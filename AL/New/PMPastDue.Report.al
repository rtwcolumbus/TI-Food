report 37002810 "PM Past Due" // Version: FOODNA
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   This report lists PM orders that are due on or before a specified date
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 27 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW17.10.01
    // P8001254, Columbus IT, Jack Reynolds, 06 JAN 14
    //   Adjust layout to accomodate Letter size paper
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
    RDLCLayout = './layout/PMPastDue.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'PM Past Due';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(PMO; "Preventive Maintenance Order")
        {
            DataItemTableView = SORTING("Asset No.", "Group Code", "Frequency Code");
            RequestFilterFields = "Asset No.", "Frequency Code";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(STRDueDate; StrSubstNo(Text001, DueDate))
            {
            }
            column(PMOAssetNo; "Asset No.")
            {
                IncludeCaption = true;
            }
            column(PMOGroupCode; "Group Code")
            {
                IncludeCaption = true;
            }
            column(PMOFrequencyCode; "Frequency Code")
            {
                IncludeCaption = true;
            }
            column(PMOLastPMDate; "Last PM Date")
            {
                IncludeCaption = true;
            }
            column(PMOLastPMUsage; "Last PM Usage")
            {
                IncludeCaption = true;
            }
            column(PMOLastWorkOrder; "Last Work Order")
            {
                IncludeCaption = true;
            }
            column(PMOCurrentWorkOrder; "Current Work Order")
            {
                IncludeCaption = true;
            }
            column(PMOWorkReqFirstLine; "Work Requested (First Line)")
            {
                IncludeCaption = true;
            }
            column(NextDate; NextDate)
            {
            }
            column(AssetDesc; Asset.Description)
            {
            }
            column(AssetUsageUOM; Asset."Usage Unit of Measure")
            {
            }
            column(PMOOverrideDate; "Override Date")
            {
                IncludeCaption = true;
            }

            trigger OnAfterGetRecord()
            begin
                NextDate := NextPMDate;
                if (NextDate > DueDate) or (NextDate = 0D) then
                    CurrReport.Skip;

                if not Asset.Get("Asset No.") then
                    Clear(Asset);
                if (not Frequency.Get("Frequency Code")) or (Frequency.Type = Frequency.Type::Calendar) then
                    Asset."Usage Unit of Measure" := '';
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
                    field(DueDate; DueDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Due on or before';
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
        PreventiveMaintPastDueCaption = 'Preventive Maintenance Past Due';
        PageNoCaption = 'Page';
        NextDateCaption = 'Next PM Date';
        AssetDescCaption = 'Asset Description';
        UsageUOMCaption = 'Usage UOM';
    }

    trigger OnInitReport()
    begin
        DueDate := WorkDate;
    end;

    var
        Asset: Record Asset;
        Frequency: Record "PM Frequency";
        DueDate: Date;
        NextDate: Date;
        Text001: Label 'Due on or before %1';
}

