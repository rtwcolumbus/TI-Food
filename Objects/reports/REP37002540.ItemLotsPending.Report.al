report 37002540 "Item Lots Pending" // Version: FOODNA
{
    // PR1.10, Navision US, John Nozzi, 29 MAR 01, New Object
    //   This report is used to list out all lots whose Q/C Status is not yet completed.
    // 
    // PR2.00
    //   Modify for Lot No. Information and Quality Control Header
    // 
    // PRW16.00.03
    // P8000816, VerticalSoft, Jack Reynolds, 21 APR 10
    //   Fix problem with totaling of quantity pending Q/C
    // 
    // PRW16.00.04
    // P8000837, VerticalSoft, Jack Reynolds, 07 JUL 10
    //   RDLC layout issues
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
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/ItemLotsPending.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Item Lots Pending';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = WHERE("Item Tracking Code" = FILTER(<> ''));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Item Type";
            column(CompanyInfoName; CompanyInformation.Name)
            {
            }
            column(ItemTabCapFilterString; TableCaption + ': ' + FilterString)
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
                CalcFields = Inventory, "Quality Control";
                DataItemLink = "Item No." = FIELD("No.");
                DataItemTableView = SORTING("Item No.", "Variant Code", "Lot No.");
                PrintOnlyIfDetail = true;
                column(LotInfoItemNo; "Item No.")
                {
                }
                column(OnHand; OnHand)
                {
                    DecimalPlaces = 0 : 5;
                }
                column(LotInfoVariantCode; "Variant Code")
                {
                }
                column(LotInfoLotNo; "Lot No.")
                {
                }
                dataitem("Quality Control Header"; "Quality Control Header")
                {
                    DataItemLink = "Item No." = FIELD("Item No."), "Variant Code" = FIELD("Variant Code"), "Lot No." = FIELD("Lot No.");
                    DataItemTableView = SORTING("Item No.", "Variant Code", "Lot No.", "Test No.") WHERE(Status = FILTER(Pending));
                    column(QCHeaderScheduleDate; "Schedule Date")
                    {
                        IncludeCaption = true;
                    }
                    column(QCHeaderAssignedTo; "Assigned To")
                    {
                        IncludeCaption = true;
                    }
                    column(QCHeaderTestNo; "Test No.")
                    {
                        IncludeCaption = true;
                    }
                    column(QCHeaderLotNo; "Lot No.")
                    {
                    }
                    column(QCHeaderDocumentNo; "Document No.")
                    {
                        IncludeCaption = true;
                    }
                    column(QCHeaderStatus; Status)
                    {
                        IncludeCaption = true;
                    }
                    column(QCHeaderExpectedReleaseDate; "Expected Release Date")
                    {
                        IncludeCaption = true;
                    }
                    column(QCHeaderQuantityonHand; "Quantity on Hand")
                    {
                        DecimalPlaces = 0 : 5;
                        IncludeCaption = true;
                    }
                    column(QCHeaderVariantCode; "Variant Code")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        // P8000816
                        if FirstTestNo = 0 then begin
                            FirstTestNo := "Test No.";
                            OnHand := "Quantity on Hand";
                        end;
                        // P8000816
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if (not "Quality Control") or (Inventory < 0) then
                        CurrReport.Skip;
                    FirstTestNo := 0; // P8000816
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

    labels
    {
        DatesFormat = 'MM/dd/yy';
        PageNoCaption = 'Page';
        ItemLotsPendingQCCaption = 'Item Lots Pending Q/C';
        ItemLotNoCaption = 'Item No.\  Lot No.';
        DescVariantCodeCaption = 'Description\  Variant Code';
        TotalQuantityPendingQCCaption = 'Total Quantity Pending Q/C';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get;
        FilterString := Item.GetFilters;
    end;

    var
        CompanyInformation: Record "Company Information";
        FilterString: Text;
        FirstTestNo: Integer;
        OnHand: Decimal;
}

