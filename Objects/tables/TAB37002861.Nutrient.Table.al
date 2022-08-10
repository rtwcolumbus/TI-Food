table 37002861 Nutrient
{
    // PRW16.00.04
    // P8000868, VerticalSoft, Rick Tweedle, 13 SEP 10
    //   Created for Genesis Enhancements
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    ObsoleteState = Removed;
    ObsoleteReason = 'Functionality moved to FOODESHA Extension App';
    ObsoleteTag = 'FOOD-16';

    fields
    {
        field(1; "Category No."; Integer)
        {
        }
        field(2; "Nutrient No."; Integer)
        {
        }
        field(3; Name; Text[100])
        {
        }
        field(4; Type; Option)
        {
            OptionMembers = Category,Nutrient;
        }
        field(5; "Pane No."; Integer)
        {
        }
        field(6; "Control No."; Integer)
        {
        }
        field(7; "Search Name"; Code[100])
        {
        }
        field(8; Indent; Integer)
        {
        }
        field(9; Visible; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Category No.", "Nutrient No.")
        {
        }
    }
}

