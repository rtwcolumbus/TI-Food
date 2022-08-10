codeunit 37002054 "Cost. Basis-Cost Adjustment"
{
    // PRW116.00.05
    // P800103616, To-Increase, Gangabhushan, 04 FEB 21
    //  Enhance inventory costing with Book Cost  

    TableNo = "Item Cost Basis";

    trigger OnRun()
    begin
        TestField(Rec."Reference Cost Basis Code");
        CalculateItemCostBasis(Rec);
    end;


    var
        CostBasis: record "Cost Basis";
        CalculatedCost: Decimal;
        Text001: Label 'Reference Cost Basis: %1, Cost Date: %2, Variant Code: %3, Cost: %4';


    local procedure CalculateItemCostBasis(var ItemCostbasis: record "Item Cost basis")
    var
        CostBasisAdjustment: record "Cost Basis Adjustment";
        CostValue: Decimal;
        StepIncrement: Decimal;
    begin
        CostValue := GetItemCostBasisValue(ItemCostbasis);
        if CostValue = 0 then
            Exit;
        CostValue := ConvertCostvalueToLCY(ItemCostbasis, CostValue);
        ItemCostbasis."Cost Value" := CostValue;
        CostBasisAdjustment.SetRange("Cost Basis Code", ItemCostbasis."Cost Basis Code");
        CostBasisAdjustment.setcurrentkey("Calculation Step");
        if CostBasisAdjustment.FindSet then
            repeat
                CostBasisAdjustment.SetRange("Calculation Step", CostBasisAdjustment."Calculation Step");
                StepIncrement := 0;
                repeat
                    case CostBasisAdjustment.Type OF
                        CostBasisAdjustment.Type::Amount:
                            StepIncrement += CostBasisAdjustment.Value;
                        CostBasisAdjustment.Type::Percentage:
                            StepIncrement += (CostValue * CostBasisAdjustment.Value / 100);
                    end;
                until CostBasisAdjustment.next = 0;
                CostValue += StepIncrement;
                CostBasisAdjustment.SetRange("Calculation Step");
            until CostBasisAdjustment.next = 0;
        ItemCostbasis.AssignResults(CostValue, STRSUBSTNO(Text001, ItemCostbasis."Reference Cost Basis Code", ItemCostbasis."Reference Date"
                                        , ItemCostbasis."Variant Code", ItemCostbasis."Cost Value"));
    end;

    local procedure GetItemCostBasisValue(ItemCostBasis: Record "Item Cost Basis"): Decimal
    var
        ItemCostBasis2: record "Item Cost Basis";
    begin
        ItemCostBasis2.SetRange("Cost Basis Code", ItemCostBasis."Reference Cost Basis Code");
        ItemCostBasis2.SetRange("Item No.", ItemCostBasis."Item No.");
        ItemCostBasis2.SetRange("Variant Code", ItemCostBasis."Variant Code");
        ItemCostBasis2.SetRange("Cost Date", ItemCostBasis."Reference Date");
        if ItemCostBasis2.FindFirst then
            exit(ItemCostBasis2."Cost Value")
        else begin
            ItemCostBasis2.SetRange("Cost Date");
            ItemCostBasis2.SetFilter("Cost Date", '<=%1', ItemCostBasis."Reference Date");
            if ItemCostBasis2.FindLast then
                exit(ItemCostBasis2."Cost Value");
        end;
    end;

    local procedure ConvertCostvalueToLCY(ItemCostBasis: Record "Item Cost Basis"; CostValue: Decimal): Decimal
    var
        CostBasis: record "Cost Basis";
        CurrencyExchRate: Record "Currency Exchange Rate";
        CurrencyFactor: Decimal;
    begin
        if CostBasis.get(ItemCostBasis."Reference Cost Basis Code") then
            if CostBasis."Currency Code" <> '' then begin
                CurrencyFactor :=
                    CurrencyExchRate.ExchangeRate(ItemCostBasis."Reference Date", CostBasis."Currency Code");
                exit(CurrencyExchRate.ExchangeAmtFCYToLCY(ItemCostBasis."Reference Date", CostBasis."Currency Code", CostValue, CurrencyFactor));
            end;
        exit(CostValue);
    end;

}