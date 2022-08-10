codeunit 37002471 "Event Subscribers (Process)"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW113.00.03
    // P80084737, To Increase, Jack Reynolds, 10 OCT 19
    //   Modify subscriptions for RunTrigger
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00


    trigger OnRun()
    begin
    end;

    var
        Text37002000: Label 'Unapproved items are not allowed.';

    [EventSubscriber(ObjectType::Table, Database::"Routing Header", 'OnBeforeDeleteEvent', '', true, false)]
    local procedure RoutingHeader_OnBeforeDelete(var Rec: Record "Routing Header"; RunTrigger: Boolean)
    var
        BOMEquip: Record "Prod. BOM Equipment";
        SKU: Record "Stockkeeping Unit";
        ErrorUsedOnEquipment: Label 'This Routing is being used on Production BOM Equipment.';
        ErrorUsedOnSKU: Label 'This Routing is being used on Stockkeeping Units.';
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        // P8001030
        SKU.SetRange("Routing No.", Rec."No.");
        if SKU.Find('-') then
            Error(ErrorUsedOnSKU);

        // P8000219A
        BOMEquip.SetRange("Routing No.", Rec."No.");
        if BOMEquip.Find('-') then
            Error(ErrorUsedOnEquipment);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Production BOM Line", 'OnValidateNoOnAfterAssignItemFields', '', true, false)]
    local procedure ProductionBOMLine_OnValidateNoOnAfterAssignItemFields(var ProductionBOMLine: Record "Production BOM Line"; Item: Record Item)
    var
        ProductionBOMVersion: Record "Production BOM Version";
    begin
        ProductionBOMLine.Validate("Unit Cost (Costing Units)", Item."Unit Cost"); // PR3.10
        // PR1.00
        ProductionBOMVersion.Get(ProductionBOMLine."Production BOM No.", ProductionBOMLine."Version Code");
        ProductionBOMLine."Auto Plan if Component" := (ProductionBOMVersion.Type = ProductionBOMVersion.Type::Formula) and
            Item."Auto Plan if Component";
        // PR1.00
    end;

    [EventSubscriber(ObjectType::Table, Database::"Production BOM Line", 'OnValidateNoOnAfterAssignProdBOMFields', '', true, false)]
    local procedure ProductionBOMLine_OnValidateNoOnAfterAssignProdBOMFields(var ProductionBOMLine: Record "Production BOM Line"; ProductionBOMHeader: Record "Production BOM Header")
    var
        BOMVariables: Record "BOM Variables";
    begin
        // PR1.00.03 Begin
        ProductionBOMLine.CalcPhantom(BOMVariables);
        if BOMVariables.Type = BOMVariables.Type::BOM then
            ProductionBOMLine."Unit Cost" := BOMVariables."Total Cost"
        else
            if ProductionBOMLine."Unit of Measure Code" = BOMVariables."Weight UOM" then
                ProductionBOMLine."Unit Cost" := BOMVariables."Total Cost (per Weight UOM)"
            else
                if ProductionBOMLine."Unit of Measure Code" = BOMVariables."Volume UOM" then
                    ProductionBOMLine."Unit Cost" := BOMVariables."Total Cost (per volume UOM)"
                else
                    ProductionBOMLine."Unit Cost" := 0;
        ProductionBOMLine.Validate("Unit Cost", Round(ProductionBOMLine."Unit Cost", 0.00001)); // P8000551A
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Production Order Document", 'OnBeforeToProdOrderModify', '', true, false)]
    local procedure CopyProductionOrderDocument_OnBeforeToProdOrderModify(var ToProdOrder: Record "Production Order"; FromProdOrder: Record "Production Order")
    begin
        // P80066030
        ToProdOrder.Validate("Production Sequence Code", FromProdOrder."Production Sequence Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', true, false)]
    local procedure ItemJnlPostLine_OnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    begin
        // P8004516
        NewItemLedgEntry."Work Shift Code" := ItemJournalLine."Work Shift Code"; // P8001231
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnAfterGetPageID', '', true, false)]
    local procedure PageManagement_OnAfterGetPageID(RecordRef: RecordRef; var PageID: Integer)
    var
        ProductionBOMHeader: Record "Production BOM Header";
    begin
        // P8004516, P80066030
        case RecordRef.Number of
            DATABASE::"Production BOM Header":
                begin
                    RecordRef.SetTable(ProductionBOMHeader);
                    case ProductionBOMHeader."Mfg. BOM Type" of
                        ProductionBOMHeader."Mfg. BOM Type"::BOM:
                            PageID := PAGE::"Package BOM";
                        ProductionBOMHeader."Mfg. BOM Type"::Formula:
                            PageID := PAGE::"Production Formula";
                        ProductionBOMHeader."Mfg. BOM Type"::Process:
                            if (ProductionBOMHeader."Output Type" = ProductionBOMHeader."Output Type"::Item) then
                                PageID := PAGE::"Item Process"
                            else
                                PageID := PAGE::"Co-Product Process";
                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process 800 Core Functions", 'OnInitializeP800', '', true, false)]
    local procedure Process800CoreFunctions_OnInitializeP800(CompName: Text[30]; var SourceCodeSetup: Record "Source Code Setup"; var SourceCode: Record "Source Code"; var ReportSelections: Record "Report Selections")
    var
        ProcessSetup: Record "Process Setup";
    begin
        // P80066030
        if CompName <> CompanyName then
            ProcessSetup.ChangeCompany(CompName);
        if not ProcessSetup.Find('-') then begin
            ProcessSetup.Init;
            ProcessSetup.Insert;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Order Status Management", 'OnAfterTransProdOrder', '', true, false)]
    procedure ProdOrderStatusManagement_OnAfterTransProdOrder(var FromProdOrder: Record "Production Order"; var ToProdOrder: Record "Production Order")
    var
        FromProdXref1: Record "Production Order XRef";
        FromProdXref2: Record "Production Order XRef";
        ToProdXref: Record "Production Order XRef";
        Process800ProdOrderMgt: Codeunit "Process 800 Prod. Order Mgt.";
    begin
        // TransProdOrderXref
        FromProdXref1.SetRange("Prod. Order Status", FromProdOrder.Status);
        FromProdXref1.SetRange("Prod. Order No.", FromProdOrder."No.");
        if FromProdXref1.Find('-') then
            repeat
                FromProdXref1.Delete(ToProdOrder.Status <> ToProdOrder.Status::Finished); // P8000087A, P8000519A
                if (FromProdXref1."Source Table ID" = DATABASE::"Sales Line") or
                  (ToProdOrder.Status <> ToProdOrder.Status::Finished)
                then begin
                    ToProdXref := FromProdXref1;
                    ToProdXref."Prod. Order Status" := ToProdOrder.Status;
                    ToProdXref."Prod. Order No." := ToProdOrder."No.";
                    ToProdXref.Insert(true);
                end else
                    if (FromProdXref1."Source Table ID" <> DATABASE::"Sales Line") and
             (ToProdOrder.Status = ToProdOrder.Status::Finished)
           then
                        Process800ProdOrderMgt.RemovePlanningOrder(FromProdXref1."Source Type",
                          FromProdXref1."Source No.", FromProdXref1."Source Line No.");
            until FromProdXref1.Next = 0;
        //FromProdXref1.DELETEALL; // P8000087A

        FromProdXref2.SetRange("Source Table ID", DATABASE::"Production Order");
        FromProdXref2.SetRange("Source Type", FromProdOrder.Status);
        FromProdXref2.SetRange("Source No.", FromProdOrder."No.");
        if FromProdXref2.Find('-') then
            repeat
                ToProdXref := FromProdXref2;
                ToProdXref."Source Type" := ToProdOrder.Status;
                ToProdXref."Source No." := ToProdOrder."No.";
                ToProdXref.Insert(true);
            until FromProdXref2.Next = 0;
        FromProdXref2.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Production BOM-Check", 'OnAfterCode', '', true, false)]
    local procedure ProductionBOMCheck_OnAfterCode(var ProductionBOMHeader: Record "Production BOM Header"; VersionCode: Code[20])
    var
        ProductionBOMLine: Record "Production BOM Line";
    begin
        // P80073095
        // P8001289
        ProductionBOMLine.SetRange("Production BOM No.", ProductionBOMHeader."No.");
        ProductionBOMLine.SetRange("Version Code", VersionCode);
        ProductionBOMLine.SetRange(Type, ProductionBOMLine.Type::FOODUnapprovedItem);
        if not ProductionBOMLine.IsEmpty then
            Error(Text37002000);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Prod. Order", 'OnAfterProdOrderCompFilter', '', true, false)]
    local procedure CalculateProdOrder_OnAfterProdOrderCompFilter(var ProdOrderComp: Record "Prod. Order Component"; ProdBOMLine: Record "Production BOM Line")
    begin
        // P80073095
        ProdOrderComp.SetRange("Step Code", ProdBOMLine."Step Code"); // PR2.00.03
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Prod. Order", 'OnAfterTransferBOMComponent', '', true, false)]
    local procedure CalculateProdOrder_OnAfterTransferBOMComponent(var ProdOrderLine: Record "Prod. Order Line"; var ProductionBOMLine: Record "Production BOM Line"; var ProdOrderComponent: Record "Prod. Order Component")
    begin
        // P80073095
        ProdOrderComponent."Auto Plan" := ProductionBOMLine."Auto Plan if Component"; // PR1.00
        ProdOrderComponent."Step Code" := ProductionBOMLine."Step Code"; // PR2.00.03
        ProdOrderComponent."Production BOM No." := ProductionBOMLine."Production BOM No.";    // P8000153A
        ProdOrderComponent."Production BOM Version Code" := ProductionBOMLine."Version Code"; // P8000153A
        ProdOrderComponent."Production BOM Line No." := ProductionBOMLine."Line No.";         // P8000153A
                                                                                              // P8001082
        ProdOrderComponent.Validate("Pre-Process Type Code", ProductionBOMLine."Pre-Process Type Code");
        ProdOrderComponent.Validate("Pre-Process Lead Time (Days)", ProductionBOMLine."Pre-Process Lead Time (Days)");
        // P8001082
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Profile Offsetting", 'OnAfterTransferAttributes', '', true, false)]
    local procedure InventoryProfileOffsetting_OnAfterTransferAttributes(var ToInventoryProfile: Record "Inventory Profile"; var FromInventoryProfile: Record "Inventory Profile"; var TempSKU: Record "Stockkeeping Unit" temporary)
    begin
        // P80073095
        ToInventoryProfile."Pre-Process" := FromInventoryProfile."Pre-Process"; // P8001082
    end;
}

