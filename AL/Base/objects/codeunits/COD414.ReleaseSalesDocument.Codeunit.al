codeunit 414 "Release Sales Document"
{
    // PR3.70.07
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
    // P8000921, Columbus IT, Don Bresee, 08 APR 11
    //   Add calculation of freight on release
    // 
    // P8000941, Columbus IT, Don Bresee, 25 JUL 11
    //   Sales Payments granule
    // 
    // PRW19.00.01
    // P8007168, To-Increase, Dayakar Battini, 08 JUN 16
    //  Trip Settlement Posting Issue
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    //   Fix problem with freight calculation
    // 
    // PRW110.0.01
    // P80043109, To-Increase, Jack Reynolds, 03 JUL 17
    //   Update LnesWereModified when modifying ""Alt. Qty. Update Required"
    // 
    // P80043567, To-Increase, Dayakar Battini, 13 JUL 17
    //   Fix for wrong item tracking updation from pick registrations.
    // 
    // PRW111.00.03
    // P80082431, To-increase, Gangabhushan, 23 SEP 19
    //   CS00075223 - Orders are removed from trips when using resolve shorts

    TableNo = "Sales Header";
    Permissions = TableData "Sales Header" = rm,
                  TableData "Sales Line" = r;

    trigger OnRun()
    begin
        OnBeforeOnRun(Rec);
        SalesHeader.Copy(Rec);
        SalesHeader.SetHideValidationDialog(Rec.GetHideValidationDialog());
        Code();
        Rec := SalesHeader;
    end;

    var
        Text001: Label 'There is nothing to release for the document of type %1 with the number %2.';
        SalesSetup: Record "Sales & Receivables Setup";
        InvtSetup: Record "Inventory Setup";
        SalesHeader: Record "Sales Header";
        WhseSalesRelease: Codeunit "Whse.-Sales Release";
        Text002: Label 'This document can only be released when the approval process is complete.';
        Text003: Label 'The approval process must be cancelled or completed to reopen this document.';
        Text005: Label 'There are unpaid prepayment invoices that are related to the document of type %1 with the number %2.';
        ExitIfNoLines: Boolean;
        SkipPaymentLineUpdate: Boolean;
        FromDeliveryTripNo: Code[20];
        UnpostedPrepaymentAmountsErr: Label 'There are unposted prepayment amounts on the document of type %1 with the number %2.', Comment = '%1 - Document Type; %2 - Document No.';
        PreviewMode: Boolean;
        NewSkipCalcFreight: Boolean;
        SkipCheckReleaseRestrictions: Boolean;

    local procedure "Code"() LinesWereModified: Boolean
    var
        SalesLine: Record "Sales Line";
        PrepaymentMgt: Codeunit "Prepayment Mgt.";
        NotOnlyDropShipment: Boolean;
        PostingDate: Date;
        PrintPostedDocuments: Boolean;
        ShouldSetStatusPrepayment: Boolean;
        IsHandled: Boolean;
    begin
        with SalesHeader do begin
            if Status = Status::Released then
                exit;

            IsHandled := false;
            OnBeforeReleaseSalesDoc(SalesHeader, PreviewMode, IsHandled, SkipCheckReleaseRestrictions);
            if IsHandled then
                exit;
            if not (PreviewMode or SkipCheckReleaseRestrictions) then
                CheckSalesReleaseRestrictions();

            IsHandled := false;
            OnBeforeCheckCustomerCreated(SalesHeader, IsHandled);
            if not IsHandled then
                if "Document Type" = "Document Type"::Quote then
                    if CheckCustomerCreated(true) then
                        Get("Document Type"::Quote, "No.")
                    else
                        exit;

            TestSellToCustomerNo(SalesHeader);

            CheckOrderMinimum('ERROR'); // P8000126A
            IsHandled := false;
            OnCodeOnAfterCheckCustomerCreated(SalesHeader, PreviewMode, IsHandled, LinesWereModified);
            if IsHandled then
                exit;

            CheckSalesLines(SalesLine, LinesWereModified);

            OnCodeOnAfterCheck(SalesHeader, SalesLine, LinesWereModified);

            SalesLine.SetRange("Drop Shipment", false);
            NotOnlyDropShipment := SalesLine.FindFirst();

            OnCodeOnCheckTracking(SalesHeader, SalesLine);

            SalesLine.Reset();

            OnBeforeCalcInvDiscount(SalesHeader, PreviewMode, LinesWereModified, SalesLine);

            SalesSetup.Get();
            // P8000921
            if SalesSetup."Calc. Freight on Release/Post" and (not NewSkipCalcFreight) then begin  // P80043567
                CalcFreight(SalesHeader); // P8007748
                Modify(true);
            end;
            // P8000921
            if SalesSetup."Calc. Inv. Discount" then begin
                PostingDate := "Posting Date";
                PrintPostedDocuments := "Print Posted Documents";
                CODEUNIT.Run(CODEUNIT::"Sales-Calc. Discount", SalesLine);
                LinesWereModified := true;
                Get("Document Type", "No.");
                "Print Posted Documents" := PrintPostedDocuments;
                if PostingDate <> "Posting Date" then
                    Validate("Posting Date", PostingDate);
            end;

            IsHandled := false;
            OnBeforeModifySalesDoc(SalesHeader, PreviewMode, IsHandled);
            if IsHandled then
                exit;

            ShouldSetStatusPrepayment := PrepaymentMgt.TestSalesPrepayment(SalesHeader) and ("Document Type" = "Document Type"::Order);
            OnCodeOnAfterCalcShouldSetStatusPrepayment(SalesHeader, PreviewMode, ShouldSetStatusPrepayment);
            if ShouldSetStatusPrepayment then begin
                Status := Status::"Pending Prepayment";
                Modify(true);
                OnAfterReleaseSalesDoc(SalesHeader, PreviewMode, LinesWereModified);
                exit;
            end;

            OnCodeOnBeforeSetStatusReleased(SalesHeader);
            Status := Status::Released;

            LinesWereModified := LinesWereModified or CalcAndUpdateVATOnLines(SalesHeader, SalesLine);

            OnAfterUpdateSalesDocLines(SalesHeader, LinesWereModified, PreviewMode);

            ReleaseATOs(SalesHeader);
            OnAfterReleaseATOs(SalesHeader, SalesLine, PreviewMode);

            Modify(true);
            OnCodeOnAfterModifySalesDoc(SalesHeader, LinesWereModified);

            WhseSalesRelease.SetSettlementPosting(FromDeliveryTripNo);    // P8007168

            if NotOnlyDropShipment then
                if "Document Type" in ["Document Type"::Order, "Document Type"::"Return Order"] then
                    WhseSalesRelease.Release(SalesHeader);

            // P8000282A
            SalesLine.Reset;
            SalesLine.SetRange("Document Type", "Document Type");
            SalesLine.SetRange("Document No.", "No.");
            SalesLine.SetRange("Alt. Qty. Update Required", true); // P80043109
            if not SalesLine.IsEmpty then begin                   // P80043109
                SalesLine.ModifyAll("Alt. Qty. Update Required", false, false);
                LinesWereModified := true;                          // P80043109
            end;                                                  // P80043109
                                                                  // P8000282A

            UpdatePaymentLine(SalesHeader); // P8000941

            OnAfterReleaseSalesDoc(SalesHeader, PreviewMode, LinesWereModified);
        end;
    end;

    local procedure CheckSalesLines(var SalesLine: Record "Sales Line"; var LinesWereModified: Boolean)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckSalesLines(SalesHeader, SalesLine, IsHandled);
        if IsHandled then
            exit;

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Type, '>0');
        SalesLine.SetFilter(Quantity, '<>0');
        IsHandled := false;
        OnBeforeSalesLineFind(SalesLine, SalesHeader, LinesWereModified, IsHandled);
        if not IsHandled then
            if not SalesLine.Find('-') then
                // P8000398A
                if ExitIfNoLines then begin
                    ExitIfNoLines := false;
                    exit;
                end else
                // P8000398A
                    Error(Text001, SalesHeader."Document Type", SalesHeader."No.");

        CheckMandatoryFields(SalesLine);
    end;

    local procedure CheckMandatoryFields(var SalesLine: Record "Sales Line")
    var
        Item: Record "Item";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckMandatoryFields(SalesHeader, IsHandled);
        if IsHandled then
            exit;

        InvtSetup.Get();
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                if InvtSetup."Location Mandatory" then
                    if SalesLine.IsInventoriableItem() then begin
                        IsHandled := false;
                        OnCodeOnBeforeSalesLineCheck(SalesLine, IsHandled);
                        if not IsHandled then
                            SalesLine.TestField("Location Code");
                    end;
                if Item.Get(SalesLine."No.") then
                    if Item.IsVariantMandatory() then
                        SalesLine.TestField("Variant Code");
                OnCodeOnAfterSalesLineCheck(SalesLine);
            until SalesLine.Next() = 0;
        SalesLine.SetFilter(Type, '>0');
    end;

    local procedure TestSellToCustomerNo(var SalesHeader: Record "Sales Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestSellToCustomerNo(SalesHeader, IsHandled);
        if IsHandled then
            exit;

        SalesHeader.TestField("Sell-to Customer No.");
    end;

    procedure Reopen(var SalesHeader: Record "Sales Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeReopenSalesDoc(SalesHeader, PreviewMode, IsHandled);
        if IsHandled then
            exit;

        with SalesHeader do begin
            if Status = Status::Open then
                exit;
            Status := Status::Open;

            if "Document Type" <> "Document Type"::Order then
                ReopenATOs(SalesHeader);

            OnReopenOnBeforeSalesHeaderModify(SalesHeader);
            Modify(true);
            if "Document Type" in ["Document Type"::Order, "Document Type"::"Return Order"] then
                WhseSalesRelease.Reopen(SalesHeader);
        end;

        UpdatePaymentLine(SalesHeader); // P8000941

        OnAfterReopenSalesDoc(SalesHeader, PreviewMode);
    end;

    procedure PerformManualRelease(var SalesHeader: Record "Sales Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePerformManualReleaseProcedure(SalesHeader, PreviewMode, IsHandled);
        if IsHandled then
            exit;

        CheckPrepaymentsForManualRelease(SalesHeader);

        OnBeforeManualReleaseSalesDoc(SalesHeader, PreviewMode);
        PerformManualCheckAndRelease(SalesHeader);
        OnAfterManualReleaseSalesDoc(SalesHeader, PreviewMode);
    end;

    local procedure CheckPrepaymentsForManualRelease(var SalesHeader: Record "Sales Header")
    var
        PrepaymentMgt: Codeunit "Prepayment Mgt.";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnPerformManualReleaseOnBeforeTestSalesPrepayment(SalesHeader, PreviewMode, IsHandled);
        if IsHandled then
            exit;

        if PrepaymentMgt.TestSalesPrepayment(SalesHeader) then
            Error(UnpostedPrepaymentAmountsErr, SalesHeader."Document Type", SalesHeader."No.");
    end;

    procedure PerformManualCheckAndRelease(var SalesHeader: Record "Sales Header")
    var
        PrepaymentMgt: Codeunit "Prepayment Mgt.";
        IsHandled: Boolean;
        ReleaseSalesDocument: Codeunit "Release Sales Document";
    begin
        IsHandled := false;
        OnBeforePerformManualCheckAndRelease(SalesHeader, PreviewMode, IsHandled);
        if IsHandled then
            exit;

        with SalesHeader do
            if ("Document Type" = "Document Type"::Order) and PrepaymentMgt.TestSalesPayment(SalesHeader) then begin
                if TestStatusIsNotPendingPrepayment() then begin
                    Status := Status::"Pending Prepayment";
                    OnPerformManualCheckAndReleaseOnBeforeSalesHeaderModify(SalesHeader, PreviewMode);
                    Modify();
                    Commit();
                end;
                Error(Text005, "Document Type", "No.");
            end;

        CheckSalesHeaderPendingApproval(SalesHeader);

        IsHandled := false;
        OnBeforePerformManualRelease(SalesHeader, PreviewMode, IsHandled);
        if IsHandled then
            exit;

        // P80082431
        ReleaseSalesDocument.SetDeliveryTrip(FromDeliveryTripNo);
        ReleaseSalesDocument.Run(SalesHeader);
        // P80082431

        OnAfterPerformManualCheckAndRelease(SalesHeader, PreviewMode);
    end;

    local procedure CheckSalesHeaderPendingApproval(var SalesHeader: Record "Sales Header")
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckSalesHeaderPendingApproval(SalesHeader, IsHandled);
        if IsHandled then
            exit;

        if ApprovalsMgmt.IsSalesHeaderPendingApproval(SalesHeader) then
            Error(Text002);
    end;

    procedure PerformManualReopen(var SalesHeader: Record "Sales Header")
    var
        SalesPaymentLine: Record "Sales Payment Line";
    begin
        if SalesHeader.OnSalesPayment(SalesPaymentLine) then      // P8000941
            SalesPaymentLine.TestField("Allow Order Changes", true); // P8000941
        CheckReopenStatus(SalesHeader);

        OnBeforeManualReOpenSalesDoc(SalesHeader, PreviewMode);
        Reopen(SalesHeader);
        OnAfterManualReOpenSalesDoc(SalesHeader, PreviewMode);
    end;

    local procedure CheckReopenStatus(SalesHeader: Record "Sales Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckReopenStatus(SalesHeader, IsHandled);
        if IsHandled then
            exit;

        if SalesHeader.Status = SalesHeader.Status::"Pending Approval" then
            Error(Text003);
    end;

    local procedure ReleaseATOs(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        AsmHeader: Record "Assembly Header";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                if SalesLine.AsmToOrderExists(AsmHeader) then
                    CODEUNIT.Run(CODEUNIT::"Release Assembly Document", AsmHeader);
            until SalesLine.Next() = 0;
    end;

    local procedure ReopenATOs(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        AsmHeader: Record "Assembly Header";
        ReleaseAssemblyDocument: Codeunit "Release Assembly Document";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                if SalesLine.AsmToOrderExists(AsmHeader) then
                    ReleaseAssemblyDocument.Reopen(AsmHeader);
            until SalesLine.Next() = 0;
    end;

    procedure ExitIfNothingToRelease()
    begin
        // P8000398A
        ExitIfNoLines := true;
    end;

    procedure SetSkipPaymentLineUpdate(NewSkipPaymentLineUpdate: Boolean)
    begin
        SkipPaymentLineUpdate := NewSkipPaymentLineUpdate; // P8000941
    end;

    local procedure UpdatePaymentLine(var SalesHeader: Record "Sales Header")
    var
        SalesPaymentLine: Record "Sales Payment Line";
    begin
        // P8000941
        if not SkipPaymentLineUpdate then
            if SalesHeader.OnSalesPayment(SalesPaymentLine) then
                if SalesPaymentLine.UpdateStatus() then
                    SalesPaymentLine.Modify(true);
    end;

    procedure ReleaseSalesHeader(var SalesHdr: Record "Sales Header"; Preview: Boolean) LinesWereModified: Boolean
    begin
        PreviewMode := Preview;
        SalesHeader.Copy(SalesHdr);
        LinesWereModified := Code();
        SalesHdr := SalesHeader;
    end;

    procedure SetSkipCheckReleaseRestrictions()
    begin
        SkipCheckReleaseRestrictions := true;
    end;

    procedure CalcAndUpdateVATOnLines(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line") LinesWereModified: Boolean
    var
        TempVATAmountLine0: Record "VAT Amount Line" temporary;
        TempVATAmountLine1: Record "VAT Amount Line" temporary;
    begin
        SalesLine.SetSalesHeader(SalesHeader);
        if SalesHeader."Tax Area Code" = '' then begin  // VAT
            SalesLine.CalcVATAmountLines(0, SalesHeader, SalesLine, TempVATAmountLine0);
            SalesLine.CalcVATAmountLines(1, SalesHeader, SalesLine, TempVATAmountLine1);
            LinesWereModified :=
              SalesLine.UpdateVATOnLines(0, SalesHeader, SalesLine, TempVATAmountLine0) or
              SalesLine.UpdateVATOnLines(1, SalesHeader, SalesLine, TempVATAmountLine1);
        end else begin
            SalesLine.CalcSalesTaxLines(SalesHeader, SalesLine);
            LinesWereModified := true;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcInvDiscount(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var LinesWereModified: Boolean; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeManualReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestSellToCustomerNo(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnRun(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean; SkipCheckReleaseRestrictions: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var LinesWereModified: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterManualReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckSalesHeaderPendingApproval(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckSalesLines(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeManualReOpenSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReopenSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifySalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePerformManualRelease(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePerformManualReleaseProcedure(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSalesLineFind(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var LinesWereModified: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReopenSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterManualReOpenSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPerformManualCheckAndRelease(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReleaseATOs(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; PreviewMode: Boolean)
    begin
    end;

    procedure SetDeliveryTrip(DeliveryTripNo: Code[20])
    begin
        // P8007168, P80082431
        FromDeliveryTripNo := DeliveryTripNo;
    end;

    local procedure CalcFreight(var SalesHeader: Record "Sales Header")
    var
        DelPricingCalcHeader: Codeunit "Del. Pricing - Calc. Header";
    begin
        // P8007748
        BindSubscription(DelPricingCalcHeader);
        SalesHeader.CalculateFreight(false);
    end;

    procedure SetSkipCalcFreight(SkipCalcFreight: Boolean)
    begin
        // P80043567
        NewSkipCalcFreight := SkipCalcFreight;
        // P80043567
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateSalesDocLines(var SalesHeader: Record "Sales Header"; var LinesWereModified: Boolean; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterCheck(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var LinesWereModified: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterSalesLineCheck(var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeSalesLineCheck(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterCalcShouldSetStatusPrepayment(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var ShouldSetStatusPrepayment: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnCheckTracking(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckCustomerCreated(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckReopenStatus(SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePerformManualCheckAndRelease(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReopenOnBeforeSalesHeaderModify(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPerformManualReleaseOnBeforeTestSalesPrepayment(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPerformManualCheckAndReleaseOnBeforeSalesHeaderModify(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterCheckCustomerCreated(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean; var LinesWereModified: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterModifySalesDoc(var SalesHeader: Record "Sales Header"; var LinesWereModified: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckMandatoryFields(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeSetStatusReleased(var SalesHeader: Record "Sales Header")
    begin
    end;
}

