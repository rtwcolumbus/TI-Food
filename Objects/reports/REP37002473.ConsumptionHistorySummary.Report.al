report 37002473 "Consumption History Summary"
{
    // PR3.70.10
    // P8000234A, Myers Nissi, Phyllis McGovern, 21 JUL 05
    //   New Report added: Work done by Steve Post
    // 
    // PR4.00.02
    // P8000293A, VerticalSoft, Jack Reynolds, 10 FEB 06
    //   Replace flowfield with function for consumption quantity
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 22 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues Property in the Request Page.
    // 
    // PRW17.10
    // P8001221, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Type added to Item table
    // 
    // P8001223, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Expand filter variables
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
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/ConsumptionHistorySummary.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Consumption History Summary';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = WHERE(Type = CONST(Inventory));
            RequestFilterFields = "No.", "Item Type", "Item Category Code";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(FilterString; FilterString)
            {
            }
            column(CurrentWeekEnding; CurrentWeekEnding)
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
            }
            column(ItemSafetyStockQuantity; "Safety Stock Quantity")
            {
            }
            column(ItemInventory; Inventory)
            {
                DecimalPlaces = 2 : 2;
            }
            column(QuantityDue; QuantityDue)
            {
            }
            column(WklyCons1; WklyCons[1])
            {
            }
            column(WklyCons2; WklyCons[2])
            {
            }
            column(WklyCons3; WklyCons[3])
            {
            }
            column(WklyCons5; WklyCons[5])
            {
            }
            column(WklyCons4; WklyCons[4])
            {
            }
            column(WklyAve; WklyAve)
            {
            }
            column(WeeksOnHandDisplay; WeeksOnHandDisplay)
            {
            }

            trigger OnAfterGetRecord()
            var
                i: Integer;
            begin
                LotStatusMgmt.SetInboundExclusions(Item, LotStatus.FieldNo("Available for Consumption"), // P8001083
                  ExcludePurch, ExcludeSalesRet, ExcludeOutput);                                          // P8001083

                SetRange("Date Filter");
                Clear(WklyCons);
                WklyAve := 0;
                WeeksOnHand := 0;
                QuantityDue := 0;
                i := 0;

                for i := 1 to 5 do begin
                    SetRange("Date Filter", WeekStart[i], WeekEnd[i]);
                    //CALCFIELDS("Consumptions (Qty.)"); // P8000293A
                    WklyCons[i] := ConsumptionQty;       // P8000293A
                    WklyAve := WklyAve + WklyCons[i]
                end;

                SetRange("Date Filter", WeekStart[5], WeekEnd[5]);
                CalcFields(Inventory, "Qty. on Purch. Order", "Qty. on Prod. Order");
                // P8001083
                LotStatusMgmt.AdjustItemFlowFields(Item, LotStatusExclusionFilter, true, false, 0,
                  ExcludePurch, ExcludeSalesRet, ExcludeOutput);
                // P8001083

                QuantityDue := "Qty. on Purch. Order" + "Qty. on Prod. Order";

                WklyAve := WklyAve / 8;
                if WklyAve <> 0 then begin
                    WeeksOnHand := Inventory / WklyAve;
                    WeeksOnHandDisplay := Format(WeeksOnHand, 0, '<Precision,1:1><Integer><Decimal>');
                    if FilterWeeksOnHand and (WeeksOnHand >= OnlyWeeksOnHandLessThan) then
                        CurrReport.Skip
                end else begin
                    WeeksOnHandDisplay := '*****';
                    if FilterWeeksOnHand and (Inventory >= 0) then
                        CurrReport.Skip;
                end;
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
                    field(CurrentWeekEnd; CurrentWeekEnd)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Current Week Ending Date';
                    }
                    field(FilterWeeksOnHand; FilterWeeksOnHand)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Only show items where weeks on hand is less than limit';
                        MultiLine = true;
                    }
                    field(OnlyWeeksOnHandLessThan; OnlyWeeksOnHandLessThan)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Limit to weeks on hand';
                        DecimalPlaces = 0 : 5;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            CurrentWeekEnd := Today;
        end;
    }

    labels
    {
        ConsumptionHistorySummaryCaption = 'Consumption History Summary';
        PAGENOCaption = 'Page';
        BaseUOMCaption = 'Base UOM';
        SafetyStockCaption = 'Safety Stock';
        OnHandCaption = 'On Hand';
        QuantityDueCaption = 'Quantity Due';
        WklyCons1Caption = 'Weeks 5 - 8';
        Week4Caption = 'Week 4';
        Week3Caption = 'Week 3';
        Week2Caption = 'Week 2';
        CurrentWeekCaption = 'Current Week';
        WklyAveCaption = 'Weekly Average';
        WeeksOnHandDisplayCaption = 'No. Weeks On Hand';
    }

    trigger OnPreReport()
    var
        i: Integer;
    begin
        if CurrentWeekEnd = 0D then
            Error(Text002);
        i := 1;
        WeekEnd[5] := CurrentWeekEnd;

        for i := 5 downto 1 do begin
            WeekStart[i] := WeekEnd[i] - 6;
            if i <> 1 then
                WeekEnd[i - 1] := WeekStart[i] - 1;
        end;
        WeekStart[1] := WeekStart[1] - 21;

        FilterString := Item.GetFilters;
        CurrentWeekEnding := StrSubstNo(Text001, Format(CurrentWeekEnd));

        LotStatusExclusionFilter := LotStatusMgmt.SetLotStatusExclusionFilter(LotStatus.FieldNo("Available for Consumption")); // P8001083
    end;

    var
        WklyCons: array[5] of Decimal;
        WklyAve: Decimal;
        WeeksOnHand: Decimal;
        WeeksOnHandDisplay: Text[30];
        CurrentWeekEnd: Date;
        WeekStart: array[5] of Date;
        WeekEnd: array[5] of Date;
        QuantityDue: Decimal;
        FilterString: Text;
        CurrentWeekEnding: Text[80];
        Text001: Label 'Current Week Ending is: %1';
        Text002: Label 'You must enter Current Week Ending date.';
        OnlyWeeksOnHandLessThan: Decimal;
        FilterWeeksOnHand: Boolean;
        LotStatus: Record "Lot Status Code";
        LotStatusMgmt: Codeunit "Lot Status Management";
        LotStatusExclusionFilter: Text[1024];
        ExcludePurch: Boolean;
        ExcludeSalesRet: Boolean;
        ExcludeOutput: Boolean;
}

