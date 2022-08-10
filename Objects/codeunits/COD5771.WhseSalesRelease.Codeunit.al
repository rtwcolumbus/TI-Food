codeunit 5771 "Whse.-Sales Release"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 02-02-2015, Initial Version
    // --------------------------------------------------------------------------------
    // TOM4220     05-10-2015  Auto creation of warehouse shipment with delivery trip
    // --------------------------------------------------------------------------------
    // TOM4222     08-10-2015  Support for adding warehouse request to warehouse shipment
    // --------------------------------------------------------------------------------
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Remove check so that a warehouse request is created even for non WMS locations
    // 
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Support for delivery trip orders
    // 
    // PRW16.00.01
    // P8000723, VerticalSoft, Jack Reynolds, 19 AUG 09
    //   Don't create warehouse request for blank locations
    // 
    // PRW17.10
    // P8001241, Columbus IT, Jack Reynolds, 12 NOV 13
    //   Fix problem deleting and changing orders on delivery trips
    // 
    // PRW18.00.01
    // P8001379, Columbus IT, Jack Reynolds, 31 MAR 15
    //   Integrate TOM and create trips based on routes
    // 
    // PRW18.00.02
    // P8004269, To-Increase, Jack Reynolds, 07 OCT 15
    //   Update source document Delivery Route No.
    // 
    // PRW19.00.01
    // P8007168, To-Increase, Dayakar Battini, 08 JUN 16
    //  Trip Settlement Posting Issue
    // 
    // P8007609, To-Increase, Dayakar Battini, 08 SEP 16
    //  Exclude nothing to ship documents
    // 
    // PRW110.0.01
    // P8008706, To-Increase, Dayakar Battini, 28 APR 17
    //  Delivery Trip link missing issue
    // 
    // P8008713, To-Increase, Jack Reynolds, 04 MAY 17
    //   Fix problem deleting warehouse requests that are still open
    // 
    // P80038689, To-Increase, Dayakar Battini, 05 MAY 17
    //  Undo shipment/settlement fail issue
    // 
    // PRW110.0.02
    // P80038970, To-Increase, Dayakar Battini, 28 NOV 17
    //    Delivery Trip changes
    // 
    // PRW110.0.03
    // P80057565, To-Increase, Dayakar Battini, 17 APR 18
    //   fix issue with incorrect Complete flag
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW115.3
    // P800125182, To Increase, Jack Reynolds, 15 JUN 21
    //    Re-releasde of sales order clears Delviery Trip No. on Whse Request

    Permissions = TableData "Warehouse Request" = rimd;

    trigger OnRun()
    begin
    end;

    var
        WhseRqst: Record "Warehouse Request";
        SalesLine: Record "Sales Line";
        Location: Record Location;
        OldLocationCode: Code[10];
        First: Boolean;
        ProcessFns: Codeunit "Process 800 Functions";
        DeliveryRouteMgt: Codeunit "Delivery Route Management";
        CalledFromPost: Boolean;
        FromDeliveryTripNo: Code[20];

    procedure Release(SalesHeader: Record "Sales Header")
    var
        WhseType: Enum "Warehouse Request Type";
        OldWhseType: Enum "Warehouse Request Type";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeRelease(SalesHeader, IsHandled);
        if IsHandled then
            exit;

        IsHandled := false;
        OnBeforeReleaseSetWhseRequestSourceDocument(SalesHeader, WhseRqst, IsHandled);
        if not IsHandled then
            case SalesHeader."Document Type" of
                "Sales Document Type"::Order:
                    WhseRqst."Source Document" := WhseRqst."Source Document"::"Sales Order";
                "Sales Document Type"::"Return Order":
                    WhseRqst."Source Document" := WhseRqst."Source Document"::"Sales Return Order";
                else
                    exit;
            end;

        SalesLine.SetCurrentKey("Document Type", "Document No.", "Location Code");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("Drop Shipment", false);
        SalesLine.SetRange("Job No.", '');
        OnAfterReleaseSetFilters(SalesLine, SalesHeader);
        if SalesLine.FindSet() then begin
            First := true;
            repeat
                if ((SalesHeader."Document Type" = "Sales Document Type"::Order) and (SalesLine.Quantity >= 0)) or
                    ((SalesHeader."Document Type" = "Sales Document Type"::"Return Order") and (SalesLine.Quantity < 0))
                then
                    WhseType := WhseType::Outbound
                else
                    WhseType := WhseType::Inbound;

                OnReleaseOnBeforeCreateWhseRequest(SalesLine, OldWhseType, WhseType, First);

                if First or (SalesLine."Location Code" <> OldLocationCode) or (WhseType <> OldWhseType) then
                    CreateWarehouseRequest(SalesHeader, SalesLine, WhseType, WhseRqst);

                OnAfterReleaseOnAfterCreateWhseRequest(
                    SalesHeader, SalesLine, WhseType.AsInteger(), First, OldWhseType.AsInteger(), OldLocationCode);

                First := false;
                OldLocationCode := SalesLine."Location Code";
                OldWhseType := WhseType;
            until SalesLine.Next() = 0;
        end;

        OnReleaseOnAfterCreateWhseRequest(SalesHeader, SalesLine);

        WhseRqst.Reset();
        WhseRqst.SetCurrentKey("Source Type", "Source Subtype", "Source No.");
        // WhseRqst.SetRange(Type, WhseRqst.Type); // P8008713
        WhseRqst.SetSourceFilter(DATABASE::"Sales Line", SalesHeader."Document Type".AsInteger(), SalesHeader."No.");
        WhseRqst.SetRange("Document Status", SalesHeader.Status::Open);
        if not WhseRqst.IsEmpty() then
            WhseRqst.DeleteAll(true);

        OnAfterRelease(SalesHeader);
    end;

    procedure Reopen(SalesHeader: Record "Sales Header")
    var
        WhseRqst: Record "Warehouse Request";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeReopen(SalesHeader, IsHandled);
        if IsHandled then
            exit;

        with SalesHeader do begin
            IsHandled := false;
            OnBeforeReopenSetWhseRequestSourceDocument(SalesHeader, WhseRqst, IsHandled);

            WhseRqst.Reset();
            WhseRqst.SetCurrentKey("Source Type", "Source Subtype", "Source No.");
            if IsHandled then
                WhseRqst.SetRange(Type, WhseRqst.Type);
            WhseRqst.SetSourceFilter(DATABASE::"Sales Line", "Document Type".AsInteger(), "No.");
            WhseRqst.SetRange("Document Status", Status::Released);
            if not WhseRqst.IsEmpty() then
                WhseRqst.ModifyAll("Document Status", WhseRqst."Document Status"::Open);
        end;

        OnAfterReopen(SalesHeader);
    end;

    [Scope('OnPrem')]
    procedure UpdateExternalDocNoForReleasedOrder(SalesHeader: Record "Sales Header")
    begin
        with SalesHeader do begin
            WhseRqst.Reset();
            WhseRqst.SetCurrentKey("Source Type", "Source Subtype", "Source No.");
            WhseRqst.SetSourceFilter(DATABASE::"Sales Line", "Document Type".AsInteger(), "No.");
            WhseRqst.SetRange("Document Status", Status::Released);
            if not WhseRqst.IsEmpty() then
                WhseRqst.ModifyAll("External Document No.", "External Document No.");
        end;
    end;

    procedure CreateWarehouseRequest(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; WhseType: Enum "Warehouse Request Type"; var WarehouseRequest: Record "Warehouse Request")
    var
        SalesLine2: Record "Sales Line";
        DeliveryTrip: Record "N138 Delivery Trip";
        DeliveryTripMgt: Codeunit "N138 Delivery Trip Mgt.";
        WarehouseRequest2: Record "Warehouse Request";
        xWWarehouseRequesthseRqst: Record "Warehouse Request";
    begin
        // if ShouldCreateWarehouseRequest(WhseType) then begin // P8000282A

        if SalesLine."Location Code" <> '' then begin // P8000723
            SalesLine2.Copy(SalesLine);
            SalesLine2.SetRange("Location Code", SalesLine."Location Code");
            SalesLine2.SetRange("Unit of Measure Code", '');
            if SalesLine2.FindFirst() then
                SalesLine2.TestField("Unit of Measure Code");

            WarehouseRequest.Type := WhseType;
            WarehouseRequest."Location Code" := SalesLine."Location Code"; // P800125182
            WarehouseRequest."Source Type" := DATABASE::"Sales Line";
            WarehouseRequest."Source Subtype" := SalesHeader."Document Type".AsInteger();
            WarehouseRequest."Source No." := SalesHeader."No.";
            // P800125182
            if WhseRqst.Find() then
                if WhseRqst."Delivery Trip" <> '' then
                    if (WhseRqst."Delivery Route No." <> SalesHeader."Delivery Route No.") or
                       (WhseRqst."Shipment Date" <> SalesHeader."Shipment Date")
                    then
                        WhseRqst."Delivery Trip" := '';
            // P800125182
            WarehouseRequest."Shipment Method Code" := SalesHeader."Shipment Method Code";
            WarehouseRequest."Shipping Agent Code" := SalesHeader."Shipping Agent Code";
            WarehouseRequest."Shipping Agent Service Code" := SalesHeader."Shipping Agent Service Code";
            WarehouseRequest."Shipping Advice" := SalesHeader."Shipping Advice";
            WarehouseRequest."Document Status" := SalesHeader.Status::Released.AsInteger();
            WarehouseRequest."Location Code" := SalesLine."Location Code";
            // WarehouseRequest."Location Code" := SalesLine."Location Code"; // P800125182
            WarehouseRequest."Destination Type" := WarehouseRequest."Destination Type"::Customer;
            WarehouseRequest."Destination No." := SalesHeader."Sell-to Customer No.";
            WarehouseRequest."External Document No." := SalesHeader."External Document No.";
            if WhseType = WhseType::Inbound then
                WarehouseRequest."Expected Receipt Date" := SalesHeader."Shipment Date"
            else
                WarehouseRequest."Shipment Date" := SalesHeader."Shipment Date";
            SalesHeader.SetRange("Location Filter", SalesLine."Location Code");
            SalesHeader.CalcFields("Completely Shipped");
            WarehouseRequest."Completely Handled" := SalesHeader."Completely Shipped";
            WarehouseRequest."Delivery Route No." := SalesHeader."Delivery Route No."; // P8004269
            WarehouseRequest."Delivery Stop No." := SalesHeader."Delivery Stop No.";   // P8004269

            // P8008706
            //  IF NOT WarehouseRequest.INSERT THEN
            //    WarehouseRequest.MODIFY;
            // P8008706
            if (not CalledFromPost) and ProcessFns.DistPlanningInstalled then begin

                // P8007168
                if FromDeliveryTripNo <> '' then begin
                    WarehouseRequest."Delivery Trip" := FromDeliveryTripNo;
                    DeliveryRouteMgt.SetQtyWeightVolume(WarehouseRequest);  // P80057565
                end else begin
                    // P8007168
                    DeliveryRouteMgt.CreateDeliveryTrip(WarehouseRequest);
                    DeliveryRouteMgt.SetQtyWeightVolume(WarehouseRequest);
                    if WarehouseRequest."Delivery Trip" <> '' then begin
                        if DeliveryTrip.Get(WarehouseRequest."Delivery Trip") then begin            // P80038689
                            WarehouseRequest2 := WarehouseRequest;                                  // TOM4222
                            WarehouseRequest2.SetRecFilter;                                         // TOM4222
                            DeliveryTrip.AddSourceDocToWarehouseShipment(WarehouseRequest2, false); // TOM4222
                        end;  // P80038689
                    end;
                end;   // P8007168
            end;
            // TOM4220

            // P8008706
            OnBeforeCreateWhseRequest(WhseRqst, SalesHeader, SalesLine, WhseType.AsInteger());
            if not WarehouseRequest.Insert() then
                WarehouseRequest.Modify();
            OnAfterCreateWhseRequest(WhseRqst, SalesHeader, SalesLine, WhseType.AsInteger());
        end;

    end;

    local procedure ShouldCreateWarehouseRequest(WhseType: Enum "Warehouse Request Type") ShouldCreate: Boolean;
    begin
        ShouldCreate :=
           ((WhseType = "Warehouse Request Type"::Outbound) and
            (Location.RequireShipment(SalesLine."Location Code") or
             Location.RequirePicking(SalesLine."Location Code"))) or
           ((WhseType = "Warehouse Request Type"::Inbound) and
            (Location.RequireReceive(SalesLine."Location Code") or
             Location.RequirePutaway(SalesLine."Location Code")));

        OnAfterShouldCreateWarehouseRequest(Location, ShouldCreate);
    end;

    procedure SetCalledFromPost()
    begin
        // P8000549A
        CalledFromPost := true;
    end;

    procedure SetSettlementPosting(DeliveryTripNo: Code[20])
    begin
        // P8007168
        FromDeliveryTripNo := DeliveryTripNo;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateWhseRequest(var WhseRqst: Record "Warehouse Request"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; WhseType: Option Inbound,Outbound)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateWhseRequest(var WhseRqst: Record "Warehouse Request"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; WhseType: Option Inbound,Outbound)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRelease(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReleaseSetFilters(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReleaseOnAfterCreateWhseRequest(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; WhseType: Option; First: Boolean; OldWhseType: Option; OldLocationCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReopen(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShouldCreateWarehouseRequest(Location: Record Location; var ShouldCreate: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRelease(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReleaseSetWhseRequestSourceDocument(var SalesHeader: Record "Sales Header"; var WarehouseRequest: Record "Warehouse Request"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReopen(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReopenSetWhseRequestSourceDocument(var SalesHeader: Record "Sales Header"; var WarehouseRequest: Record "Warehouse Request"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReleaseOnBeforeCreateWhseRequest(var SalesLine: Record "Sales Line"; OldWhseType: Enum "Warehouse Request Type"; WhseType: Enum "Warehouse Request Type"; var First: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReleaseOnAfterCreateWhseRequest(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;
}

