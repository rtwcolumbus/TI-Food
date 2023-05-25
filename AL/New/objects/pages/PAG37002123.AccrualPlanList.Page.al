page 37002123 "Accrual Plan List"
{
    // PR3.70.03
    // 
    // PR3.70.07
    // P8000119A, Myers Nissi, Don Bresee, 20 SEP 04
    //   Accruals update/fixes
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 30 JAN 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Accrual Plan List';
    Editable = false;
    PageType = List;
    SourceTable = "Accrual Plan";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Name; Name)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Plan Type"; "Plan Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Computation Level"; "Computation Level")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Accrue; Accrue)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Accrual Plan")
            {
                Caption = '&Accrual Plan';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = EditLines;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
                    begin
                        ShowCard;
                    end;
                }
                action(Statistics)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Statistics';
                    Image = Statistics;
                    ShortCutKey = 'F7';

                    trigger OnAction()
                    begin
                        PAGE.Run(PAGE::"Accrual Plan Statistics", Rec);
                    end;
                }
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = CONST(37002120),
                                  "No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                }
                action("Ledger E&ntries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ledger E&ntries';
                    RunObject = Page "Accrual Ledger Entries";
                    RunPageLink = "Accrual Plan Type" = FIELD(Type),
                                  "Accrual Plan No." = FIELD("No.");
                    RunPageView = SORTING("Accrual Plan Type", "Accrual Plan No.", "Posting Date");
                    ShortCutKey = 'Ctrl+F7';
                }
                separator(Separator1102603004)
                {
                }
                action("Accrual Schedule")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Accrual Schedule';
                    Ellipsis = true;
                    Image = InsuranceLedger;
                    ShortCutKey = 'Ctrl+S';

                    trigger OnAction()
                    begin
                        ShowScheduleLines(0);
                    end;
                }
            }
        }
        area(Promoted)
        {
            actionref(Statistics_Promoted; Statistics)
            {
            }
        }
    }

    trigger OnOpenPage()
    begin
        TypeFilter := GetFilter(Type);
        PlanTypeFilter := GetFilter("Plan Type");
        SetRange(Type);
        SetRange("Plan Type");
        FilterGroup(2);
        if (TypeFilter <> '') then
            SetFilter(Type, TypeFilter)
        else
            TypeFilter := GetFilter(Type);

        if PlanTypeFilter <> '' then
            SetFilter("Plan Type", PlanTypeFilter)
        else
            if "Plan Type" = "Plan Type"::Commission then
                PlanTypeFilter := GetFilter("Plan Type");
        FilterGroup(0);

        if (TypeFilter <> '') and (PlanTypeFilter <> '') then
            CurrPage.Caption := StrSubstNo('%1 %2 %3', TypeFilter, PlanTypeFilter, CurrPage.Caption)
        else
            if TypeFilter <> '' then
                CurrPage.Caption := StrSubstNo('%1 %2', TypeFilter, CurrPage.Caption);
    end;

    var
        TypeFilter: Text[30];
        PlanTypeFilter: Text[30];
}

