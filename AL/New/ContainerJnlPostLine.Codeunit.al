codeunit 37002562 "Container Jnl.-Post Line"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Container journal line posting codeunit - inserts entry in container ledger, creates serial infor record, and posts
    //   through to the item ledger
    // 
    // PR4.00.03
    // P8000325A, VerticalSoft, Jack Reynolds, 01 MAY 06
    //   Modify calls to CreateReservEntry for new parameter for expiration date
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 12 JUN 07
    //   Eliminate parameter for Expiration Date
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add "Bin Code" and related logic
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.10.03
    // P8001343, Columbus IT, Dayakar Battini, 25 Aug 14
    //    Containers -Consumption posting reduces container contents.
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    EventSubscriberInstance = Manual;
    TableNo = "Container Journal Line";

    trigger OnRun()
    begin
        GetGLSetup;
        RunWithCheck(Rec); // P8001133
    end;

    var
        ContJnlLine: Record "Container Journal Line";
        ContLedgEntry: Record "Container Ledger Entry";
        ContReg: Record "Container Register";
        GLSetup: Record "General Ledger Setup";
        ContJnlCheckLine: Codeunit "Container Jnl.-Check Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        GLSetupRead: Boolean;
        NextEntryNo: Integer;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WMSMgmt: Codeunit "WMS Management";
        WhseJnlPostLine: Codeunit "Whse. Jnl.-Register Line";
        ContainerJournalUsageDate: Date;

    procedure GetContReg(var NewContReg: Record "Container Register")
    begin
        NewContReg := ContReg;
    end;

    procedure RunWithCheck(var ContJnlLine2: Record "Container Journal Line")
    begin
        // P8001133 - remove parameter for TempJnlLineDim
        ContJnlLine.Copy(ContJnlLine2);
        Code;
        ContJnlLine2 := ContJnlLine;
    end;

    local procedure "Code"()
    var
        Resource: Record Resource;
    begin
        with ContJnlLine do begin
            // P8001343
            //  IF EmptyLine THEN
            //    EXIT;
            // P8001343

            ContJnlCheckLine.RunCheck(ContJnlLine); // P8001133

            if ContLedgEntry."Entry No." = 0 then begin
                ContLedgEntry.LockTable;
                if ContLedgEntry.Find('+') then
                    NextEntryNo := ContLedgEntry."Entry No.";
                NextEntryNo := NextEntryNo + 1;
            end;

            if "Document Date" = 0D then
                "Document Date" := "Posting Date";

            if "Container Serial No." <> '' then begin
                if ContReg."No." = 0 then begin
                    ContReg.LockTable;
                    if (not ContReg.Find('+')) or (ContReg."To Entry No." <> 0) then begin
                        ContReg.Init;
                        ContReg."No." := ContReg."No." + 1;
                        ContReg."From Entry No." := NextEntryNo;
                        ContReg."To Entry No." := NextEntryNo;
                        ContReg."Creation Date" := Today;
                        ContReg."Creation Time" := Time; // P80073095
                        ContReg."Source Code" := "Source Code";
                        ContReg."Journal Batch Name" := "Journal Batch Name";
                        ContReg."User ID" := UserId;
                        ContReg.Insert;
                    end;
                end;
                ContReg."To Entry No." := NextEntryNo;
                ContReg.Modify;

                InitContLedger(ContJnlLine, ContLedgEntry);
                ContLedgEntry."Entry No." := NextEntryNo;
                ContLedgEntry.Insert;
                NextEntryNo := NextEntryNo + 1;

                if "Entry Type" = "Entry Type"::Transfer then begin
                    ContReg."To Entry No." := NextEntryNo;
                    ContReg.Modify;

                    ContLedgEntry."Location Code" := "New Location Code";
                    ContLedgEntry."Bin Code" := "New Bin Code"; // P8000631A
                    ContLedgEntry.Quantity := -ContLedgEntry.Quantity;
                    ContLedgEntry."Entry No." := NextEntryNo;
                    ContLedgEntry.Insert;
                    NextEntryNo := NextEntryNo + 1;
                end;
            end;

            if "Entry Type" = "Entry Type"::Acquisition then
                CreateSerialInfo;

            if "Direct Posting" then
                case "Entry Type" of
                    "Entry Type"::Acquisition:
                        PostAcquisition;
                    "Entry Type"::Transfer:
                        PostTransfer;
                    "Entry Type"::Return:
                        PostReturn;
                    "Entry Type"::"Adjust Tare":
                        AdjustTareWeight;
                    "Entry Type"::Disposal:
                        PostDisposal;
                end;
        end;
    end;

    local procedure GetGLSetup()
    begin
        if not GLSetupRead then
            GLSetup.Get;
        GLSetupRead := true;
    end;

    procedure InitContLedger(ContJnlLine: Record "Container Journal Line"; var ContLedgEntry: Record "Container Ledger Entry")
    begin
        with ContJnlLine do begin
            ContLedgEntry.Init;

            ContLedgEntry."Container Item No." := "Container Item No.";
            ContLedgEntry."Container Serial No." := "Container Serial No.";
            ContLedgEntry."Entry Type" := "Entry Type";
            ContLedgEntry."Posting Date" := "Posting Date";
            ContLedgEntry."Document No." := "Document No.";
            ContLedgEntry."Document Date" := "Document Date";
            ContLedgEntry."External Document No." := "External Document No.";
            ContLedgEntry.Description := Description;
            ContLedgEntry."Source Code" := "Source Code";
            ContLedgEntry."Reason Code" := "Reason Code";
            ContLedgEntry."Global Dimension 1 Code" := "Shortcut Dimension 1 Code";
            ContLedgEntry."Global Dimension 2 Code" := "Shortcut Dimension 2 Code";
            ContLedgEntry."Dimension Set ID" := "Dimension Set ID"; // P8001133
            ContLedgEntry."Location Code" := "Location Code";
            ContLedgEntry."Bin Code" := "Bin Code"; // P8000631A
            if "Source No." <> '' then
                ContLedgEntry."Source Type" := "Source Type";
            ContLedgEntry."Source No." := "Source No.";
            ContLedgEntry."Container ID" := "Container ID";
            if "Entry Type" = "Entry Type"::Use then begin
                ContLedgEntry."Fill Item No." := "Fill Item No.";
                ContLedgEntry."Fill Variant Code" := "Fill Variant Code";
                ContLedgEntry."Fill Lot No." := "Fill Lot No.";
                ContLedgEntry."Fill Serial No." := "Fill Serial No.";
                ContLedgEntry."Fill Quantity" := "Fill Quantity";
                ContLedgEntry."Fill Quantity (Base)" := "Fill Quantity (Base)";
                ContLedgEntry."Fill Quantity (Alt.)" := "Fill Quantity (Alt.)";
                ContLedgEntry."Fill Unit of Measure Code" := "Fill Unit of Measure Code";
            end;
            if "Entry Type" = "Entry Type"::Transfer then
                ContLedgEntry.Quantity := -Quantity
            else
                ContLedgEntry.Quantity := Quantity;
            ContLedgEntry."Tare Weight" := "Tare Weight";
            ContLedgEntry."Tare Unit of Measure" := "Tare Unit of Measure";
            ContLedgEntry."User ID" := UserId;
        end;
    end;

    procedure CreateSerialInfo()
    var
        SerialNo: Record "Serial No. Information";
        Item: Record Item;
    begin
        with ContJnlLine do begin
            if "Container Serial No." = '' then
                exit;

            if SerialNo.Get("Container Item No.", '', "Container Serial No.") then
                exit;

            SerialNo.Init;
            SerialNo."Item No." := "Container Item No.";
            SerialNo."Variant Code" := '';
            SerialNo."Serial No." := "Container Serial No.";
            Item.Get("Container Item No.");
            SerialNo.Description := Item.Description;
            SerialNo."Tare Weight" := "Tare Weight";
            SerialNo."Tare Unit of Measure" := "Tare Unit of Measure";
            SerialNo.Insert(true);
        end;
    end;

    procedure PostAcquisition()
    var
        ItemJnlLine: Record "Item Journal Line";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        with ContJnlLine do begin
            ItemJnlLine.Init;
            ItemJnlLine.Validate("Posting Date", "Posting Date");
            ItemJnlLine."Document Date" := "Document Date";
            if "Source No." = '' then
                ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.")
            else begin
                ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::Purchase);
                ItemJnlLine.Validate("Source Type", "Source Type");
                ItemJnlLine.Validate("Source No.", "Source No.");
            end;
            ItemJnlLine.Validate("Document No.", "Document No.");
            ItemJnlLine.Validate("External Document No.", "External Document No.");
            ItemJnlLine.Validate("Item No.", "Container Item No.");
            ItemJnlLine.Validate(Description, Description);
            ItemJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code"; // P8001133
            ItemJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code"; // P8001133
            ItemJnlLine."Dimension Set ID" := "Dimension Set ID";                   // P8001133
            ItemJnlLine.Validate("Location Code", "Location Code");
            ItemJnlLine.Validate("Bin Code", "Bin Code"); // P8000631A
            ItemJnlLine.Validate("Source Code", "Source Code");
            ItemJnlLine.Validate("Reason Code", "Reason Code");
            ItemJnlLine.Validate(Quantity, Quantity);
            ItemJnlLine.Validate("Unit Amount", "Unit Amount");
            ItemJnlLine."Skip Container Posting" := true;

            if "Container Serial No." <> '' then begin
                CreateReservEntry.CreateReservEntryFor(
                  DATABASE::"Item Journal Line", ItemJnlLine."Entry Type", '', '', 0, 0, 1, 1, 1, "Container Serial No.", ''); // P8000325A, P8000466A, P8001132
                CreateReservEntry.CreateEntry("Container Item No.", '', "Location Code", Description, "Posting Date", 0D, 0, 3);
            end;

            ItemJnlPostLine.RunWithCheck(ItemJnlLine); // P8001133
            PostWhseJnlLine(ItemJnlLine); // P8000631A, P8001133
        end;
    end;

    procedure PostTransfer()
    var
        ItemJnlLine: Record "Item Journal Line";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        with ContJnlLine do begin
            ItemJnlLine.Init;
            ItemJnlLine.Validate("Posting Date", "Posting Date");
            ItemJnlLine."Document Date" := "Document Date";
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::Transfer);
            ItemJnlLine.Validate("Document No.", "Document No.");
            ItemJnlLine.Validate("External Document No.", "External Document No.");
            ItemJnlLine.Validate("Item No.", "Container Item No.");
            ItemJnlLine.Validate(Description, Description);
            ItemJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";     // P8001133
            ItemJnlLine."New Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code"; // P8001133
            ItemJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";     // P8001133
            ItemJnlLine."New Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code"; // P8001133
            ItemJnlLine."Dimension Set ID" := "Dimension Set ID";                       // P8001133
            ItemJnlLine."New Dimension Set ID" := "Dimension Set ID";                   // P8001133
            ItemJnlLine.Validate("Location Code", "Location Code");
            ItemJnlLine.Validate("New Location Code", "New Location Code");
            ItemJnlLine.Validate("Bin Code", "Bin Code");         // P8000631A
            ItemJnlLine.Validate("New Bin Code", "New Bin Code"); // P8000631A
            ItemJnlLine.Validate("Source Code", "Source Code");
            ItemJnlLine.Validate("Reason Code", "Reason Code");
            ItemJnlLine.Validate(Quantity, Quantity);
            ItemJnlLine.Validate("Unit Amount", "Unit Amount");
            ItemJnlLine."Skip Container Posting" := true;

            if "Container Serial No." <> '' then begin
                CreateReservEntry.CreateReservEntryFor(
                  DATABASE::"Item Journal Line", ItemJnlLine."Entry Type", '', '', 0, 0, 1, 1, 1, "Container Serial No.", ''); // P8000325A, P8000466A, P8001132
                CreateReservEntry.SetNewSerialLotNo("Container Serial No.", '');
                CreateReservEntry.CreateEntry("Container Item No.", '', "Location Code", Description, "Posting Date", 0D, 0, 3);
            end;

            ItemJnlPostLine.RunWithCheck(ItemJnlLine); // P8001133
            PostWhseJnlLine(ItemJnlLine); // P8000631A, P8001133
        end;
    end;

    procedure PostReturn()
    var
        InvSetup: Record "Inventory Setup";
        ItemJnlLine: Record "Item Journal Line";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        InvSetup.Get;

        with ContJnlLine do begin
            ItemJnlLine.Init;
            ItemJnlLine.Validate("Posting Date", "Posting Date");
            ItemJnlLine."Document Date" := "Document Date";
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::Transfer);
            ItemJnlLine.Validate("Document No.", "Document No.");
            ItemJnlLine.Validate("External Document No.", "External Document No.");
            ItemJnlLine.Validate("Item No.", "Container Item No.");
            ItemJnlLine.Validate(Description, Description);
            ItemJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";     // P8001133
            ItemJnlLine."New Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code"; // P8001133
            ItemJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";     // P8001133
            ItemJnlLine."New Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code"; // P8001133
            ItemJnlLine."Dimension Set ID" := "Dimension Set ID";                       // P8001133
            ItemJnlLine."New Dimension Set ID" := "Dimension Set ID";                   // P8001133
            ItemJnlLine.Validate("Location Code", InvSetup."Offsite Cont. Location Code");
            ItemJnlLine.Validate("New Location Code", "Location Code");
            ItemJnlLine.Validate("New Bin Code", "New Bin Code"); // P8000631A
            ItemJnlLine.Validate("Source Code", "Source Code");
            ItemJnlLine.Validate("Reason Code", "Reason Code");
            ItemJnlLine.Validate(Quantity, Quantity);
            ItemJnlLine.Validate("Unit Amount", "Unit Amount");
            ItemJnlLine."Skip Container Posting" := true;

            if "Container Serial No." <> '' then begin
                CreateReservEntry.CreateReservEntryFor(
                 DATABASE::"Item Journal Line", ItemJnlLine."Entry Type", '', '', 0, 0, 1, 1, 1, "Container Serial No.", ''); // P8000325A, P8000466A, P8001132
                CreateReservEntry.SetNewSerialLotNo("Container Serial No.", '');
                CreateReservEntry.CreateEntry("Container Item No.", '', "Location Code", Description, "Posting Date", 0D, 0, 3);
            end;

            ItemJnlPostLine.RunWithCheck(ItemJnlLine); // P8001133
            PostWhseJnlLine(ItemJnlLine); // P8000631A, P8001133
        end;
    end;

    procedure AdjustTareWeight()
    var
        SerialNo: Record "Serial No. Information";
    begin
        with ContJnlLine do begin
            SerialNo.Get("Container Item No.", '', "Container Serial No.");
            SerialNo."Tare Weight" := "Tare Weight";
            SerialNo."Tare Unit of Measure" := "Tare Unit of Measure";
            SerialNo.Modify;
        end;
    end;

    procedure PostDisposal()
    var
        ItemJnlLine: Record "Item Journal Line";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
    begin
        with ContJnlLine do begin
            ItemJnlLine.Init;
            ItemJnlLine.Validate("Posting Date", "Posting Date");
            ItemJnlLine."Document Date" := "Document Date";
            if "Source No." = '' then
                ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.")
            else begin
                ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::Sale);
                ItemJnlLine.Validate("Source Type", "Source Type");
                ItemJnlLine.Validate("Source No.", "Source No.");
            end;
            ItemJnlLine.Validate("Document No.", "Document No.");
            ItemJnlLine.Validate("External Document No.", "External Document No.");
            ItemJnlLine.Validate("Item No.", "Container Item No.");
            ItemJnlLine.Validate(Description, Description);
            ItemJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code"; // P8001133
            ItemJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code"; // P8001133
            ItemJnlLine."Dimension Set ID" := "Dimension Set ID";                   // P8001133
            ItemJnlLine.Validate("Location Code", "Location Code");
            ItemJnlLine.Validate("Bin Code", "Bin Code"); // P8000631A
            ItemJnlLine.Validate("Source Code", "Source Code");
            ItemJnlLine.Validate("Reason Code", "Reason Code");
            ItemJnlLine.Validate(Quantity, Quantity);
            ItemJnlLine.Validate("Unit Amount", "Unit Amount");
            ItemJnlLine."Skip Container Posting" := true;

            if "Container Serial No." <> '' then begin
                CreateReservEntry.CreateReservEntryFor(
                  DATABASE::"Item Journal Line", ItemJnlLine."Entry Type", '', '', 0, 0, 1, 1, 1, "Container Serial No.", ''); // P8000325A, P8000466A, P8001132
                CreateReservEntry.CreateEntry("Container Item No.", '', "Location Code", Description, 0D, "Posting Date", 0, 3);
            end;

            ItemJnlPostLine.RunWithCheck(ItemJnlLine); // P8001133
            PostWhseJnlLine(ItemJnlLine); // P8000631A, P8001133
        end;
    end;

    local procedure PostWhseJnlLine(var ItemJnlLine: Record "Item Journal Line")
    var
        TempHandlingSpecification: Record "Tracking Specification" temporary;
        WhseJnlLine: Record "Warehouse Journal Line";
        TempWhseJnlLine2: Record "Warehouse Journal Line" temporary;
        Location: Record Location;
    begin
        // P8000631A
        // P8001133 - remove parameter for TempJnlLineDim
        ItemJnlPostLine.CollectTrackingSpecification(TempHandlingSpecification);
        with ItemJnlLine do
            if Location.Get("Location Code") then begin
                if Location."Bin Mandatory" then
                    if WMSMgmt.CreateWhseJnlLine(ItemJnlLine, 0, WhseJnlLine, false) then begin // P8001132
                        ItemTrackingMgt.SplitWhseJnlLine(WhseJnlLine, TempWhseJnlLine2, TempHandlingSpecification, false);
                        if TempWhseJnlLine2.FindSet then
                            repeat
                                WMSMgmt.CheckWhseJnlLine(TempWhseJnlLine2, 1, 0, false);
                                WhseJnlPostLine.Run(TempWhseJnlLine2);
                            until TempWhseJnlLine2.Next = 0;
                    end;

                if "Entry Type" = "Entry Type"::Transfer then begin
                    Location.Get("New Location Code");
                    if Location."Bin Mandatory" then
                        if WMSMgmt.CreateWhseJnlLine(ItemJnlLine, 0, WhseJnlLine, true) then begin // P8001132
                            ItemTrackingMgt.SplitWhseJnlLine(WhseJnlLine, TempWhseJnlLine2, TempHandlingSpecification, true);
                            if TempWhseJnlLine2.FindSet then
                                repeat
                                    WMSMgmt.CheckWhseJnlLine(TempWhseJnlLine2, 1, 0, true);
                                    WhseJnlPostLine.Run(TempWhseJnlLine2);
                                until TempWhseJnlLine2.Next = 0;
                        end;
                end;
            end;
    end;

    procedure SetContainerJournalUsageDate(UsageDate: Date)
    begin
        // P8007012
        ContainerJournalUsageDate := UsageDate;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Container Line", 'GetUsageDate', '', true, false)]
    local procedure ContainerLine_OnGetUsageDate(var UsageDate: Date)
    begin
        // P8007012
        if ContainerJournalUsageDate <> 0D then
            UsageDate := ContainerJournalUsageDate;
    end;
}

