codeunit 23 "Item Jnl.-Post Batch"
{
    // PR3.10
    //   Allow bypass of commit if called from Production Output
    // 
    // PR3.60
    //   Skip update of analysis view if called from Production Reporting (it does a commit)
    // 
    // PR3.61
    //   Add logic for physical count with item tracking
    //   Add logic for container tracking
    // 
    // PR3.70
    //   Integration of P800 into 3.70
    // 
    // PR3.70.06
    // P8000106A, Myers Nissi, Jack Reynolds, 02 SEP 04
    //   Modify to support alternate quantities in revaluation journal
    // 
    // PR4.00
    // P8000250B, Myers Nissi, Jack Reynolds, 17 OCT 05
    //   Support for automatic lot number assignment
    // 
    // PR4.00.02
    // P8000316A, VerticalSoft, Jack Reynolds, 03 APR 06
    //   Support using output lot number on consumption during posting of batch reporting
    // 
    // PR5.00
    // P8000495A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Fixed Bin logic
    // 
    // PRW15.00.01
    // P8000543A, VerticalSoft, Jack Reynolds, 14 NOV 07
    //   Fix permission problem with combining lots
    // 
    // P8000591A, VerticalSoft, Don Bresee, 02 APR 08
    //   Add Alt. Qtys. to Whse. Adjustment logic
    //   Resolve Adjustment Bin after item posting
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    //   Add Central Container Bin
    // 
    // PRW16.00.04
    // P8000888, VerticalSoft, Don Bresee, 13 DEC 10
    //   Use new codeunit in place of form for combining lots
    // 
    // PRW16.00.05
    // P8000958, Columbus IT, Don Bresee, 14 JUN 11
    //   Add logic to handle registers
    // 
    // PRW16.00.06
    // P8001039, Columbus IT, Don Bresee, 26 FEB 12
    //   Add Rounding Adjustment logic for Warehouse
    // 
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // P8001083, Columbus IT, Jack Reynolds, 09 AUG 12
    //   Refactored so that PostWhseJnlLine can be called externally
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.00.01
    // P8001186, Columbus IT, Jack Reynolds, 25 JUL 13
    //   Fix problem posting container lines
    // 
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW17.10.02
    // P8001302, Columbus IT, Jack Reynolds, 05 MAR 14
    //   Combine CalculateRemQuantity and CalculateRemAltQuantity
    // 
    // P8001303, Columbus IT, Jack Reynolds, 05 MAR 14
    //   Fix problem committing changes before all posting has completed
    // 
    // PRW17.10.03
    // P8001314, Columbus IT, Jack Reynolds, 23 APR 14
    //   Fix problem reassigniong lot number when posting
    // 
    // PRW19.00.01
    // P8007118, To Increase, Jack Reynolds, 01 JUN 16
    //   Fix permission problem with combining lots
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW110.0.02
    // P80045166, To-Increase, Dayakar Battini, 28 JUL 17
    //   Fix issue with multiple lots by passing the correct CU variable
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW11300.03
    // P80082969, To Increase, Jack Reynolds, 26 SEP 19
    //   New Events

    Permissions = TableData "Item Journal Batch" = imd,
                  TableData "Warehouse Register" = r;
    TableNo = "Item Journal Line";

    trigger OnRun()
    begin
        ItemJnlLine.Copy(Rec);
        ItemJnlLine.SetAutoCalcFields;
        Code;
        Rec := ItemJnlLine;
    end;

    var
        Text001: Label 'Journal Batch Name    #1##########\\';
        Text002: Label 'Checking lines        #2######\';
        Text003: Label 'Posting lines         #3###### @4@@@@@@@@@@@@@\';
        Text004: Label 'Updating lines        #5###### @6@@@@@@@@@@@@@';
        Text005: Label 'Posting lines         #3###### @4@@@@@@@@@@@@@';
        Text006: Label 'A maximum of %1 posting number series can be used in each journal.';
        Text008: Label 'There are new postings made in the period you want to revalue item no. %1.\';
        Text009: Label 'You must calculate the inventory value again.';
        Text010: Label 'One or more reservation entries exist for the item with %1 = %2, %3 = %4, %5 = %6 which may be disrupted if you post this negative adjustment. Do you want to continue?', Comment = 'One or more reservation entries exist for the item with Item No. = 1000, Location Code = BLUE, Variant Code = NEW which may be disrupted if you post this negative adjustment. Do you want to continue?';
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlBatch: Record "Item Journal Batch";
        ItemJnlLine: Record "Item Journal Line";
        ItemLedgEntry: Record "Item Ledger Entry";
        WhseEntry: Record "Warehouse Entry";
        ItemReg: Record "Item Register";
        WhseReg: Record "Warehouse Register";
        GLSetup: Record "General Ledger Setup";
        InvtSetup: Record "Inventory Setup";
        AccountingPeriod: Record "Accounting Period";
        NoSeries: Record "No. Series" temporary;
        Location: Record Location;
        ItemJnlCheckLine: Codeunit "Item Jnl.-Check Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesMgt2: array[10] of Codeunit NoSeriesManagement;
        WMSMgmt: Codeunit "WMS Management";
        WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line";
        InvtAdjmtHandler: Codeunit "Inventory Adjustment Handler";
        Window: Dialog;
        ItemRegNo: Integer;
        WhseRegNo: Integer;
        StartLineNo: Integer;
        NoOfRecords: Integer;
        LineCount: Integer;
        LastDocNo: Code[20];
        LastDocNo2: Code[20];
        LastPostedDocNo: Code[20];
        NoOfPostingNoSeries: Integer;
        PostingNoSeriesNo: Integer;
        WhseTransaction: Boolean;
        PhysInvtCount: Boolean;
        ProcessFns: Codeunit "Process 800 Functions";
        P800Tracking: Codeunit "Process 800 Item Tracking";
        ContainerFns: Codeunit "Container Functions";
        P800Globals: Codeunit "Process 800 System Globals";
        OutputLotNo: Record "Prod. Order Line" temporary;
        CombineLots: Codeunit "Combine Whse. Lots";
        P8001DocWhseMgmt: Codeunit "Process 800 1-Doc Whse. Mgmt.";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        RoundingAdjmtMgmt: Codeunit "Rounding Adjustment Mgmt.";
        PostItemJnlLine: Boolean;
        SuppressCommit: Boolean;
        WindowIsOpen: Boolean;

    local procedure "Code"()
    var
        UpdateAnalysisView: Codeunit "Update Analysis View";
        UpdateItemAnalysisView: Codeunit "Update Item Analysis View";
        PhysInvtCountMgt: Codeunit "Phys. Invt. Count.-Management";
        OldEntryType: Enum "Item Ledger Entry Type";
        OriginalQuantityAlt: Decimal;
        RaiseError: Boolean;
    begin
        OnBeforeCode(ItemJnlLine);

        with ItemJnlLine do begin
            LockTable();
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");

            ItemJnlTemplate.Get("Journal Template Name");
            ItemJnlBatch.Get("Journal Template Name", "Journal Batch Name");

            OnBeforeRaiseExceedLengthError(ItemJnlBatch, RaiseError);

            if ItemJnlTemplate.Recurring then begin
                SetRange("Posting Date", 0D, WorkDate);
                SetFilter("Expiration Date", '%1 | %2..', 0D, WorkDate);
            end;

            if not Find('=><') then begin
                "Line No." := 0;
                if not SuppressCommit then
                    Commit();
                exit;
            end;

            CheckItemAvailability(ItemJnlLine);

            OpenProgressDialog();

            CheckLines(ItemJnlLine);

            // Find next register no.
            ItemLedgEntry.LockTable();
            if ItemLedgEntry.FindLast() then;
            if WhseTransaction then begin
                WhseEntry.LockTable();
                if WhseEntry.FindLast() then;
            end;

            ItemReg.LockTable();
            ItemRegNo := ItemReg.GetLastEntryNo() + 1;

            WhseReg.LockTable();
            WhseRegNo := WhseReg.GetLastEntryNo() + 1;

            GLSetup.Get();
            PhysInvtCount := false;

            // Post lines
            OnCodeOnBeforePostLines(ItemJnlLine, NoOfRecords);
            LineCount := 0;
            OldEntryType := "Entry Type";
            PostLines(ItemJnlLine, PhysInvtCountMgt);

            // Copy register no. and current journal batch name to item journal
            if not ItemReg.FindLast or (ItemReg."No." <> ItemRegNo) then
                ItemRegNo := 0;
            if not WhseReg.FindLast or (WhseReg."No." <> WhseRegNo) then
                WhseRegNo := 0;

            OnAfterCopyRegNos(ItemJnlLine, ItemRegNo, WhseRegNo);

            Init;

            "Line No." := ItemRegNo;
            if "Line No." = 0 then
                "Line No." := WhseRegNo;

            InvtSetup.Get();
            if InvtSetup.AutomaticCostAdjmtRequired() then
                InvtAdjmtHandler.MakeInventoryAdjustment(true, InvtSetup."Automatic Cost Posting");

            // Update/delete lines
            OnBeforeUpdateDeleteLines(ItemJnlLine, ItemRegNo);
            if "Line No." <> 0 then begin
                if ItemJnlTemplate.Recurring then begin
                    HandleRecurringLine(ItemJnlLine);
                end else
                    HandleNonRecurringLine(ItemJnlLine, OldEntryType);
                if ItemJnlBatch."No. Series" <> '' then
                    NoSeriesMgt.SaveNoSeries;
                if NoSeries.FindSet() then
                    repeat
                        Evaluate(PostingNoSeriesNo, NoSeries.Description);
                        NoSeriesMgt2[PostingNoSeriesNo].SaveNoSeries;
                    until NoSeries.Next() = 0;
            end;

            if PhysInvtCount then
                PhysInvtCountMgt.UpdateItemSKUListPhysInvtCount;

            OnAfterPostJnlLines(ItemJnlBatch, ItemJnlLine, ItemRegNo, WhseRegNo, WindowIsOpen);

            if WindowIsOpen then
                Window.Close;
            if not SuppressCommit then
                Commit();
            Clear(ItemJnlCheckLine);
            Clear(ItemJnlPostLine);
            Clear(WhseJnlPostLine);
            Clear(InvtAdjmtHandler);
        end;
        UpdateAnalysisView.UpdateAll(0, true);
        UpdateItemAnalysisView.UpdateAll(0, true);

        OnAfterUpdateAnalysisViews(ItemReg);

        if not SuppressCommit then
            Commit();
    end;

    local procedure OpenProgressDialog()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOpenProgressDialog(ItemJnlLine, Window, WindowIsOpen, IsHandled);
        if IsHandled then
            exit;

        if ItemJnlTemplate.Recurring then
            Window.Open(
              Text001 +
              Text002 +
              Text003 +
              Text004)
        else
            Window.Open(
              Text001 +
              Text002 +
              Text005);

        Window.Update(1, ItemJnlLine."Journal Batch Name");
        WindowIsOpen := true;
    end;

    local procedure CheckLines(var ItemJnlLine: Record "Item Journal Line")
    begin
        OnBeforeCheckLines(ItemJnlLine, WindowIsOpen);

        with ItemJnlLine do begin
            LineCount := 0;
            StartLineNo := "Line No.";
            repeat
                LineCount := LineCount + 1;
                if WindowIsOpen then
                    Window.Update(2, LineCount);
                CheckRecurringLine(ItemJnlLine);

                if ((("Value Entry Type" = "Value Entry Type"::"Direct Cost") and ("Item Charge No." = '')) or // PR3.61
                   ((GetCostingQty(FieldNo("Invoiced Quantity")) <> 0) and (Amount <> 0)))                     // PR3.61, P8000106A
                then begin
                    ItemJnlCheckLine.RunCheck(ItemJnlLine);

                    if (Quantity <> 0) and
                       ("Value Entry Type" = "Value Entry Type"::"Direct Cost") and
                       ("Item Charge No." = '')
                    then
                        CheckWMSBin(ItemJnlLine);

                    if ("Value Entry Type" = "Value Entry Type"::Revaluation) and
                       ("Inventory Value Per" = "Inventory Value Per"::" ") and
                       "Partial Revaluation"
                    then
                        CheckRemainingQty;

                    OnAfterCheckJnlLine(ItemJnlLine, SuppressCommit);
                end;

                if Next() = 0 then
                    FindFirst();
            until "Line No." = StartLineNo;
            NoOfRecords := LineCount;
        end;

        OnAfterCheckLines(ItemJnlLine);
    end;

    local procedure PostLines(var ItemJnlLine: Record "Item Journal Line"; var PhysInvtCountMgt: Codeunit "Phys. Invt. Count.-Management")
    var
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        OriginalQuantity: Decimal;
        OriginalQuantityBase: Decimal;
        OriginalQuantityAlt: Decimal;
    begin
        LastDocNo := '';
        LastDocNo2 := '';
        LastPostedDocNo := '';
        with ItemJnlLine do begin
            SetCurrentKey("Journal Template Name", "Journal Batch Name", "Line No.");
            FindSet();
            repeat
                if not EmptyLine and
                   (ItemJnlBatch."No. Series" <> '') and
                   ("Document No." <> LastDocNo2)
                then
                    TestField("Document No.", NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", "Posting Date", false));
                if not EmptyLine then
                    LastDocNo2 := "Document No.";
                MakeRecurringTexts(ItemJnlLine);
                ConstructPostingNumber(ItemJnlLine);

                OnPostLinesOnBeforePostLine(ItemJnlLine, SuppressCommit, WindowIsOpen);

                if "Inventory Value Per" <> "Inventory Value Per"::" " then
                    ItemJnlPostSumLine(ItemJnlLine)
                else
                    if (("Value Entry Type" = "Value Entry Type"::"Direct Cost") and ("Item Charge No." = '')) or
                       ((GetCostingQty(FieldNo("Invoiced Quantity")) <> 0) and (Amount <> 0)) // P8000106A
                    then begin
                        LineCount := LineCount + 1;
                        if WindowIsOpen then begin
                            Window.Update(3, LineCount);
                            Window.Update(4, Round(LineCount / NoOfRecords * 10000, 1));
                        end;
                        OriginalQuantity := Quantity;
                        OriginalQuantityBase := "Quantity (Base)";
                        OriginalQuantityAlt := "Quantity (Alt.)"; // P8000591A
                        AutoLotNo(true); // P8000250B, P8001234, P8001314
                        SaveOutputLotNo(ItemJnlLine); // P8000316A
                        UseOutputLotNo(ItemJnlLine);  // P8000316A
                        if ProcessFns.WhseInstalled then // P8000543A, P8007118
                                                         // CombineLotsForm.AddFixedBinTracking(ItemJnlLine); // P8000495A, P8000888
                            CombineLots.AddFixedBinTracking(ItemJnlLine);        // P8000888
                        P8001DocWhseMgmt.Transfer1DocPickInfo(ItemJnlLine); // P8000631A
                        if ItemJnlLine."Phys. Inventory" and ProcessFns.TrackingInstalled then // PR3.61
                            while P800Tracking.ItemJnlLineSplitPhysical(ItemJnlLine) do          // PR3.61
                                PostItemJnlLine := ItemJnlPostLine.RunWithCheck(ItemJnlLine)       // PR3.61, P8001133, P8007748
                        else                                                                   // PR3.61
                            PostItemJnlLine := ItemJnlPostLine.RunWithCheck(ItemJnlLine);        // PR3.61, P8001133, P8007748
                        if not PostItemJnlLine then // P8007748
                            ItemJnlPostLine.CheckItemTracking;
                        if "Value Entry Type" <> "Value Entry Type"::Revaluation then begin
                            //ItemJnlPostLine.CollectTrackingSpecification(TempHandlingSpecification); // P8001083
                            OnPostLinesBeforePostWhseJnlLine(ItemJnlLine, SuppressCommit);
                            PostWhseJnlLine(                                     // P8000591A
                              ItemJnlPostLine, WhseJnlPostLine, RoundingAdjmtMgmt, // P8001083
                              ItemJnlLine, OriginalQuantity, OriginalQuantityBase, // P8000591A
                              OriginalQuantityAlt, TempTrackingSpecification);     // P8000591A, P8001083, P800-MegaApp
                            OnPostLinesOnAfterPostWhseJnlLine(ItemJnlLine, SuppressCommit);
                        end;
                        if ("Entry Type" = "Entry Type"::Transfer) and ("Alt. Qty. Transaction No." <> 0) then // P8000631A
                            AltQtyMgmt.DeleteItemJnlAltQtyLines(ItemJnlLine);                                    // P8000631A
                    end;

                OnPostLinesOnAfterPostLine(ItemJnlLine, SuppressCommit);

                if IsPhysInvtCount(ItemJnlTemplate, "Phys Invt Counting Period Code", "Phys Invt Counting Period Type") then begin
                    if not PhysInvtCount then begin
                        PhysInvtCountMgt.InitTempItemSKUList;
                        PhysInvtCount := true;
                    end;
                    PhysInvtCountMgt.AddToTempItemSKUList("Item No.", "Location Code", "Variant Code", "Phys Invt Counting Period Type");
                end;
            until Next() = 0;
        end;

        OnAfterPostLines(ItemJnlLine, ItemRegNo);
    end;

    local procedure HandleRecurringLine(var ItemJnlLine: Record "Item Journal Line")
    var
        ItemJnlLine2: Record "Item Journal Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeHandleRecurringLine(ItemJnlLine, IsHandled);
        if IsHandled then
            exit;

        LineCount := 0;
        ItemJnlLine2.CopyFilters(ItemJnlLine);
        ItemJnlLine2.FindSet();
        repeat
            OnHandleRecurringLineOnBeforeItemJnlLine2Loop(ItemJnlLine, ItemJnlLine2, WindowIsOpen);
            LineCount := LineCount + 1;
            if WindowIsOpen then begin
                Window.Update(5, LineCount);
                Window.Update(6, Round(LineCount / NoOfRecords * 10000, 1));
            end;
            if ItemJnlLine2."Posting Date" <> 0D then
                ItemJnlLine2.Validate("Posting Date", CalcDate(ItemJnlLine2."Recurring Frequency", ItemJnlLine2."Posting Date"));
            if (ItemJnlLine2."Recurring Method" = ItemJnlLine2."Recurring Method"::Variable) and
               (ItemJnlLine2."Item No." <> '')
            then begin
                ItemJnlLine2.Quantity := 0;
                ItemJnlLine2."Invoiced Quantity" := 0;
                ItemJnlLine2.Amount := 0;
            end;
            OnHandleRecurringLineOnBeforeItemJnlLineModify(ItemJnlLine2);
            ItemJnlLine2.Modify();
        until ItemJnlLine2.Next() = 0;
    end;

    local procedure HandleNonRecurringLine(var ItemJnlLine: Record "Item Journal Line"; OldEntryType: Enum "Item Ledger Entry Type")
    var
        ItemJnlLine2: Record "Item Journal Line";
        ItemJnlLine3: Record "Item Journal Line";
        IncrBatchName: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeHandleNonRecurringLine(ItemJnlLine, IsHandled);
        if IsHandled then
            exit;

        with ItemJnlLine do begin
            ItemJnlLine2.CopyFilters(ItemJnlLine);
            ItemJnlLine2.SetFilter("Item No.", '<>%1', '');
            if ItemJnlLine2.FindLast() then; // Remember the last line
            ItemJnlLine2."Entry Type" := OldEntryType;

            ItemJnlLine3.Copy(ItemJnlLine);
            OnHandleNonRecurringLineOnAfterCopyItemJnlLine3(ItemJnlLine, ItemJnlLine3);
            ItemJnlLine3.DeleteAll();
            ItemJnlLine3.Reset();
            ItemJnlLine3.SetRange("Journal Template Name", "Journal Template Name");
            ItemJnlLine3.SetRange("Journal Batch Name", "Journal Batch Name");
            if ItemJnlTemplate."Increment Batch Name" then
                if not ItemJnlLine3.FindLast() then begin
                    IncrBatchName := IncStr("Journal Batch Name") <> '';
                    OnBeforeIncrBatchName(ItemJnlLine, IncrBatchName);
                    if IncrBatchName then begin
                        ItemJnlBatch.Delete();
                        IsHandled := false;
                        OnHandleNonRecurringLineOnBeforeSetItemJnlBatchName(ItemJnlTemplate, IsHandled);
                        if not IsHandled then
                            ItemJnlBatch.Name := IncStr("Journal Batch Name");
                        if ItemJnlBatch.Insert() then;
                        "Journal Batch Name" := ItemJnlBatch.Name;
                    end;
                end;

            OnHandleNonRecurringLineOnInsertNewLine(ItemJnlLine3);

            ItemJnlLine3.SetRange("Journal Batch Name", "Journal Batch Name");
            if (ItemJnlBatch."No. Series" = '') and not ItemJnlLine3.FindLast and
               not (ItemJnlLine2."Entry Type" in [ItemJnlLine2."Entry Type"::Consumption, ItemJnlLine2."Entry Type"::Output])
            then begin
                ItemJnlLine3.Init();
                ItemJnlLine3."Journal Template Name" := "Journal Template Name";
                ItemJnlLine3."Journal Batch Name" := "Journal Batch Name";
                ItemJnlLine3."Line No." := 10000;
                ItemJnlLine3.Insert();
                ItemJnlLine3.SetUpNewLine(ItemJnlLine2);
                ItemJnlLine3.Modify();
                OnHandleNonRecurringLineOnAfterItemJnlLineModify(ItemJnlLine3);
            end;
        end;
    end;

    local procedure ConstructPostingNumber(var ItemJnlLine: Record "Item Journal Line")
    begin
        with ItemJnlLine do
            if "Posting No. Series" = '' then
                "Posting No. Series" := ItemJnlBatch."No. Series"
            else
                if not EmptyLine then
                    if "Document No." = LastDocNo then
                        "Document No." := LastPostedDocNo
                    else begin
                        if not NoSeries.Get("Posting No. Series") then begin
                            NoOfPostingNoSeries := NoOfPostingNoSeries + 1;
                            if NoOfPostingNoSeries > ArrayLen(NoSeriesMgt2) then
                                Error(
                                  Text006,
                                  ArrayLen(NoSeriesMgt2));
                            NoSeries.Code := "Posting No. Series";
                            NoSeries.Description := Format(NoOfPostingNoSeries);
                            NoSeries.Insert();
                        end;
                        LastDocNo := "Document No.";
                        Evaluate(PostingNoSeriesNo, NoSeries.Description);
                        "Document No." := NoSeriesMgt2[PostingNoSeriesNo].GetNextNo("Posting No. Series", "Posting Date", false);
                        LastPostedDocNo := "Document No.";
                    end;

        OnAfterConstructPostingNumber(ItemJnlLine);
    end;

    local procedure CheckRecurringLine(var ItemJnlLine2: Record "Item Journal Line")
    var
        NULDF: DateFormula;
    begin
        with ItemJnlLine2 do
            if "Item No." <> '' then
                if ItemJnlTemplate.Recurring then begin
                    TestField("Recurring Method");
                    TestField("Recurring Frequency");
                    if "Recurring Method" = "Recurring Method"::Variable then
                        TestField(Quantity);
                end else begin
                    Clear(NULDF);
                    TestField("Recurring Method", 0);
                    TestField("Recurring Frequency", NULDF);
                end;
    end;

    local procedure MakeRecurringTexts(var ItemJnlLine2: Record "Item Journal Line")
    begin
        with ItemJnlLine2 do
            if ("Item No." <> '') and ("Recurring Method" <> 0) then
                AccountingPeriod.MakeRecurringTexts("Posting Date", "Document No.", Description);
    end;

    local procedure ItemJnlPostSumLine(ItemJnlLine4: Record "Item Journal Line")
    var
        Item: Record Item;
        ItemLedgEntry4: Record "Item Ledger Entry";
        ItemLedgEntry5: Record "Item Ledger Entry";
        Remainder: Decimal;
        RemAmountToDistribute: Decimal;
        RemQuantity: Decimal;
        DistributeCosts: Boolean;
        IncludeExpectedCost: Boolean;
        PostingDate: Date;
        IsLastEntry: Boolean;
        RemQty: Decimal;
        RemAltQty: Decimal;
    begin
        DistributeCosts := true;
        RemAmountToDistribute := ItemJnlLine.Amount;
        RemQuantity := ItemJnlLine.GetCostingQty(ItemJnlLine.FieldNo(Quantity)); // P8000106A
        if ItemJnlLine.Amount <> 0 then begin
            LineCount := LineCount + 1;
            if WindowIsOpen then begin
                Window.Update(3, LineCount);
                Window.Update(4, Round(LineCount / NoOfRecords * 10000, 1));
            end;
            with ItemLedgEntry4 do begin
                Item.Get(ItemJnlLine4."Item No.");
                OnItemJnlPostSumLineOnAfterGetItem(Item, ItemJnlLine4);
                IncludeExpectedCost :=
                    (Item."Costing Method" = Item."Costing Method"::Standard) and
                    (ItemJnlLine4."Inventory Value Per" <> ItemJnlLine4."Inventory Value Per"::" ");
                Reset;
                SetCurrentKey("Item No.", Positive, "Location Code", "Variant Code");
                SetRange("Item No.", ItemJnlLine."Item No.");
                SetRange(Positive, true);
                PostingDate := ItemJnlLine."Posting Date";

                if (ItemJnlLine4."Location Code" <> '') or
                   (ItemJnlLine4."Inventory Value Per" in
                    [ItemJnlLine."Inventory Value Per"::Location,
                     ItemJnlLine4."Inventory Value Per"::"Location and Variant"])
                then
                    SetRange("Location Code", ItemJnlLine."Location Code");
                if (ItemJnlLine."Variant Code" <> '') or
                   (ItemJnlLine4."Inventory Value Per" in
                    [ItemJnlLine."Inventory Value Per"::Variant,
                     ItemJnlLine4."Inventory Value Per"::"Location and Variant"])
                then
                    SetRange("Variant Code", ItemJnlLine."Variant Code");
                if FindSet() then
                    repeat
                        OnItemJnlPostSumLineOnBeforeIncludeEntry(ItemJnlLine4, ItemLedgEntry4, IncludeExpectedCost);
                        if IncludeEntryInCalc(ItemLedgEntry4, PostingDate, IncludeExpectedCost) then begin
                            ItemLedgEntry5 := ItemLedgEntry4;

                            ItemJnlLine4."Entry Type" := "Entry Type";
                            CalculateRemQuantity("Entry No.", ItemJnlLine."Posting Date", RemQty, RemAltQty); // P8001302
                            ItemJnlLine4.Quantity :=
                              RemQty; // P8001302

                            // P8000106A Begin
                            if "Remaining Quantity (Alt.)" <> "Quantity (Alt.)" then
                                ItemJnlLine4."Quantity (Alt.)" := RemAltQty // P8001302
                            else
                                ItemJnlLine4."Quantity (Alt.)" := "Quantity (Alt.)";
                            // P8000106A End
                            ItemJnlLine4."Quantity (Base)" := ItemJnlLine4.Quantity;
                            ItemJnlLine4."Invoiced Quantity" := ItemJnlLine4.Quantity;
                            ItemJnlLine4."Invoiced Qty. (Base)" := ItemJnlLine4.Quantity;
                            ItemJnlLine4."Invoiced Qty. (Alt.)" := ItemJnlLine4."Quantity (Alt.)"; // P8000106A
                            ItemJnlLine4."Location Code" := "Location Code";
                            ItemJnlLine4."Variant Code" := "Variant Code";
                            ItemJnlLine4."Applies-to Entry" := "Entry No.";
                            ItemJnlLine4."Source No." := "Source No.";
                            ItemJnlLine4."Order Type" := "Order Type";
                            ItemJnlLine4."Order No." := "Order No.";
                            ItemJnlLine4."Order Line No." := "Order Line No.";

                            if ItemJnlLine4.GetCostingQty(ItemJnlLine4.FieldNo(Quantity)) <> 0 then begin // P8000106A
                                ItemJnlLine4.Amount :=
                                  ItemJnlLine."Inventory Value (Revalued)" * ItemJnlLine4.GetCostingQty(ItemJnlLine4.FieldNo(Quantity)) / // P8000106A
                                  ItemJnlLine.GetCostingQty(ItemJnlLine.FieldNo(Quantity)) -   // P8000106A
                                  Round(
                                    CalculateRemInventoryValue(
                                      "Entry No.", GetCostingQty, ItemJnlLine4.GetCostingQty(ItemJnlLine4.FieldNo(Quantity)), // P8000106A
                                      IncludeExpectedCost and not "Completely Invoiced", PostingDate),
                                    GLSetup."Amount Rounding Precision") + Remainder;

                                RemQuantity := RemQuantity - ItemJnlLine4.GetCostingQty(ItemJnlLine4.FieldNo(Quantity)); // P8000106A

                                if RemQuantity = 0 then begin
                                    if Next > 0 then
                                        repeat
                                            if IncludeEntryInCalc(ItemLedgEntry4, PostingDate, IncludeExpectedCost) then begin
                                                CalculateRemQuantity("Entry No.", ItemJnlLine."Posting Date", RemQty, RemAltQty); // P8001302
                                                if Item.CostInAlternateUnits then // P8000106A
                                                    RemQuantity := RemAltQty        // P8000106A, P8001302
                                                else                              // P8000106A
                                                    RemQuantity := RemQty; // P8001302
                                                if RemQuantity > 0 then
                                                    Error(Text008 + Text009, ItemJnlLine4."Item No.");
                                            end;
                                        until Next() = 0;

                                    ItemJnlLine4.Amount := RemAmountToDistribute;
                                    DistributeCosts := false;
                                end else begin
                                    repeat
                                        IsLastEntry := Next() = 0;
                                    until IncludeEntryInCalc(ItemLedgEntry4, PostingDate, IncludeExpectedCost) or IsLastEntry;
                                    if IsLastEntry or (RemQuantity < 0) then
                                        Error(Text008 + Text009, ItemJnlLine4."Item No.");
                                    Remainder := ItemJnlLine4.Amount - Round(ItemJnlLine4.Amount, GLSetup."Amount Rounding Precision");
                                    ItemJnlLine4.Amount := Round(ItemJnlLine4.Amount, GLSetup."Amount Rounding Precision");
                                    RemAmountToDistribute := RemAmountToDistribute - ItemJnlLine4.Amount;
                                end;
                                ItemJnlLine4."Unit Cost" :=                                                         // P8000106A
                                  ItemJnlLine4.Amount / ItemJnlLine4.GetCostingQty(ItemJnlLine4.FieldNo(Quantity)); // P8000106A

                                OnItemJnlPostSumLineOnBeforeCalcAppliedAmount(ItemJnlLine4, ItemLedgEntry4);
                                if ItemJnlLine4.Amount <> 0 then begin
                                    if IncludeExpectedCost and not ItemLedgEntry5."Completely Invoiced" then begin
                                        ItemJnlLine4."Applied Amount" := Round(
                                            ItemJnlLine4.Amount * (ItemLedgEntry5.Quantity - ItemLedgEntry5."Invoiced Quantity") /
                                            ItemLedgEntry5.Quantity,
                                            GLSetup."Amount Rounding Precision");
                                    end else
                                        ItemJnlLine4."Applied Amount" := 0;
                                    OnBeforeItemJnlPostSumLine(ItemJnlLine4, ItemLedgEntry4);
                                    ItemJnlPostLine.RunWithCheck(ItemJnlLine4);
                                end;
                            end else begin
                                repeat
                                    IsLastEntry := Next() = 0;
                                until IncludeEntryInCalc(ItemLedgEntry4, PostingDate, IncludeExpectedCost) or IsLastEntry;
                                if IsLastEntry then
                                    Error(Text008 + Text009, ItemJnlLine4."Item No.");
                            end;
                        end else
                            DistributeCosts := Next <> 0;
                    until not DistributeCosts;
            end;

            if ItemJnlLine."Update Standard Cost" then
                UpdateStdCost;
        end;

        OnAfterItemJnlPostSumLine(ItemJnlLine);
    end;

    local procedure IncludeEntryInCalc(ItemLedgEntry: Record "Item Ledger Entry"; PostingDate: Date; IncludeExpectedCost: Boolean): Boolean
    begin
        with ItemLedgEntry do begin
            if IncludeExpectedCost then
                exit("Posting Date" in [0D .. PostingDate]);
            exit("Completely Invoiced" and ("Last Invoice Date" in [0D .. PostingDate]));
        end;
    end;

    local procedure UpdateStdCost()
    var
        SKU: Record "Stockkeeping Unit";
        InventorySetup: Record "Inventory Setup";
    begin
        with ItemJnlLine do begin
            InventorySetup.Get();
            if InventorySetup."Average Cost Calc. Type" = InventorySetup."Average Cost Calc. Type"::Item then
                UpdateItemStdCost
            else
                if SKU.Get("Location Code", "Item No.", "Variant Code") then begin
                    SKU.Validate("Standard Cost", "Unit Cost (Revalued)");
                    // P8001030
                    SKU."Single-Level Material Cost" := "Single-Level Material Cost";
                    SKU."Single-Level Capacity Cost" := "Single-Level Capacity Cost";
                    SKU."Single-Level Subcontrd. Cost" := "Single-Level Subcontrd. Cost";
                    SKU."Single-Level Cap. Ovhd Cost" := "Single-Level Cap. Ovhd Cost";
                    SKU."Single-Level Mfg. Ovhd Cost" := "Single-Level Mfg. Ovhd Cost";
                    SKU."Rolled-up Material Cost" := "Rolled-up Material Cost";
                    SKU."Rolled-up Capacity Cost" := "Rolled-up Capacity Cost";
                    SKU."Rolled-up Subcontracted Cost" := "Rolled-up Subcontracted Cost";
                    SKU."Rolled-up Mfg. Ovhd Cost" := "Rolled-up Mfg. Ovhd Cost";
                    SKU."Rolled-up Cap. Overhead Cost" := "Rolled-up Cap. Overhead Cost";
                    SKU."Last Unit Cost Calc. Date" := "Posting Date";
                    // P8001030
                    SKU.Modify();
                end else
                    UpdateItemStdCost;
        end;
    end;

    local procedure UpdateItemStdCost()
    var
        Item: Record Item;
    begin
        with ItemJnlLine do begin
            Item.Get("Item No.");
            Item.Validate("Standard Cost", "Unit Cost (Revalued)");
            SetItemSingleLevelCosts(Item, ItemJnlLine);
            SetItemRolledUpCosts(Item, ItemJnlLine);
            Item."Last Unit Cost Calc. Date" := "Posting Date";
            Item.Modify();
        end;
    end;

    local procedure CheckRemainingQty()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        RemainingQty: Decimal;
        RemQty: Decimal;
        RemAltQty: Decimal;
    begin
        ItemLedgerEntry.CalculateRemQuantity(ItemJnlLine."Applies-to Entry", ItemJnlLine."Posting Date", RemQty, RemAltQty); // P8001302
        if ItemJnlLine.CostInAlternateUnits then                                                                          // P8001302
            RemainingQty := RemAltQty                                                                                       // P8001302
        else                                                                                                              // P8001302
            RemainingQty := RemQty;                                                                                         // P8001302

        if RemainingQty <> ItemJnlLine.GetCostingQty(ItemJnlLine.FieldNo(Quantity)) then // P8000106A
            Error(Text008 + Text009, ItemJnlLine."Item No.");
    end;

    procedure PostWhseJnlLine(ItemJnlLine: Record "Item Journal Line"; OriginalQuantity: Decimal; OriginalQuantityBase: Decimal; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    var
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line";
        RoundingAdjmtMgmt: Codeunit "Rounding Adjustment Mgmt.";
    begin
        // P80096141 - Original signature
        PostWhseJnlLine(ItemJnlPostLine,WhseJnlPostLine, RoundingAdjmtMgmt, ItemJnlLine, OriginalQuantity, OriginalQuantityBase, 0, TempTrackingSpecification);
    end;

    procedure PostWhseJnlLine(var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line"; var RoundingAdjmtMgmt: Codeunit "Rounding Adjustment Mgmt."; ItemJnlLine: Record "Item Journal Line"; OriginalQuantity: Decimal; OriginalQuantityBase: Decimal; OriginalQuantityAlt: Decimal; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    var
        TempHandlingSpecification: Record "Tracking Specification" temporary;
	Item: Record Item;
        ItemJnlTemplateType: Option;
        IsHandled: Boolean;
    begin
        // P8000591A - add parameter OriginalQuantityAlt
        // P8001083 - parameters added for ItemJnlPostLine, WhseJnlPostLine, RoundingAdjmtMgmt, ItemJnlTemplate
        // P8001083 - parameter removed for TempHandlingSpecification)
        if Item.Get(ItemJnlLine."Item No.") then
            if Item.IsNonInventoriableType() then
                exit;
		
        ItemJnlPostLine.CollectTrackingSpecification(TempHandlingSpecification); // P8001083
        with ItemJnlLine do begin
            Quantity := OriginalQuantity;
            "Quantity (Base)" := OriginalQuantityBase;
            "Quantity (Alt.)" := OriginalQuantityAlt; // P8000591A
            GetLocation("Location Code");
            ItemJnlTemplateType := ItemJnlTemplate.Type.AsInteger();
            IsHandled := false;
            OnPostWhseJnlLineOnBeforeCreateWhseJnlLines(ItemJnlLine, ItemJnlTemplateType, IsHandled);
            if IsHandled then
                exit;
            if not ("Entry Type" in ["Entry Type"::Consumption, "Entry Type"::Output]) then
                PostWhseJnlLines(ItemJnlPostLine, WhseJnlPostLine, RoundingAdjmtMgmt, ItemJnlLine, TempHandlingSpecification, "Item Journal Template Type".FromInteger(ItemJnlTemplateType), false); // P800-MegaApp

            if "Entry Type" = "Entry Type"::Transfer then begin
                GetLocation("New Location Code");
                PostWhseJnlLines(ItemJnlPostLine, WhseJnlPostLine, RoundingAdjmtMgmt, ItemJnlLine, TempHandlingSpecification, "Item Journal Template Type".FromInteger(ItemJnlTemplateType), true); // P800-MegaApp
            end;
        end;
    end;

    local procedure PostWhseJnlLines(var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line"; var RoundingAdjmtMgmt: Codeunit "Rounding Adjustment Mgmt."; ItemJnlLine: Record "Item Journal Line"; var TempTrackingSpecification: Record "Tracking Specification" temporary; ItemJnlTemplateType: Enum "Item Journal Template Type"; ToTransfer: Boolean)
    var
        WhseJnlLine: Record "Warehouse Journal Line";
        TempWhseJnlLine: Record "Warehouse Journal Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WhseMgt: Codeunit "Whse. Management";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostWhseJnlLines(ItemJnlLine, TempTrackingSpecification, ItemJnlTemplateType, ToTransfer, IsHandled);
        if IsHandled then
            exit;

        with ItemJnlLine do
            if Location."Bin Mandatory" then
                if WMSMgmt.CreateWhseJnlLine(ItemJnlLine, ItemJnlTemplateType.AsInteger(), WhseJnlLine, ToTransfer) then begin
                    // P8001083
                    WhseJnlLine."Source Type" := DATABASE::"Item Journal Line";
                    WhseJnlLine."Source Subtype" := ItemJnlTemplateType;
                    WhseJnlLine."Source Document" := WhseMgt.GetSourceDocumentType(WhseJnlLine."Source Type", WhseJnlLine."Source Subtype");  // P8001132
                    WhseJnlLine."Source No." := "Document No.";
                    WhseJnlLine."Source Line No." := "Line No.";
                    // P8001083
                    XferRegsToWhse(ItemJnlPostLine, WhseJnlPostLine); // P8000958, P8001083
                    XferWhseRoundingAdjmts(ItemJnlPostLine, WhseJnlPostLine, RoundingAdjmtMgmt); // P8001039, P8001083
                    ItemTrackingMgt.SplitWhseJnlLine(WhseJnlLine, TempWhseJnlLine, TempTrackingSpecification, ToTransfer);
                    if TempWhseJnlLine.FindSet() then
                        repeat
                            WMSMgmt.CheckWhseJnlLine(TempWhseJnlLine, 1, 0, ToTransfer);
                            IsHandled := false;
                            OnBeforeWhseJnlPostLineRun(ItemJnlLine, TempWhseJnlLine, IsHandled);
                            if not IsHandled then
                                WhseJnlPostLine.Run(TempWhseJnlLine);
                            PostWhseAltQtyAdjmt(WhseJnlPostLine, TempWhseJnlLine, // P8000591A, P8001083
                                Location."Directed Put-away and Pick", Location."Adjustment Bin Code"); // P8001083
                        until TempWhseJnlLine.Next() = 0;
                    PostWhseRoundingAdjmts(WhseJnlPostLine, RoundingAdjmtMgmt); // P8001039, P8001083
                    XferRegsFromWhse(ItemJnlPostLine, WhseJnlPostLine); // P8000958, P8001083
                    OnAfterPostWhseJnlLine(ItemJnlLine, SuppressCommit);
                end;
    end;

    local procedure CheckWMSBin(ItemJnlLine: Record "Item Journal Line")
    var
        Item: Record Item;
    begin
        if Item.Get(ItemJnlLine."Item No.") then
            if Item.IsNonInventoriableType() then
                exit;

        with ItemJnlLine do begin
            GetLocation("Location Code");
            if Location."Bin Mandatory" then
                WhseTransaction := true;
            case "Entry Type" of
                "Entry Type"::Purchase, "Entry Type"::Sale,
                "Entry Type"::"Positive Adjmt.", "Entry Type"::"Negative Adjmt.":
                    begin
                        if Location."Directed Put-away and Pick" then
                            WMSMgmt.CheckAdjmtBin(
                              Location, Quantity,
                              ("Entry Type" in
                               ["Entry Type"::Purchase,
                                "Entry Type"::"Positive Adjmt."]));
                    end;
                "Entry Type"::Transfer:
                    begin
                        if Location."Directed Put-away and Pick" then
                            WMSMgmt.CheckAdjmtBin(Location, -Quantity, false);
                        GetLocation("New Location Code");
                        if Location."Directed Put-away and Pick" then
                            WMSMgmt.CheckAdjmtBin(Location, Quantity, true);
                        if Location."Bin Mandatory" then
                            WhseTransaction := true;
                    end;
            end;
        end;
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Clear(Location)
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);

        OnAfterGetLocation(Location, ItemJnlLine);
    end;

    procedure GetWhseRegNo(): Integer
    begin
        exit(WhseRegNo);
    end;

    procedure GetItemRegNo(): Integer
    begin
        exit(ItemRegNo);
    end;

    local procedure IsPhysInvtCount(ItemJnlTemplate2: Record "Item Journal Template"; PhysInvtCountingPeriodCode: Code[10]; PhysInvtCountingPeriodType: Option " ",Item,SKU): Boolean
    begin
        exit(
          (ItemJnlTemplate2.Type = ItemJnlTemplate2.Type::"Phys. Inventory") and
          (PhysInvtCountingPeriodType <> PhysInvtCountingPeriodType::" ") and
          (PhysInvtCountingPeriodCode <> ''));
    end;

    local procedure CheckItemAvailability(var ItemJnlLine: Record "Item Journal Line")
    var
        Item: Record Item;
        TempSKU: Record "Stockkeeping Unit" temporary;
        ItemJnlLine2: Record "Item Journal Line";
        ConfirmManagement: Codeunit "Confirm Management";
        QtyinItemJnlLine: Decimal;
        AvailableQty: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckItemAvailabilityHandled(ItemJnlLine, IsHandled);
        if IsHandled then
            exit;

        ItemJnlLine2.CopyFilters(ItemJnlLine);
        if ItemJnlLine2.FindSet() then
            repeat
                if ItemJnlLine2.IsNotInternalWhseMovement() then
                    if not TempSKU.Get(ItemJnlLine2."Location Code", ItemJnlLine2."Item No.", ItemJnlLine2."Variant Code") then
                        InsertTempSKU(TempSKU, ItemJnlLine2);
                OnBeforeCheckItemAvailability(ItemJnlLine2, TempSKU);
            until ItemJnlLine2.Next() = 0;

        if TempSKU.FindSet() then
            repeat
                QtyinItemJnlLine := CalcRequiredQty(TempSKU, ItemJnlLine2);
                if QtyinItemJnlLine < 0 then begin
                    Item.Get(TempSKU."Item No.");
                    Item.SetFilter("Location Filter", TempSKU."Location Code");
                    Item.SetFilter("Variant Filter", TempSKU."Variant Code");
                    Item.CalcFields("Reserved Qty. on Inventory", "Net Change");
                    AvailableQty := Item."Net Change" - Item."Reserved Qty. on Inventory" + SelfReservedQty(TempSKU, ItemJnlLine2);

                    if (Item."Reserved Qty. on Inventory" > 0) and (AvailableQty < Abs(QtyinItemJnlLine)) then
                        if not ConfirmManagement.GetResponseOrDefault(
                            StrSubstNo(
                                Text010, TempSKU.FieldCaption("Item No."), TempSKU."Item No.", TempSKU.FieldCaption("Location Code"),
                                TempSKU."Location Code", TempSKU.FieldCaption("Variant Code"), TempSKU."Variant Code"), true)
                        then
                            Error('');
                end;
            until TempSKU.Next() = 0;
    end;

    local procedure InsertTempSKU(var TempSKU: Record "Stockkeeping Unit" temporary; ItemJnlLine: Record "Item Journal Line")
    begin
        with TempSKU do begin
            Init;
            "Location Code" := ItemJnlLine."Location Code";
            "Item No." := ItemJnlLine."Item No.";
            "Variant Code" := ItemJnlLine."Variant Code";
            OnBeforeInsertTempSKU(TempSKU, ItemJnlLine);
            Insert;
        end;
    end;

    local procedure CalcRequiredQty(TempSKU: Record "Stockkeeping Unit" temporary; var ItemJnlLine: Record "Item Journal Line"): Decimal
    var
        SignFactor: Integer;
        QtyinItemJnlLine: Decimal;
    begin
        QtyinItemJnlLine := 0;
        ItemJnlLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Item No.", "Location Code", "Variant Code");
        ItemJnlLine.SetRange("Item No.", TempSKU."Item No.");
        ItemJnlLine.SetRange("Location Code", TempSKU."Location Code");
        ItemJnlLine.SetRange("Variant Code", TempSKU."Variant Code");
        ItemJnlLine.FindSet();
        repeat
            if (ItemJnlLine."Entry Type" in
                [ItemJnlLine."Entry Type"::Sale,
                 ItemJnlLine."Entry Type"::"Negative Adjmt.",
                 ItemJnlLine."Entry Type"::Consumption]) or
               (ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::Transfer)
            then
                SignFactor := -1
            else
                SignFactor := 1;
            QtyinItemJnlLine += ItemJnlLine."Quantity (Base)" * SignFactor;
        until ItemJnlLine.Next() = 0;
        exit(QtyinItemJnlLine);
    end;

    local procedure SelfReservedQty(SKU: Record "Stockkeeping Unit"; ItemJnlLine: Record "Item Journal Line") Result: Decimal
    var
        ReservationEntry: Record "Reservation Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSelfReservedQty(SKU, ItemJnlLine, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if ItemJnlLine."Order Type" <> ItemJnlLine."Order Type"::Production then
            exit;

        with ReservationEntry do begin
            SetRange("Item No.", SKU."Item No.");
            SetRange("Location Code", SKU."Location Code");
            SetRange("Variant Code", SKU."Variant Code");
            SetRange("Source Type", DATABASE::"Prod. Order Component");
            SetRange("Source ID", ItemJnlLine."Order No.");
            if IsEmpty() then
                exit;
            CalcSums("Quantity (Base)");
            exit(-"Quantity (Base)");
        end;
    end;

    procedure SaveOutputLotNo(ItemJnlLine: Record "Item Journal Line")
    begin
        // P8000316A
        if ItemJnlLine."Entry Type" <> ItemJnlLine."Entry Type"::Output then
            exit;
        if (ItemJnlLine."Lot No." = '') or (ItemJnlLine."Lot No." = P800Globals.MultipleLotCode) then
            exit;

        if OutputLotNo.Get(0, ItemJnlLine."Order No.", ItemJnlLine."Order Line No.") then // P8001132
            exit;

        OutputLotNo."Prod. Order No." := ItemJnlLine."Order No."; // P8001132
        OutputLotNo."Line No." := ItemJnlLine."Order Line No.";   // P8001132
        OutputLotNo."Lot No." := ItemJnlLine."Lot No.";
        OutputLotNo.Insert;
    end;

    procedure UseOutputLotNo(var ItemJnlLine: Record "Item Journal Line")
    var
        ProdOrderNo: Code[20];
        ProdOrderLineNo: Integer;
    begin
        // P8000316A
        if not ItemJnlLine.ConsumedIntermediate(ProdOrderNo, ProdOrderLineNo) then
            exit;

        if ItemJnlLine."Lot No." <> '' then
            exit;

        if OutputLotNo.Get(0, ProdOrderNo, ProdOrderLineNo) then begin
            ItemJnlLine."Lot No." := OutputLotNo."Lot No.";
            ItemJnlLine.UpdateLotTracking(true);
        end;
    end;

    local procedure PostWhseAltQtyAdjmt(var WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line"; var TempWhseJnlLine2: Record "Warehouse Journal Line" temporary; Directed: Boolean; AdjBin: Code[20])
    var
        TempWhseJnlLine: Record "Warehouse Journal Line";
        Item: Record Item;
        ItemLedgEntry: Record "Item Ledger Entry";
        WhseEntry: Record "Warehouse Entry";
    begin
        // P8000591A
        // P8001083 - parameters added for WhseJnlPostLine, Directed, AdjBin
        //IF NOT Location."Directed Put-away and Pick" THEN // P8001083
        if not Directed then                                // P8001083
            exit;

        TempWhseJnlLine := TempWhseJnlLine2;
        with TempWhseJnlLine do begin
            Item.Get("Item No.");
            if not Item.TrackAlternateUnits() then
                exit;

            ItemLedgEntry.SetCurrentKey(
              "Item No.", "Variant Code", "Location Code", "Lot No.", "Serial No.", "Posting Date");
            ItemLedgEntry.SetRange("Item No.", "Item No.");
            ItemLedgEntry.SetRange("Variant Code", "Variant Code");
            ItemLedgEntry.SetRange("Location Code", "Location Code");
            ItemLedgEntry.SetRange("Lot No.", "Lot No.");
            ItemLedgEntry.SetRange("Serial No.", "Serial No.");
            ItemLedgEntry.CalcSums(Quantity);
            if (ItemLedgEntry.Quantity <> 0) then
                exit;
            ItemLedgEntry.CalcSums("Quantity (Alt.)");
            if (ItemLedgEntry."Quantity (Alt.)" <> 0) then
                exit;

            WhseEntry.SetCurrentKey(
              "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code",
              "Lot No.", "Serial No.", "Entry Type");
            WhseEntry.SetRange("Item No.", "Item No.");
            //WhseEntry.SETRANGE("Bin Code", Location."Adjustment Bin Code"); // P8001083
            WhseEntry.SetRange("Bin Code", AdjBin);                           // P8001083
            WhseEntry.SetRange("Location Code", "Location Code");
            WhseEntry.SetRange("Variant Code", "Variant Code");
            WhseEntry.SetRange("Lot No.", "Lot No.");
            WhseEntry.SetRange("Serial No.", "Serial No.");
            WhseEntry.CalcSums("Qty. (Base)");
            if (WhseEntry."Qty. (Base)" <> 0) then
                exit;
            WhseEntry.CalcSums("Quantity (Alt.)");
            if (WhseEntry."Quantity (Alt.)" = 0) then
                exit;

            Quantity := 0;
            "Qty. (Base)" := 0;
            "Qty. (Absolute)" := 0;
            "Qty. (Absolute, Base)" := 0;
            "Quantity (Alt.)" := -WhseEntry."Quantity (Alt.)";
            "Quantity (Absolute, Alt.)" := Abs("Quantity (Alt.)");
            if ("Quantity (Alt.)" < 0) then
                "Entry Type" := "Entry Type"::"Negative Adjmt."
            else
                "Entry Type" := "Entry Type"::"Positive Adjmt.";
            if ("Entry Type" <> TempWhseJnlLine2."Entry Type") then begin
                "To Zone Code" := TempWhseJnlLine2."From Zone Code";
                "To Bin Code" := TempWhseJnlLine2."From Bin Code";
                "From Zone Code" := TempWhseJnlLine2."To Zone Code";
                "From Bin Code" := TempWhseJnlLine2."To Bin Code";
            end;

            WhseJnlPostLine.Run(TempWhseJnlLine);
        end;
    end;

    local procedure XferRegsToWhse(var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line")
    var
        ItemReg2: Record "Item Register";
        ItemApplnEntryNo2: Integer;
        WhseReg2: Record "Warehouse Register";
        GLReg2: Record "G/L Register";
        NextVATEntryNo2: Integer;
        NextTransactionNo2: Integer;
    begin
        // P8000958
        // P8001083 - parameters added for ItemJnlPostLine, WhseJnlPostLine
        ItemJnlPostLine.GetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2, WhseJnlPostLine);  //P80045166
        WhseJnlPostLine.SetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
    end;

    local procedure XferRegsFromWhse(var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line")
    var
        ItemReg2: Record "Item Register";
        ItemApplnEntryNo2: Integer;
        WhseReg2: Record "Warehouse Register";
        GLReg2: Record "G/L Register";
        NextVATEntryNo2: Integer;
        NextTransactionNo2: Integer;
    begin
        // P8000958
        // P8001083 - parameters added for ItemJnlPostLine, WhseJnlPostLine
        WhseJnlPostLine.GetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
        ItemJnlPostLine.SetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
    end;

    local procedure XferWhseRoundingAdjmts(var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line"; var RoundingAdjmtMgmt: Codeunit "Rounding Adjustment Mgmt.")
    var
        TempWhseAdjmtLine: Record "Warehouse Journal Line" temporary;
    begin
        // P8001039
        // P8001083 - parameters added for ItemJnlPostLine, WhseJnlPostLine, RoundingAdjmtMgmt
        OnBeforeXferWhseRoundingAdjmts(ItemJnlLine, ItemJnlPostLine, WhseJnlPostLine, RoundingAdjmtMgmt); // P80082969
        if ItemJnlPostLine.GetWhseRoundingAdjmts(TempWhseAdjmtLine) then begin
            ItemJnlPostLine.ClearWhseRoundingAdjmts;
            RoundingAdjmtMgmt.SetWhseAdjmts(TempWhseAdjmtLine);
            WhseJnlPostLine.SetWhseRoundingAdjmts(TempWhseAdjmtLine);
        end;
        OnAfterXferWhseRoundingAdjmts(ItemJnlLine, ItemJnlPostLine, WhseJnlPostLine, RoundingAdjmtMgmt); // P80082969al
    end;

    local procedure PostWhseRoundingAdjmts(var WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line"; var RoundingAdjmtMgmt: Codeunit "Rounding Adjustment Mgmt.")
    var
        WhseJnlLine: Record "Warehouse Journal Line";
    begin
        // P8001039
        // P8001083 - parameters added for WhseJnlPostLine, RoundingAdjmtMgmt
        if RoundingAdjmtMgmt.WhseAdjmtsToPost() then begin
            WhseJnlPostLine.ClearWhseRoundingAdjmts;
            repeat
                RoundingAdjmtMgmt.BuildWhseAdjmtJnlLine(WhseJnlLine);
                WhseJnlPostLine.Run(WhseJnlLine);
            until (not RoundingAdjmtMgmt.WhseAdjmtsToPost());
        end;
    end;

    local procedure SetItemSingleLevelCosts(var Item: Record Item; ItemJournalLine: Record "Item Journal Line")
    begin
        with ItemJournalLine do begin
            Item."Single-Level Material Cost" := "Single-Level Material Cost";
            Item."Single-Level Capacity Cost" := "Single-Level Capacity Cost";
            Item."Single-Level Subcontrd. Cost" := "Single-Level Subcontrd. Cost";
            Item."Single-Level Cap. Ovhd Cost" := "Single-Level Cap. Ovhd Cost";
            Item."Single-Level Mfg. Ovhd Cost" := "Single-Level Mfg. Ovhd Cost";
        end;
    end;

    local procedure SetItemRolledUpCosts(var Item: Record Item; ItemJournalLine: Record "Item Journal Line")
    begin
        with ItemJournalLine do begin
            Item."Rolled-up Material Cost" := "Rolled-up Material Cost";
            Item."Rolled-up Capacity Cost" := "Rolled-up Capacity Cost";
            Item."Rolled-up Subcontracted Cost" := "Rolled-up Subcontracted Cost";
            Item."Rolled-up Mfg. Ovhd Cost" := "Rolled-up Mfg. Ovhd Cost";
            Item."Rolled-up Cap. Overhead Cost" := "Rolled-up Cap. Overhead Cost";
        end;
    end;

    procedure SetSuppressCommit(NewSuppressCommit: Boolean)
    begin
        SuppressCommit := NewSuppressCommit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckLines(var ItemJnlLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckJnlLine(var ItemJournalLine: Record "Item Journal Line"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterConstructPostingNumber(var ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyRegNos(var ItemJournalLine: Record "Item Journal Line"; var ItemRegNo: Integer; var WhseRegNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetLocation(var Location: Record Location; var ItemJnlLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterItemJnlPostSumLine(var ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostLines(var ItemJournalLine: Record "Item Journal Line"; var ItemRegNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostJnlLines(var ItemJournalBatch: Record "Item Journal Batch"; var ItemJournalLine: Record "Item Journal Line"; ItemRegNo: Integer; WhseRegNo: Integer; var WindowIsOpen: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostWhseJnlLine(ItemJournalLine: Record "Item Journal Line"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterUpdateAnalysisViews(var ItemRegister: Record "Item Register")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCode(var ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckItemAvailability(var ItemJournalLine: Record "Item Journal Line"; var StockkeepingUnit: Record "Stockkeeping Unit")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckItemAvailabilityHandled(var ItemJournalLine: Record "Item Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckLines(var ItemJnlLine: Record "Item Journal Line"; var WindowIsOpen: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenProgressDialog(var ItemJnlLine: Record "Item Journal Line"; var Window: Dialog; var WindowIsOpen: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostWhseJnlLines(ItemJnlLine: Record "Item Journal Line"; var TempTrackingSpecification: Record "Tracking Specification" temporary; ItemJnlTemplateType: Enum "Item Journal Template Type"; ToTransfer: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRaiseExceedLengthError(var ItemJournalBatch: Record "Item Journal Batch"; var RaiseError: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWhseJnlPostLineRun(ItemJournalLine: Record "Item Journal Line"; var TempWarehouseJournalLine: Record "Warehouse Journal Line" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostLinesOnAfterPostWhseJnlLine(var ItemJournalLine: Record "Item Journal Line"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostLinesBeforePostWhseJnlLine(var ItemJournalLine: Record "Item Journal Line"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHandleNonRecurringLine(var ItemJournalLine: Record "Item Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHandleRecurringLine(var ItemJournalLine: Record "Item Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIncrBatchName(var ItemJournalLine: Record "Item Journal Line"; var IncrBatchName: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeItemJnlPostSumLine(var ItemJournalLine: Record "Item Journal Line"; ItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateDeleteLines(var ItemJournalLine: Record "Item Journal Line"; ItemRegNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforePostLines(var ItemJournalLine: Record "Item Journal Line"; var NoOfRecords: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleNonRecurringLineOnInsertNewLine(var ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnItemJnlPostSumLineOnAfterGetItem(var Item: Record Item; ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnItemJnlPostSumLineOnBeforeIncludeEntry(var ItemJournalLine: Record "Item Journal Line"; ItemLedgEntry: Record "Item Ledger Entry"; var IncludeExpectedCost: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnItemJnlPostSumLineOnBeforeCalcAppliedAmount(var ItemJournalLine: Record "Item Journal Line"; ItemLedgEntry: Record "Item Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostLinesOnAfterPostLine(var ItemJournalLine: Record "Item Journal Line"; var SuppressCommit: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostLinesOnBeforePostLine(var ItemJournalLine: Record "Item Journal Line"; var SuppressCommit: Boolean; var WindowIsOpen: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostWhseJnlLineOnBeforeCreateWhseJnlLines(ItemJournalLine: Record "Item Journal Line"; var ItemJnlTemplateType: Option; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeXferWhseRoundingAdjmts(var ItemJournalLine: Record "Item Journal Line"; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var WhseJnlRegisterLine: Codeunit "Whse. Jnl.-Register Line"; var RoundingAdjustmentMgmt: Codeunit "Rounding Adjustment Mgmt.")
    begin
        // P80082969
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterXferWhseRoundingAdjmts(var ItemJournalLine: Record "Item Journal Line"; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var WhseJnlRegisterLine: Codeunit "Whse. Jnl.-Register Line"; var RoundingAdjustmentMgmt: Codeunit "Rounding Adjustment Mgmt.")
    begin
        // P80082969
    end;

    local procedure OnHandleRecurringLineOnBeforeItemJnlLineModify(var ItemJournalLine: Record "Item Journal Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleRecurringLineOnBeforeItemJnlLine2Loop(var ItemJnlLine: Record "Item Journal Line"; var ItemJnlLine2: Record "Item Journal Line"; var WindowIsOpen: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertTempSKU(var TempStockkeepingUnit: Record "Stockkeeping Unit" temporary; ItemJournalLine: Record "Item Journal Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleNonRecurringLineOnAfterItemJnlLineModify(var ItemJournalLine: Record "Item Journal Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSelfReservedQty(SKU: Record "Stockkeeping Unit"; ItemJnlLine: Record "Item Journal Line"; var Result: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleNonRecurringLineOnBeforeSetItemJnlBatchName(ItemJnlTemplate: Record "Item Journal Template"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleNonRecurringLineOnAfterCopyItemJnlLine3(var ItemJournalLine: Record "Item Journal Line"; var ItemJournalLine3: Record "Item Journal Line")
    begin
    end;
}

