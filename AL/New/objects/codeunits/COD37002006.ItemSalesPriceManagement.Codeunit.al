codeunit 37002006 "Item Sales Price Management"
{
    // PR3.60
    //   Sales Pricing & Line Discounts
    // 
    // PR3.61.01
    //   Fix permission problem with DeletePriceID
    // 
    // PR3.61.02
    //   Don't convert prices based on UOM for items priced in alternate units
    // 
    // PR3.70.05
    // P8000068A, Myers Nissi, Jack Reynolds, 13 JUL 04
    //   ValidatePriceItemCode1 - test sales type for "Customer Price Group" before attempting GET
    // 
    // PR4.00
    // P8000245B, Myers Nissi, Jack Reynolds, 04 OCT 05
    //   CalculateCostBasedPrice - use variant code when getting market price
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   PriceAtShipment - pass parameter for posting location and filter sales lines based on this
    // 
    // PR4.00.03
    // P8000345A, VerticalSoft, Jack Reynolds, 08 JUN 06
    //   Support for Unit Amount as line discount type
    // 
    // PR4.00.04
    // P8000360A, VerticalSoft, Jack Reynolds, 26 JUL 06
    //   Fix problem with exchange rate conversion
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 21 JUN 07
    //   PriceAtShipment - Save and restore prepayment reference amount
    // 
    // P8000539A, VerticalSoft, Don Bresee, 13 NOV 07
    //   Eliminate addition of break charge to a price of 0
    //   Eliminate addition of amount markup to a cost-based price of 0
    //   Add Cost Calculation Method and Rounding Method
    //   Add new Break Charge options
    //   Add Sales Currency Code
    // 
    // P8000545A, VerticalSoft, Don Bresee, 13 NOV 07
    //   Add routines to determine proper price/disc. group
    // 
    // PR6.00.01
    // P8000708, VerticalSoft, Don Bresee, 20 JUL 09
    //   Skip re-pricing at shipment for sales samples
    // 
    // P8000716, VerticalSoft, Jack Reynolds, 07 AUG 09
    //   Fix problem with prices for specific UOM and costing by alternate
    // 
    // PRW16.00.05
    // P8000981, Columbus IT, Don Bresee, 20 SEP 11
    //   Separate Costing and Pricing units
    // 
    // PRW17.10
    // P8001244, Columbus IT, Jack Reynolds, 20 NOV 13
    //   Fix problem setting Sales Type and Item Type filters
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

    Permissions = TableData "Sales Invoice Line" = m;

    trigger OnRun()
    begin
    end;

    var
        Text000: Label '%1 must be blank for %2 %3.';
        Text001: Label '%1 must be not blank for %2 %3.';
        Text002: Label 'You cannot use the %1 %2 with the %3 %4.';
        Text003: Label '%1 must not be less than -100 for %2 %3.';
        Item: Record Item;
        SourceSalesPrice: Record "Sales Price";
        SourceSalesLineDisc: Record "Sales Line Discount";
        SourceUnitOfMeasure: Record "Item Unit of Measure";
        SourceCustomerNo: Code[20];
        SourceCurrencyFactor: Decimal;
        SourceExchRateDate: Date;
        SourceQtyToIgnore: Decimal;
        SourcePriceIDToIgnore: Integer;
        SourceLineAmount: Decimal;
        SourceLineQty: Decimal;
        PriceTemplatePrice: Record "Sales Price";
        CurrencyExchRate: Record "Currency Exchange Rate";
        InventorySetup: Record "Inventory Setup";
        InventorySetupRead: Boolean;
        Text004: Label '%1 must be less than 100 for %2 %3.';
        Text005: Label 'All Items';
        Text006: Label 'Shipment %1 requires a quantity of %2 (%3) for %4 %5 to be invoiced at a %6 of %7.';
        RoundingCurrency: Record Currency;
        RoundingCurrencyIsSetup: Boolean;
        NumBestFieldFilters: Integer;
        BestFieldFilter: array[9] of Integer;
        Text007: Label 'You cannot use the %1 %2 for a %3.';
        Text008: Label 'You cannot use the %1 %2 for a %3 unless %4 is checked.';
        ProcessFns: Codeunit "Process 800 Functions";

    procedure CheckItemFieldsOnInsert(ItemType: Integer; ItemCode: Code[20])
    var
        SalesPrice: Record "Sales Price";
    begin
        // P8007749 - change parameter ItemCode1 to ItemCode, remove ItemCode2
        TestItemFields(ItemType, ItemCode); // P8007749
        with SalesPrice do begin
            "Item Type" := ItemType;
            if ("Item Type" = "Item Type"::"All Items") then
                ItemCode := '';
        end;
    end;

    procedure CheckItemFieldsOnRename(ItemType: Integer; ItemCode: Code[20])
    begin
        // P8007749 - change parameter ItemCode1 to ItemCode, remove ItemCode2
        TestItemFields(ItemType, ItemCode); // P8007749
    end;

    local procedure TestItemFields(ItemType: Integer; ItemCode: Code[20])
    var
        SalesPrice: Record "Sales Price";
    begin
        // P8007749 - change parameter ItemCode1 to ItemCode, remove ItemCode2
        with SalesPrice do begin
            "Item Type" := ItemType;
            if ("Item Type" <> "Item Type"::"All Items") and (ItemCode = '') then
                Error(Text001, FieldCaption("Item Code"),
                  "Item Type", FieldCaption("Item Type"));
        end;
    end;

    procedure ValidateSalesPrice(var SalesPrice: Record "Sales Price"; OldSalesPrice: Record "Sales Price"; FldNo: Integer)
    var
        ZeroFields: Boolean;
    begin
        // ValidateSalesPrice
        with SalesPrice do
            case FldNo of

                FieldNo("Item Type"):
                    begin
                        if ("Item Type" <> OldSalesPrice."Item Type") then begin
                            if not ProcessFns.PricingInstalled then
                                TestField("Item Type", "Item Type"::Item);

                            Validate("Item Code", '');
                            PriceItemCodeChange(SalesPrice);
                        end;

                        if ("Item Type" <> "Item Type"::Item) and
                           ("Pricing Method" in ["Pricing Method"::"Fixed Amount", "Pricing Method"::"Amount Markup"])
                        then
                            Validate("Pricing Method", "Pricing Method"::"% Markup");

                        if ("Item Type" <> "Item Type"::Item) and "Special Price" then
                            Error(Text007, "Item Type", FieldCaption("Item Type"), FieldCaption("Special Price"));
                    end;

                FieldNo("Item Code"):
                    begin
                        ValidatePriceItemCode(
                          "Item Type", "Item Code", // P8007749
                          "Sales Type", "Sales Code", "Allow Invoice Disc.");

                        if ("Item Code" <> OldSalesPrice."Item Code") then
                            PriceItemCodeChange(SalesPrice);
                    end;

                FieldNo("Pricing Method"):
                    if ("Pricing Method" <> OldSalesPrice."Pricing Method") then begin
                        if not ProcessFns.PricingInstalled then
                            TestField("Pricing Method", "Pricing Method"::"Fixed Amount");

                        ValidatePricePricingMethod(
                          "Item Type", "Pricing Method",
                          OldSalesPrice."Pricing Method", "Cost Adjustment", ZeroFields);

                        if not ZeroFields then
                            Validate("Cost Adjustment")
                        else begin
                            Validate("Unit Price", 0);
                            Validate("Cost Adjustment", 0);
                            Validate("Cost Reference", 0);
                        end;
                    end;

                FieldNo("Unit Price"):
                    ValidatePriceUnitPrice("Pricing Method", "Unit Price", FieldCaption("Unit Price"));

                FieldNo("Cost Adjustment"):
                    ValidatePriceCostAdjustment(
                      "Pricing Method", "Cost Adjustment", FieldCaption("Cost Adjustment"));

                FieldNo("Special Price"):
                    if ("Item Type" <> "Item Type"::Item) and "Special Price" then
                        Error(Text007, "Item Type", FieldCaption("Item Type"), FieldCaption("Special Price"));

                // P8000539A
                FieldNo("Cost Reference"):
                    if ("Cost Reference" <> "Cost Reference"::"Cost Calc. Method") then
                        Validate("Cost Calc. Method Code", '');

                FieldNo("Cost Calc. Method Code"):
                    if ("Cost Calc. Method Code" <> '') then
                        TestField("Cost Reference", "Cost Reference"::"Cost Calc. Method");

                FieldNo("Price Rounding Method"):
                    if ("Price Rounding Method" <> '') and ("Pricing Method" = "Pricing Method"::"Fixed Amount") then
                        Error(Text000, FieldCaption("Price Rounding Method"), "Pricing Method", FieldCaption("Pricing Method"));
                    // P8000539A
            end;
    end;

    local procedure PriceItemCodeChange(var SalesPrice: Record "Sales Price")
    begin
        // P8007749 renamed from PriceItemCode1Change
        with SalesPrice do begin
            if ("Item Type" = "Item Type"::Item) then begin
                Validate("Unit of Measure Code", '');
                Validate("Variant Code", '');
            end;
        end;
    end;

    procedure ValidateSalesWksh(var SalesPriceWksh: Record "Sales Price Worksheet"; OldSalesPriceWksh: Record "Sales Price Worksheet"; FldNo: Integer)
    var
        ZeroFields: Boolean;
    begin
        // ValidateSalesWksh
        with SalesPriceWksh do
            case FldNo of

                FieldNo("Item Type"):
                    begin
                        if ("Item Type" <> OldSalesPriceWksh."Item Type") then begin
                            if not ProcessFns.PricingInstalled then
                                TestField("Item Type", "Item Type"::Item);

                            Validate("Item Code", '');
                            WkshItemCodeChange(SalesPriceWksh);
                        end;

                        if ("Item Type" <> "Item Type"::Item) and
                           ("Pricing Method" in ["Pricing Method"::"Fixed Amount", "Pricing Method"::"Amount Markup"])
                        then
                            Validate("Pricing Method", "Pricing Method"::"% Markup");

                        if ("Item Type" <> "Item Type"::Item) and "Special Price" then
                            Error(Text007, "Item Type", FieldCaption("Item Type"), FieldCaption("Special Price"));
                    end;

                FieldNo("Item Code"):
                    begin
                        ValidatePriceItemCode(
                          "Item Type", "Item Code", // P8007749
                          "Sales Type", "Sales Code", "Allow Invoice Disc.");

                        if ("Item Code" <> OldSalesPriceWksh."Item Code") then
                            WkshItemCodeChange(SalesPriceWksh);
                    end;

                FieldNo("Pricing Method"):
                    if ("Pricing Method" <> OldSalesPriceWksh."Pricing Method") then begin
                        if not ProcessFns.PricingInstalled then
                            TestField("Pricing Method", "Pricing Method"::"Fixed Amount");

                        ValidatePricePricingMethod(
                          "Item Type", "Pricing Method",
                          OldSalesPriceWksh."Pricing Method", "New Cost Adjustment", ZeroFields);

                        if not ZeroFields then
                            Validate("New Cost Adjustment")
                        else begin
                            Validate("New Unit Price", 0);
                            Validate("New Cost Adjustment", 0);
                            Validate("Cost Reference", 0);
                        end;
                    end;

                FieldNo("New Unit Price"):
                    ValidatePriceUnitPrice(
                      "Pricing Method", "New Unit Price", FieldCaption("New Unit Price"));

                FieldNo("New Cost Adjustment"):
                    ValidatePriceCostAdjustment(
                      "Pricing Method", "New Cost Adjustment", FieldCaption("New Cost Adjustment"));

                FieldNo("Special Price"):
                    if ("Item Type" <> "Item Type"::Item) and "Special Price" then
                        Error(Text007, "Item Type", FieldCaption("Item Type"), FieldCaption("Special Price"));

                // P8000539A
                FieldNo("Cost Reference"):
                    if ("Cost Reference" <> "Cost Reference"::"Cost Calc. Method") then
                        Validate("Cost Calc. Method Code", '');

                FieldNo("Cost Calc. Method Code"):
                    if ("Cost Calc. Method Code" <> '') then
                        TestField("Cost Reference", "Cost Reference"::"Cost Calc. Method");

                FieldNo("Price Rounding Method"):
                    if ("Price Rounding Method" <> '') and ("Pricing Method" = "Pricing Method"::"Fixed Amount") then
                        Error(Text000, FieldCaption("Price Rounding Method"), "Pricing Method", FieldCaption("Pricing Method"));
                    // P8000539A
            end;
    end;

    local procedure WkshItemCodeChange(var SalesPriceWksh: Record "Sales Price Worksheet")
    begin
        // P8007749 - renamed from WkshItemCode1Change
        with SalesPriceWksh do begin
            if ("Item Type" = "Item Type"::Item) then begin
                Validate("Unit of Measure Code", '');
                Validate("Variant Code", '');
            end;
        end;
    end;

    procedure ValidateSalesPriceTemplate(var SalesPriceTemplate: Record "Recurring Price Template"; OldSalesPriceTemplate: Record "Recurring Price Template"; FldNo: Integer)
    var
        ZeroFields: Boolean;
    begin
        // ValidateSalesPrceTemplate
        with SalesPriceTemplate do
            case FldNo of

                FieldNo("Item Type"):
                    begin
                        if ("Item Type" <> OldSalesPriceTemplate."Item Type") then begin
                            Validate("Item Code", '');
                            PriceTemplateItemCodeChange(SalesPriceTemplate);
                        end;

                        if ("Item Type" <> "Item Type"::Item) and
                           ("Pricing Method" in ["Pricing Method"::"Fixed Amount", "Pricing Method"::"Amount Markup"])
                        then
                            Validate("Pricing Method", "Pricing Method"::"% Markup");

                        // P8000546A
                        /*
                        IF ("Item Type" <> "Item Type"::Item) AND
                           (NOT "Generate Fixed Item Prices") AND "Special Price"
                        THEN
                          ERROR(Text008, "Item Type", FIELDCAPTION("Item Type"),
                                FIELDCAPTION("Special Price"), FIELDCAPTION("Generate Fixed Item Prices"));
                        */
                        // P8000546A
                    end;

                FieldNo("Item Code"):
                    begin
                        ValidatePriceItemCode(
                          "Item Type", "Item Code", // P8007749
                          "Sales Type", "Sales Code", "Allow Invoice Disc.");

                        if ("Item Code" <> OldSalesPriceTemplate."Item Code") then
                            PriceTemplateItemCodeChange(SalesPriceTemplate);
                    end;

                FieldNo("Pricing Method"):
                    if ("Pricing Method" <> OldSalesPriceTemplate."Pricing Method") then begin
                        ValidatePricePricingMethod(
                          "Item Type", "Pricing Method",
                          OldSalesPriceTemplate."Pricing Method", "Cost Adjustment", ZeroFields);

                        if not ZeroFields then
                            Validate("Cost Adjustment")
                        else begin
                            Validate("Cost Adjustment", 0);
                            Validate("Cost Reference", 0);
                        end;

                        Validate("Generate Fixed Item Prices");
                    end;

                FieldNo("Unit Price"):
                    ValidatePriceUnitPrice("Pricing Method", "Unit Price", FieldCaption("Unit Price"));

                FieldNo("Cost Adjustment"):
                    ValidatePriceCostAdjustment(
                      "Pricing Method", "Cost Adjustment", FieldCaption("Cost Adjustment"));

                FieldNo("Starting Date"):
                    if ("Starting Date" <> 0D) and ("Next Date" = 0D) then
                        Validate("Next Date", "Starting Date");

                FieldNo("Generate Fixed Item Prices"):
                    begin
                        if ("Pricing Method" = "Pricing Method"::"Fixed Amount") then
                            "Generate Fixed Item Prices" := true;

                        // P8000546A
                        /*
                        IF ("Item Type" <> "Item Type"::Item) AND
                           (NOT "Generate Fixed Item Prices") AND "Special Price"
                        THEN
                          ERROR(Text008, "Item Type", FIELDCAPTION("Item Type"),
                                FIELDCAPTION("Special Price"), FIELDCAPTION("Generate Fixed Item Prices"));
                        */
                        // P8000546A
                    end;

                // P8000546A
                /*
                FIELDNO("Special Price") :
                  IF ("Item Type" <> "Item Type"::Item) AND
                     (NOT "Generate Fixed Item Prices") AND "Special Price"
                  THEN
                    ERROR(Text008, "Item Type", FIELDCAPTION("Item Type"),
                          FIELDCAPTION("Special Price"), FIELDCAPTION("Generate Fixed Item Prices"));
                */
                // P8000546A

                // P8000539A
                FieldNo("Cost Reference"):
                    if ("Cost Reference" <> "Cost Reference"::"Cost Calc. Method") then
                        Validate("Cost Calc. Method Code", '');

                FieldNo("Cost Calc. Method Code"):
                    if ("Cost Calc. Method Code" <> '') then
                        TestField("Cost Reference", "Cost Reference"::"Cost Calc. Method");

                FieldNo("Price Rounding Method"):
                    if ("Price Rounding Method" <> '') and ("Pricing Method" = "Pricing Method"::"Fixed Amount") then
                        Error(Text000, FieldCaption("Price Rounding Method"), "Pricing Method", FieldCaption("Pricing Method"));
                    // P8000539A
            end;

    end;

    local procedure PriceTemplateItemCodeChange(var SalesPriceTemplate: Record "Recurring Price Template")
    begin
        // P8007749 - renamed from PriceTemplateItemCode1Change
        with SalesPriceTemplate do begin
            if ("Item Type" = "Item Type"::Item) then begin
                Validate("Unit of Measure Code", '');
                Validate("Variant Code", '');
            end;
        end;
    end;

    procedure ValidateSalesLineDisc(var SalesLineDisc: Record "Sales Line Discount"; OldSalesLineDisc: Record "Sales Line Discount"; FldNo: Integer)
    var
        AllowInvoiceDisc: Boolean;
    begin
        // ValidateSalesLineDisc
        with SalesLineDisc do
            case FldNo of

                FieldNo("Item Type"):
                    if ("Item Type" <> OldSalesLineDisc."Item Type") then begin
                        if not ProcessFns.PricingInstalled then
                            if not ("Item Type" in ["Item Type"::Item, "Item Type"::"Item Disc. Group"]) then
                                FieldError("Item Type");

                        Validate("Item Code", '');
                        LineDiscItemCodeChange(SalesLineDisc);
                    end;

                FieldNo("Item Code"):
                    begin
                        ValidatePriceItemCode(
                          "Item Type", "Item Code", // P8007749
                          "Sales Type", "Sales Code", AllowInvoiceDisc);

                        if ("Item Code" <> OldSalesLineDisc."Item Code") then
                            LineDiscItemCodeChange(SalesLineDisc);
                    end;

                FieldNo("Line Discount Type"):
                    if ("Line Discount Type" <> OldSalesLineDisc."Line Discount Type") then begin
                        if not ProcessFns.PricingInstalled then
                            TestField("Line Discount Type", "Line Discount Type"::Percent);
                        if (OldSalesLineDisc."Line Discount Type" = "Line Discount Type"::Percent) then
                            Validate("Line Discount %", 0)
                        else
                            Validate("Line Discount Amount", 0);
                    end;

                FieldNo("Line Discount %"):
                    if ("Line Discount Type" <> "Line Discount Type"::Percent) and ("Line Discount %" <> 0) then
                        Error(Text000, FieldCaption("Line Discount %"),
                              "Line Discount Type", FieldCaption("Line Discount Type"));

                FieldNo("Line Discount Amount"):
                    if (not ("Line Discount Type" in ["Line Discount Type"::Amount, "Line Discount Type"::"Unit Amount"])) and // P8000345A
                      ("Line Discount Amount" <> 0)                                                                           // P8000345A
                    then                                                                                                      // P8000345A
                        Error(Text000, FieldCaption("Line Discount Amount"),
                              "Line Discount Type", FieldCaption("Line Discount Type"));
            end;
    end;

    local procedure LineDiscItemCodeChange(var SalesLineDisc: Record "Sales Line Discount")
    begin
        // P8007749 - renamed from LineDiscItemCode1Change
        with SalesLineDisc do begin
            if ("Item Type" = "Item Type"::Item) then begin
                Validate("Unit of Measure Code", '');
                Validate("Variant Code", '');
            end;
        end;
    end;

    local procedure ValidatePriceItemCode(ItemType: Integer; ItemCode: Code[20]; SalesType: Integer; SalesCode: Code[20]; var AllowInvoiceDisc: Boolean)
    var
        SalesPrice: Record "Sales Price";
        CustPriceGr: Record "Customer Price Group";
    begin
        // P8007749 - renamed from ValidatePriceItemCode1, renamed parameter ItemCode1 to ItemCode, removed ItemCode2
        with SalesPrice do begin
            "Item Type" := ItemType;
            if ("Item Type" = "Item Type"::"All Items") and (ItemCode <> '') then
                Error(Text000, FieldCaption("Item Code"),
                  "Item Type", FieldCaption("Item Type"));

            if ("Item Type" = "Item Type"::Item) and (ItemCode <> '') then begin
                GetItem(ItemCode);
                "Sales Type" := SalesType;
                // P8000068A Begin
                if "Sales Type" = "Sales Type"::"Customer Price Group" then begin
                    if not (CustPriceGr.Get(SalesCode) and
                            (CustPriceGr."Allow Invoice Disc." = AllowInvoiceDisc))
                    then
                        AllowInvoiceDisc := Item."Allow Invoice Disc.";
                end else
                    AllowInvoiceDisc := Item."Allow Invoice Disc.";
                // P8000068A End
            end;
        end;
    end;

    local procedure ValidatePricePricingMethod(ItemType: Integer; PricingMethod: Integer; OldPricingMethod: Integer; var CostAdjustment: Decimal; var ZeroFields: Boolean)
    var
        SalesPrice: Record "Sales Price";
    begin
        // ValidatePricingMethod
        with SalesPrice do begin
            "Item Type" := ItemType;
            "Pricing Method" := PricingMethod;
            if ("Pricing Method" = "Pricing Method"::"Fixed Amount") and
               ("Item Type" <> "Item Type"::Item)
            then
                Error(Text002,
                      "Pricing Method", FieldCaption("Pricing Method"),
                      "Item Type", FieldCaption("Item Type"));

            if ("Pricing Method" = "Pricing Method"::"% Markup") and
               (OldPricingMethod = "Pricing Method"::"% Margin")
            then
                CostAdjustment := CostAdjustment / (1 - CostAdjustment / 100)
            else
                if ("Pricing Method" = "Pricing Method"::"% Margin") and
                   (OldPricingMethod = "Pricing Method"::"% Markup") and
                   (CostAdjustment <> -100)
                then
                    CostAdjustment := CostAdjustment / (1 + CostAdjustment / 100)
                else
                    ZeroFields := true;
        end;
    end;

    local procedure ValidatePriceUnitPrice(PricingMethod: Integer; UnitPrice: Decimal; UnitPriceFieldName: Text[50])
    var
        SalesPrice: Record "Sales Price";
    begin
        // ValidatePriceUnitPrice
        with SalesPrice do begin
            "Pricing Method" := PricingMethod;
            if ("Pricing Method" <> "Pricing Method"::"Fixed Amount") and (UnitPrice <> 0) then
                Error(Text000, UnitPriceFieldName, "Pricing Method", FieldCaption("Pricing Method"));
        end;
    end;

    local procedure ValidatePriceCostAdjustment(PricingMethod: Integer; CostAdjustment: Decimal; CostAdjustmentFieldName: Text[50])
    var
        SalesPrice: Record "Sales Price";
    begin
        // ValidatePriceCostAdjustment
        with SalesPrice do begin
            "Pricing Method" := PricingMethod;
            case "Pricing Method" of
                "Pricing Method"::"Fixed Amount":
                    if (CostAdjustment <> 0) then
                        Error(Text000, CostAdjustmentFieldName, "Pricing Method", FieldCaption("Pricing Method"));

                "Pricing Method"::"% Markup":
                    if (CostAdjustment < -100) then
                        Error(Text003, CostAdjustmentFieldName, "Pricing Method", FieldCaption("Pricing Method"));

                "Pricing Method"::"% Margin":
                    if (CostAdjustment >= 100) then
                        Error(Text004, CostAdjustmentFieldName, "Pricing Method", FieldCaption("Pricing Method"));
            end;
        end;
    end;

    procedure AssignTemplateID(var PriceTemplate: Record "Recurring Price Template")
    var
        LastPriceTemplate: Record "Recurring Price Template";
    begin
        // AssignTemplateID
        with LastPriceTemplate do begin
            SetCurrentKey("Template ID");
            if not Find('+') then
                "Template ID" := 0;
            PriceTemplate."Template ID" := "Template ID" + 1;
        end;
    end;

    procedure AssignPriceID(var SalesPrice: Record "Sales Price")
    var
        LastSalesPrice: Record "Sales Price";
    begin
        // AssignPriceID
        with LastSalesPrice do begin
            SetCurrentKey("Price ID");
            if not Find('+') then
                "Price ID" := 0;
            SalesPrice."Price ID" := "Price ID" + 1;
        end;
    end;

    procedure DeletePriceID(PriceID: Integer)
    var
        SalesInvLine: Record "Sales Invoice Line";
        SalesLine: Record "Sales Line";
    begin
        // DeletePriceID
        if PriceID = 0 then // PR3.61.01
            exit;             // PR3.61.01

        with SalesInvLine do begin
            SetCurrentKey("Price ID");
            SetRange("Price ID", PriceID);
            while Find('-') do begin
                "Price ID" := 0;
                Modify;
            end;
        end;

        with SalesLine do begin
            SetCurrentKey("Price ID");
            SetRange("Price ID", PriceID);
            while Find('-') do begin
                "Price ID" := 0;
                Modify;
            end;
        end;
    end;

    procedure GetPriceItemFilters(var SalesPrice: Record "Sales Price"; var ItemTypeFilter: Option Item,"Item Category",,,"All Items","None"; var ItemCodeFilter: Text[250])
    begin
        // P8007749 - remove ProductGroup from ItemTypeFilter, remove ItemCode2Filter, rename ItemCode1Filter to ItemCodeFilter
        with SalesPrice do begin
            if (GetFilter("Item Type") <> '') then
                // P8001244
                case GetFilter("Item Type") of
                    Format("Item Type"::Item):
                        ItemTypeFilter := 0;
                    Format("Item Type"::"Item Category"):
                        ItemTypeFilter := 1;
                    Format("Item Type"::"All Items"):
                        ItemTypeFilter := 4;
                end
            // P8001244
            else
                ItemTypeFilter := ItemTypeFilter::None;

            ItemCodeFilter := GetFilter("Item Code");
        end;
    end;

    procedure SetPriceItemFilters(var SalesPrice: Record "Sales Price"; ItemTypeFilter: Option Item,"Item Category",,,"All Items","None"; var ItemCodeFilter: Text[250])
    begin
        // P8007749 - remove ProductGroup from ItemTypeFilter, remove ItemCode2Filter, rename ItemCode1Filter to ItemCodeFilter
        with SalesPrice do begin
            SetRange("Item No.");

            if (ItemTypeFilter <> ItemTypeFilter::None) then
                SetRange("Item Type", ItemTypeFilter)
            else
                SetRange("Item Type");

            if (ItemTypeFilter in [ItemTypeFilter::"All Items", ItemTypeFilter::None]) then
                ItemCodeFilter := '';
            if (ItemCodeFilter <> '') then
                SetFilter("Item Code", ItemCodeFilter)
            else
                SetRange("Item Code");
        end;
    end;

    procedure GetTemplateItemFilters(var SalesPriceTemplate: Record "Recurring Price Template"; var ItemTypeFilter: Option Item,"Item Category",,,"All Items","None"; var ItemCodeFilter: Text[250])
    begin
        // P8007749 - remove ProductGroup from ItemTypeFilter, remove ItemCode2Filter, rename ItemCode1Filter to ItemCodeFilter
        with SalesPriceTemplate do begin
            if (GetFilter("Item Type") <> '') then
                ItemTypeFilter := "Item Type"
            else
                ItemTypeFilter := ItemTypeFilter::None;

            ItemCodeFilter := GetFilter("Item Code");
        end;
    end;

    procedure SetTemplateItemFilters(var SalesPriceTemplate: Record "Recurring Price Template"; ItemTypeFilter: Option Item,"Item Category",,,"All Items","None"; var ItemCodeFilter: Text[250])
    begin
        // P8007749 - remove ProductGroup from ItemTypeFilter, remove ItemCode2Filter, rename ItemCode1Filter to ItemCodeFilter
        with SalesPriceTemplate do begin
            SetRange("Item No.");

            if (ItemTypeFilter <> ItemTypeFilter::None) then
                SetRange("Item Type", ItemTypeFilter)
            else
                SetRange("Item Type");

            if (ItemTypeFilter in [ItemTypeFilter::"All Items", ItemTypeFilter::None]) then
                ItemCodeFilter := '';
            if (ItemCodeFilter <> '') then
                SetFilter("Item Code", ItemCodeFilter)
            else
                SetRange("Item Code");
        end;
    end;

    procedure GetLineDiscItemFilters(var SalesLineDisc: Record "Sales Line Discount"; var ItemTypeFilter: Option Item,"Item Category",,"Item Disc. Group","All Items","None"; var ItemCodeFilter: Text[250])
    begin
        // P8007749 - remove ProductGroup from ItemTypeFilter, remove ItemCode2Filter, rename ItemCode1Filter to ItemCodeFilter
        with SalesLineDisc do begin
            if (GetFilter("Item Type") <> '') then
                // P8001244
                case GetFilter("Item Type") of
                    Format("Item Type"::Item):
                        ItemTypeFilter := 0;
                    Format("Item Type"::"Item Category"):
                        ItemTypeFilter := 1;
                    Format("Item Type"::"Item Disc. Group"):
                        ItemTypeFilter := 3;
                    Format("Item Type"::"All Items"):
                        ItemTypeFilter := 4;
                end
            // P8001244
            else
                ItemTypeFilter := ItemTypeFilter::None;

            ItemCodeFilter := GetFilter("Item Code");
        end;
    end;

    procedure SetLineDiscItemFilters(var SalesLineDisc: Record "Sales Line Discount"; ItemTypeFilter: Option Item,"Item Category",,"Item Disc. Group","All Items","None"; var ItemCodeFilter: Text[250])
    begin
        // P8007749 - remove ProductGroup from ItemTypeFilter, remove ItemCode2Filter, rename ItemCode1Filter to ItemCodeFilter
        with SalesLineDisc do begin
            SetRange(Type);
            SetRange(Code);

            if (ItemTypeFilter <> ItemTypeFilter::None) then
                SetRange("Item Type", ItemTypeFilter)
            else
                SetRange("Item Type");

            if (ItemTypeFilter in [ItemTypeFilter::"All Items", ItemTypeFilter::None]) then
                ItemCodeFilter := '';
            if (ItemCodeFilter <> '') then
                SetFilter("Item Code", ItemCodeFilter)
            else
                SetRange("Item Code");
        end;
    end;

    procedure GetCaption(ItemTypeFilter: Option Item,"Item Category","Item Disc. Group","All Items","None"; ItemCodeFilter: Text[250]; var SourceTableName: Text[100]; var ItemNoFilter: Text[250]; var Description: Text[250])
    var
        ObjTransl: Record "Object Translation";
        Item2: Record Item;
        ItemCategory: Record "Item Category";
        ItemDiscGroup: Record "Item Discount Group";
    begin
        // P8007749 - remove ProductGroup from ItemTypeFilter, remove ItemCode2Filter, rename ItemCode1Filter to ItemCodeFilter
        SourceTableName := '';
        ItemNoFilter := '';
        case ItemTypeFilter of
            ItemTypeFilter::Item:
                begin
                    SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 27);
                    ItemNoFilter := ItemCodeFilter;
                    Item2."No." := ItemCodeFilter;
                    if Item2.Find then
                        Description := Item2.Description;
                end;
            ItemTypeFilter::"Item Category":
                begin
                    SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 5722);
                    ItemNoFilter := ItemCodeFilter;
                    ItemCategory.Code := ItemCodeFilter;
                    if ItemCategory.Find then
                        Description := ItemCategory.Description;
                end;
            ItemTypeFilter::"Item Disc. Group":
                begin
                    SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 341);
                    ItemNoFilter := ItemCodeFilter;
                    ItemDiscGroup.Code := ItemCodeFilter;
                    if ItemDiscGroup.Find then
                        Description := ItemDiscGroup.Description;
                end;
            ItemTypeFilter::"All Items":
                begin
                    SourceTableName := Text005;
                    Description := '';
                end;
        end;
    end;

    procedure LookupItemCodeFilter(ItemTypeFilter: Option Item,"Item Category",,"Item Disc. Group","All Items","None"; var Text: Text[250]): Boolean
    var
        Item2: Record Item;
        ItemList: Page "Item List";
        ItemCategory: Record "Item Category";
        ItemCategoryList: Page "Item Categories";
        ItemDiscGroup: Record "Item Discount Group";
        ItemDiscGroupList: Page "Item Disc. Groups";
    begin
        // P8007749 - renamed from LookupItemCode1Filter, remove ProductGroup from ItemTypeFilter

        case ItemTypeFilter of
            ItemTypeFilter::Item:
                begin
                    ItemList.LookupMode := true;
                    if (ItemList.RunModal <> ACTION::LookupOK) then
                        exit(false);
                    ItemList.GetRecord(Item2);
                    Text := Item2."No.";
                end;
            ItemTypeFilter::"Item Category":
                begin
                    ItemCategoryList.LookupMode := true;
                    if (ItemCategoryList.RunModal <> ACTION::LookupOK) then
                        exit(false);
                    ItemCategoryList.GetRecord(ItemCategory);
                    Text := ItemCategory.Code;
                end;
            ItemTypeFilter::"Item Disc. Group":
                begin
                    ItemDiscGroupList.LookupMode := true;
                    if (ItemDiscGroupList.RunModal <> ACTION::LookupOK) then
                        exit(false);
                    ItemDiscGroupList.GetRecord(ItemDiscGroup);
                    Text := ItemDiscGroup.Code;
                end;
        end;
        exit(true);
    end;

    procedure CalculateSalesPrices(var SalesPrice: Record "Sales Price")
    begin
        // CalculateSalesPrices
        CalculateCostBasedPrice(SalesPrice);
        with SalesPrice do
            if ("Unit of Measure Code" in ['', SourceUnitOfMeasure.Code]) and
               ("Currency Code" in ['', SourceSalesPrice."Currency Code"])
            then begin
                if "Use Break Charge" then
                    "Break Charge" := ConvertBreakCharge(SalesPrice, "Unit Price"); // P8000539A
                "Sales Unit Price" :=
                  ConvertSalesUnitPrice(SalesPrice, "Unit Price" + "Break Charge");
                "Sales Currency Code" := SourceSalesPrice."Currency Code"; // P8000539A
            end;
    end;

    procedure CalculatePriceTemplate(ItemNo: Code[20]; var UnitPrice: Decimal)
    var
        SalesPrice: Record "Sales Price";
    begin
        // CalculatePriceTemplate
        SetTemplateItemSource(ItemNo);
        CalculateCostBasedPrice(PriceTemplatePrice);
        with PriceTemplatePrice do begin
            if "Use Break Charge" then
                "Break Charge" := ConvertBreakCharge(SalesPrice, "Unit Price"); // P8000539A
            UnitPrice := "Unit Price" + "Break Charge";
            if ("Price Rounding Method" <> '') then                   // P8000539A
                RoundWithMethodCode("Price Rounding Method", UnitPrice) // P8000539A
            else                                                      // P8000539A
                RoundItemUnitPrice(Item, UnitPrice);
            RoundCurrencyUnitPrice("Currency Code", UnitPrice);
        end;
    end;

    local procedure SetTemplateItemSource(ItemNo: Code[20])
    begin
        // SetTemplateItemSource
        with SourceSalesPrice do begin
            "Item No." := ItemNo;

            GetItem("Item No.");
            GetSourceUOM("Item No.", "Unit of Measure Code");
        end;
    end;

    procedure CalculateSalesLineDiscs(var SalesLineDisc: Record "Sales Line Discount")
    var
        LineAmount: Decimal;
    begin
        // CalculateSalesLineDiscs
        with SalesLineDisc do begin
            LineAmount := SourceLineAmount;
            if ("Currency Code" <> SourceSalesLineDisc."Currency Code") then begin
                ConvertToLocalCurrency(SourceSalesLineDisc."Currency Code", LineAmount);
                ConvertFromLocalCurrency("Currency Code", LineAmount);
            end;
            if (LineAmount <> 0) then
                case "Line Discount Type" of
                    "Line Discount Type"::Percent:
                        "Line Discount Amount" := LineAmount * ("Line Discount %" / 100);
                    "Line Discount Type"::Amount:
                        "Line Discount %" := ("Line Discount Amount" / LineAmount) * 100;
                        // P8000345A
                    "Line Discount Type"::"Unit Amount":
                        begin
                            "Line Discount %" := ("Line Discount Amount" * SourceLineQty / LineAmount) * 100;
                            if "Unit of Measure Code" = '' then
                                "Line Discount %" := "Line Discount %" * SourceUnitOfMeasure."Qty. per Unit of Measure";
                        end;
                        // P8000345A
                end;
            if ("Unit of Measure Code" in ['', SourceUnitOfMeasure.Code]) and
               ("Currency Code" in ['', SourceSalesLineDisc."Currency Code"]) // P8000539A
            then
                "Sales Line Discount %" := "Line Discount %";
        end;
    end;

    procedure CalculateCostBasedPrice(var SalesPrice: Record "Sales Price")
    var
        CostBasedPrice: Record "Sales Price";
        ItemMarketPrice: Record "Item Cost Basis";
    begin
        // CalculateCostBasedPrice
        with SalesPrice do begin
            if ("Pricing Method" <> "Pricing Method"::"Fixed Amount") then begin
                case "Cost Reference" of
                    "Cost Reference"::Average:
                        "Unit Price" := Item."Unit Cost";
                    "Cost Reference"::Standard:
                        "Unit Price" := Item."Standard Cost";
                    "Cost Reference"::Last:
                        "Unit Price" := Item."Last Direct Cost";
                    "Cost Reference"::"Cost Calc. Method":
                        "Unit Price" :=
                          // ItemMarketPrice.GetMarketPriceAsOf(Item."No.", SourceSalesPrice."Variant Code", // P8000245B
                          //   SourceSalesPrice."Starting Date");                                            // P8000245B
                          CalculateCostCalcMethod(CostBasedPrice, SalesPrice); // P8000539A
                end;
                "Unit Price" := Item.ConvertUnitCostToPricing("Unit Price"); // P8000981
                if ("Unit Price" <> 0) then begin // P8000539A
                    "Unit Price" := ConvertUnitPrice(CostBasedPrice, SalesPrice, "Unit Price");
                    case "Pricing Method" of
                        "Pricing Method"::"Amount Markup":
                            "Unit Price" := "Unit Price" + "Cost Adjustment";
                        "Pricing Method"::"% Markup":
                            "Unit Price" := "Unit Price" * (1 + "Cost Adjustment" / 100);
                        "Pricing Method"::"% Margin":
                            "Unit Price" := "Unit Price" / (1 - "Cost Adjustment" / 100);
                    end;
                end; // P8000539A
            end;
        end;
    end;

    local procedure CalculateCostCalcMethod(var CostBasedPrice: Record "Sales Price"; var SalesPrice: Record "Sales Price"): Decimal
    var
        CostCalcMethod: Record "Cost Calculation Method";
        CostBasis: Record "Cost Basis";
        StartDate: Date;
        EndDate: Date;
    begin
        // P8000539A
        with CostCalcMethod do
            if Get(SalesPrice."Cost Calc. Method Code") then
                if CostBasis.Get("Cost Basis Code") then begin
                    CostBasedPrice."Currency Code" := CostBasis."Currency Code";
                    GetReferenceDates(SourceSalesPrice."Starting Date", StartDate, EndDate);
                    if (EndDate >= StartDate) then
                        exit(CalculateCostValue(
                               "Cost Basis Code", Item."No.", SourceSalesPrice."Variant Code", StartDate, EndDate));
                end;
        exit(0);
    end;

    procedure ConvertSalesUnitPrice(var FromSalesPrice: Record "Sales Price"; FromAmount: Decimal) ToAmount: Decimal
    var
        ToSalesPrice: Record "Sales Price";
    begin
        // ConvertSalesUnitPrice
        ToSalesPrice := SourceSalesPrice;
        //IF Item.CostInAlternateUnits() THEN BEGIN      // PR3.61.02, P8000981
        if Item.PriceInAlternateUnits() then begin       // PR3.61.02, P8000981
                                                         //  ToSalesPrice."Unit of Measure Code" := ''; // PR3.61.02
            ToAmount := FromAmount;                      // PR3.61.02
            exit;                                        // PR3.61.02
        end;                                           // PR3.61.02
        ToAmount := ConvertUnitPrice(FromSalesPrice, ToSalesPrice, FromAmount);
    end;

    local procedure ConvertBreakCharge(var ToSalesPrice: Record "Sales Price"; UnitPrice: Decimal) BreakAmount: Decimal
    var
        FromSalesPrice: Record "Sales Price";
    begin
        // ConvertBreakCharge
        // IF (SourceUnitOfMeasure.Code <> '') THEN BEGIN                   // P8000539A
        if (SourceUnitOfMeasure.Code <> '') and (UnitPrice <> 0) then begin // P8000539A
            FromSalesPrice := SourceSalesPrice;
            FromSalesPrice."Currency Code" := '';
            // P8000539A
            case SourceUnitOfMeasure."Break Charge Method" of
                SourceUnitOfMeasure."Break Charge Method"::"Amount Markup":
                    BreakAmount := ConvertUnitPrice(FromSalesPrice, ToSalesPrice, SourceUnitOfMeasure."Break Charge Adjustment");
                SourceUnitOfMeasure."Break Charge Method"::"% Markup":
                    BreakAmount := UnitPrice * (SourceUnitOfMeasure."Break Charge Adjustment" / 100);
                SourceUnitOfMeasure."Break Charge Method"::"% Margin":
                    BreakAmount :=
                      UnitPrice * (SourceUnitOfMeasure."Break Charge Adjustment" /
                                   (100 - SourceUnitOfMeasure."Break Charge Adjustment"));
            end;
            // P8000539A
        end;
    end;

    local procedure ConvertUnitPrice(var FromSalesPrice: Record "Sales Price"; var ToSalesPrice: Record "Sales Price"; FromAmount: Decimal) ToAmount: Decimal
    begin
        // ConvertUnitPrice
        ToAmount := FromAmount;
        with FromSalesPrice do begin
            // P8000981
            //IF ("Unit of Measure Code" <> ToSalesPrice."Unit of Measure Code") AND (NOT Item.CostInAlternateUnits) THEN BEGIN // P8000716
            if ("Unit of Measure Code" <> ToSalesPrice."Unit of Measure Code") and
               (not Item.PriceInAlternateUnits)
            then begin
                // P8000981
                ConvertToPerCostingUnit("Unit of Measure Code", ToAmount);
                ConvertFromPerCostingUnit(ToSalesPrice."Unit of Measure Code", ToAmount);
            end;

            if ("Currency Code" <> ToSalesPrice."Currency Code") then begin
                ConvertToLocalCurrency("Currency Code", ToAmount);
                ConvertFromLocalCurrency(ToSalesPrice."Currency Code", ToAmount);
            end;
        end;
    end;

    local procedure ConvertToPerCostingUnit(FromUOM: Code[10]; var AmountPerUOM: Decimal)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        // ConvertToPerCostingUnit
        if (FromUOM <> '') then begin
            if (FromUOM = SourceUnitOfMeasure.Code) then
                ItemUnitOfMeasure := SourceUnitOfMeasure
            else
                ItemUnitOfMeasure.Get(Item."No.", FromUOM);
            AmountPerUOM :=
              //AmountPerUOM / (Item.CostingQtyPerBase() * ItemUnitOfMeasure."Qty. per Unit of Measure"); // P8000981
              AmountPerUOM / (Item.PricingQtyPerBase() * ItemUnitOfMeasure."Qty. per Unit of Measure");   // P8000981
        end;
    end;

    local procedure ConvertFromPerCostingUnit(ToUOM: Code[10]; var AmountPerUOM: Decimal)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        // ConvertFromPerCostingUnit
        if (ToUOM <> '') then begin
            if (ToUOM = SourceUnitOfMeasure.Code) then
                ItemUnitOfMeasure := SourceUnitOfMeasure
            else
                ItemUnitOfMeasure.Get(Item."No.", ToUOM);
            AmountPerUOM :=
              //AmountPerUOM * (Item.CostingQtyPerBase() * ItemUnitOfMeasure."Qty. per Unit of Measure"); // P8000981
              AmountPerUOM * (Item.PricingQtyPerBase() * ItemUnitOfMeasure."Qty. per Unit of Measure");   // P8000981
        end;
    end;

    local procedure ConvertToLocalCurrency(FromCurrency: Code[10]; var CurrencyAmount: Decimal)
    var
        CurrencyFactor: Decimal;
    begin
        // ConvertToLocalCurrency
        if (FromCurrency <> '') and (SourceExchRateDate <> 0D) then begin // P8000360A
            if (FromCurrency = SourceSalesPrice."Currency Code") then
                CurrencyFactor := SourceCurrencyFactor
            else
                CurrencyFactor := CurrencyExchRate.ExchangeRate(SourceExchRateDate, FromCurrency);
            CurrencyAmount :=
              CurrencyExchRate.ExchangeAmtFCYToLCY(
                SourceExchRateDate, FromCurrency, CurrencyAmount, CurrencyFactor);
        end;
    end;

    local procedure ConvertFromLocalCurrency(ToCurrency: Code[10]; var CurrencyAmount: Decimal)
    var
        CurrencyFactor: Decimal;
    begin
        // ConvertFromLocalCurrency
        if (ToCurrency <> '') and (SourceExchRateDate <> 0D) then begin // P8000360A
            if (ToCurrency = SourceSalesPrice."Currency Code") then
                CurrencyFactor := SourceCurrencyFactor
            else
                CurrencyFactor := CurrencyExchRate.ExchangeRate(SourceExchRateDate, ToCurrency);
            CurrencyAmount :=
              CurrencyExchRate.ExchangeAmtLCYToFCY(
                SourceExchRateDate, ToCurrency, CurrencyAmount, CurrencyFactor);
        end;
    end;

    local procedure GetOrderedQuantity(PriceID: Integer) OrderedQuantity: Decimal
    var
        SalesInvLine: Record "Sales Invoice Line";
        SalesLine: Record "Sales Line";
    begin
        // GetOrderedQuantity
        with SalesInvLine do begin
            SetCurrentKey("Price ID", "Bill-to Customer No.");
            SetRange("Price ID", PriceID);
            SetRange("Bill-to Customer No.", SourceCustomerNo);
            //IF Item.CostInAlternateUnits() THEN BEGIN // P8000981
            if Item.PriceInAlternateUnits() then begin  // P8000981
                CalcSums("Quantity (Alt.)");
                OrderedQuantity := "Quantity (Alt.)";
            end else begin
                CalcSums("Quantity (Base)");
                OrderedQuantity := "Quantity (Base)";
            end;
        end;

        with SalesLine do begin
            SetCurrentKey("Price ID", "Document Type", "Bill-to Customer No.");
            SetRange("Price ID", PriceID);
            SetRange("Document Type", "Document Type"::Order);
            SetRange("Bill-to Customer No.", SourceCustomerNo);
            //IF Item.CostInAlternateUnits() THEN BEGIN // P8000981
            if Item.PriceInAlternateUnits() then begin  // P8000981
                CalcSums("Quantity (Alt.)", "Qty. Invoiced (Alt.)");
                OrderedQuantity := OrderedQuantity + ("Quantity (Alt.)" - "Qty. Invoiced (Alt.)");
            end else begin
                CalcSums("Quantity (Base)", "Qty. Invoiced (Base)");
                OrderedQuantity := OrderedQuantity + ("Quantity (Base)" - "Qty. Invoiced (Base)");
            end;
        end;
    end;

    procedure IsInMaxQty(SalesPrice: Record "Sales Price"; QtyPerUOM: Decimal; Qty: Decimal): Boolean
    begin
        // IsInMaxQty
        with SalesPrice do begin
            if ("Maximum Quantity" = 0) then
                exit(true);
            if ("Unit of Measure Code" <> '') then
                //"Maximum Quantity" := "Maximum Quantity" * (Item.CostingQtyPerBase() * QtyPerUOM); // P8000981
                "Maximum Quantity" := "Maximum Quantity" * (Item.PricingQtyPerBase() * QtyPerUOM);   // P8000981
                                                                                                     //Qty := Qty * (Item.CostingQtyPerBase() * QtyPerUOM); // P8000981
            Qty := Qty * (Item.PricingQtyPerBase() * QtyPerUOM);   // P8000981
            if ("Price ID" = SourcePriceIDToIgnore) then
                Qty := Qty - SourceQtyToIgnore;
            exit((GetOrderedQuantity("Price ID") + Qty) <= "Maximum Quantity");
        end;
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        // GetItem
        if (Item."No." <> ItemNo) then
            if not Item.Get(ItemNo) then // PR3.70
                Clear(Item);               // PR3.70
    end;

    procedure SetSalesLine(var SalesLine: Record "Sales Line")
    var
        OldSalesLine: Record "Sales Line";
    begin
        // SetSalesLine
        SourceQtyToIgnore := 0;
        SourcePriceIDToIgnore := 0;
        SourceLineQty := SalesLine.GetPricingQty;                   // P8000345A
        SourceLineAmount := SourceLineQty * SalesLine."Unit Price"; // P8000345A
        OldSalesLine := SalesLine;
        with OldSalesLine do
            if Find then begin
                SourcePriceIDToIgnore := "Price ID";
                if (SourcePriceIDToIgnore <> 0) then
                    if PriceInAlternateUnits() then
                        SourceQtyToIgnore := "Quantity (Alt.)" - "Qty. Invoiced (Alt.)"
                    else
                        SourceQtyToIgnore := "Quantity (Base)" - "Qty. Invoiced (Base)";
            end;
    end;

    procedure SetPriceSource(var NewSourceSalesPrice: Record "Sales Price"; NewSourceCustomerNo: Code[20]; NewSourceCurrencyFactor: Decimal; NewSourceExchRateDate: Date)
    begin
        // SetPriceSource
        SourceSalesPrice := NewSourceSalesPrice;
        with SourceSalesPrice do begin
            GetItem("Item No.");
            GetSourceUOM("Item No.", "Unit of Measure Code");

            SourceCustomerNo := NewSourceCustomerNo;
            SourceCurrencyFactor := NewSourceCurrencyFactor;
            SourceExchRateDate := NewSourceExchRateDate;
        end;
    end;

    procedure SetPriceTemplateSource(var NewPriceTemplate: Record "Recurring Price Template")
    begin
        // SetPriceTemplateSource
        with SourceSalesPrice do begin
            "Unit of Measure Code" := NewPriceTemplate."Unit of Measure Code";
            "Variant Code" := NewPriceTemplate."Variant Code";
            "Starting Date" := NewPriceTemplate."Next Date";

            if (NewPriceTemplate."Currency Code" <> '') and
               (NewPriceTemplate."Currency Code" <> "Currency Code")
            then begin
                SourceCurrencyFactor :=
                  CurrencyExchRate.ExchangeRate(WorkDate, NewPriceTemplate."Currency Code");
                SourceExchRateDate := WorkDate;
            end;
            "Currency Code" := NewPriceTemplate."Currency Code";
        end;
        PriceTemplatePrice.TransferFields(NewPriceTemplate);
    end;

    procedure SetLineDiscSource(var NewSourceSalesLineDisc: Record "Sales Line Discount"; NewSourceItemNo: Code[20]; NewSourceCustomerNo: Code[20]; NewSourceCurrencyFactor: Decimal; NewSourceExchRateDate: Date)
    begin
        // SetLineDiscSource
        SourceSalesLineDisc := NewSourceSalesLineDisc;
        with SourceSalesLineDisc do begin
            GetItem(NewSourceItemNo);
            GetSourceUOM(NewSourceItemNo, "Unit of Measure Code");

            SourceCustomerNo := NewSourceCustomerNo;
            SourceCurrencyFactor := NewSourceCurrencyFactor;
            SourceExchRateDate := NewSourceExchRateDate;
        end;
    end;

    local procedure GetSourceUOM(ItemNo: Code[20]; UOMCode: Code[10])
    begin
        // GetSourceUOM
        if (SourceUnitOfMeasure."Item No." <> ItemNo) or
           (SourceUnitOfMeasure.Code <> UOMCode)
        then begin
            SourceUnitOfMeasure.Init;
            SourceUnitOfMeasure."Item No." := ItemNo;
            SourceUnitOfMeasure.Code := UOMCode;
            if not SourceUnitOfMeasure.Find then
                SourceUnitOfMeasure."Qty. per Unit of Measure" := 1;
        end;
    end;

    procedure RoundCurrencyUnitPrice(CurrencyCode: Code[10]; var UnitPrice: Decimal)
    begin
        // RoundCurrencyUnitPrice
        GetRoundingCurrency(CurrencyCode);
        UnitPrice := Round(UnitPrice, RoundingCurrency."Unit-Amount Rounding Precision");
    end;

    local procedure GetRoundingCurrency(CurrencyCode: Code[10])
    begin
        // GetRoundingCurrency
        if not RoundingCurrencyIsSetup then begin
            RoundingCurrency.InitRoundingPrecision;
            RoundingCurrencyIsSetup := true;
        end;

        if (CurrencyCode <> RoundingCurrency.Code) then
            if not RoundingCurrency.Get(CurrencyCode) then begin
                RoundingCurrency.Code := '';
                RoundingCurrency.InitRoundingPrecision;
            end;
    end;

    procedure RoundItemUnitPrice(var Item2: Record Item; var UnitPrice: Decimal)
    var
        MethodCode: Code[10];
    begin
        // P8007749
        // IF GetItemProductGroup(Item2) THEN
        //  MethodCode := RoundingProductGroup."Price Rounding Method";
        MethodCode := GetPriceRoundingMethod(Item2);
        // P8007749
        if (MethodCode = '') then begin
            GetInventorySetup;
            MethodCode := InventorySetup."Def. Price Rounding Method";
        end;
        if (MethodCode <> '') then
            RoundWithMethodCode(MethodCode, UnitPrice);
    end;

    local procedure GetPriceRoundingMethod(var Item2: Record Item): Code[10]
    var
        ItemCategory: Record "Item Category";
    begin
        // P8007749
        with Item2 do begin
            if "Item Category Code" <> '' then
                if ItemCategory.Get("Item Category Code") then
                    exit(ItemCategory.GetPriceRoundingMethod);
        end;
    end;

    local procedure GetInventorySetup()
    begin
        // GetInventorySetup
        if not InventorySetupRead then begin
            InventorySetup.Get;
            InventorySetupRead := true;
        end;
    end;

    procedure RoundWithMethodCode(RoundingMethodCode: Code[10]; var UnitPrice: Decimal)
    var
        RoundingMethod: Record "Rounding Method";
    begin
        // RoundWithMethodCode
        if (UnitPrice <> 0) then begin
            RoundingMethod.SetRange(Code, RoundingMethodCode);
            RoundingMethod.Code := RoundingMethodCode;
            RoundingMethod."Minimum Amount" := UnitPrice;
            if RoundingMethod.Find('=<') then begin
                UnitPrice := UnitPrice + RoundingMethod."Amount Added Before";
                if RoundingMethod.Precision > 0 then
                    UnitPrice := Round(UnitPrice, RoundingMethod.Precision, CopyStr('=><', RoundingMethod.Type + 1, 1));
                UnitPrice := UnitPrice + RoundingMethod."Amount Added After";
            end;
        end;
    end;

    procedure SetBestPriceFilters(var SalesPrice: Record "Sales Price")
    begin
        // SetBestPriceFilters
        NumBestFieldFilters := 0;
        with SourceSalesPrice do
            if SalesPrice.Find('-') then begin
                SetPriceContractFieldFilter(SalesPrice);

                GetInventorySetup;
                case InventorySetup."Price Selection Priority" of

                    InventorySetup."Price Selection Priority"::"Currency Only":
                        SetPriceFieldFilter(
                          SalesPrice, "Currency Code", FieldNo("Currency Code"));

                    InventorySetup."Price Selection Priority"::"UOM Only":
                        SetPriceFieldFilter(
                          SalesPrice, "Unit of Measure Code", FieldNo("Unit of Measure Code"));

                    InventorySetup."Price Selection Priority"::"Currency/UOM":
                        begin
                            SetPriceFieldFilter(
                              SalesPrice, "Currency Code", FieldNo("Currency Code"));
                            SetPriceFieldFilter(
                              SalesPrice, "Unit of Measure Code", FieldNo("Unit of Measure Code"));
                        end;

                    InventorySetup."Price Selection Priority"::"UOM/Currency/Variant":
                        begin
                            SetPriceFieldFilter(
                              SalesPrice, "Unit of Measure Code", FieldNo("Unit of Measure Code"));
                            SetPriceFieldFilter(
                              SalesPrice, "Currency Code", FieldNo("Currency Code"));
                            SetPriceFieldFilter(
                              SalesPrice, "Variant Code", FieldNo("Variant Code"));
                        end;

                    InventorySetup."Price Selection Priority"::"Variant/UOM/Currency":
                        begin
                            SetPriceFieldFilter(
                              SalesPrice, "Variant Code", FieldNo("Variant Code"));
                            SetPriceFieldFilter(
                              SalesPrice, "Unit of Measure Code", FieldNo("Unit of Measure Code"));
                            SetPriceFieldFilter(
                              SalesPrice, "Currency Code", FieldNo("Currency Code"));
                        end;

                end;
            end;
    end;

    local procedure SetPriceFieldFilter(var SalesPrice: Record "Sales Price"; SourceFldCode: Code[10]; FldNo: Integer)
    begin
        // SetPriceFieldFilter
        with SalesPrice do
            if (SourceFldCode <> '') then
                case FldNo of
                    FieldNo("Currency Code"):
                        begin
                            SetRange("Currency Code", SourceFldCode);
                            if Find('-') then
                                AddBestFilter(FldNo)
                            else
                                SetRange("Currency Code");
                        end;
                    FieldNo("Unit of Measure Code"):
                        begin
                            SetRange("Unit of Measure Code", SourceFldCode);
                            if Find('-') then
                                AddBestFilter(FldNo)
                            else
                                SetRange("Unit of Measure Code");
                        end;
                    FieldNo("Variant Code"):
                        begin
                            SetRange("Variant Code", SourceFldCode);
                            if Find('-') then
                                AddBestFilter(FldNo)
                            else
                                SetRange("Variant Code");
                        end;
                end;
    end;

    local procedure SetPriceContractFieldFilter(var SalesPrice: Record "Sales Price")
    begin
        // SetPriceContractFieldFilter
        with SalesPrice do begin
            SetRange("Price Type", "Price Type"::Contract);
            if Find('-') then
                AddBestFilter(FieldNo("Price Type"))
            else
                SetRange("Price Type");
        end;
    end;

    procedure RemoveBestPriceFilter(var SalesPrice: Record "Sales Price"): Boolean
    begin
        // RemoveBestPriceFilter
        if (NumBestFieldFilters = 0) then
            exit(false);
        with SalesPrice do
            case BestFieldFilter[NumBestFieldFilters] of
                FieldNo("Price Type"):
                    SetRange("Price Type");
                FieldNo("Currency Code"):
                    SetRange("Currency Code");
                FieldNo("Unit of Measure Code"):
                    SetRange("Unit of Measure Code");
                FieldNo("Variant Code"):
                    SetRange("Variant Code");
            end;
        NumBestFieldFilters := NumBestFieldFilters - 1;
        exit(true);
    end;

    procedure SetBestLineDiscFilters(var SalesLineDisc: Record "Sales Line Discount")
    begin
        // SetBestLineDiscFilters
        NumBestFieldFilters := 0;
        with SourceSalesLineDisc do
            if SalesLineDisc.Find('-') then begin
                GetInventorySetup;
                case InventorySetup."Price Selection Priority" of

                    InventorySetup."Price Selection Priority"::"Currency Only":
                        SetLineDiscFieldFilter(
                          SalesLineDisc, "Currency Code", FieldNo("Currency Code"));

                    InventorySetup."Price Selection Priority"::"UOM Only":
                        SetLineDiscFieldFilter(
                          SalesLineDisc, "Unit of Measure Code", FieldNo("Unit of Measure Code"));

                    InventorySetup."Price Selection Priority"::"Currency/UOM":
                        begin
                            SetLineDiscFieldFilter(
                              SalesLineDisc, "Currency Code", FieldNo("Currency Code"));
                            SetLineDiscFieldFilter(
                              SalesLineDisc, "Unit of Measure Code", FieldNo("Unit of Measure Code"));
                        end;

                    InventorySetup."Price Selection Priority"::"UOM/Currency/Variant":
                        begin
                            SetLineDiscFieldFilter(
                              SalesLineDisc, "Unit of Measure Code", FieldNo("Unit of Measure Code"));
                            SetLineDiscFieldFilter(
                              SalesLineDisc, "Currency Code", FieldNo("Currency Code"));
                            SetLineDiscFieldFilter(
                              SalesLineDisc, "Variant Code", FieldNo("Variant Code"));
                        end;

                    InventorySetup."Price Selection Priority"::"Variant/UOM/Currency":
                        begin
                            SetLineDiscFieldFilter(
                              SalesLineDisc, "Variant Code", FieldNo("Variant Code"));
                            SetLineDiscFieldFilter(
                              SalesLineDisc, "Unit of Measure Code", FieldNo("Unit of Measure Code"));
                            SetLineDiscFieldFilter(
                              SalesLineDisc, "Currency Code", FieldNo("Currency Code"));
                        end;

                end;
            end;
    end;

    local procedure SetLineDiscFieldFilter(var SalesLineDisc: Record "Sales Line Discount"; SourceFldCode: Code[10]; FldNo: Integer)
    begin
        // SetLineDiscFieldFilter
        with SalesLineDisc do
            if (SourceFldCode <> '') then
                case FldNo of
                    FieldNo("Currency Code"):
                        begin
                            SetRange("Currency Code", SourceFldCode);
                            if Find('-') then
                                AddBestFilter(FldNo)
                            else
                                SetRange("Currency Code");
                        end;
                    FieldNo("Unit of Measure Code"):
                        begin
                            SetRange("Unit of Measure Code", SourceFldCode);
                            if Find('-') then
                                AddBestFilter(FldNo)
                            else
                                SetRange("Unit of Measure Code");
                        end;
                    FieldNo("Variant Code"):
                        begin
                            SetRange("Variant Code", SourceFldCode);
                            if Find('-') then
                                AddBestFilter(FldNo)
                            else
                                SetRange("Variant Code");
                        end;
                end;
    end;

    procedure RemoveBestLineDiscFilter(var SalesLineDisc: Record "Sales Line Discount"): Boolean
    begin
        // RemoveBestLineDiscFilter
        if (NumBestFieldFilters = 0) then
            exit(false);
        with SalesLineDisc do
            case BestFieldFilter[NumBestFieldFilters] of
                FieldNo("Currency Code"):
                    SetRange("Currency Code");
                FieldNo("Unit of Measure Code"):
                    SetRange("Unit of Measure Code");
                FieldNo("Variant Code"):
                    SetRange("Variant Code");
            end;
        NumBestFieldFilters := NumBestFieldFilters - 1;
        exit(true);
    end;

    local procedure AddBestFilter(FldNo: Integer)
    begin
        // AddBestFilter
        NumBestFieldFilters := NumBestFieldFilters + 1;
        BestFieldFilter[NumBestFieldFilters] := FldNo;
    end;

    procedure PriceAtShipment(var SalesHeader: Record "Sales Header"; PostingLocation: Code[10])
    var
        SalesLine: Record "Sales Line";
        SalesHeader2: Record "Sales Header";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        PriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";
        PrepmtLineAmount: Decimal;
    begin
        // PriceAtShipment
        // P8000282A - add parameter for posting location
        with SalesHeader do begin
            if ("Document Type" <> "Document Type"::Order) or (not Ship) then
                exit;

            SalesLine.SetRange("Document Type", "Document Type");
            SalesLine.SetRange("Document No.", "No.");
            SalesLine.SetRange("Invoice at Shipped Price", true);
            if SalesLine.Find('-') then
                repeat
                    SalesLine."Invoice at Shipped Price" := false;
                    SalesLine.Modify;
                until (SalesLine.Next = 0);
            if (not "Price at Shipment") then
                exit;
            SalesLine.SetRange("Invoice at Shipped Price");

            SalesLine.SetRange(Type, SalesLine.Type::Item);
            if PostingLocation <> '' then                          // P8000282A
                SalesLine.SetRange("Location Code", PostingLocation); // P8000282A
            SalesLine.SetFilter("Qty. to Ship", '<>0');
            if not SalesLine.Find('-') then
                exit;

            SalesHeader2 := SalesHeader;
            ReleaseSalesDocument.Reopen(SalesHeader);
            PriceCalcMgt.SetPostingShipment(true);
            SalesLine.SetSalesHeader(SalesHeader);
            SalesLine.Find('-');
            repeat
                if not SalesLine."Sales Sample" then begin // P8000708
                    PriceCalcMgt.FindSalesLinePrice(SalesHeader, SalesLine, 0);
                    PrepmtLineAmount := SalesLine."Prepmt. Line Amount"; // P8000466A
                    SalesLine.Validate("Unit Price");
                    SalesLine."Prepmt. Line Amount" := PrepmtLineAmount; // P8000466A
                end;                                       // P8000708
                SalesLine."Invoice at Shipped Price" := true;
                SalesLine.Modify(true);
            until (SalesLine.Next = 0);
            ReleaseSalesDocument.Run(SalesHeader);
            Invoice := SalesHeader2.Invoice;
            Ship := SalesHeader2.Ship;
            Receive := SalesHeader2.Receive;
        end;
    end;

    procedure CheckPriceAtInvoice(var SalesLine: Record "Sales Line"; var SalesShptLine: Record "Sales Shipment Line")
    begin
        // CheckPriceAtInvoice
        if SalesShptLine."Invoice at Shipped Price" and
           (SalesLine."Unit Price" <> SalesShptLine."Unit Price")
        then
            Error(Text006,
                  SalesShptLine."Document No.", SalesShptLine."Qty. Shipped Not Invoiced",
                  SalesShptLine."Unit of Measure", SalesShptLine.Type, SalesShptLine."No.",
                  SalesShptLine.FieldCaption("Unit Price"), SalesShptLine."Unit Price");
    end;

    procedure SetCustItemPriceGroup(var CustomerPriceGroup: Code[10]; CustomerNo: Code[20]; ItemCategoryCode: Code[20])
    var
        CustItemPriceGroup: Record "Cust./Item Price/Disc. Group";
        ItemCategory: Record "Item Category";
    begin
        // P8000545A, P8007749
        if (ItemCategoryCode <> '') then begin
            CustItemPriceGroup.SetRange("Customer No.", CustomerNo);
            CustItemPriceGroup.SetFilter("Customer Price Group", '<>%1', '');

            CustItemPriceGroup.SetRange("Item Category Code", ItemCategoryCode);
            if CustItemPriceGroup.FindFirst then
                CustomerPriceGroup := CustItemPriceGroup."Customer Price Group"
            else begin
                ItemCategory.Get(ItemCategoryCode);
                while ItemCategory."Parent Category" <> '' do begin
                    CustItemPriceGroup.SetRange("Item Category Code", ItemCategory."Parent Category");
                    if CustItemPriceGroup.FindFirst then begin
                        CustomerPriceGroup := CustItemPriceGroup."Customer Price Group";
                        break;
                    end else
                        ItemCategory.Get(ItemCategory."Parent Category");
                end;
            end;
        end;
    end;

    procedure SetCustItemDiscGroup(var CustomerDiscGroup: Code[10]; CustomerNo: Code[20]; ItemCategoryCode: Code[20])
    var
        CustItemPriceGroup: Record "Cust./Item Price/Disc. Group";
        ItemCategory: Record "Item Category";
    begin
        // P8000545A, P8007749
        if (ItemCategoryCode <> '') then begin
            CustItemPriceGroup.SetRange("Customer No.", CustomerNo);
            CustItemPriceGroup.SetFilter("Customer Disc. Group", '<>%1', '');

            CustItemPriceGroup.SetRange("Item Category Code", ItemCategoryCode);
            if CustItemPriceGroup.FindFirst then
                CustomerDiscGroup := CustItemPriceGroup."Customer Disc. Group"
            else begin
                ItemCategory.Get(ItemCategoryCode);
                while ItemCategory."Parent Category" <> '' do begin
                    CustItemPriceGroup.SetRange("Item Category Code", ItemCategory."Parent Category");
                    if CustItemPriceGroup.FindFirst then begin
                        CustomerDiscGroup := CustItemPriceGroup."Customer Disc. Group";
                        break;
                    end else
                        ItemCategory.Get(ItemCategory."Parent Category");
                end;
            end;
        end;
    end;
}

