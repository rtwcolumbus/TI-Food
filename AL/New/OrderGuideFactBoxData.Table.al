table 37002056 "Order Guide FactBox Data"
{
    // PRW114.00
    // P80072447/P80072449, To-Increase, Gangabhushan, 24 APR 19
    //   New table created to Display factbox information for Contracts and Margins in Sales Order Guide.

    Caption = 'Order Guide FactBox Data';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Enry No."; Integer)
        {
            Caption = 'Enry No.';
            DataClassification = SystemMetadata;
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Contract,Margin';
            OptionMembers = Contract,Margin;
        }
        field(10; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Sales Contract";
        }
        field(11; "Contract Limit"; Decimal)
        {
            Caption = 'Contract Limit';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(12; "Contract Limit Unit of Measure"; Code[10])
        {
            Caption = 'Contract Limit Unit of Measure';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Unit of Measure";
        }
        field(13; "Contract Limit Used"; Decimal)
        {
            Caption = 'Contract Limit Used';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(14; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
        }
        field(21; "Contract Line Limit"; Decimal)
        {
            Caption = 'Contract Line Limit';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(22; "Contract Line Limit UOM"; Code[10])
        {
            Caption = 'Contract Line Limit UOM';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(23; "Contract  Line Limit Used"; Decimal)
        {
            Caption = 'Contract Line Limit Used';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(31; "Expected Margin (LCY)"; Decimal)
        {
            Caption = 'Expected Margin (LCY)';
            DataClassification = SystemMetadata;
        }
        field(32; "Expected Margin Pct."; Decimal)
        {
            Caption = 'Expected Margin Pct.';
            DataClassification = SystemMetadata;
        }
        field(33; "Item Category"; Code[20])
        {
            Caption = 'Item Category';
            DataClassification = SystemMetadata;
        }
        field(34; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
        }
        field(35; "Unit Price (LCY)"; Decimal)
        {
            Caption = 'Unit Price (LCY)';
            DataClassification = SystemMetadata;
        }
        field(36; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = SystemMetadata;
        }
        field(37; "Total Margin"; Decimal)
        {
            Caption = 'Total Margin';
            DataClassification = SystemMetadata;
        }
        field(38; "Previous Quantity"; Decimal)
        {
            Caption = 'Previous Quantity';
            DataClassification = SystemMetadata;
        }
        field(39; "Previous Unit Price (LCY)"; Decimal)
        {
            Caption = 'Previous Unit Price (LCY)';
            DataClassification = SystemMetadata;
        }
        field(40; "Previous Expected Margin (LCY)"; Decimal)
        {
            Caption = 'Previous Expected Margin (LCY)';
            DataClassification = SystemMetadata;
        }
        field(41; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = SystemMetadata;
            MinValue = 0;
        }
        field(42; "Presentation Order"; Integer)
        {
            Caption = 'Presentation Order';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Enry No.")
        {
        }
        key(Key2; "Item Category")
        {
        }
        key(Key3; "Presentation Order")
        {
        }
    }

    fieldgroups
    {
    }
}

