codeunit 5895 "Inventory Adjustment" implements "Inventory Adjustment"
{
    // PR2.00
    //   Update sales document Cost is Adjusted flags
    // 
    // PR3.60
    //   Add logic for alternate quantities
    //   Relocate call to UpdateSalesDocFalg to Item Journal posting codeunit (22)
    // 
    // PR3.60.01
    //   Fix call to CoProducts Management codeunit
    // 
    // PR3.70.01
    //   UpdateBOMProductCost - allow "output" entry to come last
    // 
    // PR3.70.06
    // P8000109A, Myers Nissi, Jack Reynolds, 08 SEP 04
    //    AdjustAppliedFromEntries - set AppliedQty and ShippedNotAppliedQty based on costing quantity
    // 
    // PR3.70.07
    // P8000127A, Myers Nissi, Jack Reynolds, 08 OCT 04
    //   DistrMfgCost - use costing quantity when calculating share of total cost
    // 
    // PR3.70.08
    // P8000167A, Myers Nissi, Jack Reynolds, 14 JAN 05
    //   CalcAdjustedCost - initialize NewAdjustedCost to zero
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   This codeunit has been significantly restructured, changes have been made to bring the P800 modifications
    //     into line with this restructuring
    // 
    // PR4.00.02
    // P8000304A, VerticalSoft, Jack Reynolds, 24 FEB 06
    //   Fix divide by zero error in CalcCostPerUnit
    // 
    // PR4.00.03
    // P8000325A, VerticalSoft, Jack Reynolds, 01 MAY 06
    //   AdjustAppliedOutboundEntries - modifiy SP2 changes for alternate quantities
    // 
    // P8000338A, VerticalSoft, Jack Reynolds, 12 MAY 06
    //   ExpCostIsCompletelyInvoiced - fix incorrect implementation of alternate quantites
    // 
    // PR4.00.05
    // P8000441A, VerticalSoft, Jack Reynolds, 05 FEB 07
    //   Fix problem with posting zero actual cost for output with no consumption cost
    // 
    // P8000413A, VerticalSoft, Jack Reynolds, 02 APR 07
    //   UpdateBOMProductCost - this had been changed for repack to handle components before BOM's in the BOM ledger
    //   the repack posting has been changed so that BOM's now come before components and so this code has reverted
    //   to standard
    // 
    // PR4.00.06
    // P8000486A, VerticalSoft, Jack Reynolds, 07 JUN 07
    //   Fix problem with output cost scaled by quantity per
    // 
    // PR5.00
    // P8000498A, VerticalSoft, Jack Reynolds, 27 JUL 07
    //   Restore support for adjusting cost of positive adjustments linked to BOM Ledger entries
    // 
    // P8000504A, VerticalSoft, Jack Reynolds, 10 AUG 07
    //   Support for alternate quantities when adjusting BOM journal output
    // 
    // PRW15.00.01
    // P8000524A, VerticalSoft, Jack Reynolds, 19 SEP 07
    //   Fix problem with rounding value entries for items costed by alternate quantity
    // 
    // P8000598A, VerticalSoft, Jack Reynolds, 26 APR 08
    //   Fix problem with extra zero value rounding entries for output entries
    // 
    // P8000599A, VerticalSoft, Don Bresee, 28 MAY 08
    //   Change IDs for BOM routines
    // 
    // PRW16.00.02
    // P8000756, VerticalSoft, Jack Reynolds, 13 JAN 10
    //   Incorporate P800 mods into NAV 2009 SP1
    // 
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 24 AUG 10
    //   Add Commodity Class Costing granule
    // 
    // P8000870, VerticalSoft, Don Bresee, 21 SEP 10
    //   Use item filter for by-products
    // 
    // PRW16.00.05
    // P8000928, Columbus IT, Jack Reynolds, 06 APR 11
    //   Support for extra charges on transfer orders
    // 
    // PRW17.00
    // P8001134, Columbus IT, Don Bresee, 21 FEB 13
    //   Add logic for handling of new "Order Type" options
    // 
    // PRW17.00.01
    // P8001227, Columbus IT, Don Bresee, 03 OCT 13
    //   Add logic to commit changes periodically
    //   Change handling of "Applied Entry to Adjust" field
    // 
    // PRW17.10.01
    // P8001260, Columbus IT, Jack Reynolds, 14 JAN 14
    //   Fix problem with output entries and Invoiced Quantity
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 9 NOV 15
    //   NAV 2016 refactoring
    // 
    // P8005479, To-Increase, Jack Reynolds, 19 NOV 15
    //   Files to find value entry
    // 
    // PRW110.0.02
    // P80043683, To-Increase, Jack Reynolds, 17 JUL 17
    //   Set CalledFromAdjustment after clearing ItemJnlPostLine
    // 
    // PRW111.00.01
    // P80059825, To-Increase, Jack Reynolds, 13 JUN 18
    //   Fix problem with duplicate G/L Entry No.
    // 
    // P80074083, To-Increase, Jack Reynolds, 02 MAY 19
    //   Issues with adjusting repack and lot combination
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW120.00
    // P800144605, To Increase, Jack Reynolds, 20 APR 22
    //   Upgrade to 20.0

    Permissions = TableData Item = rm,
                  TableData "Item Ledger Entry" = rm,
                  TableData "Item Application Entry" = rimd,
                  TableData "Value Entry" = rim,
                  TableData "Avg. Cost Adjmt. Entry Point" = rimd,
                  TableData "Inventory Adjmt. Entry (Order)" = rm;

    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Adjusting value entries...\\';
        Text001: Label 'Adjmt. Level      #2######\';
        Text002: Label '%1 %2';
        Text003: Label 'Adjust            #3######\';
        Text004: Label 'Cost FW. Level    #4######\';
        Text005: Label 'Entry No.         #5######\';
        Text006: Label 'Remaining Entries #6######';
        Text007: Label 'Applied cost';
        Text008: Label 'Average cost';
        Item: Record Item;
        FilterItem: Record Item;
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        InvtSetup: Record "Inventory Setup";
        SourceCodeSetup: Record "Source Code Setup";
        TempInvtAdjmtBuf: Record "Inventory Adjustment Buffer" temporary;
        TempRndgResidualBuf: Record "Rounding Residual Buffer" temporary;
        TempItemLedgerEntryBuf: Record "Item Ledger Entry" temporary;
        TempAvgCostExceptionBuf: Record "Integer" temporary;
        AvgCostBuf: Record "Cost Element Buffer";
        TempAvgCostRndgBuf: Record "Rounding Residual Buffer" temporary;
        TempRevaluationPoint: Record "Integer" temporary;
        TempFixApplBuffer: Record "Integer" temporary;
        TempOpenItemLedgEntry: Record "Integer" temporary;
        TempJobToAdjustBuf: Record Job temporary;
        TempValueEntryCalcdOutbndCostBuf: Record "Value Entry" temporary;
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        CostCalcMgt: Codeunit "Cost Calculation Management";
        ItemCostMgt: Codeunit ItemCostManagement;
        Window: Dialog;
        WindowUpdateDateTime: DateTime;
        PostingDateForClosedPeriod: Date;
        LevelNo: array[3] of Integer;
        MaxLevels: Integer;
        LevelExceeded: Boolean;
        IsDeletedItem: Boolean;
        IsOnlineAdjmt: Boolean;
        PostToGL: Boolean;
        SkipUpdateJobItemCost: Boolean;
        WindowIsOpen: Boolean;
        WindowAdjmtLevel: Integer;
        WindowItem: Code[20];
        WindowAdjust: Text[20];
        WindowFWLevel: Integer;
        WindowEntry: Integer;
        Text009: Label 'WIP';
        Text010: Label 'Assembly';
        IsAvgCostCalcTypeItem: Boolean;
        WindowOutbndEntry: Integer;
        ConsumpAdjmtInPeriodWithOutput: Date;
        ProcessFns: Codeunit "Process 800 Functions";
        P800ProdOrderMgmt: Codeunit "Process 800 Prod. Order Mgt.";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        CoProdMgmt: Codeunit "Co-Product Cost Management";
        CommItemMgmt: Codeunit "Commodity Item Management";
        CommCostInitialized: Boolean;
        LastItemRegNo: Integer;
        LastGLRegNo: Integer;
        ManagingLockTimes: Boolean;
        MinLockTime: Integer;
        MinUnlockTime: Integer;
        WriteTransactionStarted: Boolean;
        WriteLockStartTime: DateTime;
        WriteLockEndTime: DateTime;

    procedure SetProperties(NewIsOnlineAdjmt: Boolean; NewPostToGL: Boolean)
    begin
        IsOnlineAdjmt := NewIsOnlineAdjmt;
        PostToGL := NewPostToGL;
    end;

    procedure SetFilterItem(var NewItem: Record Item)
    begin
        FilterItem.CopyFilters(NewItem);
    end;

    procedure MakeMultiLevelAdjmt()
    var
        TempItem: Record Item temporary;
        TempInventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)" temporary;
        TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary;
        IsFirstTime: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeMakeMultiLevelAdjmt(FilterItem, IsOnlineAdjmt, PostToGL, IsHandled);
        if IsHandled then
            exit;

        InitializeAdjmt();

        IsFirstTime := true;
        while (InvtToAdjustExist(TempItem) or IsFirstTime) and not LevelExceeded do begin
            MakeSingleLevelAdjmt(TempItem, TempAvgCostAdjmtEntryPoint);
            if BOMToAdjustExists(TempInventoryAdjmtEntryOrder) then                  // P8001134
                MakeBOMAdjmt(TempInventoryAdjmtEntryOrder, TempAvgCostAdjmtEntryPoint); // P8001134, P80066030
            if AssemblyToAdjustExists(TempInventoryAdjmtEntryOrder) then
                MakeAssemblyAdjmt(TempInventoryAdjmtEntryOrder, TempAvgCostAdjmtEntryPoint);
            if WIPToAdjustExist(TempInventoryAdjmtEntryOrder) then
                MakeWIPAdjmt(TempInventoryAdjmtEntryOrder, TempAvgCostAdjmtEntryPoint);
            OnMakeMultiLevelAdjmtOnAfterMakeAdjmt(
              TempAvgCostAdjmtEntryPoint, FilterItem, TempRndgResidualBuf, IsOnlineAdjmt, PostToGL, ItemJnlPostLine);
            IsFirstTime := false;
            CommitWriteTransaction(TempAvgCostAdjmtEntryPoint); // P8001227, P80066030
        end;

        SetAppliedEntryToAdjustFromBuf('');
        FinalizeAdjmt();
        UpdateJobItemCost();

        OnAfterMakeMultiLevelAdjmt(TempItem, IsOnlineAdjmt, PostToGL, FilterItem);
    end;

    local procedure InitializeAdjmt()
    begin
        Clear(LevelNo);
        MaxLevels := 100;
        WindowUpdateDateTime := CurrentDateTime;
        if not IsOnlineAdjmt then
            OpenWindow();

        Clear(ItemJnlPostLine);
        ItemJnlPostLine.SetCalledFromAdjustment(true, PostToGL);

        InvtSetup.Get();
        GLSetup.Get();
        PostingDateForClosedPeriod := GLSetup.FirstAllowedPostingDate();
        GetAddReportingCurrency();

        SourceCodeSetup.Get();

        ItemCostMgt.SetProperties(true, 0);
        TempJobToAdjustBuf.DeleteAll();
    end;

    local procedure FinalizeAdjmt()
    begin
        Clear(ItemJnlPostLine);
        Clear(CostCalcMgt);
        Clear(ItemCostMgt);
        TempAvgCostRndgBuf.DeleteAll();
        if WindowIsOpen then
            Window.Close();
        WindowIsOpen := false;
    end;

    local procedure GetAddReportingCurrency()
    begin
        if GLSetup."Additional Reporting Currency" <> '' then begin
            Currency.Get(GLSetup."Additional Reporting Currency");
            Currency.CheckAmountRoundingPrecision();
        end;
    end;

    local procedure InvtToAdjustExist(var ToItem: Record Item): Boolean
    var
        Item: Record Item;
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        with Item do begin
            Reset();
            CopyFilters(FilterItem);
            if GetFilter("No.") = '' then
                SetCurrentKey("Cost is Adjusted", "Allow Online Adjustment");
            SetRange("Cost is Adjusted", false);
            if IsOnlineAdjmt then
                SetRange("Allow Online Adjustment", true);

            OnInvtToAdjustExistOnBeforeCopyItemToItem(Item);
            CopyItemToItem(Item, ToItem);

            if ItemLedgEntry.AppliedEntryToAdjustExists('') then
                InsertDeletedItem(ToItem);

            exit(not ToItem.IsEmpty());
        end;
    end;

    local procedure MakeSingleLevelAdjmt(var TheItem: Record Item; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    var
        IsFirstTime: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeMakeSingleLevelAdjmt(TheItem, TempAvgCostAdjmtEntryPoint, IsHandled);
        if IsHandled then
            exit;

        LevelNo[1] := LevelNo[1] + 1;

        UpDateWindow(LevelNo[1], WindowItem, WindowAdjust, WindowFWLevel, WindowEntry, 0);

        ConsumpAdjmtInPeriodWithOutput := 0D;

        TheItem.SetCurrentKey("Low-Level Code");
        if TheItem.FindLast() then
            TheItem.SetRange("Low-Level Code", TheItem."Low-Level Code");

        with Item do
            if TheItem.FindSet() then
                repeat
                    Item := TheItem;
                    GetItem("No.");
                    UpDateWindow(WindowAdjmtLevel, "No.", WindowAdjust, WindowFWLevel, WindowEntry, 0);

                    OnMakeSingleLevelAdjmtOnBeforeCollectAvgCostAdjmtEntryPointToUpdate(TheItem);
                    CollectAvgCostAdjmtEntryPointToUpdate(TempAvgCostAdjmtEntryPoint, TheItem."No.");
                    IsFirstTime := not AppliedEntryToAdjustBufExists(TheItem."No.");

                    repeat
                        LevelExceeded := false;
                        AdjustItemAppliedCost(TempAvgCostAdjmtEntryPoint); // P80066030
                    until not LevelExceeded;

                    AdjustItemAvgCost();
                    PostAdjmtBuf(TempAvgCostAdjmtEntryPoint);
                    UpdateItemUnitCost(TempAvgCostAdjmtEntryPoint, IsFirstTime);
                    OnMakeSingleLevelAdjmtOnAfterUpdateItemUnitCost(TheItem, TempAvgCostAdjmtEntryPoint, LevelExceeded, IsOnlineAdjmt, ItemJnlPostLine);
                    CommitWriteTransaction(TempAvgCostAdjmtEntryPoint); // P8001227, P80066030
                until (TheItem.Next() = 0) or LevelExceeded;
    end;

    local procedure AdjustItemAppliedCost(var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        AppliedQty: Decimal;
    begin
        UpDateWindow(WindowAdjmtLevel, WindowItem, Text007, WindowFWLevel, WindowEntry, 0);

        TempValueEntryCalcdOutbndCostBuf.Reset();
        TempValueEntryCalcdOutbndCostBuf.DeleteAll();

        with ItemLedgEntry do
            if AppliedEntryToAdjustExists(Item."No.") then begin
                OnBeforeCopyILEToILE(Item, ItemLedgEntry);
                CopyILEToILE(ItemLedgEntry, TempItemLedgEntry);
                // TempItemLedgEntry.FindSet();     // P8001227
                if TempItemLedgEntry.FindSet() then // P8001227
                    repeat
                        Get(TempItemLedgEntry."Entry No.");
                        UpDateWindow(WindowAdjmtLevel, WindowItem, WindowAdjust, WindowFWLevel, "Entry No.", 0);

                        TempRndgResidualBuf.AddAdjustedCost("Entry No.", 0, 0, "Completely Invoiced");

                        AppliedQty := ForwardAppliedCost(ItemLedgEntry, false, TempAvgCostAdjmtEntryPoint); // P80066030

                        EliminateRndgResidual(ItemLedgEntry, AppliedQty);

                        EndWriteTransaction(TempAvgCostAdjmtEntryPoint); // P8001227
                    until (TempItemLedgEntry.Next() = 0) or LevelExceeded;
            end;
    end;

    local procedure ForwardAppliedCost(ItemLedgEntry: Record "Item Ledger Entry"; Recursion: Boolean; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary) AppliedQty: Decimal
    var
        AppliedEntryToAdjust: Boolean;
    begin
        with ItemLedgEntry do begin
            // Avoid stack overflow, if too many recursions
            if Recursion then
                LevelNo[3] := LevelNo[3] + 1
            else
                LevelNo[3] := 0;

            if LevelNo[3] = MaxLevels then begin
                // SetAppliedEntryToAdjust(TRUE);              // P8001227
                WriteAppliedEntryToAdjust(ItemLedgEntry, true); // P8001227
                LevelExceeded := true;
                LevelNo[3] := 0;
                exit;
            end;

            UpDateWindow(WindowAdjmtLevel, WindowItem, WindowAdjust, LevelNo[3], WindowEntry, 0);

            AppliedQty := ForwardCostToOutbndEntries(ItemLedgEntry, Recursion, AppliedEntryToAdjust, TempAvgCostAdjmtEntryPoint); // P80066030
            OnForwardAppliedCostOnAfterSetAppliedQty(ItemLedgEntry, AppliedQty);

            ForwardCostToInbndTransEntries("Entry No.", Recursion, TempAvgCostAdjmtEntryPoint); // P80066030

            ForwardCostToInbndEntries("Entry No.", TempAvgCostAdjmtEntryPoint); // P80066030

            if OutboundSalesEntryToAdjust(ItemLedgEntry) or
               InboundTransferEntryToAdjust(ItemLedgEntry)
            then
                AppliedEntryToAdjust := true;

            if not IsOutbndConsump() and AppliedEntryToAdjust then
                UpdateAppliedEntryToAdjustBuf(ItemLedgEntry, AppliedEntryToAdjust);

            if ManagingLockTimes then                                                                 // P8001227
                WriteAppliedEntryToAdjust(ItemLedgEntry, (not IsOutbndConsump) and AppliedEntryToAdjust) // P8001227
            else                                                                                      // P8001227
                SetAppliedEntryToAdjust(false);
        end;
    end;

    local procedure ForwardAppliedCostRecursion(ItemLedgEntry: Record "Item Ledger Entry"; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    var
        ValueEntry: Record "Value Entry";
        ItemApplicationEntry: Record "Item Application Entry";
        CostAmt: Decimal;
        CostAmtACY: Decimal;
        AppliedQty: Decimal;
        AppliedCostAmt: Decimal;
        AppliedCostAmtACY: Decimal;
    begin
        // if not ItemLedgEntry."Applied Entry to Adjust" then begin // P8001227
        if not IsAppliedEntryToAdjust(ItemLedgEntry) then begin      // P8001227
            AppliedQty := ForwardAppliedCost(ItemLedgEntry, true, TempAvgCostAdjmtEntryPoint); // P80066030

            if IsRndgAllowed(ItemLedgEntry, AppliedQty) then begin
                TempInvtAdjmtBuf.CalcItemLedgEntryCost(ItemLedgEntry."Entry No.", false);
                ValueEntry.CalcItemLedgEntryCost(ItemLedgEntry."Entry No.", false);
                ValueEntry.AddCost(TempInvtAdjmtBuf);
                CostAmt := ValueEntry."Cost Amount (Actual)";
                CostAmtACY := ValueEntry."Cost Amount (Actual) (ACY)";

                if ItemApplicationEntry.AppliedOutbndEntryExists(ItemLedgEntry."Entry No.", true, false) then begin
                    repeat
                        TempInvtAdjmtBuf.CalcItemLedgEntryCost(ItemApplicationEntry."Item Ledger Entry No.", false);
                        ValueEntry.CalcItemLedgEntryCost(ItemApplicationEntry."Item Ledger Entry No.", false);
                        ValueEntry.AddCost(TempInvtAdjmtBuf);
                        AppliedCostAmt -= ValueEntry."Cost Amount (Actual)";
                        AppliedCostAmtACY -= ValueEntry."Cost Amount (Actual)";
                    until ItemApplicationEntry.Next() = 0;

                    if (Abs(CostAmt - AppliedCostAmt) = GLSetup."Amount Rounding Precision") or
                       (Abs(CostAmtACY - AppliedCostAmtACY) = Currency."Amount Rounding Precision")
                    then
                        UpdateAppliedEntryToAdjustBuf(ItemLedgEntry, true);
                end;
            end;

            if LevelNo[3] > 0 then
                LevelNo[3] := LevelNo[3] - 1;
            EndWriteTransaction(TempAvgCostAdjmtEntryPoint); // P8001227, P80066030
        end;
    end;

    local procedure ForwardCostToOutbndEntries(ItemLedgEntry: Record "Item Ledger Entry"; Recursion: Boolean; var AppliedEntryToAdjust: Boolean; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary) AppliedQty: Decimal
    var
        ItemApplnEntry: Record "Item Application Entry";
        InboundCompletelyInvoiced: Boolean;
    begin
        AppliedQty := 0;
        with ItemApplnEntry do
            if AppliedOutbndEntryExists(ItemLedgEntry."Entry No.", true, ItemLedgEntry.Open) then
                repeat
                    if not AdjustAppliedOutbndEntries("Outbound Item Entry No.", Recursion, InboundCompletelyInvoiced, TempAvgCostAdjmtEntryPoint) then // P80066030
                        AppliedEntryToAdjust :=
                          AppliedEntryToAdjust or
                          InboundCompletelyInvoiced or ItemLedgEntry.Open or not ItemLedgEntry."Completely Invoiced";
                    AppliedQty += Quantity;
                until Next() = 0;
    end;

    local procedure AdjustAppliedOutbndEntries(OutbndItemLedgEntryNo: Integer; Recursion: Boolean; var InboundCompletelyInvoiced: Boolean; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary): Boolean
    var
        OutbndItemLedgEntry: Record "Item Ledger Entry";
        OutbndValueEntry: Record "Value Entry";
        TempOutbndCostElementBuf: Record "Cost Element Buffer" temporary;
        TempOldCostElementBuf: Record "Cost Element Buffer" temporary;
        TempAdjustedCostElementBuf: Record "Cost Element Buffer" temporary;
        ItemApplnEntry: Record "Item Application Entry";
        StandardCostMirroring: Boolean;
        ExpectedCost: Boolean;
    begin
        OutbndItemLedgEntry.Get(OutbndItemLedgEntryNo);
        if Item."Costing Method" = Item."Costing Method"::Standard then
            StandardCostMirroring := UseStandardCostMirroring(OutbndItemLedgEntry);

        CalcOutbndCost(TempOutbndCostElementBuf, TempAdjustedCostElementBuf, OutbndItemLedgEntry, Recursion);

        with OutbndValueEntry do begin
            Reset();
            SetCurrentKey("Item Ledger Entry No.", "Document No.", "Document Line No.");
            SetRange("Item Ledger Entry No.", OutbndItemLedgEntryNo);
            for ExpectedCost := true downto false do begin
                SetRange("Expected Cost", ExpectedCost);
                if FindSet() then
                    repeat
                        if not (Adjustment or ExpCostIsCompletelyInvoiced(OutbndItemLedgEntry, OutbndValueEntry)) and
                           Inventoriable
                        then begin
                            SetRange("Document No.", "Document No.");
                            SetRange("Document Line No.", "Document Line No.");
                            CalcOutbndDocOldCost(
                              TempOldCostElementBuf, OutbndValueEntry,
                              OutbndItemLedgEntry.IsExactCostReversingPurchase() or OutbndItemLedgEntry.IsExactCostReversingOutput());

                            //CalcCostPerUnit(OutbndValueEntry, TempOutbndCostElementBuf, OutbndItemLedgEntry.Quantity);    // P8000304A
                            CalcCostPerUnit(OutbndValueEntry, TempOutbndCostElementBuf, OutbndItemLedgEntry.GetCostingQty); // PR4.00


                            if not "Expected Cost" then begin
                                TempOldCostElementBuf.GetElement("Cost Entry Type"::"Direct Cost", "Cost Variance Type"::" ");
                                "Invoiced Quantity" := TempOldCostElementBuf."Invoiced Quantity";
                                "Valued Quantity" := TempOldCostElementBuf."Invoiced Quantity";
                            end;

                            CalcOutbndDocNewCost(
                              TempAdjustedCostElementBuf, TempOutbndCostElementBuf,
                              // OutbndValueEntry, OutbndItemLedgEntry.Quantity);   // PR4.00
                              OutbndValueEntry, OutbndItemLedgEntry.GetCostingQty); // PR4.00


                            if "Expected Cost" then begin
                                TempOldCostElementBuf.GetElement(TempOldCostElementBuf.Type::Total, TempOldCostElementBuf."Variance Type"::" ");
                                TempAdjustedCostElementBuf."Actual Cost" := TempAdjustedCostElementBuf."Actual Cost" - TempOldCostElementBuf."Expected Cost";
                                TempAdjustedCostElementBuf."Actual Cost (ACY)" :=
                                  TempAdjustedCostElementBuf."Actual Cost (ACY)" - TempOldCostElementBuf."Expected Cost (ACY)";
                            end else begin
                                TempOldCostElementBuf.GetElement("Entry Type"::"Direct Cost", "Cost Variance Type"::" ");
                                TempAdjustedCostElementBuf."Actual Cost" := TempAdjustedCostElementBuf."Actual Cost" - TempOldCostElementBuf."Actual Cost";
                                TempAdjustedCostElementBuf."Actual Cost (ACY)" :=
                                  TempAdjustedCostElementBuf."Actual Cost (ACY)" - TempOldCostElementBuf."Actual Cost (ACY)";
                            end;

                            if StandardCostMirroring and not "Expected Cost" then
                                CreateCostAdjmtBuf(
                                  OutbndValueEntry, TempAdjustedCostElementBuf, OutbndItemLedgEntry."Posting Date", "Entry Type"::Variance)
                            else
                                CreateCostAdjmtBuf(
                                  OutbndValueEntry, TempAdjustedCostElementBuf, OutbndItemLedgEntry."Posting Date", "Entry Type");

                            if not "Expected Cost" then begin
                                CreateIndirectCostAdjmt(TempOldCostElementBuf, TempAdjustedCostElementBuf, OutbndValueEntry, "Entry Type"::"Indirect Cost");
                                CreateIndirectCostAdjmt(TempOldCostElementBuf, TempAdjustedCostElementBuf, OutbndValueEntry, "Entry Type"::Variance);
                            end;
                            FindLast();
                            SetRange("Document No.");
                            SetRange("Document Line No.");
                        end;
                    until Next() = 0;
            end;

            // Update transfers, consumptions
            if IsUpdateCompletelyInvoiced(
                 OutbndItemLedgEntry, TempOutbndCostElementBuf."Inbound Completely Invoiced")
            then
                // OutbndItemLedgEntry.SetCompletelyInvoiced(); // P8001227
                WriteCompletelyInvoiced(OutbndItemLedgEntry);   // P8001227

            ForwardAppliedCostRecursion(OutbndItemLedgEntry, TempAvgCostAdjmtEntryPoint); // P80066030

            if OutbndItemLedgEntry."Completely Invoiced" then // P8001227
                StartILEWriteTransaction(OutbndItemLedgEntry);  // P8001227
            ItemApplnEntry.SetInboundToUpdated(OutbndItemLedgEntry);

            InboundCompletelyInvoiced := TempOutbndCostElementBuf."Inbound Completely Invoiced";
            exit(OutbndItemLedgEntry."Completely Invoiced");
        end;
    end;

    local procedure CalcCostPerUnit(var OutbndValueEntry: Record "Value Entry"; OutbndCostElementBuf: Record "Cost Element Buffer"; ItemLedgEntryQty: Decimal)
    begin
        with OutbndCostElementBuf do begin
            if ItemLedgEntryQty - "Remaining Quantity" = 0 then // P8000304A
                exit;                                             // P8000304A
            if (OutbndValueEntry."Cost per Unit" = 0) and ("Remaining Quantity" <> 0) then
                OutbndValueEntry."Cost per Unit" := "Actual Cost" / (ItemLedgEntryQty - "Remaining Quantity");
            if (OutbndValueEntry."Cost per Unit (ACY)" = 0) and ("Remaining Quantity" <> 0) then
                OutbndValueEntry."Cost per Unit (ACY)" := "Actual Cost (ACY)" / (ItemLedgEntryQty - "Remaining Quantity");
        end;
    end;

    local procedure CalcOutbndCost(var OutbndCostElementBuf: Record "Cost Element Buffer"; var AdjustedCostElementBuf: Record "Cost Element Buffer"; OutbndItemLedgEntry: Record "Item Ledger Entry"; Recursion: Boolean)
    var
        OutbndItemApplnEntry: Record "Item Application Entry";
        TempCostElementBuf: Record "Cost Element Buffer" temporary;
    begin
        AdjustedCostElementBuf.DeleteAll();
        OutbndCostElementBuf.DeleteAll();

        if RestoreValuesFromBuffers(OutbndCostElementBuf, AdjustedCostElementBuf, OutbndItemLedgEntry."Entry No.") then begin
            if not Recursion then begin
                OutbndItemApplnEntry.SetCurrentKey("Inbound Item Entry No.");
                OutbndItemApplnEntry.SetRange("Inbound Item Entry No.", TempRndgResidualBuf."Item Ledger Entry No.");
                OutbndItemApplnEntry.SetRange("Item Ledger Entry No.", OutbndItemLedgEntry."Entry No.");
                OutbndItemApplnEntry.SetFilter("Transferred-from Entry No.", '<>%1', TempRndgResidualBuf."Item Ledger Entry No.");
                if OutbndItemApplnEntry.FindSet() then
                    repeat
                        CalcInbndEntryAdjustedCost(
                          TempCostElementBuf, OutbndItemApplnEntry, OutbndItemLedgEntry."Entry No.", OutbndItemApplnEntry."Inbound Item Entry No.",
                          OutbndItemLedgEntry.IsExactCostReversingPurchase() or OutbndItemLedgEntry.IsExactCostReversingOutput(), false);
                    until OutbndItemApplnEntry.Next() = 0;
            end;
            exit;
        end;

        with OutbndCostElementBuf do begin
            // "Remaining Quantity" := OutbndItemLedgEntry.Quantity;   // PR4.00
            "Remaining Quantity" := OutbndItemLedgEntry.GetCostingQty; // PR4.00
            "Inbound Completely Invoiced" := true;

            OutbndItemApplnEntry.SetCurrentKey("Item Ledger Entry No.");
            OutbndItemApplnEntry.SetRange("Item Ledger Entry No.", OutbndItemLedgEntry."Entry No.");
            OutbndItemApplnEntry.FindSet();
            repeat
                if not
                   CalcInbndEntryAdjustedCost(
                     AdjustedCostElementBuf,
                     OutbndItemApplnEntry, OutbndItemLedgEntry."Entry No.",
                     OutbndItemApplnEntry."Inbound Item Entry No.",
                     OutbndItemLedgEntry.IsExactCostReversingPurchase() or OutbndItemLedgEntry.IsExactCostReversingOutput(),
                     Recursion)
                then
                    "Inbound Completely Invoiced" := false;

                AdjustedCostElementBuf.GetElement(Type::"Direct Cost", "Variance Type"::" ");
                "Actual Cost" := "Actual Cost" + AdjustedCostElementBuf."Actual Cost";
                "Actual Cost (ACY)" := "Actual Cost (ACY)" + AdjustedCostElementBuf."Actual Cost (ACY)";
                // "Remaining Quantity" := "Remaining Quantity" - OutbndItemApplnEntry.Quantity;   // PR4.00
                "Remaining Quantity" := "Remaining Quantity" - OutbndItemApplnEntry.GetCostingQty; // PR4.00
            until OutbndItemApplnEntry.Next() = 0;

            if "Inbound Completely Invoiced" then
                "Inbound Completely Invoiced" := "Remaining Quantity" = 0;
        end;

        SaveValuesToBuffers(OutbndCostElementBuf, AdjustedCostElementBuf, OutbndItemLedgEntry."Entry No.");
    end;

    local procedure CalcOutbndDocNewCost(var NewCostElementBuf: Record "Cost Element Buffer"; OutbndCostElementBuf: Record "Cost Element Buffer"; OutbndValueEntry: Record "Value Entry"; ItemLedgEntryQty: Decimal)
    var
        ShareOfTotalCost: Decimal;
    begin
        // PR4.00 Begin
        if ItemLedgEntryQty = 0 then
            ShareOfTotalCost := 0
        else
            // PR4.00 End
            ShareOfTotalCost := OutbndValueEntry."Valued Quantity" / ItemLedgEntryQty;
        with OutbndCostElementBuf do begin
            NewCostElementBuf.GetElement(Type::"Direct Cost", "Cost Variance Type"::" ");
            "Actual Cost" := "Actual Cost" + OutbndValueEntry."Cost per Unit" * "Remaining Quantity";
            "Actual Cost (ACY)" := "Actual Cost (ACY)" + OutbndValueEntry."Cost per Unit (ACY)" * "Remaining Quantity";

            RoundCost(
              NewCostElementBuf."Actual Cost", NewCostElementBuf."Rounding Residual",
              "Actual Cost", ShareOfTotalCost, GLSetup."Amount Rounding Precision");
            RoundCost(
              NewCostElementBuf."Actual Cost (ACY)", NewCostElementBuf."Rounding Residual (ACY)",
              "Actual Cost (ACY)", ShareOfTotalCost, Currency."Amount Rounding Precision");

            if not NewCostElementBuf.Insert() then
                NewCostElementBuf.Modify();
        end;
    end;

    local procedure CollectAvgCostAdjmtEntryPointToUpdate(var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary; ItemNo: Code[20])
    var
        AvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point";
    begin
        with AvgCostAdjmtEntryPoint do begin
            SetRange("Item No.", ItemNo);
            SetRange("Cost Is Adjusted", false);
            if FindSet() then
                repeat
                    InsertEntryPointToUpdate(TempAvgCostAdjmtEntryPoint, "Item No.", "Variant Code", "Location Code");
                until Next() = 0;
        end;
    end;

    local procedure CreateCostAdjmtBuf(OutbndValueEntry: Record "Value Entry"; CostElementBuf: Record "Cost Element Buffer"; ItemLedgEntryPostingDate: Date; EntryType: Enum "Cost Entry Type"): Boolean
    begin
        with CostElementBuf do
            if UpdateAdjmtBuf(OutbndValueEntry, "Actual Cost", "Actual Cost (ACY)", ItemLedgEntryPostingDate, EntryType) then begin
                UpdateAvgCostAdjmtEntryPoint(OutbndValueEntry);
                exit(true);
            end;
        exit(false);
    end;

    local procedure CreateIndirectCostAdjmt(var CostElementBuf: Record "Cost Element Buffer"; var AdjustedCostElementBuf: Record "Cost Element Buffer"; OutbndValueEntry: Record "Value Entry"; EntryType: Enum "Cost Entry Type")
    var
        ItemJnlLine: Record "Item Journal Line";
        OrigValueEntry: Record "Value Entry";
        NewAdjustedCost: Decimal;
        NewAdjustedCostACY: Decimal;
    begin
        CostElementBuf.GetElement(EntryType, "Cost Variance Type"::" ");
        AdjustedCostElementBuf.GetElement(EntryType, "Cost Variance Type"::" ");
        NewAdjustedCost := AdjustedCostElementBuf."Actual Cost" - CostElementBuf."Actual Cost";
        NewAdjustedCostACY := AdjustedCostElementBuf."Actual Cost (ACY)" - CostElementBuf."Actual Cost (ACY)";

        if HasNewCost(NewAdjustedCost, NewAdjustedCostACY) then begin
            GetOrigValueEntry(OrigValueEntry, OutbndValueEntry, EntryType);
            InitAdjmtJnlLine(
              ItemJnlLine, OrigValueEntry, OrigValueEntry."Entry Type", OrigValueEntry."Variance Type", OrigValueEntry."Invoiced Quantity");
            PostItemJnlLine(ItemJnlLine, OrigValueEntry, NewAdjustedCost, NewAdjustedCostACY);
            UpdateAvgCostAdjmtEntryPoint(OrigValueEntry);
        end;
    end;

    local procedure ForwardCostToInbndTransEntries(ItemLedgEntryNo: Integer; Recursion: Boolean; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        with ItemApplnEntry do
            if AppliedInbndTransEntryExists(ItemLedgEntryNo, true) then
                repeat
                    AdjustAppliedInbndTransEntries(ItemApplnEntry, Recursion, TempAvgCostAdjmtEntryPoint); // P80066030
                until Next() = 0;
    end;

    local procedure AdjustAppliedInbndTransEntries(TransItemApplnEntry: Record "Item Application Entry"; Recursion: Boolean; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    var
        TransValueEntry: Record "Value Entry";
        TransItemLedgEntry: Record "Item Ledger Entry";
        TempCostElementBuf: Record "Cost Element Buffer" temporary;
        TempAdjustedCostElementBuf: Record "Cost Element Buffer" temporary;
        EntryAdjusted: Boolean;
    begin
        with TransItemApplnEntry do begin
            TransItemLedgEntry.Get("Item Ledger Entry No.");
            if not TransItemLedgEntry."Completely Invoiced" then
                AdjustNotInvdRevaluation(TransItemLedgEntry, TransItemApplnEntry);

            CalcTransEntryOldCost(TempCostElementBuf, TransValueEntry, "Item Ledger Entry No.");

            if CalcInbndEntryAdjustedCost(
                 TempAdjustedCostElementBuf,
                 TransItemApplnEntry, TransItemLedgEntry."Entry No.",
                 "Transferred-from Entry No.",
                 false, Recursion)
            then
                if not TransItemLedgEntry."Completely Invoiced" then begin
                    // TransItemLedgEntry.SetCompletelyInvoiced(); // P8001227
                    WriteCompletelyInvoiced(TransItemLedgEntry);   // P8001227
                    EntryAdjusted := true;
                end;

            if UpdateAdjmtBuf(
                 TransValueEntry,
                 TempAdjustedCostElementBuf."Actual Cost" - TempCostElementBuf."Actual Cost",
                 TempAdjustedCostElementBuf."Actual Cost (ACY)" - TempCostElementBuf."Actual Cost (ACY)",
                 TransItemLedgEntry."Posting Date",
                 TransValueEntry."Entry Type")
            then
                EntryAdjusted := true;

            if EntryAdjusted then begin
                ClearOutboundEntryCostBuffer(TransItemLedgEntry."Entry No.");
                UpdateAvgCostAdjmtEntryPoint(TransValueEntry);
                ForwardAppliedCostRecursion(TransItemLedgEntry, TempAvgCostAdjmtEntryPoint); // P80066030
            end;
        end;
    end;

    local procedure CalcTransEntryOldCost(var CostElementBuf: Record "Cost Element Buffer"; var TransValueEntry: Record "Value Entry"; ItemLedgEntryNo: Integer)
    var
        TransValueEntry2: Record "Value Entry";
    begin
        Clear(CostElementBuf);
        with CostElementBuf do begin
            TransValueEntry2 := TransValueEntry;
            TransValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
            TransValueEntry.SetRange("Item Ledger Entry No.", ItemLedgEntryNo);
            TransValueEntry.SetRange("Entry Type", TransValueEntry."Entry Type"::"Direct Cost");
            TransValueEntry.Find('+');
            repeat
                if TransValueEntry."Item Charge No." = '' then begin
                    if TempInvtAdjmtBuf.Get(TransValueEntry."Entry No.") then
                        TransValueEntry.AddCost(TempInvtAdjmtBuf);
                    // P8000928
                    if TransValueEntry."Entry Type" = TransValueEntry."Entry Type"::"Direct Cost" then
                        TransValueEntry.CalcFields("Extra Charge", "Extra Charge (ACY)");
                    // P8000928
                    "Actual Cost" := "Actual Cost" + TransValueEntry."Cost Amount (Actual)" - TransValueEntry."Extra Charge"; // P8000928
                    "Actual Cost (ACY)" := "Actual Cost (ACY)" + TransValueEntry."Cost Amount (Actual) (ACY)" -               // P8000928
                      TransValueEntry."Extra Charge (ACY)";                                                                   // P8000928
                    TransValueEntry2 := TransValueEntry;
                end;
            until TransValueEntry.Next(-1) = 0;
            TransValueEntry := TransValueEntry2;
        end;
    end;

    local procedure ForwardCostToInbndEntries(ItemLedgEntryNo: Integer; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        with ItemApplnEntry do
            if AppliedInbndEntryExists(ItemLedgEntryNo, true) then
                repeat
                    AdjustAppliedInbndEntries(ItemApplnEntry, TempAvgCostAdjmtEntryPoint); // P80066030
                until Next() = 0;
    end;

    local procedure AdjustAppliedInbndEntries(var InbndItemApplnEntry: Record "Item Application Entry"; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    var
        OutbndItemLedgEntry: Record "Item Ledger Entry";
        InbndValueEntry: Record "Value Entry";
        InbndItemLedgEntry: Record "Item Ledger Entry";
        TempDocCostElementBuffer: Record "Cost Element Buffer" temporary;
        TempOldCostElementBuf: Record "Cost Element Buffer" temporary;
        EntryAdjusted: Boolean;
        ShareOfCost: Decimal;
    begin
        with InbndItemApplnEntry do begin
            OutbndItemLedgEntry.Get("Outbound Item Entry No.");
            // CalcItemApplnEntryOldCost(TempOldCostElementBuf, OutbndItemLedgEntry, Quantity);   // PR4.00
            CalcItemApplnEntryOldCost(TempOldCostElementBuf, OutbndItemLedgEntry, GetCostingQty); // PR4.00

            InbndItemLedgEntry.Get("Item Ledger Entry No.");
            InbndValueEntry.SetCurrentKey("Item Ledger Entry No.", "Document No.");
            InbndValueEntry.SetRange("Item Ledger Entry No.", "Item Ledger Entry No.");
            InbndValueEntry.FindSet();
            repeat
                if (InbndValueEntry."Entry Type" = InbndValueEntry."Entry Type"::"Direct Cost") and
                   (InbndValueEntry."Item Charge No." = '') and
                   not ExpCostIsCompletelyInvoiced(InbndItemLedgEntry, InbndValueEntry)
                then begin
                    InbndValueEntry.SetRange("Document No.", InbndValueEntry."Document No.");
                    InbndValueEntry.SetRange("Document Line No.", InbndValueEntry."Document Line No.");
                    CalcInbndDocOldCost(InbndValueEntry, TempDocCostElementBuffer);

                    if not InbndValueEntry."Expected Cost" then begin
                        TempDocCostElementBuffer.GetElement("Cost Entry Type"::"Direct Cost", "Cost Variance Type"::" ");
                        InbndValueEntry."Valued Quantity" := TempDocCostElementBuffer."Invoiced Quantity";
                        InbndValueEntry."Invoiced Quantity" := TempDocCostElementBuffer."Invoiced Quantity";
                    end;

                    // P8000756
                    if InbndItemLedgEntry.GetCostingQty <> 0 then
                        ShareOfCost := InbndValueEntry."Valued Quantity" / InbndItemLedgEntry.GetCostingQty
                    else
                        ShareOfCost := 1;
                    // P8000756
                    CalcInbndDocNewCost(
                      TempDocCostElementBuffer, TempOldCostElementBuf, InbndValueEntry."Expected Cost",
                      //InbndValueEntry."Valued Quantity" / InbndItemLedgEntry.Quantity);   // P8000756
                      ShareOfCost);                                                         // P8000756

                    if CreateCostAdjmtBuf(
                         InbndValueEntry, TempDocCostElementBuffer, InbndItemLedgEntry."Posting Date", InbndValueEntry."Entry Type")
                    then begin
                        EntryAdjusted := true;
                        TempValueEntryCalcdOutbndCostBuf.DeleteAll();
                    end;

                    InbndValueEntry.FindLast();
                    InbndValueEntry.SetRange("Document No.");
                    InbndValueEntry.SetRange("Document Line No.");
                end;
            until InbndValueEntry.Next() = 0;

            // Update transfers, consumptions
            if IsUpdateCompletelyInvoiced(
                 InbndItemLedgEntry, OutbndItemLedgEntry."Completely Invoiced")
            then begin
                // InbndItemLedgEntry.SetCompletelyInvoiced(); // P8001227
                WriteCompletelyInvoiced(InbndItemLedgEntry);   // P8001227
                EntryAdjusted := true;
            end;

            if EntryAdjusted then begin
                UpdateAvgCostAdjmtEntryPoint(InbndValueEntry);
                ForwardAppliedCostRecursion(InbndItemLedgEntry, TempAvgCostAdjmtEntryPoint); // P80066030
            end;
        end;
    end;

    local procedure CalcItemApplnEntryOldCost(var OldCostElementBuf: Record "Cost Element Buffer"; OutbndItemLedgEntry: Record "Item Ledger Entry"; ItemApplnEntryQty: Decimal)
    var
        OutbndValueEntry: Record "Value Entry";
        ShareOfExpectedCost: Decimal;
    begin
        // PR4.00 Begin
        if OutbndItemLedgEntry.GetCostingQty = 0 then
            ShareOfExpectedCost := 0
        else
            // PR4.00 End
            ShareOfExpectedCost :=
            // (OutbndItemLedgEntry.Quantity - OutbndItemLedgEntry."Invoiced Quantity") / OutbndItemLedgEntry.Quantity;     // PR4.00
            (OutbndItemLedgEntry.GetCostingQty - OutbndItemLedgEntry.GetCostingInvQty) / OutbndItemLedgEntry.GetCostingQty; // PR4.00

        Clear(OldCostElementBuf);
        with OldCostElementBuf do begin
            OutbndValueEntry.SetCurrentKey("Item Ledger Entry No.");
            OutbndValueEntry.SetRange("Item Ledger Entry No.", OutbndItemLedgEntry."Entry No.");
            OutbndValueEntry.FindSet();
            repeat
                if TempInvtAdjmtBuf.Get(OutbndValueEntry."Entry No.") then
                    OutbndValueEntry.AddCost(TempInvtAdjmtBuf);
                if OutbndValueEntry."Expected Cost" then begin
                    "Actual Cost" := "Actual Cost" + OutbndValueEntry."Cost Amount (Expected)" * ShareOfExpectedCost;
                    "Actual Cost (ACY)" := "Actual Cost (ACY)" + OutbndValueEntry."Cost Amount (Expected) (ACY)" * ShareOfExpectedCost;
                end else begin
                    "Actual Cost" := "Actual Cost" + OutbndValueEntry."Cost Amount (Actual)";
                    "Actual Cost (ACY)" := "Actual Cost (ACY)" + OutbndValueEntry."Cost Amount (Actual) (ACY)";
                end;
            until OutbndValueEntry.Next() = 0;

            if OutbndItemLedgEntry.GetCostingQty <> 0 then             // PR4.00
                RoundActualCost(
                  // ItemApplnEntryQty / OutbndItemLedgEntry.Quantity,   // PR4.00
                  ItemApplnEntryQty / OutbndItemLedgEntry.GetCostingQty, // PR4.00
                  GLSetup."Amount Rounding Precision", Currency."Amount Rounding Precision");
        end;
    end;

    local procedure CalcInbndDocOldCost(InbndValueEntry: Record "Value Entry"; var CostElementBuf: Record "Cost Element Buffer")
    begin
        CostElementBuf.DeleteAll();

        InbndValueEntry.SetCurrentKey("Item Ledger Entry No.", "Document No.");
        InbndValueEntry.SetRange("Item Ledger Entry No.", InbndValueEntry."Item Ledger Entry No.");
        InbndValueEntry.SetRange("Document No.", InbndValueEntry."Document No.");
        InbndValueEntry.SetRange("Document Line No.", InbndValueEntry."Document Line No.");
        with CostElementBuf do
            repeat
                if (InbndValueEntry."Entry Type" = InbndValueEntry."Entry Type"::"Direct Cost") and
                   (InbndValueEntry."Item Charge No." = '')
                then begin
                    if TempInvtAdjmtBuf.Get(InbndValueEntry."Entry No.") then
                        InbndValueEntry.AddCost(TempInvtAdjmtBuf);
                    if InbndValueEntry."Expected Cost" then
                        AddExpectedCostElement("Cost Entry Type"::"Direct Cost", "Cost Variance Type"::" ", InbndValueEntry."Cost Amount (Expected)", InbndValueEntry."Cost Amount (Expected) (ACY)")
                    else begin
                        AddActualCostElement("Cost Entry Type"::"Direct Cost", "Cost Variance Type"::" ", InbndValueEntry."Cost Amount (Actual)", InbndValueEntry."Cost Amount (Actual) (ACY)");
                        if InbndValueEntry."Invoiced Quantity" <> 0 then begin
                            "Invoiced Quantity" := "Invoiced Quantity" + InbndValueEntry."Invoiced Quantity";
                            if not Modify() then
                                Insert();
                        end;
                    end;
                end;
            until InbndValueEntry.Next() = 0;
    end;

    local procedure CalcInbndDocNewCost(var NewCostElementBuf: Record "Cost Element Buffer"; OldCostElementBuf: Record "Cost Element Buffer"; Expected: Boolean; ShareOfTotalCost: Decimal)
    begin
        OldCostElementBuf.RoundActualCost(
          ShareOfTotalCost, GLSetup."Amount Rounding Precision", Currency."Amount Rounding Precision");

        with NewCostElementBuf do
            if Expected then begin
                "Actual Cost" := OldCostElementBuf."Actual Cost" - "Expected Cost";
                "Actual Cost (ACY)" := OldCostElementBuf."Actual Cost (ACY)" - "Expected Cost (ACY)";
            end else begin
                "Actual Cost" := OldCostElementBuf."Actual Cost" - "Actual Cost";
                "Actual Cost (ACY)" := OldCostElementBuf."Actual Cost (ACY)" - "Actual Cost (ACY)";
            end;
    end;

    local procedure IsUpdateCompletelyInvoiced(ItemLedgEntry: Record "Item Ledger Entry"; CompletelyInvoiced: Boolean) Result: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeIsUpdateCompletelyInvoiced(ItemLedgEntry, CompletelyInvoiced, Result, IsHandled);
        if IsHandled then
            exit(Result);

        with ItemLedgEntry do
            exit(
              ("Entry Type" in ["Entry Type"::Transfer, "Entry Type"::Consumption]) and
              not "Completely Invoiced" and
              CompletelyInvoiced);
    end;

    local procedure CalcInbndEntryAdjustedCost(var AdjustedCostElementBuf: Record "Cost Element Buffer"; ItemApplnEntry: Record "Item Application Entry"; OutbndItemLedgEntryNo: Integer; InbndItemLedgEntryNo: Integer; ExactCostReversing: Boolean; Recursion: Boolean) CompletelyInvoiced: Boolean
    var
        InbndValueEntry: Record "Value Entry";
        InbndItemLedgEntry: Record "Item Ledger Entry";
        QtyNotInvoiced: Decimal;
        ShareOfTotalCost: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcInbndEntryAdjustedCost(AdjustedCostElementBuf, ItemApplnEntry, OutbndItemLedgEntryNo, InbndItemLedgEntryNo, ExactCostReversing, Recursion, CompletelyInvoiced, IsHandled);
        if not IsHandled then begin
            AdjustedCostElementBuf.DeleteAll();
            with InbndValueEntry do begin
                InbndItemLedgEntry.Get(InbndItemLedgEntryNo);
                SetCurrentKey("Item Ledger Entry No.");
                SetRange("Item Ledger Entry No.", InbndItemLedgEntryNo);
                // QtyNotInvoiced := InbndItemLedgEntry.Quantity - InbndItemLedgEntry."Invoiced Quantity"; // PR4.00
                QtyNotInvoiced := InbndItemLedgEntry.GetCostingQty - InbndItemLedgEntry.GetCostingInvQty;  // PR4.00

                FindSet();
                repeat
                    if IncludedInCostCalculation(InbndValueEntry, OutbndItemLedgEntryNo) and
                       not ExpCostIsCompletelyInvoiced(InbndItemLedgEntry, InbndValueEntry)
                    then begin
                        if TempInvtAdjmtBuf.Get("Entry No.") then
                            AddCost(TempInvtAdjmtBuf);
                        case true of
                            IsInterimRevaluation(InbndValueEntry):
                                // BEGIN                             // P8000267B
                                if "Valued Quantity" <> 0 then begin // P8000267B
                                    // ShareOfTotalCost := InbndItemLedgEntry.Quantity / "Valued Quantity";   // P8000267B
                                    ShareOfTotalCost := InbndItemLedgEntry.GetCostingQty / "Valued Quantity"; // P8000267B
                                    AdjustedCostElementBuf.AddActualCostElement(
                                      AdjustedCostElementBuf.Type::"Direct Cost", AdjustedCostElementBuf."Variance Type"::" ",
                                      ("Cost Amount (Expected)" + "Cost Amount (Actual)") * ShareOfTotalCost,
                                      ("Cost Amount (Expected) (ACY)" + "Cost Amount (Actual) (ACY)") * ShareOfTotalCost);
                                end;
                            "Expected Cost":
                                // BEGIN                             // PR4.00
                                if "Valued Quantity" <> 0 then begin // PR4.00
                                    ShareOfTotalCost := QtyNotInvoiced / "Valued Quantity";
                                    AdjustedCostElementBuf.AddActualCostElement(
                                      AdjustedCostElementBuf.Type::"Direct Cost", AdjustedCostElementBuf."Variance Type"::" ",
                                      "Cost Amount (Expected)" * ShareOfTotalCost,
                                      "Cost Amount (Expected) (ACY)" * ShareOfTotalCost);
                                end;
                            "Partial Revaluation":
                                // BEGIN                             // PR4.00
                                if "Valued Quantity" <> 0 then begin // PR4.00
                                    // ShareOfTotalCost := InbndItemLedgEntry.Quantity / "Valued Quantity";   // PR4.00
                                    ShareOfTotalCost := InbndItemLedgEntry.GetCostingQty / "Valued Quantity"; // PR4.00
                                    AdjustedCostElementBuf.AddActualCostElement(
                                      AdjustedCostElementBuf.Type::"Direct Cost", AdjustedCostElementBuf."Variance Type"::" ",
                                      "Cost Amount (Actual)" * ShareOfTotalCost,
                                      "Cost Amount (Actual) (ACY)" * ShareOfTotalCost);
                                end;
                            ("Entry Type".AsInteger() <= "Entry Type"::Revaluation.AsInteger()) or not ExactCostReversing:
                                AdjustedCostElementBuf.AddActualCostElement(
                                  AdjustedCostElementBuf.Type::"Direct Cost", AdjustedCostElementBuf."Variance Type"::" ",
                                  "Cost Amount (Actual)", "Cost Amount (Actual) (ACY)");
                            "Entry Type" = "Entry Type"::"Indirect Cost":
                                AdjustedCostElementBuf.AddActualCostElement(
                                  AdjustedCostElementBuf.Type::"Indirect Cost", AdjustedCostElementBuf."Variance Type"::" ",
                                  "Cost Amount (Actual)", "Cost Amount (Actual) (ACY)");
                            else
                                AdjustedCostElementBuf.AddActualCostElement(
                                  AdjustedCostElementBuf.Type::Variance, AdjustedCostElementBuf."Variance Type"::" ",
                                  "Cost Amount (Actual)", "Cost Amount (Actual) (ACY)");
                        end;
                    end;
                until Next() = 0;

                // P8000856
                if Item."Commodity Cost Item" then
                    CommItemMgmt.RemoveItemApplAdjmts(AdjustedCostElementBuf, InbndItemLedgEntry, ExactCostReversing);
                // P8000856

                // CalcNewAdjustedCost(AdjustedCostElementBuf,ItemApplnEntry.Quantity / InbndItemLedgEntry.Quantity); // PR4.00
                // PR4.00 Begin
                if InbndItemLedgEntry.GetCostingQty <> 0 then
                    ShareOfTotalCost := ItemApplnEntry.GetCostingQty / InbndItemLedgEntry.GetCostingQty
                else
                    ShareOfTotalCost := 1;
                CalcNewAdjustedCost(AdjustedCostElementBuf, ShareOfTotalCost);
                // PR4.00 End

                // P8000856
                if Item."Commodity Cost Item" then
                    CommItemMgmt.AddItemApplAdjmt(AdjustedCostElementBuf, ItemApplnEntry, ExactCostReversing);
                // P8000856

                if AdjustAppliedCostEntry(ItemApplnEntry, InbndItemLedgEntryNo, Recursion) then
                    TempRndgResidualBuf.AddAdjustedCost(
                      ItemApplnEntry."Inbound Item Entry No.",
                      AdjustedCostElementBuf."Actual Cost", AdjustedCostElementBuf."Actual Cost (ACY)",
                      ItemApplnEntry."Output Completely Invd. Date" <> 0D);
            end;
            CompletelyInvoiced := InbndItemLedgEntry."Completely Invoiced";
        end;

        OnAfterCalcInbndEntryAdjustedCost(AdjustedCostElementBuf, InbndValueEntry, InbndItemLedgEntry, ItemApplnEntry, OutbndItemLedgEntryNo, CompletelyInvoiced);
    end;

    local procedure CalcNewAdjustedCost(var AdjustedCostElementBuf: Record "Cost Element Buffer"; ShareOfTotalCost: Decimal)
    begin
        with AdjustedCostElementBuf do begin
            if FindSet() then
                repeat
                    RoundActualCost(ShareOfTotalCost, GLSetup."Amount Rounding Precision", Currency."Amount Rounding Precision");
                    Modify();
                until Next() = 0;

            CalcSums("Actual Cost", "Actual Cost (ACY)");
            AddActualCostElement(Type::Total, "Variance Type"::" ", "Actual Cost", "Actual Cost (ACY)");
        end;
    end;

    local procedure AdjustAppliedCostEntry(ItemApplnEntry: Record "Item Application Entry"; ItemLedgEntryNo: Integer; Recursion: Boolean): Boolean
    begin
        with ItemApplnEntry do
            exit(
              ("Transferred-from Entry No." <> ItemLedgEntryNo) and
              ("Inbound Item Entry No." = TempRndgResidualBuf."Item Ledger Entry No.") and
              not Recursion);
    end;

    procedure IncludedInCostCalculation(InbndValueEntry: Record "Value Entry"; OutbndItemLedgEntryNo: Integer): Boolean
    var
        OutbndValueEntry: Record "Value Entry";
    begin
        with InbndValueEntry do begin
            if "Entry Type" = "Entry Type"::Revaluation then begin
                if "Applies-to Entry" <> 0 then begin
                    Get("Applies-to Entry");
                    exit(IncludedInCostCalculation(InbndValueEntry, OutbndItemLedgEntryNo));
                end;
                if "Partial Revaluation" then begin
                    OutbndValueEntry.SetCurrentKey("Item Ledger Entry No.");
                    OutbndValueEntry.SetRange("Item Ledger Entry No.", OutbndItemLedgEntryNo);
                    OutbndValueEntry.SetFilter("Item Ledger Entry Quantity", '<>0');
                    // P8005479
                    if not OutbndValueEntry.FindFirst then
                        OutbndValueEntry.SetRange("Item Ledger Entry Quantity", 0);
                    // P8005479
                    OutbndValueEntry.FindFirst();
                    exit(
                      (OutbndValueEntry."Entry No." > "Entry No.") or
                      (OutbndValueEntry.GetValuationDate() > "Valuation Date") or
                      (OutbndValueEntry."Entry No." = 0));
                end;
            end;
            exit("Entry Type" <> "Entry Type"::Rounding);
        end;
    end;

    local procedure CalcOutbndDocOldCost(var CostElementBuf: Record "Cost Element Buffer"; OutbndValueEntry: Record "Value Entry"; ExactCostReversing: Boolean)
    var
        ValueEntry: Record "Value Entry";
    begin
        CostElementBuf.DeleteAll();
        with ValueEntry do begin
            SetCurrentKey("Item Ledger Entry No.", "Document No.", "Document Line No.");
            SetRange("Item Ledger Entry No.", OutbndValueEntry."Item Ledger Entry No.");
            SetRange("Document No.", OutbndValueEntry."Document No.");
            SetRange("Document Line No.", OutbndValueEntry."Document Line No.");
            FindSet();
            repeat
                if TempInvtAdjmtBuf.Get("Entry No.") then
                    AddCost(TempInvtAdjmtBuf);
                CostElementBuf.AddExpectedCostElement(
                  CostElementBuf.Type::Total, "Cost Variance Type"::" ", "Cost Amount (Expected)", "Cost Amount (Expected) (ACY)");
                if not "Expected Cost" then
                    case true of
                        ("Entry Type".AsInteger() <= "Entry Type"::Revaluation.AsInteger()) or not ExactCostReversing:
                            begin
                                CostElementBuf.AddActualCostElement(
                                  CostElementBuf.Type::"Direct Cost", CostElementBuf."Variance Type"::" ",
                                  "Cost Amount (Actual)", "Cost Amount (Actual) (ACY)");
                                if "Invoiced Quantity" <> 0 then begin
                                    CostElementBuf."Invoiced Quantity" := CostElementBuf."Invoiced Quantity" + "Invoiced Quantity";
                                    if not CostElementBuf.Modify() then
                                        CostElementBuf.Insert();
                                end;
                            end;
                        "Entry Type" = "Entry Type"::"Indirect Cost":
                            CostElementBuf.AddActualCostElement(
                              CostElementBuf.Type::"Indirect Cost", CostElementBuf."Variance Type"::" ",
                              "Cost Amount (Actual)", "Cost Amount (Actual) (ACY)");
                        else
                            CostElementBuf.AddActualCostElement(
                              CostElementBuf.Type::Variance, CostElementBuf."Variance Type"::" ",
                              "Cost Amount (Actual)", "Cost Amount (Actual) (ACY)");
                    end;
            until Next() = 0;

            CostElementBuf.CalcSums("Actual Cost", "Actual Cost (ACY)");
            CostElementBuf.AddActualCostElement(
              CostElementBuf.Type::Total, "Cost Variance Type"::" ", CostElementBuf."Actual Cost", CostElementBuf."Actual Cost (ACY)");
        end;
    end;

    local procedure EliminateRndgResidual(InbndItemLedgEntry: Record "Item Ledger Entry"; AppliedQty: Decimal)
    var
        ItemJnlLine: Record "Item Journal Line";
        ValueEntry: Record "Value Entry";
        RndgCost: Decimal;
        RndgCostACY: Decimal;
    begin
        if IsRndgAllowed(InbndItemLedgEntry, AppliedQty) then
            with InbndItemLedgEntry do begin
                TempInvtAdjmtBuf.CalcItemLedgEntryCost("Entry No.", false);
                ValueEntry.CalcItemLedgEntryCost("Entry No.", false);
                ValueEntry.AddCost(TempInvtAdjmtBuf);

                TempRndgResidualBuf.SetRange("Item Ledger Entry No.", "Entry No.");
                TempRndgResidualBuf.SetRange("Completely Invoiced", false);
                if TempRndgResidualBuf.IsEmpty() then begin
                    TempRndgResidualBuf.SetRange("Completely Invoiced");
                    TempRndgResidualBuf.CalcSums("Adjusted Cost", "Adjusted Cost (ACY)");
                    RndgCost := -(ValueEntry."Cost Amount (Actual)" + TempRndgResidualBuf."Adjusted Cost");
                    RndgCostACY := -(ValueEntry."Cost Amount (Actual) (ACY)" + TempRndgResidualBuf."Adjusted Cost (ACY)");

                    if HasNewCost(RndgCost, RndgCostACY) then begin
                        ValueEntry.Reset();
                        ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
                        ValueEntry.SetRange("Item Ledger Entry No.", "Entry No.");
                        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
                        ValueEntry.SetRange("Item Charge No.", '');
                        ValueEntry.SetRange(Adjustment, false);
                        ValueEntry.FindLast();
                        InitRndgResidualItemJnlLine(ItemJnlLine, ValueEntry);
                        PostItemJnlLine(ItemJnlLine, ValueEntry, RndgCost, RndgCostACY);
                    end;
                end;
            end;

        TempRndgResidualBuf.Reset();
        TempRndgResidualBuf.DeleteAll();
    end;

    local procedure IsRndgAllowed(ItemLedgEntry: Record "Item Ledger Entry"; AppliedQty: Decimal): Boolean
    begin
        exit(
          not ItemLedgEntry.Open and
          ItemLedgEntry."Completely Invoiced" and
          ItemLedgEntry.Positive and
          (AppliedQty = -ItemLedgEntry.Quantity) and
          not LevelExceeded);
    end;

    local procedure InitRndgResidualItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; OrigValueEntry: Record "Value Entry")
    begin
        with OrigValueEntry do begin
            ItemJnlLine.Init();
            ItemJnlLine."Value Entry Type" := ItemJnlLine."Value Entry Type"::Rounding;
            ItemJnlLine."Quantity (Base)" := 1;
            ItemJnlLine."Invoiced Qty. (Base)" := 1;
            ItemJnlLine."Quantity (Alt.)" := 1;      // P8000524A
            ItemJnlLine."Invoiced Qty. (Alt.)" := 1; // P8000524A
            ItemJnlLine."Source No." := "Source No.";
        end;
    end;

    local procedure AdjustItemAvgCost()
    var
        TempOutbndValueEntry: Record "Value Entry" temporary;
        TempExcludedValueEntry: Record "Value Entry" temporary;
        TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary;
        AvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point";
        PeriodPageMgt: Codeunit PeriodPageManagement;
        RemainingOutbnd: Integer;
        Restart: Boolean;
        EndOfValuationDateReached: Boolean;
        IsHandled: Boolean;
    begin
        if not IsAvgCostItem() then
            exit;

        UpDateWindow(WindowAdjmtLevel, WindowItem, Text008, WindowFWLevel, WindowEntry, 0);

        TempFixApplBuffer.Reset();
        TempFixApplBuffer.DeleteAll();
        DeleteAvgBuffers(TempOutbndValueEntry, TempExcludedValueEntry);

        with AvgCostAdjmtEntryPoint do
            while AvgCostAdjmtEntryPointExist(TempAvgCostAdjmtEntryPoint) do begin
                repeat
                    Restart := false;
                    AvgCostAdjmtEntryPoint := TempAvgCostAdjmtEntryPoint;

                    if (ConsumpAdjmtInPeriodWithOutput <> 0D) and
                       (ConsumpAdjmtInPeriodWithOutput <= "Valuation Date")
                    then
                        exit;

                    SetAvgCostAjmtFilter(TempAvgCostAdjmtEntryPoint);
                    TempAvgCostAdjmtEntryPoint.DeleteAll();
                    TempAvgCostAdjmtEntryPoint.Reset();

                    SetAvgCostAjmtFilter(AvgCostAdjmtEntryPoint);
                    StartWriteTransaction; // P8001227
                    ModifyAll("Cost Is Adjusted", true);
                    Reset();

                    OnAdjustItemAvgCostOnBeforeAdjustValueEntries();
                    EndOfValuationDateReached := false;
                    while not Restart and AvgValueEntriesToAdjustExist(
                            TempOutbndValueEntry, TempExcludedValueEntry, AvgCostAdjmtEntryPoint) and not EndOfValuationDateReached
                    do begin
                        RemainingOutbnd := TempOutbndValueEntry.Count();
                        TempOutbndValueEntry.SetCurrentKey("Item Ledger Entry No.");
                        TempOutbndValueEntry.Find('-');

                        repeat
                            UpDateWindow(WindowAdjmtLevel, WindowItem, WindowAdjust, WindowFWLevel, WindowEntry, RemainingOutbnd);
                            RemainingOutbnd -= 1;
                            AdjustOutbndAvgEntry(TempOutbndValueEntry, TempExcludedValueEntry, TempAvgCostAdjmtEntryPoint); // P80066030
                            UpdateConsumpAvgEntry(TempOutbndValueEntry);
                        until TempOutbndValueEntry.Next() = 0;

                        SetAvgCostAjmtFilter(AvgCostAdjmtEntryPoint);
                        Restart := FindFirst() and not "Cost Is Adjusted";
                        OnAdjustItemAvgCostOnAfterCalcRestart(TempExcludedValueEntry, Restart);
                        if "Valuation Date" >= PeriodPageMgt.EndOfPeriod() then
                            EndOfValuationDateReached := true
                        else
                            "Valuation Date" := GetNextDate("Valuation Date");
                    end;
                until (TempAvgCostAdjmtEntryPoint.Next() = 0) or Restart;

                IsHandled := false;
                OnAdjustItemAvgCostOnAfterLastTempAvgCostAdjmtEntryPoint(TempAvgCostAdjmtEntryPoint, Restart, IsHandled);
                if IsHandled then
                    break;
            end;
    end;

    local procedure AvgCostAdjmtEntryPointExist(var ToAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point"): Boolean
    var
        AvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point";
    begin
        AvgCostAdjmtEntryPoint.SetCurrentKey("Item No.", "Cost Is Adjusted", "Valuation Date");
        AvgCostAdjmtEntryPoint.SetRange("Item No.", Item."No.");
        AvgCostAdjmtEntryPoint.SetRange("Cost Is Adjusted", false);

        CopyAvgCostAdjmtToAvgCostAdjmt(AvgCostAdjmtEntryPoint, ToAvgCostAdjmtEntryPoint);
        ToAvgCostAdjmtEntryPoint.SetCurrentKey("Item No.", "Cost Is Adjusted", "Valuation Date");
        exit(ToAvgCostAdjmtEntryPoint.FindFirst())
    end;

    local procedure AvgValueEntriesToAdjustExist(var OutbndValueEntry: Record "Value Entry"; var ExcludedValueEntry: Record "Value Entry"; var AvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point"): Boolean
    var
        ValueEntry: Record "Value Entry";
        CalendarPeriod: Record Date;
        FiscalYearAccPeriod: Record "Accounting Period";
        ItemApplicationEntry: Record "Item Application Entry";
        PeriodPageMgt: Codeunit PeriodPageManagement;
        FindNextRange: Boolean;
    begin
        with ValueEntry do begin
            FindNextRange := false;
            ResetAvgBuffers(OutbndValueEntry, ExcludedValueEntry);

            CalendarPeriod."Period Start" := AvgCostAdjmtEntryPoint."Valuation Date";
            AvgCostAdjmtEntryPoint.GetValuationPeriod(CalendarPeriod);
            OnAfterGetValuationPeriod(CalendarPeriod, Item);

            SetCurrentKey("Item No.", "Valuation Date", "Location Code", "Variant Code");
            SetRange("Item No.", AvgCostAdjmtEntryPoint."Item No.");
            if AvgCostAdjmtEntryPoint.AvgCostCalcTypeIsChanged(CalendarPeriod."Period Start") then begin
                AvgCostAdjmtEntryPoint.GetAvgCostCalcTypeIsChgPeriod(FiscalYearAccPeriod, CalendarPeriod."Period Start");
                SetRange("Valuation Date", CalendarPeriod."Period Start", CalcDate('<-1D>', FiscalYearAccPeriod."Starting Date"));
            end else
                SetRange("Valuation Date", CalendarPeriod."Period Start", DMY2Date(31, 12, 9999));

            IsAvgCostCalcTypeItem := AvgCostAdjmtEntryPoint.IsAvgCostCalcTypeItem(CalendarPeriod."Period End");
            if not IsAvgCostCalcTypeItem then begin
                SetRange("Location Code", AvgCostAdjmtEntryPoint."Location Code");
                SetRange("Variant Code", AvgCostAdjmtEntryPoint."Variant Code");
            end;
            OnAvgValueEntriesToAdjustExistOnAfterSetAvgValueEntryFilters(ValueEntry);

            if FindFirst() then begin
                FindNextRange := true;

                if "Valuation Date" > CalendarPeriod."Period End" then begin
                    AvgCostAdjmtEntryPoint."Valuation Date" := "Valuation Date";
                    CalendarPeriod."Period Start" := "Valuation Date";
                    AvgCostAdjmtEntryPoint.GetValuationPeriod(CalendarPeriod);
                end;

                if not (AvgCostAdjmtEntryPoint.ValuationExists(ValueEntry) and
                        AvgCostAdjmtEntryPoint.PrevValuationAdjusted(ValueEntry)) or
                   ((ConsumpAdjmtInPeriodWithOutput <> 0D) and
                    (ConsumpAdjmtInPeriodWithOutput <= AvgCostAdjmtEntryPoint."Valuation Date"))
                then begin
                    AvgCostAdjmtEntryPoint.UpdateValuationDate(ValueEntry);
                    exit(false);
                end;

                SetRange("Valuation Date", CalendarPeriod."Period Start", CalendarPeriod."Period End");
                IsAvgCostCalcTypeItem := AvgCostAdjmtEntryPoint.IsAvgCostCalcTypeItem(CalendarPeriod."Period End");
                if not IsAvgCostCalcTypeItem then begin
                    SetRange("Location Code", AvgCostAdjmtEntryPoint."Location Code");
                    SetRange("Variant Code", AvgCostAdjmtEntryPoint."Variant Code");
                end;
                OnAvgValueEntriesToAdjustExistOnAfterSetChildValueEntryFilters(ValueEntry);

                OutbndValueEntry.Copy(ValueEntry);
                if not OutbndValueEntry.IsEmpty() then begin
                    OutbndValueEntry.SetCurrentKey("Item Ledger Entry No.");
                    exit(true);
                end;

                DeleteAvgBuffers(OutbndValueEntry, ExcludedValueEntry);
                FindSet();
                repeat
                    if "Entry Type" = "Entry Type"::Revaluation then
                        if "Partial Revaluation" or ItemApplicationEntry.AppliedFromEntryExists("Item Ledger Entry No.") then begin
                            TempRevaluationPoint.Number := "Entry No.";
                            if TempRevaluationPoint.Insert() then;
                            FillFixApplBuffer("Item Ledger Entry No.");
                        end;

                    if "Valued By Average Cost" and not Adjustment and ("Valued Quantity" < 0) then begin
                        OutbndValueEntry := ValueEntry;
                        OutbndValueEntry.Insert();
                        FindNextRange := false;
                    end;


                    OnAvgValueEntriesToAdjustExistOnBeforeIsNotAdjustment(ValueEntry, OutbndValueEntry);
                    if not Adjustment then
                        if IsAvgCostException(IsAvgCostCalcTypeItem) then begin
                            TempAvgCostExceptionBuf.Number := "Entry No.";
                            if TempAvgCostExceptionBuf.Insert() then;
                            TempAvgCostExceptionBuf.Number += 1;
                            if TempAvgCostExceptionBuf.Insert() then;
                        end;

                    ExcludedValueEntry := ValueEntry;
                    ExcludedValueEntry.Insert();
                until Next() = 0;
                FetchOpenItemEntriesToExclude(AvgCostAdjmtEntryPoint, ExcludedValueEntry, TempOpenItemLedgEntry, CalendarPeriod);
            end;

            if FindNextRange then
                if AvgCostAdjmtEntryPoint."Valuation Date" < PeriodPageMgt.EndOfPeriod() then begin
                    AvgCostAdjmtEntryPoint."Valuation Date" := GetNextDate(AvgCostAdjmtEntryPoint."Valuation Date");
                    OnAvgValueEntriesToAdjustExistOnFindNextRangeOnBeforeAvgValueEntriesToAdjustExist(OutbndValueEntry, ExcludedValueEntry, AvgCostAdjmtEntryPoint);
                    AvgValueEntriesToAdjustExist(OutbndValueEntry, ExcludedValueEntry, AvgCostAdjmtEntryPoint);
                end;
            exit(not OutbndValueEntry.IsEmpty() and not IsEmpty);
        end;
    end;

    local procedure GetNextDate(CurrentDate: Date): Date
    begin
        if CurrentDate = 0D then
            exit(00020101D);
        exit(CalcDate('<+1D>', CurrentDate));
    end;

    local procedure AdjustOutbndAvgEntry(var OutbndValueEntry: Record "Value Entry"; var ExcludedValueEntry: Record "Value Entry"; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    var
        OutbndItemLedgEntry: Record "Item Ledger Entry";
        TempOldCostElementBuf: Record "Cost Element Buffer" temporary;
        TempNewCostElementBuf: Record "Cost Element Buffer" temporary;
        EntryAdjusted: Boolean;
    begin
        OutbndItemLedgEntry.Get(OutbndValueEntry."Item Ledger Entry No.");
        if OutbndItemLedgEntry."Applies-to Entry" <> 0 then
            exit;
        if ExpCostIsCompletelyInvoiced(OutbndItemLedgEntry, OutbndValueEntry) then
            exit;

        with TempNewCostElementBuf do begin
            UpDateWindow(
              WindowAdjmtLevel, WindowItem, WindowAdjust, WindowFWLevel, OutbndValueEntry."Item Ledger Entry No.", WindowOutbndEntry);

            // EntryAdjusted := OutbndItemLedgEntry.SetAvgTransCompletelyInvoiced(); // P8001227
            EntryAdjusted := WriteAvgTransCompletelyInvoiced(OutbndItemLedgEntry);   // P8001227

            if CalcAvgCost(OutbndValueEntry, TempNewCostElementBuf, ExcludedValueEntry) then begin
                CalcOutbndDocOldCost(TempOldCostElementBuf, OutbndValueEntry, false);
                if OutbndValueEntry."Expected Cost" then begin
                    "Actual Cost" := "Actual Cost" - TempOldCostElementBuf."Expected Cost";
                    "Actual Cost (ACY)" := "Actual Cost (ACY)" - TempOldCostElementBuf."Expected Cost (ACY)";
                end else begin
                    "Actual Cost" := "Actual Cost" - TempOldCostElementBuf."Actual Cost";
                    "Actual Cost (ACY)" := "Actual Cost (ACY)" - TempOldCostElementBuf."Actual Cost (ACY)";
                end;
                if UpdateAdjmtBuf(
                     OutbndValueEntry, "Actual Cost", "Actual Cost (ACY)", OutbndItemLedgEntry."Posting Date", OutbndValueEntry."Entry Type")
                then
                    EntryAdjusted := true;
            end;

            if EntryAdjusted then begin
                if OutbndItemLedgEntry."Entry Type" = OutbndItemLedgEntry."Entry Type"::Consumption then
                    // OutbndItemLedgEntry.SetAppliedEntryToAdjust(FALSE); // P8001227
                    WriteAppliedEntryToAdjust(OutbndItemLedgEntry, false);  // P8001227

                OnAdjustOutbndAvgEntryOnBeforeForwardAvgCostToInbndEntries(OutbndItemLedgEntry);
                ForwardAvgCostToInbndEntries(OutbndItemLedgEntry."Entry No.", TempAvgCostAdjmtEntryPoint); // P80066030
            end;
        end;
    end;

    procedure ExpCostIsCompletelyInvoiced(ItemLedgEntry: Record "Item Ledger Entry"; ValueEntry: Record "Value Entry"): Boolean
    begin
        with ItemLedgEntry do
            //EXIT(ValueEntry."Expected Cost" AND (Quantity = "Invoiced Quantity"));  // P8000267B
            //EXIT(ValueEntry."Expected Cost" AND (GetCostingQty <> GetCostingInvQty)); // P8000267B, P8000338A
            exit(ValueEntry."Expected Cost" and (GetCostingQty = GetCostingInvQty)); // P8000338A
    end;

    local procedure CalcAvgCost(OutbndValueEntry: Record "Value Entry"; var CostElementBuf: Record "Cost Element Buffer"; var ExcludedValueEntry: Record "Value Entry"): Boolean
    var
        ValueEntry: Record "Value Entry";
        RoundingError: Decimal;
        RoundingErrorACY: Decimal;
    begin
        with ValueEntry do begin
            if OutbndValueEntry."Entry No." >= AvgCostBuf."Last Valid Value Entry No" then begin
                SumCostsTillValuationDate(OutbndValueEntry);
                TempInvtAdjmtBuf.SumCostsTillValuationDate(OutbndValueEntry);
                CostElementBuf."Remaining Quantity" := "Item Ledger Entry Quantity";
                CostElementBuf."Actual Cost" :=
                  "Cost Amount (Actual)" + "Cost Amount (Expected)" +
                  TempInvtAdjmtBuf."Cost Amount (Actual)" + TempInvtAdjmtBuf."Cost Amount (Expected)";
                CostElementBuf."Actual Cost (ACY)" :=
                  "Cost Amount (Actual) (ACY)" + "Cost Amount (Expected) (ACY)" +
                  TempInvtAdjmtBuf."Cost Amount (Actual) (ACY)" + TempInvtAdjmtBuf."Cost Amount (Expected) (ACY)";

                RoundingError := 0;
                RoundingErrorACY := 0;

                ExcludeAvgCostOnValuationDate(CostElementBuf, OutbndValueEntry, ExcludedValueEntry);
                AvgCostBuf.UpdateAvgCostBuffer(
                  CostElementBuf, GetLastValidValueEntry(OutbndValueEntry."Entry No."));
            end else
                CostElementBuf.UpdateCostElementBuffer(AvgCostBuf);

            if CostElementBuf."Remaining Quantity" > 0 then begin
                AvgCostBuf."Rounding Residual" := RoundingError;
                AvgCostBuf."Rounding Residual (ACY)" := RoundingErrorACY;
                RoundCost(
                  CostElementBuf."Actual Cost", AvgCostBuf."Rounding Residual", CostElementBuf."Actual Cost",
                  OutbndValueEntry."Valued Quantity" / CostElementBuf."Remaining Quantity",
                  GLSetup."Amount Rounding Precision");
                RoundCost(
                  CostElementBuf."Actual Cost (ACY)", AvgCostBuf."Rounding Residual (ACY)", CostElementBuf."Actual Cost (ACY)",
                  OutbndValueEntry."Valued Quantity" / CostElementBuf."Remaining Quantity",
                  Currency."Amount Rounding Precision");

                AvgCostBuf.DeductOutbndValueEntryFromBuf(OutbndValueEntry, CostElementBuf, IsAvgCostCalcTypeItem);
            end;

            exit(CostElementBuf."Remaining Quantity" > 0);
        end;
    end;

    local procedure ExcludeAvgCostOnValuationDate(var CostElementBuf: Record "Cost Element Buffer"; OutbndValueEntry: Record "Value Entry"; var ExcludedValueEntry: Record "Value Entry")
    var
        OutbndItemLedgEntry: Record "Item Ledger Entry";
        ItemApplnEntry: Record "Item Application Entry";
        TempItemLedgEntryInChain: Record "Item Ledger Entry" temporary;
        FirstValueEntry: Record "Value Entry";
        AvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point";
        ExcludeILE: Boolean;
        ExcludeEntry: Boolean;
        FixedApplication: Boolean;
        PreviousILENo: Integer;
        RevalFixedApplnQty: Decimal;
        ExclusionFactor: Decimal;
    begin
        with ExcludedValueEntry do begin
            SetCurrentKey("Item Ledger Entry No.", "Entry Type");
            OutbndItemLedgEntry.Get(OutbndValueEntry."Item Ledger Entry No.");
            ItemApplnEntry.GetVisitedEntries(OutbndItemLedgEntry, TempItemLedgEntryInChain, true);
            OnAfterGetVisitedEntries(ExcludedValueEntry, OutbndValueEntry, TempItemLedgEntryInChain);

            TempItemLedgEntryInChain.Reset();
            TempItemLedgEntryInChain.SetCurrentKey("Item No.", Positive, "Location Code", "Variant Code");
            TempItemLedgEntryInChain.SetRange("Item No.", "Item No.");
            TempItemLedgEntryInChain.SetRange(Positive, true);
            if not AvgCostAdjmtEntryPoint.IsAvgCostCalcTypeItem("Valuation Date") then begin
                TempItemLedgEntryInChain.SetRange("Location Code", "Location Code");
                TempItemLedgEntryInChain.SetRange("Variant Code", "Variant Code");
            end;
            OnExcludeAvgCostOnValuationDateOnAfterSetItemLedgEntryInChainFilters(TempItemLedgEntryInChain);

            if FindSet() then
                repeat
                    // Execute this block for the first Value Entry for each ILE
                    if PreviousILENo <> "Item Ledger Entry No." then begin
                        // Calculate whether a Value Entry should be excluded from average cost calculation based on ILE information
                        // All fixed application entries (except revaluation) are included in the buffer because the inbound and outbound entries cancel each other
                        FixedApplication := false;
                        ExcludeILE := IsExcludeILEFromAvgCostCalc(ExcludedValueEntry, OutbndValueEntry, TempItemLedgEntryInChain, FixedApplication);
                        PreviousILENo := "Item Ledger Entry No.";
                        if ("Entry Type" = "Entry Type"::"Direct Cost") and ("Item Charge No." = '') then
                            FirstValueEntry := ExcludedValueEntry
                        else begin
                            FirstValueEntry.SetRange("Item Ledger Entry No.", "Item Ledger Entry No.");
                            FirstValueEntry.SetRange("Entry Type", "Entry Type"::"Direct Cost");
                            FirstValueEntry.SetRange("Item Charge No.", '');
                            FirstValueEntry.FindFirst();
                        end;
                    end;

                    ExcludeEntry := ExcludeILE;

                    if FixedApplication then begin
                        // If a revaluation entry should normally be excluded, but has a partial fixed application to an outbound, then the fixed applied portion should still be included in the buffer
                        if "Entry Type" = "Entry Type"::Revaluation then begin
                            if IsExcludeFromAvgCostForRevalPoint(ExcludedValueEntry, OutbndValueEntry) then begin
                                RevalFixedApplnQty := CalcRevalFixedApplnQty(ExcludedValueEntry);
                                if RevalFixedApplnQty <> "Valued Quantity" then begin
                                    ExcludeEntry := true;
                                    ExclusionFactor := ("Valued Quantity" - RevalFixedApplnQty) / "Valued Quantity";
                                    "Cost Amount (Actual)" := RoundAmt(ExclusionFactor * "Cost Amount (Actual)", GLSetup."Amount Rounding Precision");
                                    "Cost Amount (Expected)" :=
                                      RoundAmt(ExclusionFactor * "Cost Amount (Expected)", GLSetup."Amount Rounding Precision");
                                    "Cost Amount (Actual) (ACY)" :=
                                      RoundAmt(ExclusionFactor * "Cost Amount (Actual) (ACY)", Currency."Amount Rounding Precision");
                                    "Cost Amount (Expected) (ACY)" :=
                                      RoundAmt(ExclusionFactor * "Cost Amount (Expected) (ACY)", Currency."Amount Rounding Precision");
                                end;
                            end;
                        end
                    end else
                        // For non-fixed applied entries
                        // For each value entry, perform additional check if there has been a revaluation in the period
                        if not ExcludeEntry then
                            // For non-revaluation entries, exclusion decision is based on the date of the first posted Direct Cost entry for the ILE to ensure all cost modifiers except revaluation
                            // are included or excluded based on the original item posting date
                            if "Entry Type" = "Entry Type"::Revaluation then
                                ExcludeEntry := IsExcludeFromAvgCostForRevalPoint(ExcludedValueEntry, OutbndValueEntry)
                            else
                                ExcludeEntry := IsExcludeFromAvgCostForRevalPoint(FirstValueEntry, OutbndValueEntry);

                    if ExcludeEntry then begin
                        CostElementBuf.ExcludeEntryFromAvgCostCalc(ExcludedValueEntry);
                        if TempInvtAdjmtBuf.Get("Entry No.") then
                            CostElementBuf.ExcludeBufFromAvgCostCalc(TempInvtAdjmtBuf);
                    end;
                until Next() = 0;
        end;
    end;

    local procedure IsExcludeILEFromAvgCostCalc(ValueEntry: Record "Value Entry"; OutbndValueEntry: Record "Value Entry"; var ItemLedgEntryInChain: Record "Item Ledger Entry"; var FixedApplication: Boolean): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        with ValueEntry do begin
            if TempOpenItemLedgEntry.Get("Item Ledger Entry No.") then
                exit(true);

            // fixed application is taken out
            if TempFixApplBuffer.Get("Item Ledger Entry No.") then begin
                FixedApplication := true;
                exit(false);
            end;

            if "Item Ledger Entry No." = OutbndValueEntry."Item Ledger Entry No." then
                exit(true);

            ItemLedgEntry.Get("Item Ledger Entry No.");

            if IsOutputWithSelfConsumption(ValueEntry, OutbndValueEntry, ItemLedgEntryInChain) then
                exit(true);

            if ItemLedgEntryInChain.Get("Item Ledger Entry No.") then
                exit(true);

            if not "Valued By Average Cost" then
                exit(false);

            if not ItemLedgEntryInChain.IsEmpty() then
                exit(true);

            if not ItemLedgEntry.Positive then
                exit("Item Ledger Entry No." > OutbndValueEntry."Item Ledger Entry No.");

            exit(false);
        end;
    end;

    local procedure IsExcludeFromAvgCostForRevalPoint(var RevaluationCheckValueEntry: Record "Value Entry"; var OutbndValueEntry: Record "Value Entry"): Boolean
    begin
        TempRevaluationPoint.SetRange(Number, RevaluationCheckValueEntry."Entry No.", OutbndValueEntry."Entry No.");
        if not TempRevaluationPoint.IsEmpty() then
            exit(not IncludedInCostCalculation(RevaluationCheckValueEntry, OutbndValueEntry."Item Ledger Entry No."));

        TempRevaluationPoint.SetRange(Number, OutbndValueEntry."Entry No.", RevaluationCheckValueEntry."Entry No.");
        if not TempRevaluationPoint.IsEmpty() then
            exit(true);
    end;

    local procedure CalcRevalFixedApplnQty(RevaluationValueEntry: Record "Value Entry"): Decimal
    var
        ItemApplicationEntry: Record "Item Application Entry";
        FixedApplQty: Decimal;
    begin
        ItemApplicationEntry.SetRange("Inbound Item Entry No.", RevaluationValueEntry."Item Ledger Entry No.");
        ItemApplicationEntry.SetFilter("Outbound Item Entry No.", '<>%1', 0);
        if ItemApplicationEntry.FindSet() then
            repeat
                if IncludedInCostCalculation(RevaluationValueEntry, ItemApplicationEntry."Outbound Item Entry No.") and
                   TempFixApplBuffer.Get(ItemApplicationEntry."Outbound Item Entry No.")
                then
                    FixedApplQty -= ItemApplicationEntry.Quantity;
            until ItemApplicationEntry.Next() = 0;

        exit(FixedApplQty);
    end;

    local procedure UpdateAvgCostAdjmtEntryPoint(ValueEntry: Record "Value Entry")
    var
        AvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point";
    begin
        StartWriteTransaction; // P8001227
        AvgCostAdjmtEntryPoint.UpdateValuationDate(ValueEntry);
    end;

    local procedure UpdateConsumpAvgEntry(ValueEntry: Record "Value Entry")
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ConsumpItemLedgEntry: Record "Item Ledger Entry";
        AvgCostAdjmtPoint: Record "Avg. Cost Adjmt. Entry Point";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateConsumpAvgEntry(ValueEntry, IsHandled);
        if IsHandled then
            exit;

        // Determine if average costed consumption is completely invoiced
        with ValueEntry do begin
            if "Item Ledger Entry Type" <> "Item Ledger Entry Type"::Consumption then
                exit;

            ConsumpItemLedgEntry.Get("Item Ledger Entry No.");
            if not ConsumpItemLedgEntry."Completely Invoiced" then
                if not IsDeletedItem then begin
                    ItemLedgEntry.SetCurrentKey("Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");
                    ItemLedgEntry.SetRange("Item No.", "Item No.");
                    if not AvgCostAdjmtPoint.IsAvgCostCalcTypeItem("Valuation Date") then begin
                        ItemLedgEntry.SetRange("Variant Code", "Variant Code");
                        ItemLedgEntry.SetRange("Location Code", "Location Code");
                    end;
                    ItemLedgEntry.SetRange("Posting Date", 0D, "Valuation Date");
                    OnUpdateConsumpAvgEntryOnAfterSetItemLedgEntryFilters(ItemLedgEntry);
                    // PR4.00 Begin
                    if Item.CostInAlternateUnits then begin
                        ItemLedgEntry.CalcSums("Invoiced Quantity (Alt.)");
                        ItemLedgEntry."Invoiced Quantity" := ItemLedgEntry."Invoiced Quantity (Alt.)";
                    end else
                        // PR4.00 End
                        ItemLedgEntry.CalcSums("Invoiced Quantity");
                    if ItemLedgEntry."Invoiced Quantity" >= 0 then begin
                        StartILEWriteTransaction(ConsumpItemLedgEntry); // P8001227
                        ConsumpItemLedgEntry.SetCompletelyInvoiced();
                        ConsumpItemLedgEntry.SetAppliedEntryToAdjust(false);
                    end;
                end else begin
                    StartILEWriteTransaction(ConsumpItemLedgEntry); // P8001227
                    ConsumpItemLedgEntry.SetCompletelyInvoiced();
                    ConsumpItemLedgEntry.SetAppliedEntryToAdjust(false);
                end;
        end;
    end;

    local procedure ForwardAvgCostToInbndEntries(ItemLedgEntryNo: Integer; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        with ItemApplnEntry do begin
            if AppliedInbndEntryExists(ItemLedgEntryNo, true) then
                repeat
                    LevelNo[3] := 0;
                    AdjustAppliedInbndEntries(ItemApplnEntry, TempAvgCostAdjmtEntryPoint); // P80066030
                    if LevelExceeded then begin
                        LevelExceeded := false;

                        UpDateWindow(WindowAdjmtLevel, WindowItem, WindowAdjust, LevelNo[3], WindowEntry, WindowOutbndEntry);
                        AdjustItemAppliedCost(TempAvgCostAdjmtEntryPoint); // P80066030
                        UpDateWindow(WindowAdjmtLevel, WindowItem, Text008, WindowFWLevel, WindowEntry, WindowOutbndEntry);
                    end;
                until Next() = 0;
        end;
    end;

    local procedure WIPToAdjustExist(var ToInventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"): Boolean
    var
        InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)";
    begin
        with InventoryAdjmtEntryOrder do begin
            Reset();
            SetCurrentKey("Cost is Adjusted", "Allow Online Adjustment");
            SetRange("Cost is Adjusted", false);
            SetRange("Order Type", "Order Type"::Production);
            SetRange("Is Finished", true);
            if IsOnlineAdjmt then
                SetRange("Allow Online Adjustment", true);

            OnWIPToAdjustExistOnAfterInventoryAdjmtEntryOrderSetFilters(InventoryAdjmtEntryOrder);
            CopyOrderAdmtEntryToOrderAdjmt(InventoryAdjmtEntryOrder, ToInventoryAdjmtEntryOrder);
            exit(ToInventoryAdjmtEntryOrder.FindFirst())
        end;
    end;

    local procedure MakeWIPAdjmt(var SourceInvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    var
        InvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)";
        CalcInventoryAdjmtOrder: Codeunit "Calc. Inventory Adjmt. - Order";
        DoNotSkipItems: Boolean;
    begin
        DoNotSkipItems := FilterItem.GetFilters = '';
        with SourceInvtAdjmtEntryOrder do
            if FindSet() then
                repeat
                    if true in [DoNotSkipItems, ItemInFilteredSetExists("Item No.", FilterItem)] then begin
                        GetItem("Item No.");
                        UpDateWindow(WindowAdjmtLevel, "Item No.", Text009, 0, 0, 0);

                        InvtAdjmtEntryOrder := SourceInvtAdjmtEntryOrder;
                        CalcInventoryAdjmtOrder.Calculate(SourceInvtAdjmtEntryOrder, TempInvtAdjmtBuf);
                        PostOutputAdjmtBuf(TempAvgCostAdjmtEntryPoint);

                        StartWriteTransaction; // P8001227
                        if not "Completely Invoiced" then begin
                            InvtAdjmtEntryOrder.GetUnitCostsFromItem();
                            InvtAdjmtEntryOrder."Completely Invoiced" := true;
                        end;
                        InvtAdjmtEntryOrder."Cost is Adjusted" := true;
                        InvtAdjmtEntryOrder."Allow Online Adjustment" := true;
                        InvtAdjmtEntryOrder.Modify();
                        EndWriteTransaction(TempAvgCostAdjmtEntryPoint); // P8001227, P80066030
                    end;
                until Next() = 0;
    end;

    local procedure ItemInFilteredSetExists(ItemNo: Code[20]; var FilteredItem: Record Item): Boolean
    var
        TempItem: Record Item temporary;
        Item: Record Item;
    begin
        with TempItem do begin
            if not Item.Get(ItemNo) then
                exit(false);
            CopyFilters(FilteredItem);
            TempItem := Item;
            Insert();
            exit(not IsEmpty);
        end;
    end;

    local procedure PostOutputAdjmtBuf(var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    begin
        with TempInvtAdjmtBuf do begin
            Reset();
            if FindSet() then
                repeat
                    PostOutput(TempInvtAdjmtBuf, TempAvgCostAdjmtEntryPoint);
                until Next() = 0;
            DeleteAll();
        end;
    end;

    local procedure PostOutput(InvtAdjmtBuf: Record "Inventory Adjustment Buffer"; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    var
        ItemJnlLine: Record "Item Journal Line";
        OrigItemLedgEntry: Record "Item Ledger Entry";
        OrigValueEntry: Record "Value Entry";
        IsHandled: Boolean;
    begin
        OrigValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
        OrigValueEntry.SetRange("Item Ledger Entry No.", TempInvtAdjmtBuf."Item Ledger Entry No.");
        OrigValueEntry.FindFirst();

        with OrigValueEntry do begin
            ItemJnlLine.Init();
            OrigItemLedgEntry.Get("Item Ledger Entry No."); // P8001260
            ItemJnlLine."Value Entry Type" := InvtAdjmtBuf."Entry Type";
            ItemJnlLine."Variance Type" := InvtAdjmtBuf."Variance Type";
            ItemJnlLine."Invoiced Quantity" := OrigItemLedgEntry.Quantity;             // P8001260
            ItemJnlLine."Invoiced Qty. (Base)" := OrigItemLedgEntry.Quantity;          // P8001260
            ItemJnlLine."Invoiced Qty. (Alt.)" := OrigItemLedgEntry."Quantity (Alt.)"; // P8001260
            ItemJnlLine."Qty. per Unit of Measure" := 1;
            ItemJnlLine."Source Type" := "Source Type";
            ItemJnlLine."Source No." := "Source No.";
            ItemJnlLine.Description := Description;
            ItemJnlLine.Adjustment := "Order Type" = "Order Type"::Assembly;
            //OrigItemLedgEntry.GET("Item Ledger Entry No."); // P8001260
            ItemJnlLine.Adjustment := ("Order Type" = "Order Type"::Assembly) and (OrigItemLedgEntry."Invoiced Quantity" <> 0);

            if OrigItemLedgEntry.IsBOMOrderType() then begin // P8001134, P80074083
                ItemJnlLine.Adjustment := true;          // P8001134
                                                         // P80074083
                ItemJnlLine."Quantity (Base)" := OrigValueEntry."Valued Quantity";
                ItemJnlLine."Invoiced Qty. (Base)" := OrigValueEntry."Invoiced Quantity";
            end;
            // P80074083
            IsHandled := false;
            StartWriteTransaction; // P8001227
            OnPostOutputOnBeforePostItemJnlLine(ItemJnlLine, OrigValueEntry, InvtAdjmtBuf, GLSetup, IsHandled);
            if not IsHandled then
                PostItemJnlLine(ItemJnlLine, OrigValueEntry, InvtAdjmtBuf."Cost Amount (Actual)", InvtAdjmtBuf."Cost Amount (Actual) (ACY)");

            if ProcessFns.AltQtyInstalled then                               // PR3.60
                AltQtyMgmt.UpdateOutputAltQtyEntries("Item Ledger Entry No."); // PR3.60

            OrigItemLedgEntry.Get("Item Ledger Entry No.");
            if not OrigItemLedgEntry."Completely Invoiced" then
                // OrigItemLedgEntry.SetCompletelyInvoiced(); // P8001227
                WriteCompletelyInvoiced(OrigItemLedgEntry);   // P8001227

            InsertEntryPointToUpdate(TempAvgCostAdjmtEntryPoint, "Item No.", "Variant Code", "Location Code");
        end;
    end;

    local procedure AssemblyToAdjustExists(var ToInventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"): Boolean
    var
        InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)";
    begin
        with InventoryAdjmtEntryOrder do begin
            Reset();
            SetCurrentKey("Cost is Adjusted", "Allow Online Adjustment");
            SetRange("Cost is Adjusted", false);
            SetRange("Order Type", "Order Type"::Assembly);
            if IsOnlineAdjmt then
                SetRange("Allow Online Adjustment", true);

            CopyOrderAdmtEntryToOrderAdjmt(InventoryAdjmtEntryOrder, ToInventoryAdjmtEntryOrder);
            exit(ToInventoryAdjmtEntryOrder.FindFirst())
        end;
    end;

    local procedure MakeAssemblyAdjmt(var SourceInvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    var
        InvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)";
        CalcInventoryAdjmtOrder: Codeunit "Calc. Inventory Adjmt. - Order";
        DoNotSkipItems: Boolean;
    begin
        DoNotSkipItems := FilterItem.GetFilters = '';
        with SourceInvtAdjmtEntryOrder do
            if FindSet() then
                repeat
                    if true in [DoNotSkipItems, ItemInFilteredSetExists("Item No.", FilterItem)] then begin
                        GetItem("Item No.");
                        UpDateWindow(WindowAdjmtLevel, "Item No.", Text010, 0, 0, 0);

                        InvtAdjmtEntryOrder := SourceInvtAdjmtEntryOrder;
                        if not Item."Inventory Value Zero" then begin
                            CalcInventoryAdjmtOrder.Calculate(SourceInvtAdjmtEntryOrder, TempInvtAdjmtBuf);
                            PostOutputAdjmtBuf(TempAvgCostAdjmtEntryPoint);
                        end;

                        StartWriteTransaction; // P8001227
                        if not "Completely Invoiced" then begin
                            InvtAdjmtEntryOrder.GetCostsFromItem(1);
                            InvtAdjmtEntryOrder."Completely Invoiced" := true;
                        end;
                        InvtAdjmtEntryOrder."Allow Online Adjustment" := true;
                        InvtAdjmtEntryOrder."Cost is Adjusted" := true;
                        InvtAdjmtEntryOrder.Modify();
                        EndWriteTransaction(TempAvgCostAdjmtEntryPoint); // P8001227, P80066030
                    end;
                until Next() = 0;
    end;

    local procedure UpdateAdjmtBuf(OrigValueEntry: Record "Value Entry"; NewAdjustedCost: Decimal; NewAdjustedCostACY: Decimal; ItemLedgEntryPostingDate: Date; EntryType: Enum "Cost Entry Type") Result: Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemApplnEntry: Record "Item Application Entry";
        SourceOrigValueEntry: Record "Value Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateAdjmtBuf(OrigValueEntry, NewAdjustedCost, NewAdjustedCostACY, ItemLedgEntryPostingDate, EntryType, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if not HasNewCost(NewAdjustedCost, NewAdjustedCostACY) then
            exit(false);

        if OrigValueEntry."Valued By Average Cost" then begin
            TempAvgCostRndgBuf.UpdRoundingCheck(
              OrigValueEntry."Item Ledger Entry No.", NewAdjustedCost, NewAdjustedCostACY,
              GLSetup."Amount Rounding Precision", Currency."Amount Rounding Precision");
            if TempAvgCostRndgBuf."No. of Hits" > 42 then
                exit(false);
        end;

        UpdateValuationPeriodHasOutput(OrigValueEntry);

        TempInvtAdjmtBuf.AddActualCostBuf(OrigValueEntry, NewAdjustedCost, NewAdjustedCostACY, ItemLedgEntryPostingDate);

        if EntryType = OrigValueEntry."Entry Type"::Variance then begin
            GetOrigValueEntry(SourceOrigValueEntry, OrigValueEntry, EntryType);
            TempInvtAdjmtBuf."Entry Type" := EntryType;
            TempInvtAdjmtBuf."Variance Type" := SourceOrigValueEntry."Variance Type";
            TempInvtAdjmtBuf.Modify();
        end;

        if not OrigValueEntry."Expected Cost" and
           (OrigValueEntry."Entry Type" = OrigValueEntry."Entry Type"::"Direct Cost")
        then begin
            CalcExpectedCostToBalance(OrigValueEntry, NewAdjustedCost, NewAdjustedCostACY);
            if HasNewCost(NewAdjustedCost, NewAdjustedCostACY) then
                TempInvtAdjmtBuf.AddBalanceExpectedCostBuf(OrigValueEntry, NewAdjustedCost, NewAdjustedCostACY);
        end;

        if OrigValueEntry."Item Ledger Entry Quantity" >= 0 then begin
            ItemLedgEntry.Get(OrigValueEntry."Item Ledger Entry No.");
            StartWriteTransaction; // P8001227
            ItemApplnEntry.SetOutboundsNotUpdated(ItemLedgEntry);
        end;
        exit(true);
    end;

    local procedure CalcExpectedCostToBalance(OrigValueEntry: Record "Value Entry"; var ExpectedCost: Decimal; var ExpectedCostACY: Decimal)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ShareOfTotalCost: Decimal;
    begin
        ExpectedCost := 0;
        ExpectedCostACY := 0;
        ItemLedgEntry.Get(OrigValueEntry."Item Ledger Entry No.");

        with TempInvtAdjmtBuf do begin
            Reset();
            SetCurrentKey("Item Ledger Entry No.");
            SetRange("Item Ledger Entry No.", OrigValueEntry."Item Ledger Entry No.");
            if FindFirst() and "Expected Cost" then begin
                CalcSums("Cost Amount (Expected)", "Cost Amount (Expected) (ACY)");

                // IF ItemLedgEntry.Quantity = ItemLedgEntry."Invoiced Quantity" THEN BEGIN // PR4.00
                if ItemLedgEntry.GetCostingQty = ItemLedgEntry.GetCostingInvQty then begin  // PR4.00
                    ExpectedCost := -"Cost Amount (Expected)";
                    ExpectedCostACY := -"Cost Amount (Expected) (ACY)";
                end else begin
                    // PR4.00 Begin
                    if ItemLedgEntry.GetCostingQty = 0 then
                        ShareOfTotalCost := 0
                    else
                        ShareOfTotalCost := OrigValueEntry."Invoiced Quantity" / ItemLedgEntry.GetCostingQty;
                    // ShareOfTotalCost := OrigValueEntry."Invoiced Quantity" / ItemLedgEntry.Quantity;
                    // PR4.00 End
                    ExpectedCost :=
                      -RoundAmt("Cost Amount (Expected)" * ShareOfTotalCost, GLSetup."Amount Rounding Precision");
                    ExpectedCostACY :=
                      -RoundAmt("Cost Amount (Expected) (ACY)" * ShareOfTotalCost, Currency."Amount Rounding Precision");
                end;
            end;
        end;
    end;

    local procedure PostAdjmtBuf(var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    var
        ItemJnlLine: Record "Item Journal Line";
        OrigValueEntry: Record "Value Entry";
    begin
        with TempInvtAdjmtBuf do begin
            Reset();
            if FindSet() then begin
                repeat
                    OrigValueEntry.Get("Entry No.");
                    InsertEntryPointToUpdate(
                      TempAvgCostAdjmtEntryPoint, OrigValueEntry."Item No.", OrigValueEntry."Variant Code", OrigValueEntry."Location Code");
                    if OrigValueEntry."Expected Cost" then begin
                        if HasNewCost("Cost Amount (Expected)", "Cost Amount (Expected) (ACY)") then begin
                            InitAdjmtJnlLine(ItemJnlLine, OrigValueEntry, "Entry Type", "Variance Type", OrigValueEntry."Invoiced Quantity");
                            PostItemJnlLine(ItemJnlLine, OrigValueEntry, "Cost Amount (Expected)", "Cost Amount (Expected) (ACY)");
                        end
                    end else
                        if HasNewCost("Cost Amount (Actual)", "Cost Amount (Actual) (ACY)") then begin
                            if HasNewCost("Cost Amount (Expected)", "Cost Amount (Expected) (ACY)") then begin
                                InitAdjmtJnlLine(ItemJnlLine, OrigValueEntry, "Entry Type", "Variance Type", 0);
                                PostItemJnlLine(ItemJnlLine, OrigValueEntry, "Cost Amount (Expected)", "Cost Amount (Expected) (ACY)");
                            end;
                            InitAdjmtJnlLine(ItemJnlLine, OrigValueEntry, "Entry Type", "Variance Type", OrigValueEntry."Invoiced Quantity");
                            PostItemJnlLine(ItemJnlLine, OrigValueEntry, "Cost Amount (Actual)", "Cost Amount (Actual) (ACY)");
                        end;
                until Next() = 0;
                DeleteAll();
            end;
        end;
    end;

    local procedure InitAdjmtJnlLine(var ItemJnlLine: Record "Item Journal Line"; OrigValueEntry: Record "Value Entry"; EntryType: Enum "Cost Entry Type"; VarianceType: Enum "Cost Variance Type"; InvoicedQty: Decimal)
    begin
        with OrigValueEntry do begin
            ItemJnlLine."Value Entry Type" := EntryType;
            ItemJnlLine."Partial Revaluation" := "Partial Revaluation";
            ItemJnlLine.Description := Description;
            ItemJnlLine."Source Posting Group" := "Source Posting Group";
            ItemJnlLine."Source No." := "Source No.";
            ItemJnlLine."Salespers./Purch. Code" := "Salespers./Purch. Code";
            ItemJnlLine."Source Type" := "Source Type";
            ItemJnlLine."Reason Code" := "Reason Code";
            ItemJnlLine."Drop Shipment" := "Drop Shipment";
            ItemJnlLine."Document Date" := "Document Date";
            ItemJnlLine."External Document No." := "External Document No.";
            ItemJnlLine."Quantity (Base)" := "Valued Quantity";
            ItemJnlLine."Invoiced Qty. (Base)" := InvoicedQty;
            if "Item Ledger Entry Type" = "Item Ledger Entry Type"::Output then
                ItemJnlLine."Output Quantity (Base)" := ItemJnlLine."Quantity (Base)";
            ItemJnlLine."Item Charge No." := "Item Charge No.";
            ItemJnlLine."Variance Type" := VarianceType;
            ItemJnlLine.Adjustment := true;
            ItemJnlLine."Applies-to Value Entry" := "Entry No.";
            ItemJnlLine."Return Reason Code" := "Return Reason Code";
        end;

        OnAfterInitAdjmtJnlLine(ItemJnlLine, OrigValueEntry, EntryType, VarianceType, InvoicedQty);
    end;

    local procedure PostItemJnlLine(ItemJnlLine: Record "Item Journal Line"; OrigValueEntry: Record "Value Entry"; NewAdjustedCost: Decimal; NewAdjustedCostACY: Decimal)
    var
        InvtPeriod: Record "Inventory Period";
        CostingQty: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostItemJnlLine(ItemJnlLine, OrigValueEntry, NewAdjustedCost, NewAdjustedCostACY, SkipUpdateJobItemCost, IsHandled);
        if IsHandled then
            exit;

        with OrigValueEntry do begin
            ItemJnlLine."Item No." := "Item No.";
            ItemJnlLine."Location Code" := "Location Code";
            ItemJnlLine."Variant Code" := "Variant Code";

            if GLSetup.IsPostingAllowed("Posting Date") and InvtPeriod.IsValidDate("Posting Date") then
                ItemJnlLine."Posting Date" := "Posting Date"
            else
                ItemJnlLine."Posting Date" := PostingDateForClosedPeriod;
            OnPostItemJnlLineOnAfterSetPostingDate(ItemJnlLine, OrigValueEntry, PostingDateForClosedPeriod, Item);

            ItemJnlLine."Entry Type" := "Item Ledger Entry Type";
            ItemJnlLine."Document No." := "Document No.";
            ItemJnlLine."Document Type" := "Document Type";
            ItemJnlLine."Document Line No." := "Document Line No.";
            ItemJnlLine."Source Currency Code" := GLSetup."Additional Reporting Currency";
            ItemJnlLine."Source Code" := SourceCodeSetup."Adjust Cost";
            ItemJnlLine."Inventory Posting Group" := "Inventory Posting Group";
            ItemJnlLine."Gen. Bus. Posting Group" := "Gen. Bus. Posting Group";
            ItemJnlLine."Gen. Prod. Posting Group" := "Gen. Prod. Posting Group";
            ItemJnlLine."Order Type" := "Order Type";
            ItemJnlLine."Order No." := "Order No.";
            ItemJnlLine."Order Line No." := "Order Line No.";
            ItemJnlLine."Job No." := "Job No.";
            ItemJnlLine."Job Task No." := "Job Task No.";
            ItemJnlLine.Type := Type;
            if ItemJnlLine."Value Entry Type" = ItemJnlLine."Value Entry Type"::"Direct Cost" then
                ItemJnlLine."Item Shpt. Entry No." := "Item Ledger Entry No."
            else
                ItemJnlLine."Applies-to Entry" := "Item Ledger Entry No.";
            ItemJnlLine.Amount := NewAdjustedCost;
            ItemJnlLine."Amount (ACY)" := NewAdjustedCostACY;

            CostingQty := ItemJnlLine.GetCostingQty(ItemJnlLine.FieldNo("Quantity (Base)")); // PR4.00
                                                                                             // IF ItemJnlLine."Quantity (Base)" <> 0 THEN BEGIN                              // PR4.00
            if CostingQty <> 0 then begin                                                    // PR4.00
                ItemJnlLine."Unit Cost" :=
                  // RoundAmt(NewAdjustedCost / ItemJnlLine."Quantity (Base)",GLSetup."Unit-Amount Rounding Precision"); // PR4.00
                  RoundAmt(NewAdjustedCost / CostingQty, GLSetup."Unit-Amount Rounding Precision");                       // PR4.00
                ItemJnlLine."Unit Cost (ACY)" :=
                  // RoundAmt(NewAdjustedCostACY / ItemJnlLine."Quantity (Base)",Currency."Unit-Amount Rounding Precision"); // PR4.00
                  RoundAmt(NewAdjustedCostACY / CostingQty, Currency."Unit-Amount Rounding Precision");                       // PR4.00
            end;

            ItemJnlLine."Shortcut Dimension 1 Code" := "Global Dimension 1 Code";
            ItemJnlLine."Shortcut Dimension 2 Code" := "Global Dimension 2 Code";
            ItemJnlLine."Dimension Set ID" := "Dimension Set ID";

            StartWriteTransaction; // P8001227
            if not SkipUpdateJobItemCost and ("Job No." <> '') then
                CopyJobToAdjustmentBuf("Job No.");

            OnPostItemJnlLineCopyFromValueEntry(ItemJnlLine, OrigValueEntry);
            ItemJnlPostLine.RunWithCheck(ItemJnlLine);
            OnPostItemJnlLineOnAfterItemJnlPostLineRunWithCheck(ItemJnlLine, OrigValueEntry);
        end;
    end;

    local procedure RoundCost(var Cost: Decimal; var RndgResidual: Decimal; TotalCost: Decimal; ShareOfTotalCost: Decimal; AmtRndgPrec: Decimal)
    var
        UnroundedCost: Decimal;
    begin
        UnroundedCost := TotalCost * ShareOfTotalCost + RndgResidual;
        Cost := RoundAmt(UnroundedCost, AmtRndgPrec);
        RndgResidual := UnroundedCost - Cost;
    end;

    local procedure RoundAmt(Amt: Decimal; AmtRndgPrec: Decimal): Decimal
    begin
        if Amt = 0 then
            exit(0);
        exit(Round(Amt, AmtRndgPrec))
    end;

    local procedure GetOrigValueEntry(var OrigValueEntry: Record "Value Entry"; ValueEntry: Record "Value Entry"; ValueEntryType: Enum "Cost Entry Type")
    var
        Found: Boolean;
        IsLastEntry: Boolean;
    begin
        with OrigValueEntry do begin
            SetCurrentKey("Item Ledger Entry No.", "Document No.");
            SetRange("Item Ledger Entry No.", ValueEntry."Item Ledger Entry No.");
            SetRange("Document No.", ValueEntry."Document No.");

            if FindSet() then
                repeat
                    if ("Expected Cost" = ValueEntry."Expected Cost") and
                       ("Entry Type" = ValueEntryType)
                    then begin
                        Found := true;
                        "Valued Quantity" := ValueEntry."Valued Quantity";
                        "Invoiced Quantity" := ValueEntry."Invoiced Quantity";
                        OnGetOrigValueEntryOnAfterOrigValueEntryFound(OrigValueEntry, ValueEntry);
                    end else
                        IsLastEntry := Next() = 0;
                until Found or IsLastEntry;

            if not Found then begin
                OrigValueEntry := ValueEntry;
                "Entry Type" := ValueEntryType;
                if ValueEntryType = "Entry Type"::Variance then
                    "Variance Type" := GetOrigVarianceType(ValueEntry);
            end;
        end;
    end;

    local procedure GetOrigVarianceType(ValueEntry: Record "Value Entry"): Enum "Cost Variance Type"
    begin
        with ValueEntry do begin
            if "Item Ledger Entry Type" in
               ["Item Ledger Entry Type"::Output, "Item Ledger Entry Type"::"Assembly Output"]
            then
                exit("Variance Type"::Material);

            exit("Variance Type"::Purchase);
        end;
    end;

    local procedure UpdateAppliedEntryToAdjustBuf(ItemLedgerEntry: Record "Item Ledger Entry"; AppliedEntryToAdjust: Boolean)
    begin
        if AppliedEntryToAdjust then begin
            TempItemLedgerEntryBuf := ItemLedgerEntry;
            if TempItemLedgerEntryBuf.Insert() then;
        end;
    end;

    local procedure SetAppliedEntryToAdjustFromBuf(ItemNo: Code[20])
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        with TempItemLedgerEntryBuf do begin
            Reset();
            if ItemNo <> '' then
                SetRange("Item No.", ItemNo);
            if FindSet() then
                repeat
                    if not ManagingLockTimes then // P8001227
                        ItemLedgEntry.Get("Entry No.");
                    ItemLedgEntry.SetAppliedEntryToAdjust(true);
                until Next() = 0;
        end;
    end;

    local procedure AppliedEntryToAdjustBufExists(ItemNo: Code[20]): Boolean
    begin
        TempItemLedgerEntryBuf.Reset();
        TempItemLedgerEntryBuf.SetRange("Item No.", ItemNo);
        exit(not TempItemLedgerEntryBuf.IsEmpty());
    end;

    local procedure UpdateItemUnitCost(var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary; IsFirstTime: Boolean)
    var
        AvgCostAdjmtPoint: Record "Avg. Cost Adjmt. Entry Point";
        FilterSKU: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateItemUnitCost(TempAvgCostAdjmtEntryPoint, IsHandled, Item, TempItemLedgerEntryBuf);
        if IsHandled then
            exit;

        with Item do begin
            if IsDeletedItem then
                exit;

            StartWriteTransaction(); // P8001227
            LockTable();
            Get("No.");
            OnUpdateItemUnitCostOnAfterItemGet(Item);
            if not LevelExceeded then begin
                "Allow Online Adjustment" := true;
                AvgCostAdjmtPoint.SetRange("Item No.", "No.");
                AvgCostAdjmtPoint.SetRange("Cost Is Adjusted", false);
                if "Costing Method" <> "Costing Method"::Average then begin
                    if AvgCostAdjmtPoint.FindFirst() then
                        AvgCostAdjmtPoint.ModifyAll("Cost Is Adjusted", true);
                end;
                "Cost is Adjusted" := AvgCostAdjmtPoint.IsEmpty();
                if "Cost is Adjusted" and ("Costing Method" <> "Costing Method"::Average) and IsFirstTime then begin
                    "Cost is Adjusted" := not AppliedEntryToAdjustBufExists("No.");
                    SetAppliedEntryToAdjustFromBuf("No.");
                end;
            end;

            if "Costing Method" <> "Costing Method"::Standard then begin
                if TempAvgCostAdjmtEntryPoint.FindSet() then
                    repeat
                        FilterSKU := (TempAvgCostAdjmtEntryPoint."Location Code" <> '') or (TempAvgCostAdjmtEntryPoint."Variant Code" <> '');
                        ItemCostMgt.UpdateUnitCost(
                          Item, TempAvgCostAdjmtEntryPoint."Location Code", TempAvgCostAdjmtEntryPoint."Variant Code", 0, 0, true, FilterSKU, false, 0);
                    until TempAvgCostAdjmtEntryPoint.Next() = 0
                else
                    Modify();
            end else begin
                OnUpdateItemUnitCostOnBeforeModifyItemNotStandardCostingMethod(Item);
                Modify();
                OnUpdateItemUnitCostOnAfterModifyItemNotStandardCostingMethod(Item);
            end;
        end;

        TempAvgCostAdjmtEntryPoint.Reset();
        TempAvgCostAdjmtEntryPoint.DeleteAll();
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        IsDeletedItem := ItemNo = '';
        if (Item."No." <> ItemNo) or IsDeletedItem then
            if not IsDeletedItem then
                Item.Get(ItemNo)
            else begin
                Clear(Item);
                Item.Init();
            end;
    end;

    local procedure InsertDeletedItem(var Item: Record Item)
    begin
        Clear(Item);
        Item.Init();
        Item."Cost is Adjusted" := false;
        Item."Costing Method" := Item."Costing Method"::FIFO;
        Item.Insert();
    end;

    local procedure IsAvgCostItem() AvgCostItem: Boolean
    begin
        AvgCostItem := Item."Costing Method" = Item."Costing Method"::Average;

        OnAfterIsAvgCostItem(Item, AvgCostItem);
    end;

    local procedure HasNewCost(NewCost: Decimal; NewCostACY: Decimal): Boolean
    begin
        exit((NewCost <> 0) or (NewCostACY <> 0));
    end;

    local procedure OpenWindow()
    var
        IsHandled: Boolean;
    begin
        if not GuiAllowed then // P8001227
            exit;                // P8001227

        IsHandled := false;
        OnBeforeOpenWindow(IsHandled);
        if IsHandled then
            exit;

        Window.Open(
          Text000 +
          '#1########################\\' +
          Text001 +
          Text003 +
          Text004 +
          Text005 +
          Text006);
        WindowIsOpen := true;
    end;

    local procedure UpDateWindow(NewWindowAdjmtLevel: Integer; NewWindowItem: Code[20]; NewWindowAdjust: Text[20]; NewWindowFWLevel: Integer; NewWindowEntry: Integer; NewWindowOutbndEntry: Integer)
    var
        IsHandled: Boolean;
    begin
        if not GuiAllowed then // P8001227
            exit;                // P8001227

        WindowAdjmtLevel := NewWindowAdjmtLevel;
        WindowItem := NewWindowItem;
        WindowAdjust := NewWindowAdjust;
        WindowFWLevel := NewWindowFWLevel;
        WindowEntry := NewWindowEntry;
        WindowOutbndEntry := NewWindowOutbndEntry;

        IsHandled := false;
        OnBeforeUpdateWindow(IsHandled);
        if IsHandled then
            exit;

        if IsTimeForUpdate() then begin
            if not WindowIsOpen then
                OpenWindow();
            Window.Update(1, StrSubstNo(Text002, TempInvtAdjmtBuf.FieldCaption("Item No."), WindowItem));
            Window.Update(2, WindowAdjmtLevel);
            Window.Update(3, WindowAdjust);
            Window.Update(4, WindowFWLevel);
            Window.Update(5, WindowEntry);
            Window.Update(6, WindowOutbndEntry);
        end;
    end;

    local procedure IsTimeForUpdate(): Boolean
    begin
        if CurrentDateTime - WindowUpdateDateTime >= 1000 then begin
            WindowUpdateDateTime := CurrentDateTime;
            exit(true);
        end;
        exit(false);
    end;

    local procedure CopyItemToItem(var FromItem: Record Item; var ToItem: Record Item)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyItemToItem(FromItem, ToItem, IsHandled);
        if IsHandled then
            exit;

        with ToItem do begin
            Reset();
            DeleteAll();
            if FromItem.FindSet() then
                repeat
                    ToItem := FromItem;
                    Insert();
                until FromItem.Next() = 0;
        end;
    end;

    local procedure CopyILEToILE(var FromItemLedgEntry: Record "Item Ledger Entry"; var ToItemLedgEntry: Record "Item Ledger Entry")
    begin
        with ToItemLedgEntry do begin
            Reset();
            DeleteAll();
            if FromItemLedgEntry.FindSet() then
                repeat
                    ToItemLedgEntry := FromItemLedgEntry;
                    if not TempItemLedgerEntryBuf.Get(ToItemLedgEntry."Entry No.") then // P8001227
                        Insert();
                until FromItemLedgEntry.Next() = 0;
        end;
    end;

    local procedure CopyAvgCostAdjmtToAvgCostAdjmt(var FromAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point"; var ToAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point")
    begin
        with ToAvgCostAdjmtEntryPoint do begin
            Reset();
            DeleteAll();
            if FromAvgCostAdjmtEntryPoint.FindSet() then
                repeat
                    ToAvgCostAdjmtEntryPoint := FromAvgCostAdjmtEntryPoint;
                    Insert();
                    OnCopyAvgCostAdjmtToAvgCostAdjmtOnAfterInsert(ToAvgCostAdjmtEntryPoint);
                until FromAvgCostAdjmtEntryPoint.Next() = 0;
        end;
    end;

    local procedure CopyOrderAdmtEntryToOrderAdjmt(var FromInventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; var ToInventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)")
    begin
        with ToInventoryAdjmtEntryOrder do begin
            Reset();
            DeleteAll();
            if FromInventoryAdjmtEntryOrder.FindSet() then
                repeat
                    ToInventoryAdjmtEntryOrder := FromInventoryAdjmtEntryOrder;
                    Insert();
                until FromInventoryAdjmtEntryOrder.Next() = 0;
        end;
    end;

    local procedure AdjustNotInvdRevaluation(TransItemLedgEntry: Record "Item Ledger Entry"; TransItemApplnEntry: Record "Item Application Entry")
    var
        TransValueEntry: Record "Value Entry";
        OrigItemLedgEntry: Record "Item Ledger Entry";
        CostElementBuf: Record "Cost Element Buffer";
        AdjustedCostElementBuf: Record "Cost Element Buffer";
    begin
        with TransValueEntry do
            if NotInvdRevaluationExists(TransItemLedgEntry."Entry No.") then begin
                GetOrigPosItemLedgEntryNo(TransItemApplnEntry);
                OrigItemLedgEntry.Get(TransItemApplnEntry."Item Ledger Entry No.");
                repeat
                    CalcTransEntryNewRevAmt(OrigItemLedgEntry, TransValueEntry, AdjustedCostElementBuf);
                    CalcTransEntryOldRevAmt(TransValueEntry, CostElementBuf);

                    UpdateAdjmtBuf(
                      TransValueEntry,
                      AdjustedCostElementBuf."Actual Cost" - CostElementBuf."Actual Cost",
                      AdjustedCostElementBuf."Actual Cost (ACY)" - CostElementBuf."Actual Cost (ACY)",
                      TransItemLedgEntry."Posting Date",
                      "Entry Type");
                until Next() = 0;
            end;
    end;

    local procedure GetOrigPosItemLedgEntryNo(var ItemApplnEntry: Record "Item Application Entry")
    begin
        with ItemApplnEntry do begin
            SetCurrentKey("Inbound Item Entry No.", "Item Ledger Entry No.");
            SetRange("Item Ledger Entry No.", "Transferred-from Entry No.");
            SetRange("Inbound Item Entry No.", "Transferred-from Entry No.");
            FindFirst();
            if "Transferred-from Entry No." <> 0 then
                GetOrigPosItemLedgEntryNo(ItemApplnEntry);
        end;
    end;

    local procedure CalcTransEntryNewRevAmt(ItemLedgEntry: Record "Item Ledger Entry"; TransValueEntry: Record "Value Entry"; var AdjustedCostElementBuf: Record "Cost Element Buffer")
    var
        ValueEntry: Record "Value Entry";
        InvdQty: Decimal;
        OrigInvdQty: Decimal;
        ShareOfRevExpAmt: Decimal;
        OrigShareOfRevExpAmt: Decimal;
    begin
        with ValueEntry do begin
            SetCurrentKey("Item Ledger Entry No.", "Entry Type");
            SetRange("Item Ledger Entry No.", ItemLedgEntry."Entry No.");
            SetRange("Entry Type", "Entry Type"::"Direct Cost");
            SetRange("Item Charge No.", '');
            if FindSet() then
                repeat
                    InvdQty := InvdQty + "Invoiced Quantity";
                    if "Entry No." < TransValueEntry."Entry No." then
                        OrigInvdQty := OrigInvdQty + "Invoiced Quantity";
                until Next() = 0;
            if ItemLedgEntry.GetCostingQty <> 0 then begin                                                  // PR4.00
                ShareOfRevExpAmt := (ItemLedgEntry.Quantity - InvdQty) / ItemLedgEntry.GetCostingQty;         // PR4.00
                OrigShareOfRevExpAmt := (ItemLedgEntry.Quantity - OrigInvdQty) / ItemLedgEntry.GetCostingQty; // PR4.00
            end;                                                                                            // PR4.00
        end;

        if TempInvtAdjmtBuf.Get(TransValueEntry."Entry No.") then
            TransValueEntry.AddCost(TempInvtAdjmtBuf);
        AdjustedCostElementBuf."Actual Cost" := Round(
            (ShareOfRevExpAmt - OrigShareOfRevExpAmt) * TransValueEntry."Cost Amount (Actual)", GLSetup."Amount Rounding Precision");
        AdjustedCostElementBuf."Actual Cost (ACY)" := Round(
            (ShareOfRevExpAmt - OrigShareOfRevExpAmt) *
            TransValueEntry."Cost Amount (Actual) (ACY)", Currency."Amount Rounding Precision");
    end;

    local procedure CalcTransEntryOldRevAmt(TransValueEntry: Record "Value Entry"; var CostElementBuf: Record "Cost Element Buffer")
    begin
        Clear(CostElementBuf);
        with CostElementBuf do begin
            TransValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
            TransValueEntry.SetRange("Item Ledger Entry No.", TransValueEntry."Item Ledger Entry No.");
            TransValueEntry.SetRange("Entry Type", TransValueEntry."Entry Type"::Revaluation);
            TransValueEntry.SetRange("Applies-to Entry", TransValueEntry."Entry No.");
            if TransValueEntry.FindSet() then
                repeat
                    if TempInvtAdjmtBuf.Get(TransValueEntry."Entry No.") then
                        TransValueEntry.AddCost(TempInvtAdjmtBuf);
                    "Actual Cost" := "Actual Cost" + TransValueEntry."Cost Amount (Actual)";
                    "Actual Cost (ACY)" := "Actual Cost (ACY)" + TransValueEntry."Cost Amount (Actual) (ACY)";
                until TransValueEntry.Next() = 0;
        end;
    end;

    local procedure IsInterimRevaluation(InbndValueEntry: Record "Value Entry"): Boolean
    begin
        with InbndValueEntry do
            exit(
              ("Entry Type" = "Entry Type"::Revaluation) and (("Cost Amount (Expected)" <> 0) or ("Cost Amount (Expected) (ACY)" <> 0)));
    end;

    local procedure OutboundSalesEntryToAdjust(ItemLedgEntry: Record "Item Ledger Entry"): Boolean
    var
        ItemApplnEntry: Record "Item Application Entry";
        InbndItemLedgEntry: Record "Item Ledger Entry";
    begin
        if not ItemLedgEntry.IsOutbndSale() then
            exit(false);

        with ItemApplnEntry do begin
            Reset();
            SetCurrentKey(
              "Outbound Item Entry No.", "Item Ledger Entry No.", "Cost Application", "Transferred-from Entry No.");
            SetRange("Outbound Item Entry No.", ItemLedgEntry."Entry No.");
            SetFilter("Item Ledger Entry No.", '<>%1', ItemLedgEntry."Entry No.");
            SetRange("Transferred-from Entry No.", 0);
            if FindSet() then
                repeat
                    if InbndItemLedgEntry.Get("Inbound Item Entry No.") then
                        if not InbndItemLedgEntry."Completely Invoiced" then
                            exit(true);
                until Next() = 0;
        end;

        exit(false);
    end;

    local procedure InboundTransferEntryToAdjust(ItemLedgEntry: Record "Item Ledger Entry"): Boolean
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if (ItemLedgEntry."Entry Type" <> ItemLedgEntry."Entry Type"::Transfer) or not ItemLedgEntry.Positive or
           ItemLedgEntry."Completely Invoiced"
        then
            exit(false);

        with ItemApplnEntry do begin
            SetRange("Inbound Item Entry No.", ItemLedgEntry."Entry No.");
            SetFilter("Item Ledger Entry No.", '<>%1', ItemLedgEntry."Entry No.");
            SetRange("Transferred-from Entry No.", 0);
            exit(not IsEmpty);
        end;
    end;

    procedure SetJobUpdateProperties(SkipJobUpdate: Boolean)
    begin
        SkipUpdateJobItemCost := SkipJobUpdate;
    end;

    local procedure GetLastValidValueEntry(ValueEntryNo: Integer): Integer
    var
        "Integer": Record "Integer";
    begin
        with TempAvgCostExceptionBuf do begin
            SetFilter(Number, '>%1', ValueEntryNo);
            if not FindFirst() then begin
                Integer.FindLast();
                SetRange(Number);
                exit(Integer.Number);
            end;
            exit(Number);
        end;
    end;

    local procedure FillFixApplBuffer(ItemLedgerEntryNo: Integer)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        with TempFixApplBuffer do
            if not Get(ItemLedgerEntryNo) then
                if ItemApplnEntry.AppliedOutbndEntryExists(ItemLedgerEntryNo, true, false) then begin
                    Number := ItemLedgerEntryNo;
                    Insert();
                    repeat
                        // buffer is filled with couple of entries which are applied and contains revaluation
                        Number := ItemApplnEntry."Item Ledger Entry No.";
                        if Insert() then;
                    until ItemApplnEntry.Next() = 0;
                end;
    end;

    local procedure UpdateJobItemCost()
    var
        JobsSetup: Record "Jobs Setup";
        Job: Record Job;
        UpdateJobItemCost: Report "Update Job Item Cost";
    begin
        OnBeforeUpdateJobItemCost(TempJobToAdjustBuf);

        if JobsSetup.Find() then
            if JobsSetup."Automatic Update Job Item Cost" then begin
                if TempJobToAdjustBuf.FindSet() then
                    repeat
                        Job.SetRange("No.", TempJobToAdjustBuf."No.");
                        Clear(UpdateJobItemCost);
                        UpdateJobItemCost.SetTableView(Job);
                        UpdateJobItemCost.UseRequestPage := false;
                        UpdateJobItemCost.SetProperties(true);
                        UpdateJobItemCost.RunModal();
                    until TempJobToAdjustBuf.Next() = 0;
            end;
    end;

    local procedure FetchOpenItemEntriesToExclude(AvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point"; var ExcludedValueEntry: Record "Value Entry"; var OpenEntries: Record "Integer" temporary; CalendarPeriod: Record Date)
    var
        OpenItemLedgEntry: Record "Item Ledger Entry";
        TempItemLedgEntryInChain: Record "Item Ledger Entry" temporary;
        ItemApplnEntry: Record "Item Application Entry";
    begin
        OpenEntries.Reset();
        OpenEntries.DeleteAll();

        with OpenItemLedgEntry do begin
            if OpenOutbndItemLedgEntriesExist(OpenItemLedgEntry, AvgCostAdjmtEntryPoint, CalendarPeriod) then
                repeat
                    CopyOpenItemLedgEntryToBuf(OpenEntries, ExcludedValueEntry, "Entry No.", CalendarPeriod."Period Start");
                    ItemApplnEntry.GetVisitedEntries(OpenItemLedgEntry, TempItemLedgEntryInChain, false);
                    if TempItemLedgEntryInChain.FindSet() then
                        repeat
                            CopyOpenItemLedgEntryToBuf(
                              OpenEntries, ExcludedValueEntry, TempItemLedgEntryInChain."Entry No.", CalendarPeriod."Period Start");
                        until TempItemLedgEntryInChain.Next() = 0;
                until Next() = 0;
        end;
    end;

    local procedure OpenOutbndItemLedgEntriesExist(var OpenItemLedgEntry: Record "Item Ledger Entry"; AvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point"; CalendarPeriod: Record Date): Boolean
    begin
        with OpenItemLedgEntry do begin
            SetCurrentKey("Item No.", Open, "Variant Code", Positive);
            SetRange("Item No.", AvgCostAdjmtEntryPoint."Item No.");
            SetRange(Open, true);
            SetRange(Positive, false);
            if not AvgCostAdjmtEntryPoint.IsAvgCostCalcTypeItem(CalendarPeriod."Period End") then begin
                SetRange("Location Code", AvgCostAdjmtEntryPoint."Location Code");
                SetRange("Variant Code", AvgCostAdjmtEntryPoint."Variant Code");
            end;
            OnOpenOutbndItemLedgEntriesExistOnAfterSetOpenItemLedgEntryFilters(OpenItemLedgEntry);
            exit(FindSet());
        end;
    end;

    local procedure ResetAvgBuffers(var OutbndValueEntry: Record "Value Entry"; var ExcludedValueEntry: Record "Value Entry")
    begin
        OutbndValueEntry.Reset();
        ExcludedValueEntry.Reset();
        TempAvgCostExceptionBuf.Reset();
        TempRevaluationPoint.Reset();
        TempValueEntryCalcdOutbndCostBuf.Reset();
        AvgCostBuf.Initialize(true);
    end;

    local procedure DeleteAvgBuffers(var OutbndValueEntry: Record "Value Entry"; var ExcludedValueEntry: Record "Value Entry")
    begin
        ResetAvgBuffers(OutbndValueEntry, ExcludedValueEntry);
        AvgCostBuf.Initialize(false);
        OutbndValueEntry.DeleteAll();
        ExcludedValueEntry.DeleteAll();
        TempAvgCostExceptionBuf.DeleteAll();
        TempRevaluationPoint.DeleteAll();
        TempValueEntryCalcdOutbndCostBuf.DeleteAll();
    end;

    local procedure InsertEntryPointToUpdate(var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10])
    begin
        with TempAvgCostAdjmtEntryPoint do begin
            "Item No." := ItemNo;
            "Variant Code" := VariantCode;
            "Location Code" := LocationCode;
            "Valuation Date" := 0D;
            if Insert() then;
        end;
    end;

    local procedure UpdateValuationPeriodHasOutput(ValueEntry: Record "Value Entry")
    var
        AvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point";
        OutputValueEntry: Record "Value Entry";
        CalendarPeriod: Record Date;
    begin
        if ValueEntry."Item Ledger Entry Type" in
           [ValueEntry."Item Ledger Entry Type"::Consumption,
            ValueEntry."Item Ledger Entry Type"::"Assembly Consumption"]
        then
            if AvgCostAdjmtEntryPoint.ValuationExists(ValueEntry) then begin
                if (ConsumpAdjmtInPeriodWithOutput <> 0D) and
                   (ConsumpAdjmtInPeriodWithOutput <= AvgCostAdjmtEntryPoint."Valuation Date")
                then
                    exit;

                CalendarPeriod."Period Start" := AvgCostAdjmtEntryPoint."Valuation Date";
                AvgCostAdjmtEntryPoint.GetValuationPeriod(CalendarPeriod);

                with OutputValueEntry do begin
                    SetCurrentKey("Item No.", "Valuation Date");
                    SetRange("Item No.", ValueEntry."Item No.");
                    SetRange("Valuation Date", AvgCostAdjmtEntryPoint."Valuation Date", CalendarPeriod."Period End");

                    SetFilter(
                      "Item Ledger Entry Type", '%1|%2',
                      "Item Ledger Entry Type"::Output,
                      "Item Ledger Entry Type"::"Assembly Output");
                    if FindFirst() then
                        ConsumpAdjmtInPeriodWithOutput := AvgCostAdjmtEntryPoint."Valuation Date";
                end;
            end;
    end;

    local procedure CopyOpenItemLedgEntryToBuf(var OpenEntries: Record "Integer" temporary; var ExcludedValueEntry: Record "Value Entry"; OpenItemLedgEntryNo: Integer; PeriodStart: Date)
    begin
        if CollectOpenValueEntries(ExcludedValueEntry, OpenItemLedgEntryNo, PeriodStart) then begin
            OpenEntries.Number := OpenItemLedgEntryNo;
            if OpenEntries.Insert() then;
        end;
    end;

    local procedure CollectOpenValueEntries(var ExcludedValueEntry: Record "Value Entry"; ItemLedgerEntryNo: Integer; PeriodStart: Date) FoundEntries: Boolean
    var
        OpenValueEntry: Record "Value Entry";
    begin
        OpenValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntryNo);
        OpenValueEntry.SetFilter("Valuation Date", '<%1', PeriodStart);
        FoundEntries := OpenValueEntry.FindSet();
        if FoundEntries then
            repeat
                ExcludedValueEntry := OpenValueEntry;
                if ExcludedValueEntry.Insert() then;
            until OpenValueEntry.Next() = 0;
    end;

    procedure StartCommCostPostReg(): Boolean
    var
        ItemReg: Record "Item Register";
        GLReg: Record "G/L Register";
    begin
        // P8000856
        if (LastItemRegNo <> 0) then begin
            ItemReg.FindLast;
            if (ItemReg."No." <> LastItemRegNo) then
                exit(true);
            if (LastGLRegNo <> 0) then begin
                GLReg.FindLast;
                if (GLReg."No." <> LastGLRegNo) then
                    exit(true);
            end;
        end;
    end;

    procedure PostCommCostVariance(InbndValueEntry: Record "Value Entry"; NewAdjustedCost: Decimal; NewAdjustedCostACY: Decimal; SourceCode: Code[10])
    var
        OrigValueEntry: Record "Value Entry";
        ItemJnlLine: Record "Item Journal Line";
    begin
        // P8000856
        if not CommCostInitialized then begin
            ItemJnlPostLine.SetCalledFromAdjustment(true, true);
            GLSetup.Get;
            PostingDateForClosedPeriod := GLSetup.FirstAllowedPostingDate;
            GetAddReportingCurrency;
            SourceCodeSetup."Adjust Cost" := SourceCode;
            CommCostInitialized := true;
        end;
        InitCommCostItemJnlLine(ItemJnlLine, InbndValueEntry);
        PostItemJnlLine(ItemJnlLine, InbndValueEntry, NewAdjustedCost, NewAdjustedCostACY);
        UpdateCommCostPostReg;
    end;

    local procedure InitCommCostItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; var InbndValueEntry: Record "Value Entry")
    var
        VarianceType: Integer;
    begin
        // P8000856
        with InbndValueEntry do
            if (not "Expected Cost") and
               ("Item Ledger Entry Type" in ["Item Ledger Entry Type"::Purchase, "Item Ledger Entry Type"::Output])
            then begin
                GetOrigValueEntry(InbndValueEntry, InbndValueEntry, "Entry Type"::Variance);
                case "Item Ledger Entry Type" of
                    "Item Ledger Entry Type"::Purchase:
                        VarianceType := "Variance Type"::Purchase; // P8004516
                    "Item Ledger Entry Type"::Output:
                        VarianceType := "Variance Type"::Material; // P8004516
                end;
            end else
                GetOrigValueEntry(InbndValueEntry, InbndValueEntry, "Entry Type"::"Direct Cost");
        InitAdjmtJnlLine(ItemJnlLine, InbndValueEntry, InbndValueEntry."Entry Type", VarianceType, InbndValueEntry."Invoiced Quantity"); // P8004516, P800-MegaApp
    end;

    local procedure UpdateCommCostPostReg()
    var
        ItemReg: Record "Item Register";
        GLReg: Record "G/L Register";
    begin
        // P8000856
        if (LastItemRegNo = 0) then begin
            ItemReg.FindLast;
            LastItemRegNo := ItemReg."No.";
            if GLReg.FindLast then
                LastGLRegNo := GLReg."No.";
        end;
    end;

    procedure GetOrigItemApplCost(var ItemApplEntry: Record "Item Application Entry"; var OrigApplCost: Decimal; var OrigApplCostACY: Decimal)
    var
        OutbndValueEntry: Record "Value Entry";
        CostElementBuf: Record "Cost Element Buffer" temporary;
    begin
        // P8000856
        with OutbndValueEntry do begin
            SetCurrentKey("Item Ledger Entry No.");
            SetRange("Item Ledger Entry No.", ItemApplEntry."Outbound Item Entry No.");
            FindLast;
            GetItem("Item No.");
        end;
        CalcInbndEntryAdjustedCost(
          CostElementBuf, ItemApplEntry,
          ItemApplEntry."Outbound Item Entry No.", ItemApplEntry."Inbound Item Entry No.", false, false);
        with CostElementBuf do begin
            GetElement("Cost Entry Type"::Total, "Cost Variance Type"::" "); // P800144605
            OrigApplCost := "Actual Cost";
            OrigApplCostACY := "Actual Cost (ACY)";
        end;
        with ItemApplEntry do
            if "Commodity Cost Calculated" then begin
                OrigApplCost := OrigApplCost - "Comm. Cost Adjmt.";
                OrigApplCostACY := OrigApplCostACY - "Comm. Cost Adjmt. (ACY)";
            end;
    end;

    local procedure BOMToAdjustExists(var ToInventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"): Boolean
    var
        InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)";
    begin
        // P8001134
        with InventoryAdjmtEntryOrder do begin
            Reset;
            SetCurrentKey("Cost is Adjusted", "Allow Online Adjustment");
            SetRange("Cost is Adjusted", false);
            SetFilter("Order Type", '%1|%2|%3',
              "Order Type"::FOODLotCombination, "Order Type"::FOODRepack, "Order Type"::FOODSalesRepack);
            if IsOnlineAdjmt then
                SetRange("Allow Online Adjustment", true);

            CopyOrderAdmtEntryToOrderAdjmt(InventoryAdjmtEntryOrder, ToInventoryAdjmtEntryOrder);
            exit(ToInventoryAdjmtEntryOrder.FindFirst);
        end;
    end;

    local procedure MakeBOMAdjmt(var SourceInvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    var
        InvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)";
        CalcInventoryAdjmtOrder: Codeunit "Calc. Inventory Adjmt. - Order";
        DoNotSkipItems: Boolean;
    begin
        // P8001134
        DoNotSkipItems := FilterItem.GetFilters = '';
        with SourceInvtAdjmtEntryOrder do
            if FindSet then
                repeat
                    if true in [DoNotSkipItems, ItemInFilteredSetExists("Item No.", FilterItem)] then begin
                        GetItem("Item No.");
                        UpDateWindow(WindowAdjmtLevel, "Item No.", Format("Order Type"), 0, 0, 0);

                        InvtAdjmtEntryOrder := SourceInvtAdjmtEntryOrder;
                        CalcInventoryAdjmtOrder.Calculate(SourceInvtAdjmtEntryOrder, TempInvtAdjmtBuf);
                        PostOutputAdjmtBuf(TempAvgCostAdjmtEntryPoint); // P80066030

                        StartWriteTransaction; // P8001227
                        InvtAdjmtEntryOrder."Allow Online Adjustment" := true;
                        InvtAdjmtEntryOrder."Cost is Adjusted" := true;
                        InvtAdjmtEntryOrder.Modify;
                        EndWriteTransaction(TempAvgCostAdjmtEntryPoint); // P8001227, P80066030
                    end;
                until Next = 0;
    end;

    procedure SetLockingTimes(NewMinLockSecs: Decimal; NewMinUnlockMilliSecs: Integer)
    begin
        // P8001227
        MinLockTime := Round(NewMinLockSecs * 1000, 1);
        ManagingLockTimes := (MinLockTime <> 0);
        if ManagingLockTimes then begin
            MinUnlockTime := NewMinUnlockMilliSecs;
            WriteLockEndTime := CurrentDateTime - MinUnlockTime;
        end;
        WriteTransactionStarted := false;
    end;

    local procedure StartWriteTransaction(): Boolean
    var
        WaitTime: Integer;
    begin
        // P8001227
        if ManagingLockTimes and (not WriteTransactionStarted) then begin
            if (MinUnlockTime <> 0) then begin
                WaitTime := MinUnlockTime - (CurrentDateTime - WriteLockEndTime);
                if (WaitTime > 0) then
                    Sleep(WaitTime);
            end;
            LockTables;
            if ItemJnlPostLine.ResetItemReg() then begin              // P80043683
                Clear(ItemJnlPostLine);
                ItemJnlPostLine.SetCalledFromAdjustment(true, PostToGL); // P80043683
            end;                                                      // P80043683
            WriteTransactionStarted := true;
            WriteLockStartTime := CurrentDateTime;
            exit(true);
        end;
    end;

    local procedure StartILEWriteTransaction(var ItemLedgEntry: Record "Item Ledger Entry")
    begin
        // P8001227
        if StartWriteTransaction() then
            ItemLedgEntry.Find;
    end;

    local procedure EndWriteTransaction(var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    begin
        // P8001227
        if ManagingLockTimes and WriteTransactionStarted then
            if ((CurrentDateTime - WriteLockStartTime) >= MinLockTime) then
                CommitWriteTransaction(TempAvgCostAdjmtEntryPoint); // P80066030
    end;

    local procedure CommitWriteTransaction(var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    begin
        // P8001227
        if ManagingLockTimes and WriteTransactionStarted then begin
            PostAdjmtBuf(TempAvgCostAdjmtEntryPoint); // P80066030
            Commit;
            WriteTransactionStarted := false;
            WriteLockEndTime := CurrentDateTime;
        end;
    end;

    local procedure LockTables()
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        ItemReg: Record "Item Register";
        GLEntry: Record "G/L Entry";
        GLRegister: Record "G/L Register";
    begin
        // P8001227
        ItemLedgEntry.LockTable;
        if ItemLedgEntry.FindLast then;
        ValueEntry.LockTable;
        if ValueEntry.FindLast then;
        ItemReg.LockTable;
        if ItemReg.FindLast then;
        // P80059825
        if PostToGL then begin
            GLEntry.LockTable;
            if GLEntry.FindLast then;
            GLRegister.LockTable;
            if GLRegister.FindLast then;
        end;
        // P80059825
    end;

    local procedure IsAppliedEntryToAdjust(var ItemLedgEntry: Record "Item Ledger Entry"): Boolean
    begin
        // P8001227
        with ItemLedgEntry do begin
            if ManagingLockTimes and "Applied Entry to Adjust" then
                exit(not TempItemLedgerEntryBuf.Get("Entry No."));
            exit("Applied Entry to Adjust");
        end;
    end;

    local procedure WriteAppliedEntryToAdjust(var ItemLedgEntry: Record "Item Ledger Entry"; AppliedEntryToAdjust: Boolean)
    begin
        // P8001227
        with ItemLedgEntry do
            if ("Applied Entry to Adjust" <> AppliedEntryToAdjust) then begin
                StartILEWriteTransaction(ItemLedgEntry);
                SetAppliedEntryToAdjust(AppliedEntryToAdjust);
                if ManagingLockTimes and (not AppliedEntryToAdjust) then
                    if TempItemLedgerEntryBuf.Get("Entry No.") then
                        TempItemLedgerEntryBuf.Delete;
            end;
    end;

    local procedure WriteCompletelyInvoiced(var ItemLedgEntry: Record "Item Ledger Entry")
    begin
        // P8001227
        with ItemLedgEntry do
            if not "Completely Invoiced" then begin
                StartILEWriteTransaction(ItemLedgEntry);
                SetCompletelyInvoiced;
            end;
    end;

    local procedure WriteAvgTransCompletelyInvoiced(var ItemLedgEntry: Record "Item Ledger Entry"): Boolean
    begin
        // P8001227
        with ItemLedgEntry do
            if ("Entry Type" = "Entry Type"::Transfer) and (not "Completely Invoiced") then begin
                StartILEWriteTransaction(ItemLedgEntry);
                exit(SetAvgTransCompletelyInvoiced());
            end;
    end;

    local procedure CopyJobToAdjustmentBuf(JobNo: Code[20])
    begin
        TempJobToAdjustBuf."No." := JobNo;
        if TempJobToAdjustBuf.Insert() then;
    end;

    local procedure UseStandardCostMirroring(ItemLedgEntry: Record "Item Ledger Entry"): Boolean
    var
        ReturnShipmentLine: Record "Return Shipment Line";
        EntryNo: Integer;
    begin
        with ItemLedgEntry do begin
            if ("Entry Type" <> "Entry Type"::Purchase) or
               ("Document Type" <> "Document Type"::"Purchase Return Shipment")
            then
                exit(false);

            EntryNo := "Entry No.";
            Reset();
            SetRange("Document Type", "Document Type");
            SetRange("Document No.", "Document No.");
            SetFilter("Document Line No.", '<>%1', "Document Line No.");
            SetRange("Item No.", "Item No.");
            SetRange(Correction, true);
            if FindSet() then
                repeat
                    ReturnShipmentLine.Get("Document No.", "Document Line No.");
                    if ReturnShipmentLine."Appl.-to Item Entry" = EntryNo then
                        exit(true);
                until Next() = 0;
        end;
        exit(false);
    end;

    local procedure IsOutputWithSelfConsumption(InbndValueEntry: Record "Value Entry"; OutbndValueEntry: Record "Value Entry"; var ItemLedgEntryInChain: Record "Item Ledger Entry"): Boolean
    var
        ConsumpItemLedgEntry: Record "Item Ledger Entry";
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        ConsumpValueEntry: Record "Value Entry";
        ItemApplicationEntry: Record "Item Application Entry";
        AvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point";
        AvgCostValuePeriodDate: Record Date;
    begin
        if not (InbndValueEntry."Item Ledger Entry Type" in
                [InbndValueEntry."Item Ledger Entry Type"::Output,
                 InbndValueEntry."Item Ledger Entry Type"::"Assembly Output"])
        then
            exit(false);

        if not (OutbndValueEntry."Item Ledger Entry Type" in
                [OutbndValueEntry."Item Ledger Entry Type"::Consumption,
                 OutbndValueEntry."Item Ledger Entry Type"::"Assembly Consumption"])
        then
            exit(false);

        if not AvgCostAdjmtEntryPoint.ValuationExists(InbndValueEntry) then
            exit(false);

        AvgCostValuePeriodDate."Period Start" := AvgCostAdjmtEntryPoint."Valuation Date";
        AvgCostAdjmtEntryPoint.GetValuationPeriod(AvgCostValuePeriodDate);

        with ConsumpValueEntry do begin
            SetCurrentKey("Order Type", "Order No.", "Order Line No.");
            SetRange("Order Type", InbndValueEntry."Order Type");
            SetRange("Order No.", InbndValueEntry."Order No.");
            if InbndValueEntry."Order Type" = InbndValueEntry."Order Type"::Production then
                SetRange("Order Line No.", InbndValueEntry."Order Line No.");

            SetRange("Item No.", InbndValueEntry."Item No."); // self-consumption
            SetRange("Valuation Date", AvgCostAdjmtEntryPoint."Valuation Date", AvgCostValuePeriodDate."Period End");
            SetFilter(
              "Item Ledger Entry Type", '%1|%2',
              "Item Ledger Entry Type"::Consumption, "Item Ledger Entry Type"::"Assembly Consumption");
            if not AvgCostAdjmtEntryPoint.IsAvgCostCalcTypeItem(InbndValueEntry."Valuation Date") then begin
                SetRange("Variant Code", InbndValueEntry."Variant Code");
                SetRange("Location Code", InbndValueEntry."Location Code");
            end;
            OnIsOutputWithSelfConsumptionOnAfterSetConsumpValueEntryFilters(ConsumpValueEntry);

            if FindFirst() then begin
                ConsumpItemLedgEntry.Get("Item Ledger Entry No.");
                ItemApplicationEntry.GetVisitedEntries(ConsumpItemLedgEntry, TempItemLedgEntry, true);

                TempItemLedgEntry.Reset();
                TempItemLedgEntry.SetRange("Item No.", "Item No.");
                if not AvgCostAdjmtEntryPoint.IsAvgCostCalcTypeItem(InbndValueEntry."Valuation Date") then begin
                    TempItemLedgEntry.SetRange("Location Code", "Location Code");
                    TempItemLedgEntry.SetRange("Variant Code", "Variant Code");
                end;
                OnIsOutputWithSelfConsumptionOnAfterSetTempItemLedgEntryFilter(TempItemLedgEntry);

                if TempItemLedgEntry.FindSet() then
                    repeat
                        ItemLedgEntryInChain := TempItemLedgEntry;
                        if ItemLedgEntryInChain.Insert() then;
                    until TempItemLedgEntry.Next() = 0;
                exit(true);
            end;

            exit(false);
        end;
    end;

    local procedure RestoreValuesFromBuffers(var OutbndCostElementBuf: Record "Cost Element Buffer"; var AdjustedCostElementBuf: Record "Cost Element Buffer"; OutbndItemLedgEntryNo: Integer): Boolean
    begin
        with TempValueEntryCalcdOutbndCostBuf do begin
            Reset();
            SetRange("Item Ledger Entry No.", OutbndItemLedgEntryNo);
            if IsEmpty() then
                exit(false);

            FindSet();
            CopyValueEntryBufToCostElementBuf(OutbndCostElementBuf, TempValueEntryCalcdOutbndCostBuf);

            Next();
            repeat
                CopyValueEntryBufToCostElementBuf(AdjustedCostElementBuf, TempValueEntryCalcdOutbndCostBuf);
            until Next() = 0;
        end;

        exit(true);
    end;

    local procedure SaveValuesToBuffers(var OutbndCostElementBuf: Record "Cost Element Buffer"; var AdjustedCostElementBuf: Record "Cost Element Buffer"; OutbndItemLedgEntryNo: Integer)
    begin
        if AdjustedCostElementBuf.IsEmpty() then
            exit;

        CopyCostElementBufToValueEntryBuf(TempValueEntryCalcdOutbndCostBuf, OutbndCostElementBuf, OutbndItemLedgEntryNo);
        AdjustedCostElementBuf.FindSet();
        repeat
            CopyCostElementBufToValueEntryBuf(TempValueEntryCalcdOutbndCostBuf, AdjustedCostElementBuf, OutbndItemLedgEntryNo);
        until AdjustedCostElementBuf.Next() = 0;
    end;

    local procedure CopyCostElementBufToValueEntryBuf(var ValueEntryBuf: Record "Value Entry"; CostElementBuffer: Record "Cost Element Buffer"; ItemLedgEntryNo: Integer)
    var
        EntryNo: Integer;
    begin
        with ValueEntryBuf do begin
            Reset();
            if FindLast() then
                EntryNo := "Entry No.";

            Init();
            "Entry No." := EntryNo + 1;
            "Entry Type" := CostElementBuffer.Type;
            "Variance Type" := CostElementBuffer."Variance Type";
            "Item Ledger Entry No." := ItemLedgEntryNo;
            "Cost Amount (Actual)" := CostElementBuffer."Actual Cost";
            "Cost Amount (Actual) (ACY)" := CostElementBuffer."Actual Cost (ACY)";
            "Cost Amount (Expected)" := CostElementBuffer."Expected Cost";
            "Cost Amount (Expected) (ACY)" := CostElementBuffer."Expected Cost (ACY)";
            "Cost Amount (Non-Invtbl.)" := CostElementBuffer."Rounding Residual";
            "Cost Amount (Non-Invtbl.)(ACY)" := CostElementBuffer."Rounding Residual (ACY)";
            "Invoiced Quantity" := CostElementBuffer."Invoiced Quantity";
            "Valued Quantity" := CostElementBuffer."Remaining Quantity";
            "Expected Cost" := CostElementBuffer."Inbound Completely Invoiced";
            OnCopyCostElementBufToValueEntryBufOnBeforeValueEntryBufInsert(ValueEntryBuf, CostElementBuffer);
            Insert();
        end;
    end;

    local procedure CopyValueEntryBufToCostElementBuf(var CostElementBuffer: Record "Cost Element Buffer"; ValueEntryBuf: Record "Value Entry")
    begin
        with CostElementBuffer do begin
            Init();
            Type := ValueEntryBuf."Entry Type";
            "Variance Type" := ValueEntryBuf."Variance Type";
            "Actual Cost" := ValueEntryBuf."Cost Amount (Actual)";
            "Actual Cost (ACY)" := ValueEntryBuf."Cost Amount (Actual) (ACY)";
            "Expected Cost" := ValueEntryBuf."Cost Amount (Expected)";
            "Expected Cost (ACY)" := ValueEntryBuf."Cost Amount (Expected) (ACY)";
            "Rounding Residual" := ValueEntryBuf."Cost Amount (Non-Invtbl.)";
            "Rounding Residual (ACY)" := ValueEntryBuf."Cost Amount (Non-Invtbl.)(ACY)";
            "Invoiced Quantity" := ValueEntryBuf."Invoiced Quantity";
            "Remaining Quantity" := ValueEntryBuf."Valued Quantity";
            "Inbound Completely Invoiced" := ValueEntryBuf."Expected Cost";
            OnCopyValueEntryBufToCostElementBufOnBeforeCostElementBufferInsert(CostElementBuffer, ValueEntryBuf);
            Insert();
        end;
    end;

    local procedure ClearOutboundEntryCostBuffer(InboundEntryNo: Integer)
    var
        ItemApplicationEntry: Record "Item Application Entry";
    begin
        if ItemApplicationEntry.AppliedOutbndEntryExists(InboundEntryNo, false, false) then
            repeat
                TempValueEntryCalcdOutbndCostBuf.Reset();
                TempValueEntryCalcdOutbndCostBuf.SetRange("Item Ledger Entry No.", ItemApplicationEntry."Outbound Item Entry No.");
                if not TempValueEntryCalcdOutbndCostBuf.IsEmpty() then
                    TempValueEntryCalcdOutbndCostBuf.DeleteAll();
            until ItemApplicationEntry.Next() = 0;
    end;

    // Extension interface for local procedures

    procedure CallInitializeAdjmt()
    begin
        InitializeAdjmt();
    end;

    procedure CallFinalizeAdjmt()
    begin
        FinalizeAdjmt();
    end;

    procedure CallInvtToAdjustExist(var ToItem: Record Item): Boolean
    begin
        exit(InvtToAdjustExist(ToItem));
    end;

    procedure CallMakeSingleLevelAdjmt(var TheItem: Record Item; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    begin
        MakeSingleLevelAdjmt(TheItem, TempAvgCostAdjmtEntryPoint);
    end;

    procedure CallWIPToAdjustExist(var ToInventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"): Boolean
    begin
        exit(WIPToAdjustExist(ToInventoryAdjmtEntryOrder));
    end;

    procedure CallMakeWIPAdjmt(var SourceInvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    begin
        MakeWIPAdjmt(SourceInvtAdjmtEntryOrder, TempAvgCostAdjmtEntryPoint);
    end;

    procedure CallAssemblyToAdjustExists(var ToInventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"): Boolean
    begin
        exit(AssemblyToAdjustExists(ToInventoryAdjmtEntryOrder));
    end;

    procedure CallMakeAssemblyAdjmt(var SourceInvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)"; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    begin
        MakeAssemblyAdjmt(SourceInvtAdjmtEntryOrder, TempAvgCostAdjmtEntryPoint);
    end;

    procedure CallUpdateAdjmtBuf(OrigValueEntry: Record "Value Entry"; NewAdjustedCost: Decimal; NewAdjustedCostACY: Decimal; ItemLedgEntryPostingDate: Date; EntryType: Enum "Cost Entry Type"): Boolean
    begin
        exit(UpdateAdjmtBuf(OrigValueEntry, NewAdjustedCost, NewAdjustedCostACY, ItemLedgEntryPostingDate, EntryType));
    end;

    procedure CallPostAdjmtBuf(var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary)
    begin
        PostAdjmtBuf(TempAvgCostAdjmtEntryPoint);
    end;

    procedure CallSetAppliedEntryToAdjustFromBuf(ItemNo: Code[20])
    begin
        SetAppliedEntryToAdjustFromBuf(ItemNo);
    end;

    procedure CallAppliedEntryToAdjustBufExists(ItemNo: Code[20]): Boolean
    begin
        exit(AppliedEntryToAdjustBufExists((ItemNo)));
    end;

    procedure CallUpdateJobItemCost()
    begin
        UpdateJobItemCost();
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterCalcInbndEntryAdjustedCost(var AdjustedCostElementBuf: Record "Cost Element Buffer"; var InbndValueEntry: Record "Value Entry"; InbndItemLedgEntry: Record "Item Ledger Entry"; ItemApplnEntry: Record "Item Application Entry"; OutbndItemLedgEntryNo: Integer; var CompletelyInvoiced: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAdjustOutbndAvgEntryOnBeforeForwardAvgCostToInbndEntries(var OutbndItemLedgEntry: Record "Item Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAdjustItemAvgCostOnAfterLastTempAvgCostAdjmtEntryPoint(var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary; var Restart: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAdjustItemAvgCostOnAfterCalcRestart(var TempExcludedValueEntry: Record "Value Entry" temporary; var Restart: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAvgValueEntriesToAdjustExistOnAfterSetAvgValueEntryFilters(var ValueEntry: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAvgValueEntriesToAdjustExistOnAfterSetChildValueEntryFilters(var ValueEntry: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAvgValueEntriesToAdjustExistOnFindNextRangeOnBeforeAvgValueEntriesToAdjustExist(var OutbndValueEntry: Record "Value Entry"; var ExcludedValueEntry: Record "Value Entry"; var AvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetValuationPeriod(var CalendarPeriod: Record Date; Item: record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetVisitedEntries(var ExcludedValueEntry: Record "Value Entry"; OutbndValueEntry: Record "Value Entry"; var ItemLedgEntryInChain: Record "Item Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsAvgCostItem(var Item: Record Item; var AvgCostItem: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMakeMultiLevelAdjmt(var Item: Record Item; IsOnlineAdjmt: Boolean; PostToGL: Boolean; var FilterItem: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcInbndEntryAdjustedCost(var AdjustedCostElementBuf: Record "Cost Element Buffer"; ItemApplnEntry: Record "Item Application Entry"; OutbndItemLedgEntryNo: Integer; InbndItemLedgEntryNo: Integer; ExactCostReversing: Boolean; Recursion: Boolean; var CompletelyInvoiced: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyILEToILE(var Item: Record Item; ItemLedgEntry: Record "Item Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyItemToItem(var FromItem: Record Item; var ToItem: Record Item; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsUpdateCompletelyInvoiced(ItemLedgEntry: Record "Item Ledger Entry"; CompletelyInvoiced: Boolean; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeMakeMultiLevelAdjmt(var Item: Record Item; IsOnlineAdjmt: Boolean; PostToGL: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; OrigValueEntry: Record "Value Entry"; NewAdjustedCost: Decimal; NewAdjustedCostACY: Decimal; SkipUpdateJobItemCost: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenWindow(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateAdjmtBuf(OrigValueEntry: Record "Value Entry"; NewAdjustedCost: Decimal; NewAdjustedCostACY: Decimal; ItemLedgEntryPostingDate: Date; EntryType: Enum "Cost Entry Type"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateWindow(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateItemUnitCost(var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary; var IsHandled: Boolean; var Item: Record Item; var TempItemLedgerEntry: Record "Item Ledger Entry" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateConsumpAvgEntry(ValueEntry: Record "Value Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyAvgCostAdjmtToAvgCostAdjmtOnAfterInsert(var AvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyCostElementBufToValueEntryBufOnBeforeValueEntryBufInsert(var ValueEntryBuf: Record "Value Entry"; CostElementBuffer: Record "Cost Element Buffer")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyValueEntryBufToCostElementBufOnBeforeCostElementBufferInsert(var CostElementBuffer: Record "Cost Element Buffer"; ValueEntryBuf: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnExcludeAvgCostOnValuationDateOnAfterSetItemLedgEntryInChainFilters(var ItemLedgerEntryInChain: Record "Item Ledger Entry" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnForwardAppliedCostOnAfterSetAppliedQty(ItemLedgerEntry: Record "Item Ledger Entry"; var AppliedQty: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetOrigValueEntryOnAfterOrigValueEntryFound(var OrigValueEntry: Record "Value Entry"; ValueEntry: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsOutputWithSelfConsumptionOnAfterSetTempItemLedgEntryFilter(var TempItemLedgerEntry: Record "Item Ledger Entry" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsOutputWithSelfConsumptionOnAfterSetConsumpValueEntryFilters(var ConsumpValueEntry: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnOpenOutbndItemLedgEntriesExistOnAfterSetOpenItemLedgEntryFilters(var OpenItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostItemJnlLineCopyFromValueEntry(var ItemJournalLine: Record "Item Journal Line"; ValueEntry: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostItemJnlLineOnAfterItemJnlPostLineRunWithCheck(var ItemJournalLine: Record "Item Journal Line"; ValueEntry: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostItemJnlLineOnAfterSetPostingDate(var ItemJournalLine: Record "Item Journal Line"; ValueEntry: Record "Value Entry"; PostingDateForClosedPeriod: Date; var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnMakeMultiLevelAdjmtOnAfterMakeAdjmt(var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary; var FilterItem: Record Item; var RndgResidualBuf: Record "Rounding Residual Buffer"; IsOnlineAdjmt: Boolean; PostToGL: Boolean; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnMakeSingleLevelAdjmtOnAfterUpdateItemUnitCost(var TheItem: Record Item; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary; var LevelExceeded: Boolean; IsOnlineAdjmt: Boolean; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInvtToAdjustExistOnBeforeCopyItemToItem(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateJobItemCost(var Job: Record Job);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateItemUnitCostOnAfterItemGet(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateItemUnitCostOnAfterModifyItemNotStandardCostingMethod(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateItemUnitCostOnBeforeModifyItemNotStandardCostingMethod(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateConsumpAvgEntryOnAfterSetItemLedgEntryFilters(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostOutputOnBeforePostItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; OrigValueEntry: Record "Value Entry"; var InvtAdjmtBuf: Record "Inventory Adjustment Buffer"; var GLSetup: Record "General Ledger Setup"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitAdjmtJnlLine(var ItemJnlLine: Record "Item Journal Line"; OrigValueEntry: Record "Value Entry"; EntryType: Enum "Cost Entry Type"; VarianceType: Enum "Cost Variance Type"; InvoicedQty: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnWIPToAdjustExistOnAfterInventoryAdjmtEntryOrderSetFilters(var InventoryAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeMakeSingleLevelAdjmt(var TheItem: Record Item; var TempAvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAdjustItemAvgCostOnBeforeAdjustValueEntries()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAvgValueEntriesToAdjustExistOnBeforeIsNotAdjustment(var ValueEntry: Record "Value Entry"; var OutbndValueEntry: Record "Value Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnMakeSingleLevelAdjmtOnBeforeCollectAvgCostAdjmtEntryPointToUpdate(var TheItem: Record Item)
    begin
    end;
}

