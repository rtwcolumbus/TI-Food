table 37002124 "Accrual Payment Group Line"
{
    // PR3.61AC

    Caption = 'Accrual Payment Group Line';

    fields
    {
        field(1; "Accrual Payment Group"; Code[10])
        {
            Caption = 'Accrual Payment Group';
            TableRelation = "Accrual Payment Group";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Source Bill-to/Pay-to,Customer,Vendor,G/L Account,Payment Group';
            OptionMembers = "Source Bill-to/Pay-to",Customer,Vendor,"G/L Account","Payment Group";
        }
        field(4; "Code"; Code[20])
        {
            Caption = 'Code';
            TableRelation = IF (Type = CONST(Customer)) Customer
            ELSE
            IF (Type = CONST(Vendor)) Vendor
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account"
            ELSE
            IF (Type = CONST("Payment Group")) "Accrual Payment Group";

            trigger OnValidate()
            begin
                if (Type = Type::"Source Bill-to/Pay-to") then
                    TestField(Code, '');
            end;
        }
        field(5; "Payment %"; Decimal)
        {
            Caption = 'Payment %';
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(Key1; "Accrual Payment Group", "Line No.")
        {
            SumIndexFields = "Payment %";
        }
    }

    fieldgroups
    {
    }
}

