table 37002023 "Item Tracking Buffer"
{
    // PR3.60
    //   Add field for alternate unit of measure
    // 
    // PR4.00.04
    // P8000367A, VerticalSoft, Jack Reynolds, 29 AUG 06
    //   Change Bin Code relation is to new Bin table
    // 
    // PRW16.00.04
    // P8000910, Columbus IT, Jack Reynolds, 28 FEB 11
    //   Change Bin Code to Code20
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Item Tracking Buffer';
    ReplicateData = false;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
            TableRelation = Item;
        }
        field(4; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = SystemMetadata;
            TableRelation = Location;
        }
        field(5; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
        }
        field(6; "Dimension Entry No."; Integer)
        {
            Caption = 'Dimension Entry No.';
            DataClassification = SystemMetadata;
        }
        field(5400; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = SystemMetadata;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(5401; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            DataClassification = SystemMetadata;
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
        }
        field(37002020; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            DataClassification = SystemMetadata;
        }
        field(37002021; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            DataClassification = SystemMetadata;
        }
        field(37002081; "Quantity (Alt.)"; Decimal)
        {
            Caption = 'Quantity (Alt.)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Dimension Entry No.", "Location Code", "Bin Code", "Lot No.", "Serial No.")
        {
        }
    }

    fieldgroups
    {
    }
}

