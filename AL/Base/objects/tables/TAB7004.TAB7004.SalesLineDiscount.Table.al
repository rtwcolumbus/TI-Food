table 7004 "Sales Line Discount"
{
    // PR3.60
    //   Sales Line Discount Changes
    // 
    // PR4.00.03
    // P8000345A, VerticalSoft, Jack Reynolds, 08 JUN 06
    //   Add Unit Amount as option to line discount type
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    Caption = 'Sales Line Discount';
#if not CLEAN21
    LookupPageID = "Sales Line Discounts";
    ObsoleteState = Pending;
    ObsoleteTag = '16.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '22.0';
#endif    
    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation: table Price List Line';

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            TableRelation = IF (Type = CONST(Item)) Item
            ELSE
            IF (Type = CONST("Item Disc. Group")) "Item Discount Group";

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if xRec.Code <> Code then begin
                    "Unit of Measure Code" := '';
                    "Variant Code" := '';

                    if Type = Type::Item then
                        if Item.Get(Code) then
                            "Unit of Measure Code" := Item."Sales Unit of Measure"
                end;
            end;
        }
        field(2; "Sales Code"; Code[20])
        {
            Caption = 'Sales Code';
            TableRelation = IF ("Sales Type" = CONST("Customer Disc. Group")) "Customer Discount Group"
            ELSE
            IF ("Sales Type" = CONST(Customer)) Customer
            ELSE
            IF ("Sales Type" = CONST(Campaign)) Campaign;

            trigger OnValidate()
            begin
                if "Sales Code" <> '' then
                    case "Sales Type" of
                        "Sales Type"::"All Customers":
                            Error(Text001, FieldCaption("Sales Code"));
                        "Sales Type"::Campaign:
                            begin
                                Campaign.Get("Sales Code");
                                "Starting Date" := Campaign."Starting Date";
                                "Ending Date" := Campaign."Ending Date";
                            end;
                    end;
            end;
        }
        field(3; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(4; "Starting Date"; Date)
        {
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                if ("Starting Date" > "Ending Date") and ("Ending Date" <> 0D) then
                    Error(Text000, FieldCaption("Starting Date"), FieldCaption("Ending Date"));

                if CurrFieldNo = 0 then
                    exit;
                if "Sales Type" = "Sales Type"::Campaign then
                    Error(Text003, FieldCaption("Starting Date"), FieldCaption("Ending Date"), FieldCaption("Sales Type"), "Sales Type");
            end;
        }
        field(5; "Line Discount %"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Line Discount %';
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesLineDisc(Rec, xRec, FieldNo("Line Discount %")); // PR3.60
            end;
        }
        field(13; "Sales Type"; Option)
        {
            Caption = 'Sales Type';
            OptionCaption = 'Customer,Customer Disc. Group,All Customers,Campaign';
            OptionMembers = Customer,"Customer Disc. Group","All Customers",Campaign;

            trigger OnValidate()
            begin
                if "Sales Type" <> xRec."Sales Type" then
                    Validate("Sales Code", '');
            end;
        }
        field(14; "Minimum Quantity"; Decimal)
        {
            Caption = 'Minimum Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(15; "Ending Date"; Date)
        {
            Caption = 'Ending Date';

            trigger OnValidate()
            begin
                Validate("Starting Date");

                if CurrFieldNo = 0 then
                    exit;
                if "Sales Type" = "Sales Type"::Campaign then
                    Error(Text003, FieldCaption("Starting Date"), FieldCaption("Ending Date"), FieldCaption("Sales Type"), "Sales Type");
            end;
        }
        field(21; Type; Enum "Sales Line Discount Type")
        {
            Caption = 'Type';

            trigger OnValidate()
            begin
                if xRec.Type <> Type then
                    Validate(Code, '');
            end;
        }
        field(5400; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF ("Item Type" = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item Code"))
            ELSE
            "Unit of Measure";

#if not CLEAN21
            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateUnitofMeasureCode(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                TestField(Type, Type::Item);
            end;
#endif
        }
        field(5700; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF ("Item Type" = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("Item Code"));

            trigger OnValidate()
            begin
                TestField(Type, Type::Item);
            end;
        }
        field(37002040; "Item Type"; Option)
        {
            Caption = 'Item Type';
            Description = 'PR3.60';
            OptionCaption = 'Item,Item Category,,Item Disc. Group,All Items';
            OptionMembers = Item,"Item Category",,"Item Disc. Group","All Items";

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesLineDisc(Rec, xRec, FieldNo("Item Type")); // PR3.60
            end;
        }
        field(37002041; "Item Code"; Code[20])
        {
            Caption = 'Item Code';
            Description = 'PR3.60';
            TableRelation = IF ("Item Type" = CONST(Item)) Item
            ELSE
            IF ("Item Type" = CONST("Item Category")) "Item Category"
            ELSE
            IF ("Item Type" = CONST("Item Disc. Group")) "Item Discount Group";

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesLineDisc(Rec, xRec, FieldNo("Item Code")); // PR3.60
            end;
        }
        field(37002043; "Line Discount Type"; Option)
        {
            Caption = 'Line Discount Type';
            Description = 'PR3.60';
            OptionCaption = 'Percent,Amount,Unit Amount';
            OptionMembers = Percent,Amount,"Unit Amount";

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesLineDisc(Rec, xRec, FieldNo("Line Discount Type")); // PR3.60
            end;
        }
        field(37002044; "Line Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Line Discount Amount';
            Description = 'PR3.60';

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesLineDisc(Rec, xRec, FieldNo("Line Discount Amount")); // PR3.60
            end;
        }
        field(37002045; "Sales Line Discount %"; Decimal)
        {
            AutoFormatType = 2;
            BlankZero = true;
            Caption = 'Sales Line Discount %';
            Description = 'PR3.60';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Item Type", "Item Code", "Sales Type", "Sales Code", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Line Discount Type", "Minimum Quantity")
        {
            Clustered = true;
        }
        key(Key2; "Sales Type", "Sales Code", "Item Type", "Item Code", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Line Discount Type", "Minimum Quantity")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "Sales Type", "Sales Code", "Line Discount %", Type, "Code", "Starting Date", "Ending Date")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Sales Type" = "Sales Type"::"All Customers" then
            "Sales Code" := ''
        else
            TestField("Sales Code");

        // PR3.60
        // TestField(Code);
        //
        ItemSalesPriceMgmt.CheckItemFieldsOnInsert("Item Type", "Item Code"); // P8007749
        // PR3.60
    end;

    trigger OnRename()
    begin
        if "Sales Type" <> "Sales Type"::"All Customers" then
            TestField("Sales Code");

        // PR3.60
        // TestField(Code);
        //
        ItemSalesPriceMgmt.CheckItemFieldsOnRename("Item Type", "Item Code"); // P8007749
        // PR3.60
    end;

    var
        Campaign: Record Campaign;
        ItemSalesPriceMgmt: Codeunit "Item Sales Price Management";

        Text000: Label '%1 cannot be after %2';
        Text001: Label '%1 must be blank.';
        Text003: Label 'You can only change the %1 and %2 from the Campaign Card when %3 = %4.';

#if not CLEAN21
    [Obsolete('This table is replaced by the new implementation (V16) of price calculation: table Price List Line', '22.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateUnitofMeasureCode(var SalesLineDiscount: Record "Sales Line Discount"; xSalesLineDiscount: Record "Sales Line Discount"; var IsHandled: Boolean)
    begin
    end;
#endif
}

