codeunit 5804 ItemCostManagement
{
    // PR2.00
    //   UpdateStdCostShares - update overhead rate
    // 
    // PR3.60
    //   Alternate units
    // 
    // PR3.61.02
    //   Integerate improvement 025
    // 
    // PR3.70.03
    //   Move code for updating cost on BOM Lines in UpdateUnitCost to "Process 800 BOM Functions"
    // 
    // P8000124A, Myers Nissi, Jack Reynolds, 30 SEP 04
    //   Fix division by zero problem with calculating average with expected cost
    // 
    // PR3.70.07
    // P8000146A, Myers Nissi, Jack Reynolds, 22 NOV 04
    //   CalculateAverageInclExpCost - check costing quantity for zero before dividing
    // 
    // PRW16.00.03
    // P8000805, VerticalSoft, Jack Reynolds, 31 MAR 10
    //   Fix problem calculating average cost
    // 
    // PRW16.00.04
    // P8000881, VerticalSoft, Don Bresee, 16 NOV 10
    //   Use "Costing" quantity where appropriate
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW17.00.01
    // P8001196, Columbus IT, Jack Reynolds, 16 AUG 13
    //   Fix problem setting unit cost to standard cost
    // 
    // PRW18.00.01
    // P8001386, Columbus IT, Jack Reynolds, 26 MAY 15
    //   Refactoring changess for cumulative updates
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    //
    // PRW111.00.03
    // P800146400, To Increase, Gangabhushan, 09 JUN 22
    //   CS00221633 | Adjust Cost Crashes with Div 0 Error

    Permissions = TableData Item = rm,
                  TableData "Stockkeeping Unit" = rm,
                  TableData "Value Entry" = r;

    trigger OnRun()
    begin
    end;

    var
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        InvtSetup: Record "Inventory Setup";
        CostCalcMgt: Codeunit "Cost Calculation Management";
        InvoicedQty: Decimal;
        RndgSetupRead: Boolean;
        CalledFromAdjustment: Boolean;
        InvtSetupRead: Boolean;
        GLSetupRead: Boolean;
        ItemUnitCostUpdated: Boolean;
        ProcessFns: Codeunit "Process 800 Functions";

    procedure IsItemUnitCostUpdated(): Boolean;
    begin
        exit(ItemUnitCostUpdated);
    end;

    procedure UpdateUnitCost(var Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; LastDirectCost: Decimal; NewStdCost: Decimal; UpdateSKU: Boolean; FilterSKU: Boolean; RecalcStdCost: Boolean; CalledByFieldNo: Integer)
    var
        CheckItem: Record Item;
        OriginalUnitCost: Decimal;
        P800BOMFns: Codeunit "Process 800 BOM Functions";
        MaintMgt: Codeunit "Maintenance Management";
        UnitCostUpdated: Boolean;
        RunOnModifyTrigger: Boolean;
        IsHandled: Boolean;
        xUnitCost: Decimal;
    begin
        ItemUnitCostUpdated := false;
        OnBeforeUpdateUnitCost(
          Item, LocationCode, VariantCode, LastDirectCost, NewStdCost, UpdateSKU, FilterSKU, RecalcStdCost, CalledByFieldNo, UnitCostUpdated, CalledFromAdjustment);
        if UnitCostUpdated then
            exit;

        with Item do begin
            OriginalUnitCost := "Unit Cost"; // PR2.00
            if NewStdCost <> 0 then
                "Standard Cost" := NewStdCost;

            xUnitCost := Item."Unit Cost";
            if "Costing Method" = "Costing Method"::Standard then
                "Unit Cost" := "Standard Cost"
            else
                if CalledFromAdjustment then
                    CalcUnitCostFromAverageCost(Item)
                else
                    UpdateUnitCostFromLastDirectCost(Item, LastDirectCost);
            ItemUnitCostUpdated := xUnitCost <> Item."Unit Cost";

            if RecalcStdCost then
                RecalcStdCostItem(Item);

            CheckUpdateLastDirectCost(Item, LastDirectCost);

            IsHandled := false;
            OnUpdateUnitCostOnBeforeValidatePriceProfitCalculation(Item, IsHandled);
            if not IsHandled then
                Validate("Price/Profit Calculation");

            RunOnModifyTrigger := CalledByFieldNo <> 0;
            OnUpdateUnitCostOnAfterCalcRunOnModifyTrigger(Item, RunOnModifyTrigger);
            if CheckItem.Get("No.") then
                if RunOnModifyTrigger then
                    Modify(true)
                else
                    Modify();

            OnUpdateUnitCostOnBeforeUpdateSKU(Item, UpdateSKU);
            if UpdateSKU then
                FindUpdateUnitCostSKU(Item, LocationCode, VariantCode, FilterSKU, LastDirectCost, RecalcStdCost, CalledByFieldNo); // P8001030, P8001386

            if ("Unit Cost" <> OriginalUnitCost) and ProcessFns.ProcessInstalled then // PR3.70.03
                P800BOMFns.UpdateBOMCost(Item);                                         // PR3.70.03
            if ("Unit Cost" <> OriginalUnitCost) and ProcessFns.MaintenanceInstalled then // P800 xxx
                MaintMgt.UpdatePMMtlUnitCost(Item);
        end;

        OnAfterUpdateUnitCost(Item, CalledByFieldNo);
    end;

    local procedure CalcUnitCostFromAverageCost(var Item: Record Item)
    var
        AverageCost: Decimal;
        AverageCostACY: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcUnitCostFromAverageCost(Item, CostCalcMgt, GLSetup, IsHandled);
        if IsHandled then
            exit;

        with Item do begin
            CostCalcMgt.GetRndgSetup(GLSetup, Currency, RndgSetupRead);
            if CalculateAverageCost(Item, AverageCost, AverageCostACY) then begin
                if AverageCost <> 0 then
                    "Unit Cost" := Round(AverageCost, GLSetup."Unit-Amount Rounding Precision");
            end else begin
                CalcLastAdjEntryAvgCost(Item, AverageCost, AverageCostACY);
                if AverageCost <> 0 then
                    "Unit Cost" := Round(AverageCost, GLSetup."Unit-Amount Rounding Precision");
            end;
        end;
    end;

    local procedure UpdateUnitCostFromLastDirectCost(var Item: Record Item; LastDirectCost: Decimal)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateUnitCostFromLastDirectCost(Item, LastDirectCost, InvoicedQty, IsHandled);
        if IsHandled then
            exit;

        with Item do
            if ("Unit Cost" = 0) or ((InvoicedQty > 0) and (LastDirectCost <> 0)) then begin
                // P8000881
                if CostInAlternateUnits() then begin
                    CalcFields("Net Invoiced Qty. (Alt.)");
                    if ("Net Invoiced Qty. (Alt.)" > 0) and ("Net Invoiced Qty. (Alt.)" <= InvoicedQty) then
                        "Unit Cost" := LastDirectCost;
                end else begin
                    // P8000881
                    CalcFields("Net Invoiced Qty.");
                    IsHandled := false;
                    OnUpdateUnitCostOnBeforeNetInvoiceQtyCheck(Item, IsHandled);
                    if ("Net Invoiced Qty." > 0) and ("Net Invoiced Qty." <= InvoicedQty) and not IsHandled then
                        "Unit Cost" := LastDirectCost;
                end; // P8000881
            end;
    end;

    local procedure CheckUpdateLastDirectCost(var Item: Record Item; LastDirectCost: Decimal)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckUpdateLastDirectCost(Item, LastDirectCost, IsHandled);
        if IsHandled then
            exit;

        if LastDirectCost <> 0 then
            Item."Last Direct Cost" := LastDirectCost;
    end;

    procedure UpdateStdCostShares(FromItem: Record Item)
    var
        Item: Record Item;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateStdCostShares(FromItem, IsHandled);
        if IsHandled then
            exit;

        with FromItem do begin
            Item.Get("No.");
            Item.Validate("Standard Cost", "Standard Cost");
            Item."Single-Level Material Cost" := "Single-Level Material Cost";
            Item."Single-Level Capacity Cost" := "Single-Level Capacity Cost";
            Item."Single-Level Subcontrd. Cost" := "Single-Level Subcontrd. Cost";
            Item."Single-Level Cap. Ovhd Cost" := "Single-Level Cap. Ovhd Cost";
            Item."Single-Level Mfg. Ovhd Cost" := "Single-Level Mfg. Ovhd Cost";
            Item."Rolled-up Material Cost" := "Rolled-up Material Cost";
            Item."Rolled-up Capacity Cost" := "Rolled-up Capacity Cost";
            Item."Rolled-up Subcontracted Cost" := "Rolled-up Subcontracted Cost";
            Item."Rolled-up Mfg. Ovhd Cost" := "Rolled-up Mfg. Ovhd Cost";
            Item."Rolled-up Cap. Overhead Cost" := "Rolled-up Cap. Overhead Cost";
            Item."Last Unit Cost Calc. Date" := "Last Unit Cost Calc. Date";
            Item."Overhead Rate" := "Overhead Rate"; // PR2.00
            OnUpdateStdCostSharesOnAfterCopyCosts(Item, FromItem);
            Item.Modify();
        end;
    end;

    procedure UpdateUnitCostSKU(Item: Record Item; var SKU: Record "Stockkeeping Unit"; LastDirectCost: Decimal; NewStdCost: Decimal; MatchSKU: Boolean; CalledByFieldNo: Integer)
    begin
        // P80096141 - Original signature
        UpdateUnitCostSKU(Item, SKU, LastDirectCost, NewStdCost, MatchSKU, false, 0, 0);
    end;

    procedure UpdateUnitCostSKU(Item: Record Item; var SKU: Record "Stockkeeping Unit"; LastDirectCost: Decimal; NewStdCost: Decimal; MatchSKU: Boolean; RecalcStdCost: Boolean; CalledByItemFieldNo: Integer; CalledByFieldNo: Integer)
    var
        ValueEntry: Record "Value Entry";
        AverageCost: Decimal;
        AverageCostACY: Decimal;
        UnitCostUpdated: Boolean;
        IsHandled: Boolean;
    begin
        OnBeforeUpdateUnitCostSKU(Item, SKU, LastDirectCost, NewStdCost, MatchSKU, CalledByFieldNo, UnitCostUpdated, CalledFromAdjustment);
        if UnitCostUpdated then
            exit;

        with SKU do begin
            if NewStdCost <> 0 then
                "Standard Cost" := NewStdCost;
            if Item."Costing Method" <> Item."Costing Method"::Standard then begin
                GetInvtSetup();
                if InvtSetup."Average Cost Calc. Type" <> InvtSetup."Average Cost Calc. Type"::Item then begin
                    IsHandled := false;
                    OnUpdateUnitCostSKUOnBeforeCalcNonItemAvgCostCalcType(Item, SKU, CalledFromAdjustment, IsHandled);
                    if not IsHandled then
                        if CalledFromAdjustment then begin
                            ValueEntry."Item No." := Item."No.";
                            ValueEntry."Valuation Date" := DMY2Date(31, 12, 9999);
                            ValueEntry."Location Code" := "Location Code";
                            ValueEntry."Variant Code" := "Variant Code";
                            ValueEntry.SumCostsTillValuationDate(ValueEntry);
                            if ValueEntry."Item Ledger Entry Quantity" <> 0 then begin
                                AverageCost :=
                                  (ValueEntry."Cost Amount (Actual)" + ValueEntry."Cost Amount (Expected)") /
                                  ValueEntry."Item Ledger Entry Quantity";
                                if AverageCost < 0 then
                                    AverageCost := 0;
                            end else begin
                                Item.SetRange("Location Filter", "Location Code");
                                Item.SetRange("Variant Filter", "Variant Code");
                                CalcLastAdjEntryAvgCost(Item, AverageCost, AverageCostACY);
                            end;
                            if AverageCost <> 0 then
                                "Unit Cost" := Round(AverageCost, GLSetup."Unit-Amount Rounding Precision");
                        end else
                            if ("Unit Cost" = 0) or ((InvoicedQty > 0) and MatchSKU and (LastDirectCost <> 0)) then begin
                                Item.SetRange("Location Filter", "Location Code");
                                Item.SetRange("Variant Filter", "Variant Code");
                                // P8000881
                                if Item.CostInAlternateUnits() then
                                    Item.CalcFields("Net Invoiced Qty. (Alt.)")
                                else
                                    // P8000881
                                    Item.CalcFields("Net Invoiced Qty.");
                                Item.SetRange("Location Filter");
                                Item.SetRange("Variant Filter");
                                // P8000881
                                if Item.CostInAlternateUnits() then begin
                                    if (Item."Net Invoiced Qty. (Alt.)" > 0) and (Item."Net Invoiced Qty. (Alt.)" <= InvoicedQty) then
                                        "Unit Cost" := LastDirectCost;
                                end else begin
                                    // P8000881
                                    if (Item."Net Invoiced Qty." > 0) and (Item."Net Invoiced Qty." <= InvoicedQty) then
                                        "Unit Cost" := LastDirectCost;
                                end; // P8000881
                            end;
                end else
                    "Unit Cost" := Item."Unit Cost";
            end else
            // P8001030
            begin // P8001196
                if (SKU."Routing No." = '') and (SKU."Production BOM No." = '') and
                  ((CalledByItemFieldNo in [Item.FieldNo("Routing No."), Item.FieldNo("Production BOM No.")]) or
                   (CalledByFieldNo in [SKU.FieldNo("Routing No."), SKU.FieldNo("Production BOM No.")]))
                then // P8001196
                    TransferCostsFromItemToSKU(Item, SKU);
                "Unit Cost" := "Standard Cost";
            end;

            if RecalcStdCost then
                RecalcStdCostSKU(SKU);
            // P8001030

            OnUpdateUnitCostSKUOnBeforeMatchSKU(SKU, Item);
            if MatchSKU and (LastDirectCost <> 0) then
                "Last Direct Cost" := LastDirectCost;

            if CalledByFieldNo <> 0 then
                Modify(true)
            else
                Modify();
        end;
    end;

    local procedure RecalcStdCostItem(var Item: Record Item)
    begin
        with Item do begin
            "Single-Level Material Cost" := "Standard Cost";
            "Single-Level Mfg. Ovhd Cost" := 0;
            "Single-Level Capacity Cost" := 0;
            "Single-Level Subcontrd. Cost" := 0;
            "Single-Level Cap. Ovhd Cost" := 0;
            "Rolled-up Material Cost" := "Standard Cost";
            "Rolled-up Mfg. Ovhd Cost" := 0;
            "Rolled-up Capacity Cost" := 0;
            "Rolled-up Subcontracted Cost" := 0;
            "Rolled-up Cap. Overhead Cost" := 0;
        end;

        OnAfterRecalcStdCostItem(Item);
    end;

    local procedure CalcLastAdjEntryAvgCost(var Item: Record Item; var AverageCost: Decimal; var AverageCostACY: Decimal)
    var
        ValueEntry: Record "Value Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        ComputeThisEntry: Boolean;
        IsSubOptimal: Boolean;
        AvgCostCalculated: Boolean;
    begin
        OnBeforeCalcLastAdjEntryAvgCost(Item, AverageCost, AverageCostACY, AvgCostCalculated);
        if AvgCostCalculated then
            exit;

        AverageCost := 0;
        AverageCostACY := 0;

        if CalculateQuantity(Item) <> 0 then
            exit;
        if not HasOpenEntries(Item) then
            exit;

        with ValueEntry do begin
            SetFilters(ValueEntry, Item);
            if Find('+') then
                repeat
                    ComputeThisEntry := ("Item Ledger Entry Quantity" < 0) and not Adjustment and not "Drop Shipment";
                    if ComputeThisEntry then begin
                        ItemLedgEntry.Get("Item Ledger Entry No.");
                        IsSubOptimal :=
                          ItemLedgEntry.Correction or
                          ((Item."Costing Method" = Item."Costing Method"::Average) and not "Valued By Average Cost");

                        // P8000805
                        //IF NOT IsSubOptimal OR (IsSubOptimal AND (AverageCost = 0)) THEN BEGIN
                        if (not IsSubOptimal or (IsSubOptimal and (AverageCost = 0))) and
                          (ItemLedgEntry.GetCostingQty <> 0)
                        then begin
                            // P8000805
                            ItemLedgEntry.CalcFields(
                              "Cost Amount (Expected)", "Cost Amount (Actual)",
                              "Cost Amount (Expected) (ACY)", "Cost Amount (Actual) (ACY)");
                            AverageCost :=
                              (ItemLedgEntry."Cost Amount (Expected)" +
                               ItemLedgEntry."Cost Amount (Actual)") /
                              //ItemLedgEntry.Quantity;    // P8000805
                              ItemLedgEntry.GetCostingQty; // P8000805
                            AverageCostACY :=
                              (ItemLedgEntry."Cost Amount (Expected) (ACY)" +
                               ItemLedgEntry."Cost Amount (Actual) (ACY)") /
                              //ItemLedgEntry.Quantity;    // P8000805
                              ItemLedgEntry.GetCostingQty; // P8000805

                            OnCalcLastAdjEntryAvgCostOnAfterCalcAverageCost(ItemLedgEntry, ValueEntry, Item, AverageCost, AverageCostACY);
                            if (AverageCost <> 0) and not IsSubOptimal then
                                exit;
                        end;
                    end;
                until Next(-1) = 0;
        end;
    end;

    procedure CalculateAverageCost(var Item: Record Item; var AverageCost: Decimal; var AverageCostACY: Decimal): Boolean
    var
        AverageQty: Decimal;
        CostAmt: Decimal;
        CostAmtACY: Decimal;
        NeedCalcPreciseAmt: Boolean;
        NeedCalcPreciseAmtACY: Boolean;
        AvgCostCalculated: Boolean;
    begin
        OnBeforeCalculateAverageCost(Item, AverageCost, AverageCostACY, AvgCostCalculated);
        if AvgCostCalculated then
            exit;

        AverageCost := 0;
        AverageCostACY := 0;

        if CalledFromAdjustment then
            ExcludeOpenOutbndCosts(Item, AverageCost, AverageCostACY, AverageQty);
        AverageQty := AverageQty + CalculateQuantity(Item);

        OnCalculateAverageCostOnAfterCalcAverageQty(Item, AverageCost, AverageCostACY, AverageQty);

        if AverageQty <> 0 then begin
            CostAmt := AverageCost + CalculateCostAmt(Item, true) + CalculateCostAmt(Item, false);
            if (CostAmt > 0) and (CostAmt = GLSetup."Amount Rounding Precision") then
                NeedCalcPreciseAmt := true;

            GetGLSetup();
            if GLSetup."Additional Reporting Currency" <> '' then begin
                Currency.Get(GLSetup."Additional Reporting Currency");
                CostAmtACY := AverageCostACY + CalculateCostAmtACY(Item, true) + CalculateCostAmtACY(Item, false);
                if (CostAmtACY > 0) and (CostAmtACY = Currency."Amount Rounding Precision") then
                    NeedCalcPreciseAmtACY := true;
            end;

            if NeedCalcPreciseAmt or NeedCalcPreciseAmtACY then
                CalculatePreciseCostAmounts(Item, NeedCalcPreciseAmt, NeedCalcPreciseAmtACY, CostAmt, CostAmtACY);

            AverageCost := CostAmt / AverageQty;
            AverageCostACY := CostAmtACY / AverageQty;

            if AverageCost < 0 then
                AverageCost := 0;
            if AverageCostACY < 0 then
                AverageCostACY := 0;
        end else begin
            AverageCost := 0;
            AverageCostACY := 0;
        end;
        if AverageQty <= 0 then
            exit(false);

        exit(true);
    end;

    procedure SetFilters(var ValueEntry: Record "Value Entry"; var Item: Record Item)
    begin
        with ValueEntry do begin
            Reset();
            SetCurrentKey("Item No.", "Valuation Date", "Location Code", "Variant Code");
            SetRange("Item No.", Item."No.");
            SetFilter("Valuation Date", Item.GetFilter("Date Filter"));
            SetFilter("Location Code", Item.GetFilter("Location Filter"));
            SetFilter("Variant Code", Item.GetFilter("Variant Filter"));
        end;
        OnAfterSetFilters(ValueEntry, Item);
    end;

    local procedure CalculateQuantity(var Item: Record Item) CalcQty: Decimal
    var
        ValueEntry: Record "Value Entry";
    begin
        with ValueEntry do begin
            SetFilters(ValueEntry, Item);
            CalcSums("Item Ledger Entry Quantity");
            CalcQty := "Item Ledger Entry Quantity";
            OnAfterCalculateQuantity(ValueEntry, Item, CalcQty);
            exit(CalcQty);
        end;
    end;

    local procedure CalculateCostAmt(var Item: Record Item; Actual: Boolean) CostAmount: Decimal
    var
        ValueEntry: Record "Value Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalculateCostAmount(Item, Actual, CostAmount, IsHandled);
        if IsHandled then
            exit(CostAmount);

        with ValueEntry do begin
            SetFilters(ValueEntry, Item);
            if Actual then begin
                CalcSums("Cost Amount (Actual)");
                exit("Cost Amount (Actual)");
            end;
            CalcSums("Cost Amount (Expected)");
            exit("Cost Amount (Expected)");
        end;
    end;

    local procedure CalculateCostAmtACY(var Item: Record Item; Actual: Boolean): Decimal
    var
        ValueEntry: Record "Value Entry";
    begin
        with ValueEntry do begin
            SetFilters(ValueEntry, Item);
            if Actual then begin
                CalcSums("Cost Amount (Actual) (ACY)");
                exit("Cost Amount (Actual) (ACY)");
            end;
            CalcSums("Cost Amount (Expected) (ACY)");
            exit("Cost Amount (Expected) (ACY)");
        end;
    end;

    local procedure CalculatePreciseCostAmounts(var Item: Record Item; NeedCalcPreciseAmt: Boolean; NeedCalcPreciseAmtACY: Boolean; var PreciseAmt: Decimal; var PreciseAmtACY: Decimal)
    var
        OpenInbndItemLedgEntry: Record "Item Ledger Entry";
        OpenOutbndItemLedgEntry: Record "Item Ledger Entry";
        TempItemLedgerEntry: Record "Item Ledger Entry" temporary;
        ItemApplicationEntry: Record "Item Application Entry";
    begin
        // Collect precise (not rounded) remaining cost on:
        // 1. open inbound item ledger entries;
        // 2. closed inbound item ledger entries the open outbound item entries are applied to.
        PreciseAmt := 0;
        PreciseAmtACY := 0;

        OpenInbndItemLedgEntry.SetRange("Item No.", Item."No.");
        OpenInbndItemLedgEntry.SetRange(Open, true);
        OpenInbndItemLedgEntry.SetRange(Positive, true);
        OpenInbndItemLedgEntry.SetRange("Location Code", Item.GetFilter("Location Filter"));
        OpenInbndItemLedgEntry.SetRange("Variant Code", Item.GetFilter("Variant Filter"));
        if OpenInbndItemLedgEntry.FindSet() then
            repeat
                TempItemLedgerEntry := OpenInbndItemLedgEntry;
                TempItemLedgerEntry.Insert();
            until OpenInbndItemLedgEntry.Next() = 0;

        OpenOutbndItemLedgEntry.CopyFilters(OpenInbndItemLedgEntry);
        OpenOutbndItemLedgEntry.SetRange(Positive, false);
        if OpenOutbndItemLedgEntry.FindSet() then
            repeat
                if ItemApplicationEntry.GetInboundEntriesTheOutbndEntryAppliedTo(OpenOutbndItemLedgEntry."Entry No.") then
                    repeat
                        if TempItemLedgerEntry.Get(ItemApplicationEntry."Inbound Item Entry No.") then begin
                            TempItemLedgerEntry."Remaining Quantity" -= ItemApplicationEntry.Quantity;
                            TempItemLedgerEntry."Remaining Quantity (Alt.)" -= ItemApplicationEntry."Quantity (Alt.)"; // P800146400
                            TempItemLedgerEntry.Modify();
                        end else begin
                            OpenInbndItemLedgEntry.Get(ItemApplicationEntry."Inbound Item Entry No.");
                            TempItemLedgerEntry := OpenInbndItemLedgEntry;
                            TempItemLedgerEntry."Remaining Quantity" := -ItemApplicationEntry.Quantity;
                            TempItemLedgerEntry."Remaining Quantity (Alt.)" := -ItemApplicationEntry."Quantity (Alt.)"; // P800146400
                            TempItemLedgerEntry.Insert();
                        end;
                    until ItemApplicationEntry.Next() = 0;
            until OpenOutbndItemLedgEntry.Next() = 0;

        with TempItemLedgerEntry do begin
            Reset();
            if FindSet() then
                repeat
                    if GetCostingInvQty() <> 0 then begin // P800146400
                        if NeedCalcPreciseAmt then begin
                            CalcFields("Cost Amount (Actual)", "Cost Amount (Expected)");
                            //PreciseAmt += ("Cost Amount (Actual)" + "Cost Amount (Expected)") / Quantity * "Remaining Quantity";   // P8007748
                            PreciseAmt += ("Cost Amount (Actual)" + "Cost Amount (Expected)") / GetCostingInvQty * GetCostingRemQty; // P8007748
                        end;
                        if NeedCalcPreciseAmtACY then begin
                            CalcFields("Cost Amount (Actual) (ACY)", "Cost Amount (Expected) (ACY)");
                            //PreciseAmtACY += ("Cost Amount (Actual) (ACY)" + "Cost Amount (Expected) (ACY)") / Quantity * "Remaining Quantity";   // P8007748
                            PreciseAmtACY += ("Cost Amount (Actual) (ACY)" + "Cost Amount (Expected) (ACY)") / GetCostingInvQty * GetCostingRemQty; // P8007748
                        end;
                    end; // P800146400
                until Next() = 0;
        end;
    end;

    local procedure ExcludeOpenOutbndCosts(var Item: Record Item; var CostAmt: Decimal; var CostAmtACY: Decimal; var Quantity: Decimal)
    var
        OpenItemLedgEntry: Record "Item Ledger Entry";
        OpenValueEntry: Record "Value Entry";
    begin
        with OpenValueEntry do begin
            OpenItemLedgEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive);
            OpenItemLedgEntry.SetRange("Item No.", Item."No.");
            OpenItemLedgEntry.SetRange(Open, true);
            OpenItemLedgEntry.SetRange(Positive, false);
            OpenItemLedgEntry.SetFilter("Location Code", Item.GetFilter("Location Filter"));
            OpenItemLedgEntry.SetFilter("Variant Code", Item.GetFilter("Variant Filter"));
            SetCurrentKey("Item Ledger Entry No.");
            OnExcludeOpenOutbndCostsOnAfterOpenItemLedgEntrySetFilters(OpenItemLedgEntry, Item);
            if OpenItemLedgEntry.Find('-') then
                repeat
                    SetRange("Item Ledger Entry No.", OpenItemLedgEntry."Entry No.");
                    if Find('-') then
                        repeat
                            CostAmt := CostAmt - "Cost Amount (Actual)" - "Cost Amount (Expected)";
                            CostAmtACY := CostAmtACY - "Cost Amount (Actual) (ACY)" - "Cost Amount (Expected) (ACY)";
                            Quantity := Quantity - "Item Ledger Entry Quantity";
                        until Next() = 0;
                until OpenItemLedgEntry.Next() = 0;
        end;

        OnAfterExcludeOpenOutbndCosts(Item, CostAmt, CostAmtACY, Quantity);
    end;

    local procedure HasOpenEntries(var Item: Record Item): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        with ItemLedgEntry do begin
            Reset();
            SetCurrentKey("Item No.", Open);
            SetRange("Item No.", Item."No.");
            SetRange(Open, true);
            SetFilter("Location Code", Item.GetFilter("Location Filter"));
            SetFilter("Variant Code", Item.GetFilter("Variant Filter"));
            exit(not FindFirst())
        end;
    end;

    procedure SetProperties(NewCalledFromAdjustment: Boolean; NewInvoicedQty: Decimal)
    begin
        CalledFromAdjustment := NewCalledFromAdjustment;
        InvoicedQty := NewInvoicedQty;
    end;

    local procedure GetInvtSetup()
    begin
        if not InvtSetupRead then
            InvtSetup.Get();
        InvtSetupRead := true;
    end;

    local procedure GetGLSetup()
    begin
        if not GLSetupRead then
            GLSetup.Get();
        GLSetupRead := true;
    end;

    procedure FindUpdateUnitCostSKU(Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; FilterSKU: Boolean; LastDirectCost: Decimal)
    begin
        // P80096141 - Original signature
        FindUpdateUnitCostSKU(Item, LocationCode, VariantCode, FilterSKU, LastDirectCost, false, 0);
    end;

    procedure FindUpdateUnitCostSKU(Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; FilterSKU: Boolean; LastDirectCost: Decimal; RecalcStdCost: Boolean; CalledByItemFieldNo: Integer)
    var
        SKU: Record "Stockkeeping Unit";
    begin
        GetInvtSetup();
        with SKU do begin
            SetRange("Item No.", Item."No.");
            if InvtSetup."Average Cost Calc. Type" <> InvtSetup."Average Cost Calc. Type"::Item then
                if FilterSKU then begin
                    SetFilter("Location Code", '%1|%2', '', LocationCode);
                    SetFilter("Variant Code", '%1|%2', '', VariantCode);
                end else begin
                    SetFilter("Location Code", Item.GetFilter("Location Filter"));
                    SetFilter("Variant Code", Item.GetFilter("Variant Filter"));
                end;
            OnFindUpdateUnitCostSKUOnBeforeLoopUpdateUnitCostSKU(SKU, FilterSKU);
            if Find('-') then
                repeat
                    UpdateUnitCostSKU(
                      Item, SKU, LastDirectCost, 0,
                      ("Location Code" = LocationCode) and ("Variant Code" = VariantCode), RecalcStdCost, CalledByItemFieldNo, 0); // P8001030, P8001386
                until Next() = 0;
        end;
    end;

    procedure UpdateStdCostSharesSKU(FromSKU: Record "Stockkeeping Unit")
    var
        SKU: Record "Stockkeeping Unit";
    begin
        // P8001030
        with FromSKU do begin
            SKU.Get("Location Code", "Item No.", "Variant Code");
            SKU.Validate("Standard Cost", "Standard Cost");
            SKU."Single-Level Material Cost" := "Single-Level Material Cost";
            SKU."Single-Level Capacity Cost" := "Single-Level Capacity Cost";
            SKU."Single-Level Subcontrd. Cost" := "Single-Level Subcontrd. Cost";
            SKU."Single-Level Cap. Ovhd Cost" := "Single-Level Cap. Ovhd Cost";
            SKU."Single-Level Mfg. Ovhd Cost" := "Single-Level Mfg. Ovhd Cost";
            SKU."Rolled-up Material Cost" := "Rolled-up Material Cost";
            SKU."Rolled-up Capacity Cost" := "Rolled-up Capacity Cost";
            SKU."Rolled-up Subcontracted Cost" := "Rolled-up Subcontracted Cost";
            SKU."Rolled-up Mfg. Ovhd Cost" := "Rolled-up Mfg. Ovhd Cost";
            SKU."Rolled-up Cap. Overhead Cost" := "Rolled-up Cap. Overhead Cost";
            SKU."Last Unit Cost Calc. Date" := "Last Unit Cost Calc. Date";
            SKU."Overhead Rate" := "Overhead Rate";
            SKU.Modify;
        end;
    end;

    procedure TransferCostsFromItemToSKU(FromItem: Record Item; var SKU: Record "Stockkeeping Unit")
    begin
        // P8001030
        with FromItem do begin
            SKU."Unit Cost" := "Unit Cost";
            SKU."Standard Cost" := "Standard Cost";
            SKU."Overhead Rate" := "Overhead Rate";
            SKU."Single-Level Material Cost" := "Single-Level Material Cost";
            SKU."Single-Level Capacity Cost" := "Single-Level Capacity Cost";
            SKU."Single-Level Subcontrd. Cost" := "Single-Level Subcontrd. Cost";
            SKU."Single-Level Cap. Ovhd Cost" := "Single-Level Cap. Ovhd Cost";
            SKU."Single-Level Mfg. Ovhd Cost" := "Single-Level Mfg. Ovhd Cost";
            SKU."Rolled-up Material Cost" := "Rolled-up Material Cost";
            SKU."Rolled-up Capacity Cost" := "Rolled-up Capacity Cost";
            SKU."Rolled-up Subcontracted Cost" := "Rolled-up Subcontracted Cost";
            SKU."Rolled-up Mfg. Ovhd Cost" := "Rolled-up Mfg. Ovhd Cost";
            SKU."Rolled-up Cap. Overhead Cost" := "Rolled-up Cap. Overhead Cost";
            SKU."Last Unit Cost Calc. Date" := "Last Unit Cost Calc. Date";
        end;
    end;

    procedure TransferCostsFromSKUToItem(FromSKU: Record "Stockkeeping Unit"; var Item: Record Item)
    begin
        // P8001030
        with FromSKU do begin
            Item."Unit Cost" := "Unit Cost";
            Item."Standard Cost" := "Standard Cost";
            Item."Overhead Rate" := "Overhead Rate";
            Item."Single-Level Material Cost" := "Single-Level Material Cost";
            Item."Single-Level Capacity Cost" := "Single-Level Capacity Cost";
            Item."Single-Level Subcontrd. Cost" := "Single-Level Subcontrd. Cost";
            Item."Single-Level Cap. Ovhd Cost" := "Single-Level Cap. Ovhd Cost";
            Item."Single-Level Mfg. Ovhd Cost" := "Single-Level Mfg. Ovhd Cost";
            Item."Rolled-up Material Cost" := "Rolled-up Material Cost";
            Item."Rolled-up Capacity Cost" := "Rolled-up Capacity Cost";
            Item."Rolled-up Subcontracted Cost" := "Rolled-up Subcontracted Cost";
            Item."Rolled-up Mfg. Ovhd Cost" := "Rolled-up Mfg. Ovhd Cost";
            Item."Rolled-up Cap. Overhead Cost" := "Rolled-up Cap. Overhead Cost";
            Item."Last Unit Cost Calc. Date" := "Last Unit Cost Calc. Date";
        end;
    end;

    local procedure RecalcStdCostSKU(var SKU: Record "Stockkeeping Unit")
    begin
        // P8001030
        with SKU do begin
            "Single-Level Material Cost" := "Standard Cost";
            "Single-Level Mfg. Ovhd Cost" := 0;
            "Single-Level Capacity Cost" := 0;
            "Single-Level Subcontrd. Cost" := 0;
            "Single-Level Cap. Ovhd Cost" := 0;
            "Rolled-up Material Cost" := "Standard Cost";
            "Rolled-up Mfg. Ovhd Cost" := 0;
            "Rolled-up Capacity Cost" := 0;
            "Rolled-up Subcontracted Cost" := 0;
            "Rolled-up Cap. Overhead Cost" := 0;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateQuantity(var ValueEntry: Record "Value Entry"; var Item: Record Item; var CalcQty: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterExcludeOpenOutbndCosts(var Item: Record Item; var CostAmt: Decimal; var CostAmtACY: Decimal; var Quantity: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRecalcStdCostItem(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetFilters(var ValueEntry: Record "Value Entry"; var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcLastAdjEntryAvgCost(var Item: Record Item; var AverageCost: Decimal; var AverageCostACY: Decimal; var AvgCostCalculated: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateCostAmount(var Item: Record Item; Actual: Boolean; var CostAmount: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateAverageCost(var Item: Record Item; var AverageCost: Decimal; var AverageCostACY: Decimal; var AvgCostCalculated: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcUnitCostFromAverageCost(var Item: Record Item; var CostCalcMgt: Codeunit "Cost Calculation Management"; GLSetup: Record "General Ledger Setup"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckUpdateLastDirectCost(var Item: Record Item; LastDirectCost: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateUnitCost(var Item: Record Item; LocationCode: Code[10]; VariantCode: Code[10]; LastDirectCost: Decimal; NewStdCost: Decimal; UpdateSKU: Boolean; FilterSKU: Boolean; RecalcStdCost: Boolean; CalledByFieldNo: Integer; var UnitCostUpdated: Boolean; var CalledFromAdjustment: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateUnitCostSKU(Item: Record Item; var SKU: Record "Stockkeeping Unit"; LastDirectCost: Decimal; NewStdCost: Decimal; MatchSKU: Boolean; CalledByFieldNo: Integer; var UnitCostUpdated: Boolean; var CalledFromAdjustment: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateStdCostShares(var Item: Record Item; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateUnitCostFromLastDirectCost(var Item: Record Item; LastDirectCost: Decimal; InvoicedQty: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcLastAdjEntryAvgCostOnAfterCalcAverageCost(ItemLedgEntry: Record "Item Ledger Entry"; ValueEntry: Record "Value Entry"; var Item: Record Item; var AverageCost: Decimal; var AverageCostACY: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalculateAverageCostOnAfterCalcAverageQty(var Item: Record Item; var AverageCost: Decimal; var AverageCostACY: Decimal; var AverageQty: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnExcludeOpenOutbndCostsOnAfterOpenItemLedgEntrySetFilters(var OpenItemLedgEntry: Record "Item Ledger Entry"; var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateUnitCostOnAfterCalcRunOnModifyTrigger(Item: Record Item; var RunOnModifyTrigger: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateUnitCostOnBeforeNetInvoiceQtyCheck(Item: Record Item; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateUnitCostOnBeforeUpdateSKU(var Item: Record Item; var UpdateSKU: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateUnitCostOnBeforeValidatePriceProfitCalculation(var Item: Record Item; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateUnitCostSKUOnBeforeMatchSKU(var StockkeepingUnit: Record "Stockkeeping Unit"; Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateStdCostSharesOnAfterCopyCosts(var Item: Record Item; FromItem: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateUnitCost(var Item: Record Item; CalledByFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateUnitCostSKUOnBeforeCalcNonItemAvgCostCalcType(Item: Record Item; var SKU: Record "Stockkeeping Unit"; CalledFromAdjustment: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindUpdateUnitCostSKUOnBeforeLoopUpdateUnitCostSKU(var SKU: Record "Stockkeeping Unit"; FilterSKU: Boolean)
    begin
    end;
}

