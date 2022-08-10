table 37002018 "Item Slot"
{
    // PRW16.00.05
    // P8000968, Columbus IT, Jack Reynolds, 16 AUG 11
    //   New table for Item Slots (by location)

    Caption = 'Item Slot';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item;
        }
        field(2; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            NotBlank = true;
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(3; "Slot No."; Code[10])
        {
            Caption = 'Slot No.';
            NotBlank = true;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Location Code")
        {
        }
    }

    fieldgroups
    {
    }
}

