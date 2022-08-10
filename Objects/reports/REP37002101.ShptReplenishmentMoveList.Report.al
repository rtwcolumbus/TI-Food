report 37002101 "Shpt. Replenishment/Move List"
{
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    // 
    // PRW16.00.03
    // P8000812, VerticalSoft, Rick Tweedle, 06 APR 10
    //   RTC Reporting Upgrade
    // 
    // PRW16.00.04
    // P8000848, VerticalSoft, Jack Reynolds, 21 JUL 10
    //   Fix problem with not creating journal lines
    // 
    // P8000864, VerticalSoft, Jack Reynolds, 27 AUG 10
    //   Fix paper size issue with RDLC
    // 
    // PRW16.00.06
    // P8001034, Columbus IT, Jack Reynolds, 10 FEB 12
    //   Change codeunit for Warehouse Employee functions
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 20 FEB 13
    //   Restoring the SaveValues property in the Request Page.
    // 
    // PRW17.10
    // P8001221, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Type added to Item table
    // 
    // PRW17.10.02
    // P8001278, Columbus IT, Jack Reynolds, 04 FEB 14
    //   Allow move list reports to suggest receiving and/or output bins
    // 
    // PRW17.10.03
    // P8001312, Columbus IT, Jack Reynolds, 17 APR 14
    //   Fix problem with quantity on journal lines
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 07 DEC 16
    //   Item Category/Product Group
    // 
    // PRW111.00.02
    // P80070245, To-Increase, Gangabhushan, 26 FEB 19
    //   TI-12783 & TI-12784 - Shpt. Replenishment/Move List does not group by route when run with that option
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/ShptReplenishmentMoveList.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Shpt. Replenishment/Move List';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.") WHERE(Type = CONST(Inventory));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Item Category Code";

            trigger OnPreDataItem()
            begin
                ItemFilters.Copy(Item);

                CurrReport.Break;
            end;
        }
        dataitem(WhseReqFilters; "Warehouse Request")
        {
            DataItemTableView = SORTING(Type, "Location Code", "Completely Handled", "Document Status", "Expected Receipt Date", "Shipment Date", "Source Document", "Source No.") WHERE(Type = CONST(Outbound), "Source Document" = FILTER("Sales Order" | "Purchase Return Order" | "Outbound Transfer"), "Document Status" = CONST(Released), "Completely Handled" = CONST(false));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Source Document", "Source No.";

            trigger OnPreDataItem()
            begin
                P800ReplMgmt.BuildShptReplTotals(
                  LocationCode, ShipmentDate, DeliveryRouteFilter, ItemFilters, WhseReqFilters,
                  (ShowOrderReport <> ShowOrderReport::None) or (GenerateJnlLines = GenerateJnlLines::"Detail (by Order)"));

                CurrReport.Break;
            end;
        }
        dataitem(ItemLoop; "Integer")
        {
            DataItemTableView = SORTING(Number);
            PrintOnlyIfDetail = true;
            column(ItemLoopHeaderShipDate; HeaderShipDate)
            {
            }
            column(ItemLoopHeaderInfo; HeaderInfo)
            {
            }
            column(ItemLoopHeaderTitle; HeaderTitle)
            {
            }
            column(ItemLoopNumber; Number)
            {
            }
            column(ItemLoopBody; 'ItemLoopBody')
            {
            }
            dataitem(ItemBinLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(CurrItemNo; CurrItem."No.")
                {
                }
                column(CurrItemDescription; CurrItem.Description)
                {
                }
                column(CurrUOMCode; CurrUOMCode)
                {
                }
                column(CurrQty; CurrQty)
                {
                    DecimalPlaces = 0 : 5;
                }
                column(QtyAvailBase; QtyAvailBase)
                {
                    DecimalPlaces = 0 : 5;
                }
                column(CurrQtyBase; CurrQtyBase)
                {
                    DecimalPlaces = 0 : 5;
                }
                column(ReplQtyBase; ReplQtyBase)
                {
                    DecimalPlaces = 0 : 5;
                }
                column(ReplQty; ReplQty)
                {
                    DecimalPlaces = 0 : 5;
                }
                column(CurrItemBaseUOM; CurrItem."Base Unit of Measure")
                {
                }
                column(CurrBinCode; CurrBin.Code)
                {
                }
                column(ItemBinLoopBody; 'ItemBinLoopBody')
                {
                }
                column(ItemBinLoopNumber; Number)
                {
                }
                column(NumItemsPrinted; NumItemsPrinted)
                {
                }
                column(SuggestPicks; SuggestPicks)
                {
                }
                column(FormatTransTypeCurrTransType; FormatTransType(CurrTransType))
                {
                }
                column(CurrVariantCode; CurrVariantCode)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if not P800ReplMgmt.GetReplItemBin(
                             Number = 1, CurrVariantCode, CurrTransType, CurrBin, CurrUOMCode, CurrQty) // P8001083
                    then
                        CurrReport.Break;

                    CurrQty := Round(CurrQty, 0.00001);
                    CurrItemUOM.Get(CurrItem."No.", CurrUOMCode);
                    CurrQtyBase := Round(CurrQty * CurrItemUOM."Qty. per Unit of Measure", 0.00001);

                    QtyAvailBase :=
                      P800ReplMgmt.GetQtyAvailBase(
                        LocationCode, CurrBin.Code, CurrItem."No.", CurrVariantCode, CurrTransType, CurrUOMCode); // P8001083
                    if (CurrQtyBase > QtyAvailBase) then
                        ReplQtyBase := CurrQtyBase - QtyAvailBase
                    else
                        ReplQtyBase := 0;
                    ReplQty := Round(ReplQtyBase / CurrItemUOM."Qty. per Unit of Measure", 0.00001);

                    if RoundUpToWholeQtys then
                        ReplQty := Round(ReplQty, 1, '>');
                    RTC_ReplQty += ReplQty;   // P8000812

                    if (GenerateJnlLines = GenerateJnlLines::"Summary (by Item)") and (ReplQty <> 0) then
                        InsertItemJnlLine(
                          PostingDate, DocumentNo, CurrItem."No.", CurrVariantCode,
                          LocationCode, CurrBin.Code, CurrUOMCode, ReplQty, 0, '', 0);

                    if (ReplQty = 0) and (not ShowAllItems) then
                        CurrReport.Skip;

                    NumItemsPrinted := NumItemsPrinted + 1;
                end;

                trigger OnPostDataItem()
                begin
                    if IsServiceTier then       // P8000812
                        ReplQty := RTC_ReplQty;   // P8000812
                end;

                trigger OnPreDataItem()
                begin
                    Clear(RTC_ReplQty);   // P8000812
                    NumItemsPrinted := 0;

                    SetFilter(Number, '1..');
                end;
            }
            dataitem(SuggestBinLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(SuggBinUOMMsg; SuggBinUOMMsg)
                {
                }
                column(TempBinSuggUOMCode; TempBinSuggestion."Unit of Measure Code")
                {
                }
                column(TempBinSuggQuantity; TempBinSuggestion.Quantity)
                {
                    DecimalPlaces = 0 : 5;
                }
                column(TempBinSuggLotNo; TempBinSuggestion."Lot No.")
                {
                }
                column(TempBinSuggBinCode; TempBinSuggestion."Bin Code")
                {
                }
                column(SuggestBinLoopBody; 'SuggestBinLoopBody')
                {
                }
                column(SuggestBinLoopNumber; Number)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if not P800ReplMgmt.GetSuggBinLine(Number = 1, TempBinSuggestion) then
                        CurrReport.Break;

                    P800ReplMgmt.GetSuggBinUOMMsg(
                      ReplQty, CurrUOMCode, TempBinSuggestion, SuggBinUOMMsg);
                end;

                trigger OnPreDataItem()
                begin
                    P800ReplMgmt.SetPickBinOverride(AllowRecvBin, AllowOutputBin); // P8001278
                    if not P800ReplMgmt.GetSuggestedPicks(
                             SuggestPicks, PicksSuggested, LocationCode, CurrItem."No.",
                             CurrVariantCode, CurrTransType, ReplQty, CurrUOMCode, TempBinSuggestion) // P8001083
                    then
                        CurrReport.Break;

                    SetFilter(Number, '1..');
                end;
            }
            dataitem(NoSuggestBinLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                MaxIteration = 1;
                column(NoSuggestBinLoopNumber; Number)
                {
                }

                trigger OnPreDataItem()
                begin
                    if not P800ReplMgmt.ShowNoSuggBins(SuggestPicks, PicksSuggested, ReplQty) then
                        CurrReport.Break;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if not P800ReplMgmt.GetReplItem(Number = 1, 0, CurrItem) then
                    CurrReport.Break;
            end;

            trigger OnPreDataItem()
            begin
                SetFilter(Number, '1..');

                // P8000812 S
                HeaderTitle := Text007;
                HeaderInfo := StrSubstNo('%1 - %2', Location.Code, Location.Name);
                HeaderShipDate := Format(ShipmentDate, 0, Text006);
                // P8000812 E
            end;
        }
        dataitem(BuildSalesJnlLines; "Integer")
        {
            DataItemTableView = SORTING(Number);

            trigger OnAfterGetRecord()
            begin
                if not P800ReplMgmt.GetReplSalesOrderDetail(Number = 1, SalesLine) then
                    CurrReport.Break;

                InsertItemJnlLine(
                  PostingDate, DocumentNo, SalesLine."No.", SalesLine."Variant Code",
                  LocationCode, Location."Shipment Bin Code (1-Doc)",
                  SalesLine."Unit of Measure Code", SalesLine."Outstanding Quantity" - SalesLine."Qty. to Ship", // P8001312
                  ItemJnlLine."Pick Source Type"::"Sales Order",
                  SalesLine."Document No.", SalesLine."Line No.");
            end;

            trigger OnPreDataItem()
            begin
                if (GenerateJnlLines <> GenerateJnlLines::"Detail (by Order)") then
                    CurrReport.Break;

                SetFilter(Number, '1..');
            end;
        }
        dataitem(BuildPurchJnlLines; "Integer")
        {
            DataItemTableView = SORTING(Number);

            trigger OnAfterGetRecord()
            begin
                if not P800ReplMgmt.GetReplPurchRetOrderDetail(Number = 1, PurchLine) then
                    CurrReport.Break;

                InsertItemJnlLine(
                  PostingDate, DocumentNo, PurchLine."No.", PurchLine."Variant Code",
                  LocationCode, Location."Shipment Bin Code (1-Doc)",
                  PurchLine."Unit of Measure Code", PurchLine."Outstanding Quantity" - PurchLine."Return Qty. to Ship", // P8001312
                  ItemJnlLine."Pick Source Type"::"Purchase Return Order",
                  PurchLine."Document No.", PurchLine."Line No.");
            end;

            trigger OnPreDataItem()
            begin
                if (GenerateJnlLines <> GenerateJnlLines::"Detail (by Order)") then
                    CurrReport.Break;

                SetFilter(Number, '1..');
            end;
        }
        dataitem(BuildTransJnlLines; "Integer")
        {
            DataItemTableView = SORTING(Number);

            trigger OnAfterGetRecord()
            begin
                if not P800ReplMgmt.GetReplTransOrderDetail(Number = 1, TransLine) then
                    CurrReport.Break;

                InsertItemJnlLine(
                  PostingDate, DocumentNo, TransLine."Item No.", TransLine."Variant Code",
                  LocationCode, Location."Shipment Bin Code (1-Doc)",
                  TransLine."Unit of Measure Code", TransLine."Outstanding Quantity" - TransLine."Qty. to Ship", // P8001312
                  ItemJnlLine."Pick Source Type"::"Outbound Transfer",
                  TransLine."Document No.", TransLine."Line No.");
            end;

            trigger OnPreDataItem()
            begin
                if (GenerateJnlLines <> GenerateJnlLines::"Detail (by Order)") then
                    CurrReport.Break;

                SetFilter(Number, '1..');
            end;
        }
        dataitem(OrderReport; "Integer")
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;
            PrintOnlyIfDetail = true;
            column(OrderReportNumber; Number)
            {
            }
            dataitem(WhseReq; "Warehouse Request")
            {
                DataItemTableView = SORTING(Type, "Location Code", "Completely Handled", "Document Status", "Expected Receipt Date", "Shipment Date", "Source Document", "Source No.") WHERE(Type = CONST(Outbound), "Source Document" = FILTER("Sales Order" | "Purchase Return Order" | "Outbound Transfer"), "Document Status" = CONST(Released), "Completely Handled" = CONST(false));
                PrintOnlyIfDetail = true;
                column(WhseReqHeaderShipDate; HeaderShipDate)
                {
                }
                column(WhseReqHeaderTitle; HeaderTitle)
                {
                }
                column(WhseReqBody; 'WhseReqBody')
                {
                }
                dataitem(SalesHeader1; "Sales Header")
                {
                    DataItemLink = "Document Type" = FIELD("Source Subtype"), "No." = FIELD("Source No.");
                    DataItemTableView = SORTING("Document Type", "No.");
                    PrintOnlyIfDetail = true;
                    column(SalesHeader1STRDocTypeNo; StrSubstNo(Text003, "Document Type", "No."))
                    {
                    }
                    column(SalesHeader1DocType; "Document Type")
                    {
                    }
                    column(SalesHeader1No; "No.")
                    {
                    }
                    dataitem(SalesLine1; "Sales Line")
                    {
                        DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                        DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") WHERE(Type = FILTER(Item | FOODContainer), "No." = FILTER(<> ''));
                        column(SalesLine1No; "No.")
                        {
                            IncludeCaption = true;
                        }
                        column(SalesLine1Desc; Description)
                        {
                            IncludeCaption = true;
                        }
                        column(SalesLine1Quantity; Quantity)
                        {
                            IncludeCaption = true;
                        }
                        column(SalesLine1UOMCode; "Unit of Measure Code")
                        {
                            IncludeCaption = true;
                        }
                        column(SalesLine1DocType; "Document Type")
                        {
                        }
                        column(SalesLine1DocNo; "Document No.")
                        {
                        }
                        column(SalesLine1LineNo; "Line No.")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if not P800ReplMgmt.FindReplSalesOrderLine(SalesLine1) then
                                CurrReport.Skip;
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        if (WhseReq."Source Document" <> WhseReq."Source Document"::"Sales Order") then
                            CurrReport.Break;
                    end;
                }
                dataitem(PurchaseHeader1; "Purchase Header")
                {
                    DataItemLink = "Document Type" = FIELD("Source Subtype"), "No." = FIELD("Source No.");
                    DataItemTableView = SORTING("Document Type", "No.");
                    PrintOnlyIfDetail = true;
                    column(PurchHeader1STRDocTypeNo; StrSubstNo(Text004, "Document Type", "No."))
                    {
                    }
                    column(PurchHeader1DocumentType; "Document Type")
                    {
                    }
                    column(PurchHeader1No; "No.")
                    {
                    }
                    dataitem(PurchaseLine1; "Purchase Line")
                    {
                        DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                        DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") WHERE(Type = FILTER(Item), "No." = FILTER(<> ''));
                        column(PurchLine1No; "No.")
                        {
                        }
                        column(PurchLine1Desc; Description)
                        {
                        }
                        column(PurchLine1UOMCode; "Unit of Measure Code")
                        {
                        }
                        column(PurchLine1Quantity; Quantity)
                        {
                        }
                        column(PurchLine1DocType; "Document Type")
                        {
                        }
                        column(PurchLine1DocNo; "Document No.")
                        {
                        }
                        column(PurchLine1LineNo; "Line No.")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if not P800ReplMgmt.FindReplPurchRetOrderLine(PurchaseLine1) then
                                CurrReport.Skip;
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        if (WhseReq."Source Document" <> WhseReq."Source Document"::"Purchase Return Order") then
                            CurrReport.Break;
                    end;
                }
                dataitem(TransferHeader1; "Transfer Header")
                {
                    DataItemLink = "No." = FIELD("Source No.");
                    DataItemTableView = SORTING("No.");
                    PrintOnlyIfDetail = true;
                    column(STRNo; StrSubstNo(Text005, "No."))
                    {
                    }
                    column(TransferHeader1No; "No.")
                    {
                    }
                    dataitem(TransferLine1; "Transfer Line")
                    {
                        DataItemLink = "Document No." = FIELD("No.");
                        DataItemTableView = SORTING("Document No.", "Line No.") WHERE("Item No." = FILTER(<> ''));
                        column(TransferLine1ItemNo; "Item No.")
                        {
                        }
                        column(TransferLine1Desc; Description)
                        {
                        }
                        column(TransferLine1UOMCode; "Unit of Measure Code")
                        {
                        }
                        column(TransferLine1Quantity; Quantity)
                        {
                        }
                        column(TransferLine1DocNo; "Document No.")
                        {
                        }
                        column(TransferLine1LineNo; "Line No.")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if not P800ReplMgmt.FindReplTransOrderLine(TransferLine1) then
                                CurrReport.Skip;
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        if (WhseReq."Source Document" <> WhseReq."Source Document"::"Outbound Transfer") then
                            CurrReport.Break;
                    end;
                }

                trigger OnPreDataItem()
                begin
                    SetRange("Location Code", LocationCode);
                    SetRange("Shipment Date", ShipmentDate);
                end;
            }

            trigger OnPreDataItem()
            begin
                if (ShowOrderReport <> ShowOrderReport::"By Order No.") then
                    CurrReport.Break;

                CurrReport.PageNo(0);
                CurrReport.NewPage;

                // P8000812 S
                HeaderTitle := Text008;
                HeaderInfo := '';
                HeaderShipDate := Format(ShipmentDate, 0, Text006);
                // P8000812 E
            end;
        }
        dataitem(OrderReportByRoute; "Integer")
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;
            PrintOnlyIfDetail = true;
            column(OrderReportByRouteNumber; Number)
            {
            }
            dataitem(RouteHeader; "Sales Header")
            {
                DataItemTableView = SORTING("Document Type", "Shipment Date", "Delivery Route No.", "Delivery Stop No.") WHERE("Document Type" = CONST(Order), "Delivery Route No." = FILTER(<> ''));
                PrintOnlyIfDetail = true;
                column(RouteHeaderBody; 'RouteHeaderBody')
                {
                }
                dataitem(DeliveryRoute; "Delivery Route")
                {
                    DataItemLink = "No." = FIELD("Delivery Route No.");
                    DataItemTableView = SORTING("No.");
                    PrintOnlyIfDetail = true;
                    column(DeliveryRouteBody; 'DeliveryRouteBody')
                    {
                    }
                    column(DeliveryRouteNo; DeliveryRoute."No.")
                    {
                    }
                    dataitem(RoutePageHeader; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        MaxIteration = 1;
                        PrintOnlyIfDetail = true;
                        column(RoutePageHeaderHeaderShipDate; HeaderShipDate)
                        {
                        }
                        column(RoutePageHeaderHeaderInfo; HeaderInfo)
                        {
                        }
                        column(RoutePageHeaderHeaderTitle; HeaderTitle)
                        {
                        }
                        column(RoutePageHeaderBody; 'RoutePageHeaderBody')
                        {
                        }
                        dataitem(PurchaseHeader2; "Purchase Header")
                        {
                            DataItemTableView = SORTING("Document Type", "No.") WHERE("Document Type" = CONST("Return Order"));
                            PrintOnlyIfDetail = true;
                            column(PurchHeader2STRDocTypeNo; StrSubstNo(Text004, "Document Type", "No."))
                            {
                            }
                            column(PurchHeader2DocType; "Document Type")
                            {
                            }
                            column(PurchHeader2No; "No.")
                            {
                            }
                            dataitem(PurchaseLine2; "Purchase Line")
                            {
                                DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") WHERE(Type = FILTER(Item), "No." = FILTER(<> ''));
                                column(PurchLine2No; "No.")
                                {
                                }
                                column(PurchLine2Desc; Description)
                                {
                                }
                                column(PurchLine2UOMCode; "Unit of Measure Code")
                                {
                                }
                                column(PurchLine2Quantity; Quantity)
                                {
                                }
                                column(PurchLine2DocType; "Document Type")
                                {
                                }
                                column(PurchLine2DocNo; "Document No.")
                                {
                                }
                                column(PurchLine2LineNo; "Line No.")
                                {
                                }

                                trigger OnAfterGetRecord()
                                begin
                                    if not P800ReplMgmt.FindReplPurchRetOrderLine(PurchaseLine2) then
                                        CurrReport.Skip;
                                end;
                            }

                            trigger OnPreDataItem()
                            begin
                                SetRange("Location Code", LocationCode);
                                SetRange("Expected Receipt Date", ShipmentDate);
                                SetRange("Delivery Route No.", DeliveryRoute."No.");
                            end;
                        }
                        dataitem(SalesHeader2; "Sales Header")
                        {
                            DataItemTableView = SORTING("Document Type", "Shipment Date", "Delivery Route No.", "Delivery Stop No.") WHERE("Document Type" = CONST(Order));
                            PrintOnlyIfDetail = true;
                            column(STRDeliveryStopNo; StrSubstNo('%1 %2', FieldCaption("Delivery Stop No."), "Delivery Stop No."))
                            {
                            }
                            column(SalesHeader2STRDocTypeNo; StrSubstNo(Text003, "Document Type", "No."))
                            {
                            }
                            column(SalesHeader2DeliveryStopNo; SalesHeader2."Delivery Stop No.")
                            {
                            }
                            column(SalesHeader2DoType; "Document Type")
                            {
                            }
                            column(SalesHeader2No; "No.")
                            {
                            }
                            dataitem(SalesLine2; "Sales Line")
                            {
                                DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") WHERE(Type = FILTER(Item | FOODContainer), "No." = FILTER(<> ''));
                                column(SalesLine2No; "No.")
                                {
                                    IncludeCaption = true;
                                }
                                column(SalesLine2Desc; Description)
                                {
                                    IncludeCaption = true;
                                }
                                column(SalesLine2Quantity; Quantity)
                                {
                                }
                                column(SalesLine2UOMCode; "Unit of Measure Code")
                                {
                                    IncludeCaption = true;
                                }
                                column(SalesLine2DocType; "Document Type")
                                {
                                }
                                column(SalesLine2DocNo; "Document No.")
                                {
                                }
                                column(SalesLine2LineNo; "Line No.")
                                {
                                }

                                trigger OnAfterGetRecord()
                                begin
                                    if not P800ReplMgmt.FindReplSalesOrderLine(SalesLine2) then
                                        CurrReport.Skip;
                                end;
                            }

                            trigger OnPreDataItem()
                            begin
                                SetRange("Location Code", LocationCode);
                                SetRange("Shipment Date", ShipmentDate);
                                SetRange("Delivery Route No.", DeliveryRoute."No.");
                            end;
                        }
                    }

                    trigger OnPreDataItem()
                    begin
                        // P80070245
                        // P8000812 S
                        if DeliveryRoute.Get(RouteHeader."Delivery Route No.") then;
                        HeaderTitle := Text009;
                        HeaderShipDate := Format(ShipmentDate, 0, Text006);
                        HeaderInfo := StrSubstNo('%1 %2 - %3', RouteHeader.FieldCaption("Delivery Route No."), DeliveryRoute."No.", DeliveryRoute.Description
                        );
                        // P8000812 E
                        // P80070245
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    SetRange("Delivery Route No.", "Delivery Route No.");
                    Find('+');
                    SetRange("Delivery Route No.");

                    CurrReport.PageNo(0);
                    CurrReport.NewPage;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Location Code", LocationCode);
                    SetRange("Shipment Date", ShipmentDate);
                end;
            }

            trigger OnPreDataItem()
            begin
                if (ShowOrderReport <> ShowOrderReport::"By Delivery Route") then
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
                    field("Location Code"; LocationCode)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Location Code';
                        TableRelation = Location;

                        trigger OnValidate()
                        begin
                            SetLocation(LocationCode);
                        end;
                    }
                    field("Shipment Date"; ShipmentDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Shipment Date';
                    }
                    field("Delivery Route Filter"; DeliveryRouteFilter)
                    {
                        ApplicationArea = FOODBasic;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            DelRoute: Record "Delivery Route";
                            DelRouteList: Page "Delivery Route List";
                        begin
                            if (LocationCode = '') then
                                Error(Text000);
                            DelRoute.SetRange("Location Code", LocationCode);
                            DelRouteList.SetTableView(DelRoute);
                            DelRoute.SetFilter("No.", Text);
                            if DelRoute.FindFirst then
                                DelRouteList.SetRecord(DelRoute);
                            DelRouteList.LookupMode(true);
                            if (DelRouteList.RunModal <> ACTION::LookupOK) then
                                exit(false);
                            DelRouteList.GetRecord(DelRoute);
                            Text := DelRoute."No.";
                            exit(true);
                        end;

                        trigger OnValidate()
                        var
                            DelRoute: Record "Delivery Route";
                        begin
                            if (DeliveryRouteFilter <> '') then begin
                                if (LocationCode = '') then
                                    Error(Text000);
                                DelRoute.SetFilter("No.", DeliveryRouteFilter);
                                DelRoute.SetRange("Location Code", LocationCode);
                                DelRoute.FindFirst;
                            end;
                        end;
                    }
                    field(ShowAllItems; ShowAllItems)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Show All Items';
                    }
                    field(RoundUpToWholeQtys; RoundUpToWholeQtys)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Round Up To Whole Qtys.';
                    }
                    field("Show Order Report"; ShowOrderReport)
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field(SuggestPicks; SuggestPicks)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Suggest Picks';

                        trigger OnValidate()
                        begin
                            SuggestionsEnable := SuggestPicks; // P8001278
                        end;
                    }
                    field("Max. Number of Suggestions"; MaxNumSuggestions)
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = true;
                        Caption = 'Max. Number of Suggestions';
                        Enabled = SuggestionsEnable;
                        MinValue = 0;
                    }
                    field(AllowRecvBin; AllowRecvBin)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Allow Picks from Receiving Bins';
                        Enabled = SuggestionsEnable;
                    }
                    field(AllowOutputBin; AllowOutputBin)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Allow Picks from Output Bins';
                        Enabled = SuggestionsEnable;
                    }
                    field("Generate Journal Lines"; GenerateJnlLines)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Generate Journal Lines';
                        Visible = "Generate Journal LinesVisible";

                        trigger OnValidate()
                        begin
                            "Posting DateEnable" := GenerateJnlLines <> GenerateJnlLines::None;
                            "Document No.Enable" := GenerateJnlLines <> GenerateJnlLines::None;
                        end;
                    }
                    field("Posting Date"; PostingDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Posting Date';
                        Enabled = "Posting DateEnable";
                        Visible = "Posting DateVisible";
                    }
                    field("Document No."; DocumentNo)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Document No.';
                        Enabled = "Document No.Enable";
                        Visible = "Document No.Visible";
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            "Document No.Visible" := true;
            "Posting DateVisible" := true;
            "Generate Journal LinesVisible" := true;
            "Document No.Enable" := true;
            "Posting DateEnable" := true;
            SuggestionsEnable := true; // P8001278
        end;

        trigger OnOpenPage()
        begin
            if not CalledFromJnl then begin
                "Generate Journal LinesVisible" := false;
                "Posting DateVisible" := false;
                "Document No.Visible" := false;
            end else begin
                if ItemJnlLine."Location Code" <> '' then
                    LocationCode := ItemJnlLine."Location Code";
                PostingDate := ItemJnlLine."Posting Date";
                DocumentNo := ItemJnlLine."Document No.";
                "Posting DateEnable" := GenerateJnlLines <> GenerateJnlLines::None;
                "Document No.Enable" := GenerateJnlLines <> GenerateJnlLines::None;
            end;

            if LocationCode = '' then
                LocationCode := P800CoreFns.GetDefaultEmpLocation; // P8001034

            if Location.Get(LocationCode) then
                if not Location."Bin Mandatory" then
                    LocationCode := '';

            SuggestionsEnable := SuggestPicks; // P8001278
        end;
    }

    labels
    {
        ReplQtyCaption = 'Replenish Qty.';
        ReplQtyBaseCaption = 'Replenish Qty. (Base)';
        QtyAvailBaseCaption = 'Qty. Avail. (Base)';
        BaseUOMCaption = 'Base UOM';
        QtyBaseCaption = 'Quantity (Base)';
        UOMCodeCaption = 'UOM';
        QtyCaption = 'Quantity';
        DescriptionCaption = 'Description / Variant';
        PAGENOCaption = 'Page';
        ItemNoCaption = 'Item No.';
        BinCodeCaption = 'Ship. Bin';
        TransTypeCaption = 'Trans. Type';
        TotalReplenishQtyCaption = 'Total Replenish Qty.:';
        PickBinsLotsAvailableCaption = 'Pick Bins / Lots Available';
        NoAvailablePickBinsLotsCaption = 'No Available Pick Bins / Lots';
    }

    trigger OnInitReport()
    begin
        RoundUpToWholeQtys := true;
        SuggestPicks := true;
        MaxNumSuggestions := 3;
        GenerateJnlLines := GenerateJnlLines::"Summary (by Item)"; // P8000631A
    end;

    trigger OnPreReport()
    begin
        if (LocationCode = '') then
            Error(Text000);
        SetLocation(LocationCode);
        if (ShipmentDate = 0D) then
            Error(Text001);
        P800ReplMgmt.SetMaxNumSuggestions(MaxNumSuggestions);

        // P8000631A
        if not CalledFromJnl then
            GenerateJnlLines := GenerateJnlLines::None;
        if (GenerateJnlLines <> GenerateJnlLines::None) then
            if (PostingDate = 0D) or (DocumentNo = '') then
                Error(Text002);
        // P8000631A
    end;

    var
        LocationCode: Code[10];
        ShipmentDate: Date;
        ShowAllItems: Boolean;
        RoundUpToWholeQtys: Boolean;
        ShowOrderReport: Option "None","By Order No.","By Delivery Route";
        SuggestPicks: Boolean;
        MaxNumSuggestions: Integer;
        Location: Record Location;
        CurrBin: Record Bin;
        CurrItem: Record Item;
        CurrVariantCode: Code[10];
        CurrUOMCode: Code[10];
        CurrTransType: Integer;
        CurrQty: Decimal;
        CurrQtyBase: Decimal;
        CurrItemUOM: Record "Item Unit of Measure";
        ReplQty: Decimal;
        ReplQtyBase: Decimal;
        CurrOrderNo: Code[20];
        NumItemsPrinted: Integer;
        QtyAvailBase: Decimal;
        TempBinSuggestion: Record "Warehouse Entry" temporary;
        PicksSuggested: Boolean;
        SuggBinUOMMsg: Text[250];
        P800ReplMgmt: Codeunit "Process 800 Replenish. Mgmt.";
        Text000: Label 'You must enter a Location Code.';
        Text001: Label 'You must enter a Shipment Date.';
        ItemFilters: Record Item;
        CalledFromJnl: Boolean;
        GenerateJnlLines: Option "None","Summary (by Item)","Detail (by Order)";
        PostingDate: Date;
        DocumentNo: Code[20];
        ItemJnlLine: Record "Item Journal Line";
        ItemJournalTempl: Record "Item Journal Template";
        WMSMgmt: Codeunit "WMS Management";
        Text002: Label 'You must specify the Posting Date and Document No. to Generate Journal Lines.';
        P800CoreFns: Codeunit "Process 800 Core Functions";
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        Text003: Label 'Sales %1 %2';
        Text004: Label 'Purchase %1 %2';
        Text005: Label 'Transfer Order %1';
        TransLine: Record "Transfer Line";
        DeliveryRouteFilter: Code[80];
        Text006: Label '<Month Text> <Day>, <Year4>';
        [InDataSet]
        SuggestionsEnable: Boolean;
        [InDataSet]
        "Posting DateEnable": Boolean;
        [InDataSet]
        "Document No.Enable": Boolean;
        [InDataSet]
        "Generate Journal LinesVisible": Boolean;
        [InDataSet]
        "Posting DateVisible": Boolean;
        [InDataSet]
        "Document No.Visible": Boolean;
        RTC_ReplQty: Decimal;
        HeaderTitle: Text[250];
        HeaderShipDate: Text[250];
        HeaderInfo: Text[250];
        Text007: Label 'Shipment Replenishment / Move List';
        Text008: Label 'Shipment Orders List';
        Text009: Label 'Shipment Orders List - By Route';
        Text010: Label 'Sales';
        Text011: Label 'Return';
        Text012: Label 'Trans';
        AllowRecvBin: Boolean;
        AllowOutputBin: Boolean;

    local procedure SetLocation(NewLocationCode: Code[10])
    var
        DelRoute: Record "Delivery Route";
    begin
        LocationCode := NewLocationCode;
        with Location do begin
            Get(LocationCode);
            TestField("Bin Mandatory", true);
        end;
        if (DeliveryRouteFilter <> '') then
            if (LocationCode = '') then
                DeliveryRouteFilter := ''
            else begin
                DelRoute.SetFilter("No.", DeliveryRouteFilter);
                DelRoute.SetRange("Location Code", LocationCode);
                if not DelRoute.FindFirst then
                    DeliveryRouteFilter := '';
            end;
    end;

    procedure SetItemJnlLine(var ItemJnlLine2: Record "Item Journal Line")
    begin
        ItemJnlLine := ItemJnlLine2;
        with ItemJnlLine do begin
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            if FindLast then;
            ItemJournalTempl.Get("Journal Template Name");
        end;
        CalledFromJnl := true;
    end;

    local procedure InsertItemJnlLine(PostingDate: Date; DocumentNo: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; BinCode: Code[20]; UOMCode: Code[10]; Qty: Decimal; SourceSubtype: Integer; SourceNo: Code[20]; SourceLineNo: Integer)
    begin
        with ItemJnlLine do begin
            Init;
            "Line No." := "Line No." + 10000;
            Validate("Posting Date", PostingDate);
            Validate("Document No.", DocumentNo);
            Validate("Entry Type", "Entry Type"::Transfer);
            Validate("Item No.", ItemNo);
            Validate("Variant Code", VariantCode);
            Validate("Location Code", LocationCode);
            Validate("New Location Code", LocationCode);
            if WMSMgmt.GetDefaultBin("Item No.", "Variant Code", "Location Code", "Bin Code") then
                Validate("Bin Code")
            else
                Validate("Bin Code", '');
            Validate("New Bin Code", BinCode);
            Validate("Unit of Measure Code", UOMCode);
            Validate(Quantity, Qty);
            "Source Code" := ItemJournalTempl."Source Code";
            if (SourceSubtype <> 0) then begin
                "Pick Source Type" := SourceSubtype;
                "Pick Source No." := SourceNo;
                "Pick Source Line No." := SourceLineNo;
            end;
            Insert;
        end;
    end;

    procedure FormatTransType(TransType: Integer): Text[30]
    begin
        // P8001083
        case TransType of
            1:
                exit(Text010);
            2:
                exit(Text011);
            3:
                exit(Text012);
        end;
    end;
}

