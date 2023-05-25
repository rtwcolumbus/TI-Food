page 99000902 "Item Availability Line List"
{
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRw17.00.01
    // P8001158, Columbus IT, Jack Reynolds, 23 MAY 13
    //   Fix problem insertgin entries into the source table

    Caption = 'Item Availability Line List';
    Editable = false;
    PageType = List;
    SourceTable = "Item Availability Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name for this entry.';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Quantity Available';
                    ToolTip = 'Specifies the quantity for this entry.';

                    trigger OnDrillDown()
                    begin
                        LookupEntries;
                    end;
                }
                field("Quantity Not Available"; "Quantity Not Available")
                {
                    ApplicationArea = FOODBasic;
                    Visible = NotAvailVisible;

                    trigger OnDrillDown()
                    begin
                        // P8001083
                        LookupEntries();
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        DeleteAll();
        MakeWhat();
    end;

    var
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        ServLine: Record "Service Line";
        JobPlanningLine: Record "Job Planning Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        ReqLine: Record "Requisition Line";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        PlanningComponent: Record "Planning Component";
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        AvailType: Option "Gross Requirement","Planned Order Receipt","Scheduled Order Receipt","Planned Order Release",All;
        Sign: Integer;
        QtyByUnitOfMeasure: Decimal;
        ItemTotal: Record Item;
        LotStatusMgmt: Codeunit "Lot Status Management";
        SalesReturnOrderTotal: Integer;
        LotStatusExclusionFilter: Text[1024];
        ExcludePurch: Boolean;
        ExcludeSalesRet: Boolean;
        ExcludeOutput: Boolean;
        [InDataSet]
        NotAvailVisible: Boolean;

        Text000: Label '%1 Receipt';
        Text001: Label '%1 Release';
        Text002: Label 'Firm planned %1';
        Text003: Label 'Released %1';

    procedure Init(NewType: Option "Gross Requirement","Planned Order Receipt","Scheduled Order Receipt","Planned Order Release",All; var NewItem: Record Item)
    begin
        AvailType := NewType;
        Item.Copy(NewItem);
        NotAvailVisible := not (AvailType in [AvailType::All, AvailType::"Gross Requirement"]); // P8001083
    end;

    local procedure MakeEntries()
    begin
        case AvailType of
            AvailType::"Gross Requirement":
                begin
                    InsertEntry(
                      DATABASE::"Sales Line",
                      Item.FieldNo("Qty. on Sales Order"),
                      SalesLine.TableCaption(),
                      Item."Qty. on Sales Order", 0); // P8001083
                    InsertEntry(
                      DATABASE::"Service Line",
                      Item.FieldNo("Qty. on Service Order"),
                      ServLine.TableCaption(),
                      Item."Qty. on Service Order", 0); // P8001083
                    InsertEntry(
                      DATABASE::"Job Planning Line",
                      Item.FieldNo("Qty. on Job Order"),
                      JobPlanningLine.TableCaption(),
                      Item."Qty. on Job Order", 0); // P8001132
                    InsertEntry(
                      DATABASE::"Prod. Order Component",
                      Item.FieldNo("Qty. on Component Lines"),
                      ProdOrderComp.TableCaption(),
                      Item."Qty. on Component Lines", 0); // P8001083
                    InsertEntry(
                      DATABASE::"Planning Component",
                      Item.FieldNo("Planning Issues (Qty.)"),
                      PlanningComponent.TableCaption(),
                      Item."Planning Issues (Qty.)", 0); // P8001083
                    InsertEntry(
                      DATABASE::"Transfer Line",
                      Item.FieldNo("Trans. Ord. Shipment (Qty.)"),
                      Item.FieldCaption("Trans. Ord. Shipment (Qty.)"),
                      Item."Trans. Ord. Shipment (Qty.)", 0); // P8001083
                    InsertEntry(
                      DATABASE::"Purchase Line",
                      0,
                      PurchLine.TableCaption(),
                      Item."Qty. on Purch. Return", 0); // P8001083
                    InsertEntry(
                      DATABASE::"Assembly Line",
                      Item.FieldNo("Qty. on Asm. Component"),
                      AssemblyLine.TableCaption(),
                      Item."Qty. on Asm. Component", 0); // P8001132
                end;
            AvailType::"Planned Order Receipt":
                begin
                    InsertEntry(
                      DATABASE::"Requisition Line",
                      Item.FieldNo("Purch. Req. Receipt (Qty.)"),
                      ReqLine.TableCaption(),
                      Item."Purch. Req. Receipt (Qty.)", // P8001083
                      ItemTotal."Purch. Req. Receipt (Qty.)" - Item."Purch. Req. Receipt (Qty.)"); // P8001083
                    InsertEntry(
                      DATABASE::"Prod. Order Line",
                      Item.FieldNo("Planned Order Receipt (Qty.)"),
                      StrSubstNo(Text000, ProdOrderLine.TableCaption()),
                      Item."Planned Order Receipt (Qty.)", // P8001083
                      ItemTotal."Planned Order Receipt (Qty.)" - Item."Planned Order Receipt (Qty.)"); // P8001083
                end;
            AvailType::"Planned Order Release":
                begin
                    InsertEntry(
                      DATABASE::"Requisition Line",
                      Item.FieldNo("Purch. Req. Release (Qty.)"),
                      ReqLine.TableCaption(),
                      Item."Purch. Req. Release (Qty.)", // P8001083
                      ItemTotal."Purch. Req. Release (Qty.)" - Item."Purch. Req. Release (Qty.)"); // P8001083
                    InsertEntry(
                      DATABASE::"Prod. Order Line",
                      Item.FieldNo("Planned Order Release (Qty.)"),
                      StrSubstNo(Text001, ProdOrderLine.TableCaption()),
                      Item."Planned Order Release (Qty.)", // P8001083
                      ItemTotal."Planned Order Release (Qty.)" - Item."Planned Order Release (Qty.)"); // P8001083
                    InsertEntry(
                      DATABASE::"Requisition Line",
                      Item.FieldNo("Planning Release (Qty.)"),
                      ReqLine.TableCaption(),
                      Item."Planning Release (Qty.)", // P8001083
                      ItemTotal."Planning Release (Qty.)" - Item."Planning Release (Qty.)"); // P8001083
                end;
            AvailType::"Scheduled Order Receipt":
                begin
                    InsertEntry(
                      DATABASE::"Purchase Line",
                      Item.FieldNo("Qty. on Purch. Order"),
                      PurchLine.TableCaption(),
                      Item."Qty. on Purch. Order", // P8001083
                      ItemTotal."Qty. on Purch. Order" - Item."Qty. on Purch. Order"); // P8001083
                    InsertEntry(
                      DATABASE::"Prod. Order Line",
                      Item.FieldNo("FP Order Receipt (Qty.)"),
                      StrSubstNo(Text002, ProdOrderLine.TableCaption()),
                      Item."FP Order Receipt (Qty.)", // P8001083
                      ItemTotal."FP Order Receipt (Qty.)" - Item."FP Order Receipt (Qty.)"); // P8001083
                    InsertEntry(
                      DATABASE::"Prod. Order Line",
                      Item.FieldNo("Rel. Order Receipt (Qty.)"),
                      StrSubstNo(Text003, ProdOrderLine.TableCaption()),
                      Item."Rel. Order Receipt (Qty.)", // P8001083
                      ItemTotal."Rel. Order Receipt (Qty.)" - Item."Rel. Order Receipt (Qty.)"); // P8001083
                    InsertEntry(
                      DATABASE::"Transfer Line",
                      Item.FieldNo("Qty. in Transit"),
                      Item.FieldCaption("Qty. in Transit"),
                      Item."Qty. in Transit", // P8001083
                      ItemTotal."Qty. in Transit" - Item."Qty. in Transit"); // P8001083
                    InsertEntry(
                      DATABASE::"Transfer Line",
                      Item.FieldNo("Trans. Ord. Receipt (Qty.)"),
                      Item.FieldCaption("Trans. Ord. Receipt (Qty.)"),
                      Item."Trans. Ord. Receipt (Qty.)", // P8001083
                      ItemTotal."Trans. Ord. Receipt (Qty.)" - Item."Trans. Ord. Receipt (Qty.)"); // P8001083
                    InsertEntry(
                      DATABASE::"Sales Line",
                      0,
                      SalesLine.TableCaption(),
                      Item."Qty. on Sales Return",
                      ItemTotal."Qty. on Sales Return" - Item."Qty. on Sales Return"); // P8001083
                    InsertEntry(
                      DATABASE::"Assembly Header",
                      Item.FieldNo("Qty. on Assembly Order"),
                      AssemblyHeader.TableCaption(),
                      Item."Qty. on Assembly Order", 0); // P8001132
                end;
        end;

        OnAfterMakeEntries(Item, Rec, AvailType, Sign);
    end;

    local procedure MakeWhat()
    begin
        Sign := 1;
        if AvailType <> AvailType::All then
            MakeEntries()
        else begin
            Item.SetRange("Date Filter", 0D, Item.GetRangeMax("Date Filter"));
            OnItemSetFilter(Item);
            Item.CalcFields(Inventory); // P8001023, P8001132
            Item.CalcFields(
              "Qty. on Purch. Order",
              "Qty. on Sales Order",
              "Qty. on Service Order",
              "Qty. on Job Order",
              "Net Change",
              "Scheduled Receipt (Qty.)",
              "Qty. on Component Lines",
              "Planned Order Receipt (Qty.)",
              "FP Order Receipt (Qty.)",
              "Rel. Order Receipt (Qty.)",
              "Planned Order Release (Qty.)",
              "Purch. Req. Receipt (Qty.)",
              "Planning Issues (Qty.)",
              "Purch. Req. Release (Qty.)",
              "Qty. in Transit");
            Item.CalcFields(
              "Trans. Ord. Shipment (Qty.)",
              "Trans. Ord. Receipt (Qty.)",
              "Qty. on Assembly Order",
              "Qty. on Asm. Component",
              "Qty. on Purch. Return",
              "Qty. on Sales Return");

            OnItemCalcFields(Item);

            // P8001083
            ItemTotal := Item;
            LotStatusMgmt.AdjustItemFlowFields(Item, LotStatusExclusionFilter, true, Item.GetFilter("Location Filter") <> '', 0,
              ExcludePurch, ExcludeSalesRet, ExcludeOutput);
            // P8001083
            if (Item.Inventory <> 0) or (ItemTotal.Inventory <> 0) then begin // P8001083
                "Table No." := DATABASE::"Item Ledger Entry";
                QuerySource := Item.FieldNo(Inventory);
                Name := ItemLedgerEntry.TableCaption();
                Quantity := AdjustWithQtyByUnitOfMeasure(Item.Inventory);
                "Quantity Not Available" := AdjustWithQtyByUnitOfMeasure(ItemTotal.Inventory - Item.Inventory); // P8001083
                Insert();
            end;
            AvailType := AvailType::"Gross Requirement";
            Sign := -1;
            MakeEntries();
            AvailType := AvailType::"Planned Order Receipt";
            Sign := 1;
            MakeEntries();
            AvailType := AvailType::"Scheduled Order Receipt";
            Sign := 1;
            MakeEntries();
            AvailType := AvailType::All;
        end;
    end;

    local procedure LookupEntries()
    var
        ItemLedgerEntries: Page "Item Ledger Entries";
        TransferLines: Page "Transfer Lines";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeLookupEntries(Rec, Item, IsHandled);
        if IsHandled then
            exit;
	    
        case "Table No." of
            DATABASE::"Item Ledger Entry":
                begin
                    ItemLedgerEntry.SetCurrentKey("Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");
                    ItemLedgerEntry.SetRange("Item No.", Item."No.");
                    ItemLedgerEntry.SetFilter("Variant Code", Item.GetFilter("Variant Filter"));
                    ItemLedgerEntry.SetFilter("Drop Shipment", Item.GetFilter("Drop Shipment Filter"));
                    ItemLedgerEntry.SetFilter("Location Code", Item.GetFilter("Location Filter"));
                    ItemLedgerEntry.SetFilter("Global Dimension 1 Code", Item.GetFilter("Global Dimension 1 Filter"));
                    ItemLedgerEntry.SetFilter("Global Dimension 2 Code", Item.GetFilter("Global Dimension 2 Filter"));
                    ItemLedgerEntry.SetFilter("Unit of Measure Code", Item.GetFilter("Unit of Measure Filter"));
                    OnItemLedgerEntrySetFilter(ItemLedgerEntry);
                    // P8001083
                    //PAGE.RUNMODAL(0,ItemLedgerEntry);
                    ItemLedgerEntries.SetTableView(ItemLedgerEntry);
                    ItemLedgerEntries.SetLotStatus(LotStatusExclusionFilter);
                    ItemLedgerEntries.RunModal;
                    // P8001083
                end;
            DATABASE::"Sales Line":
                begin
                    if QuerySource > 0 then
                        SalesLine.FindLinesWithItemToPlan(Item, SalesLine."Document Type"::Order)
                    else
                        SalesLine.FindLinesWithItemToPlan(Item, SalesLine."Document Type"::"Return Order");
                    SalesLine.SetRange("Drop Shipment", false);
                    PAGE.RunModal(0, SalesLine);
                end;
            DATABASE::"Service Line":
                begin
                    ServLine.FindLinesWithItemToPlan(Item);
                    PAGE.RunModal(0, ServLine);
                end;
            DATABASE::"Job Planning Line":
                begin
                    JobPlanningLine.FindLinesWithItemToPlan(Item);
                    PAGE.RunModal(0, JobPlanningLine);
                end;
            DATABASE::"Purchase Line":
                begin
                    PurchLine.SetCurrentKey("Document Type", Type, "No.");
                    if QuerySource > 0 then
                        PurchLine.FindLinesWithItemToPlan(Item, PurchLine."Document Type"::Order)
                    else
                        PurchLine.FindLinesWithItemToPlan(Item, PurchLine."Document Type"::"Return Order");
                    PurchLine.SetRange("Drop Shipment", false);
                    OnLookupEntriesOnAfterPurchLineSetFilters(Item, PurchLine);
                    PAGE.RunModal(0, PurchLine);
                end;
            DATABASE::"Transfer Line":
                begin
                    case QuerySource of
                        Item.FieldNo("Trans. Ord. Shipment (Qty.)"):
                            TransLine.FindLinesWithItemToPlan(Item, false, false);
                        Item.FieldNo("Trans. Ord. Receipt (Qty.)"), Item.FieldNo("Qty. in Transit"):
                            begin // P8001132
                                TransLine.FindLinesWithItemToPlan(Item, true, false);
                                TransferLines.SetLotStatus(LotStatusExclusionFilter); // P8001083
                            end; // P8001132
                    end;
                    // P8001083
                    //FORM.RUNMODAL(0,TransLine);
                    TransferLines.SetTableView(TransLine);
                    TransferLines.RunModal;
                    // P8001083
                end;
            DATABASE::"Planning Component":
                begin
                    PlanningComponent.FindLinesWithItemToPlan(Item);
                    PAGE.RunModal(0, PlanningComponent);
                end;
            DATABASE::"Prod. Order Component":
                begin
                    ProdOrderComp.FindLinesWithItemToPlan(Item, true);
                    PAGE.RunModal(0, ProdOrderComp);
                end;
            DATABASE::"Requisition Line":
                begin
                    ReqLine.FindLinesWithItemToPlan(Item);
                    case QuerySource of
                        Item.FieldNo("Purch. Req. Receipt (Qty.)"):
                            Item.CopyFilter("Date Filter", ReqLine."Due Date");
                        Item.FieldNo("Purch. Req. Release (Qty.)"):
                            begin
                                Item.CopyFilter("Date Filter", ReqLine."Order Date");
                                ReqLine.SetFilter("Planning Line Origin", '%1|%2',
                                  ReqLine."Planning Line Origin"::" ", ReqLine."Planning Line Origin"::Planning);
                            end;
                    end;
                    PAGE.RunModal(0, ReqLine);
                end;
            DATABASE::"Prod. Order Line":
                begin
                    ProdOrderLine.Reset();
                    ProdOrderLine.SetCurrentKey(Status, "Item No.");
                    case QuerySource of
                        Item.FieldNo("Planned Order Receipt (Qty.)"):
                            begin
                                ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Planned);
                                Item.CopyFilter("Date Filter", ProdOrderLine."Due Date");
                            end;
                        Item.FieldNo("Planned Order Release (Qty.)"):
                            begin
                                ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Planned);
                                Item.CopyFilter("Date Filter", ProdOrderLine."Starting Date");
                            end;
                        Item.FieldNo("FP Order Receipt (Qty.)"):
                            begin
                                ProdOrderLine.SetRange(Status, ProdOrderLine.Status::"Firm Planned");
                                Item.CopyFilter("Date Filter", ProdOrderLine."Due Date");
                            end;
                        Item.FieldNo("Rel. Order Receipt (Qty.)"):
                            begin
                                ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Released);
                                Item.CopyFilter("Date Filter", ProdOrderLine."Due Date");
                            end;
                    end;
                    ProdOrderLine.SetRange("Item No.", Item."No.");
                    Item.CopyFilter("Variant Filter", ProdOrderLine."Variant Code");
                    Item.CopyFilter("Location Filter", ProdOrderLine."Location Code");
                    Item.CopyFilter("Global Dimension 1 Filter", ProdOrderLine."Shortcut Dimension 1 Code");
                    Item.CopyFilter("Global Dimension 2 Filter", ProdOrderLine."Shortcut Dimension 2 Code");
                    Item.CopyFilter("Unit of Measure Filter", ProdOrderLine."Unit of Measure Code");
                    PAGE.RunModal(0, ProdOrderLine);
                end;
            DATABASE::"Assembly Header":
                begin
                    AssemblyHeader.FindItemToPlanLines(Item, AssemblyHeader."Document Type"::Order);
                    PAGE.RunModal(0, AssemblyHeader);
                end;
            DATABASE::"Assembly Line":
                begin
                    AssemblyLine.FindItemToPlanLines(Item, AssemblyHeader."Document Type"::Order);
                    PAGE.RunModal(0, AssemblyLine);
                end;
            else
                OnLookupExtensionTable(Item, "Table No.", QuerySource, SalesLine);
        end;

        OnAfterLookupEntries(Item, "Table No.", Rec);
    end;

    procedure InsertEntry("Table": Integer; "Field": Integer; TableName: Text[100]; Qty: Decimal; QtyNotAvail: Decimal)
    begin
        // P8001083 - add parameter for QtyNotAvail
        if not NotAvailVisible then // P8001083
            QtyNotAvail := 0;         // P8001083
        if (Qty = 0) and (QtyNotAvail = 0) then // P8001083, P8001158
            exit;

        "Table No." := Table;
        QuerySource := Field;
        Name := CopyStr(TableName, 1, MaxStrLen(Name));
        Quantity := AdjustWithQtyByUnitOfMeasure(Qty * Sign);
        "Quantity Not Available" := AdjustWithQtyByUnitOfMeasure(QtyNotAvail * Sign); // P8001083
        Insert();
    end;

    local procedure AdjustWithQtyByUnitOfMeasure(Quantity: Decimal): Decimal
    begin
        if QtyByUnitOfMeasure <> 0 then
            exit(Quantity / QtyByUnitOfMeasure);
        exit(Quantity);
    end;

    procedure SetQtyByUnitOfMeasure(NewQtyByUnitOfMeasure: Decimal);
    begin
        QtyByUnitOfMeasure := NewQtyByUnitOfMeasure;
    end;

    procedure InitLotStatus(var NewItemTotal: Record Item; "Filter": Text[1024]; Purch: Boolean; Sales: Boolean; Output: Boolean)
    begin
        // P8001083
        ItemTotal.Copy(NewItemTotal);
        LotStatusExclusionFilter := Filter;
        ExcludePurch := Purch;
        ExcludeSalesRet := Sales;
        ExcludeOutput := Output;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnItemCalcFields(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnItemSetFilter(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnItemLedgerEntrySetFilter(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMakeEntries(var Item: Record Item; var ItemAvailabilityLine: Record "Item Availability Line"; AvailabilityType: Option; Sign: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterLookupEntries(var Item: Record Item; TableID: Integer; ItemAvailabilityLine: Record "Item Availability Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupExtensionTable(var Item: Record Item; TableID: Integer; QuerySource: Integer; SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLookupEntries(ItemAvailabilityLine: Record "Item Availability Line"; var Item: Record Item; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupEntriesOnAfterPurchLineSetFilters(var Item: Record Item; var PurchLine: Record "Purchase Line")
    begin
    end;
}

