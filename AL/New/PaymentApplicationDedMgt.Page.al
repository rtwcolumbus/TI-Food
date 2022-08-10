page 37002190 "Payment Application-Ded. Mgt."
{
    // PR3.70.08
    // P8000170A, Myers Nissi, Jack Reynolds, 31 JAN 05
    //   Deduction Management
    // 
    // PR3.70.09
    // P8000188A, Myers Nissi, Jack Reynolds, 22 FEB 05
    //   Fix problem with payment discount not displaying
    // 
    // PR4.00
    // P8000266B, VerticalSoft, Jack Reynolds, 10 NOV 05
    //   Modify to allow modification to payment discount date
    // 
    // PR4.00.01
    // P8000269A, VerticalSoft, Jack Reynolds, 05 DEC 05
    //   Support for comments
    // 
    // PR4.00.04
    // P8000388A, VerticalSoft, Jack Reynolds, 26 SEP 06
    //   Fix problem with no records (within filter) and can't clear filters
    // 
    // P8000405A, VerticalSoft, Jack Reynolds, 05 OCT 06
    //   Deduction Management codeunit not being cleared
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 09 NOV 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.05
    // P8000920, Columbus IT, Jack Reynolds, 21 MAR 11
    //   Use WORKDATE when posting deductions
    // 
    // PRW16.00.06
    // P8001001, Columbus IT, Jack Reynolds, 30 NOV 11
    //   Fix problem with modifying Discount Date
    // 
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW18.00
    // P8001352, Columbus IT, Jack Reynolds, 31 OCT 14
    //   Renamed from "Payment Application"
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 11 NOV 15
    //   Posting preview
    // 
    // PRW111.00
    // P80055396, To Increase, Jack Reynolds, 30 MAR 18
    //   Fix posting preview problem

    Caption = 'Payment Application';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "Cust. Ledger Entry";
    SourceTableView = SORTING("Customer No.", Open, Positive, "Due Date", "Currency Code")
                      WHERE(Open = CONST(true));

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Original Document Type"; "Original Document Type")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Original Document No."; "Original Document No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Remaining Amount"; "Remaining Amount")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Pmt. Discount Date"; "Pmt. Discount Date")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Discount Date';

                    trigger OnValidate()
                    begin
                        // P8000266B
                        if Apply then
                            Error(Text005, FieldCaption("Pmt. Discount Date"));
                        // P8000266B
                    end;
                }
                field("Remaining Pmt. Disc. Possible"; "Remaining Pmt. Disc. Possible")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Payment Discount';
                    Editable = false;
                }
                field("AmountWithDiscount(WORKDATE)"; AmountWithDiscount(WorkDate))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Amount with Discount';
                    DecimalPlaces = 2 : 2;
                    Editable = false;
                }
                field(Apply; Apply)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Apply';

                    trigger OnValidate()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit", Rec); // P8001001

                        ApplyOnPush;
                        CurrPage.Update;
                    end;
                }
                field(AmountToApply; AmountToApply)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Amount to Apply';
                    DecimalPlaces = 2 : 2;
                    Editable = AmountToApplyEditable;

                    trigger OnValidate()
                    var
                        DiscountedAmount: Decimal;
                        xAmount: Decimal;
                    begin
                        DiscountedAmount := AmountWithDiscount(WorkDate);
                        if (DiscountedAmount > 0) and (AmountToApply <= 0) then
                            Error(Text003)
                        else
                            if (DiscountedAmount < 0) and (AmountToApply >= 0) then
                                Error(Text004);

                        GetDeductionLine;
                        xAmount := DeductionLine.Amount;
                        if AmountToApply <> (DiscountedAmount - xAmount) then begin
                            DeductionLine.Validate(Amount, DiscountedAmount - AmountToApply);
                            DeductionLine.Modify;

                            if xAmount > 0 then begin
                                if DeductionLine.Amount > 0 then
                                    CurrPage.Deductions.PAGE.UpdateDeductionAmount(DeductionLine.Amount - xAmount)
                                else begin
                                    CurrPage.Deductions.PAGE.UpdateDeductionAmount(-xAmount);
                                    CurrPage.Deductions.PAGE.UpdateUnappliedAmount(DeductionLine.Amount);
                                end;
                            end else begin
                                if DeductionLine.Amount > 0 then begin
                                    CurrPage.Deductions.PAGE.UpdateDeductionAmount(DeductionLine.Amount);
                                    CurrPage.Deductions.PAGE.UpdateUnappliedAmount(-xAmount);
                                end else
                                    CurrPage.Deductions.PAGE.UpdateUnappliedAmount(DeductionLine.Amount - xAmount);
                            end;
                            CurrPage.Deductions.PAGE.UpdateForm;
                        end;
                    end;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(Deductions; "Deduction Line Subform")
            {
                ApplicationArea = FOODBasic;
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(bnEntry)
            {
                Caption = 'Ent&ry';
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Ledger Entry Comments";
                    RunPageLink = "Table ID" = CONST(21),
                                  "Entry No." = FIELD("Entry No.");
                }
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        ShowDimensions;      // P8001133
                    end;
                }
                action("Detailed &Ledger Entries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Detailed &Ledger Entries';
                    Image = LedgerEntries;
                    RunObject = Page "Detailed Cust. Ledg. Entries";
                    RunPageLink = "Cust. Ledger Entry No." = FIELD("Entry No."),
                                  "Customer No." = FIELD("Customer No.");
                    RunPageView = SORTING("Cust. Ledger Entry No.", "Posting Date");
                    ShortCutKey = 'Ctrl+F7';
                }
            }
        }
        area(processing)
        {
            action(bnPost)
            {
                ApplicationArea = FOODBasic;
                Caption = 'P&ost';
                Enabled = PostAllowed;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    DeductionMgt: Codeunit "Deduction Management";
                begin
                    // P8000405A - made DeductionMgt local
                    if not Confirm(Text001, false) then
                        exit;

                    DeductionMgt.LockTables;
                    DeductionMgt.PostDeductions(PaymentEntry, DeductionLine, WorkDate); // P8000920

                    CurrPage.Close;
                end;
            }
            action(Preview)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Posting Preview';
                Enabled = PostAllowed;
                Image = ViewPostedOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    DeductionMgt: Codeunit "Deduction Management";
                begin
                    // P8004516
                    //DeductionMgt.LockTables; // P80055396
                    DeductionMgt.PreviewPostDeductions(PaymentEntry, DeductionLine, WorkDate);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        SetEditable;
    end;

    trigger OnAfterGetRecord()
    begin
        Apply := GetApplied;
        if Apply then
            AmountToApply := AmountWithDiscount(WorkDate) - DeductionLine.Amount
        else
            AmountToApply := 0;
    end;

    trigger OnInit()
    begin
        AmountToApplyEditable := true;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        // P8000266B
        CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit", Rec);
        exit(false);
        // P8000266B
    end;

    trigger OnOpenPage()
    var
        DedLine: Record "Deduction Line";
        CustLedger: Record "Cust. Ledger Entry";
        AmtToApply: Decimal;
    begin
        DedLine.SetPosition(DeductionLineKey);
        CurrPage.Deductions.PAGE.SetLink(DedLine."Source Table No.", DedLine."Source ID",
          DedLine."Source Batch Name", DedLine."Source Ref. No.");

        DeductionLine.SetRange(Type, DeductionLine.Type::Application);
        if DeductionLine.Find('-') then
            repeat
                CustLedger.Get(DeductionLine."Applies-to Entry No.");
                AmtToApply := CustLedger.AmountWithDiscount(WorkDate);
                if AmtToApply <> 0 then begin
                    TotalApplication += AmtToApply;
                    if (not CustLedger.Positive) or (DeductionLine.Amount < 0) then
                        TotalUnapplied += DeductionLine.Amount;
                end else
                    DeductionLine.Delete(true);
            until DeductionLine.Next = 0;
        DeductionLine.SetRange(Type);

        CurrPage.Deductions.PAGE.SetPaymentAmount(TotalPayment);
        CurrPage.Deductions.PAGE.UpdateApplicationAmount(TotalApplication);
        CurrPage.Deductions.PAGE.UpdateUnappliedAmount(TotalUnapplied);

        if not PostAllowed then begin                    // P8000269A
            bnEntryXPos := bnLineXPos; // P8000269A
            bnLineXPos := bnPostXPos;
        end;                                             // P8000269A
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if DeductionLine.Count <= 1 then
            DeductionLine.DeleteAll
        else
            if PostAllowed then
                exit(Confirm(Text002, false));
    end;

    var
        PaymentEntry: Record "Cust. Ledger Entry";
        DeductionLine: Record "Deduction Line";
        DeductionLineKey: Text[1024];
        TotalPayment: Decimal;
        TotalApplication: Decimal;
        TotalUnapplied: Decimal;
        Apply: Boolean;
        Text001: Label 'Do you want to post the payment application?';
        Text002: Label 'Application has not been posted.  Continue?';
        AmountToApply: Decimal;
        Text003: Label 'Amount to apply must be greater than 0.';
        Text004: Label 'Amount to apply must be less than 0.';
        [InDataSet]
        PostAllowed: Boolean;
        Text005: Label 'Application must be cleared before %1 can be modified.';
        bnEntryXPos: Integer;
        bnLineXPos: Integer;
        bnPostXPos: Integer;
        [InDataSet]
        AmountToApplyEditable: Boolean;

    procedure SetParameters(CustNo: Code[20]; Amt: Decimal; DedLine: Record "Deduction Line")
    var
        tmp: Integer;
    begin
        FilterGroup(2);
        SetRange("Customer No.", CustNo);
        if DedLine."Source Table No." = DATABASE::"Cust. Ledger Entry" then
            SetFilter("Entry No.", '<>%1', DedLine."Source Ref. No.");
        FilterGroup(0);

        TotalPayment := -Amt;

        DeductionLine.FilterGroup(9);
        DeductionLine.SetRange("Source Table No.", DedLine."Source Table No.");
        DeductionLine.SetRange("Source ID", DedLine."Source ID");
        DeductionLine.SetRange("Source Batch Name", DedLine."Source Batch Name");
        DeductionLine.SetRange("Source Ref. No.", DedLine."Source Ref. No.");
        DeductionLine.FilterGroup(0);

        DeductionLineKey := DedLine.GetPosition;

        DeductionLine.SetRange(Type, DeductionLine.Type::Remainder);
        if not DeductionLine.Find('-') then begin
            DeductionLine.SetPosition(DeductionLineKey);
            DeductionLine.Type := DeductionLine.Type::Remainder;
            DeductionLine."Line No." := 10000;
            DeductionLine.Insert(true);
            Commit;
        end;
        DeductionLine.SetRange(Type);

        if DedLine."Source Table No." = DATABASE::"Cust. Ledger Entry" then begin
            PaymentEntry.Get(DedLine."Source Ref. No.");
            PostAllowed := true;
        end;
    end;

    procedure GetApplied() Applied: Boolean
    begin
        DeductionLine.SetRange(Type, DeductionLine.Type::Application);
        DeductionLine.SetRange("Applies-to Entry No.", "Entry No.");
        Applied := DeductionLine.Find('-');
        DeductionLine.SetRange(Type);
        DeductionLine.SetRange("Applies-to Entry No.");
    end;

    procedure SetEditable()
    begin
        AmountToApplyEditable := Apply;
    end;

    procedure GetDeductionLine()
    begin
        DeductionLine.SetRange(Type, DeductionLine.Type::Application);
        DeductionLine.SetRange("Applies-to Entry No.", "Entry No.");
        DeductionLine.Find('-');
        DeductionLine.SetRange(Type);
        DeductionLine.SetRange("Applies-to Entry No.");
    end;

    local procedure ApplyOnPush()
    var
        CustLedger: Record "Cust. Ledger Entry";
        LineNo: Integer;
        Amt: array[3] of Decimal;
    begin
        DeductionLine.SetRange(Type, DeductionLine.Type::Application);
        if Apply then begin
            DeductionLine.LockTable;
            if DeductionLine.Find('+') then
                LineNo := DeductionLine."Line No.";
            DeductionLine.SetPosition(DeductionLineKey);
            DeductionLine.Type := DeductionLine.Type::Application;
            DeductionLine."Line No." := LineNo + 10000;
            DeductionLine."Applies-to Entry No." := "Entry No.";
            DeductionLine.Amount := 0;
            DeductionLine.Insert(true);
            Amt[1] := AmountWithDiscount(WorkDate);
        end else begin
            DeductionLine.SetRange("Applies-to Entry No.", "Entry No.");
            DeductionLine.Find('-');
            DeductionLine.Delete(true);
            CustLedger.Get(DeductionLine."Applies-to Entry No.");
            Amt[1] := -AmountWithDiscount(WorkDate);
            if DeductionLine.Amount > 0 then
                Amt[2] := -DeductionLine.Amount
            else
                Amt[3] := -DeductionLine.Amount;
            DeductionLine.SetRange("Applies-to Entry No.");
        end;
        DeductionLine.SetRange(Type);

        TotalApplication += Amt[1];
        CurrPage.Deductions.PAGE.UpdateApplicationAmount(TotalApplication);
        if Amt[2] <> 0 then begin
            CurrPage.Deductions.PAGE.UpdateDeductionAmount(Amt[2]);
            CurrPage.Deductions.PAGE.UpdateForm;
        end;
        if Amt[3] <> 0 then begin
            CurrPage.Deductions.PAGE.UpdateUnappliedAmount(Amt[3]);
            CurrPage.Deductions.PAGE.UpdateForm;
        end;

        SetEditable;
    end;
}

