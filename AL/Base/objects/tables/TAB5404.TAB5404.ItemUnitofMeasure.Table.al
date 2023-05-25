table 5404 "Item Unit of Measure"
{
    // PR1.00
    //   New Process 800 fields
    //     Type
    //   When Qty. per Unit of Measure changes adjust other records of same type
    //   Modify validation for Code to set Qty. per Unit of Measure if possible based upon
    //     other entries of the same type
    // 
    // PR3.10
    //   Change UOM Entry Interface
    // 
    // PR3.60
    //   New Fields
    //     Break Charge
    //     Base Quantity
    //     Equivalent UOM Qty.
    //   Update Item Specific Gravity on changes to item unit of measure
    // 
    // PR3.61
    //   Add Fields
    //     Tare Weight
    //     Tare Unit of Measure
    // 
    // PR3.70.03
    //   Add Field
    //     Rounding Precision
    // 
    // PR3.70.07
    // P8000155A, Myers Nissi, Jack Reynolds, 10 DEC 04
    //   Resore 5 decimal place precision on Qty. per Unit of Measure
    // 
    // PR3.70.10
    // P8000218A, Myers Nissi, Jack Reynolds, 06 JUN 05
    //   Reverse the changes from P8000155A
    // 
    // PR5.00
    // P8000494A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Change Local to No for GetUOMDescription
    // 
    // PRW15.00.01
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Add Break Charge Method and related logic
    // 
    // P8000555A, VerticalSoft, Jack Reynolds, 02 JAN 08
    //   Modifying record causes Specific Gravity validation on item record to use old values from Item UOM record
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Bug fix - calculate weight on validate of "Equivalent UOM Qty."
    // 
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Change DropDown field group
    // 
    // PRW16.00.01
    // P8000720, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Change call to ModifyItemUOM
    // 
    // PRW16.00.05
    // P8000981, Columbus IT, Don Bresee, 20 SEP 11
    //   Use Pricing Qtys in Break Charge calculations
    // 
    // PRW16.00.06
    // P8001047, Columbus IT, Jack Reynolds, 30 MAR 12
    //   Receiving Labels
    // 
    // P8001063, Columbus IT, Jack Reynolds, 25 APR 12
    //   Fix problem with changes to alternate unit of measure
    // 
    // P8001123, Columbus IT, Jack Reynolds, 19 DEC 12
    //   Move Item table Label Code fields to Item Label table
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
    //
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples

    Caption = 'Item Unit of Measure';
    LookupPageID = "Item Units of Measure";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item;

            trigger OnValidate()
            begin
                CalcWeight();
            end;
        }
        field(2; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            TableRelation = "Unit of Measure";

            trigger OnValidate()
            begin
                Item.Get("Item No.");
                if Item."Base Unit of Measure" <> Code then
                    P800UOMFns.VaidateItemUOMCode(Rec); // PR3.60
            end;
        }
        field(3; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            InitValue = 1;

            trigger OnValidate()
            var
                BaseItemUoM: Record "Item Unit of Measure";
            begin
                if "Qty. per Unit of Measure" <= 0 then
                    FieldError("Qty. per Unit of Measure", Text000);
                if xRec."Qty. per Unit of Measure" <> "Qty. per Unit of Measure" then
                    CheckNoEntriesWithUoM();
                Item.Get("Item No.");
                if Item."Base Unit of Measure" = Code then
                    TestField("Qty. per Unit of Measure", 1)
                else
                    if BaseItemUoM.Get(Rec."Item No.", Item."Base Unit of Measure") then
                        CheckQtyPerUoMPrecision(Rec, BaseItemUoM."Qty. Rounding Precision");
                CheckAlternateUOM; // P8001063
                CalcWeight();

                "Base Quantity" := "Qty. per Unit of Measure" * "Equivalent UOM Qty."; // PR3.60
            end;
        }
        field(4; "Qty. Rounding Precision"; Decimal)
        {
            Caption = 'Qty. Rounding Precision';
            InitValue = 0;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            // MaxValue = 1; // P800133109

            trigger OnValidate()
            var
                ItemUoM: Record "Item Unit of Measure";
            begin
                if xRec."Qty. Rounding Precision" <> "Qty. Rounding Precision" then begin
                    CheckNoEntriesWithUoM();
                    Item.Get(Rec."Item No.");
                    ItemUoM.SetFilter("Item No.", Rec."Item No.");
                    ItemUoM.SetFilter(Code, '<>%1', Item."Base Unit of Measure");
                    if (ItemUoM.FindSet()) then
                        repeat
                            CheckQtyPerUoMPrecision(ItemUoM, Rec."Qty. Rounding Precision");
                        until (ItemUoM.Next() = 0);
                    Session.LogMessage('0000FAR', StrSubstNo(UoMQtyRoundingPercisionChangedTxt, xRec."Qty. Rounding Precision", "Qty. Rounding Precision", Item.SystemId), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UoMLoggingTelemetryCategoryTxt);
                end;
            end;
        }
        field(7300; Length; Decimal)
        {
            Caption = 'Length';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                CalcCubage();
            end;
        }
        field(7301; Width; Decimal)
        {
            Caption = 'Width';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                CalcCubage();
            end;
        }
        field(7302; Height; Decimal)
        {
            Caption = 'Height';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                CalcCubage();
            end;
        }
        field(7303; Cubage; Decimal)
        {
            Caption = 'Cubage';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(7304; Weight; Decimal)
        {
            Caption = 'Weight';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(37002000; Type; Option)
        {
            CalcFormula = Lookup("Unit of Measure".Type WHERE(Code = FIELD(Code)));
            Caption = 'Type';
            Description = 'PR1.00';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = ' ,Length,Weight,Volume';
            OptionMembers = " ",Length,Weight,Volume;
        }
        field(37002001; "Base Quantity"; Decimal)
        {
            Caption = 'Base Quantity';
            DecimalPlaces = 0 : 12;
            Description = 'PR3.60';
            InitValue = 1;

            trigger OnValidate()
            begin
                // PR3.60
                if ("Base Quantity" <= 0) then
                    FieldError("Base Quantity", Text000);
                Item.Get("Item No.");
                if (Item."Base Unit of Measure" = Code) then
                    TestField("Base Quantity", 1);
                Validate("Qty. per Unit of Measure", "Base Quantity" / "Equivalent UOM Qty.");
                // PR3.60
            end;
        }
        field(37002002; "Equivalent UOM Qty."; Decimal)
        {
            Caption = 'Equivalent UOM Qty.';
            DecimalPlaces = 0 : 12;
            Description = 'PR3.60';
            InitValue = 1;

            trigger OnValidate()
            begin
                // PR3.60
                if ("Equivalent UOM Qty." <= 0) then
                    FieldError("Equivalent UOM Qty.", Text000);
                Item.Get("Item No.");
                if (Item."Base Unit of Measure" = Code) then
                    TestField("Equivalent UOM Qty.", 1);
                CheckAlternateUOM; // P8001063
                "Qty. per Unit of Measure" := "Base Quantity" / "Equivalent UOM Qty.";
                CalcWeight; // P8000631A
                // PR3.60
            end;
        }
        field(37002003; "Rounding Precision"; Decimal)
        {
            Caption = 'Rounding Precision';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.70.03';
            MinValue = 0; // P800133109

            // P800133109
            trigger OnValidate()
            begin
                Item.Get("Item No.");
                if (Item."Base Unit of Measure" = Code) then
                    Validate("Qty. Rounding Precision", "Rounding Precision");
            end;
        }
        field(37002040; "Break Charge Adjustment"; Decimal)
        {
            BlankZero = true;
            Caption = 'Break Charge Adjustment';
            DecimalPlaces = 2 : 5;
            Description = 'PR3.60';

            trigger OnValidate()
            begin
                // PR3.60
                Item.Get("Item No.");
                // P8000539A
                case "Break Charge Method" of
                    "Break Charge Method"::"Amount Markup":
                        "Break Chg. Adj. (Pricing Unit)" := "Break Charge Adjustment" /
                          //(("Base Quantity" / "Equivalent UOM Qty.") * Item.CostingQtyPerBase()); // P8000981
                          (("Base Quantity" / "Equivalent UOM Qty.") * Item.PricingQtyPerBase());   // P8000981
                    "Break Charge Method"::"% Markup":
                        begin
                            if ("Break Charge Adjustment" < -100) then
                                FieldError("Break Charge Adjustment");
                            "Break Chg. Adj. (Pricing Unit)" := "Break Charge Adjustment";
                        end;
                    "Break Charge Method"::"% Margin":
                        begin
                            if ("Break Charge Adjustment" >= 100) then
                                FieldError("Break Charge Adjustment");
                            "Break Chg. Adj. (Pricing Unit)" := "Break Charge Adjustment";
                        end;
                end;
                // P8000539A
                // PR3.60
            end;
        }
        field(37002041; "Break Chg. Adj. (Pricing Unit)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Break Chg. Adj. (Pricing Unit)';
            DecimalPlaces = 2 : 5;
            Description = 'PR3.60';

            trigger OnValidate()
            begin
                // PR3.60
                Item.Get("Item No.");
                if ("Break Charge Method" <> "Break Charge Method"::"Amount Markup") then // P8000539A
                    Validate("Break Charge Adjustment", "Break Chg. Adj. (Pricing Unit)")   // P8000539A
                else                                                                      // P8000539A
                    "Break Charge Adjustment" := "Break Chg. Adj. (Pricing Unit)" *
                      //(("Base Quantity" / "Equivalent UOM Qty.") * Item.CostingQtyPerBase()); // P8000981
                      (("Base Quantity" / "Equivalent UOM Qty.") * Item.PricingQtyPerBase());   // P8000981
                // PR3.60
            end;
        }
        field(37002042; "Break Charge Method"; Option)
        {
            Caption = 'Break Charge Method';
            Description = 'P8000539A';
            OptionCaption = 'Amount Markup,% Markup,% Margin';
            OptionMembers = "Amount Markup","% Markup","% Margin";

            trigger OnValidate()
            begin
                // P8000539A
                if ("Break Charge Method" <> xRec."Break Charge Method") then
                    Validate("Break Charge Adjustment", 0);
                // P8000539A
            end;
        }
        field(37002560; "Tare Weight"; Decimal)
        {
            Caption = 'Tare Weight';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.61';
            MinValue = 0;

            trigger OnValidate()
            begin
                // PR3.61 Begin
                if "Tare Weight" = 0 then
                    "Tare Unit of Measure" := ''
                else
                    if "Tare Unit of Measure" = '' then
                        "Tare Unit of Measure" := P800UOMFns.DefaultUOM(2);
                // PR3.61 End
            end;
        }
        field(37002561; "Tare Unit of Measure"; Code[10])
        {
            Caption = 'Tare Unit of Measure';
            Description = 'PR3.61';
            TableRelation = "Unit of Measure" WHERE(Type = CONST(Weight));

            trigger OnValidate()
            begin
                // PR3.61 Begin
                if "Tare Unit of Measure" = '' then
                    TestField("Tare Weight", 0);
                // PR3.61 End
            end;
        }
        field(37002700; "Label Code"; Code[10])
        {
            Caption = 'Label Code';
            TableRelation = Label WHERE(Type = CONST(Case));
        }
        field(37002701; "Labels per Unit"; Integer)
        {
            Caption = 'Labels per Unit';
            InitValue = 1;
            MinValue = 0;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Code")
        {
            Clustered = true;
        }
        key(Key2; "Item No.", "Qty. per Unit of Measure")
        {
        }
        key(Key3; "Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Type, "Base Quantity", "Equivalent UOM Qty.")
        {
        }
    }

    trigger OnDelete()
    begin
        if Rec.Code <> '' then begin
            TestItemUOM();
            CheckNoEntriesWithUoM();
        end;
    end;

    trigger OnModify()
    begin
        Modify; // P8000555A
        P800UOMFns.ModifyItemUOM(xRec, Rec); // PR3.60 // P8000720
    end;
    	
    trigger OnRename()
    begin
        TestItemUOM();
    end;

    var
        Item: Record Item;

        Text000: Label 'must be greater than 0';
        Text001: Label 'You cannot rename %1 %2 for item %3 because it is the item''s %4 and there are one or more open ledger entries for the item.';
        CannotModifyBaseUnitOfMeasureErr: Label 'You cannot modify item unit of measure %1 for item %2 because it is the item''s base unit of measure.', Comment = '%1 Value of Measure (KG, PCS...), %2 Item ID';
        CannotModifySalesUnitOfMeasureErr: Label 'You cannot modify item unit of measure %1 for item %2 because it is the item''s sales unit of measure.', Comment = '%1 Value of Measure (KG, PCS...), %2 Item ID';
        CannotModifyPurchUnitOfMeasureErr: Label 'You cannot modify item unit of measure %1 for item %2 because it is the item''s purchase unit of measure.', Comment = '%1 Value of Measure (KG, PCS...), %2 Item ID';
        CannotModifyPutAwayUnitOfMeasureErr: Label 'You cannot modify item unit of measure %1 for item %2 because it is the item''s put-away unit of measure.', Comment = '%1 Value of Measure (KG, PCS...), %2 Item ID';
        CannotModifyUnitOfMeasureErr: Label 'You cannot modify %1 %2 for item %3 because non-zero %5 with %2 exists in %4.', Comment = '%1 Table name (Item Unit of measure), %2 Value of Measure (KG, PCS...), %3 Item ID, %4 Entry Table Name, %5 Field Caption';
        UOM: Record "Unit of Measure";
        ItemUOM: Record "Item Unit of Measure";
        UOMMgt: Codeunit "Unit of Measure Management";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        Text37002000: Label '%1 - %2';
        Text37002001: Label '%1 %2(s) per %3';
        Text37002002: Label '%1 %2(s) is %3 %4(s)';
        Text37002003: Label 'You cannot change the conversion factor for %1 because it is the item''s %2 and there are one or more open ledger entries for the item.';
        CannotModifyLabelUnitOfMeasureErr: Label 'You cannot modify item unit of measure %1 for item %2 because it is the item''s label unit of measure.', Comment = '%1 Value of Measure (KG, PCS...), %2 Item ID';
        CannotModifyReferencesExistErr: Label 'You cannot modify %1 %2 for item %3 because one or more %4 exist.';
        CannotModifyUOMWithWhseEntriesErr: Label 'You cannot modify %1 %2 for item %3 because there are one or more warehouse adjustment entries for the item.', Comment = '%1 = Item Unit of Measure %2 = Code %3 = Item No.';
        QtyPerUoMRoundPrecisionNotAlignedErr: Label 'The quantity per unit of measure %1 for item %2 does not align with the quantity rounding precision %3 for the current base unit of measure.', Comment = '%1 = Qty. per Unit of Measure value, %2 = Item Code, %3 = Qty. Rounding Precision value';
        UoMLoggingTelemetryCategoryTxt: Label 'AL UoM Logging.', Locked = true;
        UoMQtyRoundingPercisionChangedTxt: Label 'Base UoM Qty. Rounding Precision changed from %1 to %2, for item: %3.', Locked = true;
        CannotModifyAltUnitOfMeasureErr: Label 'You cannot modify item unit of measure %1 for item %2 because it is the item''s alternate unit of measure.'; // P800122712

    local procedure CalcCubage()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcCubage(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        Cubage := Length * Width * Height;

        OnAfterCalcCubage(Rec);
    end;

    procedure CalcWeight()
    begin
        if Item."No." <> "Item No." then
            Item.Get("Item No.");

        Weight := "Qty. per Unit of Measure" * Item."Net Weight";

        OnAfterCalcWeight(Rec);
    end;

    local procedure TestNoOpenEntriesExist()
    var
        Item: Record Item;
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        if Item.Get("Item No.") then
            if Item."Base Unit of Measure" = xRec.Code then begin
                ItemLedgEntry.SetCurrentKey("Item No.", Open);
                ItemLedgEntry.SetRange("Item No.", "Item No.");
                ItemLedgEntry.SetRange(Open, true);
                if not ItemLedgEntry.IsEmpty() then
                    Error(Text001, TableCaption(), xRec.Code, "Item No.", Item.FieldCaption("Base Unit of Measure"));
            end;
    end;

    local procedure TestNoWhseAdjmtEntriesExist()
    var
        WhseEntry: Record "Warehouse Entry";
        Location: Record Location;
        Bin: Record Bin;
    begin
        WhseEntry.SetRange("Item No.", "Item No.");
        WhseEntry.SetRange("Unit of Measure Code", xRec.Code);
        if Location.FindSet() then
            repeat
                if Bin.Get(Location.Code, Location."Adjustment Bin Code") then begin
                    WhseEntry.SetRange("Zone Code", Bin."Zone Code");
                    if not WhseEntry.IsEmpty() then
                        Error(CannotModifyUOMWithWhseEntriesErr, TableCaption(), xRec.Code, "Item No.");
                end;
            until Location.Next() = 0;
    end;

    procedure TestItemSetup()
    begin
        if Item.Get("Item No.") then begin
            if Item."Base Unit of Measure" = xRec.Code then
                Error(CannotModifyBaseUnitOfMeasureErr, xRec.Code, "Item No.");
            if Item."Sales Unit of Measure" = xRec.Code then
                Error(CannotModifySalesUnitOfMeasureErr, xRec.Code, "Item No.");
            if Item."Purch. Unit of Measure" = xRec.Code then
                Error(CannotModifyPurchUnitOfMeasureErr, xRec.Code, "Item No.");
            if Item."Put-away Unit of Measure Code" = xRec.Code then
                Error(CannotModifyPutAwayUnitOfMeasureErr, xRec.Code, "Item No.");
            if Item."Label Unit of Measure" = Code then                      // P8001047
                Error(CannotModifyLabelUnitOfMeasureErr, xRec.Code, "Item No."); // P8001047, P80066030
            // P800122712
            if Item."Alternate Unit of Measure" = Code then
                Error(CannotModifyAltUnitOfMeasureErr, xRec.Code, "Item No.");
            // P800122712
        end;
        OnAfterTestItemSetup(Rec, xRec);
    end;

    local procedure TestItemUOM()
    begin
        TestItemSetup();
        TestNoOpenEntriesExist();
        TestNoWhseAdjmtEntriesExist();
    end;

    procedure CheckNoEntriesWithUoM()
    var
        WarehouseEntry: Record "Warehouse Entry";
    begin
        WarehouseEntry.SetRange("Item No.", "Item No.");
        WarehouseEntry.SetRange("Unit of Measure Code", Code);
        WarehouseEntry.CalcSums("Qty. (Base)", Quantity);
        if (WarehouseEntry."Qty. (Base)" <> 0) or (WarehouseEntry.Quantity <> 0) then
            Error(
              CannotModifyUnitOfMeasureErr, TableCaption(), xRec.Code, "Item No.", WarehouseEntry.TableCaption(),
              WarehouseEntry.FieldCaption(Quantity));

        TestNoContainerLinesExist(); // P800133109

        CheckNoOutstandingQty();
    end;

    local procedure CheckNoOutstandingQty()
    begin
        CheckNoOutstandingQtyPurchLine();
        CheckNoOutstandingQtySalesLine();
        CheckNoOutstandingQtyTransferLine();
        CheckNoRemQtyProdOrderLine();
        CheckNoRemQtyProdOrderComponent();
        CheckNoOutstandingQtyServiceLine();
        CheckNoRemQtyAssemblyHeader();
        CheckNoRemQtyAssemblyLine();

        // P800133109
        CheckPreProcessActivity();
        CheckPreProcessActivityLine();
        CheckRepackOrder();
        CheckRepackOrderLine();
        CheckWhseStagedPickLine();
        CheckWhseStagedPickSourceLine();
        CheckWorkOrderMaterial();
        // P800133109
    end;

    local procedure CheckNoOutstandingQtyPurchLine()
    var
        PurchLine: Record "Purchase Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckNoOutstandingQtyPurchLine(Rec, xRec, PurchLine, IsHandled);
        if IsHandled then
            exit;

        PurchLine.SetRange(Type, PurchLine.Type::Item);
        PurchLine.SetRange("No.", "Item No.");
        PurchLine.SetRange("Unit of Measure Code", Code);
        PurchLine.SetFilter("Outstanding Quantity", '<>%1', 0);
        if not PurchLine.IsEmpty() then
            Error(
              CannotModifyUnitOfMeasureErr, TableCaption(), xRec.Code, "Item No.",
              PurchLine.TableCaption(), PurchLine.FieldCaption("Qty. to Receive"));
    end;

    local procedure CheckNoOutstandingQtySalesLine()
    var
        SalesLine: Record "Sales Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckNoOutstandingQtySalesLine(Rec, xRec, SalesLine, IsHandled);
        if IsHandled then
            exit;

        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("No.", "Item No.");
        SalesLine.SetRange("Unit of Measure Code", Code);
        SalesLine.SetFilter("Outstanding Quantity", '<>%1', 0);
        if not SalesLine.IsEmpty() then
            Error(
              CannotModifyUnitOfMeasureErr, TableCaption(), xRec.Code, "Item No.",
              SalesLine.TableCaption(), SalesLine.FieldCaption("Qty. to Ship"));
    end;

    local procedure CheckNoOutstandingQtyTransferLine()
    var
        TransferLine: Record "Transfer Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckNoOutstandingQtyTransferLine(Rec, xRec, TransferLine, IsHandled);
        if IsHandled then
            exit;

        TransferLine.SetRange("Item No.", "Item No.");
        TransferLine.SetRange("Unit of Measure Code", Code);
        TransferLine.SetFilter("Outstanding Quantity", '<>%1', 0);
        if not TransferLine.IsEmpty() then
            Error(
              CannotModifyUnitOfMeasureErr, TableCaption(), xRec.Code, "Item No.",
              TransferLine.TableCaption(), TransferLine.FieldCaption("Qty. to Ship"));
    end;

    local procedure CheckNoRemQtyProdOrderLine()
    var
        ProdOrderLine: Record "Prod. Order Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckNoRemQtyProdOrderLine(Rec, xRec, ProdOrderLine, IsHandled);
        if IsHandled then
            exit;

        ProdOrderLine.SetRange("Item No.", "Item No.");
        ProdOrderLine.SetRange("Unit of Measure Code", Code);
        ProdOrderLine.SetFilter("Remaining Quantity", '<>%1', 0);
        ProdOrderLine.SetFilter(Status, '<>%1', ProdOrderLine.Status::Finished);
        if not ProdOrderLine.IsEmpty() then
            Error(
              CannotModifyUnitOfMeasureErr, TableCaption(), xRec.Code, "Item No.",
              ProdOrderLine.TableCaption(), ProdOrderLine.FieldCaption("Remaining Quantity"));
    end;

    local procedure CheckNoRemQtyProdOrderComponent()
    var
        ProdOrderComponent: Record "Prod. Order Component";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckNoRemQtyProdOrderComponent(Rec, xRec, ProdOrderComponent, IsHandled);
        if IsHandled then
            exit;

        ProdOrderComponent.SetRange("Item No.", "Item No.");
        ProdOrderComponent.SetRange("Unit of Measure Code", Code);
        ProdOrderComponent.SetFilter("Remaining Quantity", '<>%1', 0);
        ProdOrderComponent.SetFilter(Status, '<>%1', ProdOrderComponent.Status::Finished);
        if not ProdOrderComponent.IsEmpty() then
            Error(
              CannotModifyUnitOfMeasureErr, TableCaption(), xRec.Code, "Item No.",
              ProdOrderComponent.TableCaption(), ProdOrderComponent.FieldCaption("Remaining Quantity"));
    end;

    local procedure CheckNoOutstandingQtyServiceLine()
    var
        ServiceLine: Record "Service Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckNoOutstandingQtyServiceLine(Rec, xRec, ServiceLine, IsHandled);
        if IsHandled then
            exit;

        ServiceLine.SetRange(Type, ServiceLine.Type::Item);
        ServiceLine.SetRange("No.", "Item No.");
        ServiceLine.SetRange("Unit of Measure Code", Code);
        ServiceLine.SetFilter("Outstanding Quantity", '<>%1', 0);
        if not ServiceLine.IsEmpty() then
            Error(
              CannotModifyUnitOfMeasureErr, TableCaption(), xRec.Code, "Item No.",
              ServiceLine.TableCaption(), ServiceLine.FieldCaption("Qty. to Ship"));
    end;

    local procedure CheckNoRemQtyAssemblyHeader()
    var
        AssemblyHeader: Record "Assembly Header";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckNoRemQtyAssemblyHeader(Rec, xRec, AssemblyHeader, IsHandled);
        if IsHandled then
            exit;

        AssemblyHeader.SetRange("Item No.", "Item No.");
        AssemblyHeader.SetRange("Unit of Measure Code", Code);
        AssemblyHeader.SetFilter("Remaining Quantity", '<>%1', 0);
        if not AssemblyHeader.IsEmpty() then
            Error(
              CannotModifyUnitOfMeasureErr, TableCaption(), xRec.Code, "Item No.",
              AssemblyHeader.TableCaption(), AssemblyHeader.FieldCaption("Remaining Quantity"));
    end;

    local procedure CheckNoRemQtyAssemblyLine()
    var
        AssemblyLine: Record "Assembly Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckNoRemQtyAssemblyLine(Rec, xRec, AssemblyLine, IsHandled);
        if IsHandled then
            exit;

        AssemblyLine.SetRange(Type, AssemblyLine.Type::Item);
        AssemblyLine.SetRange("No.", "Item No.");
        AssemblyLine.SetRange("Unit of Measure Code", Code);
        AssemblyLine.SetFilter("Remaining Quantity", '<>%1', 0);
        if not AssemblyLine.IsEmpty() then
            Error(
              CannotModifyUnitOfMeasureErr, TableCaption(), xRec.Code, "Item No.",
              AssemblyLine.TableCaption(), AssemblyLine.FieldCaption("Remaining Quantity"));
    end;

    local procedure CheckQtyPerUoMPrecision(ItemUoM: Record "Item Unit of Measure"; BaseRoundingPrecision: Decimal)
    begin
        if BaseRoundingPrecision <> 0 then
            if ItemUoM."Qty. per Unit of Measure" MOD BaseRoundingPrecision <> 0 then
                Error(QtyPerUoMRoundPrecisionNotAlignedErr,
                    ItemUoM."Qty. per Unit of Measure",
                    ItemUoM.Code,
                    BaseRoundingPrecision);
    end;
    
    procedure "Conversion Description"(): Text[250]
    var
        Item: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        BaseUOMDescription: Text[100];
        EquivUOMDescription: Text[100];
    begin
        // PR3.60
        if ("Item No." <> '') and (Code <> '') then begin
            Item.Get("Item No.");
            if (Item."Base Unit of Measure" <> '') then begin
                BaseUOMDescription := GetUOMDescription(Item."Base Unit of Measure");
                if (Item."Base Unit of Measure" = Code) then
                    exit(StrSubstNo(Text37002000, BaseUOMDescription, Item.FieldCaption("Base Unit of Measure")));
                EquivUOMDescription := GetUOMDescription(Code);
                if ("Base Quantity" = 1) then
                    exit(StrSubstNo(Text37002001, "Equivalent UOM Qty.", EquivUOMDescription, BaseUOMDescription));
                if ("Equivalent UOM Qty." = 1) then
                    exit(StrSubstNo(Text37002001, "Base Quantity", BaseUOMDescription, EquivUOMDescription));
                exit(StrSubstNo(
                  Text37002002, "Base Quantity", BaseUOMDescription, "Equivalent UOM Qty.", EquivUOMDescription));
            end;
        end;
        exit('');
        // PR3.60
    end;

    procedure GetUOMDescription(UOMCode: Code[10]): Text[50]
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        // PR3.60
        UnitOfMeasure.Get(UOMCode);
        if (UnitOfMeasure.Description <> '') then
            exit(UnitOfMeasure.Description);
        exit(UOMCode);
        // PR3.60
    end;

    procedure CheckAlternateUOM()
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        // P8001063
        Item.Get("Item No.");
        if (Item."Alternate Unit of Measure" = Code) and (not Item."Catch Alternate Qtys.") then begin
            ItemLedgEntry.SetCurrentKey("Item No.", Open);
            ItemLedgEntry.SetRange("Item No.", "Item No.");
            ItemLedgEntry.SetRange(Open, true);
            if not ItemLedgEntry.IsEmpty then
                Error(Text37002003, Code, Item.FieldCaption("Alternate Unit of Measure"));
        end;
    end;

    // P800133109
    local procedure TestNoContainerLinesExist()
    var
        ContainerLine: Record "Container Line";
    begin
        ContainerLine.SetRange("Item No.", "Item No.");
        ContainerLine.SetRange("Unit of Measure Code", Code);
        if not ContainerLine.IsEmpty() then
            Error(CannotModifyReferencesExistErr, TableCaption, Code, "Item No.", ContainerLine.TableCaption);
    end;

    // P800133109
    local procedure CheckPreProcessActivity()
    var
        PreProcessActivity: Record "Pre-Process Activity";
    begin
        PreProcessActivity.SetRange("Item No.", "Item No.");
        PreProcessActivity.SetRange("Unit of Measure Code", Code);
        if not PreProcessActivity.IsEmpty() then
            Error(
              CannotModifyReferencesExistErr, TableCaption, Code, "Item No.", PreProcessActivity.TableCaption);
    end;

    // P800133109
    local procedure CheckPreProcessActivityLine()
    var
        PreProcessActivityLine, PreProcessActivityLine2 : Record "Pre-Process Activity Line";
    begin
        PreProcessActivityLine.SetRange("Item No.", "Item No.");
        PreProcessActivityLine.SetRange("Unit of Measure Code", Code);
        if not PreProcessActivityLine.IsEmpty() then
            Error(
              CannotModifyReferencesExistErr, TableCaption, Code, "Item No.", PreProcessActivityLine.TableCaption);
    end;

    // P800133109
    local procedure CheckRepackOrder()
    var
        RepackOrder: Record "Repack Order";
    begin
        RepackOrder.SetRange(Status, RepackOrder.Status::Open);
        RepackOrder.SetRange("Item No.", "Item No.");
        RepackOrder.SetRange("Unit of Measure Code", Code);
        if not RepackOrder.IsEmpty() then
            Error(
              CannotModifyReferencesExistErr, TableCaption, Code, "Item No.", RepackOrder.TableCaption);
    end;

    // P800133109
    local procedure CheckRepackOrderLine()
    var
        RepackOrder: Record "Repack Order";
        RepackOrderLine: Record "Repack Order Line";
    begin
        RepackOrderLine.SetRange(Type, RepackOrderLine.Type::Item);
        RepackOrderLine.SetRange("No.", "Item No.");
        RepackOrderLine.SetRange("Unit of Measure Code", Code);

        RepackOrder.SetRange(Status, RepackOrder.Status::Open);
        if RepackOrder.FindSet() then
            repeat
                RepackOrderLine.SetRange("Order No.", RepackOrder."No.");
                if not RepackOrderLine.IsEmpty() then
                    Error(
                      CannotModifyReferencesExistErr, TableCaption, Code, "Item No.", RepackOrderLine.TableCaption);
            until RepackOrder.Next() = 0;
    end;

    // P800133109
    local procedure CheckWhseStagedPickLine()
    var
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
    begin
        WhseStagedPickLine.SetRange("Item No.", "Item No.");
        WhseStagedPickLine.SetRange("Unit of Measure Code", Code);
        if not WhseStagedPickLine.IsEmpty() then
            Error(
              CannotModifyReferencesExistErr, TableCaption, Code, "Item No.", WhseStagedPickLine.TableCaption);
    end;

    // P800133109
    local procedure CheckWhseStagedPickSourceLine()
    var
        WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line";
    begin
        WhseStagedPickSourceLine.SetRange("Item No.", "Item No.");
        WhseStagedPickSourceLine.SetRange("Unit of Measure Code", Code);
        if not WhseStagedPickSourceLine.IsEmpty() then
            Error(
              CannotModifyReferencesExistErr, TableCaption, Code, "Item No.", WhseStagedPickSourceLine.TableCaption);
    end;

    // P800133109
    local procedure CheckWorkOrderMaterial()
    var
        WorkOrder: Record "Work Order";
        WorkOrderMaterial: Record "Work Order Material";
    begin
        WorkOrder.SetFilter(Status, '<>%1&<>%2', WorkOrder.Status::Closed, WorkOrder.Status::Cancelled);
        WorkOrderMaterial.SetRange(Type, WorkOrderMaterial.Type::Stock);
        WorkOrderMaterial.SetRange("Item No.", "Item No.");
        WorkOrderMaterial.SetRange("Unit of Measure Code", Code);
        if WorkOrder.FindSet() then
            repeat
                WorkOrderMaterial.SetRange("Work Order No.", WorkOrder."No.");
                if not WorkOrderMaterial.IsEmpty() then
                    Error(
                      CannotModifyReferencesExistErr, TableCaption, Code, "Item No.", WorkOrderMaterial.TableCaption);
            until WorkOrder.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcCubage(var ItemUnitOfMeasure: Record "Item Unit of Measure")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcWeight(var ItemUnitOfMeasure: Record "Item Unit of Measure")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestItemSetup(var Rec: Record "Item Unit of Measure"; xRec: Record "Item Unit of Measure")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcCubage(var ItemUnitOfMeasure: Record "Item Unit of Measure"; var xItemUnitOfMeasure: Record "Item Unit of Measure"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckNoRemQtyAssemblyLine(ItemUnitOfMeasure: Record "Item Unit of Measure"; xItemUnitOfMeasure: Record "Item Unit of Measure"; var AssemblyLine: Record "Assembly Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckNoOutstandingQtySalesLine(ItemUnitOfMeasure: Record "Item Unit of Measure"; xItemUnitOfMeasure: Record "Item Unit of Measure"; var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckNoRemQtyAssemblyHeader(ItemUnitOfMeasure: Record "Item Unit of Measure"; xItemUnitOfMeasure: Record "Item Unit of Measure"; var AssemblyHeader: Record "Assembly Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckNoRemQtyProdOrderLine(ItemUnitOfMeasure: Record "Item Unit of Measure"; xItemUnitOfMeasure: Record "Item Unit of Measure"; var ProdOrderLine: Record "Prod. Order Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckNoRemQtyProdOrderComponent(ItemUnitOfMeasure: Record "Item Unit of Measure"; xItemUnitOfMeasure: Record "Item Unit of Measure"; var ProdOrderComponent: Record "Prod. Order Component"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckNoOutstandingQtyPurchLine(ItemUnitOfMeasure: Record "Item Unit of Measure"; xItemUnitOfMeasure: Record "Item Unit of Measure"; var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckNoOutstandingQtyServiceLine(ItemUnitOfMeasure: Record "Item Unit of Measure"; xItemUnitOfMeasure: Record "Item Unit of Measure"; var ServiceLine: Record "Service Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckNoOutstandingQtyTransferLine(ItemUnitOfMeasure: Record "Item Unit of Measure"; xItemUnitOfMeasure: Record "Item Unit of Measure"; var TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;
}

