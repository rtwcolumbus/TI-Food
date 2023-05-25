report 37002811 "Work Order History" // Version: FOODNA
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   This report shows all data for a workorder including complete text of work requested and correct action
    //     as well as planned and actual labor and material usage
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
    // P8000837, VerticalSoft, Jack Reynolds, 09 JUL 10
    //   RDLC layout issues
    // 
    // PRW16.00.06
    // P8001109, Columbus IT, Jack Reynolds, 25 OCT 12
    //   Fix problem with actual meterial quantity
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
    Caption = 'Work Order History';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Work Order"; "Work Order")
        {
            RequestFilterFields = "No.", "Asset No.", "Origination Date", "Completion Date";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(WorkOrderAssetNo; "Asset No.")
            {
                IncludeCaption = true;
            }
            column(WorkOrderOriginationDate; "Origination Date")
            {
                IncludeCaption = true;
            }
            column(WorkOrderOriginationTime; "Origination Time")
            {
            }
            column(WorkOrderOriginator; Originator)
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
            column(WorkOrderPhysicalLocation; "Physical Location")
            {
                IncludeCaption = true;
            }
            column(WorkOrderPriority; Priority)
            {
                IncludeCaption = true;
            }
            column(WorkOrderStatus; Status)
            {
                IncludeCaption = true;
            }
            column(WorkOrderDueDate; "Due Date")
            {
                IncludeCaption = true;
            }
            column(WorkOrderDueTime; "Due Time")
            {
            }
            column(WorkOrderScheduledDate; "Scheduled Date")
            {
                IncludeCaption = true;
            }
            column(WorkOrderScheduledTime; "Scheduled Time")
            {
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
            column(WorkOrderCompletionTime; "Completion Time")
            {
            }
            column(WorkOrderUsage; Usage)
            {
                IncludeCaption = true;
            }
            column(FreqLabel; FreqLabel)
            {
            }
            column(FrequencyDesc; Frequency.Description)
            {
            }
            column(AssetUsageUOM; Asset."Usage Unit of Measure")
            {
            }
            column(WorkOrderNo; "No.")
            {
                IncludeCaption = true;
            }
            column(WorkOrderDowntimeHrs; "Downtime (Hours)")
            {
                DecimalPlaces = 2 : 2;
                IncludeCaption = true;
            }
            column(WorkOrderHeader; 'WorkOrder')
            {
            }
            dataitem(Text; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                column(WorkReqLine; WorkReq.Line)
                {
                }
                column(CorrActLine; CorrAct.Line)
                {
                }
                column(TextRec; Format(Number))
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then begin
                        WorkReqEOF := not WorkReq.FindFirst;
                        CorrActEOF := not CorrAct.FindFirst;
                    end else begin
                        WorkReqEOF := WorkReq.Next = 0;
                        CorrActEOF := CorrAct.Next = 0;
                    end;

                    if WorkReqEOF then
                        WorkReq.Line := '';
                    if CorrActEOF then
                        CorrAct.Line := '';

                    if WorkReqEOF and CorrActEOF then
                        CurrReport.Break;
                end;

                trigger OnPreDataItem()
                begin
                    WorkReq.SetRange(ID, "Work Order"."Work Requested");
                    CorrAct.SetRange(ID, "Work Order"."Corrective Action");
                end;
            }
            dataitem(ActAndMtlHdr; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(ActAndMtlHdrRec; Format(Number))
                {
                }
            }
            dataitem(ActAndMtl; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                column(ActivityLabel; ActivityLabel)
                {
                }
                column(WOActivityDisplayTradeCode; WOActivityDisplay."Trade Code")
                {
                }
                column(WOActivityDisplayPlannedHrs; WOActivityDisplay."Planned Hours")
                {
                }
                column(WOActivityDisplayPlannedCost; WOActivityDisplay."Planned Cost")
                {
                }
                column(WOActivityDisplayActualHrs; WOActivityDisplay."Actual Hours")
                {
                }
                column(WOActivityDisplayActualCost; WOActivityDisplay."Actual Cost")
                {
                }
                column(WOMaterialDisplayPartNo; WOMaterialDisplay."Part No.")
                {
                }
                column(MaterialLabel; MaterialLabel)
                {
                }
                column(WOMaterialDisplayDesc; WOMaterialDisplay.Description)
                {
                }
                column(WOMaterialDisplayUOMCode; WOMaterialDisplay."Unit of Measure Code")
                {
                }
                column(WOMaterialDisplayPlannedQuantityBase; WOMaterialDisplay."Planned Quantity (Base)")
                {
                }
                column(WOMaterialDisplayPlannedCost; WOMaterialDisplay."Planned Cost")
                {
                }
                column(WOMaterialDisplayActualQuantityBase; WOMaterialDisplay."Actual Quantity (Base)")
                {
                }
                column(WOMaterialDisplayActualCost; WOMaterialDisplay."Actual Cost")
                {
                }
                column(ActivityTotal; ActivityTotal)
                {
                }
                column(MaterialTotal; MaterialTotal)
                {
                }
                column(ActAndMtlRec; Format(Number))
                {
                }
                column(WOActivityEOF; WOActivityEOF)
                {
                }
                column(WOMaterialEOF; WOMaterialEOF)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    // EOF: 0 display record; 1 display total; >1 end of display
                    if Number = 1 then begin
                        if not WOActivity.FindFirst then
                            WOActivityEOF := 2;
                        if not WOMaterial.FindFirst then
                            WOMaterialEOF := 2;
                    end else begin
                        if WOActivity.Next = 0 then
                            WOActivityEOF += 1;
                        if WOMaterial.Next = 0 then
                            WOMaterialEOF += 1;
                    end;

                    if WOActivityEOF = 0 then begin
                        WOActivity.CalcFields("Actual Hours", "Actual Cost");
                        WOActivityTotal."Planned Hours" += WOActivity."Planned Hours";
                        WOActivityTotal."Planned Cost" += WOActivity."Planned Cost";
                        WOActivityTotal."Actual Hours" += WOActivity."Actual Hours";
                        WOActivityTotal."Actual Cost" += WOActivity."Actual Cost";
                        WOActivityDisplay := WOActivity;
                        ActivityLabel := Format(WOActivityDisplay.Type);
                        ActivityTotal := '';
                    end else
                        if WOActivityEOF = 1 then begin
                            WOActivityDisplay := WOActivityTotal;
                            ActivityLabel := '';
                            ActivityTotal := Text001;
                        end;
                    if WOMaterialEOF = 0 then begin
                        WOMaterial.CalcFields("Actual Quantity (Base)", "Actual Cost"); // P8001109
                        WOMaterialTotal."Planned Cost" += WOMaterial."Planned Cost";
                        WOMaterialTotal."Actual Cost" += WOMaterial."Actual Cost";
                        WOMaterialDisplay := WOMaterial;
                        MaterialLabel := Format(WOMaterialDisplay.Type);
                        MaterialTotal := '';
                        if WOMaterialDisplay.Type = WOMaterialDisplay.Type::Stock then
                            if Item.Get(WOMaterialDisplay."Item No.") then
                                WOMaterialDisplay."Unit of Measure Code" := Item."Base Unit of Measure";
                    end else
                        if WOMaterialEOF = 1 then begin
                            WOMaterialDisplay := WOMaterialTotal;
                            WOMaterialDisplay."Planned Quantity (Base)" := -1;
                            WOMaterialDisplay."Actual Quantity (Base)" := -1;
                            MaterialLabel := '';
                            MaterialTotal := Text001;
                        end;

                    if (WOActivityEOF > 1) and (WOMaterialEOF > 1) then
                        CurrReport.Break;
                end;

                trigger OnPreDataItem()
                begin
                    WOActivity.SetRange("Work Order No.", "Work Order"."No.");
                    WOMaterial.SetRange("Work Order No.", "Work Order"."No.");

                    WOActivityEOF := 0;
                    WOMaterialEOF := 0;

                    Clear(WOActivityTotal);
                    Clear(WOMaterialTotal);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if (not Asset.Get("Asset No.")) or (Usage < 0) then
                    Clear(Asset);

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
            LayoutFile = './layout/WorkOrderHistory.rdlc';
        }
    }

    labels
    {
        MaintenanceWorkOrderHistoryCaption = 'Maintenance Work Order History';
        WorkRequestedCaption = 'Work Requested:';
        CorrectiveActionCaption = 'Corrective Action:';
        ActivityLabelCaption = 'Type';
        TradeCodeCaption = 'Trade';
        PlannedHrsCaption = 'Planned Hours';
        PlannedCostCaption = 'Planned Cost';
        ActualCostCaption = 'Actual Cost';
        ActualHrsCaption = 'Actual Hours';
        PartNoCaption = 'Part No.';
        MaterialLabelCaption = 'Type';
        DescCaption = 'Description';
        PlannedQuantityCaption = 'Planned Quantity';
        UOMCaption = 'UOM';
        ActualQuantityCaption = 'Actual Quantity';
        LABORCONTRACTCaption = 'LABOR/CONTRACT';
        MATERIALCaption = 'MATERIAL';
    }

    var
        Asset: Record Asset;
        Frequency: Record "PM Frequency";
        WorkReq: Record "Extended Text";
        CorrAct: Record "Extended Text";
        WOActivity: Record "Work Order Activity";
        WOMaterial: Record "Work Order Material";
        WOActivityTotal: Record "Work Order Activity";
        WOMaterialTotal: Record "Work Order Material";
        WOActivityDisplay: Record "Work Order Activity";
        WOMaterialDisplay: Record "Work Order Material";
        Item: Record Item;
        FreqLabel: Text[30];
        Text001: Label 'Total';
        Text002: Label 'PM Frequency';
        ActivityLabel: Text[30];
        ActivityTotal: Text[30];
        MaterialLabel: Text[30];
        MaterialTotal: Text[30];
        WorkReqEOF: Boolean;
        CorrActEOF: Boolean;
        WOActivityEOF: Integer;
        WOMaterialEOF: Integer;
}

