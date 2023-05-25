page 37002214 "Repack Orders"
{
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 23 JUL 07
    //   Standard list form for repack orders
    // 
    // PRW16.00.05
    // P8000936, Columbus IT, Jack Reynolds, 25 APR 11
    //   Support for Repack Orders on Sales Board
    // 
    // P8000943, Columbus IT, Jack Reynolds, 06 MAY 11
    //   Add Due Date
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 16 NOV 15
    //   Page Management; Cleanup action names

    Caption = 'Repack Orders';
    Editable = false;
    PageType = List;
    SourceTable = "Repack Order";

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
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Date Required"; "Date Required")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Repack Location"; "Repack Location")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Destination Location"; "Destination Location")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
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
            group("O&rder")
            {
                Caption = 'O&rder';
                action("Show Document")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Show Document';
                    Image = ShowList;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
                    var
                        PageManagement: Codeunit "Page Management";
                    begin
                        // P8004516
                        PageManagement.PageRunModal(Rec);
                    end;
                }
            }
        }
        area(Promoted)
        {
            actionref(ShowDocument_Promoted; "Show Document")
            {
            }
        }
    }
}

