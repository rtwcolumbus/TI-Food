codeunit 37002604 "Event Subscribers (CoBy)"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Carry Out Action", 'OnInsertProdOrderWithReqLine', '', true, false)]
    local procedure CarryOutAction_OnInsertProdOrderWithReqLine(var ProductionOrder: Record "Production Order"; var RequisitionLine: Record "Requisition Line")
    var
        FamilyBOMHeader: Record "Production BOM Header";
        FamilyLine: Record "Family Line";
        P800UOMMgmt: Codeunit "Process 800 UOM Functions";
    begin
        // P80053245
        // P8001092
        if FamilyBOMHeader.Get(RequisitionLine."Production BOM No.") then
            if FamilyBOMHeader.IsProdFamilyBOM() then
                if FamilyLine.FindOutputItem(RequisitionLine."Production BOM No.", RequisitionLine."No.") then begin
                    ProductionOrder."Source Type" := ProductionOrder."Source Type"::Family;
                    ProductionOrder."Source No." := RequisitionLine."Production BOM No.";
                    ProductionOrder."Family Process Order" := true;
                    ProductionOrder."Inventory Posting Group" := '';
                    ProductionOrder."Gen. Prod. Posting Group" := '';
                    ProductionOrder."Gen. Bus. Posting Group" := '';
                    ProductionOrder.Quantity := RequisitionLine.Quantity / FamilyLine.Quantity;
                    if (FamilyLine."Unit of Measure Code" <> RequisitionLine."Unit of Measure Code") then
                        ProductionOrder.Quantity := ProductionOrder.Quantity *
                          P800UOMMgmt.GetConversionFromTo(
                            RequisitionLine."No.", FamilyLine."Unit of Measure Code", RequisitionLine."Unit of Measure Code");
                    ProductionOrder."Unit Cost" := FamilyLine."Unit Cost";
                    ProductionOrder."Cost Amount" := FamilyLine."Cost Amount";
                    ProductionOrder."Low-Level Code" := FamilyLine."Low-Level Code";
                end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Carry Out Action", 'OnAfterTransferPlanningComp', '', true, false)]
    local procedure CarryOutAction_OnAfterTransferPlanningComp(var PlanningComponent: Record "Planning Component"; var ProdOrderComponent: Record "Prod. Order Component")
    var
        ProdBOMComponent: Record "Production BOM Line";
    begin
        // P80053245
        // P8001092
        if ProdOrderComponent."Prod. Order Line No." <> 0 then
            exit;
        if not ProdBOMComponent.Get(PlanningComponent."Production BOM No.", PlanningComponent."Production BOM Version Code", PlanningComponent."Production BOM Line No.") then
            exit;
        ProdOrderComponent.Validate("Quantity per", ProdBOMComponent."Batch Quantity");
    end;
}

