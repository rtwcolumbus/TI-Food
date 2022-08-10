table 7023 "Sales Price Worksheet"
{
    // PR3.60
    //   Sales Pricing
    //     Change both keys, remove Item No., add Item Type, Item Code 1, and Item Code 2
    //     Add Break Charge
    //   Recurring Price Templates
    // 
    // PRW15.00.01
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Add Cost Calculation Method and Rounding Method
    // 
    // P8000565A, VerticalSoft, Jack Reynolds, 08 FEB 08
    //   Rename Cost Basis field to Cost Reference
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    Caption = 'Sales Price Worksheet';
#if not CLEAN19
    ObsoleteState = Pending;
    ObsoleteTag = '16.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '22.0';
#endif    
    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation: table Price Worksheet Line';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item;

#if not CLEAN19
            trigger OnValidate()
            begin
                if "Item No." <> xRec."Item No." then begin
                    "Unit of Measure Code" := '';
                    "Variant Code" := '';
                end;

                if "Sales Type" = "Sales Type"::"Customer Price Group" then
                    if CustPriceGr.Get("Sales Code") and
                       (CustPriceGr."Allow Invoice Disc." <> "Allow Invoice Disc.")
                    then
                        if Item.Get("Item No.") then
                            "Allow Invoice Disc." := Item."Allow Invoice Disc.";

                CalcCurrentPrice(PriceAlreadyExists);
            end;
#endif
        }
        field(2; "Sales Code"; Code[20])
        {
            Caption = 'Sales Code';
            TableRelation = IF ("Sales Type" = CONST("Customer Price Group")) "Customer Price Group"
            ELSE
            IF ("Sales Type" = CONST(Customer)) Customer
            ELSE
            IF ("Sales Type" = CONST(Campaign)) Campaign;

#if not CLEAN19
            trigger OnValidate()
            begin
                if ("Sales Code" <> '') and ("Sales Type" = "Sales Type"::"All Customers") then
                    Error(Text001, FieldCaption("Sales Code"));

                SetSalesDescription;
                CalcCurrentPrice(PriceAlreadyExists);

                if ("Sales Code" = '') and ("Sales Type" <> "Sales Type"::"All Customers") then
                    exit;

                if not PriceAlreadyExists and ("Sales Code" <> '') then
                    case "Sales Type" of
                        "Sales Type"::"Customer Price Group":
                            begin
                                CustPriceGr.Get("Sales Code");
                                "Price Includes VAT" := CustPriceGr."Price Includes VAT";
                                "VAT Bus. Posting Gr. (Price)" := CustPriceGr."VAT Bus. Posting Gr. (Price)";
                                "Allow Line Disc." := CustPriceGr."Allow Line Disc.";
                                "Allow Invoice Disc." := CustPriceGr."Allow Invoice Disc.";
                            end;
                        "Sales Type"::Customer:
                            begin
                                Cust.Get("Sales Code");
                                "Currency Code" := Cust."Currency Code";
                                "Price Includes VAT" := Cust."Prices Including VAT";
                                "Allow Line Disc." := Cust."Allow Line Disc.";
                            end;
                        "Sales Type"::Campaign:
                            begin
                                Campaign.Get("Sales Code");
                                "Starting Date" := Campaign."Starting Date";
                                "Ending Date" := Campaign."Ending Date";
                            end;
                    end;
            end;
#endif
        }
        field(3; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;

#if not CLEAN19
            trigger OnValidate()
            begin
                CalcCurrentPrice(PriceAlreadyExists);
            end;
#endif
        }
        field(4; "Starting Date"; Date)
        {
            Caption = 'Starting Date';

#if not CLEAN19
            trigger OnValidate()
            begin
                if ("Starting Date" > "Ending Date") and ("Ending Date" <> 0D) then
                    Error(Text000, FieldCaption("Starting Date"), FieldCaption("Ending Date"));

                if CurrFieldNo <> 0 then
                    if "Sales Type" = "Sales Type"::Campaign then
                        Error(Text002, FieldCaption("Starting Date"), FieldCaption("Ending Date"), FieldCaption("Sales Type"), "Sales Type");

                CalcCurrentPrice(PriceAlreadyExists);
            end;
#endif
        }
        field(5; "Current Unit Price"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Current Unit Price';
            Editable = false;
            MinValue = 0;
        }
        field(6; "New Unit Price"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'New Unit Price';
            MinValue = 0;

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesWksh(Rec, xRec, FieldNo("New Unit Price")); // PR3.60
            end;
        }
        field(7; "Price Includes VAT"; Boolean)
        {
            Caption = 'Price Includes VAT';
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
        field(13; "Sales Type"; Enum "Sales Price Type")
        {
            Caption = 'Sales Type';

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

#if not CLEAN19
            trigger OnValidate()
            begin
                CalcCurrentPrice(PriceAlreadyExists);
            end;
#endif
        }
        field(15; "Ending Date"; Date)
        {
            Caption = 'Ending Date';

#if not CLEAN19
            trigger OnValidate()
            begin
                Validate("Starting Date");

                if CurrFieldNo <> 0 then
                    if "Sales Type" = "Sales Type"::Campaign then
                        Error(Text002, FieldCaption("Starting Date"), FieldCaption("Ending Date"), FieldCaption("Sales Type"), "Sales Type");
            end;
#endif
        }
        field(20; "Item Description"; Text[100])
        {
            CalcFormula = Lookup(Item.Description WHERE("No." = FIELD("Item No.")));
            Caption = 'Item Description';
            FieldClass = FlowField;
        }
        field(21; "Sales Description"; Text[100])
        {
            Caption = 'Sales Description';
        }
        field(5400; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF ("Item Type" = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item Code"))
            ELSE
            "Unit of Measure";

#if not CLEAN19
            trigger OnValidate()
            begin
                CalcCurrentPrice(PriceAlreadyExists);
            end;
#endif
        }
        field(5700; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = IF ("Item Type" = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD("Item Code"));

#if not CLEAN19
            trigger OnValidate()
            begin
                CalcCurrentPrice(PriceAlreadyExists);
            end;
#endif
        }
        field(7001; "Allow Line Disc."; Boolean)
        {
            Caption = 'Allow Line Disc.';
            InitValue = true;
        }
        field(37002040; "Item Type"; Option)
        {
            Caption = 'Item Type';
            Description = 'PR3.60';
            OptionCaption = 'Item,Item Category,,,All Items';
            OptionMembers = Item,"Item Category",,,"All Items";

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesWksh(Rec, xRec, FieldNo("Item Type")); // PR3.60
            end;
        }
        field(37002041; "Item Code"; Code[20])
        {
            Caption = 'Item Code';
            Description = 'PR3.60';
            TableRelation = IF ("Item Type" = CONST(Item)) Item
            ELSE
            IF ("Item Type" = CONST("Item Category")) "Item Category";

            trigger OnValidate()
            begin
                // PR3.60
                ItemSalesPriceMgmt.ValidateSalesWksh(Rec, xRec, FieldNo("Item Code"));

                CalcCurrentPrice(PriceAlreadyExists);
                // PR3.60
            end;
        }
        field(37002043; "Pricing Method"; Option)
        {
            Caption = 'Pricing Method';
            Description = 'PR3.60';
            OptionCaption = 'Fixed Amount,Amount Markup,% Markup,% Margin';
            OptionMembers = "Fixed Amount","Amount Markup","% Markup","% Margin";

            trigger OnValidate()
            begin
                // PR3.60
                ItemSalesPriceMgmt.ValidateSalesWksh(Rec, xRec, FieldNo("Pricing Method"));

                CalcCurrentPrice(PriceAlreadyExists);
                // PR3.60
            end;
        }
        field(37002044; "Cost Reference"; Option)
        {
            Caption = 'Cost Reference';
            Description = 'PR3.60';
            OptionCaption = 'Standard,Average,Last,Cost Calc. Method';
            OptionMembers = Standard,"Average",Last,"Cost Calc. Method";

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesWksh(Rec, xRec, FieldNo("Cost Reference")); // P8000539A
                CalcCurrentPrice(PriceAlreadyExists); // PR3.60
            end;
        }
        field(37002045; "Current Cost Adjustment"; Decimal)
        {
            Caption = 'Current Cost Adjustment';
            DecimalPlaces = 2 : 5;
            Description = 'PR3.60';
            Editable = false;
        }
        field(37002046; "Use Break Charge"; Boolean)
        {
            Caption = 'Use Break Charge';
            Description = 'PR3.60';
        }
        field(37002047; "New Cost Adjustment"; Decimal)
        {
            Caption = 'New Cost Adjustment';
            DecimalPlaces = 2 : 5;
            Description = 'PR3.60';

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesWksh(Rec, xRec, FieldNo("New Cost Adjustment")); // PR3.60
            end;
        }
        field(37002049; "Price Type"; Option)
        {
            Caption = 'Price Type';
            Description = 'PR3.60';
            OptionCaption = 'Normal,Contract,Soft Contract';
            OptionMembers = Normal,Contract,"Soft Contract";

            trigger OnValidate()
            begin
                CalcCurrentPrice(PriceAlreadyExists); // PR3.60
            end;
        }
        field(37002050; "Template ID"; Integer)
        {
            Caption = 'Template ID';
            Description = 'PR3.60';
        }
        field(37002052; "Maximum Quantity"; Decimal)
        {
            Caption = 'Maximum Quantity';
            DecimalPlaces = 0 : 5;
            Description = 'PR3.60';
            MinValue = 0;
        }
        field(37002053; "Special Price"; Boolean)
        {
            Caption = 'Special Price';
            Description = 'PR3.60';

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesWksh(Rec, xRec, FieldNo("Special Price")); // PR3.60
            end;
        }
        field(37002054; "Cost Calc. Method Code"; Code[20])
        {
            Caption = 'Cost Calc. Method Code';
            Description = 'P8000539A';
            TableRelation = IF ("Cost Reference" = CONST("Cost Calc. Method")) "Cost Calculation Method";

            trigger OnValidate()
            begin
                // P8000539A
                ItemSalesPriceMgmt.ValidateSalesWksh(Rec, xRec, FieldNo("Cost Calc. Method Code"));
                CalcCurrentPrice(PriceAlreadyExists);
                // P8000539A
            end;
        }
        field(37002055; "Price Rounding Method"; Code[10])
        {
            Caption = 'Price Rounding Method';
            Description = 'P8000539A';
            TableRelation = "Rounding Method";

            trigger OnValidate()
            begin
                // P8000539A
                ItemSalesPriceMgmt.ValidateSalesWksh(Rec, xRec, FieldNo("Price Rounding Method"));
                CalcCurrentPrice(PriceAlreadyExists);
                // P8000539A
            end;
        }
    }

    keys
    {
        key(Key1; "Starting Date", "Ending Date", "Sales Type", "Sales Code", "Currency Code", "Item Type", "Item Code", "Variant Code", "Unit of Measure Code", "Price Type", "Pricing Method", "Cost Reference", "Cost Calc. Method Code", "Minimum Quantity")
        {
            Clustered = true;
        }
        key(Key2; "Item Type", "Item Code", "Variant Code", "Unit of Measure Code", "Price Type", "Pricing Method", "Cost Reference", "Cost Calc. Method Code", "Minimum Quantity", "Starting Date", "Sales Type", "Sales Code", "Currency Code")
        {
        }
    }

    fieldgroups
    {
    }

#if not CLEAN19
    trigger OnInsert()
    begin
        if "Sales Type" = "Sales Type"::"All Customers" then
            "Sales Code" := ''
        else
            TestField("Sales Code");

        // PR3.60
        // TESTFIELD("Item No.");
        //
        ItemSalesPriceMgmt.CheckItemFieldsOnInsert("Item Type", "Item Code"); // P8007749
        // PR3.60
    end;

    trigger OnRename()
    begin
        if "Sales Type" <> "Sales Type"::"All Customers" then
            TestField("Sales Code");

        // PR3.60
        // TESTFIELD("Item No.");
        //
        ItemSalesPriceMgmt.CheckItemFieldsOnRename("Item Type", "Item Code"); // P8007749
        // PR3.60
    end;

    var
        CustPriceGr: Record "Customer Price Group";
        Text000: Label '%1 cannot be after %2';
        Cust: Record Customer;
        Text001: Label '%1 must be blank.';
        Campaign: Record Campaign;
        PriceAlreadyExists: Boolean;
        Text002: Label '%1 and %2 can only be altered from the Campaign Card when %3 = %4.';
        ItemSalesPriceMgmt: Codeunit "Item Sales Price Management";

    protected var
        Item: Record Item;

    procedure CalcCurrentPrice(var PriceAlreadyExists: Boolean)
    var
        SalesPrice: Record "Sales Price";
    begin
        // PR3.60
        // SalesPrice.SETRANGE("Item No.","Item No.");
        //
        SalesPrice.SetRange("Item Type", "Item Type");
        SalesPrice.SetRange("Item Code", "Item Code");
        //SalesPrice.SETRANGE("Item Code 2", "Item Code 2"); // P8007749
        // PR3.60

        SalesPrice.SetRange("Sales Type", "Sales Type");
        SalesPrice.SetRange("Sales Code", "Sales Code");
        SalesPrice.SetRange("Currency Code", "Currency Code");
        SalesPrice.SetRange("Unit of Measure Code", "Unit of Measure Code");
        SalesPrice.SetRange("Starting Date", 0D, "Starting Date");
        SalesPrice.SetRange("Minimum Quantity", 0, "Minimum Quantity");
        SalesPrice.SetRange("Variant Code", "Variant Code");

        // PR3.60
        SalesPrice.SetRange("Pricing Method", "Pricing Method");
        SalesPrice.SetRange("Cost Reference", "Cost Reference");
        SalesPrice.SetRange("Price Type", "Price Type");
        // PR3.60

        OnCalcCurrentPriceOnAfterSetFilters(SalesPrice, Rec);
        if SalesPrice.FindLast then begin
            "Current Unit Price" := SalesPrice."Unit Price";
            "Price Includes VAT" := SalesPrice."Price Includes VAT";
            "Allow Line Disc." := SalesPrice."Allow Line Disc.";
            "Allow Invoice Disc." := SalesPrice."Allow Invoice Disc.";
            "VAT Bus. Posting Gr. (Price)" := SalesPrice."VAT Bus. Posting Gr. (Price)";
            PriceAlreadyExists := SalesPrice."Starting Date" = "Starting Date";

            // PR3.60
            "Current Cost Adjustment" := SalesPrice."Cost Adjustment";
            "Use Break Charge" := SalesPrice."Use Break Charge";
            // PR3.60

            OnAfterCalcCurrentPriceFound(Rec, SalesPrice);
        end else begin
            "Current Unit Price" := 0;
            PriceAlreadyExists := false;
            OnCalcCurrentPriceOnPriceNotFound(Rec);
        end;
    end;
#endif
    procedure SetSalesDescription()
    var
        Customer: Record Customer;
        CustomerPriceGroup: Record "Customer Price Group";
        Campaign: Record Campaign;
    begin
        "Sales Description" := '';
        if "Sales Code" = '' then
            exit;
        case "Sales Type" of
            "Sales Type"::Customer:
                if Customer.Get("Sales Code") then
                    "Sales Description" := Customer.Name;
            "Sales Type"::"Customer Price Group":
                if CustomerPriceGroup.Get("Sales Code") then
                    "Sales Description" := CustomerPriceGroup.Description;
            "Sales Type"::Campaign:
                if Campaign.Get("Sales Code") then
                    "Sales Description" := Campaign.Description;
        end;
    end;

#if not CLEAN19
    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcCurrentPriceFound(var SalesPriceWorksheet: Record "Sales Price Worksheet"; SalesPrice: Record "Sales Price")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcCurrentPriceOnAfterSetFilters(var SalesPrice: Record "Sales Price"; SalesPriceWorksheet: Record "Sales Price Worksheet")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcCurrentPriceOnPriceNotFound(var SalesPriceWorksheet: Record "Sales Price Worksheet")
    begin
    end;
#endif
}

