table 37002037 "Lot No. Custom Format Line"
{
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Lot No. Custom Format Line';

    fields
    {
        field(1; "Custom Format Code"; Code[10])
        {
            Caption = 'Custom Format Code';
            TableRelation = "Lot No. Custom Format";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Code,Text';
            OptionMembers = "Code",Text;
        }
        field(4; Segment; Code[10])
        {
            Caption = 'Segment';
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(6; "Segment Code"; Code[10])
        {
            Caption = 'Segment Code';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Custom Format Code", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

