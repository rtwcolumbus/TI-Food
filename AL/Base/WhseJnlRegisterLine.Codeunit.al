codeunit 7301 "Whse. Jnl.-Register Line"
{
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Update Open flag on warehouse entries
    // 
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 08 AUG 06
    //   Change Open field handling with remaining qtys.
    // 
    // PR5.00
    // P8000495A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Combining of Lots
    // 
    // P8000591A, VerticalSoft, Don Bresee, 13 MAR 08
    //   Add logic for Alt. Qtys. to Whse. (Adjustment Bin)
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add 1-Doc Whse Logic
    // 
    // PRW16.00.01
    // P8000737, VerticalSoft, Jack Reynolds, 28 OCT 09
    //   Insure all entries to adjustment bins are in base units
    // 
    // PRW16.00.04
    // P8000888, VerticalSoft, Don Bresee, 13 DEC 10
    //   Use new codeunit in place of form for combining lots
    //   Add logic to handle registers
    // 
    // PRW16.00.05
    // P8000994, Columbus IT, Jack Reynolds, 04 NOV 11
    //   Set expiration date from existing lot info
    // 
    // PRW16.00.06
    // P8001037, Columbus IT, Jack Reynolds, 22 FEB 12
    //   fix problem leaving negative quantity in bin
    // 
    // P8001039, Columbus IT, Don Bresee, 26 FEB 12
    //   Add Rounding Adjustment logic for Warehouse
    // 
    // P8001088, Columbus IT, Don Bresee, 14 AUG 12
    //   Change assignment of "Fixed" field to FALSE for automatically created Bin Content records
    // 
    // P8001110, Columbus IT, Don Bresee, 01 NOV 12
    //   Skip Bin Content check when quantities are zero
    // 
    // P8001127, Columbus IT, Don Bresee, 15 JAN 13
    //   Add parameter to Rounding Management call
    // 
    // PRW17.10
    // P8001225, Columbus IT, Jack Reynolds, 30 SEP 13
    //   Record date/time or warehouse entries
    // 
    // PRW17.10.03
    // P8001342, Columbus IT, Dayakar Battini, 27 Aug 14
    //    Containers -Prevent negative inventory applied to loose quantity.
    // 
    // PRW19.00
    // P8005529, To-Increase, Jack Reynolds, 23 NOV 15
    //   Fix problem lot combinations and posting multiple output entries
    // 
    // PRW19.00.01
    // P8008293, To-Increase, Dayakar Battini, 09 FEB 17
    //   Fix loose inventory error with lot change status regarding whse movement.
    // 
    // P8008593, To-Increase, Dayakar Battini, 20 MAR 17
    //   Fix for setting loose inventory error on warehouse shipment when single item multiple lines.
    // 
    // PRW110.0.01
    // P80041995, To-Increase, Dayakar Battini, 24 JUN 17
    //   Fix for negative loose quantity
    // 
    // P80042658, To-Increase, Dayakar Battini, 29 JUN 17
    //   Fix for loose inventory
    // 
    // PRW110.0.02
    // P80051635, To-Increase, Dayakar Battini, 10 JAN 18
    //   Fix for error when removing container
    // 
    // P80051660, To-Increase, Dayakar Battini, 10 JAN 18
    //   Fix for error when removing container for partial quantity
    // 
    // P80051677, To-Increase, Jack Reynolds, 10 JAN 18
    //   Fix problem synchronizing warehouse register with Lot Combination codeunit
    // 
    // PRW111.00.01
    // P80060274, To-Increase, Dayakar Battini, 28 JUN 18
    //   Fix problem with check loose quantity
    // 
    // P80056709, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - assign container to production order
    // 
    // PRW111.00.02
    // P80067617, To Increase, Jack Reynolds, 20 NOV 18
    //   Fix problem checking for loose inventory
    // 
    // P80070796, To-Increase, Gangabhushan, 18 FEB 19
    //   TI-12875 - Alt. Qty issue in Container Line for CW items in Whse Jnls.
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Permissions = TableData "Warehouse Entry" = imd,
                  TableData "Warehouse Register" = imd;
    TableNo = "Warehouse Journal Line";

    trigger OnRun()
    begin
        RegisterWhseJnlLine(Rec);
    end;

    var
        Location: Record Location;
        WhseJnlLine: Record "Warehouse Journal Line";
        Item: Record Item;
        Bin: Record Bin;
        WhseReg: Record "Warehouse Register";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WMSMgt: Codeunit "WMS Management";
        WhseEntryNo: Integer;
        Text000: Label 'is not sufficient to complete this action. The quantity in the bin is %1', Comment = '%1 = the value of the Quantity that is in the bin; %2 = the value of the Quantity that is not available.';
        Text001: Label 'Serial No. %1 is found in inventory .';
        OnMovement: Boolean;
        CombineLotsEntryNo: Integer;
        CombineLots: Codeunit "Combine Whse. Lots";
        CombineLotsDisabled: Boolean;
        Text37002000: Label '%1 and %2 must have the same sign.';
        RoundingAdjmtMgmt: Codeunit "Rounding Adjustment Mgmt.";
        Text37002001: Label 'Insufficient quantity to complete this action. The base quantity in the bin is %1. %2 units are not available for %3 %4, %5 %6.';
        ContainerHeader: Record "Container Header";
        PostContainerLine: Record "Container Line";
        ProcessFns: Codeunit "Process 800 Functions";
        ContainerFns: Codeunit "Container Functions";
        FromContainerID: Code[20];
        Text37002003: Label 'Insufficient loose quantity to complete this action for item %1 bin %2.';

    local procedure "Code"()
    var
        GlobalWhseEntry: Record "Warehouse Entry";
    begin
        Clear(CombineLotsEntryNo); // P8000495A

        OnBeforeCode(WhseJnlLine);

        with WhseJnlLine do begin
            if ("Qty. (Absolute)" = 0) and ("Qty. (Base)" = 0) and // P8000591A
               ("Quantity (Alt.)" = 0) and (not "Phys. Inventory") // P8000591A
            then                                                   // P8000591A
                exit;
            TestField("Item No.");
            GetLocation("Location Code");
            if WhseEntryNo = 0 then begin
                GlobalWhseEntry.LockTable();
                WhseEntryNo := GlobalWhseEntry.GetLastEntryNo();
            end;

            OnCodeOnAfterGetLastEntryNo(WhseJnlLine);

            OnMovement := false;
            RoundingAdjmtMgmt.AdjustWhseMovementQtys(WhseJnlLine, true); // P8001039, P8001127
            if "From Bin Code" <> '' then begin
                OnCodeBeforeInitWhseEntryFromBinCode(WhseJnlLine, GlobalWhseEntry);
                InitWhseEntry(GlobalWhseEntry, "From Zone Code", "From Bin Code", -1);
                if "To Bin Code" <> '' then begin
                    InsertWhseEntry(GlobalWhseEntry);
                    OnMovement := true;
                    InitWhseEntry(GlobalWhseEntry, "To Zone Code", "To Bin Code", 1);
                end;
            end else
                InitWhseEntry(GlobalWhseEntry, "To Zone Code", "To Bin Code", 1);

            InsertWhseEntry(GlobalWhseEntry);
            AddToContainer(WhseJnlLine); // P8001323
            PostDirectedWhseAdjmts; // P8001039
        end;

        CombineMultipleLots; // P8000495A
        
        OnAfterCode(WhseJnlLine, WhseEntryNo);
    end;

    procedure LockTables()
    var
        WarehouseEntry: Record "Warehouse Entry";
    begin
        WarehouseEntry.Lock();
    end;

    procedure InitWhseEntry(var WhseEntry: Record "Warehouse Entry"; ZoneCode: Code[10]; BinCode: Code[20]; Sign: Integer)
    var
        ToBinContent: Record "Bin Content";
        WMSMgt: Codeunit "WMS Management";
        LotInfo: Record "Lot No. Information";
        IsHandled: Boolean;
    begin
        WhseEntryNo := WhseEntryNo + 1;

        // P8001323
        if WhseJnlLine.Quantity <> 0 then begin
            CheckContainerAssignment(WhseJnlLine."From Container ID");
            CheckContainerAssignment(WhseJnlLine."To Container ID");
        end;
        if Sign < 0 then
            RemoveFromContainer(WhseJnlLine);
        // P8001323

        WhseEntry.Init();
        WhseEntry."Entry No." := WhseEntryNo;
        WhseEntryNo := WhseEntry."Entry No.";
        WhseEntry."Journal Template Name" := WhseJnlLine."Journal Template Name";
        WhseEntry."Journal Batch Name" := WhseJnlLine."Journal Batch Name";
        if WhseJnlLine."Entry Type" <> WhseJnlLine."Entry Type"::Movement then begin
            if Sign >= 0 then
                WhseEntry."Entry Type" := WhseEntry."Entry Type"::"Positive Adjmt."
            else
                WhseEntry."Entry Type" := WhseEntry."Entry Type"::"Negative Adjmt.";
        end else
            WhseEntry."Entry Type" := WhseJnlLine."Entry Type";
        WhseEntry."Line No." := WhseJnlLine."Line No.";
        WhseEntry."Whse. Document No." := WhseJnlLine."Whse. Document No.";
        WhseEntry."Whse. Document Type" := WhseJnlLine."Whse. Document Type";
        WhseEntry."Whse. Document Line No." := WhseJnlLine."Whse. Document Line No.";
        WhseEntry."No. Series" := WhseJnlLine."Registering No. Series";
        WhseEntry."Location Code" := WhseJnlLine."Location Code";
        WhseEntry."Zone Code" := ZoneCode;
        WhseEntry."Bin Code" := BinCode;
        GetBin(WhseJnlLine."Location Code", BinCode);
        WhseEntry.Dedicated := Bin.Dedicated;
        WhseEntry."Bin Type Code" := Bin."Bin Type Code";
        WhseEntry."Item No." := WhseJnlLine."Item No.";
        WhseEntry.Description := GetItemDescription(WhseJnlLine."Item No.", WhseJnlLine.Description);
        if Location."Directed Put-away and Pick" then begin
            WhseEntry.Quantity := WhseJnlLine."Qty. (Absolute)" * Sign;
            WhseEntry."Unit of Measure Code" := WhseJnlLine."Unit of Measure Code";
            WhseEntry."Qty. per Unit of Measure" := WhseJnlLine."Qty. per Unit of Measure";
        end else begin
            WhseEntry.Quantity := WhseJnlLine."Qty. (Absolute, Base)" * Sign;
            WhseEntry."Unit of Measure Code" := WMSMgt.GetBaseUOM(WhseJnlLine."Item No.");
            WhseEntry."Qty. per Unit of Measure" := 1;
        end;
        WhseEntry."Qty. (Base)" := WhseJnlLine."Qty. (Absolute, Base)" * Sign;
        WhseEntry."Registering Date" := WhseJnlLine."Registering Date";
        WhseEntry."User ID" := WhseJnlLine."User ID";
        WhseEntry."Variant Code" := WhseJnlLine."Variant Code";
        WhseEntry."Source Type" := WhseJnlLine."Source Type";
        WhseEntry."Source Subtype" := WhseJnlLine."Source Subtype";
        WhseEntry."Source No." := WhseJnlLine."Source No.";
        WhseEntry."Source Line No." := WhseJnlLine."Source Line No.";
        WhseEntry."Source Subline No." := WhseJnlLine."Source Subline No.";
        WhseEntry."Source Document" := WhseJnlLine."Source Document";
        WhseEntry."Reference Document" := WhseJnlLine."Reference Document";
        WhseEntry."Reference No." := WhseJnlLine."Reference No.";
        WhseEntry."Source Code" := WhseJnlLine."Source Code";
        WhseEntry."Reason Code" := WhseJnlLine."Reason Code";
        WhseEntry.Cubage := WhseJnlLine.Cubage * Sign;
        WhseEntry.Weight := WhseJnlLine.Weight * Sign;
        WhseEntry.CopyTrackingFromWhseJnlLine(WhseJnlLine);
        // P8000994
        if LotInfo.Get(WhseJnlLine."Item No.", WhseJnlLine."Variant Code", WhseJnlLine."Lot No.") then
            WhseEntry."Expiration Date" := LotInfo."Expiration Date"
        else
        // P8000994
            WhseEntry."Expiration Date" := WhseJnlLine."Expiration Date";
        if OnMovement and (WhseJnlLine."Entry Type" = WhseJnlLine."Entry Type"::Movement) then begin
            WhseEntry.CopyTrackingFromNewWhseJnlLine(WhseJnlLine);
            // P8000994
            if LotInfo.Get(WhseJnlLine."Item No.", WhseJnlLine."Variant Code", WhseJnlLine."New Lot No.") then
                WhseEntry."Expiration Date" := LotInfo."Expiration Date"
            else
            // P8000994
                if (WhseJnlLine."New Expiration Date" <> WhseJnlLine."Expiration Date") and (WhseEntry."Entry Type" = WhseEntry."Entry Type"::Movement) then
                WhseEntry."Expiration Date" := WhseJnlLine."New Expiration Date";
        end;
        WhseEntry."Warranty Date" := WhseJnlLine."Warranty Date";
        WhseEntry."Phys Invt Counting Period Code" := WhseJnlLine."Phys Invt Counting Period Code";
        WhseEntry."Phys Invt Counting Period Type" := WhseJnlLine."Phys Invt Counting Period Type";

        IsHandled := false;
        OnInitWhseEntryCopyFromWhseJnlLine(WhseEntry, WhseJnlLine, OnMovement, Sign, Location, BinCode, IsHandled);
        // P8000737
        if WhseEntry."Bin Code" = Location."Adjustment Bin Code" then begin
            WhseEntry.Quantity := WhseEntry."Qty. (Base)";
            WhseEntry."Unit of Measure Code" := GetItemBaseUOM(WhseJnlLine."Item No.");
            WhseEntry."Qty. per Unit of Measure" := 1;
        end;
        // P8000737

        // P8000591A
        if Item.TrackAlternateUnits() and
           (WhseEntry."Bin Code" = Location."Adjustment Bin Code")
        then begin
            if (WhseJnlLine."Qty. (Base)" * WhseJnlLine."Quantity (Alt.)" < 0) then
                Error(Text37002000,
                      WhseJnlLine.FieldCaption("Qty. (Base)"), WhseJnlLine.FieldCaption("Quantity (Alt.)"));
            WhseEntry."Quantity (Alt.)" := WhseJnlLine."Quantity (Absolute, Alt.)" * Sign;
            if (WhseEntry.Quantity <> 0) and (WhseJnlLine."Source Document" <> WhseJnlLine."Source Document"::"Item Jnl.") then
                WhseEntry.TestField("Quantity (Alt.)");
        end;
        // P8000591A

        WhseJnlLine."From Container ID" := FromContainerID;  // P8008293
        if not IsHandled then

            if Sign > 0 then begin
                if BinCode <> Location."Adjustment Bin Code" then begin
                    if not ToBinContent.Get(
                        // WhseJnlLine."Location Code", BinCode, WhseJnlLine."Item No.", WhseJnlLine."Variant Code", WhseJnlLine."Unit of Measure Code") // P8001124
                        WhseJnlLine."Location Code", BinCode, WhseJnlLine."Item No.", WhseJnlLine."Variant Code", WhseEntry."Unit of Measure Code")      // P8001124
                    then
                        InsertToBinContent(WhseEntry)
                    else
                        if Location.Is1DocWhseBin(BinCode) then // P8000631A
                            if Location."Default Bin Selection" = Location."Default Bin Selection"::"Last-Used Bin" then
                                UpdateDefaultBinContent(WhseJnlLine."Item No.", WhseJnlLine."Variant Code", WhseJnlLine."Location Code", BinCode);
                    OnInitWhseEntryOnAfterGetToBinContent(WhseEntry, ItemTrackingMgt, WhseJnlLine, WhseReg, WhseEntryNo, Bin);
                end
            end else begin
                if BinCode <> Location."Adjustment Bin Code" then
                    if (WhseEntry.Quantity <> 0) or (WhseEntry."Qty. (Base)" <> 0) then // P8001110
                        DeleteFromBinContent(WhseEntry, WhseJnlLine."From Container ID"); // P8001342
            end;
    end;

    local procedure DeleteFromBinContent(var WhseEntry: Record "Warehouse Entry"; FromContainerID: Code[20])
    var
        FromBinContent: Record "Bin Content";
        WhseEntry2: Record "Warehouse Entry";
        WhseItemTrackingSetup: Record "Item Tracking Setup";
        Sign: Integer;
        IsHandled: Boolean;
        WhseEntry3: Record "Warehouse Entry";
        ContainerQty: Decimal;
        LooseQty: Decimal;
        LooseQtyBase: Decimal;
        LooseQtyAlt: Decimal;
    begin
        // P8000332A
        // P8001342 - add parameter for FromContainerID
        FromBinContent.Get(
            WhseEntry."Location Code", WhseEntry."Bin Code", WhseEntry."Item No.", WhseEntry."Variant Code",
            WhseEntry."Unit of Measure Code");
        WhseEntry2.SetCurrentKey(
            "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code");
        WhseEntry2.SetRange("Item No.", WhseEntry."Item No.");
        WhseEntry2.SetRange("Bin Code", WhseEntry."Bin Code");
        WhseEntry2.SetRange("Location Code", WhseEntry."Location Code");
        WhseEntry2.SetRange("Variant Code", WhseEntry."Variant Code");
        WhseEntry2.SetRange("Unit of Measure Code", WhseEntry."Unit of Measure Code");
        ItemTrackingMgt.GetWhseItemTrkgSetup(FromBinContent."Item No.", WhseItemTrackingSetup);
        WhseItemTrackingSetup.CopyTrackingFromWhseEntry(WhseEntry);
        WhseEntry2.SetTrackingFilterFromItemTrackingSetupIfRequired(WhseItemTrackingSetup);
        OnDeleteFromBinContentOnAfterSetFiltersForWhseEntry(WhseEntry2, FromBinContent, WhseEntry);
        WhseEntry2.CalcSums(Quantity, "Qty. (Base)");

        // P8001342
        WhseEntry3.Copy(WhseEntry2);  //P8008593
        ContainerQty := 0;
        if ProcessFns.ContainerTrackingInstalled and (FromContainerID = '') then begin
            // P80041995
            ContainerFns.LooseBinQuantity(WhseEntry."Item No.", WhseEntry."Variant Code", WhseEntry."Location Code", WhseEntry."Bin Code",
                WhseEntry."Unit of Measure Code", WhseEntry."Lot No.", WhseEntry."Serial No.", LooseQty, LooseQtyBase, LooseQtyAlt);

            ContainerFns.SetLooseQtyForWhseEntry(WhseEntry3);    //P8008593
            ContainerQty := ContainerFns.GetWhseEntryContainerQuantity(WhseEntry);

            if ContainerQty = 0 then begin
                if ((LooseQty + WhseEntry.Quantity + ContainerQty) < 0) or ((LooseQtyAlt <> 0) and ((LooseQtyAlt + WhseEntry."Quantity (Alt.)") < 0)) then  // P80042658
                    Error(Text37002003, WhseEntry."Item No.", WhseEntry."Bin Code");
            end else
                if ((LooseQty + WhseEntry.Quantity + ContainerQty) < 0) then
                    Error(Text37002003, WhseEntry."Item No.", WhseEntry."Bin Code");
            // P80041995
        end;
        // P8001342

        RoundingAdjmtMgmt.ProcessNewDirectedWhseEntry(WhseEntry, WhseEntry2);                        // P8001039
                                                                                                        // IF ((WhseEntry2.Quantity + Quantity) < 0) THEN                                           // P8001039
        if ((RoundingAdjmtMgmt.GetWhseAdustedQty(WhseEntry2) + (WhseEntry.Quantity + ContainerQty)) < 0) then // P8001039, P8001342
            FromBinContent.FieldError(
                Quantity, StrSubstNo(Text000, WhseEntry2.Quantity));

        // P8001347
        WhseEntry3.Copy(WhseEntry2);
        WhseEntry3.SetRange("Unit of Measure Code");
        WhseEntry3.CalcSums("Qty. (Base)");
        if ((WhseEntry3."Qty. (Base)" + WhseEntry."Qty. (Base)") < 0) then
            Error(Text37002001,
                WhseEntry3."Qty. (Base)", -(WhseEntry3."Qty. (Base)" + WhseEntry."Qty. (Base)"),
                WhseEntry.FieldCaption("Bin Code"), WhseEntry."Bin Code", WhseEntry.FieldCaption("Item No."), WhseEntry."Item No.");
        // P8001347

        if ((WhseEntry2.Quantity + WhseEntry.Quantity) = 0) then begin
            WhseEntry2.CalcSums(Cubage, Weight);
            WhseEntry.Cubage := -WhseEntry2.Cubage;
            WhseEntry.Weight := -WhseEntry2.Weight;

            if ((WhseEntry2."Qty. (Base)" + WhseEntry."Qty. (Base)") <> 0) then
                RegisterRoundResidual(WhseEntry, WhseEntry2);

            FromBinContent.SetRange("Lot No. Filter");
            FromBinContent.SetRange("Serial No. Filter");
            FromBinContent.CalcFields("Quantity (Base)");
            if FromBinContent."Quantity (Base)" + WhseEntry."Qty. (Base)" = 0 then
                if (FromBinContent."Positive Adjmt. Qty. (Base)" = 0) and
                    (FromBinContent."Put-away Quantity (Base)" = 0) and
                    (not FromBinContent.Fixed)
                then begin
                    OnDeleteFromBinContentOnBeforeFromBinContentDelete(FromBinContent);
                    FromBinContent.Delete();
                end;
        end;
        // P8000332A
        /*
        FromBinContent.Get(
            WhseEntry."Location Code", WhseEntry."Bin Code", WhseEntry."Item No.", WhseEntry."Variant Code",
            WhseEntry."Unit of Measure Code");
        ItemTrackingMgt.GetWhseItemTrkgSetup(FromBinContent."Item No.", WhseItemTrackingSetup);
        WhseItemTrackingSetup.CopyTrackingFromWhseEntry(WhseEntry);
        FromBinContent.SetTrackingFilterFromItemTrackingSetupIfRequired(WhseItemTrackingSetup);
        IsHandled := false;
        OnDeleteFromBinContentOnAfterSetFiltersForBinContent(FromBinContent, WhseEntry, WhseJnlLine, WhseReg, WhseEntryNo, IsHandled);
        if IsHandled then
            exit;
        FromBinContent.CalcFields("Quantity (Base)", "Positive Adjmt. Qty. (Base)", "Put-away Quantity (Base)");
        if FromBinContent."Quantity (Base)" + WhseEntry."Qty. (Base)" = 0 then begin
            WhseEntry2.SetCurrentKey(
                "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code");
            WhseEntry2.SetRange("Item No.", WhseEntry."Item No.");
            WhseEntry2.SetRange("Bin Code", WhseEntry."Bin Code");
            WhseEntry2.SetRange("Location Code", WhseEntry."Location Code");
            WhseEntry2.SetRange("Variant Code", WhseEntry."Variant Code");
            WhseEntry2.SetRange("Unit of Measure Code", WhseEntry."Unit of Measure Code");
            WhseEntry2.SetTrackingFilterFromItemTrackingSetupIfRequired(WhseItemTrackingSetup);
            OnDeleteFromBinContentOnAfterSetFiltersForWhseEntry(WhseEntry2, FromBinContent, WhseEntry);
            WhseEntry2.CalcSums(Cubage, Weight, "Qty. (Base)");
            WhseEntry.Cubage := -WhseEntry2.Cubage;
            WhseEntry.Weight := -WhseEntry2.Weight;
            if WhseEntry2."Qty. (Base)" + WhseEntry."Qty. (Base)" <> 0 then
                RegisterRoundResidual(WhseEntry, WhseEntry2);

            FromBinContent.ClearTrackingFilters();
            OnDeleteFromBinContentOnAfterClearTrackingFilters(WhseEntry2, FromBinContent, WhseEntry);
            FromBinContent.CalcFields("Quantity (Base)");
            if FromBinContent."Quantity (Base)" + WhseEntry."Qty. (Base)" = 0 then
                if (FromBinContent."Positive Adjmt. Qty. (Base)" = 0) and
                    (FromBinContent."Put-away Quantity (Base)" = 0) and
                    (not FromBinContent.Fixed)
                then begin
                    OnDeleteFromBinContentOnBeforeFromBinContentDelete(FromBinContent);
                    FromBinContent.Delete();
                end;
        end else begin
            OnDeleteFromBinContentOnBeforeCheckQuantity(FromBinContent, WhseEntry);
            FromBinContent.CalcFields(Quantity);
            if FromBinContent.Quantity + WhseEntry.Quantity = 0 then begin
                WhseEntry."Qty. (Base)" := -FromBinContent."Quantity (Base)";
                Sign := WhseJnlLine."Qty. (Base)" / WhseJnlLine."Qty. (Absolute, Base)";
                WhseJnlLine."Qty. (Base)" := WhseEntry."Qty. (Base)" * Sign;
                WhseJnlLine."Qty. (Absolute, Base)" := Abs(WhseEntry."Qty. (Base)");
                OnDeleteFromBinContenOnAfterQtyUpdate(FromBinContent, WhseEntry, WhseJnlLine, Sign);
            end else
                if FromBinContent."Quantity (Base)" + WhseEntry."Qty. (Base)" < 0 then begin
                    IsHandled := false;
                    OnDeleteFromBinContentOnBeforeFieldError(FromBinContent, WhseEntry, IsHandled);
                    if not IsHandled then
                        FromBinContent.FieldError(
                            "Quantity (Base)",
                            StrSubstNo(Text000, FromBinContent."Quantity (Base)", -(FromBinContent."Quantity (Base)" + WhseEntry."Qty. (Base)")));
                end;
        end;
    end;
        */
        // P8000332A

    end;

    local procedure RegisterRoundResidual(var WhseEntry: Record "Warehouse Entry"; WhseEntry2: Record "Warehouse Entry")
    var
        WhseJnlLine2: Record "Warehouse Journal Line";
        WhseJnlRegLine: Codeunit "Whse. Jnl.-Register Line";
    begin
        with WhseEntry do begin
            WhseJnlLine2 := WhseJnlLine;
            GetBin(WhseJnlLine2."Location Code", Location."Adjustment Bin Code");
            // WhseJnlLine2.Quantity := 0;                           // P8000332A
            WhseJnlLine2.Quantity := WhseEntry2.Quantity + Quantity; // P8000332A
            WhseJnlLine2."Qty. (Base)" := WhseEntry2."Qty. (Base)" + "Qty. (Base)";
            RegisterRoundResidualOnAfterGetBin(WhseJnlLine2, WhseEntry, WhseEntry2);
            // P8000332A
            // if WhseEntry2."Qty. (Base)" > Abs("Qty. (Base)") then begin
            if (WhseJnlLine2."Qty. (Base)" > 0) or (WhseJnlLine2.Quantity > 0) then begin
                // P8000332A
                WhseJnlLine2."To Zone Code" := Bin."Zone Code";
                WhseJnlLine2."To Bin Code" := Bin.Code;
            end else begin
                WhseJnlLine2."To Zone Code" := WhseJnlLine2."From Zone Code";
                WhseJnlLine2."To Bin Code" := WhseJnlLine2."From Bin Code";
                WhseJnlLine2."From Zone Code" := Bin."Zone Code";
                WhseJnlLine2."From Bin Code" := Bin.Code;
                WhseJnlLine2."Qty. (Base)" := -WhseJnlLine2."Qty. (Base)";
                WhseJnlLine2.Quantity := -WhseJnlLine2.Quantity; // P8000332A
            end;
            // WhseJnlLine2."Qty. (Absolute)" := 0;                       // P8000332A
            WhseJnlLine2."Qty. (Absolute)" := Abs(WhseJnlLine2.Quantity); // P8000332A
            WhseJnlLine2."Qty. (Absolute, Base)" := Abs(WhseJnlLine2."Qty. (Base)");
            WhseJnlRegLine.DisableCombineLots(CombineLotsDisabled); // P8000495A
            OnRegisterRoundResidualOnBeforeWhseJnlRegLineSetWhseRegister(WhseEntry, WhseEntry2, WhseJnlLine, WhseJnlLine2);
            WhseJnlRegLine.SetWhseRegister(WhseReg);
            WhseJnlRegLine.Run(WhseJnlLine2);
            WhseJnlRegLine.GetWhseRegister(WhseReg);
            WhseEntryNo := WhseReg."To Entry No." + 1;
            "Entry No." := WhseReg."To Entry No." + 1;
        end;
    end;

    local procedure InsertWhseEntry(var WhseEntry: Record "Warehouse Entry")
    var
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingSetup: Record "Item Tracking Setup";
        ExistingExpDate: Date;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInsertWhseEntryProcedure(WhseEntry, WhseJnlLine, IsHandled);
        if IsHandled then
            exit;

        with WhseEntry do begin
            GetItem("Item No.");
            if ItemTrackingCode.Get(Item."Item Tracking Code") then
                if ("Serial No." <> '') and
                   ("Bin Code" <> Location."Adjustment Bin Code") and
                   (Quantity > 0) and
                   ItemTrackingCode."SN Specific Tracking"
                then begin
                    IsHandled := false;
                    OnInsertWhseEntryOnBeforeCheckSerialNo(WhseEntry, IsHandled);
                    if not IsHandled then
                        if WMSMgt.SerialNoOnInventory("Location Code", "Item No.", "Variant Code", "Serial No.") then
                            Error(Text001, "Serial No.");
                end;

            if ItemTrackingCode."Man. Expir. Date Entry Reqd." and ("Entry Type" = "Entry Type"::"Positive Adjmt.") and
               ItemTrackingCode.IsWarehouseTracking()
            then begin
                TestField("Expiration Date");
                ItemTrackingSetup.CopyTrackingFromWhseEntry(WhseEntry);
                ItemTrackingMgt.GetWhseExpirationDate("Item No.", "Variant Code", Location, ItemTrackingSetup, ExistingExpDate);
                if (ExistingExpDate <> 0D) and ("Expiration Date" <> ExistingExpDate) then
                    TestField("Expiration Date", ExistingExpDate)
            end;

            ApplyWhseEntry(WhseEntry); // P8000282A

            GetBin("Location Code", "Bin Code"); // P8000332A

            WhseEntry."Registering Date/Time" := CurrentDateTime; // P8001225
            OnBeforeInsertWhseEntry(WhseEntry, WhseJnlLine);
            Insert();
            InsertWhseReg("Entry No.");
            UpdateBinEmpty(WhseEntry);
        end;

        OnAfterInsertWhseEntry(WhseEntry, WhseJnlLine);
    end;

    local procedure UpdateBinEmpty(NewWarehouseEntry: Record "Warehouse Entry")
    var
        WarehouseEntry: Record "Warehouse Entry";
        IsHandled: Boolean;
    begin
        OnBeforeUpdateBinEmpty(NewWarehouseEntry, Bin, IsHandled);
        if IsHandled then
            exit;

        with NewWarehouseEntry do
            if Quantity > 0 then begin
                ModifyBinEmpty(false);
                CombineLotsEntryNo := NewWarehouseEntry."Entry No."; // P8000495A
            end else begin
                WarehouseEntry.SetCurrentKey("Bin Code", "Location Code");
                WarehouseEntry.SetRange("Bin Code", "Bin Code");
                WarehouseEntry.SetRange("Location Code", "Location Code");
                WarehouseEntry.CalcSums("Qty. (Base)");
                ModifyBinEmpty(WarehouseEntry."Qty. (Base)" = 0);
            end;
    end;

    local procedure ModifyBinEmpty(NewEmpty: Boolean)
    begin
        OnBeforeModifyBinEmpty(Bin, NewEmpty);

        if Bin.Empty <> NewEmpty then begin
            Bin.Empty := NewEmpty;
            Bin.Modify();
        end;
    end;

    local procedure InsertToBinContent(WhseEntry: Record "Warehouse Entry")
    var
        BinContent: Record "Bin Content";
        WhseIntegrationMgt: Codeunit "Whse. Integration Management";
    begin
        OnBeforeInsertToBinContent(WhseEntry);
        with WhseEntry do begin
            GetBinForBinContent(WhseEntry);
            BinContent.Init();
            BinContent."Location Code" := "Location Code";
            BinContent."Zone Code" := "Zone Code";
            BinContent."Bin Code" := "Bin Code";
            BinContent.Dedicated := Bin.Dedicated;
            BinContent."Bin Type Code" := Bin."Bin Type Code";
            BinContent."Block Movement" := Bin."Block Movement";
            BinContent."Bin Ranking" := Bin."Bin Ranking";
            BinContent."Cross-Dock Bin" := Bin."Cross-Dock Bin";
            BinContent."Warehouse Class Code" := Bin."Warehouse Class Code";
            BinContent."Item No." := "Item No.";
            BinContent."Variant Code" := "Variant Code";
            BinContent."Unit of Measure Code" := "Unit of Measure Code";
            BinContent."Qty. per Unit of Measure" := "Qty. per Unit of Measure";
            BinContent.Fixed := WhseIntegrationMgt.IsOpenShopFloorBin("Location Code", "Bin Code");
            if not Location."Directed Put-away and Pick" then begin
                if Location.Is1DocWhseBin("Bin Code") then // P8000631A
                    CheckDefaultBin(WhseEntry, BinContent);
                // BinContent.Fixed := BinContent.Default; // P8001088
                BinContent.Fixed := false;   // P8001088
            end;
            OnBeforeBinContentInsert(BinContent, WhseEntry);
            BinContent.Insert();
        end;
    end;

    local procedure GetBinForBinContent(var WhseEntry: Record "Warehouse Entry")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetBinForBinContent(WhseEntry, IsHandled);
        if IsHandled then
            exit;

        GetBin(WhseEntry."Location Code", WhseEntry."Bin Code");
    end;

    local procedure CheckDefaultBin(WhseEntry: Record "Warehouse Entry"; var BinContent: Record "Bin Content")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckDefaultBin(WhseEntry, BinContent, IsHandled);
        if IsHandled then
            exit;

        with WhseEntry do
            if WMSMgt.CheckDefaultBin("Item No.", "Variant Code", "Location Code", "Bin Code") then begin
                if Location."Default Bin Selection" = Location."Default Bin Selection"::"Last-Used Bin" then begin
                    DeleteDefaultBinContent("Item No.", "Variant Code", "Location Code");
                    BinContent.Default := true;
                end
            end else
                BinContent.Default := true;
    end;

    procedure UpdateDefaultBinContent(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; BinCode: Code[20])
    var
        BinContent: Record "Bin Content";
        BinContent2: Record "Bin Content";
    begin
        BinContent.SetCurrentKey(Default);
        BinContent.SetRange(Default, true);
        BinContent.SetRange("Location Code", LocationCode);
        BinContent.SetRange("Item No.", ItemNo);
        BinContent.SetRange("Variant Code", VariantCode);
        if BinContent.FindFirst then
            if BinContent."Bin Code" <> BinCode then begin
                BinContent.Default := false;
                OnUpdateDefaultBinContentOnBeforeBinContentModify(BinContent);
                BinContent.Modify();
            end;

        if BinContent."Bin Code" <> BinCode then begin
            BinContent2.SetRange("Location Code", LocationCode);
            BinContent2.SetRange("Item No.", ItemNo);
            BinContent2.SetRange("Variant Code", VariantCode);
            BinContent2.SetRange("Bin Code", BinCode);
            BinContent2.FindFirst;
            BinContent2.Default := true;
            OnUpdateDefaultBinContentOnBeforeBinContent2Modify(BinContent2);
            BinContent2.Modify();
        end;
    end;

    local procedure DeleteDefaultBinContent(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10])
    var
        BinContent: Record "Bin Content";
    begin
        BinContent.SetCurrentKey(Default);
        BinContent.SetRange(Default, true);
        BinContent.SetRange("Location Code", LocationCode);
        BinContent.SetRange("Item No.", ItemNo);
        BinContent.SetRange("Variant Code", VariantCode);
        if BinContent.FindFirst then begin
            BinContent.Default := false;
            OnDeleteDefaultBinContentOnBeforeBinContentModify(BinContent);
            BinContent.Modify();
        end;
    end;

    local procedure InsertWhseReg(WhseEntryNo: Integer)
    begin
        with WhseJnlLine do
            if WhseReg."No." = 0 then begin
                WhseReg.LockTable();
                if WhseReg.Find('+') then
                    WhseReg."No." := WhseReg."No." + 1
                else
                    WhseReg."No." := 1;
                WhseReg.Init();
                WhseReg."From Entry No." := WhseEntryNo;
                WhseReg."To Entry No." := WhseEntryNo;
                WhseReg."Creation Date" := Today;
                WhseReg."Creation Time" := Time;
                WhseReg."Journal Batch Name" := "Journal Batch Name";
                WhseReg."Source Code" := "Source Code";
                WhseReg."User ID" := UserId;
                WhseReg.Insert();
            end else begin
                if ((WhseEntryNo < WhseReg."From Entry No.") and (WhseEntryNo <> 0)) or
                   ((WhseReg."From Entry No." = 0) and (WhseEntryNo > 0))
                then
                    WhseReg."From Entry No." := WhseEntryNo;
                if WhseEntryNo > WhseReg."To Entry No." then
                    WhseReg."To Entry No." := WhseEntryNo;
                WhseReg.Modify();
            end;
    end;

    local procedure GetBin(LocationCode: Code[10]; BinCode: Code[20])
    begin
        if (Bin."Location Code" <> LocationCode) or
           (Bin.Code <> BinCode)
        then
            Bin.Get(LocationCode, BinCode);
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if Location.Code <> LocationCode then
            Location.Get(LocationCode);
    end;

    local procedure GetItemDescription(ItemNo: Code[20]; Description2: Text[100]): Text[100]
    begin
        GetItem(ItemNo);
        if Item.Description = Description2 then
            exit('');
        exit(Description2);
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        if Item."No." <> ItemNo then
            Item.Get(ItemNo);
    end;

    procedure SetWhseRegister(WhseRegDef: Record "Warehouse Register")
    begin
        if (WhseRegDef."No." <> 0) then begin // P8000888
            WhseReg := WhseRegDef;
            WhseEntryNo := WhseReg."To Entry No."; // P8000322A
        end;                                  // P8000888
    end;

    procedure GetWhseRegister(var WhseRegDef: Record "Warehouse Register")
    begin
        WhseRegDef := WhseReg;
    end;

    procedure RegisterWhseJnlLine(var WarehouseJournalLine: Record "Warehouse Journal Line")
    begin
        WhseJnlLine.Copy(WarehouseJournalLine);
        Code;
        WarehouseJournalLine := WhseJnlLine;
    end;

    local procedure ApplyWhseEntry(var NewWhseEntry: Record "Warehouse Entry")
    var
        OldWhseEntry: Record "Warehouse Entry";
        OldWhseEntry2: Record "Warehouse Entry";
        QtyToApply: Decimal;
        QtyToApplyBase: Decimal;
        QtyToApplyAlt: Decimal;
    begin
        // P8000322A
        with NewWhseEntry do begin
            "Remaining Quantity" := Quantity;
            "Remaining Qty. (Base)" := "Qty. (Base)";
            "Remaining Qty. (Alt.)" := "Quantity (Alt.)"; // P8000591A
            Open := ("Remaining Quantity" <> 0) or ("Remaining Qty. (Base)" <> 0) or
                    ("Remaining Qty. (Alt.)" <> 0); // P8000591A
        end;
        with OldWhseEntry do begin
            SetCurrentKey(
              "Location Code", "Bin Code", "Item No.", "Variant Code",
              "Unit of Measure Code", Open, "Lot No.", "Serial No.");
            SetRange("Item No.", NewWhseEntry."Item No.");
            SetRange("Bin Code", NewWhseEntry."Bin Code");
            SetRange("Location Code", NewWhseEntry."Location Code");
            SetRange("Variant Code", NewWhseEntry."Variant Code");
            SetRange("Unit of Measure Code", NewWhseEntry."Unit of Measure Code");
            SetRange(Open, true);
            SetRange("Lot No.", NewWhseEntry."Lot No.");
            SetRange("Serial No.", NewWhseEntry."Serial No.");
            if (NewWhseEntry.Quantity > 0) or (NewWhseEntry."Qty. (Base)" > 0) or
               (NewWhseEntry."Quantity (Alt.)" > 0) // P8000591A
            then begin
                SetFilter(Quantity, '<=0');
                SetFilter("Qty. (Base)", '<=0');
            end else begin
                SetFilter(Quantity, '>=0');
                SetFilter("Qty. (Base)", '>=0');
            end;
            if Find('-') then
                repeat
                    if (Abs("Remaining Quantity") < Abs(NewWhseEntry."Remaining Quantity")) then
                        QtyToApply := -"Remaining Quantity"
                    else
                        QtyToApply := NewWhseEntry."Remaining Quantity";
                    if (Abs("Remaining Qty. (Base)") < Abs(NewWhseEntry."Remaining Qty. (Base)")) then
                        QtyToApplyBase := -"Remaining Qty. (Base)"
                    else
                        QtyToApplyBase := NewWhseEntry."Remaining Qty. (Base)";
                    // P8000591A
                    if (Abs("Remaining Qty. (Alt.)") < Abs(NewWhseEntry."Remaining Qty. (Alt.)")) then
                        QtyToApplyAlt := -"Remaining Qty. (Alt.)"
                    else
                        QtyToApplyAlt := NewWhseEntry."Remaining Qty. (Alt.)";
                    // P8000591A
                    if (QtyToApply <> 0) or (QtyToApplyBase <> 0) or (QtyToApplyAlt <> 0) then begin // P8000591A
                        OldWhseEntry2 := OldWhseEntry;
                        ApplyWhseEntryQty(OldWhseEntry2, QtyToApply, QtyToApplyBase, QtyToApplyAlt); // P8000591A
                        OldWhseEntry2.Modify;
                        ApplyWhseEntryQty(NewWhseEntry, -QtyToApply, -QtyToApplyBase, -QtyToApplyAlt); // P8000591A
                    end;
                until (not NewWhseEntry.Open) or (Next = 0);
        end;
        // P8000322A
    end;

    local procedure ApplyWhseEntryQty(var WhseEntry: Record "Warehouse Entry"; QtyToApply: Decimal; QtyToApplyBase: Decimal; QtyToApplyAlt: Decimal)
    begin
        // P8000322A
        with WhseEntry do begin
            "Remaining Quantity" := "Remaining Quantity" + QtyToApply;
            "Remaining Qty. (Base)" := "Remaining Qty. (Base)" + QtyToApplyBase;
            "Remaining Qty. (Alt.)" := "Remaining Qty. (Alt.)" + QtyToApplyAlt; // P8000591A
            Open := ("Remaining Quantity" <> 0) or ("Remaining Qty. (Base)" <> 0) or
                    ("Remaining Qty. (Alt.)" <> 0); // P8000591A
        end;
        // P8000322A
    end;

    local procedure CombineMultipleLots()
    var
        PosWhseEntry: Record "Warehouse Entry";
    begin
        // P8000495A
        if (not CombineLotsDisabled) and (CombineLotsEntryNo <> 0) then
            with PosWhseEntry do begin
                Get(CombineLotsEntryNo);
                if ("Lot No." <> '') then begin
                    GetItem("Item No.");
                    // P8000890
                    GetBin("Location Code", "Bin Code");
                    if Item.IsFixedBinSingleLotItem("Location Code", "Bin Code") or
                       (Bin."Lot Combination Method" <> Bin."Lot Combination Method"::Manual)
                    then begin
                        // P8000890
                        // P8000888 - Change CombineLotsForm (form) to CombineLots (codeunit)
                        CombineLots.SetWhseEntry(PosWhseEntry);
                        CombineLots.SetBin(Bin, PosWhseEntry); // P8000890
                        if CombineLots.IsCombineNeeded() then begin
                            CombineLots.SetPostingDate("Registering Date"); // P8000888
                            CombineLots.SetDocumentNo("Reference No.");
                            CombineLots.SetSourceCode("Source Code");
                            CombineLots.SetWhseRegister(WhseReg);
                            CombineLots.Register;
                            CombineLots.GetWhseRegister(WhseReg);
                            SetWhseRegister(WhseReg); // P8000888
                        end;
                        // P8000888
                    end;
                end;
            end;
    end;

    procedure DisableCombineLots(NewCombineLotsDisabled: Boolean)
    begin
        CombineLotsDisabled := NewCombineLotsDisabled; // P8000495A
    end;

    local procedure GetItemBaseUOM(ItemNo: Code[20]): Code[10]
    begin
        // P8000737
        GetItem(ItemNo);
        exit(Item."Base Unit of Measure");
    end;

    procedure GetRegisters(var ItemReg2: Record "Item Register"; var ItemApplnEntryNo2: Integer; var WhseReg2: Record "Warehouse Register"; var GLReg2: Record "G/L Register"; var NextVATEntryNo2: Integer; var NextTransactionNo2: Integer)
    begin
        // P8000888
        CombineLots.GetRegisters(
          ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
        GetWhseRegister(WhseReg2);
    end;

    procedure GetRegisters2(var ItemReg2: Record "Item Register"; var ItemApplnEntryNo2: Integer; var GLReg2: Record "G/L Register"; var NextVATEntryNo2: Integer; var NextTransactionNo2: Integer)
    var
        WhseReg2: Record "Warehouse Register";
    begin
        // P805529
        CombineLots.GetRegisters(
          ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2); // P80051677
    end;

    procedure SetRegisters(var ItemReg2: Record "Item Register"; ItemApplnEntryNo2: Integer; var WhseReg2: Record "Warehouse Register"; var GLReg2: Record "G/L Register"; NextVATEntryNo2: Integer; NextTransactionNo2: Integer)
    begin
        // P8000888
        CombineLots.SetRegisters(
          ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
        SetWhseRegister(WhseReg2);
    end;

    procedure SetRegisters2(var ItemReg2: Record "Item Register"; ItemApplnEntryNo2: Integer; var GLReg2: Record "G/L Register"; NextVATEntryNo2: Integer; NextTransactionNo2: Integer)
    begin
        // P805529
        CombineLots.SetRegisters(
          ItemReg2, ItemApplnEntryNo2, WhseReg, GLReg2, NextVATEntryNo2, NextTransactionNo2);
    end;

    local procedure PostDirectedWhseAdjmts()
    begin
        // P8001039
        RoundingAdjmtMgmt.PostDirectedWhseAdjmts(WhseReg);
        SetWhseRegister(WhseReg);
    end;

    procedure SetWhseRoundingAdjmts(var TempWhseJnlLine: Record "Warehouse Journal Line" temporary)
    begin
        RoundingAdjmtMgmt.SetWhseAdjmts(TempWhseJnlLine); // P8001039
    end;

    procedure ClearWhseRoundingAdjmts()
    begin
        RoundingAdjmtMgmt.ClearWhseAdjmts; // P8001039
    end;

    procedure GetLooseBinQty(var WhseEntry: Record "Warehouse Entry"): Decimal
    var
        Process800Fns: Codeunit "Process 800 Functions";
        ContainerFns: Codeunit "Container Functions";
        Qty: Decimal;
        QtyBase: Decimal;
        QtyAlt: Decimal;
    begin
        with WhseEntry do begin
            if Process800Fns.ContainerTrackingInstalled then
                ContainerFns.LooseBinQuantity("Item No.", "Variant Code", "Location Code", "Bin Code",
                                              "Unit of Measure Code", "Lot No.", "Serial No.", Qty, QtyBase, QtyAlt)
            else                                                                                              // P8001323
                Qty := WhseEntry.Quantity;                                                                      // P8001323
            exit(Qty);
        end;
    end;

    local procedure RemoveFromContainer(WhseJnlLine: Record "Warehouse Journal Line")
    var
        ContainerFunctions: Codeunit "Container Functions";
    begin
        // P8001323
        if WhseJnlLine."From Container ID" = '' then
            exit;

        if WhseJnlLine."Container Master Line No." <> 0 then begin
            ContainerHeader.Get(WhseJnlLine."From Container ID");
            if not ContainerHeader.Mark then begin
                ContainerHeader.TestField("Bin Code", WhseJnlLine."From Bin Code");

                if WhseJnlLine."From Bin Code" <> WhseJnlLine."To Bin Code" then begin
                    ContainerHeader.Mark(true);
                    ContainerHeader.Validate("Bin Code", WhseJnlLine."To Bin Code");
                    ContainerHeader.Modify;
                end;
            end;
            exit;
        end;

        PostContainerLine.SetUsageParms(WhseJnlLine."Registering Date", WhseJnlLine."Whse. Document No.", '', WhseJnlLine."Source Code");
        ContainerFunctions.RemoveFromContainer(WhseJnlLine."From Container ID", WhseJnlLine."Item No.", WhseJnlLine."Variant Code",
          WhseJnlLine."Unit of Measure Code", WhseJnlLine."Lot No.", WhseJnlLine."Serial No.", WhseJnlLine."Qty. (Absolute)", WhseJnlLine."Quantity (Absolute, Alt.)",
          PostContainerLine);
    end;

    local procedure AddToContainer(WhseJnlLine: Record "Warehouse Journal Line")
    var
        ContainerHeader: Record "Container Header";
        ContainerLine: Record "Container Line";
        ContainerLine2: Record "Container Line";
        QtyAlt: Decimal;
    begin
        // P8001323
        if (WhseJnlLine."To Container ID" = '') or (WhseJnlLine."Container Master Line No." <> 0) then
            exit;

        if WhseJnlLine."Phys. Inventory" then begin
            ContainerHeader.Get(WhseJnlLine."To Container ID");
            WhseJnlLine.TestField("Bin Code", ContainerHeader."Bin Code");
        end;

        GetItem(WhseJnlLine."Item No.");
        ContainerLine.Reset;
        ContainerLine.SetRange("Container ID", WhseJnlLine."To Container ID");
        ContainerLine.SetRange("Item No.", WhseJnlLine."Item No.");
        ContainerLine.SetRange("Variant Code", WhseJnlLine."Variant Code");
        ContainerLine.SetRange("Unit of Measure Code", WhseJnlLine."Unit of Measure Code");
        ContainerLine.SetRange("Lot No.", WhseJnlLine."Lot No.");
        ContainerLine.SetRange("Serial No.", WhseJnlLine."Serial No.");
        if ContainerLine.FindFirst then begin
            ContainerLine2 := ContainerLine;
            if (Item."Alternate Unit of Measure" <> '') and Item."Catch Alternate Qtys." then
                ContainerLine."Quantity (Alt.)" += WhseJnlLine."Quantity (Absolute, Alt.)";
            ContainerLine.Quantity += WhseJnlLine."Qty. (Absolute)";
            QtyAlt := ContainerLine."Quantity (Alt.)"; // P80070796
            ContainerLine.Validate(Quantity);
            ContainerLine.Validate("Quantity (Alt.)", QtyAlt); // P80070796
            ContainerLine.Modify;
        end else begin
            ContainerLine.Reset;
            ContainerLine.SetRange("Container ID", WhseJnlLine."To Container ID");
            if ContainerLine.FindLast then;
            ContainerLine."Line No." += 10000;
            ContainerLine.Init;
            ContainerLine."Container ID" := WhseJnlLine."To Container ID";
            ContainerLine.Validate("Item No.", WhseJnlLine."Item No.");
            ContainerLine.Validate("Variant Code", WhseJnlLine."Variant Code");
            ContainerLine.Validate("Unit of Measure Code", WhseJnlLine."Unit of Measure Code");
            ContainerLine.Validate("Lot No.", WhseJnlLine."Lot No.");
            ContainerLine.Validate("Serial No.", WhseJnlLine."Serial No.");
            ContainerLine.Validate(Quantity, WhseJnlLine."Qty. (Absolute)"); // P80070796
            if (Item."Alternate Unit of Measure" <> '') and Item."Catch Alternate Qtys." then
                ContainerLine."Quantity (Alt.)" := WhseJnlLine."Quantity (Absolute, Alt.)";
            ContainerLine.Validate("Quantity (Alt.)"); // P80070796
            ContainerLine.Insert;
        end;

        PostContainerUse(WhseJnlLine, ContainerLine, ContainerLine2.Quantity, ContainerLine2."Quantity (Alt.)");
    end;

    local procedure PostContainerUse(WhseJnlLine: Record "Warehouse Journal Line"; ContainerLine: Record "Container Line"; OriginalQty: Decimal; OriginalQtyAlt: Decimal)
    begin
        // P8001323
        PostContainerLine := ContainerLine;
        PostContainerLine.SetUsageParms(WhseJnlLine."Registering Date", WhseJnlLine."Whse. Document No.", '', WhseJnlLine."Source Code");
        PostContainerLine.PostContainerUse(OriginalQty, OriginalQtyAlt, ContainerLine.Quantity, ContainerLine."Quantity (Alt.)");
    end;

    local procedure CheckContainerAssignment(ContainerID: Code[20])
    begin
        // P8001323
        // P80056709 - renamed from CheckShippingContainer
        if ContainerID <> '' then
            ContainerFns.CheckContainerAssignment(ContainerID);
    end;

    procedure SetFromContainerID(ContainerID: Code[20])
    begin
        // P8008293
        FromContainerID := ContainerID;
    end;

    procedure SetWhseEntryNo(NewWhseEntryNo: Integer)
    begin
        WhseEntryNo := NewWhseEntryNo;
    end;

    procedure GetWhseEntryNo(): Integer
    begin
        exit(WhseEntryNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitWhseEntryCopyFromWhseJnlLine(var WarehouseEntry: Record "Warehouse Entry"; var WarehouseJournalLine: Record "Warehouse Journal Line"; OnMovement: Boolean; Sign: Integer; Location: Record Location; BinCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCode(var WarehouseJournalLine: Record "Warehouse Journal Line"; var WhseEntryNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertWhseEntry(var WarehouseEntry: Record "Warehouse Entry"; var WarehouseJournalLine: Record "Warehouse Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBinContentInsert(var BinContent: Record "Bin Content"; WarehouseEntry: Record "Warehouse Entry");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCode(var WarehouseJournalLine: Record "Warehouse Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetBinForBinContent(var WarehouseEntry: Record "Warehouse Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertWhseEntry(var WarehouseEntry: Record "Warehouse Entry"; var WarehouseJournalLine: Record "Warehouse Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertWhseEntryProcedure(var WarehouseEntry: Record "Warehouse Entry"; WarehouseJournalLine: Record "Warehouse Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertToBinContent(var WarehouseEntry: Record "Warehouse Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateBinEmpty(WarehouseEntry: Record "Warehouse Entry"; var Bin: Record Bin; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterGetLastEntryNo(var WhseJnlLine: Record "Warehouse Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeBeforeInitWhseEntryFromBinCode(WarehouseJournalLine: Record "Warehouse Journal Line"; WarehouseEntry: Record "Warehouse Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteDefaultBinContentOnBeforeBinContentModify(var BinContent: Record "Bin Content")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteFromBinContentOnAfterSetFiltersForWhseEntry(var WarehouseEntry2: Record "Warehouse Entry"; var BinContent: Record "Bin Content"; var WarehouseEntry: Record "Warehouse Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteFromBinContentOnAfterSetFiltersForBinContent(var BinContent: Record "Bin Content"; WarehouseEntry: Record "Warehouse Entry"; var WhseJnlLine: Record "Warehouse Journal Line"; var WhseReg: Record "Warehouse Register"; var WhseEntryNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteFromBinContentOnBeforeFieldError(BinContent: Record "Bin Content"; WarehouseEntry: Record "Warehouse Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteFromBinContentOnBeforeFromBinContentDelete(var BinContent: Record "Bin Content")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteFromBinContentOnBeforeCheckQuantity(var BinContent: Record "Bin Content"; WarehouseEntry: Record "Warehouse Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitWhseEntryOnAfterGetToBinContent(var WhseEntry: Record "Warehouse Entry"; var ItemTrackingMgt: Codeunit "Item Tracking Management"; var WhseJnlLine: Record "Warehouse Journal Line"; var WhseReg: Record "Warehouse Register"; var WhseEntryNo: Integer; var Bin: Record Bin)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertWhseEntryOnBeforeCheckSerialNo(WarehouseEntry: Record "Warehouse Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateDefaultBinContentOnBeforeBinContentModify(var BinContent: Record "Bin Content")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateDefaultBinContentOnBeforeBinContent2Modify(var BinContent: Record "Bin Content")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure RegisterRoundResidualOnAfterGetBin(var WhseJnlLine2: Record "Warehouse Journal Line"; WhseEntry: Record "Warehouse Entry"; WhseEntry2: Record "Warehouse Entry");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteFromBinContenOnAfterQtyUpdate(var FromBinContent: Record "Bin Content"; var WhseEntry: Record "Warehouse Entry"; var WhseJnlLine: Record "Warehouse Journal Line"; Sign: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyBinEmpty(var Bin: Record Bin; NewEmpty: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDefaultBin(WhseEntry: Record "Warehouse Entry"; var BinContent: Record "Bin Content"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegisterRoundResidualOnBeforeWhseJnlRegLineSetWhseRegister(var WhseEntry: Record "Warehouse Entry"; WhseEntry2: Record "Warehouse Entry"; WhseJnlLine: Record "Warehouse Journal Line"; WhseJnlLine2: Record "Warehouse Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDeleteFromBinContentOnAfterClearTrackingFilters(VAR WarehouseEntry2: Record "Warehouse Entry"; var FromBinContent: Record "Bin Content"; WarehouseEntry: Record "Warehouse Entry")
    begin
    end;
}

