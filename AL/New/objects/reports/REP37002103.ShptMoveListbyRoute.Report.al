report 37002103 "Shpt. Move List by Route"
{
    // PRW16.00.06
    // P8001122, Columbus IT, Don Bresee, 17 DEC 12
    //   Create new report for lot/bin suggestions
    // 
    // PRW17.10
    // P8001221, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Type added to Item table
    // 
    // PRW17.10.02
    // P8001278, Columbus IT, Jack Reynolds, 04 FEB 14
    //   Allow move list reports to suggest receiving and/or output bins
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // P8007749, To-Increase, Jack Reynolds, 07 DEC 16
    //   Item Category/Product Group
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    DefaultRenderingLayout = StandardRDLCLayout;

    ApplicationArea = FOODBasic;
    Caption = 'Shpt. Move List by Route';
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
                P800ReplMgmt.BuildShptReplTotals(LocationCode, ShipmentDate, DeliveryRouteFilter, ItemFilters, WhseReqFilters, true);

                CurrReport.Break;
            end;
        }
        dataitem(DeliveryRoute; "Delivery Route")
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            column(DeliveryRouteNo; "No.")
            {
            }
            dataitem(WhseReq; "Warehouse Request")
            {
                DataItemTableView = SORTING(Type, "Location Code", "Completely Handled", "Document Status", "Expected Receipt Date", "Shipment Date", "Source Document", "Source No.") WHERE(Type = CONST(Outbound), "Source Document" = FILTER("Sales Order" | "Purchase Return Order" | "Outbound Transfer"), "Document Status" = CONST(Released), "Completely Handled" = CONST(false));
                PrintOnlyIfDetail = true;
                column(HeaderShipDate; HeaderShipDate)
                {
                }
                column(HeaderTitle; HeaderTitle)
                {
                }
                column(DeliveryRouteDesc; DeliveryRouteDesc)
                {
                }
                column(WhseReqSourceType; "Source Type")
                {
                }
                column(WhseReqSourceSubtype; "Source Subtype")
                {
                }
                dataitem(SalesHeader; "Sales Header")
                {
                    DataItemLink = "Document Type" = FIELD("Source Subtype"), "No." = FIELD("Source No.");
                    DataItemTableView = SORTING("Document Type", "No.");
                    PrintOnlyIfDetail = true;
                    column(SalesHeaderSTRDocTypeNo; StrSubstNo(Text003, "Document Type", "No."))
                    {
                    }
                    column(SalesHeaderNo; "No.")
                    {
                    }
                    dataitem(SalesLine; "Sales Line")
                    {
                        DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                        DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") WHERE(Type = FILTER(Item | FOODContainer), "No." = FILTER(<> ''));
                        column(SalesLineNo; "No.")
                        {
                            IncludeCaption = true;
                        }
                        column(SalesLineDesc; Description)
                        {
                            IncludeCaption = true;
                        }
                        column(SalesLineQuantity; Quantity)
                        {
                            IncludeCaption = true;
                        }
                        column(SalesLineUOMCode; "Unit of Measure Code")
                        {
                            IncludeCaption = true;
                        }
                        column(SalesLineDocNo; "Document No.")
                        {
                        }
                        column(SalesLineLineNo; "Line No.")
                        {
                        }
                        dataitem(SalesSuggestBinLoop; "Integer")
                        {
                            DataItemTableView = SORTING(Number);
                            column(SalesSuggBinUOMMsg; SuggBinUOMMsg)
                            {
                            }
                            column(SalesTempBinSuggUOMCode; TempBinSuggestion."Unit of Measure Code")
                            {
                            }
                            column(SalesTempBinSuggQuantity; TempBinSuggestion.Quantity)
                            {
                                DecimalPlaces = 0 : 5;
                            }
                            column(SalesTempBinSuggLotNo; TempBinSuggestion."Lot No.")
                            {
                            }
                            column(SalesTempBinSuggBinCode; TempBinSuggestion."Bin Code")
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if not P800ReplMgmt.GetSuggBinLine(Number = 1, TempBinSuggestion) then
                                    CurrReport.Break;

                                P800ReplMgmt.GetSuggBinUOMMsg(ReplQty, SalesLine."Unit of Measure Code", TempBinSuggestion, SuggBinUOMMsg);
                            end;

                            trigger OnPreDataItem()
                            begin
                                ReplQty := SalesLine.Quantity;
                                P800ReplMgmt.SetPickBinOverride(AllowRecvBin, AllowOutputBin); // P8001278
                                if not P800ReplMgmt.GetSuggestedPicks(
                                         SuggestPicks, PicksSuggested, SalesLine."Location Code", SalesLine."No.",
                                         SalesLine."Variant Code", 0, ReplQty, SalesLine."Unit of Measure Code", TempBinSuggestion)
                                then
                                    CurrReport.Break;

                                SetFilter(Number, '1..');
                            end;
                        }
                        dataitem(SalesNoSuggestBinLoop; "Integer")
                        {
                            DataItemTableView = SORTING(Number);
                            MaxIteration = 1;

                            trigger OnPreDataItem()
                            begin
                                if not P800ReplMgmt.ShowNoSuggBins(SuggestPicks, PicksSuggested, ReplQty) then
                                    CurrReport.Break;
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if not P800ReplMgmt.FindReplSalesOrderLine(SalesLine) then
                                CurrReport.Skip;
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        if (WhseReq."Source Document" <> WhseReq."Source Document"::"Sales Order") then
                            CurrReport.Break;

                        SetRange("Delivery Route No.", DeliveryRoute."No.");
                    end;
                }
                dataitem(PurchaseHeader; "Purchase Header")
                {
                    DataItemLink = "Document Type" = FIELD("Source Subtype"), "No." = FIELD("Source No.");
                    DataItemTableView = SORTING("Document Type", "No.");
                    PrintOnlyIfDetail = true;
                    column(PurchHeaderSTRDocTypeNo; StrSubstNo(Text004, "Document Type", "No."))
                    {
                    }
                    column(PurchHeaderNo; "No.")
                    {
                    }
                    dataitem(PurchaseLine; "Purchase Line")
                    {
                        DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                        DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") WHERE(Type = FILTER(Item), "No." = FILTER(<> ''));
                        column(PurchLineNo; "No.")
                        {
                        }
                        column(PurchLineDesc; Description)
                        {
                        }
                        column(PurchLineUOMCode; "Unit of Measure Code")
                        {
                        }
                        column(PurchLineQuantity; Quantity)
                        {
                        }
                        column(PurchLineDocNo; "Document No.")
                        {
                        }
                        column(PurchLineLineNo; "Line No.")
                        {
                        }
                        dataitem(PurchSuggestBinLoop; "Integer")
                        {
                            DataItemTableView = SORTING(Number);
                            column(PurchSuggBinUOMMsg; SuggBinUOMMsg)
                            {
                            }
                            column(PurchTempBinSuggUOMCode; TempBinSuggestion."Unit of Measure Code")
                            {
                            }
                            column(PurchTempBinSuggQuantity; TempBinSuggestion.Quantity)
                            {
                                DecimalPlaces = 0 : 5;
                            }
                            column(PurchTempBinSuggLotNo; TempBinSuggestion."Lot No.")
                            {
                            }
                            column(PurchTempBinSuggBinCode; TempBinSuggestion."Bin Code")
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if not P800ReplMgmt.GetSuggBinLine(Number = 1, TempBinSuggestion) then
                                    CurrReport.Break;

                                P800ReplMgmt.GetSuggBinUOMMsg(ReplQty, PurchaseLine."Unit of Measure Code", TempBinSuggestion, SuggBinUOMMsg);
                            end;

                            trigger OnPreDataItem()
                            begin
                                ReplQty := PurchaseLine.Quantity;
                                if not P800ReplMgmt.GetSuggestedPicks(
                                         SuggestPicks, PicksSuggested, PurchaseLine."Location Code", PurchaseLine."No.",
                                         PurchaseLine."Variant Code", 0, ReplQty, PurchaseLine."Unit of Measure Code", TempBinSuggestion)
                                then
                                    CurrReport.Break;

                                SetFilter(Number, '1..');
                            end;
                        }
                        dataitem(PurchNoSuggestBinLoop; "Integer")
                        {
                            DataItemTableView = SORTING(Number);
                            MaxIteration = 1;

                            trigger OnPreDataItem()
                            begin
                                if not P800ReplMgmt.ShowNoSuggBins(SuggestPicks, PicksSuggested, ReplQty) then
                                    CurrReport.Break;
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if not P800ReplMgmt.FindReplPurchRetOrderLine(PurchaseLine) then
                                CurrReport.Skip;
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        if (WhseReq."Source Document" <> WhseReq."Source Document"::"Purchase Return Order") then
                            CurrReport.Break;

                        SetRange("Delivery Route No.", DeliveryRoute."No.");
                    end;
                }
                dataitem(TransferHeader; "Transfer Header")
                {
                    DataItemLink = "No." = FIELD("Source No.");
                    DataItemTableView = SORTING("No.");
                    PrintOnlyIfDetail = true;
                    column(STRNo; StrSubstNo(Text005, "No."))
                    {
                    }
                    column(TransferHeaderNo; "No.")
                    {
                    }
                    dataitem(TransferLine; "Transfer Line")
                    {
                        DataItemLink = "Document No." = FIELD("No.");
                        DataItemTableView = SORTING("Document No.", "Line No.") WHERE("Item No." = FILTER(<> ''));
                        column(TransferLineItemNo; "Item No.")
                        {
                        }
                        column(TransferLineDesc; Description)
                        {
                        }
                        column(TransferLineUOMCode; "Unit of Measure Code")
                        {
                        }
                        column(TransferLineQuantity; Quantity)
                        {
                        }
                        column(TransferLineDocNo; "Document No.")
                        {
                        }
                        column(TransferLineLineNo; "Line No.")
                        {
                        }
                        dataitem(TransSuggestBinLoop; "Integer")
                        {
                            DataItemTableView = SORTING(Number);
                            column(TransSuggBinUOMMsg; SuggBinUOMMsg)
                            {
                            }
                            column(TransTempBinSuggUOMCode; TempBinSuggestion."Unit of Measure Code")
                            {
                            }
                            column(TransTempBinSuggQuantity; TempBinSuggestion.Quantity)
                            {
                                DecimalPlaces = 0 : 5;
                            }
                            column(TransTempBinSuggLotNo; TempBinSuggestion."Lot No.")
                            {
                            }
                            column(TransTempBinSuggBinCode; TempBinSuggestion."Bin Code")
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if not P800ReplMgmt.GetSuggBinLine(Number = 1, TempBinSuggestion) then
                                    CurrReport.Break;

                                P800ReplMgmt.GetSuggBinUOMMsg(ReplQty, TransferLine."Unit of Measure Code", TempBinSuggestion, SuggBinUOMMsg);
                            end;

                            trigger OnPreDataItem()
                            begin
                                ReplQty := TransferLine.Quantity;
                                if not P800ReplMgmt.GetSuggestedPicks(
                                         SuggestPicks, PicksSuggested, TransferLine."Transfer-from Code", TransferLine."Item No.",
                                         TransferLine."Variant Code", 0, ReplQty, TransferLine."Unit of Measure Code", TempBinSuggestion)
                                then
                                    CurrReport.Break;

                                SetFilter(Number, '1..');
                            end;
                        }
                        dataitem(TransNoSuggestBinLoop; "Integer")
                        {
                            DataItemTableView = SORTING(Number);
                            MaxIteration = 1;

                            trigger OnPreDataItem()
                            begin
                                if not P800ReplMgmt.ShowNoSuggBins(SuggestPicks, PicksSuggested, ReplQty) then
                                    CurrReport.Break;
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if not P800ReplMgmt.FindReplTransOrderLine(TransferLine) then
                                CurrReport.Skip;
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        if (WhseReq."Source Document" <> WhseReq."Source Document"::"Outbound Transfer") then
                            CurrReport.Break;

                        SetRange("Delivery Route No.", DeliveryRoute."No.");
                    end;
                }

                trigger OnPreDataItem()
                begin
                    SetRange("Location Code", LocationCode);
                    SetRange("Shipment Date", ShipmentDate);

                    HeaderTitle := Text007;
                    HeaderShipDate := Format(ShipmentDate, 0, Text006);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CurrReport.PageNo(0);
                CurrReport.NewPage;

                DeliveryRouteDesc :=
                  StrSubstNo('%1 / %2 - %3 / %4', Location.Code, DeliveryRoute."No.", Location.Name, DeliveryRoute.Description);
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Location Code", LocationCode);
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
                    field("Suggest Picks"; SuggestPicks)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Suggest Picks';

                        trigger OnValidate()
                        begin
                            RequestOptionsPage.Update;
                        end;
                    }
                    field("Max. Number of Suggestions"; MaxNumSuggestions)
                    {
                        ApplicationArea = FOODBasic;
                        BlankZero = true;
                        Caption = 'Max. Number of Suggestions';
                        Enabled = SuggestPicks;
                        MinValue = 0;
                    }
                    field(AllowRecvBin; AllowRecvBin)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Allow Picks from Receiving Bins';
                        Enabled = SuggestPicks;
                    }
                    field(AllowOutputBin; AllowOutputBin)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Allow Picks from Output Bins';
                        Enabled = SuggestPicks;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if LocationCode = '' then
                LocationCode := P800CoreFns.GetDefaultEmpLocation;

            if Location.Get(LocationCode) then
                if not Location."Bin Mandatory" then
                    LocationCode := '';
        end;
    }

    rendering
    {
        layout(StandardRDLCLayout)
        {
            Summary = 'Standard Layout';
            Type = RDLC;
            LayoutFile = './layout/ShptMoveListbyRoute.rdlc';
        }
    }

    labels
    {
        PAGENOCaption = 'Page';
        SalesPickBinsLotsAvailableCaption = 'Pick Bins / Lots Available';
        SalesNoAvailablePickBinsLotsCaption = 'No Available Pick Bins / Lots';
        PurchPickBinsLotsAvailableCaption = 'Pick Bins / Lots Available';
        PurchNoAvailablePickBinsLotsCaption = 'No Available Pick Bins / Lots';
        TransPickBinsLotsAvailableCaption = 'Pick Bins / Lots Available';
        TransNoAvailablePickBinsLotsCaption = 'No Available Pick Bins / Lots';
    }

    trigger OnInitReport()
    begin
        SuggestPicks := true;
        MaxNumSuggestions := 3;
    end;

    trigger OnPreReport()
    begin
        if (LocationCode = '') then
            Error(Text000);
        SetLocation(LocationCode);
        if (ShipmentDate = 0D) then
            Error(Text001);
        P800ReplMgmt.SetMaxNumSuggestions(MaxNumSuggestions);
    end;

    var
        LocationCode: Code[10];
        ShipmentDate: Date;
        [InDataSet]
        SuggestPicks: Boolean;
        MaxNumSuggestions: Integer;
        Location: Record Location;
        ReplQty: Decimal;
        TempBinSuggestion: Record "Warehouse Entry" temporary;
        PicksSuggested: Boolean;
        SuggBinUOMMsg: Text[250];
        P800ReplMgmt: Codeunit "Process 800 Replenish. Mgmt.";
        ItemFilters: Record Item;
        P800CoreFns: Codeunit "Process 800 Core Functions";
        DeliveryRouteFilter: Code[80];
        DeliveryRouteDesc: Text[80];
        HeaderTitle: Text[250];
        HeaderShipDate: Text[250];
        Text000: Label 'You must enter a Location Code.';
        Text001: Label 'You must enter a Shipment Date.';
        Text003: Label 'Sales %1 %2';
        Text004: Label 'Purchase %1 %2';
        Text005: Label 'Transfer Order %1';
        Text006: Label '<Month Text> <Day>, <Year4>';
        Text007: Label 'Shipment Orders  / Move List';
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
}

