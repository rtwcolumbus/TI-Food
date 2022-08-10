table 11068693 "N108 Cue Setup"
{
    ObsoleteState = Removed;

    fields
    {
        field(1; "Code"; Code[10])
        {
        }
        field(2; Description; Text[50])
        {
        }
        field(3; Caption; Text[30])
        {
        }
        field(4; "Reference ID"; Guid)
        {
        }
        field(16; "Table No."; Integer)
        {
        }
        field(17; "Table Name"; Text[50])
        {
        }
        field(20; "Page No."; Integer)
        {
        }
        field(21; "Page Name"; Text[30])
        {
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}

