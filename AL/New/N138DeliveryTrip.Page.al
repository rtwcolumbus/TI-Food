page 37002452 "N138 Delivery Trip"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // TOM4226   , 02-10-2015, Show card instead of list if single warehouse shipment
    // --------------------------------------------------------------------------------
    // TOM4224   , 02-10-2015, Post and Print; Shipment posting only
    // --------------------------------------------------------------------------------
    // TOM4220     05-10-2015  Auto creation of warehouse shipment with delivery trip
    // --------------------------------------------------------------------------------
    // TOM4554     27-10-2015  Add Truck ID
    // --------------------------------------------------------------------------------
    // 
    // PRW18.00.01
    // P8001379, Columbus IT, Jack Reynolds, 31 MAR 15
    //   Add FOOD fields
    // 
    // PRW18.00.02
    // P8004374, To-Increase, Jack Reynolds, 08 OCT 15
    //   Hide source documents in fact box
    // 
    // PRW19.00.01
    // P8006916, To-Increase, Dayakar Battini, 16 JUN 16
    //   FOOD-TOM Separation delete Transsmart objects
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // P80038979, To-Increase, Dayakar Battini, 18 DEC 17
    //   Adding Pickup load management functionality
    // 
    // P80050542, To-Increase, Dayakar Battini, 21 MAR 18
    //   Loading dock in-use info while selecting the loading dock

    Caption = 'Delivery Trip';
    PageType = Document;
    PromotedActionCategories = 'New,Process,Reports,Delivery Trip,Warehouse Shipment,Transport Order,Category7_caption,Category8_caption,Category9_caption,Category10_caption';
    SourceTable = "N138 Delivery Trip";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.Update; // P800110597
                    end;
                }
                field("Delivery Route No."; "Delivery Route No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
                field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                {
                    ApplicationArea = FOODBasic;
                    Importance = Additional;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Departure Date"; "Departure Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Departure Time"; "Departure Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Truck ID"; "Truck ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pickup Loading No."; "Pickup Loading No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Driver No."; "Driver No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Driver Name"; "Driver Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Loading Dock"; "Loading Dock")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        LoadingOnAfterValidate;  // P80050542
                    end;
                }
                field(LoadingAt; LoadingAt)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Loading Dock In-Use by';
                    Editable = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(SourceDocuments; "Delivery Trip Source Documents")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Source Documents';
                SubPageLink = "Delivery Trip" = FIELD("No.");
                SubPageView = SORTING("Source Type", "Source No.");
                UpdatePropagation = Both;
            }
            part(Containers; "Delivery Trip Containers")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Containers';
                Provider = SourceDocuments;
                SubPageLink = "Source Type" = FIELD("Source Type"),
                              "Source Subtype" = FIELD("Source Subtype"),
                              "Source No." = FIELD("Source No.");
                UpdatePropagation = Both;
            }
        }
        area(factboxes)
        {
            part(DeliveryTripFactbox; "N138 Delivery Trip Factbox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("Delivery Trip")
            {
                Caption = 'Delivery Trip';
                action(Loading)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Loading';
                    Image = TransferReceipt;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Visible = (NOT N138active);

                    trigger OnAction()
                    begin
                        DeliveryTripMgt.Loading(Rec, true);
                        CurrPage.Containers.PAGE.SetDeliveryTrip(Rec); // P8001323
                    end;
                }
                action(Shipped)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Shipped';
                    Image = ExportShipment;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Visible = (NOT N138active);

                    trigger OnAction()
                    begin
                        DeliveryTripMgt.Shipped(Rec, true);
                        CurrPage.Containers.PAGE.SetDeliveryTrip(Rec); // P8001323
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Reopen';
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Visible = (NOT N138active);

                    trigger OnAction()
                    begin
                        DeliveryTripMgt.Reopen(Rec, true);
                        CurrPage.Containers.PAGE.SetDeliveryTrip(Rec); // P8001323
                    end;
                }
                action("P&ost Shipment")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'P&ost Shipment';
                    Ellipsis = true;
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    Visible = (NOT N138active);

                    trigger OnAction()
                    begin
                        DeliveryTripMgt.PostDeliveryTrip(Rec, false, true); // TOM4224
                    end;
                }
                action("Post and &Print")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Post and &Print';
                    Ellipsis = true;
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';
                    Visible = (NOT N138active);

                    trigger OnAction()
                    begin
                        DeliveryTripMgt.PostDeliveryTrip(Rec, true, true); // TOM4224
                    end;
                }
                separator(Separator5)
                {
                }
                action(TransportCosts)
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Transport Cost';
                    Image = SalesPrices;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        OpenTransportCost;
                    end;
                }
            }
            group("Warehouse Shipment")
            {
                Caption = 'Warehouse Shipment';
                action("Whse. Shipments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Whse. Shipments';
                    Image = ShipmentLines;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        WhseShipmentHdr: Record "Warehouse Shipment Header";
                        WhseShipmentCount: Integer;
                    begin
                        // TOM4226
                        WhseShipmentHdr.SetRange("Delivery Trip", "No.");
                        WhseShipmentCount := WhseShipmentHdr.Count;
                        case WhseShipmentCount of
                            0:
                                exit;
                            1:
                                PAGE.Run(PAGE::"Warehouse Shipment", WhseShipmentHdr);
                            else
                                PAGE.Run(PAGE::"N138 Shipment List", WhseShipmentHdr);
                        end;
                    end;
                }
                action("Create Warehouse Shipment")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Create Warehouse Shipment';
                    Image = NewShipment;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        CreateWarehouseShipment; // TOM4220
                    end;
                }
                action("Link Warehouse Shipment")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Link Warehouse Shipment';
                    Image = LinkWithExisting;
                    Promoted = true;
                    PromotedCategory = Category5;

                    trigger OnAction()
                    begin
                        DeliveryTripMgt.LinkDeliveryTripWhseShipment2(Rec);
                    end;
                }
                action("Pick Lines")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pick Lines';
                    Image = PickLines;
                    Promoted = true;
                    PromotedCategory = Category5;

                    trigger OnAction()
                    begin
                        DeliveryTripMgt.OpenLinkedPicks(Rec);
                    end;
                }
            }
        }
        area(reporting)
        {
            action("Delivery Route Sheet")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Delivery Route Sheet';
                Image = "Report";

                trigger OnAction()
                var
                    DeliveryRouteSheet: Report "Delivery Trip Route Sheet";
                    DeliveryTrip: Record "N138 Delivery Trip";
                begin
                    Clear(DeliveryRouteSheet);
                    DeliveryTrip.SetRange("No.", "No.");
                    DeliveryRouteSheet.SetTableView(DeliveryTrip);
                    DeliveryRouteSheet.RunModal;
                end;
            }
            action("Truck Loading Sheet")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Truck Loading Sheet';
                Image = "Report";

                trigger OnAction()
                var
                    TruckLoadingSheet: Report "Truck Loading Sheet";
                    DeliveryTrip: Record "N138 Delivery Trip";
                begin
                    Clear(TruckLoadingSheet);
                    DeliveryTrip.SetRange("No.", "No.");
                    TruckLoadingSheet.SetTableView(DeliveryTrip);
                    TruckLoadingSheet.RunModal;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CurrPage.Containers.PAGE.SetDeliveryTrip(Rec); // P8001323
        LoadingOnAfterValidate; // P80050542
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        // P8001379
        CurrPage.Containers.PAGE.ClearSource;
        exit(Find(Which));
        // P8001379
    end;

    trigger OnOpenPage()
    begin
        CurrPage.DeliveryTripFactbox.PAGE.HideSourceDocuments; // P8004374
    end;

    var
        DeliveryTripMgt: Codeunit "N138 Delivery Trip Mgt.";
        N138Active: Boolean;
        LoadingAt: Code[20];

    local procedure LoadingOnAfterValidate()
    begin
        // P80050452
        LoadingAt := DeliveryTripMgt.LoadingAtDeliveryTrip(Rec);
        // P80050452
    end;
}

