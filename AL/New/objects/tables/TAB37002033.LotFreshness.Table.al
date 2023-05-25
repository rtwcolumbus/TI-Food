table 37002033 "Lot Freshness"
{
    // PRW16.00.06
    // P8001060, Columbus IT, Jack Reynolds, 23 APR 12
    //   Allow freshness preference to be specified for All Items
    // 
    // P8001062, Columbus IT, Jack Reynolds, 26 APR 12
    //   Lot freshness preference override on sales line
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW110.0.01
    // P80045063, To-Increase, Dayakar Battini, 24 JUL 17
    //   Item Category Code length from code10 to code20

    Caption = 'Lot Freshness';

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }
        field(2; "Item Type"; Option)
        {
            Caption = 'Item Type';
            OptionCaption = 'Item,Item Category,All Items';
            OptionMembers = Item,"Item Category","All Items";

            trigger OnValidate()
            begin
                // P8001060
                if Rec."Item Type" <> xRec."Item Type"::"All Items" then
                    "Item Code" := '';
                // P8001060
            end;
        }
        field(3; "Item Code"; Code[20])
        {
            Caption = 'Item Code';
            TableRelation = IF ("Item Type" = CONST(Item)) Item."No."
            ELSE
            IF ("Item Type" = CONST("Item Category")) "Item Category".Code;

            trigger OnValidate()
            begin
                // P8001060
                if "Item Code" <> '' then
                    if "Item Type" = "Item Type"::"All Items" then
                        Error(Text001, FieldCaption("Item Code"), "Item Type");
                // P8001060
            end;
        }
        field(4; "Days to Fresh"; Integer)
        {
            Caption = 'Days to Fresh';
            MinValue = 0;
        }
        field(5; "Required Shelf Life"; Integer)
        {
            Caption = 'Required Shelf Life';
            MinValue = 0;
        }
    }

    keys
    {
        key(Key1; "Customer No.", "Item Type", "Item Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label '%1 may not be specified for %2.';

    procedure GetForItemCategory(CustomerNo: Code[20]; ItemCategoryCode: Code[20]): Boolean
    var
        ItemCategory: Record "Item Category";
    begin
        // P8007749
        if Get(CustomerNo, "Item Type"::"Item Category", ItemCategoryCode) then
            exit(true);

        if ItemCategory.Get(ItemCategoryCode) then
            while ItemCategory."Parent Category" <> '' do
                if Get(CustomerNo, "Item Type"::"Item Category", ItemCategory."Parent Category") then
                    exit(true)
                else
                    ItemCategory.Get(ItemCategory."Parent Category");
    end;
}

