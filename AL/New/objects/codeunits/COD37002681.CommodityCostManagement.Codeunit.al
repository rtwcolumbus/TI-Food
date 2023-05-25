codeunit 37002681 "Commodity Cost Management"
{
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 24 AUG 10
    //   Add Commodity Class Costing granule
    // 
    // P8000902, Columbus IT, Don Bresee, 14 MAR 11
    //   Add Commodity Payment logic
    // 
    // PRW16.00.05
    // P8000926, Columbus IT, Don Bresee, 29 MAR 11
    //   Fix to usage of "Commodity Rejected" flowfield
    // 
    // P8000951, Columbus IT, Don Bresee, 26 MAY 11
    //   Add logic to propogate cost from BOM outputs to the inputs
    // 
    // PRW17.00
    // P8001134, Columbus IT, Don Bresee, 19 MAR 13
    //   Add logic for handling of new "Order Type" options
    // 
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.10.02
    // P8001301, Columbus IT, Jack Reynolds, 03 MAR 14
    //   Update Rollup 4
    // 
    // P8001306, Columbus IT, Jack Reynolds, 25 MAR 14
    //   Fix problem with "another user has changed..." message
    // 
    // PRW18.00
    // P8001352, Columbus IT, Jack Reynolds, 30 OCT 14
    //   2015 Upgrade - Code merge and refactoring
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Permissions = TableData "Item Ledger Entry" = m,
                  TableData "Item Application Entry" = m;

    trigger OnRun()
    var
        CommCostPeriod: Record "Commodity Cost Period";
    begin
        ImplementCostChanges(CommCostPeriod);
    end;

    var
        InvtSetup: Record "Inventory Setup";
        GLSetup: Record "General Ledger Setup";
        SourceCodeSetup: Record "Source Code Setup";
        SetupRetrieved: Boolean;
        StatusWindow: Dialog;
        ACYMgt: Codeunit "Additional-Currency Management";
        CommItemMgmt: Codeunit "Commodity Item Management";
        InvtAdjmt: Codeunit "Inventory Adjustment";
        UpdateItemAnalysisView: Codeunit "Update Item Analysis View";
        Text000: Label 'Nothing to Post.';
        Text001: Label 'Do you want to Post Commodity Cost changes?';
        Text002: Label 'Posting Commodity Cost Changes...\\Period Start #1##################\Item No.     #2##################\Lot No.      #3##################';
        Text003: Label 'You must specify Commodity Cost Component values for %1 %2 and %3 %4.';
        EntriesAdjusted: Boolean;
        PeriodCostingComplete: Boolean;
        Text004: Label 'Q/C Test %1 required for Item %2, Lot No. %3.';
        Text005: Label 'Do you want to Update Commodity Order costs?';
        Text006: Label 'Update Commodity Order Costs...\\Order No. #1##################';
        QCRptText000: Label 'Lot is missing Q/C test.';
        QCRptText001: Label 'Q/C test is not complete.';
        QCRptText002: Label 'Lot failed Q/C test.';
        QCRptText003: Label 'Lot failed a different Q/C test';

    procedure ImplementCostChanges(var CommCostPeriod2: Record "Commodity Cost Period")
    var
        CommCostPeriod: Record "Commodity Cost Period";
        CancelPost: Boolean;
    begin
        with CommCostPeriod do begin
            Copy(CommCostPeriod2);
            SetCurrentKey("Starting Market Date", "Calculate Cost");
            FilterGroup(2);
            SetRange("Calculate Cost", true);
            FilterGroup(0);
            if IsEmpty then
                Error(Text000);
        end;
        if GuiAllowed then
            if not Confirm(Text001, false) then
                CancelPost := true;
        if not CancelPost then begin
            PostCosts(CommCostPeriod);
            CommCostPeriod := CommCostPeriod2;
            CommCostPeriod2.Reset;
            CommCostPeriod2.SetCurrentKey("Location Code", "Starting Market Date");
            CommCostPeriod2 := CommCostPeriod;
        end;
    end;

    procedure PostCosts(var CommCostPeriod: Record "Commodity Cost Period")
    var
        AdjmtsModified: Boolean;
    begin
        OpenWindow;
        GetSetup;
        EntriesAdjusted := false;
        with CommCostPeriod do begin
            FindSet;
            repeat
                PostPeriodCosts(CommCostPeriod);
            until (Next = 0);
        end;
        CloseWindow;
        if InvtSetup."Cost Adjust on Comm. Post" and EntriesAdjusted then
            RunInvtAdjmt;
    end;

    local procedure PostPeriodCosts(var CommCostPeriod: Record "Commodity Cost Period")
    var
        CostingComplete: Boolean;
        Item: Record Item;
    begin
        PeriodCostingComplete := true;
        with Item do begin
            SetCurrentKey("Commodity Cost Item");
            SetRange("Commodity Cost Item", true);
            if FindSet then
                repeat
                    PostItemPeriodCosts(CommCostPeriod, Item);
                until (Next = 0);
        end;
        if PeriodCostingComplete then
            with CommCostPeriod do begin
                LockTable;
                Find;
                "Calculate Cost" := false;
                Modify;
                Commit;
            end;
    end;

    local procedure PostItemPeriodCosts(var CommCostPeriod: Record "Commodity Cost Period"; var Item: Record Item)
    var
        EndingDate: Date;
        NegItemLedgEntry: Record "Item Ledger Entry";
    begin
        UpdateWindow(CommCostPeriod."Starting Market Date", Item."No.", '');
        with NegItemLedgEntry do begin
            SetCurrentKey("Item No.", "Variant Code", "Lot No.", Positive, "Posting Date");
            SetRange("Item No.", Item."No.");
            SetRange(Positive, false);
            EndingDate := CommCostPeriod.EndingMarketDate();
            if (EndingDate = 0D) then
                SetFilter("Posting Date", '%1..', CommCostPeriod."Starting Market Date")
            else
                SetRange("Posting Date", CommCostPeriod."Starting Market Date", EndingDate);
            if InvtSetup."Commodity Cost by Location" then
                SetRange("Location Code", CommCostPeriod."Location Code");
            SetFilter("Entry Type", '<>%1', "Entry Type"::Transfer);
            SetFilter("Commodity Class Code", '<>%1', '');
            if FindSet then
                repeat
                    PostLotPeriodCosts(CommCostPeriod, Item, NegItemLedgEntry);
                until (Next = 0);
        end;
    end;

    local procedure PostLotPeriodCosts(var CommCostPeriod: Record "Commodity Cost Period"; var Item: Record Item; var NegItemLedgEntry: Record "Item Ledger Entry")
    var
        TempPosEntryChange: Record "Integer" temporary;
        TempApplChange: Record "Item Application Entry" temporary;
        TempCostAdjmt: Record "Value Entry" temporary;
    begin
        UpdateWindow(CommCostPeriod."Starting Market Date", Item."No.", NegItemLedgEntry."Lot No.");
        RetrieveNegApplCosts(CommCostPeriod, Item, NegItemLedgEntry, TempPosEntryChange, TempApplChange);
        RetrievePosApplCosts(TempPosEntryChange, TempApplChange, TempCostAdjmt);
        if not (TempCostAdjmt.IsEmpty and TempApplChange.IsEmpty) then begin
            PostItemEntryCostAdjmts(Item, TempCostAdjmt);
            UpdateItemApplEntries(TempApplChange);
            Commit;
            EntriesAdjusted := true;
        end;
    end;

    local procedure RetrieveNegApplCosts(var CommCostPeriod: Record "Commodity Cost Period"; var Item: Record Item; var NegItemLedgEntry: Record "Item Ledger Entry"; var TempPosEntryChange: Record "Integer" temporary; var TempApplChange: Record "Item Application Entry" temporary)
    var
        TempUnitCost: Record "Value Entry" temporary;
        CommUnitCost: Decimal;
        CommUnitCostACY: Decimal;
        NegEntryQty: Decimal;
    begin
        with NegItemLedgEntry do begin
            SetRange("Variant Code", "Variant Code");
            SetRange("Lot No.", "Lot No.");
            repeat
                if not IsBOMOrderType() then // P8000951, P8001134
                    if not GetCommUnitCost(
                             Item, "Entry No.", "Variant Code", "Lot No.", "Location Code", "Commodity Class Code",
                             "Posting Date", CommCostPeriod, TempUnitCost, CommUnitCost, CommUnitCostACY)
                    then
                        PeriodCostingComplete := false
                    else begin
                        NegEntryQty := GetCostingQty();
                        RetrieveEntryCostChange(
                          "Entry No.", NegEntryQty, RoundAmount(CommUnitCost * NegEntryQty),
                          ACYMgt.RoundACYAmt(CommUnitCostACY * NegEntryQty, false), TempPosEntryChange, TempApplChange);
                    end;
            until (Next = 0);
            SetRange("Variant Code");
            SetRange("Lot No.");
        end;
    end;

    local procedure RetrieveEntryCostChange(NegItemLedgEntryNo: Integer; NegEntryQty: Decimal; NegEntryCost: Decimal; NegEntryCostACY: Decimal; var TempPosEntryChange: Record "Integer" temporary; var TempApplChange: Record "Item Application Entry" temporary)
    var
        TotalAppliedFactor: Decimal;
        ItemApplEntry: Record "Item Application Entry";
        ItemApplFactor: Decimal;
        PosItemLedgEntry: Record "Item Ledger Entry";
    begin
        with ItemApplEntry do begin
            SetCurrentKey(
              "Outbound Item Entry No.", "Item Ledger Entry No.", "Cost Application", "Transferred-from Entry No.");
            SetRange("Outbound Item Entry No.", NegItemLedgEntryNo);
            SetRange("Item Ledger Entry No.", NegItemLedgEntryNo);
            SetRange("Cost Application", true);
            if FindSet then
                repeat
                    if (NegEntryQty = 0) then
                        ItemApplFactor := 0
                    else
                        ItemApplFactor := GetCostingQty() / NegEntryQty;
                    PosItemLedgEntry.Get("Inbound Item Entry No.");
                    if not PosItemLedgEntry."Completely Invoiced" then
                        PeriodCostingComplete := false;
                    if PosItemLedgEntry."Completely Invoiced" or
                       (PosItemLedgEntry."Entry Type" = PosItemLedgEntry."Entry Type"::Purchase)
                    then
                        if (NegEntryQty = 0) then
                            RetrieveApplCostChange(ItemApplEntry, 0, 0, TempPosEntryChange, TempApplChange)
                        else
                            RetrieveApplCostChange(
                              ItemApplEntry,
                              (RoundAmount(NegEntryCost * (TotalAppliedFactor + ItemApplFactor)) -
                               RoundAmount(NegEntryCost * TotalAppliedFactor)),
                              (ACYMgt.RoundACYAmt(NegEntryCostACY * (TotalAppliedFactor + ItemApplFactor), false) -
                               ACYMgt.RoundACYAmt(NegEntryCostACY * TotalAppliedFactor, false)),
                              TempPosEntryChange, TempApplChange);
                    TotalAppliedFactor := TotalAppliedFactor + ItemApplFactor;
                until (Next = 0);
        end;
    end;

    local procedure RetrieveApplCostChange(var ItemApplEntry: Record "Item Application Entry"; NewApplCost: Decimal; NewApplCostACY: Decimal; var TempPosEntryChange: Record "Integer" temporary; var TempApplChange: Record "Item Application Entry" temporary)
    var
        OrigApplCost: Decimal;
        OrigApplCostACY: Decimal;
    begin
        InvtAdjmt.GetOrigItemApplCost(ItemApplEntry, OrigApplCost, OrigApplCostACY);
        with ItemApplEntry do
            if IsApplCostChange(ItemApplEntry, NewApplCost - OrigApplCost, NewApplCostACY - OrigApplCostACY) then begin
                AddApplCostChange(
                  ItemApplEntry, TempApplChange, NewApplCost - OrigApplCost, NewApplCostACY - OrigApplCostACY);
                AddEntryCostChange("Inbound Item Entry No.", TempPosEntryChange);
            end;
    end;

    local procedure RetrievePosApplCosts(var TempPosEntryChange: Record "Integer" temporary; var TempApplChange: Record "Item Application Entry" temporary; var TempCostAdjmt: Record "Value Entry" temporary)
    var
        PosItemLedgEntry: Record "Item Ledger Entry";
        ItemApplEntry: Record "Item Application Entry";
        EntryAdjmt: Decimal;
        EntryAdjmtACY: Decimal;
        TempTransEntryChange: Record "Integer" temporary;
        AdjmtsModified: Boolean;
    begin
        if TempPosEntryChange.FindSet then
            with PosItemLedgEntry do
                repeat
                    Get(TempPosEntryChange.Number);
                    if CalcPosItemEntryAdjmt("Entry No.", TempApplChange, EntryAdjmt, EntryAdjmtACY) then begin
                        CommItemMgmt.GetPosItemApplEntry("Entry No.", ItemApplEntry);
                        if IsApplCostChange(ItemApplEntry, EntryAdjmt, EntryAdjmtACY) then begin
                            if ("Entry Type" <> "Entry Type"::Transfer) then
                                AddTempCostAdjmt(
                                  "Entry No.", TempCostAdjmt,
                                  EntryAdjmt - ItemApplEntry."Comm. Cost Adjmt.",
                                  EntryAdjmtACY - ItemApplEntry."Comm. Cost Adjmt. (ACY)");
                            AddApplCostChange(ItemApplEntry, TempApplChange, EntryAdjmt, EntryAdjmtACY);
                            AdjmtsModified := true;
                            if ("Entry Type" = "Entry Type"::Transfer) then
                                AddTransApplCostChange(ItemApplEntry, TempTransEntryChange, TempApplChange);
                            if IsBOMOrderType() then                                                                    // P8000951, P8001134
                                AddBOMApplCostChange(PosItemLedgEntry, ItemApplEntry, TempTransEntryChange, TempApplChange); // P8000951, P8001134
                        end;
                    end;
                until (TempPosEntryChange.Next = 0);
        if AdjmtsModified then
            RetrievePosApplCosts(TempTransEntryChange, TempApplChange, TempCostAdjmt);
    end;

    local procedure CalcPosItemEntryAdjmt(PosItemLedgEntryNo: Integer; var TempApplChange: Record "Item Application Entry" temporary; var EntryAdjmt: Decimal; var EntryAdjmtACY: Decimal) AdjmtsFound: Boolean
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        EntryAdjmt := 0;
        EntryAdjmtACY := 0;
        with ItemApplnEntry do
            if AppliedOutbndEntryExists(PosItemLedgEntryNo, true, false) then // P8001132, P8001301, P8001352
                repeat
                    if TempApplChange.Get("Entry No.") then
                        ItemApplnEntry := TempApplChange;
                    if "Commodity Cost Calculated" then begin
                        EntryAdjmt := EntryAdjmt - "Comm. Cost Adjmt.";
                        EntryAdjmtACY := EntryAdjmtACY - "Comm. Cost Adjmt. (ACY)";
                        AdjmtsFound := true;
                    end;
                until (Next = 0);
    end;

    local procedure AddTempCostAdjmt(PosItemLedgEntryNo: Integer; var TempCostAdjmt: Record "Value Entry" temporary; EntryAdjmt: Decimal; EntryAdjmtACY: Decimal)
    begin
        with TempCostAdjmt do
            if Get(PosItemLedgEntryNo) then begin
                "Cost Amount (Actual)" := "Cost Amount (Actual)" + EntryAdjmt;
                "Cost Amount (Actual) (ACY)" := "Cost Amount (Actual) (ACY)" + EntryAdjmtACY;
                Modify;
            end else begin
                "Entry No." := PosItemLedgEntryNo;
                "Cost Amount (Actual)" := EntryAdjmt;
                "Cost Amount (Actual) (ACY)" := EntryAdjmtACY;
                Insert;
            end;
    end;

    local procedure IsApplCostChange(var ItemApplEntry: Record "Item Application Entry"; NewApplAdjmt: Decimal; NewApplAdjmtACY: Decimal): Boolean
    begin
        with ItemApplEntry do
            exit((not "Commodity Cost Calculated") or
                 ("Comm. Cost Adjmt." <> NewApplAdjmt) or
                 ("Comm. Cost Adjmt. (ACY)" <> NewApplAdjmtACY));
    end;

    procedure AddApplCostChange(var ItemApplEntry: Record "Item Application Entry"; var TempApplChange: Record "Item Application Entry" temporary; NewApplAdjmt: Decimal; NewApplAdjmtACY: Decimal)
    begin
        with ItemApplEntry do begin
            "Commodity Cost Calculated" := true;
            "Comm. Cost Adjmt." := NewApplAdjmt;
            "Comm. Cost Adjmt. (ACY)" := NewApplAdjmtACY;
            TempApplChange := ItemApplEntry;
            TempApplChange.Insert;
        end;
    end;

    local procedure AddTransApplCostChange(var ItemApplEntry: Record "Item Application Entry"; var TempTransEntryChange: Record "Integer" temporary; var TempApplChange: Record "Item Application Entry" temporary)
    var
        TransItemApplEntry: Record "Item Application Entry";
    begin
        with ItemApplEntry do begin
            TransItemApplEntry.SetRange("Item Ledger Entry No.", "Outbound Item Entry No.");
            TransItemApplEntry.SetRange("Inbound Item Entry No.", "Transferred-from Entry No.");
            TransItemApplEntry.SetRange("Outbound Item Entry No.", "Outbound Item Entry No.");
            TransItemApplEntry.SetRange("Cost Application", true);
            if TransItemApplEntry.FindFirst then
                if IsApplCostChange(TransItemApplEntry, -"Comm. Cost Adjmt.", -"Comm. Cost Adjmt. (ACY)") then begin
                    AddApplCostChange(TransItemApplEntry, TempApplChange, -"Comm. Cost Adjmt.", -"Comm. Cost Adjmt. (ACY)");
                    AddEntryCostChange("Transferred-from Entry No.", TempTransEntryChange);
                end;
        end;
    end;

    local procedure AddEntryCostChange(PosItemLedgEntryNo: Integer; var TempPosEntryChange: Record "Integer" temporary)
    begin
        if not TempPosEntryChange.Get(PosItemLedgEntryNo) then begin
            TempPosEntryChange.Number := PosItemLedgEntryNo;
            TempPosEntryChange.Insert;
        end;
    end;

    local procedure AddBOMApplCostChange(var ItemLedgEntry: Record "Item Ledger Entry"; var ItemApplEntry: Record "Item Application Entry"; var TempTransEntryChange: Record "Integer" temporary; var TempApplChange: Record "Item Application Entry" temporary)
    var
        CompItemLedgEntry: Record "Item Ledger Entry";
        SameItemQty: Decimal;
        SameItemFound: Boolean;
        OtherItemCost: Decimal;
    begin
        // P8000951, P8001134
        with CompItemLedgEntry do begin
            SetRange("Order Type", ItemLedgEntry."Order Type");
            SetRange("Order No.", ItemLedgEntry."Order No.");
            if (ItemLedgEntry."Order Type" in ["Order Type"::FOODLotCombination, "Order Type"::FOODSalesRepack]) then
                SetRange("Order Line No.", ItemLedgEntry."Order Line No.");
            SetRange("Entry Type", "Entry Type"::"Negative Adjmt.");
            if FindSet then begin
                repeat
                    if ("Item No." = ItemLedgEntry."Item No.") then begin
                        SameItemQty := SameItemQty + GetCostingQty();
                        SameItemFound := true;
                    end else
                        if not SameItemFound then
                            OtherItemCost := OtherItemCost + GetOrigNegItemEntryCost("Entry No.");
                until (Next = 0);
                if SameItemFound then
                    DistCostToComponents(
                      ItemApplEntry, TempTransEntryChange, TempApplChange, CompItemLedgEntry, ItemLedgEntry."Item No.", SameItemQty)
                else
                    DistCostToComponents(
                      ItemApplEntry, TempTransEntryChange, TempApplChange, CompItemLedgEntry, '', OtherItemCost);
            end;
        end;
    end;

    local procedure DistCostToComponents(var ItemApplEntry: Record "Item Application Entry"; var TempTransEntryChange: Record "Integer" temporary; var TempApplChange: Record "Item Application Entry" temporary; var CompItemLedgEntry: Record "Item Ledger Entry"; ItemNo: Code[20]; TotalDistAmt: Decimal)
    var
        RemAdjmt: Decimal;
        RemAdjmtACY: Decimal;
    begin
        // P8000951, P8001134
        RemAdjmt := -ItemApplEntry."Comm. Cost Adjmt.";
        RemAdjmtACY := -ItemApplEntry."Comm. Cost Adjmt. (ACY)";
        CompItemLedgEntry.FindSet;
        repeat
            if (ItemNo = '') then
                DistCostToCompEntry(
                  CompItemLedgEntry, ItemApplEntry."Inbound Item Entry No.",
                  TempTransEntryChange, TempApplChange, RemAdjmt, RemAdjmtACY, TotalDistAmt,
                  GetOrigNegItemEntryCost(CompItemLedgEntry."Entry No."), false)
            else
                if (CompItemLedgEntry."Item No." = ItemNo) then
                    DistCostToCompEntry(
                      CompItemLedgEntry, ItemApplEntry."Inbound Item Entry No.",
                      TempTransEntryChange, TempApplChange, RemAdjmt, RemAdjmtACY, TotalDistAmt,
                      CompItemLedgEntry.GetCostingQty(), true);
        until (CompItemLedgEntry.Next = 0);
    end;

    local procedure DistCostToCompEntry(var CompItemLedgEntry: Record "Item Ledger Entry"; PosItemLedgEntryNo: Integer; var TempTransEntryChange: Record "Integer" temporary; var TempApplChange: Record "Item Application Entry" temporary; var RemAdjmt: Decimal; var RemAdjmtACY: Decimal; var TotalDistAmt: Decimal; DistAmt: Decimal; UseQty: Boolean)
    var
        EntryAdjmt: Decimal;
        EntryAdjmtACY: Decimal;
        ItemApplEntry: Record "Item Application Entry";
        ApplAdjmt: Decimal;
        ApplAdjmtACY: Decimal;
        OrigApplCost: Decimal;
        OrigApplCostACY: Decimal;
    begin
        // P8000951
        DistCostAmounts(RemAdjmt, RemAdjmtACY, TotalDistAmt, DistAmt, EntryAdjmt, EntryAdjmtACY);
        with ItemApplEntry do begin
            SetCurrentKey(
              "Outbound Item Entry No.", "Item Ledger Entry No.", "Cost Application", "Transferred-from Entry No.");
            SetRange("Outbound Item Entry No.", CompItemLedgEntry."Entry No.");
            SetRange("Item Ledger Entry No.", CompItemLedgEntry."Entry No.");
            SetRange("Cost Application", true);
            if FindSet then
                repeat
                    if UseQty then
                        DistCostAmounts(EntryAdjmt, EntryAdjmtACY, DistAmt, GetCostingQty(), ApplAdjmt, ApplAdjmtACY)
                    else begin
                        InvtAdjmt.GetOrigItemApplCost(ItemApplEntry, OrigApplCost, OrigApplCostACY);
                        DistCostAmounts(EntryAdjmt, EntryAdjmtACY, DistAmt, OrigApplCost, ApplAdjmt, ApplAdjmtACY);
                    end;
                    if IsApplCostChange(ItemApplEntry, ApplAdjmt, ApplAdjmtACY) then begin
                        AddApplCostChange(ItemApplEntry, TempApplChange, ApplAdjmt, ApplAdjmtACY);
                        AddEntryCostChange("Inbound Item Entry No.", TempTransEntryChange);
                    end;
                until (Next = 0);
        end;
    end;

    local procedure DistCostAmounts(var RemAdjmt: Decimal; var RemAdjmtACY: Decimal; var TotalDistAmt: Decimal; DistAmt: Decimal; var Adjmt: Decimal; var AdjmtACY: Decimal)
    begin
        // P8000951
        if (TotalDistAmt = 0) then begin
            Adjmt := RemAdjmt;
            AdjmtACY := RemAdjmtACY;
        end else begin
            Adjmt := RoundAmount(RemAdjmt * (DistAmt / TotalDistAmt));
            AdjmtACY := ACYMgt.RoundACYAmt(RemAdjmtACY * (DistAmt / TotalDistAmt), false);
        end;
        RemAdjmt := RemAdjmt - Adjmt;
        RemAdjmtACY := RemAdjmtACY - AdjmtACY;
        TotalDistAmt := TotalDistAmt - DistAmt;
    end;

    local procedure GetOrigNegItemEntryCost(NegItemLedgEntryNo: Integer) NegEntryCost: Decimal
    var
        ItemApplEntry: Record "Item Application Entry";
        OrigApplCost: Decimal;
        OrigApplCostACY: Decimal;
    begin
        // P8000951
        with ItemApplEntry do begin
            SetCurrentKey(
              "Outbound Item Entry No.", "Item Ledger Entry No.", "Cost Application", "Transferred-from Entry No.");
            SetRange("Outbound Item Entry No.", NegItemLedgEntryNo);
            SetRange("Item Ledger Entry No.", NegItemLedgEntryNo);
            SetRange("Cost Application", true);
            if FindSet then
                repeat
                    InvtAdjmt.GetOrigItemApplCost(ItemApplEntry, OrigApplCost, OrigApplCostACY);
                    NegEntryCost := NegEntryCost + OrigApplCost;
                until (Next = 0);
        end;
    end;

    local procedure GetCommUnitCost(var Item: Record Item; ItemLedgEntryNo: Integer; VariantCode: Code[10]; LotNo: Code[50]; LocationCode: Code[10]; CommodityClassCode: Code[10]; PostingDate: Date; var CommCostPeriod: Record "Commodity Cost Period"; var TempUnitCost: Record "Value Entry" temporary; var CommUnitCost: Decimal; var CommUnitCostACY: Decimal) CostCalculated: Boolean
    var
        CommCostSetup: Record "Comm. Cost Setup Line";
        CommCostComp: Record "Comm. Cost Component";
        ComponentValue: Decimal;
        UOM: Record "Unit of Measure";
        QCLine: Record "Quality Control Line";
    begin
        with TempUnitCost do begin
            SetCurrentKey("Item No.");
            SetRange("Item No.", CommodityClassCode);
            if FindFirst then begin
                CostCalculated := "Expected Cost";
                CommUnitCost := "Cost per Unit";
                CommUnitCostACY := "Cost per Unit (ACY)";
            end else begin
                CostCalculated :=
                  CalcCommUnitCost(
                    Item, VariantCode, LotNo, CommodityClassCode, PostingDate,
                    CommCostPeriod, false, CommUnitCost, CommUnitCostACY);
                "Entry No." := ItemLedgEntryNo;
                "Item No." := CommodityClassCode;
                "Expected Cost" := CostCalculated;
                "Cost per Unit" := CommUnitCost;
                "Cost per Unit (ACY)" := CommUnitCostACY;
                Insert;
            end;
        end;
    end;

    local procedure CalcCommUnitCost(var Item: Record Item; VariantCode: Code[10]; LotNo: Code[50]; CommodityClassCode: Code[10]; PostingDate: Date; var CommCostPeriod: Record "Commodity Cost Period"; GenerateErrors: Boolean; var CommUnitCost: Decimal; var CommUnitCostACY: Decimal): Boolean
    var
        CommCostSetup: Record "Comm. Cost Setup Line";
        CommCostComp: Record "Comm. Cost Component";
        ComponentValue: Decimal;
        UOM: Record "Unit of Measure";
        QCLine: Record "Quality Control Line";
        UnitCost: Decimal;
    begin
        CommUnitCost := 0;
        CommUnitCostACY := 0;
        CommCostSetup.SetRange("Commodity Class Code", CommodityClassCode);
        if CommCostSetup.IsEmpty then begin
            if GenerateErrors then
                CommCostSetup.FindSet;
            exit(false);
        end;
        CommCostSetup.FindSet;
        repeat
            if not CalcComponentValue(CommCostPeriod, CommCostSetup, GenerateErrors, ComponentValue) then
                exit(false);
            with CommCostComp do begin
                Get(CommCostSetup."Comm. Cost Component Code");
                if ("Unit of Measure Code" <> '') then begin
                    UOM.Get("Unit of Measure Code");
                    UOM.TestField("Base per Unit of Measure");
                    ComponentValue := ComponentValue / UOM."Base per Unit of Measure";
                end;
                if ("Q/C Test Type" = '') then
                    UnitCost := UnitCost + ComponentValue
                else begin
                    if not FindQCTestResult("Q/C Test Type", Item."No.", VariantCode, LotNo, GenerateErrors, QCLine) then
                        exit(false);
                    if ("Q/C Test Result Handling" = "Q/C Test Result Handling"::Percentage) then
                        QCLine."Numeric Result" := QCLine."Numeric Result" / 100;
                    UnitCost := UnitCost + (ComponentValue * QCLine."Numeric Result");
                end;
            end;
        until (CommCostSetup.Next = 0);
        UnitCost := Round(UnitCost, InvtSetup."Comm. Cost Rounding Precision");
        UnitCost := UnitCost * GetItemBaseQtyPerCostUnit(Item);
        CommUnitCost := RoundUnitAmount(UnitCost);
        CommUnitCostACY := ACYMgt.CalcACYAmt(UnitCost, PostingDate, true);
        exit(true);
    end;

    local procedure CalcComponentValue(var CommCostPeriod: Record "Commodity Cost Period"; var CommCostSetup: Record "Comm. Cost Setup Line"; GenerateErrors: Boolean; var ComponentValue: Decimal): Boolean
    var
        CommCostEntry: Record "Commodity Cost Entry";
    begin
        with CommCostEntry do begin
            SetCurrentKey(
              "Comm. Class Period Entry No.", "Commodity Class Code", "Comm. Cost Component Code");
            SetRange("Comm. Class Period Entry No.", CommCostPeriod."Entry No.");
            SetRange("Commodity Class Code", CommCostSetup."Commodity Class Code");
            if IsEmpty then begin
                if GenerateErrors then
                    Error(Text003,
                      CommCostSetup.FieldCaption("Commodity Class Code"), CommCostSetup."Commodity Class Code",
                      CommCostPeriod.FieldCaption("Starting Market Date"), CommCostPeriod."Starting Market Date");
                exit(false);
            end;
            SetRange("Comm. Cost Component Code", CommCostSetup."Comm. Cost Component Code");
            CalcSums("Component Value");
            ComponentValue := "Component Value";
            exit(true);
        end;
    end;

    local procedure FindQCTestResult(QCTestCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50]; GenerateErrors: Boolean; var QCLine: Record "Quality Control Line"): Boolean
    var
        QCHeader: Record "Quality Control Header";
    begin
        with QCLine do begin
            SetRange("Item No.", ItemNo);
            SetRange("Variant Code", VariantCode);
            SetRange("Lot No.", LotNo);
            SetRange("Test Code", QCTestCode);
            if IsEmpty then begin
                if GenerateErrors then
                    Error(Text004, QCTestCode, ItemNo, LotNo);
                exit(false);
            end;
            FindLast;
        end;
        with QCHeader do begin
            Get(ItemNo, VariantCode, LotNo, QCLine."Test No.");
            if (Status <> Status::Pass) then begin
                if GenerateErrors then
                    FieldError(Status);
                exit(false);
            end;
            exit(true);
        end;
    end;

    local procedure GetItemBaseQtyPerCostUnit(var Item: Record Item): Decimal
    var
        CostingUOM: Record "Item Unit of Measure";
    begin
        with Item do
            if ("Costing Unit" = "Costing Unit"::Base) then
                CostingUOM.Get("No.", "Base Unit of Measure")
            else
                CostingUOM.Get("No.", "Alternate Unit of Measure");
        exit(CommItemMgmt.GetItemBaseQtyPerUOM(Item, CostingUOM));
    end;

    local procedure PostItemEntryCostAdjmts(var Item: Record Item; var TempCostAdjmt: Record "Value Entry" temporary)
    var
        PosItemLedgEntry: Record "Item Ledger Entry";
        InbndValueEntry: Record "Value Entry";
    begin
        with TempCostAdjmt do
            if FindSet then begin
                AquireAdjmtLocks;
                if InvtAdjmt.StartCommCostPostReg() then
                    Clear(InvtAdjmt);
                repeat
                    if ("Cost Amount (Actual)" <> 0) or ("Cost Amount (Actual) (ACY)" <> 0) then begin
                        InbndValueEntry.SetCurrentKey("Item Ledger Entry No.");
                        InbndValueEntry.SetRange("Item Ledger Entry No.", "Entry No.");
                        InbndValueEntry.SetFilter("Invoiced Quantity", '<>0');
                        if not InbndValueEntry.FindLast then begin
                            InbndValueEntry.SetRange("Invoiced Quantity");
                            InbndValueEntry.FindLast;
                        end;
                        InvtAdjmt.PostCommCostVariance(
                          InbndValueEntry, "Cost Amount (Actual)", "Cost Amount (Actual) (ACY)",
                          SourceCodeSetup."Commodity Cost Adjustment");
                    end;
                    PosItemLedgEntry.Get("Entry No.");
                    PosItemLedgEntry.SetAppliedEntryToAdjust(true);
                    if Item."Cost is Adjusted" then begin
                        Item."Cost is Adjusted" := false;
                        Item.Modify;
                    end;
                until (Next = 0);
            end;
    end;

    local procedure UpdateItemApplEntries(var TempApplChange: Record "Item Application Entry" temporary)
    var
        ItemApplEntry: Record "Item Application Entry";
    begin
        with TempApplChange do
            if FindSet then begin
                ItemApplEntry.LockTable;
                repeat
                    ItemApplEntry.Get("Entry No.");
                    //ItemApplEntry := TempApplChange;                  // P8001306
                    ItemApplEntry.TransferFields(TempApplChange, false); // P8001306
                    ItemApplEntry.Modify;
                until (Next = 0);
            end;
    end;

    local procedure GetSetup()
    begin
        if not SetupRetrieved then begin
            InvtSetup.Get;
            if (InvtSetup."Comm. Cost Rounding Precision" = 0) then
                InvtSetup."Comm. Cost Rounding Precision" := 0.00001;
            GLSetup.Get;
            if (GLSetup."Amount Rounding Precision" = 0) then
                GLSetup."Amount Rounding Precision" := 0.01;
            if (GLSetup."Unit-Amount Rounding Precision" = 0) then
                GLSetup."Unit-Amount Rounding Precision" := 0.00001;
            SourceCodeSetup.Get;
            SetupRetrieved := true;
        end;
    end;

    local procedure RoundUnitAmount(UnitAmount: Decimal): Decimal
    begin
        exit(Round(UnitAmount, GLSetup."Unit-Amount Rounding Precision"));
    end;

    local procedure RoundAmount(Amount: Decimal): Decimal
    begin
        exit(Round(Amount, GLSetup."Amount Rounding Precision"));
    end;

    local procedure OpenWindow()
    begin
        if GuiAllowed then
            StatusWindow.Open(Text002);
    end;

    local procedure UpdateWindow(PeriodStartDate: Date; ItemNo: Code[20]; LotNo: Code[50])
    begin
        if GuiAllowed then begin
            StatusWindow.Update(1, PeriodStartDate);
            StatusWindow.Update(2, ItemNo);
            StatusWindow.Update(3, LotNo);
        end;
    end;

    local procedure CloseWindow()
    begin
        if GuiAllowed then
            StatusWindow.Close;
    end;

    local procedure AquireAdjmtLocks()
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemReg: Record "Item Register";
    begin
        ItemLedgEntry.LockTable;
        if ItemLedgEntry.FindLast then;
        ItemReg.LockTable;
        if ItemReg.FindLast then;
    end;

    local procedure RunInvtAdjmt()
    begin
        Clear(InvtAdjmt);
        InvtAdjmt.SetProperties(false, true);
        InvtAdjmt.MakeMultiLevelAdjmt;
        UpdateItemAnalysisView.UpdateAll(0, true);
        Commit;
    end;

    procedure UpdateCommOrderCosts()
    var
        PurchOrder: Record "Purchase Header";
    begin
        if GuiAllowed then begin
            if not Confirm(Text005, false) then
                exit;
            StatusWindow.Open(Text006);
        end;
        with PurchOrder do begin
            SetCurrentKey(
              "Buy-from Vendor No.", "Pay-to Vendor No.", "Commodity Item No.", "Commodity P.O. Type");
            SetFilter("Commodity Item No.", '<>%1', '');
            if FindSet then
                repeat
                    if GuiAllowed then
                        StatusWindow.Update(1, "No.");
                    CalcCommOrderCosts(PurchOrder, false);
                    Commit;
                until (Next = 0);
        end;
        if GuiAllowed then
            StatusWindow.Close;
    end;

    procedure CalcCommOrderCosts(var PurchOrder: Record "Purchase Header"; GenerateErrors: Boolean)
    var
        PurchLine: Record "Purchase Line";
        OrderIsReleased: Boolean;
        ReleasePurchDoc: Codeunit "Release Purchase Document";
    begin
        OrderIsReleased := (PurchOrder.Status = PurchOrder.Status::Released);
        if OrderIsReleased then
            ReleasePurchDoc.Reopen(PurchOrder);
        with PurchLine do begin
            SetRange("Document Type", PurchOrder."Document Type");
            SetRange("Document No.", PurchOrder."No.");
            SetFilter("Commodity Manifest No.", '<>%1', '');
            if FindSet then
                repeat
                    if CalcPurchLine(PurchLine, GenerateErrors) then
                        Modify(true);
                until (Next = 0);
        end;
        if OrderIsReleased then
            ReleasePurchDoc.Run(PurchOrder);
    end;

    local procedure CalcCommOrderLineCost(var PurchLine: Record "Purchase Line")
    var
        PurchOrder: Record "Purchase Header";
        OrderIsReleased: Boolean;
        ReleasePurchDoc: Codeunit "Release Purchase Document";
    begin
        with PurchLine do begin
            PurchOrder.Get("Document Type", "Document No.");
            OrderIsReleased := (PurchOrder.Status = PurchOrder.Status::Released);
            if OrderIsReleased then begin
                ReleasePurchDoc.Reopen(PurchOrder);
                Find;
            end;
            if CalcPurchLine(PurchLine, false) then
                Modify(true);
            if OrderIsReleased then
                ReleasePurchDoc.Run(PurchOrder);
        end;
    end;

    procedure CalcPurchLine(var PurchLine: Record "Purchase Line"; GenerateErrors: Boolean): Boolean
    begin
        GetSetup;
        with PurchLine do begin
            if ("Commodity P.O. Type" = "Commodity P.O. Type"::Hauler) then
                exit(CalcHaulerPurchLine(PurchLine, GenerateErrors));
            exit(CalcCommPurchLine(PurchLine, GenerateErrors));
        end;
    end;

    local procedure CalcCommPurchLine(var PurchLine: Record "Purchase Line"; GenerateErrors: Boolean): Boolean
    var
        OrigPurchLine: Record "Purchase Line";
        Item: Record Item;
        CommCostPeriod: Record "Commodity Cost Period";
        ErrorFound: Boolean;
        CommUnitCost: Decimal;
        CommUnitCostACY: Decimal;
    begin
        OrigPurchLine := PurchLine;
        with PurchLine do begin
            Item.Get("No.");
            // CALCFIELDS("Commodity Rejected"); // P8000926
            CalcCommProductRejected;             // P8000926
            if "Commodity Rejected" then
                GenerateErrors := false;
            if not FindCommCostPeriod("Location Code", "Commodity Received Date", GenerateErrors, CommCostPeriod) then
                ErrorFound := true
            else
                if not CalcCommUnitCost(
                         Item, "Variant Code", "Commodity Received Lot No.", "Comm. Payment Class Code",
                         "Commodity Received Date", CommCostPeriod, GenerateErrors, CommUnitCost, CommUnitCostACY)
                then
                    ErrorFound := true;
            Validate("Commodity Cost Calculated", not ErrorFound);
            if ErrorFound then
                Validate("Commodity Unit Cost", 0)
            else
                Validate("Commodity Unit Cost", RoundUnitAmount(CommUnitCost * "Qty. per Unit of Measure"));
            if "Commodity Rejected" and ("Rejection Action" > 0) then
                Validate("Direct Unit Cost", 0)
            else begin
                CalcFields("Blended Comm. Unit Cost");
                if ("Blended Comm. Unit Cost" <> 0) then
                    Validate("Direct Unit Cost", RoundUnitAmount("Blended Comm. Unit Cost" * "Qty. per Unit of Measure"))
                else
                    if "Commodity Cost Calculated" then
                        Validate("Direct Unit Cost", "Commodity Unit Cost");
            end;
            exit(("Commodity Cost Calculated" <> OrigPurchLine."Commodity Cost Calculated") or
                 ("Commodity Unit Cost" <> OrigPurchLine."Commodity Unit Cost") or
                 ("Direct Unit Cost" <> OrigPurchLine."Direct Unit Cost"));
        end;
    end;

    local procedure FindCommCostPeriod(LocationCode: Code[10]; PostingDate: Date; GenerateErrors: Boolean; var CommCostPeriod: Record "Commodity Cost Period"): Boolean
    begin
        with CommCostPeriod do begin
            SetCurrentKey("Location Code", "Starting Market Date");
            if InvtSetup."Commodity Cost by Location" then
                SetRange("Location Code", LocationCode);
            SetRange("Starting Market Date", 0D, PostingDate);
            if FindLast then
                exit(true);
            if GenerateErrors then
                FindLast;
        end;
    end;

    local procedure CalcHaulerPurchLine(var PurchLine: Record "Purchase Line"; GenerateErrors: Boolean): Boolean
    var
        OrigPurchLine: Record "Purchase Line";
        HaulerCharge: Record "Hauler Charge";
    begin
        OrigPurchLine := PurchLine;
        with PurchLine do begin
            if ("Producer Zone Code" = '') then
                Validate("Commodity Cost Calculated", false)
            else
                if not HaulerCharge.GetCharge(
                         "Buy-from Vendor No.", "Pay-to Vendor No.", "Location Code", "Producer Zone Code")
                then begin
                    if GenerateErrors then
                        HaulerCharge.Get("Buy-from Vendor No.", "Location Code", "Producer Zone Code");
                    Validate("Commodity Cost Calculated", false);
                end else begin
                    Validate("Commodity Cost Calculated", true);
                    Validate("Commodity Unit Cost", CalcHaulerCharge(PurchLine, HaulerCharge));
                end;
            if ("Direct Unit Cost" <> "Commodity Unit Cost") then
                Validate("Direct Unit Cost", "Commodity Unit Cost");
            exit(("Commodity Cost Calculated" <> OrigPurchLine."Commodity Cost Calculated") or
                 ("Commodity Unit Cost" <> OrigPurchLine."Commodity Unit Cost") or
                 ("Direct Unit Cost" <> OrigPurchLine."Direct Unit Cost"));
        end;
    end;

    local procedure CalcHaulerCharge(var PurchLine: Record "Purchase Line"; var HaulerCharge: Record "Hauler Charge"): Decimal
    var
        ToItemUOM: Record "Item Unit of Measure";
        FromUOM: Record "Unit of Measure";
        Item: Record Item;
        BaseQtyPerToUOM: Decimal;
    begin
        with PurchLine do begin
            if ("Unit of Measure Code" = HaulerCharge."Unit of Measure Code") then
                exit(HaulerCharge."Charge Unit Amount");
            CalcFields("Commodity Item No.");
            Item.Get("Commodity Item No.");
            ToItemUOM.Get("Commodity Item No.", "Unit of Measure Code");
            BaseQtyPerToUOM := CommItemMgmt.GetItemBaseQtyPerUOM(Item, ToItemUOM);
        end;
        with FromUOM do begin
            Get(HaulerCharge."Unit of Measure Code");
            case InvtSetup."Commodity UOM Type" of
                InvtSetup."Commodity UOM Type"::Weight:
                    TestField(Type, Type::Weight);
                InvtSetup."Commodity UOM Type"::Volume:
                    TestField(Type, Type::Volume);
            end;
            exit(RoundUnitAmount(HaulerCharge."Charge Unit Amount" * (BaseQtyPerToUOM / "Base per Unit of Measure")));
        end;
    end;

    procedure SetBlendedOrderCost(var PurchOrder: Record "Purchase Header"; NewUnitCost: Decimal)
    var
        OrderIsReleased: Boolean;
        ReleasePurchDoc: Codeunit "Release Purchase Document";
    begin
        OrderIsReleased := (PurchOrder.Status = PurchOrder.Status::Released);
        if OrderIsReleased then
            ReleasePurchDoc.Reopen(PurchOrder);
        PurchOrder.Validate("Blended Comm. Unit Cost", NewUnitCost);
        PurchOrder.Modify(true);
        if OrderIsReleased then
            ReleasePurchDoc.Run(PurchOrder);
    end;

    procedure UpdateOrderOnQCTest(var QCHeader: Record "Quality Control Header")
    var
        PurchLine: Record "Purchase Line";
    begin
        with PurchLine do begin
            SetCurrentKey(Type, "No.", "Variant Code", "Commodity Received Lot No.");
            SetRange(Type, Type::Item);
            SetRange("No.", QCHeader."Item No.");
            SetRange("Variant Code", QCHeader."Variant Code");
            SetRange("Commodity Received Lot No.", QCHeader."Lot No.");
            if FindSet then
                repeat
                    CalcCommOrderLineCost(PurchLine);
                until (Next = 0);
        end;
    end;

    procedure AddTempClassComponents(CommClassCode: Code[10]; var TempComponent: Record "Comm. Cost Component" temporary)
    var
        CommCostSetup: Record "Comm. Cost Setup Line";
        CommCostComponent: Record "Comm. Cost Component";
    begin
        with CommCostSetup do begin
            SetRange("Commodity Class Code", CommClassCode);
            if FindSet then
                repeat
                    CommCostComponent.Get("Comm. Cost Component Code");
                    if (CommCostComponent."Q/C Test Type" <> '') then
                        if not TempComponent.Get(CommCostComponent.Code) then begin
                            TempComponent := CommCostComponent;
                            TempComponent.Insert;
                        end;
                until (Next = 0);
        end;
    end;

    procedure GetQCTestError(ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50]; QCTestType: Code[10]; var ErrorMsg: Text[250]) ErrorFound: Boolean
    var
        QCLine: Record "Quality Control Line";
        QCHeader: Record "Quality Control Header";
    begin
        ErrorFound := true;
        Clear(ErrorMsg);
        QCLine.SetRange("Item No.", ItemNo);
        QCLine.SetRange("Variant Code", VariantCode);
        QCLine.SetRange("Lot No.", LotNo);
        QCLine.SetRange("Test Code", QCTestType);
        if QCLine.IsEmpty then
            ErrorMsg := QCRptText000
        else begin
            QCLine.FindLast;
            if not QCLine.Complete then
                ErrorMsg := QCRptText001
            else
                if (QCLine.Status <> QCLine.Status::Pass) then
                    ErrorMsg := QCRptText002
                else begin
                    QCHeader.Get(ItemNo, VariantCode, LotNo, QCLine."Test No.");
                    if (QCHeader.Status <> QCHeader.Status::Pass) then
                        ErrorMsg := QCRptText003
                    else
                        ErrorFound := false;
                end;
        end;
    end;

    procedure CalcAdvPaymentAmount(var PurchLine: Record "Purchase Line"; ValuationDate: Date) CommAmount: Decimal
    var
        Item: Record Item;
        CommCostPeriod: Record "Commodity Cost Period";
        CommUnitCost: Decimal;
        CommUnitCostACY: Decimal;
    begin
        with PurchLine do begin
            Item.Get("No.");
            // CALCFIELDS("Commodity Rejected"); // P8000926
            CalcCommProductRejected;             // P8000926
            if "Commodity Rejected" and ("Rejection Action" > 0) then
                exit(0);
            FindCommCostPeriod("Location Code", ValuationDate, true, CommCostPeriod);
            CalcCommUnitCost(
              Item, "Variant Code", "Commodity Received Lot No.", "Comm. Payment Class Code",
              ValuationDate, CommCostPeriod, true, CommUnitCost, CommUnitCostACY);
            CommUnitCost := RoundUnitAmount(CommUnitCost * "Qty. per Unit of Measure");
            exit(RoundAmount(CommUnitCost * "Quantity Received"));
        end;
    end;
}

