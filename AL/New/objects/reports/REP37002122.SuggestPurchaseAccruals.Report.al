report 37002122 "Suggest Purchase Accruals"
{
    // PR3.61AC
    // 
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00.01
    // P8000274A, VerticalSoft, Jack Reynolds, 22 DEC 05
    //   Fix problems with resolving start and end dates for plan and ship-to codes
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.03
    // P8000792, VerticalSoft, Rick Tweedle, 17 MAR 10
    //   Converted using TIF Editor
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
    // 
    // PRW18.00.02
    // P8002745, To-Increase, Jack Reynolds, 30 Sep 15
    //   Support for accrual payment documents
    // 
    // PRW19.00
    // P8005495, To-Increase, Jack Reynolds, 20 NOV 15
    //   Fix problem with wrong dates (posting date vs. order date)
    //
    // PRW118.00.05
    // P80014660, To-Increase, Gangabhushan, 21 JUN 22
    //   CS00221661 | Suggest Accrual Payments Document No. Incorrect

    Caption = 'Suggest Purchase Accruals';
    ProcessingOnly = true;

    dataset
    {
        dataitem(AccrualPlan; "Accrual Plan")
        {
            DataItemTableView = SORTING(Type, "No.") WHERE(Type = CONST(Purchase), "Use Accrual Schedule" = CONST(false));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Computation Group";
            RequestFilterHeading = 'Purchase Accrual Plan';
            dataitem(VendorLoop; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                PrintOnlyIfDetail = true;
                dataitem("Purch. Rcpt. Header"; "Purch. Rcpt. Header")
                {
                    DataItemTableView = SORTING("Posting Date", "Pay-to Vendor No.", "Buy-from Vendor No.");
                    dataitem("Purch. Rcpt. Line"; "Purch. Rcpt. Line")
                    {
                        DataItemLink = "Document No." = FIELD("No.");
                        DataItemTableView = SORTING("Document No.", "Line No.") WHERE(Type = CONST(Item), "No." = FILTER(<> ''));

                        trigger OnAfterGetRecord()
                        begin
                            if not AccrualPlan.IsItemInPlan("No.", TransactionDate) then // P8000274A, P8005495
                                CurrReport.Skip;

                            AccrualCalcMgmt.GetPurchRcptLineAmounts(
                              AccrualPlan, "Purch. Rcpt. Line", RcptAmount, RcptCost, RcptQuantity, TransactionDate); // P8005495

                            if (AccrualPlan."Computation Level" = AccrualPlan."Computation Level"::"Document Line") then
                                CreateAccrual(
                                  "No.", TransactionDate, RcptAmount, RcptCost, RcptQuantity, // P8000274A
                                  Vendor."No.", "Purch. Rcpt. Header"."Pay-to Vendor No.",                         // P8000274A
                                  AccrualJnlLine."Source Document Type"::Receipt, "Document No.", "Line No.");
                        end;
                    }
                    dataitem(CalcRcptAccrual; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        MaxIteration = 1;

                        trigger OnAfterGetRecord()
                        begin
                            case AccrualPlan."Computation Level" of
                                AccrualPlan."Computation Level"::Document:
                                    CreateAccrual(
                                      "Purch. Rcpt. Line"."No.", TransactionDate, RcptAmount, RcptCost, RcptQuantity, // P8000274A, P8005495
                                      Vendor."No.", "Purch. Rcpt. Header"."Pay-to Vendor No.",
                                      AccrualJnlLine."Source Document Type"::Receipt, "Purch. Rcpt. Header"."No.", 0);

                                AccrualPlan."Computation Level"::Plan:
                                    AddToPlanDistribution("Purch. Rcpt. Header"."Pay-to Vendor No.", RcptCost, RcptQuantity);
                            end;
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        StatusWindow.Update(3, "No.");
                        TransactionDate := AccrualPlan.GetDocumentTransactionDate("Purch. Rcpt. Header"); // P8005495
                    end;

                    trigger OnPreDataItem()
                    begin
                        if (AccrualPlan.Accrue <> AccrualPlan.Accrue::"Shipments/Receipts") then
                            CurrReport.Break;

                        SetFilter("Pay-to Vendor No.", GetPayToFilter());
                        SetFilter("Buy-from Vendor No.", GetBuyFromFilter());

                        if (AccrualPlan."Date Type" <> AccrualPlan."Date Type"::"Order Date") then
                            SetFilter("Posting Date",
                              AccrualPlan.GetCombinedDateFilter(AccrualSourceLine, StartDate, EndDate))  // P8000274A
                        else begin
                            SetCurrentKey("Order Date", "Pay-to Vendor No.", "Buy-from Vendor No.");
                            SetFilter("Order Date",
                              AccrualPlan.GetCombinedDateFilter(AccrualSourceLine, StartDate, EndDate)); // P8000274A
                        end;
                    end;
                }
                dataitem("Return Shipment Header"; "Return Shipment Header")
                {
                    DataItemTableView = SORTING("Posting Date", "Pay-to Vendor No.", "Buy-from Vendor No.");
                    dataitem("Return Shipment Line"; "Return Shipment Line")
                    {
                        DataItemLink = "Document No." = FIELD("No.");
                        DataItemTableView = SORTING("Document No.", "Line No.") WHERE(Type = CONST(Item), "No." = FILTER(<> ''));

                        trigger OnAfterGetRecord()
                        begin
                            if not AccrualPlan.IsItemInPlan("No.", TransactionDate) then // P8000274A, P8005495
                                CurrReport.Skip;

                            AccrualCalcMgmt.GetPurchShptLineAmounts(
                              AccrualPlan, "Return Shipment Line", ShptAmount, ShptCost, ShptQuantity, TransactionDate); // P8005495

                            if (AccrualPlan."Computation Level" = AccrualPlan."Computation Level"::"Document Line") then
                                CreateAccrual(
                                  "No.", TransactionDate, ShptAmount, ShptCost, ShptQuantity, // P8000274A, P8005495
                                  Vendor."No.", "Return Shipment Header"."Pay-to Vendor No.",                         // P8000274A
                                  AccrualJnlLine."Source Document Type"::Shipment, "Document No.", "Line No.");
                        end;
                    }
                    dataitem(CalcShptAccrual; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        MaxIteration = 1;

                        trigger OnAfterGetRecord()
                        begin
                            case AccrualPlan."Computation Level" of
                                AccrualPlan."Computation Level"::Document:
                                    CreateAccrual(
                                      "Return Shipment Line"."No.", TransactionDate, ShptAmount, ShptCost, ShptQuantity, // P8000274A, P8005495
                                      Vendor."No.", "Return Shipment Header"."Pay-to Vendor No.",
                                      AccrualJnlLine."Source Document Type"::Shipment, "Return Shipment Header"."No.", 0);

                                AccrualPlan."Computation Level"::Plan:
                                    AddToPlanDistribution("Return Shipment Header"."Pay-to Vendor No.", ShptCost, ShptQuantity);
                            end;
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        StatusWindow.Update(3, "No.");
                        TransactionDate := AccrualPlan.GetDocumentTransactionDate("Return Shipment Header"); // P8005495
                    end;

                    trigger OnPreDataItem()
                    begin
                        if (AccrualPlan.Accrue <> AccrualPlan.Accrue::"Shipments/Receipts") then
                            CurrReport.Break;

                        SetFilter("Pay-to Vendor No.", GetPayToFilter());
                        SetFilter("Buy-from Vendor No.", GetBuyFromFilter());

                        SetFilter("Posting Date",
                          AccrualPlan.GetCombinedDateFilter(AccrualSourceLine, StartDate, EndDate)); // P8000274A
                    end;
                }
                dataitem("Purch. Inv. Header"; "Purch. Inv. Header")
                {
                    DataItemTableView = SORTING("Posting Date", "Pay-to Vendor No.", "Buy-from Vendor No.");
                    dataitem("Purch. Inv. Line"; "Purch. Inv. Line")
                    {
                        DataItemLink = "Document No." = FIELD("No.");
                        DataItemTableView = SORTING("Document No.", "Line No.") WHERE(Type = CONST(Item), "No." = FILTER(<> ''));

                        trigger OnAfterGetRecord()
                        begin
                            if not AccrualPlan.IsItemInPlan("No.", TransactionDate) then // P8000274A, P8005495
                                CurrReport.Skip;

                            AccrualCalcMgmt.GetPurchInvLineAmounts(
                              AccrualPlan, "Purch. Inv. Line", InvAmount, InvCost, InvQuantity, TransactionDate); // P8005495

                            if (AccrualPlan."Computation Level" = AccrualPlan."Computation Level"::"Document Line") then
                                CreateAccrual(
                                  "No.", TransactionDate, InvAmount, InvCost, InvQuantity, // P8000274A
                                  Vendor."No.", "Purch. Inv. Header"."Pay-to Vendor No.",                      // P8000274A
                                  AccrualJnlLine."Source Document Type"::Invoice, "Document No.", "Line No.");
                        end;
                    }
                    dataitem(CalcInvAccrual; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        MaxIteration = 1;

                        trigger OnAfterGetRecord()
                        begin
                            case AccrualPlan."Computation Level" of
                                AccrualPlan."Computation Level"::Document:
                                    CreateAccrual(
                                      "Purch. Inv. Line"."No.", TransactionDate, InvAmount, InvCost, InvQuantity, // P8000274A, P8005495
                                      Vendor."No.", "Purch. Inv. Header"."Pay-to Vendor No.",
                                      AccrualJnlLine."Source Document Type"::Invoice, "Purch. Inv. Header"."No.", 0);

                                AccrualPlan."Computation Level"::Plan:
                                    AddToPlanDistribution("Purch. Inv. Header"."Pay-to Vendor No.", InvCost, InvQuantity);
                            end;
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        StatusWindow.Update(3, "No.");
                        TransactionDate := AccrualPlan.GetDocumentTransactionDate("Purch. Inv. Header"); // P8005495

                        if not AccrualCalcMgmt.ReadyToAccruePurchase(
                                 AccrualPlan, "Pay-to Vendor No.", "No.", "Posting Date")
                        then
                            CurrReport.Skip;
                    end;

                    trigger OnPreDataItem()
                    begin
                        if (AccrualPlan.Accrue = AccrualPlan.Accrue::"Shipments/Receipts") then
                            CurrReport.Break;

                        SetFilter("Pay-to Vendor No.", GetPayToFilter());
                        SetFilter("Buy-from Vendor No.", GetBuyFromFilter());

                        if (AccrualPlan."Date Type" <> AccrualPlan."Date Type"::"Order Date") then
                            SetFilter("Posting Date",
                              AccrualPlan.GetCombinedDateFilter(AccrualSourceLine, StartDate, EndDate))  // P8000274A
                        else begin
                            SetCurrentKey("Order Date", "Pay-to Vendor No.", "Buy-from Vendor No.");
                            SetFilter("Order Date",
                              AccrualPlan.GetCombinedDateFilter(AccrualSourceLine, StartDate, EndDate)); // P8000274A
                        end;
                    end;
                }
                dataitem("Purch. Cr. Memo Hdr."; "Purch. Cr. Memo Hdr.")
                {
                    DataItemTableView = SORTING("Posting Date", "Pay-to Vendor No.", "Buy-from Vendor No.");
                    dataitem("Purch. Cr. Memo Line"; "Purch. Cr. Memo Line")
                    {
                        DataItemLink = "Document No." = FIELD("No.");
                        DataItemTableView = SORTING("Document No.", "Line No.") WHERE(Type = CONST(Item), "No." = FILTER(<> ''));

                        trigger OnAfterGetRecord()
                        begin
                            if not AccrualPlan.IsItemInPlan("No.", TransactionDate) then // P8000274A, P8005495
                                CurrReport.Skip;

                            AccrualCalcMgmt.GetPurchCMLineAmounts(
                              AccrualPlan, "Purch. Cr. Memo Line", CMAmount, CMCost, CMQuantity, TransactionDate); // P8005495

                            if (AccrualPlan."Computation Level" = AccrualPlan."Computation Level"::"Document Line") then
                                CreateAccrual(
                                  "No.", TransactionDate, CMAmount, CMCost, CMQuantity, // P8000274A, P8005495
                                  Vendor."No.", "Purch. Cr. Memo Hdr."."Pay-to Vendor No.",                   // P8000274A
                                  AccrualJnlLine."Source Document Type"::"Credit Memo", "Document No.", "Line No.");
                        end;
                    }
                    dataitem(CalcCMAccrual; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        MaxIteration = 1;

                        trigger OnAfterGetRecord()
                        begin
                            case AccrualPlan."Computation Level" of
                                AccrualPlan."Computation Level"::Document:
                                    CreateAccrual(
                                      "Purch. Cr. Memo Line"."No.", TransactionDate, CMAmount, CMCost, CMQuantity, // P8000274A, P8005495
                                      Vendor."No.", "Purch. Cr. Memo Hdr."."Pay-to Vendor No.",
                                      AccrualJnlLine."Source Document Type"::"Credit Memo", "Purch. Cr. Memo Hdr."."No.", 0);

                                AccrualPlan."Computation Level"::Plan:
                                    AddToPlanDistribution("Purch. Cr. Memo Hdr."."Pay-to Vendor No.", CMCost, CMQuantity);
                            end;
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        StatusWindow.Update(3, "No.");
                        TransactionDate := AccrualPlan.GetDocumentTransactionDate("Purch. Cr. Memo Hdr."); // P8005495
                    end;

                    trigger OnPreDataItem()
                    begin
                        if (AccrualPlan.Accrue = AccrualPlan.Accrue::"Shipments/Receipts") then
                            CurrReport.Break;

                        SetFilter("Pay-to Vendor No.", GetPayToFilter());
                        SetFilter("Buy-from Vendor No.", GetBuyFromFilter());

                        SetFilter("Posting Date",
                          AccrualPlan.GetCombinedDateFilter(AccrualSourceLine, StartDate, EndDate)); // P8000274A
                    end;
                }
                dataitem(CalcPlanAccrual; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    MaxIteration = 1;

                    trigger OnAfterGetRecord()
                    begin
                        if (AccrualPlan."Computation Level" = AccrualPlan."Computation Level"::Plan) then
                            CreateAccrual(
                              '', 0D, ShptAmount + RcptAmount + InvAmount + CMAmount, // P8000274A
                              ShptCost + RcptCost + InvCost + CMCost,
                              ShptQuantity + RcptQuantity + InvQuantity + CMQuantity,
                              Vendor."No.", '', AccrualJnlLine."Source Document Type"::None, '', 0);
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if not AccrualCalcMgmt.GetVendor(Vendor, AccrualSourceLine, AccrualPlan, Number = 1) then // P8000274A
                        CurrReport.Break;

                    StatusWindow.Update(2, Vendor."No.");
                end;

                trigger OnPreDataItem()
                begin
                    AccrualCalcMgmt.PrepareVendor(Vendor, VendorFilters, AccrualPlan);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                StatusWindow.Update(1, "No.");
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Post Accrual w/ Document", RecalcDocAccruals);
                // P80014660
                if NewDocumentNo = '' then
                    Error(DocumentNoErr2);
                // P80014660
            end;
        }
        dataitem(SearchVendor; Vendor)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            begin
                CurrReport.Break;
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
                    field("Document Start Date"; StartDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Document Start Date';
                    }
                    field("Document End Date"; EndDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Document End Date';
                    }
                    field("Posting Date"; NewPostingDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Posting Date';
                        NotBlank = true;
                    }
                    field("Document No."; NewDocumentNo)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Document No.';

                        // P80014660
                        trigger OnValidate()
                        begin
                            if NewDocumentNo <> '' then
                                if IncStr(NewDocumentNo) = '' then
                                    Error(DocumentNoErr);
                        end;
                        // P80014660                        
                    }
                    field("Recalc. Document Accruals"; RecalcDocAccruals)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Recalc. Document Accruals';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            NewDocumentNo := AccrualJnlLine."Document No.";

            if (NewPostingDate = 0D) then
                NewPostingDate := WorkDate;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        if (StartDate = 0D) then
            Error(Text001);

        if (EndDate = 0D) then
            Error(Text002);

        VendorFilters.CopyFilters(SearchVendor);

        StatusWindow.Open(Text003);

        AccrualCalcMgmt.SetEntryInfo(NewPostingDate, NewDocumentNo);
    end;

    var
        StartDate: Date;
        EndDate: Date;
        NewPostingDate: Date;
        NewDocumentNo: Code[20];
        VendorFilters: Record Vendor;
        Vendor: Record Vendor;
        AccrualSourceLine: Record "Accrual Plan Source Line";
        AccrualJnlLine: Record "Accrual Journal Line";
        TempPlanPurchases: Record "Purchase Line" temporary;
        StatusWindow: Dialog;
        AccrualCalcMgmt: Codeunit "Accrual Calculation Management";
        RcptAmount: Decimal;
        RcptCost: Decimal;
        RcptQuantity: Decimal;
        ShptAmount: Decimal;
        ShptCost: Decimal;
        ShptQuantity: Decimal;
        InvAmount: Decimal;
        InvCost: Decimal;
        InvQuantity: Decimal;
        CMAmount: Decimal;
        CMCost: Decimal;
        CMQuantity: Decimal;
        Text001: Label 'You must specify a Start Date.';
        Text002: Label 'You must specify an End Date.';
        Text003: Label 'Generating Entries...\\Accrual Plan No.  #1##################\Vendor No.        #2##################\Document No.      #3##################';
        RecalcDocAccruals: Boolean;
        TransactionDate: Date;
        DocumentNoErr: Label 'The value in the Document No. field must have a number so that we can assign the next number in the series.'; // P80014660
        DocumentNoErr2: Label 'In the Document No. field, specify the document number to be used.'; // P80014660

    procedure SetJnlLine(var AccrualJnlLine2: Record "Accrual Journal Line")
    begin
        AccrualJnlLine := AccrualJnlLine2;
        AccrualCalcMgmt.SetJnlLine(AccrualJnlLine);
    end;

    procedure GetPayToFilter(): Code[20]
    begin
        if (AccrualPlan."Source Selection Type" =
            AccrualPlan."Source Selection Type"::"Bill-to/Pay-to")
        then
            exit(Vendor."No.");
        exit('');
    end;

    procedure GetBuyFromFilter(): Code[20]
    begin
        if (AccrualPlan."Source Selection Type" <>
            AccrualPlan."Source Selection Type"::"Bill-to/Pay-to")
        then
            exit(Vendor."No.");
        exit('');
    end;

    local procedure CreateAccrual(ItemNo: Code[20]; TransactionDate: Date; Amount: Decimal; Cost: Decimal; Quantity: Decimal; SourceNo: Code[20]; PayToNo: Code[20]; SourceDocType: Integer; SourceDocNo: Code[20]; SourceDocLineNo: Integer)
    var
        AccrualAmount: Decimal;
    begin
        // P8000274A - parameter added for TransactionDate
        if (SourceDocType in
            [AccrualJnlLine."Source Document Type"::None,
             AccrualJnlLine."Source Document Type"::Receipt,
             AccrualJnlLine."Source Document Type"::Invoice])
        then
            AccrualAmount := AccrualPlan.CalcAccrualAmount(ItemNo, TransactionDate, Amount, Cost, Quantity)      // P8000274A
        else
            AccrualAmount := -AccrualPlan.CalcAccrualAmount(ItemNo, TransactionDate, -Amount, -Cost, -Quantity); // P8000274A

        if (AccrualPlan."Computation Level" <> AccrualPlan."Computation Level"::Plan) then
            AccrualCalcMgmt.CreateAccrualJnlLine(
              AccrualPlan, AccrualAmount, SourceNo, PayToNo,
              SourceDocType, SourceDocNo, SourceDocLineNo)
        else
            DistributePlanAccrual(
              AccrualAmount, Cost, Quantity, SourceNo,
              SourceDocType, SourceDocNo, SourceDocLineNo);
    end;

    local procedure AddToPlanDistribution(PayToNo: Code[20]; Cost: Decimal; Qty: Decimal)
    begin
        TempPlanPurchases.Init;
        TempPlanPurchases."Document No." := PayToNo;
        if not TempPlanPurchases.Find then
            TempPlanPurchases.Insert;
        TempPlanPurchases.Amount := TempPlanPurchases.Amount + Cost;
        TempPlanPurchases.Quantity := TempPlanPurchases.Quantity + Qty;
        TempPlanPurchases.Modify;
    end;

    local procedure DistributePlanAccrual(AccrualAmount: Decimal; Cost: Decimal; Quantity: Decimal; SourceNo: Code[20]; SourceDocType: Integer; SourceDocNo: Code[20]; SourceDocLineNo: Integer)
    var
        AccrualAmountToPost: Decimal;
    begin
        if TempPlanPurchases.Find('-') then begin
            repeat
                if (AccrualPlan."Minimum Value Type" = AccrualPlan."Minimum Value Type"::Quantity) then begin
                    AccrualAmountToPost := Round(AccrualAmount * (TempPlanPurchases.Quantity / Quantity));
                    Quantity := Quantity - TempPlanPurchases.Quantity;
                end else begin
                    AccrualAmountToPost := Round(AccrualAmount * (TempPlanPurchases.Amount / Cost));
                    Cost := Cost - TempPlanPurchases.Amount;
                end;
                AccrualCalcMgmt.CreateAccrualJnlLine(
                    AccrualPlan, AccrualAmountToPost, SourceNo, TempPlanPurchases."Document No.",
                    SourceDocType, SourceDocNo, SourceDocLineNo);
                AccrualAmount := AccrualAmount - AccrualAmountToPost;
            until (TempPlanPurchases.Next = 0);
            TempPlanPurchases.DeleteAll;
        end;
    end;
}

