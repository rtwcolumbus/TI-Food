codeunit 37002024 "Lot Filtering"
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Support functions for displaying lot age data
    //   Support functions for setting lot specification filters
    //   Support functions for validating lots against age and specification filters and preferences
    // 
    // PR3.70.08
    // P8000165A, Myers Nissi, Jack Reynolds, 11 FEB 05
    //   Support for aging on dates other than TODAY
    // 
    // PRW16.00.20
    // P8000685, VerticalSoft, Jack Reynolds, 14 APR 09
    //   Modifications for RTC
    // 
    // PRW16.00.06
    // P8001070, Columbus IT, Jack Reynolds, 16 MAY 12
    //   Bring Lot Freshness and Lot Preferences together
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group


    trigger OnRun()
    begin
    end;

    var
        LotAge: Record "Lot Age" temporary;
        AgingDate: Date;
        LotAgeDate: Date;
        Text001: Label 'Age';
        Text002: Label 'Category';
        Text003: Label 'Days to Expire';
        LotAgeProfileCode: Code[10];

    procedure SetAgingDate(AgeDate: Date)
    begin
        AgingDate := AgeDate; // P000165A
    end;

    local procedure GetLotAge(LotInfo: Record "Lot No. Information")
    var
        AgeDate: Date;
    begin
        // P8000165A Begin
        if AgingDate = 0D then
            AgeDate := Today
        else
            AgeDate := AgingDate;
        // P8000165A End

        if LotAgeDate <> AgeDate then begin // P8000165A
            LotAge.Reset;
            LotAge.DeleteAll;
            LotAgeDate := AgeDate;            // P8000165A
        end;

        if not LotAge.Get(LotInfo."Item No.", LotInfo."Variant Code", LotInfo."Lot No.") then begin
            LotAge.Init;
            LotAge."Item No." := LotInfo."Item No.";
            LotAge."Variant Code" := LotInfo."Variant Code";
            LotAge."Lot No." := LotInfo."Lot No.";
            LotAge."Production Date" := LotInfo."Creation Date";
            LotAge."Expiration Date" := LotInfo."Expiration Date";
            LotAge.CalculateFields(LotAgeDate); // P8000165A
            LotAge.Insert;
        end;
    end;

    procedure ClearLotAge(LotInfo: Record "Lot No. Information")
    begin
        if LotAge.Get(LotInfo."Item No.", LotInfo."Variant Code", LotInfo."Lot No.") then
            LotAge.Delete;
    end;

    procedure Age(LotInfo: Record "Lot No. Information"): Integer
    begin
        GetLotAge(LotInfo);
        exit(LotAge.Age);
    end;

    procedure AgeCategory(LotInfo: Record "Lot No. Information"): Code[10]
    begin
        GetLotAge(LotInfo);
        exit(LotAge."Age Category");
    end;

    procedure AgeDate(LotInfo: Record "Lot No. Information"): Date
    begin
        GetLotAge(LotInfo);
        exit(LotAge."Current Age Date");
    end;

    procedure RemainingDays(LotInfo: Record "Lot No. Information"): Integer
    begin
        GetLotAge(LotInfo);
        exit(LotAge."Remaining Days");
    end;

    procedure DaysToExpire(LotInfo: Record "Lot No. Information"): Integer
    begin
        // P8000251A
        GetLotAge(LotInfo);
        exit(LotAge."Days to Expire");
    end;

    procedure LotInFilter(LotInfo: Record "Lot No. Information"; var LotAgeFilters: Record "Lot Age"; var LotSpecFilter: Record "Lot Specification Filter" temporary; FreshnessMethod: Option " ","Days To Fresh","Best If Used By","Sell By"; OldestAcceptableDate: Date): Boolean
    var
        LotSpec: Record "Lot Specification";
        Item: Record Item;
    begin
        // P8001070 - add parameters for FreshnessMethod, OldestAcceptableDate, EnforcementLevel
        // P8001070
        if OldestAcceptableDate <> 0D then
            case FreshnessMethod of
                FreshnessMethod::"Days To Fresh":
                    if LotInfo."Creation Date" < OldestAcceptableDate then
                        exit(false);
                FreshnessMethod::"Best If Used By", FreshnessMethod::"Sell By":
                    if LotInfo."Freshness Date" < OldestAcceptableDate then
                        exit(false);
            end;
        // P8001070
        GetLotAge(LotInfo);
        LotAge.CopyFilters(LotAgeFilters);
        if LotAge.Find then begin
            LotSpecFilter.Reset;
            LotSpec.SetRange("Item No.", LotInfo."Item No.");
            LotSpec.SetRange("Variant Code", LotInfo."Variant Code");
            LotSpec.SetRange("Lot No.", LotInfo."Lot No.");
            if LotSpecFilter.Find('-') then begin
                repeat
                    LotSpec.SetRange("Data Element Code", LotSpecFilter."Data Element Code");
                    LotSpec.SetRange("Boolean Value");
                    LotSpec.SetRange("Date Value");
                    LotSpec.SetRange("Lookup Value");
                    LotSpec.SetRange("Numeric Value");
                    LotSpec.SetRange("Text Value");
                    case LotSpecFilter."Data Element Type" of
                        LotSpecFilter."Data Element Type"::Boolean:
                            LotSpec.SetFilter("Boolean Value", LotSpecFilter.Filter);
                        LotSpecFilter."Data Element Type"::Date:
                            LotSpec.SetFilter("Date Value", LotSpecFilter.Filter);
                        LotSpecFilter."Data Element Type"::"Lookup":
                            LotSpec.SetFilter("Lookup Value", LotSpecFilter.Filter);
                        LotSpecFilter."Data Element Type"::Numeric:
                            LotSpec.SetFilter("Numeric Value", LotSpecFilter.Filter);
                        LotSpecFilter."Data Element Type"::Text:
                            LotSpec.SetFilter("Text Value", LotSpecFilter.Filter);
                    end;
                    if not LotSpec.Find('-') then
                        exit(false);
                until LotSpecFilter.Next = 0;
                exit(true);
            end else
                exit(true);
        end else
            exit(false);
    end;

    procedure LotSpecAssist(var LotSpecFilter: Record "Lot Specification Filter" temporary): Boolean
    var
        InvSetup: Record "Inventory Setup";
        LotSpecCat: Record "Data Collection Data Element";
        SpecFilter: Record "Lot Specification Filter" temporary;
        ShortcutSpec: array[5] of Code[10];
        i: Integer;
    begin
        LotSpecFilter.Reset;
        if LotSpecFilter.Find('-') then
            repeat
                SpecFilter := LotSpecFilter;
                SpecFilter.Insert;
            until LotSpecFilter.Next = 0;

        InvSetup.Get;
        ShortcutSpec[1] := InvSetup."Shortcut Lot Spec. 1 Code";
        ShortcutSpec[2] := InvSetup."Shortcut Lot Spec. 2 Code";
        ShortcutSpec[3] := InvSetup."Shortcut Lot Spec. 3 Code";
        ShortcutSpec[4] := InvSetup."Shortcut Lot Spec. 4 Code";
        ShortcutSpec[5] := InvSetup."Shortcut Lot Spec. 5 Code";

        for i := 1 to 5 do
            if ShortcutSpec[i] <> '' then
                if not SpecFilter.Get(0, 0, '', '', 0, 0, ShortcutSpec[i]) then begin
                    SpecFilter.Init;
                    SpecFilter.Validate("Data Element Code", ShortcutSpec[i]);
                    SpecFilter.Insert;
                end;

        //IF FORM.RUNMODAL(0,SpecFilter) = ACTION::OK THEN BEGIN                    // P8000685
        if PAGE.RunModal(0, SpecFilter) in [ACTION::OK, ACTION::LookupOK] then begin // P8000685
            LotSpecFilter.DeleteAll;
            SpecFilter.SetFilter(Filter, '<>%1', '');
            if SpecFilter.Find('-') then
                repeat
                    LotSpecFilter := SpecFilter;
                    LotSpecFilter.Insert;
                until SpecFilter.Next = 0;
            exit(true);
        end;
    end;

    procedure LotAgeText(LotAgeFilter: Record "Lot Age Filter") SpecText: Text[1024]
    begin
        // P8000165A
        if LotAgeFilter."Age Filter" <> '' then
            SpecText := SpecText + StrSubstNo(', %1: %2', Text001, LotAgeFilter."Age Filter");
        if LotAgeFilter."Category Filter" <> '' then
            SpecText := SpecText + StrSubstNo(', %1: %2', Text002, LotAgeFilter."Category Filter");
        // P8000251A Begin
        if LotAgeFilter."Days to Expire Filter" <> '' then
            SpecText := SpecText + StrSubstNo(', %1: %2', Text003, LotAgeFilter."Days to Expire Filter");
        // P8000251A End
        SpecText := CopyStr(SpecText, 3);
    end;

    procedure LotSpecText(var LotSpecFilter: Record "Lot Specification Filter" temporary) SpecText: Text[1024]
    var
        LotSpecCat: Record "Data Collection Data Element";
    begin
        LotSpecFilter.Reset;
        if LotSpecFilter.Find('-') then
            repeat
                LotSpecCat.Get(LotSpecFilter."Data Element Code");
                SpecText := SpecText + ', ' + LotSpecCat.Description + ': ' + LotSpecFilter.Filter;
            until LotSpecFilter.Next = 0;
        SpecText := CopyStr(SpecText, 3);
    end;

    procedure ItemAgeSummary(var LotInfo: Record "Lot No. Information"; var LotAgeFilters: Record "Lot Age"; var LotSpecFilter: Record "Lot Specification Filter" temporary)
    var
        Item: Record Item;
        ItemCat: Record "Item Category";
        AgeProfileCat: Record "Lot Age Profile Category";
        AgeSummary: Record "Lot Age Profile Category" temporary;
        LotInfo2: Record "Lot No. Information";
        ItemAgeSummary: Page "Item Age Summary";
    begin
        Item.Get(LotInfo."Item No.");
        if not ItemCat.Get(Item."Item Category Code") then
            exit;
        LotAgeProfileCode := ItemCat.GetLotAgeProfileCode; // P8007749
        if LotAgeProfileCode = '' then                     // P8007749
            exit;

        AgeProfileCat.SetRange("Profile Code", LotAgeProfileCode); // P8007749
        if not AgeProfileCat.Find('-') then
            exit;
        repeat
            AgeSummary := AgeProfileCat;
            AgeSummary.Insert;
        until AgeProfileCat.Next = 0;

        LotInfo2.CopyFilters(LotInfo);
        LotInfo2.SetRange("Item No.", LotInfo."Item No.");
        if LotInfo2.Find('-') then
            repeat
                if LotInFilter(LotInfo2, LotAgeFilters, LotSpecFilter, 0, 0D) then begin // P8001070
                    LotInfo2.CalcFields(Inventory, "Quantity (Alt.)");
                    AgeSummary.SetRange("Category Code", LotAge."Age Category");
                    if AgeSummary.Find('-') then begin
                        AgeSummary.Quantity += LotInfo2.Inventory;
                        AgeSummary."Quantity (Alt.)" += LotInfo2."Quantity (Alt.)";
                        AgeSummary.Modify;
                    end;
                end;
            until LotInfo2.Next = 0;

        LotInfo2.SetRange("Item No.");
        LotInfo2.SetRange("Item Category Code");
        AgeSummary.Reset;
        ItemAgeSummary.SetItem(LotInfo2."Item No.");
        ItemAgeSummary.SetFilterStrings(LotInfo2.GetFilters, LotAgeFilters.GetFilters, LotSpecText(LotSpecFilter));
        ItemAgeSummary.SetTempTable(AgeSummary);
        ItemAgeSummary.RunModal;
    end;

    procedure CheckLotPreferences(LotInfo: Record "Lot No. Information"; var LotAgeFilter: Record "Lot Age Filter"; var LotSpecFilter: Record "Lot Specification Filter"; FreshnessMethod: Option " ","Days To Fresh","Best If Used By","Sell By"; OldestAcceptableDate: Date; ShowWarning: Boolean; EnforcementLevel: Option Warning,Error): Boolean
    var
        LotSpec: Record "Lot Specification";
        LotPrefWarning: Page "Lot Preference Warning";
        Warning: Boolean;
        AgeWarning: Boolean;
        AgeCatWarning: Boolean;
        FreshWarning: Boolean;
    begin
        // P8001070 - add parameters for FreshnessMethod, OldestAcceptableDate, EnforcementLevel
        if (not LotAgeFilter.Find('-')) and (not LotSpecFilter.Find('-')) and (FreshnessMethod = 0) then // P8001070
            exit(true);

        if LotAgeFilter.Find('-') then begin
            GetLotAge(LotInfo);
            if LotAgeFilter."Age Filter" <> '' then begin
                LotAge.SetFilter(Age, LotAgeFilter."Age Filter");
                AgeWarning := not LotAge.Find;
                Warning := AgeWarning;
                LotAge.SetRange(Age);
            end;
            if Warning and (not ShowWarning) then
                exit(false);

            if LotAgeFilter."Category Filter" <> '' then begin
                LotAge.SetFilter("Age Category", LotAgeFilter."Category Filter");
                AgeCatWarning := not LotAge.Find;
                Warning := Warning or AgeCatWarning;
                LotAge.SetRange("Age Category");
            end;
            if Warning and (not ShowWarning) then
                exit(false);
        end;

        LotSpec.SetRange("Item No.", LotInfo."Item No.");
        LotSpec.SetRange("Variant Code", LotInfo."Variant Code");
        LotSpec.SetRange("Lot No.", LotInfo."Lot No.");
        if LotSpecFilter.Find('-') then
            repeat
                LotSpec.SetRange("Data Element Code", LotSpecFilter."Data Element Code");
                LotSpec.SetRange("Boolean Value");
                LotSpec.SetRange("Date Value");
                LotSpec.SetRange("Lookup Value");
                LotSpec.SetRange("Numeric Value");
                LotSpec.SetRange("Text Value");
                case LotSpecFilter."Data Element Type" of
                    LotSpecFilter."Data Element Type"::Boolean:
                        LotSpec.SetFilter("Boolean Value", LotSpecFilter.Filter);
                    LotSpecFilter."Data Element Type"::Date:
                        LotSpec.SetFilter("Date Value", LotSpecFilter.Filter);
                    LotSpecFilter."Data Element Type"::"Lookup":
                        LotSpec.SetFilter("Lookup Value", LotSpecFilter.Filter);
                    LotSpecFilter."Data Element Type"::Numeric:
                        LotSpec.SetFilter("Numeric Value", LotSpecFilter.Filter);
                    LotSpecFilter."Data Element Type"::Text:
                        LotSpec.SetFilter("Text Value", LotSpecFilter.Filter);
                end;
                if not LotSpec.Find('-') then begin
                    LotSpecFilter.Mark(true);
                    Warning := true;
                    if not ShowWarning then
                        exit(false);
                end;
            until LotSpecFilter.Next = 0;

        // P8001070
        case FreshnessMethod of
            FreshnessMethod::"Days To Fresh":
                FreshWarning := LotInfo."Creation Date" < OldestAcceptableDate;
            FreshnessMethod::"Best If Used By", FreshnessMethod::"Sell By":
                FreshWarning := LotInfo."Freshness Date" < OldestAcceptableDate;
        end;
        Warning := Warning or FreshWarning;
        // P8001070

        if not ShowWarning then
            exit(not Warning);
        if ShowWarning and (not Warning) then
            exit(true);

        GetLotAge(LotInfo);
        LotPrefWarning.SetVars(LotInfo, LotAge, LotAgeFilter, LotSpecFilter, AgeWarning, AgeCatWarning, // P8001070
          FreshnessMethod, OldestAcceptableDate, FreshWarning, EnforcementLevel);                     // P8001070
        // P8001070
        LotPrefWarning.RunModal;
        case EnforcementLevel of
            EnforcementLevel::Warning:
                exit(LotPrefWarning.GetUseLot);
            EnforcementLevel::Error:
                exit(false);
        end;
        // P8001070
    end;
}

