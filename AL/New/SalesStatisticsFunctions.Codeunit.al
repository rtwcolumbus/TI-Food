codeunit 37002010 "Sales Statistics Functions"
{
    // PRW16.00.05
    // P8000981, Columbus IT, Don Bresee, 20 SEP 11
    //   Use Costing Qty for Sales Lines


    trigger OnRun()
    begin
    end;

    procedure GetTempSalesLine(DocType: Integer; DocNo: Code[20]; var TempSalesLine: Record "Sales Statistic Line" temporary)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        UseDate: Integer;
    begin
        TempSalesLine.Reset;
        TempSalesLine.DeleteAll;

        SalesHeader.Get(DocType, DocNo);
        if (SalesHeader."Document Type" in [SalesHeader."Document Type"::"Blanket Order", SalesHeader."Document Type"::Quote]) and
           (SalesHeader."Posting Date" = 0D)
        then
            SalesHeader."Posting Date" := WorkDate;

        SalesLine.SetRange("Document Type", DocType);
        SalesLine.SetRange("Document No.", DocNo);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.Find('-') then
            repeat
                TempSalesLine."Line No." := SalesLine."Line No.";
                TempSalesLine."No." := SalesLine."No.";
                TempSalesLine.Description := SalesLine.Description;
                //TempSalesLine.Quantity := SalesLine.GetPricingQty; // P8000981
                TempSalesLine.Quantity := SalesLine.GetCostingQty;   // P8000981
                TempSalesLine."Unit Price" := SalesLine."Unit Price";
                TempSalesLine."Line Discount" := SalesLine."Line Discount Amount";
                TempSalesLine."Line Amount" := SalesLine."Line Amount";
                TempSalesLine."Unit Cost (LCY)" := SalesLine."Unit Cost (LCY)";
                if Item.Get(SalesLine."No.") and Item.CostInAlternateUnits then
                    TempSalesLine."Unit of Measure Code" := Item."Alternate Unit of Measure"
                else
                    TempSalesLine."Unit of Measure Code" := SalesLine."Unit of Measure Code";
                TempSalesLine."Currency Code" := SalesLine."Currency Code";

                TempSalesLine.ConvertToLCY(SalesHeader."Posting Date", SalesHeader."Currency Factor");
                TempSalesLine.Calculate;
                TempSalesLine.Insert;
            until SalesLine.Next = 0;
    end;

    procedure GetTempSalesInvoiceLine(DocNo: Code[20]; var TempSalesInvoiceLine: Record "Sales Statistic Line" temporary)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        Item: Record Item;
    begin
        TempSalesInvoiceLine.Reset;
        TempSalesInvoiceLine.DeleteAll;

        SalesInvoiceHeader.Get(DocNo);

        SalesInvoiceLine.SetRange("Document No.", DocNo);
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        if SalesInvoiceLine.Find('-') then
            repeat
                TempSalesInvoiceLine."Line No." := SalesInvoiceLine."Line No.";
                TempSalesInvoiceLine."No." := SalesInvoiceLine."No.";
                TempSalesInvoiceLine.Description := SalesInvoiceLine.Description;
                TempSalesInvoiceLine.Quantity := SalesInvoiceLine.GetCostingQty;
                TempSalesInvoiceLine."Unit Price" := SalesInvoiceLine."Unit Price";
                TempSalesInvoiceLine."Line Discount" := SalesInvoiceLine."Line Discount Amount";
                TempSalesInvoiceLine."Line Amount" := SalesInvoiceLine."Line Amount";
                TempSalesInvoiceLine."Unit Cost (LCY)" := SalesInvoiceLine."Unit Cost (LCY)";
                if Item.Get(SalesInvoiceLine."No.") and Item.CostInAlternateUnits then
                    TempSalesInvoiceLine."Unit of Measure Code" := Item."Alternate Unit of Measure"
                else
                    TempSalesInvoiceLine."Unit of Measure Code" := SalesInvoiceLine."Unit of Measure Code";
                TempSalesInvoiceLine."Currency Code" := SalesInvoiceHeader."Currency Code";

                TempSalesInvoiceLine.ConvertToLCY(SalesInvoiceHeader."Posting Date", SalesInvoiceHeader."Currency Factor");
                TempSalesInvoiceLine.Calculate;
                TempSalesInvoiceLine.Insert;
            until SalesInvoiceLine.Next = 0;
    end;

    procedure GetTempSalesCrMemoLine(DocNo: Code[20]; var TempSalesCrMemoLine: Record "Sales Statistic Line" temporary)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        Item: Record Item;
    begin
        TempSalesCrMemoLine.Reset;
        TempSalesCrMemoLine.DeleteAll;

        SalesCrMemoHeader.Get(DocNo);

        SalesCrMemoLine.SetRange("Document No.", DocNo);
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        if SalesCrMemoLine.Find('-') then
            repeat
                TempSalesCrMemoLine."Line No." := SalesCrMemoLine."Line No.";
                TempSalesCrMemoLine."No." := SalesCrMemoLine."No.";
                TempSalesCrMemoLine.Description := SalesCrMemoLine.Description;
                TempSalesCrMemoLine.Quantity := SalesCrMemoLine.GetCostingQty;
                TempSalesCrMemoLine."Unit Price" := SalesCrMemoLine."Unit Price";
                TempSalesCrMemoLine."Line Discount" := SalesCrMemoLine."Line Discount Amount";
                TempSalesCrMemoLine."Line Amount" := SalesCrMemoLine."Line Amount";
                TempSalesCrMemoLine."Unit Cost (LCY)" := SalesCrMemoLine."Unit Cost (LCY)";
                if Item.Get(SalesCrMemoLine."No.") and Item.CostInAlternateUnits then
                    TempSalesCrMemoLine."Unit of Measure Code" := Item."Alternate Unit of Measure"
                else
                    TempSalesCrMemoLine."Unit of Measure Code" := SalesCrMemoLine."Unit of Measure Code";
                TempSalesCrMemoLine."Currency Code" := SalesCrMemoHeader."Currency Code";

                TempSalesCrMemoLine.ConvertToLCY(SalesCrMemoHeader."Posting Date", SalesCrMemoHeader."Currency Factor");
                TempSalesCrMemoLine.Calculate;
                TempSalesCrMemoLine.Insert;
            until SalesCrMemoLine.Next = 0;
    end;
}

