codeunit 37002469 "Pre-Process Register"
{
    // PRW16.00.06
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Add Pre-Process functionality
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW111.00.01
    // P80057829, To-Increase, Dayakar Battini, 27 APR 18
    //   Provide Container handling for non blending pre-process activities
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Permissions = TableData "Reg. Pre-Process Activity" = im,
                  TableData "Reg. Pre-Process Activity Line" = im;
    TableNo = "Pre-Process Activity";

    trigger OnRun()
    begin
        Activity.Copy(Rec);
        Code;
        Rec := Activity;
    end;

    var
        Activity: Record "Pre-Process Activity";
        ActivityLine: Record "Pre-Process Activity Line";
        Item: Record Item;
        RegActivity: Record "Reg. Pre-Process Activity";
        RegActivityLine: Record "Reg. Pre-Process Activity Line";
        Text000: Label 'There is nothing to register.';
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        P800WhseActCreate: Codeunit "Process 800 Create Whse. Act.";
        TempLabelToPrintLine: Record "Reg. Pre-Process Activity Line" temporary;
        RegisterDate: Date;

    local procedure "Code"()
    begin
        with Activity do begin
            if ("Qty. to Process" = 0) then
                Error(Text000);
            GetItem("Item No.");

            ActivityLine.Reset;
            ActivityLine.SetRange("Activity No.", "No.");
            ActivityLine.SetFilter("Qty. to Process", '<>0');
            if IsLotTracked() then begin
                ActivityLine.FindSet;
                repeat
                    ActivityLine.TestField("Lot No.");
                    CreateProdOrderCompTrkg;
                until (ActivityLine.Next = 0);
            end;

            CreateRegActivity;
            ActivityLine.FindSet;
            repeat
                RegisterWhseMovement(
                  "To Bin Code", "From Bin Code", ActivityLine."Line No.",
                  ActivityLine."Lot No.", ActivityLine."Qty. to Process", ActivityLine."Qty. to Process (Base)", ActivityLine."From Container ID", ActivityLine."To Container ID");
                CreateRegActivityLine;
                ActivityLine."Quantity Processed" += ActivityLine."Qty. to Process";
                ActivityLine."Qty. Processed (Base)" += ActivityLine."Qty. to Process (Base)";
                ActivityLine."Qty. to Process" := 0;
                ActivityLine."Qty. to Process (Base)" := 0;
                ActivityLine.Modify;
            until (ActivityLine.Next = 0);

            "Quantity Processed" += "Qty. to Process";
            "Qty. Processed (Base)" += "Qty. to Process (Base)";
            InitRemaining;

            ActivityLine.Reset;
            ActivityLine.SetRange("Activity No.", "No.");
            if ("Remaining Quantity" = 0) then begin
                ActivityLine.DeleteAll;
                if HasLinks then
                    DeleteLinks;
                Delete;
            end else begin
                if not IsLotTracked() then begin
                    Modify;
                    ActivityLine.FindFirst;
                    ActivityLine.InitQtyToProcess;
                    ActivityLine.Modify;
                end;
                UpdateQtyToProcess;
                Modify;
            end;
        end;
        Clear(P800WhseActCreate);
        Commit;

        PrintLabels;
    end;

    local procedure CreateRegActivity()
    begin
        with RegActivity do begin
            if Get(Activity."No.") then begin
                Description := Activity.Description;
                "Order Specific" := Activity."Order Specific";
                "Auto Complete" := Activity."Auto Complete";
                "Quantity Processed" += Activity."Qty. to Process";
                "Qty. Processed (Base)" += Activity."Qty. to Process (Base)";
                Modify;
                if HasLinks then
                    DeleteLinks;
            end else begin
                TransferFields(Activity);
                Insert;
            end;
            CopyLinks(Activity);
        end;
    end;

    local procedure CreateRegActivityLine()
    var
        WhseEntry: Record "Warehouse Entry";
    begin
        with RegActivityLine do
            if Get(ActivityLine."Activity No.", ActivityLine."Line No.") then begin
                "Quantity Processed" += ActivityLine."Qty. to Process";
                "Qty. Processed (Base)" += ActivityLine."Qty. to Process (Base)";
                Modify;
            end else begin
                TransferFields(ActivityLine);
                Insert;
            end;
        TempLabelToPrintLine := RegActivityLine;
        TempLabelToPrintLine.Insert;
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        if (Item."No." <> ItemNo) then
            Item.Get(ItemNo);
    end;

    local procedure RegisterWhseMovement(FromBinCode: Code[20]; ToBinCode: Code[20]; SourceLineNo: Integer; LotNo: Code[50]; Qty: Decimal; QtyBase: Decimal; FromContainerID: Code[20]; ToContainerID: Code[20])
    begin
        P800WhseActCreate.SetRegisterDate(RegisterDate);
        with Activity do begin
            P800WhseActCreate.SetSourceInfo(DATABASE::"Pre-Process Activity Line", 0, "No.", SourceLineNo, FromContainerID, ToContainerID);
            P800WhseActCreate.RegisterMoveBase(
              "Location Code", FromBinCode, ToBinCode, "Item No.", "Variant Code", "Unit of Measure Code", LotNo, '', Qty, QtyBase);
        end;
    end;

    local procedure CreateProdOrderCompTrkg()
    var
        ProdOrderComp: Record "Prod. Order Component";
    begin
        with Activity do
            ProdOrderComp.Get("Prod. Order Status", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Comp. Line No.");
        with ProdOrderComp do begin
            CreateReservEntry.CreateReservEntryFor(
              DATABASE::"Prod. Order Component", Status, "Prod. Order No.", '', "Prod. Order Line No.",
              "Line No.", "Qty. per Unit of Measure", ActivityLine."Qty. to Process", ActivityLine."Qty. to Process (Base)", // P8001132
              '', ActivityLine."Lot No.");
            CreateReservEntry.CreateEntry(
              "Item No.", "Variant Code", Activity."Location Code",
              Activity.Description, 0D, Activity."Starting Date", 0, 2);
            GetLotNo;
            Modify;
        end;
    end;

    local procedure PrintLabels()
    begin
        with TempLabelToPrintLine do
            if FindSet then begin
                repeat
                    RegActivityLine.Get("Activity No.", "Line No.");
                    RegActivityLine.PrintLabel();
                until (Next = 0);
                DeleteAll;
            end;
    end;

    procedure SetRegisterDate(NewRegisterDate: Date)
    begin
        RegisterDate := NewRegisterDate;
    end;

    procedure UndoRegPreProcessActivity(var ProdOrderComp: Record "Prod. Order Component")
    var
        TotalQty: Decimal;
        TotalQtyBase: Decimal;
        UndoQty: Decimal;
        UndoQtyBase: Decimal;
    begin
        with RegActivity do begin
            Reset;
            SetCurrentKey("Prod. Order Status", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Comp. Line No.");
            SetRange("Prod. Order Status", ProdOrderComp.Status);
            SetRange("Prod. Order No.", ProdOrderComp."Prod. Order No.");
            SetRange("Prod. Order Line No.", ProdOrderComp."Prod. Order Line No.");
            SetRange("Prod. Order Comp. Line No.", ProdOrderComp."Line No.");
            if not IsEmpty then begin
                RegActivityLine.Reset;
                LockTable;
                while FindFirst do begin
                    TotalQty := 0;
                    TotalQtyBase := 0;
                    Activity.TransferFields(RegActivity);
                    RegActivityLine.SetRange("Activity No.", "No.");
                    RegActivityLine.FindSet;
                    repeat
                        UndoQty := RegActivityLine."Quantity Processed";
                        UndoQtyBase := RegActivityLine."Qty. Processed (Base)";
                        Activity.ReduceFromBinQtys(
                          RegActivity."From-Bin Code", RegActivityLine."Lot No.", UndoQty, UndoQtyBase);
                        if (UndoQty <> 0) or (UndoQtyBase <> 0) then begin
                            RegisterWhseMovement(
                              "From-Bin Code", "To-Bin Code", RegActivityLine."Line No.",
                              RegActivityLine."Lot No.", UndoQty, UndoQtyBase, RegActivityLine."From Container ID", RegActivityLine."To Container ID");
                            RegActivityLine."Quantity Processed" -= UndoQty;
                            RegActivityLine."Qty. Processed (Base)" -= UndoQtyBase;
                            RegActivityLine.Modify;
                        end;
                        TotalQty += RegActivityLine."Quantity Processed";
                        TotalQtyBase += RegActivityLine."Qty. Processed (Base)";
                    until (RegActivityLine.Next = 0);
                    "Prod. Order Status" := "Prod. Order Status"::" ";
                    "Prod. Order No." := '';
                    "Prod. Order Line No." := 0;
                    "Prod. Order Comp. Line No." := 0;
                    "Quantity Processed" := TotalQty;
                    "Qty. Processed (Base)" := TotalQtyBase;
                    Modify;
                end;
            end;
        end;
    end;
}

