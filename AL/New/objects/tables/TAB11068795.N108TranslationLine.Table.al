table 11068795 "N108 Translation Line"
{
    ObsoleteState = Removed;
    ObsoleteReason = 'Functionality was part of BIS';
    ObsoleteTag = 'FOOD-16';

    fields
    {
        field(1; ID; Guid)
        {
        }
        field(2; "Language Code"; Code[10])
        {
        }
        field(10; Text; Text[250])
        {
        }
        field(11; "Expression ID"; Guid)
        {
        }
        field(12; "Table No."; Integer)
        {
        }
    }

    keys
    {
        key(Key1; ID, "Language Code")
        {
        }
    }

    fieldgroups
    {
    }
}

