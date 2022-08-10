table 37002070 "Delivery Trip Pick Line"
{
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   New table - lines (items) for the delivery trip picks
    // 
    // PRW15.00.03
    // P8000630A, VerticalSoft, Don Bresee, 17 SEP 08
    //   Add Whse. logic to delivery trips
    // 
    // P8000644, VerticalSoft, Jack Reynolds, 25 NOV 08
    //   Support for total quantity, weight, volume
    // 
    // PRW16.00.02
    // P8000742, VerticalSoft, Jack Reynolds, 19 NOV 09
    //   Change Bin Code from CODE10 to CODE20
    // 
    // PRW16.00.04
    // P8000892, VerticalSoft, Jack Reynolds, 20 DEC 10
    //   Problem with updating Warehouse Activites from ADC
    // 
    // PRW16.00.05
    // P8000954, Columbus IT, Jack Reynolds, 08 JUL 11
    //   Support for transfer orders on delivery routes and trips
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips

    Caption = 'Delivery Trip Pick Line';

    fields
    {
        field(1; "Pick No."; Integer)
        {
            Caption = 'Pick No.';
            Editable = false;
            TableRelation = "Delivery Trip Pick";
        }
        field(4; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            Editable = false;
        }
        field(5; "Source Subtype"; Option)
        {
            Caption = 'Source Subtype';
            Editable = false;
            OptionCaption = '0,1,2,3,4,5,6,7,8,9';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9";
        }
        field(6; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            Editable = false;
        }
        field(7; "Source Line No."; Integer)
        {
            Caption = 'Source Line No.';
            Editable = false;
        }
        field(8; "Line No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Line No.';
            Editable = false;
        }
        field(9; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;
            TableRelation = Item;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(11; "Quantity to Handle"; Decimal)
        {
            Caption = 'Quantity to Handle';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(12; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            Editable = false;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(13; "Lot No."; Code[20])
        {
            Caption = 'Lot No.';
        }
        field(14; "Quantity Handled"; Decimal)
        {
            Caption = 'Quantity Handled';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(15; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Editable = false;
            TableRelation = Location;
        }
        field(16; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
        }
        field(17; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            Editable = false;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(18; "Alt. Qty. Transaction No."; Integer)
        {
            Caption = 'Alt. Qty. Transaction No.';
            Editable = false;
        }
        field(19; "Quantity Handled (Alt.)"; Decimal)
        {
            CaptionClass = StrSubstNo('37002080,0,15,%1', "Item No.");
            Caption = 'Quantity Handled (Alt.)';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(20; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
        }
        field(21; "Quantity Handled (Base)"; Decimal)
        {
            Caption = 'Quantity Handled (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(22; "Action"; Option)
        {
            Caption = 'Action';
            Editable = false;
            OptionCaption = 'Pick,Return';
            OptionMembers = Pick,Return;
        }
        field(23; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(24; "Short Pick"; Boolean)
        {
            Caption = 'Short Pick';
        }
        field(50; "Delivery Trip No."; Code[20])
        {
            Caption = 'Delivery Trip No.';
            Editable = false;
            TableRelation = "Delivery Trip";
        }
        field(71; "Weight Handled"; Decimal)
        {
            Caption = 'Weight Handled';
            Editable = false;
        }
        field(72; "Volume Handled"; Decimal)
        {
            Caption = 'Volume Handled';
            Editable = false;
        }
        field(101; "Warehouse Source Doc. No."; Code[20])
        {
            Caption = 'Warehouse Source Doc. No.';
            Editable = false;
        }
        field(102; "Warehouse Source Doc. Line No."; Integer)
        {
            Caption = 'Warehouse Source Doc. Line No.';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Pick No.", "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Line No.")
        {
            SumIndexFields = "Quantity Handled", "Quantity Handled (Base)", "Weight Handled", "Volume Handled";
        }
        key(Key2; "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Lot No.", "Bin Code")
        {
            SumIndexFields = Quantity, "Quantity to Handle", "Quantity Handled", "Quantity Handled (Alt.)";
        }
        key(Key3; "Item No.", "Variant Code", "Unit of Measure Code", "Lot No.", "Bin Code")
        {
            SumIndexFields = "Quantity to Handle", "Quantity Handled";
        }
        key(Key4; "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Short Pick")
        {
            SumIndexFields = Quantity;
        }
        key(Key5; "Delivery Trip No.")
        {
            SumIndexFields = "Quantity Handled", "Quantity Handled (Base)", "Weight Handled", "Volume Handled";
        }
    }

    fieldgroups
    {
    }
}

