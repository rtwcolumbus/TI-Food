codeunit 37002066 "N138 Change Source Doc Wizard"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // TOM4219     05-10-2105  Cleanup change line wizard
    // --------------------------------------------------------------------------------
    // 
    // PRW18.00.02
    // P8004219, To-Increase, Jack Reynolds, 05 OCT 15
    //   Preserve "Original Quantity" when changing and substituting sales/purchase line
    // 
    // P8007152, To-Increase, Dayakar Battini, 06 JUN 16
    //   Fix issue Resolve Shorts for Containers.
    // 
    // PRW19.00.01
    // P8007412, To-Increase, Dayakar Battini, 29 JUN 16
    //   Zero Qty Shipment line handling.
    // 
    // P8006916, To-Increase, Jack Reynolds, 31 AUG 16
    //   FOOD-TOM Separation
    // 
    // P8007827, To-Increase, Dayakar Battini, 11 OCT 16
    //   Change UOM for Substituted Item
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 16 JAN 17
    //   Correct misspellings
    // 
    // PRW110.0.01
    // P8008733, To-Increase, Dayakar Battini, 04 MAY 17
    //   Document status update for warehouse documents.
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW111.00.01
    // P80058334, To-Increase, Jack Reynolds, 04 MAY 18
    //   Fix problem validating new quantity on warehouse shipment line
    // 
    // PRW111.00.03
    // P80082431, To-increase, Gangabhushan, 23 SEP 19
    //   CS00075223 - Orders are removed from trips when using resolve shorts
    // 
    // PRW121.04
    // P800166568, To-Increase, Gangabhushan, 03 APR 23
    //   CS00224524 | Change Transfer Order Line function error

    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Related pick lines are deleted.';

    procedure ChangeQuantity(Source: Variant; NewQty: Decimal)
    var
        RecRef: RecordRef;
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        ServiceLine: Record "Service Line";
        WhseShipmentNo: Code[20];
    begin
        RecRef.GetTable(Source);
        case RecRef.Number of
            DATABASE::"Sales Line":
                begin
                    RecRef.SetTable(SalesLine);
                    ChangeSalesLineQty(SalesLine, NewQty, WhseShipmentNo);
                end;
            DATABASE::"Purchase Line":
                begin
                    RecRef.SetTable(PurchLine);
                    ChangePurchLineQty(PurchLine, NewQty, WhseShipmentNo); // TOM4219
                end;
            DATABASE::"Transfer Line":
                begin
                    RecRef.SetTable(TransferLine);
                    ChangeTransferLineQty(TransferLine, NewQty, WhseShipmentNo);
                end;
            DATABASE::"Service Line":
                begin
                    RecRef.SetTable(ServiceLine);
                    ChangeServiceLineQty(ServiceLine, NewQty, WhseShipmentNo);
                end;
        end;
    end;

    procedure SubstituteItem(Source: Variant; NewItem: Code[20]; SubstituteQty: Decimal; NewUOM: Code[10])
    var
        RecRef: RecordRef;
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        ServiceLine: Record "Service Line";
        TransferLine: Record "Transfer Line";
    begin
        RecRef.GetTable(Source);
        case RecRef.Number of
            DATABASE::"Sales Line":
                begin
                    RecRef.SetTable(SalesLine);
                    if (SalesLine."No." = NewItem) and (SalesLine."Unit of Measure Code" = NewUOM) then  // P8007827
                        ChangeQuantity(SalesLine, SubstituteQty)                       // P8007827
                    else                                                            // P8007827
                        SubstituteSalesLine(SalesLine, NewItem, SubstituteQty, NewUOM);  // P8007827
                end;
            DATABASE::"Purchase Line":
                begin
                    RecRef.SetTable(PurchLine); // P800166568
                    if (PurchLine."No." = NewItem) and (PurchLine."Unit of Measure Code" = NewUOM) then  // P8007827
                        ChangeQuantity(PurchLine, SubstituteQty)                       // P8007827
                    else                                                            // P8007827
                        SubstitutePurchLine(PurchLine, NewItem, SubstituteQty, NewUOM);  // P8007827
                end;
            DATABASE::"Transfer Line":
                begin
                    RecRef.SetTable(TransferLine); // P800166568
                    if (TransferLine."Item No." = NewItem) and (TransferLine."Unit of Measure Code" = NewUOM) then  // P8007827
                        ChangeQuantity(TransferLine, SubstituteQty)                          // P8007827
                    else                                                                  // P8007827
                        SubstituteTransferLine(TransferLine, NewItem, SubstituteQty, NewUOM);  // P8007827
                end;
            DATABASE::"Service Line":
                begin
                    RecRef.SetTable(ServiceLine); // P800166568
                    if (ServiceLine."No." = NewItem) and (ServiceLine."Unit of Measure Code" = NewUOM) then  // P8007827
                        ChangeQuantity(ServiceLine, SubstituteQty)                         // P8007827
                    else                                                                // P8007827
                        SubstituteServiceLine(ServiceLine, NewItem, SubstituteQty, NewUOM);  // P8007827
                end;
        end;
    end;

    local procedure ChangeSalesLineQty(SalesLine: Record "Sales Line"; NewQty: Decimal; var WhseShipment: Code[20])
    var
        WhseValidateSourceLine: Codeunit "Whse. Validate Source Line";
        ChangeShipmentLine: Boolean;
        WhseShptLine: Record "Warehouse Shipment Line";
        ReleaseOrder: Boolean;
        ReleaseWhseShip: Boolean;
        ChangeShipment: Boolean;
        TotalOutstandingWhseShptQty: Decimal;
        TotalOutstandingWhseShptQtyBase: Decimal;
        OriginalQuantity: Decimal;
    begin
        with SalesLine do begin
            ReleaseOrder := ReOpenSlsOrder(SalesLine);

            WhseShptLine.SetCurrentKey(
              "Source Type", "Source Subtype", "Source No.", "Source Line No.");
            WhseShptLine.SetRange("Source Type", DATABASE::"Sales Line");
            WhseShptLine.SetRange("Source Subtype", "Document Type");
            WhseShptLine.SetRange("Source No.", "Document No.");
            WhseShptLine.SetRange("Source Line No.", "Line No.");

            if WhseShptLine.FindFirst then begin
                ChangeShipment := true;
                WhseShipment := WhseShptLine."No.";
                if WhseShptLine."Pick Qty." = 0 then
                    SalesLine.SkipWhseQtyCheck;
            end;

            OriginalQuantity := "Original Quantity"; // P8004219
            ChangeSlsTrackingInformation(SalesLine, NewQty);
            "Allow Quantity Change" := true;         // P8007152
            Validate(Quantity, NewQty);
            "Original Quantity" := OriginalQuantity; // P8004219
            "Allow Quantity Change" := false;         // P8007152
            Modify(true);
            if ReleaseOrder then ReleaseSlsOrder(SalesLine);

            if ChangeShipment then begin
                ReleaseWhseShip := ReOpenWhseShipment(WhseShptLine);
                SalesLine.CalcFields("Whse. Outstanding Qty.", "Whse. Outstanding Qty. (Base)");
                TotalOutstandingWhseShptQty := Abs(SalesLine."Outstanding Quantity") - SalesLine."Whse. Outstanding Qty." + WhseShptLine."Qty. Outstanding";
                TotalOutstandingWhseShptQtyBase := Abs(SalesLine."Outstanding Qty. (Base)") - SalesLine."Whse. Outstanding Qty. (Base)" + WhseShptLine."Qty. Outstanding (Base)";

                // P8007412
                if TotalOutstandingWhseShptQty = 0 then
                    WhseShptLine.Delete(true)
                else begin
                    // P8007412
                    WhseShptLine.Quantity := TotalOutstandingWhseShptQty;
                    WhseShptLine."Qty. (Base)" := TotalOutstandingWhseShptQtyBase;
                    WhseShptLine.InitOutstandingQtys; // P80058334
                                                      // P8008733
                    WhseShptLine.Validate(Quantity);
                    WhseShptLine.Validate("Qty. (Base)");
                    // P8008733
                    WhseShptLine.Modify(true);
                    if ReleaseWhseShip then ReleaseWhseShipment(WhseShptLine);
                end;           // P8007412
            end;
        end;
    end;

    local procedure SubstituteSalesLine(SalesLine: Record "Sales Line"; NewItem: Code[20]; SubstituteQty: Decimal; NewUOM: Code[10])
    var
        NewSalesLine: Record "Sales Line";
        NewLineNo: Integer;
        ReleaseOrder: Boolean;
        WhseShipmentNo: Code[20];
    begin
        ReleaseOrder := ReOpenSlsOrder(SalesLine);

        NewSalesLine.SetRange("Document Type", SalesLine."Document Type");
        NewSalesLine.SetRange("Document No.", SalesLine."Document No.");
        NewSalesLine.SetFilter("Line No.", '>%1', SalesLine."Line No.");
        if NewSalesLine.FindFirst then begin
            NewLineNo := SalesLine."Line No." + ((NewSalesLine."Line No." - SalesLine."Line No.") div 2);
        end else begin
            NewLineNo := SalesLine."Line No." + 10000;
        end;

        NewSalesLine.SetShortSubstituteItem();   // P8007152
        NewSalesLine."Document Type" := SalesLine."Document Type";
        NewSalesLine."Document No." := SalesLine."Document No.";
        NewSalesLine."Line No." := NewLineNo;
        NewSalesLine.Validate(Type, NewSalesLine.Type::Item);
        NewSalesLine.Validate("No.", NewItem);
        NewSalesLine.Validate("Location Code", SalesLine."Location Code");
        NewSalesLine."Unit Price" := SalesLine."Unit Price";
        if NewUOM <> '' then                                     // P8007827
            NewSalesLine.Validate("Unit of Measure Code", NewUOM);  // P8007827
        NewSalesLine.Validate(Quantity, SubstituteQty);
        NewSalesLine."Original Quantity" := 0; // P8004219
        NewSalesLine.Insert(true);

        // P8007827
        if SalesLine."Unit of Measure Code" <> NewUOM then
            ChangeSalesLineQty(SalesLine, 0, WhseShipmentNo)  // Old line qty will be made zero for consistency.
        else
            ChangeSalesLineQty(SalesLine, SalesLine.Quantity - SubstituteQty, WhseShipmentNo);
        // P8007827

        if ReleaseOrder then ReleaseSlsOrder(SalesLine);

        if WhseShipmentNo <> '' then
            LinkSalesline2WhseShip(WhseShipmentNo, NewSalesLine);
    end;

    local procedure LinkSalesline2WhseShip(WhseShipmentNo: Code[20]; NewSalesLine: Record "Sales Line")
    var
        WhseShptHdr: Record "Warehouse Shipment Header";
        WhseRqst: Record "Warehouse Request";
        GetSourceDocuments: Report "Get Source Documents";
    begin
        WhseShptHdr.Get(WhseShipmentNo);

        WhseRqst.SetRange(Type, WhseRqst.Type::Outbound);
        WhseRqst.SetRange("Source Type", DATABASE::"Sales Line");
        WhseRqst.SetRange("Source Subtype", NewSalesLine."Document Type");
        WhseRqst.SetRange("Source No.", NewSalesLine."Document No.");
        WhseRqst.SetRange("Location Code", NewSalesLine."Location Code");
        WhseRqst.SetRange("Document Status", WhseRqst."Document Status"::Released);
        if WhseRqst.FindFirst then begin
            GetSourceDocuments.SetOneCreatedShptHeader(WhseShptHdr);
            GetSourceDocuments.SetTableView(WhseRqst);
            GetSourceDocuments.SetTableView(NewSalesLine);
            GetSourceDocuments.SetHideDialog(true); // TOM4219
            GetSourceDocuments.UseRequestPage(false);
            GetSourceDocuments.RunModal;
        end;
    end;

    local procedure ReOpenSlsOrder(SalesLine: Record "Sales Line") ReleaseOrder: Boolean
    var
        SalesHeader: Record "Sales Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        if SalesHeader.Status <> SalesHeader.Status::Open then begin
            ReleaseSalesDoc.PerformManualReopen(SalesHeader);
            ReleaseOrder := true;
        end;
    end;

    local procedure ReleaseSlsOrder(SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        SalesLine2: Record "Sales Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");

        SalesLine2.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine2.SetRange("Document No.", SalesHeader."No.");
        SalesLine2.SetFilter(Type, '>0');
        SalesLine2.SetFilter(Quantity, '<>0');

        if SalesLine2.Find('-') then begin // P80082431
            ReleaseSalesDoc.SetDeliveryTrip(GetDeliveryTrip(SalesLine2)); // P80082431
            ReleaseSalesDoc.PerformManualRelease(SalesHeader);
        end; // P80082431
    end;

    local procedure ChangeSlsTrackingInformation(SalesLine: Record "Sales Line"; NewQty: Decimal)
    var
        SalesLineReserve: Codeunit "Sales Line-Reserve";
        ReservationEntry: Record "Reservation Entry";
    begin
        SalesLine.SetReservationFilters(ReservationEntry); // P800131478
        if ReservationEntry.Count = 1 then begin
            ReservationEntry.FindFirst;
            ReservationEntry.Validate("Quantity (Base)", -NewQty);
            ReservationEntry.Modify(true);
        end;
    end;

    local procedure ChangePurchLineQty(PurchLine: Record "Purchase Line"; NewQty: Decimal; var WhseShipment: Code[20])
    var
        WhseValidateSourceLine: Codeunit "Whse. Validate Source Line";
        ChangeShipmentLine: Boolean;
        WhseShptLine: Record "Warehouse Shipment Line";
        ReleaseOrder: Boolean;
        ReleaseWhseShip: Boolean;
        ChangeShipment: Boolean;
        TotalOutstandingWhseShptQty: Decimal;
        TotalOutstandingWhseShptQtyBase: Decimal;
        OriginalQuantity: Decimal;
    begin
        with PurchLine do begin
            ReleaseOrder := ReOpenPurchOrder(PurchLine);

            WhseShptLine.SetCurrentKey(
              "Source Type", "Source Subtype", "Source No.", "Source Line No.");
            WhseShptLine.SetRange("Source Type", DATABASE::"Purchase Line");
            WhseShptLine.SetRange("Source Subtype", "Document Type");
            WhseShptLine.SetRange("Source No.", "Document No.");
            WhseShptLine.SetRange("Source Line No.", "Line No.");

            if WhseShptLine.FindFirst then begin
                ChangeShipment := true;
                WhseShipment := WhseShptLine."No.";
                if WhseShptLine."Pick Qty." = 0 then
                    PurchLine.SkipWhseQtyCheck;
            end;

            OriginalQuantity := "Original Quantity"; // P8004219
            ChangePurTrackingInformation(PurchLine, NewQty);
            Validate(Quantity, NewQty);
            "Original Quantity" := OriginalQuantity; // P8004219
            Modify(true);
            if ReleaseOrder then ReleasePurchOrder(PurchLine);

            if ChangeShipment then begin
                ReleaseWhseShip := ReOpenWhseShipment(WhseShptLine);
                TotalOutstandingWhseShptQty := Abs(PurchLine."Outstanding Quantity");
                TotalOutstandingWhseShptQtyBase := Abs(PurchLine."Outstanding Qty. (Base)");

                // P8007412
                if TotalOutstandingWhseShptQty = 0 then
                    WhseShptLine.Delete(true)
                else begin
                    // P8007412
                    WhseShptLine.Quantity := TotalOutstandingWhseShptQty;
                    WhseShptLine."Qty. (Base)" := TotalOutstandingWhseShptQtyBase;
                    WhseShptLine.InitOutstandingQtys;
                    WhseShptLine.Modify(true);
                    if ReleaseWhseShip then ReleaseWhseShipment(WhseShptLine);
                end;           // P8007412
                if ReleaseWhseShip then ReleaseWhseShipment(WhseShptLine);
            end;
        end;
    end;

    local procedure SubstitutePurchLine(PurchLine: Record "Purchase Line"; NewItem: Code[20]; SubstituteQty: Decimal; NewUOM: Code[10])
    var
        NewPurchLine: Record "Purchase Line";
        NewLineNo: Integer;
        ReleaseOrder: Boolean;
        WhseShipmentNo: Code[20];
    begin
        ReleaseOrder := ReOpenPurchOrder(PurchLine);

        NewPurchLine.SetRange("Document Type", PurchLine."Document Type");
        NewPurchLine.SetRange("Document No.", PurchLine."Document No.");
        NewPurchLine.SetFilter("Line No.", '>%1', PurchLine."Line No.");
        if NewPurchLine.FindFirst then begin
            NewLineNo := PurchLine."Line No." + ((NewPurchLine."Line No." - PurchLine."Line No.") div 2);
        end else begin
            NewLineNo := PurchLine."Line No." + 10000;
        end;

        NewPurchLine."Document Type" := PurchLine."Document Type";
        NewPurchLine."Document No." := PurchLine."Document No.";
        NewPurchLine."Line No." := NewLineNo;
        NewPurchLine.Validate(Type, NewPurchLine.Type::Item);
        NewPurchLine.Validate("No.", NewItem);
        NewPurchLine.Validate("Location Code", PurchLine."Location Code");
        NewPurchLine.Validate("Direct Unit Cost", PurchLine."Direct Unit Cost");
        NewPurchLine.Validate("Unit of Measure Code", NewUOM);  // P8007827
        NewPurchLine.Validate(Quantity, SubstituteQty);
        NewPurchLine."Original Quantity" := 0; // P8004219
        NewPurchLine.Insert(true);

        ChangePurchLineQty(PurchLine, PurchLine.Quantity - SubstituteQty, WhseShipmentNo); // TOM44219

        if ReleaseOrder then ReleasePurchOrder(PurchLine);

        if WhseShipmentNo <> '' then                           // TOM4219
            LinkPurchline2WhseShip(WhseShipmentNo, NewPurchLine); // TOM4219
    end;

    local procedure LinkPurchline2WhseShip(WhseShipmentNo: Code[20]; NewPurchLine: Record "Purchase Line")
    var
        WhseShptHdr: Record "Warehouse Shipment Header";
        WhseRqst: Record "Warehouse Request";
        GetSourceDocuments: Report "Get Source Documents";
    begin
        // TOM4219
        WhseShptHdr.Get(WhseShipmentNo);

        WhseRqst.SetRange(Type, WhseRqst.Type::Outbound);
        WhseRqst.SetRange("Source Type", DATABASE::"Purchase Line");
        WhseRqst.SetRange("Source Subtype", NewPurchLine."Document Type");
        WhseRqst.SetRange("Source No.", NewPurchLine."Document No.");
        WhseRqst.SetRange("Location Code", NewPurchLine."Location Code");
        WhseRqst.SetRange("Document Status", WhseRqst."Document Status"::Released);
        if WhseRqst.FindFirst then begin
            GetSourceDocuments.SetOneCreatedShptHeader(WhseShptHdr);
            GetSourceDocuments.SetTableView(WhseRqst);
            GetSourceDocuments.SetTableView(NewPurchLine);
            GetSourceDocuments.SetHideDialog(true);
            GetSourceDocuments.UseRequestPage(false);
            GetSourceDocuments.RunModal;
        end;
    end;

    local procedure ReOpenPurchOrder(var PurchLine: Record "Purchase Line") ReleaseOrder: Boolean
    var
        PurchHeader: Record "Purchase Header";
        ReleasePurchDoc: Codeunit "Release Purchase Document";
    begin
        PurchHeader.Get(PurchLine."Document Type", PurchLine."Document No.");
        if PurchHeader.Status <> PurchHeader.Status::Open then begin
            ReleasePurchDoc.PerformManualReopen(PurchHeader);
            ReleaseOrder := true;
            //ReOpen is changing the purch line
            PurchLine.Find;
        end;
    end;

    local procedure ReleasePurchOrder(var PurchLine: Record "Purchase Line")
    var
        PurchHeader: Record "Purchase Header";
        PurchaseLine2: Record "Purchase Line";
        ReleasePurchDoc: Codeunit "Release Purchase Document";
    begin
        PurchHeader.Get(PurchLine."Document Type", PurchLine."Document No.");

        PurchaseLine2.SetRange("Document Type", PurchHeader."Document Type");
        PurchaseLine2.SetRange("Document No.", PurchHeader."No.");
        PurchaseLine2.SetFilter(Type, '>0');
        PurchaseLine2.SetFilter(Quantity, '<>0');

        if PurchaseLine2.Find('-') then
            ReleasePurchDoc.PerformManualRelease(PurchHeader);
    end;

    local procedure ChangePurTrackingInformation(PurchaseLine: Record "Purchase Line"; NewQty: Decimal)
    var
        PurchLineReserve: Codeunit "Purch. Line-Reserve";
        ReservationEntry: Record "Reservation Entry";
    begin
        PurchaseLine.SetReservationFilters(ReservationEntry); // P800131478
        if ReservationEntry.Count = 1 then begin
            ReservationEntry.FindFirst;
            ReservationEntry.Validate("Quantity (Base)", -NewQty);
            ReservationEntry.Modify(true);
        end;
    end;

    local procedure ChangeTransferLineQty(TransferLine: Record "Transfer Line"; NewQty: Decimal; var WhseShipment: Code[20])
    var
        WhseValidateSourceLine: Codeunit "Whse. Validate Source Line";
        ChangeShipmentLine: Boolean;
        WhseShptLine: Record "Warehouse Shipment Line";
        ReleaseOrder: Boolean;
        ReleaseWhseShip: Boolean;
        ChangeShipment: Boolean;
        TotalOutstandingWhseShptQty: Decimal;
        TotalOutstandingWhseShptQtyBase: Decimal;
    begin
        with TransferLine do begin
            ReleaseOrder := ReOpenTransferOrder(TransferLine);

            WhseShptLine.SetCurrentKey(
              "Source Type", "Source Subtype", "Source No.", "Source Line No.");
            WhseShptLine.SetRange("Source Type", DATABASE::"Transfer Line");
            WhseShptLine.SetRange("Source Subtype", 0);
            WhseShptLine.SetRange("Source No.", "Document No.");
            WhseShptLine.SetRange("Source Line No.", "Line No.");

            if WhseShptLine.FindFirst then begin
                ChangeShipment := true;
                WhseShipment := WhseShptLine."No.";
                if WhseShptLine."Pick Qty." = 0 then
                    TransferLine.SkipWhseQtyCheck;
            end;

            ChangeTransferTrackingInformation(TransferLine, NewQty);
            Validate(Quantity, NewQty);
            Modify(true);
            if ReleaseOrder then ReleaseTransferOrder(TransferLine);

            if ChangeShipment then begin
                ReleaseWhseShip := ReOpenWhseShipment(WhseShptLine);
                TotalOutstandingWhseShptQty := Abs(TransferLine."Outstanding Quantity");
                TotalOutstandingWhseShptQtyBase := Abs(TransferLine."Outstanding Qty. (Base)");

                // P8007412
                if TotalOutstandingWhseShptQty = 0 then
                    WhseShptLine.Delete(true)
                else begin
                    // P8007412
                    WhseShptLine.Quantity := TotalOutstandingWhseShptQty;
                    WhseShptLine."Qty. (Base)" := TotalOutstandingWhseShptQtyBase;
                    WhseShptLine.InitOutstandingQtys;
                    WhseShptLine.Modify(true);
                    if ReleaseWhseShip then ReleaseWhseShipment(WhseShptLine);
                end;           // P8007412
            end;
        end;
    end;

    local procedure SubstituteTransferLine(TransferLine: Record "Transfer Line"; NewItem: Code[20]; SubstituteQty: Decimal; NewUOM: Code[10])
    var
        NewTransferLine: Record "Transfer Line";
        NewLineNo: Integer;
        ReleaseOrder: Boolean;
        WhseShipmentNo: Code[20];
    begin
        ReleaseOrder := ReOpenTransferOrder(TransferLine);

        NewTransferLine.SetRange("Document No.", TransferLine."Document No.");
        NewTransferLine.SetFilter("Line No.", '>%1', TransferLine."Line No.");
        if NewTransferLine.FindFirst then begin
            NewLineNo := TransferLine."Line No." + ((NewTransferLine."Line No." - TransferLine."Line No.") div 2);
        end else begin
            NewLineNo := TransferLine."Line No." + 10000;
        end;

        NewTransferLine."Document No." := TransferLine."Document No.";
        NewTransferLine."Line No." := NewLineNo;
        NewTransferLine.Validate("Item No.", NewItem);
        NewTransferLine.Validate("Transfer-from Code", TransferLine."Transfer-from Code");
        NewTransferLine.Validate("Unit of Measure Code", NewUOM);  // P8007827
        NewTransferLine.Validate(Quantity, SubstituteQty);
        NewTransferLine.Insert(true);

        ChangeTransferLineQty(TransferLine, TransferLine.Quantity - SubstituteQty, WhseShipmentNo);

        if ReleaseOrder then ReleaseTransferOrder(TransferLine);

        if WhseShipmentNo <> '' then
            LinkTransfer2WhseShip(WhseShipmentNo, NewTransferLine);
    end;

    local procedure LinkTransfer2WhseShip(WhseShipmentNo: Code[20]; NewTransferLine: Record "Transfer Line")
    var
        TransferHeader: Record "Transfer Header";
        WhseShptHdr: Record "Warehouse Shipment Header";
        WhseRqst: Record "Warehouse Request";
        GetSourceDocuments: Report "Get Source Documents";
    begin
        WhseShptHdr.Get(WhseShipmentNo);

        WhseRqst.SetRange(Type, WhseRqst.Type::Outbound);
        WhseRqst.SetRange("Source Type", DATABASE::"Transfer Line");
        WhseRqst.SetRange("Source Subtype", 0);
        WhseRqst.SetRange("Source No.", NewTransferLine."Document No.");
        WhseRqst.SetRange("Location Code", NewTransferLine."Transfer-from Code");
        WhseRqst.SetRange("Document Status", WhseRqst."Document Status"::Released);
        if WhseRqst.FindFirst then begin
            GetSourceDocuments.SetOneCreatedShptHeader(WhseShptHdr);
            GetSourceDocuments.SetTableView(WhseRqst);
            GetSourceDocuments.SetTableView(NewTransferLine);
            GetSourceDocuments.SetHideDialog(true); // TOM4219
            GetSourceDocuments.UseRequestPage(false);
            GetSourceDocuments.RunModal;
        end;
    end;

    local procedure ReOpenTransferOrder(var TransferLine: Record "Transfer Line") ReleaseOrder: Boolean
    var
        TransferHeader: Record "Transfer Header";
        ReleaseTransferDoc: Codeunit "Release Transfer Document";
    begin
        TransferHeader.Get(TransferLine."Document No.");
        if TransferHeader.Status <> TransferHeader.Status::Open then begin
            ReleaseTransferDoc.Reopen(TransferHeader);
            ReleaseOrder := true;

            //ReOpen is changing the TransferLine
            TransferLine.Find;

        end;
    end;

    local procedure ReleaseTransferOrder(TransferLine: Record "Transfer Line")
    var
        TransferHeader: Record "Transfer Header";
        TransLine2: Record "Transfer Line";
        ReleaseTransferDoc: Codeunit "Release Transfer Document";
    begin
        TransferHeader.Get(TransferLine."Document No.");

        TransLine2.SetRange("Document No.", TransferHeader."No.");
        TransLine2.SetFilter(Quantity, '<>0');

        if TransLine2.FindFirst then
            ReleaseTransferDoc.Run(TransferHeader);
    end;

    local procedure ChangeTransferTrackingInformation(TransferLine: Record "Transfer Line"; NewQty: Decimal)
    var
        TransferLineReserve: Codeunit "Transfer Line-Reserve";
        ReservationEntry: Record "Reservation Entry";
    begin
        TransferLine.SetReservationFilters(ReservationEntry, "Transfer Direction"::Outbound); // P800131478
        if ReservationEntry.Count = 1 then begin
            ReservationEntry.FindFirst;
            ReservationEntry.Validate("Quantity (Base)", -NewQty);
            ReservationEntry.Modify(true);
        end;
    end;

    local procedure ChangeServiceLineQty(ServiceLine: Record "Service Line"; NewQty: Decimal; var WhseShipment: Code[20])
    var
        WhseValidateSourceLine: Codeunit "Whse. Validate Source Line";
        ChangeShipmentLine: Boolean;
        WhseShptLine: Record "Warehouse Shipment Line";
        ReleaseOrder: Boolean;
        ReleaseWhseShip: Boolean;
        ChangeShipment: Boolean;
        TotalOutstandingWhseShptQty: Decimal;
        TotalOutstandingWhseShptQtyBase: Decimal;
    begin
        with ServiceLine do begin
            ReleaseOrder := ReOpenServiceOrder(ServiceLine);

            WhseShptLine.SetCurrentKey(
              "Source Type", "Source Subtype", "Source No.", "Source Line No.");
            WhseShptLine.SetRange("Source Type", DATABASE::"Service Line");
            WhseShptLine.SetRange("Source Subtype", ServiceLine."Document Type");
            WhseShptLine.SetRange("Source No.", "Document No.");
            WhseShptLine.SetRange("Source Line No.", "Line No.");

            if WhseShptLine.FindFirst then begin
                ChangeShipment := true;
                WhseShipment := WhseShptLine."No.";
            end;

            ChangeServiceTrackingInformation(ServiceLine, NewQty);
            Validate(Quantity, NewQty);
            Modify(true);
            if ReleaseOrder then ReleaseServiceOrder(ServiceLine);

            if ChangeShipment then begin
                ReleaseWhseShip := ReOpenWhseShipment(WhseShptLine);
                TotalOutstandingWhseShptQty := Abs(ServiceLine."Outstanding Quantity");
                TotalOutstandingWhseShptQtyBase := Abs(ServiceLine."Outstanding Qty. (Base)");

                // P8007412
                if TotalOutstandingWhseShptQty = 0 then
                    WhseShptLine.Delete(true)
                else begin
                    // P8007412
                    WhseShptLine.Quantity := TotalOutstandingWhseShptQty;
                    WhseShptLine."Qty. (Base)" := TotalOutstandingWhseShptQtyBase;
                    WhseShptLine.InitOutstandingQtys;
                    WhseShptLine.Modify(true);
                    if ReleaseWhseShip then ReleaseWhseShipment(WhseShptLine);
                end;           // P8007412
            end;
        end;
    end;

    local procedure SubstituteServiceLine(ServiceLine: Record "Service Line"; NewItem: Code[20]; SubstituteQty: Decimal; NewUOM: Code[10])
    var
        NewServiceLine: Record "Service Line";
        NewLineNo: Integer;
        ReleaseOrder: Boolean;
        WhseShipmentNo: Code[20];
    begin
        ReleaseOrder := ReOpenServiceOrder(ServiceLine);

        NewServiceLine.SetRange("Document No.", ServiceLine."Document No.");
        NewServiceLine.SetFilter("Line No.", '>%1', ServiceLine."Line No.");
        if NewServiceLine.FindFirst then begin
            NewLineNo := ServiceLine."Line No." + ((NewServiceLine."Line No." - ServiceLine."Line No.") div 2);
        end else begin
            NewLineNo := ServiceLine."Line No." + 10000;
        end;

        NewServiceLine."Document No." := ServiceLine."Document No.";
        NewServiceLine."Line No." := NewLineNo;
        ServiceLine.SetRange(Type, ServiceLine.Type::Item);
        NewServiceLine.Validate("No.", ServiceLine."No.");

        NewServiceLine.Validate("Location Code", ServiceLine."Location Code");
        NewServiceLine.Validate("Unit of Measure Code", NewUOM);  // P8007827
        NewServiceLine.Validate(Quantity, SubstituteQty);
        NewServiceLine.Insert(true);

        ChangeServiceLineQty(ServiceLine, ServiceLine.Quantity - SubstituteQty, WhseShipmentNo);

        if ReleaseOrder then ReleaseServiceOrder(ServiceLine);

        if WhseShipmentNo <> '' then
            LinkService2WhseShip(WhseShipmentNo, NewServiceLine);
    end;

    local procedure LinkService2WhseShip(WhseShipmentNo: Code[20]; NewServiceLine: Record "Service Line")
    var
        ServiceHeader: Record "Transfer Header";
        WhseShptHdr: Record "Warehouse Shipment Header";
        WhseRqst: Record "Warehouse Request";
        GetSourceDocuments: Report "Get Source Documents";
    begin
        WhseShptHdr.Get(WhseShipmentNo);

        WhseRqst.SetRange(Type, WhseRqst.Type::Outbound);
        WhseRqst.SetRange("Source Type", DATABASE::"Service Line");
        WhseRqst.SetRange("Source Subtype", 0);
        WhseRqst.SetRange("Source No.", NewServiceLine."Document No.");
        WhseRqst.SetRange("Location Code", NewServiceLine."Location Code");
        WhseRqst.SetRange("Document Status", WhseRqst."Document Status"::Released);
        if WhseRqst.FindFirst then begin
            GetSourceDocuments.SetOneCreatedShptHeader(WhseShptHdr);
            GetSourceDocuments.SetTableView(WhseRqst);
            GetSourceDocuments.SetTableView(NewServiceLine);
            GetSourceDocuments.SetHideDialog(true); // TOM4219
            GetSourceDocuments.UseRequestPage(false);
            GetSourceDocuments.RunModal;
        end;
    end;

    local procedure ReOpenServiceOrder(var ServiceLine: Record "Service Line") ReleaseOrder: Boolean
    var
        ServiceHeader: Record "Service Header";
        ReleaseServiceDoc: Codeunit "Release Service Document";
    begin
        ServiceHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.");
        if ServiceHeader."Release Status" <> ServiceHeader."Release Status"::Open then begin
            ReleaseServiceDoc.Reopen(ServiceHeader);
            ReleaseOrder := true;

            //ReOpen is changing the ServiceLine
            ServiceLine.Find;
        end;
    end;

    local procedure ReleaseServiceOrder(ServiceLine: Record "Service Line")
    var
        ServiceHeader: Record "Service Header";
        ServLine2: Record "Service Line";
        ReleaseServiceDoc: Codeunit "Release Service Document";
    begin
        ServiceHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.");

        ServLine2.SetRange("Document Type", ServiceHeader."Document Type");
        ServLine2.SetRange("Document No.", ServiceHeader."No.");
        ServLine2.SetFilter(Type, '<>%1', ServLine2.Type::" ");
        ServLine2.SetFilter(Quantity, '<>0');

        if ServLine2.Find then
            ReleaseServiceDoc.Run(ServiceHeader);
    end;

    local procedure ChangeServiceTrackingInformation(ServiceLine: Record "Service Line"; NewQty: Decimal)
    var
        ServiceLineReserve: Codeunit "Service Line-Reserve";
        ReservationEntry: Record "Reservation Entry";
    begin
        ServiceLine.SetReservationFilters(ReservationEntry); // P800131478
        if ReservationEntry.Count = 1 then begin
            ReservationEntry.FindFirst;
            ReservationEntry.Validate("Quantity (Base)", -NewQty);
            ReservationEntry.Modify(true);
        end;
    end;

    local procedure ReOpenWhseShipment(WhseShptLine: Record "Warehouse Shipment Line") ReleaseOrder: Boolean
    var
        WhseShptHdr: Record "Warehouse Shipment Header";
        ReleaseWhseShptDoc: Codeunit "Whse.-Shipment Release";
    begin
        WhseShptHdr.Get(WhseShptLine."No.");
        if WhseShptHdr.Status <> WhseShptHdr.Status::Open then begin
            ReleaseWhseShptDoc.AddWhseActivLineFilter(Format(WhseShptLine."Line No."));
            ReleaseWhseShptDoc.Reopen(WhseShptHdr);
            ReleaseOrder := true;
        end;
    end;

    local procedure ReleaseWhseShipment(WhseShptLine: Record "Warehouse Shipment Line")
    var
        WhseShptHdr: Record "Warehouse Shipment Header";
        ReleaseWhseShptDoc: Codeunit "Whse.-Shipment Release";
    begin
        WhseShptHdr.Get(WhseShptLine."No.");
        WhseShptHdr.UpdateDocumentStatus;  // P8008733
        ReleaseWhseShptDoc.Release(WhseShptHdr);
    end;

    procedure GetNewUOMQty(Source: Variant; SourceUOM: Code[10]; NewItem: Code[20]; var NewUOM: Code[10]): Decimal
    var
        RecRef: RecordRef;
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        ServiceLine: Record "Service Line";
        TransferLine: Record "Transfer Line";
    begin
        RecRef.GetTable(Source);
        case RecRef.Number of
            DATABASE::"Sales Line":
                begin
                    RecRef.SetTable(SalesLine);
                    SourceUOM := SalesLine."Unit of Measure Code";
                    exit(GetQuantity(SalesLine."No.", SourceUOM, NewItem, NewUOM, SalesLine.Quantity));
                end;
            DATABASE::"Purchase Line":
                begin
                    RecRef.SetTable(PurchLine);
                    SourceUOM := PurchLine."Unit of Measure Code";
                    exit(GetQuantity(PurchLine."No.", SourceUOM, NewItem, NewUOM, PurchLine.Quantity));
                end;
            DATABASE::"Transfer Line":
                begin
                    RecRef.SetTable(TransferLine);
                    SourceUOM := TransferLine."Unit of Measure Code";
                    exit(GetQuantity(TransferLine."Item No.", SourceUOM, NewItem, NewUOM, TransferLine.Quantity));
                end;
            DATABASE::"Service Line":
                begin
                    RecRef.SetTable(ServiceLine);
                    SourceUOM := ServiceLine."Unit of Measure Code";
                    exit(GetQuantity(ServiceLine."No.", SourceUOM, NewItem, NewUOM, ServiceLine.Quantity));
                end;
        end;
    end;

    local procedure GetQuantity(SourceItem: Code[20]; SourceUOM: Code[10]; NewItem: Code[20]; var NewUOM: Code[10]; Qty: Decimal): Decimal
    var
        SourceItemUOM: Record "Item Unit of Measure";
        NewItemUOM: Record "Item Unit of Measure";
        Factor: Decimal;
    begin
        if (SourceItem = NewItem) and (NewUOM = '') then
            NewUOM := SourceUOM;

        if not NewItemUOM.Get(NewItem, NewUOM) then begin
            NewUOM := '';
            Clear(NewItemUOM);
        end;
        SourceItemUOM.Get(SourceItem, SourceUOM);

        if (NewItemUOM."Qty. per Unit of Measure" <> 0) and (SourceItem = NewItem) then
            Factor := SourceItemUOM."Qty. per Unit of Measure" / NewItemUOM."Qty. per Unit of Measure";
        exit(Round(Qty * Factor, 0.00001));
    end;

    procedure GetSourceUOM(Source: Variant; var SourceItem: Code[20]; var SourceUOM: Code[10])
    var
        RecRef: RecordRef;
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        ServiceLine: Record "Service Line";
        TransferLine: Record "Transfer Line";
    begin
        RecRef.GetTable(Source);
        case RecRef.Number of
            DATABASE::"Sales Line":
                begin
                    RecRef.SetTable(SalesLine);
                    SourceUOM := SalesLine."Unit of Measure Code";
                    SourceItem := SalesLine."No.";
                end;
            DATABASE::"Purchase Line":
                begin
                    RecRef.SetTable(PurchLine);
                    SourceUOM := PurchLine."Unit of Measure Code";
                    SourceItem := PurchLine."No.";
                end;
            DATABASE::"Transfer Line":
                begin
                    RecRef.SetTable(TransferLine);
                    SourceUOM := TransferLine."Unit of Measure Code";
                    SourceItem := TransferLine."Item No.";
                end;
            DATABASE::"Service Line":
                begin
                    RecRef.SetTable(ServiceLine);
                    SourceUOM := ServiceLine."Unit of Measure Code";
                    SourceItem := ServiceLine."No.";
                end;
        end;
    end;

    local procedure GetDeliveryTrip(SalesLine: Record "Sales Line"): Code[20]
    var
        WarehouseRequest: Record "Warehouse Request";
        WhseType: Option Inbound,Outbound;
    begin
        // P80082431
        with SalesLine do begin
            if (("Document Type" = "Document Type"::Order) and (SalesLine.Quantity >= 0)) or
               (("Document Type" = "Document Type"::"Return Order") and (SalesLine.Quantity < 0))
            then
                WhseType := WhseType::Outbound
            else
                WhseType := WhseType::Inbound;

            if WarehouseRequest.Get(WhseType, "Location Code", DATABASE::"Sales Line", "Document Type", "Document No.") then
                exit(WarehouseRequest."Delivery Trip");
        end;
    end;
}

