codeunit 37002041 "Sales Order-Order Guide"
{
    // PR3.70
    //   Enhanced for contract items
    // 
    // PR3.70.10
    // P8000210A, Myers Nissi, Jack Reynolds, 10 MAY 05
    //   Copy lot preferences to sales line
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Changes to Item Ledger keys
    // 
    // PR4.00.02
    // P8000315A, VerticalSoft, Jack Reynolds, 28 MAR 06
    //   Modify and add function to support variant and unit price as part of sales order guide
    // 
    // PR4.00.03
    // P8000327A, VerticalSoft, Jack Reynolds, 28 APR 06
    //   Fix problem calculating unit price
    // 
    // P8000347A, VerticalSoft, Jack Reynolds, 22 JUN 06
    //   Changes to cleanup ItemFind and ItemNext
    // 
    // PR4.00.04
    // P8000348A, VerticalSoft, Jack Reynolds, 28 JUN 06
    //   Fix issue with Last Order Amount and Last Cost (for different UOM's)
    // 
    // P8000368A, VerticalSoft, Jack Reynolds, 29 AUG 06
    //  Fix division by zero error when getting last transaction info and no history
    // 
    // P8000384A, VerticalSoft, Jack Reynolds, 22 SEP 06
    //   Cleanup confusion between bill-to and sell-to customer
    // 
    // P8000433A, VerticalSoft, Jack Reynolds, 18 JAN 07
    //   Fix problem with ItemHasActivity not filtering on date
    // 
    // PRW16.00.01
    // P8000700, VerticalSoft, Jack Reynolds, 21 MAY 09
    //   Support for contract items established with campaign pricing
    // 
    // PRW16.00.04
    // P8000878, VerticalSoft, Ron Davidson, 12 NOV 10
    //   Added Check for Inventory and Customer Credit/Overdue
    //   Filtered out Items blocked as Cust./Items Alt.
    // 
    // PRW16.00.04
    // P8000885, VerticalSoft, Ron Davidson, 29 DEC 10
    //   Added login to use Sales Contracts
    // 
    // PRW16.00.05
    // P8000949, Columbus IT, Jack Reynolds, 25 MAY 11
    //   Fix problem display customer card from sales order guide
    // 
    // P8000982, Columbus IT, Jack Reynolds, 22 SEP 11
    //   Fix problem with selecting contracts
    // 
    // P8000981, Columbus IT, Don Bresee, 20 SEP 11
    //   Use Pricing Qty for Sales Price calculations
    // 
    // PRW16.00.06
    // P8000999, Columbus IT, Jack Reynolds, 09 DEC 11
    //   Non-modal operation of the Order Guide
    //   Different searching for history items
    // 
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10.03
    // P8001349, Columbus IT, Jack Reynolds, 23 SEP 14
    //   Fix problem checking contract limits on order guide
    // 
    // PRW18.00.01
    // P8001386, Columbus IT, Jack Reynolds, 26 MAY 15
    //   Refactoring changess for cumulative updates
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Upgrade signal control for JavaScript
    // 
    // PRW111.00.02
    // P80067644, To Increase, Gangabhushan, 27 NOV 18
    //   TI-12366 Freight calculation(Unit price (Freight) Excl. VAT) skipped when sales line is added through order Guide
    // 
    // PRW114.00
    // P80072447, To-Increase, Gangabhushan, 10 APR 19
    //   Dev. Pricing information on the Sales Order Guide
    // 
    // P80072449, To-Increase, Gangabhushan, 27 MAY 19
    //   Dev. Margin Information per item on the Sales Order Guide
    // 
    // PRW119.0
    // P800133109, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 19.0 - Qty. Rounding Precision

    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Nothing to add to the %1.';
        GLSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        SellToCustomer: Record Customer;
        BillToCustomer: Record Customer;
        SearchItemLedgEntry: Record "Item Ledger Entry";
        SearchSpecialItem: array[2] of Record Item;
        BlockedItem: Record Item;
        HistoryItem: Record Item;
        TempItemQty: Record "Item Ledger Entry" temporary;
        TempItemQtyEntryNo: Integer;
        Text001: Label 'Adding Items...\\Item No. #1##################';
        Text002: Label 'One item added to the %1.';
        Text003: Label '%1 items added to the %2.';
        Text004: Label 'This form must be run from a Sales Document.';
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        ProcessFns: Codeunit "Process 800 Functions";
        LotSpecFns: Codeunit "Lot Specification Functions";
        StartingDate: Date;
        EndingDate: Date;
        TotalOutstandingAmt: Decimal;
        SalesContractNo: Code[20];
        PriceID: Integer;
        BlockedItemsExist: Boolean;
        LotStatus: Record "Lot Status Code";
        LotStatusMgmt: Codeunit "Lot Status Management";
        LotStatusExclusionFilter: Text[1024];
        gOrderGuideGetPriceContract: Code[20];

    procedure AddOrderLines(LocationCode: Code[10]; var TempItemQty2: Record "Item Ledger Entry" temporary)
    var
        NewSalesLine: Record "Sales Line";
        TransferExtendedText: Codeunit "Transfer Extended Text";
        LinesAdded: Integer;
        StatusWindow: Dialog;
        ContractInfofactBox: Page "Order Guiide Contract FactBox";
    begin
        // P8000999
        with SalesHeader do begin
            TempItemQty.Reset;
            if not TempItemQty.Find('-') then begin
                Message(Text000, "Document Type");
                exit;
            end;

            StatusWindow.Open(Text001);

            NewSalesLine.SetRange("Document Type", "Document Type");
            NewSalesLine.SetRange("Document No.", "No.");
            if not NewSalesLine.FindLast then begin
                NewSalesLine."Document Type" := "Document Type";
                NewSalesLine."Document No." := "No.";
                NewSalesLine."Line No." := 0;
            end;

            repeat
                StatusWindow.Update(1, TempItemQty."Item No.");

                NewSalesLine.Init;
                NewSalesLine."Line No." := NewSalesLine."Line No." + 10000;
                NewSalesLine.SetDoNotUpdatePrice(true); // P8000885
                NewSalesLine.Validate(Type, NewSalesLine.Type::Item);
                NewSalesLine.Validate("No.", TempItemQty."Item No.");
                NewSalesLine."Contract No." := TempItemQty."Order No."; // P8000885, P8001132
                NewSalesLine."Price ID" := TempItemQty."Maint. Ledger Entry No."; // P8000885
                if TempItemQty."Variant Code" <> '' then                            // P8000315A
                    NewSalesLine.Validate("Variant Code", TempItemQty."Variant Code"); // P8000315A
                if (NewSalesLine."Unit of Measure Code" <> TempItemQty."Unit of Measure Code") then
                    NewSalesLine.Validate("Unit of Measure Code", TempItemQty."Unit of Measure Code");
                if (NewSalesLine."Location Code" <> LocationCode) then
                    NewSalesLine.Validate("Location Code", LocationCode);
                NewSalesLine.Validate(Quantity, TempItemQty.Quantity);
                NewSalesLine.Validate("Unit Price (FOB)", TempItemQty."Remaining Quantity");  // P80067644
                NewSalesLine.Insert(true);
                if ProcessFns.TrackingInstalled then                       // P8000210A
                    LotSpecFns.CopyLotPrefCustomerToSalesLine(NewSalesLine); // P8000210A
                if TransferExtendedText.SalesCheckIfAnyExtText(NewSalesLine, false) then begin
                    TransferExtendedText.InsertSalesExtText(NewSalesLine);
                    NewSalesLine.Find('+');
                end;

                LinesAdded := LinesAdded + 1;
                ContractInfofactBox.ClearContractFields(TempItemQty."Item No."); // P80072447
                TempItemQty2 := TempItemQty; // P80072449
                TempItemQty2.Insert; // P80072449
            until (TempItemQty.Next = 0);

            if (LinesAdded = 1) then
                Message(Text002, "Document Type")
            else
                Message(Text003, LinesAdded, "Document Type");

            TempItemQty.DeleteAll;

            StatusWindow.Close;
        end;
    end;

    procedure SetDocument(var SalesHeader2: Record "Sales Header")
    begin
        SalesHeader := SalesHeader2;
        SellToCustomer.Get(SalesHeader."Sell-to Customer No."); // P8000384A
        BillToCustomer.Get(SalesHeader."Bill-to Customer No."); // P8000384A
    end;

    procedure ItemListInit(var Item: Record Item)
    begin
        if SellToCustomer."No." = '' then  // P8000384A
            Error(Text004);

        GLSetup.Get; // P8000348A

        Item.SetRange("Location Filter", SalesHeader."Location Code");

        SearchItemLedgEntry.SetCurrentKey("Entry Type", "Item No.", "Variant Code", "Source Type", "Source No.", "Posting Date"); // P8000267B
        SearchItemLedgEntry.SetRange("Source Type", SearchItemLedgEntry."Source Type"::Customer);
        SearchItemLedgEntry.SetRange("Source No.", SellToCustomer."No."); // P8000384A
        SearchItemLedgEntry.SetRange("Entry Type", SearchItemLedgEntry."Entry Type"::Sale);

        SpecialPriceItemListInit; // PR3.70
        ContractItemListInit;     // PR3.70
        BlockedItemListInit; // P8000878

        TempItemQty.SetCurrentKey("Item No.");

        LotStatusExclusionFilter := LotStatusMgmt.SetLotStatusExclusionFilter(LotStatus.FieldNo("Available for Sale")); // P8001083
    end;

    procedure HistoryItemListInit()
    var
        ItemLedger: Record "Item Ledger Entry";
    begin
        // P8000999
        HistoryItem.Reset;

        ItemLedger.SetCurrentKey("Item No.", "Entry Type");
        ItemLedger.SetRange("Entry Type", ItemLedger."Entry Type"::Sale);
        ItemLedger.SetRange("Source Type", ItemLedger."Source Type"::Customer);
        ItemLedger.SetRange("Source No.", SellToCustomer."No.");
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

    local procedure SpecialPriceItemListInit()
    var
        SearchSpecialPrice: Record "Sales Price";
        PriceDate: Date;
    begin
        // PR3.70 - Change name from SpecialItemListInit
        with SearchSpecialPrice do begin
            SetCurrentKey("Special Price", "Item Type", "Item Code",
                          "Sales Type", "Sales Code", "Starting Date", "Ending Date");
            SetRange("Special Price", true);
            SetRange("Item Type", "Item Type"::Item);

            if (SalesHeader."Document Type" <> SalesHeader."Document Type"::Order) then
                PriceDate := SalesHeader."Posting Date"
            else
                if SalesHeader."Price at Shipment" then
                    PriceDate := SalesHeader."Shipment Date"
                else
                    PriceDate := SalesHeader."Order Date";

            SetRange("Starting Date", 0D, PriceDate);
            SetFilter("Ending Date", '%1|%2..', 0D, PriceDate);

            SetRange("Sales Type", "Sales Type"::"All Customers");
            SpecialItemsMark(SearchSpecialPrice, 1); // PR3.70

            SetRange("Sales Type", "Sales Type"::"Customer Price Group");
            SetRange("Sales Code", SalesHeader."Customer Price Group");
            SpecialItemsMark(SearchSpecialPrice, 1); // PR3.70

            SetRange("Sales Type", "Sales Type"::Customer);
            SetRange("Sales Code", SalesHeader."Bill-to Customer No.");
            SpecialItemsMark(SearchSpecialPrice, 1); // PR3.70

            SetRange("Sales Code", SalesHeader."Sell-to Customer No.");
            SpecialItemsMark(SearchSpecialPrice, 1); // PR3.70
        end;

        SearchSpecialItem[1].MarkedOnly(true);
    end;

    procedure ContractItemListInit()
    var
        SearchSpecialPrice: Record "Sales Price";
        TempTargetCampaignGr: Record "Campaign Target Group" temporary;
        SalesPriceMgt: Codeunit "Sales Price Calc. Mgt.";
        PriceDate: Date;
    begin
        // PR3.70
        with SearchSpecialPrice do begin
            SetCurrentKey("Price Type", "Item Type", "Item Code", "Sales Type", "Sales Code", "Starting Date", "Ending Date");
            SetFilter("Price Type", '%1|%2', "Price Type"::Contract, "Price Type"::"Soft Contract");
            SetRange("Item Type", "Item Type"::Item);

            if (SalesHeader."Document Type" <> SalesHeader."Document Type"::Order) then
                PriceDate := SalesHeader."Posting Date"
            else
                if SalesHeader."Price at Shipment" then
                    PriceDate := SalesHeader."Shipment Date"
                else
                    PriceDate := SalesHeader."Order Date";

            SetRange("Starting Date", 0D, PriceDate);
            SetFilter("Ending Date", '%1|%2..', 0D, PriceDate);

            SetRange("Sales Type", "Sales Type"::"All Customers");
            SpecialItemsMark(SearchSpecialPrice, 2); // PR3.70

            SetRange("Sales Type", "Sales Type"::"Customer Price Group");
            SetRange("Sales Code", SalesHeader."Customer Price Group");
            SpecialItemsMark(SearchSpecialPrice, 2); // PR3.70

            SetRange("Sales Type", "Sales Type"::Customer);
            SetRange("Sales Code", SalesHeader."Bill-to Customer No.");
            SpecialItemsMark(SearchSpecialPrice, 2); // PR3.70

            SetRange("Sales Code", SalesHeader."Sell-to Customer No.");
            SpecialItemsMark(SearchSpecialPrice, 2); // PR3.70

            // P8000700
            SetRange("Sales Type", "Sales Type"::Campaign);
            if SalesPriceMgt.ActivatedCampaignExists(TempTargetCampaignGr, SalesHeader."Bill-to Customer No.",
              SalesHeader."Bill-to Contact No.", '')
            then
                repeat
                    SetRange("Sales Code", TempTargetCampaignGr."Campaign No.");
                    SpecialItemsMark(SearchSpecialPrice, 2); // PR3.70
                until TempTargetCampaignGr.Next = 0;
            // P8000700
        end;

        SearchSpecialItem[2].MarkedOnly(true);
    end;

    local procedure SpecialItemsMark(var SearchSpecialPrice: Record "Sales Price"; SpecialIndex: Integer)
    begin
        // PR3.70 - add parameter for SpecialIndex
        with SearchSpecialPrice do
            if Find('-') then
                repeat
                    SearchSpecialItem[SpecialIndex].Get("Item Code"); // PR3.70
                    SearchSpecialItem[SpecialIndex].Mark(true);         // PR3.70

                    SetRange("Item Code", "Item Code");
                    Find('+');
                    SetRange("Item Code");
                until (Next = 0);
    end;

    procedure BlockedItemListInit()
    var
        CustItemAlternate: Record "Customer Item Alternate";
    begin
        // P8000878
        CustItemAlternate.SetRange("Customer No.", SalesHeader."Sell-to Customer No.");
        CustItemAlternate.SetRange("Alternate Item No.", '');
        if CustItemAlternate.FindSet then
            repeat
                BlockedItem.Get(CustItemAlternate."Sales Item No.");
                BlockedItem.Mark(true);
            until CustItemAlternate.Next = 0;

        BlockedItem.MarkedOnly(true);
        BlockedItemsExist := not CustItemAlternate.IsEmpty;
    end;

    procedure ItemFind(var Item: Record Item; Which: Text[30]; ShowItemsWithActivity: Boolean; SpecialIndex: Integer): Boolean
    var
        Direction: Integer;
        EOF: Boolean;
        i: Integer;
    begin
        // P8000347A
        if (not (ShowItemsWithActivity or (SpecialIndex <> 0) or BlockedItemsExist)) then // P8000878
            exit(Item.Find(Which));
        with Item do
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
                EOF := not Find(CopyStr(Which, i, 1));
                while (not EOF) and (not ShowItem(Item, SpecialIndex, ShowItemsWithActivity)) do
                    EOF := Next(Direction) = 0;
                if not EOF then
                    exit(true);
            end;
    end;

    procedure ItemNext(var Item: Record Item; Steps: Integer; ShowItemsWithActivity: Boolean; SpecialIndex: Integer): Integer
    var
        NextRec: Record Item;
        Direction: Integer;
        NoSteps: Integer;
        StepsTaken: Integer;
        EOF: Boolean;
    begin
        // P8000347A
        if (not (ShowItemsWithActivity or (SpecialIndex <> 0) or BlockedItemsExist)) then // P8000878
            exit(Item.Next(Steps));
        with Item do begin
            NextRec := Item;
            Direction := 1;
            if Steps < 0 then
                Direction := -1;
            NoSteps := Direction * Steps;
            while (StepsTaken < NoSteps) and (not EOF) do begin
                EOF := Next(Direction) = 0;
                if (not EOF) and ShowItem(Item, SpecialIndex, ShowItemsWithActivity) then begin
                    NextRec := Item;
                    StepsTaken += 1;
                end;
            end;
            Item := NextRec;
            exit(Direction * StepsTaken);
        end;
    end;

    procedure ShowItem(var Item: Record Item; SpecialIndex: Integer; ShowItemsWithActivity: Boolean): Boolean
    begin
        // P8000347A
        // Always show items with quantity entered
        TempItemQty.SetRange("Item No.", Item."No.");
        TempItemQty.SetFilter(Quantity, '<>0');
        if TempItemQty.Find('-') then
            exit(true);
        // P8000878
        BlockedItem.SetRange("No.", Item."No.");
        if not BlockedItem.IsEmpty then
            exit(false);
        // P8000878
        if SpecialIndex <> 0 then begin
            if IsSpecialItem(Item, SpecialIndex) then begin
                if ShowItemsWithActivity then
                    exit(ItemHasActivity(Item))
                else
                    exit(true);
            end;
        end else
            if ShowItemsWithActivity then
                exit(ItemHasActivity(Item)) // P8000878
            else                          // P8000878
                exit(true);                 // P8000878
    end;

    procedure IsSpecialItem(var Item: Record Item; SpecialIndex: Integer): Boolean
    begin
        // PR3.70 - add parameter for special index
        SearchSpecialItem[SpecialIndex]."No." := Item."No."; // PR3.70
        exit(SearchSpecialItem[SpecialIndex].Find);          // PR3.70
    end;

    procedure ItemHasActivity(var Item: Record Item): Boolean
    begin
        // P8000999
        HistoryItem."No." := Item."No.";
        exit(HistoryItem.Mark);
    end;

    procedure QtyToOrderExists(): Boolean
    begin
        TempItemQty.SetRange("Item No.");
        TempItemQty.SetFilter(Quantity, '<>0');
        exit(TempItemQty.Find('-'));
    end;

    procedure GetQtyToOrder(var Item: Record Item; var QtyToOrder: Decimal; var VariantToOrder: Code[10]; var OrderUOM: Code[10]; var DefOrderUOM: Code[10]; var UnitPrice: Decimal; var SalesContractNo: Code[20]; var PriceFromUnitPriceFnc: Boolean)
    begin
        // P8000315A - add parameters for variant and price
        TempItemQty.SetRange("Item No.", Item."No.");
        TempItemQty.SetRange(Quantity);
        if not TempItemQty.Find('-') then
            TempItemQty.Init;
        QtyToOrder := TempItemQty.Quantity;
        VariantToOrder := TempItemQty."Variant Code"; // P8000315A
        OrderUOM := TempItemQty."Unit of Measure Code";
        DefOrderUOM := GetDefOrderUOM(Item);
        if (OrderUOM = '') then
            OrderUOM := DefOrderUOM;
        UnitPrice := TempItemQty."Remaining Quantity"; // P8000315A
        SalesContractNo := TempItemQty."Order No."; // P8000885, P8001132
        PriceID := TempItemQty."Maint. Ledger Entry No."; // P8000885
        PriceFromUnitPriceFnc := TempItemQty.Positive;  // P80072447
    end;

    local procedure GetDefOrderUOM(var Item: Record Item): Code[10]
    begin
        SearchItemLedgEntry.SetRange("Item No.", Item."No.");
        SearchItemLedgEntry.SetRange("Posting Date");
        if SearchItemLedgEntry.Find('+') then
            exit(SearchItemLedgEntry."Unit of Measure Code");
        if (Item."Sales Unit of Measure" <> '') then
            exit(Item."Sales Unit of Measure");
        exit(Item."Base Unit of Measure");
    end;

    procedure GetLastTransactionInfo(var Item: Record Item; var LastDocNo: Code[20]; var LastDate: Date; var LastQty: Decimal; var LastUOM: Code[10]; var LastUnitPrice: Decimal; var LastAmount: Decimal)
    begin
        // P8000348A - add parameter for LastAmount
        SearchItemLedgEntry.SetRange("Item No.", Item."No.");
        SearchItemLedgEntry.SetRange("Posting Date");
        if not SearchItemLedgEntry.Find('+') then
            SearchItemLedgEntry.Init;
        LastDocNo := SearchItemLedgEntry."Document No.";
        LastDate := SearchItemLedgEntry."Posting Date";
        LastQty := -SearchItemLedgEntry.Quantity;                   // P8000368A
        if SearchItemLedgEntry."Qty. per Unit of Measure" <> 0 then // P8000368A
            LastQty := Round(LastQty / SearchItemLedgEntry."Qty. per Unit of Measure", 0.00001); // P8000348A, P8000368A
        LastUOM := SearchItemLedgEntry."Unit of Measure Code";
        // P8000348A
        if LastQty = 0 then begin
            LastAmount := 0;
            LastUnitPrice := 0;
        end else begin
            SearchItemLedgEntry.CalcFields("Sales Amount (Expected)", "Sales Amount (Actual)");
            LastAmount := SearchItemLedgEntry."Sales Amount (Actual)" + SearchItemLedgEntry."Sales Amount (Expected)";
            //LastUnitPrice := LastAmount / -SearchItemLedgEntry.GetCostingQty; // P8000981
            LastUnitPrice := LastAmount / -SearchItemLedgEntry.GetPricingQty;   // P8000981
        end;

        //IF NOT Item.CostInAlternateUnits THEN // P8000981
        if not Item.PriceInAlternateUnits then  // P8000981
            LastUnitPrice := Round(LastUnitPrice * SearchItemLedgEntry."Qty. per Unit of Measure",
              GLSetup."Unit-Amount Rounding Precision");
        // P8000348A
    end;

    procedure SetQtyToOrder(var Item: Record Item; QtyToOrder: Decimal; VariantToOrder: Code[10]; OrderUOM: Code[10]; DefOrderUOM: Code[10]; UnitPrice: Decimal; SalesContractNo: Code[20]; PriceFromGetPricefnc: Boolean)
    var
        SalesLine: Record "Sales Line";
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        CustCheckCreditLimit: Codeunit "Cust-Check Cr. Limit";
        ItemFound: Boolean;
        OutstandAmount: Decimal;
    begin
        // P8000315A - add parameters for variant and price

        // P8000878
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine."No." := Item."No.";
        SalesLine."Variant Code" := VariantToOrder;
        SalesLine."Contract No." := SalesContractNo; // P8000885
        SalesLine."Price ID" := PriceID; // P8000885
        SalesLine."Location Code" := GetFormLocationCode(Item); // P8000885
        SalesLine.SetDoNotUpdatePrice(true); // P8000885
        SalesLine.Validate("Unit of Measure Code", OrderUOM); // P8000885
        SalesLine.Validate(Quantity, QtyToOrder);
        SalesLine.Validate("Unit Price", UnitPrice);
        OutstandAmount := SalesLine."Outstanding Amount (LCY)";
        TempItemQty.SetRange("Item No.", Item."No.");
        TempItemQty.SetRange(Quantity);
        if TempItemQty.Find('-') then begin
            TotalOutstandingAmt += SalesLine."Outstanding Amount (LCY)" - TempItemQty."Invoiced Quantity";
            SalesLine."Outstanding Amount (LCY)" := TotalOutstandingAmt;
            ItemFound := true;
        end else begin
            TotalOutstandingAmt += SalesLine."Outstanding Amount (LCY)";
            SalesLine."Outstanding Amount (LCY)" := TotalOutstandingAmt;
        end;
        ItemCheckAvail.SalesLineCheck(SalesLine); // P8001386, P8004516
        CustCheckCreditLimit.SalesLineCheck(SalesLine);
        //TempItemQty.SETRANGE("Item No.", Item."No.");
        //TempItemQty.SETRANGE(Quantity);
        //IF TempItemQty.FIND('-') THEN BEGIN
        if ItemFound then begin
            // P8000878
            TempItemQty.Quantity := QtyToOrder;
            TempItemQty."Variant Code" := VariantToOrder; // P8000315A
            TempItemQty."Unit of Measure Code" := OrderUOM;
            TempItemQty."Remaining Quantity" := UnitPrice; // P8000315A
            TempItemQty."Invoiced Quantity" := OutstandAmount; // P8000878
            TempItemQty."Order No." := SalesContractNo; //P800088, P8001132
            TempItemQty."Maint. Ledger Entry No." := PriceID; // P8000885
                                                              // P80072447
            TempItemQty.Positive := PriceFromGetPricefnc;
            if (QtyToOrder = 0) and (OrderUOM = DefOrderUOM) and (UnitPrice = 0) then
                // P80072447
                TempItemQty.Delete
            else
                TempItemQty.Modify;
        end else begin
            TempItemQty.Init;
            if (QtyToOrder <> 0) or (OrderUOM <> DefOrderUOM) or (UnitPrice <> 0) then begin // P80072447
                TempItemQtyEntryNo := TempItemQtyEntryNo + 1;
                TempItemQty."Entry No." := TempItemQtyEntryNo;
                TempItemQty."Item No." := Item."No.";
                TempItemQty."Variant Code" := VariantToOrder; // P8000315A
                TempItemQty.Quantity := QtyToOrder;
                TempItemQty."Unit of Measure Code" := OrderUOM;
                TempItemQty."Remaining Quantity" := UnitPrice; // P8000315A
                TempItemQty."Invoiced Quantity" := OutstandAmount; // P800878
                TempItemQty."Order No." := SalesContractNo; //P8000885, P8001132
                TempItemQty."Maint. Ledger Entry No." := PriceID; // P8000885
                TempItemQty.Positive := PriceFromGetPricefnc; // P80072447
                TempItemQty.Insert;
            end;
        end;
    end;

    procedure GetQtyOrdered(var Item: Record Item): Decimal
    begin
        SearchItemLedgEntry.SetRange("Item No.", Item."No.");
        // P8000878
        if StartingDate <> 0D then
            SearchItemLedgEntry.SetRange("Posting Date", StartingDate, EndingDate)
        else
            SearchItemLedgEntry.SetRange("Posting Date");
        // P8000878
        SearchItemLedgEntry.CalcSums(Quantity);
        exit(-SearchItemLedgEntry.Quantity);
    end;

    procedure GetFormCaption(): Text[250]
    var
        SalesOrderGuide: Page "Sales Order Guide";
    begin
        exit(StrSubstNo('%1 - %2 %3 / %4 %5', SalesOrderGuide.Caption, // P80059471
                        SellToCustomer."No.", SellToCustomer.Name, // P8000384A
                        SalesHeader."Document Type", SalesHeader."No."));
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

    procedure ValidateUOM(var Item: Record Item; var OrderUOM: Code[10]; VariantToOrder: Code[10]; QtyToOrder: Decimal; var UnitPrice: Decimal; SalesContractNo: Code[20])
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SalesLine: Record "Sales Line";
    begin
        // P8000315A - add parameters for variant, quantity, price
        ItemUnitOfMeasure."Item No." := Item."No.";
        ItemUnitOfMeasure.Code := OrderUOM;
        if not ItemUnitOfMeasure.Find('=>') then
            ItemUnitOfMeasure.Get(Item."No.", OrderUOM);
        if (ItemUnitOfMeasure."Item No." <> Item."No.") or
           (CopyStr(ItemUnitOfMeasure.Code, 1, StrLen(OrderUOM)) <> OrderUOM)
        then
            ItemUnitOfMeasure.Get(Item."No.", OrderUOM);
        OrderUOM := ItemUnitOfMeasure.Code;
        UnitPrice := GetUnitPrice(Item."No.", QtyToOrder, VariantToOrder, OrderUOM, SalesContractNo); // P8000315A, P8000327A, P80072447
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

    procedure ValidateVariant(var Item: Record Item; OrderUOM: Code[10]; var VariantToOrder: Code[10]; QtyToOrder: Decimal; var UnitPrice: Decimal; SalesContractNo: Code[20])
    var
        ItemVariant: Record "Item Variant";
        SalesLine: Record "Sales Line";
    begin
        // P8000315A
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
        UnitPrice := GetUnitPrice(Item."No.", QtyToOrder, VariantToOrder, OrderUOM, SalesContractNo); // P8000327A, P80072447
    end;

    procedure LookupVariant(var Item: Record Item; var Text: Text[30]): Boolean
    var
        ItemVariant: Record "Item Variant";
    begin
        // P8000315A
        ItemVariant.SetRange("Item No.", Item."No.");
        ItemVariant."Item No." := Item."No.";
        ItemVariant.Code := Text;
        if (PAGE.RunModal(0, ItemVariant) <> ACTION::LookupOK) then
            exit(false);
        Text := ItemVariant.Code;
        exit(true);
    end;

    procedure ValidateQty(var Item: Record Item; OrderUOM: Code[10]; VariantToOrder: Code[10]; var QtyToOrder: Decimal; var UnitPrice: Decimal; var SalesContractNo: Code[20])
    var
        SalesLine: Record "Sales Line";
    begin
        // P8000315A
        UnitPrice := GetUnitPrice(Item."No.", QtyToOrder, VariantToOrder, OrderUOM, SalesContractNo); // P8000327A, P80072447
    end;

    procedure GetUnitPrice(ItemNo: Code[20]; Qty: Decimal; VariantToOrder: Code[10]; UOM: Code[10]; var SalesContractNo: Code[20]): Decimal
    var
        SalesLine: Record "Sales Line";
        ItemUOM: Record "Item Unit of Measure";
        UOMMgt: Codeunit "Unit of Measure Management";
        SalesPriceCalc: Codeunit "Sales Price Calc. Mgt.";
        ItemSalesPriceMgmt: Codeunit "Item Sales Price Management";
        Item: Record Item;
    begin
        // P8000315A
        // P8000327A - remove parameter for CalledByFieldNo
        if Qty = 0 then
            exit;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Sell-to Customer No." := SalesHeader."Sell-to Customer No.";
        SalesLine."Bill-to Customer No." := SalesHeader."Bill-to Customer No.";
        // P80072447
        //SalesLine."Customer Price Group" := SalesHeader."Customer Price Group"; // P8000327A
        Item.Get(ItemNo);
        ItemSalesPriceMgmt.SetCustItemPriceGroup(
          SalesLine."Customer Price Group", SalesHeader.PriceGroupCustomerNo, Item."Item Category Code");
        // P80072447
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine."No." := ItemNo;
        SalesLine.Quantity := Qty;
        SalesLine."Unit of Measure Code" := UOM;
        SalesLine."Variant Code" := VariantToOrder;
        ItemUOM.Get(ItemNo, UOM);
        SalesLine."Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
        SalesLine."Quantity (Base)" := UOMMgt.CalcBaseQty(ItemNo, UOM, Qty); // P800133109
        SalesLine."Outstanding Qty. (Base)" := SalesLine."Quantity (Base)"; // ***
        SalesLine."Contract No." := SalesContractNo; // P8000885
        SalesLine."Price ID" := PriceID; // P8000885
        SalesLine.InitOutstandingQtyCont; // P8001349
        SalesPriceCalc.FindSalesLinePrice(SalesHeader, SalesLine, -1); // P8000327A, P8000982, P8000999
        if (SalesContractNo = '') and (SalesLine."Contract No." <> '') then // P8001349
            SalesPriceCalc.FindSalesLinePrice(SalesHeader, SalesLine, -1);      // P8001349
        SalesContractNo := SalesLine."Contract No."; // P8000885
        PriceID := SalesLine."Price ID"; // P8000885
        exit(SalesLine."Unit Price");
    end;

    procedure GetQtyAvailable(var Item: Record Item): Decimal
    var
        Item2: Record Item;
        ExcludePurch: Boolean;
        ExcludeSalesRet: Boolean;
        ExcludeOutput: Boolean;
    begin
        with Item2 do begin
            Copy(Item);

            SetRange("Date Filter", 0D, SalesHeader."Shipment Date");

            CalcFields(Inventory, "Qty. on Purch. Order", "Qty. on Sales Order",
                       "Scheduled Need (Qty.)", "Scheduled Receipt (Qty.)", "Qty. in Transit",
                       "Trans. Ord. Receipt (Qty.)", "Trans. Ord. Shipment (Qty.)", "Qty. on Service Order");

            // P8001083
            LotStatusMgmt.SetInboundExclusions(Item2, LotStatus.FieldNo("Available for Sale"),
              ExcludePurch, ExcludeSalesRet, ExcludeOutput);
            LotStatusMgmt.AdjustItemFlowFields(Item2, LotStatusExclusionFilter, true, true, 0,
              ExcludePurch, ExcludeSalesRet, ExcludeOutput);
            // P8001083

            exit(Inventory + "Qty. on Purch. Order" - "Qty. on Sales Order" -
                 "Scheduled Need (Qty.)" + "Scheduled Receipt (Qty.)" - "Trans. Ord. Shipment (Qty.)" +
                 "Qty. in Transit" + "Trans. Ord. Receipt (Qty.)" - "Qty. on Service Order");
        end;
    end;

    procedure GetFormLocationCode(var Item: Record Item): Code[10]
    begin
        exit(Item.GetRangeMin("Location Filter"));
    end;

    procedure ShowQtyOrdered(var Item: Record Item)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.Copy(SearchItemLedgEntry);
        ItemLedgEntry.SetRange("Item No.", Item."No.");
        // P8000878
        if StartingDate <> 0D then
            ItemLedgEntry.SetRange("Posting Date", StartingDate, EndingDate)
        else
            ItemLedgEntry.SetRange("Posting Date");
        // P8000878
        ItemLedgEntry.Init;
        PAGE.RunModal(0, ItemLedgEntry);
    end;

    procedure ShowCustomerCard(var Item: Record Item)
    var
        Customer2: Record Customer;
    begin
        Customer2.SetRange("No.", SellToCustomer."No."); // P8000384A
        Item.CopyFilter("Date Filter", Customer2."Date Filter");
        Item.CopyFilter("Global Dimension 1 Filter", Customer2."Global Dimension 1 Filter");
        Item.CopyFilter("Global Dimension 2 Filter", Customer2."Global Dimension 2 Filter");
        Customer2.FindFirst; // P8000949
        PAGE.RunModal(PAGE::"Customer Card", Customer2);
    end;

    procedure ShowCustomerLedgEntries()
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgEntry.SetRange("Customer No.", BillToCustomer."No."); // P8000384A
        PAGE.RunModal(0, CustLedgEntry);
    end;

    procedure ShowCustomerOrders()
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetCurrentKey("Document Type", "Sell-to Customer No."); // P8000384A
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Sell-to Customer No.", SellToCustomer."No."); // P8000384A
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter("Outstanding Quantity", '>0');
        PAGE.RunModal(0, SalesLine);
    end;

    procedure ShowCustItemLedgEntries()
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.Copy(SearchItemLedgEntry);
        ItemLedgEntry.SetRange("Item No.");
        ItemLedgEntry.SetRange("Posting Date");
        ItemLedgEntry.Init;
        PAGE.RunModal(0, ItemLedgEntry);
    end;

    procedure SetStartEndDates(HistoryPeriod: DateFormula; ShowItemsWithActivity: Boolean)
    begin
        // P8000878
        EndingDate := WorkDate;
        if ShowItemsWithActivity and (Format(HistoryPeriod) <> '') then
            StartingDate := CalcDate('-' + Format(HistoryPeriod), EndingDate)
        else
            StartingDate := 0D;

        HistoryItemListInit; // P8000999
    end;

    procedure ClearContracts(ItemNo: Code[20])
    begin
        // P8000885
        TempItemQty.SetCurrentKey("Item No.");
        TempItemQty.SetRange("Item No.", ItemNo);
        if TempItemQty.FindFirst then begin
            TempItemQty."Order No." := ''; // P8001132
            TempItemQty."Maint. Ledger Entry No." := 0;
            TempItemQty.Modify;
            SalesContractNo := '';
            PriceID := 0;
        end;
    end;

    procedure ValidateUnitPrice(var Item: Record Item; TempSalesLine: Record "Sales Line" temporary; QtyToOrder: Decimal; VariantToOrder: Code[10]; OrderUOM: Code[10]; DefOrderUOM: Code[10]; var UnitPrice: Decimal; var SalesContractNo: Code[20]; var SalesPrice: Record "Sales Price")
    var
        SalesPriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";
        InitialContractNo: Code[20];
        Txt001: Label 'Can not select the Sales Contract through GetPrice page ';
        ItemSalesPriceMgmt: Codeunit "Item Sales Price Management";
        lRecCustomer: Record Customer;
    begin
        // P80072447
        InitialContractNo := SalesContractNo;
        TempSalesLine.Init;
        TempSalesLine."Document Type" := SalesHeader."Document Type";
        TempSalesLine."Document No." := SalesHeader."No.";
        TempSalesLine."Line No." := 10000;
        TempSalesLine.Type := TempSalesLine.Type::Item;
        TempSalesLine."No." := Item."No.";
        ItemSalesPriceMgmt.SetCustItemPriceGroup(
          TempSalesLine."Customer Price Group", SalesHeader.PriceGroupCustomerNo, Item."Item Category Code");
        if TempSalesLine."Customer Price Group" = '' then begin
            lRecCustomer.Get(SalesHeader.PriceGroupCustomerNo);
            TempSalesLine."Customer Price Group" := lRecCustomer."Customer Price Group";
        end;
        TempSalesLine."Variant Code" := VariantToOrder;
        TempSalesLine."Contract No." := SalesContractNo;
        TempSalesLine."Price ID" := PriceID;
        TempSalesLine.SetDoNotUpdatePrice(true);
        TempSalesLine.Validate("Unit of Measure Code", OrderUOM);
        TempSalesLine.Validate(Quantity, QtyToOrder);
        TempSalesLine.Validate("Unit Price", UnitPrice);
        SalesPriceCalcMgt.GetSalesLinePriceForOrderGuide(SalesHeader, TempSalesLine, SalesPrice);
        if SalesPrice."Price ID" <> 0 then begin
            UnitPrice := SalesPrice."Unit Price";
            SalesContractNo := SalesPrice."Contract No.";
            if (InitialContractNo = '') and (SalesContractNo <> '') then
                Error(Txt001);
            PriceID := SalesPrice."Price ID";
        end;
    end;

    procedure CalcUnitPriceLCY(pUnitPrice: Decimal; var UnitPriceLCY: Decimal)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        Currency: Record Currency;
    begin
        // P80072449
        if SalesHeader."Currency Code" <> '' then begin
            Currency.Get(SalesHeader."Currency Code");
            if Currency."Unit-Amount Rounding Precision" <> 0 then
                UnitPriceLCY := Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY(SalesHeader."Posting Date",
                                      SalesHeader."Currency Code", pUnitPrice, SalesHeader."Currency Factor"), Currency."Unit-Amount Rounding Precision");
        end else
            UnitPriceLCY := pUnitPrice;
    end;
}

