report 37002807 "Asset History" // Version: FOODNA
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   This report lists work orders by asset with total costs for each work order listed
    //      and for each asset listed
    // 
    // PRW16.00.01
    // P8000718, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Added downtime
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 06 MAY 10
    //   RTC Reporting Upgrade
    // 
    // PRW17.10
    // P8001223, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Expand filter variables
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
    Caption = 'Asset History';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Asset; Asset)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", Type, "Location Code", "Resource No.", "Asset Category Code";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(AssetTabCapAssetFilter; Asset.TableCaption + ' - ' + AssetFilter)
            {
            }
            column(WorkOrderTabCapWOFilter; "Work Order".TableCaption + ' - ' + WOFilter)
            {
            }
            column(AssetNo; "No.")
            {
                IncludeCaption = true;
            }
            column(AssetDesc; Description)
            {
                IncludeCaption = true;
            }
            column(AssetType; Type)
            {
                IncludeCaption = true;
            }
            column(AssetLocationCode; "Location Code")
            {
                IncludeCaption = true;
            }
            column(AssetResourceNo; "Resource No.")
            {
                IncludeCaption = true;
            }
            column(AssetAssetCategoryCode; "Asset Category Code")
            {
            }
            column(AssetFilter; AssetFilter)
            {
            }
            column(WOFilter; WOFilter)
            {
            }
            column(AssetHeader; 'Asset')
            {
            }
            dataitem("Work Order"; "Work Order")
            {
                DataItemLink = "Asset No." = FIELD("No.");
                DataItemTableView = SORTING("Asset No.", "Completion Date");
                RequestFilterFields = "Origination Date", "Completion Date", "Fault Code", "Cause Code", "Action Code";
                column(WorkOrderNo; "No.")
                {
                    IncludeCaption = true;
                }
                column(WorkOrderOriginationDate; "Origination Date")
                {
                    IncludeCaption = true;
                }
                column(WorkOrderFaultCode; "Fault Code")
                {
                    IncludeCaption = true;
                }
                column(WorkOrderCauseCode; "Cause Code")
                {
                    IncludeCaption = true;
                }
                column(WorkOrderActionCode; "Action Code")
                {
                    IncludeCaption = true;
                }
                column(WorkOrderCompletionDate; "Completion Date")
                {
                    IncludeCaption = true;
                }
                column(WorkOrderWorkReqFirstLine; "Work Requested (First Line)")
                {
                    IncludeCaption = true;
                }
                column(WorkOrderTotalCostActual; "Total Cost (Actual)")
                {
                }
                column(WorkOrderLaborCostActual; "Labor Cost (Actual)")
                {
                }
                column(WorkOrderMaterialCostActual; "Material Cost (Actual)")
                {
                }
                column(WorkOrderContractCostActual; "Contract Cost (Actual)")
                {
                }
                column(WorkOrderDowntimeHrs; "Downtime (Hours)")
                {
                    DecimalPlaces = 2 : 2;
                    IncludeCaption = true;
                }
                column(WorkOrderHeader; 'WorkOrder')
                {
                }
            }
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

    rendering
    {
        layout(StandardRDLCLayout)
        {
            Summary = 'Standard Layout';
            Type = RDLC;
            LayoutFile = './layout/AssetHistory.rdlc';
        }
    }

    labels
    {
        AssetHistoryCaption = 'Asset History';
        PageNoCaption = 'Page';
        AssetAssetCategoryCodeCaption = 'Asset Category';
        ContractCostCaption = 'Contract Cost';
        MaterialCostCaption = 'Material Cost';
        LaborCostCaption = 'Labor Cost';
        TotalCostActualCaption = 'Total Cost';
    }

    trigger OnPreReport()
    begin
        AssetFilter := Asset.GetFilters;
        WOFilter := "Work Order".GetFilters;
    end;

    var
        AssetFilter: Text;
        WOFilter: Text;
}

