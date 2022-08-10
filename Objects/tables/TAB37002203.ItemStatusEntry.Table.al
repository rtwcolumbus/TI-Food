table 37002203 "Item Status Entry"
{
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status

    Caption = 'Item Status Entry';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(3; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(4; "Lot Status Code"; Code[10])
        {
            Caption = 'Lot Status Code';
            TableRelation = "Lot Status Code";
        }
        field(11; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(12; "Quantity (Alt.)"; Decimal)
        {
            Caption = 'Quantity (Alt.)';
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Location Code", "Lot Status Code")
        {
        }
        key(Key2; "Lot Status Code")
        {
        }
    }

    fieldgroups
    {
    }

    procedure UpdateRecord()
    var
        ItemStatusEntry: Record "Item Status Entry";
    begin
        if (Quantity = 0) and ("Quantity (Alt.)" = 0) then
            exit;

        if ItemStatusEntry.Get("Item No.", "Variant Code", "Location Code", "Lot Status Code") then begin
            ItemStatusEntry.Quantity += Quantity;
            ItemStatusEntry."Quantity (Alt.)" += "Quantity (Alt.)";
            if (ItemStatusEntry.Quantity = 0) and (ItemStatusEntry."Quantity (Alt.)" = 0) then
                ItemStatusEntry.Delete
            else
                ItemStatusEntry.Modify;
        end else
            Insert;
    end;
}

