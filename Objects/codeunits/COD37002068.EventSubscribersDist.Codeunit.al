codeunit 37002068 "Event Subscribers (Dist)"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // P113.00.03
    // P80084737, To Increase, Jack Reynolds, 10 OCT 19
    //     Modify subscriptions for RunTrigger
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterDeleteEvent', '', true, false)]
    local procedure Customer_OnAfterDelete(var Rec: Record Customer; RunTrigger: Boolean)
    var
        DeliveryRouteMatrix: Record "Delivery Routing Matrix Line";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        DeliveryRouteMatrix.SetFilter("Source Type", '%1|%2', DeliveryRouteMatrix."Source Type"::Customer, DeliveryRouteMatrix."Source Type"::"Ship-to");
        DeliveryRouteMatrix.SetRange("Source No.", Rec."No.");
        DeliveryRouteMatrix.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterDeleteEvent', '', true, false)]
    local procedure Vendor_OnAfterDelete(var Rec: Record Vendor; RunTrigger: Boolean)
    var
        PickupLocation: Record "Pickup Location";
        DeliveryRouteMatrix: Record "Delivery Routing Matrix Line";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        PickupLocation.SetRange("Vendor No.", Rec."No.");
        PickupLocation.DeleteAll;

        DeliveryRouteMatrix.SetFilter("Source Type", '%1|%2', DeliveryRouteMatrix."Source Type"::Vendor, DeliveryRouteMatrix."Source Type"::"Order Address");
        DeliveryRouteMatrix.SetRange("Source No.", Rec."No.");
        DeliveryRouteMatrix.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeTestNoSeries', '', true, false)]
    local procedure SalesHeader_OnBeforeTestNoSeries(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        // P80073095
        if IsHandled then
            exit;

        SalesSetup.Get;
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::FOODStandingOrder:
                begin
                    SalesSetup.TestField("Standing Order Nos.");
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnUpdateSalesLineByChangedFieldName', '', true, false)]
    local procedure SalesHeader_OnUpdateSalesLineByChangedFieldName(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ChangedFieldName: Text[100])
    begin
        // P80053245
        case ChangedFieldName of
            SalesHeader.FieldCaption("Delivery Route No."):
                SalesLine.Validate("Delivery Route No.", SalesHeader."Delivery Route No.");
            SalesHeader.FieldCaption("Delivery Stop No."):
                SalesLine.Validate("Delivery Stop No.", SalesHeader."Delivery Stop No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignHeaderValues', '', true, false)]
    local procedure SalesLine_OnAfterAssignHeaderValues(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
        // P80053245
        SalesLine.Validate("Delivery Route No.", SalesHeader."Delivery Route No.");   // P80042706
        SalesLine."Delivery Stop No." := SalesHeader."Delivery Stop No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Expected Receipt Date', true, false)]
    local procedure PurchaseHeader_OnAfterValidate_ExpectedReceiptDate(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; CurrFieldNo: Integer)
    var
        DeliveryRouteMgmt: Codeunit "Delivery Route Management";
    begin
        // P80066030
        DeliveryRouteMgmt.GetPurchDeliveryRouting(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromSalesHeader', '', true, false)]
    local procedure ItemJournalLine_OnAfterCopyItemJnlLineFromSalesHeader(var ItemJnlLine: Record "Item Journal Line"; SalesHeader: Record "Sales Header")
    begin
        // P80053245
        ItemJnlLine."Delivery Route No." := SalesHeader."Delivery Route No."; // P8007748
    end;

    [EventSubscriber(ObjectType::Table, Database::"Ship-to Address", 'OnAfterDeleteEvent', '', true, false)]
    local procedure ShipToAddress_OnAfterDelete(var Rec: Record "Ship-to Address"; RunTrigger: Boolean)
    var
        DeliveryRouteMatrix: Record "Delivery Routing Matrix Line";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        DeliveryRouteMatrix.SetRange("Source Type", DeliveryRouteMatrix."Source Type"::"Ship-to");
        DeliveryRouteMatrix.SetRange("Source No.", Rec."Customer No.");
        DeliveryRouteMatrix.SetRange("Source No. 2", Rec.Code);
        DeliveryRouteMatrix.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Order Address", 'OnAfterDeleteEvent', '', true, false)]
    local procedure OrderAddress_OnAfterDelete(var Rec: Record "Order Address"; RunTrigger: Boolean)
    var
        DeliveryRouteMatrix: Record "Delivery Routing Matrix Line";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        DeliveryRouteMatrix.SetRange("Source Type", DeliveryRouteMatrix."Source Type"::"Order Address");
        DeliveryRouteMatrix.SetRange("Source No.", Rec."Vendor No.");
        DeliveryRouteMatrix.SetRange("Source No. 2", Rec.Code);
        DeliveryRouteMatrix.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Route", 'OnAfterDeleteEvent', '', true, false)]
    local procedure TransferRoute_OnAfterDelete(var Rec: Record "Transfer Route"; RunTrigger: Boolean)
    var
        DeliveryRoutingMatrix: Record "Delivery Routing Matrix Line";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        // P8000954
        DeliveryRoutingMatrix.SetRange("Source Type", DeliveryRoutingMatrix."Source Type"::Transfer);
        DeliveryRoutingMatrix.SetRange("Source No.", Rec."Transfer-from Code");
        DeliveryRoutingMatrix.SetRange("Source No. 2", Rec."Transfer-to Code");
        DeliveryRoutingMatrix.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', true, false)]
    local procedure ItemJnlPostLine_OnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    begin
        // P8004516
        NewItemLedgEntry."Delivery Route No." := ItemJournalLine."Delivery Route No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnAfterGetPageID', '', true, false)]
    local procedure PageManagement_OnAfterGetPageID(RecordRef: RecordRef; var PageID: Integer)
    var
        SalesHeader: Record "Sales Header";
    begin
        // P8004516
        if RecordRef.Number = DATABASE::"Sales Header" then begin
            RecordRef.SetTable(SalesHeader);
            if SalesHeader."Document Type" = SalesHeader."Document Type"::FOODStandingOrder then
                PageID := PAGE::"Standing Sales Order";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", 'OnBeforePostedWhseShptHeaderInsert', '', true, false)]
    local procedure WhsePostShipment_OnBeforePostedWhseShptHeaderInsert(var PostedWhseShipmentHeader: Record "Posted Whse. Shipment Header"; WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin
        // P8006630
        PostedWhseShipmentHeader."Delivery Trip" := WarehouseShipmentHeader."Delivery Trip";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process 800 Core Functions", 'OnInitializeP800', '', true, false)]
    local procedure Process800CoreFunctions_OnInitializeP800(CompName: Text[30]; var SourceCodeSetup: Record "Source Code Setup"; var SourceCode: Record "Source Code"; var ReportSelections: Record "Report Selections")
    var
        TransportMgtSetup: Record "N138 Transport Mgt. Setup";
    begin
        // P80066030
        if CompName <> CompanyName then
            TransportMgtSetup.ChangeCompany(CompName);
        if not TransportMgtSetup.Find('-') then begin
            TransportMgtSetup.Init;
            TransportMgtSetup.Insert;
        end;
    end;
}

