codeunit 37002081 "Alt. Qty. Tracking Management"
{
    // PR3.60
    //   Management of alternate quantities for item tracking
    // 
    // PR3.61
    //   Add logic for transfer orders
    //   Modify logic for physical count
    // 
    // PR3.70.01
    //   Add calls to SetBlockCommit prior to calling RegisterAltQtyLines on item tracking form
    // 
    // PR4.70.04
    // P8000043A, Myers Nissi, Jack Reynolds, 25 MAY 04
    //   Replace calls to RegisterAltQtyTracking with RegisterP800Tracking
    // 
    // PR4.00
    // P8000250B, Myers Nissi, Jack Reynolds, 18 OCT 05
    //   Support for alternate lot number assignemnt methods
    // 
    // PR4.00.01
    // P8000276A, VerticalSoft, Jack Reynolds, 03 JAN 06
    //   Fix problem with zero quantity and non-zero alternate quantity
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 12 JUN 07
    //   AssistEditLotSerialNo moved to codeunit 6501
    // 
    // P8000504A, VerticalSoft, Jack Reynolds, 08 AUG 07
    //   Support for alternate quantities on repack orders
    // 
    // PRW15.00.01
    // P8000538A, VerticalSoft, Jack Reynolds, 22 OCT 07
    //   UpdateItemJnlTracking - fix problem deleting existing tracking lines
    // 
    // P8000566A, VerticalSoft, Jack Reynolds, 28 MAY 08
    //   Fix problem with reclass, lot tracking, and alternate quantity
    // 
    // PRW16.00.01
    // P8000704, VerticalSoft, Jack Reynolds, 16 JUN 09
    //   Fix rounding problem with base quantity on alternate quantity lines
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00.03
    // P80075420, To-Increase, Jack Reynolds, 08 JUL 19
    //   Problem losing tracking when using containers and specifying alt quantity to handle
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW118.01
    // P800127049, To Increase, Jack Reynolds, 23 AUG 21
    //   Support for Inventory documents

    trigger OnRun()
    begin
    end;

    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        ItemJnlLine: Record "Item Journal Line";
        InvtDocLine: Record "Invt. Document Line";
        TransLine: Record "Transfer Line";
        Item: Record Item;
        TrackingSpecification: Record "Tracking Specification";
        ItemTrackingCode: Record "Item Tracking Code";
        P800Functions: Codeunit "Process 800 Functions";
        SourceAltQtyTransNo: Integer;
        SourceOutstandingQtyBase: Decimal;
        TrackingOn: array[2] of Boolean;
        LookupAllowed: Boolean;
        Text001: Label 'Do you want to assign a %1?';

    procedure UpdateSalesTracking(SalesLine: Record "Sales Line")
    var
        TrackingSpecification: Record "Tracking Specification";
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        AltQtyLine: Record "Alternate Quantity Line";
        ItemTrackingForm: Page "Item Tracking Lines";
    begin
        // UpdateSalesTracking
        Clear(TrackingOn);
        Item.Get(SalesLine."No.");
        if ItemTrackingCode.Get(Item."Item Tracking Code") then begin
            TrackingOn[1] := ItemTrackingCode."Lot Specific Tracking";
            TrackingOn[2] := ItemTrackingCode."SN Specific Tracking";
        end;
        if not (TrackingOn[1] or TrackingOn[2]) then
            exit;

        GetTempTracking(SalesLine, 0, SalesLine."Alt. Qty. Transaction No.", TempTrackingSpecification); // P8000043A, P80075420
        TrackingSpecification.InitFromSalesLine(SalesLine); // P8007748
        if ((SalesLine."Document Type" = SalesLine."Document Type"::Invoice) and
            (SalesLine."Shipment No." <> '')) or
           ((SalesLine."Document Type" = SalesLine."Document Type"::"Credit Memo") and
            (SalesLine."Return Receipt No." <> '')) then
            ItemTrackingForm.SetFormRunMode(2); // Combined shipment/receipt
        ItemTrackingForm.SetBlockCommit(true); // PR3.70.01
        ItemTrackingForm.SetSourceSpec(TrackingSpecification, SalesLine."Shipment Date");
        ItemTrackingForm.RegisterP800Tracking(TempTrackingSpecification, 'INCREMENT'); // P8000043A
    end;

    procedure UpdatePurchTracking(PurchLine: Record "Purchase Line")
    var
        TrackingSpecification: Record "Tracking Specification";
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        ItemTrackingForm: Page "Item Tracking Lines";
    begin
        // UpdatePurchTracking
        Clear(TrackingOn);
        Item.Get(PurchLine."No.");
        if ItemTrackingCode.Get(Item."Item Tracking Code") then begin
            TrackingOn[1] := ItemTrackingCode."Lot Specific Tracking";
            TrackingOn[2] := ItemTrackingCode."SN Specific Tracking";
        end;
        if not (TrackingOn[1] or TrackingOn[2]) then
            exit;

        GetTempTracking(PurchLine, 0, PurchLine."Alt. Qty. Transaction No.", TempTrackingSpecification); // P8000043A, P80075420
        TrackingSpecification.InitFromPurchLine(PurchLine); // P8007748
        if ((PurchLine."Document Type" = PurchLine."Document Type"::Invoice) and
            (PurchLine."Receipt No." <> '')) or
           ((PurchLine."Document Type" = PurchLine."Document Type"::"Credit Memo") and
            (PurchLine."Return Shipment No." <> '')) then
            ItemTrackingForm.SetFormRunMode(2); // Combined shipment/receipt
        ItemTrackingForm.SetBlockCommit(true); // PR3.70.01
        ItemTrackingForm.SetSourceSpec(TrackingSpecification, PurchLine."Expected Receipt Date");
        ItemTrackingForm.RegisterP800Tracking(TempTrackingSpecification, 'INCREMENT'); // P8000043A
    end;

    procedure UpdateItemJnlTracking(ItemJnlLine: Record "Item Journal Line")
    var
        TrackingSpecification: Record "Tracking Specification";
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        ItemJnlReserv: Codeunit "Item Jnl. Line-Reserve";
        P800Tracking: Codeunit "Process 800 Item Tracking";
        ItemTrackingForm: Page "Item Tracking Lines";
    begin
        // UpdateItemJnlTracking
        Clear(TrackingOn);
        Item.Get(ItemJnlLine."Item No.");
        if ItemTrackingCode.Get(Item."Item Tracking Code") then begin
            TrackingOn[1] := ItemTrackingCode."Lot Specific Tracking";
            TrackingOn[2] := ItemTrackingCode."SN Specific Tracking";
        end;
        if not (TrackingOn[1] or TrackingOn[2]) then
            exit;

        if ItemJnlLine."Phys. Inventory" then             // PR3.61
            P800Tracking.ItemJnlModifyPhysical(ItemJnlLine) // PR3.61
        else begin                                        // PR3.61
            GetTempTracking(ItemJnlLine, 0, ItemJnlLine."Alt. Qty. Transaction No.", TempTrackingSpecification); // P8000043A, P80075420
            ItemJnlReserv.SetDeleteItemTracking(true); // P8000538A
            ItemJnlReserv.DeleteLine(ItemJnlLine); // P8000276A
            TrackingSpecification.InitFromItemJnlLine(ItemJnlLine); // P8007748
            if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer then // P8000566A
                ItemTrackingForm.SetFormRunMode(1); // Reclass                      // P8000566A
            ItemTrackingForm.SetBlockCommit(true); // PR3.70.01
            ItemTrackingForm.SetSourceSpec(TrackingSpecification, ItemJnlLine."Posting Date");
            ItemTrackingForm.RegisterP800Tracking(TempTrackingSpecification, 'INCREMENT'); // P8000043A
        end;                                              // PR3.61
    end;

    // P800127049
    procedure UpdateInvtDocTracking(InvtDocLine: Record "Invt. Document Line")
    var
        TrackingSpecification: Record "Tracking Specification";
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        ReserveInvtDocLine: Codeunit "Invt. Doc. Line-Reserve";
        P800Tracking: Codeunit "Process 800 Item Tracking";
        ItemTrackingForm: Page "Item Tracking Lines";
    begin
        Clear(TrackingOn);
        Item.Get(InvtDocLine."Item No.");
        if ItemTrackingCode.Get(Item."Item Tracking Code") then begin
            TrackingOn[1] := ItemTrackingCode."Lot Specific Tracking";
            TrackingOn[2] := ItemTrackingCode."SN Specific Tracking";
        end;
        if not (TrackingOn[1] or TrackingOn[2]) then
            exit;

        GetTempTracking(InvtDocLine, 0, InvtDocLine."FOOD Alt. Qty. Transaction No.", TempTrackingSpecification);
        ReserveInvtDocLine.SetDeleteItemTracking(true);
        ReserveInvtDocLine.DeleteLine(InvtDocLine);
        TrackingSpecification.InitFromInvtDocLine(InvtDocLine);
        ItemTrackingForm.SetBlockCommit(true);
        ItemTrackingForm.SetSourceSpec(TrackingSpecification, InvtDocLine."Posting Date");
        ItemTrackingForm.RegisterP800Tracking(TempTrackingSpecification, 'INCREMENT');
    end;

    procedure UpdateTransTracking(TransLine: Record "Transfer Line"; Direction: Option Outbound,Inbound)
    var
        TrackingSpecification: Record "Tracking Specification";
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        ItemTrackingForm: Page "Item Tracking Lines";
        DummyDate: Date;
    begin
        // UpdateTransTracking
        // PR3.61 Begin
        Clear(TrackingOn);
        Item.Get(TransLine."Item No.");
        if ItemTrackingCode.Get(Item."Item Tracking Code") then begin
            TrackingOn[1] := ItemTrackingCode."Lot Specific Tracking";
            TrackingOn[2] := ItemTrackingCode."SN Specific Tracking";
        end;
        if not (TrackingOn[1] or TrackingOn[2]) then
            exit;

        TrackingSpecification.InitFromTransLine(TransLine, DummyDate, Direction); // P8007748
        ItemTrackingForm.SetFormRunMode(2); // Combined shipment/receipt
        ItemTrackingForm.SetBlockCommit(true); // PR3.70.01
        if Direction = Direction::Outbound then begin
            GetTempTracking(TransLine, Direction, TransLine."Alt. Qty. Trans. No. (Ship)", TempTrackingSpecification); // P8000043A, P80075420
            ItemTrackingForm.SetSourceSpec(TrackingSpecification, TransLine."Shipment Date");
        end else begin
            GetTempTracking(TransLine, Direction, TransLine."Alt. Qty. Trans. No. (Receive)", TempTrackingSpecification); // P8000043A, P80075420
            ItemTrackingForm.SetSourceSpec(TrackingSpecification, TransLine."Receipt Date");
        end;
        ItemTrackingForm.RegisterP800Tracking(TempTrackingSpecification, 'INCREMENT'); // P8000043A
        // PR3.61 End
    end;

    local procedure GetTempTracking(DocumentLine: Variant; Direction: Integer; AltQtyTransNo: Integer; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    var
        ProcessFns: Codeunit "Process 800 Functions";
        Process800CoreFunctions: Codeunit "Process 800 Core Functions";
        AltQtyLine: Record "Alternate Quantity Line";
        ReservationEntry: Record "Reservation Entry";
        QtyBase: Decimal;
        PrevQty: Decimal;
        PrevQtyToHandleBase: Decimal;
        PrevQtyToAltHandle: Decimal;
        SourceType: Integer;
        SourceSubType: Integer;
        SourceID: Code[20];
        SourceBatchName: Code[10];
        SourceRefNo: Integer;
        ContainerQtybyDocLine: Query "Container Qty. by Doc. Line 2";
        EntryNo: Integer;
    begin
        // P8000043A Begin
        // P80075420
        // This will build the TempTrackingSpecification to represent the end state of the item tracking page
        Process800CoreFunctions.GetLineFilterValues(DocumentLine, Direction, SourceType, SourceSubType, SourceID, SourceBatchName, SourceRefNo);

        // First quantities in containers that are not marked to receive - this needs to be included in the quantity, but not quantity to handle
        if (SourceType in [DATABASE::"Sales Line", DATABASE::"Purchase Line", DATABASE::"Transfer Line"]) and
           ProcessFns.ContainerTrackingInstalled
        then begin
            ContainerQtybyDocLine.SetRange(ApplicationTableNo, SourceType);
            ContainerQtybyDocLine.SetRange(ApplicationSubtype, SourceSubType);
            ContainerQtybyDocLine.SetRange(ApplicationNo, SourceID);
            ContainerQtybyDocLine.SetRange(ApplicationLineNo, SourceRefNo);
            ContainerQtybyDocLine.SetRange(ShipReceive, false);
            if ContainerQtybyDocLine.Open then
                while ContainerQtybyDocLine.Read do begin
                    TempTrackingSpecification.Init;
                    EntryNo += 1;
                    TempTrackingSpecification."Entry No." := EntryNo;
                    TempTrackingSpecification."Lot No." := ContainerQtybyDocLine.LotNo;
                    TempTrackingSpecification."Serial No." := ContainerQtybyDocLine.SerialNo;
                    TempTrackingSpecification."Quantity (Base)" := ContainerQtybyDocLine.SumQuantityBase;
                    TempTrackingSpecification.Insert;
                end;
        end;

        // Now add in quantities from alternate quantity lines - this is included in quantity to handle and will include quantities
        // in containers that are marked to receive
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", AltQtyTransNo);
        if AltQtyLine.Find('-') then // P8000704
            repeat
                // P8000704
                TempTrackingSpecification.SetRange("Lot No.", AltQtyLine."Lot No.");
                TempTrackingSpecification.SetRange("Serial No.", AltQtyLine."Serial No.");
                TempTrackingSpecification.SetRange("New Lot No.", AltQtyLine."New Lot No.");
                if not TempTrackingSpecification.FindFirst then begin
                    // P8000704
                    TempTrackingSpecification.Init;
                    EntryNo += 1;
                    TempTrackingSpecification."Entry No." := EntryNo;
                    TempTrackingSpecification."Lot No." := AltQtyLine."Lot No.";
                    TempTrackingSpecification."New Lot No." := AltQtyLine."New Lot No."; // P8000566A
                    TempTrackingSpecification."Serial No." := AltQtyLine."Serial No.";
                    TempTrackingSpecification."Quantity (Base)" := AltQtyLine."Quantity (Base)";
                    TempTrackingSpecification."Qty. to Handle (Base)" := AltQtyLine."Quantity (Base)";
                    TempTrackingSpecification."Qty. to Invoice (Base)" := AltQtyLine."Quantity (Base)";
                    TempTrackingSpecification."Qty. to Handle (Alt.)" := AltQtyLine."Quantity (Alt.)";
                    TempTrackingSpecification.Insert;
                    // P8000704
                end else begin
                    TempTrackingSpecification."Quantity (Base)" += AltQtyLine."Quantity (Base)";
                    TempTrackingSpecification."Qty. to Handle (Base)" += AltQtyLine."Quantity (Base)";
                    TempTrackingSpecification."Qty. to Invoice (Base)" += AltQtyLine."Quantity (Base)";
                    TempTrackingSpecification."Qty. to Handle (Alt.)" += AltQtyLine."Quantity (Alt.)";
                    TempTrackingSpecification.Modify;
                end;
            // P8000704
            until AltQtyLine.Next = 0;

        // Finally, preserve any tracking that was in place but not included in containers or alternate quantity lines
        if SourceType in [DATABASE::"Sales Line", DATABASE::"Purchase Line", DATABASE::"Transfer Line"] then begin
            ReservationEntry.Reset;
            ReservationEntry.SetRange("Source Type", SourceType);
            ReservationEntry.SetRange("Source Subtype", SourceSubType);
            ReservationEntry.SetRange("Source ID", SourceID);
            ReservationEntry.SetRange("Source Batch Name", SourceBatchName);
            ReservationEntry.SetRange("Source Ref. No.", SourceRefNo);
            ReservationEntry.SetCurrentKey("Lot No.", "New Lot No.", "Serial No.");
            if ReservationEntry.FindSet then
                repeat
                    ReservationEntry.SetRange("Lot No.", ReservationEntry."Lot No.");
                    ReservationEntry.SetRange("New Lot No.", ReservationEntry."New Lot No.");
                    ReservationEntry.SetRange("Serial No.", ReservationEntry."Serial No.");
                    ReservationEntry.CalcSums("Quantity (Base)", "Qty. to Handle (Base)", "Qty. to Invoice (Base)", "Qty. to Handle (Alt.)");

                    TempTrackingSpecification.SetRange("Lot No.", ReservationEntry."Lot No.");
                    TempTrackingSpecification.SetRange("Serial No.", ReservationEntry."Serial No.");
                    TempTrackingSpecification.SetRange("New Lot No.", ReservationEntry."New Lot No.");
                    if not TempTrackingSpecification.FindFirst then begin
                        TempTrackingSpecification.Init;
                        EntryNo += 1;
                        TempTrackingSpecification."Entry No." := EntryNo;
                        TempTrackingSpecification."Lot No." := ReservationEntry."Lot No.";
                        TempTrackingSpecification."Serial No." := ReservationEntry."Serial No.";
                        TempTrackingSpecification."New Lot No." := ReservationEntry."New Lot No.";
                        TempTrackingSpecification."Quantity (Base)" := ReservationEntry."Quantity (Base)";
                        TempTrackingSpecification.Insert;
                    end else
                        if TempTrackingSpecification."Quantity (Base)" < ReservationEntry."Quantity (Base)" then begin
                            TempTrackingSpecification."Quantity (Base)" := ReservationEntry."Quantity (Base)";
                            TempTrackingSpecification.Modify;
                        end;

                    ReservationEntry.FindLast;
                    ReservationEntry.SetRange("Lot No.");
                    ReservationEntry.SetRange("New Lot No.");
                    ReservationEntry.SetRange("Serial No.");
                until ReservationEntry.Next = 0;
        end;
        //GGA

        // P8000704
        TempTrackingSpecification.Reset;
        if TempTrackingSpecification.FindSet(true) then
            repeat
                TempTrackingSpecification."Quantity (Base)" := Round(TempTrackingSpecification."Quantity (Base)", 0.00001);
                TempTrackingSpecification."Qty. to Handle (Base)" := Round(TempTrackingSpecification."Qty. to Handle (Base)", 0.00001);
                TempTrackingSpecification."Qty. to Invoice (Base)" := Round(TempTrackingSpecification."Qty. to Invoice (Base)", 0.00001);
                if AltQtyLine."Table No." in [DATABASE::"Item Journal Line", Database::"Invt. Document Line"] then // P8000276A, P800127049
                    TempTrackingSpecification."Quantity (Alt.)" := AltQtyLine."Quantity (Alt.)"; // P8000276A
                TempTrackingSpecification.Modify;
            until TempTrackingSpecification.Next = 0;
        // P8000704
    end;

    procedure GetAltQtyToInvoice(SourceType: Integer; SourceID: Code[20]; SourceSubType: Integer; SourceBatchName: Code[10]; SourceProdOrderLine: Integer; SourceRefNo: Integer): Decimal
    var
        TrackingSpecification: Record "Tracking Specification";
        ResEntry: Record "Reservation Entry";
    begin
        // GetAltQtyToInvoice
        TrackingSpecification.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Batch Name",
          "Source Prod. Order Line", "Source Ref. No.");
        TrackingSpecification.SetRange("Source Type", SourceType);
        TrackingSpecification.SetRange("Source ID", SourceID);
        TrackingSpecification.SetRange("Source Subtype", SourceSubType);
        TrackingSpecification.SetRange("Source Batch Name", SourceBatchName);
        TrackingSpecification.SetRange("Source Prod. Order Line", SourceProdOrderLine);
        TrackingSpecification.SetRange("Source Ref. No.", SourceRefNo);
        TrackingSpecification.CalcSums("Qty. to Invoice (Alt.)");

        ResEntry.SetCurrentKey("Source ID", "Source Ref. No.", "Source Type", "Source Subtype", // PR4.00
          "Source Batch Name", "Source Prod. Order Line");                                    // PR4.00
        ResEntry.SetRange("Source Type", SourceType);
        ResEntry.SetRange("Source ID", SourceID);
        ResEntry.SetRange("Source Subtype", SourceSubType);
        ResEntry.SetRange("Source Batch Name", SourceBatchName);
        ResEntry.SetRange("Source Prod. Order Line", SourceProdOrderLine);
        ResEntry.SetRange("Source Ref. No.", SourceRefNo);
        ResEntry.CalcSums("Qty. to Invoice (Alt.)");

        exit(TrackingSpecification."Qty. to Invoice (Alt.)" + ResEntry."Qty. to Invoice (Alt.)");
    end;

    local procedure GetAltQtySource(AltQtyLine: Record "Alternate Quantity Line")
    var
        ItemTrackingCode: Record "Item Tracking Code";
        Positive: Boolean;
    begin
        // GetAltQtySource
        with AltQtyLine do begin
            Clear(TrackingSpecification);
            TrackingSpecification."Source Type" := "Table No.";
            case "Table No." of
                DATABASE::"Item Journal Line":
                    begin
                        ItemJnlLine.Get("Journal Template Name", "Journal Batch Name", "Source Line No.");
                        TrackingSpecification."Source Subtype" := ItemJnlLine."Entry Type";
                        TrackingSpecification."Source ID" := ItemJnlLine."Journal Template Name";
                        TrackingSpecification."Source Batch Name" := ItemJnlLine."Journal Batch Name";
                        TrackingSpecification."Source Prod. Order Line" := ItemJnlLine."Order Line No."; // P8001132
                        TrackingSpecification."Source Ref. No." := ItemJnlLine."Line No.";
                        TrackingSpecification."Item No." := ItemJnlLine."Item No.";
                        TrackingSpecification."Variant Code" := ItemJnlLine."Variant Code";
                        TrackingSpecification."Location Code" := ItemJnlLine."Location Code";
                        TrackingSpecification."Bin Code" := ItemJnlLine."Bin Code";
                        SourceAltQtyTransNo := ItemJnlLine."Alt. Qty. Transaction No.";
                        SourceOutstandingQtyBase := ItemJnlLine."Quantity (Base)";
                        LookupAllowed := ItemJnlLine."Entry Type" in
                          [ItemJnlLine."Entry Type"::Sale, ItemJnlLine."Entry Type"::"Positive Adjmt.",
                           ItemJnlLine."Entry Type"::"Negative Adjmt.", ItemJnlLine."Entry Type"::Transfer,
                           ItemJnlLine."Entry Type"::Consumption];
                        if ItemJnlLine.Quantity < 0 then
                            LookupAllowed := not LookupAllowed;
                    end;
                // P800127049
                DATABASE::"Invt. Document Line":
                    begin
                        InvtDocLine.Get("Document Type", "Document No.", "Source Line No.");
                        TrackingSpecification."Source Subtype" := InvtDocLine."Document Type".AsInteger();
                        TrackingSpecification."Source ID" := InvtDocLine."Document No.";
                        TrackingSpecification."Source Ref. No." := InvtDocLine."Line No.";
                        TrackingSpecification."Item No." := InvtDocLine."Item No.";
                        TrackingSpecification."Variant Code" := InvtDocLine."Variant Code";
                        TrackingSpecification."Location Code" := InvtDocLine."Location Code";
                        TrackingSpecification."Bin Code" := InvtDocLine."Bin Code";
                        SourceAltQtyTransNo := InvtDocLine."FOOD Alt. Qty. Transaction No.";
                        SourceOutstandingQtyBase := InvtDocLine."Quantity (Base)";
                        LookupAllowed := true;
                    end;
                // P800127049
                DATABASE::"Sales Line":
                    begin
                        SalesLine.Get("Document Type", "Document No.", "Source Line No.");
                        TrackingSpecification."Source Subtype" := SalesLine."Document Type";
                        TrackingSpecification."Source ID" := SalesLine."Document No.";
                        TrackingSpecification."Source Ref. No." := SalesLine."Line No.";
                        TrackingSpecification."Item No." := SalesLine."No.";
                        TrackingSpecification."Variant Code" := SalesLine."Variant Code";
                        TrackingSpecification."Location Code" := SalesLine."Location Code";
                        TrackingSpecification."Bin Code" := SalesLine."Bin Code";
                        SourceAltQtyTransNo := SalesLine."Alt. Qty. Transaction No.";
                        SourceOutstandingQtyBase := SalesLine."Outstanding Qty. (Base)";
                        LookupAllowed := not (SalesLine."Document Type" in
                          [SalesLine."Document Type"::"Credit Memo", SalesLine."Document Type"::"Return Order"]);
                        if SalesLine.Quantity < 0 then
                            LookupAllowed := not LookupAllowed;
                    end;
                DATABASE::"Purchase Line":
                    begin
                        PurchLine.Get("Document Type", "Document No.", "Source Line No.");
                        TrackingSpecification."Source Subtype" := PurchLine."Document Type";
                        TrackingSpecification."Source ID" := PurchLine."Document No.";
                        TrackingSpecification."Source Ref. No." := PurchLine."Line No.";
                        TrackingSpecification."Item No." := PurchLine."No.";
                        TrackingSpecification."Variant Code" := PurchLine."Variant Code";
                        TrackingSpecification."Location Code" := PurchLine."Location Code";
                        TrackingSpecification."Bin Code" := PurchLine."Bin Code";
                        SourceAltQtyTransNo := PurchLine."Alt. Qty. Transaction No.";
                        SourceOutstandingQtyBase := PurchLine."Outstanding Qty. (Base)";
                        LookupAllowed := PurchLine."Document Type" in
                          [PurchLine."Document Type"::"Credit Memo", PurchLine."Document Type"::"Return Order"];
                        if PurchLine.Quantity < 0 then
                            LookupAllowed := not LookupAllowed;
                    end;
                // PR3.61
                DATABASE::"Transfer Line":
                    begin
                        TransLine.Get("Document No.", "Source Line No.");
                        TrackingSpecification."Source Subtype" := "Document Type";
                        TrackingSpecification."Source ID" := TransLine."Document No.";
                        TrackingSpecification."Source Ref. No." := TransLine."Line No.";
                        TrackingSpecification."Item No." := TransLine."Item No.";
                        TrackingSpecification."Variant Code" := TransLine."Variant Code";
                        TrackingSpecification."Location Code" := TransLine."Transfer-from Code";
                        SourceAltQtyTransNo := TransLine."Alt. Qty. Trans. No. (Ship)";
                        SourceOutstandingQtyBase := TransLine."Quantity (Base)";
                        LookupAllowed := true;
                    end;
            // PR3.61
            end;
        end;

        Item.Get(TrackingSpecification."Item No.");
        Clear(TrackingOn);
        if (Item."Item Tracking Code" <> '') then
            if ItemTrackingCode.Get(Item."Item Tracking Code") then begin
                TrackingOn[1] := ItemTrackingCode."Lot Specific Tracking";
                TrackingOn[2] := ItemTrackingCode."SN Specific Tracking";
            end;
    end;

    procedure ShowLotInfo(AltQtyLine: Record "Alternate Quantity Line")
    var
        LotNoInfo: Record "Lot No. Information";
    begin
        // ShowLotInfo
        GetAltQtySource(AltQtyLine);
        LotNoInfo.SetRange("Item No.", TrackingSpecification."Item No.");
        LotNoInfo.SetRange("Variant Code", TrackingSpecification."Variant Code");
        LotNoInfo.SetRange("Lot No.", AltQtyLine."Lot No.");
        PAGE.RunModal(0, LotNoInfo);
    end;

    procedure AssistEditLotNo(var AltQtyLine: Record "Alternate Quantity Line"): Boolean
    var
        ResEntry: Record "Reservation Entry";
        AltQtyLine2: Record "Alternate Quantity Line";
        ItemTrackingDCMgt: Codeunit "Item Tracking Data Collection";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        CurrentSignFactor: Integer;
        MaxQty: Decimal;
    begin
        // AssistEditLotNo
        if AltQtyLine."Lot No." <> '' then begin
            ShowLotInfo(AltQtyLine);
            exit(false);
        end;

        GetAltQtySource(AltQtyLine);
        if LookupAllowed then begin
            ResEntry."Source Type" := TrackingSpecification."Source Type";
            ResEntry."Source Subtype" := TrackingSpecification."Source Subtype";
            CurrentSignFactor := CreateReservEntry.SignFactor(ResEntry);
            MaxQty := SourceOutstandingQtyBase;
            MaxQty -= AltQtyMgmt.CalcAltQtyLinesQtyBase1(SourceAltQtyTransNo);
            if AltQtyLine2.Get(AltQtyLine."Alt. Qty. Transaction No.", AltQtyLine."Line No.") then
                MaxQty += AltQtyLine2."Quantity (Base)";
            ItemTrackingDCMgt.AssistEditTrackingNo(TrackingSpecification, true, CurrentSignFactor, 1, MaxQty);
            AltQtyLine."Lot No." := TrackingSpecification."Lot No.";
            if TrackingSpecification.IsReclass then                        // P8000566A
                AltQtyLine."New Lot No." := TrackingSpecification."Lot No."; // P8000566A
            AltQtyLine.Validate("Quantity (Base)", TrackingSpecification."Quantity (Base)");
        end else begin
            if not Confirm(Text001, false, AltQtyLine.FieldCaption("Lot No.")) then
                exit(false);
            AssignLotNo(AltQtyLine);
            exit(true);
        end;
    end;

    procedure AssignLotNo(var AltQtyLine: Record "Alternate Quantity Line")
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        P800ItemTracking: Codeunit "Process 800 Item Tracking";
    begin
        // AssignLotNo
        GetAltQtySource(AltQtyLine);
        if P800Functions.TrackingInstalled then                                       // P8000250B
            AltQtyLine."Lot No." := P800ItemTracking.AssignLotNo(TrackingSpecification) // P8000250B, P8001234
        else begin                                                                    // P8000250B
            Item.TestField("Lot Nos.");
            AltQtyLine."Lot No." := NoSeriesMgt.GetNextNo(Item."Lot Nos.", WorkDate, true);
        end;                                                                          // P8000250B
    end;

    procedure ShowSerialInfo(AltQtyLine: Record "Alternate Quantity Line")
    var
        SerialNoInfo: Record "Serial No. Information";
    begin
        // ShowShowSerialInfoInfo
        GetAltQtySource(AltQtyLine);
        SerialNoInfo.SetRange("Item No.", TrackingSpecification."Item No.");
        SerialNoInfo.SetRange("Variant Code", TrackingSpecification."Variant Code");
        SerialNoInfo.SetRange("Serial No.", AltQtyLine."Serial No.");
        PAGE.RunModal(0, SerialNoInfo);
    end;

    procedure AssistEditSerialNo(var AltQtyLine: Record "Alternate Quantity Line"): Boolean
    var
        ResEntry: Record "Reservation Entry";
        AltQtyLine2: Record "Alternate Quantity Line";
        ItemTrackingDCMgt: Codeunit "Item Tracking Data Collection";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        CurrentSignFactor: Integer;
        MaxQty: Decimal;
    begin
        // AssistEditSerialNo
        if AltQtyLine."Serial No." <> '' then begin
            ShowSerialInfo(AltQtyLine);
            exit(false);
        end;

        GetAltQtySource(AltQtyLine);
        if LookupAllowed then begin
            ResEntry."Source Type" := TrackingSpecification."Source Type";
            ResEntry."Source Subtype" := TrackingSpecification."Source Subtype";
            CurrentSignFactor := CreateReservEntry.SignFactor(ResEntry);
            MaxQty := 1;
            ItemTrackingDCMgt.AssistEditTrackingNo(TrackingSpecification, true, CurrentSignFactor, 0, MaxQty); // P8000466A
            AltQtyLine."Serial No." := TrackingSpecification."Serial No.";
            AltQtyLine.Validate("Quantity (Base)", TrackingSpecification."Quantity (Base)");
        end else begin
            if not Confirm(Text001, false, AltQtyLine.FieldCaption("Serial No.")) then
                exit(false);
            AssignSerialNo(AltQtyLine);
            exit(true);
        end;
    end;

    procedure AssignSerialNo(var AltQtyLine: Record "Alternate Quantity Line")
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        // AssignSerialNo
        GetAltQtySource(AltQtyLine);
        Item.TestField("Serial Nos.");
        AltQtyLine."Serial No." := NoSeriesMgt.GetNextNo(Item."Serial Nos.", WorkDate, true);
    end;

    procedure UpdateAltQtyLineLotNo(TransNo: Integer; LotNo: Code[50])
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // P8000504A
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", TransNo);
        AltQtyLine.ModifyAll("Lot No.", LotNo);
    end;
}

