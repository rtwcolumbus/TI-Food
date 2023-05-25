table 307 "Inventory Buffer"
{
    // PR3.60
    //   Add field for alternate unit of measure
    // 
    // PRW15.00.01
    // P8000591A, VerticalSoft, Don Bresee, 13 MAR 08
    //   Add Quantity (Alt.) to key SumIndexFields
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property

    Caption = 'Inventory Buffer';
    ReplicateData = false;

    fields
    {
        field(37002081; "Quantity (Alt.)"; Decimal)
        {
            Caption = 'Quantity (Alt.)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
        }
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
        field(6500; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            DataClassification = SystemMetadata;
        }
        field(6501; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            DataClassification = SystemMetadata;
        }
        field(6515; "Package No."; Code[50])
        {
            Caption = 'Package No.';
            CaptionClass = '6,1';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Dimension Entry No.", "Location Code", "Bin Code", "Lot No.", "Serial No.")
        {
            Clustered = true;
        }
        key(Key2; "Location Code", "Variant Code", Quantity)
        {
            SumIndexFields = Quantity, "Quantity (Alt.)";
        }
    }

    fieldgroups
    {
    }
}

