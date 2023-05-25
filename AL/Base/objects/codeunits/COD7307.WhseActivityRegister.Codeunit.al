codeunit 7307 "Whse.-Activity-Register"
{
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Support for alternate quantites
    // 
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 29 JUL 06
    //   Add Breakbulk field for Undo
    //   Add Hidden Documents
    //   Check for blocked lots on pick for sales
    //   Staged Picks
    // 
    // P8000358A, VerticalSoft, Phyllis McGovern, 26 JUL 06
    //   Added logic to clear 'ADC Started'
    // 
    // PR5.00
    // P8000503A, VerticalSoft, Don Bresee, 13 FEB 07
    //   Rounding re-work
    // 
    // PRW15.00.01
    // P8000553A, VerticalSoft, Jack Reynolds, 12 DEC 07
    //   Fix problem with setting base quantity on wahouse activity lines to zero
    // 
    // P8000596A, VerticalSoft, Jack Reynolds, 27 MAR 08
    //   Fix problem updating tracking when registering picks
    // 
    // PRW15.00.03
    // P8000630A, VerticalSoft, Don Bresee, 17 SEP 08
    //   Add logic for delivery trip documents
    // 
    // P8000654, VerticalSoft, Jack Reynolds, 07 JAN 09
    //   Bring the NAV 2009 versions of RegisterWhseItemTrkgLine and UpdateTempTracking into this codeunit
    // 
    // PRW16.00
    // P8000642, VerticalSoft, Jack Reynolds, 20 NOV 08
    //   Remove P8000596A and P8000654 modifcations and references
    // 
    // PRW16.00.02
    // P8000756, VerticalSoft, Jack Reynolds, 13 JAN 10
    //   P800 code removed since it is not standard
    // 
    // PRW17.10.02
    // P8001280, Columbus IT, Don Bresee, 06 FEB 14
    //   Add logic to Combine Reg. Whse. Activities
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
    // 
    // P8004516, To-Increase, Jack Reynolds, 17 MAR 16
    //   Incorporate modifications for NAV Anywhere processes
    // 
    // PRW19.00.01
    // P8007397, To-Increase, Jack Reynolds, 28 JUN 16
    //   Fix problem moving entire containers and creation of adjustment
    // 
    //                 P8006916, To-Increase, Jack Reynolds, 31 AUG 16
    //   FOOD-TOM Separation
    // 
    // P8007961, To-Increase, Jack Reynolds, 27 OCT 16
    //   Fix license problems with containers
    // 
    // PRW110.0
    // P8008172, To-Increase, Dayakar Battini, 09 DEC 16
    //   Lifecycle Management
    // 
    //     P8008297, To-Increase, Dayakar Battini, 18 DEC 16
    //   Lifecycle settings fields cleanup
    // 
    // P8008361, To-Increase, Dayakar Battini, 30-01-2017
    //   Maintain delivery trip no. in RegisterContainer() logic
    // 
    // PRW110.0.01
    // P80043567, To-Increase, Dayakar Battini, 13 JUL 17
    //   Fix for wrong item tracking updation from pick registrations.
    // 
    // PRW110.0.02
    // P80049026, To-Increase, Dayakar Battini, 17 NOV 17
    //   "Combine Reg. Whse. Activities" requires modify permissions.
    // 
    // P80051252, To-Increase, Dayakar Battini, 10 JAN 18
    //   Advance Whse. Install check for staged pick
    // 
    // P80052890, To-Increase, Dayakar Battini, 08 FEB 18
    //   Fix issue with lot tracked partial pick registration.
    // 
    // P80050544, To-Increase, Dayakar Battini, 12 FEB 18
    //   Upgrade to 2017 CU13
    // 
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers
    // 
    // PRW111.00.01
    // P80056710, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - create production container from pick
    // 
    // PRW111.00.02
    // P80066185, To-Increase, Jack Reynolds, 16 OCT 18
    //   Remove changes from P80052890
    // 
    // P80068361, To-Increase, Gangabhushan, 17 DEC 18
    //   TI-12507 - Container loses catch weight qty. during registration of Put away/Pick
    // 
    // P80070336, To Increase, Jack Reynolds, 12 FEB 19
    //   Fix issue with Alternate Quantity to Handle
    // 
    // P80071300, To-Increase, Jack Reynolds, 08 MAR 19
    //   Qty Remaining Alt. in ILE -Issue
    // 
    // PRW111.00.03
    // P80075420, To-Increase, Jack Reynolds, 08 JUL 19
    //   Problem losing tracking when using containers and specifying alt quantity to handle
    // 
    // P80077569, To-Increase, Gangabhushan, 16 JUL 19
    //   CS00069439 - Item tracking that is pre-defined in S.O. will now allow pick registration with qty. - Error
    // 
    // P80079981, To-Increase, Gangabhushan, 23 AUG 19
    //   Qty to Handle data not get refreshed in Pick lines for Multiple UOM functionality.
    //   Code moved to Codeunit 37002080
    // 
    // P80082431, To-increase, Gangabhushan, 23 SEP 19
    //   CS00075223 - Orders are removed from trips when using resolve shorts
    //
    // PRW117.00.03
    // P800110480, To-Increase, Gangabhushan, 25 MAR 21
    //   Container Pick and Ship
    //
    // PRW114.00.03
    //   P800128454, To Increase, Jack Reynolds, 12 AUG 21
    //     Anywhere support for overpicking production containers

    Permissions = TableData "Registered Whse. Activity Hdr." = im,
                  TableData "Registered Whse. Activity Line" = im,
                  TableData "Whse. Item Tracking Line" = rim,
                  TableData "Warehouse Journal Batch" = imd,
                  TableData "Posted Whse. Receipt Header" = m,
                  TableData "Posted Whse. Receipt Line" = m,
                  TableData "Registered Invt. Movement Hdr." = i,
                  TableData "Registered Invt. Movement Line" = i;
    TableNo = "Warehouse Activity Line";

    trigger OnRun()
    begin
        GlobalWhseActivLine.Copy(Rec);
        GlobalWhseActivLine.SetAutoCalcFields();
        Code();
        Rec := GlobalWhseActivLine;
    end;

    var
        Text000: Label 'Warehouse Activity    #1##########\\';
        Text001: Label 'Checking lines        #2######\';
        Text002: Label 'Registering lines     #3###### @4@@@@@@@@@@@@@';
        Location: Record Location;
        Item: Record Item;
        GlobalWhseActivHeader: Record "Warehouse Activity Header";
        GlobalWhseActivLine: Record "Warehouse Activity Line";
        RegisteredWhseActivHeader: Record "Registered Whse. Activity Hdr.";
        RegisteredWhseActivLine: Record "Registered Whse. Activity Line";
        RegisteredInvtMovementHdr: Record "Registered Invt. Movement Hdr.";
        RegisteredInvtMovementLine: Record "Registered Invt. Movement Line";
        WhseShptHeader: Record "Warehouse Shipment Header";
        PostedWhseRcptHeader: Record "Posted Whse. Receipt Header";
        WhseInternalPickHeader: Record "Whse. Internal Pick Header";
        WhseInternalPutAwayHeader: Record "Whse. Internal Put-away Header";
        PostedWhseRcptLine: Record "Posted Whse. Receipt Line";
        WhseInternalPickLine: Record "Whse. Internal Pick Line";
        WhseInternalPutAwayLine: Record "Whse. Internal Put-away Line";
        ProdCompLine: Record "Prod. Order Component";
        AssemblyLine: Record "Assembly Line";
        JobPlanningLine: Record "Job Planning Line";
        ProdOrder: Record "Production Order";
        AssemblyHeader: Record "Assembly Header";
        Job: Record "Job";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        TempBinContentBuffer: Record "Bin Content Buffer" temporary;
        SourceCodeSetup: Record "Source Code Setup";
        Cust: Record Customer;
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WhseJnlRegisterLine: Codeunit "Whse. Jnl.-Register Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Window: Dialog;
        NoOfRecords: Integer;
        LineCount: Integer;
        HideDialog: Boolean;
        Text003: Label 'There is nothing to register.';
        InsufficientQtyItemTrkgErr: Label 'Item tracking defined for source line %1 of %2 %3 amounts to more than the quantity you have entered.\\You must adjust the existing item tracking specification and then reenter a new quantity.', Comment = '%1=Source Line No.,%2=Source Document,%3=Source No.';
        InventoryNotAvailableErr: Label '%1 %2 is not available on inventory or it has already been reserved for another document.';
        P800Functions: Codeunit "Process 800 Functions";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        HiddenDocMgmt: Codeunit "Process 800 Create Whse. Act.";
        WhseStagedPickHeader: Record "Whse. Staged Pick Header";
        WhseStagedPickLine: Record "Whse. Staged Pick Line";
        WhseStagedPickMgmt: Codeunit "Whse. Staged Pick Mgmt.";
        UseExistingRegActivHeader: Boolean;
        ContainerFns: Codeunit "Container Functions";
        OriginalContainerLine: Record "Container Line" temporary;
        PostContainerLine: Record "Container Line";
        ProcessFns: Codeunit "Process 800 Functions";
        DLMText000: Label 'The present status of this document is not allowed to carry out this action. Please contact Administrator and check with Lifecycle settings.';
        TempWhseShptLine: Record "Warehouse Shipment Line" temporary;
        TempPalceContainerActivityLine: Record "Warehouse Activity Line" temporary;
        Text37002000: Label 'Item %1 is not available in container %2.';
        Text37002001: Label 'Container %1 contains items not on the pick.';
        OrderToOrderBindingOnSalesLineQst: Label 'Registering the pick will remove the existing order-to-order reservation for the sales order.\Do you want to continue?';
        RegisterInterruptedErr: Label 'The action has been interrupted to respect the warning.';
        SuppressCommit: Boolean;

    local procedure "Code"()
    var
        OldWhseActivLine: Record "Warehouse Activity Line";
        TempWhseActivLineToReserve: Record "Warehouse Activity Line" temporary;
        TempWhseActivityLineGrouped: Record "Warehouse Activity Line" temporary;
        SkipDelete: Boolean;
        ShouldDeleteOldLine: Boolean;
        OrderShippingReceiving: Codeunit "Order Shipping-Receiving";
    begin
        BindSubscription(OrderShippingReceiving); // P80070336
        OnBeforeCode(GlobalWhseActivLine);

        with GlobalWhseActivHeader do begin
            GlobalWhseActivLine.SetRange("Activity Type", GlobalWhseActivLine."Activity Type");
            GlobalWhseActivLine.SetRange("No.", GlobalWhseActivLine."No.");
            GlobalWhseActivLine.SetFilter("Qty. to Handle (Base)", '<>0');

            CheckWhseActivLineIsEmpty(GlobalWhseActivLine);
            LocationGet(GlobalWhseActivLine."Location Code"); // P8000322A

            MaintainZeroLines(GlobalWhseActivLine);

            // CheckWhseItemTrkgLine(GlobalWhseActivLine); // P8000503A

            Get(GlobalWhseActivLine."Activity Type", GlobalWhseActivLine."No.");
            //  LocationGet("Location Code"); // P8000322A

            UpdateWindow(1, "No.");

            BalanceBaseQtysFromSource(GlobalWhseActivLine); // P8000503A

            // Check Lines
            CheckLines();
            OnCodeOnAfterCheckLines(GlobalWhseActivHeader);

            HiddenDocMgmt.StoreHiddenDocuments(GlobalWhseActivLine); // P8000322A

            // Register lines
            SourceCodeSetup.Get();
            LineCount := 0;
            CreateRegActivHeader(GlobalWhseActivHeader);
            if ProcessFns.ContainerTrackingInstalled then // P8007961
                UpdateContainerBeforeMovement(GlobalWhseActivLine, TempPalceContainerActivityLine); // P8001323, P800-MegaApp

            TempWhseActivLineToReserve.DeleteAll();
            TempWhseActivityLineGrouped.DeleteAll();

            GlobalWhseActivLine.LockTable();
            WhseJnlRegisterLine.LockTables();

            // breakbulk first to provide quantity for pick lines in smaller UoM
            GlobalWhseActivLine.SetFilter("Breakbulk No.", '<>0');
            RegisterWhseActivityLines(GlobalWhseActivLine, TempWhseActivLineToReserve, TempWhseActivityLineGrouped);

            GlobalWhseActivLine.SetRange("Breakbulk No.", 0);
            RegisterWhseActivityLines(GlobalWhseActivLine, TempWhseActivLineToReserve, TempWhseActivityLineGrouped);
            GlobalWhseActivLine.SetRange("Breakbulk No.");

            OnCodeOnBeforeTempWhseActivityLineGroupedLoop(GlobalWhseActivHeader, GlobalWhseActivLine, RegisteredWhseActivHeader);
            if ProcessFns.ContainerTrackingInstalled then // P8007961, P800-MegaApp
                UpdateContainerAfterMovement(TempPalceContainerActivityLine); // P8001323, P800-MegaApp
            TempWhseActivityLineGrouped.Reset();
            if TempWhseActivityLineGrouped.FindSet() then
                repeat
                    if Type <> Type::Movement then
                        UpdateWhseSourceDocLine(TempWhseActivityLineGrouped);
                    UpdateWhseDocHeader(TempWhseActivityLineGrouped);
                    TempWhseActivityLineGrouped.DeleteBinContent("Warehouse Action Type"::Take.AsInteger());
                until TempWhseActivityLineGrouped.Next() = 0;

            SyncItemTrackingAndReserveSourceDocument(TempWhseActivLineToReserve);
            FixWhseShptLineTracking; // P80046533

            if P800Functions.AltQtyInstalled() then                         // P8000282A
                AltQtyMgmt.UpdateWhseShptTracking(RegisteredWhseActivHeader); // P8000282A

            if Location."Bin Mandatory" then begin
                LineCount := 0;
                Clear(OldWhseActivLine);
                GlobalWhseActivLine.Reset();
                GlobalWhseActivLine.SetCurrentKey(
                  "Activity Type", "No.", "Whse. Document Type", "Whse. Document No.");
                GlobalWhseActivLine.SetRange("Activity Type", Type);
                GlobalWhseActivLine.SetRange("No.", "No.");
                if GlobalWhseActivLine.Find('-') then
                    repeat
                        ShouldDeleteOldLine := (LineCount = 1) and
                            ((OldWhseActivLine."Whse. Document Type" <> GlobalWhseActivLine."Whse. Document Type") or
                             (OldWhseActivLine."Whse. Document No." <> GlobalWhseActivLine."Whse. Document No."));
                        OnCodeOnAfterCalcShouldDeleteOldLine(OldWhseActivLine, GlobalWhseActivLine, ShouldDeleteOldLine);
                        if ShouldDeleteOldLine then begin
                            LineCount := 0;
                            OldWhseActivLine.Delete();
                        end;
                        OldWhseActivLine := GlobalWhseActivLine;
                        LineCount := LineCount + 1;
                    until GlobalWhseActivLine.Next() = 0;
                if LineCount = 1 then
                    OldWhseActivLine.Delete();
            end;
            OnBeforeUpdWhseActivHeader(GlobalWhseActivHeader, GlobalWhseActivLine);
            GlobalWhseActivLine.Reset();
            GlobalWhseActivLine.SetRange("Activity Type", Type);
            GlobalWhseActivLine.SetRange("No.", "No.");
            GlobalWhseActivLine.SetFilter("Qty. Outstanding", '<>%1', 0);
            if not GlobalWhseActivLine.Find('-') then begin
                SkipDelete := false;
                OnBeforeWhseActivHeaderDelete(GlobalWhseActivHeader, SkipDelete);
                if not SkipDelete then
                    Delete(true);
            end else begin
                "ADC Started" := false; // P8000358A
                "Last Registering No." := "Registering No.";
                "Registering No." := '';
                Modify();
                AutofillQtyToHandle(GlobalWhseActivLine);
            end;

            HiddenDocMgmt.UpdateHiddenDocuments; // P8000322A

            if not HideDialog then
                Window.Close();

            OnCodeOnBeforeCommit(RegisteredWhseActivHeader, RegisteredWhseActivLine, SuppressCommit);
            if not SuppressCommit then begin
                OnBeforeCommit(GlobalWhseActivHeader);
                Commit();
            end;
            Clear(WhseJnlRegisterLine);
        end;

        OnAfterRegisterWhseActivity(GlobalWhseActivHeader);
    end;

    local procedure RegisterWhseActivityLines(var WarehouseActivityLine: Record "Warehouse Activity Line"; var TempWhseActivLineToReserve: Record "Warehouse Activity Line" temporary; var TempWhseActivityLineGrouped: Record "Warehouse Activity Line" temporary)
    var
        QtyDiff: Decimal;
        QtyBaseDiff: Decimal;
        SkipDelete: Boolean;
    begin
        OnBeforeRegisterWhseActivityLines(WarehouseActivityLine);

        with WarehouseActivityLine do begin
            if not FindSet() then
                exit;

            repeat
                LineCount := LineCount + 1;
                UpdateWindow(3, '');
                UpdateWindow(4, '');
                if Location."Bin Mandatory" then
                    RegisterWhseJnlLine(WarehouseActivityLine);
                CreateRegActivLine(WarehouseActivityLine);
                OnAfterCreateRegActivLine(WarehouseActivityLine, RegisteredWhseActivLine, RegisteredInvtMovementLine);

                DeleteAltQtys; // P8000282A
                // CopyWhseActivityLineToReservBuf(TempWhseActivLineToReserve, WarehouseActivityLine); // P80075420
                GroupWhseActivLinesByWhseDocAndSource(TempWhseActivityLineGrouped, WarehouseActivityLine);

                if "Activity Type" <> "Activity Type"::Movement then
                    RegisterWhseItemTrkgLine(WarehouseActivityLine);
                OnAfterFindWhseActivLine(WarehouseActivityLine);
                // if "Qty. Outstanding" = "Qty. to Handle" then begin // P8000282A
                if ("Qty. Outstanding" = "Qty. to Handle") or (WarehouseActivityLine."Activity Type" = WarehouseActivityLine."Activity Type"::Pick) then begin // P8000282A
                    SkipDelete := false;
                    OnBeforeWhseActivLineDelete(WarehouseActivityLine, SkipDelete);
                    if not SkipDelete then
                        Delete();
                end else begin
                    QtyDiff := "Qty. Outstanding" - "Qty. to Handle";
                    QtyBaseDiff := "Qty. Outstanding (Base)" - "Qty. to Handle (Base)";
                    UpdateWhseActivLineQtyOutstanding(WarehouseActivityLine, QtyDiff, QtyBaseDiff);
                    UpdateWarehouseActivityLineQtyToHandle(WarehouseActivityLine, QtyDiff, QtyBaseDiff);
                    OnBeforeWhseActivLineModify(WarehouseActivityLine);
                    Modify();
                end;
            until Next() = 0;
        end;

        OnAfterRegisterWhseActivityLines(WarehouseActivityLine);
    end;

    local procedure UpdateWhseActivLineQtyOutstanding(var WarehouseActivityLine: Record "Warehouse Activity Line"; QtyDiff: Decimal; QtyBaseDiff: Decimal)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateWhseActivLineQtyOutstanding(WarehouseActivityLine, QtyDiff, QtyBaseDiff, HideDialog, IsHandled);
        if IsHandled then
            exit;

        with WarehouseActivityLine do begin
            Validate("Qty. Outstanding", QtyDiff);
            if "Qty. Outstanding (Base)" > QtyBaseDiff then // round off error- qty same, not base qty
                "Qty. Outstanding (Base)" := QtyBaseDiff;
        end;
    end;

    local procedure UpdateWarehouseActivityLineQtyToHandle(var WarehouseActivityLine: Record "Warehouse Activity Line"; QtyDiff: Decimal; QtyBaseDiff: Decimal)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateWarehouseActivityLineQtyToHandle(WarehouseActivityLine, QtyDiff, QtyBaseDiff, HideDialog, IsHandled);
        if IsHandled then
            exit;

        with WarehouseActivityLine do begin
            Validate("Qty. to Handle", QtyDiff);
            if "Qty. to Handle (Base)" > QtyBaseDiff then // round off error- qty same, not base qty
                "Qty. to Handle (Base)" := QtyBaseDiff;
            if HideDialog then
                Validate("Qty. to Handle", 0);
            Validate("Qty. Handled", Quantity - "Qty. Outstanding");
            // P8000282A
            if TrackAlternateUnits() then begin
                Validate("Quantity Handled (Alt.)", "Quantity Handled (Alt.)" + "Qty. to Handle (Alt.)");
                Validate("Qty. to Handle (Alt.)", 0);
            end;
            // P8000282A
        end;
    end;

    local procedure RegisterWhseJnlLine(WhseActivLine: Record "Warehouse Activity Line")
    var
        WhseJnlLine: Record "Warehouse Journal Line";
        WMSMgt: Codeunit "WMS Management";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeRegisterWhseJnlLine(WhseActivLine, RegisteredWhseActivHeader, IsHandled);
        if IsHandled then
            exit;

        with WhseActivLine do begin
            WhseJnlLine.Init();
            WhseJnlLine."Location Code" := "Location Code";
            WhseJnlLine."Item No." := "Item No.";
            WhseJnlLine."Registering Date" := WorkDate();
            WhseJnlLine."User ID" := CopyStr(UserId(), 1, MaxStrLen(WhseJnlLine."User ID"));
            WhseJnlLine."Variant Code" := "Variant Code";
            WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::Movement;
            if "Action Type" = "Action Type"::Take then begin
                WhseJnlLine."From Zone Code" := "Zone Code";
                WhseJnlLine."From Bin Code" := "Bin Code";
            end else begin
                WhseJnlLine."To Zone Code" := "Zone Code";
                WhseJnlLine."To Bin Code" := "Bin Code";
            end;
            WhseJnlLine.Description := Description;

            LocationGet("Location Code");
            if Location."Directed Put-away and Pick" then begin
                WhseJnlLine.Quantity := "Qty. to Handle";
                WhseJnlLine."Unit of Measure Code" := "Unit of Measure Code";
                WhseJnlLine."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
                WhseJnlLine."Qty. Rounding Precision" := "Qty. Rounding Precision";
                WhseJnlLine."Qty. Rounding Precision (Base)" := "Qty. Rounding Precision (Base)";

                GetItemUnitOfMeasure("Item No.", "Unit of Measure Code");
                WhseJnlLine.Cubage :=
                  Abs(WhseJnlLine.Quantity) * ItemUnitOfMeasure.Cubage;
                WhseJnlLine.Weight :=
                  Abs(WhseJnlLine.Quantity) * ItemUnitOfMeasure.Weight;
            end else begin
                WhseJnlLine.Quantity := "Qty. to Handle (Base)";
                WhseJnlLine."Unit of Measure Code" := WMSMgt.GetBaseUOM("Item No.");
                WhseJnlLine."Qty. per Unit of Measure" := 1;
            end;
            WhseJnlLine."Qty. (Base)" := "Qty. to Handle (Base)";
            WhseJnlLine."Qty. (Absolute)" := WhseJnlLine.Quantity;
            WhseJnlLine."Qty. (Absolute, Base)" := "Qty. to Handle (Base)";

            WhseJnlLine.SetSource("Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
            WhseJnlLine."Source Document" := "Source Document";
            WhseJnlLine."Reference No." := RegisteredWhseActivHeader."No.";
            case "Activity Type" of
                "Activity Type"::"Put-away":
                    begin
                        WhseJnlLine."Source Code" := SourceCodeSetup."Whse. Put-away";
                        WhseJnlLine.SetWhseDocument("Whse. Document Type", "Whse. Document No.", "Whse. Document Line No.");
                        WhseJnlLine."Reference Document" := WhseJnlLine."Reference Document"::"Put-away";
                    end;
                "Activity Type"::Pick:
                    begin
                        WhseJnlLine."Source Code" := SourceCodeSetup."Whse. Pick";
                        WhseJnlLine.SetWhseDocument("Whse. Document Type", "Whse. Document No.", "Whse. Document Line No.");
                        WhseJnlLine."Reference Document" := WhseJnlLine."Reference Document"::Pick;
                    end;
                "Activity Type"::Movement:
                    begin
                        WhseJnlLine."Source Code" := SourceCodeSetup."Whse. Movement";
                        WhseJnlLine."Whse. Document Type" := WhseJnlLine."Whse. Document Type"::" ";
                        WhseJnlLine."Reference Document" := WhseJnlLine."Reference Document"::Movement;
                    end;
                "Activity Type"::"Invt. Put-away",
              "Activity Type"::"Invt. Pick",
              "Activity Type"::"Invt. Movement":
                    WhseJnlLine."Whse. Document Type" := WhseJnlLine."Whse. Document Type"::" ";
            end;
            WhseActivLine.ValidateQtyWhenSNDefined();
            WhseJnlLine.CopyTrackingFromWhseActivityLine(WhseActivLine);
            WhseJnlLine."Warranty Date" := "Warranty Date";
            WhseJnlLine."Expiration Date" := "Expiration Date";
            OnBeforeWhseJnlRegisterLine(WhseJnlLine, WhseActivLine);
            WhseJnlRegisterLine.Run(WhseJnlLine);
        end;

        if P800Functions.AdvWhseInstalled then  // P80051252
            WhseStagedPickMgmt.UpdateStgdPickSourceLineOnReg(WhseActivLine); // P8000322A
    end;

    local procedure CreateRegActivHeader(WhseActivHeader: Record "Warehouse Activity Header")
    var
        WhseCommentLine: Record "Warehouse Comment Line";
        WhseCommentLine2: Record "Warehouse Comment Line";
        RecordLinkManagement: Codeunit "Record Link Management";
        TableNameFrom: Option;
        TableNameTo: Option;
        RegisteredType: Enum "Warehouse Activity Type";
        RegisteredNo: Code[20];
        IsHandled: Boolean;
    begin
        OnBeforeCreateRegActivHeader(WhseActivHeader, IsHandled, RegisteredWhseActivHeader, RegisteredInvtMovementHdr);
        if IsHandled then
            exit;

        TableNameFrom := WhseCommentLine."Table Name"::"Whse. Activity Header";
        if WhseActivHeader.Type = WhseActivHeader.Type::"Invt. Movement" then begin
            RegisteredInvtMovementHdr.Init();
            RegisteredInvtMovementHdr.TransferFields(WhseActivHeader);
            RegisteredInvtMovementHdr."No." := WhseActivHeader."Registering No.";
            RegisteredInvtMovementHdr."Invt. Movement No." := WhseActivHeader."No.";
            OnBeforeRegisteredInvtMovementHdrInsert(RegisteredInvtMovementHdr, WhseActivHeader);
            RegisteredInvtMovementHdr.Insert();
            RecordLinkManagement.CopyLinks(WhseActivHeader, RegisteredInvtMovementHdr);
            OnAfterRegisteredInvtMovementHdrInsert(RegisteredInvtMovementHdr, WhseActivHeader);

            TableNameTo := WhseCommentLine."Table Name"::"Registered Invt. Movement";
            RegisteredType := RegisteredType::" ";
            RegisteredNo := RegisteredInvtMovementHdr."No.";
        end else begin
            if not UseExistingRegActivHeader then begin // P8001280
                RegisteredWhseActivHeader.Init();
                RegisteredWhseActivHeader.TransferFields(WhseActivHeader);
                RegisteredWhseActivHeader.Type := WhseActivHeader.Type;
                RegisteredWhseActivHeader."No." := WhseActivHeader."Registering No.";
                RegisteredWhseActivHeader."Whse. Activity No." := WhseActivHeader."No.";
                RegisteredWhseActivHeader."Registering Date" := WorkDate();
                RegisteredWhseActivHeader."No. Series" := WhseActivHeader."Registering No. Series";
                OnBeforeRegisteredWhseActivHeaderInsert(RegisteredWhseActivHeader, WhseActivHeader);
                RegisteredWhseActivHeader.Insert();
                RecordLinkManagement.CopyLinks(WhseActivHeader, RegisteredWhseActivHeader);
                OnAfterRegisteredWhseActivHeaderInsert(RegisteredWhseActivHeader, WhseActivHeader);
            end; // P8001280

            TableNameTo := WhseCommentLine2."Table Name"::"Rgstrd. Whse. Activity Header";
            RegisteredType := RegisteredWhseActivHeader.Type;
            RegisteredNo := RegisteredWhseActivHeader."No.";
        end;

        WhseCommentLine.SetRange("Table Name", TableNameFrom);
        WhseCommentLine.SetRange(Type, WhseActivHeader.Type);
        WhseCommentLine.SetRange("No.", WhseActivHeader."No.");
        WhseCommentLine.LockTable();

        if WhseCommentLine.Find('-') then
            repeat
                WhseCommentLine2.Init();
                WhseCommentLine2 := WhseCommentLine;
                WhseCommentLine2."Table Name" := TableNameTo;
                WhseCommentLine2.Type := RegisteredType;
                WhseCommentLine2."No." := RegisteredNo;
                // P8001280
                // WhseCommentLine2.INSERT;
                if not WhseCommentLine2.Insert() then
                    WhseCommentLine2.Modify();
            // P8001280
            until WhseCommentLine.Next() = 0;

        OnAfterCreateRegActivHeader(WhseActivHeader);
    end;

    local procedure CreateRegActivLine(WhseActivLine: Record "Warehouse Activity Line")
    begin
        if WhseActivLine."Activity Type" = WhseActivLine."Activity Type"::"Invt. Movement" then begin
            RegisteredInvtMovementLine.Init();
            RegisteredInvtMovementLine.TransferFields(WhseActivLine);
            RegisteredInvtMovementLine."No." := RegisteredInvtMovementHdr."No.";
            OnAfterInitRegInvtMovementLine(WhseActivLine, RegisteredInvtMovementLine);
            RegisteredInvtMovementLine.Validate(Quantity, WhseActivLine."Qty. to Handle");
            OnBeforeRegisteredInvtMovementLineInsert(RegisteredInvtMovementLine, WhseActivLine);
            RegisteredInvtMovementLine.Insert();
            OnAfterRegisteredInvtMovementLineInsert(RegisteredInvtMovementLine, WhseActivLine);
            // P8001280
        end else
            if FindExistingRegActivLine() then begin
                RegisteredWhseActivLine.Quantity := RegisteredWhseActivLine.Quantity + WhseActivLine."Qty. to Handle";
                RegisteredWhseActivLine."Qty. (Base)" := RegisteredWhseActivLine."Qty. (Base)" + WhseActivLine."Qty. to Handle (Base)";
                RegisteredWhseActivLine.Modify();
                // P8001280
            end else begin
                RegisteredWhseActivLine.Init();
                RegisteredWhseActivLine.TransferFields(WhseActivLine);
                RegisteredWhseActivLine."Activity Type" := RegisteredWhseActivHeader.Type;
                RegisteredWhseActivLine."No." := RegisteredWhseActivHeader."No.";
                OnAfterInitRegActLine(WhseActivLine, RegisteredWhseActivLine);
                RegisteredWhseActivLine.Quantity := WhseActivLine."Qty. to Handle";
                RegisteredWhseActivLine."Qty. (Base)" := WhseActivLine."Qty. to Handle (Base)";
                RegisteredWhseActivLine."Quantity (Alt.)" := WhseActivLine."Qty. to Handle (Alt.)"; // P8001323
                RegisteredWhseActivLine."Breakbulk No." := WhseActivLine."Breakbulk No."; // P8000322A
                AssignRegWhseActivLineNo; // P8001280
                OnBeforeRegisteredWhseActivLineInsert(RegisteredWhseActivLine, WhseActivLine);
                RegisteredWhseActivLine.Insert();
                OnAfterRegisteredWhseActivLineInsert(RegisteredWhseActivLine, WhseActivLine);
            end;
    end;

    procedure UpdateWhseSourceDocLine(WhseActivLineGrouped: Record "Warehouse Activity Line")
    var
        WhseDocType2: Enum "Warehouse Activity Document Type";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateWhseSourceDocLine(WhseActivLineGrouped, IsHandled);
        if IsHandled then
            exit;

        with WhseActivLineGrouped do begin
            if "Original Breakbulk" then
                exit;

            if ("Whse. Document Type" = "Whse. Document Type"::Shipment) and "Assemble to Order" then
                WhseDocType2 := "Whse. Document Type"::Assembly
            else
                WhseDocType2 := "Whse. Document Type";
            case WhseDocType2 of
                "Whse. Document Type"::Shipment:
                    if ("Action Type" <> "Action Type"::Take) and ("Breakbulk No." = 0) then
                        UpdateWhseShipmentLine(
                          WhseActivLineGrouped, "Whse. Document No.", "Whse. Document Line No.",
                          "Qty. to Handle", "Qty. to Handle (Base)", "Qty. per Unit of Measure");
                "Whse. Document Type"::"Internal Pick":
                    if ("Action Type" <> "Action Type"::Take) and ("Breakbulk No." = 0) then
                        UpdateWhseIntPickLine(WhseActivLineGrouped);
                "Whse. Document Type"::Production:
                    if ("Action Type" <> "Action Type"::Take) and ("Breakbulk No." = 0) then
                        UpdateProdCompLine(WhseActivLineGrouped);
                "Whse. Document Type"::Assembly:
                    if ("Action Type" <> "Action Type"::Take) and ("Breakbulk No." = 0) then
                        UpdateAssemblyLine(WhseActivLineGrouped);
                "Whse. Document Type"::Receipt:
                    if "Action Type" <> "Action Type"::Place then
                        UpdatePostedWhseRcptLine(WhseActivLineGrouped);
                "Whse. Document Type"::"Internal Put-away":
                    if "Action Type" <> "Action Type"::Take then
                        UpdateWhseIntPutAwayLine(WhseActivLineGrouped);
                "Whse. Document Type"::Job:
                    if ("Action Type" <> "Action Type"::Take) and ("Breakbulk No." = 0) then
                        UpdateJobPlanningLine(WhseActivLineGrouped);
                "Whse. Document Type"::FOODStagedPick:
                    if ("Action Type" <> "Action Type"::Take) and ("Breakbulk No." = 0) then
                        UpdateWhseStgdPickLine(WhseActivLineGrouped); // P800-MegaApp
            end;

            if "Activity Type" = "Activity Type"::"Invt. Movement" then
                UpdateSourceDocForInvtMovement(WhseActivLineGrouped);
        end;

        OnAfterUpdateWhseSourceDocLine(WhseActivLineGrouped, WhseDocType2.AsInteger());
    end;

    procedure UpdateWhseDocHeader(WhseActivLine: Record "Warehouse Activity Line")
    var
        WhsePutAwayRqst: Record "Whse. Put-away Request";
        WhsePickRqst: Record "Whse. Pick Request";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateWhseDocHeader(WhseActivLine, IsHandled);
        if IsHandled then
            exit;

        with WhseActivLine do
            case "Whse. Document Type" of
                "Whse. Document Type"::Shipment:
                    if "Action Type" <> "Action Type"::Take then begin
                        WhseShptHeader.Get("Whse. Document No.");
                        WhseShptHeader.Validate(
                          "Document Status", WhseShptHeader.GetDocumentStatus(0));
                        WhseShptHeader.Modify();
                    end;
                "Whse. Document Type"::Receipt:
                    if "Action Type" <> "Action Type"::Place then begin
                        PostedWhseRcptHeader.Get("Whse. Document No.");
                        PostedWhseRcptLine.Reset();
                        PostedWhseRcptLine.SetRange("No.", PostedWhseRcptHeader."No.");
                        if PostedWhseRcptLine.FindFirst() then begin
                            PostedWhseRcptHeader."Document Status" := PostedWhseRcptHeader.GetHeaderStatus(0);
                            PostedWhseRcptHeader.Modify();
                        end;
                        if PostedWhseRcptHeader."Document Status" =
                           PostedWhseRcptHeader."Document Status"::"Completely Put Away"
                        then begin
                            WhsePutAwayRqst.SetRange("Document Type", WhsePutAwayRqst."Document Type"::Receipt);
                            WhsePutAwayRqst.SetRange("Document No.", PostedWhseRcptHeader."No.");
                            WhsePutAwayRqst.DeleteAll();
                            ItemTrackingMgt.DeleteWhseItemTrkgLines(
                              DATABASE::"Posted Whse. Receipt Line", 0, PostedWhseRcptHeader."No.", '', 0, 0, '', false);
                        end;
                    end;
                "Whse. Document Type"::"Internal Pick":
                    if "Action Type" <> "Action Type"::Take then begin
                        WhseInternalPickHeader.Get("Whse. Document No.");
                        WhseInternalPickLine.Reset();
                        WhseInternalPickLine.SetRange("No.", "Whse. Document No.");
                        if WhseInternalPickLine.FindFirst() then begin
                            WhseInternalPickHeader."Document Status" :=
                              WhseInternalPickHeader.GetDocumentStatus(0);
                            WhseInternalPickHeader.Modify();
                            if WhseInternalPickHeader."Document Status" =
                               WhseInternalPickHeader."Document Status"::"Completely Picked"
                            then begin
                                WhseInternalPickHeader.DeleteRelatedLines();
                                WhseInternalPickHeader.Delete();
                            end;
                        end else begin
                            WhseInternalPickHeader.DeleteRelatedLines();
                            WhseInternalPickHeader.Delete();
                        end;
                    end;
                "Whse. Document Type"::"Internal Put-away":
                    if "Action Type" <> "Action Type"::Take then begin
                        WhseInternalPutAwayHeader.Get("Whse. Document No.");
                        WhseInternalPutAwayLine.Reset();
                        WhseInternalPutAwayLine.SetRange("No.", "Whse. Document No.");
                        if WhseInternalPutAwayLine.FindFirst() then begin
                            WhseInternalPutAwayHeader."Document Status" :=
                              WhseInternalPutAwayHeader.GetDocumentStatus(0);
                            WhseInternalPutAwayHeader.Modify();
                            if WhseInternalPutAwayHeader."Document Status" =
                               WhseInternalPutAwayHeader."Document Status"::"Completely Put Away"
                            then begin
                                WhseInternalPutAwayHeader.DeleteRelatedLines();
                                WhseInternalPutAwayHeader.Delete();
                            end;
                        end else begin
                            WhseInternalPutAwayHeader.DeleteRelatedLines();
                            WhseInternalPutAwayHeader.Delete();
                        end;
                    end;
                "Whse. Document Type"::Production:
                    if "Action Type" <> "Action Type"::Take then begin
                        ProdOrder.Get("Source Subtype", "Source No.");
                        ProdOrder.CalcFields("Completely Picked");
                        if ProdOrder."Completely Picked" then begin
                            WhsePickRqst.SetRange("Document Type", WhsePickRqst."Document Type"::Production);
                            WhsePickRqst.SetRange("Document No.", ProdOrder."No.");
                            WhsePickRqst.ModifyAll("Completely Picked", true);
                            ItemTrackingMgt.DeleteWhseItemTrkgLines(
                              DATABASE::"Prod. Order Component", "Source Subtype", "Source No.", '', 0, 0, '', false);
                        end;
                    end;
                "Whse. Document Type"::Assembly:
                    if "Action Type" <> "Action Type"::Take then begin
                        AssemblyHeader.Get("Source Subtype", "Source No.");
                        if AssemblyHeader.CompletelyPicked() then begin
                            WhsePickRqst.SetRange("Document Type", WhsePickRqst."Document Type"::Assembly);
                            WhsePickRqst.SetRange("Document No.", AssemblyHeader."No.");
                            WhsePickRqst.ModifyAll("Completely Picked", true);
                            ItemTrackingMgt.DeleteWhseItemTrkgLines(
                              DATABASE::"Assembly Line", "Source Subtype", "Source No.", '', 0, 0, '', false);
                        end;
                    end;
                "Whse. Document Type"::Job:
                    if "Action Type" <> "Action Type"::Take then begin
                        Job.Get("Source No.");
                        Job.CalcFields("Completely Picked");
                        if Job."Completely Picked" then begin
                            WhsePickRqst.SetRange("Document Type", WhsePickRqst."Document Type"::Job);
                            WhsePickRqst.SetRange("Document No.", Job."No.");
                            WhsePickRqst.ModifyAll("Completely Picked", true);
                            ItemTrackingMgt.DeleteWhseItemTrkgLines(
                              DATABASE::"Job Planning Line", "Source Subtype", "Source No.", '', 0, 0, '', false);
                        end;
                    end;
                // P8000322A
                "Whse. Document Type"::FOODStagedPick:
                    if "Action Type" <> "Action Type"::Take then begin
                        WhseStagedPickHeader.Get("Whse. Document No.");
                        WhseStagedPickHeader.UpdateOnRegister;
                    end;
            // P8000322A
            end;
        OnAfterUpdateWhseDocHeader(WhseActivLine);
    end;

#if not CLEAN20
    [Obsolete('Replaced by UpdateWhseShipmentLine with parameter WhseActivityLine', '20.0')]
    procedure UpdateWhseShptLine(WhseDocNo: Code[20]; WhseDocLineNo: Integer; QtyToHandle: Decimal; QtyToHandleBase: Decimal; QtyPerUOM: Decimal)
    begin
        UpdateWhseShipmentLine(GlobalWhseActivLine, WhseDocNo, WhseDocLineNo, QtyToHandle, QtyToHandleBase, QtyPerUOM);
    end;
#endif

    procedure UpdateWhseShipmentLine(WhseActivityLineGrouped: Record "Warehouse Activity Line"; WhseDocNo: Code[20]; WhseDocLineNo: Integer; QtyToHandle: Decimal; QtyToHandleBase: Decimal; QtyPerUOM: Decimal)
    var
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        WhseShptLine.Get(WhseDocNo, WhseDocLineNo);
        OnBeforeUpdateWhseShptLine(WhseShptLine, QtyToHandle, QtyToHandleBase, QtyPerUOM);
        WhseShptLine."Qty. Picked (Base)" :=
          WhseShptLine."Qty. Picked (Base)" + QtyToHandleBase;
        if QtyPerUOM = WhseShptLine."Qty. per Unit of Measure" then
            WhseShptLine."Qty. Picked" := WhseShptLine."Qty. Picked" + QtyToHandle
        else
            WhseShptLine."Qty. Picked" :=
              // ROUND(WhseShptLine."Qty. Picked" + QtyToHandleBase / QtyPerUOM);                // P8000503A
              WhseShptLine."Qty. Picked" +                                                       // P8000503A
              Round(QtyToHandle * QtyPerUOM / WhseShptLine."Qty. per Unit of Measure", 0.00001); // P8000503A

        OnUpdateWhseShptLineOnAfterAssignQtyPicked(WhseShptLine, QtyPerUOM, QtyToHandleBase);

        WhseShptLine."Completely Picked" :=
          (WhseShptLine."Qty. Picked" = WhseShptLine.Quantity) or (WhseShptLine."Qty. Picked (Base)" = WhseShptLine."Qty. (Base)");

        // Handle rounding residual when completely picked
        if WhseShptLine."Completely Picked" and (WhseShptLine."Qty. Picked" <> WhseShptLine.Quantity) then
            WhseShptLine."Qty. Picked" := WhseShptLine.Quantity;

        WhseShptLine.Validate("Qty. to Ship", WhseShptLine."Qty. Picked" - WhseShptLine."Qty. Shipped" - WhseShptLine.GetContainerQuantity(false)); // P80046533
        WhseShptLine."Qty. to Ship (Base)" := WhseShptLine."Qty. Picked (Base)" - WhseShptLine."Qty. Shipped (Base)" - WhseShptLine.GetContainerQuantityBase(false); // P80046533
        WhseShptLine.Status := WhseShptLine.CalcStatusShptLine();
        OnBeforeWhseShptLineModify(WhseShptLine, GlobalWhseActivLine, WhseActivityLineGrouped);
        WhseShptLine.Modify();

        // P80046533
        TempWhseShptLine := WhseShptLine;
        if TempWhseShptLine.Insert then;
        // P80046533

        OnAfterWhseShptLineModify(WhseShptLine);
    end;

    local procedure UpdatePostedWhseRcptLine(WhseActivityLine: Record "Warehouse Activity Line")
    begin
        with WhseActivityLine do begin
            PostedWhseRcptHeader.LockTable();
            PostedWhseRcptHeader.Get("Whse. Document No.");
            PostedWhseRcptLine.LockTable();
            PostedWhseRcptLine.Get("Whse. Document No.", "Whse. Document Line No.");
            PostedWhseRcptLine."Qty. Put Away (Base)" :=
              PostedWhseRcptLine."Qty. Put Away (Base)" + "Qty. to Handle (Base)";
            if "Qty. per Unit of Measure" = PostedWhseRcptLine."Qty. per Unit of Measure" then
                PostedWhseRcptLine."Qty. Put Away" :=
                  PostedWhseRcptLine."Qty. Put Away" + "Qty. to Handle"
            else
                PostedWhseRcptLine."Qty. Put Away" :=
                  Round(
                    PostedWhseRcptLine."Qty. Put Away" +
                    // "Qty. to Handle (Base)" / PostedWhseRcptLine."Qty. per Unit of Measure"); // P8000503A
                    "Qty. To Handle" * "Qty. per Unit of Measure" / PostedWhseRcptLine."Qty. per Unit of Measure", 0.00001); // P8000503A
            PostedWhseRcptLine.Status := PostedWhseRcptLine.GetLineStatus();
            OnBeforePostedWhseRcptLineModify(PostedWhseRcptLine, WhseActivityLine);
            PostedWhseRcptLine.Modify();
            OnAfterPostedWhseRcptLineModify(PostedWhseRcptLine);
        end;
    end;

    local procedure UpdateWhseIntPickLine(WhseActivityLine: Record "Warehouse Activity Line")
    begin
        with WhseActivityLine do begin
            WhseInternalPickLine.Get("Whse. Document No.", "Whse. Document Line No.");
            if WhseInternalPickLine."Qty. (Base)" =
               WhseInternalPickLine."Qty. Picked (Base)" + "Qty. to Handle (Base)"
            then
                WhseInternalPickLine.Delete()
            else begin
                WhseInternalPickLine."Qty. Picked (Base)" :=
                  WhseInternalPickLine."Qty. Picked (Base)" + "Qty. to Handle (Base)";
                if "Qty. per Unit of Measure" = WhseInternalPickLine."Qty. per Unit of Measure" then
                    WhseInternalPickLine."Qty. Picked" :=
                      WhseInternalPickLine."Qty. Picked" + "Qty. to Handle"
                else
                    WhseInternalPickLine."Qty. Picked" :=
                      Round(
                        // P8000503A
                        // WhseInternalPickLine."Qty. Picked" + "Qty. to Handle (Base)" / "Qty. per Unit of Measure");
                        WhseInternalPickLine."Qty. Picked" +
                        "Qty. to Handle" * "Qty. per Unit of Measure" / WhseInternalPickLine."Qty. per Unit of Measure", 0.00001);
                // P8000503A
                WhseInternalPickLine.Validate(
                  "Qty. Outstanding", WhseInternalPickLine."Qty. Outstanding" - "Qty. to Handle");
                WhseInternalPickLine.Status := WhseInternalPickLine.CalcStatusPickLine();
                OnBeforeWhseInternalPickLineModify(WhseInternalPickLine, WhseActivityLine);
                WhseInternalPickLine.Modify();
                OnAfterWhseInternalPickLineModify(WhseInternalPickLine);
            end;
        end;
    end;

    local procedure UpdateWhseIntPutAwayLine(WhseActivityLine: Record "Warehouse Activity Line")
    begin
        with WhseActivityLine do begin
            WhseInternalPutAwayLine.Get("Whse. Document No.", "Whse. Document Line No.");
            if WhseInternalPutAwayLine."Qty. (Base)" =
               WhseInternalPutAwayLine."Qty. Put Away (Base)" + "Qty. to Handle (Base)"
            then
                WhseInternalPutAwayLine.Delete()
            else begin
                WhseInternalPutAwayLine."Qty. Put Away (Base)" :=
                  WhseInternalPutAwayLine."Qty. Put Away (Base)" + "Qty. to Handle (Base)";
                if "Qty. per Unit of Measure" = WhseInternalPutAwayLine."Qty. per Unit of Measure" then
                    WhseInternalPutAwayLine."Qty. Put Away" :=
                      WhseInternalPutAwayLine."Qty. Put Away" + "Qty. to Handle"
                else
                    WhseInternalPutAwayLine."Qty. Put Away" :=
                      Round(
                        WhseInternalPutAwayLine."Qty. Put Away" +
                        // "Qty. to Handle (Base)" / WhseInternalPutAwayLine."Qty. per Unit of Measure"); // P8000503A
                        "Qty. to Handle" * "Qty. per Unit of Measure" / WhseInternalPutAwayLine."Qty. per Unit of Measure", 0.00001); // P8000503A
                WhseInternalPutAwayLine.Validate(
                  "Qty. Outstanding", WhseInternalPutAwayLine."Qty. Outstanding" - "Qty. to Handle");
                WhseInternalPutAwayLine.Status := WhseInternalPutAwayLine.CalcStatusPutAwayLine();
                OnBeforeWhseInternalPutAwayLineModify(WhseInternalPutAwayLine, WhseActivityLine);
                WhseInternalPutAwayLine.Modify();
                OnAfterWhseInternalPutAwayLineModify(WhseInternalPutAwayLine);
            end;
        end;
    end;

    local procedure UpdateProdCompLine(WhseActivityLine: Record "Warehouse Activity Line")
    begin
        with WhseActivityLine do begin
            ProdCompLine.Get("Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
            ProdCompLine."Qty. Picked (Base)" :=
              ProdCompLine."Qty. Picked (Base)" + "Qty. to Handle (Base)";
            if "Qty. per Unit of Measure" = ProdCompLine."Qty. per Unit of Measure" then
                ProdCompLine."Qty. Picked" := ProdCompLine."Qty. Picked" + "Qty. to Handle"
            else
                ProdCompLine."Qty. Picked" :=
                // P8000503A
                //   Round(ProdCompLine."Qty. Picked" + "Qty. to Handle (Base)" / "Qty. per Unit of Measure");
                ProdCompLine."Qty. Picked" +
                Round("Qty. To Handle" * "Qty. per Unit of Measure" / ProdCompLine."Qty. per Unit of Measure", 0.00001);
            // P8000503A
            ProdCompLine."Completely Picked" :=
              // ProdCompLine."Qty. Picked" = ProdCompLine."Expected Quantity";                                  // P8000322A
              (ProdCompLine."Qty. Picked" = ProdCompLine."Expected Quantity") or ProdCompLine.ReplenishmentNotRequired(); // P8000322A
            OnBeforeProdCompLineModify(ProdCompLine, WhseActivityLine);
            ProdCompLine.Modify();
            OnAfterProdCompLineModify(ProdCompLine);
        end;
    end;

    local procedure UpdateAssemblyLine(WhseActivityLine: Record "Warehouse Activity Line")
    begin
        with WhseActivityLine do begin
            AssemblyLine.Get("Source Subtype", "Source No.", "Source Line No.");
            AssemblyLine."Qty. Picked (Base)" :=
              AssemblyLine."Qty. Picked (Base)" + "Qty. to Handle (Base)";
            if "Qty. per Unit of Measure" = AssemblyLine."Qty. per Unit of Measure" then
                AssemblyLine."Qty. Picked" := AssemblyLine."Qty. Picked" + "Qty. to Handle"
            else
                AssemblyLine."Qty. Picked" :=
                  Round(AssemblyLine."Qty. Picked" + "Qty. to Handle (Base)" / "Qty. per Unit of Measure");
            OnBeforeAssemblyLineModify(AssemblyLine, WhseActivityLine);
            AssemblyLine.Modify();
            OnAfterAssemblyLineModify(AssemblyLine);
        end;
    end;

    local procedure UpdateJobPlanningLine(WhseActivityLine: Record "Warehouse Activity Line")
    begin
        JobPlanningLine.SetRange("Job Contract Entry No.", WhseActivityLine."Source Line No.");
        if JobPlanningLine.FindFirst() then begin
            JobPlanningLine."Qty. Picked (Base)" := JobPlanningLine."Qty. Picked (Base)" + WhseActivityLine."Qty. to Handle (Base)";
            if WhseActivityLine."Qty. per Unit of Measure" = JobPlanningLine."Qty. per Unit of Measure" then
                JobPlanningLine."Qty. Picked" := JobPlanningLine."Qty. Picked" + WhseActivityLine."Qty. to Handle"
            else
                JobPlanningLine."Qty. Picked" := Round(JobPlanningLine."Qty. Picked" + WhseActivityLine."Qty. to Handle (Base)" / WhseActivityLine."Qty. per Unit of Measure");

            JobPlanningLine."Completely Picked" := JobPlanningLine."Qty. Picked" = JobPlanningLine.Quantity;
            JobPlanningLine.Modify();
        end
    end;

    procedure LocationGet(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Clear(Location)
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);
    end;

    procedure GetItemUnitOfMeasure(ItemNo: Code[20]; UOMCode: Code[10])
    begin
        if (ItemUnitOfMeasure."Item No." <> ItemNo) or
           (ItemUnitOfMeasure.Code <> UOMCode)
        then
            if not ItemUnitOfMeasure.Get(ItemNo, UOMCode) then
                ItemUnitOfMeasure.Init();
    end;

    local procedure UpdateTempBinContentBuffer(WhseActivLine: Record "Warehouse Activity Line")
    var
        WMSMgt: Codeunit "WMS Management";
        UOMCode: Code[10];
        Sign: Integer;
    begin
        with WhseActivLine do begin
            if Location."Directed Put-away and Pick" then
                UOMCode := "Unit of Measure Code"
            else
                UOMCode := WMSMgt.GetBaseUOM("Item No.");
            if not TempBinContentBuffer.Get(
                "Location Code", "Bin Code", "Item No.", "Variant Code", UOMCode, "Lot No.", "Serial No.", "Package No.")
            then begin
                TempBinContentBuffer.Init();
                TempBinContentBuffer."Location Code" := "Location Code";
                TempBinContentBuffer."Zone Code" := "Zone Code";
                TempBinContentBuffer."Bin Code" := "Bin Code";
                TempBinContentBuffer."Item No." := "Item No.";
                TempBinContentBuffer."Variant Code" := "Variant Code";
                TempBinContentBuffer."Unit of Measure Code" := UOMCode;
                TempBinContentBuffer.CopyTrackingFromWhseActivityLine(WhseActivLine);
                OnUpdateTempBinContentBufferOnBeforeInsert(TempBinContentBuffer, WhseActivLine);
                TempBinContentBuffer.Insert();
            end;
            Sign := 1;
            if "Action Type" = "Action Type"::Take then
                Sign := -1;

            TempBinContentBuffer."Base Unit of Measure" := WMSMgt.GetBaseUOM("Item No.");
            TempBinContentBuffer."Qty. to Handle (Base)" := TempBinContentBuffer."Qty. to Handle (Base)" + Sign * "Qty. to Handle (Base)";
            TempBinContentBuffer."Qty. Outstanding (Base)" :=
              TempBinContentBuffer."Qty. Outstanding (Base)" + Sign * "Qty. Outstanding (Base)";
            TempBinContentBuffer.Cubage := TempBinContentBuffer.Cubage + Sign * Cubage;
            TempBinContentBuffer.Weight := TempBinContentBuffer.Weight + Sign * Weight;
            TempBinContentBuffer.Modify();
        end;
    end;

    local procedure CheckBin()
    var
        Bin: Record Bin;
    begin
        with TempBinContentBuffer do begin
            SetFilter("Qty. to Handle (Base)", '>0');
            if Find('-') then
                repeat
                    SetRange("Qty. to Handle (Base)");
                    SetRange("Bin Code", "Bin Code");
                    CalcSums(Cubage, Weight);
                    Bin.Get("Location Code", "Bin Code");
                    CheckIncreaseBin(Bin);
                    SetFilter("Qty. to Handle (Base)", '>0');
                    Find('+');
                    SetRange("Bin Code");
                until Next() = 0;
        end;
    end;

    local procedure CheckIncreaseBin(var Bin: Record Bin)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckIncreaseBin(TempBinContentBuffer, Bin, IsHandled);
        if IsHandled then
            exit;

        with TempBinContentBuffer do
            Bin.CheckIncreaseBin(
                "Bin Code", '', "Qty. to Handle (Base)", Cubage, Weight, Cubage, Weight, true, false);
    end;

    local procedure CheckBinContent()
    var
        BinContent: Record "Bin Content";
        Bin: Record Bin;
        WhseItemTrackingSetup: Record "Item Tracking Setup";
        BreakBulkQtyBaseToPlace: Decimal;
    begin
        with TempBinContentBuffer do begin
            SetFilter("Qty. to Handle (Base)", '<>0');
            if Find('-') then
                repeat
                    if "Qty. to Handle (Base)" < 0 then begin
                        BinContent.Get("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
                        ItemTrackingMgt.GetWhseItemTrkgSetup(BinContent."Item No.", WhseItemTrackingSetup);
                        OnCheckBinContentOnAfterGetWhseItemTrkgSetup(BinContent, WhseItemTrackingSetup);

                        BinContent.ClearTrackingFilters();
                        BinContent.SetTrackingFilterFromBinContentBufferIfRequired(WhseItemTrackingSetup, TempBinContentBuffer);

                        BreakBulkQtyBaseToPlace := CalcBreakBulkQtyToPlace(TempBinContentBuffer);
                        GetItem("Item No.");

                        CheckBinContentQtyToHandle(TempBinContentBuffer, BinContent, BreakBulkQtyBaseToPlace);
                    end else begin
                        Bin.Get("Location Code", "Bin Code");
                        Bin.CheckWhseClass("Item No.", false);
                    end;
                    OnCheckBinContentOnAfterTempBinContentBufferLoop(TempBinContentBuffer, Bin);
                until Next() = 0;
        end;
    end;

    local procedure CheckBinContentQtyToHandle(var TempBinContentBuffer: Record "Bin Content Buffer" temporary; var BinContent: Record "Bin Content"; BreakBulkQtyBaseToPlace: Decimal)
    var
        UOMMgt: Codeunit "Unit of Measure Management";
        AbsQtyToHandle: Decimal;
        AbsQtyToHandleBase: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckBinContentQtyToHandle(TempBinContentBuffer, BinContent, Item, IsHandled, BreakBulkQtyBaseToPlace);
        if IsHandled then
            exit;

        with TempBinContentBuffer do begin
            AbsQtyToHandleBase := Abs("Qty. to Handle (Base)");
            AbsQtyToHandle :=
                Round(AbsQtyToHandleBase / UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code"), UOMMgt.QtyRndPrecision());
            if BreakBulkQtyBaseToPlace > 0 then
                BinContent.CheckDecreaseBinContent(AbsQtyToHandle, AbsQtyToHandleBase, BreakBulkQtyBaseToPlace - "Qty. to Handle (Base)")
            else
                BinContent.CheckDecreaseBinContent(AbsQtyToHandle, AbsQtyToHandleBase, Abs("Qty. Outstanding (Base)"));
            if AbsQtyToHandleBase <> Abs("Qty. to Handle (Base)") then begin
                "Qty. to Handle (Base)" := AbsQtyToHandleBase * "Qty. to Handle (Base)" / Abs("Qty. to Handle (Base)");
                Modify();
            end;
        end;
    end;

    local procedure CalcBreakBulkQtyToPlace(TempBinContentBuffer: Record "Bin Content Buffer") QtyBase: Decimal
    var
        BreakBulkWhseActivLine: Record "Warehouse Activity Line";
    begin
        with TempBinContentBuffer do begin
            BreakBulkWhseActivLine.SetCurrentKey(
              "Item No.", "Bin Code", "Location Code", "Action Type", "Variant Code",
              "Unit of Measure Code", "Breakbulk No.", "Activity Type", "Lot No.", "Serial No.");
            BreakBulkWhseActivLine.SetRange("Item No.", "Item No.");
            BreakBulkWhseActivLine.SetRange("Bin Code", "Bin Code");
            BreakBulkWhseActivLine.SetRange("Location Code", "Location Code");
            BreakBulkWhseActivLine.SetRange("Action Type", BreakBulkWhseActivLine."Action Type"::Place);
            BreakBulkWhseActivLine.SetRange("Variant Code", "Variant Code");
            BreakBulkWhseActivLine.SetRange("Unit of Measure Code", "Unit of Measure Code");
            BreakBulkWhseActivLine.SetFilter("Breakbulk No.", '<>0');
            BreakBulkWhseActivLine.SetRange("Activity Type", GlobalWhseActivHeader.Type);
            BreakBulkWhseActivLine.SetRange("No.", GlobalWhseActivHeader."No.");
            BreakBulkWhseActivLine.SetTrackingFilterFromBinContentBuffer(TempBinContentBuffer);
            if BreakBulkWhseActivLine.Find('-') then
                repeat
                    QtyBase := QtyBase + BreakBulkWhseActivLine."Qty. to Handle (Base)";
                until BreakBulkWhseActivLine.Next() = 0;
        end;
        exit(QtyBase);
    end;

    local procedure CheckWhseActivLineIsEmpty(var WhseActivLine: Record "Warehouse Activity Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckWhseActivLineIsEmpty(WhseActivLine, IsHandled, HideDialog);
        if not IsHandled then
            if WhseActivLine.IsEmpty() then
                Error(Text003);
    end;

    procedure CheckWhseItemTrkgLine(var WhseActivLine: Record "Warehouse Activity Line")
    var
        TempWhseActivLine: Record "Warehouse Activity Line" temporary;
        WhseItemTrackingSetup: Record "Item Tracking Setup";
        QtyAvailToRegisterBase: Decimal;
        QtyAvailToInsertBase: Decimal;
        QtyToRegisterBase: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforeCheckWhseItemTrkgLine(WhseActivLine);

        if not
           ((WhseActivLine."Activity Type" = WhseActivLine."Activity Type"::Pick) or
            (WhseActivLine."Activity Type" = WhseActivLine."Activity Type"::"Invt. Movement"))
        then
            exit;

        if WhseActivLine.Find('-') then
            repeat
                TempWhseActivLine := WhseActivLine;
                if not (TempWhseActivLine."Action Type" = TempWhseActivLine."Action Type"::Place) then
                    TempWhseActivLine.Insert();
            until WhseActivLine.Next() = 0;

        TempWhseActivLine.SetCurrentKey("Item No.");
        if TempWhseActivLine.Find('-') then
            repeat
                IsHandled := false;
                OnCheckWhseItemTrkgLineOnAfterTempWhseActivLineFind(TempWhseActivLine, IsHandled);
                if not IsHandled then begin
                    TempWhseActivLine.SetRange("Item No.", TempWhseActivLine."Item No.");
                    if ItemTrackingMgt.GetWhseItemTrkgSetup(TempWhseActivLine."Item No.", WhseItemTrackingSetup) then
                        repeat
                            OnCheckWhseItemTrkgLineOnBeforeTestTracking(TempWhseActivLine, WhseItemTrackingSetup);
                            TempWhseActivLine.TestNonSpecificItemTracking();
                            TempWhseActivLine.TestTrackingIfRequired(WhseItemTrackingSetup);
                        until TempWhseActivLine.Next() = 0
                    else begin
                        TempWhseActivLine.Find('+');
                        TempWhseActivLine.DeleteAll();
                    end;
                    TempWhseActivLine.SetRange("Item No.");
                end;
            until TempWhseActivLine.Next() = 0;

        TempWhseActivLine.Reset();
        TempWhseActivLine.SetCurrentKey(
          "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
        TempWhseActivLine.SetRange("Breakbulk No.", 0);
        OnCheckWhseItemTrkgLineOnAfterTempWhseActivLineSetFilters(TempWhseActivLine);
        if TempWhseActivLine.Find('-') then
            repeat
                ItemTrackingMgt.GetWhseItemTrkgSetup(TempWhseActivLine."Item No.", WhseItemTrackingSetup);
                OnCheckWhseItemTrkgLineOnAfterGetWhseItemTrkgSetup(TempWhseActivLine, WhseItemTrackingSetup);
                // Per document
                TempWhseActivLine.SetSourceFilter(
                  TempWhseActivLine."Source Type", TempWhseActivLine."Source Subtype", TempWhseActivLine."Source No.",
                  TempWhseActivLine."Source Line No.", TempWhseActivLine."Source Subline No.", false);

                // P8000322A
                TempWhseActivLine.SetRange("Whse. Document Type", TempWhseActivLine."Whse. Document Type");
                TempWhseActivLine.SetRange("Whse. Document No.", TempWhseActivLine."Whse. Document No.");
                TempWhseActivLine.SetRange("Whse. Document Line No.", TempWhseActivLine."Whse. Document Line No.");
                // P8000322A
                repeat
                    // Per Lot/SN
                    TempWhseActivLine.SetRange("Item No.", TempWhseActivLine."Item No.");
                    QtyAvailToInsertBase := CalcQtyAvailToInsertBase(TempWhseActivLine);
                    TempWhseActivLine.SetTrackingFilterFromWhseActivityLine(TempWhseActivLine);
                    OnCheckWhseItemTrkgLineOnBeforeCalcQtyToRegisterBase(TempWhseActivLine, WhseActivLine);
                    QtyToRegisterBase := 0;
                    repeat
                        QtyToRegisterBase := QtyToRegisterBase + TempWhseActivLine."Qty. to Handle (Base)";
                    until TempWhseActivLine.Next() = 0;

                    QtyAvailToRegisterBase := CalcQtyAvailToRegisterBase(TempWhseActivLine);
                    if QtyToRegisterBase > QtyAvailToRegisterBase then
                        QtyAvailToInsertBase -= QtyToRegisterBase - QtyAvailToRegisterBase;
                    OnBeforeCheckQtyAvailToInsertBase(TempWhseActivLine, QtyAvailToInsertBase);
                    if QtyAvailToInsertBase < 0 then
                        Error(
                          InsufficientQtyItemTrkgErr, TempWhseActivLine."Source Line No.", TempWhseActivLine."Source Document",
                          TempWhseActivLine."Source No.");

                    if TempWhseActivLine.TrackingExists() then begin
                        WhseItemTrackingSetup.CopyTrackingFromWhseActivityLine(TempWhseActivLine);
                        if not IsQtyAvailToPickNonSpecificReservation(TempWhseActivLine, WhseItemTrackingSetup, QtyToRegisterBase) then
                            AvailabilityError(TempWhseActivLine);
                    end;

                    // Clear filters, Lot/SN
                    TempWhseActivLine.ClearTrackingFilter();
                    TempWhseActivLine.SetRange("Item No.");
                    OnCheckWhseItemTrkgLineOnAfterClearFilters(TempWhseActivLine, WhseActivLine);
                until TempWhseActivLine.Next() = 0; // Per Lot/SN
                                                    // Clear filters, document
                TempWhseActivLine.ClearSourceFilter();

                // P8000322A
                TempWhseActivLine.SetRange("Whse. Document Type");
                TempWhseActivLine.SetRange("Whse. Document No.");
                TempWhseActivLine.SetRange("Whse. Document Line No.");
            // P8000322A
            until TempWhseActivLine.Next() = 0;   // Per document
    end;

    local procedure RegisterWhseItemTrkgLine(WhseActivLine2: Record "Warehouse Activity Line")
    var
        ProdOrderComp: Record "Prod. Order Component";
        AssemblyLine: Record "Assembly Line";
        JobPlanningLineRec: Record "Job Planning Line";
        WhseShptLine: Record "Warehouse Shipment Line";
        QtyToRegisterBase: Decimal;
        DueDate: Date;
        NextEntryNo: Integer;
        WhseDocType2: Enum "Warehouse Activity Document Type";
        NeedRegisterWhseItemTrkgLine: Boolean;
        WhseItemTrkgSetupExists: Boolean;
    begin
        with WhseActivLine2 do begin
            if (("Whse. Document Type" in
                 ["Whse. Document Type"::Shipment, "Whse. Document Type"::"Internal Pick",
                  "Whse. Document Type"::Production, "Whse. Document Type"::Assembly, "Whse. Document Type"::"Internal Put-away", "Whse. Document Type"::Job]) and
                ("Action Type" <> "Action Type"::Take) and ("Breakbulk No." = 0)) or
               (("Whse. Document Type" = "Whse. Document Type"::Receipt) and ("Action Type" <> "Action Type"::Place) and ("Breakbulk No." = 0))
            then
                NeedRegisterWhseItemTrkgLine := true;

            if ("Activity Type" = "Activity Type"::"Invt. Movement") and ("Action Type" <> "Action Type"::Take) and
               ("Source Document" in ["Source Document"::"Prod. Consumption", "Source Document"::"Assembly Consumption", "Source Document"::"Job Usage"])
            then
                NeedRegisterWhseItemTrkgLine := true;

            if not NeedRegisterWhseItemTrkgLine then
                exit;
        end;

        WhseItemTrkgSetupExists := ItemTrackingMgt.GetWhseItemTrkgSetup(WhseActivLine2."Item No.");
        OnRegisterWhseItemTrkgLineOnAfterCalcWhseItemTrkgSetupExists(WhseActivLine2, ItemTrackingMgt, WhseItemTrkgSetupExists);
        if not WhseItemTrkgSetupExists then
            exit;

        QtyToRegisterBase := InitTempTrackingSpecification(WhseActivLine2, TempTrackingSpecification);

        TempTrackingSpecification.Reset();

        if QtyToRegisterBase > 0 then begin
            if (WhseActivLine2."Activity Type" = WhseActivLine2."Activity Type"::Pick) or
               (WhseActivLine2."Activity Type" = WhseActivLine2."Activity Type"::"Invt. Movement")
            then
                InsertRegWhseItemTrkgLine(WhseActivLine2, QtyToRegisterBase);

            //IF (WhseActivLine2."Activity Type" <> WhseActivLine2."Activity Type"::Pick) OR (WhseActivLine2."Container ID" = '') THEN // P80046533, P80075420
            if (WhseActivLine2."Whse. Document Type" in
                [WhseActivLine2."Whse. Document Type"::Shipment,
                 WhseActivLine2."Whse. Document Type"::Production,
                 WhseActivLine2."Whse. Document Type"::Assembly,
                 WhseActivLine2."Whse. Document Type"::Job]) or
               ((WhseActivLine2."Activity Type" = WhseActivLine2."Activity Type"::"Invt. Movement") and
                (WhseActivLine2."Source Type" > 0))
            then begin
                OnRegisterWhseItemTrkgLineOnBeforeCreateSpecification(WhseActivLine2, DueDate);

                if (WhseActivLine2."Whse. Document Type" = WhseActivLine2."Whse. Document Type"::Shipment) and
                   WhseActivLine2."Assemble to Order"
                then
                    WhseDocType2 := WhseActivLine2."Whse. Document Type"::Assembly
                else
                    WhseDocType2 := WhseActivLine2."Whse. Document Type";
                case WhseDocType2 of
                    WhseActivLine2."Whse. Document Type"::Shipment:
                        begin
                            WhseShptLine.Get(WhseActivLine2."Whse. Document No.", WhseActivLine2."Whse. Document Line No.");
                            DueDate := WhseShptLine."Shipment Date";
                        end;
                    WhseActivLine2."Whse. Document Type"::Production:
                        begin
                            ProdOrderComp.Get(WhseActivLine2."Source Subtype", WhseActivLine2."Source No.",
                              WhseActivLine2."Source Line No.", WhseActivLine2."Source Subline No.");
                            DueDate := ProdOrderComp."Due Date";
                        end;
                    WhseActivLine2."Whse. Document Type"::Assembly:
                        begin
                            AssemblyLine.Get(WhseActivLine2."Source Subtype", WhseActivLine2."Source No.",
                              WhseActivLine2."Source Line No.");
                            DueDate := AssemblyLine."Due Date";
                        end;
                    WhseActivLine2."Whse. Document Type"::Job:
                        begin
                            JobPlanningLineRec.SetRange("Job Contract Entry No.", WhseActivLine2."Source Line No.");
                            JobPlanningLineRec.SetLoadFields("Planning Due Date");
                            if JobPlanningLineRec.FindFirst() then
                                DueDate := JobPlanningLineRec."Planning Due Date";
                        end;
                end;

                OnRegisterWhseItemTrkgLineOnAfterSetDueDate(WhseActivLine2, DueDate);

                if WhseActivLine2."Activity Type" = WhseActivLine2."Activity Type"::"Invt. Movement" then
                    case WhseActivLine2."Source Type" of
                        DATABASE::"Prod. Order Component":
                            begin
                                ProdOrderComp.Get(WhseActivLine2."Source Subtype", WhseActivLine2."Source No.",
                                  WhseActivLine2."Source Line No.", WhseActivLine2."Source Subline No.");
                                DueDate := ProdOrderComp."Due Date";
                            end;
                        DATABASE::"Assembly Line":
                            begin
                                AssemblyLine.Get(WhseActivLine2."Source Subtype", WhseActivLine2."Source No.",
                                  WhseActivLine2."Source Line No.");
                                DueDate := AssemblyLine."Due Date";
                            end;
                    end;

                NextEntryNo := TempTrackingSpecification.GetLastEntryNo() + 1;

                TempTrackingSpecification.Init();
                TempTrackingSpecification."Entry No." := NextEntryNo;
                case WhseActivLine2."Source Type" of
                    Database::"Prod. Order Component":
                        TempTrackingSpecification.SetSource(
                          WhseActivLine2."Source Type", WhseActivLine2."Source Subtype", WhseActivLine2."Source No.",
                          WhseActivLine2."Source Subline No.", '', WhseActivLine2."Source Line No.");
                    Database::Job:
                        TempTrackingSpecification.SetSource(
                              Database::"Job Planning Line", 2, WhseActivLine2."Source No.", WhseActivLine2."Source Line No.", '', 0);
                    else
                        TempTrackingSpecification.SetSource(
                          WhseActivLine2."Source Type", WhseActivLine2."Source Subtype", WhseActivLine2."Source No.",
                          WhseActivLine2."Source Line No.", '', 0);
                end;
                TempTrackingSpecification."Creation Date" := DueDate;
                TempTrackingSpecification."Qty. to Handle (Base)" := QtyToRegisterBase;
                TempTrackingSpecification."Item No." := WhseActivLine2."Item No.";
                TempTrackingSpecification."Variant Code" := WhseActivLine2."Variant Code";
                TempTrackingSpecification."Location Code" := WhseActivLine2."Location Code";
                TempTrackingSpecification.Description := WhseActivLine2.Description;
                TempTrackingSpecification."Qty. per Unit of Measure" := WhseActivLine2."Qty. per Unit of Measure";
                TempTrackingSpecification.CopyTrackingFromWhseActivityLine(WhseActivLine2);
                TempTrackingSpecification."Warranty Date" := WhseActivLine2."Warranty Date";
                TempTrackingSpecification."Expiration Date" := WhseActivLine2."Expiration Date";
                TempTrackingSpecification."Quantity (Base)" := QtyToRegisterBase;
                OnBeforeRegWhseItemTrkgLine(WhseActivLine2, TempTrackingSpecification);
                TempTrackingSpecification.Insert();
                OnAfterRegWhseItemTrkgLine(WhseActivLine2, TempTrackingSpecification);
            end;
        end;
    end;

    local procedure InitTempTrackingSpecification(WhseActivLine2: Record "Warehouse Activity Line"; var TempTrackingSpecification: Record "Tracking Specification" temporary) QtyToRegisterBase: Decimal
    var
        WhseItemTrkgLine: Record "Whse. Item Tracking Line";
        QtyToHandleBase: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitTempTrackingSpecification(WhseActivLine2, QtyToRegisterBase, IsHandled);
        if IsHandled then
            exit(QtyToRegisterBase);

        QtyToRegisterBase := WhseActivLine2."Qty. to Handle (Base)";
        SetPointerFilter(WhseActivLine2, WhseItemTrkgLine);

        with WhseItemTrkgLine do begin
            SetTrackingFilterFromWhseActivityLine(WhseActivLine2);
            if FindSet() then
                repeat
                    if "Quantity (Base)" > "Qty. Registered (Base)" then begin
                        if QtyToRegisterBase > ("Quantity (Base)" - "Qty. Registered (Base)") then begin
                            QtyToHandleBase := "Quantity (Base)" - "Qty. Registered (Base)";
                            QtyToRegisterBase := QtyToRegisterBase - QtyToHandleBase;
                            "Qty. Registered (Base)" := "Quantity (Base)";
                        end else begin
                            "Qty. Registered (Base)" += QtyToRegisterBase;
                            QtyToHandleBase := QtyToRegisterBase;
                            QtyToRegisterBase := 0;
                        end;
                        if not UpdateTempTracking(WhseActivLine2, QtyToHandleBase, TempTrackingSpecification) then begin
                            TempTrackingSpecification.SetTrackingKey();
                            TempTrackingSpecification.SetTrackingFilterFromWhseActivityLine(WhseActivLine2);
                            if TempTrackingSpecification.FindFirst() then begin
                                TempTrackingSpecification."Qty. to Handle (Base)" += QtyToHandleBase;
                                OnInitTempTrackingSpecificationOnBeforeTempTrackingSpecificationModify(WhseItemTrkgLine, WhseActivLine2, TempTrackingSpecification);
                                TempTrackingSpecification.Modify();
                            end;
                        end;
                        ItemTrackingMgt.SetRegistering(true);
                        ItemTrackingMgt.CalcWhseItemTrkgLine(WhseItemTrkgLine);
                        Modify();
                    end;
                until (Next() = 0) or (QtyToRegisterBase = 0);
        end;
    end;

    local procedure CalcQtyAvailToRegisterBase(WhseActivLine: Record "Warehouse Activity Line"): Decimal
    var
        WhseItemTrackingLine: Record "Whse. Item Tracking Line";
    begin
        SetPointerFilter(WhseActivLine, WhseItemTrackingLine);
        WhseItemTrackingLine.SetTrackingFilterFromWhseActivityLine(WhseActivLine);
        WhseItemTrackingLine.CalcSums("Quantity (Base)", "Qty. Registered (Base)");
        exit(WhseItemTrackingLine."Quantity (Base)" - WhseItemTrackingLine."Qty. Registered (Base)");
    end;

    local procedure SourceLineQtyBase(WhseActivLine: Record "Warehouse Activity Line"): Decimal
    var
        WhsePostedRcptLine: Record "Posted Whse. Receipt Line";
        WhseShipmentLine: Record "Warehouse Shipment Line";
        WhseIntPutAwayLine: Record "Whse. Internal Put-away Line";
        WhseIntPickLine: Record "Whse. Internal Pick Line";
        ProdOrderComponent: Record "Prod. Order Component";
        AssemblyLine: Record "Assembly Line";
        JobPlanningLineRec: Record "Job Planning Line";
        WhseMovementWksh: Record "Whse. Worksheet Line";
        WhseActivLine2: Record "Warehouse Activity Line";
        QtyBase: Decimal;
        WhseDocType2: Enum "Warehouse Activity Document Type";
        IsHandled: Boolean;
        WhseStgdPickLine: Record "Whse. Staged Pick Line";
    begin
        IsHandled := false;
        OnBeforeSourceLineQtyBase(WhseActivLine, QtyBase, IsHandled);
        if IsHandled then
            exit(QtyBase);

        if (WhseActivLine."Whse. Document Type" = WhseActivLine."Whse. Document Type"::Shipment) and
           WhseActivLine."Assemble to Order"
        then
            WhseDocType2 := WhseActivLine."Whse. Document Type"::Assembly
        else
            WhseDocType2 := WhseActivLine."Whse. Document Type";

        case WhseDocType2 of
            WhseActivLine."Whse. Document Type"::Receipt:
                if WhsePostedRcptLine.Get(
                     WhseActivLine."Whse. Document No.", WhseActivLine."Whse. Document Line No.")
                then
                    exit(WhsePostedRcptLine."Qty. (Base)");
            WhseActivLine."Whse. Document Type"::Shipment:
                if WhseShipmentLine.Get(
                     WhseActivLine."Whse. Document No.", WhseActivLine."Whse. Document Line No.")
                then
                    exit(WhseShipmentLine."Qty. (Base)");
            WhseActivLine."Whse. Document Type"::"Internal Put-away":
                if WhseIntPutAwayLine.Get(
                     WhseActivLine."Whse. Document No.", WhseActivLine."Whse. Document Line No.")
                then
                    exit(WhseIntPutAwayLine."Qty. (Base)");
            WhseActivLine."Whse. Document Type"::"Internal Pick":
                if WhseIntPickLine.Get(
                     WhseActivLine."Whse. Document No.", WhseActivLine."Whse. Document Line No.")
                then
                    exit(WhseIntPickLine."Qty. (Base)");
            WhseActivLine."Whse. Document Type"::Production:
                if ProdOrderComponent.Get(
                     WhseActivLine."Source Subtype", WhseActivLine."Source No.",
                     WhseActivLine."Source Line No.", WhseActivLine."Source Subline No.")
                then
                    exit(ProdOrderComponent."Expected Qty. (Base)");
            WhseActivLine."Whse. Document Type"::Assembly:
                if AssemblyLine.Get(
                     WhseActivLine."Source Subtype", WhseActivLine."Source No.",
                     WhseActivLine."Source Line No.")
                then
                    exit(AssemblyLine."Quantity (Base)");
            WhseActivLine."Whse. Document Type"::Job:
                begin
                    JobPlanningLineRec.SetRange("Job Contract Entry No.", WhseActivLine."Source Line No.");
                    JobPlanningLineRec.SetLoadFields("Quantity (Base)");
                    if JobPlanningLineRec.FindFirst() then
                        exit(JobPlanningLineRec."Quantity (Base)");
                end;
            WhseActivLine."Whse. Document Type"::"Movement Worksheet":
                if WhseMovementWksh.Get(
                     WhseActivLine."Whse. Document No.", WhseActivLine."Source No.",
                     WhseActivLine."Location Code", WhseActivLine."Source Line No.")
                then
                    exit(WhseMovementWksh."Qty. (Base)");
            // P8000322A
            WhseActivLine."Whse. Document Type"::FOODStagedPick:
                if WhseStgdPickLine.Get(
                  WhseActivLine."Whse. Document No.", WhseActivLine."Whse. Document Line No.")
                then
                    exit(WhseStgdPickLine."Qty. to Stage (Base)");
        // P8000322A
        end;

        if WhseActivLine."Activity Type" = WhseActivLine."Activity Type"::"Invt. Movement" then // UP
            case WhseActivLine."Source Document" of
                WhseActivLine."Source Document"::"Prod. Consumption":
                    if ProdOrderComponent.Get(
                         WhseActivLine."Source Subtype", WhseActivLine."Source No.",
                         WhseActivLine."Source Line No.", WhseActivLine."Source Subline No.")
                    then
                        exit(ProdOrderComponent."Expected Qty. (Base)");
                WhseActivLine."Source Document"::"Assembly Consumption":
                    if AssemblyLine.Get(
                         WhseActivLine."Source Subtype", WhseActivLine."Source No.",
                         WhseActivLine."Source Line No.")
                    then
                        exit(AssemblyLine."Quantity (Base)");
                WhseActivLine."Source Document"::" ":
                    begin
                        QtyBase := 0;
                        WhseActivLine2.SetCurrentKey("No.", "Line No.", "Activity Type");
                        WhseActivLine2.SetRange("Activity Type", WhseActivLine."Activity Type");
                        WhseActivLine2.SetRange("No.", WhseActivLine."No.");
                        WhseActivLine2.SetFilter("Action Type", '<%1', WhseActivLine2."Action Type"::Place);
                        WhseActivLine2.SetFilter("Qty. to Handle (Base)", '<>0');
                        WhseActivLine2.SetRange("Breakbulk No.", 0);
                        if WhseActivLine2.Find('-') then
                            repeat
                                QtyBase += WhseActivLine2."Qty. (Base)";
                            until WhseActivLine2.Next() = 0;
                        exit(QtyBase);
                    end;
            end;
    end;

    local procedure CalcQtyAvailToInsertBase(WhseActivLine: Record "Warehouse Activity Line"): Decimal
    var
        WhseItemTrkgLine: Record "Whse. Item Tracking Line";
    begin
        SetPointerFilter(WhseActivLine, WhseItemTrkgLine);
        WhseItemTrkgLine.CalcSums(WhseItemTrkgLine."Quantity (Base)");
        exit(SourceLineQtyBase(WhseActivLine) - WhseItemTrkgLine."Quantity (Base)");
    end;

    local procedure CalcQtyReservedOnInventory(WhseActivLine: Record "Warehouse Activity Line"; WhseItemTrackingSetup: Record "Item Tracking Setup")
    begin
        with WhseActivLine do begin
            GetItem("Item No.");
            Item.SetRange("Location Filter", "Location Code");
            Item.SetRange("Variant Filter", "Variant Code");
            SetTrackingFilterToItemIfRequired(Item, WhseItemTrackingSetup);
            Item.CalcFields("Reserved Qty. on Inventory");
        end;
    end;

    local procedure InsertRegWhseItemTrkgLine(WhseActivLine: Record "Warehouse Activity Line"; QtyToRegisterBase: Decimal)
    var
        WhseItemTrkgLine2: Record "Whse. Item Tracking Line";
        NextEntryNo: Integer;
    begin
        with WhseItemTrkgLine2 do begin
            NextEntryNo := WhseItemTrkgLine2.GetLastEntryNo() + 1;

            Init();
            "Entry No." := NextEntryNo;
            "Item No." := WhseActivLine."Item No.";
            Description := WhseActivLine.Description;
            "Variant Code" := WhseActivLine."Variant Code";
            "Location Code" := WhseActivLine."Location Code";
            SetPointer(WhseActivLine, WhseItemTrkgLine2);
            CopyTrackingFromWhseActivityLine(WhseActivLine);
            "Warranty Date" := WhseActivLine."Warranty Date";
            "Expiration Date" := WhseActivLine."Expiration Date";
            "Quantity (Base)" := QtyToRegisterBase;
            "Qty. per Unit of Measure" := WhseActivLine."Qty. per Unit of Measure";
            "Qty. Registered (Base)" := QtyToRegisterBase;
            Quantity := WhseActivLine."Qty. to Handle"; // P8000503A
            "Created by Whse. Activity Line" := true;
            OnInsertRegWhseItemTrkgLineOnAfterCopyFields(WhseItemTrkgLine2, WhseActivLine);

            ItemTrackingMgt.SetRegistering(true);
            ItemTrackingMgt.CalcWhseItemTrkgLine(WhseItemTrkgLine2);
            Insert();
        end;
        OnAfterInsRegWhseItemTrkgLine(WhseActivLine, WhseItemTrkgLine2);
    end;

    procedure SetPointer(WhseActivLine: Record "Warehouse Activity Line"; var WhseItemTrkgLine: Record "Whse. Item Tracking Line")
    var
        WhseDocType2: Enum "Warehouse Activity Document Type";
    begin
        with WhseActivLine do begin
            if ("Whse. Document Type" = "Whse. Document Type"::Shipment) and "Assemble to Order" then
                WhseDocType2 := "Whse. Document Type"::Assembly
            else
                WhseDocType2 := "Whse. Document Type";
            case WhseDocType2 of
                "Whse. Document Type"::Receipt:
                    WhseItemTrkgLine.SetSource(
                      DATABASE::"Posted Whse. Receipt Line", 0, "Whse. Document No.", "Whse. Document Line No.", '', 0);
                "Whse. Document Type"::Shipment:
                    WhseItemTrkgLine.SetSource(
                      DATABASE::"Warehouse Shipment Line", 0, "Whse. Document No.", "Whse. Document Line No.", '', 0);
                "Whse. Document Type"::"Internal Put-away":
                    WhseItemTrkgLine.SetSource(
                      DATABASE::"Whse. Internal Put-away Line", 0, "Whse. Document No.", "Whse. Document Line No.", '', 0);
                "Whse. Document Type"::"Internal Pick":
                    WhseItemTrkgLine.SetSource(
                      DATABASE::"Whse. Internal Pick Line", 0, "Whse. Document No.", "Whse. Document Line No.", '', 0);
                "Whse. Document Type"::Production:
                    WhseItemTrkgLine.SetSource(
                      DATABASE::"Prod. Order Component", "Source Subtype", "Source No.", "Source Subline No.", '', "Source Line No.");
                "Whse. Document Type"::Assembly:
                    WhseItemTrkgLine.SetSource(
                      DATABASE::"Assembly Line", "Source Subtype", "Source No.", "Source Line No.", '', 0);
                "Whse. Document Type"::Job:
                    WhseItemTrkgLine.SetSource(
                      DATABASE::"Job Planning Line", 2, "Source No.", "Source Line No.", '', 0);
                "Whse. Document Type"::"Movement Worksheet":
                    WhseItemTrkgLine.SetSource(
                      DATABASE::"Whse. Worksheet Line", 0, "Source No.", "Whse. Document Line No.",
                      CopyStr("Whse. Document No.", 1, MaxStrLen(WhseItemTrkgLine."Source Batch Name")), 0);
                // P8000322A
                "Whse. Document Type"::FOODStagedPick:
                    WhseItemTrkgLine.SetSource(
                      DATABASE::"Whse. Staged Pick Line", 0, WhseActivLine."Whse. Document No.", "Whse. Document Line No.", '', 0);
            // P8000322A
            end;
            OnSetPointerOnAfterWhseDocTypeSetSource(WhseActivLine, WhseDocType2.AsInteger(), WhseItemTrkgLine);
            WhseItemTrkgLine."Location Code" := "Location Code";
            if "Activity Type" = "Activity Type"::"Invt. Movement" then begin
                WhseItemTrkgLine.SetSource("Source Type", "Source Subtype", "Source No.", "Source Line No.", '', 0);
                if "Source Type" = DATABASE::"Prod. Order Component" then
                    WhseItemTrkgLine.SetSource("Source Type", "Source Subtype", "Source No.", "Source Subline No.", '', "Source Line No.")
                else
                    WhseItemTrkgLine.SetSource("Source Type", "Source Subtype", "Source No.", "Source Line No.", '', 0);
                WhseItemTrkgLine."Location Code" := "Location Code";
            end;
        end;
    end;

    procedure SetPointerFilter(WhseActivLine: Record "Warehouse Activity Line"; var WhseItemTrkgLine: Record "Whse. Item Tracking Line")
    var
        WhseItemTrkgLine2: Record "Whse. Item Tracking Line";
    begin
        SetPointer(WhseActivLine, WhseItemTrkgLine2);
        WhseItemTrkgLine.SetSourceFilter(
          WhseItemTrkgLine2."Source Type", WhseItemTrkgLine2."Source Subtype",
          WhseItemTrkgLine2."Source ID", WhseItemTrkgLine2."Source Ref. No.", true);
        WhseItemTrkgLine.SetSourceFilter(WhseItemTrkgLine2."Source Batch Name", WhseItemTrkgLine2."Source Prod. Order Line");
        WhseItemTrkgLine.SetRange("Location Code", WhseItemTrkgLine2."Location Code");
    end;

    procedure ShowHideDialog(HideDialog2: Boolean)
    begin
        HideDialog := HideDialog2;
    end;

    procedure CalcTotalAvailQtyToPick(WhseActivLine: Record "Warehouse Activity Line"; WhseItemTrackingSetup: Record "Item Tracking Setup"): Decimal
    var
        WhseEntry: Record "Warehouse Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        TempWhseActivLine2: Record "Warehouse Activity Line" temporary;
        WarehouseActivityLine: Record "Warehouse Activity Line";
        WhseActivLineItemTrackingSetup: Record "Item Tracking Setup";
        CreatePick: Codeunit "Create Pick";
        WhseAvailMgt: Codeunit "Warehouse Availability Mgt.";
        BinTypeFilter: Text;
        TotalAvailQtyBase: Decimal;
        QtyInWhseBase: Decimal;
        QtyOnPickBinsBase: Decimal;
        QtyOnOutboundBinsBase: Decimal;
        QtyOnDedicatedBinsBase: Decimal;
        SubTotalBase: Decimal;
        QtyReservedOnPickShipBase: Decimal;
        LineReservedQtyBase: Decimal;
        QtyPickedNotShipped: Decimal;
    begin
        with WhseActivLine do begin
            CalcQtyReservedOnInventory(WhseActivLine, WhseItemTrackingSetup);

            LocationGet("Location Code");
            if Location."Directed Put-away and Pick" or
               ("Activity Type" = "Activity Type"::"Invt. Movement")
            then begin
                WhseEntry.SetCurrentKey("Item No.", "Location Code", "Variant Code", "Bin Type Code");
                WhseEntry.SetRange("Item No.", "Item No.");
                WhseEntry.SetRange("Location Code", "Location Code");
                WhseEntry.SetRange("Variant Code", "Variant Code");
                SetTrackingFilterToWhseEntryIfRequired(WhseEntry, WhseItemTrackingSetup);
                WhseEntry.CalcSums("Qty. (Base)");
                QtyInWhseBase := WhseEntry."Qty. (Base)";
                OnCalcTotalAvailQtyToPickOnAfterCalcQtyInWhseBase(WhseEntry, QtyInWhseBase, "Location Code");

                BinTypeFilter := CreatePick.GetBinTypeFilter(0);
                if BinTypeFilter <> '' then
                    WhseEntry.SetFilter("Bin Type Code", '<>%1', BinTypeFilter); // Pick from all but Receive area
                WhseEntry.CalcSums("Qty. (Base)");
                QtyOnPickBinsBase := WhseEntry."Qty. (Base)";

                // P8000322A
                if ("From Staged Pick No." <> '') then
                    QtyOnPickBinsBase := QtyInWhseBase;
                // P8000322A

                QtyOnOutboundBinsBase :=
                    WhseAvailMgt.CalcQtyOnOutboundBins("Location Code", "Item No.", "Variant Code", WhseItemTrackingSetup, true);

                if "Activity Type" <> "Activity Type"::"Invt. Movement" then begin// Invt. Movement from Dedicated Bin is allowed
                    WhseActivLineItemTrackingSetup.CopyTrackingFromWhseActivityLine(WhseActivLine);
                    QtyOnDedicatedBinsBase :=
                        WhseAvailMgt.CalcQtyOnDedicatedBins("Location Code", "Item No.", "Variant Code", WhseActivLineItemTrackingSetup);
                end;

                SubTotalBase :=
                  QtyInWhseBase -
                  QtyOnPickBinsBase - QtyOnOutboundBinsBase - QtyOnDedicatedBinsBase;
                if "Activity Type" <> "Activity Type"::"Invt. Movement" then
                    SubTotalBase -= Abs(Item."Reserved Qty. on Inventory");

                if SubTotalBase < 0 then begin
                    WhseItemTrackingSetup.CopyTrackingFromWhseActivityLine(WhseActivLine);
                    CreatePick.FilterWhsePickLinesWithUndefinedBin(
                      WarehouseActivityLine, "Item No.", "Location Code", "Variant Code", WhseItemTrackingSetup);
                    if WarehouseActivityLine.FindSet() then
                        repeat
                            TempWhseActivLine2 := WarehouseActivityLine;
                            TempWhseActivLine2."Qty. Outstanding (Base)" *= -1;
                            TempWhseActivLine2.Insert();
                        until WarehouseActivityLine.Next() = 0;

                    QtyReservedOnPickShipBase :=
                      WhseAvailMgt.CalcReservQtyOnPicksShips("Location Code", "Item No.", "Variant Code", TempWhseActivLine2);

                    LineReservedQtyBase :=
                      WhseAvailMgt.CalcLineReservedQtyOnInvt(
                        "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.", true, TempWhseActivLine2);

                    if Abs(SubTotalBase) < QtyReservedOnPickShipBase + LineReservedQtyBase then
                        QtyReservedOnPickShipBase := Abs(SubTotalBase) - LineReservedQtyBase;

                    TotalAvailQtyBase :=
                      QtyOnPickBinsBase +
                      SubTotalBase +
                      QtyReservedOnPickShipBase +
                      LineReservedQtyBase;
                end else
                    TotalAvailQtyBase := QtyOnPickBinsBase;
            end else begin
                ItemLedgEntry.SetCurrentKey(
                  "Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date", "Expiration Date", "Lot No.", "Serial No.");
                ItemLedgEntry.SetRange("Item No.", "Item No.");
                ItemLedgEntry.SetRange("Variant Code", "Variant Code");
                ItemLedgEntry.SetRange(Open, true);
                ItemLedgEntry.SetRange("Location Code", "Location Code");
                SetTrackingFilterToItemLedgEntryIfRequired(ItemLedgEntry, WhseItemTrackingSetup);
                ItemLedgEntry.CalcSums("Remaining Quantity");
                OnCalcTotalAvailQtyToPickOnAfterItemLedgEntryCalcSums(WhseActivLine);
                QtyInWhseBase := ItemLedgEntry."Remaining Quantity";

                QtyPickedNotShipped := CalcQtyPickedNotShipped(WhseActivLine, WhseItemTrackingSetup);

                LineReservedQtyBase :=
                    WhseAvailMgt.CalcLineReservedQtyOnInvt(
                        "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.", false, TempWhseActivLine2);

                TotalAvailQtyBase :=
                  QtyInWhseBase -
                  QtyPickedNotShipped -
                  Abs(Item."Reserved Qty. on Inventory") +
                  LineReservedQtyBase;
            end;

            exit(TotalAvailQtyBase);
        end;
    end;

    local procedure IsQtyAvailToPickNonSpecificReservation(WhseActivLine: Record "Warehouse Activity Line"; WhseItemTrackingSetup: Record "Item Tracking Setup"; QtyToRegister: Decimal): Boolean
    var
        QtyAvailToPick: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeIsQtyAvailToPickNonSpecificReservation(WhseActivLine, QtyAvailToPick, QtyToRegister, IsHandled);
        if not IsHandled then begin
            QtyAvailToPick := CalcTotalAvailQtyToPick(WhseActivLine, WhseItemTrackingSetup);
            if QtyAvailToPick < QtyToRegister then
                if ReleaseNonSpecificReservations(WhseActivLine, WhseItemTrackingSetup, QtyToRegister - QtyAvailToPick) then
                    QtyAvailToPick := CalcTotalAvailQtyToPick(WhseActivLine, WhseItemTrackingSetup);
        end;
        exit(QtyAvailToPick >= QtyToRegister);
    end;

    local procedure CalcQtyPickedNotShipped(WhseActivLine: Record "Warehouse Activity Line"; WhseItemTrackingSetup: Record "Item Tracking Setup") QtyBasePicked: Decimal
    var
        ReservEntry: Record "Reservation Entry";
    begin
        with WhseActivLine do begin
            ReservEntry.Reset();
            ReservEntry.SetCurrentKey("Item No.", "Variant Code", "Location Code", "Reservation Status");
            ReservEntry.SetRange("Item No.", "Item No.");
            ReservEntry.SetRange("Variant Code", "Variant Code");
            ReservEntry.SetRange("Location Code", "Location Code");
            ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Surplus);
            ReservEntry.SetTrackingFilterFromWhseActivityLineIfRequired(WhseActivLine, WhseItemTrackingSetup);
            OnCalcQtyPickedNotShippedOnAfterReservEntrySetFilters(ReservEntry, WhseActivLine);
            if ReservEntry.Find('-') then
                repeat
                    if "Source Type" = Database::Job then begin
                        if not ((ReservEntry."Source Type" = Database::"Job Planning Line") and
                                                        (ReservEntry."Source Subtype" = 2) and
                                                        (ReservEntry."Source ID" = "Source No.") and
                                                        ((ReservEntry."Source Ref. No." = "Source Line No.") or
                                                         (ReservEntry."Source Ref. No." = "Source Subline No."))) and
                                                   not ReservEntry.Positive
                                                then
                            QtyBasePicked := QtyBasePicked + Abs(ReservEntry."Quantity (Base)");
                    end else
                        if not ((ReservEntry."Source Type" = "Source Type") and
                                (ReservEntry."Source Subtype" = "Source Subtype") and
                                (ReservEntry."Source ID" = "Source No.") and
                                ((ReservEntry."Source Ref. No." = "Source Line No.") or
                                 (ReservEntry."Source Ref. No." = "Source Subline No."))) and
                           not ReservEntry.Positive
                        then
                            QtyBasePicked := QtyBasePicked + Abs(ReservEntry."Quantity (Base)");
                until ReservEntry.Next() = 0;

            CalcQtyBasePicked(WhseActivLine, WhseItemTrackingSetup, QtyBasePicked);

            exit(QtyBasePicked);
        end;
    end;

    local procedure CalcQtyBasePicked(WhseActivLine: Record "Warehouse Activity Line"; WhseItemTrackingSetup: Record "Item Tracking Setup"; var QtyBasePicked: Decimal)
    var
        RegWhseActivLine: Record "Registered Whse. Activity Line";
        QtyHandled: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcQtyBasePicked(WhseActivLine, WhseItemTrackingSetup, QtyBasePicked, IsHandled);
        if IsHandled then
            exit;

        with WhseActivLine do
            if WhseItemTrackingSetup."Serial No. Required" or WhseItemTrackingSetup."Lot No. Required" then begin
                RegWhseActivLine.SetRange("Activity Type", "Activity Type");
                RegWhseActivLine.SetRange("No.", "No.");
                RegWhseActivLine.SetRange("Line No.", "Line No.");
                RegWhseActivLine.SetTrackingFilterFromWhseActivityLine(WhseActivLine);
                RegWhseActivLine.SetRange("Bin Code", "Bin Code");
                if RegWhseActivLine.FindSet() then
                    repeat
                        QtyHandled := QtyHandled + RegWhseActivLine."Qty. (Base)";
                    until RegWhseActivLine.Next() = 0;
                QtyBasePicked := QtyBasePicked + QtyHandled;
            end else
                QtyBasePicked := QtyBasePicked + "Qty. Handled (Base)";
    end;

    procedure GetItem(ItemNo: Code[20])
    begin
        if ItemNo <> Item."No." then
            Item.Get(ItemNo);
    end;

    local procedure UpdateTempTracking(WhseActivLine2: Record "Warehouse Activity Line"; QtyToHandleBase: Decimal; var TempTrackingSpecification: Record "Tracking Specification" temporary): Boolean
    var
        NextEntryNo: Integer;
        Inserted: Boolean;
    begin
        with WhseActivLine2 do begin
            NextEntryNo := TempTrackingSpecification.GetLastEntryNo() + 1;
            TempTrackingSpecification.Init();
            if WhseActivLine2."Source Type" = DATABASE::"Prod. Order Component" then
                TempTrackingSpecification.SetSource("Source Type", "Source Subtype", "Source No.", "Source Subline No.", '', "Source Line No.")
            else
                TempTrackingSpecification.SetSource("Source Type", "Source Subtype", "Source No.", "Source Line No.", '', 0);

            ItemTrackingMgt.SetPointerFilter(TempTrackingSpecification);
            TempTrackingSpecification.SetTrackingFilterFromWhseActivityLine(WhseActivLine2);
            if TempTrackingSpecification.IsEmpty() then begin
                TempTrackingSpecification."Entry No." := NextEntryNo;
                TempTrackingSpecification."Creation Date" := Today;
                TempTrackingSpecification."Qty. to Handle (Base)" := QtyToHandleBase;
                TempTrackingSpecification."Item No." := "Item No.";
                TempTrackingSpecification."Variant Code" := "Variant Code";
                TempTrackingSpecification."Location Code" := "Location Code";
                TempTrackingSpecification.Description := Description;
                TempTrackingSpecification."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
                TempTrackingSpecification.CopyTrackingFromWhseActivityLine(WhseActivLine2);
                TempTrackingSpecification."Warranty Date" := "Warranty Date";
                TempTrackingSpecification."Expiration Date" := "Expiration Date";
                TempTrackingSpecification.Correction := true;
                OnBeforeTempTrackingSpecificationInsert(TempTrackingSpecification, WhseActivLine2);
                TempTrackingSpecification.Insert();
                Inserted := true;
                TempTrackingSpecification.Reset();
                OnAfterRegWhseItemTrkgLine(WhseActivLine2, TempTrackingSpecification);
            end;
        end;
        exit(Inserted);
    end;

    local procedure CheckItemTrackingInfoBlocked(WhseActivityLine: Record "Warehouse Activity Line")
    var
        SerialNoInfo: Record "Serial No. Information";
        LotNoInfo: Record "Lot No. Information";
    begin
        if not WhseActivityLine.TrackingExists() then
            exit;

        if WhseActivityLine."Serial No." <> '' then
            if SerialNoInfo.Get(WhseActivityLine."Item No.", WhseActivityLine."Variant Code", WhseActivityLine."Serial No.") then
                SerialNoInfo.TestField(Blocked, false);

        if WhseActivityLine."Lot No." <> '' then
            if LotNoInfo.Get(WhseActivityLine."Item No.", WhseActivityLine."Variant Code", WhseActivityLine."Lot No.") then
                LotNoInfo.TestField(Blocked, false);

        OnAfterCheckItemTrackingInfoBlocked(WhseActivityLine);
    end;

    local procedure UpdateWindow(ControlNo: Integer; Value: Code[20])
    begin
        if not HideDialog then
            case ControlNo of
                1:
                    begin
                        Window.Open(Text000 + Text001 + Text002);
                        Window.Update(1, Value);
                    end;
                2:
                    Window.Update(2, LineCount);
                3:
                    Window.Update(3, LineCount);
                4:
                    Window.Update(4, Round(LineCount / NoOfRecords * 10000, 1));
            end;
    end;

    local procedure CheckLines()
    begin
        OnBeforeCheckLines(GlobalWhseActivHeader, GlobalWhseActivLine, TempBinContentBuffer);

        with GlobalWhseActivHeader do begin
            TempBinContentBuffer.DeleteAll();
            LineCount := 0;
            if GlobalWhseActivLine.Find('-') then
                repeat
                    LineCount := LineCount + 1;
                    UpdateWindow(2, '');
                    GlobalWhseActivLine.CheckBinInSourceDoc();
                    GlobalWhseActivLine.TestField("Item No.");
                    if (GlobalWhseActivLine."Activity Type" = GlobalWhseActivLine."Activity Type"::Pick) and
                       (GlobalWhseActivLine."Destination Type" = GlobalWhseActivLine."Destination Type"::Customer)
                    then begin
                        GlobalWhseActivLine.TestField("Destination No.");
                        CheckBlockedCustOnDocs();
                    end;
                    // P8000282A
                    if GlobalWhseActivLine.TrackAlternateUnits() then
                        AltQtyMgmt.CheckBaseQty(
                          GlobalWhseActivLine."Item No.", GlobalWhseActivLine."Serial No.", GlobalWhseActivLine."Lot No.",
                          GlobalWhseActivLine."Alt. Qty. Transaction No.", GlobalWhseActivLine.FieldCaption("Qty. to Handle (Base)"),
                          GlobalWhseActivLine."Qty. to Handle (Base)");
                    // P8000282A
                    ItemTrackingMgt.CheckWhsePickForSaleLot(GlobalWhseActivLine); // P8000322A
                    if Location."Bin Mandatory" then
                        CheckBinRelatedFields(GlobalWhseActivLine);

                    OnAfterCheckWhseActivLine(GlobalWhseActivLine);

                    if ((GlobalWhseActivLine."Activity Type" = GlobalWhseActivLine."Activity Type"::Pick) or
                        (GlobalWhseActivLine."Activity Type" = GlobalWhseActivLine."Activity Type"::"Invt. Pick") or
                        (GlobalWhseActivLine."Activity Type" = GlobalWhseActivLine."Activity Type"::"Invt. Movement")) and
                       (GlobalWhseActivLine."Action Type" = GlobalWhseActivLine."Action Type"::Take)
                    then
                        CheckItemTrackingInfoBlocked(GlobalWhseActivLine);
                until GlobalWhseActivLine.Next() = 0;
            NoOfRecords := LineCount;

            if Location."Bin Mandatory" then begin
                CheckBinContent();
                CheckBin();
            end;

            // P8001280
            if FindExistingRegActivHeader() then begin
                "Registering No." := RegisteredWhseActivHeader."No.";
                Modify;
                if not SuppressCommit then // P8004516, P800-MegaApp
                    Commit;
            end;
            // P8001280

            if "Registering No." = '' then begin
                TestField("Registering No. Series");
                "Registering No." := NoSeriesMgt.GetNextNo("Registering No. Series", "Assignment Date", true);
                Modify();
                OnCheckLinesOnBeforeCommit(RegisteredWhseActivHeader, RegisteredWhseActivLine, SuppressCommit);
                if not SuppressCommit then
                    Commit();
            end;
        end;

        OnAfterCheckLines(GlobalWhseActivHeader, GlobalWhseActivLine);
    end;

    local procedure CheckBlockedCustOnDocs()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckBlockedCustOnDocs(GlobalWhseActivLine, IsHandled);
        if IsHandled then
            exit;

        Cust.Get(GlobalWhseActivLine."Destination No.");
        Cust.CheckBlockedCustOnDocs(Cust, GlobalWhseActivHeader."Source Document", false, false);
    end;

    local procedure CheckBinRelatedFields(WhseActivLine: Record "Warehouse Activity Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckBinRelatedFields(WhseActivLine, IsHandled);
        if IsHandled then
            exit;

        WhseActivLine.TestField("Unit of Measure Code");
        WhseActivLine.TestField("Bin Code");
        WhseActivLine.CheckWhseDocLine();

        UpdateTempBinContentBuffer(WhseActivLine);
    end;

    local procedure UpdateSourceDocForInvtMovement(WhseActivityLine: Record "Warehouse Activity Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeUpdateSourceDocForInvtMovement(WhseActivityLine, IsHandled);
        if IsHandled then
            exit;

        if (WhseActivityLine."Action Type" = WhseActivityLine."Action Type"::Take) or
           (WhseActivityLine."Source Document" = WhseActivityLine."Source Document"::" ")
        then
            exit;

        with WhseActivityLine do
            case "Source Document" of
                "Source Document"::"Prod. Consumption":
                    UpdateProdCompLine(WhseActivityLine);
                "Source Document"::"Assembly Consumption":
                    UpdateAssemblyLine(WhseActivityLine);
            end;
    end;

    local procedure GetNextTempEntryNo(var TempTrackingSpecification: Record "Tracking Specification" temporary): Integer
    begin
        TempTrackingSpecification.Reset;
        if TempTrackingSpecification.FindLast then
            exit(TempTrackingSpecification."Entry No." + 1);

        exit(1);
    end;

    local procedure UpdateWhseStgdPickLine(WhseActivityLine: Record "Warehouse Activity Line")
    begin
        // P8000322A
        WhseStagedPickLine.Get(WhseActivityLine."Whse. Document No.", WhseActivityLine."Whse. Document Line No.");
        WhseStagedPickLine."Qty. Staged (Base)" :=
          WhseStagedPickLine."Qty. Staged (Base)" + WhseActivityLine."Qty. to Handle (Base)";
        if WhseActivityLine."Qty. per Unit of Measure" = WhseStagedPickLine."Qty. per Unit of Measure" then
            WhseStagedPickLine."Qty. Staged" :=
              WhseStagedPickLine."Qty. Staged" + WhseActivityLine."Qty. to Handle"
        else
            WhseStagedPickLine."Qty. Staged" := WhseStagedPickLine."Qty. Staged" +
              Round(WhseActivityLine."Qty. to Handle" * WhseActivityLine."Qty. per Unit of Measure" / WhseStagedPickLine."Qty. per Unit of Measure", 0.00001);
        WhseStagedPickLine.Validate(
          "Qty. Outstanding", WhseStagedPickLine."Qty. Outstanding" - WhseActivityLine."Qty. to Handle");
        WhseStagedPickLine.UpdateDocStatus(false);
        WhseStagedPickLine.Modify;
        // P8000322A
    end;

    procedure BalanceBaseQtysFromSource(var WhseActivLine2: Record "Warehouse Activity Line")
    var
        WhseActLine: Record "Warehouse Activity Line";
        Qty: Decimal;
        QtyBase: Decimal;
        QtyHandled: Decimal;
        QtyHandledBase: Decimal;
    begin
        // P8000503A
        with WhseActLine do begin
            Copy(WhseActivLine2);
            SetCurrentKey(
              "Activity Type", "No.", "Whse. Document Type",
              "Whse. Document No.", "Whse. Document Line No.");
            FilterGroup(2);
            SetRange("Breakbulk No.", 0);
            SetFilter("Qty. to Handle", '>0');
            SetRange("Action Type", "Action Type"::Take);
            FilterGroup(0);
            if Find('-') then
                repeat
                    FilterGroup(2);
                    SetRange("Whse. Document Type", "Whse. Document Type");
                    SetRange("Whse. Document No.", "Whse. Document No.");
                    SetRange("Whse. Document Line No.", "Whse. Document Line No.");
                    SetRange("Source Subline No.", "Source Subline No.");
                    FilterGroup(0);
                    if GetSourceQtys(Qty, QtyBase, QtyHandled, QtyHandledBase) then // P8000553A
                        repeat
                            UpdateWhseActLinesQtyBase(
                              WhseActLine, Qty, QtyBase, QtyHandled, QtyHandledBase);
                        until (Next = 0);
                    FilterGroup(2);
                    SetRange("Whse. Document Type");
                    SetRange("Whse. Document No.");
                    SetRange("Whse. Document Line No.");
                    SetRange("Source Subline No.");
                    FilterGroup(0);
                until (Next = 0);
        end;
        // P8000503A
    end;

    procedure UpdateWhseActLinesQtyBase(var WhseActivLine2: Record "Warehouse Activity Line"; Qty: Decimal; QtyBase: Decimal; var QtyHandled: Decimal; var QtyHandledBase: Decimal)
    var
        WhseActLine: Record "Warehouse Activity Line";
        QtyHandledBaseAfter: Decimal;
        AdjQtyBase: Decimal;
    begin
        // P8000503A
        with WhseActivLine2 do begin
            if ((QtyHandled + "Qty. to Handle") < Qty) then
                QtyHandledBaseAfter :=
                  Round((QtyHandled + "Qty. to Handle") * "Qty. per Unit of Measure", 0.00001)
            else
                QtyHandledBaseAfter := QtyBase;
            AdjQtyBase := (QtyHandledBaseAfter - QtyHandledBase) - "Qty. to Handle (Base)";
        end;

        if (AdjQtyBase <> 0) then begin
            AdjustWhseActLineQtyBase(WhseActivLine2, AdjQtyBase);
            with WhseActLine do begin
                Copy(WhseActivLine2);
                FilterGroup(2);
                SetRange("Action Type", "Action Type"::Place);
                SetRange("Lot No.", "Lot No.");
                FilterGroup(0);
                if Find('>') then
                    AdjustWhseActLineQtyBase(WhseActLine, AdjQtyBase);
            end;
        end;

        QtyHandled := QtyHandled + WhseActivLine2."Qty. to Handle";
        QtyHandledBase := QtyHandledBase + WhseActivLine2."Qty. to Handle (Base)";
        // P8000503A
    end;

    procedure AdjustWhseActLineQtyBase(var WhseActivLine2: Record "Warehouse Activity Line"; AdjQtyBase: Decimal)
    begin
        // P8000503A
        with WhseActivLine2 do begin
            "Qty. to Handle (Base)" := "Qty. to Handle (Base)" + AdjQtyBase;
            if ("Qty. to Handle" = "Qty. Outstanding") then begin
                "Qty. (Base)" := "Qty. (Base)" + AdjQtyBase;
                "Qty. Outstanding (Base)" := "Qty. Outstanding (Base)" + AdjQtyBase;
            end;
            Modify;
        end;
        // P8000503A
    end;

    local procedure FindExistingRegActivHeader(): Boolean
    var
        RegWhseActivHeader: Record "Registered Whse. Activity Hdr.";
    begin
        // P8001280
        UseExistingRegActivHeader := false;
        if Location."Combine Reg. Whse. Activities" and
           (GlobalWhseActivHeader.Type in
            [GlobalWhseActivHeader.Type::"Put-away", GlobalWhseActivHeader.Type::Pick, GlobalWhseActivHeader.Type::Movement])
        then
            with RegWhseActivHeader do begin
                SetCurrentKey("Whse. Activity No.");
                SetRange("Whse. Activity No.", GlobalWhseActivHeader."No.");
                SetRange(Type, GlobalWhseActivHeader.Type);
                SetRange("Assigned User ID", GlobalWhseActivHeader."Assigned User ID");
                SetRange("Registering Date", WorkDate);
                if FindLast then
                    UseExistingRegActivHeader := RegisteredWhseActivHeader.Get(Type, "No.");
            end;
        exit(UseExistingRegActivHeader);
    end;

    local procedure FindExistingRegActivLine(): Boolean
    var
        RegWhseActivLine: Record "Registered Whse. Activity Line";
    begin
        // P8001280
        if UseExistingRegActivHeader then
            with RegWhseActivLine do begin
                SetRange("Activity Type", RegisteredWhseActivHeader.Type);
                SetRange("No.", RegisteredWhseActivHeader."No.");
                SetRange("Item No.", GlobalWhseActivLine."Item No.");
                SetRange("Variant Code", GlobalWhseActivLine."Variant Code");
                SetRange("Unit of Measure Code", GlobalWhseActivLine."Unit of Measure Code");
                SetRange("Breakbulk No.", GlobalWhseActivLine."Breakbulk No.");
                SetRange("Serial No.", GlobalWhseActivLine."Serial No.");
                SetRange("Lot No.", GlobalWhseActivLine."Lot No.");
                SetRange("Container ID", GlobalWhseActivLine."Container ID"); // P80039754
                SetRange("Source Type", GlobalWhseActivLine."Source Type");
                SetRange("Source Subtype", GlobalWhseActivLine."Source Subtype");
                SetRange("Source No.", GlobalWhseActivLine."Source No.");
                SetRange("Source Line No.", GlobalWhseActivLine."Source Line No.");
                SetRange("Source Subline No.", GlobalWhseActivLine."Source Subline No.");
                SetRange("Whse. Document Type", GlobalWhseActivLine."Whse. Document Type");
                SetRange("Whse. Document No.", GlobalWhseActivLine."Whse. Document No.");
                SetRange("Whse. Document Line No.", GlobalWhseActivLine."Whse. Document Line No.");
                SetRange("Action Type", "Action Type"::Take);
                case GlobalWhseActivLine."Action Type" of
                    GlobalWhseActivLine."Action Type"::Take:
                        begin
                            SetRange("Bin Code", GlobalWhseActivLine."Bin Code");
                            if FindLast then
                                exit(RegisteredWhseActivLine.Get("Activity Type", "No.", "Line No."));
                        end;
                    GlobalWhseActivLine."Action Type"::Place:
                        if FindLast then begin
                            SetFilter("Line No.", '>%1', "Line No.");
                            SetRange("Action Type", GlobalWhseActivLine."Action Type");
                            SetRange("Bin Code", GlobalWhseActivLine."Bin Code");
                            if FindFirst then
                                exit(RegisteredWhseActivLine.Get("Activity Type", "No.", "Line No."));
                        end;
                end;
            end;
    end;

    local procedure AssignRegWhseActivLineNo()
    var
        RegWhseActivLine: Record "Registered Whse. Activity Line";
    begin
        // P8001280
        if UseExistingRegActivHeader then
            with RegWhseActivLine do begin
                SetRange("Activity Type", RegisteredWhseActivHeader.Type);
                SetRange("No.", RegisteredWhseActivHeader."No.");
                if FindLast then
                    RegisteredWhseActivLine."Line No." := "Line No." + 10000;
            end;
    end;

    local procedure RegisterContainer(WhseActivLine: Record "Warehouse Activity Line")
    var
        ContainerHeader: Record "Container Header";
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        SalesRelease: Codeunit "Release Sales Document";
        PurchRelease: Codeunit "Release Purchase Document";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
    begin
        // P8001347
        SalesRelease.SetSkipCalcFreight(true);  // P80043567
        with WhseActivLine do
            if ("Action Type" = "Action Type"::Place) and ("Container ID" <> '') then begin
                ContainerHeader.Get("Container ID");
                if (ContainerHeader."Bin Code" <> "Bin Code") then begin
                    ContainerHeader.Validate("Bin Code", "Bin Code");
                    ContainerHeader.Modify;
                end;
                if ContainerHeader."Pending Assignment" then begin
                    if ("Activity Type" = "Activity Type"::Pick) and
                      ("Source Document" in ["Source Document"::"Sales Order", "Source Document"::"Purchase Return Order",
                                             "Source Document"::"Outbound Transfer", "Source Document"::"Prod. Consumption"]) // P80056710
                    then begin
                        case "Source Type" of
                            DATABASE::"Sales Line":
                                begin
                                    SalesHeader.Get("Source Subtype", "Source No.");
                                    SalesRelease.Reopen(SalesHeader);
                                    SalesRelease.SetDeliveryTrip(GetDeliveryTripNo(WhseActivLine));    // P8008361, P80082431
                                end;
                            DATABASE::"Purchase Line":
                                begin
                                    PurchHeader.Get("Source Subtype", "Source No.");
                                    PurchRelease.Reopen(PurchHeader);
                                end;
                        end;
                        ContainerFns.SetRegisteringPick(true);
                        ContainerFns.DeleteContainerFromOrder(ContainerHeader);
                        ContainerHeader."Document Type" := "Source Type";
                        ContainerHeader."Document Subtype" := "Source Subtype";
                        ContainerHeader."Document No." := "Source No.";
                        ContainerHeader."Document Line No." := ContainerHeader.SourceLineNo("Source Type", "Source Subtype", "Source Line No."); // P80056710
                        if WhseActivLine."Whse. Document Type" in [WhseActivLine."Whse. Document Type"::Receipt, WhseActivLine."Whse. Document Type"::Shipment] then begin // P80056710
                            ContainerHeader."Whse. Document Type" := WhseActivLine."Whse. Document Type";
                            ContainerHeader."Whse. Document No." := WhseActivLine."Whse. Document No.";
                        end; // P80056710
                        case ContainerHeader."Document Type" of
                            DATABASE::"Sales Line":
                                ContainerFns.UpdateSalesForContainer(ContainerHeader, WhseActivLine."Whse. Document Type", WhseActivLine."Whse. Document No.");
                            DATABASE::"Purchase Line":
                                ContainerFns.UpdatePurchaseForContainer(ContainerHeader, WhseActivLine."Whse. Document Type", WhseActivLine."Whse. Document No.");
                            DATABASE::"Transfer Line":
                                ContainerFns.UpdateTransferForContainer(ContainerHeader, WhseActivLine."Whse. Document Type", WhseActivLine."Whse. Document No.");
                            DATABASE::"Prod. Order Component":
                                ContainerFns.UpdateProductionForContainer(ContainerHeader); // P80056710
                        end;
                        // P800110480
                        IF ContainerHeader."Document Type" <> DATABASE::"Prod. Order Component" THEN
                            IF ContainerHeader."Whse. Document Type" = WhseActivLine."Whse. Document Type"::Shipment THEN BEGIN
                                WarehouseShipmentHeader.GET(ContainerHeader."Whse. Document No.");
                                IF WarehouseShipmentHeader."Container Pick and Ship" THEN BEGIN
                                    ContainerHeader."Ship/Receive" := TRUE;
                                    ContainerHeader.MODIFY;
                                    ContainerFns.UpdateContainerShipReceive(ContainerHeader, TRUE, FALSE);
                                END;
                            END;
                        // P800110480                        
                        ContainerHeader.Modify;
                        case "Source Type" of
                            DATABASE::"Sales Line":
                                SalesRelease.Run(SalesHeader);
                            DATABASE::"Purchase Line":
                                PurchRelease.Run(PurchHeader);
                        end;
                    end;
                end;
            end;
    end;

    local procedure UpdateContainerBeforeMovement(var WhseActivityLine: Record "Warehouse Activity Line"; var PlaceContainerActivityLine: Record "Warehouse Activity Line" temporary)
    var
        WhseActivityLine2: Record "Warehouse Activity Line";
        WhseActivityLine3: Record "Warehouse Activity Line";
        ContainerHeader: Record "Container Header";
        ContainerLine: Record "Container Line";
        xContainerLine: Record "Container Line";
        ItemVariant: Record "Item Variant" temporary;
        QtyToRemove: Decimal;
        QtyToRemoveAlt: Decimal;
        QtyAlt: Decimal;
        MoveContainer: Boolean;
    begin
        // P8001323
        // Before making the warehouse movements we need to update the containers
        //    If the container is not moving then just take out what is being moved, so it becomes loose and can be moved
        //    If the container is moving then remove the entire contents of the container so it can be moved, we'll rebuild it later
        Clear(PostContainerLine);
        case WhseActivityLine."Activity Type" of
            WhseActivityLine."Activity Type"::"Put-away":
                PostContainerLine.SetUsageParms(WorkDate, WhseActivityLine."Whse. Document No.", '', SourceCodeSetup."Whse. Put-away");
            WhseActivityLine."Activity Type"::Pick:
                PostContainerLine.SetUsageParms(WorkDate, WhseActivityLine."Whse. Document No.", '', SourceCodeSetup."Whse. Pick");
            WhseActivityLine."Activity Type"::Movement:
                PostContainerLine.SetUsageParms(WorkDate, WhseActivityLine."Whse. Document No.", '', SourceCodeSetup."Whse. Movement");
        end;

        WhseActivityLine2.Copy(WhseActivityLine);
        WhseActivityLine3.Copy(WhseActivityLine);

        WhseActivityLine2.SetRange("Action Type", WhseActivityLine2."Action Type"::Take);
        WhseActivityLine2.SetFilter("Container ID", '<>%1', '');
        WhseActivityLine2.SetCurrentKey("Container ID", "Item No.", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.");
        if WhseActivityLine2.FindSet then
            repeat
                // Process each container that occurs on a Take line
                WhseActivityLine2.SetRange("Container ID", WhseActivityLine2."Container ID");

                // find out if it also occurs on a Place line
                WhseActivityLine3.SetRange("Action Type", WhseActivityLine2."Action Type"::Place);
                WhseActivityLine3.SetRange("Container ID", WhseActivityLine2."Container ID");
                // P80056710
                MoveContainer := not WhseActivityLine3.IsEmpty;
                ContainerHeader.Get(WhseActivityLine2."Container ID");
                if (not MoveContainer) or (ContainerHeader."Document Type" = DATABASE::"Prod. Order Component") then begin
                    ItemVariant.Reset;
                    ItemVariant.DeleteAll;
                    // P80056710
                    // Container is not being moved or is a production container
                    // Sum the activity lines by item, variant, UOM, lot, serial and remove what is being picked
                    repeat
                        WhseActivityLine2.SetRange("Item No.", WhseActivityLine2."Item No.");
                        WhseActivityLine2.SetRange("Variant Code", WhseActivityLine2."Variant Code");
                        WhseActivityLine2.SetRange("Unit of Measure Code", WhseActivityLine2."Unit of Measure Code");
                        WhseActivityLine2.SetRange("Lot No.", WhseActivityLine2."Lot No.");
                        WhseActivityLine2.SetRange("Serial No.", WhseActivityLine2."Serial No.");
                        WhseActivityLine2.FindLast;
                        WhseActivityLine2.CalcSums("Qty. to Handle", "Qty. to Handle (Alt.)");
                        WhseActivityLine2.SetRange("Item No.");
                        WhseActivityLine2.SetRange("Variant Code");
                        WhseActivityLine2.SetRange("Unit of Measure Code");
                        WhseActivityLine2.SetRange("Lot No.");
                        WhseActivityLine2.SetRange("Serial No.");

                        ContainerLine.Reset;
                        ContainerLine.SetRange("Container ID", WhseActivityLine2."Container ID");
                        ContainerLine.SetRange("Item No.", WhseActivityLine2."Item No.");
                        ContainerLine.SetRange("Variant Code", WhseActivityLine2."Variant Code");
                        ContainerLine.SetRange("Unit of Measure Code", WhseActivityLine2."Unit of Measure Code");
                        ContainerLine.SetRange("Lot No.", WhseActivityLine2."Lot No.");
                        ContainerLine.SetRange("Serial No.", WhseActivityLine2."Serial No.");
                        if ContainerLine.FindSet(true) then
                            repeat
                                if ContainerLine.Quantity < WhseActivityLine2."Qty. to Handle" then
                                    QtyToRemove := ContainerLine.Quantity
                                else
                                    QtyToRemove := WhseActivityLine2."Qty. to Handle";
                                // P80056710
                                if ContainerHeader."Document Type" = DATABASE::"Prod. Order Component" then
                                    QtyToRemoveAlt := Round(ContainerLine."Quantity (Alt.)" * QtyToRemove / ContainerLine.Quantity, 0.00001)
                                else
                                    // P80056710
                                    if ContainerLine."Quantity (Alt.)" < WhseActivityLine2."Qty. to Handle (Alt.)" then
                                        QtyToRemoveAlt := ContainerLine.Quantity
                                    else
                                        QtyToRemoveAlt := WhseActivityLine2."Qty. to Handle (Alt.)";

                                if (0 < QtyToRemove) or (0 < QtyToRemoveAlt) then begin
                                    // P80056710
                                    if ContainerHeader."Document Type" = DATABASE::"Prod. Order Component" then begin
                                        // For production containers when we will need to rebuild the container
                                        OriginalContainerLine := ContainerLine;
                                        OriginalContainerLine.Quantity := QtyToRemove;
                                        OriginalContainerLine."Quantity (Alt.)" := QtyToRemoveAlt;
                                        OriginalContainerLine.Insert;
                                    end;
                                    // P80056710
                                    xContainerLine := ContainerLine;
                                    QtyAlt := ContainerLine."Quantity (Alt.)" - QtyToRemoveAlt; // P80075420
                                    ContainerLine.Quantity -= QtyToRemove;
                                    ContainerLine.Validate(Quantity);
                                    // P80075420
                                    if (QtyAlt <> 0) and (ContainerLine."Quantity (Alt.)" = 0) then
                                        ContainerLine.Validate("Quantity (Alt.)", QtyAlt);
                                    // P80075420
                                    if (ContainerLine.Quantity = 0) and (ContainerLine."Quantity (Alt.)" = 0) then
                                        ContainerLine.Delete
                                    else
                                        ContainerLine.Modify;
                                    if not MoveContainer then begin // P80056710
                                        PostContainerLine := ContainerLine;
                                        PostContainerLine.PostContainerUse(xContainerLine.Quantity, xContainerLine."Quantity (Alt.)", ContainerLine.Quantity, ContainerLine."Quantity (Alt.)");
                                    end;                            // P80056710
                                end;
                                WhseActivityLine2."Qty. to Handle" -= QtyToRemove;
                                WhseActivityLine2."Qty. to Handle (Alt.)" -= QtyToRemoveAlt;
                            until (ContainerLine.Next = 0) or ((QtyToRemove = 0) and (QtyToRemoveAlt = 0));
                        if WhseActivityLine2."Qty. to Handle" > 0 then                                      // P80056710
                            Error(Text37002000, WhseActivityLine2."Item No.", ContainerHeader."License Plate"); // P80056710
                                                                                                                // Keep track of the items that are being moved with the container
                        ItemVariant."Item No." := WhseActivityLine2."Item No.";
                        ItemVariant.Code := WhseActivityLine2."Variant Code";
                        if ItemVariant.Insert then;
                    until WhseActivityLine2.Next = 0;

                    // P80056710
                    if ContainerHeader."Document Type" = DATABASE::"Prod. Order Component" then begin
                        // Check what is left in the container to insure that the item is on the pick
                        ContainerLine.Reset;
                        ContainerLine.SetRange("Container ID", WhseActivityLine2."Container ID");
                        if ContainerLine.FindSet then
                            repeat
                                if not ItemVariant.Get(ContainerLine."Item No.", ContainerLine."Variant Code") then
                                    Error(Text37002001, ContainerHeader."License Plate");
                            until ContainerLine.Next = 0;
                    end else begin
                        // P80056710
                        // Check to see if the container is now empty and, if so, delete it
                        ContainerLine.Reset;
                        ContainerLine.SetRange("Container ID", WhseActivityLine2."Container ID");
                        if ContainerLine.IsEmpty then begin
                            ContainerHeader.Get(WhseActivityLine2."Container ID");
                            ContainerHeader.Delete(true);
                        end;
                    end; // P80056710
                end else begin
                    // Container is being moved and is not a production container
                    // Can skip to the end of the activity lines for this container since we will remove everything from the container and is is not
                    //    necessary to look at the individual activity lines
                    WhseActivityLine2.FindLast;

                    ContainerLine.Reset;
                    ContainerLine.SetRange("Container ID", WhseActivityLine2."Container ID");
                    // P80046533
                    ContainerLine.SetCurrentKey("Item No.", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.");
                    if ContainerLine.FindSet(true) then begin
                        repeat
                            ContainerLine.SetRange("Item No.", ContainerLine."Item No.");
                            ContainerLine.SetRange("Variant Code", ContainerLine."Variant Code");
                            ContainerLine.SetRange("Unit of Measure Code", ContainerLine."Unit of Measure Code");
                            ContainerLine.SetRange("Lot No.", ContainerLine."Lot No.");
                            ContainerLine.SetRange("Serial No.", ContainerLine."Serial No.");
                            ContainerLine.FindLast;
                            ContainerLine.CalcSums(Quantity, "Quantity (Base)", "Quantity (Alt.)");
                            OriginalContainerLine := ContainerLine;
                            OriginalContainerLine.Insert;
                            ContainerLine.SetRange("Item No.");
                            ContainerLine.SetRange("Variant Code");
                            ContainerLine.SetRange("Unit of Measure Code");
                            ContainerLine.SetRange("Lot No.");
                            ContainerLine.SetRange("Serial No.");
                        until ContainerLine.Next = 0;
                        ContainerLine.DeleteAll;
                    end;
                    // P80046533
                end;
                WhseActivityLine2.SetFilter("Container ID", '<>%1', '');
            until WhseActivityLine2.Next = 0;

        // P800-MegaApp
        WhseActivityLine2.Copy(WhseActivityLine);
        WhseActivityLine2.SetRange("Action Type", WhseActivityLine2."Action Type"::Place);
        WhseActivityLine2.SetFilter("Container ID", '<>%1', '');
        if WhseActivityLine2.FindSet then
            repeat
                PlaceContainerActivityLine := WhseActivityLine2;
                PlaceContainerActivityLine.Insert;
            until WhseActivityLine2.Next = 0;
        // P800-MegaApp
    end;

    local procedure UpdateContainerAfterMovement(var WhseActivityLine2: Record "Warehouse Activity Line" temporary)
    var
        ContainerHeader: Record "Container Header";
        ContainerLine: Record "Container Line";
        ContainerLine2: Record "Container Line";
        NewContainerLineQuantity: Decimal;
        NewContainerLineQuantityAlt: Decimal;
        QtyToReplace: Decimal;
        QtyToReplaceAlt: Decimal;
        QtyAlt: Decimal;
        LineNo: Integer;
        MoveContainer: Boolean;
    begin
        // P8001323
        // P800-MegaApp
        // WhseActivityLine2.Copy(WhseActivityLine); 

        // WhseActivityLine2.SetRange("Action Type", WhseActivityLine2."Action Type"::Place);
        // WhseActivityLine2.SetFilter("Container ID", '<>%1', '');
        // P800-MegaApp
        WhseActivityLine2.SetCurrentKey("Container ID", "Item No.", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.", "Source Line No.");
        if WhseActivityLine2.FindSet then
            repeat
                // Process each container that occurs on a Place line
                WhseActivityLine2.SetRange("Container ID", WhseActivityLine2."Container ID");

                // P80046533
                ContainerHeader.Get(WhseActivityLine2."Container ID");
                if ContainerHeader."Bin Code" <> WhseActivityLine2."Bin Code" then begin
                    MoveContainer := true; // P80056710
                    ContainerHeader.RegisterMovement; // P80056710
                    ContainerHeader.Validate("Bin Code", WhseActivityLine2."Bin Code");
                    ContainerHeader.Modify;
                end;

                // P80056710
                if MoveContainer and (ContainerHeader."Document Type" = DATABASE::"Prod. Order Component") then begin
                    // For production containers that are being moved all we have to do is rebuild the original container
                    OriginalContainerLine.SetRange("Container ID", ContainerHeader.ID);
                    if OriginalContainerLine.FindSet then
                        repeat
                            if ContainerLine.Get(OriginalContainerLine."Container ID", OriginalContainerLine."Line No.") then begin
                                ContainerLine.Quantity += OriginalContainerLine.Quantity;
                                QtyAlt := ContainerLine."Quantity (Alt.)" + OriginalContainerLine."Quantity (Alt.)"; // P800128454
                                ContainerLine.Validate(Quantity);
                                ContainerLine.Validate("Quantity (Alt.)", QtyAlt); // P800128454
                                ContainerLine.Modify;
                            end else begin
                                ContainerLine := OriginalContainerLine;
                                ContainerLine."Bin Code" := ContainerHeader."Bin Code";
                                ContainerLine.Insert;
                            end;
                        until OriginalContainerLine.Next = 0;
                    WhseActivityLine2.FindLast;
                end else begin
                    // P80056710
                    ContainerLine.SetRange("Container ID", ContainerHeader.ID);
                    if ContainerLine.FindLast then
                        LineNo := ContainerLine."Line No.";
                    // P80046533

                    repeat
                        NewContainerLineQuantity := 0;
                        NewContainerLineQuantityAlt := 0;
                        WhseActivityLine2.SetRange("Item No.", WhseActivityLine2."Item No.");
                        WhseActivityLine2.SetRange("Variant Code", WhseActivityLine2."Variant Code");
                        WhseActivityLine2.SetRange("Unit of Measure Code", WhseActivityLine2."Unit of Measure Code");
                        WhseActivityLine2.SetRange("Lot No.", WhseActivityLine2."Lot No.");
                        WhseActivityLine2.SetRange("Serial No.", WhseActivityLine2."Serial No.");
                        // P80046533
                        repeat
                            WhseActivityLine2.SetRange("Source Line No.", WhseActivityLine2."Source Line No.");
                            WhseActivityLine2.FindLast;
                            WhseActivityLine2.CalcSums("Qty. to Handle", "Qty. to Handle (Alt.)");
                            WhseActivityLine2.SetRange("Source Line No.");

                            LineNo += 10000;
                            ContainerLine.Init;
                            ContainerLine."Container ID" := WhseActivityLine2."Container ID";
                            ContainerLine."Line No." := LineNo;
                            ContainerLine.Validate("Item No.", WhseActivityLine2."Item No.");
                            ContainerLine.Validate("Variant Code", WhseActivityLine2."Variant Code");
                            ContainerLine.Validate("Unit of Measure Code", WhseActivityLine2."Unit of Measure Code");
                            ContainerLine.Validate("Lot No.", WhseActivityLine2."Lot No.");
                            ContainerLine.Validate("Serial No.", WhseActivityLine2."Serial No.");
                            ContainerLine.Validate(Quantity, WhseActivityLine2."Qty. to Handle");
                            ContainerLine.Validate("Quantity (Alt.)", WhseActivityLine2."Qty. to Handle (Alt.)");  // P80068361
                            ContainerLine."Document Line No." := WhseActivityLine2."Source Line No.";
                            ContainerLine.Insert;
                            if not ContainerHeader."Pending Assignment" then begin
                                ContainerFns.SetRegisteringPick(true);
                                ContainerFns.AssignContainerLine(ContainerHeader, ContainerLine2, ContainerLine);
                            end;
                            NewContainerLineQuantity += WhseActivityLine2."Qty. to Handle";
                            NewContainerLineQuantityAlt += WhseActivityLine2."Qty. to Handle (Alt.)";
                        until WhseActivityLine2.Next = 0;
                        WhseActivityLine2.SetRange("Item No.");
                        WhseActivityLine2.SetRange("Variant Code");
                        WhseActivityLine2.SetRange("Unit of Measure Code");
                        WhseActivityLine2.SetRange("Lot No.");
                        WhseActivityLine2.SetRange("Serial No.");

                        OriginalContainerLine.SetRange("Container ID", ContainerHeader.ID);
                        OriginalContainerLine.SetRange("Item No.", WhseActivityLine2."Item No.");
                        OriginalContainerLine.SetRange("Variant Code", WhseActivityLine2."Variant Code");
                        OriginalContainerLine.SetRange("Unit of Measure Code", WhseActivityLine2."Unit of Measure Code");
                        OriginalContainerLine.SetRange("Lot No.", WhseActivityLine2."Lot No.");
                        OriginalContainerLine.SetRange("Serial No.", WhseActivityLine2."Serial No.");
                        if not OriginalContainerLine.FindFirst then
                            Clear(OriginalContainerLine);
                        PostContainerLine := ContainerLine;
                        PostContainerLine.PostContainerUse(OriginalContainerLine.Quantity, OriginalContainerLine."Quantity (Alt.)",
                          NewContainerLineQuantity, NewContainerLineQuantityAlt);
                    // P80046533
                    until WhseActivityLine2.Next = 0;
                end; // P80056710
                RegisterContainer(WhseActivityLine2); // P80056710

                WhseActivityLine2.SetFilter("Container ID", '<>%1', '');
            until WhseActivityLine2.Next = 0;
    end;

    local procedure AutoReserveForSalesLine(var TempWhseActivLineToReserve: Record "Warehouse Activity Line" temporary; var TempReservEntryBefore: Record "Reservation Entry" temporary; var TempReservEntryAfter: Record "Reservation Entry" temporary)
    var
        SalesLine: Record "Sales Line";
        WhseItemTrackingSetup: Record "Item Tracking Setup";
        ReservMgt: Codeunit "Reservation Management";
        FullAutoReservation: Boolean;
        IsHandled: Boolean;
        QtyToReserve: Decimal;
        QtyToReserveBase: Decimal;
    begin
        IsHandled := false;
        OnBeforeAutoReserveForSalesLine(TempWhseActivLineToReserve, IsHandled);
        if IsHandled then
            exit;

        with TempWhseActivLineToReserve do
            if FindSet() then
                repeat
                    ItemTrackingMgt.GetWhseItemTrkgSetup("Item No.", WhseItemTrackingSetup);
                    if HasRequiredTracking(WhseItemTrackingSetup) then begin
                        SalesLine.Get("Source Subtype", "Source No.", "Source Line No.");

                        TempReservEntryBefore.SetSourceFilter("Source Type", "Source Subtype", "Source No.", "Source Line No.", true);
                        TempReservEntryBefore.SetTrackingFilterFromWhseActivityLine(TempWhseActivLineToReserve);
                        TempReservEntryBefore.CalcSums(Quantity, "Quantity (Base)");

                        TempReservEntryAfter.CopyFilters(TempReservEntryBefore);
                        TempReservEntryAfter.CalcSums(Quantity, "Quantity (Base)");

                        QtyToReserve :=
                          "Qty. to Handle" + (TempReservEntryAfter.Quantity - TempReservEntryBefore.Quantity);
                        QtyToReserveBase :=
                          "Qty. to Handle (Base)" + (TempReservEntryAfter."Quantity (Base)" - TempReservEntryBefore."Quantity (Base)");

                        if not IsSalesLineCompletelyReserved(SalesLine) and (QtyToReserve > 0) then begin
                            ReservMgt.SetReservSource(SalesLine);
                            ReservMgt.SetTrackingFromWhseActivityLine(TempWhseActivLineToReserve);
                            OnAutoReserveForSalesLineOnBeforeRunAutoReserve(TempWhseActivLineToReserve);
                            ReservMgt.AutoReserve(FullAutoReservation, '', SalesLine."Shipment Date", QtyToReserve, QtyToReserveBase);
                        end;
                    end;
                until Next() = 0;
    end;

    local procedure AutoReserveForAssemblyLine(var TempWhseActivLineToReserve: Record "Warehouse Activity Line" temporary; var TempReservEntryBefore: Record "Reservation Entry" temporary; var TempReservEntryAfter: Record "Reservation Entry" temporary)
    var
        AsmLine: Record "Assembly Line";
        WhseItemTrackingSetup: Record "Item Tracking Setup";
        ReservMgt: Codeunit "Reservation Management";
        FullAutoReservation: Boolean;
        IsHandled: Boolean;
        QtyToReserve: Decimal;
        QtyToReserveBase: Decimal;
    begin
        IsHandled := false;
        OnBeforeAutoReserveForAssemblyLine(TempWhseActivLineToReserve, IsHandled);
        if IsHandled then
            exit;

        if TempWhseActivLineToReserve.FindSet() then
            repeat
                ItemTrackingMgt.GetWhseItemTrkgSetup(TempWhseActivLineToReserve."Item No.", WhseItemTrackingSetup);
                if TempWhseActivLineToReserve.HasRequiredTracking(WhseItemTrackingSetup) then begin
                    AsmLine.Get(
                      TempWhseActivLineToReserve."Source Subtype", TempWhseActivLineToReserve."Source No.", TempWhseActivLineToReserve."Source Line No.");

                    TempReservEntryBefore.SetSourceFilter(
                      TempWhseActivLineToReserve."Source Type", TempWhseActivLineToReserve."Source Subtype",
                      TempWhseActivLineToReserve."Source No.", TempWhseActivLineToReserve."Source Line No.", true);
                    TempReservEntryBefore.SetTrackingFilterFromWhseActivityLine(TempWhseActivLineToReserve);
                    TempReservEntryBefore.CalcSums(Quantity, "Quantity (Base)");

                    TempReservEntryAfter.CopyFilters(TempReservEntryBefore);
                    TempReservEntryAfter.CalcSums(Quantity, "Quantity (Base)");

                    QtyToReserve :=
                        TempWhseActivLineToReserve."Qty. to Handle" + (TempReservEntryAfter.Quantity - TempReservEntryBefore.Quantity);
                    QtyToReserveBase :=
                        TempWhseActivLineToReserve."Qty. to Handle (Base)" + (TempReservEntryAfter."Quantity (Base)" - TempReservEntryBefore."Quantity (Base)");

                    if not IsAssemblyLineCompletelyReserved(AssemblyLine) and (QtyToReserve > 0) then begin
                        ReservMgt.SetReservSource(AsmLine);
                        ReservMgt.SetTrackingFromWhseActivityLine(TempWhseActivLineToReserve);
                        ReservMgt.AutoReserve(FullAutoReservation, '', AsmLine."Due Date", QtyToReserve, QtyToReserveBase);
                    end;
                end;
            until TempWhseActivLineToReserve.Next() = 0;
    end;

    local procedure CheckAndRemoveOrderToOrderBinding(var TempWhseActivLineToReserve: Record "Warehouse Activity Line" temporary)
    var
        SalesLine: Record "Sales Line";
        ReservationEntry: Record "Reservation Entry";
        ReservMgt: Codeunit "Reservation Management";
        ReservationEngineMgt: Codeunit "Reservation Engine Mgt.";
        IsConfirmed: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckAndRemoveOrderToOrderBinding(TempWhseActivLineToReserve, IsHandled);
        if IsHandled then
            exit;

        if TempWhseActivLineToReserve.FindSet() then
            repeat
                SalesLine.Get(
                  SalesLine."Document Type"::Order, TempWhseActivLineToReserve."Source No.", TempWhseActivLineToReserve."Source Line No.");
                ReservationEntry.SetSourceFilter(
                  DATABASE::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.", SalesLine."Line No.", true);
                ReservationEntry.SetFilter("Item Tracking", '<>%1', ReservationEntry."Item Tracking"::None);
                ReservationEntry.SetRange(Binding, ReservationEntry.Binding::"Order-to-Order");

                if ReservationEntry.FindSet() then
                    if not ReservMgt.ReservEntryPositiveTypeIsItemLedgerEntry(ReservationEntry."Entry No.") then begin
                        if not IsConfirmed and GuiAllowed then
                            if not Confirm(OrderToOrderBindingOnSalesLineQst) then
                                Error(RegisterInterruptedErr);
                        IsConfirmed := true;
                        repeat
                            ReservationEngineMgt.CancelReservation(ReservationEntry);
                            ReservMgt.SetReservSource(SalesLine);
                            ReservMgt.SetItemTrackingHandling(1);
                            ReservMgt.ClearSurplus();
                        until ReservationEntry.Next() = 0;
                    end;
            until TempWhseActivLineToReserve.Next() = 0;
    end;

    local procedure SyncItemTrackingAndReserveSourceDocument(var TempWhseActivLineToReserve: Record "Warehouse Activity Line" temporary)
    var
        TempReservEntryBeforeSync: Record "Reservation Entry" temporary;
        TempReservEntryAfterSync: Record "Reservation Entry" temporary;
    begin
        if not TempWhseActivLineToReserve.FindFirst() then begin
            SyncItemTracking();
            exit;
        end;

        case TempWhseActivLineToReserve."Source Document" of
            "Warehouse Activity Source Document"::"Sales Order":
                begin
                    CheckAndRemoveOrderToOrderBinding(TempWhseActivLineToReserve);
                    CollectReservEntries(TempReservEntryBeforeSync, TempWhseActivLineToReserve);
                    SyncItemTracking();
                    CollectReservEntries(TempReservEntryAfterSync, TempWhseActivLineToReserve);
                    AutoReserveForSalesLine(TempWhseActivLineToReserve, TempReservEntryBeforeSync, TempReservEntryAfterSync);
                end;
            "Warehouse Activity Source Document"::"Assembly Consumption":
                begin
                    CollectReservEntries(TempReservEntryBeforeSync, TempWhseActivLineToReserve);
                    SyncItemTracking();
                    CollectReservEntries(TempReservEntryAfterSync, TempWhseActivLineToReserve);
                    AutoReserveForAssemblyLine(TempWhseActivLineToReserve, TempReservEntryBeforeSync, TempReservEntryAfterSync);
                end;
        end;
    end;

    local procedure SyncItemTracking()
    begin
        ItemTrackingMgt.SetPick(GlobalWhseActivLine."Activity Type" = GlobalWhseActivLine."Activity Type"::Pick);
        ItemTrackingMgt.SynchronizeWhseItemTracking(TempTrackingSpecification, RegisteredWhseActivLine."No.", false);
    end;

    local procedure CollectReservEntries(var TempReservEntry: Record "Reservation Entry" temporary; var TempWhseActivLineToReserve: Record "Warehouse Activity Line" temporary)
    var
        ReservEntry: Record "Reservation Entry";
    begin
        with TempWhseActivLineToReserve do
            if FindSet() then
                repeat
                    ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);
                    ReservEntry.SetSourceFilter("Source Type", "Source Subtype", "Source No.", "Source Line No.", true);
                    if ReservEntry.FindSet() then
                        repeat
                            TempReservEntry := ReservEntry;
                            if TempReservEntry.Insert() then;
                        until ReservEntry.Next() = 0;
                until Next() = 0;
    end;

    local procedure CopyWhseActivityLineToReservBuf(var TempWhseActivLineToReserve: Record "Warehouse Activity Line" temporary; WhseActivLine: Record "Warehouse Activity Line")
    var
        IsHandled: Boolean;
        Item: Record Item;
    begin
        IsHandled := false;
        OnBeforeCopyWhseActivityLineToReservBuf(TempWhseActivLineToReserve, WhseActivLine, IsHandled);
        if IsHandled then
            exit;

        if IsPickPlaceForSalesOrderTrackedItem(WhseActivLine) or
           IsInvtMovementForAssemblyOrderTrackedItem(WhseActivLine)
        then begin

        // P80071300
        Item.Get(WhseActivLine."Item No.");
        if Item."Catch Alternate Qtys." then
            exit;
        // P80071300
            TempWhseActivLineToReserve.TransferFields(WhseActivLine);
            TempWhseActivLineToReserve.Insert();
        end;
    end;

    local procedure GroupWhseActivLinesByWhseDocAndSource(var TempWarehouseActivityLine: Record "Warehouse Activity Line" temporary; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
        with TempWarehouseActivityLine do begin
            SetRange("Whse. Document Type", WarehouseActivityLine."Whse. Document Type");
            SetRange("Whse. Document No.", WarehouseActivityLine."Whse. Document No.");
            SetRange("Whse. Document Line No.", WarehouseActivityLine."Whse. Document Line No.");
            SetRange("Source Document", WarehouseActivityLine."Source Document");
            SetSourceFilter(
              WarehouseActivityLine."Source Type", WarehouseActivityLine."Source Subtype", WarehouseActivityLine."Source No.",
              WarehouseActivityLine."Source Line No.", WarehouseActivityLine."Source Subline No.", false);
            SetRange("Action Type", WarehouseActivityLine."Action Type");
            SetRange("Original Breakbulk", WarehouseActivityLine."Original Breakbulk");
            SetRange("Breakbulk No.", WarehouseActivityLine."Breakbulk No.");
            if FindFirst() then begin
                "Qty. to Handle" += WarehouseActivityLine."Qty. to Handle";
                "Qty. to Handle (Base)" += WarehouseActivityLine."Qty. to Handle (Base)";
                OnGroupWhseActivLinesByWhseDocAndSourceOnBeforeTempWarehouseActivityLineModify(TempWarehouseActivityLine, WarehouseActivityLine);
                Modify();
            end else begin
                TempWarehouseActivityLine := WarehouseActivityLine;
                Insert();
            end;
        end;
    end;

    procedure ReleaseNonSpecificReservations(WhseActivLine: Record "Warehouse Activity Line"; WhseItemTrackingSetup: Record "Item Tracking Setup"; QtyToRelease: Decimal): Boolean
    var
        WhseActivityItemTrackingSetup: Record "Item Tracking Setup";
        LateBindingMgt: Codeunit "Late Binding Management";
        xReservedQty: Decimal;
    begin
        if QtyToRelease <= 0 then
            exit;

        CalcQtyReservedOnInventory(WhseActivLine, WhseItemTrackingSetup);

        if WhseItemTrackingSetup.TrackingRequired() then
            if Item."Reserved Qty. on Inventory" > 0 then begin
                xReservedQty := Item."Reserved Qty. on Inventory";
                WhseActivityItemTrackingSetup.CopyTrackingFromWhseActivityLine(WhseActivLine);
                LateBindingMgt.ReleaseForReservation(
                  WhseActivLine."Item No.", WhseActivLine."Variant Code", WhseActivLine."Location Code",
                  WhseActivityItemTrackingSetup, QtyToRelease);
                Item.CalcFields("Reserved Qty. on Inventory");
            end;

        exit(xReservedQty > Item."Reserved Qty. on Inventory");
    end;

    local procedure AutofillQtyToHandle(var WhseActivLine: Record "Warehouse Activity Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAutofillQtyToHandle(WhseActivLine, IsHandled);
        if not IsHandled then
            if not HideDialog then
                WhseActivLine.AutofillQtyToHandle(WhseActivLine);

        OnAfterAutofillQtyToHandle(WhseActivLine);
    end;

    local procedure AvailabilityError(WhseActivLine: Record "Warehouse Activity Line")
    begin
        if WhseActivLine."Serial No." <> '' then
            Error(InventoryNotAvailableErr, WhseActivLine.FieldCaption("Serial No."), WhseActivLine."Serial No.");
        if WhseActivLine."Lot No." <> '' then
            Error(InventoryNotAvailableErr, WhseActivLine.FieldCaption("Lot No."), WhseActivLine."Lot No.");

        OnAfterAvailabilityError(WhseActivLine);
    end;

    local procedure IsPickPlaceForSalesOrderTrackedItem(WhseActivityLine: Record "Warehouse Activity Line"): Boolean
    begin
        exit(
          (WhseActivityLine."Activity Type" = WhseActivityLine."Activity Type"::Pick) and
          (WhseActivityLine."Action Type" in [WhseActivityLine."Action Type"::Place, WhseActivityLine."Action Type"::" "]) and
          (WhseActivityLine."Source Document" = WhseActivityLine."Source Document"::"Sales Order") and
          (WhseActivityLine."Breakbulk No." = 0) and
          WhseActivityLine.TrackingExists());
    end;

    local procedure IsInvtMovementForAssemblyOrderTrackedItem(WhseActivityLine: Record "Warehouse Activity Line"): Boolean
    begin
        exit(
          (WhseActivityLine."Activity Type" = WhseActivityLine."Activity Type"::"Invt. Movement") and
          (WhseActivityLine."Action Type" in [WhseActivityLine."Action Type"::Place, WhseActivityLine."Action Type"::" "]) and
          (WhseActivityLine."Source Document" = WhseActivityLine."Source Document"::"Assembly Consumption") and
          (WhseActivityLine."Breakbulk No." = 0) and
          WhseActivityLine.TrackingExists());
    end;

    local procedure IsSalesLineCompletelyReserved(SalesLine: Record "Sales Line"): Boolean
    begin
        SalesLine.CalcFields("Reserved Quantity");
        exit(SalesLine.Quantity = SalesLine."Reserved Quantity");
    end;

    local procedure IsAssemblyLineCompletelyReserved(AssemblyLine: Record "Assembly Line"): Boolean
    begin
        AssemblyLine.CalcFields("Reserved Quantity");
        exit(AssemblyLine.Quantity = AssemblyLine."Reserved Quantity");
    end;

    procedure SetSuppressCommit(NewSuppressCommit: Boolean)
    begin
        SuppressCommit := NewSuppressCommit;
    end;

    local procedure MaintainZeroLines(WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
        WarehouseActivityLine.SetRange("Activity Type", WarehouseActivityLine."Activity Type");
        WarehouseActivityLine.SetRange("No.", WarehouseActivityLine."No.");
        WarehouseActivityLine.SetRange("Qty. to Handle", 0);
        if WarehouseActivityLine.FindSet() then
            repeat
                WarehouseActivityLine.ResetQtyToHandleOnReservation();
            until WarehouseActivityLine.Next() = 0;
    end;

    local procedure GetDeliveryTripNo(WhseActivLine: Record "Warehouse Activity Line"): Code[20]
    var
        WhsePutAwayRqst: Record "Whse. Put-away Request";
        WhsePickRqst: Record "Whse. Pick Request";
    begin
        // P8008361
        with WhseActivLine do begin
            if "Whse. Document Type" = "Whse. Document Type"::Shipment then
                if "Action Type" <> "Action Type"::Take then begin
                    WhseShptHeader.Get("Whse. Document No.");
                    exit(WhseShptHeader."Delivery Trip");
                end;
        end;
        // P8008361
    end;

    local procedure FixWhseShptLineTracking()
    var
        Process800Fns: Codeunit "Process 800 Functions";
        UpdateDocumentLine: Codeunit "Update Document Line";
    begin
        // P80046533
        if not Process800Fns.ContainerTrackingInstalled then
            exit;

        if TempWhseShptLine.FindSet then
            repeat
                UpdateDocumentLine.SetApplication(false, TempWhseShptLine."Source Type", TempWhseShptLine."Source Subtype", TempWhseShptLine."Source No.", TempWhseShptLine."Source Line No.");
                UpdateDocumentLine.SetShptLine(TempWhseShptLine); // P80077569
                UpdateDocumentLine.FixTracking;
            until TempWhseShptLine.Next = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCode(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckBlockedCustOnDocs(WarehouseActivityLine: Record "Warehouse Activity Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWhseActivLineDelete(var WarehouseActivityLine: Record "Warehouse Activity Line"; var SkipDelete: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssemblyLineModify(var AssemblyLine: Record "Assembly Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAvailabilityError(WhseActivLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindWhseActivLine(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterWhseShptLineModify(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateRegActivHeader(var WarehouseActivityHeader: Record "Warehouse Activity Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateRegActivLine(var WarehouseActivityLine: Record "Warehouse Activity Line"; var RegisteredWhseActivLine: Record "Registered Whse. Activity Line"; var RegisteredInvtMovementLine: Record "Registered Invt. Movement Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAutofillQtyToHandle(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAutofillQtyToHandle(var WarehouseActivityLine: Record "Warehouse Activity Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckLines(var WarehouseActivityHeader: Record "Warehouse Activity Header"; var WarehouseActivityLine: Record "Warehouse Activity Line"; var TempBinContentBuffer: Record "Bin Content Buffer")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckItemTrackingInfoBlocked(WhseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckWhseActivLine(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegWhseItemTrkgLine(var WhseActivLine2: Record "Warehouse Activity Line"; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsRegWhseItemTrkgLine(var WhseActivLine2: Record "Warehouse Activity Line"; var WhseItemTrkgLine: Record "Whse. Item Tracking Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostedWhseRcptLineModify(var PostedWhseReceiptLine: Record "Posted Whse. Receipt Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProdCompLineModify(var ProdOrderComponent: Record "Prod. Order Component")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegisterWhseActivity(var WarehouseActivityHeader: Record "Warehouse Activity Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegisterWhseActivityLines(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegisteredInvtMovementHdrInsert(var RegisteredInvtMovementHdr: Record "Registered Invt. Movement Hdr."; WarehouseActivityHeader: Record "Warehouse Activity Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegisteredInvtMovementLineInsert(var RegisteredInvtMovementLine: Record "Registered Invt. Movement Line"; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegisteredWhseActivHeaderInsert(var RegisteredWhseActivityHdr: Record "Registered Whse. Activity Hdr."; WarehouseActivityHeader: Record "Warehouse Activity Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegisteredWhseActivLineInsert(var RegisteredWhseActivityLine: Record "Registered Whse. Activity Line"; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterWhseInternalPickLineModify(var WhseInternalPickLine: Record "Whse. Internal Pick Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterWhseInternalPutAwayLineModify(var WhseInternalPutAwayLine: Record "Whse. Internal Put-away Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAutoReserveForSalesLineOnBeforeRunAutoReserve(var TempWhseActivLineToReserve: Record "Warehouse Activity Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAssemblyLineModify(var AssemblyLine: Record "Assembly Line"; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAutoReserveForSalesLine(var TempWhseActivLineToReserve: Record "Warehouse Activity Line" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAutoReserveForAssemblyLine(var TempWhseActivLineToReserve: Record "Warehouse Activity Line" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckBinRelatedFields(WarehouseActivityLine: Record "Warehouse Activity Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostedWhseRcptLineModify(var PostedWhseReceiptLine: Record "Posted Whse. Receipt Line"; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProdCompLineModify(var ProdOrderComponent: Record "Prod. Order Component"; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRegWhseItemTrkgLine(var WhseActivLine2: Record "Warehouse Activity Line"; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRegisteredInvtMovementHdrInsert(var RegisteredInvtMovementHdr: Record "Registered Invt. Movement Hdr."; WarehouseActivityHeader: Record "Warehouse Activity Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitTempTrackingSpecification(WarehouseActivityLine: Record "Warehouse Activity Line"; var QtyToRegisterBase: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRegisteredInvtMovementLineInsert(var RegisteredInvtMovementLine: Record "Registered Invt. Movement Line"; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRegisteredWhseActivHeaderInsert(var RegisteredWhseActivityHdr: Record "Registered Whse. Activity Hdr."; WarehouseActivityHeader: Record "Warehouse Activity Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRegisteredWhseActivLineInsert(var RegisteredWhseActivityLine: Record "Registered Whse. Activity Line"; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyWhseActivityLineToReservBuf(var TempWhseActivLineToReserve: Record "Warehouse Activity Line" temporary; WhseActivLine: Record "Warehouse Activity Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckQtyAvailToInsertBase(var TempWhseActivLine: Record "Warehouse Activity Line" temporary; var QtyAvailToInsertBase: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdWhseActivHeader(var WhseActivityHeader: Record "Warehouse Activity Header"; var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateWhseShptLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; QtyToHandle: Decimal; QtyToHandleBase: Decimal; QtyPerUOM: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWhseActivHeaderDelete(var WarehouseActivityHeader: Record "Warehouse Activity Header"; var SkipDelete: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRegActLine(var WarehouseActivityLine: Record "Warehouse Activity Line"; var RegisteredWhseActivityLine: Record "Registered Whse. Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRegInvtMovementLine(var WarehouseActivityLine: Record "Warehouse Activity Line"; var RegisteredInvtMovementLine: Record "Registered Invt. Movement Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateWhseDocHeader(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckLines(var WarehouseActivityHeader: Record "Warehouse Activity Header"; var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcQtyBasePicked(WhseActivLine: Record "Warehouse Activity Line"; WhseItemTrackingSetup: Record "Item Tracking Setup"; var QtyBasePicked: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckAndRemoveOrderToOrderBinding(var TempWhseActivLineToReserve: Record "Warehouse Activity Line" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckIncreaseBin(var TempBinContentBuffer: Record "Bin Content Buffer" temporary; var Bin: Record Bin; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckWhseItemTrkgLine(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCommit(var WarehouseActivityHeader: Record "Warehouse Activity Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateRegActivHeader(var WhseActivityHeader: Record "Warehouse Activity Header"; var IsHandled: Boolean; var RegisteredWhseActivityHdr: Record "Registered Whse. Activity Hdr."; var RegisteredInvtMovementHdr: Record "Registered Invt. Movement Hdr.")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsQtyAvailToPickNonSpecificReservation(var WarehouseActivityLine: Record "Warehouse Activity Line"; var QtyAvailToPick: Decimal; var QtyToRegister: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRegisterWhseJnlLine(WarehouseActivityLine: Record "Warehouse Activity Line"; RegisteredWhseActivityHdr: Record "Registered Whse. Activity Hdr."; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRegisterWhseActivityLines(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSourceLineQtyBase(var WarehouseActivityLine: Record "Warehouse Activity Line"; var QtyBase: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWhseActivLineModify(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWhseJnlRegisterLine(var WarehouseJournalLine: Record "Warehouse Journal Line"; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTempTrackingSpecificationInsert(var TempTrackingSpecification: Record "Tracking Specification" temporary; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateSourceDocForInvtMovement(var WarehouseActivityLine: Record "Warehouse Activity Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateWhseDocHeader(var WarehouseActivityLine: Record "Warehouse Activity Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateWhseSourceDocLine(var WarehouseActivityLine: Record "Warehouse Activity Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateWhseActivLineQtyOutstanding(var WarehouseActivityLine: Record "Warehouse Activity Line"; var QtyDiff: Decimal; var QtyBaseDiff: Decimal; HideDialog: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateWarehouseActivityLineQtyToHandle(var WarehouseActivityLine: Record "Warehouse Activity Line"; var QtyDiff: Decimal; var QtyBaseDiff: Decimal; HideDialog: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWhseInternalPickLineModify(var WhseInternalPickLine: Record "Whse. Internal Pick Line"; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWhseInternalPutAwayLineModify(var WhseInternalPutAwayLine: Record "Whse. Internal Put-away Line"; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcQtyPickedNotShippedOnAfterReservEntrySetFilters(var ReservEntry: Record "Reservation Entry"; WhseActivLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcTotalAvailQtyToPickOnAfterItemLedgEntryCalcSums(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcTotalAvailQtyToPickOnAfterCalcQtyInWhseBase(var WarehouseEntry: Record "Warehouse Entry"; var QtyInWhseBase: Decimal; LocationCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterCheckLines(var WhseActivHeader: Record "Warehouse Activity Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterCalcShouldDeleteOldLine(OldWarehouseActivityLine: Record "Warehouse Activity Line"; WarehouseActivityLine: Record "Warehouse Activity Line"; var ShouldDeleteOldLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertRegWhseItemTrkgLineOnAfterCopyFields(var WhseItemTrackingLine: Record "Whse. Item Tracking Line"; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetPointerOnAfterWhseDocTypeSetSource(WhseActivLine: Record "Warehouse Activity Line"; WhseDocType2: Option; var WhseItemTrkgLine: Record "Whse. Item Tracking Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateTempBinContentBufferOnBeforeInsert(var TempBinContentBuffer: Record "Bin Content Buffer" temporary; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateWhseShptLineOnAfterAssignQtyPicked(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; QtyPerUOM: Decimal; QtyToHandleBase: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWhseShptLineModify(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; WarehouseActivityLine: Record "Warehouse Activity Line"; WhseActivityLineGrouped: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitTempTrackingSpecificationOnBeforeTempTrackingSpecificationModify(var WhseItemTrackingLine: Record "Whse. Item Tracking Line"; WarehouseActivityLine: Record "Warehouse Activity Line"; var TrackingSpecificationtemporary: Record "Tracking Specification" temporary);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGroupWhseActivLinesByWhseDocAndSourceOnBeforeTempWarehouseActivityLineModify(var TempWarehouseActivityLine: Record "Warehouse Activity Line" temporary; WarehouseActivityLine: Record "Warehouse Activity Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegisterWhseItemTrkgLineOnBeforeCreateSpecification(var WhseActivLine2: Record "Warehouse Activity Line"; var DueDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegisterWhseItemTrkgLineOnAfterSetDueDate(WarehouseActivityLine: Record "Warehouse Activity Line"; var DueDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegisterWhseItemTrkgLineOnAfterCalcWhseItemTrkgSetupExists(WarehouseActivityLine2: Record "Warehouse Activity Line"; var ItemTrackingManagement: Codeunit "Item Tracking Management"; var WhseItemTrkgSetupExists: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeCommit(RegisteredWhseActivHeader: Record "Registered Whse. Activity Hdr."; RegisteredWhseActivLine: Record "Registered Whse. Activity Line"; var SuppressCommit: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckWhseActivLineIsEmpty(var WhseActivityLine: Record "Warehouse Activity Line"; var IsHandled: Boolean; var HideDialog: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckBinContentQtyToHandle(var TempBinContentBuffer: Record "Bin Content Buffer" temporary; var BinContent: Record "Bin Content"; Item: Record Item; var IsHandled: Boolean; BreakBulkQtyBaseToPlace: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateWhseSourceDocLine(var WhseActivityLine: Record "Warehouse Activity Line"; WhseDocType2: Option)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckBinContentOnAfterTempBinContentBufferLoop(var TempBinContentBuffer: Record "Bin Content Buffer"; var Bin: Record Bin)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckBinContentOnAfterGetWhseItemTrkgSetup(BinContent: Record "Bin Content"; var WhseItemTrackingSetup: Record "Item Tracking Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckLinesOnBeforeCommit(RegisteredWhseActivHeader: Record "Registered Whse. Activity Hdr."; RegisteredWhseActivityLine: Record "Registered Whse. Activity Line"; var SuppressCommit: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckWhseItemTrkgLineOnAfterClearFilters(var TempWhseActivLine: Record "Warehouse Activity Line" temporary; WhseActivLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckWhseItemTrkgLineOnAfterTempWhseActivLineFind(var TempWhseActivLine: Record "Warehouse Activity Line" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckWhseItemTrkgLineOnBeforeTestTracking(WarehouseActivityLine: Record "Warehouse Activity Line"; var WhseItemTrackingSetup: Record "Item Tracking Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckWhseItemTrkgLineOnBeforeCalcQtyToRegisterBase(var TempWarehouseActivityLine: Record "Warehouse Activity Line" temporary; WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckWhseItemTrkgLineOnAfterTempWhseActivLineSetFilters(var TempWhseActivLine: Record "Warehouse Activity Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckWhseItemTrkgLineOnAfterGetWhseItemTrkgSetup(TempWarehouseActivityLine: Record "Warehouse Activity Line" temporary; WhseItemTrackingSetup: Record "Item Tracking Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeTempWhseActivityLineGroupedLoop(var WhseActivHeader: Record "Warehouse Activity Header"; var WhseActivLine: Record "Warehouse Activity Line"; var RegisteredWhseActivHeader: Record "Registered Whse. Activity Hdr.")
    begin
    end;
}

