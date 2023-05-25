table 14014910 "Sales Price 2"
{
    Caption = 'Sales Price';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(2; "Sales Code"; Code[20])
        {
            Caption = 'Sales Code';
        }
        field(3; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
        }
        field(4; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
        }
        field(5; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
        }
        field(7; "Price Includes VAT"; Boolean)
        {
            Caption = 'Price Includes Tax';
        }
        field(10; "Allow Invoice Disc."; Boolean)
        {
            Caption = 'Allow Invoice Disc.';
        }
        field(11; "VAT Bus. Posting Gr. (Price)"; Code[10])
        {
            Caption = 'Tax Bus. Posting Gr. (Price)';
        }
        field(13; "Sales Type"; Option)
        {
            Caption = 'Sales Type';
            OptionCaption = 'Customer,Customer Price Group,All Customers,Campaign';
            OptionMembers = Customer,"Customer Price Group","All Customers",Campaign;
        }
        field(14; "Minimum Quantity"; Decimal)
        {
            Caption = 'Minimum Quantity';
        }
        field(15; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
        }
        field(5400; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
        }
        field(5700; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
        }
        field(7001; "Allow Line Disc."; Boolean)
        {
            Caption = 'Allow Line Disc.';
        }
    }

    keys
    {
        key(Key1; "Item No.", "Sales Type", "Sales Code", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity")
        {
        }
    }

    fieldgroups
    {
    }
}

