report 37002023 "Cert. of Analysis by Shipment"
{
    // PRW16.00.05
    // P8000966, Columbus IT, Jack Reynolds, 20 JUL 11
    //   Prints all certificates of analysis by shipments
    // 
    // PRW17.10.02
    // P8001304, Columbus IT, Jack Reynolds, 12 MAR 14
    //   Fix layout issues with header data
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/CertofAnalysisbyShipment.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Certificate of Analysis by Shipment';
    UsageCategory = Documents;

    dataset
    {
        dataitem("Sales Shipment Header"; "Sales Shipment Header")
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Sell-to Customer No.";
            column(SalesShpmtHdrNo; "No.")
            {
            }
            dataitem("Item Entry Relation"; "Item Entry Relation")
            {
                DataItemLink = "Source ID" = FIELD("No.");
                DataItemLinkReference = "Sales Shipment Header";
                DataItemTableView = SORTING("Source ID", "Source Type", "Source Subtype", "Source Ref. No.", "Source Prod. Order Line", "Source Batch Name") WHERE("Source Type" = CONST(111), "Source Subtype" = CONST("0"));

                trigger OnAfterGetRecord()
                begin
                    ShipmentLine.Get("Source ID", "Source Ref. No.");
                    LotSpec.SetRange("Item No.", ShipmentLine."No.");
                    LotSpec.SetRange("Variant Code", ShipmentLine."Variant Code");
                    LotSpec.SetRange("Lot No.", "Item Entry Relation"."Lot No.");
                    if not LotSpec.IsEmpty then begin
                        LotInfoTemp."Item No." := ShipmentLine."No.";
                        LotInfoTemp."Variant Code" := ShipmentLine."Variant Code";
                        LotInfoTemp."Lot No." := "Item Entry Relation"."Lot No.";
                        Item.Get(ShipmentLine."No.");
                        LotInfoTemp.Description := Item.Description;
                        if LotInfoTemp.Insert then;
                    end;

                    CurrReport.Skip;
                end;

                trigger OnPreDataItem()
                begin
                    LotInfo.Reset;

                    LotInfoTemp.Reset;
                    LotInfoTemp.DeleteAll;

                    LotSpec.SetRange("Certificate of Analysis", true);
                end;
            }
            dataitem(Lot; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(LotInfoTempItemNo; LotInfoTemp."Item No.")
                {
                }
                column(LotInfoTempDesc; LotInfoTemp.Description)
                {
                }
                column(LotInfoTempVariantCode; LotInfoTemp."Variant Code")
                {
                }
                column(LotInfoTempLotNo; LotInfoTemp."Lot No.")
                {
                }
                column(ShipToAddr8; ShipToAddr[8])
                {
                }
                column(ShipToAddr7; ShipToAddr[7])
                {
                }
                column(ShipToAddr6; ShipToAddr[6])
                {
                }
                column(ShipToAddr5; ShipToAddr[5])
                {
                }
                column(ShipToAddr4; ShipToAddr[4])
                {
                }
                column(ShipToAddr3; ShipToAddr[3])
                {
                }
                column(ShipToAddr2; ShipToAddr[2])
                {
                }
                column(SalesShpmtHdrSelltoCustNo; "Sales Shipment Header"."Sell-to Customer No.")
                {
                }
                column(ShipToAddr1; ShipToAddr[1])
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        LotInfoTemp.FindSet
                    else
                        LotInfoTemp.Next;

                    LotInfo.Get(LotInfoTemp."Item No.", LotInfoTemp."Variant Code", LotInfoTemp."Lot No.");
                    LotInfo.Mark(true);
                end;

                trigger OnPostDataItem()
                var
                    CertOfAnalysis: Report "Certificate of Analysis";
                begin
                    if not CurrReport.Preview then begin
                        LotInfo.MarkedOnly(true);
                        CertOfAnalysis.SetTableView(LotInfo);
                        CertOfAnalysis.UseRequestPage(false);
                        CertOfAnalysis.Run;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, LotInfoTemp.Count);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                FormatAddr.SalesShptShipTo(ShipToAddr, "Sales Shipment Header");
            end;
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
        LotInfoTempLotNoCaption = 'Lot No.';
        LotInfoTempVariantCodeCaption = 'Variant';
        LotInfoTempDescriptionCaption = 'Description';
        LotInfoTempItemNoCaption = 'Item No.';
        SalesShipmtHdrSelltoCustomerNoCaption = 'Customer No.';
        SalesShipmtHdrNoCaption = 'Shipment No.';
        ReportCaption = 'Certificates of Analysis';
    }

    var
        LotInfo: Record "Lot No. Information";
        LotInfoTemp: Record "Lot No. Information" temporary;
        LotSpec: Record "Lot Specification";
        ShipmentLine: Record "Sales Shipment Line";
        Item: Record Item;
        FormatAddr: Codeunit "Format Address";
        ShipToAddr: array[8] of Text[100];
}

