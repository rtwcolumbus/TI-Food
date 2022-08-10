page 37002651 "N138 Delivery Trip Factbox"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // 
    // PRW18.00.01
    // P8001379, Columbus IT, Jack Reynolds, 31 MAR 15
    //   Add FOOD fields
    // 
    // PRW18.00.02
    // P8004374, To-Increase, Jack Reynolds, 08 OCT 15
    //   Hide source documents in fact box, drill down on source documents
    // 
    // PRW19.00.01
    // P8006916, To-Increase, Dayakar Battini, 16 JUN 16
    //   FOOD-TOM Separation delete Transsmart objects
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 16 JAN 17
    //   Correct misspellings
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // P80038705, To-Increase, Dayakar Battini, 21 MAR 18
    //   Planned qty,Qty to ship added

    Caption = 'Delivery Trip';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "N138 Delivery Trip";

    layout
    {
        area(content)
        {
            field("No."; "No.")
            {
                ApplicationArea = FOODBasic;
            }
            field(TotalSourceDocs; TotalSourceDocs)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Source Docs.';
                Visible = NOT HideSource;

                trigger OnDrillDown()
                var
                    WarehouseRequest: Record "Warehouse Request";
                begin
                    // P8004374
                    WarehouseRequest.SetRange("Delivery Trip", "No.");
                    PAGE.Run(PAGE::"Source Documents", WarehouseRequest);
                end;
            }
            field(IncompleteSourceDocs; IncompleteSourceDocs)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Source Docs. (Incomplete)';
                Style = Unfavorable;
                StyleExpr = IncompleteSourceDocs > 0;
                Visible = NOT HideSource;
            }
            field("Unlinked Source Documents"; "Unlinked Source Documents")
            {
                ApplicationArea = FOODBasic;
                DrillDownPageID = "N138 Warehouse Request";
            }
            field(PlannedQuantity; Quantity)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Planned Quantity';
                DrillDown = false;
            }
            field("Weight * WeightFactor"; Weight * WeightFactor)
            {
                ApplicationArea = FOODBasic;
                CaptionClass = StrSubstNo(Text000, WeightUOM);
                DecimalPlaces = 0 : 5;
                DrillDown = false;
                Enabled = false;
                ShowCaption = false;
                Visible = false;
            }
            field("Volume * VolumeFactor"; Volume * VolumeFactor)
            {
                ApplicationArea = FOODBasic;
                CaptionClass = StrSubstNo(Text001, VolumeUOM);
                DecimalPlaces = 0 : 5;
                DrillDown = false;
                Enabled = false;
                ShowCaption = false;
                Visible = false;
            }
            field(QtyToShip; QtyToShip)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Quantity to Ship';
                DecimalPlaces = 0 : 5;
            }
            field(TotalContainers; TotalContainers)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Containers';
            }
            field(UnloadedContainers; UnloadedContainers)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Containers (Unloaded)';
                Style = Unfavorable;
                StyleExpr = UnloadedContainers > 0;
                Visible = UnloadedVisible;
            }
            field("WhseShptHdr.COUNT"; WhseShptHdr.Count)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Warehouse Shipments';
                DrillDown = true;

                trigger OnDrillDown()
                var
                    ShipmentList: Page "N138 Shipment List";
                begin
                    ShipmentList.SetTableView(WhseShptHdr);
                    ShipmentList.RunModal;
                end;
            }
            field("PostedWhseShptHdr.COUNT"; PostedWhseShptHdr.Count)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Posted Warehouse Shipments';
                DrillDown = true;

                trigger OnDrillDown()
                var
                    PostedWhseShipmentList: Page "Posted Whse. Shipment List";
                begin
                    PostedWhseShipmentList.SetTableView(PostedWhseShptHdr);
                    PostedWhseShipmentList.RunModal;
                end;
            }
            field("DeliveryTripMgt.CalculateLinkedShipmentWeight(Rec)"; DeliveryTripMgt.CalculateLinkedShipmentWeight(Rec))
            {
                ApplicationArea = FOODBasic;
                Caption = 'Linked Shipment Weight';
                Visible = false;
            }
            field("WhseShpLine.COUNT"; WhseShpLine.Count)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Shorts';

                trigger OnDrillDown()
                var
                    WhseShipmentLines: Page "Whse. Shipment Lines";
                begin
                    WhseShipmentLines.SetTableView(WhseShpLine);
                    WhseShipmentLines.RunModal;
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        CalcFields(Weight, Volume); // P8001379
        GetDetails(Quantity, QtyToShip);  // P80038705
    end;

    trigger OnAfterGetRecord()
    begin
        WhseShptHdr.SetRange("Delivery Trip", "No.");

        PostedWhseShptHdr.SetRange("Delivery Trip", "No.");

        WhseShpLine.SetRange("Delivery Trip", "No.");
        WhseShpLine.SetRange(Short, true);

        FoodDeliveryTripMgt.DeliveryTripSourceDocumentCount("No.", 0, 0, '', TotalSourceDocs, IncompleteSourceDocs); // P8001379
        FoodDeliveryTripMgt.DeliveryTripContainerCount("No.", 0, 0, '', TotalContainers, UnloadedContainers);        // P8001379
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
        WarningTxt: Text;
        WhseShptHdr: Record "Warehouse Shipment Header";
        Text000: Label 'Weight (%1)';
        Text001: Label 'Volume (%1)';
        DeliveryRouteMgt: Codeunit "Delivery Route Management";
        WhseShpLine: Record "Warehouse Shipment Line";
        PostedWhseShptHdr: Record "Posted Whse. Shipment Header";
        DeliveryTripMgt: Codeunit "N138 Delivery Trip Mgt.";
        TOMSetup: Record "N138 Transport Mgt. Setup";
        FoodDeliveryTripMgt: Codeunit "Food Delivery Trip Management";
        WeightUOM: Code[10];
        VolumeUOM: Code[10];
        WeightFactor: Decimal;
        VolumeFactor: Decimal;
        TotalSourceDocs: Integer;
        IncompleteSourceDocs: Integer;
        TotalContainers: Integer;
        UnloadedContainers: Integer;
        [InDataSet]
        UnloadedVisible: Boolean;
        [InDataSet]
        HideSource: Boolean;
        QtyToShip: Decimal;

    procedure HideSourceDocuments()
    begin
        // P8004374
        HideSource := true;
    end;

    local procedure GetDetails(var PlannedQty: Decimal; var QtyToShip: Decimal)
    var
        WhseShpLine: Record "Warehouse Shipment Line";
    begin
        WhseShpLine.SetRange("Delivery Trip", "No.");
        WhseShpLine.CalcSums(Quantity, "Qty. to Ship");
        if PlannedQty = 0 then
            PlannedQty := WhseShpLine.Quantity;
        QtyToShip := WhseShpLine."Qty. to Ship";
    end;
}

