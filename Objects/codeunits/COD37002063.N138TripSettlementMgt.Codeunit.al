codeunit 37002063 "N138 Trip Settlement Mgt."
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 06-07-2015, Initial Version
    // --------------------------------------------------------------------------------
    // 
    // PRW19.00.01
    // P8006787, To-Increase, Jack Reynolds, 21 APR 16
    //   Fix issues with settlement and catch weight items
    // 
    // P8007168, To-Increase, Dayakar Battini, 08 JUN 16
    //  Trip Settlement Posting Issue
    // 
    // P8007185, To-Increase, Dayakar Battini, 09 JUN 16
    //  Trip Settlement maintain "Original Quantity"
    // 
    // P8006916, To-Increase, Dayakar Battini, 16 JUN 16
    //   FOOD-TOM Separation delete Transsmart objects
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 16 JAN 17
    //   Correct misspellings
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW111.00.03
    // P80082431, To-increase, Gangabhushan, 23 SEP 19
    //   CS00075223 - Orders are removed from trips when using resolve shorts


    trigger OnRun()
    begin
    end;

    var
        FromDeliveryTripNo: Code[20];

    procedure SettlementSlsOrder(SalesHeader: Record "Sales Header")
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        PostedSalesShipmentLines: Page "Posted Sales Shipment Lines";
        Text000: Label 'There are no shipments linked to this sales order';
        Text001: Label 'Select the Sales Shipment Line to settle';
    begin
        SalesShipmentLine.SetRange("Order No.", SalesHeader."No.");

        case SalesShipmentLine.Count of
            0:
                begin
                    Error(Text000);
                end;
            1:
                SalesShipmentLine.FindFirst;
            else begin
                    PostedSalesShipmentLines.Caption(Text001);
                    PostedSalesShipmentLines.LookupMode(true);
                    PostedSalesShipmentLines.SetTableView(SalesShipmentLine);
                    if PostedSalesShipmentLines.RunModal = ACTION::LookupOK then begin
                        PostedSalesShipmentLines.GetRecord(SalesShipmentLine);
                    end else
                        exit;
                end;
        end;

        Settlement2(SalesShipmentLine);
    end;

    procedure Settlement2(SalesShipmentLine: Record "Sales Shipment Line")
    var
        SettlementWizard: Page "N138 Settlement Wizard";
        SettlementQty: Decimal;
    begin
        SalesShipmentLine.SetRecFilter;
        SettlementWizard.SetTableView(SalesShipmentLine);
        SettlementWizard.SetSettlementPosting(FromDeliveryTripNo);   // P8007168
        if SettlementWizard.RunModal = ACTION::Yes then begin
        end;
    end;

    procedure UndoShipment(SalesShipmentLine: Record "Sales Shipment Line"; SettlementQty: Decimal; var PostingPossible: Boolean)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        UndoSalesShipmentLine: Codeunit "Undo Sales Shipment Line";
        SalesPost: Codeunit "Sales-Post";
    begin
        with SalesShipmentLine do begin
            SetRecFilter;
            UndoSalesShipmentLine.SetHideDialog(true);
            UndoSalesShipmentLine.Run(SalesShipmentLine);

            SalesLine.Get(SalesLine."Document Type"::Order, "Order No.", "Order Line No.");
            ChangeTrackingInformation(SalesLine, SettlementQty, PostingPossible);
            SalesLine.Settlement := true;

            SalesLine.Modify;
        end;
    end;

    local procedure ChangeQty2ShipOtherLines(SalesLine: Record "Sales Line")
    var
        CurrSalesLine: Record "Sales Line";
    begin
        CurrSalesLine.SetRange("Document Type", SalesLine."Document Type");
        CurrSalesLine.SetRange("Document No.", SalesLine."Document No.");
        CurrSalesLine.SetFilter("Line No.", '<>%1', SalesLine."Line No.");
        CurrSalesLine.ModifyAll("Qty. to Ship", 0, true);
    end;

    procedure PostSalesSettlementSlsLine(SalesLine: Record "Sales Line"; BackOrder: Boolean; SettlementQty: Decimal; SettlementQtyAlt: Decimal; BinCode: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        Location: Record Location;
        WhseShip: Boolean;
        WhseRqst: Record "Warehouse Request";
        GetSourceDocuments: Report "Get Source Documents";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WhsePostShipment: Codeunit "Whse.-Post Shipment";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        OriginalQty: Decimal;
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        // P8006787
        if SalesHeader.Status = SalesHeader.Status::Open then begin
            // P8007168
            ReleaseSalesDocument.SetDeliveryTrip(FromDeliveryTripNo); // P80082431
            ReleaseSalesDocument.Run(SalesHeader);
            // P8007168
            SalesHeader.Modify;
            SalesLine.Find;
        end;
        // P8006787
        if Location.Get(SalesLine."Location Code") then
            WhseShip := Location."Directed Put-away and Pick";

        if not BackOrder then begin
            SalesLine.SuspendStatusCheck(true);
            SalesLine."Allow Quantity Change" := true;       // P8007168
            OriginalQty := SalesLine."Original Quantity";    // P8007185
            SalesLine.Validate(Quantity, SalesLine."Quantity Shipped" + SettlementQty);
            SalesLine.Validate("Original Quantity", OriginalQty);    // P8007185
        end;

        ChangeQty2ShipOtherLines(SalesLine);
        if not WhseShip then begin
            SalesLine.Validate("Qty. to Ship", SettlementQty);
            // P8006787
            if SettlementQtyAlt <> 0 then begin
                AltQtyMgmt.DeleteAltQtyLines(SalesLine."Alt. Qty. Transaction No.");
                SalesLine."Qty. to Ship (Alt.)" := SettlementQtyAlt;
                AltQtyMgmt.ValidateSalesAltQtyLine(SalesLine);
            end;
            // P8006787
            if BinCode <> SalesLine."Bin Code" then
                SalesLine.Validate("Bin Code", BinCode);
        end;
        // P8007168
        SalesLine."Allow Quantity Change" := false;
        if SettlementQty = 0 then
            SalesLine.Settlement := false;
        // P8007168
        SalesLine.Modify;

        if SettlementQty > 0 then begin
            if not WhseShip then begin
                SalesHeader.Ship := true;
                SalesHeader.Receive := false;
                SalesHeader.Invoice := false;

                SalesPost.SetSettlement;
                SalesPost.Run(SalesHeader);

                if SalesLine.Find then begin
                    SalesLine.Settlement := false;
                    SalesLine.Modify;
                end;

            end else begin
                SalesLine.Settlement := false;
                SalesLine.Modify;

                WhseRqst.Get(1, SalesLine."Location Code", DATABASE::"Sales Line", SalesLine."Document Type", SalesLine."Document No.");
                WhseRqst.SetRecFilter;
                SalesLine.SetRecFilter;
                GetSourceDocuments.SetHideDialog(true);
                GetSourceDocuments.UseRequestPage(false);
                GetSourceDocuments.SetTableView(SalesLine);
                GetSourceDocuments.SetTableView(WhseRqst);
                GetSourceDocuments.RunModal;
                WarehouseShipmentLine.SetRange("Source Type", DATABASE::"Sales Line");
                WarehouseShipmentLine.SetRange("Source Subtype", 1);
                WarehouseShipmentLine.SetRange("Source No.", SalesLine."Document No.");
                WarehouseShipmentLine.SetRange("Source Line No.", SalesLine."Line No.");
                WarehouseShipmentLine.FindLast;
                if BinCode <> WarehouseShipmentLine."Bin Code" then
                    WarehouseShipmentLine.Validate("Bin Code", BinCode);
                WarehouseShipmentLine.Validate("Qty. Picked", SettlementQty);
                WarehouseShipmentLine.Validate("Qty. to Ship", SettlementQty);
                // P8006787
                if SettlementQtyAlt <> 0 then begin
                    AltQtyMgmt.DeleteAltQtyLines(SalesLine."Alt. Qty. Transaction No.");
                    AltQtyMgmt.WhseShptLineValidateQty(WarehouseShipmentLine, SettlementQtyAlt, false);
                end;
                // P8006787
                WarehouseShipmentLine.Modify;
                WhsePostShipment.Run(WarehouseShipmentLine);
            end;
        end;
    end;

    local procedure BackOrder(SalesLine: Record "Sales Line"; SettlementQty: Decimal)
    begin
        SalesLine.SuspendStatusCheck(true);
        SalesLine.Validate(Quantity, SettlementQty);
        SalesLine.Modify;
    end;

    local procedure ChangeTrackingInformation(SalesLine: Record "Sales Line"; SettlementQty: Decimal; var PostingPossible: Boolean)
    var
        SalesLineReserve: Codeunit "Sales Line-Reserve";
        ReservationEntry: Record "Reservation Entry";
    begin
        SalesLine.SetReservationFilters(ReservationEntry); // P800131478

        PostingPossible := not (ReservationEntry.Count > 1);
        if ReservationEntry.Count = 1 then begin
            ReservationEntry.FindFirst;
            ReservationEntry.Validate("Quantity (Base)", -SettlementQty);
            ReservationEntry.Modify(true);
        end;
    end;

    procedure SetSettlementPosting(DeliveryTripNo: Code[20])
    begin
        // P8007168
        FromDeliveryTripNo := DeliveryTripNo;
    end;
}

