report 37002082 "Qty. Sales by Customer/Item" // Version: FOODNA
{
    // PR3.70.10
    // P8000231A, Myers Nissi, Phyllis McGovern, 21 JUL 05
    //   New report added: work done by Steve Post
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Changes to Item Ledger keys
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 06 APR 10
    //   RTC Reporting Upgrade
    // 
    // P8000831, VerticalSoft, Jack Reynolds, 08 JUN 10
    //   fix problem with missing data for prior years
    // 
    // PRW16.00.04
    // P8000837, VerticalSoft, Jack Reynolds, 08 JUL 10
    //   RDLC layout issues
    // 
    // PRW16.00.06
    // P8001120, Columbus IT, Jack Reynolds, 13 DEC 12
    //   Fix problem with recap totals
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
    RDLCLayout = './layout/QtySalesbyCustomerItem.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Qty. Sales by Customer/Item';
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
            column(RecapTitle; RecapTitle)
            {
            }
            column(SalesRecap; SalesRecap)
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
            dataitem(Customer; Customer)
            {
                DataItemTableView = SORTING("No.");
                PrintOnlyIfDetail = true;
                RequestFilterFields = "No.", "Global Dimension 1 Code", "Salesperson Code";
                column(CustName; Name)
                {
                }
                column(CustNo; "No.")
                {
                }
                dataitem("Item Ledger Entry"; "Item Ledger Entry")
                {
                    DataItemLink = "Source No." = FIELD("No.");
                    DataItemTableView = SORTING("Entry Type", "Item No.", "Variant Code", "Source Type", "Source No.", "Posting Date") ORDER(Ascending) WHERE("Source Type" = CONST(Customer), "Entry Type" = CONST(Sale));
                    RequestFilterFields = "Item No.";
                    column(ILEItemDescription; Item.Description)
                    {
                    }
                    column(ILEItemNo; "Item No.")
                    {
                    }
                    column(ILEQuantitySold1; QuantitySold[1])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(ILESales1; Sales[1])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(ILEQuantitySold2; QuantitySold[2])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(ILESales2; Sales[2])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(ILEQuantitySold3; QuantitySold[3])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(ILESales3; Sales[3])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(ILEQuantitySold4; QuantitySold[4])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(ILESales4; Sales[4])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(ILEQuantitySold5; QuantitySold[5])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(ILESales5; Sales[5])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(ILEQuantitySold6; QuantitySold[6])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(ILESales6; Sales[6])
                    {
                        DecimalPlaces = 0 : 0;
                    }
                    column(ILEItemBaseUOM; Item."Base Unit of Measure")
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        i: Integer;
                        AddToRecap: Boolean;
                        changeOfItem: Boolean;
                        backup: array[6] of Decimal;
                        backup1: array[6] of Decimal;
                    begin
                        // P8000812 S
                        if IsServiceTier then begin
                            ILE2 := "Item Ledger Entry";
                            if ILE2.Next = 0 then
                                changeOfItem := true
                            else
                                changeOfItem := ILE2."Item No." <> "Item No.";
                            // P8001120
                            //  IF changeOfItem THEN BEGIN
                            //
                            //    FOR i := 1 TO ARRAYLEN(backup) DO
                            //      backup[i] := ItemQuantitySold[i];
                            //    FOR i := 1 TO ARRAYLEN(backup1) DO
                            //      backup1[i] := ItemSales[i];
                            //    CLEAR(ItemQuantitySold);
                            //    CLEAR(ItemSales);
                            //    ILEGroupFooter1("Item Ledger Entry");
                            //    FOR i := 1 TO ARRAYLEN(backup) DO
                            //      ItemQuantitySold[i] := backup[i];
                            //    FOR i := 1 TO ARRAYLEN(backup1) DO
                            //      ItemSales[i] := backup1[i];
                            //  END;
                            // P8001120
                        end;
                        // P8000812 E

                        // P8000812 S
                        if "Posting Date" < StartingDate[6] then begin
                            if IsServiceTier then begin
                                // P8001120
                                //    ILE2 := "Item Ledger Entry";
                                //    IF (ILE2.NEXT = 0) THEN BEGIN
                                if changeOfItem then begin
                                    // P8001120
                                    ILEGroupFooter1("Item Ledger Entry");
                                    Clear(ItemQuantitySold);
                                    Clear(ItemSales);
                                end;
                            end;
                            // P8000812 E
                            CurrReport.Skip;
                        end;
                        if "Posting Date" > EndingDate[2] then begin
                            if IsServiceTier then begin
                                // P8001120
                                //    ILE2 := "Item Ledger Entry";
                                //    IF (ILE2.NEXT = 0) THEN BEGIN
                                if changeOfItem then begin
                                    // P8001120
                                    ILEGroupFooter1("Item Ledger Entry");
                                    Clear(ItemQuantitySold);
                                    Clear(ItemSales);
                                end;
                            end;
                            // P8000812 E
                            CurrReport.Skip;
                        end;

                        Item.Get("Item No.");
                        if ShowAltUOM and (Item."Alternate Unit of Measure" = '') then begin
                            if IsServiceTier then begin
                                // P8001120
                                //    ILE2 := "Item Ledger Entry";
                                //    IF (ILE2.NEXT = 0) THEN BEGIN
                                if changeOfItem then begin
                                    // P8001120
                                    ILEGroupFooter1("Item Ledger Entry");
                                    Clear(ItemQuantitySold);
                                    Clear(ItemSales);
                                end;
                            end;
                            // P8000812 E
                            CurrReport.Skip;
                        end;

                        if ShowAltUOM = true then
                            Amount := "Invoiced Quantity (Alt.)"
                        else
                            Amount := "Invoiced Quantity";

                        for i := 1 to ArrayLen(StartingDate) do
                            if ("Posting Date" >= StartingDate[i]) and ("Posting Date" <= EndingDate[i]) then begin
                                CalcFields("Sales Amount (Actual)");
                                QuantitySold[i] += -(Amount);
                                Sales[i] += "Sales Amount (Actual)";

                                ItemQuantitySold[i] += -(Amount);          // P8000812
                                ItemSales[i] += "Sales Amount (Actual)";   // P8000812

                            end;

                        // there is code in Item Ledger Entry, GroupFooter (1) - OnPreSection() and
                        //                    Item Ledger Entry, GroupFooter (2) - OnPreSection()

                        // P8000812 S
                        if IsServiceTier then begin
                            // P8001120
                            //  ILE2 := "Item Ledger Entry";
                            //  IF (ILE2.NEXT = 0) THEN
                            //    changeOfItem := TRUE
                            //  ELSE IF ILE2."Item No." <> "Item No." THEN
                            //    changeOfItem := TRUE;
                            // P8001120
                            if changeOfItem then begin
                                ILEGroupFooter1("Item Ledger Entry");
                                Clear(ItemQuantitySold);
                                Clear(ItemSales);
                            end;
                        end;
                        // P8000812 E
                    end;

                    trigger OnPreDataItem()
                    begin
                        Clear(ILE2);
                        Clear(ItemQuantitySold);
                        Clear(ItemSales);
                        ILE2.Copy("Item Ledger Entry");
                    end;
                }
            }
            dataitem(RecapByItem; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(RecapByItemQuantitySold1; QuantitySold[1])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(RecapByItemSales1; Sales[1])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(RecapByItemQuantitySold2; QuantitySold[2])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(RecapByItemSales2; Sales[2])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(RecapByItemQuantitySold3; QuantitySold[3])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(RecapByItemSales3; Sales[3])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(RecapByItemQuantitySold4; QuantitySold[4])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(RecapByItemSales4; Sales[4])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(RecapByItemQuantitySold5; QuantitySold[5])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(RecapByItemSales5; Sales[5])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(RecapByItemQuantitySold6; QuantitySold[6])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(RecapByItemSales6; Sales[6])
                {
                    DecimalPlaces = 0 : 0;
                }
                column(RecapByItemItemBaseUOM; Item."Base Unit of Measure")
                {
                }
                column(RecapByItemItemDescription; Item.Description)
                {
                }
                column(RecapByItemItemNo; Item."No.")
                {
                }
                column(RecapByItemNumber; Number)
                {
                }

                trigger OnAfterGetRecord()
                var
                    i: Integer;
                begin
                    if Number = 1 then begin
                        ItemRecapSales.Find('-');
                        ItemRecapQty.Find('-');
                    end;

                    if Item.Get(ItemRecapQty.Key1) then
                        if ShowAltUOM then
                            Item."Base Unit of Measure" := Item."Alternate Unit of Measure";

                    Clear(Sales);
                    Clear(QuantitySold);
                    for i := 1 to 6 do begin
                        Sales[ItemRecapSales."Data Element"] := ItemRecapSales.Value;
                        ItemRecapSales.Next;

                        QuantitySold[ItemRecapQty."Data Element"] := ItemRecapQty.Value;
                        ItemRecapQty.Next;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    if SalesRecap = false then
                        //CurrReport.QUIT;  // P8000812
                        CurrReport.Break;   // P8000812

                    RecapTitle := Text002;
                    CurrReport.NewPage;

                    Clear(TotalQuantitySold);
                    Clear(TotalSales);
                    ItemRecapSales.Reset;
                    ItemRecapQty.Reset;
                    SetRange(Number, 1, ItemRecapQty.Count / 6);

                    ItemRecapSales.SetRange(Key1);
                    ItemRecapQty.SetRange(Key1);
                end;
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
                    field(SalesRecap; SalesRecap)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Print Sales Recap';
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
        SalesbyCustomerItemCaption = 'Sales by Customer/Item';
        PAGENOCaption = 'Page';
        ItemNoCaption = 'Item No.';
        DescriptionCaption = 'Description';
        YearToDateCaption = 'Year To Date';
        QuantityCaption = 'Quantity';
        SalesCaption = 'Sales';
        UOMCaption = 'UOM';
        CustomerTotalCaption = 'Customer Total';
        ReportTotalsCaption = 'Report Totals';
        RecapTotalsCaption = 'Recap Totals';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get;
        // Current Period
        StartingDate[1] := CalcDate(TimeDivision, EndingDate[1]);

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
        EndingDate[5] := CalcDate('-1Y', DMY2Date(31, 12, Year)); // P8000831
        Year := Date2DMY(StartingDate[5], 3);
        PriorYearText := Format(Year);

        // Current year - 3
        StartingDate[6] := CalcDate('-3Y', StartingDate[2]);
        EndingDate[6] := CalcDate('-1Y', DMY2Date(31, 12, Year)); // P8000831
        Year := Date2DMY(StartingDate[6], 3);
        PriorPriorYearText := Format(Year);

        ItemRecapQty.Reset;
        ItemRecapQty.DeleteAll;
        ItemRecapSales.Reset;
        ItemRecapSales.DeleteAll;
    end;

    var
        CompanyInformation: Record "Company Information";
        ItemRecapQty: Record "Report Summary Data" temporary;
        ItemRecapSales: Record "Report Summary Data" temporary;
        Item: Record Item;
        StartingDate: array[6] of Date;
        EndingDate: array[6] of Date;
        TimeDivision: DateFormula;
        SalesRecap: Boolean;
        ShowAltUOM: Boolean;
        QuantitySold: array[6] of Decimal;
        CustomerQuantitySold: array[6] of Decimal;
        TotalQuantitySold: array[6] of Decimal;
        Sales: array[6] of Decimal;
        CustomerSales: array[6] of Decimal;
        TotalSales: array[6] of Decimal;
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
        RecapTitle: Text[30];
        Text002: Label 'Item Recap';
        ILE2: Record "Item Ledger Entry";
        ItemQuantitySold: array[6] of Decimal;
        ItemSales: array[6] of Decimal;

    procedure ILEGroupFooter1(var iILE: Record "Item Ledger Entry")
    var
        AddToRecap: Boolean;
        i: Integer;
    begin
        with iILE do begin

            //if "Item no." = 'C1010-CW' then
            //  if isservicetier then
            //    message('Entry No. %1, Sold %2 > %3',"entry no.",itemquantitysold[1],itemquantitysold[2])
            //  else
            //    message('Entry No. %1, Sold %2 > %3',"entry no.",quantitysold[1],quantitysold[2]);
            if Item.Get("Item No.") then
                if ShowAltUOM then
                    Item."Base Unit of Measure" := Item."Alternate Unit of Measure";
            AddToRecap := SalesRecap and
              ((not ShowAltUOM) or (ShowAltUOM and (Item."Alternate Unit of Measure" <> '')));
            ItemRecapQty.Key1 := "Item No.";
            ItemRecapSales.Key1 := "Item No.";
            for i := 1 to ArrayLen(CustomerQuantitySold) do begin
                if AddToRecap then begin
                    ItemRecapQty."Data Element" := i;
                    if IsServiceTier then
                        ItemRecapQty.AddValue(ItemQuantitySold[i])
                    else
                        ItemRecapQty.AddValue(QuantitySold[i]);
                end;
                if IsServiceTier then
                    CustomerQuantitySold[i] += ItemQuantitySold[i]
                else
                    CustomerQuantitySold[i] += QuantitySold[i];

                if AddToRecap then begin
                    ItemRecapSales."Data Element" := i;
                    if IsServiceTier then
                        ItemRecapSales.AddValue(ItemSales[i])
                    else
                        ItemRecapSales.AddValue(Sales[i]);
                end;
                if IsServiceTier then
                    CustomerSales[i] += ItemSales[i]
                else
                    CustomerSales[i] += Sales[i];
            end;
        end;
    end;

    procedure ILEGroupFooter2()
    begin
        Clear(QuantitySold);
        Clear(Sales);
    end;
}

