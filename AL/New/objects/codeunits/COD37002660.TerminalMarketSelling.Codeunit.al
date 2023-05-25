codeunit 37002660 "Terminal Market Selling"
{
    // PR3.70.03
    //   Set permission property for BOM Ledger and Register
    // 
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Whn creating lots on repack set item category code on lot
    // 
    // PR4.00.02
    // P8000307A, VerticalSoft, Jack Reynolds, 07 MAR 06
    //   Only establish item tracking for the positive entry and sale if the target item is lot tracked
    // 
    // PR4.00.03
    // P8000325A, VerticalSoft, Jack Reynolds, 01 MAY 06
    //   CreateRepackItemJnlLine - modify calls to CreateReservEntry for new parameter for expiration date
    // 
    // PR4.00.05
    // P8000413A, VerticalSoft, Jack Reynolds, 02 APR 07
    //   UpdateBOMLedger - change order of records in BOM ledger so BOM comes before Component
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 12 JUN 07
    //   Eliminate parameter for Expiration Date
    // 
    // PRW15.00.03
    // P8000624A, VerticalSoft, Jack Reynolds, 19 AUG 08
    //   When creating new lot record for the item created by the repack check country of origin requirements
    // 
    // PRW16.00.02
    // P8000797, VerticalSoft, MMAS, 31 MAR 10
    //   New methods: ChangeLine(), DeleteLine(). Moved from Terminal Market Sales Order page to be used from
    //   different subpages.
    // 
    // PRW16.00.03
    // P8000804, VerticalSoft, Jack Reynolds, 31 MAR 10
    //   Fix error with alternate quantity when changing line
    // 
    // PRW16.00.05
    // P8000944, Columbus IT, Jack Reynolds, 31 MAY 11
    //   Support for enahnced terminal market order entry
    // 
    // P8000946, Columbus IT, Jack Reynolds, 31 MAY 11
    //   Terminal Market availability by country of origin
    // 
    // P8000970, Columbus IT, Jack Reynolds, 07 NOV 11
    //   support for Terminal Market Order Confirmaton and Pick ticket
    // 
    // PRW16.00.06
    // P8000998, Columbus IT, Jack Reynolds, 21 NOV 11
    //   Fix problem with missing key when calculating item availability
    // 
    // P8001013, Columbus IT, Jack Reynolds, 06 JAN 12
    //   Fix problem with availability calculation from sales line repack
    // 
    // P8001016, Columbus IT, Jack Reynolds, 09 JAN 12
    //   Fix availability unit cost calculation for alternate quantity items
    // 
    // P8001039, Columbus IT, Jack Reynolds, 07 MAR 12
    //   Bin support for sales line repack
    // 
    // P8001041, Columbus IT, Jack Reynolds, 09 MAR 12
    //   Speed up calculation of item lot availability
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW17.00
    // P8001134, Columbus IT, Don Bresee, 16 FEB 13
    //   Add logic for handling of new "Order Type" option "Sales Repack"
    // 
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW110.0.02
    // P80050651, To-Increase, Jack Reynolds, 05 FEB 18
    //   Standard cost changes for sales repack
    // 
    // PRW111.00.02
    // P80071533, To-Increase, Jack Reynolds, 05 MAR 19
    //   Changing Sales Lines loses lot tracking
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Permissions =;

    trigger OnRun()
    begin
    end;

    var
        SalesHeader: Record "Sales Header";
        Text001: Label 'No lots available for %1 ''%2'', %3 ''%4''.';
        LotStatus: Record "Lot Status Code";
        LotStatusMgmt: Codeunit "Lot Status Management";
        LotStatusExclusionFilter: Text[1024];
        LotStatusExclusionFilterSet: Boolean;
        ExcludePurch: Boolean;
        ExcludeSalesRet: Boolean;
        ExcludeOutput: Boolean;

    procedure StartRepack(DocType: Integer; DocNo: Code[20])
    begin
        SalesHeader.Get(DocType, DocNo);
    end;

    procedure CreateRepackItemJnlLine(Mode: Option Negative,Positive; var SalesLine: Record "Sales Line"; var SalesRepack: Record "Sales Line Repack" temporary; var ItemJnlLine: Record "Item Journal Line")
    var
        ItemLedger: Record "Item Ledger Entry";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        LotNoInfo: Record "Lot No. Information";
        AltQtyLine: Record "Alternate Quantity Line";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        AltQtyMgt: Codeunit "Alt. Qty. Management";
    begin
        case Mode of
            Mode::Negative:
                begin
                    // Create Negative Adjustment to get repacked items out of inventory
                    Item.Get(SalesRepack."Repack Item No.");
                    ItemJnlLine.Init;
                    ItemJnlLine."Posting Date" := SalesHeader."Posting Date";
                    ItemJnlLine."Document Date" := SalesHeader."Document Date";
                    ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");
                    ItemJnlLine.Validate("Item No.", SalesRepack."Repack Item No.");
                    ItemJnlLine.Validate("Variant Code", SalesLine."Variant Code");
                    ItemJnlLine.Validate("Location Code", SalesRepack."Location Code");
                    ItemJnlLine.Validate("Bin Code", SalesLine."Bin Code"); // P8001039
                    ItemJnlLine.Validate(Quantity, SalesRepack."Repack Quantity");
                    ItemJnlLine."Quantity (Alt.)" := SalesRepack."Repack Quantity (Alt.)";
                    // ItemJnlLine.Repack := ItemJnlLine.Repack::Sales; // P8001083, P8001134
                    if Item."Catch Alternate Qtys." then begin
                        AltQtyMgt.AssignNewTransactionNo(ItemJnlLine."Alt. Qty. Transaction No.");
                        AltQtyMgt.CreateAltQtyLine(AltQtyLine, ItemJnlLine."Alt. Qty. Transaction No.", 10000,
                          DATABASE::"Item Journal Line", 0, '', '', '', 0);
                        AltQtyLine."Lot No." := SalesRepack."Lot No.";
                        AltQtyLine."Quantity (Base)" := ItemJnlLine."Quantity (Base)";
                        AltQtyLine."Quantity (Alt.)" := ItemJnlLine."Quantity (Alt.)";
                        AltQtyLine."Invoiced Qty. (Alt.)" := ItemJnlLine."Quantity (Alt.)";
                        AltQtyLine.Modify;
                    end;
                    if SalesRepack."Lot No." <> '' then begin
                        CreateReservEntry.CreateReservEntryFor(
                          DATABASE::"Item Journal Line", ItemJnlLine."Entry Type", '', '',
                          0, ItemJnlLine."Line No.", ItemJnlLine."Qty. per Unit of Measure", ItemJnlLine.Quantity, ItemJnlLine."Quantity (Base)", // P8001132
                          '', SalesRepack."Lot No."); // P8000325A, P8000466A
                        CreateReservEntry.AddAltQtyData(-ItemJnlLine."Quantity (Alt.)");
                        CreateReservEntry.CreateEntry(
                          ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ItemJnlLine."Location Code",
                          ItemJnlLine.Description, 0D, ItemJnlLine."Posting Date", 0, 2);
                    end;
                end;

            Mode::Positive:
                begin
                    // Create Positive Adjustment to get sold item into inventory
                    ItemLedger.Get(ItemJnlLine."Item Shpt. Entry No.");
                    //ItemLedger.CALCFIELDS("Cost Amount (Actual)"); // P80050651
                    Item.Get(SalesLine."No.");
                    if Item."Item Tracking Code" <> '' then            // P8000307A
                        ItemTrackingCode.Get(Item."Item Tracking Code"); // P8000307A
                    ItemJnlLine.Init;
                    ItemJnlLine."Posting Date" := SalesHeader."Posting Date";
                    ItemJnlLine."Document Date" := SalesHeader."Document Date";
                    ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.");
                    ItemJnlLine.Validate("Item No.", SalesLine."No.");
                    ItemJnlLine.Validate("Variant Code", SalesLine."Variant Code");
                    ItemJnlLine.Validate("Location Code", SalesRepack."Location Code");
                    ItemJnlLine.Validate("Bin Code", SalesLine."Bin Code"); // P8001039
                    ItemJnlLine.Validate(Quantity, SalesLine."Qty. to Ship (Base)");
                    ItemJnlLine."Quantity (Alt.)" := SalesRepack."Target Quantity (Alt.)";
                    if Item."Catch Alternate Qtys." then begin
                        AltQtyMgt.AssignNewTransactionNo(ItemJnlLine."Alt. Qty. Transaction No.");
                        AltQtyMgt.CreateAltQtyLine(AltQtyLine, ItemJnlLine."Alt. Qty. Transaction No.", 10000,
                          DATABASE::"Item Journal Line", 0, '', '', '', 0);
                        AltQtyLine."Lot No." := SalesRepack."Lot No.";
                        AltQtyLine."Quantity (Base)" := ItemJnlLine."Quantity (Base)";
                        AltQtyLine."Quantity (Alt.)" := ItemJnlLine."Quantity (Alt.)";
                        AltQtyLine."Invoiced Qty. (Alt.)" := ItemJnlLine."Quantity (Alt.)";
                        AltQtyLine.Modify;
                    end;
                    // P80050651
                    if Item."Costing Method" <> Item."Costing Method"::Standard then begin
                        ItemLedger.CalcFields("Cost Amount (Actual)");
                        ItemJnlLine.Validate(Amount, -ItemLedger."Cost Amount (Actual)");
                    end else
                        ItemJnlLine.Validate(Amount, Round(ItemJnlLine.GetCostingQty(ItemJnlLine.FieldNo(Quantity)) * ItemJnlLine."Unit Cost"));
                    // P80050651
                    // ItemJnlLine.Repack := ItemJnlLine.Repack::Sales; // P8001083, P8001134
                    // P8000307A - all item tracking logic moved inside of following IF ... THEN BEGIN block
                    if (SalesRepack."Lot No." <> '') and (ItemTrackingCode."Lot Specific Tracking") then begin
                        CreateReservEntry.CreateReservEntryFor(
                          DATABASE::"Item Journal Line", ItemJnlLine."Entry Type", '', '',
                          0, ItemJnlLine."Line No.", ItemJnlLine."Qty. per Unit of Measure", ItemJnlLine.Quantity, ItemJnlLine."Quantity (Base)", // P8001132
                          '', SalesRepack."Lot No."); // P8000325A, P8000466A
                        CreateReservEntry.AddAltQtyData(ItemJnlLine."Quantity (Alt.)");
                        CreateReservEntry.CreateEntry(
                          ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ItemJnlLine."Location Code",
                          ItemJnlLine.Description, ItemJnlLine."Posting Date", 0D, 0, 2);

                        if LotNoInfo.Get(SalesRepack."Repack Item No.", SalesRepack."Variant Code", SalesRepack."Lot No.") then begin
                            LotNoInfo."Item No." := SalesLine."No.";
                            LotNoInfo."Variant Code" := SalesLine."Variant Code";
                            LotNoInfo.Description := Item.Description;
                            LotNoInfo."Item Category Code" := Item."Item Category Code"; // P8000153A
                            LotNoInfo."Created From Repack" := true;
                            if LotNoInfo.Insert then
                                if Item."Country/Region of Origin Reqd." then           // P8000624A
                                    LotNoInfo.TestField("Country/Region of Origin Code"); // P8000624A
                        end;

                        CreateReservEntry.CreateReservEntryFor(
                          DATABASE::"Sales Line", SalesLine."Document Type", SalesLine."Document No.", '',
                          0, SalesLine."Line No.", SalesLine."Qty. per Unit of Measure", ItemJnlLine.Quantity, ItemJnlLine."Quantity (Base)", // P8001132
                          '', SalesRepack."Lot No."); // P8000325A, P8000466A
                        CreateReservEntry.AddAltQtyData(-SalesRepack."Target Quantity (Alt.)");
                        CreateReservEntry.CreateEntry(
                          ItemJnlLine."Item No.", ItemJnlLine."Variant Code", ItemJnlLine."Location Code",
                          ItemJnlLine.Description, 0D, ItemJnlLine."Posting Date", 0, 2);
                        if Item."Catch Alternate Qtys." then begin
                            AltQtyLine.SetRange("Alt. Qty. Transaction No.", SalesLine."Alt. Qty. Transaction No.");
                            AltQtyLine.Find('+');
                            AltQtyLine."Lot No." := SalesRepack."Lot No.";
                            AltQtyLine.Modify;
                        end;
                    end;
                    // P8000307A
                end;
        end;
    end;

    procedure FinishRepack(ItemJnlLine: Record "Item Journal Line")
    begin
    end;

    procedure GetAltQtyRepackFactor(SourceItemNo: Code[20]; SourceUOM: Code[10]; TargetUOM: Code[10]) factor: Decimal
    var
        UOM: Record "Unit of Measure";
        ItemUOM: Record "Item Unit of Measure";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
    begin
        UOM.Get(TargetUOM);
        if UOM.Type = 0 then
            exit;

        factor := P800UOMFns.GetConversionToMetricBase(SourceItemNo, SourceUOM, UOM.Type);
        factor := factor / P800UOMFns.UOMtoMetricBase(TargetUOM);
    end;

    procedure CalculateAvailability(Item: Record Item temporary; LocCode: Code[10]; ShipDate: Date; DetailLevel: Option Lot,Country,Variant; var ItemLotAvail: Record "Item Lot Availability")
    var
        ItemTracking: Record "Item Tracking Code";
        ItemTracking2: Record "Item Tracking Code";
        ItemLotAvail2: Record "Item Lot Availability" temporary;
        ItemLedger: Record "Item Ledger Entry";
        Tracking: Record "Item Lot Availability" temporary;
        PurchLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        TransLine: Record "Transfer Line";
        TransLine2: Record "Transfer Line";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        RepackOrder: Record "Repack Order";
        RepackOrderLine: Record "Repack Order Line";
        SalesLineRepack: Record "Sales Line Repack";
        Item2: Record Item;
        UnitCost: Decimal;
        CostingQty: Decimal;
        Quantity2: Decimal;
        Country: Code[10];
    begin
        // P8000944
        ItemLotAvail.Reset;
        ItemLotAvail.DeleteAll;
        Clear(ItemLotAvail);

        if Item."Item Tracking Code" <> '' then
            ItemTracking.Get(Item."Item Tracking Code");

        ItemLotAvail2."Item No." := Item."No.";

        // P8001083
        if not LotStatusExclusionFilterSet then begin
            LotStatusExclusionFilter := LotStatusMgmt.SetLotStatusExclusionFilter(LotStatus.FieldNo("Available for Sale"));
            LotStatusExclusionFilterSet := true;
        end;
        LotStatusMgmt.SetInboundExclusions(Item, LotStatus.FieldNo("Available for Sale"), ExcludePurch, ExcludeSalesRet, ExcludeOutput);
        // P8001083

        // Quantity on Hand
        ItemLedger.SetCurrentKey("Item No.", Open, "Variant Code", "Location Code", "Lot No."); // P8001041, P8007748
        ItemLedger.SetRange("Item No.", Item."No.");
        ItemLedger.SetRange(Open, true); // P8001041
        ItemLedger.SetFilter("Location Code", LocCode);
        if ItemLedger.Find('-') then
            repeat
                ItemLotAvail2.Init;
                ItemLedger.SetRange("Variant Code", ItemLedger."Variant Code");
                ItemLedger.SetRange("Lot No.", ItemLedger."Lot No.");
                ItemLotAvail2."Variant Code" := ItemLedger."Variant Code";
                ItemLotAvail2."Lot No." := ItemLedger."Lot No.";
                if ItemTracking."Lot Specific Tracking" then
                    ItemLotAvail2.GetLotInfo(ItemTracking, Item, '', '', '', '', 0D);
                if ItemLotAvail2.Include(ShipDate) and                                                                         // P8001083
                  (not LotStatusMgmt.ExcludeLot(ItemLotAvail2."Item No.", ItemLotAvail2."Variant Code", ItemLotAvail2."Lot No.", // P8001083
                    LotStatusExclusionFilter))                                                                                 // P8001083
                then begin                                                                                                     // P8001083
                    ItemLedger.CalcSums("Remaining Quantity", "Remaining Quantity (Alt.)");         // P8001041
                    ItemLotAvail2."Qty. on Hand" := ItemLedger."Remaining Quantity";               // P8001041
                    ItemLotAvail2."Qty. on Hand (Alt.)" := ItemLedger."Remaining Quantity (Alt.)"; // P8001041
                    ItemLedger.SetRange(Positive, true);
                    //ItemLedger.SETRANGE(Open,TRUE); // P8001041
                    if ItemLedger.Find('-') then
                        repeat
                            if ItemLedger.GetCostingQty <> 0 then begin
                                ItemLedger.CalcFields("Cost Amount (Actual)", "Cost Amount (Expected)");
                                ItemLotAvail2."Total Cost" += ItemLedger.GetCostingRemQty *
                                  (ItemLedger."Cost Amount (Actual)" + ItemLedger."Cost Amount (Expected)") / ItemLedger.GetCostingQty;
                                ItemLotAvail2."Cost Quantity" += ItemLedger.GetCostingRemQty;
                            end;
                        until ItemLedger.Next = 0;
                    ItemLotAvail2.Insert;
                    //ItemLedger.SETRANGE(Open); // P8001041
                    ItemLedger.SetRange(Positive);
                end;
                ItemLedger.Find('+');
                ItemLedger.SetRange("Lot No.");
                ItemLedger.SetRange("Variant Code");
            until ItemLedger.Next = 0;

        // Quantity Due in on Purchase Orders
        if not ExcludePurch then begin // P8001083
            PurchLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Expected Receipt Date");
            PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
            PurchLine.SetRange(Type, PurchLine.Type::Item);
            PurchLine.SetRange("No.", Item."No.");
            PurchLine.SetRange("Drop Shipment", false);
            PurchLine.SetFilter("Location Code", LocCode);
            PurchLine.SetRange("Expected Receipt Date", 0D, ShipDate);
            PurchLine.SetFilter("Outstanding Qty. (Base)", '>0');
            if PurchLine.FindSet then
                repeat
                    CollectTracking(Tracking, ItemTracking."Lot Specific Tracking",
                      DATABASE::"Purchase Line", PurchLine."Document Type", PurchLine."Document No.", 0, PurchLine."Line No.",
                      1, PurchLine."Outstanding Qty. (Base)", PurchLine."Country/Region of Origin Code");
                    if Tracking.Find('-') then begin
                        PurchLine.CalcFields("Extra Charge");
                        UnitCost := (PurchLine."Line Amount" + PurchLine."Extra Charge") / PurchLine.GetCostingQty;
                        repeat
                            if not ItemLotAvail2.Get(Item."No.", PurchLine."Variant Code",
                              Tracking."Lot No.", Tracking."Country/Region of Origin Code")
                            then begin
                                ItemLotAvail2.Init;
                                ItemLotAvail2."Variant Code" := PurchLine."Variant Code";
                                ItemLotAvail2."Lot No." := Tracking."Lot No.";
                                ItemLotAvail2."Country/Region of Origin Code" := Tracking."Country/Region of Origin Code";
                                if ItemTracking."Lot Specific Tracking" then
                                    ItemLotAvail2.GetLotInfo(ItemTracking, Item, PurchLine."Country/Region of Origin Code",
                                    PurchLine."Receiving Reason Code", PurchLine.Farm, PurchLine.Brand, PurchLine."Expected Receipt Date");
                                if ItemLotAvail2.Include(ShipDate) then begin
                                    if ItemLotAvail2."Lot No." <> '' then begin
                                        ItemLotAvail2."Source Type" := ItemLotAvail2."Source Type"::Purchase;
                                        ItemLotAvail2."Source Document No." := PurchLine."Document No.";
                                    end;
                                    ItemLotAvail2.Insert(true);
                                end;
                            end;
                            if ItemLotAvail2.Include(ShipDate) then begin
                                ItemLotAvail2."Qty. on Purch. Order" += Tracking."Quantity Available";
                                CostingQty := Tracking."Quantity Available" * Item.CostingQtyPerBase; // P8001016
                                ItemLotAvail2."Total Cost" += CostingQty * UnitCost;
                                ItemLotAvail2."Cost Quantity" += CostingQty;
                                ItemLotAvail2.Modify;
                            end;
                        until Tracking.Next = 0;
                    end;
                until PurchLine.Next = 0;
        end; // P8001083

        // Quantity Due in on Sales Return Orders
        if not ExcludeSalesRet then begin // P8001083
            SalesLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment"); // P8000998
            SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Return Order");
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            SalesLine.SetRange("No.", Item."No.");
            SalesLine.SetRange("Drop Shipment", false);
            SalesLine.SetFilter("Location Code", LocCode);
            SalesLine.SetRange("Receipt Date", 0D, ShipDate);
            SalesLine.SetFilter("Outstanding Quantity", '>0');
            if SalesLine.FindSet then
                repeat
                    CollectTracking(Tracking, ItemTracking."Lot Specific Tracking",
                      DATABASE::"Sales Line", SalesLine."Document Type", SalesLine."Document No.", 0, SalesLine."Line No.",
                      1, SalesLine."Outstanding Qty. (Base)", '');
                    if Tracking.Find('-') then begin
                        UnitCost := ItemLotCostAtLocation(SalesLine."No.", SalesLine."Variant Code", Tracking."Lot No.", SalesLine."Location Code");
                        repeat
                            if not ItemLotAvail2.Get(Item."No.", SalesLine."Variant Code",
                              Tracking."Lot No.", Tracking."Country/Region of Origin Code")
                            then begin
                                ItemLotAvail2.Init;
                                ItemLotAvail2."Variant Code" := SalesLine."Variant Code";
                                ItemLotAvail2."Lot No." := Tracking."Lot No.";
                                ItemLotAvail2."Country/Region of Origin Code" := Tracking."Country/Region of Origin Code";
                                if ItemTracking."Lot Specific Tracking" then
                                    ItemLotAvail2.GetLotInfo(ItemTracking, Item, '', '', '', '', SalesLine."Receipt Date");
                                if ItemLotAvail2.Include(ShipDate) then begin
                                    if ItemLotAvail2."Lot No." <> '' then begin
                                        ItemLotAvail2."Source Type" := ItemLotAvail2."Source Type"::"Sales Return";
                                        ItemLotAvail2."Source Document No." := SalesLine."Document No.";
                                    end;
                                    ItemLotAvail2.Insert(true);
                                end;
                            end;
                            if ItemLotAvail2.Include(ShipDate) then begin
                                ItemLotAvail2."Qty. on Sales Ret. Order" += Tracking."Quantity Available";
                                CostingQty := Tracking."Quantity Available" * Item.CostingQtyPerBase; // P8001016
                                ItemLotAvail2."Total Cost" += CostingQty * UnitCost;
                                ItemLotAvail2."Cost Quantity" += CostingQty;
                                ItemLotAvail2.Modify;
                            end;
                        until Tracking.Next = 0;
                    end;
                until SalesLine.Next = 0;
        end; // P8001083

        // Quantity Due in on Transfer Orders
        TransLine.SetCurrentKey("Transfer-to Code", Status, "Derived From Line No.", "Item No.", "Variant Code");
        TransLine.SetFilter("Transfer-to Code", LocCode);
        TransLine.SetRange("Item No.", Item."No.");
        TransLine.SetRange("Receipt Date", 0D, ShipDate);
        if TransLine.FindSet then
            repeat
                CollectTracking(Tracking, ItemTracking."Lot Specific Tracking",
                  DATABASE::"Transfer Line", 1, TransLine."Document No.", TransLine."Derived From Line No.", TransLine."Line No.",
                  1, TransLine."Outstanding Qty. (Base)", '');
                if Tracking.Find('-') then begin
                    if TransLine."Derived From Line No." <> 0 then
                        TransLine2.Get(TransLine."Document No.", TransLine."Derived From Line No.")
                    else
                        TransLine2 := TransLine;
                    if TransLine2.Quantity <> 0 then begin
                        TransLine2.CalcFields("Extra Charge");
                        UnitCost := TransLine2."Extra Charge" / TransLine2.GetCostingQty;
                    end else
                        UnitCost := 0;
                    UnitCost += ItemLotCostAtLocation(TransLine."Item No.", TransLine."Variant Code",
                      Tracking."Lot No.", TransLine2."Transfer-from Code");
                    repeat
                        if not ItemLotAvail2.Get(Item."No.", TransLine."Variant Code",
                          Tracking."Lot No.", Tracking."Country/Region of Origin Code")
                        then begin
                            ItemLotAvail2.Init;
                            ItemLotAvail2."Variant Code" := TransLine."Variant Code";
                            ItemLotAvail2."Lot No." := Tracking."Lot No.";
                            ItemLotAvail2."Country/Region of Origin Code" := Tracking."Country/Region of Origin Code";
                            if ItemTracking."Lot Specific Tracking" then
                                ItemLotAvail2.GetLotInfo(ItemTracking, Item, '', '', '', '', TransLine."Receipt Date");
                            if ItemLotAvail2.Include(ShipDate) then begin
                                if ItemLotAvail2."Lot No." <> '' then begin
                                    ItemLotAvail2."Source Type" := ItemLotAvail2."Source Type"::Transfer;
                                    ItemLotAvail2."Source Document No." := TransLine."Document No.";
                                end;
                                ItemLotAvail2.Insert(true);
                            end;
                        end;
                        if ItemLotAvail2.Include(ShipDate) and                                                 // P8001083
                          (not LotStatusMgmt.ExcludeLot(ItemLotAvail2."Item No.", ItemLotAvail2."Variant Code", // P8001083
                            ItemLotAvail2."Lot No.", LotStatusExclusionFilter))                                 // P8001083
                        then begin                                                                             // P8001083
                            ItemLotAvail2."Qty. on Trans. Order (In)" += Tracking."Quantity Available";
                            CostingQty := Tracking."Quantity Available" * Item.CostingQtyPerBase; // P8001016
                            ItemLotAvail2."Total Cost" += CostingQty * UnitCost;
                            ItemLotAvail2."Cost Quantity" += CostingQty;
                            ItemLotAvail2.Modify;
                        end;
                    until Tracking.Next = 0;
                end;
            until TransLine.Next = 0;

        // Quantity Due in on Production Orders
        if not ExcludeOutput then begin // P8001083
            ProdOrderLine.SetCurrentKey(Status, "Item No.", "Variant Code", "Location Code", "Due Date");
            ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Planned, ProdOrderLine.Status::Released);
            ProdOrderLine.SetRange("Item No.", Item."No.");
            ProdOrderLine.SetFilter("Location Code", LocCode);
            ProdOrderLine.SetRange("Due Date", 0D, ShipDate);
            ProdOrderLine.SetFilter("Remaining Quantity", '>0');
            if ProdOrderLine.FindSet then
                repeat
                    CollectTracking(Tracking, ItemTracking."Lot Specific Tracking",
                      DATABASE::"Prod. Order Line", ProdOrderLine.Status, ProdOrderLine."Prod. Order No.", ProdOrderLine."Line No.", 0,
                      1, ProdOrderLine."Remaining Qty. (Base)", '');
                    if Tracking.Find('-') then begin
                        UnitCost := ProdOrderLine."Cost Amount" / ProdOrderLine.GetCostingQty(ProdOrderLine.FieldNo(Quantity));
                        repeat
                            if not ItemLotAvail2.Get(Item."No.", ProdOrderLine."Variant Code",
                              Tracking."Lot No.", Tracking."Country/Region of Origin Code")
                            then begin
                                ItemLotAvail2.Init;
                                ItemLotAvail2."Variant Code" := ProdOrderLine."Variant Code";
                                ItemLotAvail2."Lot No." := Tracking."Lot No.";
                                ItemLotAvail2."Country/Region of Origin Code" := Tracking."Country/Region of Origin Code";
                                if ItemTracking."Lot Specific Tracking" then
                                    ItemLotAvail2.GetLotInfo(ItemTracking, Item, '', '', '', '', ProdOrderLine."Due Date");
                                if ItemLotAvail2.Include(ShipDate) then begin
                                    if ItemLotAvail2."Lot No." <> '' then begin
                                        ItemLotAvail2."Source Type" := ItemLotAvail2."Source Type"::Production;
                                        ItemLotAvail2."Source Status" := ProdOrderLine.Status;
                                        ItemLotAvail2."Source Document No." := ProdOrderLine."Prod. Order No.";
                                    end;
                                    ItemLotAvail2.Insert(true);
                                end;
                            end;
                            if ItemLotAvail2.Include(ShipDate) then begin
                                ItemLotAvail2."Qty. on Prod. Order (In)" += Tracking."Quantity Available";
                                CostingQty := Tracking."Quantity Available" * Item.CostingQtyPerBase; // P8001016
                                ItemLotAvail2."Total Cost" += CostingQty * UnitCost;
                                ItemLotAvail2."Cost Quantity" += CostingQty;
                                ItemLotAvail2.Modify;
                            end;
                        until Tracking.Next = 0;
                    end;
                until ProdOrderLine.Next = 0;
        end; // P8001083

        // Quantity Due in on Repack Orders
        if not ExcludeOutput then begin // P8001083
            RepackOrder.SetCurrentKey(Status, "Item No.", "Variant Code", "Destination Location", "Due Date");
            RepackOrder.SetRange(Status, RepackOrder.Status::Open);
            RepackOrder.SetRange("Item No.", Item."No.");
            RepackOrder.SetFilter("Destination Location", LocCode);
            RepackOrder.SetRange("Due Date", 0D, ShipDate);
            RepackOrder.SetFilter("Quantity to Produce", '>0');
            if RepackOrder.FindSet then begin
                repeat
                    if not ItemLotAvail2.Get(Item."No.", RepackOrder."Variant Code",
                      RepackOrder."Lot No.", RepackOrder."Country/Region of Origin Code")
                    then begin
                        ItemLotAvail2.Init;
                        ItemLotAvail2."Variant Code" := RepackOrder."Variant Code";
                        ItemLotAvail2."Lot No." := RepackOrder."Lot No.";
                        ItemLotAvail2."Country/Region of Origin Code" := RepackOrder."Country/Region of Origin Code";
                        if ItemTracking."Lot Specific Tracking" then
                            ItemLotAvail2.GetLotInfo(ItemTracking, Item, RepackOrder."Country/Region of Origin Code",
                            '', RepackOrder.Farm, RepackOrder.Brand, RepackOrder."Due Date");
                        if ItemLotAvail2.Include(ShipDate) then begin
                            if ItemLotAvail2."Lot No." <> '' then begin
                                ItemLotAvail2."Source Type" := ItemLotAvail2."Source Type"::Repack;
                                ItemLotAvail2."Source Document No." := RepackOrder."No.";
                            end;
                            ItemLotAvail2.Insert(true);
                        end;
                    end;
                    if ItemLotAvail2.Include(ShipDate) then begin
                        ItemLotAvail2."Qty. on Repack Order (In)" += RepackOrder."Quantity to Produce (Base)";
                        CostingQty := RepackOrder."Quantity to Produce (Base)" * Item.CostingQtyPerBase; // P8001016
                        ItemLotAvail2."Total Cost" += CostingQty * Item."Unit Cost";
                        ItemLotAvail2."Cost Quantity" += CostingQty;
                        ItemLotAvail2.Modify;
                    end;
                until RepackOrder.Next = 0;
            end;
        end; // P8001083

        // Quantity Due in on Sales Line Repack
        SalesLineRepack.SetCurrentKey("Target Item No.", "Variant Code", "Lot No.", "Location Code");
        SalesLineRepack.SetRange("Target Item No.", Item."No.");
        SalesLineRepack.SetFilter("Location Code", LocCode);
        if SalesLineRepack.FindSet then
            repeat
                //    SalesLine.GET(SalesLineRepack."Document Type",SalesLineRepack."Document No.",SalesLineRepack."Line No."); // P8001013
                //    IF SalesLine."Shipment Date" <= ShipDate THEN BEGIN                                                       // P8001013
                if not ItemLotAvail2.Get(Item."No.", SalesLineRepack."Variant Code", SalesLineRepack."Lot No.")
                then begin
                    ItemLotAvail2.Init;
                    ItemLotAvail2."Variant Code" := SalesLineRepack."Variant Code";
                    ItemLotAvail2."Lot No." := SalesLineRepack."Lot No.";
                    if ItemTracking."Lot Specific Tracking" then begin
                        Item2.Get(SalesLineRepack."Repack Item No.");
                        if ItemTracking2.Get(Item2."Item Tracking Code") then
                            ItemLotAvail2.GetLotInfo(ItemTracking2, Item2, '', '', '', '', SalesLine."Shipment Date");
                    end;
                    if ItemLotAvail2.Include(ShipDate) then
                        ItemLotAvail2.Insert(true);
                end;
                if ItemLotAvail2.Include(ShipDate) then begin
                    ItemLotAvail2."Qty. on Line Repack (In)" += SalesLineRepack."Target Quantity";
                    ItemLotAvail2.Modify;
                end;
                //    END; // P8001013
            until SalesLineRepack.Next = 0;

        // Quantity Due out on Purchase Return Orders
        PurchLine.Reset;
        PurchLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Expected Receipt Date");
        PurchLine.SetRange("Document Type", PurchLine."Document Type"::"Return Order");
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        PurchLine.SetRange("No.", Item."No.");
        PurchLine.SetRange("Drop Shipment", false);
        PurchLine.SetFilter("Location Code", LocCode);
        PurchLine.SetFilter("Outstanding Quantity", '>0');
        if PurchLine.Find('-') then
            repeat
                CollectTracking(Tracking, ItemTracking."Lot Specific Tracking",
                  DATABASE::"Purchase Line", PurchLine."Document Type", PurchLine."Document No.", 0, PurchLine."Line No.",
                  -1, PurchLine."Outstanding Qty. (Base)", '');
                if Tracking.Find('-') then begin
                    repeat
                        if not ItemLotAvail2.Get(Item."No.", PurchLine."Variant Code",
                          Tracking."Lot No.", Tracking."Country/Region of Origin Code")
                        then begin
                            ItemLotAvail2.Init;
                            ItemLotAvail2."Variant Code" := PurchLine."Variant Code";
                            ItemLotAvail2."Lot No." := Tracking."Lot No.";
                            ItemLotAvail2."Country/Region of Origin Code" := Tracking."Country/Region of Origin Code";
                            ItemLotAvail2.Insert(true);
                        end;
                        ItemLotAvail2."Qty. on Purch. Ret. Order" += Tracking."Quantity Available";
                        ItemLotAvail2.Modify;
                    until Tracking.Next = 0;
                end;
            until PurchLine.Next = 0;

        // Quantity Due out on Sales Orders
        SalesLine.Reset;
        SalesLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment"); // P8000998
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("No.", Item."No.");
        SalesLine.SetRange("Drop Shipment", false);
        SalesLine.SetFilter("Location Code", LocCode);
        SalesLine.SetFilter("Outstanding Quantity", '>0');
        if SalesLine.Find('-') then
            repeat
                CollectTracking(Tracking, ItemTracking."Lot Specific Tracking",
                  DATABASE::"Sales Line", SalesLine."Document Type", SalesLine."Document No.", 0, SalesLine."Line No.",
                  -1, SalesLine."Outstanding Qty. (Base)", SalesLine."Country/Region of Origin Code"); // P8000946
                if Tracking.Find('-') then begin
                    repeat
                        if not ItemLotAvail2.Get(Item."No.", SalesLine."Variant Code",
                          Tracking."Lot No.", Tracking."Country/Region of Origin Code")
                        then begin
                            ItemLotAvail2.Init;
                            ItemLotAvail2."Variant Code" := SalesLine."Variant Code";
                            ItemLotAvail2."Lot No." := Tracking."Lot No.";
                            ItemLotAvail2."Country/Region of Origin Code" := Tracking."Country/Region of Origin Code";
                            ItemLotAvail2.Insert(true);
                        end;
                        ItemLotAvail2."Qty. on Sales Order" += Tracking."Quantity Available";
                        ItemLotAvail2.Modify;
                    until Tracking.Next = 0;
                end;
            until SalesLine.Next = 0;

        // Quantity Due out on Transfer Orders
        TransLine.Reset;
        TransLine.SetCurrentKey("Transfer-from Code", Status, "Derived From Line No.", "Item No.", "Variant Code");
        TransLine.SetFilter("Transfer-from Code", LocCode);
        TransLine.SetRange("Derived From Line No.", 0);
        TransLine.SetRange("Item No.", Item."No.");
        TransLine.SetFilter("Outstanding Quantity", '>0');
        if TransLine.Find('-') then
            repeat
                CollectTracking(Tracking, ItemTracking."Lot Specific Tracking",
                  DATABASE::"Transfer Line", 0, TransLine."Document No.", 0, TransLine."Line No.",
                  -1, TransLine."Outstanding Qty. (Base)", '');
                if Tracking.Find('-') then begin
                    repeat
                        if not ItemLotAvail2.Get(Item."No.", TransLine."Variant Code",
                          Tracking."Lot No.", Tracking."Country/Region of Origin Code")
                        then begin
                            ItemLotAvail2.Init;
                            ItemLotAvail2."Variant Code" := TransLine."Variant Code";
                            ItemLotAvail2."Lot No." := Tracking."Lot No.";
                            ItemLotAvail2."Country/Region of Origin Code" := Tracking."Country/Region of Origin Code";
                            ItemLotAvail2.Insert(true);
                        end;
                        ItemLotAvail2."Qty. on Trans. Order (Out)" += Tracking."Quantity Available";
                        ItemLotAvail2.Modify;
                    until Tracking.Next = 0;
                end;
            until TransLine.Next = 0;

        // Quantity Due out on Production Orders
        ProdOrderComp.SetCurrentKey("Item No.", "Variant Code", "Location Code", Status, "Due Date");
        ProdOrderComp.SetRange("Item No.", Item."No.");
        ProdOrderComp.SetFilter("Location Code", LocCode);
        ProdOrderComp.SetRange(Status, ProdOrderComp.Status::Planned, ProdOrderComp.Status::Released);
        ProdOrderComp.SetFilter("Remaining Quantity", '>0');
        if ProdOrderComp.Find('-') then
            repeat
                CollectTracking(Tracking, ItemTracking."Lot Specific Tracking",
                  DATABASE::"Prod. Order Component", ProdOrderComp.Status, ProdOrderComp."Prod. Order No.",
                  ProdOrderComp."Prod. Order Line No.", ProdOrderComp."Line No.", -1, ProdOrderComp."Remaining Qty. (Base)", '');
                if Tracking.Find('-') then begin
                    repeat
                        if not ItemLotAvail2.Get(Item."No.", ProdOrderComp."Variant Code",
                          Tracking."Lot No.", Tracking."Country/Region of Origin Code")
                        then begin
                            ItemLotAvail2.Init;
                            ItemLotAvail2."Variant Code" := ProdOrderComp."Variant Code";
                            ItemLotAvail2."Lot No." := Tracking."Lot No.";
                            ItemLotAvail2."Country/Region of Origin Code" := Tracking."Country/Region of Origin Code";
                            ItemLotAvail2.Insert(true);
                        end;
                        ItemLotAvail2."Qty. on Prod. Order (Out)" += Tracking."Quantity Available";
                        ItemLotAvail2.Modify;
                    until Tracking.Next = 0;
                end;
            until ProdOrderComp.Next = 0;

        // Quantity Due out on Repack Orders
        RepackOrderLine.SetCurrentKey(Status, Type, "No.", "Variant Code", "Source Location", "Due Date");
        RepackOrderLine.SetRange(Status, RepackOrderLine.Status::Open);
        RepackOrderLine.SetRange(Type, RepackOrderLine.Type::Item);
        RepackOrderLine.SetRange("No.", Item."No.");
        RepackOrderLine.SetFilter("Source Location", LocCode);
        if RepackOrderLine.Find('-') then
            repeat
                if not ItemLotAvail2.Get(Item."No.", RepackOrderLine."Variant Code",
                  RepackOrderLine."Lot No.", '')
                then begin
                    ItemLotAvail2.Init;
                    ItemLotAvail2."Variant Code" := RepackOrderLine."Variant Code";
                    ItemLotAvail2."Lot No." := RepackOrderLine."Lot No.";
                    ItemLotAvail2."Country/Region of Origin Code" := '';
                    ItemLotAvail2.Insert(true);
                end;
                ItemLotAvail2."Qty. on Repack Order (Out)" +=
                  RepackOrderLine."Quantity (Base)" - RepackOrderLine."Quantity Transferred (Base)";
                ItemLotAvail2.Modify;
            until RepackOrderLine.Next = 0;

        // Quantity Due out on Sales Line Repack
        SalesLineRepack.Reset;
        SalesLineRepack.SetCurrentKey("Repack Item No.", "Variant Code", "Lot No.", "Location Code");
        SalesLineRepack.SetRange("Repack Item No.", Item."No.");
        SalesLineRepack.SetFilter("Location Code", LocCode);
        if SalesLineRepack.FindSet then
            repeat
                //    SalesLine.GET(SalesLineRepack."Document Type",SalesLineRepack."Document No.",SalesLineRepack."Line No."); // P8001013
                //    IF SalesLine."Shipment Date" <= ShipDate THEN BEGIN                                                       // P8001013
                if SalesLineRepack."Lot No." = '' then
                    Country := SalesLine."Country/Region of Origin Code"
                else
                    Country := '';
                if not ItemLotAvail2.Get(Item."No.", SalesLineRepack."Variant Code", SalesLineRepack."Lot No.", Country) then begin
                    ItemLotAvail2.Init;
                    ItemLotAvail2."Variant Code" := SalesLineRepack."Variant Code";
                    ItemLotAvail2."Lot No." := SalesLineRepack."Lot No.";
                    ItemLotAvail2."Country/Region of Origin Code" := Country;
                    ItemLotAvail2.Insert(true);
                end;
                ItemLotAvail2."Qty. on Line Repack (Out)" += SalesLineRepack."Repack Quantity";
                ItemLotAvail2.Modify;
                //    END; // P8001013
            until SalesLineRepack.Next = 0;

        if not ItemTracking."Lot Specific Tracking" then
            DetailLevel := DetailLevel::Variant;

        case DetailLevel of
            DetailLevel::Lot:
                begin
                    ItemLotAvail2.SetFilter("Lot No.", '<>%1', '');
                    if ItemLotAvail2.Find('-') then
                        repeat
                            ItemLotAvail := ItemLotAvail2;
                            ItemLotAvail."Country/Region of Origin Code" := '';
                            ItemLotAvail.Insert;
                        until ItemLotAvail2.Next = 0;
                end;
            DetailLevel::Country:
                begin
                    ItemLotAvail2.SetCurrentKey("Item No.", "Variant Code", "Country Code");
                    ItemLotAvail2.SetFilter("Country Code", '<>%1', '');
                    if ItemLotAvail2.Find('-') then
                        repeat
                            ItemLotAvail.Init;
                            ItemLotAvail."Item No." := ItemLotAvail2."Item No.";
                            ItemLotAvail."Variant Code" := ItemLotAvail2."Variant Code";
                            ItemLotAvail."Lot No." := '';
                            ItemLotAvail."Country/Region of Origin Code" := ItemLotAvail2."Country Code";
                            ItemLotAvail2.SetRange("Variant Code", ItemLotAvail2."Variant Code");
                            ItemLotAvail2.SetRange("Country Code", ItemLotAvail2."Country Code");
                            repeat
                                ItemLotAvail.IncrementQty(ItemLotAvail2);
                            until ItemLotAvail2.Next = 0;
                            ItemLotAvail2.SetFilter("Country Code", '<>%1', '');
                            ItemLotAvail2.SetRange("Variant Code");
                            ItemLotAvail.Insert;
                        until ItemLotAvail2.Next = 0;
                end;
            DetailLevel::Variant:
                begin
                    ItemLotAvail2.SetCurrentKey("Item No.", "Variant Code");
                    if ItemLotAvail2.Find('-') then
                        repeat
                            ItemLotAvail.Init;
                            ItemLotAvail."Item No." := ItemLotAvail2."Item No.";
                            ItemLotAvail."Variant Code" := ItemLotAvail2."Variant Code";
                            ItemLotAvail."Lot No." := '';
                            ItemLotAvail."Country/Region of Origin Code" := '';
                            ItemLotAvail2.SetRange("Variant Code", ItemLotAvail2."Variant Code");
                            repeat
                                ItemLotAvail.IncrementQty(ItemLotAvail2);
                            until ItemLotAvail2.Next = 0;
                            ItemLotAvail2.SetRange("Variant Code");
                            ItemLotAvail.Insert;
                        until ItemLotAvail2.Next = 0;
                end;
        end;

        if ItemLotAvail.Find('-') then
            repeat
                if Item.TrackAlternateUnits then
                    ItemLotAvail."Alternate Qty. per Base" := Item.AlternateQtyPerBase;
                ItemLotAvail.CalculateAvailable;
                if ItemLotAvail."Cost Quantity" <> 0 then
                    ItemLotAvail."Unit Cost" := ItemLotAvail."Total Cost" / ItemLotAvail."Cost Quantity";
                ItemLotAvail.Modify;
            until ItemLotAvail.Next = 0;
    end;

    local procedure ItemLotCostAtLocation(ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50]; LocCode: Code[10]): Decimal
    var
        ItemLedger: Record "Item Ledger Entry";
        Cost: Decimal;
        Qty: Decimal;
    begin
        // P8000944
        ItemLedger.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code");
        ItemLedger.SetRange("Item No.", ItemNo);
        ItemLedger.SetRange(Open, true);
        ItemLedger.SetRange("Variant Code", VariantCode);
        ItemLedger.SetRange(Positive, true);
        ItemLedger.SetFilter("Location Code", LocCode);
        ItemLedger.SetFilter("Lot No.", LotNo);
        if not ItemLedger.FindSet then begin
            ItemLedger.SetRange("Lot No.");
            if not ItemLedger.FindSet then
                exit;
        end;

        repeat
            ItemLedger.CalcFields("Cost Amount (Actual)", "Cost Amount (Expected)");
            Cost += ItemLedger."Cost Amount (Actual)" + ItemLedger."Cost Amount (Expected)";
            Qty += ItemLedger.GetCostingQty;
        until ItemLedger.Next = 0;

        if Qty <> 0 then
            exit(Cost / Qty);
    end;

    local procedure CollectTracking(var Tracking: Record "Item Lot Availability" temporary; LotTracked: Boolean; SourceType: Integer; SourceSubType: Integer; SourceID: Code[20]; SourceProdOrderLine: Integer; SourceRef: Integer; Sign: Integer; TotalQty: Decimal; Country: Code[10])
    var
        ResEntry: Record "Reservation Entry";
    begin
        // P8000944
        Tracking.Reset;
        Tracking.DeleteAll;
        Clear(Tracking);

        if LotTracked then begin
            ResEntry.SetCurrentKey("Source Type", "Source Subtype", "Source ID", "Source Batch Name", "Source Prod. Order Line",
              "Source Ref. No.");
            ResEntry.SetRange("Source Type", SourceType);
            ResEntry.SetRange("Source Subtype", SourceSubType);
            ResEntry.SetRange("Source ID", SourceID);
            ResEntry.SetRange("Source Prod. Order Line", SourceProdOrderLine);
            ResEntry.SetRange("Source Ref. No.", SourceRef);
            ResEntry.SetFilter("Lot No.", '<>%1', '');
            if ResEntry.FindSet then
                repeat
                    if not Tracking.Get('', '', ResEntry."Lot No.") then begin
                        Tracking."Lot No." := ResEntry."Lot No.";
                        Tracking."Quantity Available" := 0;
                        Tracking.Insert;
                    end;
                    Tracking."Quantity Available" += Sign * ResEntry."Quantity (Base)";
                    TotalQty -= Sign * ResEntry."Quantity (Base)";
                    Tracking.Modify;
                until ResEntry.Next = 0;
        end;

        if TotalQty <> 0 then begin
            Tracking."Lot No." := '';
            Tracking."Country/Region of Origin Code" := Country;
            Tracking."Quantity Available" := TotalQty;
            Tracking.Insert;
        end;
    end;

    procedure LotLookup(SalesLine: Record "Sales Line"; var LotNo: Text[20]): Boolean
    var
        SalesSetup: Record "Sales & Receivables Setup";
        RepackLine: Record "Sales Line Repack";
        Item: Record Item;
        ItemTracking: Record "Item Tracking Code";
        ItemLotAvail: Record "Item Lot Availability" temporary;
        TermMktLotLookup: Page "Term. Mkt. Lot Lookup";
        QtyOnLine: Decimal;
    begin
        // P8000994
        SalesSetup.Get;
        if SalesSetup."Terminal Market Item Level" = SalesSetup."Terminal Market Item Level"::Lot then
            exit(false);

        if RepackLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.") then begin
            Item.Get(RepackLine."Repack Item No.");
            QtyOnLine := RepackLine."Repack Quantity";
        end else begin
            Item.Get(SalesLine."No.");
            QtyOnLine := SalesLine."Quantity (Base)";
        end;
        if not ItemTracking.Get(Item."Item Tracking Code") then
            exit(false);
        if not ItemTracking."Lot Specific Tracking" then
            exit(false);
        CalculateAvailability(Item, SalesLine."Location Code", SalesLine."Shipment Date", 0, ItemLotAvail);

        if ItemLotAvail.Get(Item."No.", SalesLine."Variant Code", SalesLine."Lot No.") then begin
            ItemLotAvail."Quantity Available" += QtyOnLine;
            ItemLotAvail.Modify;
        end;
        ItemLotAvail.SetCurrentKey("Item No.", "Variant Code", "Country Code");
        ItemLotAvail.SetRange("Variant Code", SalesLine."Variant Code");
        if SalesSetup."Terminal Market Item Level" = SalesSetup."Terminal Market Item Level"::"Item/Variant/Country of Origin" then
            ItemLotAvail.SetRange("Country Code", SalesLine."Country/Region of Origin Code");
        ItemLotAvail.SetFilter("Quantity Available", '>=%1', QtyOnLine);
        if ItemLotAvail.IsEmpty then
            Error(Text001, ItemLotAvail.FieldCaption("Item No."), Item."No.",
              ItemLotAvail.FieldCaption("Variant Code"), SalesLine."Variant Code");

        ItemLotAvail.ModifyAll(Description, Item.Description);
        ItemLotAvail.ModifyAll("Base Unit of Measure", Item."Base Unit of Measure");
        if Item.CostInAlternateUnits then
            ItemLotAvail.ModifyAll("Costing Unit of Measure", Item."Alternate Unit of Measure")
        else
            ItemLotAvail.ModifyAll("Costing Unit of Measure", Item."Base Unit of Measure");

        TermMktLotLookup.LoadData(ItemLotAvail);
        TermMktLotLookup.LookupMode(true);
        if TermMktLotLookup.RunModal = ACTION::LookupOK then begin
            TermMktLotLookup.GetRecord(ItemLotAvail);
            LotNo := ItemLotAvail."Lot No.";
            exit(true);
        end else
            exit(false);
    end;

    procedure InsertSalesLine(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50]; CountryOfOrigin: Code[10]; LocCode: Code[10]; Qty: Decimal; AltQty: Decimal; UnitPrice: Decimal; RepackItemNo: Code[20]; RepackQty: Decimal; Comment: Text[30]; BypassCreditCheck: Boolean)
    var
        SalesLine2: Record "Sales Line";
        SalesLineItem: Record Item;
        RepackLineItem: Record Item;
        SalesRepack: Record "Sales Line Repack";
        AltQtyLine: Record "Alternate Quantity Line";
        CustCheckCreditLimit: Codeunit "Cust-Check Cr. Limit";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        SalesLineQty: Decimal;
        SalesLineAltQty: Decimal;
        RepackLineQty: Decimal;
        RepackLineAltQty: Decimal;
    begin
        // P8000944
        // P8000946 - add parameter for CountryOfOrigin
        SetVarsForRepack(ItemNo, RepackItemNo, Qty, AltQty, RepackQty,
          SalesLineItem, SalesLineQty, SalesLineAltQty, RepackLineItem, RepackLineQty, RepackLineAltQty);

        // Following code inserted to enable credit check.  Salesline data required for credit check
        // must not be validated initially since the validation starts a transaction (Dimensions Recs).
        // Once a transaction has been started, FORM.RUNMODAL used by the credit check is not possible.
        // Here, the data required for the credit check is supplied without starting a transaction.
        // Proper validations are done later.
        SalesLine.Init;
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine."No." := SalesLineItem."No.";
        SalesLine.Quantity := SalesLineQty;
        SalesLine."Unit of Measure Code" := SalesLineItem."Base Unit of Measure";
        SalesLine."Location Code" := LocCode;
        SalesLine."Shipment Date" := SalesHeader."Shipment Date";
        SalesLine."Quantity (Base)" := SalesLine.Quantity;
        SalesLine."Bypass Credit Check" := BypassCreditCheck;
        SalesLine.InitOutstanding;
        SalesLine.Validate("Unit Price", UnitPrice);
        CustCheckCreditLimit.SalesLineCheck(SalesLine);
        // Credit Check End

        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", SalesLineItem."No.");
        SalesLine.Validate("Variant Code", VariantCode);
        SalesLine.Validate("Location Code", LocCode);
        SalesLine.Validate("Unit of Measure Code", SalesLineItem."Base Unit of Measure");
        SalesLine.Validate(Quantity, SalesLineQty);
        SalesLine.Validate("Unit Price", UnitPrice);
        if LotNo = '' then                                              // P8000946
            SalesLine."Country/Region of Origin Code" := CountryOfOrigin; // P8000946
        SalesLine.Comment := Comment;
        SalesLine."Bypass Credit Check" := false;
        SalesLine.LockTable;
        if SalesLine."Line No." = 0 then begin
            SalesLine2.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine2.SetRange("Document No.", SalesHeader."No.");

            if SalesLine2.Find('+') then
                SalesLine."Line No." := SalesLine2."Line No." + 10000
            else
                SalesLine."Line No." := 10000;
        end;
        SalesLine.Insert(true);

        if SalesLineItem."Catch Alternate Qtys." and (SalesLineAltQty <> 0) then begin
            SalesLine."Qty. to Ship (Alt.)" := SalesLineAltQty;
            AltQtyMgmt.SetSalesLineAltQty(SalesLine);
            AltQtyMgmt.ValidateSalesAltQtyLine(SalesLine);
            SalesLine.Modify;
        end;

        if LotNo <> '' then begin
            CreateReservEntry.CreateReservEntryFor(
              DATABASE::"Sales Line", SalesLine."Document Type", SalesLine."Document No.", '',
              0, SalesLine."Line No.", SalesLine."Qty. per Unit of Measure", SalesLine.Quantity, SalesLine."Quantity (Base)", // P8001132
              '', LotNo);
            CreateReservEntry.AddAltQtyData(-SalesLineAltQty);
            CreateReservEntry.CreateEntry(
              SalesLine."No.", SalesLine."Variant Code", SalesLine."Location Code",
              SalesLine.Description, 0D, SalesLine."Shipment Date", 0, 2);
            if SalesLineItem."Catch Alternate Qtys." then begin
                AltQtyLine.SetRange("Alt. Qty. Transaction No.", SalesLine."Alt. Qty. Transaction No.");
                AltQtyLine.Find('+');
                AltQtyLine."Lot No." := LotNo;
                AltQtyLine.Modify;
            end;
            SalesLine."Lot No." := LotNo;
            SalesLine.Modify;
        end;

        if RepackLineItem."No." <> '' then begin
            SalesRepack."Document Type" := SalesHeader."Document Type";
            SalesRepack."Document No." := SalesHeader."No.";
            SalesRepack."Line No." := SalesLine."Line No.";
            SalesRepack."Repack Item No." := RepackLineItem."No.";
            SalesRepack."Variant Code" := VariantCode;
            SalesRepack."Lot No." := LotNo;
            SalesRepack."Location Code" := LocCode;
            SalesRepack."Repack Quantity" := RepackLineQty;
            SalesRepack."Repack Quantity (Alt.)" := RepackLineAltQty;
            SalesRepack."Target Item No." := SalesLine."No.";
            SalesRepack."Target Quantity" := SalesLine."Quantity (Base)";
            SalesRepack."Target Quantity (Alt.)" := SalesLine."Quantity (Alt.)";
            SalesRepack.Insert;
        end;
    end;

    procedure ChangeSalesLine(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; Qty: Decimal; AltQty: Decimal; UnitPrice: Decimal; RepackItemNo: Code[20]; RepackQty: Decimal; Comment: Text[30]; BypassCreditCheck: Boolean)
    var
        SalesLine2: Record "Sales Line";
        SalesLineItem: Record Item;
        RepackLineItem: Record Item;
        SalesRepack: Record "Sales Line Repack";
        AltQtyLine: Record "Alternate Quantity Line";
        CustCheckCreditLimit: Codeunit "Cust-Check Cr. Limit";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        SalesLineReserve: Codeunit "Sales Line-Reserve";
        SalesLineQty: Decimal;
        SalesLineAltQty: Decimal;
        RepackLineQty: Decimal;
        RepackLineAltQty: Decimal;
    begin
        // P8000944
        SetVarsForRepack(SalesLine."No.", RepackItemNo, Qty, AltQty, RepackQty,
          SalesLineItem, SalesLineQty, SalesLineAltQty, RepackLineItem, RepackLineQty, RepackLineAltQty);

        SalesLineReserve.SetDeleteItemTracking(true); // P8006630
        SalesLineReserve.DeleteLine(SalesLine);
        SalesLine.Validate(Quantity, SalesLineQty);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Comment := Comment;
        SalesLine."Bypass Credit Check" := false;
        SalesLine.Modify(true);
        SalesLine.UpdateLotTracking(true, 0); // P80071533

        if SalesLineItem."Catch Alternate Qtys." and (SalesLineAltQty <> 0) then begin
            SalesLine."Qty. to Ship (Alt.)" := SalesLineAltQty;
            AltQtyMgmt.SetSalesLineAltQty(SalesLine);
            AltQtyMgmt.ValidateSalesAltQtyLine(SalesLine);
            SalesLine.Modify;
        end;

        if RepackLineItem."No." <> '' then begin
            SalesRepack.Get(SalesHeader."Document Type", SalesHeader."No.", SalesLine."Line No.");
            SalesRepack."Repack Quantity" := RepackLineQty;
            SalesRepack."Repack Quantity (Alt.)" := RepackLineAltQty;
            SalesRepack."Target Quantity" := SalesLine."Quantity (Base)";
            SalesRepack."Target Quantity (Alt.)" := SalesLine."Quantity (Alt.)";
            SalesRepack.Modify;
        end;
    end;

    procedure SetVarsForRepack(ItemNo: Code[20]; RepackItemNo: Code[20]; Qty: Decimal; AltQty: Decimal; RepackQty: Decimal; var SalesLineItem: Record Item; var SalesLineQty: Decimal; var SalesLineAltQty: Decimal; var RepackLineItem: Record Item; var RepackLineQty: Decimal; var RepackLineAltQty: Decimal)
    var
        TermMktMgt: Codeunit "Terminal Market Selling";
    begin
        // P8000944
        if RepackItemNo = '' then begin
            SalesLineItem.Get(ItemNo);
            SalesLineQty := Qty;
            SalesLineAltQty := AltQty;
        end else begin
            SalesLineItem.Get(RepackItemNo);
            SalesLineQty := RepackQty;
            RepackLineItem.Get(ItemNo);
            RepackLineQty := Qty;
            if SalesLineItem."Alternate Unit of Measure" = '' then
                SalesLineAltQty := 0
            else
                if not SalesLineItem."Catch Alternate Qtys." then
                    SalesLineAltQty := Round(SalesLineQty * SalesLineItem.AlternateQtyPerBase, 0.00001);
            if RepackLineItem."Alternate Unit of Measure" = '' then begin
                RepackLineAltQty := 0;
                if SalesLineItem."Catch Alternate Qtys." then begin
                    SalesLineAltQty := Round(RepackLineQty * TermMktMgt.GetAltQtyRepackFactor(
                      RepackLineItem."No.", RepackLineItem."Base Unit of Measure", SalesLineItem."Alternate Unit of Measure"),
                      0.00001);
                end;
            end else
                if not RepackLineItem."Catch Alternate Qtys." then begin
                    RepackLineAltQty := Round(RepackLineQty * RepackLineItem.AlternateQtyPerBase, 0.00001);
                    if SalesLineItem."Catch Alternate Qtys." then begin
                        SalesLineAltQty := Round(RepackLineQty * TermMktMgt.GetAltQtyRepackFactor(
                          RepackLineItem."No.", RepackLineItem."Base Unit of Measure", SalesLineItem."Alternate Unit of Measure"),
                          0.00001);
                    end;
                end else begin
                    RepackLineAltQty := AltQty;
                    if (SalesLineItem."Alternate Unit of Measure" <> '') and SalesLineItem."Catch Alternate Qtys." then begin
                        SalesLineAltQty := Round(RepackLineAltQty * TermMktMgt.GetAltQtyRepackFactor(
                          RepackLineItem."No.", RepackLineItem."Alternate Unit of Measure", SalesLineItem."Alternate Unit of Measure"),
                          0.00001);
                    end;
                end;
        end;
    end;

    procedure GetSalesLineLotInfo(SalesLine: Record "Sales Line"; var LotInfo: Record "Lot No. Information")
    var
        SalesLineRepack: Record "Sales Line Repack";
        ResEntry: Record "Reservation Entry";
        PurchLine: Record "Purchase Line";
        RepackHeader: Record "Repack Order";
    begin
        // P8000970
        if SalesLineRepack.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.") then begin
            SalesLine."No." := SalesLineRepack."Repack Item No.";
            SalesLine."Variant Code" := SalesLineRepack."Variant Code";
            SalesLine."Lot No." := SalesLineRepack."Lot No.";
        end;

        if LotInfo.Get(SalesLine."No.", SalesLine."Variant Code", SalesLine."Lot No.") then
            exit;

        LotInfo."Lot No." := SalesLine."Lot No.";

        ResEntry.SetCurrentKey("Source Type", "Item No.", "Variant Code", "Lot No.");
        ResEntry.SetRange("Source Type", DATABASE::"Purchase Line");
        ResEntry.SetRange("Source Subtype", PurchLine."Document Type"::Order);
        ResEntry.SetRange("Item No.", SalesLine."No.");
        ResEntry.SetRange("Variant Code", SalesLine."Variant Code");
        ResEntry.SetRange("Lot No.", SalesLine."Lot No.");
        if ResEntry.FindFirst then begin
            PurchLine.Get(PurchLine."Document Type"::Order, ResEntry."Source ID", ResEntry."Source Ref. No.");
            LotInfo.Brand := PurchLine.Brand;
            LotInfo."Country/Region of Origin Code" := PurchLine."Country/Region of Origin Code";
            exit;
        end;

        RepackHeader.SetCurrentKey(Status, "Item No.", "Variant Code");
        RepackHeader.SetRange(Status, RepackHeader.Status::Open);
        RepackHeader.SetRange("Item No.", SalesLine."No.");
        RepackHeader.SetRange("Variant Code", SalesLine."Variant Code");
        RepackHeader.SetRange("Lot No.", SalesLine."Lot No.");
        if RepackHeader.FindFirst then begin
            LotInfo.Brand := RepackHeader.Brand;
            LotInfo."Country/Region of Origin Code" := RepackHeader."Country/Region of Origin Code";
            exit;
        end;
    end;
}

