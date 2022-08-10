table 11068732 "N108 Filter Line"
{
    ObsoleteState = Removed;

    fields
    {
        field(1; "Filter ID"; Guid)
        {
        }
        field(2; "Line No."; Integer)
        {
        }
        field(3; "Table No."; Integer)
        {
        }
        field(4; "Field No."; Integer)
        {
        }
        field(5; "Field Name"; Text[30])
        {
        }
        field(6; "Filter"; Text[250])
        {
        }
        field(7; "Table Name"; Text[50])
        {
        }
        field(8; "Filter Group No."; Integer)
        {
        }
        field(30; "Expression ID"; Guid)
        {
        }
        field(43; "Role ID"; Code[20])
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
        field(53; "Filter Expression ID"; Guid)
        {
        }
        field(54; Type; Option)
        {
            OptionMembers = "Filter",Expression,Authorization;
        }
        field(55; FilterExpression; BLOB)
        {
        }
        field(60; "User Message"; Text[250])
        {
        }
        field(61; "User Message Expression ID"; Guid)
        {
        }
    }

    keys
    {
        key(Key1; "Filter ID", "Table No.", "Line No.")
        {
        }
    }
}

