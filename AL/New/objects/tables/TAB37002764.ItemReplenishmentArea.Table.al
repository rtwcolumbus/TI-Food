table 37002764 "Item Replenishment Area"
{
    // PR5.00
    // P8000494A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Production Bins/Replenishment
    // 
    // P8001082, Columbus IT, Rick Tweedle, 25 JUL 12
    //   Changed replend area table relation to exclude staging areas
    // 
    // PRW17.10
    // P8001221, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Type added to Item table
    // 
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Item Replenishment Area';
    DrillDownPageID = "Item Replenishment Areas";
    LookupPageID = "Item Replenishment Areas";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item WHERE(Type = CONST(Inventory));

            trigger OnValidate()
            begin
                CalcFields("Item Description");
            end;
        }
        field(2; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            NotBlank = true;
            TableRelation = Location;

            trigger OnValidate()
            begin
                Location.Get("Location Code");
                Location.TestField("Bin Mandatory", true);
            end;
        }
        field(3; "Replenishment Area Code"; Code[20])
        {
            Caption = 'Replenishment Area Code';
            NotBlank = true;
            TableRelation = "Replenishment Area".Code WHERE("Location Code" = FIELD("Location Code"),
                                                             "Pre-Process Repl. Area" = CONST(false));
        }
        field(4; "Item Description"; Text[100])
        {
            CalcFormula = Lookup (Item.Description WHERE("No." = FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Location Code")
        {
        }
        key(Key2; "Location Code", "Replenishment Area Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        TestField("Replenishment Area Code");
    end;

    var
        Location: Record Location;
}

