table 37002096 "N138 Transport Cost Component"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Transport Cost Component';
    DrillDownPageID = "N138 Transport Cost Components";
    LookupPageID = "N138 Transport Cost Components";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
        field(4; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true));
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

