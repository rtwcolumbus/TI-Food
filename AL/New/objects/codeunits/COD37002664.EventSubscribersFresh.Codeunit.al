codeunit 37002664 "Event Subscribers (Fresh)"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW113.00.03
    // P80084737, To Increase, Jack Reynolds, 10 OCT 19
    //   Modify subscriptions for RunTrigger
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Rcpt. Header", 'OnAfterDeleteEvent', '', true, false)]
    local procedure PurchRcptHeader_OnAfterDelete(var Rec: Record "Purch. Rcpt. Header"; RunTrigger: Boolean)
    var
        DocExtraCharge: Record "Posted Document Extra Charge";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        // PR3.70.01
        DocExtraCharge.SetRange("Table ID", DATABASE::"Purch. Rcpt. Header");
        DocExtraCharge.SetRange("Document No.", Rec."No.");
        DocExtraCharge.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Rcpt. Line", 'OnAfterDeleteEvent', '', true, false)]
    local procedure PurchRcptLine_OnAfterDelete(var Rec: Record "Purch. Rcpt. Line"; RunTrigger: Boolean)
    var
        DocExtraCharge: Record "Posted Document Extra Charge";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        // PR3.70.01
        DocExtraCharge.SetRange("Table ID", DATABASE::"Purch. Rcpt. Line");
        DocExtraCharge.SetRange("Document No.", Rec."Document No.");
        DocExtraCharge.SetRange("Line No.", Rec."Line No.");
        DocExtraCharge.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Header", 'OnAfterDeleteEvent', '', true, false)]
    local procedure PurchInvHeader_OnAfterDelete(var Rec: Record "Purch. Inv. Header"; RunTrigger: Boolean)
    var
        DocExtraCharge: Record "Posted Document Extra Charge";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        // PR3.70.01
        DocExtraCharge.SetRange("Table ID", DATABASE::"Purch. Inv. Header");
        DocExtraCharge.SetRange("Document No.", Rec."No.");
        DocExtraCharge.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Cr. Memo Hdr.", 'OnAfterDeleteEvent', '', true, false)]
    local procedure PurchCrMemoHdr_OnAfterDelete(var Rec: Record "Purch. Cr. Memo Hdr."; RunTrigger: Boolean)
    var
        DocExtraCharge: Record "Posted Document Extra Charge";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        // PR3.70.01
        DocExtraCharge.SetRange("Table ID", DATABASE::"Purch. Cr. Memo Hdr.");
        DocExtraCharge.SetRange("Document No.", Rec."No.");
        DocExtraCharge.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Return Shipment Header", 'OnAfterDeleteEvent', '', true, false)]
    local procedure ReturnShipmentHeader_OnAfterDelete(var Rec: Record "Return Shipment Header"; RunTrigger: Boolean)
    var
        DocExtraCharge: Record "Posted Document Extra Charge";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        // PR3.70.01
        DocExtraCharge.SetRange("Table ID", DATABASE::"Return Shipment Header");
        DocExtraCharge.SetRange("Document No.", Rec."No.");
        DocExtraCharge.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', true, false)]
    local procedure PurchPost_OnAfterPostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20])
    var
        ExtraCharge: Record "Extra Charge";
        P800UtilityFunctions: Codeunit "Process 800 Utility Functions";
        ExtraChargeManagement: Codeunit "Extra Charge Management";
    begin
        // P80053245
        if P800UtilityFunctions.IsOnCallStack(Format(OBJECTTYPE::Page), PAGE::"Truckload Receiving", '') then
            exit;

        if PurchaseHeader.Receive or PurchaseHeader.Ship then begin
            ExtraChargeManagement.UpdatePurchaseVendorBuffer(PurchaseHeader);
            ExtraChargeManagement.CreateVendorInvoices(ExtraCharge);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnAfterFillTableBuffer', '', true, false)]
    local procedure CalcGLAccWhereUsed_OnAfterFillTableBuffer(var TableBuffer: Record "Integer")
    begin
        // P80073095
        TableBuffer.Number := DATABASE::"Extra Charge Posting Setup";
        TableBuffer.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnShowExtensionPage', '', true, false)]
    local procedure CalcGLAccWhereUsed_OnShowExtensionPage(GLAccountWhereUsed: Record "G/L Account Where-Used")
    var
        ExtraChargePostingSetup: Record "Extra Charge Posting Setup";
    begin
        // P80066030
        case GLAccountWhereUsed."Table ID" of
            DATABASE::"Extra Charge Posting Setup":
                begin
                    ExtraChargePostingSetup.SetRange("Gen. Bus. Posting Group", CopyStr(GLAccountWhereUsed."Key 1", 1, MaxStrLen(ExtraChargePostingSetup."Gen. Bus. Posting Group")));
                    ExtraChargePostingSetup.SetRange("Gen. Prod. Posting Group", CopyStr(GLAccountWhereUsed."Key 2", 1, MaxStrLen(ExtraChargePostingSetup."Gen. Prod. Posting Group")));
                    ExtraChargePostingSetup."Extra Charge Code" := CopyStr(GLAccountWhereUsed."Key 3", 1, MaxStrLen(ExtraChargePostingSetup."Extra Charge Code"));
                    PAGE.Run(PAGE::"Extra Charge Posting Setup", ExtraChargePostingSetup);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnAfterTransferOrderPostReceipt', '', true, false)]
    local procedure TransferOrderPostReceipt_OnAfterTransferOrderPostReceipt(var TransferHeader: Record "Transfer Header")
    var
        ExtraCharge: Record "Extra Charge";
        ExtraChargeManagement: Codeunit "Extra Charge Management";
    begin
        // P80053245
        ExtraChargeManagement.UpdateTransferVendorBuffer(TransferHeader);
        ExtraChargeManagement.CreateVendorInvoices(ExtraCharge);
    end;
}

