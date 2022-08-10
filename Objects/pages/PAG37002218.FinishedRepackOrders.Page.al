page 37002218 "Finished Repack Orders"
{
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 23 JUL 07
    //   Standard list form for repack orders
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 08 Dec 09
    //   Added as new List Page for Finished Repack Orders
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 01 JUN 22
    //   Cleanup Role Centers and Navigate (Find Entries)

    ApplicationArea = FOODBasic;
    Caption = 'Finished Repack Orders';
    CardPageID = "Finished Repack Order";
    Editable = false;
    PageType = List;
    SourceTable = "Repack Order";
    SourceTableView = SORTING(Status)
                      WHERE(Status = CONST(Finished));
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
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Brand; Brand)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Farm; Farm)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Country/Region of Origin Code"; "Country/Region of Origin Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Date Required"; "Date Required")
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
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Repack Order Comment Sheet";
                    RunPageLink = "Repack Order No." = FIELD("No.");
                }
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;

                    trigger OnAction()
                    begin
                        ShowDocDim;
                    end;
                }
                action(Navigate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Find entries...'; // P800144605
                    Image = Navigate;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Ctrl+Alt+Q'; // P800144605

                    trigger OnAction()
                    begin
                        Navigate;
                    end;
                }
            }
        }
    }
}

