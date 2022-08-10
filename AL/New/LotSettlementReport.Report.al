report 37002660 "Lot Settlement Report"
{
    // PR4.00
    // P8000244A, Myers Nissi, Jack Reynolds, 03 OCT 05
    //   Modified for item charges and accrual expenses
    // 
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 24 JUL 07
    //   Modify for repack orders
    // 
    // PRW15.00.03
    // P8000624A, VerticalSoft, Jack Reynolds, 19 AUG 08
    //   Add controls for country/region of origin
    // 
    // PRW16.00.02
    // P8000751, VerticalSoft, Jack Reynolds, 09 DEC 09
    //   Fix totals for item charges and marketing plan expenses
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 06 MAY 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000837, VerticalSoft, Jack Reynolds, 07 JUL 10
    //   RDLC layout issues
    // 
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW16.00.05
    // P8000981, Columbus IT, Don Bresee, 20 SEP 11
    //   Separate Costing and Pricing units
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
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/LotSettlementReport.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Lot Settlement Report';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Lot No. Information"; "Lot No. Information")
        {
            DataItemTableView = SORTING("Document No.") WHERE("Created From Repack" = CONST(false));
            RequestFilterFields = "Document No.";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(LotInfoTabFilters; "Lot No. Information".GetFilters)
            {
            }
            column(LotInfoHeader; 'LotNoInformation')
            {
            }
            column(LotInfoRec; "Item No." + "Variant Code" + "Lot No.")
            {
            }
            column(LotInfoDocNoGroup; "Document No.")
            {
            }
            column(ShowDetail; ShowDetail)
            {
            }
            column(LotInfoSTRCommissionPct; StrSubstNo(Text001, CommissionPct))
            {
            }
            dataitem("Item Ledger Entry"; "Item Ledger Entry")
            {
                DataItemLink = "Item No." = FIELD("Item No."), "Variant Code" = FIELD("Variant Code"), "Lot No." = FIELD("Lot No.");
                DataItemTableView = SORTING("Item No.", "Variant Code", "Lot No.", Positive, "Posting Date");

                trigger OnAfterGetRecord()
                var
                    TempExtraCharge: Record "Value Entry Extra Charge" temporary;
                    TempItemCharge: Record "Value Entry" temporary;
                    TempAccrualLedger: Record "Accrual Ledger Entry" temporary;
                begin
                    Quantity := GetCostingQty;
                    if Quantity <> 0 then
                        case "Entry Type" of
                            "Entry Type"::Purchase, "Entry Type"::Output:
                                begin
                                    LotQuantity += Quantity;
                                    FPLotFns.GetExtraCharges("Entry No.", ExtraCharge, TempExtraCharge); // P8000244A
                                    FPLotFns.GetItemCharges("Entry No.", ItemCharge, TempItemCharge);    // P8000244A
                                    RTCExtraCharge += ExtraCharge;   // P8000812
                                    RTCItemCharge += ItemCharge;     // P8000812
                                end;
                            "Entry Type"::Sale:
                                begin
                                    Quantity := GetPricingQty();  // P8000981
                                    if (Quantity <> 0) then begin // P8000981
                                        CalcFields("Sales Amount (Expected)", "Sales Amount (Actual)");
                                        LotSettlement.Init;
                                        LotSettlement."Line No." += 1;
                                        LotSettlement."Entry Type" := LotSettlement."Entry Type"::Sales;
                                        LotSettlement."Posting Date" := "Posting Date";
                                        LotSettlement."Document No." := "Document No.";
                                        LotSettlement."Customer No." := "Source No.";
                                        LotSettlement.Quantity := -Quantity;
                                        LotSettlement."Extended Price" := "Sales Amount (Actual)" + "Sales Amount (Expected)"; // P8000244A
                                        LotSettlement."Includes Expected Cost" := "Sales Amount (Expected)" <> 0;              // P8000244A
                                        LotSettlement."Unit Price" := Round(
                                          LotSettlement."Extended Price" / LotSettlement.Quantity,
                                          GLSetup."Unit-Amount Rounding Precision");
                                        LotSettlement.Insert;
                                        //FPLotFns.GetAccrualExpense("Entry No.",Quantity,Item.CostInAlternateUnits, // P8000244A, P8000981
                                        FPLotFns.GetAccrualExpense("Entry No.", Quantity, Item.PriceInAlternateUnits,  // P8000244A, P8000981
                                           AccrualExpense, TempAccrualLedger);                                        // P8000244A
                                        RTCAccrualExpense += AccrualExpense;   // P8000812
                                    end;                          // P8000981
                                end;
                            "Entry Type"::"Negative Adjmt.":
                                begin
                                    if "Writeoff Responsibility" <> 0 then begin
                                        LotSettlement.Init;
                                        LotSettlement."Line No." += 1;
                                        LotSettlement."Entry Type" := "Writeoff Responsibility";
                                        LotSettlement."Posting Date" := "Posting Date";
                                        LotSettlement."Document No." := "Document No.";
                                        LotSettlement.Quantity := -GetCostingQty;
                                        LotSettlement.Insert;
                                    end;
                                    //IF FPLotFns.GetRepackSale("Entry No.",RepackSale) THEN BEGIN // P8000244A
                                    // P8000496A
                                    case "Order Type" of     // P8001134
                                        "Order Type"::FOODRepack: // P8001134
                                            begin
                                                LotSettlement.Init;
                                                LotSettlement."Line No." += 1;
                                                LotSettlement."Entry Type" := LotSettlement."Entry Type"::Repack;
                                                LotSettlement."Posting Date" := "Posting Date";
                                                LotSettlement."Document No." := "Document No.";
                                                //LotSettlement.Quantity := -GetCostingQty; // P8000981
                                                LotSettlement.Quantity := -GetPricingQty;   // P8000981
                                                LotSettlement.Insert;
                                            end;

                                        "Order Type"::FOODSalesRepack: // P8001134
                                            begin
                                                // P8000496A
                                                Quantity := GetPricingQty();  // P8000981
                                                if (Quantity <> 0) then begin // P8000981
                                                    FPLotFns.GetRepackSale("Item Ledger Entry", RepackSale); // P8001134
                                                    RepackSale.CalcFields("Sales Amount (Expected)", "Sales Amount (Actual)");
                                                    LotSettlement.Init;
                                                    LotSettlement."Line No." += 1;
                                                    LotSettlement."Entry Type" := LotSettlement."Entry Type"::Sales;
                                                    LotSettlement."Posting Date" := "Posting Date";
                                                    LotSettlement."Document No." := "Document No.";
                                                    LotSettlement."Customer No." := RepackSale."Source No.";
                                                    LotSettlement.Quantity := -Quantity;
                                                    LotSettlement."Extended Price" := RepackSale."Sales Amount (Actual)" +               // P8000244A
                                                      RepackSale."Sales Amount (Expected)";                                              // P8000244A
                                                    LotSettlement."Includes Expected Cost" := RepackSale."Sales Amount (Expected)" <> 0; // P8000244A
                                                    LotSettlement."Unit Price" := Round(
                                                      LotSettlement."Extended Price" / LotSettlement.Quantity,
                                                      GLSetup."Unit-Amount Rounding Precision");
                                                    LotSettlement.Insert;
                                                    FPLotFns.GetAccrualExpense(
                                                       //RepackSale."Entry No.",RepackSale.GetCostingQty,Item.CostInAlternateUnits, // P8000244A, P8000981
                                                       RepackSale."Entry No.", RepackSale.GetPricingQty, Item.PriceInAlternateUnits,  // P8000244A, P8000981
                                                       AccrualExpense, TempAccrualLedger);                                           // P8000244A
                                                    RTCAccrualExpense += AccrualExpense;   // P8000812
                                                end;                          // P8000981
                                            end; // P8000496A
                                    end;
                                end;
                        end;

                    CurrReport.Skip;
                end;
            }
            dataitem(LotInfo; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(LotInfoVariantCode; "Lot No. Information"."Variant Code")
                {
                    IncludeCaption = true;
                }
                column(LotInfoLotNo; "Lot No. Information"."Lot No.")
                {
                    IncludeCaption = true;
                }
                column(LotInfoDescription; "Lot No. Information".Description)
                {
                    IncludeCaption = true;
                }
                column(LotInfoFarm; "Lot No. Information".Farm)
                {
                    IncludeCaption = true;
                }
                column(LotInfoBrand; "Lot No. Information".Brand)
                {
                    IncludeCaption = true;
                }
                column(LotInfoLotQuantity; LotQuantity)
                {
                }
                column(ItemBaseUOM; Item."Base Unit of Measure")
                {
                }
                column(LotInfoItemNo; "Lot No. Information"."Item No.")
                {
                    IncludeCaption = true;
                }
                column(LotInfoCountryRegionofOriginCode; "Lot No. Information"."Country/Region of Origin Code")
                {
                }
                column(LotInfoRec1; Format(Number))
                {
                }
                dataitem(Sales; "Lot Settlement Report")
                {
                    DataItemTableView = SORTING("Entry Type", "Unit Price", "Posting Date", "Document No.") WHERE("Entry Type" = CONST(Sales));
                    column(SalesQuantity; Quantity)
                    {
                        IncludeCaption = true;
                    }
                    column(SalesExtendedPrice; "Extended Price")
                    {
                        AutoFormatType = 1;
                        IncludeCaption = true;
                    }
                    column(SalesUnitPrice; "Unit Price")
                    {
                        AutoFormatType = 2;
                        IncludeCaption = true;
                    }
                    column(ExpectedIndicator; ExpectedIndicator)
                    {
                    }
                    column(SalesDocNo; "Document No.")
                    {
                        IncludeCaption = true;
                    }
                    column(SalesPostingDate; "Posting Date")
                    {
                        IncludeCaption = true;
                    }
                    column(CustName; CustomerName)
                    {
                    }
                    column(SalesCustNo; "Customer No.")
                    {
                        IncludeCaption = true;
                    }
                    column(SalesHeader; 'Sales')
                    {
                    }
                    column(SalesRec; Format("Report No.") + Format("Line No."))
                    {
                    }
                    column(SalesUnitPriceGroup; Format("Unit Price"))
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if Sales."Includes Expected Cost" then
                            ExpectedFlag := 1;

                        // P8000812 S
                        if ExpectedFlag <> 0 then
                            ExpectedIndicator := '*'
                        else
                            ExpectedIndicator := '';
                        RTCTotalExtPrice += "Extended Price";
                        RTCTotalQuantity += Quantity;
                        // P8000812 E
                    end;

                    trigger OnPostDataItem()
                    begin
                        // P8000812 S
                        if IsServiceTier then begin
                            Quantity := RTCTotalQuantity;
                            "Extended Price" := RTCTotalExtPrice;
                        end;
                        // P8000812 E
                        if Quantity <> 0 then
                            AvgSalePrice := Round("Extended Price" / Quantity, GLSetup."Unit-Amount Rounding Precision");

                        TotalQuantity := Quantity;
                        TotalExtPrice := "Extended Price";
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange("Report No.", LotSettlement."Report No.");

                        RTCTotalExtPrice := 0;  // P8000812
                        RTCTotalQuantity := 0;  // P8000812
                    end;
                }
                dataitem(Adjustments; "Lot Settlement Report")
                {
                    DataItemTableView = SORTING("Entry Type", "Posting Date", "Document No.") WHERE("Entry Type" = FILTER("Writeoff Company" | "Writeoff Vendor" | Repack));
                    column(AdjustmentsExtendedPrice; "Extended Price")
                    {
                        AutoFormatType = 1;
                    }
                    column(AdjustmentsUnitPrice; "Unit Price")
                    {
                        AutoFormatType = 2;
                    }
                    column(AdjustmentsQuantity; Quantity)
                    {
                    }
                    column(AdjustmentsPostingDate; "Posting Date")
                    {
                    }
                    column(AdjustmentsDocNo; "Document No.")
                    {
                    }
                    column(EntryType; EntryType)
                    {
                    }
                    column(AdjustmentsHeader; 'Adjustments')
                    {
                    }
                    column(AdjustmentsRec; Format("Report No.") + Format("Line No."))
                    {
                    }
                    column(AdjustmentsEntryTypeGroup; Format("Entry Type"))
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if "Entry Type" in ["Entry Type"::"Writeoff Company", "Entry Type"::Repack] then begin // P8000496A
                            "Unit Price" := AvgSalePrice;
                            "Extended Price" := Round(Quantity * "Unit Price", GLSetup."Amount Rounding Precision");
                            Modify;
                        end;

                        // P8000812 S
                        RTCTotalQuantity += Quantity;
                        RTCTotalExtPrice += "Extended Price";
                        RTCQty += Quantity;
                        RTCPrice += "Extended Price";
                        //Copied from sections
                        if "Entry Type" = "Entry Type"::"Writeoff Company" then
                            EntryType := Text002
                        else
                            if "Entry Type" = "Entry Type"::"Writeoff Vendor" then // P8000496A
                                EntryType := Text003
                            else                                                      // P8000496A
                                EntryType := Text004;                                   // P8000496A
                        //Copied from sections
                        // P8000812 E
                    end;

                    trigger OnPostDataItem()
                    begin
                        // P8000812 S
                        if IsServiceTier then begin
                            Quantity := RTCQty;
                            "Extended Price" := RTCPrice;
                        end;
                        // P8000812 E
                        TotalQuantity += Quantity;
                        TotalExtPrice += "Extended Price";
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange("Report No.", LotSettlement."Report No.");

                        // P8000812 S
                        RTCQty := 0;
                        RTCPrice := 0;
                        // P8000812 E
                    end;
                }
                dataitem(LotTotals; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                    column(TotalQuantity; TotalQuantity)
                    {
                    }
                    column(TotalExtPrice; TotalExtPrice)
                    {
                        AutoFormatType = 1;
                    }
                    column(UnsoldQty; UnsoldQty)
                    {
                    }
                    column(UnsoldExtPrice; UnsoldExtPrice)
                    {
                    }
                    column(AvgSalePrice; AvgSalePrice)
                    {
                        AutoFormatType = 2;
                    }
                    column(LotExtPrice; LotExtPrice)
                    {
                    }
                    column(LotTotalsLotQuantity; LotQuantity)
                    {
                    }
                    column(LotUnitPrice; LotUnitPrice)
                    {
                        AutoFormatType = 2;
                    }
                    column(Commission; Commission)
                    {
                        AutoFormatType = 1;
                    }
                    column(UnitCommission; UnitCommission)
                    {
                        AutoFormatType = 2;
                    }
                    column(UnitExtraCharge; UnitExtraCharge)
                    {
                        AutoFormatType = 2;
                    }
                    column(ExtraCharge; ExtraCharge)
                    {
                        AutoFormatType = 1;
                    }
                    column(UnitNetReturn; UnitNetReturn)
                    {
                        AutoFormatType = 2;
                    }
                    column(NetReturn; NetReturn)
                    {
                        AutoFormatType = 1;
                    }
                    column(LotTotalsSTRCommissionPct; StrSubstNo(Text001, CommissionPct))
                    {
                    }
                    column(ItemCharge; ItemCharge)
                    {
                        AutoFormatType = 1;
                    }
                    column(UnitItemCharge; UnitItemCharge)
                    {
                        AutoFormatType = 2;
                    }
                    column(AccrualExpense; AccrualExpense)
                    {
                        AutoFormatType = 1;
                    }
                    column(UnitAccrualExpense; UnitAccrualExpense)
                    {
                        AutoFormatType = 2;
                    }
                    column(LotTotalsRec; Format(Number))
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        // P8000812 S
                        if IsServiceTier then begin
                            ItemCharge := RTCItemCharge;
                            ExtraCharge := RTCExtraCharge;
                            TotalQuantity := RTCTotalQuantity;
                            TotalExtPrice := RTCTotalExtPrice;
                        end;
                        // P8000812 E
                        UnsoldQty := LotQuantity - TotalQuantity;
                        UnsoldExtPrice := Round(UnsoldQty * AvgSalePrice);
                        LotExtPrice := TotalExtPrice + UnsoldExtPrice;
                        LotUnitPrice := 0;         // P8000812
                        if LotQuantity <> 0 then   // P8000812
                            LotUnitPrice := Round(LotExtPrice / LotQuantity, GLSetup."Unit-Amount Rounding Precision");
                        Commission := Round(LotExtPrice * CommissionPct / 100);
                        NetReturn := LotExtPrice - Commission - ExtraCharge - ItemCharge - AccrualExpense;
                        if LotQuantity <> 0 then begin
                            UnitCommission := Round(Commission / LotQuantity, GLSetup."Unit-Amount Rounding Precision");
                            UnitExtraCharge := Round(ExtraCharge / LotQuantity, GLSetup."Unit-Amount Rounding Precision");
                            UnitItemCharge := Round(ItemCharge / LotQuantity, GLSetup."Unit-Amount Rounding Precision");         // P8000244A
                            UnitAccrualExpense := Round(AccrualExpense / LotQuantity, GLSetup."Unit-Amount Rounding Precision"); // P8000244A
                            UnitNetReturn := Round(NetReturn / LotQuantity, GLSetup."Unit-Amount Rounding Precision");
                        end else begin
                            UnitCommission := 0;
                            UnitExtraCharge := 0;
                            UnitItemCharge := 0;     // P8000244A
                            UnitAccrualExpense := 0; // P8000244A
                            UnitNetReturn := 0;
                        end;
                    end;
                }
            }

            trigger OnAfterGetRecord()
            begin
                // P8000812 S
                if IsServiceTier and ("Document No." = '') then
                    "Document No." := '<BLANK>';
                // P8000812 E
                Item.Get("Item No.");
                if Item.CostInAlternateUnits then
                    Item."Base Unit of Measure" := Item."Alternate Unit of Measure";

                AdjustmentHeaderPrinted := false;

                LotQuantity := 0;
                Clear(ExtraCharge);
                Clear(ItemCharge);     // P8000244A
                Clear(AccrualExpense); // P8000244A
                Clear(RTCExtraCharge);     // P8000812
                Clear(RTCItemCharge);      // P8000812
                Clear(RTCAccrualExpense);  // P8000812
                AvgSalePrice := 0;
                LotSettlement.Reset;
                LotSettlement.DeleteAll;
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
                    field(CommissionPct; CommissionPct)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Commission Percent';
                    }
                    field(ShowDetail; ShowDetail)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Show Transaction Detail';
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
        DateFormat = 'MM/dd/yy';
        LotSettlementReportCaption = 'Lot Settlement Report';
        PageNoCaption = 'Page';
        LotQuantityCaption = 'Total Quantity';
        BaseUOMCaption = 'Unit of Measure';
        CountryRegionofOriginCodeCaption = 'Country/Region of Origin';
        ReportTotalsCaption = 'Report Totals';
        TotalSalesCaption = 'Total Sales';
        ExtraChargesCaption = 'Extra Charges';
        NetReturnCaption = 'Net Return';
        ItemChargesCaption = 'Item Charges';
        MarketingPlanExpenseCaption = 'Marketing Plan Expense';
        IncludesexpectedpricesCaption = '* Includes expected prices';
        CustNameCaption = 'Customer Name';
        SalesCaption = 'Sales';
        AdjustmentsCaption = 'Adjustments';
        SalesandAdjustmentsCaption = 'Sales and Adjustments';
        EstimatedSalesCaption = 'Estimated Sales';
    }

    trigger OnPostReport()
    begin
        LotSettlement.Reset;
        LotSettlement.SetRange("Report No.", LotSettlement."Report No.");
        LotSettlement.DeleteAll;
    end;

    trigger OnPreReport()
    begin
        GLSetup.Get;

        LotSettlement.LockTable;
        if LotSettlement.Find('+') then
            LotSettlement."Report No." += 1
        else
            LotSettlement."Report No." := 1;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        Item: Record Item;
        LotSettlement: Record "Lot Settlement Report";
        RepackSale: Record "Item Ledger Entry";
        FPLotFns: Codeunit "FreshPro Lot Functions";
        ExtraCharge: Decimal;
        ItemCharge: Decimal;
        AccrualExpense: Decimal;
        AdjustmentHeaderPrinted: Boolean;
        CommissionPct: Decimal;
        ShowDetail: Boolean;
        AvgSalePrice: Decimal;
        TotalQuantity: Decimal;
        TotalExtPrice: Decimal;
        UnsoldQty: Decimal;
        UnsoldExtPrice: Decimal;
        LotQuantity: Decimal;
        LotExtPrice: Decimal;
        LotUnitPrice: Decimal;
        Commission: Decimal;
        NetReturn: Decimal;
        UnitCommission: Decimal;
        UnitExtraCharge: Decimal;
        UnitItemCharge: Decimal;
        UnitAccrualExpense: Decimal;
        UnitNetReturn: Decimal;
        Text001: Label 'Commission at %1%';
        ExpectedFlag: Decimal;
        ExpectedIndicator: Text[1];
        EntryType: Text[30];
        Text002: Label 'Company';
        Text003: Label 'Vendor';
        Text004: Label 'Repack';
        RTCExtraCharge: Decimal;
        RTCItemCharge: Decimal;
        RTCAccrualExpense: Decimal;
        RTCTotalQuantity: Decimal;
        RTCTotalExtPrice: Decimal;
        RTCQty: Decimal;
        RTCPrice: Decimal;
}

