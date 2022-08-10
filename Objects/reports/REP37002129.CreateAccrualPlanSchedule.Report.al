report 37002129 "Create Accrual Plan Schedule"
{
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.03
    // P8000792, VerticalSoft, Rick Tweedle, 17 MAR 10
    //   Converted using TIF Editor
    // 
    // PRW16.00.04
    // P8000897, VerticalSoft, Jack Reynolds, 22 JAN 11
    //   Fix spelling mistake
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Create Accrual Plan Schedule';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number);

            trigger OnAfterGetRecord()
            begin
                AccrualSchdLine."Accrual Plan Type" := AccrualPlan.Type;
                AccrualSchdLine."Accrual Plan No." := AccrualPlan."No.";
                AccrualSchdLine."Entry Type" := AccrualEntryType;
                if (Number > 1) then
                    AccrualDate := CalcDate(AccrualInterval, AccrualDate);
                AccrualSchdLine."Scheduled Date" := AccrualDate;
                AccrualSchdLine.Amount := AccrualAmount;
                if Number = 1 then
                    AccrualSchdLine."No." := '0001'
                else
                    AccrualSchdLine."No." := IncStr(AccrualSchdLine."No.");
                AccrualSchdLine.Insert;
            end;

            trigger OnPreDataItem()
            begin
                AccrualSchdLine.Reset;

                SetRange(Number, 1, NoOfAccruals);

                AccrualDate := StartingAccrualDate;
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
                    field("Starting Accrual Date"; StartingAccrualDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Starting Accrual Date';
                    }
                    field("Accrual Interval"; AccrualInterval)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Accrual Interval';
                        DateFormula = true;
                    }
                    field("No. of Accruals"; NoOfAccruals)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'No. of Accruals';

                        trigger OnValidate()
                        begin
                            SetAccrualAmount;
                        end;
                    }
                    field("Accrual Amount"; AccrualAmount)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Accrual Amount';

                        trigger OnValidate()
                        begin
                            SetTotalAccruals;
                        end;
                    }
                    field("Total Accruals"; TotalAccruals)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Total Accruals';
                        Editable = false;
                    }
                    field("Estimated Accruals"; AccrualPlan.GetEstimatedAccrualAmount())
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Estimated Accruals';
                        Editable = false;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if (AccrualPlan."No." = '') then
                Error(Text000);

            AccrualSchdLine.Reset;
            AccrualSchdLine.SetRange("Accrual Plan Type", AccrualPlan.Type);
            AccrualSchdLine.SetRange("Accrual Plan No.", AccrualPlan."No.");
            AccrualSchdLine.SetRange("Entry Type", AccrualEntryType);
            if AccrualSchdLine.Find('-') then begin
                StartingAccrualDate := AccrualSchdLine."Scheduled Date";
                if (AccrualSchdLine.Next <> 0) then
                    if ((AccrualSchdLine."Scheduled Date" - StartingAccrualDate) = 1) then
                        AccrualInterval := '1D'
                    else
                        if ((AccrualSchdLine."Scheduled Date" - StartingAccrualDate) = 7) then
                            AccrualInterval := '1W'
                        else
                            if ((AccrualSchdLine."Scheduled Date" - StartingAccrualDate) = 14) then
                                AccrualInterval := '2W'
                            else
                                if (CalcDate('1M', StartingAccrualDate) = AccrualSchdLine."Scheduled Date") then
                                    AccrualInterval := '1M';
                NoOfAccruals := AccrualSchdLine.Count;
            end;

            AccrualPlan.CalcEstimatedTotals;

            SetAccrualAmount;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        if (StartingAccrualDate = 0D) then
            Error(Text001);
        if (AccrualInterval = '') then
            Error(Text002);
        if (NoOfAccruals = 0) then
            Error(Text003);
        if (AccrualAmount = 0) then
            Error(Text004);

        AccrualSchdLine.Reset;
        AccrualSchdLine.SetRange("Accrual Plan Type", AccrualPlan.Type);
        AccrualSchdLine.SetRange("Accrual Plan No.", AccrualPlan."No.");
        AccrualSchdLine.SetRange("Entry Type", AccrualEntryType);
        if AccrualSchdLine.Find('-') then
            if not Confirm(Text005, false, AccrualPlan.Type, AccrualPlan.TableCaption, AccrualPlan."No.") then
                CurrReport.Quit;
        AccrualSchdLine.DeleteAll;
    end;

    var
        StartingAccrualDate: Date;
        AccrualInterval: Code[20];
        NoOfAccruals: Integer;
        AccrualAmount: Decimal;
        TotalAccruals: Decimal;
        AccrualPlan: Record "Accrual Plan";
        AccrualEntryType: Integer;
        AccrualSchdLine: Record "Accrual Plan Schedule Line";
        AccrualDate: Date;
        Text000: Label 'This report must be run from the accrual plan form.';
        Text001: Label 'You must enter a Starting Payment Date.';
        Text002: Label 'You must enter an Accrual Interval.';
        Text003: Label 'You must enter the No. of Accruals.';
        Text004: Label 'You must enter an Accrual Amount.';
        Text005: Label 'Schedule lines exist for %1 %2 %3. All existing schedule lines will be deleted.\\Do you want to continue?';

    procedure SetPlan(AccrualPlanType: Integer; AccrualPlanNo: Code[20]; NewAccrualEntryType: Integer)
    begin
        AccrualPlan.Get(AccrualPlanType, AccrualPlanNo);
        AccrualEntryType := NewAccrualEntryType;
    end;

    local procedure SetAccrualAmount()
    begin
        if (NoOfAccruals <> 0) then
            AccrualAmount := Round(AccrualPlan.GetEstimatedAccrualAmount() / NoOfAccruals);
        SetTotalAccruals;
    end;

    local procedure SetTotalAccruals()
    begin
        TotalAccruals := NoOfAccruals * AccrualAmount;
    end;
}

