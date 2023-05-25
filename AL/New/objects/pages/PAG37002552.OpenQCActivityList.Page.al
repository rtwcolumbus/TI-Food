page 37002552 "Open Q/C Activity List"
{
    // PRW16.00.20
    // P8000685, VerticalSoft, Jack Reynolds, 29 APR 09
    //   List page for Q/C Headers
    // 
    // PRW16.00.06
    // P8001050, Columbus IT, Jack Reynolds, 30 MAR 12
    //   Enter Q/C results from Purchase and Prod. Order Lines
    // 
    // P8001079, Columbus IT, Jack Reynolds, 15 JUN 12
    //    Support for selective re-tests
    // 
    // P8001117, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Restructure role center to include history section
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW111.00.01
    // P80037502, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Threshhold Results
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples

    ApplicationArea = FOODBasic;
    Caption = 'Open Quality Control Activity List';
    CardPageID = "Quality Control Results Entry";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Quality Control Header";
    SourceTableView = WHERE(Status = FILTER(Pending | Suspended));
    UsageCategory = Lists;

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
                    Editable = Pending;
                }
                field("Schedule Date"; Rec."Schedule Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = Pending;
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
                    Visible = false;
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
        area(processing)
        {
            action("&Add")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Add';
                Image = Add;

                trigger OnAction()
                var
                    LotNoInfo: Record "Lot No. Information";
                    P800QCFns: Codeunit "Process 800 Q/C Functions";
                begin
                    LotNoInfo.Get(Rec."Item No.", Rec."Variant Code", Rec."Lot No.");
                    P800QCFns.AddTest(Rec); // P8001079
                    // P8001050
                    if Rec.MarkedOnly then begin
                        Rec.SetRange("Item No.", LotNoInfo."Item No.");
                        Rec.SetRange("Variant Code", LotNoInfo."Variant Code");
                        Rec.SetRange("Lot No.", LotNoInfo."Lot No.");
                        Rec.MarkedOnly(false);
                        if Rec.FindLast then
                            Rec.Mark(true);
                        Rec.MarkedOnly(true);
                        Rec.SetRange("Item No.");
                        Rec.SetRange("Variant Code");
                        Rec.SetRange("Lot No.");
                    end;
                    // P8001050
                end;
            }
            action("&Remove")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Remove';
                Enabled = Pending;
                Image = Delete;

                trigger OnAction()
                begin
                    Rec.DeleteHeader;
                end;
            }
            action("&Print")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Print Worksheet';
                Image = Print;

                trigger OnAction()
                var
                    QCHeader: Record "Quality Control Header";
                begin
                    QCHeader.Copy(Rec);
                    QCHeader.SetRecFilter;
                    //IF QCHeader.Status = QCHeader.Status::Pending THEN                       // P8001090
                    REPORT.Run(REPORT::"Quality Control Worksheet", true, true, QCHeader)
                    //ELSE                                                                     // P8001090
                    //  REPORT.RUN(REPORT::"Quality Control Test Results",TRUE,TRUE,QCHeader); // P8001090
                end;
            }
            action(QCSampling)
            {
                // P800122712
                ApplicationArea = FOODBasic;
                Caption = 'Quality Control Samples';
                Visible = SampleVisible;
                trigger OnAction()
                begin
                    Process800QCFunctions.RunQCSample(Rec);
                end;
            }
        }
        area(reporting)
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
        area(navigation)
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
            actionref(Add_Promoted; "&Add")
            {
            }
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Remove_Promoted; "&Remove")
                {
                }
                actionref(Print_Promoted; "&Print")
                {
                }
                actionref(QCSampling_Promoted; QCSampling)
                {
                }
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

    trigger OnAfterGetRecord()
    begin
        Pending := Rec.Status = Rec.Status::Pending;
    end;

    trigger OnOpenPage()
    begin
        SampleVisible := Process800QCFunctions.SamplesEnabled(); // P800122712
    end;

    var
        [InDataSet]
        Pending: Boolean;
        SampleVisible: Boolean; // P800122712
        Process800QCFunctions: Codeunit "Process 800 Q/C Functions"; // P800122712

    procedure MarkTestsToShow(var TempLotInfo: Record "Lot No. Information" temporary)
    begin
        // P8001050
        if TempLotInfo.FindSet then
            repeat
                Rec.SetRange("Item No.", TempLotInfo."Item No.");
                Rec.SetRange("Variant Code", TempLotInfo."Variant Code");
                Rec.SetRange("Lot No.", TempLotInfo."Lot No.");
                if Rec.FindSet then
                    repeat
                        Rec.Mark(true);
                    until Rec.Next = 0;
            until TempLotInfo.Next = 0;

        Rec.SetRange("Item No.");
        Rec.SetRange("Variant Code");
        Rec.SetRange("Lot No.");
        Rec.MarkedOnly(true);
        if Rec.FindFirst then;
    end;
}
