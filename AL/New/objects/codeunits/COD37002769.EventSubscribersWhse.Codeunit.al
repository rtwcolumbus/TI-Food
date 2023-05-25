codeunit 37002769 "Event Subscribers (Whse)"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW113.00.03
    // P80084737, To Increase, Jack Reynolds, 10 OCT 19
    //   Modify subscriptions for RunTrigger
    //
    // PRW120.4
    // P800158446, To-Increase, Gangabhushan, 20 OCT 22
    //   CS00222757 | Warehouse shipment - Use filters to get source docs is not working properly

    SingleInstance = true; // P800158446

    var
        DelTripFilter: Code[20]; // P800158446


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnAfterDeleteEvent', '', true, false)]
    local procedure Location_OnAfterDelete(var Rec: Record Location; RunTrigger: Boolean)
    var
        ReplArea: Record "Replenishment Area";
        FixedBinItem: Record "Item Fixed Prod. Bin";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737
        if Rec.ISTEMPORARY then exit; // P80084373

        ReplArea.Reset;
        ReplArea.SetRange("Location Code", Rec.Code);
        ReplArea.DeleteAll(true);

        FixedBinItem.Reset;
        FixedBinItem.SetRange("Location Code", Rec.Code);
        FixedBinItem.DeleteAll(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnAfterValidateEvent', 'Bin Mandatory', true, false)]
    local procedure Location_OnAfterValidate_BinMandatory(var Rec: Record Location; var xRec: Record Location; CurrFieldNo: Integer)
    begin
        // P80066030
        if not Rec."Bin Mandatory" then begin
            Rec."Receipt Bin Code (1-Doc)" := '';         // P8000631A
            Rec."Shipment Bin Code (1-Doc)" := '';        // P8000631A
            Rec."Combine Reg. Whse. Activities" := false; // P8001280
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnAfterValidateEvent', 'Directed Put-away and Pick', true, false)]
    local procedure Location_OnAfterValidate_DirectedPutAwayAndPick(var Rec: Record Location; var xRec: Record Location; CurrFieldNo: Integer)
    begin
        // P80066030
        if not Rec."Bin Mandatory" then begin
            Rec."Receipt Bin Code (1-Doc)" := '';         // P8000631A
            Rec."Shipment Bin Code (1-Doc)" := '';        // P8000631A
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Date Compress Whse. Entries", 'OnBeforeInsertNewEntry', '', true, false)]
    local procedure DateCompressWhseEntries_OnBeforeInsertNewEntry(var WarehouseEntry: Record "Warehouse Entry")
    begin
        // P8006630
        WarehouseEntry."Registering Date/Time" := CurrentDateTime;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Replan Production Order", 'OnProdOrderCompOnAfterGetRecordOnBeforeProdOrderModify', '', false, true)]
    local procedure ReplanProductionOrder_OnProdOrderCompOnAfterGetRecordOnBeforeProdOrderModify(var ProdOrder: Record "Production Order"; MainProdOrder: Record "Production Order"; ProdOrderComp: Record "Prod. Order Component")
    begin
        // P8001279
        ProdOrder.Validate("Replenishment Area Code", ProdOrder.GetDefaultReplArea);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Sales Release", 'OnAfterReleaseSetFilters', '', true, false)]
    local procedure WhseSalesRelease_OnAfterReleaseSetFilters(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
        // P8007609
        SalesLine.SetFilter("Outstanding Quantity", '<>%1', 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Purch. Release", 'OnAfterReleaseSetFilters', '', true, false)]
    local procedure WhsePurchRelease_OnAfterReleaseSetFilters(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header")
    begin
        // P8007609
        PurchaseLine.SetFilter("Outstanding Quantity", '<>%1', 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Pick", 'OnCreateWhseDocTakeLineOnAfterSetFilters', '', true, false)]
    local procedure CreatePick_OnCreateWhseDocTakeLineOnAfterSetFilters(var TempWarehouseActivityLine: Record "Warehouse Activity Line" temporary; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
        // P8000322A
        FilterStagingFromFields(TempWarehouseActivityLine, WarehouseActivityLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Pick", 'OnCreateWhseDocPlaceLineOnAfterSetFilters', '', true, false)]
    local procedure CreatePick_OnCreateWhseDocPlaceLineOnAfterSetFilters(var TempWarehouseActivityLine: Record "Warehouse Activity Line" temporary; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
        // P8000322A
        FilterStagingFromFields(TempWarehouseActivityLine, WarehouseActivityLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Prod. Order from Sale", 'OnAfterCreateProdOrderFromSalesLine', '', true, false)]
    local procedure CreateProdOrderFromSale_OnAfterCreateProdOrderFromSalesLine(var ProdOrder: Record "Production Order"; var SalesLine: Record "Sales Line")
    begin
        // P80066030
        // P8001279
        ProdOrder.Validate("Replenishment Area Code", ProdOrder.GetDefaultReplArea);
        if ProdOrder."Bin Code" = '' then
            ProdOrder."Bin Code" := SalesLine."Bin Code";
    end;

    local procedure FilterStagingFromFields(var WhseActivLine: Record "Warehouse Activity Line"; var WhseActivLine2: Record "Warehouse Activity Line")
    begin
        // P8000322A
        with WhseActivLine do begin
            SetRange("From Staged Pick No.", WhseActivLine2."From Staged Pick No.");
            SetRange("From Staged Pick Line No.", WhseActivLine2."From Staged Pick Line No.");
        end;
    end;

    procedure SetDelTripFilter(FilterString: Code[20])
    begin
        // P800158446
        DelTripFilter := FilterString;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Warehouse Source Filter", 'OnBeforeSetTableView', '', true, false)]
    local procedure WarehouseSourceFilter_OnBeforeSetTableView(var WarehouseRequest: Record "Warehouse Request")
    begin
        // P800158446
        if DelTripFilter <> '' then
            WarehouseRequest.SetFilter("Delivery Trip", '''''|%1', DelTripFilter)
        else
            WarehouseRequest.SetRange("Delivery Trip", '');
        DelTripFilter := '';
    end;
}

