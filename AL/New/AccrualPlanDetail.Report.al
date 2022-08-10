report 37002124 "Accrual Plan Detail"
{
    // PR3.70.03
    // 
    // PR3.70.07
    // P8000119A, Myers Nissi, Don Bresee, 20 SEP 04
    //   Accruals update/fixes
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 19 JUN 08
    //   Add caption property
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 20 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW16.00.06
    // P8001011, Columbus IT, Jack Reynolds, 05 JAN 12
    //   Fix problem with incorrect totaling in the RTC
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
    RDLCLayout = './layout/AccrualPlanDetail.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Accrual Plan Detail';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(AccrualPlan; "Accrual Plan")
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = Type, "No.", "Source Filter", "Item Filter", "Date Filter";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(GETFILTERS; GetFilters)
            {
            }
            column(STRTypeNoName; StrSubstNo(Text000, Type, "No.", Name))
            {
            }
            column(AccrualPlanType; Type)
            {
            }
            column(AccrualPlanNo; "No.")
            {
            }
            column(AccrualPlanBody; 'AccrualPlanBody')
            {
            }
            column(Text002; Text002)
            {
            }
            column(AccrualPlanBalance; TotalAccrualAmount + TotalPaymentAmount)
            {
            }
            column(AccrualPlanPaymentAmount; TotalPaymentAmount)
            {
            }
            column(AccrualPlanAccrualAmount; TotalAccrualAmount)
            {
            }
            dataitem(SourceLedgEntry; "Accrual Ledger Entry")
            {
                DataItemLink = "Accrual Plan Type" = FIELD(Type), "Accrual Plan No." = FIELD("No."), "Source No." = FIELD("Source Filter"), "Item No." = FIELD("Item Filter"), "Posting Date" = FIELD("Date Filter");
                DataItemTableView = SORTING("Accrual Plan Type", "Accrual Plan No.", "Source No.", "Entry Type", Type, "No.", "Item No.", "Posting Date");
                column(AccrualSource; AccrualSourceDescription())
                {
                }
                column(SourceLedgEntryAccrualAmount; TotalAccrualAmount)
                {
                }
                column(SourceLedgEntryBody; 'SourceLedgEntryBody')
                {
                }
                column(SourceLedgEntryEntryNo; "Entry No.")
                {
                }
                column(TotalAccrualAmountDetail; TotalAccrualAmountDetail)
                {
                }
                column(STRAccrualPlanTypeAccrualPlanNoText001; StrSubstNo(Text000, AccrualPlan.Type, AccrualPlan."No.", Text001))
                {
                }
                column(SourceLedgEntryBalance; TotalAccrualAmount + TotalPaymentAmount)
                {
                }
                column(SourceLedgEntryPaymentAmount; TotalPaymentAmount)
                {
                }
                column(SourceLedgEntryAccrualPlanType; "Accrual Plan Type")
                {
                }
                column(SourceLedgEntryAccrualPlanNo; "Accrual Plan No.")
                {
                }
                dataitem(PaymentLedgEntry; "Accrual Ledger Entry")
                {
                    DataItemLink = "Accrual Plan Type" = FIELD("Accrual Plan Type"), "Accrual Plan No." = FIELD("Accrual Plan No."), "Source No." = FIELD("Source No.");
                    DataItemTableView = SORTING("Accrual Plan Type", "Accrual Plan No.", "Entry Type", "Source No.", Type, "No.", "Source Document Type", "Source Document No.", "Source Document Line No.", "Item No.", "Posting Date");
                    column(AccrualPaidto; AccrualPaidToDescription())
                    {
                    }
                    column(PaymentLedgEntryPayment; PaymentPercent)
                    {
                        DecimalPlaces = 0 : 1;
                    }
                    column(PaymentAmount; PaymentAmount)
                    {
                    }
                    column(PaymentLedgEntrEntryNo; "Entry No.")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        SetRange(Type, Type);
                        SetRange("No.", "No.");
                        Find('+');

                        CalcSums(Amount);
                        PaymentAmount := Amount;
                        if (TotalPaymentAmount = 0) then
                            PaymentPercent := 0
                        else
                            PaymentPercent := 100 * (PaymentAmount / TotalPaymentAmount);

                        // P8001011
                        if not FirstDetail then
                            TotalAccrualAmountDetail := 0
                        else
                            FirstDetail := false;
                        // P8001011

                        SetRange(Type);
                        SetRange("No.");
                    end;

                    trigger OnPreDataItem()
                    begin
                        AccrualPlan.CopyFilter("Item Filter", "Item No.");
                        AccrualPlan.CopyFilter("Date Filter", "Posting Date");

                        SetRange("Entry Type", "Entry Type"::Payment);
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    // P8000119A
                    SetRange("Source No.", "Source No.");

                    SetRange("Entry Type", "Entry Type"::Accrual);
                    CalcSums(Amount);
                    TotalAccrualAmount := Amount;
                    TotalAccrualAmountDetail := Amount; // P8001011
                    FirstDetail := true;                // P8001011
                    SetRange("Entry Type", "Entry Type"::Payment);
                    CalcSums(Amount);
                    TotalPaymentAmount := Amount;
                    SetRange("Entry Type");

                    Find('+');
                    SetRange("Source No.");
                end;
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
        AccrualPlanDetailCaption = 'Accrual Plan Detail';
        PAGENOCaption = 'Page';
        AccrualAmountCaption = 'Accrual Amount';
        PaymentCaption = 'Payment %';
        PaymentAmountCaption = 'Payment Amount';
        BalanceCaption = 'Balance';
        AccrualSourceCaption = 'Accrual Source';
        AccrualPaidtoCaption = 'Accrual Paid-to';
    }

    var
        Text000: Label '%1 Plan %2 %3';
        TotalAccrualAmount: Decimal;
        TotalPaymentAmount: Decimal;
        PaymentPercent: Decimal;
        PaymentAmount: Decimal;
        Text001: Label 'Totals:';
        TotalAccrualAmountDetail: Decimal;
        Customer: Record Customer;
        Vendor: Record Vendor;
        GLAccount: Record "G/L Account";
        Text002: Label 'Report Totals';
        FirstDetail: Boolean;

    local procedure AccrualSourceDescription(): Text[250]
    begin
        with SourceLedgEntry do
            exit(GetSourceDescription("Accrual Plan Type", "Source No."));
    end;

    local procedure AccrualPaidToDescription(): Text[250]
    begin
        with PaymentLedgEntry do
            exit(GetSourceDescription(Type, "No."));
    end;

    local procedure GetSourceDescription(SourceType: Integer; SourceNo: Code[20]): Text[250]
    begin
        case SourceType of
            SourceLedgEntry.Type::Customer:
                with Customer do begin
                    if ("No." <> SourceNo) then
                        Get(SourceNo);
                    exit(StrSubstNo('%1 %2 %3', TableCaption, "No.", Name));
                end;
            SourceLedgEntry.Type::Vendor:
                with Vendor do begin
                    if ("No." <> SourceNo) then
                        Get(SourceNo);
                    exit(StrSubstNo('%1 %2 %3', TableCaption, "No.", Name));
                end;
            SourceLedgEntry.Type::"G/L Account":
                with GLAccount do begin
                    if ("No." <> SourceNo) then
                        Get(SourceNo);
                    exit(StrSubstNo('%1 %2 %3', TableCaption, "No.", Name));
                end;
        end;
    end;
}

