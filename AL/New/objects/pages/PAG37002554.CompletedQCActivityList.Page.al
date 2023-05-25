page 37002554 "Completed Q/C Activity List"
{
    // PRW16.00.06
    // P8001117, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Restructure role center to include history section
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW111.00.01
    // P80037573, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Skip Logic
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Completed Quality Control Activity List';
    CardPageID = "Quality Control Results Entry";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Quality Control Header";
    SourceTableView = WHERE(Status = FILTER(Pass | Fail | Skip));
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                FreezeColumn = "Lot No.";
                ShowCaption = false;
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Test No."; Rec."Test No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Re-Test"; Rec."Re-Test")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Assigned To"; Rec."Assigned To")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Schedule Date"; Rec."Schedule Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Expected Release Date"; Rec."Expected Release Date")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field("Release Date"; Rec."Release Date")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field("Complete Date"; Rec."Complete Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                    Visible = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                    Visible = false;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                    Visible = false;
                }
                field(CountOriginal; Rec.ActivityCount((false)))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Original Activities';
                    DrillDown = false;
                }
                field(CountReTest; Rec.ActivityCount((true)))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Re-Test Activities';
                    DrillDown = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002017; Links)
            {
                ApplicationArea = FOODBasic;
            }
            systempart(Control37002018; Notes)
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action("&Add")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Add';
                Image = Add;

                trigger OnAction()
                var
                    P800QCFns: Codeunit "Process 800 Q/C Functions";
                begin
                    P800QCFns.AddTest(Rec); // P8001079
                end;
            }

        }
        area(Processing)
        {
            action("&Print")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Print Results';
                Image = Print;

                trigger OnAction()
                var
                    QCHeader: Record "Quality Control Header";
                begin
                    QCHeader.Copy(Rec);
                    QCHeader.SetRecFilter;
                    REPORT.Run(REPORT::"Quality Control Test Results", true, true, QCHeader);
                end;
            }
        }
        area(Reporting)
        {
            action("Item Lots Pending")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item Lots Pending';
                Image = View;
                RunObject = Report "Item Lots Pending";
            }
            action("Item Test Results")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item Test Results';
                Image = TestReport;
                RunObject = Report "Item Test Results";
            }
        }
        area(Navigation)
        {
            group("&Lot")
            {
                Caption = '&Lot';
                action("Co&mment")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mment';
                    Image = Comment;
                    RunObject = Page "Item Tracking Comments";
                    RunPageLink = Type = CONST("Lot No."),
                                  "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Serial/Lot No." = FIELD("Lot No.");
                }
                action("Information Card")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Information Card';
                    Image = LotInfo;
                    RunObject = Page "Lot No. Information Card";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Lot No." = FIELD("Lot No.");
                }
                action("Lot &Specifications")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot &Specifications';
                    Image = LotInfo;
                    RunObject = Page "Lot Specifications";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Lot No." = FIELD("Lot No.");
                }
            }
        }
        area(Promoted)
        {
            group(Category_New)
            {
                Caption = 'New';

                actionref(Add_Promoted; "&Add")
                {
                }
            }
            actionref(Print_Promoted; "&Print")
            {
            }
            group(Category_Lot)
            {
                Caption = 'Lot';

                actionref(Comment_Promoted; "Co&mment")
                {
                }
                actionref(InformationCard_Promoted; "Information Card")
                {
                }
                actionref(LotSpecifications_Promoted; "Lot &Specifications")
                {
                }
            }
            group(Category_Reports)
            {
                Caption = 'Reports';

                actionref(ItemLotsPending_Promoted; "Item Lots Pending")
                {
                }
                actionref(ItemTestResults_Promoted; "Item Test Results")
                {
                }
            }
        }
    }
}
