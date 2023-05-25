report 37002474 "Production Yield & Cost Report" // Version: FOODNA
{
    // PRW16.00.02
    // P8000764, VerticalSoft, Jack Reynolds, 01 FEB 10
    //   Production yield and cost report for items
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 22 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000837, VerticalSoft, Jack Reynolds, 07 JUL 10
    //   RDLC layout issues
    // 
    // PRW17.00
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues Property in the Request Page.
    // 
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10
    // P8001221, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Type added to Item table
    // 
    // P8001223, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Expand filter variables
    // 
    // PRW17.10.03
    // P8001332, Columbus IT, Jack Reynolds, 25 JUN 14
    //   Fix problems with calculating consumption and output for mult-line batch orders
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultRenderingLayout = StandardRDLCLayout;

    ApplicationArea = FOODBasic;
    Caption = 'Production Yield & Cost Report';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Production Order"; "Production Order")
        {
            DataItemTableView = SORTING(Status, "No.") WHERE(Status = CONST(Finished), Suborder = CONST(false));
            RequestFilterFields = "Finished Date";
            RequestFilterHeading = 'Finished Production Order';
            dataitem("Prod. Order Line"; "Prod. Order Line")
            {
                DataItemLink = Status = FIELD(Status), "Prod. Order No." = FIELD("No.");
                DataItemTableView = SORTING(Status, "Prod. Order No.", "Line No.");

                trigger OnAfterGetRecord()
                begin
                    Item2.SetRange("No.", "Item No.");
                    if not Item2.FindFirst then
                        CurrReport.Skip;

                    if not SharedConsumpCalculated then begin
                        SharedConsumpQty := 0;
                        Consumption.SetRange("Order No.", "Prod. Order No."); // P8001132
                        Consumption.SetRange("Order Line No.", 0);            // P8001132
                        Consumption.SetRange("Item No.");
                        if Consumption.FindSet then
                            repeat
                                // Consumption entries are negative, so subtraction is equivalent to adding the opposite
                                SharedConsumpQty -= ConvertQtyToRptUOM(Consumption."Item No.", Consumption.Quantity, Consumption."Quantity (Alt.)");
                            until Consumption.Next = 0;
                    end;
                    SharedConsumpCalculated := true;

                    ConsumpQty := 0;
                    Consumption.SetRange("Order No.", "Prod. Order No."); // P8001132
                    Consumption.SetRange("Order Line No.", "Line No.");   // P8001132
                    Consumption.SetRange("Item No."); // P8001332
                    if Consumption.FindSet then
                        repeat
                            ConsumpQty -= ConvertQtyToRptUOM(Consumption."Item No.", Consumption.Quantity, Consumption."Quantity (Alt.)");
                        until Consumption.Next = 0;

                    OutputFound := false;
                    OutputQty := 0;
                    SubOrder.SetRange("Batch Prod. Order No.", "Prod. Order No.");
                    if SubOrder.FindSet then begin
                        repeat
                            SubOrderLine.SetRange(Status, SubOrderLine.Status::Finished);
                            SubOrderLine.SetRange("Prod. Order No.", SubOrder."No.");
                            if SubOrderLine.FindSet then
                                repeat
                                    Consumption.SetRange("Order No.", SubOrderLine."Prod. Order No."); // P8001132
                                    Consumption.SetRange("Order Line No.", SubOrderLine."Line No.");   // P8001132
                                    Consumption.SetRange("Item No.", "Item No.");
                                    if not Consumption.IsEmpty then begin
                                        if not SubOrderLine.Mark then // P8001332
                                            OutputQty += ConvertQtyToRptUOM(SubOrderLine."Item No.",
                                              SubOrderLine."Finished Qty. (Base)", SubOrderLine."Finished Qty. (Alt.)");
                                        OutputFound := true;
                                        SubOrderLine.Mark(true); // P8001332
                                    end;
                                until SubOrderLine.Next = 0;
                        until SubOrder.Next = 0;
                    end;
                    if not OutputFound then
                        OutputQty := ConvertQtyToRptUOM("Item No.", "Finished Qty. (Base)", "Finished Qty. (Alt.)");

                    MaterialCost := 0;
                    LaborCost := 0;
                    OverheadCost := 0;

                    ValueEntry.SetRange("Order No.", "Prod. Order No."); // P8001132
                    ValueEntry.SetRange("Order Line No.", "Line No.");   // P8001132
                    ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Output);
                    ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
                    if ValueEntry.FindSet then
                        repeat
                            MaterialCost += ValueEntry."Cost Amount (Actual)"; // We'll subtract out capacity cost later
                        until ValueEntry.Next = 0;
                    ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Output);
                    ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Indirect Cost");
                    if ValueEntry.FindSet then
                        repeat
                            OverheadCost += ValueEntry."Cost Amount (Actual)";
                        until ValueEntry.Next = 0;
                    ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::" ");
                    ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
                    if ValueEntry.FindSet then
                        repeat
                            LaborCost += ValueEntry."Cost Amount (Actual)";
                            MaterialCost -= ValueEntry."Cost Amount (Actual)";
                        until ValueEntry.Next = 0;
                    ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::" ");
                    ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Indirect Cost");
                    if ValueEntry.FindSet then
                        repeat
                            OverheadCost += ValueEntry."Cost Amount (Actual)";
                            MaterialCost -= ValueEntry."Cost Amount (Actual)";
                        until ValueEntry.Next = 0;

                    if not ProdOrderTemp.Get("Item No.", "Prod. Order No.") then begin
                        ProdOrderTemp.Init;
                        ProdOrderTemp."Item No." := "Item No.";
                        ProdOrderTemp."Prod. Order No." := "Prod. Order No.";
                        ProdOrderTemp."Prod. Order Date" := "Production Order"."Finished Date";
                        ProdOrderTemp.Insert;
                    end;
                    if not ItemCategoryTemp.Get(Item2."Item Category Code") then begin
                        ItemCategoryTemp.Code := Item2."Item Category Code";
                        ItemCategoryTemp.Insert;
                        ProdOrderTemp."Category Consumption" += SharedConsumpQty;
                    end;
                    ProdOrderTemp.Consumption += ConsumpQty + SharedConsumpQty;
                    ProdOrderTemp."Category Consumption" += ConsumpQty;
                    ProdOrderTemp.Output += OutputQty;
                    ProdOrderTemp."Material Cost" += MaterialCost;
                    ProdOrderTemp."Labor Cost" += LaborCost;
                    ProdOrderTemp."Overhead Cost" += OverheadCost;
                    ProdOrderTemp.Modify;
                end;

                trigger OnPreDataItem()
                begin
                    ItemCategoryTemp.DeleteAll;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                SharedConsumpCalculated := false;
            end;
        }
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("Item Category Code") WHERE(Type = CONST(Inventory));
            RequestFilterFields = "Item Category Code", "No.";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(STRRptUOM; StrSubstNo(Text003, RptUOM))
            {
            }
            column(ItemTabCapItemFilter; Item.TableCaption + ': ' + ItemFilter)
            {
            }
            column(ProdOrderTabCapOrderFilter; "Production Order".TableCaption + ': ' + OrderFilter)
            {
            }
            column(CostPerHeading; CostPerHeading)
            {
            }
            column(ItemItemCategoryCode; "Item Category Code")
            {
            }
            column(ItemNo; "No.")
            {
                IncludeCaption = true;
            }
            column(ItemDesc; Description)
            {
                IncludeCaption = true;
            }
            column(ConsumpQty; ConsumpQty)
            {
                DecimalPlaces = 0 : 0;
            }
            column(CategoryConsumpQty; CategoryConsumpQty)
            {
            }
            column(OutputQty; OutputQty)
            {
                DecimalPlaces = 0 : 5;
            }
            column(V100_Divide_OutputQty_ConsumpQty; 100 * Divide(OutputQty, ConsumpQty))
            {
                DecimalPlaces = 2 : 2;
            }
            column(MaterialCost; MaterialCost)
            {
                DecimalPlaces = 0 : 0;
            }
            column(LaborCost; LaborCost)
            {
                DecimalPlaces = 0 : 0;
            }
            column(OverheadCost; OverheadCost)
            {
                DecimalPlaces = 0 : 0;
            }
            column(MaterialCost_LaborCost_OverheadCost; MaterialCost + LaborCost + OverheadCost)
            {
                DecimalPlaces = 0 : 0;
            }
            column(DivideMaterialCost_LaborCost_OverheadCost_OutputQty; Divide(MaterialCost + LaborCost + OverheadCost, OutputQty))
            {
                AutoFormatExpression = '';
                AutoFormatType = 2;
            }
            column(ItemHeader; 'Item')
            {
            }
            column(HideDetail; HideDetail)
            {
            }
            column(ItemFilter; ItemFilter)
            {
            }
            column(OrderFilter; OrderFilter)
            {
            }
            column(V100_DivideOutputQty_CategoryConsumpQty; 100 * Divide(OutputQty, CategoryConsumpQty))
            {
                DecimalPlaces = 2 : 2;
            }
            column(STRItemCategoryCode; StrSubstNo(Text002, Item."Item Category Code"))
            {
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(ProdOrderTempConsumption; ProdOrderTemp.Consumption)
                {
                    DecimalPlaces = 0 : 0;
                }
                column(ProdOrderTempOutput; ProdOrderTemp.Output)
                {
                    DecimalPlaces = 0 : 5;
                }
                column(V100_DivideProdOrderTempOutput_Consumption; 100 * Divide(ProdOrderTemp.Output, ProdOrderTemp.Consumption))
                {
                    DecimalPlaces = 2 : 2;
                }
                column(ProdOrderTempProdOrderDate; ProdOrderTemp."Prod. Order Date")
                {
                }
                column(ProdOrderTempProdOrderNo; ProdOrderTemp."Prod. Order No.")
                {
                }
                column(ProdOrderTempMaterialCost; ProdOrderTemp."Material Cost")
                {
                    DecimalPlaces = 0 : 0;
                }
                column(ProdOrderTempLaborCost; ProdOrderTemp."Labor Cost")
                {
                    DecimalPlaces = 0 : 0;
                }
                column(ProdOrderTempOverheadCost; ProdOrderTemp."Overhead Cost")
                {
                    DecimalPlaces = 0 : 0;
                }
                column(ProdOrderTempMaterialCost_LaborCost_OverheadCost; ProdOrderTemp."Material Cost" + ProdOrderTemp."Labor Cost" + ProdOrderTemp."Overhead Cost")
                {
                    DecimalPlaces = 0 : 0;
                }
                column(DivideProdOrderTempMaterialCost_LaborCost_OverheadCost__Output; Divide(ProdOrderTemp."Material Cost" + ProdOrderTemp."Labor Cost" + ProdOrderTemp."Overhead Cost", ProdOrderTemp.Output))
                {
                    AutoFormatExpression = '';
                    AutoFormatType = 2;
                }
                column(IntegerRec; Format(Number))
                {
                }
                column(IntegerHeader; 'Integer')
                {
                }
                column(STRItemNo; StrSubstNo(Text001, Item."No."))
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        ProdOrderTemp.Find('-')
                    else
                        ProdOrderTemp.Next;

                    if Number > 1 then         // P8001332
                        CategoryConsumpQty := 0; // P8001332
                end;

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, OrderCount);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                ProdOrderTemp.SetRange("Item No.", "No.");
                OrderCount := ProdOrderTemp.Count;
                if OrderCount = 0 then
                    CurrReport.Skip;

                ProdOrderTemp.CalcSums(Consumption, "Category Consumption", Output, "Material Cost", "Labor Cost", "Overhead Cost");
                ConsumpQty := ProdOrderTemp.Consumption;
                CategoryConsumpQty := ProdOrderTemp."Category Consumption";
                OutputQty := ProdOrderTemp.Output;
                MaterialCost := ProdOrderTemp."Material Cost";
                LaborCost := ProdOrderTemp."Labor Cost";
                OverheadCost := ProdOrderTemp."Overhead Cost";
            end;

            trigger OnPreDataItem()
            begin
                ProdOrderTemp.SetCurrentKey("Item No.", "Prod. Order Date");
            end;
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
                    field(RptUOM; RptUOM)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Reporting Unit of Measure';
                        TableRelation = "Unit of Measure" WHERE(Type = FILTER(Weight | Volume));
                    }
                    field(HideDetail; HideDetail)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Hide Detail';
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
            LayoutFile = './layout/ProductionYieldCostReport.rdlc';
        }
    }

    labels
    {
        DateFormat = 'MM/dd/yy';
        ProdYieldandCostReportCaption = 'Production Yield and Cost Report';
        PAGENOCaption = 'Page';
        ItemCategoryCodeCaption = 'Item Category';
        ConsumpQtyCaption = 'Quantity Consumed';
        OutputQtyCaption = 'Quantity Output';
        YieldPerCaption = 'Yield %';
        FinishedDateCaption = 'Finished Date';
        OrderNoCaption = 'Order No.';
        MaterialCostCaption = 'Material Cost';
        LaborCostCaption = 'Labor Cost';
        OverheadCostCaption = 'Overhead Cost';
        TotalCostCaption = 'Total Cost';
    }

    trigger OnPreReport()
    begin
        Item2.Copy(Item);
        Item2.FilterGroup(9);

        if RptUOM = '' then begin
            InvSetup.Get;
            MeasuringSystem.Get(InvSetup."Measuring System", MeasuringSystem.Type::Weight);
            RptUOM := MeasuringSystem.UOM;
            RptUOMType := MeasuringSystem.Type::Weight;
            RptUOMFromBase := 1;
        end else begin
            UOM.Get(RptUOM);
            RptUOMType := UOM.Type;
            RptUOMFromBase := 1 / UOM."Base per Unit of Measure";
        end;
        CostPerHeading := StrSubstNo(Text004, RptUOM);

        SubOrder.SetCurrentKey(Status, "Batch Prod. Order No.", "No.");
        SubOrder.SetRange(Status, SubOrder.Status::Finished);
        SubOrder.SetRange(Suborder, true);

        Consumption.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type"); // P8001132
        Consumption.SetRange("Order Type", Consumption."Order Type"::Production); // P8001132
        Consumption.SetRange("Entry Type", Consumption."Entry Type"::Consumption);

        ValueEntry.SetCurrentKey("Order Type", "Order No."); // P8001132
        ValueEntry.SetRange("Order Type", ValueEntry."Order Type"::Production); // P8001132

        ItemFilter := Item.GetFilters;
        OrderFilter := "Production Order".GetFilters;
    end;

    var
        Item2: Record Item;
        ItemUOMTemp: Record Item temporary;
        Consumption: Record "Item Ledger Entry";
        SubOrder: Record "Production Order";
        SubOrderLine: Record "Prod. Order Line";
        ValueEntry: Record "Value Entry";
        InvSetup: Record "Inventory Setup";
        MeasuringSystem: Record "Measuring System";
        UOM: Record "Unit of Measure";
        ProdOrderTemp: Record "Production Yield Report" temporary;
        ItemCategoryTemp: Record "Item Category" temporary;
        ItemFilter: Text;
        OrderFilter: Text;
        RptUOM: Code[10];
        RptUOMType: Integer;
        RptUOMFromBase: Decimal;
        CostPerHeading: Text[30];
        HideDetail: Boolean;
        SharedConsumpCalculated: Boolean;
        SharedConsumpQty: Decimal;
        ConsumpQty: Decimal;
        CategoryConsumpQty: Decimal;
        OutputQty: Decimal;
        LaborCost: Decimal;
        MaterialCost: Decimal;
        OverheadCost: Decimal;
        ResDirectCost: Decimal;
        OutputFound: Boolean;
        OrderCount: Integer;
        Text001: Label 'Total for Item: %1';
        Text002: Label 'Total for Category: %1';
        Text003: Label 'Unit of Measure: %1';
        Text004: Label 'Cost per %1';

    procedure ConvertQtyToRptUOM(ItemNo: Code[20]; Quantity: Decimal; AltQuantity: Decimal): Decimal
    var
        Item: Record Item;
        UOM: Record "Unit of Measure";
        ItemUOM: Record "Item Unit of Measure";
    begin
        // It is expected that the same items will keep recurring so rather then spend the resources to determine the
        // conversion factor to the reporting UOM each time the item is encountered, we will use a temp table to store
        // the conversion factor for each item that is processed.  Subsequents requests to convert these items will obtain
        // the conversion factor form the temp table.
        // We need a table that is keyed by item number and has a decimal field to contain the conversion factor and another
        // field to indicate if the conversion factor is to be applied to the quantity or alternate quantity.
        // The Item table will serve our purpose.  The conversion factor will be stored in the "Unit Price" field and the
        // Search Description will be used to indicate which quantity to use.

        if ItemUOMTemp.Get(ItemNo) then
            case ItemUOMTemp."Search Description" of
                'BASE':
                    exit(Quantity * ItemUOMTemp."Unit Price");
                'ALT':
                    exit(AltQuantity * ItemUOMTemp."Unit Price");
                else
                    exit(0);
            end;

        Item.Get(ItemNo);
        if Item."Item Type" = Item."Item Type"::Packaging then begin
            ItemUOMTemp."No." := Item."No.";
            ItemUOMTemp."Search Description" := '';
            ItemUOMTemp."Unit Price" := 0;
            ItemUOMTemp.Insert;
            exit;
        end;

        UOM.Get(Item."Base Unit of Measure");
        if UOM.Type = RptUOMType then begin
            ItemUOMTemp."No." := Item."No.";
            ItemUOMTemp."Search Description" := 'BASE';
            ItemUOMTemp."Unit Price" := UOM."Base per Unit of Measure" * RptUOMFromBase;
            ItemUOMTemp.Insert;
            exit(Quantity * ItemUOMTemp."Unit Price");
        end;

        if Item."Alternate Unit of Measure" <> '' then begin
            UOM.Get(Item."Alternate Unit of Measure");
            if UOM.Type = RptUOMType then begin
                ItemUOMTemp."No." := Item."No.";
                ItemUOMTemp."Search Description" := 'ALT';
                ItemUOMTemp."Unit Price" := UOM."Base per Unit of Measure" * RptUOMFromBase;
                ItemUOMTemp.Insert;
                exit(AltQuantity * ItemUOMTemp."Unit Price");
            end;
        end;

        ItemUOM.SetRange("Item No.", Item."No.");
        ItemUOM.SetRange(Type, RptUOMType);
        if ItemUOM.FindFirst then begin
            UOM.Get(ItemUOM.Code);
            ItemUOMTemp."No." := Item."No.";
            ItemUOMTemp."Search Description" := 'BASE';
            ItemUOMTemp."Unit Price" := UOM."Base per Unit of Measure" * RptUOMFromBase / ItemUOM."Qty. per Unit of Measure";
            ItemUOMTemp.Insert;
            exit(Quantity * ItemUOMTemp."Unit Price");
        end else begin
            ItemUOMTemp."No." := Item."No.";
            ItemUOMTemp."Search Description" := '';
            ItemUOMTemp."Unit Price" := 0;
            ItemUOMTemp.Insert;
        end;
    end;

    procedure Divide(Dividend: Decimal; Divisor: Decimal): Decimal
    begin
        if Divisor <> 0 then
            exit(Dividend / Divisor)
        else
            exit(0);
    end;
}

