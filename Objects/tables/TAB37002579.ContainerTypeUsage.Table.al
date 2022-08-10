table 37002579 "Container Type Usage"
{
    // PRW17.10.01
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old containers
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW110.0.01
    // P80045063, To-Increase, Dayakar Battini, 24 JUL 17
    //   Item Category Code length from code10 to code20
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Container Type Usage';

    fields
    {
        field(1; "Container Type Code"; Code[20])
        {
            Caption = 'Container Type Code';
            NotBlank = true;
            TableRelation = "Container Type";
        }
        field(2; "Item Type"; Option)
        {
            Caption = 'Item Type';
            OptionCaption = 'All,Item Category,,Specific';
            OptionMembers = All,"Item Category",,Specific;

            trigger OnValidate()
            begin
                if ("Item Type" <> xRec."Item Type") then
                    Validate("Item Code", '');
                GetContainerType("Container Type Code");
                if ("Item Type" < ContainerType."Setup Level") then
                    ContainerType.FieldError("Setup Level");
            end;
        }
        field(3; "Item Code"; Code[20])
        {
            Caption = 'Item Code';
            TableRelation = IF ("Item Type" = CONST("Item Category")) "Item Category"
            ELSE
            IF ("Item Type" = CONST(Specific)) Item;

            trigger OnValidate()
            begin
                if ("Item Code" <> xRec."Item Code") or ("Item Code" = '') then
                    Validate("Unit of Measure Code", '');
                if ("Item Code" <> '') and ("Item Type" = "Item Type"::All) then
                    FieldError("Item Type");
                if ("Item Code" <> '') and ("Item Type" = "Item Type"::Specific) then begin
                    GetItem("Item Code");
                    Validate("Unit of Measure Code", Item."Base Unit of Measure");
                end;
            end;
        }
        field(5; "Container Item No."; Code[20])
        {
            CalcFormula = Lookup ("Container Type"."Container Item No." WHERE(Code = FIELD("Container Type Code")));
            Caption = 'Container Item No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; Ranking; Integer)
        {
            BlankZero = true;
            Caption = 'Ranking';
        }
        field(7; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF ("Item Type" = CONST(Specific)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item Code"))
            ELSE
            "Unit of Measure";

            trigger OnValidate()
            begin
                if "Unit of Measure Code" = '' then
                    "Default Quantity" := 0;
            end;
        }
        field(8; "Default Quantity"; Decimal)
        {
            BlankZero = true;
            Caption = 'Default Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Default Quantity" <> 0 then
                    TestField("Unit of Measure Code");
            end;
        }
        field(9; "Single Lot"; Boolean)
        {
            Caption = 'Single Lot';
        }
    }

    keys
    {
        key(Key1; "Container Type Code", "Item Type", "Item Code", "Unit of Measure Code")
        {
        }
        key(Key2; "Item Type", "Item Code", Ranking)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        CheckItemFields;
    end;

    trigger OnModify()
    begin
        CheckItemFields;
    end;

    trigger OnRename()
    begin
        CheckItemFields;
    end;

    var
        ContainerType: Record "Container Type";
        Item: Record Item;

    local procedure GetContainerType(ContTypeCode: Code[20])
    begin
        if (ContainerType.Code <> ContTypeCode) then
            if (ContTypeCode <> '') then
                ContainerType.Get(ContTypeCode)
            else
                Clear(ContainerType);
    end;

    local procedure ContainerTypeDescription(): Text[100]
    begin
        GetContainerType("Container Type Code");
        exit(ContainerType.Description);
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        if (Item."No." <> ItemNo) then
            if (ItemNo <> '') then
                Item.Get(ItemNo)
            else
                Clear(Item);
    end;

    procedure NewRecord()
    begin
        if ContainerType.Get("Container Type Code") then
            "Item Type" := ContainerType."Setup Level";
    end;

    local procedure CheckItemFields()
    begin
        if ("Item Type" <> "Item Type"::All) then begin
            TestField("Item Code");
            if ("Item Type" = "Item Type"::Specific) and ("Default Quantity" <> 0) then
                TestField("Unit of Measure Code");
        end;
    end;

    procedure FindForItemCategory(ItemCategoryCode: Code[20]): Boolean
    var
        ItemCategory: Record "Item Category";
    begin
        // P8007749
        if ItemCategoryCode = '' then
            exit(false);

        SetRange("Item Code", ItemCategoryCode);
        if FindFirst then
            exit(true)
        else begin
            ItemCategory.Get(ItemCategoryCode);
            while ItemCategory."Parent Category" <> '' do begin
                SetRange("Item Code", ItemCategory."Parent Category");
                if FindFirst then
                    exit(true)
                else
                    ItemCategory.Get(ItemCategory."Parent Category");
            end;
        end;
    end;
}

