table 37002002 "Extended Text"
{
    Caption = 'Extended Text';

    fields
    {
        field(10; ID; Integer)
        {
            Caption = 'ID';
        }
        field(20; LineNo; Integer)
        {
            Caption = 'LineNo';
        }
        field(30; Spaces; Integer)
        {
            Caption = 'Spaces';
        }
        field(40; NewLine; Boolean)
        {
            Caption = 'NewLine';
        }
        field(50; Line; Text[120])
        {
            Caption = 'Line';
        }
    }

    keys
    {
        key(Key1; ID, LineNo)
        {
        }
    }

    fieldgroups
    {
    }
}

