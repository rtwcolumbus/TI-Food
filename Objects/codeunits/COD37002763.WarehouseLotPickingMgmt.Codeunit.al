codeunit 37002763 "Warehouse Lot Picking Mgmt."
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 15 SEP 06
    //   Add Lot Warehouse Picking Method
    // 
    // PR5.00
    // P8000494A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Picking method
    // 
    // PRW16.00.01
    // P8000730, VerticalSoft, Don Bresee, 24 SEP 09
    //   Rework FEFO lot selection
    // 
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00


    trigger OnRun()
    begin
    end;

    var
        UsingPickMethod: Boolean;
        ProcessedLot: Record "Lot No. Information";
        ItemLedgEntry: Record "Item Ledger Entry";
        UseFEFO: Boolean;
        FEFOLot: Record "Lot No. Information";
        FindBlankExpDate: Boolean;
        LotStatusMgmt: Codeunit "Lot Status Management";

    procedure StartLotPicking(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; var WhseItemTrkgExists: Boolean; var LotNo: Code[50]; LotStatusExclusionFilter: Text[1024])
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        // P8001083 - add parameter for LotStatusExclusionFilter
        ClearAll;
        if not WhseItemTrkgExists then begin
            Item.Get(ItemNo);
            if (Item."Item Tracking Code" <> '') then
                with ItemTrackingCode do begin
                    Get(Item."Item Tracking Code");
                    if "Lot Warehouse Tracking" and
                       ("Lot Warehouse Picking Method" > "Lot Warehouse Picking Method"::None)
                    then
                        if FindFirstLotNo(
                             ItemTrackingCode, LocationCode, ItemNo, VariantCode, LotNo, LotStatusExclusionFilter) // P8001083
                        then begin
                            UsingPickMethod := true;
                            WhseItemTrkgExists := true;
                        end;
                end;
        end;
    end;

    procedure LotPickingComplete(var WhseItemTrkgExists: Boolean; var LotNo: Code[50]; LotStatusExclusionFilter: Text[1024]; TotalQtytoPick: Decimal; TotalQtytoPickBase: Decimal): Boolean
    begin
        // P8001083 - add parameter for LotStatusExclusionFilter
        if not UsingPickMethod then
            exit(true);
        if (TotalQtytoPick <> 0) or (TotalQtytoPickBase <> 0) then
            if FindNextLotNo(LotNo, LotStatusExclusionFilter) then // P8001083
                exit(false);
        WhseItemTrkgExists := false;
        LotNo := '';
        exit(true);
    end;

    local procedure FindFirstLotNo(var ItemTrackingCode: Record "Item Tracking Code"; LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; var LotNo: Code[50]; LotStatusExclusionFilter: Text[1024]): Boolean
    begin
        // P8001083 - add parameter for LotStatusExclusionFilter
        with ItemLedgEntry do begin
            Reset;
            case ItemTrackingCode."Lot Warehouse Picking Method" of
                ItemTrackingCode."Lot Warehouse Picking Method"::FEFO:
                    begin
                        UseFEFO := true;                                                                // P8000730
                        SetCurrentKey(                                                                  // P8000730
                          "Location Code", "Item No.", "Variant Code", Open, Positive, "Posting Date"); // P8000730
                    end;
                ItemTrackingCode."Lot Warehouse Picking Method"::FIFO:
                    SetCurrentKey(
                      "Location Code", "Item No.", "Variant Code", Open, Positive, "Posting Date");
                ItemTrackingCode."Lot Warehouse Picking Method"::LIFO:
                    begin
                        SetCurrentKey(
                          "Location Code", "Item No.", "Variant Code", Open, Positive, "Posting Date");
                        Ascending(false);
                    end;
            end;
            SetRange("Location Code", LocationCode);
            SetRange("Item No.", ItemNo);
            SetRange("Variant Code", VariantCode);
            SetRange(Open, true);
            SetRange(Positive, true);
            if not Find('-') then
                exit(false);
        end;
        if UseFEFO then                                                       // P8000730
            exit(FindFirstFEFOLotNo(LocationCode, ItemNo, VariantCode, LotNo, LotStatusExclusionFilter)); // P8000730, P81001083
        exit(FindUnprocessedLot(LotNo, LotStatusExclusionFilter)); // P8001083
    end;

    local procedure FindNextLotNo(var LotNo: Code[50]; LotStatusExclusionFilter: Text[1024]): Boolean
    begin
        // P8001083 - add parameter for LotStatusExclusionFilter
        if UseFEFO then                   // P8000730
            exit(FindNextFEFOLotNo(LotNo)); // P8000730
        if (ItemLedgEntry.Next = 0) then
            exit(false);
        exit(FindUnprocessedLot(LotNo, LotStatusExclusionFilter)); // P8001083
    end;

    local procedure FindUnprocessedLot(var LotNo: Code[50]; LotStatusExclusionFilter: Text[1024]): Boolean
    begin
        // P8001083 - add parameter for LotStatusExclusionFilter
        with ItemLedgEntry do
            repeat
                if ProcessedLot.Get("Item No.", "Variant Code", "Lot No.") then
                    if not ProcessedLot.Mark then begin
                        ProcessedLot.Mark(true);
                        //IF (NOT ProcessedLot.Blocked) THEN BEGIN                                              // P8001083
                        if (not LotStatusMgmt.ExcludeLotInfo(ProcessedLot, LotStatusExclusionFilter)) then begin // P8001083
                            LotNo := ProcessedLot."Lot No.";
                            exit(true);
                        end;
                    end;
            until (Next = 0);
        exit(false);
    end;

    local procedure FindFirstFEFOLotNo(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; var LotNo: Code[50]; LotStatusExclusionFilter: Text[1024]): Boolean
    begin
        // P8000730
        // P8001083 - add parameter for LotStatusExclusionFilter
        with FEFOLot do begin
            repeat
                if Get(ItemNo, VariantCode, ItemLedgEntry."Lot No.") then
                    //IF NOT Blocked THEN                                                      // P8001083
                    if not LotStatusMgmt.ExcludeLotInfo(FEFOLot, LotStatusExclusionFilter) then // P8001083
                        Mark(true);
            until (ItemLedgEntry.Next = 0);
            MarkedOnly(true);
            SetCurrentKey("Item No.", "Variant Code", "Expiration Date");
            SetRange("Item No.", ItemNo);
            SetRange("Variant Code", VariantCode);
            SetFilter("Expiration Date", '<>%1', 0D);
            if FindSet then begin
                LotNo := "Lot No.";
                exit(true);
            end;
            FindBlankExpDate := true;
            SetRange("Expiration Date", 0D);
            if FindSet then begin
                LotNo := "Lot No.";
                exit(true);
            end;
        end;
        exit(false);
    end;

    local procedure FindNextFEFOLotNo(var LotNo: Code[50]): Boolean
    begin
        // P8000730
        with FEFOLot do begin
            if (Next <> 0) then begin
                LotNo := "Lot No.";
                exit(true);
            end;
            if not FindBlankExpDate then begin
                FindBlankExpDate := true;
                SetRange("Expiration Date", 0D);
                if FindSet then begin
                    LotNo := "Lot No.";
                    exit(true);
                end;
            end;
        end;
        exit(false);
    end;

    procedure StartPickSuggestions(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; var LotNo: Code[50]; LotStatusExclusionFilter: Text[1024])
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        // P8000503A
        // P8001083 - add parameter for LotStatusExclusionFilter
        ClearAll;
        Item.Get(ItemNo);
        if (Item."Item Tracking Code" <> '') then
            with ItemTrackingCode do begin
                Get(Item."Item Tracking Code");
                if "Lot Warehouse Tracking" and
                   ("Lot Warehouse Picking Method" > "Lot Warehouse Picking Method"::None)
                then
                    if FindFirstLotNo(
                         ItemTrackingCode, LocationCode, ItemNo, VariantCode, LotNo, LotStatusExclusionFilter) // P8001083
                    then
                        UsingPickMethod := true;
            end;
    end;

    procedure PickSuggestionsComplete(var LotNo: Code[50]; LotStatusExclusionFilter: Text[1024]): Boolean
    begin
        // P8000503A
        // P8001083 - add parameter for LotStatusExclusionFilter
        if not UsingPickMethod then
            exit(true);
        if FindNextLotNo(LotNo, LotStatusExclusionFilter) then // P8001083
            exit(false);
        LotNo := '';
        exit(true);
    end;
}

