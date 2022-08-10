codeunit 37002663 "Sales Payment-Post"
{
    // PRW16.00.05
    // P8000941, Columbus IT, Don Bresee, 25 JUL 11
    //   Sales Payments granule
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 9 NOV 15
    //   Update .NET references
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00.02
    // P80066178, To-Increase, Jack Reynolds, 12 OCT 18
    //   Fix problem posting payment application
    //
    // PRW111.00.03
    // P800129560, To-Increase,Gangabhushan, 20 SEP 21
    //   CS00182200 | CS00173884 - sales payment page never end when posting some receipts    
    //
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Permissions = TableData "Sales Payment Tender Entry" = rimd,
                  TableData "Posted Sales Payment Header" = rimd,
                  TableData "Posted Sales Payment Line" = rimd;
    TableNo = "Sales Payment Header";

    trigger OnRun()
    begin
        InitCodeUnit(Rec);
        TestPayment;
        TestAmounts;
        AssignPostingNo;
        PostPaymentInvoice;
        PostTenderEntries;
        PostPaymentAppls;
        CreatePostedPayment;
    end;

    var
        SalesPayment: Record "Sales Payment Header";
        SalesInvoice: Record "Sales Header";
        SalesSetup: Record "Sales & Receivables Setup";
        SourceCodeSetup: Record "Source Code Setup";
        LastTenderEntryNo: Integer;
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        CustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        UpdateAnalysisView: Codeunit "Update Analysis View";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;
        StatusWindow: Dialog;
        HideGUI: Boolean;
        Text000: Label 'The Amount has changed on %1 %2.';
        Text001: Label 'The Amount has changed on multiple lines.';
        Text002: Label 'Posting Payment %1...';
        Text003: Label '#1############################\\';
        Text004: Label 'Combining Orders/Fees      #2######';
        Text005: Label 'Posting Payments      #2######';
        Text006: Label 'Posting Applications      #2######';
        Text007: Label 'Sales Payment %1';
        Text008: Label 'Unable to post all payments.';
        Text009: Label 'Unable to authorize credit card.';
        Text010: Label 'Test mode is enabled for the MS Dynamics Online Payment Service.  No payment transaction has been performed.';
        AppliesToIDError: Label '%1 should be blank for %2 %3.';

    local procedure InitCodeUnit(var PaymentToPost: Record "Sales Payment Header")
    begin
        SalesPayment.Copy(PaymentToPost);
        SalesSetup.Get;
        SourceCodeSetup.Get;
    end;

    local procedure TestPayment()
    var
        SalesPaymentLine: Record "Sales Payment Line";
        SalesOrder: Record "Sales Header";
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        with SalesPaymentLine do begin
            SetRange("Document No.", SalesPayment."No.");
            if FindSet then
                repeat
                    TestField("Allow Order Changes", false);
                    case Type of
                        Type::Order:
                            begin
                                TestField("No.");
                                SalesOrder.Get(SalesOrder."Document Type"::Order, "No.");
                                SalesOrder.TestField(Status, SalesOrder.Status::Released);
                                TestField("Order Shipment Status", "Order Shipment Status"::Complete);
                            end;
                        Type::"Open Entry":
                            begin
                                TestField("No.");
                                TestField("Entry No.");
                                CustLedgEntry.Get("Entry No.");
                                CustLedgEntry.TestField(Open, true);
                            end;
                    end;
                until (Next = 0);
        end;
    end;

    local procedure TestAmounts()
    var
        SalesPaymentLine: Record "Sales Payment Line";
        SalesOrder: Record "Sales Header";
        CustLedgEntry: Record "Cust. Ledger Entry";
        NumAmountChanges: Integer;
        FirstLineChanged: Record "Sales Payment Line";
    begin
        with SalesPaymentLine do begin
            SetRange("Document No.", SalesPayment."No.");
            if FindSet then
                repeat
                    case Type of
                        Type::Order:
                            begin
                                SalesOrder.Get(SalesOrder."Document Type"::Order, "No.");
                                SalesOrder.CalcFields("Amount Including VAT");
                                if (Amount <> SalesOrder."Amount Including VAT") then
                                    FixLineAmount(
                                      SalesPaymentLine, SalesOrder."Amount Including VAT", NumAmountChanges, FirstLineChanged);
                            end;
                        Type::"Open Entry":
                            begin
                                CustLedgEntry.Get("Entry No.");
                                CustLedgEntry.CalcFields("Remaining Amount");
                                if (Amount <> CustLedgEntry."Remaining Amount") then
                                    FixLineAmount(
                                      SalesPaymentLine, CustLedgEntry."Remaining Amount", NumAmountChanges, FirstLineChanged);
                            end;
                    end;
                until (Next = 0);
            if (NumAmountChanges > 0) then begin
                Commit;
                if (NumAmountChanges = 1) then
                    Error(Text000, FirstLineChanged.Type, FirstLineChanged."No.");
                Error(Text001);
            end;
            SalesPayment.CheckBalance;
        end;
    end;

    local procedure FixLineAmount(var SalesPaymentLine: Record "Sales Payment Line"; NewAmount: Decimal; var NumAmountChanges: Integer; var FirstLineChanged: Record "Sales Payment Line")
    begin
        with SalesPaymentLine do begin
            Amount := NewAmount;
            UpdateStatus;
            Modify(true);
        end;
        if (NumAmountChanges = 0) then
            FirstLineChanged := SalesPaymentLine;
        NumAmountChanges := NumAmountChanges + 1;
    end;

    local procedure AssignPostingNo()
    begin
        with SalesPayment do
            if ("Posting No." = '') then begin
                "Posting No. Series" := SalesSetup."Posted Sales Payment Nos.";
                if ("Posting No. Series" in ['', "No. Series"]) then
                    "Posting No." := "No."
                else
                    "Posting No." := NoSeriesMgt.GetNextNo("Posting No. Series", "Posting Date", true);
                Modify;
                Commit;
            end;
    end;

    local procedure PostPaymentInvoice()
    var
        SalesPost: Codeunit "Sales-Post";
        LastEntryBeforePost: Integer;
    begin
        with SalesPayment do begin
            if not IsInvoicePosted() then begin
                CreatePaymentInvoice;
                if (SalesInvoice."No." <> '') then begin
                    LastEntryBeforePost := GetLastCustEntryNo();
                    if not SalesPost.Run(SalesInvoice) then begin
                        SalesInvoice.Find;
                        DeletePaymentInvoice;
                        Commit;
                        Error(GetLastErrorText());
                    end;
                    "Min. Posting Entry No." := LastEntryBeforePost + 1;
                    "Max. Posting Entry No." := GetLastCustEntryNo();
                    Modify;
                    Commit;
                end;
            end;
        end;
    end;

    local procedure GetLastCustEntryNo(): Integer
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        if CustLedgEntry.FindLast then
            exit(CustLedgEntry."Entry No.");
    end;

    local procedure CreatePaymentInvoice()
    var
        SalesPaymentLine: Record "Sales Payment Line";
        LineCount: Integer;
    begin
        if SalesInvoice.Get(SalesInvoice."Document Type"::Invoice, SalesPayment."No.") then
            DeletePaymentInvoice;
        Clear(SalesInvoice);
        with SalesPaymentLine do begin
            SetRange("Document No.", SalesPayment."No.");
            if FindSet then begin
                if ShowStatusWindow() then begin
                    StatusWindow.Open(Text003 + Text004);
                    StatusWindow.Update(1, StrSubstNo(Text002, SalesPayment."No."));
                end;
                repeat
                    LineCount := LineCount + 1;
                    if ShowStatusWindow() then
                        StatusWindow.Update(2, LineCount);
                    case Type of
                        Type::Order:
                            AddOrderToInvoice(SalesPaymentLine); // P8001133
                    end;
                until (Next = 0);
                if ShowStatusWindow() then
                    StatusWindow.Close;
                Commit;
            end;
        end;
    end;

    local procedure AddOrderToInvoice(var SalesPaymentLine: Record "Sales Payment Line")
    var
        SalesShptHeader: Record "Sales Shipment Header";
        SalesShptLine: Record "Sales Shipment Line";
    begin
        // P8001133 - remove parameter for TempToLineDim
        SalesShptHeader.SetCurrentKey("Order No.");
        SalesShptHeader.SetRange("Order No.", SalesPaymentLine."No.");
        if SalesShptHeader.FindSet then
            repeat
                SalesShptLine.SetRange("Document No.", SalesShptHeader."No.");
                if SalesShptLine.FindSet then
                    repeat
                        CreateInvoiceHeader;
                        CreateInvoiceLine(SalesShptLine); // P8001133
                    until (SalesShptLine.Next = 0);
            until (SalesShptHeader.Next = 0);
    end;

    local procedure CreateInvoiceHeader()
    var
        SalesInvoiceLine: Record "Sales Line";
    begin
        with SalesInvoice do
            if ("No." = '') then begin
                SalesInvoiceLine.LockTable;
                "Document Type" := "Document Type"::Invoice;
                "No." := SalesPayment."No.";
                Insert(true);
                Validate("Sell-to Customer No.", SalesPayment."Customer No.");
                if ("Bill-to Customer No." <> "Sell-to Customer No.") then
                    Validate("Bill-to Customer No.", SalesPayment."Customer No.");
                Validate("Payment Method Code", '');
                Validate("Posting Date", SalesPayment."Posting Date");
                Validate("Document Date", SalesPayment."Posting Date");
                "Posting No." := SalesPayment."Posting No.";
                "Posting No. Series" := '';
                if SetApplsForInvoice() then
                    "Applies-to ID" := "No.";
                Modify;
            end;
    end;

    local procedure CreateInvoiceLine(SalesShptLine: Record "Sales Shipment Line")
    var
        SalesInvoiceLine: Record "Sales Line";
    begin
        // P8001133 - remove parameter for TempToLineDim
        if (SalesShptLine.Quantity <> 0) or (SalesShptLine.Type <> SalesShptLine.Type::Item) then begin
            SalesInvoiceLine.SetRange("Document Type", SalesInvoice."Document Type");
            SalesInvoiceLine.SetRange("Document No.", SalesInvoice."No.");
            SalesInvoiceLine."Document Type" := SalesInvoice."Document Type";
            SalesInvoiceLine."Document No." := SalesInvoice."No.";
            SalesShptLine.InsertInvLineFromShptLine(SalesInvoiceLine); // P8001133
        end;
    end;

    local procedure DeletePaymentInvoice()
    var
        ReserveSalesLine: Codeunit "Sales Line-Reserve";
        SalesInvoiceLine: Record "Sales Line";
    begin
        ReleaseSalesDoc.Reopen(SalesInvoice);
        SalesInvoiceLine.SetRange("Document Type", SalesInvoice."Document Type"::Invoice);
        SalesInvoiceLine.SetRange("Document No.", SalesInvoice."No.");
        if SalesInvoiceLine.FindSet then
            repeat
                ReserveSalesLine.SetDeleteItemTracking(true); // P80066030
                ReserveSalesLine.DeleteLine(SalesInvoiceLine);
                SalesInvoiceLine.Delete(true);
            until (SalesInvoiceLine.Next = 0);
        SalesInvoice.Find;
        SalesInvoice."Posting No." := '';
        SalesInvoice.Delete(true);
    end;

    local procedure SetApplsForInvoice() ApplyToEntriesFound: Boolean
    var
        SalesTenderEntry: Record "Sales Payment Tender Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        with SalesTenderEntry do begin
            SetCurrentKey("Document No.", "Payment Method Code", "Card/Check No.");
            SetRange("Document No.", SalesPayment."No.");
            SetFilter("Cust. Ledger Entry No.", '<>0');
            if FindSet then
                repeat
                    CustLedgEntry.Get("Cust. Ledger Entry No.");
                    if SetEntryApplID(CustLedgEntry, false) then
                        ApplyToEntriesFound := true;
                until (Next = 0);
        end;
    end;

    local procedure PostTenderEntries()
    var
        SalesTenderEntry: Record "Sales Payment Tender Entry";
        PaymentMethod: Record "Payment Method";
        LineCount: Integer;
        PaymentsFailed: Boolean;
    begin
        with SalesTenderEntry do begin
            SetCurrentKey("Document No.");
            SetRange("Document No.", SalesPayment."No.");
            SetRange("Cust. Ledger Entry No.", 0);
            SetRange("Voided by Entry No.", 0);
            SetFilter(Type, '<>%1', Type::Void);
            if FindSet then begin
                if ShowStatusWindow() then begin
                    StatusWindow.Open(Text003 + Text005);
                    StatusWindow.Update(1, StrSubstNo(Text002, SalesPayment."No."));
                end;
                repeat
                    LineCount := LineCount + 1;
                    if ShowStatusWindow() then
                        StatusWindow.Update(2, LineCount);
                    PaymentMethod.Get("Payment Method Code");
                    Clear(GenJnlPostLine);
                    PostFromTenderEntry(PaymentMethod, SalesTenderEntry);
                    Commit;
                    if (Result <> Result::Posted) then
                        PaymentsFailed := true;
                until (Next = 0);
                if SalesPayment.UpdateStatus() then
                    SalesPayment.Modify(true);
                Commit;
                if ShowStatusWindow() then
                    StatusWindow.Close;
                if PaymentsFailed then
                    Error(Text008);
            end;
        end;
    end;

    local procedure PostFromTenderEntry(var PaymentMethod: Record "Payment Method"; var SalesTenderEntry: Record "Sales Payment Tender Entry")
    var
        GenJnlLine: Record "Gen. Journal Line";
        CaptureFailed: Boolean;
        ApplyToEntriesFound: Boolean;
    begin
        with GenJnlLine do begin
            Validate("Posting Date", SalesPayment."Posting Date");
            if (SalesTenderEntry.Type = SalesTenderEntry.Type::Payment) then
                Validate("Document Type", "Document Type"::Payment)
            else
                Validate("Document Type", "Document Type"::" ");
            Validate("Document No.", SalesPayment."Posting No.");
            Validate("Account Type", "Account Type"::Customer);
            Validate("Account No.", SalesPayment."Customer No.");
            Validate(Description, StrSubstNo(Text007, SalesPayment."No."));
            Validate(Amount, -SalesTenderEntry.Amount);
            case PaymentMethod."Bal. Account Type" of
                PaymentMethod."Bal. Account Type"::"G/L Account":
                    Validate("Bal. Account Type", "Bal. Account Type"::"G/L Account");
                PaymentMethod."Bal. Account Type"::"Bank Account":
                    Validate("Bal. Account Type", "Bal. Account Type"::"Bank Account");
            end;
            Validate("Bal. Account No.", PaymentMethod."Bal. Account No.");
            if (SalesTenderEntry.Type = SalesTenderEntry.Type::Payment) then
                ApplyToEntriesFound := SetInvoiceAppls()
            else
                ApplyToEntriesFound := SetTenderAppls(SalesTenderEntry);
            if ApplyToEntriesFound then
                "Applies-to ID" := SalesPayment."No.";
            "Source Code" := SourceCodeSetup.Sales;

            GenJnlPostLine.RunWithCheck(GenJnlLine); // P8001133

            FinishPaymentPosting(SalesTenderEntry);
        end;
    end;

    local procedure FinishPaymentPosting(var SalesTenderEntry: Record "Sales Payment Tender Entry")
    begin
        with SalesTenderEntry do begin
            "Cust. Ledger Entry No." := GetLastCustEntryNo();
            Result := Result::Posted;
            Modify;
        end;
    end;

    local procedure SetInvoiceAppls() ApplyToEntriesFound: Boolean
    var
        SalesTenderEntry: Record "Sales Payment Tender Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        if SalesPayment.InvoiceEntriesExist(CustLedgEntry) then
            repeat
                if SetEntryApplID(CustLedgEntry, true) then
                    ApplyToEntriesFound := true;
            until (CustLedgEntry.Next = 0);
        with SalesTenderEntry do begin
            SetCurrentKey("Document No.", "Payment Method Code", "Card/Check No.");
            SetRange("Document No.", SalesPayment."No.");
            SetFilter("Cust. Ledger Entry No.", '<>0');
            if FindSet then
                repeat
                    CustLedgEntry.Get("Cust. Ledger Entry No.");
                    if SetEntryApplID(CustLedgEntry, true) then
                        ApplyToEntriesFound := true;
                until (Next = 0);
        end;
    end;

    local procedure SetTenderAppls(var ApplyingTenderEntry: Record "Sales Payment Tender Entry") ApplyToEntriesFound: Boolean
    var
        ApplyingPayment: Boolean;
        SalesTenderEntry: Record "Sales Payment Tender Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        ApplyingPayment := (ApplyingTenderEntry.Type = ApplyingTenderEntry.Type::Payment);
        with SalesTenderEntry do begin
            SetCurrentKey("Document No.", "Payment Method Code", "Card/Check No.");
            SetRange("Document No.", ApplyingTenderEntry."Document No.");
            SetRange("Payment Method Code", ApplyingTenderEntry."Payment Method Code");
            SetRange("Card/Check No.", ApplyingTenderEntry."Card/Check No.");
            SetFilter("Cust. Ledger Entry No.", '<>0');
            if FindSet then
                repeat
                    CustLedgEntry.Get("Cust. Ledger Entry No.");
                    if SetEntryApplID(CustLedgEntry, ApplyingPayment) then
                        ApplyToEntriesFound := true;
                until (Next = 0);
        end;
    end;

    local procedure SetEntryApplID(var CustLedgEntry: Record "Cust. Ledger Entry"; ApplyingPayment: Boolean): Boolean
    var
        ApplyingLedgEntry: Record "Cust. Ledger Entry";
    begin
        with CustLedgEntry do
            if Open and (Positive = ApplyingPayment) then begin
                SetApplID(CustLedgEntry, ApplyingLedgEntry);
                exit(true);
            end;
    end;

    local procedure SetApplID(var CustLedgEntry: Record "Cust. Ledger Entry"; var ApplyingLedgEntry: Record "Cust. Ledger Entry")
    begin
        with CustLedgEntry do begin
            SetRecFilter;
            CalcFields("Remaining Amount");
            if CustLedgEntry."Applies-to ID" = '' then  // P800129560
                CustEntrySetApplID.SetApplId(CustLedgEntry, ApplyingLedgEntry, SalesPayment."No."); // P8001132
        end;
    end;

    local procedure PostPaymentAppls()
    var
        TempApplyingEntry: Record "Integer" temporary;
        TempApplyToEntry: Record "Integer" temporary;
        ApplyingLedgEntry: Record "Cust. Ledger Entry";
        ApplyToLedgEntry: Record "Cust. Ledger Entry";
        ApplDate: Date;
        MoreAppls: Boolean;
        CustLedgEntry: Record "Cust. Ledger Entry";
        ApplCount: Integer;
    begin
        InitTempApplEntries(TempApplyingEntry, TempApplyToEntry);
        if GetTempApplEntry(TempApplyingEntry, ApplyingLedgEntry) and
           GetTempApplEntry(TempApplyToEntry, ApplyToLedgEntry)
        then begin
            Clear(GenJnlPostLine);
            if ShowStatusWindow() then begin
                StatusWindow.Open(Text003 + Text006);
                StatusWindow.Update(1, StrSubstNo(Text002, SalesPayment."No."));
            end;
            GetTempMaxApplDate(TempApplyingEntry, ApplyingLedgEntry, ApplDate);
            GetTempMaxApplDate(TempApplyToEntry, ApplyToLedgEntry, ApplDate);
            repeat
                ApplCount := ApplCount + 1;
                if ShowStatusWindow() then
                    StatusWindow.Update(2, ApplCount);
                MoreAppls := GetTempApplEntry(TempApplyToEntry, ApplyToLedgEntry);
                if MoreAppls then begin
                    SetApplID(ApplyingLedgEntry, ApplyingLedgEntry);
                    ApplyingLedgEntry.Find; // P80066178
                    repeat
                        SetApplID(ApplyToLedgEntry, ApplyingLedgEntry);
                    until not NextTempApplEntry(TempApplyToEntry, ApplyToLedgEntry);
                    Post1Application(ApplyingLedgEntry, ApplDate);
                    ApplyingLedgEntry.Find;
                    if not ApplyingLedgEntry.Open then
                        MoreAppls := NextTempApplEntry(TempApplyingEntry, ApplyingLedgEntry);
                end;
            until not MoreAppls;
            Commit;
            UpdateAnalysisView.UpdateAll(0, true);
            Commit;
            if ShowStatusWindow() then
                StatusWindow.Close;
        end;
    end;

    local procedure InitTempApplEntries(var TempApplyingEntry: Record "Integer" temporary; var TempApplyToEntry: Record "Integer" temporary)
    var
        SalesPaymentLine: Record "Sales Payment Line";
        CustLedgEntry: Record "Cust. Ledger Entry";
        SalesTenderEntry: Record "Sales Payment Tender Entry";
    begin
        TempApplyingEntry.DeleteAll;
        TempApplyToEntry.DeleteAll;
        with SalesPaymentLine do begin
            SetRange("Document No.", SalesPayment."No.");
            SetRange(Type, Type::"Open Entry");
            if FindSet then
                repeat
                    CustLedgEntry.Get("Entry No.");
                    AddTempApplEntry(TempApplyingEntry, TempApplyToEntry, CustLedgEntry);
                until (Next = 0);
        end;
        with SalesTenderEntry do begin
            SetCurrentKey("Document No.");
            SetRange("Document No.", SalesPayment."No.");
            SetFilter("Cust. Ledger Entry No.", '<>0');
            if FindSet then
                repeat
                    CustLedgEntry.Get("Cust. Ledger Entry No.");
                    AddTempApplEntry(TempApplyingEntry, TempApplyToEntry, CustLedgEntry);
                until (Next = 0);
        end;
        if SalesPayment.InvoiceEntriesExist(CustLedgEntry) then
            repeat
                AddTempApplEntry(TempApplyingEntry, TempApplyToEntry, CustLedgEntry);
            until (CustLedgEntry.Next = 0);
    end;

    local procedure AddTempApplEntry(var TempApplyingEntry: Record "Integer" temporary; var TempApplyToEntry: Record "Integer" temporary; var CustLedgEntry: Record "Cust. Ledger Entry")
    begin
        with CustLedgEntry do begin // P800129560
            // P800129560
            if "Applies-to ID" <> '' then
                Error(AppliesToIDError, CustLedgEntry.FieldCaption("Applies-to ID"), CustLedgEntry.TableCaption, CustLedgEntry."Entry No.");
            // P800129560        
            if Open then
                if Positive then begin
                    TempApplyToEntry.Number := "Entry No.";
                    TempApplyToEntry.Insert;
                end else begin
                    TempApplyingEntry.Number := "Entry No.";
                    TempApplyingEntry.Insert;
                end;
        end; // P800129560
    end;

    local procedure GetTempApplEntry(var TempEntry: Record "Integer" temporary; var CustLedgEntry: Record "Cust. Ledger Entry"): Boolean
    begin
        if TempEntry.FindSet then
            repeat
                CustLedgEntry.Get(TempEntry.Number);
                if CustLedgEntry.Open then
                    exit(true);
            until (TempEntry.Next = 0);
    end;

    local procedure NextTempApplEntry(var TempEntry: Record "Integer" temporary; var CustLedgEntry: Record "Cust. Ledger Entry"): Boolean
    begin
        while (TempEntry.Next <> 0) do begin
            CustLedgEntry.Get(TempEntry.Number);
            if CustLedgEntry.Open then
                exit(true);
        end;
    end;

    local procedure GetTempMaxApplDate(var TempEntry: Record "Integer" temporary; var CustLedgEntry: Record "Cust. Ledger Entry"; var ApplDate: Date): Boolean
    begin
        repeat
            if (CustLedgEntry."Posting Date" > ApplDate) then
                ApplDate := CustLedgEntry."Posting Date";
        until not NextTempApplEntry(TempEntry, CustLedgEntry);
        GetTempApplEntry(TempEntry, CustLedgEntry);
    end;

    local procedure Post1Application(var ApplyingLedgEntry: Record "Cust. Ledger Entry"; ApplDate: Date)
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        with ApplyingLedgEntry do begin
            GenJnlLine."Document No." := SalesPayment."Posting No.";
            GenJnlLine."Posting Date" := ApplDate;
            GenJnlLine."Document Date" := ApplDate;
            GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
            GenJnlLine."Account No." := "Customer No.";
            CalcFields("Debit Amount", "Credit Amount", "Debit Amount (LCY)", "Credit Amount (LCY)");
            GenJnlLine.Correction :=
              ("Debit Amount" < 0) or ("Credit Amount" < 0) or
              ("Debit Amount (LCY)" < 0) or ("Credit Amount (LCY)" < 0);
            GenJnlLine."Document Type" := "Document Type";
            GenJnlLine.Description := Description;
            GenJnlLine."Shortcut Dimension 1 Code" := "Global Dimension 1 Code";
            GenJnlLine."Shortcut Dimension 2 Code" := "Global Dimension 2 Code";
            GenJnlLine."Dimension Set ID" := "Dimension Set ID"; // P8001133
            GenJnlLine."Posting Group" := "Customer Posting Group";
            GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
            GenJnlLine."Source No." := "Customer No.";
            GenJnlLine."Source Code" := SourceCodeSetup.Sales;
            GenJnlLine."System-Created Entry" := true;

            GenJnlPostLine.CustPostApplyCustLedgEntry(GenJnlLine, ApplyingLedgEntry);
        end;
    end;

    local procedure CreatePostedPayment()
    var
        SalesPaymentLine: Record "Sales Payment Line";
        PstdSalesPayment: Record "Posted Sales Payment Header";
        PstdSalesPaymentLine: Record "Posted Sales Payment Line";
        SalesTenderEntry: Record "Sales Payment Tender Entry";
        SalesTenderEntry2: Record "Sales Payment Tender Entry";
    begin
        PstdSalesPayment.TransferFields(SalesPayment);
        PstdSalesPayment."No." := SalesPayment."Posting No.";
        PstdSalesPayment."Sales Payment No." := SalesPayment."No.";
        PstdSalesPayment.Insert;
        PstdSalesPayment.CopyLinks(SalesPayment);
        with SalesPaymentLine do begin
            SetRange("Document No.", SalesPayment."No.");
            if FindSet then
                repeat
                    PstdSalesPaymentLine.TransferFields(SalesPaymentLine);
                    PstdSalesPaymentLine."Document No." := PstdSalesPayment."No.";
                    PstdSalesPaymentLine.Insert;
                    SalesPaymentLine.Delete;
                    if (Type = Type::Order) then
                        DeletePaymentOrder("No.");
                until (Next = 0);
        end;
        if (PstdSalesPayment."No." <> SalesPayment."No.") then
            with SalesTenderEntry do begin
                SetCurrentKey("Document No.");
                SetRange("Document No.", SalesPayment."No.");
                if FindSet then
                    repeat
                        SalesTenderEntry2 := SalesTenderEntry;
                        SalesTenderEntry2."Document No." := PstdSalesPayment."No.";
                        SalesTenderEntry2.Modify;
                    until (Next = 0);
            end;
        if SalesPayment.HasLinks then
            SalesPayment.DeleteLinks;
        SalesPayment.Delete;
        Commit;
    end;

    local procedure DeletePaymentOrder(SalesOrderNo: Code[20]): Boolean
    var
        SalesOrder: Record "Sales Header";
    begin
        if SalesOrder.Get(SalesOrder."Document Type"::Order, SalesOrderNo) then begin
            ReleaseSalesDoc.Reopen(SalesOrder);
            exit(SalesOrder.Delete(true));
        end;
    end;

    procedure PostCashTender(var SalesPaymentHeader: Record "Sales Payment Header"; var PaymentMethod: Record "Payment Method"; PaymentAmount: Decimal)
    var
        SalesTenderEntry: Record "Sales Payment Tender Entry";
    begin
        InitCodeUnit(SalesPaymentHeader);
        CheckPaymentMethod(PaymentMethod, true);
        AssignPostingNo;
        InsertTenderEntry(PaymentMethod, '', PaymentAmount);
        SalesTenderEntry.FindLast;
        PostFromTenderEntry(PaymentMethod, SalesTenderEntry);
        if SalesPayment.UpdateStatus() then
            SalesPayment.Modify(true);
        Commit;
    end;

    procedure AuthorizeNonCashTender(var SalesPaymentHeader: Record "Sales Payment Header"; var PaymentMethod: Record "Payment Method"; CardCheckNo: Code[20]; PaymentAmount: Decimal)
    var
        PrevTenderEntry: Record "Sales Payment Tender Entry";
        SalesTenderEntry: Record "Sales Payment Tender Entry";
        AuthorizedAmount: Decimal;
    begin
        InitCodeUnit(SalesPaymentHeader);
        CheckPaymentMethod(PaymentMethod, false);
        AssignPostingNo;
        if PrevTenderEntry.FindPending(SalesPayment."No.", PaymentMethod.Code, CardCheckNo) then begin
            if (GetAuthorizedAmount(PrevTenderEntry) < PaymentAmount) then
                VoidTenderEntry(PrevTenderEntry)
            else
                VoidTenderEntry(PrevTenderEntry);
            if SalesPayment.UpdateStatus() then
                SalesPayment.Modify(true);
            Commit;
        end;
        InsertTenderEntry(PaymentMethod, CardCheckNo, PaymentAmount);
        if SalesPayment.UpdateStatus() then
            SalesPayment.Modify(true);
        Commit;
    end;

    local procedure GetAuthorizedAmount(var SalesTenderEntry: Record "Sales Payment Tender Entry"): Decimal
    begin
        with SalesTenderEntry do begin
            if ("Authorization Entry No." = 0) then
                exit(Amount);
        end;
    end;

    procedure VoidNonCashTender(var SalesPaymentHeader: Record "Sales Payment Header"; var PaymentMethod: Record "Payment Method"; CardCheckNo: Code[20]; PaymentAmount: Decimal)
    var
        PrevTenderEntry: Record "Sales Payment Tender Entry";
    begin
        InitCodeUnit(SalesPaymentHeader);
        CheckPaymentMethod(PaymentMethod, false);
        AssignPostingNo;
        PrevTenderEntry.FindPending(SalesPayment."No.", PaymentMethod.Code, CardCheckNo);
        VoidTenderEntry(PrevTenderEntry);
        if SalesPayment.UpdateStatus() then
            SalesPayment.Modify(true);
        Commit;
    end;

    local procedure CheckPaymentMethod(var PaymentMethod: Record "Payment Method"; IsCash: Boolean)
    begin
        with PaymentMethod do begin
            TestField("Cash Tender Method", IsCash);
            TestField("Bal. Account No.");
        end;
    end;

    local procedure GetNextTenderEntryNo(): Integer
    var
        LastSalesTenderEntry: Record "Sales Payment Tender Entry";
    begin
        if (LastTenderEntryNo = 0) then
            if LastSalesTenderEntry.FindLast then
                LastTenderEntryNo := LastSalesTenderEntry."Entry No.";
        LastTenderEntryNo := LastTenderEntryNo + 1;
        exit(LastTenderEntryNo);
    end;

    local procedure InsertTenderEntry(var PaymentMethod: Record "Payment Method"; CardCheckNo: Code[20]; PaymentAmount: Decimal)
    var
        SalesTenderEntry: Record "Sales Payment Tender Entry";
    begin
        with SalesTenderEntry do begin
            Init;
            "Entry No." := GetNextTenderEntryNo();
            "Document No." := SalesPayment."No.";
            "Customer No." := SalesPayment."Customer No.";
            "Payment Method Code" := PaymentMethod.Code;
            "Card/Check No." := CardCheckNo;
            Description := PaymentMethod.Description;
            if (PaymentAmount > 0) then
                Type := Type::Payment
            else
                Type := Type::Refund;
            Amount := PaymentAmount;
            Insert;
        end;
    end;

    local procedure VoidTenderEntry(var PrevTenderEntry: Record "Sales Payment Tender Entry")
    var
        VoidEntry: Record "Sales Payment Tender Entry";
    begin
        VoidEntry := PrevTenderEntry;
        with VoidEntry do begin
            "Entry No." := GetNextTenderEntryNo();
            Type := Type::Void;
            Amount := -Amount;
            Result := Result::" ";
            Insert;
        end;
        with PrevTenderEntry do begin
            "Voided by Entry No." := VoidEntry."Entry No.";
            Result := Result::Voided;
            Modify;
        end;
    end;

    local procedure FailTenderEntry(var SalesTenderEntry: Record "Sales Payment Tender Entry")
    var
        VoidEntry: Record "Sales Payment Tender Entry";
    begin
        VoidEntry := SalesTenderEntry;
        with VoidEntry do begin
            "Entry No." := GetNextTenderEntryNo();
            Type := Type::Void;
            Amount := -Amount;
            Result := Result::" ";
            Insert;
        end;
        with SalesTenderEntry do begin
            "Voided by Entry No." := VoidEntry."Entry No.";
            Modify;
        end;
    end;

    procedure SetHideGUI(NewHideGUI: Boolean)
    begin
        HideGUI := NewHideGUI;
    end;

    local procedure ShowStatusWindow(): Boolean
    begin
        exit(GuiAllowed and (not HideGUI));
    end;

    procedure PrintAfterPosting(var SalesPayment2: Record "Sales Payment Header")
    var
        PostedSalesPayment: Record "Posted Sales Payment Header";
    begin
        PostedSalesPayment."No." := SalesPayment2."Posting No.";
        PostedSalesPayment.SetRecFilter;
        REPORT.Run(REPORT::"Sales Payment - Posted", false, false, PostedSalesPayment);
    end;
}

