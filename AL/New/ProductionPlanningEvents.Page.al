page 37002530 "Production Planning Events"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   List page for non-production events
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Production Planning Events';
    PageType = List;
    SourceTable = "Production Planning Event";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Duration (Hours)"; "Duration (Hours)")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                }
            }
        }
    }

    actions
    {
    }
}

