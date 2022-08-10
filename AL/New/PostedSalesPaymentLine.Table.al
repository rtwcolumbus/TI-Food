table 37002675 "Posted Sales Payment Line"
{
    // PRW16.00.05
    // P8000941, Columbus IT, Don Bresee, 25 JUL 11
    //   Sales Payments granule
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Posted Sales Payment Line';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "Posted Sales Payment Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(4; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,Order,Open Entry,Payment Fee';
            OptionMembers = " ","Order","Open Entry","Payment Fee";
        }
        field(5; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(6; "Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Entry No.';
            TableRelation = IF (Type = CONST("Open Entry")) "Cust. Ledger Entry"."Entry No."
            ELSE
            IF (Type = CONST("Payment Fee")) "Cust. Ledger Entry"."Entry No.";
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            SumIndexFields = Amount;
        }
        key(Key2; Type, "No.")
        {
        }
        key(Key3; Type, "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

