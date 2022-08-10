table 37002487 "Batch Planning - Batch"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Basis for the Batch sub-page of the batch planning pages
    // 
    // PRW16.00.06
    // P8001107, Columbus IT, Don Bresee, 19 OCT 12
    //   Add Minimum Equipment Qty. fields, add logic to use new field to adjust min and max order qtys.
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

    Caption = 'Batch Planning - Batch';
    ReplicateData = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Equipment Code"; Code[20])
        {
            Caption = 'Equipment Code';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; "Equipment Description"; Text[100])
        {
            Caption = 'Equipment Description';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(4; Summary; Boolean)
        {
            Caption = 'Summary';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(5; Highlight; Boolean)
        {
            Caption = 'Highlight';
            DataClassification = SystemMetadata;
        }
        field(10; "Capacity (Base)"; Decimal)
        {
            Caption = 'Capacity (Base)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(11; Capacity; Decimal)
        {
            Caption = 'Capacity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(12; "Capacity UOM"; Code[10])
        {
            Caption = 'Capacity UOM';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(13; "Minimum Order Quantity"; Decimal)
        {
            Caption = 'Minimum Order Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(14; "Maximum Order Quantity"; Decimal)
        {
            Caption = 'Maximum Order Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(15; "Order Multiple"; Decimal)
        {
            Caption = 'Order Multiple';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(16; "Fixed Time"; Decimal)
        {
            Caption = 'Fixed Time';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(17; "Variable Time"; Decimal)
        {
            Caption = 'Variable Time';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(20; Include; Boolean)
        {
            Caption = 'Include';
            DataClassification = SystemMetadata;
        }
        field(21; Sequence; Integer)
        {
            Caption = 'Sequence';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(22; "Batch Time (Hours)"; Decimal)
        {
            Caption = 'Batch Time (Hours)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(23; "Other Time (Hours)"; Decimal)
        {
            Caption = 'Other Time (Hours)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(24; Batches; Integer)
        {
            Caption = 'Batches';
            DataClassification = SystemMetadata;
            MinValue = 0;
        }
        field(25; "Batches Remaining"; Integer)
        {
            Caption = 'Batches Remaining';
            DataClassification = SystemMetadata;
        }
        field(31; "Batch No."; Integer)
        {
            Caption = 'Batch No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(32; "Batch Size"; Decimal)
        {
            Caption = 'Batch Size';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(33; "Equipment Entry No."; Integer)
        {
            Caption = 'Equipment Entry No.';
            DataClassification = SystemMetadata;
        }
        field(34; "Batch No. Link"; Integer)
        {
            Caption = 'Batch No. Link';
            DataClassification = SystemMetadata;
        }
        field(35; "Remaining Batch Quantity"; Decimal)
        {
            Caption = 'Remaining Batch Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(36; "Production Time (Hours)"; Decimal)
        {
            Caption = 'Production Time (Hours)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(41; "Order Status"; Integer)
        {
            Caption = 'Order Status';
            DataClassification = SystemMetadata;
        }
        field(42; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            DataClassification = SystemMetadata;
        }
        // field(101; "Item Filter"; Code[20])
        // {
        //     Caption = 'Item Filter';
        //     FieldClass = FlowFilter;
        // }
        // field(102; "Variant Filter"; Code[10])
        // {
        //     Caption = 'Variant Filter';
        //     FieldClass = FlowFilter;
        // }
        field(110; "Minimum Equipment Qty."; Decimal)
        {
            Caption = 'Minimum Equipment Qty.';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(111; "Minimum Equipment Qty. (Base)"; Decimal)
        {
            Caption = 'Minimum Equipment Qty. (Base)';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            SumIndexFields = "Batch Size";
        }
        key(Key2; Sequence, "Batch No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure ConvertCapacityUOM(Item: Record Item)
    var
        ItemUOM: Record "Item Unit of Measure";
    begin
        if ItemUOM.Get(Item."No.", "Capacity UOM") then begin
            // P8001107
            "Minimum Equipment Qty. (Base)" := Round("Minimum Equipment Qty." * ItemUOM."Qty. per Unit of Measure", 0.00001);
            if ("Minimum Equipment Qty. (Base)" > "Minimum Order Quantity") then
                "Minimum Order Quantity" := "Minimum Equipment Qty. (Base)";
            if ("Minimum Equipment Qty. (Base)" > "Maximum Order Quantity") then
                "Maximum Order Quantity" := "Minimum Equipment Qty. (Base)";
            // P8001107
            "Capacity (Base)" := Round(Capacity * ItemUOM."Qty. per Unit of Measure", 0.00001);
            if "Capacity (Base)" < "Minimum Order Quantity" then
                "Minimum Order Quantity" := "Capacity (Base)";
            if "Capacity (Base)" < "Maximum Order Quantity" then
                "Maximum Order Quantity" := "Capacity (Base)";
        end else begin                          // P8001107
            "Minimum Equipment Qty. (Base)" := 0; // P8001107
            "Capacity (Base)" := 0;
        end;                                    // P8001107

        "Minimum Order Quantity" := "Order Multiple" * Round("Minimum Order Quantity" / "Order Multiple", 1, '>');
        if ("Minimum Order Quantity" > "Maximum Order Quantity") then // P8001107
            "Minimum Order Quantity" := "Maximum Order Quantity"        // P8001107
        else                                                          // P8001107
            "Maximum Order Quantity" := "Order Multiple" * Round("Maximum Order Quantity" / "Order Multiple", 1, '<');
        // IF "Maximum Order Quantity" < "Minimum Order Quantity" THEN // P8001107
        //   "Maximum Order Quantity" := "Minimum Order Quantity";     // P8001107
    end;

    procedure SetBatchSize(QtyNeeded: Decimal): Decimal
    begin
        if QtyNeeded < "Minimum Order Quantity" then
            exit("Minimum Order Quantity")
        else
            if "Maximum Order Quantity" < QtyNeeded then
                exit("Maximum Order Quantity")
            else
                exit("Minimum Order Quantity" + "Order Multiple" * Round((QtyNeeded - "Minimum Order Quantity") / "Order Multiple", 1, '>'));
    end;
}

