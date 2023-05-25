table 37002768 "Clear Bin History"
{
    // PRW17.00.01
    // P8001154, Columbus IT, Jack Reynolds, 28 MAY 13
    //   Enlarge User ID field
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property

    Caption = 'Clear Bin History';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(3; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
        }
        field(4; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(5; "Date/Time"; DateTime)
        {
            Caption = 'Date/Time';
        }
        field(6; "Item Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Item Entry No.';
            TableRelation = "Item Ledger Entry";

            trigger OnLookup()
            begin
                if ("Item Entry No." <> 0) then begin
                    ItemLedgEntry."Entry No." := "Item Entry No.";
                    PAGE.RunModal(0, ItemLedgEntry);
                end;
            end;
        }
        field(7; "Whse. Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Whse. Entry No.';
            TableRelation = "Warehouse Entry";

            trigger OnLookup()
            begin
                if ("Whse. Entry No." <> 0) then begin
                    WhseEntry."Entry No." := "Whse. Entry No.";
                    PAGE.RunModal(0, WhseEntry);
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Location Code", "Bin Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        ItemLedgEntry: Record "Item Ledger Entry";
        WhseEntry: Record "Warehouse Entry";
}

