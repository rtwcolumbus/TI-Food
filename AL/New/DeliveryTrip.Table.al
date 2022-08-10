table 37002067 "Delivery Trip"
{
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   New table contains data for delivery trips
    // 
    // PRW15.00.03
    // P8000630A, VerticalSoft, Don Bresee, 17 SEP 08
    //   Add Whse. logic to delivery trips
    // 
    // P8000644, VerticalSoft, Jack Reynolds, 25 NOV 08
    //   Support for total quantity, weight, volume
    // 
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW16.00.06
    // P8001111, Columbus IT, Don Bresee, 02 NOV 12
    //   Add new fields for pickup date/time, load ID, seal, and carrier
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Delivery Trip';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
        }
        field(4; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(5; "Departure Date"; Date)
        {
            Caption = 'Departure Date';
        }
        field(9; "Delivery Route No."; Code[20])
        {
            Caption = 'Delivery Route No.';
            TableRelation = "Delivery Route";
        }
        field(10; "Driver No."; Code[20])
        {
            Caption = 'Driver No.';
            TableRelation = "Delivery Driver";
        }
        field(11; "Driver Name"; Text[100])
        {
            CalcFormula = Lookup ("Delivery Driver".Name WHERE("No." = FIELD("Driver No.")));
            Caption = 'Driver Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "Truck ID"; Code[10])
        {
            Caption = 'Truck ID';
        }
        field(13; "Departure Time"; Time)
        {
            Caption = 'Departure Time';
        }
        field(14; "No. of Orders"; Integer)
        {
            CalcFormula = Count ("Delivery Trip Order" WHERE("Delivery Trip No." = FIELD("No.")));
            Caption = 'No. of Orders';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "No. of Picks"; Integer)
        {
            CalcFormula = Count ("Delivery Trip Pick" WHERE("Delivery Trip No." = FIELD("No.")));
            Caption = 'No. of Picks';
            Editable = false;
            FieldClass = FlowField;
        }
        field(17; "No. of Containers"; Integer)
        {
            CalcFormula = Count ("Pick Container Header" WHERE("Delivery Trip No." = FIELD("No.")));
            Caption = 'No. of Containers';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(22; "Warehouse Shipment No."; Code[20])
        {
            Caption = 'Warehouse Shipment No.';
        }
        field(23; "Loading Dock No."; Code[20])
        {
            Caption = 'Loading Dock No.';
            TableRelation = "N138 Loading Dock" WHERE("Location Code" = FIELD("Location Code"));
        }
        field(24; Posted; Boolean)
        {
            Caption = 'Posted';
            Editable = false;
        }
        field(25; "No. of Orders (Released)"; Integer)
        {
            CalcFormula = Count ("Delivery Trip Order" WHERE("Delivery Trip No." = FIELD("No."),
                                                             "Document Status" = CONST(Released)));
            Caption = 'No. of Orders (Released)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(26; "Pickup Load No."; Code[20])
        {
            Caption = 'Pickup Load No.';
            TableRelation = "Pickup Load Header" WHERE("Location Code" = FIELD("Location Code"),
                                                        "Pickup Date" = FIELD("Departure Date"),
                                                        "Truck Type" = CONST(Company));
        }
        field(27; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
        }
        field(31; "Quantity Handled"; Decimal)
        {
            CalcFormula = Sum ("Delivery Trip Pick Line"."Quantity Handled" WHERE("Delivery Trip No." = FIELD("No.")));
            Caption = 'Quantity Handled';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(32; "Weight Handled"; Decimal)
        {
            CalcFormula = Sum ("Delivery Trip Pick Line"."Weight Handled" WHERE("Delivery Trip No." = FIELD("No.")));
            Caption = 'Weight Handled';
            Editable = false;
            FieldClass = FlowField;
        }
        field(33; "Volume Handled"; Decimal)
        {
            CalcFormula = Sum ("Delivery Trip Pick Line"."Volume Handled" WHERE("Delivery Trip No." = FIELD("No.")));
            Caption = 'Volume Handled';
            Editable = false;
            FieldClass = FlowField;
        }
        field(34; "Quantity Expected"; Decimal)
        {
            CalcFormula = Sum ("Delivery Trip Order"."Quantity Expected" WHERE("Delivery Trip No." = FIELD("No.")));
            Caption = 'Quantity Expected';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(35; "Weight Expected"; Decimal)
        {
            CalcFormula = Sum ("Delivery Trip Order"."Weight Expected" WHERE("Delivery Trip No." = FIELD("No.")));
            Caption = 'Weight Expected';
            Editable = false;
            FieldClass = FlowField;
        }
        field(36; "Volume Expected"; Decimal)
        {
            CalcFormula = Sum ("Delivery Trip Order"."Volume Expected" WHERE("Delivery Trip No." = FIELD("No.")));
            Caption = 'Volume Expected';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; "Pickup Appointment Date"; Date)
        {
            Caption = 'Pickup Appointment Date';
        }
        field(41; "Pickup Appointment Time"; Time)
        {
            Caption = 'Pickup Appointment Time';
        }
        field(42; "Load ID No."; Code[20])
        {
            Caption = 'Load ID No.';
        }
        field(43; "Seal No."; Code[20])
        {
            Caption = 'Seal No.';
        }
        field(44; "Contract Carrier Vendor No."; Code[20])
        {
            Caption = 'Contract Carrier Vendor No.';
            TableRelation = Vendor;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Location Code", "Departure Date", "Departure Time")
        {
        }
    }

    fieldgroups
    {
    }
}

