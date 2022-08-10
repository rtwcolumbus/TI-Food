report 37002687 "Suggest Comm. Adv. Payments"
{
    // PRW16.00.04
    // P8000902, Columbus IT, Don Bresee, 14 MAR 11
    //   Add Commodity Payment logic
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets

    Caption = 'Suggest Comm. Adv. Payments';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            begin
                Window.Update(1, "No.");

                AddTempAmount("No.", "Comm. Adv. Payment Amount");
            end;

            trigger OnPostDataItem()
            begin
                Window.Close;
            end;

            trigger OnPreDataItem()
            begin
                FilterGroup(2);
                SetRange("Comm. Adv. Payment Type", "Comm. Adv. Payment Type"::"Fixed Amount");
                FilterGroup(0);

                Window.Open(Text002);
            end;
        }
        dataitem(PurchOrder; "Purchase Header")
        {
            DataItemTableView = SORTING("Buy-from Vendor No.", "Pay-to Vendor No.", "Commodity Item No.", "Commodity P.O. Type") WHERE("Commodity Manifest Order" = CONST(true), "Commodity Item No." = FILTER(<> ''), "Commodity P.O. Type" = FILTER(Producer | Broker));
            PrintOnlyIfDetail = true;
            dataitem(PurchOrderLine; "Purchase Line")
            {
                DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") WHERE("Commodity Manifest No." = FILTER(<> ''));

                trigger OnAfterGetRecord()
                begin
                    OrderAmount := OrderAmount + CommCostMgmt.CalcAdvPaymentAmount(PurchOrderLine, ValuationDate);
                end;

                trigger OnPostDataItem()
                begin
                    AddTempAmount(PurchOrder."Pay-to Vendor No.", OrderAmount);
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Commodity Received Date", StartRcptDate, EndRcptDate);

                    OrderAmount := 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Window.Update(1, "No.");

                VendorFilters."No." := "Pay-to Vendor No.";
                if not VendorFilters.Find then
                    CurrReport.Skip;
            end;

            trigger OnPostDataItem()
            begin
                VendorFilters.FilterGroup(2);
                VendorFilters.SetRange("Comm. Adv. Payment Type");
                VendorFilters.FilterGroup(0);

                Window.Close;
            end;

            trigger OnPreDataItem()
            begin
                VendorFilters.FilterGroup(2);
                VendorFilters.SetRange("Comm. Adv. Payment Type", VendorFilters."Comm. Adv. Payment Type"::Calculated);
                VendorFilters.FilterGroup(0);

                Window.Open(Text003);
            end;
        }
        dataitem(VendLedgEntry; "Vendor Ledger Entry")
        {
            DataItemTableView = SORTING("Vendor No.", "Comm. Reference Date");

            trigger OnAfterGetRecord()
            begin
                Window.Update(1, "Vendor No.");

                VendorFilters."No." := "Vendor No.";
                if not VendorFilters.Find then
                    CurrReport.Skip;

                CalcFields("Original Amt. (LCY)");
                AddTempAmount("Vendor No.", -"Original Amt. (LCY)");
            end;

            trigger OnPostDataItem()
            begin
                Window.Close;
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Comm. Reference Date", CalcDate('-CM', EndRcptDate), CalcDate('+CM', EndRcptDate));

                Window.Open(Text004);
            end;
        }
        dataitem(CreateJnlLine; "Integer")
        {
            DataItemTableView = SORTING(Number);

            trigger OnAfterGetRecord()
            begin
                if (Number = 1) then begin
                    if not TempAmount.FindSet then
                        CurrReport.Break;
                end else begin
                    if (TempAmount.Next = 0) then
                        CurrReport.Break;
                end;

                MakeGenJnlLine;
            end;

            trigger OnPostDataItem()
            begin
                if TempAmount.IsEmpty then
                    Message(Text010)
                else
                    Message(Text011, TempAmount.Count);
            end;

            trigger OnPreDataItem()
            begin
                GenJnlLine.LockTable;
                GenJnlTemplate.Get(GenJnlLine."Journal Template Name");
                GenJnlBatch.Get(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");
                GenJnlLine.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
                GenJnlLine.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
                if GenJnlLine.Find('+') then begin
                    LastLineNo := GenJnlLine."Line No.";
                    GenJnlLine.Init;
                end;

                TempAmount.Reset;
                TempAmount.SetCurrentKey("Vendor No.");

                SetFilter(Number, '1..');
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(StartRcptDate; StartRcptDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Starting Receipt Date';
                        Editable = false;
                    }
                    field(EndRcptDate; EndRcptDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Ending Receipt Date';
                        NotBlank = true;

                        trigger OnValidate()
                        begin
                            CalcDates;
                        end;
                    }
                    field(ValuationDate; ValuationDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Valuation Date';
                        Editable = false;
                    }
                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Posting Date';

                        trigger OnValidate()
                        begin
                            ValidatePostingDate;
                        end;
                    }
                    field(NextDocNo; NextDocNo)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Starting Document No.';

                        trigger OnValidate()
                        begin
                            if NextDocNo <> '' then
                                if IncStr(NextDocNo) = '' then
                                    Error(Text007);
                        end;
                    }
                    field("GenJnlLine2.""Bal. Account Type"""; GenJnlLine2."Bal. Account Type")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Bal. Account Type';
                        OptionCaption = 'G/L Account,,,Bank Account';

                        trigger OnValidate()
                        begin
                            case GenJnlLine2."Bal. Account Type" of
                                GenJnlLine2."Bal. Account Type"::"G/L Account":
                                    begin
                                        if GenJnlLine2."Bal. Account No." <> '' then
                                            if not GLAcc.Get(GenJnlLine2."Bal. Account No.") then
                                                GenJnlLine2."Bal. Account No." := '';
                                        GenJnlLine2."Bank Payment Type" := GenJnlLine2."Bank Payment Type"::" ";
                                    end;
                                GenJnlLine2."Bal. Account Type"::"Bank Account":
                                    if GenJnlLine2."Bal. Account No." <> '' then
                                        if not BankAcc.Get(GenJnlLine2."Bal. Account No.") then
                                            GenJnlLine2."Bal. Account No." := '';
                            end;
                        end;
                    }
                    field("GenJnlLine2.""Bal. Account No."""; GenJnlLine2."Bal. Account No.")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Bal. Account No.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            case GenJnlLine2."Bal. Account Type" of
                                GenJnlLine2."Bal. Account Type"::"G/L Account":
                                    if PAGE.RunModal(0, GLAcc) = ACTION::LookupOK then
                                        GenJnlLine2."Bal. Account No." := GLAcc."No.";
                                GenJnlLine2."Bal. Account Type"::Customer, GenJnlLine2."Bal. Account Type"::Vendor:
                                    Error(Text005, GenJnlLine2.FieldCaption("Bal. Account Type"));
                                GenJnlLine2."Bal. Account Type"::"Bank Account":
                                    if PAGE.RunModal(0, BankAcc) = ACTION::LookupOK then
                                        GenJnlLine2."Bal. Account No." := BankAcc."No.";
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            if GenJnlLine2."Bal. Account No." <> '' then
                                case GenJnlLine2."Bal. Account Type" of
                                    GenJnlLine2."Bal. Account Type"::"G/L Account":
                                        GLAcc.Get(GenJnlLine2."Bal. Account No.");
                                    GenJnlLine2."Bal. Account Type"::Customer, GenJnlLine2."Bal. Account Type"::Vendor:
                                        Error(Text005, GenJnlLine2.FieldCaption("Bal. Account Type"));
                                    GenJnlLine2."Bal. Account Type"::"Bank Account":
                                        BankAcc.Get(GenJnlLine2."Bal. Account No.");
                                end;
                        end;
                    }
                    field("GenJnlLine2.""Bank Payment Type"""; GenJnlLine2."Bank Payment Type")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Bank Payment Type';
                        OptionCaption = ' ,Computer Check,Manual Check';

                        trigger OnValidate()
                        begin
                            if (GenJnlLine2."Bal. Account Type" <> GenJnlLine2."Bal. Account Type"::"Bank Account") and
                               (GenJnlLine2."Bank Payment Type" > 0)
                            then
                                Error(
                                  Text006,
                                  GenJnlLine2.FieldCaption("Bank Payment Type"),
                                  GenJnlLine2.FieldCaption("Bal. Account Type"));
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            EndRcptDate := CalcDate('-CM', WorkDate) + 14;
            if (EndRcptDate > WorkDate) then
                EndRcptDate := WorkDate;
        end;

        trigger OnOpenPage()
        begin
            CalcDates;

            if PostingDate = 0D then
                PostingDate := WorkDate;
            ValidatePostingDate;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        if PostingDate = 0D then
            Error(Text000);

        BankPmtType := GenJnlLine2."Bank Payment Type";
        BalAccType := GenJnlLine2."Bal. Account Type";
        BalAccNo := GenJnlLine2."Bal. Account No.";

        if (BankPmtType = BankPmtType::" ") and (NextDocNo = '') then
            Error(Text001);

        VendorFilters.Copy(Vendor);

        TempAmount.SetCurrentKey("Vendor No.");
    end;

    var
        StartRcptDate: Date;
        EndRcptDate: Date;
        ValuationDate: Date;
        OrderAmount: Decimal;
        CommCostMgmt: Codeunit "Commodity Cost Management";
        TempAmount: Record "Detailed Vendor Ledg. Entry" temporary;
        TempAmountEntryNo: Integer;
        VendorFilters: Record Vendor;
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlLine2: Record "Gen. Journal Line";
        GLAcc: Record "G/L Account";
        BankAcc: Record "Bank Account";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Window: Dialog;
        PostingDate: Date;
        NextDocNo: Code[20];
        FirstLineNo: Integer;
        LastLineNo: Integer;
        BankPmtType: Option " ","Computer Check","Manual Check";
        BalAccType: Option "G/L Account",Customer,Vendor,"Bank Account";
        BalAccNo: Code[20];
        Text000: Label 'Please enter a Posting Date.';
        Text001: Label 'Please enter a Starting Document No.';
        Text002: Label 'Processing Fixed Payments #1##########';
        Text003: Label 'Processing Commodity Orders #1##########';
        Text004: Label 'Processing Prior Payments #1##########';
        Text005: Label '%1 must be G/L Account or Bank Account.';
        Text006: Label '%1 must be filled only when %2 is Bank Account.';
        Text007: Label 'Starting Document No. must contain a number.';
        Text008: Label 'Adv. Payment for %1';
        Text009: Label '<Month Text>, <Year4>';
        Text010: Label 'No Advanced Payments to generate.';
        Text011: Label 'Advanced Payments generated for %1 vendors.';

    local procedure CalcDates()
    begin
        StartRcptDate := CalcDate('-CM', EndRcptDate);
        ValuationDate := StartRcptDate - 1;
    end;

    procedure SetGenJnlLine(NewGenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine := NewGenJnlLine;
    end;

    local procedure ValidatePostingDate()
    begin
        GenJnlBatch.Get(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");
        if GenJnlBatch."No. Series" = '' then
            NextDocNo := ''
        else begin
            NextDocNo := NoSeriesMgt.GetNextNo(GenJnlBatch."No. Series", PostingDate, false);
            Clear(NoSeriesMgt);
        end;
    end;

    procedure InitializeRequest(NewPostingDate: Date; NewStartDocNo: Code[20]; BalAccType: Option "G/L Account",Customer,Vendor,"Bank Account"; BalAccNo: Code[20]; BankPmtType: Option " ","Computer Check","Manual Check")
    begin
        PostingDate := NewPostingDate;
        NextDocNo := NewStartDocNo;
        GenJnlLine2."Bal. Account Type" := BalAccType;
        GenJnlLine2."Bal. Account No." := BalAccNo;
        GenJnlLine2."Bank Payment Type" := BankPmtType;
    end;

    local procedure AddTempAmount(VendorNo: Code[20]; Amt: Decimal)
    begin
        if (Amt <> 0) then begin
            TempAmount.SetRange("Vendor No.", VendorNo);
            if TempAmount.FindFirst then begin
                TempAmount.Amount := TempAmount.Amount + Amt;
                if (TempAmount.Amount = 0) then
                    TempAmount.Delete
                else
                    TempAmount.Modify;
            end else begin
                TempAmountEntryNo := TempAmountEntryNo + 1;
                TempAmount."Entry No." := TempAmountEntryNo;
                TempAmount."Vendor No." := VendorNo;
                TempAmount.Amount := Amt;
                TempAmount.Insert;
            end;
        end;
    end;

    local procedure MakeGenJnlLine()
    var
        GenJnlLine3: Record "Gen. Journal Line";
        TempDimBuf: Record "Dimension Buffer";
        DimBufMgt: Codeunit "Dimension Buffer Management";
        EntryNo: Integer;
    begin
        with GenJnlLine do begin
            Init;
            LastLineNo := LastLineNo + 10000;
            "Line No." := LastLineNo;
            Validate("Posting Date", PostingDate);
            "Document Type" := "Document Type"::Payment;
            "Posting No. Series" := GenJnlBatch."Posting No. Series";
            if (TempAmount.Amount < 0) then
                "Document Type" := "Document Type"::Refund;
            "Document No." := NextDocNo;
            NextDocNo := IncStr(NextDocNo);
            "Account Type" := "Account Type"::Vendor;
            Validate("Account No.", TempAmount."Vendor No.");
            "Bal. Account Type" := BalAccType;
            Validate("Bal. Account No.", BalAccNo);
            if (TempAmount.Amount > 0) then
                "Bank Payment Type" := BankPmtType;
            Description := StrSubstNo(Text008, Format(EndRcptDate, 0, Text009));
            "Source Code" := GenJnlTemplate."Source Code";
            "Reason Code" := GenJnlBatch."Reason Code";
            Validate(Amount, TempAmount.Amount);
            "Comm. Reference Date" := CalcDate('-CM', EndRcptDate);
            Insert;
        end;
    end;
}

