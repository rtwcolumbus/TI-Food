table 37002486 "Batch Planning Order Detail"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Basis for the planning detail sub-page of the batch planning worksheet
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Batch Planning Order Detail';
    ReplicateData = false;

    fields
    {
        field(1; "Production Date"; Date)
        {
            Caption = 'Production Date';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Equipment Code"; Code[20])
        {
            Caption = 'Equipment Code';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            Editable = false;
            OptionCaption = 'Event,Order';
            OptionMembers = "Event","Order";
        }
        field(4; "Event Code"; Code[10])
        {
            Caption = 'Event Code';
            DataClassification = SystemMetadata;
            Editable = false;

            trigger OnValidate()
            begin
                if PlanningEvent.Get("Event Code") then
                    Description := PlanningEvent.Description
                else
                    Description := '';
            end;
        }
        field(5; "Order Status"; Option)
        {
            Caption = 'Order Status';
            DataClassification = SystemMetadata;
            Editable = false;
            OptionCaption = ' ,,Firm Planned,Released';
            OptionMembers = " ",,"Firm Planned",Released;

            trigger OnValidate()
            begin
                Description := StrSubstNo(Text001, "Order Status");
            end;
        }
        field(6; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(7; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(8; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(11; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
            Editable = false;

            trigger OnValidate()
            begin
                if Item.Get("Item No.") then begin
                    "Item Description" := Item.Description;
                    "Unit of Measure" := Item."Base Unit of Measure";
                end else begin
                    "Item Description" := '';
                    "Unit of Measure" := '';
                end;
            end;
        }
        field(12; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(13; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(14; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(20; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(21; "Duration (Hours)"; Decimal)
        {
            Caption = 'Duration (Hours)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 3;
            MinValue = 0;
        }
        field(22; "Pending Deletion"; Boolean)
        {
            Caption = 'Pending Deletion';
            DataClassification = SystemMetadata;
            MinValue = false;
        }
    }

    keys
    {
        key(Key1; "Production Date", "Equipment Code", Type, "Event Code", "Order Status", "Order No.", "Line No.")
        {
        }
        key(Key2; "Production Date", "Equipment Code", "Item No.")
        {
            SumIndexFields = "Duration (Hours)";
        }
    }

    fieldgroups
    {
    }

    var
        PlanningEvent: Record "Production Planning Event";
        Text001: Label '%1 Order';
        Item: Record Item;
}

