report 37002664 "Sales Below Price"
{
    // PRW16.00.05
    // P8000970, Columbus IT, Jack Reynolds, 07 NOV 11
    //   Report of sales below standard price
    // 
    // P8000981, Columbus IT, Don Bresee, 20 SEP 11
    //   Separate Costing and Pricing units
    // 
    // PRW17.10
    // P8001223, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Expand filter variables
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/SalesBelowPrice.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Sales Below Price';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Customer; Customer)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Customer Price Group";
            column(CompanyInfoName; CompanyInfo.Name)
            {
            }
            column(ItemLedgEntryFilter; ItemLedgEntryFilter)
            {
            }
            column(STRMinPctDiff; StrSubstNo(Text001, MinPctDiff))
            {
            }
            column(CustNo; "No.")
            {
            }
            column(CustName; Name)
            {
                IncludeCaption = true;
            }
            dataitem("Item Ledger Entry"; "Item Ledger Entry")
            {
                DataItemLink = "Source No." = FIELD("No.");
                DataItemTableView = SORTING("Source Type", "Source No.", "Item No.", "Variant Code", "Posting Date") WHERE("Source Type" = CONST(Customer), "Document Type" = CONST("Sales Shipment"), Positive = CONST(false));
                RequestFilterFields = "Item No.", "Posting Date";
                column(ILEItemNo; "Item No.")
                {
                    IncludeCaption = true;
                }
                column(ILEPostingDate; "Posting Date")
                {
                    IncludeCaption = true;
                }
                column(ILEDocNo; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(ILEQuantity; -Quantity / "Qty. per Unit of Measure")
                {
                    DecimalPlaces = 0 : 5;
                }
                column(ILEUOMCode; "Unit of Measure Code")
                {
                }
                column(ItemDesc; Item.Description)
                {
                }
                column(ValueEntrySalespersPurchCode; ValueEntry."Salespers./Purch. Code")
                {
                }
                column(SalesPrice; SalesPrice)
                {
                    AutoFormatType = 2;
                }
                column(PriceListPrice; PriceListPrice)
                {
                    AutoFormatType = 2;
                }
                column(PriceDifference; PriceDifference)
                {
                    DecimalPlaces = 2 : 2;
                }
                column(UnitCost; UnitCost)
                {
                    AutoFormatType = 2;
                }
                column(PricingUOM; PricingUOM)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Item.Get("Item No.");
                    CalcFields("Sales Amount (Actual)", "Sales Amount (Expected)");
                    //SalesPrice := -("Sales Amount (Actual)" + "Sales Amount (Expected)") / GetCostingQty; // P8000981
                    SalesPrice := -("Sales Amount (Actual)" + "Sales Amount (Expected)") / GetPricingQty;   // P8000981
                    //IF NOT Item.CostInAlternateUnits THEN BEGIN // P8000981
                    if not Item.PriceInAlternateUnits then begin  // P8000981
                        SalesPrice := SalesPrice * "Qty. per Unit of Measure";
                        PricingUOM := "Unit of Measure Code";
                    end else
                        PricingUOM := Item."Alternate Unit of Measure";
                    PriceCalcMgmt.FindCustomerPriceListPrice(Item, Customer, "Variant Code", "Unit of Measure Code", "Posting Date", true);
                    PriceListPrice := Item."Unit Price";
                    if PriceListPrice = 0 then
                        CurrReport.Skip;
                    PriceDifference := 100 * (PriceListPrice - SalesPrice) / PriceListPrice;
                    if PriceDifference < MinPctDiff then
                        CurrReport.Skip;

                    CalcFields("Cost Amount (Actual)", "Cost Amount (Expected)");
                    UnitCost := ("Cost Amount (Actual)" + "Cost Amount (Expected)") / GetCostingQty;
                    if not Item.CostInAlternateUnits then
                        UnitCost := UnitCost * "Qty. per Unit of Measure";

                    ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
                    ValueEntry.SetRange("Item Ledger Entry No.", "Entry No.");
                    ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
                    if not ValueEntry.FindFirst then
                        Clear(ValueEntry);
                end;
            }
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(MinPctDiff; MinPctDiff)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Minimum Percent Difference';
                        DecimalPlaces = 0 : 2;
                        MinValue = 0;
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        SalesBelowPriceCaption = 'Sales Below Price';
        PageNoCaption = 'Page';
        CustNoCaption = 'Customer No.';
        QuantityCaption = 'Quantity';
        UOMCaption = 'UOM';
        DescCaption = 'Description';
        SalespersonCaption = 'Sales Person';
        SalesPriceCaption = 'Sales Price';
        PriceListPriceCaption = 'Price List';
        PriceDifferenceCaption = 'Percent Diff.';
        UnitCostCaption = 'Unit Cost';
        PricingUOMCaption = 'Pricing UOM';
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get;
        ItemLedgEntryFilter := "Item Ledger Entry".GetFilters;
    end;

    var
        CompanyInfo: Record "Company Information";
        Item: Record Item;
        ValueEntry: Record "Value Entry";
        PriceCalcMgmt: Codeunit "Sales Price Calc. Mgt.";
        ItemLedgEntryFilter: Text;
        MinPctDiff: Decimal;
        SalesPrice: Decimal;
        PriceListPrice: Decimal;
        PriceDifference: Decimal;
        UnitCost: Decimal;
        Text001: Label 'Percent Difference of %1 and Greater';
        PricingUOM: Code[10];
}

