table 37002201 "Acc. Schedule Unit Data"
{
    // PRW16.00.06
    // P8001019, Columbus IT, Jack Reynolds, 16 JAN 12
    //   Account Schedule - Item Units
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Acc. Schedule Unit Data';
    ReplicateData = false;

    fields
    {
        field(1; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = SystemMetadata;
        }
        field(2; "Beginning Date"; Date)
        {
            Caption = 'Beginning Date';
            DataClassification = SystemMetadata;
        }
        field(3; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = SystemMetadata;
        }
        field(4; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Purchase,Sale,,,,Consumption,Output';
            OptionMembers = Purchase,Sale,,,,Consumption,Output;
        }
        field(5; "Dimension Entry No."; Integer)
        {
            Caption = 'Dimension Entry No.';
            DataClassification = SystemMetadata;
        }
        field(11; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
        }
        field(12; "Quantity (Alt.)"; Decimal)
        {
            Caption = 'Quantity (Alt.)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(Key1; "Item Category Code", "Beginning Date", "Ending Date", "Entry Type", "Dimension Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

