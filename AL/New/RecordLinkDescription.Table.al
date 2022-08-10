table 37002204 "Record Link Description"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection

    Caption = 'Record Link Description';

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(3; "Alert Type"; Option)
        {
            Caption = 'Alert Type';
            OptionCaption = ' ,Level 1,Level 2,Missing';
            OptionMembers = " ","Level 1","Level 2",Missing;
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

