page 37002301 "Delivery Trip Containers"
{
    // PRW19.00.01
    // P8006916, To-Increase, Dayakar Battini, 16 JUN 16
    //   FOOD-TOM Separation delete Transsmart objects
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    //
    // PRW115.3
    // P800119529, To Increase, Jack Reynolds, 23 FEB 21
    //   Bring Container Ship/Receive to Delivery trip page

    Caption = 'Delivery Trip Containers';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Delivery Trip Container Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                IndentationColumn = Level;
                IndentationControls = "Container License Plate";
                ShowAsTree = true;
                ShowCaption = false;
                field("Container License Plate"; "Container License Plate")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Container Type Code"; "Container Type Code")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Container Description"; "Container Description")
                {
                    ApplicationArea = FOODBasic;
                    Style = Strong;
                    StyleExpr = TRUE;
                    Visible = false;
                }
                
                // P800119529
                field(Ship;Ship)
                {
                    ApplicationArea = FOODBasic;
                    Enabled = "Line No." = 0;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field(Loaded; Loaded)
                {
                    ApplicationArea = FOODBasic;
                    Editable = LoadedEditable;
                    Enabled = "Line No." = 0;
                    Style = Strong;
                    StyleExpr = TRUE;
                    Visible = LoadedVisible;

                    trigger OnValidate()
                    begin
                        SourceType[2] := SourceType[1];
                        SourceSubtype[2] := SourceSubtype[1];
                        SourceNo[2] := SourceNo[1];
                        CurrPage.Update;
                    end;
                }
                field("Container Weight"; "Container Weight")
                {
                    ApplicationArea = FOODBasic;
                    BlankNumbers = BlankNeg;
                    CaptionClass = StrSubstNo(Text000, WeightUOM);
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
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
                    ContainerHeader: Record "Container Header";
                begin
                    ContainerHeader.Get("Container ID");
                    PAGE.Run(PAGE::Container, ContainerHeader);
                end;
            }
            // P800119529
            action(ShipSelected)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Ship Selected';
                Image = UpdateShipment;

                trigger OnAction()
                var
                    CurrRecord: Record "Delivery Trip Container Line";
                    DeliveryTripContainerLine: Record "Delivery Trip Container Line" temporary;
                begin
                    DeliveryTripContainerLine.Copy(Rec, true);
                    CurrRecord := Rec;

                    CurrPage.SetSelectionFilter(DeliveryTripContainerLine);
                    DeliveryTripContainerLine.SetRange("Line No.", 0);
                    DeliveryTripContainerLine.SetRange(Ship, DeliveryTripContainerLine.Ship::" ");
                    if DeliveryTripContainerLine.FindSet() then
                        repeat
                            Rec := DeliveryTripContainerLine;
                            Rec.Validate(Ship, Rec.Ship::Yes);
                            Rec.Modify();
                        until DeliveryTripContainerLine.Next() = 0;

                    Rec := CurrRecord;
                    FIND();
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
    var
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        VolumeUOM: Code[10];
    begin
        FoodDeliveryTripMgt.GetWeightVolumeUOM(WeightUOM, VolumeUOM);
        WeightFactor := P800UOMFns.ConvertUOM(1, 'METRIC BASE', WeightUOM);
        TOMSetup.Get;
        LoadedVisible := TOMSetup."Use Container Status Loaded";
    end;

    var
        TOMSetup: Record "N138 Transport Mgt. Setup";
        DeliveryTrip: Record "N138 Delivery Trip";
        FoodDeliveryTripMgt: Codeunit "Food Delivery Trip Management";
        DeliveryTripNo: Code[20];
        DeliveryTripStatus: Integer;
        SourceType: array[2] of Integer;
        SourceSubtype: array[2] of Integer;
        SourceNo: array[2] of Code[20];
        WeightUOM: Code[10];
        Text000: Label 'Weight (%1)';
        WeightFactor: Decimal;
        [InDataSet]
        LoadedVisible: Boolean;
        [InDataSet]
        LoadedEditable: Boolean;

    procedure SetDeliveryTrip(DeliveryTrip: Record "N138 Delivery Trip")
    begin
        DeliveryTripNo := DeliveryTrip."No.";
        DeliveryTripStatus := DeliveryTrip.Status;
        LoadedEditable := DeliveryTripStatus = DeliveryTrip.Status::Loading;
    end;

    procedure ClearSource()
    begin
        SourceType[1] := SourceType[2];
        SourceSubtype[1] := SourceSubtype[2];
        SourceNo[1] := SourceNo[2];
        SourceType[2] := 0;
        SourceSubtype[2] := 0;
        SourceNo[2] := '';
    end;

    local procedure FillTempTable()
    var
        DeliveryTripContainerLine: Record "Delivery Trip Container Line";
        DeliveryTripContainers: Query "Delivery Trip Containers";
        ContainerID: Code[20];
    begin
        DeliveryTripContainerLine.Copy(Rec);

        FilterGroup(4);
        if (SourceType[1] = GetRangeMin("Source Type")) and (SourceSubtype[1] = GetRangeMin("Source Subtype")) and (SourceNo[1] = GetRangeMin("Source No.")) then begin
            FilterGroup(0);
            exit;
        end;

        SourceType[1] := GetRangeMin("Source Type");
        SourceSubtype[1] := GetRangeMin("Source Subtype");
        SourceNo[1] := GetRangeMin("Source No.");
        FilterGroup(0);

        Reset;
        DeleteAll;
        Rec.CopyFilters(DeliveryTripContainerLine);

        DeliveryTripContainers.SetRange(DeliveryTripNo, DeliveryTripNo);
        DeliveryTripContainers.SetRange(DocumentType, SourceType[1]);
        DeliveryTripContainers.SetRange(DocumentSubtype, SourceSubtype[1]);
        DeliveryTripContainers.SetRange(DocumentNo, SourceNo[1]);
        if DeliveryTripContainers.Open then begin
            "Source Type" := SourceType[1];
            "Source Subtype" := SourceSubtype[1];
            "Source No." := SourceNo[1];
            while DeliveryTripContainers.Read do begin
                if ContainerID <> DeliveryTripContainers.ID then begin
                    ContainerID := DeliveryTripContainers.ID;
                    Init;
                    "Container ID" := DeliveryTripContainers.ID;
                    "Container License Plate" := DeliveryTripContainers.LicensePlate;
                    "Container Type Code" := DeliveryTripContainers.ContainerTypeCode;
                    "Container Description" := DeliveryTripContainers.ContainerDescription;
                    if DeliveryTripContainers.Loaded then
                        Loaded := Loaded::Yes;
                    // P900119529
                    IF DeliveryTripContainers.Ship THEN
                        Ship := Ship::Yes;
                    // P900119529
                    "Container Weight" := WeightFactor * (DeliveryTripContainers.ContainerNetWeightBase + DeliveryTripContainers.ContainerTareWeightBase + DeliveryTripContainers.ContaineLineTareWeightBase);
                    "Line No." := 0;
                    Insert;
                end;
                if DeliveryTripContainers.LineNo <> 0 then begin
                    Init;
                    "Container Weight" := -1;
                    "Line No." := DeliveryTripContainers.LineNo;
                    "Item No." := DeliveryTripContainers.ItemNo;
                    "Item Description" := DeliveryTripContainers.ItemDescription;
                    "Variant Code" := DeliveryTripContainers.VariantCode;
                    "Lot No." := DeliveryTripContainers.LotNo;
                    "Unit of Measure Code" := DeliveryTripContainers.UOMCode;
                    Quantity := DeliveryTripContainers.Quantity;
                    Level := 1;
                    Insert;
                end;
            end;
        end;

        if FindFirst then;
    end;
}

