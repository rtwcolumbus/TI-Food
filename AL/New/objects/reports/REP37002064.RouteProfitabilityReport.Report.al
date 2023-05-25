report 37002064 "Route Profitability Report" // Version: FOODNA
{
    // PR3.70.10
    // P8000233A, Myers Nissi, Phyllis McGovern, 21 JUL 05
    //   New Report Added
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Key change on value entry table
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 19 JUN 08
    //   Add caption property
    // 
    // PRW16.00.03
    // P8000813, VerticalSoft, MMAS, 16 APR 10
    //   Report design for RTC
    //     1. Function ComputeGrossProfit() is duplicated in Report Code
    //     2. DateFormat is applied to the field "Date"
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Set RDLC PageWidth and PageHeight to proper values for Landscape
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultRenderingLayout = StandardRDLCLayout;

    Caption = 'Route Profitability Report';

    dataset
    {
        dataitem("Report Header"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(ItemSummary; ItemSummary)
            {
            }
            dataitem("Delivery Route"; "Delivery Route")
            {
                DataItemTableView = SORTING("No.");
                PrintOnlyIfDetail = true;
                RequestFilterFields = "No.";
                column(DeliveryRouteNoDesc; "Delivery Route"."No." + ' ' + "Delivery Route".Description)
                {
                }
                column(DeliveryRouteNo; "No.")
                {
                }
                dataitem("Item Ledger Entry"; "Item Ledger Entry")
                {
                    DataItemLink = "Delivery Route No." = FIELD("No.");
                    DataItemTableView = SORTING("Delivery Route No.", "Source Type", "Source No.", "Item No.", "Variant Code", "Posting Date") WHERE("Entry Type" = CONST(Sale), "Source Type" = CONST(Customer));
                    RequestFilterFields = "Item No.", "Posting Date";
                    column(ILESourceNo; "Source No.")
                    {
                    }
                    column(ILEPostingDate; "Posting Date")
                    {
                    }
                    column(ILEItemNo; "Item No.")
                    {
                    }
                    column(Units; Units)
                    {
                    }
                    column(ILESalesAmountActual; "Sales Amount (Actual)")
                    {
                    }
                    column(CostAmount; CostAmount)
                    {
                    }
                    column(ItemDesc; Item.Description)
                    {
                    }
                    column(CustName; Customer.Name)
                    {
                    }
                    column(UnitPrice; UnitPrice)
                    {
                    }
                    column(GrossProfit; GrossProfit)
                    {
                    }
                    column(Profit1; "Profit%")
                    {
                    }
                    column(Units2; Units)
                    {
                    }
                    column(ILESalesAmountActual2; "Sales Amount (Actual)")
                    {
                    }
                    column(CostAmount2; CostAmount)
                    {
                    }
                    column(Text001; Text001)
                    {
                    }
                    column(Units3; Units)
                    {
                    }
                    column(ILESalesAmountActual3; "Sales Amount (Actual)")
                    {
                    }
                    column(CostAmount3; CostAmount)
                    {
                    }
                    column(GrossProfit3; GrossProfit)
                    {
                    }
                    column(Profit3; "Profit%")
                    {
                    }
                    column(CostAmount4; CostAmount)
                    {
                    }
                    column(ILESalesAmountActual4; "Sales Amount (Actual)")
                    {
                    }
                    column(Units4; Units)
                    {
                    }
                    column(GrossProfit4; GrossProfit)
                    {
                    }
                    column(Profit4; "Profit%")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Customer.Get("Source No.");
                        Item.Get("Item No.");

                        if ReportInAltUOM and (Item."Alternate Unit of Measure" = '') then
                            CurrReport.Skip;

                        if ReportInAltUOM = true then
                            Units := -"Invoiced Quantity (Alt.)"
                        else
                            Units := -"Invoiced Quantity";

                        //Lookup Invoice for Unit Price
                        UnitPrice := 0;
                        //ValueEntry.SETCURRENTKEY("Item Ledger Entry No.","Expected Cost","Valuation Date"); // P8000466A
                        ValueEntry.SetCurrentKey("Item Ledger Entry No.");                                    // P8000466A
                        ValueEntry.SetRange("Item Ledger Entry No.", "Entry No.");
                        ValueEntry.SetRange("Expected Cost", false);                                           // P8000466A
                        if ValueEntry.Find('-') then begin
                            InvoiceLine.SetCurrentKey("Document No.", "Line No.");
                            InvoiceLine.SetFilter("Document No.", ValueEntry."Document No.");
                            InvoiceLine.SetRange(Type, InvoiceLine.Type::Item);
                            InvoiceLine.SetFilter("No.", "Item No.");
                            if InvoiceLine.Find('-') then
                                UnitPrice := InvoiceLine."Unit Price"
                            else
                                CurrReport.Skip;
                        end else begin
                            CurrReport.Skip;
                        end;

                        if CostAtStandard then begin
                            if Item."Costing Unit" = Item."Costing Unit"::Alternate then
                                CostAmount := Units * Item."Standard Cost"
                            else
                                CostAmount := (Item."Standard Cost" * "Item Ledger Entry"."Qty. per Unit of Measure") * Units;
                        end else begin
                            CalcFields("Cost Amount (Actual)");
                            CostAmount := "Cost Amount (Actual)" * -1;
                        end;
                        ComputeGrossProfit(GrossProfit, "Sales Amount (Actual)", CostAmount);
                    end;

                    trigger OnPreDataItem()
                    begin
                        LastFieldNo := FieldNo("Item No.");
                    end;
                }
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
                    field(CostAtStandard; CostAtStandard)
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = Text19016136;
                    }
                    field(ReportInAltUOM; ReportInAltUOM)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Show Quantity in Alternate UOM';
                    }
                    field(ItemSummary; ItemSummary)
                    {
                        ApplicationArea = FOODBasic;
                        CaptionClass = Text19013599;
                    }
                }
            }
        }

        actions
        {
        }
    }

    rendering
    {
        layout(StandardRDLCLayout)
        {
            Summary = 'Standard Layout';
            Type = RDLC;
            LayoutFile = './layout/RouteProfitabilityReport.rdlc';
        }
    }

    labels
    {
        PAGENOCaption = 'Page';
        RouteProfitabilityCaption = 'Route Profitability';
        CostAmountCaption = 'Cost Amount';
        SalesAmountCaption = 'Sales Amount';
        QuantityCaption = 'Quantity';
        ItemDescriptionCaption = 'Item Description';
        ItemNoCaption = 'Item No.';
        DateCaption = 'Date';
        CustomerNameCaption = 'Customer Name';
        CustomerNoCaption = 'Customer No.';
        UnitPriceCaption = 'Unit Price';
        GrossProfitCaption = 'Gross Profit';
        GrossProfitPerCaption = '  Gross Profit %';
        LastUnitPriceCaption = 'Last Unit Price';
        LastDateCaption = 'Last Date';
        RouteCaption = 'Route:';
        RouteTotalsCaption = 'Route Totals';
        DateFormat = 'MM/dd/yy';
    }

    var
        LastFieldNo: Integer;
        FooterPrinted: Boolean;
        Item: Record Item;
        Customer: Record Customer;
        ValueEntry: Record "Value Entry";
        InvoiceLine: Record "Sales Invoice Line";
        ItemSummary: Boolean;
        CostAtStandard: Boolean;
        ReportInAltUOM: Boolean;
        Units: Decimal;
        UnitPrice: Decimal;
        CostAmount: Decimal;
        GrossProfit: Decimal;
        "Profit%": Decimal;
        Text001: Label 'Customer Totals';
        Text19016136: Label 'Cost at Current Standard';
        Text19013599: Label 'Item in Summary';

    procedure ComputeGrossProfit(var GrossProfit: Decimal; SaleAmount: Decimal; CostAmount: Decimal)
    begin
        GrossProfit := SaleAmount - CostAmount;
        "Profit%" := 0;

        if SaleAmount <> 0 then
            "Profit%" := Round(100 * GrossProfit / SaleAmount, 0.1)
        else
            "Profit%" := 0;
    end;
}

