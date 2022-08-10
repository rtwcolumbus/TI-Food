table 37002035 "Lot No. Segment"
{
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Lot No. Segment';

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
        }
        field(4; "Segment Code"; Code[10])
        {
            Caption = 'Segment Code';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
        key(Key2; "Sequence No.")
        {
        }
    }

    fieldgroups
    {
    }
}

