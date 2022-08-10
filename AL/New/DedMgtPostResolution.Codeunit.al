codeunit 37002191 "Ded. Mgt. - Post Resolution"
{
    // PR3.70.08
    // P8000170A, Myers Nissi, Jack Reynolds, 31 JAN 05
    //   Deduction Management
    // 
    // PR3.70.09
    // P8000190A, Myers Nissi, Jack Reynolds, 22 FEB 05
    //   COMMIT at end of OnRun so each run is a completed transaction
    // 
    // PR3.70.10
    // P8000240A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Support for accrual plans as account number
    // 
    // PR4.00.01
    // P8000269A, VerticalSoft, Jack Reynolds, 07 DEC 05
    //   Copy comments to new customer ledger entries
    // 
    // PR4.00.04
    // P8000393A, VerticalSoft, Jack Reynolds, 29 SEP 06
    //   Fix problem with missing dimensions posting resolutions
    // 
    // PR4.00.05
    // P8000457A, VerticalSoft, Jack Reynolds, 16 MAR 07
    //   Fix problem setting global dimensions on customer and general ledger entries
    // 
    // PRW16.00.04
    // P8000897, VerticalSoft, Jack Reynolds, 22 JAN 11
    //   Fix spelling mistake
    // 
    // PRW16.00.06
    // P8001066, Columbus IT, Jack Reynolds, 02 MAY 12
    //   Fix problem with missing global dimensions
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW18.00.02
    // P8002752, to-Increase, Jack Reynolds, 26 OCT 15
    //   Allow option to keep deductions with original customer
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 11 NOV 15
    //   Posting preview
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    EventSubscriberInstance = Manual;
    Permissions = TableData "Cust. Ledger Entry" = m;
    TableNo = "Cust. Ledger Entry";

    trigger OnRun()
    begin
        // P8004516
        CustLedgerEntry.Copy(Rec);
        Code;
        Rec := CustLedgerEntry;
    end;

    var
        Text001: Label 'Total resolution cannot exceed remaining amount of the deduction.';
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesSetup: Record "Sales & Receivables Setup";
        SourceCodeSetup: Record "Source Code Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        P800CoreFns: Codeunit "Process 800 Core Functions";
        Text002: Label 'Deduction %1 returned to original customer';
        PreviewMode: Boolean;

    local procedure "Code"()
    var
        CustLedger: Record "Cust. Ledger Entry";
        ReturnEntry: array[2] of Record "Cust. Ledger Entry";
        DeductionRes: Record "Deduction Resolution";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        TotalAmount: Decimal;
        DocNo: Code[20];
        ReturnAmount: array[2] of Decimal;
        ReturnDate: array[2] of Date;
        ReturnApplication: array[2] of Boolean;
        ClearRemaining: Boolean;
        i: Integer;
    begin
        // P8004516
        with CustLedgerEntry do begin
            LockTables; // P8000190A

            DeductionRes.SetRange("Entry No.", "Entry No.");
            DeductionRes.Find('-');
            repeat
                DeductionRes.TestField(Type);
                if DeductionRes.Type = DeductionRes.Type::Return then
                    DeductionRes.TestField("Resolve With Original Customer", true)
                else
                    if DeductionRes.Type <> DeductionRes.Type::Clear then // P8002752
                        DeductionRes.TestField("Account No.");
                DeductionRes.TestField(Amount);
                TotalAmount += DeductionRes.Amount;
            until DeductionRes.Next = 0;
            CalcFields("Remaining Amount");
            if Abs(TotalAmount) > Abs("Remaining Amount") then
                Error(Text001);

            SalesSetup.Get;
            SourceCodeSetup.Get;
            ClearRemaining := (SalesSetup."Deduction Management Cust. No." = '') and ("Remaining Amount" = TotalAmount); // P8002752

            DocNo := NoSeriesMgt.GetNextNo(SalesSetup."Deduction Management Doc. Nos.", WorkDate, true);

            DeductionRes.Find('-');
            repeat
                if (SalesSetup."Deduction Management Cust. No." <> '') and DeductionRes."Resolve With Original Customer" then begin // P8002752
                    if DeductionRes."Use Original Date" then
                        i := 1                                              // P8000269A
                    else
                        i := 2;                                             // P8000269A
                    ReturnAmount[i] += DeductionRes.Amount;               // P8000269A
                                                                          //IF DeductionRes.Type = DeductionRes.Type::Return THEN // P8000269A, P8001066
                                                                          //  ReturnRes[i] := DeductionRes;                       // P8000269A, P8001066
                end else
                    if DeductionRes.Type = DeductionRes.Type::Clear then begin // P8002752
                        ReturnAmount[1] += DeductionRes.Amount;                           // P8002752
                    end else begin
                        CreateResolutionEntry(DocNo, "Customer No.", WorkDate, CustLedgerEntry, DeductionRes); // P8004516
                        CustLedger.Get(DeductionRes."Customer Ledger Entry No.");
                        CustLedger."Applies-to ID" := DocNo;
                        CustLedger."Amount to Apply" := -DeductionRes.Amount; // PR4.00
                        CustLedger.Modify;
                    end;
            until DeductionRes.Next = 0;

            if (ReturnAmount[1] <> 0) or (ReturnAmount[2] <> 0) then begin
                if "Original Entry No." <> 0 then begin
                    CustLedger.Get("Original Entry No.");
                    ReturnDate[1] := CustLedger."Posting Date";
                end else
                    ReturnDate[1] := "Posting Date";
                ReturnDate[2] := WorkDate;
                if ReturnDate[1] = ReturnDate[2] then begin
                    ReturnAmount[1] += ReturnAmount[2];
                    ReturnAmount[2] := 0;
                    //IF ReturnRes[2]."Entry No." <> 0 THEN // P8000269A, P8001066
                    //  ReturnRes[1] := ReturnRes[2];       // P8000269A, P8001066
                end;
                if not ClearRemaining then // P8002752
                    for i := 1 to 2 do begin
                        if ReturnAmount[i] <> 0 then begin // P8001066 - moved up from below
                            DeductionRes.Init;
                            DeductionRes.Type := DeductionRes.Type::Return;
                            DeductionRes.Description := Description;
                            //IF "Original Entry No." <> 0 THEN                     // P8002752
                            //  DeductionRes.Description := CustLedger.Description; // P8002752
                            DeductionRes."Shortcut Dimension 1 Code" := "Global Dimension 1 Code"; // P8001066
                            DeductionRes."Shortcut Dimension 2 Code" := "Global Dimension 2 Code"; // P8001066
                            DeductionRes."Dimension Set ID" := "Dimension Set ID"; // P8001133
                            DeductionRes.Amount := ReturnAmount[i];
                            CreateResolutionEntry(DocNo, "Customer No.", ReturnDate[i], CustLedgerEntry, DeductionRes); // P8004516
                            CustLedger.Get(DeductionRes."Customer Ledger Entry No.");
                            CustLedger."Applies-to ID" := DocNo;
                            CustLedger."Amount to Apply" := -DeductionRes.Amount; // PR4.00
                            CustLedger.Modify;

                            // P8001066
                            DeductionRes.Amount := -ReturnAmount[i];
                            CreateResolutionEntry(DocNo, "Original Customer No.", ReturnDate[i], CustLedgerEntry, DeductionRes); // P8004516
                            ReturnEntry[i].Get(DeductionRes."Customer Ledger Entry No.");
                            // P8001066
                        end;
                    end;
            end;

            PostApplication(CustLedgerEntry, DocNo); // P8004516

            // P8001066
            //IF (ReturnAmount[1] <> 0) OR (ReturnAmount[2] <> 0) THEN BEGIN
            //  FOR i := 1 TO 2 DO
            //    IF ReturnAmount[i] <> 0 THEN BEGIN
            //      DeductionRes := ReturnRes[i]; // P8000269A
            //      DeductionRes.Amount := -ReturnAmount[i];
            //      CreateResolutionEntry(DocNo,"Original Customer No.",ReturnDate[i],Rec,DeductionRes);
            //      ReturnEntry[i].GET(DeductionRes."Customer Ledger Entry No.");
            //    END;
            //END;
            // P8001066

            DeductionRes.SetRange("Resolve With Original Customer", true);
            DeductionRes.SetFilter(Type, '<>%1&<>%2', DeductionRes.Type::Return, DeductionRes.Type::Clear); // P8002752
            if DeductionRes.Find('-') then begin
                repeat
                    DeductionRes.Amount := DeductionRes.Amount;
                    CreateResolutionEntry(DocNo, "Original Customer No.", WorkDate, CustLedgerEntry, DeductionRes); // P8004516
                    CustLedger.Get(DeductionRes."Customer Ledger Entry No.");
                    if DeductionRes."Use Original Date" then begin
                        ReturnApplication[1] := true;
                        CustLedger."Applies-to ID" := DocNo + '1';
                    end else begin
                        ReturnApplication[2] := true;
                        CustLedger."Applies-to ID" := DocNo + '2';
                    end;
                    CustLedger."Amount to Apply" := -DeductionRes.Amount; // PR4.00
                    CustLedger.Modify;
                until DeductionRes.Next = 0;
                for i := 1 to 2 do
                    if ReturnApplication[i] then
                        PostApplication(ReturnEntry[i], DocNo + Format(i));
            end;

            // P8002752
            Get("Entry No.");
            if (not Open) or ClearRemaining then begin
                "Unresolved Deduction" := false;
                Modify;
            end;
            // P8002752

            if not PreviewMode then begin // P8004516
                DeductionRes.Reset;
                DeductionRes.SetRange("Entry No.", "Entry No.");
                DeductionRes.DeleteAll(true);
            end else                         // P8004516
                GenJnlPostPreview.ThrowError; // P8004516, P8007748

            Commit; // P8000190A
        end;
    end;

    local procedure CreateResolutionEntry(DocNo: Code[20]; CustNo: Code[20]; PostingDate: Date; var DeductionEntry: Record "Cust. Ledger Entry"; var DeductionRes: Record "Deduction Resolution")
    var
        GenJnlLine: Record "Gen. Journal Line";
        CustLedger: Record "Cust. Ledger Entry";
        AccrualPlan: Record "Accrual Plan";
        LedgerComment: Record "Ledger Entry Comment Line";
        DimMgt: Codeunit DimensionManagement;
        DimensionSetID: Integer;
    begin
        with GenJnlLine do begin
            Validate("Posting Date", PostingDate);
            if DeductionRes.Type = DeductionRes.Type::Return then begin
                DimensionSetID := DeductionEntry."Dimension Set ID"; // P8001133
                if CustNo = DeductionEntry."Original Customer No." then begin
                    DeductionEntry.CalcFields("Original Document Type", "Original Document No.");
                    if DeductionEntry."Original Document Type" = DeductionEntry."Original Document Type"::Payment then
                        Validate("Document Type", DeductionEntry."Original Document Type");
                    "Original Entry No." := DeductionEntry."Original Entry No.";
                end;
            end else
                DimensionSetID := DeductionRes."Dimension Set ID"; // P8001133
            Validate("Document No.", DocNo);
            Validate("Account Type", "Account Type"::Customer);
            Validate("Account No.", CustNo);
            Description := DeductionRes.Description;
            Validate(Amount, -DeductionRes.Amount);
            if DeductionRes.Type <> DeductionRes.Type::Return then begin
                // P8000240A Begin
                case DeductionRes.Type of
                    DeductionRes.Type::Writeoff:
                        begin
                            Validate("Bal. Account Type", "Bal. Account Type"::"G/L Account");
                            Validate("Bal. Account No.", DeductionRes."Account No.");
                        end;
                    DeductionRes.Type::"Accrual Plan":
                        begin
                            AccrualPlan.Get(AccrualPlan.Type::Sales, DeductionRes."Account No.");
                            GenJnlLine.Validate("Accrual Entry Type", GenJnlLine."Accrual Entry Type"::Payment);
                            Validate("Bal. Account Type", "Bal. Account Type"::FOODAccrualPlan);
                            Validate("Bal. Account No.", DeductionRes."Account No.");
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
            GenJnlLine.Validate("Reason Code", DeductionRes."Reason Code");
            GenJnlLine."Dimension Set ID" := DimensionSetID;                                  // P8001133
            DimMgt.UpdateGlobalDimFromDimSetID(DimensionSetID,                                // P8001133
              GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code"); // P8001133
            GenJnlLine."Deduction Management Entry" := true;
            if DeductionRes.Type <> DeductionRes.Type::Return then
                GenJnlLine."Deduction Type" := DeductionRes.Type;
            GenJnlPostLine.RunWithCheck(GenJnlLine); // P8001133

            CustLedger.Find('+');
            // P8000269A
            P800CoreFns.CopyLedgerComments(DATABASE::"Cust. Ledger Entry", DeductionEntry."Entry No.",
              DATABASE::"Cust. Ledger Entry", CustLedger."Entry No.");
            if DeductionRes.Type = DeductionRes.Type::Return then begin
                LedgerComment."Table ID" := DATABASE::"Cust. Ledger Entry";
                LedgerComment."Entry No." := CustLedger."Entry No.";
                LedgerComment.Date := WorkDate;
                LedgerComment.Comment := StrSubstNo(Text002, DeductionEntry."Document No.");
                P800CoreFns.AddLedgerComment(LedgerComment);
            end;
            DeductionRes.CopyCommentsToLedger(DATABASE::"Cust. Ledger Entry", CustLedger."Entry No.");
            // P8000269A
            DeductionRes."Customer Ledger Entry No." := CustLedger."Entry No.";
        end;
    end;

    local procedure PostApplication(var CustLedger: Record "Cust. Ledger Entry"; AppliesToID: Code[20])
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        CustLedger.CalcFields("Remaining Amount");                     // PR4.00
        CustLedger."Amount to Apply" := CustLedger."Remaining Amount"; // PR4.00

        GenJnlLine."Document No." := AppliesToID;
        GenJnlLine."Posting Date" := WorkDate;
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

        CustLedger."Applies-to ID" := AppliesToID;
        GenJnlPostLine.CustPostApplyCustLedgEntry(GenJnlLine, CustLedger);
    end;

    local procedure LockTables()
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

    procedure Preview(CustLedger: Record "Cust. Ledger Entry")
    var
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        DedMgtPostResolution: Codeunit "Ded. Mgt. - Post Resolution";
    begin
        // P8007748
        BindSubscription(DedMgtPostResolution);
        GenJnlPostPreview.Preview(DedMgtPostResolution, CustLedger);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnRunPreview', '', true, false)]
    local procedure GenJnlPostPreview_OnRunPreview(var Result: Boolean; Subscriber: Variant; RecVar: Variant)
    var
        CustLedger: Record "Cust. Ledger Entry";
        DedMgtPostResolution: Codeunit "Ded. Mgt. - Post Resolution";
    begin
        // P8007748
        DedMgtPostResolution := Subscriber;
        CustLedger.Copy(RecVar);
        PreviewMode := true;
        Result := DedMgtPostResolution.Run(CustLedger);
    end;
}

