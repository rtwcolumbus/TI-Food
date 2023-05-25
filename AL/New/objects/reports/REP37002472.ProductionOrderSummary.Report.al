report 37002472 "Production Order Summary"
{
    // PR3.70.06
    // P8000081A, Myers Nissi, Jack Reynolds, 04 AUG 04
    //   Production order summary report showing posted output and consumption
    // 
    // PR3.70.07
    // P8000120A, Myers Nissi, Jack Reynolds, 22 SEP 04
    //   Fix problem with consumption lines for finshed orders
    //   Fix sign on variance
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Changes to Item Ledger keys
    // 
    // PR4.00.05
    // P8000416B, VerticalSoft, Jack Reynolds, 15 NOV 06
    //   Fix problem with not resetting labor totals
    // 
    // PRW15.00.01
    // P8000521A, VerticalSoft, Jack Reynolds, 14 SEP 07
    //   Fix problem with lookup list for No.
    // 
    // PRW15.00.03
    // P8000634A, VerticalSoft, Jack Reynolds, 02 OCT 08
    //   Fix incorrect overhead cost calculation
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 22 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW16.00.05
    // P8000925, Columbus IT, Jack Reynolds, 29 MAR 11
    //   Use Equipment Code fomr Prod Order Line when finding BOM Activities
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues Property in the Request Page.
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
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
    DefaultRenderingLayout = StandardRDLCLayout;

    ApplicationArea = FOODBasic;
    Caption = 'Production Order Summary';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Production Order"; "Production Order")
        {
            RequestFilterFields = Status, "No.";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(ProdOrderRec; Format(Status) + "No.")
            {
            }
            column(ProdOrderNo; "No.")
            {
            }
            column(ProdOrderBatchOrder; "Batch Order")
            {
            }
            dataitem("Prod. Order Line"; "Prod. Order Line")
            {
                DataItemLink = Status = FIELD(Status), "Prod. Order No." = FIELD("No.");
                DataItemTableView = SORTING(Status, "Prod. Order No.", "Line No.");
                column(ProdOrderLineVariantCode; "Variant Code")
                {
                    IncludeCaption = true;
                }
                column(ProdOrderLineDesc; Description)
                {
                    IncludeCaption = true;
                }
                column(ProdOrderLineQuantity; Quantity)
                {
                }
                column(ProdOrderLineFinishedQuantity; "Finished Quantity")
                {
                }
                column(ProdOrderLineItemNo; "Item No.")
                {
                    IncludeCaption = true;
                }
                column(ProdOrderLineUOMCode; "Unit of Measure Code")
                {
                }
                column(OutputYield; OutputYield)
                {
                    DecimalPlaces = 2 : 2;
                }
                column(ProdOrderLineRec; Format(Status) + "Prod. Order No." + Format("Line No."))
                {
                }
                column(ProdOrderLineHeader; 'ProdOrderLine')
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Item.Get("Item No.");
                    OverheadCost += Round(GetCostingQty(FieldNo("Finished Quantity")) *
                      Item.OverheadRate("Variant Code", "Location Code")); // P8000634A, P8001030

                    // If not a batch order then modify expected consumption to be based on actual output
                    if not "Production Order"."Batch Order" then begin
                        TempProdOrderComp.SetRange("Prod. Order Line No.", "Line No.");
                        if TempProdOrderComp.Find('-') then
                            repeat
                                Item.Get(TempProdOrderComp."Item No.");
                                Item.GetItemUOMRndgPrecision(TempProdOrderComp."Unit of Measure Code", true);
                                TempProdOrderComp."Expected Quantity" := Round(
                                  "Finished Quantity" * TempProdOrderComp."Quantity per", Item."Rounding Precision", '>');
                                TempProdOrderComp.Modify;
                            until TempProdOrderComp.Next = 0;
                    end;
                end;
            }
            dataitem(Consumption; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(TempProdOrderCompItemNo; TempProdOrderComp."Item No.")
                {
                }
                column(TempProdOrderCompVariantCode; TempProdOrderComp."Variant Code")
                {
                }
                column(TempProdOrderCompDesc; TempProdOrderComp.Description)
                {
                }
                column(TempProdOrderCompUOMCode; TempProdOrderComp."Unit of Measure Code")
                {
                }
                column(TempProdOrderCompQuantity; TempProdOrderComp.Quantity)
                {
                    DecimalPlaces = 0 : 5;
                }
                column(ConsumptionVariance; ConsumptionVariance)
                {
                    DecimalPlaces = 2 : 2;
                }
                column(TempProdOrderCompDirectCostAmount; TempProdOrderComp."Direct Cost Amount")
                {
                    DecimalPlaces = 2 : 2;
                }
                column(TempProdOrderCompExpectedQuantity; TempProdOrderComp."Expected Quantity")
                {
                    DecimalPlaces = 0 : 5;
                }
                column(ConsumptionRec; Format(Number))
                {
                }
                column(ConsumptionHeader; 'Consumption')
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        TempProdOrderComp.Find('-')
                    else
                        TempProdOrderComp.Next;

                    TempProdOrderComp.Quantity := TempProdOrderComp.Quantity / TempProdOrderComp."Qty. per Unit of Measure";

                    MaterialCost += TempProdOrderComp."Direct Cost Amount";
                end;

                trigger OnPreDataItem()
                begin
                    TempProdOrderComp.Reset;
                    SetRange(Number, 1, TempProdOrderComp.Count);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                TempProdOrderComp.Reset;
                TempProdOrderComp.DeleteAll;
                MaterialCost := 0;
                OverheadCost := 0;

                ProdOrderComp.SetRange(Status, Status);
                ProdOrderComp.SetRange("Prod. Order No.", "No.");
                if ProdOrderComp.Find('-') then
                    repeat
                        TempProdOrderComp := ProdOrderComp;
                        TempProdOrderComp.Quantity := 0;
                        TempProdOrderComp."Direct Cost Amount" := 0;
                        TempProdOrderComp.Insert;
                        if ProdOrderComp."Line No." > MaxLineNo then
                            MaxLineNo := ProdOrderComp."Line No.";
                    until ProdOrderComp.Next = 0;

                // Get actual consumptions, costs and items consumed that weren't components
                ItemLedger.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type", "Prod. Order Comp. Line No."); // P8000267B, P8001132
                ItemLedger.SetRange("Order Type", ItemLedger."Order Type"::Production); // P8001132
                ItemLedger.SetRange("Order No.", "No."); // P8001132
                ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::Consumption);
                TempProdOrderComp.SetRange(Status, Status); // P8000120A
                TempProdOrderComp.SetRange("Prod. Order No.", "No.");
                TempProdOrderComp.SetFilter("Line No.", '>%1', MaxLineNo);
                if ItemLedger.Find('-') then
                    repeat
                        ItemLedger.CalcFields("Cost Amount (Actual)");
                        if not TempProdOrderComp.Get(Status, ItemLedger."Order No.", // P8000120A, P8001132
                          ItemLedger."Order Line No.", ItemLedger."Prod. Order Comp. Line No.") // P8001132
                        then begin
                            TempProdOrderComp.SetRange("Prod. Order Line No.", ItemLedger."Order Line No."); // P8001132
                            TempProdOrderComp.SetRange("Item No.", ItemLedger."Item No.");
                            if not TempProdOrderComp.Find('-') then begin
                                MaxLineNo += 1;
                                Item.Get(ItemLedger."Item No.");
                                TempProdOrderComp.Init;
                                TempProdOrderComp.Status := Status; // P8000120A
                                TempProdOrderComp."Prod. Order No." := "No.";
                                TempProdOrderComp."Prod. Order Line No." := ItemLedger."Order Line No."; // P8001132
                                TempProdOrderComp."Line No." += MaxLineNo;
                                TempProdOrderComp."Item No." := ItemLedger."Item No.";
                                TempProdOrderComp."Variant Code" := ItemLedger."Variant Code";
                                TempProdOrderComp.Description := Item.Description;
                                TempProdOrderComp."Unit of Measure Code" := ItemLedger."Unit of Measure Code";
                                TempProdOrderComp."Qty. per Unit of Measure" := ItemLedger."Qty. per Unit of Measure";
                                TempProdOrderComp.Insert;
                            end;
                        end;
                        TempProdOrderComp.Quantity -= ItemLedger.Quantity;
                        TempProdOrderComp."Direct Cost Amount" -= ItemLedger."Cost Amount (Actual)";
                        TempProdOrderComp.Modify;
                    until ItemLedger.Next = 0;

                TempProdOrderComp.Reset;
            end;

            trigger OnPreDataItem()
            begin
                // P8000521A
                FilterGroup(2);
                SetFilter(Status, '%1|%2', Status::Released, Status::Finished);
                FilterGroup(0);
                // P8000521A
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
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
            LayoutFile = './layout/ProductionOrderSummary.rdlc';
        }
    }

    labels
    {
        ProdOrderSummaryCaption = 'Production Order Summary';
        PAGENOCaption = 'Page';
        ProdOrderNoCaption = 'Prod. Order No.';
        OutputCaption = 'Output';
        QuantityExpectedCaption = 'Quantity Expected';
        YieldCaption = 'Yield %';
        UOMCodeCaption = 'Unit of Measure';
        QuantityProducedCaption = 'Quantity Produced';
        ConsumptionCaption = 'Consumption';
        ItemNoCaption = 'Item No.';
        VariantCodeCaption = 'Variant Code';
        DescCaption = 'Description';
        QuantityConsumedCaption = 'Quantity Consumed';
        VarianceCaption = 'Variance %';
        CostCaption = 'Cost';
        QuantityRequiredCaption = 'Quantity Required';
        LaborCaption = 'Labor';
        ResourceNoCaption = 'Resource';
        ActualHrsCaption = 'Actual Hours';
        RequiredHrsCaption = 'Required Hours';
        MaterialCostCaption = 'Material Cost';
        TotalCostCaption = 'Total Cost';
        OverheadCostCaption = 'Overhead Cost';
    }

    var
        ProdOrderComp: Record "Prod. Order Component";
        TempProdOrderComp: Record "Prod. Order Component" temporary;
        ItemLedger: Record "Item Ledger Entry";
        Item: Record Item;
        MaxLineNo: Integer;
        MaterialCost: Decimal;
        OverheadCost: Decimal;
        BOMVersion: Record "Production BOM Version";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        P800BOMFns: Codeunit "Process 800 BOM Functions";

    procedure OutputYield(): Decimal
    begin
        if "Prod. Order Line".Quantity <> 0 then
            exit(100 * "Prod. Order Line"."Finished Quantity" / "Prod. Order Line".Quantity);
    end;

    procedure ConsumptionVariance(): Decimal
    begin
        if TempProdOrderComp."Expected Quantity" <> 0 then
            exit(100 * (TempProdOrderComp.Quantity - TempProdOrderComp."Expected Quantity") /  // P8000120A
              TempProdOrderComp."Expected Quantity");
    end;
}

