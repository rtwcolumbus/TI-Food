table 37002668 "Extra Charge Vendor Buffer"
{
    // PR4.00.06
    // P8000487A, VerticalSoft, Jack Reynolds, 12 JUN 07
    //   Multi-currency support for extra charges
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Extra Charge Vendor Buffer';
    ReplicateData = false;

    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Extra Charge Code"; Code[10])
        {
            Caption = 'Extra Charge Code';
            DataClassification = SystemMetadata;
        }
        field(3; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = SystemMetadata;
        }
        field(4; Charge; Decimal)
        {
            Caption = 'Charge';
            DataClassification = SystemMetadata;
        }
        field(5; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Vendor No.", "Currency Code", "Extra Charge Code", "Account No.")
        {
        }
    }

    fieldgroups
    {
    }
}

