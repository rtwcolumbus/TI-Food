table 37002496 "Reg. Pre-Process Activity Line"
{
    // PRW16.00.06
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Add Pre-Process functionality
    // 
    // PRW110.0.01
    // P8008451, To-Increase, Jack Reynolds, 22 MAR 17
    //   Label Printing support for NAV Anywhere
    // 
    // PRW110.0.02
    // P80055869, To-Increase, Dayakar Battini, 20 MAR 18
    //   Fix Label Printing User selection Issue
    // 
    // PRW111.00.01
    // P80057829, To-Increase, Dayakar Battini, 27 APR 18
    //   Provide Container handling for non blending pre-process activities
    // 
    // P80062661, To-Increase, Jack Reynolds, 25 JUL 18
    //   SSCC
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Reg. Pre-Process Activity Line';

    fields
    {
        field(1; "Activity No."; Code[20])
        {
            Caption = 'Activity No.';
            TableRelation = "Pre-Process Activity";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; "Item No."; Code[20])
        {
            CalcFormula = Lookup ("Reg. Pre-Process Activity"."Item No." WHERE("No." = FIELD("Activity No.")));
            Caption = 'Item No.';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = Item;
        }
        field(11; "Variant Code"; Code[10])
        {
            CalcFormula = Lookup ("Reg. Pre-Process Activity"."Variant Code" WHERE("No." = FIELD("Activity No.")));
            Caption = 'Variant Code';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(13; "Unit of Measure Code"; Code[10])
        {
            CalcFormula = Lookup ("Reg. Pre-Process Activity"."Unit of Measure Code" WHERE("No." = FIELD("Activity No.")));
            Caption = 'Unit of Measure Code';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            var
                AltQtyMgmt: Codeunit "Alt. Qty. Management";
                UOMMgt: Codeunit "Unit of Measure Management";
            begin
            end;
        }
        field(24; "Quantity Processed"; Decimal)
        {
            Caption = 'Quantity Processed';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(25; "Qty. Processed (Base)"; Decimal)
        {
            Caption = 'Qty. Processed (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(30; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(37002561; "From Container License Plate"; Code[50])
        {
            AccessByPermission = TableData "Container Header" = R;
            Caption = 'From Container License Plate';
        }
        field(37002562; "From Container ID"; Code[20])
        {
            AccessByPermission = TableData "Container Header" = R;
            Caption = 'From Container ID';
        }
        field(37002563; "To Container License Plate"; Code[50])
        {
            AccessByPermission = TableData "Container Header" = R;
            Caption = 'To Container License Plate';
        }
        field(37002564; "To Container ID"; Code[20])
        {
            AccessByPermission = TableData "Container Header" = R;
            Caption = 'To Container ID';
        }
        field(37002565; "Container Master Line No."; Integer)
        {
            AccessByPermission = TableData "Container Header" = R;
            Caption = 'Container Master Line No.';
        }
    }

    keys
    {
        key(Key1; "Activity No.", "Line No.")
        {
        }
        key(Key2; "Activity No.", "Lot No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure PrintLabel()
    var
        RegPreProcActivity: Record "Reg. Pre-Process Activity";
        Item: Record Item;
        Label: Record "Item Case Label";
        UCCBarcode: Record "UCC Barcode Data";
        LabelCode: Code[10];
        LabData: RecordRef;
        LabelMgmt: Codeunit "Label Management";
    begin
        // P8008451 - Change ADCTrans to Transaction and from Integer to Variant
        RegPreProcActivity.Get("Activity No.");

        Item.Get(RegPreProcActivity."Item No.");
        LabelCode := Item.GetLabelCode(3);
        if LabelCode = '' then
            exit;

        UCCBarcode.Validate("Item No.", RegPreProcActivity."Item No.");
        UCCBarcode.Validate("Unit of Measure Code", RegPreProcActivity."Unit of Measure Code");
        if "Lot No." <> '' then
            UCCBarcode.Validate("Lot No.", "Lot No.");
        UCCBarcode.Validate(Quantity, "Quantity Processed");
        //UCCBarcode.SetUPC; // P80055555
        UCCBarcode.CreateUCC('');

        Label."No. Of Copies" := 1;
        Label."Company Name" := CompanyName;
        Label.UCC128 := UCCBarcode."UCC Code";
        Label."UCC128 (Human Readable)" := UCCBarcode."UCC Code (Human Readable)";
        Label."Prod. Order Status" := RegPreProcActivity."Prod. Order Status";
        Label."Prod. Order No." := RegPreProcActivity."Prod. Order No.";
        Label."Prod. Order Line No." := RegPreProcActivity."Prod. Order Line No.";
        Label."Prod. Order Comp. Line No." := RegPreProcActivity."Prod. Order Comp. Line No.";
        Label.Validate("Item No.", RegPreProcActivity."Item No.");
        if RegPreProcActivity."Variant Code" <> '' then
            Label.Validate("Variant Code", RegPreProcActivity."Variant Code");
        Label.Validate("Unit of Measure Code", RegPreProcActivity."Unit of Measure Code");
        Label.Validate(Quantity, "Quantity Processed");
        if "Lot No." <> '' then
            Label.Validate("Lot No.", "Lot No.");

        LabData.GetTable(Label);
        // LabelMgmt.SetUser(UserId);  // P80055869
        LabelMgmt.PrintLabel(Item.GetLabelCode("Label Type"::PreProcess.AsInteger()), RegPreProcActivity."Location Code", LabData); // P8008451
    end;
}

