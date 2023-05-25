table 37002484 "Production Planning Event"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Table of non-production planning events
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Production Planning Event';

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
        field(3; "Duration (Hours)"; Decimal)
        {
            Caption = 'Duration (Hours)';
            DecimalPlaces = 0 : 3;
            MinValue = 0;
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

