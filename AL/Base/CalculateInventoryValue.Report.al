report 5899 "Calculate Inventory Value"
{
    // PR3.70.06
    // P8000106A, Myers Nissi, Jack Reynolds, 02 SEP 04
    //   Modify to support alternate quantities in revaluation journal
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Key changes in item ledger and item application have required restructuring of some P800 code
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10.02
    // P8001302, Columbus IT, Jack Reynolds, 05 MAR 14
    //   Combine CalculateRemQuantity and CalculateRemAltQuantity
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // P8008177, To-Increase, Jack Reynolds, 08 DEC 16
    //   Fix problem with incorrect costing quantity
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Calculate Inventory Value';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.") WHERE(Type = CONST(Inventory));
            RequestFilterFields = "No.", "Costing Method", "Location Filter", "Variant Filter";

            trigger OnAfterGetRecord()
            var
                SkipItem: Boolean;
                RemCost: Decimal;
            begin
                if ShowDialog then
                    Window.Update;

                SkipItem := false;
                OnBeforeOnAfterGetRecord(Item, SkipItem);
                if SkipItem then
                    CurrReport.Skip();

                if (CalculatePer = CalculatePer::Item) and ("Costing Method" = "Costing Method"::Average) then begin
                    CalendarPeriod."Period Start" := PostingDate;
                    AvgCostAdjmtPoint."Valuation Date" := PostingDate;
                    AvgCostAdjmtPoint.GetValuationPeriod(CalendarPeriod);
                    if PostingDate <> CalendarPeriod."Period End" then
                        Error(Text011, "No.", PostingDate, CalendarPeriod."Period End");
                end;

                ValJnlBuffer.Reset();
                ValJnlBuffer.DeleteAll();
                IncludeExpectedCost := ("Costing Method" = "Costing Method"::Standard) and (CalculatePer = CalculatePer::Item);
                ItemLedgEntry.SetRange("Item No.", "No.");
                ItemLedgEntry.SetRange(Positive, true);
                CopyFilter("Location Filter", ItemLedgEntry."Location Code");
                CopyFilter("Variant Filter", ItemLedgEntry."Variant Code");
                OnItemAfterGetRecordOnAfterItemLedgEntrySetFilters(ItemLedgEntry, Item);
                if ItemLedgEntry.Find('-') then
                    repeat
                        if IncludeEntryInCalc(ItemLedgEntry, PostingDate, IncludeExpectedCost) then begin
                            ItemLedgEntry.CalculateRemQuantity(ItemLedgEntry."Entry No.", PostingDate, RemQty, RemAltQty); // P8001302
                            RemCost := CalcRemainingCost(ItemLedgEntry, RemQty, IncludeExpectedCost);
                            case CalculatePer of
                                CalculatePer::"Item Ledger Entry":
                                    InsertItemJnlLine(
                                      ItemLedgEntry."Entry Type", ItemLedgEntry."Item No.",
                                      ItemLedgEntry."Variant Code", ItemLedgEntry."Location Code", RemQty, RemAltQty, RemCost, ItemLedgEntry."Entry No.", 0);
                                CalculatePer::Item:
                                    InsertValJnlBuffer(
                                      ItemLedgEntry."Item No.", ItemLedgEntry."Variant Code", ItemLedgEntry."Location Code", RemQty, RemAltQty, RemCost); // P8000106A
                            end;
                        end;
                    until ItemLedgEntry.Next() = 0;

                if CalculatePer = CalculatePer::Item then
                    if (GetFilter("Location Filter") <> '') or ByLocation then begin
                        ByLocation2 := true;
                        CopyFilter("Location Filter", Location.Code);
                        if Location.Find('-') then begin
                            Clear(ValJnlBuffer);
                            ValJnlBuffer.SetCurrentKey("Item No.", "Location Code", "Variant Code");
                            ValJnlBuffer.SetRange("Item No.", "No.");
                            repeat
                                ValJnlBuffer.SetRange("Location Code", Location.Code);
                                if (GetFilter("Variant Filter") <> '') or ByVariant then begin
                                    ByVariant2 := true;
                                    ItemVariant.SetRange("Item No.", "No.");
                                    CopyFilter("Variant Filter", ItemVariant.Code);
                                    if ItemVariant.Find('-') then
                                        repeat
                                            ValJnlBuffer.SetRange("Variant Code", ItemVariant.Code);
                                            Calculate(Item, ItemVariant.Code, Location.Code);
                                        until ItemVariant.Next() = 0;
                                    ValJnlBuffer.SetRange("Variant Code", '');
                                    Calculate(Item, '', Location.Code);
                                end else
                                    Calculate(Item, '', Location.Code);
                            until Location.Next() = 0;
                        end;
                        ValJnlBuffer.SetRange("Location Code", '');
                        if ByVariant then begin
                            ItemVariant.SetRange("Item No.", "No.");
                            CopyFilter("Variant Filter", ItemVariant.Code);
                            if ItemVariant.Find('-') then
                                repeat
                                    ValJnlBuffer.SetRange("Variant Code", ItemVariant.Code);
                                    Calculate(Item, ItemVariant.Code, '');
                                until ItemVariant.Next() = 0;
                            ValJnlBuffer.SetRange("Variant Code", '');
                            Calculate(Item, '', '');
                        end else
                            Calculate(Item, '', '');
                    end else
                        if (GetFilter("Variant Filter") <> '') or ByVariant then begin
                            ByVariant2 := true;
                            ItemVariant.SetRange("Item No.", "No.");
                            CopyFilter("Variant Filter", ItemVariant.Code);
                            if ItemVariant.Find('-') then begin
                                ValJnlBuffer.Reset();
                                ValJnlBuffer.SetCurrentKey("Item No.", "Variant Code");
                                ValJnlBuffer.SetRange("Item No.", "No.");
                                repeat
                                    ValJnlBuffer.SetRange("Variant Code", ItemVariant.Code);
                                    Calculate(Item, ItemVariant.Code, '');
                                until ItemVariant.Next() = 0;
                            end;
                            ValJnlBuffer.SetRange("Location Code");
                            ValJnlBuffer.SetRange("Variant Code", '');
                            Calculate(Item, '', '');
                        end else begin
                            ValJnlBuffer.Reset();
                            ValJnlBuffer.SetCurrentKey("Item No.");
                            ValJnlBuffer.SetRange("Item No.", "No.");
                            Calculate(Item, '', '');
                        end;
            end;

            trigger OnPostDataItem()
            var
                SKU: Record "Stockkeeping Unit";
                ItemCostMgt: Codeunit ItemCostManagement;
            begin
                if not UpdStdCost then
                    exit;

                if ByLocation then
                    CopyFilter("Location Filter", NewStdCostSKU."Location Code"); // P8001030
                if ByVariant then
                    CopyFilter("Variant Filter", NewStdCostSKU."Variant Code");   // P8001030


                // P8001030
                //NewStdCostItem.CopyFilters(Item);
                //if NewStdCostItem.Find('-') then
                //    repeat
                //        if not UpdatedStdCostSKU.Get('', NewStdCostItem."No.", '') then
                //            ItemCostMgt.UpdateStdCostShares(NewStdCostItem);
                //
                //        SKU.SetRange("Item No.", NewStdCostItem."No.");
                //        if SKU.Find('-') then
                //            repeat 
                //                if not UpdatedStdCostSKU.Get(SKU."Location Code", NewStdCostItem."No.", SKU."Variant Code") then begin
                //                    SKU.Validate("Standard Cost", NewStdCostItem."Standard Cost");
                //                    SKU.Modify();
                //                end;
                //            until SKU.Next() = 0;
                //    until NewStdCostItem.Next() = 0;

                if Item.Find('-') then
                    repeat
                        NewStdCostSKU.SetRange("Item No.", Item."No.");
                        if NewStdCostSKU.Find('-') then
                            repeat
                                if not UpdatedStdCostSKU.Get(NewStdCostSKU."Location Code", NewStdCostSKU."Item No.", NewStdCostSKU."Variant Code") then begin
                                    if (NewStdCostSKU."Location Code" = '') and (NewStdCostSKU."Variant Code" = '') then begin
                                        ItemCostMgt.TransferCostsFromSKUToItem(NewStdCostSKU, Item);
                                        ItemCostMgt.UpdateStdCostShares(Item);
                                    end else
                                        ItemCostMgt.UpdateStdCostSharesSKU(NewStdCostSKU);
                                end;
                            until NewStdCostSKU.Next() = 0;
                    until Item.Next() = 0;
                // P8001030
            end;

            trigger OnPreDataItem()
            var
                TempErrorBuf: Record "Error Buffer" temporary;
            begin
                ItemJnlTemplate.Get(ItemJnlLine."Journal Template Name");
                ItemJnlTemplate.TestField(Type, ItemJnlTemplate.Type::Revaluation);

                ItemJnlBatch.Get(ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name");
                if NextDocNo = '' then begin
                    if ItemJnlBatch."No. Series" <> '' then begin
                        ItemJnlLine.SetRange("Journal Template Name", ItemJnlLine."Journal Template Name");
                        ItemJnlLine.SetRange("Journal Batch Name", ItemJnlLine."Journal Batch Name");
                        if not ItemJnlLine.FindFirst then
                            NextDocNo := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", PostingDate, false);
                        ItemJnlLine.Init();
                    end;
                    if NextDocNo = '' then
                        Error(Text003);
                end;

                CalcInvtValCheck.SetProperties(PostingDate, CalculatePer, ByLocation, ByVariant, ShowDialog, false);
                CalcInvtValCheck.RunCheck(Item, TempErrorBuf);

                ItemLedgEntry.SetCurrentKey("Item No.", Positive, "Location Code", "Variant Code");

                NextLineNo := 0;

                if ShowDialog then
                    Window.Open(Text010, "No.");

                GLSetup.Get();
                SourceCodeSetup.Get();

                if CalcBase in [CalcBase::"Standard Cost - Assembly List", CalcBase::"Standard Cost - Manufacturing"] then begin
                    CalculateStdCost.SetProperties(PostingDate, true, CalcBase = CalcBase::"Standard Cost - Assembly List", false, '', true);
                    CalculateStdCost.CalcItems(Item, NewStdCostSKU); // P8001030
                    Clear(CalculateStdCost);
                end;

                OnAfterOnPreDataItem(Item);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the date for the posting of this batch job. By default, the working date is entered, but you can change it.';
                    }
                    field(NextDocNo; NextDocNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the number of the document that is processed by the report or batch job.';
                    }
                    field(CalculatePer; CalculatePer)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Calculate Per';
                        OptionCaption = 'Item Ledger Entry,Item';
                        ToolTip = 'Specifies if you want to sum up the inventory value per item ledger entry or per item.';

                        trigger OnValidate()
                        begin
                            if CalculatePer = CalculatePer::Item then
                                ItemCalculatePerOnValidate;
                            if CalculatePer = CalculatePer::"Item Ledger Entry" then
                                ItemLedgerEntryCalculatePerOnV;
                        end;
                    }
                    field("By Location"; ByLocation)
                    {
                        ApplicationArea = Location;
                        Caption = 'By Location';
                        Enabled = ByLocationEnable;
                        ToolTip = 'Specifies whether to calculate inventory by location.';
                    }
                    field("By Variant"; ByVariant)
                    {
                        ApplicationArea = Planning;
                        Caption = 'By Variant';
                        Enabled = ByVariantEnable;
                        ToolTip = 'Specifies the item variants that you want the batch job to consider.';
                    }
                    field(UpdStdCost; UpdStdCost)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Update Standard Cost';
                        Enabled = UpdStdCostEnable;
                        ToolTip = 'Specifies if you want the items'' standard cost to be updated according to the calculated inventory value. This option is available only if Item is chosen in the Calculate Per field.';
                    }
                    field(CalcBase; CalcBase)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Calculation Base';
                        Enabled = CalcBaseEnable;
                        OptionCaption = ' ,Last Direct Unit Cost,Standard Cost - Assembly List,Standard Cost - Manufacturing';
                        ToolTip = 'Specifies if the revaluation journal will suggest a new value for the Unit Cost (Revalued) field.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            UpdStdCostEnable := true;
            CalcBaseEnable := true;
            ByVariantEnable := true;
            ByLocationEnable := true;
        end;

        trigger OnOpenPage()
        begin
            if PostingDate = 0D then
                PostingDate := WorkDate;
            ValidatePostingDate;

            ValidateCalcLevel;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        OnBeforePreReport;
    end;

    var
        Text003: Label 'You must enter a document number.';
        Text010: Label 'Processing items #1##########';
        NewStdCostSKU: Record "Stockkeeping Unit" temporary;
        UpdatedStdCostSKU: Record "Stockkeeping Unit" temporary;
        ItemJnlBatch: Record "Item Journal Batch";
        ItemJnlLine: Record "Item Journal Line";
        ValJnlBuffer: Record "Item Journal Buffer" temporary;
        ItemJnlTemplate: Record "Item Journal Template";
        ItemLedgEntry: Record "Item Ledger Entry";
        GLSetup: Record "General Ledger Setup";
        SourceCodeSetup: Record "Source Code Setup";
        Location: Record Location;
        ItemVariant: Record "Item Variant";
        AvgCostAdjmtPoint: Record "Avg. Cost Adjmt. Entry Point";
        CalendarPeriod: Record Date;
        CalcInvtValCheck: Codeunit "Calc. Inventory Value-Check";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        CalculateStdCost: Codeunit "Calculate Standard Cost";
        Window: Dialog;
        CalculatePer: Option "Item Ledger Entry",Item;
        CalcBase: Option " ","Last Direct Unit Cost","Standard Cost - Assembly List","Standard Cost - Manufacturing";
        PostingDate: Date;
        NextDocNo: Code[20];
        AverageUnitCostLCY: Decimal;
        RemQty: Decimal;
        NextLineNo: Integer;
        NextLineNo2: Integer;
        ByLocation: Boolean;
        ByVariant: Boolean;
        ByLocation2: Boolean;
        ByVariant2: Boolean;
        UpdStdCost: Boolean;
        ShowDialog: Boolean;
        IncludeExpectedCost: Boolean;
        Text011: Label 'You cannot revalue by Calculate Per Item for item %1 using posting date %2. You can only use the posting date %3 for this period.';
        [InDataSet]
        ByLocationEnable: Boolean;
        [InDataSet]
        ByVariantEnable: Boolean;
        [InDataSet]
        CalcBaseEnable: Boolean;
        [InDataSet]
        UpdStdCostEnable: Boolean;
        DuplWarningQst: Label 'Duplicate Revaluation Journals will be generated.\Do you want to continue?';
        HideDuplWarning: Boolean;
        RemAltQty: Decimal;

    local procedure IncludeEntryInCalc(ItemLedgEntry: Record "Item Ledger Entry"; PostingDate: Date; IncludeExpectedCost: Boolean): Boolean
    begin
        with ItemLedgEntry do begin
            if IncludeExpectedCost then
                exit("Posting Date" in [0D .. PostingDate]);
            exit("Completely Invoiced" and ("Last Invoice Date" in [0D .. PostingDate]));
        end;
    end;

    procedure SetItemJnlLine(var NewItemJnlLine: Record "Item Journal Line")
    begin
        ItemJnlLine := NewItemJnlLine;
    end;

    local procedure ValidatePostingDate()
    begin
        ItemJnlBatch.Get(ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name");
        if ItemJnlBatch."No. Series" = '' then
            NextDocNo := ''
        else begin
            NextDocNo := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", PostingDate, false);
            Clear(NoSeriesMgt);
        end;
    end;

    local procedure ValidateCalcLevel()
    begin
        PageValidateCalcLevel();
        exit;
    end;

    local procedure InsertValJnlBuffer(ItemNo2: Code[20]; VariantCode2: Code[10]; LocationCode2: Code[10]; Quantity2: Decimal; AltQuantity2: Decimal; Amount2: Decimal)
    begin
        // P8000106A - add parameter for alternate quantity
        if CostingQty(Quantity2, AltQuantity2) = 0 then // P8000106A
            exit;                                        // P8000106A

        ValJnlBuffer.Reset();
        ValJnlBuffer.SetCurrentKey("Item No.", "Location Code", "Variant Code");
        ValJnlBuffer.SetRange("Item No.", ItemNo2);
        ValJnlBuffer.SetRange("Location Code", LocationCode2);
        ValJnlBuffer.SetRange("Variant Code", VariantCode2);
        if ValJnlBuffer.FindFirst() then begin
            ValJnlBuffer.Quantity := ValJnlBuffer.Quantity + Quantity2;
            ValJnlBuffer."Quantity (Alt.)" := ValJnlBuffer."Quantity (Alt.)" + AltQuantity2; // P8000106A
            ValJnlBuffer."Inventory Value (Calculated)" :=
              ValJnlBuffer."Inventory Value (Calculated)" + Amount2;
            ValJnlBuffer.Modify();
        end else
          //IF Quantity2 <> 0 THEN BEGIN // P8000106A
          begin // P8000106A
            NextLineNo2 := NextLineNo2 + 10000;
            ValJnlBuffer.Init;
            ValJnlBuffer."Line No." := NextLineNo2;
            ValJnlBuffer."Item No." := ItemNo2;
            ValJnlBuffer."Variant Code" := VariantCode2;
            ValJnlBuffer."Location Code" := LocationCode2;
            ValJnlBuffer.Quantity := Quantity2;
            ValJnlBuffer."Quantity (Alt.)" := AltQuantity2; // P8000106A
            ValJnlBuffer."Inventory Value (Calculated)" := Amount2;
            ValJnlBuffer.Insert();
        end;
    end;

    local procedure CalcAverageUnitCost(BufferQty: Decimal; var InvtValueCalc: Decimal; var AppliedAmount: Decimal)
    var
        ValueEntry: Record "Value Entry";
        AverageQty: Decimal;
        AverageCost: Decimal;
        NotComplInvQty: Decimal;
        NotComplInvValue: Decimal;
    begin
        with ValueEntry do begin
            "Item No." := Item."No.";
            "Valuation Date" := PostingDate;
            if ValJnlBuffer.GetFilter("Location Code") <> '' then
                "Location Code" := ValJnlBuffer.GetRangeMin("Location Code");
            if ValJnlBuffer.GetFilter("Variant Code") <> '' then
                "Variant Code" := ValJnlBuffer.GetRangeMin("Variant Code");
            SumCostsTillValuationDate(ValueEntry);
            AverageQty := "Invoiced Quantity";
            AverageCost := "Cost Amount (Actual)";

            CalcNotComplInvcdTransfer(NotComplInvQty, NotComplInvValue);
            AverageQty -= NotComplInvQty;
            AverageCost -= NotComplInvValue;

            Reset;
            SetRange("Item No.", Item."No.");
            SetRange("Valuation Date", 0D, PostingDate);
            SetFilter("Location Code", ValJnlBuffer.GetFilter("Location Code"));
            SetFilter("Variant Code", ValJnlBuffer.GetFilter("Variant Code"));
            SetRange(Inventoriable, true);
            SetRange("Item Charge No.", '');
            SetFilter("Posting Date", '>%1', PostingDate);
            SetFilter("Entry Type", '<>%1', "Entry Type"::Revaluation);
            CalcSums("Invoiced Quantity", "Cost Amount (Actual)");
            AverageQty -= "Invoiced Quantity";
            AverageCost -= "Cost Amount (Actual)";
        end;

        if AverageQty <> 0 then begin
            AverageUnitCostLCY := AverageCost / AverageQty;
            if AverageUnitCostLCY < 0 then
                AverageUnitCostLCY := 0;
        end else
            AverageUnitCostLCY := 0;

        AppliedAmount := InvtValueCalc;
        InvtValueCalc := BufferQty * AverageUnitCostLCY;
    end;

    local procedure CalcNotComplInvcdTransfer(var NotComplInvQty: Decimal; var NotComplInvValue: Decimal)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        RemQty: Decimal;
        RemInvValue: Decimal;
        i: Integer;
    begin
        for i := 1 to 2 do
            with ItemLedgEntry do begin
                SetCurrentKey("Item No.", Positive, "Location Code", "Variant Code");
                SetRange("Item No.", Item."No.");
                SetRange(Positive, i = 1);
                SetFilter("Location Code", ValJnlBuffer.GetFilter("Location Code"));
                SetFilter("Variant Code", ValJnlBuffer.GetFilter("Variant Code"));
                if Find('-') then
                    repeat
                        if (GetCostingQty = GetCostingInvQty) and // P8000106A
                           not "Completely Invoiced" and
                           ("Last Invoice Date" in [0D .. PostingDate]) and
                           //("Invoiced Quantity" <> 0) // P8000267B
                           (GetCostingInvQty <> 0)      // P8000267B
                        then begin
                            RemQty := Quantity;
                            RemInvValue := CalculateRemInventoryValue("Entry No.", Quantity, Quantity, false, 0D, PostingDate);
                            NotComplInvQty := NotComplInvQty + RemQty;
                            NotComplInvValue := NotComplInvValue + RemInvValue;
                        end;
                    until Next() = 0;
            end;
    end;

    local procedure InsertItemJnlLine(EntryType2: Enum "Item Ledger Entry Type"; ItemNo2: Code[20]; VariantCode2: Code[10]; LocationCode2: Code[10]; Quantity2: Decimal; AltQuantity2: Decimal; Amount2: Decimal; ApplyToEntry2: Integer; AppliedAmount: Decimal)
    var
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
        UseNewStd: Boolean;
    begin
        // P8000106A - add parameter for alternate quantity
        Item.Get(ItemNo2);                             // P8000106A
        if CostingQty(Quantity2, AltQuantity2) = 0 then // P8000106A
            exit;

        with ItemJnlLine do begin
            if not HideDuplWarning then
                if ItemJnlLineExists(ItemJnlLine, ItemNo2, VariantCode2, LocationCode2, ApplyToEntry2) then
                    if Confirm(DuplWarningQst) then
                        HideDuplWarning := true
                    else
                        Error('');

            InitItemJnlLine(ItemJnlLine, EntryType2, ItemNo2, VariantCode2, LocationCode2);

            Validate("Unit Amount", 0);
            if ApplyToEntry2 <> 0 then
                "Inventory Value Per" := "Inventory Value Per"::" "
            else
                if ByLocation2 and ByVariant2 then
                    "Inventory Value Per" := "Inventory Value Per"::"Location and Variant"
                else
                    if ByLocation2 then
                        "Inventory Value Per" := "Inventory Value Per"::Location
                    else
                        if ByVariant2 then
                            "Inventory Value Per" := "Inventory Value Per"::Variant
                        else
                            "Inventory Value Per" := "Inventory Value Per"::Item;
            if CalculatePer = CalculatePer::"Item Ledger Entry" then begin
                "Applies-to Entry" := ApplyToEntry2;
                CopyDim(ItemLedgEntry."Dimension Set ID");
            end;
            Validate(Quantity, Quantity2);
            if AltQuantity2 <> 0 then                   // P8000106A
                Validate("Quantity (Alt.)", AltQuantity2); // P8000106A
            Validate("Inventory Value (Calculated)", Round(Amount2, GLSetup."Amount Rounding Precision"));
            case CalcBase of
                CalcBase::" ":
                    Validate("Inventory Value (Revalued)", "Inventory Value (Calculated)");
                CalcBase::"Last Direct Unit Cost":
                    if SKU.Get("Location Code", "Item No.", "Variant Code") then
                        Validate("Unit Cost (Revalued)", SKU."Last Direct Cost")
                    else begin
                        Item.Get("Item No.");
                        Validate("Unit Cost (Revalued)", Item."Last Direct Cost");
                    end;
                CalcBase::"Standard Cost - Assembly List",
                CalcBase::"Standard Cost - Manufacturing":
                    begin
                        // P8001030
                        UseNewStd := NewStdCostSKU.Get(LocationCode2, ItemNo2, VariantCode2);
                        if not UseNewStd then
                            UseNewStd := NewStdCostSKU.Get('', ItemNo2, '');
                        if UseNewStd then begin
                            //IF NewStdCostItem.GET(ItemNo2) THEN BEGIN
                            // P8001030
                            Validate("Unit Cost (Revalued)", NewStdCostSKU."Standard Cost");                 // P8001030
                            "Single-Level Material Cost" := NewStdCostSKU."Single-Level Material Cost";     // P8001030
                            "Single-Level Capacity Cost" := NewStdCostSKU."Single-Level Capacity Cost";     // P8001030
                            "Single-Level Subcontrd. Cost" := NewStdCostSKU."Single-Level Subcontrd. Cost"; // P8001030
                            "Single-Level Cap. Ovhd Cost" := NewStdCostSKU."Single-Level Cap. Ovhd Cost";   // P8001030
                            "Single-Level Mfg. Ovhd Cost" := NewStdCostSKU."Single-Level Mfg. Ovhd Cost";   // P8001030
                            "Rolled-up Material Cost" := NewStdCostSKU."Rolled-up Material Cost";           // P8001030
                            "Rolled-up Capacity Cost" := NewStdCostSKU."Rolled-up Capacity Cost";           // P8001030
                            "Rolled-up Subcontracted Cost" := NewStdCostSKU."Rolled-up Subcontracted Cost"; // P8001030
                            "Rolled-up Mfg. Ovhd Cost" := NewStdCostSKU."Rolled-up Mfg. Ovhd Cost";         // P8001030
                            "Rolled-up Cap. Overhead Cost" := NewStdCostSKU."Rolled-up Cap. Overhead Cost"; // P8001030
                            UpdatedStdCostSKU."Item No." := ItemNo2;
                            UpdatedStdCostSKU."Location Code" := LocationCode2;
                            UpdatedStdCostSKU."Variant Code" := VariantCode2;
                            if UpdatedStdCostSKU.Insert() then;
                        end else
                            Validate("Inventory Value (Revalued)", "Inventory Value (Calculated)");
                    end;
            end;
            "Update Standard Cost" := UpdStdCost;
            "Partial Revaluation" := true;
            "Applied Amount" := AppliedAmount;
            Insert;
            OnAfterInsertItemJnlLine(ItemJnlLine, EntryType2, ItemNo2, VariantCode2, LocationCode2, Quantity2, Amount2, ApplyToEntry2, AppliedAmount);
        end;
    end;

    local procedure InitItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; EntryType2: Enum "Item Ledger Entry Type"; ItemNo2: Code[20]; VariantCode2: Code[10]; LocationCode2: Code[10])
    begin
        with ItemJnlLine do begin
            if NextLineNo = 0 then begin
                LockTable();
                SetRange("Journal Template Name", "Journal Template Name");
                SetRange("Journal Batch Name", "Journal Batch Name");
                if FindLast then
                    NextLineNo := "Line No.";
            end;

            NextLineNo := NextLineNo + 10000;
            Init;
            "Line No." := NextLineNo;
            "Value Entry Type" := "Value Entry Type"::Revaluation;

            OnInitItemJnlLineOnBeforeValidateFields(ItemJnlLine);

            Validate("Posting Date", PostingDate);
            Validate("Entry Type", EntryType2);
            Validate("Document No.", NextDocNo);
            Validate("Item No.", ItemNo2);
            "Reason Code" := ItemJnlBatch."Reason Code";
            "Variant Code" := VariantCode2;
            "Location Code" := LocationCode2;
            "Source Code" := SourceCodeSetup."Revaluation Journal";
        end;

        OnAfterInitItemJnlLine(ItemJnlLine, ItemJnlBatch);
    end;

    procedure InitializeRequest(NewPostingDate: Date; NewDocNo: Code[20]; NewHideDuplWarning: Boolean; NewCalculatePer: Option; NewByLocation: Boolean; NewByVariant: Boolean; NewUpdStdCost: Boolean; NewCalcBase: Option; NewShowDialog: Boolean)
    begin
        PostingDate := NewPostingDate;
        NextDocNo := NewDocNo;
        CalculatePer := NewCalculatePer;
        ByLocation := NewByLocation;
        ByVariant := NewByVariant;
        UpdStdCost := NewUpdStdCost;
        CalcBase := NewCalcBase;
        ShowDialog := NewShowDialog;
        HideDuplWarning := NewHideDuplWarning;
    end;

    local procedure PageValidateCalcLevel()
    begin
        UpdStdCostEnable := true;
        if CalculatePer = CalculatePer::"Item Ledger Entry" then begin
            ByLocation := false;
            ByVariant := false;
            CalcBase := CalcBase::" ";
            UpdStdCost := false;
            UpdStdCostEnable := false;
        end;
    end;

    local procedure ItemLedgerEntryCalculatePerOnV()
    begin
        ValidateCalcLevel;
    end;

    local procedure ItemCalculatePerOnValidate()
    begin
        ValidateCalcLevel;
    end;

    local procedure ItemJnlLineExists(ItemJnlLine: Record "Item Journal Line"; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; ApplyToEntry: Integer): Boolean
    begin
        with ItemJnlLine do begin
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            SetRange("Item No.", ItemNo);
            SetRange("Variant Code", VariantCode);
            SetRange("Location Code", LocationCode);
            SetRange("Applies-to Entry", ApplyToEntry);
            exit(not IsEmpty);
        end;
    end;

    local procedure CalcRemainingCost(ItemLedgerEntry: Record "Item Ledger Entry"; RemainingQty: Decimal; IncludeExpCost: Boolean): Decimal
    var
        UntilValuationDate: Date;
        UntilPostingDate: Date;
    begin
        if ItemLedgerEntry."Entry Type" in [ItemLedgerEntry."Entry Type"::Output, ItemLedgerEntry."Entry Type"::"Assembly Output"] then
            UntilPostingDate := PostingDate
        else
            UntilValuationDate := PostingDate;

        case CalculatePer of
            CalculatePer::"Item Ledger Entry":
                exit(
                  ItemLedgerEntry.CalculateRemInventoryValue(
                    ItemLedgerEntry."Entry No.", ItemLedgerEntry.Quantity, RemainingQty, false, UntilValuationDate, UntilPostingDate));
            CalculatePer::Item:
                exit(
                  ItemLedgerEntry.CalculateRemInventoryValue(
                    ItemLedgerEntry."Entry No.", ItemLedgerEntry.Quantity, RemainingQty,
                    IncludeExpCost and not ItemLedgerEntry."Completely Invoiced", UntilValuationDate, UntilPostingDate));
        end;

        exit(0);
    end;

    local procedure CostingQty(Qty: Decimal; AltQty: Decimal): Decimal
    begin
        // P8000106A
        if Item.CostInAlternateUnits then
            exit(AltQty)
        else
            exit(Qty);
    end;

    local procedure Calculate(Item: Record Item; VariantCode: Code[10]; LocationCode: Code[10])
    var
        AppliedAmount: Decimal;
    begin
        ValJnlBuffer."Item No." := Item."No."; // P8008177
        ValJnlBuffer.CalcSums(Quantity, "Quantity (Alt.)", "Inventory Value (Calculated)"); // P8007748
        if ValJnlBuffer.GetCostingQty <> 0 then begin // P8007748
            AppliedAmount := 0;
            if Item."Costing Method" = Item."Costing Method"::Average then
                CalcAverageUnitCost(
                  ValJnlBuffer.GetCostingQty, ValJnlBuffer."Inventory Value (Calculated)", AppliedAmount); // P8007748
            InsertItemJnlLine(
                ItemJnlLine."Entry Type"::"Positive Adjmt.",
                Item."No.", VariantCode, LocationCode, ValJnlBuffer.Quantity, ValJnlBuffer."Quantity (Alt.)", ValJnlBuffer."Inventory Value (Calculated)", // P8007748
                0, AppliedAmount);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; ItemJnlBatch: Record "Item Journal Batch")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; EntryType2: Enum "Item Ledger Entry Type"; ItemNo2: Code[20]; VariantCode2: Code[10]; LocationCode2: Code[10]; Quantity2: Decimal; Amount2: Decimal; ApplyToEntry2: Integer; AppliedAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOnPreDataItem(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnAfterGetRecord(var Item: Record Item; var SkipItem: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePreReport()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitItemJnlLineOnBeforeValidateFields(var ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnItemAfterGetRecordOnAfterItemLedgEntrySetFilters(var ItemLedgerEntry: Record "Item Ledger Entry"; var Item: Record Item)
    begin
    end;
}

