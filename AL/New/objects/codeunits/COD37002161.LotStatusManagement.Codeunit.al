codeunit 37002161 "Lot Status Management"
{
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // PRW18.00
    // P8001352, Columbus IT, Jack Reynolds, 30 OCT 14
    //   Modified for new FlowFields on the Item table
    // 
    // PRW18.00.02
    // P8004239, To-Increase, Jack Reynolds, 14 OCT 15
    //   Change lot status for container for multiple lots
    // 
    // PRW19.00.01
    // P8008155, To-Increase, Dayakar Battini, 02 DEC 16
    //   Fix issue with change lot status functionality, bin and new lot no. update on whse entries.
    // 
    // P8008293, To-Increase, Dayakar Battini, 09 FEB 17
    //   Fix loose inventory error with lot change status regarding whse movement.
    // 
    // PRW110.0.01
    // P80041970, To-Increase, Dayakar Battini, 26 JUN 17
    //   Fix issue with change lot status functionality, expiration date flow.
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80059064, To-Increase, Dayakar Battini, 17 MAY 18
    //   Corrected coding issues.
    // 
    // P80037569, To-Increase, Jack Reynolds, 25 JUL 18
    //   QC-Additions: Develop QC skip logic
    // 
    // P80059361, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - NAV Anywhere
    // 
    // P80045713, To-Increase, Jack Reynolds, 31 JUL 18
    //   Lot status warning when selecting lot from lot lookup
    // 
    // PRW111.00.03
    // P80082286, To-Increase, Gangabhushan, 09 SEP 19
    //   CS00075169 - Create Pick on items with many Warehouse Entries takes a long time.
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW11300.03
    // P80082969, To Increase, Jack Reynolds, 26 SEP 19
    //   New Events
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW120.00
    // P800144605, To Increase, Jack Reynolds, 20 APR 22
    //   Upgrade to 20.0
    //   Upgrade to 20.0 - Refactoring for default dimensions


    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'Lot Status Code %1 prohibits %2 of item %3, lot %4.';
        Text002: Label 'sale';
        Text003: Label 'purchase';
        Text004: Label 'transfer';
        Text005: Label 'consumption';
        Text006: Label 'adjustment';
        Text007: Label ' is after the posting date.';
        AvailableFor: Option " ",Sale,"Purchase Return",Transfer,Consumption,Adjustment,Planning;
        Text008: Label '%1 %2, %3 %4, %5 %6 is in quarantine.';

    procedure InsertItemLedger(ItemLedgEntry: Record "Item Ledger Entry")
    var
        LotInfo: Record "Lot No. Information";
        ItemStatusEntry: Record "Item Status Entry";
    begin
        if ItemLedgEntry."Drop Shipment" then
            exit;

        ItemStatusEntry."Item No." := ItemLedgEntry."Item No.";
        ItemStatusEntry."Variant Code" := ItemLedgEntry."Variant Code";
        ItemStatusEntry."Location Code" := ItemLedgEntry."Location Code";
        if ItemLedgEntry."Lot No." <> '' then begin
            LotInfo.Get(ItemLedgEntry."Item No.", ItemLedgEntry."Variant Code", ItemLedgEntry."Lot No.");
            ItemStatusEntry."Lot Status Code" := LotInfo."Lot Status Code";
        end;
        ItemStatusEntry.Quantity := ItemLedgEntry.Quantity;
        ItemStatusEntry."Quantity (Alt.)" := ItemLedgEntry."Quantity (Alt.)";
        ItemStatusEntry.UpdateRecord;
    end;

    procedure ChangeLotStatus(xLotInfo: Record "Lot No. Information"; LotInfo: Record "Lot No. Information")
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        Location: Record Location;
        ItemStatusEntry: Record "Item Status Entry";
    begin
        if LotInfo."Lot Status Code" = xLotInfo."Lot Status Code" then
            exit;

        LotInfo.LockTable;
        ItemLedgerEntry.LockTable;

        ItemLedgerEntry.SetCurrentKey("Item No.", "Variant Code", "Location Code", "Lot No.", "Serial No.", "Posting Date");
        ItemLedgerEntry.SetRange("Item No.", LotInfo."Item No.");
        ItemLedgerEntry.SetRange("Variant Code", LotInfo."Variant Code");
        ItemLedgerEntry.SetRange("Lot No.", LotInfo."Lot No.");

        ItemStatusEntry."Item No." := LotInfo."Item No.";
        ItemStatusEntry."Variant Code" := LotInfo."Variant Code";

        ItemLedgerEntry.SetRange("Location Code", '');
        ItemLedgerEntry.CalcSums(Quantity, "Quantity (Alt.)");
        if (ItemLedgerEntry.Quantity <> 0) or (ItemLedgerEntry."Quantity (Alt.)" <> 0) then begin
            ItemStatusEntry."Location Code" := '';
            ItemStatusEntry."Lot Status Code" := xLotInfo."Lot Status Code";
            ItemStatusEntry.Quantity := -ItemLedgerEntry.Quantity;
            ItemStatusEntry."Quantity (Alt.)" := -ItemLedgerEntry."Quantity (Alt.)";
            ItemStatusEntry.UpdateRecord;

            ItemStatusEntry."Lot Status Code" := LotInfo."Lot Status Code";
            ItemStatusEntry.Quantity := ItemLedgerEntry.Quantity;
            ItemStatusEntry."Quantity (Alt.)" := ItemLedgerEntry."Quantity (Alt.)";
            ItemStatusEntry.UpdateRecord;
        end;

        if Location.FindSet then
            repeat
                ItemLedgerEntry.SetRange("Location Code", Location.Code);
                ItemLedgerEntry.CalcSums(Quantity, "Quantity (Alt.)");
                if (ItemLedgerEntry.Quantity <> 0) or (ItemLedgerEntry."Quantity (Alt.)" <> 0) then begin
                    ItemStatusEntry."Location Code" := Location.Code;
                    ItemStatusEntry."Lot Status Code" := xLotInfo."Lot Status Code";
                    ItemStatusEntry.Quantity := -ItemLedgerEntry.Quantity;
                    ItemStatusEntry."Quantity (Alt.)" := -ItemLedgerEntry."Quantity (Alt.)";
                    ItemStatusEntry.UpdateRecord;

                    ItemStatusEntry."Lot Status Code" := LotInfo."Lot Status Code";
                    ItemStatusEntry.Quantity := ItemLedgerEntry.Quantity;
                    ItemStatusEntry."Quantity (Alt.)" := ItemLedgerEntry."Quantity (Alt.)";
                    ItemStatusEntry.UpdateRecord;
                end;
            until Location.Next = 0;
    end;

    procedure SetDefaultStatusForLot(var LotInfo: Record "Lot No. Information"; ItemJnlLine: Record "Item Journal Line")
    var
        InvSetup: Record "Inventory Setup";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        QCHeader: Record "Quality Control Header";
    begin
        InvSetup.Get;
        // P80037569
        //LotInfo.CALCFIELDS("Quality Control");
        //IF LotInfo."Quality Control" THEN BEGIN
        if not QCHeader.Get(LotInfo."Item No.", LotInfo."Variant Code", LotInfo."Lot No.", 1) then
            QCHeader.Status := QCHeader.Status::Skip;
        if QCHeader.Status <> QCHeader.Status::Skip then begin
            // P80037569
            if LotInfo."Release Date" = 0D then begin
                Item.Get(LotInfo."Item No.");
                ItemTrackingCode.Get(Item."Item Tracking Code");
                if ItemTrackingCode."Strict Quarantine Posting" then
                    LotInfo."Lot Status Code" := InvSetup."Quarantine Lot Status"
                else
                    LotInfo."Lot Status Code" := InvSetup."Quality Control Lot Status";
            end else
                LotInfo."Lot Status Code" := InvSetup."Quality Control Lot Status";
        end else
            case ItemJnlLine."Entry Type" of
                ItemJnlLine."Entry Type"::Purchase:
                    LotInfo."Lot Status Code" := InvSetup."Purchase Lot Status";
                ItemJnlLine."Entry Type"::Sale:
                    LotInfo."Lot Status Code" := InvSetup."Sales Lot Status";
                ItemJnlLine."Entry Type"::Output, ItemJnlLine."Entry Type"::"Assembly Output": // P8001132
                    LotInfo."Lot Status Code" := InvSetup."Output Lot Status";
                ItemJnlLine."Entry Type"::"Positive Adjmt.":
                    if ItemJnlLine."Order Type" = ItemJnlLine."Order Type"::FOODRepack then // P8001134
                        LotInfo."Lot Status Code" := InvSetup."Output Lot Status";
            end;
    end;

    procedure TestItemLedgerBlocked(LotNoInfo: Record "Lot No. Information"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        LotStatus: Record "Lot Status Code";
        InvSetup: Record "Inventory Setup";
        EntryType: Integer;
        TestRelease: Boolean;
    begin
        EntryType := ItemLedgerEntry."Entry Type";
        if ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::"Negative Adjmt." then
            case ItemLedgerEntry."Order Type" of // P8001134
                ItemLedgerEntry."Order Type"::FOODSalesRepack:
                    EntryType := ItemLedgerEntry."Entry Type"::Sale; // P8001134
                ItemLedgerEntry."Order Type"::FOODRepack:
                    EntryType := ItemLedgerEntry."Entry Type"::Consumption;  // P8001134
            end;
        if ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Transfer then
            if (ItemLedgerEntry."Order No." = '') and (ItemLedgerEntry."Order Type" <> ItemLedgerEntry."Order Type"::FOODRepack) then // P8001134
                EntryType := -1;

        LotStatus.Get(LotNoInfo."Lot Status Code");
        case EntryType of
            ItemLedgerEntry."Entry Type"::Sale:
                if not LotStatus."Available for Sale" then
                    Error(Text001, LotStatus.Code, Text002, LotNoInfo."Item No.", LotNoInfo."Lot No.");
            ItemLedgerEntry."Entry Type"::Purchase:
                if not LotStatus."Available for Purchase" then
                    Error(Text001, LotStatus.Code, Text003, LotNoInfo."Item No.", LotNoInfo."Lot No.");               // P80059064
            ItemLedgerEntry."Entry Type"::Transfer:
                if not LotStatus."Available for Transfer" then
                    Error(Text001, LotStatus.Code, Text004, LotNoInfo."Item No.", LotNoInfo."Lot No.");               // P80059064
            ItemLedgerEntry."Entry Type"::Consumption, ItemLedgerEntry."Entry Type"::"Assembly Consumption": // P8001132
                if not LotStatus."Available for Consumption" then
                    Error(Text001, LotStatus.Code, Text005, LotNoInfo."Item No.", LotNoInfo."Lot No.");               // P80059064
            ItemLedgerEntry."Entry Type"::"Negative Adjmt.":
                if not LotStatus."Available for Adjustment" then
                    Error(Text001, LotStatus.Code, Text006, LotNoInfo."Item No.", LotNoInfo."Lot No.");               // P80059064
        end;

        InvSetup.Get;
        if LotStatus.Code = InvSetup."Quarantine Lot Status" then begin
            TestRelease :=
              ((EntryType = ItemLedgerEntry."Entry Type"::Sale) and (not LotStatus."Available for Sale")) or
              ((EntryType = ItemLedgerEntry."Entry Type"::Purchase) and (not LotStatus."Available for Purchase")) or
              ((EntryType = ItemLedgerEntry."Entry Type"::Transfer) and (not LotStatus."Available for Transfer")) or
              ((EntryType = ItemLedgerEntry."Entry Type"::Consumption) and (not LotStatus."Available for Consumption")) or
              ((EntryType = ItemLedgerEntry."Entry Type"::"Negative Adjmt.") and (not LotStatus."Available for Adjustment"));
            if TestRelease and (LotNoInfo."Release Date" = 0D) or (ItemLedgerEntry."Posting Date" < LotNoInfo."Release Date") then
                LotNoInfo.FieldError("Release Date", Text007);
        end;
    end;

    procedure GetQCStatus(var Item: Record Item): Code[10]
    var
        InvSetup: Record "Inventory Setup";
        DataCollectionLine: Record "Data Collection Line";
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        // P8001090
        DataCollectionLine.SetRange("Source ID", DATABASE::Item);
        //ItemQualityTest.SETRANGE("Item No.",Item."No.");
        DataCollectionLine.SetRange("Source Key 1", Item."No.");
        DataCollectionLine.SetRange(Type, DataCollectionLine.Type::"Q/C");
        // P8001090
        if not DataCollectionLine.IsEmpty then begin // P8001090
            InvSetup.Get;
            ItemTrackingCode.Get(Item."Item Tracking Code");
            if ItemTrackingCode."Strict Quarantine Posting" and (Format(Item."Quarantine Calculation") <> '') then
                exit(InvSetup."Quarantine Lot Status")
            else
                exit(InvSetup."Quality Control Lot Status");
        end;
    end;

    procedure SetInboundExclusions(Item: Record Item; AvailFldNo: Integer; var ExcludePurch: Boolean; var ExcludeSalesRet: Boolean; var ExcludeOutput: Boolean)
    var
        InvSetup: Record "Inventory Setup";
        LotStatus: Record "Lot Status Code";
        LotStatusRecRef: RecordRef;
        AvailFld: FieldRef;
        QCStatus: Code[10];
    begin
        ExcludePurch := false;
        ExcludeSalesRet := false;
        ExcludeOutput := false;

        if (Item."Item Tracking Code" = '') or (AvailFldNo = 0) then
            exit;

        QCStatus := GetQCStatus(Item);
        if QCStatus <> '' then begin
            LotStatus.Get(QCStatus);
            LotStatusRecRef.GetTable(LotStatus);
            AvailFld := LotStatusRecRef.Field(AvailFldNo);
            ExcludePurch := AvailFld.Value;
            ExcludePurch := not ExcludePurch;
            ExcludeSalesRet := ExcludePurch;
            ExcludeOutput := ExcludePurch;
        end else begin
            InvSetup.Get;

            LotStatus.Get(InvSetup."Purchase Lot Status");
            LotStatusRecRef.GetTable(LotStatus);
            AvailFld := LotStatusRecRef.Field(AvailFldNo);
            ExcludePurch := AvailFld.Value;
            ExcludePurch := not ExcludePurch;

            LotStatus.Get(InvSetup."Sales Lot Status");
            LotStatusRecRef.GetTable(LotStatus);
            AvailFld := LotStatusRecRef.Field(AvailFldNo);
            ExcludeSalesRet := AvailFld.Value;
            ExcludeSalesRet := not ExcludeSalesRet;

            LotStatus.Get(InvSetup."Output Lot Status");
            LotStatusRecRef.GetTable(LotStatus);
            AvailFld := LotStatusRecRef.Field(AvailFldNo);
            ExcludeOutput := AvailFld.Value;
            ExcludeOutput := not ExcludeOutput;
        end;
    end;

    procedure SetLotStatusExclusionFilter(AvailForFldNo: Integer) ExclusionFilter: Text[1024]
    var
        LotStatus: Record "Lot Status Code";
        LotStatus2: Record "Lot Status Code";
    begin
        if AvailForFldNo = 0 then
            exit;

        case AvailForFldNo of
            LotStatus.FieldNo("Available for Sale"):
                LotStatus2.SetRange("Available for Sale", true);
            LotStatus.FieldNo("Available for Purchase"):
                LotStatus2.SetRange("Available for Purchase", true);
            LotStatus.FieldNo("Available for Transfer"):
                LotStatus2.SetRange("Available for Transfer", true);
            LotStatus.FieldNo("Available for Consumption"):
                LotStatus2.SetRange("Available for Consumption", true);
            LotStatus.FieldNo("Available for Adjustment"):
                LotStatus2.SetRange("Available for Adjustment", true);
            LotStatus.FieldNo("Available for Planning"):
                LotStatus2.SetRange("Available for Planning", true);
        end;

        LotStatus.FindSet;
        repeat
            LotStatus2.Code := LotStatus.Code;
            if not LotStatus2.Find then
                ExclusionFilter := ExclusionFilter + '|' + LotStatus.Code;
        until LotStatus.Next = 0;
        ExclusionFilter := CopyStr(ExclusionFilter, 2);
    end;

    procedure AdjustItemFlowFields(var Item: Record Item; LotStatusExclusionFilter: Text[1024]; CalcInventory: Boolean; CalcTransfer: Boolean; FieldType: Option Regular,Reserved,Both; ExcludePurch: Boolean; ExcludeSalesRet: Boolean; ExcludeOutput: Boolean)
    var
        TransLine: Record "Transfer Line";
    begin
        if Item."Item Tracking Code" = '' then
            exit;

        if CalcInventory and (LotStatusExclusionFilter <> '') then begin
            if FieldType in [FieldType::Regular, FieldType::Both] then
                QuantityAdjforItem(Item, LotStatusExclusionFilter, Item.Inventory, Item."Quantity on Hand (Alt.)");
            if FieldType in [FieldType::Reserved, FieldType::Both] then
                QuantityAdjForReservedOnInv(Item, LotStatusExclusionFilter, Item."Reserved Qty. on Inventory");
        end;

        if ExcludePurch then begin
            if FieldType in [FieldType::Regular, FieldType::Both] then begin
                Item."Qty. on Purch. Order" := 0;
                Item."Purch. Req. Receipt (Qty.)" := 0;
                Item."Purch. Req. Release (Qty.)" := 0;
            end;
            if FieldType in [FieldType::Reserved, FieldType::Both] then begin
                Item."Reserved Qty. on Purch. Orders" := 0;
                Item."Res. Qty. on Req. Line" := 0;
            end;
        end;

        // P8001352
        if ExcludeSalesRet then begin
            if FieldType in [FieldType::Regular, FieldType::Both] then
                Item."Qty. on Sales Return" := 0;
            if FieldType in [FieldType::Reserved, FieldType::Both] then
                Item."Res. Qty. on Sales Returns" := 0;
        end;
        // P8001352

        if ExcludeOutput then begin
            if FieldType in [FieldType::Regular, FieldType::Both] then begin
                Item."Scheduled Receipt (Qty.)" := 0;
                Item."Qty. on Repack" := 0;
                Item."Planning Receipt (Qty.)" := 0;
                Item."Planned Order Receipt (Qty.)" := 0;
                Item."FP Order Receipt (Qty.)" := 0;
                Item."Rel. Order Receipt (Qty.)" := 0;
                Item."Planning Release (Qty.)" := 0; // P8001352
                Item."Planned Order Release (Qty.)" := 0;
                Item."Qty. on Prod. Order" := 0;
                Item."Qty. on Assembly Order" := 0; // P8001132
            end;
            if FieldType in [FieldType::Reserved, FieldType::Both] then begin // P8001132
                Item."Reserved Qty. on Prod. Order" := 0;
                Item."Res. Qty. on Assembly Order" := 0;                        // P8001132
            end;                                                              // P8001132
        end;

        if CalcTransfer and (Item."Item Tracking Code" <> '') and (LotStatusExclusionFilter <> '') then begin
            if FieldType in [FieldType::Regular, FieldType::Both] then begin
                TransLine.SetCurrentKey("Item No.");
                TransLine.SetRange("Item No.", Item."No.");
                TransLine.SetRange("Derived From Line No.", 0);
                Item.CopyFilter("Location Filter", TransLine."Transfer-to Code");
                Item.CopyFilter("Variant Filter", TransLine."Variant Code");
                Item.CopyFilter("Global Dimension 1 Filter", TransLine."Shortcut Dimension 1 Code");
                Item.CopyFilter("Global Dimension 2 Filter", TransLine."Shortcut Dimension 2 Code");
                Item.CopyFilter("Date Filter", TransLine."Receipt Date");

                QuantityAdjForTransfer(TransLine, LotStatusExclusionFilter, Item."Trans. Ord. Receipt (Qty.)", Item."Qty. in Transit");
            end;
        end;
    end;

    procedure ItemAvailabilityContext(Context: Code[12]): Integer
    begin
        case Context of
            '':
                exit(AvailableFor::" ");
            'SALE':
                exit(AvailableFor::Sale);
            'PURCHASE':
                exit(AvailableFor::"Purchase Return");
            'TRANSFER':
                exit(AvailableFor::Transfer);
            'CONSUMPTION':
                exit(AvailableFor::Consumption);
            'ADJUSTMENT':
                exit(AvailableFor::Adjustment);
            'PLANNING':
                exit(AvailableFor::Planning);
        end;
    end;

    procedure AvailableForToFieldNo(AvailFor: Integer): Integer
    var
        LotStatus: Record "Lot Status Code";
    begin
        case AvailFor of
            AvailableFor::" ":
                exit(0);
            AvailableFor::Sale:
                exit(LotStatus.FieldNo("Available for Sale"));
            AvailableFor::"Purchase Return":
                exit(LotStatus.FieldNo("Available for Purchase"));
            AvailableFor::Transfer:
                exit(LotStatus.FieldNo("Available for Transfer"));
            AvailableFor::Consumption:
                exit(LotStatus.FieldNo("Available for Consumption"));
            AvailableFor::Adjustment:
                exit(LotStatus.FieldNo("Available for Adjustment"));
            AvailableFor::Planning:
                exit(LotStatus.FieldNo("Available for Planning"));
        end;
    end;

    procedure AvailableForFieldNoToActionText(AvailForFieldNo: Integer): Text
    var
        LotStatusCode: Record "Lot Status Code";
    begin
        // P80045713
        case AvailForFieldNo of
            LotStatusCode.FieldNo("Available for Sale"):
                exit(Text002);
            LotStatusCode.FieldNo("Available for Purchase"):
                exit(Text003);
            LotStatusCode.FieldNo("Available for Transfer"):
                exit(Text004);
            LotStatusCode.FieldNo("Available for Consumption"):
                exit(Text005);
            LotStatusCode.FieldNo("Available for Adjustment"):
                exit(Text006);
        end;
    end;

    procedure ItemJnlLineToFieldNo(ItemJnlLine: Record "Item Journal Line"): Integer
    var
        LotStatus: Record "Lot Status Code";
    begin
        case ItemJnlLine."Entry Type" of
            ItemJnlLine."Entry Type"::Sale:
                if ItemJnlLine.Quantity > 0 then
                    exit(LotStatus.FieldNo("Available for Sale"));
            ItemJnlLine."Entry Type"::Purchase:
                if ItemJnlLine.Quantity < 0 then
                    exit(LotStatus.FieldNo("Available for Purchase"));
            ItemJnlLine."Entry Type"::"Negative Adjmt.":
                exit(LotStatus.FieldNo("Available for Adjustment"));
            ItemJnlLine."Entry Type"::Consumption:
                exit(LotStatus.FieldNo("Available for Consumption"));
            ItemJnlLine."Entry Type"::"Assembly Consumption":
                exit(LotStatus.FieldNo("Available for Consumption")); // P8001132
        end;
    end;

    procedure TrackingSpecToFieldNo(TrackingSpec: Record "Tracking Specification"): Integer
    var
        ItemJnlLine: Record "Item Journal Line";
        LotStatus: Record "Lot Status Code";
    begin
        if TrackingSpec.Positive then
            exit(0);
        case TrackingSpec."Source Type" of
            DATABASE::"Sales Line":
                exit(LotStatus.FieldNo("Available for Sale"));
            DATABASE::"Purchase Line":
                exit(LotStatus.FieldNo("Available for Sale"));
            DATABASE::"Item Journal Line":
                case TrackingSpec."Source Subtype" of
                    ItemJnlLine."Entry Type"::Sale:
                        exit(LotStatus.FieldNo("Available for Sale"));
                    ItemJnlLine."Entry Type"::Purchase:
                        exit(LotStatus.FieldNo("Available for Purchase"));
                    ItemJnlLine."Entry Type"::"Negative Adjmt.":
                        exit(LotStatus.FieldNo("Available for Adjustment"));
                    ItemJnlLine."Entry Type"::Consumption:
                        exit(LotStatus.FieldNo("Available for Consumption"));
                    ItemJnlLine."Entry Type"::"Assembly Consumption":
                        exit(LotStatus.FieldNo("Available for Consumption")); // P8001132
                end;
            DATABASE::"Prod. Order Component":
                exit(LotStatus.FieldNo("Available for Consumption"));
            DATABASE::"Assembly Line":
                exit(LotStatus.FieldNo("Available for Consumption")); // P8001132
            DATABASE::"Transfer Line":
                exit(LotStatus.FieldNo("Available for Transfer"));
        end;
    end;

    procedure QuantityAdjforItem(var Item: Record Item; LotStatusExclusionFilter: Text[1024]; var Quantity: Decimal; var QuantityAlt: Decimal): Decimal
    var
        ItemStatus: Record "Item Status Entry";
    begin
        if (Item."Item Tracking Code" = '') or (LotStatusExclusionFilter = '') then
            exit;

        ItemStatus.SetRange("Item No.", Item."No.");
        Item.CopyFilter("Variant Filter", ItemStatus."Variant Code");
        Item.CopyFilter("Location Filter", ItemStatus."Location Code");
        ItemStatus.SetFilter("Lot Status Code", LotStatusExclusionFilter);
        ItemStatus.CalcSums(Quantity, "Quantity (Alt.)");
        Quantity -= ItemStatus.Quantity;
        QuantityAlt -= ItemStatus."Quantity (Alt.)";
    end;

    procedure QuantityAdjForItemLedger(var ItemLedgerEntry: Record "Item Ledger Entry"; LotStatusExclusionFilter: Text[1024]; var Quantity: Decimal)
    var
        Item: Record Item;
        ItemStatus: Record "Item Status Entry";
    begin
        if LotStatusExclusionFilter = '' then
            exit;
        Item.Get(ItemLedgerEntry.GetFilter("Item No."));
        if Item."Item Tracking Code" = '' then
            exit;

        ItemLedgerEntry.CopyFilter("Item No.", ItemStatus."Item No.");
        ItemLedgerEntry.CopyFilter("Variant Code", ItemStatus."Variant Code");
        ItemLedgerEntry.CopyFilter("Location Code", ItemStatus."Location Code");
        ItemStatus.SetFilter("Lot Status Code", LotStatusExclusionFilter);
        ItemStatus.CalcSums(Quantity);
        Quantity -= ItemStatus.Quantity;
    end;

    procedure QuantityAdjForTransfer(var TransLine: Record "Transfer Line"; LotStatusExclusionFilter: Text[1024]; var OutstandingQty: Decimal; var QtyInTransit: Decimal)
    var
        TransLine2: Record "Transfer Line";
        ResEntry: Record "Reservation Entry";
    begin
        if LotStatusExclusionFilter = '' then
            exit;

        TransLine2.Copy(TransLine);
        ResEntry.SetCurrentKey("Source Type", "Item No.", "Variant Code", "Lot No.");
        ResEntry.SetRange("Source Type", DATABASE::"Transfer Line");
        ResEntry.SetRange("Source Subtype", 1);
        TransLine2.CopyFilter("Item No.", ResEntry."Item No.");
        TransLine2.CopyFilter("Variant Code", ResEntry."Variant Code");
        ResEntry.SetFilter("Lot No.", '<>%1', '');

        if TransLine2.FindSet then
            repeat
                ResEntry.SetRange("Source ID", TransLine2."Document No.");
                if ResEntry.Find('-') then
                    repeat
                        ResEntry.SetRange("Variant Code", ResEntry."Variant Code");
                        ResEntry.SetRange("Lot No.", ResEntry."Lot No.");
                        if ExcludeLot(ResEntry."Item No.", ResEntry."Variant Code", ResEntry."Lot No.", LotStatusExclusionFilter) then
                            repeat
                                if ResEntry."Source Prod. Order Line" = TransLine2."Line No." then
                                    QtyInTransit -= ResEntry."Quantity (Base)";
                                if (ResEntry."Source Prod. Order Line" = 0) and (ResEntry."Source Ref. No." = TransLine2."Line No.") then
                                    OutstandingQty -= ResEntry."Quantity (Base)";
                            until ResEntry.Next = 0;

                        ResEntry.Find('+');
                        TransLine2.CopyFilter("Variant Code", ResEntry."Variant Code");
                        ResEntry.SetFilter("Lot No.", '<>%1', '');
                    until ResEntry.Next = 0;
            until TransLine2.Next = 0;
    end;

    procedure QuantityAdjForTransferLine(var TransLine: Record "Transfer Line"; LotStatusExclusionfilter: Text[1024])
    var
        ResEntry: Record "Reservation Entry";
    begin
        if LotStatusExclusionfilter = '' then
            exit;

        ResEntry.SetCurrentKey("Source Type", "Source ID", "Source Batch Name", "Source Ref. No.", "Lot No.");
        ResEntry.SetRange("Source Type", DATABASE::"Transfer Line");
        ResEntry.SetRange("Source ID", TransLine."Document No.");
        if TransLine."Derived From Line No." = 0 then
            ResEntry.SetFilter("Source Prod. Order Line", '%1|%2', 0, TransLine."Line No.")
        else begin
            ResEntry.SetRange("Source Ref. No.", TransLine."Line No.");
            ResEntry.SetRange("Source Prod. Order Line", TransLine."Derived From Line No.");
        end;
        ResEntry.SetFilter("Lot No.", '<>%1', '');

        if ResEntry.Find('-') then
            repeat
                ResEntry.SetRange("Variant Code", ResEntry."Variant Code");
                ResEntry.SetRange("Lot No.", ResEntry."Lot No.");
                if ExcludeLot(ResEntry."Item No.", ResEntry."Variant Code", ResEntry."Lot No.", LotStatusExclusionfilter) then
                    repeat
                        if (ResEntry."Source Subtype" = 1) and (ResEntry."Source Ref. No." = TransLine."Line No.") then
                            TransLine."Outstanding Qty. (Base)" -= ResEntry."Quantity (Base)";
                        if ResEntry."Source Prod. Order Line" = TransLine."Line No." then
                            TransLine."Qty. in Transit (Base)" -= ResEntry."Quantity (Base)";
                        if (ResEntry."Reservation Status" = ResEntry."Reservation Status"::Reservation) and
                           (ResEntry."Source Ref. No." = TransLine."Line No.") and
                           (ResEntry."Source Prod. Order Line" = TransLine."Derived From Line No.")
                        then
                            if ResEntry."Source Subtype" = 1 then
                                TransLine."Reserved Qty. Inbnd. (Base)" -= ResEntry."Quantity (Base)"
                            else
                                TransLine."Reserved Qty. Outbnd. (Base)" += ResEntry."Quantity (Base)";
                    until ResEntry.Next = 0;

                ResEntry.Find('+');
                TransLine.CopyFilter("Variant Code", ResEntry."Variant Code");
                ResEntry.SetFilter("Lot No.", '<>%1', '');
            until ResEntry.Next = 0;

        TransLine."Qty. Shipped (Base)" := TransLine."Qty. Received (Base)" + TransLine."Qty. in Transit (Base)";
        TransLine."Quantity (Base)" := TransLine."Outstanding Qty. (Base)" + TransLine."Qty. Shipped (Base)";

        TransLine.Quantity := Round(TransLine."Quantity (Base)" / TransLine."Qty. per Unit of Measure", 0.00001);
        TransLine."Outstanding Quantity" := Round(TransLine."Outstanding Qty. (Base)" / TransLine."Qty. per Unit of Measure", 0.00001);
        TransLine."Quantity Shipped" := Round(TransLine."Qty. Shipped (Base)" / TransLine."Qty. per Unit of Measure", 0.00001);
        TransLine."Quantity Received" := Round(TransLine."Qty. Received (Base)" / TransLine."Qty. per Unit of Measure", 0.00001);
        TransLine."Qty. in Transit" := Round(TransLine."Qty. in Transit (Base)" / TransLine."Qty. per Unit of Measure", 0.00001);
        TransLine."Reserved Quantity Inbnd." :=
          Round(TransLine."Reserved Qty. Inbnd. (Base)" / TransLine."Qty. per Unit of Measure", 0.00001);
        TransLine."Reserved Quantity Outbnd." :=
          Round(TransLine."Reserved Qty. Outbnd. (Base)" / TransLine."Qty. per Unit of Measure", 0.00001);
    end;

    procedure QuantityAdjForReservedOnInv(var Item: Record Item; LotStatusExclusionFilter: Text[1024]; var Quantity: Decimal)
    var
        ResEntry: Record "Reservation Entry";
    begin
        if (Item."Item Tracking Code" = '') or (LotStatusExclusionFilter = '') then
            exit;

        ResEntry.SetCurrentKey("Source Type", "Item No.", "Variant Code", "Lot No.");
        ResEntry.SetRange("Item No.", Item."No.");
        ResEntry.SetRange("Source Type", DATABASE::"Item Ledger Entry");
        ResEntry.SetRange("Source Subtype", 0);
        ResEntry.SetRange("Reservation Status", ResEntry."Reservation Status"::Reservation);
        Item.CopyFilter("Location Filter", ResEntry."Location Code");
        Item.CopyFilter("Variant Filter", ResEntry."Variant Code");
        ResEntry.SetFilter("Lot No.", '<>%1', '');

        if ResEntry.Find('-') then
            repeat
                ResEntry.SetRange("Variant Code", ResEntry."Variant Code");
                ResEntry.SetRange("Lot No.", ResEntry."Lot No.");
                if ExcludeLot(ResEntry."Item No.", ResEntry."Variant Code", ResEntry."Lot No.", LotStatusExclusionFilter) then
                    repeat
                        Quantity -= ResEntry."Quantity (Base)";
                    until ResEntry.Next = 0;

                ResEntry.Find('+');
                Item.CopyFilter("Variant Filter", ResEntry."Variant Code");
                ResEntry.SetFilter("Lot No.", '<>%1', '');
            until ResEntry.Next = 0;
    end;

    procedure QuantityAdjForBinContent(var BinContent: Record "Bin Content"; LotStatusExclusionFilter: Text[1024]; var Quantity: Decimal)
    var
        Item: Record Item;
        WhseEntry: Record "Warehouse Entry";
        LotNoFilter: Text[50];
    begin
        if LotStatusExclusionFilter = '' then
            exit;
        Item.Get(BinContent."Item No.");
        if Item."Item Tracking Code" = '' then
            exit;

        WhseEntry.SetCurrentKey("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code", Open, "Lot No.");
        WhseEntry.SetRange("Location Code", BinContent."Location Code");
        WhseEntry.SetRange("Bin Code", BinContent."Bin Code");
        WhseEntry.SetRange("Item No.", BinContent."Item No.");
        WhseEntry.SetRange("Variant Code", BinContent."Variant Code");
        WhseEntry.SetRange("Unit of Measure Code", BinContent."Unit of Measure Code");
        WhseEntry.SetRange(Open, true); // P80082286
        LotNoFilter := BinContent.GetFilter("Lot No. Filter");
        if LotNoFilter = '' then
            LotNoFilter := '<>''''';
        WhseEntry.SetFilter("Lot No.", LotNoFilter);
        if WhseEntry.Find('-') then
            repeat
                WhseEntry.SetRange("Lot No.", WhseEntry."Lot No.");
                if ExcludeLot(WhseEntry."Item No.", WhseEntry."Variant Code", WhseEntry."Lot No.", LotStatusExclusionFilter) then begin
                    WhseEntry.CalcSums("Remaining Qty. (Base)");
                    Quantity -= WhseEntry."Remaining Qty. (Base)";
                end;
                WhseEntry.Find('+');
                WhseEntry.SetFilter("Lot No.", LotNoFilter);
            until WhseEntry.Next = 0;
    end;

    procedure QuantityAdjForWhseEntry(var WhseEntry: Record "Warehouse Entry"; LotStatusExclusionFilter: Text[1024]; var Quantity: Decimal)
    var
        WhseEntry2: Record "Warehouse Entry";
    begin
        if LotStatusExclusionFilter = '' then
            exit;

        WhseEntry2.SetCurrentKey("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code", Open, "Lot No.");
        WhseEntry.CopyFilter("Location Code", WhseEntry2."Location Code");
        WhseEntry.CopyFilter("Bin Code", WhseEntry2."Bin Code");
        WhseEntry.CopyFilter("Item No.", WhseEntry2."Item No.");
        WhseEntry.CopyFilter("Variant Code", WhseEntry2."Variant Code");
        WhseEntry.CopyFilter("Unit of Measure Code", WhseEntry2."Unit of Measure Code");
        WhseEntry.CopyFilter("Lot No.", WhseEntry2."Lot No.");
        if WhseEntry2.Find('-') then
            repeat
                WhseEntry2.SetRange("Lot No.", WhseEntry2."Lot No.");
                if ExcludeLot(WhseEntry2."Item No.", WhseEntry2."Variant Code", WhseEntry2."Lot No.", LotStatusExclusionFilter) then begin
                    WhseEntry2.CalcSums("Remaining Qty. (Base)");
                    Quantity -= WhseEntry2."Remaining Qty. (Base)";
                end;
                WhseEntry2.Find('+');
                WhseEntry.CopyFilter("Lot No.", WhseEntry2."Lot No.");
            until WhseEntry2.Next = 0;
    end;

    procedure AdjustQuickPlannerFlowFields(var QuickPlanner: Record "Quick Planner Worksheet"; LotStatusExclusionFilter: Text[1024]; CalcOnHand: Boolean; CalcTransfer: Boolean; ExcludePurch: Boolean; ExcludeSalesRet: Boolean; ExcludeOutput: Boolean)
    var
        Item: Record Item;
        ItemStatus: Record "Item Status Entry";
        TransLine: Record "Transfer Line";
    begin
        Item.Get(QuickPlanner."Item No.");
        if Item."Item Tracking Code" = '' then
            exit;

        if CalcOnHand and (LotStatusExclusionFilter <> '') then begin
            ItemStatus.SetRange("Item No.", QuickPlanner."Item No.");
            ItemStatus.SetRange("Variant Code", QuickPlanner."Variant Code");
            QuickPlanner.CopyFilter("Location Filter", ItemStatus."Location Code");
            ItemStatus.SetFilter("Lot Status Code", LotStatusExclusionFilter);
            ItemStatus.CalcSums(Quantity);
            QuickPlanner."On Hand" -= ItemStatus.Quantity;
        end;

        if ExcludePurch then
            QuickPlanner."Qty. on Purchase Order" := 0;

        if ExcludeOutput then
            QuickPlanner."Qty. on Production Order" := 0;

        if CalcTransfer and (LotStatusExclusionFilter <> '') then begin
            TransLine.SetCurrentKey("Item No.");
            TransLine.SetRange("Item No.", QuickPlanner."Item No.");
            TransLine.SetRange("Derived From Line No.", 0);
            QuickPlanner.CopyFilter("Location Filter", TransLine."Transfer-to Code");
            TransLine.SetRange("Variant Code", QuickPlanner."Variant Code");
            TransLine.SetRange("Receipt Date", 0D, QuickPlanner.GetRangeMax("Date Filter"));

            QuantityAdjForTransfer(TransLine, LotStatusExclusionFilter,
              QuickPlanner."Qty. on Transfer (Outstanding)", QuickPlanner."Qty. on Transfer (In-Transit)");
        end;
    end;

    procedure GetLotStatus(ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50]; ExclusionFilter: Text[1024]; var LotStatusCode: Code[10]; var Excluded: Boolean)
    var
        LotInfo: Record "Lot No. Information";
    begin
        LotStatusCode := '';
        Excluded := false;

        if LotNo = '' then
            exit;
        if not LotInfo.Get(ItemNo, VariantCode, LotNo) then
            exit;

        LotStatusCode := LotInfo."Lot Status Code";
        Excluded := ExcludeLotInfo(LotInfo, ExclusionFilter);
    end;

    procedure ExcludeLot(ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50]; ExclusionFilter: Text[1024]): Boolean
    var
        LotInfo: Record "Lot No. Information";
    begin
        if (LotNo = '') or (ExclusionFilter = '') then
            exit(false);
        if not LotInfo.Get(ItemNo, VariantCode, LotNo) then
            exit(false);

        exit(ExcludeLotInfo(LotInfo, ExclusionFilter));
    end;

    procedure ExcludeLotInfo(LotInfo: Record "Lot No. Information"; ExclusionFilter: Text[1024]): Boolean
    var
        LotStatus: Record "Lot Status Code";
    begin
        if (LotInfo."Lot Status Code" = '') or (ExclusionFilter = '') then
            exit(false);

        LotStatus.SetFilter(Code, ExclusionFilter);
        LotStatus.Code := LotInfo."Lot Status Code";
        exit(LotStatus.Find);
    end;

    procedure TrackingSpecBlocked(TrackingSpec: Record "Tracking Specification"): Boolean
    begin
        exit(ExcludeLot(TrackingSpec."Item No.", TrackingSpec."Variant Code", TrackingSpec."Lot No.",
          SetLotStatusExclusionFilter(TrackingSpecToFieldNo(TrackingSpec))));
    end;

    procedure ChangeLotStatusForContainer(var ContainerHeader: Record "Container Header")
    var
        InvSetup: Record "Inventory Setup";
        ContainerLine: Record "Container Line";
        ContainerLineTemp: Record "Container Line" temporary;
        ContainerLineTemp2: Record "Container Line" temporary;
        LotInfo: Record "Lot No. Information";
        LotInfo2: Record "Lot No. Information";
        Item: Record Item;
        ChangeLotStatusPage: Page "Change Lot Status";
        RoundingAdjMgmt: Codeunit "Rounding Adjustment Mgmt.";
        P800ItemTracking: Codeunit "Process 800 Item Tracking";
        NoSeriesMgmt: Codeunit NoSeriesManagement;
        LotStatus: Code[10];
        NewLotNo: Code[50];
        LineNo: Integer;
        NearZero: Decimal;
        NewStatus: Code[10];
        DocumentNo: Code[20];
    begin
        if ChangeLotStatusPage.RunModal <> ACTION::Yes then
            exit;
        ChangeLotStatusPage.GetData(NewStatus, DocumentNo);

        InvSetup.Get;

        if ContainerHeader.FindSet then
            repeat
                ContainerLine.SetRange("Container ID", ContainerHeader.ID);
                ContainerLine.SetFilter("Lot No.", '<>%1', '');
                if ContainerLine.FindSet then
                    repeat
                        LotStatus := ContainerLine.LotStatus;
                        if LotStatus <> NewStatus then
                            if (LotStatus <> '') and (LotStatus = InvSetup."Quarantine Lot Status") then
                                Error(Text008, ContainerLine.FieldCaption("Item No."), ContainerLine."Item No.",
                                  ContainerLine.FieldCaption("Variant Code"), ContainerLine."Variant Code",
                                  ContainerLine.FieldCaption("Lot No."), ContainerLine."Lot No.")
                            else begin
                                ContainerLineTemp := ContainerLine;
                                ContainerLineTemp.Insert;
                            end;
                    until ContainerLine.Next = 0;
            until ContainerHeader.Next = 0;

        ContainerLineTemp.SetCurrentKey("Item No.", "Variant Code", "Location Code", "Bin Code", "Unit of Measure Code", "Lot No.", "Serial No.");
        ContainerLineTemp2.Copy(ContainerLineTemp, true);
        ContainerLineTemp2.SetCurrentKey("Item No.", "Variant Code", "Lot No.");

        if ContainerLineTemp2.Find('-') then
            repeat
                ContainerLineTemp2.SetRange("Item No.", ContainerLineTemp2."Item No.");
                ContainerLineTemp2.SetRange("Variant Code", ContainerLineTemp2."Variant Code");
                ContainerLineTemp2.SetRange("Lot No.", ContainerLineTemp2."Lot No.");

                ContainerLineTemp.SetRange("Item No.", ContainerLineTemp2."Item No.");
                ContainerLineTemp.SetRange("Variant Code", ContainerLineTemp2."Variant Code");
                ContainerLineTemp.SetRange("Lot No.", ContainerLineTemp2."Lot No.");
                ContainerLineTemp.CalcSums("Quantity (Base)", "Quantity (Alt.)");
                LotInfo.Get(ContainerLineTemp2."Item No.", ContainerLineTemp2."Variant Code", ContainerLineTemp2."Lot No.");
                LotInfo.CalcFields(Inventory, "Quantity (Alt.)");
                NearZero := RoundingAdjMgmt.GetNearZeroQtyForItem(ContainerLineTemp."Item No.");
                if (Abs(ContainerLineTemp."Quantity (Base)" - LotInfo.Inventory) <= NearZero) and
                   (Abs(ContainerLineTemp."Quantity (Alt.)" - LotInfo."Quantity (Alt.)") <= NearZero)
                then begin
                    ContainerLineTemp2.DeleteAll;
                    LotInfo.Mark(true);
                end;
                if ContainerLineTemp2.Find('+') then;

                ContainerLineTemp2.SetRange("Lot No.");
                ContainerLineTemp2.SetRange("Variant Code");
                ContainerLineTemp2.SetRange("Item No.");
            until ContainerLineTemp2.Next = 0;

        ContainerLineTemp2.Reset;

        if ContainerLineTemp2.Find('-') then
            repeat
                ContainerLineTemp2.SetRange("Item No.", ContainerLineTemp2."Item No.");
                ContainerLineTemp2.SetRange("Variant Code", ContainerLineTemp2."Variant Code");
                ContainerLineTemp2.SetRange("Lot No.", ContainerLineTemp2."Lot No.");

                NewLotNo := StrSubstNo('%1-%2', ContainerLineTemp2."Lot No.", P800ItemTracking.GetUniqueSegmentNo(ContainerLineTemp2."Lot No.")); // P801234, P8004239
                while LotInfo.Get(ContainerLineTemp2."Item No.", ContainerLineTemp2."Variant Code", NewLotNo) do
                    NewLotNo := StrSubstNo('%1-%2', ContainerLineTemp2."Lot No.", P800ItemTracking.GetUniqueSegmentNo(ContainerLineTemp2."Lot No.")); // P801234, P8004239

                ContainerLineTemp.SetRange("Item No.", ContainerLineTemp2."Item No.");
                ContainerLineTemp.SetRange("Variant Code", ContainerLineTemp2."Variant Code");
                ContainerLineTemp.SetRange("Lot No.", ContainerLineTemp2."Lot No.");
                if ContainerLineTemp.Find('-') then
                    repeat
                        ContainerLineTemp.SetRange("Location Code", ContainerLineTemp."Location Code");
                        ContainerLineTemp.SetRange("Bin Code", ContainerLineTemp."Bin Code");
                        ContainerLineTemp.SetRange("Unit of Measure Code", ContainerLineTemp."Unit of Measure Code");
                        repeat
                            ContainerLineTemp.CalcSums(Quantity, "Quantity (Alt.)");
                            if DocumentNo = '' then
                                DocumentNo := NoSeriesMgmt.GetNextNo(InvSetup."Chg. Lot Status Document Nos.", WorkDate, true);
                            PostItemJnlReclass(ContainerLineTemp, DocumentNo, NewLotNo, NewStatus);
                            repeat
                                ContainerLine.Get(ContainerLineTemp."Container ID", ContainerLineTemp."Line No.");
                                ContainerLine."Lot No." := NewLotNo;
                                ContainerLine.Modify;
                            until ContainerLineTemp.Next = 0;
                        until ContainerLineTemp.Next = 0;
                        ContainerLineTemp.SetRange("Unit of Measure Code");
                        ContainerLineTemp.SetRange("Bin Code");
                        ContainerLineTemp.SetRange("Location Code");
                    until ContainerLineTemp.Next = 0;

                ContainerLineTemp2.Find('+');
                ContainerLineTemp2.SetRange("Lot No.");
                ContainerLineTemp2.SetRange("Variant Code");
                ContainerLineTemp2.SetRange("Item No.");
            until ContainerLineTemp2.Next = 0;

        LotInfo.MarkedOnly(true);
        if LotInfo.Find('-') then
            repeat
                LotInfo2 := LotInfo;
                LotInfo2."Lot Status Code" := NewStatus;
                ChangeLotStatus(LotInfo, LotInfo2);
                LotInfo2.Modify;
            until LotInfo.Next = 0;
    end;

    local procedure PostItemJnlReclass(ContainerLine: Record "Container Line"; DocumentNo: Code[20]; NewLotNo: Code[50]; NewLotStatus: Code[10])
    var
        ItemJnlLine, ItemJnlLine2 : Record "Item Journal Line";
        Item: Record Item;
        AltQtyLine: Record "Alternate Quantity Line";
        SourceCodeSetup: Record "Source Code Setup";
        ItemJnlTemplate: Record "Item Journal Template";
        AltQtyMgt: Codeunit "Alt. Qty. Management";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line";
        RoundingAdjmtMgmt: Codeunit "Rounding Adjustment Mgmt.";
        LotInfo: Record "Lot No. Information";
        Handled: Boolean;
    begin
        SourceCodeSetup.Get;
        Item.Get(ContainerLine."Item No.");

        ItemJnlLine.Init;
        ItemJnlLine."Posting Date" := WorkDate;
        ItemJnlLine."Document Date" := WorkDate;
        ItemJnlLine."Document No." := DocumentNo;
        ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Transfer;
        ItemJnlLine."Source Code" := SourceCodeSetup."Item Reclass. Journal";
        ItemJnlLine.Validate("Item No.", ContainerLine."Item No.");
        ItemJnlLine.Validate("Variant Code", ContainerLine."Variant Code");
        ItemJnlLine.Validate("Unit of Measure Code", ContainerLine."Unit of Measure Code");
        ItemJnlLine.Validate("Location Code", ContainerLine."Location Code");
        ItemJnlLine.Validate("New Location Code", ContainerLine."Location Code");
        ItemJnlLine.Validate("Bin Code", ContainerLine."Bin Code");
        ItemJnlLine.Validate("New Bin Code", ContainerLine."Bin Code");
        ItemJnlLine.Validate("New Lot Status Code", NewLotStatus);
        ItemJnlLine.Validate(Quantity, ContainerLine.Quantity);
        ItemJnlLine."Old Container ID" := ContainerLine."Container ID";           // P8008293
        if Item."Alternate Unit of Measure" <> '' then
            ItemJnlLine.Validate("Quantity (Alt.)", ContainerLine."Quantity (Alt.)");
        if Item."Catch Alternate Qtys." then begin
            AltQtyMgt.StartItemJnlAltQtyLine(ItemJnlLine);
            AltQtyMgt.CreateAltQtyLine(AltQtyLine, ItemJnlLine."Alt. Qty. Transaction No.",
              10000, DATABASE::"Item Journal Line", 0, '', '', '', 0);
            AltQtyLine."Lot No." := ContainerLine."Lot No.";
            AltQtyLine."New Lot No." := NewLotNo;
            AltQtyLine."Quantity (Base)" := ItemJnlLine."Quantity (Base)";
            AltQtyLine.Quantity := ItemJnlLine.Quantity;
            AltQtyLine."Quantity (Alt.)" := ContainerLine."Quantity (Alt.)";
            AltQtyLine."Invoiced Qty. (Alt.)" := ContainerLine."Quantity (Alt.)";
            AltQtyLine.Modify;
        end;
        CreateReservEntry.CreateReservEntryFor(
          DATABASE::"Item Journal Line", ItemJnlLine."Entry Type", '', '', 0, 0,
          ItemJnlLine."Qty. per Unit of Measure", ItemJnlLine.Quantity, ItemJnlLine."Quantity (Base)", // P8001132
          '', ContainerLine."Lot No.");
        ItemJnlLine2."Lot No." := NewLotNo;                            // P800144605
        CreateReservEntry.SetNewTrackingFromItemJnlLine(ItemJnlLine2); // P800144605
        // P80041970
        if ContainerLine."Lot No." <> '' then begin
            LotInfo.Get(ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ContainerLine."Lot No.");
            CreateReservEntry.SetNewExpirationDate(LotInfo."Expiration Date");
        end;
        // P80041970
        CreateReservEntry.SetNewLotStatus(NewLotStatus);
        CreateReservEntry.AddAltQtyData(-ContainerLine."Quantity (Alt.)");
        CreateReservEntry.CreateEntry(ItemJnlLine."Item No.", ItemJnlLine."Variant Code",
          ItemJnlLine."Location Code", ItemJnlLine.Description, 0D, ItemJnlLine."Posting Date", 0, 3);

        SetItemJnlDefaultDim(ItemJnlLine); // P8001133
        // P80082969
        OnPostItemJnlReclassOnBeforeRunWithCheck(ItemJnlLine, Handled);
        if not Handled then
            // P80082969
            ItemJnlPostLine.RunWithCheck(ItemJnlLine); // P8001133
        // P8008155
        //ItemJnlTemplate.Type := ItemJnlTemplate.Type::Transfer;
        //ItemJnlPostBatch.PostWhseJnlLine(ItemJnlPostLine,WhseJnlPostLine,RoundingAdjmtMgmt,ItemJnlTemplate,
        //  ItemJnlLine,ItemJnlLine.Quantity,ItemJnlLine."Quantity (Base)",ItemJnlLine."Quantity (Alt.)");
        PostWhseJnlLine(ItemJnlPostLine, WhseJnlPostLine, ItemJnlLine, ContainerLine."Container ID");   // P8008293
        // P8008155
    end;

    local procedure SetItemJnlDefaultDim(var ItemJnlLine: Record "Item Journal Line")
    begin
        // P8001133 - remove parameter for TempJnlLineDim
        ItemJnlLine."Shortcut Dimension 1 Code" := '';
        ItemJnlLine."Shortcut Dimension 2 Code" := '';
        ItemJnlLine.CreateDimFromDefaultDim(ItemJnlLine.FieldNo("Item No.")); // P800144605
        ItemJnlLine."New Shortcut Dimension 1 Code" := ItemJnlLine."Shortcut Dimension 1 Code";
        ItemJnlLine."New Shortcut Dimension 2 Code" := ItemJnlLine."Shortcut Dimension 2 Code";
        ItemJnlLine."New Dimension Set ID" := ItemJnlLine."Dimension Set ID"; // P8001133
    end;

    local procedure PostWhseJnlLine(var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line"; ItemJnlLine: Record "Item Journal Line"; FromContainerID: Code[20])
    var
        WhseJnlLine: Record "Warehouse Journal Line";
        TempWhseJnlLine2: Record "Warehouse Journal Line" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        TempHandlingSpecification: Record "Tracking Specification" temporary;
        WhseMgt: Codeunit "Whse. Management";
        Location: Record Location;
        WMSMgmt: Codeunit "WMS Management";
        Bin: Record Bin;
    begin
        with ItemJnlLine do begin
            Location.Get("Location Code");
            if Location."Bin Mandatory" then
                if WMSMgmt.CreateWhseJnlLine(ItemJnlLine, 1, WhseJnlLine, false) then begin
                    WhseJnlLine."From Bin Code" := "Bin Code";
                    Bin.Get(WhseJnlLine."Location Code", WhseJnlLine."From Bin Code");
                    WhseJnlLine."From Zone Code" := Bin."Zone Code";
                    WhseJnlLine."To Bin Code" := "Bin Code";
                    Bin.Get(WhseJnlLine."Location Code", WhseJnlLine."To Bin Code");
                    WhseJnlLine."To Zone Code" := Bin."Zone Code";
                    WhseJnlLine."New Lot No." := "New Lot No.";
                    WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::Movement;
                    WhseJnlLine."Source Type" := DATABASE::"Item Journal Line";
                    WhseJnlLine."Source Subtype" := 1;
                    WhseJnlLine."Source Document" := WhseMgt.GetSourceDocumentType(WhseJnlLine."Source Type", WhseJnlLine."Source Subtype");
                    WhseJnlLine."Source No." := "Document No.";
                    WhseJnlLine."Source Line No." := "Line No.";

                    WMSMgmt.CheckWhseJnlLine(WhseJnlLine, 1, 0, false);
                    WhseJnlPostLine.SetFromContainerID(FromContainerID);    // P8008293
                    WhseJnlPostLine.Run(WhseJnlLine);
                end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostItemJnlReclassOnBeforeRunWithCheck(var ItemJournalLine: Record "Item Journal Line"; var Handled: Boolean)
    begin
        // P80082969
    end;
}

