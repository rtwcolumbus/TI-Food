table 37002570 "Shipped Container Line"
{
    // PR3.70
    //   Add Key - Item No.
    // 
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW18.00.02
    // P8004554, To-Increase, Jack Reynolds, 27 OCT 15
    //   Renamed from Closed Container Line
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Shipped Container Line';
    DataCaptionFields = "Container ID";

    fields
    {
        field(1; "Container ID"; Code[20])
        {
            Caption = 'Container ID';
            Editable = false;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            TableRelation = Item;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(5; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            Editable = false;
        }
        field(6; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            Editable = false;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(7; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            Editable = false;
        }
        field(8; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';
            Editable = false;
        }
        field(9; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            Editable = false;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(10; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            MinValue = 0;
        }
        field(11; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            MinValue = 0;
        }
        field(12; "Quantity (Alt.)"; Decimal)
        {
            Caption = 'Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            MinValue = 0;
        }
        field(13; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(100; "Document Type"; Integer)
        {
            Caption = 'Document Type';
        }
        field(101; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
    }

    keys
    {
        key(Key1; "Container ID", "Document Type", "Document No.", "Line No.")
        {
            SumIndexFields = "Quantity (Base)";
        }
        key(Key2; "Item No.")
        {
        }
    }

    fieldgroups
    {
    }
}

