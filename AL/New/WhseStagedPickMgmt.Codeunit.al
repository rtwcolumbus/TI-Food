codeunit 37002762 "Whse. Staged Pick Mgmt."
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 15 SEP 06
    //   Staged Picks
    // 
    // PR5.00
    // P8000494A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Production Bins/Replenishment
    // 
    // P8000494A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Order Picking Options
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW119.0
    // P800133109, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 19.0 - Qty. Rounding Precision

    trigger OnRun()
    begin
    end;

    var
        HideValidationDialog: Boolean;
        Text000: Label 'You have to delete all related %1s first before you can reopen Staged Pick No. %2.';
        TempOrderToPick: Record "Item Ledger Entry" temporary;

    procedure Release(var WhsePickHeader: Record "Whse. Staged Pick Header")
    var
        Location: Record Location;
        WhsePickRqst: Record "Whse. Pick Request";
        WhsePickLine: Record "Whse. Staged Pick Line";
    begin
        with WhsePickHeader do begin
            if Status = Status::Released then
                exit;

            if "Location Code" <> '' then begin
                Location.Get("Location Code");
                Location.TestField("Require Pick");
            end else
                CheckPickRequired("Location Code");

            WhsePickLine.SetRange("No.", "No.");
            WhsePickLine.SetFilter("Qty. to Stage", '<>0');
            if WhsePickLine.Find('-') then
                repeat
                    WhsePickLine.TestField("Item No.");
                    WhsePickLine.TestField("Unit of Measure Code");
                    if Location."Directed Put-away and Pick" then
                        WhsePickLine.TestField("Zone Code");
                    if Location."Bin Mandatory" then
                        WhsePickLine.TestField("Bin Code");
                until WhsePickLine.Next = 0;

            Status := Status::Released;
            Modify;

            CreateWhsePickRqst(WhsePickHeader);

            WhsePickRqst.SetRange("Document Type", WhsePickRqst."Document Type"::FOODStagedPick);
            WhsePickRqst.SetRange("Document No.", "No.");
            WhsePickRqst.SetRange(Status, Status::Open);
            WhsePickRqst.DeleteAll(true);
        end;
    end;

    procedure Reopen(var WhsePickHeader: Record "Whse. Staged Pick Header")
    var
        WhsePickRqst: Record "Whse. Pick Request";
        PickWkshLine: Record "Whse. Worksheet Line";
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        with WhsePickHeader do begin
            if Status = Status::Open then
                exit;

            PickWkshLine.SetCurrentKey("Whse. Document Type", "Whse. Document No.");
            PickWkshLine.SetRange("Whse. Document Type", PickWkshLine."Whse. Document Type"::FOODStagedPick);
            PickWkshLine.SetRange("Whse. Document No.", "No.");
            if PickWkshLine.Find('-') then
                Error(Text000, PickWkshLine.TableCaption, "No.");

            WhseActivLine.SetCurrentKey("Whse. Document No.", "Whse. Document Type", "Activity Type");
            WhseActivLine.SetRange("Whse. Document No.", "No.");
            WhseActivLine.SetRange("Whse. Document Type", WhseActivLine."Whse. Document Type"::FOODStagedPick);
            WhseActivLine.SetRange("Activity Type", WhseActivLine."Activity Type"::Pick);
            if WhseActivLine.Find('-') then
                Error(Text000, WhseActivLine.TableCaption, "No.");

            WhseActivLine.Reset;
            WhseActivLine.SetCurrentKey("From Staged Pick No.");
            WhseActivLine.SetRange("From Staged Pick No.", "No.");
            if WhseActivLine.Find('-') then
                Error(Text000, WhseActivLine.TableCaption, "No.");

            WhsePickRqst.SetRange("Document Type", WhsePickRqst."Document Type"::FOODStagedPick);
            WhsePickRqst.SetRange("Document No.", "No.");
            WhsePickRqst.SetRange(Status, Status::Released);
            if WhsePickRqst.Find('-') then
                repeat
                    WhsePickRqst.Status := WhsePickRqst.Status::Open;
                    WhsePickRqst.Modify;
                until WhsePickRqst.Next = 0;

            Status := Status::Open;
            Modify;
        end;
    end;

    local procedure CreateWhsePickRqst(var WhsePickHeader: Record "Whse. Staged Pick Header")
    var
        WhsePickRqst: Record "Whse. Pick Request";
        Location: Record Location;
    begin
        with WhsePickHeader do begin
            if Location.RequirePicking("Location Code") then begin
                WhsePickRqst."Document Type" := WhsePickRqst."Document Type"::FOODStagedPick;
                //WhsePickRqst."Document Subtype" := WhsePickRqst."Document Subtype"::" "; // P8001132
                WhsePickRqst."Document No." := "No.";
                WhsePickRqst.Status := Status;
                WhsePickRqst."Location Code" := "Location Code";
                WhsePickRqst."Zone Code" := "Zone Code";
                WhsePickRqst."Bin Code" := "Bin Code";
                "Staging Status" := GetStagingStatus(0);
                WhsePickRqst."Completely Picked" :=
                  "Staging Status" = "Staging Status"::"Completely Staged";
                if not WhsePickRqst.Insert then
                    WhsePickRqst.Modify;
            end;
        end;
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    procedure UpdateStgdPickSourceLineOnReg(var WhseActLine: Record "Warehouse Activity Line")
    var
        WhseStgdPickHeader: Record "Whse. Staged Pick Header";
        WhseStgdPickSourceLine: Record "Whse. Staged Pick Source Line";
        TotalQtyToPick: Decimal;
        TotalQtyToPickBase: Decimal;
        QtyToPick: Decimal;
        QtyToPickBase: Decimal;
    begin
        with WhseActLine do
            if ("Activity Type" = "Activity Type"::Pick) and
               ("Action Type" = "Action Type"::Take) and
               ("Breakbulk No." = 0)
            then begin
                TotalQtyToPick := "Qty. to Handle";
                TotalQtyToPickBase := "Qty. to Handle (Base)";
                WhseStgdPickSourceLine.SetRange("No.", "From Staged Pick No.");
                WhseStgdPickSourceLine.SetRange("Line No.", "From Staged Pick Line No.");
                WhseStgdPickSourceLine.SetRange("Source Type", "Source Type");
                WhseStgdPickSourceLine.SetRange("Source Subtype", "Source Subtype");
                WhseStgdPickSourceLine.SetRange("Source No.", "Source No.");
                WhseStgdPickSourceLine.SetRange("Source Line No.", "Source Line No.");
                WhseStgdPickSourceLine.SetRange("Source Subline No.", "Source Subline No.");
                if WhseStgdPickSourceLine.Find('-') then
                    repeat
                        if ("Bin Code" = WhseStgdPickSourceLine."Bin Code") then begin
                            QtyToPick := WhseStgdPickSourceLine."Qty. Outstanding";
                            QtyToPickBase := WhseStgdPickSourceLine."Qty. Outstanding (Base)";
                            if (QtyToPick > TotalQtyToPick) then
                                QtyToPick := TotalQtyToPick;
                            if (QtyToPickBase > TotalQtyToPickBase) then
                                QtyToPickBase := TotalQtyToPickBase;
                            TotalQtyToPick := TotalQtyToPick - QtyToPick;
                            TotalQtyToPickBase := TotalQtyToPickBase - QtyToPickBase;
                            WhseStgdPickSourceLine."Qty. Picked" :=
                              WhseStgdPickSourceLine."Qty. Picked" + QtyToPick;
                            WhseStgdPickSourceLine."Qty. Picked (Base)" :=
                              WhseStgdPickSourceLine."Qty. Picked (Base)" + QtyToPickBase;
                            WhseStgdPickSourceLine.Validate("Qty. Outstanding",
                              WhseStgdPickSourceLine.Quantity - WhseStgdPickSourceLine."Qty. Picked");
                            WhseStgdPickSourceLine.UpdateDocStatus(false);
                            WhseStgdPickSourceLine.Modify;
                            WhseStgdPickHeader.Get(WhseStgdPickSourceLine."No.");
                            WhseStgdPickHeader.UpdateOnRegister;
                        end;
                    until (WhseStgdPickSourceLine.Next = 0) or
                          ((TotalQtyToPick = 0) and (TotalQtyToPickBase = 0));
            end;
    end;

    procedure FindItemPickLine(var WhseStgdPickHeader: Record "Whse. Staged Pick Header"; ItemNo: Code[20]; VariantCode: Code[10]; var WhseStagedPickLine: Record "Whse. Staged Pick Line"): Boolean
    begin
        with WhseStagedPickLine do begin
            SetCurrentKey("No.", "Item No.");
            SetRange("No.", WhseStgdPickHeader."No.");
            SetRange("Item No.", ItemNo);
            SetRange("Variant Code", VariantCode);
            exit(Find('-'));
        end;
    end;

    local procedure AddItemPickLine(var WhseStgdPickHeader: Record "Whse. Staged Pick Header"; ItemNo: Code[20]; VariantCode: Code[10]; var WhseStagedPickLine: Record "Whse. Staged Pick Line")
    begin
        if FindItemPickLine(WhseStgdPickHeader, ItemNo, VariantCode, WhseStagedPickLine) then
            exit;
        with WhseStagedPickLine do begin
            Reset;
            SetRange("No.", WhseStgdPickHeader."No.");
            if not Find('+') then begin
                "No." := WhseStgdPickHeader."No.";
                "Line No." := 0;
            end;
            "Line No." := "Line No." + 10000;
            Init;
            "Zone Code" := WhseStgdPickHeader."Zone Code";
            "Bin Code" := WhseStgdPickHeader."Bin Code";
            "Due Date" := WhseStgdPickHeader."Due Date";
            "Location Code" := WhseStgdPickHeader."Location Code";
            Validate("Item No.", ItemNo);
            Validate("Variant Code", VariantCode);
            Insert(true);
        end;
        WhseStgdPickHeader.Find;
        WhseStgdPickHeader.SortWhseDoc;
    end;

    local procedure AddSourcePickLine(var WhseStgdPickHeader: Record "Whse. Staged Pick Header"; var WhseStagedPickLine: Record "Whse. Staged Pick Line"; SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20]; SourceLineNo: Integer; SourceSublineNo: Integer; var WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line")
    var
        WhseMgmt: Codeunit "Whse. Management";
    begin
        with WhseStagedPickSourceLine do begin
            Init;
            "No." := WhseStgdPickHeader."No.";
            "Line No." := WhseStagedPickLine."Line No.";
            "Source Type" := SourceType;
            "Source Subtype" := SourceSubtype;
            "Source No." := SourceNo;
            "Source Line No." := SourceLineNo;
            "Source Subline No." := SourceSublineNo;
            "Location Code" := WhseStgdPickHeader."Location Code";
            "Zone Code" := WhseStgdPickHeader."Zone Code";
            "Bin Code" := WhseStgdPickHeader."Bin Code";
            "Item No." := WhseStagedPickLine."Item No.";
            "Variant Code" := WhseStagedPickLine."Variant Code";
            "Source Document" := WhseMgmt.GetSourceDocumentType(SourceType, SourceSubtype).AsInteger(); // P8001132
            Insert(true);
        end;
        WhseStgdPickHeader.Find;
    end;

    local procedure FindSourceLines(var WhseStgdPickHeader: Record "Whse. Staged Pick Header"; ItemNo: Code[20]; VariantCode: Code[10]; SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20]; SourceLineNo: Integer; SourceSublineNo: Integer; var ItemLineExists: Boolean; var SourceLineExists: Boolean; var WhseStagedPickLine: Record "Whse. Staged Pick Line"; var WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line")
    begin
        Clear(WhseStagedPickLine);
        Clear(WhseStagedPickSourceLine);
        ItemLineExists :=
          FindItemPickLine(WhseStgdPickHeader, ItemNo, VariantCode, WhseStagedPickLine);
        if not ItemLineExists then
            SourceLineExists := false
        else
            SourceLineExists :=
              WhseStagedPickSourceLine.Get(
                WhseStgdPickHeader."No.", WhseStagedPickLine."Line No.", SourceType,
                SourceSubtype, SourceNo, SourceLineNo, SourceSublineNo);
    end;

    local procedure CreateSourceLines(var WhseStgdPickHeader: Record "Whse. Staged Pick Header"; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; QtyPerUnitOfMeasure: Decimal; SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20]; SourceLineNo: Integer; SourceSublineNo: Integer; Descrip: Text[100]; Descrip2: Text[50]; AvailPickQty: Decimal; ItemLineExists: Boolean; SourceLineExists: Boolean; var WhseStagedPickLine: Record "Whse. Staged Pick Line"; var WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line")
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        UOMMgt: Codeunit "Unit of Measure Management";
    begin
        if not SourceLineExists then begin
            if not ItemLineExists then
                AddItemPickLine(WhseStgdPickHeader, ItemNo, VariantCode, WhseStagedPickLine);
            AddSourcePickLine(
              WhseStgdPickHeader, WhseStagedPickLine, SourceType, SourceSubtype,
              SourceNo, SourceLineNo, SourceSublineNo, WhseStagedPickSourceLine);
        end;
        with WhseStagedPickSourceLine do begin
            "Unit of Measure Code" := UnitOfMeasureCode;
            "Qty. per Unit of Measure" := QtyPerUnitOfMeasure;
            // P800133109
            ItemUnitOfMeasure.Get("Item No.","Unit of Measure Code");
            UOMMgt.GetQtyRoundingPrecision("Item No.", "Unit of Measure Code", "Qty. Rounding Precision", "Qty. Rounding Precision (Base)");
            // P800133109
            Description := Descrip;
            "Description 2" := Descrip2;
            Validate(Quantity, "Qty. Picked" + AvailPickQty);
            Modify(true);
        end;
        WhseStgdPickHeader.Find;
    end;

    procedure AddSourceSalesLine(var WhseStgdPickHeader: Record "Whse. Staged Pick Header"; var SalesLine: Record "Sales Line")
    var
        ItemLineExists: Boolean;
        SourceLineExists: Boolean;
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
        WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line";
        AvailPickQty: Decimal;
    begin
        with SalesLine do begin
            FindSourceLines(
              WhseStgdPickHeader, "No.", "Variant Code", DATABASE::"Sales Line",
              "Document Type", "Document No.", "Line No.", 0, ItemLineExists,
              SourceLineExists, WhseStagedPickLine, WhseStagedPickSourceLine);
            AvailPickQty := WhseStagedPickSourceLine.GetSalesLineAvailPickQty(SalesLine);
            if (AvailPickQty <> 0) or (WhseStagedPickSourceLine."Qty. Picked" <> 0) then
                CreateSourceLines(
                  WhseStgdPickHeader, "No.", "Variant Code", "Unit of Measure Code",
                  "Qty. per Unit of Measure", DATABASE::"Sales Line", "Document Type",
                  "Document No.", "Line No.", 0, Description, "Description 2", AvailPickQty,
                  ItemLineExists, SourceLineExists, WhseStagedPickLine, WhseStagedPickSourceLine);
        end;
    end;

    procedure AddSourcePurchLine(var WhseStgdPickHeader: Record "Whse. Staged Pick Header"; var PurchLine: Record "Purchase Line")
    var
        ItemLineExists: Boolean;
        SourceLineExists: Boolean;
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
        WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line";
        AvailPickQty: Decimal;
    begin
        with PurchLine do begin
            FindSourceLines(
              WhseStgdPickHeader, "No.", "Variant Code", DATABASE::"Purchase Line",
              "Document Type", "Document No.", "Line No.", 0, ItemLineExists,
              SourceLineExists, WhseStagedPickLine, WhseStagedPickSourceLine);
            AvailPickQty := WhseStagedPickSourceLine.GetPurchLineAvailPickQty(PurchLine);
            if (AvailPickQty <> 0) or (WhseStagedPickSourceLine."Qty. Picked" <> 0) then
                CreateSourceLines(
                  WhseStgdPickHeader, "No.", "Variant Code", "Unit of Measure Code",
                  "Qty. per Unit of Measure", DATABASE::"Purchase Line", "Document Type",
                  "Document No.", "Line No.", 0, Description, "Description 2", AvailPickQty,
                  ItemLineExists, SourceLineExists, WhseStagedPickLine, WhseStagedPickSourceLine);
        end;
    end;

    procedure AddSourceTransLine(var WhseStgdPickHeader: Record "Whse. Staged Pick Header"; var TransLine: Record "Transfer Line")
    var
        ItemLineExists: Boolean;
        SourceLineExists: Boolean;
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
        WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line";
        AvailPickQty: Decimal;
    begin
        with TransLine do begin
            FindSourceLines(
              WhseStgdPickHeader, "Item No.", "Variant Code", DATABASE::"Transfer Line",
              0, "Document No.", "Line No.", 0, ItemLineExists, SourceLineExists,
              WhseStagedPickLine, WhseStagedPickSourceLine);
            AvailPickQty := WhseStagedPickSourceLine.GetTransLineAvailPickQty(TransLine);
            if (AvailPickQty <> 0) or (WhseStagedPickSourceLine."Qty. Picked" <> 0) then
                CreateSourceLines(
                  WhseStgdPickHeader, "Item No.", "Variant Code", "Unit of Measure Code",
                  "Qty. per Unit of Measure", DATABASE::"Transfer Line", 0,
                  "Document No.", "Line No.", 0, Description, "Description 2", AvailPickQty,
                  ItemLineExists, SourceLineExists, WhseStagedPickLine, WhseStagedPickSourceLine);
        end;
    end;

    procedure AddSourceWhseShptLine(var WhseStgdPickHeader: Record "Whse. Staged Pick Header"; var WhseShptLine: Record "Warehouse Shipment Line")
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
    begin
        with WhseShptLine do
            case "Source Document" of
                "Source Document"::"Sales Order":
                    if SalesLine.Get("Source Subtype", "Source No.", "Source Line No.") then
                        AddSourceSalesLine(WhseStgdPickHeader, SalesLine);
                "Source Document"::"Purchase Return Order":
                    if PurchLine.Get("Source Subtype", "Source No.", "Source Line No.") then
                        AddSourcePurchLine(WhseStgdPickHeader, PurchLine);
                "Source Document"::"Outbound Transfer":
                    if TransLine.Get("Source No.", "Source Line No.") then
                        AddSourceTransLine(WhseStgdPickHeader, TransLine);
            end;
    end;

    procedure AddSource1WhseShpt(var WhseStgdPickHeader: Record "Whse. Staged Pick Header"; var WhseShptHeader: Record "Warehouse Shipment Header")
    var
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        with WhseShptLine do begin
            SetRange("No.", WhseShptHeader."No.");
            if Find('-') then
                repeat
                    AddSourceWhseShptLine(WhseStgdPickHeader, WhseShptLine);
                until (Next = 0);
        end;
    end;

    procedure AddSourceWhseShpts(var WhseStgdPickHeader: Record "Whse. Staged Pick Header"; var WhseShptHeader: Record "Warehouse Shipment Header")
    begin
        with WhseShptHeader do
            if Find('-') then
                repeat
                    AddSource1WhseShpt(WhseStgdPickHeader, WhseShptHeader);
                until (Next = 0);
    end;

    procedure AddSourceProdCompLine(var WhseStgdPickHeader: Record "Whse. Staged Pick Header"; var ProdCompLine: Record "Prod. Order Component")
    var
        ItemLineExists: Boolean;
        SourceLineExists: Boolean;
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
        WhseStagedPickSourceLine: Record "Whse. Staged Pick Source Line";
        AvailPickQty: Decimal;
    begin
        with ProdCompLine do
            if not ReplenishmentNotRequired() then begin // P8000494A
                FindSourceLines(
                  WhseStgdPickHeader, "Item No.", "Variant Code", DATABASE::"Prod. Order Component",
                  Status, "Prod. Order No.", "Prod. Order Line No.", "Line No.", ItemLineExists,
                  SourceLineExists, WhseStagedPickLine, WhseStagedPickSourceLine);
                AvailPickQty := WhseStagedPickSourceLine.GetProdCompLineAvailPickQty(ProdCompLine);
                if (AvailPickQty <> 0) or (WhseStagedPickSourceLine."Qty. Picked" <> 0) then
                    CreateSourceLines(
                      WhseStgdPickHeader, "Item No.", "Variant Code", "Unit of Measure Code",
                      "Qty. per Unit of Measure", DATABASE::"Prod. Order Component", Status,
                      "Prod. Order No.", "Prod. Order Line No.", "Line No.", Description, '',
                      AvailPickQty, ItemLineExists, SourceLineExists,
                      WhseStagedPickLine, WhseStagedPickSourceLine);
            end;
    end;

    procedure AddSource1ProdOrderLine(var WhseStgdPickHeader: Record "Whse. Staged Pick Header"; var ProdOrderLine: Record "Prod. Order Line")
    var
        ProdCompLine: Record "Prod. Order Component";
    begin
        with ProdCompLine do begin
            SetRange(Status, ProdOrderLine.Status);
            SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
            SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
            if Find('-') then
                repeat
                    AddSourceProdCompLine(WhseStgdPickHeader, ProdCompLine);
                until (Next = 0);
        end;
    end;

    procedure AddSourceProdOrderLines(var WhseStgdPickHeader: Record "Whse. Staged Pick Header"; var ProdOrderLine: Record "Prod. Order Line")
    var
        ProdCompLine: Record "Prod. Order Component";
    begin
        with ProdOrderLine do
            if Find('-') then
                repeat
                    AddSource1ProdOrderLine(WhseStgdPickHeader, ProdOrderLine);
                until (Next = 0);
    end;

    procedure ClearAssignedDocumentNos()
    begin
        with TempOrderToPick do begin
            Reset;
            DeleteAll;
        end;
    end;

    procedure AssignTempDocNo(OrderPickingOptions: Option " ","One Pick per Order","One Pick per Ship-to Address"; OrderNo: Code[20]): Integer
    var
        SalesHeader: Record "Sales Header";
        PerPickData: Code[20];
    begin
        // P8000503A - reworked for more general Order Picking Options
        case OrderPickingOptions of
            OrderPickingOptions::" ":
                exit(1);
            OrderPickingOptions::"One Pick per Order":
                PerPickData := OrderNo;
            OrderPickingOptions::"One Pick per Ship-to Address":
                if SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo) then
                    PerPickData := SalesHeader."Ship-to Code";
        end;
        with TempOrderToPick do begin
            Reset;
            SetCurrentKey("Document No.");
            SetRange("Document No.", PerPickData);
            if not Find('-') then begin
                Reset;
                if Find('+') then
                    "Entry No." := "Entry No." + 1
                else
                    "Entry No." := 1;
                "Document No." := PerPickData;
                Insert;
            end;
            exit("Entry No.");
        end;
    end;
}

