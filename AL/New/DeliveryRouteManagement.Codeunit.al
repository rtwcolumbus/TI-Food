codeunit 37002060 "Delivery Route Management"
{
    // PR3.70.10
    // P8000228A, Myers Nissi, Phyllis McGovern, 08 JUL 05
    //   Added Functions: GetShipmentOrderShipped , GetShipmentNetWeightShipped , GetShipmentAmtShipped
    // 
    // PRW15.00.01
    // P8000547A, VerticalSoft, Jack Reynolds, 02 MAY 08
    //   Modified to support ship-to's, vendors, order addresses
    //   Modified for Locations
    //   Modified for validating routes against dates
    // 
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Support for delivery trips
    // 
    // PRW15.00.03
    // P8000630A, VerticalSoft, Don Bresee, 17 SEP 08
    //   Add Whse. logic to delivery trips
    // 
    // P8000644, VerticalSoft, Jack Reynolds, 25 NOV 08
    //   Support for total quantity, weight, volume
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 30 JUN 09
    //   Modify function InsertRoute to use Option values instead of Integer values in For Loop.
    // 
    // PRW16.00.03
    // P8000828, VerticalSoft, Don Bresee, 24 MAY 10
    //   Create lookup to present unassigned orders as a seperate page
    // 
    // PRW16.00.05
    // P8000955, Columbus IT, Jack Reynolds, 08 JUN 11
    //   Fix problem with duplicate delivery trip orders
    // 
    // P8000954, Columbus IT, Jack Reynolds, 08 JUL 11
    //   Support for transfer orders on delivery routes and trips
    // 
    // PRW16.00.06
    // P8001003, Columbus IT, Jack Reynolds, 09 DEC 11
    //   Modify LookupTrip to exclude posted trips
    // 
    // P8001111, Columbus IT, Don Bresee, 02 NOV 12
    //   Add "Promised Delivery Date" field, move INSERT
    // 
    // PRW17.10
    // P8001241, Columbus IT, Jack Reynolds, 12 NOV 13
    //   Fix problem deleting and changing orders on delivery trips
    // 
    // PRW17.10.02
    // P8001277, Columbus IT, Jack Reynolds, 03 FEB 14
    //   Allow Delivery Trips by order type
    // 
    // PRW18.00.01
    // P8001379, Columbus IT, Jack Reynolds, 31 MAR 15
    //   Migrate to TOM Delivery trips
    // 
    // PRW18.00.02
    // P8004220, To-Increase, Jack Reynolds, 05 OCT 15
    //   Auto create warehouse shipment when creating delivery trip
    // 
    // P8004269, To-Increase, Jack Reynolds, 07 OCT 15
    //   Update source document Delivery Route No.
    // 
    // P8004554, To-Increase, Jack Reynolds, 27 OCT 15
    //   Support for delivery trip history
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // PRW19.00.01
    // P8007168, To-Increase, Dayakar Battini, 20 SEP 16
    //  Trip Settlement Posting Issue
    // 
    // PRW110.0.01
    // P80042706, To-Increase, Dayakar Battini, 07 JUL 17
    //  Fix issue with Delivery Route behaviour
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW110.0.02
    // P80038970, To-Increase, Dayakar Battini, 28 NOV 17
    //    Delivery Trip changes
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // P80072445, To-Increase, Gangabhushan, 24 APR 19
    //   Dev. Delivery Route information on non-valid days


    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'Shipment %1 indicates a quantity of %2 (%3) for %4 %5 that must be invoiced with a %6 of %7.';
        NameLookupDriver: Record "Delivery Driver";
        Text002: Label '%1 %2 is not enabled for %3.  Continue?';
        Text003: Label 'Cancelled.';
        Text004: Label 'Route No. #1#########';
        ConfirmTxtOneMoreDeliveryTrip: Label 'One or more posted shipments exists. Do you want to add sales order to a delivery trip? (yes/no).';
        WarehouseSetupFound: Boolean;
        VarGuid: Integer;

    procedure GetDeliveryDriverNo(RouteDate: Date; RouteNo: Code[250]; var DriverNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        Route: Record "Delivery Route";
    begin
        DriverNo := '';
        if Route.Get(RouteNo) then begin
            SetDeliveryRouteFilters(SalesHeader, RouteDate, RouteNo);
            if not SalesHeader.Find('-') then
                DriverNo := Route."Default Driver No."
            else
                DriverNo := SalesHeader."Delivery Driver No.";
        end;
    end;

    procedure SetDeliveryDriverNo(RouteDate: Date; RouteNo: Code[20]; DriverNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
    begin
        SetDeliveryRouteFilters(SalesHeader, RouteDate, RouteNo);
        SalesHeader.Find('-');
        repeat
            SalesHeader.Validate("Delivery Driver No.", DriverNo);
            SalesHeader.Modify(true);
        until (SalesHeader.Next = 0);
    end;

    procedure GetDeliveryDriverName(DriverNo: Code[20]): Text[100]
    begin
        if (DriverNo = '') then
            exit('');
        if (DriverNo <> NameLookupDriver."No.") then
            NameLookupDriver.Get(DriverNo);
        exit(NameLookupDriver.Name);
    end;

    procedure SetDeliveryRouteFilters(var SalesHeader: Record "Sales Header"; RouteDate: Date; RouteNo: Code[20])
    begin
        SalesHeader.Reset;
        SalesHeader.SetCurrentKey("Document Type", "Shipment Date", "Delivery Route No.", "Delivery Stop No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("Shipment Date", RouteDate);
        SalesHeader.SetRange("Delivery Route No.", RouteNo);
    end;

    procedure SetRouteDefaultDriver(RouteNo: Code[20]; OldDriverNo: Code[20]; NewDriverNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Reset;
        SalesHeader.SetCurrentKey("Document Type", "Shipment Date", "Delivery Route No.", "Delivery Stop No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("Delivery Route No.", RouteNo);
        SalesHeader.SetRange("Delivery Driver No.", OldDriverNo);
        while SalesHeader.Find('-') do begin
            SalesHeader."Delivery Driver No." := NewDriverNo;
            SalesHeader.Modify(true);
        end;
    end;

    procedure CheckRouteAtInvoice(var SalesLine: Record "Sales Line"; var SalesShptLine: Record "Sales Shipment Line")
    begin
        if (SalesLine."Delivery Route No." <> SalesShptLine."Delivery Route No.") then
            Error(Text001,
                  SalesShptLine."Document No.", SalesShptLine."Qty. Shipped Not Invoiced",
                  SalesShptLine."Unit of Measure", SalesShptLine.Type, SalesShptLine."No.",
                  SalesShptLine.FieldCaption("Delivery Route No."), SalesShptLine."Delivery Route No.");

        if (SalesLine."Delivery Stop No." <> SalesShptLine."Delivery Stop No.") then
            Error(Text001,
                  SalesShptLine."Document No.", SalesShptLine."Qty. Shipped Not Invoiced",
                  SalesShptLine."Unit of Measure", SalesShptLine.Type, SalesShptLine."No.",
                  SalesShptLine.FieldCaption("Delivery Stop No."), SalesShptLine."Delivery Stop No.");
    end;

    procedure GetPostedDeliveryDriverNo(RouteDate: Date; RouteNo: Code[250]; var DriverNo: Code[20])
    var
        SalesInvHeader: Record "Sales Invoice Header";
        Route: Record "Delivery Route";
    begin
        DriverNo := '';
        if Route.Get(RouteNo) then begin
            SalesInvHeader.Reset;
            SalesInvHeader.SetCurrentKey("Shipment Date", "Delivery Route No.", "Delivery Stop No.");
            SalesInvHeader.SetRange("Shipment Date", RouteDate);
            SalesInvHeader.SetRange("Delivery Route No.", RouteNo);
            if not SalesInvHeader.Find('-') then
                DriverNo := Route."Default Driver No."
            else
                DriverNo := SalesInvHeader."Delivery Driver No.";
        end;
    end;

    procedure GetSalesDeliveryRouting(var SalesHeader: Record "Sales Header")
    var
        RoutingMatrixLine: Record "Delivery Routing Matrix Line";
        Customer: Record Customer;
        ShipToAddress: Record "Ship-to Address";
        DeliveryRoute: Record "Delivery Route";
        DeliveryRouteSched: Record "Delivery Route Schedule";
        RouteNo: Code[20];
        StopNo: Code[20];
        NewDeliveryDate: Date;
        Notification: Notification;
        TxtShipDate: Label 'Shipment Date changed from %1 to %2';
        ShptDateChangeText: Text;
        PrevShptDt: Date;
        OldShptdate: Date;
        PrevRouteNo: Code[20];
        PrevStopNo: Code[20];
    begin
        // P8000547A
        with SalesHeader do begin
            if ("Document Type" in ["Document Type"::Order, "Document Type"::"Return Order"]) and
               ("Sell-to Customer No." <> '') and
               ("Shipment Date" <> 0D)
            then begin
                // P80072445
                PrevRouteNo := "Delivery Route No.";
                PrevStopNo := "Delivery Stop No.";
                if DeliveryRouteSched.Get(PrevRouteNo, Date2DWY("Shipment Date", 1)) then
                    if DeliveryRouteSched.Enabled then
                        exit;
                Validate("Delivery Route No.", '');
                Validate("Delivery Stop No.", '');
                // P80072445
                if "Ship-to Code" <> '' then begin
                    if RoutingMatrixLine.Get(RoutingMatrixLine."Source Type"::"Ship-to", "Sell-to Customer No.",
                      "Ship-to Code", Date2DWY("Shipment Date", 1)) and (RoutingMatrixLine."Delivery Route No." <> '')
                    then begin
                        RouteNo := RoutingMatrixLine."Delivery Route No.";
                        StopNo := RoutingMatrixLine."Delivery Stop No.";
                    end else begin
                        ShipToAddress.Get("Sell-to Customer No.", "Ship-to Code");
                        if ShipToAddress."Default Delivery Route No." <> '' then begin
                            RouteNo := ShipToAddress."Default Delivery Route No.";
                            StopNo := ShipToAddress."Default Delivery Stop No.";
                        end;
                    end;
                end;
                OldShptdate := "Shipment Date"; // P80072445
                if RouteNo = '' then
                    if RoutingMatrixLine.Get(RoutingMatrixLine."Source Type"::Customer, "Sell-to Customer No.",
                      '', Date2DWY("Shipment Date", 1)) and (RoutingMatrixLine."Delivery Route No." <> '')
                    then begin
                        RouteNo := RoutingMatrixLine."Delivery Route No.";
                        StopNo := RoutingMatrixLine."Delivery Stop No.";
                    end else begin
                        Customer.Get("Sell-to Customer No.");
                        if Customer."Default Delivery Route No." <> '' then begin
                            RouteNo := Customer."Default Delivery Route No.";
                            StopNo := Customer."Default Delivery Stop No.";
                            //END;
                        end else begin
                            NewDeliveryDate := GetNextDelRtMatrixLine(RoutingMatrixLine."Source Type"::Customer, "Sell-to Customer No.",
                                                '', "Shipment Date", RoutingMatrixLine);
                            RouteNo := RoutingMatrixLine."Delivery Route No.";
                            StopNo := RoutingMatrixLine."Delivery Stop No.";
                        end;
                    end;
            end;

            if RouteNo <> '' then begin
                DeliveryRoute.Get(RouteNo);
                // P80072445
                if NewDeliveryDate <> 0D then
                    Validate("Shipment Date", NewDeliveryDate); //72445
                                                                // P80072445
                DeliveryRouteSched.Get(RouteNo, Date2DWY("Shipment Date", 1));
                // P80072445
                if (DeliveryRoute."Location Code" = "Location Code") then
                    if DeliveryRouteSched.Enabled then begin
                        if OldShptdate <> "Shipment Date" then
                            "Promised Delivery Date" := OldShptdate
                        else
                            "Promised Delivery Date" := "Shipment Date";
                        // P80072445
                        Validate("Delivery Route No.", RouteNo);
                        Validate("Delivery Stop No.", StopNo);
                        if OldShptdate <> "Shipment Date" then begin
                            ShptDateChangeText := StrSubstNo(TxtShipDate, OldShptdate, "Shipment Date");
                            Notification.Message(ShptDateChangeText);
                            if VarGuid = 0 then begin
                                Notification.Scope := NOTIFICATIONSCOPE::LocalScope;
                                Notification.Send;
                            end;
                            VarGuid := 1;
                        end;
                    end else begin
                        RoutingMatrixLine.SetRange("Source Type", RoutingMatrixLine."Source Type"::Customer);
                        RoutingMatrixLine.SetRange("Source No.", "Sell-to Customer No.");
                        RoutingMatrixLine.SetFilter("Delivery Route No.", '<>%1', '');
                        if RoutingMatrixLine.FindSet then
                            repeat
                                NewDeliveryDate := GetNextDelRtMatrixLine(RoutingMatrixLine."Source Type"::Customer, "Sell-to Customer No.",
                                                    '', "Shipment Date", RoutingMatrixLine);
                            until NewDeliveryDate <> 0D;
                        if PrevShptDt = 0D then
                            PrevShptDt := "Shipment Date";
                        SalesHeader.FromDelRtShpt(true);
                        Validate("Shipment Date", NewDeliveryDate);
                        "Promised Delivery Date" := PrevShptDt;
                        Validate("Delivery Route No.", RoutingMatrixLine."Delivery Route No.");
                        Validate("Delivery Stop No.", RoutingMatrixLine."Delivery Stop No.");
                        if PrevShptDt <> "Shipment Date" then begin
                            ShptDateChangeText := StrSubstNo(TxtShipDate, PrevShptDt, "Shipment Date");
                            Notification.Message(ShptDateChangeText);
                            if VarGuid = 0 then begin
                                Notification.Scope := NOTIFICATIONSCOPE::LocalScope;
                                Notification.Send;
                            end;
                            VarGuid := 1;
                        end;
                    end;
            end;
        end;
        // P8000547A
    end;

    procedure GetPurchDeliveryRouting(var PurchHeader: Record "Purchase Header")
    var
        RoutingMatrixLine: Record "Delivery Routing Matrix Line";
        Vendor: Record Vendor;
        OrderAddress: Record "Order Address";
        DeliveryRoute: Record "Delivery Route";
        RouteNo: Code[20];
    begin
        // P8000547A
        with PurchHeader do begin
            Validate("Delivery Route No.", '');
            if ("Document Type" in ["Document Type"::Order, "Document Type"::"Return Order"]) and
               ("Buy-from Vendor No." <> '') and
               ("Expected Receipt Date" <> 0D)
            then begin
                if "Order Address Code" <> '' then begin
                    if RoutingMatrixLine.Get(RoutingMatrixLine."Source Type"::"Order Address", "Buy-from Vendor No.",
                      "Order Address Code", Date2DWY("Expected Receipt Date", 1)) and (RoutingMatrixLine."Delivery Route No." <> '')
                    then
                        RouteNo := RoutingMatrixLine."Delivery Route No."
                    else begin
                        OrderAddress.Get("Buy-from Vendor No.", "Order Address Code");
                        if OrderAddress."Default Delivery Route No." <> '' then
                            RouteNo := OrderAddress."Default Delivery Route No.";
                    end;
                end;
                if RouteNo = '' then
                    if RoutingMatrixLine.Get(RoutingMatrixLine."Source Type"::Vendor, "Buy-from Vendor No.",
                      '', Date2DWY("Expected Receipt Date", 1)) and (RoutingMatrixLine."Delivery Route No." <> '')
                    then
                        RouteNo := RoutingMatrixLine."Delivery Route No."
                    else begin
                        Vendor.Get("Buy-from Vendor No.");
                        if Vendor."Default Delivery Route No." <> '' then
                            RouteNo := Vendor."Default Delivery Route No.";
                    end;
            end;

            if RouteNo <> '' then begin
                DeliveryRoute.Get(RouteNo);
                if DeliveryRoute."Location Code" = "Location Code" then
                    Validate("Delivery Route No.", RouteNo);
            end;
        end;
        // P8000547A
    end;

    procedure GetTransDeliveryRouting(var TransHeader: Record "Transfer Header")
    var
        RoutingMatrixLine: Record "Delivery Routing Matrix Line";
        TransferRoute: Record "Transfer Route";
        ShipToAddress: Record "Ship-to Address";
        DeliveryRoute: Record "Delivery Route";
        DeliveryRouteSched: Record "Delivery Route Schedule";
        RouteNo: Code[20];
        StopNo: Code[20];
    begin
        // P8000954
        with TransHeader do begin
            Validate("Delivery Route No.", '');
            Validate("Delivery Stop No.", '');
            if ("Transfer-from Code" <> '') and
               ("Transfer-to Code" <> '') and
               ("Shipment Date" <> 0D)
            then begin
                if RoutingMatrixLine.Get(RoutingMatrixLine."Source Type"::Transfer, "Transfer-from Code",
                  "Transfer-to Code", Date2DWY("Shipment Date", 1)) and (RoutingMatrixLine."Delivery Route No." <> '')
                then begin
                    RouteNo := RoutingMatrixLine."Delivery Route No.";
                    StopNo := RoutingMatrixLine."Delivery Stop No.";
                end else
                    if TransferRoute.Get("Transfer-from Code", "Transfer-to Code") then;
                if TransferRoute."Default Delivery Route No." <> '' then begin
                    RouteNo := TransferRoute."Default Delivery Route No.";
                    StopNo := TransferRoute."Default Delivery Stop No.";
                end;
            end;

            if RouteNo <> '' then begin
                DeliveryRoute.Get(RouteNo);
                DeliveryRouteSched.Get(RouteNo, Date2DWY("Shipment Date", 1));
                if (DeliveryRoute."Location Code" = "Transfer-from Code") and DeliveryRouteSched.Enabled then begin
                    Validate("Delivery Route No.", RouteNo);
                    Validate("Delivery Stop No.", StopNo);
                end;
            end;
        end;
    end;

    procedure CheckDeliveryRouteDOW(RouteNo: Code[20]; Date: Date)
    var
        DeliveryRoute: Record "Delivery Route";
        DeliveryRouteSched: Record "Delivery Route Schedule";
    begin
        // P8000547A
        if (RouteNo <> '') and (Date <> 0D) then begin
            DeliveryRouteSched.Get(RouteNo, Date2DWY(Date, 1));
            if not DeliveryRouteSched.Enabled then
                if Confirm(Text002, false, DeliveryRoute.TableCaption, RouteNo, DeliveryRouteSched."Day of Week") then
                    exit
                else
                    Error(Text003);
        end;
    end;

    procedure CheckDeliveryRouteLocation(RouteNo: Code[20]; LocationCode: Code[10])
    var
        DeliveryRoute: Record "Delivery Route";
    begin
        // P8000547A
        if RouteNo <> '' then begin
            DeliveryRoute.Get(RouteNo);
            DeliveryRoute.TestField("Location Code", LocationCode);
        end;
    end;

    procedure RoutingDateToDOW(Date: Date): Integer
    begin
        exit(Date2DWY(Date, 1) mod 7);
    end;

    procedure GetOrderQtyToShip(var SalesHeader: Record "Sales Header"): Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        with SalesLine do begin
            SetCurrentKey("Document Type", Type, "Shipment Date",
                          "Delivery Route No.", "Delivery Stop No.", "Document No.");
            SetRange("Document Type", "Document Type"::Order);
            SetRange(Type, Type::Item);
            SetRange("Shipment Date", SalesHeader."Shipment Date");
            SetRange("Delivery Route No.", SalesHeader."Delivery Route No.");
            SetRange("Delivery Stop No.", SalesHeader."Delivery Stop No.");
            SetRange("Document No.", SalesHeader."No.");
            CalcSums("Qty. to Ship");
            exit("Qty. to Ship");
        end;
    end;

    procedure GetOrderNetWeightToShip(var SalesHeader: Record "Sales Header"): Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        with SalesLine do begin
            SetCurrentKey("Document Type", Type, "Shipment Date",
                          "Delivery Route No.", "Delivery Stop No.", "Document No.");
            SetRange("Document Type", "Document Type"::Order);
            SetRange(Type, Type::Item);
            SetRange("Shipment Date", SalesHeader."Shipment Date");
            SetRange("Delivery Route No.", SalesHeader."Delivery Route No.");
            SetRange("Delivery Stop No.", SalesHeader."Delivery Stop No.");
            SetRange("Document No.", SalesHeader."No.");
            CalcSums("Net Weight to Ship");
            exit("Net Weight to Ship");
        end;
    end;

    procedure GetOrderAmountToShip(var SalesHeader: Record "Sales Header"): Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        with SalesLine do begin
            SetCurrentKey("Document Type", Type, "Shipment Date",
                          "Delivery Route No.", "Delivery Stop No.", "Document No.");
            SetRange("Document Type", "Document Type"::Order);
            SetRange(Type, Type::Item);
            SetRange("Shipment Date", SalesHeader."Shipment Date");
            SetRange("Delivery Route No.", SalesHeader."Delivery Route No.");
            SetRange("Delivery Stop No.", SalesHeader."Delivery Stop No.");
            SetRange("Document No.", SalesHeader."No.");
            CalcSums("Amount to Ship (LCY)");
            exit("Amount to Ship (LCY)");
        end;
    end;

    procedure DeleteStandingOrder(var SalesHeader: Record "Sales Header")
    var
        RoutingMatrixLine: Record "Delivery Routing Matrix Line";
    begin
        if (SalesHeader."Document Type" = SalesHeader."Document Type"::FOODStandingOrder) then
            with RoutingMatrixLine do begin
                SetCurrentKey("Standing Order No.");
                SetRange("Standing Order No.", SalesHeader."No.");
                while Find('-') do begin
                    Validate("Standing Order No.", '');
                    if IsBlank() then
                        Delete(true)
                    else
                        Modify(true);
                end;
            end;
    end;

    procedure DeleteRoute(var Route: Record "Delivery Route")
    var
        RoutingMatrixLine: Record "Delivery Routing Matrix Line";
        RoutingMatrixLine2: Record "Delivery Routing Matrix Line";
        Customer: Record Customer;
        Customer2: Record Customer;
        ShipToAddress: Record "Ship-to Address";
        ShipToAddress2: Record "Ship-to Address";
        Vendor: Record Vendor;
        Vendor2: Record Vendor;
        OrderAddress: Record "Order Address";
        OrderAddress2: Record "Order Address";
        TransferRoute: Record "Transfer Route";
        TransferRoute2: Record "Transfer Route";
        SalesHeader: Record "Sales Header";
        SalesHeader2: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        PurchHeader2: Record "Purchase Header";
        TransHeader: Record "Transfer Header";
        TransHeader2: Record "Transfer Header";
        DeliveryRouteSched: Record "Delivery Route Schedule";
    begin
        // P8000547A
        RoutingMatrixLine.SetCurrentKey("Delivery Route No.");
        RoutingMatrixLine.SetRange("Delivery Route No.", Route."No.");
        if RoutingMatrixLine.FindSet(true, true) then
            repeat
                RoutingMatrixLine2 := RoutingMatrixLine;
                RoutingMatrixLine2.Validate("Delivery Route No.", '');
                RoutingMatrixLine2.Validate("Delivery Stop No.", '');
                if RoutingMatrixLine2.IsBlank() then
                    RoutingMatrixLine2.Delete(true)
                else
                    RoutingMatrixLine2.Modify(true);
            until RoutingMatrixLine.Next = 0;

        Customer.SetCurrentKey("Default Delivery Route No.");
        Customer.SetRange("Default Delivery Route No.", Route."No.");
        if Customer.FindSet(true, true) then
            repeat
                Customer2 := Customer;
                Customer2.Validate("Default Delivery Route No.", '');
                Customer2.Validate("Default Delivery Stop No.", '');
                Customer2.Modify(true);
            until Customer.Next = 0;

        ShipToAddress.SetCurrentKey("Default Delivery Route No.");
        ShipToAddress.SetRange("Default Delivery Route No.", Route."No.");
        if ShipToAddress.FindSet(true, true) then
            repeat
                ShipToAddress2 := ShipToAddress;
                ShipToAddress2.Validate("Default Delivery Route No.", '');
                ShipToAddress2.Validate("Default Delivery Stop No.", '');
                ShipToAddress2.Modify(true);
            until ShipToAddress.Next = 0;

        Vendor.SetCurrentKey("Default Delivery Route No.");
        Vendor.SetRange("Default Delivery Route No.", Route."No.");
        if Vendor.FindSet(true, true) then
            repeat
                Vendor2 := Vendor;
                Vendor2.Validate("Default Delivery Route No.", '');
                Vendor2.Modify(true);
            until Vendor.Next = 0;

        OrderAddress.SetCurrentKey("Default Delivery Route No.");
        OrderAddress.SetRange("Default Delivery Route No.", Route."No.");
        if OrderAddress.FindSet(true, true) then
            repeat
                OrderAddress2 := OrderAddress;
                OrderAddress2.Validate("Default Delivery Route No.", '');
                OrderAddress2.Modify(true);
            until OrderAddress.Next = 0;

        // P8000954
        TransferRoute.SetRange("Default Delivery Route No.", Route."No.");
        if TransferRoute.FindSet(true, true) then
            repeat
                TransferRoute2 := TransferRoute;
                TransferRoute2.Validate("Default Delivery Route No.", '');
                TransferRoute2.Validate("Default Delivery Stop No.", '');
                TransferRoute2.Modify(true);
            until TransferRoute.Next = 0;
        // P8000954

        SalesHeader.SetCurrentKey("Document Type", "Shipment Date", "Delivery Route No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("Delivery Route No.", Route."No.");
        if SalesHeader.FindSet(true, true) then
            repeat
                SalesHeader2 := SalesHeader;
                SalesHeader2.Validate("Delivery Route No.", '');
                SalesHeader2.Validate("Delivery Stop No.", '');
                SalesHeader2.Modify(true);
            until SalesHeader.Next = 0;

        // P8000954
        PurchHeader.SetCurrentKey("Document Type", "Delivery Route No.");
        PurchHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        PurchHeader.SetRange("Delivery Route No.", Route."No.");
        if PurchHeader.FindSet(true, true) then
            repeat
                PurchHeader2 := PurchHeader;
                PurchHeader2.Validate("Delivery Route No.", '');
                PurchHeader2.Validate("Delivery Stop No.", ''); // P8004554
                PurchHeader2.Modify(true);
            until PurchHeader.Next = 0;

        TransHeader.SetCurrentKey("Delivery Route No.");
        TransHeader.SetRange("Delivery Route No.", Route."No.");
        if TransHeader.FindSet(true, true) then
            repeat
                TransHeader2 := TransHeader;
                TransHeader2.Validate("Delivery Route No.", '');
                TransHeader2.Validate("Delivery Stop No.", '');
                TransHeader2.Modify(true);
            until TransHeader.Next = 0;
        // P8000954

        DeliveryRouteSched.SetRange("Delivery Route No.", Route."No.");
        DeliveryRouteSched.DeleteAll(true);
        // P8000547A
    end;

    procedure InsertRoute(var Route: Record "Delivery Route")
    var
        DelRouteSched: Record "Delivery Route Schedule";
        Index: Integer;
    begin
        // P8000547A
        DelRouteSched."Delivery Route No." := Route."No.";
        for DelRouteSched."Day of Week" := DelRouteSched."Day of Week"::Monday to DelRouteSched."Day of Week"::Sunday do  //P8000664
            DelRouteSched.Insert;
    end;

    procedure DeleteDriver(var Driver: Record "Delivery Driver")
    var
        Route: Record "Delivery Route";
        SalesHeader: Record "Sales Header";
    begin
        with Route do begin
            SetRange("Default Driver No.", Driver."No.");
            if Find('-') then
                repeat
                    Validate("Default Driver No.", '');
                    Modify(true);
                until (Next = 0);
        end;
        with SalesHeader do begin
            SetCurrentKey("Document Type", "Shipment Date", "Delivery Route No.");
            SetRange("Document Type", SalesHeader."Document Type"::Order);
            SetFilter("Delivery Route No.", '<>%1', '');
            SetRange("Delivery Driver No.", Driver."No.");
            if Find('-') then
                repeat
                    SetRange("Shipment Date", "Shipment Date");
                    SetRange("Delivery Route No.", "Delivery Route No.");
                    Find('+');
                    SetRange("Shipment Date");
                    SetRange("Delivery Route No.");
                    SetDeliveryDriverNo("Shipment Date", "Delivery Route No.", '');
                until (Next = 0);
        end;
    end;

    procedure LookupRoute(var Text: Text[1024]): Boolean
    var
        Route: Record "Delivery Route";
        RouteList: Page "Delivery Route List";
    begin
        if (Text <> '') then
            if Route.Get(Text) then
                RouteList.SetRecord(Route);
        RouteList.LookupMode(true);
        if (RouteList.RunModal <> ACTION::LookupOK) then
            exit(false);
        RouteList.GetRecord(Route);
        Text := Route."No.";
        exit(true);
    end;

    procedure LookupDriver(var Text: Text[1024]): Boolean
    var
        Driver: Record "Delivery Driver";
        DriverList: Page "Delivery Driver List";
    begin
        if (Text <> '') then
            if Driver.Get(Text) then
                DriverList.SetRecord(Driver);
        DriverList.LookupMode(true);
        if (DriverList.RunModal <> ACTION::LookupOK) then
            exit(false);
        DriverList.GetRecord(Driver);
        Text := Driver."No.";
        exit(true);
    end;

    procedure LookupCustomer(var Text: Text[1024]): Boolean
    var
        Customer: Record Customer;
        CustomerList: Page "Customer List";
    begin
        if (Text <> '') then
            if Customer.Get(Text) then
                CustomerList.SetRecord(Customer);
        CustomerList.LookupMode(true);
        if (CustomerList.RunModal <> ACTION::LookupOK) then
            exit(false);
        CustomerList.GetRecord(Customer);
        Text := Customer."No.";
        exit(true);
    end;

    procedure GetShipmentQtyShipped(var ShipmentHeader: Record "Sales Shipment Header"): Decimal
    var
        ShipmentLine: Record "Sales Shipment Line";
    begin
        //P800228A
        with ShipmentLine do begin
            SetCurrentKey(Type, "Shipment Date", "Delivery Route No.", "Delivery Stop No.");
            SetRange(Type, Type::Item);
            SetRange("Shipment Date", ShipmentHeader."Shipment Date");
            SetRange("Delivery Route No.", ShipmentHeader."Delivery Route No.");
            SetRange("Delivery Stop No.", ShipmentHeader."Delivery Stop No.");
            SetRange("Document No.", ShipmentHeader."No.");
            CalcSums(Quantity);
            exit(Quantity);
        end;
    end;

    procedure GetShipmentNetWeightShipped(var ShipmentHeader: Record "Sales Shipment Header"): Decimal
    var
        ShipmentLine: Record "Sales Shipment Line";
    begin
        //P800228A
        with ShipmentLine do begin
            SetCurrentKey(Type, "Shipment Date", "Delivery Route No.", "Delivery Stop No.");
            SetRange(Type, Type::Item);
            SetRange("Shipment Date", ShipmentHeader."Shipment Date");
            SetRange("Delivery Route No.", ShipmentHeader."Delivery Route No.");
            SetRange("Delivery Stop No.", ShipmentHeader."Delivery Stop No.");
            SetRange("Document No.", ShipmentHeader."No.");
            CalcSums("Total Net Weight");
            exit("Total Net Weight");
        end;
    end;

    procedure GetShipmentAmtShipped(var ShipmentHeader: Record "Sales Shipment Header") RouteAmount: Decimal
    var
        ShipmentLine: Record "Sales Shipment Line";
        SalesLine: Record "Sales Line";
        ItemEntryRelation: Record "Item Entry Relation";
        ItemLedger: Record "Item Ledger Entry";
    begin
        //P800228A
        ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.");
        ItemEntryRelation.SetRange("Source Type", DATABASE::"Sales Shipment Line");

        with ShipmentLine do begin
            SetCurrentKey(Type, "Shipment Date", "Delivery Route No.", "Delivery Stop No.");
            SetRange(Type, Type::Item);
            SetRange("Shipment Date", ShipmentHeader."Shipment Date");
            SetRange("Delivery Route No.", ShipmentHeader."Delivery Route No.");
            SetRange("Delivery Stop No.", ShipmentHeader."Delivery Stop No.");
            SetRange("Document No.", ShipmentHeader."No.");
            if Find('-') then
                repeat
                    if SalesLine.Get(SalesLine."Document Type"::Order, "Order No.", "Order Line No.") then begin
                        if SalesLine.PriceInAlternateUnits then
                            RouteAmount += (SalesLine.Amount / SalesLine."Quantity (Alt.)") * "Quantity (Alt.)"
                        else
                            RouteAmount += (SalesLine.Amount / SalesLine."Quantity (Base)") * "Quantity (Base)";
                    end else begin
                        if "Item Shpt. Entry No." <> 0 then begin
                            ItemLedger.Get("Item Shpt. Entry No.");
                            ItemLedger.CalcFields("Sales Amount (Actual)");
                            RouteAmount += ItemLedger."Sales Amount (Actual)";
                        end else begin
                            ItemEntryRelation.SetRange("Source ID", "Document No.");
                            ItemEntryRelation.SetRange("Source Ref. No.", "Line No.");
                            if ItemEntryRelation.Find('-') then
                                repeat
                                    ItemLedger.Get(ItemEntryRelation."Item Entry No.");
                                    ItemLedger.CalcFields("Sales Amount (Actual)");
                                    RouteAmount += ItemLedger."Sales Amount (Actual)";
                                until ItemEntryRelation.Next = 0;
                        end;
                    end;
                until Next = 0;
        end;
    end;

    procedure CreateDeliveryTrip(var WhseRqst: Record "Warehouse Request")
    var
        xWhseRqst: Record "Warehouse Request";
        Location: Record Location;
        DeliveryTrip: Record "N138 Delivery Trip";
        DeliveryRoute: Record "Delivery Route";
        TMSetup: Record "N138 Transport Mgt. Setup";
    begin
        // P8001379
        if WhseRqst.Type = WhseRqst.Type::Inbound then
            exit;
        if not (WhseRqst."Source Type" in [DATABASE::"Sales Line", DATABASE::"Purchase Line", DATABASE::"Transfer Line"]) then
            exit;
        if xWhseRqst.Get(WhseRqst.Type, WhseRqst."Location Code", WhseRqst."Source Type", WhseRqst."Source Subtype", WhseRqst."Source No.") then begin
            //WhseRqst."Delivery Trip" := xWhseRqst."Delivery Trip";           // P80042706
            //WhseRqst."Delivery Route No." := xWhseRqst."Delivery Route No."; // P8004269  // P80042706
            //WhseRqst."Delivery Stop No." := xWhseRqst."Delivery Stop No.";   // P80042706
        end;
        if WhseRqst."Delivery Trip" <> '' then
            exit;
        if WhseRqst."Shipment Date" = 0D then
            exit;

        Location.Get(WhseRqst."Location Code");
        case WhseRqst."Source Type" of
            DATABASE::"Sales Line":
                if not Location."Use Delivery Trips (Sales)" then
                    exit;
            DATABASE::"Purchase Line":
                if not Location."Use Delivery Trips (Purchase)" then
                    exit;
            DATABASE::"Transfer Line":
                if not Location."Use Delivery Trips (Transfer)" then
                    exit;
        end;
        if WhseRqst."Delivery Route No." = '' then
            exit;

        // P8007168
        if IsPostedShipmentsExists(WhseRqst) then
            if not Confirm(ConfirmTxtOneMoreDeliveryTrip, false) then
                exit;
        // P8007168

        DeliveryTrip.SetRange(Status, DeliveryTrip.Status::Open);
        DeliveryTrip.SetRange("Location Code", WhseRqst."Location Code");
        DeliveryTrip.SetRange("Delivery Route No.", WhseRqst."Delivery Route No.");
        DeliveryTrip.SetRange("Departure Date", WhseRqst."Shipment Date");
        if not DeliveryTrip.FindSet then begin
            DeliveryTrip.Init;
            DeliveryTrip.Status := DeliveryTrip.Status::Open;
            DeliveryTrip."Location Code" := WhseRqst."Location Code";
            DeliveryTrip.Validate("Departure Date", WhseRqst."Shipment Date");               // P80038970
            DeliveryTrip."Shipping Agent Code" := WhseRqst."Shipping Agent Code";                 // P8004269
            DeliveryTrip."Shipping Agent Service Code" := WhseRqst."Shipping Agent Service Code"; // P8004269
            DeliveryTrip.Validate("Delivery Route No.", WhseRqst."Delivery Route No.");      // P80038970
            DeliveryTrip.Description := '';
            DeliveryTrip.Insert(true);
        end else
            if 0 <> DeliveryTrip.Next then
                exit;

        WhseRqst."Delivery Trip" := DeliveryTrip."No.";

        // P8004220
        TMSetup.Get;
        if not TMSetup."Auto Create Del. Trip Shipment" then
            exit;
        if not Location."Require Shipment" then
            exit;
        DeliveryTrip.CreateWarehouseShipment;
        // P8004220
    end;

    procedure SetQtyWeightVolume(var WhseRqst: Record "Warehouse Request")
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
    begin
        // P8001379
        WhseRqst.Quantity := 0;
        WhseRqst.Weight := 0;
        WhseRqst.Volume := 0;

        case WhseRqst."Source Type" of
            DATABASE::"Sales Line":
                begin
                    SalesLine.SetRange("Document Type", WhseRqst."Source Subtype");
                    SalesLine.SetRange("Document No.", WhseRqst."Source No.");
                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                    SalesLine.SetRange("Location Code", WhseRqst."Location Code");
                    SalesLine.SetFilter("Outstanding Quantity", '<>0');
                    if SalesLine.FindSet then
                        repeat
                            WhseRqst.Quantity += SalesLine."Outstanding Quantity";
                            WhseRqst.Weight += SalesLine."Outstanding Quantity" *
                              P800UOMFns.GetConversionToMetricBase(SalesLine."No.", SalesLine."Unit of Measure Code", 2);
                            WhseRqst.Volume += SalesLine."Outstanding Quantity" *
                              P800UOMFns.GetConversionToMetricBase(SalesLine."No.", SalesLine."Unit of Measure Code", 3);
                        until SalesLine.Next = 0;
                end;

            DATABASE::"Purchase Line":
                begin
                    PurchLine.SetRange("Document Type", WhseRqst."Source Subtype");
                    PurchLine.SetRange("Document No.", WhseRqst."Source No.");
                    PurchLine.SetRange(Type, PurchLine.Type::Item);
                    PurchLine.SetRange("Location Code", WhseRqst."Location Code");
                    PurchLine.SetFilter("Outstanding Quantity", '<>0');
                    if PurchLine.FindSet then
                        repeat
                            WhseRqst.Quantity += PurchLine."Outstanding Quantity";
                            WhseRqst.Weight += PurchLine."Outstanding Quantity" *
                              P800UOMFns.GetConversionToMetricBase(PurchLine."No.", PurchLine."Unit of Measure Code", 2);
                            WhseRqst.Volume += PurchLine."Outstanding Quantity" *
                              P800UOMFns.GetConversionToMetricBase(PurchLine."No.", PurchLine."Unit of Measure Code", 3);
                        until PurchLine.Next = 0;
                end;

            DATABASE::"Transfer Line":
                begin
                    TransLine.SetRange("Document No.", WhseRqst."Source No.");
                    TransLine.SetRange(Type, TransLine.Type::Item);
                    TransLine.SetRange("Transfer-from Code", WhseRqst."Location Code");
                    TransLine.SetFilter("Outstanding Quantity", '<>0');
                    if TransLine.FindSet then
                        repeat
                            WhseRqst.Quantity += TransLine."Outstanding Quantity";
                            WhseRqst.Weight += TransLine."Outstanding Quantity" *
                              P800UOMFns.GetConversionToMetricBase(TransLine."Item No.", TransLine."Unit of Measure Code", 2);
                            WhseRqst.Volume += TransLine."Outstanding Quantity" *
                              P800UOMFns.GetConversionToMetricBase(TransLine."Item No.", TransLine."Unit of Measure Code", 3);
                        until TransLine.Next = 0;
                end;
        end;
    end;

    procedure GetWeightVolumeUOM(var WeightUOM: Code[10]; var VolumeUOM: Code[10])
    var
        TransportSetup: Record "N138 Transport Mgt. Setup";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
    begin
        // P8000644
        // P8001379
        TransportSetup.Get;
        if TransportSetup."Delivery Trip Unit of Weight" <> '' then
            WeightUOM := TransportSetup."Delivery Trip Unit of Weight"
        else
            WeightUOM := P800UOMFns.DefaultUOM(2);
        if TransportSetup."Delivery Trip Unit of Volume" <> '' then
            VolumeUOM := TransportSetup."Delivery Trip Unit of Volume"
        else
            VolumeUOM := P800UOMFns.DefaultUOM(3);
    end;

    procedure SetPostedWeightVolume(var DeliveryTripOrder: Record "Delivery Trip Order")
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        ReturnShipmentLine: Record "Return Shipment Line";
        TransferShipmentLine: Record "Transfer Shipment Line";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
    begin
        // P8004554
        DeliveryTripOrder.Weight := 0;
        DeliveryTripOrder.Volume := 0;

        case DeliveryTripOrder."Posted Document" of
            DeliveryTripOrder."Posted Document"::Shipment:
                begin
                    SalesShipmentLine.SetRange("Document No.", DeliveryTripOrder."Posted Document No.");
                    SalesShipmentLine.SetRange(Type, SalesShipmentLine.Type::Item);
                    SalesShipmentLine.SetFilter(Quantity, '<>0');
                    if SalesShipmentLine.FindSet then
                        repeat
                            DeliveryTripOrder.Weight +=
                              Round(P800UOMFns.ItemWeight(SalesShipmentLine."No.", SalesShipmentLine."Quantity (Base)", SalesShipmentLine."Quantity (Alt.)"), 0.000000001);
                            DeliveryTripOrder.Volume +=
                              Round(P800UOMFns.ItemVolume(SalesShipmentLine."No.", SalesShipmentLine."Quantity (Base)", SalesShipmentLine."Quantity (Alt.)"), 0.000000001);
                        until SalesShipmentLine.Next = 0;
                end;

            DeliveryTripOrder."Posted Document"::"Return Shipment":
                begin
                    ReturnShipmentLine.SetRange("Document No.", DeliveryTripOrder."Posted Document No.");
                    ReturnShipmentLine.SetRange(Type, ReturnShipmentLine.Type::Item);
                    ReturnShipmentLine.SetFilter(Quantity, '<>0');
                    if ReturnShipmentLine.FindSet then
                        repeat
                            DeliveryTripOrder.Weight +=
                              Round(P800UOMFns.ItemWeight(ReturnShipmentLine."No.", ReturnShipmentLine."Quantity (Base)", ReturnShipmentLine."Quantity (Alt.)"), 0.000000001);
                            DeliveryTripOrder.Volume +=
                              Round(P800UOMFns.ItemVolume(ReturnShipmentLine."No.", ReturnShipmentLine."Quantity (Base)", ReturnShipmentLine."Quantity (Alt.)"), 0.000000001);
                        until ReturnShipmentLine.Next = 0;
                end;

            DeliveryTripOrder."Posted Document"::"Transfer Shipment":
                begin
                    TransferShipmentLine.SetRange("Document No.", DeliveryTripOrder."Posted Document No.");
                    TransferShipmentLine.SetRange(Type, TransferShipmentLine.Type::Item);
                    TransferShipmentLine.SetFilter(Quantity, '<>0');
                    if TransferShipmentLine.FindSet then
                        repeat
                            DeliveryTripOrder.Weight +=
                              Round(P800UOMFns.ItemWeight(TransferShipmentLine."Item No.", TransferShipmentLine."Quantity (Base)", TransferShipmentLine."Quantity (Alt.)"), 0.000000001);
                            DeliveryTripOrder.Volume +=
                              Round(P800UOMFns.ItemVolume(TransferShipmentLine."Item No.", TransferShipmentLine."Quantity (Base)", TransferShipmentLine."Quantity (Alt.)"), 0.000000001);
                        until TransferShipmentLine.Next = 0;
                end;
        end;
    end;

    local procedure IsPostedShipmentsExists(WhseRqst: Record "Warehouse Request"): Boolean
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
    begin
        // P8007168
        PostedWhseShipmentLine.SetRange("Source Type", WhseRqst."Source Type");
        PostedWhseShipmentLine.SetRange("Source Subtype", WhseRqst."Source Subtype");
        PostedWhseShipmentLine.SetRange("Source No.", WhseRqst."Source No.");
        if (not PostedWhseShipmentLine.IsEmpty) then
            exit(true);

        if (WhseRqst."Source Type" = DATABASE::"Sales Line") then begin
            SalesShipmentHeader.SetRange("Order No.", WhseRqst."Source No.");
            exit(not SalesShipmentHeader.IsEmpty);
        end;
    end;

    procedure GetDeliveryTripRouteDetails(var DeliveryTrip: Record "N138 Delivery Trip")
    var
        Route: Record "Delivery Route";
        RouteSched: Record "Delivery Route Schedule";
    begin
        // P80038970
        with DeliveryTrip do begin
            "Driver No." := '';
            "Truck ID" := '';
            Clear("Departure Time");
            if Route.Get("Delivery Route No.") then begin
                GetDeliveryDriverNo("Departure Date", Route."No.", "Driver No.");
                "Truck ID" := Route."Default Truck ID";
                "Departure Time" := Route."Default Departure Time";
                if RouteSched.Get("Delivery Route No.", Date2DWY("Departure Date", 1)) then begin
                    if RouteSched.Enabled then begin
                        Validate("Driver No.", RouteSched."Default Driver No.");
                        "Truck ID" := RouteSched."Default Truck ID";
                        "Departure Time" := RouteSched."Default Departure Time";
                    end;
                end;
            end;
        end;
    end;

    procedure IsPickClassCodeEnabled(): Boolean
    var
        WarehouseSetup: Record "Warehouse Setup";
        P800Functions: Codeunit "Process 800 Functions";
    begin
        // P80038975
        if not WarehouseSetupFound then
            WarehouseSetup.Get;
        WarehouseSetupFound := true;
        exit(P800Functions.AdvWhseInstalled and WarehouseSetup."Whse. Pick Using Pick Class");
        // P80038975
    end;

    local procedure GetNextDeliveryRouteSchedule(DelRoute: Code[20]; ShptDate: Date): Date
    var
        DeliveryRouteSchedule: Record "Delivery Route Schedule";
        lShptDt1: Date;
    begin
        // P80072445
        lShptDt1 := ShptDate;
        for lShptDt1 := ShptDate to CalcDate('<6D>', ShptDate) do begin
            DeliveryRouteSchedule.Get(DelRoute, Date2DWY(lShptDt1, 1));
            if DeliveryRouteSchedule.Enabled then
                exit(lShptDt1);
        end;
    end;

    local procedure GetNextDelRtMatrixLine(pSrcType: Integer; pSorceNo: Code[20]; pSrcNo2: Code[20]; pShptDt: Date; var DeliveryRoutingMatrixLine2: Record "Delivery Routing Matrix Line"): Date
    var
        DeliveryRoutingMatrixLine: Record "Delivery Routing Matrix Line";
        lShptDt1: Date;
        j: Integer;
        DeliveryRouteSchedule: Record "Delivery Route Schedule";
    begin
        // P80072445
        lShptDt1 := CalcDate('<1D>', pShptDt);
        DeliveryRoutingMatrixLine.SetRange("Source Type", pSrcType);
        DeliveryRoutingMatrixLine.SetRange("Source No.", pSorceNo);
        DeliveryRoutingMatrixLine.SetRange("Source No. 2", pSrcNo2);
        DeliveryRoutingMatrixLine.SetFilter("Delivery Route No.", '<>%1', '');
        //IF DeliveryRoutingMatrixLine.FINDSET THEN
        for j := 1 to DeliveryRoutingMatrixLine.Count do begin
            DeliveryRoutingMatrixLine2.CopyFilters(DeliveryRoutingMatrixLine);
            DeliveryRoutingMatrixLine2.SetRange("Day Of Week", Date2DWY(lShptDt1, 1));
            if DeliveryRoutingMatrixLine2.FindFirst then begin
                if DeliveryRouteSchedule.Get(DeliveryRoutingMatrixLine2."Delivery Route No.", DeliveryRoutingMatrixLine2."Day Of Week") and
                                                DeliveryRouteSchedule.Enabled then
                    exit(lShptDt1)
            end
            else
                lShptDt1 := CalcDate('<1D>', lShptDt1);
        end;
    end;
}

