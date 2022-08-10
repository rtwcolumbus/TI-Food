table 37002051 "Item Cost Conversion Factor"
{
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   New table for cost conversions between items (used in cost based sales price calculation)

    Caption = 'Item Cost Conversion Factor';

    fields
    {
        field(1; "Cost Calc. Item No."; Code[20])
        {
            Caption = 'Cost Calc. Item No.';
            NotBlank = true;
            TableRelation = Item;
        }
        field(2; "Pricing Item No."; Code[20])
        {
            Caption = 'Pricing Item No.';
            NotBlank = true;
            TableRelation = Item;

            trigger OnValidate()
            begin
                if ("Pricing Item No." = "Cost Calc. Item No.") then
                    FieldError("Pricing Item No.");
            end;
        }
        field(3; "Costing Qty."; Decimal)
        {
            BlankZero = true;
            Caption = 'Costing Qty.';
            DecimalPlaces = 0 : 5;
            InitValue = 1;
            MinValue = 0;

            trigger OnValidate()
            begin
                if ("Costing Qty." = 0) then
                    "Costing Qty." := 1;
            end;
        }
        field(4; "Equivalent Pricing Qty."; Decimal)
        {
            BlankZero = true;
            Caption = 'Equivalent Pricing Qty.';
            DecimalPlaces = 0 : 5;
            InitValue = 1;
            MinValue = 0;

            trigger OnValidate()
            begin
                if ("Equivalent Pricing Qty." = 0) then
                    "Equivalent Pricing Qty." := 1;
            end;
        }
    }

    keys
    {
        key(Key1; "Cost Calc. Item No.", "Pricing Item No.")
        {
        }
    }

    fieldgroups
    {
    }
}

