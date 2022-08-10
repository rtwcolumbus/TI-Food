report 37002461 "Production Ticket"
{
    // PR1.00, Myers Nissi, Jack Reynolds, 10 JAN 00, OLY002
    //   Production Batch tickets
    // 
    // PR1.00, Myers Nissi, Diane Fox, 9 NOV 00, PRO11 PR012
    //   Add Quality Control Specs on option
    // 
    // PR1.20
    //   Modify to work for process and package orders
    // 
    // PR1.20.01
    //   Change prompt for Quality Control Tests
    // 
    // PR2.00
    //   Item Tracking
    //   Text Constants
    // 
    // PR2.00.03
    //   BOM instructions
    // 
    // PR3.10
    //   New Production Order table
    // 
    // PR3.60
    //   Update for new item tracking
    // 
    // PR3.70
    //   Fix text constant with extra ' after package order item number
    // 
    // PR3.70.01
    //   Use PkgBOMNo when copying instruction for package order
    // 
    // PR3.70.02
    //   Modify logic for copying instructions for package order
    //   Modify for Q/C by variant
    // 
    // PR3.70.03
    //   Modified AddLotLine Function
    //    to use new GetUOMRndgPrecision function
    //    item."Rounding precision" will reflect UOM specific Rounding Precision if available
    // 
    // PR3.70.07
    // P8000152A, Myers Nissi, Jack Reynolds, 04 JAN 05
    //   Modify Q/C sections for new test types
    // 
    // PR3.70.08
    // P8000180A, Myers Nissi, Jack Reynolds, 11 FEB 05
    //   Fix problem of lot numnber appearing on blank lines
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Changes to Item Ledger keys
    // 
    // PR4.00.04
    // P8000402A, VerticalSoft, Jack Reynolds, 04 OCT 06
    //   Modify to print for all orders
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 07 MAY 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000837, VerticalSoft, Jack Reynolds, 02 JUL 10
    //   Cleanup RDLC layout issues
    // 
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // P8000905, Columbus IT, Jack Reynolds, 25 FEB 11
    //   Modified for multi-line batch orders
    // 
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues Property in the Request Page.
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10.03
    // P8001346, Columbus IT, Jack Reynolds, 10 SEP 14
    //   Fix problem with extra blank page
    // 
    // PRW18.00.01
    // P8001381, Columbus IT, Jack Reynolds, 20 APR 15
    //   fix problem with extra component lines for lot tracked items
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 08 MAR 16
    //   Expand BOM Version code to Code20
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/ProductionTicket.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Production Ticket';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Production Order"; "Production Order")
        {
            DataItemTableView = SORTING(Status, "No.") WHERE(Suborder = CONST(false));
            PrintOnlyIfDetail = true;
            RequestFilterFields = Status, "No.", "Source Type", "Source No.";
            column(ProductionOrderRec; Format(Status) + "No.")
            {
            }
            column(OrderType; Format("Order Type"))
            {
            }
            dataitem(PageLoop; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(ProductionOrderDesc; "Production Order".Description)
                {
                }
                column(ProductionOrderSourceNo; "Production Order"."Source No.")
                {
                }
                column(ProductionOrderNo; "Production Order"."No.")
                {
                }
                column(ProductionOrderLastDateModified; "Production Order"."Last Date Modified")
                {
                    IncludeCaption = true;
                }
                column(PageLoopRec; Format(Number))
                {
                }
                column(PageLoopHeader; 'PageLoop')
                {
                }
                dataitem(ProdOrderLine; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    column(ProdOrderLineRec; Format(Number))
                    {
                    }
                    column(QuantityLabel; QuantityLabel)
                    {
                    }
                    column(ProductionOrderCreationDate; "Production Order"."Creation Date")
                    {
                    }
                    column(PageLoopFormatQty; Format(TempProdOrderLine.Quantity) + ' ' + TempProdOrderLine."Unit of Measure Code")
                    {
                    }
                    column(ProductionOrderDueDate; "Production Order"."Due Date")
                    {
                    }
                    column(BatchLot; BatchLot)
                    {
                    }
                    column(TempProdOrderLineItemNo; TempProdOrderLine."Item No.")
                    {
                    }
                    column(TempProdOrderLineDesc; TempProdOrderLine.Description)
                    {
                    }
                    column(TempProdOrderLineQuantityUOMCode; Format(TempProdOrderLine.Quantity) + ' ' + TempProdOrderLine."Unit of Measure Code")
                    {
                    }
                    column(SalesHeaderNo; SalesHeader."No.")
                    {
                    }
                    column(SalesOrderLabel1; SalesOrderLabel[1])
                    {
                    }
                    column(SalesOrderLabel4; SalesOrderLabel[4])
                    {
                    }
                    column(SalesOrderLabel2; SalesOrderLabel[2])
                    {
                    }
                    column(SalesHeaderSelltoCustName; SalesHeader."Sell-to Customer Name")
                    {
                    }
                    column(SalesOrderLabel3; SalesOrderLabel[3])
                    {
                    }
                    column(SalesHeaderShpmtDate; SalesHeader."Shipment Date")
                    {
                    }
                    dataitem("Prod. Order Comment Line"; "Prod. Order Comment Line")
                    {
                        DataItemLink = Status = FIELD(Status), "Prod. Order No." = FIELD("No.");
                        DataItemLinkReference = "Production Order";
                        DataItemTableView = SORTING(Status, "Prod. Order No.", "Line No.");
                        column(ProdOrderCommentLineComment; Comment)
                        {
                        }
                        column(ProdOrderCommentLneRec; Format(Status) + "Prod. Order No." + Format("Line No."))
                        {
                        }
                        column(ProdOrderCommentLneHeader; 'ProdOrderCommentLne')
                        {
                        }
                    }
                    dataitem("Prod. Order Component"; "Prod. Order Component")
                    {
                        DataItemLink = Status = FIELD(Status), "Prod. Order No." = FIELD("No.");
                        DataItemLinkReference = "Production Order";
                        DataItemTableView = SORTING(Status, "Prod. Order No.", "Prod. Order Line No.", "Line No.");
                        column(ProdOrderComponentRec; Format(Status) + "Prod. Order No." + Format("Prod. Order Line No.") + Format("Line No."))
                        {
                        }
                        column(ProdOrderComponentHeader; 'ProdOrderComponent')
                        {
                        }
                        dataitem("Reservation Entry"; "Reservation Entry")
                        {
                            DataItemLink = "Source Subtype" = FIELD(Status), "Source ID" = FIELD("Prod. Order No."), "Source Prod. Order Line" = FIELD("Prod. Order Line No."), "Source Ref. No." = FIELD("Line No.");
                            DataItemTableView = SORTING("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Reservation Status", "Expected Receipt Date") WHERE("Source Type" = CONST(5407), "Item Tracking" = FILTER("Lot No." | "Lot and Serial No."));

                            trigger OnAfterGetRecord()
                            begin
                                AddLotLine("Prod. Order Component", Item, "Lot No.", -"Qty. to Handle (Base)"); // PR3.60
                            end;
                        }
                        dataitem("Item Ledger Entry"; "Item Ledger Entry")
                        {
                            DataItemLink = "Order No." = FIELD("Prod. Order No."), "Order Line No." = FIELD("Prod. Order Line No."), "Prod. Order Comp. Line No." = FIELD("Line No.");
                            DataItemTableView = SORTING("Order Type", "Order No.", "Order Line No.", "Entry Type", "Prod. Order Comp. Line No.") WHERE("Order Type" = CONST(Production), "Entry Type" = CONST(Consumption));

                            trigger OnAfterGetRecord()
                            begin
                                AddLotLine("Prod. Order Component", Item, "Lot No.", -Quantity); // PR3.60
                            end;
                        }
                        dataitem(LotRemainder1; "Integer")
                        {
                            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

                            trigger OnAfterGetRecord()
                            begin
                                // P800103A
                                if TotalQty > TotalLotQty then                                        // PR3.60
                                    AddLotLine("Prod. Order Component", Item, '', TotalQty - TotalLotQty); // PR3.60
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            Item.Get("Item No.");

                            // PR2.00 Begin
                            itemUOM.Get("Item No.", "Unit of Measure Code");
                            TotalQty := "Expected Qty. (Base)"; // PR3.60
                            TotalLotQty := 0;
                            // PR2.00
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange("Prod. Order Line No.", TempProdOrderLine."Line No."); // PR3.70.03
                        end;
                    }
                    dataitem(FormulaBlanks; "Integer")
                    {
                        DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 .. 3));

                        trigger OnAfterGetRecord()
                        begin
                            // PR2.00.03 Begin
                            BatchTicketLine."Line No." := BatchTicketLine."Line No." + 1;
                            BatchTicketLine.Insert;
                            // PR2.00.03 End
                        end;

                        trigger OnPreDataItem()
                        begin
                            // PR2.00.03 Begin
                            BatchTicketLine.Reset;
                            if BatchTicketLine.Find('+') then;
                            BatchTicketLine.Init;
                            BatchTicketLine."Lot No." := ''; // P8000180A
                            // PR2.00.03 End
                        end;
                    }
                    dataitem(BatchLines; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(BatchTicketLineDesc; BatchTicketLine.Description)
                        {
                        }
                        column(BatchTicketLineItemNo; BatchTicketLine."Item No.")
                        {
                        }
                        column(BatchTicketLineUOMCode; BatchTicketLine."Unit of Measure Code")
                        {
                        }
                        column(BatchTicketLineFmtQuantity; BatchTicketLine.FmtQuantity)
                        {
                        }
                        column(BatchTicketLineLotNo; BatchTicketLine."Lot No.")
                        {
                        }
                        column(BatchLinesRec; Format(Number))
                        {
                        }
                        column(BatchLinesHeader; 'BatchLines')
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            // PR2.00.03 Begin
                            if Number = 1 then
                                BatchTicketLine.Find('-')
                            else
                                BatchTicketLine.Next;
                            // PR2.00.03 End
                        end;

                        trigger OnPreDataItem()
                        begin
                            // PR2.00.03 Begin
                            BatchTicketLine.Reset;
                            SetRange(Number, 1, BatchTicketLine.Count);
                            // PR2.00.03 End;
                        end;
                    }
                    dataitem(FormulaQC; "Data Collection Line")
                    {
                        DataItemLinkReference = PageLoop;
                        DataItemTableView = SORTING("Source ID", "Source Key 1", "Source Key 2", Type, "Variant Type", "Data Element Code", "Line No.") WHERE("Source ID" = CONST(27), Type = CONST("Q/C"), Active = CONST(true));
                        column(Low; Low)
                        {
                        }
                        column(High; High)
                        {
                        }
                        column(FormulaQCCode; "Data Element Code")
                        {
                        }
                        column(FormulaQCDesc; Description)
                        {
                        }
                        column(FormulaQCType; "Data Element Type")
                        {
                        }
                        column(Target; Target)
                        {
                        }
                        column(FormulaQCRec; "Source Key 1" + Format("Variant Type") + "Data Element Code")
                        {
                        }
                        column(FormulaQCHeader; 'FormulaQC')
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            // PR3.70.02 Begin
                            if ((TempProdOrderLine."Variant Code" = '') and (FormulaQC."Variant Type" = FormulaQC."Variant Type"::"Variant Only")) or
                              ((TempProdOrderLine."Variant Code" <> '') and (FormulaQC."Variant Type" = FormulaQC."Variant Type"::"Item Only"))
                            then
                                CurrReport.Skip;
                            // PR3.70.02 End
                            // PR1.20 Begin
                            Clear(Low);
                            Clear(High);
                            Clear(Target);
                            // P8000152A Begin
                            case "Data Element Type" of
                                "Data Element Type"::Boolean:
                                    Target := Format("Boolean Target Value");
                                "Data Element Type"::"Lookup":
                                    Target := "Lookup Target Value";
                                "Data Element Type"::Numeric:
                                    begin
                                        Low := Format("Numeric Low-Low Value");    // P8001090
                                        High := Format("Numeric High-High Value"); // P8001090
                                        Target := Format("Numeric Target Value");
                                    end;
                                "Data Element Type"::Text:
                                    Target := "Text Target Value";
                            end;
                            // P8000152A Begin
                            // PR1.20 End
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange("Source Key 1", TempProdOrderLine."Item No."); // PR3.70.03, P8001090
                            if not PrintQuality then
                                SetRange("Data Element Code", ''); // P8001090
                        end;
                    }
                    dataitem(Instructions; "Manufacturing Comment Line")
                    {
                        DataItemLinkReference = PageLoop;
                        DataItemTableView = SORTING("Table Name", "No.", "Line No.") WHERE("Table Name" = CONST("Production BOM Header"), Code = CONST('INSTR'));
                        column(InstructionsComment; Comment)
                        {
                        }
                        column(InstructionsRec; Format("Table Name") + "No." + Format("Line No."))
                        {
                        }
                        column(InstructionsHeader; 'Instructions')
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            SetRange("No.", TempProdOrderLine."Production BOM No."); // PR3.70.03
                        end;
                    }
                    dataitem(VersionComments; "Manufacturing Comment Line")
                    {
                        DataItemLinkReference = PageLoop;
                        DataItemTableView = SORTING("Table Name", "No.", "Line No.") WHERE("Table Name" = CONST("Production BOM Header"));
                        column(STRProdBOMHeaderMfgBOMType; UpperCase(StrSubstNo(Text000, ProdBOMHeader."Mfg. BOM Type")))
                        {
                        }
                        column(VersionCommentsComment; Comment)
                        {
                        }
                        column(VersionCommentsRec; Format("Table Name") + "No." + Format("Line No."))
                        {
                        }
                        column(VersionCommentsHeader; 'VersionComments')
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            SetRange("No.", TempProdOrderLine."Production BOM No."); // PR3.70.03
                            SetRange(Code, TempProdOrderLine."Production BOM Version Code"); // PR3.70.03
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        // PR3.70.03 Begin
                        if Number = 1 then
                            TempProdOrderLine.Find('-')
                        else
                            TempProdOrderLine.Next;
                        // PR3.70.03 End

                        if ProdBOMHeader.Get(TempProdOrderLine."Production BOM No.") then; // PR1.20, PR3.70.03

                        if "Production Order"."Order Type" = "Production Order"."Order Type"::Package then // PR1.20
                            GetSalesDocInfo(TempProdOrderLine);                                              // PR1.20, PR3.70.03

                        BatchLot := P800ItemTracking.GetLotNoForProdOrderLine(TempProdOrderLine); // PR3.60, PR3.70.03

                        // PR2.00.03 Begin
                        BatchTicketLine.Reset;
                        BatchTicketLine.DeleteAll;
                        CopyInstructions(TempProdOrderLine."Production BOM No.", TempProdOrderLine."Production BOM Version Code"); // PR3.70.03
                        // PR2.00.03 End
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, TempProdOrderLine.Count); // PR3.70.03
                    end;
                }
                dataitem(PkgOrder; "Production Order")
                {
                    DataItemLink = Status = FIELD(Status), "Batch Prod. Order No." = FIELD("No.");
                    DataItemLinkReference = "Production Order";
                    DataItemTableView = SORTING(Status, "No.");
                    column(PkgOrderRec; Format(Status) + "No.")
                    {
                    }
                    dataitem(PkgLine; "Prod. Order Line")
                    {
                        DataItemLink = Status = FIELD(Status), "Prod. Order No." = FIELD("No.");
                        DataItemTableView = SORTING(Status, "Prod. Order No.", "Line No.");
                        column(PkgLineSalesHeaderNo; SalesHeader."No.")
                        {
                        }
                        column(PkgLineItemNo; "Item No.")
                        {
                        }
                        column(PkgLineDesc; Description)
                        {
                        }
                        column(QuantityUOMCode; Format(Quantity) + ' ' + "Unit of Measure Code")
                        {
                        }
                        column(PkgLineSalesHeaderSelltoCustName; SalesHeader."Sell-to Customer Name")
                        {
                        }
                        column(STRItemNo; StrSubstNo(Text010, "Item No."))
                        {
                        }
                        column(PkgLot; PkgLot)
                        {
                        }
                        column(PkgLineSalesHeaderShpmtDate; SalesHeader."Shipment Date")
                        {
                        }
                        column(PkgLineSalesOrderLabel1; SalesOrderLabel[1])
                        {
                        }
                        column(PkgLineSalesOrderLabel2; SalesOrderLabel[2])
                        {
                        }
                        column(PkgLineSalesOrderLabel3; SalesOrderLabel[3])
                        {
                        }
                        column(PkgLineSalesOrderLabel4; SalesOrderLabel[4])
                        {
                        }
                        column(PkgLineRec; Format(Status) + "Prod. Order No." + Format("Line No."))
                        {
                        }
                        column(PkgLineHeader; 'PkgLine')
                        {
                        }
                        dataitem(PkgBOM; "Prod. Order Component")
                        {
                            DataItemLink = Status = FIELD(Status), "Prod. Order No." = FIELD("Prod. Order No."), "Prod. Order Line No." = FIELD("Line No.");
                            DataItemTableView = SORTING(Status, "Prod. Order No.", "Prod. Order Line No.", "Line No.");
                            column(PkgBOMHeader; 'PkgBOM')
                            {
                            }
                            dataitem(PkgTrackingLine; "Reservation Entry")
                            {
                                DataItemLink = "Source Subtype" = FIELD(Status), "Source ID" = FIELD("Prod. Order No."), "Source Prod. Order Line" = FIELD("Prod. Order Line No."), "Source Ref. No." = FIELD("Line No.");
                                DataItemTableView = SORTING("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line", "Source Ref. No.", "Reservation Status", "Expected Receipt Date") WHERE("Source Type" = CONST(5407), "Item Tracking" = FILTER("Lot No." | "Lot and Serial No."));

                                trigger OnAfterGetRecord()
                                begin
                                    AddLotLine(PkgBOM, Item, "Lot No.", -"Qty. to Handle (Base)"); // PR3.60
                                end;
                            }
                            dataitem(PkgConsumption; "Item Ledger Entry")
                            {
                                DataItemLink = "Order No." = FIELD("Prod. Order No."), "Order Line No." = FIELD("Prod. Order Line No."), "Prod. Order Comp. Line No." = FIELD("Line No.");
                                DataItemTableView = SORTING("Order Type", "Order No.", "Order Line No.", "Entry Type", "Prod. Order Comp. Line No.") WHERE("Order Type" = CONST(Production), "Entry Type" = CONST(Consumption));

                                trigger OnAfterGetRecord()
                                begin
                                    AddLotLine(PkgBOM, Item, "Lot No.", -Quantity); // PR3.60
                                end;
                            }
                            dataitem(LotRemainder2; "Integer")
                            {
                                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

                                trigger OnAfterGetRecord()
                                begin
                                    if TotalQty > TotalLotQty then                       // PR3.60
                                        AddLotLine(PkgBOM, Item, '', TotalQty - TotalLotQty); // PR3.60
                                end;
                            }

                            trigger OnAfterGetRecord()
                            begin
                                Item.Get("Item No.");

                                // PR2.00 Begin
                                itemUOM.Get("Item No.", "Unit of Measure Code");
                                TotalQty := "Expected Qty. (Base)"; // PR3.60
                                TotalLotQty := 0;
                                // PR2.00
                            end;
                        }
                        dataitem(PkgBlanks; "Integer")
                        {
                            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 .. 1));

                            trigger OnAfterGetRecord()
                            begin
                                // PR2.00.03 Begin
                                BatchTicketLine."Line No." := BatchTicketLine."Line No." + 1;
                                BatchTicketLine.Insert;
                                // PR2.00.03 End
                            end;

                            trigger OnPreDataItem()
                            begin
                                // PR2.00.03 Begin
                                BatchTicketLine.Reset;
                                if BatchTicketLine.Find('+') then;
                                BatchTicketLine.Init;
                                BatchTicketLine."Lot No." := ''; // P8000180A
                                // PR2.00.03 End
                            end;
                        }
                        dataitem(PkgLines; "Integer")
                        {
                            DataItemTableView = SORTING(Number);
                            column(PkgLinesBatchTicketLineLotNo; BatchTicketLine."Lot No.")
                            {
                            }
                            column(PkgLinesBatchTicketLineDesc; BatchTicketLine.Description)
                            {
                            }
                            column(PkgLinesBatchTicketLineItemNo; BatchTicketLine."Item No.")
                            {
                            }
                            column(PkgLinesBatchTicketLineUOMCode; BatchTicketLine."Unit of Measure Code")
                            {
                            }
                            column(PkgLinesBatchTicketLineFmtQuantity; BatchTicketLine.FmtQuantity)
                            {
                            }
                            column(PkgLinesRec; Format(Number))
                            {
                            }
                            column(PkgLinesHeader; 'PkgLines')
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                // PR2.00.03 Begin
                                if Number = 1 then
                                    BatchTicketLine.Find('-')
                                else
                                    BatchTicketLine.Next;
                                // PR2.00.03 End
                            end;

                            trigger OnPreDataItem()
                            begin
                                // PR2.00.03 Begin
                                BatchTicketLine.Reset;
                                SetRange(Number, 1, BatchTicketLine.Count);
                                // PR2.00.03 End;
                            end;
                        }
                        dataitem(PkgQC; "Data Collection Line")
                        {
                            DataItemLink = "Source Key 1" = FIELD("Item No.");
                            DataItemTableView = SORTING("Source ID", "Source Key 1", "Source Key 2", Type, "Variant Type", "Data Element Code", "Line No.") WHERE("Source ID" = CONST(27), Type = CONST("Q/C"), Active = CONST(true));
                            column(PkgQCCode; "Data Element Code")
                            {
                            }
                            column(PkgQCDesc; Description)
                            {
                            }
                            column(PkgQCType; "Data Element Type")
                            {
                            }
                            column(PkgQCLow; Low)
                            {
                            }
                            column(PkgQCHigh; High)
                            {
                            }
                            column(PkgQCTarget; Target)
                            {
                            }
                            column(PkgQCRec; "Source Key 1" + Format("Variant Type") + "Data Element Code")
                            {
                            }
                            column(PkgQCHeader; 'PkgQC')
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                // PR3.70.02 Begin
                                if ((PkgLine."Variant Code" = '') and (PkgQC."Variant Type" = PkgQC."Variant Type"::"Variant Only")) or
                                  ((PkgLine."Variant Code" <> '') and (PkgQC."Variant Type" = PkgQC."Variant Type"::"Item Only"))
                                then
                                    CurrReport.Skip;
                                // PR3.70.02 End
                                // PR1.20 Begin
                                Clear(Low);
                                Clear(High);
                                Clear(Target);
                                // P8000152A Begin
                                case Type of
                                    "Data Element Type"::Boolean:
                                        Target := Format("Boolean Target Value");
                                    "Data Element Type"::"Lookup":
                                        Target := "Lookup Target Value";
                                    "Data Element Type"::Numeric:
                                        begin
                                            Low := Format("Numeric Low-Low Value");    // P8001090
                                            High := Format("Numeric High-High Value"); // P8001090
                                            Target := Format("Numeric Target Value");
                                        end;
                                    "Data Element Type"::Text:
                                        Target := "Text Target Value";
                                end;
                                // P8000152A Begin
                                // PR1.20 End
                            end;

                            trigger OnPreDataItem()
                            begin
                                if not PrintQuality then
                                    SetRange("Data Element Code", ''); // PR1.20, P8001090
                            end;
                        }
                        dataitem(PkgInstructions; "Manufacturing Comment Line")
                        {
                            DataItemLink = "No." = FIELD("Production BOM No.");
                            DataItemTableView = SORTING("Table Name", "No.", "Line No.") WHERE("Table Name" = CONST("Production BOM Header"), Code = CONST('INSTR'));
                            column(PkgInstComment; Comment)
                            {
                            }
                            column(PkgInstRec; Format("Table Name") + "No." + Format("Line No."))
                            {
                            }
                            column(PkgInstHeader; 'PkgInstructions')
                            {
                            }
                        }

                        trigger OnAfterGetRecord()
                        var
                            BOMNo: Code[20];
                            VersionNo: Code[20];
                        begin
                            GetSalesDocInfo(PkgLine); // PR1.20

                            PkgLot := P800ItemTracking.GetLotNoForProdOrderLine(PkgLine); // PR3.60

                            // PR2.00.03 Begin
                            BatchTicketLine.Reset;
                            BatchTicketLine.DeleteAll;
                            // PR3.70.02 Begin
                            BOMNo := "Production BOM No.";
                            VersionNo := "Production BOM Version Code";
                            if PkgBOMNo <> '' then begin
                                BOMNo := PkgBOMNo;
                                VersionNo := VersionMgt.GetBOMVersion(BOMNo, "Due Date", true);
                            end;
                            CopyInstructions(BOMNo, VersionNo);
                            // PR3.70.02 End
                            // PR2.00.03 End
                        end;
                    }

                    trigger OnPostDataItem()
                    begin
                        if StartOnOddPage and (1 = CurrReport.PageNo mod 2) then
                            CurrReport.NewPage;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetFilter("No.", '<>%1', "Production Order"."No.");
                    end;
                }
            }

            trigger OnAfterGetRecord()
            var
                ProdOrderLine: Record "Prod. Order Line";
            begin
                // PR1.20 Begin
                if "Order Type" = "Order Type"::Batch then
                    QuantityLabel := Text001
                else
                    QuantityLabel := Text002;
                // PR1.20 End

                // PR3.70.03 Begin
                TempProdOrderLine.Reset;
                TempProdOrderLine.DeleteAll;
                if "Production Order"."Family Process Order" then begin
                    TempProdOrderLine.Init;
                    TempProdOrderLine.Status := Status;
                    TempProdOrderLine."Prod. Order No." := "No.";
                    TempProdOrderLine."Line No." := 0;
                    TempProdOrderLine."Production BOM No." := "Source No.";
                    TempProdOrderLine."Production BOM Version Code" := '1';
                    TempProdOrderLine.Insert;
                end else begin
                    ProdOrderLine.SetRange(Status, Status);
                    ProdOrderLine.SetRange("Prod. Order No.", "No.");
                    if ProdOrderLine.Find('-') then
                        repeat
                            TempProdOrderLine := ProdOrderLine;
                            TempProdOrderLine.Insert;
                        until ProdOrderLine.Next = 0;
                end;
                // PR3.70.03 End
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
                    field(StartOnOddPage; StartOnOddPage)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Start on Odd Page:';
                        Visible = false;
                    }
                    field(PrintQuality; PrintQuality)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Print Quality Control Tests?';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            // PR1.20 Begin
            ProcessSetup.Get;
            PrintQuality := ProcessSetup."Prod. Ticket Print Quality";
            // PR1.20 End
        end;
    }

    labels
    {
        ProductCaption = 'Product:';
        ProductionOrderNoCaption = 'Production Order No.:';
        OrderDateCaption = 'Order Date:';
        DateRequiredCaption = 'Date Required:';
        DateProducedCaption = 'Date Produced:';
        QuantityProducedCaption = 'Quantity Produced:';
        FinishedItemCaption = 'Finished Item:';
        FinishedQuantityCaption = 'Finished Quantity:';
        PRODUCTIONORDERCOMMENTSCaption = 'PRODUCTION ORDER COMMENTS';
        ItemQtyCaption = 'Item Qty';
        UOMCaption = 'UOM';
        ItemNoCaption = 'Item No.';
        DescriptionCaption = 'Description';
        LotNoCaption = 'Lot No.';
        ActualQtyUsedCaption = 'Actual Qty Used';
        HighCaption = 'High';
        LowCaption = 'Low';
        TestCodeCaption = 'Test Code';
        DescriptionFCaption = 'Description';
        TypeCaption = 'Type';
        TargetCaption = 'Target';
        ResultCaption = 'Result';
        RangeCaption = 'Range';
        PRODUCTIONINSTRUCTIONSCaption = 'PRODUCTION INSTRUCTIONS';
        ExpectedItemQtyCaption = 'Expected Item Qty';
        PageCaption = 'Page';
    }

    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ProdXref: Record "Production Order XRef";
        Item: Record Item;
        itemUOM: Record "Item Unit of Measure";
        ProcessSetup: Record "Process Setup";
        ProdBOMHeader: Record "Production BOM Header";
        BatchTicketLine: Record "Batch Ticket Line" temporary;
        TempProdOrderLine: Record "Prod. Order Line" temporary;
        BatchLot: Code[20];
        PkgLot: Code[20];
        DisplayQty: Text[20];
        SalesOrderLabel: array[4] of Text[30];
        Low: Text[30];
        High: Text[30];
        Target: Text[30];
        QuantityLabel: Text[30];
        Text000: Label '%1 VERSION COMMENTS';
        TotalQty: Decimal;
        TotalLotQty: Decimal;
        LotDetail: Boolean;
        StartOnOddPage: Boolean;
        PrintQuality: Boolean;
        Text001: Label 'Batch Quantity:';
        Text002: Label 'Expected Quantity:';
        Text004: Label 'Sales Order No.:';
        Text005: Label 'Customer:';
        Text006: Label 'Ship Date:';
        Text007: Label 'STOCK ORDER';
        Text010: Label '* * * * * * * * * * * * *        PACKAGING INSTRUCTIONS FOR %1        * * * * * * * * * * * * *';
        P800ItemTracking: Codeunit "Process 800 Item Tracking";
        VersionMgt: Codeunit VersionManagement;

    procedure SetFlags(quality: Boolean)
    begin
        PrintQuality := quality;
    end;

    procedure GetSalesDocInfo(ProdOrderLine: Record "Prod. Order Line")
    begin
        // PR1.20 Begin
        Clear(SalesHeader);
        Clear(SalesLine);
        Clear(SalesOrderLabel);

        ProdXref.SetRange("Prod. Order Status", ProdOrderLine.Status);
        ProdXref.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
        ProdXref.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
        ProdXref.SetRange("Source Table ID", DATABASE::"Sales Line"); // PR2.00
        if ProdXref.Find('-') then begin
            if SalesHeader.Get(ProdXref."Source Type", ProdXref."Source No.") then begin // PR2.00
                SalesLine.Get(ProdXref."Source Type", ProdXref."Source No.", ProdXref."Source Line No."); // PR2.00
                SalesOrderLabel[1] := Text004;
                SalesOrderLabel[2] := Text005;
                SalesOrderLabel[3] := Text006;
            end else
                SalesOrderLabel[4] := Text007;
        end else
            SalesOrderLabel[4] := Text007;
        // PR1.20 End
    end;

    procedure CopyInstructions(BOMNo: Code[20]; BOMVersion: Code[20])
    var
        ProdBOMLine: Record "Production BOM Line";
    begin
        // PR2.00.03 Begin
        ProdBOMLine.SetRange("Production BOM No.", BOMNo);
        ProdBOMLine.SetRange("Version Code", BOMVersion);
        ProdBOMLine.SetRange(Type, ProdBOMLine.Type::" ");
        if ProdBOMLine.Find('-') then
            repeat
                BatchTicketLine.Init;
                BatchTicketLine."Step Code" := ProdBOMLine."Step Code";
                BatchTicketLine.Type := BatchTicketLine.Type::Text;
                BatchTicketLine."Line No." := ProdBOMLine."Line No.";
                BatchTicketLine."Lot No." := '';
                BatchTicketLine.Description := ProdBOMLine.Description;
                BatchTicketLine.Insert;
            until ProdBOMLine.Next = 0;
        // PR2.00.03 End
    end;

    procedure AddLotLine(ProdOrderComp: Record "Prod. Order Component"; Item: Record Item; LotNo: Code[50]; Qty: Decimal)
    begin
        // PR3.60 Begin
        TotalLotQty += Qty;
        if not BatchTicketLine.Get(ProdOrderComp."Step Code", BatchTicketLine.Type::Item, ProdOrderComp."Line No.", LotNo) then begin
            BatchTicketLine.Init;
            BatchTicketLine."Step Code" := ProdOrderComp."Step Code";
            BatchTicketLine.Type := BatchTicketLine.Type::Item;
            BatchTicketLine."Line No." := ProdOrderComp."Line No.";
            BatchTicketLine."Lot No." := LotNo;
            BatchTicketLine."Item No." := ProdOrderComp."Item No.";
            BatchTicketLine."Unit of Measure Code" := ProdOrderComp."Unit of Measure Code";
            BatchTicketLine."Qty. per Unit of Measure" := ProdOrderComp."Qty. per Unit of Measure";
            Item.GetItemUOMRndgPrecision(ProdOrderComp."Unit of Measure Code", true); // PR3.70.03
            BatchTicketLine."Rounding Precision" := Item."Rounding Precision";
            BatchTicketLine.Description := ProdOrderComp.Description;
            BatchTicketLine."Quantity (Base)" := Qty;
            BatchTicketLine.Insert;
        end else begin
            BatchTicketLine."Quantity (Base)" += Qty;
            BatchTicketLine.Modify;
        end;
        // PR3.60 End
    end;
}

