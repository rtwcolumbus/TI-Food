codeunit 37002102 "Combine Whse. Lots"
{
    // PRW16.00.04
    // P8000888, VerticalSoft, Don Bresee, 13 DEC 10
    //   Create codeunit from code in Page 37002771
    // 
    // P8000890, VerticalSoft, Don Bresee, 15 DEC 10
    //   Add "Combine Lots Method" logic
    // 
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic
    // 
    // PRW17.00
    // P8001134, Columbus IT, Don Bresee, 16 FEB 13
    //   Add logic for handling of new "Order Type" option "Lot Combination"
    // 
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW18.00.01
    // P8001337, Columbus IT, Jack Reynolds, 31 MAR 15
    //   Support for containers
    // 
    // PRW19.00.01
    // P8006983, To Increase, Jack Reynolds, 11 MAY 16
    //   Fix problem with LIFO/FIFO automatic lot assignment for fixed production bins
    // 
    // PRW111.00.01
    // P80060684, To-Increase, Jack Reynolds, 08 AUG 18
    //   Combined Lot Expiration Date
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW118.01
    // P80094516, To Increase, Jack Reynolds, 24 SEP 21
    //   Use AutoIncrement property

    Permissions = TableData "Clear Bin History" = rim;

    trigger OnRun()
    begin
    end;

    var
        TempBinData: Record "Warehouse Entry" temporary;
        Item: Record Item;
        P800WhseActCreate: Codeunit "Process 800 Create Whse. Act.";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        P800ItemTracking: Codeunit "Process 800 Item Tracking";
        PostingDate: Date;
        WhseReg: Record "Warehouse Register";
        SourceCode: Code[10];
        DocumentNo: Code[20];
        Text000: Label 'You can only combine lots for a single item and bin.';
        Text001: Label 'No lots to combine.';
        Text002: Label 'You can only combine multiple lots.';
        ExistingLotNo: Code[50];
        Text003: Label 'Unable to assign lot number.';

    procedure SetPostingDate(NewPostingDate: Date)
    begin
        PostingDate := NewPostingDate;
    end;

    procedure SetSourceCode(NewSourceCode: Code[10])
    begin
        SourceCode := NewSourceCode;
    end;

    procedure SetDocumentNo(NewDocumentNo: Code[20])
    begin
        DocumentNo := NewDocumentNo;
    end;

    procedure SetWhseRegister(NewWhseReg: Record "Warehouse Register")
    begin
        WhseReg := NewWhseReg;
    end;

    procedure GetWhseRegister(var NewWhseReg: Record "Warehouse Register")
    begin
        NewWhseReg := WhseReg;
    end;

    procedure GetItemDescription(var WhseJnlLine: Record "Warehouse Entry"): Text[100]
    begin
        with WhseJnlLine do
            if ("Item No." <> '') then
                if Item.Get("Item No.") then
                    exit(Item.Description);
    end;

    procedure SetBinContents(var BinContent: Record "Bin Content")
    begin
        BuildTempData(BinContent);
        RemoveContainerized; // P8001337
        CheckTempData;
        TempBinData.FindFirst;
    end;

    procedure SetWhseEntry(var WhseEntry: Record "Warehouse Entry")
    var
        BinContent: Record "Bin Content";
    begin
        with WhseEntry do begin
            BinContent.SetRange("Location Code", "Location Code");
            BinContent.SetRange("Bin Code", "Bin Code");
            BinContent.SetRange("Item No.", "Item No.");
            BinContent.SetRange("Variant Code", "Variant Code");
            BuildTempData(BinContent);
        end;
    end;

    local procedure BuildTempData(var BinContent: Record "Bin Content")
    var
        WhseEntry: Record "Warehouse Entry";
        NextEntryNo: Integer;
    begin
        SetLotNo('');
        with TempBinData do begin
            Reset;
            DeleteAll;
            SetCurrentKey(
              "Location Code", "Bin Code", "Item No.", "Variant Code",
              "Unit of Measure Code", Open, "Lot No.", "Serial No.");

            WhseEntry.SetCurrentKey(
              "Location Code", "Bin Code", "Item No.", "Variant Code",
              "Unit of Measure Code", Open, "Lot No.", "Serial No.");

            if BinContent.FindSet then begin
                Item.Get(BinContent."Item No.");
                if not Item."Catch Alternate Qtys." then
                    repeat
                        WhseEntry.SetRange("Location Code", BinContent."Location Code");
                        WhseEntry.SetRange("Bin Code", BinContent."Bin Code");
                        WhseEntry.SetRange("Item No.", BinContent."Item No.");
                        WhseEntry.SetRange("Variant Code", BinContent."Variant Code");
                        WhseEntry.SetRange("Unit of Measure Code", BinContent."Unit of Measure Code");
                        WhseEntry.SetRange(Open, true);
                        BinContent.CopyFilter("Lot No. Filter", WhseEntry."Lot No.");
                        BinContent.CopyFilter("Serial No. Filter", WhseEntry."Serial No.");
                        if WhseEntry.Find('-') then
                            repeat
                                SetRange("Location Code", WhseEntry."Location Code");
                                SetRange("Bin Code", WhseEntry."Bin Code");
                                SetRange("Item No.", WhseEntry."Item No.");
                                SetRange("Variant Code", WhseEntry."Variant Code");
                                SetRange("Unit of Measure Code", WhseEntry."Unit of Measure Code");
                                SetRange("Lot No.", WhseEntry."Lot No.");
                                if FindFirst then begin
                                    Quantity := Quantity + WhseEntry."Remaining Quantity";
                                    "Qty. (Base)" := "Qty. (Base)" + WhseEntry."Remaining Qty. (Base)";
                                    Modify;
                                end else begin
                                    TempBinData := WhseEntry;
                                    NextEntryNo := NextEntryNo + 1;
                                    "Entry No." := NextEntryNo;
                                    Quantity := WhseEntry."Remaining Quantity";
                                    "Qty. (Base)" := WhseEntry."Remaining Qty. (Base)";
                                    Insert;
                                end;
                            until (WhseEntry.Next = 0);
                    until (BinContent.Next = 0);
            end;
            Reset;
        end;
    end;

    procedure Register()
    var
        NewLotNo: Code[50];
        ItemTrackingCode: Record "Item Tracking Code";
        LooseLotControl: Boolean;
    begin
        InitForRegister;

        TempBinData.FindSet;
        Item.Get(TempBinData."Item No.");
        if (ExistingLotNo <> '') then
            NewLotNo := ExistingLotNo
        else
            AssignNewLotNo(Item, NewLotNo);
        if (DocumentNo <> '') then
            P800WhseActCreate.SetItemPostingDocNo(DocumentNo)
        else
            P800WhseActCreate.SetItemPostingDocNo(NewLotNo);

        PostWhseAdjmts(Item);
        PostLotConversion(NewLotNo); // P8001134
    end;

    local procedure InitForRegister()
    begin
        P800WhseActCreate.SetSourceCode(SourceCode);
        if (PostingDate <> 0D) then
            P800WhseActCreate.SetRegisterDate(PostingDate)
        else
            P800WhseActCreate.SetRegisterDate(WorkDate);
        P800WhseActCreate.DisableCombineLots(true);
        P800WhseActCreate.SetItemPosting(true);
    end;

    local procedure AssignNewLotNo(var Item: Record Item; var NewLotNo: Code[50])
    var
        LotNoData: Record "Lot No. Data";
    begin
        // P8001234
        LotNoData.Validate("Item No.", Item."No.");
        if (PostingDate <> 0D) then
            LotNoData.Validate(Date, PostingDate)
        else
            LotNoData.Validate(Date, WorkDate);

        if LotNoData.OKToAssign then
            NewLotNo := LotNoData.AssignLotNo
        else
            Error(Text003);
        // P801234
    end;

    local procedure PostWhseAdjmts(var Item: Record Item)
    var
        TempILEData: Record "Item Ledger Entry" temporary;
        NextILEEntryNo: Integer;
    begin
        with TempILEData do begin
            TempBinData.FindSet;
            SetCurrentKey("Item No.", "Variant Code", "Lot No.");
            repeat
                SetRange("Item No.", TempBinData."Item No.");
                SetRange("Variant Code", TempBinData."Variant Code");
                SetRange("Lot No.", TempBinData."Lot No.");
                if FindFirst then begin
                    Quantity := Quantity + TempBinData."Qty. (Base)";
                    Modify;
                end else begin
                    NextILEEntryNo := NextILEEntryNo + 1;
                    "Entry No." := NextILEEntryNo;
                    "Item No." := TempBinData."Item No.";
                    "Variant Code" := TempBinData."Variant Code";
                    "Lot No." := TempBinData."Lot No.";
                    "Location Code" := TempBinData."Location Code";
                    Quantity := TempBinData."Qty. (Base)";
                    Insert;
                end;
            until (TempBinData.Next = 0);

            P800WhseActCreate.SetWhseRegister(WhseReg);
            FindSet;
            repeat
                Item.SetRange("Location Filter", "Location Code");
                Item.SetRange("Variant Filter", "Variant Code");
                Item.SetRange("Lot No. Filter", "Lot No.");
                Item.CalcFields(Inventory);
                if (Item.Inventory < Quantity) then
                    P800WhseActCreate.PostAdjmtBase(
                      "Location Code", "Item No.", "Variant Code",
                      "Lot No.", '', Quantity - Item.Inventory);
            until (Next = 0);
            P800WhseActCreate.GetWhseRegister(WhseReg);
        end;
    end;

    local procedure PostLotConversion(NewLotNo: Code[50])
    var
        TotalUOMQty: Decimal;
        TotalUOMQtyBase: Decimal;
        ItemJnlLine: Record "Item Journal Line";
    begin
        P800WhseActCreate.StartLotCombination(NewLotNo, CombinedLotExpDate); // P8001134, P80060684
        with TempBinData do
            while not IsEmpty do begin
                P800WhseActCreate.SetWhseRegister(WhseReg);
                FindSet;
                SetRange("Unit of Measure Code", "Unit of Measure Code");
                TotalUOMQty := 0;
                TotalUOMQtyBase := 0;
                repeat
                    TotalUOMQty := TotalUOMQty + Quantity;
                    TotalUOMQtyBase := TotalUOMQtyBase + "Qty. (Base)";
                until (Next = 0);
                P800WhseActCreate.RegisterAdjmtBase(
                  "Location Code", "Bin Code", "Item No.", "Variant Code",
                  "Unit of Measure Code", NewLotNo, "Serial No.", TotalUOMQty, TotalUOMQtyBase);
                FindSet(true);
                repeat
                    P800WhseActCreate.RegisterAdjmtBase(
                      "Location Code", "Bin Code", "Item No.", "Variant Code",
                      "Unit of Measure Code", "Lot No.", "Serial No.", -Quantity, -"Qty. (Base)");
                    Delete;
                until (Next = 0);
                SetRange("Unit of Measure Code");
                P800WhseActCreate.GetWhseRegister(WhseReg);
            end;
        P800WhseActCreate.EndLotCombination; // P8001134
    end;

    local procedure CheckTempData()
    var
        FirstRec: Record "Warehouse Entry";
    begin
        with TempBinData do begin
            if FindSet then begin
                FirstRec := TempBinData;
                repeat
                    if ("Location Code" <> FirstRec."Location Code") or
                       ("Bin Code" <> FirstRec."Bin Code") or
                       ("Item No." <> FirstRec."Item No.") or
                       ("Variant Code" <> FirstRec."Variant Code")
                    then
                        Error(Text000);
                until (Next = 0);
            end;
            SetFilter("Lot No.", '<>%1', '');
            if not FindFirst then
                Error(Text001);
            SetFilter("Lot No.", '<>%1', "Lot No.");
            if not FindFirst then
                Error(Text002);
            SetRange("Lot No.");
        end;
    end;

    procedure IsCombineNeeded() Combine: Boolean
    begin
        with TempBinData do
            if FindFirst then
                if (ExistingLotNo <> '') then
                    Combine := true
                else begin
                    SetFilter("Lot No.", '<>%1', "Lot No.");
                    Combine := FindFirst;
                    SetRange("Lot No.");
                end;
    end;

    procedure AddFixedBinTracking(var ItemJnlLine: Record "Item Journal Line")
    var
        ItemFixedBin: Record "Item Fixed Prod. Bin";
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        RemQtyBase: Decimal;
        WhseEntry: Record "Warehouse Entry";
    begin
        with ItemJnlLine do
            if ("Entry Type" = "Entry Type"::Consumption) and
               ("Item No." <> '') and ("Location Code" <> '') and ("Quantity (Base)" > 0)
            then
                if ItemFixedBin.Get("Item No.", "Location Code") then
                    if (ItemFixedBin."Lot Handling" <> ItemFixedBin."Lot Handling"::Manual) then begin
                        RemQtyBase := "Quantity (Base)";
                        if ItemTrackingMgt.RetrieveItemTracking(ItemJnlLine, TempTrackingSpecification) then begin
                            TempTrackingSpecification.FindSet;
                            repeat
                                InsertItemJnlTrackingLine(
                                  ItemJnlLine, TempTrackingSpecification."Lot No.",
                                  Signed(TempTrackingSpecification."Quantity (Base)"));
                                RemQtyBase := RemQtyBase - Signed(TempTrackingSpecification."Quantity (Base)");
                            until (TempTrackingSpecification.Next = 0);
                        end;
                        if (RemQtyBase > 0) then begin
                            WhseEntry.SetCurrentKey(
                              "Location Code", "Bin Code", "Item No.", "Variant Code",
                              "Unit of Measure Code", Open, "Entry No."); // P8006983
                            if (ItemFixedBin."Lot Handling" = ItemFixedBin."Lot Handling"::LIFO) then
                                WhseEntry.Ascending(false);
                            WhseEntry.SetRange("Location Code", "Location Code");
                            WhseEntry.SetRange("Bin Code", ItemFixedBin."Bin Code");
                            WhseEntry.SetRange("Item No.", "Item No.");
                            WhseEntry.SetRange("Variant Code", "Variant Code");
                            WhseEntry.SetRange(Open, true);
                            if WhseEntry.FindFirst then
                                repeat
                                    // P8006983
                                    //WhseEntry.SETRANGE("Unit of Measure Code", WhseEntry."Unit of Measure Code");
                                    //WhseEntry.SETRANGE("Lot No.", WhseEntry."Lot No.");
                                    //WhseEntry.CALCSUMS("Remaining Qty. (Base)");
                                    // P8006983
                                    if (WhseEntry."Remaining Qty. (Base)" > 0) then begin
                                        if (WhseEntry."Remaining Qty. (Base)" > RemQtyBase) then
                                            WhseEntry."Remaining Qty. (Base)" := RemQtyBase;
                                        InsertItemJnlTrackingLine(
                                          ItemJnlLine, WhseEntry."Lot No.", WhseEntry."Remaining Qty. (Base)");
                                        RemQtyBase := RemQtyBase - WhseEntry."Remaining Qty. (Base)";
                                    end;
                                    // P8006983
                                    //WhseEntry.FINDLAST;
                                    //WhseEntry.SETRANGE("Unit of Measure Code");
                                    //WhseEntry.SETRANGE("Lot No.");
                                    // P8006983
                                until (RemQtyBase = 0) or (WhseEntry.Next = 0);
                        end;
                    end;
    end;

    procedure InsertItemJnlTrackingLine(var ItemJnlLine: Record "Item Journal Line"; LotNo: Code[50]; QtyBase: Decimal)
    var
        ResEntry: Record "Reservation Entry";
    begin
        with ItemJnlLine do begin
            // P80094516
            // if not ResEntry.Find('+') then
            //     ResEntry."Entry No." := 0;
            // P80094516
            ResEntry.Init;
            ResEntry."Entry No." := 0; // P80094516
            ResEntry."Item No." := "Item No.";
            ResEntry."Variant Code" := "Variant Code";
            ResEntry."Location Code" := "Location Code";
            ResEntry."Source Type" := DATABASE::"Item Journal Line";
            ResEntry."Source Subtype" := "Entry Type";
            ResEntry."Source ID" := "Journal Template Name";
            ResEntry."Source Batch Name" := "Journal Batch Name";
            ResEntry."Source Ref. No." := "Line No.";
            ResEntry."Lot No." := LotNo;
            ResEntry."Reservation Status" := ResEntry."Reservation Status"::Prospect;
            ResEntry."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
            ResEntry."Quantity (Base)" := Signed(QtyBase);
            ResEntry."Qty. to Handle (Base)" := ResEntry."Quantity (Base)";
            ResEntry."Qty. to Invoice (Base)" := ResEntry."Quantity (Base)";
            ResEntry.Insert;
        end;
    end;

    procedure GetRegisters(var ItemReg2: Record "Item Register"; var ItemApplnEntryNo2: Integer; var WhseReg2: Record "Warehouse Register"; var GLReg2: Record "G/L Register"; var NextVATEntryNo2: Integer; var NextTransactionNo2: Integer)
    begin
        P800WhseActCreate.GetRegisters(
          ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
        GetWhseRegister(WhseReg2);
    end;

    procedure SetRegisters(var ItemReg2: Record "Item Register"; ItemApplnEntryNo2: Integer; var WhseReg2: Record "Warehouse Register"; var GLReg2: Record "G/L Register"; NextVATEntryNo2: Integer; NextTransactionNo2: Integer)
    begin
        P800WhseActCreate.SetRegisters(
          ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
        SetWhseRegister(WhseReg2);
    end;

    procedure LoadFormData(var BinContent: Record "Bin Content"; var TempFormData: Record "Warehouse Entry" temporary)
    begin
        SetBinContents(BinContent);
        CopyTempData(TempBinData, TempFormData);
    end;

    procedure SaveFormData(var TempFormData: Record "Warehouse Entry" temporary)
    begin
        CopyTempData(TempFormData, TempBinData);
        CheckTempData;
    end;

    local procedure CopyTempData(var FromTempData: Record "Warehouse Entry" temporary; var ToTempData: Record "Warehouse Entry" temporary)
    begin
        with ToTempData do begin
            Reset;
            DeleteAll;
        end;
        with FromTempData do begin
            Reset;
            if FindSet then
                repeat
                    ToTempData := FromTempData;
                    ToTempData.Insert;
                until (Next = 0);
        end;
    end;

    procedure SetBin(var Bin: Record Bin; var WhseEntry: Record "Warehouse Entry")
    begin
        with Bin do
            if ("Lot Combination Method" <> "Lot Combination Method"::"Use Existing Lot") then
                SetLotNo('')
            else begin
                if ("Current Lot No." <> '') then begin
                    TestField("Current Item No.", WhseEntry."Item No.");
                    TestField("Current Variant Code", WhseEntry."Variant Code");
                end else begin
                    "Current Item No." := WhseEntry."Item No.";
                    "Current Variant Code" := WhseEntry."Variant Code";
                    Item.Get("Current Item No.");
                    AssignNewLotNo(Item, "Current Lot No.");
                    Modify(true);
                end;
                SetLotNo("Current Lot No.");
            end;
    end;

    procedure SetLotNo(NewExistingLotNo: Code[50])
    begin
        ExistingLotNo := NewExistingLotNo;
        if (ExistingLotNo <> '') then
            with TempBinData do begin
                Reset;
                SetCurrentKey(
                  "Location Code", "Bin Code", "Item No.", "Variant Code",
                  "Unit of Measure Code", Open, "Lot No.", "Serial No.");
                FindFirst;
                SetRange("Location Code", "Location Code");
                SetRange("Bin Code", "Bin Code");
                SetRange("Item No.", "Item No.");
                SetRange("Variant Code", "Variant Code");
                SetRange("Lot No.", ExistingLotNo);
                DeleteAll;
                Reset;
            end;
    end;

    procedure ClearBin(var Bin: Record Bin)
    var
        BinContent: Record "Bin Content";
        ClearBinEntry: Record "Clear Bin History";
    begin
        BinContent.SetRange("Location Code", Bin."Location Code");
        BinContent.SetRange("Bin Code", Bin.Code);
        BuildTempData(BinContent);
        with TempBinData do
            if not IsEmpty then begin
                InitForRegister;
                P800WhseActCreate.SetWhseRegister(WhseReg);
                if (DocumentNo <> '') then
                    P800WhseActCreate.SetItemPostingDocNo(DocumentNo);
                FindSet;
                repeat
                    if (DocumentNo = '') then
                        P800WhseActCreate.SetItemPostingDocNo("Lot No.");
                    P800WhseActCreate.RegisterAdjmtBase(
                      "Location Code", "Bin Code", "Item No.", "Variant Code",
                      "Unit of Measure Code", "Lot No.", "Serial No.", -Quantity, -"Qty. (Base)");
                    InsertClearBinEntry(Bin, ClearBinEntry, true);
                until (Next = 0);
                P800WhseActCreate.GetWhseRegister(WhseReg);
                Bin.Find;
            end;
        if (Bin."Current Lot No." <> '') then begin
            Bin."Current Item No." := '';
            Bin."Current Variant Code" := '';
            Bin."Current Lot No." := '';
            Bin.Modify(true);
            if (ClearBinEntry."Entry No." = 0) then
                InsertClearBinEntry(Bin, ClearBinEntry, false);
        end;
    end;

    local procedure InsertClearBinEntry(var Bin: Record Bin; var ClearBinEntry: Record "Clear Bin History"; AssignEntryNos: Boolean)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        WhseEntry: Record "Warehouse Entry";
    begin
        with ClearBinEntry do begin
            if ("Entry No." = 0) then begin
                LockTable;
                if FindLast then;
            end;
            "Entry No." := "Entry No." + 1;
            Init;
            "Location Code" := Bin."Location Code";
            "Bin Code" := Bin.Code;
            "User ID" := UserId;
            "Date/Time" := CurrentDateTime;
            if AssignEntryNos then begin
                ItemLedgEntry.FindLast;
                "Item Entry No." := ItemLedgEntry."Entry No.";
                WhseEntry.FindLast;
                "Whse. Entry No." := WhseEntry."Entry No.";
            end;
            Insert;
        end;
    end;

    procedure RegisterManifest(var CommManifestHeader: Record "Commodity Manifest Header")
    var
        CommManifestLine: Record "Commodity Manifest Line";
        NextEntryNo: Integer;
        QtyBase: Decimal;
    begin
        // P8000891
        ExistingLotNo := CommManifestHeader."Lot No.";
        with TempBinData do begin
            Reset;
            DeleteAll;
            SetCurrentKey(
              "Location Code", "Bin Code", "Item No.", "Variant Code",
              "Unit of Measure Code", Open, "Lot No.", "Serial No.");
            SetRange("Location Code", CommManifestHeader."Location Code");
            SetRange("Bin Code", CommManifestHeader."Bin Code");
            SetRange("Item No.", CommManifestHeader."Item No.");
            SetRange("Variant Code", CommManifestHeader."Variant Code");

            CommManifestLine.SetRange("Commodity Manifest No.", CommManifestHeader."No.");
            CommManifestLine.FindSet;
            repeat
                QtyBase := CommManifestHeader.GetBaseQty(CommManifestLine."Manifest Quantity");
                SetRange("Lot No.", CommManifestLine."Received Lot No.");
                if FindFirst then begin
                    Quantity := Quantity + QtyBase;
                    "Qty. (Base)" := "Qty. (Base)" + QtyBase;
                    Modify;
                end else begin
                    NextEntryNo := NextEntryNo + 1;
                    "Entry No." := NextEntryNo;
                    Init;
                    "Location Code" := CommManifestHeader."Location Code";
                    "Bin Code" := CommManifestHeader."Bin Code";
                    "Item No." := CommManifestHeader."Item No.";
                    "Variant Code" := CommManifestHeader."Variant Code";
                    "Lot No." := CommManifestLine."Received Lot No.";
                    Quantity := QtyBase;
                    "Qty. (Base)" := QtyBase;
                    Insert;
                end;
            until (CommManifestLine.Next = 0);
            Reset;
        end;
        Register;
    end;

    local procedure RemoveContainerized()
    var
        ContainerLine: Record "Container Line";
    begin
        // P8001337
        with TempBinData do begin
            Reset;
            if FindSet(true) then
                repeat
                    ContainerLine.SetRange("Location Code", "Location Code");
                    ContainerLine.SetRange("Bin Code", "Bin Code");
                    ContainerLine.SetRange("Item No.", "Item No.");
                    ContainerLine.SetRange("Variant Code", "Variant Code");
                    ContainerLine.SetRange("Unit of Measure Code", "Unit of Measure Code");
                    ContainerLine.SetRange("Lot No.", "Lot No.");
                    ContainerLine.CalcSums(Quantity, "Quantity (Base)");
                    Quantity -= ContainerLine.Quantity;
                    "Qty. (Base)" -= ContainerLine."Quantity (Base)";
                    if 0 < Quantity then
                        Modify
                    else
                        Delete;
                until Next = 0;
        end;
    end;

    local procedure CombinedLotExpDate(): Date
    var
        TempData: Record "Warehouse Entry" temporary;
    begin
        // P80060684
        TempData.Copy(TempBinData, true);
        TempData.Reset;
        TempData.SetFilter("Expiration Date", '<>0D');
        TempData.SetCurrentKey("Expiration Date");
        if TempData.FindFirst then
            exit(TempData."Expiration Date");
    end;
}

