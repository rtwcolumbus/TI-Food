table 37002661 "Sales Line Repack"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Sales Line Repack';

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,Standing Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","Standing Order";
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; "Repack Quantity"; Decimal)
        {
            Caption = 'Repack Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(6; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
        }
        field(8; "Repack Item No."; Code[20])
        {
            Caption = 'Repack Item No.';
        }
        field(9; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
        }
        field(10; "Repack Quantity (Alt.)"; Decimal)
        {
            Caption = 'Repack Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
        }
        field(20; "Target Item No."; Code[20])
        {
            Caption = 'Target Item No.';
        }
        field(21; "Target Quantity"; Decimal)
        {
            Caption = 'Target Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(22; "Target Quantity (Alt.)"; Decimal)
        {
            Caption = 'Target Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Line No.")
        {
        }
        key(Key2; "Repack Item No.", "Variant Code", "Lot No.", "Location Code")
        {
            SumIndexFields = "Repack Quantity", "Repack Quantity (Alt.)";
        }
        key(Key3; "Target Item No.", "Variant Code", "Lot No.", "Location Code")
        {
            SumIndexFields = "Target Quantity", "Target Quantity (Alt.)";
        }
    }

    fieldgroups
    {
    }
}

