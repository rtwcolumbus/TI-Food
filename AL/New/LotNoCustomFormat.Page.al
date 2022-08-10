page 37002026 "Lot No. Custom Format"
{
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats

    Caption = 'Lot No. Custom Format';
    PageType = Card;
    SourceTable = "Lot No. Custom Format";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Sample)
            {
                Caption = 'Sample';
                field(Date; LotNoData.Date)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Date';
                }
                field(DocumentNo; LotNoData."Document No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Document No.';
                }
                field(Location; LotNoData."Location Segment")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Segment';
                }
                field(Equipment; LotNoData."Equipment Segment")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Equipment Segment';
                }
                field(Shift; LotNoData."Shift Segment")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Shift Segment';
                }
                field(LotNo; SampleLotNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot No.';
                    Editable = false;
                    Importance = Promoted;
                }
            }
            part(Segments; "Lot No. Custom Format Lines")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Segments';
                SubPageLink = "Custom Format Code" = FIELD(Code);
            }
        }
        area(factboxes)
        {
            systempart(Control37002006; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002005; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        LotNoData.SetSampleData;
    end;

    var
        LotNoData: Record "Lot No. Data";
        CustomFormat: Codeunit "Lot No. Custom Format";
        Text001: Label '***ERROR***';

    procedure SampleLotNo() LotNo: Code[40]
    begin
        LotNoData."Assignment Method" := LotNoData."Assignment Method"::Custom;
        LotNoData."Source Code" := Code;
        if LotNoData.OKToAssign then begin
            LotNo := LotNoData.AssignLotNo;
            LotNo := CopyStr(LotNo, 1, 20);
        end else
            exit(Text001);
    end;
}

