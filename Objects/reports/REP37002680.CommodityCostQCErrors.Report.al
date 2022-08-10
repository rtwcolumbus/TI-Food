report 37002680 "Commodity Cost Q/C Errors"
{
    // PRW16.00.04
    // P8000856, Columbus IT, Don Bresee, 14 MAR 11
    //   Add Commodity Class Costing granule
    // 
    // PRW16.00.05
    // P8000983, Columbus IT, Jack Reynolds, 30 SEP 11
    //   Fix error looking up Q/C result
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
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
    RDLCLayout = './layout/CommodityCostQCErrors.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Commodity Cost Q/C Errors';
    UsageCategory = Tasks;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("Commodity Cost Item") WHERE("Commodity Cost Item" = CONST(true));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            dataitem(ItemLedgEntry; "Item Ledger Entry")
            {
                DataItemLink = "Item No." = FIELD("No.");
                DataItemTableView = SORTING("Item No.", "Variant Code", "Lot No.", Positive, "Posting Date") WHERE(Positive = CONST(false), "Entry Type" = FILTER(<> Transfer), "Commodity Class Code" = FILTER(<> ''));
                PrintOnlyIfDetail = true;

                trigger OnAfterGetRecord()
                begin
                    TempEntry.SetRange("Variant Code", "Variant Code");
                    TempEntry.SetRange("Lot No.", "Lot No.");
                    TempEntry.SetRange("Commodity Class Code", "Commodity Class Code");
                    if TempEntry.IsEmpty then begin
                        TempEntry := ItemLedgEntry;
                        TempEntry.Insert;
                    end;
                end;

                trigger OnPostDataItem()
                begin
                    TempEntry.Reset;
                    TempEntry.SetCurrentKey("Item No.", "Variant Code", "Lot No.", Positive, "Posting Date");
                end;

                trigger OnPreDataItem()
                begin
                    TempEntry.Reset;
                    TempEntry.DeleteAll;
                    TempEntry.SetCurrentKey("Item No.", "Variant Code", "Lot No.", Positive, "Posting Date");
                    TempEntry.SetRange("Item No.", Item."No.");

                    SetFilter("Posting Date", '%1..', StartDate);
                end;
            }
            dataitem(TempEntryLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                PrintOnlyIfDetail = true;
                dataitem(TempLotLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    PrintOnlyIfDetail = true;

                    trigger OnAfterGetRecord()
                    begin
                        if (Number > 1) then
                            if (TempEntry.Next = 0) then
                                CurrReport.Break;

                        CommCostMgmt.AddTempClassComponents(TempEntry."Commodity Class Code", TempCostComponent);
                    end;

                    trigger OnPostDataItem()
                    begin
                        TempEntry.SetRange("Item No.");
                        TempEntry.SetRange("Variant Code");
                        TempEntry.SetRange("Lot No.");
                    end;

                    trigger OnPreDataItem()
                    begin
                        TempCostComponent.DeleteAll;

                        SetFilter(Number, '1..');

                        TempEntry.SetRange("Item No.", TempEntry."Item No.");
                        TempEntry.SetRange("Variant Code", TempEntry."Variant Code");
                        TempEntry.SetRange("Lot No.", TempEntry."Lot No.");
                    end;
                }
                dataitem(TempCompLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    column(TempEntryLotNo; TempEntry."Lot No.")
                    {
                    }
                    column(TempCostComponentQCTestType; TempCostComponent."Q/C Test Type")
                    {
                    }
                    column(QCErrorText; QCErrorText)
                    {
                    }
                    column(TempEntryVariantCode; TempEntry."Variant Code")
                    {
                    }
                    column(TempEntryItemNo; TempEntry."Item No.")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if (Number = 1) then begin
                            if not TempCostComponent.FindSet then
                                CurrReport.Break;
                        end else begin
                            if (TempCostComponent.Next = 0) then
                                CurrReport.Break;
                        end;

                        if not CommCostMgmt.GetQCTestError(
                                 TempEntry."Item No.", TempEntry."Variant Code", TempEntry."Lot No.",
                                 TempCostComponent."Q/C Test Type", QCErrorText) // P8000983
                        then
                            CurrReport.Skip;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetFilter(Number, '1..');
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if (Number = 1) then begin
                        if not TempEntry.FindSet then
                            CurrReport.Break;
                    end else begin
                        if (TempEntry.Next = 0) then
                            CurrReport.Break;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    SetFilter(Number, '1..');
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
                    field(StartDate; StartDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Start Date';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        var
            CommCostPeriod: Record "Commodity Cost Period";
        begin
            CommCostPeriod.SetRange("Calculate Cost", true);
            if CommCostPeriod.IsEmpty then
                CommCostPeriod.SetRange("Calculate Cost");
            if CommCostPeriod.FindSet then
                repeat
                    if (StartDate = 0D) or (StartDate > CommCostPeriod."Starting Market Date") then
                        StartDate := CommCostPeriod."Starting Market Date";
                until (CommCostPeriod.Next = 0);
        end;
    }

    labels
    {
        PageNoCaption = 'Page';
        AssetCaption = 'Commodity Cost Q/C Errors';
        QCErrorTextCaption = 'Q/C Problem Description';
        LotNoCaption = 'Lot No.';
        QCTestTypeCaption = 'Q/C Test Type';
        VariantCodeCaption = 'Variant Code';
        ItemNoCaption = 'Item No.';
    }

    var
        StartDate: Date;
        TempEntry: Record "Item Ledger Entry" temporary;
        TempCostComponent: Record "Comm. Cost Component" temporary;
        QCErrorText: Text[250];
        CommCostMgmt: Codeunit "Commodity Cost Management";
}

