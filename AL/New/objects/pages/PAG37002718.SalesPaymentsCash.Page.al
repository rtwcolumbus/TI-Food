page 37002718 "Sales Payments - Cash"
{
    // PRW16.00.05
    // P8000941, Columbus IT, Don Bresee, 25 JUL 11
    //   Sales Payments granule
    // 
    // PRW17.00
    // P8001149, Columbus IT, Don Bresee, 24 APR 13
    //   Change calling of page to use lookup mode
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names

    Caption = 'Sales Payments - Cash';
    PageType = Card;
    SaveValues = true;
    SourceTable = "Sales Payment Header";

    layout
    {
        area(content)
        {
            group(Payment)
            {
                group(Control37002012)
                {
                    ShowCaption = false;
                    field(TenderedAmount; TenderedAmount)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Tendered';
                        MinValue = 0;

                        trigger OnValidate()
                        begin
                            SetChangeAmount;
                        end;
                    }
                    field(ChangeAmount; ChangeAmount)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Change';
                        MinValue = 0;

                        trigger OnValidate()
                        var
                            RefundOK: Boolean;
                        begin
                            if (ChangeAmount > TenderedAmount) then begin
                                if (GetBalance(false) > 0) then
                                    RefundOK := Confirm(
                                      Text000, false, GetAmountStr(GetBalance(false)), GetAmountStr(ChangeAmount - TenderedAmount))
                                else
                                    if ((ChangeAmount - TenderedAmount) <= -GetBalance(false)) then
                                        RefundOK := true
                                    else
                                        RefundOK := Confirm(
                                          Text001, false, GetAmountStr((ChangeAmount - TenderedAmount) + GetBalance(false)),
                                          GetAmountStr(ChangeAmount - TenderedAmount));
                                if not RefundOK then
                                    SetChangeAmount;
                            end;
                        end;
                    }
                    field(PaymentMethodCode; PaymentMethodCode)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Cash Method';
                        NotBlank = true;
                        TableRelation = "Payment Method" WHERE("Cash Tender Method" = CONST(true),
                                                                "Bal. Account No." = FILTER(<> ''));
                    }
                }
            }
            fixed(Sale)
            {
                group(Control37002013)
                {
                    ShowCaption = false;
                    field("'Customer No.:'"; 'Customer No.:')
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field("'Customer Name:'"; 'Customer Name:')
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field("'Total:'"; 'Total:')
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field("'Paid:'"; 'Paid:')
                    {
                        ApplicationArea = FOODBasic;
                        ShowCaption = false;
                    }
                    field("'Balance:'"; 'Balance:')
                    {
                        ApplicationArea = FOODBasic;
                        AutoFormatType = 1;
                        ShowCaption = false;
                    }
                }
                group(Control37002017)
                {
                    ShowCaption = false;
                    field("Customer No."; "Customer No.")
                    {
                        ApplicationArea = FOODBasic;
                        Editable = false;
                        Lookup = false;
                    }
                    field("Customer Name"; "Customer Name")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field(Amount; Amount)
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = false;
                        DrillDown = false;
                    }
                    field("Amount Tendered"; "Amount Tendered")
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = false;
                        DrillDown = false;
                    }
                    field("GetBalance(FALSE)"; GetBalance(false))
                    {
                        ApplicationArea = FOODBasic;
                        AutoFormatType = 1;
                        BlankZero = false;
                        ShowCaption = false;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("P&ost")
            {
                ApplicationArea = FOODBasic;
                Caption = 'P&ost';
                Ellipsis = true;
                Image = Post;
                ShortCutKey = 'F9';

                trigger OnAction()
                begin
                    if PostCash() then
                        CurrPage.Close;
                end;
            }
        }
        area(Promoted)
        {
            actionref(Post_Promoted; "P&ost")
            {
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        Get(SalesPaymentHeader."No.");
        CalcFields(Amount, "Amount Tendered");
        exit(true);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(0);
    end;

    trigger OnOpenPage()
    begin
        Get(SalesPaymentHeader."No.");
        SetPositiveAmount(TenderedAmount, GetBalance(true));
        SetChangeAmount;
        InitPaymentMethod;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        // IF (CloseAction = ACTION::OK) THEN    // P8001149
        if (CloseAction = ACTION::LookupOK) then // P8001149
            exit(PostCash());
    end;

    var
        SalesPaymentHeader: Record "Sales Payment Header";
        TenderedAmount: Decimal;
        ChangeAmount: Decimal;
        PaymentMethodCode: Code[10];
        PaymentMethod: Record "Payment Method";
        Text000: Label 'The customer owes $%1.\\Are you sure you want to refund $%2?';
        Text001: Label 'The refund exceeds the amount the customer is due by $%1.\\Are you sure you want to refund $%2?';
        Text002: Label 'Nothing to Post.';
        Text003: Label 'Post Cash Payment of $%1?';
        Text004: Label 'Post Cash Refund of $%1?';

    procedure SetPayment(var SalesPaymentHeader2: Record "Sales Payment Header")
    begin
        SalesPaymentHeader.Copy(SalesPaymentHeader2);
    end;

    local procedure InitPaymentMethod()
    begin
        if PaymentMethod.Get(PaymentMethodCode) then
            if not PaymentMethod."Cash Tender Method" or (PaymentMethod."Bal. Account No." = '') then
                Clear(PaymentMethodCode);
        if not PaymentMethod.Get(PaymentMethodCode) then begin
            PaymentMethod.SetRange("Cash Tender Method", true);
            PaymentMethod.SetFilter("Bal. Account No.", '<>%1', '');
            if PaymentMethod.FindFirst then
                PaymentMethodCode := PaymentMethod.Code;
        end;
    end;

    local procedure SetChangeAmount()
    begin
        SetPositiveAmount(ChangeAmount, TenderedAmount - GetBalance(false));
    end;

    local procedure SetPositiveAmount(var Amt: Decimal; NewAmt: Decimal)
    begin
        if (NewAmt < 0) then
            Amt := 0
        else
            Amt := NewAmt;
    end;

    local procedure PostCash(): Boolean
    var
        PaymentMethod: Record "Payment Method";
        SalesPaymentPost: Codeunit "Sales Payment-Post";
    begin
        PaymentMethod.Get(PaymentMethodCode);
        if (ChangeAmount = TenderedAmount) then
            Error(Text002);
        if not Confirm(GetConfirmPostMsg()) then
            exit(false);
        SalesPaymentPost.PostCashTender(Rec, PaymentMethod, TenderedAmount - ChangeAmount);
        Commit;
        exit(true);
    end;

    local procedure GetConfirmPostMsg(): Text[250]
    begin
        if (TenderedAmount > ChangeAmount) then
            exit(StrSubstNo(Text003, GetAmountStr(TenderedAmount - ChangeAmount)));
        exit(StrSubstNo(Text004, GetAmountStr(ChangeAmount - TenderedAmount)));
    end;
}

