table 37002079 "Pick Container Line"
{
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   New table - records the contents of the picking containers
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips

    Caption = 'Pick Container Line';

    fields
    {
        field(1; "Pick Container Header No."; Integer)
        {
            Caption = 'Pick Container Header No.';
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(3; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(4; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(5; "Lot No."; Code[20])
        {
            Caption = 'Lot No.';
        }
        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(Key1; "Pick Container Header No.", "Item No.", "Variant Code", "Unit of Measure", "Lot No.")
        {
        }
    }

    fieldgroups
    {
    }
}

