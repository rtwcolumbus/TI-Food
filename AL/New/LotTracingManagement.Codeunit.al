codeunit 37002025 "Lot Tracing Management"
{
    // PRW16.00.05
    // P8000979, Columbus IT, Don Bresee, 09 SEP 11
    //   Add Lot Tracing to Enhanced Lot Tracking granule
    // 
    // P8000984, Columbus IT, Don Bresee, 18 OCT 11
    //   Add Multiple Lot Trace
    // 
    // PRW16.00.06
    // P8001028, Columbus IT, Jack Reynolds, 27 JAN 12
    //   Fix problem tracing through production orders with alternate quantities
    // 
    // PRW17.00
    // P8001134, Columbus IT, Don Bresee, 21 FEB 13
    //   Add logic for handling of new "Order Type" options
    // 
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10.01
    // P8001248, Columbus IT, Jack Reynolds, 13 DEC 13
    //   Fix problem tracing transfer for average cost items
    // 
    // PRW110.0.01
    // P80045381, To-Increase, Dayakar Battini, 07 AUG 17
    //   Item filtering added to fix the multi items single lot no issue
    // 
    // PRW110.0.02
    // P80051648, To-Increase, Jack Reynolds, 06 FEB 18
    //   Remove incorrect fix from P80045381
    // 
    // PRW111.00.01
    // P80060769, To-Increase, Jack Reynolds, 01 AUG 18
    //   Fix problem with inconsistencies with the trace quantity
    // 
    // PRW111.00.02
    // P80069192, To-Increase, Gangabhushan, 17 JAN 19
    //   TI-12629 - Lot Tracing Fails With Insufficient Memory Error
    // 
    // P80069257, To-Increase, Gangabhushan, 21 JAN 19
    //   TI-12630 - Lot Tracing Incorrectly Reports Negative Adjustment Repack Entries in Lot Destination
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW111.00.03
    // P80074332, To-Increase, Gangabhushan, 18 JUL 19
    //   Lot tracing performance improvements
    // 
    // P80081511, To-Increase, Gangabhushan, 18 SEP 19
    //   CS00071677-Lot tracing performance improvements Source part side


    trigger OnRun()
    begin
    end;

    var
        Item: Record Item;
        LotInfo: Record "Lot No. Information";
        InvtSetup: Record "Inventory Setup";
        TempSourceEntryNo: Record "Integer" temporary;
        TempDestEntryNo: Record "Integer" temporary;
        TempLotBufEntryNo: Integer;
        TempSourceBufEntryNo: Integer;
        TempDestBufEntryNo: Integer;
        TempAdjustedEntry: Record "Item Ledger Entry" temporary;
        TempProdTotal: Record "Prod. Order Line" temporary;
        TempOutpEntry: Record "Item Ledger Entry" temporary;
        TempConsEntry: Record "Item Ledger Entry" temporary;
        CoProdMgmt: Codeunit "Co-Product Cost Management";
        StatusWindow: Dialog;
        StatusWindowOpen: Boolean;
        StatusWindowUpdateTime: DateTime;
        Text000: Label 'Tracing Lot...\Item No. #1##################\Lot No.  #2##################';
        TempItemLedgerStack: Record "Lot Tracing Buffer" temporary;
        TempItemTracingBuffer: array[2] of Record "Lot Tracing Buffer" temporary;


    [Obsolete('Replaced by overload using Lot Tracing Buffer.', '17.0')]
    procedure GetLotTrace(var TraceLotInfo: Record "Lot No. Information"; var TempSourceBuf: Record "Item Tracing Buffer" temporary; var TempDestBuf: Record "Item Tracing Buffer" temporary; var TotalPos: Decimal; var TotalNeg: Decimal)
    begin
    end;

    procedure GetLotTrace(var TraceLotInfo: Record "Lot No. Information"; var TempSourceBuf: Record "Lot Tracing Buffer" temporary; var TempDestBuf: Record "Lot Tracing Buffer" temporary; var TotalPos: Decimal; var TotalNeg: Decimal)
    var
        TempLotBuf: Record "Lot Tracing Buffer" temporary;
    begin
        StartLotTrace(TempLotBuf, TempSourceBuf, TempDestBuf);
        AddLotToTrace(TraceLotInfo, TempLotBuf, TempSourceBuf, TempDestBuf, TotalPos, TotalNeg);
        OnAfterGetLotTrace2(TraceLotInfo, TempLotBuf, TempSourceBuf, TempDestBuf, TotalPos, TotalNeg); // P80060769
    end;


    [Obsolete('Replaced by overload using Lot Tracing Buffer.', '17.0')]
    procedure StartLotTrace(var TempLotBuf: Record "Item Tracing Buffer" temporary; var TempSourceBuf: Record "Item Tracing Buffer" temporary; var TempDestBuf: Record "Item Tracing Buffer" temporary)
    begin
    end;        

    procedure StartLotTrace(var TempLotBuf: Record "Lot Tracing Buffer" temporary; var TempSourceBuf: Record "Lot Tracing Buffer" temporary; var TempDestBuf: Record "Lot Tracing Buffer" temporary)
    begin
        ClearAll;
        InvtSetup.Get;
        TempLotBuf.Reset;
        TempLotBuf.DeleteAll;
        TempSourceBuf.Reset;
        TempSourceBuf.DeleteAll;
        TempDestBuf.Reset;
        TempDestBuf.DeleteAll;
        StatusWindowUpdateTime := CurrentDateTime;
    end;

    [Obsolete('Replaced by overload using Lot Tracing Buffer.', '17.0')]
    procedure AddLotToTrace(var TraceLotInfo: Record "Lot No. Information"; var TempLotBuf: Record "Item Tracing Buffer" temporary; var TempSourceBuf: Record "Item Tracing Buffer" temporary; var TempDestBuf: Record "Item Tracing Buffer" temporary; var TotalPos: Decimal; var TotalNeg: Decimal)
    begin        
    end;

    procedure AddLotToTrace(var TraceLotInfo: Record "Lot No. Information"; var TempLotBuf: Record "Lot Tracing Buffer" temporary; var TempSourceBuf: Record "Lot Tracing Buffer" temporary; var TempDestBuf: Record "Lot Tracing Buffer" temporary; var TotalPos: Decimal; var TotalNeg: Decimal)
    var
        TempInitialEntry: Record "Item Ledger Entry" temporary;
    begin
        LotInfo := TraceLotInfo;
        GetOriginalLotEntries(TempInitialEntry, TotalPos, TotalNeg);
        ClearStack; // P80081511
        GetSourceBuf(TempInitialEntry, TempSourceBuf);
        ClearStack; // P80081511 
        GetDestBuf(TempInitialEntry, TempDestBuf);
        MergeTraceLotAdjmts(TempSourceBuf, TempDestBuf, TotalPos, TotalNeg);
        AddTempLotBuf(TraceLotInfo, TempLotBuf, TotalPos, TotalNeg);
    end;

    local procedure AddTempLotBuf(var TraceLotInfo: Record "Lot No. Information"; var TempLotBuf: Record "Lot Tracing Buffer" temporary; var TotalPos: Decimal; var TotalNeg: Decimal)
    begin
        with TempLotBuf do begin
            TempLotBufEntryNo := TempLotBufEntryNo + 1;
            "Line No." := TempLotBufEntryNo;
            "Item No." := TraceLotInfo."Item No.";
            "Variant Code" := TraceLotInfo."Variant Code";
            "Lot No." := TraceLotInfo."Lot No.";
            Quantity := TotalPos;
            "Remaining Quantity" := TotalPos + TotalNeg;
            Insert;
        end;
    end;

    local procedure GetOriginalLotEntries(var TempInitialEntry: Record "Item Ledger Entry" temporary; var TotalPos: Decimal; var TotalNeg: Decimal)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemLedgEntryQty: Decimal;
        TotalRem: Decimal;
        TotalRemAlt: Decimal;
    begin
        TotalPos := 0;
        with ItemLedgEntry do begin
            SetCurrentKey("Item No.", "Variant Code", "Lot No.");
            SetRange("Item No.", LotInfo."Item No.");
            SetRange("Variant Code", LotInfo."Variant Code");
            SetRange("Lot No.", LotInfo."Lot No.");
            SetRange(Positive, true);
            if FindSet then
                repeat
                    if IsOriginalLotEntry(ItemLedgEntry) then
                        if LoadItemEntry(ItemLedgEntry, ItemLedgEntryQty) then begin
                            TempInitialEntry := ItemLedgEntry;
                            TempInitialEntry.Insert;
                            TotalPos := TotalPos + ItemLedgEntryQty;
                        end;
                    TotalRem := TotalRem + GetLedgTraceRemQty(ItemLedgEntry);
                until (Next = 0);
        end;
        TotalNeg := -(TotalPos - TotalRem);
    end;

    local procedure IsOriginalLotEntry(var ItemLedgEntry: Record "Item Ledger Entry"): Boolean
    var
        ItemApplEntry: Record "Item Application Entry";
        FromLedgEntry: Record "Item Ledger Entry";
    begin
        with ItemLedgEntry do
            if Positive and ("Entry Type" <> "Entry Type"::Consumption) then begin
                if not FindPosSourceAppl("Entry No.", ItemApplEntry) then
                    exit(true);
                FromLedgEntry.Get(ItemApplEntry."Outbound Item Entry No.");
                exit((FromLedgEntry."Item No." <> "Item No.") or
                     (FromLedgEntry."Variant Code" <> "Variant Code") or
                     (FromLedgEntry."Lot No." <> "Lot No."));
            end;
    end;

    local procedure GetSourceBuf(var TempInitialEntry: Record "Item Ledger Entry" temporary; var TempSourceBuf: Record "Lot Tracing Buffer" temporary)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemLedgEntryQty: Decimal;
    begin
        with TempInitialEntry do
            if FindSet then
                repeat
                    GetItemEntry("Entry No.", ItemLedgEntry, ItemLedgEntryQty);
                    AddSourcePosEntry(ItemLedgEntry, ItemLedgEntryQty, 1, TempSourceBuf);
                until (Next = 0);
        TempSourceBuf.Reset;
    end;

    local procedure AddSourcePosEntry(var InboundEntry: Record "Item Ledger Entry"; InboundEntryQty: Decimal; SourceFactor: Decimal; var TempSourceBuf: Record "Lot Tracing Buffer" temporary)
    var
        ItemApplEntry: Record "Item Application Entry";
        OutboundEntry: Record "Item Ledger Entry";
        OutboundEntryQty: Decimal;
    begin
        with InboundEntry do begin
            // P80081511
            if EntryAlreadyProcessed(0, InboundEntry, TempSourceBuf, SourceFactor) then
                exit;
            // P80081511
            UpdateStatus;
            case "Entry Type" of
                "Entry Type"::Output:
                    AddSourceOutpEntry(InboundEntry, SourceFactor, TempSourceBuf);
                "Entry Type"::Consumption:
                    AddSourcePosConsEntry(InboundEntry, SourceFactor, TempSourceBuf);
                else
                    if not AddSourceBOMComponents(InboundEntry, SourceFactor, TempSourceBuf) then // P8001134
                        if not FindPosSourceAppl("Entry No.", ItemApplEntry) then
                            AddTempSourceBuf(InboundEntry, InboundEntryQty, SourceFactor, TempSourceBuf)
                        else begin
                            GetItemEntry(ItemApplEntry."Outbound Item Entry No.", OutboundEntry, OutboundEntryQty);
                            AddSourceNegEntry(
                              OutboundEntry, SourceFactor * (-InboundEntryQty / OutboundEntryQty), TempSourceBuf);
                        end;
            end;
            RemoveFromStack; // P80081511
        end;
    end;

    local procedure AddSourceOutpEntry(var OutpLedgEntry: Record "Item Ledger Entry"; SourceFactor: Decimal; var TempSourceBuf: Record "Lot Tracing Buffer" temporary)
    var
        ConsLedgEntry: Record "Item Ledger Entry";
    begin
        with ConsLedgEntry do begin
            SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type"); // P8001132
            SetRange("Order Type", "Order Type"::Production);                       // P8001132
            SetRange("Order No.", OutpLedgEntry."Order No.");                       // P8001132
            SetFilter("Order Line No.", '%1|0', OutpLedgEntry."Order Line No.");     // P8001132
            SetRange("Entry Type", "Entry Type"::Consumption);
            SetRange(Positive, false);
            if not FindSet then
                AddTempSourceBuf(OutpLedgEntry, GetLedgTraceQty(OutpLedgEntry), SourceFactor, TempSourceBuf)
            else
                repeat
                    AddSourceNegEntry(
                      ConsLedgEntry,
                      SourceFactor * GetLotConsFactor(ConsLedgEntry) * GetOutputFactor(ConsLedgEntry, OutpLedgEntry), TempSourceBuf);
                until (Next = 0);
        end;
    end;

    local procedure AddSourcePosConsEntry(var PosConsLedgEntry: Record "Item Ledger Entry"; SourceFactor: Decimal; var TempSourceBuf: Record "Lot Tracing Buffer" temporary)
    var
        ConsLedgEntry: Record "Item Ledger Entry";
        ConsLedgEntryQty: Decimal;
        TotalNegQty: Decimal;
    begin
        SetLotConsFilter(ConsLedgEntry, PosConsLedgEntry);
        with ConsLedgEntry do begin
            SetRange(Positive, false);
            if not FindSet then
                AddTempSourceBuf(PosConsLedgEntry, GetLedgTraceQty(PosConsLedgEntry), SourceFactor, TempSourceBuf)
            else begin
                TotalNegQty := GetNegLotConsQty(PosConsLedgEntry);
                SourceFactor := SourceFactor * (GetLedgTraceQty(PosConsLedgEntry) / TotalNegQty);
                repeat
                    if LoadItemEntry(ConsLedgEntry, ConsLedgEntryQty) then
                        //AddSourceNegEntry(ConsLedgEntry,SourceFactor * (-ConsLedgEntryQty / TotalNegQty),TempSourceBuf);
                        AddSourceNegEntry(ConsLedgEntry, SourceFactor, TempSourceBuf); // P80060769
                until (Next = 0);
            end;
        end;
    end;

    local procedure AddSourceNegEntry(var OutboundEntry: Record "Item Ledger Entry"; SourceFactor: Decimal; var TempSourceBuf: Record "Lot Tracing Buffer" temporary)
    var
        OutboundEntryQty: Decimal;
        ItemApplEntry: Record "Item Application Entry";
        InboundEntry: Record "Item Ledger Entry";
        InboundEntryQty: Decimal;
    begin
        if LoadItemEntry(OutboundEntry, OutboundEntryQty) and (SourceFactor <> 0) then
            // P80081511
            if EntryAlreadyProcessed(0, OutboundEntry, TempSourceBuf, SourceFactor) then
                exit
            else
                if FindNegSourceAppls(OutboundEntry."Entry No.", ItemApplEntry) then
                    // P80081511
                    with ItemApplEntry do
                        repeat
                            if GetItemEntry("Inbound Item Entry No.", InboundEntry, InboundEntryQty) then
                                if not IsReversingEntryAppl(InboundEntry, OutboundEntry) then
                                    AddSourcePosEntry(
                                      InboundEntry, InboundEntryQty,
                                      SourceFactor * (-GetApplTraceQty(OutboundEntry, ItemApplEntry) / InboundEntryQty), TempSourceBuf);
                        until (Next = 0);
        RemoveFromStack; // P80081511
    end;

    local procedure AddTempSourceBuf(var ItemLedgEntry: Record "Item Ledger Entry"; ItemLedgEntryQty: Decimal; SourceFactor: Decimal; var TempSourceBuf: Record "Lot Tracing Buffer" temporary)
    begin
        if (SourceFactor <> 0) and (ItemLedgEntryQty <> 0) then
            with TempSourceBuf do begin
                if FindTempTracingBuf(ItemLedgEntry, TempSourceBuf, false) then begin
                    Quantity := Quantity + GetSourceEntryQty(ItemLedgEntry);
                    "Trace Quantity" := "Trace Quantity" + (SourceFactor * ItemLedgEntryQty);
                    UpdateTempTracingBuf(TempSourceBuf);
                end else begin
                    TempSourceBufEntryNo := TempSourceBufEntryNo + 1;
                    "Line No." := TempSourceBufEntryNo;
                    Quantity := GetSourceEntryQty(ItemLedgEntry);
                    "Trace Quantity" := SourceFactor * ItemLedgEntryQty;
                    Insert;
                end;
                UpdateTempItemTracingBuffer("Line No.", (SourceFactor * ItemLedgEntryQty)); // P80081511
            end;
    end;

    local procedure GetSourceEntryQty(var ItemLedgEntry: Record "Item Ledger Entry"): Decimal
    begin
        if not TempSourceEntryNo.Get(ItemLedgEntry."Entry No.") then begin
            TempSourceEntryNo.Number := ItemLedgEntry."Entry No.";
            TempSourceEntryNo.Insert;
            exit(GetLedgTraceQty(ItemLedgEntry));
        end;
    end;

    local procedure GetDestBuf(var TempInitialEntry: Record "Item Ledger Entry" temporary; var TempDestBuf: Record "Lot Tracing Buffer" temporary)
    begin
        with TempInitialEntry do
            if FindSet then
                repeat
                    AddDestPosEntry("Entry No.", GetLedgTraceQty(TempInitialEntry), TempDestBuf);
                until (Next = 0);
        TempDestBuf.Reset;
    end;

    local procedure AddDestPosEntry(InboundEntryNo: Integer; SourceQty: Decimal; var TempDestBuf: Record "Lot Tracing Buffer" temporary)
    var
        InboundEntry: Record "Item Ledger Entry";
        InboundEntryQty: Decimal;
        InboundEntryRemQty: Decimal;
        ItemApplEntry: Record "Item Application Entry";
        OutboundEntry: Record "Item Ledger Entry";
        OutboundEntryQty: Decimal;
    begin
        if GetItemEntry(InboundEntryNo, InboundEntry, InboundEntryQty) and (SourceQty <> 0) then
            with InboundEntry do begin
                // P80074332
                if EntryAlreadyProcessed(1, InboundEntry, TempDestBuf, SourceQty) then
                    exit;
                // P80074332
                UpdateStatus;
                InboundEntryRemQty := GetLedgTraceRemQty(InboundEntry);
                if (InboundEntryRemQty <> 0) then
                    AddTempDestBuf(InboundEntry, SourceQty * (InboundEntryRemQty / InboundEntryQty), TempDestBuf, true);
                if (InboundEntryQty <> InboundEntryRemQty) then
                    if FindPosDestAppls("Entry No.", ItemApplEntry) then
                        repeat
                            if GetItemEntry(ItemApplEntry."Outbound Item Entry No.", OutboundEntry, OutboundEntryQty) then
                                if not IsReversingEntryAppl(InboundEntry, OutboundEntry) then
                                    AddDestNegAppl(
                                      InboundEntryNo, OutboundEntry, OutboundEntryQty,
                                      SourceQty * (-GetApplTraceQty(InboundEntry, ItemApplEntry) / InboundEntryQty), TempDestBuf);
                        until (ItemApplEntry.Next = 0);
                RemoveFromStack; // P80074332
            end;
    end;

    local procedure AddDestNegAppl(InboundEntryNo: Integer; var OutboundEntry: Record "Item Ledger Entry"; OutboundEntryQty: Decimal; SourceQty: Decimal; var TempDestBuf: Record "Lot Tracing Buffer" temporary)
    var
        ItemApplEntry: Record "Item Application Entry";
        RevSourceQty: Decimal;
        TotalRevSourceQty: Decimal;
    begin
        with OutboundEntry do begin // P8001248
            // P80074332
            if EntryAlreadyProcessed(1, OutboundEntry, TempDestBuf, SourceQty) then
                exit;
            // P80074332
            GetItem("Item No.");
            if "Entry Type" = "Entry Type"::Consumption then
                // P8001248
                //CASE "Entry Type" OF
                //  "Entry Type"::Consumption :
                // P8001248
                AddDestNegConsEntry(OutboundEntry, SourceQty, TempDestBuf)
            // P8001248
            else
                if ("Entry Type" = "Entry Type"::Transfer) and (Item."Costing Method" <> Item."Costing Method"::Average) then begin
                    //  "Entry Type"::Transfer :
                    // P8001248
                    if FindNegDestAppls("Entry No.", ItemApplEntry, InboundEntryNo) then
                        AddDestPosEntry(ItemApplEntry."Inbound Item Entry No.", SourceQty, TempDestBuf)
                    else
                        AddTempDestBuf(OutboundEntry, SourceQty, TempDestBuf, false);
                end else // P8001248
                    if not AddDestBOMOutput(OutboundEntry, SourceQty, TempDestBuf) then begin // P8001134
                        if FindNegDestAppls("Entry No.", ItemApplEntry, 0) then begin
                            repeat
                                RevSourceQty :=
                                  SourceQty * (-GetApplTraceQty(OutboundEntry, ItemApplEntry) / OutboundEntryQty);
                                AddDestPosEntry(ItemApplEntry."Inbound Item Entry No.", RevSourceQty, TempDestBuf);
                                TotalRevSourceQty := TotalRevSourceQty + RevSourceQty;
                            until (ItemApplEntry.Next = 0);
                            SourceQty := SourceQty - TotalRevSourceQty;
                        end;
                        if (SourceQty <> 0) and (not OutboundEntry.IsBOMOrderType()) then // P80069257
                            AddTempDestBuf(OutboundEntry, SourceQty, TempDestBuf, false);
                    end;
            //END; // P8001248
            RemoveFromStack; // P80074332
        end;     // P8001248
    end;

    local procedure AddDestNegConsEntry(var ConsLedgEntry: Record "Item Ledger Entry"; SourceQty: Decimal; var TempDestBuf: Record "Lot Tracing Buffer" temporary)
    var
        OutpLedgEntry: Record "Item Ledger Entry";
        SourceQtyReversed: Decimal;
        PosConsLedgEntry: Record "Item Ledger Entry";
        PosConsLedgEntryQty: Decimal;
        TotalPosQty: Decimal;
    begin
        SourceQtyReversed := SourceQty * (1 - GetLotConsFactor(ConsLedgEntry));
        SourceQty := SourceQty - SourceQtyReversed;
        if (SourceQty <> 0) then
            with OutpLedgEntry do begin
                SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type"); // P8001132
                SetRange("Order Type", "Order Type"::Production);                       // P8001132
                SetRange("Order No.", ConsLedgEntry."Order No.");                       // P8001132
                if (ConsLedgEntry."Order Line No." <> 0) then                          // P8001132
                    SetRange("Order Line No.", ConsLedgEntry."Order Line No.");           // P8001132
                SetRange("Entry Type", "Entry Type"::Output);
                SetRange(Positive, true);
                if not FindSet then
                    AddTempDestBuf(ConsLedgEntry, SourceQty, TempDestBuf, false)
                else
                    repeat
                        AddDestPosEntry("Entry No.", SourceQty * GetOutputFactor(ConsLedgEntry, OutpLedgEntry), TempDestBuf);
                    until (Next = 0);
            end;
        if (SourceQtyReversed <> 0) then begin
            TotalPosQty := GetPosLotConsQty(ConsLedgEntry);
            SetLotConsFilter(PosConsLedgEntry, ConsLedgEntry);
            with PosConsLedgEntry do begin
                SetRange(Positive, true);
                FindSet;
                repeat
                    if LoadItemEntry(PosConsLedgEntry, PosConsLedgEntryQty) then
                        AddDestPosEntry("Entry No.", SourceQtyReversed * (PosConsLedgEntryQty / TotalPosQty), TempDestBuf);
                until (Next = 0);
            end;
        end;
    end;

    local procedure AddTempDestBuf(var ItemLedgEntry: Record "Item Ledger Entry"; SourceQty: Decimal; var TempDestBuf: Record "Lot Tracing Buffer" temporary; IsOnHand: Boolean)
    begin
        if (SourceQty <> 0) then
            with TempDestBuf do begin
                if FindTempTracingBuf(ItemLedgEntry, TempDestBuf, IsOnHand) then begin
                    Quantity := Quantity + GetDestEntryQty(ItemLedgEntry, IsOnHand);
                    "Trace Quantity" := "Trace Quantity" + SourceQty;
                    UpdateTempTracingBuf(TempDestBuf);
                end else begin
                    TempDestBufEntryNo := TempDestBufEntryNo + 1;
                    "Line No." := TempDestBufEntryNo;
                    Quantity := GetDestEntryQty(ItemLedgEntry, IsOnHand);
                    "Trace Quantity" := SourceQty;
                    Insert;
                end;
                UpdateTempItemTracingBuffer("Line No.", SourceQty); // P80074332
            end;
    end;

    local procedure GetDestEntryQty(var ItemLedgEntry: Record "Item Ledger Entry"; IsOnHand: Boolean) Qty: Decimal
    var
        ItemApplEntry: Record "Item Application Entry";
    begin
        with ItemLedgEntry do
            if not TempDestEntryNo.Get("Entry No.") then begin
                TempDestEntryNo.Number := "Entry No.";
                TempDestEntryNo.Insert;
                if IsOnHand then
                    Qty := GetLedgTraceRemQty(ItemLedgEntry)
                else begin
                    Qty := -GetLedgTraceQty(ItemLedgEntry);
                    if ("Entry Type" <> "Entry Type"::Transfer) then
                        if FindNegDestAppls("Entry No.", ItemApplEntry, 0) then
                            repeat
                                Qty := Qty - GetApplTraceQty(ItemLedgEntry, ItemApplEntry);
                            until (ItemApplEntry.Next = 0);
                end;
            end;
    end;

    local procedure MergeTraceLotAdjmts(var TempSourceBuf: Record "Lot Tracing Buffer" temporary; var TempDestBuf: Record "Lot Tracing Buffer" temporary; var TotalPos: Decimal; var TotalNeg: Decimal)
    var
        Qty: Decimal;
    begin
        FilterForTraceLotAdjmts(TempSourceBuf, TempSourceBuf."Entry Type"::"Positive Adjmt.");
        if TempSourceBuf.FindSet then begin
            GetItem(TempSourceBuf."Item No.");
            FilterForTraceLotAdjmts(TempDestBuf, TempDestBuf."Entry Type"::"Negative Adjmt.");
            repeat
                TempDestBuf.SetRange("Location Code", TempSourceBuf."Location Code");
                if TempDestBuf.FindFirst then
                    if (TempDestBuf.Quantity < TempSourceBuf.Quantity) then
                        Merge1TraceLotAdjmt(TempDestBuf, TempSourceBuf, TotalPos, TotalNeg)
                    else
                        Merge1TraceLotAdjmt(TempSourceBuf, TempDestBuf, TotalPos, TotalNeg);
            until (TempSourceBuf.Next = 0);
        end;
        TempSourceBuf.Reset;
        TempDestBuf.Reset;
    end;

    local procedure Merge1TraceLotAdjmt(var TempFromBuf: Record "Lot Tracing Buffer" temporary; var TempToBuf: Record "Lot Tracing Buffer" temporary; var TotalPos: Decimal; var TotalNeg: Decimal)
    begin
        with TempFromBuf do begin
            UpdateDocumentFields(TempToBuf, "Document No.", "Source Type", "Source No.");
            TotalPos := TotalPos - Quantity;
            TotalNeg := TotalNeg + Quantity;
            Delete;
        end;
        with TempToBuf do
            if (Quantity = TempFromBuf.Quantity) then
                Delete
            else begin
                Quantity := Quantity - TempFromBuf.Quantity;
                "Trace Quantity" := Quantity;
                Modify;
            end;
    end;

    local procedure FilterForTraceLotAdjmts(var TempBuf: Record "Lot Tracing Buffer" temporary; EntryType: Integer)
    begin
        with TempBuf do begin
            Reset;
            SetCurrentKey("Item No.", "Variant Code", "Lot No.", "Location Code", "Entry Type");
            SetRange("Item No.", LotInfo."Item No.");
            SetRange("Variant Code", LotInfo."Variant Code");
            SetRange("Lot No.", LotInfo."Lot No.");
            SetRange("Entry Type", EntryType);
        end;
    end;

    local procedure FindPosSourceAppl(InboundEntryNo: Integer; var ItemApplEntry: Record "Item Application Entry"): Boolean
    begin
        with ItemApplEntry do begin
            SetCurrentKey("Inbound Item Entry No.", "Item Ledger Entry No.");
            SetRange("Inbound Item Entry No.", InboundEntryNo);
            SetRange("Item Ledger Entry No.", InboundEntryNo);
            SetFilter("Outbound Item Entry No.", '<>0');
            exit(FindFirst);
        end;
    end;

    local procedure FindPosDestAppls(InboundEntryNo: Integer; var ItemApplEntry: Record "Item Application Entry"): Boolean
    begin
        with ItemApplEntry do begin
            SetCurrentKey("Inbound Item Entry No.", "Item Ledger Entry No.");
            SetRange("Inbound Item Entry No.", InboundEntryNo);
            SetFilter("Item Ledger Entry No.", '<>%1', InboundEntryNo);
            SetFilter("Outbound Item Entry No.", '<>0');
            exit(FindSet);
        end;
    end;

    local procedure FindNegSourceAppls(OutboundEntryNo: Integer; var ItemApplEntry: Record "Item Application Entry"): Boolean
    begin
        with ItemApplEntry do begin
            SetCurrentKey("Outbound Item Entry No.", "Item Ledger Entry No.");
            SetRange("Outbound Item Entry No.", OutboundEntryNo);
            SetRange("Item Ledger Entry No.", OutboundEntryNo);
            exit(FindSet);
        end;
    end;

    local procedure FindNegDestAppls(OutboundEntryNo: Integer; var ItemApplEntry: Record "Item Application Entry"; TransferredFromEntryNo: Integer): Boolean
    begin
        with ItemApplEntry do begin
            SetCurrentKey("Outbound Item Entry No.", "Item Ledger Entry No.");
            SetRange("Outbound Item Entry No.", OutboundEntryNo);
            SetFilter("Item Ledger Entry No.", '<>%1', OutboundEntryNo);
            if (TransferredFromEntryNo <> 0) then
                SetRange("Transferred-from Entry No.", TransferredFromEntryNo);
            exit(FindSet);
        end;
    end;

    local procedure GetItemEntry(ItemLedgEntryNo: Integer; var ItemLedgEntry: Record "Item Ledger Entry"; var ItemLedgEntryQty: Decimal): Boolean
    begin
        ItemLedgEntry.Get(ItemLedgEntryNo);
        exit(LoadItemEntry(ItemLedgEntry, ItemLedgEntryQty));
    end;

    local procedure LoadItemEntry(var ItemLedgEntry: Record "Item Ledger Entry"; var ItemLedgEntryQty: Decimal): Boolean
    begin
        AdjustItemEntry(ItemLedgEntry);
        ItemLedgEntryQty := GetLedgTraceQty(ItemLedgEntry);
        exit(ItemLedgEntryQty <> 0);
    end;

    local procedure AdjustItemEntry(var ItemLedgEntry: Record "Item Ledger Entry")
    var
        ItemApplEntry: Record "Item Application Entry";
        ApplLedgEntry: Record "Item Ledger Entry";
    begin
        if IsReversableEntryType(ItemLedgEntry) then
            with ItemLedgEntry do
                if TempAdjustedEntry.Get("Entry No.") then begin
                    Quantity := TempAdjustedEntry.Quantity;
                    "Quantity (Alt.)" := TempAdjustedEntry."Quantity (Alt.)";
                end else begin
                    if Positive then begin
                        if FindPosDestAppls("Entry No.", ItemApplEntry) then
                            repeat
                                ApplLedgEntry.Get(ItemApplEntry."Outbound Item Entry No.");
                                if IsReversingEntryAppl(ItemLedgEntry, ApplLedgEntry) then begin
                                    Quantity := Quantity + ItemApplEntry.Quantity;
                                    "Quantity (Alt.)" := "Quantity (Alt.)" + ItemApplEntry."Quantity (Alt.)";
                                end;
                            until (ItemApplEntry.Next = 0);
                    end else begin
                        if FindNegSourceAppls("Entry No.", ItemApplEntry) then
                            repeat
                                ApplLedgEntry.Get(ItemApplEntry."Inbound Item Entry No.");
                                if IsReversingEntryAppl(ApplLedgEntry, ItemLedgEntry) then begin
                                    Quantity := Quantity - ItemApplEntry.Quantity;
                                    "Quantity (Alt.)" := "Quantity (Alt.)" - ItemApplEntry."Quantity (Alt.)";
                                end;
                            until (ItemApplEntry.Next = 0);
                    end;
                    TempAdjustedEntry := ItemLedgEntry;
                    TempAdjustedEntry.Insert;
                end;
    end;

    local procedure IsReversableEntryType(var ItemLedgEntry: Record "Item Ledger Entry"): Boolean
    begin
        with ItemLedgEntry do
            exit("Entry Type" in ["Entry Type"::Purchase, "Entry Type"::Consumption, "Entry Type"::Output]);
    end;

    local procedure IsReversingEntryAppl(var PosLedgEntry: Record "Item Ledger Entry"; var NegLedgEntry: Record "Item Ledger Entry"): Boolean
    begin
        with PosLedgEntry do
            if ("Entry Type" = NegLedgEntry."Entry Type") then
                case "Entry Type" of
                    "Entry Type"::Purchase:
                        exit(("Document Type" <> 0) and (NegLedgEntry."Document Type" <> 0));
                    "Entry Type"::Consumption, "Entry Type"::Output:
                        exit(("Order Type" = NegLedgEntry."Order Type") and       // P8001132
                             ("Order No." = NegLedgEntry."Order No.") and         // P8001132
                             ("Order Line No." = NegLedgEntry."Order Line No.")); // P8001132
                end;
    end;

    local procedure GetOutputFactor(var ConsLedgEntry: Record "Item Ledger Entry"; var OutpLedgEntry: Record "Item Ledger Entry"): Decimal
    var
        ProdOrderLine: Record "Prod. Order Line";
        Qty: Decimal;
    begin
        AdjustItemEntry(OutpLedgEntry);
        with ConsLedgEntry do begin
            if not TempProdTotal.Get(0, "Order No.", "Order Line No.") then begin // P8001132
                TempProdTotal."Prod. Order No." := "Order No."; // P8001132
                TempProdTotal."Line No." := "Order Line No.";   // P8001132
                if ("Order Line No." = 0) then // P8001132
                    CoProdMgmt.GetTraceTotalQty(OutpLedgEntry, TempProdTotal.Quantity, TempProdTotal."Unit of Measure Code")
                else begin
                    if not ProdOrderLine.Get(ProdOrderLine.Status::Finished, "Order No.", "Order Line No.") then // P8001132
                        ProdOrderLine.Get(ProdOrderLine.Status::Released, "Order No.", "Order Line No.");          // P8001132
                    TempProdTotal.Quantity :=
                      SelectTraceQty(ProdOrderLine."Item No.", ProdOrderLine."Finished Quantity", ProdOrderLine."Finished Qty. (Alt.)"); // P8001028
                end;
                TempProdTotal.Insert;
            end;
            if (TempProdTotal.Quantity <> 0) then begin
                if not TempOutpEntry.Get(OutpLedgEntry."Entry No.") then begin
                    TempOutpEntry."Entry No." := OutpLedgEntry."Entry No.";
                    if ("Order Line No." = 0) then // P8001132
                        TempOutpEntry.Quantity := CoProdMgmt.GetTraceEntryQty(OutpLedgEntry, TempProdTotal."Unit of Measure Code")
                    else
                        TempOutpEntry.Quantity :=
                          SelectTraceQty(OutpLedgEntry."Item No.", OutpLedgEntry.Quantity, OutpLedgEntry."Quantity (Alt.)"); // P8001028
                    TempOutpEntry.Insert;
                end;
                exit(TempOutpEntry.Quantity / TempProdTotal.Quantity);
            end;
        end;
    end;

    local procedure GetLotConsFactor(var ConsLedgEntry: Record "Item Ledger Entry"): Decimal
    begin
        CalcLotConsTotals(ConsLedgEntry);
        if (TempConsEntry.Quantity <> 0) then
            exit(TempConsEntry."Quantity (Alt.)" / TempConsEntry.Quantity);
    end;

    local procedure GetNegLotConsQty(var ConsLedgEntry: Record "Item Ledger Entry"): Decimal
    begin
        CalcLotConsTotals(ConsLedgEntry);
        exit(TempConsEntry.Quantity);
    end;

    local procedure GetPosLotConsQty(var ConsLedgEntry: Record "Item Ledger Entry"): Decimal
    begin
        CalcLotConsTotals(ConsLedgEntry);
        exit(TempConsEntry.Quantity - TempConsEntry."Quantity (Alt.)");
    end;

    local procedure CalcLotConsTotals(var ConsLedgEntry: Record "Item Ledger Entry")
    var
        ProdConsEntry: Record "Item Ledger Entry";
        ProdConsEntryQty: Decimal;
    begin
        SetLotConsFilter(TempConsEntry, ConsLedgEntry);
        with TempConsEntry do
            if not FindFirst then begin
                TempConsEntry := ConsLedgEntry;
                "Quantity (Alt.)" := 0;
                Quantity := 0;
                SetLotConsFilter(ProdConsEntry, ConsLedgEntry);
                ProdConsEntry.FindSet;
                repeat
                    if LoadItemEntry(ProdConsEntry, ProdConsEntryQty) then begin
                        "Quantity (Alt.)" := "Quantity (Alt.)" - ProdConsEntryQty;
                        if not ProdConsEntry.Positive then
                            Quantity := Quantity - ProdConsEntryQty;
                    end;
                until (ProdConsEntry.Next = 0);
                Insert;
            end;
    end;

    local procedure SetLotConsFilter(var EntryToFilter: Record "Item Ledger Entry"; var ConsLedgEntry: Record "Item Ledger Entry")
    begin
        with EntryToFilter do begin
            SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type"); // P8001132
            SetRange("Order No.", ConsLedgEntry."Order No.");           // P8001132
            SetRange("Order Line No.", ConsLedgEntry."Order Line No."); // P8001132
            SetRange("Entry Type", "Entry Type"::Consumption);
            SetRange("Item No.", ConsLedgEntry."Item No.");
            SetRange("Variant Code", ConsLedgEntry."Variant Code");
            SetRange("Lot No.", ConsLedgEntry."Lot No.");
        end;
    end;

    local procedure FindTempTracingBuf(var ItemLedgEntry: Record "Item Ledger Entry"; var TempTracingBuf: Record "Lot Tracing Buffer" temporary; IsOnHand: Boolean) DataFound: Boolean
    begin
        with TempTracingBuf do begin
            Reset;
            SetCurrentKey("Item No.", "Variant Code", "Lot No.", "Location Code", "Entry Type");
            SetRange("Item No.", ItemLedgEntry."Item No.");
            SetRange("Variant Code", ItemLedgEntry."Variant Code");
            SetRange("Lot No.", ItemLedgEntry."Lot No.");
            SetRange("Location Code", ItemLedgEntry."Location Code");
            SetRange("Entry Type", GetDataEntryType(ItemLedgEntry, IsOnHand));
            if (InvtSetup."Lot Trace Summary Level" >= InvtSetup."Lot Trace Summary Level"::Source) then begin
                SetRange("Source Type", ItemLedgEntry."Source Type");
                SetRange("Source No.", ItemLedgEntry."Source No.");
            end else begin
                SetRange("Source Type");
                SetRange("Source No.");
            end;
            if (InvtSetup."Lot Trace Summary Level" >= InvtSetup."Lot Trace Summary Level"::Document) then
                SetRange("Document No.", ItemLedgEntry."Document No.")
            else
                SetRange("Document No.");
            DataFound := FindFirst;
            if DataFound then
                UpdateDocumentReference(ItemLedgEntry, TempTracingBuf)
            else begin
                Init;
                "Item No." := ItemLedgEntry."Item No.";
                "Variant Code" := ItemLedgEntry."Variant Code";
                "Lot No." := ItemLedgEntry."Lot No.";
                "Location Code" := ItemLedgEntry."Location Code";
                "Entry Type" := GetDataEntryType(ItemLedgEntry, IsOnHand);
                GetItem(ItemLedgEntry."Item No.");
                Description := Item.Description;
                InitDocumentFields(ItemLedgEntry, TempTracingBuf, GetDocumentReferenceNo(ItemLedgEntry));
            end;
        end;
    end;

    local procedure GetDataEntryType(var ItemLedgEntry: Record "Item Ledger Entry"; IsOnHand: Boolean): Integer
    var
        ItemTracingBuf: Record "Lot Tracing Buffer";
    begin
        if IsOnHand then
            exit(ItemTracingBuf."Entry Type"::Location);
        with ItemLedgEntry do
            case "Entry Type" of
                "Entry Type"::"Positive Adjmt.", "Entry Type"::"Negative Adjmt.":
                    if Positive then
                        exit(ItemTracingBuf."Entry Type"::"Positive Adjmt.")
                    else
                        exit(ItemTracingBuf."Entry Type"::"Negative Adjmt.");
                "Entry Type"::Purchase:
                    exit(ItemTracingBuf."Entry Type"::Purchase);
                "Entry Type"::Sale:
                    exit(ItemTracingBuf."Entry Type"::Sale);
                "Entry Type"::Consumption:
                    exit(ItemTracingBuf."Entry Type"::Consumption);
                "Entry Type"::Output:
                    exit(ItemTracingBuf."Entry Type"::Output);
            end;
    end;

    local procedure UpdateDocumentReference(var ItemLedgEntry: Record "Item Ledger Entry"; var TempTracingBuf: Record "Lot Tracing Buffer" temporary)
    var
        NewReferenceNo: Integer;
    begin
        NewReferenceNo := GetDocumentReferenceNo(ItemLedgEntry);
        if (NewReferenceNo <> 0) and (TempTracingBuf."Item Ledger Entry No." = 0) then
            InitDocumentFields(ItemLedgEntry, TempTracingBuf, NewReferenceNo)
        else
            if (NewReferenceNo <> 0) or (TempTracingBuf."Item Ledger Entry No." = 0) then
                with ItemLedgEntry do
                    UpdateDocumentFields(TempTracingBuf, "Document No.", "Source Type", "Source No.");
    end;

    local procedure GetDocumentReferenceNo(var ItemLedgEntry: Record "Item Ledger Entry"): Integer
    begin
        with ItemLedgEntry do begin
            if not Positive then
                exit("Entry No.");
            if IsOriginalLotEntry(ItemLedgEntry) then
                exit("Entry No.");
        end;
    end;

    local procedure InitDocumentFields(var ItemLedgEntry: Record "Item Ledger Entry"; var TempTracingBuf: Record "Lot Tracing Buffer" temporary; NewReferenceNo: Integer)
    begin
        with TempTracingBuf do begin
            "Item Ledger Entry No." := NewReferenceNo;
            "Document No." := ItemLedgEntry."Document No.";
            "Source Type" := ItemLedgEntry."Source Type";
            "Source No." := ItemLedgEntry."Source No.";
            "Source Name" := GetSourceName(TempTracingBuf);
        end;
    end;

    local procedure GetSourceName(var TempTracingBuf: Record "Lot Tracing Buffer" temporary): Text[100]
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        with TempTracingBuf do
            case "Source Type" of
                "Source Type"::Customer:
                    if Customer.Get("Source No.") then
                        exit(Customer.Name);
                "Source Type"::Vendor:
                    if Vendor.Get("Source No.") then
                        exit(Vendor.Name);
                "Source Type"::Item:
                    if ("Source No." <> "Item No.") then
                        if GetItem("Source No.") then
                            exit(Item.Description);
            end;
    end;

    local procedure UpdateDocumentFields(var TempTracingBuf: Record "Lot Tracing Buffer" temporary; DocNo: Code[20]; SourceType: Integer; SourceNo: Code[20])
    begin
        with TempTracingBuf do begin
            if ("Document No." <> DocNo) then
                "Document No." := '';
            if ("Source Type" <> SourceType) or ("Source No." <> SourceNo) then begin
                "Source Type" := 0;
                "Source No." := '';
                "Source Name" := '';
            end;
        end;
    end;

    local procedure UpdateTempTracingBuf(var TempTracingBuf: Record "Lot Tracing Buffer" temporary)
    begin
        with TempTracingBuf do
            if (Abs("Trace Quantity") < 0.000000000001) then
                Delete
            else
                Modify;
    end;

    local procedure GetItem(ItemNo: Code[20]): Boolean
    begin
        if (ItemNo = Item."No.") then
            exit(true);
        if Item.Get(ItemNo) then
            exit(true);
        Clear(Item);
    end;

    local procedure UpdateStatus()
    begin
        if ((CurrentDateTime - StatusWindowUpdateTime) > 500) then begin
            if not StatusWindowOpen then begin
                StatusWindow.Open(Text000);
                StatusWindowOpen := true;
            end;
            StatusWindow.Update(1, LotInfo."Item No.");
            StatusWindow.Update(2, LotInfo."Lot No.");
            StatusWindowUpdateTime := CurrentDateTime;
        end;
    end;

    procedure SelectTraceQty(ItemNo: Code[20]; Qty: Decimal; QtyAlt: Decimal): Decimal
    begin
        GetItem(ItemNo);
        if Item.TraceAltQty() then
            exit(QtyAlt);
        exit(Qty);
    end;

    procedure SelectTraceFactor(var ItemLedgEntry: Record "Item Ledger Entry"; TotalQty: Decimal; TotalQtyAlt: Decimal): Decimal
    begin
        with ItemLedgEntry do begin
            GetItem("Item No.");
            if Item.TraceAltQty() then begin
                if (TotalQtyAlt <> 0) then
                    exit("Quantity (Alt.)" / TotalQtyAlt);
            end else begin
                if (TotalQty <> 0) then
                    exit(Quantity / TotalQty);
            end;
        end;
    end;

    procedure GetLedgTraceQty(var ItemLedgEntry: Record "Item Ledger Entry"): Decimal
    begin
        with ItemLedgEntry do
            exit(SelectTraceQty("Item No.", Quantity, "Quantity (Alt.)"));
    end;

    procedure GetLedgTraceRemQty(var ItemLedgEntry: Record "Item Ledger Entry"): Decimal
    begin
        with ItemLedgEntry do
            exit(SelectTraceQty("Item No.", "Remaining Quantity", "Remaining Quantity (Alt.)"));
    end;

    procedure GetApplTraceQty(var ItemLedgEntry: Record "Item Ledger Entry"; var ItemApplEntry: Record "Item Application Entry"): Decimal
    begin
        exit(SelectTraceQty(ItemLedgEntry."Item No.", ItemApplEntry.Quantity, ItemApplEntry."Quantity (Alt.)"));
    end;

    [Obsolete('Replaced by overload using Lot Tracing Buffer.', '17.0')]
    procedure CopyTempPageBuf(var TempPageTracingBuf: Record "Item Tracing Buffer" temporary; var TempTracingBuf: Record "Item Tracing Buffer" temporary)
    begin 
    end;

    procedure CopyTempPageBuf(var TempPageTracingBuf: Record "Lot Tracing Buffer" temporary; var TempTracingBuf: Record "Lot Tracing Buffer" temporary)
    var
        TempBufSortingAndFilters: Record "Lot Tracing Buffer";
    begin
        TempBufSortingAndFilters.Copy(TempPageTracingBuf);
        with TempPageTracingBuf do begin
            Reset;
            DeleteAll;
            Copy(TempBufSortingAndFilters);
            TempTracingBuf.Reset;
            if TempTracingBuf.FindSet then begin
                repeat
                    TempPageTracingBuf := TempTracingBuf;
                    Insert;
                until (TempTracingBuf.Next = 0);
                FindFirst;
            end;
        end;
    end;

    [Obsolete('Replaced by overload using Lot Tracing Buffer.', '17.0')]
    procedure Navigate(var TempTracingBuf: Record "Item Tracing Buffer" temporary)
    begin
    end;

    procedure Navigate(var TempTracingBuf: Record "Lot Tracing Buffer" temporary)
    var
        Navigate: Page Navigate;
    begin
        with TempTracingBuf do
            if ("Document No." <> '') then begin
                Navigate.SetDoc(0D, "Document No.");
                Navigate.Run;
            end;
    end;

    [Obsolete('Replaced by overload using Lot Tracing Buffer.', '17.0')]
    
    procedure ShowLotEntries(var TempTracingBuf: Record "Item Tracing Buffer" temporary)
    begin 
    end;
    
    procedure ShowLotEntries(var TempTracingBuf: Record "Lot Tracing Buffer" temporary)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        with TempTracingBuf do begin
            ItemLedgEntry.SetCurrentKey("Item No.", "Variant Code", "Lot No.");
            ItemLedgEntry.SetRange("Item No.", "Item No.");
            ItemLedgEntry.SetRange("Variant Code", "Variant Code");
            ItemLedgEntry.SetRange("Lot No.", "Lot No.");
            PAGE.Run(0, ItemLedgEntry);
        end;
    end;

    [Obsolete('Replaced by overload using Lot Tracing Buffer.', '17.0')]
    procedure ShowRelatedEntries(var TempTracingBuf: Record "Item Tracing Buffer" temporary)
    begin 
    end;

    procedure ShowRelatedEntries(var TempTracingBuf: Record "Lot Tracing Buffer" temporary)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        with TempTracingBuf do begin
            ItemLedgEntry.SetCurrentKey("Item No.", "Variant Code", "Lot No.");
            ItemLedgEntry.SetRange("Item No.", "Item No.");
            ItemLedgEntry.SetRange("Variant Code", "Variant Code");
            ItemLedgEntry.SetRange("Lot No.", "Lot No.");
            ItemLedgEntry.SetRange("Location Code", "Location Code");
            case "Entry Type" of
                "Entry Type"::Location:
                    ItemLedgEntry.SetRange(Open, true);
                "Entry Type"::"Negative Adjmt.", "Entry Type"::"Positive Adjmt.":
                    ItemLedgEntry.SetFilter(
                      "Entry Type", '%1|%2', ItemLedgEntry."Entry Type"::"Positive Adjmt.", ItemLedgEntry."Entry Type"::"Negative Adjmt.");
                "Entry Type"::Purchase:
                    ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Purchase);
                "Entry Type"::Sale:
                    ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Sale);
                "Entry Type"::Consumption:
                    begin
                        if ("Document No." <> '') then
                            ItemLedgEntry.SetRange("Document No.", "Document No.");
                        ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Consumption);
                    end;
                "Entry Type"::Output:
                    ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Output);
            end;
            PAGE.Run(0, ItemLedgEntry);
        end;
    end;

    procedure GetTraceUOMCode(ItemNo: Code[20]): Code[10]
    begin
        GetItem(ItemNo);
        if Item.TraceAltQty() then
            exit(Item."Alternate Unit of Measure");
        exit(Item."Base Unit of Measure");
    end;

    procedure LookupVariantCode(ItemNo: Code[20]; var Text: Text[1024]): Boolean
    var
        ItemVariant2: Record "Item Variant";
        ItemVariantPage: Page "Item Variants";
    begin
        if (ItemNo <> '') then begin
            ItemVariant2.FilterGroup(2);
            ItemVariant2.SetRange("Item No.", ItemNo);
            ItemVariant2.FilterGroup(0);
            ItemVariantPage.LookupMode(true);
            ItemVariantPage.SetTableView(ItemVariant2);
            if (Text <> '') then begin
                ItemVariant2.SetFilter(Code, Text + '*');
                if ItemVariant2.Find('=><') then
                    ItemVariantPage.SetRecord(ItemVariant2);
            end;
            if (ItemVariantPage.RunModal = ACTION::LookupOK) then begin
                ItemVariantPage.GetRecord(ItemVariant2);
                Text := ItemVariant2.Code;
                exit(true);
            end;
        end;
    end;

    procedure LookupLotNo(ItemNo: Code[20]; VariantCode: Code[10]; var Text: Text[1024]): Boolean
    var
        LotInfo2: Record "Lot No. Information";
        LotInfoPage: Page "Lot No. Information List";
    begin
        if (ItemNo <> '') then begin
            LotInfo2.FilterGroup(2);
            LotInfo2.SetRange("Item No.", ItemNo);
            LotInfo2.SetRange("Variant Code", VariantCode);
            LotInfo2.FilterGroup(0);
            LotInfoPage.LookupMode(true);
            LotInfoPage.SetTableView(LotInfo2);
            if (Text <> '') then begin
                LotInfo2.SetFilter("Lot No.", Text + '*');
                if LotInfo2.Find('=><') then
                    LotInfoPage.SetRecord(LotInfo2);
            end;
            if (LotInfoPage.RunModal = ACTION::LookupOK) then begin
                LotInfoPage.GetRecord(LotInfo2);
                Text := LotInfo2."Lot No.";
                exit(true);
            end;
        end;
    end;

    local procedure AddSourceBOMComponents(var InboundEntry: Record "Item Ledger Entry"; SourceFactor: Decimal; var TempSourceBuf: Record "Lot Tracing Buffer" temporary): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        // P8001134
        // P80069192
        if (InboundEntry.IsBOMOrderType() and (InboundEntry."Entry Type" in [InboundEntry."Entry Type"::"Positive Adjmt.", InboundEntry."Entry Type"::"Negative Adjmt."])) or
              (InboundEntry."Order Type" = InboundEntry."Order Type"::Assembly) then
            // P80069192
            with ItemLedgEntry do begin
                SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type");
                SetRange("Order Type", InboundEntry."Order Type");
                SetRange("Order No.", InboundEntry."Order No.");
                if (InboundEntry."Order Type" in ["Order Type"::FOODLotCombination, "Order Type"::FOODSalesRepack]) then
                    SetRange("Order Line No.", InboundEntry."Order Line No.");
                if (InboundEntry."Order Type" = "Order Type"::Assembly) then
                    SetRange("Entry Type", "Entry Type"::"Assembly Consumption")
                else
                    SetRange("Entry Type", "Entry Type"::"Negative Adjmt.");
                if FindSet then
                    repeat
                        AddSourceNegEntry(ItemLedgEntry, SourceFactor, TempSourceBuf);
                    until Next = 0;
            end;
    end;

    local procedure AddDestBOMOutput(var OutboundEntry: Record "Item Ledger Entry"; SourceQty: Decimal; var TempDestBuf: Record "Lot Tracing Buffer" temporary): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        // P8001134
        if OutboundEntry.IsBOMOrderType() or (OutboundEntry."Order Type" = OutboundEntry."Order Type"::Assembly) then
            with ItemLedgEntry do begin
                SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type");
                SetRange("Order Type", OutboundEntry."Order Type");
                SetRange("Order No.", OutboundEntry."Order No.");
                if (OutboundEntry."Order Type" in ["Order Type"::FOODLotCombination, "Order Type"::FOODSalesRepack]) then
                    SetRange("Order Line No.", OutboundEntry."Order Line No.");
                if (OutboundEntry."Order Type" = "Order Type"::Assembly) then
                    SetRange("Entry Type", "Entry Type"::"Assembly Output")
                else
                    SetRange("Entry Type", "Entry Type"::"Positive Adjmt.");
                if FindSet then
                    repeat
                        AddDestPosEntry(ItemLedgEntry."Entry No.", SourceQty, TempDestBuf);
                    until Next = 0;
            end;
    end;


    [Obsolete('Replaced by overload using Lot Tracing Buffer.', '17.0')]
    [IntegrationEvent(false, TRUE)]
    local procedure OnAfterGetLotTrace(var TraceLotInfo: Record "Lot No. Information"; var TempLotBuf: Record "Item Tracing Buffer" temporary; var TempSourceBuf: Record "Item Tracing Buffer" temporary; var TempDestBuf: Record "Item Tracing Buffer" temporary; var TotalPos: Decimal; var TotalNeg: Decimal)
    begin
        // P80060769
    end;

    [IntegrationEvent(false, TRUE)]
    local procedure OnAfterGetLotTrace2(var TraceLotInfo: Record "Lot No. Information"; var TempLotBuf: Record "Lot Tracing Buffer" temporary; var TempSourceBuf: Record "Lot Tracing Buffer" temporary; var TempDestBuf: Record "Lot Tracing Buffer" temporary; var TotalPos: Decimal; var TotalNeg: Decimal)
    begin
        // P80060769
    end;

    local procedure ClearStack()
    begin
        // P80081511
        TempItemLedgerStack.Reset;
        TempItemLedgerStack.DeleteAll;

        TempItemTracingBuffer[1].Reset;
        TempItemTracingBuffer[1].DeleteAll;
        TempItemTracingBuffer[2].Reset;
    end;

    local procedure EntryAlreadyProcessed(SourceDest: Option Source,Destination; ItemLedgerEntry: Record "Item Ledger Entry"; var TempBuf: Record "Lot Tracing Buffer" temporary; TraceQtyFactor: Decimal): Boolean
    var
        AlwaysProcess: Boolean;
    begin
        // P80074332
        GetItem(ItemLedgerEntry."Item No.");

        if SourceDest = SourceDest::Destination then
            AlwaysProcess := (ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Transfer) AND
              (not ItemLedgerEntry.Positive) AND
              (Item."Costing Method" <> Item."Costing Method"::Average);

        TempItemTracingBuffer[2].SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        if (not AlwaysProcess) and TempItemTracingBuffer[2].FindSet then begin
            repeat
                TempBuf.Reset;
                TempBuf.SetRange("Line No.", TempItemTracingBuffer[2]."Line No.");
                if TempBuf.FindFirst then begin
                    TempBuf."Trace Quantity" += TempItemTracingBuffer[2]."Trace Quantity" * TraceQtyFactor;
                    TempBuf.Modify;
                    UpdateTempItemTracingBuffer(TempItemTracingBuffer[2]."Line No.", TempItemTracingBuffer[2]."Trace Quantity" * TraceQtyFactor);
                end;
            until TempItemTracingBuffer[2].Next = 0;
            exit(true);
        end else begin
            if TempItemLedgerStack.FindLast then
                TempItemLedgerStack."Line No." += 1
            else
                TempItemLedgerStack."Line No." := 1;
            TempItemLedgerStack."Item Ledger Entry No." := ItemLedgerEntry."Entry No.";
            TempItemLedgerStack.Quantity := TraceQtyFactor;
            TempItemLedgerStack.Insert;
            exit(false);
        end;
    end;

    local procedure RemoveFromStack()
    begin
        // P80074332
        if TempItemLedgerStack.FindLast then
            TempItemLedgerStack.Delete;
    end;

    local procedure UpdateTempItemTracingBuffer(LineNo: Integer; TraceQty: Decimal)
    begin
        // P80074332
        if TempItemLedgerStack.FindSet then
            repeat
                if TempItemTracingBuffer[1].Get(LineNo, TempItemLedgerStack."Item Ledger Entry No.") then begin
                    TempItemTracingBuffer[1]."Trace Quantity" += TraceQty / TempItemLedgerStack.Quantity;
                    TempItemTracingBuffer[1].Modify;
                end else begin
                    TempItemTracingBuffer[1]."Line No." := LineNo;
                    TempItemTracingBuffer[1]."Item Ledger Entry No." := TempItemLedgerStack."Item Ledger Entry No.";
                    TempItemTracingBuffer[1]."Trace Quantity" := TraceQty / TempItemLedgerStack.Quantity;
                    TempItemTracingBuffer[1].Insert;
                end;
            until TempItemLedgerStack.Next = 0;
    end;
}

