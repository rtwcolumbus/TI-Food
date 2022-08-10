codeunit 37002760 "Undo Whse. Activity"
{
    // P8000322A, Don Bresee, 29 JUL 06
    //   Add Undo for Registered Whse. Activity Line
    // 
    // PRW15.00.01
    // P8000527A, VerticalSoft, Jack Reynolds, 01 OCT 07
    //   Set permission property for Registered Whse. Activity Line (INSERT) and Whse. Item Tracking Line (ALL)
    // 
    // PRW16.00.04
    // P8000897, VerticalSoft, Jack Reynolds, 22 JAN 11
    //   Fix spelling mistake
    // 
    // PRW110.0.01
    // P8008715, To-Increase, Dayakar Battini, 03 MAY 17
    //   Fix issue with orphaned reservation entry
    // 
    // PRW111.00.01
    // P80058322, To-Increase, Jack Reynolds, 03 MAY 18
    //   Fix issue with removing content form container
    // 
    // P80060233, To-Increase, Jack Reynolds, 07 JUN 18
    //   Fix problem updating quanity on warehouse item tracking lines
    // 
    // PRW111.00.02
    // P80067728, To-Increase, Gangabhushan, 29 NOV 18
    //   TI-12386 In Pick lines,  Qty. to Handle (alt.) is not over ride on Qty. to Ship (alt.) in WH. Shipment.
    //          & Qty. to Ship (alt.) is not updating as undo pick lines.
    // 
    // P80070693, To-Increase, Gangabhushan, 22 MAR 19
    //   TI-12871 - TO-Warehouse Shipment Error when undo the Registered Picks
    // 
    // P80079981, To Increase, Gangabhushan, 23 AUG 19
    //   Qty to Handle data not get refreshed in Pick lines for Multiple UOM functionality.
    //
    // PRW111.00.03
    //   P80093335, To-Increase, Gangabhushan, 25 FEB 2020
    //     CS00093963 - Transfer Order / Undo Pick issue
    // 
    // PRW11300.03
    // P80082969, To Increase, Jack Reynolds, 26 SEP 19
    //   New Events

    Permissions = TableData "Registered Whse. Activity Line" = i,
                  TableData "Whse. Item Tracking Line" = rimd;
    TableNo = "Registered Whse. Activity Line";

    trigger OnRun()
    var
        TempLineToUndo: Record "Registered Whse. Activity Line" temporary;
        NumTakeLines: Integer;
        NumPlaceLines: Integer;
        RelatedLine: Record "Registered Whse. Activity Line";
        TempNetTotals: Record "Registered Whse. Activity Line" temporary;
        TempTotals: Record "Registered Whse. Activity Line" temporary;
        UnPostedQty: Decimal;
        RemovedFromContainer: Boolean;
        MsgText: Text[250];
        FoodManualSubscriptions: Codeunit "Food Manual Subscriptions";
    begin
        SetRange("Undo-to Line No.", 0);
        if not Find('-') then
            Error(Text000);
        SetBreakbulkFilter(Rec);
        Find('-');
        repeat
            CalcFields("Qty. Undone (Base)");
            "Qty. (Base)" := "Qty. (Base)" + "Qty. Undone (Base)";
            if ("Qty. (Base)" <> 0) then begin
                TempLineToUndo := Rec;
                TempLineToUndo.Insert;
            end;
        until (Next = 0);

        CountTakeAndPlaceLines(TempLineToUndo, NumTakeLines, NumPlaceLines);
        if (NumTakeLines = 0) and (NumPlaceLines = 0) then
            Error(Text000);

        with TempLineToUndo do begin
            if ("Breakbulk No." = 0) then begin
                if (NumTakeLines = 0) or (NumPlaceLines = 0) then begin
                    Reset;
                    Find('-');
                    repeat
                        if (NumTakeLines = 0) then
                            MarkRelatedLines(TempLineToUndo, "Action Type"::Take, RelatedLine)
                        else
                            MarkRelatedLines(TempLineToUndo, "Action Type"::Place, RelatedLine);
                    until (Next = 0);
                    AddRelatedLines(TempLineToUndo, RelatedLine);
                end;

                BuildTypeTotals(TempLineToUndo, "Action Type"::Place, TempTotals);
                if TempTotals.Find('-') then
                    repeat
                        Reset;
                        SetLineFilter(TempLineToUndo, TempTotals);
                        SetRange("Action Type", "Action Type"::Place);
                        UnPostedQty := GetUnPostedQty(TempTotals);
                        if (UnPostedQty = 0) then
                            DeleteAll
                        else
                            if (UnPostedQty < TempTotals."Qty. (Base)") then begin
                                Find('-');
                                if (Next <> 0) then
                                    Error(Text002);
                                "Qty. (Base)" := UnPostedQty;
                                Modify;
                            end;
                    until (TempTotals.Next = 0);

                Reset;
                SetRange("Action Type", "Action Type"::Place);
                if not Find('-') then
                    Error(Text001);
                SetRange("Action Type");
            end;

            BuildTypeTotals(TempLineToUndo, "Action Type"::Take, TempNetTotals);
            BuildTypeTotals(TempLineToUndo, "Action Type"::Place, TempNetTotals);
            if TempNetTotals.Find('-') then
                repeat
                    Reset;
                    SetLineFilter(TempLineToUndo, TempNetTotals);
                    if (TempNetTotals."Qty. (Base)" > 0) then begin
                        SetRange("Action Type", "Action Type"::Take);
                        if not Find('-') then
                            Error(Text002);
                        SetRange("Action Type", "Action Type"::Place);
                        Find('-');
                        if (Next <> 0) then
                            Error(Text002);
                        "Qty. (Base)" := "Qty. (Base)" - TempNetTotals."Qty. (Base)";
                    end else begin
                        SetRange("Action Type", "Action Type"::Place);
                        if not Find('-') then
                            Error(Text002);
                        SetRange("Action Type", "Action Type"::Take);
                        Find('-');
                        if (Next <> 0) then
                            Error(Text002);
                        "Qty. (Base)" := "Qty. (Base)" + TempNetTotals."Qty. (Base)";
                    end;
                    Modify;
                until (TempNetTotals.Next = 0);

            SourceCodeSetup.Get;

            CountTakeAndPlaceLines(TempLineToUndo, NumTakeLines, NumPlaceLines);
            Reset;
            Find('-');
            if ("Breakbulk No." = 0) then
                MsgText := Text003
            else
                MsgText := Text004;
            if not Confirm(MsgText, false, NumTakeLines + NumPlaceLines, NumTakeLines, NumPlaceLines) then
                exit;

            repeat
                if ("Qty. per Unit of Measure" = 0) then
                    Quantity := "Qty. (Base)"
                else
                    Quantity := Round("Qty. (Base)" / "Qty. per Unit of Measure", 0.00001);
                Modify;
            until (Next = 0);

            Clear(WhseJnlRegisterLine);
            OnUndoWhseActivityOnBeforeProcessLine(TempLineToUndo); // P80082969
            if FindSet then begin // P80082969
                                  // P80070693
                FoodManualSubscriptions.SetUndoPick();
                BindSubscription(FoodManualSubscriptions);
                // P80070693
                repeat
                    RemovedFromContainer := RemoveFromContainer(TempLineToUndo); // P8001323, P80058322
                    PostWhseJnlLine(TempLineToUndo);
                    InsertRegActLine(TempLineToUndo);
                    if ("Breakbulk No." = 0) then begin
                        UpdateActLine(TempLineToUndo);
                        if "Action Type" = "Action Type"::Place then
                            UpdateSourceDocument(TempLineToUndo, RemovedFromContainer); // P80058322
                    end;
                    DeleteAltQtyLine(TempLineToUndo);  // P80067728
                until (Next = 0);
                UnbindSubscription(FoodManualSubscriptions); // P80070693
            end; // P80082969
            OnAfterUndoWhseActivity; // P80082969
            Message(Text005);
        end;
    end;

    var
        WhseJnlLine: Record "Warehouse Journal Line";
        WhseJnlRegisterLine: Codeunit "Whse. Jnl.-Register Line";
        SourceCodeSetup: Record "Source Code Setup";
        Text000: Label 'Nothing to undo. All selected lines have already been undone.';
        Text001: Label 'Unable to undo. All selected lines have been posted.';
        Text002: Label 'Unable to determine the quantities to undo.';
        Text003: Label 'Are you sure you want to undo the selected lines?\\%1 lines (%2 take and %3 place) will be reversed.';
        Text004: Label 'Are you sure you want to undo the selected lines?\\This will undo a Breakbulk transaction.\\%1 lines (%2 take and %3 place) will be reversed.';
        Text005: Label 'The selected lines have been undone.';
        Text006: Label 'You cannot undo breakbulk lines along with other lines. Breakbulk lines must be undone separately.';
        Text007: Label 'You cannot undo multiple breakbulk transactions at once.';
        PostContainerLine: Record "Container Line";

    local procedure SetBreakbulkFilter(var LineToUndo: Record "Registered Whse. Activity Line")
    begin
        with LineToUndo do begin
            if ("Breakbulk No." = 0) then
                SetFilter("Breakbulk No.", '<>0')
            else
                SetRange("Breakbulk No.", 0);
            if Find('-') then
                Error(Text006);
            if ("Breakbulk No." = 0) then
                SetRange("Breakbulk No.", 0)
            else begin
                SetFilter("Breakbulk No.", '<>%1', "Breakbulk No.");
                if Find('-') then
                    Error(Text007);
                Reset;
                SetRange("Activity Type", "Activity Type");
                SetRange("No.", "No.");
                SetRange("Undo-to Line No.", 0);
                SetRange("Breakbulk No.", "Breakbulk No.");
            end;
        end;
    end;

    local procedure CountTakeAndPlaceLines(var TempLineToUndo: Record "Registered Whse. Activity Line" temporary; var NumTakeLines: Integer; var NumPlaceLines: Integer)
    begin
        NumTakeLines := 0;
        NumPlaceLines := 0;
        with TempLineToUndo do begin
            Reset;
            if Find('-') then
                repeat
                    case "Action Type" of
                        "Action Type"::Take:
                            NumTakeLines := NumTakeLines + 1;
                        "Action Type"::Place:
                            NumPlaceLines := NumPlaceLines + 1;
                    end;
                until (Next = 0);
        end;
    end;

    local procedure MarkRelatedLines(var TempLineToUndo: Record "Registered Whse. Activity Line" temporary; ActionType: Integer; var RelatedLine: Record "Registered Whse. Activity Line")
    var
        RegWhseActLine: Record "Registered Whse. Activity Line";
    begin
        with RegWhseActLine do begin
            SetRange("Activity Type", TempLineToUndo."Activity Type");
            SetRange("No.", TempLineToUndo."No.");
            SetRange("Action Type", ActionType);
            SetLineFilter(RegWhseActLine, TempLineToUndo);
            SetRange("Undo-to Line No.", 0);
            SetRange("Breakbulk No.", 0);
            if Find('-') then
                repeat
                    RelatedLine := RegWhseActLine;
                    RelatedLine.Mark(true);
                until (Next = 0);
        end;
    end;

    local procedure AddRelatedLines(var TempLineToUndo: Record "Registered Whse. Activity Line" temporary; var RelatedLine: Record "Registered Whse. Activity Line")
    begin
        with RelatedLine do begin
            MarkedOnly(true);
            if Find('-') then
                repeat
                    CalcFields("Qty. Undone (Base)");
                    "Qty. (Base)" := "Qty. (Base)" + "Qty. Undone (Base)";
                    if ("Qty. (Base)" <> 0) then begin
                        TempLineToUndo := RelatedLine;
                        TempLineToUndo.Insert;
                    end;
                until (Next = 0);
        end;
    end;

    local procedure BuildTypeTotals(var TempLineToUndo: Record "Registered Whse. Activity Line" temporary; ActionType: Integer; var TempTotal: Record "Registered Whse. Activity Line" temporary)
    begin
        with TempLineToUndo do begin
            Reset;
            SetRange("Action Type", ActionType);
            SetRange("Undo-to Line No.", 0);
            if not Find('-') then
                exit;
        end;

        with TempTotal do begin
            repeat
                SetLineFilter(TempTotal, TempLineToUndo);
                if not Find('-') then begin
                    TempTotal := TempLineToUndo;
                    "Action Type" := "Action Type"::Place;
                    "Qty. (Base)" := 0;
                    Insert;
                end;
                case TempLineToUndo."Action Type" of
                    "Action Type"::Take:
                        "Qty. (Base)" := "Qty. (Base)" - TempLineToUndo."Qty. (Base)";
                    "Action Type"::Place:
                        "Qty. (Base)" := "Qty. (Base)" + TempLineToUndo."Qty. (Base)";
                end;
                if ("Qty. (Base)" = 0) then
                    Delete
                else
                    Modify;
            until (TempLineToUndo.Next = 0);
            Reset;
        end;
    end;

    local procedure SetLineFilter(var RegWhseActLine: Record "Registered Whse. Activity Line"; var FromRegWhseActLine: Record "Registered Whse. Activity Line")
    begin
        with RegWhseActLine do begin
            SetRange("Whse. Document Type", FromRegWhseActLine."Whse. Document Type");
            SetRange("Whse. Document No.", FromRegWhseActLine."Whse. Document No.");
            SetRange("Whse. Document Line No.", FromRegWhseActLine."Whse. Document Line No.");
            SetRange("Item No.", FromRegWhseActLine."Item No.");
            SetRange("Variant Code", FromRegWhseActLine."Variant Code");
            SetRange("Lot No.", FromRegWhseActLine."Lot No.");
            SetRange("Serial No.", FromRegWhseActLine."Serial No.");
        end;
    end;

    local procedure GetUnPostedQty(var TempTotals: Record "Registered Whse. Activity Line" temporary): Decimal
    var
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        with TempTotals do begin
            case "Whse. Document Type" of
                "Whse. Document Type"::Shipment:
                    if WhseShptLine.Get("Whse. Document No.", "Whse. Document Line No.") then begin
                        if ("Lot No." <> '') or ("Serial No." <> '') then
                            exit(-GetReservQty(TempTotals));
                        exit(WhseShptLine."Qty. Picked (Base)" - WhseShptLine."Qty. Shipped (Base)");
                    end;
            end;
        end;
        exit(0);
    end;

    local procedure GetReservQty(var TempTotals: Record "Registered Whse. Activity Line" temporary) ReservQty: Decimal
    var
        ReservEntry: Record "Reservation Entry";
    begin
        ReservQty := 0;
        with ReservEntry do begin
            SetCurrentKey(
              "Source Type", "Source ID", "Source Batch Name", "Source Ref. No.", "Lot No.", "Serial No.");
            SetRange("Source Type", TempTotals."Source Type");
            SetRange("Source Subtype", TempTotals."Source Subtype");
            SetRange("Source ID", TempTotals."Source No.");
            SetRange("Source Ref. No.", TempTotals."Source Line No.");
            SetRange("Lot No.", TempTotals."Lot No.");
            SetRange("Serial No.", TempTotals."Serial No.");
            if Find('-') then
                repeat
                    ReservQty := ReservQty + "Quantity (Base)";
                until (Next = 0);
        end;
    end;

    local procedure PostWhseJnlLine(var TempLineToUndo: Record "Registered Whse. Activity Line" temporary)
    begin
        with TempLineToUndo do begin
            WhseJnlLine.Init;
            WhseJnlLine."Location Code" := "Location Code";
            WhseJnlLine."Item No." := "Item No.";
            WhseJnlLine."Registering Date" := WorkDate;
            WhseJnlLine."User ID" := UserId;
            WhseJnlLine."Variant Code" := "Variant Code";
            WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::Movement;
            if ("Action Type" = "Action Type"::Place) then begin
                WhseJnlLine."From Zone Code" := "Zone Code";
                WhseJnlLine."From Bin Code" := "Bin Code";
            end else begin
                WhseJnlLine."To Zone Code" := "Zone Code";
                WhseJnlLine."To Bin Code" := "Bin Code";
            end;
            WhseJnlLine.Description := Description;

            WhseJnlLine.Quantity := Quantity;
            WhseJnlLine."Qty. (Base)" := "Qty. (Base)";
            WhseJnlLine."Unit of Measure Code" := "Unit of Measure Code";
            WhseJnlLine."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
            WhseJnlLine."Qty. (Absolute)" := WhseJnlLine.Quantity;
            WhseJnlLine."Qty. (Absolute, Base)" := WhseJnlLine."Qty. (Base)";
            SetWeightAndCubage(
              WhseJnlLine."Item No.", WhseJnlLine."Unit of Measure Code",
              WhseJnlLine.Quantity, WhseJnlLine.Weight, WhseJnlLine.Cubage);

            WhseJnlLine."Source Type" := "Source Type";
            WhseJnlLine."Source Subtype" := "Source Subtype";
            WhseJnlLine."Source No." := "Source No.";
            WhseJnlLine."Source Line No." := "Source Line No.";
            WhseJnlLine."Source Subline No." := "Source Subline No.";
            WhseJnlLine."Source Document" := "Source Document";
            WhseJnlLine."Reference No." := "No.";

            case "Activity Type" of
                "Activity Type"::"Put-away":
                    begin
                        WhseJnlLine."Source Code" := SourceCodeSetup."Whse. Put-away";
                        WhseJnlLine."Whse. Document Type" := "Whse. Document Type";
                        WhseJnlLine."Whse. Document No." := "Whse. Document No.";
                        WhseJnlLine."Whse. Document Line No." := "Whse. Document Line No.";
                        WhseJnlLine."Reference Document" := WhseJnlLine."Reference Document"::"Put-away";
                    end;
                "Activity Type"::Pick:
                    begin
                        WhseJnlLine."Source Code" := SourceCodeSetup."Whse. Pick";
                        WhseJnlLine."Whse. Document Type" := "Whse. Document Type";
                        WhseJnlLine."Whse. Document No." := "Whse. Document No.";
                        WhseJnlLine."Whse. Document Line No." := "Whse. Document Line No.";
                        WhseJnlLine."Reference Document" := WhseJnlLine."Reference Document"::Pick;
                    end;
                "Activity Type"::Movement:
                    begin
                        WhseJnlLine."Source Code" := SourceCodeSetup."Whse. Movement";
                        WhseJnlLine."Whse. Document Type" :=
                          WhseJnlLine."Whse. Document Type"::" ";
                        WhseJnlLine."Reference Document" := WhseJnlLine."Reference Document"::Movement;
                    end;
            end;
            if ("Serial No." <> '') then
                TestField("Qty. per Unit of Measure", 1);
            WhseJnlLine."Serial No." := "Serial No.";
            WhseJnlLine."Lot No." := "Lot No.";
            WhseJnlLine."Warranty Date" := "Warranty Date";
            WhseJnlLine."Expiration Date" := "Expiration Date";

            OnPostWhseJnlLineOnBeforeWhseJnlRegisterLine(WhseJnlRegisterLine, TempLineToUndo, WhseJnlLine); // P80082969
            WhseJnlRegisterLine.Run(WhseJnlLine);
        end;
    end;

    local procedure SetWeightAndCubage(ItemNo: Code[20]; UOMCode: Code[10]; Qty: Decimal; var Weight: Decimal; var Cubage: Decimal)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if not ItemUnitOfMeasure.Get(ItemNo, UOMCode) then
            Clear(ItemUnitOfMeasure);
        Weight := Abs(Qty) * ItemUnitOfMeasure.Weight;
        Cubage := Abs(Qty) * ItemUnitOfMeasure.Cubage;
    end;

    local procedure InsertRegActLine(var TempLineToUndo: Record "Registered Whse. Activity Line" temporary)
    var
        LastRegWhseActLine: Record "Registered Whse. Activity Line";
        NewRegWhseActLine: Record "Registered Whse. Activity Line";
    begin
        NewRegWhseActLine := TempLineToUndo;
        with NewRegWhseActLine do begin
            "Undo-to Line No." := "Line No.";
            Quantity := -Quantity;
            "Qty. (Base)" := -"Qty. (Base)";
            SetWeightAndCubage("Item No.", "Unit of Measure Code", Quantity, Weight, Cubage);
            repeat
                "Line No." := "Line No." + 1;
            until Insert;
        end;
    end;

    local procedure UpdateActLine(var TempLineToUndo: Record "Registered Whse. Activity Line" temporary)
    var
        RegWhseActHdr: Record "Registered Whse. Activity Hdr.";
        WhseActLine: Record "Warehouse Activity Line";
    begin
        with TempLineToUndo do begin
            RegWhseActHdr.Get("Activity Type", "No.");
            if not WhseActLine.Get("Activity Type", RegWhseActHdr."Whse. Activity No.", "Line No.") then
                exit;
        end;

        with WhseActLine do begin
            "Qty. Handled" := "Qty. Handled" - TempLineToUndo.Quantity;
            "Qty. Handled (Base)" := "Qty. Handled (Base)" - TempLineToUndo."Qty. (Base)";
            "Qty. Outstanding" := Quantity - "Qty. Handled";
            "Qty. Outstanding (Base)" := "Qty. (Base)" - "Qty. Handled (Base)";
            "Qty. to Handle" := "Qty. Outstanding";
            "Qty. to Handle (Base)" := "Qty. Outstanding (Base)";
            SetWeightAndCubage("Item No.", "Unit of Measure Code", Quantity, Weight, Cubage);
            Modify;
        end;
    end;

    local procedure UpdateSourceDocument(var TempLineToUndo: Record "Registered Whse. Activity Line" temporary; RemovedFromContainer: Boolean)
    var
        WhseShptHeader: Record "Warehouse Shipment Header";
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        // P80058322 - Add parameter for RemovedFromContainer
        with TempLineToUndo do
            case "Whse. Document Type" of
                "Whse. Document Type"::Shipment:
                    begin
                        WhseShptLine.Get("Whse. Document No.", "Whse. Document Line No.");
                        WhseShptLine."Qty. Picked" := WhseShptLine."Qty. Picked" - Quantity;
                        WhseShptLine."Qty. Picked (Base)" := WhseShptLine."Qty. Picked (Base)" - "Qty. (Base)";
                        if not RemovedFromContainer then begin // P80058322
                            WhseShptLine."Qty. to Ship" :=
                              WhseShptLine."Qty. Picked" - WhseShptLine."Qty. Shipped";
                            WhseShptLine."Qty. to Ship (Base)" :=
                              WhseShptLine."Qty. Picked (Base)" - WhseShptLine."Qty. Shipped (Base)";
                        end; // P80058322
                        WhseShptLine.Status := WhseShptLine.CalcStatusShptLine();
                        WhseShptLine."Completely Picked" := false;
                        SetWeightAndCubage(
                          WhseShptLine."Item No.", WhseShptLine."Unit of Measure Code",
                          WhseShptLine.Quantity, WhseShptLine.Weight, WhseShptLine.Cubage);
                        WhseShptLine.Modify;

                        if not RemovedFromContainer then // P80058322
                            UpdateSourceTracking(TempLineToUndo, -1);
                        UpdateWhseTracking(
                          TempLineToUndo, DATABASE::"Warehouse Shipment Line",
                          WhseShptLine."No.", WhseShptLine."Line No.");

                        WhseShptHeader.Get("Whse. Document No.");
                        WhseShptHeader.Validate("Document Status", WhseShptHeader.GetDocumentStatus(0));
                        WhseShptHeader.Modify;
                    end;
            end;
    end;

    local procedure UpdateSourceTracking(var TempLineToUndo: Record "Registered Whse. Activity Line" temporary; SignFactor: Decimal)
    var
        ReservEntry: Record "Reservation Entry";
        Qty: Decimal;
        ReservEntry2: Record "Reservation Entry";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
        FromRowId: Text;
        ToRowId: Text;

    begin
        with ReservEntry do begin
            SetCurrentKey(
              "Source Type", "Source ID", "Source Batch Name", "Source Ref. No.", "Lot No.", "Serial No.");
            SetRange("Source Type", TempLineToUndo."Source Type");
            SetRange("Source Subtype", TempLineToUndo."Source Subtype");
            SetRange("Source ID", TempLineToUndo."Source No.");
            SetRange("Source Ref. No.", TempLineToUndo."Source Line No.");
            SetRange("Lot No.", TempLineToUndo."Lot No.");
            SetRange("Serial No.", TempLineToUndo."Serial No.");
            Qty := SignFactor * TempLineToUndo."Qty. (Base)";
            if Find('+') then
                repeat
                    if (Abs(Qty) < Abs("Quantity (Base)")) then begin
                        "Quantity (Base)" := "Quantity (Base)" - Qty;
                        if ("Qty. per Unit of Measure" = 0) then
                            Quantity := "Quantity (Base)"
                        else
                            Quantity := Round("Quantity (Base)" / "Qty. per Unit of Measure", 0.00001);
                        "Qty. to Handle (Base)" := "Quantity (Base)";
                        "Qty. to Invoice (Base)" := "Quantity (Base)";
                        Modify;
                        Qty := 0;
                    end else begin
                        Qty := Qty - "Quantity (Base)";
                        Delete;
                    end;
                until (Next(-1) = 0) or (Qty = 0);
            // P80093335
            if ReservEntry."Source Type" = Database::"Transfer Line" then begin
                FromRowId := ItemTrackingManagement.ComposeRowID(ReservEntry."Source Type", 0, ReservEntry."Source ID",
                    ReservEntry."Source Batch Name", ReservEntry."Source Prod. Order Line", ReservEntry."Source Ref. No.");
                ToRowID := ItemTrackingManagement.ComposeRowID(ReservEntry."Source Type", 1, ReservEntry."Source ID",
                    ReservEntry."Source Batch Name", ReservEntry."Source Prod. Order Line", ReservEntry."Source Ref. No.");
                ItemTrackingManagement.SynchronizeItemTracking(FromRowId, ToRowID, '');
            end;
            // P80093335
        end;
    end;

    local procedure UpdateWhseTracking(var TempLineToUndo: Record "Registered Whse. Activity Line" temporary; WhseSourceType: Integer; WhseDocNo: Code[20]; WhseDocLineNo: Integer)
    var
        WhseTrackingLine: Record "Whse. Item Tracking Line";
        Qty: Decimal;
    begin
        with WhseTrackingLine do begin
            SetCurrentKey(
              "Source ID", "Source Type", "Source Subtype", "Source Batch Name",
              "Source Prod. Order Line", "Source Ref. No.", "Location Code");
            SetRange("Source ID", WhseDocNo);
            SetRange("Source Type", WhseSourceType);
            SetRange("Source Ref. No.", WhseDocLineNo);
            SetRange("Lot No.", TempLineToUndo."Lot No.");
            SetRange("Serial No.", TempLineToUndo."Serial No.");
            Qty := TempLineToUndo."Qty. (Base)";
            if Find('+') then
                repeat
                    if (Abs(Qty) < Abs("Quantity (Base)")) then begin
                        "Quantity (Base)" := "Quantity (Base)" - Qty;
                        "Quantity Handled (Base)" := "Quantity Handled (Base)" - Qty;
                        "Qty. Registered (Base)" := "Qty. Registered (Base)" - Qty;
                        Quantity := Round("Quantity (Base)" / "Qty. per Unit of Measure", 0.00001); // P80060233
                        InitQtyToHandle;
                        Modify;
                        Qty := 0;
                    end else begin
                        Qty := Qty - "Quantity (Base)";
                        Delete;
                    end;
                until (Next(-1) = 0) or (Qty = 0);
        end;
    end;

    local procedure RemoveFromContainer(TempLineToUndo: Record "Registered Whse. Activity Line" temporary): Boolean
    var
        ContainerHeader: Record "Container Header";
        ContainerLine: Record "Container Line";
        xContainerLine: Record "Container Line";
        ContainerFns: Codeunit "Container Functions";
        QtyToRemove: Decimal;
        QtyToRemoveAlt: Decimal;
    begin
        // P8001323
        with TempLineToUndo do
            if ("Activity Type" = "Activity Type"::Pick) and ("Action Type" = "Action Type"::Place) and ("Container ID" <> '') then begin
                if not ContainerHeader.Get("Container ID") then
                    exit;
                if (ContainerHeader."Location Code" <> "Location Code") or (ContainerHeader."Bin Code" <> "Bin Code") then
                    exit;

                PostContainerLine.SetUsageParms(WorkDate, "Whse. Document No.", '', SourceCodeSetup."Whse. Pick");

                ContainerLine.SetRange("Container ID", TempLineToUndo."Container ID");
                ContainerLine.SetRange("Item No.", TempLineToUndo."Item No.");
                ContainerLine.SetRange("Variant Code", TempLineToUndo."Variant Code");
                ContainerLine.SetRange("Lot No.", TempLineToUndo."Lot No.");
                ContainerLine.SetRange("Serial No.", TempLineToUndo."Serial No.");
                ContainerLine.SetRange("Unit of Measure Code", TempLineToUndo."Unit of Measure Code");
                if ContainerLine.FindSet(true) then
                    repeat
                        if ContainerLine.Quantity <= TempLineToUndo.Quantity then begin
                            QtyToRemove := ContainerLine.Quantity;
                            QtyToRemoveAlt := ContainerLine."Quantity (Alt.)";
                        end else begin
                            QtyToRemove := Quantity;
                            QtyToRemoveAlt := "Quantity (Alt.)";
                            if QtyToRemoveAlt < 0 then
                                QtyToRemoveAlt := 0;
                        end;
                        Quantity -= QtyToRemove;
                        "Quantity (Alt.)" -= QtyToRemoveAlt;
                        xContainerLine := ContainerLine;
                        ContainerLine."Quantity (Alt.)" -= QtyToRemoveAlt;
                        ContainerLine.Quantity -= QtyToRemove;
                        ContainerLine.Validate(Quantity);
                        ContainerFns.SetRegisteringPick(true);
                        ContainerFns.AssignContainerLine(ContainerHeader, xContainerLine, ContainerLine);
                        PostContainerLine := ContainerLine;
                        PostContainerLine.PostContainerUse(xContainerLine.Quantity, xContainerLine."Quantity (Alt.)", ContainerLine.Quantity, ContainerLine."Quantity (Alt.)");
                        if (ContainerLine.Quantity = 0) and (ContainerLine."Quantity (Alt.)" = 0) then
                            ContainerLine.Delete
                        else
                            ContainerLine.Modify;
                    until (ContainerLine.Next = 0) or ((Quantity <= 0) and ("Quantity (Alt.)" <= 0));

                // Check to see if the container is now empty and, if so, delete it
                ContainerLine.Reset;
                ContainerLine.SetRange("Container ID", "Container ID");
                if ContainerLine.IsEmpty then
                    ContainerHeader.Delete(true);

                exit(true); // P80058322
            end;
    end;

    local procedure DeleteAltQtyLine(RegWhseActivityLine: Record "Registered Whse. Activity Line")
    var
        AltQuantityLine: Record "Alternate Quantity Line";
    begin
        // P80067728, P80079981
        AltQuantityLine.SetRange("Additional Ref. ID", RegWhseActivityLine.RecordId);
        AltQuantityLine.DeleteAll;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUndoWhseActivityOnBeforeProcessLine(var RegisteredWhseActivityLine: Record "Registered Whse. Activity Line" temporary)
    begin
        // P80082969
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUndoWhseActivity()
    begin
        // P80082969
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostWhseJnlLineOnBeforeWhseJnlRegisterLine(var WhseJnlRegisterLine: Codeunit "Whse. Jnl.-Register Line"; var RegisteredWhseActivityLine: Record "Registered Whse. Activity Line" temporary; var WarehouseJournalLine: Record "Warehouse Journal Line")
    begin
        // P80082969
    end;
}

