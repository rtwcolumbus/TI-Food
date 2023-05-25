table 37002044 "Order Off-Invoice Allowance"
{
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 04 AUG 08
    //   Caption was Order Off-Invoice Allowances
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Order Off-Invoice Allowance';

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            Editable = false;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,Standing Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","Standing Order";
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
            TableRelation = "Sales Header"."No." WHERE("Document Type" = FIELD("Document Type"));
        }
        field(3; "Allowance Code"; Code[10])
        {
            Caption = 'Allowance Code';
            Editable = false;
            TableRelation = "Off-Invoice Allowance Header";
        }
        field(4; Description; Text[100])
        {
            CalcFormula = Lookup ("Off-Invoice Allowance Header".Description WHERE(Code = FIELD("Allowance Code")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Grant Allowance"; Boolean)
        {
            Caption = 'Grant Allowance';
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Allowance Code")
        {
        }
        key(Key2; "Allowance Code")
        {
        }
    }

    fieldgroups
    {
    }
}

