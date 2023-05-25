codeunit 37002123 "Accrual Jnl.-Post Batch" // Version: FOODNA
{
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
    // PR4.00
    // P8000262B, VerticalSoft, Jack Reynolds, 28 OCT 05
    //   Fix problem posting wrong payment amount with sales and purchase lines
    // 
    // PR4.00.06
    // P8000464A, VerticalSoft, Don Bresee, 9 APR 07
    //   Fixes relating to Combine Shipment & Combine Return Receipts functions
    // 
    // PRW16.00.01
    // P8000694, VerticalSoft, Jack Reynolds, 01 MAY 09
    //   Fix problem with creating Posted Document Accrual Lines
    // 
    // PRW16.00.02
    // P8000762, VerticalSoft, Jack Reynolds, 28 JAN 10
    //   Set Accrual Ledger entry on General Journal Line
    // 
    // PRW16.00.03
    // P8000825, VerticalSoft, Jack Reynolds, 14 MAY 10
    //   Fix problem with posting of global dimensions
    // 
    // PRW16.00.04
    // P8000852, VerticalSoft, Jack Reynolds, 05 AUG 10
    //   Fix problem wih records accumulating in Dimension Buffer table
    // 
    // PRNA6.00.04
    // P8000894, VerticalSoft, Jack Reynolds, 13 JAN 11
    //   Restore code to update 1099 code
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW110.0.01
    // P8008663, To-Increase, Jack Reynolds 21 APR 17
    //   Payments in foreign currencies
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 26 APR 22
    //   Upgrade to 20.0 - Refactoring for default dimensions

    Permissions = TableData "Accrual Journal Batch" = imd,
                  TableData "Accrual Ledger Entry" = imd,
                  TableData "Accrual Register" = imd,
                  TableData "Accrual Posting Buffer" = rimd,
                  TableData "Posted Document Accrual Line" = rimd;
    TableNo = "Accrual Journal Line";

    trigger OnRun()
    begin
        AccrualJnlLine.Copy(Rec);
        Code;
        Rec := AccrualJnlLine;
    end;

    var
        Text000: Label 'cannot exceed %1 characters';
        Text001: Label 'Journal Batch Name    #1##########\\';
        Text002: Label 'Checking lines        #2######\';
        Text003: Label 'Posting lines         #3###### @4@@@@@@@@@@@@@\';
        Text004: Label 'Posting lines to G/L  #5###### @6@@@@@@@@@@@@@\';
        Text005: Label 'Updating lines        #7###### @8@@@@@@@@@@@@@';
        Text006: Label 'Posting lines to G/L  #5###### @6@@@@@@@@@@@@@';
        Text007: Label 'A maximum of %1 posting number series can be used in each journal.';
        Text008: Label '<Month Text>';
        AccountingPeriod: Record "Accounting Period";
        AccrualJnlTemplate: Record "Accrual Journal Template";
        AccrualJnlBatch: Record "Accrual Journal Batch";
        AccrualJnlLine: Record "Accrual Journal Line";
        AccrualJnlLine2: Record "Accrual Journal Line";
        AccrualJnlLine3: Record "Accrual Journal Line";
        AccrualLedgEntry: Record "Accrual Ledger Entry";
        AccrualPostingBuffer: Record "Accrual Posting Buffer" temporary;
        AccrualReg: Record "Accrual Register";
        NoSeries: Record "No. Series" temporary;
        Vendor: Record Vendor;
        AccrualJnlCheckLine: Codeunit "Accrual Jnl.-Check Line";
        AccrualJnlPostLine: Codeunit "Accrual Jnl.-Post Line";
        AccrualCalcMgmt: Codeunit "Accrual Calculation Management";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesMgt2: array[10] of Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;
        Window: Dialog;
        AccrualRegNo: Integer;
        StartLineNo: Integer;
        Day: Integer;
        Week: Integer;
        Month: Integer;
        MonthText: Text[30];
        LineCount: Integer;
        NoOfRecords: Integer;
        LastDocNo: Code[20];
        LastDocNo2: Code[20];
        LastPostedDocNo: Code[20];
        NoOfPostingNoSeries: Integer;
        PostingNoSeriesNo: Integer;
        "0DF": DateFormula;
        BufLineCount: Integer;
        NoOfBufRecords: Integer;
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        Text009: Label 'Accruals - %1 %2 %3';
        Text010: Label 'Accruals - Customer %1';
        Text011: Label 'Accruals - Vendor %1';
        Text012: Label 'Accruals - %1 Plan %2';
        Text013: Label '%1 Accruals';

    local procedure "Code"()
    var
        UpdateAnalysisView: Codeunit "Update Analysis View";
    begin
        with AccrualJnlLine do begin
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            if RecordLevelLocking then
                LockTable;

            //AccrualPostingBuffer.LOCKTABLE;           // P8000852
            //AccrualPostingBuffer.DeleteAllDimensions; // P8000852

            AccrualJnlTemplate.Get("Journal Template Name");
            AccrualJnlBatch.Get("Journal Template Name", "Journal Batch Name");
            if StrLen(IncStr(AccrualJnlBatch.Name)) > MaxStrLen(AccrualJnlBatch.Name) then
                AccrualJnlBatch.FieldError(
                  Name,
                  StrSubstNo(
                    Text000,
                    MaxStrLen(AccrualJnlBatch.Name)));

            if AccrualJnlTemplate.Recurring then begin
                SetRange("Posting Date", 0D, WorkDate);
                SetFilter("Expiration Date", '%1|%2..', 0D, WorkDate);
            end;

            if not Find('=><') then begin
                "Line No." := 0;
                Commit;
                exit;
            end;

            if AccrualJnlTemplate.Recurring then
                Window.Open(
                  Text001 +
                  Text002 +
                  Text003 +
                  Text004 +
                  Text005)
            else
                Window.Open(
                  Text001 +
                  Text002 +
                  Text003 +
                  Text006);
            Window.Update(1, "Journal Batch Name");

            // Check lines
            LineCount := 0;
            StartLineNo := "Line No.";
            repeat
                LineCount := LineCount + 1;
                Window.Update(2, LineCount);
                CheckRecurringLine(AccrualJnlLine);
                AccrualJnlCheckLine.RunCheck(AccrualJnlLine); // P8001133
                if Next = 0 then
                    Find('-');
            until "Line No." = StartLineNo;
            NoOfRecords := LineCount;

            // Find next register no.
            AccrualLedgEntry.LockTable;
            AccrualReg.LockTable;
            if RecordLevelLocking then
                if AccrualLedgEntry.Find('+') then;
            AccrualReg.LockTable;
            if AccrualReg.Find('+') and (AccrualReg."To Entry No." = 0) then
                AccrualRegNo := AccrualReg."No."
            else
                AccrualRegNo := AccrualReg."No." + 1;

            // Post lines
            LineCount := 0;
            LastDocNo := '';
            LastDocNo2 := '';
            LastPostedDocNo := '';
            Find('-');
            repeat
                LineCount := LineCount + 1;
                Window.Update(3, LineCount);
                Window.Update(4, Round(LineCount / NoOfRecords * 10000, 1));
                if not EmptyLine and
                   (AccrualJnlBatch."No. Series" <> '') and
                   ("Document No." <> LastDocNo2)
                then
                    TestField("Document No.",
                      NoSeriesMgt.GetNextNo(AccrualJnlBatch."No. Series", "Posting Date", false));
                LastDocNo2 := "Document No.";
                MakeRecurringTexts(AccrualJnlLine);
                if "Posting No. Series" = '' then
                    "Posting No. Series" := AccrualJnlBatch."No. Series"
                else
                    if not EmptyLine then
                        if "Document No." = LastDocNo then
                            "Document No." := LastPostedDocNo
                        else begin
                            if not NoSeries.Get("Posting No. Series") then begin
                                NoOfPostingNoSeries := NoOfPostingNoSeries + 1;
                                if NoOfPostingNoSeries > ArrayLen(NoSeriesMgt2) then
                                    Error(
                                      Text007,
                                      ArrayLen(NoSeriesMgt2));
                                NoSeries.Code := "Posting No. Series";
                                NoSeries.Description := Format(NoOfPostingNoSeries);
                                NoSeries.Insert;
                            end;
                            LastDocNo := "Document No.";
                            Evaluate(PostingNoSeriesNo, NoSeries.Description);
                            "Document No." := NoSeriesMgt2[PostingNoSeriesNo].GetNextNo("Posting No. Series", "Posting Date", false);
                            LastPostedDocNo := "Document No.";
                        end;
                AccrualJnlPostLine.RunWithCheck(AccrualJnlLine); // P8001133
            until Next = 0;

            // Copy register no. and current journal batch name to the job journal
            if not AccrualReg.Find('+') or (AccrualReg."No." <> AccrualRegNo) then
                AccrualRegNo := 0;

            Init;
            "Line No." := AccrualRegNo;

            // post to G/L
            BufLineCount := 0;
            AccrualJnlPostLine.GetPostBuffer(AccrualPostingBuffer); // P8000852
            NoOfBufRecords := AccrualPostingBuffer.Count;
            while AccrualPostingBuffer.Find('-') do begin
                BufLineCount := BufLineCount + 1;
                Window.Update(5, BufLineCount);
                Window.Update(6, Round(BufLineCount / NoOfBufRecords * 10000, 1));

                if BuildGenJnlLine(AccrualPostingBuffer, true, GenJnlLine, LineCount) then // P8001133
                    GenJnlPostLine.RunWithCheck(GenJnlLine); // P8001133

                BufLineCount := BufLineCount + LineCount - 1;
                Window.Update(5, BufLineCount);
                Window.Update(6, Round(BufLineCount / NoOfBufRecords * 10000, 1));
            end;
            //AccrualPostingBuffer.DeleteAllDimensions; // P8000852

            // Update/delete lines
            if AccrualRegNo <> 0 then begin
                if AccrualJnlTemplate.Recurring then begin
                    // Recurring journal
                    LineCount := 0;
                    AccrualJnlLine2.CopyFilters(AccrualJnlLine);
                    AccrualJnlLine2.Find('-');
                    repeat
                        LineCount := LineCount + 1;
                        Window.Update(7, LineCount);
                        Window.Update(8, Round(LineCount / NoOfRecords * 10000, 1));
                        if AccrualJnlLine2."Posting Date" <> 0D then
                            AccrualJnlLine2.Validate("Posting Date",
                              CalcDate(AccrualJnlLine2."Recurring Frequency", AccrualJnlLine2."Posting Date"));
                        if (AccrualJnlLine2."Recurring Method" = AccrualJnlLine2."Recurring Method"::Variable) and
                           (AccrualJnlLine2."No." <> '')
                        then
                            AccrualJnlLine2.Amount := 0;
                        AccrualJnlLine2.Modify;
                    until AccrualJnlLine2.Next = 0;
                end else begin
                    // Not a recurring journal
                    AccrualJnlLine2.CopyFilters(AccrualJnlLine);
                    AccrualJnlLine2.SetFilter("No.", '<>%1', '');
                    if AccrualJnlLine2.Find('+') then; // Remember the last line  // P8000119A
                    AccrualJnlLine3.Copy(AccrualJnlLine);
                    AccrualJnlLine3.DeleteAll; // P8001133
                    AccrualJnlLine3.Reset;
                    AccrualJnlLine3.SetRange("Journal Template Name", "Journal Template Name");
                    AccrualJnlLine3.SetRange("Journal Batch Name", "Journal Batch Name");
                    if not AccrualJnlLine3.Find('+') then
                        if IncStr("Journal Batch Name") <> '' then begin
                            AccrualJnlBatch.Delete;
                            AccrualJnlBatch.Name := IncStr("Journal Batch Name");
                            if AccrualJnlBatch.Insert then;
                            "Journal Batch Name" := AccrualJnlBatch.Name;
                        end;

                    AccrualJnlLine3.SetRange("Journal Batch Name", "Journal Batch Name");
                    if (AccrualJnlBatch."No. Series" = '') and not AccrualJnlLine3.Find('+') then begin
                        AccrualJnlLine3.Init;
                        AccrualJnlLine3."Journal Template Name" := "Journal Template Name";
                        AccrualJnlLine3."Journal Batch Name" := "Journal Batch Name";
                        AccrualJnlLine3."Line No." := 10000;
                        AccrualJnlLine3.Insert;
                        AccrualJnlLine3.SetUpNewLine(AccrualJnlLine2);
                        AccrualJnlLine3.Modify;
                    end;
                end;
            end;
            if AccrualJnlBatch."No. Series" <> '' then
                NoSeriesMgt.SaveNoSeries;
            if NoSeries.Find('-') then
                repeat
                    Evaluate(PostingNoSeriesNo, NoSeries.Description);
                    NoSeriesMgt2[PostingNoSeriesNo].SaveNoSeries;
                until NoSeries.Next = 0;

            Commit;
        end;
        UpdateAnalysisView.UpdateAll(0, true);
        Commit;
    end;

    local procedure CheckRecurringLine(var AccrualJnlLine2: Record "Accrual Journal Line")
    begin
        with AccrualJnlLine2 do begin
            if "No." <> '' then
                if AccrualJnlTemplate.Recurring then begin
                    TestField("Recurring Method");
                    TestField("Recurring Frequency");
                    if "Recurring Method" = "Recurring Method"::Variable then
                        TestField(Amount);
                end else begin
                    TestField("Recurring Method", 0);
                    TestField("Recurring Frequency", "0DF");
                end;
        end;
    end;

    local procedure MakeRecurringTexts(var AccrualJnlLine2: Record "Accrual Journal Line")
    begin
        with AccrualJnlLine2 do begin
            if ("No." <> '') and ("Recurring Method" <> 0) then begin // Not recurring
                Day := Date2DMY("Posting Date", 1);
                Week := Date2DWY("Posting Date", 2);
                Month := Date2DMY("Posting Date", 2);
                MonthText := Format("Posting Date", 0, Text008);
                AccountingPeriod.SetRange("Starting Date", 0D, "Posting Date");
                if not AccountingPeriod.Find('+') then
                    AccountingPeriod.Name := '';
                "Document No." :=
                  DelChr(
                    PadStr(
                      StrSubstNo("Document No.", Day, Week, Month, MonthText, AccountingPeriod.Name),
                      MaxStrLen("Document No.")),
                    '>');
                Description :=
                  DelChr(
                    PadStr(
                      StrSubstNo(Description, Day, Week, Month, MonthText, AccountingPeriod.Name),
                      MaxStrLen(Description)),
                    '>');
            end;
        end;
    end;

    local procedure MakeGLEntryDescription(): Text[250]
    begin
        with AccrualPostingBuffer do begin
            if ("Source Document No." <> '') then
                exit(
                  StrSubstNo(Text009, "Accrual Plan Type", "Source Document Type", "Source Document No."));
            if ("Source No." <> '') then begin
                if (Type = "Accrual Plan Type") and ("No." = "Source No.") then
                    exit(StrSubstNo(Text013, "Accrual Plan Type"));
                case "Accrual Plan Type" of
                    "Accrual Plan Type"::Sales:
                        exit(StrSubstNo(Text010, "Source No."));
                    "Accrual Plan Type"::Purchase:
                        exit(StrSubstNo(Text011, "Source No."));
                end;
            end;
            if ("Accrual Plan No." <> '') then
                exit(
                  StrSubstNo(Text012, "Accrual Plan Type", "Accrual Plan No."));
            exit(StrSubstNo(Text013, "Accrual Plan Type"));
        end;
    end;

    procedure PostSalesLineAccruals(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; SourceCode: Code[10])
    var
        DocAccrualLine: Record "Document Accrual Line";
        AccrualPlan: Record "Accrual Plan";
        IsReturn: Boolean;
        TempDocAccrualLine: Record "Document Accrual Line" temporary;
    begin
        // P8001133 - remove parameter for TempDocDim
        if GetFirstDocLineAccrual(
             DocAccrualLine, AccrualPlan, AccrualPlan.Type::Sales,
             AccrualPlan."Computation Level"::"Document Line", SalesLine."Document Type",
             SalesLine."Document No.", SalesLine."Line No.")
        then
            repeat
                if HandleDocAccrual(AccrualPlan, SalesHeader.Ship or SalesHeader.Receive, SalesHeader.Invoice) then
                    if AccrualPlan."Post Accrual w/ Document" then
                        if ScaleSalesLineAccrual(DocAccrualLine, SalesLine, AccrualPlan, TempDocAccrualLine) then
                            with TempDocAccrualLine do begin
                                IsReturn := ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]);

                                InitAccrualJnlLine(TempDocAccrualLine, AccrualPlan, IsReturn);

                                AccrualJnlLine.Amount := -"Payment Amount (LCY)";
                                if IsReturn then
                                    AccrualJnlLine.Amount := -AccrualJnlLine.Amount;
                                AccrualJnlLine."Source Code" := SourceCode;

                                SalesHeaderTOAccrualJnlLine(SalesHeader, AccrualPlan, IsReturn);

                                SalesLineTOAccrualJnlLine(SalesLine, AccrualPlan); // P8000464A

                                PostAccrualsAndPayments(
                                  TempDocAccrualLine, AccrualPlan, SalesLine."Dimension Set ID", IsReturn); // P8001133
                            end;
            until not GetNextDocLineAccrual(DocAccrualLine, AccrualPlan);
    end;

    local procedure ScaleSalesLineAccrual(var DocAccrualLine: Record "Document Accrual Line"; var SalesLine: Record "Sales Line"; var AccrualPlan: Record "Accrual Plan"; var TempDocAccrualLine: Record "Document Accrual Line" temporary): Boolean
    var
        QtyToHandle: Decimal;
        QtyHandled: Decimal;
    begin
        with DocAccrualLine do begin
            CalcSums("Payment Amount (LCY)");
            if ("Payment Amount (LCY)" = 0) then
                exit(false);
            Find; // P8000262B
        end;

        GetSalesQtys(AccrualPlan, SalesLine, QtyToHandle, QtyHandled);
        with TempDocAccrualLine do begin
            DeleteAll;
            repeat
                TempDocAccrualLine := DocAccrualLine;
                if (QtyToHandle <> SalesLine.GetPricingQty()) then
                    "Payment Amount (LCY)" := Round("Payment Amount (LCY)" * (QtyToHandle / SalesLine.GetPricingQty()));
                Insert;
            until (DocAccrualLine.Next = 0);
            Find('-');
            CalcSums("Payment Amount (LCY)");
            exit("Payment Amount (LCY)" <> 0);
        end;
    end;

    local procedure GetSalesQtys(var AccrualPlan: Record "Accrual Plan"; var SalesLine: Record "Sales Line"; var QtyToHandle: Decimal; var QtyHandled: Decimal)
    var
        IsReturn: Boolean;
    begin
        with SalesLine do begin
            IsReturn := ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]);
            if (AccrualPlan.Accrue <> AccrualPlan.Accrue::"Shipments/Receipts") then begin
                if PriceInAlternateUnits() then begin
                    QtyToHandle := -"Qty. to Invoice (Alt.)";
                    QtyHandled := -"Qty. Invoiced (Alt.)";
                end else begin
                    QtyToHandle := -"Qty. to Invoice";
                    QtyHandled := -"Quantity Invoiced";
                end;
                if IsReturn then begin
                    QtyToHandle := -QtyToHandle;
                    QtyHandled := -QtyHandled;
                end;
            end else
                case true of
                    IsReturn and PriceInAlternateUnits():
                        begin
                            QtyToHandle := "Return Qty. to Receive (Alt.)";
                            QtyHandled := "Return Qty. Received (Alt.)";
                        end;
                    IsReturn:
                        begin
                            QtyToHandle := "Return Qty. to Receive";
                            QtyHandled := "Return Qty. Received";
                        end;
                    PriceInAlternateUnits():
                        begin
                            QtyToHandle := -"Qty. to Ship (Alt.)";
                            QtyHandled := -"Qty. Shipped (Alt.)";
                        end;
                    else begin
                            QtyToHandle := -"Qty. to Ship";
                            QtyHandled := -"Quantity Shipped";
                        end;
                end;
        end;
    end;

    procedure PostSalesHeaderAccruals(var SalesHeader: Record "Sales Header"; SourceCode: Code[10])
    var
        DocAccrualLine: Record "Document Accrual Line";
        AccrualPlan: Record "Accrual Plan";
        IsReturn: Boolean;
    begin
        // P8001133 - remove parameter for TempDocDim
        with DocAccrualLine do
            if GetFirstDocLineAccrual(
                 DocAccrualLine, AccrualPlan, "Accrual Plan Type"::Sales,
                 "Computation Level"::Document, SalesHeader."Document Type",
                 SalesHeader."No.", 0)
            then
                repeat
                    if HandleDocAccrual(AccrualPlan, SalesHeader.Ship or SalesHeader.Receive, SalesHeader.Invoice) then
                        if AccrualPlan."Post Accrual w/ Document" then begin
                            CalcSums("Payment Amount (LCY)");
                            if ("Payment Amount (LCY)" <> 0) then begin
                                IsReturn := ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]);

                                InitAccrualJnlLine(DocAccrualLine, AccrualPlan, IsReturn);

                                AccrualJnlLine.Amount := -"Payment Amount (LCY)";
                                if IsReturn then
                                    AccrualJnlLine.Amount := -AccrualJnlLine.Amount;
                                AccrualJnlLine."Source Code" := SourceCode;

                                SalesHeaderTOAccrualJnlLine(SalesHeader, AccrualPlan, IsReturn);

                                PostAccrualsAndPayments(
                                  DocAccrualLine, AccrualPlan, SalesHeader."Dimension Set ID", IsReturn); // P8001133
                            end;
                        end;
                until not GetNextDocLineAccrual(DocAccrualLine, AccrualPlan);
    end;

    local procedure SalesHeaderTOAccrualJnlLine(var SalesHeader: Record "Sales Header"; var AccrualPlan: Record "Accrual Plan"; IsReturn: Boolean)
    begin
        with SalesHeader do begin
            AccrualJnlLine."Posting Date" := "Posting Date";
            AccrualJnlLine."Document Date" := "Document Date";
            if (AccrualPlan."Source Selection Type" =
              AccrualPlan."Source Selection Type"::"Bill-to/Pay-to")
            then
                AccrualJnlLine."Source No." := "Bill-to Customer No."
            else
                AccrualJnlLine."Source No." := "Sell-to Customer No.";
            AccrualJnlLine."No." := "Bill-to Customer No.";
            AccrualJnlLine.Description := "Posting Description";
            AccrualJnlLine."External Document No." := "External Document No.";
            AccrualJnlLine."Due Date" := "Due Date";
            AccrualJnlLine.SetDueDateFromSource;
            if (AccrualPlan.Accrue <> AccrualPlan.Accrue::"Shipments/Receipts") then
                SetDocNoToPostingNo("No.", "Posting No.", "Posting No. Series")
            else begin
                if IsReturn then begin
                    AccrualJnlLine."Document No." := "Return Receipt No.";
                    AccrualJnlLine."Posting No. Series" := "Return Receipt No. Series";
                end else begin
                    AccrualJnlLine."Document No." := "Shipping No.";
                    AccrualJnlLine."Posting No. Series" := "Shipping No. Series";
                end;
                if (AccrualJnlLine."Document No." = '') then
                    SetDocNoToInvCMNo("No.", IsReturn, "Posting No.", "Posting No. Series");
            end;
            AccrualJnlLine."Reason Code" := "Reason Code";

            AccrualJnlLine."Source Document No." := AccrualJnlLine."Document No.";
            AccrualJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            AccrualJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            AccrualJnlLine."Dimension Set ID" := "Dimension Set ID"; // P8001133
        end;
    end;

    local procedure SalesLineTOAccrualJnlLine(var SalesLine: Record "Sales Line"; var AccrualPlan: Record "Accrual Plan")
    begin
        // P8000464A - add AccrualPlan parameter
        with SalesLine do begin
            if (AccrualPlan."Source Selection Type" <>                 // P8000464A
                AccrualPlan."Source Selection Type"::"Bill-to/Pay-to") // P8000464A
            then                                                       // P8000464A
                AccrualJnlLine."Source No." := "Sell-to Customer No.";   // P8000464A
            AccrualJnlLine."Source Document No." := AccrualJnlLine."Document No.";
            AccrualJnlLine."Source Document Line No." := "Line No.";
            AccrualJnlLine."Item No." := "No.";
            AccrualJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            AccrualJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            AccrualJnlLine."Dimension Set ID" := "Dimension Set ID"; // P8001133
            AccrualJnlLine."Gen. Bus. Posting Group" := "Gen. Bus. Posting Group";
            AccrualJnlLine."Gen. Prod. Posting Group" := "Gen. Prod. Posting Group";
        end;
    end;

    procedure PostPurchLineAccruals(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; SourceCode: Code[10])
    var
        DocAccrualLine: Record "Document Accrual Line";
        AccrualPlan: Record "Accrual Plan";
        IsReturn: Boolean;
        TempDocAccrualLine: Record "Document Accrual Line" temporary;
    begin
        // P8001133 - remove parameter for TempDocDim
        if GetFirstDocLineAccrual(
             DocAccrualLine, AccrualPlan, AccrualPlan.Type::Purchase,
             AccrualPlan."Computation Level"::"Document Line", PurchLine."Document Type",
             PurchLine."Document No.", PurchLine."Line No.")
        then
            repeat
                if HandleDocAccrual(AccrualPlan, PurchHeader.Ship or PurchHeader.Receive, PurchHeader.Invoice) then
                    if AccrualPlan."Post Accrual w/ Document" then
                        if ScalePurchLineAccrual(DocAccrualLine, PurchLine, AccrualPlan, TempDocAccrualLine) then
                            with TempDocAccrualLine do begin
                                IsReturn := ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]);

                                InitAccrualJnlLine(TempDocAccrualLine, AccrualPlan, IsReturn);

                                AccrualJnlLine.Amount := "Payment Amount (LCY)";
                                if IsReturn then
                                    AccrualJnlLine.Amount := -AccrualJnlLine.Amount;
                                AccrualJnlLine."Source Code" := SourceCode;

                                PurchHeaderTOAccrualJnlLine(PurchHeader, AccrualPlan, IsReturn);

                                PurchLineTOAccrualJnlLine(PurchLine);

                                PostAccrualsAndPayments(
                                  TempDocAccrualLine, AccrualPlan, PurchLine."Dimension Set ID", IsReturn); // P8001133
                            end;
            until not GetNextDocLineAccrual(DocAccrualLine, AccrualPlan);
    end;

    local procedure ScalePurchLineAccrual(var DocAccrualLine: Record "Document Accrual Line"; var PurchLine: Record "Purchase Line"; var AccrualPlan: Record "Accrual Plan"; var TempDocAccrualLine: Record "Document Accrual Line" temporary): Boolean
    var
        QtyToHandle: Decimal;
        QtyHandled: Decimal;
    begin
        with DocAccrualLine do begin
            CalcSums("Payment Amount (LCY)");
            if ("Payment Amount (LCY)" = 0) then
                exit(false);
            Find; // P8000262B
        end;

        GetPurchQtys(AccrualPlan, PurchLine, QtyToHandle, QtyHandled);
        with TempDocAccrualLine do begin
            DeleteAll;
            repeat
                TempDocAccrualLine := DocAccrualLine;
                if (QtyToHandle <> PurchLine.GetCostingQty()) then
                    "Payment Amount (LCY)" := Round("Payment Amount (LCY)" * (QtyToHandle / PurchLine.GetCostingQty()));
                Insert;
            until (DocAccrualLine.Next = 0);
            Find('-');
            CalcSums("Payment Amount (LCY)");
            exit("Payment Amount (LCY)" <> 0);
        end;
    end;

    local procedure GetPurchQtys(var AccrualPlan: Record "Accrual Plan"; var PurchLine: Record "Purchase Line"; var QtyToHandle: Decimal; var QtyHandled: Decimal)
    var
        IsReturn: Boolean;
    begin
        with PurchLine do begin
            IsReturn := ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]);
            if (AccrualPlan.Accrue <> AccrualPlan.Accrue::"Shipments/Receipts") then begin
                if CostInAlternateUnits() then begin
                    QtyToHandle := "Qty. to Invoice (Alt.)";
                    QtyHandled := "Qty. Invoiced (Alt.)";
                end else begin
                    QtyToHandle := "Qty. to Invoice";
                    QtyHandled := "Quantity Invoiced";
                end;
                if IsReturn then begin
                    QtyToHandle := -QtyToHandle;
                    QtyHandled := -QtyHandled;
                end;
            end else
                case true of
                    IsReturn and CostInAlternateUnits():
                        begin
                            QtyToHandle := -"Return Qty. to Ship (Alt.)";
                            QtyHandled := -"Return Qty. Shipped (Alt.)";
                        end;
                    IsReturn:
                        begin
                            QtyToHandle := -"Return Qty. to Ship";
                            QtyHandled := -"Return Qty. Shipped";
                        end;
                    CostInAlternateUnits():
                        begin
                            QtyToHandle := "Qty. to Receive (Alt.)";
                            QtyHandled := "Qty. Received (Alt.)";
                        end;
                    else begin
                            QtyToHandle := "Qty. to Receive";
                            QtyHandled := "Quantity Received";
                        end;
                end;
        end;
    end;

    procedure PostPurchHeaderAccruals(var PurchHeader: Record "Purchase Header"; SourceCode: Code[10])
    var
        DocAccrualLine: Record "Document Accrual Line";
        AccrualPlan: Record "Accrual Plan";
        IsReturn: Boolean;
    begin
        // P8001133 - remove parameter for TempDocDim
        with DocAccrualLine do
            if GetFirstDocLineAccrual(
                 DocAccrualLine, AccrualPlan, "Accrual Plan Type"::Purchase,
                 "Computation Level"::Document, PurchHeader."Document Type",
                 PurchHeader."No.", 0)
            then
                repeat
                    if HandleDocAccrual(AccrualPlan, PurchHeader.Ship or PurchHeader.Receive, PurchHeader.Invoice) then
                        if AccrualPlan."Post Accrual w/ Document" then begin
                            CalcSums("Payment Amount (LCY)");
                            if ("Payment Amount (LCY)" <> 0) then begin
                                IsReturn := ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]);

                                InitAccrualJnlLine(DocAccrualLine, AccrualPlan, IsReturn);

                                AccrualJnlLine.Amount := "Payment Amount (LCY)";
                                if IsReturn then
                                    AccrualJnlLine.Amount := -AccrualJnlLine.Amount;
                                AccrualJnlLine."Source Code" := SourceCode;

                                PurchHeaderTOAccrualJnlLine(PurchHeader, AccrualPlan, IsReturn);

                                PostAccrualsAndPayments(
                                  DocAccrualLine, AccrualPlan, PurchHeader."Dimension Set ID", IsReturn); // P8001133
                            end;
                        end;
                until not GetNextDocLineAccrual(DocAccrualLine, AccrualPlan);
    end;

    local procedure PurchHeaderTOAccrualJnlLine(var PurchHeader: Record "Purchase Header"; var AccrualPlan: Record "Accrual Plan"; IsReturn: Boolean)
    begin
        with PurchHeader do begin
            AccrualJnlLine."Posting Date" := "Posting Date";
            AccrualJnlLine."Document Date" := "Document Date";
            if (AccrualPlan."Source Selection Type" =
              AccrualPlan."Source Selection Type"::"Bill-to/Pay-to")
            then
                AccrualJnlLine."Source No." := "Pay-to Vendor No."
            else
                AccrualJnlLine."Source No." := "Buy-from Vendor No.";
            AccrualJnlLine."No." := "Pay-to Vendor No.";
            AccrualJnlLine.Description := "Posting Description";
            AccrualJnlLine."External Document No." := "Vendor Order No.";
            AccrualJnlLine."Due Date" := "Due Date";
            AccrualJnlLine.SetDueDateFromSource;
            if (AccrualPlan.Accrue <> AccrualPlan.Accrue::"Shipments/Receipts") then
                SetDocNoToPostingNo("No.", "Posting No.", "Posting No. Series")
            else begin
                if IsReturn then begin
                    AccrualJnlLine."Document No." := "Return Shipment No.";
                    AccrualJnlLine."Posting No. Series" := "Return Shipment No. Series";
                end else begin
                    AccrualJnlLine."Document No." := "Receiving No.";
                    AccrualJnlLine."Posting No. Series" := "Receiving No. Series";
                end;
                if (AccrualJnlLine."Document No." = '') then
                    SetDocNoToInvCMNo("No.", IsReturn, "Posting No.", "Posting No. Series");
            end;
            AccrualJnlLine."Reason Code" := "Reason Code";

            AccrualJnlLine."Source Document No." := AccrualJnlLine."Document No.";
            AccrualJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            AccrualJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            AccrualJnlLine."Dimension Set ID" := "Dimension Set ID"; // P8001133
        end;
    end;

    local procedure PurchLineTOAccrualJnlLine(var PurchLine: Record "Purchase Line")
    begin
        with PurchLine do begin
            AccrualJnlLine."Source Document No." := AccrualJnlLine."Document No.";
            AccrualJnlLine."Source Document Line No." := "Line No.";
            AccrualJnlLine."Item No." := "No.";
            AccrualJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            AccrualJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            AccrualJnlLine."Dimension Set ID" := "Dimension Set ID"; // P8001133
            AccrualJnlLine."Gen. Bus. Posting Group" := "Gen. Bus. Posting Group";
            AccrualJnlLine."Gen. Prod. Posting Group" := "Gen. Prod. Posting Group";
        end;
    end;

    procedure PostAccrualsAndPayments(var DocAccrualLine: Record "Document Accrual Line"; var AccrualPlan: Record "Accrual Plan"; DimensionSetID: Integer; IsReturn: Boolean)
    var
        PostedDocAccrualLine: Record "Posted Document Accrual Line";
    begin
        // P8001133 - remoave parameter for TempDocDim, TableNo, DocLineNo; replace with DimensionSetID
        with DocAccrualLine do begin
            BuildJnlLineDim(DimensionSetID); // P8001133
            AccrualJnlPostLine.RunWithCheck(AccrualJnlLine); // P8001133

            Find('-');
            repeat
                if ("Payment Amount (LCY)" <> 0) then begin
                    AccrualJnlLine."Entry Type" := AccrualJnlLine."Entry Type"::Payment;
                    AccrualJnlLine.Type := Type;
                    AccrualJnlLine."No." := "No.";
                    AccrualJnlLine.Description := Description;
                    if ("Accrual Plan Type" = "Accrual Plan Type"::Sales) then
                        AccrualJnlLine.Amount := "Payment Amount (LCY)"
                    else
                        AccrualJnlLine.Amount := -"Payment Amount (LCY)";
                    if IsReturn then
                        AccrualJnlLine.Amount := -AccrualJnlLine.Amount;

                    if AccrualPlan."Post Payment w/ Document" then begin
                        AccrualJnlLine.SetCurrencyCode; // P8008663
                        BuildJnlLineDim(DimensionSetID); // P8001133
                        AccrualJnlPostLine.RunWithCheck(AccrualJnlLine); // P8001133
                    end else
                        if AccrualPlan."Edit Accrual on Document" then begin // P8000119A, P8000694
                            PostedDocAccrualLine.TransferFields(AccrualJnlLine);
                            PostedDocAccrualLine.Insert;
                        end;
                end;
            until (Next = 0);
        end;
    end;

    local procedure GetFirstDocLineAccrual(var DocAccrualLine: Record "Document Accrual Line"; var AccrualPlan: Record "Accrual Plan"; AccrualPlanType: Integer; ComputationLevel: Integer; DocumentType: Integer; DocumentNo: Code[20]; DocumentLineNo: Integer): Boolean
    begin
        with DocAccrualLine do begin
            SetRange("Accrual Plan Type", AccrualPlanType);
            SetRange("Computation Level", ComputationLevel);
            SetRange("Document Type", DocumentType);
            SetRange("Document No.", DocumentNo);
            SetRange("Document Line No.", DocumentLineNo);
            if not Find('-') then
                exit(false);
            exit(GetAccrualPlan(DocAccrualLine, AccrualPlan));
        end;
    end;

    local procedure GetNextDocLineAccrual(var DocAccrualLine: Record "Document Accrual Line"; var AccrualPlan: Record "Accrual Plan"): Boolean
    begin
        with DocAccrualLine do begin
            Find('+');
            SetRange("Accrual Plan No.");
            if (Next = 0) then
                exit(false);
            exit(GetAccrualPlan(DocAccrualLine, AccrualPlan));
        end;
    end;

    local procedure GetAccrualPlan(var DocAccrualLine: Record "Document Accrual Line"; var AccrualPlan: Record "Accrual Plan"): Boolean
    begin
        with DocAccrualLine do begin
            TestField("Accrual Plan No.");
            AccrualPlan.Get("Accrual Plan Type", "Accrual Plan No.");
            SetRange("Accrual Plan No.", "Accrual Plan No.");
            exit(true);
        end;
    end;

    procedure InitAccrualJnlLine(var DocAccrualLine: Record "Document Accrual Line"; var AccrualPlan: Record "Accrual Plan"; var IsReturn: Boolean)
    begin
        with DocAccrualLine do begin
            AccrualJnlLine.Init;
            AccrualJnlLine."Entry Type" := AccrualJnlLine."Entry Type"::Accrual;

            AccrualJnlLine."Accrual Plan Type" := "Accrual Plan Type";
            AccrualJnlLine."Accrual Plan No." := "Accrual Plan No.";
            AccrualJnlLine.Type := "Accrual Plan Type";
            AccrualJnlLine."Price Impact" := "Price Impact";
            AccrualJnlLine."Accrual Posting Group" := AccrualPlan."Accrual Posting Group";
            case true of
                (AccrualPlan.Accrue <> AccrualPlan.Accrue::"Shipments/Receipts") and IsReturn:
                    AccrualJnlLine."Source Document Type" := AccrualJnlLine."Source Document Type"::"Credit Memo";
                (AccrualPlan.Accrue <> AccrualPlan.Accrue::"Shipments/Receipts"):
                    AccrualJnlLine."Source Document Type" := AccrualJnlLine."Source Document Type"::Invoice;
                ("Accrual Plan Type" = "Accrual Plan Type"::Sales) and IsReturn:
                    AccrualJnlLine."Source Document Type" := AccrualJnlLine."Source Document Type"::Receipt;
                ("Accrual Plan Type" = "Accrual Plan Type"::Sales):
                    AccrualJnlLine."Source Document Type" := AccrualJnlLine."Source Document Type"::Shipment;
                IsReturn:
                    AccrualJnlLine."Source Document Type" := AccrualJnlLine."Source Document Type"::Shipment;
                else
                    AccrualJnlLine."Source Document Type" := AccrualJnlLine."Source Document Type"::Receipt;
            end;
        end;
    end;

    local procedure SetDocNoToInvCMNo(DocNo: Code[20]; IsReturn: Boolean; PostingNo: Code[20]; PostingNoSeries: Code[10])
    begin
        with AccrualJnlLine do begin
            SetDocNoToPostingNo(DocNo, PostingNo, PostingNoSeries);
            if IsReturn then
                "Source Document Type" := "Source Document Type"::"Credit Memo"
            else
                "Source Document Type" := "Source Document Type"::Invoice;
        end;
    end;

    local procedure SetDocNoToPostingNo(DocNo: Code[20]; PostingNo: Code[20]; PostingNoSeries: Code[20])
    begin
        // P80053245 - Enlarge PostingNoSeries
        with AccrualJnlLine do begin
            if (PostingNo <> '') then
                "Document No." := PostingNo
            else
                "Document No." := DocNo;
            "Posting No. Series" := PostingNoSeries;
        end;
    end;

    local procedure HandleDocAccrual(var AccrualPlan: Record "Accrual Plan"; ShippingOrReceiving: Boolean; Invoicing: Boolean): Boolean
    begin
        with AccrualPlan do begin
            if (Accrue = Accrue::"Shipments/Receipts") then
                exit(ShippingOrReceiving);
            exit(Invoicing);
        end;
    end;

    local procedure BuildJnlLineDim(DimensionSetID: Integer)
    var
        GLSetup: Record "General Ledger Setup";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        TempDimSetEntry2: Record "Dimension Set Entry" temporary;
    begin
        // P8001133 - replace all parameters with DimensionSetID
        AccrualJnlLine.CreateDimFromDefaultDim(); // P800144605
        DimMgt.GetDimensionSet(TempDimSetEntry, AccrualJnlLine."Dimension Set ID");
        // P8001133
        DimMgt.GetDimensionSet(TempDimSetEntry2, DimensionSetID);
        if TempDimSetEntry2.FindSet then begin
            repeat
                TempDimSetEntry."Dimension Set ID" := AccrualJnlLine."Dimension Set ID";
                TempDimSetEntry."Dimension Code" := TempDimSetEntry2."Dimension Code";
                TempDimSetEntry."Dimension Value Code" := TempDimSetEntry2."Dimension Value Code";
                TempDimSetEntry."Dimension Value ID" := TempDimSetEntry2."Dimension Value ID";
                if not TempDimSetEntry.Insert then begin                                                    // P8002013R2
                    TempDimSetEntry.Get(TempDimSetEntry."Dimension Set ID", TempDimSetEntry."Dimension Code"); // P8002013R2
                    TempDimSetEntry."Dimension Value Code" := TempDimSetEntry2."Dimension Value Code";        // P8002013R2
                    TempDimSetEntry."Dimension Value ID" := TempDimSetEntry2."Dimension Value ID";
                    TempDimSetEntry.Modify;                                                                   // P8002013R2
                end;
            until TempDimSetEntry2.Next = 0;
            AccrualJnlLine."Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
            DimMgt.UpdateGlobalDimFromDimSetID(AccrualJnlLine."Dimension Set ID",
              AccrualJnlLine."Shortcut Dimension 1 Code", AccrualJnlLine."Shortcut Dimension 2 Code");
        end;
        // P8001133
    end;

    procedure BuildGenJnlLine(var AccrualPostingBuffer: Record "Accrual Posting Buffer"; PostByEntryType: Boolean; var GenJnlLine: Record "Gen. Journal Line"; var NumBufLines: Integer): Boolean
    begin
        // P8001133 - remove parameter for TempJnlLineDim
        with AccrualPostingBuffer do begin
            SetRange("Posting Date", "Posting Date");
            SetRange("Document No.", "Document No.");
            SetRange("Accrual Plan Type", "Accrual Plan Type");
            SetRange("Accrual Plan No.", "Accrual Plan No.");
            SetRange("Source No.", "Source No.");
            SetRange("Source Document Type", "Source Document Type");
            SetRange("Source Document No.", "Source Document No.");
            SetRange("Source Document Line No.", "Source Document Line No.");
            if PostByEntryType then
                SetRange("Entry Type", "Entry Type");
            SetRange(Type, Type);
            SetRange("No.", "No.");
            SetRange("Currency Code", "Currency Code"); // P8008663
            SetRange("Source Code", "Source Code");
            SetRange("Reason Code", "Reason Code");
            if (Type <> Type::"G/L Account") then
                SetRange("External Document No.", "External Document No.");
            SetRange("Dimension Entry No.", "Dimension Entry No.");

            NumBufLines := Count;
            CalcSums(Amount, "Amount (FCY)"); // P8008663

            GenJnlLine.Init;
            if (Amount <> 0) then begin
                GenJnlLine."Posting Date" := "Posting Date";
                GenJnlLine."Document No." := "Document No.";
                case Type of
                    Type::Customer:
                        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
                    Type::Vendor:
                        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
                    Type::"G/L Account":
                        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                end;
                GenJnlLine."Account No." := "No.";
                GenJnlLine.Validate("Currency Code", "Currency Code");
                GenJnlLine.Description := MakeGLEntryDescription();
                GenJnlLine."Shortcut Dimension 1 Code" := "Global Dimension 1 Code";
                GenJnlLine."Shortcut Dimension 2 Code" := "Global Dimension 2 Code";
                GenJnlLine."Dimension Set ID" := "Dimension Entry No."; // P8001133
                GenJnlLine."Source Code" := "Source Code";
                GenJnlLine."Reason Code" := "Reason Code";
                GenJnlLine."Document Date" := "Posting Date";
                if (Type <> Type::"G/L Account") then begin
                    GenJnlLine."External Document No." := "External Document No.";
                    GenJnlLine."Due Date" := "Due Date";
                end;
                GenJnlLine."System-Created Entry" := true;
                GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
                GenJnlLine.Amount := "Amount (FCY)"; // P8008663
                GenJnlLine."Amount (LCY)" := Amount;
                GenJnlLine."System-Created Entry" := true;
                GenJnlLine."Accrual Entry" := true; // P8000762
                // P8000762, P8000894
                if Type = Type::Vendor then begin
                    Vendor.Get("No.");
                    GenJnlLine.Validate("IRS 1099 Code", Vendor."IRS 1099 Code");
                end;
                // P8000762, P8000894
            end;

            DeleteAll;

            SetRange("Posting Date");
            SetRange("Document No.");
            SetRange("Accrual Plan Type");
            SetRange("Accrual Plan No.");
            SetRange("Source No.");
            SetRange("Source Document Type");
            SetRange("Source Document No.");
            SetRange("Source Document Line No.");
            if PostByEntryType then
                SetRange("Entry Type");
            SetRange(Type);
            SetRange("No.");
            SetRange("Currency Code"); // P8008663
            SetRange("Source Code");
            SetRange("Reason Code");
            if (Type <> Type::"G/L Account") then
                SetRange("External Document No.");
            SetRange("Dimension Entry No.");

            exit(GenJnlLine.Amount <> 0);
        end;
    end;

    procedure GetNextGenJnlLine(FirstLine: Boolean; PostByEntryType: Boolean; var GenJnlLine: Record "Gen. Journal Line"): Boolean
    var
        DummyCount: Integer;
    begin
        // P8000852
        // P8001133 - remove parameter for TempJnlLineDim
        if FirstLine then
            AccrualJnlPostLine.GetPostBuffer(AccrualPostingBuffer);
        while AccrualPostingBuffer.Find('-') do begin
            if BuildGenJnlLine(AccrualPostingBuffer, PostByEntryType, GenJnlLine, DummyCount) then // P8001133
                exit(true);
        end;
        exit(false);
    end;
}

