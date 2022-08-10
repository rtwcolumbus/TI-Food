page 37002760 "Production Picking"
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 08 AUG 06
    //   Master form for managing warehouse picking activities associated with production orders
    // 
    // P8000394A, VerticalSoft, Jack Reynolds, 02 OCT 06
    //   Run batch reporting for current order
    // 
    // PR5.00
    // P8000494A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Production Bins/Replenishment
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
    // PRW110.0.02
    // P80051732, To-Increase, Dayakar Battini, 12 JAN 18
    //   Fixing Stage pick creation errors
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Production Picking';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "Prod. Order Line";
    SourceTableView = SORTING(Status, "Item No.", "Variant Code", "Location Code", "Starting Date")
                      WHERE(Status = CONST(Released));
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
                        LocCode1OnAfterValidate;
                    end;
                }
                field(ReplAreaFilter; ReplAreaFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Replenishment Area';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ReplArea: Record "Replenishment Area";
                    begin
                        // P8000494A
                        if (LocCode[1] <> '') then
                            ReplArea.SetRange("Location Code", LocCode[1]);
                        if (ReplAreaFilter <> '') then begin
                            ReplArea.SetFilter(Code, ReplAreaFilter);
                            if ReplArea.FindFirst then;
                            ReplArea.SetRange(Code);
                        end;
                        if (PAGE.RunModal(0, ReplArea) <> ACTION::LookupOK) then
                            exit(false);
                        Text := ReplArea.Code;
                        exit(true);
                    end;

                    trigger OnValidate()
                    begin
                        ReplAreaFilterOnAfterValidate;
                    end;
                }
                field(StartingDateFilter; StartingDateFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Starting Date';

                    trigger OnValidate()
                    begin
                        StartingDateFilterOnAfterValid;
                    end;
                }
                field(ProdShiftFilter; ProdShiftFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Production Shift';

                    trigger OnValidate()
                    begin
                        ProdShiftFilterOnAfterValidate;
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
                field("Replenishment Area Code"; "Replenishment Area Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Work Shift Code"; "Work Shift Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Prod. Order No."; "Prod. Order No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Finished Quantity"; "Finished Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field(CompletelyPicked; GetCompletelyPicked(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Completely Picked';
                    Visible = CompletelyPickedVisible;
                }
                field(n; ProdWhsePickNo(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pick No.';
                    Editable = false;
                    Visible = PickNoVisible;

                    trigger OnDrillDown()
                    begin
                        ProdWhsePickDrillDown(Rec);
                        CurrPage.Update(false);
                    end;
                }
                field(StagedPickNo; ProdStagedPickNo(Rec))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Staged Pick No.';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        ProdStagedPickDrillDown(Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
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
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
                    begin
                        ShowProdOrder(Rec);
                    end;
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Prod. Order Comment Sheet";
                    RunPageLink = Status = FIELD(Status),
                                  "Prod. Order No." = FIELD("Prod. Order No.");
                }
                group("Order &Line")
                {
                    Caption = 'Order &Line';
                    action(Components)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Components';
                        Image = Components;
                        RunObject = Page "Prod. Order Components";
                        RunPageLink = Status = FIELD(Status),
                                      "Prod. Order No." = FIELD("Prod. Order No."),
                                      "Prod. Order Line No." = FIELD("Line No.");
                        RunPageView = SORTING(Status, "Prod. Order No.", "Prod. Order Line No.", "Line No.");
                    }
                    action("Item Ledger E&ntries")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Item Ledger E&ntries';
                        Image = ItemLedger;
                        RunObject = Page "Item Ledger Entries";
                        RunPageLink = "Order No." = FIELD("Prod. Order No."),
                                      "Order Line No." = FIELD("Line No.");
                        RunPageView = SORTING("Order Type", "Order No.", "Order Line No.", "Entry Type", "Prod. Order Comp. Line No.");
                        ShortCutKey = 'Ctrl+F7';
                    }
                }
                separator(Separator1102603028)
                {
                }
                action("&Batch Reporting")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Batch Reporting';
                    Image = Journals;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'F7';

                    trigger OnAction()
                    var
                        ProdOrder: Record "Production Order";
                        BatchRptngForm: Page "Batch Reporting";
                    begin
                        // P8000394A
                        ProdOrder.Get(ProdOrder.Status::Released, "Prod. Order No.");
                        if ProdOrder.Suborder then
                            BatchRptngForm.SetOrder(ProdOrder."Batch Prod. Order No.")
                        else
                            BatchRptngForm.SetOrder("Prod. Order No.");
                        BatchRptngForm.RunModal;
                    end;
                }
                action("Finish Order")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Finish Order';
                    Image = Stop;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    var
                        ProdOrder: Record "Production Order";
                        ProdOrderStatusMgmt: Codeunit "Prod. Order Status Management";
                    begin
                        if ProdOrder.Get(Status, "Prod. Order No.") then begin
                            ProdOrderStatusMgmt.Run(ProdOrder);
                            CurrPage.Update(false);
                        end;
                    end;
                }
                separator(Separator1102603021)
                {
                }
                action(Pick)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pick';
                    Image = InventoryPick;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Shift+F11';

                    trigger OnAction()
                    var
                        ProdOrderLine: Record "Prod. Order Line";
                    begin
                        CurrPage.SetSelectionFilter(ProdOrderLine);
                        ProdWhsePickOrder(ProdOrderLine);
                        CurrPage.Update(false);
                    end;
                }
                action("Sta&ge")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Sta&ge';
                    Image = Stages;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Ctrl+F11';

                    trigger OnAction()
                    var
                        ProdOrderLine: Record "Prod. Order Line";
                    begin
                        CurrPage.SetSelectionFilter(ProdOrderLine);
                        ProdStagePickOrder(ProdOrderLine);
                        CurrPage.Update(false);
                    end;
                }
                separator(Separator1102603054)
                {
                }
                action("Replenishment Report")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Replenishment Report';
                    Image = "Report";

                    trigger OnAction()
                    var
                        ProdReplenishRpt: Report "Prod. Replenishment/Move List";
                    begin
                        // P8000494A
                        ProdReplenishRpt.SetProdOrder(Rec);
                        ProdReplenishRpt.Run;
                        CurrPage.Update(false);
                    end;
                }
            }
        }
        area(processing)
        {
            action(InputBinButton)
            {
                ApplicationArea = FOODBasic;
                Caption = 'I&nput Bin';
                Ellipsis = true;
                Image = Bins;
                Promoted = true;
                PromotedCategory = Process;
                Visible = InputBinButtonVisible;

                trigger OnAction()
                var
                    BinMaintenanceForm: Page "Bin Status";
                begin
                    BinMaintenanceForm.SetInitialLocation(LocCode[1]);
                    BinMaintenanceForm.SetMode(3); // Production Input
                    BinMaintenanceForm.SetProdOrderLine(Rec); // P8000494A
                    BinMaintenanceForm.Run;
                end;
            }
            action(OutputBinButton)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Output Bin';
                Ellipsis = true;
                Image = Bin;
                Promoted = true;
                PromotedCategory = Process;
                Visible = OutputBinButtonVisible;

                trigger OnAction()
                var
                    BinMaintenanceForm: Page "Bin Status";
                begin
                    BinMaintenanceForm.SetInitialLocation(LocCode[1]);
                    BinMaintenanceForm.SetMode(4); // Production Output
                    BinMaintenanceForm.SetProdOrderLine(Rec); // P8000494A
                    BinMaintenanceForm.Run;
                end;
            }
            action("Reset Filters")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Reset Filters';
                Image = ClearFilter;
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;

                trigger OnAction()
                begin
                    LocCode[1] := P800CoreFns.GetDefaultEmpLocation; // P8001034
                    LocCode[2] := '*';
                    StartingDateFilter := '';
                    ReplAreaFilter := '';  // P8000494A
                    ProdShiftFilter := ''; // P8000494A

                    SetLocation;
                    SetRange("Starting Date");
                    SetRange("Replenishment Area Code"); // P8000494A
                    SetRange("Work Shift Code");    // P8000494A
                    CurrPage.Update(false);
                end;
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
        OutputBinButtonVisible := true;
        InputBinButtonVisible := true;
        CompletelyPickedVisible := true;
        PickNoVisible := true;
    end;

    trigger OnOpenPage()
    begin
        LocCode[1] := P800CoreFns.GetDefaultEmpLocation; // P8001034
        LocCode[2] := '*';

        SetLocation;
    end;

    var
        P800CoreFns: Codeunit "Process 800 Core Functions";
        LocCode: array[2] of Code[10];
        StartingDateFilter: Text[50];
        Location: Record Location;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        P800WhseActCreate: Codeunit "Process 800 Create Whse. Act.";
        Text000: Label 'Nothing to Pick.';
        Text001: Label 'Nothing to Stage.';
        ReplAreaFilter: Code[80];
        ProdShiftFilter: Code[80];
        [InDataSet]
        PickNoVisible: Boolean;
        [InDataSet]
        CompletelyPickedVisible: Boolean;
        [InDataSet]
        InputBinButtonVisible: Boolean;
        [InDataSet]
        OutputBinButtonVisible: Boolean;

    local procedure SetLocation()
    var
        Location: Record Location;
    begin
        if LocCode[1] <> LocCode[2] then begin
            FilterGroup(2);
            if LocCode[1] <> '' then begin
                SetRange("Location Code", LocCode[1]);
                Location.Get(LocCode[1]);
                PickNoVisible := Location."Require Pick";
                CompletelyPickedVisible := Location."Require Pick";
                // CurrForm.PutAwayNo.VISIBLE(
                //   Location."Require Put-away" AND (NOT Location."Require Receive"));
                // CurrForm.CompletelyPutAway.VISIBLE(
                //   Location."Require Put-away" AND (NOT Location."Require Receive"));
                InputBinButtonVisible := Location."Require Put-away";
                OutputBinButtonVisible := Location."Require Put-away";
            end else begin
                SetFilter("Location Code", P800CoreFns.GetEmpLocationFilter); // P8001034
                PickNoVisible := false;
                CompletelyPickedVisible := false;
                // CurrForm.PutAwayNo.VISIBLE(FALSE);
                // CurrForm.CompletelyPutAway.VISIBLE(FALSE);
                InputBinButtonVisible := false;
                OutputBinButtonVisible := false;
            end;
            FilterGroup(0);
            LocCode[2] := LocCode[1];
            if Find('-') then;
        end;
    end;

    local procedure UpdateFilters()
    begin
        StartingDateFilter := GetFilter("Starting Date");
        ReplAreaFilter := GetFilter("Replenishment Area Code"); // P8000494A
        ProdShiftFilter := GetFilter("Work Shift Code");   // P8000494A
    end;

    local procedure ShowProdOrder(ProdOrderLine: Record "Prod. Order Line")
    var
        ProdOrder: Record "Production Order";
    begin
        if ProdOrder.Get(ProdOrderLine.Status, ProdOrderLine."Prod. Order No.") then
            PAGE.RunModal(PAGE::"Released Production Order", ProdOrder);
    end;

    local procedure ShowComponents()
    var
        ProdOrderComp: Record "Prod. Order Component";
    begin
        ProdOrderComp.SetRange(Status, Status);
        ProdOrderComp.SetRange("Prod. Order No.", "Prod. Order No.");
        ProdOrderComp.SetRange("Prod. Order Line No.", "Line No.");
        PAGE.Run(PAGE::"Prod. Order Components", ProdOrderComp);
    end;

    local procedure ShowItemEntries()
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.SetCurrentKey("Order Type", "Order No.");  // P8001132
        ItemLedgEntry.SetRange("Order No.", "Prod. Order No."); // P8001132
        PAGE.Run(0, ItemLedgEntry);
    end;

    local procedure GetFirstProdWhsePickLine(ProdOrderLine: Record "Prod. Order Line"; var WhseActivityLine: Record "Warehouse Activity Line"): Boolean
    var
        Location: Record Location;
    begin
        GetLocationRequirements(ProdOrderLine."Location Code", Location);
        if not (Location."Require Pick" and Location."Require Shipment") then
            exit(false);
        with WhseActivityLine do begin
            SetCurrentKey("Source Type", "Source Subtype", "Source No.");
            SetRange("Source Type", DATABASE::"Prod. Order Component");
            SetRange("Source Subtype", 3);
            SetRange("Source No.", ProdOrderLine."Prod. Order No.");
            SetRange("Source Line No.", ProdOrderLine."Line No.");
            SetRange("Activity Type", "Activity Type"::Pick);
            exit(Find('-'));
        end;
    end;

    local procedure ProdWhsePickNo(ProdOrderLine: Record "Prod. Order Line"): Code[20]
    var
        WhseActivityLine: Record "Warehouse Activity Line";
    begin
        if GetFirstProdWhsePickLine(ProdOrderLine, WhseActivityLine) then
            exit(WhseActivityLine."No.");
    end;

    local procedure ProdWhsePickDrillDown(ProdOrderLine: Record "Prod. Order Line")
    var
        Location: Record Location;
        ProdOrderLine2: Record "Prod. Order Line";
    begin
        with ProdOrderLine do begin
            GetLocationRequirements("Location Code", Location);
            if Location."Require Pick" and Location."Require Shipment" then begin
                ProdOrderLine.SetRecFilter;
                if not ProdWhsePickCreate(ProdOrderLine, false) then
                    Error(Text000);
            end;
        end;
    end;

    local procedure ProdWhsePickOrder(var ProdOrderLine: Record "Prod. Order Line")
    var
        Location: Record Location;
        WhseSetup: Record "Warehouse Setup";
    begin
        with ProdOrderLine do
            if Find('-') then begin
                GetLocationRequirements("Location Code", Location);
                if Location."Require Pick" and Location."Require Shipment" then
                    if not ProdWhsePickCreate(ProdOrderLine, true) then
                        Error(Text000);
            end;
    end;

    local procedure ProdWhsePickCreate(var ProdOrderLine: Record "Prod. Order Line"; AlwaysCreatePick: Boolean): Boolean
    var
        PickNo: Code[20];
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseActivityHdr: Record "Warehouse Activity Header";
        WhsePick: Page "Warehouse Pick";
    begin
        if not ProdOrderLine.Find('-') then
            exit(false);
        if not AlwaysCreatePick then
            if GetFirstProdWhsePickLine(ProdOrderLine, WhseActivityLine) then
                PickNo := WhseActivityLine."No.";
        if (PickNo <> '') then
            WhseActivityHdr.Get(WhseActivityLine."Activity Type"::Pick, PickNo)
        else begin
            if not P800WhseActCreate.CreateWhsePickForProdOrders(ProdOrderLine, WhseActivityHdr) then
                exit(false);
            Commit;
        end;

        WhseActivityHdr.Reset;
        WhseActivityHdr.FilterGroup(9);
        WhseActivityHdr.SetRecFilter;
        WhseActivityHdr.FilterGroup(0);
        WhsePick.RunFromOrderShipping(true);
        WhsePick.SetTableView(WhseActivityHdr);
        if IsServiceTier then // P80000828
            WhsePick.Run        // P80000828
        else                  // P80000828
            WhsePick.RunModal;
        exit(true);
    end;

    local procedure GetCompletelyPicked(var ProdOrderLine: Record "Prod. Order Line"): Boolean
    var
        ProdOrderComp: Record "Prod. Order Component";
    begin
        with ProdOrderComp do begin
            SetRange(Status, ProdOrderLine.Status);
            SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
            SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
            SetRange("Completely Picked", false);
            exit(not Find('-'));
        end;
    end;

    local procedure GetFirstProdStagedPickLine(ProdOrderLine: Record "Prod. Order Line"; var WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line"): Boolean
    var
        Location: Record Location;
    begin
        GetLocationRequirements(ProdOrderLine."Location Code", Location);
        if not (Location."Require Pick" and Location."Require Shipment") then
            exit(false);
        with WhseStagedPickSourceLine do begin
            SetCurrentKey("Source Type", "Source Subtype", "Source No.");
            SetRange("Source Type", DATABASE::"Prod. Order Component");
            SetRange("Source Subtype", ProdOrderLine.Status);
            SetRange("Source No.", ProdOrderLine."Prod. Order No.");
            SetRange("Source Line No.", ProdOrderLine."Line No.");
            exit(Find('-'));
        end;
    end;

    local procedure ProdStagedPickNo(ProdOrderLine: Record "Prod. Order Line"): Code[20]
    var
        WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line";
    begin
        if GetFirstProdStagedPickLine(ProdOrderLine, WhseStagedPickSourceLine) then
            exit(WhseStagedPickSourceLine."No.");
    end;

    local procedure ProdStagedPickDrillDown(ProdOrderLine: Record "Prod. Order Line")
    var
        WhseSetup: Record "Warehouse Setup";
        Location: Record Location;
    begin
        with ProdOrderLine do begin
            GetLocationRequirements("Location Code", Location);
            if Location."Require Pick" and Location."Require Shipment" then begin
                SetRecFilter;
                if not ProdStagedPickCreate(ProdOrderLine, false) then
                    Error(Text001);
            end;
        end;
    end;

    local procedure ProdStagePickOrder(var ProdOrderLine: Record "Prod. Order Line")
    var
        Location: Record Location;
        WhseSetup: Record "Warehouse Setup";
    begin
        with ProdOrderLine do
            if Find('-') then begin
                GetLocationRequirements("Location Code", Location);
                if Location."Require Pick" and Location."Require Shipment" then
                    if not ProdStagedPickCreate(ProdOrderLine, true) then
                        Error(Text001);
            end;
    end;

    local procedure ProdStagedPickCreate(var ProdOrderLine: Record "Prod. Order Line"; AlwaysCreatePick: Boolean): Boolean
    var
        PickNo: Code[20];
        WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line";
        WhseStagedPickHeader: Record "Whse. Staged Pick Header";
        WhseStagedPick: Page "Whse. Staged Pick";
    begin
        if not ProdOrderLine.Find('-') then
            exit(false);
        if not AlwaysCreatePick then
            if GetFirstProdStagedPickLine(ProdOrderLine, WhseStagedPickSourceLine) then
                PickNo := WhseStagedPickSourceLine."No.";
        if (PickNo <> '') then
            WhseStagedPickHeader.Get(PickNo)
        else begin
            Clear(P800WhseActCreate);
            repeat
                P800WhseActCreate.AddStagedPickProdOrderLine(ProdOrderLine);
            until (ProdOrderLine.Next = 0);
            if not P800WhseActCreate.CreateStagedPick(WhseStagedPickHeader) then
                exit(false);
            Commit;
        end;

        WhseStagedPickHeader.Reset;
        WhseStagedPickHeader.FilterGroup(9);
        WhseStagedPickHeader.SetRecFilter;
        WhseStagedPickHeader.FilterGroup(0);
        WhseStagedPick.SetTableView(WhseStagedPickHeader);
        WhseStagedPick.SetRecord(WhseStagedPickHeader);  // P80051732
        if IsServiceTier then // P80000828
            WhseStagedPick.Run  // P80000828
        else                  // P80000828
            WhseStagedPick.RunModal;
        exit(true);
    end;

    local procedure GetLocationRequirements(LocationCode: Code[10]; var Location: Record Location): Boolean
    var
        WhseSetup: Record "Warehouse Setup";
    begin
        if not Location.Get(LocationCode) then begin
            WhseSetup.Get;
            Location."Require Pick" := WhseSetup."Require Pick";
            Location."Require Shipment" := WhseSetup."Require Shipment";
        end;
    end;

    local procedure LocCode1OnAfterValidate()
    begin
        SetLocation;
        CurrPage.Update(false);
    end;

    local procedure StartingDateFilterOnAfterValid()
    var
        FilterTokens: Codeunit "Filter Tokens";
    begin
        FilterTokens.MakeDateFilter(StartingDateFilter); // P8000950, P80066030, P800-MegaApp
        if StartingDateFilter = '' then
            SetRange("Starting Date")
        else
            SetFilter("Starting Date", StartingDateFilter);
        CurrPage.Update(false);
    end;

    local procedure ProdShiftFilterOnAfterValidate()
    begin
        // P8000494A
        if (ProdShiftFilter = '') then
            SetRange("Work Shift Code")
        else
            SetFilter("Work Shift Code", ProdShiftFilter);
        CurrPage.Update(false);
    end;

    local procedure ReplAreaFilterOnAfterValidate()
    begin
        // P8000494A
        if (ReplAreaFilter = '') then
            SetRange("Replenishment Area Code")
        else
            SetFilter("Replenishment Area Code", ReplAreaFilter);
        CurrPage.Update(false);
    end;
}
