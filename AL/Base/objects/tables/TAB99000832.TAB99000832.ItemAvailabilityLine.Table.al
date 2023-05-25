table 99000832 "Item Availability Line"
{
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status

    Caption = 'Item Availability Line';

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
        }
        field(3; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(5; QuerySource; Integer)
        {
            Caption = 'QuerySource';
        }
        field(37002000; "Quantity Not Available"; Decimal)
        {
            Caption = 'Quantity Not Available';
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(Key1; Name, QuerySource)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

