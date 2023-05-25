table 37002673 "Sales Payment Tender Entry"
{
    // PRW16.00.05
    // P8000941, Columbus IT, Don Bresee, 25 JUL 11
    //   Sales Payments granule
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Sales Payment Tender Entry';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(3; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(4; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Payment,Refund,Void';
            OptionMembers = Payment,Refund,Void;
        }
        field(5; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(7; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
        }
        field(8; "Card/Check No."; Code[20])
        {
            Caption = 'Card/Check No.';
        }
        field(9; "Cust. Ledger Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Cust. Ledger Entry No.';
            TableRelation = "Cust. Ledger Entry";
        }
        field(10; "Authorization Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Authorization Entry No.';
        }
        field(11; "Capture Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Capture Entry No.';
        }
        field(12; "Voided by Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Voided by Entry No.';
            TableRelation = "Sales Payment Tender Entry";
        }
        field(13; Result; Option)
        {
            Caption = 'Result';
            OptionCaption = ' ,Posted,Authorized,Voided,Failed Authorization,Failed Capture';
            OptionMembers = " ",Posted,Authorized,Voided,"Failed Authorization","Failed Capture";
        }
        field(14; "Cash Tender"; Boolean)
        {
            CalcFormula = Lookup ("Payment Method"."Cash Tender Method" WHERE(Code = FIELD("Payment Method Code")));
            Caption = 'Cash Tender';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Document No.")
        {
        }
        key(Key3; "Cust. Ledger Entry No.")
        {
        }
        key(Key4; "Document No.", "Payment Method Code", "Card/Check No.", "Cust. Ledger Entry No.")
        {
            SumIndexFields = Amount;
        }
    }

    fieldgroups
    {
    }

    procedure FindPending(SalesPaymentNo: Code[20]; PaymentMethodCode: Code[10]; CardCheckNo: Code[20]): Boolean
    begin
        Reset;
        SetCurrentKey("Document No.", "Payment Method Code", "Card/Check No.", "Cust. Ledger Entry No.");
        SetRange("Document No.", SalesPaymentNo);
        SetRange("Payment Method Code", PaymentMethodCode);
        SetRange("Card/Check No.", CardCheckNo);
        SetRange("Cust. Ledger Entry No.", 0);
        SetFilter(Type, '<>%1', Type::Void);
        SetRange("Voided by Entry No.", 0);
        exit(FindLast);
    end;
}

