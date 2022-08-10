table 37002822 "PM Material"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   Planned material for PM orders
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

    Caption = 'PM Material';
    DrillDownPageID = "PM Materials";
    LookupPageID = "PM Materials";

    fields
    {
        field(1; "PM Entry No."; Code[20])
        {
            Caption = 'PM Entry No.';
            TableRelation = "Preventive Maintenance Order";
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            InitValue = Stock;
            OptionCaption = ',Stock,NonStock';
            OptionMembers = ,Stock,NonStock;

            trigger OnValidate()
            begin
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
                PMOrder: Record "Preventive Maintenance Order";
                Asset: Record Asset;
                AssetSpare: Record "Asset Spare Part";
            begin
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
                            PMOrder.Get("PM Entry No.");
                            Asset.Get(PMOrder."Asset No.");
                            if Asset.GetSpare(Type, "Item No.", AssetSpare) then begin
                                "Part No." := AssetSpare."Part No.";
                                Description := AssetSpare.Description;
                            end else
                                // P8000517A
                                "Part No." := "Item No.";
                            // "Qty. per Unit of Measure" := 1; // P800133109
                        end;
                end;
            end;
        }
        field(4; "Part No."; Code[20])
        {
            Caption = 'Part No.';

            trigger OnValidate()
            begin
                if (Type = Type::NonStock) and ("Item No." = '') then
                    "Item No." := "Part No.";
            end;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(9; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(10; "Vendor Name"; Text[100])
        {
            CalcFormula = Lookup(Vendor.Name WHERE("No." = FIELD("Vendor No.")));
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
                // "Planned Quantity (Base)" := Round("Planned Quantity" * "Qty. per Unit of Measure", 0.00001); // P800133109
                Validate("Planned Cost");
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
                            // P800133109
                            // ItemUOM.Get("Item No.", "Unit of Measure Code");
                            "Unit Cost" := "Unit Cost" / xRec.QtyPerUnitOfMeasure();
                            // "Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
                            Validate("Unit Cost", Round("Unit Cost" * QtyPerUnitOfMeasure(), GLSetup."Unit-Amount Rounding Precision"));
                            // "Planned Quantity (Base)" := Round("Planned Quantity" * "Qty. per Unit of Measure", 0.00001);
                            // P800133109
                        end;
                end;
            end;
        }
        field(13; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            InitValue = 1;
            ObsoleteReason = 'No longer required - replaced by QtyPerUnitOfMesaure function.';
            ObsoleteState = Pending; 
            ObsoleteTag = '19.0';
        }
        field(14; "Planned Quantity (Base)"; Decimal)
        {
            Caption = 'Planned Quantity (Base)';
            DecimalPlaces = 0 : 5;
            ObsoleteReason = 'No longer required - replaced by PlannedQuantityBase function.';
            ObsoleteState = Pending;
            ObsoleteTag = '19.0';
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
                GLSetup.Get;
                "Planned Cost" := Round("Planned Quantity" * "Unit Cost", GLSetup."Amount Rounding Precision");
            end;
        }
    }

    keys
    {
        key(Key1; "PM Entry No.", Type, "Item No.")
        {
            SumIndexFields = "Planned Cost";
        }
        key(Key2; Type, "Item No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Item: Record Item;
        // ItemUOM: Record "Item Unit of Measure"; // P800133109
        GLSetup: Record "General Ledger Setup";
        PMOrder: Record "Preventive Maintenance Order";

    // P800133109
    procedure QtyPerUnitOfMeasure() QtyPer: Decimal
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        QtyPer := 1;
        if Type = Type::Stock then
            if ItemUnitOfMeasure.get("Item No.", "Unit of Measure Code") then
                QtyPer := ItemUnitOfMeasure."Qty. per Unit of Measure";
    end;

    // P800133109
    procedure PlannedQuantityBase(): Decimal
    var
        UOMManagement: Codeunit "Unit of Measure Management";
    begin
        case Type of
            Type::NonStock:
                exit("Planned Quantity");
            Type::Stock:
                exit(UOMManagement.CalcBaseQty("Item No.", "Unit of Measure Code", "Planned Quantity"));
        end;
    end;

    procedure LookupItem(var Text: Text[1024]): Boolean
    var
        PMOrder: Record "Preventive Maintenance Order";
        Asset: Record Asset;
    begin
        PMOrder.Get("PM Entry No.");
        Asset.Get(PMOrder."Asset No.");
        exit(Asset.LookupItem(Type, Text));
    end;

    procedure GetPMOrder()
    begin
        if PMOrder."Entry No." <> "PM Entry No." then
            PMOrder.Get("PM Entry No.");
    end;

    procedure AssetNo(): Code[20]
    begin
        GetPMOrder;
        exit(PMOrder."Asset No.");
    end;

    procedure FrequencyCode(): Code[10]
    begin
        GetPMOrder;
        exit(PMOrder."Frequency Code");
    end;
}

