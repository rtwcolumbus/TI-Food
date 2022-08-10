report 37002805 "Asset Cost Summary"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   This report lists assets and shows the number and cost of completed work orders (by asset)
    //     for a specified time range
    // 
    // P8000336A, VerticalSoft, Jack Reynolds, 14 SEP 06
    //   Option to include standing orders
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 05 MAY 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
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
    DefaultLayout = RDLC;
    RDLCLayout = './layout/AssetCostSummary.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Asset Cost Summary';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Asset; Asset)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", Type, "Asset Category Code", "Location Code", "Date Filter";
            dataitem("Work Order"; "Work Order")
            {
                DataItemLink = "Asset No." = FIELD("No."), "Completion Date" = FIELD("Date Filter");
                DataItemTableView = SORTING("Asset No.") WHERE(Completed = CONST(true));

                trigger OnAfterGetRecord()
                begin
                    CalcFields("Total Cost (Actual)", "Labor Cost (Actual)", "Material Cost (Actual)", "Contract Cost (Actual)");
                    AssetCostSummary."Total Cost" -= "Total Cost (Actual)"; // Sign reversed for sorting
                    AssetCostSummary."Labor Cost" += "Labor Cost (Actual)";
                    AssetCostSummary."Material Cost" += "Material Cost (Actual)";
                    AssetCostSummary."Contract Cost" += "Contract Cost (Actual)";
                    AssetCostSummary."No. of Orders" -= 1;                  // Sign reversed for sorting

                    CurrReport.Skip;
                end;

                trigger OnPostDataItem()
                begin
                    AssetCostSummary.Insert;

                    TotalCost[1] [1] -= AssetCostSummary."Total Cost";
                    TotalCost[1] [2] += AssetCostSummary."Labor Cost";
                    TotalCost[1] [3] += AssetCostSummary."Material Cost";
                    TotalCost[1] [4] += AssetCostSummary."Contract Cost";

                    TotalOrders[1] -= AssetCostSummary."No. of Orders";
                end;

                trigger OnPreDataItem()
                begin
                    if not IncludeStandingOrders then   // P8000336A
                        SetRange("Standing Order", false); // P8000336A
                end;
            }

            trigger OnAfterGetRecord()
            begin
                AssetCostSummary.Init;
                AssetCostSummary."Asset No." := "No.";
            end;
        }
        dataitem(PageLoop; "Integer")
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(ReportTitle; ReportTitle)
            {
            }
            column(STRDateFilter; StrSubstNo(Text003, DateFilter))
            {
            }
            column(PageLoopRec; Format(Number))
            {
            }
            column(PageLoopHeader; 'PageLoop')
            {
            }
            dataitem(AssetSummary; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(AssetCostSummaryContractCost; AssetCostSummary."Contract Cost")
                {
                    DecimalPlaces = 0 : 0;
                }
                column(AssetCostSummaryMaterialCost; AssetCostSummary."Material Cost")
                {
                    DecimalPlaces = 0 : 0;
                }
                column(AssetCostSummaryLaborCost; AssetCostSummary."Labor Cost")
                {
                    DecimalPlaces = 0 : 0;
                }
                column(AssetCostSummaryTotalCost; -AssetCostSummary."Total Cost")
                {
                    DecimalPlaces = 0 : 0;
                }
                column(AssetLocationCode; Asset."Location Code")
                {
                    IncludeCaption = true;
                }
                column(AssetAssetCategoryCode; Asset."Asset Category Code")
                {
                }
                column(AssetType; Asset.Type)
                {
                    IncludeCaption = true;
                }
                column(AssetDesc; Asset.Description)
                {
                    IncludeCaption = true;
                }
                column(AssetNo; Asset."No.")
                {
                    IncludeCaption = true;
                }
                column(AssetCostSummaryNoofOrders; -AssetCostSummary."No. of Orders")
                {
                }
                column(AssetSummaryRec; Format(Number))
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        AssetCostSummary.Find('-')
                    else
                        AssetCostSummary.Next;

                    case CountOrCost of
                        CountOrCost::Count:
                            if AssetCostSummary."No. of Orders" > -CountLimit then
                                CurrReport.Break;
                        CountOrCost::Cost:
                            begin
                                CummulativeCost -= AssetCostSummary."Total Cost";
                                if MustBreak or (CummulativeCost > CostLimit) then
                                    CurrReport.Break;
                                MustBreak := CummulativeCost = CostLimit;
                            end
                    end;

                    TotalCost[2] [1] -= AssetCostSummary."Total Cost";
                    TotalCost[2] [2] += AssetCostSummary."Labor Cost";
                    TotalCost[2] [3] += AssetCostSummary."Material Cost";
                    TotalCost[2] [4] += AssetCostSummary."Contract Cost";

                    TotalOrders[2] -= AssetCostSummary."No. of Orders";

                    Asset.Get(AssetCostSummary."Asset No.");
                end;

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, AssetCostSummary.Count);
                    case CountOrCost of
                        CountOrCost::Count:
                            begin
                                AssetCostSummary.SetCurrentKey("No. of Orders");
                                TotalLabel := StrSubstNo(Text004, CountLimit);
                            end;
                        CountOrCost::Cost:
                            begin
                                AssetCostSummary.SetCurrentKey("Total Cost");
                                CostLimit := TotalCost[1] [1] * CostPct / 100;
                                TotalLabel := StrSubstNo(Text005, CostPct);
                                if CostLimit = 0 then
                                    CurrReport.Break;
                            end;
                    end;
                end;
            }
            dataitem(AssetTotal; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(TotalCost21; TotalCost[2] [1])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(TotalCost22; TotalCost[2] [2])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(TotalCost23; TotalCost[2] [3])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(TotalCost24; TotalCost[2] [4])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(TotalOrders2; TotalOrders[2])
                {
                }
                column(TotalCost11; TotalCost[1] [1])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(TotalCost12; TotalCost[1] [2])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(TotalCost13; TotalCost[1] [3])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(TotalCost14; TotalCost[1] [4])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(TotalOrders1; TotalOrders[1])
                {
                }
                column(TotalLabel; TotalLabel)
                {
                }
                column(AssetTotalRec; Format(Number))
                {
                }
            }
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
                    field(CountOrCost; CountOrCost)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Summary by';
                        OptionCaption = 'Count,Cost';

                        trigger OnValidate()
                        begin
                            if CountOrCost = CountOrCost::Cost then
                                CostCountOrCostOnValidate;
                            if CountOrCost = CountOrCost::Count then
                                CountCountOrCostOnValidate;
                        end;
                    }
                    field(CountLimit; CountLimit)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'No. of Work Orders';
                        Enabled = CountLimitEnable;
                        MinValue = 0;
                    }
                    field(CostPct; CostPct)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Percent of Total Cost';
                        DecimalPlaces = 0 : 2;
                        Enabled = CostPctEnable;
                        MaxValue = 100;
                        MinValue = 0;
                    }
                    field(IncludeStandingOrders; IncludeStandingOrders)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Include Standing Orders';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            CostPctEnable := true;
            CountLimitEnable := true;
        end;

        trigger OnOpenPage()
        begin
            SetControlProperties;
        end;
    }

    labels
    {
        PageNoCaption = 'Page';
        NoofOrdersCaption = 'No. of Orders';
        ContractCostCaption = 'Contract Cost';
        MaterialCostCaption = 'Material Cost';
        LaborCostCaption = 'Labor Cost';
        TotalCostCaption = 'Total Cost';
        AssetCategoryCodeCaption = 'Asset Category';
        TotalofAllAssetsCaption = 'Total of All Assets';
    }

    trigger OnPreReport()
    begin
        case CountOrCost of
            CountOrCost::Count:
                ReportTitle := Text001;
            CountOrCost::Cost:
                ReportTitle := Text002;
        end;

        DateFilter := Asset.GetFilter("Date Filter");
    end;

    var
        AssetCostSummary: Record "Asset Cost Summary" temporary;
        CountOrCost: Option "Count",Cost;
        TotalCost: array[2, 4] of Decimal;
        TotalOrders: array[2] of Integer;
        CountLimit: Integer;
        CostLimit: Decimal;
        CostPct: Decimal;
        CummulativeCost: Decimal;
        Text001: Label 'Asset Cost Summary by Count';
        Text002: Label 'Asset Cost Summary by Cost';
        ReportTitle: Text[100];
        TotalLabel: Text[100];
        DateFilter: Text[100];
        Text003: Label 'Based on Work Orders Completed: %1';
        MustBreak: Boolean;
        Text004: Label 'Total of Assets Listed (%1 or more work orders)';
        Text005: Label 'Total of Assets Listed (up to %1% of total cost)';
        IncludeStandingOrders: Boolean;
        [InDataSet]
        CountLimitEnable: Boolean;
        [InDataSet]
        CostPctEnable: Boolean;

    procedure SetControlProperties()
    begin
        // P8001132
        CountLimitEnable := CountOrCost = CountOrCost::Count;
        CostPctEnable := CountOrCost = CountOrCost::Cost;
    end;

    local procedure CountCountOrCostOnAfterValidat()
    begin
        SetControlProperties;
    end;

    local procedure CostCountOrCostOnAfterValidate()
    begin
        SetControlProperties;
    end;

    local procedure CountCountOrCostOnValidate()
    begin
        CountCountOrCostOnAfterValidat;
    end;

    local procedure CostCountOrCostOnValidate()
    begin
        CostCountOrCostOnAfterValidate;
    end;
}

