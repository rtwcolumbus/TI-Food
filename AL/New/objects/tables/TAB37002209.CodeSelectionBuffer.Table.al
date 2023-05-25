table 37002209 "Code Selection Buffer" // Version: FOODNA
{
    // PRNA7.10
    // P8001252, Columbus IT, Jack Reynolds, 03 JAN 14
    //   Renumbered from 37002004

    Caption = 'Code Selection Buffer';

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(2; "Code"; Code[5])
        {
            Caption = 'Code';
        }
        field(3; Description; Text[30])
        {
            Caption = 'Description';
        }
        field(4; Selected; Boolean)
        {
            Caption = 'Selected';
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

