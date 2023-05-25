table 7002 "Sales Price"
{
    // PR3.60
    //   Sales Pricing
    //     Change both keys, remove Item No., add Item Type, Item Code 1, and Item Code 2
    //     Add Break Charge
    //   Recurring Price Templates
    // 
    // PR3.70
    //   Add key - Price Type,Item Type,Item Code 1,Sales Type,Sales Code,Starting Date,Ending Date
    // 
    // PRW15.00.01
    // P8000539A, VerticalSoft, Don Bresee, 13 NOV 07
    //   Add Cost Calculation Method and Rounding Method
    // 
    // P8000546A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Change Price ID to AutoIncrement
    // 
    // P8000565A, VerticalSoft, Jack Reynolds, 08 FEB 08
    //   Rename Cost Basis field to Cost Reference
    // 
    // PRW16.00.01
    // P8000708, VerticalSoft, Don Bresee, 23 JUL 09
    //   Clear Price ID on Insert to avoid duplicates on Paste
    // 
    // PRW16.00.04
    // P8000885, VerticalSoft, Ron Davidson, 27 DEC 10
    //   Added a new field to link to Sales Contracts
    //   Added Contract No. to Primary Key
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    Caption = 'Sales Price';
#if not CLEAN21
    LookupPageID = "Sales Prices";
    ObsoleteState = Pending;
    ObsoleteTag = '16.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '22.0';
#endif    
    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation: table Price List Line';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;

#if not CLEAN21
            trigger OnValidate()
            var
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeItemNoOnValidate(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                if "Item No." <> xRec."Item No." then begin
                    Item.Get("Item No.");
                    "Unit of Measure Code" := Item."Sales Unit of Measure";
                    "Variant Code" := '';
                end;

                if "Sales Type" = "Sales Type"::"Customer Price Group" then
                    if CustPriceGr.Get("Sales Code") and
                       (CustPriceGr."Allow Invoice Disc." = "Allow Invoice Disc.")
                    then
                        exit;

                UpdateValuesFromItem();
            end;
#endif
        }
        field(2; "Sales Code"; Code[20])
        {
            Caption = 'Sales Code';
#if not CLEAN21
            TableRelation = IF ("Sales Type" = CONST("Customer Price Group")) "Customer Price Group"
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
                        "Sales Type"::"Customer Price Group":
                            begin
                                CustPriceGr.Get("Sales Code");
                                OnValidateSalesCodeOnAfterGetCustomerPriceGroup(Rec, CustPriceGr);
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
                                "VAT Bus. Posting Gr. (Price)" := Cust."VAT Bus. Posting Group";
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

                if "Starting Date" <> 0D then
                    if "Sales Type" = "Sales Type"::Campaign then
                        Error(Text002, "Sales Type");
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
                ItemSalesPriceMgmt.ValidateSalesPrice(Rec, xRec, FieldNo("Unit Price")); // PR3.60
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

#if not CLEAN21
            trigger OnValidate()
            begin
                if "Sales Type" <> xRec."Sales Type" then begin
                    Validate("Sales Code", '');
                    UpdateValuesFromItem();
                end;
            end;
#endif
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
                if CurrFieldNo = 0 then
                    exit;

                Validate("Starting Date");

                if "Ending Date" <> 0D then
                    if "Sales Type" = "Sales Type"::Campaign then
                        Error(Text002, "Sales Type");
            end;
        }
        field(720; "Coupled to CRM"; Boolean)
        {
            Caption = 'Coupled to Dynamics 365 Sales';
            Editable = false;
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
            Description = 'PR3.60';
            OptionCaption = 'Item,Item Category,,,All Items';
            OptionMembers = Item,"Item Category",,,"All Items";

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesPrice(Rec, xRec, FieldNo("Item Type")); // PR3.60
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
                ItemSalesPriceMgmt.ValidateSalesPrice(Rec, xRec, FieldNo("Item Code")); // PR3.60
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
                ItemSalesPriceMgmt.ValidateSalesPrice(Rec, xRec, FieldNo("Pricing Method")); // PR3.60
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
                ItemSalesPriceMgmt.ValidateSalesPrice(Rec, xRec, FieldNo("Cost Reference")); // P8000539A
            end;
        }
        field(37002045; "Cost Adjustment"; Decimal)
        {
            Caption = 'Cost Adjustment';
            DecimalPlaces = 2 : 5;
            Description = 'PR3.60';

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesPrice(Rec, xRec, FieldNo("Cost Adjustment")); // PR3.60
            end;
        }
        field(37002046; "Use Break Charge"; Boolean)
        {
            Caption = 'Use Break Charge';
            Description = 'PR3.60';
        }
        field(37002047; "Break Charge"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            BlankZero = true;
            Caption = 'Break Charge';
            Description = 'PR3.60';
            Editable = false;
        }
        field(37002048; "Sales Unit Price"; Decimal)
        {
            AutoFormatExpression = "Sales Currency Code";
            AutoFormatType = 2;
            BlankZero = true;
            Caption = 'Sales Unit Price';
            DecimalPlaces = 2 : 10;
            Description = 'PR3.60';
            Editable = false;
        }
        field(37002049; "Price Type"; Option)
        {
            Caption = 'Price Type';
            Description = 'PR3.60';
            OptionCaption = 'Normal,Contract,Soft Contract';
            OptionMembers = Normal,Contract,"Soft Contract";
        }
        field(37002050; "Template ID"; Integer)
        {
            Caption = 'Template ID';
            Description = 'PR3.60';
        }
        field(37002051; "Price ID"; Integer)
        {
            AutoIncrement = true;
            Caption = 'Price ID';
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
                ItemSalesPriceMgmt.ValidateSalesPrice(Rec, xRec, FieldNo("Special Price")); // PR3.60
            end;
        }
        field(37002054; "Cost Calc. Method Code"; Code[20])
        {
            Caption = 'Cost Calc. Method Code';
            Description = 'P8000539A';
            TableRelation = IF ("Cost Reference" = CONST("Cost Calc. Method")) "Cost Calculation Method";

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesPrice(Rec, xRec, FieldNo("Cost Calc. Method Code")); // P8000539A
            end;
        }
        field(37002055; "Price Rounding Method"; Code[10])
        {
            Caption = 'Price Rounding Method';
            Description = 'P8000539A';
            TableRelation = "Rounding Method";

            trigger OnValidate()
            begin
                ItemSalesPriceMgmt.ValidateSalesPrice(Rec, xRec, FieldNo("Price Rounding Method")); // P8000539A
            end;
        }
        field(37002056; "Sales Currency Code"; Code[10])
        {
            Caption = 'Sales Currency Code';
            Description = 'P8000539A';
            TableRelation = Currency;
        }
        field(37002057; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            Description = 'PRW16.00.04';
            TableRelation = "Sales Contract";
        }
    }

    keys
    {
        key(Key1; "Item Type", "Item Code", "Sales Type", "Sales Code", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Price Type", "Pricing Method", "Cost Reference", "Cost Calc. Method Code", "Minimum Quantity", "Contract No.")
        {
        }
        key(Key2; "Sales Type", "Sales Code", "Item Type", "Item Code", "Starting Date", "Ending Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Price Type", "Pricing Method", "Cost Reference", "Use Break Charge", "Minimum Quantity", "Maximum Quantity")
        {
        }
        key(Key3; SystemModifiedAt)
        {
        }
        key(Key37002000; "Template ID", "Starting Date", "Ending Date")
        {
        }
        key(Key37002001; "Price ID")
        {
        }
        key(Key37002002; "Special Price", "Item Type", "Item Code", "Sales Type", "Sales Code", "Starting Date", "Ending Date")
        {
        }
        key(Key37002003; "Price Type", "Item Type", "Item Code", "Sales Type", "Sales Code", "Starting Date", "Ending Date")
        {
            Clustered = true;
        }
        key(Key37002004; "Contract No.")
        {
        }
        key(Key4; "Coupled to CRM")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "Sales Type", "Sales Code", "Item No.", "Starting Date", "Unit Price", "Ending Date")
        {
        }
    }

    trigger OnDelete()
    begin
        // ItemSalesPriceMgmt.DeletePriceID("Price ID"); // PR3.60, P8000546A
        SalesLinesExists; // P8000885
    end;

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
        // ItemSalesPriceMgmt.AssignPriceID(Rec); // P8000546A
        // PR3.60

        "Price ID" := 0; // P8000708
        // P8000885
        if not SalesCont.IsEmpty and ("Price Type" = "Price Type"::Contract) and ("Contract No." = '') then
            Error(Text003, FieldCaption("Price Type"), Format("Price Type"));
        // P8000885
    end;

    trigger OnRename()
    begin
        if "Sales Type" <> "Sales Type"::"All Customers" then
            TestField("Sales Code");
        // P8000885
        if "Contract No." <> '' then
            Error(Text004);
        // P8000885
        // PR3.60
        // TESTFIELD("Item No.");
        //
        ItemSalesPriceMgmt.CheckItemFieldsOnRename("Item Type", "Item Code"); // P8007749
        // PR3.60
    end;

    var
#if not CLEAN21
        CustPriceGr: Record "Customer Price Group";
        Cust: Record Customer;
        Campaign: Record Campaign;
        ItemSalesPriceMgmt: Codeunit "Item Sales Price Management";
        SalesCont: Record "Sales Contract";

        Text001: Label '%1 must be blank.';
        Text003: Label 'You can only create Sales Prices with %1 of %2 from a Sales Contract Card.';
        Text004: Label 'You cannot rename this record because it is associated with a Sales Contract.';
        Text005: Label 'You cannot delete this %1 because it is associated with one or more Sales Document.';
#endif
        Text000: Label '%1 cannot be after %2';
        Text002: Label 'If Sales Type = %1, then you can only change Starting Date and Ending Date from the Campaign Card.';

#if not CLEAN21
    protected var
        Item: Record Item;
#endif

#if not CLEAN21
    local procedure UpdateValuesFromItem()
    begin
        if Item.Get("Item No.") then begin
            "Allow Invoice Disc." := Item."Allow Invoice Disc.";
            if "Sales Type" = "Sales Type"::"All Customers" then begin
                "Price Includes VAT" := Item."Price Includes VAT";
                "VAT Bus. Posting Gr. (Price)" := Item."VAT Bus. Posting Gr. (Price)";
            end;
        end;
    end;

    procedure CopySalesPriceToCustomersSalesPrice(var SalesPrice: Record "Sales Price"; CustNo: Code[20])
    var
        NewSalesPrice: Record "Sales Price";
    begin
        if SalesPrice.FindSet() then
            repeat
                NewSalesPrice := SalesPrice;
                NewSalesPrice."Sales Type" := NewSalesPrice."Sales Type"::Customer;
                NewSalesPrice."Sales Code" := CustNo;
                OnBeforeNewSalesPriceInsert(NewSalesPrice, SalesPrice);
                if NewSalesPrice.Insert() then;
            until SalesPrice.Next() = 0;
    end;

    procedure SalesLinesExists()
    var
        SalesLine: Record "Sales Line";
        FoundRec: Boolean;
    begin
        // P8000885
        if "Contract No." = '' then
            exit;
        SalesLine.SetRange("Price ID", "Price ID");
        if not SalesLine.IsEmpty then
            Error(Text005, TableCaption);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeItemNoOnValidate(var SalesPrice: Record "Sales Price"; var xSalesPrice: Record "Sales Price"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeNewSalesPriceInsert(var NewSalesPrice: Record "Sales Price"; SalesPrice: Record "Sales Price")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateSalesCodeOnAfterGetCustomerPriceGroup(var Salesprice: Record "Sales Price"; CustPriceGroup: Record "Customer Price Group")
    begin
    end;
#endif
}

