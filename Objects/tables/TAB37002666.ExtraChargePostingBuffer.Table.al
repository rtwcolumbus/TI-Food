table 37002666 "Extra Charge Posting Buffer"
{
    // PR3.70.05
    // P8000062B, Myers Nissi, Jack Reynolds, 18 JUN 04
    //   Field 10 - Cost To Post - Decimal
    //   Field 11 - Cost To Post (ACY) - Decimal
    // 
    // PR4.00.04
    // P8000403A, VerticalSoft, Jack Reynolds, 05 OCT 06
    //   Dropshipments - add field Sales Line No.
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Extra Charge Posting Buffer';
    ReplicateData = false;

    fields
    {
        field(1; "Extra Charge Code"; Code[10])
        {
            Caption = 'Extra Charge Code';
            DataClassification = SystemMetadata;
        }
        field(2; Charge; Decimal)
        {
            Caption = 'Charge';
            DataClassification = SystemMetadata;
        }
        field(3; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
        }
        field(4; "Invoiced Quantity"; Decimal)
        {
            Caption = 'Invoiced Quantity';
            DataClassification = SystemMetadata;
        }
        field(5; "Recv/Ship Charge"; Decimal)
        {
            Caption = 'Recv/Ship Charge';
            DataClassification = SystemMetadata;
        }
        field(6; "Invoicing Charge"; Decimal)
        {
            Caption = 'Invoicing Charge';
            DataClassification = SystemMetadata;
        }
        field(7; "Recv/Ship Charge (LCY)"; Decimal)
        {
            Caption = 'Recv/Ship Charge (LCY)';
            DataClassification = SystemMetadata;
        }
        field(8; "Invoicing Charge (LCY)"; Decimal)
        {
            Caption = 'Invoicing Charge (LCY)';
            DataClassification = SystemMetadata;
        }
        field(9; "Remaining Amount"; Decimal)
        {
            Caption = 'Remaining Amount';
            DataClassification = SystemMetadata;
        }
        field(10; "Cost To Post"; Decimal)
        {
            Caption = 'Cost To Post';
            DataClassification = SystemMetadata;
            Description = 'PR3.70.05';
        }
        field(11; "Cost To Post (ACY)"; Decimal)
        {
            Caption = 'Cost To Post (ACY)';
            DataClassification = SystemMetadata;
            Description = 'PR3.70.05';
        }
        field(12; "Cost To Post (Expected)"; Decimal)
        {
            Caption = 'Cost To Post (Expected)';
            DataClassification = SystemMetadata;
            Description = 'PR4.00';
        }
        field(13; "Cost To Post (Expected) (ACY)"; Decimal)
        {
            Caption = 'Cost To Post (Expected) (ACY)';
            DataClassification = SystemMetadata;
            Description = 'PR4.00';
        }
        field(14; "Sales Line No."; Decimal)
        {
            Caption = 'Sales Line No.';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Extra Charge Code", "Sales Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

