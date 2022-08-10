codeunit 5837 "Additional-Currency Management"
{
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 9 NOV 15
    //   NAV 2016 refactoring


    trigger OnRun()
    begin
    end;

    var
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        GLSetupRead: Boolean;
        CurrencyRead: Boolean;

    local procedure InitCodeunit(): Boolean
    begin
        if not GLSetupRead then begin
            GLSetup.Get();
            GLSetupRead := true;
        end;
        if GLSetup."Additional Reporting Currency" = '' then
            exit;
        if not CurrencyRead then begin
            Currency.Get(GLSetup."Additional Reporting Currency");
            Currency.TestField("Unit-Amount Rounding Precision");
            Currency.TestField("Amount Rounding Precision");
            CurrencyRead := true;
        end;
        exit(true);
    end;

    procedure CalcACYAmt(Amount: Decimal; PostingDate: Date; IsUnitAmount: Boolean): Decimal
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if not InitCodeunit then
            exit;
        exit(
          RoundACYAmt(
            CurrExchRate.ExchangeAmtLCYToFCY(
              PostingDate, GLSetup."Additional Reporting Currency", Amount,
              CurrExchRate.ExchangeRate(PostingDate, GLSetup."Additional Reporting Currency")),
            IsUnitAmount));
    end;

    procedure RoundACYAmt(UnroundedACYAmt: Decimal; IsUnitAmount: Boolean): Decimal
    var
        RndgPrec: Decimal;
    begin
        if not InitCodeunit then
            exit;
        if IsUnitAmount then
            RndgPrec := Currency."Unit-Amount Rounding Precision"
        else
            RndgPrec := Currency."Amount Rounding Precision";
        exit(Round(UnroundedACYAmt, RndgPrec));
    end;
}

