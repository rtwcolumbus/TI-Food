report 7390 "Whse. Calculate Inventory"
{
    // PRW18.00.01
    // P8001372, Columbus IT, Don Bresee, 03 FEB 15
    //   Use Open field on Warehouse Entries when no date filter is used
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 17 MAR 16
    //   Incorporate modifications for NAV Anywhere processes
    // 
    // PRW110.0.01
    // P8008649, To-Increase, Jack Reynolds, 19 APR 17
    //   Containers and "Set Count to Zero"
    // 
    // PRW110.0.02
    // P80049717, To-Increase, Dayakar Battini, 04 DEC 17
    //   Fix for error when Calculate Inventory for Fixed weight items.
    // 
    // PRW111.00.01
    // P80058977, To-Increase, Dayakar Battini, 15 MAY 18
    //   Fix issue for calculate inventory for fixed weight containerized items
    // 
    // P80060078, To-Increase, Dayakar Battini, 13 JUN 18
    //   Fix issue for calculate inventory for container quantity
    //
    // PRW!18.00.01
    // P800132967, To-Increase, Gangabhushan, 25 OCT 21
    //   CS00189654 | Warehouse Physical Inventory Journal missing Containers

    Caption = 'Whse. Calculate Inventory';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Bin Content"; "Bin Content")
        {
            DataItemTableView = SORTING("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
            RequestFilterFields = "Zone Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code", "Bin Type Code", "Warehouse Class Code";

            trigger OnAfterGetRecord()
            begin
                if SkipCycleSKU("Location Code", "Item No.", "Variant Code") then
                    CurrReport.Skip();

                if not HideValidationDialog then
                    Window.Update;
                CalcFields("Quantity (Base)");
                if ("Quantity (Base)" <> 0) or ZeroQty then
                    InsertWhseJnlLine("Bin Content");
            end;

            trigger OnPostDataItem()
            begin
                if not HideValidationDialog then
                    Window.Close;
            end;

            trigger OnPreDataItem()
            var
                WhseJnlTemplate: Record "Warehouse Journal Template";
                WhseJnlBatch: Record "Warehouse Journal Batch";
            begin
                if RegisteringDate = 0D then
                    Error(Text001, WhseJnlLine.FieldCaption("Registering Date"));

                SetRange("Location Code", WhseJnlLine."Location Code");

                OnBinContentOnBeforePreDataItem("Bin Content", WhseJnlLine);

                WhseJnlTemplate.Get(WhseJnlLine."Journal Template Name");
                WhseJnlBatch.Get(
                  WhseJnlLine."Journal Template Name",
                  WhseJnlLine."Journal Batch Name", WhseJnlLine."Location Code");
                if NextDocNo = '' then begin
                    if WhseJnlBatch."No. Series" <> '' then begin
                        WhseJnlLine.SetRange("Journal Template Name", WhseJnlLine."Journal Template Name");
                        WhseJnlLine.SetRange("Journal Batch Name", WhseJnlLine."Journal Batch Name");
                        WhseJnlLine.SetRange("Location Code", WhseJnlLine."Location Code");
                        if not WhseJnlLine.FindFirst() then
                            NextDocNo :=
                              NoSeriesMgt.GetNextNo(WhseJnlBatch."No. Series", RegisteringDate, false);
                        WhseJnlLine.Init();
                    end;
                    if NextDocNo = '' then
                        Error(Text001, WhseJnlLine.FieldCaption("Whse. Document No."));
                end;

                NextLineNo := 0;

                if not HideValidationDialog then
                    Window.Open(Text002, "Bin Code");
            end;
        }
        dataitem("Warehouse Entry"; "Warehouse Entry")
        {

            trigger OnAfterGetRecord()
            var
                BinContent: Record "Bin Content";
                SkipRecord: Boolean;
            begin
                GetLocation("Location Code");
                SkipRecord := ("Bin Code" = Location."Adjustment Bin Code") or SkipCycleSKU("Location Code", "Item No.", "Variant Code");
                OnWarehouseEntryOnAfterGetRecordOnAfterCalcSkipRecord("Warehouse Entry", SkipRecord);
                if SkipRecord then
                    CurrReport.Skip();

                BinContent.CopyFilters("Bin Content");
                BinContent.SetRange("Location Code", "Location Code");
                BinContent.SetRange("Item No.", "Item No.");
                BinContent.SetRange("Variant Code", "Variant Code");
                BinContent.SetRange("Unit of Measure Code", "Unit of Measure Code");
                if not BinContent.IsEmpty() then
                    CurrReport.Skip();

                InitBinContent(TempBinContent, "Warehouse Entry");

                if not TempBinContent.Find() then
                    TempBinContent.Insert();
            end;

            trigger OnPostDataItem()
            begin
                TempBinContent.Reset();
                if TempBinContent.FindSet() then
                    repeat
                        InsertWhseJnlLine(TempBinContent);
                    until TempBinContent.Next() = 0;
            end;

            trigger OnPreDataItem()
            begin
                if ("Bin Content".GetFilter("Zone Code") = '') and
                   ("Bin Content".GetFilter("Bin Code") = '')
                then
                    CurrReport.Break();

                "Bin Content".CopyFilter("Location Code", "Location Code");
                "Bin Content".CopyFilter("Zone Code", "Zone Code");
                "Bin Content".CopyFilter("Bin Code", "Bin Code");
                "Bin Content".CopyFilter("Item No.", "Item No.");
                "Bin Content".CopyFilter("Variant Code", "Variant Code");
                "Bin Content".CopyFilter("Unit of Measure Code", "Unit of Measure Code");
                "Bin Content".CopyFilter("Bin Type Code", "Bin Type Code");
                "Bin Content".CopyFilter("Lot No. Filter", "Lot No.");
                "Bin Content".CopyFilter("Serial No. Filter", "Serial No.");
                TempBinContent.Reset();
                TempBinContent.DeleteAll();
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(RegisteringDate; RegisteringDate)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Registering Date';
                        ToolTip = 'Specifies the date for registering this batch job. The program automatically enters the work date in this field, but you can change it.';

                        trigger OnValidate()
                        begin
                            ValidateRegisteringDate;
                        end;
                    }
                    field(WhseDocumentNo; NextDocNo)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Whse. Document No.';
                        ToolTip = 'Specifies which document number will be entered in the Document No. field on the journal lines created by the batch job.';
                    }
                    field(ZeroQty; ZeroQty)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Items Not on Inventory';
                        ToolTip = 'Specifies if journal lines should be created for items that are not on inventory, that is, items where the value in the Qty. (Calculated) field is 0.';
                    }
                    field(SetCountToZero; SetCountToZero)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Set Count to Zero';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if RegisteringDate = 0D then
                RegisteringDate := WorkDate;
            ValidateRegisteringDate;
        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        OnAfterOnPostReport(WhseJnlLine);
    end;

    var
        Text001: Label 'Enter the %1.';
        Text002: Label 'Processing bins    #1##########';
        SourceCodeSetup: Record "Source Code Setup";
        TempBinContent: Record "Bin Content" temporary;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        UOMMgt: Codeunit "Unit of Measure Management";
        Window: Dialog;
        StockProposal: Boolean;

    protected var
        Bin: Record Bin;
        Location: Record Location;
        WhseJnlBatch: Record "Warehouse Journal Batch";
        WhseJnlLine: Record "Warehouse Journal Line";
        HideValidationDialog: Boolean;
        NextDocNo: Code[20];
        NextLineNo: Integer;
        RegisteringDate: Date;
        CycleSourceType: Option " ",Item,SKU;
        PhysInvtCountCode: Code[10];
        ZeroQty: Boolean;
        Item: Record Item;
        P800Functions: Codeunit "Process 800 Functions";
        ContainerFunctions: Codeunit "Container Functions";
        SetCountToZero: Boolean;

    procedure SetWhseJnlLine(var NewWhseJnlLine: Record "Warehouse Journal Line")
    begin
        WhseJnlLine := NewWhseJnlLine;
    end;

    local procedure ValidateRegisteringDate()
    begin
        WhseJnlBatch.Get(
          WhseJnlLine."Journal Template Name",
          WhseJnlLine."Journal Batch Name", WhseJnlLine."Location Code");
        if WhseJnlBatch."No. Series" = '' then
            NextDocNo := ''
        else begin
            NextDocNo :=
              NoSeriesMgt.GetNextNo(WhseJnlBatch."No. Series", RegisteringDate, false);
            Clear(NoSeriesMgt);
        end;
    end;

    local procedure InitBinContent(var BinContent: Record "Bin Content"; WarehouseEntry: Record "Warehouse Entry")
    begin
        BinContent.Init();
        BinContent."Location Code" := WarehouseEntry."Location Code";
        BinContent."Item No." := WarehouseEntry."Item No.";
        BinContent."Zone Code" := WarehouseEntry."Zone Code";
        BinContent."Bin Code" := WarehouseEntry."Bin Code";
        BinContent."Variant Code" := WarehouseEntry."Variant Code";
        BinContent."Unit of Measure Code" := WarehouseEntry."Unit of Measure Code";
        BinContent."Quantity (Base)" := 0;

        OnAfterInitBinContent(BinContent, WarehouseEntry);
    end;

    procedure InsertWhseJnlLine(BinContent: Record "Bin Content")
    var
        WhseEntry: Record "Warehouse Entry";
        ItemUOM: Record "Item Unit of Measure";
        ItemTrackingSetup: Record "Item Tracking Setup";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ExpDate: Date;
        EntriesExist: Boolean;
        ContainerDetailBuffer: Record "Container Line" temporary;
    begin
        with WhseJnlLine do begin
            if NextLineNo = 0 then begin
                LockTable();
                SetRange("Journal Template Name", "Journal Template Name");
                SetRange("Journal Batch Name", "Journal Batch Name");
                SetRange("Location Code", "Location Code");
                if FindLast() then
                    NextLineNo := "Line No.";

                SourceCodeSetup.Get();
            end;

            GetLocation(BinContent."Location Code");
            Item.Get(BinContent."Item No."); // P8001323

            if P800Functions.ContainerTrackingInstalled then                                       // P8001323
                ContainerFunctions.ContainerDetailForWhsePhysical(BinContent, ContainerDetailBuffer); // P8001323

            // P8001372
            // WhseEntry.SETCURRENTKEY(
            //   "Item No.","Bin Code","Location Code","Variant Code",
            //   "Unit of Measure Code","Lot No.","Serial No.","Entry Type");
            WhseEntry.SetCurrentKey(
              "Location Code", "Bin Code", "Item No.", "Variant Code",
              "Unit of Measure Code", Open, "Lot No.", "Serial No.");
            WhseEntry.SetRange(Open, true);
            // P8001372
            WhseEntry.SetRange("Item No.", BinContent."Item No.");
            WhseEntry.SetRange("Bin Code", BinContent."Bin Code");
            WhseEntry.SetRange("Location Code", BinContent."Location Code");
            WhseEntry.SetRange("Variant Code", BinContent."Variant Code");
            WhseEntry.SetRange("Unit of Measure Code", BinContent."Unit of Measure Code");
            OnInsertWhseJnlLineOnAfterWhseEntrySetFilters(WhseEntry, "Bin Content");
            if WhseEntry.Find('-') or ZeroQty then
                repeat
                    WhseEntry.SetTrackingFilterFromWhseEntry(WhseEntry);
                    // P8001372
                    // WhseEntry.CalcSums("Qty. (Base)");
                    WhseEntry.CalcSums("Remaining Quantity"); // P8001323
                    //WhseEntry."Qty. (Base)" := WhseEntry."Remaining Qty. (Base)"; // P8001323
                    // P8001372
                    if (WhseEntry."Remaining Quantity" <> 0) or ZeroQty then begin // P8001323
                        ItemUOM.Get(BinContent."Item No.", BinContent."Unit of Measure Code"); // P8001323
                        NextLineNo := NextLineNo + 10000;
                        Init;
                        "Line No." := NextLineNo;
                        Validate("Registering Date", RegisteringDate);
                        Validate("Entry Type", "Entry Type"::"Positive Adjmt.");
                        Validate("Whse. Document No.", NextDocNo);
                        Validate("Item No.", BinContent."Item No.");
                        Validate("Variant Code", BinContent."Variant Code");
                        Validate("Location Code", BinContent."Location Code");
                        "From Bin Code" := Location."Adjustment Bin Code";
                        "From Zone Code" := Bin."Zone Code";
                        "From Bin Type Code" := Bin."Bin Type Code";
                        Validate("To Zone Code", BinContent."Zone Code");
                        Validate("To Bin Code", BinContent."Bin Code");
                        Validate("Zone Code", BinContent."Zone Code");
                        SetProposal(StockProposal);
                        Validate("Bin Code", BinContent."Bin Code");
                        Validate("Source Code", SourceCodeSetup."Whse. Phys. Invt. Journal");
                        Validate("Unit of Measure Code", BinContent."Unit of Measure Code");
                        CopyTrackingFromWhseEntry(WhseEntry);
                        "Warranty Date" := WhseEntry."Warranty Date";
                        ItemTrackingSetup.CopyTrackingFromWhseEntry(WhseEntry);
                        ExpDate := ItemTrackingMgt.ExistingExpirationDate("Item No.", "Variant Code", ItemTrackingSetup, false, EntriesExist);
                        if EntriesExist then
                            "Expiration Date" := ExpDate
                        else
                            "Expiration Date" := WhseEntry."Expiration Date";
                        "Phys. Inventory" := true;

                        // P8001323
                        //"Qty. (Calculated)" := Round(WhseEntry."Qty. (Base)" / ItemUOM."Qty. per Unit of Measure", UOMMgt.QtyRndPrecision);
                        //"Qty. (Calculated) (Base)" := WhseEntry."Qty. (Base)";
                        "Qty. (Calculated)" := WhseEntry."Remaining Quantity";
                        "Qty. (Calculated) (Base)" := Round(WhseEntry."Remaining Quantity" * ItemUOM."Qty. per Unit of Measure", UOMMgt.QtyRndPrecision); // P800-MegaApp
                        // P8001323

                        Validate("Qty. (Phys. Inventory)", "Qty. (Calculated)");
                        Validate("Qty. (Phys. Inventory) (Base)", "Qty. (Calculated) (Base)"); // P8001323

                        if Location."Use ADCS" or SetCountToZero then // P8004516
                            Validate("Qty. (Phys. Inventory)", 0);
                        "Registering No. Series" := WhseJnlBatch."Registering No. Series";
                        "Whse. Document Type" :=
                          "Whse. Document Type"::"Whse. Phys. Inventory";
                        if WhseJnlBatch."Reason Code" <> '' then
                            "Reason Code" := WhseJnlBatch."Reason Code";
                        "Phys Invt Counting Period Code" := PhysInvtCountCode;
                        "Phys Invt Counting Period Type" := CycleSourceType;

                        OnBeforeWhseJnlLineInsert(WhseJnlLine, WhseEntry, NextLineNo);
                        InsertWhseJnlLineWithContainer(WhseJnlLine, WhseEntry, NextLineNo, ContainerDetailBuffer, Location."Use ADCS" OR SetCountToZero); // P8001323, P8004516, P800132967
                        if "Qty. (Calculated)" > 0 THEN // P8001323, P800132967
                            Insert(true);
                        NextLineNo := "Line No.";       // P8001323, P800132967
                        OnAfterWhseJnlLineInsert(WhseJnlLine, NextLineNo, "Bin Content");
                    end;
                    if WhseEntry.Find('+') then;
                    WhseEntry.ClearTrackingFilter;
                until WhseEntry.Next() = 0;
        end;
    end;

    procedure InitializeRequest(NewRegisteringDate: Date; WhseDocNo: Code[20]; ItemsNotOnInvt: Boolean)
    begin
        RegisteringDate := NewRegisteringDate;
        NextDocNo := WhseDocNo;
        ZeroQty := ItemsNotOnInvt;
    end;

    procedure InitializePhysInvtCount(PhysInvtCountCode2: Code[10]; CycleSourceType2: Option " ",Item,SKU)
    begin
        PhysInvtCountCode := PhysInvtCountCode2;
        CycleSourceType := CycleSourceType2;
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
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

    procedure GetLocation(LocationCode: Code[10])
    begin
        if Location.Code <> LocationCode then begin
            Location.Get(LocationCode);
            Location.TestField("Adjustment Bin Code");
            Bin.Get(Location.Code, Location."Adjustment Bin Code");
            Bin.TestField("Zone Code");
        end;
    end;

    procedure SetProposalMode(NewValue: Boolean)
    begin
        StockProposal := NewValue;
    end;

    local procedure InsertWhseJnlLineWithContainer(var WhseJnlLine: Record "Warehouse Journal Line"; WarehouseEntry: Record "Warehouse Entry"; var NextLineNo: Integer; var ContainerDetailBuffer: Record "Container Line" temporary; SetCountToZero: Boolean)
    var
        WhseJnlLine2: Record "Warehouse Journal Line";
        ContainerHeader: Record "Container Header";
    begin
        // P8001323
        ContainerDetailBuffer.SetRange("Lot No.", WhseJnlLine."Lot No.");
        ContainerDetailBuffer.SetRange("Serial No.", WhseJnlLine."Serial No.");
        if ContainerDetailBuffer.FindSet then begin
            repeat
                ContainerHeader.Get(ContainerDetailBuffer."Container ID");

                WhseJnlLine2 := WhseJnlLine;
                WhseJnlLine2."Qty. (Calculated)" := ContainerDetailBuffer.Quantity;
                WhseJnlLine2."Qty. (Calculated) (Base)" := ContainerDetailBuffer."Quantity (Base)";
                // WhseJnlLine2."Qty. (Alt.) (Calculated)" := ContainerDetailBuffer."Quantity (Alt.)"; // P8004516  // P80049717
                WhseJnlLine."Qty. (Calculated)" -= ContainerDetailBuffer.Quantity;    // P80058977  // P80060078
                if Item."Catch Alternate Qtys." then
                    WhseJnlLine2."Qty. (Alt.) (Calculated)" := ContainerDetailBuffer."Quantity (Alt.)";
                if (not SetCountToZero) or (ContainerHeader."Document Type" <> 0) then begin
                    WhseJnlLine2.Validate("Qty. (Phys. Inventory)", WhseJnlLine2."Qty. (Calculated)");
                    WhseJnlLine2.Validate("Qty. (Phys. Inventory) (Base)", WhseJnlLine2."Qty. (Calculated) (Base)");
                    if WhseJnlLine2."Qty. (Alt.) (Calculated)" <> 0 then                                              // P8004516
                        WhseJnlLine2.Validate("Qty. (Alt.) (Phys. Inventory)", WhseJnlLine2."Qty. (Alt.) (Calculated)"); // P8004516
                end else begin                                                // P8004516
                    WhseJnlLine2.Validate("Qty. (Phys. Inventory)", 0);
                    if WhseJnlLine2."Qty. (Alt.) (Calculated)" <> 0 then        // P8004516
                        WhseJnlLine2.Validate("Qty. (Alt.) (Phys. Inventory)", 0); // P8004516
                end;                                                          // P8004516

                WhseJnlLine2."Container License Plate" := ContainerHeader."License Plate";
                // P8008649
                if SetCountToZero then begin
                    WhseJnlLine2."From Container License Plate" := ContainerHeader."License Plate";
                    WhseJnlLine2."From Container ID" := ContainerHeader.ID;
                end else begin
                    // P8008649
                    WhseJnlLine2."To Container License Plate" := ContainerHeader."License Plate";
                    WhseJnlLine2."To Container ID" := ContainerHeader.ID;
                end; // P8008649
                WhseJnlLine2."Shipping Container" := ContainerHeader."Document Type" <> 0;
                OnBeforeWhseJnlLineInsert(WhseJnlLine2, WarehouseEntry, NextLineNo); // P800-MegaApp
                WhseJnlLine2.Insert(true);

                NextLineNo += 10000;
                WhseJnlLine2."Line No." := NextLineNo;
                WhseJnlLine."Line No." := WhseJnlLine2."Line No.";
            until ContainerDetailBuffer.Next = 0;

            WhseJnlLine."Qty. (Calculated) (Base)" := Round(WhseJnlLine."Qty. (Calculated)" * WhseJnlLine."Qty. per Unit of Measure", 0.00001);
            if not SetCountToZero then begin
                WhseJnlLine.Validate("Qty. (Phys. Inventory)", WhseJnlLine."Qty. (Calculated)");
                WhseJnlLine.Validate("Qty. (Phys. Inventory) (Base)", WhseJnlLine."Qty. (Calculated) (Base)");
                if Item."Catch Alternate Qtys." then
                    WhseJnlLine.Validate("Qty. (Alt.) (Phys. Inventory)", WhseJnlLine."Qty. (Alt.) (Calculated)");
            end else begin
                WhseJnlLine.Validate("Qty. (Phys. Inventory)", 0);
                if Item."Catch Alternate Qtys." then
                    WhseJnlLine.Validate("Qty. (Alt.) (Phys. Inventory)", 0);
            end;
        end;

        if Item."Catch Alternate Qtys." then
            WhseJnlLine."Qty. (Alt.) (Calculated)" := Round(WhseJnlLine."Qty. (Calculated) (Base)" * Item.AlternateQtyPerBase, 0.00001);
        if not SetCountToZero then begin
            if Item."Catch Alternate Qtys." then
                WhseJnlLine.Validate("Qty. (Alt.) (Phys. Inventory)", WhseJnlLine."Qty. (Alt.) (Calculated)");
        end else begin
            if Item."Catch Alternate Qtys." then
                WhseJnlLine.Validate("Qty. (Alt.) (Phys. Inventory)", 0);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitBinContent(var BinContent: Record "Bin Content"; WarehouseEntry: Record "Warehouse Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOnPostReport(var WarehouseJournalLine: Record "Warehouse Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterWhseJnlLineInsert(var WarehouseJournalLine: Record "Warehouse Journal Line"; var NextLineNo: Integer; var BinContent: Record "Bin Content")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWhseJnlLineInsert(var WarehouseJournalLine: Record "Warehouse Journal Line"; var WarehouseEntry: Record "Warehouse Entry"; var NextLineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBinContentOnBeforePreDataItem(var BinContent: Record "Bin Content"; var WarehouseJournalLine: Record "Warehouse Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertWhseJnlLineOnAfterWhseEntrySetFilters(var WhseEntry: Record "Warehouse Entry"; var BinContent: Record "Bin Content")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnWarehouseEntryOnAfterGetRecordOnAfterCalcSkipRecord(var WarehouseEntry: Record "Warehouse Entry"; var SkipRecord: Boolean)
    begin
    end;
}

