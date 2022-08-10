codeunit 37002128 "Accrual Calculation Management"
{
    // PR3.70.03
    // 
    // PR3.70.04
    // P8000044A, Myers Nissi, Jack Reynolds, 21 MAY 04
    //   Accrual Fixes
    // 
    // PR3.70.07
    // P8000119A, Myers Nissi, Don Bresee, 20 SEP 04
    //   Accruals update/fixes
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00.01
    // P8000274A, VerticalSoft, Jack Reynolds, 22 DEC 05
    //   Fix problems with resolving start and end dates for plan and ship-to codes
    // 
    // PR4.00.04
    // P8000355A, VerticalSoft, Jack Reynolds, 19 JUL 06
    //   Add support for accrual groups
    // 
    // P8000389A, VerticalSoft, Jack Reynolds, 27 SEP 06
    //   CreateSchdAccrualJnlLine - for payments set Type and No.
    // 
    // PR4.00.06
    // P8000464A, VerticalSoft, Don Bresee, 9 APR 07
    //   Fixes relating to Combine Shipment & Combine Return Receipts functions
    // 
    // PRW15.00.02
    // P8000614A, VerticalSoft, Jack Reynolds, 25 JUL 08
    //   Fix problem with missing key in GetValueEntryAmounts
    // 
    // PRW16.00.01
    // P8000692, VerticalSoft, Jack Reynolds, 28 APR 09
    //   Fix problem with obsolete key
    // 
    // P8000697, VerticalSoft, Jack Reynolds, 06 MAY 09
    //   Modify GetValueEntryAmounts to use Document Line No. on the Value Entry table
    //   Remove ValueIsForDocLine, MatchInvLine, MatchCMLine, MatchDocLine
    // 
    // P8000731, VerticalSoft, Don Bresee, 08 OCT 09
    //   Add logic for date filtering for plans that accrue on "Paid Invoices/CMs"
    // 
    // PRW16.00.02
    // P8000757, VerticalSoft, Jack Reynolds, 08 JAN 10
    //   Fix problem with CreatePaymentJournal
    // 
    // PRW16.00.04
    // P8000850, VerticalSoft, Jack Reynolds, 23 JUL 10
    //   Fix commission calculation with Include Promo/Rebate and Price Impact
    // 
    // PRW16.00.05
    // P8000981, Columbus IT, Don Bresee, 20 SEP 11
    //   Separate Costing and Pricing units
    // 
    // PRW17.10
    // P8001236, Columbus IT, Don Bresee, 31 OCT 13
    //   Add logic for "Payment Posting Options" field
    // 
    // P8001237, Columbus IT, Don Bresee, 31 OCT 13
    //   Move logic to reduce the payment amount with the posted amount
    // 
    // PRW18.00.01
    // P8001374, Columbus IT, Jack Reynolds, 17 FEB 15
    //   Correct problem with sell-to/bill-to customers
    // 
    // PRW18.00.02
    // P8003887, To-Increase, Jack Reynolds, 23 Sep 15
    //   Fix problem with suggest payemnts with payment posting level
    // 
    // P8002745, To-Increase, Jack Reynolds, 30 Sep 15
    //   Support for accrual payment documents
    // 
    // PRW19.00
    // P8005495, To-Increase, Jack Reynolds, 20 NOV 15
    //   Fix problem with wrong dates (posting date vs. order date)
    // 
    // PRW110.0.01
    // P8008663, To-Increase, Jack Reynolds 21 APR 17
    //   Payments in foreign currencies
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Permissions = TableData "Posted Document Accrual Line" = r,
                  TableData "Accrual Plan Search Line" = r;

    trigger OnRun()
    begin
    end;

    var
        AccrualJnlLine: Record "Accrual Journal Line";
        EntryPostingDate: Date;
        EntryDocumentNo: Code[20];
        LastAccrualPlan: Record "Accrual Plan";
        NewLinesCreated: Boolean;
        PaymentGroup: Record "Accrual Payment Group";
        TempPaymentGroupLine: Record "Accrual Payment Group Line" temporary;
        TempPaymentGroupLineNo: Integer;
        RptAccrualGroupLine: Record "Accrual Group Line";
        RptAccrualSourceLine: Record "Accrual Plan Source Line";
        TempDocAccrualLine: Record "Document Accrual Line" temporary;
        Item: Record Item;
        Text000: Label 'This report must be run from the Accrual Journal.';
        Text001: Label 'Circular reference to %1 %2 in %1 %3.';
        CalculationLevel: Integer;
        TempPaidSalesInv: Record "Sales Invoice Line" temporary;
        TempPaidSalesCM: Record "Sales Cr.Memo Line" temporary;
        SalesDocPaidType: Option;
        SalesDocPaidNo: Code[20];
        SalesDocCalculatePartial: Boolean;
        SalesDocPaidFactor: Decimal;
        TempPaymentDoc: Record "Accrual Ledger Entry" temporary;
        TempPaymentDocEntryNo: Integer;
        Text002: Label 'Payment %1 %2 for %3';

    procedure SetJnlLine(var AccrualJnlLine2: Record "Accrual Journal Line")
    begin
        AccrualJnlLine := AccrualJnlLine2;
        with AccrualJnlLine do begin
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            if not Find('+') then
                "Line No." := 0
            else
                if ("Document No." <> '') then
                    "Document No." := IncStr("Document No.");
        end;
    end;

    procedure SetEntryInfo(NewPostingDate: Date; NewDocumentNo: Code[20])
    begin
        EntryPostingDate := NewPostingDate;
        EntryDocumentNo := NewDocumentNo;

        //IF (AccrualJnlLine."Journal Template Name" = '') THEN // P8002746
        //  ERROR(Text000);                                     // P8002746
    end;

    local procedure HandleDocumentNo(var AccrualPlan: Record "Accrual Plan")
    begin
        if (LastAccrualPlan."No." <> AccrualPlan."No.") then begin
            if NewLinesCreated then
                EntryDocumentNo := IncStr(EntryDocumentNo)
            else
                NewLinesCreated := true;
            LastAccrualPlan := AccrualPlan;
        end;
    end;

    procedure ReadyToAccrueSale(var AccrualPlan: Record "Accrual Plan"; CustomerNo: Code[20]; SourceDocNo: Code[20]; PostingDate: Date): Boolean
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        if (AccrualPlan.Accrue <> AccrualPlan.Accrue::"Paid Invoices/CMs") then
            exit(true);

        with CustLedgEntry do begin
            //SETCURRENTKEY("Document No.", "Document Type", "Customer No."); // P8000692
            SetCurrentKey("Document No.");                                    // P8000692
            SetRange("Document No.", SourceDocNo);
            SetRange("Document Type", "Document Type"::Invoice);
            SetRange("Customer No.", CustomerNo);
            SetRange("Posting Date", PostingDate);
            if not Find('-') then
                exit(false);
            exit(not Open);
        end;
    end;

    procedure ReadyToAccruePurchase(var AccrualPlan: Record "Accrual Plan"; VendorNo: Code[20]; SourceDocNo: Code[20]; PostingDate: Date): Boolean
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        if (AccrualPlan.Accrue <> AccrualPlan.Accrue::"Paid Invoices/CMs") then
            exit(true);

        with VendLedgEntry do begin
            //SETCURRENTKEY("Document No.", "Document Type", "Vendor No."); // P8000692
            SetCurrentKey("Document No.");                                  // P8000692
            SetRange("Document No.", SourceDocNo);
            SetRange("Document Type", "Document Type"::Invoice);
            SetRange("Vendor No.", VendorNo);
            SetRange("Posting Date", PostingDate);
            if not Find('-') then
                exit(false);
            exit(not Open);
        end;
    end;

    procedure CreateAccrualJnlLine(var AccrualPlan: Record "Accrual Plan"; AccrualAmount: Decimal; SourceNo: Code[20]; BillToPayToNo: Code[20]; SourceDocType: Integer; SourceDocNo: Code[20]; SourceDocLineNo: Integer)
    var
        AccrualJnlLine2: Record "Accrual Journal Line";
        PostedAccrualAmount: Decimal;
    begin
        PostedAccrualAmount :=
          AccrualPlan.GetPostedAccrualAmount(SourceNo, SourceDocType, SourceDocNo, SourceDocLineNo);
        if (PostedAccrualAmount = AccrualAmount) then
            exit;

        HandleDocumentNo(AccrualPlan);

        AccrualJnlLine."Line No." := AccrualJnlLine."Line No." + 10000;
        AccrualJnlLine2 := AccrualJnlLine;
        with AccrualJnlLine2 do begin
            Init;
            SetUpNewLine(AccrualJnlLine);

            Validate("Posting Date", EntryPostingDate);
            Validate("Document No.", EntryDocumentNo);
            Validate("Accrual Plan Type", AccrualPlan.Type);
            Validate("Accrual Plan No.", AccrualPlan."No.");
            Validate("Entry Type", "Entry Type"::Accrual);
            Validate("Source No.", SourceNo);
            Validate(Type, AccrualPlan.Type);
            Validate("No.", BillToPayToNo);
            Validate("Source Document Type", SourceDocType);
            Validate("Source Document No.", SourceDocNo);
            Validate("Source Document Line No.", SourceDocLineNo);
            Validate(Amount, AccrualAmount - PostedAccrualAmount);
            Insert(true);
        end;
    end;

    procedure GetPaymentDistribution(AccrualPlanType: Integer; AccrualPlanNo: Code[20]; BillToPayToNo: Code[20]; PaymentAmount: Decimal; var TempJnlLine: Record "Accrual Journal Line")
    var
        AccrualPlan: Record "Accrual Plan";
    begin
        TempJnlLine.DeleteAll;
        TempJnlLine."Line No." := 0;

        with AccrualPlan do begin
            Get(AccrualPlanType, AccrualPlanNo);
            case "Payment Type" of
                "Payment Type"::"Source Bill-to/Pay-to":
                    CreateTempPayment(PaymentAmount, Type, BillToPayToNo, TempJnlLine);
                "Payment Type"::Customer:
                    CreateTempPayment(PaymentAmount, TempJnlLine.Type::Customer, "Payment Code", TempJnlLine);
                "Payment Type"::Vendor:
                    CreateTempPayment(PaymentAmount, TempJnlLine.Type::Vendor, "Payment Code", TempJnlLine);
                "Payment Type"::"G/L Account":
                    CreateTempPayment(PaymentAmount, TempJnlLine.Type::"G/L Account", "Payment Code", TempJnlLine);
                "Payment Type"::"Payment Group":
                    CreateTempGroupPayment(Type, BillToPayToNo, PaymentAmount, "Payment Code", TempJnlLine);
            end;
        end;
    end;

    local procedure CreateTempPayment(PaymentAmount: Decimal; PaymentType: Integer; PaymentNo: Code[20]; var TempJnlLine: Record "Accrual Journal Line")
    begin
        with TempJnlLine do begin
            "Line No." := "Line No." + 1;
            Type := PaymentType;
            "No." := PaymentNo;
            Amount := PaymentAmount;
            Insert;
        end;
    end;

    local procedure CreateTempGroupPayment(AccrualPlanType: Integer; BillToPayToNo: Code[20]; PaymentAmount: Decimal; PaymentGroupCode: Code[20]; var TempJnlLine: Record "Accrual Journal Line")
    var
        AmtDistributed: Decimal;
        PctDistributed: Decimal;
        AmtToDistribute: Decimal;
    begin
        PaymentGroup.Reset;
        with TempPaymentGroupLine do begin
            DeleteAll;
            TempPaymentGroupLineNo := 0;
            BuildGroupDistribution('', PaymentGroupCode, 100);
            Reset;
            if Find('-') then
                repeat
                    PctDistributed := PctDistributed + "Payment %";
                    AmtToDistribute := Round(PaymentAmount * (PctDistributed / 100)) - AmtDistributed;
                    AmtDistributed := AmtDistributed + AmtToDistribute;
                    if (Type = Type::"Source Bill-to/Pay-to") then
                        CreateTempPayment(AmtToDistribute, AccrualPlanType, BillToPayToNo, TempJnlLine)
                    else
                        CreateTempPayment(AmtToDistribute, Type - 1, Code, TempJnlLine);
                until (Next = 0);
        end;
    end;

    local procedure BuildGroupDistribution(ParentPaymentGroupCode: Code[20]; PaymentGroupCode: Code[20]; PercentOfTotal: Decimal)
    var
        PaymentGroupLine: Record "Accrual Payment Group Line";
        NewPercentOfTotal: Decimal;
    begin
        with PaymentGroup do begin
            Get(PaymentGroupCode);
            if Mark then
                Error(Text001,
                      TableCaption, ParentPaymentGroupCode, PaymentGroupCode);
            Mark(true);
        end;

        with PaymentGroupLine do begin
            SetRange("Accrual Payment Group", PaymentGroupCode);
            if Find('-') then
                repeat
                    NewPercentOfTotal := PercentOfTotal * ("Payment %" / 100);
                    if (Type <> Type::"Payment Group") then
                        AddToGroupDistribution(Type, Code, NewPercentOfTotal)
                    else
                        BuildGroupDistribution(PaymentGroupCode, Code, NewPercentOfTotal);
                until (Next = 0);
        end;
    end;

    local procedure AddToGroupDistribution(PaymentType: Integer; PaymentNo: Code[20]; PercentOfTotal: Decimal)
    begin
        with TempPaymentGroupLine do begin
            SetRange(Type, PaymentType);
            SetRange(Code, PaymentNo);
            if Find('-') then begin
                "Payment %" := "Payment %" + PercentOfTotal;
                Modify;
            end else begin
                TempPaymentGroupLineNo := TempPaymentGroupLineNo + 1;
                "Line No." := TempPaymentGroupLineNo;
                Type := PaymentType;
                Code := PaymentNo;
                "Payment %" := PercentOfTotal;
                Insert;
            end;
        end;
    end;

    procedure GetPostedPaymentDistribution(var AccrualLedgEntry: Record "Accrual Ledger Entry"; var TempJnlLine: Record "Accrual Journal Line")
    var
        PostedDocAccrualLine: Record "Posted Document Accrual Line";
    begin
        TempJnlLine.DeleteAll;
        TempJnlLine."Line No." := 0;

        with PostedDocAccrualLine do begin
            SetRange("Accrual Plan Type", AccrualLedgEntry."Accrual Plan Type");
            SetRange("Source Document Type", AccrualLedgEntry."Source Document Type");
            SetRange("Source Document No.", AccrualLedgEntry."Source Document No.");
            SetRange("Source Document Line No.", AccrualLedgEntry."Source Document Line No.");
            SetRange("Accrual Plan No.", AccrualLedgEntry."Accrual Plan No.");
            if Find('-') then
                repeat
                    TempJnlLine.TransferFields(PostedDocAccrualLine);
                    TempJnlLine."Line No." := TempJnlLine."Line No." + 1;
                    TempJnlLine.Insert;
                until (Next = 0);
        end;
    end;

    procedure CreatePaymentJnlLine(var AccrualPlan: Record "Accrual Plan"; PaymentAmount: Decimal; SourceNo: Code[20]; PaymentType: Integer; PaymentNo: Code[20]; SourceDocType: Integer; SourceDocNo: Code[20]; SourceDocLineNo: Integer)
    var
        AccrualJnlLine2: Record "Accrual Journal Line";
        PostedPaymentAmount: Decimal;
    begin
        // P8001237
        // PostedPaymentAmount :=
        //   AccrualPlan.GetPostedPaymentAmount(
        //     SourceNo, SourceDocType, SourceDocNo, SourceDocLineNo); // P8000757
        // IF (PostedPaymentAmount = PaymentAmount) THEN
        //   EXIT;
        // P8001237

        HandleDocumentNo(AccrualPlan);

        AccrualJnlLine."Line No." := AccrualJnlLine."Line No." + 10000;
        AccrualJnlLine2 := AccrualJnlLine;
        with AccrualJnlLine2 do begin
            Init;
            SetUpNewLine(AccrualJnlLine);

            Validate("Posting Date", EntryPostingDate);
            Validate("Document No.", EntryDocumentNo);
            Validate("Accrual Plan Type", AccrualPlan.Type);
            Validate("Accrual Plan No.", AccrualPlan."No.");
            Validate("Entry Type", "Entry Type"::Payment);
            Validate("Source No.", SourceNo);
            Validate(Type, PaymentType);
            Validate("No.", PaymentNo);
            if (AccrualPlan."Computation Level" <> AccrualPlan."Computation Level"::Plan) then begin
                Validate("Source Document Type", SourceDocType);
                Validate("Source Document No.", SourceDocNo);
                if (AccrualPlan."Computation Level" =
                    AccrualPlan."Computation Level"::"Document Line")
                then
                    Validate("Source Document Line No.", SourceDocLineNo);
            end;
            // VALIDATE(Amount, PaymentAmount - PostedPaymentAmount); // P8001237
            Validate(Amount, PaymentAmount);                          // P8001237
            Insert(true);
        end;
    end;

    procedure CreateSchdAccrualJnlLine(var AccrualPlan: Record "Accrual Plan"; PostingDate: Date; EntryType: Integer; AccrualNo: Code[10])
    var
        AccrualJnlLine2: Record "Accrual Journal Line";
    begin
        HandleDocumentNo(AccrualPlan);

        AccrualJnlLine."Line No." := AccrualJnlLine."Line No." + 10000;
        AccrualJnlLine2 := AccrualJnlLine;
        with AccrualJnlLine2 do begin
            Init;
            SetUpNewLine(AccrualJnlLine);

            if (PostingDate <> 0D) then
                Validate("Posting Date", PostingDate)
            else
                Validate("Posting Date", EntryPostingDate);
            Validate("Document No.", EntryDocumentNo);
            Validate("Accrual Plan Type", AccrualPlan.Type);
            Validate("Accrual Plan No.", AccrualPlan."No.");
            Validate("Entry Type", EntryType);
            // P800389A
            if "Entry Type" = "Entry Type"::Payment then
                if AccrualPlan."Payment Type" in [AccrualPlan."Payment Type"::Customer,
                  AccrualPlan."Payment Type"::Vendor, AccrualPlan."Payment Type"::"G/L Account"]
                then begin
                    Validate(Type, AccrualPlan."Payment Type" - 1);
                    Validate("No.", AccrualPlan."Payment Code");
                end;
            // P800389A
            Validate("Scheduled Accrual No.", AccrualNo);
            Insert(true);
        end;
    end;

    procedure CreatePaymentDocLine(var AccrualPlan: Record "Accrual Plan"; PaymentAmount: Decimal; SourceNo: Code[20]; PaymentType: Integer; PaymentNo: Code[20]; SourceDocType: Integer; SourceDocNo: Code[20]; SourceDocLineNo: Integer)
    begin
        // P8002746
        InsertPaymentDocHeader(PaymentAmount, PaymentType, PaymentNo);
        InsertPaymentDocLine(AccrualPlan, PaymentAmount, SourceNo, SourceDocType, SourceDocNo, SourceDocLineNo, '', '');
    end;

    procedure CreateSchedPaymentDocLine(var AccrualPlan: Record "Accrual Plan"; var AccrualScheduleLine: Record "Accrual Plan Schedule Line")
    var
        PaymentAmount: Decimal;
    begin
        // P8002746
        PaymentAmount := AccrualScheduleLine.SignedAmount(AccrualScheduleLine.Amount) - AccrualScheduleLine."Posted Amount";
        InsertPaymentDocHeader(PaymentAmount, AccrualPlan."Payment Type" - 1, AccrualPlan."Payment Code");
        InsertPaymentDocLine(AccrualPlan, PaymentAmount, '', 0, '', 0, AccrualScheduleLine."No.",
          StrSubstNo(Text002, AccrualScheduleLine.FieldCaption("No."), AccrualScheduleLine."No.", AccrualScheduleLine."Scheduled Date"));
    end;

    local procedure InsertPaymentDocHeader(var PaymentAmount: Decimal; PaymentType: Integer; PaymentNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        DocType: Integer;
    begin
        // P8002746
        // P8008663 - PaymentAmount passed by reference
        if PaymentType = TempPaymentDoc.Type::Customer then
            if PaymentAmount > 0 then
                DocType := SalesHeader."Document Type"::"Credit Memo"
            else
                DocType := SalesHeader."Document Type"::Invoice;
        if PaymentType = TempPaymentDoc.Type::Vendor then
            if PaymentAmount > 0 then
                DocType := PurchHeader."Document Type"::Invoice
            else
                DocType := PurchHeader."Document Type"::"Credit Memo";
        TempPaymentDoc.SetRange(Type, PaymentType);
        TempPaymentDoc.SetRange("No.", PaymentNo);
        TempPaymentDoc.SetRange("Source Document Type", DocType);
        if not TempPaymentDoc.FindFirst then begin
            TempPaymentDocEntryNo += 1;
            TempPaymentDoc."Entry No." := TempPaymentDocEntryNo;
            TempPaymentDoc.Type := PaymentType;
            TempPaymentDoc."No." := PaymentNo;
            TempPaymentDoc."Source Document Type" := DocType;
            TempPaymentDoc."Source Document Line No." := 0;

            case TempPaymentDoc.Type of
                TempPaymentDoc.Type::Customer:
                    begin
                        SalesHeader."Document Type" := TempPaymentDoc."Source Document Type";
                        SalesHeader.Insert(true);
                        TempPaymentDoc."Source Document No." := SalesHeader."No.";
                        SalesHeader.Validate("Sell-to Customer No.", PaymentNo);
                        SalesHeader.Validate("Posting Date", EntryPostingDate);
                        SalesHeader."Accrual Payment" := true;
                        SalesHeader.Modify(true);
                        // P8008663
                        TempPaymentDoc."Source Code" := SalesHeader."Currency Code";
                        TempPaymentDoc.Amount := SalesHeader."Currency Factor";
                        // P8008663
                    end;

                TempPaymentDoc.Type::Vendor:
                    begin
                        PurchHeader."Document Type" := TempPaymentDoc."Source Document Type";
                        PurchHeader.Insert(true);
                        TempPaymentDoc."Source Document No." := PurchHeader."No.";
                        PurchHeader.Validate("Buy-from Vendor No.", PaymentNo);
                        PurchHeader.Validate("Posting Date", EntryPostingDate);
                        PurchHeader."Accrual Payment" := true;
                        PurchHeader.Modify(true);
                        // P8008663
                        TempPaymentDoc."Source Code" := PurchHeader."Currency Code";
                        TempPaymentDoc.Amount := PurchHeader."Currency Factor";
                        // P8008663
                    end;
            end;

            TempPaymentDoc.Insert;
        end;

        // P8008663
        if TempPaymentDoc."Source Code" <> '' then begin
            Currency.Get(TempPaymentDoc."Source Code");
            Currency.TestField("Amount Rounding Precision");
            PaymentAmount :=
              Round(
                CurrExchRate.ExchangeAmtLCYToFCY(EntryPostingDate, TempPaymentDoc."Source Code", PaymentAmount, TempPaymentDoc.Amount),
                Currency."Unit-Amount Rounding Precision")
        end;
        // P8008663
    end;

    local procedure InsertPaymentDocLine(var AccrualPlan: Record "Accrual Plan"; PaymentAmount: Decimal; SourceNo: Code[20]; SourceDocType: Integer; SourceDocNo: Code[20]; SourceDocLineNo: Integer; AccrualNo: Code[10]; LineDesc: Text[100])
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
    begin
        // P8002746
        TempPaymentDoc."Source Document Line No." += 10000;
        TempPaymentDoc.Modify;

        case TempPaymentDoc.Type of
            TempPaymentDoc.Type::Customer:
                begin
                    SalesLine."Document Type" := TempPaymentDoc."Source Document Type";
                    SalesLine."Document No." := TempPaymentDoc."Source Document No.";
                    SalesLine."Line No." := TempPaymentDoc."Source Document Line No.";
                    SalesLine.Validate(Type, SalesLine.Type::FOODAccrualPlan);
                    SalesLine.Validate("No.", AccrualPlan."No.");
                    if SourceNo <> '' then
                        SalesLine.Validate("Accrual Source No.", SourceNo);
                    if SourceDocNo <> '' then begin
                        SalesLine.Validate("Accrual Source Doc. Type", SourceDocType);
                        SalesLine.Validate("Accrual Source Doc. No.", SourceDocNo);
                    end;
                    if SourceDocLineNo <> 0 then
                        SalesLine.Validate("Accrual Source Doc. Line No.", SourceDocLineNo);
                    if AccrualNo <> '' then
                        SalesLine.Validate("Scheduled Accrual No.", AccrualNo);
                    SalesLine.Validate(Quantity, 1);
                    SalesLine.Validate("Unit Price", Abs(PaymentAmount));
                    if LineDesc <> '' then begin
                        SalesLine."Description 2" := SalesLine.Description;
                        SalesLine.Description := LineDesc;
                    end;
                    SalesLine.Insert(true);
                end;

            TempPaymentDoc.Type::Vendor:
                begin
                    PurchLine."Document Type" := TempPaymentDoc."Source Document Type";
                    PurchLine."Document No." := TempPaymentDoc."Source Document No.";
                    PurchLine."Line No." := TempPaymentDoc."Source Document Line No.";
                    PurchLine.Validate(Type, PurchLine.Type::FOODAccrualPlan);
                    PurchLine.Validate("No.", AccrualPlan."No.");
                    if SourceNo <> '' then
                        PurchLine.Validate("Accrual Source No.", SourceNo);
                    if SourceDocNo <> '' then begin
                        PurchLine.Validate("Accrual Source Doc. Type", SourceDocType);
                        PurchLine.Validate("Accrual Source Doc. No.", SourceDocNo);
                    end;
                    if SourceDocLineNo <> 0 then
                        PurchLine.Validate("Accrual Source Doc. Line No.", SourceDocLineNo);
                    if AccrualNo <> '' then
                        PurchLine.Validate("Scheduled Accrual No.", AccrualNo);
                    PurchLine.Validate(Quantity, 1);
                    PurchLine.Validate("Direct Unit Cost", Abs(PaymentAmount));
                    if LineDesc <> '' then begin
                        PurchLine."Description 2" := PurchLine.Description;
                        PurchLine.Description := LineDesc;
                    end;
                    PurchLine.Insert(true);
                end;
        end;
    end;

    procedure PrepareCustomer(var Customer: Record Customer; var CustomerFilters: Record Customer; var AccrualPlan: Record "Accrual Plan")
    begin
        with Customer do begin
            Reset;
            CopyFilters(CustomerFilters);

            if (AccrualPlan."Source Selection" = AccrualPlan."Source Selection"::"Price Group") then
                ;// SETCURRENTKEY("Customer Price Group");
        end;
    end;

    procedure GetCustomer(var Customer: Record Customer; var AccrualSourceLine: Record "Accrual Plan Source Line"; var AccrualPlan: Record "Accrual Plan"; FirstCustomer: Boolean): Boolean
    begin
        // P8000274A - add parameter for AccrualSourceLine
        Clear(AccrualSourceLine); // P8000274A
        with Customer do begin
            case AccrualPlan."Source Selection" of
                AccrualPlan."Source Selection"::All:
                    begin
                        if FirstCustomer then
                            exit(Find('-'));
                        exit(Next <> 0);
                    end;
                AccrualPlan."Source Selection"::Specific:
                    begin
                        repeat
                            if not GetSourceLine(AccrualPlan, FirstCustomer) then
                                exit(false);
                            FilterGroup(2);
                            SetRange("No.", RptAccrualSourceLine."Source Code");
                            FilterGroup(0);
                        until Find('-');
                        AccrualSourceLine := RptAccrualSourceLine; // P8000274A
                        exit(true);
                    end;
                AccrualPlan."Source Selection"::"Price Group":
                    begin
                        if not FirstCustomer then
                            if (Next <> 0) then
                                exit(true);
                        repeat
                            if not GetSourceLine(AccrualPlan, FirstCustomer) then
                                exit(false);
                            FilterGroup(2);
                            SetRange("Customer Price Group", RptAccrualSourceLine."Source Code");
                            FilterGroup(0);
                        until Find('-');
                        AccrualSourceLine := RptAccrualSourceLine; // P8000274A
                        exit(true);
                    end;
                // P8000355A
                AccrualPlan."Source Selection"::"Accrual Group":
                    begin
                        if FirstCustomer then begin
                            if not GetSourceLine(AccrualPlan, FirstCustomer) then
                                exit(false);
                            FirstCustomer := true;
                        end;
                        repeat
                            if not GetGroupLine(RptAccrualSourceLine, FirstCustomer) then
                                exit(false);
                            FilterGroup(2);
                            SetRange("No.", RptAccrualGroupLine."No.");
                            FilterGroup(0);
                        until Find('-');
                        AccrualSourceLine := RptAccrualSourceLine;
                        exit(true);
                    end;
                    // P8000355A
            end;
        end;
    end;

    procedure PrepareVendor(var Vendor: Record Vendor; var VendorFilters: Record Vendor; var AccrualPlan: Record "Accrual Plan")
    begin
        with Vendor do begin
            Reset;
            CopyFilters(VendorFilters);
        end;
    end;

    procedure GetVendor(var Vendor: Record Vendor; var AccrualSourceLine: Record "Accrual Plan Source Line"; var AccrualPlan: Record "Accrual Plan"; FirstVendor: Boolean): Boolean
    begin
        // P8000274A - add parameter for AccrualSourceLine
        Clear(AccrualSourceLine); // P8000274A
        // P8000355A
        with Vendor do begin
            case AccrualPlan."Source Selection" of
                AccrualPlan."Source Selection"::All:
                    begin
                        if FirstVendor then
                            exit(Find('-'));
                        exit(Next <> 0);
                    end;
                AccrualPlan."Source Selection"::Specific:
                    begin
                        repeat
                            if not GetSourceLine(AccrualPlan, FirstVendor) then
                                exit(false);
                            FilterGroup(2);
                            SetRange("No.", RptAccrualSourceLine."Source Code");
                            FilterGroup(0);
                        until Find('-');
                        AccrualSourceLine := RptAccrualSourceLine;
                        exit(true);
                    end;
                AccrualPlan."Source Selection"::"Accrual Group":
                    begin
                        if FirstVendor then begin
                            if not GetSourceLine(AccrualPlan, FirstVendor) then
                                exit(false);
                            FirstVendor := true;
                        end;
                        repeat
                            if not GetGroupLine(RptAccrualSourceLine, FirstVendor) then
                                exit(false);
                            FilterGroup(2);
                            SetRange("No.", RptAccrualGroupLine."No.");
                            FilterGroup(0);
                        until Find('-');
                        AccrualSourceLine := RptAccrualSourceLine;
                        exit(true);
                    end;
            end;
        end;
        // P8000355A
    end;

    local procedure GetGroupLine(var AccrualSourceLine: Record "Accrual Plan Source Line"; var FirstLine: Boolean): Boolean
    begin
        // P8000355A - Change parameter from Accrual Plan to Accrual Plan Source Line
        with RptAccrualGroupLine do begin
            if not FirstLine then
                exit(Next <> 0);
            SetRange("Accrual Group Type", AccrualSourceLine."Accrual Plan Type"); // P8000355A
            SetRange("Accrual Group Code", AccrualSourceLine."Source Code");       // P8000355A
            FirstLine := false;
            exit(Find('-'));
        end;
    end;

    local procedure GetSourceLine(var AccrualPlan: Record "Accrual Plan"; var FirstLine: Boolean): Boolean
    begin
        with RptAccrualSourceLine do begin
            if not FirstLine then
                exit(Next <> 0);
            SetRange("Accrual Plan Type", AccrualPlan.Type);
            SetRange("Accrual Plan No.", AccrualPlan."No.");
            FirstLine := false;
            exit(Find('-'));
        end;
    end;

    procedure GetSalesShptLineAmounts(var AccrualPlan: Record "Accrual Plan"; var SalesShptLine: Record "Sales Shipment Line"; var ShptAmount: Decimal; var ShptCost: Decimal; var ShptQuantity: Decimal; TransactionDate: Date)
    var
        CostQty: Decimal;
        ItemEntryRelation: Record "Item Entry Relation";
    begin
        // P8005495 - add parameter for TransactionDate
        with SalesShptLine do begin
            ShptAmount := 0;
            ShptCost := 0;
            ShptQuantity := 0;
            //CostQty := GetCostQty("No.", Quantity, "Quantity (Alt.)"); // P8000981
            CostQty := GetPriceQty("No.", Quantity, "Quantity (Alt.)");  // P8000981
            if ("Item Shpt. Entry No." <> 0) then
                AddItemLedgEntryAmounts(
                  AccrualPlan, "Item Shpt. Entry No.", "Accrual Amount (Price)",
                  CostQty, ShptAmount, ShptCost, ShptQuantity, TransactionDate) // P8005495
            else begin
                ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.");
                ItemEntryRelation.SetRange("Source ID", "Document No.");
                ItemEntryRelation.SetRange("Source Type", DATABASE::"Sales Shipment Line");
                ItemEntryRelation.SetRange("Source Ref. No.", "Line No.");
                if ItemEntryRelation.Find('-') then
                    repeat
                        AddItemLedgEntryAmounts(
                          AccrualPlan, ItemEntryRelation."Item Entry No.", "Accrual Amount (Price)",
                          CostQty, ShptAmount, ShptCost, ShptQuantity, TransactionDate); // P8005495
                    until (ItemEntryRelation.Next = 0);
            end;
        end;
    end;

    procedure GetSalesRcptLineAmounts(var AccrualPlan: Record "Accrual Plan"; var SalesRcptLine: Record "Return Receipt Line"; var RcptAmount: Decimal; var RcptCost: Decimal; var RcptQuantity: Decimal; TransactionDate: Date)
    var
        CostQty: Decimal;
        ItemEntryRelation: Record "Item Entry Relation";
    begin
        // P8005495 - add parameter for TransactionDate
        with SalesRcptLine do begin
            RcptAmount := 0;
            RcptCost := 0;
            RcptQuantity := 0;
            //CostQty := -GetCostQty("No.", Quantity, "Quantity (Alt.)"); // P8000981
            CostQty := -GetPriceQty("No.", Quantity, "Quantity (Alt.)");  // P8000981
            if ("Item Rcpt. Entry No." <> 0) then
                AddItemLedgEntryAmounts(
                  AccrualPlan, "Item Rcpt. Entry No.", "Accrual Amount (Price)",
                  CostQty, RcptAmount, RcptCost, RcptQuantity, TransactionDate) // P8005495
            else begin
                ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.");
                ItemEntryRelation.SetRange("Source ID", "Document No.");
                ItemEntryRelation.SetRange("Source Type", DATABASE::"Return Receipt Line");
                ItemEntryRelation.SetRange("Source Ref. No.", "Line No.");
                if ItemEntryRelation.Find('-') then
                    repeat
                        AddItemLedgEntryAmounts(
                          AccrualPlan, ItemEntryRelation."Item Entry No.", "Accrual Amount (Price)",
                          CostQty, RcptAmount, RcptCost, RcptQuantity, TransactionDate); // P8005495
                    until (ItemEntryRelation.Next = 0);
            end;
        end;
    end;

    procedure GetPurchRcptLineAmounts(var AccrualPlan: Record "Accrual Plan"; var PurchRcptLine: Record "Purch. Rcpt. Line"; var RcptAmount: Decimal; var RcptCost: Decimal; var RcptQuantity: Decimal; TransactionDate: Date)
    var
        CostQty: Decimal;
        ItemEntryRelation: Record "Item Entry Relation";
    begin
        // P8005495 - add parameter for TransactionDate
        with PurchRcptLine do begin
            RcptAmount := 0;
            RcptCost := 0;
            RcptQuantity := 0;
            CostQty := GetCostQty("No.", Quantity, "Quantity (Alt.)");
            if ("Item Rcpt. Entry No." <> 0) then
                AddItemLedgEntryAmounts(
                  AccrualPlan, "Item Rcpt. Entry No.", "Accrual Amount (Cost)",
                  CostQty, RcptAmount, RcptCost, RcptQuantity, TransactionDate) // P8005495
            else begin
                ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.");
                ItemEntryRelation.SetRange("Source ID", "Document No.");
                ItemEntryRelation.SetRange("Source Type", DATABASE::"Purch. Rcpt. Line");
                ItemEntryRelation.SetRange("Source Ref. No.", "Line No.");
                if ItemEntryRelation.Find('-') then
                    repeat
                        AddItemLedgEntryAmounts(
                          AccrualPlan, ItemEntryRelation."Item Entry No.", "Accrual Amount (Cost)",
                          CostQty, RcptAmount, RcptCost, RcptQuantity, TransactionDate); // P8005495
                    until (ItemEntryRelation.Next = 0);
            end;
        end;
    end;

    procedure GetPurchShptLineAmounts(var AccrualPlan: Record "Accrual Plan"; var PurchShptLine: Record "Return Shipment Line"; var ShptAmount: Decimal; var ShptCost: Decimal; var ShptQuantity: Decimal; TransactionDate: Date)
    var
        CostQty: Decimal;
        ItemEntryRelation: Record "Item Entry Relation";
    begin
        // P8005495 - add parameter for TransactionDate
        with PurchShptLine do begin
            ShptAmount := 0;
            ShptCost := 0;
            ShptQuantity := 0;
            CostQty := -GetCostQty("No.", Quantity, "Quantity (Alt.)");
            if ("Item Shpt. Entry No." <> 0) then
                AddItemLedgEntryAmounts(
                  AccrualPlan, "Item Shpt. Entry No.", "Accrual Amount (Cost)",
                  CostQty, ShptAmount, ShptCost, ShptQuantity, TransactionDate) // P8005495
            else begin
                ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.");
                ItemEntryRelation.SetRange("Source ID", "Document No.");
                ItemEntryRelation.SetRange("Source Type", DATABASE::"Return Shipment Line");
                ItemEntryRelation.SetRange("Source Ref. No.", "Line No.");
                if ItemEntryRelation.Find('-') then
                    repeat
                        AddItemLedgEntryAmounts(
                          AccrualPlan, ItemEntryRelation."Item Entry No.", "Accrual Amount (Cost)",
                          CostQty, ShptAmount, ShptCost, ShptQuantity, TransactionDate); // P8005495
                    until (ItemEntryRelation.Next = 0);
            end;
        end;
    end;

    local procedure AddItemLedgEntryAmounts(var AccrualPlan: Record "Accrual Plan"; EntryNo: Integer; AccrualAmount: Decimal; CostQty: Decimal; var Amt: Decimal; var Cost: Decimal; var Qty: Decimal; TransactionDate: Date)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        // P8005495 - add parameter for TransactionDate
        with ItemLedgEntry do begin
            Get(EntryNo);
            CalcFields("Sales Amount (Actual)", "Cost Amount (Actual)");
            if (AccrualPlan."Computation Level" = AccrualPlan."Computation Level"::"Document Line") then
                if (AccrualPlan.Type = AccrualPlan.Type::Sales) then
                    "Sales Amount (Actual)" := "Sales Amount (Actual)" - (AccrualAmount * CostQty)
                else
                    "Cost Amount (Actual)" := "Cost Amount (Actual)" - (AccrualAmount * CostQty);
            Amt := Amt - "Sales Amount (Actual)";
            Cost := Cost + "Cost Amount (Actual)";
            Qty := Qty +
              AccrualPlan.CalcAccrualQuantity(                                          // P8000274A
                "Item No.", TransactionDate, Quantity, "Quantity (Alt.)"); // P8000274A, P8005495
        end;
    end;

    procedure GetSalesInvLineAmounts(var AccrualPlan: Record "Accrual Plan"; var SalesInvLine: Record "Sales Invoice Line"; var InvAmount: Decimal; var InvCost: Decimal; var InvQuantity: Decimal; TransactionDate: Date)
    var
        AccrualLedgEntry: Record "Accrual Ledger Entry";
    begin
        // P8000119A
        // P8005495 - add parameter for TransactionDate
        with SalesInvLine do begin
            GetValueEntryAmounts(
              AccrualPlan, "Sell-to Customer No.", "No.",
              DATABASE::"Sales Invoice Line", "Document No.", "Line No.",
              InvAmount, InvCost, InvQuantity, TransactionDate); // P8005495
            if (AccrualPlan."Computation Level" = AccrualPlan."Computation Level"::"Document Line") then
                InvAmount := InvAmount +
                  //"Accrual Amount (Price)" * GetCostQty("No.", Quantity, "Quantity (Alt.)"); // P8000981
                  "Accrual Amount (Price)" * GetPriceQty("No.", Quantity, "Quantity (Alt.)");  // P8000981
            if AccrualPlan."Include Promo/Rebate" then begin
                AccrualLedgEntry.SetCurrentKey(
                  "Accrual Plan Type", "Entry Type", "Price Impact", "Plan Type",
                  "Source Document Type", "Source Document No.", "Source Document Line No.");
                AccrualLedgEntry.SetRange("Accrual Plan Type", AccrualLedgEntry."Accrual Plan Type"::Sales);
                AccrualLedgEntry.SetRange("Entry Type", AccrualLedgEntry."Entry Type"::Accrual);
                // P8000850
                //AccrualLedgEntry.SETRANGE("Price Impact", AccrualLedgEntry."Price Impact"::None);
                AccrualLedgEntry.SetFilter("Price Impact", '%1|%2',
                  AccrualLedgEntry."Price Impact"::None, AccrualLedgEntry."Price Impact"::"Exclude from Price");
                // P8000850
                AccrualLedgEntry.SetRange("Plan Type", AccrualLedgEntry."Plan Type"::"Promo/Rebate");
                AccrualLedgEntry.SetRange("Source Document Type", AccrualLedgEntry."Source Document Type"::Invoice);
                AccrualLedgEntry.SetRange("Source Document No.", "Document No.");
                AccrualLedgEntry.SetRange("Source Document Line No.", "Line No.");
                AccrualLedgEntry.CalcSums(Amount);
                InvAmount := InvAmount - AccrualLedgEntry.Amount;
            end;
        end;
    end;

    procedure GetSalesCMLineAmounts(var AccrualPlan: Record "Accrual Plan"; var SalesCMLine: Record "Sales Cr.Memo Line"; var CMAmount: Decimal; var CMCost: Decimal; var CMQuantity: Decimal; TransactionDate: Date)
    var
        AccrualLedgEntry: Record "Accrual Ledger Entry";
    begin
        // P8000119A
        // P8005495 - add parameter for TransactionDate
        with SalesCMLine do begin
            GetValueEntryAmounts(
              AccrualPlan, "Sell-to Customer No.", "No.",
              DATABASE::"Sales Cr.Memo Line", "Document No.", "Line No.",
              CMAmount, CMCost, CMQuantity, TransactionDate); // P8005495
            if (AccrualPlan."Computation Level" = AccrualPlan."Computation Level"::"Document Line") then
                CMAmount := CMAmount -
                  //"Accrual Amount (Price)" * GetCostQty("No.", Quantity, "Quantity (Alt.)"); // P8000981
                  "Accrual Amount (Price)" * GetPriceQty("No.", Quantity, "Quantity (Alt.)");  // P8000981
            if AccrualPlan."Include Promo/Rebate" then begin
                AccrualLedgEntry.SetCurrentKey(
                  "Accrual Plan Type", "Entry Type", "Price Impact", "Plan Type",
                  "Source Document Type", "Source Document No.", "Source Document Line No.");
                AccrualLedgEntry.SetRange("Accrual Plan Type", AccrualLedgEntry."Accrual Plan Type"::Sales);
                AccrualLedgEntry.SetRange("Entry Type", AccrualLedgEntry."Entry Type"::Accrual);
                // P8000850
                //AccrualLedgEntry.SETRANGE("Price Impact", AccrualLedgEntry."Price Impact"::None);
                AccrualLedgEntry.SetFilter("Price Impact", '%1|%2',
                  AccrualLedgEntry."Price Impact"::None, AccrualLedgEntry."Price Impact"::"Exclude from Price");
                // P8000850
                AccrualLedgEntry.SetRange("Plan Type", AccrualLedgEntry."Plan Type"::"Promo/Rebate");
                AccrualLedgEntry.SetRange("Source Document Type", AccrualLedgEntry."Source Document Type"::"Credit Memo");
                AccrualLedgEntry.SetRange("Source Document No.", "Document No.");
                AccrualLedgEntry.SetRange("Source Document Line No.", "Line No.");
                AccrualLedgEntry.CalcSums(Amount);
                CMAmount := CMAmount - AccrualLedgEntry.Amount;
            end;
        end;
    end;

    procedure GetPurchInvLineAmounts(var AccrualPlan: Record "Accrual Plan"; var PurchInvLine: Record "Purch. Inv. Line"; var InvAmount: Decimal; var InvCost: Decimal; var InvQuantity: Decimal; TransactionDate: Date)
    begin
        // P8005495 - add parameter for TransactionDate
        with PurchInvLine do begin
            GetValueEntryAmounts(
              AccrualPlan, "Buy-from Vendor No.", "No.",
              DATABASE::"Purch. Inv. Line", "Document No.", "Line No.", // P8000119A
              InvAmount, InvCost, InvQuantity, TransactionDate);        // P8000119A, P8005495
            if (AccrualPlan."Computation Level" = AccrualPlan."Computation Level"::"Document Line") then
                InvCost := InvCost -
                  "Accrual Amount (Cost)" * GetCostQty("No.", Quantity, "Quantity (Alt.)");
        end;
    end;

    procedure GetPurchCMLineAmounts(var AccrualPlan: Record "Accrual Plan"; var PurchCMLine: Record "Purch. Cr. Memo Line"; var CMAmount: Decimal; var CMCost: Decimal; var CMQuantity: Decimal; TransactionDate: Date)
    begin
        // P8005495 - add parameter for TransactionDate
        with PurchCMLine do begin
            GetValueEntryAmounts(
              AccrualPlan, "Buy-from Vendor No.", "No.",
              DATABASE::"Purch. Cr. Memo Line", "Document No.", "Line No.", // P8000119A
              CMAmount, CMCost, CMQuantity, TransactionDate);               // P8000119A, P8005495
            if (AccrualPlan."Computation Level" = AccrualPlan."Computation Level"::"Document Line") then
                CMCost := CMCost +
                  "Accrual Amount (Cost)" * GetCostQty("No.", Quantity, "Quantity (Alt.)");
        end;
    end;

    local procedure GetValueEntryAmounts(var AccrualPlan: Record "Accrual Plan"; SourceNo: Code[20]; ItemNo: Code[20]; TableNo: Integer; DocumentNo: Code[20]; DocumentLineNo: Integer; var Amt: Decimal; var Cost: Decimal; var Qty: Decimal; TransactionDate: Date)
    var
        ValueEntry: Record "Value Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        DocumentType: Integer;
    begin
        // P8000119A - add parameters for table number and document line no.
        // P8005495 - add parameter for TransactionDate
        with ValueEntry do begin
            // P8000697
            /*
            SETCURRENTKEY(
              //"Source Type", "Source No.", "Item Ledger Entry Type", "Item No.", "Posting Date"); // P8000614A
              "Source Type", "Source No.", "Item No.", "Posting Date", "Entry Type", Adjustment);   // P8000614A
            CASE AccrualPlan.Type OF
              AccrualPlan.Type::Sales :
                BEGIN
                  SETRANGE("Source Type", "Source Type"::Customer);
                  SETRANGE("Item Ledger Entry Type", "Item Ledger Entry Type"::Sale);
                END;
              AccrualPlan.Type::Purchase :
                BEGIN
                  SETRANGE("Source Type", "Source Type"::Vendor);
                  SETRANGE("Item Ledger Entry Type", "Item Ledger Entry Type"::Purchase);
                END;
            END;
            SETRANGE("Source No.", SourceNo);
            SETRANGE("Item No.", ItemNo);
            SETRANGE("Document No.", DocumentNo);
            */
            SetCurrentKey("Item Ledger Entry No.", "Document No.", "Document Line No.");
            SetRange("Document No.", DocumentNo);
            SetRange("Document Line No.", DocumentLineNo);
            case TableNo of
                DATABASE::"Sales Invoice Line":
                    DocumentType := ValueEntry."Document Type"::"Sales Invoice";
                DATABASE::"Sales Cr.Memo Line":
                    DocumentType := ValueEntry."Document Type"::"Sales Credit Memo";
                DATABASE::"Purch. Inv. Line":
                    DocumentType := ValueEntry."Document Type"::"Purchase Invoice";
                DATABASE::"Purch. Cr. Memo Line":
                    DocumentType := ValueEntry."Document Type"::"Purchase Credit Memo";
            end;
            // P8000697

            Amt := 0;
            Cost := 0;
            Qty := 0;
            GetItem(ItemNo);
            if Find('-') then
                repeat
                    //IF ValueIsForDocLine("Item Ledger Entry No.", TableNo, DocumentNo, DocumentLineNo) THEN BEGIN // P8000697
                    if "Document Type" = DocumentType then begin                                                    // P8000697
                        Amt := Amt - "Sales Amount (Actual)";
                        Cost := Cost + "Cost Amount (Actual)";
                        if ("Invoiced Quantity" <> 0) then begin
                            if (ItemLedgEntry."Entry No." <> "Item Ledger Entry No.") then
                                ItemLedgEntry.Get("Item Ledger Entry No.");
                            if ("Invoiced Quantity" = ItemLedgEntry.GetCostingInvQty()) then
                                Qty := Qty + AccrualPlan.CalcAccrualQuantity(
                                  "Item No.", TransactionDate,                                                  // P8000274A, P8005495
                                  ItemLedgEntry."Invoiced Quantity", ItemLedgEntry."Invoiced Quantity (Alt.)") // P8000274A
                            else
                                if Item.TrackAlternateUnits() then
                                    Qty := Qty + AccrualPlan.CalcAccrualQuantity("Item No.", TransactionDate,       // P8000274A, P8005495
                                      ItemLedgEntry."Invoiced Quantity" *
                                        ("Invoiced Quantity" / ItemLedgEntry."Invoiced Quantity (Alt.)"),
                                      "Invoiced Quantity")
                                else
                                    Qty := Qty + AccrualPlan.CalcAccrualQuantity("Item No.", TransactionDate, "Invoiced Quantity", 0); // P8000274A, P8005495
                        end;
                    end;
                until (Next = 0);
        end;

    end;

    procedure GetCostQty(ItemNo: Code[20]; Qty: Decimal; QtyAlt: Decimal): Decimal
    begin
        GetItem(ItemNo);
        if Item.CostInAlternateUnits() then
            exit(QtyAlt);
        exit(Qty);
    end;

    procedure GetPriceQty(ItemNo: Code[20]; Qty: Decimal; QtyAlt: Decimal): Decimal
    begin
        // P8000981
        GetItem(ItemNo);
        if Item.PriceInAlternateUnits() then
            exit(QtyAlt);
        exit(Qty);
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        if (Item."No." <> ItemNo) then
            Item.Get(ItemNo);
    end;

    procedure Disable()
    begin
        CalculationLevel := CalculationLevel + 1;
    end;

    procedure Enable()
    begin
        if (CalculationLevel > 0) then
            CalculationLevel := CalculationLevel - 1;
    end;

    procedure IsEnabled(): Boolean
    begin
        exit(CalculationLevel = 0);
    end;

    procedure DeleteAllDocLines(AccrualPlanType: Integer; DocumentType: Integer; DocumentNo: Code[20])
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        // P8000119A
        with DocAccrualLine do begin
            SetRange("Accrual Plan Type", AccrualPlanType);
            SetRange("Document Type", DocumentType);
            SetRange("Document No.", DocumentNo);
            if not IsEmpty then // P8000885
                DeleteAll;
        end;
    end;

    procedure DeleteDocLines(AccrualPlanType: Integer; ComputationLevel: Integer; DocumentType: Integer; DocumentNo: Code[20]; DocumentLineNo: Integer)
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        with DocAccrualLine do begin
            SetRange("Accrual Plan Type", AccrualPlanType);
            SetRange("Computation Level", ComputationLevel);
            SetRange("Document Type", DocumentType);
            SetRange("Document No.", DocumentNo);
            SetRange("Document Line No.", DocumentLineNo);
            if not IsEmpty then // P8000885
                DeleteAll;
        end;
    end;

    procedure Insert1TempDocLine(var DocAccrualLine: Record "Document Accrual Line")
    begin
        TempDocAccrualLine := DocAccrualLine;
        TempDocAccrualLine.Insert;
    end;

    procedure InsertTempDocLines(DocumentLineNo: Integer)
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        // P8000119A
        with TempDocAccrualLine do
            while Find('-') do begin
                DocAccrualLine := TempDocAccrualLine;
                DocAccrualLine."Document Line No." := DocumentLineNo;
                DocAccrualLine.Insert;
                Delete;
            end;
    end;

    procedure DeleteTempDocLines()
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        with TempDocAccrualLine do
            DeleteAll;
    end;

    procedure CalcTempDocTotals(var PromoRebateAmount: Decimal; var CommissionAmount: Decimal)
    begin
        with TempDocAccrualLine do begin
            SetRange("Plan Type", "Plan Type"::"Promo/Rebate");
            CalcSums("Payment Amount (LCY)");
            PromoRebateAmount := "Payment Amount (LCY)";
            SetRange("Plan Type", "Plan Type"::Commission);
            CalcSums("Payment Amount (LCY)");
            CommissionAmount := "Payment Amount (LCY)";
            SetRange("Plan Type");
        end;
    end;

    procedure CalcTempDocPriceImpact(var IncludedInPrice: Decimal; var ExcludedFromPrice: Decimal): Decimal
    begin
        with TempDocAccrualLine do begin
            SetRange("Price Impact", "Price Impact"::"Include in Price");
            CalcSums("Payment Amount (LCY)");
            IncludedInPrice := "Payment Amount (LCY)";
            SetRange("Price Impact", "Price Impact"::"Exclude from Price");
            CalcSums("Payment Amount (LCY)");
            ExcludedFromPrice := "Payment Amount (LCY)";
            SetRange("Price Impact");
            exit(IncludedInPrice - ExcludedFromPrice);
        end;
    end;

    procedure DocPlanTypeDrillDown(AccrualPlanType: Integer; PlanType: Integer; ComputationLevel: Integer; DocumentType: Integer; DocumentNo: Code[20]; DocumentLineNo: Integer)
    var
        DocAccrualLine: Record "Document Accrual Line";
        DocAccrualLines: Page "Document Accrual Lines";
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
    begin
        Commit;
        with DocAccrualLine do begin
            FilterGroup(3);
            SetRange("Accrual Plan Type", AccrualPlanType);
            SetRange("Plan Type", PlanType);
            SetRange("Computation Level", ComputationLevel);
            FilterGroup(0);
            SetRange("Document Type", DocumentType);
            SetRange("Document No.", DocumentNo);
            if (ComputationLevel = "Computation Level"::"Document Line") then
                SetRange("Document Line No.", DocumentLineNo);

            case AccrualPlanType of
                "Accrual Plan Type"::Sales:
                    begin
                        SalesHeader.Get(DocumentType, DocumentNo);
                        DocAccrualLines.DisableForm(SalesHeader.Status <> SalesHeader.Status::Open);
                    end;
                "Accrual Plan Type"::Purchase:
                    begin
                        PurchHeader.Get(DocumentType, DocumentNo);
                        DocAccrualLines.DisableForm(PurchHeader.Status <> PurchHeader.Status::Open);
                    end;
            end;
        end;
        DocAccrualLines.SetTableView(DocAccrualLine);
        DocAccrualLines.SetRecord(DocAccrualLine);
        DocAccrualLines.RunModal;
    end;

    procedure DocPriceImpactDrillDown(AccrualPlanType: Integer; DocumentType: Integer; DocumentNo: Code[20]; DocumentLineNo: Integer)
    var
        DocAccrualLine: Record "Document Accrual Line";
        DocAccrualLines: Page "Document Accrual Lines";
    begin
        Commit;
        with DocAccrualLine do begin
            FilterGroup(3);
            SetRange("Accrual Plan Type", AccrualPlanType);
            SetRange("Computation Level", "Computation Level"::"Document Line");
            FilterGroup(0);
            SetRange("Document Type", DocumentType);
            SetRange("Document No.", DocumentNo);
            SetRange("Document Line No.", DocumentLineNo);
            SetFilter("Price Impact", '<>%1', "Price Impact"::None);
        end;
        DocAccrualLines.DisableForm(true);
        DocAccrualLines.SetTableView(DocAccrualLine);
        DocAccrualLines.SetRecord(DocAccrualLine);
        DocAccrualLines.RunModal;
    end;

    procedure LedgPriceImpactDrillDown(AccrualPlanType: Integer; DocumentType: Integer; DocumentNo: Code[20]; DocumentLineNo: Integer)
    var
        AccrualLedgEntry: Record "Accrual Ledger Entry";
    begin
        with AccrualLedgEntry do begin
            SetCurrentKey("Accrual Plan Type", "Entry Type", "Price Impact");
            FilterGroup(3);
            SetRange("Accrual Plan Type", AccrualPlanType);
            SetRange("Entry Type", "Entry Type"::Accrual);
            SetRange("Source Document Type", DocumentType);
            FilterGroup(0);
            SetFilter("Price Impact", '<>%1', "Price Impact"::None);
            SetRange("Source Document No.", DocumentNo);
            SetRange("Source Document Line No.", DocumentLineNo);
        end;
        PAGE.RunModal(0, AccrualLedgEntry);
    end;

    procedure LoadPaidSales(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; BillTo: Boolean; var NumPaidInvoices: Integer; var NumPaidCMs: Integer): Boolean
    var
        DetlCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
        DetCustLedgerSellTo: Query "Detailed Cust. Ledger-Sell-to";
    begin
        // P8000731
        // P8001374 - add parameter for BillTo
        with TempPaidSalesInv do begin
            Reset;
            DeleteAll;
            SetCurrentKey("Accrual Posting Date", "Bill-to Customer No.", "Sell-to Customer No.", Type, "Document No.");
        end;
        with TempPaidSalesCM do begin
            Reset;
            DeleteAll;
            SetCurrentKey("Accrual Posting Date", "Bill-to Customer No.", "Sell-to Customer No.", Type, "Document No.");
        end;
        if BillTo then begin // P8001374
            with DetlCustLedgEntry do begin
                SetCurrentKey("Customer No.", "Posting Date", "Entry Type");
                SetRange("Customer No.", CustomerNo);
                SetRange("Posting Date", StartDate, EndDate);
                SetRange("Entry Type", "Entry Type"::Application);
                if FindSet then
                    repeat
                        CustLedgEntry.Get("Cust. Ledger Entry No.");
                        if (CustLedgEntry."Document Type" in
                            [CustLedgEntry."Document Type"::Invoice, CustLedgEntry."Document Type"::"Credit Memo"]) and
                           (not CustLedgEntry.Open)
                        then
                            if (CustLedgEntry."Closed at Date" <> 0D) then begin
                                if (CustLedgEntry."Closed at Date" >= StartDate) and (CustLedgEntry."Closed at Date" <= EndDate) then
                                    LoadCustLedgEntry(CustLedgEntry."Document Type", CustLedgEntry."Document No.", CustLedgEntry."Posting Date", // P8001374
                                      CustLedgEntry."Sell-to Customer No.", CustLedgEntry."Customer No.", CustLedgEntry."Closed at Date");       // P8001374
                            end else begin
                                if ("Applied Cust. Ledger Entry No." = "Cust. Ledger Entry No.") then
                                    LoadCustLedgEntry(CustLedgEntry."Document Type", CustLedgEntry."Document No.", CustLedgEntry."Posting Date", // P8001374
                                      CustLedgEntry."Sell-to Customer No.", CustLedgEntry."Customer No.", "Posting Date");                       // P8001374
                            end;
                    until (Next = 0);
            end;
            // P8001374
        end else begin
            DetCustLedgerSellTo.SetRange(PostingDate, StartDate, EndDate);
            DetCustLedgerSellTo.SetRange(CustLedgerEntry_SellToCustNo, CustomerNo);
            DetCustLedgerSellTo.Open;
            while DetCustLedgerSellTo.Read do begin
                if (DetCustLedgerSellTo.CustLedgerEntry_DocType in
                    [CustLedgEntry."Document Type"::Invoice, CustLedgEntry."Document Type"::"Credit Memo"]) and
                   (not DetCustLedgerSellTo.CustLedgerEntry_Open)
                then
                    if (DetCustLedgerSellTo.CustLedgerEntry_ClosedAtDate <> 0D) then begin
                        if (DetCustLedgerSellTo.CustLedgerEntry_ClosedAtDate >= StartDate) and (DetCustLedgerSellTo.CustLedgerEntry_ClosedAtDate <= EndDate) then
                            LoadCustLedgEntry(DetCustLedgerSellTo.CustLedgerEntry_DocType, DetCustLedgerSellTo.CustLedgerEntry_DocumentNo, DetCustLedgerSellTo.CustLedgerEntry_PostingDate,
                              DetCustLedgerSellTo.CustLedgerEntry_SellToCustNo, DetCustLedgerSellTo.BillToCustomerNo, DetCustLedgerSellTo.CustLedgerEntry_ClosedAtDate);
                    end else begin
                        if (DetCustLedgerSellTo.CustLedgerEntryNo = DetCustLedgerSellTo.AppliedCustLedgerEntryNo) then
                            LoadCustLedgEntry(DetCustLedgerSellTo.CustLedgerEntry_DocType, DetCustLedgerSellTo.CustLedgerEntry_DocumentNo, DetCustLedgerSellTo.CustLedgerEntry_PostingDate,
                              DetCustLedgerSellTo.CustLedgerEntry_SellToCustNo, DetCustLedgerSellTo.BillToCustomerNo, DetCustLedgerSellTo.PostingDate);
                    end;
            end;
        end;
        // P8001374
        NumPaidInvoices := TempPaidSalesInv.Count;
        NumPaidCMs := TempPaidSalesCM.Count;
        exit((NumPaidInvoices <> 0) or (NumPaidCMs <> 0));
    end;

    local procedure LoadCustLedgEntry(DocType: Option; DocNo: Code[20]; PostingDate: Date; SellToCustNo: Code[20]; BillToCustNo: Code[20]; ClosedDate: Date)
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCMHeader: Record "Sales Cr.Memo Header";
    begin
        // P8000731
        // P8001374 - remove parameter for CustLedgEntry and replace with individual fields; code changed below to use these parameters
        case DocType of
            CustLedgEntry."Document Type"::Invoice:
                if not TempPaidSalesInv.Get(DocNo, 0) then
                    if SalesInvHeader.Get(DocNo) then
                        if (SalesInvHeader."Posting Date" = PostingDate) then begin
                            TempPaidSalesInv."Document No." := SalesInvHeader."No.";
                            TempPaidSalesInv."Sell-to Customer No." := SellToCustNo;
                            TempPaidSalesInv."Bill-to Customer No." := BillToCustNo;
                            TempPaidSalesInv."Accrual Posting Date" := ClosedDate;
                            TempPaidSalesInv.Insert;
                        end;
            CustLedgEntry."Document Type"::"Credit Memo":
                if not TempPaidSalesCM.Get(DocNo, 0) then
                    if SalesCMHeader.Get(DocNo) then
                        if (SalesCMHeader."Posting Date" = PostingDate) then begin
                            TempPaidSalesCM."Document No." := SalesCMHeader."No.";
                            TempPaidSalesCM."Sell-to Customer No." := SellToCustNo;
                            TempPaidSalesCM."Bill-to Customer No." := BillToCustNo;
                            TempPaidSalesCM."Accrual Posting Date" := ClosedDate;
                            TempPaidSalesCM.Insert;
                        end;
        end;
    end;

    procedure GetPaidSalesDocNo(TableNo: Integer; FirstPaidDoc: Boolean; var PaidDocNo: Code[20])
    begin
        // P8000731
        case TableNo of
            DATABASE::"Sales Invoice Header":
                begin
                    if FirstPaidDoc then
                        TempPaidSalesInv.FindFirst
                    else
                        TempPaidSalesInv.Next;
                    PaidDocNo := TempPaidSalesInv."Document No.";
                end;
            DATABASE::"Sales Cr.Memo Header":
                begin
                    if FirstPaidDoc then
                        TempPaidSalesCM.FindFirst
                    else
                        TempPaidSalesCM.Next;
                    PaidDocNo := TempPaidSalesCM."Document No.";
                end;
        end;
    end;

    procedure AdjustForPaymentOptions(var AccrualPlan: Record "Accrual Plan"; var AccrualLedgEntry: Record "Accrual Ledger Entry")
    var
        PayPartial: Boolean;
    begin
        // P8001236
        with AccrualLedgEntry do begin
            if (Amount = 0) or (AccrualPlan."Payment Posting Options" = AccrualPlan."Payment Posting Options"::Immediate) then
                exit;
            if (AccrualPlan."Payment Posting Options" = AccrualPlan."Payment Posting Options"::"Partially Paid") then
                if not PostedPayDistributionExists(AccrualLedgEntry) then begin
                    Amount := Round(Amount * GetSalesDocPartialFactor(AccrualLedgEntry));
                    exit;
                end;
            if not IsSalesDocPaidInFull(AccrualLedgEntry) then
                Amount := 0;
        end;
    end;

    local procedure PostedPayDistributionExists(var AccrualLedgEntry: Record "Accrual Ledger Entry"): Boolean
    var
        PostedDocAccrualLine: Record "Posted Document Accrual Line";
    begin
        // P8001236
        with PostedDocAccrualLine do begin
            SetRange("Accrual Plan Type", AccrualLedgEntry."Accrual Plan Type");
            SetRange("Source Document Type", AccrualLedgEntry."Source Document Type");
            SetRange("Source Document No.", AccrualLedgEntry."Source Document No.");
            SetRange("Source Document Line No.", AccrualLedgEntry."Source Document Line No.");
            SetRange("Accrual Plan No.", AccrualLedgEntry."Accrual Plan No.");
            exit(not IsEmpty);
        end;
    end;

    local procedure GetSalesDocPartialFactor(var AccrualLedgEntry: Record "Accrual Ledger Entry"): Decimal
    begin
        // P8001236
        with AccrualLedgEntry do
            exit(GetSalesDocPaidFactor("Source Document Type", "Source Document No.", true));
    end;

    local procedure IsSalesDocPaidInFull(var AccrualLedgEntry: Record "Accrual Ledger Entry"): Boolean
    begin
        // P8001236
        with AccrualLedgEntry do
            exit(GetSalesDocPaidFactor("Source Document Type", "Source Document No.", false) = 1);
    end;

    local procedure GetSalesDocPaidFactor(DocumentType: Option; DocumentNo: Code[20]; CalculatePartial: Boolean): Decimal
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        AccrualLedgEntry: Record "Accrual Ledger Entry";
    begin
        // P8001236
        if (DocumentType <> SalesDocPaidType) or (DocumentNo <> SalesDocPaidNo) or
           ((SalesDocCalculatePartial <> CalculatePartial) and CalculatePartial)
        then begin
            SalesDocPaidType := DocumentType;
            SalesDocPaidNo := DocumentNo;
            SalesDocCalculatePartial := CalculatePartial;
            SalesDocPaidFactor := CalcSalesDocPaidFactor(DocumentType, DocumentNo, CalculatePartial);
        end;
        exit(SalesDocPaidFactor);
    end;

    local procedure CalcSalesDocPaidFactor(DocumentType: Option; DocumentNo: Code[20]; CalculatePartial: Boolean): Decimal
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        AccrualLedgEntry: Record "Accrual Ledger Entry";
    begin
        // P8001236
        with CustLedgEntry do begin
            SetCurrentKey("Document No.");
            SetRange("Document No.", DocumentNo);
            if (DocumentType = AccrualLedgEntry."Source Document Type"::Invoice) then
                SetRange("Document Type", "Document Type"::Invoice)
            else
                SetRange("Document Type", "Document Type"::"Credit Memo");
            if FindFirst then begin
                if not Open then
                    exit(1);
                if CalculatePartial then begin
                    CalcFields(Amount);
                    if (Amount = 0) then
                        exit(1);
                    CalcFields("Remaining Amount");
                    exit(1 - "Remaining Amount" / Amount);
                end;
            end;
        end;
    end;

    procedure AdjustForPreviousPayments(var AccrualPlan: Record "Accrual Plan"; var AccrualJnlLine: Record "Accrual Journal Line")
    var
        PayPartial: Boolean;
    begin
        // P8001236
        // P8003887 - Changed parameter from Accrual Ledger Entry to Accrual Journal Line
        with AccrualJnlLine do begin  // P8003887
            case AccrualPlan."Payment Posting Level" of
                AccrualPlan."Payment Posting Level"::Plan:
                    Amount := Amount - AccrualPlan.GetPostedPaymentAmount('', 0, '', 0, Type, "No."); // P8003887
                AccrualPlan."Payment Posting Level"::Source:
                    Amount := Amount - AccrualPlan.GetPostedPaymentAmount("Source No.", 0, '', 0, Type, "No."); // P8003887
                AccrualPlan."Payment Posting Level"::Document:
                    Amount := Amount -
                      AccrualPlan.GetPostedPaymentAmount("Source No.", "Source Document Type", "Source Document No.", 0, Type, "No."); // P8003887
                AccrualPlan."Payment Posting Level"::"Document Line":
                    Amount := Amount -
                      AccrualPlan.GetPostedPaymentAmount(
                        "Source No.", "Source Document Type", "Source Document No.", "Source Document Line No.", Type, "No."); // P8003887
            end;
        end;
    end;
}

