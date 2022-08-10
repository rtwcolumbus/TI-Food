table 11068790 "N108 Lifecycle Event Argument"
{
    ObsoleteState = Removed;

    fields
    {
        field(1; "Lifecycle No."; Code[20])
        {
        }
        field(2; "Parent Line No."; Integer)
        {
        }
        field(3; "Line No."; Integer)
        {
        }
        field(4; "State Code"; Code[20])
        {
        }
        field(5; Name; Text[30])
        {
        }
        field(6; Description; Text[50])
        {
        }
        field(7; Type; Integer)
        {
        }
        field(8; Mandatory; Boolean)
        {
        }
        field(9; "Expression ID"; Guid)
        {
        }
        field(10; "Value Text"; Text[100])
        {
        }
        field(12; "Version Code"; Code[10])
        {
        }
        field(13; "Table No."; Integer)
        {
        }
    }

    keys
    {
        key(Key1; "Lifecycle No.", "Version Code", "Parent Line No.", "State Code", "Line No.", Name)
        {
        }
    }
}

