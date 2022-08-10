codeunit 37002044 "Cost. Basis-Avg. Purch. Cost"
{
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Calculates cost values for a Cost Basis - a one week average purchase cost

    TableNo = "Item Cost Basis";

    trigger OnRun()
    begin
        if GetFirstPurchItemEntry(ItemLedgEntry, '<1W>') then begin
            Qty := 0;
            Cost := 0;
            repeat
                Qty := Qty + GetItemEntryQty(ItemLedgEntry);
                Cost := Cost + GetItemEntryCost(ItemLedgEntry);
            until (ItemLedgEntry.Next = 0);
            if (Qty > 0) and (Cost > 0) then
                AssignResults(
                  Cost / Qty,
                  StrSubstNo(Text001, ItemLedgEntry.GetFilter("Posting Date"), Qty, Cost));
        end;
    end;

    var
        ItemLedgEntry: Record "Item Ledger Entry";
        Qty: Decimal;
        Cost: Decimal;
        Text001: Label 'Dates: %1 Qty: %2, Cost: %3';
}

