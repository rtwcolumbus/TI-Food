table 11068780 "N108 Lifecycle Setup"
{
    ObsoleteState = Removed;
    ObsoleteReason = 'Functionality was part of BIS';
    ObsoleteTag = 'FOOD-16';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
        }
        field(100; Alert; Boolean)
        {
        }
        field(101; "Alert Email Address"; Text[80])
        {
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}

