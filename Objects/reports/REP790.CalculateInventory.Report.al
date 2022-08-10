report 790 "Calculate Inventory"
{
    // PR2.00
    //   Support for physical count with item tracking
    // 
    // PR3.10
    //   Fix for creation of buffer entries (lot and serial had data from prior records)
    // 
    // PR3.60
    //   Add logic for alternate quantities
    //   Update for new item tracking
    // 
    // PR3.61
    //   Update for new item tracking and containers
    // 
    // PR3.61.01
    //   Update to accommodate changes made in improvement 026
    // 
    // PR3.70.06
    // P8000069A, Myers Nissi, Jack Reynolds, 19 JUL 04
    //   Modify to use SIFT if no dimensions are selected
    //   Modify handling of default dimensions when inserting item journal lines
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Changes have been made to the standard report; functionally there are no changes for P800 although a number of
    //     changes have been made to work the P800 modifications into the new standard report code
    // 
    // PR4.00.02
    // P8000308A, VerticalSoft, Jack Reynolds, 10 MAR 06
    //   Add option to set physical count to zero
    // 
    // PR4.00.04
    // P8000349A, VerticalSoft, Jack Reynolds, 10 JUL 06
    //   Fix problem with updating reservation entries for alt. qty. items
    // 
    // PRW15.00.01
    // P8000561A, VerticalSoft, Jack Reynolds, 22 JAN 08
    //   Fix problem with sort order and drop shipments causing entries to be skipped
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    //   Add "Bin Code" to containers
    // 
    // PRW16.00
    // P8000646, VerticalSoft, Jack Reynolds, 01 DEC 08
    //   Add "Set Count to Zero" to request page
    // 
    // PRW16.00.01
    // P8000728, VerticalSoft, Don Bresee, 15 SEP 09
    //   Fix 1 & 2 Doc issue
    // 
    // PRW16.00.03
    // P8000792, VerticalSoft, Rick Tweedle, 17 MAR 10
    //   Converted using TIF Editor
    // 
    // PRW16.00.04
    // P8000896, VerticalSoft, Jack Reynolds, 20 JAN 11
    //   Fix problem counting second and subsequent lots in a bin
    // 
    // PRW16.00.06
    // P8001052, Columbus IT, Jack Reynolds, 03 APR 12
    //   Set count to zero for cycle counts
    // 
    // PRW17.10
    // P8001213, Columbus IT, Jack Reynolds, 26 SEP 13
    //   NAV 2013 R2 changes
    // 
    // PRW17.10.01
    // P8001256, Columbus IT, Jack Reynolds, 09 JAN 14
    //   Fix error checking alternate quantity for item being inserted into journal
    // 
    // PRW17.10.02
    // P8001269, Columbus IT, Jack Reynolds, 23 JAN 14
    //   Fix problem calculating lot detail
    // 
    // PRW18.00.01
    // P8001372, Columbus IT, Don Bresee, 03 FEB 15
    //   Use Open field on Item Ledger Entries when no date filter is used
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Calculate Inventory';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.") WHERE(Type = FILTER(Inventory | FOODContainer), Blocked = CONST(false));
            RequestFilterFields = "No.", "Location Filter", "Bin Filter";
            dataitem("Item Ledger Entry"; "Item Ledger Entry")
            {
                DataItemLink = "Item No." = FIELD("No."), "Variant Code" = FIELD("Variant Filter"), "Location Code" = FIELD("Location Filter"), "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"), "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter");
                DataItemTableView = SORTING("Item No.", "Variant Code", "Drop Shipment", "Location Code", "Lot No.", "Serial No.");

                trigger OnAfterGetRecord()
                var
                    ItemVariant: Record "Item Variant";
                    ByBin: Boolean;
                    ExecuteLoop: Boolean;
                    InsertTempSKU: Boolean;
                    IsHandled: Boolean;
                begin
                    if not GetLocation("Location Code") then
                        CurrReport.Skip();

                    if ("Location Code" <> '') and Location."Use As In-Transit" then
                        CurrReport.Skip();
                    if not UseSIFT then // P8000267B
                        if ColumnDim <> '' then
                            TransferDim("Dimension Set ID");

                    if not "Drop Shipment" then
                        ByBin := Location."Bin Mandatory" and not Location."Directed Put-away and Pick";

                    IsHandled := false;
                    OnAfterGetRecordItemLedgEntryOnBeforeUpdateBuffer(Item, "Item Ledger Entry", ByBin, IsHandled);
                    if IsHandled then
                        CurrReport.Skip();

                    if not SkipCycleSKU("Location Code", "Item No.", "Variant Code") then
                        if ByBin then begin
                            if not TempSKU.Get("Location Code", "Item No.", "Variant Code") then begin
                                InsertTempSKU := false;
                                if "Variant Code" = '' then
                                    InsertTempSKU := true
                                else
                                    if ItemVariant.Get("Item No.", "Variant Code") then
                                        InsertTempSKU := true;
                                if InsertTempSKU then begin
                                    TempSKU."Item No." := "Item No.";
                                    TempSKU."Variant Code" := "Variant Code";
                                    TempSKU."Location Code" := "Location Code";
                                    TempSKU.Insert();
                                    ExecuteLoop := true;
                                end;
                            end;
                            if ExecuteLoop then begin
                                WhseEntry.SetRange("Item No.", "Item No.");
                                WhseEntry.SetRange("Location Code", "Location Code");
                                WhseEntry.SetRange("Variant Code", "Variant Code");
                                if WhseEntry.Find('-') then
                                    //IF WhseEntry."Entry No." <> OldWhseEntry."Entry No." THEN BEGIN // P8000896
                                    //  OldWhseEntry := WhseEntry;                                    // P8000896
                                    repeat
                                        WhseEntry.SetRange("Bin Code", WhseEntry."Bin Code");
                                        // P8000631A
                                        WhseEntry.SetRange("Unit of Measure Code", WhseEntry."Unit of Measure Code");
                                        WhseEntry.SetRange("Lot No.", WhseEntry."Lot No.");
                                        WhseEntry.SetRange("Serial No.", WhseEntry."Serial No.");
                                        // P8000631A
                                        //IF NOT ItemBinLocationIsCalculated(WhseEntry."Bin Code") THEN BEGIN // P8000896
                                        //WhseEntry.CALCSUMS("Qty. (Base)");         // P8000631A
                                        WhseEntry.CalcSums("Remaining Qty. (Base)"); // P8000631A
                                        UpdateBuffer(WhseEntry."Bin Code", WhseEntry."Remaining Qty. (Base)", 0, false); // PR3.70, P8000631A
                                                                                                                  //END; // P8000896
                                        WhseEntry.Find('+');
                                        // P8000631A
                                        WhseEntry.SetRange("Unit of Measure Code");
                                        WhseEntry.SetRange("Lot No.");
                                        WhseEntry.SetRange("Serial No.");
                                        // P8000631A
                                        Item.CopyFilter("Bin Filter", WhseEntry."Bin Code");
                                    until WhseEntry.Next() = 0;
                                DistributeAltQty; // P8000631A
                                                  //END;
                            end;
                            // P8000069A Begin
                        end else
                            if UseSIFT then begin
                                SetRange("Variant Code", "Variant Code");
                                SetRange("Location Code", "Location Code");
                                SetRange("Lot No.", "Lot No.");
                                SetRange("Serial No.", "Serial No.");
                                if ByDate then begin // P8001372
                                    CalcSums(Quantity, "Quantity (Alt.)");
                                    UpdateBuffer('', Quantity, "Quantity (Alt.)", true);
                                    // P8001372
                                end else begin
                                    CalcSums("Remaining Quantity", "Remaining Quantity (Alt.)");
                                    UpdateBuffer('', "Remaining Quantity", "Remaining Quantity (Alt.)", true);
                                end;
                                // P8001372
                                Find('+');
                                SetRange("Variant Code");
                                SetRange("Location Code");
                                SetRange("Lot No.");
                                SetRange("Serial No.");
                                // P8000069A End
                            end else
                                // P8001372
                                // UpdateBuffer('',Quantity,"Quantity (Alt.)"); // PR3.61.01
                                if ByDate then
                                    UpdateBuffer('', Quantity, "Quantity (Alt.)", true)
                                else
                                    UpdateBuffer('', "Remaining Quantity", "Remaining Quantity (Alt.)", true);
                    // P8001372
                end;

                trigger OnPreDataItem()
                begin
                    // P8000896
                    //IF UseSIFT THEN                                                                                    // P8000069A
                    //  SETCURRENTKEY("Item No.","Variant Code","Drop Shipment","Location Code","Lot No.","Serial No."); // P8000069A
                    // P8000896
                    SetRange("Drop Shipment", false); // P8000561A

                    // P8000631A
                    //WhseEntry.SetCurrentKey("Item No.","Bin Code","Location Code","Variant Code");
                    WhseEntry.SetCurrentKey(
                      "Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code", Open, "Lot No.", "Serial No.");
                    WhseEntry.SetRange(Open, true);
                    // P8000631A
                    Item.CopyFilter("Bin Filter", WhseEntry."Bin Code");

                    // P8001213
                    //ItemTrackingBuffer.RESET;     // PR2.00
                    //ItemTrackingBuffer.DELETEALL; // PR2.00
                    // P8001213

                    if ColumnDim = '' then
                        TempDimBufIn.SetRange("Table ID", DATABASE::Item)
                    else
                        TempDimBufIn.SetRange("Table ID", DATABASE::"Item Ledger Entry");
                    TempDimBufIn.SetRange("Entry No.");
                    TempDimBufIn.DeleteAll();

                    OnItemLedgerEntryOnAfterPreDataItem("Item Ledger Entry", Item);
                end;
            }
            dataitem("Warehouse Entry"; "Warehouse Entry")
            {
                DataItemLink = "Item No." = FIELD("No."), "Variant Code" = FIELD("Variant Filter"), "Location Code" = FIELD("Location Filter");

                trigger OnAfterGetRecord()
                begin
                    // if not "Item Ledger Entry".IsEmpty() then                                   // P8001372
                    //   CurrReport.Skip();   // Skip if item has any record in Item Ledger Entry. // P8001372

                    Clear(QuantityOnHandBuffer);
                    QuantityOnHandBuffer."Item No." := "Item No.";
                    QuantityOnHandBuffer."Location Code" := "Location Code";
                    QuantityOnHandBuffer."Variant Code" := "Variant Code";

                    GetLocation("Location Code");
                    if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then
                        QuantityOnHandBuffer."Bin Code" := "Bin Code";

                    OnBeforeQuantityOnHandBufferFindAndInsert(QuantityOnHandBuffer, "Warehouse Entry");
                    if not QuantityOnHandBuffer.Find then
                        QuantityOnHandBuffer.Insert();   // Insert a zero quantity line.
                end;

                trigger OnPreDataItem()
                begin
                    if not "Item Ledger Entry".IsEmpty then // P8001372
                        CurrReport.Break;                     // P8001372
                end;
            }
            dataitem(ItemWithNoTransaction; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

                trigger OnAfterGetRecord()
                begin
                    if IncludeItemWithNoTransaction then
                        UpdateQuantityOnHandBuffer(Item."No.");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                OnBeforeItemOnAfterGetRecord(Item);
                if not HideValidationDialog then
                    Window.Update(1, "No."); // P8000631A

                // PR2.00 Begin
                if "Item Tracking Code" <> '' then
                    ItemTracking.Get("Item Tracking Code")
                else
                    Clear(ItemTracking);
                // PR2.00 End
                TempSKU.DeleteAll();
                if ProcessFns.ContainerTrackingInstalled then                          // P8001323
                    ContainerFns.ContainerDetailForPhysical(Item, ContainerDetailBuffer); // P8001323
            end;

            trigger OnPostDataItem()
            begin
                CalcPhysInvQtyAndInsertItemJnlLine;
            end;

            trigger OnPreDataItem()
            var
                ItemJnlTemplate: Record "Item Journal Template";
                ItemJnlBatch: Record "Item Journal Batch";
            begin
                if PostingDate = 0D then
                    Error(Text000);

                ItemJnlTemplate.Get(ItemJnlLine."Journal Template Name");
                ItemJnlBatch.Get(ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name");

                OnPreDataItemOnAfterGetItemJnlTemplateAndBatch(ItemJnlTemplate, ItemJnlBatch);

                if NextDocNo = '' then begin
                    if ItemJnlBatch."No. Series" <> '' then begin
                        ItemJnlLine.SetRange("Journal Template Name", ItemJnlLine."Journal Template Name");
                        ItemJnlLine.SetRange("Journal Batch Name", ItemJnlLine."Journal Batch Name");
                        if not ItemJnlLine.FindFirst() then
                            NextDocNo := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", PostingDate, false);
                        ItemJnlLine.Init();
                    end;
                    if NextDocNo = '' then
                        Error(Text001);
                end;

                NextLineNo := 0;

                if not HideValidationDialog then
                    Window.Open(Text002, "No.");

                if not SkipDim then
                    SelectedDim.GetSelectedDim(UserId, 3, REPORT::"Calculate Inventory", '', TempSelectedDim);

                QuantityOnHandBuffer.Reset();

                // P8000069A Begin
                UseSIFT := (Item.GetFilter("Global Dimension 1 Code") = '') and
                  (Item.GetFilter("Global Dimension 2 Code") = '') and
                  (not TempSelectedDim.Find('-'));
                // P8000069A End

                ByDate := (Item.GetFilter("Date Filter") <> ''); // P8001372

                OnAfterItemOnPreDataItem(Item, ZeroQty, IncludeItemWithNoTransaction);
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

                        trigger OnValidate()
                        begin
                            ValidatePostingDate;
                        end;
                    }
                    field(DocumentNo; NextDocNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the number of the document that is processed by the report or batch job.';
                    }
                    field(ItemsNotOnInventory; ZeroQty)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Items Not on Inventory.';
                        ToolTip = 'Specifies if journal lines should be created for items that are not on inventory, that is, items where the value in the Qty. (Calculated) field is 0.';

                        trigger OnValidate()
                        begin
                            if not ZeroQty then
                                IncludeItemWithNoTransaction := false;
                        end;
                    }
                    field(IncludeItemWithNoTransaction; IncludeItemWithNoTransaction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Include Item without Transactions';
                        ToolTip = 'Specifies if journal lines should be created for items that are not on inventory and are not used in any transactions.';

                        trigger OnValidate()
                        begin
                            if not IncludeItemWithNoTransaction then
                                exit;
                            if not ZeroQty then
                                Error(ItemNotOnInventoryErr);
                        end;
                    }
                    field(SetCountToZero; SetCountToZero)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Set Count to Zero';
                    }
                    field(ByDimensions; ColumnDim)
                    {
                        ApplicationArea = Dimensions;
                        Caption = 'By Dimensions';
                        Editable = false;
                        ToolTip = 'Specifies the dimensions that you want the batch job to consider.';

                        trigger OnAssistEdit()
                        begin
                            DimSelectionBuf.SetDimSelectionMultiple(3, REPORT::"Calculate Inventory", ColumnDim);
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if PostingDate = 0D then
                PostingDate := WorkDate;
            ValidatePostingDate;
            ColumnDim := DimSelectionBuf.GetDimSelectionText(3, REPORT::"Calculate Inventory", '');
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        OnBeforeOnPreReport(ItemJnlLine, PostingDate);

        if SkipDim then
            ColumnDim := ''
        else
            DimSelectionBuf.CompareDimText(3, REPORT::"Calculate Inventory", '', ColumnDim, Text003);
        ZeroQtySave := ZeroQty;
    end;

    var
        Text000: Label 'Enter the posting date.';
        Text001: Label 'Enter the document no.';
        Text002: Label 'Processing items    #1##########';
        Text003: Label 'Retain Dimensions';
        ItemJnlBatch: Record "Item Journal Batch";
        ItemJnlLine: Record "Item Journal Line";
        WhseEntry: Record "Warehouse Entry";
        SourceCodeSetup: Record "Source Code Setup";
        DimSetEntry: Record "Dimension Set Entry";
        OldWhseEntry: Record "Warehouse Entry";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        SelectedDim: Record "Selected Dimension";
        TempSelectedDim: Record "Selected Dimension" temporary;
        TempDimBufIn: Record "Dimension Buffer" temporary;
        TempDimBufOut: Record "Dimension Buffer" temporary;
        DimSelectionBuf: Record "Dimension Selection Buffer";
        Location: Record Location;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DimBufMgt: Codeunit "Dimension Buffer Management";
        Window: Dialog;
        CycleSourceType: Option " ",Item,SKU;
        PhysInvtCountCode: Code[10];
        NextLineNo: Integer;
        ZeroQtySave: Boolean;
        AdjustPosQty: Boolean;
        ItemTrackingSplit: Boolean;
        SkipDim: Boolean;
        PosQty: Decimal;
        NegQty: Decimal;
        ItemNotOnInventoryErr: Label 'Items Not on Inventory.';
        ItemTracking: Record "Item Tracking Code";
        ItemTrackingBuffer: Record "Item Tracking Buffer" temporary;
        ContainerDetailBuffer: Record "Container Line" temporary;
        ProcessFns: Codeunit "Process 800 Functions";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        ContainerFns: Codeunit "Container Functions";
        UseSIFT: Boolean;
        SetCountToZero: Boolean;
        ByDate: Boolean;

    protected var
        QuantityOnHandBuffer: Record "Inventory Buffer" temporary;
        TempSKU: Record "Stockkeeping Unit" temporary;
        HideValidationDialog: Boolean;
        PostingDate: Date;
        NextDocNo: Code[20];
        ZeroQty: Boolean;
        IncludeItemWithNoTransaction: Boolean;
        ColumnDim: Text[250];

    procedure SetItemJnlLine(var NewItemJnlLine: Record "Item Journal Line")
    begin
        ItemJnlLine := NewItemJnlLine;
    end;

    local procedure ValidatePostingDate()
    begin
        if not ItemJnlBatch.Get(ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name") then
            exit;

        if ItemJnlBatch."No. Series" = '' then
            NextDocNo := ''
        else begin
            NextDocNo := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", PostingDate, false);
            Clear(NoSeriesMgt);
        end;
    end;

    procedure InsertItemJnlLine(ItemNo: Code[20]; VariantCode2: Code[10]; DimEntryNo2: Integer; BinCode2: Code[20]; Quantity2: Decimal; PhysInvQuantity: Decimal)
    begin
        // P80096141 - Original signature
        InsertItemJnlLine(ItemNo, VariantCode2, DimEntryNo2, BinCode2, Quantity2, 0, PhysInvQuantity, 0, '', '', '', '');
    end;

    procedure InsertItemJnlLine(ItemNo: Code[20]; VariantCode2: Code[10]; DimEntryNo2: Integer; BinCode2: Code[20]; Quantity2: Decimal; AltQuantity2: Decimal; PhysInvQuantity: Decimal; PhysInvQuantityAlt: Decimal; UOMCode: Code[10]; LotNo: Code[50]; SerialNo: Code[50]; ContID: Code[20])
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        Bin: Record Bin;
        DimValue: Record "Dimension Value";
        DimMgt: Codeunit DimensionManagement;
        NoBinExist: Boolean;
        ShouldInsertItemJnlLine: Boolean;
        IsHandled: Boolean;
        OrderLineNo: Integer;
        Item2: Record Item;
        ContainerHeader: Record "Container Header";
    begin
        IsHandled := false;
        OnBeforeFunctionInsertItemJnlLine(ItemNo, VariantCode2, DimEntryNo2, BinCode2, Quantity2, PhysInvQuantity, ItemJnlLine, IsHandled);
        if not IsHandled then

            with ItemJnlLine do begin
                if NextLineNo = 0 then begin
                    LockTable();
                    SetRange("Journal Template Name", "Journal Template Name");
                    SetRange("Journal Batch Name", "Journal Batch Name");
                    if FindLast then
                        NextLineNo := "Line No.";

                    SourceCodeSetup.Get();
                end;
                NextLineNo := NextLineNo + 10000;
                ShouldInsertItemJnlLine := (Quantity2 <> 0) or (AltQuantity2 <> 0) or ZeroQty; // PR3.60
                OnInsertItemJnlLineOnAfterCalcShouldInsertItemJnlLine(ItemNo, VariantCode2, DimEntryNo2, BinCode2, Quantity2, PhysInvQuantity, ZeroQty, ShouldInsertItemJnlLine);
                if ShouldInsertItemJnlLine or ZeroQty then begin
                    if (Quantity2 = 0) and Location."Bin Mandatory" and not Location."Directed Put-away and Pick"
                    then
                        if not Bin.Get(Location.Code, BinCode2) then
                            NoBinExist := true;

                    if ContID <> '' then           // P8001323
                        ContainerHeader.Get(ContID); // P8001323

                    OnInsertItemJnlLineOnBeforeInit(ItemJnlLine);

                    Init;
                    "Line No." := NextLineNo;
                    Validate("Posting Date", PostingDate);
                    if PhysInvQuantity >= Quantity2 then
                        Validate("Entry Type", "Entry Type"::"Positive Adjmt.")
                    else
                        Validate("Entry Type", "Entry Type"::"Negative Adjmt.");
                    Validate("Document No.", NextDocNo);
                    Validate("Item No.", ItemNo);
                    if UOMCode <> '' then                       // PR3.61
                        Validate("Unit of Measure Code", UOMCode); // PR3.61
                    Validate("Variant Code", VariantCode2);
                    Validate("Location Code", Location.Code);
                    OnInsertItemJnlLineOnAfterValidateLocationCode(ItemNo, VariantCode2, DimEntryNo2, BinCode2, Quantity2, PhysInvQuantity, ItemJnlLine);
                    if not NoBinExist then
                        Validate("Bin Code", BinCode2)
                    else
                        Validate("Bin Code", '');
                    Validate("Source Code", SourceCodeSetup."Phys. Inventory Journal");
                    "Lot No." := LotNo;       // PR3.61
                    "Serial No." := SerialNo; // PR3.61
                    if (not SetCountToZero) or (ContainerHeader."Document Type" <> 0) then // P8000308A, P8001323
                        "Qty. (Phys. Inventory)" := PhysInvQuantity;
                    "Phys. Inventory" := true;
                    Validate("Qty. (Calculated)", Quantity2);
                    "Posting No. Series" := ItemJnlBatch."Posting No. Series";
                    "Reason Code" := ItemJnlBatch."Reason Code";

                    "Phys Invt Counting Period Code" := PhysInvtCountCode;
                    "Phys Invt Counting Period Type" := CycleSourceType;

                    if Location."Bin Mandatory" then
                        "Dimension Set ID" := 0;
                    "Shortcut Dimension 1 Code" := '';
                    "Shortcut Dimension 2 Code" := '';

                    ItemLedgEntry.Reset();
                    ItemLedgEntry.SetCurrentKey("Item No.");
                    ItemLedgEntry.SetRange("Item No.", ItemNo);
                    if ItemLedgEntry.FindLast then
                        "Last Item Ledger Entry No." := ItemLedgEntry."Entry No."
                    else
                        "Last Item Ledger Entry No." := 0;

                    OnBeforeInsertItemJnlLine(ItemJnlLine, QuantityOnHandBuffer);
                    Insert(true);
                    OnAfterInsertItemJnlLine(ItemJnlLine);

                    // P8000308A
                    if Item.TrackAlternateUnits() then begin
                        Validate("Qty. (Alt.) (Calculated)", AltQuantity2);
                        if SetCountToZero then
                            Validate("Qty. (Alt.) (Phys. Inventory)", 0)
                        else
                            Validate("Qty. (Alt.) (Phys. Inventory)", PhysInvQuantityAlt);
                        if Item."Catch Alternate Qtys." then
                            AltQtyMgmt.ValidateItemJnlAltQtyLine(ItemJnlLine);
                    end;
                    // P8001323

                    if ContID <> '' then begin
                        "Shipping Container" := ContainerHeader."Document Type" <> 0;
                        "Container License Plate" := ContainerHeader."License Plate";
                        if "Entry Type" = "Entry Type"::"Positive Adjmt." then begin
                            "New Container License Plate" := ContainerHeader."License Plate";
                            "New Container ID" := ContainerHeader.ID;
                        end else begin
                            "Old Container License Plate" := ContainerHeader."License Plate";
                            "Old Container ID" := ContainerHeader.ID;
                        end;
                    end;

                    Modify(true); // P8000349A
                                  // P8000308A

                    if Location.Code <> '' then
                        if Location."Directed Put-away and Pick" then
                            ReserveWarehouse(ItemJnlLine);

                    if ColumnDim = '' then
                        DimEntryNo2 := CreateDimFromItemDefault;

                    if DimBufMgt.GetDimensions(DimEntryNo2, TempDimBufOut) then begin
                        TempDimSetEntry.Reset();
                        TempDimSetEntry.DeleteAll();
                           if TempDimBufOut.Find('-') then begin
                            repeat
                                DimValue.Get(TempDimBufOut."Dimension Code", TempDimBufOut."Dimension Value Code");
                                TempDimSetEntry."Dimension Code" := TempDimBufOut."Dimension Code";
                                TempDimSetEntry."Dimension Value Code" := TempDimBufOut."Dimension Value Code";
                                TempDimSetEntry."Dimension Value ID" := DimValue."Dimension Value ID";
                                if TempDimSetEntry.Insert() then;
                                "Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
                                DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID",
                                  "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
                                OnInsertItemJnlLineOnAfterUpdateDimensionSetID(ItemJnlLine);
                                Modify;
                            until TempDimBufOut.Next() = 0;
                            TempDimBufOut.DeleteAll();
                        end;
                    end;
               end;
            end;

        OnAfterFunctionInsertItemJnlLine(ItemNo, VariantCode2, DimEntryNo2, BinCode2, Quantity2, PhysInvQuantity, ItemJnlLine);
    end;

    local procedure InsertQuantityOnHandBuffer(ItemNo: Code[20]; LocationCode: Code[10]; VariantCode: Code[10])
    begin
        with QuantityOnHandBuffer do begin
            Reset;
            SetRange("Item No.", ItemNo);
            SetRange("Location Code", LocationCode);
            SetRange("Variant Code", VariantCode);
            if not FindFirst() then begin
                Reset;
                Init;
                "Item No." := ItemNo;
                "Location Code" := LocationCode;
                "Variant Code" := VariantCode;
                "Bin Code" := '';
                "Dimension Entry No." := 0;
                Insert(true);
            end;
        end;
    end;

    local procedure ReserveWarehouse(ItemJnlLine: Record "Item Journal Line")
    var
        ReservEntry: Record "Reservation Entry";
        WhseEntry: Record "Warehouse Entry";
        WhseEntry2: Record "Warehouse Entry";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        EntryType: Option "Negative Adjmt.","Positive Adjmt.";
        OrderLineNo: Integer;
    begin
        with ItemJnlLine do begin
            WhseEntry.SetCurrentKey(
                "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code",
                "Lot No.", "Serial No.", "Entry Type");
            WhseEntry.SetRange("Item No.", "Item No.");
            WhseEntry.SetRange("Bin Code", Location."Adjustment Bin Code");
            WhseEntry.SetRange("Location Code", "Location Code");
            WhseEntry.SetRange("Variant Code", "Variant Code");
            if "Entry Type" = "Entry Type"::"Positive Adjmt." then
                EntryType := EntryType::"Negative Adjmt.";
            if "Entry Type" = "Entry Type"::"Negative Adjmt." then
                EntryType := EntryType::"Positive Adjmt.";
            OnAfterWhseEntrySetFilters(WhseEntry, ItemJnlLine);
            WhseEntry.SetRange("Entry Type", EntryType);
            if WhseEntry.Find('-') then
                repeat
                    WhseEntry.SetTrackingFilterFromWhseEntry(WhseEntry);
                    WhseEntry.CalcSums("Qty. (Base)");

                    WhseEntry2.SetCurrentKey(
                        "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code",
                        "Lot No.", "Serial No.", "Entry Type");
                    WhseEntry2.CopyFilters(WhseEntry);
                    case EntryType of
                        EntryType::"Positive Adjmt.":
                            WhseEntry2.SetRange("Entry Type", WhseEntry2."Entry Type"::"Negative Adjmt.");
                        EntryType::"Negative Adjmt.":
                            WhseEntry2.SetRange("Entry Type", WhseEntry2."Entry Type"::"Positive Adjmt.");
                    end;
                    OnReserveWarehouseOnAfterWhseEntry2SetFilters(ItemJnlLine, WhseEntry, WhseEntry2, EntryType);
                    WhseEntry2.CalcSums("Qty. (Base)");
                    if Abs(WhseEntry2."Qty. (Base)") > Abs(WhseEntry."Qty. (Base)") then
                        WhseEntry."Qty. (Base)" := 0
                    else
                        WhseEntry."Qty. (Base)" := WhseEntry."Qty. (Base)" + WhseEntry2."Qty. (Base)";

                    if WhseEntry."Qty. (Base)" <> 0 then begin
                        if "Order Type" = "Order Type"::Production then
                            OrderLineNo := "Order Line No.";
                        ReservEntry.CopyTrackingFromWhseEntry(WhseEntry);
                        CreateReservEntry.CreateReservEntryFor(
                            DATABASE::"Item Journal Line", "Entry Type".AsInteger(), "Journal Template Name", "Journal Batch Name", OrderLineNo,
                            "Line No.", "Qty. per Unit of Measure",
                            Abs(WhseEntry.Quantity), Abs(WhseEntry."Qty. (Base)"), ReservEntry);
                        if WhseEntry."Qty. (Base)" < 0 then             // only Date on positive adjustments
                            CreateReservEntry.SetDates(WhseEntry."Warranty Date", WhseEntry."Expiration Date");
                        CreateReservEntry.CreateEntry(
                            "Item No.", "Variant Code", "Location Code", Description, 0D, 0D, 0, "Reservation Status"::Prospect);
                    end;
                    WhseEntry.Find('+');
                    WhseEntry.ClearTrackingFilter;
                until WhseEntry.Next() = 0;
        end;
    end;

    procedure InitializeRequest(NewPostingDate: Date; DocNo: Code[20]; ItemsNotOnInvt: Boolean; InclItemWithNoTrans: Boolean)
    begin
        PostingDate := NewPostingDate;
        NextDocNo := DocNo;
        ZeroQty := ItemsNotOnInvt;
        IncludeItemWithNoTransaction := InclItemWithNoTrans and ZeroQty;
        if not SkipDim then
            ColumnDim := DimSelectionBuf.GetDimSelectionText(3, REPORT::"Calculate Inventory", '');
    end;

    procedure InitializeRequest(NewPostingDate: Date; DocNo: Code[20]; ItemsNotOnInvt: Boolean; ZeroCount: Boolean; InclItemWithNoTrans: Boolean)
    begin
        // P8001052 - add parameter for ZeroCount
        InitializeRequest(NewPostingDate, DocNo, ItemsNotOnInvt, InclItemWithNoTrans);
        SetCountToZero := ZeroCount; // P8001052
    end;

    local procedure TransferDim(DimSetID: Integer)
    begin
        DimSetEntry.SetRange("Dimension Set ID", DimSetID);
        if DimSetEntry.Find('-') then begin
            repeat
                if TempSelectedDim.Get(
                     UserId, 3, REPORT::"Calculate Inventory", '', DimSetEntry."Dimension Code")
                then
                    InsertDim(DATABASE::"Item Ledger Entry", DimSetID, DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code");
            until DimSetEntry.Next() = 0;
        end;
    end;

    local procedure CalcWhseQty(AdjmtBin: Code[20]; var PosQuantity: Decimal; var NegQuantity: Decimal)
    var
        WhseEntry: Record "Warehouse Entry";
        WhseEntry2: Record "Warehouse Entry";
        WhseItemTrackingSetup: Record "Item Tracking Setup";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WhseQuantity: Decimal;
        NoWhseEntry: Boolean;
        NoWhseEntry2: Boolean;
    begin
        AdjustPosQty := false;
        with QuantityOnHandBuffer do begin
            ItemTrackingMgt.GetWhseItemTrkgSetup("Item No.", WhseItemTrackingSetup);
            ItemTrackingSplit := WhseItemTrackingSetup.TrackingRequired();
            WhseEntry.SetCurrentKey(
              "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code",
              "Lot No.", "Serial No.", "Entry Type");

            WhseEntry.SetRange("Item No.", "Item No.");
            WhseEntry.SetRange("Location Code", "Location Code");
            WhseEntry.SetRange("Variant Code", "Variant Code");
            OnCalcWhseQtyOnAfterWhseEntrySetFilters(WhseEntry);
            WhseEntry.CalcSums("Qty. (Base)");
            WhseQuantity := WhseEntry."Qty. (Base)";
            WhseEntry.SetRange("Bin Code", AdjmtBin);

            if WhseItemTrackingSetup."Serial No. Required" then begin
                WhseEntry.SetRange("Entry Type", WhseEntry."Entry Type"::"Positive Adjmt.");
                WhseEntry.CalcSums("Qty. (Base)");
                PosQuantity := WhseQuantity - WhseEntry."Qty. (Base)";
                WhseEntry.SetRange("Entry Type", WhseEntry."Entry Type"::"Negative Adjmt.");
                WhseEntry.CalcSums("Qty. (Base)");
                NegQuantity := WhseQuantity - WhseEntry."Qty. (Base)";
                WhseEntry.SetRange("Entry Type", WhseEntry."Entry Type"::Movement);
                WhseEntry.CalcSums("Qty. (Base)");
                if WhseEntry."Qty. (Base)" <> 0 then begin
                    if WhseEntry."Qty. (Base)" > 0 then
                        PosQuantity := PosQuantity + WhseQuantity - WhseEntry."Qty. (Base)"
                    else
                        NegQuantity := NegQuantity - WhseQuantity - WhseEntry."Qty. (Base)";
                end;

                WhseEntry.SetRange("Entry Type", WhseEntry."Entry Type"::"Positive Adjmt.");
                if WhseEntry.Find('-') then begin
                    repeat
                        WhseEntry.SetRange("Serial No.", WhseEntry."Serial No.");

                        WhseEntry2.Reset();
                        WhseEntry2.SetCurrentKey(
                          "Item No.", "Bin Code", "Location Code", "Variant Code",
                          "Unit of Measure Code", "Lot No.", "Serial No.", "Entry Type");

                        WhseEntry2.CopyFilters(WhseEntry);
                        WhseEntry2.SetRange("Entry Type", WhseEntry2."Entry Type"::"Negative Adjmt.");
                        WhseEntry2.SetRange("Serial No.", WhseEntry."Serial No.");
                        if WhseEntry2.Find('-') then
                            repeat
                                PosQuantity := PosQuantity + 1;
                                NegQuantity := NegQuantity - 1;
                                NoWhseEntry := WhseEntry.Next() = 0;
                                NoWhseEntry2 := WhseEntry2.Next() = 0;
                            until NoWhseEntry2 or NoWhseEntry
                        else
                            AdjustPosQty := true;

                        if not NoWhseEntry and NoWhseEntry2 then
                            AdjustPosQty := true;

                        WhseEntry.Find('+');
                        WhseEntry.SetRange("Serial No.");
                    until WhseEntry.Next() = 0;
                end;
            end else begin
                if WhseEntry.Find('-') then
                    repeat
                        WhseEntry.SetRange("Lot No.", WhseEntry."Lot No.");
                        OnCalcWhseQtyOnAfterLotRequiredWhseEntrySetFilters(WhseEntry);
                        WhseEntry.CalcSums("Qty. (Base)");
                        if WhseEntry."Qty. (Base)" <> 0 then begin
                            if WhseEntry."Qty. (Base)" > 0 then
                                NegQuantity := NegQuantity - WhseEntry."Qty. (Base)"
                            else
                                PosQuantity := PosQuantity + WhseEntry."Qty. (Base)";
                        end;
                        WhseEntry.Find('+');
                        WhseEntry.SetRange("Lot No.");
                        OnCalcWhseQtyOnAfterLotRequiredWhseEntryClearFilters(WhseEntry);
                    until WhseEntry.Next() = 0;
                if PosQuantity <> WhseQuantity then
                    PosQuantity := WhseQuantity - PosQuantity;
                if NegQuantity <> -WhseQuantity then
                    NegQuantity := WhseQuantity + NegQuantity;
            end;
        end;
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    procedure InitializePhysInvtCount(PhysInvtCountCode2: Code[10]; CountSourceType2: Option " ",Item,SKU)
    begin
        PhysInvtCountCode := PhysInvtCountCode2;
        CycleSourceType := CountSourceType2;
    end;

    local procedure SkipCycleSKU(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]): Boolean
    var
        SKU: Record "Stockkeeping Unit";
    begin
        if CycleSourceType = CycleSourceType::Item then
            if SKU.ReadPermission then
                if SKU.Get(LocationCode, ItemNo, VariantCode) then
                    exit(true);
        exit(false);
    end;

    procedure GetLocation(LocationCode: Code[10]): Boolean
    begin
        if LocationCode = '' then begin
            Clear(Location);
            exit(true);
        end;

        if Location.Code <> LocationCode then
            if not Location.Get(LocationCode) then
                exit(false);

        exit(true);
    end;

    local procedure UpdateBuffer(BinCode: Code[20]; NewQuantity: Decimal; NewQuantityAlt: Decimal; CalledFromItemLedgerEntry: Boolean)
    var
        DimEntryNo: Integer;
    begin
        // PR3.61.01 - added parameter for alternate quantity
        with QuantityOnHandBuffer do begin
            if not HasNewQuantity(NewQuantity, NewQuantityAlt) then // P8000267B
                exit;
            if BinCode = '' then begin
                if ColumnDim <> '' then
                    TempDimBufIn.SetRange("Entry No.", "Item Ledger Entry"."Dimension Set ID");
                DimEntryNo := DimBufMgt.FindDimensions(TempDimBufIn);
                if DimEntryNo = 0 then
                    DimEntryNo := DimBufMgt.InsertDimensions(TempDimBufIn);
            end;
            if RetrieveBuffer(BinCode, DimEntryNo) then begin
                Quantity := Quantity + NewQuantity;
                "Quantity (Alt.)" := "Quantity (Alt.)" + NewQuantityAlt; // PR3.61.01
                OnUpdateBufferOnBeforeModify(QuantityOnHandBuffer, CalledFromItemLedgerEntry);
                Modify;
            end else begin
                Quantity := NewQuantity;
                "Quantity (Alt.)" := NewQuantityAlt; // PR3.61.01
                OnUpdateBufferOnBeforeInsert(QuantityOnHandBuffer, CalledFromItemLedgerEntry);
                Insert;
            end;
        end;

        // PR3.61.01 Begin
        if ProcessFns.TrackingInstalled and
          (ItemTracking."Lot Specific Tracking" or ItemTracking."SN Specific Tracking")
        then begin
            ItemTrackingBuffer.Reset;
            ItemTrackingBuffer.SetRange("Item No.", "Item Ledger Entry"."Item No.");
            ItemTrackingBuffer.SetRange("Variant Code", "Item Ledger Entry"."Variant Code");
            ItemTrackingBuffer.SetRange("Location Code", "Item Ledger Entry"."Location Code");
            ItemTrackingBuffer.SetRange("Dimension Entry No.", QuantityOnHandBuffer."Dimension Entry No.");
            ItemTrackingBuffer.SetRange("Bin Code", BinCode); // P8000631A
            if BinCode = '' then begin // P8000631A
                if ItemTracking."Lot Specific Tracking" then
                    ItemTrackingBuffer.SetRange("Lot No.", "Item Ledger Entry"."Lot No.");
                if ItemTracking."SN Specific Tracking" then
                    ItemTrackingBuffer.SetRange("Serial No.", "Item Ledger Entry"."Serial No.");
                // P8000631A
            end else begin
                if ItemTracking."Lot Specific Tracking" then
                    ItemTrackingBuffer.SetRange("Lot No.", WhseEntry."Lot No.");       // P8000728
                if ItemTracking."SN Specific Tracking" then
                    ItemTrackingBuffer.SetRange("Serial No.", WhseEntry."Serial No."); // P8000728
            end;
            // P8000631A
            if not ItemTrackingBuffer.Find('-') then begin
                ItemTrackingBuffer."Item No." := "Item Ledger Entry"."Item No.";
                ItemTrackingBuffer."Variant Code" := "Item Ledger Entry"."Variant Code";
                ItemTrackingBuffer."Dimension Entry No." := QuantityOnHandBuffer."Dimension Entry No.";
                ItemTrackingBuffer."Location Code" := "Item Ledger Entry"."Location Code";
                ItemTrackingBuffer."Bin Code" := BinCode; // P8000631A
                if BinCode = '' then begin // P8000631A
                    ItemTrackingBuffer."Lot No." := "Item Ledger Entry"."Lot No.";
                    ItemTrackingBuffer."Serial No." := "Item Ledger Entry"."Serial No.";
                    // P8000631A
                end else begin
                    ItemTrackingBuffer."Lot No." := WhseEntry."Lot No.";
                    ItemTrackingBuffer."Serial No." := WhseEntry."Serial No.";
                end;
                // P8000631A
                ItemTrackingBuffer.Quantity := 0;
                ItemTrackingBuffer."Quantity (Alt.)" := 0;
                ItemTrackingBuffer.Insert;
            end;
            ItemTrackingBuffer.Quantity += NewQuantity;
            ItemTrackingBuffer."Quantity (Alt.)" += NewQuantityAlt;
            ItemTrackingBuffer.Modify;
        end;
        // PR3.61.01 End
    end;

    local procedure RetrieveBuffer(BinCode: Code[20]; DimEntryNo: Integer): Boolean
    begin
        with QuantityOnHandBuffer do begin
            Reset;
            "Item No." := "Item Ledger Entry"."Item No.";
            "Variant Code" := "Item Ledger Entry"."Variant Code";
            "Location Code" := "Item Ledger Entry"."Location Code";
            "Dimension Entry No." := DimEntryNo;
            "Bin Code" := BinCode;
            OnRetrieveBufferOnBeforeFind(QuantityOnHandBuffer, "Item Ledger Entry");
            exit(Find);
        end;
    end;

    local procedure HasNewQuantity(NewQuantity: Decimal; NewQuantityAlt: Decimal): Boolean
    begin
        // P8000267B - add parameter for NewQuantityAlt
        exit((NewQuantity <> 0) or (NewQuantityAlt <> 0) or ZeroQty); // P8000267B
    end;

    local procedure ItemBinLocationIsCalculated(BinCode: Code[20]): Boolean
    begin
        with QuantityOnHandBuffer do begin
            Reset;
            SetRange("Item No.", "Item Ledger Entry"."Item No.");
            SetRange("Variant Code", "Item Ledger Entry"."Variant Code");
            SetRange("Location Code", "Item Ledger Entry"."Location Code");
            SetRange("Bin Code", BinCode);
            exit(Find('-'));
        end;
    end;

    procedure SetSkipDim(NewSkipDim: Boolean)
    begin
        SkipDim := NewSkipDim;
    end;

    local procedure UpdateQuantityOnHandBuffer(ItemNo: Code[20])
    var
        Location: Record Location;
        ItemVariant: Record "Item Variant";
    begin
        ItemVariant.SetRange("Item No.", Item."No.");
        Item.CopyFilter("Variant Filter", ItemVariant.Code);
        Item.CopyFilter("Location Filter", Location.Code);
        Location.SetRange("Use As In-Transit", false);
        if (Item.GetFilter("Location Filter") <> '') and Location.FindSet() then
            repeat
                if (Item.GetFilter("Variant Filter") <> '') and ItemVariant.FindSet() then
                    repeat
                        InsertQuantityOnHandBuffer(ItemNo, Location.Code, ItemVariant.Code);
                    until ItemVariant.Next() = 0
                else
                    InsertQuantityOnHandBuffer(ItemNo, Location.Code, '');
            until Location.Next() = 0
        else
            if (Item.GetFilter("Variant Filter") <> '') and ItemVariant.FindSet() then
                repeat
                    InsertQuantityOnHandBuffer(ItemNo, '', ItemVariant.Code);
                until ItemVariant.Next() = 0
            else
                InsertQuantityOnHandBuffer(ItemNo, '', '');
    end;

    local procedure CalcPhysInvQtyAndInsertItemJnlLine()
    begin
        with QuantityOnHandBuffer do begin
            Reset;
            OnCalcPhysInvQtyAndInsertItemJnlLineOnBeforeFindset(QuantityOnHandBuffer);
            if FindSet() then begin
                repeat
                    // P800213, P8001256
                    if Item."No." <> "Item No." then begin
                        Item.Get("Item No.");
                        if Item."Item Tracking Code" <> '' then
                            ItemTracking.Get(Item."Item Tracking Code")
                        else
                            Clear(ItemTracking);
                    end;
                    // P8001213, P8001256
                    PosQty := 0;
                    NegQty := 0;

                    GetLocation("Location Code");
                    if Location."Directed Put-away and Pick" then
                        CalcWhseQty(Location."Adjustment Bin Code", PosQty, NegQty);

                    if (NegQty - Quantity <> Quantity - PosQty) or ItemTrackingSplit then begin
                        if PosQty = Quantity then
                            PosQty := 0;
                        if (PosQty <> 0) or AdjustPosQty then
                            InsertItemJnlLine(
                              "Item No.", "Variant Code", "Dimension Entry No.",
                              "Bin Code", Quantity, PosQty, 0, 0, // PR3.61.01
                              '', '', '', '');                   // PR3.61.01

                        if NegQty = Quantity then
                            NegQty := 0;
                        if NegQty <> 0 then begin
                            if ((PosQty <> 0) or AdjustPosQty) and not ItemTrackingSplit then begin
                                NegQty := NegQty - Quantity;
                                Quantity := 0;
                                ZeroQty := true;
                            end;
                            if NegQty = -Quantity then begin
                                NegQty := 0;
                                AdjustPosQty := true;
                            end;
                            InsertItemJnlLine(
                              "Item No.", "Variant Code", "Dimension Entry No.",
                              "Bin Code", Quantity, NegQty, 0, 0, // PR3.61.01
                              '', '', '', '');                   // PR3.61.01

                            ZeroQty := ZeroQtySave;
                        end;
                    end else begin
                        PosQty := 0;
                        NegQty := 0;
                    end;

                    OnCalcPhysInvQtyAndInsertItemJnlLineOnBeforeCheckIfInsertNeeded(QuantityOnHandBuffer);
                    if (PosQty = 0) and (NegQty = 0) and not AdjustPosQty then
                        //InsertItemJnlLine(                                 // PR3.70
                        //  "Item No.","Variant Code","Dimension Entry No.", // PR3.70
                        //  "Bin Code",Quantity,Quantity);                   // PR3.70
                        if ProcessFns.TrackingInstalled and
                  (ItemTracking."Lot Specific Tracking" or ItemTracking."SN Specific Tracking")
                then begin
                            ItemTrackingBuffer.Reset;
                            ItemTrackingBuffer.SetRange("Item No.", "Item No.");
                            ItemTrackingBuffer.SetRange("Variant Code", "Variant Code");
                            ItemTrackingBuffer.SetRange("Dimension Entry No.", "Dimension Entry No.");
                            ItemTrackingBuffer.SetRange("Location Code", "Location Code");
                            ItemTrackingBuffer.SetRange("Bin Code", "Bin Code");
                            if ItemTrackingBuffer.Find('-') then
                                repeat
                                    if (ItemTrackingBuffer.Quantity <> 0) or (ItemTrackingBuffer."Quantity (Alt.)" <> 0) or ZeroQty then
                                        InsertItemJnlWithContainer(
                                          "Item No.", "Variant Code", "Dimension Entry No.",
                                          "Bin Code", ItemTrackingBuffer.Quantity, ItemTrackingBuffer."Quantity (Alt.)",
                                          ItemTrackingBuffer."Lot No.", ItemTrackingBuffer."Serial No.");
                                until ItemTrackingBuffer.Next = 0;
                        end else
                            InsertItemJnlWithContainer(
                              "Item No.", "Variant Code", "Dimension Entry No.",
                              "Bin Code", Quantity, "Quantity (Alt.)",
                              '', '');
                // PR3.61 End
                until Next() = 0;
                DeleteAll();
            end;
        end;
    end;

    local procedure CreateDimFromItemDefault() DimEntryNo: Integer
    var
        DefaultDimension: Record "Default Dimension";
    begin
        with DefaultDimension do begin
            SetRange("No.", QuantityOnHandBuffer."Item No.");
            SetRange("Table ID", DATABASE::Item);
            SetFilter("Dimension Value Code", '<>%1', '');
            if FindSet() then
                repeat
                    InsertDim(DATABASE::Item, 0, "Dimension Code", "Dimension Value Code");
                until Next() = 0;
        end;

        DimEntryNo := DimBufMgt.InsertDimensions(TempDimBufIn);
        TempDimBufIn.SetRange("Table ID", DATABASE::Item);
        TempDimBufIn.DeleteAll();
    end;

    local procedure InsertDim(TableID: Integer; EntryNo: Integer; DimCode: Code[20]; DimValueCode: Code[20])
    begin
        with TempDimBufIn do begin
            Init;
            "Table ID" := TableID;
            "Entry No." := EntryNo;
            "Dimension Code" := DimCode;
            "Dimension Value Code" := DimValueCode;
            if Insert() then;
        end;
    end;

    procedure InsertItemJnlWithContainer(ItemNo: Code[20]; VariantCode: Code[10]; DimEntryNo: Integer; BinCode: Code[20]; Quantity: Decimal; AltQuantity: Decimal; LotNo: Code[50]; SerialNo: Code[50])
    begin
        // P8001323
        ContainerDetailBuffer.SetRange("Item No.", ItemNo);
        ContainerDetailBuffer.SetRange("Variant Code", VariantCode);
        ContainerDetailBuffer.SetRange("Location Code", Location.Code);
        ContainerDetailBuffer.SetRange("Bin Code", BinCode);
        ContainerDetailBuffer.SetRange("Lot No.", LotNo);
        ContainerDetailBuffer.SetRange("Serial No.", SerialNo);
        if ContainerDetailBuffer.FindSet then
            repeat
                InsertItemJnlLine(ItemNo, VariantCode, DimEntryNo, BinCode,
                  ContainerDetailBuffer.Quantity, ContainerDetailBuffer."Quantity (Alt.)", ContainerDetailBuffer.Quantity, ContainerDetailBuffer."Quantity (Alt.)",
                  ContainerDetailBuffer."Unit of Measure Code", LotNo, SerialNo, ContainerDetailBuffer."Container ID");
                Quantity -= ContainerDetailBuffer."Quantity (Base)";
                AltQuantity -= ContainerDetailBuffer."Quantity (Alt.)";
            until ContainerDetailBuffer.Next = 0;

        InsertItemJnlLine(ItemNo, VariantCode, DimEntryNo, BinCode, Quantity, AltQuantity, Quantity, AltQuantity, '', LotNo, SerialNo, '');
    end;

    local procedure DistributeAltQty()
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ContainerLine: Record "Container Line";
        FirstBufferEntry: Record "Item Tracking Buffer";
        LooseAltQtyPerBase: Decimal;
    begin
        // P8000631A
        if not Item.TrackAlternateUnits() then
            exit;
        if ProcessFns.TrackingInstalled and
          (ItemTracking."Lot Specific Tracking" or ItemTracking."SN Specific Tracking")
        then
            with ItemTrackingBuffer do begin
                Reset;
                SetRange("Item No.", "Item Ledger Entry"."Item No.");
                SetRange("Variant Code", "Item Ledger Entry"."Variant Code");
                SetRange("Location Code", "Item Ledger Entry"."Location Code");
                if FindSet then
                    repeat
                        if not Mark then
                            if CalcDistributionQtys(
                                 "Lot No.", "Serial No.", ItemLedgEntry, ContainerLine, LooseAltQtyPerBase)
                            then begin
                                FirstBufferEntry := ItemTrackingBuffer;
                                SetRange("Lot No.", "Lot No.");
                                SetRange("Serial No.", "Serial No.");
                                repeat
                                    SetBinAltQty(
                                      "Bin Code", Quantity, "Quantity (Alt.)", ItemLedgEntry, ContainerLine, LooseAltQtyPerBase);
                                    Modify;
                                    Mark(true);
                                until (ItemLedgEntry.Quantity = 0) or (Next = 0);
                                SetRange("Lot No.");
                                SetRange("Serial No.");
                                ItemTrackingBuffer := FirstBufferEntry;
                            end;
                    until (Next = 0);
                Reset;
            end
        else
            with QuantityOnHandBuffer do begin
                Reset;
                SetRange("Item No.", "Item Ledger Entry"."Item No.");
                SetRange("Variant Code", "Item Ledger Entry"."Variant Code");
                SetRange("Location Code", "Item Ledger Entry"."Location Code");
                if FindSet then begin
                    if CalcDistributionQtys('', '', ItemLedgEntry, ContainerLine, LooseAltQtyPerBase) then
                        repeat
                            SetBinAltQty(
                              "Bin Code", Quantity, "Quantity (Alt.)", ItemLedgEntry, ContainerLine, LooseAltQtyPerBase);
                            Modify;
                        until (ItemLedgEntry.Quantity = 0) or (Next = 0);
                end;
                Reset;
            end;
    end;

    local procedure CalcDistributionQtys(LotNo: Code[50]; SerialNo: Code[50]; var ItemLedgEntry: Record "Item Ledger Entry"; var ContainerLine: Record "Container Line"; var LooseAltQtyPerBase: Decimal): Boolean
    var
        LooseQty: Decimal;
    begin
        // P8000631A
        with ItemLedgEntry do begin
            Reset;
            SetCurrentKey("Item No.", "Variant Code", "Drop Shipment", "Location Code", "Lot No.", "Serial No.");
            SetRange("Item No.", "Item Ledger Entry"."Item No.");
            SetRange("Variant Code", "Item Ledger Entry"."Variant Code");
            SetRange("Drop Shipment", false);
            SetRange("Location Code", "Item Ledger Entry"."Location Code");
            if (LotNo <> '') or (SerialNo <> '') then begin
                SetRange("Lot No.", LotNo);
                SetRange("Serial No.", SerialNo);
            end;
            CalcSums(Quantity, "Quantity (Alt.)");
            if (Quantity = 0) then
                exit(false);
        end;
        with ContainerLine do begin
            Reset;
            SetCurrentKey("Item No.", "Variant Code", "Location Code", "Bin Code", "Lot No.", "Serial No.");
            SetRange("Item No.", "Item Ledger Entry"."Item No.");
            SetRange("Variant Code", "Item Ledger Entry"."Variant Code");
            SetRange("Location Code", "Item Ledger Entry"."Location Code");
            if (LotNo <> '') or (SerialNo <> '') then begin
                SetRange("Lot No.", LotNo);
                SetRange("Serial No.", SerialNo);
            end;
            CalcSums("Quantity (Base)", "Quantity (Alt.)");
        end;
        LooseQty := ItemLedgEntry.Quantity - ContainerLine."Quantity (Base)";
        if (LooseQty = 0) then
            LooseAltQtyPerBase := 0
        else
            LooseAltQtyPerBase := (ItemLedgEntry."Quantity (Alt.)" - ContainerLine."Quantity (Alt.)") / LooseQty;
        exit(true);
    end;

    local procedure SetBinAltQty(BinCode: Code[20]; BinQty: Decimal; var BinQtyAlt: Decimal; var ItemLedgEntry: Record "Item Ledger Entry"; var ContainerLine: Record "Container Line"; LooseAltQtyPerBase: Decimal)
    var
        LooseBinQty: Decimal;
    begin
        // P8000631A
        ContainerLine.SetRange("Bin Code", BinCode);
        ContainerLine.CalcSums("Quantity (Base)", "Quantity (Alt.)");
        LooseBinQty := BinQty - ContainerLine."Quantity (Base)";
        ItemLedgEntry.Quantity := ItemLedgEntry.Quantity - ContainerLine."Quantity (Base)";
        ItemLedgEntry."Quantity (Alt.)" := ItemLedgEntry."Quantity (Alt.)" - ContainerLine."Quantity (Alt.)";
        if (LooseBinQty <> 0) then
            if (LooseBinQty >= ItemLedgEntry.Quantity) then begin
                BinQtyAlt := ItemLedgEntry."Quantity (Alt.)";
                ItemLedgEntry.Quantity := 0;
            end else begin
                BinQtyAlt := Round(LooseBinQty * LooseAltQtyPerBase, 0.00001);
                if (BinQtyAlt > ItemLedgEntry."Quantity (Alt.)") then
                    BinQtyAlt := ItemLedgEntry."Quantity (Alt.)";
                ItemLedgEntry.Quantity := ItemLedgEntry.Quantity - LooseBinQty;
            end;
        ItemLedgEntry."Quantity (Alt.)" := ItemLedgEntry."Quantity (Alt.)" - BinQtyAlt;
        BinQtyAlt := BinQtyAlt + ContainerLine."Quantity (Alt.)";
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetRecordItemLedgEntryOnBeforeUpdateBuffer(var Item: Record Item; ItemLedgEntry: Record "Item Ledger Entry"; var ByBin: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertItemJnlLine(var ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterItemOnPreDataItem(var Item: Record Item; ZeroQty: Boolean; IncludeItemWithNoTransaction: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterWhseEntrySetFilters(var WarehouseEntry: Record "Warehouse Entry"; var ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnItemLedgerEntryOnAfterPreDataItem(var ItemLedgerEntry: Record "Item Ledger Entry"; var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertItemJnlLineOnBeforeInit(var ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertItemJnlLineOnAfterCalcShouldInsertItemJnlLine(ItemNo: Code[20]; VariantCode2: Code[10]; DimEntryNo2: Integer; BinCode2: Code[20]; Quantity2: Decimal; PhysInvQuantity: Decimal; ZeroQty: Boolean; var ShouldInsertItemJnlLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertItemJnlLineOnAfterValidateLocationCode(ItemNo: Code[20]; VariantCode2: Code[10]; DimEntryNo2: Integer; BinCode2: Code[20]; Quantity2: Decimal; PhysInvQuantity: Decimal; var ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeItemOnAfterGetRecord(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFunctionInsertItemJnlLine(ItemNo: Code[20]; VariantCode2: Code[10]; DimEntryNo2: Integer; BinCode2: Code[20]; Quantity2: Decimal; PhysInvQuantity: Decimal; var ItemJournalLine: Record "Item Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; var InventoryBuffer: Record "Inventory Buffer");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeQuantityOnHandBufferFindAndInsert(var InventoryBuffer: Record "Inventory Buffer"; WarehouseEntry: Record "Warehouse Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFunctionInsertItemJnlLine(ItemNo: Code[20]; VariantCode2: Code[10]; DimEntryNo2: Integer; BinCode2: Code[20]; Quantity2: Decimal; PhysInvQuantity: Decimal; var ItemJournalLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcPhysInvQtyAndInsertItemJnlLineOnBeforeCheckIfInsertNeeded(InventoryBuffer: Record "Inventory Buffer")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcPhysInvQtyAndInsertItemJnlLineOnBeforeFindset(var InventoryBuffer: Record "Inventory Buffer")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcWhseQtyOnAfterLotRequiredWhseEntryClearFilters(var WarehouseEntry: Record "Warehouse Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcWhseQtyOnAfterLotRequiredWhseEntrySetFilters(var WarehouseEntry: Record "Warehouse Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcWhseQtyOnAfterWhseEntrySetFilters(var WarehouseEntry: Record "Warehouse Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertItemJnlLineOnAfterUpdateDimensionSetID(var ItemJnlLine: Record "Item Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPreDataItemOnAfterGetItemJnlTemplateAndBatch(var ItemJnlTemplate: Record "Item Journal Template"; var ItemJnlBatch: Record "Item Journal Batch")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRetrieveBufferOnBeforeFind(var InventoryBuffer: Record "Inventory Buffer"; ItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnReserveWarehouseOnAfterWhseEntry2SetFilters(var ItemJnlLine: Record "Item Journal Line"; var WhseEntry: Record "Warehouse Entry"; var WhseEntry2: Record "Warehouse Entry"; EntryType: Option)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateBufferOnBeforeInsert(var InventoryBuffer: Record "Inventory Buffer"; CalledFromItemLedgerEntry: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateBufferOnBeforeModify(var InventoryBuffer: Record "Inventory Buffer"; CalledFromItemLedgerEntry: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnPreReport(var ItemJournalLine: Record "Item Journal Line"; var PostingDate: Date)
    begin
    end;
}

