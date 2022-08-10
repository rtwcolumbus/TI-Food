page 37002593 "Assign Container to Order"
{
    // PRW110.0.02
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers
    // 
    // PRW111.00.01
    // P80056709, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - assign container to production order

    Caption = 'Assign Container to Order';
    DataCaptionExpression = ContainerHeader.ID;
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field(OrderTypeIn; OrderTypeInbound)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Order Type';
                OptionCaption = ' ,Purchase,Sales Return';
                Visible = Inbound;

                trigger OnValidate()
                begin
                    if OrderTypeInbound <> xOrderType then begin // P80056709
                        OrderNo := '';
                        // P80056709
                        xOrderNo := '';
                        OrderLineNo := 0;
                    end;
                    // P80056709

                    xOrderType := OrderTypeInbound;
                end;
            }
            field(OrderTypeOut; OrderTypeOutbound)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Order Type';
                OptionCaption = ' ,Sales,Purchase Return,Transfer,Production';
                Visible = NOT Inbound;

                trigger OnValidate()
                begin
                    if OrderTypeOutbound <> xOrderType then begin // P80056709
                        OrderNo := '';
                        // P80056709
                        xOrderNo := '';
                        OrderLineNo := 0;
                        OrderLineEnabled := OrderTypeOutbound = OrderTypeOutbound::Production;
                    end;
                    // P80056709

                    xOrderType := OrderTypeOutbound;
                end;
            }
            field(OrderNo; OrderNo)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Order No.';

                trigger OnLookup(var Text: Text): Boolean
                var
                    SalesHeader: Record "Sales Header";
                    PurchHeader: Record "Purchase Header";
                    TransHeader: Record "Transfer Header";
                    ProductionOrder: Record "Production Order";
                    SalesList: Page "Sales List";
                    PurchList: Page "Purchase List";
                    TransList: Page "Transfer Orders";
                    ReleasedProductionOrders: Page "Released Production Orders";
                begin
                    if ContainerHeader.Inbound then begin
                        case OrderTypeInbound of
                            OrderTypeInbound::"Sales Return":
                                begin
                                    SalesHeader.FilterGroup(2);
                                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
                                    SalesHeader.FilterGroup(0);
                                    SalesList.SetTableView(SalesHeader);
                                    if SalesHeader.Get(SalesHeader."Document Type"::"Return Order", OrderNo) then
                                        SalesList.SetRecord(SalesHeader);
                                    SalesList.LookupMode(true);
                                    if SalesList.RunModal = ACTION::LookupOK then begin
                                        SalesList.GetRecord(SalesHeader);
                                        OrderNo := SalesHeader."No.";
                                        ValidateOrderNo; // P80046533
                                    end;
                                end;
                            OrderTypeInbound::Purchase:
                                begin
                                    PurchHeader.FilterGroup(2);
                                    PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
                                    PurchHeader.FilterGroup(0);
                                    PurchList.SetTableView(PurchHeader);
                                    if PurchHeader.Get(PurchHeader."Document Type"::Order, OrderNo) then
                                        PurchList.SetRecord(PurchHeader);
                                    PurchList.LookupMode(true);
                                    if PurchList.RunModal = ACTION::LookupOK then begin
                                        PurchList.GetRecord(PurchHeader);
                                        OrderNo := PurchHeader."No.";
                                        ValidateOrderNo; // P80046533
                                    end;
                                end;
                        end;
                    end else begin
                        case OrderTypeOutbound of
                            OrderTypeOutbound::Sales:
                                begin
                                    SalesHeader.FilterGroup(2);
                                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                                    SalesHeader.FilterGroup(0);
                                    SalesList.SetTableView(SalesHeader);
                                    if SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo) then
                                        SalesList.SetRecord(SalesHeader);
                                    SalesList.LookupMode(true);
                                    if SalesList.RunModal = ACTION::LookupOK then begin
                                        SalesList.GetRecord(SalesHeader);
                                        OrderNo := SalesHeader."No.";
                                        ValidateOrderNo; // P80046533
                                    end;
                                end;
                            OrderTypeOutbound::"Purchase Return":
                                begin
                                    PurchHeader.FilterGroup(2);
                                    PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::"Return Order");
                                    PurchHeader.FilterGroup(0);
                                    PurchList.SetTableView(PurchHeader);
                                    if PurchHeader.Get(PurchHeader."Document Type"::"Return Order", OrderNo) then
                                        PurchList.SetRecord(PurchHeader);
                                    PurchList.LookupMode(true);
                                    if PurchList.RunModal = ACTION::LookupOK then begin
                                        PurchList.GetRecord(PurchHeader);
                                        OrderNo := PurchHeader."No.";
                                        ValidateOrderNo; // P80046533
                                    end;
                                end;
                            OrderTypeOutbound::Transfer:
                                begin
                                    TransHeader.FilterGroup(2);
                                    TransHeader.SetRange("Transfer-from Code", ContainerHeader."Location Code");
                                    TransHeader.FilterGroup(0);
                                    TransList.SetTableView(TransHeader);
                                    if TransHeader.Get(OrderNo) then
                                        TransList.SetRecord(TransHeader);
                                    TransList.LookupMode(true);
                                    if TransList.RunModal = ACTION::LookupOK then begin
                                        TransList.GetRecord(TransHeader);
                                        OrderNo := TransHeader."No.";
                                        ValidateOrderNo; // P80046533
                                    end;
                                end;
                            // P80056709
                            OrderTypeOutbound::Production:
                                begin
                                    ProductionOrder.FilterGroup(2);
                                    ProductionOrder.SetRange(Status, ProductionOrder.Status::Released);
                                    ProductionOrder.SetRange("Location Code", ContainerHeader."Location Code");
                                    ProductionOrder.FilterGroup(0);
                                    ReleasedProductionOrders.SetTableView(ProductionOrder);
                                    if ProductionOrder.Get(ProductionOrder.Status::Released, OrderNo) then
                                        ReleasedProductionOrders.SetRecord(ProductionOrder);
                                    ReleasedProductionOrders.LookupMode(true);
                                    if ReleasedProductionOrders.RunModal = ACTION::LookupOK then begin
                                        ReleasedProductionOrders.GetRecord(ProductionOrder);
                                        OrderNo := ProductionOrder."No.";
                                        ValidateOrderNo;
                                    end;
                                end;
                                // P80056709
                        end;
                    end;
                end;

                trigger OnValidate()
                begin
                    ValidateOrderNo; // P80046533

                    // P80056709
                    if OrderNo <> xOrderNo then
                        OrderLineNo := 0;
                    xOrderNo := OrderNo;
                    // P80056709
                end;
            }
            field(OrderLineNo; OrderLineNo)
            {
                ApplicationArea = FOODBasic;
                BlankZero = true;
                Caption = 'Order Line No.';
                Editable = OrderLineEditable;
                Enabled = OrderLineEnabled;
                Visible = OrderLineVisible;

                trigger OnLookup(var Text: Text): Boolean
                var
                    ProdOrderLine: Record "Prod. Order Line";
                    ProdOrderLineList: Page "Prod. Order Line List";
                begin
                    // P80056709
                    if (OrderTypeOutbound <> OrderTypeOutbound::Production) or (OrderNo = '') then
                        exit;

                    ProdOrderLine.FilterGroup(2);
                    ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Released);
                    ProdOrderLine.SetRange("Prod. Order No.", OrderNo);
                    ProdOrderLine.FilterGroup(0);
                    ProdOrderLineList.SetTableView(ProdOrderLine);
                    if ProdOrderLine.Get(ProdOrderLine.Status::Released, OrderNo, OrderLineNo) then
                        ProdOrderLineList.SetRecord(ProdOrderLine);
                    ProdOrderLineList.LookupMode(true);
                    if ProdOrderLineList.RunModal = ACTION::LookupOK then begin
                        ProdOrderLineList.GetRecord(ProdOrderLine);
                        OrderLineNo := ProdOrderLine."Line No.";
                    end;
                end;

                trigger OnValidate()
                var
                    ProdOrderLine: Record "Prod. Order Line";
                begin
                    // P80056709
                    if OrderNo = '' then
                        Error(Text002);

                    ProdOrderLine.Get(ProdOrderLine.Status::Released, OrderNo, OrderLineNo);
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::Cancel then
            exit(true);

        // P80046533
        if (GetDocType <> 0) and (OrderNo = '') then
            Error(Text002);
        // P80046533
        // P80056709
        if (OrderNo <> '') and OrderLineVisible and OrderLineEnabled and (OrderLineNo = 0) then
            Error(Text004);
        // P80056709

        //IF (ContainerHeader."Document Type" = 0) OR ((ContainerHeader."Document Type" = GetDocType) AND (ContainerHeader."Document No." = OrderNo)) THEN
        if (ContainerHeader."Document Type" = 0) or ((GetDocType <> 0) and (OrderNo <> '')) then
            exit(true);

        exit(ContainerFns.ConfirmRemoveContainerFromOrder(ContainerHeader, DeleteContainer)); // P80046533
    end;

    var
        ContainerHeader: Record "Container Header";
        ContainerFns: Codeunit "Container Functions";
        [InDataSet]
        Inbound: Boolean;
        OrderTypeInbound: Option " ",Purchase,"Sales Return";
        OrderTypeOutbound: Option " ",Sales,"Purchase Return",Transfer,Production;
        xOrderType: Option " ",Sales,"Purchase Return",Transfer,Production;
        OrderNo: Code[20];
        xOrderNo: Code[20];
        OrderLineNo: Integer;
        [InDataSet]
        OrderLineVisible: Boolean;
        [InDataSet]
        OrderLineEnabled: Boolean;
        [InDataSet]
        OrderLineEditable: Boolean;
        DeleteContainer: Boolean;
        Text002: Label 'Order number must be specified.';
        Text003: Label '%1 %2 is already on a %3.';
        Text004: Label 'Order line number must be specified.';

    local procedure ValidateOrderNo()
    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        TransHeader: Record "Transfer Header";
        ProductionOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        WarehouseReceipt: Page "Warehouse Receipt";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        WarehouseShipment: Page "Warehouse Shipment";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        TransferOrder: Page "Transfer Order";
        OrderTypeText: Text;
        Text001: Label 'Order type must be specified.';
    begin
        // P80046533
        // P80056709
        if OrderNo = '' then begin
            OrderLineNo := 0;
            exit;
        end;
        // P80056709

        if ContainerHeader.Inbound then begin
            if OrderTypeInbound = 0 then // P80056709
                Error(Text001);            // P80056709
            case OrderTypeInbound of
                OrderTypeInbound::"Sales Return":
                    begin
                        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", OrderNo);
                        OrderTypeText := Format(SalesHeader."Document Type");
                        WarehouseReceiptLine.SetRange("Source Type", DATABASE::"Sales Line");
                        WarehouseReceiptLine.SetRange("Source Subtype", SalesHeader."Document Type");
                        WarehouseReceiptLine.SetRange("Source No.", SalesHeader."No.");
                        WarehouseReceiptLine.SetRange("Location Code", ContainerHeader."Location Code");
                    end;
                OrderTypeInbound::Purchase:
                    begin
                        PurchHeader.Get(PurchHeader."Document Type"::Order, OrderNo);
                        OrderTypeText := Format(PurchHeader."Document Type");
                        WarehouseReceiptLine.SetRange("Source Type", DATABASE::"Purchase Line");
                        WarehouseReceiptLine.SetRange("Source Subtype", PurchHeader."Document Type");
                        WarehouseReceiptLine.SetRange("Source No.", PurchHeader."No.");
                        WarehouseReceiptLine.SetRange("Location Code", ContainerHeader."Location Code");
                    end;
            end;
            if not WarehouseReceiptLine.IsEmpty then
                Error(Text003, OrderTypeText, OrderNo, WarehouseReceipt.Caption);
        end else begin
            if OrderTypeOutbound = 0 then // P80056709
                Error(Text001);             // P80056709
            case OrderTypeOutbound of
                OrderTypeOutbound::Sales:
                    begin
                        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);
                        OrderTypeText := Format(SalesHeader."Document Type");
                        WarehouseShipmentLine.SetRange("Source Type", DATABASE::"Sales Line");
                        WarehouseShipmentLine.SetRange("Source Subtype", SalesHeader."Document Type");
                        WarehouseShipmentLine.SetRange("Source No.", SalesHeader."No.");
                        WarehouseShipmentLine.SetRange("Location Code", ContainerHeader."Location Code");
                    end;
                OrderTypeOutbound::"Purchase Return":
                    begin
                        PurchHeader.Get(PurchHeader."Document Type"::"Return Order", OrderNo);
                        OrderTypeText := Format(PurchHeader."Document Type");
                        WarehouseShipmentLine.SetRange("Source Type", DATABASE::"Purchase Line");
                        WarehouseShipmentLine.SetRange("Source Subtype", PurchHeader."Document Type");
                        WarehouseShipmentLine.SetRange("Source No.", PurchHeader."No.");
                        WarehouseShipmentLine.SetRange("Location Code", ContainerHeader."Location Code");
                    end;
                OrderTypeOutbound::Transfer:
                    begin
                        TransHeader.Get(OrderNo);
                        TransHeader.TestField("Transfer-from Code", ContainerHeader."Location Code");
                        OrderTypeText := TransferOrder.Caption;
                        WarehouseShipmentLine.SetRange("Source Type", DATABASE::"Transfer Line");
                        WarehouseShipmentLine.SetRange("Source Subtype", 0);
                        WarehouseShipmentLine.SetRange("Source No.", TransHeader."No.");
                        WarehouseShipmentLine.SetRange("Location Code", ContainerHeader."Location Code");
                    end;
                // P80056709
                OrderTypeOutbound::Production:
                    begin
                        ProductionOrder.Get(ProductionOrder.Status::Released, OrderNo);
                        ProductionOrder.TestField("Location Code", ContainerHeader."Location Code");
                        OrderTypeText := ProductionOrder.TableCaption;
                        OrderLineEditable := false;
                        if OrderLineVisible then begin
                            ProdOrderLine.SetRange(Status, ProductionOrder.Status);
                            ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
                            if ProdOrderLine.FindFirst then begin
                                if ProdOrderLine.Next = 0 then
                                    OrderLineNo := ProdOrderLine."Line No."
                                else begin
                                    OrderLineNo := 0;
                                    OrderLineEditable := true;
                                end;
                            end;
                        end;
                    end;
                    // P80056709
            end;
            if (OrderTypeOutbound <> OrderTypeOutbound::Production) and (not WarehouseShipmentLine.IsEmpty) then // P80056709
                Error(Text003, OrderTypeText, OrderNo, WarehouseShipment.Caption);
        end;
    end;

    procedure SetContainer(ContHeader: Record "Container Header")
    var
        Location: Record Location;
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ContainerHeader := ContHeader;
        Inbound := ContainerHeader.Inbound;
        if ContainerHeader.Inbound then begin
            case ContainerHeader."Document Type" of
                DATABASE::"Sales Line":
                    OrderTypeInbound := OrderTypeInbound::"Sales Return";
                DATABASE::"Purchase Line":
                    OrderTypeInbound := OrderTypeInbound::Purchase;
            end;
            xOrderType := OrderTypeInbound;
        end else begin
            // P80056709
            if ContainerHeader."Location Code" <> '' then begin
                Location.Get(ContainerHeader."Location Code");
                OrderLineVisible := Location."Pick Production by Line";
            end;
            // P80056709
            case ContainerHeader."Document Type" of
                DATABASE::"Sales Line":
                    OrderTypeOutbound := OrderTypeOutbound::Sales;
                DATABASE::"Purchase Line":
                    OrderTypeOutbound := OrderTypeOutbound::"Purchase Return";
                DATABASE::"Transfer Line":
                    OrderTypeOutbound := OrderTypeOutbound::Transfer;
                // P80056709
                DATABASE::"Prod. Order Component":
                    begin
                        OrderTypeOutbound := OrderTypeOutbound::Production;
                        OrderLineEnabled := (OrderTypeOutbound = OrderTypeOutbound::Production) and Location."Pick Production by Line";
                        ProdOrderLine.SetRange(Status, ContainerHeader."Document Subtype");
                        ProdOrderLine.SetRange("Prod. Order No.", ContainerHeader."Document No.");
                        OrderLineEditable := 1 < ProdOrderLine.Count;
                    end;
                    // P80056709
            end;
            xOrderType := OrderTypeOutbound;
        end;
        OrderNo := ContainerHeader."Document No.";
        OrderLineNo := ContainerHeader."Document Line No."; // P80056709
    end;

    procedure GetOrder(var DocType: Integer; var DocNo: Code[20]; var DocLineNo: Integer; var DeleteCont: Boolean)
    begin
        DocType := GetDocType;
        DocNo := OrderNo;
        DocLineNo := OrderLineNo; // P80056709
        DeleteCont := DeleteContainer;
    end;

    local procedure GetDocType(): Integer
    begin
        if ContainerHeader.Inbound then begin
            case OrderTypeInbound of
                OrderTypeInbound::" ":
                    exit(0);
                OrderTypeInbound::"Sales Return":
                    exit(DATABASE::"Sales Line");
                OrderTypeInbound::Purchase:
                    exit(DATABASE::"Purchase Line");
            end;
        end else begin
            case OrderTypeOutbound of
                OrderTypeOutbound::" ":
                    exit(0);
                OrderTypeOutbound::Sales:
                    exit(DATABASE::"Sales Line");
                OrderTypeOutbound::"Purchase Return":
                    exit(DATABASE::"Purchase Line");
                OrderTypeOutbound::Transfer:
                    exit(DATABASE::"Transfer Line");
                OrderTypeOutbound::Production:
                    exit(DATABASE::"Prod. Order Component"); // P80056709
            end;
        end;
    end;
}

