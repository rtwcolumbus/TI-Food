page 37002704 "Label Worksheet"
{
    // PRW16.00.06
    // P8001047, Columbus IT, Jack Reynolds, 30 MAR 12
    //   Receiving Labels
    // 
    // PRW17.00
    // P8001233, Columbus IT, Jack Reynolds, 24 OCT 13
    //   Support for label worksheet
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Label Worksheet';
    InsertAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Label Worksheet Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group("Document Date")
            {
                Caption = 'Document Date';
                field(DocumentDateBase; DocumentDateBase)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Base';

                    trigger OnValidate()
                    begin
                        CalcDocumentDate;
                    end;
                }
                field(DocumentDateOffset; DocumentDateOffset)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Offset';

                    trigger OnValidate()
                    begin
                        CalcDocumentDate;
                    end;
                }
                field(DocumentDate; DocumentDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Date';

                    trigger OnValidate()
                    begin
                        CalcDocumentDateOffset;
                    end;
                }
            }
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Lot Tracked"; "Lot Tracked")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(DisplayLotNo; DisplayLotNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot No.';
                    Style = Attention;
                    StyleExpr = HighLightLotNo;
                }
                field(SourceDocumentType; SourceDocumentType)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Source Document Type';
                }
                field("Source Document No."; "Source Document No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Control37002015; "Document Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = DocumentDateEditable;
                    ShowCaption = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Label Units)"; "Quantity (Label Units)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Label Unit of Measure Code"; "Label Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("No. of Labels"; "No. of Labels")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Label Code"; "Label Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = true;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Print)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Print';
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    RecCopy: Record "Label Worksheet Line";
                begin
                    RecCopy.Copy(Rec);
                    CurrPage.SetSelectionFilter(Rec);
                    SetFilter("Label Code", '<>%1', '');
                    if FindSet then
                        repeat
                            PrintLabel;
                        until Next = 0;
                    Rec.Copy(RecCopy);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        HighLightLotNo := "Lot Tracked" and ("Lot No." = '');
        DocumentDateEditable := "Document Date Editable";
    end;

    trigger OnOpenPage()
    begin
        DocumentDate := 0D;
        CalcDocumentDate;
    end;

    var
        DocumentDateBase: Option Today,"Work Date";
        DocumentDateOffset: Integer;
        DocumentDate: Date;
        [InDataSet]
        DocumentDateEditable: Boolean;
        Text001: Label 'NOT ASSIGNED';
        [InDataSet]
        HighLightLotNo: Boolean;

    procedure LoadData(var LabelWorksheetLine: Record "Label Worksheet Line")
    begin
        if LabelWorksheetLine.FindSet then
            repeat
                Rec := LabelWorksheetLine;
                Insert;
            until LabelWorksheetLine.Next = 0;
        if FindFirst then;
    end;

    procedure CalcDocumentDate()
    var
        NewDocumentDate: Date;
    begin
        case DocumentDateBase of
            DocumentDateBase::Today:
                NewDocumentDate := Today + DocumentDateOffset;
            DocumentDateBase::"Work Date":
                NewDocumentDate := WorkDate + DocumentDateOffset;
        end;
        if NewDocumentDate <> DocumentDate then begin
            DocumentDate := NewDocumentDate;
            UpdateDocumentDate;
        end;
    end;

    procedure CalcDocumentDateOffset()
    var
        NewDocumentDateOffset: Integer;
    begin
        case DocumentDateBase of
            DocumentDateBase::Today:
                NewDocumentDateOffset := DocumentDate - Today;
            DocumentDateBase::"Work Date":
                NewDocumentDateOffset := DocumentDate - WorkDate;
        end;
        if NewDocumentDateOffset <> DocumentDateOffset then begin
            DocumentDateOffset := NewDocumentDateOffset;
            UpdateDocumentDate;
        end;
    end;

    procedure UpdateDocumentDate()
    var
        CopyRec: Record "Label Worksheet Line";
    begin
        CopyRec.Copy(Rec);
        Reset;
        SetRange("Document Date Editable", true);
        ModifyAll("Document Date", DocumentDate);
        Rec.Copy(CopyRec);
    end;

    procedure DisplayLotNo(): Code[50]
    begin
        if "Lot Tracked" and ("Lot No." = '') then
            exit(Text001)
        else
            exit("Lot No.");
    end;
}

