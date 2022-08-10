table 37002581 "Item Variant Variable"
{
    // PR2.00.05
    //   Associates package variables with actual items for item variants
    // 
    // PRW17.10
    // P8001221, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Type added to Item table

    Caption = 'Item Variant Variable';
    DataCaptionFields = "Item No.", "Variant Code";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item WHERE(Type = CONST(Inventory));
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(3; "Package Variable Code"; Code[10])
        {
            Caption = 'Package Variable Code';
            TableRelation = "Package Variable";

            trigger OnLookup()
            var
                ProdBomLine: Record "Production BOM Line";
                ItemVariant: Record "Item Variant";
            begin
                if ItemVariant.Get("Item No.", "Variant Code") then begin
                    ProdBomLine.SetRange("Production BOM No.", ItemVariant."Production BOM No.");
                    ProdBomLine.SetRange(Type, ProdBomLine.Type::FOODVariable);
                    if ProdBomLine.Find('-') then
                        repeat
                            if PackVar.Get(ProdBomLine."No.") then
                                PackVar.Mark(true);
                        until ProdBomLine.Next = 0;
                    PackVar.MarkedOnly(true);
                end;

                PackVarForm.SetTableView(PackVar);
                if PackVar.Get("Package Variable Code") then
                    PackVarForm.SetRecord(PackVar);
                PackVarForm.LookupMode := true;
                if PackVarForm.RunModal = ACTION::LookupOK then begin
                    PackVarForm.GetRecord(PackVar);
                    Validate("Package Variable Code", PackVar.Code);
                end;
            end;
        }
        field(4; "Variable Item No."; Code[20])
        {
            Caption = 'Variable Item No.';
            TableRelation = Item WHERE(Type = CONST(Inventory));
        }
        field(5; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(6; "UOM Code"; Code[10])
        {
            Caption = 'UOM Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Variable Item No."));
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Package Variable Code")
        {
        }
        key(Key2; "Variable Item No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        PackVar: Record "Package Variable";
        PackVarForm: Page "Package Variables";
}

