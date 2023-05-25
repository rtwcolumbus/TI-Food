report 37002806 "Maintenance Work Order"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   This is a document style report for work orders
    // 
    // PRW16.00.01
    // P8000718, VerticalSoft, Jack Reynolds, 10 AUG 09
    //   Added downtime
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 05 MAY 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000837, VerticalSoft, Jack Reynolds, 07 SEP 10
    //   Controls in header were not aligned consistently
    // 
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues Property in the Request Page.
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
    Caption = 'Maintenance Work Order';
    UsageCategory = Documents;

    dataset
    {
        dataitem("Work Order"; "Work Order")
        {
            DataItemTableView = WHERE(Completed = CONST(false));
            RequestFilterFields = "No.", "Asset No.", "Location Code", "Due Date", "Scheduled Date";
            column(WorkOrderRec; "No.")
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
                {
                }
                column(STRWorkOrderNo; StrSubstNo(Text001, "Work Order"."No."))
                {
                }
                column(WorkOrderAssetNo; "Work Order"."Asset No.")
                {
                    IncludeCaption = true;
                }
                column(FrequencyDesc; Frequency.Description)
                {
                }
                column(WorkOrderOriginationDate; "Work Order"."Origination Date")
                {
                    IncludeCaption = true;
                }
                column(WorkOrderOriginationTime; "Work Order"."Origination Time")
                {
                }
                column(WorkOrderOriginator; "Work Order".Originator)
                {
                    IncludeCaption = true;
                }
                column(WorkOrderAssetDesc; "Work Order"."Asset Description")
                {
                    IncludeCaption = true;
                }
                column(WorkOrderLocationCode; "Work Order"."Location Code")
                {
                    IncludeCaption = true;
                }
                column(WorkOrderPhysicalLocation; "Work Order"."Physical Location")
                {
                    IncludeCaption = true;
                }
                column(WorkOrderPriority; "Work Order".Priority)
                {
                    IncludeCaption = true;
                }
                column(WorkOrderDueDate; "Work Order"."Due Date")
                {
                    IncludeCaption = true;
                }
                column(WorkOrderDueTime; "Work Order"."Due Time")
                {
                }
                column(WorkOrderScheduledDate; "Work Order"."Scheduled Date")
                {
                    IncludeCaption = true;
                }
                column(WorkOrderScheduledTime; "Work Order"."Scheduled Time")
                {
                }
                column(WorkOrderFaultCode; "Work Order"."Fault Code")
                {
                    IncludeCaption = true;
                }
                column(FreqLabel; FreqLabel)
                {
                }
                column(CopyLoopRec; Format(Number))
                {
                }
                column(CopyLoopHeader; 'CopyLoop')
                {
                }
                dataitem(WorkRequest; "Extended Text")
                {
                    DataItemLink = ID = FIELD("Work Requested");
                    DataItemLinkReference = "Work Order";
                    DataItemTableView = SORTING(ID, LineNo);
                    column(WorkRequestLine; Line)
                    {
                    }
                    column(WorkRequestRec; Format(ID) + Format(LineNo))
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        LinesPrinted += 1;
                        if LinesPrinted > LinesPerPage then
                            CurrReport.Break;
                    end;

                    trigger OnPreDataItem()
                    begin
                        LinesPrinted := 0;
                    end;
                }
                dataitem(WorkRequestFiller; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    column(WorkRequestFillerRec; Format(Number))
                    {
                    }

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, LinesPerPage - LinesPrinted);
                    end;
                }
                dataitem(CorrectiveAction; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = FILTER(0 .. 8));
                    column(CorrectiveActionRec; Format(Number))
                    {
                    }
                }
                dataitem(LaborAndMtl; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = FILTER(0 .. 5));
                    column(LaborAndMtlRec; Format(Number))
                    {
                    }
                }
                dataitem(WorkRequestCont; "Extended Text")
                {
                    DataItemLink = ID = FIELD("Work Requested");
                    DataItemLinkReference = "Work Order";
                    DataItemTableView = SORTING(ID, LineNo);
                    column(WorkReqContLine; Line)
                    {
                    }
                    column(WorkReqContRec; Format(ID) + Format(LineNo))
                    {
                    }
                    column(WorkReqContHeader; 'WorkRequestedCont')
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        LinesPrinted += 1;
                        if LinesPrinted <= LinesPerPage then
                            CurrReport.Skip;
                    end;

                    trigger OnPreDataItem()
                    begin
                        LinesPrinted := 0;
                    end;
                }

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, NoOfCopies);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if Frequency.Get("Frequency Code") then
                    FreqLabel := Text002
                else begin
                    Clear(Frequency);
                    FreqLabel := '';
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
                    field(NoOfCopies; NoOfCopies)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'No. of Copies';
                        MinValue = 1;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if NoOfCopies = 0 then
                NoOfCopies := 1;
        end;
    }

    rendering
    {
        layout(StandardRDLCLayout)
        {
            Summary = 'Standard Layout';
            Type = RDLC;
            LayoutFile = './layout/MaintenanceWorkOrder.rdlc';
        }
    }

    labels
    {
        WorkRequestedCaption = 'Work Requested:';
        CompletionDateTimeCaption = 'Completion Date/Time';
        CauseCodeCaption = 'Cause Code';
        ActionCodeCaption = 'Action Code';
        CorrectiveActionCaption = 'Corrective Action:';
        CancelledCaption = 'Cancelled';
        NoCaption = 'No';
        YesCaption = 'Yes';
        DowntimeHrsCaption = 'Downtime (Hours)';
        HrsCaption = 'Hours';
        EmployeeVendorCaption = 'Employee/Vendor';
        TradeCaption = 'Trade';
        DateCaption = 'Date';
        LABORCONTRACTCaption = 'LABOR / CONTRACT';
        MATERIALCaption = 'MATERIAL';
        QuantityCaption = 'Quantity';
        PartNoCaption = 'Part No.';
        ItemNoCaption = 'Item No.';
        UOMCaption = 'UOM';
        WorkRequestedcontinuedCaption = 'Work Requested (continued):';
    }

    trigger OnInitReport()
    begin
        LinesPerPage := 9;
    end;

    var
        Frequency: Record "PM Frequency";
        NoOfCopies: Integer;
        Text001: Label 'Maintenance Work Order %1';
        Text002: Label 'PM Frequency';
        FreqLabel: Text[30];
        LinesPerPage: Integer;
        LinesPrinted: Integer;
}

