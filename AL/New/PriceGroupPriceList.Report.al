report 37002044 "Price Group Price List"
{
    // PR4.00
    // P8000247A, Myers Nissi, Jack Reynolds, 05 OCT 05
    //   Copied from report 37002041 (Customer Price List) and modified to replace customers with customer price groups
    // 
    // P8000249A, Myers Nissi, Jack Reynolds, 20 OCT 05
    //   Modify calls to calculate price to include accruals
    // 
    // P8000253A, Myers Nissi, Jack Reynolds, 26 OCT 05
    //   Changes calls to FindPriceGroupPriceListPrice to pass blank variant code
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 06 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/PriceGroupPriceList.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Price Group Price List';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Customer Price Group"; "Customer Price Group")
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Code";
            column(CustPriceGroupCode; Code)
            {
            }
            dataitem(PageLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                MaxIteration = 1;
                PrintOnlyIfDetail = true;
                column(CompanyInfoName; CompanyInformation.Name)
                {
                }
                column(ReportTypeCustPriceGroupDesc; StrSubstNo(Text008, ReportType, "Customer Price Group".Description))
                {
                }
                column(ReportType; ReportType)
                {
                }
                column(CompanyAddress2; CompanyAddress[2])
                {
                }
                column(CompanyAddress3; CompanyAddress[3])
                {
                }
                column(CompanyAddress4; CompanyAddress[4])
                {
                }
                column(CompanyAddress5; CompanyAddress[5])
                {
                }
                column(CompanyAddress6; CompanyAddress[6])
                {
                }
                column(CompanyAddress7; CompanyAddress[7])
                {
                }
                column(CompanyAddress8; CompanyAddress[8])
                {
                }
                column(DateFilterDesc; DateFilterDescription)
                {
                }
                column(PageLoopQtyToOrderLabel; QtyToOrderLabel)
                {
                }
                dataitem(TempItemCategory; "Item Category")
                {
                    DataItemTableView = SORTING("Presentation Order");
                    RequestFilterFields = "Code";
                    UseTemporary = true;
                    dataitem(Item; Item)
                    {
                        DataItemLink = "Item Category Code" = FIELD(Code);
                        DataItemTableView = SORTING("Price List Sequence No.") WHERE("Item Type" = FILTER("Finished Good"), "Price List Sequence No." = FILTER(<> ''));
                        PrintOnlyIfDetail = true;
                        RequestFilterFields = "No.";
                        column(ItemGetItemCatDesc; ItemCategoryDescription)
                        {
                        }
                        column(ItemItemCategoryCode; Item."Item Category Code")
                        {
                        }
                        column(ItemNo; "No.")
                        {
                        }
                        dataitem(SalesUOM; "Item Unit of Measure")
                        {
                            DataItemLink = "Item No." = FIELD("No."), Code = FIELD("Sales Unit of Measure");
                            DataItemTableView = SORTING("Item No.", Code);
                            column(SalesUOMBody1; 'SalesUOM Body1')
                            {
                            }
                            column(SalesUOMGetUnitPrice; GetUnitPrice())
                            {
                            }
                            column(SalesUOMGetUOMDesc; GetUOMDescription(Code))
                            {
                            }
                            column(SalesUOMItemDesc; ItemDescToDisplay)
                            {
                            }
                            column(SalesUOMItemNo; ItemNoToDisplay)
                            {
                            }
                            column(SalesUOMQtyToOrderLine; QtyToOrderLine)
                            {
                            }
                            column(SalesUOMBody2; 'SalesUOM Body2')
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                SalesPriceMgmt.FindPriceGroupPriceListPrice(Item, "Customer Price Group", '', Code, StartDate, true); // P8000249A P8000253A
                                if (not ShowAllItems) and (Item."Unit Price" = 0) then
                                    CurrReport.Skip;

                                GetDisplayStrings;
                            end;

                            trigger OnPreDataItem()
                            begin
                                if (Item."Sales Unit of Measure" = '') then
                                    CurrReport.Break;
                            end;
                        }
                        dataitem(BaseUOM; "Item Unit of Measure")
                        {
                            DataItemLink = "Item No." = FIELD("No."), Code = FIELD("Base Unit of Measure");
                            DataItemTableView = SORTING("Item No.", Code);
                            column(BaseUOMBody1; 'BaseUOM Body1')
                            {
                            }
                            column(BaseUOMItemDesc; ItemDescToDisplay)
                            {
                            }
                            column(BaseUOMItemNo; ItemNoToDisplay)
                            {
                            }
                            column(BaseUOMGetUnitPrice; GetUnitPrice())
                            {
                            }
                            column(BaseUOMGetUOMDesc; GetUOMDescription(Code))
                            {
                            }
                            column(BaseUOMQtyToOrderLine; QtyToOrderLine)
                            {
                            }
                            column(BaseUOMBody2; 'BaseUOM Body2')
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                SalesPriceMgmt.FindPriceGroupPriceListPrice(Item, "Customer Price Group", '', Code, StartDate, true); // P8000249A P8000253A
                                if (not ShowAllItems) and (Item."Unit Price" = 0) then
                                    CurrReport.Skip;

                                GetDisplayStrings;
                            end;

                            trigger OnPreDataItem()
                            begin
                                if (Item."Sales Unit of Measure" = Item."Base Unit of Measure") then
                                    CurrReport.Break;
                            end;
                        }
                        dataitem(UOMLoop; "Integer")
                        {
                            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                            column(UOMLoopBody1; 'UOMLoop Body1')
                            {
                            }
                            column(UOMLoopItemDescToDisplay; ItemDescToDisplay)
                            {
                            }
                            column(UOMLoopItemNoToDisplay; ItemNoToDisplay)
                            {
                            }
                            column(UOMLoopGetUnitPrice; GetUnitPrice())
                            {
                            }
                            column(UOMLoopGetUOMDescTempUOM; GetUOMDescription(TempUOM.Code))
                            {
                            }
                            column(UOMLoopQtyToOrderLine; QtyToOrderLine)
                            {
                            }
                            column(UOMLoopBody2; 'UOMLoop Body2')
                            {
                            }
                            column(UOMLoopNumber; Number)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if (Number > 1) then
                                    if (TempUOM.Next = 0) then
                                        CurrReport.Break;

                                if (TempUOM.Code in [Item."Sales Unit of Measure", Item."Base Unit of Measure"]) then
                                    CurrReport.Skip;

                                SalesPriceMgmt.FindPriceGroupPriceListPrice(Item, "Customer Price Group", '', //  P8000253A
                                  TempUOM.Code, StartDate, true); // P8000249A
                                if (not ShowAllItems) and (Item."Unit Price" = 0) then
                                    CurrReport.Skip;

                                GetDisplayStrings;
                            end;

                            trigger OnPreDataItem()
                            begin
                                TempUOM.Reset;
                                if not TempUOM.Find('-') then
                                    CurrReport.Break;
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            SalesPriceMgmt.FindPriceGroupPriceListUnits(Item, "Customer Price Group", StartDate, ShowBrokenCasePrices, TempUOM);

                            ItemHasBeenDisplayed := false;
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        // P8007749
                        ItemCategoryDescription := GetExtendedDescription;
                    end;

                    trigger OnPreDataItem()
                    begin
                        // P8007749
                        Reset;
                        SetCurrentKey("Presentation Order");
                    end;
                }
            }

            trigger OnAfterGetRecord()
            begin
                if FirstCustomer then
                    FirstCustomer := false
                else begin
                    CurrReport.NewPage;
                    CurrReport.PageNo(1);
                end;
            end;

            trigger OnPreDataItem()
            begin
                GLSetup.Get;
                Currency."Unit-Amount Decimal Places" := GLSetup."Unit-Amount Decimal Places";
                FirstCustomer := true;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(StartDate; StartDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Date';
                    }
                    field("Report Type"; ReportType)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Report Type';
                    }
                    field(ShowStreetAddress; ShowStreetAddress)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Show Street Address';

                        trigger OnValidate()
                        begin
                            ShowStreetAddressOnAfterValida;
                        end;
                    }
                    field(ShowFaxNo; ShowFaxNo)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Show Fax No.';

                        trigger OnValidate()
                        begin
                            ShowFaxNoOnAfterValidate;
                        end;
                    }
                    field(ShowAllItems; ShowAllItems)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Show All Items';

                        trigger OnValidate()
                        begin
                            ShowAllItemsOnAfterValidate;
                        end;
                    }
                    field(ZeroPriceDescControl; ZeroPriceDescription)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Zero Price Description';
                        Enabled = ZeroPriceDescControlEnable;
                    }
                    field("Show Broken Case Prices"; ShowBrokenCasePrices)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Show Broken Case Prices';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            ZeroPriceDescControlEnable := true;
        end;

        trigger OnOpenPage()
        begin
            ZeroPriceDescControlEnable := ShowAllItems;
        end;
    }

    labels
    {
        PageNo = 'Page';
        ItemDescCaption = 'Item Description';
        ItemNoCaption = 'Item No.';
        UnitPriceCaption = 'Unit Price';
        UOMDescriptionCaption = 'Unit of Measure';
    }

    trigger OnInitReport()
    begin
        ZeroPriceDescription := Text000;
        CompanyInformation.Get;
        CompanyInformation.TestField("Phone No.");
    end;

    trigger OnPreReport()
    var
        ItemCategory: Record "Item Category";
        Process800CoreFunctions: Codeunit "Process 800 Core Functions";
        PreseentationOrderFilter: Text;
    begin
        if StartDate = 0D then
            Error(Text002)
        else
            DateFilterDescription := StrSubstNo(Text001, StartDate);

        if ShowFaxNo then
            CompanyInformation.TestField("Fax No.");

        if ShowStreetAddress then
            FormatAddress.Company(CompanyAddress, CompanyInformation);
        AddressIndex := 1;
        repeat
            AddressIndex := AddressIndex + 1;
        until (AddressIndex = ArrayLen(CompanyAddress)) or (CompanyAddress[AddressIndex] = '');
        if (CompanyAddress[AddressIndex] = '') then begin
            CompanyAddress[AddressIndex] := CompanyInformation."Phone No.";
            if ShowFaxNo and (AddressIndex < ArrayLen(CompanyAddress)) then
                CompanyAddress[AddressIndex + 1] := StrSubstNo(Text006, CompanyInformation."Fax No.");
        end;

        if (ReportType = ReportType::"Order Guide") then begin
            QtyToOrderLabel := Text007;
            QtyToOrderLine := PadStr('', MaxStrLen(QtyToOrderLine), '_');
        end;

        // P8007749
        if TempItemCategory.GetFilters = '' then
            TempItemCategory.Insert;

        ItemCategory.Copy(TempItemCategory);
        PreseentationOrderFilter := Process800CoreFunctions.GetItemCategoryPresentationRangeFilter(ItemCategory); // P80066030
        ItemCategory.Reset;
        ItemCategory.SetFilter("Presentation Order", PreseentationOrderFilter);

        if ItemCategory.FindSet then
            repeat
                TempItemCategory := ItemCategory;
                TempItemCategory.Insert;
            until ItemCategory.Next = 0;
        // P8007749
    end;

    var
        ReportType: Option "Price List","Order Guide";
        QtyToOrderLabel: Text[30];
        QtyToOrderLine: Text[30];
        ShowStreetAddress: Boolean;
        ShowFaxNo: Boolean;
        ShowAllItems: Boolean;
        ZeroPriceDescription: Text[50];
        ShowBrokenCasePrices: Boolean;
        CompanyInformation: Record "Company Information";
        StartDate: Date;
        DateFilterDescription: Text[250];
        GLSetup: Record "General Ledger Setup";
        FirstCustomer: Boolean;
        SalesPriceMgmt: Codeunit "Sales Price Calc. Mgt.";
        TempUOM: Record "Unit of Measure" temporary;
        Currency: Record Currency;
        ItemHasBeenDisplayed: Boolean;
        ItemNoToDisplay: Code[20];
        ItemDescToDisplay: Text[250];
        FormatAddress: Codeunit "Format Address";
        CompanyAddress: array[8] of Text[100];
        AddressIndex: Integer;
        Text000: Label 'Market (Call for Price)';
        Text001: Label 'Prices for %1';
        Text002: Label 'Date must be entered.';
        Text003: Label 'Unknown Item Category';
        Text004: Label '<Precision,%1><Standard format,0>';
        Text005: Label '%1 - continued';
        Text006: Label 'Fax: %1';
        Text007: Label 'Qty. to Order';
        Text008: Label '%1 for %2';
        [InDataSet]
        ZeroPriceDescControlEnable: Boolean;
        ItemCategoryDescription: Text;

    local procedure GetDisplayStrings()
    begin
        if ItemHasBeenDisplayed then begin
            ItemNoToDisplay := '';
            ItemDescToDisplay := '';
        end else begin
            ItemNoToDisplay := Item."No.";
            ItemDescToDisplay := Item.Description;
            ItemHasBeenDisplayed := true;
        end;
    end;

    local procedure GetUOMDescription(UOMCode: Code[10]): Text[250]
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if not UnitOfMeasure.Get(UOMCode) then
            exit('');
        exit(UnitOfMeasure.Description);
    end;

    local procedure GetUnitPrice(): Text[30]
    begin
        if ShowAllItems then
            if (ZeroPriceDescription <> '') and (Item."Unit Price" = 0) then
                exit(ZeroPriceDescription);
        exit(Format(Item."Unit Price", 0, StrSubstNo(Text004, Currency."Unit-Amount Decimal Places")));
    end;

    local procedure ShowFaxNoOnAfterValidate()
    begin
        ZeroPriceDescControlEnable := ShowAllItems;
    end;

    local procedure ShowAllItemsOnAfterValidate()
    begin
        ZeroPriceDescControlEnable := ShowAllItems;
    end;

    local procedure ShowStreetAddressOnAfterValida()
    begin
        ZeroPriceDescControlEnable := ShowAllItems;
    end;
}

