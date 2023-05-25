table 37002077 "Delivery Trip Order"
{
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   New table - this is main record that links orders to delivery trips
    // 
    // PRW15.00.03
    // P8000644, VerticalSoft, Jack Reynolds, 25 NOV 08
    //   Support for total quantity, weight, volume
    // 
    // PRW16.00.05
    // P8000954, Columbus IT, Jack Reynolds, 08 JUL 11
    //   Support for transfer orders on delivery routes and trips
    // 
    // PRW16.00.06
    // P8001003, Columbus IT, Jack Reynolds, 09 DEC 11
    //   Required unposted orders to be assigned to unposted trips
    // 
    // P8001111, Columbus IT, Don Bresee, 02 NOV 12
    //   Add Promised Delivery Date for sales orders
    // 
    // PRW17.10
    // P8001241, Columbus IT, Jack Reynolds, 12 NOV 13
    //   Fix problem deleting and changing orders on delivery trips
    // 
    // PRW18.00.02
    // P8004554, To-Increase, Jack Reynolds, 27 OCT 15
    //   Add Containers, Weight, Volume
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // PRW19.00.01
    // P8007133, To-Increase, Dayakar Battini, 08 JUN 16
    //  Trip Settlement and Posted Documents visibility
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Delivery Trip Order';

    fields
    {
        field(1; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Editable = false;
            TableRelation = Location;
        }
        field(2; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            Editable = false;
        }
        field(3; "Source Subtype"; Option)
        {
            Caption = 'Source Subtype';
            Editable = false;
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10";
        }
        field(4; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            Editable = false;
        }
        field(5; "Line No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Line No.';
            Editable = false;
        }
        field(6; "Source Document"; Option)
        {
            Caption = 'Source Document';
            Editable = false;
            OptionCaption = ',Sales Order,Purchase Return Order,Transfer Order';
            OptionMembers = ,"Sales Order","Purchase Return Order","Transfer Order";
        }
        field(7; "Document Status"; Option)
        {
            Caption = 'Document Status';
            Editable = false;
            OptionCaption = 'Open,Released,Posted,Deleted';
            OptionMembers = Open,Released,Posted,Deleted;
        }
        field(11; "Destination Type"; Option)
        {
            Caption = 'Destination Type';
            Editable = false;
            OptionCaption = ' ,Customer,Vendor,Location';
            OptionMembers = " ",Customer,Vendor,Location;
        }
        field(12; "Destination No."; Code[20])
        {
            Caption = 'Destination No.';
            Editable = false;
            TableRelation = IF ("Destination Type" = CONST(Customer)) Customer
            ELSE
            IF ("Destination Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Destination Type" = CONST(Location)) Location;
        }
        field(13; "Shipment Date"; Date)
        {
            Caption = 'Shipment Date';
            Editable = false;
        }
        field(14; "Destination Name"; Text[100])
        {
            Caption = 'Destination Name';
            Editable = false;
        }
        field(15; "Order Date"; Date)
        {
            Caption = 'Order Date';
            Editable = false;
        }
        field(16; "Posted Document"; Option)
        {
            Caption = 'Posted Document';
            Editable = false;
            OptionCaption = ',Shipment,Return Shipment,Transfer Shipment';
            OptionMembers = ,Shipment,"Return Shipment","Transfer Shipment";
        }
        field(17; "Posted Document No."; Code[20])
        {
            Caption = 'Posted Document No.';
            Editable = false;
        }
        field(21; "Delivery Route No."; Code[20])
        {
            Caption = 'Delivery Route No.';
            TableRelation = "Delivery Route";
        }
        field(22; "Delivery Trip No."; Code[20])
        {
            Caption = 'Delivery Trip No.';
            TableRelation = IF ("Document Status" = FILTER(Open | Released)) "Delivery Trip" WHERE("Location Code" = FIELD("Location Code"),
                                                                                                "Departure Date" = FIELD("Shipment Date"),
                                                                                                Posted = CONST(false))
            ELSE
            IF ("Document Status" = CONST(Posted)) "Delivery Trip" WHERE("Location Code" = FIELD("Location Code"),
                                                                                                                                                                 "Departure Date" = FIELD("Shipment Date"),
                                                                                                                                                                 Posted = CONST(true));
        }
        field(23; "Delivery Trip Stop No."; Code[20])
        {
            Caption = 'Delivery Trip Stop No.';
        }
        field(31; "Quantity Expected"; Decimal)
        {
            Caption = 'Quantity Expected';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(32; "Weight Expected"; Decimal)
        {
            Caption = 'Weight Expected';
            Editable = false;
        }
        field(33; "Volume Expected"; Decimal)
        {
            Caption = 'Volume Expected';
            Editable = false;
        }
        field(40; "Promised Delivery Date"; Date)
        {
            Caption = 'Promised Delivery Date';
            Editable = false;
        }
        field(41; Containers; Integer)
        {
            Caption = 'Containers';
            Editable = false;
        }
        field(42; Weight; Decimal)
        {
            Caption = 'Weight';
            Editable = false;
        }
        field(43; Volume; Decimal)
        {
            Caption = 'Volume';
            Editable = false;
        }
        field(54; "Posted Documents"; Integer)
        {
            Caption = 'Posted Documents';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Location Code", "Source Type", "Source Subtype", "Source No.", "Line No.")
        {
        }
        key(Key2; "Delivery Trip No.", "Delivery Trip Stop No.")
        {
            SumIndexFields = "Quantity Expected", "Weight Expected", "Volume Expected";
        }
        key(Key3; "Delivery Trip No.", "Posted Document", "Posted Document No.")
        {
        }
    }

    fieldgroups
    {
    }
}

