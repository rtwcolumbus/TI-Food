table 37002480 "Production Yield Report"
{
    // PRW16.00.02
    // P8000764, VerticalSoft, Jack Reynolds, 01 FEB 10
    //   Temporary table for Production Yield & Cost Report
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Production Yield Report';
    ReplicateData = false;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. Order No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Prod. Order Date"; Date)
        {
            Caption = 'Prod. Order Date';
            DataClassification = SystemMetadata;
        }
        field(4; "Category Consumption"; Decimal)
        {
            Caption = 'Category Consumption';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
        }
        field(5; Consumption; Decimal)
        {
            Caption = 'Consumption';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
        }
        field(6; Output; Decimal)
        {
            Caption = 'Output';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
        }
        field(7; "Material Cost"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Material Cost';
            DataClassification = SystemMetadata;
        }
        field(8; "Labor Cost"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Labor Cost';
            DataClassification = SystemMetadata;
        }
        field(9; "Overhead Cost"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Overhead Cost';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Prod. Order No.")
        {
            SumIndexFields = "Category Consumption", Consumption, Output, "Material Cost", "Labor Cost", "Overhead Cost";
        }
        key(Key2; "Item No.", "Prod. Order Date")
        {
        }
    }

    fieldgroups
    {
    }
}

