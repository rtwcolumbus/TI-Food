codeunit 37002685 "Event Subscribers (Commodity)"
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

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', true, false)]
    local procedure VendorLedgerEntry_OnAfterCopyVendLedgerEntryFromGenJnlLine(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        // P8004516
        VendorLedgerEntry."Comm. Reference Date" := GenJournalLine."Comm. Reference Date"; // P8001213
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', true, false)]
    local procedure ItemJnlPostLine_OnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    begin
        // P8004516
        NewItemLedgEntry."Commodity Class Code" := ItemJournalLine."Commodity Class Code"; // P8000856
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process 800 Core Functions", 'OnInitializeP800', '', true, false)]
    local procedure Process800CoreFunctions_OnInitializeP800(CompName: Text[30]; var SourceCodeSetup: Record "Source Code Setup"; var SourceCode: Record "Source Code"; var ReportSelections: Record "Report Selections")
    var
        COMMADJ: Label 'COMMADJ';
        COMMMFST: Label 'COMMMFST';
        Process800CoreFunctions: Codeunit "Process 800 Core Functions";
        CommodityCostAdjustment: Label 'Commodity Cost Adjustment';
    begin
        // P80066030
        Process800CoreFunctions.InsertSourceCode(SourceCode, SourceCodeSetup."Commodity Cost Adjustment", COMMADJ, CommodityCostAdjustment);
        Process800CoreFunctions.InsertSourceCode(SourceCode, SourceCodeSetup."Commodity Manifest", COMMMFST, Process800CoreFunctions.PageName(PAGE::"Commodity Manifest"));
    end;
}

