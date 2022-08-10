table 37002765 "Item Fixed Prod. Bin"
{
    // PR5.00
    // P8000494A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Production Bins/Replenishment
    // 
    // PRW15.00.01
    // P8000591A, VerticalSoft, Don Bresee, 13 MAR 08
    //   Add Fixed Production Bin / Alt. Qty. restriction
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

    Caption = 'Item Fixed Prod. Bin';
    DrillDownPageID = "Item Fixed Prod. Bins";
    LookupPageID = "Item Fixed Prod. Bins";

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
                if ("Lot Handling" <> "Lot Handling"::Manual) then
                    if ("Item No." = '') then
                        Validate("Lot Handling", "Lot Handling"::Manual)
                    else begin
                        Item.Get("Item No.");
                        if (Item."Item Tracking Code" = '') then
                            Validate("Lot Handling", "Lot Handling"::Manual);
                    end;
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
        field(3; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            NotBlank = true;
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
        }
        field(4; "Lot Handling"; Option)
        {
            Caption = 'Lot Handling';
            OptionCaption = 'Manual,FIFO,LIFO,Single Lot';
            OptionMembers = Manual,FIFO,LIFO,"Single Lot";

            trigger OnValidate()
            begin
                if ("Lot Handling" <> "Lot Handling"::Manual) then begin
                    TestField("Item No.");
                    Item.Get("Item No.");
                    Item.TestField("Item Tracking Code");
                    if ("Lot Handling" = "Lot Handling"::"Single Lot") then // P8000591A
                        Item.TestField("Alternate Unit of Measure", '');      // P8000591A
                end;
            end;
        }
        field(5; "Item Description"; Text[100])
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
        key(Key2; "Location Code", "Bin Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        TestField("Bin Code");
    end;

    var
        Item: Record Item;
        Location: Record Location;
}

