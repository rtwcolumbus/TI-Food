table 37002135 "Accrual Computation Group"
{
    // PR3.61AC

    Caption = 'Accrual Computation Group';
    DataCaptionFields = "Code", Description;
    LookupPageID = "Accrual Computation Groups";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[50])
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
}

