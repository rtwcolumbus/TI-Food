page 37002953 "Skip Logic Setup List"
{
    // PRW111.00.01
    // P80037569, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop QC skip logic
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Skip Logic Setup';
    DelayedInsert = true;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Item';
    RefreshOnActivate = true;
    SourceTable = "Skip Logic Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                FreezeColumn = "Activity Class";
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
                    ShowMandatory = true;
                }
                field(Skip; Skip)
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;
                }
                field(Frequency; Frequency)
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;
                }
                field("Rejected Level"; "Rejected Level")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;
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

