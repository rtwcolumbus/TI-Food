codeunit 37002136 "Event Subscribers (Rebate)"
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
        VendorLedgerEntry."Accrual Entry" := GenJournalLine."Accrual Entry"; // P8001213
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Line", 'OnAfterInitFromSalesLine', '', true, false)]
    local procedure SalesInvoiceLine_OnAfterInitFromSalesLine(var SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line")
    begin
        // P80053245
        // P8004516
        SalesInvLine."Accrual Posting Date" := SalesInvHeader."Posting Date";
        SalesInvLine."Accrual Order Date" := SalesInvHeader."Order Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Cr.Memo Line", 'OnAfterInitFromSalesLine', '', true, false)]
    local procedure SalesCrMemoLine_OnAfterInitFromSalesLine(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesLine: Record "Sales Line")
    begin
        // P80053245
        // P8004516
        SalesCrMemoLine."Accrual Posting Date" := SalesCrMemoHeader."Posting Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterUpdateGlobalDimCode', '', true, false)]
    local procedure DefaultDimension_OnAfterUpdateGlobalDimCode(GlobalDimCodeNo: Integer; TableID: Integer; AccNo: Code[20]; NewDimValue: Code[20])
    var
        AccrualFieldManagement: Codeunit "Accrual Field Management";
    begin
        // P80053245
        case TableID of
            // P8001133
            DATABASE::"Accrual Plan":
                AccrualFieldManagement.UpdateAccrualPlanGLobalDimCode(GlobalDimCodeNo, AccNo, NewDimValue);
                // P8001133
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', true, false)]
    local procedure GenJnlCheckLine_OnAfterCheckGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        AccrualJnlCheckLine: Codeunit "Accrual Jnl.-Check Line";
    begin
        // P8000241A, P80066030
        if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::FOODAccrualPlan) or
            (GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::FOODAccrualPlan)
        then
            AccrualJnlCheckLine.RunCheckGL(GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnBeforeInsertSalesOrderLine', '', true, false)]
    local procedure SalesQuoteToOrder_OnBeforeInsertSalesOrderLine(var SalesOrderLine: Record "Sales Line"; SalesOrderHeader: Record "Sales Header"; SalesQuoteLine: Record "Sales Line"; SalesQuoteHeader: Record "Sales Header")
    begin
        // P80053245
        SalesOrderLine.Validate(Quantity); // P8000691
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Quote to Order", 'OnBeforeInsertPurchOrderLine', '', true, false)]
    local procedure PurchQuoteToOrder_OnBeforeInsertPurchOrderLine(var PurchOrderLine: Record "Purchase Line"; PurchOrderHeader: Record "Purchase Header"; PurchQuoteLine: Record "Purchase Line"; PurchQuoteHeader: Record "Purchase Header")
    begin
        // P80053245
        PurchOrderLine.Validate(Quantity); // P8000691
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnAfterFillTableBuffer', '', true, false)]
    local procedure CalcGLAccWhereUsed_OnAfterFillTableBuffer(var TableBuffer: Record "Integer")
    begin
        // P80073095
        TableBuffer.Number := DATABASE::"Accrual Posting Group";
        TableBuffer.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnShowExtensionPage', '', true, false)]
    local procedure CalcGLAccWhereUsed_OnShowExtensionPage(GLAccountWhereUsed: Record "G/L Account Where-Used")
    var
        AccrualPostingGroup: Record "Accrual Posting Group";
    begin
        // P80066030
        case GLAccountWhereUsed."Table ID" of
            DATABASE::"Accrual Posting Group":
                begin
                    AccrualPostingGroup.Code := CopyStr(GLAccountWhereUsed."Key 1", 1, MaxStrLen(AccrualPostingGroup.Code));
                    PAGE.Run(0, AccrualPostingGroup);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnAfterGetPageID', '', true, false)]
    local procedure PageManagement_OnAfterGetPageID(RecordRef: RecordRef; var PageID: Integer)
    var
        AccrualPlan: Record "Accrual Plan";
        AccrualGroup: Record "Accrual Group";
    begin
        // P8004516, P80066030
        case RecordRef.Number of
            DATABASE::"Accrual Plan":
                begin
                    RecordRef.SetTable(AccrualPlan);
                    case AccrualPlan.Type of
                        AccrualPlan.Type::Sales:
                            if AccrualPlan."Plan Type" = AccrualPlan."Plan Type"::Commission then
                                PageID := PAGE::"Sales Commission Card"
                            else
                                PageID := PAGE::"Customer Rebate/Promo Card";
                        AccrualPlan.Type::Purchase:
                            PageID := PAGE::"Vendor Rebate/Promo Card";
                    end;
                end;
            DATABASE::"Accrual Group":
                begin
                    RecordRef.SetTable(AccrualGroup);
                    case AccrualGroup.Type of
                        AccrualGroup.Type::Customer:
                            PageID := PAGE::"Customer Accrual Group Card";
                        AccrualGroup.Type::Vendor:
                            PageID := PAGE::"Vendor Accrual Group Card";
                        AccrualGroup.Type::Item:
                            PageID := PAGE::"Item Accrual Group Card";
                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process 800 Core Functions", 'OnInitializeP800', '', true, false)]
    local procedure Process800CoreFunctions_OnInitializeP800(CompName: Text[30]; var SourceCodeSetup: Record "Source Code Setup"; var SourceCode: Record "Source Code"; var ReportSelections: Record "Report Selections")
    var
        ACCJNL: Label 'ACCJNL';
        SCHACCJNL: Label 'SCHACCJNL';
        Process800CoreFunctions: Codeunit "Process 800 Core Functions";
    begin
        // P80066030
        Process800CoreFunctions.InsertSourceCode(SourceCode, SourceCodeSetup."Accrual Journal", ACCJNL, Process800CoreFunctions.PageName(PAGE::"Accrual Journal"));
        Process800CoreFunctions.InsertSourceCode(SourceCode, SourceCodeSetup."Scheduled Accrual Journal", SCHACCJNL, Process800CoreFunctions.PageName(PAGE::"Scheduled Accrual Journal"));
    end;
}

