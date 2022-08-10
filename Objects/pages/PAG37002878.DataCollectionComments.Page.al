page 37002878 "Data Collection Comments"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.10.02
    // P8001281, Columbus IT, Jack Reynolds, 06 FEB 14
    //   Fix problem adding new comments

    AutoSplitKey = true;
    Caption = 'Data Collection Comments';
    DataCaptionFields = "Source Key 1", "Source Key 2";
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Data Collection Comment";

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

