codeunit 37002046 "Cost. Basis-Max. Purch. Cost"
{
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Calculates cost values for a Cost Basis - a one week maximum purchase cost

    TableNo = "Item Cost Basis";

    trigger OnRun()
    begin
        if GetFirstPurchItemEntry(ItemLedgEntry, '<1W>') then begin
            FirstCost := true;
            repeat
                Qty := GetItemEntryQty(ItemLedgEntry);
                Cost := GetItemEntryCost(ItemLedgEntry);
                if (Qty > 0) and (Cost > 0) then begin
                    UnitCost := Cost / Qty;
                    if FirstCost or (UnitCost >= "Cost Value") then begin
                        AssignResults(
                          UnitCost,
                          StrSubstNo(Text001, ItemLedgEntry."Document No.", Qty, Cost));
                        FirstCost := false;
                    end;
                end;
            until (ItemLedgEntry.Next = 0);
        end;
    end;

    var
        ItemLedgEntry: Record "Item Ledger Entry";
        Qty: Decimal;
        Cost: Decimal;
        FirstCost: Boolean;
        UnitCost: Decimal;
        Text001: Label 'Doc. No.: %1, Qty: %2, Cost: %3';
}

