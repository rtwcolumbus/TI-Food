codeunit 37002575 "Event Subscribers (Cont)"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00


    trigger OnRun()
    begin
    end;

    var
        ContainersAreAssigned: Label 'Containers are assigned to %1 %2.';
        ErrorLessThanContainerQuantity: Label '%1 would be less than quantity assigned through containers.';

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterInitOutstandingQty', '', true, false)]
    local procedure SalesLine_OnAfterInitOutstandingQty(var SalesLine: Record "Sales Line")
    begin
        // P8001324, P80046533
        if (SalesLine."Outstanding Quantity" < SalesLine.GetContainerQuantity('')) and (SalesLine.GetContainerQuantity('') <> 0) then
            Error(ErrorLessThanContainerQuantity, SalesLine.FieldCaption("Outstanding Quantity"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterInitOutstandingQty', '', true, false)]
    local procedure PurchaseLine_OnAfterInitOutstandingQty(var PurchaseLine: Record "Purchase Line")
    begin
        // P8001324, P80046533
        if (PurchaseLine."Outstanding Quantity" < PurchaseLine.GetContainerQuantity('')) and (PurchaseLine.GetContainerQuantity('') <> 0) then
            Error(ErrorLessThanContainerQuantity, PurchaseLine.FieldCaption("Outstanding Quantity"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Production Order", 'OnBeforeDeleteEvent', '', true, false)]
    local procedure ProductionOrder_OnBeforeDelete(var Rec: Record "Production Order"; RunTrigger: Boolean)
    var
        ContainerHeader: Record "Container Header";
    begin
        // P80056709
        if Rec.IsTemporary then
            exit;

        ContainerHeader.SetRange("Document Type", DATABASE::"Prod. Order Component");
        ContainerHeader.SetRange("Document Subtype", Rec.Status);
        ContainerHeader.SetRange("Document No.", Rec."No.");
        if not ContainerHeader.IsEmpty then
            Error(ContainersAreAssigned, Rec.TableCaption, Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Production Order", 'OnBeforeValidateEvent', 'Location Code', true, false)]
    local procedure ProductionOrder_OnBeforeValidate_LocationCode(var Rec: Record "Production Order"; var xRec: Record "Production Order"; CurrFieldNo: Integer)
    var
        ContainerHeader: Record "Container Header";
    begin
        // P80056709
        if Rec.IsTemporary then
            exit;

        if Rec."Location Code" = xRec."Location Code" then
            exit;

        ContainerHeader.SetRange("Document Type", DATABASE::"Prod. Order Component");
        ContainerHeader.SetRange("Document Subtype", Rec.Status);
        ContainerHeader.SetRange("Document No.", Rec."No.");
        if not ContainerHeader.IsEmpty then
            Error(ContainersAreAssigned, Rec.TableCaption, Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Line", 'OnBeforeDeleteEvent', '', true, false)]
    local procedure ProdOrderLine_OnBeforeDelete(var Rec: Record "Prod. Order Line"; RunTrigger: Boolean)
    var
        Location: Record Location;
        ProductionOrder: Record "Production Order";
        ContainerHeader: Record "Container Header";
    begin
        // P80056709
        if Rec.IsTemporary then
            exit;

        ProductionOrder.Get(Rec.Status, Rec."Prod. Order No.");
        if ProductionOrder."Location Code" <> '' then
            Location.Get(ProductionOrder."Location Code");
        ContainerHeader.SetRange("Document Type", DATABASE::"Prod. Order Component");
        ContainerHeader.SetRange("Document Subtype", Rec.Status);
        ContainerHeader.SetRange("Document No.", Rec."Prod. Order No.");
        if Location."Pick Production by Line" then
            ContainerHeader.SetRange("Document Line No.", Rec."Line No.");
        if not ContainerHeader.IsEmpty then
            Error(ContainersAreAssigned, ProductionOrder.TableCaption, Rec."Prod. Order No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Component", 'OnBeforeDeleteEvent', '', true, false)]
    local procedure ProdOrderComponent_OnBeforeDelete(var Rec: Record "Prod. Order Component"; RunTrigger: Boolean)
    var
        Location: Record Location;
        ProductionOrder: Record "Production Order";
        ContainerHeader: Record "Container Header";
    begin
        // P80056709
        if Rec.IsTemporary then
            exit;

        ProductionOrder.Get(Rec.Status, Rec."Prod. Order No.");
        if ProductionOrder."Location Code" <> '' then
            Location.Get(ProductionOrder."Location Code");
        ContainerHeader.SetRange("Document Type", DATABASE::"Prod. Order Component");
        ContainerHeader.SetRange("Document Subtype", Rec.Status);
        ContainerHeader.SetRange("Document No.", Rec."Prod. Order No.");
        if Location."Pick Production by Line" then
            ContainerHeader.SetRange("Document Line No.", Rec."Prod. Order Line No.");
        if not ContainerHeader.IsEmpty then
            Error(ContainersAreAssigned, ProductionOrder.TableCaption, Rec."Prod. Order No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Container Header", 'OnAfterInsertEvent', '', true, false)]
    local procedure ContainerHeader_OnAfterInsert(var Rec: Record "Container Header"; RunTrigger: Boolean)
    var
        CompanyInformation: Record "Company Information";
        InventorySetup: Record "Inventory Setup";
        ContainerFunctions: Codeunit "Container Functions";
    begin
        // P80055555
        if Rec.IsTemporary then
            exit;

        CompanyInformation.Get;
        InventorySetup.Get;

        Rec.SSCC := ContainerFunctions.CreateSSCC(CompanyInformation."GS1 Company Prefix", InventorySetup."SSCC Extension Digit", Rec."Serial Reference");
        Rec.Validate("License Plate", Rec.DefaultLicensePlate);
        Rec.Modify;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnAfterFillTableBuffer', '', true, false)]
    local procedure CalcGLAccWhereUsed_OnAfterFillTableBuffer(var TableBuffer: Record "Integer")
    begin
        // P80073095
        TableBuffer.Number := DATABASE::"Container Charge";
        TableBuffer.Insert;
        TableBuffer.Number := DATABASE::"Container Type Charge";
        TableBuffer.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnShowExtensionPage', '', true, false)]
    local procedure CalcGLAccWhereUsed_OnShowExtensionPage(GLAccountWhereUsed: Record "G/L Account Where-Used")
    var
        ContainerCharge: Record "Container Charge";
        ContainerTypeCharge: Record "Container Type Charge";
    begin
        // P80066030
        case GLAccountWhereUsed."Table ID" of
            DATABASE::"Container Charge":
                begin
                    ContainerCharge.Code := CopyStr(GLAccountWhereUsed."Key 1", 1, MaxStrLen(ContainerCharge.Code));
                    PAGE.Run(0, ContainerCharge);
                end;
            DATABASE::"Container Type Charge":
                begin
                    ContainerTypeCharge."Container Type Code" := CopyStr(GLAccountWhereUsed."Key 1", 1, MaxStrLen(ContainerTypeCharge."Container Type Code"));
                    ContainerTypeCharge."Container Charge Code" := CopyStr(GLAccountWhereUsed."Key 2", 1, MaxStrLen(ContainerTypeCharge."Container Charge Code"));
                    PAGE.Run(PAGE::"Container Type Charges", ContainerTypeCharge);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnAfterTransferOrderPostShipment', '', true, false)]
    local procedure TransferOrderPostShipment_OnAfterTransferOrderPostShipment(var TransferHeader: Record "Transfer Header")
    var
        ContainerHeader: Record "Container Header";
        ContainerFunctions: Codeunit "Container Functions";
    begin
        // P80053245
        if not TransferHeader."Direct Transfer" then
            exit;

        ContainerHeader.SetRange(Inbound, true);
        ContainerHeader.SetRange("Document Type", DATABASE::"Transfer Line");
        ContainerHeader.SetRange("Document Subtype", 1);
        ContainerHeader.SetRange("Document No.", TransferHeader."No.");
        if ContainerHeader.FindSet(true) then
            repeat
                ContainerHeader."Ship/Receive" := true;
                ContainerHeader.Modify;
                ContainerFunctions.UpdateContainerShipReceive(ContainerHeader, true, false);
            until ContainerHeader.Next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Pick", 'OnAfterWhseActivLineInsert', '', true, false)]
    local procedure CreatePick_OnAfterWhseActivLineInsert(var WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        ContainerHeader: Record "Container Header";
    begin
        // P80056710
        if WarehouseActivityLine."Container ID" = '' then
            exit;

        ContainerHeader.Get(WarehouseActivityLine."Container ID");
        WarehouseActivityLine."Container License Plate" := ContainerHeader."License Plate";
        WarehouseActivityLine.Modify;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Pick", 'OnCreateWhseDocTakeLineOnAfterSetFilters', '', true, false)]
    local procedure CreatePick_OnCreateWhseDocTakeLineOnAfterSetFilters(var TempWarehouseActivityLine: Record "Warehouse Activity Line" temporary; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
        // P8001347
        TempWarehouseActivityLine.SetRange("Container ID", WarehouseActivityLine."Container ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Pick", 'OnCreateWhseDocPlaceLineOnAfterSetFilters', '', true, false)]
    local procedure CreatePick_OnCreateWhseDocPlaceLineOnAfterSetFilters(var TempWarehouseActivityLine: Record "Warehouse Activity Line" temporary; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
        // P8001347
        TempWarehouseActivityLine.SetRange("Container ID", WarehouseActivityLine."Container ID");
        TempWarehouseActivityLine.SetRange("Container Qty.", WarehouseActivityLine."Container Qty.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process 800 Core Functions", 'OnInitializeP800', '', true, false)]
    local procedure Process800CoreFunctions_OnInitializeP800(CompName: Text[30]; var SourceCodeSetup: Record "Source Code Setup"; var SourceCode: Record "Source Code"; var ReportSelections: Record "Report Selections")
    var
        Process800CoreFunctions: Codeunit "Process 800 Core Functions";
        CONTJNL: Label 'CONTJNL';
    begin
        // P80066030
        Process800CoreFunctions.InsertSourceCode(SourceCode, SourceCodeSetup."Container Journal", CONTJNL, Process800CoreFunctions.PageName(PAGE::"Container Journal"));
    end;
}

