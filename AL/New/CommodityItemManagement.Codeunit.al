codeunit 37002680 "Commodity Item Management"
{
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 24 AUG 10
    //   Add Commodity Class Costing granule
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013

    Permissions = TableData "Item Ledger Entry" = m,
                  TableData "Item Application Entry" = m;

    trigger OnRun()
    begin
    end;

    var
        OverrideCommVariance: Boolean;
        CommMatVarCost: Record "Cost Element Buffer";
        InvtSetupRetrieved: Boolean;
        InvtSetup: Record "Inventory Setup";
        Text000: Label 'You must define a %1 type Unit of Measure for %2 %3.';
        Text001: Label 'You cannot change %1 when Cost Components exist and have a Unit of Measure.';

    procedure ItemValidate(var Item: Record Item; ItemFieldNo: Integer)
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        with Item do
            case ItemFieldNo of
                FieldNo("Base Unit of Measure"),
              FieldNo("Alternate Unit of Measure"),
              FieldNo("Costing Unit"):
                    if "Commodity Cost Item" then
                        CheckItemUOM(Item);
                FieldNo("Costing Method"):
                    if ("Costing Method" <> "Costing Method"::Standard) then
                        TestField("Commodity Cost Item", false);
                FieldNo("Item Tracking Code"):
                    if ("Item Tracking Code" = '') then
                        TestField("Commodity Cost Item", false)
                    else
                        if "Commodity Cost Item" then begin
                            ItemTrackingCode.Get("Item Tracking Code");
                            ItemTrackingCode.TestField("Lot Specific Tracking", true);
                        end;
                FieldNo("Commodity Cost Item"):
                    if "Commodity Cost Item" then begin
                        CheckItemUOM(Item);
                        TestField("Costing Method", "Costing Method"::Standard);
                        TestField("Item Tracking Code");
                        ItemTrackingCode.Get("Item Tracking Code");
                        ItemTrackingCode.TestField("Lot Specific Tracking", true);
                    end;
            end;
    end;

    local procedure CheckItemUOM(var Item: Record Item)
    var
        ItemUOM: Record "Item Unit of Measure";
    begin
        GetItemUOM(Item, ItemUOM);
    end;

    procedure GetItemUOM(var Item: Record Item; var ItemUOM: Record "Item Unit of Measure")
    var
        ItemUOM2: Record "Item Unit of Measure";
    begin
        GetInvtSetup;
        with ItemUOM2 do begin
            SetRange("Item No.", Item."No.");
            case InvtSetup."Commodity UOM Type" of
                InvtSetup."Commodity UOM Type"::Weight:
                    SetRange(Type, Type::Weight);
                InvtSetup."Commodity UOM Type"::Volume:
                    SetRange(Type, Type::Volume);
            end;
            SetRange(Code, Item."Base Unit of Measure");
            if not FindFirst then begin
                SetRange(Code);
                if not FindFirst then
                    Error(Text000, InvtSetup."Commodity UOM Type", Item.TableCaption, Item."No.");
            end;
            TestField("Qty. per Unit of Measure");
            ItemUOM.Get("Item No.", Code);
        end;
    end;

    procedure GetItemBaseQtyPerUOM(var Item: Record Item; var FromUOM: Record "Item Unit of Measure"): Decimal
    var
        ItemUOM: Record "Item Unit of Measure";
        CommUOM: Record "Unit of Measure";
    begin
        with CommUOM do begin
            Get(FromUOM.Code);
            case InvtSetup."Commodity UOM Type" of
                InvtSetup."Commodity UOM Type"::Weight:
                    if (Type = Type::Weight) then
                        exit("Base per Unit of Measure");
                InvtSetup."Commodity UOM Type"::Volume:
                    if (Type = Type::Volume) then
                        exit("Base per Unit of Measure");
            end;
            GetItemUOM(Item, ItemUOM);
            Get(ItemUOM.Code);
            exit("Base per Unit of Measure" *
                 (FromUOM."Qty. per Unit of Measure" / ItemUOM."Qty. per Unit of Measure"));
        end;
    end;

    procedure CheckCommCostUOMTypeChg(var CurrInvtSetup: Record "Inventory Setup"; OldInvtSetup: Record "Inventory Setup")
    var
        CommCostComp: Record "Comm. Cost Component";
    begin
        if (CurrInvtSetup."Commodity UOM Type" <> OldInvtSetup."Commodity UOM Type") then begin
            CommCostComp.SetFilter("Unit of Measure Code", '<>%1', '');
            if not CommCostComp.IsEmpty then
                Error(Text001, CurrInvtSetup.FieldCaption("Commodity UOM Type"));
        end;
    end;

    procedure ItemJnlModify(var ItemJnlLine: Record "Item Journal Line")
    var
        Item: Record Item;
        ProdOrderCompLine: Record "Prod. Order Component";
        ProdBOMLine: Record "Production BOM Line";
    begin
        with ItemJnlLine do
            case "Entry Type" of
                "Entry Type"::Consumption:
                    if ("Commodity Class Code" <> '') then begin
                        TestField("Item No.");
                        Item.Get("Item No.");
                        Item.TestField("Commodity Cost Item", true);
                    end else
                        if ("Order No." <> '') and ("Prod. Order Comp. Line No." <> 0) then // P8001132
                            if ProdOrderCompLine.Get(
                                 ProdOrderCompLine.Status::Released,
                                 "Order No.", "Order Line No.", "Prod. Order Comp. Line No.")   // P8001132
                            then
                                if ProdBOMLine.Get(
                                     ProdOrderCompLine."Production BOM No.",
                                     ProdOrderCompLine."Production BOM Version Code",
                                     ProdOrderCompLine."Production BOM Line No.")
                                then
                                    "Commodity Class Code" := ProdBOMLine."Commodity Class Code";
            end;
    end;

    procedure ProdBOMLineValidate(var ProdBOMLine: Record "Production BOM Line"; LineFieldNo: Integer)
    var
        Item: Record Item;
    begin
        with ProdBOMLine do
            case LineFieldNo of
                FieldNo("No."):
                    if (Type <> Type::Item) or ("No." = '') then
                        "Commodity Class Code" := ''
                    else begin
                        Item.Get("No.");
                        if not Item."Commodity Cost Item" then
                            "Commodity Class Code" := '';
                    end;
                FieldNo("Commodity Class Code"):
                    if ("Commodity Class Code" <> '') then begin
                        TestField(Type, Type::Item);
                        TestField("No.");
                        Item.Get("No.");
                        Item.TestField("Commodity Cost Item", true);
                    end;
            end;
    end;

    procedure CheckCommCostLocations()
    var
        CommCostPeriod: Record "Commodity Cost Period";
    begin
        with CommCostPeriod do
            if FindSet then
                repeat
                    TestField("Location Code", '');
                until (Next = 0);
    end;

    procedure InsertingItemApplForEntry(var ItemLedgEntry: Record "Item Ledger Entry")
    begin
        with ItemLedgEntry do
            if ("Commodity Class Code" <> '') then
                RecalcCommCostForDate("Location Code", "Posting Date");
    end;

    procedure AdjustPurchVariance(var InbndItemLedgEntry: Record "Item Ledger Entry"; var VarAmt: Decimal; var VarAmtACY: Decimal)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if GetPosItemApplEntry(InbndItemLedgEntry."Entry No.", ItemApplnEntry) then
            with ItemApplnEntry do
                if "Commodity Cost Calculated" then begin
                    VarAmt := VarAmt + "Comm. Cost Adjmt.";
                    VarAmtACY := VarAmtACY + "Comm. Cost Adjmt. (ACY)";
                end;
    end;

    procedure UpdatePeriodOnQCTest(var LotSpec: Record "Lot Specification")
    var
        NegItemLedgEntry: Record "Item Ledger Entry";
    begin
        with NegItemLedgEntry do begin
            SetCurrentKey("Item No.", "Variant Code", "Lot No.", Positive, "Posting Date");
            SetRange("Item No.", LotSpec."Item No.");
            SetRange("Variant Code", LotSpec."Variant Code");
            SetRange("Lot No.", LotSpec."Lot No.");
            SetRange(Positive, false);
            SetFilter("Commodity Class Code", '<>%1', '');
            if FindSet then
                repeat
                    RecalcCommCostForDate("Location Code", "Posting Date");
                until (Next = 0);
        end;
    end;

    local procedure RecalcCommCostForDate(LocationCode: Code[10]; PostingDate: Date)
    var
        CommCostPeriod: Record "Commodity Cost Period";
    begin
        GetInvtSetup;
        with CommCostPeriod do begin
            if InvtSetup."Commodity Cost by Location" then
                SetRange("Location Code", LocationCode);
            SetRange("Starting Market Date", 0D, PostingDate);
            if FindLast then
                if not "Calculate Cost" then begin
                    "Calculate Cost" := true;
                    Modify;
                end;
        end;
    end;

    procedure RemoveItemApplAdjmts(var CostElementBuf: Record "Cost Element Buffer"; var InbndItemLedgEntry: Record "Item Ledger Entry"; ExactCostReversing: Boolean)
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if GetPosItemApplEntry(InbndItemLedgEntry."Entry No.", ItemApplnEntry) then
            with ItemApplnEntry do
                if "Commodity Cost Calculated" then
                    AddCostElementAdjmt(
                      CostElementBuf, ExactCostReversing, -"Comm. Cost Adjmt.", -"Comm. Cost Adjmt. (ACY)");
    end;

    procedure GetPosItemApplEntry(InbndItemLedgEntryNo: Integer; var ItemApplnEntry: Record "Item Application Entry"): Boolean
    begin
        with ItemApplnEntry do begin
            Reset;
            SetCurrentKey("Inbound Item Entry No.", "Item Ledger Entry No.", "Outbound Item Entry No.", "Cost Application");
            SetRange("Inbound Item Entry No.", InbndItemLedgEntryNo);
            SetRange("Item Ledger Entry No.", InbndItemLedgEntryNo);
            SetRange("Cost Application", true);
            exit(FindFirst);
        end;
    end;

    procedure AddItemApplAdjmt(var CostElementBuf: Record "Cost Element Buffer"; var ItemApplnEntry: Record "Item Application Entry"; ExactCostReversing: Boolean)
    begin
        with ItemApplnEntry do
            if "Commodity Cost Calculated" then begin
                AddCostElementAdjmt(CostElementBuf, ExactCostReversing, "Comm. Cost Adjmt.", "Comm. Cost Adjmt. (ACY)");
                AddCostAdjmt(CostElementBuf, CostElementBuf.Type::Total, "Comm. Cost Adjmt.", "Comm. Cost Adjmt. (ACY)");
            end;
    end;

    local procedure AddCostElementAdjmt(var CostElementBuf: Record "Cost Element Buffer"; ExactCostReversing: Boolean; CostAdjmt: Decimal; CostAdjmtACY: Decimal)
    var
        CostExists: Boolean;
    begin
        if not ExactCostReversing then
            AddCostAdjmt(CostElementBuf, CostElementBuf.Type::"Direct Cost", CostAdjmt, CostAdjmtACY)
        else
            AddCostAdjmt(CostElementBuf, CostElementBuf.Type::Variance, CostAdjmt, CostAdjmtACY);
    end;

    local procedure AddCostAdjmt(var CostElementBuf: Record "Cost Element Buffer"; CostElementType: Integer; CostAdjmt: Decimal; CostAdjmtACY: Decimal)
    var
        CostExists: Boolean;
    begin
        if (CostAdjmt <> 0) or (CostAdjmtACY <> 0) then
            with CostElementBuf do begin
                CostExists := Retrieve(CostElementType, 0);
                "Actual Cost" := "Actual Cost" + CostAdjmt;
                "Actual Cost (ACY)" := "Actual Cost (ACY)" + CostAdjmtACY;
                if CostExists then
                    Modify
                else
                    Insert;
            end;
    end;

    procedure InitCommVarianceAdjust(var CurrEntryCostBuf: Record "Cost Element Buffer"; var ProdOrderCostBuf: Record "Cost Element Buffer"; ShareOfTotalCost: Decimal; AmtRndgPrec: Decimal; AmtRndgPrecACY: Decimal)
    var
        NewEntryCostBuf: Record "Cost Element Buffer" temporary;
    begin
        OverrideCommVariance := false;
        if (ShareOfTotalCost <> 0) then
            with CurrEntryCostBuf do
                if Retrieve(Type::"Direct Cost", 0) then
                    OverrideCommVariance := ("Actual Cost" <> 0) or ("Actual Cost (ACY)" <> 0);
        if OverrideCommVariance then begin
            with ProdOrderCostBuf do begin
                if not Retrieve(Type::Variance, "Variance Type"::Material) then
                    Insert;
                FindSet;
            end;
            with NewEntryCostBuf do begin
                repeat
                    NewEntryCostBuf := ProdOrderCostBuf;
                    RoundCost(NewEntryCostBuf, "Actual Cost", ShareOfTotalCost, "Rounding Residual", AmtRndgPrec);
                    RoundCost(NewEntryCostBuf, "Actual Cost (ACY)", ShareOfTotalCost, "Rounding Residual (ACY)", AmtRndgPrecACY);
                    CurrEntryCostBuf.Retrieve(Type, "Variance Type");
                    "Actual Cost" := "Actual Cost" - CurrEntryCostBuf."Actual Cost";
                    "Actual Cost (ACY)" := "Actual Cost (ACY)" - CurrEntryCostBuf."Actual Cost (ACY)";
                    Insert;
                until (ProdOrderCostBuf.Next = 0);
                Retrieve(Type::Variance, "Variance Type"::Material);
                CommMatVarCost := NewEntryCostBuf;
                CalcSums("Actual Cost", "Actual Cost (ACY)");
                CommMatVarCost."Actual Cost" := CommMatVarCost."Actual Cost" - "Actual Cost";
                CommMatVarCost."Actual Cost (ACY)" := CommMatVarCost."Actual Cost (ACY)" - "Actual Cost (ACY)";
            end;
        end;
    end;

    local procedure RoundCost(var NewEntryCostBuf: Record "Cost Element Buffer" temporary; var ActualCost: Decimal; ShareOfTotalCost: Decimal; var RoundingResidual: Decimal; AmtRndgPrec: Decimal)
    var
        NewCost: Decimal;
    begin
        with NewEntryCostBuf do begin
            NewCost := ActualCost * ShareOfTotalCost + RoundingResidual;
            ActualCost := Round(NewCost, AmtRndgPrec);
            RoundingResidual := NewCost - ActualCost;
        end;
    end;

    procedure AdjustCommVariance(var ProdOrderCostBuf: Record "Cost Element Buffer"; var NewAdjustedCost: Decimal; var NewAdjustedCostACY: Decimal)
    begin
        if OverrideCommVariance then
            with ProdOrderCostBuf do
                if (Type = Type::Variance) and ("Variance Type" = "Variance Type"::Material) then begin
                    NewAdjustedCost := CommMatVarCost."Actual Cost";
                    NewAdjustedCostACY := CommMatVarCost."Actual Cost (ACY)";
                end;
    end;

    local procedure GetInvtSetup()
    begin
        if not InvtSetupRetrieved then begin
            InvtSetup.Get;
            InvtSetupRetrieved := true;
        end;
    end;
}

