page 37002007 "Ledger Entry Comments"
{
    // PR4.00.01
    // P8000268B, VerticalSoft, Jack Reynolds, 04 DEC 05
    //   List form to display comments attached to a ledger entry
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 02 FEB 09
    //   Transformed from Form
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    AutoSplitKey = true;
    Caption = 'Comment Sheet';
    DataCaptionExpression = StrSubstNo(Text001, TableCap, "Entry No.");
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Ledger Entry Comment Line";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field(Date; Date)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetUpNewLine;
    end;

    trigger OnOpenPage()
    var
        BaseTable: RecordRef;
    begin
        if "Table ID" <> 0 then begin
            BaseTable.Open("Table ID");
            TableCap := BaseTable.Caption;
        end;
    end;

    var
        TableCap: Text[50];
        Text001: Label '%1 %2';
}

