codeunit 37002735 "Sub-Lot Management"
{
    // PRW118.1
    // P800129613, To Increase, Jack Reynolds, 20 SEP 21
    //   Creatre Sub-Lot Wizard
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 26 APR 22
    //   Upgrade to 20.0 - Refactoring for default dimensions

    EventSubscriberInstance = Manual;

    var
        ContainerLinePost: Record "Container Line";
        QCToSkip: List of [Integer];
        ErrExcessReclassQuantity: Label 'Quantity to reclass exceeds quantity in container "%1".';

    procedure CreateSubLotWizard()
    var
        CreateSubLotWizard: page "Create Sub-Lot Wizard";
    begin
        CreateSubLotWizard.RunModal();
    end;

    procedure CreateSubLotWizard(SourceRec: Variant)
    var
        CreateSubLotWizard: page "Create Sub-Lot Wizard";
    begin
        CreateSubLotWizard.SetSource(SourceRec);
        CreateSubLotWizard.RunModal();
    end;

    procedure CreateSubLot(SubLot: Record "Sub-Lot Buffer"; var ReclassQuantity: Record "Sub-Lot Buffer" temporary; var QualityControl: Record "Sub-Lot Buffer" temporary)
    var
        Location: Record Location;
        SourceCodeSetup: Record "Source Code Setup";
        PostingBuffer: Record "Sub-Lot Buffer" temporary;
        SubLotManagement: Codeunit "Sub-Lot Management";
    begin
        if Location.Get(SubLot."Location Code") then;
        SourceCodeSetup.Get();
        SubLot.SourceCode := SourceCodeSetup."Item Reclass. Journal";

        ContainerLinePost.SetUsageParms(SubLot."Posting Date", SubLot."Document No.", '', SubLot.SourceCode);

        SubLotManagement.SetQCToSkip(QualityControl);
        BindSubscription(SubLotManagement);

        ReclassQuantity.Reset();
        ReclassQuantity.SetFilter("Quantity to Reclass", '>0');
        if ReclassQuantity.FindSet() then
            repeat
                PostingBuffer.SetRange("Bin Code", ReclassQuantity."Bin Code");
                if Location."Directed Put-away and Pick" then
                    PostingBuffer.SetRange("Unit of Measure Code", ReclassQuantity."Unit of Measure Code");
                if not PostingBuffer.FindFirst() then begin
                    PostingBuffer := ReclassQuantity;
                    PostingBuffer.Insert();
                end else begin
                    PostingBuffer."Quantity to Reclass" += ReclassQuantity."Quantity to Reclass";
                    PostingBuffer."Quantity to Reclass (Base)" += ReclassQuantity."Quantity to Reclass (Base)";
                    PostingBuffer."Quantity to Reclass (Alt.)" += ReclassQuantity."Quantity to Reclass (Alt.)";
                    PostingBuffer.Modify();
                end;

                if ReclassQuantity.ContainerID <> '' then
                    RemoveFromContainer(ReclassQuantity);
            until ReclassQuantity.Next() = 0;

        PostingBuffer.Reset();
        if PostingBuffer.FindSet() then
            repeat
                // PostingBuffer."Quantity to Reclass (Base)" := Round(PostingBuffer."Quantity to Reclass" * PostingBuffer.QtyPerUOM, 0.00001);
                if not Location."Directed Put-away and Pick" then begin
                    PostingBuffer."Unit of Measure Code" := SubLot."Base Unit of Measure";
                    PostingBuffer."Quantity to Reclass" := PostingBuffer."Quantity to Reclass (Base)";
                end;
                PostReclass(SubLot, PostingBuffer);
            until PostingBuffer.Next() = 0;

        ReclassQuantity.Reset();
        ReclassQuantity.SetFilter("Quantity to Reclass", '>0');
        ReclassQuantity.SetFilter(ContainerID, '<>%1', '');
        if ReclassQuantity.FindSet() then
            repeat
                ReclassQuantity."Sub-Lot No." := SubLot."Sub-Lot No.";
                AddToContainer(ReclassQuantity);
            until ReclassQuantity.Next() = 0;

        ReclassQuantity.Reset();
        ReclassQuantity.SetFilter("No. of Labels", '>0');
        if ReclassQuantity.FindSet() then
            repeat
                ReclassQuantity."Sub-Lot No." := SubLot."Sub-Lot No.";
                PrintLabels(ReclassQuantity);
            until ReclassQuantity.Next() = 0;
    end;

    procedure SetQCToSkip(var QualityControl: Record "Sub-Lot Buffer" temporary)
    begin
        QualityControl.Reset();
        QualityControl.SetRange("Copy to Sub-lot", false);
        if QualityControl.FindSet() then
            repeat
                QCToSkip.Add(QualityControl."Test No.");
            until QualityControl.Next() = 0;
    end;

    local procedure RemoveFromContainer(ReclassQuantity: Record "Sub-Lot Buffer")
    var
        ContainerLine: Record "Container Line";
        QtyToRemove, QtytoRemoveAlt, QtyAlt : Decimal;
    begin
        ContainerLine.SetRange("Container ID", ReclassQuantity.ContainerID);
        ContainerLine.SetRange("Item No.", ReclassQuantity."Item No.");
        ContainerLine.SetRange("Variant Code", ReclassQuantity."Variant Code");
        ContainerLine.SetRange("Lot No.", ReclassQuantity."Lot No.");
        ContainerLine.SetRange("Unit of Measure Code", ReclassQuantity."Unit of Measure Code");
        if ContainerLine.FindSet(true) then begin
            ContainerLinePost := ContainerLine;
            ContainerLinePost.Quantity := ReclassQuantity."Quantity to Reclass";
            ContainerLinePost."Quantity (Alt.)" := ReclassQuantity."Quantity to Reclass (Alt.)";
            repeat
                if ContainerLine.Quantity < ReclassQuantity."Quantity to Reclass" then
                    QtyToRemove := ContainerLine.Quantity
                else
                    QtyToRemove := ReclassQuantity."Quantity to Reclass";
                if ReclassQuantity.CatchAlternateQuantity then begin
                    if ContainerLine."Quantity (Alt.)" < ReclassQuantity."Quantity to Reclass (Alt.)" then
                        QtytoRemoveAlt := ContainerLine."Quantity (Alt.)"
                    else
                        QtytoRemoveAlt := ReclassQuantity."Quantity to Reclass (Alt.)";
                    QtyAlt := ContainerLine."Quantity (Alt.)" - QtytoRemoveAlt;
                end;

                ContainerLine.Validate(ContainerLine.Quantity, ContainerLine.Quantity - QtyToRemove);
                if ReclassQuantity.CatchAlternateQuantity then
                    if ContainerLine.Quantity > 0 then
                        ContainerLine.Validate("Quantity (Alt.)", QtyAlt)
                    else
                        ContainerLine."Quantity (Alt.)" := QtyAlt;

                ReclassQuantity."Quantity to Reclass" -= QtyToRemove;
                ReclassQuantity."Quantity to Reclass (Alt.)" -= QtytoRemoveAlt;

                if ReclassQuantity.CatchAlternateQuantity and ((ContainerLine.Quantity = 0) or (ContainerLine."Quantity (Alt.)" = 0)) then begin
                    // May need to shift some residual quantity to another container line
                    ReclassQuantity."Quantity to Reclass" -= ContainerLine.Quantity;
                    ReclassQuantity."Quantity to Reclass (Alt.)" -= ContainerLine."Quantity (Alt.)";
                    ContainerLine.Delete();
                end else
                    ContainerLine.Modify();
            until (ContainerLine.Next() = 0) or ((ReclassQuantity."Quantity to Reclass" = 0) and (ReclassQuantity."Quantity to Reclass (Alt.)" = 0));
            if (ReclassQuantity."Quantity to Reclass" <> 0) or (ReclassQuantity."Quantity to Reclass (Alt.)" <> 0) then
                Error(ErrExcessReclassQuantity, ReclassQuantity."Container License Plate");
            ContainerLinePost.PostContainerUse(ContainerLinePost.Quantity, ContainerLinePost."Quantity (Alt.)", 0, 0);
        end;
    end;

    local procedure AddToContainer(ReclassQuantity: Record "Sub-Lot Buffer")
    var
        ContainerLine: Record "Container Line";
        LineNo: Integer;
    begin
        ContainerLine.SetRange("Container ID", ReclassQuantity.ContainerID);
        if ContainerLine.FindLast() then
            LineNo := ContainerLine."Line No.";

        ContainerLine.Init();
        ContainerLine."Container ID" := ReclassQuantity.ContainerID;
        ContainerLine."Line No." := LineNo + 10000;
        ContainerLine."Location Code" := ReclassQuantity."Location Code";
        ContainerLine."Bin Code" := ReclassQuantity."Bin Code";
        ContainerLine.Validate("Item No.", ReclassQuantity."Item No.");
        ContainerLine.Validate("Variant Code", ReclassQuantity."Variant Code");
        ContainerLine.Validate("Lot No.", ReclassQuantity."Sub-Lot No.");
        ContainerLine.Validate("Unit of Measure Code", ReclassQuantity."Unit of Measure Code");
        ContainerLine.Validate(Quantity, ReclassQuantity."Quantity to Reclass");
        if ReclassQuantity.CatchAlternateQuantity then
            ContainerLine.Validate("Quantity (Alt.)", ReclassQuantity."Quantity to Reclass (Alt.)");
        ContainerLine.Insert();

        ContainerLinePost := ContainerLine;
        ContainerLinePost.Quantity := ReclassQuantity."Quantity to Reclass";
        ContainerLinePost."Quantity (Alt.)" := ReclassQuantity."Quantity to Reclass (Alt.)";
        ContainerLinePost.PostContainerUse(0, 0, ContainerLinePost.Quantity, ContainerLinePost."Quantity (Alt.)");
    end;

    local procedure PostReclass(SubLot: Record "Sub-Lot Buffer"; ReclassQuantity: Record "Sub-Lot Buffer" temporary)
    var
        ItemJournalLine: Record "Item Journal Line";
        AlternateQuantityLine: Record "Alternate Quantity Line";
        LotNoInfo: Record "Lot No. Information";
        ReservEntry: Record "Reservation Entry";
        TrackingSpecification: Record "Tracking Specification";
        AltQtyManagement: Codeunit "Alt. Qty. Management";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        WhseJnlRegisterLine: Codeunit "Whse. Jnl.-Register Line";
    begin
        ItemJournalLine.INIT;
        ItemJournalLine."Posting Date" := SubLot."Posting Date";
        ItemJournalLine."Document Date" := SubLot."Posting Date";
        ItemJournalLine."Document No." := SubLot."Document No.";
        ItemJournalLine."Entry Type" := ItemJournalLine."Entry Type"::Transfer;
        ItemJournalLine."Source Code" := SubLot.SourceCode;
        ItemJournalLine."Reason Code" := SubLot."Reason Code";
        ItemJournalLine.Validate("Item No.", ReclassQuantity."Item No.");
        ItemJournalLine.Validate("Variant Code", ReclassQuantity."Variant Code");
        ItemJournalLine.Validate("Unit of Measure Code", ReclassQuantity."Unit of Measure Code");
        ItemJournalLine.Validate("Location Code", ReclassQuantity."Location Code");
        ItemJournalLine.Validate("New Location Code", ReclassQuantity."Location Code");
        ItemJournalLine.Validate("Bin Code", ReclassQuantity."Bin Code");
        ItemJournalLine.Validate("New Bin Code", ReclassQuantity."Bin Code");
        ItemJournalLine.Validate("New Lot Status Code", SubLot."Lot Status Code");
        ItemJournalLine.Validate(Quantity, ReclassQuantity."Quantity to Reclass");
        if ReclassQuantity.CatchAlternateQuantity then begin
            ItemJournalLine.Validate("Quantity (Alt.)", ReclassQuantity."Quantity to Reclass (Alt.)");
            AltQtyManagement.StartItemJnlAltQtyLine(ItemJournalLine);
            AltQtyManagement.CreateAltQtyLine(AlternateQuantityLine, ItemJournalLine."Alt. Qty. Transaction No.",
              10000, Database::"Item Journal Line", 0, '', '', '', 0);
            AlternateQuantityLine."Lot No." := ReclassQuantity."Lot No.";
            AlternateQuantityLine."New Lot No." := SubLot."Sub-Lot No.";
            AlternateQuantityLine."Quantity (Base)" := ReclassQuantity."Quantity to Reclass (Base)";
            AlternateQuantityLine.Quantity := ReclassQuantity."Quantity to Reclass";
            AlternateQuantityLine."Quantity (Alt.)" := ReclassQuantity."Quantity to Reclass (Alt.)";
            AlternateQuantityLine."Invoiced Qty. (Alt.)" := ReclassQuantity."Quantity to Reclass (Alt.)";
            AlternateQuantityLine.Modify();
        end;
        ReservEntry."Lot No." := ReclassQuantity."Lot No.";
        CreateReservEntry.CreateReservEntryFor(
          Database::"Item Journal Line", ItemJournalLine."Entry Type".AsInteger(), '', '', 0, 0,
          ItemJournalLine."Qty. per Unit of Measure", ItemJournalLine.Quantity, ItemJournalLine."Quantity (Base)",
          ReservEntry);
        TrackingSpecification."New Lot No." := SubLot."Sub-Lot No.";
        CreateReservEntry.SetNewTrackingFromNewTrackingSpecification(TrackingSpecification);
        if ReclassQuantity."Lot No." <> '' then begin
            LotNoInfo.GET(ItemJournalLine."Item No.", ItemJournalLine."Variant Code", ReclassQuantity."Lot No.");
            CreateReservEntry.SetNewExpirationDate(LotNoInfo."Expiration Date");
        end;
        CreateReservEntry.SetNewLotStatus(SubLot."Lot Status Code");
        CreateReservEntry.AddAltQtyData(-ReclassQuantity."Quantity to Reclass (Alt.)");
        CreateReservEntry.CreateEntry(ItemJournalLine."Item No.", ItemJournalLine."Variant Code",
          ItemJournalLine."Location Code", ItemJournalLine.Description, 0D, ItemJournalLine."Posting Date", 0, "Reservation Status"::Prospect);

        ItemJournalLine.CreateDimFromDefaultDim(ItemJournalLine.FieldNo("Item No.")); // P800144605
        ItemJnlPostLine.RunWithCheck(ItemJournalLine);
        if SubLot.BinMandatory then
            RegisterWhseJnlLine(ItemJnlPostLine, WhseJnlRegisterLine, ItemJournalLine);
    end;

    local procedure RegisterWhseJnlLine(var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var WhseJnlRegisterLine: Codeunit "Whse. Jnl.-Register Line"; ItemJournalLine: Record "Item Journal Line")
    var
        WarehouseJournalLine: Record "Warehouse Journal Line";
        Bin: Record Bin;
        WMSManagement: Codeunit "WMS Management";
        WhseManagement: Codeunit "Whse. Management";
    begin
        if WMSManagement.CreateWhseJnlLine(ItemJournalLine, 1, WarehouseJournalLine, false) then begin
            WarehouseJournalLine."From Bin Code" := ItemJournalLine."Bin Code";
            Bin.GET(WarehouseJournalLine."Location Code", WarehouseJournalLine."From Bin Code");
            WarehouseJournalLine."From Zone Code" := Bin."Zone Code";
            WarehouseJournalLine."To Bin Code" := ItemJournalLine."Bin Code";
            Bin.GET(WarehouseJournalLine."Location Code", WarehouseJournalLine."To Bin Code");
            WarehouseJournalLine."To Zone Code" := Bin."Zone Code";
            WarehouseJournalLine."New Lot No." := ItemJournalLine."New Lot No.";
            WarehouseJournalLine."Entry Type" := WarehouseJournalLine."Entry Type"::Movement;
            WarehouseJournalLine."Source Type" := Database::"Item Journal Line";
            WarehouseJournalLine."Source Subtype" := 1;
            WarehouseJournalLine."Source Document" := WhseManagement.GetSourceDocumentType(WarehouseJournalLine."Source Type", WarehouseJournalLine."Source Subtype");
            WarehouseJournalLine."Source No." := ItemJournalLine."Document No.";
            WarehouseJournalLine."Source Line No." := ItemJournalLine."Line No.";

            WMSManagement.CheckWhseJnlLine(WarehouseJournalLine, 1, 0, FALSE);
            WhseJnlRegisterLine.RUN(WarehouseJournalLine);
        end;
    end;

    local procedure PrintLabels(ReclassQuantity: Record "Sub-Lot Buffer")
    var
        ItemCaseLabel: Record "Item Case Label";
        // LabelData: RecordRef;
        LabelManagement: Codeunit "Label Management";
        FldList: Text[30];
    begin
        FldList := '01';
        ItemCaseLabel.Validate("Item No.", ReclassQuantity."Item No.");
        ItemCaseLabel.Validate("Variant Code", ReclassQuantity."Variant Code");
        FldList += ',10';
        ItemCaseLabel.Validate("Lot No.", ReclassQuantity."Sub-Lot No.");
        ItemCaseLabel.Validate("Unit of Measure Code", ReclassQuantity."Unit of Measure Code");
        ItemCaseLabel.Validate(Quantity, 1);

        ItemCaseLabel.CreateUCC(FldList);

        ItemCaseLabel."No. Of Copies" := ReclassQuantity."No. of Labels";
        // LabelData.GetTable(ItemCaseLabel);
        LabelManagement.PrintLabel(ReclassQuantity."Label Code", ReclassQuantity."Location Code", ItemCaseLabel);
    end;

    procedure GetReclassQuantity(SubLot: Record "Sub-Lot Buffer"; var ReclassQuantity: Record "Sub-Lot Buffer" temporary)
    var
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        WarehouseEntry: Record "Warehouse Entry";
        ContainerHeader: Record "Container Header";
        ContainerLine: Record "Container Line";
        ContainerSubLot: Record "Sub-Lot Buffer" temporary;
        EntryNo: Integer;
    begin
        ReclassQuantity.Reset();
        ReclassQuantity.DeleteAll();
        ReclassQuantity := SubLot;

        Item.Get(SubLot."Item No.");
        Item.GetItemUOMRndgPrecision(SubLot.AlternateUOM, true);

        // If containr has been specified then it not necessary to look beyond the container lines
        if SubLot.ContainerID <> '' then begin
            ContainerLine.SetRange("Container ID", SubLot.ContainerID);
            ContainerLine.SetRange("Item No.", SubLot."Item No.");
            ContainerLine.SetRange("Variant Code", SubLot."Variant Code");
            ContainerLine.SetRange("Lot No.", SubLot."Lot No.");
            GetContainerQuantity(ContainerLine, '', '', ReclassQuantity);
            exit;
        end;

        ItemLedgerEntry.SetRange("Item No.", SubLot."Item No.");
        ItemLedgerEntry.SetRange("Variant Code", SubLot."Variant Code");
        ItemLedgerEntry.SetRange("Lot No.", SubLot."Lot No.");
        ItemLedgerEntry.SetRange("Location Code", SubLot."Location Code");
        ItemLedgerEntry.CalcSums(Quantity, "Quantity (Alt.)");

        if SubLot.BinMandatory then begin
            WarehouseEntry.SetCurrentKey("Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code", "Lot No.");
            WarehouseEntry.SetRange("Item No.", SubLot."Item No.");
            WarehouseEntry.SetRange("Variant Code", SubLot."Variant Code");
            WarehouseEntry.SetRange("Lot No.", SubLot."Lot No.");
            WarehouseEntry.SetRange("Location Code", SubLot."Location Code");
            if SubLot."Bin Code" <> '' then
                WarehouseEntry.SetRange("Bin Code", SubLot."Bin Code");
            if WarehouseEntry.FindSet() then
                repeat
                    WarehouseEntry.FilterGroup(9);
                    WarehouseEntry.SetRange("Bin Code", WarehouseEntry."Bin Code");
                    WarehouseEntry.SetRange("Unit of Measure Code", WarehouseEntry."Unit of Measure Code");
                    WarehouseEntry.CalcSums(Quantity, "Qty. (Base)");
                    if WarehouseEntry.Quantity > 0 then begin
                        EntryNo += 1;
                        ReclassQuantity.EntryNo := EntryNo;
                        ReclassQuantity.Validate("Bin Code", WarehouseEntry."Bin Code");
                        ReclassQuantity.Validate("Unit of Measure Code", WarehouseEntry."Unit of Measure Code");
                        ReclassQuantity.Quantity := WarehouseEntry.Quantity;
                        ReclassQuantity."Quantity (Base)" := WarehouseEntry."Qty. (Base)";
                        ReclassQuantity.Insert();
                    end;
                    WarehouseEntry.FindLast();
                    WarehouseEntry.SetRange("Unit of Measure Code");
                    WarehouseEntry.SetRange("Bin Code");
                    WarehouseEntry.FilterGroup(0);
                until WarehouseEntry.Next() = 0;
        end else
            if ItemLedgerEntry.Quantity > 0 then begin
                EntryNo += 1;
                ReclassQuantity.EntryNo := EntryNo;
                ReclassQuantity.Validate("Unit of Measure Code", SubLot."Base Unit of Measure");
                ReclassQuantity.Quantity := ItemLedgerEntry.Quantity;
                ReclassQuantity."Quantity (Base)" := ItemLedgerEntry.Quantity;
                ReclassQuantity.Insert();
            end;

        if SubLot.ContainersEnabled then begin
            ContainerLine.SetRange("Item No.", SubLot."Item No.");
            ContainerLine.SetRange("Variant Code", SubLot."Variant Code");
            ContainerLine.SetRange("Lot No.", SubLot."Lot No.");
            ContainerLine.SetRange("Location Code", SubLot."Location Code");
            ContainerLine.SetRange(Inbound, false);

            ContainerSubLot := SubLot;
            GetContainerQuantity(ContainerLine, '', '', ContainerSubLot);
            if ContainerSubLot.FindSet() then
                repeat
                    if SubLot."Bin Code" in ['', ContainerSubLot."Bin Code"] then begin
                        ContainerHeader.Get(ContainerSubLot.ContainerID);
                        if ContainerHeader."Document Type" = 0 then begin
                            ReclassQuantity.TransferFields(ContainerSubLot);
                            EntryNo += 1;
                            ReclassQuantity.EntryNo := EntryNo;
                            ReclassQuantity.Insert();
                        end;

                        ReclassQuantity.SetRange("Bin Code", ContainerSubLot."Bin Code");
                        ReclassQuantity.SetRange("Unit of Measure Code", ContainerSubLot."Unit of Measure Code");
                        ReclassQuantity.SetRange(ContainerID, '');
                        if not ReclassQuantity.FindFirst() then begin
                            ReclassQuantity.SetRange("Unit of Measure Code", ContainerSubLot."Base Unit of Measure");
                            ReclassQuantity.FindFirst();
                            ContainerSubLot.Quantity := ContainerSubLot."Quantity (Base)";
                        end;
                        ReclassQuantity.Quantity -= ContainerSubLot.Quantity;
                        ReclassQuantity."Quantity (Base)" -= ContainerSubLot."Quantity (Base)";
                        if ReclassQuantity.Quantity <= 0 then
                            ReclassQuantity.Delete()
                        else
                            ReclassQuantity.Modify();
                    end;
                    
                    ItemLedgerEntry.Quantity -= ContainerSubLot."Quantity (Base)";
                    ItemLedgerEntry."Quantity (Alt.)" -= ContainerSubLot."Quantity (Alt.)";
                until ContainerSubLot.Next() = 0;
        end;

        if SubLot.CatchAlternateQuantity then begin
            ReclassQuantity.Reset();
            ReclassQuantity.SetRange(ContainerID, '');
            if ReclassQuantity.FindSet() then
                repeat
                    ReclassQuantity."Quantity (Alt.)" := Round(
                      (ReclassQuantity."Quantity (Base)" / ItemLedgerEntry.Quantity) * ItemLedgerEntry."Quantity (Alt.)", item."Rounding Precision");
                    ItemLedgerEntry.Quantity -= ReclassQuantity."Quantity (Base)";
                    ItemLedgerEntry."Quantity (Alt.)" -= ReclassQuantity."Quantity (Alt.)";
                    ReclassQuantity.Modify();
                until ReclassQuantity.Next() = 0;
        end;
    end;

    local procedure GetContainerQuantity(var ContainerLine: Record "Container Line"; BinCode: Code[20]; UOMCode: Code[10]; var ContainerSubLot: Record "Sub-Lot Buffer" temporary)
    var
        ContainerHeader: Record "Container Header";
        EntryNo: Integer;
    begin
        ContainerLine.SetCurrentKey("Item No.", "Variant Code", "Location Code", "Bin Code", "Unit of Measure Code", "Lot No.");
        if BinCode <> '' then
            ContainerLine.SetRange("Bin Code", BinCode);
        if UOMCode <> '' then
            ContainerLine.SetRange("Unit of Measure Code", UOMCode);
        if ContainerLine.FindSet() then
            repeat
                ContainerLine.FilterGroup(9);
                ContainerLine.SetRange("Container ID", ContainerLine."Container ID");
                ContainerLine.SetRange("Bin Code", ContainerLine."Bin Code");
                ContainerLine.SetRange("Unit of Measure Code", ContainerLine."Unit of Measure Code");
                ContainerLine.CalcSums(Quantity, "Quantity (Base)", "Quantity (Alt.)");
                if ContainerLine.Quantity > 0 then begin
                    ContainerHeader.Get(ContainerLine."Container ID");
                    EntryNo += 1;
                    ContainerSubLot.EntryNo := EntryNo;
                    ContainerSubLot.Validate(ContainerID, ContainerLine."Container ID");
                    ContainerSubLot.Validate("Container License Plate", ContainerHeader."License Plate");
                    ContainerSubLot.Validate("Bin Code", ContainerLine."Bin Code");
                    ContainerSubLot.Validate("Unit of Measure Code", ContainerLine."Unit of Measure Code");
                    ContainerSubLot.Quantity := ContainerLine.Quantity;
                    ContainerSubLot."Quantity (Base)" := ContainerLine."Quantity (Base)";
                    ContainerSubLot."Quantity (Alt.)" := ContainerLine."Quantity (Alt.)";
                    ContainerSubLot.Insert();
                end;
                ContainerLine.FindLast();
                ContainerLine.SetRange("Unit of Measure Code");
                ContainerLine.SetRange("Bin Code");
                ContainerLine.SetRange("Container ID");
                ContainerLine.FilterGroup(0);
            until ContainerLine.Next() = 0;
    end;

    procedure GetOpenQualityControl(SubLot: Record "Sub-Lot Buffer"; var OpenQualityControl: Record "Sub-Lot Buffer" temporary)
    var
        QualityControlHeader: Record "Quality Control Header";
    begin
        if not SubLot.QCEnabled then
            exit;

        OpenQualityControl.Reset();
        OpenQualityControl.DeleteAll();
        OpenQualityControl := SubLot;
        OpenQualityControl.EntryNo := 0;

        QualityControlHeader.SetRange("Item No.", SubLot."Item No.");
        QualityControlHeader.SetRange("Variant Code", SubLot."Variant Code");
        QualityControlHeader.SetRange("Lot No.", SubLot."Lot No.");
        QualityControlHeader.SetRange(Status, QualityControlHeader.Status::Pending);
        if QualityControlHeader.FindSet() then
            repeat
                OpenQualityControl.EntryNo += 1;
                OpenQualityControl."Test No." := QualityControlHeader."Test No.";
                OpenQualityControl."Re-Test" := QualityControlHeader."Re-Test";
                OpenQualityControl."Assigned To" := QualityControlHeader."Assigned To";
                OpenQualityControl."Schedule Date" := QualityControlHeader."Schedule Date";
                OpenQualityControl."Copy to Sub-lot" := true;
                OpenQualityControl.Insert();
                OpenQualityControl.SaveQualityTests(GetQualityTests(SubLot, OpenQualityControl));
            until QualityControlHeader.Next() = 0;
    end;

    local procedure GetQualityTests(SubLot: Record "Sub-Lot Buffer"; var OpenQualityControl: Record "Sub-Lot Buffer" temporary) Tests: Text
    var
        QualityControlLine: Record "Quality Control Line";
    begin
        QualityControlLine.SetRange("Item No.", SubLot."Item No.");
        QualityControlLine.SetRange("Variant Code", SubLot."Variant Code");
        QualityControlLine.SetRange("Lot No.", SubLot."Lot No.");
        QualityControlLine.SetRange("Test No.", OpenQualityControl."Test No.");
        if QualityControlLine.FindSet() then begin
            repeat
                Tests := Tests + ', ' + QualityControlLine."Test Code";
            until QualityControlLine.Next() = 0;
            Tests := CopyStr(Tests, 3);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process 800 Item Tracking", 'OnBeforeCopyQC', '', true, false)]
    local procedure Process800ItemTracking_OnBeforeCopyQC(QualityControlHeader: Record "Quality Control Header"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        Handled := QCToSkip.Contains(QualityControlHeader."Test No.");
    end;
}