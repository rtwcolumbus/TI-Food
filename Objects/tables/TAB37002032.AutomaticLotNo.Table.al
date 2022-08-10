table 37002032 "Automatic Lot No."
{
    // PR4.00
    // P8000250B, Myers Nissi, Jack Reynolds, 16 OCT 05
    //   Table of root lot numbers and last suffix used
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Automatic Lot No.';

    fields
    {
        field(1; Root; Code[50])
        {
            Caption = 'Root';
        }
        field(2; Suffix; Integer)
        {
            Caption = 'Suffix';
        }
    }

    keys
    {
        key(Key1; Root)
        {
        }
    }

    fieldgroups
    {
    }
}

