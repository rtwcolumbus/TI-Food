table 37002807 "Work Order Cause Code"
{
    // PR4.00.40
    // P8000333A, VerticalSoft, Jack Reynolds, 30 AUG 06
    //   Standard code/description table for cause codes
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Work Order Cause Code';
    LookupPageID = "Work Order Cause Codes";

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
}

