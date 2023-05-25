codeunit 5705 "TransferOrder-Post Receipt"
{
    // PR3.61
    //   Add logic for alternate quantities
    //   Add logic for container tracking
    // 
    // PR3.61.01
    //   There is a Navision bug that leaves records in the reservation entry table after posting transfer receipts
    //   This patch (until Navision provides a proper fix) will remove any such records after posting
    // 
    // PR3.70.01
    //   The bug described above has been fix in improvement 044 (NAVUS3.70.00.44), therefore the above fix has
    //   been removed
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
    // P8000928, Columbus IT, Jack Reynolds, 06 APR 11
    //   Support for Extra Charges
    // 
    // P8000931, Columbus IT, Jack Reynolds, 20 APR 11
    //   Support for Supply Chain Groups
    // 
    // PRW16.00.06
    // P8001032, Columbus IT, Jack Reynolds, 02 FEB 12
    //   Correct flaw in design of Document Extra Charge table
    // 
    // P8001039, Columbus IT, Don Bresee, 26 FEB 12
    //   Add Rounding Adjustment logic for Warehouse
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10.03
    // P8001328, Columbus IT, Jack Reynolds, 13 JUN 14
    //   Fix problem with posting extra charges for containers
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW110.0.02
    // P80045166, To-Increase, Dayakar Battini, 28 JUL 17
    //   Fix issue with multiple lots by passing the correct CU variable
    // 
    // PRW110.0.02
    // P80050544, To-Increase, Dayakar Battini, 12 FEB 18
    //   Upgrade to 2017 CU13
    // 
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers

    Permissions = TableData "Item Entry Relation" = i;
    TableNo = "Transfer Header";

    trigger OnRun()
    var
        Item: Record Item;
        SourceCodeSetup: Record "Source Code Setup";
        ValueEntry: Record "Value Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemApplnEntry: Record "Item Application Entry";
        ItemReg: Record "Item Register";
        InvtCommentLine: Record "Inventory Comment Line";
        UpdateAnalysisView: Codeunit "Update Analysis View";
        UpdateItemAnalysisView: Codeunit "Update Item Analysis View";
        ReservMgt: Codeunit "Reservation Management";
        RecordLinkManagement: Codeunit "Record Link Management";
        Window: Dialog;
        LineCount: Integer;
        NewDate: Date;
        UpdateDocumentLine: Codeunit "Update Document Line";
        DeleteOne: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOnRun(Rec, HideValidationDialog, SuppressCommit, IsHandled);
        if IsHandled then
            exit;

        ReleaseDocument(Rec);
        TransHeader := Rec;
        TransHeader.SetHideValidationDialog(HideValidationDialog);

        OnBeforeTransferOrderPostReceipt(TransHeader, SuppressCommit, ItemJnlPostLine);

        if ProcessFns.ContainerTrackingInstalled then          // P8001342
            ItemJnlPostLine.SetContainerFunctions(ContainerFns); // P8001342
        with TransHeader do begin
            CheckBeforePost();

            SaveAndClearPostingFromWhseRef();

            CheckDim();
            CheckLines(TransHeader, TransLine);

            WhseReceive := TempWhseRcptHeader.FindFirst();
            InvtPickPutaway := WhseReference <> 0;
            if not (WhseReceive or InvtPickPutaway) then
                CheckWarehouse(TransLine);

            WhsePosting := IsWarehousePosting("Transfer-to Code");

            if GuiAllowed then begin
                Window.Open(
                  '#1#################################\\' +
                  Text003);

                Window.Update(1, StrSubstNo(Text004, "No."));
            end;

            SourceCodeSetup.Get();
            SourceCode := SourceCodeSetup.Transfer;
            InvtSetup.Get();
            InvtSetup.TestField("Posted Transfer Rcpt. Nos.");

            CheckInvtPostingSetup();
            OnAfterCheckInvtPostingSetup(TransHeader, TempWhseRcptHeader, SourceCode);

            LockTables(InvtSetup."Automatic Cost Posting");

            // Insert receipt header
            if WhseReceive then
                PostedWhseRcptHeader.LockTable();
            TransRcptHeader.LockTable();
            InsertTransRcptHeader(TransRcptHeader, TransHeader, InvtSetup."Posted Transfer Rcpt. Nos.");

            if InvtSetup."Copy Comments Order to Rcpt." then begin
                InvtCommentLine.CopyCommentLines(
                    "Inventory Comment Document Type"::"Transfer Order", "No.",
                    "Inventory Comment Document Type"::"Posted Transfer Receipt", TransRcptHeader."No.");
                RecordLinkManagement.CopyLinks(Rec, TransRcptHeader);
            end;

            // P8000928
            if ProcessFns.FreshProInstalled then
                ExtraChargeMgmt.MoveToDocumentHeader(DATABASE::"Transfer Header", 0, "No.", "Posting Date", // P8000132
                 DATABASE::"Transfer Receipt Header", TransRcptHeader."No.");
            // P8000928

            if WhseReceive then begin
                WhseRcptHeader.Get(TempWhseRcptHeader."No.");
                WhsePostRcpt.CreatePostedRcptHeader(PostedWhseRcptHeader, WhseRcptHeader, TransRcptHeader."No.", "Posting Date");
                // P8001323
                if ProcessFns.ContainerTrackingInstalled then
                    ContainerFns.UpdateContainerQtyToReceive(WhseRcptHeader, DATABASE::"Transfer Line", 1, TransHeader."No.");
                // P8001323
            end;

            // P8000282A
            if ProcessFns.AltQtyInstalled() then
                AltQtyMgmt.CopyWhseActToTransfer(TempWhseActHeader, TransHeader);
            // P8000282A

            // Insert receipt lines
            LineCount := 0;
            if WhseReceive then
                PostedWhseRcptLine.LockTable();
            if InvtPickPutaway then
                WhseRqst.LockTable();
            TransRcptLine.LockTable();
            TransLine.SetRange(Quantity);
            TransLine.SetRange("Qty. to Receive");
            OnRunOnAfterTransLineSetFiltersForRcptLines(TransLine, TransHeader, Location, WhseReceive);
            if TransLine.Find('-') then
                repeat
                    if ProcessFns.ContainerTrackingInstalled then               // P8001342
                        ContainerFns.SetContainerDocumentLineSource(TransLine, 1); // P8001342
                    LineCount := LineCount + 1;
                    if GuiAllowed then
                        Window.Update(2, LineCount);

                    if (TransLine."Item No." <> '') and (TransLine."Qty. to Receive" <> 0) then begin
                        Item.Get(TransLine."Item No.");
                        IsHandled := false;
                        OnRunOnBeforeCheckItemBlocked(TransLine, Item, TransHeader, Location, WhseReceive, IsHandled);
                        if not IsHandled then
                            Item.TestField(Blocked, false);
                    end;

                    OnCheckTransLine(TransLine, TransHeader, Location, WhseReceive);

                    InsertTransRcptLine(TransRcptHeader, TransRcptLine, TransLine);
                until TransLine.Next() = 0;

            OnRunOnAfterInsertTransRcptLines(TransRcptHeader, TransLine, TransHeader, Location, WhseReceive);

            // P8001090
            if ProcessFns.ProcessDataCollectionInstalled then
                DataCollectionMgmt.CreateSheetForTransHeader(TransHeader, 1, true, TransRcptHeader."No.");
            // P8001090

            if ProcessFns.ContainerTrackingInstalled then                                 // P80046533
                ContainerFns.PostTransContainerHeader(TransHeader, 1, TransRcptHeader."No."); // P80046533

            MakeInventoryAdjustment();

            ValueEntry.LockTable();
            ItemLedgEntry.LockTable();
            ItemApplnEntry.LockTable();
            ItemReg.LockTable();
            TransLine.LockTable();
            if WhsePosting then
                WhseEntry.LockTable();

            TransLine.SetFilter(Quantity, '<>0');
            TransLine.SetFilter("Qty. to Receive", '<>0');
            if TransLine.Find('-') then
                repeat
                    TransLine.Validate("Qty. Received (Alt.)", TransLine."Qty. Received (Alt.)" + TransLine."Qty. to Receive (Alt.)"); // PR3.61
                    TransLine.Validate("Quantity Received", TransLine."Quantity Received" + TransLine."Qty. to Receive");
                    //TransLine."Qty. to Receive (Cont.)" := 0; // PR3.61, P80046533
                    OnRunOnBeforeUpdateWithWarehouseShipReceive(TransLine);
                    TransLine.UpdateWithWarehouseShipReceive();
                    ReservMgt.SetReservSource(ItemJnlLine);
                    ReservMgt.SetItemTrackingHandling(1); // Allow deletion
                    ReservMgt.DeleteReservEntries(true, 0);

                    // PR3.61
                    if TransLine."Alt. Qty. Trans. No. (Receive)" <> 0 then begin
                        AltQtyLine.SetRange("Alt. Qty. Transaction No.", TransLine."Alt. Qty. Trans. No. (Receive)");
                        AltQtyLine.DeleteAll;
                        TransLine."Qty. to Receive (Alt.)" := 0;
                    end;
                    TransLine."Alt. Qty. Trans. No. (Receive)" := 0;
                    // PR3.61

                    TransLine.Modify();
                    OnAfterTransLineUpdateQtyReceived(TransLine, SuppressCommit);
                until TransLine.Next() = 0;

            OnRunOnBeforePostUpdateDocumens(ItemJnlPostLine);

            if WhseReceive then
                WhseRcptLine.LockTable();
            LockTable();
            if WhseReceive then begin
                WhsePostRcpt.PostUpdateWhseDocuments(WhseRcptHeader);
                TempWhseRcptHeader.Delete();
            end;

            "Last Receipt No." := TransRcptHeader."No.";
            Modify();

            TransLine.SetRange(Quantity);
            TransLine.SetRange("Qty. to Receive");
            DeleteOne := ShouldDeleteOneTransferOrder(TransLine);
            OnBeforeDeleteOneTransferHeader(TransHeader, DeleteOne, TransRcptHeader);
            if DeleteOne then
                DeleteOneTransferOrder(TransHeader, TransLine)
            else begin
                WhseTransferRelease.Release(TransHeader);
                ReserveTransLine.UpdateItemTrackingAfterPosting(TransHeader, "Transfer Direction"::Inbound);
                // P80046533
                if ProcessFns.ContainerTrackingInstalled then begin
                    UpdateDocumentLine.SetApplication(true, DATABASE::"Transfer Line", 1, TransHeader."No.", 0);
                    UpdateDocumentLine.FixTracking;
                end;
                // P80046533
            end;

            OnRunOnBeforeCommit(TransHeader, TransRcptHeader, PostedWhseRcptHeader, SuppressCommit);
            if not (InvtPickPutaway or SuppressCommit) then begin
                Commit();
                UpdateAnalysisView.UpdateAll(0, true);
                UpdateItemAnalysisView.UpdateAll(0, true);
            end;
            Clear(WhsePostRcpt);
            if GuiAllowed() then
                Window.Close();
        end;

        Rec := TransHeader;

        OnAfterTransferOrderPostReceipt(Rec, SuppressCommit, TransRcptHeader);
    end;

    var
        Text002: Label 'Warehouse handling is required for Transfer order = %1, %2 = %3.', Comment = '1%=TransLine2."Document No."; 2%=TransLine2.FIELDCAPTION("Line No."); 3%=TransLine2."Line No.");';
        Text003: Label 'Posting transfer lines     #2######';
        Text004: Label 'Transfer Order %1';
        Text005: Label 'The combination of dimensions used in transfer order %1 is blocked. %2.';
        Text006: Label 'The combination of dimensions used in transfer order %1, line no. %2 is blocked. %3.';
        Text007: Label 'The dimensions that are used in transfer order %1, line no. %2 are not valid. %3.';
        Text008: Label 'Base Qty. to Receive must be 0.';
        InvtSetup: Record "Inventory Setup";
        TransRcptHeader: Record "Transfer Receipt Header";
        TransRcptLine: Record "Transfer Receipt Line";
        TransHeader: Record "Transfer Header";
        TransLine: Record "Transfer Line";
        ItemJnlLine: Record "Item Journal Line";
        Location: Record Location;
        NewLocation: Record Location;
        WhseRqst: Record "Warehouse Request";
        WhseRcptHeader: Record "Warehouse Receipt Header";
        TempWhseRcptHeader: Record "Warehouse Receipt Header" temporary;
        WhseRcptLine: Record "Warehouse Receipt Line";
        PostedWhseRcptHeader: Record "Posted Whse. Receipt Header";
        PostedWhseRcptLine: Record "Posted Whse. Receipt Line";
        TempWhseSplitSpecification: Record "Tracking Specification" temporary;
        WhseEntry: Record "Warehouse Entry";
        TempItemEntryRelation2: Record "Item Entry Relation" temporary;
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        DimMgt: Codeunit DimensionManagement;
        WhseTransferRelease: Codeunit "Whse.-Transfer Release";
        ReserveTransLine: Codeunit "Transfer Line-Reserve";
        WhsePostRcpt: Codeunit "Whse.-Post Receipt";
        DocumentErrorsMgt: Codeunit "Document Errors Mgt.";
        WhseJnlRegisterLine: Codeunit "Whse. Jnl.-Register Line";
        SourceCode: Code[10];
        WhsePosting: Boolean;
        WhseReference: Integer;
        OriginalQuantity: Decimal;
        OriginalQuantityBase: Decimal;
        WhseReceive: Boolean;
        InvtPickPutaway: Boolean;
        ContainerFns: Codeunit "Container Functions";
        AltQtyLine: Record "Alternate Quantity Line";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        ProcessFns: Codeunit "Process 800 Functions";
        TempWhseActHeader: Record "Warehouse Activity Header" temporary;
        RoundingAdjmtMgmt: Codeunit "Rounding Adjustment Mgmt.";
        WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line";
        ExtraChargeMgmt: Codeunit "Extra Charge Management";
        DataCollectionMgmt: Codeunit "Data Collection Management";
        SuppressCommit: Boolean;
        HideValidationDialog: Boolean;

    local procedure PostItemJnlLine(var TransLine3: Record "Transfer Line"; TransRcptHeader2: Record "Transfer Receipt Header"; TransRcptLine2: Record "Transfer Receipt Line")
    var
        ExtraChargeBuffer: Record "Extra Charge Posting Buffer" temporary;
        ExtraChargeQty: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforePostItemJnlLine(TransRcptHeader2, IsHandled, TransRcptLine2);
        if IsHandled then
            exit;

        ItemJnlLine.Init();
        ItemJnlLine."Posting Date" := TransRcptHeader2."Posting Date";
        ItemJnlLine."Document Date" := TransRcptHeader2."Posting Date";
        ItemJnlLine."Document No." := TransRcptHeader2."No.";
        ItemJnlLine."Document Type" := ItemJnlLine."Document Type"::"Transfer Receipt";
        ItemJnlLine."Document Line No." := TransRcptLine2."Line No.";
        ItemJnlLine."Order Type" := ItemJnlLine."Order Type"::Transfer;
        ItemJnlLine."Order No." := TransRcptHeader2."Transfer Order No.";
        ItemJnlLine."Order Line No." := TransLine3."Line No.";
        ItemJnlLine."External Document No." := TransRcptHeader2."External Document No.";
        ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Transfer;
        ItemJnlLine."Item No." := TransRcptLine2."Item No.";
        ItemJnlLine.Description := TransRcptLine2.Description;
        ItemJnlLine."Shortcut Dimension 1 Code" := TransRcptLine2."Shortcut Dimension 1 Code";
        ItemJnlLine."New Shortcut Dimension 1 Code" := TransRcptLine2."Shortcut Dimension 1 Code";
        ItemJnlLine."Shortcut Dimension 2 Code" := TransRcptLine2."Shortcut Dimension 2 Code";
        ItemJnlLine."New Shortcut Dimension 2 Code" := TransRcptLine2."Shortcut Dimension 2 Code";
        ItemJnlLine."Dimension Set ID" := TransRcptLine2."Dimension Set ID";
        ItemJnlLine."New Dimension Set ID" := TransRcptLine2."Dimension Set ID";
        ItemJnlLine."Location Code" := TransHeader."In-Transit Code";
        ItemJnlLine."New Location Code" := TransRcptHeader2."Transfer-to Code";
        ItemJnlLine.Quantity := TransRcptLine2.Quantity;
        ItemJnlLine."Invoiced Quantity" := TransRcptLine2.Quantity;
        ItemJnlLine."Quantity (Base)" := TransRcptLine2."Quantity (Base)";
        ItemJnlLine."Invoiced Qty. (Base)" := TransRcptLine2."Quantity (Base)";
        // PR3.61
        ItemJnlLine."Quantity (Alt.)" := TransRcptLine2."Quantity (Alt.)";
        ItemJnlLine."Invoiced Qty. (Alt.)" := TransRcptLine2."Quantity (Alt.)";
        if (TransRcptLine2."Quantity (Alt.)" <> 0) then
            ItemJnlLine."Alt. Qty. Transaction No." := TransLine3."Alt. Qty. Trans. No. (Receive)";
        // PR3.61
        ItemJnlLine."Source Code" := SourceCode;
        ItemJnlLine."Gen. Prod. Posting Group" := TransRcptLine2."Gen. Prod. Posting Group";
        ItemJnlLine."Inventory Posting Group" := TransRcptLine2."Inventory Posting Group";
        ItemJnlLine."Unit of Measure Code" := TransRcptLine2."Unit of Measure Code";
        ItemJnlLine."Qty. per Unit of Measure" := TransRcptLine2."Qty. per Unit of Measure";
        ItemJnlLine."Variant Code" := TransRcptLine2."Variant Code";
        ItemJnlLine."New Bin Code" := TransLine."Transfer-To Bin Code";
        ItemJnlLine."Item Category Code" := TransLine."Item Category Code";
        ItemJnlLine."Supply Chain Group Code" := TransLine."Supply Chain Group Code"; // P8000931
        if TransHeader."In-Transit Code" <> '' then begin
            if NewLocation.Code <> TransHeader."In-Transit Code" then
                NewLocation.Get(TransHeader."In-Transit Code");
            ItemJnlLine."Country/Region Code" := NewLocation."Country/Region Code";
        end;
        ItemJnlLine."Transaction Type" := TransRcptHeader2."Transaction Type";
        ItemJnlLine."Transport Method" := TransRcptHeader2."Transport Method";
        ItemJnlLine."Entry/Exit Point" := TransRcptHeader2."Entry/Exit Point";
        ItemJnlLine.Area := TransRcptHeader2.Area;
        ItemJnlLine."Transaction Specification" := TransRcptHeader2."Transaction Specification";
        ItemJnlLine."Shpt. Method Code" := TransRcptHeader2."Shipment Method Code";
        ItemJnlLine."Direct Transfer" := TransLine."Direct Transfer";
        WriteDownDerivedLines(TransLine3);
        ItemJnlPostLine.SetPostponeReservationHandling(true);

        RoundingAdjmtMgmt.AdjustItemJnlFixedAltQty(ItemJnlLine); // P8000550A

        // P8000928
        if (TransRcptLine2.Type = TransRcptLine2.Type::Item) and ProcessFns.FreshProInstalled then begin // P8001328
            ExtraChargeMgmt.AdjustItemJnlLine(ItemJnlLine, ExtraChargeBuffer, ExtraChargeQty);
            ItemJnlPostLine.SetExtraChargeBuffer(ExtraChargeBuffer, ExtraChargeQty);
        end;
        // P8000928

        OnBeforePostItemJournalLine(ItemJnlLine, TransLine3, TransRcptHeader2, TransRcptLine2, SuppressCommit, TransLine, PostedWhseRcptHeader);
        ItemJnlPostLine.RunWithCheck(ItemJnlLine);

        OnAfterPostItemJnlLine(ItemJnlLine, TransLine3, TransRcptHeader2, TransRcptLine2, ItemJnlPostLine);
    end;

    local procedure CheckDim()
    begin
        TransLine."Line No." := 0;
        CheckDimComb(TransHeader, TransLine);
        CheckDimValuePosting(TransHeader, TransLine);

        TransLine.SetRange("Document No.", TransHeader."No.");
        if TransLine.FindFirst() then begin
            CheckDimComb(TransHeader, TransLine);
            CheckDimValuePosting(TransHeader, TransLine);
        end;
    end;

    local procedure CheckDimComb(TransferHeader: Record "Transfer Header"; TransferLine: Record "Transfer Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckDimComb(TransferHeader, TransferLine, IsHandled);
        if IsHandled then
            exit;

        if TransferLine."Line No." = 0 then
            if not DimMgt.CheckDimIDComb(TransferHeader."Dimension Set ID") then
                Error(
                  Text005,
                  TransHeader."No.", DimMgt.GetDimCombErr());
        if TransferLine."Line No." <> 0 then
            if not DimMgt.CheckDimIDComb(TransferLine."Dimension Set ID") then
                Error(
                  Text006,
                  TransHeader."No.", TransferLine."Line No.", DimMgt.GetDimCombErr());

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
                Error(
                  Text007,
                  TransHeader."No.", TransferLine."Line No.", DimMgt.GetDimValuePostingErr());

        if TransferLine."Line No." <> 0 then
            if not DimMgt.CheckDimValuePosting(TableIDArr, NumberArr, TransferLine."Dimension Set ID") then
                Error(
                  Text007,
                  TransHeader."No.", TransferLine."Line No.", DimMgt.GetDimValuePostingErr());
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    local procedure SaveAndClearPostingFromWhseRef()
    begin
        WhseReference := TransHeader."Posting from Whse. Ref.";
        TransHeader."Posting from Whse. Ref." := 0;

        OnAfterSaveAndClearPostingFromWhseRef(TransHeader, Location);
    end;

    local procedure WriteDownDerivedLines(var TransLine3: Record "Transfer Line")
    var
        TransLine4: Record "Transfer Line";
        T337: Record "Reservation Entry";
        TempDerivedSpecification: Record "Tracking Specification" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        QtyToReceive: Decimal;
        BaseQtyToReceive: Decimal;
        TrackingSpecificationExists: Boolean;
        AltQtyToReceive: Decimal;
    begin
        TransLine4.SetRange("Document No.", TransLine3."Document No.");
        TransLine4.SetRange("Derived From Line No.", TransLine3."Line No.");
        if TransLine4.Find('-') then begin
            QtyToReceive := TransLine3."Qty. to Receive";
            BaseQtyToReceive := TransLine3."Qty. to Receive (Base)";
            AltQtyToReceive := TransLine3."Qty. to Receive (Alt.)"; // P8000267B

            T337.SetCurrentKey(
              "Source ID", "Source Ref. No.", "Source Type", "Source Subtype",
              "Source Batch Name", "Source Prod. Order Line");
            T337.SetRange("Source ID", TransLine3."Document No.");
            T337.SetRange("Source Ref. No.");
            T337.SetRange("Source Type", DATABASE::"Transfer Line");
            T337.SetRange("Source Subtype", 1);
            T337.SetRange("Source Batch Name", '');
            T337.SetRange("Source Prod. Order Line", TransLine3."Line No.");
            T337.SetFilter("Qty. to Handle (Base)", '<>0');

            TrackingSpecificationExists :=
              ItemTrackingMgt.SumUpItemTracking(T337, TempDerivedSpecification, true, false);

            repeat
                if TrackingSpecificationExists then begin
                    TempDerivedSpecification.SetRange("Source Ref. No.", TransLine4."Line No.");
                    if TempDerivedSpecification.FindFirst() then begin
                        TransLine4."Qty. to Receive (Base)" := TempDerivedSpecification."Qty. to Handle (Base)";
                        TransLine4."Qty. to Receive" := TempDerivedSpecification."Qty. to Handle";
                        TransLine4."Qty. to Receive (Alt.)" := TempDerivedSpecification."Qty. to Handle (Alt.)"; // P8000267B
                    end else begin
                        TransLine4."Qty. to Receive (Base)" := 0;
                        TransLine4."Qty. to Receive" := 0;
                        TransLine4."Qty. to Receive (Alt.)" := 0; // P8000267B
                    end;
                end;
                if TransLine4."Qty. to Receive (Base)" <= BaseQtyToReceive then begin
                    ReserveTransLine.TransferTransferToItemJnlLine(
                      TransLine4, ItemJnlLine, TransLine4."Qty. to Receive (Base)", "Transfer Direction"::Inbound);
                    TransLine4."Quantity (Base)" :=
                      TransLine4."Quantity (Base)" - TransLine4."Qty. to Receive (Base)";
                    TransLine4.Quantity :=
                      TransLine4.Quantity - TransLine4."Qty. to Receive";
                    TransLine4."Quantity (Alt.)" :=                                       // P8000267B
                      TransLine4."Quantity (Alt.)" - TransLine4."Qty. to Receive (Alt.)"; // P8000267B
                    BaseQtyToReceive := BaseQtyToReceive - TransLine4."Qty. to Receive (Base)";
                    QtyToReceive := QtyToReceive - TransLine4."Qty. to Receive";
                    AltQtyToReceive := AltQtyToReceive - TransLine4."Qty. to Receive (Alt.)"; // P8000267B
                end else begin
                    ReserveTransLine.TransferTransferToItemJnlLine(
                      TransLine4, ItemJnlLine, BaseQtyToReceive, "Transfer Direction"::Inbound);
                    TransLine4.Quantity := TransLine4.Quantity - QtyToReceive;
                    TransLine4."Quantity (Base)" := TransLine4."Quantity (Base)" - BaseQtyToReceive;
                    TransLine4."Quantity (Alt.)" := TransLine4."Quantity (Alt.)" - AltQtyToReceive; // P8000267B
                    BaseQtyToReceive := 0;
                    QtyToReceive := 0;
                    AltQtyToReceive := 0; // P8000267B
                end;
                if TransLine4."Quantity (Base)" = 0 then
                    TransLine4.Delete()
                else begin
                    TransLine4."Qty. to Ship" := TransLine4.Quantity;
                    TransLine4."Qty. to Ship (Base)" := TransLine4."Quantity (Base)";
                    TransLine4."Qty. to Receive" := TransLine4.Quantity;
                    TransLine4."Qty. to Receive (Base)" := TransLine4."Quantity (Base)";
                    TransLine4.ResetPostedQty();
                    TransLine4."Outstanding Quantity" := TransLine4.Quantity;
                    TransLine4."Outstanding Qty. (Base)" := TransLine4."Quantity (Base)";
                    // P8000267B
                    TransLine4."Qty. to Ship (Alt.)" := TransLine4."Quantity (Alt.)";
                    TransLine4."Qty. to Receive (Alt.)" := TransLine4."Quantity (Alt.)";
                    TransLine4."Qty. Shipped (Alt.)" := 0;
                    TransLine4."Qty. Received (Alt.)" := 0;
                    // P8000267B

                    OnWriteDownDerivedLinesOnBeforeTransLineModify(TransLine4, TransLine3);
                    TransLine4.Modify();
                end;
            until (TransLine4.Next() = 0) or (BaseQtyToReceive = 0);
        end;

        if BaseQtyToReceive <> 0 then
            Error(Text008);
    end;

    local procedure InsertRcptEntryRelation(var TransRcptLine: Record "Transfer Receipt Line") Result: Integer
    var
        ItemEntryRelation: Record "Item Entry Relation";
        TempItemEntryRelation: Record "Item Entry Relation" temporary;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInsertRcptEntryRelation(TransRcptLine, ItemJnlLine, ItemJnlPostLine, Result, IsHandled);
        if IsHandled then
            exit(Result);

        TempItemEntryRelation2.Reset();
        TempItemEntryRelation2.DeleteAll();

        if ItemJnlPostLine.CollectItemEntryRelation(TempItemEntryRelation) then begin
            if TempItemEntryRelation.Find('-') then begin
                repeat
                    ItemEntryRelation := TempItemEntryRelation;
                    ItemEntryRelation.TransferFieldsTransRcptLine(TransRcptLine);
                    ItemEntryRelation.Insert();
                    TempItemEntryRelation2 := TempItemEntryRelation;
                    TempItemEntryRelation2.Insert();
                until TempItemEntryRelation.Next() = 0;
                exit(0);
            end;
        end else
            exit(ItemJnlLine."Item Shpt. Entry No.");
    end;

    local procedure InsertTransRcptHeader(var TransRcptHeader: Record "Transfer Receipt Header"; TransHeader: Record "Transfer Header"; NoSeries: Code[20])
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Handled: Boolean;
    begin
        OnBeforeInsertTransRcptHeader(TransRcptHeader, TransHeader, SuppressCommit, Handled);
        if Handled then
            exit;

        TransRcptHeader.Init();
        TransRcptHeader.CopyFromTransferHeader(TransHeader);
        TransRcptHeader."No. Series" := NoSeries;
        OnInsertTransRcptHeaderOnBeforeGetNextNo(TransRcptHeader, TransHeader);
        if TransRcptHeader."No." = '' then
            TransRcptHeader."No." := NoSeriesMgt.GetNextNo(TransRcptHeader."No. Series", TransHeader."Posting Date", true);
        OnBeforeTransRcptHeaderInsert(TransRcptHeader, TransHeader);
        TransRcptHeader.Insert();

        OnAfterInsertTransRcptHeader(TransRcptHeader, TransHeader);
    end;

    local procedure InsertTransRcptLine(TransferReceiptHeader: Record "Transfer Receipt Header"; var TransRcptLine: Record "Transfer Receipt Line"; TransLine: Record "Transfer Line")
    var
        IsHandled: Boolean;
        ShouldRunPosting: Boolean;
    begin
        TransRcptLine.Init();
        TransRcptLine."Document No." := TransferReceiptHeader."No.";
        TransRcptLine.CopyFromTransferLine(TransLine);
        IsHandled := false;
        OnBeforeInsertTransRcptLine(TransRcptLine, TransLine, SuppressCommit, IsHandled, TransferReceiptHeader);
        if IsHandled then
            exit;

        TransRcptLine.Insert();
        if TransLine."Alt. Qty. Trans. No. (Receive)" <> 0 then       // PR3.61
            AltQtyMgmt.TransLineToReceiptLine(TransLine, TransRcptLine); // PR3.61

        RoundingAdjmtMgmt.SetFixedAltQtyTransLine(TransLine, 1); // P8000550A
        OnAfterInsertTransRcptLine(TransRcptLine, TransLine, SuppressCommit, TransferReceiptHeader);

        if TransLine."Qty. to Receive" > 0 then begin
            OriginalQuantity := TransLine."Qty. to Receive";
            OriginalQuantityBase := TransLine."Qty. to Receive (Base)";
            // P8000928
            if (TransLine.Type = TransLine.Type::Item) and ProcessFns.FreshProInstalled then
                ExtraChargeMgmt.StartTransferPosting(TransHeader, TransLine);
            // P8000928
            PostItemJnlLine(TransLine, TransRcptHeader, TransRcptLine);
            TransRcptLine."Item Rcpt. Entry No." := InsertRcptEntryRelation(TransRcptLine);
            TransRcptLine.Modify();
            SaveTempWhseSplitSpec(TransLine);
            if WhseReceive and (TransLine.Type <> TransLine.Type::Container) then begin // P8001323
                WhseRcptLine.SetCurrentKey(
                  "No.", "Source Type", "Source Subtype", "Source No.", "Source Line No.");
                WhseRcptLine.SetRange("No.", WhseRcptHeader."No.");
                WhseRcptLine.SetRange("Source Type", DATABASE::"Transfer Line");
                WhseRcptLine.SetRange("Source No.", TransLine."Document No.");
                WhseRcptLine.SetRange("Source Line No.", TransLine."Line No.");
                OnInsertTransRcptLineOnAfterWhseRcptLineSetFilters(TransLine, TransRcptLine, WhseRcptLine);
                if WhseRcptLine.FindFirst() then
                    CreatePostedRcptLineFromWhseRcptLine(TransRcptLine);
            end;
            ShouldRunPosting := WhsePosting;
            OnInsertTransRcptLineOnBeforePostWhseJnlLine(TransRcptLine, TransLine, SuppressCommit, WhsePosting, ShouldRunPosting);
            if ShouldRunPosting then
                PostWhseJnlLine(ItemJnlLine, OriginalQuantity, OriginalQuantityBase, TempWhseSplitSpecification);
            OnAfterTransRcptLineModify(TransRcptLine, TransLine, SuppressCommit);
        end;
        // P8000928
        if (TransRcptLine.Type = TransRcptLine.Type::Item) and ProcessFns.FreshProInstalled then
            ExtraChargeMgmt.MoveToDocumentLine(
              DATABASE::"Transfer Receipt Line", TransRcptLine."Document No.", TransRcptLine."Line No.");
        // P8000928
    end;

    local procedure CreatePostedRcptLineFromWhseRcptLine(var TransferReceiptLine: Record "Transfer Receipt Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreatePostedRcptLineFromWhseRcptLine(TransferReceiptLine, WhseRcptLine, PostedWhseRcptHeader, PostedWhseRcptLine, TempWhseSplitSpecification, IsHandled, WhsePostRcpt, TempItemEntryRelation2);
        if IsHandled then
            exit;

        WhseRcptLine.TestField("Qty. to Receive", TransferReceiptLine.Quantity);
        WhsePostRcpt.SetItemEntryRelation(PostedWhseRcptHeader, PostedWhseRcptLine, TempItemEntryRelation2);
        WhsePostRcpt.CreatePostedRcptLine(
          WhseRcptLine, PostedWhseRcptHeader, PostedWhseRcptLine, TempWhseSplitSpecification);
    end;

    local procedure CheckLines(TransHeader: Record "Transfer Header"; var TransLine: Record "Transfer Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckLines(TransHeader, TransLine, IsHandled);
        if IsHandled then
            exit;

        with TransHeader do begin
            TransLine.Reset();
            TransLine.SetRange("Document No.", "No.");
            TransLine.SetRange("Derived From Line No.", 0);
            TransLine.SetFilter(Quantity, '<>0');
            TransLine.SetFilter("Qty. to Receive", '<>0');
            if not TransLine.Find('-') then
                Error(DocumentErrorsMgt.GetNothingToPostErrorMsg());
        end;
    end;

    local procedure CheckWarehouse(var TransLine: Record "Transfer Line")
    var
        TransLine2: Record "Transfer Line";
        WhseValidateSourceLine: Codeunit "Whse. Validate Source Line";
        ShowError: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckWarehouse(TransLine, IsHandled);
        If IsHandled then
            exit;

        TransLine2.Copy(TransLine);
        if TransLine2.Find('-') then
            repeat
                GetLocation(TransLine2."Transfer-to Code");
                if Location."Require Receive" or Location."Require Put-away" then begin
                    if Location."Bin Mandatory" then
                        ShowError := true
                    else
                        if WhseValidateSourceLine.WhseLinesExist(
                             DATABASE::"Transfer Line",
                             1,// In
                             TransLine2."Document No.",
                             TransLine2."Line No.",
                             0,
                             TransLine2.Quantity)
                        then
                            ShowError := true;

                    if ShowError then
                        Error(
                          Text002,
                          TransLine2."Document No.",
                          TransLine2.FieldCaption("Line No."),
                          TransLine2."Line No.");
                end;
            until TransLine2.Next() = 0;
    end;

    local procedure SaveTempWhseSplitSpec(TransLine: Record "Transfer Line")
    var
        TempHandlingSpecification: Record "Tracking Specification" temporary;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSaveTempWhseSplitSpec(TransLine, ItemJnlPostLine, IsHandled);
        if IsHandled then
            exit;

        TempWhseSplitSpecification.Reset();
        TempWhseSplitSpecification.DeleteAll();
        if ItemJnlPostLine.CollectTrackingSpecification(TempHandlingSpecification) then
            if TempHandlingSpecification.Find('-') then
                repeat
                    TempWhseSplitSpecification := TempHandlingSpecification;
                    TempWhseSplitSpecification."Entry No." := TempHandlingSpecification."Transfer Item Entry No.";
                    TempWhseSplitSpecification."Source Type" := DATABASE::"Transfer Line";
                    TempWhseSplitSpecification."Source Subtype" := 1;
                    TempWhseSplitSpecification."Source ID" := TransLine."Document No.";
                    TempWhseSplitSpecification."Source Ref. No." := TransLine."Line No.";
                    TempWhseSplitSpecification.Insert();
                until TempHandlingSpecification.Next() = 0;
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Location.GetLocationSetup(LocationCode, Location)
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);
    end;

    local procedure IsWarehousePosting(LocationCode: Code[10]): Boolean
    begin
        GetLocation(LocationCode);
        if Location."Bin Mandatory" and not (WhseReceive or InvtPickPutaway) then
            exit(true);
        exit(false);
    end;

    local procedure PostWhseJnlLine(ItemJnlLine: Record "Item Journal Line"; OriginalQuantity: Decimal; OriginalQuantityBase: Decimal; var TempHandlingSpecification: Record "Tracking Specification" temporary)
    var
        WhseJnlLine: Record "Warehouse Journal Line";
        TempWhseJnlLine2: Record "Warehouse Journal Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WMSMgmt: Codeunit "WMS Management";
        WhseJnlLineCreated: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostWhseJnlLine(ItemJnlLine, OriginalQuantity, OriginalQuantityBase, TempHandlingSpecification, IsHandled);
        if IsHandled then
            exit;

        with ItemJnlLine do begin
            Quantity := OriginalQuantity;
            "Quantity (Base)" := OriginalQuantityBase;
            GetLocation("New Location Code");
            // P8001039
            // IF Location."Bin Mandatory" THEN
            //   IF WMSMgmt.CreateWhseJnlLine(ItemJnlLine,1,WhseJnlLine,TRUE) THEN BEGIN
            if Location."Bin Mandatory" then begin
                WhseJnlLineCreated := WMSMgmt.CreateWhseJnlLine(ItemJnlLine, 1, WhseJnlLine, true); // P8001132
                XferWhseRoundingAdjmts(WhseJnlLineCreated);
                if WhseJnlLineCreated then begin
                    // P8001039
                    XferRegsToWhse; // P8000888
                    WMSMgmt.SetTransferLine(TransLine, WhseJnlLine, 1, TransRcptHeader."No.");
                    OnPostWhseJnlLineOnBeforeSplitWhseJnlLine();
                    ItemTrackingMgt.SplitWhseJnlLine(WhseJnlLine, TempWhseJnlLine2, TempHandlingSpecification, true);
                    if TempWhseJnlLine2.Find('-') then
                        repeat
                            WMSMgmt.CheckWhseJnlLine(TempWhseJnlLine2, 1, 0, true);
                            WhseJnlRegisterLine.RegisterWhseJnlLine(TempWhseJnlLine2);
                        until TempWhseJnlLine2.Next() = 0;
                    PostWhseRoundingAdjmts; // P8001039
                    XferRegsFromWhse; // P8000888
                end;
            end; // P8001039
        end;
    end;

    procedure SetWhseRcptHeader(var WhseRcptHeader2: Record "Warehouse Receipt Header")
    begin
        WhseRcptHeader := WhseRcptHeader2;
        TempWhseRcptHeader := WhseRcptHeader;
        TempWhseRcptHeader.Insert();
    end;

    local procedure LockTables(AutoCostPosting: Boolean)
    var
        GLEntry: Record "G/L Entry";
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeriesLine.LockTable();
        if NoSeriesLine.FindLast() then;
        if AutoCostPosting then begin
            GLEntry.LockTable();
            if GLEntry.FindLast() then;
        end;
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
        if InvtSetup.AutomaticCostAdjmtRequired() then
            InvtAdjmtHandler.MakeInventoryAdjustment(true, InvtSetup."Automatic Cost Posting");
    end;

    procedure SetSuppressCommit(NewSuppressCommit: Boolean)
    begin
        SuppressCommit := NewSuppressCommit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line"; TransferReceiptHeader: Record "Transfer Receipt Header"; TransferReceiptLine: Record "Transfer Receipt Line"; CommitIsSuppressed: Boolean; TransLine: Record "Transfer Line"; PostedWhseRcptHeader: Record "Posted Whse. Receipt Header")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeTransferOrderPostReceipt(var TransferHeader: Record "Transfer Header"; var CommitIsSuppressed: Boolean; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertTransRcptLine(var TransRcptLine: Record "Transfer Receipt Line"; TransLine: Record "Transfer Line"; CommitIsSuppressed: Boolean; TransferReceiptHeader: Record "Transfer Receipt Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSaveAndClearPostingFromWhseRef(var TransferHeader: Record "Transfer Header"; var Location: Record Location)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferOrderPostReceipt(var TransferHeader: Record "Transfer Header"; CommitIsSuppressed: Boolean; var TransferReceiptHeader: Record "Transfer Receipt Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferOderPostReceipt(var TransferHeader: Record "Transfer Header")
    begin
        // will be deprecated
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

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransLineUpdateQtyReceived(var TransferLine: Record "Transfer Line"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransRcptLineModify(var TransferReceiptLine: Record "Transfer Receipt Line"; TransferLine: Record "Transfer Line"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDimComb(TransferHeader: Record "Transfer Header"; TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckLines(TransHeader: Record "Transfer Header"; var TransLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDimValuePosting(TransferHeader: Record "Transfer Header"; TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckWarehouse(var TransferLine: Record "Transfer Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreatePostedRcptLineFromWhseRcptLine(var TransRcptLine: Record "Transfer Receipt Line"; var WhseRcptLine: Record "Warehouse Receipt Line"; var PostedWhseRcptHeader: Record "Posted Whse. Receipt Header"; var PostedWhseRcptLine: Record "Posted Whse. Receipt Line"; var TempWhseSplitSpecification: Record "Tracking Specification" temporary; var IsHandled: Boolean; var WhsePostReceipt: Codeunit "Whse.-Post Receipt"; var TempItemEntryRelation2: Record "Item Entry Relation" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnRun(var TransferHeader2: Record "Transfer Header"; HideValidationDialog: Boolean; SuppressCommit: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertTransRcptHeader(var TransRcptHeader: Record "Transfer Receipt Header"; TransHeader: Record "Transfer Header"; CommitIsSuppressed: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostWhseJnlLine(ItemJnlLine: Record "Item Journal Line"; OriginalQuantity: Decimal; OriginalQuantityBase: Decimal; var TempHandlingSpecification: Record "Tracking Specification" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertTransRcptLine(var TransRcptLine: Record "Transfer Receipt Line"; TransLine: Record "Transfer Line"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; TransferReceiptHeader: Record "Transfer Receipt Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertRcptEntryRelation(var TransRcptLine: Record "Transfer Receipt Line"; var ItemJnlLine: Record "Item Journal Line"; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var Result: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTransRcptHeaderInsert(var TransferReceiptHeader: Record "Transfer Receipt Header"; TransferHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteOneTransferHeader(TransferHeader: Record "Transfer Header"; var DeleteOne: Boolean; TransferReceiptHeader: Record "Transfer Receipt Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostItemJnlLine(var TransferReceiptHeader: Record "Transfer Receipt Header"; var IsHandled: Boolean; TransferReceiptLine: Record "Transfer Receipt Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReleaseDocument(var TransferHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSaveTempWhseSplitSpec(TransLine: Record "Transfer Line"; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckInvtPostingSetup(var TransferHeader: Record "Transfer Header"; var WarehouseReceiptHeader: Record "Warehouse Receipt Header"; var SourceCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckTransLine(TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header"; Location: Record Location; WhseReceive: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnWriteDownDerivedLinesOnBeforeTransLineModify(var TransferLine: Record "Transfer Line"; SourceTransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertTransRcptHeader(var TransRcptHeader: Record "Transfer Receipt Header"; var TransHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertTransRcptHeaderOnBeforeGetNextNo(var TransRcptHeader: Record "Transfer Receipt Header"; TransHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertTransRcptLineOnBeforePostWhseJnlLine(var TransRcptLine: Record "Transfer Receipt Line"; var TransLine: Record "Transfer Line"; SuppressCommit: Boolean; var WhsePosting: Boolean; var ShouldRunPosting: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostWhseJnlLineOnBeforeSplitWhseJnlLine()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeCommit(var TransHeader: Record "Transfer Header"; var TransRcptHeader: Record "Transfer Receipt Header"; PostedWhseRcptHeader: Record "Posted Whse. Receipt Header"; var SuppressCommit: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckDimComb(TransferHeader: Record "Transfer Header"; TransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostItemJnlLine(ItemJnlLine: Record "Item Journal Line"; var TransLine3: Record "Transfer Line"; var TransRcptHeader2: Record "Transfer Receipt Header"; var TransRcptLine2: Record "Transfer Receipt Line"; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnAfterTransLineSetFiltersForRcptLines(var TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header"; Location: Record Location; WhseReceive: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnAfterInsertTransRcptLines(TransRcptHeader: Record "Transfer Receipt Header"; TransferLine: Record "Transfer Line"; TransferHeader: Record "Transfer Header"; Location: Record Location; WhseReceive: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforePostUpdateDocumens(var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertTransRcptLineOnAfterWhseRcptLineSetFilters(var TransferLine: Record "Transfer Line"; var TransferRcptLine: Record "Transfer Receipt Line"; var WarehouseReceiptLine: Record "Warehouse Receipt Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeCheckItemBlocked(TransLine: Record "Transfer Line"; Item: Record Item; TransHeader: Record "Transfer Header"; Location: Record Location; WhseReceive: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeUpdateWithWarehouseShipReceive(var TransferLine: Record "Transfer Line")
    begin
    end;
}

