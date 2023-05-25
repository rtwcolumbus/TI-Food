page 37002154 "Vendor Accrual Plan List"
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
    // P8000664, VerticalSoft, Jimmy Abidi, 08 Dec 09
    //   Added as new List Page for Vendor Rebate/Promo Card
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Vendor Rebates/Promos';
    CardPageID = "Vendor Rebate/Promo Card";
    Editable = false;
    PageType = List;
    SourceTable = "Accrual Plan";
    SourceTableView = WHERE(Type = CONST(Purchase));
    UsageCategory = Lists;

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
            part(Control37002001; "Accrual Plan Details FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = Type = FIELD(Type),
                              "No." = FIELD("No.");
                Visible = true;
            }
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
                    Image = ItemLedger;
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
            actionref(LedgerEntries_Promoted; "Ledger E&ntries")
            {
            }
            actionref(AccrualSchedule_Promoted; "Accrual Schedule")
            {
            }
            actionref(Statistics_Promoted; Statistics)
            {
            }
        }
    }
}

