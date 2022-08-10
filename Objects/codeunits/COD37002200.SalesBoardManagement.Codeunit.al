codeunit 37002200 "Sales Board Management"
{
    // PR3.70.08
    // P8000178A, Myers Nissi, Jack Reynolds, 08 FEB 05
    //   Sales Board functions
    // 
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 22 SEP 05
    //   Support for produciton changes
    //   Broaden production to include frim planned orders
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Changes to Item Ledger keys
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Key change on sales line table
    // 
    // PRW16.00.04
    // P8000887, VerticalSoft, Jack Reynolds, 08 DEC 10
    //   Fix to properly account for quantity in-transit
    // 
    // PRW16.00.05
    // P8000936, Columbus IT, Jack Reynolds, 25 APR 11
    //   Support for Repack Orders on Sales Board
    // 
    // PRW16.00.06
    // P8001018, Columbus IT, Jack Reynolds, 11 JAN 12
    //   Fix problem maintaining temporary table of sales board data
    // 
    // P8001020, Columbus IT, Jack Reynolds, 17 JAN 12
    //   Fix problem with missing key on Sales Line in NA database
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW17.00.01
    // P8001198, Columbus IT, Jack Reynolds, 23 AUG 13
    //   Fix problem filtering on location or variant


    trigger OnRun()
    begin
    end;

    var
        Item: Record Item;
        TempLocation: Record Location temporary;
        TempVariant: Record Variant temporary;
        SalesBoard: Record "Item Availability" temporary;
        ProdPlanChange: Record "Daily Prod. Planning-Change" temporary;
        ItemLedger: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        ProdOrderComp: Record "Prod. Order Component";
        ProdOrderLine: Record "Prod. Order Line";
        RepackOrder: Record "Repack Order";
        RepackLine: array[2] of Record "Repack Order Line";
        TransferLine: array[3] of Record "Transfer Line";
        Date: Record Date;
        DateFormat: Text[250];
        Text001: Label '(prior to %1)';
        Text002: Label '<Mon>/<Day>/<Year,2>';
        Text003: Label 'week of <Mon>/<Day>/<Year,2>';
        Text004: Label 'month of <Mon>/<Year,2>';
        xItemNo: Code[20];
        xVariantFilter: Text[250];
        xLocationFilter: Text[250];
        xShortage: Code[1];
        xZero: Code[1];
        BufferLimit: array[4] of BigInteger;
        LotStatusMgmt: Codeunit "Lot Status Management";
        AvailableFor: Integer;
        LotStatusExclusionFilter: Text[1024];
        ExcludePurch: Boolean;
        ExcludeSalesRet: Boolean;
        ExcludeOutput: Boolean;

    procedure Initialize(BaseDate: Date; PeriodType: Option Day,Week,Month; Periods: Integer; AvailFor: Integer)
    var
        Location: Record Location;
        Variant: Record Variant;
        Date1: Date;
    begin
        // P8001083 - add parameter for AvailFor
        // P8000197A
        Clear(BufferLimit);
        // Maximum number of records in temp sales board table
        BufferLimit[1] := 100000;
        // Number of records to delete when table is full - 20%, rounded to be entire sets of data
        // 16 = NumberOfDaataElements - 1
        BufferLimit[4] := Round(BufferLimit[1] * 0.2, 1 + (16 * (Periods + 1))); // P8000936, P8001018
        // P8000197A

        SalesBoard.Reset;
        SalesBoard.DeleteAll;
        TempVariant.Reset;
        TempVariant.DeleteAll;
        Clear(TempVariant);
        TempLocation.Reset;
        TempLocation.DeleteAll;
        Clear(TempLocation);

        TempVariant.Insert;
        TempVariant.Code := '----------'; // P8001198
        TempVariant.Insert;
        if Variant.Find('-') then
            repeat
                TempVariant := Variant;
                TempVariant.Insert;
            until Variant.Next = 0;

        TempLocation.Insert;
        TempLocation.Code := '----------'; // P8001198
        TempLocation.Insert;
        if Location.Find('-') then
            repeat
                TempLocation := Location;
                TempLocation.Insert;
            until Location.Next = 0;

        Date.Reset;
        Date.SetRange("Period Type", PeriodType);
        Date.SetFilter("Period Start", '<=%1', BaseDate);
        Date.Find('+');
        Date1 := Date."Period Start";
        Date.SetRange("Period Start");
        Date.Next(Periods - 1);
        Date.SetRange("Period Start", Date1, Date."Period Start");
        case PeriodType of
            PeriodType::Day:
                DateFormat := Text002;
            PeriodType::Week:
                DateFormat := Text003;
            PeriodType::Month:
                DateFormat := Text004;
        end;

        ItemLedger.Reset;
        ItemLedger.SetCurrentKey("Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code"); // P8000267B
        ItemLedger.SetRange("Drop Shipment", false);

        PurchaseLine.Reset;
        PurchaseLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Expected Receipt Date");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.SetRange("Drop Shipment", false);

        SalesLine.Reset;
        SalesLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment"); // P8001020
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("Drop Shipment", false);

        ProdOrderLine.Reset;
        ProdOrderLine.SetCurrentKey(Status, "Item No.", "Variant Code", "Location Code", "Due Date");
        ProdOrderLine.SetRange(Status, ProdOrderLine.Status::"Firm Planned", ProdOrderLine.Status::Released); // P8000197A

        ProdOrderComp.Reset;
        ProdOrderComp.SetCurrentKey(Status, "Item No.", "Variant Code", "Location Code", "Due Date");
        ProdOrderComp.SetRange(Status, ProdOrderComp.Status::"Firm Planned", ProdOrderComp.Status::Released); // P8000197A

        // P8000936
        RepackOrder.Reset;
        RepackOrder.SetCurrentKey(Status, "Item No.", "Variant Code", "Destination Location", "Due Date");
        RepackOrder.SetRange(Status, RepackOrder.Status::Open);

        RepackLine[1].Reset;
        RepackLine[1].SetCurrentKey(Status, Type, "No.", "Variant Code", "Source Location", "Due Date");
        RepackLine[1].SetRange(Status, RepackLine[1].Status::Open);
        RepackLine[1].SetRange(Type, RepackLine[1].Type::Item);

        RepackLine[2].Reset;
        RepackLine[2].SetCurrentKey(Status, Type, "No.", "Variant Code", "Repack Location", "Due Date");
        RepackLine[2].SetRange(Status, RepackLine[2].Status::Open);
        RepackLine[2].SetRange(Type, RepackLine[2].Type::Item);
        // P8000936

        TransferLine[1].Reset;
        TransferLine[1].SetCurrentKey("Transfer-to Code", Status, "Derived From Line No.", "Item No.", "Variant Code",
          "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Receipt Date");
        TransferLine[1].SetRange("Derived From Line No.", 0);

        TransferLine[2].Reset;
        TransferLine[2].SetCurrentKey("Transfer-from Code", Status, "Derived From Line No.", "Item No.", "Variant Code",
          "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Shipment Date");
        TransferLine[2].SetRange("Derived From Line No.", 0);

        // P8000887
        TransferLine[3].Reset;
        TransferLine[3].SetCurrentKey("Transfer-from Code", Status, "Derived From Line No.", "Item No.", "Variant Code",
          "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Shipment Date");
        TransferLine[3].SetFilter("Derived From Line No.", '>0');
        // P8000887

        // P8001083
        AvailableFor := AvailFor;
        LotStatusExclusionFilter := LotStatusMgmt.SetLotStatusExclusionFilter(AvailableFor);
        // P8001083
    end;

    local procedure SetTempFilters(VariantFilter: Text[250]; LocationFilter: Text[250])
    begin
        TempVariant.Reset;
        if VariantFilter = '' then
            TempVariant.SetRange(Code, '----------') // P8001198
        else begin
            TempVariant.FilterGroup(9);
            TempVariant.SetFilter(Code, '<>%1', '----------'); // P8001198
            TempVariant.FilterGroup(0);
            TempVariant.SetFilter(Code, VariantFilter);
        end;

        TempLocation.Reset;
        if LocationFilter = '' then
            TempLocation.SetRange(Code, '----------') // P8001198
        else begin
            TempLocation.FilterGroup(9);
            TempLocation.SetFilter(Code, '<>%1', '----------'); // P8001198
            TempLocation.FilterGroup(0);
            TempLocation.SetFilter(Code, LocationFilter);
        end;
    end;

    procedure GetQuantity(ItemNo: Code[20]; VariantFilter: Text[250]; LocationFilter: Text[250]; DateOffset: Integer; DataElement: Integer) Quantity: Decimal
    begin
        // P8000197A - Renamed from GetData
        SetTempFilters(VariantFilter, LocationFilter);
        if TempVariant.Find('-') then
            repeat
                if TempLocation.Find('-') then
                    repeat
                        if not SalesBoard.Get(ItemNo, TempVariant.Code, TempLocation.Code, DateOffset, DataElement) then begin
                            Calculate(ItemNo, TempVariant.Code, TempLocation.Code);
                            SalesBoard.Get(ItemNo, TempVariant.Code, TempLocation.Code, DateOffset, DataElement);
                        end;
                        Quantity += SalesBoard.Quantity;
                    until TempLocation.Next = 0;
            until TempVariant.Next = 0;
    end;

    procedure GetIncludesProdChanges(ItemNo: Code[20]; VariantFilter: Text[250]; LocationFilter: Text[250]; DateOffset: Integer; DataElement: Integer) IncludesProdChanges: Boolean
    begin
        // P8000197A
        SetTempFilters(VariantFilter, LocationFilter);
        if TempVariant.Find('-') then
            repeat
                if TempLocation.Find('-') then
                    repeat
                        if not SalesBoard.Get(ItemNo, TempVariant.Code, TempLocation.Code, DateOffset, DataElement) then begin
                            Calculate(ItemNo, TempVariant.Code, TempLocation.Code);
                            SalesBoard.Get(ItemNo, TempVariant.Code, TempLocation.Code, DateOffset, DataElement);
                        end;
                        IncludesProdChanges := IncludesProdChanges or SalesBoard."Includes Production Changes";
                    until TempLocation.Next = 0;
            until TempVariant.Next = 0;
    end;

    procedure GetData(ItemNo: Code[20]; VariantFilter: Text[250]; LocationFilter: Text[250]; DateOffset: Integer; DataElement: Integer; var Quantity: Decimal; var IncludesProdChanges: Boolean)
    begin
        // P8000197A
        IncludesProdChanges := false;
        SetTempFilters(VariantFilter, LocationFilter);
        if TempVariant.Find('-') then
            repeat
                if TempLocation.Find('-') then
                    repeat
                        if not SalesBoard.Get(ItemNo, TempVariant.Code, TempLocation.Code, DateOffset, DataElement) then begin
                            Calculate(ItemNo, TempVariant.Code, TempLocation.Code);
                            SalesBoard.Get(ItemNo, TempVariant.Code, TempLocation.Code, DateOffset, DataElement);
                        end;
                        Quantity += SalesBoard.Quantity;
                        IncludesProdChanges := IncludesProdChanges or SalesBoard."Includes Production Changes";
                    until TempLocation.Next = 0;
            until TempVariant.Next = 0;
    end;

    procedure GetHeading(DateOffset: Integer; DataElement: Integer): Text[30]
    var
        DateAvail: Date;
    begin
        SalesBoard."Data Element" := DataElement;
        if SalesBoard."Data Element" <> SalesBoard."Data Element"::Available then
            exit(Format(SalesBoard."Data Element"));

        Date.Find('-');
        if DateOffset = Date.Next(DateOffset) then
            DateAvail := Date."Period Start"
        else
            DateAvail := NormalDate(Date."Period End") + 1;
        exit(Format(DateAvail, 0, '<Month,2>/<Day,2>') + ' ' + Format(SalesBoard."Data Element"));
    end;

    procedure DrillDown(ItemNo: Code[20]; VariantFilter: Text[250]; LocationFilter: Text[250]; DateOffset: Integer; DataElement: Integer)
    var
        SalesBoardDrillDown: Record "Item Availability" temporary;
    begin
        SalesBoard.Reset;
        SalesBoard.SetRange("Item No.", ItemNo);
        if VariantFilter = '' then
            SalesBoard.SetRange("Variant Code", '----------') // P8001198
        else
            SalesBoard.SetFilter("Variant Code", VariantFilter);
        if LocationFilter = '' then
            SalesBoard.SetRange("Location Code", '----------') // P8001198
        else
            SalesBoard.SetFilter("Location Code", LocationFilter);
        SalesBoard.SetRange("Date Offset", DateOffset);
        SalesBoard.SetRange("Data Element", DataElement);
        SalesBoard.CalcSums(Quantity);
        SalesBoardDrillDown."Item No." := ItemNo;
        SalesBoardDrillDown."Date Offset" := DateOffset;
        SalesBoardDrillDown."Data Element" := DataElement;
        SalesBoardDrillDown.Quantity := SalesBoard.Quantity;
        // P8000197A
        SalesBoard.SetRange("Includes Production Changes", true);
        SalesBoardDrillDown."Includes Production Changes" := SalesBoard.Find('-');
        SalesBoard.SetRange("Includes Production Changes");
        // P8000197A
        SetSalesBoardDate(SalesBoardDrillDown);
        SalesBoardDrillDown.Insert;

        case DataElement of
            SalesBoard."Data Element"::Available:
                begin
                    SalesBoard.SetRange("Date Offset", -1, DateOffset - 1);
                    SalesBoard.SetFilter("Data Element", '<>%1&<>%2&<>%3&<>%4&<>%5', SalesBoard."Data Element"::Purchases, // P8000936
                      SalesBoard."Data Element"::Sales, SalesBoard."Data Element"::Output,                                // P8000936
                      SalesBoard."Data Element"::Consumption, SalesBoard."Data Element"::Transfers);                      // P8000936
                end;
            SalesBoard."Data Element"::Purchases:
                SalesBoard.SetRange("Data Element", SalesBoard."Data Element"::"Purchase Orders",
                  SalesBoard."Data Element"::"Purchase Returns");
            SalesBoard."Data Element"::Sales:
                SalesBoard.SetRange("Data Element", SalesBoard."Data Element"::"Sales Orders",
                  SalesBoard."Data Element"::"Sales Returns");
                // P8000936
            SalesBoard."Data Element"::Output:
                SalesBoard.SetRange("Data Element", SalesBoard."Data Element"::"Production Output",
                  SalesBoard."Data Element"::"Repack Output");
            SalesBoard."Data Element"::Consumption:
                SalesBoard.SetRange("Data Element", SalesBoard."Data Element"::"Production Components",
                  SalesBoard."Data Element"::"Repack Components");
                // P8000936
            SalesBoard."Data Element"::Transfers:
                SalesBoard.SetRange("Data Element", SalesBoard."Data Element"::"Transfers In",
                  SalesBoard."Data Element"::"Transfers Out");
            else
                SalesBoard.SetRange("Data Element", -1);
        end;

        if SalesBoard.Find('-') then
            repeat
                if not SalesBoardDrillDown.Get(ItemNo, '', '', SalesBoard."Date Offset", SalesBoard."Data Element") then begin
                    SalesBoardDrillDown.Init;
                    SalesBoardDrillDown."Item No." := ItemNo;
                    SalesBoardDrillDown."Date Offset" := SalesBoard."Date Offset";
                    SalesBoardDrillDown."Data Element" := SalesBoard."Data Element";
                    SetSalesBoardDate(SalesBoardDrillDown);
                    SalesBoardDrillDown.Insert;
                end;
                SalesBoardDrillDown.Quantity += SalesBoard.Quantity;
                SalesBoardDrillDown."Quantity Not Available" += SalesBoard."Quantity Not Available"; // P8001083
                SalesBoardDrillDown."Includes Production Changes" :=                                             // P8000197A
                  SalesBoardDrillDown."Includes Production Changes" or SalesBoard."Includes Production Changes"; // P8000197A
                SalesBoardDrillDown.Modify;
            until SalesBoard.Next = 0;

        SalesBoardDrillDown.Get(ItemNo, '', '', DateOffset, DataElement);

        // P8000197A
        ProdPlanChange.Reset;
        ProdPlanChange.SetCurrentKey("Item No.");
        ProdPlanChange.SetRange("Item No.", ItemNo);
        if ProdPlanChange.Find('-') then
            SalesBoardDrillDown.SetProdPlanChange(ProdPlanChange);
        // P8000197A

        SalesBoardDrillDown.DrillDown(VariantFilter, LocationFilter, LotStatusExclusionFilter, Date); // P8001083
        SalesBoard.Reset;
    end;

    local procedure Calculate(ItemNo: Code[20]; VarCode: Code[10]; LocCode: Code[10])
    var
        SalesBoardQuantity: array[2, 17] of Decimal;
        Available: array[2] of Decimal;
        DateOffset: Integer;
        SalesBoardProdChanges: array[17] of Boolean;
        IncludesChanges: Boolean;
    begin
        SetItem(ItemNo); // P8001083

        ItemLedger.SetRange("Item No.", ItemNo);
        PurchaseLine.SetRange("No.", ItemNo);
        SalesLine.SetRange("No.", ItemNo);
        ProdOrderLine.SetRange("Item No.", ItemNo);
        ProdOrderComp.SetRange("Item No.", ItemNo);
        // P8000936
        RepackOrder.SetRange("Item No.", ItemNo);
        RepackLine[1].SetRange("No.", ItemNo);
        RepackLine[2].SetRange("No.", ItemNo);
        // P8000936
        TransferLine[1].SetRange("Item No.", ItemNo);
        TransferLine[2].SetRange("Item No.", ItemNo);
        TransferLine[3].SetRange("Item No.", ItemNo); // P8000887
        ProdPlanChange.Reset;                       // P8000197A
        ProdPlanChange.SetRange("Item No.", ItemNo); // P8000197A

        if VarCode = '----------' then begin // P8001198
            ItemLedger.SetRange("Variant Code");
            PurchaseLine.SetRange("Variant Code");
            SalesLine.SetRange("Variant Code");
            ProdOrderLine.SetRange("Variant Code");
            ProdOrderComp.SetRange("Variant Code");
            // P8000936
            RepackOrder.SetRange("Variant Code");
            RepackLine[1].SetRange("Variant Code");
            RepackLine[2].SetRange("Variant Code");
            // P8000936
            TransferLine[1].SetRange("Variant Code");
            TransferLine[2].SetRange("Variant Code");
            TransferLine[3].SetRange("Variant Code"); // P8000887
            ProdPlanChange.SetRange("Variant Code"); // P8000197A
        end else begin
            ItemLedger.SetRange("Variant Code", VarCode);
            PurchaseLine.SetRange("Variant Code", VarCode);
            SalesLine.SetRange("Variant Code", VarCode);
            ProdOrderLine.SetRange("Variant Code", VarCode);
            ProdOrderComp.SetRange("Variant Code", VarCode);
            // P8000936
            RepackOrder.SetRange("Variant Code", VarCode);
            RepackLine[1].SetRange("Variant Code", VarCode);
            RepackLine[2].SetRange("Variant Code", VarCode);
            // P8000936
            TransferLine[1].SetRange("Variant Code", VarCode);
            TransferLine[2].SetRange("Variant Code", VarCode);
            TransferLine[3].SetRange("Variant Code", VarCode); // P8000887
            ProdPlanChange.SetRange("Variant Code", VarCode); // P8000197A
        end;

        if LocCode = '----------' then begin // P8001198
            ItemLedger.SetRange("Location Code");
            PurchaseLine.SetRange("Location Code");
            SalesLine.SetRange("Location Code");
            ProdOrderLine.SetRange("Location Code");
            ProdOrderComp.SetRange("Location Code");
            // P8000936
            RepackOrder.SetRange("Destination Location");
            RepackLine[1].SetRange("Source Location");
            RepackLine[2].SetRange("Repack Location");
            // P8000936
            TransferLine[1].SetRange("Transfer-to Code");
            TransferLine[2].SetRange("Transfer-from Code");
            TransferLine[3].SetRange("Transfer-from Code"); // P8000887
            ProdPlanChange.SetRange("Location Code"); // P8000197A
        end else begin
            ItemLedger.SetRange("Location Code", LocCode);
            PurchaseLine.SetRange("Location Code", LocCode);
            SalesLine.SetRange("Location Code", LocCode);
            ProdOrderLine.SetRange("Location Code", LocCode);
            ProdOrderComp.SetRange("Location Code", LocCode);
            // P8000936
            RepackOrder.SetRange("Destination Location", LocCode);
            RepackLine[1].SetRange("Source Location", LocCode);
            RepackLine[2].SetRange("Repack Location", LocCode);
            // P8000936
            TransferLine[1].SetRange("Transfer-to Code", LocCode);
            TransferLine[2].SetRange("Transfer-from Code", LocCode);
            TransferLine[3].SetRange("Transfer-from Code", LocCode); // P8000887
            ProdPlanChange.SetRange("Location Code", LocCode); // P8000197A
        end;

        Date.Find('-');
        PurchaseLine.SetRange("Expected Receipt Date", 0D, Date."Period Start" - 1);
        SalesLine.SetRange("Shipment Date", 0D, Date."Period Start" - 1);
        ProdOrderLine.SetRange("Due Date", 0D, Date."Period Start" - 1);
        ProdOrderComp.SetRange("Due Date", 0D, Date."Period Start" - 1);
        // P8000936
        RepackOrder.SetRange("Due Date", 0D, Date."Period Start" - 1);
        RepackLine[1].SetRange("Due Date", 0D, Date."Period Start" - 1);
        RepackLine[2].SetRange("Due Date", 0D, Date."Period Start" - 1);
        // P8000936
        TransferLine[1].SetRange("Receipt Date", 0D, Date."Period Start" - 1);
        TransferLine[2].SetRange("Shipment Date", 0D, Date."Period Start" - 1);
        TransferLine[3].SetRange("Shipment Date", 0D, Date."Period Start" - 1); // P8000887
        ProdPlanChange.SetRange(Date, 0D, Date."Period Start" - 1); // P8000197A

        SalesBoard."Item No." := ItemNo;
        SalesBoard."Variant Code" := VarCode;
        SalesBoard."Location Code" := LocCode;

        DateOffset := -1;
        CalculatePeriod(true, SalesBoardQuantity, SalesBoardProdChanges); // P8000197A
        InsertSalesBoardData(DateOffset, SalesBoardQuantity, SalesBoardProdChanges); // P8000197A

        repeat
            DateOffset += 1;
            Available[1] := SalesBoardQuantity[1, 2]; // P8001083
            Available[2] := SalesBoardQuantity[2, 2]; // P8001083
            IncludesChanges := SalesBoardProdChanges[2]; // P8000197A
            Clear(SalesBoardQuantity);
            Clear(SalesBoardProdChanges); // P8000197A
            SalesBoardQuantity[1, 2] := Available[1]; // P8001083
            SalesBoardQuantity[2, 2] := Available[2]; // P8001083
            SalesBoardProdChanges[2] := IncludesChanges; // P8000197A
            PurchaseLine.SetRange("Expected Receipt Date", Date."Period Start", Date."Period End");
            SalesLine.SetRange("Shipment Date", Date."Period Start", Date."Period End");
            ProdOrderLine.SetRange("Due Date", Date."Period Start", Date."Period End");
            ProdOrderComp.SetRange("Due Date", Date."Period Start", Date."Period End");
            // P8000936
            RepackOrder.SetRange("Due Date", Date."Period Start", Date."Period End");
            RepackLine[1].SetRange("Due Date", Date."Period Start", Date."Period End");
            RepackLine[2].SetRange("Due Date", Date."Period Start", Date."Period End");
            // P8000936
            TransferLine[1].SetRange("Receipt Date", Date."Period Start", Date."Period End");
            TransferLine[2].SetRange("Shipment Date", Date."Period Start", Date."Period End");
            TransferLine[3].SetRange("Shipment Date", Date."Period Start", Date."Period End"); // P8000887
            ProdPlanChange.SetRange(Date, Date."Period Start", Date."Period End"); // P8000197A
            CalculatePeriod(false, SalesBoardQuantity, SalesBoardProdChanges); // P8000197A
            InsertSalesBoardData(DateOffset, SalesBoardQuantity, SalesBoardProdChanges); // P8000197A
        until Date.Next = 0;
    end;

    local procedure CalculatePeriod(PriorToStart: Boolean; var SalesBoardQuantity: array[2, 17] of Decimal; var SalesBoardProdChanges: array[17] of Boolean)
    var
        i: Integer;
        QtyIndex: Integer;
    begin
        // P8000197A - add parameter SalesBoardProdChanges
        // P8001083 - SalesBoardQuantity changed to 2 dimensions
        if PriorToStart then begin
            ItemLedger.CalcSums(Quantity);
            SalesBoardQuantity[2, 1] := ItemLedger.Quantity; // P8001083
            LotStatusMgmt.QuantityAdjForItemLedger(ItemLedger, LotStatusExclusionFilter, ItemLedger.Quantity); // P8001083
            SalesBoardQuantity[1, 1] := ItemLedger.Quantity;
            SalesBoardQuantity[2, 1] -= SalesBoardQuantity[1, 1]; // P8001083
        end;

        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.CalcSums("Outstanding Qty. (Base)");
        // P8001083
        if ExcludePurch then begin
            SalesBoardQuantity[1, 4] := 0;
            SalesBoardQuantity[2, 4] := PurchaseLine."Outstanding Qty. (Base)";
        end else begin
            SalesBoardQuantity[1, 4] := PurchaseLine."Outstanding Qty. (Base)";
            SalesBoardQuantity[2, 4] := 0;
        end;
        // P8001083
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::"Return Order");
        PurchaseLine.CalcSums("Outstanding Qty. (Base)");
        SalesBoardQuantity[1, 5] := PurchaseLine."Outstanding Qty. (Base)"; // P8001083

        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.CalcSums("Outstanding Qty. (Base)");
        SalesBoardQuantity[1, 7] := SalesLine."Outstanding Qty. (Base)"; // P8001083
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Return Order");
        SalesLine.CalcSums("Outstanding Qty. (Base)");
        // P8001083
        if ExcludeSalesRet then begin
            SalesBoardQuantity[1, 8] := 0;
            SalesBoardQuantity[2, 8] := SalesLine."Outstanding Qty. (Base)";
        end else begin
            SalesBoardQuantity[1, 8] := SalesLine."Outstanding Qty. (Base)";
            SalesBoardQuantity[2, 8] := 0;
        end;
        // P8001083

        // P8000936 - Index 9 changed to 10, 9 is new aggregate for Output
        ProdOrderLine.CalcSums("Remaining Qty. (Base)");
        // P8001083
        if ExcludeOutput then begin
            SalesBoardQuantity[1, 10] := 0;
            SalesBoardQuantity[2, 10] := ProdOrderLine."Remaining Qty. (Base)";
            QtyIndex := 2;
        end else begin
            SalesBoardQuantity[1, 10] := ProdOrderLine."Remaining Qty. (Base)";
            SalesBoardQuantity[2, 10] := 0;
            QtyIndex := 1;
        end;
        // P8001083
        ProdPlanChange.SetRange(Type, ProdPlanChange.Type::Output); // P8000197A
        SalesBoardProdChanges[10] := ProdPlanChange.Find('-');      // P8000197A
        ProdPlanChange.CalcSums("Quantity (Base)");                // P8000197A
        SalesBoardQuantity[QtyIndex, 10] += ProdPlanChange."Quantity (Base)"; // P8000197A, P8001083
        SalesBoardProdChanges[2] := SalesBoardProdChanges[2] or SalesBoardProdChanges[10]; // P8000197A

        // P8000936 - Index 10 changed to 13, 12 is new aggregate for consumption
        ProdOrderComp.CalcSums("Remaining Qty. (Base)");
        SalesBoardQuantity[1, 13] := ProdOrderComp."Remaining Qty. (Base)"; // P8001083
        ProdPlanChange.SetRange(Type, ProdPlanChange.Type::Consumption); // P8000197A
        SalesBoardProdChanges[13] := ProdPlanChange.Find('-');          // P8000197A
        ProdPlanChange.CalcSums("Quantity (Base)");                     // P8000197A
        SalesBoardQuantity[1, 13] += ProdPlanChange."Quantity (Base)";     // P8000197A, P8001083
        SalesBoardProdChanges[2] := SalesBoardProdChanges[2] or SalesBoardProdChanges[13]; // P8000197A

        // P8000936
        RepackOrder.CalcSums("Quantity (Base)");
        // P8001083
        if ExcludeOutput then begin
            SalesBoardQuantity[1, 11] := 0;
            SalesBoardQuantity[2, 11] := RepackOrder."Quantity (Base)";
        end else begin
            SalesBoardQuantity[1, 11] := RepackOrder."Quantity (Base)";
            SalesBoardQuantity[2, 11] := 0;
        end;
        // P8001083

        RepackLine[1].CalcSums("Quantity (Base)", "Quantity Transferred (Base)");
        RepackLine[2].CalcSums("Quantity Transferred (Base)");
        SalesBoardQuantity[1, 14] := RepackLine[1]."Quantity (Base)" - RepackLine[1]."Quantity Transferred (Base)" + // P8001083
          RepackLine[2]."Quantity Transferred (Base)";
        // P8000936

        // P8000936 - Index 11, 12, 13 changed to 15, 16, 17
        TransferLine[1].CalcSums("Outstanding Qty. (Base)", "Qty. in Transit (Base)"); // P8000887
        SalesBoardQuantity[2, 16] := // P8001083
          TransferLine[1]."Outstanding Qty. (Base)" + TransferLine[1]."Qty. in Transit (Base)"; // P8000887
        // P8001083
        LotStatusMgmt.QuantityAdjForTransfer(TransferLine[1], LotStatusExclusionFilter,
          TransferLine[1]."Outstanding Qty. (Base)", TransferLine[1]."Qty. in Transit (Base)");
        SalesBoardQuantity[1, 16] := // P8001083
          TransferLine[1]."Outstanding Qty. (Base)" + TransferLine[1]."Qty. in Transit (Base)";
        SalesBoardQuantity[2, 16] -= SalesBoardQuantity[1, 16];
        // P8001083
        TransferLine[2].CalcSums("Outstanding Qty. (Base)");
        SalesBoardQuantity[1, 17] := TransferLine[2]."Outstanding Qty. (Base)"; // P8001083
        TransferLine[3].CalcSums("Outstanding Qty. (Base)");                   // P8000887
        SalesBoardQuantity[1, 17] += TransferLine[3]."Outstanding Qty. (Base)"; // P8000887, P8001083

        // P8001083
        for i := 1 to 2 do begin
            SalesBoardQuantity[i, 3] := SalesBoardQuantity[i, 4] - SalesBoardQuantity[i, 5];
            SalesBoardQuantity[i, 6] := SalesBoardQuantity[i, 7] - SalesBoardQuantity[i, 8];
            SalesBoardQuantity[i, 9] := SalesBoardQuantity[i, 10] + SalesBoardQuantity[i, 11];
            SalesBoardQuantity[i, 12] := SalesBoardQuantity[i, 13] + SalesBoardQuantity[i, 14];
            SalesBoardQuantity[i, 15] := SalesBoardQuantity[i, 16] - SalesBoardQuantity[i, 17];
            if PriorToStart then
                SalesBoardQuantity[i, 2] += SalesBoardQuantity[i, 1];
            SalesBoardQuantity[i, 2] += (SalesBoardQuantity[i, 3] + SalesBoardQuantity[i, 9] + SalesBoardQuantity[i, 15]);
            SalesBoardQuantity[i, 2] -= (SalesBoardQuantity[i, 6] + SalesBoardQuantity[i, 12]);
        end;
        // P8001083
    end;

    local procedure InsertSalesBoardData(DateOffset: Integer; var SalesBoardQuantity: array[2, 17] of Decimal; var SalesBoardProdChanges: array[17] of Boolean)
    var
        SalesBoard2: Record "Item Availability";
        BufferOffset: Integer;
        i: Integer;
    begin
        // P8000197A - add parameter SalesBoardProdChanges
        // P8000936 - Array length for SalesBoardQuantity and SalesBoardProdChanges increased from 13 to 17
        // P8001083 - SalesBoardQuantity changed to 2 dimensions
        for i := 1 to ArrayLen(SalesBoardQuantity, 2) do begin // P8001083
            SalesBoard."Date Offset" := DateOffset;
            SalesBoard."Data Element" := i - 1;
            SalesBoard.Quantity := SalesBoardQuantity[1, i];                 // P8001083
            SalesBoard."Quantity Not Available" := SalesBoardQuantity[2, i]; // P8001083
            SalesBoard."Includes Production Changes" := SalesBoardProdChanges[i]; // P8000197A
            if SalesBoard."Data Element" = SalesBoard."Data Element"::Available then
                SalesBoard."Date Offset" += 1;
            // P8000197A
            if (DateOffset = -1) or (SalesBoard."Data Element" <> SalesBoard."Data Element"::"On Hand") then begin
                BufferLimit[2] += 1;
                BufferLimit[3] += 1;
                if BufferLimit[1] < BufferLimit[2] then begin
                    SalesBoard2.Copy(SalesBoard);
                    SalesBoard.Reset;
                    SalesBoard.SetCurrentKey("Record No.");
                    BufferOffset := BufferLimit[3] - BufferLimit[2];
                    SalesBoard.Find('-');
                    SalesBoard.SetRange("Record No.", 1 + BufferOffset, BufferLimit[4] + BufferOffset);
                    SalesBoard.DeleteAll;
                    BufferLimit[2] -= BufferLimit[4];
                    SalesBoard.Copy(SalesBoard2);
                end;
                SalesBoard."Record No." := BufferLimit[3];
                SalesBoard.Insert;
            end;
            // P8000197A
        end;
    end;

    local procedure SetSalesBoardDate(var SalesBoard: Record "Item Availability")
    var
        Dt: Date;
    begin
        if SalesBoard."Data Element" = SalesBoard."Data Element"::"On Hand" then
            exit;
        Date.Find('-');
        if (SalesBoard."Date Offset" = -1) or (SalesBoard."Date Offset" = Date.Next(SalesBoard."Date Offset")) then
            Dt := Date."Period Start"
        else
            Dt := NormalDate(Date."Period End") + 1;
        if SalesBoard."Date Offset" = -1 then
            SalesBoard."Date Text" := StrSubstNo(Text001, Format(Dt, 0, Text002))
        else
            if SalesBoard."Data Element" = SalesBoard."Data Element"::Available then
                SalesBoard."Date Text" := StrSubstNo('(%1)', Format(Dt, 0, Text002))
            else
                SalesBoard."Date Text" := StrSubstNo('(%1)', Format(Dt, 0, DateFormat));
    end;

    local procedure GetDisplayOptions(ItemNo: Code[20]; VariantFilter: Text[250]; LocationFilter: Text[250]; CalcShortage: Boolean; CalcZero: Boolean; var Shortage: Boolean; var Zero: Boolean)
    var
        DataElement: Integer;
        DateOffset: Integer;
        Periods: Integer;
    begin
        if (ItemNo = xItemNo) and (VariantFilter = xVariantFilter) and (LocationFilter = xLocationFilter) and
          (CalcShortage and (xShortage <> '')) and (CalcZero and (xZero <> ''))
        then begin
            Shortage := xShortage = 'Y';
            Zero := xZero = 'Y';
            exit;
        end;

        xItemNo := ItemNo;
        xVariantFilter := VariantFilter;
        xLocationFilter := xLocationFilter;
        SetTempFilters(VariantFilter, LocationFilter);
        if TempVariant.Find('-') then
            repeat
                if TempLocation.Find('-') then
                    repeat
                        if not SalesBoard.Get(ItemNo, TempVariant.Code, TempLocation.Code, 0, 1) then
                            Calculate(ItemNo, TempVariant.Code, TempLocation.Code);
                    until TempLocation.Next = 0;
            until TempVariant.Next = 0;

        SalesBoard.SetRange("Item No.", ItemNo);
        SalesBoard.SetFilter("Variant Code", VariantFilter);
        SalesBoard.SetFilter("Location Code", LocationFilter);

        Shortage := false;
        Zero := true;
        Periods := 1 + Date.Count;
        for DateOffset := -1 to Periods do begin
            SalesBoard.SetRange("Date Offset", DateOffset);
            for DataElement := 0 to 12 do
                if (CalcZero and Zero) or
                  (CalcShortage and (not Shortage) and (DataElement = SalesBoard."Data Element"::Available))
                then begin
                    SalesBoard.SetRange("Data Element", DataElement);
                    SalesBoard.CalcSums(Quantity);
                    if CalcZero and (SalesBoard.Quantity <> 0) then
                        Zero := false;
                    if (CalcShortage and (not Shortage) and (DataElement = SalesBoard."Data Element"::Available)) and
                      (SalesBoard.Quantity < 0)
                    then
                        Shortage := true;
                end;
        end;

        if CalcShortage then begin
            if Shortage then
                xShortage := 'Y'
            else
                xShortage := 'N';
        end else
            xShortage := '';

        if CalcZero then begin
            if Zero then
                xZero := 'Y'
            else
                xZero := 'N';
        end else
            xZero := '';
    end;

    procedure ShowRecord(ItemNo: Code[20]; VariantFilter: Text[250]; LocationFilter: Text[250]; ShortagesOnly: Boolean; HideZero: Boolean): Boolean
    var
        Shortage: Boolean;
        Zero: Boolean;
    begin
        if ItemNo = '' then // P8001083
            exit(false);      // P8001083

        if ShortagesOnly or HideZero then begin
            GetDisplayOptions(ItemNo, VariantFilter, LocationFilter, ShortagesOnly, HideZero, Shortage, Zero);
            if ShortagesOnly then
                exit(Shortage)
            else
                if HideZero then
                    exit(not Zero);
        end else
            exit(true);
    end;

    procedure AddProductionChanges(var ProdPlanChange2: Record "Daily Prod. Planning-Change" temporary)
    begin
        // P8000197A
        SalesBoard.Reset;
        ProdPlanChange.Reset;
        ProdPlanChange.SetRange(Status, ProdPlanChange2.Status);
        ProdPlanChange.SetRange("Production Order No.", ProdPlanChange2."Production Order No.");
        if ProdPlanChange.Find('-') then
            repeat
                SalesBoard.SetRange("Item No.", ProdPlanChange."Item No.");
                SalesBoard.DeleteAll;
                ProdPlanChange.Delete;
            until ProdPlanChange.Next = 0;
        ProdPlanChange.Reset;

        ProdPlanChange2.SetCurrentKey("Item No.");
        ProdPlanChange2.SetFilter("Quantity (Base)", '<>0');
        if ProdPlanChange2.Find('-') then
            repeat
                SalesBoard.SetRange("Item No.", ProdPlanChange2."Item No.");
                SalesBoard.DeleteAll;
                ProdPlanChange2.SetRange("Item No.", ProdPlanChange2."Item No.");
                repeat
                    ProdPlanChange := ProdPlanChange2;
                    ProdPlanChange.Insert;
                until ProdPlanChange2.Next = 0;
                ProdPlanChange2.SetRange("Item No.");
            until ProdPlanChange2.Next = 0;
    end;

    local procedure SetItem(ItemNo: Code[20])
    begin
        // P8001083
        if Item."No." <> ItemNo then begin
            Item.Get(ItemNo);
            LotStatusMgmt.SetInboundExclusions(Item, AvailableFor, ExcludePurch, ExcludeSalesRet, ExcludeOutput);
        end;
    end;
}

