table 99000850 "Planning Assignment"
{
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // PRW110.0.02
    // P80050544, To-Increase, Dayakar Battini, 16 JAN 18
    //   Upgrade to 2017 CU13 - ChkAssignOne modifications reverted to standard coding

    Caption = 'Planning Assignment';
    Permissions = TableData "Planning Assignment" = rimd;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(3; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(10; "Latest Date"; Date)
        {
            Caption = 'Latest Date';
        }
        field(12; Inactive; Boolean)
        {
            Caption = 'Inactive';
        }
        field(13; "Action Msg. Response Planning"; Boolean)
        {
            Caption = 'Action Msg. Response Planning';

            trigger OnValidate()
            begin
                if "Action Msg. Response Planning" then
                    Inactive := false;
            end;
        }
        field(14; "Net Change Planning"; Boolean)
        {
            Caption = 'Net Change Planning';

            trigger OnValidate()
            begin
                if "Net Change Planning" then
                    Inactive := false;
            end;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Location Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        ManufacturingSetup: Record "Manufacturing Setup";
        InvtSetup: Record "Inventory Setup";

    procedure ItemChange(var NewItem: Record Item; var OldItem: Record Item)
    begin
        if NewItem."Reordering Policy" = NewItem."Reordering Policy"::" " then
            if OldItem."Reordering Policy" <> OldItem."Reordering Policy"::" " then
                AnnulAllAssignment(NewItem."No.")
            else
                exit
        else
            if PlanningParametersChanged(NewItem, OldItem) then begin
                ManufacturingSetup.Get();
                InvtSetup.Get();
                if (ManufacturingSetup."Components at Location" <> '') or
                   not InvtSetup."Location Mandatory"
                then
                    AssignOne(NewItem."No.", '', ManufacturingSetup."Components at Location", WorkDate);
            end;

    end;

    local procedure PlanningParametersChanged(NewItem: Record Item; OldItem: Record Item) Result: Boolean
    begin
        Result := (NewItem."Safety Stock Quantity" <> OldItem."Safety Stock Quantity") or
               (NewItem."Safety Lead Time" <> OldItem."Safety Lead Time") or
               (NewItem."Lead Time Calculation" <> OldItem."Lead Time Calculation") or
               (NewItem."Reorder Point" <> OldItem."Reorder Point") or
               (NewItem."Reordering Policy" <> OldItem."Reordering Policy") or
               (NewItem."Replenishment System" <> OldItem."Replenishment System") or
               (NewItem."Include Inventory" <> OldItem."Include Inventory");
        OnAfterPlanningParametersChanged(NewItem, OldItem, Result);
    end;

    procedure SKUChange(var NewSKU: Record "Stockkeeping Unit"; var OldSKU: Record "Stockkeeping Unit")
    begin
        if NewSKU."Reordering Policy" = NewSKU."Reordering Policy"::" " then
            if OldSKU."Reordering Policy" <> OldSKU."Reordering Policy"::" " then begin
                SetRange("Item No.", NewSKU."Item No.");
                SetRange("Variant Code", NewSKU."Variant Code");
                SetRange("Location Code", NewSKU."Location Code");
                if Find then begin
                    "Net Change Planning" := false;
                    Modify;
                end;
            end else
                exit
        else
            if PlanningSKUParametersChanged(NewSKU, OldSKU) then
                AssignOne(NewSKU."Item No.", NewSKU."Variant Code", NewSKU."Location Code", WorkDate());
    end;

    local procedure PlanningSKUParametersChanged(NewSKU: Record "Stockkeeping Unit"; OldSKU: Record "Stockkeeping Unit") Result: Boolean
    begin
        Result := (NewSKU."Safety Stock Quantity" <> OldSKU."Safety Stock Quantity") or
                (NewSKU."Safety Lead Time" <> OldSKU."Safety Lead Time") or
                (NewSKU."Lead Time Calculation" <> OldSKU."Lead Time Calculation") or
                (NewSKU."Reorder Point" <> OldSKU."Reorder Point") or
                (NewSKU."Reordering Policy" <> OldSKU."Reordering Policy") or
                (NewSKU."Replenishment System" <> OldSKU."Replenishment System") or
                (NewSKU."Include Inventory" <> OldSKU."Include Inventory");

        OnAfterPlanningSKUParametersChanged(NewSKU, OldSKU, Result);
    end;

    procedure RoutingReplace(var Item: Record Item; OldRoutingNo: Code[20])
    var
        SKU: Record "Stockkeeping Unit";
    begin
        if OldRoutingNo <> Item."Routing No." then begin // P8001030
            if Item."Reordering Policy" <> Item."Reordering Policy"::" " then
                AssignPlannedOrders(Item."No.", true, false, ''); // P8001030
                                                                  // P8001030
            SKU.SetCurrentKey("Item No.");
            SKU.SetRange("Item No.", Item."No.");
            SKU.SetFilter("Reordering Policy", '<>%1', SKU."Reordering Policy"::" ");
            SKU.SetRange("Routing No.", '');
            if SKU.FindSet then
                repeat
                    AssignPlannedOrdersForSKU(SKU);
                until SKU.Next = 0;
        end;
        // P8001030
    end;

    procedure BomReplace(var Item: Record Item; OldProductionBOMNo: Code[20])
    var
        SKU: Record "Stockkeeping Unit";
    begin
        if OldProductionBOMNo <> Item."Production BOM No." then begin
            if Item."Reordering Policy" <> Item."Reordering Policy"::" " then
                AssignPlannedOrders(Item."No.", true, false, ''); // P8001030
                                                                  // P8001030
            SKU.SetCurrentKey("Item No.");
            SKU.SetRange("Item No.", Item."No.");
            SKU.SetFilter("Reordering Policy", '<>%1', SKU."Reordering Policy"::" ");
            SKU.SetRange("Production BOM No.", '');
            if SKU.FindSet then
                repeat
                    AssignPlannedOrdersForSKU(SKU);
                until SKU.Next = 0;
            // P8001030
            if OldProductionBOMNo <> '' then
                OldBom(OldProductionBOMNo);
        end;
    end;

    procedure OldBom(ProductionBOMNo: Code[20])
    var
        Item: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMVersion: Record "Production BOM Version";
        ProductionBOMLine: Record "Production BOM Line";
        UseVersions: Boolean;
        EndLoop: Boolean;
    begin
        ProductionBOMVersion.SetRange("Production BOM No.", ProductionBOMNo);
        ProductionBOMVersion.SetRange(Status, ProductionBOMVersion.Status::Certified);
        UseVersions := ProductionBOMVersion.FindSet();

        if ProductionBOMHeader.Get(ProductionBOMNo) and
           (ProductionBOMHeader.Status = ProductionBOMHeader.Status::Certified)
        then begin
            ProductionBOMVersion."Production BOM No." := ProductionBOMHeader."No.";
            ProductionBOMVersion."Version Code" := '';
        end else
            if not ProductionBOMVersion.FindSet() then
                exit;

        repeat
            ProductionBOMLine.SetRange("Production BOM No.", ProductionBOMVersion."Production BOM No.");
            ProductionBOMLine.SetRange("Version Code", ProductionBOMVersion."Version Code");
            if ProductionBOMLine.FindSet() then
                repeat
                    // P8001030
                    //if ProductionBOMLine.Type = ProductionBOMLine.Type::Item then begin
                    //  if Item.Get(ProductionBOMLine."No.") then
                    //    if Item."Reordering Policy" <> Item."Reordering Policy"::" " then
                    //      AssignPlannedOrders(ProductionBOMLine."No.", false);
                    //end else
                    //  if ProductionBOMLine.Type = ProductionBOMLine.Type::"Production BOM" then
                    //    OldBom(ProductionBOMLine."No.");
                    AssignForBOMLine(ProductionBOMLine);
                    // P8001030
                until ProductionBOMLine.Next() = 0;
            if UseVersions then
                EndLoop := ProductionBOMVersion.Next() = 0
            else
                EndLoop := true;
        until EndLoop;
    end;

    procedure NewBOM(ProductionBOMNo: Code[20])
    var
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
    begin
        Item.SetCurrentKey("Production BOM No.");
        Item.SetRange("Production BOM No.", ProductionBOMNo);
        if Item.FindSet() then
            repeat
                if Item."Reordering Policy" <> Item."Reordering Policy"::" " then
                    AssignPlannedOrders(Item."No.", true, false, ''); // P8001030
                                                                      // P8001030
                SKU.SetCurrentKey("Item No.");
                SKU.SetRange("Item No.", Item."No.");
                SKU.SetFilter("Production BOM No.", '%1|%2', '', ProductionBOMNo);
                SKU.SetFilter("Reordering Policy", '<>%1', SKU."Reordering Policy"::" ");
                if SKU.FindSet then
                    repeat
                        AssignPlannedOrdersForSKU(SKU);
                    until SKU.Next = 0;
                // P8001030
            until Item.Next() = 0;

        // P8001030
        SKU.Reset;
        SKU.SetCurrentKey("Production BOM No.");
        SKU.SetFilter("Item No.", '<>%1', Item."No.");
        SKU.SetRange("Production BOM No.", ProductionBOMNo);
        SKU.SetFilter("Reordering Policy", '<>%1', SKU."Reordering Policy"::" ");
        if SKU.FindSet then
            repeat
                AssignPlannedOrdersForSKU(SKU);
            until SKU.Next = 0;
        // P8001030
    end;

    procedure AssignPlannedOrders(ItemNo: Code[20]; CheckSKU: Boolean)
    begin
        // P80096141 - Original signature
        AssignPlannedOrders(ItemNo, CheckSKU, false, '');  
    end;

    procedure AssignPlannedOrders(ItemNo: Code[20]; CheckSKU: Boolean; FilterVariant: Boolean; VariantCode: Code[10])
    var
        ProdOrderLine: Record "Prod. Order Line";
        ReqLine: Record "Requisition Line";
        AssignThis: Boolean;
    begin
        // P8001030 - add parameters for FilterVariant and VariantCode
        ProdOrderLine.SetCurrentKey(Status, "Item No.", "Variant Code", "Location Code");
        ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Planned);
        ProdOrderLine.SetRange("Item No.", ItemNo);
        // P8001090
        if FilterVariant then begin
            ProdOrderLine.FilterGroup(9);
            ProdOrderLine.SetRange("Variant Code", VariantCode);
            ProdOrderLine.FilterGroup(0);
        end;
        // P8001030
        if ProdOrderLine.FindSet(true, true) then
            repeat
                if CheckSKU then
                    AssignThis := not SKUexists(ProdOrderLine."Item No.", ProdOrderLine."Variant Code", ProdOrderLine."Location Code")
                else
                    AssignThis := true;
                if AssignThis then
                    AssignOne(ProdOrderLine."Item No.", ProdOrderLine."Variant Code", ProdOrderLine."Location Code", WorkDate);
                ProdOrderLine.SetRange("Variant Code", ProdOrderLine."Variant Code");
                ProdOrderLine.SetRange("Location Code", ProdOrderLine."Location Code");
                ProdOrderLine.FindLast();
                ProdOrderLine.SetRange("Variant Code");
                ProdOrderLine.SetRange("Location Code");
            until ProdOrderLine.Next() = 0;

        ReqLine.SetCurrentKey(Type, "No.", "Variant Code", "Location Code");
        ReqLine.SetRange(Type, ReqLine.Type::Item);
        ReqLine.SetRange("No.", ItemNo);
        // P8001090
        if FilterVariant then begin
            ReqLine.FilterGroup(9);
            ReqLine.SetRange("Variant Code", VariantCode);
            ReqLine.FilterGroup(0);
        end;
        // P8001030
        if ReqLine.FindSet(true, true) then
            repeat
                if CheckSKU then
                    AssignThis := not SKUexists(ReqLine."No.", ReqLine."Variant Code", ReqLine."Location Code")
                else
                    AssignThis := true;
                if AssignThis then
                    AssignOne(ReqLine."No.", ReqLine."Variant Code", ReqLine."Location Code", WorkDate);
                ReqLine.SetRange("Variant Code", ReqLine."Variant Code");
                ReqLine.SetRange("Location Code", ReqLine."Location Code");
                ReqLine.FindLast();
                ReqLine.SetRange("Variant Code");
                ReqLine.SetRange("Location Code");
            until ReqLine.Next() = 0;
    end;

    procedure AssignOne(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; UpdateDate: Date)
    begin
        LockTable();
        "Item No." := ItemNo;
        "Variant Code" := VariantCode;
        "Location Code" := LocationCode;
        if Find then begin
            Validate("Net Change Planning", true);
            if UpdateDate > "Latest Date" then
                "Latest Date" := UpdateDate;
            Modify;
        end else begin
            Init;
            Validate("Net Change Planning", true);
            "Latest Date" := UpdateDate;
            Insert;
        end
    end;

    procedure ChkAssignOne(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; UpdateDate: Date)
    var
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
        ReorderingPolicy: Enum "Reordering Policy";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeChkAssignOne(ItemNo, VariantCode, LocationCode, UpdateDate, IsHandled);
        if IsHandled then
            exit;

        ReorderingPolicy := Item."Reordering Policy"::" ";

        if SKU.Get(LocationCode, ItemNo, VariantCode) then
            ReorderingPolicy := SKU."Reordering Policy"
        else
            if Item.Get(ItemNo) then
                ReorderingPolicy := Item."Reordering Policy";

        if ReorderingPolicy <> Item."Reordering Policy"::" " then
            AssignOne(ItemNo, VariantCode, LocationCode, UpdateDate);
    end;

    local procedure AnnulAllAssignment(ItemNo: Code[20])
    begin
        SetRange("Item No.", ItemNo);
        // P8001030
        //MODIFYALL("Net Change Planning",FALSE);
        if FindSet(true) then
            repeat
                if not SKUexists("Item No.", "Variant Code", "Location Code") then begin
                    "Net Change Planning" := false;
                    Modify;
                end;
            until Next = 0;
        // P8001030
    end;

    local procedure SKUexists(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]): Boolean
    var
        SKU: Record "Stockkeeping Unit";
    begin
        SKU.SetRange("Item No.", ItemNo);
        SKU.SetRange("Variant Code", VariantCode);
        SKU.SetRange("Location Code", LocationCode);
        exit(not SKU.IsEmpty);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPlanningParametersChanged(NewItem: Record Item; OldItem: Record Item; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPlanningSKUParametersChanged(NewSKU: Record "Stockkeeping Unit"; OldSKU: Record "Stockkeeping Unit"; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeChkAssignOne(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; UpdateDate: Date; var IsHandled: Boolean)
    begin
    end;


    procedure AssignPlannedOrdersForSKU(SKU: Record "Stockkeeping Unit")
    var
        ProdOrderLine: Record "Prod. Order Line";
        ReqLine: Record "Requisition Line";
        AssignThis: Boolean;
    begin
        // P8001030
        ProdOrderLine.SetCurrentKey(Status, "Item No.", "Variant Code", "Location Code");
        ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Planned);
        ProdOrderLine.SetRange("Item No.", SKU."Item No.");
        ProdOrderLine.SetRange("Variant Code", SKU."Variant Code");
        ProdOrderLine.SetRange("Location Code", SKU."Location Code");
        if ProdOrderLine.FindFirst then
            AssignOne(ProdOrderLine."Item No.", ProdOrderLine."Variant Code", ProdOrderLine."Location Code", WorkDate);

        ReqLine.SetCurrentKey(Type, "No.", "Variant Code", "Location Code");
        ReqLine.SetRange(Type, ReqLine.Type::Item);
        ReqLine.SetRange("No.", SKU."Item No.");
        ReqLine.SetRange("Variant Code", SKU."Variant Code");
        ReqLine.SetRange("Location Code", SKU."Location Code");
        if ReqLine.FindFirst then
            AssignOne(ReqLine."No.", ReqLine."Variant Code", ReqLine."Location Code", WorkDate);
    end;

    procedure AssignForBOMLine(ProductionBOMLine: Record "Production BOM Line")
    var
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
    begin
        // P8001030
        if ProductionBOMLine.Type = ProductionBOMLine.Type::Item then begin
            if Item.Get(ProductionBOMLine."No.") then begin
                if Item."Reordering Policy" <> Item."Reordering Policy"::" " then
                    AssignPlannedOrders(ProductionBOMLine."No.", true, true, ProductionBOMLine."Variant Code");
                SKU.SetCurrentKey("Item No.");
                SKU.SetRange("Item No.", Item."No.");
                SKU.SetRange("Variant Code", ProductionBOMLine."Variant Code");
                SKU.SetFilter("Reordering Policy", '<>%1', SKU."Reordering Policy"::" ");
                if SKU.FindSet then
                    repeat
                        AssignPlannedOrdersForSKU(SKU);
                    until SKU.Next = 0;
            end;
        end else
            if ProductionBOMLine.Type = ProductionBOMLine.Type::"Production BOM" then
                OldBom(ProductionBOMLine."No.");
    end;

    procedure SKURoutingReplace(var SKU: Record "Stockkeeping Unit"; OldRoutingNo: Code[20])
    begin
        // P8001030
        if OldRoutingNo <> SKU."Routing No." then
            if SKU."Reordering Policy" <> SKU."Reordering Policy"::" " then
                AssignPlannedOrdersForSKU(SKU);
    end;

    procedure SKUBOMReplace(var SKU: Record "Stockkeeping Unit"; OldProductionBOMNo: Code[20])
    begin
        // P8001030
        if OldProductionBOMNo <> SKU."Production BOM No." then
            if SKU."Reordering Policy" <> SKU."Reordering Policy"::" " then
                AssignPlannedOrdersForSKU(SKU);

        if OldProductionBOMNo <> '' then
            OldBom(OldProductionBOMNo);
    end;
}

