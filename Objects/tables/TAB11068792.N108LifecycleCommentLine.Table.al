table 11068792 "N108 Lifecycle Comment Line"
{
    DataPerCompany = false;
    ObsoleteState = Removed;
    ObsoleteReason = 'Functionality was part of BIS';
    ObsoleteTag = 'FOOD-16';

    fields
    {
        field(2; "Lifecycle Code"; Code[20])
        {
        }
        field(3; "Line No."; Integer)
        {
        }
        field(4; Date; Date)
        {
        }
        field(6; Comment; Text[80])
        {
        }
        field(9; "Version Code"; Code[20])
        {
        }
    }

    keys
    {
        key(Key1; "Lifecycle Code", "Version Code", "Line No.")
        {
        }
    }
}

