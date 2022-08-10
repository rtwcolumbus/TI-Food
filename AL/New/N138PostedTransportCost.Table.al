table 37002098 "N138 Posted Transport Cost"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // TOM4524     29-10-2014  Cleanup field names/captions
    // --------------------------------------------------------------------------------
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Transport Cost';

    fields
    {
        field(1; "Posted No."; Code[20])
        {
            Caption = 'Posted No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Cost Component,Cost Component Template';
            OptionMembers = "Cost Component","Cost Component Template";
        }
        field(4; "Code"; Code[20])
        {
            Caption = 'Code';
            TableRelation = IF (Type = CONST("Cost Component Template")) "N138 Trans. Cost Comp Template".Code WHERE(Status = CONST(Certified))
            ELSE
            IF (Type = CONST("Cost Component")) "N138 Transport Cost Component".Code WHERE(Blocked = CONST(false));
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(6; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(7; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
        }
        field(8; Currency; Code[10])
        {
            Caption = 'Currency';
        }
        field(9; Subtype; Option)
        {
            Caption = 'Subtype';
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10";
        }
        field(10; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true));
        }
        field(11; "Purch. Invoice No."; Code[20])
        {
            CalcFormula = Lookup ("Purchase Line"."Document No." WHERE("Transport Cost Entry No" = FIELD("Entry No.")));
            Caption = 'Purch. Invoice No.';
            FieldClass = FlowField;
        }
        field(12; "Posted Amount"; Decimal)
        {
            CalcFormula = Lookup ("Purch. Inv. Line".Amount WHERE("Transport Cost Entry No" = FIELD("Entry No.")));
            Caption = 'Posted Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Posted Invoice No."; Code[20])
        {
            CalcFormula = Lookup ("Purch. Inv. Line"."Document No." WHERE("Transport Cost Entry No" = FIELD("Entry No.")));
            Caption = 'Posted Invoice No.';
            FieldClass = FlowField;
        }
        field(15; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(16; "Source Type"; Integer)
        {
            Caption = 'Source Type';
        }
        field(17; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(18; Invoiced; Boolean)
        {
            Caption = 'Invoiced';
        }
    }

    keys
    {
        key(Key1; "Source Type", Subtype, "Posted No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

