table 5896 "Inventory Adjmt. Entry (Order)"
{
    // PRW17.00
    // P8001134, Columbus IT, Don Bresee, 16 FEB 13
    //   Add new options to "Order Type"
    // 
    // PRW17.00.01
    // P8001195, Columbus IT, Jack Reynolds, 14 AUG 13
    //   Fix costing problems with repack and sales repack
    // 
    // P8001209, Columbus IT, Jack Reynolds, 16 SEP 13
    //   Fix problem calculating variance when costing by SKU
    // 
    // P800W18.00
    // P8001352, Columbus IT, Jack Reynolds, 30 OCT 14
    //   2015 Upgrade - Code merge and refactoring
    // 
    // PRW110.0.02
    // P80050651, To-Increase, Jack Reynolds, 05 FEB 18
    //   Adjust cost elements for BOM Orders
    // 
    // PRW110.0.03
    // P80056618, To-Increase, Jack Reynolds, 03 APR 18
    //   Fix problem setting overhead reate for production orders
    // 
    // PRW111.00.02
    // P80064362, To-Increase, Jack Reynolds, 06 SEP 18
    //   Fix problem useing item table costs instead of SKU costs
    //
    //   PRW114.00
    //   P80093298, To-Increase, Gangabhushan, 17 FEB 20
    //     CS00093764 - Adjust Cost error with Assembly Orders
    // 
    // PRW120.00
    // P800144605, To Increase, Jack Reynolds, 20 APR 22
    //   Upgrade to 20.0

    Caption = 'Inventory Adjmt. Entry (Order)';
    Permissions = TableData "Inventory Adjmt. Entry (Order)" = i;

    fields
    {
        field(1; "Order Type"; Enum "Inventory Order Type")
        {
            Caption = 'Order Type';
        }
        field(2; "Order No."; Code[20])
        {
            Caption = 'Order No.';
        }
        field(3; "Order Line No."; Integer)
        {
            Caption = 'Order Line No.';
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(7; "Routing No."; Code[20])
        {
            Caption = 'Routing No.';
            TableRelation = "Routing Header"."No.";
        }
        field(8; "Routing Reference No."; Integer)
        {
            Caption = 'Routing Reference No.';
        }
        field(21; "Indirect Cost %"; Decimal)
        {
            Caption = 'Indirect Cost %';
            DecimalPlaces = 0 : 5;
        }
        field(22; "Overhead Rate"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Overhead Rate';
        }
        field(29; "Cost is Adjusted"; Boolean)
        {
            Caption = 'Cost is Adjusted';
            InitValue = true;
        }
        field(30; "Allow Online Adjustment"; Boolean)
        {
            Caption = 'Allow Online Adjustment';
            InitValue = true;
        }
        field(41; "Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost';
        }
        field(42; "Direct Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Direct Cost';
        }
        field(43; "Indirect Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Indirect Cost';
        }
        field(44; "Single-Level Material Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Level Material Cost';
        }
        field(45; "Single-Level Capacity Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Level Capacity Cost';
        }
        field(46; "Single-Level Subcontrd. Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Level Subcontrd. Cost';
        }
        field(47; "Single-Level Cap. Ovhd Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Level Cap. Ovhd Cost';
        }
        field(48; "Single-Level Mfg. Ovhd Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Level Mfg. Ovhd Cost';
        }
        field(52; "Direct Cost (ACY)"; Decimal)
        {
            Caption = 'Direct Cost (ACY)';
        }
        field(53; "Indirect Cost (ACY)"; Decimal)
        {
            Caption = 'Indirect Cost (ACY)';
        }
        field(54; "Single-Lvl Material Cost (ACY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Lvl Material Cost (ACY)';
        }
        field(55; "Single-Lvl Capacity Cost (ACY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Lvl Capacity Cost (ACY)';
        }
        field(56; "Single-Lvl Subcontrd Cost(ACY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Lvl Subcontrd Cost(ACY)';
        }
        field(57; "Single-Lvl Cap. Ovhd Cost(ACY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Lvl Cap. Ovhd Cost(ACY)';
        }
        field(58; "Single-Lvl Mfg. Ovhd Cost(ACY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Single-Lvl Mfg. Ovhd Cost(ACY)';
        }
        field(61; "Completely Invoiced"; Boolean)
        {
            Caption = 'Completely Invoiced';
        }
        field(62; "Is Finished"; Boolean)
        {
            Caption = 'Is Finished';
        }
    }

    keys
    {
        key(Key1; "Order Type", "Order No.", "Order Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Cost is Adjusted", "Allow Online Adjustment")
        {
        }
    }

    fieldgroups
    {
    }

    var
        GLSetup: Record "General Ledger Setup";
        GLSetupRead: Boolean;
        AmtRndgPrec: Decimal;
        AmtRndgPrecACY: Decimal;
        UnitAmtRndgPrec: Decimal;
        UnitAmtRndgPrecACY: Decimal;
        SKU: Record "Stockkeeping Unit";

    procedure RoundCosts(ShareOfTotalCost: Decimal)
    begin
        GetRoundingPrecision(AmtRndgPrec, AmtRndgPrecACY);
        RoundAmounts(AmtRndgPrec, AmtRndgPrecACY, ShareOfTotalCost);
    end;

    local procedure RoundUnitCosts()
    begin
        GetUnitAmtRoundingPrecision(UnitAmtRndgPrec, UnitAmtRndgPrecACY);
        RoundAmounts(UnitAmtRndgPrec, UnitAmtRndgPrecACY, 1);
    end;

    local procedure RoundAmounts(RndPrecLCY: Decimal; RndPrecACY: Decimal; ShareOfTotalCost: Decimal)
    var
        RndResLCY: Decimal;
        RndResACY: Decimal;
    begin
        "Direct Cost" := RoundCost("Direct Cost", ShareOfTotalCost, RndResLCY, RndPrecLCY);
        "Indirect Cost" := RoundCost("Indirect Cost", ShareOfTotalCost, RndResLCY, RndPrecLCY);
        "Single-Level Material Cost" := RoundCost("Single-Level Material Cost", ShareOfTotalCost, RndResLCY, RndPrecLCY);
        "Single-Level Capacity Cost" := RoundCost("Single-Level Capacity Cost", ShareOfTotalCost, RndResLCY, RndPrecLCY);
        "Single-Level Subcontrd. Cost" := RoundCost("Single-Level Subcontrd. Cost", ShareOfTotalCost, RndResLCY, RndPrecLCY);
        "Single-Level Cap. Ovhd Cost" := RoundCost("Single-Level Cap. Ovhd Cost", ShareOfTotalCost, RndResLCY, RndPrecLCY);
        "Single-Level Mfg. Ovhd Cost" := RoundCost("Single-Level Mfg. Ovhd Cost", ShareOfTotalCost, RndResLCY, RndPrecLCY);

        "Direct Cost (ACY)" := RoundCost("Direct Cost (ACY)", ShareOfTotalCost, RndResACY, RndPrecACY);
        "Indirect Cost (ACY)" := RoundCost("Indirect Cost (ACY)", ShareOfTotalCost, RndResACY, RndPrecACY);
        "Single-Lvl Material Cost (ACY)" := RoundCost("Single-Lvl Material Cost (ACY)", ShareOfTotalCost, RndResACY, RndPrecACY);
        "Single-Lvl Capacity Cost (ACY)" := RoundCost("Single-Lvl Capacity Cost (ACY)", ShareOfTotalCost, RndResACY, RndPrecACY);
        "Single-Lvl Subcontrd Cost(ACY)" := RoundCost("Single-Lvl Subcontrd Cost(ACY)", ShareOfTotalCost, RndResACY, RndPrecACY);
        "Single-Lvl Cap. Ovhd Cost(ACY)" := RoundCost("Single-Lvl Cap. Ovhd Cost(ACY)", ShareOfTotalCost, RndResACY, RndPrecACY);
        "Single-Lvl Mfg. Ovhd Cost(ACY)" := RoundCost("Single-Lvl Mfg. Ovhd Cost(ACY)", ShareOfTotalCost, RndResACY, RndPrecACY);

        OnAfterRoundAmounts(Rec, RndPrecLCY, RndPrecACY, ShareOfTotalCost);
    end;

    procedure CalcOvhdCost(OutputQty: Decimal)
    begin
        GetRoundingPrecision(AmtRndgPrec, AmtRndgPrecACY);

        "Single-Level Mfg. Ovhd Cost" :=
          (("Single-Level Material Cost" + "Single-Level Capacity Cost" +
            "Single-Level Subcontrd. Cost" + "Single-Level Cap. Ovhd Cost") *
           "Indirect Cost %" / 100) +
          ("Overhead Rate" * OutputQty);
        "Single-Level Mfg. Ovhd Cost" := Round("Single-Level Mfg. Ovhd Cost", AmtRndgPrec);

        "Single-Lvl Mfg. Ovhd Cost(ACY)" :=
          (("Single-Lvl Material Cost (ACY)" + "Single-Lvl Capacity Cost (ACY)" +
            "Single-Lvl Subcontrd Cost(ACY)" + "Single-Lvl Cap. Ovhd Cost(ACY)") *
           "Indirect Cost %" / 100) +
          ("Overhead Rate" * OutputQty * CalcCurrencyFactor);
        "Single-Lvl Mfg. Ovhd Cost(ACY)" := Round("Single-Lvl Mfg. Ovhd Cost(ACY)", AmtRndgPrecACY);

        OnAfterCalcOvhdCost(xRec, Rec, GLSetup, OutputQty, AmtRndgPrec, AmtRndgPrecACY, CalcCurrencyFactor);
    end;

    procedure GetCostsFromItem(OutputQty: Decimal)
    begin
        GetUnroundedCostsFromItem;
        RoundCosts(OutputQty);
        CalcCostFromCostShares;
        AdjustCostsForOrderType; // P80050651
        Clear(SKU); // P80064362
    end;

    procedure GetUnitCostsFromItem()
    begin
        GetUnroundedCostsFromItem;
        RoundUnitCosts;
        CalcCostFromCostShares;
        AdjustCostsForOrderType; // P80050651
        Clear(SKU); // P80064362
    end;

    procedure GetUnitCostsFromProdOrderLine()
    begin
        GetSingleLevelCosts;
        RoundUnitCosts;
        CalcCostFromCostShares;
        AdjustCostsForOrderType; // P80050651
        Clear(SKU); // P80064362
    end;

    local procedure GetUnroundedCostsFromItem()
    var
        Item: Record Item;
    begin
        Item.Get("Item No.");
        GetSKUCosts(Item); // P80064362

        "Indirect Cost %" := Item."Indirect Cost %";
        "Overhead Rate" := Item."Overhead Rate";

        GetSingleLevelCosts;
    end;

    local procedure GetSingleLevelCosts()
    var
        Item: Record Item;
        CurrExchRate: Decimal;
    begin
        Item.Get("Item No.");
        GetSKUCosts(Item); // P80064362

        "Single-Level Material Cost" := Item."Single-Level Material Cost";
        "Single-Level Capacity Cost" := Item."Single-Level Capacity Cost";
        "Single-Level Subcontrd. Cost" := Item."Single-Level Subcontrd. Cost";
        "Single-Level Cap. Ovhd Cost" := Item."Single-Level Cap. Ovhd Cost";
        "Single-Level Mfg. Ovhd Cost" := Item."Single-Level Mfg. Ovhd Cost";

        CurrExchRate := CalcCurrencyFactor;
        "Direct Cost (ACY)" := "Direct Cost" * CurrExchRate;
        "Indirect Cost (ACY)" := "Indirect Cost" * CurrExchRate;
        "Single-Lvl Material Cost (ACY)" := "Single-Level Material Cost" * CurrExchRate;
        "Single-Lvl Capacity Cost (ACY)" := "Single-Level Capacity Cost" * CurrExchRate;
        "Single-Lvl Subcontrd Cost(ACY)" := "Single-Level Subcontrd. Cost" * CurrExchRate;
        "Single-Lvl Cap. Ovhd Cost(ACY)" := "Single-Level Cap. Ovhd Cost" * CurrExchRate;
        "Single-Lvl Mfg. Ovhd Cost(ACY)" := "Single-Level Mfg. Ovhd Cost" * CurrExchRate;

        OnAfterGetSingleLevelCosts(Rec, Item);
    end;

    local procedure CalcCostFromCostShares()
    begin
        CalcDirectCostFromCostShares;
        CalcIndirectCostFromCostShares;
        CalcUnitCost;
    end;

    local procedure CalcCurrencyFactor(): Decimal
    var
        OutputItemLedgEntry: Record "Item Ledger Entry";
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        GetRoundingPrecision(AmtRndgPrec, AmtRndgPrecACY);
        if GLSetup."Additional Reporting Currency" <> '' then begin
            OutputItemLedgEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type");
            OutputItemLedgEntry.SetRange("Order Type", "Order Type");
            OutputItemLedgEntry.SetRange("Order No.", "Order No.");
            if "Order Type" = "Order Type"::Production then begin
                OutputItemLedgEntry.SetRange("Order Line No.", "Order Line No.");
                OutputItemLedgEntry.SetRange("Entry Type", OutputItemLedgEntry."Entry Type"::Output);
            end else
                OutputItemLedgEntry.SetRange("Entry Type", OutputItemLedgEntry."Entry Type"::"Assembly Output");

            SetBOMILEFilters(OutputItemLedgEntry, true); // P8001134
            OnCalcCurrencyFactorOnAfterSetFilters(OutputItemLedgEntry, Rec);
            if OutputItemLedgEntry.FindLast() then
                exit(CurrExchRate.ExchangeRate(OutputItemLedgEntry."Posting Date", GLSetup."Additional Reporting Currency"));
        end;
    end;

    procedure SetProdOrderLine(ProdOrderLine: Record "Prod. Order Line")
    begin
        Init;
        "Order Type" := "Order Type"::Production;
        "Order No." := ProdOrderLine."Prod. Order No.";
        "Order Line No." := ProdOrderLine."Line No.";
        "Item No." := ProdOrderLine."Item No.";
        "Routing No." := ProdOrderLine."Routing No.";
        "Routing Reference No." := ProdOrderLine."Routing Reference No.";
        "Cost is Adjusted" := false;
        "Is Finished" := ProdOrderLine.Status = ProdOrderLine.Status::Finished;
        "Indirect Cost %" := ProdOrderLine."Indirect Cost %";
        "Overhead Rate" := ProdOrderLine."Overhead Rate" * ProdOrderLine.Quantity / ProdOrderLine.GetCostingQty(ProdOrderLine.FieldNo(Quantity)); // P80056618
        OnAfterSetProdOrderLineTransferFields(Rec, ProdOrderLine);
        SetSKU(ProdOrderLine."Item No.", ProdOrderLine."Variant Code", ProdOrderLine."Location Code"); // P80064362

        GetUnitCostsFromProdOrderLine;
        if not Insert() then;
    end;

    procedure SetAsmOrder(AssemblyHeader: Record "Assembly Header")
    begin
        SetSKU(AssemblyHeader."Item No.", AssemblyHeader."Variant Code", AssemblyHeader."Location Code"); // P80064362
        SetAssemblyDoc(AssemblyHeader."No.", AssemblyHeader."Item No.");
    end;

    procedure SetPostedAsmOrder(PostedAssemblyHeader: Record "Posted Assembly Header")
    begin
        SetSKU(PostedAssemblyHeader."Item No.", PostedAssemblyHeader."Variant Code", PostedAssemblyHeader."Location Code"); // P80064362
        SetAssemblyDoc(PostedAssemblyHeader."Order No.", PostedAssemblyHeader."Item No.");
    end;

    local procedure SetAssemblyDoc(OrderNo: Code[20]; ItemNo: Code[20])
    begin
        Init;
        "Order Type" := "Order Type"::Assembly;
        "Order No." := OrderNo;
        "Item No." := ItemNo;
        "Cost is Adjusted" := false;
        "Is Finished" := true;
        GetCostsFromItem(1);
        if not Insert() then;
    end;

    procedure CalcDirectCostFromCostShares()
    begin
        "Direct Cost" :=
          "Single-Level Material Cost" +
          "Single-Level Capacity Cost" +
          "Single-Level Subcontrd. Cost" +
          "Single-Level Cap. Ovhd Cost";
        "Direct Cost (ACY)" :=
          "Single-Lvl Material Cost (ACY)" +
          "Single-Lvl Capacity Cost (ACY)" +
          "Single-Lvl Subcontrd Cost(ACY)" +
          "Single-Lvl Cap. Ovhd Cost(ACY)";

        OnAfterCalcDirectCostFromCostShares(Rec);
    end;

    procedure CalcIndirectCostFromCostShares()
    begin
        "Indirect Cost" := "Single-Level Mfg. Ovhd Cost";
        "Indirect Cost (ACY)" := "Single-Lvl Mfg. Ovhd Cost(ACY)";
    end;

    procedure CalcUnitCost()
    begin
        "Unit Cost" := "Direct Cost" + "Indirect Cost";
    end;

    procedure CalcDiff(var InvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; OnlyCostShares: Boolean)
    begin
        if not OnlyCostShares then begin
            "Direct Cost" := InvtAdjmtEntryOrder."Direct Cost" - "Direct Cost";
            "Indirect Cost" := InvtAdjmtEntryOrder."Indirect Cost" - "Indirect Cost";
        end;
        "Single-Level Material Cost" := InvtAdjmtEntryOrder."Single-Level Material Cost" - "Single-Level Material Cost";
        "Single-Level Capacity Cost" := InvtAdjmtEntryOrder."Single-Level Capacity Cost" - "Single-Level Capacity Cost";
        "Single-Level Subcontrd. Cost" := InvtAdjmtEntryOrder."Single-Level Subcontrd. Cost" - "Single-Level Subcontrd. Cost";
        "Single-Level Cap. Ovhd Cost" := InvtAdjmtEntryOrder."Single-Level Cap. Ovhd Cost" - "Single-Level Cap. Ovhd Cost";
        "Single-Level Mfg. Ovhd Cost" := InvtAdjmtEntryOrder."Single-Level Mfg. Ovhd Cost" - "Single-Level Mfg. Ovhd Cost";

        if not OnlyCostShares then begin
            "Direct Cost (ACY)" := InvtAdjmtEntryOrder."Direct Cost (ACY)" - "Direct Cost (ACY)";
            "Indirect Cost (ACY)" := InvtAdjmtEntryOrder."Indirect Cost (ACY)" - "Indirect Cost (ACY)";
        end;
        "Single-Lvl Material Cost (ACY)" := InvtAdjmtEntryOrder."Single-Lvl Material Cost (ACY)" - "Single-Lvl Material Cost (ACY)";
        "Single-Lvl Capacity Cost (ACY)" := InvtAdjmtEntryOrder."Single-Lvl Capacity Cost (ACY)" - "Single-Lvl Capacity Cost (ACY)";
        "Single-Lvl Subcontrd Cost(ACY)" := InvtAdjmtEntryOrder."Single-Lvl Subcontrd Cost(ACY)" - "Single-Lvl Subcontrd Cost(ACY)";
        "Single-Lvl Cap. Ovhd Cost(ACY)" := InvtAdjmtEntryOrder."Single-Lvl Cap. Ovhd Cost(ACY)" - "Single-Lvl Cap. Ovhd Cost(ACY)";
        "Single-Lvl Mfg. Ovhd Cost(ACY)" := InvtAdjmtEntryOrder."Single-Lvl Mfg. Ovhd Cost(ACY)" - "Single-Lvl Mfg. Ovhd Cost(ACY)";

        OnAfterCalcDiff(Rec, InvtAdjmtEntryOrder, OnlyCostShares);
    end;

    procedure AddDirectCost(CostAmtLCY: Decimal; CostAmtACY: Decimal)
    begin
        "Direct Cost" += CostAmtLCY;
        "Direct Cost (ACY)" += CostAmtACY;
    end;

    procedure AddIndirectCost(CostAmtLCY: Decimal; CostAmtACY: Decimal)
    begin
        "Indirect Cost" += CostAmtLCY;
        "Indirect Cost (ACY)" += CostAmtACY;
    end;

    procedure AddSingleLvlMaterialCost(CostAmtLCY: Decimal; CostAmtACY: Decimal)
    begin
        OnBeforeAddSingleLvlMaterialCost(Rec, CostAmtLCY, CostAmtACY);

        "Single-Level Material Cost" += CostAmtLCY;
        "Single-Lvl Material Cost (ACY)" += CostAmtACY;

        OnAfterAddSingleLvlMaterialCost(Rec, CostAmtLCY, CostAmtACY);
    end;

    procedure AddSingleLvlCapacityCost(CostAmtLCY: Decimal; CostAmtACY: Decimal)
    begin
        OnBeforeAddSingleLvlCapacityCost(Rec, CostAmtLCY, CostAmtACY);

        "Single-Level Capacity Cost" += CostAmtLCY;
        "Single-Lvl Capacity Cost (ACY)" += CostAmtACY;

        OnAfterAddSingleLvlCapacityCost(Rec, CostAmtLCY, CostAmtACY);
    end;

    procedure AddSingleLvlSubcontrdCost(CostAmtLCY: Decimal; CostAmtACY: Decimal)
    begin
        OnBeforeAddSingleLvlSubcontrdCost(Rec, CostAmtLCY, CostAmtACY);

        "Single-Level Subcontrd. Cost" += CostAmtLCY;
        "Single-Lvl Subcontrd Cost(ACY)" += CostAmtACY;

        OnAfterAddSingleLvlSubcontrdCost(Rec, CostAmtLCY, CostAmtACY);
    end;

    procedure AddSingleLvlCapOvhdCost(CostAmtLCY: Decimal; CostAmtACY: Decimal)
    begin
        OnBeforeAddSingleLvlCapOvhdCost(Rec, CostAmtLCY, CostAmtACY);

        "Single-Level Cap. Ovhd Cost" += CostAmtLCY;
        "Single-Lvl Cap. Ovhd Cost(ACY)" += CostAmtACY;

        OnAfterAddSingleLvlCapOvhdCost(Rec, CostAmtLCY, CostAmtACY);
    end;

    procedure AddSingleLvlMfgOvhdCost(CostAmtLCY: Decimal; CostAmtACY: Decimal)
    begin
        OnBeforeAddSingleLvlMfgOvhdCost(Rec, CostAmtLCY, CostAmtACY);

        "Single-Level Mfg. Ovhd Cost" += CostAmtLCY;
        "Single-Lvl Mfg. Ovhd Cost(ACY)" += CostAmtACY;

        OnAfterAddSingleLvlMfgOvhdCost(Rec, CostAmtLCY, CostAmtACY);
    end;

    local procedure GetRoundingPrecision(var AmtRndingPrecLCY: Decimal; var AmtRndingPrecACY: Decimal)
    var
        Currency: Record Currency;
    begin
        if not GLSetupRead then
            GLSetup.Get();
        AmtRndingPrecLCY := GLSetup."Amount Rounding Precision";
        AmtRndingPrecACY := Currency."Amount Rounding Precision";
        if GLSetup."Additional Reporting Currency" <> '' then begin
            Currency.Get(GLSetup."Additional Reporting Currency");
            Currency.CheckAmountRoundingPrecision;
            AmtRndingPrecACY := Currency."Amount Rounding Precision"
        end;
        GLSetupRead := true;
    end;

    local procedure GetUnitAmtRoundingPrecision(var UnitAmtRndingPrecLCY: Decimal; var UnitAmtRndingPrecACY: Decimal)
    var
        Currency: Record Currency;
    begin
        if not GLSetupRead then
            GLSetup.Get();
        UnitAmtRndingPrecLCY := GLSetup."Unit-Amount Rounding Precision";
        UnitAmtRndingPrecACY := Currency."Unit-Amount Rounding Precision";
        if GLSetup."Additional Reporting Currency" <> '' then begin
            Currency.Get(GLSetup."Additional Reporting Currency");
            Currency.CheckAmountRoundingPrecision;
            UnitAmtRndingPrecACY := Currency."Unit-Amount Rounding Precision"
        end;
        GLSetupRead := true;
    end;

    local procedure RoundCost(Cost: Decimal; ShareOfTotal: Decimal; var RndRes: Decimal; AmtRndgPrec: Decimal): Decimal
    var
        UnRoundedCost: Decimal;
    begin
        if Cost <> 0 then begin
            UnRoundedCost := Cost * ShareOfTotal + RndRes;
            Cost := Round(UnRoundedCost, AmtRndgPrec);
            RndRes := UnRoundedCost - Cost;
            exit(Cost);
        end;
    end;

    local procedure SetSKU(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10])
    begin
        // P80064362
        SKU."Item No." := ItemNo;
        SKU."Variant Code" := VariantCode;
        SKU."Location Code" := LocationCode;
    end;

    local procedure GetSKUCosts(var Item: Record Item)
    var
        ProdOrderLine: Record "Prod. Order Line";
        AssemblyHeader: Record "Assembly Header";
        ItemLedgerEntry: Record "Item Ledger Entry";
        RepackOrder: Record "Repack Order";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        SalesLine: Record "Sales Line";
        ItemCostMgmt: Codeunit ItemCostManagement;
        PostedAssemblyHeader: Record "Posted Assembly Header";
    begin
        // P80064362
        if SKU."Item No." = '' then begin
            case "Order Type" of
                "Order Type"::Production:
                    begin
                        ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Released, ProdOrderLine.Status::Finished);
                        ProdOrderLine.SetRange("Prod. Order No.", "Order No.");
                        ProdOrderLine.SetRange("Line No.", "Order Line No.");
                        if ProdOrderLine.FindFirst then
                            SetSKU(ProdOrderLine."Item No.", ProdOrderLine."Variant Code", ProdOrderLine."Location Code");
                    end;
                "Order Type"::Assembly:
                    begin
                        // P80093298
                        PostedAssemblyHeader.SetRange("Order No.", "Order No.");
                        if PostedAssemblyHeader.FindLast then
                            SetSKU(PostedAssemblyHeader."Item No.", PostedAssemblyHeader."Variant Code", PostedAssemblyHeader."Location Code")
                        else begin
                            // P80093298
                            AssemblyHeader.Get(AssemblyHeader."Document Type"::Order, "Order No.");
                            SetSKU(AssemblyHeader."Item No.", AssemblyHeader."Variant Code", AssemblyHeader."Location Code");
                        end; // P80093298
                    end;
                "Order Type"::FOODLotCombination:
                    begin
                        ItemLedgerEntry.Get("Order Line No.");
                        SetSKU(ItemLedgerEntry."Item No.", ItemLedgerEntry."Variant Code", ItemLedgerEntry."Location Code");
                    end;
                "Order Type"::FOODRepack:
                    begin
                        RepackOrder.Get("Order No.");
                        SetSKU(RepackOrder."Item No.", RepackOrder."Variant Code", RepackOrder."Destination Location");
                    end;
                "Order Type"::FOODSalesRepack:
                    if SalesShipmentLine.Get("Order No.", "Order Line No.") then
                        SetSKU(SalesShipmentLine."No.", SalesShipmentLine."Variant Code", SalesShipmentLine."Location Code")
                    else begin
                        SalesShipmentHeader.Get("Order No.");
                        SalesLine.Get(SalesLine."Document Type"::Order, SalesShipmentHeader."Order No.", "Order Line No.");
                        SetSKU(SalesLine."No.", SalesLine."Variant Code", SalesLine."Location Code");
                    end;
            end;
        end;

        if SKU.Find then
            ItemCostMgmt.TransferCostsFromSKUToItem(SKU, Item);
    end;

    procedure SetLotCombination(ItemJnlLine: Record "Item Journal Line")
    begin
        SetSKU(ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ItemJnlLine."Location Code"); // P80064362
        SetBOM("Order Type"::FOODLotCombination, ItemJnlLine."Order No.", ItemJnlLine."Order Line No.", ItemJnlLine."Item No."); // P8001134, P8001195
    end;

    procedure SetRepackOrder(RepackOrder: Record "Repack Order")
    begin
        // P8001195 - change parameter to Repack Order (was Item Journal Line)
        SetSKU(RepackOrder."Item No.", RepackOrder."Variant Code", RepackOrder."Destination Location"); // P80064362
        SetBOM("Order Type"::FOODRepack, RepackOrder."No.", 0, RepackOrder."Item No."); // P8001134, P8001195
    end;

    procedure SetSalesRepack(OrderNo: Code[20]; OrderLineNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10])
    begin
        // P8001195 - change parameters
        // P80064362 - add parameters VariantCode and LocationCode
        SetSKU(ItemNo, VariantCode, LocationCode); // P80064362
        SetBOM("Order Type"::FOODSalesRepack, OrderNo, OrderLineNo, ItemNo) // P8001134, P8001195
    end;

    local procedure SetBOM(OrderType: Option; OrderNo: Code[20]; OrderLineNo: Integer; ItemNo: Code[20])
    begin
        // P8001134
        // P8001195 - change parameters
        Init;
        "Order Type" := OrderType;
        "Order No." := OrderNo;          // P8001195
        "Order Line No." := OrderLineNo; // P8001195
        "Item No." := ItemNo;            // P8001195
        "Cost is Adjusted" := false;
        "Completely Invoiced" := true;
        "Is Finished" := true;
        GetCostsFromItem(1);
        if not Insert then;
    end;

    procedure AdjustCostsForOrderType()
    begin
        // P80050651
        case "Order Type" of
            "Order Type"::FOODRepack:
                ; // Nothing to do
            "Order Type"::FOODSalesRepack, "Order Type"::FOODLotCombination:
                begin
                    "Overhead Rate" := 0;
                    "Indirect Cost %" := 0;

                    "Direct Cost" := "Direct Cost" + "Indirect Cost";
                    "Indirect Cost" := 0;
                    "Single-Level Material Cost" := "Direct Cost";
                    "Single-Level Capacity Cost" := 0;
                    "Single-Level Subcontrd. Cost" := 0;
                    "Single-Level Cap. Ovhd Cost" := 0;
                    "Single-Level Mfg. Ovhd Cost" := 0;

                    "Direct Cost (ACY)" := "Direct Cost (ACY)" + "Indirect Cost (ACY)";
                    "Indirect Cost (ACY)" := 0;
                    "Single-Lvl Material Cost (ACY)" := "Direct Cost (ACY)";
                    "Single-Lvl Capacity Cost (ACY)" := 0;
                    "Single-Lvl Subcontrd Cost(ACY)" := 0;
                    "Single-Lvl Cap. Ovhd Cost(ACY)" := 0;
                    "Single-Lvl Mfg. Ovhd Cost(ACY)" := 0;
                end;
        end;
    end;

    procedure SetBOMILEFilters(var ItemLedgEntry: Record "Item Ledger Entry"; FindBOMEntry: Boolean)
    begin
        // P8001134
        if IsBOMOrderType() then begin
            if ("Order Type" in ["Order Type"::FOODLotCombination, "Order Type"::FOODSalesRepack]) then
                ItemLedgEntry.SetRange("Order Line No.", "Order Line No.");
            if FindBOMEntry then
                ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::"Positive Adjmt.")
            else
                ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::"Negative Adjmt.");
        end;
    end;

    // P800144605
    procedure SetBOMILEFilters(var CalcActualMaterialCostQuery: Query "Calculate Actual Material Cost"; FindBOMEntry: Boolean)
    begin
        if IsBOMOrderType() then begin
            if ("Order Type" in ["Order Type"::FOODLotCombination, "Order Type"::FOODSalesRepack]) then
                CalcActualMaterialCostQuery.SetRange(Order_Line_No_, "Order Line No.");
            if FindBOMEntry then
                CalcActualMaterialCostQuery.SetRange(Entry_Type, "Item Ledger Entry Type"::"Positive Adjmt.")
            else
                CalcActualMaterialCostQuery.SetRange(Entry_Type, "Item Ledger Entry Type"::"Negative Adjmt.");
        end;
    end;

    procedure IsBOMOrderType(): Boolean
    begin
        exit("Order Type" in ["Order Type"::FOODLotCombination, "Order Type"::FOODRepack, "Order Type"::FOODSalesRepack]); // P8001134
    end;

    procedure CalcAmtACY(AmtLCY: Decimal): Decimal
    begin
        exit(AmtLCY * CalcCurrencyFactor()); // P8001134
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcOvhdCost(xInventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; var InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; GeneralLedgerSetup: Record "General Ledger Setup"; OutputQty: Decimal; AmtRndgPrec: Decimal; AmtRndgPrecACY: Decimal; CurrencyFactor: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcDiff(var InvtAdjmtEntryOrderRec: Record "Inventory Adjmt. Entry (Order)"; var InvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; OnlyCostShares: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcDirectCostFromCostShares(var InvtAdjmtEntryOrderRec: Record "Inventory Adjmt. Entry (Order)")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetSingleLevelCosts(var InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRoundAmounts(var InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; RndPrecLCY: Decimal; RndPrecACY: Decimal; ShareOfTotalCost: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetProdOrderLineTransferFields(var InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; ProdOrderLine: Record "Prod. Order Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddSingleLvlMaterialCost(var InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; var CostAmtLCY: Decimal; var CostAmtACY: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddSingleLvlMaterialCost(var InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; var CostAmtLCY: Decimal; var CostAmtACY: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddSingleLvlCapacityCost(var InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; var CostAmtLCY: Decimal; var CostAmtACY: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddSingleLvlCapacityCost(var InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; var CostAmtLCY: Decimal; var CostAmtACY: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddSingleLvlSubcontrdCost(var InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; var CostAmtLCY: Decimal; var CostAmtACY: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddSingleLvlSubcontrdCost(var InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; var CostAmtLCY: Decimal; var CostAmtACY: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddSingleLvlCapOvhdCost(var InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; var CostAmtLCY: Decimal; var CostAmtACY: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddSingleLvlCapOvhdCost(var InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; var CostAmtLCY: Decimal; var CostAmtACY: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddSingleLvlMfgOvhdCost(var InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; var CostAmtLCY: Decimal; var CostAmtACY: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddSingleLvlMfgOvhdCost(var InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; var CostAmtLCY: Decimal; var CostAmtACY: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcCurrencyFactorOnAfterSetFilters(var OutputItemLedgEntry: Record "Item Ledger Entry"; InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)")
    begin
    end;
}

