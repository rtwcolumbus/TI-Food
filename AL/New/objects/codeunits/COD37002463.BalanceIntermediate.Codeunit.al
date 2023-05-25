codeunit 37002463 "Balance Intermediate"
{
    // PR3.70.05
    // P8000064A, Myers Nissi, Jack Reynolds, 12 JUL 04
    //   TableNo - Item Journal Line
    //   OnRun - call OutputToConsumption or ConsumptionToOutput based on entry type
    //   OutputToConsumption - allocates output of intermediate on batch order to consumption on sub orders
    //   ConsumptionToOutput - sets output of intermediate on batch order from conumsumption on sub orders
    //   UpdateDetailToBalance - updates temp item ledger containing lot detail of intermediate quantity to balance
    //   DeleteReservationEntries - deletes all reservations entries associated with item journal line
    //   CreateReservationEntry - create new reservation entry for item journal line
    //   DeleteAltQtyLine - deletes all alternate quantity lines for item journal line
    //   CreateltQtyLine - create new alternate quantity line for item journal line
    // 
    // PR3.70.06
    // P8000074A, Myers Nissi, Jack Reynolds, 21 JUL 04
    //   ConsumptionToOutput - test result of FIND on DetailToBalance
    // 
    // P8000092A, Myers Nissi, Jack Reynolds, 20 AUG 04
    //   OutputToConsumption - create item tracking entries while component quantity <> 0 (as opposed to > 0)
    //   ConsumptionToOutput - don't exit if total consumption is less than posted consumption
    // 
    // P8000112A, Myers Nissi, Jack Reynolds, 10 SEP 04
    //   Generate error messages instead of exiting without a message
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Changes to Item Ledger keys
    // 
    // PR4.00.03
    // P8000325A, VerticalSoft, Jack Reynolds, 01 MAY 06
    //   CreateReservationEntry - modify call to CreateReservEntry for new parameter for expiration date
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 12 JUN 07
    //   Eliminate parameter for Expiration Date
    // 
    // PRW16.00.04
    // P8000897, VerticalSoft, Jack Reynolds, 22 JAN 11
    //   Fix spelling mistake
    // 
    // P8000900, Columbus IT, Jack Reynolds, 14 FEB 11
    //   Modify for muli-line batch orders
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10.03
    // P8001330, Columbus IT, Jack Reynolds, 19 JUN 14
    //   Fix problems with mulitple intermediate items to balance
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    TableNo = "Item Journal Line";

    trigger OnRun()
    begin
        case "Entry Type" of
            "Entry Type"::Output:
                OutputToConsumption(Rec);
            "Entry Type"::Consumption:
                ConsumptionToOutput(Rec);
        end;
    end;

    var
        Text001: Label 'Item tracking not specified for %1 %2.';
        Text002: Label 'Alternate quantities not specified for %1 %2.';
        Text003: Label '%1 %2 for %3 %4, %5 %6 does not equal quantity required.';
        ProdOrder: Record "Production Order";
        Item: Record Item;
        BalanceBuffer: array[3] of Record "Intermediate Balancing Buffer" temporary;
        ProcessSetup: Record "Process Setup";
        ProdDate: Date;
        LineCount: array[2] of Integer;
        Text101: Label 'There are no sub-orders.';
        Text102: Label '%1 %2 for %3 %4 is not enough for quantity required.';
        Text103: Label 'Unable to assign %1 %2 to the %3.';

    procedure OutputToConsumption(ItemJnlLine: Record "Item Journal Line")
    var
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        Item: Record Item;
        ItemLedger: Record "Item Ledger Entry";
        ResEntry: Record "Reservation Entry";
        AltQtyLine: Record "Alternate Quantity Line";
        DetailToBalance: Record "Item Ledger Entry" temporary;
        ItemJnlLine2: Record "Item Journal Line";
        ProcessSetup: Record "Process Setup";
        QtyToBalance: Decimal;
        RemainingQty: Decimal;
        RemainingQtyAlt: Decimal;
        QtyTracked: Decimal;
        QtyAlt: Decimal;
        QtyAltBase: Decimal;
        Qty: Decimal;
        QtyExpected: Decimal;
        LineQtyExpected: Decimal;
        ComponentQty: Decimal;
        LotQty: Decimal;
        AltQtyRounding: Decimal;
    begin
        with ItemJnlLine do begin
            if not ProdOrderLine.Get(ProdOrderLine.Status::Released, "Order No.", "Order Line No.") then // P8001132
                exit;
            if ProdOrderLine."By-Product" then
                exit;
            Item.Get(ProdOrderLine."Item No.");
            Item.GetItemUOMRndgPrecision(Item."Alternate Unit of Measure", true);
            AltQtyRounding := Item."Rounding Precision";
            Item.GetItemUOMRndgPrecision(Item."Base Unit of Measure", true);

            UpdateDetailToBalance('', 0, 0, 0, 0, 0, 0, DetailToBalance);

            ItemLedger.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type"); // P8000267B, P8001132
            ItemLedger.SetRange("Order Type", ItemLedger."Order Type"::Production); // P8001132
            ItemLedger.SetRange("Order No.", "Order No.");           // P8001132
            ItemLedger.SetRange("Order Line No.", "Order Line No."); // P8001132
            ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::Output);
            if ItemLedger.Find('-') then
                repeat
                    UpdateDetailToBalance(ItemLedger."Lot No.", ItemLedger.Quantity, ItemLedger."Remaining Quantity",
                      ItemLedger."Quantity (Alt.)", ItemLedger."Remaining Quantity (Alt.)", 0, 0, DetailToBalance);
                until ItemLedger.Next = 0;

            ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
              "Source Prod. Order Line", "Source Ref. No.");
            ResEntry.SetRange("Source Type", DATABASE::"Item Journal Line");
            ResEntry.SetRange("Source Subtype", ItemJnlLine."Entry Type");
            ResEntry.SetRange("Source ID", ItemJnlLine."Journal Template Name");
            ResEntry.SetRange("Source Batch Name", ItemJnlLine."Journal Batch Name");
            if Item."Item Tracking Code" <> '' then begin
                ResEntry.SetRange("Source Ref. No.", ItemJnlLine."Line No.");
                if ResEntry.Find('-') then
                    repeat
                        UpdateDetailToBalance(ResEntry."Lot No.", ResEntry."Quantity (Base)", ResEntry."Quantity (Base)",
                          ResEntry."Quantity (Alt.)", ResEntry."Quantity (Alt.)", 0, 0, DetailToBalance);
                        QtyTracked += ResEntry."Quantity (Base)";
                    until ResEntry.Next = 0;
            end else
                UpdateDetailToBalance('', ItemJnlLine."Quantity (Base)", ItemJnlLine."Quantity (Base)", 0, 0, 0, 0,
                  DetailToBalance);
            if Item."Catch Alternate Qtys." then begin
                AltQtyLine.SetRange("Alt. Qty. Transaction No.", ItemJnlLine."Alt. Qty. Transaction No.");
                if AltQtyLine.Find('-') then
                    repeat
                        UpdateDetailToBalance(AltQtyLine."Lot No.", 0, 0, AltQtyLine."Quantity (Alt.)", AltQtyLine."Quantity (Alt.)", 0, 0,
                          DetailToBalance);
                        QtyAlt += AltQtyLine."Quantity (Alt.)";
                        QtyAltBase += AltQtyLine."Quantity (Base)";
                    until AltQtyLine.Next = 0;
            end;
            Qty += ItemJnlLine."Quantity (Base)";

            ItemJnlLine2.SetCurrentKey("Entry Type", "Order No."); // P8001132
            ItemJnlLine2.SetRange("Entry Type", ItemJnlLine2."Entry Type"::Output);
            ItemJnlLine2.SetRange("Journal Template Name", "Journal Template Name");
            ItemJnlLine2.SetRange("Journal Batch Name", "Journal Batch Name");
            ItemJnlLine2.SetRange("Order Type", ItemJnlLine2."Order Type"::Production); // P8001132
            ItemJnlLine2.SetRange("Order No.", "Order No.");           // P8001132
            ItemJnlLine2.SetRange("Order Line No.", "Order Line No."); // P8001132
            ItemJnlLine2.SetFilter("Line No.", '<>%1', "Line No.");
            if ItemJnlLine2.Find('-') then
                repeat
                    if Item."Item Tracking Code" <> '' then begin
                        ResEntry.SetRange("Source Ref. No.", ItemJnlLine2."Line No.");
                        if ResEntry.Find('-') then
                            repeat
                                UpdateDetailToBalance(ResEntry."Lot No.", ResEntry."Quantity (Base)", ResEntry."Quantity (Base)",
                                  ResEntry."Quantity (Alt.)", ResEntry."Quantity (Alt.)", 0, 0, DetailToBalance);
                                QtyTracked += ResEntry."Quantity (Base)";
                            until ResEntry.Next = 0;
                    end else
                        UpdateDetailToBalance('', ItemJnlLine2."Quantity (Base)", ItemJnlLine2."Quantity (Base)", 0, 0, 0, 0,
                          DetailToBalance);
                    if Item."Catch Alternate Qtys." then begin
                        AltQtyLine.SetRange("Alt. Qty. Transaction No.", ItemJnlLine2."Alt. Qty. Transaction No.");
                        if AltQtyLine.Find('-') then
                            repeat
                                UpdateDetailToBalance(AltQtyLine."Lot No.", 0, 0, AltQtyLine."Quantity (Alt.)", AltQtyLine."Quantity (Alt.)", 0, 0,
                                  DetailToBalance);
                                QtyAlt += AltQtyLine."Quantity (Alt.)";
                                QtyAltBase += AltQtyLine."Quantity (Base)";
                            until AltQtyLine.Next = 0;
                    end;
                    Qty += ItemJnlLine2."Quantity (Base)";
                until ItemJnlLine2.Next = 0;

            if (Item."Item Tracking Code" <> '') and (Qty <> QtyTracked) then
                Error(Text001, ItemJnlLine.FieldCaption("Item No."), ItemJnlLine."Item No."); // P8000112A
            if Item."Catch Alternate Qtys." and (Qty <> QtyAltBase) then
                Error(Text002, ItemJnlLine.FieldCaption("Item No."), ItemJnlLine."Item No."); // P8000112A

            ProcessSetup.Get;
            ProdOrder.SetCurrentKey(Status, "Batch Prod. Order No.");
            ProdOrder.SetRange(Status, ProdOrder.Status::Released);
            ProdOrder.SetRange("Batch Prod. Order No.", "Order No."); // P8001132
            ProdOrder.SetRange(Suborder, true);
            ProdOrderComp.SetRange(Status, ProdOrderComp.Status::Released);
            ProdOrderComp.SetRange("Item No.", "Item No.");
            ItemLedger.Reset;
            ItemLedger.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type", "Prod. Order Comp. Line No."); // P8000267B, P8001132
            ItemLedger.SetRange("Order Type", ItemLedger."Order Type"::Production); // P8001132
            ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::Consumption);
            ItemJnlLine2.Reset;
            ItemJnlLine2.SetRange("Journal Template Name", ProcessSetup."Batch Consumption Template");
            ItemJnlLine2.SetRange("Journal Batch Name", ProcessSetup."Batch Consumption Batch");
            ItemJnlLine2.SetRange("Order Type", ItemJnlLine2."Order Type"::Production); // P8001132
            ItemJnlLine2.SetRange("Entry Type", ItemJnlLine2."Entry Type"::Consumption);
            ItemJnlLine2.SetFilter("Expected Quantity", '<>0');
            if ProdOrder.Find('-') then
                repeat
                    ProdOrderComp.SetRange("Prod. Order No.", ProdOrder."No.");
                    if ProdOrderComp.Find('-') then
                        repeat
                            ItemLedger.SetRange("Order No.", ProdOrderComp."Prod. Order No.");           // P8001132
                            ItemLedger.SetRange("Order Line No.", ProdOrderComp."Prod. Order Line No."); // P8001132
                            ItemLedger.SetRange("Prod. Order Comp. Line No.", ProdOrderComp."Line No.");
                            if ItemLedger.Find('-') then
                                repeat
                                    UpdateDetailToBalance(ItemLedger."Lot No.", 0, 0, 0, 0, ItemLedger.Quantity, 0,
                                      DetailToBalance);
                                until ItemLedger.Next = 0;
                            ItemJnlLine2.SetRange("Order No.", ProdOrderComp."Prod. Order No.");           // P8001132
                            ItemJnlLine2.SetRange("Order Line No.", ProdOrderComp."Prod. Order Line No."); // P8001132
                            ItemJnlLine2.SetRange("Prod. Order Comp. Line No.", ProdOrderComp."Line No.");
                            if ItemJnlLine2.Find('-') then
                                repeat
                                    QtyExpected += Round(
                                      ItemJnlLine2."Expected Quantity" * ItemJnlLine2."Qty. per Unit of Measure" -
                                      ItemJnlLine2.PostedQuantity, 0.00001);
                                until ItemJnlLine2.Next = 0;
                        until ProdOrderComp.Next = 0;
                until ProdOrder.Next = 0;

            DetailToBalance.Reset;
            DetailToBalance.Find('-');
            repeat
                if (DetailToBalance.Quantity + DetailToBalance."Invoiced Quantity") <> DetailToBalance."Remaining Quantity" then
                    Error(Text003, DetailToBalance.TableCaption, DetailToBalance.FieldCaption("Remaining Quantity"), // P8000112A
                      DetailToBalance.FieldCaption("Item No."), ItemJnlLine."Item No.",                         // P8000112A
                      DetailToBalance.FieldCaption("Lot No."), DetailToBalance."Lot No.");                          // P8000112A
                QtyToBalance += DetailToBalance."Remaining Quantity";
                RemainingQty += DetailToBalance."Remaining Quantity";
                RemainingQtyAlt += DetailToBalance."Remaining Quantity (Alt.)";
            until DetailToBalance.Next = 0;

            DetailToBalance.SetFilter("Lot No.", '<>%1', '');
            DetailToBalance.SetFilter("Remaining Quantity", '<>0');
            if ProdOrder.Find('-') then
                repeat
                    ProdOrderComp.SetRange("Prod. Order No.", ProdOrder."No.");
                    if ProdOrderComp.Find('-') then
                        repeat
                            ItemJnlLine2.SetRange("Order No.", ProdOrderComp."Prod. Order No.");           // P8001132
                            ItemJnlLine2.SetRange("Order Line No.", ProdOrderComp."Prod. Order Line No."); // P8001132
                            ItemJnlLine2.SetRange("Prod. Order Comp. Line No.", ProdOrderComp."Line No.");
                            if ItemJnlLine2.Find('-') then
                                repeat
                                    if Item."Item Tracking Code" <> '' then
                                        DeleteReservationEntries(ItemJnlLine2);
                                    if Item."Catch Alternate Qtys." then begin
                                        DeleteAltQtyLines(ItemJnlLine2);
                                        ItemJnlLine2."Quantity (Alt.)" := 0;
                                    end;
                                    LineQtyExpected := Round(ItemJnlLine2."Expected Quantity" * ItemJnlLine2."Qty. per Unit of Measure" -
                                      ItemJnlLine2.PostedQuantity, 0.00001);
                                    if QtyExpected <> 0 then
                                        ComponentQty := Round(LineQtyExpected * QtyToBalance / QtyExpected, Item."Rounding Precision")
                                    else
                                        ComponentQty := 0;
                                    QtyToBalance -= ComponentQty;
                                    QtyExpected -= LineQtyExpected;
                                    ItemJnlLine2.Validate(Quantity, Round(ComponentQty / ItemJnlLine2."Qty. per Unit of Measure", 0.00001));
                                    QtyToBalance += ComponentQty - ItemJnlLine2."Quantity (Base)";
                                    if Item."Item Tracking Code" <> '' then begin
                                        while ComponentQty <> 0 do // P8000092A
                                            if DetailToBalance.Find('-') then begin
                                                if DetailToBalance."Remaining Quantity" <= ComponentQty then
                                                    LotQty := DetailToBalance."Remaining Quantity"
                                                else
                                                    LotQty := ComponentQty;
                                                if Item."Catch Alternate Qtys." then
                                                    QtyAlt := Round(
                                                      DetailToBalance."Remaining Quantity (Alt.)" * LotQty / DetailToBalance."Remaining Quantity",
                                                      AltQtyRounding);
                                                CreateReservationEntry(ItemJnlLine2, DetailToBalance."Lot No.", 0D,
                                                  ItemJnlLine."Posting Date", LotQty, -QtyAlt);
                                                CreateAltQtyLine(ItemJnlLine2, DetailToBalance."Lot No.", LotQty, QtyAlt);
                                                ComponentQty -= LotQty;
                                                DetailToBalance."Remaining Quantity" -= LotQty;
                                                DetailToBalance."Remaining Quantity (Alt.)" -= QtyAlt;
                                                DetailToBalance.Modify;
                                            end else
                                                ComponentQty := 0;
                                        ItemJnlLine2.GetLotNo;
                                    end else
                                        if Item."Catch Alternate Qtys." then begin
                                            QtyAlt := Round(RemainingQtyAlt * ComponentQty / RemainingQty, AltQtyRounding);
                                            CreateAltQtyLine(ItemJnlLine2, '', ComponentQty, QtyAlt);
                                            RemainingQty -= ComponentQty;
                                            RemainingQtyAlt -= QtyAlt;
                                        end;
                                    ItemJnlLine2.Modify;
                                until ItemJnlLine2.Next = 0;
                        until ProdOrderComp.Next = 0;
                until ProdOrder.Next = 0;
        end;
    end;

    procedure ConsumptionToOutput(ItemJnlLine: Record "Item Journal Line")
    var
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        Item: Record Item;
        ItemLedger: Record "Item Ledger Entry";
        ResEntry: Record "Reservation Entry";
        AltQtyLine: Record "Alternate Quantity Line";
        ItemJnlLine2: Record "Item Journal Line";
        DetailToBalance: Record "Item Ledger Entry" temporary;
        ProcessSetup: Record "Process Setup";
        BatchOrderNo: Code[20];
        BatchOrderLineNo: Integer;
        AltQtyRounding: Decimal;
        Qty: Decimal;
        QtyAlt: Decimal;
        DeleteItemJnl: Boolean;
    begin
        with ItemJnlLine do begin
            if not ConsumedIntermediate(BatchOrderNo, BatchOrderLineNo) then
                exit;

            Item.Get("Item No.");
            Item.GetItemUOMRndgPrecision(Item."Alternate Unit of Measure", true);
            AltQtyRounding := Item."Rounding Precision";
            Item.GetItemUOMRndgPrecision(ItemJnlLine."Unit of Measure Code", true);

            UpdateDetailToBalance('', 0, 0, 0, 0, 0, 0, DetailToBalance);

            ProdOrder.SetCurrentKey(Status, "Batch Prod. Order No.");
            ProdOrder.SetRange(Status, ProdOrder.Status::Released);
            ProdOrder.SetRange("Batch Prod. Order No.", BatchOrderNo);
            ProdOrder.SetRange(Suborder, true);
            ProdOrderComp.SetCurrentKey(Status, "Prod. Order No.", "Prod. Order Line No.", "Item No.");
            ProdOrderComp.SetRange(Status, ProdOrderComp.Status::Released);
            ProdOrderComp.SetRange("Item No.", "Item No.");
            ItemLedger.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type", "Prod. Order Comp. Line No."); // P8000267B, P8001132
            ItemLedger.SetRange("Order Type", ItemLedger."Order Type"::Production); // P8001132
            ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::Consumption);
            ItemJnlLine2.SetCurrentKey("Entry Type", "Order No."); // P8001132
            ItemJnlLine2.SetRange("Entry Type", ItemJnlLine2."Entry Type"::Consumption);
            ItemJnlLine2.SetRange("Journal Template Name", "Journal Template Name");
            ItemJnlLine2.SetRange("Journal Batch Name", "Journal Batch Name");
            ItemJnlLine2.SetRange("Order Type", ItemJnlLine2."Order Type"::Production); // P8001132
            ItemJnlLine2.SetFilter("Line No.", '<>%1', "Line No.");
            ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
              "Source Prod. Order Line", "Source Ref. No.");
            ResEntry.SetRange("Source Type", DATABASE::"Item Journal Line");
            ResEntry.SetRange("Source Subtype", ItemJnlLine."Entry Type");
            ResEntry.SetRange("Source ID", ItemJnlLine."Journal Template Name");
            ResEntry.SetRange("Source Batch Name", ItemJnlLine."Journal Batch Name");
            if ProdOrder.Find('-') then
                repeat
                    ProdOrderComp.SetRange("Prod. Order No.", ProdOrder."No.");
                    if ProdOrderComp.Find('-') then
                        repeat
                            ItemLedger.SetRange("Order No.", ProdOrderComp."Prod. Order No.");           // P8001132
                            ItemLedger.SetRange("Order Line No.", ProdOrderComp."Prod. Order Line No."); // P8001132
                            ItemLedger.SetRange("Prod. Order Comp. Line No.", ProdOrderComp."Line No.");
                            if ItemLedger.Find('-') then
                                repeat
                                    UpdateDetailToBalance(ItemLedger."Lot No.", -ItemLedger.Quantity, 0,
                                      -ItemLedger."Quantity (Alt.)", 0, 0, 0, DetailToBalance);
                                until ItemLedger.Next = 0;

                            ItemJnlLine2.SetRange("Order No.", ProdOrderComp."Prod. Order No.");           // P8001132
                            ItemJnlLine2.SetRange("Order Line No.", ProdOrderComp."Prod. Order Line No."); // P8001132
                            ItemJnlLine2.SetRange("Prod. Order Comp. Line No.", ProdOrderComp."Line No.");
                            if ItemJnlLine2.Find('-') then
                                repeat
                                    if Item."Item Tracking Code" <> '' then begin
                                        ResEntry.SetRange("Source Ref. No.", ItemJnlLine2."Line No.");
                                        if ResEntry.Find('-') then
                                            repeat
                                                UpdateDetailToBalance(ResEntry."Lot No.", -ResEntry."Quantity (Base)", 0,
                                                  -ResEntry."Quantity (Alt.)", 0, 0, 0, DetailToBalance);
                                            until ResEntry.Next = 0;
                                    end else
                                        UpdateDetailToBalance('', ItemJnlLine2."Quantity (Base)", 0, 0, 0, 0, 0,
                                          DetailToBalance);
                                    if Item."Catch Alternate Qtys." then begin
                                        AltQtyLine.SetRange("Alt. Qty. Transaction No.", ItemJnlLine2."Alt. Qty. Transaction No.");
                                        if AltQtyLine.Find('-') then
                                            repeat
                                                UpdateDetailToBalance(AltQtyLine."Lot No.", 0, 0, AltQtyLine."Quantity (Alt.)", 0, 0, 0,
                                                  DetailToBalance);
                                            until AltQtyLine.Next = 0;
                                    end;
                                until ItemJnlLine2.Next = 0;
                        until ProdOrderComp.Next = 0;
                until ProdOrder.Next = 0;

            if Item."Item Tracking Code" <> '' then begin
                ResEntry.SetRange("Source Ref. No.", ItemJnlLine."Line No.");
                if ResEntry.Find('-') then
                    repeat
                        UpdateDetailToBalance(ResEntry."Lot No.", -ResEntry."Quantity (Base)", 0,
                          -ResEntry."Quantity (Alt.)", 0, 0, 0, DetailToBalance);
                    until ResEntry.Next = 0;
            end else
                UpdateDetailToBalance('', ItemJnlLine."Quantity (Base)", 0, 0, 0, 0, 0,
                  DetailToBalance);
            if Item."Catch Alternate Qtys." then begin
                AltQtyLine.SetRange("Alt. Qty. Transaction No.", ItemJnlLine."Alt. Qty. Transaction No.");
                if AltQtyLine.Find('-') then
                    repeat
                        UpdateDetailToBalance(AltQtyLine."Lot No.", 0, 0, AltQtyLine."Quantity (Alt.)", 0, 0, 0,
                          DetailToBalance);
                    until AltQtyLine.Next = 0;
            end;

            ProdOrderLine.Get(ProdOrder.Status::Released, BatchOrderNo, BatchOrderLineNo);
            ItemLedger.Reset;
            ItemLedger.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type"); // P8000267B, P8001132
            ItemLedger.SetRange("Order Type", ItemLedger."Order Type"::Production); // P8001132
            ItemLedger.SetRange("Order No.", ProdOrderLine."Prod. Order No.");      // P8001132
            ItemLedger.SetRange("Order Line No.", ProdOrderLine."Line No.");        // P8001132
            ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::Output);
            if ItemLedger.Find('-') then
                repeat
                    UpdateDetailToBalance(ItemLedger."Lot No.", 0, 0, 0, 0, ItemLedger.Quantity, ItemLedger."Quantity (Alt.)",
                      DetailToBalance);
                until ItemLedger.Next = 0;

            DetailToBalance.Reset;
            DetailToBalance.Find('-');
            repeat
                /*P8000092A Begin
                IF (DetailToBalance.Quantity < DetailToBalance."Invoiced Quantity") OR
                  (DetailToBalance."Quantity (Alt.)" < DetailToBalance."Invoiced Quantity (Alt.)")
                THEN
                  EXIT;
                P8000092A End*/
                DetailToBalance."Remaining Quantity" := DetailToBalance.Quantity - DetailToBalance."Invoiced Quantity";
                DetailToBalance."Remaining Quantity (Alt.)" := DetailToBalance."Quantity (Alt.)" - DetailToBalance."Invoiced Quantity (Alt.)";
                DetailToBalance.Modify;
                Qty += DetailToBalance."Remaining Quantity";
                QtyAlt += DetailToBalance."Remaining Quantity (Alt.)";
            until DetailToBalance.Next = 0;

            ProcessSetup.Get;
            ItemJnlLine2.Reset;
            ItemJnlLine2.SetRange("Journal Template Name", ProcessSetup."Batch Output Template");
            ItemJnlLine2.SetRange("Journal Batch Name", ProcessSetup."Batch Output Batch");
            ItemJnlLine2.SetRange("Entry Type", ItemJnlLine2."Entry Type"::Output);
            ItemJnlLine2.SetRange("Order Type", ItemJnlLine2."Order Type"::Production); // P8001132
            ItemJnlLine2.SetRange("Order No.", ProdOrderLine."Prod. Order No.");        // P8001132
            ItemJnlLine2.SetRange("Order Line No.", ProdOrderLine."Line No.");          // P8001132
            ItemJnlLine2.SetFilter("Expected Quantity", '<>0');
            if ItemJnlLine2.Find('-') then
                repeat
                    if Item."Item Tracking Code" <> '' then
                        DeleteReservationEntries(ItemJnlLine2);
                    if Item."Catch Alternate Qtys." then begin
                        DeleteAltQtyLines(ItemJnlLine2);
                        ItemJnlLine2."Quantity (Alt.)" := 0;
                    end;
                    if DeleteItemJnl then
                        ItemJnlLine2.Delete(true)
                    else begin
                        ItemJnlLine2.Validate("Output Quantity", Round(Qty / ItemJnlLine2."Qty. per Unit of Measure",
                          Item."Rounding Precision"));
                        if Item."Item Tracking Code" <> '' then begin
                            DetailToBalance.SetFilter("Remaining Quantity", '<>0');
                            if DetailToBalance.Find('-') then // P8000074A
                                repeat
                                    CreateReservationEntry(ItemJnlLine2, DetailToBalance."Lot No.", 0D, ItemJnlLine."Posting Date",
                                      DetailToBalance."Remaining Quantity", DetailToBalance."Remaining Quantity (Alt.)");
                                    CreateAltQtyLine(ItemJnlLine2, DetailToBalance."Lot No.",
                                      DetailToBalance."Remaining Quantity", DetailToBalance."Remaining Quantity (Alt.)");
                                until DetailToBalance.Next = 0;
                            ItemJnlLine2.GetLotNo;
                        end else
                            if Item."Catch Alternate Qtys." then
                                CreateAltQtyLine(ItemJnlLine2, '', Qty, QtyAlt);
                        ItemJnlLine2.Modify;
                        DeleteItemJnl := true;
                    end;
                until ItemJnlLine2.Next = 0;
        end;

    end;

    procedure UpdateDetailToBalance(LotNo: Code[50]; Qty: Decimal; RemQty: Decimal; AltQty: Decimal; RemAltQty: Decimal; QtyUsed: Decimal; QtyUsedAlt: Decimal; var DetailToBalance: Record "Item Ledger Entry" temporary)
    begin
        DetailToBalance.SetRange("Lot No.", LotNo);
        if not DetailToBalance.Find('-') then begin
            DetailToBalance.SetRange("Lot No.");
            if DetailToBalance.Find('+') then;
            DetailToBalance."Entry No." += 1;
            DetailToBalance.Init;
            DetailToBalance."Lot No." := LotNo;
            DetailToBalance.Insert;
        end;
        DetailToBalance.Quantity += Qty;
        DetailToBalance."Remaining Quantity" += RemQty;
        DetailToBalance."Quantity (Alt.)" += AltQty;
        DetailToBalance."Remaining Quantity (Alt.)" += RemAltQty;
        DetailToBalance."Invoiced Quantity" += QtyUsed;
        DetailToBalance."Invoiced Quantity (Alt.)" += QtyUsedAlt;
        DetailToBalance.Modify;
    end;

    procedure BalanceIntermediate(BatchOrder: Code[20]; var BalancingMethod: Option ,"Output Matches Consumption","Consumption Matches Output"; Date: Date)
    var
        ProdOrderLine: Record "Prod. Order Line";
        BalancingMethodForm: Page "Intermediate Balancing Method";
    begin
        // P8000904
        ProdDate := Date;
        ProdOrder.SetCurrentKey(Status, "Batch Prod. Order No.");
        ProdOrder.SetRange(Status, ProdOrder.Status::Released);
        ProdOrder.SetRange(Suborder, true);
        ProdOrder.SetRange("Batch Prod. Order No.", BatchOrder);
        if ProdOrder.IsEmpty then
            Error(Text101);

        BalancingMethodForm.SetBalancingMethod(BalancingMethod);
        if (BalancingMethodForm.RunModal <> ACTION::Yes) then
            exit;
        BalancingMethod := BalancingMethodForm.GetBalancingMethod;
        if BalancingMethod = 0 then
            exit;

        ProcessSetup.Get;

        ProdOrder.Get(ProdOrder.Status::Released, BatchOrder);

        ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Released);
        ProdOrderLine.SetRange("Prod. Order No.", BatchOrder);
        ProdOrderLine.SetRange("By-Product", false);
        if ProdOrderLine.FindSet then
            repeat
                Item.Get(ProdOrderLine."Item No.");
                if not Item.Mark then begin
                    Item.Mark(true);

                    ClearBuffer;
                    LoadConsumption;
                    LoadOutput;
                    case BalancingMethod of
                        BalancingMethod::"Output Matches Consumption":
                            begin
                                Balance(BalanceBuffer[1].Type::Consumption, BalanceBuffer[1].Type::Output, LineCount[BalancingMethod]);
                                UpdateJournal(BalanceBuffer[1].Type::Output);
                            end;
                        BalancingMethod::"Consumption Matches Output":
                            begin
                                Balance(BalanceBuffer[1].Type::Output, BalanceBuffer[1].Type::Consumption, LineCount[BalancingMethod]);
                                ;
                                UpdateJournal(BalanceBuffer[1].Type::Consumption);
                            end;
                    end;
                end;
            until ProdOrderLine.Next = 0;
    end;

    procedure ClearBuffer()
    begin
        // P8000904
        BalanceBuffer[1].Reset;
        BalanceBuffer[1].DeleteAll;
        BalanceBuffer[2].Reset; // P8001330
        Clear(LineCount);       // P8001330
    end;

    procedure LoadConsumption()
    var
        ProdOrder2: Record "Production Order";
        ProdOrderComp: Record "Prod. Order Component";
        ItemLedger: Record "Item Ledger Entry";
        ItemJnlLine: Record "Item Journal Line";
        ResEntry: Record "Reservation Entry";
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // P8000904
        ProdOrder2.SetCurrentKey(Status, "Batch Prod. Order No.");
        ProdOrder2.SetRange(Status, ProdOrder2.Status::Released);
        ProdOrder2.SetRange("Batch Prod. Order No.", ProdOrder."No.");
        ProdOrder2.SetRange(Suborder, true);
        if ProdOrder2.FindSet then
            repeat
                ProdOrderComp.SetRange(Status, ProdOrder2.Status);
                ProdOrderComp.SetRange("Prod. Order No.", ProdOrder2."No.");
                ProdOrderComp.SetRange("Item No.", Item."No.");

                ItemLedger.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type", "Prod. Order Comp. Line No."); // P8001132
                ItemLedger.SetRange("Order Type", ItemLedger."Order Type"::Production); // P8001132
                ItemLedger.SetRange("Order No.", ProdOrder2."No."); // P8001132
                ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::Consumption);

                ItemJnlLine.SetCurrentKey("Entry Type", "Order No."); // P8001132
                ItemJnlLine.SetRange("Entry Type", ItemJnlLine."Entry Type"::Consumption);
                ItemJnlLine.SetRange("Journal Template Name", ProcessSetup."Batch Consumption Template");
                ItemJnlLine.SetRange("Journal Batch Name", ProcessSetup."Batch Consumption Batch");
                ItemJnlLine.SetRange("Order Type", ItemJnlLine."Order Type"::Production); // P8001132
                ItemJnlLine.SetRange("Order No.", ProdOrder2."No."); // P8001132

                ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
                  "Source Prod. Order Line", "Source Ref. No.");
                ResEntry.SetRange("Source Type", DATABASE::"Item Journal Line");
                ResEntry.SetRange("Source Subtype", ItemJnlLine."Entry Type"::Consumption);
                ResEntry.SetRange("Source ID", ProcessSetup."Batch Consumption Template");
                ResEntry.SetRange("Source Batch Name", ProcessSetup."Batch Consumption Batch");

                if ProdOrderComp.FindSet then
                    repeat
                        LineCount[2] += 1;

                        UpdateBuffer(BalanceBuffer[1].Type::Consumption, '',
                          ProdOrder2."No.", ProdOrderComp."Prod. Order Line No.", ProdOrderComp."Line No.",
                          ProdOrderComp."Expected Qty. (Base)", 0, 0, 0, 0, 0, 0);

                        ItemLedger.SetRange("Prod. Order Comp. Line No.", ProdOrderComp."Line No.");
                        if ItemLedger.FindSet then
                            repeat
                                UpdateBuffer(BalanceBuffer[1].Type::Consumption, ItemLedger."Lot No.",
                                  ProdOrder2."No.", ProdOrderComp."Prod. Order Line No.", ProdOrderComp."Line No.",
                                  0, -ItemLedger.Quantity, -ItemLedger."Quantity (Alt.)",
                                  -ItemLedger."Remaining Quantity", -ItemLedger."Remaining Quantity (Alt.)",
                                  0, 0);
                            until ItemLedger.Next = 0;

                        ItemJnlLine.SetRange("Prod. Order Comp. Line No.", ProdOrderComp."Line No.");
                        if ItemJnlLine.FindSet then
                            repeat
                                UpdateBuffer(BalanceBuffer[1].Type::Consumption, '',
                                  ProdOrder2."No.", ProdOrderComp."Prod. Order Line No.", ProdOrderComp."Line No.",
                                  0, 0, 0, 0, 0, ItemJnlLine."Quantity (Base)", 0);

                                if Item."Item Tracking Code" <> '' then begin
                                    ResEntry.SetRange("Source Ref. No.", ItemJnlLine."Line No.");
                                    if ResEntry.FindSet then
                                        repeat
                                            UpdateBuffer(BalanceBuffer[1].Type::Consumption, ResEntry."Lot No.",
                                              ProdOrder2."No.", ProdOrderComp."Prod. Order Line No.", ProdOrderComp."Line No.",
                                              0, 0, 0, 0, 0, -ResEntry."Quantity (Base)", 0);
                                        until ResEntry.Next = 0;
                                end;
                                if Item."Catch Alternate Qtys." then begin
                                    AltQtyLine.SetRange("Alt. Qty. Transaction No.", ItemJnlLine."Alt. Qty. Transaction No.");
                                    if AltQtyLine.Find('-') then
                                        repeat
                                            UpdateBuffer(BalanceBuffer[1].Type::Consumption, AltQtyLine."Lot No.",
                                              ProdOrder2."No.", ProdOrderComp."Prod. Order Line No.", ProdOrderComp."Line No.",
                                              0, 0, 0, 0, 0, 0, AltQtyLine."Quantity (Alt.)");
                                        until AltQtyLine.Next = 0;
                                end;
                            until ItemJnlLine.Next = 0;
                    until ProdOrderComp.Next = 0;
            until ProdOrder2.Next = 0;
    end;

    procedure LoadOutput()
    var
        ProdOrderLine2: Record "Prod. Order Line";
        ItemLedger: Record "Item Ledger Entry";
        ItemJnlLine: Record "Item Journal Line";
        ResEntry: Record "Reservation Entry";
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        // P8000904
        ProdOrderLine2.SetRange(Status, ProdOrder.Status);
        ProdOrderLine2.SetRange("Prod. Order No.", ProdOrder."No.");
        ProdOrderLine2.SetRange("Item No.", Item."No.");

        ItemLedger.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type", "Prod. Order Comp. Line No."); // P8001132
        ItemLedger.SetRange("Order Type", ItemLedger."Order Type"::Production); // P8001132
        ItemLedger.SetRange("Order No.", ProdOrder."No."); // P8001132
        ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::Output);
        ItemJnlLine.SetCurrentKey("Entry Type", "Order No."); // P8001132
        ItemJnlLine.SetRange("Entry Type", ItemJnlLine."Entry Type"::Output);
        ItemJnlLine.SetRange("Journal Template Name", ProcessSetup."Batch Output Template");
        ItemJnlLine.SetRange("Journal Batch Name", ProcessSetup."Batch Output Batch");
        ItemJnlLine.SetRange("Order Type", ItemJnlLine."Order Type"::Production); // P8001132
        ItemJnlLine.SetRange("Order No.", ProdOrder."No."); // P8001132

        ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
          "Source Prod. Order Line", "Source Ref. No.");
        ResEntry.SetRange("Source Type", DATABASE::"Item Journal Line");
        ResEntry.SetRange("Source Subtype", ItemJnlLine."Entry Type"::Output);
        ResEntry.SetRange("Source ID", ProcessSetup."Batch Output Template");
        ResEntry.SetRange("Source Batch Name", ProcessSetup."Batch Output Batch");

        if ProdOrderLine2.FindSet then
            repeat
                LineCount[1] += 1;

                UpdateBuffer(BalanceBuffer[1].Type::Output, '', ProdOrder."No.", ProdOrderLine2."Line No.", 0,
                  ProdOrderLine2."Quantity (Base)", 0, 0, 0, 0, 0, 0);

                ItemLedger.SetRange("Order Line No.", ProdOrderLine2."Line No."); // P8001132
                if ItemLedger.FindSet then
                    repeat
                        UpdateBuffer(BalanceBuffer[1].Type::Output, ItemLedger."Lot No.", ProdOrder."No.", ProdOrderLine2."Line No.", 0,
                          0, ItemLedger.Quantity, ItemLedger."Quantity (Alt.)",
                          ItemLedger."Remaining Quantity", ItemLedger."Remaining Quantity (Alt.)",
                          0, 0);
                    until ItemLedger.Next = 0;

                ItemJnlLine.SetRange("Order Line No.", ProdOrderLine2."Line No."); // P8001132
                if ItemJnlLine.FindSet then
                    repeat
                        UpdateBuffer(BalanceBuffer[1].Type::Output, '', ProdOrder."No.", ProdOrderLine2."Line No.", 0,
                          0, 0, 0, 0, 0, ItemJnlLine."Quantity (Base)", 0);

                        if Item."Item Tracking Code" <> '' then begin
                            ResEntry.SetRange("Source Ref. No.", ItemJnlLine."Line No.");
                            if ResEntry.FindSet then
                                repeat
                                    UpdateBuffer(BalanceBuffer[1].Type::Output, ResEntry."Lot No.", ProdOrder."No.", ProdOrderLine2."Line No.", 0,
                                      0, 0, 0, 0, 0, ResEntry."Quantity (Base)", 0);
                                until ResEntry.Next = 0;
                        end;
                        if Item."Catch Alternate Qtys." then begin
                            AltQtyLine.SetRange("Alt. Qty. Transaction No.", ItemJnlLine."Alt. Qty. Transaction No.");
                            if AltQtyLine.Find('-') then
                                repeat
                                    UpdateBuffer(BalanceBuffer[1].Type::Output, AltQtyLine."Lot No.",
                                      ProdOrder."No.", ProdOrderLine2."Line No.", 0,
                                      0, 0, 0, 0, 0, 0, AltQtyLine."Quantity (Alt.)");
                                until AltQtyLine.Next = 0;
                        end;
                    until ItemJnlLine.Next = 0;
            until ProdOrderLine2.Next = 0;
    end;

    procedure Balance(Source: Integer; Target: Integer; TargetLineCount: Integer)
    var
        ItemLedger: Record "Item Ledger Entry";
        ExpectedQty: Decimal;
    begin
        // P8000904
        BalanceBuffer[1].SetRange(Type, Source);
        BalanceBuffer[2].SetRange(Type, Target);
        if Item."Item Tracking Code" <> '' then begin
            BalanceBuffer[1].FilterGroup(9);
            BalanceBuffer[1].SetFilter("Lot No.", '<>%1', '');
            BalanceBuffer[1].FilterGroup(0);
        end;

        // Special case a single target line, entire source can go to that line
        if (Item."Item Tracking Code" <> '') and (TargetLineCount = 1) then begin
            if BalanceBuffer[2].Find('-') then;
            BalanceBuffer[2].SetFilter("Lot No.", '<>%1', '');
            BalanceBuffer[2].ModifyAll("Expected Quantity", 0);
            BalanceBuffer[2].ModifyAll("Journal Quantity", 0);
            BalanceBuffer[2].ModifyAll("Journal Quantity (Alt.)", 0);
            BalanceBuffer[2].SetRange("Lot No.");
            if BalanceBuffer[1].Find('-') then
                repeat
                    BalanceBuffer[1].SetRange("Lot No.", BalanceBuffer[1]."Lot No.");
                    UpdateBuffer(BalanceBuffer[2].Type, BalanceBuffer[1]."Lot No.",
                      BalanceBuffer[2]."Prod. Order No.", BalanceBuffer[2]."Prod. Order Line No.", BalanceBuffer[2]."Prod. Order Comp. Line No.",
                      1, 0, 0, 0, 0, 0, 0);
                    BalanceBuffer[1].Find('+');
                    BalanceBuffer[1].SetRange("Lot No.");
                until BalanceBuffer[1].Next = 0;
        end;

        if BalanceBuffer[1].Find('-') then
            repeat
                BalanceBuffer[1].SetRange("Lot No.", BalanceBuffer[1]."Lot No.");
                BalanceBuffer[1].CalcSums("Posted Quantity", "Posted Quantity (Alt.)", "Journal Quantity", "Journal Quantity (Alt.)");
                BalanceBuffer[1]."Posted Quantity" += BalanceBuffer[1]."Journal Quantity";
                BalanceBuffer[1]."Posted Quantity (Alt.)" += BalanceBuffer[1]."Journal Quantity (Alt.)";

                ExpectedQty := 0;
                BalanceBuffer[2].SetRange("Lot No.", BalanceBuffer[1]."Lot No.");
                if BalanceBuffer[2].Find('-') then begin
                    repeat
                        BalanceBuffer[3].Get(BalanceBuffer[2].Type, '', BalanceBuffer[2]."Prod. Order No.",
                          BalanceBuffer[2]."Prod. Order Line No.", BalanceBuffer[2]."Prod. Order Comp. Line No.");
                        ExpectedQty += BalanceBuffer[3]."Expected Quantity";
                    until BalanceBuffer[2].Next = 0;

                    BalanceBuffer[2].Find('-');
                    repeat
                        if ExpectedQty <> 0 then begin
                            BalanceBuffer[3].Get(BalanceBuffer[2].Type, '', BalanceBuffer[2]."Prod. Order No.",
                              BalanceBuffer[2]."Prod. Order Line No.", BalanceBuffer[2]."Prod. Order Comp. Line No.");
                            BalanceBuffer[2]."Journal Quantity" :=
                              Round(BalanceBuffer[1]."Posted Quantity" * BalanceBuffer[3]."Expected Quantity" / ExpectedQty, 0.00001);
                            BalanceBuffer[2]."Journal Quantity (Alt.)" :=
                              Round(BalanceBuffer[1]."Posted Quantity (Alt.)" * BalanceBuffer[3]."Expected Quantity" / ExpectedQty, 0.00001);
                            ExpectedQty -= BalanceBuffer[3]."Expected Quantity";
                        end else begin
                            BalanceBuffer[2]."Journal Quantity" := 0;
                            BalanceBuffer[2]."Journal Quantity (Alt.)" := 0;
                        end;
                        BalanceBuffer[1]."Posted Quantity" -= BalanceBuffer[2]."Journal Quantity";
                        BalanceBuffer[1]."Posted Quantity (Alt.)" -= BalanceBuffer[2]."Journal Quantity (Alt.)";
                        BalanceBuffer[2]."Journal Quantity" -= BalanceBuffer[2]."Posted Quantity";
                        BalanceBuffer[2]."Journal Quantity (Alt.)" -= BalanceBuffer[2]."Posted Quantity (Alt.)";
                        BalanceBuffer[2].Modify;
                    until BalanceBuffer[2].Next = 0;
                end else begin
                    BalanceBuffer[2].Type := Target;
                    Error(Text103, BalanceBuffer[1].FieldCaption("Lot No."), BalanceBuffer[1]."Lot No.", BalanceBuffer[2].Type);
                end;

                BalanceBuffer[1].Find('+');
                BalanceBuffer[1].SetRange("Lot No.");
            until BalanceBuffer[1].Next = 0;

        BalanceBuffer[1].Reset;
        BalanceBuffer[2].Reset;
        BalanceBuffer[1].SetRange(Type, BalanceBuffer[1].Type::Consumption);
        BalanceBuffer[2].SetRange(Type, BalanceBuffer[1].Type::Output);
        BalanceBuffer[1].FilterGroup(9);
        if Item."Item Tracking Code" <> '' then
            BalanceBuffer[1].SetFilter("Lot No.", '<>%1', '');
        BalanceBuffer[1].FilterGroup(0);
        if BalanceBuffer[1].Find('-') then
            repeat
                BalanceBuffer[1].SetRange("Lot No.", BalanceBuffer[1]."Lot No.");
                BalanceBuffer[1].CalcSums("Journal Quantity", "Journal Quantity (Alt.)");
                BalanceBuffer[2].SetRange("Lot No.", BalanceBuffer[1]."Lot No.");
                BalanceBuffer[2].CalcSums("Remaining Quantity", "Remaining Quantity (Alt.)", "Journal Quantity", "Journal Quantity (Alt.)");
                BalanceBuffer[2]."Remaining Quantity" += BalanceBuffer[2]."Journal Quantity";
                BalanceBuffer[2]."Remaining Quantity (Alt.)" += BalanceBuffer[2]."Journal Quantity (Alt.)";
                if (BalanceBuffer[2]."Remaining Quantity" < BalanceBuffer[1]."Journal Quantity") or
                   (BalanceBuffer[2]."Remaining Quantity (Alt.)" < BalanceBuffer[1]."Journal Quantity (Alt.)")
                then
                    Error(Text102, ItemLedger.TableCaption, ItemLedger.FieldCaption("Remaining Quantity"),
                      BalanceBuffer[1].FieldCaption("Lot No."), BalanceBuffer[1]."Lot No.");
                BalanceBuffer[1].Find('+');
                BalanceBuffer[1].SetRange("Lot No.");
            until BalanceBuffer[1].Next = 0;
    end;

    procedure UpdateJournal(Type: Integer)
    var
        ProdOrder2: Record "Production Order";
        ProdOrderLine2: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
    begin
        // P8000904
        BalanceBuffer[1].Reset;
        BalanceBuffer[1].SetRange(Type, Type);
        if Item."Item Tracking Code" <> '' then begin
            BalanceBuffer[1].FilterGroup(9);
            BalanceBuffer[1].SetFilter("Lot No.", '<>%1', '');
            BalanceBuffer[1].FilterGroup(0);
        end;
        BalanceBuffer[1].SetRange("Journal Quantity", 0);
        BalanceBuffer[1].DeleteAll;
        BalanceBuffer[1].SetRange("Journal Quantity");

        case Type of
            BalanceBuffer[1].Type::Consumption:
                begin
                    ProdOrder2.SetCurrentKey(Status, "Batch Prod. Order No.");
                    ProdOrder2.SetRange(Status, ProdOrder2.Status::Released);
                    ProdOrder2.SetRange("Batch Prod. Order No.", ProdOrder."No.");
                    ProdOrder2.SetRange(Suborder, true);
                    if ProdOrder2.FindSet then
                        repeat
                            ProdOrderComp.SetRange(Status, ProdOrder2.Status);
                            ProdOrderComp.SetRange("Prod. Order No.", ProdOrder2."No.");
                            ProdOrderComp.SetRange("Item No.", Item."No.");
                            if ProdOrderComp.FindSet then
                                repeat
                                    UpdateJournalLine(ProdOrderComp."Prod. Order No.", ProdOrderComp."Prod. Order Line No.", ProdOrderComp."Line No.");
                                until ProdOrderComp.Next = 0;
                        until ProdOrder2.Next = 0;
                end;

            BalanceBuffer[1].Type::Output:
                begin
                    ProdOrderLine2.SetRange(Status, ProdOrder.Status);
                    ProdOrderLine2.SetRange("Prod. Order No.", ProdOrder."No.");
                    ProdOrderLine2.SetRange("Item No.", Item."No.");
                    if ProdOrderLine2.FindSet then
                        repeat
                            UpdateJournalLine(ProdOrderLine2."Prod. Order No.", ProdOrderLine2."Line No.", 0);
                        until ProdOrderLine2.Next = 0;
                end;
        end;
    end;

    procedure UpdateJournalLine(OrderNo: Code[20]; OrderLineNo: Integer; CompLineNo: Integer)
    var
        ItemJnlLine: Record "Item Journal Line";
        ShipDate: Date;
        RcptDate: Date;
    begin
        // P8000904
        if CompLineNo = 0 then begin
            ItemJnlLine.SetRange("Journal Template Name", ProcessSetup."Batch Output Template");
            ItemJnlLine.SetRange("Journal Batch Name", ProcessSetup."Batch Output Batch");
            ItemJnlLine.SetRange("Entry Type", ItemJnlLine."Entry Type"::Output);
        end else begin
            ItemJnlLine.SetRange("Journal Template Name", ProcessSetup."Batch Consumption Template");
            ItemJnlLine.SetRange("Journal Batch Name", ProcessSetup."Batch Consumption Batch");
            ItemJnlLine.SetRange("Entry Type", ItemJnlLine."Entry Type"::Consumption);
        end;
        ItemJnlLine.SetRange("Order Type", ItemJnlLine."Order Type"::Production); // P8001132
        ItemJnlLine.SetRange("Order No.", OrderNo); // P8001132
        ItemJnlLine.SetRange("Order Line No.", OrderLineNo); // P8001132
        ItemJnlLine.SetRange("Prod. Order Comp. Line No.", CompLineNo);

        BalanceBuffer[1].SetRange("Prod. Order No.", OrderNo);
        BalanceBuffer[1].SetRange("Prod. Order Line No.", OrderLineNo);
        BalanceBuffer[1].SetRange("Prod. Order Comp. Line No.", CompLineNo);

        if ItemJnlLine.FindSet(true, true) then
            repeat
                if Item."Item Tracking Code" <> '' then
                    DeleteReservationEntries(ItemJnlLine);
                if Item."Catch Alternate Qtys." then begin
                    DeleteAltQtyLines(ItemJnlLine);
                    ItemJnlLine."Quantity (Alt.)" := 0;
                end;
                if BalanceBuffer[1].Find('-') then begin
                    BalanceBuffer[1].CalcSums("Journal Quantity", "Journal Quantity (Alt.)");
                    Item.GetItemUOMRndgPrecision(ItemJnlLine."Unit of Measure Code", true);
                    case ItemJnlLine."Entry Type" of
                        ItemJnlLine."Entry Type"::Consumption:
                            begin
                                ItemJnlLine.Validate(Quantity,
                                  Round(BalanceBuffer[1]."Journal Quantity" / ItemJnlLine."Qty. per Unit of Measure", Item."Rounding Precision"));
                                ItemJnlLine."Quantity (Base)" := BalanceBuffer[1]."Journal Quantity";
                                ShipDate := ItemJnlLine."Posting Date";
                                RcptDate := 0D;
                            end;
                        ItemJnlLine."Entry Type"::Output:
                            begin
                                ItemJnlLine.Validate("Output Quantity",
                                  Round(BalanceBuffer[1]."Journal Quantity" / ItemJnlLine."Qty. per Unit of Measure", Item."Rounding Precision"));
                                ItemJnlLine."Output Quantity (Base)" := BalanceBuffer[1]."Journal Quantity";
                                ItemJnlLine."Quantity (Base)" := BalanceBuffer[1]."Journal Quantity";
                                ShipDate := 0D;
                                RcptDate := ItemJnlLine."Posting Date";
                            end;
                    end;
                    if Item."Item Tracking Code" <> '' then begin
                        BalanceBuffer[1].Find; // Clear the CALCSUMS
                        repeat
                            CreateReservationEntry(ItemJnlLine, BalanceBuffer[1]."Lot No.", ShipDate, RcptDate,
                              BalanceBuffer[1]."Journal Quantity", BalanceBuffer[1]."Journal Quantity (Alt.)");
                            CreateAltQtyLine(ItemJnlLine, BalanceBuffer[1]."Lot No.",
                              BalanceBuffer[1]."Journal Quantity", BalanceBuffer[1]."Journal Quantity (Alt.)");
                        until BalanceBuffer[1].Next = 0;
                        ItemJnlLine.GetLotNo; // P8001330
                    end else
                        CreateAltQtyLine(ItemJnlLine, '',
                          BalanceBuffer[1]."Journal Quantity", BalanceBuffer[1]."Journal Quantity (Alt.)");
                    ItemJnlLine.Modify;
                    BalanceBuffer[1].DeleteAll;
                end else
                    ItemJnlLine.Delete(true);
            until ItemJnlLine.Next = 0;

        if BalanceBuffer[1].Find('-') then begin
            // This will happen if adjustments need to be made to a previously posted amount and there is no item journal
            // record availabel to use for this
            BalanceBuffer[1].CalcSums("Journal Quantity", "Journal Quantity (Alt.)");
            InitItemJnlLine(BalanceBuffer[1], ItemJnlLine, ShipDate, RcptDate);
            ItemJnlLine.Insert;
            if Item."Item Tracking Code" <> '' then begin
                BalanceBuffer[1].Find; // Clear the CALCSUMS
                repeat
                    CreateReservationEntry(ItemJnlLine, BalanceBuffer[1]."Lot No.", ShipDate, RcptDate,
                      BalanceBuffer[1]."Journal Quantity", BalanceBuffer[1]."Journal Quantity (Alt.)");
                    CreateAltQtyLine(ItemJnlLine, BalanceBuffer[1]."Lot No.",
                      BalanceBuffer[1]."Journal Quantity", BalanceBuffer[1]."Journal Quantity (Alt.)");
                until BalanceBuffer[1].Next = 0;
                ItemJnlLine.GetLotNo; // P8001330
            end else
                CreateAltQtyLine(ItemJnlLine, '',
                  BalanceBuffer[1]."Journal Quantity", BalanceBuffer[1]."Journal Quantity (Alt.)");
            ItemJnlLine.Modify;
        end;
    end;

    procedure InitItemJnlLine(BalanceBuffer: Record "Intermediate Balancing Buffer"; var ItemJnlLine: Record "Item Journal Line"; var ShipDate: Date; var RcptDate: Date)
    var
        ProdOrder2: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        ProdOrderRtgLine: Record "Prod. Order Routing Line";
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlBatch: Record "Item Journal Batch";
        P800ProdOrderMgmt: Codeunit "Process 800 Prod. Order Mgt.";
        UOMCode: Code[10];
        ExpectedQty: Decimal;
    begin
        // P8000904
        ProdOrderLine.Get(ProdOrderComp.Status::Released, BalanceBuffer."Prod. Order No.", BalanceBuffer."Prod. Order Line No.");

        ItemJnlLine.Init;
        case BalanceBuffer.Type of
            BalanceBuffer.Type::Consumption:
                begin
                    ProdOrder2.Get(ProdOrder2.Status::Released, BalanceBuffer."Prod. Order No.");
                    ProdOrderComp.Get(ProdOrderComp.Status::Released,
                      BalanceBuffer."Prod. Order No.", BalanceBuffer."Prod. Order Line No.", BalanceBuffer."Prod. Order Comp. Line No.");
                    ItemJnlLine."Journal Template Name" := ProcessSetup."Batch Consumption Template";
                    ItemJnlLine."Journal Batch Name" := ProcessSetup."Batch Consumption Batch";
                    ItemJnlLine."Line No." := P800ProdOrderMgmt.GetNextItemJnlLineNo(
                      ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name", BalanceBuffer."Prod. Order No.");
                    ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::Consumption);
                    UOMCode := ProdOrderComp."Unit of Measure Code";
                    Item.GetItemUOMRndgPrecision(UOMCode, true);
                    if (ProdOrderLine."Finished Quantity" <> 0) and
                      (ProdOrder2."Order Type" = ProdOrder."Order Type"::Package)
                    then
                        ExpectedQty := ProdOrderComp.ProdOrderNeeds *
                          ProdOrderComp.Quantity * ProdOrderLine."Finished Qty. (Base)" / ProdOrderLine."Quantity (Base)"
                    else
                        ExpectedQty := ProdOrderComp."Expected Quantity";
                    ExpectedQty := Round(ExpectedQty, Item."Rounding Precision", '>');
                end;

            BalanceBuffer.Type::Output:
                begin
                    ItemJnlLine."Journal Template Name" := ProcessSetup."Batch Output Template";
                    ItemJnlLine."Journal Batch Name" := ProcessSetup."Batch Output Batch";
                    ItemJnlLine."Line No." := P800ProdOrderMgmt.GetNextItemJnlLineNo(
                      ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name", BalanceBuffer."Prod. Order No.");
                    ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::Output);
                    UOMCode := ProdOrderLine."Unit of Measure Code";
                    Item.GetItemUOMRndgPrecision(UOMCode, true);
                    ExpectedQty := ProdOrderLine.Quantity;
                    ProdOrderRtgLine.SetRange(Status, ProdOrderLine.Status);
                    ProdOrderRtgLine.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
                    ProdOrderRtgLine.SetRange("Routing Reference No.", ProdOrderLine."Routing Reference No.");
                    ProdOrderRtgLine.SetRange("Routing No.", ProdOrderLine."Routing No.");
                    if ProdOrderRtgLine.FindLast then;
                end;
        end;
        ItemJnlLine.Validate("Posting Date", ProdDate);
        ItemJnlLine.Validate("Order Type", ItemJnlLine."Order Type"::Production); // P8001132
        ItemJnlLine.Validate("Order No.", BalanceBuffer."Prod. Order No."); // P8001132
        ItemJnlLine.Validate("Document No.", ProdOrder."No.");
        ItemJnlLine.Validate("Order Line No.", BalanceBuffer."Prod. Order Line No."); // P8001132
        ItemJnlLine.Validate("Prod. Order Comp. Line No.", BalanceBuffer."Prod. Order Comp. Line No.");
        ItemJnlLine.Validate("Item No.", Item."No.");
        ItemJnlLine.Validate("Location Code", ProdOrderLine."Location Code");
        ItemJnlLine.Validate("Unit of Measure Code", UOMCode);
        if ProdOrderRtgLine."Prod. Order No." = BalanceBuffer."Prod. Order No." then begin
            ItemJnlLine.Validate("Routing No.", ProdOrderRtgLine."Routing No.");
            ItemJnlLine.Validate("Routing Reference No.", ProdOrderRtgLine."Routing Reference No.");
            ItemJnlLine.Validate("Operation No.", ProdOrderRtgLine."Operation No.");
        end;
        ItemJnlLine.Validate("Setup Time", 0);
        ItemJnlLine.Validate("Run Time", 0);
        ItemJnlLine.Validate("Expected Quantity", ExpectedQty);
        case ItemJnlLine."Entry Type" of
            ItemJnlLine."Entry Type"::Consumption:
                begin
                    ItemJnlLine.Validate(Quantity,
                      Round(BalanceBuffer."Journal Quantity" / ItemJnlLine."Qty. per Unit of Measure", Item."Rounding Precision"));
                    ItemJnlLine."Quantity (Base)" := BalanceBuffer."Journal Quantity";
                    ShipDate := ItemJnlLine."Posting Date";
                    RcptDate := 0D;
                end;
            ItemJnlLine."Entry Type"::Output:
                begin
                    ItemJnlLine.Validate("Output Quantity",
                      Round(BalanceBuffer."Journal Quantity" / ItemJnlLine."Qty. per Unit of Measure", Item."Rounding Precision"));
                    ItemJnlLine."Output Quantity (Base)" := BalanceBuffer."Journal Quantity";
                    ItemJnlLine."Quantity (Base)" := BalanceBuffer."Journal Quantity";
                    ShipDate := 0D;
                    RcptDate := ItemJnlLine."Posting Date";
                end;
        end;
        ItemJnlTemplate.Get(ItemJnlLine."Journal Template Name");
        ItemJnlLine."Source Code" := ItemJnlTemplate."Source Code";
        ItemJnlBatch.Get(ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name");
        ItemJnlLine."Reason Code" := ItemJnlBatch."Reason Code";
        ItemJnlLine.Description := Item.Description;
    end;

    procedure UpdateBuffer(Type: Integer; LotNo: Code[50]; OrderNo: Code[20]; LineNo: Integer; CompLineNo: Integer; ExpQty: Decimal; PostedQty: Decimal; PostedQtyAlt: Decimal; RemQty: Decimal; RemQtyAlt: Decimal; JnlQty: Decimal; JnlQtyAlt: Decimal)
    begin
        // P8000904
        if not BalanceBuffer[3].Get(Type, LotNo, OrderNo, LineNo, CompLineNo) then begin
            BalanceBuffer[3].Init;
            BalanceBuffer[3].Type := Type;
            BalanceBuffer[3]."Lot No." := LotNo;
            BalanceBuffer[3]."Prod. Order No." := OrderNo;
            BalanceBuffer[3]."Prod. Order Line No." := LineNo;
            BalanceBuffer[3]."Prod. Order Comp. Line No." := CompLineNo;
            BalanceBuffer[3].Insert;
        end;
        BalanceBuffer[3]."Expected Quantity" += ExpQty;
        BalanceBuffer[3]."Posted Quantity" += PostedQty;
        BalanceBuffer[3]."Posted Quantity (Alt.)" += PostedQtyAlt;
        BalanceBuffer[3]."Remaining Quantity" += RemQty;
        BalanceBuffer[3]."Remaining Quantity (Alt.)" += RemQtyAlt;
        BalanceBuffer[3]."Journal Quantity" += JnlQty;
        BalanceBuffer[3]."Journal Quantity (Alt.)" += JnlQtyAlt;
        BalanceBuffer[3].Modify;
    end;

    procedure DeleteReservationEntries(ItemJnlLine: Record "Item Journal Line")
    var
        ResEntry: Record "Reservation Entry";
    begin
        with ItemJnlLine do begin
            ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name",
              "Source Prod. Order Line", "Source Ref. No.");
            ResEntry.SetRange("Source Type", DATABASE::"Item Journal Line");
            ResEntry.SetRange("Source Subtype", ItemJnlLine."Entry Type");
            ResEntry.SetRange("Source ID", ItemJnlLine."Journal Template Name");
            ResEntry.SetRange("Source Batch Name", ItemJnlLine."Journal Batch Name");
            ResEntry.SetRange("Source Ref. No.", "Line No.");
            ResEntry.DeleteAll(true);
        end;
    end;

    procedure CreateReservationEntry(var ItemJnlLine: Record "Item Journal Line"; LotNo: Code[50]; RcptDate: Date; ShipDate: Date; QtyBase: Decimal; QtyAlt: Decimal)
    var
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        Qty: Decimal;
    begin
        Qty := Round(QtyBase / ItemJnlLine."Qty. per Unit of Measure", 0.00001); // P8001132
        CreateReservEntry.CreateReservEntryFor(
          DATABASE::"Item Journal Line", ItemJnlLine."Entry Type", ItemJnlLine."Journal Template Name",
          ItemJnlLine."Journal Batch Name", 0, ItemJnlLine."Line No.", ItemJnlLine."Qty. per Unit of Measure", Qty, QtyBase, // P8001132
          '', LotNo); // P8000466A
        CreateReservEntry.AddAltQtyData(QtyAlt);
        CreateReservEntry.CreateEntry(ItemJnlLine."Item No.", ItemJnlLine."Variant Code",
          ItemJnlLine."Location Code", ItemJnlLine.Description, RcptDate, ShipDate, 0, 3);
    end;

    procedure DeleteAltQtyLines(ItemJnlLine: Record "Item Journal Line")
    var
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", ItemJnlLine."Alt. Qty. Transaction No.");
        AltQtyLine.DeleteAll;
    end;

    procedure CreateAltQtyLine(var ItemJnlLine: Record "Item Journal Line"; LotNo: Code[50]; QtyBase: Decimal; QtyAlt: Decimal)
    var
        AltQtyLine: Record "Alternate Quantity Line";
        AltQtyMgt: Codeunit "Alt. Qty. Management";
    begin
        if QtyAlt = 0 then
            exit;
        AltQtyMgt.AssignNewTransactionNo(ItemJnlLine."Alt. Qty. Transaction No.");
        AltQtyLine.SetRange("Alt. Qty. Transaction No.", ItemJnlLine."Alt. Qty. Transaction No.");
        if AltQtyLine.Find('+') then
            AltQtyLine."Line No." += 10000
        else
            AltQtyLine."Line No." := 10000;
        AltQtyLine."Alt. Qty. Transaction No." := ItemJnlLine."Alt. Qty. Transaction No.";
        AltQtyLine."Table No." := DATABASE::"Item Journal Line";
        AltQtyLine."Journal Template Name" := ItemJnlLine."Journal Template Name";
        AltQtyLine."Journal Batch Name" := ItemJnlLine."Journal Batch Name";
        AltQtyLine."Source Line No." := ItemJnlLine."Line No.";
        AltQtyLine."Lot No." := LotNo;
        AltQtyLine.Validate("Quantity (Base)", QtyBase);
        AltQtyLine.Validate("Quantity (Alt.)", QtyAlt);
        AltQtyLine.Insert;

        ItemJnlLine.Validate("Quantity (Alt.)", ItemJnlLine."Quantity (Alt.)" + QtyAlt);
    end;
}

