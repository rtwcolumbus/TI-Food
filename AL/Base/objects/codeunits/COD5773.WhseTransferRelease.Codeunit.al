codeunit 5773 "Whse.-Transfer Release"
{
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Remove check so that a warehouse request is created even for non WMS locations
    // 
    // PR4.00.03
    // P8000325A, VerticalSoft, Jack Reynolds, 01 MAY 06
    //   Release - integrate SP2 modifications
    // 
    // PRW16.00.05
    // P8000954, Columbus IT, Jack Reynolds, 08 JUL 11
    //   Support for transfer orders on delivery routes and trips
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
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // PRW19.00.01
    // P8007609, To-Increase, Dayakar Battini, 08 SEP 16
    //  Exclude nothing to ship/receive documents
    // 
    // PRW110.0.01
    // P80041198, To-Increase, Jack Reynolds, 08 MAY 17
    //   General changes and refactoring for NAV 2017 CU7
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects


    trigger OnRun()
    begin
    end;

    var
        Location: Record Location;
        WhseMgt: Codeunit "Whse. Management";
        CalledFromTransferOrder: Boolean;
        ProcessFns: Codeunit "Process 800 Functions";
        DeliveryRouteMgt: Codeunit "Delivery Route Management";
        CalledFromPost: Boolean;

    procedure Release(TransHeader: Record "Transfer Header")
    var
        WhseRqst: Record "Warehouse Request";
    begin
        OnBeforeRelease(TransHeader);

        with TransHeader do begin
            InitializeWhseRequest(WhseRqst, TransHeader, Status::Released);

            //  IF Location.RequireReceive("Transfer-to Code") OR Location.RequirePutaway("Transfer-to Code") THEN      // P8000282A
            CreateInboundWhseRequest(WhseRqst, TransHeader);
            //  IF Location.RequireShipment("Transfer-from Code") OR Location.RequirePicking("Transfer-from Code") THEN // P8000282A
            CreateOutboundWhseRequest(WhseRqst, TransHeader);

            DeleteOpenWhseRequest("No.");
        end;

        OnAfterRelease(TransHeader);
    end;

    procedure Reopen(TransHeader: Record "Transfer Header")
    var
        WhseRqst: Record "Warehouse Request";
    begin
        OnBeforeReopen(TransHeader);

        with TransHeader do begin
            /*P8000282A
            if WhseRqst.Get(WhseRqst.Type::Inbound, "Transfer-to Code", DATABASE::"Transfer Line", 1, "No.") then begin
                WhseRqst."Document Status" := Status::Open;
                WhseRqst.Modify();
            end;
            P8000282A*/
            if WhseRqst.Get(WhseRqst.Type::Outbound, "Transfer-from Code", DATABASE::"Transfer Line", 0, "No.") then begin
                WhseRqst."Document Status" := Status::Open;
                WhseRqst.Modify();
            end;
        end;

        OnAfterReopen(TransHeader);

    end;

    [Scope('OnPrem')]
    procedure UpdateExternalDocNoForReleasedOrder(TransHeader: Record "Transfer Header")
    var
        WhseRqst: Record "Warehouse Request";
    begin
        with TransHeader do begin
            if WhseRqst.Get(WhseRqst.Type::Inbound, "Transfer-to Code", DATABASE::"Transfer Line", 1, "No.") then begin
                WhseRqst."External Document No." := "External Document No.";
                WhseRqst.Modify;
            end;
            if WhseRqst.Get(WhseRqst.Type::Outbound, "Transfer-from Code", DATABASE::"Transfer Line", 0, "No.") then begin
                WhseRqst."External Document No." := "External Document No.";
                WhseRqst.Modify;
            end;
        end;
    end;

    procedure InitializeWhseRequest(var WarehouseRequest: Record "Warehouse Request"; TransferHeader: Record "Transfer Header"; DocumentStatus: Option)
    begin
        with WarehouseRequest do begin
            "Source Type" := DATABASE::"Transfer Line";
            "Source No." := TransferHeader."No.";
            "Document Status" := DocumentStatus;
            "Destination Type" := "Destination Type"::Location;
            "External Document No." := TransferHeader."External Document No.";
        end;
    end;

    procedure CreateInboundWhseRequest(var WarehouseRequest: Record "Warehouse Request"; TransferHeader: Record "Transfer Header")
    begin
        with WarehouseRequest do begin
            CheckUnitOfMeasureCode(TransferHeader."No.");
            TransferHeader.SetRange("Location Filter", TransferHeader."Transfer-to Code");
            TransferHeader.CalcFields("Completely Received");

            Type := Type::Inbound;
            "Source Subtype" := 1;
            "Source Document" := WhseMgt.GetWhseRqstSourceDocument("Source Type", "Source Subtype");
            "Expected Receipt Date" := TransferHeader."Receipt Date";
            "Location Code" := TransferHeader."Transfer-to Code";
            "Completely Handled" := TransferHeader."Completely Received";
            "Shipment Method Code" := TransferHeader."Shipment Method Code";
            "Shipping Agent Code" := TransferHeader."Shipping Agent Code";
            "Shipping Agent Service Code" := TransferHeader."Shipping Agent Service Code";
            //"Destination No." := TransferHeader."Transfer-to Code"; // P8000282A, P80041198
            "Destination No." := TransferHeader."Transfer-from Code"; // P8000282A, P80041198
            OnBeforeCreateWhseRequest(WarehouseRequest, TransferHeader);
            if CalledFromTransferOrder then begin
                if Modify() then;
            end else
                if not Insert() then
                    Modify();
        end;

        OnAfterCreateInboundWhseRequest(WarehouseRequest, TransferHeader);
    end;

    procedure CreateOutboundWhseRequest(var WarehouseRequest: Record "Warehouse Request"; TransferHeader: Record "Transfer Header")
    var
        DeliveryTrip: Record "N138 Delivery Trip";
        WarehouseRequest2: Record "Warehouse Request";
    begin
        with WarehouseRequest do begin
            CheckUnitOfMeasureCode(TransferHeader."No.");
            TransferHeader.SetRange("Location Filter", TransferHeader."Transfer-from Code");
            TransferHeader.CalcFields("Completely Shipped");

            Type := Type::Outbound;
            "Source Subtype" := 0;
            "Source Document" := WhseMgt.GetWhseRqstSourceDocument("Source Type", "Source Subtype");
            "Location Code" := TransferHeader."Transfer-from Code";
            "Completely Handled" := TransferHeader."Completely Shipped";
            "Completely Handled" := IsCompletelyHandled(TransferHeader."No.", WarehouseRequest.Type); // P8007609, P80041198
            "Shipment Method Code" := TransferHeader."Shipment Method Code";
            "Shipping Agent Code" := TransferHeader."Shipping Agent Code";
            "Shipping Agent Service Code" := TransferHeader."Shipping Agent Service Code";
            "Shipping Advice" := TransferHeader."Shipping Advice";
            "Shipment Date" := TransferHeader."Shipment Date";
            //"Destination No." := TransferHeader."Transfer-from Code"; // P8000282A, P80041198
            "Destination No." := TransferHeader."Transfer-to Code";     // P8000282A, P80041198
            "Delivery Route No." := TransferHeader."Delivery Route No."; // P8004269, P80041198
            "Delivery Stop No." := TransferHeader."Delivery Stop No.";   // P8004269, P80041198
            OnBeforeCreateWhseRequest(WarehouseRequest, TransferHeader);
            if not Insert() then
                Modify();

            // P80041198
            if (not CalledFromPost) and ProcessFns.DistPlanningInstalled then begin
                DeliveryRouteMgt.CreateDeliveryTrip(WarehouseRequest);
                DeliveryRouteMgt.SetQtyWeightVolume(WarehouseRequest);
                // P8004220
                if "Delivery Trip" <> '' then begin
                    DeliveryTrip.Get("Delivery Trip");
                    WarehouseRequest2 := WarehouseRequest;                                 // P8004222
                    WarehouseRequest2.SetRecFilter;                                        // P8004222
                    DeliveryTrip.AddSourceDocToWarehouseShipment(WarehouseRequest2, false); // P8004222
                end;
                Modify;
                // P8004220
            end;
            // P80041198
        end;

        OnAfterCreateOutboundWhseRequest(WarehouseRequest, TransferHeader);
    end;

    local procedure DeleteOpenWhseRequest(TransferOrderNo: Code[20])
    var
        WarehouseRequest: Record "Warehouse Request";
    begin
        with WarehouseRequest do begin
            SetCurrentKey("Source Type", "Source No.");
            SetRange("Source Type", DATABASE::"Transfer Line");
            SetRange("Source No.", TransferOrderNo);
            SetRange("Document Status", "Document Status"::Open);
            if not IsEmpty() then
                DeleteAll(true);
        end;
    end;

    procedure SetCallFromTransferOrder(CalledFromTransferOrder2: Boolean)
    begin
        CalledFromTransferOrder := CalledFromTransferOrder2;
    end;

    local procedure CheckUnitOfMeasureCode(DocumentNo: Code[20])
    var
        TransLine: Record "Transfer Line";
    begin
        TransLine.SetRange("Document No.", DocumentNo);
        TransLine.SetRange("Unit of Measure Code", '');
        TransLine.SetFilter("Item No.", '<>%1', '');
        OnCheckUnitOfMeasureCodeOnAfterTransLineSetFilters(TransLine, DocumentNo);
        if TransLine.FindFirst() then
            TransLine.TestField("Unit of Measure Code");
    end;

    procedure SetCalledFromPost()
    begin
        // P8000954
        CalledFromPost := true;
    end;

    local procedure IsCompletelyHandled(DocumentNo: Code[20]; Type: Integer) CompletelyHandled: Boolean
    var
        TransLine: Record "Transfer Line";
        LineCompletelyHandled: Boolean;
    begin
        // P8007609
        TransLine.SetRange("Document No.", DocumentNo);
        TransLine.SetRange("Derived From Line No.", 0);
        CompletelyHandled := true;
        if TransLine.FindSet then
            repeat
                if Type = 0 then
                    LineCompletelyHandled := TransLine."Completely Received" or (TransLine."Outstanding Quantity" = 0)
                else
                    LineCompletelyHandled := TransLine."Completely Shipped" or (TransLine."Outstanding Quantity" = 0);
                CompletelyHandled := CompletelyHandled and LineCompletelyHandled;
            until (TransLine.Next = 0);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateInboundWhseRequest(var WarehouseRequest: Record "Warehouse Request"; var TransferHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateOutboundWhseRequest(var WarehouseRequest: Record "Warehouse Request"; var TransferHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateWhseRequest(var WarehouseRequest: Record "Warehouse Request"; TransferHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRelease(var TransferHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReopen(var TransferHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRelease(var TransferHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReopen(var TransferHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckUnitOfMeasureCodeOnAfterTransLineSetFilters(var TransLine: Record "Transfer Line"; DocumentNo: Code[20])
    begin
    end;
}

