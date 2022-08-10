page 37002063 "Dist. Planning Role Center"
{
    // PRW16.00.03
    // P8000810, VerticalSoft, Don Bresee, 11 APR 10
    //   Create Distribution Planning Role Center
    // 
    // PRW17.10
    // P8001218, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Remove Outlook part
    // 
    // PRW18.00
    // P8001355, Columbus IT, Jack Reynolds, 30 OCT 14
    //   Add Report Inbox
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 10 MAR 16
    //   Cleanup old delivery trips
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80060684, To-Increase, Jack Reynolds, 2 AUG 18
    //   Update Caption
    //
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 01 JUN 22
    //   Cleanup Role Centers and Navigate (Find Entries)

    Caption = 'Distribution Planning';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            part(Headline; "Headline Dist. Planning")
            {
                ApplicationArea = Basic, Suite;
            }
            group(Control37002001)
            {
                ShowCaption = false;
                part(Control37002002; "Dist. Planning Activities")
                {
                    ApplicationArea = FOODBasic;
                }
                part(Control37002005; "My Items")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Control37002004)
            {
                ShowCaption = false;
                part(Control37002003; "Report Inbox Part")
                {
                    ApplicationArea = FOODBasic;
                }
                systempart(Control37002006; MyNotes)
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
        area(embedding)
        {
            action(OrderShipping)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Order Shipping';
                Image = Shipment;
                RunObject = Page "Order Shipping";
            }
            action(OrderReceiving)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Order Receiving';
                Image = Receipt;
                RunObject = Page "Order Receiving";
            }
            action("Delivery Trips")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Delivery Trips';
                Image = SalesShipment;
                RunObject = Page "N138 Delivery Trip List";
            }
        }
        area(Creation)
        {
            action("Pickup &Load")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Pickup &Load';
                Image = CreateWarehousePick;
                RunObject = Page "Pickup Load";
                RunPageMode = Create;
            }

        }
        area(processing)
        {
            group(Shipping)
            {
                Caption = 'Shipping';
                action("Order S&hipping")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Order S&hipping';
                    Image = Shipment;
                    RunObject = Page "Order Shipping";
                }
                action(DeliveryTrips)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Delivery Trips';
                    Image = SalesShipment;
                    RunObject = Page "N138 Delivery Trip List";
                }
                action("Make Delivery &Orders")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Make Delivery &Orders';
                    Image = Delivery;
                    RunObject = Report "Make Delivery Orders";
                }
            }
            group(Receiving)
            {
                Caption = 'Receiving';
                action("Order Receivin&g")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Order Receivin&g';
                    Image = Receipt;
                    RunObject = Page "Order Receiving";
                }
                action("Truckload Receiving")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Truckload Receiving';
                    Image = ExportReceipt;
                    RunObject = Page "Truckload Receiving";
                }
                action("Pickup Loads")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pickup Loads';
                    Image = CreateWarehousePick;
                    RunObject = Page "Pickup Load List";
                }
            }
            group(Administration)
            {
                Caption = 'Administration';
                action("Delivery Routes")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Delivery Routes';
                    Image = Delivery;
                    RunObject = Page "Delivery Route List";
                }
                action("Delivery Drivers")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Delivery Drivers';
                    Image = Delivery;
                    RunObject = Page "Delivery Driver List";
                }
                action("Pick Classes")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pick Classes';
                    Image = InventoryPick;
                    RunObject = Page "Pick Classes";
                }
            }
            group(History)
            {
                Caption = 'History';
                action("Route Re&view")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Route Re&view';
                    Image = Route;
                    RunObject = Page "Posted Delivery Route Review";
                }
                action("Navi&gate")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Find entries...';
                    Image = Navigate;
                    RunObject = Page Navigate;
                                    ShortCutKey = 'Ctrl+Alt+Q';
                }

            }
        }
        area(reporting)
        {
            group(Reports)
            {
                Caption = 'Reports';
                action("Pickup Load Sheet")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pickup Load Sheet';
                    Image = PickWorksheet;
                    RunObject = Report "Pickup Load Sheet";
                }
                action("Projected Shortage List")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Projected Shortage List';
                    Image = List;
                    RunObject = Report "Projected Shortage List";
                }
                action("Truck Loading Sheet")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Truck Loading Sheet';
                    Image = Worksheet;
                    RunObject = Report "Truck Loading Sheet";
                }
                action("Delivery Trip Route Sheet")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Delivery Trip Route Sheet';
                    Image = Delivery;
                    RunObject = Report "Delivery Trip Route Sheet";
                }
            }
        }
    }
}

