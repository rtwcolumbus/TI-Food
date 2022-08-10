codeunit 37002062 "N138 Delivery Trip Mgt."
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 02-02-2015, Initial Version
    // --------------------------------------------------------------------------------
    // TOM4224   , 02-10-2015, Post and Print; Shipment posting only
    // --------------------------------------------------------------------------------
    // TOM4220     05-10-2015  Auto creation of warehouse shipment with delivery trip
    // --------------------------------------------------------------------------------
    // TOM4269     06-10-2015  Update source document shipping fields
    // --------------------------------------------------------------------------------
    // 
    // PRW18.00.02
    // P8004269, To-Increase, Jack Reynolds, 07 OCT 15
    //   Update source document Delivery Route No.
    // 
    // PRW19.00.01
    // P8006916, To-Increase, Dayakar Battini, 16 JUN 16
    //   FOOD-TOM Separation delete Transsmart objects
    // 
    // PRW110.0.01
    // P8008706, To-Increase, Dayakar Battini, 28 APR 17
    //  Delivery Trip link missing issue
    // 
    // P80037380, To-Increase, Dayakar Battini, 31 MAY 17
    //  Updating whse. shipment dates with departure date
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // P80050542, To-Increase, Dayakar Battini, 21 MAR 18
    //   Loading dock visibility while selecting the loading dock
    // 
    // PRW111.00.02
    // P80075865, To-Increase, Gangabhushan, 13 Jun 19
    //   CS00062204 - Delivery Trips will allow "posting" without anything to post, which will orphan the order
    // 
    // PRW111.00.03
    // P80083600, To-Increase, Gangabhushan, 16 OCT 19
    //   Delivery trip lines get deleted after partial shipment.


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Not all containers are linked to a Transport Order';
        Text001: Label 'Do you want to post the shipment?';
        Text002: Label 'Loading Dock %1 is already linked to Delivery Trip %2';
        Text003: Label 'Not all containers are loaded';
        TransportMgtSetup: Record "N138 Transport Mgt. Setup";
        Text37002000: Label 'Not all orders are complete.';

    procedure Reopen(var DeliveryTrip: Record "N138 Delivery Trip"; Manual: Boolean)
    begin
        DeliveryTrip.Status := DeliveryTrip.Status::Open;
        DeliveryTrip.Modify(true);
    end;

    procedure Loading(var DeliveryTrip: Record "N138 Delivery Trip"; Manual: Boolean)
    var
        LoadingAt: Code[20];
    begin
        DeliveryTrip.TestField("Loading Dock");

        // P80050542
        LoadingAt := LoadingAtDeliveryTrip(DeliveryTrip);
        if LoadingAt <> '' then
            Error(Text002, DeliveryTrip."Loading Dock", LoadingAt);
        // P80050542

        DeliveryTrip.Status := DeliveryTrip.Status::Loading;
        DeliveryTrip.Modify(true);
    end;

    procedure Shipped(var DeliveryTrip: Record "N138 Delivery Trip"; Manual: Boolean)
    var
        FoodDeliveryTripManagement: Codeunit "Food Delivery Trip Management";
        Total: Integer;
        IncompleteOrders: Integer;
        UnloadedContainers: Integer;
    begin
        // P8001379
        FoodDeliveryTripManagement.DeliveryTripSourceDocumentCount(DeliveryTrip."No.", 0, 0, '', Total, IncompleteOrders);
        if 0 < IncompleteOrders then
            Error(Text37002000);
        // P8001379

        TransportMgtSetup.Get;
        if TransportMgtSetup."Use Container Status Loaded" then begin
            // P8001379
            //  Container.SETRANGE("Delivery Trip",DeliveryTrip."No.");
            //  Container.SETFILTER(Status,'<>%1',Container.Status::Loaded);
            //  IF NOT Container.ISEMPTY THEN
            //    ERROR(Text003);
            FoodDeliveryTripManagement.DeliveryTripContainerCount(DeliveryTrip."No.", 0, 0, '', Total, UnloadedContainers);
            if 0 < UnloadedContainers then
                Error(Text003);
            // P8001379
        end;

        DeliveryTrip.Status := DeliveryTrip.Status::Shipped;
        DeliveryTrip.Modify(true);
    end;

    procedure PostDeliveryTrip(var DeliveryTrip: Record "N138 Delivery Trip"; Print: Boolean; ConfirmYN: Boolean)
    var
        DeliveryTripHistory: Record "N138 Delivery Trip History";
        WhseShipmentHdr: Record "Warehouse Shipment Header";
        WhseShipLine: Record "Warehouse Shipment Line";
        WhsePostShipment: Codeunit "Whse.-Post Shipment";
        Txt0001: Label 'All the Source Documents are not complete for Delivery Trip %1';
    begin
        // P80075865
        if not CheckCompleteForAllDocLines(DeliveryTrip."No.") then
            Error(Txt0001, DeliveryTrip."No.");
        // P80075865
        WhseShipmentHdr.SetRange("Delivery Trip", DeliveryTrip."No.");
        if WhseShipmentHdr.FindSet then begin
            if ConfirmYN then
                if not Confirm(Text001, false) then
                    exit;

            WhsePostShipment.SetPostingSettings(false);
            WhsePostShipment.SetPrint(Print);
            WhsePostShipment.CallFromDeliveryTrip(true); // P80083600

            repeat
                WhseShipLine.SetRange("No.", WhseShipmentHdr."No.");
                if WhseShipLine.FindFirst then
                    WhsePostShipment.Run(WhseShipLine);
                if WhseShipmentHdr.Find then begin
                    WhseShipmentHdr."Delivery Trip" := '';
                    WhseShipmentHdr.Modify;
                end;
            until WhseShipmentHdr.Next = 0;
        end;

        DeliveryTripHistory.TransferFields(DeliveryTrip);
        DeliveryTripHistory.Insert(true);

        TransferCost2PostedCost(DeliveryTrip, DeliveryTripHistory);

        DeliveryTrip.Delete;
    end;

    procedure OpenLinkedPicks(DeliveryTrip: Record "N138 Delivery Trip")
    var
        WhseShipmentHdr: Record "Warehouse Shipment Header";
        WhseActLine: Record "Warehouse Activity Line";
        TempWhseActLine: Record "Warehouse Activity Line" temporary;
        WhseActList: Page "Warehouse Activity List";
    begin
        WhseShipmentHdr.SetRange("Delivery Trip", DeliveryTrip."No.");
        if WhseShipmentHdr.FindSet then
            repeat
                WhseActLine.SetRange("Activity Type", WhseActLine."Activity Type"::Pick);
                WhseActLine.SetRange("Whse. Document Type", WhseActLine."Whse. Document Type"::Shipment);
                WhseActLine.SetRange("Whse. Document No.", WhseShipmentHdr."No.");
                if WhseActLine.FindSet then
                    repeat
                        TempWhseActLine.TransferFields(WhseActLine);
                        TempWhseActLine.Insert;
                    until WhseActLine.Next = 0;
            until WhseShipmentHdr.Next = 0;

        PAGE.RunModal(PAGE::"Warehouse Activity Lines", TempWhseActLine);
    end;

    procedure OpenLinkedPicks2(WhseShipmentHdr: Record "Warehouse Shipment Header")
    var
        WhseActLine: Record "Warehouse Activity Line";
        TempWhseActLine: Record "Warehouse Activity Line" temporary;
        WhseActList: Page "Warehouse Activity List";
    begin
        WhseActLine.SetRange("Activity Type", WhseActLine."Activity Type"::Pick);
        WhseActLine.SetRange("Whse. Document Type", WhseActLine."Whse. Document Type"::Shipment);
        WhseActLine.SetRange("Whse. Document No.", WhseShipmentHdr."No.");
        if WhseActLine.FindSet then
            repeat
                TempWhseActLine.TransferFields(WhseActLine);
                TempWhseActLine.Insert;
            until WhseActLine.Next = 0;

        PAGE.RunModal(PAGE::"Warehouse Activity Lines", TempWhseActLine);
    end;

    procedure LinkDeliveryTripWhseShipment(WhseGetSourceFilterRec: Record "Warehouse Source Filter"; var WhseShptHeader: Record "Warehouse Shipment Header")
    var
        ShippingAgent: Record "Shipping Agent";
        ShippingAgentServices: Record "Shipping Agent Services";
        DeliveryTrip: Record "N138 Delivery Trip";
    begin
        with WhseGetSourceFilterRec do begin
            if "Create Delivery Trip" then begin
                ShippingAgent.SetFilter(Code, "Shipping Agent Code Filter");
                ShippingAgent.FindFirst;
                ShippingAgentServices.SetRange("Shipping Agent Code", ShippingAgent.Code);
                ShippingAgentServices.SetFilter(Code, "Shipping Agent Service Filter");
                ShippingAgentServices.FindFirst;

                if WhseShptHeader."Delivery Trip" = '' then begin
                    DeliveryTrip.Init;
                    DeliveryTrip."Location Code" := WhseShptHeader."Location Code";
                    DeliveryTrip."Shipping Agent Code" := ShippingAgent.Code;
                    DeliveryTrip."Shipping Agent Service Code" := ShippingAgentServices.Code;
                    DeliveryTrip.Description := ShippingAgentServices.Description;
                    DeliveryTrip.Insert(true);

                    WhseShptHeader.Validate("Delivery Trip", DeliveryTrip."No.");  // P8008706
                    WhseShptHeader.Modify;
                end else begin
                    //Update Delivery Trip with Shipping Agent filters
                    DeliveryTrip.Get(WhseShptHeader."Delivery Trip");
                    DeliveryTrip."Location Code" := WhseShptHeader."Location Code";
                    DeliveryTrip."Shipping Agent Code" := ShippingAgent.Code;
                    DeliveryTrip."Shipping Agent Service Code" := ShippingAgentServices.Code;
                    DeliveryTrip.Description := ShippingAgentServices.Description;
                    DeliveryTrip.Modify(true);
                end;
            end;
        end;
    end;

    procedure LinkDeliveryTripWhseShipment2(DeliveryTrip: Record "N138 Delivery Trip")
    var
        WhseShipmentHdr: Record "Warehouse Shipment Header";
        WarehouseShipmentList: Page "Warehouse Shipment List";
    begin
        WhseShipmentHdr.SetFilter("Delivery Trip", '%1', '');
        WarehouseShipmentList.SetTableView(WhseShipmentHdr);
        WarehouseShipmentList.LookupMode := true;
        if WarehouseShipmentList.RunModal = ACTION::LookupOK then begin
            WarehouseShipmentList.GetRecord(WhseShipmentHdr);
            WhseShipmentHdr.Validate("Delivery Trip", DeliveryTrip."No.");   // P8008706
            WhseShipmentHdr.Modify(true);
        end;
    end;

    local procedure TransferCost2PostedCost(DeliveryTrip: Record "N138 Delivery Trip"; DeliveryTripHistory: Record "N138 Delivery Trip History")
    var
        TransportCost: Record "N138 Transport Cost";
        PostedTransportCost: Record "N138 Posted Transport Cost";
    begin
        CheckTransportCost(DeliveryTrip);

        TransportCost.Reset;
        TransportCost.SetRange("Source Type", DATABASE::"N138 Delivery Trip");
        TransportCost.SetRange("No.", DeliveryTrip."No.");
        if TransportCost.FindSet then
            repeat
                PostedTransportCost.Init;
                PostedTransportCost.TransferFields(TransportCost);
                PostedTransportCost."Source Type" := DATABASE::"N138 Delivery Trip History";
                PostedTransportCost."Posted No." := DeliveryTripHistory."No.";
                PostedTransportCost."No." := DeliveryTrip."No.";
                PostedTransportCost.Insert;
            until TransportCost.Next = 0;
        TransportCost.DeleteAll;
    end;

    procedure CheckTransportCost(DeliveryTrip: Record "N138 Delivery Trip")
    var
        TransportCost: Record "N138 Transport Cost";
        TransportMgtSetup: Record "N138 Transport Mgt. Setup";
        N138Text001: Label 'Transport Costs are not available.';
        N138Text002: Label 'Transport Costs are not available. Do you want to release the delivery trip?';
    begin
        TransportMgtSetup.Get;
        TransportCost.Reset;
        TransportCost.SetRange("Source Type", DATABASE::"N138 Delivery Trip");
        TransportCost.SetRange(Subtype, 0);
        TransportCost.SetRange("No.", DeliveryTrip."No.");
        if TransportCost.Count = 0 then
            if (TransportMgtSetup."Cost Warning" =
                TransportMgtSetup."Cost Warning"::Error) then
                Error(N138Text001)
            else
                if (TransportMgtSetup."Cost Warning" =
                    TransportMgtSetup."Cost Warning"::Warning) then
                    if not Confirm(N138Text002) then
                        Error('');

        TransportCost.SetRange(Type, TransportCost.Type::"Cost Component Template");
        if TransportCost.FindSet then
            repeat
                TransportCost.gFncUpdateAmount;
                TransportCost.Modify(true);
                TransportCost.TestField(Amount);
            until TransportCost.Next = 0;
    end;

    procedure CreateDeliveryTrip(var WhseReq: Record "Warehouse Request"): Code[20]
    var
        DeliveryTrip: Record "N138 Delivery Trip";
        ShippingAgentServices: Record "Shipping Agent Services";
        xWhseRqst: Record "Warehouse Request";
        TMSetup: Record "N138 Transport Mgt. Setup";
        Location: Record Location;
    begin
        if xWhseRqst.Get(WhseReq.Type, WhseReq."Location Code", WhseReq."Source Type", WhseReq."Source Subtype", WhseReq."Source No.") then begin
            if xWhseRqst."Delivery Trip" <> '' then begin
                WhseReq."Delivery Trip" := xWhseRqst."Delivery Trip";
                exit;
            end;
        end;

        if not ShippingAgentServices.Get(WhseReq."Shipping Agent Code", WhseReq."Shipping Agent Service Code") then exit;
        if not ShippingAgentServices."Delivery Trip Route" then exit;

        DeliveryTrip.SetRange(Status, DeliveryTrip.Status::Open);
        DeliveryTrip.SetRange("Location Code", WhseReq."Location Code");
        DeliveryTrip.SetRange("Shipping Agent Code", WhseReq."Shipping Agent Code");
        DeliveryTrip.SetRange("Shipping Agent Service Code", WhseReq."Shipping Agent Service Code");
        DeliveryTrip.SetRange("Departure Date", WhseReq."Shipment Date");
        if not DeliveryTrip.FindFirst then begin
            DeliveryTrip.Init;
            DeliveryTrip.Status := DeliveryTrip.Status::Open;
            DeliveryTrip."Location Code" := WhseReq."Location Code";
            DeliveryTrip."Shipping Agent Code" := WhseReq."Shipping Agent Code";
            DeliveryTrip."Shipping Agent Service Code" := WhseReq."Shipping Agent Service Code";
            DeliveryTrip."Departure Date" := WhseReq."Shipment Date";

            DeliveryTrip.Description := ShippingAgentServices.Description;
            DeliveryTrip.Insert(true);
        end;

        WhseReq."Delivery Trip" := DeliveryTrip."No.";

        // TOM4220
        TMSetup.Get;
        if not TMSetup."Auto Create Del. Trip Shipment" then
            exit;
        Location.Get(WhseReq."Location Code");
        if not Location."Require Shipment" then
            exit;
        DeliveryTrip.CreateWarehouseShipment;
        // TOM4220
    end;

    procedure GetWhseReqSLS(SalesLine: Record "Sales Line"; var WhseRqst: Record "Warehouse Request"): Boolean
    var
        WhseType: Option Inbound,Outbound;
    begin
        with SalesLine do begin
            if (("Document Type" = "Document Type"::Order) and
                (SalesLine.Quantity >= 0)) or
               (("Document Type" = "Document Type"::"Return Order") and
                (SalesLine.Quantity < 0))
            then
                WhseType := WhseType::Outbound
            else
                WhseType := WhseType::Inbound;

            exit(WhseRqst.Get(WhseType, "Location Code", DATABASE::"Sales Line", "Document Type", "Document No."));

        end;
    end;

    procedure LookupWhseReqSls(SalesLine: Record "Sales Line")
    var
        WhseRqst: Record "Warehouse Request";
        WarehouseRequest: Page "N138 Warehouse Request";
    begin
        if not GetWhseReqSLS(SalesLine, WhseRqst) then exit;
        WhseRqst.SetRecFilter;
        WarehouseRequest.SetTableView(WhseRqst);
        WarehouseRequest.LookupMode := true;

        WarehouseRequest.RunModal;
    end;

    procedure GetWhseReqPUR(PurchLine: Record "Purchase Line"; var WhseRqst: Record "Warehouse Request"): Boolean
    var
        WhseType: Option Inbound,Outbound;
    begin
        with PurchLine do begin
            if (("Document Type" = "Document Type"::Order) and
                (Quantity >= 0)) or
               (("Document Type" = "Document Type"::"Return Order") and
                (Quantity < 0))
            then
                WhseType := WhseType::Inbound
            else
                WhseType := WhseType::Outbound;

            exit(WhseRqst.Get(WhseType, "Location Code", DATABASE::"Purchase Line", "Document Type", "Document No."));

        end;
    end;

    procedure LookupWhseReqPUR(PurchLine: Record "Purchase Line")
    var
        WhseRqst: Record "Warehouse Request";
        WarehouseRequest: Page "N138 Warehouse Request";
    begin
        if not GetWhseReqPUR(PurchLine, WhseRqst) then exit;
        WhseRqst.SetRecFilter;
        WarehouseRequest.SetTableView(WhseRqst);

        WarehouseRequest.LookupMode := true;

        WarehouseRequest.RunModal;
    end;

    procedure GetWhseReqTransfer(TransferLine: Record "Transfer Line"; var WhseRqst: Record "Warehouse Request"): Boolean
    var
        WhseType: Option Inbound,Outbound;
    begin
        with TransferLine do begin
            WhseType := WhseType::Outbound;

            exit(WhseRqst.Get(WhseType, TransferLine."Transfer-from Code", DATABASE::"Transfer Line", 0, "Document No."));

        end;
    end;

    procedure LookupWhseReqTransfer(TransferLine: Record "Transfer Line")
    var
        WhseRqst: Record "Warehouse Request";
        WarehouseRequest: Page "N138 Warehouse Request";
    begin
        if not GetWhseReqTransfer(TransferLine, WhseRqst) then exit;
        WhseRqst.SetRecFilter;
        WarehouseRequest.SetTableView(WhseRqst);

        WarehouseRequest.LookupMode := true;

        WarehouseRequest.RunModal;
    end;

    procedure CreateWhseShipFromWhseReq(var WarehouseRequest: Record "Warehouse Request")
    var
        GetSourceDocuments: Report "Get Source Documents";
    begin
        GetSourceDocuments.SetTableView(WarehouseRequest);
        GetSourceDocuments.RunModal;
    end;

    procedure CalculateLinkedShipmentWeight(DeliveryTrip: Record "N138 Delivery Trip") Weight: Decimal
    var
        WhseShptHeader: Record "Warehouse Shipment Header";
    begin
        WhseShptHeader.SetRange("Delivery Trip", DeliveryTrip."No.");
        if WhseShptHeader.FindSet then
            repeat
                Weight += CalculateShipmentHdrWeight(WhseShptHeader);
            until WhseShptHeader.Next = 0;
    end;

    local procedure CalculateShipmentHdrWeight(WhseShptHeader: Record "Warehouse Shipment Header") Weight: Decimal
    var
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        WhseShptLine.SetRange("No.", WhseShptHeader."No.");

        if WhseShptLine.FindSet then
            repeat
                Weight += CalculateShipmentLineWeight(WhseShptLine);
            until WhseShptLine.Next = 0;
    end;

    procedure CalculateShipmentLineWeight(WhseShptLine: Record "Warehouse Shipment Line") Weight: Decimal
    var
        Item: Record Item;
    begin
        Item.Get(WhseShptLine."Item No.");
        if Item."Gross Weight" <> 0 then
            Weight += Item."Gross Weight" * WhseShptLine.Quantity
        else
            Weight += Item."Net Weight" * WhseShptLine.Quantity;
    end;

    procedure CalcWeight(DeliveryTrip: Record "N138 Delivery Trip") Return: Decimal
    var
        WarehouseRequest: Record "Warehouse Request";
        SalesLine: Record "Sales Line";
        TOMSetup: Record "N138 Transport Mgt. Setup";
        WhseValidateSourceLine: Codeunit "Whse. Validate Source Line";
    begin
        WarehouseRequest.SetRange("Delivery Trip", DeliveryTrip."No.");

        if WarehouseRequest.FindSet then
            repeat
                case WarehouseRequest."Source Type" of
                    DATABASE::"Sales Line":
                        begin
                            SalesLine.SetRange("Document Type", WarehouseRequest."Source Subtype");
                            SalesLine.SetRange("Document No.", WarehouseRequest."Source No.");
                            SalesLine.SetRange("Location Code", WarehouseRequest."Location Code");
                            if SalesLine.FindSet then
                                repeat
                                    if not WhseValidateSourceLine.WhseLinesExist(
                                             DATABASE::"Sales Line",
                                             SalesLine."Document Type",
                                             SalesLine."Document No.",
                                             SalesLine."Line No.",
                                             0,
                                             SalesLine.Quantity) then
                                        if SalesLine."Gross Weight" <> 0 then
                                            Return += SalesLine."Gross Weight" * SalesLine.Quantity
                                        else
                                            Return += SalesLine."Net Weight" * SalesLine.Quantity;
                                until SalesLine.Next = 0;
                        end;
                end;
            //TODO
            until WarehouseRequest.Next = 0;
    end;

    local procedure ChangeSalesLineQty(SalesLine: Record "Sales Line")
    var
        CurrSalesHeader: Record "Sales Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        WhseValidateSourceLine: Codeunit "Whse. Validate Source Line";
        SkipQtyCheck: Boolean;
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        with SalesLine do begin
            CurrSalesHeader.Get("Document Type", "Document No.");
            if CurrSalesHeader.Status <> CurrSalesHeader.Status::Open then
                ReleaseSalesDoc.PerformManualReopen(CurrSalesHeader);
            Validate(Quantity, 5);
            Modify(true);
            ReleaseSalesDoc.PerformManualRelease(CurrSalesHeader);

            if WhseValidateSourceLine.WhseLinesExist(
              DATABASE::"Sales Line",
              "Document Type",
               "Document No.",
               "Line No.",
               0,
               Quantity) then begin
                WhseValidateSourceLine.N138GetWhseShipmentLine(SkipQtyCheck, WhseShptLine);
                if SkipQtyCheck then begin
                    WhseShptLine.Validate(Quantity, 5);
                    WhseShptLine.Modify(true);
                end;
            end
        end;
    end;

    procedure UpdateSourceDocument(xWarehouseRequest: Record "Warehouse Request"; WarehouseRequest: Record "Warehouse Request")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        TransferRoute: Record "Transfer Route";
        UpdateHeader: Boolean;
    begin
        // TOM4269
        case WarehouseRequest."Source Type" of
            DATABASE::"Sales Line":
                begin
                    SalesLine.SetRange("Document Type", WarehouseRequest."Source Subtype");
                    SalesLine.SetRange("Document No.", WarehouseRequest."Source No.");
                    if SalesLine.FindSet(true) then begin
                        UpdateHeader := true;
                        repeat
                            if SalesLine."Location Code" = WarehouseRequest."Location Code" then begin
                                SalesLine.SuspendStatusCheck(true);
                                SalesLine."Delivery Route No." := WarehouseRequest."Delivery Route No."; // P8004269
                                SalesLine.Validate("Shipment Date", WarehouseRequest."Shipment Date");
                                SalesLine.Validate("Shipping Agent Code", WarehouseRequest."Shipping Agent Code");
                                SalesLine.Validate("Shipping Agent Service Code", WarehouseRequest."Shipping Agent Service Code");
                                SalesLine.Modify;
                            end else
                                UpdateHeader := false;
                        until SalesLine.Next = 0;
                    end;
                    if UpdateHeader then begin
                        SalesHeader.Get(WarehouseRequest."Source Subtype", WarehouseRequest."Source No.");
                        SalesHeader."Delivery Route No." := WarehouseRequest."Delivery Route No."; // P8004269
                        if xWarehouseRequest."Shipment Date" = SalesHeader."Shipment Date" then
                            SalesHeader."Shipment Date" := WarehouseRequest."Shipment Date";
                        if xWarehouseRequest."Shipping Agent Code" = SalesHeader."Shipping Agent Code" then
                            SalesHeader."Shipping Agent Code" := WarehouseRequest."Shipping Agent Code";
                        if xWarehouseRequest."Shipping Agent Service Code" = SalesHeader."Shipping Agent Service Code" then
                            SalesHeader."Shipping Agent Service Code" := WarehouseRequest."Shipping Agent Service Code";
                        SalesHeader.GetShippingTime(SalesHeader.FieldNo("Shipping Agent Service Code"));
                        SalesHeader.Modify;
                    end;
                end;

            DATABASE::"Purchase Line":
                begin
                    PurchaseLine.SetRange("Document Type", WarehouseRequest."Source Subtype");
                    PurchaseLine.SetRange("Document No.", WarehouseRequest."Source No.");
                    if PurchaseLine.FindSet(true) then begin
                        UpdateHeader := true;
                        repeat
                            if PurchaseLine."Location Code" = WarehouseRequest."Location Code" then begin
                                PurchaseLine.SuspendStatusCheck(true);
                                PurchaseLine.Validate("Expected Receipt Date", WarehouseRequest."Shipment Date");
                                PurchaseLine.Modify;
                            end else
                                UpdateHeader := false;
                        until PurchaseLine.Next = 0;
                    end;
                    if UpdateHeader then begin
                        PurchaseHeader.Get(WarehouseRequest."Source Subtype", WarehouseRequest."Source No.");
                        PurchaseHeader."Delivery Route No." := WarehouseRequest."Delivery Route No."; // P8004269
                        if xWarehouseRequest."Expected Receipt Date" = PurchaseHeader."Expected Receipt Date" then
                            PurchaseHeader."Expected Receipt Date" := WarehouseRequest."Shipment Date";
                        PurchaseHeader.Modify;
                    end;
                end;

            DATABASE::"Transfer Line":
                begin
                    TransferLine.SetRange("Document No.", WarehouseRequest."Source No.");
                    if TransferLine.FindSet(true) then
                        repeat
                            TransferLine.Validate("Shipment Date", WarehouseRequest."Shipment Date");
                            TransferLine.Validate("Shipping Agent Code", WarehouseRequest."Shipping Agent Code");
                            TransferLine.Validate("Shipping Agent Service Code", WarehouseRequest."Shipping Agent Service Code");
                            TransferLine.Modify;
                        until TransferLine.Next = 0;
                    TransferHeader.Get(WarehouseRequest."Source No.");
                    TransferHeader."Delivery Route No." := WarehouseRequest."Delivery Route No."; // P8004269
                    if xWarehouseRequest."Shipment Date" = TransferHeader."Shipment Date" then
                        TransferHeader."Shipment Date" := WarehouseRequest."Shipment Date";
                    if xWarehouseRequest."Shipping Agent Code" = TransferHeader."Shipping Agent Code" then
                        TransferHeader."Shipping Agent Code" := WarehouseRequest."Shipping Agent Code";
                    if xWarehouseRequest."Shipping Agent Service Code" = TransferHeader."Shipping Agent Service Code" then
                        TransferHeader."Shipping Agent Service Code" := WarehouseRequest."Shipping Agent Service Code";
                    TransferRoute.GetShippingTime(
                      TransferHeader."Transfer-from Code", TransferHeader."Transfer-to Code",
                      TransferHeader."Shipping Agent Code", TransferHeader."Shipping Agent Service Code",
                      TransferHeader."Shipping Time");
                    TransferRoute.CalcReceiptDate(
                      TransferHeader."Shipment Date",
                      TransferHeader."Receipt Date",
                      TransferHeader."Shipping Time",
                      TransferHeader."Outbound Whse. Handling Time",
                      TransferHeader."Inbound Whse. Handling Time",
                      TransferHeader."Transfer-from Code",
                      TransferHeader."Transfer-to Code",
                      TransferHeader."Shipping Agent Code",
                      TransferHeader."Shipping Agent Service Code");
                    TransferHeader.Modify;
                end;
        end;
    end;

    procedure UpdateWhseShipment(DeliveryTrip: Record "N138 Delivery Trip")
    var
        WhseShipmentHdr: Record "Warehouse Shipment Header";
        WhseShipmentLine: Record "Warehouse Shipment Line";
    begin
        // P80037380
        WhseShipmentHdr.SetRange("Delivery Trip", DeliveryTrip."No.");
        if WhseShipmentHdr.FindFirst then begin
            WhseShipmentLine.SetRange("No.", WhseShipmentHdr."No.");
            if WhseShipmentLine.FindFirst then begin
                WhseShipmentLine."Shipment Date" := DeliveryTrip."Departure Date";
                WhseShipmentLine.Modify(true);
            end;
            WhseShipmentHdr."Posting Date" := DeliveryTrip."Departure Date";
            WhseShipmentHdr."Shipment Date" := DeliveryTrip."Departure Date";
            WhseShipmentHdr.Modify(true);
        end;
        // P80037380
    end;

    procedure LoadingAtDeliveryTrip(var DeliveryTrip: Record "N138 Delivery Trip"): Code[20]
    var
        DeliveryTrip2: Record "N138 Delivery Trip";
    begin
        // P80050542
        if DeliveryTrip."Loading Dock" = '' then
            exit;

        DeliveryTrip2.SetFilter("No.", '<>%1', DeliveryTrip."No.");
        DeliveryTrip2.SetRange(Status, DeliveryTrip2.Status::Loading);
        DeliveryTrip2.SetRange("Loading Dock", DeliveryTrip."Loading Dock");
        if DeliveryTrip2.FindFirst then
            exit(DeliveryTrip2."No.")
        // P80050542
    end;

    local procedure CheckCompleteForAllDocLines(pDeliveryTripNo: Code[20]): Boolean
    var
        WarehouseRequest: Record "Warehouse Request";
        FoodDeliveryTripMgt: Codeunit "Food Delivery Trip Management";
        TotalCnt: Integer;
        IncompleteCnt: Integer;
    begin
        // P80075865
        WarehouseRequest.SetRange("Delivery Trip", pDeliveryTripNo);
        if WarehouseRequest.FindSet then
            repeat
                FoodDeliveryTripMgt.DeliveryTripSourceDocumentCount(WarehouseRequest."Delivery Trip", WarehouseRequest."Source Type",
                                                                    WarehouseRequest."Source Subtype", WarehouseRequest."Source No.",
                                                                    TotalCnt, IncompleteCnt);
                if IncompleteCnt <> 0 then
                    exit(false)
            until WarehouseRequest.Next = 0;
        exit(true);
    end;
}

