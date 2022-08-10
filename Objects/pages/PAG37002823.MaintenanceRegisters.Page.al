page 37002823 "Maintenance Registers"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard register form, adapted for maintenance
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 02 FEB 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
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
    Caption = 'Maintenance Registers';
    Editable = false;
    PageType = List;
    SourceTable = "Maintenance Register";
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
            systempart(Control1900000003; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1900000004; Notes)
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
                action("Maintenance Ledger")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Maintenance Ledger';
                    Image = MaintenanceLedger;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        MaintLedgEntry.SetRange("Entry No.", "From Entry No.", "To Entry No.");
                        PAGE.RunModal(0, MaintLedgEntry);
                    end;
                }
            }
        }
        area(reporting)
        {
            action("Maintenance Register")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Maintenance Register';
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Maint. Register";
            }
        }
    }

    var
        MaintLedgEntry: Record "Maintenance Ledger";
}

