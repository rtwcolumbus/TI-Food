codeunit 37002100 "Process 800 Warehouse Mgmt."
{
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Support functions for order shipping and order receiving to handle 1, 2, and 3 document processing
    // 
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 18 AUG 06
    //   Additional functions for managing warehouse picks from order shipping form
    //   Staged Picks
    //   Sales Samples
    // 
    // PRW15.00.01
    // P8000526A, VerticalSoft, Jack Reynolds, 01 OCT 07
    //   WhseReqDestName - increase length of return value to 50 characters
    // 
    // PRW16.00.03
    // P8000828, VerticalSoft, Don Bresee, 21 JUN 10
    //   Add logic to eliminate modal windows for the RTC
    // 
    // PRW16.00.06
    // P8001034, Columbus IT, Jack Reynolds, 10 FEB 12
    //   Move Warehouse Employee functions
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW19.00.01
    // P8008011, To-Increase, Dayakar Battini, 14 NOV 16
    //   Bug whith Whse. shipment creation.
    // 
    // P8008012, To-Increase, Dayakar Battini, 14 NOV 16
    //   Bug whith Whse. receive creation
    // 
    // PRW110.0.01
    // P8008653, To-Increase, Jack Reynolds, 07 APR 17
    //   Bug with assigning containers to inbound transfers
    // 
    // PRW110.0.02
    // P80051732, To-Increase, Dayakar Battini, 12 JAN 18
    //   Fixing Stage pick creation errors
    // 
    // P80050544, To-Increase, Dayakar Battini, 12 FEB 18
    //   Upgrade to 2017 CU13
    // 
    // PRW111.00.02
    // P80070336, To Increase, Jack Reynolds, 12 FEB 19
    //   Fix issue with Alternate Quantity to Handle
    // 
    // P80071657, To Increase, Jack Reynolds, 15 MAR 19
    //   Fix posting date issue; refactoring
    // 
    //  PRW111.00.03
    //  P800115815, To Increase, Gangabhushan, 19 JAN 21
    //    CS00145229 | FW: Sales Return Order - Order Receiving    
    //    
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW121.2
    // P800162917, To Increase, Jack Reynolds, 23 Jan 23
    //   Obsolete Post and Print and add Post and Send

    Permissions = TableData "Batch Processing Parameter" = rimd,
                  TableData "Batch Processing Session Map" = rimd;

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        WarehouseRequest: Record "Warehouse Request";
        WhseReqSource: RecordRef;
        Text002: Label 'Orders for different locations cannot be combined.';
        Text003: Label 'Selected orders have different shipment numbers.';
        Text004: Label 'Selected orders have different receipt numbers.';
        P800WhseActCreate: Codeunit "Process 800 Create Whse. Act.";
        SalesSampleStaging: Boolean;
        Text005: Label 'Nothing to Pick.';
        Text006: Label 'Nothing to Stage.';

    procedure WhseReqDestName(WhseReq: Record "Warehouse Request"): Text[100]
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Location: Record Location;
    begin
        // P8000526A - increase length of return value to 50 characters
        with WhseReq do
            case "Source Document" of
                "Source Document"::"Sales Order", "Source Document"::"Sales Return Order":
                    begin
                        Customer.Get("Destination No.");
                        exit(Customer.Name);
                    end;
                "Source Document"::"Purchase Order", "Source Document"::"Purchase Return Order":
                    begin
                        Vendor.Get("Destination No.");
                        exit(Vendor.Name);
                    end;
                "Source Document"::"Inbound Transfer", "Source Document"::"Outbound Transfer":
                    begin
                        Location.Get("Destination No.");
                        exit(Location.Name);
                    end;
            end;
    end;

    procedure WhseReqSourceDate(WhseReq: Record "Warehouse Request") SourceDate: Date
    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        FldRef: FieldRef;
        FldNo: Integer;
    begin
        with WhseReq do begin
            case "Source Document" of
                "Source Document"::"Sales Order", "Source Document"::"Sales Return Order":
                    FldNo := SalesHeader.FieldNo("Order Date");
                "Source Document"::"Purchase Order", "Source Document"::"Purchase Return Order":
                    FldNo := PurchHeader.FieldNo("Order Date");
            end;

            if FldNo <> 0 then begin
                WhseReqGetSource(WhseReq);
                FldRef := WhseReqSource.Field(FldNo);
                SourceDate := FldRef.Value;
            end;
        end;
    end;

    procedure WhseReqReceiptNo(WhseReq: Record "Warehouse Request"): Code[20]
    var
        WhseReceiptLine: Record "Warehouse Receipt Line";
    begin
        WhseReceiptLine.SetCurrentKey("Source Type", "Source Subtype", "Source No.");
        WhseReceiptLine.SetRange("Source Type", WhseReq."Source Type");
        WhseReceiptLine.SetRange("Source Subtype", WhseReq."Source Subtype");
        WhseReceiptLine.SetRange("Source No.", WhseReq."Source No.");
        WhseReceiptLine.SetRange("Location Code", WhseReq."Location Code");
        if WhseReceiptLine.Find('-') then
            exit(WhseReceiptLine."No.");
    end;

    procedure WhseReqShipmentNo(WhseReq: Record "Warehouse Request"): Code[20]
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
    begin
        WhseShipmentLine.SetCurrentKey("Source Type", "Source Subtype", "Source No.");
        WhseShipmentLine.SetRange("Source Type", WhseReq."Source Type");
        WhseShipmentLine.SetRange("Source Subtype", WhseReq."Source Subtype");
        WhseShipmentLine.SetRange("Source No.", WhseReq."Source No.");
        WhseShipmentLine.SetRange("Location Code", WhseReq."Location Code");
        if WhseShipmentLine.Find('-') then
            exit(WhseShipmentLine."No.");
    end;

    procedure WhseReqPickPutAwayNo(WhseReq: Record "Warehouse Request"): Code[20]
    var
        WhseActivityHeader: Record "Warehouse Activity Header";
    begin
        WhseActivityHeader.SetCurrentKey("Source Document", "Source No.", "Location Code");
        WhseActivityHeader.SetFilter(Type, '%1|%2', WhseActivityHeader.Type::"Invt. Put-away", WhseActivityHeader.Type::"Invt. Pick");
        WhseActivityHeader.SetRange("Source Document", WhseReq."Source Document");
        WhseActivityHeader.SetRange("Source No.", WhseReq."Source No.");
        WhseActivityHeader.SetRange("Location Code", WhseReq."Location Code");
        if WhseActivityHeader.Find('-') then
            exit(WhseActivityHeader."No.");
    end;

    local procedure WhseReqGetSource(WhseReq: Record "Warehouse Request")
    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        TransHeader: Record "Transfer Header";
    begin
        with WhseReq do
            if ("Source Document" <> WarehouseRequest."Source Document") or
               ("Source No." <> WarehouseRequest."Source No.")
            then begin
                WarehouseRequest := WhseReq;
                case "Source Document" of
                    "Source Document"::"Sales Order", "Source Document"::"Sales Return Order":
                        begin
                            SalesHeader.Get("Source Subtype", "Source No.");
                            WhseReqSource.GetTable(SalesHeader);
                        end;
                    "Source Document"::"Purchase Order", "Source Document"::"Purchase Return Order":
                        begin
                            PurchHeader.Get("Source Subtype", "Source No.");
                            WhseReqSource.GetTable(PurchHeader);
                        end;
                    "Source Document"::"Inbound Transfer", "Source Document"::"Outbound Transfer":
                        begin
                            TransHeader.Get("Source No.");
                            WhseReqSource.GetTable(TransHeader);
                        end;
                end;
            end;
    end;

    procedure WhseReqShowSourceDoc(WhseReq: Record "Warehouse Request")
    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        TransHeader: Record "Transfer Header";
        SalesOrder: Page "Sales Order";
        SalesRetOrder: Page "Sales Return Order";
        PurchOrder: Page "Purchase Order";
        PurchRetOrder: Page "Purchase Return Order";
        TransOrder: Page "Transfer Order";
    begin
        with WhseReq do
            case "Source Document" of
                "Source Document"::"Sales Order", "Source Document"::"Sales Return Order":
                    begin
                        SalesHeader.FilterGroup(4);
                        SalesHeader.Get("Source Subtype", "Source No.");
                        SalesHeader.SetRecFilter;
                        SalesHeader.FilterGroup(0);
                        case "Source Document" of
                            "Source Document"::"Sales Order":
                                begin
                                    SalesOrder.Editable(false);
                                    SalesOrder.SetTableView(SalesHeader);
                                    if IsServiceTier then // P8000828
                                        SalesOrder.Run      // P8000828
                                    else                  // P8000828
                                        SalesOrder.RunModal;
                                end;
                            "Source Document"::"Sales Return Order":
                                begin
                                    SalesRetOrder.Editable(false);
                                    SalesRetOrder.SetTableView(SalesHeader);
                                    if IsServiceTier then // P8000828
                                        SalesRetOrder.Run   // P8000828
                                    else                  // P8000828
                                        SalesRetOrder.RunModal;
                                end;
                        end;
                    end;
                "Source Document"::"Purchase Order", "Source Document"::"Purchase Return Order":
                    begin
                        PurchHeader.FilterGroup(4);
                        PurchHeader.Get("Source Subtype", "Source No.");
                        PurchHeader.SetRecFilter;
                        PurchHeader.FilterGroup(0);
                        case "Source Document" of
                            "Source Document"::"Purchase Order":
                                begin
                                    PurchOrder.Editable(false);
                                    PurchOrder.SetTableView(PurchHeader);
                                    if IsServiceTier then // P8000828
                                        PurchOrder.Run      // P8000828
                                    else                  // P8000828
                                        PurchOrder.RunModal;
                                end;
                            "Source Document"::"Purchase Return Order":
                                begin
                                    PurchRetOrder.Editable(false);
                                    PurchRetOrder.SetTableView(PurchHeader);
                                    if IsServiceTier then // P8000828
                                        PurchRetOrder.Run   // P8000828
                                    else                  // P8000828
                                        PurchRetOrder.RunModal;
                                end;
                        end;
                    end;
                "Source Document"::"Outbound Transfer", "Source Document"::"Inbound Transfer":
                    begin
                        TransHeader.FilterGroup(4);
                        TransHeader.Get("Source No.");
                        TransHeader.SetRecFilter;
                        TransHeader.FilterGroup(0);
                        TransOrder.Editable(false);
                        TransOrder.SetTableView(TransHeader);
                        if IsServiceTier then // P8000828
                            TransOrder.Run      // P8000828
                        else                  // P8000828
                            TransOrder.RunModal;
                    end;
            end;
    end;

    procedure WhseReqShowSourceComments(WhseReq: Record "Warehouse Request")
    var
        SalesCommentLine: Record "Sales Comment Line";
        PurchCommentLine: Record "Purch. Comment Line";
        InvCommentLine: Record "Inventory Comment Line";
        SalesCommentSheet: Page "Sales Comment Sheet";
        PurchCommentSheet: Page "Purch. Comment Sheet";
        InvCommentSheet: Page "Inventory Comment Sheet";
    begin
        with WhseReq do
            case "Source Document" of
                "Source Document"::"Sales Order", "Source Document"::"Sales Return Order":
                    begin
                        SalesCommentLine.FilterGroup(4);
                        SalesCommentLine.SetRange("Document Type", "Source Subtype");
                        SalesCommentLine.SetRange("No.", "Source No.");
                        SalesCommentLine.FilterGroup(4);
                        SalesCommentSheet.SetTableView(SalesCommentLine);
                        SalesCommentSheet.RunModal;
                    end;
                "Source Document"::"Purchase Order", "Source Document"::"Purchase Return Order":
                    begin
                        PurchCommentLine.FilterGroup(4);
                        PurchCommentLine.SetRange("Document Type", "Source Subtype");
                        PurchCommentLine.SetRange("No.", "Source No.");
                        PurchCommentLine.FilterGroup(4);
                        PurchCommentSheet.SetTableView(PurchCommentLine);
                        PurchCommentSheet.RunModal;
                    end;
                "Source Document"::"Outbound Transfer", "Source Document"::"Inbound Transfer":
                    begin
                        InvCommentLine.FilterGroup(4);
                        InvCommentLine.SetRange("Document Type", InvCommentLine."Document Type"::"Transfer Order");
                        InvCommentLine.SetRange("No.", "Source No.");
                        InvCommentLine.FilterGroup(4);
                        InvCommentSheet.SetTableView(InvCommentLine);
                        InvCommentSheet.RunModal;
                    end;
            end;
    end;

    procedure WhseShipOrder(var WhseReq: Record "Warehouse Request")
    var
        Location: Record Location;
        WhseSetup: Record "Warehouse Setup";
    begin
        with WhseReq do begin
            if not Find('-') then
                exit;

            if not Location.Get("Location Code") then begin
                WhseSetup.Get;
                Location."Require Pick" := WhseSetup."Require Pick";
                Location."Require Shipment" := WhseSetup."Require Shipment";
            end;

            //IF Location."Require Pick" AND Location."Require Shipment" THEN   // P8008011
            if Location."Require Shipment" then                                 // P8008011
                ShipWithWhseShipment(WhseReq)
            else
                if Location."Require Pick" then
                    ShipWithInvPick(WhseReq)
                else
                    ShipWithDocLine(WhseReq);
        end;
    end;

    procedure ShipWithWhseShipment(var WhseReq: Record "Warehouse Request")
    var
        WhseShipmentHeader: Record "Warehouse Shipment Header";
        WhseShipmentLine: Record "Warehouse Shipment Line";
        Location: Record Location;
        GetSourceDocuments: Report "Get Source Documents";
        WhseShipment: Page "Warehouse Shipment";
        CreatePick: Codeunit "Create Pick";
        ShipmentNo: Code[20];
        LocCode: Code[10];
    begin
        with WhseReq do
            if Find('-') then begin
                LocCode := "Location Code";
                WhseShipmentLine.SetCurrentKey("Source Type", "Source Subtype", "Source No.");
                WhseShipmentLine.SetRange("Source Type", "Source Type");
                WhseShipmentLine.SetRange("Source Subtype", "Source Subtype");
                WhseShipmentLine.SetRange("Source No.", "Source No.");
                WhseShipmentLine.SetRange("Location Code", "Location Code");
                if WhseShipmentLine.Find('-') then
                    ShipmentNo := WhseShipmentLine."No.";
                if Next <> 0 then
                    repeat
                        if LocCode <> "Location Code" then
                            Error(Text002);
                        WhseShipmentLine.SetRange("Source Type", "Source Type");
                        WhseShipmentLine.SetRange("Source Subtype", "Source Subtype");
                        WhseShipmentLine.SetRange("Source No.", "Source No.");
                        WhseShipmentLine.SetRange("Location Code", "Location Code");
                        if WhseShipmentLine.Find('-') then begin
                            if ShipmentNo <> WhseShipmentLine."No." then
                                Error(Text003);
                        end else begin
                            if ShipmentNo <> '' then
                                Error(Text003);
                        end;
                    until Next = 0;

                if ShipmentNo = '' then begin
                    WhseShipmentHeader.Validate("Location Code", "Location Code");
                    WhseShipmentHeader.Insert(true);
                    ShipmentNo := WhseShipmentHeader."No.";

                    GetSourceDocuments.UseRequestPage(false);
                    GetSourceDocuments.SetTableView(WhseReq);
                    GetSourceDocuments.SetOneCreatedShptHeader(WhseShipmentHeader);
                    GetSourceDocuments.RunModal;
                    Commit;
                end;

                WhseShipmentHeader.Get(ShipmentNo);
                WhseShipmentHeader.FilterGroup(9);
                WhseShipmentHeader.SetRecFilter;
                WhseShipmentHeader.FilterGroup(0);
                WhseShipment.SetTableView(WhseShipmentHeader);
                WhseShipment.RunFromOrderShipping(true);
                if IsServiceTier then // P8000828
                    WhseShipment.Run    // P8000828
                else                  // P8000828
                    WhseShipment.RunModal;

                if WhseShipment.ShipmentPosted then begin
                    // P8000828
                    if not IsServiceTier then
                        WhseShipmentAfterPost(WhseShipmentHeader);
                    //
                    /*
                    IF WhseShipmentHeader.FIND THEN BEGIN
                      WhseShipmentLine.RESET;
                      WhseShipmentLine.SETRANGE("No.",WhseShipmentHeader."No.");
                      IF WhseShipmentLine.FIND('-') THEN BEGIN
                        Location.GET(WhseShipmentLine."Location Code");
                        REPEAT
                          IF Location."Require Pick" THEN
                            CreatePick.AdjustReservation(
                              WhseShipmentLine."Qty. Outstanding (Base)",WhseShipmentLine."Source Type",
                              WhseShipmentLine."Source Subtype",WhseShipmentLine."Source No.",
                              WhseShipmentLine."Source Line No.",0,1);
                          WhseShipmentLine.DELETE;
                        UNTIL WhseShipmentLine.NEXT = 0;
                      END;
                      WhseShipmentHeader.DeleteRelatedLines;
                      WhseShipmentHeader.DELETE;
                    END;
                    */
                    // P8000828
                end;
            end;

    end;

    procedure WhseShipmentAfterPost(WhseShipmentHeader: Record "Warehouse Shipment Header")
    var
        WhseShipmentLine: Record "Warehouse Shipment Line";
        Location: Record Location;
        CreatePick: Codeunit "Create Pick";
    begin
        // P8000828
        if WhseShipmentHeader.Find then begin
            WhseShipmentLine.Reset;
            WhseShipmentLine.SetRange("No.", WhseShipmentHeader."No.");
            if WhseShipmentLine.Find('-') then begin
                Location.Get(WhseShipmentLine."Location Code");
                repeat
                    // P8001132
                    //IF Location."Require Pick" THEN
                    //  CreatePick.AdjustReservation(
                    //    WhseShipmentLine."Qty. Outstanding (Base)",WhseShipmentLine."Source Type",
                    //    WhseShipmentLine."Source Subtype",WhseShipmentLine."Source No.",
                    //    WhseShipmentLine."Source Line No.",0,1);
                    // P8001132
                    WhseShipmentLine.Delete;
                until WhseShipmentLine.Next = 0;
            end;
            WhseShipmentHeader.DeleteRelatedLines;
            WhseShipmentHeader.Delete;
        end;
    end;

    local procedure ShipWithInvPick(WhseReq: Record "Warehouse Request")
    var
        WhseActivityHdr: Record "Warehouse Activity Header";
        InventoryPick: Page "Inventory Pick";
    begin
        with WhseReq do begin
            WhseActivityHdr.SetCurrentKey("Source Document", "Source No.", "Location Code");
            WhseActivityHdr.SetRange("Source Document", "Source Document");
            WhseActivityHdr.SetRange("Source No.", "Source No.");
            WhseActivityHdr.SetRange("Location Code", "Location Code");
            if not WhseActivityHdr.Find('-') then begin
                Clear(WhseActivityHdr);
                WhseActivityHdr.Validate(Type, WhseActivityHdr.Type::"Invt. Pick");
                WhseActivityHdr.Insert(true);
                WhseActivityHdr.Validate("Location Code", "Location Code");
                WhseActivityHdr.Validate("Source Document", "Source Document");
                WhseActivityHdr.Validate("Source No.", "Source No.");
                WhseActivityHdr.Modify(true);
                Commit;
            end;

            WhseActivityHdr.Reset;
            WhseActivityHdr.FilterGroup(9);
            WhseActivityHdr.SetRecFilter;
            WhseActivityHdr.FilterGroup(0);
            InventoryPick.RunFromOrderShipping(true);
            InventoryPick.SetTableView(WhseActivityHdr);
            if IsServiceTier then // P8000828
                InventoryPick.Run   // P8000828
            else                  // P8000828
                InventoryPick.RunModal;
        end;
    end;

    local procedure ShipWithDocLine(WhseReq: Record "Warehouse Request")
    var
        ShipSalesOrder: Page "Order Shipping-Sales";
        ShipPurchRetOrder: Page "Order Shipping-Purch.";
        ShipTransOrder: Page "Order Shipping-Trans.";
    begin
        with WhseReq do begin
            WhseReqGetSource(WhseReq);
            case "Source Document" of
                "Source Document"::"Sales Order":
                    begin
                        ShipSalesOrder.SetSalesHeader(WhseReq);
                        ShipSalesOrder.RunModal;
                    end;
                "Source Document"::"Purchase Return Order":
                    begin
                        ShipPurchRetOrder.SetPurchHeader(WhseReq);
                        ShipPurchRetOrder.RunModal;
                    end;
                "Source Document"::"Outbound Transfer":
                    begin
                        ShipTransOrder.SetTransHeader(WhseReq);
                        ShipTransOrder.RunModal;
                    end;
            end;
        end;
    end;

    procedure WhseReceiveOrder(var WhseReq: Record "Warehouse Request")
    var
        Location: Record Location;
        WhseSetup: Record "Warehouse Setup";
    begin
        with WhseReq do begin
            if not Find('-') then
                exit;

            if not Location.Get("Location Code") then begin
                WhseSetup.Get;
                Location."Require Put-away" := WhseSetup."Require Put-away";
                Location."Require Receive" := WhseSetup."Require Receive";
            end;

            //IF Location."Require Put-away" AND Location."Require Receive" THEN  // P8008012
            if Location."Require Receive" then                                    // P8008012
                ReceiveWithWhseReceipt(WhseReq)
            else
                if Location."Require Put-away" then
                    ReceiveWithInvPutAway(WhseReq)
                else
                    ReceiveWithDocLine(WhseReq);
        end;
    end;

    procedure ReceiveWithWhseReceipt(var WhseReq: Record "Warehouse Request")
    var
        WhseReceiptHeader: Record "Warehouse Receipt Header";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        GetSourceDocuments: Report "Get Source Documents";
        WhseReceipt: Page "Warehouse Receipt";
        ReceiptNo: Code[20];
        LocCode: Code[10];
    begin
        with WhseReq do
            if Find('-') then begin
                LocCode := "Location Code";
                WhseReceiptLine.SetCurrentKey("Source Type", "Source Subtype", "Source No.");
                WhseReceiptLine.SetRange("Source Type", "Source Type");
                WhseReceiptLine.SetRange("Source Subtype", "Source Subtype");
                WhseReceiptLine.SetRange("Source No.", "Source No.");
                WhseReceiptLine.SetRange("Location Code", "Location Code");
                if WhseReceiptLine.Find('-') then
                    ReceiptNo := WhseReceiptLine."No.";
                if Next <> 0 then
                    repeat
                        if LocCode <> "Location Code" then
                            Error(Text002);
                        WhseReceiptLine.SetRange("Source Type", "Source Type");
                        WhseReceiptLine.SetRange("Source Subtype", "Source Subtype");
                        WhseReceiptLine.SetRange("Source No.", "Source No.");
                        WhseReceiptLine.SetRange("Location Code", "Location Code");
                        if WhseReceiptLine.Find('-') then begin
                            if ReceiptNo <> WhseReceiptLine."No." then
                                Error(Text004);
                        end else begin
                            if ReceiptNo <> '' then
                                Error(Text004);
                        end;
                    until WhseReq.Next = 0;

                if ReceiptNo = '' then begin
                    WhseReceiptHeader.Validate("Location Code", "Location Code");
                    WhseReceiptHeader.Insert(true);
                    ReceiptNo := WhseReceiptHeader."No.";

                    GetSourceDocuments.UseRequestPage(false);
                    GetSourceDocuments.SetTableView(WhseReq);
                    GetSourceDocuments.SetOneCreatedReceiptHeader(WhseReceiptHeader);
                    GetSourceDocuments.SetAssignContainers; // P8008653
                    GetSourceDocuments.RunModal;
                    Commit;
                end;

                WhseReceiptHeader.Get(ReceiptNo);
                WhseReceiptHeader.FilterGroup(9);
                WhseReceiptHeader.SetRecFilter;
                WhseReceiptHeader.FilterGroup(0);
                WhseReceipt.SetTableView(WhseReceiptHeader);
                WhseReceipt.RunFromOrderReceiving(true);
                if IsServiceTier then // P8000828
                    WhseReceipt.Run     // P8000828
                else                  // P8000828
                    WhseReceipt.RunModal;

                if WhseReceipt.ReceiptPosted then
                    // P8000828
                    if not IsServiceTier then
                        WhseReceiptAfterPost(WhseReceiptHeader);
                //
                /*
                IF WhseReceiptHeader.FIND THEN BEGIN
                  WhseReceiptHeader.DeleteRelatedLines(FALSE);
                  WhseReceiptHeader.DELETE;
                END;
                */
                // P8000828
            end;

    end;

    procedure WhseReceiptAfterPost(WhseReceiptHeader: Record "Warehouse Receipt Header")
    begin
        // P8000828
        if WhseReceiptHeader.Find then begin
            WhseReceiptHeader.DeleteRelatedLines(false);
            WhseReceiptHeader.Delete;
        end;
    end;

    local procedure ReceiveWithInvPutAway(WhseReq: Record "Warehouse Request")
    var
        WhseActivityHdr: Record "Warehouse Activity Header";
        InventoryPutAway: Page "Inventory Put-away";
    begin
        with WhseReq do begin
            WhseActivityHdr.SetCurrentKey("Source Document", "Source No.", "Location Code");
            WhseActivityHdr.SetRange("Source Document", "Source Document");
            WhseActivityHdr.SetRange("Source No.", "Source No.");
            WhseActivityHdr.SetRange("Location Code", "Location Code");
            if not WhseActivityHdr.Find('-') then begin
                Clear(WhseActivityHdr);
                WhseActivityHdr.Validate(Type, WhseActivityHdr.Type::"Invt. Put-away");
                WhseActivityHdr.Insert(true);
                WhseActivityHdr.Validate("Location Code", "Location Code");
                WhseActivityHdr.Validate("Source Document", "Source Document");
                WhseActivityHdr.Validate("Source No.", "Source No.");
                WhseActivityHdr.Modify(true);
                Commit;
            end;

            WhseActivityHdr.Reset;
            WhseActivityHdr.FilterGroup(9);
            WhseActivityHdr.SetRecFilter;
            WhseActivityHdr.FilterGroup(0);
            InventoryPutAway.SetTableView(WhseActivityHdr);
            InventoryPutAway.RunFromOrderReceiving(true);
            if IsServiceTier then  // P8000828
                InventoryPutAway.Run // P8000828
            else                   // P8000828
                InventoryPutAway.RunModal;

            if InventoryPutAway.PutAwayPosted then
                // P8000828
                if not IsServiceTier then
                    InvPutAwayAfterPost(WhseActivityHdr);
            //
            /*
            IF WhseActivityHdr.FIND THEN
              WhseActivityHdr.DELETE(TRUE);
            */
            // P8000828
        end;

    end;

    procedure InvPutAwayAfterPost(WhseActivityHdr: Record "Warehouse Activity Header")
    begin
        // P8000828
        if WhseActivityHdr.Find then
            WhseActivityHdr.Delete(true);
    end;

    local procedure ReceiveWithDocLine(WhseReq: Record "Warehouse Request")
    var
        ReceivePurchOrder: Page "Order Receiving-Purch.";
        ReceiveSalesRetOrder: Page "Order Receiving-Sales";
        ReceiveTransOrder: Page "Order Receiving-Trans.";
    begin
        with WhseReq do
            case "Source Document" of
                "Source Document"::"Purchase Order":
                    begin
                        ReceivePurchOrder.SetPurchHeader(WhseReq);
                        ReceivePurchOrder.RunModal;
                    end;
                "Source Document"::"Sales Return Order":
                    begin
                        ReceiveSalesRetOrder.SetSalesHeader(WhseReq);
                        ReceiveSalesRetOrder.RunModal;
                    end;
                "Source Document"::"Inbound Transfer":
                    begin
                        ReceiveTransOrder.SetTransHeader(WhseReq);
                        ReceiveTransOrder.RunModal;
                    end;
            end;
    end;

    procedure WhseReqPutAwayDrillDown(WhseReq: Record "Warehouse Request")
    var
        WhseSetup: Record "Warehouse Setup";
        Location: Record Location;
    begin
        with WhseReq do begin
            if not Location.Get("Location Code") then begin
                WhseSetup.Get;
                Location."Require Put-away" := WhseSetup."Require Put-away";
                Location."Require Receive" := WhseSetup."Require Receive";
            end;

            if Location."Require Put-away" and (not Location."Require Receive") then
                ReceiveWithInvPutAway(WhseReq);
        end;
    end;

    procedure WhseReqPickDrillDown(WhseReq: Record "Warehouse Request")
    var
        WhseSetup: Record "Warehouse Setup";
        Location: Record Location;
    begin
        with WhseReq do begin
            if not Location.Get("Location Code") then begin
                WhseSetup.Get;
                Location."Require Pick" := WhseSetup."Require Pick";
                Location."Require Shipment" := WhseSetup."Require Shipment";
            end;

            // P8000322A
            if Location."Require Pick" and Location."Require Shipment" then begin
                SetRecFilter;
                PickWithWhseShipment(WhseReq, false);
            end;
            // P8000322A

            if Location."Require Pick" and (not Location."Require Shipment") then
                ShipWithInvPick(WhseReq);
        end;
    end;

    procedure WhseReqReceiptDrillDown(WhseReq: Record "Warehouse Request")
    var
        WhseSetup: Record "Warehouse Setup";
        Location: Record Location;
    begin
        with WhseReq do begin
            if not Location.Get("Location Code") then begin
                WhseSetup.Get;
                Location."Require Receive" := WhseSetup."Require Receive";
            end;

            if Location."Require Receive" then begin
                SetRecFilter;
                ReceiveWithWhseReceipt(WhseReq);
            end;
        end;
    end;

    procedure WhseReqShipmentDrillDown(WhseReq: Record "Warehouse Request")
    var
        WhseSetup: Record "Warehouse Setup";
        Location: Record Location;
    begin
        with WhseReq do begin
            if not Location.Get("Location Code") then begin
                WhseSetup.Get;
                Location."Require Shipment" := WhseSetup."Require Shipment";
            end;

            if Location."Require Shipment" then begin
                SetRecFilter;
                ShipWithWhseShipment(WhseReq);
            end;
        end;
    end;

    local procedure GetFirstWhsePickLine(WhseReq: Record "Warehouse Request"; var WhseActivityLine: Record "Warehouse Activity Line"): Boolean
    var
        Location: Record Location;
    begin
        // P8000322A
        GetLocationRequirements(WhseReq."Location Code", Location);
        if not (Location."Require Pick" and Location."Require Shipment") then
            exit(false);
        with WhseActivityLine do begin
            SetCurrentKey("Source Type", "Source Subtype", "Source No.");
            SetRange("Source Type", WhseReq."Source Type");
            SetRange("Source Subtype", WhseReq."Source Subtype");
            SetRange("Source No.", WhseReq."Source No.");
            SetRange("Activity Type", "Activity Type"::Pick);
            exit(Find('-'));
        end;
        // P8000322A
    end;

    procedure WhseReqWhsePickNo(WhseReq: Record "Warehouse Request"): Code[20]
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        // P8000322A
        if GetFirstWhsePickLine(WhseReq, WhseActivityLine) then
            exit(WhseActivityLine."No.");
        exit(WhseReqPickPutAwayNo(WhseReq));
        // P8000322A
    end;

    procedure WhsePickOrder(var WhseReq: Record "Warehouse Request")
    var
        Location: Record Location;
    begin
        // P8000322A
        with WhseReq do
            if Find('-') then begin
                GetLocationRequirements("Location Code", Location);
                if Location."Require Pick" and Location."Require Shipment" then
                    PickWithWhseShipment(WhseReq, true);
            end;
        // P8000322A
    end;

    local procedure PickWithWhseShipment(var WhseReq: Record "Warehouse Request"; AlwaysCreatePick: Boolean)
    var
        PickNo: Code[20];
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseActivityHdr: Record "Warehouse Activity Header";
        ReleaseWhseShipment: Codeunit "Whse.-Shipment Release";
        WhsePick: Page "Warehouse Pick";
    begin
        // P8000322A
        if not WhseReq.Find('-') then
            exit;
        WhseReqCheckMultLocation(WhseReq);
        if not AlwaysCreatePick then
            if GetFirstWhsePickLine(WhseReq, WhseActivityLine) then
                PickNo := WhseActivityLine."No.";
        if (PickNo <> '') then
            WhseActivityHdr.Get(WhseActivityLine."Activity Type"::Pick, PickNo)
        else begin
            Clear(P800WhseActCreate);
            repeat
                // P800-MegaApp
                WarehouseShipmentHeader.Get(WhseReqShipmentNo(WhseReq));
                if WarehouseShipmentHeader.Status = WarehouseShipmentHeader.Status::Open then
                    ReleaseWhseShipment.Release(WarehouseShipmentHeader);
                // P800-MegaApp
                P800WhseActCreate.AddWhsePickWhseReq(WhseReq);
            until (WhseReq.Next = 0);
            if not P800WhseActCreate.CreateWhseReqWhsePick(WhseActivityHdr) then
                Error(Text005);
            Commit;
        end;

        WhseActivityHdr.Reset;
        WhseActivityHdr.FilterGroup(9);
        WhseActivityHdr.SetRecFilter;
        WhseActivityHdr.FilterGroup(0);
        WhsePick.RunFromOrderShipping(true);
        WhsePick.SetTableView(WhseActivityHdr);
        if IsServiceTier then // P8000828
            WhsePick.Run        // P8000828
        else                  // P8000828
            WhsePick.RunModal;
        // P8000322A
    end;

    procedure WhseReqShipmentStatus(WhseReq: Record "Warehouse Request"): Text[30]
    var
        WhseShptHeader: Record "Warehouse Shipment Header";
    begin
        // P8000322A
        if WhseShptHeader.Get(WhseReqShipmentNo(WhseReq)) then
            exit(Format(WhseShptHeader."Document Status"));
        // P8000322A
    end;

    local procedure GetFirstWhseStagedPickLine(WhseReq: Record "Warehouse Request"; var WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line"): Boolean
    var
        Location: Record Location;
    begin
        // P8000322A
        GetLocationRequirements(WhseReq."Location Code", Location);
        if not (Location."Require Pick" and Location."Require Shipment") then
            exit(false);
        with WhseStagedPickSourceLine do begin
            SetCurrentKey("Source Type", "Source Subtype", "Source No.");
            SetRange("Source Type", WhseReq."Source Type");
            SetRange("Source Subtype", WhseReq."Source Subtype");
            SetRange("Source No.", WhseReq."Source No.");
            exit(Find('-'));
        end;
        // P8000322A
    end;

    procedure WhseReqStagedPickNo(WhseReq: Record "Warehouse Request"): Code[20]
    var
        WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line";
    begin
        // P8000322A
        if GetFirstWhseStagedPickLine(WhseReq, WhseStagedPickSourceLine) then
            exit(WhseStagedPickSourceLine."No.");
        // P8000322A
    end;

    procedure WhseReqStagedPickDrillDown(WhseReq: Record "Warehouse Request")
    var
        Location: Record Location;
    begin
        // P8000322A
        with WhseReq do begin
            GetLocationRequirements("Location Code", Location);
            if Location."Require Pick" and Location."Require Shipment" then begin
                SetRecFilter;
                StagePickWithWhseShipment(WhseReq, false);
            end;
        end;
        // P8000322A
    end;

    procedure WhseStagePickOrder(var WhseReq: Record "Warehouse Request")
    var
        Location: Record Location;
    begin
        // P8000322A
        with WhseReq do
            if Find('-') then begin
                GetLocationRequirements("Location Code", Location);
                if Location."Require Pick" and Location."Require Shipment" then
                    StagePickWithWhseShipment(WhseReq, true);
            end;
        // P8000322A
    end;

    local procedure StagePickWithWhseShipment(var WhseReq: Record "Warehouse Request"; AlwaysCreatePick: Boolean)
    var
        PickNo: Code[20];
        WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line";
        WhseStagedPickHeader: Record "Whse. Staged Pick Header";
        WhseStagedPick: Page "Whse. Staged Pick";
    begin
        // P8000322A
        if not WhseReq.Find('-') then
            exit;
        WhseReqCheckMultLocation(WhseReq);
        if not AlwaysCreatePick then
            if GetFirstWhseStagedPickLine(WhseReq, WhseStagedPickSourceLine) then
                PickNo := WhseStagedPickSourceLine."No.";
        if (PickNo <> '') then
            WhseStagedPickHeader.Get(PickNo)
        else begin
            Clear(P800WhseActCreate);
            P800WhseActCreate.SetSalesSampleStaging(SalesSampleStaging);
            repeat
                P800WhseActCreate.AddStagedPickWhseReq(WhseReq);
            until (WhseReq.Next = 0);
            if not P800WhseActCreate.CreateStagedPick(WhseStagedPickHeader) then
                Error(Text006);
            Commit;
        end;

        WhseStagedPickHeader.Reset;
        WhseStagedPickHeader.FilterGroup(9);
        WhseStagedPickHeader.SetRecFilter;
        WhseStagedPickHeader.FilterGroup(0);
        WhseStagedPick.SetTableView(WhseStagedPickHeader);
        WhseStagedPick.SetRecord(WhseStagedPickHeader);  // P80051732
        if IsServiceTier then // P8000828
            WhseStagedPick.Run  // P8000828
        else                  // P8000828
            WhseStagedPick.RunModal;
        // P8000322A
    end;

    procedure SetSalesSampleStaging(NewSalesSampleStaging: Boolean)
    begin
        SalesSampleStaging := NewSalesSampleStaging; // P8000322A
    end;

    local procedure WhseReqCheckMultLocation(var WhseReq: Record "Warehouse Request")
    begin
        // P8000322A
        with WhseReq do begin
            FilterGroup(9);
            SetFilter("Location Code", '<>%1', "Location Code");
            if Find('-') then
                Error(Text002);
            SetRange("Location Code");
            FilterGroup(0);
        end;
        // P8000322A
    end;

    local procedure GetLocationRequirements(LocationCode: Code[10]; var Location: Record Location): Boolean
    var
        WhseSetup: Record "Warehouse Setup";
    begin
        // P8000322A
        if not Location.Get(LocationCode) then begin
            WhseSetup.Get;
            Location."Require Pick" := WhseSetup."Require Pick";
            Location."Require Shipment" := WhseSetup."Require Shipment";
        end;
        // P8000322A
    end;

    procedure PostSale(var SalesHeader: Record "Sales Header"; PostingDate: Date; PostingLocation: Code[10]; PrintSend: Boolean)
    var
        FoodManualSubscriptions: Codeunit "Food Manual Subscriptions";
        P800WarehouseMgmt: Codeunit "Process 800 Warehouse Mgmt.";
    begin
        // P80071657
        // P800115815
        SalesHeader.Ship := SalesHeader."Document Type" = SalesHeader."Document Type"::Order;
        SalesHeader.Receive := SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order";
        // P800115815
        SalesHeader.Invoice := false;

        SetPostingParametetrs(SalesHeader.RecordId, PostingDate);
        // P800162917
        BindSubscription(FoodManualSubscriptions);
        FoodManualSubscriptions.SetPostingLocation(PostingLocation);
        BindSubscription(P800WarehouseMgmt);
        if not PrintSend then
            SalesHeader.SendToPosting(Codeunit::"Sales-Post")
        else
            if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
                SalesHeader.SendToPosting(CODEUNIT::"Sales-Post and Send")
            else
                if SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" then
                    SalesHeader.SendToPosting(CODEUNIT::"Sales-Post + Print");
        // P800162917
        ClearPostingParameters(SalesHeader.RecordId);
    end;

    // P800162917
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post + Print", 'OnBeforeConfirmPost', '', false, false)]
    local procedure SalesPostPrint_OnBeforeConfirmPost(var HideDialog: Boolean)
    begin
        HideDialog := true;
    end;

    // P800162917
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", 'OnBeforeConfirmSalesPost', '', false, false)]
    local procedure SalesPostYesNo_OnBeforeConfirmSalesPost(var HideDialog: Boolean)
    begin
        HideDialog := true;
    end;

    procedure PostPurchase(var PurchaseHeader: Record "Purchase Header"; PostingDate: Date; PostingLocation: Code[10]; Print: Boolean)
    var
        PurchPost: Codeunit "Purch.-Post";
        PurchPostPrint: Codeunit "Purch.-Post + Print";
        FoodManualSubscriptions: Codeunit "Food Manual Subscriptions";
        P800WarehouseMgmt: Codeunit "Process 800 Warehouse Mgmt.";
    begin
        // P80071657
        // P800115815
        PurchaseHeader.Ship := PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Return Order";
        PurchaseHeader.Receive := PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order;
        // P800115815
        PurchaseHeader.Invoice := false;

        SetPostingParametetrs(PurchaseHeader.RecordId, PostingDate);
        // P800162917
        BindSubscription(FoodManualSubscriptions);
        FoodManualSubscriptions.SetPostingLocation(PostingLocation);
        BindSubscription(P800WarehouseMgmt);
        if not Print then
            PurchaseHeader.SendToPosting(Codeunit::"Purch.-Post")
        else
            PurchaseHeader.SendToPosting(CODEUNIT::"Purch.-Post + Print");
        // P800162917
        ClearPostingParameters(PurchaseHeader.RecordId);
    end;

    // P800162917
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post + Print", 'OnBeforeConfirmPost', '', false, false)]
    local procedure PurchPostPrint_OnBeforeConfirmPost(var HideDialog: Boolean)
    begin
        HideDialog := true;
    end;

    local procedure SetPostingParametetrs(RecID: RecordID; PostigDate: Date)
    var
        BatchProcessingSessionMap: Record "Batch Processing Session Map";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
    begin
        // P80071657
        // Upgrade18.0
        BatchProcessingMgt.SetParameter("Batch Posting Parameter Type"::"Posting Date", PostigDate);
        BatchProcessingMgt.SetParameter("Batch Posting Parameter Type"::"Replace Posting Date", true);
        BatchProcessingMgt.SetParameter("Batch Posting Parameter Type"::"Replace Document Date", false);

        BatchProcessingSessionMap."Record ID" := RecID;
        OnGetBatchID(BatchProcessingSessionMap."Batch ID");
        BatchProcessingSessionMap."User ID" := UserSecurityId;
        BatchProcessingSessionMap."Session ID" := SessionId;
        BatchProcessingSessionMap.Insert();

        Commit;
    end;

    local procedure ClearPostingParameters(RecID: RecordID)
    var
        BatchProcessingSessionMap: Record "Batch Processing Session Map";
        BatchProcessingParameter: Record "Batch Processing Parameter";
    begin
        // P80071657
        // Upgrade18.0
        BatchProcessingSessionMap.SetRange("Record ID", RecID);
        if BatchProcessingSessionMap.FindFirst() then begin
            BatchProcessingSessionMap.Delete();

            BatchProcessingParameter.SetRange("Batch ID", BatchProcessingSessionMap."Batch ID");
            BatchProcessingParameter.DeleteAll();

            Commit;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetBatchID(var ID: Guid)
    begin
        // P80071657
    end;
}

