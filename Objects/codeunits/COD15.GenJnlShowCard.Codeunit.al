codeunit 15 "Gen. Jnl.-Show Card"
{
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 04 SEP 05
    //   Accrual enhancements

    TableNo = "Gen. Journal Line";

    trigger OnRun()
    begin
        case "Account Type" of
            "Account Type"::"G/L Account":
                begin
                    GLAcc."No." := "Account No.";
                    PAGE.Run(PAGE::"G/L Account Card", GLAcc);
                end;
            "Account Type"::Customer:
                begin
                    Cust."No." := "Account No.";
                    PAGE.Run(PAGE::"Customer Card", Cust);
                end;
            "Account Type"::Vendor:
                begin
                    Vend."No." := "Account No.";
                    PAGE.Run(PAGE::"Vendor Card", Vend);
                end;
            "Account Type"::Employee:
                begin
                    Empl."No." := "Account No.";
                    PAGE.Run(PAGE::"Employee Card", Empl);
                end;
            "Account Type"::"Bank Account":
                begin
                    BankAcc."No." := "Account No.";
                    PAGE.Run(PAGE::"Bank Account Card", BankAcc);
                end;
            "Account Type"::"Fixed Asset":
                begin
                    FA."No." := "Account No.";
                    PAGE.Run(PAGE::"Fixed Asset Card", FA);
                end;
            "Account Type"::"IC Partner":
                begin
                    ICPartner.Code := "Account No.";
                    PAGE.Run(PAGE::"IC Partner Card", ICPartner);
                end;
            // P8000241A
            "Account Type"::FOODAccrualPlan:
                begin
                    if not AccrualPlan.Get(AccrualPlan.Type::Sales, "Account No.") then
                        if not AccrualPlan.Get(AccrualPlan.Type::Purchase, "Account No.") then
                            AccrualPlan."No." := "Account No.";
                    AccrualPlan.ShowCard;
                end;
                // P8000241A
        end;

        OnAfterRun(Rec);
    end;

    var
        GLAcc: Record "G/L Account";
        Cust: Record Customer;
        Empl: Record Employee;
        Vend: Record Vendor;
        BankAcc: Record "Bank Account";
        FA: Record "Fixed Asset";
        ICPartner: Record "IC Partner";
        AccrualPlan: Record "Accrual Plan";

    [IntegrationEvent(false, false)]
    local procedure OnAfterRun(GenJournalLine: Record "Gen. Journal Line")
    begin
    end;
}

