codeunit 37002043 "Purchase Order-Order Guide"
{
    // PR4.00.02
    // P8000314A, VerticalSoft, Jack Reynolds, 28 MAR 06
    //   Support functions for purchase order guide
    // 
    // PR4.00.04
    // P8000348A, VerticalSoft, Jack Reynolds, 28 JUN 06
    //   Fix issue with Last Order Amount and Last Cost (for different UOM's)
    // 
    // P8000356A, VerticalSoft, Jack Reynolds, 25 JUL 06
    //   Fix problem calculating unit cost
    // 
    // P8000368A, VerticalSoft, Jack Reynolds, 29 AUG 06
    //  Fix division by zero error when getting last transaction info and no history
    // 
    // P8000384A, VerticalSoft, Jack Reynolds, 22 SEP 06
    //   Cleanup confusion between buy-from and pay-to vendor
    // 
    // PRW16.00.02
    // P8000791, VerticalSoft, MMAS, 18 MAR 10
    //   1. Avoid error when open Vendor card from page
    //     Method ShowVendorCard() changed
    // 
    // PRW16.00.04
    // P8000879, VerticalSoft, Ron Davidson, 18 NOV 10
    //  Replaced Date Filter with History Period a DateFormula Data Type
    //  Created new function called SetStartEndDates called from Page 37002173
    // 
    // PRW16.00.06
    // P8000999, Columbus IT, Jack Reynolds, 15 DEC 11
    //   Non-modal operation of the Order Guide
    //   Different searching for history items
    // 
    // P8001004, Columbus IT, Jack Reynolds, 15 DEC 11
    //   Fixes to FactBoxes
    // 
    // PRW17.10
    // P8001230, Columbus IT, Jack Reynolds, 18 OCT 13
    //   Support for approved vendors
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Upgrade signal control for JavaScript
    // 
    // PRW119.0
    // P800133109, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 19.0 - Qty. Rounding Precision


    trigger OnRun()
    begin
    end;

    var
        GLSetup: Record "General Ledger Setup";
        PurchHeader: Record "Purchase Header";
        BuyFromVendor: Record Vendor;
        Text000: Label 'Nothing to add to the %1.';
        Text001: Label 'Adding Items...\\Item No. #1##################';
        Text002: Label 'One item added to the %1.';
        Text003: Label '%1 items added to the %2.';
        Text004: Label 'This form must be run from a Purchase Document.';
        PayToVendor: Record Vendor;
        SearchItemLedgEntry: Record "Item Ledger Entry";
        TempItemQty: Record "Item Ledger Entry" temporary;
        HistoryItem: Record Item;
        ApprovedItem: Record Item temporary;
        TempItemQtyEntryNo: Integer;
        StartingDate: Date;
        EndingDate: Date;
        ShowApprovedOnly: Boolean;
        Text005: Label 'Variant %1 is not approved for vendor %2.';

    procedure AddOrderLines(LocationCode: Code[10])
    var
        NewPurchLine: Record "Purchase Line";
        TransferExtendedText: Codeunit "Transfer Extended Text";
        LinesAdded: Integer;
        StatusWindow: Dialog;
    begin
        // P8000999
        with PurchHeader do begin
            TempItemQty.Reset;
            if not TempItemQty.Find('-') then begin
                Message(Text000, "Document Type");
                exit;
            end;

            StatusWindow.Open(Text001);

            NewPurchLine.SetRange("Document Type", "Document Type");
            NewPurchLine.SetRange("Document No.", "No.");
            if not NewPurchLine.Find('+') then begin
                NewPurchLine."Document Type" := "Document Type";
                NewPurchLine."Document No." := "No.";
                NewPurchLine."Line No." := 0;
            end;

            repeat
                StatusWindow.Update(1, TempItemQty."Item No.");

                NewPurchLine.Init;
                NewPurchLine."Line No." += 10000;
                NewPurchLine.Validate(Type, NewPurchLine.Type::Item);
                NewPurchLine.Validate("No.", TempItemQty."Item No.");
                if TempItemQty."Variant Code" <> '' then
                    NewPurchLine.Validate("Variant Code", TempItemQty."Variant Code");
                if (NewPurchLine."Unit of Measure Code" <> TempItemQty."Unit of Measure Code") then
                    NewPurchLine.Validate("Unit of Measure Code", TempItemQty."Unit of Measure Code");
                if (NewPurchLine."Location Code" <> LocationCode) then
                    NewPurchLine.Validate("Location Code", LocationCode);
                NewPurchLine.Validate(Quantity, TempItemQty.Quantity);
                NewPurchLine.Validate("Direct Unit Cost", TempItemQty."Remaining Quantity");
                NewPurchLine.Insert(true);
                if TransferExtendedText.PurchCheckIfAnyExtText(NewPurchLine, false) then begin
                    TransferExtendedText.InsertPurchExtText(NewPurchLine);
                    NewPurchLine.Find('+');
                end;

                LinesAdded := LinesAdded + 1;
            until (TempItemQty.Next = 0);

            if (LinesAdded = 1) then
                Message(Text002, "Document Type")
            else
                Message(Text003, LinesAdded, "Document Type");

            TempItemQty.DeleteAll;

            StatusWindow.Close;
        end;
    end;

    procedure SetDocument(var PurchHeader2: Record "Purchase Header")
    begin
        PurchHeader := PurchHeader2;
        BuyFromVendor.Get(PurchHeader."Buy-from Vendor No."); // P8000384A
        PayToVendor.Get(PurchHeader."Pay-to Vendor No.");     // P8000384A
        ShowApprovedOnly := not PurchHeader."Allow Unapproved Items"; // P8001230
    end;

    procedure SetAllowUnapproved(AllowUnapproved: Boolean)
    begin
        // P8001230
        ShowApprovedOnly := not AllowUnapproved;
    end;

    procedure GetFormCaption(): Text[250]
    var
        PurchaseOrderGuide: Page "Purchase Order Guide";
    begin
        exit(StrSubstNo('%1 - %2 %3 / %4 %5', PurchaseOrderGuide.Caption, // P80059471
                        BuyFromVendor."No.", BuyFromVendor.Name, // P8000384A
                        PurchHeader."Document Type", PurchHeader."No."));
    end;

    procedure ItemListInit(var Item: Record Item)
    begin
        if (BuyFromVendor."No." = '') then // P8000384A
            Error(Text004);

        GLSetup.Get; // P8000348A

        Item.SetRange("Location Filter", PurchHeader."Location Code");

        SearchItemLedgEntry.SetCurrentKey("Entry Type", "Item No.", "Variant Code", "Source Type", "Source No.", "Posting Date"); // P8000267B
        SearchItemLedgEntry.SetRange("Source Type", SearchItemLedgEntry."Source Type"::Vendor);
        SearchItemLedgEntry.SetRange("Source No.", BuyFromVendor."No."); // P8000384A
        SearchItemLedgEntry.SetRange("Entry Type", SearchItemLedgEntry."Entry Type"::Purchase);

        TempItemQty.SetCurrentKey("Item No.");
    end;

    procedure HistoryItemListInit()
    var
        ItemLedger: Record "Item Ledger Entry";
    begin
        // P8000999
        HistoryItem.Reset;

        ItemLedger.SetCurrentKey("Item No.", "Entry Type");
        ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::Purchase);
        ItemLedger.SetRange(Positive, true);
        ItemLedger.SetRange("Source Type", ItemLedger."Source Type"::Vendor);
        ItemLedger.SetRange("Source No.", BuyFromVendor."No.");

        if StartingDate <> 0D then
            ItemLedger.SetRange("Posting Date", StartingDate, EndingDate)
        else
            ItemLedger.SetRange("Posting Date");
        if ItemLedger.Find('-') then
            repeat
                HistoryItem.Get(ItemLedger."Item No.");
                HistoryItem.Mark(true);
                ItemLedger.SetRange("Item No.", ItemLedger."Item No.");
                ItemLedger.Find('+');
                ItemLedger.SetRange("Item No.");
            until ItemLedger.Next = 0;

        HistoryItem.MarkedOnly(true);
    end;

    procedure ItemFind(var Item: Record Item; Which: Text[30]; ShowItemsWithActivity: Boolean): Boolean
    var
        i: Integer;
        EOF: Boolean;
        Direction: Integer;
    begin
        if (not ShowItemsWithActivity) and (not ShowApprovedOnly) then // P8001230
            exit(Item.Find(Which));

        for i := 1 to StrLen(Which) do begin
            EOF := false;
            case Which[i] of
                '-', '>':
                    Direction := 1;
                '+', '<':
                    Direction := -1;
                '=':
                    Direction := 0;
            end;
            EOF := not Item.Find(CopyStr(Which, i, 1));
            while (not EOF) and (not ShowItem(Item, ShowItemsWithActivity)) do // P8001230
                EOF := Item.Next(Direction) = 0;
            if not EOF then
                exit(true);
        end;
    end;

    procedure ItemNext(var Item: Record Item; Steps: Integer; ShowItemsWithActivity: Boolean): Integer
    var
        NextRec: Record Item;
        EOF: Boolean;
        Direction: Integer;
        NoSteps: Integer;
        StepsTaken: Integer;
    begin
        if (not ShowItemsWithActivity) and (not ShowApprovedOnly) then // P8001230
            exit(Item.Next(Steps));

        NextRec := Item;
        Direction := 1;
        if Steps < 0 then
            Direction := -1;
        NoSteps := Direction * Steps;
        while (StepsTaken < NoSteps) and (not EOF) do begin
            EOF := Item.Next(Direction) = 0;
            if (not EOF) and ShowItem(Item, ShowItemsWithActivity) then begin // P8001230
                NextRec := Item;
                StepsTaken += 1;
            end;
        end;
        Item := NextRec;
        exit(Direction * StepsTaken);
    end;

    local procedure ShowItem(var Item: Record Item; ShowItemsWithActivity: Boolean) Show: Boolean
    begin
        // P8001230 - add parameter ShowItemsWithActivity
        // P8001230
        case true of
            ShowItemsWithActivity and ShowApprovedOnly:
                Show := ItemHasActivity(Item) and ItemIsApproved(Item);
            ShowItemsWithActivity and (not ShowApprovedOnly):
                Show := ItemHasActivity(Item);
            (not ShowItemsWithActivity) and ShowApprovedOnly:
                Show := ItemIsApproved(Item);
        end;

        if Show then
            exit;
        // P8001230

        TempItemQty.SetRange("Item No.", Item."No.");
        TempItemQty.SetRange(Quantity);
        Show := TempItemQty.Find('-'); // P8001230
    end;

    local procedure ItemHasActivity(Item: Record Item): Boolean
    begin
        // P8001230
        HistoryItem."No." := Item."No.";
        exit(HistoryItem.Mark);
    end;

    local procedure ItemIsApproved(Item: Record Item): Boolean
    begin
        // P8001230
        if not ApprovedItem.Get(Item."No.") then begin
            ApprovedItem := Item;
            if ApprovedItem.VendorApprovalRequired then begin
                if ApprovedItem.VendorApproved(BuyFromVendor."No.") then
                    ApprovedItem."Vendor Approval Required" := ApprovedItem."Vendor Approval Required"::Yes
                else
                    ApprovedItem."Vendor Approval Required" := ApprovedItem."Vendor Approval Required"::No;
            end else
                ApprovedItem."Vendor Approval Required" := ApprovedItem."Vendor Approval Required"::Yes;
            ApprovedItem.Insert;
        end;

        exit(ApprovedItem."Vendor Approval Required" = ApprovedItem."Vendor Approval Required"::Yes);
    end;

    procedure GetFormLocationCode(var Item: Record Item): Code[10]
    begin
        exit(Item.GetRangeMin("Location Filter"));
    end;

    procedure GetQtyToOrder(var Item: Record Item; var QtyToOrder: Decimal; var VariantToOrder: Code[10]; var OrderUOM: Code[10]; var DefOrderUOM: Code[10]; var UnitCost: Decimal)
    begin
        TempItemQty.SetRange("Item No.", Item."No.");
        TempItemQty.SetRange(Quantity);
        if not TempItemQty.Find('-') then
            TempItemQty.Init;
        QtyToOrder := TempItemQty.Quantity;
        VariantToOrder := TempItemQty."Variant Code";
        OrderUOM := TempItemQty."Unit of Measure Code";
        DefOrderUOM := GetDefOrderUOM(Item);
        if (OrderUOM = '') then
            OrderUOM := DefOrderUOM;
        UnitCost := TempItemQty."Remaining Quantity";
    end;

    procedure GetVariant(ItemNo: Code[20]): Code[10]
    begin
        // P8001004
        TempItemQty.SetRange("Item No.", ItemNo);
        TempItemQty.SetRange(Quantity);
        if not TempItemQty.Find('-') then
            TempItemQty.Init;
        exit(TempItemQty."Variant Code");
    end;

    local procedure GetDefOrderUOM(var Item: Record Item): Code[10]
    begin
        SearchItemLedgEntry.SetRange("Item No.", Item."No.");
        SearchItemLedgEntry.SetRange("Posting Date");
        SearchItemLedgEntry.SetRange(Positive);
        if SearchItemLedgEntry.Find('+') then
            exit(SearchItemLedgEntry."Unit of Measure Code");
        if (Item."Purch. Unit of Measure" <> '') then
            exit(Item."Purch. Unit of Measure");
        exit(Item."Base Unit of Measure");
    end;

    procedure GetQtyOrdered(var Item: Record Item): Decimal
    begin
        SearchItemLedgEntry.SetRange("Item No.", Item."No.");
        // Item.COPYFILTER("Date Filter", SearchItemLedgEntry."Posting Date"); // P8000879 Removed
        // P8000879 Added
        if StartingDate <> 0D then
            SearchItemLedgEntry.SetRange("Posting Date", StartingDate, EndingDate)
        else
            SearchItemLedgEntry.SetRange("Posting Date");
        // P8000879 Added

        SearchItemLedgEntry.CalcSums(Quantity);
        exit(SearchItemLedgEntry.Quantity);
    end;

    procedure GetLastTransactionInfo(var Item: Record Item; var LastDocNo: Code[20]; var LastDate: Date; var LastQty: Decimal; var LastUOM: Code[10]; var LastUnitCost: Decimal; var LastAmount: Decimal)
    begin
        // P8000348A - add parameter for LastAmount
        SearchItemLedgEntry.SetRange("Item No.", Item."No.");
        SearchItemLedgEntry.SetRange("Posting Date");
        SearchItemLedgEntry.SetRange(Positive);
        if not SearchItemLedgEntry.Find('+') then
            SearchItemLedgEntry.Init;
        LastDocNo := SearchItemLedgEntry."Document No.";
        LastDate := SearchItemLedgEntry."Posting Date";
        LastQty := SearchItemLedgEntry.Quantity;                    // P8000368A
        if SearchItemLedgEntry."Qty. per Unit of Measure" <> 0 then // P8000368A
            LastQty := Round(LastQty / SearchItemLedgEntry."Qty. per Unit of Measure", 0.00001); // P8000348A, P8000368A
        LastUOM := SearchItemLedgEntry."Unit of Measure Code";
        // P8000348A
        if LastQty = 0 then begin
            LastAmount := 0;
            LastUnitCost := 0;
        end else begin
            SearchItemLedgEntry.CalcFields("Purchase Amount (Expected)", "Purchase Amount (Actual)");
            LastAmount := SearchItemLedgEntry."Purchase Amount (Actual)" + SearchItemLedgEntry."Purchase Amount (Expected)";
            LastUnitCost := LastAmount / SearchItemLedgEntry.GetCostingQty;
        end;

        if not Item.CostInAlternateUnits then
            LastUnitCost := Round(LastUnitCost * SearchItemLedgEntry."Qty. per Unit of Measure",
              GLSetup."Unit-Amount Rounding Precision");
        // P8000348A
    end;

    procedure SetQtyToOrder(var Item: Record Item; QtyToOrder: Decimal; VariantToOrder: Code[10]; OrderUOM: Code[10]; DefOrderUOM: Code[10]; UnitCost: Decimal)
    begin
        TempItemQty.SetRange("Item No.", Item."No.");
        TempItemQty.SetRange(Quantity);
        if TempItemQty.Find('-') then begin
            TempItemQty.Quantity := QtyToOrder;
            TempItemQty."Variant Code" := VariantToOrder;
            TempItemQty."Unit of Measure Code" := OrderUOM;
            TempItemQty."Remaining Quantity" := UnitCost;
            if (QtyToOrder = 0) and (OrderUOM = DefOrderUOM) then
                TempItemQty.Delete
            else
                TempItemQty.Modify;
        end else begin
            TempItemQty.Init;
            if (QtyToOrder <> 0) or (OrderUOM <> DefOrderUOM) or (VariantToOrder <> '') then begin
                TempItemQtyEntryNo := TempItemQtyEntryNo + 1;
                TempItemQty."Entry No." := TempItemQtyEntryNo;
                TempItemQty."Item No." := Item."No.";
                TempItemQty.Quantity := QtyToOrder;
                TempItemQty."Variant Code" := VariantToOrder;
                TempItemQty."Unit of Measure Code" := OrderUOM;
                TempItemQty."Remaining Quantity" := UnitCost;
                TempItemQty.Insert;
            end;
        end;
    end;

    procedure ValidateUOM(var Item: Record Item; var OrderUOM: Code[10]; VariantToOrder: Code[10]; QtyToOrder: Decimal; var UnitCost: Decimal)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        PurchLine: Record "Purchase Line";
    begin
        ItemUnitOfMeasure."Item No." := Item."No.";
        ItemUnitOfMeasure.Code := OrderUOM;
        if not ItemUnitOfMeasure.Find('=>') then
            ItemUnitOfMeasure.Get(Item."No.", OrderUOM);
        if (ItemUnitOfMeasure."Item No." <> Item."No.") or
           (CopyStr(ItemUnitOfMeasure.Code, 1, StrLen(OrderUOM)) <> OrderUOM)
        then
            ItemUnitOfMeasure.Get(Item."No.", OrderUOM);
        OrderUOM := ItemUnitOfMeasure.Code;

        UnitCost := GetDirectUnitCost(Item."No.", QtyToOrder, VariantToOrder, OrderUOM); // P8000356A
    end;

    procedure LookupUOM(var Item: Record Item; var Text: Text[30]): Boolean
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        ItemUnitOfMeasure.SetRange("Item No.", Item."No.");
        ItemUnitOfMeasure."Item No." := Item."No.";
        ItemUnitOfMeasure.Code := Text;
        if (PAGE.RunModal(0, ItemUnitOfMeasure) <> ACTION::LookupOK) then
            exit(false);
        Text := ItemUnitOfMeasure.Code;
        exit(true);
    end;

    procedure ValidateVariant(var Item: Record Item; OrderUOM: Code[10]; var VariantToOrder: Code[10]; QtyToOrder: Decimal; var UnitCost: Decimal)
    var
        ItemVariant: Record "Item Variant";
        PurchLine: Record "Purchase Line";
    begin
        if VariantToOrder <> '' then begin
            ItemVariant."Item No." := Item."No.";
            ItemVariant.Code := VariantToOrder;
            if not ItemVariant.Find('=>') then
                ItemVariant.Get(Item."No.", VariantToOrder);
            if (ItemVariant."Item No." <> Item."No.") or
               (CopyStr(ItemVariant.Code, 1, StrLen(VariantToOrder)) <> VariantToOrder)
            then
                ItemVariant.Get(Item."No.", VariantToOrder);
            VariantToOrder := ItemVariant.Code;
        end;
        CheckApprovedVariant(Item, VariantToOrder); // P8001230

        UnitCost := GetDirectUnitCost(Item."No.", QtyToOrder, VariantToOrder, OrderUOM); // P8000356A
    end;

    local procedure CheckApprovedVariant(var Item: Record Item; VariantToOrder: Code[10])
    var
        ItemVendor: Record "Item Vendor";
    begin
        // P8001230
        if ShowApprovedOnly then
            if Item.VendorApprovalRequired then begin
                ItemVendor.SetRange("Vendor No.", BuyFromVendor."No.");
                ItemVendor.SetRange("Item No.", Item."No.");
                ItemVendor.SetRange("Variant Code", VariantToOrder);
                ItemVendor.SetRange(Approved, true);
                if ItemVendor.IsEmpty then
                    Error(Text005, VariantToOrder, BuyFromVendor."No.");
            end;
    end;

    procedure LookupVariant(var Item: Record Item; var Text: Text[30]): Boolean
    var
        ItemVariant: Record "Item Variant";
    begin
        ItemVariant.SetRange("Item No.", Item."No.");
        ItemVariant."Item No." := Item."No.";
        ItemVariant.Code := Text;
        if (PAGE.RunModal(0, ItemVariant) <> ACTION::LookupOK) then
            exit(false);
        Text := ItemVariant.Code;
        exit(true);
    end;

    procedure ValidateQty(var Item: Record Item; OrderUOM: Code[10]; VariantToOrder: Code[10]; var QtyToOrder: Decimal; var UnitCost: Decimal)
    var
        PurchLine: Record "Purchase Line";
    begin
        if VariantToOrder = '' then          // P8001230
            CheckApprovedVariant(Item, VariantToOrder); // P8001230
        UnitCost := GetDirectUnitCost(Item."No.", QtyToOrder, VariantToOrder, OrderUOM); // P8000356A
    end;

    procedure GetDirectUnitCost(ItemNo: Code[20]; Qty: Decimal; VariantToOrder: Code[10]; UOM: Code[10]): Decimal
    var
        PurchLine: Record "Purchase Line";
        ItemUOM: Record "Item Unit of Measure";
        UOMMgt: Codeunit "Unit of Measure Management";
        PurchPriceCalc: Codeunit "Purch. Price Calc. Mgt.";
    begin
        // P8000356A - remove parameter for CalledByFieldNo
        if Qty = 0 then
            exit;

        PurchLine."Document Type" := PurchHeader."Document Type";
        PurchLine."Document No." := PurchHeader."No.";
        PurchLine."Buy-from Vendor No." := PurchHeader."Buy-from Vendor No.";
        PurchLine."Pay-to Vendor No." := PurchHeader."Pay-to Vendor No.";
        PurchLine.Type := PurchLine.Type::Item;
        PurchLine."No." := ItemNo;
        PurchLine.Quantity := Qty;
        PurchLine."Unit of Measure Code" := UOM;
        PurchLine."Variant Code" := VariantToOrder;
        ItemUOM.Get(ItemNo, UOM);
        PurchLine."Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
        PurchLine."Quantity (Base)" := UOMMgt.CalcBaseQty(ItemNo, UOM, Qty); // P800133109
        PurchPriceCalc.FindPurchLinePrice(PurchHeader, PurchLine, 0); // P8000356A
        exit(PurchLine."Direct Unit Cost");
    end;

    procedure QtyToOrderExists(): Boolean
    begin
        TempItemQty.SetRange("Item No.");
        TempItemQty.SetFilter(Quantity, '<>0');
        exit(TempItemQty.Find('-'));
    end;

    procedure ShowQtyOrdered(var Item: Record Item)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.Copy(SearchItemLedgEntry);
        ItemLedgEntry.SetRange("Item No.", Item."No.");
        // Item.COPYFILTER("Date Filter", ItemLedgEntry."Posting Date"); // P8000879 Removed
        // P8000879 Added
        if StartingDate <> 0D then
            ItemLedgEntry.SetRange("Posting Date", StartingDate, EndingDate)
        else
            ItemLedgEntry.SetRange("Posting Date");
        // P8000879 Added

        ItemLedgEntry.Init;
        PAGE.RunModal(0, ItemLedgEntry);
    end;

    procedure ShowVendorCard(var Item: Record Item)
    var
        Vendor2: Record Vendor;
    begin
        Vendor2.SetRange("No.", BuyFromVendor."No."); // P8000384A
        Item.CopyFilter("Date Filter", Vendor2."Date Filter");
        Item.CopyFilter("Global Dimension 1 Filter", Vendor2."Global Dimension 1 Filter");
        Item.CopyFilter("Global Dimension 2 Filter", Vendor2."Global Dimension 2 Filter");
        // P8000791
        if IsServiceTier then
            if (Vendor2.FindFirst()) then;
        // P8000791
        PAGE.RunModal(PAGE::"Vendor Card", Vendor2);
    end;

    procedure ShowVendorLedgEntries()
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgEntry.SetRange("Vendor No.", PayToVendor."No."); // P8000384A
        PAGE.RunModal(0, VendLedgEntry);
    end;

    procedure ShowVendorOrders()
    var
        PurchLine: Record "Purchase Line";
    begin
        PurchLine.SetCurrentKey("Document Type", "Buy-from Vendor No.", Type);
        PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
        PurchLine.SetRange("Buy-from Vendor No.", BuyFromVendor."No."); // P8000384A
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        PurchLine.SetFilter("Outstanding Quantity", '>0');
        PAGE.RunModal(0, PurchLine);
    end;

    procedure ShowVendorItemLedgEntries()
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.Copy(SearchItemLedgEntry);
        ItemLedgEntry.SetRange("Item No.");
        ItemLedgEntry.SetRange("Posting Date");
        ItemLedgEntry.Init;
        PAGE.RunModal(0, ItemLedgEntry);
    end;

    procedure GetItemsToCopy(var TempItemQty2: Record "Item Ledger Entry" temporary)
    begin
        TempItemQty2.Reset;
        TempItemQty2.SetCurrentKey("Item No.");
        TempItemQty2.DeleteAll;

        TempItemQty.SetRange("Item No.");
        TempItemQty.SetFilter(Quantity, '<>0');
        if TempItemQty.Find('-') then
            repeat
                TempItemQty2 := TempItemQty;
                TempItemQty2.Insert;
            until (TempItemQty.Next = 0);
    end;

    procedure SetStartEndDates(HistoryPeriod: DateFormula; ShowItemsWithActivity: Boolean)
    begin
        // P8000879
        EndingDate := WorkDate;
        if ShowItemsWithActivity and (Format(HistoryPeriod) <> '') then
            StartingDate := CalcDate('-' + Format(HistoryPeriod), EndingDate)
        else
            StartingDate := 0D;

        HistoryItemListInit; // P8000999
    end;

    procedure CalledFromOrderGuide(): Boolean
    begin
        // P8001004
        exit(PurchHeader."No." <> '');
    end;
}

