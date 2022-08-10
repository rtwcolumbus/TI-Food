table 5803 "Item Journal Buffer"
{
    // PR3.70.06
    // P8000106A, Myers Nissi, Jack Reynolds, 02 SEP 04
    //   Modify to support alternate quantities in revaluation journal
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property

    Caption = 'Item Journal Buffer';
    ReplicateData = false;

    fields
    {
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
            TableRelation = Item;
        }
        field(8; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = SystemMetadata;
            TableRelation = Location;
        }
        field(12; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = SystemMetadata;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(5802; "Inventory Value (Calculated)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Inventory Value (Calculated)';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(37002081; "Quantity (Alt.)"; Decimal)
        {
            Caption = 'Quantity (Alt.)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Description = 'PR3.70.06';
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Item No.", "Location Code", "Variant Code")
        {
        }
        key(Key3; "Item No.", "Variant Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Item: Record Item;

    local procedure GetItem()
    begin
        // P8000106A
        if (Item."No." <> "Item No.") then
            Item.Get("Item No.");
    end;

    procedure GetCostingQty(): Decimal
    begin
        // P8000106A
        GetItem;
        if Item.CostInAlternateUnits() then
            exit("Quantity (Alt.)");
        exit(Quantity);
    end;
}

