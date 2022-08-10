codeunit 99000771 "BOM Matrix Management"
{
    // PR1.00
    //   Use Batch Quantity for formulas
    //   BuildMatrix - add section for Unapproved items
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013

    Permissions = TableData Item = r,
                  TableData "Production BOM Header" = r,
                  TableData "Production BOM Version" = r,
                  TableData "Production Matrix BOM Line" = rimd,
                  TableData "Production Matrix  BOM Entry" = rimd;

    trigger OnRun()
    begin
    end;

    var
        Item: Record Item;
        ItemAssembly: Record Item;
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMVersion: Record "Production BOM Version";
        ProdBOMVersion2: Record "Production BOM Version";
        ComponentList: Record "Production Matrix BOM Line" temporary;
        ComponentEntry: Record "Production Matrix  BOM Entry" temporary;
        ComponentEntry2: Record "Production Matrix  BOM Entry";
        UOMMgt: Codeunit "Unit of Measure Management";
        VersionMgt: Codeunit VersionManagement;
        GlobalCalcDate: Date;
        MatrixType: Option Version,Item;
        MultiLevel: Boolean;
        UnapprItem: Record "Unapproved Item";
        P800UOMFns: Codeunit "Process 800 UOM Functions";

    procedure FindRecord(Which: Text[30]; var ComponentList2: Record "Production Matrix BOM Line"): Boolean
    begin
        ComponentList := ComponentList2;
        if not ComponentList.Find(Which) then
            exit(false);
        ComponentList2 := ComponentList;
        exit(true);
    end;

    procedure NextRecord(Steps: Integer; var ComponentList2: Record "Production Matrix BOM Line"): Integer
    var
        CurrentSteps: Integer;
    begin
        ComponentList := ComponentList2;
        CurrentSteps := ComponentList.Next(Steps);
        if CurrentSteps <> 0 then
            ComponentList2 := ComponentList;
        exit(CurrentSteps);
    end;

    procedure GetComponentNeed(No: Code[20]; VariantCode: Code[10]; ID: Code[20]): Decimal
    begin
        ComponentEntry.SetRange("Item No.", No);
        ComponentEntry.SetRange("Variant Code", VariantCode);
        ComponentEntry.SetRange(ID, ID);
        if not ComponentEntry.FindFirst() then
            Clear(ComponentEntry);

        exit(ComponentEntry.Quantity);
    end;

    procedure CompareTwoItems(Item1: Record Item; Item2: Record Item; CalcDate: Date; NewMultiLevel: Boolean; var VersionCode1: Code[20]; var VersionCode2: Code[20]; var UnitOfMeasure1: Code[10]; var UnitOfMeasure2: Code[10])
    begin
        // P80096141 - Original signature
        CompareTwoItems(Item1, Item2, CalcDate, NewMultiLevel, '', VersionCode1, VersionCode2, UnitOfMeasure1, UnitOfMeasure2);
    end;

    procedure CompareTwoItems(Item1: Record Item; Item2: Record Item; CalcDate: Date; NewMultiLevel: Boolean; LocationCode: Code[10]; var VersionCode1: Code[20]; var VersionCode2: Code[20]; var UnitOfMeasure1: Code[10]; var UnitOfMeasure2: Code[10])
    var
        ProdBOM1: Code[20];
        ProdBOM2: Code[20];
    begin
        // P8001070 - add parameter for LocationCode
        GlobalCalcDate := CalcDate;

        ComponentList.DeleteAll();
        ComponentEntry.Reset();
        ComponentEntry.DeleteAll();

        MultiLevel := NewMultiLevel;
        MatrixType := MatrixType::Item;

        ProdBOM1 := Item1.ProductionBOMNo('', LocationCode); // P8001030
        VersionCode1 :=
          VersionMgt.GetBOMVersion(
            ProdBOM1,                                       // P8001030
            GlobalCalcDate, false);
        UnitOfMeasure1 :=
          VersionMgt.GetBOMUnitOfMeasure(
            ProdBOM1, VersionCode1);                         // P8001030

        ItemAssembly := Item1;
        BuildMatrix(
          ProdBOM1,                                         // P8001030
          VersionCode1, LocationCode, 1,                      // P8001030
          UOMMgt.GetQtyPerUnitOfMeasure(
            Item1, UnitOfMeasure1) /
          UOMMgt.GetQtyPerUnitOfMeasure(
            Item1, Item1."Base Unit of Measure"), 0); // PR1.00

        ProdBOM2 := Item2.ProductionBOMNo('', LocationCode); // P8001030
        VersionCode2 :=
          VersionMgt.GetBOMVersion(
            ProdBOM2,                                       // P8001030
            GlobalCalcDate, false);
        UnitOfMeasure2 :=
          VersionMgt.GetBOMUnitOfMeasure(
            ProdBOM2, VersionCode2);                         // P8001030

        ItemAssembly := Item2;
        BuildMatrix(
          ProdBOM2,                                         // P8001030
          VersionCode2, LocationCode, 1,                      // P8001030
          UOMMgt.GetQtyPerUnitOfMeasure(
            Item2, UnitOfMeasure2) /
          UOMMgt.GetQtyPerUnitOfMeasure(
            Item2, Item2."Base Unit of Measure"), 0); // PR1.00
    end;

    procedure BOMMatrixFromBOM(ProdBOM: Record "Production BOM Header"; NewMultiLevel: Boolean)
    begin
        // P80096141 - Original signature
        BOMMatrixFromBOM(ProdBOM, NewMultiLevel, '');
    end;

    procedure BOMMatrixFromBOM(ProdBOM: Record "Production BOM Header"; NewMultiLevel: Boolean; LocationCode: Code[10])
    begin
        ComponentList.DeleteAll();
        ComponentEntry.Reset();
        ComponentEntry.DeleteAll();

        MultiLevel := NewMultiLevel;
        MatrixType := MatrixType::Version;
        BuildMatrix(ProdBOM."No.", '', LocationCode, 1, 1, ProdBOM."Mfg. BOM Type"); // PR1.00, P8001030
        ProdBOMVersion.SetRange("Production BOM No.", ProdBOM."No.");

        if ProdBOMVersion.Find('-') then
            repeat
                GlobalCalcDate := ProdBOMVersion."Starting Date";
                BuildMatrix(ProdBOM."No.", ProdBOMVersion."Version Code", LocationCode, 1, 1, ProdBOM."Mfg. BOM Type"); // PR1.00, P8001030
            until ProdBOMVersion.Next() = 0;
    end;

    local procedure BuildMatrix(ProdBOMNo: Code[20]; VersionCode: Code[20]; LocationCode: Code[10]; Level: Integer; Quantity: Decimal; Type: Option BOM,Formula,Process)
    var
        ProdBOMComponent: Record "Production BOM Line";
        Qty: Decimal;
        BOMNo: Code[20];
    begin
        // P8001030 - add parameter for LocationCode
        if Level > 20 then
            exit;

        ProdBOMComponent.SetRange("Production BOM No.", ProdBOMNo);
        ProdBOMComponent.SetRange("Version Code", VersionCode);
        if GlobalCalcDate <> 0D then begin
            ProdBOMComponent.SetFilter("Starting Date", '%1|..%2', 0D, GlobalCalcDate);
            ProdBOMComponent.SetFilter("Ending Date", '%1|%2..', 0D, GlobalCalcDate);
        end;

        if ProdBOMComponent.Find('-') then
            repeat
                case ProdBOMComponent.Type of
                    ProdBOMComponent.Type::Item:
                        if Item.Get(ProdBOMComponent."No.") then begin
                            OnBuildMatrixForItemOnAfterGetItem(ProdBOMComponent);
                            BOMNo := Item.ProductionBOMNo(ProdBOMComponent."Variant Code", LocationCode); // P8001030
                            if MultiLevel and (BOMNo <> '') then begin                                   // P8001030
                                VersionMgt.GetBOMVersion(BOMNo, GlobalCalcDate, false);                  // P8001030
                                OnBuildMatrixForItemOnBeforeRecursion(ProdBOMComponent);
                                // PR1.00 Begin
                                if Type = Type::BOM then
                                    Qty := ProdBOMComponent.Quantity
                                else
                                    Qty := ProdBOMComponent."Batch Quantity";
                                // PR1.00 End
                                BuildMatrix(
                                  BOMNo, VersionCode, LocationCode, Level + 1, // P8001030
                                  Quantity *
                                  UOMMgt.GetQtyPerUnitOfMeasure(Item, ProdBOMComponent."Unit of Measure Code") /
                                  UOMMgt.GetQtyPerUnitOfMeasure(Item, Item."Base Unit of Measure") /
                                  UOMMgt.GetQtyPerUnitOfMeasure(
                                    Item, VersionMgt.GetBOMUnitOfMeasure(BOMNo, VersionCode)) * // P8001030
                                  Qty, Type); // PR1.00
                            end else begin
                                ComponentList."Item No." := ProdBOMComponent."No.";
                                ComponentList."Variant Code" := ProdBOMComponent."Variant Code";
                                ComponentList.Description := ProdBOMComponent.Description;
                                ComponentList."Unit of Measure Code" := Item."Base Unit of Measure";
                                OnBuildMatrixForItemOnBeforeComponentListFind(ProdBOMComponent, ComponentList);
                                if not ComponentList.Find then
                                    ComponentList.Insert();
                                ComponentEntry2.Init();
                                ComponentEntry2."Item No." := ProdBOMComponent."No.";
                                ComponentEntry2."Variant Code" := ProdBOMComponent."Variant Code";
                                case MatrixType of
                                    MatrixType::Version:
                                        ComponentEntry2.ID := ProdBOMVersion."Version Code";
                                    MatrixType::Item:
                                        ComponentEntry2.ID := ItemAssembly."No.";
                                end;
                                // PR1.00 Begin
                                if Type = Type::BOM then
                                    Qty := ProdBOMComponent.Quantity
                                else
                                    Qty := ProdBOMComponent."Batch Quantity";
                                // PR1.00 End
                                ComponentEntry2.Quantity :=
                                  Qty * // PR1.00
                                  UOMMgt.GetQtyPerUnitOfMeasure(Item, ProdBOMComponent."Unit of Measure Code") /
                                  UOMMgt.GetQtyPerUnitOfMeasure(Item, Item."Base Unit of Measure") *
                                  Quantity;
                                ComponentEntry := ComponentEntry2;
                                ComponentEntry.SetRange("Item No.", ComponentEntry2."Item No.");
                                ComponentEntry.SetRange("Variant Code", ComponentEntry2."Variant Code");
                                ComponentEntry.SetRange(ID, ComponentEntry2.ID);
                                if ComponentEntry.FindFirst() then begin
                                    ComponentEntry.Quantity :=
                                      ComponentEntry.Quantity + ComponentEntry2.Quantity;
                                    ComponentEntry.Modify();
                                end else
                                    ComponentEntry.Insert();
                            end;
                        end;
                    // PR1.00 Begin
                    ProdBOMComponent.Type::FOODUnapprovedItem:
                        begin
                            if UnapprItem.Get(ProdBOMComponent."No.") then begin
                                ComponentList."Item No." := ProdBOMComponent."No.";
                                ComponentList.Description := ProdBOMComponent.Description;
                                ComponentList."Unit of Measure Code" := UnapprItem."Base Unit of Measure";
                                if not ComponentList.Find then
                                    ComponentList.Insert;
                                ComponentEntry2."Item No." := ProdBOMComponent."No.";
                                case MatrixType of
                                    MatrixType::Version:
                                        ComponentEntry2.ID := ProdBOMVersion."Version Code";
                                    MatrixType::Item:
                                        ComponentEntry2.ID := ItemAssembly."No.";
                                end;
                                if Type = Type::BOM then
                                    Qty := ProdBOMComponent.Quantity
                                else
                                    Qty := ProdBOMComponent."Batch Quantity";
                                ComponentEntry2.Quantity :=
                                  Qty *
                                  P800UOMFns.GetQtyPerUnitOfMeasureUnapp(UnapprItem, ProdBOMComponent."Unit of Measure Code") /
                                  P800UOMFns.GetQtyPerUnitOfMeasureUnapp(UnapprItem, UnapprItem."Base Unit of Measure") *
                                  Quantity;
                                ComponentEntry := ComponentEntry2;
                                ComponentEntry.SetRange("Item No.", ComponentEntry2."Item No.");
                                ComponentEntry.SetRange(ID, ComponentEntry2.ID);
                                if ComponentEntry.Find('-') then begin
                                    ComponentEntry.Quantity :=
                                      ComponentEntry.Quantity + ComponentEntry2.Quantity;
                                    ComponentEntry.Modify;
                                end else
                                    ComponentEntry.Insert();
                            end;
                        end;
                    // PR1.00 End
                    ProdBOMComponent.Type::"Production BOM":
                        begin
                            if ProdBOMHeader.Get(ProdBOMComponent."No.") then begin // P8001132
                                                                                    // PR1.00 Begin
                                if Type = Type::BOM then
                                    Qty := ProdBOMComponent.Quantity
                                else
                                    Qty := ProdBOMComponent."Batch Quantity";
                                // PR1.00 End
                                BuildMatrix(
                                  ProdBOMHeader."No.",
                                  GetVersion(ProdBOMHeader."No."),
                                  LocationCode, // P8001030
                                  Level + 1,
                                  Quantity * Qty, ProdBOMHeader."Mfg. BOM Type"); // PR1.00
                            end; // P8001132
                        end;
                end;
            until ProdBOMComponent.Next() = 0;
    end;

    local procedure GetVersion(ProdBOMNo: Code[20]): Code[20]
    begin
        ProdBOMVersion2.SetRange("Production BOM No.", ProdBOMNo);
        ProdBOMVersion2.SetFilter("Starting Date", '%1|..%2', 0D, GlobalCalcDate);
        if ProdBOMVersion2.FindLast() then
            exit(ProdBOMVersion2."Version Code");

        exit('');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBuildMatrixForItemOnAfterGetItem(var ProductionBOMLine: Record "Production BOM Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBuildMatrixForItemOnBeforeRecursion(var ProductionBOMLine: Record "Production BOM Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBuildMatrixForItemOnBeforeComponentListFind(var ProductionBOMLine: Record "Production BOM Line"; var ProductionMatrixBOMLine: Record "Production Matrix BOM Line")
    begin
    end;
}

