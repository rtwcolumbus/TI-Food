page 37002300 "Delivery Trip Source Documents"
{
    // PRW18.00.02
    // P8004222, To-Increase, Jack Reynolds, 08 OCT 15
    //   Support for adding warehouse request to warehouse shipment
    // 
    // P8004373, To-Increase, Jack Reynolds, 14 OCT 15
    //   Remove source document from trip
    // 
    // PRW19.00.01
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

    Caption = 'Delivery Trip Source Documents';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Warehouse Request";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Source Document"; "Source Document")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document Status"; "Document Status")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Destination Type"; "Destination Type")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Destination No."; "Destination No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(FirstWarehouseShipment; FirstWarehouseShipment)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Warehouse Shipment No.';
                }
                field("Delivery Stop No."; "Delivery Stop No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin 
                        CurrPage.SaveRecord();
                    end;
                }
                field("Weight * WeightFactor"; Weight * WeightFactor)
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = StrSubstNo(Text000, WeightUOM);
                    DecimalPlaces = 0 : 5;
                }
                field("Volume * VolumeFactor"; Volume * VolumeFactor)
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = StrSubstNo(Text001, VolumeUOM);
                    DecimalPlaces = 0 : 5;
                }
                field(Complete; Complete)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Complete';
                    Editable = false;
                }
                field(Containers; Containers)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Containers';
                    Editable = false;
                }
                field(UnloadedContainers; UnloadedContainers)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Containers (Unloaded)';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = TRUE;
                    Visible = UnloadedVisible;
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
                    SalesHeader: Record "Sales Header";
                    PurchaseHeader: Record "Purchase Header";
                    TransferHeader: Record "Transfer Header";
                begin
                    case "Source Document" of
                        "Source Document"::"Sales Order":
                            begin
                                SalesHeader.Get("Source Subtype", "Source No.");
                                PAGE.Run(PAGE::"Sales Order", SalesHeader);
                            end;
                        "Source Document"::"Purchase Return Order":
                            begin
                                PurchaseHeader.Get("Source Subtype", "Source No.");
                                PAGE.Run(PAGE::"Purchase Return Order", PurchaseHeader);
                            end;
                        "Source Document"::"Outbound Transfer":
                            begin
                                TransferHeader.Get("Source No.");
                                PAGE.Run(PAGE::"Transfer Order", TransferHeader);
                            end;
                    end;
                end;
            }
            action(RemoveFromTrip)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Remove From Trip';
                Image = RemoveLine;

                trigger OnAction()
                var
                    WarehouseRequest: Record "Warehouse Request";
                    DeliveryTrip: Record "N138 Delivery Trip";
                begin
                    // P8004373
                    CurrPage.SetSelectionFilter(WarehouseRequest);
                    DeliveryTrip.Get("Delivery Trip");
                    DeliveryTrip.RemoveSourceDocFromTrip(WarehouseRequest);
                end;
            }
            action(AddToShipment)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Add to Shipment';
                Image = PostedShipment;

                trigger OnAction()
                var
                    WarehouseRequest: Record "Warehouse Request";
                    DeliveryTrip: Record "N138 Delivery Trip";
                begin
                    // P8004222
                    CurrPage.SetSelectionFilter(WarehouseRequest);
                    DeliveryTrip.Get("Delivery Trip");
                    DeliveryTrip.AddSourceDocToWarehouseShipment(WarehouseRequest, true);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        TotalCnt: Integer;
        IncompleteCnt: Integer;
    begin
        // P8001379
        FoodDeliveryTripMgt.DeliveryTripSourceDocumentCount("Delivery Trip", "Source Type", "Source Subtype", "Source No.", TotalCnt, IncompleteCnt);
        Complete := IncompleteCnt = 0;
        FoodDeliveryTripMgt.DeliveryTripContainerCount("Delivery Trip", "Source Type", "Source Subtype", "Source No.", Containers, UnloadedContainers);
        // P8001379
        CurrPage.Update(false); // P800110597
    end;

    trigger OnInit()
    var
        P800UOMFns: Codeunit "Process 800 UOM Functions";
    begin
        // P8001379
        FoodDeliveryTripMgt.GetWeightVolumeUOM(WeightUOM, VolumeUOM);
        WeightFactor := P800UOMFns.ConvertUOM(1, 'METRIC BASE', WeightUOM);
        VolumeFactor := P800UOMFns.ConvertUOM(1, 'METRIC BASE', VolumeUOM);
        TOMSetup.Get;
        UnloadedVisible := TOMSetup."Use Container Status Loaded";
        // P8001379
    end;

    var
        TOMSetup: Record "N138 Transport Mgt. Setup";
        FoodDeliveryTripMgt: Codeunit "Food Delivery Trip Management";
        WeightUOM: Code[10];
        VolumeUOM: Code[10];
        Text000: Label 'Weight (%1)';
        Text001: Label 'Volume (%1)';
        WeightFactor: Decimal;
        VolumeFactor: Decimal;
        [InDataSet]
        Complete: Boolean;
        [InDataSet]
        Containers: Integer;
        [InDataSet]
        UnloadedContainers: Integer;
        [InDataSet]
        UnloadedVisible: Boolean;
}

