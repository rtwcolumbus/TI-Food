codeunit 37002042 "Process 800 Req. Wksh. Fns."
{
    // PR4.00.02
    // P8000312A, VerticalSoft, Jack Reynolds, 20 MAR 06
    //   Functions to support extensions to requisition worksheet
    // 
    // PR4.00.06
    // P8000493A, VerticalSoft, Jack Reynolds, 06 JUL 07
    //   Modify LoadItemVendor to use different temp table
    // 
    // PRW16.00.05
    // P8000936, Columbus IT, Jack Reynolds, 25 APR 11
    //   Support for Repack Orders on Sales Board
    // 
    // PRW16.00.06
    // P8001004, Columbus IT, Jack Reynolds, 15 DEC 11
    //   Fixes to FactBoxes on Req. Worksheet and Order Guide
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW17.10.02
    // P8001264, Columbus IT, Jack Reynolds, 20 JAN 14
    //   Fix date issues with production output drilldown
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00


    trigger OnRun()
    begin
    end;

    var
        LotStatus: Record "Lot Status Code";
        LotStatusMgmt: Codeunit "Lot Status Management";
        LotStatusExclusionFilter: Text[1024];
        LotStatusExclusionFilterSet: Boolean;
        ExcludePurch: Boolean;
        ExcludeSalesRet: Boolean;
        ExcludeOutput: Boolean;

    procedure LoadItemAvail(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; BegDate: Date; EndDate: Date; var ItemAvail: Record "Item Availability" temporary)
    var
        Item: Record Item;
        ItemTotal: Record Item;
        PurchLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        Sales: array[2] of Decimal;
        Purchases: array[2] of Decimal;
        Output: array[2] of Decimal;
        Consumption: array[2] of Decimal;
        Transfers: array[2] of Decimal;
        Available: array[2] of Decimal;
    begin
        ItemAvail.Reset;
        ItemAvail.DeleteAll;
        ItemAvail.Init;

        if not Item.Get(ItemNo) then // P8001004
            exit;                      // P8001004
        // P8001083
        if not LotStatusExclusionFilterSet then begin
            LotStatusExclusionFilter := LotStatusMgmt.SetLotStatusExclusionFilter(LotStatus.FieldNo("Available for Planning"));
            LotStatusExclusionFilterSet := true;
        end;
        LotStatusMgmt.SetInboundExclusions(Item, LotStatus.FieldNo("Available for Planning"), ExcludePurch, ExcludeSalesRet, ExcludeOutput);
        // P8001083

        Item.SetRange("Variant Filter", VariantCode);
        Item.SetRange("Location Filter", LocationCode);
        //Item.SETRANGE("Date Filter",0D,BegDate - 1);
        //Item.CALCFIELDS("Net Change");

        Item.SetRange("Date Filter", 0D, EndDate);
        Item.CalcFields(Inventory, "Qty. on Purch. Order", "Qty. on Sales Order", "Trans. Ord. Receipt (Qty.)", // P8001083
          "Trans. Ord. Shipment (Qty.)", "Qty. in Transit", "Scheduled Receipt (Qty.)", "Scheduled Need (Qty.)",       // P8000936
          "Qty. on Repack", "Qty. on Repack Line", "Qty. on Repack Line-Trans. Out", "Qty. on Repack Line-Trans. In"); // P8000936
        // P8001083
        ItemTotal := Item;
        LotStatusMgmt.AdjustItemFlowFields(Item, LotStatusExclusionFilter, true, true, 0, ExcludePurch, ExcludeSalesRet, ExcludeOutput);
        // P8001083

        ItemAvail."Date Offset" := 0;
        ItemAvail."Data Element" := ItemAvail."Data Element"::"On Hand";
        ItemAvail.Quantity := Item.Inventory; // P8001083
        ItemAvail."Quantity Not Available" := ItemTotal.Inventory - ItemAvail.Quantity; // P8001083
        ItemAvail.Insert;
        Available[1] := ItemAvail.Quantity;                 // P8001083
        Available[2] := ItemAvail."Quantity Not Available"; // P8001083

        ItemAvail."Data Element" := ItemAvail."Data Element"::"Purchase Orders";
        ItemAvail.Quantity := Item."Qty. on Purch. Order";
        ItemAvail."Quantity Not Available" := ItemTotal."Qty. on Purch. Order" - ItemAvail.Quantity; // P8001083
        ItemAvail.Insert;
        Purchases[1] += ItemAvail.Quantity;                 // P8001083
        Purchases[2] += ItemAvail."Quantity Not Available"; // P8001083

        ItemAvail."Data Element" := ItemAvail."Data Element"::"Sales Orders";
        ItemAvail.Quantity := -Item."Qty. on Sales Order";
        ItemAvail."Quantity Not Available" := -ItemTotal."Qty. on Sales Order" - ItemAvail.Quantity; // P8001083
        ItemAvail.Insert;
        Sales[1] += ItemAvail.Quantity;                 // P8001083
        Sales[2] += ItemAvail."Quantity Not Available"; // P8001083

        ItemAvail."Data Element" := ItemAvail."Data Element"::"Transfers In";
        ItemAvail.Quantity := Item."Trans. Ord. Receipt (Qty.)" + Item."Qty. in Transit";
        ItemAvail."Quantity Not Available" := ItemTotal."Trans. Ord. Receipt (Qty.)" + ItemTotal."Qty. in Transit" -
          ItemAvail.Quantity; // P8001083
        ItemAvail.Insert;
        Transfers[1] += ItemAvail.Quantity;                 // P8001083
        Transfers[2] += ItemAvail."Quantity Not Available"; // P8001083

        ItemAvail."Data Element" := ItemAvail."Data Element"::"Transfers Out";
        ItemAvail.Quantity := -Item."Trans. Ord. Shipment (Qty.)";
        ItemAvail."Quantity Not Available" := -ItemTotal."Trans. Ord. Shipment (Qty.)" - ItemAvail.Quantity; // P8001083
        ItemAvail.Insert;
        Transfers[1] += ItemAvail.Quantity;                 // P8001083
        Transfers[2] += ItemAvail."Quantity Not Available"; // P8001083

        ItemAvail."Data Element" := ItemAvail."Data Element"::"Production Output";
        ItemAvail.Quantity := Item."Scheduled Receipt (Qty.)";
        ItemAvail."Quantity Not Available" := ItemTotal."Scheduled Receipt (Qty.)" - ItemAvail.Quantity; // P8001083
        ItemAvail.Insert;
        Output[1] += ItemAvail.Quantity; // P8000936,       P8001083
        Output[2] += ItemAvail."Quantity Not Available"; // P8001083

        ItemAvail."Data Element" := ItemAvail."Data Element"::"Production Components";
        ItemAvail.Quantity := -Item."Scheduled Need (Qty.)";
        ItemAvail."Quantity Not Available" := -ItemTotal."Scheduled Need (Qty.)" - ItemAvail.Quantity; // P8001083
        ItemAvail.Insert;
        Consumption[1] += ItemAvail.Quantity; // P8000936,       P8001083
        Consumption[2] += ItemAvail."Quantity Not Available"; // P8001083

        // P8000936
        ItemAvail."Data Element" := ItemAvail."Data Element"::"Repack Output";
        ItemAvail.Quantity := Item."Qty. on Repack";
        ItemAvail."Quantity Not Available" := ItemTotal."Qty. on Repack" - ItemAvail.Quantity; // P8001083
        ItemAvail.Insert;
        Output[1] += ItemAvail.Quantity;                 // P8001083
        Output[2] += ItemAvail."Quantity Not Available"; // P8001083

        ItemAvail."Data Element" := ItemAvail."Data Element"::"Repack Components";
        ItemAvail.Quantity := -(Item."Qty. on Repack Line" - Item."Qty. on Repack Line-Trans. Out" + Item."Qty. on Repack Line-Trans. In");
        // P8001083
        ItemAvail."Quantity Not Available" :=
         -(ItemTotal."Qty. on Repack Line" - ItemTotal."Qty. on Repack Line-Trans. Out" + ItemTotal."Qty. on Repack Line-Trans. In") -
           ItemAvail.Quantity;
        // P8001083
        ItemAvail.Insert;
        Consumption[1] += ItemAvail.Quantity;                 // P8001083
        Consumption[2] += ItemAvail."Quantity Not Available"; // P8001083
        // P8000936

        PurchLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Expected Receipt Date");
        PurchLine.SetRange("Document Type", PurchLine."Document Type"::"Return Order");
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        PurchLine.SetRange("No.", ItemNo);
        PurchLine.SetRange("Variant Code", VariantCode);
        PurchLine.SetRange("Location Code", LocationCode);
        PurchLine.SetRange("Expected Receipt Date", 0D, EndDate);
        PurchLine.CalcSums("Outstanding Qty. (Base)");
        ItemAvail."Data Element" := ItemAvail."Data Element"::"Purchase Returns";
        ItemAvail.Quantity := -PurchLine."Outstanding Qty. (Base)";
        ItemAvail."Quantity Not Available" := 0; // P8001083
        ItemAvail.Insert;
        Purchases[1] += ItemAvail.Quantity; // P8001083

        SalesLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Shipment Date");
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Return Order");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("No.", ItemNo);
        SalesLine.SetRange("Variant Code", VariantCode);
        SalesLine.SetRange("Location Code", LocationCode);
        SalesLine.SetRange("Shipment Date", 0D, EndDate);
        SalesLine.CalcSums("Outstanding Qty. (Base)");
        ItemAvail."Data Element" := ItemAvail."Data Element"::"Sales Returns";
        // P8001083
        if ExcludeSalesRet then begin
            ItemAvail.Quantity := 0;
            ItemAvail."Quantity Not Available" := SalesLine."Outstanding Qty. (Base)";
        end else begin
            ItemAvail.Quantity := SalesLine."Outstanding Qty. (Base)";
            ItemAvail."Quantity Not Available" := 0;
        end;
        // P8001083
        ItemAvail.Insert;
        Sales[1] += ItemAvail.Quantity;                 // P8001083
        Sales[2] += ItemAvail."Quantity Not Available"; // P8001083

        ItemAvail."Data Element" := ItemAvail."Data Element"::Purchases;
        ItemAvail.Quantity := Purchases[1];                 // P8001083
        ItemAvail."Quantity Not Available" := Purchases[2]; // P8001083
        ItemAvail.Insert;

        ItemAvail."Data Element" := ItemAvail."Data Element"::Sales;
        ItemAvail.Quantity := Sales[1];                 // P8001083
        ItemAvail."Quantity Not Available" := Sales[2]; // P8001083
        ItemAvail.Insert;

        // P8000936
        ItemAvail."Data Element" := ItemAvail."Data Element"::Output;
        ItemAvail.Quantity := Output[1];                 // P8001083
        ItemAvail."Quantity Not Available" := Output[2]; // P8001083
        ItemAvail.Insert;

        ItemAvail."Data Element" := ItemAvail."Data Element"::Consumption;
        ItemAvail.Quantity := Consumption[1];                 // P8001083
        ItemAvail."Quantity Not Available" := Consumption[2]; // P8001083
        ItemAvail.Insert;
        // P8000936

        ItemAvail."Data Element" := ItemAvail."Data Element"::Transfers;
        ItemAvail.Quantity := Transfers[1];                 // P8001083
        ItemAvail."Quantity Not Available" := Transfers[2]; // P8001083
        ItemAvail.Insert;

        ItemAvail."Date Offset" := 1;
        ItemAvail."Data Element" := ItemAvail."Data Element"::Available;
        ItemAvail.Quantity := Available[1] + Purchases[1] + Sales[1] + Output[1] + Consumption[1] + Transfers[1]; // P8001083
        ItemAvail."Quantity Not Available" := Available[2] + Purchases[2] + Sales[2] + Output[2] + Consumption[2] + Transfers[2]; // P8001083
        ItemAvail.Insert;
    end;

    procedure ItemAvailDrillDown(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; BegDate: Date; EndDate: Date; var ItemAvail: Record "Item Availability" temporary)
    var
        ItemAvail2: Record "Item Availability";
        ItemLedger: Record "Item Ledger Entry";
        PurchLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        ProdOrderLine: Record "Prod. Order Line";
        RepackOrder: Record "Repack Order";
        ProdOrderComp: Record "Prod. Order Component";
        RepackOrderLine: Record "Repack Order Line";
        TransLine: Record "Transfer Line";
        ItemLedgerEntries: Page "Item Ledger Entries";
        TransferLines: Page "Transfer Lines";
    begin
        ItemAvail2.Copy(ItemAvail);
        ItemAvail.Reset;

        case ItemAvail."Data Element" of
            ItemAvail."Data Element"::"On Hand":
                begin
                    ItemLedger.SetCurrentKey("Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");
                    ItemLedger.SetRange("Item No.", ItemNo);
                    ItemLedger.SetRange("Location Code", LocationCode);
                    ItemLedger.SetRange("Variant Code", VariantCode);
                    //ItemLedger.SETRANGE("Posting Date",0D,BegDate - 1); // P8001083
                    ItemLedger.SetRange(Open, true);
                    // P8001083
                    //FORM.RUNMODAL(0,ItemLedger);
                    ItemLedgerEntries.SetTableView(ItemLedger);
                    ItemLedgerEntries.SetLotStatus(LotStatusExclusionFilter);
                    ItemLedgerEntries.RunModal;
                    // P8001083
                end;
            ItemAvail."Data Element"::Purchases:
                begin
                    ItemAvail.FilterGroup(9);
                    ItemAvail.SetFilter("Data Element", '%1|%2',
                      ItemAvail."Data Element"::"Purchase Orders", ItemAvail."Data Element"::"Purchase Returns");
                    ItemAvail.FilterGroup(0);
                    ItemAvailDrillDown2(ItemNo, VariantCode, LocationCode, BegDate, EndDate, ItemAvail);
                end;
            ItemAvail."Data Element"::"Purchase Orders":
                begin
                    PurchLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Expected Receipt Date");
                    PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
                    PurchLine.SetRange(Type, PurchLine.Type::Item);
                    PurchLine.SetRange("No.", ItemNo);
                    PurchLine.SetRange("Variant Code", VariantCode);
                    PurchLine.SetRange("Location Code", LocationCode);
                    PurchLine.SetRange("Expected Receipt Date", 0D, EndDate);
                    PurchLine.SetFilter("Outstanding Quantity", '<>0');
                    PAGE.RunModal(0, PurchLine);
                end;
            ItemAvail."Data Element"::"Purchase Returns":
                begin
                    PurchLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Expected Receipt Date");
                    PurchLine.SetRange("Document Type", PurchLine."Document Type"::"Return Order");
                    PurchLine.SetRange(Type, PurchLine.Type::Item);
                    PurchLine.SetRange("No.", ItemNo);
                    PurchLine.SetRange("Variant Code", VariantCode);
                    PurchLine.SetRange("Location Code", LocationCode);
                    PurchLine.SetRange("Expected Receipt Date", 0D, EndDate);
                    PurchLine.SetFilter("Outstanding Quantity", '<>0');
                    PAGE.RunModal(0, PurchLine);
                end;
            ItemAvail."Data Element"::Sales:
                begin
                    ItemAvail.FilterGroup(9);
                    ItemAvail.SetFilter("Data Element", '%1|%2',
                      ItemAvail."Data Element"::"Sales Orders", ItemAvail."Data Element"::"Sales Returns");
                    ItemAvail.FilterGroup(0);
                    ItemAvailDrillDown2(ItemNo, VariantCode, LocationCode, BegDate, EndDate, ItemAvail);
                end;
            ItemAvail."Data Element"::"Sales Orders":
                begin
                    SalesLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Shipment Date");
                    SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                    SalesLine.SetRange("No.", ItemNo);
                    SalesLine.SetRange("Variant Code", VariantCode);
                    SalesLine.SetRange("Location Code", LocationCode);
                    SalesLine.SetRange("Shipment Date", 0D, EndDate);
                    SalesLine.SetFilter("Outstanding Quantity", '<>0');
                    PAGE.RunModal(0, SalesLine);
                end;
            ItemAvail."Data Element"::"Sales Returns":
                begin
                    SalesLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Shipment Date");
                    SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Return Order");
                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                    SalesLine.SetRange("No.", ItemNo);
                    SalesLine.SetRange("Variant Code", VariantCode);
                    SalesLine.SetRange("Location Code", LocationCode);
                    SalesLine.SetRange("Shipment Date", 0D, EndDate);
                    SalesLine.SetFilter("Outstanding Quantity", '<>0');
                    PAGE.RunModal(0, SalesLine);
                end;
            // P8000936
            ItemAvail."Data Element"::Output:
                begin
                    ItemAvail.FilterGroup(9);
                    ItemAvail.SetFilter("Data Element", '%1|%2',
                      ItemAvail."Data Element"::"Production Output", ItemAvail."Data Element"::"Repack Output");
                    ItemAvail.FilterGroup(0);
                    ItemAvailDrillDown2(ItemNo, VariantCode, LocationCode, BegDate, EndDate, ItemAvail);
                end;
            // P8000936
            ItemAvail."Data Element"::"Production Output":
                begin
                    ProdOrderLine.SetCurrentKey(Status, "Item No.", "Variant Code", "Location Code", "Due Date");
                    ProdOrderLine.SetRange(Status, ProdOrderComp.Status::Planned, ProdOrderComp.Status::Released);
                    ProdOrderLine.SetRange("Item No.", ItemNo);
                    ProdOrderLine.SetRange("Variant Code", VariantCode);
                    ProdOrderLine.SetRange("Location Code", LocationCode);
                    ProdOrderLine.SetRange("Due Date", 0D, EndDate); // P8000936, P8001264
                    ProdOrderLine.SetFilter("Remaining Qty. (Base)", '<>0');
                    PAGE.RunModal(0, ProdOrderLine);
                end;
            // P8000936
            ItemAvail."Data Element"::"Repack Output":
                begin
                    RepackOrder.SetCurrentKey(Status, "Item No.", "Variant Code", "Destination Location", "Due Date");
                    RepackOrder.SetRange(Status, RepackOrder.Status::Open);
                    RepackOrder.SetRange("Item No.", ItemNo);
                    RepackOrder.SetRange("Variant Code", VariantCode);
                    RepackOrder.SetRange("Destination Location", LocationCode);
                    RepackOrder.SetRange("Due Date", 0D, EndDate);
                    PAGE.RunModal(0, RepackOrder);
                end;
            ItemAvail."Data Element"::Consumption:
                begin
                    ItemAvail.FilterGroup(9);
                    ItemAvail.SetFilter("Data Element", '%1|%2',
                      ItemAvail."Data Element"::"Production Components", ItemAvail."Data Element"::"Repack Components");
                    ItemAvail.FilterGroup(0);
                    ItemAvailDrillDown2(ItemNo, VariantCode, LocationCode, BegDate, EndDate, ItemAvail);
                end;
            // P8000936
            ItemAvail."Data Element"::"Production Components":
                begin
                    ProdOrderComp.SetCurrentKey(Status, "Item No.", "Variant Code", "Location Code", "Due Date");
                    ProdOrderComp.SetRange(Status, ProdOrderComp.Status::Planned, ProdOrderComp.Status::Released);
                    ProdOrderComp.SetRange("Item No.", ItemNo);
                    ProdOrderComp.SetRange("Variant Code", VariantCode);
                    ProdOrderComp.SetRange("Location Code", LocationCode);
                    ProdOrderComp.SetRange("Due Date", 0D, EndDate); // P8000936
                    ProdOrderComp.SetFilter("Remaining Qty. (Base)", '<>0');
                    PAGE.RunModal(0, ProdOrderComp);
                end;
            // P8000936
            ItemAvail."Data Element"::"Repack Components":
                begin
                    RepackOrderLine.SetRange(Status, RepackOrderLine.Status::Open);
                    RepackOrderLine.SetRange(Type, RepackOrderLine.Type::Item);
                    RepackOrderLine.SetRange("No.", ItemNo);
                    RepackOrderLine.SetRange("Variant Code", VariantCode);
                    RepackOrderLine.SetRange("Due Date", 0D, EndDate);
                    RepackOrderLine.SetCurrentKey(Status, Type, "No.", "Variant Code", "Source Location", "Due Date");
                    RepackOrderLine.SetRange("Source Location", LocationCode);
                    if RepackOrderLine.FindSet then
                        repeat
                            RepackOrderLine.Mark(RepackOrderLine.Quantity > RepackOrderLine."Quantity Transferred");
                        until RepackOrderLine.Next = 0;
                    RepackOrderLine.SetRange("Source Location");
                    RepackOrderLine.SetCurrentKey(Status, Type, "No.", "Variant Code", "Repack Location", "Due Date");
                    RepackOrderLine.SetRange("Repack Location", LocationCode);
                    RepackOrderLine.SetFilter("Quantity Transferred", '>0');
                    if RepackOrderLine.FindSet then
                        repeat
                            RepackOrderLine.Mark(true);
                        until RepackOrderLine.Next = 0;
                    RepackOrderLine.SetRange("Quantity Transferred");
                    RepackOrderLine.SetRange("Repack Location");
                    RepackOrderLine.SetCurrentKey("Order No.", "Line No.");
                    RepackOrderLine.MarkedOnly(true);
                    PAGE.RunModal(0, RepackOrderLine);
                end;
            // P8000936
            ItemAvail."Data Element"::Transfers:
                begin
                    ItemAvail.FilterGroup(9);
                    ItemAvail.SetFilter("Data Element", '%1|%2',
                      ItemAvail."Data Element"::"Transfers In", ItemAvail."Data Element"::"Transfers Out");
                    ItemAvail.FilterGroup(0);
                    ItemAvailDrillDown2(ItemNo, VariantCode, LocationCode, BegDate, EndDate, ItemAvail);
                end;
            ItemAvail."Data Element"::"Transfers In":
                begin
                    TransLine.SetRange("Derived From Line No.", 0);
                    TransLine.SetRange("Item No.", ItemNo);
                    TransLine.SetRange("Variant Code", VariantCode);
                    TransLine.SetRange("Transfer-to Code", LocationCode);
                    // P8001083
                    //FORM.RUNMODAL(0,TransLine);
                    TransferLines.SetTableView(TransLine);
                    LotStatusExclusionFilter := LotStatusMgmt.SetLotStatusExclusionFilter(LotStatus.FieldNo("Available for Planning"));
                    TransferLines.SetLotStatus(LotStatusExclusionFilter);
                    TransferLines.RunModal;
                    // P8001083
                end;
            ItemAvail."Data Element"::"Transfers Out":
                begin
                    TransLine.SetRange("Derived From Line No.", 0);
                    TransLine.SetRange("Item No.", ItemNo);
                    TransLine.SetRange("Variant Code", VariantCode);
                    TransLine.SetRange("Transfer-from Code", LocationCode);
                    PAGE.RunModal(0, TransLine);
                end;
        end;

        ItemAvail.Copy(ItemAvail2);
    end;

    procedure ItemAvailDrillDown2(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; BegDate: Date; EndDate: Date; var ItemAvail: Record "Item Availability" temporary)
    var
        DrillDownForm: Page "Req. Wksh. Avail. DrillDown";
    begin
        DrillDownForm.SetData(ItemNo, VariantCode, LocationCode, BegDate, EndDate, ItemAvail);
        DrillDownForm.RunModal;
    end;

    procedure ProjectUsage(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; BaseDate: Date; EndDate: Date; var Projection: Record "Usage History and Projection" temporary)
    var
        ItemLedger: Record "Item Ledger Entry";
        Formula: Record "Usage Formula";
        DateFormula: Code[10];
        i: Integer;
        GrowthFactor: Decimal;
    begin
        Projection.Reset;
        Projection.DeleteAll;

        GetUsageFormula(ItemNo, VariantCode, LocationCode, Formula);
        if Formula.Code = '' then
            exit;

        case Formula.Period of
            Formula.Period::Day:
                DateFormula := '1D';
            Formula.Period::Week:
                DateFormula := '1W';
            Formula.Period::Month:
                DateFormula := '1M';
        end;

        Projection."Period Offset" := 1;
        Projection."Start Date - Current" := BaseDate;
        Projection."End Date - Current" := CalcDate(DateFormula, Projection."Start Date - Current") - 1;
        Projection.Insert;
        while Projection."End Date - Current" < EndDate do begin
            Projection."Period Offset" += 1;
            Projection."Start Date - Current" := Projection."End Date - Current" + 1;
            Projection."End Date - Current" := CalcDate(DateFormula, Projection."Start Date - Current");
            Projection.Insert;
        end;

        DateFormula := '-' + DateFormula;
        Projection.Find('-');
        for i := 1 to Formula."No. of Periods" do begin
            Projection."Period Offset" -= 1;
            Projection."End Date - Current" := Projection."Start Date - Current" - 1;
            Projection."Start Date - Current" := CalcDate(DateFormula, Projection."End Date - Current") + 1;
            Projection.Insert;
        end;

        ItemLedger.SetCurrentKey("Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");
        ItemLedger.SetRange("Item No.", ItemNo);
        ItemLedger.SetFilter("Entry Type", '%1|%2', ItemLedger."Entry Type"::Sale, ItemLedger."Entry Type"::Consumption);
        ItemLedger.SetRange("Variant Code", VariantCode);
        ItemLedger.SetRange("Drop Shipment", false);
        ItemLedger.SetRange("Location Code", LocationCode);

        Projection.Find('-');
        repeat
            Projection."Start Date - Comp." := CalcDate(Formula."Comparison Period Formula", Projection."Start Date - Current");
            Projection."End Date - Comp." := CalcDate(Formula."Comparison Period Formula", Projection."End Date - Current");
            ItemLedger.SetRange("Posting Date", Projection."Start Date - Comp.", Projection."End Date - Comp.");
            ItemLedger.CalcSums(Quantity);
            Projection."Comparison Period" := -ItemLedger.Quantity;
            if Projection."Period Offset" <= 0 then begin
                ItemLedger.SetRange("Posting Date", Projection."Start Date - Current", Projection."End Date - Current");
                ItemLedger.CalcSums(Quantity);
                Projection."Current Period" := -ItemLedger.Quantity;
            end;
            Projection.Modify;
        until Projection.Next = 0;

        Projection.SetFilter("Period Offset", '<=0');
        Projection.CalcSums("Comparison Period", "Current Period");
        if Projection."Comparison Period" <> 0 then
            GrowthFactor := Projection."Current Period" / Projection."Comparison Period"
        else
            GrowthFactor := 1;

        Projection.Reset;
        Projection.SetFilter("Period Offset", '>0');
        if Projection.Find('-') then
            repeat
                Projection."Current Period" := Round(Projection."Comparison Period" * GrowthFactor,
                  Formula."Rounding Precision", Format(Formula."Rounding Method"));
                Projection.Modify;
            until Projection.Next = 0;

        Projection.Reset;
    end;

    procedure GetUsageFormula(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; var Formula: Record "Usage Formula")
    var
        SKU: Record "Stockkeeping Unit";
        Item: Record Item;
        ItemCat: Record "Item Category";
        FormulaCode: Code[10];
    begin
        if SKU.Get(LocationCode, ItemNo, VariantCode) and (SKU."Usage Formula" <> '') then
            Formula.Get(SKU."Usage Formula")
        else
            if Item.Get(ItemNo) and (Item."Usage Formula" <> '') then
                Formula.Get(Item."Usage Formula")
            // P8007749
            else
                if Item."Item Category Code" <> '' then
                    if ItemCat.Get(Item."Item Category Code") then begin
                        FormulaCode := ItemCat.GetUsageFormula;
                        if FormulaCode <> '' then
                            Formula.Get(FormulaCode)
                    end;
        // P8007749
    end;

    procedure LoadItemVendor(ItemNo: Code[20]; VariantCode: Code[10]; var ItemVend: Record "Item Vendor" temporary)
    var
        Item: Record Item;
        ItemVendor: Record "Item Vendor";
        Vendor: Record Vendor;
    begin
        ItemVend.Reset;
        ItemVend.DeleteAll;

        if ItemNo = '' then // P8001004
            exit;             // P8001004

        ItemVendor.SetRange("Item No.", ItemNo);
        ItemVendor.SetRange("Variant Code", VariantCode);
        if ItemVendor.Find('-') then
            repeat
                ItemVend := ItemVendor;
                ItemVend.Insert;
            until ItemVendor.Next = 0;

        Item.Get(ItemNo);
        if Item."Vendor No." <> '' then begin
            ItemVend.SetRange("Vendor No.", Item."Vendor No.");
            if not ItemVend.Find('-') then begin
                ItemVend."Vendor No." := Item."Vendor No.";
                ItemVend."Item No." := ItemNo;
                ItemVend."Variant Code" := '';
                ItemVend."Lead Time Calculation" := Item."Lead Time Calculation";
                ItemVend."Vendor Item No." := Item."Vendor Item No.";
                ItemVend.Insert;
            end;
            ItemVend.Reset;
        end;

        if ItemVend.Find('-') then; // P8001004
    end;

    procedure AddItemToWorksheet(WkshTemplate: Code[10]; WkshName: Code[10]; ItemNo: Code[20])
    var
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
        ReqLine: Record "Requisition Line";
        LineNo: Integer;
    begin
        Item.Get(ItemNo);
        SKU.SetRange("Item No.", ItemNo);
        if not SKU.Find('-') then begin
            SKU."Item No." := ItemNo;
            SKU."Variant Code" := '';
            SKU."Location Code" := '';
            SKU."Replenishment System" := Item."Replenishment System";
            SKU."Reordering Policy" := Item."Reordering Policy";
        end;

        ReqLine.LockTable;
        ReqLine.SetRange("Worksheet Template Name", WkshTemplate);
        ReqLine.SetRange("Journal Batch Name", WkshName);
        if ReqLine.Find('+') then
            LineNo := ReqLine."Line No.";
        ReqLine.SetCurrentKey(Type, "No.", "Variant Code", "Location Code");
        ReqLine.SetRange(Type, ReqLine.Type::Item);
        ReqLine.SetRange("No.", ItemNo);
        repeat
            ReqLine.SetRange("Variant Code", SKU."Variant Code");
            ReqLine.SetRange("Location Code", SKU."Location Code");
            if not ReqLine.Find('-') then
                if (SKU."Replenishment System" = SKU."Replenishment System"::Purchase) and
                  (SKU."Reordering Policy" <> SKU."Reordering Policy"::" ")
                then begin
                    LineNo += 10000;
                    ReqLine.Init;
                    ReqLine."Worksheet Template Name" := WkshTemplate;
                    ReqLine."Journal Batch Name" := WkshName;
                    ReqLine."Line No." := LineNo;
                    ReqLine.Validate(Type, ReqLine.Type::Item);
                    ReqLine.Validate("No.", ItemNo);
                    ReqLine.Validate("Variant Code", SKU."Variant Code");
                    ReqLine.Validate("Location Code", SKU."Location Code");
                    ReqLine.Validate("Action Message", ReqLine."Action Message"::New);
                    ReqLine.Validate("Accept Action Message", false);
                    ReqLine.Insert;
                end;
        until SKU.Next = 0;
    end;
}

