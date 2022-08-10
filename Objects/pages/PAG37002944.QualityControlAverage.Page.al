page 37002944 "Quality Control-Average"
{
    // PRW111.00.01
    // P80037659, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop average measurement

    Caption = 'Quality Control-Average';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = ListPlus;
    SourceTable = "Quality Control Header";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control37002003)
            {
                ShowCaption = false;
                field(Select; Select)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        if Select then begin
                            Process800QCFunctions.LoadAverageData(Rec);
                            SelectedTest.Number := "Test No.";
                            SelectedTest.Insert;
                        end else begin
                            Process800QCFunctions.RemoveAverageData(Rec);
                            SelectedTest.Number := "Test No.";
                            SelectedTest.Delete;
                        end;
                        Process800QCFunctions.CalculateAverage;

                        CurrPage.Averages.PAGE.LoadData;
                    end;
                }
                field("Test No."; "Test No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Assigned To"; "Assigned To")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field("Schedule Date"; "Schedule Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Complete Date"; "Complete Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
            }
            part(LinesByActivity; "Quality Control Results Sub.")
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
            part(Averages; "Q/C Average Factbox")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Test Averages';
            }
            part(LinesByTest; "Quality Control Results FB")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Individual Test Results';
                Editable = false;
                Provider = Averages;
                SubPageLink = "Item No." = FIELD("Item No."),
                              "Variant Code" = FIELD("Variant Code"),
                              "Lot No." = FIELD("Lot No."),
                              "Test Code" = FIELD("Test Code");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ShowAll)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Select All';
                Image = AllLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Select all lines.';

                trigger OnAction()
                var
                    QualityControlHeader: Record "Quality Control Header";
                begin
                    QualityControlHeader := Rec;
                    if FindSet then
                        repeat
                            if not Select then begin
                                Process800QCFunctions.LoadAverageData(Rec);
                                SelectedTest.Number := "Test No.";
                                SelectedTest.Insert;
                                Select := true;
                                Modify;
                            end;
                        until Next = 0;
                    Process800QCFunctions.CalculateAverage;
                    Rec := QualityControlHeader;
                    Find;
                    CurrPage.Averages.PAGE.LoadData;
                end;
            }
            action(ShowNone)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Deselect All';
                Image = CancelAllLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Unselect all lines.';

                trigger OnAction()
                begin
                    Process800QCFunctions.ClearAverageData;
                    SelectedTest.DeleteAll;
                    ModifyAll(Select, false);
                    CurrPage.Averages.PAGE.LoadData;
                end;
            }
            action(Print)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Print';
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    QCHeader: Record "Quality Control Header" temporary;
                    QCLine: Record "Quality Control Line" temporary;
                    QCAverageReport: Report "Quality Control Average";
                begin
                    QCHeader.Copy(Rec, true);
                    QCHeader.Reset;
                    QCHeader.SetRange(Select, true);
                    if not QCHeader.FindFirst then
                        Error(NoTestsSelected);
                    QCHeader."Test No." := QCHeader.Count;
                    Process800QCFunctions.GetAverageCalculation(QCLine);

                    QCAverageReport.SetData(QCHeader, QCLine);
                    QCAverageReport.Run;
                end;
            }
            action(UpdateLotSpecs)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Update Lot Specifications';
                Image = LotProperties;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    QCHeader: Record "Quality Control Header" temporary;
                begin
                    QCHeader.Copy(Rec, true);
                    QCHeader.Reset;
                    QCHeader.SetRange(Select, true);
                    if not QCHeader.FindFirst then
                        Error(NoTestsSelected);

                    Process800QCFunctions.UpdateLotSpecsWithAverages;
                    Message(LotSpecsUpdated);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CurrPage.Editable := true;
        CurrPage.Averages.PAGE.SetQCCodeunit(Process800QCFunctions);
        CurrPage.Averages.PAGE.LoadData;
        CurrPage.LinesByTest.PAGE.SetSelectedTest(SelectedTest);
    end;

    var
        SelectedTest: Record "Integer" temporary;
        Process800QCFunctions: Codeunit "Process 800 Q/C Functions";
        UnabletoAverageTxt: Label 'No results are available to average.';
        NoTestsSelected: Label 'No test have been selected.';
        LotSpecsUpdated: Label 'The lot specifications have been updated.';

    procedure SetData(QCHeader: Record "Quality Control Header")
    var
        QCHeader2: Record "Quality Control Header";
    begin
        QCHeader2.Reset;
        QCHeader2.SetRange("Item No.", QCHeader."Item No.");
        QCHeader2.SetRange("Variant Code", QCHeader."Variant Code");
        QCHeader2.SetRange("Lot No.", QCHeader."Lot No.");
        QCHeader2.SetFilter(Status, '%1|%2|%3', QCHeader2.Status::Pass, QCHeader2.Status::Fail, QCHeader2.Status::Suspended);
        if QCHeader2.Count > 1 then begin
            Process800QCFunctions.ClearAverageData;
            if QCHeader2.FindSet then
                repeat
                    Rec.Copy(QCHeader2, false);
                    Rec.Select := true;
                    Rec.Insert;
                    Process800QCFunctions.LoadAverageData(Rec);
                    SelectedTest.Number := "Test No.";
                    SelectedTest.Insert;
                until QCHeader2.Next = 0;
            Process800QCFunctions.CalculateAverage;
            FindFirst;
        end else
            Error(UnabletoAverageTxt);
    end;

    procedure GetData(var QCHeader: Record "Quality Control Header" temporary)
    begin
        Reset;
        SetRange(Select, true);
        if FindSet then
            repeat
                QCHeader.Copy(Rec);
                QCHeader.Insert;
            until Next = 0;
    end;
}

