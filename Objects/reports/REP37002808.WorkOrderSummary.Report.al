report 37002808 "Work Order Summary"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   This report lists work orders showing total costs and complete text of work requested and corrective action
    // 
    // PRW16.00.01
    // P8000718, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Added downtime
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 27 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000837, VerticalSoft, Jack Reynolds, 08 JUL 10
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
    RDLCLayout = './layout/WorkOrderSummary.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Work Order Summary';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Work Order"; "Work Order")
        {
            RequestFilterFields = "No.", "Asset No.", "Location Code", "Origination Date", "Completion Date";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(WorkOrderTabCapWOFilter; "Work Order".TableCaption + ' - ' + WOFilter)
            {
            }
            column(WorkOrderNo; "No.")
            {
                IncludeCaption = true;
            }
            column(WorkOrderAssetNo; "Asset No.")
            {
                IncludeCaption = true;
            }
            column(WorkOrderAssetDesc; "Asset Description")
            {
                IncludeCaption = true;
            }
            column(WorkOrderLocationCode; "Location Code")
            {
                IncludeCaption = true;
            }
            column(WorkOrderOriginationDate; "Origination Date")
            {
                IncludeCaption = true;
            }
            column(WorkOrderCompletionDate; "Completion Date")
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
            column(WOFilter; WOFilter)
            {
            }
            dataitem(WorkRequest; "Extended Text")
            {
                DataItemLink = ID = FIELD("Work Requested");
                DataItemTableView = SORTING(ID, LineNo);
                column(WorkRequestLine; Line)
                {
                }
                column(WorkRequestHeader; 'WorkRequest')
                {
                }
                column(WorkRequestRec; Format(ID) + Format(LineNo))
                {
                }
                column(WorkRequestLineNo; LineNo)
                {
                }
            }
            dataitem(CorrectiveAction; "Extended Text")
            {
                DataItemLink = ID = FIELD("Corrective Action");
                DataItemTableView = SORTING(ID, LineNo);
                column(CorrectiveActionLine; Line)
                {
                }
                column(CorrectiveActionHeader; 'CorrectiveAction')
                {
                }
                column(CorrectiveActionRec; Format(ID) + Format(LineNo))
                {
                }
                column(CorrectiveActionLineNo; LineNo)
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                WorkRequestDisplayed := false;
                CorrActionDisplayed := false;

                // P8000812 S
                CalcFields("Total Cost (Actual)", "Labor Cost (Actual)", "Material Cost (Actual)", "Contract Cost (Actual)");//,"Downtime (Hours)");
                RTCa += "Total Cost (Actual)";
                RTCb += "Labor Cost (Actual)";
                RTCc += "Material Cost (Actual)";
                RTCd += "Contract Cost (Actual)";
                RTCe += "Downtime (Hours)";
                // P8000812 E
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            column(IntegerBody; 'Integer')
            {
            }
            column(RTCa; RTCa)
            {
            }
            column(RTCb; RTCb)
            {
            }
            column(RTCc; RTCc)
            {
            }
            column(RTCd; RTCd)
            {
            }
            column(RTCe; RTCe)
            {
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

    labels
    {
        WorkOrderSummaryCaption = 'Work Order Summary';
        PageNoCaption = 'Page';
        TotalCostActualCaption = 'Total Cost';
        LaborCostCaption = 'Labor Cost';
        MaterialCostCaption = 'Material Cost';
        ContractCostCaption = 'Contract Cost';
        WorkRequestedCaption = 'Work Requested';
        CorrectiveActionCaption = 'Corrective Action';
    }

    trigger OnPreReport()
    begin
        WOFilter := "Work Order".GetFilters;
    end;

    var
        WOFilter: Text;
        WorkRequestDisplayed: Boolean;
        CorrActionDisplayed: Boolean;
        RTCa: Decimal;
        RTCb: Decimal;
        RTCc: Decimal;
        RTCd: Decimal;
        RTCe: Decimal;
}

