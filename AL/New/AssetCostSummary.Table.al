table 37002825 "Asset Cost Summary"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   This table is used to collect data for the asset cost summary report that summarizes asset cost
    //     by total cost and number of orders
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Asset Cost Summary';
    ReplicateData = false;

    fields
    {
        field(1; "Asset No."; Code[20])
        {
            Caption = 'Asset No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Total Cost"; Decimal)
        {
            Caption = 'Total Cost';
            DataClassification = SystemMetadata;
        }
        field(3; "Labor Cost"; Decimal)
        {
            Caption = 'Labor Cost';
            DataClassification = SystemMetadata;
        }
        field(4; "Material Cost"; Decimal)
        {
            Caption = 'Material Cost';
            DataClassification = SystemMetadata;
        }
        field(5; "Contract Cost"; Decimal)
        {
            Caption = 'Contract Cost';
            DataClassification = SystemMetadata;
        }
        field(6; "No. of Orders"; Integer)
        {
            Caption = 'No. of Orders';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Asset No.")
        {
        }
        key(Key2; "Total Cost")
        {
        }
        key(Key3; "No. of Orders")
        {
        }
    }

    fieldgroups
    {
    }
}

