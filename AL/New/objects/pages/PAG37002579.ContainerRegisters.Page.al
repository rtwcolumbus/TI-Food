page 37002579 "Container Registers"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Standard register form for container registers
    // 
    // PRW16.00.02
    // P8000782, VerticalSoft, Rick Tweedle, 02 MAR 10
    //   Transformed to Page using transfor tool
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Container Registers';
    Editable = false;
    PageType = List;
    SourceTable = "Container Register";

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
                action("Container Ledger")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Container Ledger';
                    Image = ItemLedger;

                    trigger OnAction()
                    begin
                        ContLedgEntry.SetRange("Entry No.", "From Entry No.", "To Entry No.");
                        PAGE.RunModal(0, ContLedgEntry);
                    end;
                }
            }
        }
        area(Promoted)
        {
            actionref(ContainerLedger_Promoted; "Container Ledger")
            {
            }
        }
    }

    var
        ContLedgEntry: Record "Container Ledger Entry";
}

