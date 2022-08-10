table 37002674 "Posted Sales Payment Header"
{
    // PRW16.00.05
    // P8000941, Columbus IT, Don Bresee, 25 JUL 11
    //   Sales Payments granule
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Posted Sales Payment Header';
    DataCaptionFields = "No.", "Customer Name";
    LookupPageID = "Sales Payment List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
        }
        field(4; Amount; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum ("Posted Sales Payment Line".Amount WHERE("Document No." = FIELD("No.")));
            Caption = 'Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Amount Tendered"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum ("Sales Payment Tender Entry".Amount WHERE("Document No." = FIELD("No.")));
            Caption = 'Amount Tendered';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(13; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(1001; "Sales Payment No."; Code[20])
        {
            Caption = 'Sales Payment No.';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Customer No.", "Posting Date")
        {
        }
    }

    fieldgroups
    {
    }

    procedure ShowInvoice()
    var
        SalesInvoice: Record "Sales Invoice Header";
    begin
        SalesInvoice.Get("No.");
        SalesInvoice.SetRecFilter;
        PAGE.Run(PAGE::"Posted Sales Invoice", SalesInvoice);
    end;

    procedure Navigate()
    var
        NavigateForm: Page Navigate;
    begin
        NavigateForm.SetDoc("Posting Date", "No.");
        NavigateForm.Run;
    end;

    procedure Print()
    var
        SalesPayment: Record "Posted Sales Payment Header";
        SalesPaymentRpt: Report "Sales Payment - Posted";
    begin
        SalesPayment.Get("No.");
        SalesPayment.SetRecFilter;
        SalesPaymentRpt.SetTableView(SalesPayment);
        SalesPaymentRpt.RunModal;
    end;
}

