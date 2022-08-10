table 37002015 "Supply Chain Group"
{
    // PRW16.00.05
    // P8000931, Columbus IT, Jack Reynolds, 20 APR 11
    //   Support for Supply Chain Groups
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Supply Chain Group';
    LookupPageID = "Supply Chain Groups";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
        SuppyChainGroupUser: Record "Supply Chain Group User";
    begin
        Item.SetRange("Supply Chain Group Code", Code);
        if not Item.IsEmpty then
            Error(Text001, TableCaption, Code, Item.TableCaption);

        // P8007749
        // ProductGroup.SETRANGE("Supply Chain Group Code",Code);
        // IF NOT ProductGroup.ISEMPTY THEN
        //  ERROR(Text001,TABLECAPTION,Code,ProductGroup.TABLECAPTION);
        // P8007749

        ItemCategory.SetRange("Supply Chain Group Code", Code);
        if not ItemCategory.IsEmpty then
            Error(Text001, TableCaption, Code, ItemCategory.TableCaption);

        SuppyChainGroupUser.SetCurrentKey("Supply Chain Group Code");
        SuppyChainGroupUser.SetRange("Supply Chain Group Code", Code);
        SuppyChainGroupUser.DeleteAll;
    end;

    var
        Text001: Label 'You cannot delete %1 %2 because there is at least one %3 that includes this group.';

    procedure MarkItems(var Item: Record Item)
    var
        ItemCategory: Record "Item Category";
    begin
        Item.SetRange("Supply Chain Group Code", Code);
        if Item.Find('-') then
            repeat
                Item.Mark(true);
            until Item.Next = 0;
        Item.SetRange("Supply Chain Group Code");


        MarkItemCategories(ItemCategory);
        ItemCategory.MarkedOnly(true);

        Item.SetCurrentKey("Item Category Code");
        Item.SetRange("Supply Chain Group Code", '');

        if ItemCategory.FindSet then
            repeat
                Item.SetRange("Item Category Code", ItemCategory.Code);
                if Item.FindSet then
                    repeat
                        Item.Mark(true);
                    until Item.Next = 0;
            until ItemCategory.Next = 0;
        Item.SetRange("Item Category Code");
        Item.SetRange("Supply Chain Group Code");
        Item.SetCurrentKey("No.");
    end;

    procedure MarkItemCategories(var ItemCategory: Record "Item Category")
    var
        ItemCategory2: Record "Item Category";
    begin
        // P8007749
        ItemCategory2.CopyFilters(ItemCategory);
        ItemCategory2 := ItemCategory;

        ItemCategory.SetFilter("Parent Category", ItemCategory.Code);
        if ItemCategory.Code = '' then
            ItemCategory.SetRange("Supply Chain Group Code", Code)
        else
            ItemCategory.SetRange("Supply Chain Group Code", '');

        if ItemCategory.FindSet then
            repeat
                ItemCategory.Mark(true);
                MarkItemCategories(ItemCategory);
            until ItemCategory.Next = 0;

        ItemCategory.CopyFilters(ItemCategory2);
        ItemCategory := ItemCategory2;
    end;
}

