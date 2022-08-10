codeunit 5772 "Whse.-Purch. Release"
{
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
    // PRW18.00.02
    // P8004220, To-Increase, Jack Reynolds, 05 OCT 15
    //   Auto create warehouse shipment when creating delivery trip
    // 
    // P8004269, To-Increase, Jack Reynolds, 07 OCT 15
    //   Update source document Delivery Route No.
    // 
    // P8004222, To-Increase, Jack Reynolds, 08 OCT 15
    //   Support for adding warehouse request to warehouse shipment
    // 
    // P8004554, To-Increase, Jack Reynolds, 27 OCT 15
    //   Synchronize Delivery Stop No.
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // P8007609, To-Increase, Dayakar Battini, 08 SEP 16
    //  Exclude nothing to ship documents
    // 
    // PRW110.0.01
    // P8008713, To-Increase, Jack Reynolds, 04 MAY 17
    //   Fix problem deleting warehouse requests that are still open
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Permissions = TableData "Warehouse Request" = rimd;

    trigger OnRun()
    begin
    end;

    var
        WhseRqst: Record "Warehouse Request";
        PurchLine: Record "Purchase Line";
        Location: Record Location;
        OldLocationCode: Code[10];
        First: Boolean;
        ProcessFns: Codeunit "Process 800 Functions";
        DeliveryRouteMgt: Codeunit "Delivery Route Management";
        CalledFromPost: Boolean;

    procedure Release(PurchHeader: Record "Purchase Header")
    var
        WhseType: Enum "Warehouse Request Type";
        OldWhseType: Enum "Warehouse Request Type";
    begin
        OnBeforeRelease(PurchHeader);

        case PurchHeader."Document Type" of
            PurchHeader."Document Type"::Order:
                WhseRqst."Source Document" := WhseRqst."Source Document"::"Purchase Order";
            PurchHeader."Document Type"::"Return Order":
                WhseRqst."Source Document" := WhseRqst."Source Document"::"Purchase Return Order";
            else
                exit;
        end;

        PurchLine.SetCurrentKey("Document Type", "Document No.", "Location Code");
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        PurchLine.SetRange("Drop Shipment", false);
        PurchLine.SetRange("Job No.", '');
        PurchLine.SetRange("Work Center No.", '');
        OnAfterReleaseSetFilters(PurchLine, PurchHeader);
        if PurchLine.FindSet() then begin
            First := true;
            repeat
                if ((PurchHeader."Document Type" = "Purchase Document Type"::Order) and (PurchLine.Quantity >= 0)) or
                    ((PurchHeader."Document Type" = "Purchase Document Type"::"Return Order") and (PurchLine.Quantity < 0))
                then
                    WhseType := WhseType::Inbound
                else
                    WhseType := WhseType::Outbound;
                if First or (PurchLine."Location Code" <> OldLocationCode) or (WhseType <> OldWhseType) then
                    CreateWarehouseRequest(PurchHeader, PurchLine, WhseType);

                OnReleaseOnAfterCreateWhseRequest(PurchHeader, PurchLine, WhseType.AsInteger());

                First := false;
                OldLocationCode := PurchLine."Location Code";
                OldWhseType := WhseType;
            until PurchLine.Next() = 0;
        end;

        FilterWarehouseRequest(WhseRqst, PurchHeader, WhseRqst."Document Status"::Open);
        WhseRqst.SetRange(Type); // P8008713
        if not WhseRqst.IsEmpty() then
            WhseRqst.DeleteAll(true);

        OnAfterRelease(PurchHeader);
    end;

    procedure Reopen(PurchHeader: Record "Purchase Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeReopen(PurchHeader, WhseRqst, IsHandled);
        if IsHandled then
            exit;

        FilterWarehouseRequest(WhseRqst, PurchHeader, WhseRqst."Document Status"::Released);
        if not WhseRqst.IsEmpty() then
            WhseRqst.ModifyAll("Document Status", WhseRqst."Document Status"::Open);

        OnAfterReopen(PurchHeader);
    end;

    [Scope('OnPrem')]
    procedure UpdateExternalDocNoForReleasedOrder(PurchHeader: Record "Purchase Header")
    begin
        FilterWarehouseRequest(WhseRqst, PurchHeader, WhseRqst."Document Status"::Released);
        if not WhseRqst.IsEmpty() then
            WhseRqst.ModifyAll("External Document No.", PurchHeader."Vendor Shipment No.");
    end;

    procedure CreateWarehouseRequest(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; WhseType: Enum "Warehouse Request Type")
    var
        PurchLine2: Record "Purchase Line";
        DeliveryTrip: Record "N138 Delivery Trip";
        xWhseRqst: Record "Warehouse Request";
        WhseRqst2: Record "Warehouse Request";
    begin
        /*P8000282A
        IF ((WhseType = WhseType::Outbound) AND
            (Location.RequireShipment(PurchLine."Location Code") OR
             Location.RequirePicking(PurchLine."Location Code"))) OR
           ((WhseType = WhseType::Inbound) AND
            (Location.RequireReceive(PurchLine."Location Code") OR
             Location.RequirePutaway(PurchLine."Location Code")))
        THEN BEGIN
        P8000282A*/
        if PurchLine."Location Code" <> '' then begin // P8000723
            PurchLine2.Copy(PurchLine);
            PurchLine2.SetRange("Location Code", PurchLine."Location Code");
            PurchLine2.SetRange("Unit of Measure Code", '');
            if PurchLine2.FindFirst() then
                PurchLine2.TestField("Unit of Measure Code");

            WhseRqst.Type := WhseType;
            WhseRqst."Source Type" := DATABASE::"Purchase Line";
            WhseRqst."Source Subtype" := PurchHeader."Document Type".AsInteger();
            WhseRqst."Source No." := PurchHeader."No.";
            WhseRqst."Shipment Method Code" := PurchHeader."Shipment Method Code";
            WhseRqst."Document Status" := PurchHeader.Status::Released.AsInteger();
            WhseRqst."Location Code" := PurchLine."Location Code";
            WhseRqst."Destination Type" := WhseRqst."Destination Type"::Vendor;
            WhseRqst."Destination No." := PurchHeader."Buy-from Vendor No.";
            WhseRqst."External Document No." := PurchHeader."Vendor Shipment No.";
            if WhseType = WhseType::Inbound then
                WhseRqst."Expected Receipt Date" := PurchHeader."Expected Receipt Date"
            else
                WhseRqst."Shipment Date" := PurchHeader."Expected Receipt Date";
            PurchHeader.SetRange("Location Filter", PurchLine."Location Code");
            PurchHeader.CalcFields("Completely Received");
            WhseRqst."Completely Handled" := PurchHeader."Completely Received";
            WhseRqst."Delivery Route No." := PurchHeader."Delivery Route No."; // P8004269
            WhseRqst."Delivery Stop No." := PurchHeader."Delivery Stop No.";   // P8004554

            OnBeforeCreateWhseRequest(WhseRqst, PurchHeader, PurchLine, WhseType.AsInteger());
            if not WhseRqst.Insert() then // P8004220
                WhseRqst.Modify();          // P8004220

            // P8001379
            if (not CalledFromPost) and ProcessFns.DistPlanningInstalled then begin
                DeliveryRouteMgt.CreateDeliveryTrip(WhseRqst);
                DeliveryRouteMgt.SetQtyWeightVolume(WhseRqst);
                // P8004220
                if WhseRqst."Delivery Trip" <> '' then begin
                    DeliveryTrip.Get(WhseRqst."Delivery Trip");
                    WhseRqst2 := WhseRqst;                                         // P8004222
                    WhseRqst2.SetRecFilter;                                        // P8004222
                    DeliveryTrip.AddSourceDocToWarehouseShipment(WhseRqst2, false); // P8004222
                end;
                WhseRqst.Modify;
                // P8004220
            end;
            OnAfterCreateWhseRqst(WhseRqst, PurchHeader, PurchLine, WhseType.AsInteger());
        end;

    end;

    local procedure FilterWarehouseRequest(var WarehouseRequest: Record "Warehouse Request"; PurchaseHeader: Record "Purchase Header"; DocumentStatus: Option)
    begin
        WarehouseRequest.Reset;
        WarehouseRequest.SetCurrentKey("Source Type", "Source Subtype", "Source No.");
        WarehouseRequest.SetRange("Source Type", DATABASE::"Purchase Line");
        WarehouseRequest.SetRange("Source Subtype", PurchaseHeader."Document Type");
        WarehouseRequest.SetRange("Source No.", PurchaseHeader."No.");
        WarehouseRequest.SetRange("Document Status", DocumentStatus);

        OnAfterFilterWarehouseRequest(WarehouseRequest, PurchaseHeader, DocumentStatus);
    end;

    procedure SetCalledFromPost()
    begin
        // P8000549A
        CalledFromPost := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateWhseRqst(var WhseRqst: Record "Warehouse Request"; var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; WhseType: Option Inbound,Outbound)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFilterWarehouseRequest(var WarehouseRequest: Record "Warehouse Request"; PurchaseHeader: Record "Purchase Header"; DocumentStatus: Option)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateWhseRequest(var WhseRqst: Record "Warehouse Request"; var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; WhseType: Option Inbound,Outbound)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRelease(var PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReleaseSetFilters(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReopen(var PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRelease(var PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReopen(var PurchaseHeader: Record "Purchase Header"; var WhseRqst: Record "Warehouse Request"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReleaseOnAfterCreateWhseRequest(PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; WhseType: Option Inbound,Outbound)
    begin
    end;
}

