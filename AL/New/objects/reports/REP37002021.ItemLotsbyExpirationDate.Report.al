report 37002021 "Item Lots by Expiration Date"
{
    // PR1.10, Navision US, John Nozzi, 29 MAR 01, New Object
    //   This report is used to list out all lots whose Q/C Status is completed, sorted by Expiration Date.
    // 
    // PR2.00
    //   Modify for Lot No. Information
    // 
    // PRW16.00.03
    // P8000813, VerticalSoft, MMAS, 14 APR 10
    //   Report design for RTC
    //     1. Various fields formatting
    //     2. Fields' locations changes
    // 
    // PRW16.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW17.10
    // P8001223, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Expand filter variables
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    DefaultRenderingLayout = StandardRDLCLayout;

    ApplicationArea = FOODBasic;
    Caption = 'Item Lots by Expiration Date';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = WHERE("Item Tracking Code" = FILTER(<> ''));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Item Type";
            column(PageNo; CurrReport.PageNo)
            {
            }
            column(CompanyInfoName; CompanyInformation.Name)
            {
            }
            column(ItemTabCapFilterString; TableCaption + ': ' + FilterString)
            {
            }
            column(FilterString; FilterString)
            {
            }
            column(ItemNo; "No.")
            {
            }
            column(ItemDesc; Description)
            {
            }
            column(ItemQuarantineCalc; "Quarantine Calculation")
            {
                IncludeCaption = true;
            }
            column(ItemExpirationCalc; "Expiration Calculation")
            {
                IncludeCaption = true;
            }
            column(ItemBaseUOM; "Base Unit of Measure")
            {
                IncludeCaption = true;
            }
            dataitem("Lot No. Information"; "Lot No. Information")
            {
                CalcFields = Inventory;
                DataItemLink = "Item No." = FIELD("No.");
                DataItemTableView = SORTING("Item No.", "Variant Code", "Lot No.") WHERE("Expiration Date" = FILTER(<> 0D));
                RequestFilterFields = "Variant Code", "Lot No.", "Expiration Date";
                column(LotInfoLotNo; "Lot No.")
                {
                }
                column(LotInfoDocNo; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(LotInfoReleaseDate; Format("Release Date"))
                {
                }
                column(LotInfoExpirationDate; Format("Expiration Date"))
                {
                }
                column(LotInfoVariantCode; "Variant Code")
                {
                }
                column(LotInfoInventory; Inventory)
                {
                    IncludeCaption = true;
                }

                trigger OnAfterGetRecord()
                begin
                    if Inventory < 0 then
                        CurrReport.Skip;
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    rendering
    {
        layout(StandardRDLCLayout)
        {
            Summary = 'Standard Layout';
            Type = RDLC;
            LayoutFile = './layout/ItemLotsbyExpirationDate.rdlc';
        }
    }

    labels
    {
        PageCaption = 'Page';
        ReportCaption = 'Item Lots by Expiration Date';
        ItemNoLotNoCaption = 'Item No.\  Lot No.';
        DescVariantCodeCaption = 'Description\  Variant Code';
        ReleaseDateCaption = 'Release Date';
        ExpirationDateCaption = 'Expiration Date';
        TotQtyCaption = 'Total Quantity';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get;
        FilterString := Item.GetFilters;
    end;

    var
        CompanyInformation: Record "Company Information";
        FilterString: Text;
}

