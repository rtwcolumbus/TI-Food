report 37002686 "Commodity Payment Q/C Errors"
{
    // PRW16.00.04
    // P8000902, Columbus IT, Don Bresee, 14 MAR 11
    //   Add Commodity Payment logic
    // 
    // PRW16.00.05
    // P8000983, Columbus IT, Jack Reynolds, 30 SEP 11
    //   Fix error looking up Q/C result
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
    RDLCLayout = './layout/CommodityPaymentQCErrors.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Commodity Payment Q/C Errors';
    UsageCategory = Tasks;

    dataset
    {
        dataitem(PurchOrder; "Purchase Header")
        {
            DataItemTableView = SORTING("Buy-from Vendor No.", "Pay-to Vendor No.", "Commodity Item No.", "Commodity P.O. Type") WHERE("Commodity Manifest Order" = CONST(true), "Commodity Item No." = FILTER(<> ''), "Commodity P.O. Type" = FILTER(Producer | Broker));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Buy-from Vendor No.", "Pay-to Vendor No.", "Commodity Item No.", "Commodity P.O. Type";
            RequestFilterHeading = 'Purchase Order';
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(STRNoBuyfromVendNoName; StrSubstNo(Text000, "No.", "Buy-from Vendor No.", "Buy-from Vendor Name"))
            {
            }
            column(PurchOrderDocType; "Document Type")
            {
            }
            dataitem(PurchOrderLine; "Purchase Line")
            {
                DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") WHERE("Commodity Manifest No." = FILTER(<> ''));
                PrintOnlyIfDetail = true;
                column(PurchOrderLineDocNo; "Document No.")
                {
                }
                dataitem(TempCompLoop2; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    column(QCErrorText; QCErrorText)
                    {
                    }
                    column(PurchOrderLineCommodityRcvdLotNo; PurchOrderLine."Commodity Received Lot No.")
                    {
                    }
                    column(TempCostComponentQCTestType; TempCostComponent."Q/C Test Type")
                    {
                    }
                    column(PurchOrderLineVariantCode; PurchOrderLine."Variant Code")
                    {
                    }
                    column(PurchOrderLineNo; PurchOrderLine."No.")
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
                                 PurchOrderLine."No.", PurchOrderLine."Variant Code",
                                 PurchOrderLine."Commodity Received Lot No.", TempCostComponent."Q/C Test Type", QCErrorText) // P8000983
                        then
                            CurrReport.Skip;
                    end;

                    trigger OnPreDataItem()
                    begin
                        TempCostComponent.DeleteAll;
                        CommCostMgmt.AddTempClassComponents(
                          PurchOrderLine."Comm. Payment Class Code", TempCostComponent);

                        SetFilter(Number, '1..');
                    end;
                }

                trigger OnPreDataItem()
                begin
                    SetFilter("Commodity Received Date", '%1..', StartDate);
                end;
            }
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
    }

    labels
    {
        QCErrorTextCaption = 'Q/C Problem Description';
        LotNoCaption = 'Lot No.';
        QCTestTypeCaption = 'Q/C Test Type';
        VariantCodeCaption = 'Variant Code';
        ItemNoCaption = 'Item No.';
        PageNoCaption = 'Page';
        AssetCaption = 'Commodity Payment Q/C Errors';
    }

    var
        StartDate: Date;
        TempCostComponent: Record "Comm. Cost Component" temporary;
        QCErrorText: Text[250];
        Text000: Label 'Order: %1 / Producer: %2 - %3';
        CommCostMgmt: Codeunit "Commodity Cost Management";
}

