page 37002302 "Del. Trip History-Posted Docs."
{
    // PRW18.00.02
    // P8004554, To-Increase, Jack Reynolds, 27 OCT 15
    //   Add Delivery Stop, Weight, Volume, Containers
    // 
    // PRW19.00.01
    // P8007168, To-Increase, Dayakar Battini, 08 JUN 16
    //  Trip Settlement Posting Issue
    // 
    // P8007133, To-Increase, Dayakar Battini, 08 JUN 16
    //  Trip Settlement and Posted Documents visibility
    // 
    // P8006916, To-Increase, Dayakar Battini, 16 JUN 16
    //   FOOD-TOM Separation delete Transsmart objects
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Del. Trip History-Posted Docs.';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Delivery Trip Order";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posted Document"; "Posted Document")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Posted Document No."; "Posted Document No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Document"; "Source Document")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Destination Type"; "Destination Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Destination No."; "Destination No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Destination Name"; "Destination Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Delivery Trip Stop No."; "Delivery Trip Stop No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Delivery Stop No.';
                }
                field("Weight * WeightFactor"; Weight * WeightFactor)
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = StrSubstNo(Text001, WeightUOM);
                    DecimalPlaces = 0 : 5;
                    ShowCaption = false;
                }
                field("Volume * VolumeFactor"; Volume * VolumeFactor)
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = StrSubstNo(Text002, VolumeUOM);
                    DecimalPlaces = 0 : 5;
                    ShowCaption = false;
                }
                field(Containers; Containers)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        // P8004554
                        FoodDeliveryTripMgt.PostedDocumentContainerDrilldown(Rec);
                    end;
                }
                field("Posted Documents"; "Posted Documents")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        // P8007133
                        FoodDeliveryTripMgt.PostedDocumentDrilldown(Rec);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Card)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Card';
                Image = EditLines;

                trigger OnAction()
                var
                    SalesShipmentHeader: Record "Sales Shipment Header";
                    ReturnShipmentHeader: Record "Return Shipment Header";
                    TransferShipmentHeader: Record "Transfer Shipment Header";
                begin
                    case "Posted Document" of
                        "Posted Document"::Shipment:
                            begin
                                SalesShipmentHeader.Get("Posted Document No.");
                                PAGE.Run(PAGE::"Posted Sales Shipment", SalesShipmentHeader);
                            end;
                        "Posted Document"::"Return Shipment":
                            begin
                                ReturnShipmentHeader.Get("Posted Document No.");
                                PAGE.Run(PAGE::"Posted Return Shipment", ReturnShipmentHeader);
                            end;
                        "Posted Document"::"Transfer Shipment":
                            begin
                                TransferShipmentHeader.Get("Posted Document No.");
                                PAGE.Run(PAGE::"Posted Transfer Shipment", TransferShipmentHeader);
                            end;
                    end;
                end;
            }
            action(Settlement)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Settlement';
                Enabled = "Posted Document" = "Posted Document"::Shipment;
                Image = SettleOpenTransactions;

                trigger OnAction()
                var
                    SalesShipmentLine: Record "Sales Shipment Line";
                    TripSettlementMgt: Codeunit "N138 Trip Settlement Mgt.";
                begin
                    SalesShipmentLine.SetRange("Document No.", "Posted Document No.");
                    case SalesShipmentLine.Count of
                        0:
                            begin
                                Error(Text000);
                            end;
                        1:
                            SalesShipmentLine.FindFirst;
                        else
                            if PAGE.RunModal(PAGE::"Posted Sales Shipment Lines", SalesShipmentLine) <> ACTION::LookupOK then
                                exit;
                    end;
                    TripSettlementMgt.SetSettlementPosting("Delivery Trip No.");   // P8007168
                    TripSettlementMgt.Settlement2(SalesShipmentLine);
                end;
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        FillTempTable;
        exit(Find(Which));
    end;

    trigger OnInit()
    begin
        // P8004554
        FoodDeliveryTripMgt.GetWeightVolumeUOM(WeightUOM, VolumeUOM);
        WeightFactor := P800UOMFns.ConvertUOM(1, 'METRIC BASE', WeightUOM);
        VolumeFactor := P800UOMFns.ConvertUOM(1, 'METRIC BASE', VolumeUOM);
        // P8004554
    end;

    var
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        FoodDeliveryTripMgt: Codeunit "Food Delivery Trip Management";
        DeliveryRouteMgmt: Codeunit "Delivery Route Management";
        DeliveryTripNo: Code[20];
        Text000: Label 'No lines';
        WeightUOM: Code[10];
        VolumeUOM: Code[10];
        WeightFactor: Decimal;
        VolumeFactor: Decimal;
        Text001: Label 'Weight (%1)';
        Text002: Label 'Volume (%1)';

    local procedure FillTempTable()
    var
        DeliveryTripOrder: Record "Delivery Trip Order";
        DeliveryTripHistory: Query "Delivery Trip History";
        SalesShipmentHeader: Record "Sales Shipment Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        DeliveryTripOrder.Copy(Rec);

        FilterGroup(4);
        if DeliveryTripNo = GetRangeMin("Delivery Trip No.") then begin
            FilterGroup(0);
            exit;
        end;

        DeliveryTripNo := GetRangeMin("Delivery Trip No.");
        FilterGroup(0);

        Reset;
        DeleteAll;
        Rec.CopyFilters(DeliveryTripOrder);

        DeliveryTripHistory.SetRange(DeliveryTripNo, DeliveryTripNo);
        if DeliveryTripHistory.Open then
            while DeliveryTripHistory.Read do begin // P8004554
                case DeliveryTripHistory.PostedSourceDocument of
                    DeliveryTripHistory.PostedSourceDocument::"Posted Shipment":
                        begin
                            SalesShipmentHeader.Get(DeliveryTripHistory.PostedSourceNo);
                            "Source No." := SalesShipmentHeader."Order No.";
                            "Line No." += 1;
                            "Source Document" := "Source Document"::"Sales Order";
                            "Posted Document" := "Posted Document"::Shipment;
                            "Posted Document No." := SalesShipmentHeader."No.";
                            "Destination Type" := "Destination Type"::Customer;
                            "Destination No." := SalesShipmentHeader."Sell-to Customer No.";
                            "Destination Name" := SalesShipmentHeader."Sell-to Customer Name";
                            "Delivery Trip No." := DeliveryTripNo;
                            "Delivery Trip Stop No." := SalesShipmentHeader."Delivery Stop No."; // P8004554
                                                                                                 //INSERT;                                                            // P8004554
                        end;

                    DeliveryTripHistory.PostedSourceDocument::"Posted Return Shipment":
                        begin
                            ReturnShipmentHeader.Get(DeliveryTripHistory.PostedSourceNo);
                            "Source No." := ReturnShipmentHeader."Return Order No.";
                            "Line No." += 1;
                            "Source Document" := "Source Document"::"Purchase Return Order";
                            "Posted Document" := "Posted Document"::"Return Shipment";
                            "Posted Document No." := ReturnShipmentHeader."No.";
                            "Destination Type" := "Destination Type"::Vendor;
                            "Destination No." := ReturnShipmentHeader."Buy-from Vendor No.";
                            "Destination Name" := ReturnShipmentHeader."Buy-from Vendor Name";
                            "Delivery Trip No." := DeliveryTripNo;
                            "Delivery Trip Stop No." := ReturnShipmentHeader."Delivery Stop No."; // P8004554
                                                                                                  //INSERT;                                                             // P8004554
                        end;

                    DeliveryTripHistory.PostedSourceDocument::"Posted Transfer Shipment":
                        begin
                            TransferShipmentHeader.Get(DeliveryTripHistory.PostedSourceNo);
                            "Source No." := TransferShipmentHeader."Transfer Order No.";
                            "Line No." += 1;
                            "Source Document" := "Source Document"::"Transfer Order";
                            "Posted Document" := "Posted Document"::"Transfer Shipment";
                            "Posted Document No." := TransferShipmentHeader."No.";
                            "Destination Type" := "Destination Type"::Location;
                            "Destination No." := TransferShipmentHeader."Transfer-to Code";
                            "Destination Name" := TransferShipmentHeader."Transfer-to Name";
                            "Delivery Trip No." := DeliveryTripNo;
                            "Delivery Trip Stop No." := TransferShipmentHeader."Delivery Stop No."; // P8004554
                                                                                                    //INSERT;                                                               // P8004554
                        end;
                end;

                FoodDeliveryTripMgt.PostedDocumentCount(Rec);      // P8007133

                // P8004554
                FoodDeliveryTripMgt.PostedDocumentContainerCount(Rec);
                DeliveryRouteMgmt.SetPostedWeightVolume(Rec);
                Insert;
            end;
        // P8004554

        if FindFirst then;
    end;
}

