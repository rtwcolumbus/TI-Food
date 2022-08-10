table 37002042 "Off-Invoice Allowance Header"
{
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Off-Invoice Allowance Header';
    LookupPageID = "Off-Invoice Allowance List";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "G/L Account"; Code[20])
        {
            Caption = 'G/L Account';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                GLAcc.Get("G/L Account");
                GLAcc.CheckGLAcc;
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        OrderAllowance.SetCurrentKey("Allowance Code");
        OrderAllowance.SetRange("Allowance Code", Code);
        if OrderAllowance.Find('-') then
            Error(Text000, OrderAllowance."Document Type", OrderAllowance."Document No.");

        AllowanceLine.SetRange("Allowance Code", Code);
        AllowanceLine.DeleteAll;
    end;

    var
        AllowanceLine: Record "Off-Invoice Allowance Line";
        OrderAllowance: Record "Order Off-Invoice Allowance";
        Text000: Label 'Allowance is used in %1 %2 and cannot be deleted.';
        GLAcc: Record "G/L Account";
}

