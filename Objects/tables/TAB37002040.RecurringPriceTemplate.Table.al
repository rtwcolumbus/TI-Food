table 37002040 "Recurring Price Template"
{
    // PR3.10.P
    //   Recurring Price Templates
    // 
    // PRW15.00.01
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Add Cost Calculation Method and Rounding Method
    // 
    // P8000546A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Change Template ID to AutoIncrement
    //   Remove Special Price field
    // 
    // P8000565A, VerticalSoft, Jack Reynolds, 08 FEB 08
    //   Rename Cost Basis field to Cost Reference
    // 
    // PRW16.00.04
    // P8000885, Columbus IT, Jack Reynolds, 10 MAR 11
    //   Check for sales contracts when validating Price Type
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Recurring Price Template';
    LookupPageID = "Recurring Price Template List";
    ReplicateData = false;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(2; "Sales Code"; Code[20])
        {
            Caption = 'Sales Code';
            TableRelation = IF ("Sales Type" = CONST("Customer Price Group")) "Customer Price Group"
            ELSE
            IF ("Sales Type" = CONST(Customer)) Customer;

            trigger OnValidate()
            begin
                if "Sales Code" <> '' then begin
                    case "Sales Type" of
                        "Sales Type"::"All Customers":
                            Error(Text001, FieldCaption("Sales Code"));
                        "Sales Type"::"Customer Price Group":
                            begin
                                CustPriceGr.Get("Sales Code");
                                "VAT Bus. Posting Gr. (Price)" := CustPriceGr."VAT Bus. Posting Gr. (Price)";
                                "Allow Line Disc." := CustPriceGr."Allow Line Disc.";
                                "Allow Invoice Disc." := CustPriceGr."Allow Invoice Disc.";
                            end;
                        "Sales Type"::Customer:
                            begin
                                Cust.Get("Sales Code");
                                "Currency Code" := Cust."Currency Code";
                                "Allow Line Disc." := Cust."Allow Line Disc.";
                            end;
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

                ItemSalesPriceMgmt.ValidateSalesPriceTemplate(Rec, xRec, FieldNo("Starting Date"));
            end;
        }
        field(5; "Unit Price"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price';
            MinValue = 0;

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesPriceTemplate(Rec, xRec, FieldNo("Unit Price"));
            end;
        }
        field(10; "Allow Invoice Disc."; Boolean)
        {
            Caption = 'Allow Invoice Disc.';
            InitValue = true;
        }
        field(11; "VAT Bus. Posting Gr. (Price)"; Code[20])
        {
            Caption = 'VAT Bus. Posting Gr. (Price)';
            TableRelation = "VAT Business Posting Group";
        }
        field(13; "Sales Type"; Option)
        {
            Caption = 'Sales Type';
            OptionCaption = 'Customer,Customer Price Group,All Customers';
            OptionMembers = Customer,"Customer Price Group","All Customers";

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
            end;
        }
        field(500; "Next Date"; Date)
        {
            Caption = 'Next Date';
        }
        field(501; "Pricing Frequency"; DateFormula)
        {
            Caption = 'Pricing Frequency';
        }
        field(502; "Generate Fixed Item Prices"; Boolean)
        {
            Caption = 'Generate Fixed Item Prices';

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesPriceTemplate(Rec, xRec, FieldNo("Generate Fixed Item Prices"));
            end;
        }
        field(5400; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF ("Item Type" = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item Code"))
            ELSE
            "Unit of Measure";
        }
        field(5700; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF ("Item Type" = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("Item Code"));
        }
        field(7001; "Allow Line Disc."; Boolean)
        {
            Caption = 'Allow Line Disc.';
            InitValue = true;
        }
        field(37002040; "Item Type"; Option)
        {
            Caption = 'Item Type';
            OptionCaption = 'Item,Item Category,,,All Items';
            OptionMembers = Item,"Item Category",,,"All Items";

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesPriceTemplate(Rec, xRec, FieldNo("Item Type"));
            end;
        }
        field(37002041; "Item Code"; Code[20])
        {
            Caption = 'Item Code';
            TableRelation = IF ("Item Type" = CONST(Item)) Item
            ELSE
            IF ("Item Type" = CONST("Item Category")) "Item Category";

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesPriceTemplate(Rec, xRec, FieldNo("Item Code"));
            end;
        }
        field(37002043; "Pricing Method"; Option)
        {
            Caption = 'Pricing Method';
            OptionCaption = 'Fixed Amount,Amount Markup,% Markup,% Margin';
            OptionMembers = "Fixed Amount","Amount Markup","% Markup","% Margin";

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesPriceTemplate(Rec, xRec, FieldNo("Pricing Method"));
            end;
        }
        field(37002044; "Cost Reference"; Option)
        {
            Caption = 'Cost Reference';
            OptionCaption = 'Standard,Average,Last,Cost Calc. Method';
            OptionMembers = Standard,"Average",Last,"Cost Calc. Method";

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesPriceTemplate(Rec, xRec, FieldNo("Cost Reference")); // P8000539A
            end;
        }
        field(37002045; "Cost Adjustment"; Decimal)
        {
            Caption = 'Cost Adjustment';
            DecimalPlaces = 2 : 5;

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesPriceTemplate(Rec, xRec, FieldNo("Cost Adjustment"));
            end;
        }
        field(37002046; "Use Break Charge"; Boolean)
        {
            Caption = 'Use Break Charge';
        }
        field(37002049; "Price Type"; Option)
        {
            Caption = 'Price Type';
            OptionCaption = 'Normal,Contract,Soft Contract';
            OptionMembers = Normal,Contract,"Soft Contract";

            trigger OnValidate()
            begin
                // P8000885
                if not SalesCont.IsEmpty and ("Price Type" = "Price Type"::Contract) then
                    Error(Text003, FieldCaption("Price Type"), Format("Price Type"));
                // P8000885
            end;
        }
        field(37002050; "Template ID"; Integer)
        {
            AutoIncrement = true;
            Caption = 'Template ID';
        }
        field(37002052; "Maximum Quantity"; Decimal)
        {
            Caption = 'Maximum Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(37002054; "Cost Calc. Method Code"; Code[20])
        {
            Caption = 'Cost Calc. Method Code';
            Description = 'P8000539A';
            TableRelation = IF ("Cost Reference" = CONST("Cost Calc. Method")) "Cost Calculation Method";

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesPriceTemplate(Rec, xRec, FieldNo("Cost Calc. Method Code")); // P8000539A
            end;
        }
        field(37002055; "Price Rounding Method"; Code[10])
        {
            Caption = 'Price Rounding Method';
            Description = 'P8000539A';
            TableRelation = "Rounding Method";

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesPriceTemplate(Rec, xRec, FieldNo("Price Rounding Method")); // P8000539A
            end;
        }
    }

    keys
    {
        key(Key1; "Template ID")
        {
        }
        key(Key2; "Item Type", "Item Code", "Sales Type", "Sales Code", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Price Type", "Pricing Method", "Cost Reference", "Cost Calc. Method Code", "Minimum Quantity")
        {
        }
        key(Key3; "Sales Type", "Sales Code", "Item Type", "Item Code", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Price Type", "Pricing Method", "Cost Reference", "Cost Calc. Method Code", "Minimum Quantity")
        {
        }
        key(Key4; "Next Date", "Starting Date")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Sales Type" = "Sales Type"::"All Customers" then
            "Sales Code" := ''
        else
            TestField("Sales Code");

        ItemSalesPriceMgmt.CheckItemFieldsOnInsert("Item Type", "Item Code"); // P8007749
        // ItemSalesPriceMgmt.AssignTemplateID(Rec); // P8000546A
    end;

    trigger OnRename()
    begin
        if "Sales Type" <> "Sales Type"::"All Customers" then
            TestField("Sales Code");

        ItemSalesPriceMgmt.CheckItemFieldsOnRename("Item Type", "Item Code");  // P8007749
    end;

    var
        CustPriceGr: Record "Customer Price Group";
        Text000: Label '%1 cannot be after %2';
        Cust: Record Customer;
        Text001: Label '%1 must be blank.';
        Item: Record Item;
        SalesCont: Record "Sales Contract";
        ItemSalesPriceMgmt: Codeunit "Item Sales Price Management";
        Text002: Label 'untitled';
        Text003: Label 'You cannot create Price Templates with %1 of %2.';

    procedure GetDescription() TemplateDescription: Text[250]
    begin
        if ("Template ID" <> 0) then begin
            if ("Sales Type" = "Sales Type"::"All Customers") or ("Sales Code" <> '') then
                TemplateDescription := DelChr(StrSubstNo('%1 %2', "Sales Type", "Sales Code"), '>');

            if ("Item Type" = "Item Type"::"All Items") or ("Item Code" <> '')            // P8007749
                                                                                          //(("Item Type" <> "Item Type"::"Product Group") OR ("Item Code 2" <> '')) // P8007749
            then begin
                if (TemplateDescription <> '') then
                    TemplateDescription := TemplateDescription + ' - ';
                TemplateDescription := TemplateDescription +
                  DelChr(StrSubstNo('%1 %2', "Item Type", "Item Code"), '>'); // P8007749
            end;
        end;

        if (TemplateDescription = '') then
            TemplateDescription := Text002;
    end;
}

