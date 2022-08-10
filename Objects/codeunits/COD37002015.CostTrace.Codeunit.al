codeunit 37002015 "Cost Trace"
{
    // PR4.00.04
    // P8000370A, VerticalSoft, Jack Reynolds, 08 SEP 06
    //   Populates Cost Trace temp table and displays cost trace form
    // 
    // PRW17.00
    // P8001134, Columbus IT, Don Bresee, 21 FEB 13
    //   Add logic for handling of new "Order Type" options
    // 
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013

    TableNo = "Item Ledger Entry";

    trigger OnRun()
    begin
        FindAllPredecessors("Entry No.", CostTrace);

        CostTrace.SetCurrentKey("Parent Entry No.");
        CostTrace.SetRange("Parent Entry No.", 0);
        SetSequence(CostTrace);

        CostTrace.Reset;
        CostTrace.SetCurrentKey("Sequence No.");

        PAGE.RunModal(0, CostTrace);
    end;

    var
        CostTrace: Record "Cost Trace" temporary;
        NextSeqNo: Integer;

    procedure FindAllPredecessors(EntryNo: Integer; var CostTrace: Record "Cost Trace" temporary)
    var
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemApplicationEntry: Record "Item Application Entry";
        CostTrace2: Record "Cost Trace" temporary;
        CostEntryNo: Integer;
        Parent: Integer;
        Level: Integer;
        ParentContrib: Decimal;
    begin
        ItemLedgerEntry.Get(EntryNo);
        ItemLedgerEntry.CalcFields("Cost Amount (Actual)", "Cost Amount (Expected)");
        SetCostTraceILE(ItemLedgerEntry, ItemApplicationEntry, CostTrace);
        CostTrace.Displayed := true;
        CostTrace.Contribution := 1;
        CostTrace.Insert;
        CostEntryNo := 1;
        repeat
            if CostTrace."Entry Type" in [CostTrace."Entry Type"::Purchase .. CostTrace."Entry Type"::Output] then begin
                CostTrace2.Reset;
                CostTrace2.DeleteAll;
                FindPredecessors(CostTrace."Ledger Entry No.", CostTrace2);
                if CostTrace2.Find('-') then begin
                    CostTrace."Has Children" := true;
                    CostTrace.Modify;
                    Parent := CostTrace."Entry No.";
                    ParentContrib := CostTrace.Contribution;
                    Level := CostTrace.Level + 1;
                    repeat
                        CostTrace := CostTrace2;
                        CostEntryNo += 1;
                        CostTrace."Entry No." := CostEntryNo;
                        CostTrace.Level := Level;
                        CostTrace."Parent Entry No." := Parent;
                        CostTrace.Contribution := ParentContrib * CostTrace.Contribution;
                        CostTrace."Cost Contribution" := (CostTrace.Cost - CostTrace."Allocated to By-Products") * CostTrace.Contribution;
                        CostTrace.Insert;
                    until CostTrace2.Next = 0;
                    CostTrace.Get(Parent);
                end;
            end;
        until CostTrace.Next = 0;
    end;

    procedure FindPredecessors(EntryNo: Integer; var CostTrace: Record "Cost Trace" temporary)
    var
        Item: Record Item;
        Resource: Record Resource;
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemLedgerEntry2: Record "Item Ledger Entry";
        ItemApplicationEntry: Record "Item Application Entry";
        ResourceLedgerEntry: Record "Res. Ledger Entry";
        CapacityLedgerEntry: Record "Capacity Ledger Entry";
        ProdOrderLine: Record "Prod. Order Line";
        OutputQuantity: Decimal;
        OutputTotal: Decimal;
        OutputFactor: Decimal;
        P800ProdOrderMgt: Codeunit "Process 800 Prod. Order Mgt.";
        CoProdCostMgt: Codeunit "Co-Product Cost Management";
        TotalCoProductUnits: Decimal;
        CostShare: Decimal;
        TotalCost: Decimal;
        TotalByProductCost: Decimal;
    begin
        ItemLedgerEntry.Get(EntryNo);
        if ItemLedgerEntry.Positive then begin
            // Look for fixed application
            ItemApplicationEntry.SetCurrentKey("Inbound Item Entry No.", "Outbound Item Entry No.", "Cost Application");
            ItemApplicationEntry.SetRange("Inbound Item Entry No.", EntryNo);
            ItemApplicationEntry.SetFilter("Outbound Item Entry No.", '<>0');
            ItemApplicationEntry.SetRange("Transferred-from Entry No.", 0);
            ItemApplicationEntry.SetRange("Cost Application", true);
            if ItemApplicationEntry.Find('-') then
                repeat
                    if ItemApplicationEntry."Item Ledger Entry No." <> ItemApplicationEntry."Outbound Item Entry No." then begin
                        ItemLedgerEntry.Get(ItemApplicationEntry."Outbound Item Entry No.");
                        SetCostTraceILE(ItemLedgerEntry, ItemApplicationEntry, CostTrace);
                        CostTrace.Type := CostTrace.Type::"Fixed Application";
                        if CostTrace.Quantity <> 0 then
                            CostTrace.Insert;
                    end;
                until ItemApplicationEntry.Next = 0;

            // Look for transfer
            ItemApplicationEntry.SetCurrentKey("Inbound Item Entry No.", "Outbound Item Entry No.", "Cost Application");
            ItemApplicationEntry.SetRange("Inbound Item Entry No.", EntryNo);
            ItemApplicationEntry.SetFilter("Outbound Item Entry No.", '<>0');
            ItemApplicationEntry.SetFilter("Transferred-from Entry No.", '<>0');
            ItemApplicationEntry.SetRange("Cost Application", true);
            if ItemApplicationEntry.Find('-') then
                repeat
                    if ItemApplicationEntry."Item Ledger Entry No." <> ItemApplicationEntry."Outbound Item Entry No." then begin
                        ItemLedgerEntry.Get(ItemApplicationEntry."Transferred-from Entry No.");
                        SetCostTraceILE(ItemLedgerEntry, ItemApplicationEntry, CostTrace);
                        CostTrace.Type := CostTrace.Type::Transfer;
                        if CostTrace.Quantity <> 0 then
                            CostTrace.Insert;
                    end;
                until ItemApplicationEntry.Next = 0;

            // P8001134
            with ItemLedgerEntry do begin
                Get(EntryNo);
                if (("Order Type" = "Order Type"::Assembly) and ("Entry Type" = "Entry Type"::"Assembly Output")) or
                   (IsBOMOrderType() and ("Entry Type" = "Entry Type"::"Positive Adjmt."))
                then begin
                    ItemLedgerEntry2.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type");
                    ItemLedgerEntry2.SetRange("Order Type", "Order Type");
                    ItemLedgerEntry2.SetRange("Order No.", "Order No.");
                    if ("Order Type" in ["Order Type"::FOODLotCombination, "Order Type"::FOODSalesRepack]) then
                        ItemLedgerEntry2.SetRange("Order Line No.", "Order Line No.");
                    if ("Order Type" = "Order Type"::Assembly) then
                        ItemLedgerEntry2.SetRange("Entry Type", "Entry Type"::"Assembly Consumption")
                    else
                        ItemLedgerEntry2.SetRange("Entry Type", "Entry Type"::"Negative Adjmt.");
                    if ItemLedgerEntry2.FindSet then
                        repeat
                            Clear(ItemApplicationEntry);
                            ItemApplicationEntry.Quantity := ItemLedgerEntry2.Quantity;
                            ItemApplicationEntry."Quantity (Alt.)" := ItemLedgerEntry2."Quantity (Alt.)";
                            SetCostTraceILE(ItemLedgerEntry2, ItemApplicationEntry, CostTrace);
                            CostTrace.Type := CostTrace.Type::"Assembly/Repack/Reclass.";
                            if CostTrace.Quantity <> 0 then
                                CostTrace.Insert;
                        until ItemLedgerEntry2.Next = 0;
                    ResourceLedgerEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.");
                    ResourceLedgerEntry.SetRange("Order Type", "Order Type");
                    ResourceLedgerEntry.SetRange("Order No.", "Order No.");
                    if ResourceLedgerEntry.FindSet then
                        repeat
                            SetCostTraceRLE(ResourceLedgerEntry, CostTrace);
                            CostTrace.Type := CostTrace.Type::"Assembly/Repack/Reclass.";
                            if CostTrace.Quantity <> 0 then
                                CostTrace.Insert;
                        until ResourceLedgerEntry.Next = 0;
                end;
            end;
            // P8001134

            // Look for Production Order
            if ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Output then begin
                OutputQuantity := ItemLedgerEntry.GetCostingQty;
                ItemLedgerEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type", "Prod. Order Comp. Line No."); // P8001132
                ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production); // P8001132
                ItemLedgerEntry.SetRange("Order No.", ItemLedgerEntry."Order No.");               // P8001132
                ItemLedgerEntry.SetRange("Order Line No.", ItemLedgerEntry."Order Line No.");     // P8001132
                ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Output);
                ItemLedgerEntry.CalcSums(Quantity, "Quantity (Alt.)");
                OutputTotal := ItemLedgerEntry.GetCostingQty;
                if OutputTotal <> 0 then
                    OutputFactor := OutputQuantity / OutputTotal;
                ProdOrderLine.SetRange("Prod. Order No.", ItemLedgerEntry."Order No."); // P8001132
                ProdOrderLine.SetRange("Line No.", ItemLedgerEntry."Order Line No.");   // P8001132
                ProdOrderLine.Find('-');
                if P800ProdOrderMgt.IsProdFamilyProcess(ProdOrderLine) then begin
                    TotalByProductCost := -GetByProductCost(ProdOrderLine);
                    if not ProdOrderLine."By-Product" then
                        CoProdCostMgt.BuildProdCommonUOMQtys(ProdOrderLine, TotalCoProductUnits, true);
                end;
                ItemLedgerEntry2.SetCurrentKey("Order Type", "Order No.", "Order Line No.", "Entry Type", "Prod. Order Comp. Line No."); // P8001132
                ItemLedgerEntry2.SetRange("Order Type", ItemLedgerEntry2."Order Type"::Production);       // P8001132
                ItemLedgerEntry2.SetRange("Order No.", ItemLedgerEntry."Order No.");                      // P8001132
                ItemLedgerEntry2.SetFilter("Order Line No.", '%1|%2', 0, ItemLedgerEntry."Order Line No."); // P8001132
                ItemLedgerEntry2.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Consumption);
                if ItemLedgerEntry2.Find('-') then
                    repeat
                        ItemApplicationEntry.Quantity := ItemLedgerEntry2.Quantity;
                        ItemApplicationEntry."Quantity (Alt.)" := ItemLedgerEntry2."Quantity (Alt.)";
                        SetCostTraceILE(ItemLedgerEntry2, ItemApplicationEntry, CostTrace);
                        CostTrace.Type := CostTrace.Type::"Production Order";
                        CostTrace."Total Output (Base)" := ItemLedgerEntry.Quantity;
                        CostTrace."Total Output (Alt.)" := ItemLedgerEntry."Quantity (Alt.)";
                        CostTrace."Total Output" := OutputTotal;
                        TotalCost += CostTrace.Cost;
                        if CostTrace.Quantity <> 0 then
                            CostTrace.Insert;
                    until ItemLedgerEntry2.Next = 0;
                if CostTrace.Find('-') then
                    repeat
                        if P800ProdOrderMgt.IsProdFamilyProcess(ProdOrderLine) then begin
                            CostTrace."Co-Product Units" := CoProdCostMgt.GetCoProductUnits(ProdOrderLine);
                            CostTrace."Total Co-Product Units" := TotalCoProductUnits;
                            CostTrace."Allocated to By-Products" := TotalByProductCost * CostTrace.Cost / TotalCost;
                            if ProdOrderLine."By-Product" then begin
                                if CostTrace.Cost <> 0 then
                                    CostTrace.Contribution := CostTrace.Contribution * CostTrace."Allocated to By-Products" / CostTrace.Cost
                                else
                                    CostTrace.Contribution := 0;
                            end else begin
                                CostShare := (CostTrace.Cost - CostTrace."Allocated to By-Products") *
                                  CostTrace."Co-Product Units" / TotalCoProductUnits;
                                CostTrace.Contribution :=
                                  CostTrace.Contribution * CostShare / (CostTrace.Cost - CostTrace."Allocated to By-Products");
                            end;
                        end;
                        CostTrace.Contribution := OutputFactor * CostTrace.Contribution;
                        CostTrace.Modify;
                    until CostTrace.Next = 0;
                CapacityLedgerEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.");            // P8001132
                CapacityLedgerEntry.SetRange("Order Type", CapacityLedgerEntry."Order Type"::Production); // P8001132
                CapacityLedgerEntry.SetRange("Order No.", ItemLedgerEntry."Order No.");                   // P8001132
                CapacityLedgerEntry.SetRange("Order Line No.", ItemLedgerEntry."Order Line No.");         // P8001132
                if CapacityLedgerEntry.Find('-') then
                    repeat
                        SetCostTraceCLE(CapacityLedgerEntry, CostTrace);
                        CostTrace.Type := CostTrace.Type::"Production Order";
                        CostTrace."Total Output (Base)" := ItemLedgerEntry.Quantity;
                        CostTrace."Total Output (Alt.)" := ItemLedgerEntry."Quantity (Alt.)";
                        CostTrace."Total Output" := OutputTotal;
                        CostTrace.Contribution := OutputFactor * CostTrace.Contribution;
                        if CostTrace.Quantity <> 0 then
                            CostTrace.Insert;
                    until CapacityLedgerEntry.Next = 0;
            end;

        end else begin
            ItemApplicationEntry.SetCurrentKey("Outbound Item Entry No.");
            ItemApplicationEntry.SetRange("Outbound Item Entry No.", EntryNo);
            ItemApplicationEntry.SetRange("Item Ledger Entry No.", EntryNo);
            ItemApplicationEntry.SetRange("Cost Application", true);
            if ItemApplicationEntry.Find('-') then
                repeat
                    ItemLedgerEntry.Get(ItemApplicationEntry."Inbound Item Entry No.");
                    SetCostTraceILE(ItemLedgerEntry, ItemApplicationEntry, CostTrace);
                    CostTrace.Type := CostTrace.Type::"Standard Application";
                    if CostTrace.Quantity <> 0 then
                        CostTrace.Insert;
                until ItemApplicationEntry.Next = 0;
        end;
    end;

    procedure SetCostTraceILE(ItemLedgerEntry: Record "Item Ledger Entry"; ItemApplicationEntry: Record "Item Application Entry"; var CostTrace: Record "Cost Trace")
    var
        Item: Record Item;
        ValueEntry: Record "Value Entry";
        ProdOrderLine: Record "Prod. Order Line";
        P800ProdOrderMgt: Codeunit "Process 800 Prod. Order Mgt.";
    begin
        Item.Get(ItemLedgerEntry."Item No.");

        ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");

        CostTrace.Init;
        CostTrace."Entry No." += 1;
        CostTrace."Ledger Entry No." := ItemLedgerEntry."Entry No.";
        CostTrace."Entry Type" := ItemLedgerEntry."Entry Type";
        CostTrace."Posting Date" := ItemLedgerEntry."Posting Date";
        CostTrace."Document No." := ItemLedgerEntry."Document No.";
        CostTrace."Quantity (Base)" := ItemLedgerEntry.Quantity;
        CostTrace."Quantity (Alt.)" := ItemLedgerEntry."Quantity (Alt.)";
        CostTrace."Applied Quantity (Base)" := ItemApplicationEntry.Quantity;
        CostTrace."Applied Quantity (Alt.)" := ItemApplicationEntry."Quantity (Alt.)";
        ValueEntry.SetFilter("Entry Type", '=%1', ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.CalcSums("Cost Amount (Actual)", "Cost Amount (Expected)");
        CostTrace."Direct Cost (Actual)" := ValueEntry."Cost Amount (Actual)";
        CostTrace."Direct Cost (Expected)" := ValueEntry."Cost Amount (Expected)";
        CostTrace."Direct Cost" := CostTrace."Direct Cost (Actual)" + CostTrace."Direct Cost (Expected)";
        ValueEntry.SetFilter("Entry Type", '<>%1', ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.CalcSums("Cost Amount (Actual)", "Cost Amount (Expected)");
        CostTrace."Other Cost (Actual)" := ValueEntry."Cost Amount (Actual)";
        CostTrace."Other Cost (Expected)" := ValueEntry."Cost Amount (Expected)";
        CostTrace."Other Cost" := CostTrace."Other Cost (Actual)" + CostTrace."Other Cost (Expected)";
        CostTrace."Cost (Actual)" := CostTrace."Direct Cost (Actual)" + CostTrace."Other Cost (Actual)";
        CostTrace."Cost (Expected)" := CostTrace."Direct Cost (Expected)" + CostTrace."Other Cost (Expected)";
        CostTrace.Cost := CostTrace."Direct Cost" + CostTrace."Other Cost";
        CostTrace."Source No." := ItemLedgerEntry."Item No.";
        CostTrace."Cost by Alternate" := Item.CostInAlternateUnits;
        if CostTrace."Cost by Alternate" then begin
            CostTrace.Quantity := CostTrace."Quantity (Alt.)";
            CostTrace."Applied Quantity" := CostTrace."Applied Quantity (Alt.)";
            CostTrace."Unit of Measure Code" := Item."Alternate Unit of Measure";
        end else begin
            CostTrace.Quantity := CostTrace."Quantity (Base)";
            CostTrace."Applied Quantity" := CostTrace."Applied Quantity (Base)";
            CostTrace."Unit of Measure Code" := Item."Base Unit of Measure";
        end;
        if CostTrace.Quantity <> 0 then
            CostTrace.Contribution := CostTrace."Applied Quantity" / CostTrace.Quantity;
        CostTrace."Shared Component" := (ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Consumption) and
          (ItemLedgerEntry."Order Line No." = 0); // P8001132
        if ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Output then begin
            ProdOrderLine.SetRange("Prod. Order No.", ItemLedgerEntry."Order No."); // P8001132
            ProdOrderLine.SetRange("Line No.", ItemLedgerEntry."Order Line No.");   // P8001132
            ProdOrderLine.Find('-');
            if P800ProdOrderMgt.IsProdFamilyProcess(ProdOrderLine) then begin
                if ProdOrderLine."By-Product" then
                    CostTrace."Output Type" := CostTrace."Output Type"::"By-Product"
                else
                    CostTrace."Output Type" := CostTrace."Output Type"::"Co-Product";
            end else
                CostTrace."Output Type" := CostTrace."Output Type"::Regular;
        end;
        if not ItemLedgerEntry.Positive then
            CostTrace.Contribution := -CostTrace.Contribution;
    end;

    procedure SetCostTraceRLE(ResourceLedgerEntry: Record "Res. Ledger Entry"; var CostTrace: Record "Cost Trace")
    var
        Resource: Record Resource;
    begin
        Resource.Get(ResourceLedgerEntry."Resource No.");

        CostTrace.Init;
        CostTrace."Entry No." += 1;
        CostTrace."Ledger Entry No." := ResourceLedgerEntry."Entry No.";
        CostTrace."Entry Type" := CostTrace."Entry Type"::Resource;
        CostTrace."Posting Date" := ResourceLedgerEntry."Posting Date";
        CostTrace."Document No." := ResourceLedgerEntry."Document No.";
        CostTrace."Quantity (Base)" := -ResourceLedgerEntry.Quantity;
        CostTrace."Applied Quantity (Base)" := -ResourceLedgerEntry.Quantity;
        CostTrace."Direct Cost (Actual)" := -ResourceLedgerEntry."Total Cost";
        CostTrace."Direct Cost" := CostTrace."Direct Cost (Actual)";
        CostTrace."Cost (Actual)" := CostTrace."Direct Cost (Actual)";
        CostTrace.Cost := CostTrace."Direct Cost";
        CostTrace."Source No." := ResourceLedgerEntry."Resource No.";
        CostTrace.Quantity := CostTrace."Quantity (Base)";
        CostTrace."Applied Quantity" := CostTrace."Applied Quantity (Base)";
        CostTrace."Unit of Measure Code" := Resource."Base Unit of Measure";
        CostTrace.Contribution := -1;
    end;

    procedure SetCostTraceCLE(CapacityLedgerEntry: Record "Capacity Ledger Entry"; var CostTrace: Record "Cost Trace")
    var
        WorkCenter: Record "Work Center";
        ValueEntry: Record "Value Entry";
    begin
        if WorkCenter.Get(CapacityLedgerEntry."Work Center No.") then;

        ValueEntry.SetCurrentKey("Capacity Ledger Entry No.", "Entry Type");
        ValueEntry.SetRange("Capacity Ledger Entry No.", CapacityLedgerEntry."Entry No.");

        CostTrace.Init;
        CostTrace."Entry No." += 1;
        CostTrace."Ledger Entry No." := CapacityLedgerEntry."Entry No.";
        CostTrace."Entry Type" := CostTrace."Entry Type"::"Work Center" + CapacityLedgerEntry.Type;
        CostTrace."Posting Date" := CapacityLedgerEntry."Posting Date";
        CostTrace."Document No." := CapacityLedgerEntry."Document No.";
        CostTrace."Quantity (Base)" := -CapacityLedgerEntry.Quantity;
        CostTrace."Applied Quantity (Base)" := -CapacityLedgerEntry.Quantity;
        ValueEntry.SetFilter("Entry Type", '=%1', ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.CalcSums("Cost Amount (Actual)");
        CostTrace."Direct Cost (Actual)" := -ValueEntry."Cost Amount (Actual)";
        CostTrace."Direct Cost" := CostTrace."Direct Cost (Actual)";
        ValueEntry.SetFilter("Entry Type", '<>%1', ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.CalcSums("Cost Amount (Actual)");
        CostTrace."Other Cost (Actual)" := -ValueEntry."Cost Amount (Actual)";
        CostTrace."Other Cost" := CostTrace."Other Cost (Actual)";
        CostTrace."Cost (Actual)" := CostTrace."Direct Cost (Actual)" + CostTrace."Other Cost (Actual)";
        CostTrace.Cost := CostTrace."Cost (Actual)";
        CostTrace."Source No." := CapacityLedgerEntry."No.";
        CostTrace.Quantity := CostTrace."Quantity (Base)";
        CostTrace."Applied Quantity" := CostTrace."Applied Quantity (Base)";
        CostTrace."Unit of Measure Code" := WorkCenter."Unit of Measure Code";
        CostTrace.Contribution := -1;
    end;

    procedure GetByProductCost(ProdOrderLine: Record "Prod. Order Line"): Decimal
    var
        CoProdCostMgt: Codeunit "Co-Product Cost Management";
        ActByProductCost: Decimal;
        ActByProductCostACY: Decimal;
    begin
        if ProdOrderLine.Status = ProdOrderLine.Status::Released then
            exit(CoProdCostMgt.CalcProdByProductExpCost(ProdOrderLine))
        else begin
            CoProdCostMgt.CalcProdByProductActCost(ProdOrderLine, ActByProductCost, ActByProductCostACY);
            exit(ActByProductCost);
        end;
    end;

    procedure SetSequence(var CostTrace: Record "Cost Trace" temporary)
    var
        CostTrace2: Record "Cost Trace";
        EntryNo: Integer;
    begin
        NextSeqNo += 1;
        CostTrace."Sequence No." := NextSeqNo;
        CostTrace.Modify;
        if CostTrace.Find('-') then begin
            repeat
                CostTrace2.Copy(CostTrace);
                CostTrace.SetRange("Parent Entry No.", CostTrace2."Entry No.");
                SetSequence(CostTrace);
                CostTrace.Copy(CostTrace2);
            until CostTrace.Next = 0;
        end;
    end;
}

