report 37002024 "Convert Lot Controlled Items"
{
    // Process only report to turn lot control on for items that have not been lot controlled.  This is accomplished by
    // assigning a single lot number to all transactions for that item.
    // 
    // Does not handle - warehouse related tables, service order related tables
    // 
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Add code to update Fill Lot No. on container ledger
    // 
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   When creating lots set item category code
    // 
    // PR4.00.01
    // P8000267B, VerticalSoft, Jack Reynolds, 12 DEC 05
    //   Changes to Value Entry keys
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Jack Reynolds, 31 JUL 07
    //   Key change on value entry table
    // 
    // PRW16.00.03
    // P8000792, VerticalSoft, Rick Tweedle, 17 MAR 10
    //   Converted using TIF Editor
    // 
    // PRW17.10
    // P8001216, Columbus IT, Jack Reynolds, 26 SEP 13
    //   Remove support for Key Groups
    // 
    // PRW19.00.01
    // P8007512, To-Increase, Dayakar Battini, 26 JUL 16
    //   Include Warehouse entries.
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW110.0.02
    // P80050840, To-Increase, Dayakar Battini, 21 DEC 17
    //   added Warehouse entry modify permission
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Convert Lot Controlled Items';
    Permissions = TableData "Item Ledger Entry" = m,
                  TableData "Sales Shipment Line" = m,
                  TableData "Purch. Rcpt. Line" = m,
                  TableData "Phys. Inventory Ledger Entry" = m,
                  TableData "Transfer Shipment Line" = m,
                  TableData "Transfer Receipt Line" = m,
                  TableData "Lot No. Information" = i,
                  TableData "Item Entry Relation" = i,
                  TableData "Value Entry Relation" = i,
                  TableData "Return Shipment Line" = m,
                  TableData "Return Receipt Line" = m,
                  TableData "Warehouse Entry" = m,
                  TableData "Alternate Quantity Entry" = m,
                  TableData "Container Line" = m,
                  TableData "Shipped Container Line" = m;
    ProcessingOnly = true;
    UseRequestPage = false;

    dataset
    {
        dataitem("Lot Control Item"; "Lot Control Item")
        {

            trigger OnAfterGetRecord()
            var
                ItemVariant: Record "Item Variant";
                WhseEntry2: Record "Warehouse Entry";
            begin
                Window.Update(1, "Item No.");

                Message := '';
                ReleaseDate := DMY2Date(31, 12, 9999); // P8007748

                Item.Get("Item No.");
                if Item."Item Tracking Code" <> '' then begin
                    UpdateMessage(Text004);
                    Modify;
                    CurrReport.Skip;
                end;

                TempVariant.Reset;
                TempVariant.DeleteAll;
                TempVariant.Code := '';
                TempVariant.Insert;
                ItemVariant.SetRange("Item No.", "Item No.");
                ItemVariant.SetFilter(Code, '<>%1', '');
                if ItemVariant.Find('-') then
                    repeat
                        TempVariant.Code := ItemVariant.Code;
                        TempVariant.Insert;
                    until ItemVariant.Next = 0;

                if ("Item Tracking Code" = '') or
                  (("Lot Nos." = '') and ("Original Lot No." = ''))
                then
                    UpdateMessage(Text005)
                else
                    if not AssignLotNo("Item No.") then
                        UpdateMessage(Text006);

                if not CheckBalance("Item No.") then
                    UpdateMessage(Text007);

                if not CheckSalesLines("Item No.") then
                    UpdateMessage(Text008);

                if not CheckPurchLines("Item No.") then
                    UpdateMessage(Text009);

                if not CheckTransLines("Item No.") then
                    UpdateMessage(Text010);

                if not CheckAssignedContainers("Item No.") then // P8001324
                    UpdateMessage(Text011);

                if Message <> '' then begin
                    Modify;
                    CurrReport.Skip;
                end;

                Window.Update(2, ItemLedger.TableCaption);
                Window.Update(3, '');
                ItemLedger.SetCurrentKey("Item No.");
                ItemLedger.SetRange("Item No.", "Item No.");
                if ItemLedger.Find('-') then
                    repeat
                        Window.Update(3, ItemLedger."Entry No.");
                        ItemLedger."Lot No." := GetLotNo(ItemLedger."Variant Code");
                        ItemLedger.Modify;
                        UpdateAltQtyEntry(DATABASE::"Item Ledger Entry", '', ItemLedger."Entry No.", ItemLedger."Lot No.");
                        if ItemLedger."Posting Date" < ReleaseDate then
                            ReleaseDate := ItemLedger."Posting Date";
                    until ItemLedger.Next = 0;

                // P8000140A Begin
                Window.Update(2, ContainerLedger.TableCaption);
                Window.Update(3, '');
                if ContainerLedger.SetCurrentKey("Fill Item No.") then; // P8002013R2
                ContainerLedger.SetRange("Fill Item No.", "Item No.");
                if ContainerLedger.Find('-') then
                    repeat
                        Window.Update(3, ContainerLedger."Entry No.");
                        ContainerLedger."Fill Lot No." := GetLotNo(ContainerLedger."Fill Variant Code");
                        ContainerLedger.Modify;
                    until ContainerLedger.Next = 0;
                // P8000140A End

                Window.Update(2, PhysInvLedger.TableCaption);
                Window.Update(3, '');
                PhysInvLedger.SetCurrentKey("Item No.");
                PhysInvLedger.SetRange("Item No.", "Item No.");
                if PhysInvLedger.Find('-') then
                    repeat
                        Window.Update(3, PhysInvLedger."Entry No.");
                        PhysInvLedger."Lot No." := GetLotNo(PhysInvLedger."Variant Code");
                        PhysInvLedger.Modify;
                        UpdateAltQtyEntry(DATABASE::"Phys. Inventory Ledger Entry", '', PhysInvLedger."Entry No.", PhysInvLedger."Lot No.");
                    until PhysInvLedger.Next = 0;

                // P8007512
                Window.Update(2, WhseEntry.TableCaption);
                Window.Update(3, '');
                WhseEntry.Reset;
                WhseEntry.SetCurrentKey("Item No.");
                WhseEntry.SetRange("Item No.", "Item No.");
                if WhseEntry.Find('-') then
                    repeat
                        WhseEntry2.Get(WhseEntry."Entry No.");
                        Window.Update(3, WhseEntry2."Entry No.");
                        WhseEntry2."Lot No." := GetLotNo(WhseEntry2."Variant Code");
                        WhseEntry2.Modify;
                    until WhseEntry.Next = 0;
                // P8007512

                Window.Update(2, SalesShipmentLine.TableCaption);
                Window.Update(3, '');
                if SalesShipmentLine.SetCurrentKey(Type, "No.") then;
                SalesShipmentLine.SetRange(Type, SalesShipmentLine.Type::Item);
                SalesShipmentLine.SetRange("No.", "Item No.");
                SalesShipmentLine.SetFilter("Item Shpt. Entry No.", '<>0');
                if SalesShipmentLine.Find('-') then
                    repeat
                        Window.Update(3, SalesShipmentLine."Document No.");
                        InsertItemEntryRelation(SalesShipmentLine."Item Shpt. Entry No.",
                          DATABASE::"Sales Shipment Line", 0, SalesShipmentLine."Document No.",
                          '', 0, SalesShipmentLine."Line No.", GetLotNo(SalesShipmentLine."Variant Code"),
                          SalesShipmentLine."Order No.", SalesShipmentLine."Order Line No.");
                        SalesShipmentLine."Item Shpt. Entry No." := 0;
                        SalesShipmentLine.Modify;
                        UpdateAltQtyEntry(DATABASE::"Sales Shipment Line", SalesShipmentLine."Document No.", SalesShipmentLine."Line No.",
                          GetLotNo(SalesShipmentLine."Variant Code"));
                    until SalesShipmentLine.Next = 0;

                Window.Update(2, SalesInvoiceLine.TableCaption);
                Window.Update(3, '');
                if SalesInvoiceLine.SetCurrentKey(Type, "No.") then;
                SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
                SalesInvoiceLine.SetRange("No.", "Item No.");
                SalesInvoiceLine.SetFilter(Quantity, '<>0');
                if SalesInvoiceLine.Find('-') then
                    repeat
                        Window.Update(3, SalesInvoiceLine."Document No.");
                        GetValueEntryForSalesInvoice(SalesInvoiceLine, TempValueEntry);
                        if TempValueEntry.Find('-') then
                            repeat
                                InsertValueEntryRelation(TempValueEntry."Entry No.", SalesInvoiceLine.RowID1);
                            until TempValueEntry.Next = 0;
                        UpdateAltQtyEntry(DATABASE::"Sales Invoice Line", SalesInvoiceLine."Document No.", SalesInvoiceLine."Line No.",
                          GetLotNo(SalesInvoiceLine."Variant Code"));
                    until SalesInvoiceLine.Next = 0;

                Window.Update(2, SalesReturnLine.TableCaption);
                Window.Update(3, '');
                if SalesReturnLine.SetCurrentKey(Type, "No.") then;
                SalesReturnLine.SetRange(Type, SalesReturnLine.Type::Item);
                SalesReturnLine.SetRange("No.", "Item No.");
                SalesReturnLine.SetFilter("Item Rcpt. Entry No.", '<>0');
                if SalesReturnLine.Find('-') then
                    repeat
                        Window.Update(3, SalesReturnLine."Document No.");
                        InsertItemEntryRelation(SalesReturnLine."Item Rcpt. Entry No.",
                          DATABASE::"Return Receipt Line", 0, SalesReturnLine."Document No.",
                          '', 0, SalesReturnLine."Line No.", GetLotNo(SalesReturnLine."Variant Code"),
                          SalesReturnLine."Return Order No.", SalesReturnLine."Return Order Line No.");
                        SalesReturnLine."Item Rcpt. Entry No." := 0;
                        SalesReturnLine.Modify;
                        UpdateAltQtyEntry(DATABASE::"Return Receipt Line", SalesReturnLine."Document No.", SalesReturnLine."Line No.",
                          GetLotNo(SalesReturnLine."Variant Code"));
                    until SalesShipmentLine.Next = 0;

                Window.Update(2, SalesCrMemoLine.TableCaption);
                Window.Update(3, '');
                if SalesCrMemoLine.SetCurrentKey(Type, "No.") then;
                SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
                SalesCrMemoLine.SetRange("No.", "Item No.");
                SalesCrMemoLine.SetFilter(Quantity, '<>0');
                if SalesCrMemoLine.Find('-') then
                    repeat
                        Window.Update(3, SalesCrMemoLine."Document No.");
                        GetValueEntryForSalesCrMemo(SalesCrMemoLine, TempValueEntry);
                        if TempValueEntry.Find('-') then
                            repeat
                                InsertValueEntryRelation(TempValueEntry."Entry No.", SalesCrMemoLine.RowID1);
                            until TempValueEntry.Next = 0;
                        UpdateAltQtyEntry(DATABASE::"Sales Cr.Memo Line", SalesCrMemoLine."Document No.", SalesCrMemoLine."Line No.",
                          GetLotNo(SalesCrMemoLine."Variant Code"));
                    until SalesCrMemoLine.Next = 0;

                Window.Update(2, PurchReceiptLine.TableCaption);
                Window.Update(3, '');
                if PurchReceiptLine.SetCurrentKey(Type, "No.") then;
                PurchReceiptLine.SetRange(Type, PurchReceiptLine.Type::Item);
                PurchReceiptLine.SetRange("No.", "Item No.");
                PurchReceiptLine.SetFilter("Item Rcpt. Entry No.", '<>0');
                if PurchReceiptLine.Find('-') then
                    repeat
                        Window.Update(3, PurchReceiptLine."Document No.");
                        InsertItemEntryRelation(PurchReceiptLine."Item Rcpt. Entry No.",
                          DATABASE::"Purch. Rcpt. Line", 0, PurchReceiptLine."Document No.",
                          '', 0, PurchReceiptLine."Line No.", GetLotNo(PurchReceiptLine."Variant Code"),
                          PurchReceiptLine."Order No.", PurchReceiptLine."Order Line No.");
                        PurchReceiptLine."Item Rcpt. Entry No." := 0;
                        PurchReceiptLine.Modify;
                        UpdateAltQtyEntry(DATABASE::"Purch. Rcpt. Line", PurchReceiptLine."Document No.", PurchReceiptLine."Line No.",
                          GetLotNo(PurchReceiptLine."Variant Code"));
                    until PurchReceiptLine.Next = 0;

                Window.Update(2, PurchInvoiceLine.TableCaption);
                Window.Update(3, '');
                if PurchInvoiceLine.SetCurrentKey(Type, "No.") then;
                PurchInvoiceLine.SetRange(Type, PurchInvoiceLine.Type::Item);
                PurchInvoiceLine.SetRange("No.", "Item No.");
                PurchInvoiceLine.SetFilter(Quantity, '<>0');
                if PurchInvoiceLine.Find('-') then
                    repeat
                        Window.Update(3, PurchInvoiceLine."Document No.");
                        GetValueEntryForPurchInvoice(PurchInvoiceLine, TempValueEntry);
                        if TempValueEntry.Find('-') then
                            repeat
                                InsertValueEntryRelation(TempValueEntry."Entry No.", PurchInvoiceLine.RowID1);
                            until TempValueEntry.Next = 0;
                        UpdateAltQtyEntry(DATABASE::"Purch. Inv. Line", PurchInvoiceLine."Document No.", PurchInvoiceLine."Line No.",
                          GetLotNo(PurchInvoiceLine."Variant Code"));
                    until PurchInvoiceLine.Next = 0;

                Window.Update(2, PurchReturnLine.TableCaption);
                Window.Update(3, '');
                if PurchReturnLine.SetCurrentKey(Type, "No.") then;
                PurchReturnLine.SetRange(Type, PurchReturnLine.Type::Item);
                PurchReturnLine.SetRange("No.", "Item No.");
                PurchReturnLine.SetFilter("Item Shpt. Entry No.", '<>0');
                if PurchReturnLine.Find('-') then
                    repeat
                        Window.Update(3, PurchReturnLine."Document No.");
                        InsertItemEntryRelation(PurchReturnLine."Item Shpt. Entry No.",
                          DATABASE::"Return Shipment Line", 0, PurchReturnLine."Document No.",
                          '', 0, PurchReturnLine."Line No.", GetLotNo(PurchReturnLine."Variant Code"),
                          PurchReturnLine."Return Order No.", PurchReturnLine."Return Order Line No.");
                        PurchReturnLine."Item Shpt. Entry No." := 0;
                        PurchReturnLine.Modify;
                        UpdateAltQtyEntry(DATABASE::"Return Shipment Line", PurchReturnLine."Document No.", PurchReturnLine."Line No.",
                          GetLotNo(PurchReturnLine."Variant Code"));
                    until PurchReturnLine.Next = 0;

                Window.Update(2, PurchCrMemoLine.TableCaption);
                Window.Update(3, '');
                if PurchCrMemoLine.SetCurrentKey(Type, "No.") then;
                PurchCrMemoLine.SetRange(Type, PurchCrMemoLine.Type::Item);
                PurchCrMemoLine.SetRange("No.", "Item No.");
                PurchCrMemoLine.SetFilter(Quantity, '<>0');
                if PurchCrMemoLine.Find('-') then
                    repeat
                        Window.Update(3, PurchCrMemoLine."Document No.");
                        GetValueEntryForPurchCrMemo(PurchCrMemoLine, TempValueEntry);
                        if TempValueEntry.Find('-') then
                            repeat
                                InsertValueEntryRelation(TempValueEntry."Entry No.", PurchCrMemoLine.RowID1);
                            until TempValueEntry.Next = 0;
                        UpdateAltQtyEntry(DATABASE::"Purch. Cr. Memo Line", PurchCrMemoLine."Document No.", PurchCrMemoLine."Line No.",
                          GetLotNo(PurchCrMemoLine."Variant Code"));
                    until PurchCrMemoLine.Next = 0;

                Window.Update(2, TransShipmentLine.TableCaption);
                Window.Update(3, '');
                if TransShipmentLine.SetCurrentKey(Type, "Item No.") then;
                TransShipmentLine.SetRange(Type, TransShipmentLine.Type::Item);
                TransShipmentLine.SetRange("Item No.", "Item No.");
                TransShipmentLine.SetFilter("Item Shpt. Entry No.", '<>0');
                if TransShipmentLine.Find('-') then
                    repeat
                        Window.Update(3, TransShipmentLine."Document No.");
                        InsertItemEntryRelation(TransShipmentLine."Item Shpt. Entry No.",
                          DATABASE::"Transfer Shipment Line", 0, TransShipmentLine."Document No.",
                          '', 0, TransShipmentLine."Line No.", GetLotNo(TransShipmentLine."Variant Code"),
                          TransShipmentLine."Transfer Order No.", TransShipmentLine."Line No.");
                        TransShipmentLine."Item Shpt. Entry No." := 0;
                        TransShipmentLine.Modify;
                        UpdateAltQtyEntry(DATABASE::"Transfer Shipment Line", TransShipmentLine."Document No.", TransShipmentLine."Line No.",
                          GetLotNo(TransShipmentLine."Variant Code"));
                    until TransShipmentLine.Next = 0;

                Window.Update(2, TransReceiptLine.TableCaption);
                Window.Update(3, '');
                if TransReceiptLine.SetCurrentKey(Type, "Item No.") then;
                TransReceiptLine.SetRange(Type, TransReceiptLine.Type::Item);
                TransReceiptLine.SetRange("Item No.", "Item No.");
                TransReceiptLine.SetFilter("Item Rcpt. Entry No.", '<>0');
                if TransReceiptLine.Find('-') then
                    repeat
                        Window.Update(3, TransReceiptLine."Document No.");
                        InsertItemEntryRelation(TransReceiptLine."Item Rcpt. Entry No.",
                          DATABASE::"Transfer Receipt Line", 0, TransReceiptLine."Document No.",
                          '', 0, TransReceiptLine."Line No.", GetLotNo(TransReceiptLine."Variant Code"),
                          TransReceiptLine."Transfer Order No.", TransReceiptLine."Line No.");
                        TransReceiptLine."Item Rcpt. Entry No." := 0;
                        TransReceiptLine.Modify;
                        UpdateAltQtyEntry(DATABASE::"Transfer Receipt Line", TransReceiptLine."Document No.", TransReceiptLine."Line No.",
                          GetLotNo(TransReceiptLine."Variant Code"));
                    until TransReceiptLine.Next = 0;

                Window.Update(2, ContainerLine.TableCaption);
                if ContainerLine.SetCurrentKey("Item No.") then;
                ContainerLine.SetRange("Item No.", "Item No.");
                if ContainerLine.Find('-') then
                    repeat
                        Window.Update(3, ContainerLine."Container ID");
                        ContainerLine2 := ContainerLine;
                        ContainerLine2."Lot No." := GetLotNo(ContainerLine2."Variant Code");
                        ContainerLine2.Modify;
                    until ContainerLine.Next = 0;

                Window.Update(2, ClosedContainerLine.TableCaption);
                Window.Update(3, '');
                if ClosedContainerLine.SetCurrentKey("Item No.") then;
                ClosedContainerLine.SetRange("Item No.", "Item No.");
                if ClosedContainerLine.Find('-') then
                    repeat
                        Window.Update(3, ClosedContainerLine."Container ID");
                        ClosedContainerLine."Lot No." := GetLotNo(ClosedContainerLine."Variant Code");
                        ClosedContainerLine.Modify;
                    until ClosedContainerLine.Next = 0;

                LotByVariant.Reset;
                if LotByVariant.Find('-') then
                    repeat
                        LotInfo.Init;
                        LotInfo."Item No." := "Item No.";
                        LotInfo."Variant Code" := LotByVariant.Code;
                        LotInfo."Lot No." := LotByVariant.Description;
                        LotInfo.Description := Item.Description;
                        LotInfo."Item Category Code" := Item."Item Category Code"; // P8000153A
                        LotInfo."Release Date" := ReleaseDate;
                        LotInfo.Posted := true;
                        LotInfo.Insert;

                        LotComment.Init;
                        LotComment.Type := LotComment.Type::"Lot No.";
                        LotComment."Item No." := LotInfo."Item No.";
                        LotComment."Variant Code" := LotInfo."Variant Code";
                        LotComment."Serial/Lot No." := LotInfo."Lot No.";
                        LotComment."Line No." := 10000;
                        LotComment.Date := Today;
                        LotComment.Comment := Text012;
                        LotComment.Insert;
                    until LotByVariant.Next = 0;

                Item."Item Tracking Code" := "Item Tracking Code";
                Item."Lot Nos." := "Lot Nos.";
                Item.Modify;

                Delete;
            end;

            trigger OnPreDataItem()
            var
                Location: Record Location;
            begin
                TempLocation.Code := '';
                TempLocation.Insert;
                Location.SetFilter(Code, '<>%1', '');
                if Location.Find('-') then
                    repeat
                        TempLocation.Code := Location.Code;
                        TempLocation.Insert;
                    until Location.Next = 0;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        Window.Close;
    end;

    trigger OnPreReport()
    begin
        // P8001216
        //KeyGroup.GET('LOT CTRL');
        //KeyGroup.TESTFIELD("Last Change",KeyGroup."Last Change"::Enabled);
        // P8001216

        Window.Open(
          Text001 +
          Text002);
    end;

    var
        LotByVariant: Record Variant temporary;
        Item: Record Item;
        ItemLedger: Record "Item Ledger Entry";
        PhysInvLedger: Record "Phys. Inventory Ledger Entry";
        ContainerLedger: Record "Container Ledger Entry";
        SalesShipmentLine: Record "Sales Shipment Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesReturnLine: Record "Return Receipt Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        PurchReceiptLine: Record "Purch. Rcpt. Line";
        PurchInvoiceLine: Record "Purch. Inv. Line";
        PurchReturnLine: Record "Return Shipment Line";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        TransShipmentLine: Record "Transfer Shipment Line";
        TransReceiptLine: Record "Transfer Receipt Line";
        ContainerLine: Record "Container Line";
        ContainerLine2: Record "Container Line";
        ClosedContainerLine: Record "Shipped Container Line";
        AltQtyEntry: Record "Alternate Quantity Entry";
        LotInfo: Record "Lot No. Information";
        LotComment: Record "Item Tracking Comment";
        TempLocation: Record Location temporary;
        TempVariant: Record Variant temporary;
        TempValueEntry: Record "Value Entry" temporary;
        NoSeriesMgmt: Codeunit NoSeriesManagement;
        ReleaseDate: Date;
        Window: Dialog;
        Text001: Label 'Item         #1#################\';
        Text002: Label 'Table        #2#################   #3##############';
        Text003: Label '; ';
        Text004: Label 'Tracking already on';
        Text005: Label 'Incomplete specification';
        Text006: Label 'Unable to assign lot number';
        Text007: Label 'Negative balance';
        Text008: Label 'Sales ship/receive not invoiced';
        Text009: Label 'Purchase receive/ship not invoiced';
        Text010: Label 'Transfer ship/receive not invoiced';
        Text011: Label 'Assigned containers';
        Text012: Label 'Conversion to lot controlled';
        WhseEntry: Record "Warehouse Entry";

    procedure UpdateAltQtyEntry(TableNo: Integer; DocNo: Code[20]; SourceLineNo: Integer; LotNo: Code[50])
    begin
        AltQtyEntry.SetRange("Table No.", TableNo);
        AltQtyEntry.SetRange("Document No.", DocNo);
        AltQtyEntry.SetRange("Source Line No.", SourceLineNo);
        AltQtyEntry.ModifyAll("Lot No.", LotNo);
    end;

    procedure GetValueEntryForSalesInvoice(SalesInvoiceLine: Record "Sales Invoice Line"; var TempValueEntry: Record "Value Entry" temporary)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        ItemEntryRelation: Record "Item Entry Relation";
        ItemLedger: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        ValueEntryRelation: Record "Value Entry Relation";
    begin
        TempValueEntry.Reset;
        TempValueEntry.DeleteAll;

        SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.");
        if SalesInvoiceHeader."Order No." <> '' then begin
            SalesShipmentLine.SetCurrentKey("Order No.", "Order Line No.");
            SalesShipmentLine.SetRange("Order No.", SalesInvoiceHeader."Order No.");
            SalesShipmentLine.SetRange("Order Line No.", SalesInvoiceLine."Line No.");
            if SalesShipmentLine.Find('-') then begin
                ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.",
                  "Source Prod. Order Line", "Source Batch Name");
                ItemEntryRelation.SetRange("Source Type", DATABASE::"Sales Shipment Line");
                ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type"); // P8000267B
                ValueEntry.SetRange("Expected Cost", false);
                ValueEntry.SetRange("Document No.", SalesInvoiceLine."Document No.");
                ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
                ValueEntry.SetFilter("Invoiced Quantity", '<>0');
                repeat
                    ItemEntryRelation.SetRange("Source ID", SalesShipmentLine."Document No.");
                    ItemEntryRelation.SetRange("Source Ref. No.", SalesShipmentLine."Line No.");
                    if ItemEntryRelation.Find('-') then
                        repeat
                            ValueEntry.SetRange("Item Ledger Entry No.", ItemEntryRelation."Item Entry No.");
                            if ValueEntry.Find('-') then begin
                                TempValueEntry := ValueEntry;
                                TempValueEntry.Insert;
                            end;
                        until ItemEntryRelation.Next = 0;
                until SalesShipmentLine.Next = 0;
            end;
        end else begin
            //ValueEntry.SETCURRENTKEY("Document No.","Posting Date"); // P8000466A
            ValueEntry.SetCurrentKey("Document No.");                  // P8000466A
            ValueEntry.SetRange("Document No.", SalesInvoiceLine."Document No.");
            ValueEntry.SetRange("Posting Date", SalesInvoiceHeader."Posting Date");
            ValueEntry.SetRange("Item No.", SalesInvoiceLine."No.");
            ValueEntry.SetRange("Expected Cost", false);
            ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
            ValueEntry.SetRange("Invoiced Quantity", -SalesInvoiceLine."Quantity (Base)");
            ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
            ValueEntry.SetRange("Source Type", ValueEntry."Source Type"::Customer);
            ValueEntry.SetRange("Source No.", SalesInvoiceLine."Sell-to Customer No.");
            if ValueEntry.Find('-') then
                repeat
                    if not ValueEntryRelation.Get(ValueEntry."Entry No.") then begin
                        TempValueEntry := ValueEntry;
                        TempValueEntry.Insert;
                        exit;
                    end;
                until ValueEntry.Next = 0;
        end;
    end;

    procedure GetValueEntryForSalesCrMemo(SalesCrMemoLine: Record "Sales Cr.Memo Line"; var TempValueEntry: Record "Value Entry" temporary)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesReturnLine: Record "Return Receipt Line";
        ItemEntryRelation: Record "Item Entry Relation";
        ItemLedger: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        ValueEntryRelation: Record "Value Entry Relation";
    begin
        TempValueEntry.Reset;
        TempValueEntry.DeleteAll;

        SalesCrMemoHeader.Get(SalesCrMemoLine."Document No.");
        if SalesCrMemoHeader."Return Order No." <> '' then begin
            SalesReturnLine.SetCurrentKey("Return Order No.", "Return Order Line No.");
            SalesReturnLine.SetRange("Return Order No.", SalesCrMemoHeader."Return Order No.");
            SalesReturnLine.SetRange("Return Order Line No.", SalesCrMemoLine."Line No.");
            if SalesReturnLine.Find('-') then begin
                ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.",
                  "Source Prod. Order Line", "Source Batch Name");
                ItemEntryRelation.SetRange("Source Type", DATABASE::"Sales Shipment Line");
                ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type"); // P8000267B
                ValueEntry.SetRange("Expected Cost", false);
                ValueEntry.SetRange("Document No.", SalesCrMemoLine."Document No.");
                ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
                ValueEntry.SetFilter("Invoiced Quantity", '<>0');
                repeat
                    ItemEntryRelation.SetRange("Source ID", SalesReturnLine."Document No.");
                    ItemEntryRelation.SetRange("Source Ref. No.", SalesReturnLine."Line No.");
                    if ItemEntryRelation.Find('-') then
                        repeat
                            ValueEntry.SetRange("Item Ledger Entry No.", ItemEntryRelation."Item Entry No.");
                            if ValueEntry.Find('-') then begin
                                TempValueEntry := ValueEntry;
                                TempValueEntry.Insert;
                            end;
                        until ItemEntryRelation.Next = 0;
                until SalesReturnLine.Next = 0;
            end;
        end else begin
            //ValueEntry.SETCURRENTKEY("Document No.","Posting Date"); // P8000466A
            ValueEntry.SetCurrentKey("Document No.");                  // P8000466A
            ValueEntry.SetRange("Document No.", SalesCrMemoLine."Document No.");
            ValueEntry.SetRange("Posting Date", SalesCrMemoHeader."Posting Date");
            ValueEntry.SetRange("Item No.", SalesCrMemoLine."No.");
            ValueEntry.SetRange("Expected Cost", false);
            ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
            ValueEntry.SetRange("Invoiced Quantity", SalesCrMemoLine."Quantity (Base)");
            ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
            ValueEntry.SetRange("Source Type", ValueEntry."Source Type"::Customer);
            ValueEntry.SetRange("Source No.", SalesCrMemoLine."Sell-to Customer No.");
            if ValueEntry.Find('-') then
                repeat
                    if not ValueEntryRelation.Get(ValueEntry."Entry No.") then begin
                        TempValueEntry := ValueEntry;
                        TempValueEntry.Insert;
                        exit;
                    end;
                until ValueEntry.Next = 0;
        end;
    end;

    procedure GetValueEntryForPurchInvoice(PurchInvoiceLine: Record "Purch. Inv. Line"; var TempValueEntry: Record "Value Entry" temporary)
    var
        PurchInvoiceHeader: Record "Purch. Inv. Header";
        PurchReceiptLine: Record "Purch. Rcpt. Line";
        ItemEntryRelation: Record "Item Entry Relation";
        ItemLedger: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        ValueEntryRelation: Record "Value Entry Relation";
    begin
        TempValueEntry.Reset;
        TempValueEntry.DeleteAll;

        PurchInvoiceHeader.Get(PurchInvoiceLine."Document No.");
        if PurchInvoiceHeader."Order No." <> '' then begin
            PurchReceiptLine.SetCurrentKey("Order No.", "Order Line No.");
            PurchReceiptLine.SetRange("Order No.", PurchInvoiceHeader."Order No.");
            PurchReceiptLine.SetRange("Order Line No.", PurchInvoiceLine."Line No.");
            if PurchReceiptLine.Find('-') then begin
                ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.",
                  "Source Prod. Order Line", "Source Batch Name");
                ItemEntryRelation.SetRange("Source Type", DATABASE::"Purch. Rcpt. Line");
                ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type"); // P8000267B
                ValueEntry.SetRange("Expected Cost", false);
                ValueEntry.SetRange("Document No.", PurchInvoiceLine."Document No.");
                ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
                ValueEntry.SetFilter("Invoiced Quantity", '<>0');
                repeat
                    ItemEntryRelation.SetRange("Source ID", PurchReceiptLine."Document No.");
                    ItemEntryRelation.SetRange("Source Ref. No.", PurchReceiptLine."Line No.");
                    if ItemEntryRelation.Find('-') then
                        repeat
                            ValueEntry.SetRange("Item Ledger Entry No.", ItemEntryRelation."Item Entry No.");
                            if ValueEntry.Find('-') then begin
                                TempValueEntry := ValueEntry;
                                TempValueEntry.Insert;
                            end;
                        until ItemEntryRelation.Next = 0;
                until PurchReceiptLine.Next = 0;
            end;
        end else begin
            //ValueEntry.SETCURRENTKEY("Document No.","Posting Date"); // P8000466A
            ValueEntry.SetCurrentKey("Document No.");                  // P8000466A
            ValueEntry.SetRange("Document No.", PurchInvoiceLine."Document No.");
            ValueEntry.SetRange("Posting Date", PurchInvoiceHeader."Posting Date");
            ValueEntry.SetRange("Item No.", PurchInvoiceLine."No.");
            ValueEntry.SetRange("Expected Cost", false);
            ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
            ValueEntry.SetRange("Invoiced Quantity", PurchInvoiceLine."Quantity (Base)");
            ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Purchase);
            ValueEntry.SetRange("Source Type", ValueEntry."Source Type"::Vendor);
            ValueEntry.SetRange("Source No.", PurchInvoiceLine."Buy-from Vendor No.");
            if ValueEntry.Find('-') then
                repeat
                    if not ValueEntryRelation.Get(ValueEntry."Entry No.") then begin
                        TempValueEntry := ValueEntry;
                        TempValueEntry.Insert;
                        exit;
                    end;
                until ValueEntry.Next = 0;
        end;
    end;

    procedure GetValueEntryForPurchCrMemo(PurchCrMemoLine: Record "Purch. Cr. Memo Line"; var TempValueEntry: Record "Value Entry" temporary)
    var
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        PurchReturnLine: Record "Return Shipment Line";
        ItemEntryRelation: Record "Item Entry Relation";
        ItemLedger: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        ValueEntryRelation: Record "Value Entry Relation";
    begin
        TempValueEntry.Reset;
        TempValueEntry.DeleteAll;

        PurchCrMemoHeader.Get(PurchCrMemoLine."Document No.");
        if PurchCrMemoHeader."Return Order No." <> '' then begin
            PurchReturnLine.SetCurrentKey("Return Order No.", "Return Order Line No.");
            PurchReturnLine.SetRange("Return Order No.", PurchCrMemoHeader."Return Order No.");
            PurchReturnLine.SetRange("Return Order Line No.", PurchCrMemoLine."Line No.");
            if PurchReturnLine.Find('-') then begin
                ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.",
                  "Source Prod. Order Line", "Source Batch Name");
                ItemEntryRelation.SetRange("Source Type", DATABASE::"Purch. Rcpt. Line");
                ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type"); // P8000267B
                ValueEntry.SetRange("Expected Cost", false);
                ValueEntry.SetRange("Document No.", PurchCrMemoLine."Document No.");
                ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
                ValueEntry.SetFilter("Invoiced Quantity", '<>0');
                repeat
                    ItemEntryRelation.SetRange("Source ID", PurchReturnLine."Document No.");
                    ItemEntryRelation.SetRange("Source Ref. No.", PurchReturnLine."Line No.");
                    if ItemEntryRelation.Find('-') then
                        repeat
                            ValueEntry.SetRange("Item Ledger Entry No.", ItemEntryRelation."Item Entry No.");
                            if ValueEntry.Find('-') then begin
                                TempValueEntry := ValueEntry;
                                TempValueEntry.Insert;
                            end;
                        until ItemEntryRelation.Next = 0;
                until PurchReturnLine.Next = 0;
            end;
        end else begin
            //ValueEntry.SETCURRENTKEY("Document No.","Posting Date"); // P8000466A
            ValueEntry.SetCurrentKey("Document No.");                  // P8000466A
            ValueEntry.SetRange("Document No.", PurchCrMemoLine."Document No.");
            ValueEntry.SetRange("Posting Date", PurchCrMemoHeader."Posting Date");
            ValueEntry.SetRange("Item No.", PurchCrMemoLine."No.");
            ValueEntry.SetRange("Expected Cost", false);
            ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
            ValueEntry.SetRange("Invoiced Quantity", PurchCrMemoLine."Quantity (Base)");
            ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Purchase);
            ValueEntry.SetRange("Source Type", ValueEntry."Source Type"::Vendor);
            ValueEntry.SetRange("Source No.", PurchCrMemoLine."Buy-from Vendor No.");
            if ValueEntry.Find('-') then
                repeat
                    if not ValueEntryRelation.Get(ValueEntry."Entry No.") then begin
                        TempValueEntry := ValueEntry;
                        TempValueEntry.Insert;
                        exit;
                    end;
                until ValueEntry.Next = 0;
        end;
    end;

    procedure InsertItemEntryRelation(EntryNo: Integer; Type: Integer; Subtype: Integer; ID: Code[20]; BatchName: Code[10]; ProdOrderLine: Integer; RefNo: Integer; LotNo: Code[50]; OrderNo: Code[20]; OrderLine: Integer)
    var
        ItemEntryRelation: Record "Item Entry Relation";
    begin
        ItemEntryRelation."Item Entry No." := EntryNo;
        ItemEntryRelation."Source Type" := Type;
        ItemEntryRelation."Source Subtype" := Subtype;
        ItemEntryRelation."Source ID" := ID;
        ItemEntryRelation."Source Batch Name" := BatchName;
        ItemEntryRelation."Source Prod. Order Line" := ProdOrderLine;
        ItemEntryRelation."Source Ref. No." := RefNo;
        ItemEntryRelation."Lot No." := LotNo;
        ItemEntryRelation."Order No." := OrderNo;
        ItemEntryRelation."Order Line No." := OrderLine;
        ItemEntryRelation.Insert;
    end;

    procedure InsertValueEntryRelation(EntryNo: Integer; RowID: Text[100])
    var
        ValueEntryRelation: Record "Value Entry Relation";
    begin
        if EntryNo = 0 then
            exit;
        ValueEntryRelation."Value Entry No." := EntryNo;
        ValueEntryRelation."Source RowId" := RowID;
        ValueEntryRelation.Insert;
    end;

    procedure AssignLotNo(ItemNo: Code[20]): Boolean
    var
        ItemLedger: Record "Item Ledger Entry";
        PhysLedger: Record "Phys. Inventory Ledger Entry";
        OrigLotNo: array[2] of Code[50];
    begin
        LotByVariant.Reset;
        LotByVariant.DeleteAll;

        ItemLedger.SetCurrentKey("Item No.", "Variant Code");
        ItemLedger.SetRange("Item No.", ItemNo);
        PhysLedger.SetCurrentKey("Item No.", "Variant Code");
        PhysLedger.SetRange("Item No.", ItemNo);
        if TempVariant.Find('-') then
            repeat
                ItemLedger.SetRange("Variant Code", TempVariant.Code);
                if ItemLedger.Find('-') then begin
                    LotByVariant.Code := TempVariant.Code;
                    LotByVariant.Insert;
                end else begin
                    PhysLedger.SetRange("Variant Code", TempVariant.Code);
                    if PhysLedger.Find('-') then begin
                        LotByVariant.Code := TempVariant.Code;
                        LotByVariant.Insert;
                    end;
                end;
            until TempVariant.Next = 0;

        OrigLotNo[2] := "Lot Control Item"."Original Lot No.";
        if LotByVariant.Find('-') then
            repeat
                if OrigLotNo[2] = '' then begin
                    LotByVariant.Description := NoSeriesMgmt.GetNextNo("Lot Control Item"."Lot Nos.", Today, true);
                    LotByVariant.Modify;
                end else
                    if OrigLotNo[1] <> OrigLotNo[2] then begin
                        LotByVariant.Description := OrigLotNo[2];
                        LotByVariant.Modify;
                        OrigLotNo[1] := OrigLotNo[2];
                        OrigLotNo[2] := IncStr(OrigLotNo[1]);
                        if OrigLotNo[2] = '' then
                            OrigLotNo[2] := OrigLotNo[1];
                    end else
                        exit(false);
            until LotByVariant.Next = 0;

        exit(true);
    end;

    procedure GetLotNo(VariantCode: Code[10]): Code[50]
    begin
        LotByVariant.Get(VariantCode);
        exit(LotByVariant.Description);
    end;

    procedure CheckBalance(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);

        TempLocation.Find('-');
        repeat
            Item.SetRange("Location Filter", TempLocation.Code);
            TempVariant.Find('-');
            repeat
                Item.SetRange("Variant Filter", TempVariant.Code);
                Item.CalcFields(Inventory);
                if Item.Inventory < 0 then
                    exit(false);
            until TempVariant.Next = 0;
        until TempLocation.Next = 0;

        exit(true);
    end;

    procedure CheckSalesLines(ItemNo: Code[20]): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetCurrentKey(Type, "No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("No.", ItemNo);
        SalesLine.SetFilter("Qty. Shipped Not Invoiced", '<>0');
        if SalesLine.Find('-') then
            exit(false);
        SalesLine.SetRange("Qty. Shipped Not Invoiced");
        SalesLine.SetFilter("Return Qty. Rcd. Not Invd.", '<>0');
        exit(not SalesLine.Find('-'));
    end;

    procedure CheckPurchLines(ItemNo: Code[20]): Boolean
    var
        PurchLine: Record "Purchase Line";
    begin
        PurchLine.SetCurrentKey(Type, "No.");
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        PurchLine.SetRange("No.", ItemNo);
        PurchLine.SetFilter("Qty. Rcd. Not Invoiced", '<>0');
        if PurchLine.Find('-') then
            exit(false);
        PurchLine.SetRange("Qty. Rcd. Not Invoiced");
        PurchLine.SetFilter("Return Qty. Shipped Not Invd.", '<>0');
        exit(not PurchLine.Find('-'));
    end;

    procedure CheckAssignedContainers(ItemNo: Code[20]): Boolean
    var
        ContainerLine: Record "Container Line";
        ContainerHeader: Record "Container Header";
    begin
        // P8001324
        ContainerLine.SetRange("Item No.", ItemNo);
        if ContainerLine.FindSet then
            repeat
                ContainerHeader.Get(ContainerLine."Container ID");
                if ContainerHeader."Document Type" <> 0 then
                    exit(false);
            until ContainerLine.Next = 0;
        exit(true);
    end;

    procedure CheckTransLines(ItemNo: Code[20]): Boolean
    var
        TransLine: Record "Transfer Line";
    begin
        TransLine.SetCurrentKey("Item No.");
        TransLine.SetRange("Item No.", ItemNo);
        TransLine.SetFilter("Qty. in Transit", '<>0');
        exit(not TransLine.Find('-'));
    end;

    procedure UpdateMessage(Msg: Text[50])
    begin
        if "Lot Control Item".Message <> '' then
            "Lot Control Item".Message := "Lot Control Item".Message + Text003;
        "Lot Control Item".Message := "Lot Control Item".Message + Msg;
    end;
}

