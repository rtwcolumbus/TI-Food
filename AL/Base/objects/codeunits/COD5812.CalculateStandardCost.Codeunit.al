codeunit 5812 "Calculate Standard Cost"
{
    // PR2.00
    //   Set Overhead Rate on item from ABC costs
    // 
    // PR3.60
    //   Add logic for alternate quantities
    //   Use Active version wehn calculating standard cost
    // 
    // PR3.70.03
    //   CalcMfgItem - call function to adjusts costs for co/by-products
    //   AdjustForCoProduct - adjusts costs for co-products
    // 
    // PR4.00
    // P8000219A, Myers Nissi, Jack Reynolds, 24 JUN 05
    //   CalcMfgItem - pass Item to CalcRtngCost; bypass ABC overhead if item has routing number
    //   CalcRtngCost - add parameter for tem record; call function to set costs from ABC cost
    // 
    // PRW15.00.01
    // P8000567A, VerticalSoft, Jack Reynolds, 13 FEB 08
    //   Modify to be in closer alignemnt with NA version
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10.02
    // P8001266, Columbus IT, Jack Reynolds, 21 JAN 14
    //   Fix standard cost calculation for co-products
    // 
    // PRW19.00.01
    // P8007573, To Increase, Jack Reynolds, 06 SEP 16
    //   another fix to standard cost calculation for co-products
    // 
    // PRW110.0.02
    // P80047611, To Increase, Jack Reynolds, 07 NOV 17
    //   Problem inserting records into NewTempSKU from TempItem


    trigger OnRun()
    begin
    end;

    var
        MfgSetup: Record "Manufacturing Setup";
        GLSetup: Record "General Ledger Setup";
        TempItem: Record Item temporary;
        TempWorkCenter: Record "Work Center" temporary;
        TempMachineCenter: Record "Machine Center" temporary;
        TempPriceListLine: Record "Price List Line" temporary;
        TempProductionBOMVersion: Record "Production BOM Version" temporary;
        TempRoutingVersion: Record "Routing Version" temporary;
        CostCalcMgt: Codeunit "Cost Calculation Management";
        VersionMgt: Codeunit VersionManagement;
        UOMMgt: Codeunit "Unit of Measure Management";
        Window: Dialog;
        MaxLevel: Integer;
        NextPriceListLineNo: Integer;
        CalculationDate: Date;
        CalcMultiLevel: Boolean;
        UseAssemblyList: Boolean;
        LogErrors: Boolean;
        ShowDialog: Boolean;
        StdCostWkshName: Text[50];
        ColIdx: Option ,StdCost,ExpCost,ActCost,Dev,"Var";
        RowIdx: Option ,MatCost,ResCost,ResOvhd,AsmOvhd,Total;

        Text000: Label 'Too many levels. Must be below %1.';
        Text001: Label '&Top level,&All levels';
        Text002: Label '@1@@@@@@@@@@@@@';
        CalcMfgPrompt: Label 'One or more subassemblies on the assembly list for item %1 use replenishment system Prod. Order. Do you want to calculate standard cost for those subassemblies?';
        TargetText: Label 'Standard Cost,Unit Price';
        RecursionInstruction: Label 'Calculate the %3 of item %1 %2 by rolling up the assembly list components. Select All levels to include and update the %3 of any subassemblies.', Comment = '%1 = Item No., %2 = Description';
        NonAssemblyItemError: Label 'Item %1 %2 does not use replenishment system Assembly. The %3 will not be calculated.', Comment = '%1 = Item No., %2 = Description';
        NoAssemblyListError: Label 'Item %1 %2 has no assembly list. The %3 will not be calculated.', Comment = '%1 = Item No., %2 = Description';
        NonAssemblyComponentWithList: Label 'One or more subassemblies on the assembly list for this item does not use replenishment system Assembly. The %1 for these subassemblies will not be calculated. Are you sure that you want to continue?';
        P800BOMFns: Codeunit "Process 800 BOM Functions";
        ItemCostMgmt: Codeunit ItemCostManagement;
        TempSKU: Record "Stockkeeping Unit" temporary;

    procedure SetProperties(NewCalculationDate: Date; NewCalcMultiLevel: Boolean; NewUseAssemblyList: Boolean; NewLogErrors: Boolean; NewStdCostWkshName: Text[50]; NewShowDialog: Boolean)
    begin
        TempItem.DeleteAll();
        TempSKU.DeleteAll(); // P8001030
        TempProductionBOMVersion.DeleteAll();
        TempRoutingVersion.DeleteAll();
        ClearAll();

        OnBeforeSetProperties(NewCalculationDate, NewCalcMultiLevel, NewUseAssemblyList, NewLogErrors, NewStdCostWkshName, NewShowDialog);

        CalculationDate := NewCalculationDate;
        CalcMultiLevel := NewCalcMultiLevel;
        UseAssemblyList := NewUseAssemblyList;
        LogErrors := NewLogErrors;
        StdCostWkshName := NewStdCostWkshName;
        ShowDialog := NewShowDialog;

        MaxLevel := 50;
        MfgSetup.Get();
        GLSetup.Get();

        OnAfterSetProperties(NewCalculationDate, NewCalcMultiLevel, NewUseAssemblyList, NewLogErrors, NewStdCostWkshName, NewShowDialog);
    end;

    procedure TestPreconditions(var Item: Record Item; var TempNewProductionBOMVersion: Record "Production BOM Version" temporary; var NewRtngVersionErrBuf: Record "Routing Version")
    var
        TempSKU2: Record "Stockkeeping Unit" temporary;
    begin
        CalcItems(Item, TempSKU2); // P8001030

        TempProductionBOMVersion.Reset();
        if TempProductionBOMVersion.Find('-') then
            repeat
                TempNewProductionBOMVersion := TempProductionBOMVersion;
                TempNewProductionBOMVersion.Insert();
            until TempProductionBOMVersion.Next() = 0;

        TempRoutingVersion.Reset();
        if TempRoutingVersion.Find('-') then
            repeat
                NewRtngVersionErrBuf := TempRoutingVersion;
                NewRtngVersionErrBuf.Insert();
            until TempRoutingVersion.Next() = 0;
    end;

    local procedure AnalyzeAssemblyList(var Item: Record Item; var Depth: Integer; var NonAssemblyItemWithList: Boolean; var ContainsProdBOM: Boolean)
    var
        BOMComponent: Record "BOM Component";
        SubItem: Record Item;
        BaseDepth: Integer;
        MaxDepth: Integer;
    begin
        if Item.IsMfgItem() and ((Item."Production BOM No." <> '') or (Item."Routing No." <> '')) then begin
            ContainsProdBOM := true;
            if Item."Production BOM No." <> '' then
                AnalyzeProdBOM(Item."Production BOM No.", Depth, NonAssemblyItemWithList, ContainsProdBOM)
            else
                Depth += 1;
            exit
        end;
        BOMComponent.SetRange("Parent Item No.", Item."No.");
        if BOMComponent.FindSet() then begin
            if not Item.IsAssemblyItem() then begin
                NonAssemblyItemWithList := true;
                exit
            end;
            Depth += 1;
            BaseDepth := Depth;
            repeat
                if BOMComponent.Type = BOMComponent.Type::Item then begin
                    SubItem.Get(BOMComponent."No.");
                    MaxDepth := BaseDepth;
                    AnalyzeAssemblyList(SubItem, MaxDepth, NonAssemblyItemWithList, ContainsProdBOM);
                    if MaxDepth > Depth then
                        Depth := MaxDepth
                end
            until BOMComponent.Next() = 0
        end;
    end;

    local procedure AnalyzeProdBOM(ProductionBOMNo: Code[20]; var Depth: Integer; var NonAssemblyItemWithList: Boolean; var ContainsProdBOM: Boolean)
    var
        ProdBOMLine: Record "Production BOM Line";
        SubItem: Record Item;
        PBOMVersionCode: Code[20];
        BaseDepth: Integer;
        MaxDepth: Integer;
    begin
        SetProdBOMFilters(ProdBOMLine, PBOMVersionCode, ProductionBOMNo);
        if ProdBOMLine.FindSet() then begin
            Depth += 1;
            BaseDepth := Depth;
            repeat
                case ProdBOMLine.Type of
                    ProdBOMLine.Type::Item:
                        begin
                            SubItem.Get(ProdBOMLine."No.");
                            MaxDepth := BaseDepth;
                            AnalyzeAssemblyList(SubItem, MaxDepth, NonAssemblyItemWithList, ContainsProdBOM);
                            if MaxDepth > Depth then
                                Depth := MaxDepth
                        end;
                    ProdBOMLine.Type::"Production BOM":
                        begin
                            MaxDepth := BaseDepth;
                            AnalyzeProdBOM(ProdBOMLine."No.", MaxDepth, NonAssemblyItemWithList, ContainsProdBOM);
                            MaxDepth -= 1;
                            if MaxDepth > Depth then
                                Depth := MaxDepth
                        end;
                end;
            until ProdBOMLine.Next() = 0
        end
    end;

    local procedure PrepareAssemblyCalculation(var Item: Record Item; var Depth: Integer; Target: Option "Standard Cost","Unit Price"; var ContainsProdBOM: Boolean) Instruction: Text[1024]
    var
        CalculationTarget: Text[80];
        SubNonAssemblyItemWithList: Boolean;
    begin
        CalculationTarget := SelectStr(Target, TargetText);
        if not Item.IsAssemblyItem() then
            Error(NonAssemblyItemError, Item."No.", Item.Description, CalculationTarget);
        AnalyzeAssemblyList(Item, Depth, SubNonAssemblyItemWithList, ContainsProdBOM);
        if Depth = 0 then
            Error(NoAssemblyListError, Item."No.", Item.Description, CalculationTarget);
        Instruction := StrSubstNo(RecursionInstruction, Item."No.", Item.Description, CalculationTarget);
        if SubNonAssemblyItemWithList then
            Instruction += StrSubstNo(NonAssemblyComponentWithList, CalculationTarget)
    end;

    procedure CalcItem(ItemNo: Code[20]; NewUseAssemblyList: Boolean)
    var
        Item: Record Item;
        ItemCostMgt: Codeunit ItemCostManagement;
        Instruction: Text[1024];
        NewCalcMultiLevel: Boolean;
        Depth: Integer;
        AssemblyContainsProdBOM: Boolean;
        CalcMfgItems: Boolean;
        IsHandled: Boolean;
        SKU: Record "Stockkeeping Unit";
        SKU2: Record "Stockkeeping Unit";
        ShowStrMenu: Boolean;
        ShowConfirm: Boolean;
    begin
        Item.Get(ItemNo);
        IsHandled := false;
        OnBeforeCalcItem(Item, NewUseAssemblyList, IsHandled);
        if IsHandled then
            exit;

        if NewUseAssemblyList then
            Instruction := PrepareAssemblyCalculation(Item, Depth, 1, AssemblyContainsProdBOM) // 1=StandardCost
        else
            if not Item.IsMfgItem() then
                exit;

        ShowStrMenu := not NewUseAssemblyList or (Depth > 1);
        OnCalcItemOnBeforeShowStrMenu(Item, ShowStrMenu, NewCalcMultiLevel);
        if ShowStrMenu then
            case StrMenu(Text001, 1, Instruction) of
                0:
                    exit;
                1:
                    NewCalcMultiLevel := false;
                2:
                    NewCalcMultiLevel := true;
            end;

        SetProperties(WorkDate(), NewCalcMultiLevel, NewUseAssemblyList, false, '', false);

        if NewUseAssemblyList then begin
            ShowConfirm := NewCalcMultiLevel and AssemblyContainsProdBOM;
            OnCalcItemOnAfterCalcShowConfirm(Item, CalcMfgItems, ShowConfirm);
            if ShowConfirm then
                CalcMfgItems := Confirm(CalcMfgPrompt, false, Item."No.");
            CalcAssemblyItem(ItemNo, Item, 0, CalcMfgItems)
        end else begin // P8001030
            CalcMfgSKU(ItemNo, '', '', SKU2, 0); // P8001030
                                                 // P8001030
            SKU.SetCurrentKey("Item No.");
            SKU.SetRange("Item No.", ItemNo);
            if SKU.FindSet then
                repeat
                    CalcMfgSKU(SKU."Item No.", SKU."Location Code", SKU."Variant Code", SKU2, 0);
                until SKU.Next = 0;
        end;
        // P8001030

        if TempItem.Find('-') then
            repeat
                TempItem.ConvertFieldsToCosting; // PR3.60
                ItemCostMgt.UpdateStdCostShares(TempItem);
            until TempItem.Next() = 0;
        // P8001030
        if TempSKU.Find('-') then
            repeat
                if (TempSKU."Location Code" = '') and (TempSKU."Variant Code" = '') then begin
                    Item.Get(TempSKU."Item No.");
                    ItemCostMgmt.TransferCostsFromSKUToItem(TempSKU, Item);
                    Item.ConvertFieldsToCosting;
                    ItemCostMgt.UpdateStdCostShares(Item);
                end else begin
                    TempSKU.ConvertFieldsToCosting;
                    ItemCostMgt.UpdateStdCostSharesSKU(TempSKU);
                end;
            until TempSKU.Next = 0;
        // P8001030
    end;

    procedure CalcItems(var Item: Record Item; var NewTempItem: Record Item)
    var
        TempSKU: Record "Stockkeeping Unit" temporary;
        Item2: Record Item;
    begin
        // P80096141 - Original signature
        NewTempItem.DeleteAll();

        CalcItems(Item, TempSKU);
        TempSKU.SetRange("Variant Code", '');
        TempSKU.SetRange("Location Code", '');
        if TempSKU.FindSet() then
            repeat
                Item2.Get(TempSKU."Item No.");
                TempItem := Item2;
                ItemCostMgmt.TransferCostsFromSKUToItem(TempSKU, TempItem);
                TempItem.Insert();
            until TempSKU.Next() = 0;
    end;

    procedure CalcItems(var Item: Record Item; var NewTempSKU: Record "Stockkeeping Unit")
    var
        Item2: Record Item;
        Item3: Record Item;
        NoOfRecords: Integer;
        LineCount: Integer;
        SKU: Record "Stockkeeping Unit";
        SKU2: Record "Stockkeeping Unit";
    begin
        // P8001030 - replace NewTempItem by NewTempSKU
        // P8001132 - restore NewTempItem, but keep NewTempSKU
        // P8009614
        NewTempSKU.DeleteAll(); // P8001030

        Item2.Copy(Item);
        OnBeforeCalcItems(Item2);

        NoOfRecords := Item.Count();
        if ShowDialog then
            Window.Open(Text002);

        if Item2.Find('-') then
            repeat
                LineCount := LineCount + 1;
                if ShowDialog then
                    Window.Update(1, Round(LineCount / NoOfRecords * 10000, 1));
                if UseAssemblyList then
                    CalcAssemblyItem(Item2."No.", Item3, 0, true)
                else begin // P8001030
                    CalcMfgSKU(Item2."No.", '', '', SKU2, 0); // P8001030
                                                              // P8001030
                    SKU.SetCurrentKey("Item No.");
                    SKU.SetRange("Item No.", Item2."No.");
                    if SKU.FindSet then
                        repeat
                            CalcMfgSKU(SKU."Item No.", SKU."Location Code", SKU."Variant Code", SKU2, 0);
                        until SKU.Next = 0;
                end;
            // P8001030
            until Item2.Next() = 0;

        TempItem.Reset();
        if TempItem.Find('-') then
            repeat
                TempItem.ConvertFieldsToCosting(); // PR3.60
                GetSKU(TempItem."No.", '', '', TempSKU); // P80047611
                ItemCostMgmt.TransferCostsFromItemToSKU(TempItem, TempSKU); // P8001030
                NewTempSKU := TempSKU;                                     // P8001030
                NewTempSKU.Insert();                                         // P8001030
            until TempItem.Next() = 0;

        // P8001030
        TempSKU.Reset;
        if TempSKU.Find('-') then
            repeat
                TempSKU.ConvertFieldsToCosting;
                NewTempSKU := TempSKU;
                NewTempSKU.Insert;
            until TempSKU.Next() = 0;
        // P8001030

        if ShowDialog then
            Window.Close();
    end;

    local procedure CalcAssemblyItem(ItemNo: Code[20]; var Item: Record Item; Level: Integer; CalcMfgItems: Boolean)
    var
        BOMComp: Record "BOM Component";
        CompItem: Record Item;
        Res: Record Resource;
        LotSize: Decimal;
        ComponentQuantity: Decimal;
        CompSKU: Record "Stockkeeping Unit";
    begin
        if Level > MaxLevel then
            Error(Text000, MaxLevel);

        if GetItem(ItemNo, Item) then
            exit;

        if not Item.IsAssemblyItem() then
            exit;

        if not CalcMultiLevel and (Level <> 0) then
            exit;

        BOMComp.SetRange("Parent Item No.", ItemNo);
        BOMComp.SetFilter(Type, '<>%1', BOMComp.Type::" ");
        if BOMComp.FindSet() then begin
            Item."Rolled-up Material Cost" := 0;
            Item."Rolled-up Capacity Cost" := 0;
            Item."Rolled-up Cap. Overhead Cost" := 0;
            Item."Rolled-up Mfg. Ovhd Cost" := 0;
            Item."Rolled-up Subcontracted Cost" := 0;
            Item."Single-Level Material Cost" := 0;
            Item."Single-Level Capacity Cost" := 0;
            Item."Single-Level Cap. Ovhd Cost" := 0;
            Item."Single-Level Subcontrd. Cost" := 0;
            OnCalcAssemblyItemOnAfterInitItemCost(Item);

            repeat
                case BOMComp.Type of
                    BOMComp.Type::Item:
                        begin
                            GetItem(BOMComp."No.", CompItem);
                            ComponentQuantity :=
                              BOMComp."Quantity per" *
                              UOMMgt.GetQtyPerUnitOfMeasure(CompItem, BOMComp."Unit of Measure Code");
                            if CompItem.IsInventoriableType() then
                                if CompItem.IsAssemblyItem() or CompItem.IsMfgItem() then begin
                                    if CompItem.IsAssemblyItem() then
                                        CalcAssemblyItem(BOMComp."No.", CompItem, Level + 1, CalcMfgItems)
                                    else
                                        // P8001132
                                        //IF CalcMfgItems THEN
                                        //  CalcMfgItem(BOMComp."No.",CompItem,Level + 1);
                                        if CalcMfgItems then begin
                                            GetSKU(BOMComp."No.", '', BOMComp."Variant Code", CompSKU);
                                            CalcMfgSKU(BOMComp."No.", '', BOMComp."Variant Code", CompSKU, Level + 1);
                                            ItemCostMgmt.TransferCostsFromSKUToItem(CompSKU, CompItem);
                                            CompItem.ConvertFieldsToCosting;
                                        end;
                                    // P8001132
                                    Item."Rolled-up Material Cost" += ComponentQuantity * CompItem."Rolled-up Material Cost";
                                    Item."Rolled-up Capacity Cost" += ComponentQuantity * CompItem."Rolled-up Capacity Cost";
                                    Item."Rolled-up Cap. Overhead Cost" += ComponentQuantity * CompItem."Rolled-up Cap. Overhead Cost";
                                    Item."Rolled-up Mfg. Ovhd Cost" += ComponentQuantity * CompItem."Rolled-up Mfg. Ovhd Cost";
                                    Item."Rolled-up Subcontracted Cost" += ComponentQuantity * CompItem."Rolled-up Subcontracted Cost";
                                    Item."Single-Level Material Cost" += ComponentQuantity * CompItem."Standard Cost"
                                end else begin
                                    Item."Rolled-up Material Cost" += ComponentQuantity * CompItem."Unit Cost";
                                    Item."Single-Level Material Cost" += ComponentQuantity * CompItem."Unit Cost"
                                end;
                            OnCalcAssemblyItemOnAfterCalcItemCost(Item, CompItem, BOMComp, ComponentQuantity);
                        end;
                    BOMComp.Type::Resource:
                        begin
                            LotSize := 1;
                            if BOMComp."Resource Usage Type" = BOMComp."Resource Usage Type"::Fixed then
                                if Item."Lot Size" <> 0 then
                                    LotSize := Item."Lot Size";

                            GetResCost(BOMComp."No.", TempPriceListLine);
                            Res.Get(BOMComp."No.");
                            ComponentQuantity :=
                              BOMComp."Quantity per" *
                              UOMMgt.GetResQtyPerUnitOfMeasure(Res, BOMComp."Unit of Measure Code") /
                              LotSize;
                            Item."Single-Level Capacity Cost" += ComponentQuantity * TempPriceListLine."Direct Unit Cost";
                            Item."Single-Level Cap. Ovhd Cost" += ComponentQuantity * (TempPriceListLine."Unit Cost" - TempPriceListLine."Direct Unit Cost");
                        end;
                end;
            until BOMComp.Next() = 0;

            Item."Single-Level Mfg. Ovhd Cost" :=
              Round(
                (Item."Single-Level Material Cost" +
                 Item."Single-Level Capacity Cost" +
                 Item."Single-Level Cap. Ovhd Cost") * Item."Indirect Cost %" / 100 +
                Item."Overhead Rate",
                GLSetup."Unit-Amount Rounding Precision");
            Item."Rolled-up Material Cost" :=
              Round(
                Item."Rolled-up Material Cost",
                GLSetup."Unit-Amount Rounding Precision");
            Item."Rolled-up Capacity Cost" :=
              Round(
                Item."Rolled-up Capacity Cost" + Item."Single-Level Capacity Cost",
                GLSetup."Unit-Amount Rounding Precision");
            Item."Rolled-up Cap. Overhead Cost" :=
              Round(
                Item."Rolled-up Cap. Overhead Cost" + Item."Single-Level Cap. Ovhd Cost",
                GLSetup."Unit-Amount Rounding Precision");
            Item."Rolled-up Mfg. Ovhd Cost" :=
              Round(
                Item."Rolled-up Mfg. Ovhd Cost" + Item."Single-Level Mfg. Ovhd Cost",
                GLSetup."Unit-Amount Rounding Precision");
            Item."Rolled-up Subcontracted Cost" :=
              Round(
                Item."Rolled-up Subcontracted Cost",
                GLSetup."Unit-Amount Rounding Precision");

            OnCalcAssemblyItemOnAfterCalcItemRolledupCost(Item);

            Item."Standard Cost" :=
              Round(
                Item."Single-Level Material Cost" +
                Item."Single-Level Capacity Cost" +
                Item."Single-Level Cap. Ovhd Cost" +
                Item."Single-Level Mfg. Ovhd Cost" +
                Item."Single-Level Subcontrd. Cost",
                GLSetup."Unit-Amount Rounding Precision");
            Item."Single-Level Capacity Cost" :=
              Round(
                Item."Single-Level Capacity Cost",
                GLSetup."Unit-Amount Rounding Precision");
            Item."Single-Level Cap. Ovhd Cost" :=
              Round(
                Item."Single-Level Cap. Ovhd Cost",
                GLSetup."Unit-Amount Rounding Precision");

            OnCalcAssemblyItemOnAfterCalcSingleLevelCost(Item);

            Item."Last Unit Cost Calc. Date" := CalculationDate;

            TempItem := Item;
            TempItem.Insert();
        end
    end;

    procedure CalcAssemblyItemPrice(ItemNo: Code[20])
    var
        Item: Record Item;
        Instruction: Text[1024];
        Depth: Integer;
        NewCalcMultiLevel: Boolean;
        AssemblyContainsProdBOM: Boolean;
    begin
        Item.Get(ItemNo);
        Instruction := PrepareAssemblyCalculation(Item, Depth, 2, AssemblyContainsProdBOM); // 2=UnitPrice
        if Depth > 1 then
            case StrMenu(Text001, 1, Instruction) of
                0:
                    exit;
                1:
                    NewCalcMultiLevel := false;
                2:
                    NewCalcMultiLevel := true;
            end;

        SetProperties(WorkDate(), NewCalcMultiLevel, true, false, '', false);

        Item.Get(ItemNo);
        DoCalcAssemblyItemPrice(Item, 0);
    end;

    local procedure DoCalcAssemblyItemPrice(var Item: Record Item; Level: Integer)
    var
        BOMComp: Record "BOM Component";
        CompItem: Record Item;
        CompResource: Record Resource;
        UnitPrice: Decimal;
    begin
        if Level > MaxLevel then
            Error(Text000, MaxLevel);

        if not CalcMultiLevel and (Level <> 0) then
            exit;

        if not Item.IsAssemblyItem() then
            exit;

        BOMComp.SetRange("Parent Item No.", Item."No.");
        if BOMComp.Find('-') then begin
            repeat
                case BOMComp.Type of
                    BOMComp.Type::Item:
                        if CompItem.Get(BOMComp."No.") then begin
                            DoCalcAssemblyItemPrice(CompItem, Level + 1);
                            UnitPrice +=
                              BOMComp."Quantity per" *
                              UOMMgt.GetQtyPerUnitOfMeasure(CompItem, BOMComp."Unit of Measure Code") *
                              CompItem."Unit Price";
                        end;
                    BOMComp.Type::Resource:
                        if CompResource.Get(BOMComp."No.") then
                            UnitPrice +=
                              BOMComp."Quantity per" *
                              UOMMgt.GetResQtyPerUnitOfMeasure(CompResource, BOMComp."Unit of Measure Code") *
                              CompResource."Unit Price";
                end
            until BOMComp.Next() = 0;
            UnitPrice := Round(UnitPrice, GLSetup."Unit-Amount Rounding Precision");
            Item.Validate("Unit Price", UnitPrice);
            Item.Modify(true)
        end;
    end;

    local procedure CalcMfgSKU(ItemNo: Code[20]; LocationCode: Code[10]; VariantCode: Code[10]; var SKU: Record "Stockkeeping Unit"; Level: Integer)
    var
        LotSize: Decimal;
        MfgItemQtyBase: Decimal;
        SLMat: Decimal;
        SLCap: Decimal;
        SLSub: Decimal;
        SLCapOvhd: Decimal;
        SLMfgOvhd: Decimal;
        RUMat: Decimal;
        RUCap: Decimal;
        RUSub: Decimal;
        RUCapOvhd: Decimal;
        RUMfgOvhd: Decimal;
        Item: Record Item;
    begin
        OnBeforeCalcMfgItem(Item, LogErrors, StdCostWkshName);
        // P8001030 - renamed from CalcMfgItem; add parameter for VariantCode, LocationCode; replace Item with SKU
        if Level > MaxLevel then
            Error(Text000, MaxLevel);

        if GetSKU(ItemNo, LocationCode, VariantCode, SKU) then // P8001030
            exit;

        if not CalcMultiLevel and (Level <> 0) then
            exit;

        with SKU do begin // P8001030
            LotSize := 1;

            Item.Get(ItemNo); // P8001030
            if IsMfgItem() then begin
                // P8001030
                if "Production BOM No." = '' then
                    "Production BOM No." := Item."Production BOM No.";
                Item."Production BOM No." := "Production BOM No.";
                if "Routing No." = '' then
                    "Routing No." := Item."Routing No.";
                // P8001030

                if "Lot Size" <> 0 then
                    LotSize := "Lot Size";
                MfgItemQtyBase := CostCalcMgt.CalcQtyAdjdForBOMScrap(LotSize, Item."Scrap %"); // P8001030
                OnCalcMfgItemOnBeforeCalcRtngCost(Item, Level, LotSize, MfgItemQtyBase);
                CalcRtngCost("Routing No.", MfgItemQtyBase, SLCap, SLSub, SLCapOvhd, Item, LocationCode); // P8000219A, P8001030
                CalcProdBOMCost(
                  Item, LocationCode, "Production BOM No.", "Routing No.", // P8001030
                  MfgItemQtyBase, true, Level, SLMat, RUMat, RUCap, RUSub, RUCapOvhd, RUMfgOvhd);
                if "Routing No." = '' then // P8000219A
                    P800BOMFns.CalcABCOverhead(Item, SKU, "Production BOM No.", CalculationDate); // PR3.60, P8001030
                AdjustForCoProduct(Item, LocationCode, "Production BOM No.", CalculationDate, // PR3.70.03, P8001030
                  SLMat, RUMat, "Overhead Rate");                          // PR3.70.03, P8001266
                SLMfgOvhd :=
                  CostCalcMgt.CalcOvhdCost(
                    SLMat + SLCap + SLSub + SLCapOvhd,
                    "Indirect Cost %", "Overhead Rate", LotSize);
                "Last Unit Cost Calc. Date" := CalculationDate;
                // P8001030
            end else
                if SKU.IsTransItem then begin
                    CalcTransferCost(Item, SKU, Level, SLMat, RUMat);
                    // P8001030
                end else
                    if Item.IsAssemblyItem() then begin // P8001132
                        CalcAssemblyItem(ItemNo, Item, Level, true);
                        ItemCostMgmt.TransferCostsFromItemToSKU(Item, SKU); // P8001132
                        exit
                    end else begin
                        SLMat := "Unit Cost";
                        RUMat := "Unit Cost";
                    end;

            // OnCalcMfgItemOnBeforeCalculateCosts(
            //     SLMat, SLCap, SLSub, SLCapOvhd, SLMfgOvhd, Item, LotSize, MfgItemQtyBase, Level, CalculationDate, RUMat);
            OnCalcMfgSKUOnBeforeCalculateCosts(
                SLMat, SLCap, SLSub, SLCapOvhd, SLMfgOvhd, SKU, LotSize, MfgItemQtyBase, Level, CalculationDate, RUMat);

            "Single-Level Material Cost" := CalcCostPerUnit(SLMat, LotSize);
            "Single-Level Capacity Cost" := CalcCostPerUnit(SLCap, LotSize);
            "Single-Level Subcontrd. Cost" := CalcCostPerUnit(SLSub, LotSize);
            "Single-Level Cap. Ovhd Cost" := CalcCostPerUnit(SLCapOvhd, LotSize);
            "Single-Level Mfg. Ovhd Cost" := CalcCostPerUnit(SLMfgOvhd, LotSize);
            "Rolled-up Material Cost" := CalcCostPerUnit(RUMat, LotSize);
            "Rolled-up Capacity Cost" := CalcCostPerUnit(RUCap + SLCap, LotSize);
            "Rolled-up Subcontracted Cost" := CalcCostPerUnit(RUSub + SLSub, LotSize);
            "Rolled-up Cap. Overhead Cost" := CalcCostPerUnit(RUCapOvhd + SLCapOvhd, LotSize);
            "Rolled-up Mfg. Ovhd Cost" := CalcCostPerUnit(RUMfgOvhd + SLMfgOvhd, LotSize);
            "Standard Cost" :=
              "Single-Level Material Cost" +
              "Single-Level Capacity Cost" +
              "Single-Level Subcontrd. Cost" +
              "Single-Level Cap. Ovhd Cost" +
              "Single-Level Mfg. Ovhd Cost";
        end;

        TempSKU := SKU; // P8001030
        TempSKU.Insert(); // P8001030
    end;

    local procedure SetProdBOMFilters(var ProdBOMLine: Record "Production BOM Line"; var PBOMVersionCode: Code[20]; ProdBOMNo: Code[20])
    var
        ProdBOMHeader: Record "Production BOM Header";
    begin
        PBOMVersionCode :=
          VersionMgt.GetBOMVersion(ProdBOMNo, CalculationDate, true);
        if PBOMVersionCode = '' then begin
            ProdBOMHeader.Get(ProdBOMNo);
            TestBOMVersionIsCertified(PBOMVersionCode, ProdBOMHeader);
        end;

        with ProdBOMLine do begin
            SetRange("Production BOM No.", ProdBOMNo);
            SetRange("Version Code", PBOMVersionCode);
            SetFilter("Starting Date", '%1|..%2', 0D, CalculationDate);
            SetFilter("Ending Date", '%1|%2..', 0D, CalculationDate);
            SetFilter("No.", '<>%1', '')
        end;

        OnAfterSetProdBOMFilters(ProdBOMLine, PBOMVersionCode, ProdBOMNo);
    end;

    local procedure CalcProdBOMCost(MfgItem: Record Item; LocationCode: Code[10]; ProdBOMNo: Code[20]; RtngNo: Code[20]; MfgItemQtyBase: Decimal; IsTypeItem: Boolean; Level: Integer; var SLMat: Decimal; var RUMat: Decimal; var RUCap: Decimal; var RUSub: Decimal; var RUCapOvhd: Decimal; var RUMfgOvhd: Decimal)
    var
        CompSKU: Record "Stockkeeping Unit";
        ProdBOMLine: Record "Production BOM Line";
        CompItemQtyBase: Decimal;
        UOMFactor: Decimal;
        PBOMVersionCode: Code[20];
        IsHandled: Boolean;
    begin
        // P8001030 - add parameter for LocationCode
	IsHandled := false;
        OnBeforeCalcProdBOMCost(MfgItem, ProdBOMNo, RtngNo, MfgItemQtyBase, IsTypeItem, Level, SLMat, RUMat, RUCap, RUSub, RUCapOvhd, RUMfgOvhd, isHandled);
        if IsHandled then
            exit;

        if ProdBOMNo = '' then
            exit;

        SetProdBOMFilters(ProdBOMLine, PBOMVersionCode, ProdBOMNo);

        if IsTypeItem then
            UOMFactor := UOMMgt.GetQtyPerUnitOfMeasure(MfgItem, VersionMgt.GetBOMUnitOfMeasure(ProdBOMNo, PBOMVersionCode))
        else
            UOMFactor := 1;

        with ProdBOMLine do
            if Find('-') then
                repeat
                    CompItemQtyBase :=
                      UOMMgt.RoundQty(
                        CostCalcMgt.CalcCompItemQtyBase(ProdBOMLine, CalculationDate, MfgItemQtyBase, RtngNo, IsTypeItem) / UOMFactor);

                    OnCalcProdBOMCostOnAfterCalcCompItemQtyBase(
                      CalculationDate, MfgItem, MfgItemQtyBase, IsTypeItem, ProdBOMLine, CompItemQtyBase, RtngNo, UOMFactor);
                    case Type of
                        Type::Item:
                            begin
                                CalcMfgSKU("No.", LocationCode, "Variant Code", CompSKU, Level + 1);          // P8001030
                                if CompSKU.IsInventoriableType() then
                                    if CompSKU.IsMfgItem() or CompSKU.IsAssemblyItem() then begin
                                        IncrCost(SLMat, CompSKU."Standard Cost", CompItemQtyBase);                    // P8001030
                                        IncrCost(RUMat, CompSKU."Rolled-up Material Cost", CompItemQtyBase);          // P8001030
                                        IncrCost(RUCap, CompSKU."Rolled-up Capacity Cost", CompItemQtyBase);          // P8001030
                                        IncrCost(RUSub, CompSKU."Rolled-up Subcontracted Cost", CompItemQtyBase);     // P8001030
                                        IncrCost(RUCapOvhd, CompSKU."Rolled-up Cap. Overhead Cost", CompItemQtyBase); // P8001030
                                        IncrCost(RUMfgOvhd, CompSKU."Rolled-up Mfg. Ovhd Cost", CompItemQtyBase);     // P8001030
                                        // OnCalcProdBOMCostOnAfterCalcMfgItem(ProdBOMLine, MfgItem, MfgItemQtyBase, CompItem, CompItemQtyBase, Level, IsTypeItem, UOMFactor);
                                        OnCalcProdBOMCostOnAfterCalcMfgItem(ProdBOMLine, MfgItem, MfgItemQtyBase, CompSKU, CompItemQtyBase, Level, IsTypeItem, UOMFactor);
                                    end else begin
                                        IncrCost(SLMat, CompSKU."Unit Cost", CompItemQtyBase);
                                        IncrCost(RUMat, CompSKU."Unit Cost", CompItemQtyBase);
                                    end;
                                // OnCalcProdBOMCostOnAfterCalcAnyItem(ProdBOMLine, MfgItem, MfgItemQtyBase, CompItem, CompItemQtyBase, Level, IsTypeItem, UOMFactor);
                                OnCalcProdBOMCostOnAfterCalcAnyItem(ProdBOMLine, MfgItem, MfgItemQtyBase, CompSKU, CompItemQtyBase, Level, IsTypeItem, UOMFactor);
                            end;
                        Type::"Production BOM":
                            CalcProdBOMCost(
                              MfgItem, LocationCode, "No.", RtngNo, CompItemQtyBase, false, Level, SLMat, RUMat, RUCap, RUSub, RUCapOvhd, RUMfgOvhd); // P8001030
                    end;
                until Next() = 0;
    end;

    local procedure CalcRtngCost(RtngHeaderNo: Code[20]; MfgItemQtyBase: Decimal; var SLCap: Decimal; var SLSub: Decimal; var SLCapOvhd: Decimal; var ParentItem: Record Item; LocationCode: Code[10])
    var
        RtngLine: Record "Routing Line";
        RtngHeader: Record "Routing Header";
    begin
        // P8000219A - add parameter for Item
        // P8001030 - add parameter for LocationCode
        if RtngLine.CertifiedRoutingVersionExists(RtngHeaderNo, CalculationDate) then begin
            if RtngLine."Version Code" = '' then begin
                RtngHeader.Get(RtngHeaderNo);
                TestRtngVersionIsCertified(RtngLine."Version Code", RtngHeader);
            end;

            repeat
                OnCalcRtngCostOnBeforeCalcRtngLineCost(RtngLine, ParentItem);
                CalcRtngLineCost(RtngLine, MfgItemQtyBase, SLCap, SLSub, SLCapOvhd, ParentItem, LocationCode); // P8001132
            until RtngLine.Next() = 0;
        end;
    end;

    local procedure CalcRtngCostPerUnit(Type: Enum "Capacity Type Routing"; No: Code[20]; var DirUnitCost: Decimal; var IndirCostPct: Decimal; var OvhdRate: Decimal; var UnitCost: Decimal; var UnitCostCalculation: Option Time,Unit)
    var
        WorkCenter: Record "Work Center";
        MachineCenter: Record "Machine Center";
        IsHandled: Boolean;
    begin
        case Type of
            Type::"Work Center":
                GetWorkCenter(No, WorkCenter);
            Type::"Machine Center":
                GetMachineCenter(No, MachineCenter);
        end;

        IsHandled := false;
        OnCalcRtngCostPerUnitOnBeforeCalc(Type.AsInteger(), DirUnitCost, IndirCostPct, OvhdRate, UnitCost, UnitCostCalculation, WorkCenter, MachineCenter, IsHandled);
        if IsHandled then
            exit;

        CostCalcMgt.RoutingCostPerUnit(
            Type, DirUnitCost, IndirCostPct, OvhdRate, UnitCost, UnitCostCalculation, WorkCenter, MachineCenter);
    end;

    local procedure CalcCostPerUnit(CostPerLot: Decimal; LotSize: Decimal): Decimal
    begin
        exit(Round(CostPerLot / LotSize, GLSetup."Unit-Amount Rounding Precision"));
    end;

    local procedure TestBOMVersionIsCertified(BOMVersionCode: Code[20]; ProdBOMHeader: Record "Production BOM Header")
    var
        ProdBOMVersion: Record "Production BOM Version";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestBOMVersionIsCertified(BOMVersionCode, ProdBOMHeader, LogErrors, IsHandled);
        if IsHandled then
            exit;

        if BOMVersionCode = '' then
            //  if ProdBOMHeader.Status <> ProdBOMHeader.Status::Certified then // P8001132
            if LogErrors then
                InsertInErrBuf(ProdBOMHeader."No.", '', false)
            else
                //ProdBOMHeader.TestField(Status, ProdBOMHeader.Status::Certified); // P8001132
                ProdBOMVersion.Get(ProdBOMHeader."No.", BOMVersionCode);            // P8001132
    end;

    local procedure InsertInErrBuf(No: Code[20]; Version: Code[10]; IsRtng: Boolean)
    begin
        if not LogErrors then
            exit;

        if IsRtng then begin
            TempRoutingVersion."Routing No." := No;
            TempRoutingVersion."Version Code" := Version;
            if TempRoutingVersion.Insert() then;
        end else begin
            TempProductionBOMVersion."Production BOM No." := No;
            TempProductionBOMVersion."Version Code" := Version;
            if TempProductionBOMVersion.Insert() then;
        end;
    end;

    local procedure GetItem(ItemNo: Code[20]; var Item: Record Item) IsInBuffer: Boolean
    var
        StdCostWksh: Record "Standard Cost Worksheet";
    begin
        if TempItem.Get(ItemNo) then begin
            Item := TempItem;
            IsInBuffer := true;
        end else begin
            Item.Get(ItemNo);
            if (StdCostWkshName <> '') and
               not (Item.IsMfgItem() or Item.IsAssemblyItem())
            then
                if StdCostWksh.Get(StdCostWkshName, StdCostWksh.Type::Item, ItemNo) then begin
                    Item."Unit Cost" := StdCostWksh."New Standard Cost";
                    Item."Standard Cost" := StdCostWksh."New Standard Cost";
                    Item."Indirect Cost %" := StdCostWksh."New Indirect Cost %";
                    Item."Overhead Rate" := StdCostWksh."New Overhead Rate";
                end;
            IsInBuffer := false;
            Item.ConvertFieldsToBase; // PR3.60
        end;

        OnAfterGetItem(Item, StdCostWkshName, IsInBuffer);
    end;

    local procedure GetWorkCenter(No: Code[20]; var WorkCenter: Record "Work Center")
    var
        StdCostWksh: Record "Standard Cost Worksheet";
    begin
        if TempWorkCenter.Get(No) then
            WorkCenter := TempWorkCenter
        else begin
            WorkCenter.Get(No);
            if StdCostWkshName <> '' then
                if StdCostWksh.Get(StdCostWkshName, StdCostWksh.Type::"Work Center", No) then begin
                    WorkCenter."Unit Cost" := StdCostWksh."New Standard Cost";
                    WorkCenter."Indirect Cost %" := StdCostWksh."New Indirect Cost %";
                    WorkCenter."Overhead Rate" := StdCostWksh."New Overhead Rate";
                    WorkCenter."Direct Unit Cost" :=
                      CostCalcMgt.CalcDirUnitCost(
                        StdCostWksh."New Standard Cost", StdCostWksh."New Overhead Rate", StdCostWksh."New Indirect Cost %");
                end;

            OnGetWorkCenterOnBeforeAssignWorkCenterToTemp(WorkCenter, TempItem);
            TempWorkCenter := WorkCenter;
            TempWorkCenter.Insert();
        end;
    end;

    local procedure GetMachineCenter(No: Code[20]; var MachineCenter: Record "Machine Center")
    var
        StdCostWksh: Record "Standard Cost Worksheet";
    begin
        if TempMachineCenter.Get(No) then
            MachineCenter := TempMachineCenter
        else begin
            MachineCenter.Get(No);
            if StdCostWkshName <> '' then
                if StdCostWksh.Get(StdCostWkshName, StdCostWksh.Type::"Machine Center", No) then begin
                    MachineCenter."Unit Cost" := StdCostWksh."New Standard Cost";
                    MachineCenter."Indirect Cost %" := StdCostWksh."New Indirect Cost %";
                    MachineCenter."Overhead Rate" := StdCostWksh."New Overhead Rate";
                    MachineCenter."Direct Unit Cost" :=
                      CostCalcMgt.CalcDirUnitCost(
                        StdCostWksh."New Standard Cost", StdCostWksh."New Overhead Rate", StdCostWksh."New Indirect Cost %");
                end;
            TempMachineCenter := MachineCenter;
            TempMachineCenter.Insert();
        end;
    end;

    local procedure GetResCost(ResourceNo: Code[20]; var PriceListLine: Record "Price List Line")
    var
        StdCostWksh: Record "Standard Cost Worksheet";
    begin
        TempPriceListLine.SetRange("Asset Type", TempPriceListLine."Asset Type"::Resource);
        TempPriceListLine.SetRange("Asset No.", ResourceNo);
        if TempPriceListLine.FindFirst() then
            PriceListLine := TempPriceListLine
        else begin
            PriceListLine.Init();
            PriceListLine."Price Type" := PriceListLine."Price Type"::Purchase;
            PriceListLine."Asset Type" := PriceListLine."Asset Type"::Resource;
            PriceListLine."Asset No." := ResourceNo;
            PriceListLine."Work Type Code" := '';

            FindResourceCost(PriceListLine);

            if StdCostWkshName <> '' then
                if StdCostWksh.Get(StdCostWkshName, StdCostWksh.Type::Resource, ResourceNo) then begin
                    PriceListLine."Unit Cost" := StdCostWksh."New Standard Cost";
                    PriceListLine."Direct Unit Cost" :=
                        CostCalcMgt.CalcDirUnitCost(
                            StdCostWksh."New Standard Cost",
                            StdCostWksh."New Overhead Rate",
                            StdCostWksh."New Indirect Cost %");
                end;

            TempPriceListLine := PriceListLine;
            NextPriceListLineNo += 1;
            TempPriceListLine."Line No." := NextPriceListLineNo;
            TempPriceListLine.Insert();
        end;
    end;

    local procedure FindResourceCost(var PriceListLine: Record "Price List Line")
    var
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
        PriceListLinePrice: Codeunit "Price List Line - Price";
        LineWithPrice: Interface "Line With Price";
        PriceCalculation: Interface "Price Calculation";
        Line: Variant;
        PriceType: Enum "Price Type";
    begin
        LineWithPrice := PriceListLinePrice;
        LineWithPrice.SetLine(PriceType::Purchase, PriceListLine);
        PriceCalculationMgt.GetHandler(LineWithPrice, PriceCalculation);
        PriceCalculation.ApplyPrice(0);
        PriceCalculation.GetLine(Line);
        PriceListLine := Line;
    end;

    local procedure IncrCost(var Cost: Decimal; UnitCost: Decimal; Qty: Decimal)
    begin
        Cost := Cost + Round(Qty * UnitCost, GLSetup."Unit-Amount Rounding Precision");
    end;

    procedure CalculateAssemblyCostExp(AssemblyHeader: Record "Assembly Header"; var ExpCost: array[5] of Decimal)
    begin
        GLSetup.Get();

        ExpCost[RowIdx::AsmOvhd] :=
          Round(
            CalcOverHeadAmt(
              AssemblyHeader.CalcTotalCost(ExpCost),
              AssemblyHeader."Indirect Cost %",
              AssemblyHeader."Overhead Rate" * AssemblyHeader.Quantity),
            GLSetup."Unit-Amount Rounding Precision");
    end;

    local procedure CalculateAssemblyCostStd(ItemNo: Code[20]; QtyBase: Decimal; var StdCost: array[5] of Decimal)
    var
        Item: Record Item;
        StdTotalCost: Decimal;
    begin
        GLSetup.Get();

        Item.Get(ItemNo);
        StdCost[RowIdx::MatCost] :=
          Round(
            Item."Single-Level Material Cost" * QtyBase,
            GLSetup."Unit-Amount Rounding Precision");
        StdCost[RowIdx::ResCost] :=
          Round(
            Item."Single-Level Capacity Cost" * QtyBase,
            GLSetup."Unit-Amount Rounding Precision");
        StdCost[RowIdx::ResOvhd] :=
          Round(
            Item."Single-Level Cap. Ovhd Cost" * QtyBase,
            GLSetup."Unit-Amount Rounding Precision");
        StdTotalCost := StdCost[RowIdx::MatCost] + StdCost[RowIdx::ResCost] + StdCost[RowIdx::ResOvhd];
        StdCost[RowIdx::AsmOvhd] :=
          Round(
            CalcOverHeadAmt(
              StdTotalCost,
              Item."Indirect Cost %",
              Item."Overhead Rate" * QtyBase),
            GLSetup."Unit-Amount Rounding Precision");
    end;

    procedure CalcOverHeadAmt(CostAmt: Decimal; IndirectCostPct: Decimal; OverheadRateAmt: Decimal): Decimal
    begin
        exit(CostAmt * IndirectCostPct / 100 + OverheadRateAmt);
    end;

    local procedure CalculatePostedAssemblyCostExp(PostedAssemblyHeader: Record "Posted Assembly Header"; var ExpCost: array[5] of Decimal)
    begin
        GLSetup.Get();

        ExpCost[RowIdx::AsmOvhd] :=
          Round(
            CalcOverHeadAmt(
              PostedAssemblyHeader.CalcTotalCost(ExpCost),
              PostedAssemblyHeader."Indirect Cost %",
              PostedAssemblyHeader."Overhead Rate" * PostedAssemblyHeader.Quantity),
            GLSetup."Unit-Amount Rounding Precision");
    end;

    local procedure CalcTotalAndVar(var Value: array[5, 5] of Decimal)
    begin
        CalcTotal(Value);
        CalcVariance(Value);
    end;

    local procedure CalcTotal(var Value: array[5, 5] of Decimal)
    var
        RowId: Integer;
        ColId: Integer;
    begin
        for ColId := 1 to 3 do begin
            Value[ColId, 5] := 0;
            for RowId := 1 to 4 do
                Value[ColId, 5] += Value[ColId, RowId];
        end;
    end;

    local procedure CalcVariance(var Value: array[5, 5] of Decimal)
    var
        i: Integer;
    begin
        for i := 1 to 5 do begin
            Value[ColIdx::Dev, i] := CalcIndicatorPct(Value[ColIdx::StdCost, i], Value[ColIdx::ActCost, i]);
            Value[ColIdx::"Var", i] := Value[ColIdx::ActCost, i] - Value[ColIdx::StdCost, i];
        end;
    end;

    local procedure CalcIndicatorPct(Value: Decimal; "Sum": Decimal): Decimal
    begin
        if Value = 0 then
            exit(0);

        exit(Round((Sum - Value) / Value * 100, 1));
    end;

    procedure CalcAsmOrderStatistics(AssemblyHeader: Record "Assembly Header"; var Value: array[5, 5] of Decimal)
    begin
        CalculateAssemblyCostStd(
          AssemblyHeader."Item No.",
          AssemblyHeader."Quantity (Base)",
          Value[ColIdx::StdCost]);
        CalculateAssemblyCostExp(AssemblyHeader, Value[ColIdx::ExpCost]);
        AssemblyHeader.CalcActualCosts(Value[ColIdx::ActCost]);
        CalcTotalAndVar(Value);
    end;

    procedure CalcPostedAsmOrderStatistics(PostedAssemblyHeader: Record "Posted Assembly Header"; var Value: array[5, 5] of Decimal)
    begin
        CalculateAssemblyCostStd(
          PostedAssemblyHeader."Item No.",
          PostedAssemblyHeader."Quantity (Base)",
          Value[ColIdx::StdCost]);
        CalculatePostedAssemblyCostExp(PostedAssemblyHeader, Value[ColIdx::ExpCost]);
        PostedAssemblyHeader.CalcActualCosts(Value[ColIdx::ActCost]);
        CalcTotalAndVar(Value);
    end;

    procedure CalcRtngLineCost(RoutingLine: Record "Routing Line"; MfgItemQtyBase: Decimal; var SLCap: Decimal; var SLSub: Decimal; var SLCapOvhd: Decimal)
    var
        Item: Record Item;
    begin
        // P80096141 - Original signature
        CalcRtngLineCost(RoutingLine, MfgItemQtyBase, SLCap, SLSub, SLCapOvhd, Item, '');
    end;

    procedure CalcRtngLineCost(RoutingLine: Record "Routing Line"; MfgItemQtyBase: Decimal; var SLCap: Decimal; var SLSub: Decimal; var SLCapOvhd: Decimal; Item: Record Item; LocationCode: Code[10])
    var
        WorkCenter: Record "Work Center";
        CostCalculationMgt: Codeunit "Cost Calculation Management";
        UnitCost: Decimal;
        DirUnitCost: Decimal;
        IndirCostPct: Decimal;
        OvhdRate: Decimal;
        CostTime: Decimal;
        UnitCostCalculation: Option;
        RoutingRec: RecordRef;
        ProdBOMNo: Code[20];
        ProdBOMVersion: Code[10];
    begin
        OnBeforeCalcRtngLineCost(RoutingLine, MfgItemQtyBase);
        with RoutingLine do begin
            if (Type = Type::"Work Center") and ("No." <> '') then
                WorkCenter.Get("No.");

            // P8000219A Begin
            RoutingRec.GetTable(RoutingLine);
            if not CostCalcMgt.CalcABCRtngCostPerUnit(
              RoutingRec, Item, CalculationDate, LocationCode, ProdBOMNo, ProdBOMVersion, // P8001030
              DirUnitCost, IndirCostPct, OvhdRate, UnitCost, UnitCostCalculation)
            then begin
                // P8000219A End
                UnitCost := "Unit Cost per";
            CalcRtngCostPerUnit(
                Type, "No.", DirUnitCost, IndirCostPct, OvhdRate, UnitCost, UnitCostCalculation);
            end; // P8000219A
            CostTime :=
              CostCalculationMgt.CalcCostTime(
                MfgItemQtyBase,
                "Setup Time", "Setup Time Unit of Meas. Code",
                "Run Time", "Run Time Unit of Meas. Code", "Lot Size",
                "Scrap Factor % (Accumulated)", "Fixed Scrap Qty. (Accum.)",
                "Work Center No.", UnitCostCalculation, MfgSetup."Cost Incl. Setup",
                "Concurrent Capacities");

            if (Type = Type::"Work Center") and (WorkCenter."Subcontractor No." <> '') then
                IncrCost(SLSub, DirUnitCost, CostTime)
            else
                IncrCost(SLCap, DirUnitCost, CostTime);
            IncrCost(SLCapOvhd, CostCalcMgt.CalcOvhdCost(DirUnitCost, IndirCostPct, OvhdRate, 1), CostTime);
        end;

        OnAfterCalcRtngLineCost(RoutingLine, MfgItemQtyBase, SLCap, SLSub, SLCapOvhd);
    end;

    local procedure TestRtngVersionIsCertified(RtngVersionCode: Code[20]; RtngHeader: Record "Routing Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestRtngVersionIsCertified(RtngVersionCode, RtngHeader, LogErrors, IsHandled);
        if IsHandled then
            exit;

        if RtngVersionCode = '' then
            if RtngHeader.Status <> RtngHeader.Status::Certified then
                if LogErrors then
                    InsertInErrBuf(RtngHeader."No.", '', true)
                else
                    RtngHeader.TestField(Status, RtngHeader.Status::Certified);
    end;

    local procedure AdjustForCoProduct(Item: Record Item; LocationCode: Code[10]; ProdBOMNo: Code[20]; CalculationDate: Date; var SLMat: Decimal; var RUMat: Decimal; var Overhead: Decimal)
    var
        FamilyLine: Record "Family Line";
        ByProduct: Record "Stockkeeping Unit";
        ByProductItem: Record Item;
        ByProductFactor: Decimal;
        CoProductFactor: Decimal;
    begin
        // PR3.70.03
        // P8001030 - add parameter for LocationCode
        if not P800BOMFns.GetStdCostFactors(Item, ProdBOMNo, CalculationDate, ByProductFactor, CoProductFactor) then
            exit;

        // P8007573
        SLMat := SLMat * ByProductFactor;
        RUMat := RUMat * ByProductFactor;
        Overhead := Overhead * ByProductFactor;
        // P8007573

        FamilyLine.SetRange("Family No.", ProdBOMNo);
        FamilyLine.SetRange("Process Family", true);
        FamilyLine.SetRange("By-Product", true);
        if FamilyLine.Find('-') then
            repeat
                GetSKU(FamilyLine."Item No.", LocationCode, '', ByProduct); // P8001030
                ByProductItem.Get(ByProduct."Item No."); // P8001030
                                                         //    IF ByProduct.CostInAlternateUnits THEN
                                                         //      FamilyLine.VALIDATE("Unit Cost",ByProduct."Unit Cost")
                                                         //   ELSE
                FamilyLine."Cost Amount" := FamilyLine.Quantity *
                  ByProduct."Unit Cost" * UOMMgt.GetQtyPerUnitOfMeasure(ByProductItem, FamilyLine."Unit of Measure Code"); // P8001030
                                                                                                                           // adjustment := FamilyLine."Cost Amount" / ByProductFactor; // P8007573
                SLMat -= FamilyLine."Cost Amount";                           // P8007573
                RUMat -= FamilyLine."Cost Amount";                           // P8007573
            until FamilyLine.Next = 0;

        SLMat *= CoProductFactor;
        RUMat *= CoProductFactor;
        Overhead *= CoProductFactor;
        Overhead := Round(Overhead, GLSetup."Unit-Amount Rounding Precision"); // P8001266
    end;

    local procedure GetSKU(ItemNo: Code[20]; LocationCode: Code[10]; VariantCode: Code[10]; var SKU: Record "Stockkeeping Unit") IsInBuffer: Boolean
    var
        StdCostWksh: Record "Standard Cost Worksheet";
        Item: Record Item;
    begin
        // P8001030
        if TempSKU.Get(LocationCode, ItemNo, VariantCode) then begin
            SKU := TempSKU;
            IsInBuffer := true;
        end else begin
            if not SKU.Get(LocationCode, ItemNo, VariantCode) then begin
                LocationCode := '';
                VariantCode := '';
                if TempSKU.Get(LocationCode, ItemNo, VariantCode) then begin
                    SKU := TempSKU;
                    IsInBuffer := true;
                    exit;
                end else begin
                    SKU.Init;
                    SKU."Item No." := ItemNo;
                    SKU."Location Code" := LocationCode;
                    SKU."Variant Code" := VariantCode;
                    Item.Get(ItemNo);
                    SKU."Replenishment System" := Item."Replenishment System";
                    SKU."Lot Size" := Item."Lot Size"; // P800106829
                    ItemCostMgmt.TransferCostsFromItemToSKU(Item, SKU);
                end;
            end;

            if (StdCostWkshName <> '') and
              (not (SKU.IsMfgItem or SKU.IsTransItem))
            then begin
                if StdCostWksh.Get(StdCostWkshName, StdCostWksh.Type::Item, ItemNo, LocationCode, VariantCode) then begin
                    SKU."Unit Cost" := StdCostWksh."New Standard Cost";
                    SKU."Standard Cost" := StdCostWksh."New Standard Cost";
                    SKU."Indirect Cost %" := StdCostWksh."New Indirect Cost %";
                    SKU."Overhead Rate" := StdCostWksh."New Overhead Rate";
                end;
            end;
            IsInBuffer := false;
            SKU.ConvertFieldsToBase;
        end;
    end;

    procedure CalcTransferCost(Item: Record Item; SKU: Record "Stockkeeping Unit"; Level: Integer; var SLMat: Decimal; var RUMat: Decimal)
    var
        TransSKU: Record "Stockkeeping Unit";
    begin
        // P8001030
        CalcMfgSKU(SKU."Item No.", SKU."Transfer-from Code", SKU."Variant Code", TransSKU, Level + 1);
        if Item."Costing Method" = Item."Costing Method"::Standard then begin
            SLMat := TransSKU."Standard Cost";
            RUMat := TransSKU."Standard Cost";
        end else begin
            SLMat := TransSKU."Unit Cost";
            RUMat := TransSKU."Unit Cost";
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcRtngLineCost(RoutingLine: Record "Routing Line"; MfgItemQtyBase: Decimal; var SLCap: Decimal; var SLSub: Decimal; var SLCapOvhd: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetProdBOMFilters(var ProdBOMLine: Record "Production BOM Line"; var PBOMVersionCode: Code[20]; var ProdBOMNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetProperties(var NewCalculationDate: Date; var NewCalcMultiLevel: Boolean; var NewUseAssemblyList: Boolean; var NewLogErrors: Boolean; var NewStdCostWkshName: Text[50]; var NewShowDialog: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcItems(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcItem(var Item: Record Item; UseAssemblyList: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcMfgItem(var Item: Record Item; var LogErrors: Boolean; StdCostWkshName: Text[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcRtngLineCost(var RoutingLine: Record "Routing Line"; MfgItemQtyBase: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcAssemblyItemOnAfterInitItemCost(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcAssemblyItemOnAfterCalcItemRolledupCost(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestBOMVersionIsCertified(BOMVersionCode: Code[20]; ProductionBOMHeader: Record "Production BOM Header"; LogErrors: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestRtngVersionIsCertified(RtngVersionCode: Code[20]; RoutingHeader: Record "Routing Header"; LogErrors: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcAssemblyItemOnAfterCalcSingleLevelCost(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcAssemblyItemOnAfterCalcItemCost(var Item: Record Item; CompItem: Record Item; BOMComponent: Record "BOM Component"; ComponentQuantity: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcItemOnBeforeShowStrMenu(var Item: Record Item; var ShowStrMenu: Boolean; var NewCalcMultiLevel: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcItemOnAfterCalcShowConfirm(Item: Record Item; var CalcMfgItems: Boolean; var ShowConfirm: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcMfgItemOnBeforeCalcRtngCost(var Item: Record Item; Level: Integer; var LotSize: Decimal; var MfgItemQtyBase: Decimal)
    begin
    end;

    // [IntegrationEvent(false, false)]
    // local procedure OnCalcMfgItemOnBeforeCalculateCosts(var SLMat: Decimal; var SLCap: Decimal; var SLSub: Decimal; var SLCapOvhd: Decimal; var SLMfgOvhd: Decimal; var Item: Record Item; LotSize: Decimal; MfgItemQtyBase: Decimal; Level: Integer; CalculationDate: Date; var RUMat: Decimal)
    // begin
    // end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcMfgSKUOnBeforeCalculateCosts(var SLMat: Decimal; var SLCap: Decimal; var SLSub: Decimal; var SLCapOvhd: Decimal; var SLMfgOvhd: Decimal; var SKU: Record "Stockkeeping Unit"; LotSize: Decimal; MfgItemQtyBase: Decimal; Level: Integer; CalculationDate: Date; var RUMat: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcProdBOMCostOnAfterCalcCompItemQtyBase(CalculationDate: Date; MfgItem: Record Item; MfgItemQtyBase: Decimal; IsTypeItem: Boolean; var ProdBOMLine: Record "Production BOM Line"; var CompItemQtyBase: Decimal; RtngNo: Code[20]; UOMFactor: Decimal)
    begin
    end;

    // [IntegrationEvent(false, false)]
    // local procedure OnCalcProdBOMCostOnAfterCalcMfgItem(var ProdBOMLine: Record "Production BOM Line"; MfgItem: Record Item; MfgItemQtyBase: Decimal; CompItem: Record Item; CompItemQtyBase: Decimal; Level: Integer; IsTypeItem: Boolean; UOMFactor: Decimal)
    // begin
    // end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcProdBOMCostOnAfterCalcMfgItem(var ProdBOMLine: Record "Production BOM Line"; MfgItem: Record Item; MfgItemQtyBase: Decimal; CompSKU: Record "Stockkeeping Unit"; CompItemQtyBase: Decimal; Level: Integer; IsTypeItem: Boolean; UOMFactor: Decimal)
    begin
    end;

    // [IntegrationEvent(false, false)]
    // local procedure OnCalcProdBOMCostOnAfterCalcAnyItem(var ProductionBOMLine: Record "Production BOM Line"; MfgItem: Record Item; MfgItemQtyBase: Decimal; CompItem: Record Item; CompItemQtyBase: Decimal; Level: Integer; IsTypeItem: Boolean; UOMFactor: Decimal)
    // begin
    // end;
    [IntegrationEvent(false, false)]
    local procedure OnCalcProdBOMCostOnAfterCalcAnyItem(var ProductionBOMLine: Record "Production BOM Line"; MfgItem: Record Item; MfgItemQtyBase: Decimal; CompSKU: Record "Stockkeeping Unit"; CompItemQtyBase: Decimal; Level: Integer; IsTypeItem: Boolean; UOMFactor: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcRtngCostOnBeforeCalcRtngLineCost(var RoutingLine: Record "Routing Line"; ParentItem: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcRtngCostPerUnitOnBeforeCalc(Type: Option "Work Center","Machine Center"; var DirUnitCost: Decimal; var IndirCostPct: Decimal; var OvhdRate: Decimal; var UnitCost: Decimal; var UnitCostCalculation: Option Time,Unit; WorkCenter: Record "Work Center"; MachineCenter: Record "Machine Center"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetWorkCenterOnBeforeAssignWorkCenterToTemp(var WorkCenter: Record "Work Center"; var TempItem: Record Item temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetItem(var Item: Record Item; StdCostWkshName: Text[50]; IsInBuffer: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetProperties(var NewCalculationDate: Date; var NewCalcMultiLevel: Boolean; var NewUseAssemblyList: Boolean; var NewLogErrors: Boolean; var NewStdCostWkshName: Text[50]; var NewShowDialog: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcProdBOMCost(MfgItem: Record Item; ProdBOMNo: Code[20]; RtngNo: Code[20]; MfgItemQtyBase: Decimal; IsTypeItem: Boolean; Level: Integer; var SLMat: Decimal; var RUMat: Decimal; var RUCap: Decimal; var RUSub: Decimal; var RUCapOvhd: Decimal; var RUMfgOvhd: Decimal; var IsHandled: Boolean)
    begin
    end;
}

