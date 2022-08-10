table 5765 "Warehouse Request"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 29-01-2015, Initial Version
    // --------------------------------------------------------------------------------
    // TOM4269     06-10-2015  Update source document shipping fields when delivery trip changes
    // --------------------------------------------------------------------------------
    // 
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Maintain Delivery Trip Order when deleting
    // 
    // PRW18.00.01
    // P8001379, Columbus IT, Jack Reynolds, 31 MAR 15
    //   Integrate TOM delivery trips
    // 
    // PRW18.00.02
    // P8004269, To-Increase, Jack Reynolds, 07 OCT 15
    //   Update source document Delivery Route No.
    // 
    // P8004222, To-Increase, Jack Reynolds, 08 OCT 15
    //   Support for adding warehouse request to warehouse shipment
    // 
    // P8004375, To-Increase, Jack Reynolds, 14 OCT 15
    //   Move change to delivery stop back to source document
    // 
    // P8004554, To-Increase, Jack Reynolds, 27 OCT 15
    //   Delivery Stop added to Purchase Header
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // PRW19.00.01
    // P8006916, To-Increase, Dayakar Battini, 16 JUN 16
    //   FOOD-TOM Separation delete Transsmart objects
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects

    Caption = 'Warehouse Request';
    DrillDownPageID = "Source Documents";
    LookupPageID = "Source Documents";

    fields
    {
        field(1; "Source Type"; Integer)
        {
            Caption = 'Source Type';
            Editable = false;
        }
        field(2; "Source Subtype"; Option)
        {
            Caption = 'Source Subtype';
            Editable = false;
            OptionCaption = '0,1,2,3,4,5,6,7,8,9,10';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9","10";
        }
        field(3; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            Editable = false;
            TableRelation = IF ("Source Document" = CONST("Sales Order")) "Sales Header"."No." WHERE("Document Type" = CONST(Order),
                                                                                                    "No." = FIELD("Source No."))
            ELSE
            IF ("Source Document" = CONST("Sales Return Order")) "Sales Header"."No." WHERE("Document Type" = CONST("Return Order"),
                                                                                                                                                                                        "No." = FIELD("Source No."))
            ELSE
            IF ("Source Document" = CONST("Purchase Order")) "Purchase Header"."No." WHERE("Document Type" = CONST(Order),
                                                                                                                                                                                                                                                                           "No." = FIELD("Source No."))
            ELSE
            IF ("Source Document" = CONST("Purchase Return Order")) "Purchase Header"."No." WHERE("Document Type" = CONST("Return Order"),
                                                                                                                                                                                                                                                                                                                                                                     "No." = FIELD("Source No."))
            ELSE
            IF ("Source Type" = CONST(5741)) "Transfer Header"."No." WHERE("No." = FIELD("Source No."))
            ELSE
            IF ("Source Type" = FILTER(5406 | 5407)) "Production Order"."No." WHERE(Status = CONST(Released),
                                                                                                                                                                                                                                                                                                                                                                                                                                               "No." = FIELD("Source No."))
            ELSE
            IF ("Source Type" = FILTER(901)) "Assembly Header"."No." WHERE("Document Type" = CONST(Order),
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  "No." = FIELD("Source No."));
        }
        field(4; "Source Document"; Enum "Warehouse Request Source Document")
        {
            Caption = 'Source Document';
            Editable = false;
        }
        field(5; "Document Status"; Option)
        {
            Caption = 'Document Status';
            Editable = false;
            OptionCaption = 'Open,Released';
            OptionMembers = Open,Released;
        }
        field(6; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Editable = false;
            TableRelation = Location;
        }
        field(7; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            Editable = false;
            TableRelation = "Shipment Method";
        }
        field(8; "Shipping Agent Code"; Code[10])
        {
            AccessByPermission = TableData "Shipping Agent Services" = R;
            Caption = 'Shipping Agent Code';
            Editable = false;
            TableRelation = "Shipping Agent";
        }
        /*
        field(9; "Shipping Agent Service Code"; Code[10])
        {
            AccessByPermission = TableData "Shipping Agent Services" = R;
            Caption = 'Shipping Agent Service Code';
            Editable = false;
            TableRelation = "Shipping Agent Services";
        }
        */
        field(10; "Shipping Advice"; Enum "Sales Header Shipping Advice")
        {
            Caption = 'Shipping Advice';
            Editable = false;
        }
        field(11; "Destination Type"; enum "Warehouse Destination Type")
        {
            Caption = 'Destination Type';
        }
        field(12; "Destination No."; Code[20])
        {
            Caption = 'Destination No.';
            TableRelation = IF ("Destination Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Destination Type" = CONST(Customer)) Customer
            ELSE
            IF ("Destination Type" = CONST(Location)) Location
            ELSE
            IF ("Destination Type" = CONST(Item)) Item
            ELSE
            IF ("Destination Type" = CONST(Family)) Family
            ELSE
            IF ("Destination Type" = CONST("Sales Order")) "Sales Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(13; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(14; "Expected Receipt Date"; Date)
        {
            Caption = 'Expected Receipt Date';
        }
        field(15; "Shipment Date"; Date)
        {
            Caption = 'Shipment Date';
        }
        field(19; Type; Enum "Warehouse Request Type")
        {
            Caption = 'Type';
            Editable = false;
        }
        field(20; "Put-away / Pick No."; Code[20])
        {
            CalcFormula = Lookup("Warehouse Activity Line"."No." WHERE("Source Type" = FIELD("Source Type"),
                                                                        "Source Subtype" = FIELD("Source Subtype"),
                                                                        "Source No." = FIELD("Source No."),
                                                                        "Location Code" = FIELD("Location Code")));
            Caption = 'Put-away / Pick No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(41; "Completely Handled"; Boolean)
        {
            Caption = 'Completely Handled';
        }
        field(11028580; "Delivery Trip"; Code[20])
        {
            Caption = 'Delivery Trip';
            Description = 'N138F000';
            TableRelation = "N138 Delivery Trip" WHERE("Location Code" = FIELD("Location Code"));

            trigger OnValidate()
            var
                DeliveryTrip: Record "N138 Delivery Trip";
                DelTripMgt: Codeunit "N138 Delivery Trip Mgt.";
            begin
                CalcFields("Warehouse Shipment No.");
                if "Warehouse Shipment No." <> '' then
                    Error(Text000);

                // TOM4269
                if "Delivery Trip" <> '' then begin
                    DeliveryTrip.Get("Delivery Trip");
                    if ("Shipment Date" <> DeliveryTrip."Departure Date") or
                      ("Delivery Route No." <> DeliveryTrip."Delivery Route No.") or // P8004269
                      ("Shipping Agent Code" <> DeliveryTrip."Shipping Agent Code") or
                      ("Shipping Agent Service Code" <> DeliveryTrip."Shipping Agent Service Code")
                    then begin
                        "Shipment Date" := DeliveryTrip."Departure Date";
                        "Delivery Route No." := DeliveryTrip."Delivery Route No."; // P8004269
                        "Shipping Agent Code" := DeliveryTrip."Shipping Agent Code";
                        "Shipping Agent Service Code" := DeliveryTrip."Shipping Agent Service Code";
                        DelTripMgt.UpdateSourceDocument(xRec, Rec);
                    end;
                end;
                // TOM4269
            end;
        }
        field(11028581; "Shipping Agent Service Code"; Code[10])
        {
            AccessByPermission = TableData "Shipping Agent Services" = R;
            Caption = 'Shipping Agent Service Code';
            Editable = false;
            Description = 'N138F000';
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));
        }
        field(11028583; "Warehouse Shipment No."; Code[20])
        {
            CalcFormula = Lookup ("Warehouse Shipment Line"."No." WHERE("Source Type" = FIELD("Source Type"),
                                                                        "Source Subtype" = FIELD("Source Subtype"),
                                                                        "Source No." = FIELD("Source No."),
                                                                        "Location Code" = FIELD("Location Code")));
            Caption = 'Warehouse Shipment No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(37002060; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(37002061; Weight; Decimal)
        {
            Caption = 'Weight';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(37002062; Volume; Decimal)
        {
            Caption = 'Volume';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(37002063; "Delivery Stop No."; Code[20])
        {
            Caption = 'Delivery Stop No.';

            trigger OnValidate()
            var
                SalesHeader: Record "Sales Header";
                PurchHeader: Record "Purchase Header";
                TransferHeader: Record "Transfer Header";
                OrderStatus: Integer;
            begin
                // P8004375
                if "Delivery Stop No." <> xRec."Delivery Stop No." then
                    case "Source Type" of
                        DATABASE::"Sales Line":
                            begin
                                SalesHeader.Get("Source Subtype", "Source No.");
                                OrderStatus := SalesHeader.Status;
                                SalesHeader.Status := SalesHeader.Status::Open;
                                SalesHeader.Validate("Delivery Stop No.", "Delivery Stop No.");
                                SalesHeader.Status := OrderStatus;
                                SalesHeader.Modify;
                            end;
                            // P8004554
                        DATABASE::"Purchase Line":
                            begin
                                PurchHeader.Get("Source Subtype", "Source No.");
                                OrderStatus := PurchHeader.Status;
                                PurchHeader.Status := PurchHeader.Status::Open;
                                PurchHeader.Validate("Delivery Stop No.", "Delivery Stop No.");
                                PurchHeader.Status := OrderStatus;
                                PurchHeader.Modify;
                            end;
                        // P8004554
                        DATABASE::"Transfer Line":
                            begin
                                TransferHeader.Get("Source No.");
                                TransferHeader."Delivery Stop No." := "Delivery Stop No.";
                                TransferHeader.Modify;
                            end;
                    end;
            end;
        }
        field(37002064; "Delivery Route No."; Code[20])
        {
            Caption = 'Delivery Route No.';
            TableRelation = "Delivery Route" WHERE("Location Code" = FIELD("Location Code"));
        }
    }

    keys
    {
        key(Key1; Type, "Location Code", "Source Type", "Source Subtype", "Source No.")
        {
            Clustered = true;
        }
        key(Key2; "Source Type", "Source Subtype", "Source No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key3; "Source Type", "Source No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key4; "Source Document", "Source No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key5; Type, "Location Code", "Completely Handled", "Document Status", "Expected Receipt Date", "Shipment Date", "Source Document", "Source No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        ProcessFns: Codeunit "Process 800 Functions";
        Text000: Label 'Warehouse Shipment exists, update the Delivery Trip in the Warehouse Shipment';

    procedure FirstWarehouseShipment(): Code[20]
    var
        WhseShipment: Record "Warehouse Shipment Header";
        WhseShipmentLine: Record "Warehouse Shipment Line";
    begin
        // P8004222
        WhseShipment.SetRange("Delivery Trip", "Delivery Trip");
        WhseShipmentLine.SetRange("Source Type", "Source Type");
        WhseShipmentLine.SetRange("Source Subtype", "Source Subtype");
        WhseShipmentLine.SetRange("Source No.", "Source No.");

        if WhseShipment.FindSet then
            repeat
                WhseShipmentLine.SetRange("No.", WhseShipment."No.");
                if not WhseShipmentLine.IsEmpty then
                    exit(WhseShipment."No.");
            until WhseShipment.Next = 0;
    end;

    procedure DeleteRequest(SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20])
    begin
        SetSourceFilter(SourceType, SourceSubtype, SourceNo);
        if not IsEmpty() then
            DeleteAll();

        OnAfterDeleteRequest(SourceType, SourceSubtype, SourceNo);
    end;

    procedure SetDestinationType(ProdOrder: Record "Production Order")
    begin
        case ProdOrder."Source Type" of
            ProdOrder."Source Type"::Item:
                "Destination Type" := "Destination Type"::Item;
            ProdOrder."Source Type"::Family:
                "Destination Type" := "Destination Type"::Family;
            ProdOrder."Source Type"::"Sales Header":
                "Destination Type" := "Destination Type"::"Sales Order";
        end;

        OnAfterSetDestinationType(Rec, ProdOrder);
    end;

    procedure SetSourceFilter(SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20])
    begin
        SetRange("Source Type", SourceType);
        SetRange("Source Subtype", SourceSubtype);
        SetRange("Source No.", SourceNo);
    end;

    procedure ShowSourceDocumentCard()
    var
        PurchHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        TransHeader: Record "Transfer Header";
        ProdOrder: Record "Production Order";
        ServiceHeader: Record "Service Header";
    begin
        case "Source Document" of
            "Source Document"::"Purchase Order":
                begin
                    PurchHeader.Get("Source Subtype", "Source No.");
                    PAGE.Run(PAGE::"Purchase Order", PurchHeader);
                end;
            "Source Document"::"Purchase Return Order":
                begin
                    PurchHeader.Get("Source Subtype", "Source No.");
                    PAGE.Run(PAGE::"Purchase Return Order", PurchHeader);
                end;
            "Source Document"::"Sales Order":
                begin
                    SalesHeader.Get("Source Subtype", "Source No.");
                    PAGE.Run(PAGE::"Sales Order", SalesHeader);
                end;
            "Source Document"::"Sales Return Order":
                begin
                    SalesHeader.Get("Source Subtype", "Source No.");
                    PAGE.Run(PAGE::"Sales Return Order", SalesHeader);
                end;
            "Source Document"::"Inbound Transfer", "Source Document"::"Outbound Transfer":
                begin
                    TransHeader.Get("Source No.");
                    PAGE.Run(PAGE::"Transfer Order", TransHeader);
                end;
            "Source Document"::"Prod. Consumption", "Source Document"::"Prod. Output":
                begin
                    ProdOrder.Get("Source Subtype", "Source No.");
                    PAGE.Run(PAGE::"Released Production Order", ProdOrder);
                end;
            "Source Document"::"Service Order":
                begin
                    ServiceHeader.Get("Source Subtype", "Source No.");
                    PAGE.Run(PAGE::"Service Order", ServiceHeader);
                end;
            else
                OnShowSourceDocumentCardCaseElse(Rec);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeleteRequest(SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetDestinationType(var WhseRequest: Record "Warehouse Request"; ProdOrder: Record "Production Order")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShowSourceDocumentCardCaseElse(var WhseRequest: Record "Warehouse Request")
    begin
    end;
}

