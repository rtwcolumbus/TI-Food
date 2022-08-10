table 11068785 "N108 Lifecycle Condition"
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
        field(4; Type; Option)
        {
            OptionMembers = "Filter",Expression,Authorization;
        }
        field(5; "State Code"; Code[20])
        {
        }
        field(12; "Version Code"; Code[10])
        {
        }
        field(20; "Table No."; Integer)
        {
        }
        field(21; "Field No."; Integer)
        {
        }
        field(22; "Field Name"; Text[50])
        {
        }
        field(30; "Expression ID"; Guid)
        {
        }
        field(40; "Condition Text"; Text[250])
        {
        }
        field(41; "Condition Expression ID"; Guid)
        {
        }
        field(43; "Role ID"; Code[20])
        {
        }
        field(44; "Change Log No."; Code[20])
        {
        }
        field(50; Status; Option)
        {
            OptionMembers = Enabled,Disabled;
        }
        field(51; "Product No."; Code[10])
        {
        }
        field(52; "Record ID"; Guid)
        {
        }
        field(53; "User Message"; Text[250])
        {
        }
        field(54; "User Message Expression ID"; Guid)
        {
        }
    }

    keys
    {
        key(Key1; "Lifecycle No.", "Version Code", "Parent Line No.", "State Code", "Line No.")
        {
        }
    }
}

