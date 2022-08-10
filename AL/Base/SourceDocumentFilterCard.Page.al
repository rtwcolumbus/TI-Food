page 5786 "Source Document Filter Card"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 29-01-2015, Initial Version
    // --------------------------------------------------------------------------------
    // 
    // PRW19.00.01
    // P8006916, To-Increase, Jack Reynolds, 31 AUG 16
    //   FOOD-TOM Separation
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // P80038975, To-Increase, Dayakar Battini, 13 DEC 17
    //   Adding Picking Classes functionality

    Caption = 'Source Document Filter Card';
    LinksAllowed = false;
    PageType = Card;
    SourceTable = "Warehouse Source Filter";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code that identifies the filter record.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the description of filter combinations in the Source Document Filter Card window to retrieve lines from source documents.';
                }
                field("Source No. Filter"; Rec."Source No. Filter")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number, or number range, that is used to filter the source documents to get.';
                }
                field("Pick Class Code Sub Filter"; Rec."Pick Class Code Sub Filter")
                {
                    ApplicationArea = FOODBasic;
                    Visible = PickClassCodeEnabled;
                }
                field("Item No. Filter"; Rec."Item No. Filter")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the item number used to filter the source documents to get.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemList: Page "Item List";
                        Item: Record Item;
                    begin
                        // P80038975
                        if ("Pick Class Code Sub Filter" <> '') and PickClassCodeEnabled then
                            Item.SetFilter("Pick Class Code", "Pick Class Code Sub Filter");

                        ItemList.SetTableView(Item);
                        ItemList.LookupMode := true;
                        if ItemList.RunModal = ACTION::LookupOK then
                            Text := ItemList.GetSelectionFilter
                        else
                            exit(false);

                        exit(true);
                        // P80038975
                    end;
                }
                field("Variant Code Filter"; Rec."Variant Code Filter")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the item variant used to filter the source documents to get.';
                }
                field("Unit of Measure Filter"; Rec."Unit of Measure Filter")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the unit of measure used to filter the source documents to get.';
                }
                field("Shipment Method Code Filter"; Rec."Shipment Method Code Filter")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the shipment method code used to filter the source documents to get.';
                }
                field("Show Filter Request"; Rec."Show Filter Request")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies if the Filters to Get Source Docs. window appears when you choose Use Filters to Get Source Docs on a warehouse shipment or receipt.';
                }
                field("Sales Return Orders"; Rec."Sales Return Orders")
                {
                    ApplicationArea = Warehouse;
                    Enabled = SalesReturnOrdersEnable;
                    ToolTip = 'Specifies that sales return orders are retrieved when you choose Use Filters to Get Src. Docs in the Warehouse Shipment window.';
                }
                field("Purchase Orders"; Rec."Purchase Orders")
                {
                    ApplicationArea = Warehouse;
                    Enabled = PurchaseOrdersEnable;
                    ToolTip = 'Specifies that purchase orders are retrieved when you choose Use Filters to Get Src. Docs in the Warehouse Receipt window.';
                }
                field("Inbound Transfers"; Rec."Inbound Transfers")
                {
                    ApplicationArea = Warehouse;
                    Enabled = InboundTransfersEnable;
                    ToolTip = 'Specifies that inbound transfer orders are retrieved when you choose Use Filters to Get Src. Docs in the Warehouse Receipt.';

                    trigger OnValidate()
                    begin
                        EnableControls();
                    end;
                }
                field("Shipping Agent Code Filter"; Rec."Shipping Agent Code Filter")
                {
                    ApplicationArea = Warehouse;
                    Enabled = ShippingAgentCodeFilterEnable;
                    ToolTip = 'Specifies the shipping agent code used to filter the source documents.';
                }
                field("Shipping Agent Service Filter"; Rec."Shipping Agent Service Filter")
                {
                    ApplicationArea = Warehouse;
                    Enabled = ShippingAgentServiceFilterEnable;
                    ToolTip = 'Specifies the shipping agent service used to filter the source documents.';
                }
                field("Create Delivery Trip"; Rec."Create Delivery Trip")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Do Not Fill Qty. to Handle"; Rec."Do Not Fill Qty. to Handle")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies that inventory quantities are assigned when you get outbound source document lines for shipment.';
                }
                group("Source Document:")
                {
                    Caption = 'Source Document:';
                    field("Sales Orders"; Rec."Sales Orders")
                    {
                        ApplicationArea = Warehouse;
                        Enabled = SalesOrdersEnable;
                        ToolTip = 'Specifies that sales orders are retrieved when you choose Use Filters to Get Src. Docs in the Warehouse Shipment window.';

                        trigger OnValidate()
                        begin
                            EnableControls();
                        end;
                    }
                    field("Service Orders"; Rec."Service Orders")
                    {
                        ApplicationArea = Warehouse;
                        ToolTip = 'Specifies that service lines with a Released to Ship status are retrieved by the function that gets source documents for warehouse shipment.';
                    }
                    field("Purchase Return Orders"; Rec."Purchase Return Orders")
                    {
                        ApplicationArea = Warehouse;
                        Enabled = PurchaseReturnOrdersEnable;
                        ToolTip = 'Specifies that purchase return orders are retrieved when you choose Use Filters to Get Src. Docs in the Warehouse Shipment window.';
                    }
                    field("Outbound Transfers"; Rec."Outbound Transfers")
                    {
                        ApplicationArea = Warehouse;
                        Enabled = OutboundTransfersEnable;
                        ToolTip = 'Specifies that outbound transfer orders are retrieved when you choose Use Filters to Get Src. Docs in the Warehouse Shipment window.';

                        trigger OnValidate()
                        begin
                            EnableControls();
                        end;
                    }
                }
                group("Shipping Advice Filter:")
                {
                    Caption = 'Shipping Advice Filter:';
                    field(Partial; Rec.Partial)
                    {
                        ApplicationArea = Warehouse;
                        ToolTip = 'Specifies the Shipping Advice field on sales orders must contain Partial when you choose Use Filters to Get Src. Docs.';
                    }
                    field(Complete; Rec.Complete)
                    {
                        ApplicationArea = Warehouse;
                        ToolTip = 'Specifies the Shipping Advice field on sales orders must contain Complete when you choose Use Filters to Get Src. Docs.';
                    }
                }
            }
            group(Sales)
            {
                Caption = 'Sales';
                field("Sell-to Customer No. Filter"; Rec."Sell-to Customer No. Filter")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the sell-to customer number used to filter the source documents to get.';
                }
            }
            group(Purchase)
            {
                Caption = 'Purchase';
                field("Buy-from Vendor No. Filter"; Rec."Buy-from Vendor No. Filter")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the buy-from vendor number used to filter the source documents to get.';
                }
            }
            group(Transfer)
            {
                Caption = 'Transfer';
                field("In-Transit Code Filter"; Rec."In-Transit Code Filter")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the in-transit code used to filter the source documents.';
                }
                field("Transfer-from Code Filter"; Rec."Transfer-from Code Filter")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the transfer-from code used to filter the source documents.';
                }
                field("Transfer-to Code Filter"; Rec."Transfer-to Code Filter")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the transfer-to code used to filter the source documents to get.';
                }
            }
            group(Service)
            {
                Caption = 'Service';
                field("Customer No. Filter"; Rec."Customer No. Filter")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies which customers are included when you use the Filters to Get Source Docs. window to retrieve source document lines.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Run)
            {
                ApplicationArea = Warehouse;
                Caption = '&Run';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Get the specified source documents.';

                trigger OnAction()
                var
                    GetSourceBatch: Report "Get Source Documents";
                begin
                    Rec."Planned Delivery Date" := CopyStr(Rec.GetFilter("Planned Delivery Date Filter"), 1, MaxStrLen(Rec."Planned Delivery Date"));
                    Rec."Planned Shipment Date" := CopyStr(Rec.GetFilter("Planned Shipment Date Filter"), 1, MaxStrLen(Rec."Planned Shipment Date"));
                    Rec."Sales Shipment Date" := CopyStr(Rec.GetFilter("Sales Shipment Date Filter"), 1, MaxStrLen(Rec."Sales Shipment Date"));
                    Rec."Planned Receipt Date" := CopyStr(Rec.GetFilter("Planned Receipt Date Filter"), 1, MaxStrLen(Rec."Planned Receipt Date"));
                    Rec."Expected Receipt Date" := CopyStr(Rec.GetFilter("Expected Receipt Date Filter"), 1, MaxStrLen(Rec."Expected Receipt Date"));
                    Rec."Shipment Date" := CopyStr(Rec.GetFilter("Shipment Date Filter"), 1, MaxStrLen(Rec."Shipment Date"));
                    Rec."Receipt Date" := CopyStr(Rec.GetFilter("Receipt Date Filter"), 1, MaxStrLen(Rec."Receipt Date"));

                    case RequestType of
                        RequestType::Receive:
                            begin
                                GetSourceBatch.SetOneCreatedReceiptHeader(WhseReceiptHeader);
                                SetFilters(GetSourceBatch, WhseReceiptHeader."Location Code");
                            end;
                        RequestType::Ship:
                            begin
                                GetSourceBatch.SetOneCreatedShptHeader(WhseShptHeader);
                                SetFilters(GetSourceBatch, WhseShptHeader."Location Code");
                            end;
                    end;

                    GetSourceBatch.UseRequestPage(Rec."Show Filter Request");
                    GetSourceBatch.RunModal();

                    //N138F0000.sn
                    if GetSourceBatch.NotCancelled then
                        DeliveryTripMgt.LinkDeliveryTripWhseShipment(Rec, WhseShptHeader);
                    //N138F0000.en
                    if GetSourceBatch.NotCancelled then
                        CurrPage.Close();
                end;
            }
            action("&Run and Select")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Run and Select';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    GetSourceBatch: Report "Get Source Documents";
                    WhseShipmentLine: Record "Warehouse Shipment Line" temporary;
                    WhseShipmentLine2: Record "Warehouse Shipment Line" temporary;
                    WhseShipmentLine3: Record "Warehouse Shipment Line";
                    WhseShipmentLines: Page "Whse. Shipment Lines";
                    LineNo: Integer;
                    Text000: Label 'Not Implemented';
                begin
                    //N138F0000.sn
                    "Planned Delivery Date" := GetFilter("Planned Delivery Date Filter");
                    "Planned Shipment Date" := GetFilter("Planned Shipment Date Filter");
                    "Sales Shipment Date" := GetFilter("Sales Shipment Date Filter");
                    "Planned Receipt Date" := GetFilter("Planned Receipt Date Filter");
                    "Expected Receipt Date" := GetFilter("Expected Receipt Date Filter");

                    case RequestType of
                        RequestType::Receive:
                            begin
                                Error(Text000);
                            end;
                        RequestType::Ship:
                            begin
                                GetSourceBatch.SetOneCreatedShptHeader(WhseShptHeader);
                                SetFilters(GetSourceBatch, WhseShptHeader."Location Code", WhseShptHeader."Delivery Trip"); //N138F0000
                                GetSourceBatch.SetUserInteraction;
                            end;
                    end;

                    GetSourceBatch.UseRequestPage("Show Filter Request");
                    GetSourceBatch.RunModal;
                    GetSourceBatch.GetShipmentLines(WhseShipmentLine);
                    WhseShipmentLines.LookupMode(true);
                    WhseShipmentLines.SetSource(WhseShipmentLine);
                    if WhseShipmentLines.RunModal = ACTION::LookupOK then begin
                        WhseShipmentLines.GetSource(WhseShipmentLine2);
                        if WhseShipmentLine2.FindSet then begin
                            WhseShipmentLine3.SetRange("No.", WhseShptHeader."No.");
                            if WhseShipmentLine3.FindLast then
                                LineNo := WhseShipmentLine3."Line No.";

                            WhseShipmentLine3.Reset;
                            repeat
                                WhseShipmentLine3 := WhseShipmentLine2;
                                LineNo += 10000;
                                WhseShipmentLine3."Line No." := LineNo;
                                WhseShipmentLine3.Insert;
                            until WhseShipmentLine2.Next = 0;
                            WhseShptHeader.SortWhseDoc;
                        end;
                    end;

                    if GetSourceBatch.NotCancelled then begin
                        DeliveryTripMgt.LinkDeliveryTripWhseShipment(Rec, WhseShptHeader);
                        CurrPage.Close();
                    end;
                    //N138F0000.en
                end;
            }
        }
    }

    trigger OnInit()
    begin
    end;

    trigger OnOpenPage()
    begin
        InitializeControls();

        DataCaption := CurrPage.Caption;
        Rec.FilterGroup := 2;
        if Rec.GetFilter(Type) <> '' then
            DataCaption := DataCaption + ' - ' + Rec.GetFilter(Type);
        Rec.FilterGroup := 0;
        CurrPage.Caption(DataCaption);

        EnableControls();
    end;
    
    var    
        DeliveryTripMgt: Codeunit "N138 Delivery Trip Mgt.";
        PickClassCodeEnabled: Boolean;
        DeliveryRouteManagement: Codeunit "Delivery Route Management";

    protected var
        WhseShptHeader: Record "Warehouse Shipment Header";
        WhseReceiptHeader: Record "Warehouse Receipt Header";
        DataCaption: Text[250];
        RequestType: Option Receive,Ship;
        [InDataSet]
        SalesOrdersEnable: Boolean;
        [InDataSet]
        PurchaseReturnOrdersEnable: Boolean;
        [InDataSet]
        OutboundTransfersEnable: Boolean;
        [InDataSet]
        PurchaseOrdersEnable: Boolean;
        [InDataSet]
        SalesReturnOrdersEnable: Boolean;
        [InDataSet]
        InboundTransfersEnable: Boolean;
        [InDataSet]
        ShippingAgentCodeFilterEnable: Boolean;
        [InDataSet]
        ShippingAgentServiceFilterEnable: Boolean;

    procedure SetOneCreatedShptHeader(WhseShptHeader2: Record "Warehouse Shipment Header")
    begin
        RequestType := RequestType::Ship;
        WhseShptHeader := WhseShptHeader2;
    end;

    procedure SetOneCreatedReceiptHeader(WhseReceiptHeader2: Record "Warehouse Receipt Header")
    begin
        RequestType := RequestType::Receive;
        WhseReceiptHeader := WhseReceiptHeader2;
    end;

    protected procedure EnableControls()
    begin
        OnBeforeEnableControls();
        case Rec.Type of
            Rec.Type::Inbound:
                begin
                    SalesOrdersEnable := false;
                    PurchaseReturnOrdersEnable := false;
                    OutboundTransfersEnable := false;
                end;
            Rec.Type::Outbound:
                begin
                    PurchaseOrdersEnable := false;
                    SalesReturnOrdersEnable := false;
                    InboundTransfersEnable := false;
                end;
        end;
        if Rec."Sales Orders" or Rec."Inbound Transfers" or Rec."Outbound Transfers" then begin
            ShippingAgentCodeFilterEnable := true;
            ShippingAgentServiceFilterEnable := true;
        end else begin
            ShippingAgentCodeFilterEnable := false;
            ShippingAgentServiceFilterEnable := false;
        end;

        PickClassCodeEnabled := DeliveryRouteManagement.IsPickClassCodeEnabled;   // P80038975
    end;

    protected procedure InitializeControls()
    begin
        ShippingAgentServiceFilterEnable := true;
        ShippingAgentCodeFilterEnable := true;
        InboundTransfersEnable := true;
        SalesReturnOrdersEnable := true;
        PurchaseOrdersEnable := true;
        OutboundTransfersEnable := true;
        PurchaseReturnOrdersEnable := true;
        SalesOrdersEnable := true;
        PickClassCodeEnabled := true;

        OnAfterInitializeControls();
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterInitializeControls()
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeEnableControls()
    begin
    end;
}

