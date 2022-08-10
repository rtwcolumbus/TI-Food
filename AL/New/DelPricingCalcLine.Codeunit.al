codeunit 37002050 "Del. Pricing - Calc. Line"
{
    // PRW16.00.05
    // P8000921, Columbus IT, Don Bresee, 08 APR 11
    //   Add Delivered Pricing granule

    TableNo = "Sales Line";

    trigger OnRun()
    begin
        // This function should set the value of the "Unit Price (Freight)" or "Line Amount (Freight)" fields.
        // Both fields will be zero when this codeunit is called. The NAV price will be in the
        // "Unit Price (FOB)" field, not the "Unit Price".
        // There is no need to validate or round the result, that is done by the calling routine.
        // WARNING: Validation of the "Unit Price (FOB)" field will cause an infinite loop.

        if (GetPricingQty() <> 0) then
            "Unit Price (Freight)" := 0.1 * (CalculateWeight(Rec) / GetPricingQty());

        // "Line Amount (Freight)" := CalculateWeight(Rec) * 0.095;
    end;

    var
        Item: Record Item;

    procedure CalculateWeight(var SalesLine: Record "Sales Line"): Decimal
    begin
        with SalesLine do
            if (Type = Type::Item) and ("No." <> '') then begin
                if not PriceInAlternateUnits() then
                    exit(Quantity * CalculateUOMWeight("No.", "Unit of Measure Code"));
                if (Item."No." <> "No.") then
                    Item.Get("No.");
                exit("Quantity (Alt.)" * CalculateUOMWeight("No.", Item."Alternate Unit of Measure"));
            end;
    end;

    local procedure CalculateUOMWeight(ItemNo: Code[20]; UOMCode: Code[10]): Decimal
    var
        ItemUOM: Record "Item Unit of Measure";
        UOM: Record "Unit of Measure";
        WeightUOM: Record "Item Unit of Measure";
    begin
        with ItemUOM do begin
            Get(ItemNo, UOMCode);
            CalcFields(Type);
            if (Type = Type::Weight) then begin
                UOM.Get(Code);
                exit(UOM."Base per Unit of Measure");
            end;
        end;
        with WeightUOM do begin
            SetRange("Item No.", ItemNo);
            SetRange(Type, Type::Weight);
            if FindFirst then begin
                UOM.Get(Code);
                exit(ItemUOM."Qty. per Unit of Measure" * (UOM."Base per Unit of Measure" / "Qty. per Unit of Measure"));
            end;
        end;
    end;
}

