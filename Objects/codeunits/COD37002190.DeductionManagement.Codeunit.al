codeunit 37002190 "Deduction Management"
{
    // PR3.70.08
    // P8000170A, Myers Nissi, Jack Reynolds, 31 JAN 05
    //   Deduction Management
    // 
    // PR3.70.09
    // P8000189A, Myers Nissi, Jack Reynolds, 22 FEB 05
    //   Summarize unallowed deductions by dimensions
    // 
    // P8000196A, Myers Nissi, Jack Reynolds, 01 MAR 05
    //   Delete functions were not setting ranges properly and deleting all deductions
    // 
    // P8000202A, Myers Nissi, Jack Reynolds, 07 MAR 05
    //   Fix posting deduction management applications so that any remaining amount is left with the payment
    // 
    // P8000204A, Myers Nissi, Jack Reynolds, 08 MAR 05
    //   Move Assigned To to posted deductions
    // 
    // PR3.70.10
    // P8000240A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Support for accrual plans as account number
    // 
    // PR4.00.01
    // P8000269A, VerticalSoft, Jack Reynolds, 07 DEC 05
    //   Copy comments to new customer ledger entries
    // 
    // P8000274A, VerticalSoft, Jack Reynolds, 22 DEC 05
    //   Fix problems with resolving start and end dates for accrual plan
    // 
    // PR4.00.05
    // P8000457A, VerticalSoft, Jack Reynolds, 16 MAR 07
    //   Fix problem setting global dimensions on customer and general ledger entries
    // 
    // PRW16.00.05
    // P8000920, Columbus IT, Jack Reynolds, 21 MAR 11
    //   Use transaction posting date instead of WORKDATE for deduction entries
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW18.00.02
    // P8002751, to-Increase, Jack Reynolds, 26 OCT 15
    //   Allow option to keep deductions with original customer
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 11 NOV 15
    //   Posting preview
    // 
    // PRW19.00.01
    // P8007339, To-Increase, Jack Reynolds, 30 JUN 16
    //   Fix dimension problem with overpayments
    // 
    // P8008391, To-Increase, Jack Reynolds, 08 Feb 17
    //   Allow unapplied deductions
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW110.0.01
    // P80041422, to-Increase, Jack Reynolds, 14 JUN 17
    //   Fix issue when applying deduction management payments
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // P80055396, To Increase, Jack Reynolds, 30 MAR 18
    //   Fix posting preview problem
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW113.00.03
    // P80085994, To Increase, Jack Reynolds, 20 NOV 19
    //   Fix dimension issues
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    EventSubscriberInstance = Manual;
    Permissions = TableData "Cust. Ledger Entry" = m;

    trigger OnRun()
    begin
        // P80055396
        LockTables;
        PostDeductions(PreviewPaymentEntry, PreviewDeductionLine, PreviewPostingDate);
    end;

    var
        Text001: Label 'must be negative';
        Text002: Label 'must be positive';
        Text003: Label 'Nothing to apply.';
        Text004: Label 'Under payment of %1 is not allowed.';
        SalesSetup: Record "Sales & Receivables Setup";
        SourceCodeSetup: Record "Source Code Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        Text005: Label 'Over Payment - %1';
        Text006: Label 'Unallowed Deductions';
        Text007: Label '%1 %2 is being processed through deduction management.';
        Text008: Label '%1 lines exist.';
        Text009: Label 'may not be %1';
        P800CoreFns: Codeunit "Process 800 Core Functions";
        PreviewMode: Boolean;
        PreviewPostingDate: Date;
        PreviewDeductionLine: Record "Deduction Line";
        Text010: Label 'Payments should not be applied to other payments.';
        PreviewPaymentEntry: Record "Cust. Ledger Entry";

    procedure TestCustLedgerAppliesTo(CustLedger: Record "Cust. Ledger Entry")
    var
        DeductionLine: Record "Deduction Line";
    begin
        DeductionLine.SetRange("Source Table No.", DATABASE::"Cust. Ledger Entry");
        DeductionLine.SetRange("Source Ref. No.", CustLedger."Entry No.");
        if DeductionLine.Find('-') then
            Error(Text007, CustLedger.TableCaption, CustLedger."Entry No.");

        DeductionLine.Reset;
        DeductionLine.SetRange("Applies-to Entry No.", CustLedger."Entry No.");
        if DeductionLine.Find('-') then
            Error(Text007, CustLedger.TableCaption, CustLedger."Entry No.");
    end;

    procedure ApplyFromCustomerLedger(CustLedger: Record "Cust. Ledger Entry")
    var
        DeductionLine: Record "Deduction Line";
    begin
        with CustLedger do begin
            TestField("Document Type", "Document Type"::Payment);
            TestField("Applies-to ID", '');
            if "Remaining Amount" >= 0 then
                FieldError("Remaining Amount", Text001);

            DeductionLine."Source Table No." := DATABASE::"Cust. Ledger Entry";
            DeductionLine."Source Ref. No." := "Entry No.";
            EnterApplication("Customer No.", "Remaining Amount", DeductionLine);
        end;
    end;

    procedure ApplyFromGenJnlLine(GenJnlLine: Record "Gen. Journal Line")
    var
        DeductionLine: Record "Deduction Line";
    begin
        with GenJnlLine do begin
            TestField("Document Type", "Document Type"::Payment);
            TestField("Account Type", "Account Type"::Customer);
            TestField("Account No.");
            TestField("Applies-to Doc. Type", 0);
            TestField("Applies-to Doc. No.", '');
            TestField("Applies-to ID", '');
            if Amount >= 0 then
                FieldError(Amount, Text001);

            DeductionLine."Source Table No." := DATABASE::"Gen. Journal Line";
            DeductionLine."Source ID" := "Journal Template Name";
            DeductionLine."Source Batch Name" := "Journal Batch Name";
            DeductionLine."Source Ref. No." := "Line No.";
            EnterApplication("Account No.", Amount, DeductionLine);
        end;
    end;

    procedure DeleteGenJnlLineDeductions(GenJnlLine: Record "Gen. Journal Line")
    var
        DeductionLine: Record "Deduction Line";
    begin
        // P8000196A Begin
        DeductionLine.SetRange("Source Table No.", DATABASE::"Gen. Journal Line");
        DeductionLine.SetRange("Source ID", GenJnlLine."Journal Template Name");
        DeductionLine.SetRange("Source Batch Name", GenJnlLine."Journal Batch Name");
        DeductionLine.SetRange("Source Ref. No.", GenJnlLine."Line No.");
        DeductionLine.DeleteAll(true);
        // P8000196A End
    end;

    procedure EnterApplication(CustNo: Code[20]; Amount: Decimal; DeductionLine: Record "Deduction Line")
    var
        ApplicationForm: Page "Payment Application-Ded. Mgt.";
    begin
        ApplicationForm.SetParameters(CustNo, Amount, DeductionLine);
        ApplicationForm.RunModal;
    end;

    procedure AmountApplied(SourceTable: Integer; SourceID: Code[20]; SourceBatch: Code[10]; SourceRef: Integer; PostingDate: Date) AmtApplied: Decimal
    var
        DeductionLine: Record "Deduction Line";
        CustLedger: Record "Cust. Ledger Entry";
        AmtToApply: Decimal;
    begin
        // P8000920 - Add parameter for posting date
        DeductionLine.SetCurrentKey("Source Table No.", "Source ID", "Source Batch Name", "Source Ref. No.", Type, "Line No.");
        DeductionLine.SetRange("Source Table No.", SourceTable);
        DeductionLine.SetRange("Source ID", SourceID);
        DeductionLine.SetRange("Source Batch Name", SourceBatch);
        DeductionLine.SetRange("Source Ref. No.", SourceRef);
        DeductionLine.SetRange(Type, DeductionLine.Type::Application);
        if DeductionLine.Find('-') then
            repeat
                CustLedger.Get(DeductionLine."Applies-to Entry No.");
                AmtToApply := CustLedger.AmountWithDiscount(PostingDate); // P8000920
                if AmtToApply <> 0 then
                    AmtApplied += AmtToApply;
            until DeductionLine.Next = 0;

        DeductionLine.SetRange(Type, DeductionLine.Type::Deduction);
        DeductionLine.CalcSums(Amount);
        AmtApplied -= DeductionLine.Amount;
    end;

    procedure PostDeductions(PaymentEntry: Record "Cust. Ledger Entry"; var DeductionLine: Record "Deduction Line"; PostingDate: Date)
    var
        CustLedger: Record "Cust. Ledger Entry";
        UnallowedBuffer: Record "Deduction Line" temporary;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        DocNo: Code[20];
        Remainder: Decimal;
        PostDate: Date;
    begin
        // P8000920 - Add parameter for posting date
        SalesSetup.Get;
        SourceCodeSetup.Get;

        PaymentEntry.Find('=');
        PaymentEntry.CalcFields("Remaining Amount");
        Remainder := PaymentEntry."Remaining Amount";

        CheckDeductions(PaymentEntry, DeductionLine, PostingDate); // P8000920

        DocNo := NoSeriesMgt.GetNextNo(SalesSetup."Deduction Management Doc. Nos.", PostingDate, true); // P8000920
        // Create deduction entries for customer and mark entries for application
        if DeductionLine.Find('-') then
            repeat
                case DeductionLine.Type of
                    DeductionLine.Type::Application:
                        begin
                            CustLedger.Get(DeductionLine."Applies-to Entry No.");
                            CustLedger."Applies-to ID" := DocNo;
                            CustLedger."Amount to Apply" := CustLedger.AmountWithDiscount(PostingDate); // PR4.00, P8000920
                            CustLedger.Modify;
                            Remainder += CustLedger."Amount to Apply"; // PR4.00
                            if DeductionLine.Amount < 0 then begin
                                Remainder -= DeductionLine.Amount;
                                DeductionLine.Description := StrSubstNo(Text005, DeductionLine.RelatedDocumentNo);
                                CreateDeductionEntry(DocNo, PaymentEntry."Customer No.", PaymentEntry, DeductionLine, PostingDate, false); // P8000920, P8002751
                                CustLedger.Get(DeductionLine."Applies-to Entry No.");
                                CustLedger."Applies-to ID" := DocNo;
                                CustLedger."Amount to Apply" := -DeductionLine.Amount; // PR4.00
                                CustLedger.Modify;
                                DeductionLine.Amount := -DeductionLine.Amount;
                                DeductionLine.Description := PaymentEntry.Description;
                                CreateDeductionEntry(PaymentEntry."Document No.", PaymentEntry."Customer No.", PaymentEntry, DeductionLine,
                                  PostingDate, false); // P8000920, P8002751
                            end;
                        end;
                    DeductionLine.Type::Deduction:
                        begin
                            //CustLedger.GET(DeductionLine."Applies-to Entry No."); // P8002751, P8008391
                            if DeductionLine.Allowed then begin
                                CreateDeductionEntry(DocNo, PaymentEntry."Customer No.", PaymentEntry, DeductionLine, PostingDate, false); // P8000920, P8002751
                                CustLedger.Get(DeductionLine."Applies-to Entry No.");
                                CustLedger."Applies-to ID" := DocNo;
                                CustLedger."Amount to Apply" := -DeductionLine.Amount; // PR4.00
                                CustLedger.Modify;
                            end else begin // // P8000189A
                                           // P8000189A Begin
                                           // P8002751
                                if SalesSetup."Deduction Management Cust. No." = '' then begin // P8008391
                                    CustLedger.Get(DeductionLine."Applies-to Entry No."); // P8002751, P8008391
                                    PostDate := CustLedger."Posting Date";
                                end else //P8008391
                                    PostDate := PostingDate;
                                // P8002751
                                UnallowedBuffer.SetRange("Dimension Set ID", DeductionLine."Dimension Set ID"); // P8001133
                                UnallowedBuffer.SetRange(Date, PostDate); // P8002751
                                if UnallowedBuffer.Find('-') then begin
                                    UnallowedBuffer.Amount += DeductionLine.Amount;
                                    UnallowedBuffer.Modify;
                                end else begin
                                    UnallowedBuffer := DeductionLine;
                                    UnallowedBuffer.Date := PostDate; // P8002751
                                                                      //UnallowedBuffer."Dimension Entry No." := DimEntryNo; // P8001133
                                    UnallowedBuffer.Insert;
                                end;
                            end;
                            // P8000189A End
                            Remainder -= DeductionLine.Amount;
                        end;
                    DeductionLine.Type::Remainder:
                        if (DeductionLine."Remainder Applied to" = DeductionLine."Remainder Applied to"::"Ded. Mgt.") and
                          (Remainder < 0)
                        then begin
                            // P8002751
                            if SalesSetup."Deduction Management Cust. No." = '' then
                                PostDate := PaymentEntry."Posting Date"
                            else
                                PostDate := PostingDate;
                            // P8002751
                            DeductionLine.Amount := Remainder;
                            DeductionLine.Description := StrSubstNo(Text005, PaymentEntry."Document No.");
                            CreateDeductionEntry(DocNo, PaymentEntry."Customer No.", PaymentEntry, DeductionLine, PostDate, false); // P8000920, P8002751
                            CustLedger.Get(DeductionLine."Applies-to Entry No.");
                            CustLedger."Applies-to ID" := DocNo;
                            CustLedger."Amount to Apply" := -DeductionLine.Amount; // PR4.00
                            CustLedger.Modify;
                        end;
                end;
            until DeductionLine.Next = 0;
        // P8000189A Begin
        UnallowedBuffer.Reset;
        UnallowedBuffer.SetFilter(Amount, '<>0');
        if UnallowedBuffer.Find('-') then
            repeat
                UnallowedBuffer.Description := Text006;
                CreateDeductionEntry(DocNo, PaymentEntry."Customer No.", PaymentEntry, UnallowedBuffer, UnallowedBuffer.Date, false); // P8000920, P8002751
                CustLedger.Get(UnallowedBuffer."Applies-to Entry No.");
                CustLedger."Applies-to ID" := DocNo;
                CustLedger."Amount to Apply" := -UnallowedBuffer.Amount; // PR4.00
                CustLedger.Modify;
            until UnallowedBuffer.Next = 0;
        // P8000189A End

        PostApplication(PaymentEntry, DocNo, PostingDate); // P8000920

        // Create deduction management entries for unallowed deductions
        DeductionLine.SetRange(Type, DeductionLine.Type::Deduction, DeductionLine.Type::Remainder);
        if DeductionLine.Find('-') then
            repeat
                case DeductionLine.Type of
                    DeductionLine.Type::Deduction:
                        if not DeductionLine.Allowed then begin
                            // P8002751
                            if not CustLedger.Get(DeductionLine."Applies-to Entry No.") then // P8008391
                                Clear(CustLedger);                                             // P8008391
                            if SalesSetup."Deduction Management Cust. No." = '' then
                                if CustLedger."Entry No." <> 0 then // P8008391
                                    PostDate := CustLedger."Posting Date"
                                else
                                    PostDate := PostingDate;
                            if CustLedger."Entry No." <> 0 then // P8008391
                                if CustLedger."Document Type" = 0 then
                                    DeductionLine.Description := CustLedger."Document No."
                                else
                                    DeductionLine.Description := StrSubstNo('%1 %2', CustLedger."Document Type", CustLedger."Document No.");
                            // P8002751
                            DeductionLine.Amount := -DeductionLine.Amount;
                            CreateDeductionEntry(DocNo, SalesSetup."Deduction Management Cust. No.", PaymentEntry, DeductionLine,
                              PostDate, true); // P8000920, P8002751
                        end;
                    DeductionLine.Type::Remainder:
                        if (DeductionLine."Remainder Applied to" = DeductionLine."Remainder Applied to"::"Ded. Mgt.") and
                          (Remainder < 0)
                        then begin
                            // P8002751
                            if SalesSetup."Deduction Management Cust. No." = '' then
                                PostDate := PaymentEntry."Posting Date"
                            else
                                PostDate := PostingDate;
                            // P8002751
                            DeductionLine.Amount := -Remainder;
                            DeductionLine.Description := StrSubstNo(Text005, PaymentEntry."Document No.");
                            DeductionLine."Applies-to Entry No." := PaymentEntry."Entry No.";
                            CreateDeductionEntry(DocNo, SalesSetup."Deduction Management Cust. No.", PaymentEntry, DeductionLine,
                              PostDate, true); // P8000920, P8002751
                        end;
                end;
            until DeductionLine.Next = 0;

        if PreviewMode then             // P8004516
            GenJnlPostPreview.ThrowError; // P8004516, P8007748

        DeductionLine.SetRange(Type);
        DeductionLine.DeleteAll(true);
    end;

    procedure CheckDeductions(PaymentEntry: Record "Cust. Ledger Entry"; var DeductionLine: Record "Deduction Line"; PostingDate: Date)
    var
        CustLedger: Record "Cust. Ledger Entry";
        NoOfEntries: Integer;
        Remainder: Decimal;
    begin
        // P8000920 - Add parameter for posting date
        PaymentEntry.TestField("Document Type", PaymentEntry."Document Type"::Payment);
        PaymentEntry.CalcFields("Remaining Amount");
        if PaymentEntry."Remaining Amount" >= 0 then
            PaymentEntry.FieldError("Remaining Amount", Text001);
        Remainder := PaymentEntry."Remaining Amount";

        if DeductionLine.Find('-') then
            repeat
                case DeductionLine.Type of
                    DeductionLine.Type::Application:
                        begin
                            CustLedger.Get(DeductionLine."Applies-to Entry No.");
                            Remainder += CustLedger.AmountWithDiscount(PostingDate); // P8000920
                            if (not CustLedger.Positive) or (DeductionLine.Amount < 0) then
                                Remainder -= DeductionLine.Amount;
                            NoOfEntries += 1;
                        end;
                    DeductionLine.Type::Deduction:
                        begin
                            DeductionLine.TestField(Amount);
                            if DeductionLine.Allowed then
                                DeductionLine.TestField("Account No.");
                            Remainder -= DeductionLine.Amount;
                            NoOfEntries += 1;
                        end;
                end;
            until DeductionLine.Next = 0;

        if 0 = NoOfEntries then
            Error(Text003);
        if Remainder > 0 then
            Error(Text004, Format(Remainder, 0, '<Precision,2:2><Standard Format,0>'));
    end;

    local procedure CreateDeductionEntry(DocNo: Code[20]; CustNo: Code[20]; PaymentEntry: Record "Cust. Ledger Entry"; var DeductionLine: Record "Deduction Line"; PostingDate: Date; Unresolved: Boolean)
    var
        GenJnlLine: Record "Gen. Journal Line";
        CustLedger: Record "Cust. Ledger Entry";
        AccrualPlan: Record "Accrual Plan";
    begin
        // P8000920 - Add parameter for posting date
        // P8002751 - add parameter - Unresolved
        // P8002751
        if CustNo = '' then
            CustNo := PaymentEntry."Customer No.";
        // P8002751
        with GenJnlLine do begin
            if DeductionLine."Applies-to Entry No." <> 0 then
                CustLedger.Get(DeductionLine."Applies-to Entry No.");
            Validate("Posting Date", PostingDate); // P8000920
                                                   // P80085994
            case DeductionLine.Type of
                DeductionLine.Type::Application:
                    if CustLedger.Positive and (DeductionLine.Amount > 0) then
                        Validate("Document Type", "Document Type"::Payment);
                DeductionLine.Type::Remainder:
                    if DeductionLine.Amount > 0 then
                        Validate("Document Type", "Document Type"::Payment);
            end;
            // P80085994
            Validate("Document No.", DocNo);
            Validate("Account Type", "Account Type"::Customer);
            Validate("Account No.", CustNo);
            Description := DeductionLine.Description;
            Validate(Amount, -DeductionLine.Amount);
            if DeductionLine.Allowed then begin
                // P8000240A Begin
                case DeductionLine."Deduction Type" of
                    DeductionLine."Deduction Type"::Writeoff:
                        begin
                            Validate("Bal. Account Type", "Bal. Account Type"::"G/L Account");
                            Validate("Bal. Account No.", DeductionLine."Account No.");
                        end;
                    DeductionLine."Deduction Type"::"Accrual Plan":
                        begin
                            AccrualPlan.Get(AccrualPlan.Type::Sales, DeductionLine."Account No.");
                            GenJnlLine.Validate("Accrual Entry Type", GenJnlLine."Accrual Entry Type"::Payment);
                            Validate("Bal. Account Type", "Bal. Account Type"::FOODAccrualPlan);
                            Validate("Bal. Account No.", DeductionLine."Account No.");
                            if AccrualPlan."Payment Posting Level" = AccrualPlan."Payment Posting Level"::Source then
                                GenJnlLine.Validate("Accrual Source No.", CustNo);
                        end;
                end;
                // P8000240A End
            end;
            GenJnlLine.Validate("Bal. Gen. Posting Type", GenJnlLine."Bal. Gen. Posting Type"::" ");
            GenJnlLine.Validate("Bal. Gen. Bus. Posting Group", '');
            GenJnlLine.Validate("Bal. Gen. Prod. Posting Group", '');
            GenJnlLine.Validate("Source Code", SourceCodeSetup."Deduction Management");
            GenJnlLine.Validate("Reason Code", DeductionLine."Reason Code");
            // P8007339
            //  GenJnlLine."Shortcut Dimension 1 Code" := DeductionLine."Shortcut Dimension 1 Code"; // P8000457A
            //  GenJnlLine."Shortcut Dimension 2 Code" := DeductionLine."Shortcut Dimension 2 Code"; // P8000457A
            //  GenJnlLine."Dimension Set ID" := DeductionLine."Dimension Set ID"; // P8001133
            // P8007339
            // P80085994
            case DeductionLine.Type of
                DeductionLine.Type::Application:
                    begin
                        "Shortcut Dimension 1 Code" := PaymentEntry."Global Dimension 1 Code"; // P8007339
                        "Shortcut Dimension 2 Code" := PaymentEntry."Global Dimension 2 Code"; // P8007339
                        "Dimension Set ID" := PaymentEntry."Dimension Set ID"; // P8001133
                    end;
                DeductionLine.Type::Deduction:
                    begin
                        "Shortcut Dimension 1 Code" := DeductionLine."Shortcut Dimension 1 Code"; // P8007339
                        "Shortcut Dimension 2 Code" := DeductionLine."Shortcut Dimension 2 Code"; // P8007339
                        "Dimension Set ID" := DeductionLine."Dimension Set ID"; // P8001133
                        if (DeductionLine."Applies-to Entry No." <> 0) and (DeductionLine.Amount < 0) then begin
                            if CustLedger."Original Entry No." <> 0 then
                                GenJnlLine."Original Entry No." := CustLedger."Original Entry No."
                            else
                                GenJnlLine."Original Entry No." := DeductionLine."Applies-to Entry No.";
                        end;
                    end;
                DeductionLine.Type::Remainder:
                    begin
                        "Shortcut Dimension 1 Code" := PaymentEntry."Global Dimension 1 Code"; // P8007339
                        "Shortcut Dimension 2 Code" := PaymentEntry."Global Dimension 2 Code"; // P8007339
                        "Dimension Set ID" := PaymentEntry."Dimension Set ID"; // P8001133
                        if DeductionLine.Amount > 0 then
                            GenJnlLine."Original Entry No." := DeductionLine."Applies-to Entry No.";
                    end;
            end;
            // P80085994
            GenJnlLine."Deduction Management Entry" := true;
            GenJnlLine."Assigned To" := DeductionLine."Assigned To"; // P8000204A
            GenJnlLine."Deduction Type" := DeductionLine."Deduction Type";
            if Unresolved then // P8002751
                GenJnlLine."Original Customer No." := DeductionLine."Customer No.";
            GenJnlPostLine.RunWithCheck(GenJnlLine); // P8001133

            CustLedger.Find('+');
            // P8002751
            if Unresolved then begin
                CustLedger."Unresolved Deduction" := true;
                CustLedger.Modify;
            end;
            // P8002751
            // P8000269A
            if DeductionLine.Type = DeductionLine.Type::Deduction then begin
                P800CoreFns.CopyLedgerComments(DATABASE::"Cust. Ledger Entry", PaymentEntry."Entry No.",
                  DATABASE::"Cust. Ledger Entry", CustLedger."Entry No.");
                P800CoreFns.CopyLedgerComments(DATABASE::"Cust. Ledger Entry", DeductionLine."Applies-to Entry No.",
                  DATABASE::"Cust. Ledger Entry", CustLedger."Entry No.");
                DeductionLine.CopyCommentsToLedger(DATABASE::"Cust. Ledger Entry", CustLedger."Entry No.");
            end;
            // P8000269A
            DeductionLine."Applies-to Entry No." := CustLedger."Entry No.";
        end;
    end;

    local procedure PostApplication(var CustLedger: Record "Cust. Ledger Entry"; AppliesToID: Code[20]; PostingDate: Date)
    var
        GenJnlLine: Record "Gen. Journal Line";
        EntryNoBefore: Integer;
        EntryNoAfter: Integer;
    begin
        // P8000920 - Add parameter for posting date
        CustLedger.CalcFields("Remaining Amount");                     // PR4.00
        CustLedger."Amount to Apply" := CustLedger."Remaining Amount"; // PR4.00

        GenJnlLine."Document No." := AppliesToID;
        GenJnlLine."Posting Date" := PostingDate; // P8000920
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine."Account No." := CustLedger."Customer No.";
        GenJnlLine."Document Type" := CustLedger."Document Type";
        GenJnlLine.Description := CustLedger.Description;
        GenJnlLine."Shortcut Dimension 1 Code" := CustLedger."Global Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := CustLedger."Global Dimension 2 Code";
        GenJnlLine."Dimension Set ID" := CustLedger."Dimension Set ID"; // P8001133
        GenJnlLine."Posting Group" := CustLedger."Customer Posting Group";
        GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
        GenJnlLine."Source No." := CustLedger."Customer No.";
        GenJnlLine."Source Code" := SourceCodeSetup."Deduction Management";
        GenJnlLine."System-Created Entry" := true;

        EntryNoBefore := FindLastApplDtldCustLedgEntry; // P80041422

        CustLedger."Applies-to ID" := AppliesToID;
        GenJnlPostLine.SetPostDeductionApplication; // P8000202A
        GenJnlPostLine.CustPostApplyCustLedgEntry(GenJnlLine, CustLedger);

        // P80041422
        EntryNoAfter := FindLastApplDtldCustLedgEntry;
        if EntryNoBefore = EntryNoAfter then
            Error(Text010);
        // P80041422
    end;

    local procedure FindLastApplDtldCustLedgEntry(): Integer
    var
        DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        // P80041422
        DtldCustLedgEntry.LockTable;
        if DtldCustLedgEntry.FindLast then
            exit(DtldCustLedgEntry."Entry No.");

        exit(0);
    end;

    procedure LockTables()
    var
        GLEntry: Record "G/L Entry";
        GLReg: Record "G/L Register";
        DtlCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        CustLedgEntrey: Record "Cust. Ledger Entry";
    begin
        GLEntry.LockTable;
        GLReg.LockTable;
        DtlCustLedgEntry.LockTable;
        CustLedgEntrey.LockTable;
        if GLEntry.Find('+') then;
        if GLReg.Find('+') then;
        if DtlCustLedgEntry.Find('+') then;
        if CustLedgEntrey.Find('+') then;
    end;

    procedure CheckAccrualPlan(CustNo: Code[20]; PlanNo: Code[20])
    var
        AccrualPlan: Record "Accrual Plan";
    begin
        // P8000240A
        if PlanNo = '' then
            exit;

        AccrualPlan.Get(AccrualPlan.Type::Sales, PlanNo);
        AccrualPlan.TestField("Use Payment Schedule", false);
        if AccrualPlan."Payment Posting Level" > AccrualPlan."Payment Posting Level"::Source then
            AccrualPlan.FieldError("Payment Posting Level", StrSubstNo(Text009, AccrualPlan."Payment Posting Level"));
        case AccrualPlan."Payment Type" of
            AccrualPlan."Payment Type"::"Source Bill-to/Pay-to":
                if not AccrualPlan.IsSourceInPlan(CustNo, CustNo, 0D) then // P8000274A
                    Error('Customer %1 is not in %2 %3.', CustNo, AccrualPlan.TableCaption, AccrualPlan."No.");
            AccrualPlan."Payment Type"::Customer:
                AccrualPlan.TestField("Payment Code", CustNo);
            else
                AccrualPlan.FieldError("Payment Type", StrSubstNo(Text009, AccrualPlan."Payment Type"));
        end;
    end;

    procedure AcctNoLookup(DedType: Option ,Writeoff,"Accrual Plan"; CustNo: Code[20]; var Text: Text[1024]): Boolean
    var
        GLAccount: Record "G/L Account";
        AccrualPlan: Record "Accrual Plan";
        TempAccrualPlan: Record "Accrual Plan" temporary;
        AcctList: Page "G/L Account List";
        AccrualList: Page "Accrual Plan List";
    begin
        // P8000240A
        case DedType of
            DedType::Writeoff:
                begin
                    AcctList.SetTableView(GLAccount);
                    if GLAccount.Get(Text) then
                        AcctList.SetRecord(GLAccount);
                    AcctList.LookupMode := true;
                    if AcctList.RunModal <> ACTION::LookupOK then
                        exit(false);
                    AcctList.GetRecord(GLAccount);
                    Text := GLAccount."No.";
                    exit(true);
                end;

            DedType::"Accrual Plan":
                begin
                    AccrualPlan.FilterGroup(9);
                    AccrualPlan.SetRange(Type, AccrualPlan.Type::Sales);
                    AccrualPlan.SetRange("Use Payment Schedule", false);
                    AccrualPlan.SetRange("Payment Posting Level", 0, AccrualPlan."Payment Posting Level"::Source);
                    AccrualPlan.SetFilter("Payment Type", '%1|%2',
                      AccrualPlan."Payment Type"::"Source Bill-to/Pay-to", AccrualPlan."Payment Type"::Customer);
                    AccrualPlan.FilterGroup(0);

                    AccrualPlan.SetRange("Payment Type", AccrualPlan."Payment Type"::Customer);
                    AccrualPlan.SetRange("Payment Code", CustNo);
                    if AccrualPlan.Find('-') then
                        repeat
                            AccrualPlan.Mark(true);
                        until AccrualPlan.Next = 0;

                    AccrualPlan.SetRange("Payment Type", AccrualPlan."Payment Type"::"Source Bill-to/Pay-to");
                    AccrualPlan.SetRange("Payment Code");
                    if AccrualPlan.Find('-') then
                        repeat
                            AccrualPlan.Mark(AccrualPlan.IsSourceInPlan(CustNo, CustNo, 0D)); // P8000274A
                        until AccrualPlan.Next = 0;

                    AccrualPlan.SetRange("Payment Type");
                    AccrualPlan.MarkedOnly(true);

                    AccrualList.SetTableView(AccrualPlan);
                    if AccrualPlan.Get(AccrualPlan.Type::Sales, Text) and AccrualPlan.Mark then
                        AccrualList.SetRecord(AccrualPlan);
                    AccrualList.LookupMode := true;
                    if AccrualList.RunModal <> ACTION::LookupOK then
                        exit(false);
                    AccrualList.GetRecord(AccrualPlan);
                    Text := AccrualPlan."No.";
                    exit(true);
                end;
        end;
    end;

    procedure PreviewPostDeductions(PaymentEntry: Record "Cust. Ledger Entry"; var DeductionLine: Record "Deduction Line"; PostingDate: Date)
    var
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        DeductionManagement: Codeunit "Deduction Management";
    begin
        // P8007748
        DeductionManagement.SetPreviewMode(PaymentEntry, DeductionLine, PostingDate); // P80055396
        BindSubscription(DeductionManagement);
        GenJnlPostPreview.Preview(DeductionManagement, PaymentEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnRunPreview', '', true, false)]
    local procedure GenJnlPostPreview_OnRunPreview(var Result: Boolean; Subscriber: Variant; RecVar: Variant)
    var
        DeductionManagement: Codeunit "Deduction Management";
    begin
        // P8007748
        DeductionManagement := Subscriber;
        // PaymentEntry.COPY(RecVar); // P80055396
        Result := DeductionManagement.Run; // P80055396
    end;

    procedure SetPreviewMode(var PaymentEntry: Record "Cust. Ledger Entry"; var DeductionLine: Record "Deduction Line"; PostingDate: Date)
    begin
        // P8007748
        // P80055396 - add parameter for PaymentEntry
        PreviewMode := true;
        PreviewPaymentEntry.Copy(PaymentEntry); // P80055396
        PreviewDeductionLine.Copy(DeductionLine);
        PreviewPostingDate := PostingDate;
    end;
}

