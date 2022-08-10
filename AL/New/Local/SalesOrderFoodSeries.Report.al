report 37002080 "Sales Order - Food Series"
{
    // PR3.10
    //   Add logic for alternate quantities
    // 
    // PR3.70
    //   Change call Segment Management Log Document
    //   Off-Invoice Allowances
    // 
    // PR4.00.02
    // P8000301A, VerticalSoft, Jack Reynolds, 23 FEB 06
    //   Name changed from "Sales Order - Food Series" to reflect that this is a North American report
    // 
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Change call to OffInvoiceFns.SumSalesLines
    // 
    // PRNA5.00.01
    // P8000599A, VerticalSoft, Don Bresee, 29 MAY 08
    //   Key change for Sales Comment Line table
    // 
    // PRW16.00.03
    // P8000827, VerticalSoft, Rick Tweedle, 20 MAY 10
    //   RTC Reporting Upgrade
    // 
    // PRNA6.00.04
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // P8000908, Columbus IT, Jack Reynolds, 28 FEB 11
    //   Fix AllowanceLine problem
    // 
    // PRW16.00.05
    // P8000989, Columbus IT, Jack Reynolds, 25 OCT 11
    //   Fix layout and totaling issues
    // 
    // PRW19.00.01
    // P8007431, To-Increase, Dayakar Battini, 04 JUL 16
    //   Fix for missing header information on RDLC layout.
    DefaultLayout = RDLC;
    RDLCLayout = './layout/Local/SalesOrderFoodSeries.rdlc';

    Caption = 'Sales Order - Food Series';

    dataset
    {
        dataitem("Sales Header";"Sales Header")
        {
            DataItemTableView = SORTING("Document Type","No.") WHERE("Document Type"=CONST(Order));
            RequestFilterFields = "No.","Sell-to Customer No.","Standing Order No.","Shipment Date","No. Printed";
            RequestFilterHeading = 'Sales Order';
            column(SalesHeader_Rec;Format("Sales Header"."Document Type")+"Sales Header"."No.")
            {
            }
            column(SalesHeader_Header;'SalesHeader')
            {
            }
            column(CopyPageGrp;CopyPageGrp)
            {
            }
            column(Sales_Header_Document_Type;"Document Type")
            {
            }
            column(Sales_Header_No_;"No.")
            {
            }
            dataitem("Sales Line";"Sales Line")
            {
                DataItemLink = "Document No."=FIELD("No.");
                DataItemTableView = SORTING("Document Type","Document No.","Line No.") WHERE("Document Type"=CONST(Order));

                trigger OnAfterGetRecord()
                begin
                    HighestLineNo := "Line No.";
                    // PR3.70
                    if "Off-Invoice Allowance Code" <> '' then begin
                      if TempAllowance.Get("Off-Invoice Allowance Code") then begin
                        TempAllowance.Allowance -= "Unit Price";
                        TempAllowance.Modify;
                      end else begin
                        TempAllowance.Init;
                        TempAllowance."Allowance Code" := "Off-Invoice Allowance Code";
                        TempAllowance.Allowance -= "Line Amount";
                        TempAllowance.Insert;
                      end;
                      AllowanceTotal -= "Line Amount";
                      CurrReport.Skip;
                    end;
                    // PR3.70
                    TempSalesLine := "Sales Line";
                    TempSalesLine.Insert;
                    SubTotal += TempSalesLine."Line Amount"; // P8000989
                    if "Sales Header"."Tax Area Code" <> '' then
                      SalesTaxCalc.AddSalesLine(TempSalesLine);

                    // P8000989
                    if Type = Type::Item then begin
                      TotalQty += Quantity;
                      TotalWeight += Quantity * "Net Weight";
                    end;
                    // P8000989
                end;

                trigger OnPostDataItem()
                begin
                    if "Sales Header"."Tax Area Code" <> '' then begin
                      SalesTaxCalc.EndSalesTaxCalculation(UseDate);
                      if TempSalesLine.Find('-') then
                        SalesTaxCalc.DistTaxOverSalesLines(TempSalesLine);

                      //**
                      // SalesTaxCalc.GetSummarizedSalesTaxTable(TempSalesTaxAmtLine);
                      TempSalesTaxAmtLine.Reset;
                      TempSalesTaxAmtLine.DeleteAll;
                      SalesTaxCalc.GetSalesTaxAmountLineTable(TempSalesTaxAmtLine);
                      with TempSalesTaxAmtLine do
                        if Find('-') then
                          repeat
                            if TaxJurisdiction.Get("Tax Jurisdiction Code") then
                              "Print Description" := TaxJurisdiction.Description
                            else if TaxArea.Get("Tax Area Code") then
                              "Print Description" := TaxArea.Description;
                            Modify;
                          until (Next = 0);
                      //**

                      BrkIdx := 0;
                      with TempSalesTaxAmtLine do begin
                        Reset;
                        SetCurrentKey("Print Order","Tax Area Code for Key","Tax Jurisdiction Code");
                        SetFilter("Tax Amount", '<>0');
                        if Find('-') then
                          repeat
                            BrkIdx := BrkIdx + 1;
                            if BrkIdx = 1 then
                              if TaxArea."Country/Region" = TaxArea."Country/Region"::CA then
                                BreakdownTitle := Text006
                              else
                                BreakdownTitle := Text003;
                            if BrkIdx > ArrayLen(BreakdownAmt) then begin
                              BrkIdx := BrkIdx - 1;
                              BreakdownLabel[BrkIdx] := Text004;
                            end else
                              BreakdownLabel[BrkIdx] := StrSubstNo("Print Description","Tax %");
                            BreakdownAmt[BrkIdx] := BreakdownAmt[BrkIdx] + "Tax Amount";
                            TotalTax += "Tax Amount"; // P8000989
                          until Next = 0;
                      end;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    TempSalesLine.Reset;
                    TempSalesLine.DeleteAll;
                end;
            }
            dataitem(AllowanceLine;"Integer")
            {
                DataItemTableView = SORTING(Number);

                trigger OnAfterGetRecord()
                begin
                    // PR3.70
                    if Number = 1 then
                      TempAllowance.Find('-')
                    else
                      TempAllowance.Next;
                    Allowance.Get(TempAllowance."Allowance Code");
                    with TempSalesLine do begin
                      Init;
                      "Document Type" := "Sales Header"."Document Type";
                      "Document No." := "Sales Header"."No.";
                      "Line No." := HighestLineNo + 1000;
                      HighestLineNo := "Line No.";
                      Type := 1;
                      Description := Allowance.Description;
                      "Unit Price" := TempAllowance.Allowance;
                      "Off-Invoice Allowance Code" := Allowance.Code;
                      Insert;
                    end;
                    // PR3.70
                end;

                trigger OnPreDataItem()
                var
                    OrderAllowance: Record "Order Off-Invoice Allowance";
                    AllowanceLine2: Record "Off-Invoice Allowance Line";
                    OffInvoiceFns: Codeunit "Off-Invoice Allowance Mgt.";
                    Weight: Decimal;
                    Volume: Decimal;
                    Quantity: Decimal;
                    Amount: Decimal;
                begin
                    // PR3.70
                    OrderAllowance.SetRange("Document Type","Sales Header"."Document Type");
                    OrderAllowance.SetRange("Document No.","Sales Header"."No.");
                    OrderAllowance.SetRange("Grant Allowance",true);
                    if OrderAllowance.Find('-') then begin
                      OffInvoiceFns.SumSalesLines("Sales Header",Weight,Volume,Quantity,Amount,'OUT'); // P8000282A
                      repeat
                        OffInvoiceFns.CalcAllowance("Sales Header",OrderAllowance."Allowance Code", // P8000908
                          Weight,Volume,Quantity,Amount,AllowanceLine2);                            // P8000908
                        if AllowanceLine2.Allowance <> 0 then begin // P8000908
                          if TempAllowance.Get(OrderAllowance."Allowance Code") then begin
                            TempAllowance.Allowance += AllowanceLine2.Allowance; // P8000908
                            TempAllowance.Modify;
                          end else begin
                            TempAllowance.Init;
                            TempAllowance."Allowance Code" := OrderAllowance."Allowance Code";
                            TempAllowance.Allowance += AllowanceLine2.Allowance; // P8000908
                            TempAllowance.Insert;
                          end;
                          AllowanceTotal += AllowanceLine2.Allowance; // P8000908
                        end;
                      until OrderAllowance.Next = 0;
                    end;

                    if PrintAllowanceDetail then
                      SetRange(Number,1,TempAllowance.Count)
                    else
                      SetRange(Number,1,0);

                    // PR3.70
                end;
            }
            dataitem("Sales Comment Line";"Sales Comment Line")
            {
                DataItemLink = "No."=FIELD("No.");
                DataItemTableView = SORTING("Document Type","No.","Document Line No.","Line No.") WHERE("Document Type"=CONST(Order),"Document Line No."=CONST(0),"Print On Order Confirmation"=CONST(true));

                trigger OnAfterGetRecord()
                begin
                    with TempSalesLine do begin
                      Init;
                      "Document Type" := "Sales Header"."Document Type";
                      "Document No." := "Sales Header"."No.";
                      "Line No." := HighestLineNo + 1000;
                      HighestLineNo := "Line No.";
                    end;
                    if StrLen(Comment) <= MaxStrLen(TempSalesLine.Description) then begin
                      TempSalesLine.Description := Comment;
                      TempSalesLine."Description 2" := '';
                    end else begin
                      SpacePointer := MaxStrLen(TempSalesLine.Description) + 1;
                      while (SpacePointer > 1) and (Comment[SpacePointer] <> ' ') do
                        SpacePointer := SpacePointer - 1;
                      if SpacePointer = 1 then
                        SpacePointer := MaxStrLen(TempSalesLine.Description) + 1;
                      TempSalesLine.Description := CopyStr(Comment,1,SpacePointer - 1);
                      TempSalesLine."Description 2" := CopyStr(CopyStr(Comment,SpacePointer + 1),1,MaxStrLen(TempSalesLine."Description 2"));
                    end;
                    TempSalesLine.Insert;
                end;
            }
            dataitem(CopyLoop;"Integer")
            {
                DataItemTableView = SORTING(Number);
                column(CopyLoop_Rec;Format(Number))
                {
                }
                column(CopyLoop_Header;'CopyLoop')
                {
                }
                column(CopyLoop_Number;Number)
                {
                }
                dataitem(PageLoop;"Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));
                    column(CompanyAddress_3_;CompanyAddress[3])
                    {
                    }
                    column(CompanyAddress_2_;CompanyAddress[2])
                    {
                    }
                    column(CompanyAddress_1_;CompanyAddress[1])
                    {
                    }
                    column(CompanyAddress_4_;CompanyAddress[4])
                    {
                    }
                    column(CompanyAddress_5_;CompanyAddress[5])
                    {
                    }
                    column(CompanyAddress_6_;CompanyAddress[6])
                    {
                    }
                    column(CompanyAddress_7_;CompanyAddress[7])
                    {
                    }
                    column(CompanyAddress_8_;CompanyAddress[8])
                    {
                    }
                    column(CopyTxt;CopyTxt)
                    {
                    }
                    column(BillToAddress_1_;BillToAddress[1])
                    {
                    }
                    column(BillToAddress_2_;BillToAddress[2])
                    {
                    }
                    column(BillToAddress_3_;BillToAddress[3])
                    {
                    }
                    column(BillToAddress_4_;BillToAddress[4])
                    {
                    }
                    column(BillToAddress_5_;BillToAddress[5])
                    {
                    }
                    column(BillToAddress_6_;BillToAddress[6])
                    {
                    }
                    column(BillToAddress_7_;BillToAddress[7])
                    {
                    }
                    column(Sales_Header___Shipment_Date_;"Sales Header"."Shipment Date")
                    {
                    }
                    column(ShipToAddress_1_;ShipToAddress[1])
                    {
                    }
                    column(ShipToAddress_2_;ShipToAddress[2])
                    {
                    }
                    column(ShipToAddress_3_;ShipToAddress[3])
                    {
                    }
                    column(ShipToAddress_4_;ShipToAddress[4])
                    {
                    }
                    column(ShipToAddress_5_;ShipToAddress[5])
                    {
                    }
                    column(ShipToAddress_6_;ShipToAddress[6])
                    {
                    }
                    column(ShipToAddress_7_;ShipToAddress[7])
                    {
                    }
                    column(Sales_Header___Bill_to_Customer_No__;"Sales Header"."Bill-to Customer No.")
                    {
                    }
                    column(Sales_Header___External_Document_No__;"Sales Header"."External Document No.")
                    {
                    }
                    column(SalesPurchPerson_Name;SalesPurchPerson.Name)
                    {
                    }
                    column(Sales_Header___No__;"Sales Header"."No.")
                    {
                    }
                    column(Sales_Header___Order_Date_;"Sales Header"."Order Date")
                    {
                    }
                    column(PageNo;CurrReport.PageNo)
                    {
                    }
                    column(BillToAddress_8_;BillToAddress[8])
                    {
                    }
                    column(ShipToAddress_8_;ShipToAddress[8])
                    {
                    }
                    column(ShipmentMethod_Description;ShipmentMethod.Description)
                    {
                    }
                    column(PaymentTerms_Description;PaymentTerms.Description)
                    {
                    }
                    column(Sales_Header___Order_Date__Control1102603047;"Sales Header"."Order Date")
                    {
                    }
                    column(TaxRegLabel;TaxRegLabel)
                    {
                    }
                    column(TaxRegNo;TaxRegNo)
                    {
                    }
                    column(RouteDescription;RouteDescription)
                    {
                    }
                    column(DocumentNoLabel;DocumentNoLabel)
                    {
                    }
                    column(DocumentLabel;DocumentLabel)
                    {
                    }
                    column(TotalQty;TotalQty)
                    {
                        DecimalPlaces = 0:5;
                    }
                    column(TotalWeight;TotalWeight)
                    {
                        DecimalPlaces = 0:5;
                    }
                    column(SubTotal;SubTotal)
                    {
                        AutoFormatType = 1;
                        DecimalPlaces = 0:5;
                    }
                    column(TotalAllowance;AllowanceTotal)
                    {
                        AutoFormatType = 1;
                        DecimalPlaces = 0:5;
                    }
                    column(TotalTax;TotalTax)
                    {
                        AutoFormatType = 1;
                        DecimalPlaces = 0:5;
                    }
                    column(TotalAmount;SubTotal - AllowanceTotal + TotalTax)
                    {
                        AutoFormatType = 1;
                        DecimalPlaces = 0:5;
                    }
                    column(PageLoop_Rec;Format(Number))
                    {
                    }
                    column(PageLoop_Header;'PageLoop')
                    {
                    }
                    column(SoldCaption;SoldCaptionLbl)
                    {
                    }
                    column(To_Caption;To_CaptionLbl)
                    {
                    }
                    column(Ship_DateCaption;Ship_DateCaptionLbl)
                    {
                    }
                    column(Customer_IDCaption;Customer_IDCaptionLbl)
                    {
                    }
                    column(P_O__NumberCaption;P_O__NumberCaptionLbl)
                    {
                    }
                    column(Sales_PersonCaption;Sales_PersonCaptionLbl)
                    {
                    }
                    column(ShipCaption;ShipCaptionLbl)
                    {
                    }
                    column(To_Caption_Control1102603024;To_Caption_Control1102603024Lbl)
                    {
                    }
                    column(Order_Date_Caption;Order_Date_CaptionLbl)
                    {
                    }
                    column(Page_Caption;Page_CaptionLbl)
                    {
                    }
                    column(Ship_ViaCaption;Ship_ViaCaptionLbl)
                    {
                    }
                    column(TermsCaption;TermsCaptionLbl)
                    {
                    }
                    column(P_O__DateCaption;P_O__DateCaptionLbl)
                    {
                    }
                    column(RouteCaption;RouteCaptionLbl)
                    {
                    }
                    column(PageLoop_Number;Number)
                    {
                    }
                    dataitem(SalesLine;"Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(STRSUBSTNO_Text001_CurrReport_PAGENO___1_;StrSubstNo(Text001,CurrReport.PageNo - 1))
                        {
                        }
                        column(AmountExclInvDisc;AmountExclInvDisc)
                        {
                        }
                        column(TempSalesLine__No__;TempSalesLine."No.")
                        {
                        }
                        column(TempSalesLine__Unit_of_Measure_;TempSalesLine."Unit of Measure")
                        {
                        }
                        column(TempSalesLine__Qty__to_Ship_;TempSalesLine."Qty. to Ship")
                        {
                            DecimalPlaces = 0:5;
                        }
                        column(UnitPriceToPrint;UnitPriceToPrint)
                        {
                            DecimalPlaces = 2:5;
                        }
                        column(AmountExclInvDisc_Control1102603071;AmountExclInvDisc)
                        {
                        }
                        column(TempSalesLine_Description_________TempSalesLine__Description_2_;TempSalesLine.Description + ' ' + TempSalesLine."Description 2")
                        {
                        }
                        column(BillingUnitOfMeasure;BillingUnitOfMeasure)
                        {
                        }
                        column(BillingQuantity;BillingQuantity)
                        {
                            DecimalPlaces = 0:5;
                        }
                        column(TempSalesLine__Original_Quantity_;TempSalesLine."Original Quantity")
                        {
                            DecimalPlaces = 0:5;
                        }
                        column(SalesLine_Rec;Format(Number))
                        {
                        }
                        column(SalesLine_Header;'SalesLine')
                        {
                        }
                        column(TempSalesLine__Off_Invoice_Allowance_Code_;TempSalesLine."Off-Invoice Allowance Code")
                        {
                        }
                        column(PrintFooter;PrintFooter)
                        {
                        }
                        column(NetWeight_Control37002502;NetWeight)
                        {
                        }
                        column(TempSalesLine__Line_Amount_;TempSalesLine."Line Amount")
                        {
                        }
                        column(TempSalesLine__Inv__Discount_Amount_;TempSalesLine."Inv. Discount Amount")
                        {
                        }
                        column(TempSalesLine_Description;TempSalesLine.Description)
                        {
                        }
                        column(TempSalesLine__Unit_Price_;TempSalesLine."Unit Price")
                        {
                            DecimalPlaces = 2:5;
                        }
                        column(STRSUBSTNO_Text002_CurrReport_PAGENO___1_;StrSubstNo(Text002,CurrReport.PageNo + 1))
                        {
                        }
                        column(AmountExclInvDisc_Control1102603078;AmountExclInvDisc)
                        {
                        }
                        column(AmountExclInvDisc_Control1102603079;AmountExclInvDisc)
                        {
                        }
                        column(TaxAmount;TaxAmount)
                        {
                        }
                        column(TempSalesLine__Line_Amount____TaxAmount___TempSalesLine__Inv__Discount_Amount____AllowanceTotal;TempSalesLine."Line Amount" + TaxAmount - TempSalesLine."Inv. Discount Amount" - AllowanceTotal)
                        {
                        }
                        column(BreakdownTitle;BreakdownTitle)
                        {
                        }
                        column(BreakdownLabel_1_;BreakdownLabel[1])
                        {
                        }
                        column(BreakdownLabel_2_;BreakdownLabel[2])
                        {
                        }
                        column(BreakdownLabel_3_;BreakdownLabel[3])
                        {
                        }
                        column(BreakdownAmt_1_;BreakdownAmt[1])
                        {
                            DecimalPlaces = 2:5;
                        }
                        column(BreakdownAmt_2_;BreakdownAmt[2])
                        {
                            DecimalPlaces = 2:5;
                        }
                        column(BreakdownAmt_3_;BreakdownAmt[3])
                        {
                            DecimalPlaces = 2:5;
                        }
                        column(BreakdownAmt_4_;BreakdownAmt[4])
                        {
                            DecimalPlaces = 2:5;
                        }
                        column(BreakdownLabel_4_;BreakdownLabel[4])
                        {
                        }
                        column(TotalTaxLabel;TotalTaxLabel)
                        {
                        }
                        column(TempSalesLine_Quantity;TempSalesLine.Quantity)
                        {
                            DecimalPlaces = 0:5;
                        }
                        column(NetWeight;NetWeight)
                        {
                            DecimalPlaces = 0:5;
                        }
                        column(Text014;Text014)
                        {
                        }
                        column(Text015;Text015)
                        {
                        }
                        column(Text016;Text016)
                        {
                        }
                        column(AllowanceTotal;AllowanceTotal)
                        {
                        }
                        column(Item_No_Caption;Item_No_CaptionLbl)
                        {
                        }
                        column(Sell_UnitCaption;Sell_UnitCaptionLbl)
                        {
                        }
                        column(DescriptionCaption;DescriptionCaptionLbl)
                        {
                        }
                        column(Qty_to_ShipCaption;Qty_to_ShipCaptionLbl)
                        {
                        }
                        column(Unit_PriceCaption;Unit_PriceCaptionLbl)
                        {
                        }
                        column(Total_PriceCaption;Total_PriceCaptionLbl)
                        {
                        }
                        column(Price_UnitCaption;Price_UnitCaptionLbl)
                        {
                        }
                        column(QtyCaption;QtyCaptionLbl)
                        {
                        }
                        column(XCaption;XCaptionLbl)
                        {
                        }
                        column(Order_QtyCaption;Order_QtyCaptionLbl)
                        {
                        }
                        column(Subtotal_Caption;Subtotal_CaptionLbl)
                        {
                        }
                        column(Total_Caption;Total_CaptionLbl)
                        {
                        }
                        column(Allowances_Caption;Allowances_CaptionLbl)
                        {
                        }
                        column(SalesLine_Number;Number)
                        {
                        }
                        dataitem(AltQtyLine;"Integer")
                        {
                            DataItemTableView = SORTING(Number);
                            column(AltQty1;AltQtyMgmt.FormatReportAltQty(TempSalesLine."No.", AltQtys[1]))
                            {
                            }
                            column(AltQty2;AltQtyMgmt.FormatReportAltQty(TempSalesLine."No.", AltQtys[2]))
                            {
                            }
                            column(AltQty3;AltQtyMgmt.FormatReportAltQty(TempSalesLine."No.", AltQtys[3]))
                            {
                            }
                            column(AltQty4;AltQtyMgmt.FormatReportAltQty(TempSalesLine."No.", AltQtys[4]))
                            {
                            }
                            column(AltQty5;AltQtyMgmt.FormatReportAltQty(TempSalesLine."No.", AltQtys[5]))
                            {
                            }
                            column(AltQtyLine_Rec;Format(Number))
                            {
                            }
                            column(AltQtyLine_Header;'AltQtyLine')
                            {
                            }
                            column(AltQtyLine_Number;Number)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                // PR3.10
                                if not AltQtyMgmt.GetLineReportAltQtys(AltQtys, 5) then
                                  CurrReport.Break;
                                // PR3.10
                            end;

                            trigger OnPreDataItem()
                            begin
                                // PR3.10
                                if not AltQtyMgmt.StartLineReport(TempSalesLine."Alt. Qty. Transaction No.", TempSalesLine.Quantity) then
                                  CurrReport.Break;
                                // PR3.10
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            OnLineNumber := OnLineNumber + 1;

                            with TempSalesLine do begin
                              if OnLineNumber = 1 then
                                Find('-')
                              else
                                Next;

                              if Type = 0 then begin
                                "No." := '';
                                "Unit of Measure" := '';
                                "Line Amount" := 0;
                                "Inv. Discount Amount" := 0;
                                Quantity := 0;
                              end else if Type = Type::"G/L Account" then
                                "No." := '';

                              TaxAmount := "Amount Including VAT" - Amount;
                              if TaxAmount <> 0 then begin
                                TaxFlag := true;
                                TaxLiable := Amount;
                              end else begin
                                TaxFlag := false;
                                TaxLiable := 0;
                              end;

                              AmountExclInvDisc := "Line Amount";

                              //**
                              BillingQuantity := GetPricingQty();
                              NetWeight := Quantity * "Net Weight";

                              if BillingQuantity = 0 then
                                UnitPriceToPrint := 0  // so it won't print
                              else
                                UnitPriceToPrint :=
                                  Round(AmountExclInvDisc / BillingQuantity,
                                        Currency."Unit-Amount Rounding Precision");

                              BillingUnitOfMeasure := TempSalesLine."Unit of Measure";
                              if (Type = Type::Item) and ("No." <> '') then
                                if PriceInAlternateUnits() then
                                  if Item.Get("No.") then
                                    if UnitOfMeasure.Get(Item."Alternate Unit of Measure") then
                                      BillingUnitOfMeasure := UnitOfMeasure.Description;
                              //**
                            end;
                            // P8007431
                            if OnLineNumber = NumberOfLines then
                              PrintFooter := true;
                            // P8007431
                        end;

                        trigger OnPreDataItem()
                        begin
                            CurrReport.CreateTotals(TaxLiable,TaxAmount,AmountExclInvDisc,TempSalesLine."Line Amount",TempSalesLine."Inv. Discount Amount");

                            CurrReport.CreateTotals(TempSalesLine.Quantity, BillingQuantity, NetWeight); //**

                            NumberOfLines := TempSalesLine.Count;
                            SetRange(Number,1,NumberOfLines);
                            OnLineNumber := 0;
                            PrintFooter := false;
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                var
                    SalesPost: Codeunit "Sales-Post";
                begin
                    CurrReport.PageNo := 1;
                    if CopyNo <> 0 then  // P8000827
                      CopyPageGrp += 1;  // P8000827
                    if CopyNo = NoLoops then begin
                      if not CurrReport.Preview then
                        SalesPrinted.Run("Sales Header");
                      CurrReport.Break;
                    end else
                      CopyNo := CopyNo + 1;
                    if CopyNo = 1 then // Original
                      Clear(CopyTxt)
                    else
                      CopyTxt := Text000;
                end;

                trigger OnPreDataItem()
                begin
                    NoLoops := 1 + Abs(NoCopies);
                    if NoLoops <= 0 then
                      NoLoops := 1;
                    CopyNo := 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CopyPageGrp += 1;  // P8000827
                if PrintCompany then begin
                  if RespCenter.Get("Responsibility Center") then begin
                    FormatAddress.RespCenter(CompanyAddress,RespCenter);
                    AddToAddress(CompanyAddress, RespCenter."Phone No.");
                  end else begin
                    FormatAddress.Company(CompanyAddress,CompanyInformation);
                    AddToAddress(CompanyAddress, CompanyInformation."Phone No.");
                  end;
                end;
                CurrReport.Language := Language.GetLanguageID("Language Code");

                if "Salesperson Code" = '' then
                  Clear(SalesPurchPerson)
                else
                  SalesPurchPerson.Get("Salesperson Code");

                if "Payment Terms Code" = '' then
                  Clear(PaymentTerms)
                else
                  PaymentTerms.Get("Payment Terms Code");

                if "Shipment Method Code" = '' then
                  Clear(ShipmentMethod)
                else
                  ShipmentMethod.Get("Shipment Method Code");

                FormatAddress.SalesHeaderSellTo(BillToAddress,"Sales Header");
                FormatAddress.SalesHeaderShipTo(ShipToAddress,ShipToAddress,"Sales Header");

                if not CurrReport.Preview then begin
                  if LogInteraction then begin
                    CalcFields("No. of Archived Versions");
                    if "Bill-to Contact No." <> '' then
                      SegManagement.LogDocument(
                        3,"No.","Doc. No. Occurrence",
                        "No. of Archived Versions",DATABASE::Contact,"Bill-to Contact No."
                        ,"Salesperson Code","Campaign No.","Posting Description","Opportunity No.")
                    else
                      SegManagement.LogDocument(
                        3,"No.","Doc. No. Occurrence",
                        "No. of Archived Versions",DATABASE::Customer,"Bill-to Customer No.",
                        "Salesperson Code","Campaign No.","Posting Description","Opportunity No.");
                  end;
                end;
                Clear(BreakdownTitle);
                Clear(BreakdownLabel);
                Clear(BreakdownAmt);
                TotalTaxLabel := Text008;
                TaxRegNo := '';
                TaxRegLabel := '';
                if "Tax Area Code" <> '' then begin
                  TaxArea.Get("Tax Area Code");
                  case TaxArea."Country/Region" of
                    TaxArea."Country/Region"::US:
                      TotalTaxLabel := Text005;
                    TaxArea."Country/Region"::CA:
                      begin
                        TotalTaxLabel := Text007;
                        TaxRegNo := CompanyInformation."VAT Registration No.";
                        TaxRegLabel := CompanyInformation.FieldCaption("VAT Registration No.");
                      end;
                  end;
                  SalesTaxCalc.StartSalesTaxCalculation;
                end;

                if "Posting Date" <> 0D then
                  UseDate := "Posting Date"
                else
                  UseDate := WorkDate;

                //**
                if Customer.Get("Bill-to Customer No.") then
                  AddToAddress(BillToAddress, Customer."Phone No.");

                Clear(RouteDescription);
                if ("Delivery Route No." <> '') then
                  if Route.Get("Delivery Route No.") then
                    if ("Delivery Stop No." = '') then
                      RouteDescription := Route.Description
                    else
                      RouteDescription := StrSubstNo('%1 / %2', Route.Description, "Delivery Stop No.");

                if ("No. Series" <> "Posting No. Series") then begin
                  DocumentNoLabel := Text010;
                  DocumentLabel := Text012;
                end else begin
                  DocumentNoLabel := Text011;
                  DocumentLabel := Text013;
                end;

                if ("Currency Code" <> '') then
                  Currency.Get("Currency Code")
                else begin
                  Clear(Currency);
                  Currency.InitRoundingPrecision;
                end;

                TempAllowance.Reset;     // PR3.70
                TempAllowance.DeleteAll; // PR3.70
                AllowanceTotal := 0;     // PR3.70
                TotalQty := 0;    // P8000989
                TotalWeight := 0; // P8000989
                TotalTax := 0; // P8000989
                SubTotal := 0; // P8000989
                //**
            end;

            trigger OnPreDataItem()
            begin
                CompanyInformation.Get;
                Clear(CompanyAddress);

                if UseRouteOrder then begin
                  SetCurrentKey("Document Type", "Shipment Date", "Delivery Route No.", "Delivery Stop No.");
                  SetRange("Shipment Date", DeliveryDate);
                  SetFilter("Delivery Route No.", RouteFilter);
                end;
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
                    field(NoCopies;NoCopies)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Number of Copies';
                    }
                    field(PrintCompany;PrintCompany)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Print Company Address';
                    }
                    field(PrintAllowanceDetail;PrintAllowanceDetail)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Print Allowance Detail';
                    }
                    field(LogInteraction;LogInteraction)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
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
            LogInteraction := SegManagement.FindInteractTmplCode(2) <> '';
            LogInteractionEnable := LogInteraction;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        PrintCompany := true;
    end;

    var
        TaxLiable: Decimal;
        UnitPriceToPrint: Decimal;
        AmountExclInvDisc: Decimal;
        ShipmentMethod: Record "Shipment Method";
        PaymentTerms: Record "Payment Terms";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        CompanyInformation: Record "Company Information";
        TempSalesLine: Record "Sales Line" temporary;
        RespCenter: Record "Responsibility Center";
        Language: Codeunit Language;
        TempSalesTaxAmtLine: Record "Sales Tax Amount Line" temporary;
        TaxArea: Record "Tax Area";
        CompanyAddress: array [8] of Text[50];
        BillToAddress: array [8] of Text[50];
        ShipToAddress: array [8] of Text[50];
        CopyTxt: Text[10];
        PrintCompany: Boolean;
        PrintFooter: Boolean;
        TaxFlag: Boolean;
        NoCopies: Integer;
        NoLoops: Integer;
        CopyNo: Integer;
        NumberOfLines: Integer;
        OnLineNumber: Integer;
        HighestLineNo: Integer;
        SpacePointer: Integer;
        SalesPrinted: Codeunit "Sales-Printed";
        FormatAddress: Codeunit "Format Address";
        SalesTaxCalc: Codeunit "Sales Tax Calculate";
        TaxAmount: Decimal;
        SegManagement: Codeunit SegManagement;
        LogInteraction: Boolean;
        Text000: Label 'COPY';
        Text001: Label 'Transferred from page %1';
        Text002: Label 'Transferred to page %1';
        Text003: Label 'Sales Tax Breakdown:';
        Text004: Label 'Other Taxes';
        Text005: Label 'Total Sales Tax:';
        Text006: Label 'Tax Breakdown:';
        Text007: Label 'Total Tax:';
        Text008: Label 'Tax:';
        TaxRegNo: Text[30];
        TaxRegLabel: Text[30];
        TotalTaxLabel: Text[30];
        BreakdownTitle: Text[30];
        BreakdownLabel: array [4] of Text[30];
        BreakdownAmt: array [4] of Decimal;
        BrkIdx: Integer;
        UseDate: Date;
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        AltQtys: array [99] of Decimal;
        TaxJurisdiction: Record "Tax Jurisdiction";
        Customer: Record Customer;
        AddressIndex: Integer;
        Route: Record "Delivery Route";
        RouteDescription: Text[50];
        Item: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        BillingQuantity: Decimal;
        BillingUnitOfMeasure: Text[30];
        NetWeight: Decimal;
        Text009: Label 'Sales Tax (%1%):';
        UseRouteOrder: Boolean;
        DeliveryDate: Date;
        RouteFilter: Code[250];
        DocumentNoLabel: Text[30];
        Text010: Label 'Order Number:';
        Text011: Label 'Invoice Number:';
        DocumentLabel: Text[30];
        Text012: Label 'SALES ORDER';
        Text013: Label 'SALES INVOICE';
        Text014: Label 'Total Quantity';
        Text015: Label 'Total Net Weight';
        Text016: Label 'Customer''s Signature:';
        Currency: Record Currency;
        TempAllowance: Record "Off-Invoice Allowance Line" temporary;
        Allowance: Record "Off-Invoice Allowance Header";
        AllowanceTotal: Decimal;
        PrintAllowanceDetail: Boolean;
        [InDataSet]
        LogInteractionEnable: Boolean;
        CopyPageGrp: Integer;
        TotalQty: Decimal;
        TotalWeight: Decimal;
        TotalTax: Decimal;
        SubTotal: Decimal;
        SoldCaptionLbl: Label 'Sold';
        To_CaptionLbl: Label 'To:';
        Ship_DateCaptionLbl: Label 'Ship Date';
        Customer_IDCaptionLbl: Label 'Customer ID';
        P_O__NumberCaptionLbl: Label 'P.O. Number';
        Sales_PersonCaptionLbl: Label 'Sales Person';
        ShipCaptionLbl: Label 'Ship';
        To_Caption_Control1102603024Lbl: Label 'To:';
        Order_Date_CaptionLbl: Label 'Order Date:';
        Page_CaptionLbl: Label 'Page:';
        Ship_ViaCaptionLbl: Label 'Ship Via';
        TermsCaptionLbl: Label 'Terms';
        P_O__DateCaptionLbl: Label 'P.O. Date';
        RouteCaptionLbl: Label 'Route';
        Item_No_CaptionLbl: Label 'Item No.';
        Sell_UnitCaptionLbl: Label 'Sell Unit';
        DescriptionCaptionLbl: Label 'Description';
        Qty_to_ShipCaptionLbl: Label 'Qty to Ship';
        Unit_PriceCaptionLbl: Label 'Unit Price';
        Total_PriceCaptionLbl: Label 'Total Price';
        Price_UnitCaptionLbl: Label 'Price Unit';
        QtyCaptionLbl: Label 'Qty';
        XCaptionLbl: Label 'X';
        Order_QtyCaptionLbl: Label 'Order Qty';
        Subtotal_CaptionLbl: Label 'Subtotal:';
        Total_CaptionLbl: Label 'Total:';
        Allowances_CaptionLbl: Label 'Allowances:';

    local procedure AddToAddress(var Addr: array [8] of Text[50];StrToAdd: Text[250])
    var
        AddrIndex: Integer;
    begin
        //**
        if (StrToAdd <> '') then begin
          AddrIndex := 0;
          repeat
            AddrIndex := AddrIndex + 1;
          until (AddrIndex = ArrayLen(Addr)) or (Addr[AddrIndex] = '');
          if (Addr[AddrIndex] = '') then
            Addr[AddrIndex] := StrToAdd;
        end;
        //**
    end;

    procedure SetRouteInfo(DeliveryDate2: Date;RouteFilter2: Code[250])
    begin
        //**
        UseRouteOrder := true;
        DeliveryDate := DeliveryDate2;
        RouteFilter := RouteFilter2;
        //**
    end;
}

