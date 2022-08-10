report 37002025 "Item Lot Availability" // Version: FOODNA
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Report of quantity available for lots
    //   Shows lot age fields and lot specifications
    //   Allows filtering on lot age and lot specifications
    // 
    // PR4.00
    // P8000251A, Myers Nissi, Jack Reynolds, 20 OCT 05
    //   Add expiration date and days to expire
    // 
    // PRW16.00.03
    // P8000813, VerticalSoft, MMAS, 04 MAY 10
    //   Report design for RTC
    //     1. DateFormat added to the fields: "Release Date", "Production Date", Current Age Date, Expiration Date
    // 
    // PRW16.00.06
    // P8001070, Columbus IT, Jack Reynolds, 07 JAN 13
    //   Support for Lot Freshness
    // 
    // PRW17.10
    // P8001223, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Expand filter variables
    // 
    // PRW17.10.01
    // P8001254, Columbus IT, Jack Reynolds, 06 JAN 14
    //   Adjust layout to accomodate Letter size paper
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/ItemLotAvailability.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Item Lot Availability';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Lot No. Information"; "Lot No. Information")
        {
            DataItemTableView = SORTING("Item Category Code", "Item No.", "Creation Date", "Variant Code", "Lot No.") WHERE(Posted = CONST(true), Inventory = FILTER(> 0));
            RequestFilterFields = "Item Category Code", "Item No.";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(LotInfoFilterText; LotInfoFilterText)
            {
            }
            column(LotAgeFilterText; LotAgeFilterText)
            {
            }
            column(LotSpecFilterText; LotSpecFilterText)
            {
            }
            column(OldestAcceptableText; OldestAcceptableText)
            {
            }
            column(LotInfoItemNo; "Item No.")
            {
                IncludeCaption = true;
            }
            column(LotInfoVariantCode; "Variant Code")
            {
                IncludeCaption = true;
            }
            column(LotInfoLotNo; "Lot No.")
            {
                IncludeCaption = true;
            }
            column(LotInfoReleaseDate; "Release Date")
            {
                IncludeCaption = true;
            }
            column(LotInfoProductionDate; "Creation Date")
            {
                IncludeCaption = true;
            }
            column(LotInfoInventory; Inventory)
            {
            }
            column(LotInfoQuantityAlt; "Quantity (Alt.)")
            {
            }
            column(LotInfoDesc; Description)
            {
                IncludeCaption = true;
            }
            column(LotFilterFnsAgeLotNoInfo; LotFilterFns.Age("Lot No. Information"))
            {
            }
            column(LotFilterFnsAgeCategoryLotNoInfo; LotFilterFns.AgeCategory("Lot No. Information"))
            {
            }
            column(LotFilterFnsAgeDateLotNoInfo; LotFilterFns.AgeDate("Lot No. Information"))
            {
            }
            column(RemDaysText; RemDaysText)
            {
            }
            column(LotInfoExpirationDate; "Expiration Date")
            {
                IncludeCaption = true;
            }
            column(DaysToExpireText; DaysToExpireText)
            {
            }
            column(LotInfoFreshnessDate; "Freshness Date")
            {
                IncludeCaption = true;
            }
            column(LotSpecText; LotSpecText)
            {
            }

            trigger OnAfterGetRecord()
            begin
                Item.Get("Item No.");                                                             // P8001070
                if not LotFilterFns.LotInFilter("Lot No. Information", LotAgeFilter, LotSpecFilter, // P8001070
                  Item."Freshness Calc. Method", OldestAcceptableDate)                             // P8001070
                then                                                                              // P8001070
                    CurrReport.Skip;

                RemDays := LotFilterFns.RemainingDays("Lot No. Information");
                case RemDays of
                    0:
                        RemDaysText := '';
                    2147483647:
                        RemDaysText := Text001;
                    else
                        RemDaysText := Format(RemDays);
                end;

                // P8000251A Begin
                DaysToExpire := LotFilterFns.DaysToExpire("Lot No. Information");
                case DaysToExpire of
                    0:
                        DaysToExpireText := '';
                    2147483647:
                        DaysToExpireText := Text001;
                    else
                        DaysToExpireText := Format(DaysToExpire);
                end;
                // P8000251A End

                LotSpecText := '';
                if LotSpecCat.Find('-') then begin
                    repeat
                        if LotSpec.Get("Item No.", "Variant Code", "Lot No.", LotSpecCat.Code) then
                            LotSpecText := LotSpecText + ', ' + LotSpecCat.Description + ': ' + LotSpec.Value;
                    until LotSpecCat.Next = 0;
                    LotSpecText := CopyStr(LotSpecText, 3);
                end;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(AgeFilter; AgeFilter)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Age Filter';

                        trigger OnValidate()
                        begin
                            LotAgeFilter.SetFilter(Age, AgeFilter);
                            AgeFilter := LotAgeFilter.GetFilter(Age);
                        end;
                    }
                    field(CategoryFilter; CategoryFilter)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Age Category Filter';
                        TableRelation = "Lot Age Category";

                        trigger OnValidate()
                        begin
                            LotAgeFilter.SetFilter("Age Category", CategoryFilter);
                            CategoryFilter := LotAgeFilter.GetFilter("Age Category");
                        end;
                    }
                    field(DaysToExpireFilter; DaysToExpireFilter)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Days to Expire Filter';

                        trigger OnValidate()
                        begin
                            // P8000251A
                            LotAgeFilter.SetFilter("Days to Expire", DaysToExpireFilter);
                            DaysToExpireFilter := LotAgeFilter.GetFilter("Days to Expire");
                        end;
                    }
                    field(LotSpecFilterText; LotSpecFilterText)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Lot Specification Filter';
                        Editable = false;

                        trigger OnAssistEdit()
                        begin
                            if LotFilterFns.LotSpecAssist(LotSpecFilter) then
                                LotSpecFilterText := LotFilterFns.LotSpecText(LotSpecFilter);
                        end;
                    }
                    field(OldestAcceptableDate; OldestAcceptableDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Oldest Acceptable Freshness Date';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        ItemLotAvailabilityCaption = 'Item Lot Availability';
        PageCaption = 'Page';
        QuantityAltCaption = 'Quantity (Alt.)';
        LotFilterFnsAgeCaption = 'Age';
        LotFilterFnsAgeCategoryCaption = 'Age Category';
        LotFilterFnsAgeDateCaption = 'Current Age Date';
        RemDaysTextCaption = 'Remaining Days';
        LotNoInfoInventoryCaption = 'Quantity';
        DaysToExpireTextCaption = 'Days to Expire';
        DateFormatCaption = 'MM/dd/yy';
    }

    trigger OnPreReport()
    begin
        LotInfoFilterText := "Lot No. Information".GetFilters;
        LotAgeFilterText := LotAgeFilter.GetFilters;
        if OldestAcceptableDate <> 0D then                                  // P8001070
            OldestAcceptableText := StrSubstNo(Text002, OldestAcceptableDate); // P8001070

        InvSetup.Get;
        if LotSpecCat.Get(InvSetup."Shortcut Lot Spec. 1 Code") then
            LotSpecCat.Mark(true);
        if LotSpecCat.Get(InvSetup."Shortcut Lot Spec. 2 Code") then
            LotSpecCat.Mark(true);
        if LotSpecCat.Get(InvSetup."Shortcut Lot Spec. 3 Code") then
            LotSpecCat.Mark(true);
        if LotSpecCat.Get(InvSetup."Shortcut Lot Spec. 4 Code") then
            LotSpecCat.Mark(true);
        if LotSpecCat.Get(InvSetup."Shortcut Lot Spec. 5 Code") then
            LotSpecCat.Mark(true);
        LotSpecFilter.Reset;
        if LotSpecFilter.Find('-') then
            repeat
                LotSpecCat.Get(LotSpecFilter."Data Element Code");
                LotSpecCat.Mark(true);
            until LotSpecFilter.Next = 0;
        LotSpecCat.MarkedOnly(true);
    end;

    var
        InvSetup: Record "Inventory Setup";
        Item: Record Item;
        LotSpecCat: Record "Data Collection Data Element";
        LotSpec: Record "Lot Specification";
        LotAgeFilter: Record "Lot Age";
        LotSpecFilter: Record "Lot Specification Filter" temporary;
        LotFilterFns: Codeunit "Lot Filtering";
        RemDays: Integer;
        DaysToExpire: Integer;
        AgeFilter: Text[250];
        CategoryFilter: Text[250];
        DaysToExpireFilter: Text[250];
        RemDaysText: Text[10];
        Text001: Label 'N/A';
        DaysToExpireText: Text[10];
        LotInfoFilterText: Text;
        LotAgeFilterText: Text;
        LotSpecFilterText: Text;
        OldestAcceptableText: Text[100];
        LotSpecText: Text;
        Text002: Label 'Oldest Acceptable Freshness Date: %1';
        OldestAcceptableDate: Date;
        DateFormat: Label 'MM/dd/yy';

    procedure SetLotFilters(var LotAge: Record "Lot Age"; var LotSpec: Record "Lot Specification Filter" temporary; OldestDate: Date)
    begin
        // P8001070 - add parameted for OldestDate
        LotAgeFilter.CopyFilters(LotAge);
        AgeFilter := LotAgeFilter.GetFilter(Age);                       // P8000251A
        CategoryFilter := LotAgeFilter.GetFilter("Age Category");       // P8000251A
        DaysToExpireFilter := LotAgeFilter.GetFilter("Days to Expire"); // P8000251A
        OldestAcceptableDate := OldestDate; // P8001070

        if LotSpec.Find('-') then
            repeat
                LotSpecFilter := LotSpec;
                LotSpecFilter.Insert;
            until LotSpec.Next = 0;
        LotSpecFilterText := LotFilterFns.LotSpecText(LotSpecFilter);
    end;
}

