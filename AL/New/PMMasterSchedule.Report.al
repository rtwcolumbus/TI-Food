report 37002809 "PM Master Schedule"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   This report lists assets and the PM orders established for them
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 27 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000837, VerticalSoft, Jack Reynolds, 09 JUL 10
    //   RDLC layout issues
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
    DefaultLayout = RDLC;
    RDLCLayout = './layout/PMMasterSchedule.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'PM Master Schedule';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Asset; Asset)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", Type, "Location Code";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(AssetTabCapAssetFilter; TableCaption + ' - ' + AssetFilter)
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
            column(AssetUsageUOM; "Usage Unit of Measure")
            {
            }
            column(AssetManufactureDate; "Manufacture Date")
            {
                IncludeCaption = true;
            }
            column(AssetWarrantyDate; "Warranty Date")
            {
                IncludeCaption = true;
            }
            column(UsageDate; UsageDate)
            {
            }
            column(UsageReading; UsageReading)
            {
                DecimalPlaces = 0 : 5;
            }
            column(AvgDailyUsage; AvgDailyUsage)
            {
                DecimalPlaces = 0 : 5;
            }
            column(AssetRec; "No.")
            {
            }
            column(AssetHeader; 'Asset')
            {
            }
            column(AssetFilter; AssetFilter)
            {
            }
            dataitem("Preventive Maintenance Order"; "Preventive Maintenance Order")
            {
                DataItemLink = "Asset No." = FIELD("No.");
                DataItemTableView = SORTING("Asset No.", "Group Code", "Frequency Code") WHERE("Frequency Code" = FILTER(<> ''));
                column(PrevMaintOrderGroupCode; "Group Code")
                {
                    IncludeCaption = true;
                }
                column(PrevMaintOrderFrequencyCode; "Frequency Code")
                {
                    IncludeCaption = true;
                }
                column(PrevMaintOrderLastPMDate; "Last PM Date")
                {
                    IncludeCaption = true;
                }
                column(PrevMaintOrderLastPMUsage; "Last PM Usage")
                {
                    IncludeCaption = true;
                }
                column(PrevMaintOrderLastWorkOrder; "Last Work Order")
                {
                    IncludeCaption = true;
                }
                column(PrevMaintOrderCurrentWorkOrder; "Current Work Order")
                {
                    IncludeCaption = true;
                }
                column(PrevMaintOrderWorkReqFirstLine; "Work Requested (First Line)")
                {
                    IncludeCaption = true;
                }
                column(PrevMaintOrderLaborCostPlanned; "Labor Cost (Planned)")
                {
                }
                column(PrevMaintOrderMaterialCostPlanned; "Material Cost (Planned)")
                {
                }
                column(PrevMaintOrderContractCostPlanned; "Contract Cost (Planned)")
                {
                }
                column(PrevMaintOrderNextPMDate; "Preventive Maintenance Order".NextPMDate())
                {
                }
                column(LaborCostPlanned_MaterialCostPlanned_ContractCostPlanned; "Labor Cost (Planned)" + "Material Cost (Planned)" + "Contract Cost (Planned)")
                {
                }
                column(PMORec; "Entry No.")
                {
                }
                column(PMOHeader; 'PMO')
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                GetLastUsage(UsageDate, UsageReading, AvgDailyUsage);
                if "Usage Unit of Measure" = '' then begin
                    UsageReading := -1;
                    AvgDailyUsage := -1;
                end;
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
        DateFormat = 'MM/dd/yy';
        PMMasterScheduleCaption = 'PM Master Schedule';
        PageNoCaption = 'Page';
        UsageUOMCaption = 'Usage UOM';
        UsageDateCaption = 'Last Usage Date';
        UsageReadingCaption = 'Last Usage Reading';
        AvgDailyUsageCaption = 'Average Daily Usage';
        LaborCostPlannedCaption = 'Labor Cost';
        MaterialCostPlannedCaption = 'Material Cost';
        ContractCostPlannedCaption = 'Contract Cost';
        NextPMDateCaption = 'Next PM Date';
        TotalCostCaption = 'Total Cost';
    }

    trigger OnPreReport()
    begin
        AssetFilter := Asset.GetFilters;
    end;

    var
        UsageDate: Date;
        UsageReading: Decimal;
        AvgDailyUsage: Decimal;
        AssetFilter: Text;
}

