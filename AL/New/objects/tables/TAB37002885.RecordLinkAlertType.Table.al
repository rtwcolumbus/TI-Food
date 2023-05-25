table 37002885 "Record Link Alert Type"
{

    fields
    {
        field(1; "Link ID"; Integer)
        {
        }
        field(2; "Alert Type"; Option)
        {
            Caption = 'Alert Type';
            OptionCaption = ' ,Level 1,Level 2,Missing';
            OptionMembers = " ","Level 1","Level 2",Missing;
        }
    }

    keys
    {
        key(Key1; "Link ID")
        {
        }
    }

    fieldgroups
    {
    }
}

