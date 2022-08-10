table 11068794 "N108 Condition Reference"
{
    ObsoleteState = Removed;

    fields
    {
        field(1; "Reference ID"; Guid)
        {
        }
        field(2; "Line No."; Integer)
        {
        }
        field(5; "Table No."; Integer)
        {
        }
        field(6; "Table Name"; Text[50])
        {
        }
        field(7; "Parent Table No."; Integer)
        {
        }
        field(20; "Relation Mapping ID."; Guid)
        {
        }
        field(30; "Field No."; Integer)
        {
        }
        field(31; "Field Name"; Text[50])
        {
        }
        field(32; Mandatory; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Reference ID", "Line No.")
        {
        }
    }
}

