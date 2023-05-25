page 37002196 "Deduction Comments"
{
    // PR4.00.01
    // P8000269A, VerticalSoft, Jack Reynolds, 05 DEC 05
    //   List style form for deduction comment lines
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 30 JAN 09
    //   Transformed from Form
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    AutoSplitKey = true;
    Caption = 'Deduction Comment Sheet';
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Deduction Comment Line";

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
}

