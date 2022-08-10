page 37002549 "Quality Control"
{
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 13 APR 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001079, Columbus IT, Jack Reynolds, 15 JUN 12
    //    Support for selective re-tests
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW111.00.01
    // P80037659, To-Increase, Jack Reynolds, 25 JUL 18
    //   QC-Additions: Develop average measurement

    Caption = 'Quality Control';
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Reports,Statistics';
    SourceTable = "Quality Control Header";

    layout
    {
        area(content)
        {
            repeater(Control37002003)
            {
                Editable = false;
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
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Test No."; Rec."Test No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(ReTest; Rec."Re-Test")
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
                }
                field("Schedule Date"; Rec."Schedule Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Complete Date"; Rec."Complete Date")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(Lines; "Quality Control Results Sub.")
            {
                ApplicationArea = FOODBasic;
                Editable = false;
                SubPageLink = "Item No." = FIELD("Item No."),
                              "Variant Code" = FIELD("Variant Code"),
                              "Lot No." = FIELD("Lot No."),
                              "Test No." = FIELD("Test No.");
            }
        }
        area(factboxes)
        {
            systempart(Control37002001; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002000; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = true;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Test")
            {
                Caption = '&Test';
                action("&Add")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Add';
                    Image = Add;
                    Promoted = true;
                    PromotedCategory = New;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        P800QCFns: Codeunit "Process 800 Q/C Functions";
                    begin
                        P800QCFns.AddTest(Rec);
                    end;
                }
                action("&Remove")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Remove';
                    Image = Delete;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin
                        Rec.DeleteHeader;
                    end;
                }
                action("&Print")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Print';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        QCHeader: Record "Quality Control Header";
                    begin
                        QCHeader.Copy(Rec);
                        QCHeader.SetRecFilter;
                        case QCHeader.Status of
                            QCHeader.Status::Pending:
                                REPORT.Run(REPORT::"Quality Control Worksheet", true, true, QCHeader);
                            QCHeader.Status::Pass:
                                REPORT.Run(REPORT::"Quality Control Test Results", true, true, QCHeader);
                        end;
                    end;
                }
            }
            group(Statistics)
            {
                Caption = 'Statistics';
                action("Average Measurements")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Average Measurements';
                    Ellipsis = true;
                    Image = AllLines;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        QualityControlSelect: Page "Quality Control-Average";
                    begin
                        // P80037659
                        QualityControlSelect.SetData(Rec);
                        QualityControlSelect.Run;
                    end;
                }
            }
        }
    }
}
