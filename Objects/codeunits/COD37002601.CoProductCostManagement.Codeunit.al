codeunit 37002601 "Co-Product Cost Management"
{
    // PR3.60
    //   Management of production co-products and by-products
    // 
    // PR3.70.06
    // P8000085A, Myers Nissi, Jack Reynolds, 09 AUG 04
    //   CalcProdSharedActCost - use "Cost Amount (Actual) (ACY)" instead of "Cost Amount (Expected) (ACY)"
    //   AddProdLineByProductActCost - use "Cost Amount (Actual) (ACY)" instead of "Cost Amount (Expected) (ACY)"
    // 
    // P8000104A, Myers Nissi, Jack Reynolds, 31 AUG 04
    //   BuildProdCommonUOMQtys - don't insert record in TempCoProductLine unless quantity is greater than zero
    // 
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Add BOM line source identification when creating shared components
    // 
    // PR3.70.08
    // P8000173A, Myers Nissi, Jack Reynolds, 24 JAN 05
    //   CalcActNeededQtyBase - calculate needed quantity for shared components based on actual quantity vs. expected
    //     quantity for all output lines that are not by-products
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Changes to Item Ledger keys
    // 
    // PR4.00.04
    // P8000370A, VerticalSoft, Jack Reynolds, 08 SEP 06
    //   New function GetCoProductUnits to return co-product untis for specified production order line
    // 
    // PRW16.00.01
    // P8000693, VerticalSoft, Jack Reynolds, 01 MAY 09
    //   Fix problem with currency rounding precision
    // 
    // PRW16.00.05
    // P8000979, Columbus IT, Don Bresee, 09 SEP 11
    //   Add logic for Co/By products for Lot Tracing
    // 
    // PRW16.00.06
    // P8001092, Columbus IT, Don Bresee, 17 AUG 12
    //   Change costing logic to use "Co-Product Cost Share" field
    // 
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Add Pre-Process functionality
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10.02
    // P8001288, Columbus IT, Jack Reynolds, 12 FEB 14
    //   Fix problem setting Bin Code on shared components

    Permissions = TableData "Alternate Quantity Entry" = rim;

    trigger OnRun()
    begin
    end;

    var
        Item: Record Item;
        ProdOrder: Record "Production Order";
        TempCoProductLine: Record "Prod. Order Line" temporary;
        VersionMgmt: Codeunit VersionManagement;
        GetPlanningParameters: Codeunit "Planning-Get Parameters";
        UOMMgmt: Codeunit "Unit of Measure Management";
        P800ProdOrderMgmt: Codeunit "Process 800 Prod. Order Mgt.";
        Text001: Label 'Order %1 must have co-product output.';

    local procedure GetItem(ItemNo: Code[20])
    begin
        // GetItem
        if (Item."No." <> ItemNo) then
            Item.Get(ItemNo);
    end;

    procedure ProcessSharedComponents(var ProdOrder2: Record "Production Order")
    var
        ProdBOMLine: Record "Production BOM Line";
        ProdOrderComp2: Record "Prod. Order Component";
        SKU: Record "Stockkeeping Unit";
    begin
        // ProcessSharedComponents
        if ProdOrder2."Family Process Order" then begin
            ProdBOMLine.SetRange("Production BOM No.", ProdOrder2."Source No.");
            ProdBOMLine.SetRange("Version Code",
              VersionMgmt.GetBOMVersion(ProdOrder2."Source No.", ProdOrder2."Starting Date", true));
            ProdBOMLine.SetRange(Type, ProdBOMLine.Type::Item);
            if ProdBOMLine.Find('-') then
                repeat
                    ProdOrderComp2.Init;
                    ProdOrderComp2.BlockDynamicTracking(false);
                    ProdOrderComp2.Status := ProdOrder2.Status;
                    ProdOrderComp2."Prod. Order No." := ProdOrder2."No.";
                    ProdOrderComp2."Prod. Order Line No." := 0;
                    ProdOrderComp2."Line No." := ProdOrderComp2."Line No." + 10000;
                    ProdOrderComp2.Validate("Item No.", ProdBOMLine."No.");
                    ProdOrderComp2."Variant Code" := ProdBOMLine."Variant Code";
                    ProdOrderComp2.Validate("Location Code", ProdOrder2."Location Code"); // P8001288
                    ProdOrderComp2.Description := ProdBOMLine.Description;
                    ProdOrderComp2.Validate("Unit of Measure Code", ProdBOMLine."Unit of Measure Code");
                    ProdOrderComp2.Validate("Quantity per", ProdBOMLine."Batch Quantity");
                    ProdOrderComp2.Length := ProdBOMLine.Length;
                    ProdOrderComp2.Width := ProdBOMLine.Width;
                    ProdOrderComp2.Weight := ProdBOMLine.Weight;
                    ProdOrderComp2.Depth := ProdBOMLine.Depth;
                    ProdOrderComp2.Position := ProdBOMLine.Position;
                    ProdOrderComp2."Position 2" := ProdBOMLine."Position 2";
                    ProdOrderComp2."Position 3" := ProdBOMLine."Position 3";
                    ProdOrderComp2."Lead-Time Offset" := ProdBOMLine."Lead-Time Offset";
                    ProdOrderComp2.Validate("Routing Link Code", ProdBOMLine."Routing Link Code");
                    ProdOrderComp2.Validate("Scrap %", ProdBOMLine."Scrap %");
                    ProdOrderComp2.Validate("Calculation Formula", ProdBOMLine."Calculation Formula");
                    ProdOrderComp2."Auto Plan" := ProdBOMLine."Auto Plan if Component";
                    ProdOrderComp2."Step Code" := ProdBOMLine."Step Code";
                    ProdOrderComp2."Production BOM No." := ProdBOMLine."Production BOM No.";    // P8000153A
                    ProdOrderComp2."Production BOM Version Code" := ProdBOMLine."Version Code"; // P8000153A
                    ProdOrderComp2."Production BOM Line No." := ProdBOMLine."Line No.";         // P8000153A
                    GetPlanningParameters.AtSKU(
                      SKU, ProdOrderComp2."Item No.",
                      ProdOrderComp2."Variant Code", ProdOrderComp2."Location Code");
                    ProdOrderComp2."Flushing Method" := SKU."Flushing Method";
                    // P8001082
                    ProdOrderComp2.Validate("Pre-Process Type Code", ProdBOMLine."Pre-Process Type Code");
                    ProdOrderComp2.Validate("Pre-Process Lead Time (Days)", ProdBOMLine."Pre-Process Lead Time (Days)");
                    // P8001082
                    ProdOrderComp2.Insert(true);
                until (ProdBOMLine.Next = 0);
        end;
    end;

    procedure ConvertSharedComponents(var TempProdOrderLine: Record "Prod. Order Line" temporary)
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        // ConvertSharedComponents
        with TempProdOrderLine do begin
            SetRange("Line No.", 0);
            while Find('-') do begin
                Delete;
                ProdOrderLine.SetRange(Status, Status);
                ProdOrderLine.SetRange("Prod. Order No.", "Prod. Order No.");
                if ProdOrderLine.Find('-') then
                    repeat
                        TempProdOrderLine := ProdOrderLine;
                        if not Get(Status, "Prod. Order No.", "Line No.") then
                            Insert;
                    until (ProdOrderLine.Next = 0);
            end;
            SetRange("Line No.");
            Find('-');
        end;
    end;

    procedure IsCoProductMissing(ProdOrderLine: Record "Prod. Order Line"; FindCoProdEntries: Boolean): Boolean
    begin
        // IsCoProductMissing
        with ProdOrderLine do begin
            if not P800ProdOrderMgmt.IsProdFamilyProcess(ProdOrderLine) then
                exit(false);
            SetRange(Status, Status);
            SetRange("Prod. Order No.", "Prod. Order No.");
            SetRange("By-Product", false);
            if FindCoProdEntries then
                SetFilter("Finished Quantity", '<>0');
            exit(not Find('-'));
        end;
    end;

    procedure CheckForMissingCoProduct(var ProdOrder2: Record "Production Order")
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        // CheckForMissingCoProduct
        with ProdOrderLine do
            if ProdOrder2."Family Process Order" then begin
                Status := ProdOrder2.Status;
                "Prod. Order No." := ProdOrder2."No.";
                if IsCoProductMissing(ProdOrderLine, true) then
                    Error(Text001, "Prod. Order No.");
            end;
    end;

    procedure CalcProdSharedExpCost(var ProdOrderLine: Record "Prod. Order Line") SharedExpMatCost: Decimal
    var
        ProdOrderComp: Record "Prod. Order Component";
    begin
        // CalcProdSharedExpCost
        with ProdOrderLine do begin
            SharedExpMatCost := 0;

            ProdOrderComp.SetRange(Status, Status);
            ProdOrderComp.SetRange("Prod. Order No.", "Prod. Order No.");
            ProdOrderComp.SetRange("Prod. Order Line No.", 0);
            if ProdOrderComp.Find('-') then
                repeat
                    SharedExpMatCost := SharedExpMatCost + ProdOrderComp."Cost Amount";
                until (ProdOrderComp.Next = 0);
        end;
    end;

    procedure CalcProdByProductExpCost(ProdOrderLine: Record "Prod. Order Line") ByProductCost: Decimal
    begin
        // CalcProdByProductExpCost
        with ProdOrderLine do begin
            ByProductCost := 0;

            SetRange(Status, Status);
            SetRange("Prod. Order No.", "Prod. Order No.");
            Find('-');
            repeat
                if "By-Product" then
                    ByProductCost := ByProductCost + CalcProdLineByProductExpCost(ProdOrderLine);
            until (Next = 0);
        end;
    end;

    procedure CalcProdLineByProductExpCost(var ProdOrderLine: Record "Prod. Order Line"): Decimal
    begin
        // CalcProdLineByProductExpCost
        with ProdOrderLine do
            exit("Unit Cost (By-Product)" * P800ProdOrderMgmt.CalcProdLineCostQty(ProdOrderLine, false));
    end;

    procedure CalcProdSharedActCost(var ProdOrderLine: Record "Prod. Order Line"; var SharedActMatCost: Decimal; var SharedActMatCostACY: Decimal)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        // CalcProdSharedActCost
        with ProdOrderLine do begin
            SharedActMatCost := 0;
            SharedActMatCostACY := 0;

            ItemLedgEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type"); // P8000267B, P8001132
            ItemLedgEntry.SetRange("Order Type", ItemLedgEntry."Order Type"::Production); // P8001132
            ItemLedgEntry.SetRange("Order No.", "Prod. Order No."); // P8001132
            ItemLedgEntry.SetRange("Order Line No.", 0);            // P8001132
            ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Consumption);
            if ItemLedgEntry.Find('-') then
                repeat
                    ItemLedgEntry.CalcFields("Cost Amount (Actual)", "Cost Amount (Actual) (ACY)"); // P8000085A
                    SharedActMatCost := SharedActMatCost - ItemLedgEntry."Cost Amount (Actual)";
                    SharedActMatCostACY := SharedActMatCostACY - ItemLedgEntry."Cost Amount (Actual) (ACY)"; // P8000085A
                until (ItemLedgEntry.Next = 0);
        end;
    end;

    procedure CalcProdByProductActCost(ProdOrderLine: Record "Prod. Order Line"; var ActByProductCost: Decimal; var ActByProductCostACY: Decimal)
    var
        ByProductCost: Decimal;
        ByProductCostACY: Decimal;
    begin
        // CalcProdByProductActCost
        with ProdOrderLine do begin
            ActByProductCost := 0;
            ActByProductCostACY := 0;

            SetRange(Status, Status);
            SetRange("Prod. Order No.", "Prod. Order No.");
            Find('-');
            repeat
                if "By-Product" then
                    AddProdLineByProductActCost(ProdOrderLine, ActByProductCost, ActByProductCostACY);
            until (Next = 0);
        end;
    end;

    local procedure AddProdLineByProductTargetCost(var ProdOrderLine: Record "Prod. Order Line"; var TargetByProductCost: Decimal; var TargetByProductCostACY: Decimal)
    var
        InvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)";
    begin
        // AddProdLineByProductTargetCost - not used, same as "CalcByProductLineTargetCost" routine in "Process 800 Prod. Order Mgt." codeunit
        with ProdOrderLine do begin
            InvtAdjmtEntryOrder.Get(InvtAdjmtEntryOrder."Order Type"::Production, "Prod. Order No.", "Line No."); // P8001132
            TargetByProductCost := "Unit Cost (By-Product)" * P800ProdOrderMgmt.CalcProdLineCostQty(ProdOrderLine, true);
            TargetByProductCostACY := InvtAdjmtEntryOrder.CalcAmtACY(TargetByProductCost); // P8001132
        end;
    end;

    procedure AddProdLineByProductActCost(var ProdOrderLine: Record "Prod. Order Line"; var ActByProductCost: Decimal; var ActByProductCostACY: Decimal)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        // AddProdLineByProductActCost
        with ProdOrderLine do begin
            ItemLedgEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type"); // P8000267B, P8001132
            ItemLedgEntry.SetRange("Order Type", ItemLedgEntry."Order Type"::Production); // P8001132
            ItemLedgEntry.SetRange("Order No.", "Prod. Order No."); // P8001132
            ItemLedgEntry.SetRange("Order Line No.", "Line No.");   // P8001132
            ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Output);
            if ItemLedgEntry.Find('-') then
                repeat
                    ItemLedgEntry.CalcFields("Cost Amount (Actual)", "Cost Amount (Actual) (ACY)"); // P8000085A
                    ActByProductCost := ActByProductCost + ItemLedgEntry."Cost Amount (Actual)";
                    ActByProductCostACY := ActByProductCostACY + ItemLedgEntry."Cost Amount (Actual) (ACY)"; // P8000085A
                until (ItemLedgEntry.Next = 0);
        end;
    end;

    procedure BuildProdCommonUOMQtys(var ProdOrderLine: Record "Prod. Order Line"; var TotalQty: Decimal; CalcActCost: Boolean)
    var
        ProdOrderLine2: Record "Prod. Order Line";
        ProdBOMVersion: Record "Production BOM Version";
        UnitOfMeasure: Record "Unit of Measure";
    begin
        // BuildProdCommonUOMQtys
        TotalQty := 0;

        ProdOrderLine2 := ProdOrderLine;
        with ProdOrderLine2 do begin
            ProdOrder.Get(Status, "Prod. Order No.");
            ProdBOMVersion.Get(ProdOrder."Source No.",
              VersionMgmt.GetBOMVersion(ProdOrder."Source No.", ProdOrder."Due Date", true));
            UnitOfMeasure.Get(ProdBOMVersion."Unit of Measure Code");

            TempCoProductLine.Reset;
            TempCoProductLine.DeleteAll;

            SetRange(Status, Status);
            SetRange("Prod. Order No.", "Prod. Order No.");
            Find('-');
            repeat
                if not "By-Product" then begin
                    if CalcActCost then begin
                        Quantity := "Finished Quantity";
                        "Quantity (Alt.)" := "Finished Qty. (Alt.)";
                    end;
                    GetItem("Item No.");
                    if (UnitOfMeasure.Type = UnitOfMeasure.Type::" ") then begin
                        if Item.CostInAlternateUnits() and
                           (Item."Alternate Unit of Measure" = UnitOfMeasure.Code)
                        then
                            Quantity := "Quantity (Alt.)"
                        else
                            if ("Unit of Measure Code" <> UnitOfMeasure.Code) then
                                Quantity :=
                                  ConvertProdQty(Quantity, "Unit of Measure Code", UnitOfMeasure.Code);
                    end else begin
                        if UseProdAltQty(ProdOrderLine, UnitOfMeasure.Type) then
                            Quantity :=
                              ConvertProdQty("Quantity (Alt.)", Item."Alternate Unit of Measure", UnitOfMeasure.Code)
                        else
                            Quantity :=
                              ConvertProdQty(Quantity, "Unit of Measure Code", UnitOfMeasure.Code);
                    end;
                    if Quantity > 0 then begin // P8000104A
                        Quantity := Quantity * "Co-Product Cost Share"; // P8001092
                        TotalQty := TotalQty + Quantity;
                        TempCoProductLine := ProdOrderLine2;
                        TempCoProductLine.Insert;
                    end;                       // P8000104A
                end;
            until (Next = 0);
        end;
    end;

    local procedure UseProdAltQty(var ProdOrderLine: Record "Prod. Order Line"; UnitType: Integer): Boolean
    var
        AltUnitOfMeasure: Record "Unit of Measure";
    begin
        // UseProdAltQty
        if not Item.CostInAlternateUnits() then
            exit(false);
        AltUnitOfMeasure.Get(Item."Alternate Unit of Measure");
        exit(AltUnitOfMeasure.Type = UnitType);
    end;

    local procedure ConvertProdQty(Qty: Decimal; FromUOM: Code[10]; ToUOM: Code[10]): Decimal
    begin
        // ConvertProdQty
        if (FromUOM = ToUOM) then // P8000979
            exit(Qty);              // P8000979
        exit(Qty * (UOMMgmt.GetQtyPerUnitOfMeasure(Item, FromUOM) /
                    UOMMgmt.GetQtyPerUnitOfMeasure(Item, ToUOM)));
    end;

    procedure CalcProdCostShare(var ProdOrderLine: Record "Prod. Order Line"; TotalQty: Decimal; SharedCost: Decimal; CurrencyCode: Code[10]): Decimal
    var
        Currency: Record Currency;
        LineCost: Decimal;
    begin
        // CalcProdCostShare
        if (TotalQty = 0) then
            exit(0);

        if (CurrencyCode <> '') then
            Currency.Get(CurrencyCode) // P8000693
        else                         // P8000693
            Currency.InitRoundingPrecision;

        TempCoProductLine.Reset;
        TempCoProductLine.Find('-');
        repeat
            LineCost := Round(SharedCost * (TempCoProductLine.Quantity / TotalQty),
                              Currency."Amount Rounding Precision");
            if (TempCoProductLine."Line No." = ProdOrderLine."Line No.") then
                exit(LineCost);
            TotalQty := TotalQty - TempCoProductLine.Quantity;
            SharedCost := SharedCost - LineCost;
        until (TempCoProductLine.Next = 0);
        exit(0);
    end;

    procedure CalcActNeededQtyBase(ProdOrderComp: Record "Prod. Order Component") NeededQty: Decimal
    var
        ProdOrderLine: Record "Prod. Order Line";
        CostCalcMgt: Codeunit "Cost Calculation Management";
        ExpectedOutput: Decimal;
        ActualOutput: Decimal;
    begin
        // P8000173A
        with ProdOrderComp do begin
            ProdOrderLine.SetRange(Status, Status);
            ProdOrderLine.SetRange("Prod. Order No.", "Prod. Order No.");
            ProdOrderLine.SetRange("By-Product", false);
            if ProdOrderLine.Find('-') then
                BuildProdCommonUOMQtys(ProdOrderLine, ExpectedOutput, false);
            if ExpectedOutput <> 0 then begin
                BuildProdCommonUOMQtys(ProdOrderLine, ActualOutput, true);
                NeededQty := ActualOutput / ExpectedOutput;
            end else
                NeededQty := 1;

            NeededQty := CostCalcMgt.CalcQtyAdjdForBOMScrap("Expected Qty. (Base)" * NeededQty, "Scrap %");
        end;
    end;

    procedure GetCoProductUnits(var ProdOrderLine: Record "Prod. Order Line"): Decimal
    begin
        // P8000370A
        TempCoProductLine := ProdOrderLine;
        if TempCoProductLine.Find then
            exit(TempCoProductLine.Quantity)
        else
            exit(0);
    end;

    procedure GetTraceTotalQty(var OutputEntry: Record "Item Ledger Entry"; var TotalQty: Decimal; var UOMCode: Code[10]): Decimal
    var
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderLine2: Record "Prod. Order Line";
        ProdBOMVersion: Record "Production BOM Version";
        UnitOfMeasure: Record "Unit of Measure";
        AltUOM: Record "Unit of Measure";
    begin
        // P8000979
        with ProdOrderLine do begin
            if not Get(Status::Finished, OutputEntry."Order No.", OutputEntry."Order Line No.") then // P8001132
                Get(Status::Released, OutputEntry."Order No.", OutputEntry."Order Line No.");          // P8001132
            if ProdBOMVersion.Get("Production BOM No.", "Production BOM Version Code") then
                UOMCode := ProdBOMVersion."Unit of Measure Code"
            else
                UOMCode := "Unit of Measure Code";
        end;
        UnitOfMeasure.Get(UOMCode);
        TotalQty := 0;
        with ProdOrderLine2 do begin
            SetRange(Status, ProdOrderLine.Status);
            SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
            FindSet;
            repeat
                GetTraceItem("Item No.", AltUOM);
                TotalQty := TotalQty +
                  GetQtyForTrace("Finished Quantity", "Finished Qty. (Alt.)", "Unit of Measure Code", UnitOfMeasure, AltUOM);
            until (Next = 0);
        end;
    end;

    procedure GetTraceEntryQty(var OutputEntry: Record "Item Ledger Entry"; var UOMCode: Code[10]): Decimal
    var
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderLine2: Record "Prod. Order Line";
        ProdBOMVersion: Record "Production BOM Version";
        UnitOfMeasure: Record "Unit of Measure";
        AltUOM: Record "Unit of Measure";
    begin
        // P8000979
        with OutputEntry do begin
            GetTraceItem("Item No.", AltUOM);
            UnitOfMeasure.Get(UOMCode);
            exit(GetQtyForTrace(Quantity, "Quantity (Alt.)", Item."Base Unit of Measure", UnitOfMeasure, AltUOM));
        end;
    end;

    local procedure GetTraceItem(ItemNo: Code[20]; var AltUOM: Record "Unit of Measure")
    begin
        // P8000979
        GetItem(ItemNo);
        if Item.TraceAltQty() then
            if (AltUOM.Code <> Item."Alternate Unit of Measure") then
                AltUOM.Get(Item."Alternate Unit of Measure");
    end;

    local procedure GetQtyForTrace(Qty: Decimal; QtyAlt: Decimal; UOMCode: Code[10]; var UnitOfMeasure: Record "Unit of Measure"; var AltUOM: Record "Unit of Measure"): Decimal
    begin
        // P8000979
        if Item.TraceAltQty() then
            if (UnitOfMeasure.Type = AltUOM.Type) then
                exit(ConvertProdQty(QtyAlt, Item."Alternate Unit of Measure", UnitOfMeasure.Code));
        exit(ConvertProdQty(Qty, UOMCode, UnitOfMeasure.Code));
    end;
}

