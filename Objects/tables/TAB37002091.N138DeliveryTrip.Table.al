table 37002091 "N138 Delivery Trip"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 02-02-2015, Initial Version
    // --------------------------------------------------------------------------------
    // TOM4220     05-10-2015  Auto creation of warehouse shipment with delivery trip
    // --------------------------------------------------------------------------------
    // TOM4269     06-10-2015  Update source document shipping fields
    // --------------------------------------------------------------------------------
    // TOM4372     08-10-2015  OnDelete - remove link to warehouse request
    // --------------------------------------------------------------------------------
    // TOM4222     08-10-2015  Support for adding warehouse request to warehouse shipment
    // --------------------------------------------------------------------------------
    // 
    // PRW18.00.01
    // P8001379, Columbus IT, Jack Reynolds, 31 MAR 15
    //   FOOD fields
    // 
    // PRW18.00.02
    // P8004269, To-Increase, Jack Reynolds, 07 OCT 15
    //   Update source document Delivery Route No.
    // 
    // P8004373, To-Increase, Jack Reynolds, 14 OCT 15
    //   Remove source document from trip
    // 
    // PRW19.00.01
    // P8006916, To-Increase, Dayakar Battini, 16 JUN 16
    //   FOOD-TOM Separation delete Transsmart objects
    // 
    // PRW110.0.01
    // P80037380, To-Increase, Dayakar Battini, 31 MAY 17
    //   Updating whse. shipment dates with departure date
    // 
    // P80042706, To-Increase, Dayakar Battini, 07 JUL 17
    //  Fix issue with Delivery Route behaviour
    // 
    // PRW110.0.02
    // P80050451, To-Increase, Dayakar Battini, 19 DEC 17
    //  Fix issue with Add shipment functionality.
    // 
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // P80038970, To-Increase, Dayakar Battini, 13 DEC 17
    //     Delivery Trip changes
    // 
    // P80038979, To-Increase, Dayakar Battini, 18 DEC 17
    //   Adding Pickup load management functionality
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80058404, To-Increase, Dayakar Battini, 05 MAY 18
    //   Fixing issue when removing delivery trip causes loosing delivery trip no.
    // 
    // P80060942, To Increase, Jack Reynolds, 25 JUN 18
    //   Fix problem removing order from delivery trip - rollback P80058484
    //
    // PRW111.00.03
    //   P80094579, To-Increase, Gangabhushan, 25 FEB 20
    //     CS00095752 - Loading Dock - Field Size mismatch
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW115.3
    // P800125182, To-Increase, Jack Reynolds, 22 JUN 21
    //   Qty. to Handle is cleared when adding source document to shipment

    Caption = 'Delivery Trip';
    DrillDownPageID = "N138 Delivery Trip List";
    LookupPageID = "N138 Delivery Trip List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    Setup.Get;
                    NoSeriesMgt.TestManual(Setup."Delivery Trip Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Departure Date"; Date)
        {
            Caption = 'Departure Date';

            trigger OnValidate()
            begin
                Validate("Delivery Route No.");  // P80038970
            end;
        }
        field(4; "Departure Time"; Time)
        {
            Caption = 'Departure Time';
        }
        field(5; Status; Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = 'Open,Release to Deliver,Loading,Shipped';
            OptionMembers = Open,"Release to Deliver",Loading,Shipped;
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate()
            var
                WhseShptLine: Record "Warehouse Shipment Line";
            begin
            end;
        }
        field(10; "Driver No."; Code[20])
        {
            Caption = 'Driver No.';
            TableRelation = "Delivery Driver";

            trigger OnValidate()
            var
                DeliveryRouteManagement: Codeunit "Delivery Route Management";
            begin
                "Driver Name" := DeliveryRouteManagement.GetDeliveryDriverName("Driver No.");  // P80038970
            end;
        }
        field(11; "Driver Name"; Text[100])
        {
            Caption = 'Driver Name';
            Editable = false;
        }
        field(12; "Truck ID"; Code[20])
        {
            Caption = 'Truck ID';
            TableRelation = "Delivery Truck";
        }
        field(14; "Loading Dock"; Code[20])
        {
            Caption = 'Loading Dock';
            TableRelation = "N138 Loading Dock" WHERE("Location Code" = FIELD("Location Code"));
        }
        field(60; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";

            trigger OnValidate()
            var
                ShippingAgent: Record "Shipping Agent";
                PickupLoad: Record "Pickup Load Header";
            begin
                CalcFields("Pickup Loading No.");
                if "Pickup Loading No." <> '' then
                    if ("Shipping Agent Code" <> xRec."Shipping Agent Code") then begin
                        if ShippingAgent.Get("Shipping Agent Code") then begin
                            if PickupLoad.Get("Pickup Loading No.") then begin
                                PickupLoad."Truck Type" := PickupLoad."Truck Type"::"Common Carrier";
                                PickupLoad.Carrier := "Shipping Agent Code";
                                PickupLoad.Modify;
                            end;
                        end else begin
                            if PickupLoad.Get("Pickup Loading No.") then begin
                                PickupLoad."Truck Type" := PickupLoad."Truck Type"::Company;
                                PickupLoad.Carrier := "Delivery Route No.";
                                PickupLoad.Modify;
                            end;
                        end;
                    end;
            end;
        }
        field(61; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));

            trigger OnValidate()
            var
                lRecShipAgentService: Record "Shipping Agent Services";
            begin
            end;
        }
        field(97; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(98; "Source Doucments"; Integer)
        {
            CalcFormula = Count ("Warehouse Request" WHERE("Delivery Trip" = FIELD("No.")));
            Caption = 'Source Documents';
            Editable = false;
            FieldClass = FlowField;
        }
        field(99; "Unlinked Source Documents"; Integer)
        {
            CalcFormula = Count ("Warehouse Request" WHERE("Location Code" = FIELD("Location Code"),
                                                           "Delivery Trip" = FILTER(''),
                                                           Type = CONST(Outbound),
                                                           "Put-away / Pick No." = FILTER('')));
            Caption = 'Unlinked Source Documents';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11068780; "Status Code"; Code[20])
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Part of Document Lifecycle not migrated from C/AL to AL';
            ObsoleteTag = 'FOOD-16';
        }
        field(37002060; "Delivery Route No."; Code[20])
        {
            Caption = 'Delivery Route No.';
            TableRelation = "Delivery Route" WHERE("Location Code" = FIELD("Location Code"));

            trigger OnValidate()
            var
                DeliveryRouteManagement: Codeunit "Delivery Route Management";
            begin
                // P80038970
                DeliveryRouteManagement.GetDeliveryTripRouteDetails(Rec);
                Validate("Driver No.");
                // P80038970
            end;
        }
        field(37002061; Quantity; Decimal)
        {
            CalcFormula = Sum ("Warehouse Request".Quantity WHERE("Delivery Trip" = FIELD("No.")));
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002062; Weight; Decimal)
        {
            CalcFormula = Sum ("Warehouse Request".Weight WHERE("Delivery Trip" = FIELD("No.")));
            Caption = 'Weight';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002063; Volume; Decimal)
        {
            CalcFormula = Sum ("Warehouse Request".Volume WHERE("Delivery Trip" = FIELD("No.")));
            Caption = 'Volume';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002064; "Pickup Loading No."; Code[20])
        {
            CalcFormula = Lookup ("Pickup Load Header"."No." WHERE("Delivery Trip No." = FIELD("No.")));
            Caption = 'Pickup Loading No.';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        WhseShipmentHeader: Record "Warehouse Shipment Header";
        WarehouseRequest: Record "Warehouse Request";
    begin
        WhseShipmentHeader.SetRange("Delivery Trip", "No.");
        WhseShipmentHeader.ModifyAll("Delivery Trip", '');

        WarehouseRequest.SetRange("Delivery Trip", "No."); // TOM4372
        WarehouseRequest.ModifyAll("Delivery Trip", '');   // TOM4372
    end;

    trigger OnInsert()
    begin
        if "No." = '' then begin
            Setup.Get;
            Setup.TestField("Delivery Trip Nos.");
            NoSeriesMgt.InitSeries(Setup."Delivery Trip Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        end;
    end;

    trigger OnModify()
    var
        WarehouseRequest: Record "Warehouse Request";
        xWarehouseRequest: Record "Warehouse Request";
        DelTripMgt: Codeunit "N138 Delivery Trip Mgt.";
    begin
        // TOM4269
        if ("Departure Date" <> xRec."Departure Date") or
          ("Delivery Route No." <> xRec."Delivery Route No.") or // P8004269
          ("Shipping Agent Code" <> xRec."Shipping Agent Code") or
          ("Shipping Agent Service Code" <> xRec."Shipping Agent Service Code")
        then begin
            WarehouseRequest.SetRange("Delivery Trip", "No.");
            if WarehouseRequest.FindSet(true) then
                repeat
                    xWarehouseRequest := WarehouseRequest;
                    WarehouseRequest."Shipment Date" := "Departure Date";
                    WarehouseRequest."Delivery Route No." := "Delivery Route No."; // P8004269
                    WarehouseRequest."Shipping Agent Code" := "Shipping Agent Code";
                    WarehouseRequest."Shipping Agent Service Code" := "Shipping Agent Service Code";
                    WarehouseRequest.Modify;
                    DelTripMgt.UpdateSourceDocument(xWarehouseRequest, WarehouseRequest);
                    DelTripMgt.UpdateWhseShipment(Rec);  // P80037380
                until WarehouseRequest.Next = 0;
        end;
        // TOM4269
    end;

    var
        Setup: Record "N138 Transport Mgt. Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Text37002000: Label '%1 %2 is on Warehouse Shipment %3.';

    procedure CreateWarehouseShipment()
    var
        WhseShipmentHdr: Record "Warehouse Shipment Header";
    begin
        // TOM4220
        WhseShipmentHdr.SetRange("Delivery Trip", "No.");
        ;
        if not WhseShipmentHdr.IsEmpty then
            exit;

        WhseShipmentHdr.Insert(true);
        WhseShipmentHdr.Validate("Location Code", "Location Code");
        WhseShipmentHdr.Validate("Posting Date", "Departure Date");
        WhseShipmentHdr.Validate("Shipment Date", "Departure Date");
        WhseShipmentHdr."Delivery Trip" := "No.";
        WhseShipmentHdr.Modify(true);
    end;

    procedure AddSourceDocToWarehouseShipment(var WhseRqst: Record "Warehouse Request"; AlwaysAdd: Boolean)
    var
        TMSetup: Record "N138 Transport Mgt. Setup";
        WhseShptHeader: Record "Warehouse Shipment Header";
        GetSourceDocuments: Report "Get Source Documents";
    begin
        // TOM4220
        // TOM4222 - add parameter AlwaysAdd
        if not AlwaysAdd then begin // TOM4222
            TMSetup.Get;
            if not TMSetup."Auto Create Del. Trip Shipment" then
                exit;                   // TOM4222
        end;

        //WhseRqst.SETRECFILTER; // TOM4222
        WhseShptHeader.SetRange("Delivery Trip", "No.");
        if WhseShptHeader.FindFirst then begin
            GetSourceDocuments.SetOneCreatedShptHeader(WhseShptHeader);
            GetSourceDocuments.SetHideDialog(true);
            GetSourceDocuments.SetSkipBlocked(true);
            GetSourceDocuments.SetDoNotFillQtytoHandle(true); // P800125182
            GetSourceDocuments.UseRequestPage(false);
            GetSourceDocuments.SetTableView(WhseRqst);
            GetSourceDocuments.RunModal;

            WhseShptHeader.FindFirst;       // P80050451
            WhseShptHeader."Document Status" := WhseShptHeader.GetDocumentStatus(0);
            WhseShptHeader.Modify;
        end;
    end;

    procedure RemoveSourceDocFromTrip(var WhseRqst: Record "Warehouse Request")
    var
        WhseShptHeader: Record "Warehouse Shipment Header";
        WhseShipmentLine: Record "Warehouse Shipment Line";
    begin
        // P8004373
        WhseShptHeader.SetRange("Delivery Trip", "No.");
        if WhseRqst.FindSet(true) then
            repeat
                WhseShipmentLine.SetRange("Source Type", WhseRqst."Source Type");
                WhseShipmentLine.SetRange("Source Subtype", WhseRqst."Source Subtype");
                WhseShipmentLine.SetRange("Source No.", WhseRqst."Source No.");
                if WhseShptHeader.FindSet then
                    repeat
                        WhseShipmentLine.SetRange("No.", WhseShptHeader."No.");
                        if not WhseShipmentLine.IsEmpty then
                            Error(Text37002000, WhseRqst."Source Document", WhseRqst."Source No.", WhseShptHeader."No.");
                    until WhseShptHeader.Next = 0;
                WhseRqst."Delivery Trip" := '';
                WhseRqst."Delivery Route No." := '';   // P80042706
                WhseRqst."Delivery Stop No." := '';    // P80042706
                WhseRqst.Modify;
            until WhseRqst.Next = 0;
    end;

    procedure OpenTransportCost()
    var
        TransportCost: Record "N138 Transport Cost";
        TransportCosts: Page "N138 Transport Costs";
    begin
        TransportCost.SetRange("Source Type", DATABASE::"N138 Delivery Trip");
        TransportCost.SetRange("No.", "No.");
        TransportCosts.SetTableView(TransportCost);
        TransportCosts.RunModal;
    end;
}

