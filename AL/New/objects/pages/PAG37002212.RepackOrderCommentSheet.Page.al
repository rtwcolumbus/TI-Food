page 37002212 "Repack Order Comment Sheet"
{
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 23 JUL 07
    //   Adapted from Sales Order Comment Sheet
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 30 JAN 09
    //   Transformed from Form
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    AutoSplitKey = true;
    Caption = 'Comment Sheet';
    DataCaptionFields = "Repack Order No.";
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Repack Order Comment Line";

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
        SetupNewLine;
    end;
}

