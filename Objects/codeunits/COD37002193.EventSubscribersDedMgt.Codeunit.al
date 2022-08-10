codeunit 37002193 "Event Subscribers (DedMgt)"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', true, false)]
    local procedure CustLedgerEntry_OnAfterCopyCustLedgerEntryFromGenJnlLine(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        // P8004516
        CustLedgerEntry."Deduction Management Entry" := GenJournalLine."Deduction Management Entry";
        CustLedgerEntry."Deduction Type" := GenJournalLine."Deduction Type";
        CustLedgerEntry."Original Entry No." := GenJournalLine."Original Entry No.";
        CustLedgerEntry."Original Customer No." := GenJournalLine."Original Customer No.";
        CustLedgerEntry."Assigned To" := GenJournalLine."Assigned To";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cust. Entry-Edit", 'OnBeforeCustLedgEntryModify', '', true, false)]
    local procedure CustEntryEdit_OnBeforeCustLedgEntryModify(var CustLedgEntry: Record "Cust. Ledger Entry"; FromCustLedgEntry: Record "Cust. Ledger Entry")
    begin
        // P80066030
        if CustLedgEntry.Open then begin
            CustLedgEntry."Assigned To" := FromCustLedgEntry."Assigned To"; // P8000170A
            CustLedgEntry."Deduction Type" := FromCustLedgEntry."Deduction Type"; // P8002751
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Apply", 'OnBeforeRun', '', true, false)]
    local procedure GenJnlApply_OnBeforeRun(var GenJnlLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
        // P80066030
        GenJnlLine.ErrorIfDeductionsExist; // P8000170A
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process 800 Core Functions", 'OnInitializeP800', '', true, false)]
    local procedure Process800CoreFunctions_OnInitializeP800(CompName: Text[30]; var SourceCodeSetup: Record "Source Code Setup"; var SourceCode: Record "Source Code"; var ReportSelections: Record "Report Selections")
    var
        DEDMGT: Label 'DEDMGT';
        DeductionManagement: Label 'Deduction Management';
        Process800CoreFunctions: Codeunit "Process 800 Core Functions";
    begin
        // P80066030
        Process800CoreFunctions.InsertSourceCode(SourceCode, SourceCodeSetup."Deduction Management", DEDMGT, DeductionManagement);
    end;
}

