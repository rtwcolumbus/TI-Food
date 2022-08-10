table 37002812 "Work Order Material"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Planned stock and non-stock material for work orders
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 09 AUG 07
    //   Expand Vendor Name to TEXT50
    // 
    // PRW15.00.01
    // P8000517A, VerticalSoft, Jack Reynolds, 13 SEP 07
    //   Get part number and description from spares list for non-stock items
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW119.0
    // P800133109, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 19.0 - Qty. Rounding Precision

    Caption = 'Work Order Material';
    DrillDownPageID = "Work Order Materials";
    LookupPageID = "Work Order Materials";

    fields
    {
        field(1; "Work Order No."; Code[20])
        {
            Caption = 'Work Order No.';
            TableRelation = "Work Order";
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            InitValue = Stock;
            OptionCaption = ',Stock,NonStock';
            OptionMembers = ,Stock,NonStock;

            trigger OnValidate()
            begin
                if CurrFieldNo <> 0 then
                    if EntriesExist(xRec) then
                        Error(Text001, FieldCaption(Type));

                if Type <> xRec.Type then begin
                    Init;
                    "Item No." := '';
                end;
            end;
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = IF (Type = CONST(Stock)) Item;

            trigger OnValidate()
            var
                WorkOrder: Record "Work Order";
                Asset: Record Asset;
                AssetSpare: Record "Asset Spare Part";
            begin
                if CurrFieldNo <> 0 then
                    if EntriesExist(xRec) then
                        Error(Text001, FieldCaption("Item No."));

                if "Item No." <> xRec."Item No." then
                    Init;

                case Type of
                    Type::Stock:
                        begin
                            Item.Get("Item No.");
                            "Part No." := Item."Part No.";
                            Description := Item.Description;
                            Validate("Unit of Measure Code", Item."Base Unit of Measure");
                            Validate("Unit Cost", Item."Unit Cost");
                        end;

                    Type::NonStock:
                        begin
                            // P8000517A
                            WorkOrder.Get("Work Order No.");
                            Asset.Get(WorkOrder."Asset No.");
                            if Asset.GetSpare(Type, "Item No.", AssetSpare) then begin
                                "Part No." := AssetSpare."Part No.";
                                Description := AssetSpare.Description;
                            end else
                                // P8000517A
                                "Part No." := "Item No.";
                            "Qty. per Unit of Measure" := 1;
                        end;
                end;
            end;
        }
        field(4; "Part No."; Code[20])
        {
            Caption = 'Part No.';
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(6; Completed; Boolean)
        {
            Caption = 'Completed';
        }
        field(7; "Required Date"; Date)
        {
            Caption = 'Required Date';
        }
        field(8; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(9; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(10; "Vendor Name"; Text[100])
        {
            CalcFormula = Lookup (Vendor.Name WHERE("No." = FIELD("Vendor No.")));
            Caption = 'Vendor Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Planned Quantity"; Decimal)
        {
            Caption = 'Planned Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                // P800133109
                "Planned Quantity" := UOMMgt.RoundAndValidateQty("Planned Quantity", "Qty. Rounding Precision", FieldCaption("Planned Quantity"));
                "Planned Quantity (Base)" := CalcBaseQty("Planned Quantity", FieldCaption("Planned Quantity"), FieldCaption("Planned Quantity (Base)"));
                // P800133109
                Validate("Planned Cost");

                CalcQuantityRemaining;
            end;
        }
        field(12; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF (Type = CONST(Stock)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."))
            ELSE
            IF (Type = CONST(NonStock)) "Unit of Measure";

            trigger OnValidate()
            begin
                case Type of
                    Type::Stock:
                        begin
                            GLSetup.Get;
                            ItemUOM.Get("Item No.", "Unit of Measure Code");
                            "Unit Cost" := "Unit Cost" / "Qty. per Unit of Measure";
                            "Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
                            UOMMgt.GetQtyRoundingPrecision("Item No.", "Unit of Measure Code", "Qty. Rounding Precision", "Qty. Rounding Precision (Base)"); // P800133109
                            Validate("Unit Cost", Round("Unit Cost" * "Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision"));
                            "Planned Quantity (Base)" := Round("Planned Quantity" * "Qty. per Unit of Measure", 0.00001);
                            CalcQuantityRemaining;
                        end;
                end;
            end;
        }
        field(13; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            InitValue = 1;
        }
        field(14; "Planned Quantity (Base)"; Decimal)
        {
            Caption = 'Planned Quantity (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(15; "Planned Quantity Rem. (Base)"; Decimal)
        {
            Caption = 'Planned Quantity Rem. (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(16; "Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost';

            trigger OnValidate()
            begin
                Validate("Planned Cost");
            end;
        }
        field(17; "Planned Cost"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Planned Cost';
            Editable = false;

            trigger OnValidate()
            begin
                "Planned Cost" := Round("Planned Quantity" * "Unit Cost", GLSetup."Amount Rounding Precision");
            end;
        }
        field(18; "Actual Quantity (Base)"; Decimal)
        {
            CalcFormula = Sum ("Maintenance Ledger"."Quantity (Base)" WHERE("Work Order No." = FIELD("Work Order No."),
                                                                            "Entry Type" = FIELD(Type),
                                                                            "Item No." = FIELD("Item No.")));
            Caption = 'Actual Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(19; "Actual Cost"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum ("Maintenance Ledger"."Cost Amount" WHERE("Work Order No." = FIELD("Work Order No."),
                                                                        "Entry Type" = FIELD(Type),
                                                                        "Item No." = FIELD("Item No.")));
            Caption = 'Actual Cost';
            Editable = false;
            FieldClass = FlowField;
        }
        // P800133109
        field(20; "Qty. Rounding Precision"; Decimal)
        {
            Caption = 'Qty. Rounding Precision';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        // P800133109
        field(21; "Qty. Rounding Precision (Base)"; Decimal)
        {
            Caption = 'Qty. Rounding Precision (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Work Order No.", Type, "Item No.")
        {
            SumIndexFields = "Planned Cost";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if EntriesExist(Rec) then
            Error(Text002);
    end;

    trigger OnInsert()
    begin
        GetWorkOrder;
        if WorkOrder."Scheduled Date" <> 0D then
            "Required Date" := WorkOrder."Scheduled Date"
        else
            "Required Date" := WorkOrder."Due Date";
        "Location Code" := WorkOrder."Location Code";
    end;

    var
        Text001: Label 'You cannot change %1 because there are one or more ledger entries for this material.';
        Text002: Label 'You cannot delete this material because there are one or more ledger entries for this material.';
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        GLSetup: Record "General Ledger Setup";
        WorkOrder: Record "Work Order";
        UOMMgt: Codeunit "Unit of Measure Management";

    procedure EntriesExist(WOMaterial: Record "Work Order Material"): Boolean
    var
        MaintLedger: Record "Maintenance Ledger";
    begin
        with WOMaterial do begin
            MaintLedger.SetCurrentKey("Work Order No.", "Entry Type", "Item No.");
            MaintLedger.SetRange("Work Order No.", "Work Order No.");
            case Type of
                Type::Stock:
                    MaintLedger.SetRange("Entry Type", MaintLedger."Entry Type"::"Material-Stock");
                Type::NonStock:
                    MaintLedger.SetRange("Entry Type", MaintLedger."Entry Type"::"Material-NonStock");
            end;
            MaintLedger.SetRange("Item No.", "Item No.");
            exit(MaintLedger.FindFirst);
        end;
    end;

    procedure LookupItem(var Text: Text[1024]): Boolean
    var
        WorkOrder: Record "Work Order";
        Asset: Record Asset;
    begin
        WorkOrder.Get("Work Order No.");
        Asset.Get(WorkOrder."Asset No.");
        exit(Asset.LookupItem(Type, Text));
    end;

    procedure GetWorkOrder()
    begin
        if "Work Order No." <> WorkOrder."No." then
            WorkOrder.Get("Work Order No.");
    end;

    local procedure CalcBaseQty(Qty: Decimal; FromFieldName: Text; ToFieldName: Text): Decimal
    begin
        // P800133109
        exit(UOMMgt.CalcBaseQty(
            "Item No.", '', "Unit of Measure Code", Qty, "Qty. per Unit of Measure", "Qty. Rounding Precision (Base)", FieldCaption("Qty. Rounding Precision"), FromFieldName, ToFieldName));
    end;

    procedure CalcQuantityRemaining()
    begin
        CalcFields("Actual Quantity (Base)");
        if "Planned Quantity (Base)" < "Actual Quantity (Base)" then
            "Planned Quantity Rem. (Base)" := 0
        else
            "Planned Quantity Rem. (Base)" := "Planned Quantity (Base)" - "Actual Quantity (Base)";
    end;
}

