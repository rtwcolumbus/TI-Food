table 37002460 "Production Forecast"
{
    // PR1.20
    //   Rename from Item Forecast
    // 
    // PR2.00.05
    //   Add Variant Code
    //   Change key to include variant code for SIFT calculations
    // 
    // PRW16.00.04
    // P8000869, VerticalSoft, Jack Reynolds, 28 SEP 10
    //   Change DecimalPlaces property for Quantity

    Caption = 'Production Forecast';
    DrillDownPageID = "Production Forecast List";
    LookupPageID = "Production Forecast List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(3; Date; Date)
        {
            Caption = 'Date';
        }
        field(4; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(5; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(6; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            Description = 'PR2.00.05';
            TableRelation = Variant;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Item No.", "Variant Code", Date, "Location Code")
        {
            SumIndexFields = Quantity;
        }
    }

    fieldgroups
    {
    }
}

