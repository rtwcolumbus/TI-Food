table 37002918 "Quality Control Sample"
{
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples

    Caption = 'Quality Control Sample';
    DataClassification = SystemMetadata;
    DataCaptionFields = "Item Description", "Variant Code", "Lot No.", "Test No.";
    TableType = Temporary;

    fields
    {
        field(1; LineNo; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
        }
        field(11; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            Editable = false;

            trigger OnValidate()
            var
                Item: Record Item;
                ItemUnitofMeasure: Record "Item Unit of Measure";
            begin
                Item.Get("Item No.");
                "Item Description" := Item.Description;
                "Base Unit of Measure" := Item."Base Unit of Measure";
            end;
        }

        field(12; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            Editable = false;
        }
        field(13; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            Editable = false;
        }
        field(14; "Base Unit of Measure"; Code[10])
        {
            Caption = 'Base Unit of Measure';
            Editable = false;
        }
        field(15; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            Editable = false;

            trigger OnValidate()
            var
                ItemUnitofMeasure: Record "Item Unit of Measure";
            begin
                ItemUnitofMeasure.Get("Item No.", "Unit of Measure Code");
                "Qty per Unit of Measure" := ItemUnitofMeasure."Qty. per Unit of Measure";
            end;
        }
        field(16; "Sample Quantity"; Decimal)
        {
            Caption = 'Sample Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                "Sample Quantity (Base)" := UOMMgt.CalcBaseQty("Item No.", "Unit of Measure Code", "Sample Quantity");
                Rec."Quantity Posted (Line)" := Round(GetSamplePostedOnLine() / Rec."Qty per Unit of Measure", 0.00001, '=');
                Rec.Validate("Quanity to Post", (Rec."Sample Quantity" - Rec."Quantity Posted (Line)"));
            end;
        }
        field(17; "Sample Quantity (Base)"; Decimal)
        {
            Caption = 'Sample Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }

        field(19; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code where("Use As In-Transit" = const(false));

            trigger OnValidate()
            var
                Location: Record Location;
            begin
                if "Location Code" <> xRec."Location Code" then begin
                    Rec."Bin Code" := '';
                    Rec."Container License Plate" := '';
                end;
            end;
        }
        field(20; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code where("Location Code" = field("Location Code"));
        }
        field(21; "Container License Plate"; Code[50])
        {
            Caption = 'Container ID';

            trigger OnValidate()
            var
                ContainerHeader: Record "Container Header";
            begin
                if CurrFieldNo <> 0 then begin
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
                    end;
                end;
            end;
        }
        field(22; "Test Code"; Code[10])
        {
            Caption = 'Test Code';
            Editable = false;
            trigger OnValidate()
            var
                DataCollectionDataElement: Record "Data Collection Data Element";
            begin
                if DataCollectionDataElement.Get("Test Code") then
                    "Test Description" := DataCollectionDataElement.Description
                else
                    "Test Description" := '';
            end;
        }
        field(23; "Test No."; Integer)
        {
            Caption = 'Test No.';
            Editable = false;
        }
        field(24; "Combine Samples"; Boolean)
        {
            Caption = 'Combine Samples';
            Editable = false;
        }
        field(25; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
        }
        field(26; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(27; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(28; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(29; "Quantity Posted"; Decimal)
        {
            Caption = 'Quantity Posted';
            CalcFormula = - sum("Item Ledger Entry".Quantity where("Item No." = Field("Item No."),
                                                                "Variant code" = Field("Variant code"),
                                                                "Lot No." = Field("Lot No."),
                                                                "Sample Test No." = Field("Test No.")));
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(30; "Quantity Posted (Line)"; Decimal)
        {
            Caption = 'Quantity Posted (Line)';
            DecimalPlaces = 0 : 5;
            Editable = false;

        }
        field(31; "Quanity to Post"; Decimal)
        {
            Caption = 'Quantity to Post';
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            var
                Item: Record Item;
                ItemUnitofMeasure: Record "Item Unit of Measure";
            begin
                Item.Get("Item No.");
                if Item."Alternate Unit of Measure" <> '' then begin
                    if Item."Catch Alternate Qtys." then
                        "Quantity to Post (Alt.)" := 0
                    else begin
                        ItemUnitofMeasure.Get("Item No.", "Unit of Measure Code");
                        Validate("Quantity to Post (Alt.)", "Quanity to Post" * ItemUnitofMeasure."Equivalent UOM Qty.");
                    end;
                end;
                if Rec."Quanity to Post" < 0 then
                    Rec."Quanity to Post" := 0;
            end;
        }
        field(18; "Quantity to Post (Alt.)"; Decimal)
        {
            Caption = 'Quantity to Post (Alt.)';
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            var
                Item: Record Item;
                AltQtyMgmt: Codeunit "Alt. Qty. Management";
            begin
                Item.Get("Item No.");
                Item.TestField("Alternate Unit of Measure");
                AltQtyMgmt.CheckTolerance("Item No.", FieldCaption("Quantity to Post (Alt.)"), ("Quanity to Post" * "Qty per Unit of Measure"), "Quantity to Post (Alt.)");
            end;
        }
        field(32; "Qty per Unit of Measure"; Decimal)
        {
            Caption = 'Qty per Unit of Measure';
        }
        field(33; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            Editable = false;
        }
        field(34; "Test Description"; Text[100])
        {
            Caption = 'Test Description';
            Editable = false;
        }
    }
    keys
    {
        key(Key1; LineNo)
        {
            Clustered = true;
        }
    }


    var
        UOMMgt: Codeunit "Unit of Measure Management";

    local procedure GetSamplePostedOnLine(): Decimal
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.setrange("Item No.", Rec."Item No.");
        ItemLedgEntry.setrange("Variant Code", Rec."Variant Code");
        ItemLedgEntry.setrange("Lot No.", Rec."Lot No.");
        ItemLedgEntry.setrange("Sample Test No.", Rec."Test No.");
        if Rec."Combine Samples" then
            ItemLedgEntry.setrange("Sample Test Code", '')
        else
            ItemLedgEntry.setrange("Sample Test Code", Rec."Test Code");
        ItemLedgEntry.CalcSums(Quantity);
        exit(Abs(ItemLedgEntry.Quantity));
    end;

    procedure LookupContainer(var Text: Text): Boolean
    var
        ContainerHeader: Record "Container Header";
        ContainerLine: Record "Container Line";
        TempContainerHeader: Record "Container Header" temporary;
        Containers: Page "Containers";
    begin
        ContainerLine.SetRange(Inbound, false);
        ContainerLine.SetRange("Item No.", Rec."Item No.");
        ContainerLine.SetRange("Variant Code", Rec."Variant Code");
        if Rec."Lot No." <> '' then
            ContainerLine.SetRange("Lot No.", Rec."Lot No.");
        if Rec."Location Code" <> '' then
            ContainerLine.SetRange("Location Code", Rec."Location Code");
        if Rec."Bin Code" <> '' then
            ContainerLine.SetRange("Bin Code", Rec."Bin Code");
        if ContainerLine.FindSet then
            repeat
                ContainerHeader.Get(ContainerLine."Container ID");
                if ContainerHeader."Document Type" = 0 then begin
                    TempContainerHeader := ContainerHeader;
                    if TempContainerHeader.Insert then;
                end;
            until ContainerLine.Next = 0;
        TempContainerHeader.FindSet();

        if Page.RunModal(0, TempContainerHeader) = action::LookupOK then begin
            Text := TempContainerHeader."License Plate";
            exit(true);
        end;
    end;
}