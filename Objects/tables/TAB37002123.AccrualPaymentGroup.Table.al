table 37002123 "Accrual Payment Group"
{
    // PR3.61AC
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Accrual Payment Group';
    DataCaptionFields = "Code", Description;
    LookupPageID = "Accrual Payment Groups";

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
        AccrualPaymentGroupLine.SetRange("Accrual Payment Group", Code);
        AccrualPaymentGroupLine.DeleteAll(true);
    end;

    var
        AccrualPaymentGroupLine: Record "Accrual Payment Group Line";
}

