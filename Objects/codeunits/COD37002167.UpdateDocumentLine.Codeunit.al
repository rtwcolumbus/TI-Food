codeunit 37002167 "Update Document Line"
{
    // PRW110.0.02
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80057995, To Increase, Jack Reynolds, 12 JUN 18
    //   Fix issues with fixed weight items
    // 
    // PRW111.00.02
    // P80068216, To Increase, Jack Reynolds, 10 DEC 18
    //   Block of COMMIT when synchronizing item tracking
    // 
    // PRW111.00.02
    // P80071954, To-Increase, Gangabhushan, 14 MAR 19
    //   TI-13009 - Unable to register pick
    // 
    // PRW111.00.03
    // P80075420, To-Increase, Jack Reynolds, 08 JUL 19
    //   Problem losing tracking when using containers and specifying alt quantity to handle
    // 
    // P80077569, To-Increase, Gangabhushan, 16 JUL 19
    //   CS00069439 - Item tracking that is pre-defined in S.O. will now allow pick registration with qty. - Error
    // 
    // P80079980, To-Increase, Gangabhushan, 06 SEP 19
    //   Multiple Lot assign issue while updating from Pick lines-Sales order
    // 
    // P80082722, To-Increase, Gangabhushan, 23 SEP 19
    //   CS00075740 - When registering a pick with mulitpie items, the tracking is incorrect
    //   Code moved to function CheckSourceOutStandingQty of fix 79980
    // 
    // P800124831, To-Increase, Gangabhushan, 03 JUN 21
    //   CS00170355 | Adding/Removing Container w/non base uom throws off tracking on Whse. Receipt
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00


    trigger OnRun()
    begin
    end;

    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        Item: Record Item;
        Location: Record Location;
        ApplicationTableNo: Integer;
        ApplicationSubtype: Integer;
        ApplicationNo: Code[20];
        ApplicationLineNo: Integer;
        SignFactor: Integer;
        VariantCode: Code[10];
        ShipReceiptDate: Date;
        Inbound: Boolean;
        RequireWarehouseDocument: Boolean;
        QtyPer: Decimal;
        QtyToHandleAltBase: Decimal;
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        LastCheckSourceOutStandingQty: Record "Reservation Entry";

    procedure SetApplication(Inbnd: Boolean; TableNo: Integer; Subtype: Integer; No: Code[20]; LineNo: Integer)
    begin
        ClearAll;

        ApplicationTableNo := TableNo;
        ApplicationSubtype := Subtype;
        ApplicationNo := No;
        ApplicationLineNo := LineNo;
        SignFactor := SetSignFactor;

        if LineNo <> 0 then
            GetSourceDocumentLine(Inbnd, SalesLine, PurchaseLine, TransferLine, ShipReceiptDate, RequireWarehouseDocument);
        Inbound := Inbnd;
    end;

    local procedure SetSignFactor(): Integer
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
    begin
        // Demand is regarded as negative, supply is regarded as positive.
        case ApplicationTableNo of
            DATABASE::"Sales Line":
                if ApplicationSubtype = SalesLine."Document Type"::Order then
                    exit(-1)
                else
                    exit(1);
            DATABASE::"Purchase Line":
                if ApplicationSubtype = PurchaseLine."Document Type"::Order then
                    exit(1)
                else
                    exit(-1);
            DATABASE::"Transfer Line":
                if ApplicationSubtype = 0 then // Outbound
                    exit(-1)
                else
                    exit(1);
        end;
    end;

    local procedure GetSourceDocumentLine(Inbound: Boolean; var SalesLine: Record "Sales Line"; var PurchaseLine: Record "Purchase Line"; var TransferLine: Record "Transfer Line"; var ShipReceiptDate: Date; var RequireWarehouseDocument: Boolean)
    begin
        case ApplicationTableNo of
            DATABASE::"Sales Line":
                begin
                    SalesLine.Get(ApplicationSubtype, ApplicationNo, ApplicationLineNo);
                    Item.Get(SalesLine."No.");
                    VariantCode := SalesLine."Variant Code";
                    QtyPer := SalesLine."Qty. per Unit of Measure";
                    if Location.Get(SalesLine."Location Code") then;
                    ShipReceiptDate := SalesLine."Shipment Date";
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchaseLine.Get(ApplicationSubtype, ApplicationNo, ApplicationLineNo);
                    Item.Get(PurchaseLine."No.");
                    VariantCode := PurchaseLine."Variant Code";
                    QtyPer := PurchaseLine."Qty. per Unit of Measure";
                    if Location.Get(PurchaseLine."Location Code") then;
                    ShipReceiptDate := PurchaseLine."Expected Receipt Date";
                end;
            DATABASE::"Transfer Line":
                begin
                    TransferLine.Get(ApplicationNo, ApplicationLineNo);
                    Item.Get(TransferLine."Item No.");
                    VariantCode := TransferLine."Variant Code";
                    QtyPer := TransferLine."Qty. per Unit of Measure";
                    if Inbound then begin
                        if Location.Get(TransferLine."Transfer-to Code") then;
                        ShipReceiptDate := TransferLine."Receipt Date";
                    end else begin
                        if Location.Get(TransferLine."Transfer-from Code") then;
                        ShipReceiptDate := TransferLine."Shipment Date";
                    end;
                end;
        end;

        Item.GetItemUOMRndgPrecision(Item."Alternate Unit of Measure", true);
        RequireWarehouseDocument := (Inbound and Location."Require Receive") or ((not Inbound) and Location."Require Shipment");
    end;

    procedure AddTracking(TrackingSpecific: Boolean; Incremental: Boolean; LotNo: Code[50]; SerialNo: Code[50]; Quantity: Decimal; QuantityBase: Decimal; QuantityAlt: Decimal; QuantityToAdd: Decimal; QuantityToAddBase: Decimal; QuantityToAddAlt: Decimal; UpdateQtyToHandle: Boolean)
    var
        ResEntry: Record "Reservation Entry";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        RemQtyBase: Decimal;
        RemQtyToHandle: Decimal;
        QtyToAdjust: Decimal;
        QtyToHandle: Decimal;
        ContainerQuantity: array[3] of Decimal;
        ContainerQuantityBase: array[3] of Decimal;
        ContainerQuantityAlt: array[3] of Decimal;
    begin
        if ((QuantityToAdd = 0) and (QuantityToAddAlt = 0)) or ((LotNo = '') and (SerialNo = '')) then
            exit;

        RemQtyBase := QuantityBase;
        RemQtyToHandle := QuantityToAddBase;

        SetReservationEntryFilter(ResEntry, LotNo, '');
        GetContainerQuantities(ApplicationLineNo, LotNo, ContainerQuantity, ContainerQuantityBase, ContainerQuantityAlt);
        if ResEntry.FindSet(true) then begin
            repeat
                QtyToAdjust := Abs(ResEntry."Quantity (Base)");
                if QtyToAdjust < ContainerQuantityBase[3] then begin
                    ContainerQuantityBase[3] -= QtyToAdjust;
                    RemQtyBase -= QtyToAdjust; // P80053245
                    QtyToAdjust := 0;
                end else begin
                    QtyToAdjust -= ContainerQuantityBase[3];
                    RemQtyBase -= ContainerQuantityBase[3]; // P80053245
                    ContainerQuantityBase[3] := 0;
                end;

                if Incremental then begin
                    QtyToHandle := Abs(ResEntry."Qty. to Handle (Base)");
                    if QtyToHandle < ContainerQuantityBase[2] then begin
                        ContainerQuantityBase[2] -= QtyToHandle;
                        QtyToHandle := 0;
                    end else begin
                        QtyToHandle -= ContainerQuantityBase[2];
                        ContainerQuantityBase[2] := 0;
                    end;
                    QtyToAdjust -= QtyToHandle;
                end;

                if UpdateQtyToHandle and (RemQtyToHandle <> 0) then
                    if UpdateTrackingQtyToHandle(ResEntry, RemQtyToHandle, true) then
                        ResEntry.Modify;
            until (ResEntry.Next = 0) or (RemQtyToHandle = 0);
        end;

        if not TrackingSpecific then begin
            if RemQtyBase > 0 then begin // P80053245
                CreateReservEntry.CreateReservEntryFor(
                  ApplicationTableNo, ApplicationSubtype, ApplicationNo, '', 0, ApplicationLineNo, QtyPer,
                  Round(RemQtyBase / QtyPer, 0.00001), RemQtyBase, SerialNo, LotNo);
                if SignFactor > 1 then begin
                    CreateReservEntry.CreateEntry(Item."No.", VariantCode, Location.Code, Item.Description, ShipReceiptDate, 0D, 0, 2);
                end else begin
                    CreateReservEntry.CreateEntry(Item."No.", VariantCode, Location.Code, Item.Description, 0D, ShipReceiptDate, 0, 2);
                end;

                CreateReservEntry.GetLastEntry(ResEntry);
                ResEntry.Validate("Quantity (Base)");
                if not UpdateQtyToHandle then
                    RemQtyToHandle := 0
                else
                    if Abs(ResEntry."Quantity (Base)") < RemQtyToHandle then
                        RemQtyToHandle := Abs(ResEntry."Quantity (Base)");
                RemQtyToHandle := SignFactor * RemQtyToHandle;
                ResEntry."Qty. to Handle (Base)" := RemQtyToHandle;
                ResEntry."Qty. to Invoice (Base)" := RemQtyToHandle;
                // P80057995
                if Item.TrackAlternateUnits and (not Item."Catch Alternate Qtys.") then begin
                    ResEntry."Qty. to Handle (Alt.)" := Round(ResEntry."Qty. to Handle (Base)" * Item.AlternateQtyPerBase, 0.00001);
                    ResEntry."Qty. to Invoice (Alt.)" := ResEntry."Qty. to Handle (Alt.)";
                end;
                // P80057995
                ResEntry.Modify;
            end;
        end;

        SynchronizeTransferTracking;
    end;

    procedure DeleteTracking(LotNo: Code[50]; SerialNo: Code[50]; Quantity: Decimal; QuantityBase: Decimal; QuantityAlt: Decimal; UpdateQtyToHandle: Boolean)
    var
        ResEntry: Record "Reservation Entry";
        ResEntry2: Record "Reservation Entry";
        RemQtyBase: Decimal;
        RemQtyToHandleBase: Decimal;
        QtyToAdjust: Decimal;
        QtyToHandle: Decimal;
    begin
        if ((Quantity = 0) and (QuantityAlt = 0)) or ((LotNo = '') and (SerialNo = '')) then
            exit;

        SetReservationEntryFilter(ResEntry, LotNo, SerialNo);

        RemQtyBase := QuantityBase;
        if UpdateQtyToHandle then
            RemQtyToHandleBase := RemQtyBase;

        ResEntry.SetCurrentKey("Entry No.");
        ResEntry.Ascending(false);
        if ResEntry.FindSet then
            repeat
                QtyToAdjust := Minimum(RemQtyToHandleBase, Abs(ResEntry."Qty. to Handle (Base)"));
                if QtyToAdjust <> 0 then begin
                    ResEntry."Qty. to Handle (Base)" -= SignFactor * QtyToAdjust;
                    RemQtyToHandleBase -= QtyToAdjust;
                end;
                QtyToAdjust := Minimum(RemQtyBase, Abs(ResEntry."Quantity (Base)") - ResEntry."Qty. to Handle (Base)");
                if QtyToAdjust <> 0 then begin
                    ResEntry."Quantity (Base)" -= SignFactor * QtyToAdjust;
                    RemQtyBase -= QtyToAdjust;
                end;

                if ResEntry."Quantity (Base)" <> 0 then begin
                    QtyToHandle := ResEntry."Qty. to Handle (Base)";
                    ResEntry.Validate("Quantity (Base)");
                    ResEntry."Qty. to Handle (Base)" := QtyToHandle;
                    ResEntry."Qty. to Invoice (Base)" := QtyToHandle;
                    // P80057995
                    if Item.TrackAlternateUnits and (not Item."Catch Alternate Qtys.") then begin
                        ResEntry."Qty. to Handle (Alt.)" := Round(ResEntry."Qty. to Handle (Base)" * Item.AlternateQtyPerBase, 0.00001);
                        ResEntry."Qty. to Invoice (Alt.)" := ResEntry."Qty. to Handle (Alt.)";
                    end;
                    // P80057995
                    ResEntry.Modify
                    // Update paired entry if exists
                end else begin
                    ResEntry.Delete;
                    if ResEntry2.Get(ResEntry."Entry No.", not ResEntry.Positive) then
                        ResEntry2.Delete;
                end;
            until (ResEntry.Next = 0) or ((RemQtyBase = 0) and (RemQtyToHandleBase = 0));

        SynchronizeTransferTracking;
    end;

    local procedure Minimum(Value1: Decimal; Value2: Decimal): Decimal
    begin
        if Value1 < Value2 then
            exit(Value1)
        else
            exit(Value2);
    end;

    procedure UpdateTracking(LotNo: Code[50]; SerialNo: Code[50]; Quantity: Decimal; QuantityBase: Decimal; UpdateQtyToHandle: Boolean)
    var
        ResEntry: Record "Reservation Entry";
    begin
        if QuantityBase = 0 then // P800124831
            exit;

        SetReservationEntryFilter(ResEntry, LotNo, SerialNo);

        if ResEntry.FindSet(true) then begin
            repeat
                if UpdateTrackingQtyToHandle(ResEntry, QuantityBase, UpdateQtyToHandle) then // P800124831
                    ResEntry.Modify;
            until (ResEntry.Next = 0) or (QuantityBase = 0); // P800124831
        end;

        SynchronizeTransferTracking;
    end;

    procedure FixTracking()
    var
        ResEntry: Record "Reservation Entry";
        ResEntry2: Record "Reservation Entry";
        LineNo: Integer;
        RemQtyToHandle: Decimal;
        ContainerQuantity: array[3] of Decimal;
        ContainerQuantityBase: array[3] of Decimal;
        ContainerQuantityAlt: array[3] of Decimal;
    begin
        SetReservationEntryFilter(ResEntry, '', '');
        ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Ref. No.", "Source Prod. Order Line", "Lot No.");

        if ResEntry.FindSet(true) then
            repeat
                if WarehouseShipmentLine."No." = '' then begin // P80082722
                    ResEntry.SetRange("Source Ref. No.", ResEntry."Source Ref. No.");
                    ResEntry.SetRange("Source Prod. Order Line", ResEntry."Source Prod. Order Line");
                end; // P80082722
                ResEntry.SetRange("Lot No.", ResEntry."Lot No.");

                ResEntry2.Copy(ResEntry);
                ResEntry2.CalcSums("Quantity (Base)", "Qty. to Handle (Base)");

                if (ApplicationTableNo = DATABASE::"Transfer Line") and (ApplicationSubtype = 1) then
                    LineNo := ResEntry."Source Prod. Order Line"
                else
                    LineNo := ResEntry."Source Ref. No.";
                GetContainerQuantities(LineNo, ResEntry."Lot No.", ContainerQuantity, ContainerQuantityBase, ContainerQuantityAlt);
                // P80077569
                if WarehouseShipmentLine."No." <> '' then begin
                    GetShptQtyFromPick(ResEntry."Lot No.", RemQtyToHandle, QtyToHandleAltBase);
                    RemQtyToHandle -= ContainerQuantityBase[1];
                end else
                    // P80077569
                    RemQtyToHandle := Abs(ResEntry2."Qty. to Handle (Base)");
                // Must be at least as much as in containres to handle
                if RemQtyToHandle < ContainerQuantityBase[2] then
                    RemQtyToHandle := ContainerQuantityBase[2]
                // Must leave enough room for other containers
                else
                    if (Abs(ResEntry2."Quantity (Base)") - ContainerQuantityBase[1]) < RemQtyToHandle then
                        RemQtyToHandle := Abs(ResEntry2."Quantity (Base)") - ContainerQuantityBase[1];
                if RemQtyToHandle < 0 then
                    RemQtyToHandle := 0;

                repeat
                    if RemQtyToHandle < Abs(ResEntry."Qty. to Handle (Base)") then begin
                        ResEntry."Qty. to Handle (Base)" -= SignFactor * (Abs(ResEntry."Qty. to Handle (Base)") - RemQtyToHandle);
                        ResEntry."Qty. to Invoice (Base)" := ResEntry."Qty. to Handle (Base)";
                        // P80057995
                        if Item.TrackAlternateUnits and (not Item."Catch Alternate Qtys.") then begin
                            ResEntry."Qty. to Handle (Alt.)" := Round(ResEntry."Qty. to Handle (Base)" * Item.AlternateQtyPerBase, 0.00001);
                            ResEntry."Qty. to Invoice (Alt.)" := ResEntry."Qty. to Handle (Alt.)";
                        end;
                        // P80057995
                        ResEntry.Modify;
                    end;
                    RemQtyToHandle -= Abs(ResEntry."Qty. to Handle (Base)");
                until ResEntry.Next = 0;

                ResEntry.SetRange("Lot No.");
                CheckSourceOutStandingQty(ResEntry); // P80082722
                if WarehouseShipmentLine."No." = '' then begin // P80082722
                    ResEntry.SetRange("Source Prod. Order Line");
                    ResEntry.SetRange("Source Ref. No.");
                end; // P80082722
            until ResEntry.Next = 0;

        SynchronizeTransferTracking;
    end;

    procedure ClearQtyToHandle(DocumentLine: Variant; Direction: Integer)
    var
        DocumentLineRecRef: RecordRef;
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        ResEntry: Record "Reservation Entry";
        AltQtyLine: Record "Alternate Quantity Line";
        ProcessFns: Codeunit "Process 800 Functions";
        ContainerQtybyDocLine: Query "Container Qty. by Doc. Line";
        QtyToHandle: Decimal;
    begin
        DocumentLineRecRef.GetTable(DocumentLine);
        case DocumentLineRecRef.Number of
            DATABASE::"Sales Line":
                begin
                    SalesLine := DocumentLine;
                    ApplicationTableNo := DATABASE::"Sales Line";
                    ApplicationSubtype := SalesLine."Document Type";
                    ApplicationNo := SalesLine."Document No.";
                    ApplicationLineNo := SalesLine."Line No.";
                    if SalesLine."Document Type" = SalesLine."Document Type"::Order then
                        QtyToHandle := SalesLine."Qty. to Ship"
                    else
                        QtyToHandle := SalesLine."Return Qty. to Receive";
                    Item.Get(SalesLine."No.");
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchaseLine := DocumentLine;
                    ApplicationTableNo := DATABASE::"Purchase Line";
                    ApplicationSubtype := PurchaseLine."Document Type";
                    ApplicationNo := PurchaseLine."Document No.";
                    ApplicationLineNo := PurchaseLine."Line No.";
                    if PurchaseLine."Document Type" = PurchaseLine."Document Type"::Order then
                        QtyToHandle := PurchaseLine."Qty. to Receive"
                    else
                        QtyToHandle := PurchaseLine."Return Qty. to Ship";
                    Item.Get(PurchaseLine."No.");
                end;
            DATABASE::"Transfer Line":
                begin
                    TransferLine := DocumentLine;
                    ApplicationTableNo := DATABASE::"Transfer Line";
                    ApplicationSubtype := Direction;
                    ApplicationNo := TransferLine."Document No.";
                    ApplicationLineNo := TransferLine."Line No.";
                    if Direction = 0 then
                        QtyToHandle := TransferLine."Qty. to Ship"
                    else
                        QtyToHandle := TransferLine."Qty. to Ship";
                    Item.Get(TransferLine."Item No.");
                end;
            DATABASE::"Warehouse Receipt Line":
                begin
                    WarehouseReceiptLine := DocumentLine;
                    ApplicationTableNo := WarehouseReceiptLine."Source Type";
                    ApplicationSubtype := WarehouseReceiptLine."Source Subtype";
                    ApplicationNo := WarehouseReceiptLine."Source No.";
                    ApplicationLineNo := WarehouseReceiptLine."Source Line No.";
                    QtyToHandle := WarehouseReceiptLine."Qty. to Receive";
                    Item.Get(WarehouseReceiptLine."Item No.");
                end;
            DATABASE::"Warehouse Shipment Line":
                begin
                    WarehouseShipmentLine := DocumentLine;
                    ApplicationTableNo := WarehouseShipmentLine."Source Type";
                    ApplicationSubtype := WarehouseShipmentLine."Source Subtype";
                    ApplicationNo := WarehouseShipmentLine."Source No.";
                    ApplicationLineNo := WarehouseShipmentLine."Source Line No.";
                    QtyToHandle := WarehouseShipmentLine."Qty. to Ship";
                    Item.Get(WarehouseShipmentLine."Item No.");
                end;
        end;
        SignFactor := SetSignFactor;

        if ProcessFns.AltQtyInstalled then begin
            AltQtyLine.SetRange("Table No.", ApplicationTableNo);
            AltQtyLine.SetRange("Document Type", ApplicationSubtype);
            AltQtyLine.SetRange("Document No.", ApplicationNo);
            AltQtyLine.SetRange("Source Line No.", ApplicationLineNo);
            AltQtyLine.SetRange("Container ID", '');
            AltQtyLine.DeleteAll;
        end;

        SetReservationEntryFilter(ResEntry, '', '');
        ResEntry.ModifyAll("Quantity (Alt.)", 0);
        ResEntry.ModifyAll("Qty. to Handle (Base)", 0);
        ResEntry.ModifyAll("Qty. to Handle (Alt.)", 0);
        ResEntry.ModifyAll("Qty. to Invoice (Base)", 0);
        ResEntry.ModifyAll("Qty. to Invoice (Alt.)", 0);
        if (QtyToHandle <> 0) and ProcessFns.ContainerTrackingInstalled then begin
            ResEntry.SetCurrentKey("Source Type", "Source ID", "Source Batch Name", "Source Ref. No.", "Lot No.", "Serial No.");
            if ResEntry.FindSet(true) then
                repeat
                    ResEntry.SetRange("Lot No.", ResEntry."Lot No.");
                    ResEntry.SetRange("Serial No.", ResEntry."Serial No.");

                    ContainerQtybyDocLine.SetRange(ApplicationTableNo, ApplicationTableNo);
                    ContainerQtybyDocLine.SetRange(ApplicationSubtype, ApplicationSubtype);
                    ContainerQtybyDocLine.SetRange(ApplicationNo, ApplicationNo);
                    ContainerQtybyDocLine.SetRange(ApplicationLineNo, ApplicationLineNo);
                    ContainerQtybyDocLine.SetRange(LotNo, ResEntry."Lot No.");
                    ContainerQtybyDocLine.SetRange(SerialNo, ResEntry."Serial No.");
                    ContainerQtybyDocLine.SetRange(ShipReceive, true);
                    if ContainerQtybyDocLine.Open then begin
                        QtyToHandle := 0;
                        while ContainerQtybyDocLine.Read do
                            QtyToHandle += ContainerQtybyDocLine.SumQuantityBase;
                        repeat
                            if UpdateTrackingQtyToHandle(ResEntry, QtyToHandle, true) then
                                ResEntry.Modify;
                        until ResEntry.Next = 0;
                    end else
                        ResEntry.FindLast;

                    ResEntry.SetRange("Lot No.");
                    ResEntry.SetRange("Serial No.");

                    UpdateTrackingAltQuantity(ResEntry."Lot No.", ResEntry."Serial No.");
                until ResEntry.Next = 0;
        end;
    end;

    procedure FreeQuantity(DocumentLine: Variant; Direction: Integer; LotNo: Code[50]; Specific: Boolean) QtyFree: Decimal
    var
        DocumentLineRecRef: RecordRef;
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        ResEntry: Record "Reservation Entry";
        ContainerQtybyDocLine: Query "Container Qty. by Doc. Line";
        QtyOutstanding: Decimal;
        QtyToHandle: Decimal;
        QtyContainer: Decimal;
        QtyPer: Decimal;
    begin
        DocumentLineRecRef.GetTable(DocumentLine);
        case DocumentLineRecRef.Number of
            DATABASE::"Sales Line":
                begin
                    SalesLine := DocumentLine;
                    ApplicationTableNo := DATABASE::"Sales Line";
                    ApplicationSubtype := SalesLine."Document Type";
                    ApplicationNo := SalesLine."Document No.";
                    ApplicationLineNo := SalesLine."Line No.";
                    QtyPer := SalesLine."Qty. per Unit of Measure";
                    QtyOutstanding := SalesLine."Outstanding Quantity";
                    if LotNo = '' then begin
                        QtyContainer := SalesLine.GetContainerQuantity(false);
                        if SalesLine."Document Type" = SalesLine."Document Type"::Order then begin
                            if FindWarehouseShipmentLine('', WarehouseShipmentLine) then
                                QtyToHandle := WarehouseShipmentLine."Qty. to Ship"
                            else
                                QtyToHandle := SalesLine."Qty. to Ship";
                        end else begin
                            if FindWarehouseReceiptLine('', WarehouseReceiptLine) then
                                QtyToHandle := WarehouseReceiptLine."Qty. to Receive"
                            else
                                QtyToHandle := SalesLine."Return Qty. to Receive";
                        end;
                    end;
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchaseLine := DocumentLine;
                    ApplicationTableNo := DATABASE::"Purchase Line";
                    ApplicationSubtype := PurchaseLine."Document Type";
                    ApplicationNo := PurchaseLine."Document No.";
                    ApplicationLineNo := PurchaseLine."Line No.";
                    QtyPer := PurchaseLine."Qty. per Unit of Measure";
                    QtyOutstanding := PurchaseLine."Outstanding Quantity";
                    if LotNo = '' then begin
                        QtyContainer := PurchaseLine.GetContainerQuantity(false);
                        if PurchaseLine."Document Type" = PurchaseLine."Document Type"::Order then begin
                            if FindWarehouseReceiptLine('', WarehouseReceiptLine) then
                                QtyToHandle := WarehouseReceiptLine."Qty. to Receive"
                            else
                                QtyToHandle := PurchaseLine."Qty. to Receive";
                        end else begin
                            if FindWarehouseShipmentLine('', WarehouseShipmentLine) then
                                QtyToHandle := WarehouseShipmentLine."Qty. to Ship"
                            else
                                QtyToHandle := PurchaseLine."Return Qty. to Ship";
                        end;
                    end;
                end;
            DATABASE::"Transfer Line":
                begin
                    TransferLine := DocumentLine;
                    ApplicationTableNo := DATABASE::"Transfer Line";
                    ApplicationSubtype := Direction;
                    ApplicationNo := TransferLine."Document No.";
                    ApplicationLineNo := TransferLine."Line No.";
                    QtyPer := TransferLine."Qty. per Unit of Measure";
                    if Direction = 0 then
                        QtyOutstanding := TransferLine."Outstanding Quantity"
                    else
                        QtyOutstanding := TransferLine."Qty. in Transit";
                    if LotNo = '' then begin
                        QtyContainer := TransferLine.GetContainerQuantity(Direction, false);
                        if Direction = 0 then begin
                            QtyContainer := TransferLine.GetContainerQuantity(Direction, false);
                            if FindWarehouseShipmentLine('', WarehouseShipmentLine) then
                                QtyToHandle := WarehouseShipmentLine."Qty. to Ship"
                            else
                                QtyToHandle := TransferLine."Qty. to Ship";
                        end else begin
                            if FindWarehouseReceiptLine('', WarehouseReceiptLine) then
                                QtyToHandle := WarehouseReceiptLine."Qty. to Receive"
                            else
                                QtyToHandle := TransferLine."Qty. to Receive";
                        end;
                    end;
                end;
            DATABASE::"Warehouse Receipt Line":
                begin
                    WarehouseReceiptLine := DocumentLine;
                    ApplicationTableNo := WarehouseReceiptLine."Source Type";
                    ApplicationSubtype := WarehouseReceiptLine."Source Subtype";
                    ApplicationNo := WarehouseReceiptLine."Source No.";
                    ApplicationLineNo := WarehouseReceiptLine."Source Line No.";
                    QtyPer := WarehouseReceiptLine."Qty. per Unit of Measure";
                    QtyOutstanding := WarehouseReceiptLine."Qty. Outstanding";
                    if LotNo = '' then begin
                        QtyContainer := WarehouseReceiptLine.GetContainerQuantity(false);
                        QtyToHandle := WarehouseReceiptLine."Qty. to Receive";
                    end;
                end;
            DATABASE::"Warehouse Shipment Line":
                begin
                    WarehouseShipmentLine := DocumentLine;
                    ApplicationTableNo := WarehouseShipmentLine."Source Type";
                    ApplicationSubtype := WarehouseShipmentLine."Source Subtype";
                    ApplicationNo := WarehouseShipmentLine."Source No.";
                    ApplicationLineNo := WarehouseShipmentLine."Source Line No.";
                    QtyPer := WarehouseShipmentLine."Qty. per Unit of Measure";
                    QtyOutstanding := WarehouseShipmentLine."Qty. Outstanding";
                    if LotNo = '' then begin
                        QtyContainer := WarehouseShipmentLine.GetContainerQuantity(false);
                        QtyToHandle := WarehouseShipmentLine."Qty. to Ship";
                    end;
                end;
        end;

        if LotNo = '' then
            exit(QtyOutstanding - QtyToHandle - QtyContainer);

        SetReservationEntryFilter(ResEntry, LotNo, '');
        if Specific then begin
            ResEntry.CalcSums("Quantity (Base)", "Qty. to Handle (Base)");
            QtyFree := Abs(Round((ResEntry."Quantity (Base)" - ResEntry."Qty. to Handle (Base)") / QtyPer, 0.00001));
        end else begin
            ResEntry.CalcSums("Qty. to Handle (Base)");
            ResEntry.SetFilter("Lot No.", '<>%1', LotNo);
            ResEntry.CalcSums("Quantity (Base)");
            QtyFree := QtyOutstanding - Abs(Round((ResEntry."Quantity (Base)" + ResEntry."Qty. to Handle (Base)") / QtyPer, 0.00001));
        end;

        if QtyFree = 0 then
            exit;

        ContainerQtybyDocLine.SetRange(ApplicationTableNo, ApplicationTableNo);
        ContainerQtybyDocLine.SetRange(ApplicationSubtype, ApplicationSubtype);
        ContainerQtybyDocLine.SetRange(ApplicationNo, ApplicationNo);
        ContainerQtybyDocLine.SetRange(ApplicationLineNo, ApplicationLineNo);
        ContainerQtybyDocLine.SetRange(LotNo, LotNo);
        ContainerQtybyDocLine.SetRange(ShipReceive, false);
        if ContainerQtybyDocLine.Open then
            while ContainerQtybyDocLine.Read do
                QtyFree -= ContainerQtybyDocLine.SumQuantity;
    end;

    procedure AddAlternateQuantityLines(LotNo: Code[50]; SerialNo: Code[50]; ContainerID: Code[20]; ContainerLineNo: Integer; Quantity: Decimal; QuantityBase: Decimal; QuantityAlt: Decimal)
    var
        AltQtyLine: Record "Alternate Quantity Line";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
    begin
        if ((Quantity = 0) and (QuantityAlt = 0)) or (not Item."Catch Alternate Qtys.") then // P80066030
            exit;

        if GetAlternateQuantityLine(AltQtyLine, ContainerID, ContainerLineNo, LotNo, SerialNo) then begin
            AltQtyLine.Quantity += Quantity;
            AltQtyLine."Quantity (Base)" += QuantityBase;
            AltQtyLine."Quantity (Alt.)" += QuantityAlt;
            AltQtyLine.Modify;
        end else begin
            case ApplicationTableNo of
                DATABASE::"Sales Line":
                    AltQtyMgmt.CreateSalesContainerAltQtyLine(SalesLine, LotNo, SerialNo, Quantity, QuantityAlt, ContainerID, ContainerLineNo);
                DATABASE::"Purchase Line":
                    AltQtyMgmt.CreatePurchaseContainerAltQtyLine(PurchaseLine, LotNo, SerialNo, Quantity, QuantityAlt, ContainerID, ContainerLineNo);
                DATABASE::"Transfer Line":
                    AltQtyMgmt.CreateTransContainerAltQtyLine(TransferLine, ApplicationSubtype, LotNo, SerialNo, Quantity, QuantityAlt, ContainerID, ContainerLineNo);
            end;
        end;
    end;

    procedure DeleteAlternateQuantityLines(LotNo: Code[50]; SerialNo: Code[50]; ContainerID: Code[20]; ContainerLineNo: Integer; Quantity: Decimal; QuantityBase: Decimal; QuantityAlt: Decimal)
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        if (QuantityAlt = 0) or (not Item."Catch Alternate Qtys.") then
            exit;

        if GetAlternateQuantityLine(AltQtyLine, ContainerID, ContainerLineNo, LotNo, SerialNo) then begin
            AltQtyLine.Quantity -= Quantity;
            AltQtyLine."Quantity (Base)" -= QuantityBase;
            AltQtyLine."Quantity (Alt.)" -= QuantityAlt;
            if AltQtyLine.Quantity = 0 then
                AltQtyLine.Delete
            else
                AltQtyLine.Modify;
        end;
    end;

    local procedure GetAlternateQuantityLine(var AltQtyLine: Record "Alternate Quantity Line"; ContainerID: Code[20]; ContainerLineNo: Integer; LotNo: Code[50]; SerialNo: Code[50]): Boolean
    begin
        if (ContainerID = '') or (ContainerLineNo = 0) then
            exit(false);

        AltQtyLine.SetRange("Container ID", ContainerID);
        AltQtyLine.SetRange("Container Line No.", ContainerLineNo);
        AltQtyLine.SetRange("Table No.", ApplicationTableNo);
        AltQtyLine.SetRange("Document Type", ApplicationSubtype);
        AltQtyLine.SetRange("Document No.", ApplicationNo);
        AltQtyLine.SetRange("Source Line No.", ApplicationLineNo);
        AltQtyLine.SetRange("Lot No.", LotNo);
        AltQtyLine.SetRange("Serial No.", SerialNo);
        exit(AltQtyLine.FindFirst);
    end;

    procedure UpdateSourceDocumentLine(Quantity: Decimal; QuantityAlt: Decimal)
    var
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
    begin
        case ApplicationTableNo of
            DATABASE::"Sales Line":
                begin
                    if SalesLine.TrackAlternateUnits then
                        AltQtyMgmt.SetSalesLineAltQty(SalesLine);
                    if Inbound then begin
                        SalesLine."Return Qty. to Receive (Alt.)" += QuantityAlt;
                        if not RequireWarehouseDocument then
                            SalesLine.Validate("Return Qty. to Receive", SalesLine."Return Qty. to Receive" + Quantity);
                    end else begin
                        SalesLine."Qty. to Ship (Alt.)" += QuantityAlt;
                        if not RequireWarehouseDocument then
                            SalesLine.Validate("Qty. to Ship", SalesLine."Qty. to Ship" + Quantity);
                    end;
                    SalesLine.GetLotNo;
                    SalesLine.Modify;
                end;
            DATABASE::"Purchase Line":
                begin
                    if PurchaseLine.TrackAlternateUnits then
                        AltQtyMgmt.SetPurchLineAltQty(PurchaseLine);
                    if Inbound then begin
                        PurchaseLine."Qty. to Receive (Alt.)" += QuantityAlt;
                        if not RequireWarehouseDocument then
                            PurchaseLine.Validate("Qty. to Receive", PurchaseLine."Qty. to Receive" + Quantity);
                    end else begin
                        PurchaseLine."Return Qty. to Ship (Alt.)" += QuantityAlt;
                        if not RequireWarehouseDocument then
                            PurchaseLine.Validate("Return Qty. to Ship", PurchaseLine."Return Qty. to Ship" + Quantity);
                    end;
                    PurchaseLine.GetLotNo;
                    PurchaseLine.Modify;
                end;
            DATABASE::"Transfer Line":
                begin
                    if TransferLine.TrackAlternateUnits then
                        AltQtyMgmt.SetTransLineAltQty(TransferLine);
                    if Inbound then begin
                        TransferLine."Qty. to Receive (Alt.)" += QuantityAlt;
                        if not RequireWarehouseDocument then
                            TransferLine.Validate("Qty. to Receive", TransferLine."Qty. to Receive" + Quantity);
                    end else begin
                        TransferLine."Qty. to Ship (Alt.)" += QuantityAlt;
                        if not RequireWarehouseDocument then
                            TransferLine.Validate("Qty. to Ship", TransferLine."Qty. to Ship" + Quantity);
                    end;
                    TransferLine.GetLotNo;
                    TransferLine.Modify;
                end;
        end;
    end;

    procedure UpdateWarehouseDcoumentLine(WarehouseDocType: Integer; WarehouseDocNo: Code[20]; RegisteringPick: Boolean; BinCode: Code[20]; Quantity: Decimal)
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
    begin
        case WarehouseDocType of
            1:  // Receipt
                begin
                    FindWarehouseReceiptLine(WarehouseDocNo, WarehouseReceiptLine);
                    if BinCode <> '' then
                        WarehouseReceiptLine.TestField("Bin Code", BinCode);
                    WarehouseReceiptLine.Validate("Qty. to Receive", WarehouseReceiptLine."Qty. to Receive" + Quantity);
                    WarehouseReceiptLine.Modify;
                end;
            2: // shipment
                if not RegisteringPick then begin
                    FindWarehouseShipmentLine(WarehouseDocNo, WarehouseShipmentLine);
                    if BinCode <> '' then
                        WarehouseShipmentLine.TestField("Bin Code", BinCode);
                    WarehouseShipmentLine.Validate("Qty. to Ship", WarehouseShipmentLine."Qty. to Ship" + Quantity);
                    WarehouseShipmentLine.Modify;
                end;
        end;
    end;

    local procedure FindWarehouseReceiptLine(WarehouseDocNo: Code[20]; var WarehouseReceiptLine: Record "Warehouse Receipt Line"): Boolean
    begin
        if WarehouseDocNo <> '' then
            WarehouseReceiptLine.SetRange("No.", WarehouseDocNo);
        WarehouseReceiptLine.SetRange("Source Type", ApplicationTableNo);
        WarehouseReceiptLine.SetRange("Source Subtype", ApplicationSubtype);
        WarehouseReceiptLine.SetRange("Source No.", ApplicationNo);
        WarehouseReceiptLine.SetRange("Source Line No.", ApplicationLineNo);
        exit(WarehouseReceiptLine.FindFirst);
    end;

    local procedure FindWarehouseShipmentLine(WarehouseDocNo: Code[20]; var WarehouseShipmentLine: Record "Warehouse Shipment Line"): Boolean
    begin
        if WarehouseDocNo <> '' then
            WarehouseShipmentLine.SetRange("No.", WarehouseDocNo);
        WarehouseShipmentLine.SetRange("Source Type", ApplicationTableNo);
        WarehouseShipmentLine.SetRange("Source Subtype", ApplicationSubtype);
        WarehouseShipmentLine.SetRange("Source No.", ApplicationNo);
        WarehouseShipmentLine.SetRange("Source Line No.", ApplicationLineNo);
        exit(WarehouseShipmentLine.FindFirst);
    end;

    procedure UpdateTrackingAltQuantity(LotNo: Code[50]; SerialNo: Code[50])
    var
        AltQtyLine: Record "Alternate Quantity Line";
        ResEntry: Record "Reservation Entry";
        ResEntry2: Record "Reservation Entry";
    begin
        if (not Item."Catch Alternate Qtys.") or ((LotNo = '') and (SerialNo = '')) then
            exit;

        SetReservationEntryFilter(ResEntry, LotNo, SerialNo);
        ResEntry.ModifyAll("Qty. to Handle (Alt.)", 0);
        ResEntry.ModifyAll("Qty. to Invoice (Alt.)", 0);
        ResEntry.ModifyAll("Quantity (Alt.)", 0);

        if ResEntry.FindSet(true) then begin
            ResEntry2.Copy(ResEntry);
            ResEntry2.CalcSums("Qty. to Handle (Base)");
            if ResEntry2."Qty. to Handle (Base)" <> 0 then begin
                ResEntry2."Qty. to Handle (Base)" := Abs(ResEntry2."Qty. to Handle (Base)");

                AltQtyLine.SetRange("Table No.", ApplicationTableNo);
                AltQtyLine.SetRange("Document Type", ApplicationSubtype);
                AltQtyLine.SetRange("Document No.", ApplicationNo);
                AltQtyLine.SetRange("Source Line No.", ApplicationLineNo);
                AltQtyLine.SetRange("Lot No.", LotNo);
                AltQtyLine.SetRange("Serial No.", SerialNo);
                AltQtyLine.CalcSums("Quantity (Alt.)");

                repeat
                    if Abs(ResEntry."Qty. to Handle (Base)") < ResEntry2."Qty. to Handle (Base)" then
                        ResEntry."Qty. to Handle (Alt.)" := Round(AltQtyLine."Quantity (Alt.)" * ResEntry."Qty. to Handle (Base)" / ResEntry2."Qty. to Handle (Base)", Item."Rounding Precision")
                    else
                        ResEntry."Qty. to Handle (Alt.)" := SignFactor * AltQtyLine."Quantity (Alt.)";
                    ResEntry."Qty. to Invoice (Alt.)" := ResEntry."Qty. to Handle (Alt.)";
                    ResEntry."Quantity (Alt.)" := ResEntry."Qty. to Handle (Alt.)";
                    ResEntry.Modify;

                    ResEntry2."Qty. to Handle (Base)" -= Abs(ResEntry."Qty. to Handle (Base)");
                    AltQtyLine."Quantity (Alt.)" -= Abs(ResEntry."Qty. to Handle (Alt.)");
                until (ResEntry.Next = 0) or (ResEntry2."Qty. to Handle (Base)" = 0);
            end;
        end;
    end;

    local procedure SetReservationEntryFilter(var ResEntry: Record "Reservation Entry"; LotNo: Code[50]; SerialNo: Code[50])
    begin
        ResEntry.SetRange("Source Type", ApplicationTableNo);
        ResEntry.SetRange("Source Subtype", ApplicationSubtype);
        ResEntry.SetRange("Source ID", ApplicationNo);
        if ApplicationLineNo <> 0 then
            if (ApplicationTableNo = DATABASE::"Transfer Line") and (ApplicationSubtype = 1) then
                ResEntry.SetRange("Source Prod. Order Line", ApplicationLineNo)
            else
                ResEntry.SetRange("Source Ref. No.", ApplicationLineNo);
        ResEntry.SetRange("Item Tracking", ResEntry."Item Tracking"::"Lot No.");
        if LotNo <> '' then
            ResEntry.SetRange("Lot No.", LotNo);
        if SerialNo <> '' then
            ResEntry.SetRange("Serial No.", SerialNo);
    end;

    local procedure UpdateTrackingQtyToHandle(var ResEntry: Record "Reservation Entry"; var RemQtyToHandle: Decimal; Add: Boolean): Boolean
    var
        QtyToAdjust: Decimal;
    begin
        if Add then begin
            QtyToAdjust := Abs(ResEntry."Quantity (Base)" - ResEntry."Qty. to Handle (Base)");
            if RemQtyToHandle <= QtyToAdjust then
                QtyToAdjust := RemQtyToHandle;
            RemQtyToHandle -= QtyToAdjust;
        end else begin
            QtyToAdjust := Abs(ResEntry."Qty. to Handle (Base)");
            if RemQtyToHandle < QtyToAdjust then
                QtyToAdjust := RemQtyToHandle;
            RemQtyToHandle -= QtyToAdjust;
            QtyToAdjust := -QtyToAdjust;
        end;

        QtyToAdjust := SignFactor * QtyToAdjust;
        if 0 < Abs(QtyToAdjust) then begin
            ResEntry."Qty. to Handle (Base)" += QtyToAdjust;
            ResEntry."Qty. to Invoice (Base)" += QtyToAdjust;
            // P80057995
            if Item.TrackAlternateUnits and (not Item."Catch Alternate Qtys.") then begin
                ResEntry."Qty. to Handle (Alt.)" := Round(ResEntry."Qty. to Handle (Base)" * Item.AlternateQtyPerBase, 0.00001);
                ResEntry."Qty. to Invoice (Alt.)" := Round(ResEntry."Qty. to Invoice (Base)" * Item.AlternateQtyPerBase, 0.00001);
            end;
            // P80057995
            exit(true);
        end;
    end;

    local procedure SynchronizeTransferTracking()
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        CurrentSourceRowID: Text[250];
        SecondSourceRowID: Text[250];
    begin
        if (ApplicationTableNo <> DATABASE::"Transfer Line") or (ApplicationSubtype <> 0) then
            exit;

        CurrentSourceRowID := ItemTrackingMgt.ComposeRowID(ApplicationTableNo, 0, ApplicationNo, '', 0, ApplicationLineNo);
        SecondSourceRowID := ItemTrackingMgt.ComposeRowID(ApplicationTableNo, 1, ApplicationNo, '', 0, ApplicationLineNo);
        ItemTrackingMgt.SetBlockCommit(true); // P80068216
        ItemTrackingMgt.SynchronizeItemTracking(CurrentSourceRowID, SecondSourceRowID, '');
    end;

    local procedure GetContainerQuantities(LineNo: Integer; LotNo: Code[50]; var Quantity: array[3] of Decimal; var QuantityBase: array[3] of Decimal; var QuantityAlt: array[3] of Decimal)
    var
        Process800Fns: Codeunit "Process 800 Functions";
        ContainerQtybyDocLine: Query "Container Qty. by Doc. Line";
    begin
        Clear(Quantity);
        Clear(QuantityBase);
        Clear(QuantityAlt);

        if not Process800Fns.ContainerTrackingInstalled then
            exit;

        ContainerQtybyDocLine.SetRange(ApplicationTableNo, ApplicationTableNo);
        ContainerQtybyDocLine.SetRange(ApplicationSubtype, ApplicationSubtype);
        ContainerQtybyDocLine.SetRange(ApplicationNo, ApplicationNo);
        ContainerQtybyDocLine.SetRange(ApplicationLineNo, LineNo);
        if LotNo <> '' then
            ContainerQtybyDocLine.SetRange(LotNo, LotNo);

        if ContainerQtybyDocLine.Open then
            while ContainerQtybyDocLine.Read do
                if ContainerQtybyDocLine.ShipReceive then begin
                    Quantity[2] += ContainerQtybyDocLine.SumQuantity;
                    QuantityBase[2] += ContainerQtybyDocLine.SumQuantityBase;
                    QuantityAlt[2] += ContainerQtybyDocLine.SumQuantityAlt;
                end else begin
                    Quantity[1] += ContainerQtybyDocLine.SumQuantity;
                    QuantityBase[1] += ContainerQtybyDocLine.SumQuantityBase;
                    QuantityAlt[1] += ContainerQtybyDocLine.SumQuantityAlt;
                end;

        Quantity[3] := Quantity[1] + Quantity[2];
        QuantityBase[3] := QuantityBase[1] + QuantityBase[2];
        QuantityAlt[3] := QuantityAlt[1] + QuantityAlt[2];
    end;

    procedure SetShptLine(WarehouseShipmentLine2: Record "Warehouse Shipment Line")
    begin
        WarehouseShipmentLine := WarehouseShipmentLine2; // P80077569
    end;

    local procedure GetShptQtyFromPick(LotNo: Code[50]; var QtyPicked: Decimal; var QtyPickedAlt: Decimal)
    var
        RegisteredWhseActivityLine: Record "Registered Whse. Activity Line";
    begin
        // P80077569
        RegisteredWhseActivityLine.SetRange("Action Type", RegisteredWhseActivityLine."Action Type"::Place);
        RegisteredWhseActivityLine.SetRange("Activity Type", RegisteredWhseActivityLine."Activity Type"::Pick);
        RegisteredWhseActivityLine.SetRange("Source Type", WarehouseShipmentLine."Source Type");
        RegisteredWhseActivityLine.SetRange("Source Subtype", WarehouseShipmentLine."Source Subtype");
        RegisteredWhseActivityLine.SetRange("Source No.", WarehouseShipmentLine."Source No.");
        RegisteredWhseActivityLine.SetRange("Source Line No.", WarehouseShipmentLine."Source Line No.");
        RegisteredWhseActivityLine.SetRange("Lot No.", LotNo);
        RegisteredWhseActivityLine.CalcSums(Quantity, "Qty. (Base)", "Quantity (Alt.)");
        QtyPicked := RegisteredWhseActivityLine."Qty. (Base)";
        QtyPickedAlt := RegisteredWhseActivityLine."Quantity (Alt.)";
    end;

    local procedure CheckSourceOutStandingQty(var ResEntry: Record "Reservation Entry")
    var
        lSalesLine: Record "Sales Line";
        lPurchLine: Record "Purchase Line";
        lTransferLine: Record "Transfer Line";
        TxtQtyError: Label 'Pick Lot Quanity exceeds with total of %1 Lot Quantity';
        ResEntry2: Record "Reservation Entry";
    begin
        // P80079980, P80082722
        if (LastCheckSourceOutStandingQty."Source Type" = ResEntry."Source Type") and
           (LastCheckSourceOutStandingQty."Source Subtype" = ResEntry."Source Subtype") and
           (LastCheckSourceOutStandingQty."Source ID" = ResEntry."Source ID") and
           (LastCheckSourceOutStandingQty."Source Ref. No." = ResEntry."Source Ref. No.")
        then
            exit;

        LastCheckSourceOutStandingQty := ResEntry;
        ResEntry2.Copy(ResEntry);
        ResEntry2.CalcSums("Quantity (Base)");
        case ResEntry2."Source Type" of
            DATABASE::"Sales Line":
                begin
                    lSalesLine.Get(ResEntry2."Source Subtype", ResEntry2."Source ID", ResEntry2."Source Ref. No.");
                    if lSalesLine."Outstanding Qty. (Base)" < Abs(ResEntry2."Quantity (Base)") then
                        Error(TxtQtyError, SalesLine.TableCaption);
                end;
            DATABASE::"Purchase Line":
                begin
                    lPurchLine.Get(ResEntry2."Source Subtype", ResEntry2."Source ID", ResEntry2."Source Ref. No.");
                    if lPurchLine."Outstanding Qty. (Base)" < Abs(ResEntry2."Quantity (Base)") then
                        Error(TxtQtyError, PurchaseLine.TableCaption);
                end;
            DATABASE::"Transfer Line":
                begin
                    lTransferLine.Get(ResEntry2."Source ID", ResEntry2."Source Ref. No.");
                    if lTransferLine."Outstanding Qty. (Base)" < Abs(ResEntry2."Quantity (Base)") then
                        Error(TxtQtyError, TransferLine.TableCaption);
                end;
        end;
        // P80079980, P80082722
    end;
}

