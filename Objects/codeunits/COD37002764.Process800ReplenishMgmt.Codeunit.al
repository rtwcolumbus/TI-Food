codeunit 37002764 "Process 800 Replenish. Mgmt."
{
    // PR5.00
    // P8000494A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Production Bins/Replenishment
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    // 
    // PRW16.00.01
    // P8000706, VerticalSoft, Jack Reynolds, 06 JUL 09
    //   Fix problem with incorrect quantities
    // 
    // PRW16.00.04
    // P8000899, Columbus IT, Ron Davidson, 01 MAR 11
    //   Added Freshness Date logic.
    // 
    // PRW16.00.06
    // P8001075, Columbus IT, Jack Reynolds, 12 JUN 12
    //   Fix problem with location filter on document lines
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // P8001082, Columbus IT, Rick Tweedle, 06 SEP 12
    //   Added Support for Pre-Process Activities
    // 
    // P8001121, Columbus IT, Don Bresee, 17 DEC 12
    //   Add logic to filter transfers
    // 
    // P8001130, Columbus IT, Don Bresee, 20 JAN 13
    //   Modify Prod. Replenishment to process co-product orders
    // 
    // PRW17.00
    // P8001142, Columbus IT, Don Bresee, 09 MAR 13
    //   Rework Replenishment logic
    // 
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10
    // P8001231, Columbus IT, Jack Reynolds, 22 OCT 13
    //   Add support for Shift Code
    // 
    // PRW17.10.02
    // P8001276, Columbus IT, Jack Reynolds, 03 FEB 14
    //   Allow filtering of Prod. Replenishment/Move List by replenishment area
    // 
    // P8001278, Columbus IT, Jack Reynolds, 04 FEB 14
    //   Allow move list reports to suggest receiving and/or output bins
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW120.00
    // P800144605, To Increase, Jack Reynolds, 20 APR 22
    //   Upgrade to 20.0


    trigger OnRun()
    begin
    end;

    var
        TempItemEntry: Record "Warehouse Entry" temporary;
        TempItemEntryNo: Integer;
        TempProdOrderComp: Record "Prod. Order Component" temporary;
        MaxNumSuggestions: Integer;
        WhseLotPickingMgmt: Codeunit "Warehouse Lot Picking Mgmt.";
        SuggBinUOM: Record "Item Unit of Measure";
        UseItemTrackingSugg: Boolean;
        TempItemTrkgSuggestion: Record "Warehouse Entry" temporary;
        TempItemTrkgSuggestionNo: Integer;
        Text000: Label '%1(s)';
        Text001: Label '%1 %2(s) is %3 %4(s)';
        WMSMgmt: Codeunit "WMS Management";
        MarkedSalesLine: Record "Sales Line";
        MarkedPurchLine: Record "Purchase Line";
        MarkedTransLine: Record "Transfer Line";
        PickDate: Date;
        LotStatus: Record "Lot Status Code";
        LotStatusMgmt: Codeunit "Lot Status Management";
        LotStatusExclusionFilter: array[3] of Text[1024];
        PreProcessRefDoc: Option "None",Required;
        PreProcessBinCode: Code[20];
        TempPreProcessBin: Record "Warehouse Entry" temporary;
        TempPreProcessBinNo: Integer;
        TempPreProcessBinAvail: Record "Warehouse Entry" temporary;
        TempPreProcessBinAvailNo: Integer;
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        AllowPickFromRecvBin: Boolean;
        AllowPickFromOutputBin: Boolean;

    procedure BuildProdReplTotals(LocationCode: Code[10]; var ReplenishmentArea: Record "Replenishment Area"; StartingDate: Date; ProdShiftNo: Code[10]; BuildOrderDetail: Boolean)
    var
        Location: Record Location;
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        Item: Record Item;
        ReplBinCode: Code[20];
        ProdUOM: Record "Item Unit of Measure";
        ProdQty: Decimal;
        TransactionType: Integer;
        SharedComponents: Boolean;
        TempCoProductOrder: Record "Prod. Order Line" temporary;
        PreProcessAct: Record "Pre-Process Activity";
        ProdOrder: Record "Production Order";
    begin
        // P8001231 - change ProdShiftNo to Code10
        // P8001276 - add parameter for ReplenishmentArea
        InitReplTotals;
        TempProdOrderComp.Reset;
        TempProdOrderComp.DeleteAll;
        ClearItemTrackingSugg;
        ClearRegPreProcesses(TempPreProcessBin, TempPreProcessBinNo);           // P8001082
        ClearRegPreProcesses(TempPreProcessBinAvail, TempPreProcessBinAvailNo); // P8001082
        Location.Get(LocationCode);
        PickDate := StartingDate; // P8000899
        LotStatusExclusionFilter[1] := LotStatusMgmt.SetLotStatusExclusionFilter( // P8001083
          LotStatus.FieldNo("Available for Consumption"));                        // P8001083
        ProdOrderLine.SetCurrentKey(Status, "Item No.", "Variant Code", "Location Code", "Starting Date");
        ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Released);
        ProdOrderLine.SetRange("Location Code", LocationCode);
        ProdOrderLine.SetRange("Starting Date", StartingDate);
        if (ProdShiftNo <> '') then
            ProdOrderLine.SetRange("Work Shift Code", ProdShiftNo);
        if ProdOrderLine.FindSet then
            with ProdOrderComp do
                repeat
                    ReplenishmentArea.Code := ProdOrderLine."Replenishment Area Code"; // P8001276
                    if ReplenishmentArea.Find then begin                               // P8001276
                        SetRange(Status, ProdOrderLine.Status);
                        SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
                        SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
                        SetFilter("Item No.", '<>%1', '');
                        SetFilter("Remaining Quantity", '>0');
                        if FindSet then
                            repeat
                                Item.Get("Item No.");
                                // P8001083
                                if Item."Item Tracking Code" <> '' then
                                    TransactionType := 1
                                else
                                    TransactionType := 0;
                                // P8001083
                                if Item.IsFixedBinItem(LocationCode) or (not ReplenishmentNotRequired()) then begin
                                    if ("Planning Level Code" = 0) and
                                       (("Flushing Method" = "Flushing Method"::Manual) or
                                        ("Flushing Method" = "Flushing Method"::"Pick + Backward") or
                                        (("Flushing Method" = "Flushing Method"::"Pick + Forward") and
                                         ("Routing Link Code" <> '')))
                                    then begin
                                        Location.SetToProductionBin("Prod. Order No.", "Prod. Order Line No.", "Line No."); // P8001142
                                        ReplBinCode := Location."To-Production Bin Code";
                                    end else begin
                                        Location.TestField("Open Shop Floor Bin Code");
                                        ReplBinCode := Location."Open Shop Floor Bin Code";
                                    end;
                                    if (ReplBinCode <> '') then begin
                                        ProdUOM.Code := Item."Replenishment UOM Code";
                                        if (ProdUOM.Code = '') then
                                            ProdUOM.Code := Item."Base Unit of Measure";
                                        ProdUOM.Get("Item No.", ProdUOM.Code);
                                        ProdQty := "Remaining Quantity" *
                                          "Qty. per Unit of Measure" / ProdUOM."Qty. per Unit of Measure";
                                        SetPreProcessReplBin(ProdOrderComp); // P8001082
                                        InsertReplQty(
                                          LocationCode, Location."To-Production Bin Code", "Item No.",
                                          "Variant Code", TransactionType, Item."Replenishment Type", ProdUOM.Code, ProdQty); // P8001083
                                                                                                                              // P8001082
                                        if IsPreProcessReplBin() then
                                            InsertRegPreProcess(LocationCode, ProdOrderComp, ReplBinCode)
                                        else
                                            // P8001082
                                            InsertItemTrkgSuggestions(
                            LocationCode, DATABASE::"Prod. Order Component", Status, "Prod. Order No.",
                            "Prod. Order Line No.", "Line No.", ProdQty);
                                        if BuildOrderDetail then begin
                                            TempProdOrderComp := ProdOrderComp;
                                            TempProdOrderComp."Bin Code" := Location."To-Production Bin Code";
                                            TempProdOrderComp.Insert;
                                        end;
                                    end;
                                end;
                            until (Next = 0);
                    end; // P8001276
                         // UNTIL (ProdOrderLine.NEXT = 0);                                                   // P8001130
                until (not GetNextProdOrderLine(ProdOrderLine, SharedComponents, TempCoProductOrder)); // P8001130

        // P8001082
        with PreProcessAct do begin
            SetCurrentKey("Location Code", "Starting Date", "Prod. Order Status", Blending);
            SetRange("Location Code", LocationCode);
            SetRange("Starting Date", StartingDate);
            SetRange("Prod. Order Status", "Prod. Order Status"::Released);
            SetRange(Blending, Blending::" ");
            SetFilter("Remaining Quantity", '>0');
            if FindSet then
                repeat
                    ReplenishmentArea.Code := "Replenishment Area Code"; // P8001276
                    if ReplenishmentArea.Find then begin                 // P8001276
                        ProdOrder.Get("Prod. Order Status", "Prod. Order No.");
                        if (ProdShiftNo = '') or (ProdOrder."Work Shift Code" = ProdShiftNo) then begin
                            if IsLotTracked() then
                                TransactionType := 1
                            else
                                TransactionType := 0;
                            Item.Get("Item No.");
                            ProdOrderComp.Get("Prod. Order Status", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Comp. Line No.");
                            if Item.IsFixedBinItem(LocationCode) or (not ProdOrderComp.ReplenishmentNotRequired()) then begin
                                ProdUOM.Code := Item."Replenishment UOM Code";
                                if (ProdUOM.Code = '') then
                                    ProdUOM.Code := Item."Base Unit of Measure";
                                ProdUOM.Get("Item No.", ProdUOM.Code);
                                ProdQty := "Remaining Quantity" *
                                  "Qty. per Unit of Measure" / ProdUOM."Qty. per Unit of Measure";
                                InsertReplQty(
                                  LocationCode, "To Bin Code", "Item No.", "Variant Code",
                                  TransactionType, Item."Replenishment Type", ProdUOM.Code, ProdQty);
                                if BuildOrderDetail then begin
                                    TempProdOrderComp := ProdOrderComp;
                                    TempProdOrderComp."Bin Code" := "To Bin Code";
                                    TempProdOrderComp.Insert;
                                end;
                            end;
                        end;
                    end; // P8001276
                until (Next = 0);
        end;
        UpdatePreProcessQtyAvail;
        // P8001082
    end;

    local procedure InitReplTotals()
    var
        PickingType: Integer;
    begin
        TempItemEntry.Reset;
        TempItemEntry.DeleteAll;
        TempItemEntry.SetCurrentKey(
          "Location Code", "Bin Code", "Item No.", "Variant Code");
        TempItemEntryNo := 0;
    end;

    local procedure InsertReplQty(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; TransactionType: Integer; PickingType: Integer; UOMCode: Code[10]; Qty: Decimal)
    begin
        // P8001083 - add parameter for TransactionType
        with TempItemEntry do begin
            SetRange("Location Code", LocationCode);
            SetRange("Bin Code", BinCode);
            SetRange("Item No.", ItemNo);
            SetRange("Variant Code", VariantCode);
            SetRange("Reference Document", PreProcessRefDoc); // P8001082
            SetRange("Reference No.", PreProcessBinCode);     // P8001082
            SetRange("Source Subtype", TransactionType); // P8001083
            if FindFirst then begin
                Quantity := Quantity + Qty;
                Modify;
            end else begin
                TempItemEntryNo := TempItemEntryNo + 1;
                "Entry No." := TempItemEntryNo;
                "Location Code" := LocationCode;
                "Bin Code" := BinCode;
                "Item No." := ItemNo;
                "Variant Code" := VariantCode;
                "Unit of Measure Code" := UOMCode;
                "Source Type" := PickingType;
                "Reference Document" := PreProcessRefDoc; // P8001082
                "Reference No." := PreProcessBinCode;     // P8001082
                "Source Subtype" := TransactionType; // P8001083
                "Source No." := BinCode;
                Quantity := Qty;
                Insert;
            end;
        end;
    end;

    procedure GetReplItemType(GetFirstItemType: Boolean; var ItemType: Integer; var ItemTypeStr: Text[80]): Boolean
    var
        ReplItemType: Record Item;
    begin
        with TempItemEntry do begin
            Reset;
            SetCurrentKey("Source Type", "Source Subtype", "Source No.");
            if GetFirstItemType then begin
                if not FindFirst then
                    exit(false);
            end else begin
                SetRange("Source Type", ItemType);
                FindLast;
                SetRange("Source Type");
                if (Next = 0) then
                    exit(false);
            end;
            ItemType := "Source Type";
            ReplItemType."Replenishment Type" := ItemType;
            ItemTypeStr := Format(ReplItemType."Replenishment Type");
            exit(true);
        end;
    end;

    procedure GetReplItem(GetFirstItem: Boolean; ItemType: Integer; var Item: Record Item): Boolean
    begin
        with TempItemEntry do begin
            if GetFirstItem then begin
                Reset;
                SetCurrentKey(
                  "Item No.", "Bin Code", "Location Code", "Variant Code");
                SetRange("Source Type", ItemType);
                if not FindSet then
                    exit(false);
            end else begin
                SetRange("Item No.");
                SetRange("Variant Code");   // P8001083
                SetRange("Source Subtype"); // P8001083
                SetRange("Reference Document"); // P8001082
                SetRange("Reference No.");      // P8001082
                if (Next = 0) then
                    exit(false);
            end;
            SetRange("Item No.", "Item No.");
            SetRange("Variant Code", "Variant Code");     // P8001083
            SetRange("Source Subtype", "Source Subtype"); // P8001083
            SetRange("Reference Document", "Reference Document"); // P8001082
            SetRange("Reference No.", "Reference No.");           // P8001082
            Item.Get("Item No.");
            exit(true);
        end;
    end;

    procedure GetReplItemBin(GetFirstItemBin: Boolean; var VariantCode: Code[10]; var TransType: Integer; var Bin: Record Bin; var UOMCode: Code[10]; var Qty: Decimal): Boolean
    begin
        // P8001083 - add parameter for TransType
        with TempItemEntry do begin
            if not GetFirstItemBin then
                if (Next = 0) then
                    exit(false);
            VariantCode := "Variant Code";
            PreProcessRefDoc := "Reference Document"; // P8001082
            PreProcessBinCode := "Reference No.";     // P8001082
            TransType := "Source Subtype"; // P8001083
            Bin.Get("Location Code", "Bin Code");
            UOMCode := "Unit of Measure Code";
            Qty := Quantity;
            exit(true);
        end;
    end;

    procedure GetReplProdOrderDetail(GetFirstOrderDetail: Boolean; var OrderNo: Code[20]; var BinCode: Code[20]; var UOMCode: Code[10]; var Qty: Decimal; var QtyBase: Decimal): Boolean
    begin
        with TempProdOrderComp do begin
            if GetFirstOrderDetail then begin
                SetCurrentKey("Item No.");
                SetRange("Item No.", TempItemEntry."Item No.");
                if not FindSet then
                    exit(false);
            end else
                if (Next = 0) then
                    exit(false);
            OrderNo := "Prod. Order No.";
            BinCode := "Bin Code";
            UOMCode := "Unit of Measure Code";
            Qty := "Remaining Quantity";
            QtyBase := "Remaining Qty. (Base)";
            exit(true);
        end;
    end;

    procedure GetQtyAvailBase(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; TransactionType: Integer; UOMCode: Code[10]): Decimal
    var
        QtyAvailBase: Decimal;
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
        WhseActLine: Record "Warehouse Activity Line";
        WhseEntry: Record "Warehouse Entry";
    begin
        // P8001083 - Add parameter for TransactionType
        with WhseEntry do begin
            SetCurrentKey("Item No.", "Bin Code", "Location Code", "Variant Code");
            SetRange("Location Code", LocationCode);
            SetRange("Bin Code", BinCode);
            SetRange("Item No.", ItemNo);
            SetRange("Variant Code", VariantCode);
            CalcSums("Qty. (Base)");
            QtyAvailBase := "Qty. (Base)";
            if TransactionType <> 0 then // P8001083
                LotStatusMgmt.QuantityAdjForWhseEntry(WhseEntry, LotStatusExclusionFilter[Abs(TransactionType)], QtyAvailBase); // P8001083
        end;

        with WhseActLine do begin
            SetCurrentKey(
              "Item No.", "Bin Code", "Location Code", "Action Type",
              "Variant Code", "Unit of Measure Code", "Breakbulk No.");
            SetRange("Item No.", ItemNo);
            SetRange("Bin Code", BinCode);
            SetRange("Location Code", LocationCode);
            SetRange("Action Type", "Action Type"::Take);
            SetRange("Variant Code", VariantCode);
            SetRange("Unit of Measure Code", UOMCode);
            SetRange("Breakbulk No.", 0);
            CalcSums("Qty. (Base)");
            QtyAvailBase := QtyAvailBase - "Qty. (Base)";

            SetRange("Action Type", "Action Type"::Place);
            SetFilter("Breakbulk No.", '<>0');
            CalcSums("Qty. (Base)");
            QtyAvailBase := QtyAvailBase + "Qty. (Base)";
        end;
        if (QtyAvailBase <= 0) then
            exit(0);

        with WhseStagedPickLine do begin
            SetCurrentKey(
              "Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
            SetRange("Location Code", LocationCode);
            SetRange("Bin Code", BinCode);
            SetRange("Item No.", ItemNo);
            SetRange("Variant Code", VariantCode);
            SetRange("Unit of Measure Code", UOMCode);
            CalcSums("Qty. Outstanding (Base)");
            QtyAvailBase := QtyAvailBase - "Qty. Outstanding (Base)";
        end;
        if (QtyAvailBase <= 0) then
            exit(0);
        exit(QtyAvailBase);
    end;

    procedure SetMaxNumSuggestions(NewMaxNumSuggestions: Integer)
    begin
        MaxNumSuggestions := NewMaxNumSuggestions;
    end;

    local procedure MaxNumSuggestionsReached(NumSuggestions: Integer): Boolean
    begin
        exit((MaxNumSuggestions <> 0) and (NumSuggestions >= MaxNumSuggestions));
    end;

    procedure GetSuggestedPicks(SuggestPicks: Boolean; var PicksSuggested: Boolean; LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; TransactionType: Integer; QtyNeeded: Decimal; UOMCode: Code[10]; var TempBinSuggestion: Record "Warehouse Entry" temporary): Boolean
    var
        QtyNeededBase: Decimal;
        NumSuggestions: Integer;
        SuggestedQtyBase: Decimal;
        LotNo: Code[50];
        ItemUOM: Record "Item Unit of Measure";
        ExclusionFilter: Text[1024];
    begin
        // P8001083 - add parameter for TransactionType
        PicksSuggested := false;
        if not SuggestPicks then
            exit(false);
        with TempBinSuggestion do begin
            Reset;
            DeleteAll;
            "Entry No." := 0;
        end;
        SuggBinUOM.Reset;
        if (QtyNeeded = 0) then
            exit(false);
        if IsPreProcessReplBin() then                                                                 // P8001082
            exit(GetPreProcessPicks(PicksSuggested, LocationCode, ItemNo, VariantCode, TempBinSuggestion)); // P8001082
        NumSuggestions := 0;
        SuggestedQtyBase := 0;
        if TransactionType <> 0 then                                         // P8001083
            ExclusionFilter := LotStatusExclusionFilter[Abs(TransactionType)]; // P8001083
        with ItemUOM do begin
            Get(ItemNo, UOMCode);
            QtyNeededBase := QtyNeeded * "Qty. per Unit of Measure";
            StartPickSuggestions(LocationCode, ItemNo, VariantCode, ExclusionFilter, LotNo); // P8001083
            repeat
                Get(ItemNo, UOMCode);
                SetCurrentKey("Item No.", "Qty. per Unit of Measure");
                SetRange("Item No.", ItemNo);
                SetFilter("Qty. per Unit of Measure", '>=%1', "Qty. per Unit of Measure");
                if Find('-') then
                    repeat
                        AddSuggPickLines(
                          LocationCode, ItemNo, VariantCode, ExclusionFilter, // P8001083
                          QtyNeededBase, ItemUOM, LotNo,
                          NumSuggestions, SuggestedQtyBase, TempBinSuggestion);
                    until MaxNumSuggestionsReached(NumSuggestions) or (Next = 0);
                if not MaxNumSuggestionsReached(NumSuggestions) then begin
                    Get(ItemNo, UOMCode);
                    SetFilter("Qty. per Unit of Measure", '<%1', "Qty. per Unit of Measure");
                    if Find('+') then
                        repeat
                            AddSuggPickLines(
                              LocationCode, ItemNo, VariantCode, ExclusionFilter, // P8001083
                              QtyNeededBase, ItemUOM, LotNo,
                              NumSuggestions, SuggestedQtyBase, TempBinSuggestion);
                        until MaxNumSuggestionsReached(NumSuggestions) or (Next(-1) = 0);
                end;
            until MaxNumSuggestionsReached(NumSuggestions) or PickSuggestionsComplete(ExclusionFilter, LotNo); // P8001083
        end;
        PicksSuggested := TempBinSuggestion.Find('-');
        exit(PicksSuggested);
    end;

    local procedure AddSuggPickLines(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; ExclusionFilter: Text[1024]; QtyNeededBase: Decimal; var ItemUOM: Record "Item Unit of Measure"; LotNo: Code[50]; var NumSuggestions: Integer; var SuggestedQtyBase: Decimal; var TempBinSuggestion: Record "Warehouse Entry" temporary)
    var
        BinContent: Record "Bin Content";
    begin
        // P8001083 - add parameter for ExclusionFilter
        with BinContent do begin
            SetCurrentKey(
              "Location Code", "Item No.", "Variant Code",
              "Cross-Dock Bin", "Qty. per Unit of Measure", "Bin Ranking");
            SetRange("Location Code", LocationCode);
            SetRange("Item No.", ItemNo);
            SetRange("Variant Code", VariantCode);
            SetRange("Cross-Dock Bin", false);
            SetRange("Unit of Measure Code", ItemUOM.Code);
            SetRange(Dedicated, false); // P8001142
            SetFilter("Lot No. Filter", LotNo);
            if Find('+') then
                repeat
                    // IF BinType.GET("Bin Type Code") THEN // P8000631A
                    //  IF BinType.Pick THEN BEGIN          // P8000631A
                    if IsPickBin(BinContent) then begin     // P8000631A
                        CalcFields("Remaining Quantity", "Pick Qty.");
                        // P8001083
                        if ExclusionFilter <> '' then
                            LotStatusMgmt.QuantityAdjForBinContent(BinContent, ExclusionFilter, "Remaining Quantity");
                        // P8001083
                        if (("Remaining Quantity" - "Pick Qty.") > 0) then begin
                            TempBinSuggestion."Entry No." := TempBinSuggestion."Entry No." + 1;
                            TempBinSuggestion."Bin Code" := "Bin Code";
                            TempBinSuggestion."Item No." := ItemNo;
                            TempBinSuggestion."Variant Code" := VariantCode;
                            TempBinSuggestion."Unit of Measure Code" := ItemUOM.Code;
                            TempBinSuggestion."Lot No." := LotNo;
                            TempBinSuggestion.Quantity := "Remaining Quantity" - "Pick Qty.";
                            TempBinSuggestion."Qty. (Base)" :=
                              TempBinSuggestion.Quantity * ItemUOM."Qty. per Unit of Measure";
                            if VerifyLotFreshness(TempBinSuggestion."Lot No.") then // P8000899
                                TempBinSuggestion.Insert;
                            SuggestedQtyBase := SuggestedQtyBase + TempBinSuggestion."Qty. (Base)";
                            if (SuggestedQtyBase >= QtyNeededBase) then begin
                                NumSuggestions := NumSuggestions + 1;
                                SuggestedQtyBase := 0;
                            end;
                        end;
                    end;
                until MaxNumSuggestionsReached(NumSuggestions) or (Next(-1) = 0);
        end;
    end;

    local procedure IsPickBin(var BinContent: Record "Bin Content"): Boolean
    var
        Location: Record Location;
        BinType: Record "Bin Type";
    begin
        // P8000631A
        with BinContent do begin
            if BinType.Get("Bin Type Code") then
              // P8001278
              begin
                //EXIT(BinType.Pick);
                if BinType.Pick then
                    exit(true);
                if AllowPickFromRecvBin and BinType.Receive then
                    exit(true);
                if AllowPickFromOutputBin then begin
                    Location.Get("Location Code");
                    exit(Location.IsFromBin("Bin Code"));
                end;
            end;
            // P8001278
            Location.Get("Location Code");
            if Location.Is1DocWhseBin("Bin Code") then // P8001278
                exit(true);                              // P8001278
                                                         // P8001278
            if AllowPickFromRecvBin and (Location."Receipt Bin Code (1-Doc)" = "Bin Code") then
                exit(true);
            if AllowPickFromOutputBin then
                if Location.IsFromBin("Bin Code") then
                    exit(true);
            // P8001278
        end;
    end;

    procedure GetSuggBinLine(GetFirstLine: Boolean; var TempBinSuggestion: Record "Warehouse Entry" temporary): Boolean
    begin
        if GetFirstLine then
            exit(TempBinSuggestion.Find('-'));
        exit(TempBinSuggestion.Next <> 0);
    end;

    procedure ShowNoSuggBins(SuggestBins: Boolean; BinsSuggested: Boolean; QtyNeeded: Decimal): Boolean
    begin
        exit(SuggestBins and (not BinsSuggested) and (QtyNeeded <> 0));
    end;

    procedure GetSuggBinUOMMsg(QtyNeeded: Decimal; UOMCode: Code[10]; var TempBinSuggestion: Record "Warehouse Entry" temporary; var UOMMsg: Text[250])
    var
        UOMDesc: Text[80];
        SourceUOM: Record "Item Unit of Measure";
    begin
        UOMMsg := '';
        with TempBinSuggestion do begin
            SuggBinUOM.Get("Item No.", "Unit of Measure Code");
            if not SuggBinUOM.Mark then begin
                if (UOMCode = "Unit of Measure Code") then begin
                    UOMDesc := SuggBinUOM.GetUOMDescription(SuggBinUOM.Code);
                    if (UOMDesc <> SuggBinUOM.Code) then
                        UOMMsg := StrSubstNo(Text000, UOMDesc);
                end else begin
                    SourceUOM.Get("Item No.", UOMCode);
                    UOMMsg :=
                      StrSubstNo(
                        Text001, QtyNeeded, SourceUOM.GetUOMDescription(SourceUOM.Code),
                        Round(QtyNeeded *
                          SourceUOM."Qty. per Unit of Measure" / SuggBinUOM."Qty. per Unit of Measure", 0.00001),
                        SuggBinUOM.GetUOMDescription(SuggBinUOM.Code));
                end;
                SuggBinUOM.Mark(true);
            end;
        end;
    end;

    local procedure StartPickSuggestions(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; ExclusionFilter: Text[1024]; var LotNo: Code[50])
    begin
        // P8001083 - add parameter for ExclusionFilter
        with TempItemTrkgSuggestion do begin
            SetRange("Location Code", LocationCode);
            SetRange("Item No.", ItemNo);
            SetRange("Variant Code", VariantCode);
        end;
        UseItemTrackingSugg := GetItemTrkgSuggestion(LotNo);
        if not UseItemTrackingSugg then
            WhseLotPickingMgmt.StartPickSuggestions(LocationCode, ItemNo, VariantCode, LotNo, ExclusionFilter); // P8001083
    end;

    local procedure PickSuggestionsComplete(ExclusionFilter: Text[1024]; var LotNo: Code[50]): Boolean
    begin
        // P8001083 - add parameter for ExclusionFilter
        if not UseItemTrackingSugg then
            exit(WhseLotPickingMgmt.PickSuggestionsComplete(LotNo, ExclusionFilter)); // P8001083
        exit(not GetItemTrkgSuggestion(LotNo));
    end;

    local procedure GetItemTrkgSuggestion(var LotNo: Code[50]): Boolean
    begin
        with TempItemTrkgSuggestion do begin
            if Find('-') then begin
                LotNo := "Lot No.";
                Delete;
                exit(true);
            end;
            LotNo := '';
            exit(false);
        end;
    end;

    local procedure InsertItemTrkgSuggestions(LocationCode: Code[10]; SourceType: Integer; SourceSubtype: Integer; SourceID: Code[20]; SourceProdLineNo: Integer; SourceLineNo: Integer; Qty: Decimal)
    var
        ResEntry: Record "Reservation Entry";
    begin
        with ResEntry do begin
            SetCurrentKey(
              "Source Type", "Source Subtype", "Source ID", "Source Batch Name",
              "Source Prod. Order Line", "Source Ref. No.", "Reservation Status", "Expected Receipt Date");
            SetRange("Source Type", SourceType);
            SetRange("Source Subtype", SourceSubtype);
            SetRange("Source ID", SourceID);
            SetRange("Source Prod. Order Line", SourceProdLineNo);
            SetRange("Source Ref. No.", SourceLineNo);
            SetRange("Reservation Status", "Reservation Status"::Surplus);
            SetFilter("Qty. to Handle (Base)", '<>0');
            if FindSet then
                repeat
                    AddItemTrackingSugg(
                      LocationCode, "Item No.", "Variant Code", "Lot No.", Qty);
                until (Next = 0);
        end;
    end;

    local procedure AddItemTrackingSugg(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50]; Qty: Decimal)
    begin
        with TempItemTrkgSuggestion do begin
            SetRange("Location Code", LocationCode);
            SetRange("Item No.", ItemNo);
            SetRange("Variant Code", VariantCode);
            SetRange("Lot No.", LotNo);
            if FindFirst then begin
                Quantity := Quantity + Qty;
                Modify;
            end else begin
                TempItemTrkgSuggestionNo := TempItemTrkgSuggestionNo + 1;
                "Entry No." := TempItemTrkgSuggestionNo;
                "Location Code" := LocationCode;
                "Item No." := ItemNo;
                "Variant Code" := VariantCode;
                "Lot No." := LotNo;
                Quantity := Qty;
                Insert;
            end;
            SetRange("Lot No.");
        end;
    end;

    local procedure ClearItemTrackingSugg()
    begin
        with TempItemTrkgSuggestion do begin
            Reset;
            DeleteAll;
            SetCurrentKey("Item No.", "Location Code", "Variant Code");
        end;
        TempItemTrkgSuggestionNo := 0;
    end;

    procedure GetSuggestedPutAways(SuggestPutAways: Boolean; var PutAwaysSuggested: Boolean; LocationCode: Code[10]; var FromBins: Record Bin; ItemNo: Code[20]; VariantCode: Code[10]; var ItemUOM: Record "Item Unit of Measure"; var TempBinSuggestion: Record "Warehouse Entry" temporary): Boolean
    var
        NumSuggestions: Integer;
        DefBinCode: Code[20];
    begin
        // P8000631A
        PutAwaysSuggested := false;
        if not SuggestPutAways then
            exit(false);
        with TempBinSuggestion do begin
            Reset;
            DeleteAll;
            "Entry No." := 0;
        end;
        SuggBinUOM.Reset;
        NumSuggestions := 0;
        with ItemUOM do begin
            SetCurrentKey("Item No.", "Qty. per Unit of Measure");
            SetRange("Item No.", ItemNo);
            MarkedOnly(true);
            if FindSet then begin
                repeat
                    AddPutAwayDefLine(
                      LocationCode, FromBins, ItemNo, VariantCode, ItemUOM, DefBinCode, NumSuggestions, TempBinSuggestion);
                until (Next = 0);
                if (NumSuggestions > 1) then
                    NumSuggestions := 1;
                if not MaxNumSuggestionsReached(NumSuggestions) then begin
                    FindSet;
                    repeat
                        AddSuggPutAwayLines(
                          LocationCode, FromBins, ItemNo, VariantCode, ItemUOM, DefBinCode, NumSuggestions, TempBinSuggestion);
                    until MaxNumSuggestionsReached(NumSuggestions) or (Next = 0);
                end;
            end;
            MarkedOnly(false);
            if not MaxNumSuggestionsReached(NumSuggestions) then
                if FindSet then
                    repeat
                        if not Mark then
                            AddSuggPutAwayLines(
                              LocationCode, FromBins, ItemNo, VariantCode, ItemUOM, '', NumSuggestions, TempBinSuggestion);
                    until MaxNumSuggestionsReached(NumSuggestions) or (Next = 0);
        end;
        PutAwaysSuggested := TempBinSuggestion.FindSet;
        exit(PutAwaysSuggested);
    end;

    local procedure AddPutAwayDefLine(LocationCode: Code[10]; var FromBins: Record Bin; ItemNo: Code[20]; VariantCode: Code[10]; var ItemUOM: Record "Item Unit of Measure"; var DefBinCode: Code[20]; var NumSuggestions: Integer; var TempBinSuggestion: Record "Warehouse Entry" temporary)
    var
        BinContent: Record "Bin Content";
    begin
        // P8000631A
        if not WMSMgmt.GetDefaultBin(ItemNo, VariantCode, LocationCode, DefBinCode) then
            DefBinCode := ''
        else
            if not IsPutAwayFromBin(LocationCode, FromBins, DefBinCode) then begin
                TempBinSuggestion."Entry No." := TempBinSuggestion."Entry No." + 1;
                TempBinSuggestion."Bin Code" := DefBinCode;
                TempBinSuggestion."Item No." := ItemNo;
                TempBinSuggestion."Variant Code" := VariantCode;
                TempBinSuggestion."Unit of Measure Code" := ItemUOM.Code;
                if BinContent.Get(LocationCode, DefBinCode, ItemNo, VariantCode, ItemUOM.Code) then begin
                    BinContent.CalcFields("Remaining Quantity", "Pick Qty.");
                    TempBinSuggestion.Quantity := BinContent."Remaining Quantity" - BinContent."Pick Qty.";
                    TempBinSuggestion."Qty. (Base)" :=
                      TempBinSuggestion.Quantity * ItemUOM."Qty. per Unit of Measure";
                end else begin
                    TempBinSuggestion.Quantity := 0;
                    TempBinSuggestion."Qty. (Base)" := 0;
                end;
                TempBinSuggestion.Insert;
                NumSuggestions := NumSuggestions + 1;
            end;
    end;

    local procedure AddSuggPutAwayLines(LocationCode: Code[10]; var FromBins: Record Bin; ItemNo: Code[20]; VariantCode: Code[10]; var ItemUOM: Record "Item Unit of Measure"; DefBinCode: Code[20]; var NumSuggestions: Integer; var TempBinSuggestion: Record "Warehouse Entry" temporary)
    var
        BinContent: Record "Bin Content";
        Location: Record Location;
    begin
        // P8000631A
        with BinContent do begin
            SetCurrentKey(
              "Location Code", "Item No.", "Variant Code",
              "Cross-Dock Bin", "Qty. per Unit of Measure", "Bin Ranking");
            SetRange("Location Code", LocationCode);
            SetRange("Item No.", ItemNo);
            SetRange("Variant Code", VariantCode);
            SetRange("Cross-Dock Bin", false);
            SetRange("Unit of Measure Code", ItemUOM.Code);
            if Find('+') then begin
                Location.Get("Location Code");
                repeat
                    if Location.Is1DocWhseBin("Bin Code") and
                       (not IsPutAwayFromBin(LocationCode, FromBins, "Bin Code")) and ("Bin Code" <> DefBinCode)
                    then begin
                        CalcFields("Remaining Quantity", "Pick Qty.");
                        if (("Remaining Quantity" - "Pick Qty.") > 0) then begin
                            TempBinSuggestion."Entry No." := TempBinSuggestion."Entry No." + 1;
                            TempBinSuggestion."Bin Code" := "Bin Code";
                            TempBinSuggestion."Item No." := ItemNo;
                            TempBinSuggestion."Variant Code" := VariantCode;
                            TempBinSuggestion."Unit of Measure Code" := ItemUOM.Code;
                            TempBinSuggestion.Quantity := "Remaining Quantity" - "Pick Qty.";
                            TempBinSuggestion."Qty. (Base)" :=
                              TempBinSuggestion.Quantity * ItemUOM."Qty. per Unit of Measure";
                            TempBinSuggestion.Insert;
                            NumSuggestions := NumSuggestions + 1;
                        end;
                    end;
                until MaxNumSuggestionsReached(NumSuggestions) or (Next(-1) = 0);
            end;
        end;
    end;

    local procedure IsPutAwayFromBin(LocationCode: Code[10]; var FromBins: Record Bin; BinCode: Code[20]): Boolean
    begin
        // P8000631A
        FromBins."Location Code" := LocationCode;
        FromBins.Code := BinCode;
        exit(FromBins.Find);
    end;

    procedure BuildShptReplTotals(LocationCode: Code[10]; ShptDate: Date; DelRouteFilter: Code[80]; var Item: Record Item; var WhseReq: Record "Warehouse Request"; BuildOrderDetail: Boolean)
    var
        Location: Record Location;
        WhseReq2: Record "Warehouse Request";
    begin
        // P8000631A
        InitReplTotals;
        MarkedSalesLine.Reset;
        MarkedPurchLine.Reset;
        ClearItemTrackingSugg;
        Location.Get(LocationCode);
        PickDate := ShptDate; // P8000899
        // P8001083
        LotStatusExclusionFilter[1] := LotStatusMgmt.SetLotStatusExclusionFilter(LotStatus.FieldNo("Available for Sale"));
        LotStatusExclusionFilter[2] := LotStatusMgmt.SetLotStatusExclusionFilter(LotStatus.FieldNo("Available for Purchase"));
        LotStatusExclusionFilter[3] := LotStatusMgmt.SetLotStatusExclusionFilter(LotStatus.FieldNo("Available for Transfer"));
        // P8001083
        with WhseReq2 do begin
            Copy(WhseReq);
            SetRange("Location Code", LocationCode);
            SetRange("Shipment Date", ShptDate);
            if FindSet then
                repeat
                    case "Source Document" of
                        "Source Document"::"Sales Order":
                            BuildSalesOrderRepl(Location, Item, "Source No.", DelRouteFilter, BuildOrderDetail);
                        "Source Document"::"Purchase Return Order":
                            BuildPurchReturnOrderRepl(Location, Item, "Source No.", DelRouteFilter, BuildOrderDetail);
                        "Source Document"::"Outbound Transfer":
                            BuildTransOrderRepl(Location, Item, "Source No.", DelRouteFilter, BuildOrderDetail);
                    end;
                until (Next = 0);
        end;

        ConsolidateReplItemByTransType; // P8001083
    end;

    local procedure BuildSalesOrderRepl(var Location: Record Location; var Item: Record Item; OrderNo: Code[20]; DelRouteFilter: Code[80]; BuildOrderDetail: Boolean)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ItemUOM: Record "Item Unit of Measure";
        TransactionType: Integer;
    begin
        // P8000631A
        if (DelRouteFilter <> '') then
            with SalesHeader do begin
                SetRange("Document Type", "Document Type"::Order);
                SetRange("No.", OrderNo);
                SetFilter("Delivery Route No.", DelRouteFilter);
                if not FindFirst then
                    exit;
            end;
        with SalesLine do begin
            SetRange("Document Type", "Document Type"::Order);
            SetRange("Document No.", OrderNo);
            SetRange(Type, Type::Item);
            SetFilter("No.", '<>%1', '');
            SetFilter("Outstanding Qty. (Base)", '>0');
            SetRange("Location Code", Location.Code); // xxx
            if FindSet then
                repeat
                    Item.Get("No.");
                    // P8001083
                    if Item."Item Tracking Code" <> '' then
                        TransactionType := 1
                    else
                        TransactionType := 0;
                    // P8001083
                    if Item.Find then begin
                        // P8000706
                        if Item."Replenishment UOM Code" = '' then begin
                            "Unit of Measure Code" := Item."Base Unit of Measure";
                            "Outstanding Quantity" := "Outstanding Qty. (Base)"
                        end else begin
                            "Unit of Measure Code" := Item."Replenishment UOM Code";
                            ItemUOM.Get("No.", "Unit of Measure Code");
                            "Outstanding Quantity" := "Outstanding Qty. (Base)" / ItemUOM."Qty. per Unit of Measure";
                        end;
                        // P8000706
                        InsertReplQty(
                          Location.Code, Location."Shipment Bin Code (1-Doc)", "No.",
                          "Variant Code", TransactionType, 0, "Unit of Measure Code", "Outstanding Quantity"); // P8000706, P8001083
                                                                                                               // P8000899, P8001083
                                                                                                               //TempItemEntry."Source Subtype" := "Document Type";
                                                                                                               //TempItemEntry."Source No." := "Document No.";
                                                                                                               //TempItemEntry."Source Line No." := "Line No.";
                                                                                                               //TempItemEntry.MODIFY;
                                                                                                               // P8000899, P8001083
                        InsertItemTrkgSuggestions(
                          Location.Code, DATABASE::"Sales Line", "Document Type",
                          "Document No.", 0, "Line No.", "Outstanding Quantity"); // P8000706
                        if BuildOrderDetail then begin
                            MarkedSalesLine := SalesLine;
                            MarkedSalesLine.Mark(true);
                        end;
                    end;
                until (Next = 0);
        end;
    end;

    local procedure BuildPurchReturnOrderRepl(var Location: Record Location; var Item: Record Item; OrderNo: Code[20]; DelRouteFilter: Code[80]; BuildOrderDetail: Boolean)
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        ItemUOM: Record "Item Unit of Measure";
        TransactionType: Integer;
    begin
        // P8000631A
        if (DelRouteFilter <> '') then
            with PurchHeader do begin
                SetRange("Document Type", "Document Type"::"Return Order");
                SetRange("No.", OrderNo);
                SetFilter("Delivery Route No.", DelRouteFilter);
                if not FindFirst then
                    exit;
            end;
        with PurchLine do begin
            SetRange("Document Type", "Document Type"::"Return Order");
            SetRange("Document No.", OrderNo);
            SetRange(Type, Type::Item);
            SetFilter("No.", '<>%1', '');
            SetFilter("Outstanding Qty. (Base)", '>0');
            SetRange("Location Code", Location.Code); // xxx
            if FindSet then
                repeat
                    Item.Get("No.");
                    // P8001083
                    if Item."Item Tracking Code" <> '' then
                        TransactionType := 2
                    else
                        TransactionType := 0;
                    // P8001083
                    if Item.Find then begin
                        // P8000706
                        if Item."Replenishment UOM Code" = '' then begin
                            "Unit of Measure Code" := Item."Base Unit of Measure";
                            "Outstanding Quantity" := "Outstanding Qty. (Base)"
                        end else begin
                            "Unit of Measure Code" := Item."Replenishment UOM Code";
                            ItemUOM.Get("No.", "Unit of Measure Code");
                            "Outstanding Quantity" := "Outstanding Qty. (Base)" / ItemUOM."Qty. per Unit of Measure";
                        end;
                        // P8000706
                        InsertReplQty(
                          Location.Code, Location."Shipment Bin Code (1-Doc)", "No.",
                          "Variant Code", TransactionType, 0, "Unit of Measure Code", "Outstanding Quantity"); // P8000706, P8001083
                        InsertItemTrkgSuggestions(
                          Location.Code, DATABASE::"Purchase Line", "Document Type",
                          "Document No.", 0, "Line No.", "Outstanding Quantity"); // P8000706
                        if BuildOrderDetail then begin
                            MarkedPurchLine := PurchLine;
                            MarkedPurchLine.Mark(true);
                        end;
                    end;
                until (Next = 0);
        end;
    end;

    local procedure BuildTransOrderRepl(var Location: Record Location; var Item: Record Item; OrderNo: Code[20]; DelRouteFilter: Code[80]; BuildOrderDetail: Boolean)
    var
        TransHeader: Record "Transfer Header";
        TransLine: Record "Transfer Line";
        ItemUOM: Record "Item Unit of Measure";
        TransactionType: Integer;
    begin
        // P8000631A
        if (DelRouteFilter <> '') then
            // P8001121
            // EXIT;
            with TransHeader do begin
                SetRange("No.", OrderNo);
                SetFilter("Delivery Route No.", DelRouteFilter);
                if not FindFirst then
                    exit;
            end;
        // P8001121
        with TransLine do begin
            SetRange("Document No.", OrderNo);
            SetRange(Type, Type::Item);
            SetFilter("Item No.", '<>%1', '');
            SetFilter("Outstanding Qty. (Base)", '>0');
            SetRange("Transfer-from Code", Location.Code); // xxx
            if FindSet then
                repeat
                    Item.Get("Item No.");
                    // P8001083
                    if Item."Item Tracking Code" <> '' then
                        TransactionType := 3
                    else
                        TransactionType := 0;
                    // P8001083
                    if Item.Find then begin
                        // P8000706
                        if Item."Replenishment UOM Code" = '' then begin
                            "Unit of Measure Code" := Item."Base Unit of Measure";
                            "Outstanding Quantity" := "Outstanding Qty. (Base)"
                        end else begin
                            "Unit of Measure Code" := Item."Replenishment UOM Code";
                            ItemUOM.Get("Item No.", "Unit of Measure Code");
                            "Outstanding Quantity" := "Outstanding Qty. (Base)" / ItemUOM."Qty. per Unit of Measure";
                        end;
                        // P8000706
                        InsertReplQty(
                          Location.Code, Location."Shipment Bin Code (1-Doc)", "Item No.",
                          "Variant Code", TransactionType, 0, "Unit of Measure Code", "Outstanding Quantity"); // P8000706, P8001083
                        InsertItemTrkgSuggestions(
                          Location.Code, DATABASE::"Transfer Line", 0,
                          "Document No.", 0, "Line No.", "Outstanding Quantity"); // P8000706
                        if BuildOrderDetail then begin
                            MarkedTransLine := TransLine;
                            MarkedTransLine.Mark(true);
                        end;
                    end;
                until (Next = 0);
        end;
    end;

    procedure GetReplSalesOrderDetail(GetFirstOrderDetail: Boolean; var SalesLine: Record "Sales Line"): Boolean
    begin
        // P8000631A
        with MarkedSalesLine do begin
            if GetFirstOrderDetail then begin
                MarkedOnly(true);
                if not FindSet then
                    exit(false);
            end else
                if (Next = 0) then
                    exit(false);
        end;
        SalesLine := MarkedSalesLine;
        exit(true);
    end;

    procedure GetReplPurchRetOrderDetail(GetFirstOrderDetail: Boolean; var PurchLine: Record "Purchase Line"): Boolean
    begin
        // P8000631A
        with MarkedPurchLine do begin
            if GetFirstOrderDetail then begin
                MarkedOnly(true);
                if not FindSet then
                    exit(false);
            end else
                if (Next = 0) then
                    exit(false);
        end;
        PurchLine := MarkedPurchLine;
        exit(true);
    end;

    procedure GetReplTransOrderDetail(GetFirstOrderDetail: Boolean; var TransLine: Record "Transfer Line"): Boolean
    begin
        // P8000631A
        with MarkedTransLine do begin
            if GetFirstOrderDetail then begin
                MarkedOnly(true);
                if not FindSet then
                    exit(false);
            end else
                if (Next = 0) then
                    exit(false);
        end;
        TransLine := MarkedTransLine;
        exit(true);
    end;

    procedure FindReplSalesOrderLine(var SalesLine: Record "Sales Line"): Boolean
    begin
        // P8000631A
        with SalesLine do
            if MarkedSalesLine.Get("Document Type", "Document No.", "Line No.") then
                exit(MarkedSalesLine.Mark);
        exit(false);
    end;

    procedure FindReplPurchRetOrderLine(var PurchLine: Record "Purchase Line"): Boolean
    begin
        // P8000631A
        with PurchLine do
            if MarkedPurchLine.Get("Document Type", "Document No.", "Line No.") then
                exit(MarkedPurchLine.Mark);
        exit(false);
    end;

    procedure FindReplTransOrderLine(var TransLine: Record "Transfer Line"): Boolean
    begin
        // P8000631A
        with TransLine do
            if MarkedTransLine.Get("Document No.", "Line No.") then
                exit(MarkedTransLine.Mark);
        exit(false);
    end;

    procedure VerifyLotFreshness(LotNo: Code[50]): Boolean
    var
        P800ItemTrack: Codeunit "Process 800 Item Tracking";
        P800Func: Codeunit "Process 800 Functions";
        SalesOrderLine: Record "Sales Line";
    begin
        // P8000899
        if not SalesOrderLine.Get(SalesOrderLine."Document Type"::Order, TempItemEntry."Source No.", TempItemEntry."Source Line No.") or
           not P800Func.TrackingInstalled or
           (LotNo = '')
        then
            exit(true);
        exit(P800ItemTrack.VerifySalesLotIsFresh(SalesOrderLine, LotNo, PickDate));
    end;

    procedure ConsolidateReplItemByTransType()
    var
        TempItemEntry2: Record "Warehouse Entry" temporary;
        TransTypeExists: array[3] of Boolean;
        TransType: Integer;
        Index: Integer;
    begin
        // P8001083
        with TempItemEntry do begin
            Reset;
            SetCurrentKey("Item No.", "Bin Code", "Location Code", "Variant Code");
            if Find('-') then
                repeat
                    Clear(TransTypeExists);
                    TransType := 0;
                    SetRange("Item No.", "Item No.");
                    for Index := 1 to 3 do begin
                        SetRange("Source Subtype", Index);
                        TransTypeExists[Index] := not IsEmpty;
                    end;
                    SetRange("Source Subtype");
                    case true of
                        TransTypeExists[1] and TransTypeExists[2] and TransTypeExists[3]:
                            if (LotStatusExclusionFilter[1] = LotStatusExclusionFilter[2]) and
                               (LotStatusExclusionFilter[1] = LotStatusExclusionFilter[3])
                            then
                                TransType := -1;
                        TransTypeExists[1] and TransTypeExists[2] and (not TransTypeExists[3]):
                            if (LotStatusExclusionFilter[1] = LotStatusExclusionFilter[2]) then
                                TransType := -1;
                        TransTypeExists[1] and (not TransTypeExists[2]) and TransTypeExists[3]:
                            if (LotStatusExclusionFilter[1] = LotStatusExclusionFilter[3]) then
                                TransType := -1;
                        TransTypeExists[1] and (not TransTypeExists[2]) and (not TransTypeExists[3]):
                            TransType := -1;
                        (not TransTypeExists[1]) and TransTypeExists[2] and TransTypeExists[3]:
                            if (LotStatusExclusionFilter[2] = LotStatusExclusionFilter[3]) then
                                TransType := -2;
                        (not TransTypeExists[1]) and TransTypeExists[2] and (not TransTypeExists[3]):
                            TransType := -2;
                        (not TransTypeExists[1]) and (not TransTypeExists[2]) and TransTypeExists[3]:
                            TransType := -3;
                    end;
                    if TransType <> 0 then begin
                        Find('-');
                        repeat
                            TempItemEntry2.Copy(TempItemEntry, true);
                            TempItemEntry2."Source Subtype" := TransType;
                            TempItemEntry2.Quantity := 0;
                            SetRange("Variant Code", "Variant Code");
                            repeat
                                TempItemEntry2.Quantity += Quantity;
                                Delete;
                            until Next = 0;
                            TempItemEntry2.Insert;
                            SetRange("Variant Code");
                        until Next = 0;
                    end;

                    Find('+');
                    SetRange("Item No.");
                until Next = 0;
        end;
    end;

    local procedure SetPreProcessReplBin(var ProdOrderComp: Record "Prod. Order Component")
    var
        PreProcessAct: Record "Pre-Process Activity";
        RegPreProcessAct: Record "Reg. Pre-Process Activity";
    begin
        // P8001082
        ClearPreProcessReplBin;
        with ProdOrderComp do begin
            PreProcessAct.SetCurrentKey("Prod. Order Status", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Comp. Line No.");
            PreProcessAct.SetRange("Prod. Order Status", Status);
            PreProcessAct.SetRange("Prod. Order No.", "Prod. Order No.");
            PreProcessAct.SetRange("Prod. Order Line No.", "Prod. Order Line No.");
            PreProcessAct.SetRange("Prod. Order Comp. Line No.", "Line No.");
            if PreProcessAct.FindFirst then
                PreProcessBinCode := PreProcessAct."From Bin Code"
            else begin
                RegPreProcessAct.SetCurrentKey("Prod. Order Status", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Comp. Line No.");
                RegPreProcessAct.SetRange("Prod. Order Status", Status);
                RegPreProcessAct.SetRange("Prod. Order No.", "Prod. Order No.");
                RegPreProcessAct.SetRange("Prod. Order Line No.", "Prod. Order Line No.");
                RegPreProcessAct.SetRange("Prod. Order Comp. Line No.", "Line No.");
                if RegPreProcessAct.FindFirst then
                    PreProcessBinCode := RegPreProcessAct."From-Bin Code";
            end;
            if (PreProcessBinCode <> '') or ("Pre-Process Type Code" <> '') then
                PreProcessRefDoc := PreProcessRefDoc::Required;
        end;
    end;

    local procedure ClearPreProcessReplBin()
    begin
        // P8001082
        Clear(PreProcessRefDoc);
        Clear(PreProcessBinCode);
    end;

    procedure IsPreProcessReplBin(): Boolean
    begin
        exit(PreProcessRefDoc <> PreProcessRefDoc::None); // P8001082
    end;

    procedure GetPreProcessReplBin(): Code[20]
    begin
        exit(PreProcessBinCode); // P8001082
    end;

    procedure CreatePreProcessReplTrkg(var ItemJnlLine: Record "Item Journal Line")
    var
        ItemJnlLine2: Record "Item Journal Line";
    begin
        // P8001082
        with ItemJnlLine do begin
            TempPreProcessBin.Reset;
            TempPreProcessBin.SetCurrentKey("Item No.", "Location Code", "Variant Code");
            TempPreProcessBin.SetRange("Location Code", "Location Code");
            TempPreProcessBin.SetRange("Item No.", "Item No.");
            TempPreProcessBin.SetRange("Variant Code", "Variant Code");
            if TempPreProcessBin.FindSet then
                repeat
                    CreateReservEntry.CreateReservEntryFor(
                      DATABASE::"Item Journal Line", "Entry Type", "Journal Template Name", "Journal Batch Name", 0,
                      "Line No.", "Qty. per Unit of Measure", TempPreProcessBin.Quantity, TempPreProcessBin."Qty. (Base)", // P8001132
                      '', TempPreProcessBin."Lot No.");
                    ItemJnlLine2."Lot No." := TempPreProcessBin."Lot No.";         // P800144605
                    CreateReservEntry.SetNewTrackingFromItemJnlLine(ItemJnlLine2); // P800144605
                    CreateReservEntry.CreateEntry(
                      "Item No.", "Variant Code", "Location Code", Description, 0D, "Posting Date", 0, 3);
                    GetLotNo;
                    GetNewLotNo;
                    Modify;
                until (TempPreProcessBin.Next = 0);
        end;
    end;

    local procedure InsertRegPreProcess(LocationCode: Code[10]; var ProdOrderComp: Record "Prod. Order Component"; ReplBinCode: Code[20])
    var
        RegPreProcessAct: Record "Reg. Pre-Process Activity";
        RegPreProcessActLine: Record "Reg. Pre-Process Activity Line";
        PreProcessAct: Record "Pre-Process Activity";
        BinQty: Decimal;
        BinQtyBase: Decimal;
    begin
        // P8001082
        with RegPreProcessAct do begin
            SetCurrentKey("Prod. Order Status", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Comp. Line No.");
            SetRange("Prod. Order Status", ProdOrderComp.Status);
            SetRange("Prod. Order No.", ProdOrderComp."Prod. Order No.");
            SetRange("Prod. Order Line No.", ProdOrderComp."Prod. Order Line No.");
            SetRange("Prod. Order Comp. Line No.", ProdOrderComp."Line No.");
            if FindSet then
                repeat
                    PreProcessAct.TransferFields(RegPreProcessAct);
                    RegPreProcessActLine.SetRange("Activity No.", "No.");
                    RegPreProcessActLine.SetFilter("Qty. Processed (Base)", '<>0');
                    if RegPreProcessActLine.FindSet then
                        repeat
                            GetRegPreProcessLineQtys(RegPreProcessAct, RegPreProcessActLine, BinQty, BinQtyBase);
                            AddRegPreProcess(
                              TempPreProcessBinAvail, TempPreProcessBinAvailNo, LocationCode, ReplBinCode,
                              "Item No.", "Variant Code", "Unit of Measure Code", RegPreProcessActLine."Lot No.", BinQty, BinQtyBase);
                            AddRegPreProcess(
                              TempPreProcessBin, TempPreProcessBinNo, LocationCode, PreProcessBinCode,
                              "Item No.", "Variant Code", "Unit of Measure Code", RegPreProcessActLine."Lot No.",
                              RegPreProcessActLine."Quantity Processed", RegPreProcessActLine."Qty. Processed (Base)");
                        until (RegPreProcessActLine.Next = 0);
                until (Next = 0);
        end;
        ClearPreProcessReplBin;
    end;

    local procedure GetRegPreProcessLineQtys(var RegPreProcessAct: Record "Reg. Pre-Process Activity"; var RegPreProcessActLine: Record "Reg. Pre-Process Activity Line"; var BinQty: Decimal; var BinQtyBase: Decimal)
    var
        WhseEntry: Record "Warehouse Entry";
        Location: Record Location;
        LocType: Integer;
    begin
        // P8001082
        BinQty := RegPreProcessActLine."Quantity Processed";
        BinQtyBase := RegPreProcessActLine."Qty. Processed (Base)";
        with WhseEntry do begin
            SetCurrentKey("Source Type", "Source Subtype", "Source No.");
            SetRange("Source Type", DATABASE::"Pre-Process Activity Line");
            SetRange("Source No.", RegPreProcessActLine."Activity No.");
            SetRange("Source Line No.", RegPreProcessActLine."Line No.");
            SetRange(Open, true);
            if not IsEmpty then begin
                Location.Get(RegPreProcessAct."Location Code");
                LocType := Location.LocationType();
                FindSet;
                repeat
                    BinQtyBase -= "Remaining Qty. (Base)";
                    if (LocType = 3) then
                        BinQty -= "Remaining Quantity";
                until (Next = 0);
                if (LocType <> 3) then
                    BinQty := BinQtyBase / RegPreProcessAct."Qty. per Unit of Measure";
            end;
        end;
    end;

    local procedure AddRegPreProcess(var TempRegPreProcess: Record "Warehouse Entry" temporary; var TempRegPreProcessNo: Integer; LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UOMCode: Code[10]; LotNo: Code[50]; Qty: Decimal; QtyBase: Decimal)
    begin
        // P8001082
        with TempRegPreProcess do begin
            SetRange("Location Code", LocationCode);
            SetRange("Item No.", ItemNo);
            SetRange("Variant Code", VariantCode);
            SetRange("Unit of Measure Code", UOMCode);
            SetRange("Lot No.", LotNo);
            SetRange("Bin Code", BinCode);
            if FindFirst then begin
                Quantity := Quantity + Qty;
                "Qty. (Base)" := "Qty. (Base)" + QtyBase;
                Modify;
            end else begin
                TempRegPreProcessNo := TempRegPreProcessNo + 1;
                "Entry No." := TempRegPreProcessNo;
                "Location Code" := LocationCode;
                "Item No." := ItemNo;
                "Variant Code" := VariantCode;
                "Unit of Measure Code" := UOMCode;
                "Lot No." := LotNo;
                "Bin Code" := BinCode;
                Quantity := Qty;
                "Qty. (Base)" := QtyBase;
                Insert;
            end;
            SetRange("Lot No.");
        end;
    end;

    local procedure ClearRegPreProcesses(var TempRegPreProcess: Record "Warehouse Entry" temporary; var TempRegPreProcessNo: Integer)
    begin
        // P8001082
        with TempRegPreProcess do begin
            Reset;
            DeleteAll;
            SetCurrentKey("Item No.", "Location Code", "Variant Code");
        end;
        TempRegPreProcessNo := 0;
    end;

    local procedure GetPreProcessPicks(var PicksSuggested: Boolean; LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; var TempBinSuggestion: Record "Warehouse Entry" temporary): Boolean
    begin
        // P8001082
        with TempPreProcessBin do begin
            Reset;
            SetCurrentKey("Item No.", "Location Code", "Variant Code");
            SetRange("Location Code", LocationCode);
            SetRange("Item No.", ItemNo);
            SetRange("Variant Code", VariantCode);
            if FindSet then begin
                repeat
                    TempBinSuggestion := TempPreProcessBin;
                    TempBinSuggestion.Insert;
                until (Next = 0);
                DeleteAll;
            end;
        end;
        PicksSuggested := TempBinSuggestion.FindSet;
        exit(PicksSuggested);
    end;

    local procedure UpdatePreProcessQtyAvail()
    var
        LotQty: Decimal;
        LotRatio: Decimal;
    begin
        // P8001082
        with TempPreProcessBinAvail do begin
            Reset;
            SetCurrentKey("Item No.", "Bin Code", "Location Code", "Variant Code");
            if FindSet then
                repeat
                    if ("Qty. (Base)" <= 0) then
                        Delete
                    else begin
                        TempPreProcessBin.Get("Entry No.");
                        if ("Qty. (Base)" >= TempPreProcessBin."Qty. (Base)") then
                            TempPreProcessBin.Delete
                        else begin
                            TempPreProcessBin.Quantity -= Quantity;
                            TempPreProcessBin."Qty. (Base)" -= "Qty. (Base)";
                            TempPreProcessBin.Modify;
                        end;
                    end;
                until (Next = 0);
        end;
    end;

    procedure GetPreProcessQtyAvailBase(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]): Decimal
    begin
        // P8001082
        with TempPreProcessBinAvail do begin
            Reset;
            SetCurrentKey("Item No.", "Bin Code", "Location Code", "Variant Code");
            SetRange("Item No.", ItemNo);
            SetRange("Bin Code", BinCode);
            SetRange("Location Code", LocationCode);
            SetRange("Variant Code", VariantCode);
            CalcSums("Qty. (Base)");
            exit("Qty. (Base)");
        end;
    end;

    local procedure GetNextProdOrderLine(var ProdOrderLine: Record "Prod. Order Line"; var SharedComponents: Boolean; var TempCoProductOrder: Record "Prod. Order Line" temporary): Boolean
    var
        ProdOrder: Record "Production Order";
    begin
        // P8001130
        if not SharedComponents then begin
            ProdOrder.Get(ProdOrderLine.Status, ProdOrderLine."Prod. Order No.");
            if ProdOrder."Family Process Order" then begin
                TempCoProductOrder := ProdOrderLine;
                TempCoProductOrder."Line No." := 0;
                if not TempCoProductOrder.Find then
                    TempCoProductOrder.Insert;
            end;
            if (ProdOrderLine.Next <> 0) then
                exit(true);
            if TempCoProductOrder.FindSet then begin
                ProdOrderLine := TempCoProductOrder;
                SharedComponents := true;
                exit(true);
            end;
        end else begin
            if (TempCoProductOrder.Next <> 0) then begin
                ProdOrderLine := TempCoProductOrder;
                exit(true);
            end;
        end;
    end;

    procedure SetPickBinOverride(RecvBin: Boolean; OutputBin: Boolean)
    begin
        // P8001278
        AllowPickFromRecvBin := RecvBin;
        AllowPickFromOutputBin := OutputBin;
    end;
}

