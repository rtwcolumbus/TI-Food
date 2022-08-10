page 37002217 "Open Repack Orders"
{
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 23 JUL 07
    //   Standard list form for repack orders
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 08 Dec 09
    //   Added as new List Page for Open Repack Orders
    // 
    // PRW16.00.05
    // P8000943, Columbus IT, Jack Reynolds, 06 MAY 11
    //   Add Due Date
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW120.00
    // P800144605, To Increase, Jack Reynolds, 20 APR 22
    //   Upgrade to 20.0
    //   Cleanup Role Centers and Navigate (Find Entries)

    ApplicationArea = FOODBasic;
    Caption = 'Open Repack Orders';
    CardPageID = "Repack Order";
    Editable = false;
    PageType = List;
    SourceTable = "Repack Order";
    SourceTableView = SORTING(Status)
                      WHERE(Status = CONST(Open));
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
        area(processing)
        {
            group("P&osting")
            {
                Caption = 'P&osting';
                action(Post)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    var
                        RepackOrder: Record "Repack Order";
                        RepackBatchPostMgt: Codeunit "Repack Batch Post Mgt.";
                        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
                    begin
                        // P80053245
                        CurrPage.SetSelectionFilter(RepackOrder);
                        if RepackOrder.Count > 1 then begin
                            BatchProcessingMgt.SetParameter("Batch Posting Parameter Type"::FOODRepackTransfer, true); // P800144605
                            BatchProcessingMgt.SetParameter("Batch Posting Parameter Type"::FOODRepackProduce, true);  // P800144605

                            RepackBatchPostMgt.SetBatchProcessor(BatchProcessingMgt);
                            RepackBatchPostMgt.RunWithUI(RepackOrder, RepackOrder.Count, ReadyToPostQst);
                        end else
                            CODEUNIT.Run(CODEUNIT::"Repack-Post (Yes/No)", Rec);
                    end;
                }
                action(PostBatch)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Post &Batch';
                    Ellipsis = true;
                    Image = PostBatch;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        // P80053245
                        REPORT.RunModal(REPORT::"Batch Post Repack Orders", true, true, Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
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

    var
        ReadyToPostQst: Label '%1 out of %2 selected orders are ready for post. \Do you want to continue and post them?', Comment = '%1 - selected count, %2 - total count';
}

