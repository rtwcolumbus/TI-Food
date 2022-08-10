codeunit 37002017 "Rounding Adjustment Mgmt."
{
    // PRW15.00.01
    // P8000548A, VerticalSoft, Don Bresee, 05 MAR 08
    //   Add logic for Rounding Adjustments
    // 
    // PRW16.00.06
    // P8001039, Columbus IT, Don Bresee, 26 FEB 12
    //   Add Rounding Adjustment logic for Warehouse
    //   Add "Near-Zero Qty. Value" field to Item
    // 
    // P8001067, Columbus IT, Don Bresee, 09 MAY 12
    //   Add special Rounding Adjmts. logic for transfer entries
    // 
    // P8001091, Columbus IT, Don Bresee, 15 AUG 12
    //   Eliminate near-zero logic when posting positive entries
    // 
    // P8001110, Columbus IT, Don Bresee, 25 OCT 12
    //   Add new type of Near-Zero adjustment (remove excess alt. qty. when qty. is zero, 1-doc locations)
    // 
    // P8001127, Columbus IT, Don Bresee, 15 JAN 13
    //   Complete rework of AdjustWhseMovementQtys routine
    //   Change to bin quantity logic to use appropriate UOM based on location
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.10.01
    // P8001249, Columbus IT, Jack Reynolds, 13 DEC 13
    //   Fix problem posting fixed weight adjustments for consumption entries
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00


    trigger OnRun()
    begin
    end;

    var
        FixedAltEntryToAdjust: Record "Item Ledger Entry" temporary;
        FixedAltAdjmtsToPost: Boolean;
        NearZeroEntryToAdjust: Record "Item Ledger Entry" temporary;
        Item: Record Item;
        OrigItemJnlLine: Record "Item Journal Line";
        OrigItemLedgEntry: Record "Item Ledger Entry";
        OrigValueEntry: Record "Value Entry";
        OrigTempTrackingSpec: Record "Tracking Specification" temporary;
        InvtSetup: Record "Inventory Setup";
        InvtSetupRead: Boolean;
        DimMgt: Codeunit DimensionManagement;
        BaseQtyHandled: Decimal;
        AltQtyHandled: Decimal;
        Location: Record Location;
        NearZeroWhseJnlLine: Record "Warehouse Journal Line" temporary;
        WMSMgmt: Codeunit "WMS Management";
        WhseMovementSourceLine: Record "Warehouse Journal Line" temporary;
        WhseMovementSourceLineNo: Integer;
        NearZeroDirectedWhseEntry: Record "Warehouse Entry" temporary;
        P800UOMMgmt: Codeunit "Process 800 UOM Functions";

    procedure PreProcessApplQtys(var ItemLedgEntry: Record "Item Ledger Entry"; var OldItemLedgEntry: Record "Item Ledger Entry"; AppliedQty: Decimal; var AppliedAltQty: Decimal)
    begin
        with ItemLedgEntry do
            if ("Rounding Adjustment Type" = 0) and ((AppliedQty <> 0) or (AppliedAltQty <> 0)) then
                if IsBasicOrNonWhseLocation("Location Code") then // P8001039
                    if IsFixedAltItem("Item No.") then
                        AdjustFixedAltQtyApplied(ItemLedgEntry, OldItemLedgEntry, AppliedQty, AppliedAltQty);
    end;

    local procedure AdjustFixedAltQtyApplied(var ItemLedgEntry: Record "Item Ledger Entry"; var OldItemLedgEntry: Record "Item Ledger Entry"; AppliedQty: Decimal; var AppliedAltQty: Decimal)
    var
        AdjustQty: Decimal;
    begin
        if (AppliedQty = 0) then
            AppliedAltQty := 0
        else
            if FixedAltQtyAdjmtNeeded(OldItemLedgEntry, AppliedQty, AppliedAltQty, AdjustQty) then
                if AdjmtApplicationAllowed(OldItemLedgEntry, AdjustQty) then
                    AddFixedAltQtyAdjmtQty(OldItemLedgEntry, AdjustQty)
                else
                    AppliedAltQty := AppliedAltQty + AdjustQty;
    end;

    local procedure FixedAltQtyAdjmtNeeded(var ItemLedgEntry: Record "Item Ledger Entry"; ApplQty: Decimal; ApplQtyAlt: Decimal; var AdjustQty: Decimal): Boolean
    var
        RemQty: Decimal;
        RemQtyAlt: Decimal;
    begin
        with ItemLedgEntry do begin
            AddItemEntryRemQtys(ItemLedgEntry, RemQty, RemQtyAlt);
            RemQty := RemQty + ApplQty;
            RemQtyAlt := RemQtyAlt + ApplQtyAlt;
            AdjustQty := Round(RemQty * Item.AlternateQtyPerBase(), 0.00001) - RemQtyAlt;
            exit(AdjustQty <> 0);
        end;
    end;

    local procedure AddItemEntryRemQtys(var ItemLedgEntry: Record "Item Ledger Entry"; var RemQty: Decimal; var RemQtyAlt: Decimal)
    begin
        with ItemLedgEntry do begin
            RemQty := RemQty + "Remaining Quantity";
            RemQtyAlt := RemQtyAlt + ("Remaining Quantity (Alt.)" + GetFixedAltQtyAdjmtQty(ItemLedgEntry));
        end;
    end;

    local procedure GetFixedAltQtyAdjmtQty(var ItemLedgEntry: Record "Item Ledger Entry"): Decimal
    begin
        with FixedAltEntryToAdjust do
            if Get(ItemLedgEntry."Entry No.") then
                exit("Quantity (Alt.)");
        exit(0);
    end;

    local procedure AdjmtApplicationAllowed(var ItemLedgEntry: Record "Item Ledger Entry"; AdjustQty: Decimal): Boolean
    begin
        if ItemLedgEntry.Positive then
            exit(AdjustQty < 0);
        exit(AdjustQty > 0);
    end;

    local procedure AddFixedAltQtyAdjmtQty(var ItemLedgEntry: Record "Item Ledger Entry"; AdjustQty: Decimal)
    begin
        with FixedAltEntryToAdjust do
            if not Get(ItemLedgEntry."Entry No.") then begin
                FixedAltEntryToAdjust := ItemLedgEntry;
                "Quantity (Alt.)" := AdjustQty;
                Insert;
            end else begin
                "Quantity (Alt.)" := "Quantity (Alt.)" + AdjustQty;
                if ("Quantity (Alt.)" = 0) then
                    Delete
                else
                    Modify;
            end;
    end;

    procedure ProcessNewEntry(var ItemJnlLine: Record "Item Journal Line"; var ItemLedgEntry: Record "Item Ledger Entry")
    begin
        // P8001039 - Add "ItemJnlLine" parameter
        with ItemLedgEntry do
            if ("Rounding Adjustment Type" = 0) then
                if IsBasicOrNonWhseLocation("Location Code") then begin // P8001039
                    if IsFixedAltItem("Item No.") then
                        AdjustNewOpenFixedAltQty(ItemLedgEntry);
                    if not Positive then begin // P8001091
                        AdjustNearZeroRemaining(ItemLedgEntry);
                        AdjustWhseNearZeroRemaining(ItemJnlLine, ItemLedgEntry); // P8001039
                    end; // P8001091
                    if Item."Catch Alternate Qtys." and IsWhseLocation("Location Code") then // P8001110
                        AddOpenAltQtyAdjustment(ItemLedgEntry);                                // P8001110
                end;
    end;

    local procedure AdjustNewOpenFixedAltQty(var ItemLedgEntry: Record "Item Ledger Entry")
    var
        AdjustQty: Decimal;
    begin
        if FixedAltQtyAdjmtNeeded(ItemLedgEntry, 0, 0, AdjustQty) then
            if AdjmtApplicationAllowed(ItemLedgEntry, AdjustQty) then
                AddFixedAltQtyAdjmtQty(ItemLedgEntry, AdjustQty);
    end;

    local procedure AdjustNearZeroRemaining(var ItemLedgEntry: Record "Item Ledger Entry")
    var
        OpenItemLedgEntry: Record "Item Ledger Entry";
        EndLoop: Boolean;
        RemQty: Decimal;
        RemQtyAlt: Decimal;
        AdjustQty: Decimal;
        AdjustQtyAlt: Decimal;
    begin
        GetInvtSetup;
        // IF (InvtSetup."Near-Zero Qty. Value" > 0) THEN BEGIN // P8001039
        if (GetNearZeroQty() > 0) then begin                    // P8001039
            GetItem(ItemLedgEntry."Item No.");
            if NearZeroAdjmtNotNeeded(ItemLedgEntry, RemQty, RemQtyAlt) then
                exit;
            SetOpenItemLedgFilters(ItemLedgEntry, OpenItemLedgEntry);
            with OpenItemLedgEntry do
                if Find('-') then
                    repeat
                        if NearZeroAdjmtNotNeeded(OpenItemLedgEntry, RemQty, RemQtyAlt) then
                            exit;
                    until (Next = 0);
            if IsFixedAltItem(ItemLedgEntry."Item No.") then begin
                if QtyIsNearZero(RemQty) then begin
                    AdjustQty := -RemQty;
                    AdjustQtyAlt := -RemQtyAlt;
                end;
            end else begin
                if QtyIsNearZero(RemQty) then
                    AdjustQty := -RemQty;
                if QtyIsNearZero(RemQtyAlt) then
                    AdjustQtyAlt := -RemQtyAlt;
            end;
            if (AdjustQty <> 0) or (AdjustQtyAlt <> 0) then begin
                NearZeroEntryToAdjust := ItemLedgEntry;
                NearZeroEntryToAdjust.Quantity := AdjustQty;
                NearZeroEntryToAdjust."Quantity (Alt.)" := AdjustQtyAlt;
                NearZeroEntryToAdjust.Insert;
            end;
        end;
    end;

    local procedure NearZeroAdjmtNotNeeded(var ItemLedgEntry: Record "Item Ledger Entry"; var RemQty: Decimal; var RemQtyAlt: Decimal): Boolean
    begin
        AddItemEntryRemQtys(ItemLedgEntry, RemQty, RemQtyAlt);
        if QtyIsNearZero(RemQty) then
            exit(false);
        if Item.TrackAlternateUnits() and Item."Catch Alternate Qtys." then
            if QtyIsNearZero(RemQtyAlt) then
                exit(false);
        exit(true);
    end;

    local procedure QtyIsNearZero(Qty: Decimal): Boolean
    begin
        // EXIT(ABS(Qty) <= InvtSetup."Near-Zero Qty. Value"); // P8001039
        exit(Abs(Qty) <= GetNearZeroQty());                    // P8001039
    end;

    local procedure SetOpenItemLedgFilters(var ItemLedgEntry: Record "Item Ledger Entry"; var OpenItemLedgEntry: Record "Item Ledger Entry")
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        with OpenItemLedgEntry do begin
            Reset;
            SetCurrentKey(
              "Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date");
            SetRange("Item No.", ItemLedgEntry."Item No.");
            SetRange(Open, true);
            SetRange("Variant Code", ItemLedgEntry."Variant Code");
            SetRange("Location Code", ItemLedgEntry."Location Code");

            SetFilter("Entry No.", '<>%1', ItemLedgEntry."Entry No.");

            if ItemLedgEntry."Job Purchase" then begin
                SetRange("Job No.", ItemLedgEntry."Job No.");
                SetRange("Job Task No.", ItemLedgEntry."Job Task No.");
            end;

            GetItem(ItemLedgEntry."Item No.");
            if ItemTrackingCode.Get(Item."Item Tracking Code") then begin
                if ItemTrackingCode."SN Specific Tracking" then
                    SetRange("Serial No.", ItemLedgEntry."Serial No.");
                if ItemTrackingCode."Lot Specific Tracking" then
                    SetRange("Lot No.", ItemLedgEntry."Lot No.");
            end;

            // IF Location.GET(ItemLedgEntry."Location Code") THEN // P8001039
            if GetLocation(ItemLedgEntry."Location Code") then     // P8001039
                if Location."Use As In-Transit" then
                    SetRange("Order No.", ItemLedgEntry."Order No."); // P8001132
        end;
    end;

    procedure FixedAltQtyApplComplete(var ItemLedgEntry: Record "Item Ledger Entry"): Boolean
    begin
        with ItemLedgEntry do
            if IsBasicOrNonWhseLocation("Location Code") then // P8001039
                if IsFixedAltItem("Item No.") then
                    exit("Remaining Quantity" + "Reserved Quantity" = 0);
        exit(false);
    end;

    procedure EntryOpenAfterAdjustments(var ItemLedgEntry: Record "Item Ledger Entry"): Boolean
    var
        RemQty: Decimal;
        RemQtyAlt: Decimal;
    begin
        if not ItemLedgEntry.Open then
            exit(false);
        AddItemEntryRemQtys(ItemLedgEntry, RemQty, RemQtyAlt);
        if (RemQty = 0) and (RemQtyAlt = 0) then
            exit(false);
        with NearZeroEntryToAdjust do
            if Get(ItemLedgEntry."Entry No.") then begin
                if (Quantity <> 0) then
                    RemQty := 0;
                if ("Quantity (Alt.)" <> 0) then
                    RemQtyAlt := 0;
            end;
        exit((RemQty <> 0) or (RemQtyAlt <> 0));
    end;

    local procedure IsFixedAltItem(ItemNo: Code[20]): Boolean
    begin
        GetItem(ItemNo);
        exit((Item."Alternate Unit of Measure" <> '') and (not Item."Catch Alternate Qtys."));
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        if (Item."No." <> ItemNo) then
            Item.Get(ItemNo);
    end;

    local procedure GetInvtSetup()
    begin
        if not InvtSetupRead then begin
            InvtSetup.Get;
            InvtSetupRead := true;
        end;
    end;

    procedure AdjustmentsToPost(): Boolean
    begin
        FixedAltAdjmtsToPost := FixedAltEntryToAdjust.FindFirst;
        if FixedAltAdjmtsToPost then
            exit(true);
        exit(NearZeroEntryToAdjust.FindFirst);
    end;

    procedure BuildAdjustmentJnlLine(var ItemJnlLine: Record "Item Journal Line")
    begin
        // P8001133 - remove parameter for TempJnlLineDim
        if FixedAltAdjmtsToPost then
            with FixedAltEntryToAdjust do begin
                BuildItemJnlLine(
                  ItemJnlLine, 0, "Quantity (Alt.)", FixedAltEntryToAdjust,
                  "Rounding Adjustment Type"::"Fixed Alt. Qty.", "Entry No."); // P8001133
                Delete;
            end
        else
            with NearZeroEntryToAdjust do
                if (Quantity * "Quantity (Alt.)" >= 0) then begin
                    BuildItemJnlLine(
                      ItemJnlLine, Quantity, "Quantity (Alt.)", NearZeroEntryToAdjust,
                      "Rounding Adjustment Type"::"Near-Zero", 0); // P8001133
                    Delete;
                end else begin
                    BuildItemJnlLine(
                      ItemJnlLine, Quantity, 0, NearZeroEntryToAdjust,
                      "Rounding Adjustment Type"::"Near-Zero", 0); // P8001133
                    Quantity := 0;
                    Modify;
                end;
    end;

    local procedure BuildItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; Qty: Decimal; QtyAlt: Decimal; var ReferenceEntry: Record "Item Ledger Entry"; AdjustmentType: Integer; ApplToEntryNo: Integer)
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        // P8001133 - remove parameter for TempJnlLineDim
        with ItemJnlLine do begin
            Init;
            if (Qty < 0) or (QtyAlt < 0) then
                Validate("Entry Type", "Entry Type"::"Negative Adjmt.")
            else
                Validate("Entry Type", "Entry Type"::"Positive Adjmt.");

            Validate("Posting Date", OrigItemJnlLine."Posting Date");
            Validate("Document No.", OrigItemJnlLine."Document No.");
            Validate("Document Date", OrigItemJnlLine."Document Date");
            "Source Code" := OrigItemJnlLine."Source Code";

            Validate("Item No.", ReferenceEntry."Item No.");
            Validate("Variant Code", ReferenceEntry."Variant Code");
            Validate("Location Code", ReferenceEntry."Location Code");
            "Lot No." := ReferenceEntry."Lot No.";
            "Serial No." := ReferenceEntry."Serial No.";
            if ReferenceEntry."Order Type" = ReferenceEntry."Order Type"::Transfer then begin // P8001249
                "Order Type" := ReferenceEntry."Order Type"; // P8001132
                "Order No." := ReferenceEntry."Order No.";   // P8001132
            end;                                                                              // P8001249

            "Rounding Adjustment Type" := AdjustmentType;
            "Applies-to Entry" := ApplToEntryNo;
            Quantity := Abs(Qty);
            "Invoiced Quantity" := Abs(Qty);
            "Quantity (Base)" := Abs(Qty);
            "Invoiced Qty. (Base)" := Abs(Qty);
            "Quantity (Alt.)" := Abs(QtyAlt);
            "Invoiced Qty. (Alt.)" := Abs(QtyAlt);

            Validate("Unit Cost", 0);

            TableID[1] := DATABASE::Item;
            No[1] := "Item No.";
            "Shortcut Dimension 1 Code" := '';
            "Shortcut Dimension 2 Code" := '';
            "Dimension Set ID" := DimMgt.GetDefaultDimID( // P8001133
              TableID, No, "Source Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0); // P8001133

            if ("Rounding Adjustment Type" = "Rounding Adjustment Type"::"Near-Zero") then // P8001039
                AddNearZeroWhseAdjmt(ItemJnlLine, ReferenceEntry);                            // P8001039
        end;
    end;

    procedure SaveItemPostingData(var ItemJnlLine: Record "Item Journal Line"; var ItemLedgEntry: Record "Item Ledger Entry"; var ValueEntry: Record "Value Entry"; var TempTrackingSpec: Record "Tracking Specification")
    begin
        // P8001133 - remove parameter for TempJnlLineDim
        OrigItemJnlLine := ItemJnlLine;
        OrigItemLedgEntry := ItemLedgEntry;
        OrigValueEntry := ValueEntry;
        CopyTrackingSpec(TempTrackingSpec, OrigTempTrackingSpec);
    end;

    procedure RestoreItemPostingData(var ItemJnlLine: Record "Item Journal Line"; var ItemLedgEntry: Record "Item Ledger Entry"; var ValueEntry: Record "Value Entry"; var TempTrackingSpec: Record "Tracking Specification")
    begin
        // P8001133 - remove parameter for TempJnlLineDim
        ItemJnlLine := OrigItemJnlLine;
        ItemLedgEntry := OrigItemLedgEntry;
        ValueEntry := OrigValueEntry;
        CopyTrackingSpec(OrigTempTrackingSpec, TempTrackingSpec);
    end;

    local procedure CopyTrackingSpec(var FromTrackingSpec: Record "Tracking Specification"; var ToTrackingSpec: Record "Tracking Specification")
    begin
        ToTrackingSpec.DeleteAll;
        if FromTrackingSpec.FindSet then
            repeat
                ToTrackingSpec := FromTrackingSpec;
                ToTrackingSpec.Insert;
            until (FromTrackingSpec.Next = 0);
    end;

    procedure SetFixedAltQtySalesLine(var SalesLine: Record "Sales Line")
    begin
        with SalesLine do
            if ("Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]) then
                SetFixedAltQtyTrackingQtys("Return Qty. Received (Base)", "Return Qty. Received (Alt.)")
            else
                SetFixedAltQtyTrackingQtys(-"Qty. Shipped (Base)", -"Qty. Shipped (Alt.)");
    end;

    procedure SetFixedAltQtyPurchLine(var PurchLine: Record "Purchase Line")
    begin
        with PurchLine do
            if ("Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]) then
                SetFixedAltQtyTrackingQtys(-"Return Qty. Shipped (Base)", -"Return Qty. Shipped (Alt.)")
            else
                SetFixedAltQtyTrackingQtys("Qty. Received (Base)", "Qty. Received (Alt.)");
    end;

    procedure SetFixedAltQtyTransLine(var TransLine: Record "Transfer Line"; Direction: Option Outbound,Inbound)
    begin
        with TransLine do
            if (Direction = Direction::Outbound) then
                SetFixedAltQtyTrackingQtys(-"Qty. Shipped (Base)", -"Qty. Shipped (Alt.)")
            else
                SetFixedAltQtyTrackingQtys("Qty. Received (Base)", "Qty. Received (Alt.)");
    end;

    procedure AdjustItemJnlFixedAltQty(var ItemJnlLine: Record "Item Journal Line")
    begin
        with ItemJnlLine do
            AdjustFixedAltQtyTracking(
              "Item No.", DATABASE::"Item Journal Line", "Entry Type",
              "Journal Template Name", "Journal Batch Name", 0, "Line No.");
    end;

    local procedure SetFixedAltQtyTrackingQtys(NewBaseQtyHandled: Decimal; NewAltQtyHandled: Decimal)
    begin
        BaseQtyHandled := NewBaseQtyHandled;
        AltQtyHandled := NewAltQtyHandled;
    end;

    local procedure AdjustFixedAltQtyTracking(ItemNo: Code[20]; SourceType: Integer; SourceSubtype: Integer; SourceID: Code[20]; SourceBatchName: Code[10]; SourceProdOrderLine: Integer; SourceRefNo: Integer)
    var
        ReservEntry: Record "Reservation Entry";
        AltQtyAdjmt: Decimal;
    begin
        if IsFixedAltItem(ItemNo) then
            with ReservEntry do begin
                SetCurrentKey(
                  "Source ID", "Source Ref. No.", "Source Type", "Source Subtype",
                  "Source Batch Name", "Source Prod. Order Line", "Reservation Status");
                SetRange("Source Type", SourceType);
                SetRange("Source Subtype", SourceSubtype);
                SetRange("Source ID", SourceID);
                SetRange("Source Batch Name", SourceBatchName);
                SetRange("Source Prod. Order Line", SourceProdOrderLine);
                SetRange("Source Ref. No.", SourceRefNo);
                if FindSet then
                    repeat
                        BaseQtyHandled := BaseQtyHandled + "Qty. to Handle (Base)";
                        AltQtyHandled := AltQtyHandled + "Qty. to Handle (Alt.)";
                        AltQtyAdjmt := Round(BaseQtyHandled * Item.AlternateQtyPerBase(), 0.00001) - AltQtyHandled;
                        if (AltQtyAdjmt <> 0) then begin
                            AltQtyHandled := AltQtyHandled + AltQtyAdjmt;
                            "Qty. to Handle (Alt.)" := "Qty. to Handle (Alt.)" + AltQtyAdjmt;
                            if ("Qty. to Handle (Base)" = "Quantity (Base)") then
                                "Quantity (Alt.)" := "Qty. to Handle (Alt.)";
                            if ("Qty. to Invoice (Base)" = "Quantity (Base)") then
                                "Qty. to Invoice (Alt.)" := "Quantity (Alt.)"
                            else
                                if ("Qty. to Invoice (Base)" = "Qty. to Handle (Base)") then
                                    "Qty. to Invoice (Alt.)" := "Qty. to Handle (Alt.)";
                            Modify;
                        end;
                    until (Next = 0);
            end;
    end;

    local procedure GetLocation(LocationCode: Code[10]): Boolean
    begin
        // P8001039
        if (Location.Code <> '') then begin
            if (Location.Code = LocationCode) then
                exit(true);
            Clear(Location);
        end;
        exit(Location.Get(LocationCode));
    end;

    local procedure IsWhseLocation(LocationCode: Code[10]): Boolean
    begin
        // P8001039
        if GetLocation(LocationCode) then
            exit(Location."Bin Mandatory");
    end;

    local procedure IsDirectedWhseLocation(LocationCode: Code[10]): Boolean
    begin
        // P8001039
        if GetLocation(LocationCode) then
            exit(Location."Directed Put-away and Pick");
    end;

    local procedure IsBasicOrNonWhseLocation(LocationCode: Code[10]): Boolean
    begin
        // P8001039
        if GetLocation(LocationCode) then
            exit(not Location."Directed Put-away and Pick");
        exit(true);
    end;

    local procedure GetNearZeroQty(): Decimal
    begin
        // P8001039
        if (Item."Near-Zero Qty. Value" <> 0) then
            exit(Item."Near-Zero Qty. Value");
        exit(InvtSetup."Near-Zero Qty. Value");
    end;

    procedure GetNearZeroQtyForItem(ItemNo: Code[20]): Decimal
    begin
        // P8001039
        GetItem(ItemNo);
        if (Item."Near-Zero Qty. Value" <> 0) then
            exit(Item."Near-Zero Qty. Value");
        GetInvtSetup;
        exit(InvtSetup."Near-Zero Qty. Value");
    end;

    local procedure AdjustWhseNearZeroRemaining(var ItemJnlLine: Record "Item Journal Line"; var ItemLedgEntry: Record "Item Ledger Entry")
    var
        BinQty: Decimal;
        BinQtyBase: Decimal;
    begin
        // P8001039
        if (GetNearZeroQty() > 0) and (not NearZeroEntryToAdjust.Get(ItemLedgEntry."Entry No.")) then
            if IsWhseLocation(ItemLedgEntry."Location Code") then
                with ItemJnlLine do begin
                    GetWhseBinQtys(
                      // "Item No.","Variant Code","Location Code","Bin Code",WMSMgmt.GetBaseUOM("Item No."), // P8001127
                      "Item No.", "Variant Code", "Location Code", "Bin Code", "Unit of Measure Code",            // P8001127
                      "Lot No.", "Serial No.", BinQty, BinQtyBase);
                    // IF QtyIsNearZero(BinQty + Signed("Quantity (Base)")) THEN BEGIN  // P8001127
                    if QtyIsNearZero(BinQtyBase + Signed("Quantity (Base)")) then begin // P8001127
                        NearZeroEntryToAdjust := ItemLedgEntry;
                        // NearZeroEntryToAdjust.Quantity := -(BinQty + Signed("Quantity (Base)"));  // P8001127
                        NearZeroEntryToAdjust.Quantity := -(BinQtyBase + Signed("Quantity (Base)")); // P8001127
                        NearZeroEntryToAdjust."Quantity (Alt.)" := 0;
                        NearZeroEntryToAdjust.Insert;
                    end;
                end;
    end;

    local procedure GetWhseBinQtys(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; BinCode: Code[20]; UOMCode: Code[10]; LotNo: Code[50]; SerialNo: Code[50]; var BinQty: Decimal; var BinQtyBase: Decimal)
    var
        WhseEntry: Record "Warehouse Entry";
    begin
        // P8001039
        with WhseEntry do begin
            SetCurrentKey(
              "Item No.", "Bin Code", "Location Code", "Variant Code",
              "Unit of Measure Code", "Lot No.", "Serial No.");
            SetRange("Item No.", ItemNo);
            SetRange("Bin Code", BinCode);
            SetRange("Location Code", LocationCode);
            SetRange("Variant Code", VariantCode);
            // SETRANGE("Unit of Measure Code",UOMCode);                              // P8001127
            SetRange("Unit of Measure Code", GetWhseUOM(ItemNo, LocationCode, UOMCode)); // P8001127
            SetRange("Lot No.", LotNo);
            SetRange("Serial No.", SerialNo);
            CalcSums(Quantity, "Qty. (Base)");
            BinQty := Quantity;
            BinQtyBase := "Qty. (Base)";
        end;
    end;

    procedure GetWhseAdustedQty(var WhseEntry: Record "Warehouse Entry") AdjustedQty: Decimal
    begin
        // P8001039
        if IsDirectedWhseLocation(WhseEntry.GetFilter("Location Code")) then
            with NearZeroDirectedWhseEntry do begin
                Copy(WhseEntry);
                CalcSums(Quantity);
                AdjustedQty := WhseEntry.Quantity + Quantity;
                Reset;
            end
        else
            with NearZeroWhseJnlLine do begin
                AdjustedQty := WhseEntry.Quantity;
                WhseEntry.CopyFilter("Item No.", "Item No.");
                WhseEntry.CopyFilter("Variant Code", "Variant Code");
                WhseEntry.CopyFilter("Location Code", "Location Code");
                WhseEntry.CopyFilter("Bin Code", "To Bin Code");
                WhseEntry.CopyFilter("Lot No.", "Lot No.");
                WhseEntry.CopyFilter("Serial No.", "Serial No.");
                if FindSet then
                    repeat
                        AdjustedQty := AdjustedQty + Quantity;
                    until (Next = 0);
                SetRange("To Bin Code");
                WhseEntry.CopyFilter("Bin Code", "From Bin Code");
                if FindSet then
                    repeat
                        AdjustedQty := AdjustedQty - Quantity;
                    until (Next = 0);
                Reset;
            end;
    end;

    local procedure AddNearZeroWhseAdjmt(var ItemJnlLine: Record "Item Journal Line"; var ReferenceEntry: Record "Item Ledger Entry")
    begin
        // P8001039
        if (ItemJnlLine.Quantity <> 0) then
            if IsWhseLocation(ItemJnlLine."Location Code") then begin
                ItemJnlLine."Bin Code" := OrigItemJnlLine."Bin Code";
                WMSMgmt.CreateWhseJnlLine(ItemJnlLine, 0, NearZeroWhseJnlLine, false); // P8001132
                NearZeroWhseJnlLine."Line No." := ReferenceEntry."Entry No.";
                NearZeroWhseJnlLine.Insert;
            end;
    end;

    procedure WhseAdjmtsToPost(): Boolean
    begin
        exit(NearZeroWhseJnlLine.FindFirst); // P8001039
    end;

    procedure BuildWhseAdjmtJnlLine(var WhseJnlLine: Record "Warehouse Journal Line")
    var
        AdjmtItemLedgEntry: Record "Item Ledger Entry";
    begin
        // P8001039
        WhseJnlLine := NearZeroWhseJnlLine;
        WhseJnlLine."Line No." := 0;
        NearZeroWhseJnlLine.Delete;
    end;

    procedure GetWhseAdjmts(var TempWhseJnlLine: Record "Warehouse Journal Line" temporary): Boolean
    begin
        exit(CopyWhseAdjmts(NearZeroWhseJnlLine, TempWhseJnlLine, true)); // P8001039
    end;

    procedure SetWhseAdjmts(var TempWhseJnlLine: Record "Warehouse Journal Line" temporary)
    begin
        CopyWhseAdjmts(TempWhseJnlLine, NearZeroWhseJnlLine, true); // P8001039
    end;

    procedure AddWhseAdjmts(var TempWhseJnlLine: Record "Warehouse Journal Line" temporary)
    begin
        CopyWhseAdjmts(TempWhseJnlLine, NearZeroWhseJnlLine, false); // P8001039
    end;

    procedure ClearWhseAdjmts()
    begin
        NearZeroWhseJnlLine.DeleteAll; // P8001039
    end;

    local procedure CopyWhseAdjmts(var FromWhseJnlLine: Record "Warehouse Journal Line" temporary; var ToWhseJnlLine: Record "Warehouse Journal Line" temporary; ClearToWhseJnl: Boolean): Boolean
    begin
        // P8001039
        if ClearToWhseJnl then
            ToWhseJnlLine.DeleteAll;
        if FromWhseJnlLine.FindSet then begin
            repeat
                ToWhseJnlLine := FromWhseJnlLine;
                ToWhseJnlLine.Insert;
            until (FromWhseJnlLine.Next = 0);
            exit(true);
        end;
    end;

    procedure AdjustWhseMovementQtys(var WhseJnlLine: Record "Warehouse Journal Line"; RegisteringEntries: Boolean)
    var
        BinQty: Decimal;
        BinQtyBase: Decimal;
    begin
        // P8001039
        // P8001127 - Rework routine
        // Change global WhseMovementSourceLine to a temp table
        // Add global WhseMovementSourceLineNo, Add parameter RegisteringEntries
        // P8001127
        if (WhseJnlLine."Entry Type" = WhseJnlLine."Entry Type"::Movement) then
            if (WhseJnlLine."From Bin Code" <> '') then begin
                GetInvtSetup;
                GetItem(WhseJnlLine."Item No.");
                with WhseJnlLine do begin
                    GetWhseBinQtys(
                      "Item No.", "Variant Code", "Location Code", "From Bin Code",
                      "Unit of Measure Code", "Lot No.", "Serial No.", BinQty, BinQtyBase);
                    if (BinQtyBase <> "Qty. (Base)") then
                        if QtyIsNearZero(BinQtyBase - "Qty. (Base)") then begin
                            Quantity := BinQty;
                            "Qty. (Base)" := BinQtyBase;
                            "Qty. (Absolute)" := Abs(Quantity);
                            "Qty. (Absolute, Base)" := Abs("Qty. (Base)");
                            if ("To Bin Code" = '') and RegisteringEntries then begin
                                WhseMovementSourceLine := WhseJnlLine;
                                WhseMovementSourceLineNo := WhseMovementSourceLineNo + 1;
                                WhseMovementSourceLine."Line No." := WhseMovementSourceLineNo;
                                WhseMovementSourceLine.Insert;
                            end;
                        end;
                end;
            end else
                if (WhseJnlLine."To Bin Code" <> '') then
                    with WhseMovementSourceLine do begin
                        SetRange("Lot No.", WhseJnlLine."Lot No.");
                        SetRange("Serial No.", WhseJnlLine."Serial No.");
                        if FindFirst then begin
                            if ("Unit of Measure Code" <> WhseJnlLine."Unit of Measure Code") then
                                Quantity := Quantity *
                                  P800UOMMgmt.GetConversionFromTo("Item No.", "Unit of Measure Code", WhseJnlLine."Unit of Measure Code");
                            WhseJnlLine.Quantity := -Quantity;
                            WhseJnlLine."Qty. (Base)" := -"Qty. (Base)";
                            WhseJnlLine."Qty. (Absolute)" := Abs(WhseJnlLine.Quantity);
                            WhseJnlLine."Qty. (Absolute, Base)" := Abs(WhseJnlLine."Qty. (Base)");
                            Delete;
                        end;
                        Reset;
                    end;
    end;

    local procedure GetWhseUOM(ItemNo: Code[20]; LocationCode: Code[10]; UOMCode: Code[10]): Code[10]
    begin
        // P8001127
        if IsDirectedWhseLocation(LocationCode) then
            exit(UOMCode);
        GetItem(ItemNo);
        exit(Item."Base Unit of Measure");
    end;

    procedure ProcessNewDirectedWhseEntry(var WhseEntry: Record "Warehouse Entry"; var BinQuantity: Record "Warehouse Entry")
    begin
        // P8001039
        with WhseEntry do
            if IsDirectedWhseLocation("Location Code") and ((BinQuantity.Quantity + Quantity) <> 0) then begin
                GetInvtSetup;
                GetItem("Item No.");
                if QtyIsNearZero(BinQuantity.Quantity + Quantity) then begin
                    NearZeroDirectedWhseEntry := WhseEntry;
                    NearZeroDirectedWhseEntry.Quantity := -(BinQuantity.Quantity + Quantity);
                    NearZeroDirectedWhseEntry."Qty. (Base)" := -(BinQuantity."Qty. (Base)" + "Qty. (Base)");
                    if Item.TrackAlternateUnits() then
                        NearZeroDirectedWhseEntry."Quantity (Alt.)" :=
                          Round(NearZeroDirectedWhseEntry."Qty. (Base)" * Item.AlternateQtyPerBase(), 0.00001);
                    NearZeroDirectedWhseEntry.Insert;
                end;
            end;
    end;

    procedure PostDirectedWhseAdjmts(var WhseReg: Record "Warehouse Register")
    var
        AdjmtBin: Record Bin;
        WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line";
        WhseJnlLine: Record "Warehouse Journal Line";
    begin
        // P8001039
        with NearZeroDirectedWhseEntry do
            if FindSet then begin
                WhseJnlPostLine.SetWhseRegister(WhseReg);
                repeat
                    GetLocation("Location Code");
                    Location.TestField("Adjustment Bin Code");
                    AdjmtBin.Get("Location Code", Location."Adjustment Bin Code");
                    WhseJnlLine."Location Code" := "Location Code";
                    WhseJnlLine."Registering Date" := "Registering Date";
                    WhseJnlLine."Item No." := "Item No.";
                    WhseJnlLine."Variant Code" := "Variant Code";
                    WhseJnlLine."Unit of Measure Code" := "Unit of Measure Code";
                    WhseJnlLine."Lot No." := "Lot No.";
                    WhseJnlLine."Serial No." := "Serial No.";
                    if (Quantity > 0) then begin
                        WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::"Positive Adjmt.";
                        WhseJnlLine."To Zone Code" := "Zone Code";
                        WhseJnlLine."To Bin Code" := "Bin Code";
                        WhseJnlLine."From Zone Code" := AdjmtBin."Zone Code";
                        WhseJnlLine."From Bin Code" := AdjmtBin.Code;
                    end else begin
                        WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::"Negative Adjmt.";
                        WhseJnlLine."From Zone Code" := "Zone Code";
                        WhseJnlLine."From Bin Code" := "Bin Code";
                        WhseJnlLine."To Zone Code" := AdjmtBin."Zone Code";
                        WhseJnlLine."To Bin Code" := AdjmtBin.Code;
                    end;
                    WhseJnlLine.Quantity := Abs(Quantity);
                    WhseJnlLine."Qty. (Base)" := Abs("Qty. (Base)");
                    WhseJnlLine."Quantity (Alt.)" := Abs("Quantity (Alt.)");
                    WhseJnlLine."Qty. (Absolute)" := Abs(WhseJnlLine.Quantity);
                    WhseJnlLine."Qty. (Absolute, Base)" := Abs(WhseJnlLine."Qty. (Base)");
                    WhseJnlLine."Quantity (Absolute, Alt.)" := Abs(WhseJnlLine."Quantity (Alt.)");
                    WhseJnlPostLine.Run(WhseJnlLine);
                until (Next = 0);
                DeleteAll;
                WhseJnlPostLine.GetWhseRegister(WhseReg);
            end;
    end;

    procedure UpdateItemTransferQtys(var TransLedgEntry: Record "Item Ledger Entry")
    begin
        // P8001067
        with TransLedgEntry do begin
            Quantity := -Quantity;
            "Quantity (Alt.)" := -"Quantity (Alt.)";
        end;
    end;

    procedure UpdateItemTransferFields(var ItemLedgEntry: Record "Item Ledger Entry"; var TransLedgEntry: Record "Item Ledger Entry")
    var
        ItemApplEntry: Record "Item Application Entry";
        PosTransLedgEntry: Record "Item Ledger Entry";
    begin
        // P8001067
        with ItemApplEntry do begin
            SetCurrentKey("Outbound Item Entry No.", "Item Ledger Entry No.");
            SetRange("Outbound Item Entry No.", TransLedgEntry."Entry No.");
            SetRange("Item Ledger Entry No.", TransLedgEntry."Entry No.");
            FindFirst;
            SetCurrentKey("Transferred-from Entry No.");
            SetRange("Transferred-from Entry No.", "Inbound Item Entry No.");
            SetRange("Item Ledger Entry No.");
            FindFirst;
        end;
        with PosTransLedgEntry do begin
            Get(ItemApplEntry."Inbound Item Entry No.");
            ItemLedgEntry."Entry Type" := "Entry Type";
            ItemLedgEntry."Location Code" := "Location Code";
            ItemLedgEntry."Document Type" := "Document Type";
            ItemLedgEntry."Document Line No." := "Document Line No.";
            ItemLedgEntry."Order Type" := "Order Type"::Transfer; // P8001132
            ItemLedgEntry."Order No." := "Order No.";             // P8001132
            ItemLedgEntry."Serial No." := "Serial No.";
            ItemLedgEntry."Lot No." := "Lot No.";
            ItemLedgEntry."Expiration Date" := "Expiration Date";
        end;
    end;

    procedure UpdateValueTransferFields(var ValueEntry: Record "Value Entry"; var TransValueEntry: Record "Value Entry"; var TransLedgEntry: Record "Item Ledger Entry")
    begin
        // P8001067
        with TransLedgEntry do begin
            TransValueEntry."Item Ledger Entry Type" := "Entry Type";
            TransValueEntry."Document Type" := "Document Type";
            TransValueEntry."Document Line No." := "Document Line No.";
        end;
        with TransValueEntry do begin
            ValueEntry."Cost Amount (Actual)" := "Cost Amount (Actual)";
            ValueEntry."Cost Amount (Actual) (ACY)" := "Cost Amount (Actual) (ACY)";
        end;
    end;

    procedure UpdateTransferEntryDims(var ItemJnlLine: Record "Item Journal Line"; var TransLedgEntry: Record "Item Ledger Entry"; var TransValueEntry: Record "Value Entry")
    begin
        // P8001067
        // P8001133 - remove parameter for TempJnlLineDim
        with TransLedgEntry do begin
            "Global Dimension 1 Code" := ItemJnlLine."Shortcut Dimension 1 Code";
            "Global Dimension 2 Code" := ItemJnlLine."Shortcut Dimension 2 Code";
            "Dimension Set ID" := ItemJnlLine."Dimension Set ID"; // P8001133
            Modify;
        end;
        with TransValueEntry do begin
            "Global Dimension 1 Code" := ItemJnlLine."Shortcut Dimension 1 Code";
            "Global Dimension 2 Code" := ItemJnlLine."Shortcut Dimension 2 Code";
            "Dimension Set ID" := ItemJnlLine."Dimension Set ID"; // P8001133
            Modify;
        end;
    end;

    local procedure AddOpenAltQtyAdjustment(var ItemLedgEntry: Record "Item Ledger Entry")
    var
        RemQty: Decimal;
        RemQtyAlt: Decimal;
        OpenItemLedgEntry: Record "Item Ledger Entry";
    begin
        // P8001110
        with NearZeroEntryToAdjust do
            if Get(ItemLedgEntry."Entry No.") then begin
                RemQty := Quantity;
                RemQtyAlt := "Quantity (Alt.)";
            end;
        AddItemEntryRemQtys(ItemLedgEntry, RemQty, RemQtyAlt);
        SetOpenItemLedgFilters(ItemLedgEntry, OpenItemLedgEntry);
        with OpenItemLedgEntry do
            if FindSet then
                repeat
                    AddItemEntryRemQtys(OpenItemLedgEntry, RemQty, RemQtyAlt);
                until (Next = 0);
        if (RemQty = 0) and (RemQtyAlt > 0) then
            with NearZeroEntryToAdjust do
                if Get(ItemLedgEntry."Entry No.") then begin
                    "Quantity (Alt.)" := "Quantity (Alt.)" - RemQtyAlt;
                    Modify;
                end else begin
                    NearZeroEntryToAdjust := ItemLedgEntry;
                    Quantity := 0;
                    "Quantity (Alt.)" := -RemQtyAlt;
                    Insert;
                end;
    end;
}

