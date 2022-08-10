table 11068784 "N108 Lifecycle State"
{
    ObsoleteState = Removed;

    fields
    {
        field(1; "Lifecycle No."; Code[20])
        {
        }
        field(2; "Code"; Code[20])
        {
        }
        field(3; Description; Text[50])
        {
        }
        field(7; Conditions; Boolean)
        {
        }
        field(8; "Actions"; Boolean)
        {
        }
        field(12; "Version Code"; Code[10])
        {
        }
        field(13; "No. of Instances"; Integer)
        {
        }
        field(14; Editable; Boolean)
        {
        }
        field(101; "Approval State"; Option)
        {
            OptionMembers = " ",,Approved,Rejected;
        }
    }

    keys
    {
        key(Key1; "Lifecycle No.", "Version Code", "Code")
        {
        }
    }
}

