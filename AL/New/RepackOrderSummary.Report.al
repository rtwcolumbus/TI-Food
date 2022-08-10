report 37002212 "Repack Order Summary"
{
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 25 JUL 07
    //   Summary report of finished repack orders with cost of consumption and output
    // 
    // PR5.00
    // P8000504A, VerticalSoft, Jack Reynolds, 10 AUG 07
    //   Modify to show costing quantity
    // 
    // PRW16.00.03
    // P8000813, VerticalSoft, MMAS, 29 APR 10
    //   Report design for RTC
    // 
    // PRW16.00.04
    // P8000843, VerticalSoft, Jack Reynolds, 15 JUL 10
    //   Fix problem with total order cost (RTC)
    // 
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW17.00
    // P8001134, Columbus IT, Don Bresee, 25 FEB 13
    //   Eliminate use of BOM Ledger table, use new "Order Type" field
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/RepackOrderSummary.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Repack Order Summary';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Repack Order"; "Repack Order")
        {
            RequestFilterFields = "No.", "Posting Date", "Item No.";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(RepackOrderNo; "No.")
            {
                IncludeCaption = true;
            }
            column(RepackOrderPostingDate; "Posting Date")
            {
                IncludeCaption = true;
            }
            column(RepackOrderItemNo; "Item No.")
            {
                IncludeCaption = true;
            }
            column(RepackOrderDesc; Description)
            {
                IncludeCaption = true;
            }
            column(RepackOrderLotNo; "Lot No.")
            {
                IncludeCaption = true;
            }
            column(RepackOrderQuantityProduced; "Quantity Produced")
            {
            }
            column(RepackOrderUOMCode; "Unit of Measure Code")
            {
            }
            column(LineCost; TotalCost)
            {
                AutoFormatType = 1;
            }
            column(UnitCost; UnitCost)
            {
                AutoFormatType = 2;
            }
            dataitem("Repack Order Line"; "Repack Order Line")
            {
                DataItemLink = "Order No." = FIELD("No.");
                DataItemTableView = SORTING("Order No.", "Line No.");
                column(RepackOrderLineType; Type)
                {
                }
                column(RepackOrderLineNo; "No.")
                {
                }
                column(RepackOrderLineDesc; Description)
                {
                }
                column(RepackOrderLineUOMCode; "Unit of Measure Code")
                {
                }
                column(RepackOrderLineQuantityConsumed; "Quantity Consumed")
                {
                }
                column(RepackOrderLineLotNo; "Lot No.")
                {
                }
                column(RepackOrderLineLineCost; LineCost)
                {
                    AutoFormatType = 1;
                }
                column(RepackOrderLineLineNo; "Line No.")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    LineCost := 0;
                    ItemLedger.SetRange("Order No.", "Order No.");
                    ItemLedger.SetRange("Order Line No.", "Line No.");
                    ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::"Negative Adjmt.");
                    if ItemLedger.FindFirst then begin
                        ItemLedger.CalcFields("Cost Amount (Actual)");
                        LineCost := -ItemLedger."Cost Amount (Actual)";
                        // P8000504A
                        Item.Get("No.");
                        if Item.CostInAlternateUnits then begin
                            "Quantity Consumed" := "Quantity Consumed (Alt.)";
                            "Unit of Measure Code" := Item."Alternate Unit of Measure";
                        end;
                        // P8000504A
                    end else begin
                        ResLedger.SetRange("Order No.", "Order No.");
                        ResLedger.SetRange("Order Line No.", "Line No.");
                        if ResLedger.FindFirst then
                            LineCost := ResLedger."Total Cost";
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                ItemLedger.SetRange("Order No.", "No.");
                ItemLedger.SetRange("Order Line No.");
                ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::"Positive Adjmt.");
                if ItemLedger.FindFirst then begin
                    ItemLedger.CalcFields("Cost Amount (Actual)");
                    TotalCost := ItemLedger."Cost Amount (Actual)"; // P8000843
                                                                    // P8000504A
                    Item.Get("Item No.");
                    if Item.CostInAlternateUnits then begin
                        "Quantity Produced" := "Quantity Produced (Alt.)";
                        "Unit of Measure Code" := Item."Alternate Unit of Measure";
                    end;
                    // P8000504A
                    if "Quantity Produced" <> 0 then
                        UnitCost := TotalCost / "Quantity Produced" // P8000843
                    else
                        UnitCost := 0;
                end else begin
                    TotalCost := 0; // P8000843
                    UnitCost := 0;
                end;
            end;

            trigger OnPreDataItem()
            begin
                ItemLedger.SetCurrentKey("Order Type", "Order No.", "Order Line No.");
                ItemLedger.SetRange("Order Type", ItemLedger."Order Type"::FOODRepack);

                ResLedger.SetCurrentKey("Order Type", "Order No.", "Order Line No.");
                ResLedger.SetRange("Order Type", ResLedger."Order Type"::FOODRepack);
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
        RepackOrderSummaryCaption = 'Repack Order Summary';
        PAGENOCaption = 'Page';
        QuantityProducedCaption = 'Quantity';
        UOMCodeCaption = 'Unit of Measure';
        LineCostCaption = 'Total Cost';
        UnitCostCaption = 'Unit Cost';
    }

    var
        ItemLedger: Record "Item Ledger Entry";
        ResLedger: Record "Res. Ledger Entry";
        Item: Record Item;
        LineCost: Decimal;
        TotalCost: Decimal;
        UnitCost: Decimal;
}

