codeunit 415 "Release Purchase Document"
{
    // P3.70.07
    // P8000126A, Myers Nissi, Jack Reynolds, 21 DEC 04
    //  Generate error if order is below minimum
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Clear "Alt. Qty. Update Required"
    // 
    // PR4.00.04
    // P8000398A, VerticalSoft, Jack Reynolds, 03 OCT 06
    //   Optionally exit if nothing to release rather than error
    // 
    // PRW16.00.05
    // P8000935, Columbus IT, Jack Reynolds, 22 APR 11
    //   Check Country of Origin at Release
    // 
    // PRW17.10
    // P8001213, Columbus IT, Jack Reynolds, 26 SEP 13
    //   NAV 2013 R2 changes
    // 
    // P8001230, Columbus IT, Jack Reynolds, 18 OCT 13
    //   Support for approved vendors
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW110.0.01
    // P80043109, To-Increase, Jack Reynolds, 03 JUL 17
    //   Update LnesWereModified when modifying ""Alt. Qty. Update Required"

    TableNo = "Purchase Header";
    Permissions = TableData "Purchase Header" = rm;

    trigger OnRun()
    begin
        PurchaseHeader.Copy(Rec);
        Code;
        Rec := PurchaseHeader;
    end;

    var
        Text001: Label 'There is nothing to release for the document of type %1 with the number %2.';
        PurchSetup: Record "Purchases & Payables Setup";
        InvtSetup: Record "Inventory Setup";
        PurchaseHeader: Record "Purchase Header";
        WhsePurchRelease: Codeunit "Whse.-Purch. Release";
        Text002: Label 'This document can only be released when the approval process is complete.';
        Text003: Label 'The approval process must be cancelled or completed to reopen this document.';
        Text005: Label 'There are unpaid prepayment invoices that are related to the document of type %1 with the number %2.';
        ExitIfNoLines: Boolean;
        ProcessFns: Codeunit "Process 800 Functions";
        P800Tracking: Codeunit "Process 800 Item Tracking";
        UnpostedPrepaymentAmountsErr: Label 'There are unposted prepayment amounts on the document of type %1 with the number %2.', Comment = '%1 - Document Type; %2 - Document No.';
        PreviewMode: Boolean;
        SkipCheckReleaseRestrictions: Boolean;

    local procedure "Code"() LinesWereModified: Boolean
    var
        PurchLine: Record "Purchase Line";
        PrepaymentMgt: Codeunit "Prepayment Mgt.";
        NotOnlyDropShipment: Boolean;
        PostingDate: Date;
        PrintPostedDocuments: Boolean;
        IsHandled: Boolean;
    begin
        with PurchaseHeader do begin
            if Status = Status::Released then
                exit;

            OnBeforeReleasePurchaseDoc(PurchaseHeader, PreviewMode);
            if not (PreviewMode or SkipCheckReleaseRestrictions) then
                CheckPurchaseReleaseRestrictions;

            TestField("Buy-from Vendor No.");

            CheckOrderMinimum('ERROR'); // P8000126A
            IsHandled := false;
            OnCodeOnAfterCheckPurchaseReleaseRestrictions(PurchaseHeader, IsHandled);
            if IsHandled then
                exit;

            PurchLine.SetRange("Document Type", "Document Type");
            PurchLine.SetRange("Document No.", "No.");
            PurchLine.SetFilter(Type, '>0');
            PurchLine.SetFilter(Quantity, '<>0');
            OnCodeOnAfterPurchLineSetFilters(PurchaseHeader, PurchLine);
            if not PurchLine.Find('-') then
                // P8000398A
                if ExitIfNoLines then begin
                    ExitIfNoLines := false;
                    exit;
                end else
                    // P8000398A
                    Error(Text001, "Document Type", "No.");
            InvtSetup.Get();
            PurchSetup.Get(); // P8000935
            if InvtSetup."Location Mandatory" or PurchSetup."Check COO at Order Release" or (not "Allow Unapproved Items") then begin // P8000935, P8001230
                PurchLine.SetRange(Type, PurchLine.Type::Item);
                if PurchLine.Find('-') then
                    repeat
                        if InvtSetup."Location Mandatory" and PurchLine.IsInventoriableItem then
                            //IF InvtSetup."Location Mandatory"  AND (NOT PurchLine.IsServiceItem) THEN // P8000935, P8001213
                            PurchLine.TestField("Location Code");
                        // P8000935
                        //IF PurchSetup."Check COO at Order Release" AND (NOT PurchLine.IsServiceItem) THEN // P8001213
                        if PurchSetup."Check COO at Order Release" and PurchLine.IsInventoriableItem then // P8001213
                            if ProcessFns.TrackingInstalled then
                                P800Tracking.CheckPurchLineCOO(PurchLine);
                        // P8000935
                        PurchLine.TestApprovedItem("Allow Unapproved Items"); // P8001230
                    until PurchLine.Next() = 0;
                PurchLine.SetFilter(Type, '>0');
            end;

            OnCodeOnAfterCheck(PurchaseHeader, PurchLine, LinesWereModified);

            PurchLine.SetRange("Drop Shipment", false);
            NotOnlyDropShipment := PurchLine.Find('-');

            OnCodeOnCheckTracking(PurchaseHeader, PurchLine);

            PurchLine.Reset();

            OnBeforeCalcInvDiscount(PurchaseHeader, PreviewMode);

            PurchSetup.Get();
            if PurchSetup."Calc. Inv. Discount" then begin
                PostingDate := "Posting Date";
                PrintPostedDocuments := "Print Posted Documents";
                CODEUNIT.Run(CODEUNIT::"Purch.-Calc.Discount", PurchLine);
                LinesWereModified := true;
                Get("Document Type", "No.");
                "Print Posted Documents" := PrintPostedDocuments;
                if PostingDate <> "Posting Date" then
                    Validate("Posting Date", PostingDate);
            end;

            IsHandled := false;
            OnBeforeModifyPurchDoc(PurchaseHeader, PreviewMode, IsHandled);
            if IsHandled then
                exit;

            if PrepaymentMgt.TestPurchasePrepayment(PurchaseHeader) and ("Document Type" = "Document Type"::Order) then begin
                Status := Status::"Pending Prepayment";
                Modify(true);
                OnAfterReleasePurchaseDoc(PurchaseHeader, PreviewMode, LinesWereModified);
                exit;
            end;
            Status := Status::Released;

            LinesWereModified := LinesWereModified or CalcAndUpdateVATOnLines(PurchaseHeader, PurchLine);

            OnCodeOnBeforeModifyHeader(PurchaseHeader, PurchLine, PreviewMode, LinesWereModified);

            Modify(true);

            if NotOnlyDropShipment then
                if "Document Type" in ["Document Type"::Order, "Document Type"::"Return Order"] then
                    WhsePurchRelease.Release(PurchaseHeader);

            // P8000282A
            PurchLine.Reset;
            PurchLine.SetRange("Document Type", "Document Type");
            PurchLine.SetRange("Document No.", "No.");
            PurchLine.SetRange("Alt. Qty. Update Required", true); // P80043109
            if not PurchLine.IsEmpty then begin                   // P80043109
                PurchLine.ModifyAll("Alt. Qty. Update Required", false, false);
                LinesWereModified := true;                          // P80043109
            end;                                                  // P80043109
                                                                  // P8000282A

            OnAfterReleasePurchaseDoc(PurchaseHeader, PreviewMode, LinesWereModified);
        end;
    end;

    procedure Reopen(var PurchHeader: Record "Purchase Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeReopenPurchaseDoc(PurchHeader, PreviewMode, IsHandled);
        if IsHandled then
            exit;

        with PurchHeader do begin
            if Status = Status::Open then
                exit;
            if "Document Type" in ["Document Type"::Order, "Document Type"::"Return Order"] then
                WhsePurchRelease.Reopen(PurchHeader);
            Status := Status::Open;

            Modify(true);
        end;

        OnAfterReopenPurchaseDoc(PurchHeader, PreviewMode);
    end;

    procedure PerformManualRelease(var PurchHeader: Record "Purchase Header")
    var
        PrepaymentMgt: Codeunit "Prepayment Mgt.";
    begin
        OnPerformManualReleaseOnBeforeTestPurchasePrepayment(PurchHeader, PreviewMode);
        if PrepaymentMgt.TestPurchasePrepayment(PurchHeader) then
            Error(UnpostedPrepaymentAmountsErr, PurchHeader."Document Type", PurchHeader."No.");

        OnBeforeManualReleasePurchaseDoc(PurchHeader, PreviewMode);
        PerformManualCheckAndRelease(PurchHeader);
        OnAfterManualReleasePurchaseDoc(PurchHeader, PreviewMode);
    end;

    procedure PerformManualCheckAndRelease(var PurchHeader: Record "Purchase Header")
    var
        PrepaymentMgt: Codeunit "Prepayment Mgt.";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePerformManualCheckAndRelease(PurchHeader, PreviewMode, IsHandled);
        if IsHandled then
            exit;

        with PurchHeader do
            if ("Document Type" = "Document Type"::Order) and PrepaymentMgt.TestPurchasePayment(PurchHeader) then begin
                if TestStatusIsNotPendingPrepayment then begin
                    Status := Status::"Pending Prepayment";
                    Modify;
                    Commit();
                end;
                Error(Text005, "Document Type", "No.");
            end;

        CheckPurchaseHeaderPendingApproval(PurchHeader);

        IsHandled := false;
        OnBeforePerformManualRelease(PurchHeader, PreviewMode, IsHandled);
        if IsHandled then
            exit;

        CODEUNIT.Run(CODEUNIT::"Release Purchase Document", PurchHeader);
    end;

    local procedure CheckPurchaseHeaderPendingApproval(var PurchHeader: Record "Purchase Header")
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckPurchaseHeaderPendingApproval(PurchHeader, IsHandled);
        if IsHandled then
            exit;

        if ApprovalsMgmt.IsPurchaseHeaderPendingApproval(PurchHeader) then
            Error(Text002);
    end;

    procedure PerformManualReopen(var PurchHeader: Record "Purchase Header")
    begin
        if PurchHeader.Status = PurchHeader.Status::"Pending Approval" then
            Error(Text003);

        OnBeforeManualReopenPurchaseDoc(PurchHeader, PreviewMode);
        Reopen(PurchHeader);
        OnAfterManualReopenPurchaseDoc(PurchHeader, PreviewMode);
    end;

    procedure ReleasePurchaseHeader(var PurchHdr: Record "Purchase Header"; Preview: Boolean) LinesWereModified: Boolean
    begin
        PreviewMode := Preview;
        PurchaseHeader.Copy(PurchHdr);
        LinesWereModified := Code;
        PurchHdr := PurchaseHeader;
    end;

    procedure CalcAndUpdateVATOnLines(var PurchaseHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line") LinesWereModified: Boolean
    var
        TempVATAmountLine0: Record "VAT Amount Line" temporary;
        TempVATAmountLine1: Record "VAT Amount Line" temporary;
    begin
        PurchLine.SetPurchHeader(PurchaseHeader);
        if PurchaseHeader."Tax Area Code" = '' then begin  // VAT
            PurchLine.CalcVATAmountLines(0, PurchaseHeader, PurchLine, TempVATAmountLine0);
            PurchLine.CalcVATAmountLines(1, PurchaseHeader, PurchLine, TempVATAmountLine1);
            LinesWereModified :=
              PurchLine.UpdateVATOnLines(0, PurchaseHeader, PurchLine, TempVATAmountLine0) or
              PurchLine.UpdateVATOnLines(1, PurchaseHeader, PurchLine, TempVATAmountLine1);
        end else begin
            PurchLine.CalcSalesTaxLines(PurchaseHeader, PurchLine);
            LinesWereModified := true;
        end;
    end;

    procedure SetSkipCheckReleaseRestrictions()
    begin
        SkipCheckReleaseRestrictions := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcInvDiscount(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckPurchaseHeaderPendingApproval(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeManualReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePerformManualCheckAndRelease(var PurchHeader: Record "Purchase Header"; PreviewMode: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; var LinesWereModified: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterManualReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeManualReopenPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReopenPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyPurchDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePerformManualRelease(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReopenPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    begin
    end;

    procedure ExitIfNothingToRelease()
    begin
        // P8000398A
        ExitIfNoLines := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterManualReopenPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterCheck(PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; var LinesWereModified: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterPurchLineSetFilters(PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeModifyHeader(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; PreviewMode: Boolean; var LinesWereModified: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnCheckTracking(PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPerformManualReleaseOnBeforeTestPurchasePrepayment(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterCheckPurchaseReleaseRestrictions(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;
}

