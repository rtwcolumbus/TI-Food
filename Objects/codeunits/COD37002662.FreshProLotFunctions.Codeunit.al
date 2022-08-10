codeunit 37002662 "FreshPro Lot Functions"
{
    // PR4.00
    // P8000244A, Myers Nissi, Jack Reynolds, 03 OCT 05
    //   FreshPro utility lot functions
    //   Initially, functions to support the lot summary form and lot settlement report
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Changes to Value Entry keys
    // 
    // PR4.00.02
    // P8000319A, VerticalSoft, Jack Reynolds, 04 APR 06
    //   Fix problems with GetRepackSale
    // 
    // PR4.00.06
    // P8000496A, VerticalSoft, Jack Reynolds, 24 JUL 07
    //   Modify GetRepackSale to indicate if neg adjust is a result of consumption for a repack order


    trigger OnRun()
    begin
    end;

    procedure GetExtraCharges(ItemLedgerEntryNo: Integer; var TotalExtraCharges: Decimal; var ExtraChargeTemp: Record "Value Entry Extra Charge" temporary)
    var
        ValueEntryExtraCharge: Record "Value Entry Extra Charge";
    begin
        ValueEntryExtraCharge.SetCurrentKey("Item Ledger Entry No.");
        ValueEntryExtraCharge.SetRange("Item Ledger Entry No.", ItemLedgerEntryNo);
        if ValueEntryExtraCharge.Find('-') then
            repeat
                TotalExtraCharges += ValueEntryExtraCharge.Charge + ValueEntryExtraCharge."Expected Charge";
                ExtraChargeTemp := ValueEntryExtraCharge;
                ExtraChargeTemp.Insert;
            until ValueEntryExtraCharge.Next = 0;
    end;

    procedure GetItemCharges(ItemLedgerEntryNo: Integer; var TotalItemCharges: Decimal; var ItemChargeTemp: Record "Value Entry" temporary)
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetCurrentKey("Item Ledger Entry No.");
        ValueEntry.SetFilter("Item Charge No.", '<>%1', '');
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntryNo);
        if ValueEntry.Find('-') then
            repeat
                TotalItemCharges += ValueEntry."Cost Amount (Actual)" + ValueEntry."Cost Amount (Expected)";
                ItemChargeTemp := ValueEntry;
                ItemChargeTemp.Insert;
            until ValueEntry.Next = 0;
    end;

    procedure GetAccrualExpense(ItemLedgerEntryNo: Integer; CostingQty: Decimal; CostInAltQty: Boolean; var TotalAccrualExpense: Decimal; var AccrualLedgerTemp: Record "Accrual Ledger Entry" temporary)
    var
        ItemEntryRelation: Record "Item Entry Relation";
        ValueEntryRelation: Record "Value Entry Relation";
        ValueEntry: Record "Value Entry";
        AccrualLedger: Record "Accrual Ledger Entry";
        ShipmentLine: Record "Sales Shipment Line";
        RetReceiptLine: Record "Return Receipt Line";
        InvoiceLine: Record "Sales Invoice Line";
        CrMemoLine: Record "Sales Cr.Memo Line";
        RetShipmentLine: Record "Sales Cr.Memo Line";
        ItemTrackMgt: Codeunit "Item Tracking Management";
        DocLineQty: Decimal;
        AccrualAmt: Decimal;
        DocLineNo: Integer;
        DocArray: array[6] of Text[100];
    begin
        AccrualLedger.SetCurrentKey("Accrual Plan Type", "Source Document Type", "Plan Type", "Entry Type",
          "Source Document No.", "Source Document Line No.");
        AccrualLedger.SetRange("Accrual Plan Type", AccrualLedger."Accrual Plan Type"::Sales);
        AccrualLedger.SetRange("Entry Type", AccrualLedger."Entry Type"::Accrual);
        if ItemEntryRelation.Get(ItemLedgerEntryNo) then begin
            case ItemEntryRelation."Source Type" of
                DATABASE::"Sales Shipment Line":
                    begin
                        AccrualLedger.SetRange("Source Document Type", AccrualLedger."Source Document Type"::Shipment);
                        ShipmentLine.Get(ItemEntryRelation."Source ID", ItemEntryRelation."Source Ref. No.");
                        if CostInAltQty then
                            DocLineQty := ShipmentLine."Quantity (Alt.)"
                        else
                            DocLineQty := ShipmentLine."Quantity (Base)";
                    end;
                DATABASE::"Return Receipt Line":
                    begin
                        AccrualLedger.SetRange("Source Document Type", AccrualLedger."Source Document Type"::Receipt);
                        RetReceiptLine.Get(ItemEntryRelation."Source ID", ItemEntryRelation."Source Ref. No.");
                        if CostInAltQty then
                            DocLineQty := -RetReceiptLine."Quantity (Alt.)"
                        else
                            DocLineQty := -RetReceiptLine."Quantity (Base)";
                    end;
            end;
            AccrualLedger.SetRange("Source Document No.", ItemEntryRelation."Source ID");
            AccrualLedger.SetRange("Source Document Line No.", ItemEntryRelation."Source Ref. No.");
            if AccrualLedger.Find('-') then
                repeat
                    if not AccrualLedgerTemp.Get(AccrualLedger."Entry No.") then begin
                        AccrualLedgerTemp := AccrualLedger;
                        AccrualLedgerTemp.Amount := 0;
                        AccrualLedgerTemp.Insert;
                    end;
                    if DocLineQty <> 0 then begin
                        AccrualAmt := AccrualLedger.Amount * CostingQty / DocLineQty;
                        TotalAccrualExpense += AccrualAmt;
                        AccrualLedgerTemp.Amount -= AccrualAmt;
                        AccrualLedgerTemp.Modify;
                    end;
                until AccrualLedger.Next = 0;
        end;

        ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type"); // P8000267B
        ValueEntry.SetRange("Expected Cost", false);
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.SetRange(Adjustment, false);
        ValueEntry.SetFilter("Invoiced Quantity", '<>0');
        ValueEntry.SetRange("Item Charge No.", '');
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntryNo);
        if ValueEntry.Find('-') then
            repeat
                if ValueEntryRelation.Get(ValueEntry."Entry No.") then begin
                    Clear(DocArray);
                    ItemTrackMgt.DecomposeRowID(ValueEntryRelation."Source RowId", DocArray);
                    Evaluate(DocLineNo, DocArray[6]);
                    case DocArray[1] of
                        Format(DATABASE::"Sales Invoice Line"):
                            begin
                                AccrualLedger.SetRange("Source Document Type", AccrualLedger."Source Document Type"::Invoice);
                                InvoiceLine.Get(DocArray[3], DocLineNo);
                                if CostInAltQty then
                                    DocLineQty := InvoiceLine."Quantity (Alt.)"
                                else
                                    DocLineQty := InvoiceLine."Quantity (Base)";
                            end;
                        Format(DATABASE::"Sales Cr.Memo Line"):
                            begin
                                AccrualLedger.SetRange("Source Document Type", AccrualLedger."Source Document Type"::"Credit Memo");
                                CrMemoLine.Get(DocArray[3], DocLineNo);
                                if CostInAltQty then
                                    DocLineQty := -CrMemoLine."Quantity (Alt.)"
                                else
                                    DocLineQty := -CrMemoLine."Quantity (Base)";
                            end;
                    end;
                    AccrualLedger.SetRange("Source Document No.", DocArray[3]);
                    AccrualLedger.SetRange("Source Document Line No.", DocLineNo);
                    if AccrualLedger.Find('-') then
                        repeat
                            if not AccrualLedgerTemp.Get(AccrualLedger."Entry No.") then begin
                                AccrualLedgerTemp := AccrualLedger;
                                AccrualLedgerTemp.Amount := 0;
                                AccrualLedgerTemp.Insert;
                            end;
                            if DocLineQty <> 0 then begin
                                AccrualAmt := AccrualLedger.Amount * CostingQty / DocLineQty;
                                TotalAccrualExpense += AccrualAmt;

                                AccrualLedgerTemp.Amount -= AccrualAmt;
                                AccrualLedgerTemp.Modify;
                            end;
                        until AccrualLedger.Next = 0;
                end;
            until ValueEntry.Next = 0;
    end;

    procedure GetRepackSale(ItemLedger: Record "Item Ledger Entry"; var RepackEntry: Record "Item Ledger Entry"): Code[10]
    var
        ItemLedger2: Record "Item Ledger Entry";
        ItemApplication: Record "Item Application Entry";
    begin
        // P8001134
        if ItemLedger."Order Type" <> ItemLedger."Order Type"::FOODSalesRepack then
            exit;

        ItemLedger2.SetRange("Order Type", ItemLedger2."Order Type"::FOODSalesRepack);
        ItemLedger2.SetRange("Order No.", ItemLedger."Order No.");
        ItemLedger2.SetRange("Order Line No.", ItemLedger."Order Line No.");
        ItemLedger2.SetRange("Entry Type", ItemLedger2."Entry Type"::"Positive Adjmt.");
        ItemLedger2.FindFirst;

        ItemApplication.SetRange("Inbound Item Entry No.", ItemLedger2."Entry No.");
        ItemApplication.SetFilter("Outbound Item Entry No.", '<>0');
        if ItemApplication.Find('-') then
            RepackEntry.Get(ItemApplication."Outbound Item Entry No.");
    end;
}

