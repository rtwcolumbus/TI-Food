page 37002100 "Order Shipping"
{
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   This is a re-working of the order shipping form to expand beyond sales orders to include all outbound shipments
    // 
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 18 AUG 06
    //   Add support for Shipment Status and Pick No. and managing picks
    //   Add Staged Picks
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 15 NOV 06
    //   Change to date filter - OnAfterInput
    // 
    // PR5.00.03
    // P8000656, VerticalSoft, Jack Reynolds, 08 JAN 09
    //   Fix problem when clearing document type and destination type filters
    // 
    // PRW16.00.02
    // P8000777, VerticalSoft, Don Bresee, 24 FEB 10
    //   Removed += operator, used with an option variable, causes trouble for the form transformation tool
    // P8000777, VerticalSoft, Don Bresee, 01 APR 10
    //   Remove visible varibles from list field properties
    // 
    // PRW16.00.03
    // P8000828, VerticalSoft, Don Bresee, 21 JUN 10
    //   Move DrillDown calls to the Lookup trigger - so the page will use "Edit" mode
    // 
    // PRW16.00.05
    // P8000950, Columbus IT, Jack Reynolds, 25 MAY 11
    //   More flexibilty in specifying date filters
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001034, Columbus IT, Jack Reynolds, 10 FEB 12
    //   Change codeunit for Warehouse Employee functions
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW19.00.01
    // P8007791, To-Increase, Dayakar Battini, 19 SEP 16
    //  Block Deletion of Orders
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW117.3
    // P80096165, To Increase, Jack Reynolds, 02 MAR 21
    //   Upgrade to 17.3 - Options to Enums

    ApplicationArea = FOODBasic;
    Caption = 'Order Shipping';
    DeleteAllowed = false;
    PageType = Worksheet;
    SourceTable = "Warehouse Request";
    SourceTableView = SORTING(Type, "Location Code", "Completely Handled", "Document Status", "Expected Receipt Date", "Shipment Date", "Source Document", "Source No.")
                      WHERE(Type = CONST(Outbound),
                            "Source Document" = FILTER("Sales Order" | "Purchase Return Order" | "Outbound Transfer"),
                            "Document Status" = CONST(Released),
                            "Completely Handled" = CONST(false));
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Filters)
            {
                Caption = 'Filters';
                field("LocCode[1]"; LocCode[1])
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Code';
                    TableRelation = Location;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(P800CoreFns.LookupEmpLocation(Text)); // P8001034
                    end;

                    trigger OnValidate()
                    begin
                        P800CoreFns.ValidateEmpLocation(LocCode[1]); // P8001034
                        SetLocation;
                        CurrPage.Update(false);
                    end;
                }
                field(ShipDateFilter; ShipDateFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Shipment Date';

                    trigger OnValidate()
                    var
                        FilterTokens: Codeunit "Filter Tokens";
                    begin
                        FilterTokens.MakeDateFilter(ShipDateFilter);  // P8000950, P80066030, P800-MegaApp
                        if ShipDateFilter = '' then
                            SetRange("Shipment Date")
                        else
                            SetFilter("Shipment Date", ShipDateFilter);
                        CurrPage.Update(false);
                    end;
                }
                field(DocTypeFilter; DocTypeFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Document Type';

                    trigger OnValidate()
                    begin
                        case DocTypeFilter of
                            DocTypeFilter::" ":
                                SetRange("Source Document");
                            DocTypeFilter::"Sales Order":
                                SetRange("Source Document", "Source Document"::"Sales Order");
                            DocTypeFilter::"Purchase Return Order":
                                SetRange("Source Document", "Source Document"::"Purchase Return Order");
                            DocTypeFilter::"Outbound Transfer":
                                SetRange("Source Document", "Source Document"::"Outbound Transfer");
                        end;
                        DocTypeFilterText := GetFilter("Source Document");
                        CurrPage.Update(false);
                    end;
                }
                field(DocNoFilter; DocNoFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Document No.';

                    trigger OnValidate()
                    begin
                        if DocNoFilter = '' then
                            SetRange("Source No.")
                        else
                            SetFilter("Source No.", DocNoFilter);
                        CurrPage.Update(false);
                    end;
                }
                field(DestTypeFilter; DestTypeFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Destination Type';

                    trigger OnValidate()
                    begin
                        case DestTypeFilter of
                            DestTypeFilter::" ":
                                SetRange("Destination Type");
                            DestTypeFilter::Customer:
                                SetRange("Destination Type", "Destination Type"::Customer);
                            DestTypeFilter::Vendor:
                                SetRange("Destination Type", "Destination Type"::Vendor);
                            DestTypeFilter::Location:
                                SetRange("Destination Type", "Destination Type"::Location);
                        end;
                        DestTypeFilterText := GetFilter("Destination Type");
                        CurrPage.Update(false);
                    end;
                }
                field(DestNoFilter; DestNoFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Destination No.';

                    trigger OnValidate()
                    begin
                        if DestNoFilter = '' then
                            SetRange("Destination No.")
                        else
                            SetFilter("Destination No.", DestNoFilter);
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(Control37002000)
            {
                Editable = false;
                ShowCaption = false;
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Document"; "Source Document")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Document Type';
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Document No.';
                }
                field("Destination Type"; "Destination Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Destination No."; "Destination No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("P800WhseMgt.WhseReqDestName(Rec)"; P800WhseMgt.WhseReqDestName(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Destination Name';
                }
                field("P800WhseMgt.WhseReqSourceDate(Rec)"; P800WhseMgt.WhseReqSourceDate(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Order Date';
                }
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field(ShipmentNo; P800WhseMgt.WhseReqShipmentNo(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Shipment No.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        P800WhseMgt.WhseReqShipmentDrillDown(Rec);
                        CurrPage.Update(false);
                    end;
                }
                field(ShipmentStatus; P800WhseMgt.WhseReqShipmentStatus(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Shipment Status';
                }
                field(PickNo; P800WhseMgt.WhseReqWhsePickNo(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pick No.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        // P8000322A
                        P800WhseMgt.WhseReqPickDrillDown(Rec);
                        CurrPage.Update(false);
                        // P8000322A
                    end;
                }
                field(StagedPickNo; P800WhseMgt.WhseReqStagedPickNo(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Staged Pick No.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        // P8000322A
                        P800WhseMgt.WhseReqStagedPickDrillDown(Rec);
                        CurrPage.Update(false);
                        // P8000322A
                    end;
                }
                field("Shipment Method Code"; "Shipment Method Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("O&rder")
            {
                Caption = 'O&rder';
                action("&Card")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Card';
                    Image = Card;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
                    begin
                        P800WhseMgt.WhseReqShowSourceDoc(Rec);
                    end;
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;

                    trigger OnAction()
                    begin
                        P800WhseMgt.WhseReqShowSourceComments(Rec);
                    end;
                }
                separator(Separator1102603041)
                {
                }
                action("&Ship")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Ship';
                    Image = Shipment;
                    ShortCutKey = 'F7';

                    trigger OnAction()
                    var
                        WhseReq: Record "Warehouse Request";
                    begin
                        CurrPage.SetSelectionFilter(WhseReq);
                        WhseReq.MarkedOnly(true);
                        if not WhseReq.Find('-') then begin
                            WhseReq.MarkedOnly(false);
                            WhseReq := Rec;
                            WhseReq.SetRecFilter;
                        end;

                        P800WhseMgt.WhseShipOrder(WhseReq);
                    end;
                }
                action(Pick)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pick';
                    Image = InventoryPick;
                    ShortCutKey = 'Shift+F11';

                    trigger OnAction()
                    var
                        WhseReq: Record "Warehouse Request";
                    begin
                        // P8000322A
                        CurrPage.SetSelectionFilter(WhseReq);
                        P800WhseMgt.WhsePickOrder(WhseReq);
                        CurrPage.Update(false);
                        // P8000322A
                    end;
                }
                action("Sta&ge")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Sta&ge';
                    Image = Stages;
                    ShortCutKey = 'Ctrl+F11';

                    trigger OnAction()
                    var
                        WhseReq: Record "Warehouse Request";
                    begin
                        // P8000322A
                        CurrPage.SetSelectionFilter(WhseReq);
                        P800WhseMgt.SetSalesSampleStaging(false);
                        P800WhseMgt.WhseStagePickOrder(WhseReq);
                        CurrPage.Update(false);
                        // P8000322A
                    end;
                }
                separator(Separator1102603054)
                {
                }
                action("S&tage Sales Samples")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'S&tage Sales Samples';
                    Image = Stages;

                    trigger OnAction()
                    var
                        WhseReq: Record "Warehouse Request";
                    begin
                        // P8000322A
                        CurrPage.SetSelectionFilter(WhseReq);
                        P800WhseMgt.SetSalesSampleStaging(true);
                        P800WhseMgt.WhseStagePickOrder(WhseReq);
                        CurrPage.Update(false);
                        // P8000322A
                    end;
                }
            }
        }
        area(processing)
        {
            action("Reset Filters")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Reset Filters';
                Image = ClearFilter;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;

                trigger OnAction()
                begin
                    LocCode[1] := P800CoreFns.GetDefaultEmpLocation; // P8001034
                    LocCode[2] := '*';
                    ShipDateFilter := '';
                    DocTypeFilter := 0;
                    DocNoFilter := '';
                    DestTypeFilter := 0;
                    DestNoFilter := '';

                    DocTypeFilterText := '*';
                    DestTypeFilterText := '*';

                    SetLocation;
                    SetRange("Shipment Date");
                    SetRange("Source Document");
                    SetRange("Source No.");
                    SetRange("Destination Type");
                    SetRange("Destination No.");
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Card_Promoted; "&Card")
                {
                }
                actionref(Ship_Promoted; "&Ship")
                {
                }
                actionref(Pick_Promoted; Pick)
                {
                }
                actionref(Stage_Promoted; "Sta&ge")
                {
                }
                actionref(StageSalesSamples_Promoted; "S&tage Sales Samples")
                {
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        UpdateFilters;

        exit(Find(Which));
    end;

    trigger OnInit()
    begin
        DocTypeFilterText := '*';
        DestTypeFilterText := '*';
    end;

    trigger OnOpenPage()
    begin
        LocCode[1] := P800CoreFns.GetDefaultEmpLocation; // P8001034
        LocCode[2] := '*';

        SetLocation;
    end;

    var
        P800WhseMgt: Codeunit "Process 800 Warehouse Mgmt.";
        P800CoreFns: Codeunit "Process 800 Core Functions";
        LocCode: array[2] of Code[10];
        ShipDateFilter: Text[50];
        DocTypeFilter: Option ," ","Sales Order","Purchase Return Order","Outbound Transfer";
        Text001: Label '* MULTIPLE *';
        DocTypeFilterText: Text[250];
        DocNoFilter: Code[50];
        DestTypeFilter: Option ," ",Customer,Vendor,Location;
        DestTypeFilterText: Text[250];
        DestNoFilter: Code[50];

    procedure SetLocation()
    var
        Location: Record Location;
    begin
        if LocCode[1] <> LocCode[2] then begin
            FilterGroup(2);
            if LocCode[1] <> '' then begin
                SetRange("Location Code", LocCode[1]);
                Location.Get(LocCode[1]);
            end else
                SetFilter("Location Code", P800CoreFns.GetEmpLocationFilter); // P8001034
            FilterGroup(0);
            LocCode[2] := LocCode[1];
        end;
    end;

    procedure UpdateFilters()
    begin
        ShipDateFilter := GetFilter("Shipment Date");

        if DocTypeFilterText <> GetFilter("Source Document") then begin
            DocTypeFilterText := GetFilter("Source Document");
            if DocTypeFilterText = '' then
                DocTypeFilter := 1
            else begin
                DocTypeFilter := 2;
                while (DocTypeFilterText <> Format(DocTypeFilter)) and (DocTypeFilter < 5) do
                    // DocTypeFilter += 1;              // P8000777
                    DocTypeFilter := DocTypeFilter + 1; // P8000777
            end;
            if DocTypeFilter = 5 then
                DocTypeFilter := 0;
        end;

        DocNoFilter := GetFilter("Source No.");

        if DestTypeFilterText <> GetFilter("Destination Type") then begin
            DestTypeFilterText := GetFilter("Destination Type");
            if DestTypeFilterText = '' then
                DestTypeFilter := 1
            else begin
                DestTypeFilter := 2;
                while (DestTypeFilterText <> Format(DestTypeFilter)) and (DestTypeFilter < 5) do
                    // DestTypeFilter += 1;                // P8000777
                    DestTypeFilter := DestTypeFilter + 1; // P8000777
            end;
            if DestTypeFilter = 5 then
                DestTypeFilter := 0;
        end;

        DestNoFilter := GetFilter("Destination No.");
    end;
}

