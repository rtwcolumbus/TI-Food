table 37002735 "Sub-Lot Buffer"
{
    // PRW118.1
    // P800129613, To Increase, Jack Reynolds, 20 SEP 21
    //   Creatre Sub-Lot Wizard

    Caption = 'Sub-Lot Buffer';
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'EntryNo';
            Editable = false;
        }
        field(2; ContainersEnabled; Boolean)
        {
            Caption = 'ContainersEnabled';
            Editable = false;
        }
        field(3; QCEnabled; Boolean)
        {
            Caption = 'QCEnabled';
            Editable = false;
        }
        field(4; DocumentNoSeries; Code[20])
        {
            Caption = 'DocumentNoSeries';
            Editable = false;
        }
        field(5; SourceCode; Code[10])
        {
            Caption = 'SourceCode';
            Editable = false;
        }
        field(11; "Item No."; Code[20])
        {
            TableRelation = Item."No.";

            trigger OnValidate()
            var
                Item: Record Item;
                ItemTrackingCode: Record "Item Tracking Code";
                ItemVariant: Record "Item Variant";
            begin
                if "Item No." <> xRec."Item No." then
                    ClearFields();

                if "Item No." <> '' then begin
                    Item.Get("Item No.");
                    if not ItemTrackingCode.Get(Item."Item Tracking Code") then
                        Error(ErrNotLotTracked, "Item No.");
                    if not ItemTrackingCode."Lot Specific Tracking" then
                        Error(ErrNotLotTracked, "Item No.");

                    "Item Description" := Item.Description;
                    "Base Unit of Measure" := Item."Base Unit of Measure";
                    ItemVariant.SetRange("Item No.", "Item No.");
                    ItemHasVariants := not ItemVariant.IsEmpty();
                    AlternateUOM := Item."Alternate Unit of Measure";
                    CatchAlternateQuantity := Item."Catch Alternate Qtys.";
                    AlternateQtyPerBase := Item.AlternateQtyPerBase();
                end;
            end;
        }
        field(12; "Item Description"; Text[50])
        {
            Caption = 'Item Description';
            Editable = false;
        }
        field(13; "Base Unit of Measure"; Code[10])
        {
            Caption = 'Base Unit of Measure';
            Editable = false;
        }
        field(14; ItemHasVariants; Boolean)
        {
            Caption = 'ItemHasVariants';
            Editable = false;
        }
        field(15; AlternateUOM; Code[10])
        {
            Caption = 'AlternateUOM';
            Editable = false;
        }
        field(16; CatchAlternateQuantity; Boolean)
        {
            Caption = 'CatchAlternateQuantity';
            Editable = false;
        }
        field(17; AlternateQtyPerBase; Decimal)
        {
            Caption = 'AlternateQtyPerBase';
            Editable = false;
        }
        field(18; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
        }
        field(19; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            TableRelation = "Lot No. Information"."Lot No." where("Item No." = field("Item No."),
                                                                  "Variant Code" = field("Variant Code"),
                                                                  Inventory = filter(> 0));

            trigger OnValidate()
            var
                LotNoInfo: Record "Lot No. Information";
            begin
                LotNoInfo.Get("Item No.", "Variant Code", "Lot No.");
                OriginalLotStatusCode := LotNoInfo."Lot Status Code";
                "Lot Status Code" := LotNoInfo."Lot Status Code";
            end;
        }
        field(20; OriginalLotStatusCode; Code[10])
        {
            Caption = 'OriginalLotStatusCode';
            Editable = false;
        }
        field(21; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code where("Use As In-Transit" = const(false));

            trigger OnValidate()
            var
                Location: Record Location;
            begin
                if "Location Code" <> xRec."Location Code" then begin
                    Rec."Bin Code" := '';
                    Rec.ContainerID := '';
                    Rec."Container License Plate" := '';
                end;
                if "Location Code" <> '' then begin
                    Location.Get("Location Code");
                    BinMandatory := Location."Bin Mandatory";
                    UseWarehouseJournal := Location."Directed Put-away and Pick";
                end else
                    BinMandatory := false;
            end;
        }
        field(22; BinMandatory; Boolean)
        {
            Caption = 'BinMandatory';
            Editable = false;
        }
        field(23; UseWarehouseJournal; Boolean)
        {
            Caption = 'UseWarehouseJournal';
            Editable = false;
        }
        field(24; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code where("Location Code" = field("Location Code"));
        }
        field(25; ContainerID; Code[20])
        {
            Caption = 'ContainerID';
            Editable = false;
        }
        field(26; "Container License Plate"; Code[50])
        {
            Caption = 'Container License Plate';

            trigger OnValidate()
            var
                ContainerHeader: Record "Container Header";
            begin
                if CurrFieldNo <> 0 then begin
                    ContainerID := '';
                    if "Container License Plate" <> '' then begin
                        if "Location Code" <> '' then
                            ContainerHeader.SetRange("Location Code", "Location Code");
                        if "Bin Code" <> '' then
                            ContainerHeader.SetRange("Bin Code", "Bin Code");
                        ContainerHeader.SetRange("License Plate", "Container License Plate");
                        ContainerHeader.SetRange(Inbound, false);
                        ContainerHeader.SetRange("Document Type", 0);
                        ContainerHeader.FindFirst();
                        "Location Code" := ContainerHeader."Location Code";
                        "Bin Code" := ContainerHeader."Bin Code";
                        ContainerID := ContainerHeader.ID;
                    end;
                end;
            end;
        }
        field(31; "Sub-Lot No."; Code[50])
        {
            Caption = 'Sub-Lot No.';

            trigger OnValidate()
            var
                LotNoInfo: Record "Lot No. Information";
                P800ItemTracking: Codeunit "Process 800 Item Tracking";
            begin
                if "Sub-Lot No." = '' then begin
                    "Sub-Lot No." := StrSubstNo('%1-%2', "Lot No.", P800ItemTracking.GetUniqueSegmentNo("Lot No."));
                    while LotNoInfo.Get("Item No.", "Variant Code", "Sub-Lot No.") do
                        "Sub-Lot No." := StrSubstNo('%1-%2', "Lot No.", P800ItemTracking.GetUniqueSegmentNo("Lot No."));
                end else
                    if LotNoInfo.Get("Item No.", "Variant Code", "Sub-Lot No.") then
                        Error(ErrLotExists, "Lot No.");
            end;
        }
        field(32; "Lot Status Code"; Code[10])
        {
            Caption = 'Lot Status Code';
            TableRelation = "Lot Status Code".Code;

            trigger OnValidate()
            var
                InventorySetup: Record "Inventory Setup";
            begin
                InventorySetup.Get();
                if "Lot Status Code" = InventorySetup."Quarantine Lot Status" then
                    Error(ErrQuarantine, FieldCaption("Lot Status Code"));
            end;
        }
        field(33; "Document No."; Code[20])
        {
            Caption = 'Document No.';

            trigger OnValidate()
            begin
                if "Document No." = '' then
                    Error(ErrRequiredField, FieldCaption("Document No."));
            end;
        }
        field(34; "Posting Date"; Date)
        {
            Caption = 'Posting Date';

            trigger OnValidate()
            begin
                if "Posting Date" = 0D then
                    Error(ErrRequiredField, FieldCaption("Posting Date"));
            end;
        }
        field(35; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code".Code;
        }
        field(51; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            Editable = false;

            trigger OnValidate()
            var
                ItemUnitofMeasure: Record "Item Unit of Measure";
                LabelSelection: Record "Label Selection";
            begin
                ItemUnitofMeasure.Get("Item No.", "Unit of Measure Code");
                QtyPerUOM := ItemUnitofMeasure."Qty. per Unit of Measure";
                if CatchAlternateQuantity then
                    AlternateQtyPerUOM := AlternateQtyPerBase * ItemUnitofMeasure."Qty. per Unit of Measure";

                "Label Code" := '';
                LabelsPerUnit := 0;
                if ItemUnitofMeasure."Label Code" <> '' then begin
                    "Label Code" := ItemUnitofMeasure."Label Code";
                    LabelsPerUnit := ItemUnitofMeasure."Labels per Unit"
                end else
                    if LabelSelection.Get(Database::Item, "Item No.", "Label Type"::"Case") then begin
                        "Label Code" := LabelSelection."Label Code";
                        LabelsPerUnit := 1;
                    end;
            end;
        }
        field(52; QtyPerUOM; Decimal)
        {
            Caption = 'QtyPerUOM';
            Editable = false;
        }
        field(53; AlternateQtyPerUOM; Decimal)
        {
            Caption = 'AlternateQtyPerUOM';
            Editable = false;
        }
        field(54; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(55; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(56; "Quantity (Alt.)"; Decimal)
        {
            Caption = 'Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(57; "Quantity to Reclass"; Decimal)
        {
            Caption = 'Quantity to Reclass';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            var
                Item: Record Item;
                ContainerHeader: Record "Container Header";
                ContainerTypeUsage: Record "Container Type Usage";
                ContainerFunctions: Codeunit "Container Functions";
            begin
                Item.Get("Item No.");
                if CurrFieldNo <> 0 then begin
                    Item.GetItemUOMRndgPrecision("Unit of Measure Code", true);
                    "Quantity to Reclass" := Round("Quantity to Reclass", Item."Rounding Precision");

                    if "Quantity to Reclass" > Quantity then
                        Error(ErrReclassQuantityExceedsQuantity, FieldCaption("Quantity to Reclass"), FieldCaption(Quantity));
                    if ("Quantity to Reclass" < Quantity) and (ContainerID <> '') then begin
                        ContainerHeader.get(ContainerID);
                        if ContainerHeader."Document Type" = 0 then begin
                            Item.Get("Item No.");
                            ContainerFunctions.GetContainerUsage(ContainerHeader."Container Type Code", Item."No.", Item."Item Category Code",
                                "Unit of Measure Code", true, ContainerTypeUsage);
                            if ContainerTypeUsage."Single Lot" then
                                Error(ErrMultiLotContainer);
                        end;
                    end;
                end;

                "Quantity to Reclass (Base)" := Round("Quantity to Reclass" * QtyPerUOM, 0.00001);

                "No. of Labels" := Round("Quantity to Reclass" * LabelsPerUnit, 1, '>');

                if CatchAlternateQuantity then
                    if Quantity = "Quantity to Reclass" then
                        "Quantity to Reclass (Alt.)" := "Quantity (Alt.)"
                    else begin
                        Item.GetItemUOMRndgPrecision(AlternateUOM, true);
                        "Quantity to Reclass (Alt.)" := Round("Quantity to Reclass" * AlternateQtyPerUOM, Item."Rounding Precision");
                    end;
            end;
        }
        field(58; "Quantity to Reclass (Base)"; Decimal)
        {
            Caption = 'Quantity to Reclass (Alt.)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(59; "Quantity to Reclass (Alt.)"; Decimal)
        {
            AutoFormatExpression = "Item No.";
            AutoFormatType = 37002080;
            Caption = 'Quantity to Reclass (Alt.)';
            MinValue = 0;

            trigger OnValidate()
            var
                Item: Record Item;
                AltQtyManangement: Codeunit "Alt. Qty. Management";
            begin
                Item.Get("Item No.");
                if CurrFieldNo <> 0 then begin
                    Item.GetItemUOMRndgPrecision(AlternateUOM, true);
                    "Quantity to Reclass (Alt.)" := Round("Quantity to Reclass (Alt.)", Item."Rounding Precision");
                end;

                if ("Quantity to Reclass (Alt.)" > 0) and ("Quantity to Reclass" = 0) then
                    Error(ErrReclassQtyZero, FieldCaption("Quantity to Reclass (Alt.)"));
                if ("Quantity to Reclass (Alt.)" = 0) and ("Quantity to Reclass" > 0) then
                    Error(ErrReclassQtyPositive, FieldCaption("Quantity to Reclass (Alt.)"));
                if (Quantity = "Quantity to Reclass") and ("Quantity to Reclass (Alt.)" < "Quantity (Alt.)") then
                    Error(ErrReclassQtyEqual, FieldCaption("Quantity to Reclass (Alt.)"), FieldCaption("Quantity (Alt.)"));
                if "Quantity to Reclass (Alt.)" > "Quantity (Alt.)" then
                    Error(ErrReclassQuantityExceedsQuantity, FieldCaption("Quantity to Reclass (Alt.)"), FieldCaption("Quantity (Alt.)"));

                AltQtyManangement.CheckTolerance("Item No.", FieldCaption("Quantity to Reclass (Alt.)"),
                  "Quantity to Reclass (Base)", "Quantity to Reclass (Alt.)");
            end;
        }
        field(61; "Label Code"; Code[10])
        {
            Caption = 'Label Code';
            Editable = false;
        }
        field(62; LabelsPerUnit; Integer)
        {
            Caption = 'LabelQtyPer';
            Editable = false;
        }
        field(63; "No. of Labels"; Integer)
        {
            Caption = 'No. of Labels';
            MinValue = 0;
        }
        field(71; "Test No."; Integer)
        {
            Caption = 'Test No.';
            Editable = false;
        }
        field(72; "Re-Test"; Boolean)
        {
            Caption = 'Re-Test';
            Editable = false;
        }
        field(73; "Assigned To"; Code[10])
        {
            Caption = 'Assigned To';
            Editable = false;
        }
        field(74; "Schedule Date"; Date)
        {
            Caption = 'Schedule Date';
            Editable = false;
        }
        field(75; "Quality Tests"; Blob)
        {
            Caption = 'Quality Tests';
        }
        field(76; "Copy to Sub-lot"; Boolean)
        {
            Caption = 'Copy to Sub-lot';
        }
    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }
        key(Key2; "Bin Code", "Container License Plate", "Unit of Measure Code")
        { }
        key(Key3; "Test No.")
        { }
    }

    var
        ErrRequiredField: Label '"%1" must be entered.';
        ErrNotLotTracked: Label 'Item "%1" is not lot tracked.';
        ErrLotExists: Label 'Lot "%1" already exists.';
        ErrReclassQuantityExceedsQuantity: Label '"%1" exceeds "%2".';
        ErrReclassQtyZero: Label '"%1" must be zero.';
        ErrReclassQtyPositive: Label '"%1" must be greater than zero.';
        ErrReclassQtyEqual: Label '"%1" must be equal to "%2".';
        ErrMultiLotContainer: Label 'This container cannot contain multiple lots.';
        ErrQuarantine: Label '"%1" is reserved for Quarantine.';

    trigger OnInsert()
    var
        P800Functions: Codeunit "Process 800 Functions";
        InventorySetup: Record "Inventory Setup";
    begin
        ContainersEnabled := P800Functions.ContainerTrackingInstalled();
        QCEnabled := P800Functions.QCInstalled();
        InventorySetup.Get();
        DocumentNoSeries := InventorySetup."Chg. Lot Status Document Nos.";
    end;

    local procedure ClearFields()
        SubLot: Record "Sub-Lot Buffer";
    begin
        SubLot := Rec;
        Init();
        ContainersEnabled := SubLot.ContainersEnabled;
        QCEnabled := SubLot.QCEnabled;
        DocumentNoSeries := SubLot.DocumentNoSeries;
        "Item No." := SubLot."Item No.";
    end;

    procedure Join(Variant1: Variant; Variant2: Variant) Result: Text
    var
        Text001: Label '%1 • %2';
    begin
        Result := format(Variant1);
        if Result = '' then
            Result := Format(Variant2)
        else
            if Format(Variant2) <> '' then
                Result := StrSubstNo(Text001, Result, Variant2);
    end;

    procedure Join(Variant1: Variant; Variant2: Variant; Variant3: Variant) Result: Text
    begin
        Result := Join(Variant1, Variant2);
        Result := Join(Result, Variant3);
    end;

    procedure LotSummary() Result: Text
    begin
        Result := Join(StrSubstNo('%1 - %2', "Item No.", "Item Description"), "Variant Code", "Lot No.");
    end;

    procedure LocationSummary() Result: Text
    begin
        Result := Join("Location Code", "Bin Code", "Container License Plate");
    end;

    procedure QuantitySummary() Result: Text
    var
        SubLot: Record "Sub-Lot Buffer" temporary;
    begin
        SubLot.Copy(Rec, true);
        SubLot.Reset();
        SubLot.SetFilter("Quantity to Reclass", '>0');
        SubLot.SetCurrentKey("Unit of Measure Code");
        if SubLot.FindSet() then
            repeat
                SubLot.SetRange("Unit of Measure Code", SubLot."Unit of Measure Code");
                SubLot.CalcSums("Quantity to Reclass");
                Result := Join(Result, StrSubstNo('%1: %2', SubLot."Unit of Measure Code", SubLot."Quantity to Reclass"));
                SubLot.FindLast();
                SubLot.SetRange("Unit of Measure Code");
            until SubLot.Next() = 0;
    end;

    procedure QualitySummary() Result: Text
    var
        SubLot: Record "Sub-Lot Buffer" temporary;
    begin
        SubLot.Copy(Rec, true);
        SubLot.Reset();
        SubLot.SetRange("Copy to Sub-lot", true);
        Result := StrSubstNo('%1: %2', FieldCaption("Copy to Sub-lot"), SubLot.Count());
    end;

    procedure SubLotSummary() Result: Text
    begin
        Result := Join("Sub-Lot No.", "Lot Status Code");
    end;

    procedure PostingSummary() Result: Text
    begin
        Result := Join("Posting Date", "Document No.", "Reason Code");
    end;

    procedure LabelSummary() Result: Text
    var
        SubLot: Record "Sub-Lot Buffer" temporary;
    begin
        SubLot.Copy(Rec, true);
        SubLot.Reset();
        SubLot.SetFilter("No. of Labels", '>0');
        SubLot.SetCurrentKey("Unit of Measure Code");
        if SubLot.FindSet() then
            repeat
                SubLot.SetRange("Unit of Measure Code", SubLot."Unit of Measure Code");
                SubLot.CalcSums("No. of Labels");
                Result := Join(Result, StrSubstNo('%1: %2', SubLot."Unit of Measure Code", SubLot."No. of Labels"));
                SubLot.FindLast();
                SubLot.SetRange("Unit of Measure Code");
            until SubLot.Next() = 0;
    end;

    procedure LookupContainerLicensePlate(var Text: Text): Boolean
    var
        ContainerHeader: Record "Container Header";
        ContainerList: Page Containers;
    begin
        if "Location Code" <> '' then
            ContainerHeader.SetRange("Location Code", "Location Code");
        if "Bin Code" <> '' then
            ContainerHeader.SetRange("Bin Code", "Bin Code");
        ContainerHeader.SetRange(Inbound, false);
        ContainerHeader.SetRange("Document Type", 0);
        ContainerList.LookupMode(true);
        ContainerList.SetTableView(ContainerHeader);
        if Text <> '' then begin
            ContainerHeader.SetRange("License Plate", Text);
            if ContainerHeader.FindFirst() then
                ContainerList.SetRecord(ContainerHeader);
        end;
        if ContainerList.RunModal() = Action::LookupOK then begin
            ContainerList.GetRecord(ContainerHeader);
            Text := ContainerHeader."License Plate";
            exit(true);
        end;
    end;

    procedure ReadQualityTests() Result: Text
    var
        Instr: InStream;
    begin
        CalcFields("Quality Tests");
        "Quality Tests".CreateInStream(Instr);
        Instr.ReadText(Result);
    end;

    procedure SaveQualityTests(QualityTests: Text)
    var
        OutStr: OutStream;
    begin
        CalcFields("Quality Tests");
        Clear("Quality Tests");
        "Quality Tests".CreateOutStream(OutStr);
        OutStr.WriteText(QualityTests);
        Modify();
    end;

    procedure AssignLotNo()
    var
        ItemJournalLine: Record "Item Journal Line";
        P800ItemTracking: Codeunit "Process 800 Item Tracking";
    begin
        ItemJournalLine."Entry Type" := ItemJournalLine."Entry Type"::Transfer;
        ItemJournalLine."Item No." := "Item No.";
        ItemJournalLine."Posting Date" := "Posting Date";
        ItemJournalLine."Document No." := "Document No.";
        ItemJournalLine."Location Code" := "Location Code";
        "Sub-Lot No." := P800ItemTracking.AssignLotNo(ItemJournalLine);
    end;
}
