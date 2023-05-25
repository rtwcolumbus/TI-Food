table 37002921 "Allergen Set Entry"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Allergen Set Entry';

    fields
    {
        field(1; "Allergen Set ID"; Integer)
        {
            Caption = 'Allergen Set ID';
        }
        field(2; "Allergen Code"; Code[10])
        {
            Caption = 'Allergen Code';
            NotBlank = true;
            TableRelation = Allergen;

            trigger OnValidate()
            var
                Allergen: Record Allergen;
            begin
                Allergen.Get("Allergen Code");
                Allergen.TestField(Blocked, false);
                "Allergen ID" := Allergen."Allergen ID";
            end;
        }
        field(3; Presence; Option)
        {
            Caption = 'Presence';
            InitValue = Allergen;
            OptionCaption = ',,,May Contain,,,,Allergen';
            OptionMembers = ,,,"May Contain",,,,Allergen;
        }
        field(4; "Allergen ID"; Integer)
        {
            Caption = 'Allergen ID';
        }
        field(5; "Allergen Description"; Text[100])
        {
            CalcFormula = Lookup (Allergen.Description WHERE(Code = FIELD("Allergen Code")));
            Caption = 'Allergen Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; "Pending Change"; Option)
        {
            Caption = 'Pending Change';
            OptionCaption = ' ,Add,Delete,Change Presence';
            OptionMembers = " ",Add,Delete,"Change Presence";
        }
        field(11; "Table No. Filter"; Integer)
        {
            Caption = 'Table No. Filter';
            FieldClass = FlowFilter;
        }
        field(12; "Type Filter"; Integer)
        {
            Caption = 'Type Filter';
            FieldClass = FlowFilter;
        }
        field(13; "No. Filter"; Code[20])
        {
            Caption = 'No. Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1; "Allergen Set ID", "Allergen Code")
        {
        }
    }

    fieldgroups
    {
    }
}

