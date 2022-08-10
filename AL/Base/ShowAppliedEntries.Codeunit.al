codeunit 5801 "Show Applied Entries"
{
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 26 JUN 07
    //   Add Alternate Quantites

    Permissions = TableData "Item Ledger Entry" = rim,
                  TableData "Item Application Entry" = r;
    TableNo = "Item Ledger Entry";

    trigger OnRun()
    var
        TempItemLedgerEntry: Record "Item Ledger Entry" temporary;
    begin
        TempItemLedgerEntry.DeleteAll();
        FindAppliedEntries(Rec, TempItemLedgerEntry);
        PAGE.RunModal(PAGE::"Applied Item Entries", TempItemLedgerEntry);
    end;

    procedure FindAppliedEntries(ItemLedgEntry: Record "Item Ledger Entry"; var TempItemLedgerEntry: Record "Item Ledger Entry" temporary)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        with ItemLedgEntry do
            if Positive then begin
                ItemApplnEntry.Reset();
                ItemApplnEntry.SetCurrentKey("Inbound Item Entry No.", "Outbound Item Entry No.", "Cost Application");
                ItemApplnEntry.SetRange("Inbound Item Entry No.", "Entry No.");
                ItemApplnEntry.SetFilter("Outbound Item Entry No.", '<>%1', 0);
                ItemApplnEntry.SetRange("Cost Application", true);
                OnFindAppliedEntryOnAfterSetFilters(ItemApplnEntry, ItemLedgEntry);
                if ItemApplnEntry.Find('-') then
                    repeat
                        InsertTempEntry(TempItemLedgerEntry, ItemApplnEntry."Outbound Item Entry No.", ItemApplnEntry.Quantity, ItemApplnEntry."Quantity (Alt.)"); // P8000466A
                    until ItemApplnEntry.Next() = 0;
            end else begin
                ItemApplnEntry.Reset();
                ItemApplnEntry.SetCurrentKey("Outbound Item Entry No.", "Item Ledger Entry No.", "Cost Application");
                ItemApplnEntry.SetRange("Outbound Item Entry No.", "Entry No.");
                ItemApplnEntry.SetRange("Item Ledger Entry No.", "Entry No.");
                ItemApplnEntry.SetRange("Cost Application", true);
                OnFindAppliedEntryOnAfterSetFilters(ItemApplnEntry, ItemLedgEntry);
                if ItemApplnEntry.Find('-') then
                    repeat
                        InsertTempEntry(TempItemLedgerEntry, ItemApplnEntry."Inbound Item Entry No.", -ItemApplnEntry.Quantity, -ItemApplnEntry."Quantity (Alt.)"); // P8000466A
                    until ItemApplnEntry.Next() = 0;
            end;
    end;

    local procedure InsertTempEntry(var TempItemLedgerEntry: Record "Item Ledger Entry" temporary; EntryNo: Integer; AppliedQty: Decimal; AppliedQtyAlt: Decimal)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        IsHandled: Boolean;
    begin
        // P8000466A - Add AppliedQtyAlt parameter
        ItemLedgEntry.Get(EntryNo);

        IsHandled := false;
        OnBeforeInsertTempEntry(ItemLedgEntry, IsHandled, TempItemLedgerEntry, AppliedQty);
        if IsHandled then
            exit;

        if AppliedQty * ItemLedgEntry.Quantity < 0 then
            exit;
        if AppliedQtyAlt * ItemLedgEntry."Quantity (Alt.)" < 0 then // P8000466A
            exit;                                                     // P8000466A

        if not TempItemLedgerEntry.Get(EntryNo) then begin
            TempItemLedgerEntry.Init();
            TempItemLedgerEntry := ItemLedgEntry;
            TempItemLedgerEntry.Quantity := AppliedQty;
            TempItemLedgerEntry."Quantity (Alt.)" := AppliedQtyAlt; // P8000466A
            TempItemLedgerEntry.Insert();
        end else begin
            TempItemLedgerEntry.Quantity := TempItemLedgerEntry.Quantity + AppliedQty;
            TempItemLedgerEntry."Quantity (Alt.)" := TempItemLedgerEntry."Quantity (Alt.)" + AppliedQtyAlt; // P8000466A
            TempItemLedgerEntry.Modify();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertTempEntry(ItemLedgerEntry: Record "Item Ledger Entry"; var IsHandled: Boolean; var TempItemLedgerEntry: Record "Item Ledger Entry" temporary; AppliedQty: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindAppliedEntryOnAfterSetFilters(var ItemApplicationEntry: Record "Item Application Entry"; ItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;
}

