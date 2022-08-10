table 37002024 "Lot Control Item"
{
    // PRW17.10.01
    // P8001258, Columbus IT, Jack Reynolds, 10 JAN 14
    //   Increase size ot text fields/variables
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Lot Control Item';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item WHERE("Item Tracking Code" = FILTER(''));
        }
        field(2; "Item Tracking Code"; Code[10])
        {
            Caption = 'Item Tracking Code';
            TableRelation = "Item Tracking Code";

            trigger OnValidate()
            begin
                ItemTrackingCode.Get("Item Tracking Code");
                ItemTrackingCode.TestField("Lot Specific Tracking", true);
            end;
        }
        field(3; "Lot Nos."; Code[20])
        {
            Caption = 'Lot Nos.';
            TableRelation = "No. Series";
        }
        field(4; "Original Lot No."; Code[50])
        {
            Caption = 'Original Lot No.';
        }
        field(5; Message; Text[250])
        {
            Caption = 'Message';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Item No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Item: Record Item;
        ItemLedger: Record "Item Ledger Entry";
        ItemTrackingCode: Record "Item Tracking Code";

    procedure GetItem()
    begin
        if Item."No." <> "Item No." then
            if not Item.Get("Item No.") then
                Clear(Item);
    end;

    procedure ItemDescription(): Text[100]
    begin
        // P8001258 - increase size or Return Value to Text50
        GetItem;
        exit(Item.Description);
    end;

    procedure ItemUOM(): Code[10]
    begin
        GetItem;
        exit(Item."Base Unit of Measure");
    end;
}

