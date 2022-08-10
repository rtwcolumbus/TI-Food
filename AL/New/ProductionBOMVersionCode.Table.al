table 37002489 "Production BOM Version Code"
{
    // PRW19.10.01
    // P8007502, To Increase, Jack Reynolds, 28 JUL 16
    //   Correct problem with auto version numbering of BOMs

    Caption = 'Production BOM Version Code';

    fields
    {
        field(1; "Version Code"; Code[20])
        {
            Caption = 'Version Code';
            SQLDataType = Variant;
        }
    }

    keys
    {
        key(Key1; "Version Code")
        {
        }
    }

    fieldgroups
    {
    }
}

