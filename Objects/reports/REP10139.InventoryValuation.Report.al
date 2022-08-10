report 10139 "Inventory Valuation" // Version: FOODNA
{
    // PR3.60
    //   Add logic for alternate quantities
    // 
    // PRNA6.00
    // P8000646, VerticalSoft, Jack Reynolds, 18 DEC 08\
    //   Add "Breakdown by Lot No." to request page
    // 
    // PRW16.00.03
    // P8000827, VerticalSoft, Rick Tweedle, 24 MAY 10
    //   RTC Reporting Upgrade
    // 
    // PRNA6.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRNA7.10
    // P8001252, Columbus IT, Jack Reynolds, 09 JAN 14
    //   Add Breakdown by Lots functioality to refactoring
    // 
    // PRNA7.10.02
    // P8001301, Columbus IT, Jack Reynolds, 25 MAR 14
    //   Code changes for LastLotNo and LotLabel
    // 
    // PRNA11.00.02
    // P80072032, To Increase, Jack Reynolds, 28 MAR 19
    //   Fix Remaining Quantity calculation for alternate quantities
    // 
    // PRNA11.00.03
    // P80080570, To Increase, Jack Reynolds, 20 AUG 19
    //   Fix attempt to insert duplicate records to buffer table
    //
    // PRW119.03
    // P800142405, To Increase, Gangabhushan, 14 MAR 22
    //   CS00212965 | Error when Lot number exceeds 20 characters


    DefaultLayout = RDLC;
    RDLCLayout = './layout/local/InventoryValuation.rdlc';
    ApplicationArea = Basic, Suite;
    Caption = 'Inventory Valuation';
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = WHERE(Type = CONST(Inventory));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Inventory Posting Group", "Costing Method", "Location Filter", "Variant Filter", "Lot No. Filter";
            column(CompanyInformation_Name; CompanyInformation.Name)
            {
            }
            column(STRSUBSTNO_Text003_AsOfDate_; StrSubstNo(Text003, AsOfDate))
            {
            }
            column(ShowVariants; ShowVariants)
            {
            }
            column(ShowLocations; ShowLocations)
            {
            }
            column(ShowLots; ShowLots)
            {
            }
            column(ShowACY; ShowACY)
            {
            }
            column(STRSUBSTNO_Text006_Currency_Description_; StrSubstNo(Text006, Currency.Description))
            {
            }
            column(Item_TABLECAPTION__________ItemFilter; Item.TableCaption + ': ' + ItemFilter)
            {
            }
            column(ItemFilter; ItemFilter)
            {
            }
            column(STRSUBSTNO_Text004_InvPostingGroup_TABLECAPTION_InvPostingGroup_Code_InvPostingGroup_Description_; StrSubstNo(Text004, InvPostingGroup.TableCaption, InvPostingGroup.Code, InvPostingGroup.Description))
            {
            }
            column(Item__Inventory_Posting_Group_; "Inventory Posting Group")
            {
            }
            column(Grouping; Grouping)
            {
            }
            column(Item__No__; "No.")
            {
                IncludeCaption = true;
            }
            column(Item_Description; Description)
            {
                IncludeCaption = true;
            }
            column(Item__Base_Unit_of_Measure_; "Base Unit of Measure")
            {
                IncludeCaption = true;
            }
            column(Item__Costing_Method_; "Costing Method")
            {
                IncludeCaption = true;
            }
            column(STRSUBSTNO_Text005_InvPostingGroup_TABLECAPTION_InvPostingGroup_Code_InvPostingGroup_Description_; StrSubstNo(Text005, InvPostingGroup.TableCaption, InvPostingGroup.Code, InvPostingGroup.Description))
            {
            }
            column(Inventory_ValuationCaption; Inventory_ValuationCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(InventoryValue_Control34Caption; InventoryValue_Control34CaptionLbl)
            {
            }
            column(Item_Ledger_Entry__Remaining_Quantity_Caption; "Item Ledger Entry".FieldCaption("Remaining Quantity"))
            {
            }
            column(UnitCost_Control33Caption; UnitCost_Control33CaptionLbl)
            {
            }
            column(Total_Inventory_ValueCaption; Total_Inventory_ValueCaptionLbl)
            {
            }
            dataitem("Item Ledger Entry"; "Item Ledger Entry")
            {
                DataItemLink = "Item No." = FIELD("No."), "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"), "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"), "Location Code" = FIELD("Location Filter"), "Variant Code" = FIELD("Variant Filter");
                DataItemTableView = SORTING("Item No.", "Variant Code", "Location Code", "Posting Date");

                trigger OnAfterGetRecord()
                begin
                    AdjustItemLedgEntryToAsOfDate("Item Ledger Entry");
                    UpdateBuffer("Item Ledger Entry");
                    CurrReport.Skip();
                end;

                trigger OnPostDataItem()
                begin
                    UpdateTempEntryBuffer;
                end;

                trigger OnPreDataItem()
                begin
                    //SETRANGE("Posting Date",0D,AsOfDate); // P8000257A
                    SetView(ItemLedgerView);                // P8000257A
                end;
            }
            dataitem(BufferLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(RowLabel; TempEntryBuffer.Label)
                {
                }
                column(RemainingQty; TempEntryBuffer."Remaining Quantity")
                {
                }
                column(InventoryValue; TempEntryBuffer.Value1)
                {
                }
                column(VariantCode; TempEntryBuffer."Variant Code")
                {
                }
                column(LocationCode; TempEntryBuffer."Location Code")
                {
                }
                column(LotNo; TempEntryBuffer."Lot No.")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if TempEntryBuffer.Next <> 1 then
                        CurrReport.Break();
                end;

                trigger OnPreDataItem()
                begin
                    Clear(TempEntryBuffer);
                    TempEntryBuffer.SetFilter("Item No.", '%1', Item."No.");
                    if Item."Location Filter" <> '' then
                        TempEntryBuffer.SetFilter("Location Code", '%1', Item."Location Filter");

                    if Item."Variant Filter" <> '' then
                        TempEntryBuffer.SetFilter("Variant Code", '%1', Item."Variant Filter");

                    // P8001252
                    if (Item."Lot No. Filter" <> '') then
                        TempEntryBuffer.SetFilter("Lot No.", '%1', Item."Lot No. Filter");
                    // P8001252
                end;
            }

            trigger OnAfterGetRecord()
            begin
                // PR3.60
                if CostInAlternateUnits() then
                    "Base Unit of Measure" := "Alternate Unit of Measure";
                // PR3.60
                if not InvPostingGroup.Get("Inventory Posting Group") then
                    Clear(InvPostingGroup);
                TempEntryBuffer.Reset();
                TempEntryBuffer.DeleteAll();
                Progress.Update(1, Format("No."));
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Date Filter", 0D, AsOfDate);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(AsOfDate; AsOfDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'As Of Date';
                        ToolTip = 'Specifies the valuation date.';
                        ShowMandatory = true;
                    }
                    field(BreakdownByVariants; ShowVariants)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Breakdown by Variants';
                        ToolTip = 'Specifies the item variants that you want the report to consider.';
                    }
                    field(BreakdownByLocation; ShowLocations)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Breakdown by Location';
                        ToolTip = 'Specifies the breakdown report data by locations.';
                    }
                    field(ShowLots; ShowLots)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Breakdown by Lot No.';
                    }
                    field(UseAdditionalReportingCurrency; ShowACY)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Use Additional Reporting Currency';
                        ToolTip = 'Specifies if you want all amounts to be printed by using the additional reporting currency. If you do not select the check box, then all amounts will be printed in US dollars.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        Progress.Close();
    end;

    trigger OnPreReport()
    begin
        Grouping := (Item.FieldCaption("Inventory Posting Group") = Item.CurrentKey);

        if AsOfDate = 0D then
            Error(Text000);

        // P8000257A Begin
        case true of
            ShowVariants and ShowLocations and ShowLots:
                if not "Item Ledger Entry".SetCurrentKey("Item No.", "Variant Code", "Location Code", "Lot No.", "Serial No.", "Posting Date") then
                    Error(Text37002000,
                      "Item Ledger Entry".TableCaption, "Item Ledger Entry".FieldCaption("Item No."),
                      StrSubstNo(Text37002003,
                        "Item Ledger Entry".FieldCaption("Variant Code"),
                        "Item Ledger Entry".FieldCaption("Location Code"),
                        "Item Ledger Entry".FieldCaption("Lot No.")));
            ShowVariants and ShowLocations and (not ShowLots):
                if not "Item Ledger Entry".SetCurrentKey("Item No.", "Variant Code", "Location Code", "Lot No.", "Serial No.", "Posting Date") then
                    Error(Text37002000,
                      "Item Ledger Entry".TableCaption, "Item Ledger Entry".FieldCaption("Item No."),
                      StrSubstNo(Text37002002,
                        "Item Ledger Entry".FieldCaption("Variant Code"),
                        "Item Ledger Entry".FieldCaption("Location Code")));
            ShowVariants and (not ShowLocations) and ShowLots:
                if not "Item Ledger Entry".SetCurrentKey("Item No.", "Variant Code", "Lot No.", Positive, "Posting Date") then
                    Error(Text37002000,
                      "Item Ledger Entry".TableCaption, "Item Ledger Entry".FieldCaption("Item No."),
                      StrSubstNo(Text37002002,
                        "Item Ledger Entry".FieldCaption("Variant Code"),
                        "Item Ledger Entry".FieldCaption("Lot No.")));
            ShowVariants and (not ShowLocations) and (not ShowLots):
                if not "Item Ledger Entry".SetCurrentKey("Item No.", "Variant Code", "Lot No.", Positive, "Posting Date") then
                    Error(Text37002000,
                      "Item Ledger Entry".TableCaption, "Item Ledger Entry".FieldCaption("Item No."),
                      StrSubstNo(Text37002001,
                        "Item Ledger Entry".FieldCaption("Variant Code")));
            (not ShowVariants) and ShowLocations and ShowLots:
                if not "Item Ledger Entry".SetCurrentKey("Item No.", "Location Code", "Lot No.", "Posting Date") then
                    Error(Text37002000,
                      "Item Ledger Entry".TableCaption, "Item Ledger Entry".FieldCaption("Item No."),
                      StrSubstNo(Text37002002,
                        "Item Ledger Entry".FieldCaption("Location Code"),
                        "Item Ledger Entry".FieldCaption("Lot No.")));
            (not ShowVariants) and ShowLocations and (not ShowLots):
                if not "Item Ledger Entry".SetCurrentKey("Item No.", "Location Code", "Lot No.", "Posting Date") then
                    Error(Text37002000,
                      "Item Ledger Entry".TableCaption, "Item Ledger Entry".FieldCaption("Item No."),
                      StrSubstNo(Text37002001,
                        "Item Ledger Entry".FieldCaption("Location Code")));
            (not ShowVariants) and (not ShowLocations) and ShowLots:
                if not "Item Ledger Entry".SetCurrentKey("Item No.", "Lot No.", "Posting Date") then
                    Error(Text37002000,
                      "Item Ledger Entry".TableCaption, "Item Ledger Entry".FieldCaption("Item No."),
                      StrSubstNo(Text37002001,
                        "Item Ledger Entry".FieldCaption("Lot No.")));
        end;
        "Item Ledger Entry".SetRange("Posting Date", 0D, AsOfDate);
        ItemLedgerView := "Item Ledger Entry".GetView;
        // P8000257A End
        /*P8000257A Begin
        IF ShowLocations AND NOT ShowVariants THEN
          IF NOT "Item Ledger Entry".SETCURRENTKEY("Item No.","Location Code") THEN
            ERROR(Text001,
              "Item Ledger Entry".TABLECAPTION,
              "Item Ledger Entry".FIELDCAPTION("Item No."),
              "Item Ledger Entry".FIELDCAPTION("Location Code"));
        IF Item.GETFILTER("Date Filter") <> '' THEN
          ERROR(Text002,Item.FIELDCAPTION("Date Filter"),Item.TABLECAPTION);
        P8000257A End*/

        CompanyInformation.Get();
        ItemFilter := Item.GetFilters();
        GLSetup.Get();
        if GLSetup."Additional Reporting Currency" = '' then
            ShowACY := false
        else begin
            Currency.Get(GLSetup."Additional Reporting Currency");
            Currency.TestField("Amount Rounding Precision");
            Currency.TestField("Unit-Amount Rounding Precision");
        end;
        Progress.Open(Item.TableCaption + '  #1############');

    end;

    var
        GLSetup: Record "General Ledger Setup";
        CompanyInformation: Record "Company Information";
        InvPostingGroup: Record "Inventory Posting Group";
        Currency: Record Currency;
        Location: Record Location;
        ItemVariant: Record "Item Variant";
        ItemFilter: Text;
        ShowVariants: Boolean;
        ShowLocations: Boolean;
        ShowACY: Boolean;
        AsOfDate: Date;
        Text000: Label 'You must enter an As Of Date.';
        Text001: Label 'If you want to show Locations without also showing Variants, you must add a new key to the %1 table which starts with the %2 and %3 fields.';
        Text002: Label 'Do not set a %1 on the %2.  Use the As Of Date on the Option tab instead.';
        Text003: Label 'Quantities and Values As Of %1';
        Text004: Label '%1 %2 (%3)';
        Text005: Label '%1 %2 (%3) Total';
        Text006: Label 'All Inventory Values are shown in %1.';
        Text007: Label 'No Variant';
        Text008: Label 'No Location';
        Grouping: Boolean;
        Inventory_ValuationCaptionLbl: Label 'Inventory Valuation';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        InventoryValue_Control34CaptionLbl: Label 'Inventory Value';
        UnitCost_Control33CaptionLbl: Label 'Unit Cost';
        Total_Inventory_ValueCaptionLbl: Label 'Total Inventory Value';
        LastItemNo: Code[20];
        LastLocationCode: Code[10];
        LastVariantCode: Code[10];
        TempEntryBuffer: Record "Item Location Variant Buffer" temporary;
        VariantLabel: Text[250];
        LocationLabel: Text[250];
        IsCollecting: Boolean;
        Progress: Dialog;
        ItemLedgerView: Text[1024];
        ShowLots: Boolean;
        Text37002000: Label 'If you want to show this combination of Variants, Locations, and Lots, you must add a new key to the %1 table which begins with %2 and includes %3.';
        Text37002001: Label '%1';
        Text37002002: Label '%1 and %2';
        Text37002003: Label '%1, %2, and %3';
        LastLotNo: Code[50];
        LotLabel: Text[250];
        Text37002004: Label 'Lot';
        Text37002005: Label 'No Lot';

    local procedure AdjustItemLedgEntryToAsOfDate(var ItemLedgEntry: Record "Item Ledger Entry")
    var
        ItemApplnEntry: Record "Item Application Entry";
        ValueEntry: Record "Value Entry";
        ItemLedgEntry2: Record "Item Ledger Entry";
    begin
        with ItemLedgEntry do begin
            Quantity := GetCostingQty(); // PR3.60
                                         // adjust remaining quantity
            "Remaining Quantity" := Quantity;
            if Positive then begin
                ItemApplnEntry.Reset();
                ItemApplnEntry.SetCurrentKey(
                  "Inbound Item Entry No.", "Item Ledger Entry No.", "Outbound Item Entry No.", "Cost Application");
                ItemApplnEntry.SetRange("Inbound Item Entry No.", "Entry No.");
                ItemApplnEntry.SetRange("Posting Date", 0D, AsOfDate);
                ItemApplnEntry.SetFilter("Outbound Item Entry No.", '<>%1', 0);
                ItemApplnEntry.SetFilter("Item Ledger Entry No.", '<>%1', "Entry No.");
                ItemApplnEntry.CalcSums(Quantity, "Quantity (Alt.)");   // P80072032
                ItemApplnEntry."Item Ledger Entry No." := "Entry No."; // P80072032
                                                                       //"Remaining Quantity" += ItemApplnEntry.Quantity;        // PR3.60. P80072032
                "Remaining Quantity" += ItemApplnEntry.GetCostingQty(); // PR3.60
            end else begin
                ItemApplnEntry.Reset();
                ItemApplnEntry.SetCurrentKey(
                  "Outbound Item Entry No.", "Item Ledger Entry No.", "Cost Application", "Transferred-from Entry No.");
                ItemApplnEntry.SetRange("Item Ledger Entry No.", "Entry No.");
                ItemApplnEntry.SetRange("Outbound Item Entry No.", "Entry No.");
                ItemApplnEntry.SetRange("Posting Date", 0D, AsOfDate);
                if ItemApplnEntry.Find('-') then
                    repeat
                        if ItemLedgEntry2.Get(ItemApplnEntry."Inbound Item Entry No.") and
                           (ItemLedgEntry2."Posting Date" <= AsOfDate)
                        then
                            //"Remaining Quantity" := "Remaining Quantity" - ItemApplnEntry.Quantity;      // PR3.60
                            "Remaining Quantity" := "Remaining Quantity" - ItemApplnEntry.GetCostingQty(); // PR3.60
                    until ItemApplnEntry.Next() = 0;
            end;

            // calculate adjusted cost of entry
            ValueEntry.Reset();
            ValueEntry.SetRange("Item Ledger Entry No.", "Entry No.");
            ValueEntry.SetRange("Posting Date", 0D, AsOfDate);
            ValueEntry.CalcSums(
              "Cost Amount (Expected)", "Cost Amount (Actual)", "Cost Amount (Expected) (ACY)", "Cost Amount (Actual) (ACY)");
            "Cost Amount (Actual)" := Round(ValueEntry."Cost Amount (Actual)" + ValueEntry."Cost Amount (Expected)");
            "Cost Amount (Actual) (ACY)" :=
              Round(
                ValueEntry."Cost Amount (Actual) (ACY)" + ValueEntry."Cost Amount (Expected) (ACY)", Currency."Amount Rounding Precision");
        end;
    end;

    procedure UpdateBuffer(var ItemLedgEntry: Record "Item Ledger Entry")
    var
        NewRow: Boolean;
    begin
        if ItemLedgEntry."Item No." <> LastItemNo then begin
            ClearLastEntry();
            LastItemNo := ItemLedgEntry."Item No.";
            NewRow := true
        end;

        //IF ShowVariants OR ShowLocations OR ShowLots THEN BEGIN // P8001301, P80080570
        if ShowVariants and (ItemLedgEntry."Variant Code" <> LastVariantCode) then begin // P80080570
            NewRow := true;
            LastVariantCode := ItemLedgEntry."Variant Code";
            if ShowVariants then begin
                if (ItemLedgEntry."Variant Code" = '') or not ItemVariant.Get(ItemLedgEntry."Item No.", ItemLedgEntry."Variant Code") then
                    VariantLabel := Text007
                else
                    VariantLabel := ItemVariant.TableCaption + ' ' + ItemLedgEntry."Variant Code" + '(' + ItemVariant.Description + ')';
            end
            else
                VariantLabel := ''
        end;
        if ShowLocations and (ItemLedgEntry."Location Code" <> LastLocationCode) then begin // P80080570
            NewRow := true;
            LastLocationCode := ItemLedgEntry."Location Code";
            if ShowLocations then begin
                if (ItemLedgEntry."Location Code" = '') or not Location.Get(ItemLedgEntry."Location Code") then
                    LocationLabel := Text008
                else
                    LocationLabel := Location.TableCaption + ' ' + ItemLedgEntry."Location Code" + '(' + Location.Name + ')';
            end
            else
                LocationLabel := '';
        end; // P8001301
             // P8001301
        if ShowLots and (ItemLedgEntry."Lot No." <> LastLotNo) then begin // P80080570
            NewRow := true;
            LastLotNo := ItemLedgEntry."Lot No.";
            if ShowLots then begin
                if ItemLedgEntry."Lot No." = '' then
                    LotLabel := Text37002005
                else
                    LotLabel := Text37002004 + ' ' + ItemLedgEntry."Lot No.";
            end
            else
                LotLabel := '';
        end;
        // P8001301
        //END; // P80080570

        if NewRow then
            UpdateTempEntryBuffer();

        TempEntryBuffer."Remaining Quantity" += ItemLedgEntry."Remaining Quantity";
        if ShowACY then
            TempEntryBuffer.Value1 += ItemLedgEntry."Cost Amount (Actual) (ACY)"
        else
            TempEntryBuffer.Value1 += ItemLedgEntry."Cost Amount (Actual)";

        TempEntryBuffer."Item No." := ItemLedgEntry."Item No.";
        TempEntryBuffer."Variant Code" := LastVariantCode;
        TempEntryBuffer."Location Code" := LastLocationCode;
        TempEntryBuffer."Lot No." := LastLotNo; // P8001252
        TempEntryBuffer.Label := CopyStr(VariantLabel + ' ' + LocationLabel + ' ' + LotLabel, 1, MaxStrLen(TempEntryBuffer.Label)); // P8001252

        IsCollecting := true;
    end;

    procedure ClearLastEntry()
    begin
        LastItemNo := '@@@';
        LastLocationCode := '@@@';
        LastVariantCode := '@@@';
        LastLotNo := '@@@'; // P8001252
    end;

    procedure UpdateTempEntryBuffer()
    begin
        if IsCollecting and ((TempEntryBuffer."Remaining Quantity" <> 0) or (TempEntryBuffer.Value1 <> 0)) then
            TempEntryBuffer.Insert();
        IsCollecting := false;
        Clear(TempEntryBuffer);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnAfterItemGetRecord(var Item: Record Item; var SkipItem: Boolean)
    begin
    end;
}

