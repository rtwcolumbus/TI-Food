codeunit 37002461 "Process 800 Prod. Order Mgt."
{
    // PR1.20
    //   Functions for creating orders, populating journals, and posting orders
    // 
    // PR1.20.03
    //   Add function for creating Xref entry and call from CreatePackageOrder
    // 
    // PR2.00
    //   Modify for dimensions
    //   Modify for Item Tracking
    //   Pull routing data into output journal line
    // 
    // PR2.00.02
    //   Use same lot number for output and consumption of intermediate
    // 
    // PR2.00.05
    //   Add logic to create orders and lines with variant codes
    // 
    // PR3.10
    //   New Production Order table, Consumption and Output Journal moved to Item Journal
    //   Call delete trigger when deleting item journal lines
    // 
    // PR3.60
    // 
    // PR3.60.02
    //   Add calls to GetItem in SetProdBOMQuantity, SetProdOrderQuantity, SetProdOrderCompQuantity
    // 
    // PR3.61.01
    //   Fix unit of measure conversion problem when creating auto plan orders
    // 
    // PR3.61.03
    //   FillOutputAndConsumpJnl - Fix problem generating consumption journal lines for shared components
    // 
    // PR3.70
    //   Remove reference to Bind Code in reservation entry
    //   Change call to CopyItemTracking for additional parameter
    // 
    // PR3.70.03
    //   Modified FillOuputAndConsumpJnl, CreateProcessOrder, CreatePackageOrder, CreateBatchOrder Functions
    //     to use new GetUOMRndgPrecision function
    //     item."Rounding precision" will reflect UOM specific Rounding Precision if available
    //   GetAlternateQtyPerUOM - was not discriminating between costing quantity and alternate quantity; added
    //     new function GetCostingQtyPerUOM and changed calls as necessary to call the correct function
    // 
    // PR3.70.04
    // P8000043A, Myers Nissi, Jack Reynolds, 02 JUN 04
    //    Support for easy lot tracking
    // 
    // P8000051A, Myers Nissi, Jack Reynolds, 03 JUN 04
    //   UpdatePostingDate - exit if order number is blank
    // 
    // PR7.70.05
    // P8000064A, Myers Nissi, Jack Reynolds, 02 JUL 04
    //   FillOutputAndConsumpJnl - expected consumption quantity for package orders is based on finished output
    //     (if any posted); quantity defaults to zero if any quantity already posted; don't remove consumption lines
    //     with zero quantity
    //   PostOrder - remove output and consumption lines with zero quantity prior to posting
    // 
    // PR3.70.06
    // P8000072A, Myers Nissi, Jack Reynolds, 16 JUL 04
    //   FillOutputAndConsumpJnl - fix problem with expected quantity for shared components
    // 
    // P8000075A, Myers Nissi, Jack Reynolds, 22 JUL 04
    //   FillOutputAndConsumpJnl - don't create item tracking lines unless the quantity is non-zero
    // 
    // P8000084A, Myers Nissi, Jack Reynolds, 09 AUG 04
    //   FillOutputAndConsumpJnl - add FIND('-') after setting filters for Batch Prod. Order No.
    // 
    // P8000087A, Myers Nissi, Jack Reynolds, 17 AUG 04
    //   TransProdOrderXref - delete the cross reference entry before calling RemovePlanningOrder
    // 
    // P8000092A, Myers Nissi, Jack Reynolds, 20 AUG 04
    //   PostOrder - break the posting into 4 parts: +output, -consumption, -output, +consumption
    // 
    // P8000093A, Myers Nissi, Jack Reynolds, 20 AUG 04
    //   FillOutputAndConsumpJnl - after processing production order components, process item ledger to find
    //     consumption not related to a planned component
    // 
    // PR3.70.10
    // P8000209A, Myers Nissi, Jack Reynolds, 10 MAY 05
    //   Forward flush components for released orders
    // 
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 22 SEP 05
    //   Add function to calculate production order start and end date and time
    // 
    // P8000250B, Myers Nissi, Jack Reynolds, 18 OCT 05
    //   Support for alternate lot number assignemnt methods
    // 
    // P8000259A, VerticalSoft, Jack Reynolds, 04 NOV 05
    //   Set proruction sequence code
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Changes to Item Ledger keys
    // 
    // PR4.00.02
    // P8000317A, VerticalSoft, Jack Reynolds, 30 MAR 06
    //   Fix problem in CreateOrderHeader where validation of equipment code clears due date
    // 
    // P8000316A, VerticalSoft, Jack Reynolds, 31 MAR 06
    //   Add logic for selectively handeling output or consumption in FillOutputAndConsumpJnl, UpdatePostingDate, and
    //     PostOrder
    //   Add new function to delete journal lines for batch and process reporting
    // 
    // PR4.00.03
    // P8000341A, VerticalSoft, Jack Reynolds, 17 MAY 06
    //   Change OrderNo parameter from Code10 to Code20 for FillOutputAndConsumpJnl and DeleteOutputAndConsumpJnl
    // 
    // PR4.00.04
    // P8000350A, VerticalSoft, Jack Reynolds, 11 JUL 06
    //   Fix problem creating package order without batch order
    // 
    // P8000359A, VerticalSoft, Jack Reynolds, 26 JUL 06
    //   Fix problem with equipment location on production order header
    // 
    // P8000387A, VerticalSoft, Jack Reynolds, 26 SEP 06
    //   Fix calculation of consumption quantity to use scrap %
    // 
    // P8000397A, VerticalSoft, Jack Reynolds, 03 OCT 06
    //   When posting from batch reporting move intermediate output form output to consumption bin
    // 
    // P8000401A, VerticalSoft, Jack Reynolds, 04 OCT 06
    //   Fix Reservation Entry already exists error with CreateComponentItemTracking
    // 
    // PR4.00.05
    // P8000422A, VerticalSoft, Jack Reynolds, 12 DEC 06
    //   Fix problem populating consumption journal in batch reporting
    // 
    // P8000444A, VerticalSoft, Jack Reynolds, 15 FEB 07
    //   When posting for batch reporting release locks after posting the batch
    // 
    // P8000447B, VerticalSoft, Jack Reynolds, 19 FEB 07
    //   Remove leftover code from OnRun trigger
    // 
    // PR4.00.06
    // P8000476A, VerticalSoft, Jack Reynolds, 29 MAY 07
    //   Fix problem with production order header having incorrect start/end dates
    // 
    // P8000479A, VerticalSoft, Jack Reynolds, 31 MAY 07
    //   Fix problem of doubling of lot tracknig for output journal lines in batch reporting
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Fix bug creating only a package order
    // 
    // P8000494A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Production Bins/Replenishment
    // 
    // PRW15.00.01
    // P8000518A, VerticalSoft, Jack Reynolds, 14 SEP 07
    //   CreateOrderHeader - check for non-blank location if Location Mandatory is set
    // 
    // P8000519A, VerticalSoft, Jack Reynolds, 14 SEP 07
    //   TransferProdOrderXref - Use TRUE parameter when deleting xref record so production order line quantity is updated
    // 
    // P8000531A, VerticalSoft, Jack Reynolds, 22 OCT 07
    //   Problem creating conusmption journal lines
    // 
    // P8000551A, VerticalSoft, Jack Reynolds, 04 DEC 07
    //   Rounding of unit cost on BOM lines
    // 
    // P8000571A, VerticalSoft, Jack Reynolds, 14 FEB 08
    //   FillOutputAndConsumpJnl - remove MODIFY immediately after INSERT
    // 
    // P8000572A, VerticalSoft, Jack Reynolds, 14 FEB 08
    //   Automatically delete tracking when deleting output/consumption journal lines
    // 
    // P8000580A, VerticalSoft, Jack Reynolds, 20 FEB 08
    //   Code Cleanup - CLEAR followed by INIT
    // 
    // P8000595A, VerticalSoft, Jack Reynolds, 19 MAR 08
    //   Fix problem with rounding of expected quantity for consumption journal lines
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    // 
    // PRW16.00.01
    // P8000681, VerticalSoft, Jack Reynolds, 06 MAR 09
    //   Fix problem with production order dates on package order
    // 
    // PRW16.00.03
    // P8000806, VerticalSoft, Jack Reynolds, 01 APR 10
    //   Fix problem in MoveOutput with inbound bin
    // 
    // PRW16.00.04
    // P8000870, VerticalSoft, Don Bresee, 21 SEP 10
    //   Rework by-product costing
    // 
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Modify for Batch Planning
    // 
    // P8000900, Columbus IT, Jack Reynolds, 14 FEB 11
    //   Modify for muli-line batch orders
    // 
    // P8000904, Columbus IT, Jack Reynolds, 14 FEB 11
    //   Consolidate redundant functions GetNextOutputLineNo and GetNextConsumpLineNo
    // 
    // PRW16.00.05
    // P8000987, Columbus IT, Jack Reynolds, 21 OCT 11
    //   Fix problem is alternate quantity on batch reporting output journal lines
    // 
    // PRW16.00.06
    // P8001054, Columbus IT, Jack Reynolds, 04 APR 12
    //   Fix problem with Replenishment Area not being set on component lines
    // 
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // P8001072, Columbus IT, Jack Reynolds, 01 JUN 12
    //   Fix problem with order line number and auto plan components
    // 
    // P8001081, Columbus IT, Jack Reynolds, 21 JUN 12
    //   Fix missing BOM No and Versoin on production order lines
    // 
    // P8001092, Columbus IT, Don Bresee, 17 AUG 12
    //   Add validation logic for new fields
    // 
    // PRW17.00
    // P8001142, Columbus IT, Don Bresee, 09 MAR 13
    //   Rework Replenishment logic
    // 
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10
    // P8001231, Columbus IT, Jack Reynolds, 22 OCT 13
    //   Add support for Shift Code
    // 
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats
    // 
    // P8001243, Columbus IT, Jack Reynolds, 20 NOV 13
    //   Fix problem with due dates on component lines
    // 
    // PRW17.10.02
    // P8001301, Columbus IT, Jack Reynolds, 03 MAR 14
    //   Update Rollup 4
    // 
    // P8001303, Columbus IT, Jack Reynolds, 05 MAR 14
    //   Fix problem committing changes before all posting has completed
    // 
    // PRW17.10.03
    // P8001314, Columbus IT, Jack Reynolds, 23 APR 14
    //   Fix problem reassigniong lot number when posting
    // 
    // PRW18.00.01
    // P8001385, Columbus IT, Jack Reynolds, 08 MAY 15
    //   Fix problem deleting output and consumption journal lines
    // 
    // PRW18.00.01
    // P8001391, Columbus IT, Jack Reynolds, 06 JUL 15
    //   Add Variant code to batch reporting output and consumption journals
    // 
    // PRW19.00.01
    // P8008029, To-Increase, Dayakar Battini, 18 NOV 16
    //   Planning worksheet Date calculations
    // 
    // P8008050, To-Increase, Dayakar Battini, 05 DEC 16
    //   Fix issue with scaling consumption Qty on posted output qty
    // 
    // PRW110.0.02
    // P80046446, To-Increase, Dayakar Battini, 07 Sep 17
    //   Fix issue with custom lot formats.
    // 
    // P80049623, Columbus IT, Jack Reynolds, 30 NOV 17
    //   Fix problem with bin code in consumption journal for batch reporting
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW11300.03
    // P80082969, To Increase, Jack Reynolds, 26 SEP 19
    //   New Events
    // 
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW120.00
    // P800144605, To Increase, Jack Reynolds, 20 APR 22
    //   Upgrade to 20.0


    trigger OnRun()
    begin
    end;

    var
        Item: Record Item;
        UOMMgmt: Codeunit "Unit of Measure Management";
        ProdOrderStatusMgt: Codeunit "Prod. Order Status Management";
        ProcessFns: Codeunit "Process 800 Functions";
        BatchItem: Code[20];
        BatchLotNo: Code[50];
        LastProdOrderLineNo: Integer;
        Text001: Label '%1 exceeds %2.';
        Text002: Label 'Order %1 can only have shared components.';
        Text003: Label 'Order %1 cannot have shared components.';
        TempStdCost: array[6] of Decimal;
        TempExpCost: array[6] of Decimal;
        TempActCost: array[6] of Decimal;
        Text004: Label 'The Order must have at least one line that is not a %1.';
        ProdOrderComp: Record "Prod. Order Component";
        Text005: Label 'Location must be specified.';
        Text006: Label '%1 %2 is a %3 on Co-Product BOM No. %4.';

    procedure CreateAutoPlanOrder(Status: Integer; OrderNo: Code[20]; LineNo: Integer; StartDate: Date; LocCode: Code[10]; Direction: Integer)
    var
        MfgSetup: Record "Manufacturing Setup";
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderCalculate: Codeunit "Calculate Prod. Order";
        Filler: Code[10];
        xLastProdOrderLineNo: Integer;
    begin
        // P8000877
        xLastProdOrderLineNo := LastProdOrderLineNo; // P8001072
        ProdOrderComp.Reset;
        ProdOrderComp.SetRange(Status, Status);
        ProdOrderComp.SetRange("Prod. Order No.", OrderNo);
        ProdOrderComp.SetRange("Prod. Order Line No.", LineNo);
        ProdOrderComp.SetRange("Auto Plan", true);
        if ProdOrderComp.Find('-') then begin
            MfgSetup.Get;
            MfgSetup.TestField("Planned Order Nos."); // P8000877
            repeat
                Clear(ProdOrder);
                CreateOrderHeader(ProdOrder,
                  ProdOrder.Status::Planned,  // P8000877
                  MfgSetup."Planned Order Nos.", // P8000877
                  Filler,
                  ProdOrder."Source Type"::Item,
                  ProdOrderComp."Item No.",
                  ProdOrderComp."Variant Code", // PR2.00.05
                  ProdOrderComp."Expected Quantity" * ProdOrderComp."Qty. per Unit of Measure", // PR3.61.01
                  StartDate,
                  LocCode,
                  0, // P8001133
                  '',
                  0,
                  Status,
                  OrderNo,
                  '');
                CreateOrderLine(ProdOrder,
                  ProdOrderLine,
                  ProdOrderComp."Item No.",
                  ProdOrderComp."Variant Code", // PR2.00.05
                  ProdOrderComp."Expected Quantity",
                  ProdOrderComp."Unit of Measure Code", '', ''); // PR3.60, P8000877
                ProdOrderCalculate.Calculate(ProdOrderLine, Direction, true, true, true, true); // P8001301
                ProdOrderLine.Find; // P8000197A
                ProdOrder.Find; // P8000476A

                ProdOrder.SetDefaultProductionSequence; // P8000259A
                ProdOrder.Modify;                       // P8000259A
            until ProdOrderComp.Next = 0;
        end;
        LastProdOrderLineNo := xLastProdOrderLineNo; // P8001072
    end;

    procedure CreateProcessOrder(var ProdOrder: Record "Production Order"; ProdOrderLine: Record "Prod. Order Line"; InputItem: Code[20]; OrderStatus: Integer; OutputItem: Code[20]; OutputQty: Decimal; StartDate: Date; Loc: Code[10]; DimensionSetID: Integer; LotNo: Code[50]; OutputUOM: Code[10]; Direction: Integer; BOMNo: Code[20])
    var
        Item: Record Item;
        ProcessSetup: Record "Process Setup";
        ProdOrderComp: Record "Prod. Order Component";
        ProdOrderCalculate: Codeunit "Calculate Prod. Order";
        Filler: Code[20];
    begin
        // P8001133 - new parameter for DimensionSetID
        ProcessSetup.Get;
        ProcessSetup.TestField("Process Order Nos.");

        // PR3.60 Begin
        Item.Get(OutputItem);
        if Item.GetItemUOMRndgPrecision(OutputUOM, false) then  // PR3.70.03
            OutputQty := Round(OutputQty, Item."Rounding Precision", '>');
        // PR3.60
        CreateOrderHeader(ProdOrder,
          OrderStatus,
          ProcessSetup."Process Order Nos.",
          Filler,
          // PR3.10
          // ProdOrder."Source Type"::Item,
          ProdOrder."Source Type",
          // PR3.10
          OutputItem,
          '', // PR2.00.05
          OutputQty,
          StartDate,
          Loc,
          DimensionSetID, // P8001133
          '',
          ProdOrder."Order Type"::Process,
          0,
          '',
          InputItem);
        CreateOrderLine(
          ProdOrder,
          ProdOrderLine,
          OutputItem,
          '', // PR2.00.05
          OutputQty,
          OutputUOM, BOMNo, ''); // PR3.60, P8000877

        CreateOutputItemTracking(ProdOrderLine, BatchLotNo); // PR2.00

        ProdOrderCalculate.Calculate(ProdOrderLine, Direction, true, true, true, true); // Components, P8001301
        ProdOrderLine.Find; // P8000197A
        ProdOrder.Find; // P8000476A

        CreateComponentItemTracking(ProdOrderLine, InputItem, '', LotNo); // PR2.00, P8001030

        ProdOrder.SetDefaultProductionSequence; // P8000259A
        ProdOrder.Modify;                       // P8000259A

        if ProdOrder.Status = ProdOrder.Status::Released then                     // P8000209A
            ProdOrderStatusMgt.FlushProdOrder(ProdOrder, ProdOrder.Status, WorkDate); // P8000209A
    end;

    procedure CreateOrderHeader(var ProdOrder: Record "Production Order"; OrderStatus: Integer; NoSeries: Code[20]; var SubOrder: Code[10]; SourceType: Integer; Source: Code[20]; VariantCode: Code[10]; OrderQty: Decimal; StartDate: Date; Loc: Code[10]; DimensionSetID: Integer; Equip: Code[20]; OrderType: Integer; ParentStatus: Integer; ParentNo: Code[20]; InputItem: Code[20])
    var
        Item: Record Item;
        InvSetup: Record "Inventory Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;
        DimensionSetIDArr: array[10] of Integer;
    begin
        // P80053245 - Enlarge NoSeries
        // P8001133 - add parameter for DimensionSetID
        // P8000518A
        InvSetup.Get;
        if InvSetup."Location Mandatory" and (Loc = '') then
            Error(Text005);
        // P8000518A

        Clear(ProdOrder);
        ProdOrder.Init;
        if (OrderType = ProdOrder."Order Type"::Package) and (NoSeries = '') then begin
            SubOrder := IncStr(SubOrder);
            ProdOrder."No." := ParentNo + '-' + SubOrder;
            ProdOrder."No. Series" := '';
        end else
            NoSeriesMgt.InitSeries(NoSeries, '', StartDate, ProdOrder."No.", ProdOrder."No. Series");
        ProdOrder.Validate(Status, OrderStatus);
        ProdOrder.Insert(true);

        ProdOrder."Location Code" := Loc; // P8000359A - moved up from below
        ProdOrder.Validate("Equipment Code", Equip); // P8000317A - moved up from below
        // P8000681 - moved up from below
        ProdOrder."Source Type" := SourceType;
        ProdOrder.Validate("Source No.", Source);
        if SourceType = ProdOrder."Source Type"::Item then // PR2.00.05
            ProdOrder.Validate("Variant Code", VariantCode);  // PR2.00.05
        // P8000681
        ProdOrder."Starting Date" := StartDate;
        ProdOrder."Creation Date" := WorkDate;
        ProdOrder."Due Date" := StartDate;
        ProdOrder."Ending Date" := ProdOrder."Due Date" - 1;
        ProdOrder."Low-Level Code" := 1;
        // P8000681 - move the following 4 lines up
        //ProdOrder."Source Type" := SourceType;
        //ProdOrder.VALIDATE("Source No.",Source);
        //IF SourceType = ProdOrder."Source Type"::Item THEN // PR2.00.05
        //  ProdOrder.VALIDATE("Variant Code",VariantCode);  // PR2.00.05
        // P8000681
        //ProdOrder."Location Code" := Loc; // P8000359A
        ProdOrder.Quantity := OrderQty;
        //ProdOrder.VALIDATE("Equipment Code",Equip); // P8000317A
        ProdOrder."Order Type" := OrderType;
        if OrderType = ProdOrder."Order Type"::Batch then begin
            ProdOrder.Validate("Batch Order", true);
            ProdOrder."Batch Prod. Order No." := ProdOrder."No.";
        end;
        if OrderType = ProdOrder."Order Type"::Package then
            ProdOrder.Validate("Batch Prod. Order No.", ParentNo)
        else begin
            ProdOrder."Parent Order Status" := ParentStatus;
            ProdOrder."Parent Order No." := ParentNo;
        end;
        ProdOrder."Input Item No." := InputItem;
        // P8001133
        DimensionSetIDArr[1] := DimensionSetID;
        DimensionSetIDArr[2] := ProdOrder."Dimension Set ID";
        ProdOrder."Dimension Set ID" :=
          DimMgt.GetCombinedDimensionSetID(DimensionSetIDArr, ProdOrder."Shortcut Dimension 1 Code", ProdOrder."Shortcut Dimension 2 Code");
        // P8001133
        ProdOrder.Modify;
        ProdOrder.Get(ProdOrder.Status, ProdOrder."No.");

        LastProdOrderLineNo := 0; // PR3.10
    end;

    procedure CreateOrderLine(var ProdOrder: Record "Production Order"; var ProdOrderLine: Record "Prod. Order Line"; LineItem: Code[20]; LineVariantCode: Code[10]; LineQty: Decimal; LineUOM: Code[10]; LineBOMNo: Code[20]; EQCode: Code[20])
    var
        Item: Record Item;
    begin
        // P8000877 - Add parameter for equipment code
        ProdOrderLine.Init;
        ProdOrderLine.Validate(Status, ProdOrder.Status);
        ProdOrderLine.Validate("Prod. Order No.", ProdOrder."No.");

        // PR3.10
        // ProdOrderLine.VALIDATE("Line No.",10000);
        LastProdOrderLineNo := LastProdOrderLineNo + 10000;
        ProdOrderLine.Validate("Line No.", LastProdOrderLineNo);
        // PR3.10
        ProdOrderLine.Validate("Item No.", LineItem);
        ProdOrderLine.Validate("Variant Code", LineVariantCode); // PR2.00.05
        if LineBOMNo <> '' then                                   // PR3.60
            ProdOrderLine.Validate("Production BOM No.", LineBOMNo); // PR3.60
        ProdOrderLine.Validate("Location Code", ProdOrder."Location Code"); // PR3.60
        ProdOrderLine.Validate(Quantity, LineQty);
        ProdOrderLine.Validate("Unit of Measure Code", LineUOM);
        ProdOrderLine.Validate("Equipment Code", EQCode); // P8000877
        ProdOrderLine.Insert(true);

        if ProdOrder."Order Type" = ProdOrder."Order Type"::Package then begin
            Item.Get(LineItem);
            ProdOrder.Validate("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
            ProdOrder.Modify;
        end;
    end;

    procedure CreateXrefEntry(TableID: Integer; DocType: Integer; DocNo: Code[20]; LineNo: Integer; OrderStatus: Integer; OrderNo: Code[20]; OrderLineNo: Integer; Qty: Decimal)
    var
        ProdXref: Record "Production Order XRef";
    begin
        // PR1.20.03 Begin
        ProdXref."Source Table ID" := TableID;
        ProdXref."Source Type" := DocType;
        ProdXref."Source No." := DocNo;
        ProdXref."Source Line No." := LineNo;
        ProdXref."Prod. Order Status" := OrderStatus;
        ProdXref."Prod. Order No." := OrderNo;
        ProdXref."Prod. Order Line No." := OrderLineNo;
        ProdXref."Quantity (Base)" := Qty;
        ProdXref.Insert(true);
        // PR1.20.03 End
    end;

    procedure CreateOutputItemTracking(var ProdOrderLine: Record "Prod. Order Line"; var LotNo: Code[50])
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ResEntry: Record "Reservation Entry";
        ProdOrderLine2: Record "Prod. Order Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        P800ItemTracking: Codeunit "Process 800 Item Tracking";
    begin
        // P8000043A - pass ProdOrderLine by reference so Lot No. is avaialble in calling environment
        // PR3.60 Begin - create item tracking entry for production order line
        Item.Get(ProdOrderLine."Item No.");
        if (Item."Item Tracking Code" <> '') then begin
            ItemTrackingCode.Get(Item."Item Tracking Code");
            // P8000250B then
            if (ItemTrackingCode."Lot Specific Tracking") and (LotNo = '') then begin
                if ProcessFns.TrackingInstalled then begin
                    ProdOrderLine2 := ProdOrderLine;                         // P8001234
                                                                             //ProdOrderLine2."Due Date" := 0D;                         // P8001234  // P80046446
                    if P800ItemTracking.OKToAssignLotNo(ProdOrderLine2) then // P8001234
                        LotNo := P800ItemTracking.AssignLotNo(ProdOrderLine2); // P8001234
                end else
                    if Item."Lot Nos." <> '' then
                        LotNo := NoSeriesMgt.GetNextNo(Item."Lot Nos.", Today, true);
            end;
            if LotNo <> '' then begin
                // P8000250B
                ResEntry.Init;
                ResEntry."Creation Date" := Today;
                ResEntry."Created By" := UserId;
                ResEntry."Reservation Status" := ResEntry."Reservation Status"::Surplus;
                ResEntry."Source Type" := DATABASE::"Prod. Order Line";
                ResEntry."Source Subtype" := ProdOrderLine.Status;
                ResEntry."Source ID" := ProdOrderLine."Prod. Order No.";
                ResEntry."Source Prod. Order Line" := ProdOrderLine."Line No.";
                ResEntry.Positive := true;
                ResEntry."Item No." := ProdOrderLine."Item No.";
                ResEntry."Variant Code" := ProdOrderLine."Variant Code";
                ResEntry."Location Code" := ProdOrderLine."Location Code";
                ResEntry."Expected Receipt Date" := ProdOrderLine."Due Date";
                //IF (Item."Lot Nos." <> '') AND (LotNo = '') THEN              // P8000250B
                //  LotNo := NoSeriesMgt.GetNextNo(Item."Lot Nos.",TODAY,TRUE); // P8000250B
                ResEntry."Lot No." := LotNo;
                ResEntry.UpdateItemTracking; // P88000877
                ResEntry.Validate("Quantity (Base)", ProdOrderLine."Remaining Qty. (Base)");
                ResEntry.Insert(true);
                ProdOrderLine."Lot No." := LotNo; // P8000043A
                ProdOrderLine.Modify;             // P8000043A
            end;
        end;
        // PR3.60 End
    end;

    procedure CreateComponentItemTracking(ProdOrderLine: Record "Prod. Order Line"; ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50])
    var
        ProdOrderComp: Record "Prod. Order Component";
        ResEntry: Record "Reservation Entry";
    begin
        // PR3.60 Begin - create item tracking entry for production order component
        // P8001030 - add parameter for VariantCode
        if LotNo <> '' then begin
            ProdOrderComp.SetRange(Status, ProdOrderLine.Status);
            ProdOrderComp.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
            ProdOrderComp.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
            ProdOrderComp.SetRange("Item No.", ItemNo);
            ProdOrderComp.SetRange("Variant Code", VariantCode); // P8001030
            if ProdOrderComp.Find('-') then
                repeat
                    Clear(ResEntry); // P8000401A
                                     //ResEntry.INIT; // P8000580A
                    ResEntry."Creation Date" := Today;
                    ResEntry."Created By" := UserId;
                    ResEntry."Reservation Status" := ResEntry."Reservation Status"::Surplus;
                    ResEntry."Source Type" := DATABASE::"Prod. Order Component";
                    ResEntry."Source Subtype" := ProdOrderComp.Status;
                    ResEntry."Source ID" := ProdOrderComp."Prod. Order No.";
                    ResEntry."Source Prod. Order Line" := ProdOrderLine."Line No.";
                    ResEntry."Source Ref. No." := ProdOrderComp."Line No.";
                    ResEntry.Positive := false;
                    ResEntry."Item No." := ProdOrderComp."Item No.";
                    ResEntry."Variant Code" := ProdOrderComp."Variant Code";
                    ResEntry."Location Code" := ProdOrderComp."Location Code";
                    ResEntry."Shipment Date" := ProdOrderComp."Due Date";
                    ResEntry."Lot No." := LotNo;
                    ResEntry.UpdateItemTracking; // P88000877
                    ResEntry.Validate("Quantity (Base)", -ProdOrderComp."Expected Qty. (Base)");
                    ResEntry.Insert(true);
                    ProdOrderComp."Lot No." := LotNo; // P8000043A
                    ProdOrderComp.Modify;             // P8000043A
                until ProdOrderComp.Next = 0;
        end;
        // PR2.00 End
    end;

    procedure FillOutputAndConsumpJnl(OrderNo: Code[20]; ProdDate: Date; ShiftCode: Code[10]; CalcOutput: Boolean; CalcConsumption: Boolean; OutputTemplate: Code[10]; OutputBatch: Code[10]; ConsumptionTemplate: Code[10]; ConsumptionBatch: Code[10])
    var
        Item: Record Item;
        OutputJnlTemplate: Record "Item Journal Template";
        OutputJnlBatch: Record "Item Journal Batch";
        ConsumpJnlTemplate: Record "Item Journal Template";
        ConsumpJnlBatch: Record "Item Journal Batch";
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        ItemLedger: Record "Item Ledger Entry";
        ProdOrderRtgLine: Record "Prod. Order Routing Line";
        OutputJnlLine: Record "Item Journal Line";
        ConsumpJnlLine: Record "Item Journal Line";
        UnitOfMeasMgt: Codeunit "Unit of Measure Management";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        UnitOfMeasConv: Decimal;
        NeededQty: Decimal;
        ProdBOMHeader: Record "Production BOM Header";
    begin
        // P8000316A - add parameters for CalcOutput, CalcConsumption
        // P8000341A - Change OrderNo from Code10 to Code20
        // P8001231 - add parameter for ShiftCode
        OutputJnlLine.LockTable;
        ConsumpJnlLine.LockTable;

        OutputJnlTemplate.Get(OutputTemplate);
        OutputJnlBatch.Get(OutputTemplate, OutputBatch);

        ConsumpJnlTemplate.Get(ConsumptionTemplate);               // PR3.10
        ConsumpJnlBatch.Get(ConsumptionTemplate, ConsumptionBatch); // PR3.10

        ProdOrder.Get(ProdOrder.Status::Released, OrderNo);
        /*PR2.00 Begin
        IF ProdOrder."Order Type" = ProdOrder."Order Type"::Batch THEN BEGIN
          IntermediateNo := ProdOrder."Source No.";
          IF IntermediateNo <> '' THEN BEGIN
            ProdOrderLine.SETRANGE(Status,ProdOrder.Status);
            ProdOrderLine.SETRANGE("Prod. Order No.",ProdOrder."No.");
            ProdOrderLine.SETRANGE("Item No.",IntermediateNo);
            IF ProdOrderLine.FIND('-') THEN
              IntermediateLot := ProdOrderLine."Lot No.";
          END;
        END;
        PR2.00 End*/
        if ProdOrder."Order Type" = ProdOrder."Order Type"::Batch then begin
            ProdOrder.Reset;
            ProdOrder.SetCurrentKey(Status, "Batch Prod. Order No.");
            ProdOrder.SetRange(Status, ProdOrder.Status::Released);
            ProdOrder.SetRange("Batch Prod. Order No.", OrderNo);
        end else
            ProdOrder.SetRecFilter;
        ProdOrder.Find('-'); // P8000084A

        repeat
            // Run through the production orders and populate the consumption journal and
            // output journal for each line of each production order
            ProdOrderLine.Reset;
            ProdOrderLine.SetRange(Status, ProdOrder.Status);
            ProdOrderLine.SetRange("Prod. Order No.", ProdOrder."No.");

            ConsumpJnlLine.Reset;
            ConsumpJnlLine.SetRange("Journal Template Name", ConsumptionTemplate);
            ConsumpJnlLine.SetRange("Journal Batch Name", ConsumptionBatch);
            ConsumpJnlLine.SetRange("Order Type", ConsumpJnlLine."Order Type"::Production); // P8001132
            ConsumpJnlLine.SetRange("Order No.", ProdOrder."No.");                          // P8001132

            OutputJnlLine.Reset;
            OutputJnlLine.SetRange("Journal Template Name", OutputTemplate);
            OutputJnlLine.SetRange("Journal Batch Name", OutputBatch);
            OutputJnlLine.SetRange("Order Type", OutputJnlLine."Order Type"::Production); // P8001132
            OutputJnlLine.SetRange("Order No.", ProdOrder."No.");                         // P8001132

            if ProdOrderLine.Find('-') then begin
                if ProdOrder."Family Process Order" then // PR3.61.03
                    ProdOrderLine."Line No." := 0;         // PR3.61.03
                repeat
                    // Find components for the production order line
                    ProdOrderComp.SetRange(Status, ProdOrder.Status);
                    ProdOrderComp.SetRange("Prod. Order No.", ProdOrder."No.");
                    ProdOrderComp.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
                    ConsumpJnlLine.SetRange("Order Line No.", ProdOrderLine."Line No."); // P8001132
                    if CalcConsumption then // P8000316A
                        if ProdOrderComp.Find('-') then
                            repeat
                                // For each component add a record to the consumption journal
                                ConsumpJnlLine.SetRange("Prod. Order Comp. Line No.", ProdOrderComp."Line No.");
                                if not ConsumpJnlLine.Find('-') then begin
                                    Item.Get(ProdOrderComp."Item No.");
                                    ConsumpJnlLine.Init;
                                    ConsumpJnlLine."Journal Template Name" := ConsumptionTemplate;
                                    ConsumpJnlLine."Journal Batch Name" := ConsumptionBatch;
                                    ConsumpJnlLine."Line No." := GetNextItemJnlLineNo( // P800094
                                      ConsumpJnlLine."Journal Template Name",
                                      ConsumpJnlLine."Journal Batch Name",
                                      ProdOrder."No.");
                                    ConsumpJnlLine.Validate("Entry Type", ConsumpJnlLine."Entry Type"::Consumption); // PR3.10
                                    ConsumpJnlLine.Validate("Posting Date", ProdDate);
                                    ConsumpJnlLine.Validate("Work Shift Code", ShiftCode); // P8001231
                                    ConsumpJnlLine.Validate("Order Type", ConsumpJnlLine."Order Type"::Production); // P8001132
                                    ConsumpJnlLine.Validate("Order No.", ProdOrder."No."); // P8001132
                                    ConsumpJnlLine.Validate("Document No.", OrderNo);
                                    ConsumpJnlLine.Validate("Item No.", ProdOrderComp."Item No."); // PR3.10
                                                                                                   //            ConsumpJnlLine.VALIDATE("No.",ProdOrderComp."Item No."); // PR3.10
                                    if ConsumpJnlLine."Variant Code" <> ProdOrderComp."Variant Code" then   // P8001391
                                        ConsumpJnlLine.Validate("Variant Code", ProdOrderComp."Variant Code"); // P8001391
                                    ConsumpJnlLine.Validate("Unit of Measure Code", ProdOrderComp."Unit of Measure Code");
                                    // P8000064A Begin
                                    //IF ProdOrderLine."Line No." <> 0 THEN BEGIN // P8000072A
                                    if (ProdOrderLine."Finished Quantity" <> 0) and
                                      (ProdOrder."Order Type" = ProdOrder."Order Type"::Package)
                                    then
                                        // P8000387A
                                        ConsumpJnlLine."Expected Quantity" := ProdOrderComp.ProdOrderNeeds *
                        ProdOrderComp.Quantity * ProdOrderLine."Finished Qty. (Base)" / ProdOrderLine."Quantity (Base)"
                                    //ConsumpJnlLine."Expected Quantity" := ProdOrderLine."Finished Quantity" *
                                    //  ProdOrderComp.Quantity
                                    // P8000387A
                                    else
                                        ConsumpJnlLine."Expected Quantity" := ProdOrderComp."Expected Quantity"; // P8000072A
                                                                                                                 //END;                                        // P8000072A
                                                                                                                 // P8000064A End
                                                                                                                 // PR3.70.03 Begin
                                    if Item.GetItemUOMRndgPrecision(ProdOrderComp."Unit of Measure Code", true) then // P8000595A
                                        ConsumpJnlLine."Expected Quantity" :=                                      // P8000064A
                                          Round(ConsumpJnlLine."Expected Quantity", Item."Rounding Precision", '>'); // P8000064A
                                                                                                                     //ELSE                                                                       // P8000064A
                                    ConsumpJnlLine.Validate("Expected Quantity");                                // P8000064A
                                                                                                                 //ConsumpJnlLine.VALIDATE(Quantity,ConsumpJnlLine."Expected Quantity");      // P8000064A
                                                                                                                 // PR3.70.03 End
                                    ConsumpJnlLine.Description := ProdOrderComp.Description;
                                    ConsumpJnlLine.Validate("Location Code", ProdOrderLine."Location Code"); // P80049623
                                    ConsumpJnlLine."Order Line No." := ProdOrderComp."Prod. Order Line No."; // P8001132
                                    ConsumpJnlLine.Validate("Prod. Order Comp. Line No.", ProdOrderComp."Line No."); // PR2.00
                                    if ConsumpJnlLine.PostedQuantity = 0 then                                    // P8000064A
                                        ConsumpJnlLine.Validate(Quantity, ConsumpJnlLine."Expected Quantity");      // P8000064A

                                    /*PR2.00 Begin
                                                IF (ProdOrder."Order Type" = ProdOrder."Order Type"::Package) AND
                                                  (IntermediateNo = ConsumpJnlLine."No.")
                                                THEN
                                                  ConsumpJnlLine.VALIDATE("Lot No.",IntermediateLot)
                                                ELSE
                                                  ConsumpJnlLine.VALIDATE("Lot No.",ProdOrderComp."Lot No.");
                                    PR2.00 End*/
                                    ConsumpJnlLine."Source Code" := ConsumpJnlTemplate."Source Code";
                                    ConsumpJnlLine."Reason Code" := ConsumpJnlBatch."Reason Code";
                                    //            ConsumpJnlLine."No. Series" := ConsumpJnlBatch."Posting No. Series"; // PR3.10
                                    ConsumpJnlLine.Insert;
                                    if ConsumpJnlLine.PostedQuantity = 0 then // P8000075A
                                        ItemTrackingMgt.CopyItemTracking(ProdOrderComp.RowID1, ConsumpJnlLine.RowID1, false); // PR3.70
                                    ConsumpJnlLine.GetLotNo; // P8000043A
                                    ConsumpJnlLine.UpdateLotTracking(true); // P8000422A
                                    ConsumpJnlLine.Modify;   // P8000043A
                                end else
                                    repeat
                                        ConsumpJnlLine.Validate("Posting Date", ProdDate);
                                        ConsumpJnlLine.Validate("Work Shift Code", ShiftCode); // P8001231
                                        ConsumpJnlLine.Modify;
                                    until ConsumpJnlLine.Next = 0;
                            until ProdOrderComp.Next = 0;

                    // P8000093A Begin
                    // Now check item ledger for unplanned consumption and add line to consumption journal for each item
                    ConsumpJnlLine.SetRange("Prod. Order Comp. Line No.", 0);
                    ItemLedger.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type", "Prod. Order Comp. Line No."); // P8000267B, P8001132
                    ItemLedger.SetRange("Order Type", ItemLedger."Order Type"::Production); // P8001132
                    ItemLedger.SetRange("Order No.", ProdOrder."No.");                      // P8001132
                    ItemLedger.SetRange("Order Line No.", ProdOrderLine."Line No.");        // P8001132
                    ItemLedger.SetRange("Prod. Order Comp. Line No.", 0);
                    ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::Consumption);
                    if CalcConsumption then // P8000316A
                        if ItemLedger.Find('-') then
                            repeat
                                ConsumpJnlLine.SetRange("Item No.", ItemLedger."Item No.");
                                if not ConsumpJnlLine.Find('-') then begin
                                    Item.Get(ItemLedger."Item No.");
                                    ConsumpJnlLine.Init;
                                    ConsumpJnlLine."Journal Template Name" := ConsumptionTemplate;
                                    ConsumpJnlLine."Journal Batch Name" := ConsumptionBatch;
                                    ConsumpJnlLine."Line No." := GetNextItemJnlLineNo( // P800094
                                      ConsumpJnlLine."Journal Template Name",
                                      ConsumpJnlLine."Journal Batch Name",
                                      ProdOrder."No.");
                                    ConsumpJnlLine.Validate("Entry Type", ConsumpJnlLine."Entry Type"::Consumption);
                                    ConsumpJnlLine.Validate("Posting Date", ProdDate);
                                    ConsumpJnlLine.Validate("Work Shift Code", ShiftCode); // P8001231
                                    ConsumpJnlLine.Validate("Order Type", ConsumpJnlLine."Order Type"::Production); // P8001132
                                    ConsumpJnlLine.Validate("Order No.", ProdOrder."No."); // P8001132
                                    ConsumpJnlLine.Validate("Document No.", OrderNo);
                                    ConsumpJnlLine.Validate("Item No.", ItemLedger."Item No.");
                                    if ConsumpJnlLine."Variant Code" <> ItemLedger."Variant Code" then   // P8001391
                                        ConsumpJnlLine.Validate("Variant Code", ItemLedger."Variant Code"); // P8001391
                                    ConsumpJnlLine.Validate("Unit of Measure Code", ItemLedger."Unit of Measure Code");
                                    ConsumpJnlLine."Order Line No." := ProdOrderLine."Line No."; // P8001132
                                    ConsumpJnlLine.Validate("Location Code", ProdOrderLine."Location Code");
                                    ConsumpJnlLine."Source Code" := ConsumpJnlTemplate."Source Code";
                                    ConsumpJnlLine."Reason Code" := ConsumpJnlBatch."Reason Code";
                                    ConsumpJnlLine.Insert;
                                    //ConsumpJnlLine.MODIFY; // P8000571A
                                end else
                                    if not ConsumpJnlLine.Mark then begin
                                        ConsumpJnlLine.Validate("Posting Date", ProdDate);
                                        ConsumpJnlLine.Validate("Work Shift Code", ShiftCode); // P8001231
                                        ConsumpJnlLine.Modify;
                                    end;
                                ConsumpJnlLine.Mark(true);
                            until ItemLedger.Next = 0;
                    ConsumpJnlLine.SetRange("Item No."); // P8000531A

                    // P8000093A End

                    // Run through each line of the production orders and populate the
                    // output journal
                    if CalcOutput and (ProdOrderLine."Line No." <> 0) then begin // PR3.61.03, P8000316A
                                                                                 // PR2.00 Begin
                        ProdOrderRtgLine.SetRange(Status, ProdOrderLine.Status);
                        ProdOrderRtgLine.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
                        ProdOrderRtgLine.SetRange("Routing Reference No.", ProdOrderLine."Routing Reference No.");
                        ProdOrderRtgLine.SetRange("Routing No.", ProdOrderLine."Routing No.");
                        // PR2.00 End
                        OutputJnlLine.SetRange("Order Line No.", ProdOrderLine."Line No."); // P8001132
                        if not OutputJnlLine.Find('-') then begin
                            Item.Get(ProdOrderLine."Item No.");
                            OutputJnlLine.Init;
                            OutputJnlLine."Journal Template Name" := OutputTemplate;
                            OutputJnlLine."Journal Batch Name" := OutputBatch;
                            OutputJnlLine."Line No." := GetNextItemJnlLineNo( // P8000904
                              OutputJnlLine."Journal Template Name",
                              OutputJnlLine."Journal Batch Name",
                              ProdOrder."No.");
                            OutputJnlLine.Validate("Entry Type", OutputJnlLine."Entry Type"::Output); // PR3.10
                            OutputJnlLine.Validate("Posting Date", ProdDate);
                            OutputJnlLine.Validate("Work Shift Code", ShiftCode); // P8001231
                            OutputJnlLine.Validate("Order Type", OutputJnlLine."Order Type"::Production); // P8001132
                            OutputJnlLine.Validate("Order No.", ProdOrder."No."); // P8001132
                            OutputJnlLine.Validate("Document No.", OrderNo);
                            OutputJnlLine.Validate("Order Line No.", ProdOrderLine."Line No."); // P8001132
                            OutputJnlLine.Validate("Item No.", ProdOrderLine."Item No.");
                            if OutputJnlLine."Variant Code" <> ProdOrderLine."Variant Code" then   // P8001391
                                OutputJnlLine.Validate("Variant Code", ProdOrderLine."Variant Code"); // P8001391
                            OutputJnlLine.Validate("Location Code", ProdOrderLine."Location Code"); // P8000900
                                                                                                    // PR2.00 Begin
                            if ProdOrderRtgLine.Find('+') then begin
                                OutputJnlLine.Validate("Routing No.", ProdOrderRtgLine."Routing No.");
                                OutputJnlLine.Validate("Routing Reference No.", ProdOrderRtgLine."Routing Reference No.");
                                OutputJnlLine.Validate("Operation No.", ProdOrderRtgLine."Operation No.");
                            end;
                            OutputJnlLine.Validate("Setup Time", 0);
                            OutputJnlLine.Validate("Run Time", 0);
                            // PR2.00 End
                            OutputJnlLine.Validate("Expected Quantity", ProdOrderLine.Quantity); // P8000064A
                            OutputJnlLine.Validate("Unit of Measure Code", ProdOrderLine."Unit of Measure Code"); // PR3.10
                            if OutputJnlLine.PostedQuantity <> 0 then                                       // P8000064A
                                ProdOrderLine."Remaining Quantity" := 0;                                      // P8000064A
                            if Item."Rounding Precision" <> 0 then
                                OutputJnlLine.Validate("Output Quantity",                                     // P8000064A
                                  Round(ProdOrderLine."Remaining Quantity", Item."Rounding Precision", '>'))
                            else
                                OutputJnlLine.Validate("Output Quantity", ProdOrderLine."Remaining Quantity"); // P8000064A
                                                                                                               //OutputJnlLine.VALIDATE("Output Quantity",OutputJnlLine."Expected Quantity");  // P8000064A
                                                                                                               //OutputJnlLine."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
                            OutputJnlLine."Source Code" := OutputJnlTemplate."Source Code";
                            OutputJnlLine."Reason Code" := OutputJnlBatch."Reason Code";
                            //          OutputJnlLine."No. Series" := OutputJnlBatch."Posting No. Series"; // PR3.10
                            OutputJnlLine.Insert;
                            //OutputJnlLine.AutoLotNo(TRUE); // P8000316A, P8000479A
                            if OutputJnlLine.PostedQuantity = 0 then // P8000075A
                                ItemTrackingMgt.CopyItemTracking(ProdOrderLine.RowID1, OutputJnlLine.RowID1, false); // PR3.70
                            OutputJnlLine.GetLotNo; // P8000043A
                            OutputJnlLine.AutoLotNo(false); // P8000479A, P8001234, P8001314
                            OutputJnlLine.GetLotNo;  // P8000479A
                            OutputJnlLine.UpdateLotTracking(true); // P8000987
                            OutputJnlLine.Modify;   // P8000043A
                        end else
                            repeat
                                OutputJnlLine.Validate("Posting Date", ProdDate);
                                OutputJnlLine.Validate("Work Shift Code", ShiftCode); // P8001231
                                OutputJnlLine.Modify;
                                ;
                            until OutputJnlLine.Next = 0;
                    end; // PR3.61.03

                    /*P8000064A Begin
                    // Remove consumption journal lines with no quantity
                    ConsumpJnlLine.SETRANGE("Prod. Order Comp. Line No.");
                    ConsumpJnlLine.SETRANGE("Expected Quantity",0);

                    // ConsumpJnlLine.DELETEALL;
                    ConsumpJnlLine.DELETEALL(TRUE); // PR3.10
                    P8000064A End*/

                    // P8008050
                    if not ProdOrderLine."By-Product" then
                        if ProdBOMHeader.Get(ProdOrderLine."Production BOM No.") then
                            if ProdBOMHeader."Mfg. BOM Type" = ProdBOMHeader."Mfg. BOM Type"::BOM then
                                OutputJnlLine.SetConsumptionQty(OutputJnlLine);
                // P8008050
                until ProdOrderLine.Next = 0;
            end;
        until ProdOrder.Next = 0;

    end;

    procedure DeleteOutputAndConsumpJnl(OrderNo: Code[20]; OutputTemplate: Code[10]; OutputBatch: Code[10]; ConsumptionTemplate: Code[10]; ConsumptionBatch: Code[10])
    var
        ProdOrder: Record "Production Order";
        OutputJnlLine: Record "Item Journal Line";
        ConsumpJnlLine: Record "Item Journal Line";
    begin
        // P8000316A
        // P8000341A - Change OrderNo from Code10 to Code20
        // P8001385 - remove parameters for CalcOutput and CalcConsumption
        OutputJnlLine.LockTable;
        OutputJnlLine.SetCurrentKey("Entry Type", "Order No."); // P8001132
        OutputJnlLine.SetRange("Entry Type", OutputJnlLine."Entry Type"::Output);
        OutputJnlLine.SetRange("Journal Template Name", OutputTemplate);
        OutputJnlLine.SetRange("Journal Batch Name", OutputBatch);
        OutputJnlLine.SetRange("Order Type", OutputJnlLine."Order Type"::Production); // P8001132

        ConsumpJnlLine.LockTable;
        ConsumpJnlLine.SetCurrentKey("Entry Type", "Order No."); // P8001132
        ConsumpJnlLine.SetRange("Entry Type", ConsumpJnlLine."Entry Type"::Consumption);
        ConsumpJnlLine.SetRange("Journal Template Name", ConsumptionTemplate);
        ConsumpJnlLine.SetRange("Journal Batch Name", ConsumptionBatch);
        ConsumpJnlLine.SetRange("Order Type", ConsumpJnlLine."Order Type"::Production); // P8001132

        ProdOrder.Get(ProdOrder.Status::Released, OrderNo);
        if ProdOrder."Order Type" = ProdOrder."Order Type"::Batch then begin
            ProdOrder.Reset;
            ProdOrder.SetCurrentKey(Status, "Batch Prod. Order No.");
            ProdOrder.SetRange(Status, ProdOrder.Status::Released);
            ProdOrder.SetRange("Batch Prod. Order No.", OrderNo);
        end else
            ProdOrder.SetRecFilter;
        ProdOrder.Find('-');

        repeat
            OutputJnlLine.SetRange("Order No.", ProdOrder."No."); // P8001132
                                                                  // P8000572A
            if OutputJnlLine.FindSet(true, true) then
                repeat
                    OutputJnlLine.SetDeleteTracking(true);
                    OutputJnlLine.Delete(true);
                until OutputJnlLine.Next = 0;
            // P8000572A

            ConsumpJnlLine.SetRange("Order No.", ProdOrder."No."); // P8001132
                                                                   // P8000572A
            if ConsumpJnlLine.FindSet(true, true) then
                repeat
                    ConsumpJnlLine.SetDeleteTracking(true);
                    ConsumpJnlLine.Delete(true);
                until ConsumpJnlLine.Next = 0;
        // P8000572A
        until ProdOrder.Next = 0;
    end;

    procedure GetNextItemJnlLineNo(Template: Code[10]; Batch: Code[10]; ProdOrder: Code[20]): Integer
    var
        ProdJnlLine: Record "Item Journal Line";
    begin
        // P8000904 - Clear local setting
        ProdJnlLine.SetRange("Journal Template Name", Template);
        ProdJnlLine.SetRange("Journal Batch Name", Batch);
        ProdJnlLine.SetRange("Order Type", ProdJnlLine."Order Type"::Production); // P8001132
        ProdJnlLine.SetRange("Order No.", ProdOrder); // P8001132
        if ProdJnlLine.Find('+') then
            exit(ProdJnlLine."Line No." + 1000); // P8000531A
        ProdJnlLine.SetRange("Order No."); // P8001132
        if ProdJnlLine.Find('+') then
            exit(1000 + 1000000 * Round(ProdJnlLine."Line No." / 1000000, 1, '>')) // P8000531A
        else
            exit(1000); // P8000531A
    end;

    procedure UpdatePostingDate(OrderNo: Code[20]; PostingDate: Date; CalcOutput: Boolean; CalcConsumption: Boolean; OutputTemplate: Code[10]; OutputBatch: Code[10]; ConsumptionTemplate: Code[10]; ConsumptionBatch: Code[10])
    var
        ProdOrder: Record "Production Order";
        ConsumpJnlLine: Record "Item Journal Line";
        OutputJnlLine: Record "Item Journal Line";
    begin
        // P8000316A - add parameters for CalcOutput, CalcConsumption
        if OrderNo = '' then // P8000051A
            exit;              // P8000051A
        ProdOrder.Get(ProdOrder.Status::Released, OrderNo);
        if ProdOrder."Order Type" = ProdOrder."Order Type"::Batch then begin
            ProdOrder.Reset;
            ProdOrder.SetCurrentKey(Status, "Batch Prod. Order No.");
            ProdOrder.SetRange(Status, ProdOrder.Status::Released);
            ProdOrder.SetRange("Batch Prod. Order No.", OrderNo);
        end else
            ProdOrder.SetRecFilter;

        if ProdOrder.Find('-') then
            repeat
                if CalcConsumption then begin // P8000316A
                    ConsumpJnlLine.SetRange("Journal Template Name", ConsumptionTemplate);
                    ConsumpJnlLine.SetRange("Journal Batch Name", ConsumptionBatch);
                    ConsumpJnlLine.SetRange("Order Type", ConsumpJnlLine."Order Type"::Production); // P8001132
                    ConsumpJnlLine.SetRange("Order No.", ProdOrder."No."); // P8001132
                    if ConsumpJnlLine.Find('-') then
                        repeat
                            ConsumpJnlLine.Validate("Posting Date", PostingDate);
                            ConsumpJnlLine.Modify;
                        until ConsumpJnlLine.Next = 0;
                end;                          // P8000316A

                if CalcOutput then begin // P8000316A
                    OutputJnlLine.SetRange("Journal Template Name", OutputTemplate);
                    OutputJnlLine.SetRange("Journal Batch Name", OutputBatch);
                    OutputJnlLine.SetRange("Order Type", OutputJnlLine."Order Type"::Production); // P8001132
                    OutputJnlLine.SetRange("Order No.", ProdOrder."No."); // P8001132
                    if OutputJnlLine.Find('-') then
                        repeat
                            OutputJnlLine.Validate("Posting Date", PostingDate);
                            OutputJnlLine.Modify;
                        until OutputJnlLine.Next = 0;
                end;                     // P8000316A
            until ProdOrder.Next = 0;
    end;

    procedure UpdateShiftCode(OrderNo: Code[20]; ShiftCode: Code[10]; CalcOutput: Boolean; CalcConsumption: Boolean; OutputTemplate: Code[10]; OutputBatch: Code[10]; ConsumptionTemplate: Code[10]; ConsumptionBatch: Code[10])
    var
        ProdOrder: Record "Production Order";
        ConsumpJnlLine: Record "Item Journal Line";
        OutputJnlLine: Record "Item Journal Line";
    begin
        // P8001231
        if OrderNo = '' then
            exit;
        ProdOrder.Get(ProdOrder.Status::Released, OrderNo);
        if ProdOrder."Order Type" = ProdOrder."Order Type"::Batch then begin
            ProdOrder.Reset;
            ProdOrder.SetCurrentKey(Status, "Batch Prod. Order No.");
            ProdOrder.SetRange(Status, ProdOrder.Status::Released);
            ProdOrder.SetRange("Batch Prod. Order No.", OrderNo);
        end else
            ProdOrder.SetRecFilter;

        if ProdOrder.Find('-') then
            repeat
                if CalcConsumption then begin
                    ConsumpJnlLine.SetRange("Journal Template Name", ConsumptionTemplate);
                    ConsumpJnlLine.SetRange("Journal Batch Name", ConsumptionBatch);
                    ConsumpJnlLine.SetRange("Order Type", ConsumpJnlLine."Order Type"::Production);
                    ConsumpJnlLine.SetRange("Order No.", ProdOrder."No.");
                    if ConsumpJnlLine.Find('-') then
                        repeat
                            ConsumpJnlLine.Validate("Work Shift Code", ShiftCode);
                            ConsumpJnlLine.Modify;
                        until ConsumpJnlLine.Next = 0;
                end;

                if CalcOutput then begin
                    OutputJnlLine.SetRange("Journal Template Name", OutputTemplate);
                    OutputJnlLine.SetRange("Journal Batch Name", OutputBatch);
                    OutputJnlLine.SetRange("Order Type", OutputJnlLine."Order Type"::Production);
                    OutputJnlLine.SetRange("Order No.", ProdOrder."No.");
                    if OutputJnlLine.Find('-') then
                        repeat
                            OutputJnlLine.Validate("Work Shift Code", ShiftCode);
                            OutputJnlLine.Modify;
                        until OutputJnlLine.Next = 0;
                end;
            until ProdOrder.Next = 0;
    end;

    procedure PostOrder(OrderNo: Code[20]; ProdDate: Date; CalcOutput: Boolean; CalcConsumption: Boolean; OutputTemplate: Code[10]; OutputBatch: Code[10]; ConsumptionTemplate: Code[10]; ConsumptionBatch: Code[10]) Posted: Boolean
    var
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        OutputJnlLine: Record "Item Journal Line";
        ConsumpJnlLine: Record "Item Journal Line";
        ToProdOrder: Record "Production Order";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        ChangeStatus: Codeunit "Prod. Order Status Management";
        UpdateAnalysisView: Codeunit "Update Analysis View";
        UpdateItemAnalysisView: Codeunit "Update Item Analysis View";
        Selection: Integer;
        Text001: Label '&Finish Order,&Leave Order Open';
        DefaultSelection: Integer;
    begin
        // P8000316A - add parameters for CalcOutput, CalcConsumption; add return value
        // P80082969
        DefaultSelection := 1;
        OnPostOrderOnBeforeSelectStatus(OrderNo, ProdDate, CalcOutput, CalcConsumption, OutputTemplate, OutputBatch,
          ConsumptionTemplate, ConsumptionBatch, DefaultSelection, Selection);
        if Selection = 0 then
            Selection := StrMenu(Text001, DefaultSelection);
        // P80082969
        if Selection = 0 then
            exit;

        Posted := true; // P8000316A
        OutputJnlLine.Reset;
        OutputJnlLine.SetRange("Journal Template Name", OutputTemplate);
        OutputJnlLine.SetRange("Journal Batch Name", OutputBatch);
        OutputJnlLine.SetRange("Document No.", OrderNo);
        // P8000064A Begin
        OutputJnlLine.SetRange(Quantity, 0);
        OutputJnlLine.SetRange("Quantity (Alt.)", 0);
        OutputJnlLine.DeleteAll(true);
        OutputJnlLine.SetRange(Quantity);
        OutputJnlLine.SetRange("Quantity (Alt.)");
        // P8000064A End
        OutputJnlLine.SetFilter(Quantity, '>0'); // P8000092A
        if CalcOutput then // P8000316A
            if OutputJnlLine.Find('-') then begin
                ItemJnlPostBatch.SetSuppressCommit(true); // PR3.10, P80066030
                ItemJnlPostBatch.Run(OutputJnlLine); // PR3.10
            end;

        ConsumpJnlLine.Reset;
        ConsumpJnlLine.SetRange("Journal Template Name", ConsumptionTemplate);
        ConsumpJnlLine.SetRange("Journal Batch Name", ConsumptionBatch);
        ConsumpJnlLine.SetRange("Document No.", OrderNo);
        // P8000064A Begin
        ConsumpJnlLine.SetRange(Quantity, 0);
        ConsumpJnlLine.SetRange("Quantity (Alt.)", 0);
        ConsumpJnlLine.DeleteAll(true);
        ConsumpJnlLine.SetRange(Quantity);
        ConsumpJnlLine.SetRange("Quantity (Alt.)");
        // P8000064A End
        ConsumpJnlLine.SetFilter(Quantity, '<0'); // P8000092A
        if CalcConsumption then // P8000316A
            if ConsumpJnlLine.Find('-') then begin
                ItemJnlPostBatch.SetSuppressCommit(true); // PR3.10, P80066030
                ItemJnlPostBatch.Run(ConsumpJnlLine); // PR3.10
            end;

        MoveOutput(OrderNo, ProdDate, OutputTemplate, OutputBatch, ConsumptionTemplate, ConsumptionBatch); // P8000397A

        // P8000092A Begin
        OutputJnlLine.SetFilter(Quantity, '<0');
        if CalcOutput then // P8000316A
            if OutputJnlLine.Find('-') then begin
                ItemJnlPostBatch.SetSuppressCommit(true); // PR3.10, P80066030
                ItemJnlPostBatch.Run(OutputJnlLine);
            end;
        ConsumpJnlLine.SetFilter(Quantity, '>0');
        if CalcConsumption then // P8000316A
            if ConsumpJnlLine.Find('-') then begin
                ItemJnlPostBatch.SetSuppressCommit(true); // PR3.10, P80066030
                ItemJnlPostBatch.Run(ConsumpJnlLine);
            end;
        // P8000092A End

        UpdateAnalysisView.UpdateAll(0, true); // PR3.60
        UpdateItemAnalysisView.UpdateAll(0, true); // P8001303

        Commit; // P8000444A

        if Selection = 1 then begin
            ProdOrder.Get(ProdOrder.Status::Released, OrderNo);
            ChangeStatus.ChangeProdOrderStatus(ProdOrder, "Production Order Status"::Finished, ProdDate, true); // PR3.10, P800144605
            /*PR3.10 Begin
                ProdOrderCommentLine.SETRANGE(Status,ProdOrder.Status);
                ProdOrderCommentLine.SETRANGE("Prod. Order No.",ProdOrder."No.");
                IF ProdOrderCommentLine.FIND('-') THEN
                REPEAT
                    FinProdOrderCommentLine."Prod. Order No." := ToFinProdOrder."No.";
                    FinProdOrderCommentLine."Line No." := ProdOrderCommentLine."Line No.";
                    FinProdOrderCommentLine.Date := ProdOrderCommentLine.Date;
                    FinProdOrderCommentLine.Code := ProdOrderCommentLine.Code;
                    FinProdOrderCommentLine.Comment := ProdOrderCommentLine.Comment;
                    FinProdOrderCommentLine.INSERT;
                    ProdOrderCommentLine.DELETE;
                UNTIL ProdOrderCommentLine.NEXT = 0;
            PR3.10 End*/
        end;

    end;

    procedure MoveOutput(OrderNo: Code[20]; ProdDate: Date; OutputTemplate: Code[10]; OutputBatch: Code[10]; ConsumptionTemplate: Code[10]; ConsumptionBatch: Code[10])
    var
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        Location: Record Location;
        WhseEntry: Record "Warehouse Entry";
        ConsumptionJnl: Record "Item Journal Line";
        WhseAct: Codeunit "Process 800 Create Whse. Act.";
    begin
        // P8000397A
        ProdOrder.Get(ProdOrder.Status::Released, OrderNo);
        if (not Location.Get(ProdOrder."Location Code")) or (not Location."Bin Mandatory") then
            exit;
        // IF Location."Inbound Production Bin Code" = Location."Outbound Production Bin Code" THEN // P8000494A
        //   EXIT;                                                                                  // P8000494A

        ProdOrder.SetCurrentKey(Status, "Batch Prod. Order No.");
        ProdOrder.SetRange(Status, ProdOrder.Status::Released);
        ProdOrder.SetRange("Batch Prod. Order No.", OrderNo);
        ProdOrder.SetRange(Suborder, true);
        if not ProdOrder.Find('-') then
            exit;

        WhseEntry.SetCurrentKey("Reference No.", "Registering Date");
        WhseEntry.SetRange("Reference No.", OrderNo);
        WhseEntry.SetRange("Registering Date", ProdDate);
        WhseEntry.SetRange("Location Code", Location.Code);
        // WhseEntry.SETRANGE("Bin Code",Location."Outbound Production Bin Code"); // P8000494A
        WhseEntry.SetRange("Journal Template Name", OutputTemplate);
        WhseEntry.SetRange("Journal Batch Name", OutputBatch);
        WhseEntry.SetRange(Open, true);

        ConsumptionJnl.SetRange("Journal Template Name", ConsumptionTemplate);
        ConsumptionJnl.SetRange("Journal Batch Name", ConsumptionBatch);
        ConsumptionJnl.SetRange("Entry Type", ConsumptionJnl."Entry Type"::Consumption);

        ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Released);
        ProdOrderLine.SetRange("Prod. Order No.", OrderNo);
        ProdOrderLine.SetRange("By-Product", false);
        if ProdOrderLine.Find('-') then
            repeat
                // Move output from output bin to consumption bin
                WhseEntry.SetRange("Item No.", ProdOrderLine."Item No.");
                // P8000494A, P8000631A
                Location.Get(ProdOrderLine."Location Code");
                Location.SetFromProductionBin(ProdOrderLine."Prod. Order No.", ProdOrderLine."Line No."); // P8001142
                WhseEntry.SetRange("Bin Code", Location."From-Production Bin Code");
                ProdOrderComp.SetRange(Status, ProdOrderComp.Status::Released);
                ProdOrderComp.SetRange("Prod. Order No.", ProdOrder."No.");
                ProdOrderComp.SetRange("Item No.", ProdOrderLine."Item No.");
                if ProdOrderComp.FindFirst then begin
                    if ((ProdOrderComp."Planning Level Code" = 0) and    // P8000806
                       ((ProdOrderComp."Flushing Method" = ProdOrderComp."Flushing Method"::Manual) or
                        (ProdOrderComp."Flushing Method" = ProdOrderComp."Flushing Method"::"Pick + Backward") or
                        ((ProdOrderComp."Flushing Method" = ProdOrderComp."Flushing Method"::"Pick + Forward") and
                         (ProdOrderComp."Routing Link Code" <> '')))) or // P8000806
                       (not Location."Directed Put-away and Pick")       // P8000806
                    then
                        Location.SetToProductionBin(                                                                     // P8001142
                          ProdOrderComp."Prod. Order No.", ProdOrderComp."Prod. Order Line No.", ProdOrderComp."Line No.") // P8001142
                    else
                        Location."To-Production Bin Code" := Location."Open Shop Floor Bin Code";
                    if WhseEntry.Find('-') then
                        repeat
                            if (WhseEntry."Bin Code" <> Location."To-Production Bin Code") then // P8000494A
                                WhseAct.RegisterMove(WhseEntry."Location Code", WhseEntry."Bin Code", Location."To-Production Bin Code",
                                  WhseEntry."Item No.", WhseEntry."Variant Code", WhseEntry."Unit of Measure Code",
                                  WhseEntry."Lot No.", WhseEntry."Serial No.", WhseEntry."Remaining Quantity");
                        until WhseEntry.Next = 0;
                end;
            // P8000494A, P8000631A

            // P8000494A
            /*
            // Mark consumption journal lines for intermediates to bypass picking
            ProdOrder.FIND('-');
            ProdOrderComp.SETRANGE(Status,ProdOrderComp.Status::Released);
            ProdOrderComp.SETRANGE("Item No.",ProdOrderLine."Item No.");
            REPEAT
              ProdOrderComp.SETRANGE("Prod. Order No.",ProdOrder."No.");
              IF ProdOrderComp.FIND('-') THEN
                REPEAT
                  ConsumptionJnl.SETRANGE("Prod. Order No.",ProdOrderComp."Prod. Order No.");
                  ConsumptionJnl.SETRANGE("Prod. Order Line No.",ProdOrderComp."Prod. Order Line No.");
                  ConsumptionJnl.SETRANGE("Prod. Order Comp. Line No.",ProdOrderComp."Line No.");
                  IF ConsumptionJnl.FIND('-') THEN
                    REPEAT
                      ConsumptionJnl."Bypass Pick" := TRUE;
                      ConsumptionJnl.MODIFY;
                    UNTIL ConsumptionJnl.NEXT = 0;
                UNTIL ProdOrderComp.NEXT = 0;
            UNTIL ProdOrder.NEXT = 0;
            */
            // P8000494A
            until ProdOrderLine.Next = 0;

    end;

    procedure InitVersionUOM(var ProdBOMVersion: Record "Production BOM Version")
    var
        ProdBOMVersion2: Record "Production BOM Version";
        ProdBOMHeader: Record "Production BOM Header";
    begin
        // InitVersionUOM
        with ProdBOMVersion do begin
            ProdBOMHeader.Get("Production BOM No.");
            if (ProdBOMHeader."Output Type" = ProdBOMHeader."Output Type"::Family) then begin
                ProdBOMVersion2.SetRange("Production BOM No.", "Production BOM No.");
                ProdBOMVersion2.SetFilter("Version Code", '<>%1', "Version Code");
                if ProdBOMVersion2.Find('-') then begin
                    "Primary UOM" := ProdBOMVersion2."Primary UOM";
                    "Weight UOM" := ProdBOMVersion2."Weight UOM";
                    "Volume UOM" := ProdBOMVersion2."Volume UOM";
                    Modify;
                end;
            end;
        end;
    end;

    procedure AssignConsumptionSource(var ItemJnlLine: Record "Item Journal Line")
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        // AssignConsumptionSource
        with ItemJnlLine do
            if ("Entry Type" = "Entry Type"::Consumption) and
               ("Order Type" = "Order Type"::Production) and   // P8001132
               ("Order No." <> '') and ("Order Line No." <> 0) // P8001132
            then
                if ProdOrderLine.Get(ProdOrderLine.Status::Released,
                                     "Order No.", "Order Line No.") // P8001132
                then begin
                    "Source Type" := "Source Type"::Item;
                    "Source No." := ProdOrderLine."Item No.";
                end;
    end;

    procedure DeleteSharedComponents(var ProdOrder2: Record "Production Order")
    var
        ProdOrderComp2: Record "Prod. Order Component";
    begin
        // DeleteSharedComponents
        with ProdOrder2 do begin
            ProdOrderComp2.SetRange(Status, Status);
            ProdOrderComp2.SetRange("Prod. Order No.", "No.");
            ProdOrderComp2.SetRange("Prod. Order Line No.", 0);
            ProdOrderComp2.DeleteAll(true);
        end;
    end;

    procedure SetProdBOMQuantity(var ProdBOMLine: Record "Production BOM Line"; FldNo: Integer)
    var
        AltQtyPerUOM: Decimal;
        ProdBOMHeader: Record "Production BOM Header";
    begin
        // SetProdBOMQuantity
        with ProdBOMLine do begin
            if (Type <> Type::Item) then
                AltQtyPerUOM := 0
            else
                AltQtyPerUOM := GetAlternateQtyPerUOM("No.", "Unit of Measure Code", 0);
            if not ProdBOMHeader.Get("Production BOM No.") then
                ProdBOMHeader.Init;
            case FldNo of
                FieldNo("Unit of Measure Code"):
                    if (ProdBOMHeader."Mfg. BOM Type" = ProdBOMHeader."Mfg. BOM Type"::BOM) then
                        "Quantity (Alt.)" := "Quantity per" * AltQtyPerUOM
                    else
                        "Quantity (Alt.)" := "Batch Quantity" * AltQtyPerUOM;
                FieldNo("Quantity per"):
                    "Quantity (Alt.)" := "Quantity per" * AltQtyPerUOM;
                FieldNo("Batch Quantity"):
                    "Quantity (Alt.)" := "Batch Quantity" * AltQtyPerUOM;
                FieldNo("Quantity (Alt.)"):
                    begin
                        TestField(Type, Type::Item);
                        TestField("No.");
                        GetItem("No."); // PR3.60.02
                        Item.TestField("Alternate Unit of Measure");
                        if (ProdBOMHeader."Mfg. BOM Type" = ProdBOMHeader."Mfg. BOM Type"::BOM) then
                            Validate("Quantity per", "Quantity (Alt.)" / AltQtyPerUOM)
                        else
                            Validate("Batch Quantity", "Quantity (Alt.)" / AltQtyPerUOM);
                    end;
            end;
        end;
    end;

    procedure SetProdBOMUnitCost(var ProdBOMLine: Record "Production BOM Line"; FldNo: Integer)
    var
        CostingQtyPerUOM: Decimal;
    begin
        // SetProdBOMUnitCost
        with ProdBOMLine do begin
            if (Type <> Type::Item) then
                CostingQtyPerUOM := 1
            else
                CostingQtyPerUOM := GetCostingQtyPerUOM("No.", "Unit of Measure Code", 1); // PR3.70.03
            case FldNo of
                FieldNo("Unit Cost"):
                    "Unit Cost (Costing Units)" := Round("Unit Cost" / CostingQtyPerUOM, 0.00001); // P8000551A
                FieldNo("Unit Cost (Costing Units)"):
                    Validate("Unit Cost", Round("Unit Cost (Costing Units)" * CostingQtyPerUOM, 0.00001)); // P8000551A
            end;
        end;
    end;

    procedure SetProdOrderQuantity(var ProdOrderLine: Record "Prod. Order Line"; FldNo: Integer)
    var
        AltQtyPerUOM: Decimal;
    begin
        // SetProdOrderQuantity
        with ProdOrderLine do begin
            AltQtyPerUOM := GetAlternateQtyPerUOM("Item No.", "Unit of Measure Code", 0);
            case FldNo of
                FieldNo(Quantity),
              FieldNo("Quantity (Base)"):
                    "Quantity (Alt.)" := Quantity * AltQtyPerUOM;
                FieldNo("Quantity (Alt.)"):
                    begin
                        TestField("Item No.");
                        GetItem("Item No."); // PR3.60.02
                        Item.TestField("Alternate Unit of Measure");
                        Validate(Quantity, "Quantity (Alt.)" / AltQtyPerUOM);
                    end;
            end;
        end;
        UpdateProdLineCost(ProdOrderLine);
    end;

    procedure SetProdOrderUnitCost(var ProdOrderLine: Record "Prod. Order Line"; FldNo: Integer)
    var
        CostingQtyPerUOM: Decimal;
    begin
        // SetProdOrderUnitCost
        with ProdOrderLine do begin
            CostingQtyPerUOM := GetCostingQtyPerUOM("Item No.", "Unit of Measure Code", 1); // PR3.70.03
            case FldNo of
                FieldNo("Unit Cost"),
              FieldNo("Unit of Measure Code"):
                    "Unit Cost (Costing Units)" := "Unit Cost" / CostingQtyPerUOM;
                FieldNo("Unit Cost (Costing Units)"):
                    Validate("Unit Cost", "Unit Cost (Costing Units)" * CostingQtyPerUOM);
            end;
            if "By-Product" then
                "Unit Cost (By-Product)" := "Unit Cost (Costing Units)"
            else
                "Unit Cost (By-Product)" := 0;
        end;
        UpdateProdLineCost(ProdOrderLine);
    end;

    local procedure UpdateProdLineCost(var ProdOrderLine: Record "Prod. Order Line")
    var
        InvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)";
    begin
        // UpdateProdLineCost
        with ProdOrderLine do begin
            if InvtAdjmtEntryOrder.Get(InvtAdjmtEntryOrder."Order Type"::Production, "Prod. Order No.", "Line No.") then;           // P8001132
            "Cost Amount" :=
              Round(CalcProdLineCostQty(ProdOrderLine, InvtAdjmtEntryOrder."Completely Invoiced") * "Unit Cost (Costing Units)"); // P8001132
        end;                                                                                                                    // P8001132
    end;

    procedure CalcProdLineCostQty(var ProdOrderLine: Record "Prod. Order Line"; CalcActCost: Boolean): Decimal
    begin
        // CalcProdLineCostQty
        with ProdOrderLine do begin
            GetItem("Item No.");
            if Item.CostInAlternateUnits() then begin
                if CalcActCost then
                    exit("Finished Qty. (Alt.)");
                exit("Quantity (Alt.)");
            end else begin
                if CalcActCost then
                    exit("Finished Quantity");
                exit(Quantity);
            end;
        end;
    end;

    procedure DeleteProdLine(ProdOrderLine: Record "Prod. Order Line")
    begin
        // DeleteProdLine
        with ProdOrderLine do
            if IsProdFamilyProcess(ProdOrderLine) then
                if not "By-Product" then begin
                    SetRange(Status, Status);
                    SetRange("Prod. Order No.", "Prod. Order No.");
                    SetFilter("Line No.", '<>%1', "Line No.");
                    SetRange("By-Product", false);
                    if not Find('-') then
                        Error(Text004, FieldCaption("By-Product"));
                end;
    end;

    procedure SetProdOrderCompQuantity(var ProdOrderComp: Record "Prod. Order Component"; FldNo: Integer)
    var
        AltQtyPerUOM: Decimal;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        // SetProdOrderCompQuantity
        with ProdOrderComp do begin
            AltQtyPerUOM := GetAlternateQtyPerUOM("Item No.", "Unit of Measure Code", 0);
            "Quantity (Alt.)" := Quantity * AltQtyPerUOM;
            case FldNo of
                FieldNo("Expected Quantity"):
                    "Expected Qty. (Alt.)" := "Expected Quantity" * AltQtyPerUOM;
                FieldNo("Expected Qty. (Alt.)"):
                    begin
                        TestField("Item No.");
                        GetItem("Item No."); // PR3.60.02
                        Item.TestField("Alternate Unit of Measure");
                        Validate("Expected Quantity", "Expected Qty. (Alt.)" / AltQtyPerUOM);
                    end;
            end;
        end;
    end;

    procedure SetProdOrderCompUnitCost(var ProdOrderComp: Record "Prod. Order Component"; FldNo: Integer)
    var
        CostingQtyPerUOM: Decimal;
    begin
        // SetProdOrderCompUnitCost
        with ProdOrderComp do begin
            CostingQtyPerUOM := GetCostingQtyPerUOM("Item No.", "Unit of Measure Code", 1); // PR3.70.03
            case FldNo of
                FieldNo("Unit Cost"),
              FieldNo("Unit of Measure Code"):
                    "Unit Cost (Costing Units)" := "Unit Cost" / CostingQtyPerUOM;
                FieldNo("Unit Cost (Costing Units)"):
                    Validate("Unit Cost", "Unit Cost (Costing Units)" * CostingQtyPerUOM);
            end;
        end;
    end;

    procedure InsertComponentLine(var ProdOrderComp: Record "Prod. Order Component")
    var
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        SKU: Record "Stockkeeping Unit";
        GetPlanningParameters: Codeunit "Planning-Get Parameters";
    begin
        // InsertComponentLine
        with ProdOrderComp do begin
            TestField("Prod. Order No.");
            ProdOrder.Get(Status, "Prod. Order No.");
            if ProdOrder."Family Process Order" then begin
                if ("Prod. Order Line No." <> 0) then
                    Error(Text002, "Prod. Order No.");
            end else begin
                if ("Prod. Order Line No." = 0) then
                    Error(Text003, "Prod. Order No.");
            end;
            // P8001054
            if ("Location Code" = '') or ("Replenishment Area Code" = '') then begin
                if "Prod. Order Line No." <> 0 then
                    ProdOrderLine.Get(Status, "Prod. Order No.", "Prod. Order Line No.")
                else begin
                    ProdOrderLine.SetRange(Status, Status);
                    ProdOrderLine.SetRange("Prod. Order No.", "Prod. Order No.");
                    ProdOrderLine.FindFirst;
                end;
                if "Location Code" = '' then begin
                    GetPlanningParameters.AtSKU(SKU, ProdOrderLine."Item No.", ProdOrderLine."Variant Code", ProdOrderLine."Location Code");
                    Validate("Location Code", SKU."Components at Location");
                end;
                if "Replenishment Area Code" = '' then
                    Validate("Replenishment Area Code", ProdOrderLine."Replenishment Area Code");
            end;
            // P8001054
        end;
    end;

    procedure ValidateFamilyLine(var FamilyLine: Record "Family Line"; FldNo: Integer)
    var
        AltQtyPerUOM: Decimal;
    begin
        // ValidateFamilyLine
        with FamilyLine do begin
            if (FldNo = FieldNo("Item No.")) then
                if ("Item No." = '') then
                    Validate("Unit Cost", 0)
                else begin
                    GetItem("Item No.");
                    if Item.CostInAlternateUnits() then
                        Validate("Unit Cost", Item."Unit Cost")
                    else
                        Validate("Unit Cost",
                          Item."Unit Cost" * UOMMgmt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code"));
                end
            else begin
                TestField("Item No.");
                GetItem("Item No.");
                case FldNo of
                    FieldNo("Unit of Measure Code"):
                        begin
                            "Quantity (Alt.)" := Quantity * GetAlternateQtyPerUOM("Item No.", "Unit of Measure Code", 0);
                            if not Item.CostInAlternateUnits() then
                                Validate("Unit Cost",
                                  Item."Unit Cost" * UOMMgmt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code"));
                        end;
                    FieldNo(Quantity):
                        "Quantity (Alt.)" := Quantity * GetAlternateQtyPerUOM("Item No.", "Unit of Measure Code", 0);
                    FieldNo("Quantity (Alt.)"):
                        begin
                            Item.TestField("Alternate Unit of Measure");
                            Quantity := "Quantity (Alt.)" / GetAlternateQtyPerUOM("Item No.", "Unit of Measure Code", 1);
                        end;
                    FieldNo("Unit Cost"):
                        TestField("Item No.");
                    // P8001092
                    FieldNo("By-Product"):
                        if not "By-Product" then
                            "Co-Product Cost Share" := 1
                        else begin
                            Item.TestField("Costing Method", Item."Costing Method"::Standard);
                            "Primary Co-Product" := false;
                            "Co-Product Cost Share" := 0;
                        end;
                    FieldNo("Primary Co-Product"):
                        if "Primary Co-Product" then begin
                            TestField("By-Product", false);
                            TestField("Co-Product Cost Share");
                            ChangePrimaryCoProduct(FamilyLine);
                        end;
                    FieldNo("Co-Product Cost Share"):
                        if ("Co-Product Cost Share" = 0) then
                            TestField("Primary Co-Product", false)
                        else
                            TestField("By-Product", false);
                // P8001092
                end;
                "Cost Amount" :=
                  "Unit Cost" * Quantity * GetCostingQtyPerUOM("Item No.", "Unit of Measure Code", 1); // PR3.70.03
            end;
        end;
    end;

    local procedure ChangePrimaryCoProduct(var FamilyLine: Record "Family Line")
    var
        FamilyLine2: Record "Family Line";
    begin
        // P8001092
        FamilyLine2 := FamilyLine;
        with FamilyLine2 do begin
            SetRange("Family No.", "Family No.");
            SetFilter("Line No.", '<>%1', "Line No.");
            SetRange("Primary Co-Product", true);
            if FindFirst then begin
                Validate("Primary Co-Product", false);
                Modify(true);
            end;
        end;
    end;

    procedure ValidateItemCostingMethod(xItem2: Record Item; var Item2: Record Item)
    var
        FamilyLine: Record "Family Line";
    begin
        // P8001092
        if (xItem2."Costing Method" <> Item2."Costing Method") and
           (xItem2."Costing Method" = xItem2."Costing Method"::Standard)
        then
            with FamilyLine do begin
                SetCurrentKey("Item No.", "By-Product", "Variant Code");
                SetRange("Item No.", Item2."No.");
                SetRange("By-Product", true);
                if FindFirst then
                    Error(Text006, Item2.TableCaption, Item2."No.", FieldCaption("By-Product"), "Family No.");
            end;
    end;

    procedure GetAlternateQtyPerUOM(ItemNo: Code[20]; UnitOfMeasureCode: Code[10]; DefQtyPerUOM: Decimal): Decimal
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        // GetAlternateQtyPerUOM
        if (ItemNo <> '') then begin
            GetItem(ItemNo);
            if Item.TrackAlternateUnits then begin // PR3.70.03
                if (UnitOfMeasureCode <> '') then
                    ItemUnitOfMeasure.Get(ItemNo, UnitOfMeasureCode)
                else
                    ItemUnitOfMeasure."Qty. per Unit of Measure" := 1;
                exit(Item.AlternateQtyPerBase() * ItemUnitOfMeasure."Qty. per Unit of Measure"); // PR3.70.03
            end;
        end;
        exit(DefQtyPerUOM);
    end;

    procedure GetCostingQtyPerUOM(ItemNo: Code[20]; UnitOfMeasureCode: Code[10]; DefQtyPerUOM: Decimal): Decimal
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        // PR3.70.03
        if (ItemNo <> '') then begin
            GetItem(ItemNo);
            if Item.CostInAlternateUnits() then begin
                if (UnitOfMeasureCode <> '') then
                    ItemUnitOfMeasure.Get(ItemNo, UnitOfMeasureCode)
                else
                    ItemUnitOfMeasure."Qty. per Unit of Measure" := 1;
                exit(Item.CostingQtyPerBase() * ItemUnitOfMeasure."Qty. per Unit of Measure");
            end;
        end;
        exit(DefQtyPerUOM);
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        // GetItem
        if (Item."No." <> ItemNo) then
            Item.Get(ItemNo);
    end;

    procedure IsProdFamilyProcess(var ProdOrderLine: Record "Prod. Order Line"): Boolean
    var
        ProdOrder: Record "Production Order";
    begin
        // IsProdFamilyProcess
        with ProdOrderLine do begin
            if ("Prod. Order No." = '') then
                exit(false);
            ProdOrder.Get(Status, "Prod. Order No.");
            exit(ProdOrder."Family Process Order");
        end;
    end;

    procedure InitStatisticsTotals()
    begin
        // InitStatisticsTotals
        Clear(TempStdCost);
        Clear(TempExpCost);
        Clear(TempActCost);
    end;

    procedure AddToStatisticsTotals(var ProdOrderLine: Record "Prod. Order Line"; var StdCost: array[6] of Decimal; var ExpCost: array[6] of Decimal; var ActCost: array[6] of Decimal)
    begin
        // AddToStatisticsTotals
        if ProdOrderLine."By-Product" then
            AddToTotals(TempStdCost, StdCost, true)
        else begin
            AddToTotals(TempStdCost, StdCost, false);
            AddToTotals(TempExpCost, ExpCost, false);
            AddToTotals(TempActCost, ActCost, false);
        end;
    end;

    procedure GetStatisticsTotals(var StdCost: array[6] of Decimal; var ExpCost: array[6] of Decimal; var ActCost: array[6] of Decimal)
    begin
        // GetStatisticsTotals
        CopyTotals(StdCost, TempStdCost);
        CopyTotals(ExpCost, TempExpCost);
        CopyTotals(ActCost, TempActCost);
    end;

    local procedure AddToTotals(var TotalCost: array[6] of Decimal; var CurrCost: array[6] of Decimal; Subtract: Boolean)
    var
        i: Integer;
    begin
        // AddToTotals
        for i := 1 to ArrayLen(TotalCost) - 1 do
            if Subtract then
                TotalCost[i] := TotalCost[i] - CurrCost[i]
            else
                TotalCost[i] := TotalCost[i] + CurrCost[i];
    end;

    local procedure CopyTotals(var ToData: array[6] of Decimal; var FromData: array[6] of Decimal)
    var
        i: Integer;
    begin
        // CopyTotals
        for i := 1 to ArrayLen(ToData) - 1 do
            ToData[i] := FromData[i];
    end;

    procedure ShowProdOrderFinishedEntries(var ProdOrderLine: Record "Prod. Order Line")
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        // ShowProdOrderFinishedEntries
        with ItemLedgEntry do begin
            SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type"); // P8000267B, P8001132
            SetRange("Order Type", "Order Type"::Production);        // P8001132
            SetRange("Order No.", ProdOrderLine."Prod. Order No."); // P8001132
            SetRange("Order Line No.", ProdOrderLine."Line No.");   // P8001132
            SetRange("Entry Type", "Entry Type"::Output);
            PAGE.RunModal(0, ItemLedgEntry, ItemLedgEntry."Quantity (Alt.)");
        end;
    end;

    procedure CalcProdLineCostQtyBase(var ProdOrderLine: Record "Prod. Order Line"; CalcActCost: Boolean): Decimal
    begin
        // CalcProdLineCostQtyBase
        with ProdOrderLine do begin
            GetItem("Item No.");
            if Item.CostInAlternateUnits() then begin
                if CalcActCost then
                    exit("Finished Qty. (Alt.)");
                exit("Quantity (Alt.)");
            end else begin
                if CalcActCost then
                    exit("Finished Qty. (Base)");
                exit("Quantity (Base)");
            end;
        end;
    end;

    procedure AddProdLineExpCost(var ProdOrderLine: Record "Prod. Order Line"; var ExpMatCost: Decimal)
    var
        CoProdMgmt: Codeunit "Co-Product Cost Management";
        SharedCost: Decimal;
        TotalQty: Decimal;
        ByProductCost: Decimal;
    begin
        // AddProdLineExpCost
        with ProdOrderLine do
            if IsProdFamilyProcess(ProdOrderLine) then
              // P8000870
              /*
              IF "By-Product" THEN
                ExpMatCost := CoProdMgmt.CalcProdLineByProductExpCost(ProdOrderLine)
              ELSE BEGIN
                SharedCost :=
                  CoProdMgmt.CalcProdSharedExpCost(ProdOrderLine) - CoProdMgmt.CalcProdByProductExpCost(ProdOrderLine);

                CoProdMgmt.BuildProdCommonUOMQtys(ProdOrderLine, TotalQty, FALSE);

                ExpMatCost := ExpMatCost +
                  CoProdMgmt.CalcProdCostShare(ProdOrderLine, TotalQty, SharedCost, '');
              END;
              */
              begin
                SharedCost := CoProdMgmt.CalcProdSharedExpCost(ProdOrderLine);
                ByProductCost := CoProdMgmt.CalcProdByProductExpCost(ProdOrderLine);
                if "By-Product" then
                    if (SharedCost >= ByProductCost) then
                        ExpMatCost := ExpMatCost + CoProdMgmt.CalcProdLineByProductExpCost(ProdOrderLine)
                    else
                        ExpMatCost := ExpMatCost + CalcProdByProductCostShare(ProdOrderLine, ByProductCost, SharedCost, false, '')
                else
                    if (SharedCost >= ByProductCost) then begin
                        CoProdMgmt.BuildProdCommonUOMQtys(ProdOrderLine, TotalQty, false);
                        ExpMatCost := ExpMatCost +
                          CoProdMgmt.CalcProdCostShare(ProdOrderLine, TotalQty, SharedCost - ByProductCost, '');
                    end;
            end;
        // P8000870

    end;

    procedure AddProdLineActCost(var ProdOrderLine: Record "Prod. Order Line"; var ActMatCost: Decimal; var ActMatCostACY: Decimal)
    var
        CoProdMgmt: Codeunit "Co-Product Cost Management";
        SharedCost: Decimal;
        SharedCostACY: Decimal;
        ByProductCost: Decimal;
        ByProductCostACY: Decimal;
        TotalQty: Decimal;
        GLSetup: Record "General Ledger Setup";
        LineCost: Decimal;
        LineCostACY: Decimal;
    begin
        // AddProdLineActCost
        with ProdOrderLine do
            if IsProdFamilyProcess(ProdOrderLine) then
              // P8000870
              /*
              IF "By-Product" THEN
                CoProdMgmt.AddProdLineByProductTargetCost(ProdOrderLine, ActMatCost, ActMatCostACY)
              ELSE BEGIN
                CoProdMgmt.CalcProdSharedActCost(ProdOrderLine, SharedCost, SharedCostACY);
                CoProdMgmt.CalcProdByProductActCost(ProdOrderLine, ByProductCost, ByProductCostACY);
                SharedCost := SharedCost - ByProductCost;
                SharedCostACY := SharedCostACY - ByProductCostACY;

                CoProdMgmt.BuildProdCommonUOMQtys(ProdOrderLine, TotalQty, TRUE);

                ActMatCost := ActMatCost +
                  CoProdMgmt.CalcProdCostShare(ProdOrderLine, TotalQty, SharedCost, '');
                GLSetup.GET;
                ActMatCostACY := ActMatCostACY +
                  CoProdMgmt.CalcProdCostShare(ProdOrderLine, TotalQty, SharedCostACY, GLSetup."Additional Reporting Currency");
              END;
              */
              begin
                CoProdMgmt.CalcProdSharedActCost(ProdOrderLine, SharedCost, SharedCostACY);
                CalcByProductTargetCost(ProdOrderLine, ByProductCost, ByProductCostACY);
                if "By-Product" then
                    if (SharedCost >= ByProductCost) then begin
                        CalcByProductLineTargetCost(ProdOrderLine, LineCost, LineCostACY);
                        ActMatCost := ActMatCost + LineCost;
                        ActMatCostACY := ActMatCostACY + LineCostACY;
                    end else begin
                        ActMatCost := ActMatCost + CalcProdByProductCostShare(ProdOrderLine, ByProductCost, SharedCost, true, '');
                        GLSetup.Get;
                        ActMatCostACY := ActMatCostACY +
                          CalcProdByProductCostShare(
                            ProdOrderLine, ByProductCost, SharedCostACY, true, GLSetup."Additional Reporting Currency");
                    end
                else
                    if (SharedCost >= ByProductCost) then begin
                        CoProdMgmt.BuildProdCommonUOMQtys(ProdOrderLine, TotalQty, true);
                        ActMatCost := ActMatCost +
                          CoProdMgmt.CalcProdCostShare(ProdOrderLine, TotalQty, SharedCost - ByProductCost, '');
                        GLSetup.Get;
                        ActMatCostACY := ActMatCostACY +
                          CoProdMgmt.CalcProdCostShare(
                            ProdOrderLine, TotalQty, SharedCostACY - ByProductCostACY, GLSetup."Additional Reporting Currency");
                    end;
            end;
        // P8000870

    end;

    procedure RemovePlanningOrder(stat: Integer; no: Code[20]; line: Integer)
    var
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProdXref: Record "Production Order XRef";
    begin
        // RemovePlanningOrder
        // Remove planning order if quantity is zero and there are no more cross reference
        // entries to batch orders
        if ProdOrderLine.Get(stat, no, line) and (ProdOrderLine."Quantity (Base)" <= 0) then begin
            ProdXref.SetRange("Source Table ID", DATABASE::"Prod. Order Line");
            ProdXref.SetRange("Source Type", stat);
            ProdXref.SetRange("Source No.", no);
            ProdXref.SetRange("Source Line No.", line);
            if not ProdXref.Find('-') then begin
                ProdOrderLine.Delete(true);
                ProdOrderLine.SetRange(Status, stat);
                ProdOrderLine.SetRange("Prod. Order No.", no);
                if not ProdOrderLine.Find('-') then begin
                    ProdOrder.Get(stat, no);
                    ProdOrder.Delete(true);
                end;
            end;
        end;
    end;

    procedure CalculateProdOrderLineDates(var ProdOrderLine: Record "Prod. Order Line"; Direction: Option Forward,Backward): Boolean
    var
        ProdOrder: Record "Production Order";
        ProdBOMEquip: Record "Prod. BOM Equipment";
        ProdDateTime: Record "Production Time by Date" temporary;
        P800CalMgt: Codeunit "Process 800 Calendar Mngt.";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        VersionMgt: Codeunit VersionManagement;
        ProductionTime: Decimal;
    begin
        // P8000197A
        ProdOrderLine.GetEquipmentCode; // P8000877
        if ProdBOMEquip.Get(ProdOrderLine."Production BOM No.", ProdOrderLine."Production BOM Version Code",
          ProdOrderLine."Equipment Code") // P8000877
        then begin
            ProductionTime := ProdOrderLine.Quantity * ProdBOMEquip."Variable Prod. Time (Hours)";
            ProductionTime := ProductionTime * P800UOMFns.GetConversionFromTo(
              ProdOrderLine."Item No.", ProdOrderLine."Unit of Measure Code",
              VersionMgt.GetBOMUnitOfMeasure(
                ProdOrderLine."Production BOM No.", ProdOrderLine."Production BOM Version Code"));
            ProductionTime := ProductionTime + ProdBOMEquip."Fixed Prod. Time (Hours)";
        end else
            ProductionTime := 0;

        case Direction of
            Direction::Forward:
                P800CalMgt.CalculateProductionDateTime(ProdOrderLine."Location Code",
                  ProdOrderLine."Starting Date", ProdOrderLine."Starting Time", Direction, ProductionTime,
                  ProdOrderLine."Ending Date", ProdOrderLine."Ending Time", ProdDateTime);
            Direction::Backward:
                P800CalMgt.CalculateProductionDateTime(ProdOrderLine."Location Code",
                  ProdOrderLine."Ending Date", ProdOrderLine."Ending Time", Direction, ProductionTime,
                  ProdOrderLine."Starting Date", ProdOrderLine."Starting Time", ProdDateTime);
        end;

        exit(true);
    end;

    procedure AdjustProdOrderLineDates(var ProdOrder: Record "Production Order"; EqCode: Code[20]; StartDateTime: DateTime; EndDateTime: DateTime; Direction: Option Forward,Backward)
    var
        ProdOrderLine: Record "Prod. Order Line";
        LeadTimeMgt: Codeunit "Lead-Time Management";
        CalculateProdOrder: Codeunit "Calculate Prod. Order";
        ReferenceDateTime: DateTime;
        Duration: Duration;
    begin
        // P8000877
        case Direction of
            Direction::Forward:
                begin
                    ReferenceDateTime := StartDateTime;
                    ProdOrderLine.Ascending(true);
                end;
            Direction::Backward:
                begin
                    ReferenceDateTime := EndDateTime;
                    ProdOrderLine.Ascending(false);
                end;
        end;

        ProdOrderLine.SetRange(Status, ProdOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProdOrder."No.");
        ProdOrderLine.SetRange("Equipment Code", EqCode);
        if ProdOrderLine.Find('-') then
            repeat
                Duration := CreateDateTime(ProdOrderLine."Ending Date", ProdOrderLine."Ending Time") -
                  CreateDateTime(ProdOrderLine."Starting Date", ProdOrderLine."Starting Time");
                case Direction of
                    Direction::Forward:
                        begin
                            ProdOrderLine."Starting Date" := DT2Date(ReferenceDateTime);
                            ProdOrderLine."Starting Time" := DT2Time(ReferenceDateTime);
                            ReferenceDateTime := ReferenceDateTime + Duration;
                            ProdOrderLine."Ending Date" := DT2Date(ReferenceDateTime);
                            ProdOrderLine."Ending Time" := DT2Time(ReferenceDateTime);
                        end;
                    Direction::Backward:
                        begin
                            ProdOrderLine."Ending Date" := DT2Date(ReferenceDateTime);
                            ProdOrderLine."Ending Time" := DT2Time(ReferenceDateTime);
                            ReferenceDateTime := ReferenceDateTime - Duration;
                            ProdOrderLine."Starting Date" := DT2Date(ReferenceDateTime);
                            ProdOrderLine."Starting Time" := DT2Time(ReferenceDateTime);
                        end;
                end;

                if ProdOrderLine."Planning Level Code" = 0 then
                    ProdOrderLine."Due Date" :=
                      LeadTimeMgt.PlannedDueDate(
                        ProdOrderLine."Item No.",
                        ProdOrderLine."Location Code",
                        ProdOrderLine."Variant Code",
                        ProdOrderLine."Ending Date",
                        '',
                        2)
                else
                    ProdOrderLine."Due Date" := ProdOrderLine."Ending Date";
                ProdOrderLine.UpdateDatetime;
                CalculateProdOrder.Recalculate(ProdOrderLine, Direction, true); // P8001243, P8001301
                ProdOrderLine.Modify;

            until ProdOrderLine.Next = 0;

        ProdOrder.AdjustStartEndingDate; // P80073095
    end;

    local procedure CalcByProductLineTargetCost(var ByProductLine: Record "Prod. Order Line"; var ByProductTargetCost: Decimal; var ByProductTargetCostACY: Decimal)
    var
        InvtAdjmtEntryOrder: Record "Inventory Adjmt. Entry (Order)";
    begin
        // P8000870
        with ByProductLine do begin
            InvtAdjmtEntryOrder.Get(InvtAdjmtEntryOrder."Order Type"::Production, "Prod. Order No.", "Line No."); // P8001132
            ByProductTargetCost := "Unit Cost (By-Product)" * CalcProdLineCostQty(ByProductLine, true);
            ByProductTargetCostACY := InvtAdjmtEntryOrder.CalcAmtACY(ByProductTargetCost); // P8001132
        end;
    end;

    local procedure CalcByProductTargetCost(ByProductLine: Record "Prod. Order Line"; var ByProductTargetCost: Decimal; var ByProductTargetCostACY: Decimal)
    var
        LineTargetCost: Decimal;
        LineTargetCostACY: Decimal;
    begin
        // P8000870
        with ByProductLine do begin
            ByProductTargetCost := 0;
            ByProductTargetCostACY := 0;

            SetRange(Status, Status);
            SetRange("Prod. Order No.", "Prod. Order No.");
            SetRange("By-Product", true);
            if FindSet then
                repeat
                    CalcByProductLineTargetCost(ByProductLine, LineTargetCost, LineTargetCostACY);
                    ByProductTargetCost := ByProductTargetCost + LineTargetCost;
                    ByProductTargetCostACY := ByProductTargetCostACY + LineTargetCostACY;
                until (Next = 0);
        end;
    end;

    local procedure CalcProdByProductCostShare(var ProdOrderLine: Record "Prod. Order Line"; TotalCost: Decimal; SharedCost: Decimal; CalcActCost: Boolean; CurrencyCode: Code[10]): Decimal
    var
        ByProductLine: Record "Prod. Order Line";
        Currency: Record Currency;
        LineCost: Decimal;
        TargetLineCost: Decimal;
    begin
        // P8000870
        if (TotalCost = 0) then
            exit(0);

        if (CurrencyCode <> '') then
            Currency.Get(CurrencyCode);
        Currency.InitRoundingPrecision;

        with ByProductLine do begin
            SetRange(Status, ProdOrderLine.Status);
            SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
            SetRange("By-Product", true);
            if FindSet then
                repeat
                    TargetLineCost := "Unit Cost (By-Product)" * CalcProdLineCostQty(ByProductLine, CalcActCost);
                    if (TotalCost = 0) then
                        LineCost := 0
                    else
                        LineCost := Round(SharedCost * (TargetLineCost / TotalCost), Currency."Amount Rounding Precision");
                    if ("Line No." = ProdOrderLine."Line No.") then
                        exit(LineCost);
                    TotalCost := TotalCost - TargetLineCost;
                    SharedCost := SharedCost - LineCost;
                until (Next = 0);
        end;
        exit(0);
    end;

    procedure CalculatePlanningLineDates(var PlannningLine: Record "Requisition Line"; Direction: Option Forward,Backward): Boolean
    var
        ProdOrder: Record "Production Order";
        ProdBOMEquip: Record "Prod. BOM Equipment";
        ProdDateTime: Record "Production Time by Date" temporary;
        P800CalMgt: Codeunit "Process 800 Calendar Mngt.";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        VersionMgt: Codeunit VersionManagement;
        ProductionTime: Decimal;
    begin
        // P8008029
        if ProdBOMEquip.Get(PlannningLine."Production BOM No.", PlannningLine."Production BOM Version Code",
          PlannningLine."Equipment Code")
        then begin
            ProductionTime := PlannningLine.Quantity * ProdBOMEquip."Variable Prod. Time (Hours)";
            ProductionTime := ProductionTime * P800UOMFns.GetConversionFromTo(
              PlannningLine."No.", PlannningLine."Unit of Measure Code",
              VersionMgt.GetBOMUnitOfMeasure(
                PlannningLine."Production BOM No.", PlannningLine."Production BOM Version Code"));
            ProductionTime := ProductionTime + ProdBOMEquip."Fixed Prod. Time (Hours)";
        end else
            ProductionTime := 0;

        case Direction of
            Direction::Forward:
                P800CalMgt.CalculateProductionDateTime(PlannningLine."Location Code",
                  PlannningLine."Starting Date", PlannningLine."Starting Time", Direction, ProductionTime,
                  PlannningLine."Ending Date", PlannningLine."Ending Time", ProdDateTime);
            Direction::Backward:
                P800CalMgt.CalculateProductionDateTime(PlannningLine."Location Code",
                  PlannningLine."Ending Date", PlannningLine."Ending Time", Direction, ProductionTime,
                  PlannningLine."Starting Date", PlannningLine."Starting Time", ProdDateTime);
        end;

        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostOrderOnBeforeSelectStatus(OrderNo: Code[20]; ProdDate: Date; CalcOutput: Boolean; CalcConsumption: Boolean; OutputTemplate: Code[10]; OutputBatch: Code[10]; ConsumptionTemplate: Code[10]; ConsumptionBatch: Code[10]; DefaultSelection: Integer; var Selection: Integer)
    begin
        // P80082969
    end;
}

