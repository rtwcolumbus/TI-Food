table 1304 "Sales Price and Line Disc Buff"
{
    // PRW110.0
    // P8007998, To-Increase, Jack Reynolds, 15 DEC 16
    //   Modified for additional Food fields
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property

    Caption = 'Sales Price and Line Disc Buff';
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
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
#if not CLEAN19
            NotBlank = true;
            TableRelation = IF (Type = CONST(Item)) Item
            ELSE
            IF (Type = CONST(FOODItemCategory)) "Item Category"
            ELSE
            IF (Type = CONST("Item Disc. Group")) "Item Discount Group";

            trigger OnLookup()
            var
                Item: Record Item;
                ItemDiscountGroup: Record "Item Discount Group";
                ItemCategory: Record "Item Category";
            begin
                case Type of
                    Type::Item:
                        if PAGE.RunModal(PAGE::"Item List", Item) = ACTION::LookupOK then
                            Validate(Code, Item."No.");
                    Type::"Item Disc. Group":
                        if PAGE.RunModal(PAGE::"Item Disc. Groups", ItemDiscountGroup) = ACTION::LookupOK then
                            Validate(Code, ItemDiscountGroup.Code);
                    // P8007998
                    Type::FOODItemCategory:
                        if PAGE.RunModal(PAGE::"Item Categories", ItemCategory) = ACTION::LookupOK then
                            Validate(Code, ItemCategory.Code);
                        // P8007998
                    else
                        OnLookupCodeCaseElse();
                end;
            end;

            trigger OnValidate()
            var
                Item: Record Item;
                CustPriceGr: Record "Customer Price Group";
            begin
                "Unit of Measure Code" := '';
                "Variant Code" := '';

                if Type = Type::Item then
                    if Item.Get(Code) then
                        "Unit of Measure Code" := Item."Sales Unit of Measure";

                if "Line Type" = "Line Type"::"Sales Price" then begin
                    if "Sales Type" = "Sales Type"::"Customer Price/Disc. Group" then
                        if CustPriceGr.Get("Sales Code") and
                           (CustPriceGr."Allow Invoice Disc." = "Allow Invoice Disc.")
                        then
                            exit;

                    UpdateValuesFromItem;
                end;
            end;
#endif
        }
        field(2; "Sales Code"; Code[20])
        {
            Caption = 'Sales Code';
            DataClassification = SystemMetadata;
            TableRelation = IF ("Sales Type" = CONST("Customer Price/Disc. Group"),
                                "Line Type" = CONST("Sales Line Discount")) "Customer Discount Group"
            ELSE
            IF ("Sales Type" = CONST("Customer Price/Disc. Group"),
                                         "Line Type" = CONST("Sales Price")) "Customer Price Group"
            ELSE
            IF ("Sales Type" = CONST(Customer)) Customer;

            trigger OnValidate()
            var
                CustPriceGr: Record "Customer Price Group";
                Cust: Record Customer;
            begin
                if "Sales Code" <> '' then
                    case "Sales Type" of
                        "Sales Type"::"All Customers":
                            Error(MustBeBlankErr, FieldCaption("Sales Code"));
                        "Sales Type"::"Customer Price/Disc. Group":
                            if "Line Type" = "Line Type"::"Sales Price" then begin
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
                                if "Line Type" = "Line Type"::"Sales Price" then begin
                                    "Price Includes VAT" := Cust."Prices Including VAT";
                                    "VAT Bus. Posting Gr. (Price)" := Cust."VAT Bus. Posting Group";
                                    "Allow Line Disc." := Cust."Allow Line Disc.";
                                end;
                            end;
                    end;
            end;
        }
        field(3; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = SystemMetadata;
            TableRelation = Currency;
        }
        field(4; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if ("Starting Date" > "Ending Date") and ("Ending Date" <> 0D) then
                    Error(EndDateErr, FieldCaption("Starting Date"), FieldCaption("Ending Date"));
            end;
        }
        field(5; "Line Discount %"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Line Discount %';
            DataClassification = SystemMetadata;
            MaxValue = 100;
            MinValue = 0;
        }
        field(6; "Unit Price"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price';
            DataClassification = SystemMetadata;
            MinValue = 0;
        }
        field(7; "Price Includes VAT"; Boolean)
        {
            Caption = 'Price Includes VAT';
            DataClassification = SystemMetadata;
        }
        field(10; "Allow Invoice Disc."; Boolean)
        {
            Caption = 'Allow Invoice Disc.';
            DataClassification = SystemMetadata;
            InitValue = true;
        }
        field(11; "VAT Bus. Posting Gr. (Price)"; Code[20])
        {
            Caption = 'VAT Bus. Posting Gr. (Price)';
            DataClassification = SystemMetadata;
            TableRelation = "VAT Business Posting Group";
        }
        field(13; "Sales Type"; Option)
        {
            Caption = 'Sales Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Customer,Customer Price/Disc. Group,All Customers,Campaign';
            OptionMembers = Customer,"Customer Price/Disc. Group","All Customers",Campaign;

            trigger OnValidate()
            begin
                case "Sales Type" of
                    "Sales Type"::Customer:
                        Validate("Sales Code", "Loaded Customer No.");
                    "Sales Type"::"All Customers":
                        Validate("Sales Code", '');
                    "Sales Type"::"Customer Price/Disc. Group":
                        if "Loaded Customer No." = '' then
                            Validate("Sales Code", '')
                        else begin
                            if "Line Type" = "Line Type"::"Sales Price" then begin
                                if "Loaded Price Group" = '' then
                                    Error(CustNotInPriceGrErr);
                                Validate("Sales Code", "Loaded Price Group");
                            end;

                            if "Line Type" = "Line Type"::"Sales Line Discount" then begin
                                if "Loaded Disc. Group" = '' then
                                    Error(CustNotInDiscGrErr);
                                Validate("Sales Code", "Loaded Disc. Group");
                            end;
                        end;
                end;

                UpdateValuesFromItem;
            end;
        }
        field(14; "Minimum Quantity"; Decimal)
        {
            Caption = 'Minimum Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(15; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Validate("Starting Date");
            end;
        }
        field(21; Type; Enum "Sales Line Discount Type")
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;

#if not CLEAN19
            trigger OnValidate()
            begin
                case Type of
                    Type::Item:
                        Validate(Code, "Loaded Item No.");
                    Type::"Item Disc. Group":
                        begin
                            Validate(Code, '');
                            if "Loaded Item No." <> '' then begin
                                if "Loaded Disc. Group" = '' then
                                    Error(ItemNotInDiscGrErr);

                                TestField("Line Type", "Line Type"::"Sales Line Discount");
                                Validate(Code, "Loaded Disc. Group");
                            end;
                        end;
                    else
                        OnValidateTypeCaseElse();
                end;
            end;
#endif
        }
        field(1300; "Line Type"; Option)
        {
            Caption = 'Line Type';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,Sales Line Discount,Sales Price';
            OptionMembers = " ","Sales Line Discount","Sales Price";

            trigger OnValidate()
            begin
                TestField("Line Type");
                case "Line Type" of
                    "Line Type"::"Sales Price":
                        begin
                            TestField(Type, Type::Item);
                            "Line Discount %" := 0;
                        end;
                    "Line Type"::"Sales Line Discount":
                        "Unit Price" := 0;
                end;
                Validate("Sales Type", "Sales Type");
                Validate(Type, Type);
            end;
        }
        field(1301; "Loaded Item No."; Code[20])
        {
            Caption = 'Loaded Item No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(1302; "Loaded Disc. Group"; Code[20])
        {
            Caption = 'Loaded Disc. Group';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(1303; "Loaded Customer No."; Code[20])
        {
            Caption = 'Loaded Customer No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(1304; "Loaded Price Group"; Code[20])
        {
            Caption = 'Loaded Price Group';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(5400; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = SystemMetadata;
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD(Code));

            trigger OnValidate()
            begin
                TestField(Type, Type::Item);
            end;
        }
        field(5700; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = SystemMetadata;
            TableRelation = IF (Type = CONST(Item)) "Item Variant".Code WHERE("Item No." = FIELD(Code));

            trigger OnValidate()
            begin
                TestField(Type, Type::Item);
            end;
        }
        field(7001; "Allow Line Disc."; Boolean)
        {
            Caption = 'Allow Line Disc.';
            DataClassification = SystemMetadata;
            InitValue = true;
        }
        field(37002000; "Pricing Method"; Option)
        {
            Caption = 'Pricing Method';
            DataClassification = SystemMetadata;
            OptionCaption = 'Fixed Amount,Amount Markup,% Markup,% Margin';
            OptionMembers = "Fixed Amount","Amount Markup","% Markup","% Margin";
        }
        field(37002001; "Cost Reference"; Option)
        {
            Caption = 'Cost Reference';
            DataClassification = SystemMetadata;
            OptionCaption = 'Standard,Average,Last,Cost Calc. Method';
            OptionMembers = Standard,"Average",Last,"Cost Calc. Method";
        }
        field(37002002; "Cost Adjustment"; Decimal)
        {
            Caption = 'Cost Adjustment';
            DataClassification = SystemMetadata;
            DecimalPlaces = 2 : 5;
        }
        field(37002003; "Use Break Charge"; Boolean)
        {
            Caption = 'Use Break Charge';
            DataClassification = SystemMetadata;
        }
        field(37002004; "Price Type"; Option)
        {
            Caption = 'Price Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Normal,Contract,Soft Contract';
            OptionMembers = Normal,Contract,"Soft Contract";
        }
        field(37002005; "Maximum Quantity"; Decimal)
        {
            Caption = 'Maximum Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(37002006; "Special Price"; Boolean)
        {
            Caption = 'Special Price';
            DataClassification = SystemMetadata;
        }
        field(37002007; "Cost Calc. Method Code"; Code[20])
        {
            Caption = 'Cost Calc. Method Code';
            DataClassification = SystemMetadata;
            TableRelation = IF ("Cost Reference" = CONST("Cost Calc. Method")) "Cost Calculation Method";
        }
        field(37002008; "Price Rounding Method"; Code[10])
        {
            Caption = 'Price Rounding Method';
            DataClassification = SystemMetadata;
            TableRelation = "Rounding Method";
        }
        field(37002009; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            DataClassification = SystemMetadata;
            TableRelation = "Sales Contract";
        }
        field(37002100; "Line Discount Type"; Option)
        {
            Caption = 'Line Discount Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Percent,Amount,Unit Amount';
            OptionMembers = Percent,Amount,"Unit Amount";
        }
        field(37002101; "Line Discount Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Line Discount Amount';
            DataClassification = SystemMetadata;
        }
        field(37002200; "Loaded Item Category"; Code[20])
        {
            Caption = 'Loaded Item Category';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Line Type", Type, "Code", "Sales Type", "Sales Code", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Line Discount Type", "Price Type", "Pricing Method", "Cost Reference", "Cost Calc. Method Code", "Minimum Quantity", "Contract No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

#if not CLEAN19
    trigger OnDelete()
    begin
        DeleteOldRecordVersion;
    end;

    trigger OnInsert()
    begin
        if "Sales Type" = "Sales Type"::"All Customers" then
            "Sales Code" := ''
        else
            TestField("Sales Code");
        TestField(Code);

        InsertNewRecordVersion;
    end;

    trigger OnModify()
    begin
        DeleteOldRecordVersion;
        InsertNewRecordVersion;
    end;

    trigger OnRename()
    begin
        if "Sales Type" <> "Sales Type"::"All Customers" then
            TestField("Sales Code");

        TestField(Code);

        DeleteOldRecordVersion;
        InsertNewRecordVersion;
    end;
#endif

    var
        EndDateErr: Label '%1 cannot be after %2.';
        MustBeBlankErr: Label '%1 must be blank.';
        CustNotInPriceGrErr: Label 'This customer is not assigned to any price group, therefore a price group could not be used in context of this customer.';
        CustNotInDiscGrErr: Label 'This customer is not assigned to any discount group, therefore a discount group could not be used in context of this customer.';
#if not CLEAN19
        ItemNotInDiscGrErr: Label 'This item is not assigned to any discount group, therefore a discount group could not be used in context of this item.';
        IncludeVATQst: Label 'One or more of the sales prices do not include VAT.\Do you want to update all sales prices to include VAT?';
        ExcludeVATQst: Label 'One or more of the sales prices include VAT.\Do you want to update all sales prices to exclude VAT?';
        LoadedItemNo: Code[20];
        LoadedDiscGroup: Code[20];
        LoadedCustomerNo: Code[20];
        LoadedPriceGroup: Code[20];
        LoadedItemCategory: Code[20];
        DiscGroupFilter: Text;
        PriceGroupFilter: Text;
        ItemCategoryFilter: Text;
        PricesAndDiscountsCountLbl: Label 'Prices and Discounts', Locked = true;
        PricesAndDiscountsCountMsg: Label 'Total count of Prices and Discounts loaded are: %1', Locked = true;
#endif

    local procedure UpdateValuesFromItem()
    var
        Item: Record Item;
    begin
        if "Line Type" <> "Line Type"::"Sales Price" then
            exit;

        if Item.Get(Code) then begin
            "Allow Invoice Disc." := Item."Allow Invoice Disc.";
            if "Sales Type" = "Sales Type"::"All Customers" then begin
                "Price Includes VAT" := Item."Price Includes VAT";
                "VAT Bus. Posting Gr. (Price)" := Item."VAT Bus. Posting Gr. (Price)";
            end;
        end;
    end;

#if not CLEAN19
    procedure LoadDataForItem(Item: Record Item)
    var
        SalesPrice: Record "Sales Price";
        SalesLineDiscountItem: Record "Sales Line Discount";
        SalesLineDiscountItemGroup: Record "Sales Line Discount";
        ItemCategory: Record "Item Category";
    begin
        Reset;
        DeleteAll();

        LoadedItemNo := Item."No.";                 // P8007998
        LoadedDiscGroup := Item."Item Disc. Group"; // P8007998
        // P8007998
        LoadedItemCategory := Item."Item Category Code";
        if LoadedItemCategory <> '' then begin
            ItemCategory.Get(LoadedItemCategory);
            ItemCategoryFilter := ItemCategory.GetAncestorFilterString(true);
        end;
        // P8007998

        // P8007998
        // SetFiltersOnSalesPrice(SalesPrice);
        // LoadSalesPrice(SalesPrice);
        //
        // SetFiltersOnSalesLineDiscountItem(SalesLineDiscountItem);
        // LoadSalesLineDiscount(SalesLineDiscountItem);
        //
        // SetFiltersOnSalesLineDiscountItemGroup(SalesLineDiscountItemGroup);
        // LoadSalesLineDiscount(SalesLineDiscountItemGroup);
        LoadSalesPriceForItem;
        LoadSalesPriceForAllItems;
        LoadSalesPriceForItemCategory;

        LoadSalesLineDiscForItem;
        LoadSalesLineDiscForAllItems;
        LoadSalesLineDiscForItemCategory;
        LoadSalesLineDiscForItemGroup;
        // P8007998

        if FindFirst then;

        Session.LogMessage('0000AI4', StrSubstNo(PricesAndDiscountsCountMsg, Count), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PricesAndDiscountsCountLbl);
    end;

    procedure LoadDataForCustomer(Customer: Record Customer)
    begin
        LoadDataForCustomer(Customer, 0);
    end;

    procedure LoadDataForCustomer(var Customer: Record Customer; MaxNoOfLines: Integer): Integer
    var
        LoadedLines: Integer;
        RemainingLinesToLoad: Integer;
    begin
        Reset;
        DeleteAll();
        LoadedLines := 0;
        if MaxNoOfLines > 0 then
            RemainingLinesToLoad := MaxNoOfLines - LoadedLines;
        if EnoughLoaded(LoadedLines, MaxNoOfLines, RemainingLinesToLoad) then
            exit(LoadedLines);

        LoadedCustomerNo := Customer."No.";                  // P8007998
        LoadedDiscGroup := Customer."Customer Disc. Group";  // P8007998
        LoadedPriceGroup := Customer."Customer Price Group"; // P8007998
        SetCustomerGroupFilters;                             // P8007998

        LoadedLines += LoadSalesPriceForCustomer(RemainingLinesToLoad);

        LoadedLines += LoadSalesPriceForAllCustomers(RemainingLinesToLoad);
        if EnoughLoaded(LoadedLines, MaxNoOfLines, RemainingLinesToLoad) then
            exit(LoadedLines);
        LoadedLines += LoadSalesPriceForCustPriceGr(RemainingLinesToLoad);
        if EnoughLoaded(LoadedLines, MaxNoOfLines, RemainingLinesToLoad) then
            exit(LoadedLines);
        LoadedLines += LoadSalesLineDiscForCustomer(RemainingLinesToLoad);
        if EnoughLoaded(LoadedLines, MaxNoOfLines, RemainingLinesToLoad) then
            exit(LoadedLines);
        LoadedLines += LoadSalesLineDiscForAllCustomers(RemainingLinesToLoad);
        if EnoughLoaded(LoadedLines, MaxNoOfLines, RemainingLinesToLoad) then
            exit(LoadedLines);
        LoadedLines += LoadSalesLineDiscForCustDiscGr(RemainingLinesToLoad);
        if EnoughLoaded(LoadedLines, MaxNoOfLines, RemainingLinesToLoad) then
            exit(LoadedLines);
        LoadedLines += GetCustomerCampaignSalesPrice(RemainingLinesToLoad);

        if FindFirst then; // P8007998

        Session.LogMessage('0000AI3', StrSubstNo(PricesAndDiscountsCountMsg, Count), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PricesAndDiscountsCountLbl);
        exit(LoadedLines);
    end;

    Local procedure EnoughLoaded(LoadedLines: Integer; MaxNoOfLines: Integer; var RemainingLinesToLoad: Integer): Boolean
    begin
        if MaxNoOfLines > 0 then begin
            RemainingLinesToLoad := MaxNoOfLines - LoadedLines;
            exit(RemainingLinesToLoad <= 0);
        end;
        exit(false);
    end;

    local procedure LoadSalesLineDiscForCustomer(MaxNoOfLines: Integer): Integer
    var
        SalesLineDiscount: Record "Sales Line Discount";
    begin
        SetFiltersForSalesLineDiscForCustomer(SalesLineDiscount);
        exit(LoadSalesLineDiscount(SalesLineDiscount, MaxNoOfLines));
    end;

    local procedure LoadSalesLineDiscForAllCustomers(MaxNoOfLines: Integer): Integer
    var
        SalesLineDiscount: Record "Sales Line Discount";
    begin
        SetFiltersForSalesLineDiscForAllCustomers(SalesLineDiscount);
        exit(LoadSalesLineDiscount(SalesLineDiscount, MaxNoOfLines));
    end;

    local procedure LoadSalesLineDiscForCustDiscGr(MaxNoOfLines: Integer): Integer
    var
        SalesLineDiscount: Record "Sales Line Discount";
    begin
        if DiscGroupFilter = '' then // P8007998
            exit;                      // P8007998

        SetFiltersForSalesLineDiscForCustDiscGr(SalesLineDiscount);
        exit(LoadSalesLineDiscount(SalesLineDiscount, MaxNoOfLines));
    end;

    local procedure LoadSalesPriceForCustomer(MaxNoOfLines: Integer): Integer
    var
        SalesPrice: Record "Sales Price";
    begin
        SetFiltersForSalesPriceForCustomer(SalesPrice);
        exit(LoadSalesPrice(SalesPrice, MaxNoOfLines));
    end;

    local procedure LoadSalesPriceForAllCustomers(MaxNoOfLines: Integer): Integer
    var
        SalesPrice: Record "Sales Price";
    begin
        SetFiltersForSalesPriceForAllCustomers(SalesPrice);
        exit(LoadSalesPrice(SalesPrice, MaxNoOfLines));
    end;

    local procedure LoadSalesPriceForCustPriceGr(MaxNoOfLines: Integer): Integer
    var
        SalesPrice: Record "Sales Price";
    begin
        if PriceGroupFilter = '' then // P8007998
            exit;                       // P8007998

        SetFiltersForSalesPriceForCustPriceGr(SalesPrice);
        exit(LoadSalesPrice(SalesPrice, MaxNoOfLines));
    end;

    local procedure SetFiltersForSalesLineDiscForCustomer(var SalesLineDiscount: Record "Sales Line Discount")
    begin
        SalesLineDiscount.SetRange("Sales Type", "Sales Type"::Customer);
        SalesLineDiscount.SetRange("Sales Code", LoadedCustomerNo); // P8007998
    end;

    local procedure SetFiltersForSalesLineDiscForAllCustomers(var SalesLineDiscount: Record "Sales Line Discount")
    begin
        SalesLineDiscount.SetRange("Sales Type", "Sales Type"::"All Customers");
    end;

    local procedure SetFiltersForSalesLineDiscForCustDiscGr(var SalesLineDiscount: Record "Sales Line Discount")
    begin
        SalesLineDiscount.SetFilter("Sales Code", DiscGroupFilter); // P8007998
        SalesLineDiscount.SetRange("Sales Type", "Sales Type"::"Customer Price/Disc. Group");
    end;

    local procedure SetFiltersForSalesPriceForCustomer(var SalesPrice: Record "Sales Price")
    begin
        SalesPrice.SetRange("Sales Type", "Sales Type"::Customer);
        SalesPrice.SetRange("Sales Code", LoadedCustomerNo); // P8007998
    end;

    local procedure SetFiltersForSalesPriceForAllCustomers(var SalesPrice: Record "Sales Price")
    begin
        SalesPrice.SetRange("Sales Type", "Sales Type"::"All Customers");
    end;

    local procedure SetFiltersForSalesPriceForCustPriceGr(var SalesPrice: Record "Sales Price")
    begin
        SalesPrice.SetFilter("Sales Code", PriceGroupFilter); // P8007998
        SalesPrice.SetRange("Sales Type", "Sales Type"::"Customer Price/Disc. Group");
    end;

    local procedure LoadSalesLineDiscount(var SalesLineDiscount: Record "Sales Line Discount"; MaxNoOfLines: Integer): Integer
    var
        NoOfRows: Integer;
    begin
        if SalesLineDiscount.FindSet then
            repeat
                Init;
                "Line Type" := "Line Type"::"Sales Line Discount";

                Code := SalesLineDiscount."Item Code"; // P8007998
                Type := SalesLineDiscount."Item Type"; // P8007998
                "Sales Code" := SalesLineDiscount."Sales Code";
                "Sales Type" := SalesLineDiscount."Sales Type";

                "Starting Date" := SalesLineDiscount."Starting Date";
                "Minimum Quantity" := SalesLineDiscount."Minimum Quantity";
                "Unit of Measure Code" := SalesLineDiscount."Unit of Measure Code";

                "Line Discount %" := SalesLineDiscount."Line Discount %";
                "Currency Code" := SalesLineDiscount."Currency Code";
                "Ending Date" := SalesLineDiscount."Ending Date";
                "Variant Code" := SalesLineDiscount."Variant Code";

                // P8007998
                "Line Discount Type" := SalesLineDiscount."Line Discount Type";
                "Line Discount Amount" := SalesLineDiscount."Line Discount Amount";
                // P8007998

                SetLoadedFields; // P8007998
                OnLoadSalesLineDiscountOnBeforeInsert(Rec, SalesLineDiscount);
                Insert;
                NoOfRows += 1;
            until (SalesLineDiscount.Next() = 0) or (MaxNoOfLines > 0) and (NoOfRows >= MaxNoOfLines);
        exit(NoOfRows);
    end;

    local procedure LoadSalesPrice(var SalesPrice: Record "Sales Price"; MaxNoOfLines: Integer): Integer
    var
        NoOfRows: Integer;
    begin
        if SalesPrice.FindSet then
            repeat
                Init;
                "Line Type" := "Line Type"::"Sales Price";

                Code := SalesPrice."Item Code"; // P8007998
                Type := SalesPrice."Item Type"; // P8007998
                "Sales Code" := SalesPrice."Sales Code";
                "Sales Type" := SalesPrice."Sales Type".AsInteger();

                "Starting Date" := SalesPrice."Starting Date";
                "Minimum Quantity" := SalesPrice."Minimum Quantity";
                "Unit of Measure Code" := SalesPrice."Unit of Measure Code";
                "Unit Price" := SalesPrice."Unit Price";
                "Currency Code" := SalesPrice."Currency Code";
                "Ending Date" := SalesPrice."Ending Date";
                "Variant Code" := SalesPrice."Variant Code";

                "Price Includes VAT" := SalesPrice."Price Includes VAT";
                "VAT Bus. Posting Gr. (Price)" := SalesPrice."VAT Bus. Posting Gr. (Price)";

                "Allow Invoice Disc." := SalesPrice."Allow Invoice Disc.";
                "Allow Line Disc." := SalesPrice."Allow Line Disc.";

                // P8007998
                "Pricing Method" := SalesPrice."Pricing Method";
                "Cost Reference" := SalesPrice."Cost Reference";
                "Cost Adjustment" := SalesPrice."Cost Adjustment";
                "Use Break Charge" := SalesPrice."Use Break Charge";
                "Maximum Quantity" := SalesPrice."Maximum Quantity";
                "Special Price" := SalesPrice."Special Price";
                "Cost Calc. Method Code" := SalesPrice."Cost Calc. Method Code";
                "Price Rounding Method" := SalesPrice."Price Rounding Method";
                "Contract No." := SalesPrice."Contract No.";
                // P8007998

                SetLoadedFields; // P8007998
                OnLoadSalesPriceOnBeforeInsert(Rec, SalesPrice);
                Insert;
                NoOfRows += 1;
            until (SalesPrice.Next() = 0) or (MaxNoOfLines > 0) and (NoOfRows >= MaxNoOfLines);
        exit(NoOfRows);
    end;

    local procedure InsertNewPriceLine()
    var
        SalesPrice: Record "Sales Price";
    begin
        SalesPrice.Init();

        SalesPrice."Item Type" := Type; // P80096141
        SalesPrice."Item Code" := Code; // P80096141
        SalesPrice."Sales Code" := "Sales Code";
        SalesPrice."Sales Type" := "Sales Price Type".FromInteger("Sales Type");
        SalesPrice."Starting Date" := "Starting Date";
        SalesPrice."Minimum Quantity" := "Minimum Quantity";
        SalesPrice."Unit of Measure Code" := "Unit of Measure Code";
        SalesPrice."Unit Price" := "Unit Price";
        SalesPrice."Currency Code" := "Currency Code";
        SalesPrice."Ending Date" := "Ending Date";
        SalesPrice."Variant Code" := "Variant Code";

        SalesPrice."Allow Invoice Disc." := "Allow Invoice Disc.";
        SalesPrice."Allow Line Disc." := "Allow Line Disc.";
        SalesPrice."VAT Bus. Posting Gr. (Price)" := "VAT Bus. Posting Gr. (Price)";
        SalesPrice."Price Includes VAT" := "Price Includes VAT";

        // P80096141
        SalesPrice."Pricing Method" := "Pricing Method";
        SalesPrice."Cost Reference" := "Cost Reference";
        SalesPrice."Cost Adjustment" := "Cost Adjustment";
        SalesPrice."Use Break Charge" := "Use Break Charge";
        SalesPrice."Maximum Quantity" := "Maximum Quantity";
        SalesPrice."Cost Calc. Method Code" := "Cost Calc. Method Code";
        SalesPrice."Price Rounding Method" := "Price Rounding Method";
        SalesPrice."Contract No." := "Contract No.";
        // P80096141

        OnInsertNewPriceLineOnBeforeInsert(SalesPrice, Rec);
        SalesPrice.Insert(true);
    end;

    local procedure InsertNewDiscountLine()
    var
        SalesLineDiscount: Record "Sales Line Discount";
    begin
        SalesLineDiscount.Init();

        SalesLineDiscount."Item Code" := Code; // P80096141
        SalesLineDiscount."Item Type" := Type; // P80096141
        SalesLineDiscount."Sales Code" := "Sales Code";
        SalesLineDiscount."Sales Type" := "Sales Type";
        SalesLineDiscount."Starting Date" := "Starting Date";
        SalesLineDiscount."Minimum Quantity" := "Minimum Quantity";
        SalesLineDiscount."Unit of Measure Code" := "Unit of Measure Code";
        SalesLineDiscount."Line Discount %" := "Line Discount %";
        SalesLineDiscount."Currency Code" := "Currency Code";
        SalesLineDiscount."Ending Date" := "Ending Date";
        SalesLineDiscount."Variant Code" := "Variant Code";
        SalesLineDiscount."Line Discount Type" := "Line Discount Type"; // P80096141
        SalesLineDiscount."Line Discount Amount" := "Line Discount Amount"; // P80096141
        OnInsertNewDiscountLineOnBeforeInsert(SalesLineDiscount, Rec);
        SalesLineDiscount.Insert(true);
    end;

    local procedure SetFiltersOnSalesPrice(var SalesPrice: Record "Sales Price")
    begin
        SalesPrice.SetRange("Item Type", SalesPrice."Item Type"::Item); // P8007998
        SalesPrice.SetRange("Item Code", LoadedItemNo);                 // P8007998
        SalesPrice.SetFilter("Sales Type", '<> %1', SalesPrice."Sales Type"::Campaign);

        OnAfterSetFiltersOnSalesPrice(Rec);
    end;

    local procedure SetFiltersOnSalesLineDiscountItem(var SalesLineDiscount: Record "Sales Line Discount")
    begin
        SalesLineDiscount.SetRange("Item Type", SalesLineDiscount."Item Type"::Item); // P8007998
        SalesLineDiscount.SetRange("Item Code", LoadedItemNo);                        // P8007998
        SalesLineDiscount.SetFilter("Sales Type", '<> %1', SalesLineDiscount."Sales Type"::Campaign);

        OnAfterSetFiltersOnSalesLineDiscountItem(Rec);
    end;

    local procedure SetFiltersOnSalesLineDiscountItemGroup(var SalesLineDiscount: Record "Sales Line Discount")
    begin
        SalesLineDiscount.SetRange("Item Type", SalesLineDiscount."Item Type"::"Item Disc. Group"); // P8007998
        SalesLineDiscount.SetRange("Item Code", LoadedDiscGroup);                                   // P8007998
        SalesLineDiscount.SetFilter("Sales Type", '<> %1', SalesLineDiscount."Sales Type"::Campaign);

        OnAfterSetFiltersOnSalesLineDiscountItemGroup(Rec);
    end;

    procedure FilterToActualRecords()
    begin
        SetFilter("Ending Date", '%1|%2..', 0D, Today);

        OnAfterFilterToActualRecords(Rec);
    end;

    local procedure DeleteOldRecordVersion()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeDeleteOldRecordVersion(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        TestField("Line Type");
        if xRec."Line Type" = xRec."Line Type"::"Sales Line Discount" then
            DeleteOldRecordVersionFromDiscounts
        else
            DeleteOldRecordVersionFromPrices;
    end;

    local procedure DeleteOldRecordVersionFromDiscounts()
    var
        SalesLineDiscount: Record "Sales Line Discount";
    begin
        SalesLineDiscount.Get(
          xRec.Type,
          xRec.Code,
          xRec."Sales Type",
          xRec."Sales Code",
          xRec."Starting Date",
          xRec."Currency Code",
          xRec."Variant Code",
          xRec."Unit of Measure Code",
          xRec."Line Discount Type", // P80096141
          xRec."Minimum Quantity");

        SalesLineDiscount.Delete(true);
    end;

    local procedure DeleteOldRecordVersionFromPrices()
    var
        SalesPrice: Record "Sales Price";
        IsHandled: Boolean;
    begin
        OnBeforeDeleteOldRecordVersionFromPrices(xRec, IsHandled);
        if IsHandled then
            exit;

        SalesPrice.Get(
          xRec.Type, // P80096141
          xRec.Code,
          xRec."Sales Type",
          xRec."Sales Code",
          xRec."Starting Date",
          xRec."Currency Code",
          xRec."Variant Code",
          xRec."Unit of Measure Code",
          xRec."Price Type", // P80096141
          xrec."Pricing Method", // P80096141
          xRec."Cost Reference", // P80096141
          xrec."Cost Calc. Method Code", // P80096141
          xRec."Minimum Quantity",
          xRec."Contract No."); // P80096141

        SalesPrice.Delete(true);
    end;

    local procedure InsertNewRecordVersion()
    begin
        TestField("Line Type");
        if "Line Type" = "Line Type"::"Sales Line Discount" then
            InsertNewDiscountLine
        else
            InsertNewPriceLine
    end;

    procedure CustHasLines(Cust: Record Customer): Boolean
    var
        SalesLineDiscount: Record "Sales Line Discount";
        SalesPrice: Record "Sales Price";
    begin
        Reset;

        LoadedCustomerNo := Cust."No.";                  // P8007998
        LoadedDiscGroup := Cust."Customer Disc. Group";  // P8007998
        LoadedPriceGroup := Cust."Customer Price Group"; // P8007998
        SetCustomerGroupFilters;                         // P8007998

        SetFiltersForSalesLineDiscForAllCustomers(SalesLineDiscount);
        if SalesLineDiscount.Count > 0 then
            exit(true);
        Clear(SalesLineDiscount);

        SetFiltersForSalesPriceForAllCustomers(SalesPrice);
        if SalesPrice.Count > 0 then
            exit(true);
        Clear(SalesPrice);

        if DiscGroupFilter <> '' then begin // P8007998
            SetFiltersForSalesLineDiscForCustDiscGr(SalesLineDiscount);
            if SalesLineDiscount.Count > 0 then
                exit(true);
            Clear(SalesLineDiscount);
        end;                                // P8007998

        if PriceGroupFilter <> '' then begin // P8007998
            SetFiltersForSalesPriceForCustPriceGr(SalesPrice);
            if SalesPrice.Count > 0 then
                exit(true);
            Clear(SalesPrice);
        end;                                 // P8007998

        SetFiltersForSalesLineDiscForCustomer(SalesLineDiscount);
        if SalesLineDiscount.Count > 0 then
            exit(true);
        Clear(SalesLineDiscount);

        SetFiltersForSalesPriceForCustomer(SalesPrice);
        if SalesPrice.Count > 0 then
            exit(true);

        exit(false);
    end;

    procedure ItemHasLines(Item: Record Item): Boolean
    var
        SalesLineDiscount: Record "Sales Line Discount";
        SalesPrice: Record "Sales Price";
        ItemCategory: Record "Item Category";
    begin
        Reset;

        LoadedItemNo := Item."No.";                 // P8007998
        LoadedDiscGroup := Item."Item Disc. Group"; // P8007998
        // P8007998
        LoadedItemCategory := Item."Item Category Code";
        if LoadedItemCategory <> '' then begin
            ItemCategory.Get(LoadedItemCategory);
            ItemCategoryFilter := ItemCategory.GetAncestorFilterString(true);
        end;
        // P8007998

        SetFiltersOnSalesPrice(SalesPrice);
        if not SalesPrice.IsEmpty() then
            exit(true);

        // P80096141
        SetFilterOnSalesPriceAllItems(SalesPrice);
        if not SalesPrice.IsEmpty then
            exit(true);

        if ItemCategoryFilter <> '' then begin
            SetFilterOnSalesPriceItemCategory(SalesPrice);
            if not SalesPrice.IsEmpty then
                exit(true);
        end;
        // P80096141

        SetFiltersOnSalesLineDiscountItem(SalesLineDiscount);
        if not SalesLineDiscount.IsEmpty() then
            exit(true);
        Clear(SalesLineDiscount);

        SetFiltersOnSalesLineDiscountItemGroup(SalesLineDiscount);
        if not SalesLineDiscount.IsEmpty() then
            exit(true);

        // P80096141
        SetFilterOnSalesLineDiscountAllItems(SalesLineDiscount);
        if not SalesLineDiscount.IsEmpty then
            exit(true);

        if ItemCategoryFilter <> '' then begin
            SetFilterOnSalesLineDiscountItemCategory(SalesLineDiscount);
            if not SalesLineDiscount.IsEmpty then
                exit(true);
        end;

        // P80096141
        exit(false);
    end;

    procedure UpdatePriceIncludesVatAndPrices(Item: Record Item; IncludesVat: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        MsgQst: Text;
    begin
        SetRange("Price Includes VAT", not IncludesVat);
        SetRange("Line Type", "Line Type"::"Sales Price");
        SetRange(Type, Type::Item);
        SetFilter("Unit Price", '>0');

        if not FindSet then
            exit;

        if IncludesVat then
            MsgQst := IncludeVATQst
        else
            MsgQst := ExcludeVATQst;

        if not Confirm(MsgQst, false) then
            exit;

        repeat
            VATPostingSetup.Get("VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group");
            OnAfterVATPostingSetupGet(VATPostingSetup);

            "Price Includes VAT" := IncludesVat;

            if IncludesVat then
                "Unit Price" := "Unit Price" * (100 + VATPostingSetup."VAT %") / 100
            else
                "Unit Price" := "Unit Price" * 100 / (100 + VATPostingSetup."VAT %");

            Modify(true);
        until Next() = 0;
    end;

    local procedure LoadSalesPriceForItem()
    var
        SalesPrice: Record "Sales Price";
    begin
        // P8007998
        SetFiltersOnSalesPrice(SalesPrice);
        LoadSalesPrice(SalesPrice, 0);
    end;

    local procedure LoadSalesPriceForAllItems()
    var
        SalesPrice: Record "Sales Price";
    begin
        // P8007998
        SetFilterOnSalesPriceAllItems(SalesPrice);
        LoadSalesPrice(SalesPrice, 0);
    end;

    local procedure LoadSalesPriceForItemCategory()
    var
        SalesPrice: Record "Sales Price";
    begin
        // P8007998
        if ItemCategoryFilter = '' then
            exit;

        SetFilterOnSalesPriceItemCategory(SalesPrice);
        LoadSalesPrice(SalesPrice, 0);
    end;

    local procedure LoadSalesLineDiscForItem()
    var
        SalesLineDiscount: Record "Sales Line Discount";
    begin
        // P8007998
        SetFiltersOnSalesLineDiscountItem(SalesLineDiscount);
        LoadSalesLineDiscount(SalesLineDiscount, 0);
    end;

    local procedure LoadSalesLineDiscForAllItems()
    var
        SalesLineDiscount: Record "Sales Line Discount";
    begin
        // P8007998
        SetFilterOnSalesLineDiscountAllItems(SalesLineDiscount);
        LoadSalesLineDiscount(SalesLineDiscount, 0);
    end;

    local procedure LoadSalesLineDiscForItemCategory()
    var
        SalesLineDiscount: Record "Sales Line Discount";
    begin
        // P8007998
        if ItemCategoryFilter = '' then
            exit;

        SetFilterOnSalesLineDiscountItemCategory(SalesLineDiscount);
        LoadSalesLineDiscount(SalesLineDiscount, 0);
    end;

    local procedure LoadSalesLineDiscForItemGroup()
    var
        SalesLineDiscount: Record "Sales Line Discount";
    begin
        // P8007998
        SetFiltersOnSalesLineDiscountItemGroup(SalesLineDiscount);
        LoadSalesLineDiscount(SalesLineDiscount, 0);
    end;

    local procedure SetFilterOnSalesPriceAllItems(var SalesPrice: Record "Sales Price")
    begin
        // P8007998
        SalesPrice.SetRange("Item Type", SalesPrice."Item Type"::"All Items");
    end;

    local procedure SetFilterOnSalesPriceItemCategory(var SalesPrice: Record "Sales Price")
    begin
        // P8007998
        SalesPrice.SetRange("Item Type", SalesPrice."Item Type"::"Item Category");
        SalesPrice.SetFilter("Item Code", ItemCategoryFilter);
    end;

    local procedure SetFilterOnSalesLineDiscountAllItems(var SalesLineDiscount: Record "Sales Line Discount")
    begin
        // P8007998
        SalesLineDiscount.SetRange("Item Type", SalesLineDiscount."Item Type"::"All Items");
    end;

    local procedure SetFilterOnSalesLineDiscountItemCategory(var SalesLineDiscount: Record "Sales Line Discount")
    begin
        // P8007998
        SalesLineDiscount.SetRange("Item Type", SalesLineDiscount."Item Type"::"Item Category");
        SalesLineDiscount.SetFilter("Item Code", ItemCategoryFilter);
    end;

    local procedure SetCustomerGroupFilters()
    var
        CustItemPriceDiscGroup: Record "Cust./Item Price/Disc. Group";
    begin
        // P8007998
        CustItemPriceDiscGroup.SetRange("Customer No.", LoadedCustomerNo);
        if CustItemPriceDiscGroup.FindSet then begin
            if LoadedDiscGroup <> '' then
                DiscGroupFilter := '|' + LoadedDiscGroup
            else
                DiscGroupFilter := '';

            if LoadedPriceGroup <> '' then
                PriceGroupFilter := '|' + LoadedPriceGroup
            else
                PriceGroupFilter := '';

            repeat
                if CustItemPriceDiscGroup."Customer Disc. Group" <> '' then
                    DiscGroupFilter := DiscGroupFilter + '|' + CustItemPriceDiscGroup."Customer Disc. Group";
                if CustItemPriceDiscGroup."Customer Price Group" <> '' then
                    PriceGroupFilter := PriceGroupFilter + '|' + CustItemPriceDiscGroup."Customer Price Group";
            until CustItemPriceDiscGroup.Next = 0;

            DiscGroupFilter := CopyStr(DiscGroupFilter, 2);
            PriceGroupFilter := CopyStr(PriceGroupFilter, 2);
        end;
    end;

    local procedure SetLoadedFields()
    begin
        // P8007998
        "Loaded Item No." := LoadedItemNo;
        "Loaded Disc. Group" := LoadedDiscGroup;
        "Loaded Customer No." := LoadedCustomerNo;
        "Loaded Price Group" := LoadedPriceGroup;
        "Loaded Item Category" := LoadedItemCategory;
    end;

    local procedure GetCustomerCampaignSalesPrice(MaxNoOfLines: Integer): Integer
    var
        ContactBusinessRelation: Record "Contact Business Relation";
        SalesPrice: Record "Sales Price";
        TempCampaign: Record Campaign temporary;
        RemainingLinesToLoad: Integer;
        LoadedLines: Integer;
    begin
        if not ContactBusinessRelation.FindByRelation(ContactBusinessRelation."Link to Table"::Customer, "Loaded Customer No.") then
            exit(0);
        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::Campaign);
        if SalesPrice.IsEmpty() then
            exit;

        GetContactCampaigns(TempCampaign, ContactBusinessRelation."Contact No.");

        RemainingLinesToLoad := MaxNoOfLines;
        TempCampaign.SetAutoCalcFields(Activated);
        TempCampaign.SetRange(Activated, true);
        if TempCampaign.FindSet() then
            repeat
                SalesPrice.SetRange("Sales Code", TempCampaign."No.");
                LoadedLines += LoadSalesPrice(SalesPrice, RemainingLinesToLoad);
            until (TempCampaign.Next() = 0) or EnoughLoaded(LoadedLines, MaxNoOfLines, RemainingLinesToLoad);
        exit(LoadedLines);
    end;

    local procedure GetContactCampaigns(var TempCampaign: Record Campaign temporary; CompanyContactNo: Code[20])
    var
        Contact: Record Contact;
        SegmentLine: Record "Segment Line";
    begin
        Contact.SetLoadFields("No.", "Company No.");
        Contact.SetRange("Company No.", CompanyContactNo);
        if Contact.FindSet then begin
            SegmentLine.SetFilter("Campaign No.", '<>%1', '');
            SegmentLine.SetRange("Campaign Target", true);
            repeat
                SegmentLine.SetRange("Contact No.", Contact."No.");
                InsertTempCampaignFromSegmentLines(TempCampaign, SegmentLine);
            until Contact.Next() = 0;
        end;
    end;

    local procedure InsertTempCampaignFromSegmentLines(var TempCampaign: Record Campaign temporary; var SegmentLine: Record "Segment Line")
    begin
        SegmentLine.SetLoadFields("Segment No.", "Line No.", "Campaign No.", "Campaign Target");
        if SegmentLine.FindSet then
            repeat
                TempCampaign.Init();
                TempCampaign."No." := SegmentLine."Campaign No.";
                if TempCampaign.Insert() then;
            until SegmentLine.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterVATPostingSetupGet(var VATPostingSetup: Record "VAT Posting Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteOldRecordVersion(var SalesPriceAndLineDiscBuff: Record "Sales Price and Line Disc Buff"; xSalesPriceAndLineDiscBuff: Record "Sales Price and Line Disc Buff"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteOldRecordVersionFromPrices(xSalesPriceAndLineDiscBuff: Record "Sales Price and Line Disc Buff"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertNewDiscountLineOnBeforeInsert(var SalesLineDiscount: Record "Sales Line Discount"; SalesPriceAndLineDiscBuff: Record "Sales Price and Line Disc Buff")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertNewPriceLineOnBeforeInsert(var SalesPrice: Record "Sales Price"; SalesPriceAndLineDiscBuff: Record "Sales Price and Line Disc Buff")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLoadSalesLineDiscountOnBeforeInsert(var SalesPriceAndLineDiscBuff: Record "Sales Price and Line Disc Buff"; SalesLineDiscount: Record "Sales Line Discount")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLoadSalesPriceOnBeforeInsert(var SalesPriceAndLineDiscBuff: Record "Sales Price and Line Disc Buff"; SalesPrice: Record "Sales Price")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnLookupCodeCaseElse()
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateTypeCaseElse()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetFiltersOnSalesPrice(var SalesPriceandLineDiscBuff: Record "Sales Price and Line Disc Buff")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetFiltersOnSalesLineDiscountItem(var SalesPriceandLineDiscBuff: Record "Sales Price and Line Disc Buff")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetFiltersOnSalesLineDiscountItemGroup(var SalesPriceandLineDiscBuff: Record "Sales Price and Line Disc Buff")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFilterToActualRecords(var SalesPriceandLineDiscBuff: Record "Sales Price and Line Disc Buff")
    begin
    end;
#endif
}

