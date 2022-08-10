table 11068735 "N108 Expression Reference"
{
    ObsoleteState = Removed;
    ObsoleteReason = 'Functionality was part of BIS';
    ObsoleteTag = 'FOOD-16';
    fields
    {
        field(1; "Expression ID"; Guid)
        {
        }
        field(2; "Parent Line No."; Integer)
        {
        }
        field(4; "Line No."; Integer)
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
    }

    keys
    {
        key(Key1; "Expression ID", "Parent Line No.", "Line No.")
        {
        }
    }
}

