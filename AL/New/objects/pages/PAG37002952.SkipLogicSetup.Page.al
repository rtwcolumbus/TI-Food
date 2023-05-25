page 37002952 "Skip Logic Setup"
{
    // PRW111.00.01
    // P80037569, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop QC skip logic

    Caption = 'Skip Logic Setup';
    Editable = false;
    PageType = ListPart;
    PromotedActionCategories = 'New,Process,Report,Item';
    SourceTable = "Skip Logic Setup";

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
                field("Value Class"; "Value Class")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Activity Class"; "Activity Class")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Level; Level)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Accept; Accept)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Skip; Skip)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Frequency; Frequency)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Rejected Level"; "Rejected Level")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Max Interval"; "Max Interval")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }
}

