codeunit 99000770 "Where-Used Management"
{
    // PR1.00
    //   WhereUsedFromUnapprItem - calls BuildWhereUsedList for unapproved items
    // 
    // PR2.00.05
    //   BuildWhereUsedList - look for BOM's in item variant table; look for items in use as variables
    //     in package variants
    //   WhereUsedFromVariable - calls BuildWhereUsedList for variables
    //   GetVariableQtyOnBOM - gets total quantity needed for a variable
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    //
    // PRW121.4
    // P800164877, To-Increase, Gangabhushan, 07 MAR 23
    //   Upgrade- Redesigned function GetItemBOMNo to get the correct Prod. BOM number

    Permissions = TableData "Production BOM Header" = r,
                  TableData "Production BOM Version" = r,
                  TableData "Where-Used Line" = imd;

    trigger OnRun()
    begin
    end;

    var
        TempWhereUsedList: Record "Where-Used Line" temporary;
        UOMMgt: Codeunit "Unit of Measure Management";
        VersionMgt: Codeunit VersionManagement;
        CostCalcMgt: Codeunit "Cost Calculation Management";
        MultiLevel: Boolean;
        NextWhereUsedEntryNo: Integer;

    procedure FindRecord(Which: Text[30]; var WhereUsedList2: Record "Where-Used Line"): Boolean
    begin
        TempWhereUsedList.Copy(WhereUsedList2);
        if not TempWhereUsedList.Find(Which) then
            exit(false);
        WhereUsedList2 := TempWhereUsedList;

        exit(true);
    end;

    procedure NextRecord(Steps: Integer; var WhereUsedList2: Record "Where-Used Line"): Integer
    var
        CurrentSteps: Integer;
    begin
        TempWhereUsedList.Copy(WhereUsedList2);
        CurrentSteps := TempWhereUsedList.Next(Steps);
        if CurrentSteps <> 0 then
            WhereUsedList2 := TempWhereUsedList;

        exit(CurrentSteps);
    end;

    procedure WhereUsedFromItem(Item: Record Item; CalcDate: Date; NewMultiLevel: Boolean)
    begin
        // P80096141 - Original signature
        WhereUsedFromItem(Item, '', CalcDate, NewMultiLevel);
    end;

    procedure WhereUsedFromItem(Item: Record Item; Location: Code[10]; CalcDate: Date; NewMultiLevel: Boolean)
    begin
        BuildWhereUsedListWithCheck(Enum::"Production BOM Line Type"::Item, Item."No.", '', Location, CalcDate, NewMultiLevel);  // P8001030
    end;

    procedure WhereUsedFromProdBOM(ProdBOM: Record "Production BOM Header"; CalcDate: Date; NewMultiLevel: Boolean)
    begin
        // P80096141 - Original signature
        WhereUsedFromProdBOM(ProdBOM, '', CalcDate, NewMultiLevel);
    end;

    procedure WhereUsedFromProdBOM(ProdBOM: Record "Production BOM Header"; Location: Code[10]; CalcDate: Date; NewMultiLevel: Boolean)
    begin
        BuildWhereUsedListWithCheck(Enum::"Production BOM Line Type"::"Production BOM", ProdBOM."No.", '', Location, CalcDate, NewMultiLevel); // P8001030
    end;

    local procedure BuildWhereUsedListWithCheck(BOMLineType: Enum "Production BOM Line Type"; No: Code[20]; Variant: Code[10]; Location: Code[10]; CalcDate: Date; IsMultiLevel: Boolean)
    var
        ProdBOMCheck: Codeunit "Production BOM-Check";
        ProdBOMToCheck: Code[20];
    begin
        if BOMLineType = BOMLineType::Item then
            ProdBOMToCheck := GetItemBOMNo(No, Variant, Location)
        else
            ProdBOMToCheck := No;

        ProdBOMCheck.CheckBOM(ProdBOMToCheck, VersionMgt.GetBOMVersion(ProdBOMToCheck, CalcDate, false));

        TempWhereUsedList.DeleteAll();
        NextWhereUsedEntryNo := 1;
        MultiLevel := IsMultiLevel;

        BuildWhereUsedList(BOMLineType, No, Variant, Location, CalcDate, 1, 1); // P8001030
    end;

    local procedure BuildWhereUsedList(Type: Enum "Production BOM Line Type"; No: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; CalcDate: Date; Level: Integer; Quantity: Decimal)
    var
        ItemAssembly: Record Item;
        ProdBOMComponent: Record "Production BOM Line";
        ItemVariant: Record "Item Variant";
        ItemVariantVariable: Record "Item Variant Variable";
        SKU: Record "Stockkeeping Unit";
        Item: Record Item;
        UseItem: Boolean;
    begin
        // P8001030 - Add parameters for Variant and Location
        OnBeforeBuildWhereUsedList(Type, No, MultiLevel, CalcDate, Level, Quantity, NextWhereUsedEntryNo, TempWhereUsedList);
        if Level > 30 then
            exit;

        if Type = Type::"Production BOM" then begin
            ItemAssembly.SetCurrentKey("Production BOM No.");
            ItemAssembly.SetRange("Production BOM No.", No);
            OnBuildWhereUsedListOnAfterItemAssemblySetFilters(ItemAssembly, No);
            if ItemAssembly.FindSet() then
                repeat
                    // P8001030
                    UseItem := true;
                    if SKU.Get(LocationCode, ItemAssembly."No.", VariantCode) then
                        UseItem := SKU."Production BOM No." = '';
                    if UseItem then begin
                        TempWhereUsedList.Init();
                        TempWhereUsedList."Entry No." := NextWhereUsedEntryNo;
                        TempWhereUsedList."Item No." := ItemAssembly."No.";
                        TempWhereUsedList."Variant Code" := ''; // PR2.00.05
                        TempWhereUsedList.Description := ItemAssembly.Description;
                        TempWhereUsedList."Level Code" := Level;
                        TempWhereUsedList."Quantity Needed" :=
                          Quantity *
                          (1 + ItemAssembly."Scrap %" / 100) *
                          UOMMgt.GetQtyPerUnitOfMeasure(ItemAssembly, ItemAssembly."Base Unit of Measure") /
                          UOMMgt.GetQtyPerUnitOfMeasure(
                            ItemAssembly,
                            VersionMgt.GetBOMUnitOfMeasure(
                              ItemAssembly."Production BOM No.",
                              VersionMgt.GetBOMVersion(ItemAssembly."Production BOM No.", CalcDate, false)));
                        TempWhereUsedList."Version Code" := VersionMgt.GetBOMVersion(No, CalcDate, true);
                        OnBeforeWhereUsedListInsert(TempWhereUsedList, ItemAssembly, CalcDate, Quantity);
                        TempWhereUsedList.Insert();
                        NextWhereUsedEntryNo := NextWhereUsedEntryNo + 1;
                        if MultiLevel then
                            BuildWhereUsedList(
                              Enum::"Production BOM Line Type"::Item,
                              ItemAssembly."No.",
                                  '', LocationCode, // P8001030
                              CalcDate,
                              Level + 1,
                              TempWhereUsedList."Quantity Needed");
                    end; // P8001030
                until ItemAssembly.Next() = 0;
            // P8001030
            SKU.SetCurrentKey("Production BOM No.");
            SKU.SetRange("Production BOM No.", No);
            SKU.SetRange("Location Code", LocationCode);
            SKU.SetRange("Variant Code", VariantCode);
            if SKU.Find('-') then
                repeat
                    Item.Get(SKU."Item No.");
                    TempWhereUsedList."Entry No." := NextWhereUsedEntryNo;
                    TempWhereUsedList."Item No." := SKU."Item No.";
                    TempWhereUsedList."Variant Code" := SKU."Variant Code";
                    TempWhereUsedList.Description := Item.Description;
                    TempWhereUsedList."Level Code" := Level;
                    TempWhereUsedList."Quantity Needed" :=
                      Quantity *
                      (1 + Item."Scrap %" / 100) *
                      UOMMgt.GetQtyPerUnitOfMeasure(Item, Item."Base Unit of Measure") /
                      UOMMgt.GetQtyPerUnitOfMeasure(
                        Item,
                        VersionMgt.GetBOMUnitOfMeasure(
                          SKU."Production BOM No.",
                          VersionMgt.GetBOMVersion(SKU."Production BOM No.", CalcDate, false)));
                    OnBeforeWhereUsedListInsert(TempWhereUsedList, Item, CalcDate, Quantity); // P800-MegaApp
                    TempWhereUsedList.Insert();
                    NextWhereUsedEntryNo := NextWhereUsedEntryNo + 1;
                    if MultiLevel then
                        BuildWhereUsedList(
                          1,
                          SKU."Item No.",
                          SKU."Variant Code", SKU."Location Code",
                          CalcDate,
                          Level + 1,
                          TempWhereUsedList."Quantity Needed");
                until SKU.Next = 0;
            // P8001030

            // PR2.00.05 Begin
            ItemVariant.SetCurrentKey("Production BOM No.");
            ItemVariant.SetRange("Production BOM No.", No);
            if ItemVariant.Find('-') then
                repeat
                    TempWhereUsedList."Entry No." := NextWhereUsedEntryNo;
                    TempWhereUsedList."Item No." := ItemVariant."Item No.";
                    TempWhereUsedList."Variant Code" := ItemVariant.Code; // PR2.00.05
                    TempWhereUsedList.Description := ItemVariant.Description;
                    TempWhereUsedList."Level Code" := Level;
                    TempWhereUsedList."Quantity Needed" := Quantity;
                    TempWhereUsedList."Version Code" := VersionMgt.GetBOMVersion(No, CalcDate, false);
                    OnBeforeWhereUsedListInsert(TempWhereUsedList, Item, CalcDate, Quantity); // P800-MegaApp
                    TempWhereUsedList.Insert;
                    NextWhereUsedEntryNo := NextWhereUsedEntryNo + 1;
                until ItemVariant.Next = 0;
            // PR2.00.05 End
        end;

        // PR2.00.05 Begin
        if Type = Type::Item then begin
            ItemVariantVariable.SetCurrentKey("Variable Item No.");
            ItemVariantVariable.SetRange("Variable Item No.", No);
            if ItemVariantVariable.Find('-') then
                repeat
                    ItemVariant.Get(ItemVariantVariable."Item No.", ItemVariantVariable."Variant Code");
                    ItemAssembly.Get(ItemVariantVariable."Variable Item No.");
                    TempWhereUsedList."Entry No." := NextWhereUsedEntryNo;
                    TempWhereUsedList."Item No." := ItemVariantVariable."Item No.";
                    TempWhereUsedList."Variant Code" := ItemVariantVariable."Variant Code";
                    TempWhereUsedList.Description := ItemVariant.Description;
                    TempWhereUsedList."Level Code" := Level;
                    TempWhereUsedList."Quantity Needed" :=
                      ItemVariantVariable.Quantity *
                      UOMMgt.GetQtyPerUnitOfMeasure(ItemAssembly, ItemVariantVariable."UOM Code") *
                      GetVariableQtyOnBOM(
                        ItemVariant."Production BOM No.",
                        VersionMgt.GetBOMVersion(
                          ItemVariant."Production BOM No.",
                          CalcDate, false),
                        ItemVariantVariable."Package Variable Code");
                    TempWhereUsedList."Version Code" := VersionMgt.GetBOMVersion(ItemVariant."Production BOM No.", CalcDate, false);
                    OnBeforeWhereUsedListInsert(TempWhereUsedList, Item, CalcDate, Quantity); // P800-MegaApp
                    TempWhereUsedList.Insert;
                    NextWhereUsedEntryNo := NextWhereUsedEntryNo + 1;
                until ItemVariantVariable.Next = 0;
        end;
        // PR2.00.05 End

        ProdBOMComponent.SetCurrentKey(Type, "No.");
        ProdBOMComponent.SetRange(Type, Type);
        ProdBOMComponent.SetRange("No.", No);
        ProdBOMComponent.SetRange("Variant Code", VariantCode); // P8001030
        if CalcDate <> 0D then begin
            ProdBOMComponent.SetFilter("Starting Date", '%1|..%2', 0D, CalcDate);
            ProdBOMComponent.SetFilter("Ending Date", '%1|%2..', 0D, CalcDate);
        end;

        if ProdBOMComponent.FindSet() then
            repeat
                if VersionMgt.GetBOMVersion(
                     ProdBOMComponent."Production BOM No.", CalcDate, true) =
                   ProdBOMComponent."Version Code"
                then begin
                    OnBuildWhereUsedListOnLoopProdBomComponent(ProdBOMComponent, TempWhereUsedList, NextWhereUsedEntryNo, No, CalcDate, Level);
                    if IsActiveProductionBOM(ProdBOMComponent) then
                        BuildWhereUsedList(
                          Enum::"Production BOM Line Type"::"Production BOM",
                          ProdBOMComponent."Production BOM No.",
                          '', LocationCode, // P8001030
                          CalcDate,
                          Level + 1,
                          CostCalcMgt.CalcCompItemQtyBase(ProdBOMComponent, CalcDate, Quantity, '', false));
                end;
            until ProdBOMComponent.Next() = 0;

        OnAfterBuildWhereUsedList(Type, No, CalcDate, TempWhereUsedList, NextWhereUsedEntryNo, Level, Quantity, MultiLevel);
    end;

    procedure IsActiveProductionBOM(ProductionBOMLine: Record "Production BOM Line") Result: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeIsActiveProductionBOM(ProductionBOMLine, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if ProductionBOMLine."Version Code" = '' then
            exit(not IsProductionBOMClosed(ProductionBOMLine));

        exit(not IsProdBOMVersionClosed(ProductionBOMLine));
    end;

    local procedure IsProductionBOMClosed(ProductionBOMLine: Record "Production BOM Line"): Boolean
    var
        ProdBOMHeader: Record "Production BOM Header";
    begin
        ProdBOMHeader.Get(ProductionBOMLine."Production BOM No.");
        exit(ProdBOMHeader.Status = ProdBOMHeader.Status::Closed);
    end;

    local procedure IsProdBOMVersionClosed(ProductionBOMLine: Record "Production BOM Line"): Boolean
    var
        ProductionBOMVersion: Record "Production BOM Version";
    begin
        ProductionBOMVersion.Get(ProductionBOMLine."Production BOM No.", ProductionBOMLine."Version Code");
        exit(ProductionBOMVersion.Status = ProductionBOMVersion.Status::Closed);
    end;

    local procedure GetItemBOMNo(ItemNo: Code[20]; Variant: Code[10]; Location: Code[10]): Code[20]
    var
        Item: Record Item;
    begin
        // Item.SetLoadFields("Production BOM No."); // P800164877
        Item.Get(ItemNo);
        // P800164877
        // exit(Item."Production BOM No."); 
        exit(Item.ProductionBOMNo(Variant, Location));
        // P800164877
    end;

    procedure WhereUsedFromUnapprItem(UnapprItem: Record "Unapproved Item"; Location: Code[10]; "Calc.Date": Date; NewMultiLevel: Boolean)
    begin
        // P8001030 - Add parameter for Location
        // PR1.00 Begin
        TempWhereUsedList.DeleteAll;
        NextWhereUsedEntryNo := 1;
        MultiLevel := NewMultiLevel;

        BuildWhereUsedList(3, UnapprItem."No.", '', Location, "Calc.Date", 1, 1); // P8001030
        // PR1.00 End
    end;

    procedure WhereUsedFromVariable(PkgVar: Record "Package Variable"; Location: Code[10]; "Calc.Date": Date; NewMultiLevel: Boolean)
    begin
        // P8001030 - Add parameter for Location
        // PR2.00.05 Begin
        TempWhereUsedList.DeleteAll;
        NextWhereUsedEntryNo := 1;
        MultiLevel := NewMultiLevel;

        BuildWhereUsedList(4, PkgVar.Code, '', Location, "Calc.Date", 1, 1); // P8001030
        // PR2.00.05 End
    end;

    procedure GetVariableQtyOnBOM(ProdBOMNo: Code[20]; VersionCode: Code[10]; VarCode: Code[10]) VarQty: Decimal
    var
        BOMLine: Record "Production BOM Line";
    begin
        // PR2.00.05 Begin
        BOMLine.SetRange("Production BOM No.", ProdBOMNo);
        BOMLine.SetRange("Version Code", VersionCode);
        BOMLine.SetRange(Type, BOMLine.Type::FOODVariable);
        BOMLine.SetRange("No.", VarCode);
        if BOMLine.Find('-') then
            repeat
                VarQty += BOMLine."Quantity per";
            until BOMLine.Next = 0;
        // PR2.00.05 End
    end;

    procedure WhereUsedFromSKU(SKU: Record "Stockkeeping Unit"; "Calc.Date": Date; NewMultiLevel: Boolean)
    begin
        // P8001030
        TempWhereUsedList.DeleteAll;
        NextWhereUsedEntryNo := 1;
        MultiLevel := NewMultiLevel;

        BuildWhereUsedList(1, SKU."Item No.", SKU."Variant Code", SKU."Location Code", "Calc.Date", 1, 1);
    end;


    [IntegrationEvent(false, false)]
    local procedure OnAfterBuildWhereUsedList(Type: Option " ",Item,"Production BOM"; No: Code[20]; CalcDate: Date; var WhereUsedList: Record "Where-Used Line" temporary; NextWhereUsedEntryNo: Integer; Level: Integer; Quantity: Decimal; MultiLevel: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsActiveProductionBOM(ProductionBOMLine: Record "Production BOM Line"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBuildWhereUsedList(Type: Option; No: Code[20]; var Multilevel: Boolean; var CalcDate: Date; var Level: Integer; var Quantity: Decimal; var NextWhereUsedEntryNo: Integer; var TempWhereUsedLine: Record "Where-Used Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWhereUsedListInsert(var WhereUsedLine: Record "Where-Used Line"; var ItemAssembly: Record Item; var CalcDate: Date; var Quantity: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBuildWhereUsedListOnLoopProdBomComponent(var ProductionBOMLine: Record "Production BOM Line"; var TempWhereUsedLine: Record "Where-Used Line" temporary; var NextWhereUsedEntryNo: Integer; No: Code[20]; CalcDate: Date; var Level: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBuildWhereUsedListOnAfterItemAssemblySetFilters(var Item: Record Item; var No: Code[20])
    begin
    end;
}

