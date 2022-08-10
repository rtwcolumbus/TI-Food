codeunit 37002300 "Food Delivery Trip Management"
{
    // PRW18.00.02
    // P8004554, To-Increase, Jack Reynolds, 27 OCT 15
    //   Support for delivery trip history
    // 
    // PRW19.00.01
    // P8007133, To-Increase, Dayakar Battini, 08 JUN 16
    //  Trip Settlement and Posted Documents visibility
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects


    trigger OnRun()
    begin
    end;

    var
        ProcessFns: Codeunit "Process 800 Functions";

    procedure GetWeightVolumeUOM(var WeightUOM: Code[10]; var VolumeUOM: Code[10])
    var
        TransportSetup: Record "N138 Transport Mgt. Setup";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
    begin
        // P8001379
        TransportSetup.Get;

        if TransportSetup."Delivery Trip Unit of Weight" <> '' then
            WeightUOM := TransportSetup."Delivery Trip Unit of Weight"
        else
            WeightUOM := P800UOMFns.DefaultUOM(2);

        if TransportSetup."Delivery Trip Unit of Volume" <> '' then
            VolumeUOM := TransportSetup."Delivery Trip Unit of Volume"
        else
            VolumeUOM := P800UOMFns.DefaultUOM(3);
    end;

    procedure DeliveryTripSourceDocumentCount(DeliveryTripNo: Code[20]; SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20]; var Total: Integer; var Incomplete: Integer)
    var
        DeliveryTripSourceDocCnt: Query "Delivery Trip Source Doc. Cnt.";
    begin
        Total := 0;
        Incomplete := 0;
        DeliveryTripSourceDocCnt.SetRange(DeliveryTripNo, DeliveryTripNo);
        if SourceType <> 0 then begin
            DeliveryTripSourceDocCnt.SetRange(SourceType, SourceType);
            DeliveryTripSourceDocCnt.SetRange(SourceSubtype, SourceSubtype);
            DeliveryTripSourceDocCnt.SetRange(SourceNo, SourceNo);
        end;
        if DeliveryTripSourceDocCnt.Open then
            while DeliveryTripSourceDocCnt.Read do begin
                Total += 1;
                if DeliveryTripSourceDocCnt.SumQtyToShip < DeliveryTripSourceDocCnt.Quantity then
                    Incomplete += 1;
            end;
    end;

    procedure DeliveryTripContainerCount(DeliveryTripNo: Code[20]; SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20]; var Total: Integer; var Unloaded: Integer)
    var
        DeliveryTripContainerCnt: Query "Delivery Trip Container Count";
    begin
        Total := 0;
        Unloaded := 0;

        if not ProcessFns.ContainerTrackingInstalled then // P8004554
            exit;                                           // P8004554

        DeliveryTripContainerCnt.SetRange(DeliveryTripNo, DeliveryTripNo);
        if SourceType <> 0 then begin
            DeliveryTripContainerCnt.SetRange(DocumentSubtype, SourceSubtype);
            DeliveryTripContainerCnt.SetRange(DocumentType, SourceType);
            DeliveryTripContainerCnt.SetRange(DocumentNo, SourceNo);
        end;
        if DeliveryTripContainerCnt.Open then
            while DeliveryTripContainerCnt.Read do begin
                Total += DeliveryTripContainerCnt.LineCount;
                if not DeliveryTripContainerCnt.Loaded then
                    Unloaded += DeliveryTripContainerCnt.LineCount;
            end;
    end;

    procedure PostedDocumentContainerCount(var DeliveryTripOrder: Record "Delivery Trip Order")
    var
        ClosedContainerHeader: Record "Shipped Container Header";
    begin
        // P8004554
        DeliveryTripOrder.Containers := 0;

        if not ProcessFns.ContainerTrackingInstalled then
            exit;

        case DeliveryTripOrder."Posted Document" of
            DeliveryTripOrder."Posted Document"::Shipment:
                ClosedContainerHeader.SetRange("Document Type", DATABASE::"Sales Shipment Line");
            DeliveryTripOrder."Posted Document"::"Return Shipment":
                ClosedContainerHeader.SetRange("Document Type", DATABASE::"Return Shipment Line");
            DeliveryTripOrder."Posted Document"::"Transfer Shipment":
                ClosedContainerHeader.SetRange("Document Type", DATABASE::"Transfer Shipment Line");
        end;
        ClosedContainerHeader.SetRange("Document No.", DeliveryTripOrder."Posted Document No.");
        DeliveryTripOrder.Containers := ClosedContainerHeader.Count;
    end;

    procedure PostedDocumentContainerDrilldown(var DeliveryTripOrder: Record "Delivery Trip Order")
    var
        ClosedContainerHeader: Record "Shipped Container Header";
    begin
        // P8004554
        if DeliveryTripOrder.Containers = 0 then
            exit;

        case DeliveryTripOrder."Posted Document" of
            DeliveryTripOrder."Posted Document"::Shipment:
                ClosedContainerHeader.SetRange("Document Type", DATABASE::"Sales Shipment Line");
            DeliveryTripOrder."Posted Document"::"Return Shipment":
                ClosedContainerHeader.SetRange("Document Type", DATABASE::"Return Shipment Line");
            DeliveryTripOrder."Posted Document"::"Transfer Shipment":
                ClosedContainerHeader.SetRange("Document Type", DATABASE::"Transfer Shipment Line");
        end;
        ClosedContainerHeader.SetRange("Document No.", DeliveryTripOrder."Posted Document No.");
        PAGE.Run(0, ClosedContainerHeader);
    end;

    procedure PostedDocumentCount(var DeliveryTripOrder: Record "Delivery Trip Order")
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        // P8007133
        DeliveryTripOrder."Posted Documents" := 0;

        case DeliveryTripOrder."Source Document" of
            DeliveryTripOrder."Source Document"::"Sales Order":
                begin
                    SalesShipmentHeader.SetRange("Order No.", DeliveryTripOrder."Source No.");
                    DeliveryTripOrder."Posted Documents" := SalesShipmentHeader.Count;
                end;
            DeliveryTripOrder."Source Document"::"Purchase Return Order":
                begin
                    ReturnShipmentHeader.SetRange("Return Order No.", DeliveryTripOrder."Source No.");
                    DeliveryTripOrder."Posted Documents" := ReturnShipmentHeader.Count;
                end;
            DeliveryTripOrder."Source Document"::"Transfer Order":
                begin
                    TransferShipmentHeader.SetRange("Transfer Order No.", DeliveryTripOrder."Source No.");
                    DeliveryTripOrder."Posted Documents" := TransferShipmentHeader.Count;
                end;
        end;
    end;

    procedure PostedDocumentDrilldown(var DeliveryTripOrder: Record "Delivery Trip Order")
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        // P8007133
        if DeliveryTripOrder."Posted Documents" = 0 then
            exit;

        case DeliveryTripOrder."Source Document" of
            DeliveryTripOrder."Source Document"::"Sales Order":
                begin
                    SalesShipmentHeader.SetRange("Order No.", DeliveryTripOrder."Source No.");
                    PAGE.Run(0, SalesShipmentHeader);
                end;
            DeliveryTripOrder."Source Document"::"Purchase Return Order":
                begin
                    ReturnShipmentHeader.SetRange("Return Order No.", DeliveryTripOrder."Source No.");
                    PAGE.Run(0, ReturnShipmentHeader);
                end;
            DeliveryTripOrder."Source Document"::"Transfer Order":
                begin
                    TransferShipmentHeader.SetRange("Transfer Order No.", DeliveryTripOrder."Source No.");
                    PAGE.Run(0, TransferShipmentHeader);
                end;
        end;
    end;
}

