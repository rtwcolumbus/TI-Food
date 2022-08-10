codeunit 101 "Cust. Entry-SetAppl.ID"
{
    // PR3.70.08
    // P8000170A, Myers Nissi, Jack Reynolds, 31 JAN 05
    //   Deduction Management
    // 
    // PRW110.0.02
    // P80050544, To-Increase, Dayakar Battini, 16 JAN 18
    //   Upgrade to 2017 CU13
    // 
    // PRW111.00.01
    // P80063377, To-Increase, Jack Reynolds, 16 AUG 18
    //   Fiox problem setting Applies-to ID

    Permissions = TableData "Cust. Ledger Entry" = imd;

    trigger OnRun()
    begin
    end;

    var
        CustEntryApplID: Code[50];

    procedure SetApplId(var CustLedgEntry: Record "Cust. Ledger Entry"; ApplyingCustLedgEntry: Record "Cust. Ledger Entry"; AppliesToID: Code[50])
    var
        TempCustLedgEntry: Record "Cust. Ledger Entry" temporary;
    begin
        CustLedgEntry.LockTable();
        if CustLedgEntry.FindSet() then begin
            // Make Applies-to ID
            if CustLedgEntry."Applies-to ID" <> '' then
                CustEntryApplID := ''
            else begin
                CustEntryApplID := AppliesToID;
                if CustEntryApplID = '' then begin
                    CustEntryApplID := UserId;
                    if CustEntryApplID = '' then
                        CustEntryApplID := '***';
                end;
            end;
            repeat
                TempCustLedgEntry := CustLedgEntry;
                TempCustLedgEntry.Insert();
            until CustLedgEntry.Next() = 0;
        end;

        if TempCustLedgEntry.FindSet() then
            repeat
                UpdateCustLedgerEntry(TempCustLedgEntry, ApplyingCustLedgEntry, AppliesToID);
            until TempCustLedgEntry.Next() = 0;
    end;

    local procedure UpdateCustLedgerEntry(var TempCustLedgerEntry: Record "Cust. Ledger Entry" temporary; ApplyingCustLedgerEntry: Record "Cust. Ledger Entry"; AppliesToID: Code[50])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateCustLedgerEntry(TempCustLedgerEntry, ApplyingCustLedgerEntry, AppliesToID, IsHandled, CustEntryApplID);
        if IsHandled then
            exit;

        CustLedgerEntry.Copy(TempCustLedgerEntry);
        CustLedgerEntry.TestField(Open, true);
        // CustLedgerEntry."Applies-to ID" := CustEntryApplID; // P80050544
        CustLedgerEntry.Validate("Applies-to ID",CustEntryApplID); // P8000170A, P80063377
        if CustLedgerEntry."Applies-to ID" = '' then begin
            CustLedgerEntry."Accepted Pmt. Disc. Tolerance" := false;
            CustLedgerEntry."Accepted Payment Tolerance" := 0;
        end;
        if ((CustLedgerEntry."Amount to Apply" <> 0) and (CustEntryApplID = '')) or
           (CustEntryApplID = '')
        then
            CustLedgerEntry."Amount to Apply" := 0
        else
            if CustLedgerEntry."Amount to Apply" = 0 then begin
                CustLedgerEntry.CalcFields("Remaining Amount");
                CustLedgerEntry."Amount to Apply" := CustLedgerEntry."Remaining Amount"
            end;

        if CustLedgerEntry."Entry No." = ApplyingCustLedgerEntry."Entry No." then
            CustLedgerEntry."Applying Entry" := ApplyingCustLedgerEntry."Applying Entry";
        OnUpdateCustLedgerEntryOnBeforeCustLedgerEntryModify(CustLedgerEntry, TempCustLedgerEntry, ApplyingCustLedgerEntry, AppliesToID);
        CustLedgerEntry.Modify();

        OnAfterUpdateCustLedgerEntry(CustLedgerEntry, TempCustLedgerEntry, ApplyingCustLedgerEntry, AppliesToID);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateCustLedgerEntry(var TempCustLedgerEntry: Record "Cust. Ledger Entry" temporary; ApplyingCustLedgerEntry: Record "Cust. Ledger Entry"; AppliesToID: Code[50]; var IsHandled: Boolean; var CustEntryApplID: Code[50]);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateCustLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; var TempCustLedgerEntry: Record "Cust. Ledger Entry" temporary; ApplyingCustLedgerEntry: Record "Cust. Ledger Entry"; AppliesToID: Code[50]);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateCustLedgerEntryOnBeforeCustLedgerEntryModify(var CustLedgerEntry: Record "Cust. Ledger Entry"; var TempCustLedgerEntry: Record "Cust. Ledger Entry" temporary; ApplyingCustLedgerEntry: Record "Cust. Ledger Entry"; AppliesToID: Code[50]);
    begin
    end;
}

