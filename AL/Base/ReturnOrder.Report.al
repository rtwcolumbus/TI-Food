report 6641 "Return Order"
{
    DefaultLayout = RDLC;
    RDLCLayout = './layout/ReturnOrder.rdlc';
    Caption = 'Return Order';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            DataItemTableView = SORTING("Document Type", "No.") WHERE("Document Type" = CONST("Return Order"));
            RequestFilterFields = "No.", "Buy-from Vendor No.", "No. Printed";
            RequestFilterHeading = 'Purchase Return Order';
            column(No_PurchHdr; "No.")
            {
            }
            column(InvDiscAmtCaption; InvDiscAmtCaptionLbl)
            {
            }
            column(VATAmtSpecificationCaption; VATAmtSpecificationCaptionLbl)
            {
            }
            column(VATIdentifierCaption; VATIdentifierCaptionLbl)
            {
            }
            column(InvDiscBaseAmtCaption; InvDiscBaseAmtCaptionLbl)
            {
            }
            column(LineAmtCaption; LineAmtCaptionLbl)
            {
            }
            column(VATIdentifierCaption1; VATIdentifierCaption1Lbl)
            {
            }
            column(VATPctCaption; VATPctCaptionLbl)
            {
            }
            column(VATBaseCaption2; VATBaseCaption2Lbl)
            {
            }
            column(VATAmountCaption; VATAmountCaptionLbl)
            {
            }
            column(TotalCaption1; TotalCaption1Lbl)
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                    column(AmtCaption; AmtCaptionLbl)
                    {
                    }
                    column(DiscPercentageCaption; DiscPercentageCaptionLbl)
                    {
                    }
                    column(TotalText; TotalText)
                    {
                    }
                    column(TotalAmt; TotalAmount)
                    {
                        AutoFormatExpression = "Purchase Header"."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(PurchReturnOrderCopyText; StrSubstNo(Text004, CopyText))
                    {
                    }
                    column(CompanyAddr1; CompanyAddr[1])
                    {
                    }
                    column(CompanyAddr2; CompanyAddr[2])
                    {
                    }
                    column(CompanyAddr3; CompanyAddr[3])
                    {
                    }
                    column(CompanyAddr4; CompanyAddr[4])
                    {
                    }
                    column(CompanyInfoPhoneNo; CompanyInfo."Phone No.")
                    {
                    }
                    column(CompanyInfoHomePage; CompanyInfo."Home Page")
                    {
                    }
                    column(CompanyInfoEmail; CompanyInfo."E-Mail")
                    {
                    }
                    column(CompanyInfoVATRegNo; CompanyInfo."VAT Registration No.")
                    {
                    }
                    column(CompanyInfoGiroNo; CompanyInfo."Giro No.")
                    {
                    }
                    column(CompanyInfoBankName; CompanyInfo."Bank Name")
                    {
                    }
                    column(CompanyInfoBankAccNo; CompanyInfo."Bank Account No.")
                    {
                    }
                    column(DocDate_PurchHdr; Format("Purchase Header"."Document Date", 0, 4))
                    {
                    }
                    column(VATNoText; VATNoText)
                    {
                    }
                    column(VATRegNo_PurchHdr; "Purchase Header"."VAT Registration No.")
                    {
                    }
                    column(PurchaserText; PurchaserText)
                    {
                    }
                    column(SalesPurchPersonName; SalesPurchPerson.Name)
                    {
                    }
                    column(ReferenceText; ReferenceText)
                    {
                    }
                    column(YourReference_PurchHdr; "Purchase Header"."Your Reference")
                    {
                    }
                    column(CompanyAddr5; CompanyAddr[5])
                    {
                    }
                    column(CompanyAddr6; CompanyAddr[6])
                    {
                    }
                    column(BuyFromVendNo_PurchHdr; "Purchase Header"."Buy-from Vendor No.")
                    {
                        IncludeCaption = false;
                    }
                    column(BuyFromVendNo_PurchHdrCaption; "Purchase Header".FieldCaption("Buy-from Vendor No."))
                    {
                    }
                    column(BuyFromAddr1; BuyFromAddr[1])
                    {
                    }
                    column(BuyFromAddr2; BuyFromAddr[2])
                    {
                    }
                    column(BuyFromAddr3; BuyFromAddr[3])
                    {
                    }
                    column(BuyFromAddr4; BuyFromAddr[4])
                    {
                    }
                    column(BuyFromAddr5; BuyFromAddr[5])
                    {
                    }
                    column(BuyFromAddr6; BuyFromAddr[6])
                    {
                    }
                    column(BuyFromAddr7; BuyFromAddr[7])
                    {
                    }
                    column(BuyFromAddr8; BuyFromAddr[8])
                    {
                    }
                    column(PricesInclVAT_PurchHdr; "Purchase Header"."Prices Including VAT")
                    {
                        IncludeCaption = false;
                    }
                    column(PricesInclVAT_PurchHdrCaption; "Purchase Header".FieldCaption("Prices Including VAT"))
                    {
                    }
                    column(PricesInclVATYesNo; Format("Purchase Header"."Prices Including VAT"))
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(PageCaption; StrSubstNo(Text005, ''))
                    {
                    }
                    column(VendTaxIdentificationType; Format(Vend."Tax Identification Type"))
                    {
                    }
                    column(CompanyInfoPhoneNoCaption; CompanyInfoPhoneNoCaptionLbl)
                    {
                    }
                    column(CompanyInfoVATRegNoCaption; CompanyInfoVATRegNoCaptionLbl)
                    {
                    }
                    column(CompanyInfoGiroNoCaption; CompanyInfoGiroNoCaptionLbl)
                    {
                    }
                    column(CompanyInfoBankNameCaption; CompanyInfoBankNameCaptionLbl)
                    {
                    }
                    column(CompanyInfoBankAccNoCaption; CompanyInfoBankAccNoCaptionLbl)
                    {
                    }
                    column(ReturnOrderNoCaption; ReturnOrderNoCaptionLbl)
                    {
                    }
                    column(TaxIdentTypeCaption; TaxIdentTypeCaptionLbl)
                    {
                    }
                    column(DirectUnitCostCaption; DirectUnitCostCaptionLbl)
                    {
                    }
                    column(DocDateCaption; DocDateCaptionLbl)
                    {
                    }
                    column(CompanyInfoHomePageCaption; CompanyInfoHomePageCaptionLbl)
                    {
                    }
                    column(CompanyInfoEmailCaption; CompanyInfoEmailCaptionLbl)
                    {
                    }
                    dataitem(DimensionLoop1; "Integer")
                    {
                        DataItemLinkReference = "Purchase Header";
                        DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                        column(DimText_DimensionLoop1; DimText_DimensionLoop1)
                        {
                        }
                        column(DimLoop1No; Number)
                        {
                        }
                        column(HdrDimCaption; HdrDimCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then begin
                                if not DimSetEntry1.Find('-') then
                                    CurrReport.Break();
                            end else
                                if not Continue then
                                    CurrReport.Break();

                            Clear(DimText_DimensionLoop1);
                            Continue := false;
                            repeat
                                OldDimText_DimensionLoop1 := DimText_DimensionLoop1;
                                if DimText_DimensionLoop1 = '' then
                                    DimText_DimensionLoop1 := StrSubstNo(
                                        '%1 %2', DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code")
                                else
                                    DimText_DimensionLoop1 :=
                                      StrSubstNo(
                                        '%1, %2 %3', DimText_DimensionLoop1,
                                        DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code");
                                if StrLen(DimText_DimensionLoop1) > MaxStrLen(OldDimText_DimensionLoop1) then begin
                                    DimText_DimensionLoop1 := OldDimText_DimensionLoop1;
                                    Continue := true;
                                    exit;
                                end;
                            until (DimSetEntry1.Next() = 0);
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not ShowInternalInfo then
                                CurrReport.Break();
                        end;
                    }
                    dataitem("Purchase Line"; "Purchase Line")
                    {
                        DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                        DataItemLinkReference = "Purchase Header";
                        DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");

                        trigger OnPreDataItem()
                        begin
                            CurrReport.Break();
                        end;
                    }
                    dataitem(RoundLoop; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(TypeInt; TypeInt)
                        {
                        }
                        column(LineAmt_PurchLine; PurchLine."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Line"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(Description_PurchLine; "Purchase Line".Description)
                        {
                            IncludeCaption = false;
                        }
                        column(No_PurchLine; "Purchase Line"."No.")
                        {
                            IncludeCaption = false;
                        }
                        column(Quantity_PurchLine; "Purchase Line".Quantity)
                        {
                            IncludeCaption = false;
                        }
                        column(UOM_PurchLine; "Purchase Line"."Unit of Measure")
                        {
                            IncludeCaption = false;
                        }
                        column(No_PurchLineCaption; "Purchase Line".FieldCaption("No."))
                        {
                        }
                        column(Description_PurchLineCaption; "Purchase Line".FieldCaption(Description))
                        {
                        }
                        column(Qty_PurchLineCaption; "Purchase Line".FieldCaption(Quantity))
                        {
                        }
                        column(UOM_PurchLineCaption; "Purchase Line".FieldCaption("Unit of Measure"))
                        {
                        }
                        column(DirectUnitCost_PurchLine; "Purchase Line"."Direct Unit Cost")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 2;
                        }
                        column(LineDisc_PurchLine; "Purchase Line"."Line Discount %")
                        {
                        }
                        column(AllowInvDisc_PurchLine; "Purchase Line"."Allow Invoice Disc.")
                        {
                            IncludeCaption = false;
                        }
                        column(VATIdentifier_PurchLine; "Purchase Line"."VAT Identifier")
                        {
                            IncludeCaption = false;
                        }
                        column(VATIdentifier_PurchLineCaption; "Purchase Line".FieldCaption("VAT Identifier"))
                        {
                        }
                        column(AllowInvDiscYesNo; Format("Purchase Line"."Allow Invoice Disc."))
                        {
                        }
                        column(InvDiscAmt_PurchLine; -PurchLine."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Purchase Line"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(LineAmtPurchLineInvDiscAmt_PurchLine; PurchLine."Line Amount" - PurchLine."Inv. Discount Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalInclVATText; TotalInclVATText)
                        {
                        }
                        column(VATAmtLineVATAmtText; VATAmountLine.VATAmountText)
                        {
                        }
                        column(VATAmt; VATAmount)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(LineAmtPurchLineInvDiscAmtVATAmt_PurchLine; PurchLine."Line Amount" - PurchLine."Inv. Discount Amount" + VATAmount)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalExclVATText; TotalExclVATText)
                        {
                        }
                        column(VATDiscAmt; -VATDiscountAmount)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATBaseDisc; "Purchase Header"."VAT Base Discount %")
                        {
                        }
                        column(VATBaseAmt; VATBaseAmount)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalAmtInclVAT; TotalAmountInclVAT)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(RoundLoopNo; Number)
                        {
                        }
                        column(TotalSubTotal; TotalSubTotal)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TotalInvDiscAmt; TotalInvoiceDiscountAmount)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(SubtotalCaption; SubtotalCaptionLbl)
                        {
                        }
                        column(PymtDiscOnVATCaption; PymtDiscOnVATCaptionLbl)
                        {
                        }
                        column(AllowInvDiscCaption; AllowInvDiscCaptionLbl)
                        {
                        }
                        dataitem(DimensionLoop2; "Integer")
                        {
                            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                            column(DimText_DimensionLoop2; DimText_DimensionLoop1)
                            {
                            }
                            column(DimLoop2No; Number)
                            {
                            }
                            column(LineDimCaption; LineDimCaptionLbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if Number = 1 then begin
                                    if not DimSetEntry2.Find('-') then
                                        CurrReport.Break();
                                end else
                                    if not Continue then
                                        CurrReport.Break();

                                Clear(DimText_DimensionLoop1);
                                Continue := false;
                                repeat
                                    OldDimText_DimensionLoop1 := DimText_DimensionLoop1;
                                    if DimText_DimensionLoop1 = '' then
                                        DimText_DimensionLoop1 := StrSubstNo(
                                            '%1 %2', DimSetEntry2."Dimension Code", DimSetEntry2."Dimension Value Code")
                                    else
                                        DimText_DimensionLoop1 :=
                                          StrSubstNo(
                                            '%1, %2 %3', DimText_DimensionLoop1,
                                            DimSetEntry2."Dimension Code", DimSetEntry2."Dimension Value Code");
                                    if StrLen(DimText_DimensionLoop1) > MaxStrLen(OldDimText_DimensionLoop1) then begin
                                        DimText_DimensionLoop1 := OldDimText_DimensionLoop1;
                                        Continue := true;
                                        exit;
                                    end;
                                until (DimSetEntry2.Next() = 0);
                            end;

                            trigger OnPreDataItem()
                            begin
                                if not ShowInternalInfo then
                                    CurrReport.Break();

                                DimSetEntry2.SetRange("Dimension Set ID", "Purchase Line"."Dimension Set ID");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then
                                PurchLine.Find('-')
                            else
                                PurchLine.Next;
                            "Purchase Line" := PurchLine;

                            if (PurchLine.Type = PurchLine.Type::"G/L Account") and (not ShowInternalInfo) then
                                "Purchase Line"."No." := '';

                            TypeInt := "Purchase Line".Type.AsInteger();
                            TotalSubTotal += "Purchase Line"."Line Amount";
                            TotalInvoiceDiscountAmount -= "Purchase Line"."Inv. Discount Amount";
                            TotalAmount += "Purchase Line".Amount;
                        end;

                        trigger OnPostDataItem()
                        begin
                            PurchLine.DeleteAll();
                        end;

                        trigger OnPreDataItem()
                        begin
                            MoreLines := PurchLine.Find('+');
                            while MoreLines and (PurchLine.Description = '') and (PurchLine."Description 2" = '') and
                                  (PurchLine."No." = '') and (PurchLine.Quantity = 0) and
                                  (PurchLine.Amount = 0)
                            do
                                MoreLines := PurchLine.Next(-1) <> 0;
                            if not MoreLines then
                                CurrReport.Break();
                            PurchLine.SetRange("Line No.", 0, PurchLine."Line No.");
                            SetRange(Number, 1, PurchLine.Count);
                        end;
                    }
                    dataitem(VATCounter; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(VATAmtLineVATBase; VATAmountLine."VAT Base")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVATAmt; VATAmountLine."VAT Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineLineAmt; VATAmountLine."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineInvDiscBaseAmt; VATAmountLine."Inv. Disc. Base Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineInvDiscAmt; VATAmountLine."Invoice Discount Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVAT_VATCounter; VATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATIdentifierCaption_VATCounter; VATIdentifierCaptionLbl)
                        {
                        }
                        column(VATAmtLineVATIdentifier_VATCounter; VATAmountLine."VAT Identifier")
                        {
                        }
                        column(VATPercentageCaption; VATPercentageCaptionLbl)
                        {
                        }
                        column(VATBaseCaption; VATBaseCaptionLbl)
                        {
                        }
                        column(VATAmtCaption; VATAmtCaptionLbl)
                        {
                        }
                        column(TotalCaption; TotalCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            VATAmountLine.GetLine(Number);
                        end;

                        trigger OnPreDataItem()
                        begin
                            if VATAmount = 0 then
                                CurrReport.Break();
                            SetRange(Number, 1, VATAmountLine.Count);
                        end;
                    }
                    dataitem(VATCounterLCY; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(VALExchRate; VALExchRate)
                        {
                        }
                        column(VALSpecLCYHdr; VALSpecLCYHeader)
                        {
                        }
                        column(VALVATAmtLCY; VALVATAmountLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VALVATBaseLCY; VALVATBaseLCY)
                        {
                            AutoFormatType = 1;
                        }
                        column(VATAmtLineVAT_VATCounterLCY; VATAmountLine."VAT %")
                        {
                            DecimalPlaces = 0 : 5;
                        }
                        column(VATAmtLineVATIdentifier_VATCounterLCY; VATAmountLine."VAT Identifier")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            VATAmountLine.GetLine(Number);

                            VALVATBaseLCY := Round(CurrExchRate.ExchangeAmtFCYToLCY(
                                  "Purchase Header"."Posting Date", "Purchase Header"."Currency Code",
                                  VATAmountLine."VAT Base", "Purchase Header"."Currency Factor"));
                            VALVATAmountLCY := Round(CurrExchRate.ExchangeAmtFCYToLCY(
                                  "Purchase Header"."Posting Date", "Purchase Header"."Currency Code",
                                  VATAmountLine."VAT Amount", "Purchase Header"."Currency Factor"));
                        end;

                        trigger OnPreDataItem()
                        begin
                            if (not GLSetup."Print VAT specification in LCY") or
                               ("Purchase Header"."Currency Code" = '') or
                               (VATAmountLine.GetTotalVATAmount = 0)
                            then
                                CurrReport.Break();

                            SetRange(Number, 1, VATAmountLine.Count);
                            Clear(VALVATBaseLCY);
                            Clear(VALVATAmountLCY);

                            if GLSetup."LCY Code" = '' then
                                VALSpecLCYHeader := Text007 + Text008
                            else
                                VALSpecLCYHeader := Text007 + Format(GLSetup."LCY Code");

                            CurrExchRate.FindCurrency("Purchase Header"."Posting Date", "Purchase Header"."Currency Code", 1);
                            VALExchRate := StrSubstNo(Text009, CurrExchRate."Relational Exch. Rate Amount", CurrExchRate."Exchange Rate Amount");
                        end;
                    }
                    dataitem(Total; "Integer")
                    {
                        DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

                        trigger OnPreDataItem()
                        begin
                            if "Purchase Header"."Buy-from Vendor No." = "Purchase Header"."Pay-to Vendor No." then
                                CurrReport.Break();
                        end;
                    }
                    dataitem(Total2; "Integer")
                    {
                        DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                        column(SellToCustNo_PurchHdr; "Purchase Header"."Sell-to Customer No.")
                        {
                            IncludeCaption = false;
                        }
                        column(SellToCustNo_PurchHdrCaption; "Purchase Header".FieldCaption("Sell-to Customer No."))
                        {
                        }
                        column(ShipToAddr1; ShipToAddr[1])
                        {
                        }
                        column(ShipToAddr2; ShipToAddr[2])
                        {
                        }
                        column(ShipToAddr3; ShipToAddr[3])
                        {
                        }
                        column(ShipToAddr4; ShipToAddr[4])
                        {
                        }
                        column(ShipToAddr5; ShipToAddr[5])
                        {
                        }
                        column(ShipToAddr6; ShipToAddr[6])
                        {
                        }
                        column(ShipToAddr7; ShipToAddr[7])
                        {
                        }
                        column(ShipToAddr8; ShipToAddr[8])
                        {
                        }
                        column(ShiptoAddressCaption; ShiptoAddressCaptionLbl)
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            if ("Purchase Header"."Sell-to Customer No." = '') and (ShipToAddr[1] = '') then
                                CurrReport.Break();
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(PurchLine);
                    Clear(PurchPost);
                    PurchLine.DeleteAll();
                    VATAmountLine.DeleteAll();
                    PurchPost.GetPurchLines("Purchase Header", PurchLine, 0);
                    PurchLine.CalcVATAmountLines(0, "Purchase Header", PurchLine, VATAmountLine);
                    PurchLine.UpdateVATOnLines(0, "Purchase Header", PurchLine, VATAmountLine);
                    VATAmount := VATAmountLine.GetTotalVATAmount;
                    VATBaseAmount := VATAmountLine.GetTotalVATBase;
                    VATDiscountAmount :=
                      VATAmountLine.GetTotalVATDiscount("Purchase Header"."Currency Code", "Purchase Header"."Prices Including VAT");
                    TotalAmountInclVAT := VATAmountLine.GetTotalAmountInclVAT;

                    if Number > 1 then begin
                        CopyText := FormatDocument.GetCOPYText;
                        OutputNo += 1;
                    end;

                    TotalSubTotal := 0;
                    TotalInvoiceDiscountAmount := 0;
                    TotalAmount := 0;
                end;

                trigger OnPostDataItem()
                begin
                    if not IsReportInPreviewMode then
                        CODEUNIT.Run(CODEUNIT::"Purch.Header-Printed", "Purchase Header");
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopies) + 1;
                    CopyText := '';
                    SetRange(Number, 1, NoOfLoops);
                    OutputNo := 1;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CurrReport.Language := Language.GetLanguageIdOrDefault("Language Code");

                FormatAddressFields("Purchase Header");
                FormatDocumentFields("Purchase Header");

                DimSetEntry1.SetRange("Dimension Set ID", "Dimension Set ID");
                if not Vend.Get("Buy-from Vendor No.") then
                    Clear(Vend);
            end;

            trigger OnPostDataItem()
            begin
                OnAfterPostDataItem("Purchase Header");
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
                    field(NoOfCopies; NoOfCopies)
                    {
                        ApplicationArea = PurchReturnOrder;
                        Caption = 'No. of Copies';
                        ToolTip = 'Specifies how many copies of the document to print.';
                    }
                    field(ShowInternalInfo; ShowInternalInfo)
                    {
                        ApplicationArea = PurchReturnOrder;
                        Caption = 'Show Internal Information';
                        ToolTip = 'Specifies if you want the printed report to show information that is only for internal use.';
                    }
                    field(LogInteraction; LogInteraction)
                    {
                        ApplicationArea = PurchReturnOrder;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ToolTip = 'Specifies if you want to record the reports that you print as interactions.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            LogInteractionEnable := true;
        end;

        trigger OnOpenPage()
        begin
            InitLogInteraction;
            LogInteractionEnable := LogInteraction;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        GLSetup.Get();
        CompanyInfo.Get();

        OnAfterInitReport;
    end;

    trigger OnPostReport()
    begin
        if LogInteraction and not IsReportInPreviewMode then
            if "Purchase Header".FindSet then
                repeat
                    if "Purchase Header"."Buy-from Contact No." <> '' then
                        SegManagement.LogDocument(22, "Purchase Header"."No.", 0, 0, DATABASE::Contact,
                          "Purchase Header"."Buy-from Contact No.", "Purchase Header"."Purchaser Code", '',
                          "Purchase Header"."Posting Description", '')
                    else
                        SegManagement.LogDocument(22, "Purchase Header"."No.", 0, 0, DATABASE::Vendor,
                          "Purchase Header"."Buy-from Vendor No.", "Purchase Header"."Purchaser Code", '',
                          "Purchase Header"."Posting Description", '')
                until "Purchase Header".Next() = 0;
    end;

    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then
            InitLogInteraction;
    end;

    var
        Text004: Label 'Return Order %1', Comment = '%1 = Document No.';
        Text005: Label 'Page %1';
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        VATAmountLine: Record "VAT Amount Line" temporary;
        PurchLine: Record "Purchase Line" temporary;
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        RespCenter: Record "Responsibility Center";
        CurrExchRate: Record "Currency Exchange Rate";
        Vend: Record Vendor;
        Language: Codeunit Language;
        FormatAddr: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        PurchPost: Codeunit "Purch.-Post";
        SegManagement: Codeunit SegManagement;
        VendAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        CompanyAddr: array[8] of Text[100];
        BuyFromAddr: array[8] of Text[100];
        PurchaserText: Text[30];
        VATNoText: Text[80];
        ReferenceText: Text[80];
        TotalText: Text[50];
        TotalInclVATText: Text[50];
        TotalExclVATText: Text[50];
        MoreLines: Boolean;
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        CopyText: Text[30];
        DimText_DimensionLoop1: Text[120];
        OldDimText_DimensionLoop1: Text[75];
        ShowInternalInfo: Boolean;
        Continue: Boolean;
        VATAmount: Decimal;
        VATBaseAmount: Decimal;
        VATDiscountAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        LogInteraction: Boolean;
        VALVATBaseLCY: Decimal;
        VALVATAmountLCY: Decimal;
        VALSpecLCYHeader: Text[80];
        VALExchRate: Text[50];
        Text007: Label 'VAT Amount Specification in ';
        Text008: Label 'Local Currency';
        Text009: Label 'Exchange rate: %1/%2';
        OutputNo: Integer;
        TypeInt: Integer;
        [InDataSet]
        LogInteractionEnable: Boolean;
        TotalSubTotal: Decimal;
        TotalAmount: Decimal;
        TotalInvoiceDiscountAmount: Decimal;
        InvDiscAmtCaptionLbl: Label 'Invoice Discount Amount';
        VATAmtSpecificationCaptionLbl: Label 'VAT Amount Specification';
        VATIdentifierCaptionLbl: Label 'VAT Identifier';
        InvDiscBaseAmtCaptionLbl: Label 'Invoice Discount Base Amount';
        LineAmtCaptionLbl: Label 'Line Amount';
        AmtCaptionLbl: Label 'Amount';
        DiscPercentageCaptionLbl: Label 'Discount %';
        CompanyInfoPhoneNoCaptionLbl: Label 'Phone No.';
        CompanyInfoVATRegNoCaptionLbl: Label 'VAT Registration No.';
        CompanyInfoGiroNoCaptionLbl: Label 'Giro No.';
        CompanyInfoBankNameCaptionLbl: Label 'Bank';
        CompanyInfoBankAccNoCaptionLbl: Label 'Account No.';
        ReturnOrderNoCaptionLbl: Label 'Return Order No.';
        TaxIdentTypeCaptionLbl: Label 'Tax Identification Type';
        DirectUnitCostCaptionLbl: Label 'Direct Unit Cost';
        DocDateCaptionLbl: Label 'Document Date';
        CompanyInfoHomePageCaptionLbl: Label 'Home Page';
        CompanyInfoEmailCaptionLbl: Label 'Email';
        HdrDimCaptionLbl: Label 'Header Dimensions';
        SubtotalCaptionLbl: Label 'Subtotal';
        PymtDiscOnVATCaptionLbl: Label 'Payment Discount on VAT';
        AllowInvDiscCaptionLbl: Label 'Allow Invoice Discount';
        LineDimCaptionLbl: Label 'Line Dimensions';
        VATPercentageCaptionLbl: Label 'VAT %';
        VATBaseCaptionLbl: Label 'VAT Base';
        VATAmtCaptionLbl: Label 'VAT Amount';
        TotalCaptionLbl: Label 'Total';
        ShiptoAddressCaptionLbl: Label 'Ship-to Address';
        VATIdentifierCaption1Lbl: Label 'VAT Identifier';
        VATPctCaptionLbl: Label 'VAT %';
        VATBaseCaption2Lbl: Label 'VAT Base';
        VATAmountCaptionLbl: Label 'VAT Amount';
        TotalCaption1Lbl: Label 'Total';

    local procedure InitLogInteraction()
    begin
        LogInteraction := SegManagement.FindInteractTmplCode(22) <> '';
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody);
    end;

    local procedure FormatAddressFields(PurchaseHeader: Record "Purchase Header")
    begin
        FormatAddr.GetCompanyAddr(PurchaseHeader."Responsibility Center", RespCenter, CompanyInfo, CompanyAddr);
        FormatAddr.PurchHeaderBuyFrom(BuyFromAddr, PurchaseHeader);
        if PurchaseHeader."Buy-from Vendor No." <> PurchaseHeader."Pay-to Vendor No." then
            FormatAddr.PurchHeaderPayTo(VendAddr, PurchaseHeader);
        FormatAddr.PurchHeaderShipTo(ShipToAddr, PurchaseHeader);
    end;

    local procedure FormatDocumentFields(PurchaseHeader: Record "Purchase Header")
    begin
        with PurchaseHeader do begin
            FormatDocument.SetTotalLabels("Currency Code", TotalText, TotalInclVATText, TotalExclVATText);
            FormatDocument.SetPurchaser(SalesPurchPerson, "Purchaser Code", PurchaserText);

            ReferenceText := FormatDocument.SetText("Your Reference" <> '', FieldCaption("Your Reference"));
            VATNoText := FormatDocument.SetText("VAT Registration No." <> '', FieldCaption("VAT Registration No."));
        end;
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterInitReport()
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterPostDataItem(var PurchaseHeader: Record "Purchase Header")
    begin
    end;
}

