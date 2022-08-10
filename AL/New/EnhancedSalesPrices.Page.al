page 37002040 "Enhanced Sales Prices"
{
    // PR3.60
    // 
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Add Cost Calculation Method and Rounding Method
    // 
    // P8000761, VerticalSoft, Maria Maslennikova, 02 FEB 10
    //   Code changed in the UpdateItemFields() method to be correctly transformed into 2009
    //   Methods changed in order to keep editable properties updated:
    //     Item Type - OnValidate()
    //     Pricing Method - OnValidate()
    //     Item Code 1 - OnValidate()
    //     Cost Reference - OnValidate()
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property
    // 
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10
    // P8001244, Columbus IT, Jack Reynolds, 20 NOV 13
    //   Fix problem setting Sales Type and Item Type filters
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW110.0.01
    // P80041198, To-Increase, Jack Reynolds, 08 MAY 17
    //   Copied Copy Prices from page 7002 (Sales Prices)
    // 
    // PRW111.00.02
    // P80064337, To-Increase, Jack Reynolds, 06 SEP 18
    //   Missing or misspelled caption

    Caption = 'Sales Prices';
    DataCaptionExpression = GetCaption;
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Sales Price";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(SalesTypeFilter; SalesTypeFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Sales Type Filter';
                    OptionCaption = 'Customer,Customer Price Group,All Customers,Campaign,None';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                        SalesCodeFilter := '';
                        SetRecFilters;
                    end;
                }
                field(SalesCodeFilterCtrl; SalesCodeFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Sales Code Filter';
                    Enabled = SalesCodeFilterCtrlEnable;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CustList: Page "Customer List";
                        CustPriceGrList: Page "Customer Price Groups";
                        CampaignList: Page "Campaign List";
                    begin
                        if SalesTypeFilter = SalesTypeFilter::"All Customers" then exit;

                        case SalesTypeFilter of
                            SalesTypeFilter::Customer:
                                begin
                                    CustList.LookupMode := true;
                                    if CustList.RunModal <> ACTION::LookupOK then
                                        exit(false);
                                    CustList.GetRecord(Cust);
                                    Text := Cust."No.";
                                end;
                            SalesTypeFilter::"Customer Price Group":
                                begin
                                    CustPriceGrList.LookupMode := true;
                                    if CustPriceGrList.RunModal <> ACTION::LookupOK then
                                        exit(false);
                                    CustPriceGrList.GetRecord(CustPriceGr);
                                    Text := CustPriceGr.Code;
                                end;
                            SalesTypeFilter::Campaign:
                                begin
                                    CampaignList.LookupMode := true;
                                    if CampaignList.RunModal = ACTION::LookupOK then
                                        Text := CampaignList.GetSelectionFilter
                                    else
                                        exit(false);
                                end;
                        end;

                        exit(true);
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                        SetRecFilters;
                    end;
                }
                field(StartingDateFilter; StartingDateFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Starting Date Filter';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                        SetRecFilters;
                    end;
                }
                field(CurrencyCodeFilterCtrl; CurrencyCodeFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Currency Code Filter';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CurrencyList: Page Currencies;
                    begin
                        CurrencyList.LookupMode := true;
                        if CurrencyList.RunModal <> ACTION::LookupOK then
                            exit(false);
                        CurrencyList.GetRecord(Currency);
                        Text := Currency.Code;

                        exit(true);
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                        SetRecFilters;
                    end;
                }
                field(ItemTypeFilterCtrl; ItemTypeFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Type Filter';
                    OptionCaption = 'Item,Item Category,,,All Items,None';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                        ItemCodeFilter := '';
                        SetRecFilters;
                    end;
                }
                field(ItemCodeFilterCtrl; ItemCodeFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Code Filter';
                    Enabled = ItemCodeFilterCtrlEnable;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(ItemSalesPriceMgmt.LookupItemCodeFilter(ItemTypeFilter, Text)); // PR3.60
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                        SetRecFilters;
                    end;
                }
            }
            repeater(Control37002001)
            {
                ShowCaption = false;
                field("Sales Type"; "Sales Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sales Code"; "Sales Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Sales CodeEditable";
                }
                field("Item Type"; "Item Type")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        //P8000761 MMAS >>
                        xRec := Rec;
                        UpdateItemFields;
                        //P8000761 MMAS <<
                    end;
                }
                field("Item Code"; "Item Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = ItemCodeEditable;

                    trigger OnValidate()
                    begin
                        //P8000761 MMAS >>
                        xRec := Rec;
                        UpdateItemFields;
                        //P8000761 MMAS <<
                    end;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Special Price"; "Special Price")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Price Type"; "Price Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Minimum Quantity"; "Minimum Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Maximum Quantity"; "Maximum Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pricing Method"; "Pricing Method")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        //P8000761 MMAS >>
                        xRec := Rec;
                        UpdateItemFields;
                        //P8000761 MMAS <<
                    end;
                }
                field("Cost Adjustment"; "Cost Adjustment")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Cost AdjustmentEditable";
                }
                field("Cost Reference"; "Cost Reference")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Cost ReferenceEditable";

                    trigger OnValidate()
                    begin
                        //P8000761 MMAS >>
                        xRec := Rec;
                        UpdateItemFields;
                        //P8000761 MMAS <<
                    end;
                }
                field("Cost Calc. Method Code"; "Cost Calc. Method Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Cost Calc. Method CodeEditable";
                }
                field("Price Rounding Method"; "Price Rounding Method")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Price Rounding MethodEditable";
                    Visible = false;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Unit PriceEditable";
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Use Break Charge"; "Use Break Charge")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Price Includes VAT"; "Price Includes VAT")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Allow Line Disc."; "Allow Line Disc.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Allow Invoice Disc."; "Allow Invoice Disc.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("VAT Bus. Posting Gr. (Price)"; "VAT Bus. Posting Gr. (Price)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(CopyPrices)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Copy Prices';
                Image = Copy;
                Visible = NOT IsLookupMode;

                trigger OnAction()
                begin
                    // P80041198
                    CopyPrices;
                    CurrPage.Update;
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        "Sales CodeEditable" := "Sales Type" <> "Sales Type"::"All Customers";
        UpdateItemFields;                                                      // P8001132
    end;

    trigger OnOpenPage()
    begin
        GetRecFilters;
        SetRecFilters;
        IsLookupMode := CurrPage.LookupMode; // P80041198
    end;

    var
        Cust: Record Customer;
        CustPriceGr: Record "Customer Price Group";
        Campaign: Record Campaign;
        Item: Record Item;
        SalesTypeFilter: Option Customer,"Customer Price Group","All Customers",Campaign,"None";
        SalesCodeFilter: Text[250];
        ItemNoFilter: Text[250];
        StartingDateFilter: Text[30];
        CurrencyCodeFilter: Text[250];
        Text000: Label 'All Customers';
        Currency: Record Currency;
        ItemTypeFilter: Option Item,"Item Category",,,"All Items","None";
        ItemCodeFilter: Text[250];
        ItemSalesPriceMgmt: Codeunit "Item Sales Price Management";
        [InDataSet]
        "Sales CodeEditable": Boolean;
        [InDataSet]
        "Cost Calc. Method CodeEditable": Boolean;
        [InDataSet]
        "Unit PriceEditable": Boolean;
        [InDataSet]
        ItemCodeEditable: Boolean;
        [InDataSet]
        "Cost AdjustmentEditable": Boolean;
        [InDataSet]
        "Cost ReferenceEditable": Boolean;
        [InDataSet]
        "Price Rounding MethodEditable": Boolean;
        [InDataSet]
        SalesCodeFilterCtrlEnable: Boolean;
        [InDataSet]
        ItemCodeFilterCtrlEnable: Boolean;
        IsLookupMode: Boolean;
        MultipleCustomersSelectedErr: Label 'More than one customer uses these sales prices. To copy prices, the Sales Code Filter field must contain one customer only.';
        IncorrectSalesTypeToCopyPricesErr: Label 'To copy sales prices, The Sales Type Filter field must contain Customer.';

    procedure GetRecFilters()
    begin
        if GetFilters <> '' then begin
            if GetFilter("Sales Type") <> '' then
                SalesTypeFilter := GetSalesTypeFilter // P8001244
            else
                SalesTypeFilter := SalesTypeFilter::None;

            SalesCodeFilter := GetFilter("Sales Code");
            ItemNoFilter := GetFilter("Item No.");
            CurrencyCodeFilter := GetFilter("Currency Code");

            ItemSalesPriceMgmt.GetPriceItemFilters(Rec, ItemTypeFilter, ItemCodeFilter); // P8007749
        end;

        Evaluate(StartingDateFilter, GetFilter("Starting Date"));
    end;

    procedure SetRecFilters()
    begin
        SalesCodeFilterCtrlEnable := true;

        if SalesTypeFilter <> SalesTypeFilter::None then
            SetRange("Sales Type", SalesTypeFilter)
        else
            SetRange("Sales Type");

        if SalesTypeFilter in [SalesTypeFilter::"All Customers", SalesTypeFilter::None] then begin
            SalesCodeFilterCtrlEnable := false;
            SalesCodeFilter := '';
        end;

        if SalesCodeFilter <> '' then
            SetFilter("Sales Code", SalesCodeFilter)
        else
            SetRange("Sales Code");

        if StartingDateFilter <> '' then
            SetFilter("Starting Date", StartingDateFilter)
        else
            SetRange("Starting Date");

        if ItemNoFilter <> '' then begin
            SetFilter("Item No.", ItemNoFilter);
        end else
            SetRange("Item No.");

        ItemCodeFilterCtrlEnable := true;

        if (ItemTypeFilter in [ItemTypeFilter::"All Items", ItemTypeFilter::None]) then
            ItemCodeFilterCtrlEnable := false;

        ItemSalesPriceMgmt.SetPriceItemFilters(Rec, ItemTypeFilter, ItemCodeFilter); // P8007749

        if CurrencyCodeFilter <> '' then begin
            SetFilter("Currency Code", CurrencyCodeFilter);
        end else
            SetRange("Currency Code");

        CurrPage.Update(false);
    end;

    procedure GetCaption(): Text[250]
    var
        ObjTransl: Record "Object Translation";
        SourceTableName: Text[100];
        SalesSrcTableName: Text[100];
        Description: Text[250];
    begin
        GetRecFilters;
        "Sales CodeEditable" := "Sales Type" <> "Sales Type"::"All Customers";

        SourceTableName := '';
        if ItemNoFilter <> '' then
            SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 27);

        UpdateItemFields;

        ItemSalesPriceMgmt.GetCaption(
          ItemTypeFilter, ItemCodeFilter, // P8007749
          SourceTableName, ItemNoFilter, Description);

        SalesSrcTableName := '';
        case SalesTypeFilter of
            SalesTypeFilter::Customer:
                begin
                    SalesSrcTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 18);
                    Cust."No." := SalesCodeFilter;
                    if Cust.Find then
                        Description := Cust.Name;
                end;
            SalesTypeFilter::"Customer Price Group":
                begin
                    SalesSrcTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 6);
                    CustPriceGr.Code := SalesCodeFilter;
                    if CustPriceGr.Find then
                        Description := CustPriceGr.Description;
                end;
            SalesTypeFilter::Campaign:
                begin
                    SalesSrcTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 5071);
                    Campaign."No." := SalesCodeFilter;
                    if Campaign.Find then
                        Description := Campaign.Description;
                end;
            SalesTypeFilter::"All Customers":
                begin
                    SalesSrcTableName := Text000;
                    Description := '';
                end;
        end;

        if SalesSrcTableName = Text000 then
            exit(StrSubstNo('%1 %2 %3', SalesSrcTableName, SourceTableName, ItemNoFilter));
        exit(StrSubstNo('%1 %2 %3 %4 %5', SalesSrcTableName, SalesCodeFilter, Description, SourceTableName, ItemNoFilter));
    end;

    local procedure UpdateItemFields()
    begin
        ItemCodeEditable := "Item Type" <> "Item Type"::"All Items";

        "Cost AdjustmentEditable" := "Pricing Method" <> "Pricing Method"::"Fixed Amount";
        "Cost ReferenceEditable" := "Pricing Method" <> "Pricing Method"::"Fixed Amount";
        // P8000539A
        //P8000761 MMAS >>
        //CurrForm."Cost Calc. Method Code".EDITABLE(
        "Cost Calc. Method CodeEditable" := (
        //P8000761 MMAS <<
          ("Pricing Method" <> "Pricing Method"::"Fixed Amount") and
          ("Cost Reference" = "Cost Reference"::"Cost Calc. Method"));
        "Price Rounding MethodEditable" := "Pricing Method" <> "Pricing Method"::"Fixed Amount";
        // P8000539A
        "Unit PriceEditable" := "Pricing Method" = "Pricing Method"::"Fixed Amount";
    end;

    local procedure GetSalesTypeFilter(): Integer
    begin
        // P8001244
        case GetFilter("Sales Type") of
            Format("Sales Type"::Customer):
                exit(0);
            Format("Sales Type"::"Customer Price Group"):
                exit(1);
            Format("Sales Type"::"All Customers"):
                exit(2);
            Format("Sales Type"::Campaign):
                exit(3);
        end;
    end;

    local procedure CopyPrices()
    var
        Customer: Record Customer;
        SalesPrice: Record "Sales Price";
        SelectedSalesPrice: Record "Sales Price";
        SalesPrices: Page "Enhanced Sales Prices";
        CopyToCustomerNo: Code[20];
    begin
        // P80041198
        if SalesTypeFilter <> SalesTypeFilter::Customer then
            Error(IncorrectSalesTypeToCopyPricesErr);
        Customer.SetFilter("No.", SalesCodeFilter);
        if Customer.Count <> 1 then
            Error(MultipleCustomersSelectedErr);
        CopyToCustomerNo := CopyStr(SalesCodeFilter, 1, MaxStrLen(CopyToCustomerNo));
        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::Customer);
        SalesPrice.SetFilter("Sales Code", '<>%1', SalesCodeFilter);
        SalesPrice.FilterGroup(2);
        SalesPrice.SetRange("Contract No.", '');
        SalesPrice.FilterGroup(0);
        SalesPrices.LookupMode(true);
        SalesPrices.SetTableView(SalesPrice);
        if SalesPrices.RunModal = ACTION::LookupOK then begin
            SalesPrices.GetSelectionFilter(SelectedSalesPrice);
            CopySalesPriceToCustomersSalesPrice(SelectedSalesPrice, CopyToCustomerNo);
        end;
    end;

    procedure GetSelectionFilter(var SalesPrice: Record "Sales Price")
    begin
        // P80041198
        CurrPage.SetSelectionFilter(SalesPrice);
    end;
}

