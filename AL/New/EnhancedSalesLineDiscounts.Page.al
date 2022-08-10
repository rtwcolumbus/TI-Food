page 37002041 "Enhanced Sales Line Discounts"
{
    // PR3.60
    // 
    // PR4.00.03
    // P8000345A, VerticalSoft, Jack Reynolds, 08 JUN 06
    //   Support for Unit Amount as line discount type
    // 
    // P8000761, VerticalSoft, MMAS, 29 JAN 10
    //   Code changed in the UpdateItemFields() method to be correctly transformed into 2009.
    //   Methods changed to update editable property:
    //     Line Discount Type - OnValidate()
    //     Item Type - OnValidate()
    //     Item Code 1 - OnValidate()
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
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Sales Line Discounts';
    DataCaptionExpression = GetCaption;
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Sales Line Discount";

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
                    OptionCaption = 'Customer,Customer Discount Group,All Customers,Campaign,None';

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
                        CustDiscGrList: Page "Customer Disc. Groups";
                        CampaignList: Page "Campaign List";
                        ItemList: Page "Item List";
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
                            SalesTypeFilter::"Customer Discount Group":
                                begin
                                    CustDiscGrList.LookupMode := true;
                                    if CustDiscGrList.RunModal <> ACTION::LookupOK then
                                        exit(false);
                                    CustDiscGrList.GetRecord(CustDiscGr);
                                    Text := CustDiscGr.Code;
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
                    var
                        FilterTokens: Codeunit "Filter Tokens";
                    begin
                        FilterTokens.MakeDateFilter(StartingDateFilter); // P800-MegaApp
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
                field(ItemTypeFilterCtrl; ItemTypeFilter2)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Type Filter';

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
                        exit(ItemSalesPriceMgmt.LookupItemCodeFilter(ItemTypeFilter2, Text));
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                        SetRecFilters;
                    end;
                }
            }
            repeater(Control37002000)
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
                        UpdateItemFields();
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
                        UpdateItemFields();
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
                field("Minimum Quantity"; "Minimum Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Line Discount Type"; "Line Discount Type")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        //P8000761 MMAS >>
                        xRec := Rec;
                        UpdateItemFields();
                        //P8000761 MMAS <<
                    end;
                }
                field("Line Discount %"; "Line Discount %")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Line Discount %Editable";
                }
                field("Line Discount Amount"; "Line Discount Amount")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Line Discount AmountEditable";
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        "Sales CodeEditable" := "Sales Type" <> "Sales Type"::"All Customers";
        UpdateItemFields;
    end;

    trigger OnInit()
    begin
        ItemCodeFilterCtrlEnable := true;
        SalesCodeFilterCtrlEnable := true;
        ItemCodeEditable := true;
        "Line Discount %Editable" := true;
        "Line Discount AmountEditable" := true;
        "Sales CodeEditable" := true;
    end;

    trigger OnOpenPage()
    begin
        GetRecFilters;
        SetRecFilters;
    end;

    var
        Cust: Record Customer;
        Campaign: Record Campaign;
        CustDiscGr: Record "Customer Discount Group";
        Item: Record Item;
        ItemDiscGr: Record "Item Discount Group";
        SalesTypeFilter: Option Customer,"Customer Discount Group","All Customers",Campaign,"None";
        SalesCodeFilter: Text[250];
        ItemTypeFilter: Option Item,"Item Discount Group","None";
        CodeFilter: Text[250];
        StartingDateFilter: Text[30];
        Text000: Label 'All Customers';
        CurrencyCodeFilter: Text[250];
        Currency: Record Currency;
        ItemTypeFilter2: Option Item,"Item Category",,"Item Disc. Group","All Items","None";
        ItemCodeFilter: Text[250];
        ItemSalesPriceMgmt: Codeunit "Item Sales Price Management";
        [InDataSet]
        "Sales CodeEditable": Boolean;
        [InDataSet]
        "Line Discount AmountEditable": Boolean;
        [InDataSet]
        "Line Discount %Editable": Boolean;
        [InDataSet]
        ItemCodeEditable: Boolean;
        [InDataSet]
        SalesCodeFilterCtrlEnable: Boolean;
        [InDataSet]
        ItemCodeFilterCtrlEnable: Boolean;

    procedure GetRecFilters()
    begin
        if GetFilters <> '' then begin
            if GetFilter("Sales Type") <> '' then
                SalesTypeFilter := GetSalesTypeFilter // P8001244
            else
                SalesTypeFilter := SalesTypeFilter::None;

            if GetFilter(Type) <> '' then
                ItemTypeFilter := Type
            else
                ItemTypeFilter := ItemTypeFilter::None;

            SalesCodeFilter := GetFilter("Sales Code");
            CodeFilter := GetFilter(Code);
            CurrencyCodeFilter := GetFilter("Currency Code");
            Evaluate(StartingDateFilter, GetFilter("Starting Date"));

            ItemSalesPriceMgmt.GetLineDiscItemFilters(
              Rec, ItemTypeFilter2, ItemCodeFilter); // P8007749
        end;
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

        if ItemTypeFilter <> ItemTypeFilter::None then
            SetRange(Type, ItemTypeFilter)
        else
            SetRange(Type);

        ItemCodeFilterCtrlEnable := true;

        if (ItemTypeFilter2 in [ItemTypeFilter2::"All Items", ItemTypeFilter2::None]) then
            ItemCodeFilterCtrlEnable := false;

        ItemSalesPriceMgmt.SetLineDiscItemFilters(Rec, ItemTypeFilter2, ItemCodeFilter); // P8007749

        if CurrencyCodeFilter <> '' then begin
            SetFilter("Currency Code", CurrencyCodeFilter);
        end else
            SetRange("Currency Code");

        if StartingDateFilter <> '' then
            SetFilter("Starting Date", StartingDateFilter)
        else
            SetRange("Starting Date");

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

        UpdateItemFields;

        ItemSalesPriceMgmt.GetCaption(
          ItemTypeFilter2, ItemCodeFilter, // P8007749
          SourceTableName, CodeFilter, Description);

        SalesSrcTableName := '';
        case SalesTypeFilter of
            SalesTypeFilter::Customer:
                begin
                    SalesSrcTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 18);
                    Cust."No." := SalesCodeFilter;
                    if Cust.Find then
                        Description := Cust.Name;
                end;
            SalesTypeFilter::"Customer Discount Group":
                begin
                    SalesSrcTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 340);
                    CustDiscGr.Code := SalesCodeFilter;
                    if CustDiscGr.Find then
                        Description := CustDiscGr.Description;
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
            exit(StrSubstNo('%1 %2 %3 %4 %5', SalesSrcTableName, SalesCodeFilter, Description, SourceTableName, CodeFilter));
        exit(StrSubstNo('%1 %2 %3 %4 %5', SalesSrcTableName, SalesCodeFilter, Description, SourceTableName, CodeFilter));
    end;

    local procedure UpdateItemFields()
    begin
        ItemCodeEditable := "Item Type" <> "Item Type"::"All Items";

        "Line Discount %Editable" := "Line Discount Type" = "Line Discount Type"::Percent;
        //P8000761 MMAS >>
        //CurrForm."Line Discount Amount".EDITABLE("Line Discount Type" IN       // P8000345A
        //  ["Line Discount Type"::Amount,"Line Discount Type"::"Unit Amount"]); // P8000345A
        "Line Discount AmountEditable" := ("Line Discount Type" in       // P8000345A
          ["Line Discount Type"::Amount, "Line Discount Type"::"Unit Amount"]); // P8000345A
        //P8000761 MMAS <<
    end;

    local procedure GetSalesTypeFilter(): Integer
    begin
        // P8001244
        case GetFilter("Sales Type") of
            Format("Sales Type"::Customer):
                exit(0);
            Format("Sales Type"::"Customer Disc. Group"):
                exit(1);
            Format("Sales Type"::"All Customers"):
                exit(2);
            Format("Sales Type"::Campaign):
                exit(3);
        end;
    end;
}

