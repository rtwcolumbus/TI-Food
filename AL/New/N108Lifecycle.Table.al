table 11068782 "N108 Lifecycle"
{
    ObsoleteState = Removed;

    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; Description; Text[50])
        {
        }
        field(3; "Type Code"; Code[20])
        {
        }
        field(4; Status; Option)
        {
            OptionMembers = Open,Released;
        }
        field(10; "State Code Failed"; Code[20])
        {
        }
        field(12; "Version Code"; Code[10])
        {
        }
        field(13; "No. of Instances"; Integer)
        {
        }
        field(16; "Table No."; Integer)
        {
        }
        field(17; "Table Name"; Text[30])
        {
        }
        field(24; "User ID"; Code[50])
        {
        }
        field(28; "Date Modified"; Date)
        {
        }
        field(29; "Time Modified"; Time)
        {
        }
        field(30; "Filter ID"; Guid)
        {
        }
        field(31; "Delayed Insert"; Boolean)
        {
        }
        field(38; Comment; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "No.", "Version Code")
        {
        }
    }
}

