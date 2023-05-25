report 37002067 "Projected Shortage List"
{
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Lists items that are expected to be short
    // 
    // PRW16.00.03
    // P8000813, VerticalSoft, MMAS, 04 MAY 10
    //   Report design for RTC
    //     1. Item - OnAfterGetRecord() - code for RTC added to get Item Category
    // 
    // PRW16.00.04
    // P8000837, VerticalSoft, Jack Reynolds, 08 JUL 10
    //   RDLC layout issues
    // 
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW17.00
    // P8001139, Columbus IT, Jack Reynolds, 22 FEB 13
    //   Fix problem with incorrect key
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // P8007749, To-Increase, Jack Reynolds, 07 DEC 16
    //   Item Category/Product Group
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
    Caption = 'Projected Shortage List';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("Item Type", "Item Category Code") WHERE("Item Type" = CONST("Finished Good"));
            RequestFilterFields = "Item Category Code", "Location Filter";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(LocationFilter; LocationFilter)
            {
            }
            column(STRCurrentPeriod; StrSubstNo(Text001, CurrentPeriod))
            {
            }
            column(STRFuturePeriod; StrSubstNo(Text002, FuturePeriod))
            {
            }
            column(STRItemCategoryCodeDesc; StrSubstNo('%1 - %2', ItemCategory.Code, ItemCategory.Description))
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
            column(ItemBaseUOM; "Base Unit of Measure")
            {
                IncludeCaption = true;
            }
            column(Available; Available)
            {
                DecimalPlaces = 0 : 5;
            }
            column(CurrentSalesDemand; CurrentSalesDemand)
            {
                DecimalPlaces = 0 : 5;
            }
            column(CurrentPurchDemand; CurrentPurchDemand)
            {
                DecimalPlaces = 0 : 5;
            }
            column(CurrentTransDemand; CurrentTransDemand)
            {
                DecimalPlaces = 0 : 5;
            }
            column(CurrentProdDemand; CurrentProdDemand)
            {
                DecimalPlaces = 0 : 5;
            }
            column(Shortage; Shortage)
            {
                DecimalPlaces = 0 : 5;
            }
            column(CurrentSupply; CurrentSupply)
            {
                DecimalPlaces = 0 : 5;
            }
            column(FutureDemand; FutureDemand)
            {
                DecimalPlaces = 0 : 5;
            }
            column(FutureSupply; FutureSupply)
            {
                DecimalPlaces = 0 : 5;
            }
            column(ItemItemCategoryCode; "Item Category Code")
            {
            }

            trigger OnAfterGetRecord()
            begin
                // P8000813 >>
                if IsServiceTier then
                    if ("Item Category Code" <> CurrentItemCategory) then begin
                        if not ItemCategory.Get("Item Category Code") then
                            Clear(ItemCategory);
                        CurrentItemCategory := "Item Category Code";
                    end;
                // P8000813 <<

                LotStatusMgmt.SetInboundExclusions(Item, LotStatus.FieldNo("Available for Sale"), // P8001083
                  ExcludePurch, ExcludeSalesRet, ExcludeOutput);                                   // P8001083

                SetRange("Date Filter", 0D, BaseDate - 1);
                CalcFields(Inventory, "Qty. on Purch. Order", "Qty. on Sales Order",
                  "Qty. in Transit", "Trans. Ord. Receipt (Qty.)", "Trans. Ord. Shipment (Qty.)",
                  "Qty. on Prod. Order", "Qty. on Component Lines");
                // P8001083
                LotStatusMgmt.AdjustItemFlowFields(Item, LotStatusExclusionFilter, true, true, 0,
                  ExcludePurch, ExcludeSalesRet, ExcludeOutput);
                if not ExcludeSalesRet then begin
                    // P8001083
                    SalesLine.SetRange("No.", "No.");
                    SalesLine.SetRange("Shipment Date", 0D, BaseDate - 1);
                    SalesLine.CalcSums("Outstanding Qty. (Base)");
                end; // P8001083
                PurchLine.SetRange("No.", "No.");
                PurchLine.SetRange("Expected Receipt Date", 0D, BaseDate - 1);
                PurchLine.CalcSums("Outstanding Qty. (Base)");

                Available := Inventory + "Qty. on Purch. Order" - PurchLine."Outstanding Qty. (Base)" -
                  "Qty. on Sales Order" + SalesLine."Outstanding Qty. (Base)" +
                  "Qty. in Transit" + "Trans. Ord. Receipt (Qty.)" - "Trans. Ord. Shipment (Qty.)" +
                  "Qty. on Prod. Order" - "Qty. on Component Lines";

                SetRange("Date Filter", BaseDate, BaseDate + CurrentView - 1);
                CalcFields("Qty. on Purch. Order", "Qty. on Sales Order",
                  "Qty. in Transit", "Trans. Ord. Receipt (Qty.)", "Trans. Ord. Shipment (Qty.)",
                  "Qty. on Prod. Order", "Qty. on Component Lines");
                // P8001083
                LotStatusMgmt.AdjustItemFlowFields(Item, LotStatusExclusionFilter, false, true, 0,
                  ExcludePurch, ExcludeSalesRet, ExcludeOutput);
                if not ExcludeSalesRet then begin
                    // P8001083
                    SalesLine.SetRange("Shipment Date", BaseDate, BaseDate + CurrentView);
                    SalesLine.CalcSums("Outstanding Qty. (Base)");
                end; // P8001083
                PurchLine.SetRange("Expected Receipt Date", BaseDate, BaseDate + CurrentView);
                PurchLine.CalcSums("Outstanding Qty. (Base)");

                CurrentSalesDemand := "Qty. on Sales Order";
                CurrentPurchDemand := PurchLine."Outstanding Qty. (Base)";
                CurrentTransDemand := "Trans. Ord. Shipment (Qty.)";
                CurrentProdDemand := "Qty. on Component Lines";

                Shortage := CurrentSalesDemand + CurrentPurchDemand + CurrentTransDemand + CurrentProdDemand - Available;
                if Shortage <= 0 then
                    CurrReport.Skip;

                CurrentSupply := "Qty. on Purch. Order" + SalesLine."Outstanding Qty. (Base)" +
                  "Qty. in Transit" + "Trans. Ord. Receipt (Qty.)" + "Qty. on Prod. Order";

                SetRange("Date Filter", BaseDate + CurrentView, BaseDate + CurrentView + FutureView - 1);
                CalcFields("Qty. on Purch. Order", "Qty. on Sales Order",
                  "Qty. in Transit", "Trans. Ord. Receipt (Qty.)", "Trans. Ord. Shipment (Qty.)",
                  "Qty. on Prod. Order", "Qty. on Component Lines");
                // P8001083
                LotStatusMgmt.AdjustItemFlowFields(Item, LotStatusExclusionFilter, false, true, 0,
                  ExcludePurch, ExcludeSalesRet, ExcludeOutput);
                if not ExcludeSalesRet then begin
                    // P8001083
                    SalesLine.SetRange("Shipment Date", BaseDate + CurrentView, BaseDate + CurrentView + FutureView - 1);
                    SalesLine.CalcSums("Outstanding Qty. (Base)");
                end; // P8001083
                PurchLine.SetRange("Expected Receipt Date", BaseDate + CurrentView, BaseDate + CurrentView + FutureView - 1);
                PurchLine.CalcSums("Outstanding Qty. (Base)");

                FutureDemand := "Qty. on Sales Order" + PurchLine."Outstanding Qty. (Base)" +
                  "Trans. Ord. Shipment (Qty.)" + "Qty. on Component Lines";
                FutureSupply := "Qty. on Purch. Order" + SalesLine."Outstanding Qty. (Base)" +
                  "Qty. in Transit" + "Trans. Ord. Receipt (Qty.)" + "Qty. on Prod. Order";
            end;

            trigger OnPreDataItem()
            begin
                SalesLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Shipment Date");
                SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Return Order");
                SalesLine.SetRange(Type, SalesLine.Type::Item);
                CopyFilter("Location Filter", SalesLine."Location Code");

                PurchLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Expected Receipt Date");
                PurchLine.SetRange("Document Type", PurchLine."Document Type"::"Return Order");
                PurchLine.SetRange(Type, PurchLine.Type::Item);
                CopyFilter("Location Filter", PurchLine."Location Code");

                if IsServiceTier then        // P8000813
                    CurrentItemCategory := ''; // P8000813
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(BaseDate; BaseDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Date';
                    }
                    field(CurrentView; CurrentView)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Current View (days)';
                        MinValue = 1;
                    }
                    field(FutureView; FutureView)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Future View (days)';
                        MinValue = 1;
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
            LayoutFile = './layout/ProjectedShortageList.rdlc';
        }
    }

    labels
    {
        ProjectedShortageCaption = 'Projected Shortage';
        PAGENOCaption = 'Page';
        AvailableCaption = 'Available';
        CurrentSalesDemandCaption = 'Sales';
        CurrentPurchDemandCaption = 'Purchases';
        CurrentTransDemandCaption = 'Transfers';
        CurrentProdDemandCaption = 'Production';
        ShortageCaption = 'Shortage';
        CurrentSupplyCaption = 'Supply';
        FutureDemandCaption = 'Demand';
    }

    trigger OnInitReport()
    begin
        if CurrentView = 0 then
            CurrentView := 1;
        if FutureView = 0 then
            FutureView := 1;

        BaseDate := WorkDate;
    end;

    trigger OnPreReport()
    begin
        CurrentPeriod := Format(BaseDate);
        if CurrentView > 1 then
            CurrentPeriod := CurrentPeriod + '-' + Format(BaseDate + CurrentView - 1);

        FuturePeriod := Format(BaseDate + CurrentView);
        if FutureView > 1 then
            FuturePeriod := FuturePeriod + '-' + Format(BaseDate + CurrentView + FutureView - 1);

        LocationFilter := Item.GetFilter("Location Filter");
        if LocationFilter <> '' then
            LocationFilter := StrSubstNo(Text003, LocationFilter);

        LotStatusExclusionFilter := LotStatusMgmt.SetLotStatusExclusionFilter(LotStatus.FieldNo("Available for Sale")); // P8001083
    end;

    var
        ItemCategory: Record "Item Category";
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        BaseDate: Date;
        CurrentView: Integer;
        FutureView: Integer;
        Available: Decimal;
        CurrentSalesDemand: Decimal;
        CurrentPurchDemand: Decimal;
        CurrentTransDemand: Decimal;
        CurrentProdDemand: Decimal;
        CurrentSupply: Decimal;
        FutureDemand: Decimal;
        FutureSupply: Decimal;
        Shortage: Decimal;
        LocationFilter: Text[30];
        CurrentPeriod: Text[30];
        FuturePeriod: Text[30];
        Text001: Label 'Current (%1)';
        Text002: Label 'Future (%1)';
        Text003: Label 'Location: %1';
        CurrentItemCategory: Code[20];
        LotStatus: Record "Lot Status Code";
        LotStatusMgmt: Codeunit "Lot Status Management";
        LotStatusExclusionFilter: Text[1024];
        ExcludePurch: Boolean;
        ExcludeSalesRet: Boolean;
        ExcludeOutput: Boolean;
}

