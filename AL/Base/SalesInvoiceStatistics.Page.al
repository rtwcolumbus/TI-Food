page 397 "Sales Invoice Statistics"
{
    // PR3.70
    //   Add logic for alternate quantities
    //   Off-Invoice Allowances
    //   Move Tax Summary to separate tab
    //   Add Line by Line Profit Summary
    // 
    // PRW16.00.05
    // P8000921, Columbus IT, Don Bresee, 09 APR 11
    //   Add Freight Amount, exclude freight from profit calculation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Sales Invoice Statistics';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPlus;
    SourceTable = "Sales Invoice Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("CustAmount + InvDiscAmount + Allowance"; CustAmount + InvDiscAmount + Allowance)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 1;
                    Caption = 'Amount';
                    ToolTip = 'Specifies the net amount of all the lines in the sales document.';
                }
                field(InvDiscAmount; InvDiscAmount)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 1;
                    Caption = 'Inv. Discount Amount';
                    ToolTip = 'Specifies the invoice discount amount for the sales document.';
                }
                field(Allowance; Allowance)
                {
                    ApplicationArea = FOODBasic;
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 1;
                    Caption = 'Off-Invoice Allowance';
                }
                field(CustAmount; CustAmount)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 1;
                    Caption = 'Total';
                    ToolTip = 'Specifies the total amount, less any invoice discount amount, and excluding VAT for the sales document.';
                }
                field(VATAmount; VATAmount)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = '3,' + Format(VATAmountText);
                    Caption = 'VAT Amount';
                    ToolTip = 'Specifies the total VAT amount that has been calculated for all the lines in the sales document.';
                }
                field(AmountInclVAT; AmountInclVAT)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 1;
                    Caption = 'Total Incl. VAT';
                    ToolTip = 'Specifies the total amount, including VAT, that will be posted to the customer''s account for all the lines in the sales document.';
                }
                field(FreightAmountLCY; FreightAmountLCY)
                {
                    ApplicationArea = FOODBasic;
                    AutoFormatType = 1;
                    Caption = 'Freight (LCY)';
                }
                field(AmountLCY; AmountLCY)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    Caption = 'Sales (LCY)';
                    ToolTip = 'Specifies your total sales turnover in the fiscal year.';
                }
                field(ProfitLCY; ProfitLCY)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    Caption = 'Original Profit (LCY)';
                    ToolTip = 'Specifies the original profit that was associated with the sales when they were originally posted.';
                }
                field(AdjustedProfitLCY; AdjProfitLCY)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    Caption = 'Adjusted Profit (LCY)';
                    ToolTip = 'Specifies the profit, taking into consideration changes in the purchase prices of the goods.';
                }
                field(ProfitPct; ProfitPct)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Original Profit %';
                    DecimalPlaces = 1 : 1;
                    ToolTip = 'Specifies the original percentage of profit that was associated with the sales when they were originally posted.';
                }
                field(AdjProfitPct; AdjProfitPct)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Adjusted Profit %';
                    DecimalPlaces = 1 : 1;
                    ToolTip = 'Specifies the percentage of profit for all sales, including changes that occurred in the purchase prices of the goods.';
                }
                field(LineQty; LineQty)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Quantity';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the total quantity of G/L account entries, items and/or resources in the sales document.';
                }
                field(TotalParcels; TotalParcels)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Parcels';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the total number of parcels in the sales document.';
                }
                field(TotalNetWeight; TotalNetWeight)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Net Weight';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the total net weight of the items in the sales document.';
                }
                field(TotalGrossWeight; TotalGrossWeight)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Gross Weight';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the total gross weight of the items in the sales document.';
                }
                field(TotalVolume; TotalVolume)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Volume';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the total volume of the items in the sales document.';
                }
                field(CostLCY; CostLCY)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    Caption = 'Original Cost (LCY)';
                    ToolTip = 'Specifies the total cost, in LCY, of the G/L account entries, items and/or resources in the sales document.';
                }
                field(AdjustedCostLCY; TotalAdjCostLCY)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    Caption = 'Adjusted Cost (LCY)';
                    ToolTip = 'Specifies the total cost, in LCY, of the items in the posted sales invoice, adjusted for any changes in the original costs of these items.';
                }
                field("TotalAdjCostLCY - CostLCY"; TotalAdjCostLCY - CostLCY)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    Caption = 'Cost Adjmt. Amount (LCY)';
                    ToolTip = 'Specifies the difference between the original cost and the total adjusted cost of the items in the posted sales invoice.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupAdjmtValueEntries;
                    end;
                }
            }
            part(SalesLine; "Sales Statistics Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
            }
            group(Customer)
            {
                Caption = 'Customer';
                field("Cust.""Balance (LCY)"""; Cust."Balance (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    Caption = 'Balance (LCY)';
                    ToolTip = 'Specifies the balance in LCY on the customer''s account.';
                }
                field("Cust.""Credit Limit (LCY)"""; Cust."Credit Limit (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatType = 1;
                    Caption = 'Credit Limit (LCY)';
                    ToolTip = 'Specifies information about the credit limit in LCY, for the customer who you created and posted this sales invoice for. ';
                }
                field(CreditLimitLCYExpendedPct; CreditLimitLCYExpendedPct)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Expended % of Credit Limit (LCY)';
                    ExtendedDatatype = Ratio;
                    ToolTip = 'Specifies the expended percentage of the credit limit in (LCY).';
                }
            }
            group(VAT)
            {
                Caption = 'VAT';
                part(Subform; "VAT Specification Subform")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        ClearAll;

        Currency.Initialize("Currency Code");

        CalculateTotals();

        VATAmount := AmountInclVAT - CustAmount;
        InvDiscAmount := Round(InvDiscAmount, Currency."Amount Rounding Precision");

        if VATPercentage <= 0 then
            VATAmountText := Text000
        else
            VATAmountText := StrSubstNo(Text001, VATPercentage);

        if "Currency Code" = '' then
            AmountLCY := CustAmount
        else
            AmountLCY :=
              CurrExchRate.ExchangeAmtFCYToLCY(
                WorkDate, "Currency Code", CustAmount, "Currency Factor");

        CustLedgEntry.SetCurrentKey("Document No.");
        CustLedgEntry.SetRange("Document No.", "No.");
        CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
        CustLedgEntry.SetRange("Customer No.", "Bill-to Customer No.");
        if CustLedgEntry.FindFirst then
            AmountLCY := CustLedgEntry."Sales (LCY)";

        // P8000921
        if (FreightAmountLCY <> 0) then begin
            if ("Currency Code" <> '') then
                FreightAmountLCY :=
                  CurrExchRate.ExchangeAmtFCYToLCY(WorkDate, "Currency Code", FreightAmountLCY, "Currency Factor");
            AmountLCY := AmountLCY - FreightAmountLCY;
        end;
        // P8000921

        ProfitLCY := AmountLCY - CostLCY;
        if AmountLCY <> 0 then
            ProfitPct := Round(100 * ProfitLCY / AmountLCY, 0.1);

        AdjProfitLCY := AmountLCY - TotalAdjCostLCY;

        OnAfterGetRecordOnAfterCalculateAdjProfitLCY(Rec, AdjProfitLCY);

        if AmountLCY <> 0 then
            AdjProfitPct := Round(100 * AdjProfitLCY / AmountLCY, 0.1);

        if Cust.Get("Bill-to Customer No.") then
            Cust.CalcFields("Balance (LCY)")
        else
            Clear(Cust);

        case true of
            Cust."Credit Limit (LCY)" = 0:
                CreditLimitLCYExpendedPct := 0;
            Cust."Balance (LCY)" / Cust."Credit Limit (LCY)" < 0:
                CreditLimitLCYExpendedPct := 0;
            Cust."Balance (LCY)" / Cust."Credit Limit (LCY)" > 1:
                CreditLimitLCYExpendedPct := 10000;
            else
                CreditLimitLCYExpendedPct := Round(Cust."Balance (LCY)" / Cust."Credit Limit (LCY)" * 10000, 1);
        end;

        SalesInvLine.CalcVATAmountLines(Rec, TempVATAmountLine);
        CurrPage.Subform.PAGE.SetTempVATAmountLine(TempVATAmountLine);
        CurrPage.Subform.PAGE.InitGlobals("Currency Code", false, false, false, false, "VAT Base Discount %");
        SetSalesLines; // PR3.70
    end;

    var
        Text000: Label 'VAT Amount';
        Text001: Label '%1% VAT';
        CurrExchRate: Record "Currency Exchange Rate";
        SalesInvLine: Record "Sales Invoice Line";
        Cust: Record Customer;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        TotalAdjCostLCY: Decimal;
        CustAmount: Decimal;
        AmountInclVAT: Decimal;
        InvDiscAmount: Decimal;
        VATAmount: Decimal;
        ProfitLCY: Decimal;
        ProfitPct: Decimal;
        AdjProfitLCY: Decimal;
        AdjProfitPct: Decimal;
        LineQty: Decimal;
        TotalNetWeight: Decimal;
        TotalGrossWeight: Decimal;
        TotalVolume: Decimal;
        TotalParcels: Decimal;
        CreditLimitLCYExpendedPct: Decimal;
        VATPercentage: Decimal;
        VATAmountText: Text[30];
        Allowance: Decimal;
        FreightAmountLCY: Decimal;

    protected var
        Currency: Record Currency;
        AmountLCY: Decimal;
        CostLCY: Decimal;

    procedure SetSalesLines()
    var
        TempSalesInvoiceLine: Record "Sales Statistic Line" temporary;
        SalesStatFns: Codeunit "Sales Statistics Functions";
    begin
        // PR3.70
        SalesStatFns.GetTempSalesInvoiceLine("No.", TempSalesInvoiceLine);
        CurrPage.SalesLine.PAGE.SetTempSalesLine(TempSalesInvoiceLine);
        // PR3.70
    end;

    local procedure CalculateTotals()
    var
        CostCalcMgt: Codeunit "Cost Calculation Management";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalculateTotals(
            Rec, CustAmount, AmountInclVAT, InvDiscAmount, CostLCY, TotalAdjCostLCY,
            LineQty, TotalNetWeight, TotalGrossWeight, TotalVolume, TotalParcels, IsHandled, VATpercentage);
        if IsHandled then
            exit;

        SalesInvLine.SetRange("Document No.", "No.");
        if SalesInvLine.Find('-') then
            repeat
                CustAmount += SalesInvLine.Amount;
                AmountInclVAT += SalesInvLine."Amount Including VAT";
                FreightAmountLCY += SalesInvLine."Line Amount (Freight)"; // P8000921
                if SalesInvLine."Off-Invoice Allowance Code" <> '' then // PR3.70
                    Allowance -= SalesInvLine.Amount;                     // PR3.70
                if "Prices Including VAT" then
                    InvDiscAmount += SalesInvLine."Inv. Discount Amount" / (1 + SalesInvLine."VAT %" / 100)
                else
                    InvDiscAmount += SalesInvLine."Inv. Discount Amount";
                CostLCY += SalesInvLine.Quantity * SalesInvLine."Unit Cost (LCY)";
                // CostLCY += SalesInvLine.Quantity * SalesInvLine."Unit Cost (LCY)";     // PR3.70
                CostLCY += SalesInvLine.GetCostingQty() * SalesInvLine."Unit Cost (LCY)"; // PR3.70
                LineQty += SalesInvLine.Quantity;
                TotalNetWeight += SalesInvLine.Quantity * SalesInvLine."Net Weight";
                TotalGrossWeight += SalesInvLine.Quantity * SalesInvLine."Gross Weight";
                TotalVolume += SalesInvLine.Quantity * SalesInvLine."Unit Volume";
                if SalesInvLine."Units per Parcel" > 0 then
                    TotalParcels += Round(SalesInvLine.Quantity / SalesInvLine."Units per Parcel", 1, '>');
                if SalesInvLine."VAT %" <> VATPercentage then
                    if VATPercentage = 0 then
                        VATPercentage := SalesInvLine."VAT %"
                    else
                        VATPercentage := -1;
                TotalAdjCostLCY +=
                  CostCalcMgt.CalcSalesInvLineCostLCY(SalesInvLine) + CostCalcMgt.CalcSalesInvLineNonInvtblCostAmt(SalesInvLine);

                OnCalculateTotalsOnAfterAddLineTotals(
                    SalesInvLine, CustAmount, AmountInclVAT, InvDiscAmount, CostLCY, TotalAdjCostLCY,
                    LineQty, TotalNetWeight, TotalGrossWeight, TotalVolume, TotalParcels, Rec)
            until SalesInvLine.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetRecordOnAfterCalculateAdjProfitLCY(SalesInvoiceHeader: Record "Sales Invoice Header"; var AdjProfitLCY: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateTotals(SalesInvoiceHeader: Record "Sales Invoice Header"; var CustAmount: Decimal; var AmountInclVAT: Decimal; var InvDiscAmount: Decimal; var CostLCY: Decimal; var TotalAdjCostLCY: Decimal; var LineQty: Decimal; var TotalNetWeight: Decimal; var TotalGrossWeight: Decimal; var TotalVolume: Decimal; var TotalParcels: Decimal; var IsHandled: Boolean; var VATPercentage: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalculateTotalsOnAfterAddLineTotals(var SalesInvLine: Record "Sales Invoice Line"; var CustAmount: Decimal; var AmountInclVAT: Decimal; var InvDiscAmount: Decimal; var CostLCY: Decimal; var TotalAdjCostLCY: Decimal; var LineQty: Decimal; var TotalNetWeight: Decimal; var TotalGrossWeight: Decimal; var TotalVolume: Decimal; var TotalParcels: Decimal; SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
    end;
}

