table 37002019 "Acc. Schedule Unit"
{
    // PRW16.00.06
    // P8001019, Columbus IT, Jack Reynolds, 16 JAN 12
    //   Account Schedule - Item Units
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Acc. Schedule Unit';
    LookupPageID = "Acc. Schedule Units";

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
        field(3; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Purchase,Sale,,,,Consumption,Output';
            OptionMembers = Purchase,Sale,,,,Consumption,Output;
        }
        field(4; "Quantity Field"; Option)
        {
            Caption = 'Quantity Field';
            OptionCaption = 'Base,Alternate';
            OptionMembers = Base,Alternate;
        }
        field(5; "Item Category Code Filter"; Code[80])
        {
            Caption = 'Item Category Code Filter';
        }
        field(6; Factor; Decimal)
        {
            Caption = 'Factor';
            DecimalPlaces = 0 : 5;
            InitValue = 1;
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

    procedure LookUpItemCatFilter(var Text: Text[250]): Boolean
    var
        ItemCategory: Record "Item Category";
        ItemCategoryList: Page "Item Categories";
    begin
        ItemCategoryList.LookupMode(true);
        if ItemCategoryList.RunModal = ACTION::LookupOK then begin
            ItemCategoryList.GetRecord(ItemCategory);
            Text := Text + ItemCategoryList.GetSelectionFilter;
            exit(true);
        end else
            exit(false)
    end;
}

