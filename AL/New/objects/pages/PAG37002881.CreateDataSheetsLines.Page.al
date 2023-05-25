page 37002881 "Create Data Sheets-Lines"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection

    Caption = 'Create Data Sheets-Lines';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Data Collection Entity";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
                field(Include; Include)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Prod. Order Line No."; "Prod. Order Line No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Line No.';
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    procedure SetSourceTable(var TempLine: Record "Data Collection Entity")
    begin
        Rec.Copy(TempLine, true);
    end;

    procedure GetSourceTable(var TempLine: Record "Data Collection Entity")
    begin
        TempLine.Copy(Rec, true);
    end;
}

