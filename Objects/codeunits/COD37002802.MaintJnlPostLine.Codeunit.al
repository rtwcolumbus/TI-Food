codeunit 37002802 "Maint. Jnl.-Post Line"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   Posts maintenance journal line o maintenance ledger; posts item ledger as well for stock items
    // 
    // P8000335A, VerticalSoft, Jack Reynolds, 20 SEP 06
    //   Support for posting in conjunction with posting purchase lines
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 12 JUN 07
    //   Eliminate parameter for Expiration Date
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    TableNo = "Maintenance Journal Line";

    trigger OnRun()
    begin
        GLSetup.Get;
        RunWithCheck(Rec); // P8001133
    end;

    var
        GLSetup: Record "General Ledger Setup";
        MaintJnlLine: Record "Maintenance Journal Line";
        MaintLedgEntry: Record "Maintenance Ledger";
        MaintReg: Record "Maintenance Register";
        WorkOrder: Record "Work Order";
        WorkOrderActivity: Record "Work Order Activity";
        WorkOrderMtl: Record "Work Order Material";
        ItemJnlLine: Record "Item Journal Line";
        MaintJnlCheckLine: Codeunit "Maint. Jnl.-Check Line";
        DimMgt: Codeunit DimensionManagement;
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        NextEntryNo: Integer;
        DeferItemPosting: Boolean;

    procedure RunWithCheck(var MaintJnlLine2: Record "Maintenance Journal Line")
    begin
        // P8001133 - remove parameter for TempJnlLineDim2
        MaintJnlLine.Copy(MaintJnlLine2);
        Code(true);
        MaintJnlLine2 := MaintJnlLine;
    end;

    procedure RunWithoutCheck(var MaintJnlLine2: Record "Maintenance Journal Line")
    begin
        // P8001133 - remove parameter for TempJnlLineDim2
        MaintJnlLine.Copy(MaintJnlLine2);
        Code(false);
        MaintJnlLine2 := MaintJnlLine;
    end;

    procedure "Code"(CheckLine: Boolean)
    begin
        with MaintJnlLine do begin
            if EmptyLine then
                exit;

            if CheckLine then
                MaintJnlCheckLine.RunCheck(MaintJnlLine); // P8001133

            if NextEntryNo = 0 then begin
                MaintLedgEntry.LockTable;
                if MaintLedgEntry.FindLast then
                    NextEntryNo := MaintLedgEntry."Entry No.";
                NextEntryNo := NextEntryNo + 1;
            end;

            if "Document Date" = 0D then
                "Document Date" := "Posting Date";

            if MaintReg."No." = 0 then begin
                MaintReg.LockTable;
                if (not MaintReg.FindLast) or (MaintReg."To Entry No." <> 0) then begin
                    MaintReg.Init;
                    MaintReg."No." := MaintReg."No." + 1;
                    MaintReg."From Entry No." := NextEntryNo;
                    MaintReg."To Entry No." := NextEntryNo;
                    MaintReg."Creation Date" := Today;
                    MaintReg."Creation Time" := Time; // P80073095
                    MaintReg."Source Code" := "Source Code";
                    MaintReg."Journal Batch Name" := "Journal Batch Name";
                    MaintReg."User ID" := UserId;
                    MaintReg.Insert;
                end;
            end;
            MaintReg."To Entry No." := NextEntryNo;
            MaintReg.Modify;

            WorkOrder.Get("Work Order No.");
            MaintLedgEntry.Init;
            MaintLedgEntry."Work Order No." := "Work Order No.";
            MaintLedgEntry."Asset No." := WorkOrder."Asset No.";
            MaintLedgEntry."Entry Type" := "Entry Type";
            MaintLedgEntry."Document No." := "Document No.";
            MaintLedgEntry."Posting Date" := "Posting Date";
            MaintLedgEntry."Document Date" := "Document Date";
            MaintLedgEntry.Description := Description;
            MaintLedgEntry."Source Code" := "Source Code";
            MaintLedgEntry."Reason Code" := "Reason Code";
            MaintLedgEntry."Journal Batch Name" := "Journal Batch Name";
            MaintLedgEntry."Global Dimension 1 Code" := "Shortcut Dimension 1 Code";
            MaintLedgEntry."Global Dimension 2 Code" := "Shortcut Dimension 2 Code";
            MaintLedgEntry."Dimension Set ID" := "Dimension Set ID"; // P80011133
            MaintLedgEntry."Location Code" := "Location Code";
            MaintLedgEntry.Quantity := Quantity;
            MaintLedgEntry."Quantity (Base)" := Round(Quantity * "Qty. per Unit of Measure", 0.00001);
            MaintLedgEntry."Cost Amount" := Amount;
            MaintLedgEntry."Unit Cost" := "Unit Cost";
            MaintLedgEntry."Maintenance Trade Code" := "Maintenance Trade Code";
            MaintLedgEntry."Employee No." := "Employee No.";
            MaintLedgEntry."Starting Time" := "Starting Time";
            MaintLedgEntry."Ending Time" := "Ending Time";
            MaintLedgEntry."Vendor No." := "Vendor No.";
            MaintLedgEntry."Item No." := "Item No.";
            MaintLedgEntry."Part No." := "Part No.";
            MaintLedgEntry."Unit of Measure Code" := "Unit of Measure Code";
            MaintLedgEntry."Lot No." := "Lot No.";
            MaintLedgEntry."Serial No." := "Serial No.";
            MaintLedgEntry."Applies-to Entry" := "Applies-to Entry";

            MaintLedgEntry."Entry No." := NextEntryNo;
            MaintLedgEntry.Insert;
            NextEntryNo := NextEntryNo + 1;

            case "Entry Type" of
                "Entry Type"::Labor:
                    PostLabor;
                "Entry Type"::"Material-Stock", "Entry Type"::"Material-Nonstock":
                    PostMaterial;
                "Entry Type"::Contract:
                    PostContract;
            end;
        end;
    end;

    procedure PostLabor()
    begin
        with MaintLedgEntry do begin
            if not WorkOrderActivity.Get("Work Order No.", "Entry Type", "Maintenance Trade Code") then begin
                WorkOrderActivity.Init;
                WorkOrderActivity.Validate("Work Order No.", "Work Order No.");
                WorkOrderActivity.Validate(Type, "Entry Type");
                WorkOrderActivity.Validate("Trade Code", "Maintenance Trade Code");
                WorkOrderActivity.Insert;
            end else begin
                WorkOrderActivity.CalcHoursRemaining;
                WorkOrderActivity.Modify;
            end;
        end;
    end;

    procedure PostMaterial()
    begin
        with MaintLedgEntry do begin
            if not WorkOrderMtl.Get("Work Order No.", "Entry Type", "Item No.") then begin
                WorkOrderMtl.Init;
                WorkOrderMtl.Validate("Work Order No.", "Work Order No.");
                WorkOrderMtl.Validate(Type, "Entry Type");
                WorkOrderMtl.Validate("Item No.", "Item No.");
                WorkOrderMtl.Validate("Part No.", "Part No.");
                WorkOrderMtl.Insert;
            end else begin
                WorkOrderMtl.CalcQuantityRemaining;
                WorkOrderMtl.Modify;
            end;

            if "Entry Type" = "Entry Type"::"Material-Stock" then
                PostItemJnlLine;
        end;
    end;

    procedure PostContract()
    begin
        with MaintLedgEntry do begin
            if not WorkOrderActivity.Get("Work Order No.", "Entry Type", "Maintenance Trade Code") then begin
                WorkOrderActivity.Init;
                WorkOrderActivity.Validate("Work Order No.", "Work Order No.");
                WorkOrderActivity.Validate(Type, "Entry Type");
                WorkOrderActivity.Validate("Trade Code", "Maintenance Trade Code");
                WorkOrderActivity.Insert;
            end else begin
                WorkOrderActivity.CalcHoursRemaining;
                WorkOrderActivity.Modify;
            end;
        end;
    end;

    procedure PostItemJnlLine()
    var
        MaintLedgerEntry2: Record "Maintenance Ledger";
    begin
        with MaintJnlLine do begin
            ItemJnlLine.Init;
            if Quantity > 0 then
                ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.")
            else
                ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.");
            ItemJnlLine.Validate("Posting Date", "Posting Date");
            ItemJnlLine.Validate("Document Date", "Document Date");
            ItemJnlLine.Validate("Document No.", "Document No.");
            ItemJnlLine.Validate("Item No.", "Item No.");
            ItemJnlLine.Validate("Unit of Measure Code", "Unit of Measure Code");
            ItemJnlLine.Validate("Location Code", "Location Code");
            ItemJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            ItemJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            ItemJnlLine."Dimension Set ID" := "Dimension Set ID"; // P8001133
            ItemJnlLine."Source Code" := "Source Code";
            ItemJnlLine."Reason Code" := "Reason Code";
            ItemJnlLine.Validate("Unit Cost", "Unit Cost");
            ItemJnlLine.Validate(Quantity, Abs(Quantity));
            ItemJnlLine."Maint. Ledger Entry No." := MaintLedgEntry."Entry No.";
            if Quantity < 0 then begin
                MaintLedgerEntry2.Get("Applies-to Entry");
                ItemJnlLine.Validate("Applies-from Entry", MaintLedgerEntry2."Item Ledger Entry No.");
            end;
            if "Item Ledger Entry No." <> 0 then                                // P8000335A
                ItemJnlLine.Validate("Applies-to Entry", "Item Ledger Entry No."); // P8000335A

            if ("Lot No." <> '') or ("Serial No." <> '') then begin
                CreateReservEntry.CreateReservEntryFor(
                  DATABASE::"Item Journal Line", ItemJnlLine."Entry Type", '', '', 0, 0,
                  "Qty. per Unit of Measure", ItemJnlLine.Quantity, ItemJnlLine."Quantity (Base)", // P8001132
                  "Serial No.", "Lot No."); // P8000466A
                CreateReservEntry.CreateEntry("Item No.", '', "Location Code",
                  ItemJnlLine.Description, ItemJnlLine."Posting Date", 0D, 0, 3);
            end;

            if not DeferItemPosting then begin // P8000335A
                ItemJnlPostLine.RunWithCheck(ItemJnlLine); // P8001133
                MaintLedgEntry."Item Ledger Entry No." := ItemJnlLine."Item Shpt. Entry No.";
                MaintLedgEntry.Modify;
            end else                           // P8000335A
                DeferItemPosting := false;       // P8000335A
        end;
    end;

    procedure SetDeferItemPosting(flag: Boolean)
    begin
        // P8000335A
        DeferItemPosting := flag;
    end;

    procedure GetItemJnlLine(var rec: Record "Item Journal Line")
    begin
        // P8000335A
        rec := ItemJnlLine;
    end;

    procedure GetMaintLedger(var rec: Record "Maintenance Ledger")
    begin
        // P8000335A
        rec := MaintLedgEntry;
    end;
}

