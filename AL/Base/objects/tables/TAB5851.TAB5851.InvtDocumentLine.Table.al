table 5851 "Invt. Document Line"
{
    // PRW118.01
    // P800127049, To Increase, Jack Reynolds, 23 AUG 21
    //   Support for Inventory document
    //
    // PRW118.01
    // P800128960, To Increase, Jack Reynolds, 24 AUG 21
    //   Decimal precision on alternate quantity data entry

    Caption = 'Item Document Line';
    DrillDownPageID = "Invt. Document Lines";
    LookupPageID = "Invt. Document Lines";

    fields
    {
        field(37002020; "FOOD Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            Description = 'PR3.61';
            Editable = true;

            trigger OnValidate()
            begin
                if ("FOOD Lot No." = '') then begin
                    "FOOD Creation Date" := 0D;
                    "FOOD Country/Reg of Orig Code" := '';
                end;
                if "Line No." <> 0 then begin
                    Modify();
                    UpdateLotTracking(false);
                end;
            end;
        }
        field(37002021; "FOOD Country/Reg of Orig Code"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";

            trigger OnValidate()
            var
                P800Globals: Codeunit "Process 800 System Globals";
            begin
                TestField("Document Type", "Document Type"::Receipt);
                if ("FOOD Lot No." = P800Globals.MultipleLotCode) then
                    FieldError("FOOD Country/Reg of Orig Code", Text37002004);
                if ("FOOD Country/Reg of Orig Code" <> '') then
                    TestField("FOOD Lot No.");
                if "Line No." <> 0 then begin
                    Modify();
                    UpdateLotTracking(false);
                end;
            end;
        }
        field(3700022; "FOOD Creation Date"; Date)
        {
            Caption = 'Creation Date';

            trigger OnValidate()
            var
                P800Globals: Codeunit "Process 800 System Globals";
            begin
                TestField("Document Type", "Document Type"::Receipt);
                if ("FOOD Lot No." = P800Globals.MultipleLotCode) then
                    FieldError("FOOD Creation Date", Text37002004);
                if ("FOOD Creation Date" <> 0D) then
                    TestField("FOOD Lot No.");
                if "Line No." <> 0 then begin
                    Modify();
                    UpdateLotTracking(false);
                end;
            end;
        }
        field(37002080; "FOOD Alt. Qty. Transaction No."; Integer)
        {
            Caption = 'Alt. Qty. Transaction No.';
            Editable = false;
        }
        field(37002081; "FOOD Quantity (Alt.)"; Decimal)
        {
            AccessByPermission = TableData "Alternate Quantity Line" = R;
            AutoFormatExpression = "Item No.";
            AutoFormatType = 37002080;
            BlankZero = true;
            Caption = 'Quantity (Alt.)';

            trigger OnValidate()
            begin
                if CurrFieldNo <> 0 then
                    TestStatusOpen();
                if Quantity < 0 then
                    error(CannotBeNegativeErr, FieldCaption(Quantity));
                if Quantity > 0 then
                    TestField("Item No.");

                GetItem;
                Item.TestField("Alternate Unit of Measure");

                if (CurrFieldNo = FieldNo("FOOD Quantity (Alt.)")) then begin
                    Item.TestField("Catch Alternate Qtys.", true);
                    AltQtyMgmt.CheckSummaryTolerance1("FOOD Alt. Qty. Transaction No.", "Item No.",
                                                     FieldCaption("FOOD Quantity (Alt.)"),
                                                     "Quantity (Base)", "FOOD Quantity (Alt.)");
                end;

                UpdateAmount();
            end;
        }
        field(37002560; "FOOD Container License Plate"; Code[50])
        {
            Caption = 'Container License Plate';

            trigger OnValidate()
            var
                InvtDocHeader: Record "Invt. Document Header";
            begin
                InvtDocHeader.Get("Document Type", "Document No.");
                if ((InvtDocHeader."Document Type" = InvtDocHeader."Document Type"::Receipt) and InvtDocHeader.Correction) or
                   ((InvtDocHeader."Document Type" = InvtDocHeader."Document Type"::Shipment) and (not InvtDocHeader.Correction))
                then
                    Validate("FOOD Old License Plate", "FOOD Container License Plate")
                else
                    Validate("FOOD New License Plate", "FOOD Container License Plate");
            end;
        }
        field(37002561; "FOOD Old License Plate"; Code[50])
        {
            Caption = 'Old Container License Plate';

            trigger OnValidate()
            var
                ContainerHeader: Record "Container Header";
                ContainerLine: Record "Container Line";
                ProductionOrder: Record "Production Order";
                ItemNo: Code[20];
                VariantCode: Code[10];
                LotNo: Code[50];
                UOMCode: Code[10];
                ContainerDocumentLineNo: Integer;
            begin
                if "FOOD Old License Plate" <> xRec."FOOD Old License Plate" then
                    if "FOOD Old License Plate" = '' then begin
                        "FOOD Old Container ID" := '';
                        if xRec."FOOD Old License Plate" = "FOOD New License Plate" then begin
                            "FOOD New License Plate" := '';
                            "FOOD New Container ID" := '';
                        end;
                    end else begin
                        ContainerHeader.SetRange("License Plate", "FOOD Old License Plate");
                        ContainerHeader.SetRange("Location Code", "Location Code");
                        if "Bin Code" <> '' then
                            ContainerHeader.SetRange("Bin Code", "Bin Code");
                        ContainerHeader.SetRange(Inbound, false);
                        ContainerHeader.FindFirst();

                        if ContainerHeader."Document Type" <> 0 then
                            Error(Text37002003, ContainerHeader.DocumentType, ContainerHeader."Document No.");

                        "FOOD Old Container ID" := ContainerHeader.ID;
                        CheckOldContainer();

                        ContainerLine.SetRange("Container ID", "FOOD Old Container ID");
                        if ContainerLine.FindFirst() then begin
                            if "Item No." = '' then begin
                                ContainerLine.SetFilter("Item No.", '<>%1', ContainerLine."Item No.");
                                if ContainerLine.IsEmpty then
                                    ItemNo := ContainerLine."Item No.";
                                ContainerLine.SetRange("Item No.", ItemNo);
                            end else
                                ContainerLine.SetRange("Item No.", "Item No.");

                            if ("Item No." <> '') or (ItemNo <> '') then begin
                                if "Variant Code" = '' then begin
                                    ContainerLine.SetFilter("Variant Code", '<>%1', ContainerLine."Variant Code");
                                    if ContainerLine.IsEmpty() then
                                        VariantCode := ContainerLine."Variant Code";
                                end else begin
                                    ContainerLine.SetFilter("Variant Code", '%1', "Variant Code");
                                    if ContainerLine.FindFirst() then
                                        VariantCode := ContainerLine."Variant Code";
                                end;
                                ContainerLine.SetRange("Variant Code");

                                if "FOOD Lot No." = '' then begin
                                    ContainerLine.SetFilter("Lot No.", '<>%1', ContainerLine."Lot No.");
                                    if ContainerLine.IsEmpty() then
                                        LotNo := ContainerLine."Lot No.";
                                    ContainerLine.SetRange("Lot No.");
                                end;

                                if "Unit of Measure Code" = '' then begin
                                    ContainerLine.SetFilter("Unit of Measure Code", '<>%1', ContainerLine."Unit of Measure Code");
                                    if ContainerLine.IsEmpty() then
                                        UOMCode := ContainerLine."Unit of Measure Code";
                                    ContainerLine.SetRange("Unit of Measure Code");
                                end;
                            end;

                            if ItemNo <> '' then
                                Validate("Item No.", ItemNo);
                            if "Variant Code" <> VariantCode then
                                Validate("Variant Code", VariantCode);
                            if LotNo <> '' then
                                Validate("FOOD Lot No.", LotNo);
                            if ("Unit of Measure Code" <> UOMCode) and (UOMCode <> '') then
                                Validate("Unit of Measure Code", UOMCode);
                        end;
                    end;
            end;
        }
        field(37002562; "FOOD Old Container ID"; Code[20])
        {
            Caption = 'Old Container ID';
        }
        field(37002563; "FOOD New License Plate"; Code[50])
        {
            Caption = 'New Container License Plate';

            trigger OnValidate()
            var
                ContainerHeader: Record "Container Header";
            begin
                if "FOOD New License Plate" <> xRec."FOOD New License Plate" then
                    if "FOOD New License Plate" = '' then
                        "FOOD New Container ID" := ''
                    else begin
                        ContainerHeader.SetRange("License Plate", "FOOD New License Plate");
                        ContainerHeader.SetRange("Location Code", "Location Code");
                        if "Bin Code" <> '' then
                            ContainerHeader.SetRange("Bin Code", "Bin Code");
                        ContainerHeader.SetRange(Inbound, false);
                        ContainerHeader.FindFirst();

                        if ContainerHeader."Document Type" <> 0 then
                            Error(Text37002003, ContainerHeader.DocumentType, ContainerHeader."Document No.");

                        "FOOD New Container ID" := ContainerHeader.ID;
                        CheckNewContainer();
                        if "Bin Code" <> ContainerHeader."Bin Code" then
                            Validate("Bin Code", ContainerHeader."Bin Code");
                    end;
            end;
        }
        field(37002564; "FOOD New Container ID"; Code[20])
        {
            Caption = 'New Container ID';
        }
        field(1; "Document Type"; Enum "Invt. Doc. Document Type")
        {
            Caption = 'Document Type';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;

            trigger OnValidate()
            begin
                if CurrFieldNo <> 0 then
                    TestStatusOpen();

                CheckItemAvailable(FieldNo("Item No."));

                ReserveInvtDocLine.VerifyChange(Rec, xRec);
                CalcFields("Reserved Qty. Inbnd. (Base)");
                TestField("Reserved Qty. Inbnd. (Base)", 0);

                GetInvtDocHeader();
                "Posting Date" := InvtDocHeader."Posting Date";
                "Document Date" := InvtDocHeader."Document Date";
                "Location Code" := InvtDocHeader."Location Code";
                "Gen. Bus. Posting Group" := InvtDocHeader."Gen. Bus. Posting Group";

                GetItem();
                Item.TestField(Blocked, false);
                Item.TestField("Base Unit of Measure");
                Item.TestField(Type, Item.Type::Inventory);
                Validate(Description, Item.Description);
                Validate("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
                Validate("Inventory Posting Group", Item."Inventory Posting Group");
                Validate("Unit Volume", Item."Unit Volume");
                Validate("Units per Parcel", Item."Units per Parcel");
                "Item Category Code" := Item."Item Category Code";
                "Indirect Cost %" := Item.IndirectCostPct("Variant Code", "Location Code"); // P800127049

                if "Item No." <> xRec."Item No." then begin
                    "Variant Code" := '';
                    "Bin Code" := '';
                    if ("Location Code" <> '') and ("Item No." <> '') then begin
                        GetLocation("Location Code");
                        if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then
                            WMSManagement.GetDefaultBin("Item No.", "Variant Code", "Location Code", "Bin Code")
                    end;
                    // P800127049
                    if "FOOD Alt. Qty. Transaction No." <> 0 then
                        AltQtyMgmt.DeleteAltQtyLines("FOOD Alt. Qty. Transaction No.");
                    "FOOD Quantity (Alt.)" := 0;
                    "FOOD Alt. Qty. Transaction No." := 0;
                    // P800127049
                end;

                if "Bin Code" <> '' then
                    Validate("Bin Code");

                if "Variant Code" <> '' then
                    Validate("Variant Code");

                Validate("Unit of Measure Code", Item."Base Unit of Measure");

                CreateDimFromDefaultDim(Rec.FieldNo("Item No."));

                // P800127049
                if (CurrFieldNo = FieldNo("Item No.")) and ("Item No." <> xRec."Item No.") then begin
                    CheckOldContainer();
                    CheckNewContainer();
                end;

                if Item."Catch Alternate Qtys." then
                    AltQtyMgmt.AssignNewTransactionNo("FOOD Alt. Qty. Transaction No.");
                // P800127049
            end;
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(5; "Document Date"; Date)
        {
            Caption = 'Document Date';

            trigger OnValidate()
            begin
                CheckDateConflict.InvtDocLineCheck(Rec, CurrFieldNo <> 0); // Inbound
            end;
        }
        field(7; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(9; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;

            trigger OnValidate()
            begin
                // P800127049
                GetItem;
                "Indirect Cost %" := Item.IndirectCostPct("Variant Code", "Location Code");
                // P800127049
                GetUnitAmount(FieldNo("Location Code"));
                "Unit Cost" := Round(UnitCost * UOMCostFactor(), GLSetup."Unit-Amount Rounding Precision"); // P800127049
                Validate("Unit Amount");
                CheckItemAvailable(FieldNo("Location Code"));

                if "Location Code" <> xRec."Location Code" then begin
                    "Bin Code" := '';
                    if ("Location Code" <> '') and ("Item No." <> '') then begin
                        GetLocation("Location Code");
                        if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then
                            WMSManagement.GetDefaultBin("Item No.", "Variant Code", "Location Code", "Bin Code");
                    end;
                    // P800127049
                    "FOOD Container License Plate" := '';
                    "FOOD Old License Plate" := '';
                    "FOOD Old Container ID" := '';
                    // P800127049
                end;

                ReserveInvtDocLine.VerifyChange(Rec, xRec);
                CreateDimFromDefaultDim(Rec.FieldNo("Location Code"));
            end;
        }
        field(10; "Inventory Posting Group"; Code[20])
        {
            Caption = 'Inventory Posting Group';
            Editable = false;
            TableRelation = "Inventory Posting Group";
        }
        field(13; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if CurrFieldNo <> 0 then
                    TestStatusOpen();
                if Quantity < 0 then
                    error(CannotBeNegativeErr, FieldCaption(Quantity));
                if Quantity > 0 then
                    TestField("Item No.");

                Quantity := UOMMgt.RoundAndValidateQty(Quantity, "Qty. Rounding Precision", FieldCaption(Quantity));

                "Quantity (Base)" := CalcBaseQty(Quantity, FieldCaption(Quantity), FieldCaption("Quantity (Base)"));

                // P800127049
                if ("Item No." <> '') then
                    AltQtyMgmt.InitAlternateQty("Item No.", "FOOD Alt. Qty. Transaction No.", "Quantity (Base)", "FOOD Quantity (Alt.)");
                // P800127049
                GetUnitAmount(FieldNo(Quantity));
                UpdateAmount();

                CheckItemAvailable(FieldNo(Quantity));
                ReserveInvtDocLine.VerifyQuantity(Rec, xRec);
                UpdateLotTracking(false); // P800127049
            end;
        }
        field(16; "Unit Amount"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Amount';

            trigger OnValidate()
            begin
                UpdateAmount();
                if ("Item No." <> '') and ("Document Type" = "Document Type"::Receipt) then begin
                    ReadGLSetup();
                    // P800127049
                    if TrackAlternateUnits() then
                        AltQtyMgmt.AdjustPerBaseAmount("Item No.", "Qty. per Unit of Measure");
                    // P800127049
                    "Unit Cost" :=
                      Round(
                        "Unit Amount" * (1 + "Indirect Cost %" / 100), GLSetup."Unit-Amount Rounding Precision");
                    // P800127049
                    if TrackAlternateUnits() then
                        AltQtyMgmt.AdjustPerBaseAmount("Item No.", "Qty. per Unit of Measure");
                    // P800127049
                    Validate("Unit Cost");
                end;
            end;
        }
        field(17; "Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost';

            trigger OnValidate()
            begin
                TestField("Item No.");
                RetrieveCosts();
                if ("Document Type" = "Document Type"::Receipt) and (Item."Costing Method" = Item."Costing Method"::Standard) then
                    if CurrFieldNo <> FieldNo("Unit Cost") then
                        "Unit Cost" := Round(UnitCost * UOMCostFactor() * "Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision") // P800127049
                    else
                        Error(CannotChangeCostErr, FieldCaption("Unit Cost"), Item."Costing Method");
            end;
        }
        field(18; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';

            trigger OnValidate()
            begin
                // P800127049
                if CostInAlternateUnits() then
                    TestField("FOOD Quantity (Alt.)")
                else
                    TestField(Quantity);
                // P800127049
                "Unit Amount" := Amount / GetPricingQty(FIELDNO(Quantity)); // P800127049
                Validate("Unit Amount");
                ReadGLSetup();
                "Unit Amount" := Round("Unit Amount", GLSetup."Unit-Amount Rounding Precision");
            end;
        }
        field(23; "Salespers./Purch. Code"; Code[20])
        {
            Caption = 'Salespers./Purch. Code';
            TableRelation = "Salesperson/Purchaser" where(Blocked = const(false));

            trigger OnValidate()
            begin
                CreateDimFromDefaultDim(Rec.FieldNo("Salespers./Purch. Code"));
            end;
        }
        field(26; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            TableRelation = "Source Code";
        }
        field(29; "Applies-to Entry"; Integer)
        {
            Caption = 'Applies-to Entry';

            trigger OnLookup()
            begin
                SelectItemEntry(FieldNo("Applies-to Entry"));
            end;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
            begin
                if "Applies-to Entry" <> 0 then begin
                    ItemLedgEntry.Get("Applies-to Entry");

                    TestField(Quantity);
                    ItemLedgEntry.TestField(Open, true);

                    "Location Code" := ItemLedgEntry."Location Code";
                    "Variant Code" := ItemLedgEntry."Variant Code";
                    "Unit Cost" := CalcUnitCost(ItemLedgEntry."Entry No.");
                    "Unit Amount" := "Unit Cost";
                    UpdateAmount();

                    if (ItemLedgEntry."Lot No." <> '') or (ItemLedgEntry."Serial No." <> '') then
                        Error(UseItemTrackingLinesErr, FieldCaption("Applies-from Entry"));
                end else begin
                    RetrieveCosts();
                    "Unit Cost" := UnitCost;
                end;
            end;
        }
        field(32; "Item Shpt. Entry No."; Integer)
        {
            Caption = 'Item Shpt. Entry No.';
            Editable = false;
        }
        field(34; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(35; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(37; "Indirect Cost %"; Decimal)
        {
            Caption = 'Indirect Cost %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField("Item No.");
                TestField("Item Charge No.", '');

                GetItem();
                if Item."Costing Method" = Item."Costing Method"::Standard then
                    Error(CannotChangeCostErr, FieldCaption("Indirect Cost %"), Item."Costing Method");

                // P800127049
                if TrackAlternateUnits() then
                    AltQtyMgmt.AdjustPerBaseAmount("Item No.", "Qty. per Unit of Measure");
                // P800127049
                "Unit Cost" :=
                  Round("Unit Amount" * (1 + "Indirect Cost %" / 100), GLSetup."Unit-Amount Rounding Precision");
                // P800127049
                if TrackAlternateUnits() then
                    AltQtyMgmt.RestorePerBaseAmount("Qty. per Unit of Measure");
                // P800127049
            end;
        }
        field(38; "Gross Weight"; Decimal)
        {
            Caption = 'Gross Weight';
            DecimalPlaces = 0 : 5;
        }
        field(39; "Net Weight"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;
        }
        field(40; "Units per Parcel"; Decimal)
        {
            Caption = 'Units per Parcel';
            DecimalPlaces = 0 : 5;
        }
        field(41; "Unit Volume"; Decimal)
        {
            Caption = 'Unit Volume';
            DecimalPlaces = 0 : 5;
        }
        field(42; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(55; "Last Item Ledger Entry No."; Integer)
        {
            Caption = 'Last Item Ledger Entry No.';
            Editable = false;
            TableRelation = "Item Ledger Entry";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(57; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(58; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(65; "Posting No. Series"; Code[20])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
        }
        field(72; "Unit Cost (ACY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Unit Cost (ACY)';
            Editable = false;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;

            trigger OnValidate()
            begin
                DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            begin
                if "Variant Code" <> xRec."Variant Code" then begin
                    "Bin Code" := '';
                    if ("Location Code" <> '') and ("Item No." <> '') then begin
                        GetLocation("Location Code");
                        if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then
                            WMSManagement.GetDefaultBin("Item No.", "Variant Code", "Location Code", "Bin Code")
                    end;
                end;
                // P800127049
                GetItem;
                "Indirect Cost %" := Item.IndirectCostPct("Variant Code", "Location Code");
                // P800127049
                GetUnitAmount(FieldNo("Variant Code"));
                "Unit Cost" := Round(UnitCost * UOMCostFactor(), GLSetup."Unit-Amount Rounding Precision"); // P800127049
                Validate("Unit Amount");
                ReserveInvtDocLine.VerifyChange(Rec, xRec);

                if "Variant Code" = '' then
                    exit;

                ItemVariant.Get("Item No.", "Variant Code");
                Description := ItemVariant.Description;
            end;
        }
        field(5403; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';

            trigger OnLookup()
            var
                BinCode: Code[20];
            begin
                if (("Document Type" = "Document Type"::Shipment) and (Quantity >= 0)) or
                   (("Document Type" = "Document Type"::Receipt) and (Quantity < 0))
                then
                    BinCode := WMSManagement.BinContentLookUp("Location Code", "Item No.", "Variant Code", '', "Bin Code")
                else
                    BinCode := WMSManagement.BinLookUp("Location Code", "Item No.", "Variant Code", '');

                if BinCode <> '' then
                    Validate("Bin Code", BinCode);
            end;

            trigger OnValidate()
            begin
                if ("Bin Code" <> xRec."Bin Code") and ("Bin Code" <> '') then begin
                    if (("Document Type" = "Document Type"::Shipment) and (Quantity >= 0)) or
                       (("Document Type" = "Document Type"::Receipt) and (Quantity < 0))
                    then
                        WMSManagement.FindBinContent("Location Code", "Bin Code", "Item No.", "Variant Code", '')
                    else
                        WMSManagement.FindBin("Location Code", "Bin Code", '');

                    TestField("Location Code");
                    if "Bin Code" <> '' then begin
                        // P800127049
                        GetItem();
                        Item.TestField("Non-Warehouse Item", false);
                        // P800127049
                        GetLocation("Location Code");
                        Location.TestField("Bin Mandatory");
                        Location.TestField("Directed Put-away and Pick", false);
                        GetBin("Location Code", "Bin Code");
                        TestField("Location Code", Bin."Location Code");
                    end;

                    // P800127049
                    if CurrFieldNo = FieldNo("Bin Code") then begin
                        "FOOD Container License Plate" := '';
                        "FOOD Old License Plate" := '';
                        "FOOD Old Container ID" := '';
                        "FOOD New License Plate" := '';
                        "FOOD New Container ID" := '';
                    end;
                    // P800127049
                end;

                ReserveInvtDocLine.VerifyChange(Rec, xRec);
            end;
        }
        field(5404; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(5405; "Qty. Rounding Precision"; Decimal)
        {
            Caption = 'Qty. Rounding Precision';
            InitValue = 0;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 1;
            Editable = false;
        }
        field(5406; "Qty. Rounding Precision (Base)"; Decimal)
        {
            Caption = 'Qty. Rounding Precision (Base)';
            InitValue = 0;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 1;
            Editable = false;
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            begin
                GetItem();
                // P800127049
                if Item.TrackAlternateUnits() then
                    AltQtyMgmt.CheckUOMDifferentFromAltUOM(Item, "Unit of Measure Code", FieldCaption("Unit of Measure Code"));
                // P800127049
                "Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code");
                "Qty. Rounding Precision" := UOMMgt.GetQtyRoundingPrecision(Item, "Unit of Measure Code");
                "Qty. Rounding Precision (Base)" := UOMMgt.GetQtyRoundingPrecision(Item, Item."Base Unit of Measure");

                ReadGLSetup();
                // P800127049
                if TrackAlternateUnits() then
                    AltQtyMgmt.AdjustPerBaseAmount("Item No.", "Qty. per Unit of Measure");
                // P800127049
                "Unit Cost" := Round(UnitCost * "Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision");

                // P800127049
                if TrackAlternateUnits() then
                    AltQtyMgmt.RestorePerBaseAmount("Qty. per Unit of Measure");
                // P800127049
                Validate(Quantity);
                Validate("Unit Amount");
                "Net Weight" := Item."Net Weight" * "Qty. per Unit of Measure";
                "Gross Weight" := Item."Gross Weight" * "Qty. per Unit of Measure";
            end;
        }
        field(5413; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                TestField("Qty. per Unit of Measure", 1);
                Validate(Quantity, "Quantity (Base)");
            end;
        }
        field(5470; "Reserved Quantity Inbnd."; Decimal)
        {
            CalcFormula = Sum("Reservation Entry".Quantity WHERE("Source ID" = FIELD("Document No."),
                                                                  "Source Ref. No." = FIELD("Line No."),
                                                                  "Source Type" = CONST(5851),
                                                                  "Source Subtype" = FILTER("0" | "3"),
                                                                  "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Quantity Inbnd.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5471; "Reserved Quantity Outbnd."; Decimal)
        {
            CalcFormula = - Sum("Reservation Entry".Quantity WHERE("Source ID" = FIELD("Document No."),
                                                                   "Source Ref. No." = FIELD("Line No."),
                                                                   "Source Type" = CONST(5851),
                                                                   "Source Subtype" = FILTER("1" | "2"),
                                                                   "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Quantity Outbnd.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5472; "Reserved Qty. Inbnd. (Base)"; Decimal)
        {
            CalcFormula = Sum("Reservation Entry"."Quantity (Base)" WHERE("Source ID" = FIELD("Document No."),
                                                                           "Source Ref. No." = FIELD("Line No."),
                                                                           "Source Type" = CONST(5851),
                                                                           "Source Subtype" = FILTER("0" | "3"),
                                                                           "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Qty. Inbnd. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5473; "Reserved Qty. Outbnd. (Base)"; Decimal)
        {
            CalcFormula = - Sum("Reservation Entry"."Quantity (Base)" WHERE("Source ID" = FIELD("Document No."),
                                                                            "Source Ref. No." = FIELD("Line No."),
                                                                            "Source Type" = CONST(5851),
                                                                            "Source Subtype" = FILTER("1" | "2"),
                                                                            "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Qty. Outbnd. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5704; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";
        }
        field(5706; "Purchasing Code"; Code[10])
        {
            Caption = 'Purchasing Code';
            TableRelation = Purchasing;
        }
        field(5801; "Item Charge No."; Code[20])
        {
            Caption = 'Item Charge No.';
            TableRelation = "Item Charge";
        }
        field(5807; "Applies-from Entry"; Integer)
        {
            Caption = 'Applies-from Entry';
            MinValue = 0;

            trigger OnLookup()
            begin
                SelectItemEntry(FieldNo("Applies-from Entry"));
            end;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
            begin
                if "Applies-from Entry" <> 0 then begin
                    TestField(Quantity);
                    ItemLedgEntry.Get("Applies-from Entry");
                    "Location Code" := ItemLedgEntry."Location Code";
                    "Variant Code" := ItemLedgEntry."Variant Code";
                    "Unit Cost" := CalcUnitCost(ItemLedgEntry."Entry No.");
                    "Unit Amount" := "Unit Cost";
                    UpdateAmount();

                    if ItemLedgEntry.TrackingExists() then
                        Error(UseItemTrackingLinesErr, FieldCaption("Applies-from Entry"));
                end;
            end;
        }
        field(5811; "Applied Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Applied Amount';
            Editable = false;
        }
        field(5812; "Update Standard Cost"; Boolean)
        {
            Caption = 'Update Standard Cost';

            trigger OnValidate()
            begin
                GetItem();
                Item.TestField("Costing Method", Item."Costing Method"::Standard);
            end;
        }
        field(5813; "Amount (ACY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount (ACY)';
        }
        field(5819; "Applies-to Value Entry"; Integer)
        {
            Caption = 'Applies-to Value Entry';
        }
        field(12450; "FA No."; Code[20])
        {
            Caption = 'FA No.';
            TableRelation = "Fixed Asset";
        }
        field(12451; "FA Entry No."; Integer)
        {
            Caption = 'FA Entry No.';
            TableRelation = "FA Ledger Entry" WHERE("Entry No." = FIELD("FA Entry No."));
        }
        field(12452; "Depreciation Book Code"; Code[10])
        {
            Caption = 'Depreciation Book Code';
            TableRelation = "FA Depreciation Book"."Depreciation Book Code" WHERE("FA No." = FIELD("FA No."));
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
            MaintainSIFTIndex = false;
        }
        key(Key2; "Location Code")
        {
        }
        key(Key3; "Item No.", "Variant Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestStatusOpen();

        CalcFields("Reserved Qty. Inbnd. (Base)", "Reserved Qty. Outbnd. (Base)");
        TestField("Reserved Qty. Inbnd. (Base)", 0);
        TestField("Reserved Qty. Outbnd. (Base)", 0);

        ReserveInvtDocLine.DeleteLine(Rec);

        // P800127049
        if "FOOD Alt. Qty. Transaction No." <> 0 then
            AltQtyMgmt.DeleteAltQtyLines("FOOD Alt. Qty. Transaction No.");
        // P800127049
    end;

    trigger OnInsert()
    begin
        TestStatusOpen();
        ReserveInvtDocLine.VerifyQuantity(Rec, xRec);
        LockTable();
        InvtDocHeader."No." := '';

        UpdateLotTracking(true); // P800127049
    end;

    trigger OnModify()
    begin
        ReserveInvtDocLine.VerifyChange(Rec, xRec);
        UpdateLotTracking("Item No." <> xRec."Item No."); // P800127049
    end;

    trigger OnRename()
    begin
        Error(CannotBeRenamedErr, TableCaption);
    end;

    var
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        Text37002000: Label 'Item %1 is not allowed for container %2';
        Text37002001: Label 'Different lots for item %1 cannot be combined.';
        Text37002002: Label 'Container %1 cannot have multiple items.';
        Text37002003: Label 'Container has been assigned to %1 %2.';
        Text37002004: Label 'may not be edited';
        InvtDocHeader: Record "Invt. Document Header";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        GLSetup: Record "General Ledger Setup";
        SKU: Record "Stockkeeping Unit";
        Location: Record Location;
        Bin: Record Bin;
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        ReserveInvtDocLine: Codeunit "Invt. Doc. Line-Reserve";
        UOMMgt: Codeunit "Unit of Measure Management";
        DimMgt: Codeunit DimensionManagement;
        WMSManagement: Codeunit "WMS Management";
        CheckDateConflict: Codeunit "Reservation-Check Date Confl.";
        Reservation: Page Reservation;
        GLSetupRead: Boolean;
        UnitCost: Decimal;
        StatusCheckSuspended: Boolean;
        CannotBeNegativeErr: label '%1 cannot be negative.', Comment = '%1 - field caption';
        CannotBeRenamedErr: Label '%1 cannot be renamed.', Comment = '%1 - table caption';
        CannotChangeCostErr: Label 'You cannot change %1 when Costing Method is %2.', Comment = '%1 - field caption, %2 - costing method value';
        UseItemTrackingLinesErr: Label 'You must use page Item Tracking Lines to enter %1, if item tracking is used.', Comment = '%1 - field caption';
        CannotReserveAutomaticallyErr: Label 'Quantity %1 in line %2 cannot be reserved automatically.', Comment = '%1 - quantity, %2 - line number';
        DocumentLineTxt: Label '%1 %2 %3', Locked = true;

    // P800127049
    procedure TrackAlternateUnits(): Boolean
    begin
        GetItem();
        exit(Item.TrackAlternateUnits());
    end;

    // P800127049
    procedure CostInAlternateUnits(): Boolean
    begin
        GetItem();
        exit(Item.CostInAlternateUnits());
    end;

    // P800127049
    procedure PriceInAlternateUnits(): Boolean
    begin
        GetItem();
        exit(Item.PriceInAlternateUnits());
    end;

    // P800127049
    procedure GetPricingQty(FldNo: Integer): Decimal
    begin
        if PriceInAlternateUnits() then
            case FldNo of
                FieldNo(Quantity), FieldNo("Quantity (Base)"):
                    exit("FOOD Quantity (Alt.)");
            end;

        case FldNo of
            FieldNo(Quantity):
                exit(Quantity);
        end;
    end;

    // P800127049
    local procedure UOMCostFactor(): Decimal
    begin
        if Item.CostInAlternateUnits() then
            exit(1)
        else
            exit("Qty. per Unit of Measure");
    end;

    // P800127049
    procedure GetLotNo()
    var
        ProcessFns: Codeunit "Process 800 Functions";
        EasyLotTracking: Codeunit "Easy Lot Tracking";
    begin
        if ProcessFns.TrackingInstalled() then begin
            EasyLotTracking.SetInvtDocLine(Rec);
            "FOOD Lot No." := EasyLotTracking.GetLotNo();
            if "Document Type" = "Document Type"::Receipt then begin
                "FOOD Creation Date" := EasyLotTracking.GetLotCreationDate("FOOD Lot No.");
                "FOOD Country/Reg of Orig Code" := EasyLotTracking.GetCountryOfOrigin("FOOD Lot No.");
            end;
        end;
    end;

    // P800127049
    procedure UpdateLotTracking(ForceUpdate: Boolean)
    var
        ProcessFns: Codeunit "Process 800 Functions";
        P800Globals: Codeunit "Process 800 System Globals";
        EasyLotTracking: Codeunit "Easy Lot Tracking";
    begin
        if (CurrFieldNo = 0) and (not ForceUpdate) then
            exit;
        if ("FOOD Lot No." = P800Globals.MultipleLotCode()) or (not ProcessFns.TrackingInstalled()) or
          (("FOOD Lot No." = '') and (("Line No." <> xRec."Line No.") or (xRec."FOOD Lot No." = '')))
        then
            exit;

        EasyLotTracking.TestInvtDocLine(Rec);
        if "Line No." = 0 then
            exit;

        EasyLotTracking.SetInvtDocLine(Rec);
        if (xRec."Document Type" = 0) and (xRec."Document No." = '') and (xRec."Line No." = 0) then
            xRec."FOOD Lot No." := "FOOD Lot No.";
        EasyLotTracking.SetLotCreationDate(xRec."FOOD Creation Date", "FOOD Creation Date");
        EasyLotTracking.SetCountryOfOrigin(xRec."FOOD Country/Reg of Orig Code", "FOOD Country/Reg of Orig Code");
        EasyLotTracking.ReplaceTracking(xRec."FOOD Lot No.", "FOOD Lot No.", "FOOD Alt. Qty. Transaction No.",
          "Quantity (Base)", "Quantity (Base)", "FOOD Quantity (Alt.)", "Quantity (Base)");
    end;

    // P800127049
    local procedure CheckOldContainer()
    var
        ContainerLine: Record "Container Line";
    begin
        if "FOOD Old Container ID" <> '' then begin
            ContainerLine.SetRange("Container ID", "FOOD Old Container ID");
            if "Item No." <> '' then
                ContainerLine.SetRange("Item No.", "Item No.");
            if "Variant Code" <> '' then
                ContainerLine.SetRange("Variant Code", "Variant Code");
            if "Unit of Measure Code" <> '' then
                ContainerLine.SetRange("Unit of Measure Code", "Unit of Measure Code");
            if "FOOD Lot No." <> '' then
                ContainerLine.SetRange("Lot No.", "FOOD Lot No.");
            ContainerLine.SetFilter(Quantity, '>0');
            ContainerLine.FindFirst();
        end;
    end;

    // P800127049
    local procedure CheckNewContainer()
    var
        Item: Record Item;
        ContainerHeader: Record "Container Header";
        ContainerLine: Record "Container Line";
        ContainerUsage: Record "Container Type Usage";
        ContainerFns: Codeunit "Container Functions";
    begin
        if "FOOD New Container ID" <> '' then begin
            TestField("Item No.");
            TestField("Unit of Measure Code");
            ContainerHeader.Get("FOOD New Container ID");

            Item.Get("Item No.");
            if not ContainerFns.GetContainerUsage(ContainerHeader."Container Type Code", Item."No.", Item."Item Category Code",
              "Unit of Measure Code", true, ContainerUsage)
            then
                Error(Text37002000, Item."No.", "FOOD New License Plate");

            if ContainerHeader."Document Type" = 0 then begin
                ContainerLine.SetRange("Container ID", "FOOD New Container ID");
                ContainerLine.SetFilter("Item No.", '<>%1', "Item No.");
                if not ContainerLine.IsEmpty() then
                    Error(Text37002002, "FOOD New License Plate");

                if ContainerUsage."Single Lot" and ("FOOD Lot No." <> '') then begin
                    ContainerLine.SetRange("Item No.");
                    ContainerLine.SetFilter("Lot No.", '<>%1', "FOOD Lot No.");
                    ContainerLine.SetFilter("Variant Code", '<>%1', "Variant Code");
                    if not ContainerLine.IsEmpty() then
                        Error(Text37002001, "Item No.");
                end;
            end;
        end;
    end;

    procedure EmptyLine(): Boolean
    begin
        exit(
          (Quantity = 0) and
          ("FOOD Quantity (Alt.)" = 0) and // P800127049
          ("Item No." = ''));
    end;

    local procedure CalcBaseQty(Qty: Decimal; FromFieldName: Text; ToFieldName: Text): Decimal
    begin
        TestField("Qty. per Unit of Measure");
        exit(UOMMgt.CalcBaseQty(
            '', '', "Unit of Measure Code", Qty, "Qty. per Unit of Measure", "Qty. Rounding Precision (Base)", FieldCaption("Qty. Rounding Precision"), FromFieldName, ToFieldName));
    end;

    procedure UpdateAmount()
    begin
        Amount := Round(GetPricingQty(FieldNo(Quantity)) * "Unit Amount"); // P800127049
    end;

    local procedure SelectItemEntry(CurrentFieldNo: Integer)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemDocLine2: Record "Invt. Document Line";
    begin
        ItemLedgEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code");
        ItemLedgEntry.SetRange("Item No.", "Item No.");
        ItemLedgEntry.SetRange(Correction, false);
        if "Location Code" <> '' then
            ItemLedgEntry.SetRange("Location Code", "Location Code");

        if CurrentFieldNo = FieldNo("Applies-to Entry") then begin
            ItemLedgEntry.SetRange(Positive, true);
            ItemLedgEntry.SetRange(Open, true);
        end else
            ItemLedgEntry.SetRange(Positive, false);

        if PAGE.RunModal(PAGE::"Item Ledger Entries", ItemLedgEntry) = ACTION::LookupOK then begin
            ItemDocLine2 := Rec;
            if CurrentFieldNo = FieldNo("Applies-to Entry") then
                ItemDocLine2.Validate("Applies-to Entry", ItemLedgEntry."Entry No.")
            else
                ItemDocLine2.Validate("Applies-from Entry", ItemLedgEntry."Entry No.");
            CheckItemAvailable(CurrentFieldNo);
            Rec := ItemDocLine2;
        end;
    end;

    procedure CheckItemAvailable(CalledByFieldNo: Integer)
    begin
        if (CurrFieldNo = 0) or (CurrFieldNo <> CalledByFieldNo) then // Prevent two checks on quantity
            exit;

        if (CurrFieldNo <> 0) and ("Item No." <> '') and (Quantity <> 0) then
            ItemCheckAvail.InvtDocCheckLine(Rec);
    end;

    procedure GetInvtDocHeader()
    begin
        TestField("Document No.");
        if ("Document Type" <> InvtDocHeader."Document Type") or ("Document No." <> InvtDocHeader."No.") then
            InvtDocHeader.Get("Document Type", "Document No.");
    end;

    local procedure GetItem()
    begin
        if Item."No." <> "Item No." then
            Item.Get("Item No.");
    end;

    procedure GetUnitAmount(CalledByFieldNo: Integer)
    begin
        RetrieveCosts();
        "Unit Cost" := UnitCost;

        case "Document Type" of
            "Document Type"::Receipt:
                "Unit Amount" := FindInvtDocLinePrice(CalledByFieldNo);
            "Document Type"::Shipment:
                "Unit Amount" := UnitCost * "Qty. per Unit of Measure";
        end;
    end;

    local procedure FindInvtDocLinePrice(CalledByFieldNo: Integer): Decimal
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        ItemJournalLine.Init();
        ItemJournalLine."Posting Date" := "Posting Date";
        ItemJournalLine."Item No." := "Item No.";
        ItemJournalLine."Variant Code" := "Variant Code";
        ItemJournalLine."Location Code" := "Location Code";
        ItemJournalLine."Unit of Measure Code" := "Unit of Measure Code";
        ItemJournalLine."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
        ItemJournalLine."Price Calculation Method" := GetDefaultPriceCalculationMethod();
        ItemJournalLine.Quantity := Quantity;

        case CalledByFieldNo of
            FieldNo("Variant Code"):
                CalledByFieldNo := ItemJournalLine.FieldNo("Variant Code");
            FieldNo(Quantity):
                CalledByFieldNo := ItemJournalLine.FieldNo(Quantity);
            FieldNo("Location Code"):
                CalledByFieldNo := ItemJournalLine.FieldNo("Location Code");
        end;
        ItemJournalLine.ApplyPrice("Price Type"::Purchase, CalledByFieldNo);
        exit(ItemJournalLine."Unit Amount");
    end;

    local procedure GetDefaultPriceCalculationMethod(): Enum "Price Calculation Method";
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        exit(PurchasesPayablesSetup."Price Calculation Method");
    end;

    local procedure TestStatusOpen()
    begin
        if StatusCheckSuspended then
            exit;

        GetInvtDocHeader();
        InvtDocHeader.TestField(Status, InvtDocHeader.Status::Open);
    end;

    procedure ShowReservation()
    begin
        TestField("Item No.");
        Clear(Reservation);
        Reservation.SetReservSource(Rec);
        Reservation.RunModal();
    end;

    procedure OpenItemTrackingLines()
    begin
        ReserveInvtDocLine.CallItemTracking(Rec);
        // P800127049
        Get("Document Type", "Document No.", "Line No.");
        if TrackAlternateUnits() then
            AltQtyMgmt.UpdateInvtDocLine(Rec);
        GetLotNo();
        Modify();
        // P800127049
    end;

#if not CLEAN20
    [Obsolete('Replaced by CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])', '20.0')]
    procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20])
    var
        SourceCodeSetup: Record "Source Code Setup";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        SourceCodeSetup.Get();
        TableID[1] := Type1;
        No[1] := No1;
        TableID[2] := Type2;
        No[2] := No2;
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        GetInvtDocHeader();
        "Dimension Set ID" :=
          DimMgt.GetDefaultDimID(
            TableID, No, "Source Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code",
            InvtDocHeader."Dimension Set ID", DATABASE::"Invt. Document Header");
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;
#endif

    procedure CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        GetInvtDocHeader();
        "Dimension Set ID" :=
          DimMgt.GetDefaultDimID(
            DefaultDimSource, "Source Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code",
            InvtDocHeader."Dimension Set ID", DATABASE::"Invt. Document Header");
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    procedure ShowDimensions()
    begin
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet("Dimension Set ID", StrSubstNo(DocumentLineTxt, "Document Type", "Document No.", "Line No."));
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        ValidateShortcutDimCode(FieldNumber, ShortcutDimCode);
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    local procedure ReadGLSetup()
    begin
        if not GLSetupRead then begin
            GLSetup.Get();
            GLSetupRead := true;
        end;
    end;

    local procedure GetSKU(): Boolean
    begin
        if (SKU."Location Code" = "Location Code") and
           (SKU."Item No." = "Item No.") and
           (SKU."Variant Code" = "Variant Code")
        then
            exit(true);

        if SKU.Get("Location Code", "Item No.", "Variant Code") then
            exit(true);

        exit(false);
    end;

    local procedure RetrieveCosts()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeRetrieveCosts(Rec, UnitCost, IsHandled);
        if IsHandled then
            exit;

        ReadGLSetup();
        GetItem();
        if GetSKU() then
            UnitCost := SKU."Unit Cost"
        else
            UnitCost := Item."Unit Cost";

        if Item."Costing Method" <> Item."Costing Method"::Standard then
            UnitCost := Round(UnitCost, GLSetup."Unit-Amount Rounding Precision");
    end;

    local procedure CalcUnitCost(ItemLedgEntryNo: Integer): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry"; // P800127049
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.Reset();
        ValueEntry.SetCurrentKey("Item Ledger Entry No.");
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgEntryNo);
        // P800127049
        // ValueEntry.CalcSums("Invoiced Quantity", "Cost Amount (Actual)");
        ValueEntry.CalcSums("Cost Amount (Actual)");
        ItemLedgerEntry.Get(ItemLedgEntryNo);
        if ItemLedgerEntry.GetCostingQty() <> 0 then
            exit(ValueEntry."Cost Amount (Actual)" / ItemLedgerEntry.GetCostingQty() * UOMCostFactor());
        // P800127049
        exit(0);
    end;

    procedure RowID1(): Text[250]
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        exit(
            ItemTrackingMgt.ComposeRowID(DATABASE::"Invt. Document Line",
            "Document Type".AsInteger(), "Document No.", '', 0, "Line No."));
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Clear(Location)
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);
    end;

    local procedure GetBin(LocationCode: Code[10]; BinCode: Code[20])
    begin
        if BinCode = '' then
            Clear(Bin)
        else
            if Bin.Code <> BinCode then
                Bin.Get(LocationCode, BinCode);
    end;

    procedure SuspendStatusCheck(Suspend: Boolean)
    begin
        StatusCheckSuspended := Suspend;
    end;

    procedure Signed(Value: Decimal): Decimal
    begin
        case "Document Type" of
            "Document Type"::Receipt:
                exit(Value);
            "Document Type"::Shipment:
                exit(-Value);
        end;
    end;

    procedure ReserveFromInventory(var InvtDocLine: Record "Invt. Document Line")
    var
        ReservMgt: Codeunit "Reservation Management";
        AutoReserv: Boolean;
    begin
        if InvtDocLine.FindSet() then
            repeat
                InvtDocLine.TestField("Posting Date");
                ReservMgt.SetReservSource(InvtDocLine);
                InvtDocLine.CalcFields("Reserved Qty. Outbnd. (Base)");
                ReservMgt.AutoReserveToShip(
                  AutoReserv, '', InvtDocLine."Posting Date",
                  InvtDocLine.Quantity - InvtDocLine."Reserved Quantity Outbnd.",
                  InvtDocLine."Quantity (Base)" - InvtDocLine."Reserved Qty. Outbnd. (Base)");
                if not AutoReserv then
                    Error(CannotReserveAutomaticallyErr, InvtDocLine."Quantity (Base)", InvtDocLine."Line No.");
            until InvtDocLine.Next() = 0;
    end;

    procedure GetRemainingQty(var RemainingQty: Decimal; var RemainingQtyBase: Decimal; Direction: Integer)
    begin
        case Direction of
            1: // Shipment
                begin
                    CalcFields("Reserved Quantity Outbnd.", "Reserved Qty. Outbnd. (Base)");
                    RemainingQty := Quantity - Abs("Reserved Quantity Outbnd.");
                    RemainingQtyBase := "Quantity (Base)" - Abs("Reserved Qty. Outbnd. (Base)");
                end;
            0: // Receipt
                begin
                    CalcFields("Reserved Quantity Inbnd.", "Reserved Qty. Inbnd. (Base)");
                    RemainingQty := Quantity - Abs("Reserved Quantity Inbnd.");
                    RemainingQtyBase := "Quantity (Base)" - Abs("Reserved Qty. Inbnd. (Base)");
                end;
        end;
    end;

    procedure GetReservationQty(var QtyReserved: Decimal; var QtyReservedBase: Decimal; var QtyToReserve: Decimal; var QtyToReserveBase: Decimal; SourceSubtype: Integer): Decimal
    begin
        if SourceSubtype = 0 then begin // Inbound
            CalcFields("Reserved Quantity Inbnd.", "Reserved Qty. Inbnd. (Base)");
            QtyReserved := "Reserved Quantity Inbnd.";
            QtyReservedBase := "Reserved Qty. Inbnd. (Base)";
            QtyToReserve := Quantity;
            QtyToReserveBase := "Quantity (Base)";
        end else begin // Outbound
            CalcFields("Reserved Quantity Outbnd.", "Reserved Qty. Outbnd. (Base)");
            QtyReserved := "Reserved Quantity Outbnd.";
            QtyReservedBase := "Reserved Qty. Outbnd. (Base)";
            QtyToReserve := Quantity;
            QtyToReserveBase := "Quantity (Base)";
        end;
        exit("Qty. per Unit of Measure");
    end;

    procedure GetSourceCaption(): Text
    begin
        exit(StrSubstNo(DocumentLineTxt, "Document No.", "Line No.", "Item No."));
    end;

    procedure FilterReceiptLinesForReservation(ReservationEntry: Record "Reservation Entry"; AvailabilityFilter: Text; Positive: Boolean)
    begin
        Reset();
        SetCurrentKey("Location Code");
        SetRange("Item No.", ReservationEntry."Item No.");
        SetRange("Variant Code", ReservationEntry."Variant Code");
        SetRange("Location Code", ReservationEntry."Location Code");
        SetRange("Document Type", "Document Type"::Receipt);
        SetFilter("Document Date", AvailabilityFilter);
        if Positive then
            SetFilter("Quantity (Base)", '>0')
        else
            SetFilter("Quantity (Base)", '<0');

        OnAfterFilterReceiptLinesForReservation(Rec, ReservationEntry, AvailabilityFilter, Positive);
    end;

    procedure FilterShipmentLinesForReservation(ReservationEntry: Record "Reservation Entry"; AvailabilityFilter: Text; Positive: Boolean)
    begin
        Reset();
        SetCurrentKey("Location Code");
        SetRange("Item No.", ReservationEntry."Item No.");
        SetRange("Variant Code", ReservationEntry."Variant Code");
        SetRange("Location Code", ReservationEntry."Location Code");
        SetRange("Document Type", "Document Type"::Shipment);
        SetFilter("Document Date", AvailabilityFilter);
        if Positive then
            SetFilter("Quantity (Base)", '<0')
        else
            SetFilter("Quantity (Base)", '>0');

        OnAfterFilterShipmentLinesForReservation(Rec, ReservationEntry, AvailabilityFilter, Positive);
    end;

    procedure ReservEntryExist(): Boolean
    var
        ReservEntry: Record "Reservation Entry";
    begin
        ReservEntry.InitSortingAndFilters(false);
        SetReservationFilters(ReservEntry);
        exit(not ReservEntry.IsEmpty);
    end;

    procedure SetReservationEntry(var ReservEntry: Record "Reservation Entry")
    begin
        ReservEntry.SetSource(DATABASE::"Invt. Document Line", "Document Type".AsInteger(), "Document No.", "Line No.", '', 0);
        ReservEntry.SetItemData("Item No.", Description, "Location Code", "Variant Code", "Qty. per Unit of Measure");
        ReservEntry."Expected Receipt Date" := "Document Date";
        ReservEntry."Shipment Date" := "Document Date";
    end;

    procedure SetReservationFilters(var ReservEntry: Record "Reservation Entry")
    begin
        ReservEntry.SetSourceFilter(DATABASE::"Invt. Document Line", "Document Type".AsInteger(), "Document No.", "Line No.", false);
        ReservEntry.SetSourceFilter('', 0);
    end;

    procedure CreateDimFromDefaultDim(FieldNo: Integer)
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        InitDefaultDimensionSources(DefaultDimSource, FieldNo);
        CreateDim(DefaultDimSource);
    end;

    local procedure InitDefaultDimensionSources(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    begin
        DimMgt.AddDimSource(DefaultDimSource, Database::Item, Rec."Item No.", FieldNo = Rec.FieldNo("Item No."));
        DimMgt.AddDimSource(DefaultDimSource, Database::"Salesperson/Purchaser", Rec."Salespers./Purch. Code", FieldNo = Rec.FieldNo("Salespers./Purch. Code"));
        DimMgt.AddDimSource(DefaultDimSource, Database::Location, Rec."Location Code", FieldNo = Rec.FieldNo("Location Code"));

        OnAfterInitDefaultDimensionSources(Rec, DefaultDimSource, FieldNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitDefaultDimensionSources(var InvtDocumentLine: Record "Invt. Document Line"; var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFilterReceiptLinesForReservation(var InvtDocumentLine: Record "Invt. Document Line"; ReservationEntry: Record "Reservation Entry"; AvailabilityFilter: Text; Positive: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFilterShipmentLinesForReservation(var InvtDocumentLine: Record "Invt. Document Line"; ReservationEntry: Record "Reservation Entry"; AvailabilityFilter: Text; Positive: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRetrieveCosts(var InvtDocumentLine: Record "Invt. Document Line"; var UnitCost: Decimal; var IsHandled: Boolean)
    begin
    end;
}

