report 129 "Customer - Trial Balance"
{
    DefaultLayout = RDLC;
    RDLCLayout = './layout/CustomerTrialBalance.rdlc';
    AdditionalSearchTerms = 'payment due,order status';
    ApplicationArea = Basic, Suite;
    Caption = 'Customer - Trial Balance';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING("Customer Posting Group");
            RequestFilterFields = "No.", "Date Filter", "Customer Posting Group";
            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(PeriodFilter; StrSubstNo(Text003, PeriodFilter))
            {
            }
            column(CustFieldCaptPostingGroup; StrSubstNo(Text005, FieldCaption("Customer Posting Group")))
            {
            }
            column(CustTableCaptioncustFilter; TableCaption + ': ' + CustFilter)
            {
            }
            column(CustFilter; CustFilter)
            {
            }
            column(EmptyString; '')
            {
            }
            column(PeriodStartDate; Format(PeriodStartDate))
            {
            }
            column(PeriodFilter1; PeriodFilter)
            {
            }
            column(FiscalYearStartDate; Format(FiscalYearStartDate))
            {
            }
            column(FiscalYearFilter; FiscalYearFilter)
            {
            }
            column(PeriodEndDate; Format(PeriodEndDate))
            {
            }
            column(PostingGroup_Customer; "Customer Posting Group")
            {
            }
            column(YTDTotal; YTDTotal)
            {
                AutoFormatType = 1;
            }
            column(YTDCreditAmt; YTDCreditAmt)
            {
                AutoFormatType = 1;
            }
            column(YTDDebitAmt; YTDDebitAmt)
            {
                AutoFormatType = 1;
            }
            column(YTDBeginBalance; YTDBeginBalance)
            {
            }
            column(PeriodCreditAmt; PeriodCreditAmt)
            {
            }
            column(PeriodDebitAmt; PeriodDebitAmt)
            {
            }
            column(PeriodBeginBalance; PeriodBeginBalance)
            {
            }
            column(Name_Customer; Name)
            {
                IncludeCaption = true;
            }
            column(No_Customer; "No.")
            {
                IncludeCaption = true;
            }
            column(TotalPostGroup_Customer; Text004 + Format(' ') + "Customer Posting Group")
            {
            }
            column(CustTrialBalanceCaption; CustTrialBalanceCaptionLbl)
            {
            }
            column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
            {
            }
            column(AmtsinLCYCaption; AmtsinLCYCaptionLbl)
            {
            }
            column(inclcustentriesinperiodCaption; inclcustentriesinperiodCaptionLbl)
            {
            }
            column(YTDTotalCaption; YTDTotalCaptionLbl)
            {
            }
            column(PeriodCaption; PeriodCaptionLbl)
            {
            }
            column(FiscalYearToDateCaption; FiscalYearToDateCaptionLbl)
            {
            }
            column(NetChangeCaption; NetChangeCaptionLbl)
            {
            }
            column(TotalinLCYCaption; TotalinLCYCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                CalcAmounts(
                  PeriodStartDate, PeriodEndDate,
                  PeriodBeginBalance, PeriodDebitAmt, PeriodCreditAmt, YTDTotal);

                CalcAmounts(
                  FiscalYearStartDate, PeriodEndDate,
                  YTDBeginBalance, YTDDebitAmt, YTDCreditAmt, YTDTotal);
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
        PeriodBeginBalanceCaption = 'Beginning Balance';
        PeriodDebitAmtCaption = 'Debit';
        PeriodCreditAmtCaption = 'Credit';
    }

    trigger OnPreReport()
    begin
        with Customer do begin
            PeriodFilter := GetFilter("Date Filter");
            PeriodStartDate := GetRangeMin("Date Filter");
            PeriodEndDate := GetRangeMax("Date Filter");
            SetRange("Date Filter");
            CustFilter := GetFilters();
            SetRange("Date Filter", PeriodStartDate, PeriodEndDate);
            AccountingPeriod.SetRange("Starting Date", 0D, PeriodEndDate);
            AccountingPeriod.SetRange("New Fiscal Year", true);
            if AccountingPeriod.FindLast() then
                FiscalYearStartDate := AccountingPeriod."Starting Date"
            else
                Error(Text000, AccountingPeriod.FieldCaption("Starting Date"), AccountingPeriod.TableCaption());
            FiscalYearFilter := Format(FiscalYearStartDate) + '..' + Format(PeriodEndDate);
        end;
    end;

    var
        AccountingPeriod: Record "Accounting Period";
        PeriodBeginBalance: Decimal;
        PeriodDebitAmt: Decimal;
        PeriodCreditAmt: Decimal;
        YTDBeginBalance: Decimal;
        YTDDebitAmt: Decimal;
        YTDCreditAmt: Decimal;
        YTDTotal: Decimal;
        PeriodFilter: Text;
        FiscalYearFilter: Text;
        CustFilter: Text;
        PeriodStartDate: Date;
        PeriodEndDate: Date;
        FiscalYearStartDate: Date;

        Text000: Label 'It was not possible to find a %1 in %2.';
        Text003: Label 'Period: %1';
        Text004: Label 'Total for';
        Text005: Label 'Group Totals: %1';
        CustTrialBalanceCaptionLbl: Label 'Customer - Trial Balance';
        CurrReportPageNoCaptionLbl: Label 'Page';
        AmtsinLCYCaptionLbl: Label 'Amounts in LCY';
        inclcustentriesinperiodCaptionLbl: Label 'Only includes customers with entries in the period';
        YTDTotalCaptionLbl: Label 'Ending Balance';
        PeriodCaptionLbl: Label 'Period';
        FiscalYearToDateCaptionLbl: Label 'Fiscal Year-To-Date';
        NetChangeCaptionLbl: Label 'Net Change';
        TotalinLCYCaptionLbl: Label 'Total in LCY';

    local procedure CalcAmounts(DateFrom: Date; DateTo: Date; var BeginBalance: Decimal; var DebitAmt: Decimal; var CreditAmt: Decimal; var TotalBalance: Decimal)
    var
        CustomerCopy: Record Customer;
    begin
        CustomerCopy.Copy(Customer);

        CustomerCopy.SetRange("Date Filter", 0D, DateFrom - 1);
        CustomerCopy.CalcFields("Net Change (LCY)");
        BeginBalance := CustomerCopy."Net Change (LCY)";

        CustomerCopy.SetRange("Date Filter", DateFrom, DateTo);
        CustomerCopy.CalcFields("Debit Amount (LCY)", "Credit Amount (LCY)");
        DebitAmt := CustomerCopy."Debit Amount (LCY)";
        CreditAmt := CustomerCopy."Credit Amount (LCY)";

        TotalBalance := BeginBalance + DebitAmt - CreditAmt;
    end;
}

