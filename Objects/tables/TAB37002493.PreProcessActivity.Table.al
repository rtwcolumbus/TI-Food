table 37002493 "Pre-Process Activity"
{
    // PRW16.00.06
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Add Pre-Process functionality
    // 
    // PRW17.00
    // P8001142, Columbus IT, Don Bresee, 09 MAR 13
    //   Rework Replenishment logic
    // 
    // PRW17.00.01
    // P8001164, Columbus IT, Jack Reynolds, 28 MAY 13
    //   Enlarge description to 50 characters
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW119.0
    // P800133109, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 19.0 - Qty. Rounding Precision

    Caption = 'Pre-Process Activity';
    DrillDownPageID = "Pre-Process Activity List";
    LookupPageID = "Pre-Process Activity List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Prod. Order Status"; Option)
        {
            Caption = 'Prod. Order Status';
            Editable = false;
            OptionCaption = 'Simulated,Planned,Firm Planned,Released,Finished';
            OptionMembers = Simulated,Planned,"Firm Planned",Released,Finished;
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
            Editable = false;
            TableRelation = "Prod. Order Line"."Line No." WHERE(Status = FIELD("Prod. Order Status"),
                                                                 "Prod. Order No." = FIELD("Prod. Order No."));
        }
        field(5; "Prod. Order Comp. Line No."; Integer)
        {
            Caption = 'Prod. Order Comp. Line No.';
            Editable = false;
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

            trigger OnValidate()
            var
                StageArea: Record "Replenishment Area";
            begin
                StageArea.Get("Location Code", "Replenishment Area Code");
                "To Bin Code" := StageArea."To Bin Code";
                "From Bin Code" := StageArea."From Bin Code";
            end;
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;

            trigger OnValidate()
            begin
                GetItem("Item No.");
                Validate("Variant Code", '');
                Validate("Unit of Measure Code", Item."Base Unit of Measure");
            end;
        }
        field(11; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            begin
                GetItem("Item No.");
                if "Variant Code" = '' then
                    Description := Item.Description
                else begin
                    ItemVariant.Get("Item No.", "Variant Code");
                    Description := ItemVariant.Description;
                end;
            end;
        }
        field(12; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(13; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            var
                AltQtyMgmt: Codeunit "Alt. Qty. Management";
            begin
                GetItem("Item No.");
                "Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code");
                UOMMgt.GetQtyRoundingPrecision(Item, "Unit of Measure Code", "Qty. Rounding Precision", "Qty. Rounding Precision (Base)"); // P800133109
                Validate(Quantity);
            end;
        }
        field(14; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
        }
        // P800133109
        field(15; "Qty. Rounding Precision"; Decimal)
        {
            Caption = 'Qty. Rounding Precision';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        // P800133109
        field(16; "Qty. Rounding Precision (Base)"; Decimal)
        {
            Caption = 'Qty. Rounding Precision (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(18; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            MinValue = 0;

            trigger OnValidate()
            begin
                // P800133109
                Quantity := UOMMgt.RoundAndValidateQty(Quantity, "Qty. Rounding Precision", FieldCaption(Quantity));
                "Quantity (Base)" := CalcBaseQty(Quantity, FieldCaption(Quantity), FieldCaption("Quantity (Base)"));
                // P800133109
                InitRemaining;
                UpdateQtyToProcess;
            end;
        }
        field(19; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(21; "Remaining Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Remaining Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(22; "Remaining Qty. (Base)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Remaining Qty. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(24; "Qty. to Process"; Decimal)
        {
            BlankZero = true;
            Caption = 'Qty. to Process';
            DecimalPlaces = 0 : 5;
            Editable = false;
            MinValue = 0;

            trigger OnValidate()
            begin
                if ("Qty. to Process" > "Remaining Quantity") then
                    Error(Text002, FieldCaption("Qty. to Process"), "Remaining Quantity", FieldCaption("Remaining Quantity"));
                "Qty. to Process (Base)" := CalcBaseQty("Qty. to Process" + "Quantity Processed", FieldCaption("Qty. to Process"), FieldCaption("Qty. to Process (Base)")) - "Qty. Processed (Base)"; // P800133109
            end;
        }
        field(25; "Qty. to Process (Base)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Qty. to Process (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(31; "To Bin Code"; Code[20])
        {
            Caption = 'To Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
        }
        field(32; "From Bin Code"; Code[20])
        {
            Caption = 'From Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
        }
        field(33; "Quantity Processed"; Decimal)
        {
            BlankZero = true;
            Caption = 'Quantity Processed';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(34; "Qty. Processed (Base)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Qty. Processed (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(40; "Pre-Process Type Code"; Code[10])
        {
            Caption = 'Pre-Process Type Code';
            Editable = false;
            TableRelation = "Pre-Process Type";

            trigger OnValidate()
            var
                PreProcType: Record "Pre-Process Type";
            begin
                PreProcType.Get("Pre-Process Type Code");
                Blending := PreProcType.Blending;
                "Order Specific" := PreProcType."Order Specific";
                "Auto Complete" := PreProcType."Auto Complete";
            end;
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

            trigger OnValidate()
            begin
                if not "Order Specific" then
                    if (Blending <> Blending::" ") then
                        FieldError(Blending);
            end;
        }
        field(43; "Auto Complete"; Boolean)
        {
            Caption = 'Auto Complete';

            trigger OnValidate()
            begin
                if "Auto Complete" then
                    TestField(Blending, Blending::"Per Order");
            end;
        }
        field(44; "Blending Order Status"; Option)
        {
            Caption = 'Blending Order Status';
            Editable = false;
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
            SumIndexFields = "Remaining Quantity";
        }
        key(Key3; "Blending Order Status", "Blending Order No.")
        {
            SumIndexFields = "Remaining Quantity", "Remaining Qty. (Base)", "Qty. to Process (Base)";
        }
        key(Key4; "Location Code", "Starting Date", "Prod. Order Status", Blending)
        {
        }
        key(Key5; "Item No.", "Variant Code", "Unit of Measure Code", "Replenishment Area Code", "Location Code", "Starting Date")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        BlendOrder: Record "Production Order";
    begin
        if ("Blending Order Status" < "Blending Order Status"::Finished) and ("Blending Order No." <> '') then
            case Blending of
                Blending::"Per Order":
                    if BlendOrder.Get("Blending Order Status", "Blending Order No.") then begin
                        BlendOrder.Delete(true);
                        Find;
                    end;
                Blending::"Per Item":
                    if not Confirm(Text003, false) then
                        Error('');
            end;

        ActivityLine.Reset;
        ActivityLine.SetRange("Activity No.", "No.");
        ActivityLine.DeleteAll;
    end;

    trigger OnInsert()
    var
        ProcessSetup: Record "Process Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        ProcessSetup.Get;

        if "No." = '' then begin
            ProcessSetup.TestField("Pre-Process Activity Nos.");
            NoSeriesMgt.InitSeries(ProcessSetup."Pre-Process Activity Nos.", xRec."No. Series", WorkDate, "No.", "No. Series");
        end;
    end;

    var
        ActivityLine: Record "Pre-Process Activity Line";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        UOMMgt: Codeunit "Unit of Measure Management";
        Text001: Label '%1 cannot be less than %2 (%3)';
        Text002: Label '%1 cannot be more than %2 (%3)';
        Text003: Label 'This activity is part of a Per Item Blending Order, the Blending Order will NOT be deleted. Continue?';
        Text004: Label ' may not be edited.';
        Text005: Label 'There is Quantity remaining, are you sure you want to complete this activity?';
        Text006: Label 'A Blend Order exists for this Activity, do you want to mark it as Finished?';
        Text007: Label 'There is no quantity to Process on %1 Order %2 Line %3 Component Line %4';

    local procedure CalcBaseQty(Qty: Decimal; FromFieldName: Text; ToFieldName: Text): Decimal
    begin
        // P800133109
        exit(UOMMgt.CalcBaseQty(
            "No.", "Variant Code", "Unit of Measure Code", Qty, "Qty. per Unit of Measure", "Qty. Rounding Precision (Base)", FieldCaption("Qty. Rounding Precision"), FromFieldName, ToFieldName));
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        if (Item."No." <> ItemNo) then
            Item.Get(ItemNo);
    end;

    procedure InitRemaining()
    begin
        "Remaining Quantity" := Quantity - "Quantity Processed";
        "Remaining Qty. (Base)" := "Quantity (Base)" - "Qty. Processed (Base)";
    end;

    procedure IsLotTracked(): Boolean
    begin
        GetItem("Item No.");
        exit(Item."Item Tracking Code" <> '');
    end;

    procedure InitFromComponent(var ProdOrderComp: Record "Prod. Order Component")
    var
        ReplenArea: Record "Replenishment Area";
        QtyToProcess: Decimal;
    begin
        ProdOrderComp.TestField("Pre-Process Type Code");
        QtyToProcess := ProdOrderComp.GetQtyToPreProcess();
        if (QtyToProcess <= 0) then
            Error(Text007, "Prod. Order Status", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Comp. Line No.");

        "Prod. Order Status" := ProdOrderComp.Status;
        "Prod. Order No." := ProdOrderComp."Prod. Order No.";
        "Prod. Order Line No." := ProdOrderComp."Prod. Order Line No.";
        "Prod. Order Comp. Line No." := ProdOrderComp."Line No.";

        ProdOrderComp.TestField("Replenishment Area Code");                                    // P8001142
        ReplenArea.Get(ProdOrderComp."Location Code", ProdOrderComp."Replenishment Area Code"); // P8001142

        Validate("Pre-Process Type Code", ProdOrderComp."Pre-Process Type Code");
        Validate("Item No.", ProdOrderComp."Item No.");
        if (ProdOrderComp."Variant Code" <> '') then
            Validate("Variant Code", ProdOrderComp."Variant Code");
        Validate("Unit of Measure Code", ProdOrderComp."Unit of Measure Code");
        Validate(Quantity, QtyToProcess);
        Validate("Location Code", ReplenArea."Location Code");
        Validate("Replenishment Area Code", ReplenArea."Pre-Process Repl. Area Code");
    end;

    procedure ShowProdOrder(OrderStatus: Integer; OrderNo: Code[20])
    var
        ProdOrder: Record "Production Order";
    begin
        if ProdOrder.Get(OrderStatus, OrderNo) then begin
            ProdOrder.SetRecFilter;
            case ProdOrder.Status of
                ProdOrder.Status::Simulated:
                    PAGE.RunModal(PAGE::"Simulated Production Order", ProdOrder);
                ProdOrder.Status::Planned:
                    PAGE.RunModal(PAGE::"Planned Production Order", ProdOrder);
                ProdOrder.Status::"Firm Planned":
                    PAGE.RunModal(PAGE::"Firm Planned Prod. Order", ProdOrder);
                ProdOrder.Status::Released:
                    PAGE.RunModal(PAGE::"Released Production Order", ProdOrder);
                ProdOrder.Status::Finished:
                    PAGE.RunModal(PAGE::"Finished Production Order", ProdOrder);
            end;
        end;
    end;

    procedure UpdateQtyToProcess()
    begin
        ActivityLine.Reset;
        ActivityLine.SetRange("Activity No.", "No.");
        ActivityLine.CalcSums("Qty. to Process", "Qty. to Process (Base)");
        "Qty. to Process" := ActivityLine."Qty. to Process";
        "Qty. to Process (Base)" := ActivityLine."Qty. to Process (Base)";
    end;

    procedure ReduceFromBinQtys(BinCode: Code[20]; LotNo: Code[50]; var Qty: Decimal; var QtyBase: Decimal)
    var
        BinQty: Decimal;
        BinQtyBase: Decimal;
    begin
        GetLotBinQtys(BinCode, LotNo, BinQty, BinQtyBase);
        if (QtyBase > BinQtyBase) then begin
            QtyBase := BinQtyBase;
            Qty := BinQty;
        end;
    end;

    procedure GetLotBinQtys(BinCode: Code[20]; LotNo: Code[50]; var BinQty: Decimal; var BinQtyBase: Decimal)
    var
        WhseEntry: Record "Warehouse Entry";
        Location: Record Location;
    begin
        WhseEntry.SetCurrentKey(
          "Location Code", "Bin Code", "Item No.", "Variant Code",
          "Unit of Measure Code", Open, "Lot No.", "Serial No.");
        Location.Get("Location Code");
        WhseEntry.SetRange("Location Code", Location.Code);
        if (BinCode <> '') then
            WhseEntry.SetRange("Bin Code", BinCode)
        else
            WhseEntry.SetRange("Bin Code", "To Bin Code");
        WhseEntry.SetRange("Item No.", "Item No.");
        if ("Variant Code" <> '') then
            WhseEntry.SetRange("Variant Code", "Variant Code");
        if (Location.LocationType() = 3) then
            WhseEntry.SetRange("Unit of Measure Code", "Unit of Measure Code");
        WhseEntry.SetRange(Open, true);
        if (LotNo <> '') then
            WhseEntry.SetRange("Lot No.", LotNo);
        WhseEntry.CalcSums("Remaining Quantity", "Remaining Qty. (Base)");
        BinQtyBase := WhseEntry."Remaining Qty. (Base)";
        if (Location.LocationType() = 3) then
            BinQty := WhseEntry."Remaining Quantity"
        else
            BinQty := Round(WhseEntry."Remaining Quantity" / "Qty. per Unit of Measure", 0.00001);
    end;
}

