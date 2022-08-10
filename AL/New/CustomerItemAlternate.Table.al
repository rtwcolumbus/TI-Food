table 37002010 "Customer Item Alternate"
{
    // PRW15.00.01
    // P8000589A, VerticalSoft, Don Bresee, 05 MAR 08
    //   Add alternate sales items by Customer
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Customer Item Alternate';

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            NotBlank = true;
            TableRelation = Customer;
        }
        field(2; "Sales Item No."; Code[20])
        {
            Caption = 'Sales Item No.';
            NotBlank = true;
            TableRelation = Item;

            trigger OnValidate()
            begin
                if ("Sales Item No." <> '') and ("Alternate Item No." = "Sales Item No.") then
                    FieldError("Alternate Item No.");

                CalcFields("Sales Item Description");
            end;
        }
        field(3; "Alternate Item No."; Code[20])
        {
            Caption = 'Alternate Item No.';
            TableRelation = Item;

            trigger OnValidate()
            begin
                if ("Alternate Item No." <> '') and ("Alternate Item No." = "Sales Item No.") then
                    FieldError("Sales Item No.");

                CalcFields("Alternate Item Description");
            end;
        }
        field(4; "Sales Item Description"; Text[100])
        {
            CalcFormula = Lookup (Item.Description WHERE("No." = FIELD("Sales Item No.")));
            Caption = 'Sales Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Alternate Item Description"; Text[100])
        {
            CalcFormula = Lookup (Item.Description WHERE("No." = FIELD("Alternate Item No.")));
            Caption = 'Alternate Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Customer No.", "Sales Item No.", "Alternate Item No.")
        {
        }
    }

    fieldgroups
    {
    }
}

