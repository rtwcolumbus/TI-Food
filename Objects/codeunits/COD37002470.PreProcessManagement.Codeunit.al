codeunit 37002470 "Pre-Process Management"
{
    // PRW16.00.06
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Add Pre-Process functionality
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.10.02
    // P8001301, Columbus IT, Jack Reynolds, 03 MAR 14
    //   Update Rollup 4
    // 
    // PRW110.0.02
    // P80037375, To-Increase, Dayakar Battini, 20 MAR 18
    //   Deleting orphaned pre-process activities when finished
    // 
    // PRW111.00.01
    // P80061248, To-Increase, Jack Reynolds, 26 JUN 18
    //   Fix problem with orphaned package orders
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Permissions = TableData "Reg. Pre-Process Activity" = m;

    trigger OnRun()
    begin
    end;

    var
        Planning: Codeunit "Planning-Get Parameters";
        CalcProdOrder: Codeunit "Calculate Prod. Order";
        ProdOrderStatusMgt: Codeunit "Prod. Order Status Management";
        WhseProdRelease: Codeunit "Whse.-Production Release";
        Text000: Label 'Unable to register Activity No. %1.\\%2';
        ConfirmDeleteActivityTxt: Label 'Do you want to delete the associated %1 %2 (yes/no)?.';

    procedure CreateBlendingOrder(NewActivity: Record "Pre-Process Activity"; NewOrderStatus: Integer; var NewProdOrder: Record "Production Order")
    var
        OrigQtyBase: Decimal;
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
        NewProdOrderLine: Record "Prod. Order Line";
    begin
        with NewActivity do
            if (Blending = Blending::"Per Item") then begin
                OrigQtyBase := "Quantity (Base)";
                Planning.AtSKU(SKU, "Item No.", "Variant Code", "Location Code");
                if (SKU."Minimum Order Quantity" > 0) and ("Quantity (Base)" < SKU."Minimum Order Quantity") then
                    "Quantity (Base)" := SKU."Minimum Order Quantity";
                if (SKU."Order Multiple" > 0) then
                    "Quantity (Base)" := Round("Quantity (Base)", SKU."Order Multiple", '>');
                if ("Quantity (Base)" <> OrigQtyBase) then
                    Quantity := Round("Quantity (Base)" / "Qty. per Unit of Measure", 0.00001);
            end;

        with NewProdOrder do begin
            Init;
            Status := NewOrderStatus;
            "No." := '';
            "Due Date" := NewActivity."Starting Date";
            Insert(true);
            Validate("Source Type", "Source Type"::Item);
            Validate("Source No.", NewActivity."Item No.");
            Validate("Variant Code", NewActivity."Variant Code");
            Validate(Quantity, NewActivity."Quantity (Base)");
            Validate("Location Code", NewActivity."Location Code");
            Validate("Replenishment Area Code", NewActivity."Replenishment Area Code");
            Modify;
        end;

        Item.Get(NewActivity."Item No.");
        with NewProdOrderLine do begin
            Init;
            Status := NewProdOrder.Status;
            "Prod. Order No." := NewProdOrder."No.";
            "Line No." := 10000;
            "Routing Reference No." := "Line No.";
            Validate("Item No.", Item."No.");
            "Location Code" := NewProdOrder."Location Code";
            "Equipment Code" := NewProdOrder."Equipment Code";
            //"Shortcut Dimension 1 Code" := NewProdOrder."Shortcut Dimension 1 Code"; // P8001133
            //"Shortcut Dimension 2 Code" := NewProdOrder."Shortcut Dimension 2 Code"; // P8001133
            Validate("Location Code");
            "Scrap %" := Item."Scrap %";
            "Due Date" := NewProdOrder."Due Date";
            "Starting Date" := NewProdOrder."Starting Date";
            "Starting Time" := NewProdOrder."Starting Time";
            "Ending Date" := NewProdOrder."Ending Date";
            "Ending Time" := NewProdOrder."Ending Time";
            "Planning Level Code" := 0;
            "Inventory Posting Group" := Item."Inventory Posting Group";
            "Variant Code" := NewProdOrder."Variant Code";
            Description := NewProdOrder.Description;
            "Description 2" := NewProdOrder."Description 2";
            "Planning Flexibility" := "Planning Flexibility"::None;
            Validate("Unit of Measure Code", NewActivity."Unit of Measure Code");
            Validate(Quantity, NewActivity.Quantity);
            UpdateDatetime;
            Validate("Unit Cost");
            Insert;
        end;

        CalcProdOrder.Calculate(NewProdOrderLine, 1, true, true, false, true); // P8001301
        NewProdOrder.Find;
        if (NewProdOrder.Status = NewProdOrder.Status::Released) then begin
            ProdOrderStatusMgt.FlushProdOrder(NewProdOrder, NewProdOrder.Status, WorkDate);
            WhseProdRelease.Release(NewProdOrder);
        end;
    end;

    procedure ChangeOrderStatus(OrigStatus: Integer; OrigNo: Code[20]; NewStatus: Integer; NewNo: Code[20])
    var
        Activity: Record "Pre-Process Activity";
        Activity2: Record "Pre-Process Activity";
        RegActivity: Record "Reg. Pre-Process Activity";
        RegActivity2: Record "Reg. Pre-Process Activity";
    begin
        with RegActivity do begin
            SetCurrentKey("Prod. Order Status", "Prod. Order No.");
            SetRange("Prod. Order Status", OrigStatus);
            SetRange("Prod. Order No.", OrigNo);
            if FindSet then
                repeat
                    RegActivity2.Get("No.");
                    RegActivity2."Prod. Order Status" := NewStatus;
                    RegActivity2."Prod. Order No." := NewNo;
                    RegActivity2.Modify;
                until (Next = 0);
        end;
        with Activity do begin
            SetCurrentKey("Prod. Order Status", "Prod. Order No.");
            SetRange("Prod. Order Status", OrigStatus);
            SetRange("Prod. Order No.", OrigNo);
            if FindSet then
                repeat
                    Activity2.Get("No.");
                    Activity2."Prod. Order Status" := NewStatus;
                    Activity2."Prod. Order No." := NewNo;
                    Activity2.Modify;
                until (Next = 0);
        end;
    end;

    procedure ChangeBlendingOrderStatus(OrigStatus: Integer; OrigNo: Code[20]; NewStatus: Integer; NewNo: Code[20])
    var
        Activity: Record "Pre-Process Activity";
        Activity2: Record "Pre-Process Activity";
        RegActivity: Record "Reg. Pre-Process Activity";
        RegActivity2: Record "Reg. Pre-Process Activity";
    begin
        with RegActivity do begin
            SetCurrentKey("Blending Order Status", "Blending Order No.");
            SetRange("Blending Order Status", OrigStatus);
            SetRange("Blending Order No.", OrigNo);
            if FindSet then
                repeat
                    RegActivity2.Get("No.");
                    RegActivity2."Blending Order No." := NewNo;
                    if (NewNo <> '') then
                        RegActivity2."Blending Order Status" := NewStatus
                    else begin
                        RegActivity2.Blending := Blending::" ";
                        RegActivity2."Blending Order Status" := "Blending Order Status"::" ";
                        RegActivity2."Auto Complete" := false;
                    end;
                    RegActivity2.Modify;
                until (Next = 0);
        end;
        with Activity do begin
            SetCurrentKey("Blending Order Status", "Blending Order No.");
            SetRange("Blending Order Status", OrigStatus);
            SetRange("Blending Order No.", OrigNo);
            if FindSet then
                repeat
                    Activity2.Get("No.");
                    Activity2."Blending Order No." := NewNo;
                    if (NewNo <> '') then
                        Activity2."Blending Order Status" := NewStatus
                    else begin
                        Activity2.Blending := Blending::" ";
                        Activity2."Blending Order Status" := "Blending Order Status"::" ";
                        Activity2."Auto Complete" := false;
                    end;
                    Activity2.Modify;
                until (Next = 0);
        end;
    end;

    procedure CancelBlendingOrder(var ProdOrderLine: Record "Prod. Order Line")
    begin
        with ProdOrderLine do begin
            LockTable;
            ChangeBlendingOrderStatus(Status, "Prod. Order No.", 0, '');
        end;
    end;

    procedure AutoComplete(var ProdOrder: Record "Production Order")
    var
        Activity: Record "Pre-Process Activity";
        ActivityRegister: Codeunit "Pre-Process Register";
    begin
        //COMMIT; // P80061248
        with Activity do begin
            SetCurrentKey("Blending Order Status", "Blending Order No.");
            SetRange("Blending Order Status", ProdOrder.Status);
            SetRange("Blending Order No.", ProdOrder."No.");
            // P80037375
            SetRange("Auto Complete", false);
            if not IsEmpty then begin // P80061248
                Commit;                 // P80061248
                if Confirm(StrSubstNo(ConfirmDeleteActivityTxt, Activity.TableCaption, Activity."No."), false) then
                    DeleteAll(true);
            end;                      // P80061248
                                      // P80037375
            SetRange("Auto Complete", true);
            if FindSet then begin // P80061248
                Commit;             // P80061248
                repeat
                    if AutoCompleteAllowed(Activity) then begin
                        if not ActivityRegister.Run(Activity) then
                            Message(Text000, "No.", GetLastErrorText);
                        Clear(ActivityRegister);
                        Commit;
                    end;
                until (Next = 0);
            end;                  // P80061248
        end;
    end;

    local procedure AutoCompleteAllowed(var Activity: Record "Pre-Process Activity"): Boolean
    var
        BlendOrderLine: Record "Prod. Order Line";
    begin
        with Activity do
            if ("Qty. to Process" > 0) then begin
                BlendOrderLine.SetRange(Status, "Blending Order Status");
                BlendOrderLine.SetRange("Prod. Order No.", "Blending Order No.");
                if BlendOrderLine.FindFirst then
                    exit("Qty. to Process (Base)" <= BlendOrderLine."Finished Qty. (Base)");
            end;
    end;

    procedure UpdatePerOrderBlending(var ProdOrderLine: Record "Prod. Order Line"; var ItemJnlLine: Record "Item Journal Line")
    var
        Activity: Record "Pre-Process Activity";
        OutputQty: Decimal;
        OutputQtyBase: Decimal;
    begin
        with Activity do begin
            SetCurrentKey("Blending Order Status", "Blending Order No.");
            SetRange("Blending Order Status", ProdOrderLine.Status);
            SetRange("Blending Order No.", ProdOrderLine."Prod. Order No.");
            SetRange(Blending, Blending::"Per Order");
            if FindSet then
                repeat
                    if IsLotTracked() and ("Qty. to Process (Base)" < "Remaining Qty. (Base)") then begin
                        OutputQtyBase := ItemJnlLine."Output Quantity (Base)";
                        if (OutputQtyBase >= ("Remaining Qty. (Base)" - "Qty. to Process (Base)")) then begin
                            OutputQtyBase := "Remaining Qty. (Base)" - "Qty. to Process (Base)";
                            OutputQty := "Remaining Quantity" - "Qty. to Process";
                        end else
                            OutputQty := Round(OutputQtyBase / "Qty. per Unit of Measure", 0.00001);
                        AddToActivityLines(Activity, ItemJnlLine."Lot No.", OutputQty, OutputQtyBase);
                    end;
                until (Next = 0);
        end;
    end;

    local procedure AddToActivityLines(var Activity: Record "Pre-Process Activity"; LotNo: Code[50]; OutputQty: Decimal; OutputQtyBase: Decimal)
    var
        ActivityLine: Record "Pre-Process Activity Line";
    begin
        with ActivityLine do begin
            SetCurrentKey("Activity No.", "Lot No.");
            SetRange("Activity No.", Activity."No.");
            SetRange("Lot No.", LotNo);
            if not FindFirst then
                InsertRecord(Activity."No.", LotNo);
            "Qty. to Process" := "Qty. to Process" + OutputQty;
            "Qty. to Process (Base)" := "Qty. to Process (Base)" + OutputQtyBase;
            Modify(true);
        end;
    end;

    procedure UpdatePerItemBlending(var ProdOrder: Record "Production Order")
    var
        Activity: Record "Pre-Process Activity";
        ProdOrderLine: Record "Prod. Order Line";
        ActivityLine: Record "Pre-Process Activity Line";
        NeededQtyBase: Decimal;
        LotNo: Code[50];
    begin
        with Activity do begin
            SetCurrentKey("Blending Order Status", "Blending Order No.");
            SetRange("Blending Order Status", ProdOrder.Status);
            SetRange("Blending Order No.", ProdOrder."No.");
            if FindSet then
                if (Blending = Blending::"Per Item") and IsLotTracked() then begin
                    CalcSums("Remaining Qty. (Base)", "Qty. to Process (Base)");
                    if ("Remaining Qty. (Base)" > "Qty. to Process (Base)") then begin
                        NeededQtyBase := "Remaining Qty. (Base)" - "Qty. to Process (Base)";
                        ProdOrderLine.SetRange(Status, ProdOrder.Status);
                        ProdOrderLine.SetRange("Prod. Order No.", ProdOrder."No.");
                        ProdOrderLine.FindFirst;
                        if (ProdOrderLine."Finished Qty. (Base)" >= NeededQtyBase) then
                            if OutputIsOneLotNo(ProdOrderLine, LotNo) then begin
                                ActivityLine.SetCurrentKey("Activity No.", "Lot No.");
                                ActivityLine.SetRange("Lot No.", LotNo);
                                repeat
                                    ActivityLine.SetRange("Activity No.", "No.");
                                    if ActivityLine.FindFirst then
                                        NeededQtyBase += (ActivityLine."Qty. to Process (Base)" + ActivityLine."Qty. Processed (Base)");
                                until (Next = 0);
                                if (ProdOrderLine."Finished Qty. (Base)" >= NeededQtyBase) then begin
                                    FindSet;
                                    repeat
                                        AddToActivityLines(
                                          Activity, LotNo, "Remaining Quantity" - "Qty. to Process",
                                          "Remaining Qty. (Base)" - "Qty. to Process (Base)");
                                    until (Next = 0);
                                    Commit;
                                end;
                            end;
                    end;
                end;
        end;
    end;

    local procedure OutputIsOneLotNo(var ProdOrderLine: Record "Prod. Order Line"; var LotNo: Code[50]): Boolean
    var
        OutputItemEntry: Record "Item Ledger Entry";
    begin
        with OutputItemEntry do begin
            SetCurrentKey(
              "Order Type", "Order No.", "Order Line No.", "Entry Type", "Prod. Order Comp. Line No."); // P8001132
            SetRange("Order Type", "Order Type"::Production);       // P8001132
            SetRange("Order No.", ProdOrderLine."Prod. Order No."); // P8001132
            SetRange("Order Line No.", ProdOrderLine."Line No.");   // P8001132
            SetRange("Entry Type", "Entry Type"::Output);
            if FindFirst then begin
                SetFilter("Lot No.", '<>%1', "Lot No.");
                if IsEmpty then begin
                    LotNo := "Lot No.";
                    exit(true);
                end;
            end;
        end;
    end;

    procedure IsPreProcessBlending(var ProdOrder: Record "Production Order"): Boolean
    var
        PreProcessAct: Record "Pre-Process Activity";
        RegPreProcessAct: Record "Reg. Pre-Process Activity";
    begin
        PreProcessAct.SetCurrentKey("Blending Order Status", "Blending Order No.");
        PreProcessAct.SetRange("Blending Order Status", ProdOrder.Status);
        PreProcessAct.SetRange("Blending Order No.", ProdOrder."No.");
        if PreProcessAct.IsEmpty then begin
            RegPreProcessAct.SetCurrentKey("Blending Order Status", "Blending Order No.");
            RegPreProcessAct.SetRange("Blending Order Status", ProdOrder.Status);
            RegPreProcessAct.SetRange("Blending Order No.", ProdOrder."No.");
            if RegPreProcessAct.IsEmpty then
                exit(false);
        end;
        exit(true);
    end;
}

