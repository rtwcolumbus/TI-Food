table 37002060 "Delivery Route"
{
    // PR3.10
    //   Delivery Routing
    // 
    // PR3.70.06
    // P8000079A, Myers Nissi, Jack Reynolds, 16 SEP 04
    //   Change amount and quantity flowfields to sum outstanding amount and quantity
    //   Add fields for day of week
    //   Add backhaul flow field to indicate if pickup load is associated with route
    // 
    // PRW15.00.01
    // P8000547A, VerticalSoft, Jack Reynolds, 02 MAY 08
    //   Added Location and modified to support Delivery Route Schedule table
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Delivery Route';
    DataCaptionFields = "No.", Description;
    LookupPageID = "Delivery Route List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
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
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(10; "Default Driver No."; Code[20])
        {
            Caption = 'Default Driver No.';
            TableRelation = "Delivery Driver";

            trigger OnValidate()
            begin
                DeliveryRouteMgmt.SetRouteDefaultDriver("No.", xRec."Default Driver No.", "Default Driver No.");
                CalcFields("Default Driver Name");
            end;
        }
        field(11; "Default Driver Name"; Text[100])
        {
            CalcFormula = Lookup ("Delivery Driver".Name WHERE("No." = FIELD("Default Driver No.")));
            Caption = 'Default Driver Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "Default Truck ID"; Code[10])
        {
            Caption = 'Default Truck ID';
        }
        field(13; "Default Departure Time"; Time)
        {
            Caption = 'Default Departure Time';
        }
        field(101; Monday; Boolean)
        {
            CalcFormula = Exist ("Delivery Route Schedule" WHERE("Delivery Route No." = FIELD("No."),
                                                                 "Day of Week" = CONST(Monday),
                                                                 Enabled = CONST(true)));
            Caption = 'Monday';
            Editable = false;
            FieldClass = FlowField;
        }
        field(102; Tuesday; Boolean)
        {
            CalcFormula = Exist ("Delivery Route Schedule" WHERE("Delivery Route No." = FIELD("No."),
                                                                 "Day of Week" = CONST(Tuesday),
                                                                 Enabled = CONST(true)));
            Caption = 'Tuesday';
            Editable = false;
            FieldClass = FlowField;
        }
        field(103; Wednesday; Boolean)
        {
            CalcFormula = Exist ("Delivery Route Schedule" WHERE("Delivery Route No." = FIELD("No."),
                                                                 "Day of Week" = CONST(Wednesday),
                                                                 Enabled = CONST(true)));
            Caption = 'Wednesday';
            Editable = false;
            FieldClass = FlowField;
        }
        field(104; Thursday; Boolean)
        {
            CalcFormula = Exist ("Delivery Route Schedule" WHERE("Delivery Route No." = FIELD("No."),
                                                                 "Day of Week" = CONST(Thursday),
                                                                 Enabled = CONST(true)));
            Caption = 'Thursday';
            Editable = false;
            FieldClass = FlowField;
        }
        field(105; Friday; Boolean)
        {
            CalcFormula = Exist ("Delivery Route Schedule" WHERE("Delivery Route No." = FIELD("No."),
                                                                 "Day of Week" = CONST(Friday),
                                                                 Enabled = CONST(true)));
            Caption = 'Friday';
            Editable = false;
            FieldClass = FlowField;
        }
        field(106; Saturday; Boolean)
        {
            CalcFormula = Exist ("Delivery Route Schedule" WHERE("Delivery Route No." = FIELD("No."),
                                                                 "Day of Week" = CONST(Saturday),
                                                                 Enabled = CONST(true)));
            Caption = 'Saturday';
            Editable = false;
            FieldClass = FlowField;
        }
        field(107; Sunday; Boolean)
        {
            CalcFormula = Exist ("Delivery Route Schedule" WHERE("Delivery Route No." = FIELD("No."),
                                                                 "Day of Week" = CONST(Sunday),
                                                                 Enabled = CONST(true)));
            Caption = 'Sunday';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description, "Location Code", "Default Departure Time")
        {
        }
    }

    trigger OnDelete()
    begin
        DeliveryRouteMgmt.DeleteRoute(Rec);
    end;

    trigger OnInsert()
    begin
        DeliveryRouteMgmt.InsertRoute(Rec); // P8000547A
    end;

    var
        DeliveryRouteMgmt: Codeunit "Delivery Route Management";

    procedure SetDefaults(Date: Date)
    var
        DeliveryRouteSched: Record "Delivery Route Schedule";
    begin
        // P8000547A
        DeliveryRouteSched.Get("No.", Date2DWY(Date, 1));
        if DeliveryRouteSched.Enabled then begin
            if DeliveryRouteSched."Default Driver No." <> '' then
                "Default Driver No." := DeliveryRouteSched."Default Driver No.";
            if DeliveryRouteSched."Default Truck ID" <> '' then
                "Default Truck ID" := DeliveryRouteSched."Default Truck ID";
            if DeliveryRouteSched."Default Departure Time" <> 0T then
                "Default Departure Time" := DeliveryRouteSched."Default Departure Time"
        end;
    end;
}

