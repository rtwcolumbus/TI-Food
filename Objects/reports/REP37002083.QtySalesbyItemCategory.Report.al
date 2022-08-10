report 37002083 "Qty. Sales by Item Category" // Version: FOODNA
{
    // PR3.70.10
    // P8000232A, Myers Nissi, Phyllis McGovern, 21 JUL 05
    //   New report added: work done by Steve Post
    // 
    // PR4.00.06
    // P8000472A, VerticalSoft, Jack Reynolds, 21 MAY 07
    //   Fix problem with wrong UOM
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 06 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000837, VerticalSoft, Jack Reynolds, 08 JUL 10
    //   RDLC layout issues
    // 
    // PRW16.00.06
    // P8001102, Columbus IT, Jack Reynolds, 02 OCT 12
    //   Renamed from "Qty. Sales By Item Category"
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
    // 
    // PRW17.10.01
    // P8001254, Columbus IT, Jack Reynolds, 06 JAN 14
    //   Adjust layout to accomodate Letter size paper
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/QtySalesbyItemCategory.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Qty. Sales by Item Category';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Report Header"; "Integer")
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;
            column(CompanyInfoName; CompanyInformation.Name)
            {
            }
            column(OptionDesc; OptionDescription)
            {
            }
            column(CurrYearText; CurrentYearText)
            {
            }
            column(CurrPeriodText; CurrentPeriodText)
            {
            }
            column(LastYearText; LastYearText)
            {
            }
            column(LastYearPeriodText; LastYearPeriodText)
            {
            }
            column(PriorYearText; PriorYearText)
            {
            }
            column(PriorPriorYearText; PriorPriorYearText)
            {
            }
            dataitem("Item Category"; "Item Category")
            {
                DataItemTableView = SORTING(Code);
                PrintOnlyIfDetail = true;
                RequestFilterFields = "Code";
                column(ItemCategoryCode; Code)
                {
                }
                column(ItemCategoryDesc; Description)
                {
                }
                dataitem("Item Ledger Entry"; "Item Ledger Entry")
                {
                    DataItemLink = "Item Category Code" = FIELD(Code);
                    DataItemTableView = SORTING("Item Category Code", "Item No.", "Entry Type") WHERE("Entry Type" = CONST(Sale));
                    column(ILEItemNo; "Item No.")
                    {
                    }
                    column(QuantitySold1; QuantitySold[1])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(Sales1; Sales[1])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(QuantitySold2; QuantitySold[2])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(Sales2; Sales[2])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(QuantitySold3; QuantitySold[3])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(Sales3; Sales[3])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(QuantitySold4; QuantitySold[4])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(Sales4; Sales[4])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(QuantitySold5; QuantitySold[5])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(Sales5; Sales[5])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(QuantitySold6; QuantitySold[6])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(Sales6; Sales[6])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(ItemDesc; Item.Description)
                    {
                    }
                    column(ItemBaseUOM; Item."Base Unit of Measure")
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        i: Integer;
                    begin
                        if "Posting Date" < StartingDate[6] then
                            CurrReport.Skip;
                        if "Posting Date" > EndingDate[2] then
                            CurrReport.Skip;

                        Item.Get("Item No.");
                        if ShowAltUOM and (Item."Alternate Unit of Measure" = '') then
                            CurrReport.Skip;

                        if ShowAltUOM = true then
                            Amount := "Invoiced Quantity (Alt.)"
                        else
                            Amount := "Invoiced Quantity";

                        for i := 1 to ArrayLen(StartingDate) do begin
                            if ("Posting Date" >= StartingDate[i]) and ("Posting Date" <= EndingDate[i]) then begin
                                CalcFields("Sales Amount (Actual)");
                                QuantitySold[i] += -(Amount);
                                Sales[i] += "Sales Amount (Actual)";
                            end;
                        end;

                        // there is code in Item Ledger Entry, GroupFooter (1) - OnPreSection() and
                        //                    Item Ledger Entry, GroupFooter (2) - OnPreSection()
                    end;
                }
            }
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
                    field("EndingDate[1]"; EndingDate[1])
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Ending Date';
                    }
                    field(TimeDivision; TimeDivision)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Length of Period (-1M,-2W,-29D)';
                        MultiLine = false;
                    }
                    field(ShowAltUOM; ShowAltUOM)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Show Amount in Alternate UOM';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if EndingDate[1] = 0D then
                EndingDate[1] := WorkDate;
            if Format(TimeDivision) = '' then
                Evaluate(TimeDivision, '-1M+1D');
        end;
    }

    labels
    {
        SalesbyItemCategoryCaption = 'Sales by Item Category';
        PAGENOCaption = 'Page';
        ItemNoCaption = 'Item No.';
        DescriptionCaption = 'Description';
        UOMCaption = 'UOM';
        QuantityCaption = 'Quantity';
        SalesCaption = 'Sales';
        YearToDateCaption = 'Year To Date';
        ItemCategoryTotalCaption = 'Item Category Total';
        ReportTotalsCaption = 'Report Totals';
    }

    trigger OnPreReport()
    begin

        CompanyInformation.Get;

        // Current Period
        StartingDate[1] := CalcDate(TimeDivision, EndingDate[1]); //RW040730

        CurrentPeriodText := StrSubstNo(Text001, Format(StartingDate[1]), Format(EndingDate[1]));
        OptionDescription := StrSubstNo(Text000, StartingDate[1], EndingDate[1]);

        // Current Year
        Year := Date2DMY(StartingDate[1], 3);
        CurrentYearText := Format(Year);
        StartingDate[2] := DMY2Date(1, 1, Year);
        EndingDate[2] := EndingDate[1];

        // Prior Year Current Period
        StartingDate[3] := CalcDate('-1Y', StartingDate[1]);
        EndingDate[3] := CalcDate('-1Y', EndingDate[1]);
        LastYearPeriodText := StrSubstNo(Text001, Format(StartingDate[3]), Format(EndingDate[3]));

        // Prior Year
        StartingDate[4] := CalcDate('-1Y', StartingDate[2]);
        EndingDate[4] := CalcDate('-1Y', EndingDate[2]);
        Year := Date2DMY(StartingDate[4], 3);
        LastYearText := Format(Year);

        // Current year - 2
        StartingDate[5] := CalcDate('-2Y', StartingDate[2]);
        EndingDate[5] := CalcDate('-1Y', DMY2Date(31, 12, Year));
        Year := Date2DMY(StartingDate[5], 3);
        PriorYearText := Format(Year);

        // Current year - 3
        StartingDate[6] := CalcDate('-3Y', StartingDate[2]);
        EndingDate[6] := CalcDate('-1Y', DMY2Date(31, 12, Year));
        Year := Date2DMY(StartingDate[6], 3);
        PriorPriorYearText := Format(Year);
    end;

    var
        CompanyInformation: Record "Company Information";
        Item: Record Item;
        StartingDate: array[6] of Date;
        EndingDate: array[6] of Date;
        TimeDivision: DateFormula;
        ShowAltUOM: Boolean;
        QuantitySold: array[6] of Decimal;
        ItemCategoryQuantitySold: array[6] of Decimal;
        Sales: array[6] of Decimal;
        ItemCategorySales: array[6] of Decimal;
        Text000: Label 'Current period %1 thru %2';
        OptionDescription: Text[250];
        Year: Integer;
        Amount: Decimal;
        CurrentYearText: Text[30];
        PriorYearText: Text[30];
        LastYearText: Text[30];
        PriorPriorYearText: Text[30];
        CurrentPeriodText: Text[30];
        LastYearPeriodText: Text[30];
        Text001: Label '%1 to %2';
        Text002: Label 'Item Recap';

    procedure ItemLedgerEntry_GroupFooter1(var iILE: Record "Item Ledger Entry")
    var
        i: Integer;
    begin
        with iILE do begin      // P8000812
                                // P8000472A - Item was local
            if Item.Get("Item No.") then
                if ShowAltUOM then
                    Item."Base Unit of Measure" := Item."Alternate Unit of Measure";

            for i := 1 to ArrayLen(ItemCategoryQuantitySold) do begin
                ItemCategoryQuantitySold[i] += QuantitySold[i];
                ItemCategorySales[i] += Sales[i];
            end;
        end;                    // P8000812
    end;

    procedure ItemLedgerEntry_GroupFooter2()
    begin
        Clear(QuantitySold);
        Clear(Sales);
    end;
}

