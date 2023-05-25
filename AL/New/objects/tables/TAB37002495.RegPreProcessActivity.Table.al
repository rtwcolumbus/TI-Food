table 37002495 "Reg. Pre-Process Activity"
{
    // PRW16.00.06
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Add Pre-Process functionality
    // 
    // PRW17.00.01
    // P8001164, Columbus IT, Jack Reynolds, 28 MAY 13
    //   Enlarge description to 50 characters
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Reg. Pre-Process Activity';
    DrillDownPageID = "Reg. Pre-Process Activity List";
    LookupPageID = "Reg. Pre-Process Activity List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Prod. Order Status"; Option)
        {
            Caption = 'Prod. Order Status';
            OptionCaption = 'Simulated,Planned,Firm Planned,Released,Finished, ';
            OptionMembers = Simulated,Planned,"Firm Planned",Released,Finished," ";
        }
        field(3; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. Order No.';
            Editable = false;
            TableRelation = "Production Order"."No." WHERE(Status = FIELD("Prod. Order Status"));
        }
        field(4; "Prod. Order Line No."; Integer)
        {
            Caption = 'Prod. Order Line No.';
            TableRelation = "Prod. Order Line"."Line No." WHERE(Status = FIELD("Prod. Order Status"),
                                                                 "Prod. Order No." = FIELD("Prod. Order No."));
        }
        field(5; "Prod. Order Comp. Line No."; Integer)
        {
            Caption = 'Prod. Order Comp. Line No.';
            TableRelation = "Prod. Order Component"."Line No." WHERE(Status = FIELD("Prod. Order Status"),
                                                                      "Prod. Order No." = FIELD("Prod. Order No."),
                                                                      "Prod. Order Line No." = FIELD("Prod. Order Line No."));
        }
        field(6; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(7; "Replenishment Area Code"; Code[20])
        {
            Caption = 'Replenishment Area Code';
            TableRelation = "Replenishment Area".Code WHERE("Location Code" = FIELD("Location Code"),
                                                             "Pre-Process Repl. Area" = CONST(true));
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(11; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(12; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(13; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(14; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(18; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            MinValue = 0;
        }
        field(19; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(24; "Quantity Processed"; Decimal)
        {
            Caption = 'Quantity Processed';
            DecimalPlaces = 0 : 5;
        }
        field(25; "Qty. Processed (Base)"; Decimal)
        {
            Caption = 'Qty. Processed (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(31; "To-Bin Code"; Code[20])
        {
            Caption = 'To-Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
        }
        field(32; "From-Bin Code"; Code[20])
        {
            Caption = 'From-Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
        }
        field(40; "Pre-Process Type Code"; Code[10])
        {
            Caption = 'Pre-Process Type Code';
            Editable = false;
            TableRelation = "Pre-Process Type".Code;
        }
        field(41; Blending; Option)
        {
            Caption = 'Blending';
            Editable = false;
            OptionCaption = ' ,Per Order,Per Item';
            OptionMembers = " ","Per Order","Per Item";
        }
        field(42; "Order Specific"; Boolean)
        {
            Caption = 'Order Specific';
            Editable = false;
        }
        field(43; "Auto Complete"; Boolean)
        {
            Caption = 'Auto Complete';
        }
        field(44; "Blending Order Status"; Option)
        {
            Caption = 'Blending Order Status';
            InitValue = " ";
            OptionCaption = 'Simulated,Planned,Firm Planned,Released,Finished, ';
            OptionMembers = Simulated,Planned,"Firm Planned",Released,Finished," ";
        }
        field(45; "Blending Order No."; Code[20])
        {
            Caption = 'Blending Order No.';
            Editable = false;
            TableRelation = "Production Order"."No." WHERE(Status = FIELD("Blending Order Status"));
        }
        field(46; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
        }
        field(47; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(48; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(49; "Prod. Order BOM No."; Code[20])
        {
            CalcFormula = Lookup ("Prod. Order Component"."Production BOM No." WHERE(Status = FIELD("Prod. Order Status"),
                                                                                     "Prod. Order No." = FIELD("Prod. Order No."),
                                                                                     "Prod. Order Line No." = FIELD("Prod. Order Line No."),
                                                                                     "Line No." = FIELD("Prod. Order Comp. Line No.")));
            Caption = 'Prod. Order BOM No.';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "Production BOM Header";
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Prod. Order Status", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Comp. Line No.")
        {
            SumIndexFields = "Quantity Processed";
        }
        key(Key3; "Blending Order Status", "Blending Order No.")
        {
        }
        key(Key4; "Location Code", "Starting Date", "Prod. Order Status", Blending)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        BlendOrder: Record "Production Order";
        LotTrack: Record "Reg. Pre-Process Activity Line";
    begin
        LockTable;

        RegActivityLine.Reset;
        RegActivityLine.SetRange("Activity No.", "No.");
        RegActivityLine.DeleteAll;
    end;

    var
        RegActivityLine: Record "Reg. Pre-Process Activity Line";

    procedure PrintLabels()
    var
        RegActivityLine: Record "Reg. Pre-Process Activity Line";
    begin
        RegActivityLine.Reset;
        RegActivityLine.SetRange("Activity No.", "No.");
        if RegActivityLine.FindSet then
            repeat
                RegActivityLine.PrintLabel();
            until (RegActivityLine.Next = 0);
    end;
}

