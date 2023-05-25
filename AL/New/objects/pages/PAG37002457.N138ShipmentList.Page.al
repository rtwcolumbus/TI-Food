page 37002457 "N138 Shipment List"
{
    // PRW19.00.01
    // P8006916, To-Increase, Dayakar Battini, 16 JUN 16
    //   FOOD-TOM Separation delete Transsmart objects
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects

    Caption = 'Warehouse Shipments';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Warehouse Shipment Header";
    SourceTableView = WHERE("Delivery Trip" = FILTER(<> '""'));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document Status"; "Document Status")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
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
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = EditLines;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
                    begin
                        PAGE.Run(PAGE::"Warehouse Shipment", Rec);
                    end;
                }
                action("Use Filters to Get Src. Docs.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Use Filters to Get Src. Docs.';
                    Image = UseFilters;

                    trigger OnAction()
                    var
                        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
                    begin
                        TestField(Status, Status::Open);
                        GetSourceDocOutbound.GetOutboundDocs(Rec);
                    end;
                }
                action("Create Pick")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Create Pick';
                    Ellipsis = true;
                    Image = CreateInventoryPickup;

                    trigger OnAction()
                    begin
                        PickCreate;
                    end;
                }
                action("Pick Lines")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pick Lines';
                    Image = PickLines;

                    trigger OnAction()
                    begin
                        DeliveryTripMgt.OpenLinkedPicks2(Rec);
                    end;
                }
            }
        }
        area(Promoted)
        {
            actionref(UseFiltersToGetSrcDocs_Promoted; "Use Filters to Get Src. Docs.")
            {
            }
            actionref(PickLines_Promoted; "Pick Lines")
            {
            }
            actionref(CreatePick_Promoted; "Create Pick")
            {
            }
        }
    }

    var
        DeliveryTripMgt: Codeunit "N138 Delivery Trip Mgt.";

    procedure PickCreate()
    var
        WhseShptLine: Record "Warehouse Shipment Line";
        ReleaseWhseShipment: Codeunit "Whse.-Shipment Release";
    begin
        WhseShptLine.SetRange("No.", Rec."No.");
        if Rec.Status = Rec.Status::Open then
            ReleaseWhseShipment.Release(Rec);
        WhseShptLine.CreatePickDoc(WhseShptLine, Rec);
    end;
}

