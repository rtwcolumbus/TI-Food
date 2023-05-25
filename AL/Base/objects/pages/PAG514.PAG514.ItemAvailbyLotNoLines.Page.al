page 514 "Item Avail. by Lot No. Lines"
{
    // PR18.1
    // P800109637, To-Increase, Jack Reynolds, 28 SEP 21
    //   Lot Status Summary

    Caption = 'Lines';
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SaveValues = true;
    SourceTable = "Availability Info. Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                Editable = false;
                IndentationColumn = Indent;
                TreeInitialState = CollapseAll;
                ShowAsTree = true;
                ShowCaption = false;

                field(LotStatusCode; LotStatusDisplay())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot Status Code';
                    Style = Attention;
                    StyleExpr = Rec.Exclude;
                }
                field(VariantCode; Rec."Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Style = Attention;
                    StyleExpr = Rec.Exclude;
                }
                field(LotNo; Rec."Lot No.")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Lot No.';
                    Style = Attention;
                    StyleExpr = Rec.Exclude;
                    ToolTip = 'Specifies a location code for the warehouse or distribution center where your items are handled and stored before being sold.';
                }
                field(SupplierLotNo; Rec."Supplier Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                    Visible = false;
                }
                field(CreationDate; Rec."Creation Date")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                    Visible = false;
                }
                field(ExpirationDate; Rec."Expiration Date-Lot Info")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Expiration Date';
                    DrillDown = false;
                    ToolTip = 'Specifies expiration date for the specified lot.';
                }
                field(Quality; Rec.Quality)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Quality';
                    ToolTip = 'Specifies the test quality of the specified lot.';
                    Visible = false;
                }
                field(CertificateNumber; Rec."Certificate Number")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Certificate Number';
                    ToolTip = 'Specifies the certificate number of the specified lot.';
                    Visible = false;
                }

                field(Inventory; Rec."Qty. In Hand")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory';
                    DecimalPlaces = 0 : 5;
                    Style = Strong;
                    StyleExpr = Rec."Lot No." = '';
                    ToolTip = 'Specifies the inventory level of an item.';

                    trigger OnDrillDown()
                    var
                        ItemLedgerEntry: Record "Item Ledger Entry";
                        IsHandled: Boolean;
                    begin
                        if Rec."Lot No." = '' then // P800109637
                            exit;                  // P800109637

                        OnBeforeLookupInventory(IsHandled, Rec);
                        if IsHandled then
                            exit;

                        Rec.LookupInventory(ItemLedgerEntry);
                        if ItemLedgerEntry.FindSet() then
                            Page.RunModal(0, ItemLedgerEntry);
                    end;
                }
                field(GrossRequirement; Rec."Gross Requirement")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Gross Requirement';
                    DecimalPlaces = 0 : 5;
                    Style = Strong;
                    StyleExpr = Rec."Lot No." = '';
                    ToolTip = 'Specifies the sum of the total demand for the item. The gross requirement consists of independent demand (which include sales orders, service orders, transfer orders, and demand forecasts) and dependent demand (which include production order components for planned, firm planned, and released production orders and requisition and planning worksheets lines).';

                    trigger OnDrillDown()
                    var
                        TempReservationEntry: Record "Reservation Entry" temporary;
                        IsHandled: Boolean;
                    begin
                        if Rec."Lot No." = '' then // P800109637
                            exit;                  // P800109637

                        OnBeforeLookupGrossRequirement(IsHandled, Rec);
                        if IsHandled then
                            exit;

                        Rec.LookupGrossRequirement(TempReservationEntry);
                        if TempReservationEntry.FindSet() then
                            Page.RunModal(0, TempReservationEntry);
                    end;
                }
                field(ScheduledRcpt; Rec."Scheduled Receipt")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Scheduled Receipt';
                    DecimalPlaces = 0 : 5;
                    Style = Strong;
                    StyleExpr = Rec."Lot No." = '';
                    ToolTip = 'Specifies the sum of items from replenishment orders.';

                    trigger OnDrillDown()
                    var
                        TempReservationEntry: Record "Reservation Entry" temporary;
                        IsHandled: Boolean;
                    begin
                        if Rec."Lot No." = '' then // P800109637
                            exit;                  // P800109637

                        OnBeforeLookupScheduledReceipt(IsHandled, Rec);
                        if IsHandled then
                            exit;

                        Rec.LookupScheduledReceipt(TempReservationEntry);
                        if TempReservationEntry.FindSet() then
                            Page.RunModal(0, TempReservationEntry);
                    end;
                }
                field(PlannedOrderRcpt; Rec."Planned Order Receipt")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Planned Order Receipt';
                    DecimalPlaces = 0 : 5;
                    Style = Strong;
                    StyleExpr = Rec."Lot No." = '';
                    ToolTip = 'Specifies the item''s availability figures for the planned order receipt.';

                    trigger OnDrillDown()
                    var
                        TempReservationEntry: Record "Reservation Entry" temporary;
                        IsHandled: Boolean;
                    begin
                        if Rec."Lot No." = '' then // P800109637
                            exit;                  // P800109637

                        OnBeforeLookupPlannedOrderReceipt(IsHandled, Rec);
                        if IsHandled then
                            exit;

                        Rec.LookupPlannedOrderReceipt(TempReservationEntry);
                        if TempReservationEntry.FindSet() then
                            Page.RunModal(0, TempReservationEntry);
                    end;
                }
                field(QtyAvailable; Rec."Available Inventory")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Available Inventory';
                    DecimalPlaces = 0 : 5;
                    Style = Strong;
                    StyleExpr = Rec."Lot No." = '';
                    ToolTip = 'Specifies the quantity of the item that is currently in inventory and not reserved for other demand.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        // P800109637
        // Calculate();
        if Rec."Lot No." = '' then
            Indent := 0
        else
            Indent := 2;
        // P800109637
    end;

    var
        LotStatusExclusionFilter: Text[1024];
        Indent: Integer;
        Item: Record Item;
        [InDataSet]
        GrossRequirement: Decimal;
        [InDataSet]
        PlannedOrderRcpt: Decimal;
        [InDataSet]
        ScheduledRcpt: Decimal;

    procedure SetItem(var NewItem: Record Item; NewAmountType: Enum "Analysis Amount Type")
    begin
        Item.Copy(NewItem);
        GenerateLines();
        if Item.GetFilter("Location Filter") <> '' then
            Rec.SetRange("Location Code Filter", Item.GetFilter("Location Filter"));

        // if Item.GetFilter("Variant Filter") <> '' then
        //     Rec.SetRange("Variant Code Filter", Item.GetFilter("Variant Filter"));

        if NewAmountType = NewAmountType::"Net Change" then
            Rec.SetRange("Date Filter", Item.GetRangeMin("Date Filter"), Item.GetRangeMax("Date Filter"))
        else
            Rec.SetRange("Date Filter", 0D, Item.GetRangeMax("Date Filter"));

        OnAfterSetItem(Item, NewAmountType);
        CurrPage.Update(false);
    end;

    procedure GetItem(var ItemOut: Record Item)
    begin
        ItemOut.Copy(Item);
    end;

    local procedure GenerateLines()
    begin
        BuildLotNoList(Rec, Item."No.");
        if Rec.FindFirst() then;
    end;

    local procedure Calculate(var Rec: Record "Availability Info. Buffer")
    var
        IsHandled: Boolean;
    begin
        Rec.SetRange("Lot No. Filter", "Lot No.");
        OnBeforeCalcAvailQuantities(Rec, Item, IsHandled);

        if not IsHandled then
            Rec.CalcFields(
                Inventory,
                "Qty. on Sales Order",
                "Qty. on Service Order",
                "Qty. on Job Order",
                "Qty. on Component Lines",
                "Qty. on Trans. Order Shipment",
                "Qty. on Asm. Component",
                "Qty. on Purch. Return",
                "Planned Order Receipt (Qty.)",
                "Purch. Req. Receipt (Qty.)",
                "Qty. on Purch. Order",
                "Qty. on Prod. Receipt",
                "Qty. on Trans. Order Receipt",
                "Qty. on Assembly Order",
                "Qty. on Sales Return"
            );

        /*GrossRequirement :=
            "Qty. on Sales Order" + "Qty. on Service Order" + "Qty. on Job Order" + "Qty. on Component Lines" +
            TransOrdShipmentQty + "Planning Issues (Qty.)" + "Qty. on Asm. Component" + "Qty. on Purch. Return";*/
        GrossRequirement :=
            Rec."Qty. on Sales Order" +
            Rec."Qty. on Service Order" +
            Rec."Qty. on Job Order" +
            Rec."Qty. on Component Lines" +
            Rec."Qty. on Trans. Order Shipment" +
            Rec."Qty. on Asm. Component" +
            Rec."Qty. on Purch. Return";

        /*PlannedOrderReceipt := "Planned Order Receipt (Qty.)" + "Purch. Req. Receipt (Qty.)";*/
        PlannedOrderRcpt :=
            Rec."Planned Order Receipt (Qty.)" +
            Rec."Purch. Req. Receipt (Qty.)";

        /*ScheduledReceipt :=
            "FP Order Receipt (Qty.)" + "Rel. Order Receipt (Qty.)" + "Qty. on Purch. Order" +
            QtyinTransit + TransOrdReceiptQty + "Qty. on Assembly Order" + "Qty. on Sales Return";*/
        ScheduledRcpt :=
            Rec."Qty. on Prod. Receipt" +
            Rec."Qty. on Purch. Order" +
            Rec."Qty. on Trans. Order Receipt" +
            Rec."Qty. on Assembly Order" +
            Rec."Qty. on Sales Return";

        Rec."Qty. In Hand" := Rec.Inventory;
        Rec."Gross Requirement" := GrossRequirement;
        Rec."Planned Order Receipt" := PlannedOrderRcpt;
        Rec."Scheduled Receipt" := ScheduledRcpt;
        Rec."Available Inventory" := Rec.Inventory + PlannedOrderRcpt + ScheduledRcpt - GrossRequirement;

        OnAfterCalcAvailQuantities(Rec, Item);
    end;

    // P800109637
    local procedure UpdateLotStatusTotal(AvailabilityInfoBuffer: Record "Availability Info. Buffer"; var LotStatusTotalBuffer: Record "Availability Info. Buffer")
    begin
        if LotStatusTotalBuffer.Get(AvailabilityInfoBuffer."Lot Status Code", '', '') then begin
            LotStatusTotalBuffer."Qty. In Hand" += AvailabilityInfoBuffer."Qty. In Hand";
            LotStatusTotalBuffer."Gross Requirement" += AvailabilityInfoBuffer."Gross Requirement";
            LotStatusTotalBuffer."Scheduled Receipt" += AvailabilityInfoBuffer."Scheduled Receipt";
            LotStatusTotalBuffer."Planned Order Receipt" += AvailabilityInfoBuffer."Planned Order Receipt";
            LotStatusTotalBuffer."Available Inventory" += AvailabilityInfoBuffer."Available Inventory";
            LotStatusTotalBuffer.Modify();
        end else begin
            LotStatusTotalBuffer := AvailabilityInfoBuffer;
            LotStatusTotalBuffer."Variant Code" := '';
            LotStatusTotalBuffer."Lot No." := '';
            LotStatusTotalBuffer.Insert();
        end;
    end;

    local procedure BuildLotNoList(var AvailabilityInfoBuffer: Record "Availability Info. Buffer"; ItemNo: Code[20])
    var
        LotStatusTotalBuffer: Record "Availability Info. Buffer" temporary;
        ItemByLotNoRes: Query "Item By Lot No. Res.";
        ItemByLotNoItemLedg: Query "Item By Lot No. Item Ledg.";
        LotDictionary: Dictionary of [Code[50], Text];
    begin
        Clear(AvailabilityInfoBuffer);
        AvailabilityInfoBuffer.DeleteAll();

        LotStatusTotalBuffer.Copy(AvailabilityInfoBuffer, true); // P800109637

        ItemByLotNoItemLedg.SetRange(Item_No, ItemNo);
        ItemByLotNoItemLedg.SetFilter(Variant_Code, Item.GetFilter("Variant Filter"));
        ItemByLotNoItemLedg.SetFilter(Location_Code, Item.GetFilter("Location Filter"));
        ItemByLotNoItemLedg.Open();
        while ItemByLotNoItemLedg.Read() do
            // if ItemByLotNoItemLedg.Lot_No <> '' then
            //     if not LotDictionary.ContainsKey(ItemByLotNoItemLedg.Lot_No) then begin
            if not AvailabilityInfoBuffer.Get(ItemByLotNoItemLedg.Variant_Code, ItemByLotNoItemLedg.Lot_No) then begin
                AvailabilityInfoBuffer.Init();
                AvailabilityInfoBuffer."Item No." := Item."No.";
                AvailabilityInfoBuffer."Variant Code" := ItemByLotNoItemLedg.Variant_Code;
                AvailabilityInfoBuffer."Lot No." := ItemByLotNoItemLedg.Lot_No;
                AvailabilityInfoBuffer."Expiration Date" := ItemByLotNoItemLedg.Expiration_Date;
                AvailabilityInfoBuffer.SetLotStatus(false);
                AvailabilityInfoBuffer.UpdateExclude(LotStatusExclusionFilter);
                Calculate(AvailabilityInfoBuffer); // P800109637
                AvailabilityInfoBuffer.Insert();
                UpdateLotStatusTotal(AvailabilityInfoBuffer, LotStatusTotalBuffer); // P800109637
            end;

        // Expected Receipt Date for positive reservation entries.
        ItemByLotNoRes.SetRange(Item_No, ItemNo);
        ItemByLotNoRes.SetFilter(Quantity__Base_, '>0');
        ItemByLotNoRes.SetFilter(Expected_Receipt_Date, Item.GetFilter("Date Filter"));
        ItemByLotNoRes.SetFilter(Variant_Code, Item.GetFilter("Variant Filter"));
        ItemByLotNoRes.SetFilter(Location_Code, Item.GetFilter("Location Filter"));
        ItemByLotNoRes.Open();
        AddReservationEntryLotNos(AvailabilityInfoBuffer, LotStatusTotalBuffer, ItemByLotNoRes, LotDictionary);

        // Shipment date for negative reservation entries.
        ItemByLotNoRes.SetRange(Item_No, ItemNo);
        ItemByLotNoRes.SetFilter(Quantity__Base_, '<0');
        ItemByLotNoRes.SetFilter(Expected_Receipt_Date, '');
        ItemByLotNoRes.SetFilter(Shipment_Date, Item.GetFilter("Date Filter"));
        ItemByLotNoRes.SetFilter(Variant_Code, Item.GetFilter("Variant Filter"));
        ItemByLotNoRes.SetFilter(Location_Code, Item.GetFilter("Location Filter"));
        AddReservationEntryLotNos(AvailabilityInfoBuffer, LotStatusTotalBuffer, ItemByLotNoRes, LotDictionary);
    end;

    local procedure AddReservationEntryLotNos(
        var AvailabilityInfoBuffer: Record "Availability Info. Buffer";
        var LotStatusTotalBuffer: Record "Availability Info. Buffer";
        var ItemByLotNoRes: Query "Item By Lot No. Res.";
        var LotDictionary: Dictionary of [Code[50], Text]
    )
    begin
        ItemByLotNoRes.Open();
        while ItemByLotNoRes.Read() do
            if ItemByLotNoRes.Lot_No <> '' then
                // if not LotDictionary.ContainsKey(ItemByLotNoRes.Lot_No) then begin
                //     LotDictionary.Add(ItemByLotNoRes.Lot_No, '');
                if not AvailabilityInfoBuffer.Get(ItemByLotNoRes.Variant_Code, ItemByLotNoRes.Lot_No) then begin
                    AvailabilityInfoBuffer.Init();
                    AvailabilityInfoBuffer."Item No." := Item."No.";
                    AvailabilityInfoBuffer."Variant Code" := ItemByLotNoRes.Variant_Code;
                    AvailabilityInfoBuffer."Lot No." := ItemByLotNoRes.Lot_No;
                    AvailabilityInfoBuffer."Expiration Date" := ItemByLotNoRes.Expiration_Date;
                    AvailabilityInfoBuffer.SetLotStatus(ItemByLotNoRes.Qty_Quantity__Base_ > 0);
                    AvailabilityInfoBuffer.UpdateExclude(LotStatusExclusionFilter);
                    Calculate(AvailabilityInfoBuffer); // P800109637
                    AvailabilityInfoBuffer.Insert();
                    UpdateLotStatusTotal(AvailabilityInfoBuffer, LotStatusTotalBuffer); // P800109637
                end;
    end;

    procedure SetAvailableFor(AvailableFor: Option " ",Sale,"Purchase Return",Transfer,Consumption,Adjustment,Planning)
    var
        AvailabilityInfoBuffer: Record "Availability Info. Buffer" temporary;
        LotStatusMgmt: Codeunit "Lot Status Management";
    begin
        LotStatusExclusionFilter := LotStatusMgmt.SetLotStatusExclusionFilter(LotStatusMgmt.AvailableForToFieldNo(AvailableFor));

        AvailabilityInfoBuffer.Copy(Rec, true);
        AvailabilityInfoBuffer.Reset();
        if AvailabilityInfoBuffer.FindSet(true) then
            repeat
                AvailabilityInfoBuffer.UpdateExclude(LotStatusExclusionFilter);
                AvailabilityInfoBuffer.Modify();
            until AvailabilityInfoBuffer.Next() = 0;

        CurrPage.Update(false); // P800109637
    end;

    // P800109637
    local procedure LotStatusDisplay(): Text
    var
        Blank: Label '(blank)';
    begin
        if (Rec."Lot Status Code" = '') and (rec."Lot No." = '') then
            exit(Blank)
        else
            exit(Rec."Lot Status Code");
    end;

    procedure GetLotNoInformation() LotNoInformation: Record "Lot No. Information"
    begin
        if LotNoInformation.Get(xRec."Item No.", xRec."Variant Code", xRec."Lot No.") then;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterSetItem(var Item: Record Item; NewAmountType: Enum "Analysis Amount Type")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCalcAvailQuantities(var AvailabilityInfoBuffer: Record "Availability Info. Buffer"; var Item: Record Item; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterCalcAvailQuantities(var AvailabilityInfoBuffer: Record "Availability Info. Buffer"; var Item: Record Item)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeLookupInventory(var IsHandled: Boolean; var AvailabilityInfoBuffer: Record "Availability Info. Buffer")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeLookupGrossRequirement(var IsHandled: Boolean; var AvailabilityInfoBuffer: Record "Availability Info. Buffer")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeLookupScheduledReceipt(var IsHandled: Boolean; var AvailabilityInfoBuffer: Record "Availability Info. Buffer")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeLookupPlannedOrderReceipt(var IsHandled: Boolean; var AvailabilityInfoBuffer: Record "Availability Info. Buffer")
    begin
    end;
}

