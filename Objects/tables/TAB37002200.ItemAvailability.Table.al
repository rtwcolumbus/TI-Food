table 37002200 "Item Availability"
{
    // PR3.70.08
    // P8000178A, Myers Nissi, Jack Reynolds, 08 FEB 05
    //   This table is used on a temporary basis to store the calculated data for presentation on the sales board
    // 
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 21 SEP 05
    //   Add support for production changes in drill down
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Changes to Item Ledger keys
    // 
    // PRW15.00.02
    // P8000618A, VerticalSoft, Jack Reynolds, 11 AUG 08
    //   RENAMED - was Sales Board
    // 
    // PRW16.00.04
    // P8000887, VerticalSoft, Jack Reynolds, 08 DEC 10
    //   Fix drilldown to show in-transit quantity at in-transit location
    // 
    // PRW16.00.05
    // P8000936, Columbus IT, Jack Reynolds, 25 APR 11
    //   Support for Repack Orders on Sales Board
    // 
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW111.00.01
    // P80060684, To Increase, Jack Reynolds, 07 AUG 18
    //   DataClassification property
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Item Availability';
    DrillDownPageID = "Item Availability Drilldown";
    ReplicateData = false;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = SystemMetadata;
        }
        field(3; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = SystemMetadata;
        }
        field(4; "Date Offset"; Integer)
        {
            Caption = 'Date Offset';
            DataClassification = SystemMetadata;
        }
        field(5; "Data Element"; Option)
        {
            Caption = 'Data Element';
            DataClassification = SystemMetadata;
            OptionCaption = 'On Hand,Available,Purchases,Purchase Orders,Purchase Returns,Sales,Sales Orders,Sales Returns,Output,Production Output,Repack Output,Consumption,Production Components,Repack Components,Transfers,Transfers In,Transfers Out';
            OptionMembers = "On Hand",Available,Purchases,"Purchase Orders","Purchase Returns",Sales,"Sales Orders","Sales Returns",Output,"Production Output","Repack Output",Consumption,"Production Components","Repack Components",Transfers,"Transfers In","Transfers Out";
        }
        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
        }
        field(7; "Date Text"; Text[30])
        {
            Caption = 'Date Text';
            DataClassification = SystemMetadata;
        }
        field(8; "Includes Production Changes"; Boolean)
        {
            Caption = 'Includes Production Changes';
            DataClassification = SystemMetadata;
        }
        field(9; "Record No."; BigInteger)
        {
            Caption = 'Record No.';
            DataClassification = SystemMetadata;
        }
        field(10; "Quantity Not Available"; Decimal)
        {
            Caption = 'Quantity Not Available';
            DataClassification = SystemMetadata;
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Location Code", "Date Offset", "Data Element")
        {
            SumIndexFields = Quantity;
        }
        key(Key2; "Record No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        ProdPlanChange: Record "Daily Prod. Planning-Change" temporary;

    procedure DrillDown(VariantFilter: Text[1024]; LocationFilter: Text[1024]; LotStatusExclusionFilter: Text[1024]; var Date: Record Date)
    var
        Item: Record Item;
        ItemLedger: Record "Item Ledger Entry";
        PurchaseLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        ProdOrderLine: Record "Prod. Order Line";
        TempProdOrderLine: Record "Prod. Order Line" temporary;
        ProdOrderComp: Record "Prod. Order Component";
        TempProdOrderComp: Record "Prod. Order Component" temporary;
        RepackOrder: Record "Repack Order";
        RepackOrderLine: Record "Repack Order Line";
        TransferLine: Record "Transfer Line";
        DrillDown: Page "Item Availability Drilldown";
        ItemLedgerEntries: Page "Item Ledger Entries";
        TransferLines: Page "Transfer Lines";
        Date1: Date;
        Date2: Date;
        LineNo: Integer;
    begin
        // P8001083 - add parameter for LotStatusExclusionFilter
        Date.Find('-');
        if "Date Offset" = -1 then begin
            Date1 := 0D;
            Date2 := Date."Period Start" - 1;
        end else begin
            Date.Next("Date Offset");
            Date1 := Date."Period Start";
            Date2 := NormalDate(Date."Period End");
        end;

        case "Data Element" of
            "Data Element"::Available, "Data Element"::Purchases, "Data Element"::Sales,       // P8000936
              "Data Element"::Output, "Data Element"::Consumption, "Data Element"::Transfers: // P8000936
                begin
                    DrillDown.SetParameters(VariantFilter, LocationFilter, LotStatusExclusionFilter, Date, Rec); // P8001083
                    DrillDown.SetProdPlanChange(ProdPlanChange); // P8000187A
                    DrillDown.RunModal;
                end;
            "Data Element"::"On Hand":
                begin
                    ItemLedger.SetCurrentKey("Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code"); // P8000267B
                    ItemLedger.SetRange("Drop Shipment", false);
                    ItemLedger.SetRange("Item No.", "Item No.");
                    if VariantFilter <> '' then
                        ItemLedger.SetFilter("Variant Code", VariantFilter);
                    if LocationFilter <> '' then
                        ItemLedger.SetFilter("Location Code", LocationFilter);
                    // P8001083
                    //FORM.RUNMODAL(0,ItemLedger);
                    ItemLedgerEntries.SetTableView(ItemLedger);
                    ItemLedgerEntries.SetLotStatus(LotStatusExclusionFilter);
                    ItemLedgerEntries.RunModal;
                    // P8001083
                end;
            "Data Element"::"Purchase Orders", "Data Element"::"Purchase Returns":
                begin
                    PurchaseLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Expected Receipt Date");
                    PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
                    PurchaseLine.SetRange("No.", "Item No.");
                    PurchaseLine.SetRange("Drop Shipment", false);
                    PurchaseLine.SetRange("Expected Receipt Date", Date1, Date2);
                    if VariantFilter <> '' then
                        PurchaseLine.SetFilter("Variant Code", VariantFilter);
                    if LocationFilter <> '' then
                        PurchaseLine.SetFilter("Location Code", LocationFilter);
                    case "Data Element" of
                        "Data Element"::"Purchase Orders":
                            PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                        "Data Element"::"Purchase Returns":
                            PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::"Return Order");
                    end;
                    PAGE.RunModal(0, PurchaseLine);
                end;
            "Data Element"::"Sales Orders", "Data Element"::"Sales Returns":
                begin
                    SalesLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Shipment Date");
                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                    SalesLine.SetRange("No.", "Item No.");
                    SalesLine.SetRange("Drop Shipment", false);
                    SalesLine.SetRange("Shipment Date", Date1, Date2);
                    if VariantFilter <> '' then
                        SalesLine.SetFilter("Variant Code", VariantFilter);
                    if LocationFilter <> '' then
                        SalesLine.SetFilter("Location Code", LocationFilter);
                    case "Data Element" of
                        "Data Element"::"Sales Orders":
                            SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                        "Data Element"::"Sales Returns":
                            SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Return Order");
                    end;
                    PAGE.RunModal(0, SalesLine);
                end;
            "Data Element"::"Production Output":
                begin
                    ProdOrderLine.SetCurrentKey(Status, "Item No.", "Variant Code", "Location Code", "Due Date");
                    ProdOrderLine.SetRange(Status, ProdOrderLine.Status::"Firm Planned", ProdOrderLine.Status::Released); // P8000187A
                    ProdOrderLine.SetRange("Item No.", "Item No.");
                    ProdOrderLine.SetRange("Due Date", Date1, Date2);
                    if VariantFilter <> '' then
                        ProdOrderLine.SetFilter("Variant Code", VariantFilter);
                    if LocationFilter <> '' then
                        ProdOrderLine.SetFilter("Location Code", LocationFilter);
                    // P8000187A
                    if "Includes Production Changes" then begin
                        if ProdOrderLine.Find('-') then
                            repeat
                                TempProdOrderLine := ProdOrderLine;
                                TempProdOrderLine.Insert;
                            until ProdOrderLine.Next = 0;
                        ProdPlanChange.Reset;
                        ProdPlanChange.SetRange("Item No.", "Item No.");
                        ProdPlanChange.SetRange(Type, ProdPlanChange.Type::Output);
                        ProdPlanChange.SetRange(Date, Date1, Date2);
                        if VariantFilter <> '' then
                            ProdPlanChange.SetFilter("Variant Code", VariantFilter);
                        if LocationFilter <> '' then
                            ProdPlanChange.SetFilter("Location Code", LocationFilter);
                        LineNo := 10000000;
                        if ProdPlanChange.Find('-') then
                            repeat
                                LineNo += 1;
                                Item.Get(ProdPlanChange."Item No.");
                                TempProdOrderLine.Status := ProdPlanChange.Status;
                                TempProdOrderLine."Prod. Order No." := ProdPlanChange."Production Order No.";
                                TempProdOrderLine."Line No." := LineNo;
                                TempProdOrderLine.Init;
                                TempProdOrderLine."Item No." := ProdPlanChange."Item No.";
                                TempProdOrderLine.Description := Item.Description;
                                TempProdOrderLine."Variant Code" := ProdPlanChange."Variant Code";
                                TempProdOrderLine."Location Code" := ProdPlanChange."Location Code";
                                TempProdOrderLine."Due Date" := ProdPlanChange.Date;
                                TempProdOrderLine.Quantity := ProdPlanChange.Quantity;
                                TempProdOrderLine."Quantity (Base)" := ProdPlanChange."Quantity (Base)";
                                TempProdOrderLine."Remaining Quantity" := ProdPlanChange.Quantity;
                                TempProdOrderLine."Remaining Qty. (Base)" := ProdPlanChange."Quantity (Base)";
                                TempProdOrderLine.Insert;
                            until ProdPlanChange.Next = 0;
                        PAGE.RunModal(0, TempProdOrderLine);
                    end else
                        // P8000187A
                        PAGE.RunModal(0, ProdOrderLine);
                end;
            "Data Element"::"Production Components":
                begin
                    ProdOrderComp.SetCurrentKey(Status, "Item No.", "Variant Code", "Location Code", "Due Date");
                    ProdOrderComp.SetRange(Status, ProdOrderComp.Status::"Firm Planned", ProdOrderComp.Status::Released); // P8000187A
                    ProdOrderComp.SetRange("Item No.", "Item No.");
                    ProdOrderComp.SetRange("Due Date", Date1, Date2);
                    if VariantFilter <> '' then
                        ProdOrderComp.SetFilter("Variant Code", VariantFilter);
                    if LocationFilter <> '' then
                        ProdOrderComp.SetFilter("Location Code", LocationFilter);
                    // P8000187A
                    if "Includes Production Changes" then begin
                        if ProdOrderComp.Find('-') then
                            repeat
                                TempProdOrderComp := ProdOrderComp;
                                TempProdOrderComp.Insert;
                            until ProdOrderComp.Next = 0;
                        ProdPlanChange.Reset;
                        ProdPlanChange.SetRange("Item No.", "Item No.");
                        ProdPlanChange.SetRange(Type, ProdPlanChange.Type::Consumption);
                        ProdPlanChange.SetRange(Date, Date1, Date2);
                        if VariantFilter <> '' then
                            ProdPlanChange.SetFilter("Variant Code", VariantFilter);
                        if LocationFilter <> '' then
                            ProdPlanChange.SetFilter("Location Code", LocationFilter);
                        LineNo := 10000000;
                        if ProdPlanChange.Find('-') then
                            repeat
                                LineNo += 1;
                                Item.Get(ProdPlanChange."Item No.");
                                TempProdOrderComp.Status := ProdPlanChange.Status;
                                TempProdOrderComp."Prod. Order No." := ProdPlanChange."Production Order No.";
                                TempProdOrderComp."Prod. Order Line No." := ProdPlanChange."Prod. Order Line No.";
                                TempProdOrderComp.Init;
                                TempProdOrderComp."Line No." := LineNo;
                                TempProdOrderComp."Item No." := ProdPlanChange."Item No.";
                                TempProdOrderComp.Description := Item.Description;
                                TempProdOrderComp."Variant Code" := ProdPlanChange."Variant Code";
                                TempProdOrderComp."Location Code" := ProdPlanChange."Location Code";
                                TempProdOrderComp."Due Date" := ProdPlanChange.Date;
                                TempProdOrderComp."Expected Quantity" := ProdPlanChange.Quantity;
                                TempProdOrderComp."Expected Qty. (Base)" := ProdPlanChange."Quantity (Base)";
                                TempProdOrderComp."Remaining Quantity" := ProdPlanChange.Quantity;
                                TempProdOrderComp."Remaining Qty. (Base)" := ProdPlanChange."Quantity (Base)";
                                TempProdOrderComp.Insert;
                            until ProdPlanChange.Next = 0;
                        PAGE.RunModal(0, TempProdOrderComp);
                    end else
                        // P8000187A
                        PAGE.RunModal(0, ProdOrderComp);
                end;
            // P8000936
            "Data Element"::"Repack Output":
                begin
                    RepackOrder.SetCurrentKey(Status, "Item No.", "Variant Code", "Destination Location", "Due Date");
                    RepackOrder.SetRange(Status, RepackOrder.Status::Open);
                    RepackOrder.SetRange("Item No.", "Item No.");
                    if VariantFilter <> '' then
                        RepackOrder.SetRange("Variant Code", VariantFilter);
                    if LocationFilter <> '' then
                        RepackOrder.SetRange("Destination Location", LocationFilter);
                    RepackOrder.SetRange("Due Date", Date1, Date2);
                    PAGE.RunModal(0, RepackOrder);
                end;
            "Data Element"::"Repack Components":
                begin
                    RepackOrderLine.SetRange(Status, RepackOrderLine.Status::Open);
                    RepackOrderLine.SetRange(Type, RepackOrderLine.Type::Item);
                    RepackOrderLine.SetRange("No.", "Item No.");
                    if VariantFilter <> '' then
                        RepackOrderLine.SetRange("Variant Code", VariantFilter);
                    RepackOrderLine.SetRange("Due Date", Date1, Date2);
                    RepackOrderLine.SetCurrentKey(Status, Type, "No.", "Variant Code", "Source Location", "Due Date");
                    if LocationFilter <> '' then
                        RepackOrderLine.SetRange("Source Location", LocationFilter);
                    if RepackOrderLine.FindSet then
                        repeat
                            RepackOrderLine.Mark(RepackOrderLine.Quantity > RepackOrderLine."Quantity Transferred");
                        until RepackOrderLine.Next = 0;
                    RepackOrderLine.SetRange("Source Location");
                    RepackOrderLine.SetCurrentKey(Status, Type, "No.", "Variant Code", "Repack Location", "Due Date");
                    if LocationFilter <> '' then
                        RepackOrderLine.SetRange("Repack Location", LocationFilter);
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
            "Data Element"::"Transfers In", "Data Element"::"Transfers Out":
                begin
                    if ("Data Element" = "Data Element"::"Transfers In") or (LocationFilter = '') then // P8000887
                        TransferLine.SetRange("Derived From Line No.", 0);
                    TransferLine.SetRange("Item No.", "Item No.");
                    if VariantFilter <> '' then
                        TransferLine.SetFilter("Variant Code", VariantFilter);
                    case "Data Element" of
                        "Data Element"::"Transfers In":
                            begin
                                TransferLine.SetCurrentKey("Transfer-from Code", Status, "Derived From Line No.", "Item No.", "Variant Code",
                                  "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Shipment Date");
                                TransferLine.SetRange("Receipt Date", Date1, Date2);
                                if LocationFilter <> '' then
                                    TransferLine.SetFilter("Transfer-to Code", LocationFilter);
                                TransferLines.SetLotStatus(LotStatusExclusionFilter); // P8001083
                            end;
                        "Data Element"::"Transfers Out":
                            begin
                                TransferLine.SetCurrentKey("Transfer-to Code", Status, "Derived From Line No.", "Item No.", "Variant Code",
                                  "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Receipt Date");
                                TransferLine.SetRange("Shipment Date", Date1, Date2);
                                if LocationFilter <> '' then
                                    TransferLine.SetFilter("Transfer-from Code", LocationFilter);
                            end;
                    end;
                    // P8001083
                    //FORM.RUNMODAL(0,TransferLine);
                    TransferLines.SetTableView(TransferLine);
                    TransferLines.RunModal;
                    // P8001083
                end;
        end;
    end;

    procedure SetProdPlanChange(var PPchange: Record "Daily Prod. Planning-Change" temporary)
    begin
        // P8000187A
        ProdPlanChange.Reset;
        ProdPlanChange.DeleteAll;
        if PPchange.Find('-') then
            repeat
                ProdPlanChange := PPchange;
                ProdPlanChange.Insert;
            until PPchange.Next = 0;
    end;
}

