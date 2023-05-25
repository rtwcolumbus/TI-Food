table 37002562 "Container Comment Line"
{
    Caption = 'Container Comment Line';

    fields
    {
        field(1; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Open,Closed';
            OptionMembers = Open,Closed;
        }
        field(2; "Container ID"; Code[20])
        {
            Caption = 'Container ID';
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; Date; Date)
        {
            Caption = 'Date';
        }
        field(5; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(6; Comment; Text[80])
        {
            Caption = 'Comment';
        }
    }

    keys
    {
        key(Key1; Status, "Container ID", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

