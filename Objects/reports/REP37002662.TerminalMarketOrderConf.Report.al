report 37002662 "Terminal Market Order Conf."
{
    // PRW16.00.05
    // P8000970, Columbus IT, Jack Reynolds, 12 AUG 11
    //   Order confirmation for terminal market orders
    // 
    // PRW18.00
    // P8001352, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Change PreviewMode property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/TerminalMarketOrderConf.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Terminal Market Order Confirmation';
    PreviewMode = PrintLayout;
    UsageCategory = Documents;

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = SORTING("Document Type", "No.") WHERE("Document Type" = CONST(Order));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Sell-to Customer No.", "Order Date";
            column(SellToAddress8; SellToAddress[8])
            {
            }
            column(CompanyAddress8; CompanyAddress[8])
            {
            }
            column(CompanyAddress7; CompanyAddress[7])
            {
            }
            column(SellToAddress7; SellToAddress[7])
            {
            }
            column(CompanyAddress6; CompanyAddress[6])
            {
            }
            column(SellToAddress6; SellToAddress[6])
            {
            }
            column(PaymentTermsDesc; PaymentTerms.Description)
            {
            }
            column(CompanyAddress5; CompanyAddress[5])
            {
            }
            column(SellToAddress5; SellToAddress[5])
            {
            }
            column(SalesHeaderExtDocNo; "Sales Header"."External Document No.")
            {
            }
            column(CompanyAddress3; CompanyAddress[3])
            {
            }
            column(CompanyAddress4; CompanyAddress[4])
            {
            }
            column(SellToAddress3; SellToAddress[3])
            {
            }
            column(SellToAddress4; SellToAddress[4])
            {
            }
            column(SalesHeaderSalespersonCode; "Sales Header"."Salesperson Code")
            {
            }
            column(SalesHeaderSelltoCustNo; "Sales Header"."Sell-to Customer No.")
            {
            }
            column(CompanyAddress1; CompanyAddress[1])
            {
            }
            column(CompanyAddress2; CompanyAddress[2])
            {
            }
            column(SellToAddress1; SellToAddress[1])
            {
            }
            column(SellToAddress2; SellToAddress[2])
            {
            }
            column(SalesHeaderNo; "Sales Header"."No.")
            {
            }
            column(SalesHeaderOrderDate; "Sales Header"."Order Date")
            {
                IncludeCaption = true;
            }
            column(CompanyInfoPicture; CompanyInfo.Picture)
            {
            }
            column(CopyText; CopyText)
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                dataitem("Sales Line"; "Sales Line")
                {
                    DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                    DataItemLinkReference = "Sales Header";
                    DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") WHERE(Type = CONST(Item), Quantity = FILTER(> 0));
                    column(SalesLineNo; "No.")
                    {
                    }
                    column(SalesLineDesc; Description)
                    {
                        IncludeCaption = true;
                    }
                    column(SalesLineVariantCode; "Variant Code")
                    {
                    }
                    column(Qty; Qty)
                    {
                        DecimalPlaces = 0 : 5;
                    }
                    column(SalesLineUnitPrice; "Unit Price")
                    {
                    }
                    column(SalesLineAmount; "Line Amount")
                    {
                    }
                    column(UOM; UOM)
                    {
                    }
                    column(LotData3; LotData[3])
                    {
                    }
                    column(LotData1; LotData[1])
                    {
                    }
                    column(LotData2; LotData[2])
                    {
                    }
                    column(CopyLoopNumber; CopyLoop.Number)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Item.Get("No.");
                        if Item.CostInAlternateUnits then begin
                            Qty := "Quantity (Alt.)";
                            UOM := Item."Alternate Unit of Measure";
                        end else begin
                            Qty := Quantity;
                            UOM := "Unit of Measure Code";
                        end;

                        Clear(LotData);
                        case SalesSetup."Terminal Market Item Level" of
                            SalesSetup."Terminal Market Item Level"::Lot:
                                begin
                                    TermMktFns.GetSalesLineLotInfo("Sales Line", LotInfo);
                                    LotData[1] := StrSubstNo('%1: %2', FieldCaption("Lot No."), "Lot No.");
                                    if LotInfo."Country/Region of Origin Code" <> '' then
                                        LotData[2] := StrSubstNo(Text002, LotInfo."Country/Region of Origin Code");
                                    if LotInfo.Brand <> '' then
                                        LotData[3] := StrSubstNo('%1: %2', LotInfo.FieldCaption(Brand), LotInfo.Brand);
                                end;
                            SalesSetup."Terminal Market Item Level"::"Item/Variant/Country of Origin":
                                if "Country/Region of Origin Code" <> '' then
                                    LotData[2] := StrSubstNo(Text002, "Country/Region of Origin Code");
                        end;
                        CompressArray(LotData);
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 0 then
                        CopyText := ''
                    else
                        CopyText := StrSubstNo(Text001, Number);
                end;

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 0, NoOfcopies);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                FormatAddress.SalesHeaderSellTo(SellToAddress, "Sales Header");
                if not PaymentTerms.Get("Payment Terms Code") then
                    Clear(PaymentTerms);
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
                    field(NoOfcopies; NoOfcopies)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'No. of Copies';
                        MinValue = 0;
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
        PaymentTermsDescCaption = 'Terms';
        CustomerPONoCaption = 'Customer PO No.';
        SalespersonCodeCaption = 'Salesperson';
        CustomerNoCaption = 'Customer No.';
        OrderNoCaption = 'Order No.';
        OrderConfirmationCaption = 'Order Confirmation';
        ItemNoCaption = 'Item No.';
        VariantCodeCaption = 'Variant';
        QtyCaption = 'Quantity';
        UnitPriceCaption = 'Unit Price';
        AmountCaption = 'Amount';
        UOMCaption = 'UOM';
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get;
        CompanyInfo.CalcFields(Picture);
        FormatAddress.Company(CompanyAddress, CompanyInfo);

        SalesSetup.Get;
    end;

    var
        CompanyInfo: Record "Company Information";
        SalesSetup: Record "Sales & Receivables Setup";
        PaymentTerms: Record "Payment Terms";
        Item: Record Item;
        LotInfo: Record "Lot No. Information";
        FormatAddress: Codeunit "Format Address";
        TermMktFns: Codeunit "Terminal Market Selling";
        CompanyAddress: array[8] of Text[100];
        SellToAddress: array[8] of Text[100];
        CopyText: Text[30];
        NoOfcopies: Integer;
        Qty: Decimal;
        UOM: Code[10];
        Text001: Label 'COPY %1';
        LotData: array[3] of Text[50];
        Text002: Label 'Country of Origin: %1';
}

