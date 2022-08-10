table 37002670 "Lot Summary"
{
    // PR4.00
    // P8000244A, Myers Nissi, Jack Reynolds, 03 OCT 05
    //   Temporary table used for display of lot summary form
    // 
    // PRW15.00.03
    // P8000624A, VerticalSoft, Jack Reynolds, 19 AUG 08
    //   Add field for country/region of origin
    // 
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Lot Summary';
    ReplicateData = false;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = Item;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(3; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Lot No. Information"."Lot No." WHERE("Item No." = FIELD("Item No."),
                                                                   "Variant Code" = FIELD("Variant Code"));
        }
        field(4; "Lot Detail"; Boolean)
        {
            Caption = 'Lot Detail';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(5; "Unit Sales Price"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Sales Price';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(6; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(9; Expanded; Boolean)
        {
            Caption = 'Expanded';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(10; Display; Boolean)
        {
            Caption = 'Display';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(11; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(12; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(13; "Release Date"; Date)
        {
            Caption = 'Release Date';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(14; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(15; "Source Type"; Option)
        {
            Caption = 'Source Type';
            DataClassification = SystemMetadata;
            Editable = false;
            OptionCaption = ' ,Customer,Vendor,Item';
            OptionMembers = " ",Customer,Vendor,Item;
        }
        field(16; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = IF ("Source Type" = CONST(Customer)) Customer
            ELSE
            IF ("Source Type" = CONST(Vendor)) Vendor;
        }
        field(17; "Source Name"; Text[100])
        {
            Caption = 'Source Name';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(18; Farm; Text[30])
        {
            Caption = 'Farm';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(19; Brand; Text[30])
        {
            Caption = 'Brand';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(20; "Country/Region of Origin Code"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            DataClassification = SystemMetadata;
            TableRelation = "Country/Region";
        }
        field(21; "Original Quantity"; Decimal)
        {
            Caption = 'Original Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(22; "Quantity Sold"; Decimal)
        {
            Caption = 'Quantity Sold';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(23; "Quantity Adjusted"; Decimal)
        {
            Caption = 'Quantity Adjusted';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(24; "Quantity On Hand"; Decimal)
        {
            Caption = 'Quantity On Hand';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(25; "Sales Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Sales Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(26; "Cost Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Cost Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(27; "Extra Charge Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Extra Charge Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(28; "Item Charge Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Item Charge Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(29; "Accrual Plan Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Accrual Plan Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(30; "Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Lot No.", "Lot Detail", "Unit Sales Price")
        {
        }
    }

    fieldgroups
    {
    }

    procedure ExpansionStatus(): Integer
    begin
        case true of
            "Lot Detail":
                exit(2);
            Expanded:
                exit(0);
            else
                exit(1);
        end;
    end;
}

