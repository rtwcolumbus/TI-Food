codeunit 37002083 "Event Subscribers (CW)"
{
    // PRW111.00.03
    // P80095316, To Increase, Jack Reynolds, 09 MAR 20
    //   Delegte Alt Qty Lines with status check suspended
    //
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW113.00.03
    // P80084737, To Increase, Jack Reynolds, 10 OCT 19
    //   Modify subscriptions for RunTrigger
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW118.00.01
    // P800131264, To Increase, Gangabhushan, 20 OCT 21
    //   CS00187330 | Not able to undo purchase receipts for Catch weight items


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnAfterValidateEvent', 'Require Pick', true, false)]
    local procedure Location_OnAfterValidate_RequirePick(var Rec: Record Location; var xRec: Record Location; CurrFieldNo: Integer)
    begin
        // P80066030
        Rec."Catch Alt. Qtys. On Whse. Pick" := (Rec."Require Shipment" and Rec."Require Pick"); // P8000282A
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnAfterValidateEvent', 'Require Shipment', true, false)]
    local procedure Location_OnAfterValidate_RequireShipment(var Rec: Record Location; var xRec: Record Location; CurrFieldNo: Integer)
    begin
        // P80066030
        Rec."Catch Alt. Qtys. On Whse. Pick" := (Rec."Require Shipment" and Rec."Require Pick"); // P8000282A
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterInitQtyToShip', '', true, false)]
    local procedure SalesLine_OnAfterInitQtyToShip(var SalesLine: Record "Sales Line"; CurrFieldNo: Integer)
    var
        AltQtyManagement: Codeunit "Alt. Qty. Management";
    begin
        // P80053245
        if (SalesLine.Type = SalesLine.Type::Item) and (SalesLine."No." <> '') and SalesLine.TrackAlternateUnits then
            AltQtyManagement.InitAlternateQtyToHandle(
              SalesLine."No.", SalesLine."Alt. Qty. Transaction No.", SalesLine."Quantity (Base)", SalesLine."Qty. to Ship (Base)",
              SalesLine."Qty. Shipped (Base)", SalesLine."Quantity (Alt.)", SalesLine."Qty. Shipped (Alt.)", SalesLine."Qty. to Ship (Alt.)");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterInitQtyToReceive', '', true, false)]
    local procedure SalesLine_OnAfterInitQtyToReceive(var SalesLine: Record "Sales Line"; CurrFieldNo: Integer)
    var
        AltQtyManagement: Codeunit "Alt. Qty. Management";
    begin
        // P80053245
        if (SalesLine.Type = SalesLine.Type::Item) and (SalesLine."No." <> '') and SalesLine.TrackAlternateUnits then
            AltQtyManagement.InitAlternateQtyToHandle(
              SalesLine."No.", SalesLine."Alt. Qty. Transaction No.", SalesLine."Quantity (Base)",
              SalesLine."Return Qty. to Receive (Base)", SalesLine."Return Qty. Received (Base)",
              SalesLine."Quantity (Alt.)", SalesLine."Return Qty. Received (Alt.)", SalesLine."Return Qty. to Receive (Alt.)");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnValidateNoOnBeforeInitRec', '', true, false)]
    local procedure PurchaseLine_OnValidateNoOnBeforeInitRec(var PurchaseLine: Record "Purchase Line"; xPurchaseLine: Record "Purchase Line"; CallingFieldNo: Integer)
    var
        AltQtyManagement: Codeunit "Alt. Qty. Management";
    begin
        // P8000045B
        if PurchaseLine."Alt. Qty. Transaction No." <> 0 then
            AltQtyManagement.DeleteAltQtyLines(PurchaseLine."Alt. Qty. Transaction No.");
        PurchaseLine."Alt. Qty. Transaction No." := 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterInitQtyToReceive', '', true, false)]
    local procedure PurchaseLine_OnAfterInitQtyToReceive(var PurchLine: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        AltQtyManagement: Codeunit "Alt. Qty. Management";
    begin
        // P80053245
        if (PurchLine.Type = PurchLine.Type::Item) and (PurchLine."No." <> '') and PurchLine.TrackAlternateUnits then
            AltQtyManagement.InitAlternateQtyToHandle(
              PurchLine."No.", PurchLine."Alt. Qty. Transaction No.", PurchLine."Quantity (Base)", PurchLine."Qty. to Receive (Base)",
              PurchLine."Qty. Received (Base)", PurchLine."Quantity (Alt.)", PurchLine."Qty. Received (Alt.)", PurchLine."Qty. to Receive (Alt.)");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterInitQtyToShip', '', true, false)]
    local procedure PurchaseLine_OnAfterInitQtyToShip(var PurchLine: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        AltQtyManagement: Codeunit "Alt. Qty. Management";
    begin
        // P80053245
        if (PurchLine.Type = PurchLine.Type::Item) and (PurchLine."No." <> '') and PurchLine.TrackAlternateUnits then
            AltQtyManagement.InitAlternateQtyToHandle(
              PurchLine."No.", PurchLine."Alt. Qty. Transaction No.", PurchLine."Quantity (Base)",
              PurchLine."Return Qty. to Ship (Base)", PurchLine."Return Qty. Shipped (Base)",
              PurchLine."Quantity (Alt.)", PurchLine."Return Qty. Shipped (Alt.)", PurchLine."Return Qty. to Ship (Alt.)");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnValidateQuantityOnBeforeGetUnitAmount', '', true, false)]
    local procedure ItemJournalLine_OnValidateQuantityOnBeforeGetUnitAmount(var ItemJournalLine: Record "Item Journal Line"; xItemJournalLine: Record "Item Journal Line"; CallingFieldNo: Integer)
    var
        AltQtyManagement: Codeunit "Alt. Qty. Management";
    begin
        // P80073095
        // PR3.60
        if (ItemJournalLine."Item No." <> '') then begin
            if not ItemJournalLine."Phys. Inventory" and ItemJournalLine.TrackAlternateUnits then
                AltQtyManagement.InitAlternateQty(ItemJournalLine."Item No.", ItemJournalLine."Alt. Qty. Transaction No.", ItemJournalLine."Quantity (Base)", ItemJournalLine."Quantity (Alt.)");
            if (ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::Output) and
               (ItemJournalLine."Value Entry Type" <> ItemJournalLine."Value Entry Type"::Revaluation)
            then
                ItemJournalLine."Invoiced Qty. (Alt.)" := 0
            else
                ItemJournalLine."Invoiced Qty. (Alt.)" := ItemJournalLine."Quantity (Alt.)";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Line", 'OnAfterInitFromSalesLine', '', true, false)]
    local procedure SalesInvoiceLine_OnAfterInitFromSalesLine(var SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line")
    begin
        // P80053245
        // P8004516
        SalesInvLine."Quantity (Alt.)" := SalesLine."Qty. to Invoice (Alt.)";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Cr.Memo Line", 'OnAfterInitFromSalesLine', '', true, false)]
    local procedure SalesCrMemoLine_OnAfterInitFromSalesLine(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesLine: Record "Sales Line")
    begin
        // P80053245
        // P8004516
        SalesCrMemoLine."Quantity (Alt.)" := SalesLine."Qty. to Invoice (Alt.)";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Line", 'OnAfterInitFromPurchLine', '', true, false)]
    local procedure PurchInvLine_OnAfterInitFromPurchLine(PurchInvHeader: Record "Purch. Inv. Header"; PurchLine: Record "Purchase Line"; var PurchInvLine: Record "Purch. Inv. Line")
    begin
        // P80053245
        PurchInvLine."Quantity (Alt.)" := PurchLine."Qty. to Invoice (Alt.)"; // P8004516
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Cr. Memo Line", 'OnAfterInitFromPurchLine', '', true, false)]
    local procedure PurchCrMemoLine_OnAfterInitFromPurchLine(PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; PurchLine: Record "Purchase Line"; var PurchCrMemoLine: Record "Purch. Cr. Memo Line")
    begin
        // P80053245
        PurchCrMemoLine."Quantity (Alt.)" := PurchLine."Qty. to Invoice (Alt.)"; // P8004516
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Shipment Header", 'OnAfterDeleteEvent', '', true, false)]
    local procedure TransferShipmentHeader_OnAfterDelete(var Rec: Record "Transfer Shipment Header"; RunTrigger: Boolean)
    var
        AltQtyManagement: Codeunit "Alt. Qty. Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        AltQtyManagement.DeletePostedDocEntries(DATABASE::"Transfer Shipment Line", Rec."No."); // P8000198A
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Receipt Header", 'OnAfterDeleteEvent', '', true, false)]
    local procedure TransferReceiptHeader_OnAfterDelete(var Rec: Record "Transfer Receipt Header"; RunTrigger: Boolean)
    var
        AltQtyManagement: Codeunit "Alt. Qty. Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        AltQtyManagement.DeletePostedDocEntries(DATABASE::"Transfer Receipt Line", Rec."No."); // P8000198A
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertPhysInvtLedgEntry', '', true, false)]
    local procedure ItemJnlPostLine_OnBeforeInsertPhysInvtLedgEntry(var PhysInventoryLedgerEntry: Record "Phys. Inventory Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    var
        AltQtyManagement: Codeunit "Alt. Qty. Management";
    begin
        // P80053245
        if ItemJournalLine.TrackAlternateUnits then
            AltQtyManagement.ItemJnlLineToPhysInvtLedgEntry(ItemJournalLine, PhysInventoryLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeOldItemLedgEntryModify', '', true, false)]
    local procedure ItemJnlPostLine_OnBeforeOldItemLedgEntryModify(var OldItemLedgerEntry: Record "Item Ledger Entry")
    begin
        // P80073095
        OldItemLedgerEntry."Shipped Qty. Not Ret. (Alt.)" := 0; // P8000466A
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Purchase Receipt Line", 'OnAfterUpdateOrderLine', '', true, false)]
    local procedure UndoPurchaseReceiptLine_OnAfterUpdateOrderLine(var PurchRcptLine: Record "Purch. Rcpt. Line"; var PurchLine: Record "Purchase Line")
    var
        AltQtyManagement: Codeunit "Alt. Qty. Management";
    begin
        // P80053245
        // P8000267B
        PurchLine.Find();  // P800131264
        if PurchRcptLine.AltQtyEntriesExist then begin
            AltQtyManagement.AltQtyEntriesToPurchLine(DATABASE::"Purch. Rcpt. Line", PurchRcptLine."Document No.", PurchRcptLine."Line No.", PurchLine);
            PurchLine.Modify;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Sales Shipment Line", 'OnAfterUpdateSalesLine', '', true, false)]
    local procedure UndoSalesShipmentLine_OnAfterUpdateSalesLine(var SalesLine: Record "Sales Line"; SalesShptLine: Record "Sales Shipment Line")
    var
        AltQtyManagement: Codeunit "Alt. Qty. Management";
    begin
        // P80053245
        // P8000267B
        SalesLine.Find(); // P800131264
        if SalesShptLine.AltQtyEntriesExist then begin
            AltQtyManagement.AltQtyEntriesToSalesLine(DATABASE::"Sales Shipment Line", SalesShptLine."Document No.", SalesShptLine."Line No.", SalesLine);
            SalesLine.Modify;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Return Receipt Line", 'OnAfterUpdateSalesLine', '', true, false)]
    local procedure UndoReturnReceiptLine_OnAfterUpdateSalesLine(ReturnRcptLine: Record "Return Receipt Line"; SalesLine: Record "Sales Line")
    var
        AltQtyManagement: Codeunit "Alt. Qty. Management";
    begin
        // P80053245
        SalesLine.Find(); // P800131264
        if ReturnRcptLine.AltQtyEntriesExist then begin
            AltQtyManagement.AltQtyEntriesToSalesLine(DATABASE::"Return Receipt Line", ReturnRcptLine."Document No.", ReturnRcptLine."Line No.", SalesLine);
            SalesLine.Modify;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Pick", 'OnBeforeWhseActivLineInsert', '', true, false)]
    local procedure CreatePick_OnBeforeWhseActivLineInsert(var WarehouseActivityLine: Record "Warehouse Activity Line"; WarehouseActivityHeader: Record "Warehouse Activity Header")
    begin
        // P80073095
        if WarehouseActivityLine.TrackAlternateUnits() then           // P8000282A
            WarehouseActivityLine.Validate("Qty. to Handle (Alt.)", 0); // P8000282A
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Post", 'OnBeforeWhseActivLineDelete', '', true, false)]
    local procedure WhseActivityPost_OnBeforeWhseActivLineDelete(WarehouseActivityLine: Record "Warehouse Activity Line"; var ForceDelete: Boolean)
    begin
        // P8000282A
        WarehouseActivityLine.DeleteAltQtys2(true); // P80095316
    end;
}

