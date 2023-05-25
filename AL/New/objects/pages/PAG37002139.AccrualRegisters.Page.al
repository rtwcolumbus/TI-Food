page 37002139 "Accrual Registers"
{
    // PR3.61AC
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    ApplicationArea = FOODBasic;
    Caption = 'Accrual Registers';
    Editable = false;
    PageType = List;
    SourceTable = "Accrual Register";
    UsageCategory = History;

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
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Creation Time"; "Creation Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Code"; "Source Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Journal Batch Name"; "Journal Batch Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field("From Entry No."; "From Entry No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("To Entry No."; "To Entry No.")
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
            group("&Register")
            {
                Caption = '&Register';
                action("Accrual Ledger")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Accrual Ledger';
                    Image = InsuranceLedger;

                    trigger OnAction()
                    var
                        AccrualLedgEntry: Record "Accrual Ledger Entry";
                    begin
                        AccrualLedgEntry.SetRange("Entry No.", "From Entry No.", "To Entry No.");
                        PAGE.RunModal(0, AccrualLedgEntry);
                    end;
                }
            }
        }
        area(Promoted)
        {
            actionref(AccrualLedger_Promoted; "Accrual Ledger")
            {
            }
        }
    }
}

