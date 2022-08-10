report 37002120 "Suggest Sales Accruals"
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
    // PR4.00.06
    // P8000464A, VerticalSoft, Don Bresee, 9 APR 07
    //   Fixes relating to Combine Shipment & Combine Return Receipts functions
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 09 AUG 07
    //   Remove unused section
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.01
    // P8000731, VerticalSoft, Don Bresee, 08 OCT 09
    //   Change date filtering for plans that accrue on "Paid Invoices/CMs"
    // 
    // PRW16.00.03
    // P8000792, VerticalSoft, Rick Tweedle, 17 MAR 10
    //   Converted using TIF Editor
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
    // 
    // PRW18.00.01
    // P8001374, Columbus IT, Jack Reynolds, 17 FEB 15
    //   Correct problem with sell-to/bill-to customers
    // 
    // PRW18.00.02
    // P8002745, To-Increase, Jack Reynolds, 30 Sep 15
    //   Support for accrual payment documents
    // 
    // PRW19.00
    // P8005495, To-Increase, Jack Reynolds, 20 NOV 15
    //   Fix problem with wrong dates (posting date vs. order date)
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW118.00.05
    // P80014660, To-Increase, Gangabhushan, 21 JUN 22
    //   CS00221661 | Suggest Accrual Payments Document No. Incorrect

    Caption = 'Suggest Sales Accruals';
    ProcessingOnly = true;

    dataset
    {
        dataitem(AccrualPlan; "Accrual Plan")
        {
            DataItemTableView = SORTING(Type, "No.") WHERE(Type = CONST(Sales), "Use Accrual Schedule" = CONST(false), "Use Accrual Schedule" = CONST(false));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Computation Group";
            RequestFilterHeading = 'Sales Accrual Plan';
            dataitem(CustomerLoop; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                PrintOnlyIfDetail = true;
                dataitem("Sales Shipment Header"; "Sales Shipment Header")
                {
                    DataItemTableView = SORTING("Posting Date", "Bill-to Customer No.", "Sell-to Customer No.");
                    dataitem("Sales Shipment Line"; "Sales Shipment Line")
                    {
                        DataItemLink = "Document No." = FIELD("No.");
                        DataItemTableView = SORTING("Document No.", "Line No.") WHERE(Type = CONST(Item), "No." = FILTER(<> ''));

                        trigger OnAfterGetRecord()
                        begin
                            if not AccrualPlan.IsItemInPlan("No.", TransactionDate) then // P8000274A, P8005495
                                CurrReport.Skip;

                            AccrualCalcMgmt.GetSalesShptLineAmounts(
                              AccrualPlan, "Sales Shipment Line", ShptAmount, ShptCost, ShptQuantity, TransactionDate); // P8005495

                            if (AccrualPlan."Computation Level" = AccrualPlan."Computation Level"::"Document Line") then
                                CreateAccrual(
                                  "No.", TransactionDate, ShptAmount, ShptCost, ShptQuantity, // P8000274A, P8005495
                                  Customer."No.", "Sales Shipment Header"."Bill-to Customer No.",
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
                                      "Sales Shipment Line"."No.", TransactionDate, ShptAmount, ShptCost, ShptQuantity, // P8000274A, P8005495
                                      Customer."No.", "Sales Shipment Header"."Bill-to Customer No.",
                                      AccrualJnlLine."Source Document Type"::Shipment, "Sales Shipment Header"."No.", 0);

                                AccrualPlan."Computation Level"::Plan:
                                    AddToPlanDistribution("Sales Shipment Header"."Bill-to Customer No.", ShptAmount, ShptQuantity);
                            end;
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        StatusWindow.Update(3, "No.");
                        TransactionDate := AccrualPlan.GetDocumentTransactionDate("Sales Shipment Header"); // P8005495
                    end;

                    trigger OnPreDataItem()
                    begin
                        if (AccrualPlan.Accrue <> AccrualPlan.Accrue::"Shipments/Receipts") then
                            CurrReport.Break;

                        SetFilter("Bill-to Customer No.", GetBillToFilter());
                        SetFilter("Sell-to Customer No.", GetSellToFilter());
                        SetFilter("Ship-to Code", GetShipToFilter());

                        if (AccrualPlan."Date Type" <> AccrualPlan."Date Type"::"Order Date") then
                            SetFilter("Posting Date",
                              AccrualPlan.GetCombinedDateFilter(AccrualSourceLine, StartDate, EndDate))  // P8000274A
                        else begin
                            SetCurrentKey("Order Date", "Bill-to Customer No.", "Sell-to Customer No.");
                            SetFilter("Order Date",
                              AccrualPlan.GetCombinedDateFilter(AccrualSourceLine, StartDate, EndDate)); // P8000274A
                        end;
                    end;
                }
                dataitem("Return Receipt Header"; "Return Receipt Header")
                {
                    DataItemTableView = SORTING("Posting Date", "Bill-to Customer No.", "Sell-to Customer No.");
                    dataitem("Return Receipt Line"; "Return Receipt Line")
                    {
                        DataItemLink = "Document No." = FIELD("No.");
                        DataItemTableView = SORTING("Document No.", "Line No.") WHERE(Type = CONST(Item), "No." = FILTER(<> ''));

                        trigger OnAfterGetRecord()
                        begin
                            if not AccrualPlan.IsItemInPlan("No.", TransactionDate) then // P8000274A, P8005495
                                CurrReport.Skip;

                            AccrualCalcMgmt.GetSalesRcptLineAmounts(
                              AccrualPlan, "Return Receipt Line", RcptAmount, RcptCost, RcptQuantity, TransactionDate); // P8005495

                            if (AccrualPlan."Computation Level" = AccrualPlan."Computation Level"::"Document Line") then
                                CreateAccrual(
                                  "No.", TransactionDate, RcptAmount, RcptCost, RcptQuantity, // P8000274A, P8005495
                                  Customer."No.", "Return Receipt Header"."Bill-to Customer No.",
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
                                      "Return Receipt Line"."No.", TransactionDate, RcptAmount, RcptCost, RcptQuantity, // P8000274A, P8005495
                                      Customer."No.", "Return Receipt Header"."Bill-to Customer No.",
                                      AccrualJnlLine."Source Document Type"::Receipt, "Return Receipt Header"."No.", 0);

                                AccrualPlan."Computation Level"::Plan:
                                    AddToPlanDistribution("Return Receipt Header"."Bill-to Customer No.", RcptAmount, RcptQuantity);
                            end;
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        StatusWindow.Update(3, "No.");
                        TransactionDate := AccrualPlan.GetDocumentTransactionDate("Return Receipt Header"); // P8005495
                    end;

                    trigger OnPreDataItem()
                    begin
                        if (AccrualPlan.Accrue <> AccrualPlan.Accrue::"Shipments/Receipts") then
                            CurrReport.Break;

                        SetFilter("Bill-to Customer No.", GetBillToFilter());
                        SetFilter("Sell-to Customer No.", GetSellToFilter());
                        SetFilter("Ship-to Code", GetShipToFilter());

                        if (AccrualPlan."Date Type" <> AccrualPlan."Date Type"::"Order Date") then
                            SetFilter("Posting Date",
                              AccrualPlan.GetCombinedDateFilter(AccrualSourceLine, StartDate, EndDate))  // P8000274A
                        else begin
                            SetCurrentKey("Order Date", "Bill-to Customer No.", "Sell-to Customer No.");
                            SetFilter("Order Date",
                              AccrualPlan.GetCombinedDateFilter(AccrualSourceLine, StartDate, EndDate)); // P8000274A
                        end;
                    end;
                }
                dataitem(SalesInvSearchLine; "Sales Invoice Line")
                {
                    DataItemTableView = SORTING("Accrual Posting Date", "Bill-to Customer No.", "Sell-to Customer No.", Type, "Document No.") WHERE(Type = CONST(Item));
                    dataitem("Sales Invoice Header"; "Sales Invoice Header")
                    {
                        DataItemLink = "No." = FIELD("Document No.");
                        DataItemTableView = SORTING("No.");
                        dataitem("Sales Invoice Line"; "Sales Invoice Line")
                        {
                            DataItemLink = "Document No." = FIELD("No.");
                            DataItemTableView = SORTING("Document No.", "Line No.") WHERE(Type = CONST(Item), "No." = FILTER(<> ''));

                            trigger OnAfterGetRecord()
                            begin
                                if not IsSalesInvShipToInPlan("Sales Invoice Line") then // P8000464A
                                    CurrReport.Skip;                                       // P8000464A

                                if not AccrualPlan.IsItemInPlan("No.", TransactionDate) then // P8000274A, P8005495
                                    CurrReport.Skip;

                                AccrualCalcMgmt.GetSalesInvLineAmounts(
                                  AccrualPlan, "Sales Invoice Line", InvAmount, InvCost, InvQuantity, TransactionDate); // P885495

                                if (AccrualPlan."Computation Level" = AccrualPlan."Computation Level"::"Document Line") then
                                    CreateAccrual(
                                      "No.", TransactionDate, InvAmount, InvCost, InvQuantity, // P8000274A, P8005495
                                      Customer."No.", "Sales Invoice Header"."Bill-to Customer No.",
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
                                          "Sales Invoice Line"."No.", TransactionDate, InvAmount, InvCost, InvQuantity, // P8000274A, P8005495
                                          Customer."No.", "Sales Invoice Header"."Bill-to Customer No.",
                                          AccrualJnlLine."Source Document Type"::Invoice, "Sales Invoice Header"."No.", 0);

                                    AccrualPlan."Computation Level"::Plan:
                                        AddToPlanDistribution("Sales Invoice Header"."Bill-to Customer No.", InvAmount, InvQuantity);
                                end;
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            StatusWindow.Update(3, "No.");
                            TransactionDate := AccrualPlan.GetDocumentTransactionDate("Sales Invoice Header"); // P8005495

                            // P8000731
                            /*
                            IF NOT AccrualCalcMgmt.ReadyToAccrueSale(
                                     AccrualPlan, "Bill-to Customer No.", "No.", "Posting Date")
                            THEN
                              CurrReport.SKIP;
                            */
                            // P8000731

                        end;

                        trigger OnPreDataItem()
                        begin
                            // P8000464A
                            /*
                            IF (AccrualPlan.Accrue = AccrualPlan.Accrue::"Shipments/Receipts") THEN
                              CurrReport.BREAK;
                            
                            SETFILTER("Bill-to Customer No.", GetBillToFilter());
                            SETFILTER("Sell-to Customer No.", GetSellToFilter());
                            SETFILTER("Ship-to Code", GetShipToFilter());
                            
                            IF (AccrualPlan."Date Type" <> AccrualPlan."Date Type"::"Order Date") THEN
                              SETFILTER("Posting Date",
                                AccrualPlan.GetCombinedDateFilter(AccrualSourceLine, StartDate, EndDate))  // P8000274A
                            ELSE BEGIN
                              SETCURRENTKEY("Order Date", "Bill-to Customer No.", "Sell-to Customer No.");
                              SETFILTER("Order Date",
                                AccrualPlan.GetCombinedDateFilter(AccrualSourceLine, StartDate, EndDate)); // P8000274A
                            END;
                            */
                            // P8000464A

                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        // P8000464A
                        SetRange("Document No.", "Document No.");
                        Find('+');
                        SetRange("Document No.");
                        // P8000464A
                    end;

                    trigger OnPreDataItem()
                    begin
                        if (AccrualPlan.Accrue = AccrualPlan.Accrue::"Paid Invoices/CMs") then // P8000731
                            CurrReport.Break;                                                    // P8000731

                        // P8000464A
                        if (AccrualPlan.Accrue = AccrualPlan.Accrue::"Shipments/Receipts") then
                            CurrReport.Break;

                        SetFilter("Bill-to Customer No.", GetBillToFilter());
                        SetFilter("Sell-to Customer No.", GetSellToFilter());

                        if (AccrualPlan."Date Type" <> AccrualPlan."Date Type"::"Order Date") then
                            SetFilter("Accrual Posting Date",
                              AccrualPlan.GetCombinedDateFilter(AccrualSourceLine, StartDate, EndDate))
                        else begin
                            SetCurrentKey(
                              "Accrual Order Date", "Bill-to Customer No.", "Sell-to Customer No.", Type, "Document No.");
                            SetFilter("Accrual Order Date",
                              AccrualPlan.GetCombinedDateFilter(AccrualSourceLine, StartDate, EndDate));
                        end;
                        // P8000464A
                    end;
                }
                dataitem(SalesCMSearchLine; "Sales Cr.Memo Line")
                {
                    DataItemTableView = SORTING("Accrual Posting Date", "Bill-to Customer No.", "Sell-to Customer No.", Type, "Document No.") WHERE(Type = CONST(Item));
                    dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
                    {
                        DataItemLink = "No." = FIELD("Document No.");
                        DataItemTableView = SORTING("No.");
                        dataitem("Sales Cr.Memo Line"; "Sales Cr.Memo Line")
                        {
                            DataItemLink = "Document No." = FIELD("No.");
                            DataItemTableView = SORTING("Document No.", "Line No.") WHERE(Type = CONST(Item), "No." = FILTER(<> ''));

                            trigger OnAfterGetRecord()
                            begin
                                if not IsSalesCMShipToInPlan("Sales Cr.Memo Line") then // P8000464A
                                    CurrReport.Skip;                                      // P8000464A

                                if not AccrualPlan.IsItemInPlan("No.", TransactionDate) then // P8000274A, P8005495
                                    CurrReport.Skip;

                                AccrualCalcMgmt.GetSalesCMLineAmounts(
                                  AccrualPlan, "Sales Cr.Memo Line", CMAmount, CMCost, CMQuantity, TransactionDate); // P8005495

                                if (AccrualPlan."Computation Level" = AccrualPlan."Computation Level"::"Document Line") then
                                    CreateAccrual(
                                      "No.", TransactionDate, CMAmount, CMCost, CMQuantity, // P8000274A, P8005495
                                      Customer."No.", "Sales Cr.Memo Header"."Bill-to Customer No.",
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
                                          "Sales Cr.Memo Line"."No.", TransactionDate, CMAmount, CMCost, CMQuantity, // P8000274A, P8005495
                                          Customer."No.", "Sales Cr.Memo Header"."Bill-to Customer No.",
                                          AccrualJnlLine."Source Document Type"::"Credit Memo", "Sales Cr.Memo Header"."No.", 0);

                                    AccrualPlan."Computation Level"::Plan:
                                        AddToPlanDistribution("Sales Cr.Memo Header"."Bill-to Customer No.", CMAmount, CMQuantity);
                                end;
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            StatusWindow.Update(3, "No.");
                            TransactionDate := AccrualPlan.GetDocumentTransactionDate("Sales Cr.Memo Header"); // P8005495
                        end;

                        trigger OnPreDataItem()
                        begin
                            // P8000464A
                            /*
                            IF (AccrualPlan.Accrue = AccrualPlan.Accrue::"Shipments/Receipts") THEN
                              CurrReport.BREAK;
                            
                            SETFILTER("Bill-to Customer No.", GetBillToFilter());
                            SETFILTER("Sell-to Customer No.", GetSellToFilter());
                            SETFILTER("Ship-to Code", GetShipToFilter());
                            
                            SETFILTER("Posting Date",
                              AccrualPlan.GetCombinedDateFilter(AccrualSourceLine, StartDate, EndDate)); // P8000274A
                            */
                            // P8000464A

                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        // P8000464A
                        SetRange("Document No.", "Document No.");
                        Find('+');
                        SetRange("Document No.");
                        // P8000464A
                    end;

                    trigger OnPreDataItem()
                    begin
                        if (AccrualPlan.Accrue = AccrualPlan.Accrue::"Paid Invoices/CMs") then // P8000731
                            CurrReport.Break;                                                    // P8000731

                        // P8000464A
                        if (AccrualPlan.Accrue = AccrualPlan.Accrue::"Shipments/Receipts") then
                            CurrReport.Break;

                        SetFilter("Bill-to Customer No.", GetBillToFilter());
                        SetFilter("Sell-to Customer No.", GetSellToFilter());

                        SetFilter("Accrual Posting Date",
                          AccrualPlan.GetCombinedDateFilter(AccrualSourceLine, StartDate, EndDate)); // P8000274A
                        // P8000464A
                    end;
                }
                dataitem(AccrueOnPaidPlan; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    MaxIteration = 1;
                    dataitem(AccrueOnPaidInvoice; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        dataitem(PaidSalesInvHeader; "Sales Invoice Header")
                        {
                            DataItemTableView = SORTING("No.");
                            dataitem(PaidSalesInvLine; "Sales Invoice Line")
                            {
                                DataItemLink = "Document No." = FIELD("No.");
                                DataItemTableView = SORTING("Document No.", "Line No.") WHERE(Type = CONST(Item), "No." = FILTER(<> ''));

                                trigger OnAfterGetRecord()
                                begin
                                    // P8000731
                                    if not IsSalesInvShipToInPlan(PaidSalesInvLine) then
                                        CurrReport.Skip;

                                    if not AccrualPlan.IsItemInPlan("No.", TransactionDate) then // P8005495
                                        CurrReport.Skip;

                                    AccrualCalcMgmt.GetSalesInvLineAmounts(
                                      AccrualPlan, PaidSalesInvLine, InvAmount, InvCost, InvQuantity, TransactionDate); // P8005495

                                    if (AccrualPlan."Computation Level" = AccrualPlan."Computation Level"::"Document Line") then
                                        CreateAccrual(
                                          "No.", TransactionDate, InvAmount, InvCost, InvQuantity, // P8005495
                                          Customer."No.", PaidSalesInvHeader."Bill-to Customer No.",
                                          AccrualJnlLine."Source Document Type"::Invoice, "Document No.", "Line No.");
                                    // P8000731
                                end;
                            }
                            dataitem(CalcPaidInvAccrual; "Integer")
                            {
                                DataItemTableView = SORTING(Number);
                                MaxIteration = 1;

                                trigger OnAfterGetRecord()
                                begin
                                    // P8000731
                                    case AccrualPlan."Computation Level" of
                                        AccrualPlan."Computation Level"::Document:
                                            CreateAccrual(
                                              PaidSalesInvLine."No.", TransactionDate, InvAmount, InvCost, InvQuantity, // P8005495
                                              Customer."No.", PaidSalesInvHeader."Bill-to Customer No.",
                                              AccrualJnlLine."Source Document Type"::Invoice, PaidSalesInvHeader."No.", 0);

                                        AccrualPlan."Computation Level"::Plan:
                                            AddToPlanDistribution(PaidSalesInvHeader."Bill-to Customer No.", InvAmount, InvQuantity);
                                    end;
                                    // P8000731
                                end;
                            }

                            trigger OnAfterGetRecord()
                            begin
                                StatusWindow.Update(3, "No."); // P8000731
                                TransactionDate := AccrualPlan.GetDocumentTransactionDate(PaidSalesInvHeader); // P8005495
                            end;

                            trigger OnPreDataItem()
                            begin
                                // P8000731
                                SetRange("No.", PaidDocNo);
                                SetFilter("Bill-to Customer No.", GetBillToFilter());
                                SetFilter("Sell-to Customer No.", GetSellToFilter());
                                SetFilter("Ship-to Code", GetShipToFilter());
                                // P8000731
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            AccrualCalcMgmt.GetPaidSalesDocNo(DATABASE::"Sales Invoice Header", Number = 1, PaidDocNo); // P8000731
                        end;

                        trigger OnPreDataItem()
                        begin
                            // P8000731
                            SetRange(Number, 1, NumPaidInvoices);
                            // P8000731
                        end;
                    }
                    dataitem(AccrueOnPaidCM; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        dataitem(PaidSalesCMHeader; "Sales Cr.Memo Header")
                        {
                            DataItemTableView = SORTING("No.");
                            dataitem(PaidSalesCMLine; "Sales Cr.Memo Line")
                            {
                                DataItemLink = "Document No." = FIELD("No.");
                                DataItemTableView = SORTING("Document No.", "Line No.") WHERE(Type = CONST(Item), "No." = FILTER(<> ''));

                                trigger OnAfterGetRecord()
                                begin
                                    // P8000731
                                    if not IsSalesCMShipToInPlan(PaidSalesCMLine) then
                                        CurrReport.Skip;

                                    if not AccrualPlan.IsItemInPlan("No.", TransactionDate) then // P8005495
                                        CurrReport.Skip;

                                    AccrualCalcMgmt.GetSalesCMLineAmounts(
                                      AccrualPlan, PaidSalesCMLine, CMAmount, CMCost, CMQuantity, TransactionDate); // P8005495

                                    if (AccrualPlan."Computation Level" = AccrualPlan."Computation Level"::"Document Line") then
                                        CreateAccrual(
                                          "No.", TransactionDate, CMAmount, CMCost, CMQuantity, // P8005495
                                          Customer."No.", PaidSalesCMHeader."Bill-to Customer No.",
                                          AccrualJnlLine."Source Document Type"::"Credit Memo", "Document No.", "Line No.");
                                    // P8000731
                                end;
                            }
                            dataitem(CalcPaidCMAccrual; "Integer")
                            {
                                DataItemTableView = SORTING(Number);
                                MaxIteration = 1;

                                trigger OnAfterGetRecord()
                                begin
                                    // P8000731
                                    case AccrualPlan."Computation Level" of
                                        AccrualPlan."Computation Level"::Document:
                                            CreateAccrual(
                                              PaidSalesCMLine."No.", TransactionDate, CMAmount, CMCost, CMQuantity, // P8005495
                                              Customer."No.", PaidSalesCMHeader."Bill-to Customer No.",
                                              AccrualJnlLine."Source Document Type"::"Credit Memo", PaidSalesCMHeader."No.", 0);

                                        AccrualPlan."Computation Level"::Plan:
                                            AddToPlanDistribution(PaidSalesCMHeader."Bill-to Customer No.", CMAmount, CMQuantity);
                                    end;
                                    // P8000731
                                end;
                            }

                            trigger OnAfterGetRecord()
                            begin
                                StatusWindow.Update(3, "No."); // P8000731
                                TransactionDate := AccrualPlan.GetDocumentTransactionDate(PaidSalesCMHeader); // P8005495
                            end;

                            trigger OnPreDataItem()
                            begin
                                // P8000731
                                SetRange("No.", PaidDocNo);
                                SetFilter("Bill-to Customer No.", GetBillToFilter());
                                SetFilter("Sell-to Customer No.", GetSellToFilter());
                                SetFilter("Ship-to Code", GetShipToFilter());
                                // P8000731
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            AccrualCalcMgmt.GetPaidSalesDocNo(DATABASE::"Sales Cr.Memo Header", Number = 1, PaidDocNo); // P8000731
                        end;

                        trigger OnPreDataItem()
                        begin
                            // P8000731
                            SetRange(Number, 1, NumPaidCMs);
                            // P8000731
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        // P8000731
                        if (AccrualPlan.Accrue <> AccrualPlan.Accrue::"Paid Invoices/CMs") then
                            CurrReport.Break;

                        if not AccrualCalcMgmt.LoadPaidSales(Customer."No.", StartDate, EndDate, AccrualPlan."Source Selection Type" = AccrualPlan."Source Selection Type"::"Bill-to/Pay-to", // P8001374
                          NumPaidInvoices, NumPaidCMs)                                                                                                                                      // P8001374
                        then                                                                                                                                                               // P8001374
                            CurrReport.Break;
                        // P8000731
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
                              Customer."No.", '', AccrualJnlLine."Source Document Type"::None, '', 0);
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if not AccrualCalcMgmt.GetCustomer(Customer, AccrualSourceLine, AccrualPlan, Number = 1) then // P8000274A
                        CurrReport.Break;

                    StatusWindow.Update(2, Customer."No.");
                end;

                trigger OnPreDataItem()
                begin
                    AccrualCalcMgmt.PrepareCustomer(Customer, CustomerFilters, AccrualPlan);
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
        dataitem(SearchCustomer; Customer)
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

        CustomerFilters.CopyFilters(SearchCustomer);

        StatusWindow.Open(Text003);

        AccrualCalcMgmt.SetEntryInfo(NewPostingDate, NewDocumentNo);
    end;

    var
        StartDate: Date;
        EndDate: Date;
        NewPostingDate: Date;
        NewDocumentNo: Code[20];
        CustomerFilters: Record Customer;
        Customer: Record Customer;
        AccrualSourceLine: Record "Accrual Plan Source Line";
        AccrualJnlLine: Record "Accrual Journal Line";
        TempPlanSales: Record "Sales Line" temporary;
        StatusWindow: Dialog;
        AccrualCalcMgmt: Codeunit "Accrual Calculation Management";
        ShptAmount: Decimal;
        ShptCost: Decimal;
        ShptQuantity: Decimal;
        RcptAmount: Decimal;
        RcptCost: Decimal;
        RcptQuantity: Decimal;
        InvAmount: Decimal;
        InvCost: Decimal;
        InvQuantity: Decimal;
        CMAmount: Decimal;
        CMCost: Decimal;
        CMQuantity: Decimal;
        Text001: Label 'You must specify a Start Date.';
        Text002: Label 'You must specify an End Date.';
        Text003: Label 'Generating Entries...\\Accrual Plan No.  #1##################\Customer No.      #2##################\Document No.      #3##################';
        RecalcDocAccruals: Boolean;
        AccrualFldMgmt: Codeunit "Accrual Field Management";
        NumPaidInvoices: Integer;
        NumPaidCMs: Integer;
        PaidDocNo: Code[20];
        TransactionDate: Date;
        DocumentNoErr: Label 'The value in the Document No. field must have a number so that we can assign the next number in the series.'; // P80014660
        DocumentNoErr2: Label 'In the Document No. field, specify the document number to be used.'; // P80014660

    procedure SetJnlLine(var AccrualJnlLine2: Record "Accrual Journal Line")
    begin
        AccrualJnlLine := AccrualJnlLine2;
        AccrualCalcMgmt.SetJnlLine(AccrualJnlLine);
    end;

    procedure GetBillToFilter(): Code[20]
    begin
        with AccrualPlan do                                                             // P8000274A
            if "Source Selection Type" = "Source Selection Type"::"Bill-to/Pay-to" then // P8000274A
                exit(Customer."No.");
        exit('');
    end;

    procedure GetSellToFilter(): Code[20]
    begin
        with AccrualPlan do                                                              // P8000274A
            if ("Source Selection Type" <> "Source Selection Type"::"Bill-to/Pay-to") then // P8000274A
                exit(Customer."No.");
        exit('');
    end;

    procedure GetShipToFilter(): Code[20]
    begin
        with AccrualSourceLine do                                                              // P8000274A
            if "Source Selection Type" = "Source Selection Type"::"Sell-to/Ship-to" then begin // P8000274A
                if ("Source Ship-to Code" = '') then                                               // P8000274A
                    exit(StrSubstNo('%1', ''));                                                      // P8000274A
                exit("Source Ship-to Code");                                                       // P8000274A
            end;
        exit('');
    end;

    procedure IsSalesInvShipToInPlan(var SalesInvLine: Record "Sales Invoice Line"): Boolean
    begin
        // P8000464A
        with AccrualSourceLine do
            if "Source Selection Type" = "Source Selection Type"::"Sell-to/Ship-to" then
                exit("Source Ship-to Code" = AccrualFldMgmt.GetSalesInvShipToCode(SalesInvLine));
        exit(true);
    end;

    procedure IsSalesCMShipToInPlan(var SalesCMLine: Record "Sales Cr.Memo Line"): Boolean
    begin
        // P8000464A
        with AccrualSourceLine do
            if "Source Selection Type" = "Source Selection Type"::"Sell-to/Ship-to" then
                exit("Source Ship-to Code" = AccrualFldMgmt.GetSalesCMShipToCode(SalesCMLine));
        exit(true);
    end;

    local procedure CreateAccrual(ItemNo: Code[20]; TransactionDate: Date; Amount: Decimal; Cost: Decimal; Quantity: Decimal; SourceNo: Code[20]; BillToNo: Code[20]; SourceDocType: Integer; SourceDocNo: Code[20]; SourceDocLineNo: Integer)
    var
        AccrualAmount: Decimal;
    begin
        // P8000274A - add parameter for TransactionDate
        if (SourceDocType in
            [AccrualJnlLine."Source Document Type"::None,
             AccrualJnlLine."Source Document Type"::Shipment,
             AccrualJnlLine."Source Document Type"::Invoice])
        then
            AccrualAmount := -AccrualPlan.CalcAccrualAmount(ItemNo, TransactionDate, -Amount, -Cost, -Quantity) // P8000274A
        else
            AccrualAmount := AccrualPlan.CalcAccrualAmount(ItemNo, TransactionDate, Amount, Cost, Quantity);    // P8000274A

        if (AccrualPlan."Computation Level" <> AccrualPlan."Computation Level"::Plan) then
            AccrualCalcMgmt.CreateAccrualJnlLine(
              AccrualPlan, AccrualAmount, SourceNo, BillToNo,
              SourceDocType, SourceDocNo, SourceDocLineNo)
        else
            DistributePlanAccrual(
              AccrualAmount, Amount, Quantity, SourceNo,
              SourceDocType, SourceDocNo, SourceDocLineNo);
    end;

    local procedure AddToPlanDistribution(BillToNo: Code[20]; Amount: Decimal; Qty: Decimal)
    begin
        TempPlanSales.Init;
        TempPlanSales."Document No." := BillToNo;
        if not TempPlanSales.Find then
            TempPlanSales.Insert;
        TempPlanSales.Amount := TempPlanSales.Amount + Amount;
        TempPlanSales.Quantity := TempPlanSales.Quantity + Qty;
        TempPlanSales.Modify;
    end;

    local procedure DistributePlanAccrual(AccrualAmount: Decimal; Amount: Decimal; Quantity: Decimal; SourceNo: Code[20]; SourceDocType: Integer; SourceDocNo: Code[20]; SourceDocLineNo: Integer)
    var
        AccrualAmountToPost: Decimal;
    begin
        if TempPlanSales.Find('-') then begin
            repeat
                if (AccrualPlan."Minimum Value Type" = AccrualPlan."Minimum Value Type"::Quantity) then begin
                    AccrualAmountToPost := Round(AccrualAmount * (TempPlanSales.Quantity / Quantity));
                    Quantity := Quantity - TempPlanSales.Quantity;
                end else begin
                    AccrualAmountToPost := Round(AccrualAmount * (TempPlanSales.Amount / Amount));
                    Amount := Amount - TempPlanSales.Amount;
                end;
                AccrualCalcMgmt.CreateAccrualJnlLine(
                    AccrualPlan, AccrualAmountToPost, SourceNo, TempPlanSales."Document No.",
                    SourceDocType, SourceDocNo, SourceDocLineNo);
                AccrualAmount := AccrualAmount - AccrualAmountToPost;
            until (TempPlanSales.Next = 0);
            TempPlanSales.DeleteAll;
        end;
    end;
}

