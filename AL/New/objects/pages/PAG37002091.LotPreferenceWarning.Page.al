page 37002091 "Lot Preference Warning"
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Lot preference warning
    // 
    // PR3.70.08
    // P8000160A, Myers Nissi, Jack Reynolds, 06 JAN 05
    //   Make form editable and individual controls non-editable
    // 
    // PR3.70.09
    // P8000193A, Myers Nissi, Jack Reynolds, 22 FEB 05
    //   Correct misspellings in warning message
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 16 APR 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001070, Columbus IT, Jack Reynolds, 16 MAY 12
    //   Bring Lot Freshness and Lot Preferences together
    // 
    // PRW111.00.01
    // P80037645, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Add UOM/Measuring Method

    Caption = 'Lot Preference Warning';
    PageType = Worksheet;
    SourceTable = "Lot Specification";

    layout
    {
        area(content)
        {
            field(Control37002017; '')
            {
                ApplicationArea = FOODBasic;
                CaptionClass = MsgText;
                ShowCaption = false;
            }
            field(Control37002020; '')
            {
                ApplicationArea = FOODBasic;
                ShowCaption = false;
            }
            group(Control37002021)
            {
                ShowCaption = false;
                group(Control37002022)
                {
                    ShowCaption = false;
                    field("LotInfo.""Item No."""; LotInfo."Item No.")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Item No.';
                        Editable = false;
                    }
                    field("LotInfo.""Variant Code"""; LotInfo."Variant Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Variant Code';
                        Editable = false;
                    }
                    field("LotInfo.""Lot No."""; LotInfo."Lot No.")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Lot No.';
                        Editable = false;
                    }
                }
                group(Control37002023)
                {
                    ShowCaption = false;
                    field(AgeValue; LotAge.Age)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Lot Age';
                        Editable = false;
                    }
                    field(AgePref; LotAgeFilter."Age Filter")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = '     Preference';
                        Editable = false;
                    }
                    field(AgeWarning; AgeWarning)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = '     Status';
                        Editable = false;
                    }
                }
                group(Control37002024)
                {
                    ShowCaption = false;
                    field(AgeCatValue; LotAge."Age Category")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Lot Age Category';
                        Editable = false;
                    }
                    field(AgeCatPref; LotAgeFilter."Category Filter")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = '     Preference';
                        Editable = false;
                    }
                    field(AgeCatWarning; AgeCatWarning)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = '     Status';
                        Editable = false;
                    }
                }
                group(Control37002025)
                {
                    ShowCaption = false;
                    field(FreshDate; FreshDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Lot Freshness';
                        Editable = false;
                    }
                    field(OldestAcceptableDate; OldestAcceptableDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = '     Oldest Acceptable Date';
                        Editable = false;
                    }
                    field(FreshWarning; FreshWarning)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = '     Status';
                        Editable = false;
                    }
                }
            }
            repeater(Details)
            {
                Caption = 'Details';
                Editable = false;
                field("Data Element Code"; "Data Element Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Measuring Method"; "Measuring Method")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Value; Value)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Preference; CatPref)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Preference';
                }
                field(SpecWarning; SpecWarning)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Status';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("A&pprove")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Approve';
                Image = Approve;
                ShortCutKey = 'Ctrl+P';
                Visible = Warning;

                trigger OnAction()
                begin
                    // P8001070
                    UseLot := true;
                    CurrPage.Close;
                end;
            }
            action("&Reject")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Reject';
                Image = Reject;
                ShortCutKey = 'Ctrl+R';
                Visible = Warning;

                trigger OnAction()
                begin
                    // P8001070
                    UseLot := false;
                    CurrPage.Close;
                end;
            }
        }
        area(Promoted)
        {
            actionref(Approve_Promoted; "A&pprove")
            {
            }
            actionref(Reject_Promoted; "&Reject")
            {
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LotSpecFilter.SetRange("Data Element Code", "Data Element Code");
        if LotSpecFilter.Find('-') then begin
            CatPref := LotSpecFilter.Filter;
            if LotSpecFilter.Mark then
                SpecWarning := Text001
            else
                SpecWarning := '';
        end else begin
            CatPref := '';
            SpecWarning := '';
        end;
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        TempLotSpec := Rec;
        if not TempLotSpec.Find(Which) then
            exit(false);
        Rec := TempLotSpec;
        exit(true);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        CurrentSteps: Integer;
    begin
        TempLotSpec := Rec;
        CurrentSteps := TempLotSpec.Next(Steps);
        if CurrentSteps <> 0 then
            Rec := TempLotSpec;
        exit(CurrentSteps);
    end;

    var
        LotInfo: Record "Lot No. Information";
        LotAge: Record "Lot Age";
        LotAgeFilter: Record "Lot Age Filter";
        LotSpecFilter: Record "Lot Specification Filter" temporary;
        TempLotSpec: Record "Lot Specification" temporary;
        CatPref: Text[250];
        Color: Integer;
        AgeWarning: Text[30];
        AgeCatWarning: Text[30];
        SpecWarning: Text[30];
        Text001: Label 'Violation';
        FreshDate: Date;
        OldestAcceptableDate: Date;
        FreshWarning: Text[30];
        Text002: Label '  The selected lot fails to satisfy the specified preferences for age, specifications, or freshness.';
        UseLot: Boolean;
        [InDataSet]
        Warning: Boolean;
        Text003: Label 'WARNING!';
        Text004: Label 'ERROR!';
        MsgText: Text[1024];
        Text005: Label '  Do you want to use the lot?';

    procedure SetVars(LotInfo1: Record "Lot No. Information"; LotAge1: Record "Lot Age"; LotAgeFilter1: Record "Lot Age Filter"; var LotSpecFilter1: Record "Lot Specification Filter"; AgeWarning1: Boolean; AgeCatWarning1: Boolean; FreshnessMethod: Option " ","Days To Fresh","Best If Used By","Sell By"; OldestAcceptableDate1: Date; FreshWarning1: Boolean; EnforcementLevel: Option Warning,Error)
    var
        LotSpec: Record "Lot Specification";
    begin
        // P8001070 - add parementes for FreshnessMethod, OldestAcceptableDate, FreshWarning, EnforcementLevel
        if AgeWarning1 then
            AgeWarning := Text001;
        if AgeCatWarning1 then
            AgeCatWarning := Text001;
        LotInfo := LotInfo1;
        LotAge := LotAge1;
        LotAgeFilter := LotAgeFilter1;

        LotSpec.SetRange("Item No.", LotInfo."Item No.");
        LotSpec.SetRange("Variant Code", LotInfo."Variant Code");
        LotSpec.SetRange("Lot No.", LotInfo."Lot No.");
        if LotSpec.Find('-') then
            repeat
                TempLotSpec := LotSpec;
                TempLotSpec.Insert;
            until LotSpec.Next = 0;

        if LotSpecFilter1.Find('-') then
            repeat
                LotSpecFilter := LotSpecFilter1;
                LotSpecFilter.Insert;
                LotSpecFilter.Mark(LotSpecFilter1.Mark);

                if not LotSpec.Get(LotInfo."Item No.", LotInfo."Variant Code", LotInfo."Lot No.", LotSpecFilter."Data Element Code") then begin
                    TempLotSpec."Item No." := LotInfo."Item No.";
                    TempLotSpec."Variant Code" := LotInfo."Variant Code";
                    TempLotSpec."Lot No." := LotInfo."Lot No.";
                    TempLotSpec.Validate("Data Element Code", LotSpecFilter."Data Element Code");
                    TempLotSpec.Insert;
                end;
            until LotSpecFilter1.Next = 0;

        // P8001070
        case FreshnessMethod of
            FreshnessMethod::"Days To Fresh":
                FreshDate := LotInfo."Creation Date";
            FreshnessMethod::"Best If Used By", FreshnessMethod::"Sell By":
                FreshDate := LotInfo."Freshness Date";
        end;
        OldestAcceptableDate := OldestAcceptableDate1;
        if FreshWarning1 then
            FreshWarning := Text001;

        case EnforcementLevel of
            EnforcementLevel::Warning:
                begin
                    MsgText := Text003 + Text002 + Text005;
                    Warning := true;
                end;
            EnforcementLevel::Error:
                begin
                    MsgText := Text004 + Text002;
                    Warning := false;
                end;
        end;
        // P8001070
    end;

    procedure GetUseLot(): Boolean
    begin
        // P8001070
        exit(UseLot)
    end;
}

