table 37002491 "Intermediate Balancing Buffer"
{
    // PRW16.00.04
    // P8000904, Columbus IT, Jack Reynolds, 03 MAR 11
    //   Temporary, buffer table used during intermediate balancing
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Intermediate Balancing Buffer';
    ReplicateData = false;

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Consumption,Output';
            OptionMembers = Consumption,Output;
        }
        field(2; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. Order No.';
            DataClassification = SystemMetadata;
        }
        field(4; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
            DataClassification = SystemMetadata;
        }
        field(5; "Prod. Order Comp. Line No."; Integer)
        {
            Caption = 'Prod. Order Comp. Line No.';
            DataClassification = SystemMetadata;
        }
        field(6; "Expected Quantity"; Decimal)
        {
            Caption = 'Expected Quantity';
            DataClassification = SystemMetadata;
        }
        field(7; "Posted Quantity"; Decimal)
        {
            Caption = 'Posted Quantity';
            DataClassification = SystemMetadata;
        }
        field(8; "Posted Quantity (Alt.)"; Decimal)
        {
            Caption = 'Posted Quantity (Alt.)';
            DataClassification = SystemMetadata;
        }
        field(9; "Remaining Quantity"; Decimal)
        {
            Caption = 'Remaining Quantity';
            DataClassification = SystemMetadata;
        }
        field(10; "Remaining Quantity (Alt.)"; Decimal)
        {
            Caption = 'Remaining Quantity (Alt.)';
            DataClassification = SystemMetadata;
        }
        field(11; "Journal Quantity"; Decimal)
        {
            Caption = 'Journal Quantity';
            DataClassification = SystemMetadata;
        }
        field(12; "Journal Quantity (Alt.)"; Decimal)
        {
            Caption = 'Journal Quantity (Alt.)';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Type, "Lot No.", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Comp. Line No.")
        {
            SumIndexFields = "Posted Quantity", "Posted Quantity (Alt.)", "Remaining Quantity", "Remaining Quantity (Alt.)", "Journal Quantity", "Journal Quantity (Alt.)";
        }
    }

    fieldgroups
    {
    }
}

