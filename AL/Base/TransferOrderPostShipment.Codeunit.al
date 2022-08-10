codeunit 5704 "TransferOrder-Post Shipment"
{
    // PR3.61
    //   Add logic for alternate quantities
    //   Add logic for container tracking
    // 
    // PR3.70.07
    // P8000141A, Myers Nissi, Jack Reynolds, 17 NOV 04
    //   OnRun - defer calling PostTransContainerLine until all transfer lines have been processed
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   P800 WMS Project
    // 
    // PRW15.00.01
    // P8000550A, VerticalSoft, Don Bresee, 05 MAR 08
    //   Add logic for new calculation of base and alternate quantities
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Change WhseJnlPostLine to global
    // 
    // PRW16.00.04
    // P8000888, VerticalSoft, Don Bresee, 14 DEC 10
    //   Add logic to handle registers
    // 
    // PRW16.00.05
    // P8000923, Columbus IT, Jack Reynolds, 29 MAR 11
    //   Fix problem posting containers with lot tracked items
    // 
    // P8000931, Columbus IT, Jack Reynolds, 20 APR 11
    //   Support for Supply Chain Groups
    // 
    // P8000954, Columbus IT, Jack Reynolds, 08 JUL 11
    //   Support for transfer orders on delivery routes and trips
    // 
    // PRW16.00.06
    // P8001002, Columbus IT, Jack Reynolds, 08 DEC 11
    //   Fix permission error with delivery trips
    // 
    // P8001035, Columbus IT, Jack Reynolds, 23 FEB 12
    //   Remove changes from project P8000923
    // 
    // P8001039, Columbus IT, Don Bresee, 26 FEB 12
    //   Add Rounding Adjustment logic for Warehouse
    // 
    // P8001087, Columbus IT, Jack Reynolds, 14 AUG 12
    //   Check availability of loose containers when posting container transactions
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.10.02
    // P8001300, Columbus IT, Jack Reynolds, 27 FEB 14
    //   Fix problem entering quantity to pick for transfer orders in ADC Bin to Bin Movement - 1 doc
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW110.0.01
    // P80041198, To-Increase, Jack Reynolds, 08 MAY 17
    //   General changes and refactoring for NAV 2017 CU7
    // 
    // PRW110.0.02
    // P80045166, To-Increase, Dayakar Battini, 28 JUL 17
    //   Fix issue with multiple lots by passing the correct CU variable
    // 
    // P80050544, To-Increase, Dayakar Battini, 12 FEB 18
    //   Upgrade to 2017 CU13
    // 
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 26 JUL 18
    //   Upgrade for NAV 2018 CU4 due to Microsoft changes
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 15 JAN 19
    //   Upgrade to 13.00

    Permissions = TableData "Item Entry Relation" = i;
    TableNo = "Transfer Header";

    trigger OnRun()
    var
        Item: Record Item;
        SourceCodeSetup: Record "Source Code Setup";
        InvtCommentLine: Record "Inventory Comment Line";
        UpdateAnalysisView: Codeunit "Update Analysis View";
        UpdateItemAnalysisView: Codeunit "Update Item Analysis View";
        RecordLinkManagement: Codeunit "Record Link Management";
        Window: Dialog;
        LineCount: Integer;
        NextLineNo: Integer;
        NewDate: Date;
    begin
        ReleaseDocument(Rec);

        TransHeader := Rec;
        TransHeader.SetHideValidationDialog(HideValidationDialog);

        OnBeforeTransferOrderPostShipment(TransHeader, SuppressCommit);

        DeliveryTripNo := "Delivery Trip No."; // P8000954
        "Delivery Trip No." := '';             // P8000954
        if ProcessFns.ContainerTrackingInstalled then          // P8001342
            ItemJnlPostLine.SetContainerFunctions(ContainerFns); // P8001342
        with TransHeader do begin
            CheckBeforePost();

            WhseReference := "Posting from Whse. Ref.";
            "Posting from Whse. Ref." := 0;

            if "Shipping Advice" = "Shipping Advice"::Complete then
                if not GetShippingAdvice then
                    Error(Text008);

            CheckDim();
            CheckLines(TransHeader, TransLine);

            WhseShip := TempWhseShptHeader.FindFirst;
            InvtPickPutaway := WhseReference <> 0;
            CheckItemInInventoryAndWarehouse(TransLine, not (WhseShip or InvtPickPutaway));
            // P8001379
            //  IF (DeliveryTripNo = '') AND ProcessFns.DistPlanningInstalled THEN // P8000954, P8001002
            //    DeliveryRouteMgmt.CheckTransHeaderLocation(TransHeader); // P8000954
            // P8001379

            GetLocation("Transfer-from Code");
            if Location."Bin Mandatory" and not (WhseShip or InvtPickPutaway) then
                WhsePosting := true;

            if GuiAllowed then begin
                Window.Open(
                  '#1#################################\\' +
                  Text003);

                Window.Update(1, StrSubstNo(Text004, "No."));
            end;

            SourceCodeSetup.Get();
            SourceCode := SourceCodeSetup.Transfer;
            InvtSetup.Get();
            InvtSetup.TestField("Posted Transfer Shpt. Nos.");

            CheckInvtPostingSetup;
            OnAfterCheckInvtPostingSetup(TransHeader, TempWhseShptHeader, SourceCode);

            LockTables(InvtSetup."Automatic Cost Posting");

            // Insert shipment header
            PostedWhseShptHeader.LockTable();
            TransShptHeader.LockTable();
            InsertTransShptHeader(TransShptHeader, TransHeader, InvtSetup."Posted Transfer Shpt. Nos.");

            if InvtSetup."Copy Comments Order to Shpt." then begin
                InvtCommentLine.CopyCommentLines(
                    "Inventory Comment Document Type"::"Transfer Order", "No.",
                    "Inventory Comment Document Type"::"Posted Transfer Shipment", TransShptHeader."No.");
                RecordLinkManagement.CopyLinks(Rec, TransShptHeader);
            end;

            if WhseShip then begin
                WhseShptHeader.Get(TempWhseShptHeader."No.");
                WhsePostShpt.CreatePostedShptHeader(PostedWhseShptHeader, WhseShptHeader, TransShptHeader."No.", "Posting Date");
                // P8001323
                if ProcessFns.ContainerTrackingInstalled then
                    ContainerFns.UpdateContainerQtyToShip(WhseShptHeader, DATABASE::"Transfer Line", 0, TransHeader."No.");
                // P8001323
            end;

            // P8000282A
            if ProcessFns.AltQtyInstalled() then
                AltQtyMgmt.CopyWhseActToTransfer(TempWhseActHeader, TransHeader);
            // P8000282A

            // Insert shipment lines
            OnRunOnBeforeInsertShipmentLines(WhseShptHeader, WhseShptLine);
            LineCount := 0;
            if WhseShip then
                PostedWhseShptLine.LockTable();
            if InvtPickPutaway then
                WhseRqst.LockTable();
            TransShptLine.LockTable();
            TransLine.SetRange(Quantity);
            TransLine.SetRange("Qty. to Ship");
            OnRunOnAfterTransLineSetFiltersForShptLines(TransLine, TransHeader, Location, WhseShip);
            if TransLine.Find('-') then
                repeat
                    if ProcessFns.ContainerTrackingInstalled then               // P8001342
                        ContainerFns.SetContainerDocumentLineSource(TransLine, 0); // P8001342
                    LineCount := LineCount + 1;
                    if GuiAllowed then
                        Window.Update(2, LineCount);

                    if TransLine."Item No." <> '' then begin
                        Item.Get(TransLine."Item No.");
                        CheckItemNotBlocked(Item);
                    end;

                    OnCheckTransLine(TransLine, TransHeader, Location, WhseShip, TransShptLine);

                    InsertTransShptLine(TransShptHeader);
                until TransLine.Next() = 0;

            // P8001090
            if ProcessFns.ProcessDataCollectionInstalled then
                DataCollectionMgmt.CreateSheetForTransHeader(TransHeader, 0, true, TransShptHeader."No.");
            // P8001090

            if ProcessFns.ContainerTrackingInstalled then                                 // P80046533
                ContainerFns.PostTransContainerHeader(TransHeader, 0, TransShptHeader."No."); // P80046533

            MakeInventoryAdjustment();

            if WhseShip then
                WhseShptLine.LockTable();
            TransLine.LockTable();

            OnBeforeCopyTransLines(TransHeader);

            TransLine.SetFilter(Quantity, '<>0');
            //TransLine.SETFILTER("Qty. to Ship",'<>0'); // P8001323
            if TransLine.Find('-') then begin
                NextLineNo := AssignLineNo(TransLine."Document No.");
                repeat
                    if TransLine."Qty. to Ship" <> 0 then begin // P8001323
                        CopyTransLine(TransLine2, TransLine, NextLineNo, TransHeader);
                        TransferTracking(TransLine, TransLine2, TransLine."Qty. to Ship (Base)");
                        TransLine.Validate("Qty. Shipped (Alt.)", TransLine."Qty. Shipped (Alt.)" + TransLine."Qty. to Ship (Alt.)"); // PR3.61
                        TransLine.Validate("Quantity Shipped", TransLine."Quantity Shipped" + TransLine."Qty. to Ship");
                        if TransLine."Alt. Qty. Trans. No. (Ship)" <> 0 then begin            // PR3.61
                            AltQtyMgmt.UpdateTransLineShipToRcv(TransLine);                     // PR3.61
                                                                                                // AltQtyTrackingMgmt.UpdateTransTracking(TransLine,1);             // PR3.61   // P8000282A
                            AltQtyMgmt.UpdateTransTracking(TransLine, 1);                                   // P8000282A
                        end;                                                                  // PR3.61
                                                                                              //TransLine."Qty. to Ship (Cont.)" := 0;                                // PR3.61, P80046533
                    end; // P8001323

                    OnBeforeUpdateWithWarehouseShipReceive(TransLine);
                    TransLine.UpdateWithWarehouseShipReceive;
                    TransLine.Modify();
                    OnAfterTransLineModify(TransLine);
                    // P80046533
                    if (TransLine.Type = TransLine.Type::Item) and ProcessFns.ContainerTrackingInstalled then
                        ContainerFns.UpdateTransLineTrackingQtyToReceive(TransLine);
                // P80046533
                until TransLine.Next() = 0;

            end;

            OnRunOnBeforeLockTables(ItemJnlPostLine);
            if WhseShip then
                WhseShptLine.LockTable();
            LockTable();
            if WhseShip then begin
                WhsePostShpt.PostUpdateWhseDocuments(WhseShptHeader);
                TempWhseShptHeader.Delete();
            end;

            "Last Shipment No." := TransShptHeader."No.";
            "ADC Started" := false; // P8001300
            Modify();

            FinalizePosting(TransHeader, TransLine);

            OnRunOnBeforeCommit(TransHeader, TransShptHeader, PostedWhseShptHeader, SuppressCommit);
            if not (InvtPickPutaway or "Direct Transfer" or SuppressCommit) then begin
                Commit();
                UpdateAnalysisView.UpdateAll(0, true);
                UpdateItemAnalysisView.UpdateAll(0, true);
            end;
            Clear(WhsePostShpt);

            if GuiAllowed() then
                Window.Close();
        end;

        Rec := TransHeader;

        OnAfterTransferOrderPostShipment(Rec, SuppressCommit, TransShptHeader);
    end;

    var
        Text001: Label 'There is nothing to post.';
        Text002: Label 'Warehouse handling is required for Transfer order = %1, %2 = %3.';
        Text003: Label 'Posting transfer lines     #2######';
        Text004: Label 'Transfer Order %1';
        Text005: Label 'The combination of dimensions used in transfer order %1 is blocked. %2';
        Text006: Label 'The combination of dimensions used in transfer order %1, line no. %2 is blocked. %3';
        Text007: Label 'The dimensions that are used in transfer order %1, line no. %2 are not valid. %3.';
        InvtSetup: Record "Inventory Setup";
        TransShptHeader: Record "Transfer Shipment Header";
        TransShptLine: Record "Transfer Shipment Line";
        TransHeader: Record "Transfer Header";
        TransLine: Record "Transfer Line";
        TransLine2: Record "Transfer Line";
        Location: Record Location;
        ItemJnlLine: Record "Item Journal Line";
        WhseRqst: Record "Warehouse Request";
        WhseShptHeader: Record "Warehouse Shipment Header";
        TempWhseShptHeader: Record "Warehouse Shipment Header" temporary;
        WhseShptLine: Record "Warehouse Shipment Line";
        PostedWhseShptHeader: Record "Posted Whse. Shipment Header";
        PostedWhseShptLine: Record "Posted Whse. Shipment Line";
        TempWhseSplitSpecification: Record "Tracking Specification" temporary;
        TempHandlingSpecification: Record "Tracking Specification" temporary;
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        DimMgt: Codeunit DimensionManagement;
        WhseTransferRelease: Codeunit "Whse.-Transfer Release";
        ReserveTransLine: Codeunit "Transfer Line-Reserve";
        WhsePostShpt: Codeunit "Whse.-Post Shipment";
        WhseJnlRegisterLine: Codeunit "Whse. Jnl.-Register Line";
        SourceCode: Code[10];
        WhseShip: Boolean;
        WhsePosting: Boolean;
        InvtPickPutaway: Boolean;
        WhseReference: Integer;
        OriginalQuantity: Decimal;
        OriginalQuantityBase: Decimal;
        Text008: Label 'This order must be a complete shipment.';
        Text009: Label 'Item %1 is not in inventory.';
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        AltQtyTrackingMgmt: Codeunit "Alt. Qty. Tracking Management";
        ContainerFns: Codeunit "Container Functions";
        ProcessFns: Codeunit "Process 800 Functions";
        TempWhseActHeader: Record "Warehouse Activity Header" temporary;
        RoundingAdjmtMgmt: Codeunit "Rounding Adjustment Mgmt.";
        WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line";
        DeliveryRouteMgmt: Codeunit "Delivery Route Management";
        DeliveryTripNo: Code[20];
        DataCollectionMgmt: Codeunit "Data Collection Management";
        SuppressCommit: Boolean;
        TransferDirection: Enum "Transfer Direction";
        HideValidationDialog: Boolean;

    local procedure PostItem(var TransferLine: Record "Transfer Line"; TransShptHeader2: Record "Transfer Shipment Header"; TransShptLine2: Record "Transfer Shipment Line"; WhseShip: Boolean; WhseShptHeader2: Record "Warehouse Shipment Header")
    var
        IsHandled: Boolean;
    begin
        OnBeforePostItem(TransShptHeader2, IsHandled, TransferLine, TransShptLine2, WhseShip, WhseShptHeader2);
        if IsHandled then
            exit;

        CreateItemJnlLine(ItemJnlLine, TransferLine, TransShptHeader2, TransShptLine2);
        ReserveItemJnlLine(ItemJnlLine, TransferLine, WhseShip, WhseShptHeader2);
        RoundingAdjmtMgmt.AdjustItemJnlFixedAltQty(ItemJnlLine); // P8000550A, P80060684

        OnBeforePostItemJournalLine(ItemJnlLine, TransferLine, TransShptHeader2, TransShptLine2, SuppressCommit);
        ItemJnlPostLine.RunWithCheck(ItemJnlLine);
    end;

    local procedure CreateItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line"; TransShptHeader2: Record "Transfer Shipment Header"; TransShptLine2: Record "Transfer Shipment Line")
    begin
        with ItemJnlLine do begin
            Init;
            CopyDocumentFields(
              "Document Type"::"Transfer Shipment", TransShptHeader2."No.", "External Document No.", SourceCode, '');
            "Posting Date" := TransShptHeader2."Posting Date";
            "Document Date" := TransShptHeader2."Posting Date";
            "Document Line No." := TransShptLine2."Line No.";
            "Order Type" := "Order Type"::Transfer;
            "Order No." := TransShptHeader2."Transfer Order No.";
            "Order Line No." := TransferLine."Line No.";
            "Entry Type" := "Entry Type"::Transfer;
            "Item No." := TransShptLine2."Item No.";
            "Variant Code" := TransShptLine2."Variant Code";
            Description := TransShptLine2.Description;
            "Location Code" := TransShptHeader2."Transfer-from Code";
            "New Location Code" := TransHeader."In-Transit Code";
            "Bin Code" := TransLine."Transfer-from Bin Code";
            "Shortcut Dimension 1 Code" := TransShptLine2."Shortcut Dimension 1 Code";
            "New Shortcut Dimension 1 Code" := TransShptLine2."Shortcut Dimension 1 Code";
            "Shortcut Dimension 2 Code" := TransShptLine2."Shortcut Dimension 2 Code";
            "New Shortcut Dimension 2 Code" := TransShptLine2."Shortcut Dimension 2 Code";
            "Dimension Set ID" := TransShptLine2."Dimension Set ID";
            "New Dimension Set ID" := TransShptLine2."Dimension Set ID";
            Quantity := TransShptLine2.Quantity;
            "Invoiced Quantity" := TransShptLine2.Quantity;
            "Quantity (Base)" := TransShptLine2."Quantity (Base)";
            "Invoiced Qty. (Base)" := TransShptLine2."Quantity (Base)";
            // PR3.61
            "Quantity (Alt.)" := TransShptLine2."Quantity (Alt.)";
            "Invoiced Qty. (Alt.)" := TransShptLine2."Quantity (Alt.)";
            if (TransShptLine2."Quantity (Alt.)" <> 0) then
                "Alt. Qty. Transaction No." := TransferLine."Alt. Qty. Trans. No. (Ship)";
            // PR3.61
            "Gen. Prod. Posting Group" := TransShptLine2."Gen. Prod. Posting Group";
            "Inventory Posting Group" := TransShptLine2."Inventory Posting Group";
            "Unit of Measure Code" := TransShptLine2."Unit of Measure Code";
            "Qty. per Unit of Measure" := TransShptLine2."Qty. per Unit of Measure";
            "Country/Region Code" := TransShptHeader2."Trsf.-from Country/Region Code";
            "Transaction Type" := TransShptHeader2."Transaction Type";
            "Transport Method" := TransShptHeader2."Transport Method";
            "Entry/Exit Point" := TransShptHeader2."Entry/Exit Point";
            Area := TransShptHeader2.Area;
            "Transaction Specification" := TransShptHeader2."Transaction Specification";
            "Item Category Code" := TransferLine."Item Category Code";
            "Supply Chain Group Code" := TransferLine."Supply Chain Group Code"; // P8000931
            "Applies-to Entry" := TransferLine."Appl.-to Item Entry";
            "Shpt. Method Code" := TransShptHeader2."Shipment Method Code";
            "Direct Transfer" := TransferLine."Direct Transfer";
        end;

        OnAfterCreateItemJnlLine(ItemJnlLine, TransferLine, TransShptHeader2, TransShptLine2);
    end;

    local procedure CheckItemNotBlocked(var Item: Record Item)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckItemNotBlocked(TransLine, Item, Transheader, Location, WhseShip, IsHandled);
        if IsHandled then
            exit;

        Item.TestField(Blocked, false);
    end;

    local procedure ReserveItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; var TransferLine: Record "Transfer Line"; WhseShip: Boolean; WhseShptHeader2: Record "Warehouse Shipment Header")
    begin
        GetLocation(TransferLine."Transfer-from Code");
        if WhseShip and (WhseShptHeader2."Document Status" = WhseShptHeader2."Document Status"::"Partially Picked") and
           Location."Bin Mandatory"
        then
            ReserveTransLine.TransferWhseShipmentToItemJnlLine(
              TransferLine, ItemJnlLine, WhseShptHeader2, ItemJnlLine."Quantity (Base)")
        else
            ReserveTransLine.TransferTransferToItemJnlLine(
              TransferLine, ItemJnlLine, ItemJnlLine."Quantity (Base)", TransferDirection::Outbound);
    end;

    local procedure CheckDim()
    begin
        TransLine."Line No." := 0;
        CheckDimComb(TransHeader, TransLine);
        CheckDimValuePosting(TransHeader, TransLine);

        TransLine.SetRange("Document No.", TransHeader."No.");
        if TransLine.FindFirst then begin
            CheckDimComb(TransHeader, TransLine);
            CheckDimValuePosting(TransHeader, TransLine);
        end;
    end;

    local procedure CheckDimComb(TransferHeader: Record "Transfer Header"; TransferLine: Record "Transfer Line")
    begin
        if TransferLine."Line No." = 0 then
            if not DimMgt.CheckDimIDComb(TransferHeader."Dimension Set ID") then
                Error(
                  Text005,
                  TransHeader."No.", DimMgt.GetDimCombErr);
        if TransferLine."Line No." <> 0 then
            if not DimMgt.CheckDimIDComb(TransferLine."Dimension Set ID") then
                Error(
                  Text006,
                  TransHeader."No.", TransferLine."Line No.", DimMgt.GetDimCombErr);

        OnAfterCheckDimComb(TransferHeader, TransferLine);
    end;

    local procedure CheckDimValuePosting(TransferHeader: Record "Transfer Header"; TransferLine: Record "Transfer Line")
    var
        TableIDArr: array[10] of Integer;
        NumberArr: array[10] of Code[20];
        IsHandled: Boolean;
    begin
        OnBeforeCheckDimValuePosting(TransferHeader, TransferLine, IsHandled);
        if IsHandled then
            exit;

        TableIDArr[1] := DATABASE::Item;
        NumberArr[1] := TransferLine."Item No.";
        if TransferLine."Line No." = 0 then
            if not DimMgt.CheckDimValuePosting(TableIDArr, NumberArr, TransferHeader."Dimension Set ID") then
                Error(Text007, TransHeader."No.", TransferLine."Line No.", DimMgt.GetDimValuePostingErr);

        if TransferLine."Line No." <> 0 then
            if not DimMgt.CheckDimValuePosting(TableIDArr, NumberArr, TransferLine."Dimension Set ID") then
                Error(Text007, TransHeader."No.", TransferLine."Line No.", DimMgt.GetDimValuePostingErr);
    end;

    local procedure FinalizePosting(var TransHeader: Record "Transfer Header"; var TransLine: Record "Transfer Line")
    var
        DeleteOne: Boolean;
        UpdateDocumentLine: Codeunit "Update Document Line";
    begin
        OnBeforeFinalizePosting(TransHeader, PostedWhseShptHeader, WhseShip);
        TransLine.SetRange(Quantity);
        TransLine.SetRange("Qty. to Ship");
        DeleteOne := TransHeader.ShouldDeleteOneTransferOrder(TransLine);
        OnBeforeDeleteOneTransferOrder(TransHeader, DeleteOne);
        if DeleteOne then
            TransHeader.DeleteOneTransferOrder(TransHeader, TransLine)
        else begin
            WhseTransferRelease.SetCalledFromPost; // P8000954, P800-MegaApp
            WhseTransferRelease.Release(TransHeader);
            ReserveTransLine.UpdateItemTrackingAfterPosting(TransHeader, TransferDirection::Outbound);
            // P80046533, P800-MegaApp
            if ProcessFns.ContainerTrackingInstalled then begin
                UpdateDocumentLine.SetApplication(false, DATABASE::"Transfer Line", 0, TransHeader."No.", 0);
                UpdateDocumentLine.FixTracking;
            end;
            // P80046533
        end;
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    local procedure AssignLineNo(FromDocNo: Code[20]): Integer
    var
        TransLine3: Record "Transfer Line";
    begin
        TransLine3.SetRange("Document No.", FromDocNo);
        if TransLine3.FindLast then
            exit(TransLine3."Line No." + 10000);
    end;

    local procedure InsertShptEntryRelation(var TransShptLine: Record "Transfer Shipment Line") Result: Integer
    var
        TempHandlingSpecification2: Record "Tracking Specification" temporary;
        ItemEntryRelation: Record "Item Entry Relation";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WhseSplitSpecification: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInsertShptEntryRelation(TransShptLine, TransLine, ItemJnlLine, WhsePosting, ItemJnlPostLine, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if WhsePosting then begin
            TempWhseSplitSpecification.Reset();
            TempWhseSplitSpecification.DeleteAll();
        end;

        TempHandlingSpecification2.Reset();
        if ItemJnlPostLine.CollectTrackingSpecification(TempHandlingSpecification2) then begin
            TempHandlingSpecification2.SetRange("Buffer Status", 0);
            if TempHandlingSpecification2.Find('-') then begin
                repeat
                    WhseSplitSpecification := WhsePosting or WhseShip or InvtPickPutaway;
                    OnInsertShptEntryRelationOnAfterCalcWhseSplitSpecification(
                        TransLine, TransShptLine, TempHandlingSpecification2, TempWhseSplitSpecification, WhsePosting, WhseShip, InvtPickPutaway, WhseSplitSpecification);
                    if WhseSplitSpecification then begin
                        if ItemTrackingMgt.GetWhseItemTrkgSetup(TransShptLine."Item No.") then begin
                            TempWhseSplitSpecification := TempHandlingSpecification2;
                            TempWhseSplitSpecification."Source Type" := DATABASE::"Transfer Line";
                            TempWhseSplitSpecification."Source ID" := TransLine."Document No.";
                            TempWhseSplitSpecification."Source Ref. No." := TransLine."Line No.";
                            TempWhseSplitSpecification.Insert();
                        end;
                    end;

                    ItemEntryRelation.InitFromTrackingSpec(TempHandlingSpecification2);
                    ItemEntryRelation.TransferFieldsTransShptLine(TransShptLine);
                    ItemEntryRelation.Insert();
                    TempHandlingSpecification := TempHandlingSpecification2;
                    TempHandlingSpecification."Source Prod. Order Line" := TransShptLine."Line No.";
                    TempHandlingSpecification."Buffer Status" := TempHandlingSpecification."Buffer Status"::MODIFY;
                    TempHandlingSpecification.Insert();
                until TempHandlingSpecification2.Next() = 0;
                OnAfterInsertShptEntryRelation(TransLine, WhseShip, 0, SuppressCommit);
                exit(0);
            end;
        end else begin
            OnAfterInsertShptEntryRelation(TransLine, WhseShip, ItemJnlLine."Item Shpt. Entry No.", SuppressCommit);
            exit(ItemJnlLine."Item Shpt. Entry No.");
        end;
    end;

    local procedure InsertTransShptHeader(var TransShptHeader: Record "Transfer Shipment Header"; var TransHeader: Record "Transfer Header"; NoSeries: Code[20])
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        TransShptHeader.Init();
        TransShptHeader.CopyFromTransferHeader(TransHeader);
        TransShptHeader."No. Series" := NoSeries;
        OnBeforeGenNextNo(TransShptHeader, TransHeader);
        if TransShptHeader."No." = '' then
            TransShptHeader."No." := NoSeriesMgt.GetNextNo(NoSeries, TransHeader."Posting Date", true);
        TransShptHeader."No." := NoSeriesMgt.GetNextNo(NoSeries, TransHeader."Posting Date", true);
        TransShptHeader."Delivery Route No." := TransHeader."Delivery Route No."; // P8000954
        TransShptHeader."Delivery Stop No." := TransHeader."Delivery Stop No.";   // P8000954
        TransShptHeader."Delivery Trip No." := DeliveryTripNo;                    // P8000954
        TransShptHeader."No." := NoSeriesMgt.GetNextNo(TransShptHeader."No. Series", TransHeader."Posting Date", true);
        OnBeforeInsertTransShptHeader(TransShptHeader, TransHeader, SuppressCommit);
        TransShptHeader.Insert();
        OnAfterInsertTransShptHeader(TransHeader, TransShptHeader);
    end;

    local procedure InsertTransShptLine(TransShptHeader: Record "Transfer Shipment Header")
    var
        TransShptLine: Record "Transfer Shipment Line";
        IsHandled: Boolean;
        ShouldRunPosting: Boolean;
    begin
        OnBeforeInsertTransShipmentLine(TransLine);

        TransShptLine.Init();
        TransShptLine."Document No." := TransShptHeader."No.";
        TransShptLine.CopyFromTransferLine(TransLine);
        TransShptLine."Delivery Trip No." := DeliveryTripNo; // P8000954
        RoundingAdjmtMgmt.SetFixedAltQtyTransLine(TransLine, 0); // P8000550A
        if TransLine."Qty. to Ship" > 0 then begin
            OriginalQuantity := TransLine."Qty. to Ship";
            OriginalQuantityBase := TransLine."Qty. to Ship (Base)";
            PostItem(TransLine, TransShptHeader, TransShptLine, WhseShip, WhseShptHeader);
            TransShptLine."Item Shpt. Entry No." := InsertShptEntryRelation(TransShptLine);
            if WhseShip and (TransLine.Type <> TransLine.Type::Container) then begin // P8001323
                WhseShptLine.SetCurrentKey(
                  "No.", "Source Type", "Source Subtype", "Source No.", "Source Line No.");
                WhseShptLine.SetRange("No.", WhseShptHeader."No.");
                WhseShptLine.SetRange("Source Type", DATABASE::"Transfer Line");
                WhseShptLine.SetRange("Source No.", TransLine."Document No.");
                WhseShptLine.SetRange("Source Line No.", TransLine."Line No.");
                if WhseShptLine.FindFirst then
                    CreatePostedShptLineFromWhseShptLine(TransShptLine);
            end;
            ShouldRunPosting := WhsePosting;
            OnInsertTransShptLineOnBeforePostWhseJnlLine(TransShptLine, TransLine, SuppressCommit, WhsePosting, ShouldRunPosting);
            if ShouldRunPosting then
                PostWhseJnlLine(ItemJnlLine, OriginalQuantity, OriginalQuantityBase);
        end;

        IsHandled := false;
        OnBeforeInsertTransShptLine(TransShptLine, TransLine, SuppressCommit, IsHandled, TransShptHeader);
        if IsHandled then
            exit;

        TransShptLine.Insert();
        if TransLine."Alt. Qty. Trans. No. (Ship)" <> 0 then           // PR3.61
            AltQtyMgmt.TransLineToShipmentLine(TransLine, TransShptLine); // PR3.61
        OnAfterInsertTransShptLine(TransShptLine, TransLine, SuppressCommit, TransShptHeader);
    end;

    local procedure CreatePostedShptLineFromWhseShptLine(var TransferShipmentLine: Record "Transfer Shipment Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreatePostedShptLineFromWhseShptLine(TransferShipmentLine, WhseShptLine, PostedWhseShptHeader, PostedWhseShptLine, TempWhseSplitSpecification, IsHandled);
        if IsHandled then
            exit;

        WhseShptLine.TestField("Qty. to Ship", TransferShipmentLine.Quantity);
        WhsePostShpt.CreatePostedShptLine(
          WhseShptLine, PostedWhseShptHeader, PostedWhseShptLine, TempWhseSplitSpecification);

        OnInsertTransShptLineOnAfterCreatePostedShptLine(WhseShptLine, PostedWhseShptLine);
    end;

    local procedure TransferTracking(var FromTransLine: Record "Transfer Line"; var ToTransLine: Record "Transfer Line"; TransferQty: Decimal)
    var
        DummySpecification: Record "Tracking Specification";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTransferTracking(FromTransLine, ToTransLine, TransferQty, IsHandled);
        if IsHandled then
            exit;

        TempHandlingSpecification.Reset();
        TempHandlingSpecification.SetRange("Source Prod. Order Line", ToTransLine."Derived From Line No.");
        if TempHandlingSpecification.Find('-') then begin
            repeat
                ReserveTransLine.TransferTransferToTransfer(
                  FromTransLine, ToTransLine, -TempHandlingSpecification."Quantity (Base)", TransferDirection::Inbound, TempHandlingSpecification);
                TransferQty += TempHandlingSpecification."Quantity (Base)";
            until TempHandlingSpecification.Next() = 0;
            TempHandlingSpecification.DeleteAll();
        end;

        if TransferQty > 0 then
            ReserveTransLine.TransferTransferToTransfer(
              FromTransLine, ToTransLine, TransferQty, TransferDirection::Inbound, DummySpecification);
    end;

    local procedure CheckWarehouse(TransLine: Record "Transfer Line")
    var
        WhseValidateSourceLine: Codeunit "Whse. Validate Source Line";
        ShowError: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckWarehouse(TransLine, IsHandled);
        if IsHandled then
            exit;

        if DeliveryTripNo <> '' then // P8000954
            exit;

        GetLocation(TransLine."Transfer-from Code");
        if Location."Require Pick" or Location."Require Shipment" then begin
            if Location."Bin Mandatory" then
                ShowError := true
            else
                if WhseValidateSourceLine.WhseLinesExist(
                     DATABASE::"Transfer Line",
                     0,// Out
                     TransLine."Document No.",
                     TransLine."Line No.",
                     0,
                     TransLine.Quantity)
                then
                    ShowError := true;

            if ShowError then
                Error(
                  Text002,
                  TransLine."Document No.",
                  TransLine.FieldCaption("Line No."),
                  TransLine."Line No.");
        end;
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Location.GetLocationSetup(LocationCode, Location)
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);
    end;

    local procedure PostWhseJnlLine(ItemJnlLine: Record "Item Journal Line"; OriginalQuantity: Decimal; OriginalQuantityBase: Decimal)
    var
        WhseJnlLine: Record "Warehouse Journal Line";
        TempWhseJnlLine2: Record "Warehouse Journal Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WMSMgmt: Codeunit "WMS Management";
        IsHandled: Boolean;
        WhseJnlLineCreated: Boolean;
    begin
        IsHandled := false;
        OnBeforePostWhseJnlLine(ItemJnlLine, OriginalQuantity, OriginalQuantityBase, IsHandled);
        if IsHandled then
            exit;

        with ItemJnlLine do begin
            Quantity := OriginalQuantity;
            "Quantity (Base)" := OriginalQuantityBase;
            GetLocation("Location Code");
            if Location."Bin Mandatory" then
                // P8000954
                WhseJnlLineCreated := WMSMgmt.CreateWhseJnlLine(ItemJnlLine, 1, WhseJnlLine, false);
            //IF WMSMgmt.CreateWhseJnlLine(ItemJnlLine,1,WhseJnlLine,FALSE,FALSE) THEN BEGIN
            XferWhseRoundingAdjmts(WhseJnlLineCreated); // P8001039
            if WhseJnlLineCreated then begin
                // P8000954
                XferRegsToWhse; // P8000888
                WMSMgmt.SetTransferLine(TransLine, WhseJnlLine, 0, TransShptHeader."No.");
                OnPostWhseJnlLineOnBeforeSplitWhseJnlLine();
                ItemTrackingMgt.SplitWhseJnlLine(
                  WhseJnlLine, TempWhseJnlLine2, TempWhseSplitSpecification, true);
                if TempWhseJnlLine2.Find('-') then
                    repeat
                        WMSMgmt.CheckWhseJnlLine(TempWhseJnlLine2, 1, 0, true);
                        WhseJnlRegisterLine.RegisterWhseJnlLine(TempWhseJnlLine2);
                    until TempWhseJnlLine2.Next() = 0;
                PostWhseRoundingAdjmts; // P8001039
                XferRegsFromWhse; // P8000888
            end;
        end;
    end;

    procedure SetWhseShptHeader(var WhseShptHeader2: Record "Warehouse Shipment Header")
    begin
        WhseShptHeader := WhseShptHeader2;
        TempWhseShptHeader := WhseShptHeader;
        TempWhseShptHeader.Insert();
    end;

    local procedure GetShippingAdvice(): Boolean
    var
        TransLine: Record "Transfer Line";
    begin
        TransLine.SetRange("Document No.", TransHeader."No.");
        if TransLine.Find('-') then
            repeat
                if TransLine."Quantity (Base)" <>
                   TransLine."Qty. to Ship (Base)" + TransLine."Qty. Shipped (Base)"
                then
                    exit(false);
            until TransLine.Next() = 0;
        exit(true);
    end;

    local procedure CheckItemInInventory(TransLine: Record "Transfer Line")
    var
        Item: Record Item;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckItemInInventory(TransLine, IsHandled);
        if IsHandled then
            exit;

        with Item do begin
            Get(TransLine."Item No.");
            if (Type = Type::FOODContainer) then // P8001290
                exit;                          // P8001290
            SetRange("Variant Filter", TransLine."Variant Code");
            SetRange("Location Filter", TransLine."Transfer-from Code");
            CalcFields(Inventory);
            if Inventory <= 0 then
                Error(Text009, TransLine."Item No.");
        end;
    end;

    local procedure CheckItemInInventoryAndWarehouse(var TransLine: Record "Transfer Line"; NeedCheckWarehouse: Boolean)
    var
        TransLine2: Record "Transfer Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckItemInInventoryAndWarehouse(TransLine, NeedCheckWarehouse, IsHandled);
        if IsHandled then
            exit;

        TransLine2.CopyFilters(TransLine);
        TransLine2.FindSet();
        repeat
            CheckItemInInventory(TransLine2);
            if NeedCheckWarehouse then
                CheckWarehouse(TransLine2);
        until TransLine2.Next() = 0;
    end;

    local procedure CheckLines(TransHeader: Record "Transfer Header"; var TransLine: Record "Transfer Line")
    begin
        with TransHeader do begin
            TransLine.Reset();
            TransLine.SetRange("Document No.", "No.");
            TransLine.SetRange("Derived From Line No.", 0);
            TransLine.SetFilter(Quantity, '<>0');
            TransLine.SetFilter("Qty. to Ship", '<>0');
            if TransLine.IsEmpty() then
                Error(Text001);
        end;
    end;

    local procedure LockTables(AutoCostPosting: Boolean)
    var
        GLEntry: Record "G/L Entry";
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeriesLine.LockTable();
        if NoSeriesLine.FindLast then;
        if AutoCostPosting then begin
            GLEntry.LockTable();
            if GLEntry.FindLast then;
        end;
    end;

    local procedure CopyTransLine(var NewTransferLine: Record "Transfer Line"; TransferLine: Record "Transfer Line"; var NextLineNo: Integer; TransferHeader: Record "Transfer Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyTransLine(NewTransferLine, TransferLine, NextLineNo, TransferHeader, IsHandled);
        if IsHandled then
            exit;

        NewTransferLine.Init();
        NewTransferLine := TransferLine;
        if TransferHeader."In-Transit Code" <> '' then
            NewTransferLine."Transfer-from Code" := TransferLine."In-Transit Code";
        NewTransferLine."In-Transit Code" := '';
        NewTransferLine."Derived From Line No." := TransferLine."Line No.";
        NewTransferLine."Line No." := NextLineNo;
        NextLineNo := NextLineNo + 10000;
        NewTransferLine.Quantity := TransferLine."Qty. to Ship";
        NewTransferLine."Quantity (Base)" := TransferLine."Qty. to Ship (Base)";
        NewTransferLine."Quantity (Alt.)" := TransferLine."Qty. to Ship (Alt.)"; // PR3.61, P80041198
        NewTransferLine."Qty. to Ship" := NewTransferLine.Quantity;
        NewTransferLine."Qty. to Ship (Base)" := NewTransferLine."Quantity (Base)";
        NewTransferLine."Qty. to Ship (Alt.)" := NewTransferLine."Quantity (Alt.)"; // PR3.61, P80041198
        NewTransferLine."Qty. to Receive" := NewTransferLine.Quantity;
        NewTransferLine."Qty. to Receive (Base)" := NewTransferLine."Quantity (Base)";
        NewTransferLine."Qty. to Receive (Alt.)" := NewTransferLine."Quantity (Alt.)"; // PR3.61, P80041198
        NewTransferLine.ResetPostedQty;
        NewTransferLine."Outstanding Quantity" := NewTransferLine.Quantity;
        NewTransferLine."Outstanding Qty. (Base)" := NewTransferLine."Quantity (Base)";
        OnBeforeNewTransferLineInsert(NewTransferLine, TransferLine, NextLineNo);
        NewTransferLine.Insert();
        OnAfterCopyTransLine(NewTransferLine, TransferLine);
    end;

    procedure SetWhseActHeader(var WhseActHeader2: Record "Warehouse Activity Header")
    begin
        // P8000282A
        TempWhseActHeader := WhseActHeader2;
        TempWhseActHeader.Insert;
    end;

    local procedure XferRegsToWhse()
    var
        ItemReg2: Record "Item Register";
        ItemApplnEntryNo2: Integer;
        WhseReg2: Record "Warehouse Register";
        GLReg2: Record "G/L Register";
        NextVATEntryNo2: Integer;
        NextTransactionNo2: Integer;
    begin
        // P8000888
        ItemJnlPostLine.GetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2, WhseJnlPostLine);  //P80045166
        WhseJnlPostLine.SetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
    end;

    local procedure XferRegsFromWhse()
    var
        ItemReg2: Record "Item Register";
        ItemApplnEntryNo2: Integer;
        WhseReg2: Record "Warehouse Register";
        GLReg2: Record "G/L Register";
        NextVATEntryNo2: Integer;
        NextTransactionNo2: Integer;
    begin
        // P8000888
        WhseJnlPostLine.GetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
        ItemJnlPostLine.SetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
    end;

    local procedure XferWhseRoundingAdjmts(PostToWhse: Boolean)
    var
        TempWhseAdjmtLine: Record "Warehouse Journal Line" temporary;
    begin
        // P8001039
        if ItemJnlPostLine.GetWhseRoundingAdjmts(TempWhseAdjmtLine) then begin
            ItemJnlPostLine.ClearWhseRoundingAdjmts;
            RoundingAdjmtMgmt.AddWhseAdjmts(TempWhseAdjmtLine);
            if PostToWhse then
                WhseJnlPostLine.SetWhseRoundingAdjmts(TempWhseAdjmtLine);
        end;
    end;

    local procedure PostWhseRoundingAdjmts()
    var
        WhseJnlLine: Record "Warehouse Journal Line";
    begin
        // P8001039
        if RoundingAdjmtMgmt.WhseAdjmtsToPost() then begin
            WhseJnlPostLine.ClearWhseRoundingAdjmts;
            repeat
                RoundingAdjmtMgmt.BuildWhseAdjmtJnlLine(WhseJnlLine);
                WhseJnlPostLine.Run(WhseJnlLine);
            until (not RoundingAdjmtMgmt.WhseAdjmtsToPost());
        end;
    end;

    procedure GetWhseRoundingAdjmts(var TempWhseJnlLine: Record "Warehouse Journal Line" temporary): Boolean
    begin
        exit(RoundingAdjmtMgmt.GetWhseAdjmts(TempWhseJnlLine)); // P8001039
    end;

    local procedure ReleaseDocument(var TransferHeader: Record "Transfer Header")
    begin
        OnBeforeReleaseDocument(TransferHeader);

        if TransferHeader.Status = TransferHeader.Status::Open then begin
            CODEUNIT.Run(CODEUNIT::"Release Transfer Document", TransferHeader);
            TransferHeader.Status := TransferHeader.Status::Open;
            TransferHeader.Modify();
            if not SuppressCommit then
                Commit();
            TransferHeader.Status := TransferHeader.Status::Released;
        end;
    end;

    local procedure MakeInventoryAdjustment()
    var
        InvtAdjmtHandler: Codeunit "Inventory Adjustment Handler";
    begin
        InvtSetup.Get();
        if InvtSetup.AutomaticCostAdjmtRequired() then begin
            InvtAdjmtHandler.MakeInventoryAdjustment(true, InvtSetup."Automatic Cost Posting");
            OnAfterInvtAdjmt(TransHeader, TransShptHeader);
        end;
    end;

    procedure SetSuppressCommit(NewSuppressCommit: Boolean)
    begin
        SuppressCommit := NewSuppressCommit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line"; TransferShipmentHeader: Record "Transfer Shipment Header"; TransferShipmentLine: Record "Transfer Shipment Line"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeTransferOrderPostShipment(var TransferHeader: Record "Transfer Header"; var CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckItemNotBlocked(TransferLine: Record "Transfer Line"; Item: Record Item; TransferHeader: Record "Transfer Header"; Location: Record Location; WhseShip: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckInvtPostingSetup(var TransferHeader: Record "Transfer Header"; var TempWhseShipmentHeader: Record "Warehouse Shipment Header" temporary; var SourceCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line"; TransferShipmentHeader: Record "Transfer Shipment Header"; TransferShipmentLine: Record "Transfer Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyTransLine(var NewTransferLine: Record "Transfer Line"; TransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInvtAdjmt(var TransferHeader: Record "Transfer Header"; var TransferShipmentHeader: Record "Transfer Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransLineModify(var TransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferOrderPostShipment(var TransferHeader: Record "Transfer Header"; CommitIsSuppressed: Boolean; var TransferShipmentHeader: Record "Transfer Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertShptEntryRelation(var TransLine: Record "Transfer Line"; WhseShip: Boolean; EntryNo: Integer; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertTransShptHeader(var TransferHeader: Record "Transfer Header"; var TransferShipmentHeader: Record "Transfer Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertTransShptLine(var TransShptLine: Record "Transfer Shipment Line"; TransLine: Record "Transfer Line"; CommitIsSuppressed: Boolean; TransShptHeader: Record "Transfer Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertTransShptHeader(var TransShptHeader: Record "Transfer Shipment Header"; TransHeader: Record "Transfer Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDimValuePosting(TransferHeader: Record "Transfer Header"; TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckWarehouse(TransLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckItemInInventoryAndWarehouse(var TransLine: Record "Transfer Line"; NeedCheckWarehouse: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyTransLines(TransferHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyTransLine(var NewTransferLine: Record "Transfer Line"; TransferLine: Record "Transfer Line"; var NextLineNo: Integer; TransferHeader: Record "Transfer Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreatePostedShptLineFromWhseShptLine(var TransShptLine: Record "Transfer Shipment Line"; var WhseShptLine: Record "Warehouse Shipment Line"; var PostedWhseShptHeader: Record "Posted Whse. Shipment Header"; var PostedWhseShptLine: Record "Posted Whse. Shipment Line"; var TempWhseSplitSpecification: Record "Tracking Specification" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertTransShptLine(var TransShptLine: Record "Transfer Shipment Line"; TransLine: Record "Transfer Line"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; TransShptHeader: Record "Transfer Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteOneTransferOrder(TransferHeader: Record "Transfer Header"; var DeleteOne: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFinalizePosting(TransferHeader: Record "Transfer Header"; PostedWhseShptHeader: Record "Posted Whse. Shipment Header"; WhseShip: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGenNextNo(var TransferShipmentHeader: Record "Transfer Shipment Header"; TransferHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckItemInInventory(TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertShptEntryRelation(var TransShptLine: Record "Transfer Shipment Line"; TransferLine: Record "Transfer Line"; var ItemJnlLine: Record "Item Journal Line"; WhsePosting: Boolean; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var Result: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeNewTransferLineInsert(var NewTransferLine: Record "Transfer Line"; TransferLine: Record "Transfer Line"; var NextLineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostItem(var TransferShipmentHeader: Record "Transfer Shipment Header"; var IsHandled: Boolean; var TransferLine: Record "Transfer Line"; TransShptLine2: Record "Transfer Shipment Line"; WhseShip: Boolean; WhseShptHeader2: Record "Warehouse Shipment Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReleaseDocument(var TransferHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTransferTracking(var FromTransLine: Record "Transfer Line"; var ToTransLine: Record "Transfer Line"; TransferQty: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateWithWarehouseShipReceive(TransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckTransLine(TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header"; Location: Record Location; WhseShip: Boolean; TransShptLine: Record "Transfer Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertTransShptLineOnAfterCreatePostedShptLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; var PostedWhseShipmentLine: Record "Posted Whse. Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertTransShptLineOnBeforePostWhseJnlLine(TransShptLine: Record "Transfer Shipment Line"; TransLine: Record "Transfer Line"; SuppressCommit: Boolean; var WhsePosting: Boolean; var ShouldRunPosting: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertShptEntryRelationOnAfterCalcWhseSplitSpecification(TransLine: Record "Transfer Line"; var TransShptLine: Record "Transfer Shipment Line"; TempHandlingSpecification2: Record "Tracking Specification" temporary; var TempWhseSplitSpecification: Record "Tracking Specification" temporary; WhsePosting: Boolean; WhseShip: Boolean; InvtPickPutaway: Boolean; var WhseSplitSpecification: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeCommit(var TransferHeader: Record "Transfer Header"; var TransferShipmentHeader: Record "Transfer Shipment Header"; PostedWhseShptHeader: Record "Posted Whse. Shipment Header"; var SuppressCommit: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckDimComb(TransferHeader: Record "Transfer Header"; TransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostWhseJnlLineOnBeforeSplitWhseJnlLine()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertTransShipmentLine(TransLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnAfterTransLineSetFiltersForShptLines(var TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header"; Location: Record Location; WhseShip: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeInsertShipmentLines(var WhseShptHeader: Record "Warehouse Shipment Header"; var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeLockTables(var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostWhseJnlLine(ItemJnlLine: Record "Item Journal Line"; OriginalQuantity: Decimal; OriginalQuantityBase: Decimal; var IsHandled: Boolean)
    begin
    end;
}

