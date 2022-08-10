codeunit 37002761 "Process 800 Create Whse. Act."
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 18 AUG 06
    //   Functions to create picks, put-aways, and register movements, adjustments
    //   Staged Picks
    //   Sales Samples
    // 
    // PR5.00
    // P8000494A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Production Bins/Replenishment
    // 
    // P8000495A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Combining of Lots
    // 
    // P8000591A, VerticalSoft, Don Bresee, 02 APR 08
    //   Add Alt. Qtys. for Adjustments
    // 
    // PRW15.00.03
    // P8000631A, VerticalSoft, Don Bresee, 12 JAN 09
    //   Add "Bin Code" to containers
    // 
    // PRW16.00.02
    // P8000740, VerticalSoft, Don Bresee, 18 NOV 09
    //   Add logic to handle 1-Doc (no adjustment bin), and fixed weight items
    // 
    // PRW16.00.04
    // P8000888, VerticalSoft, Don Bresee, 14 DEC 10
    //   Add logic to handle registers
    // 
    // P8000895, VerticalSoft, Jack Reynolds, 18 JAN 11
    //   Fix problem reqistering warehouse entreis without lot numbers
    // 
    // PRW16.00.05
    // P8000974, Columbus IT, Jack Reynolds, 07 SEP 11
    //   Fix problem registering UOM Conversions
    // 
    // PRW16.00.06
    // P8001039, Columbus IT, Don Bresee, 06 MAR 12
    //   Add Rounding Adjustment logic for Warehouse
    //   Change Posting/Register order - posting to item ledger should occur before whse entries creation
    // 
    // P8001056, Columbus IT, Don Bresee, 11 APR 12
    //   Move logic to swap to and from bins (needed due to change in posting order)
    // 
    // P8001082, Columbus IT, Rick Tweedle, 03 AUG 12
    //   Added code to allow setting of Source Doc fields (used in Pre-Processing)
    // 
    // PRW17.00
    // P8001134, Columbus IT, Don Bresee, 16 FEB 13
    //   Add logic for handling of new "Order Type" options
    // 
    // P8001142, Columbus IT, Don Bresee, 09 MAR 13
    //   Rework Replenishment logic
    // 
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10.02
    // P8001301, Columbus IT, Jack Reynolds, 03 MAR 14
    //   Update Rollup 4 - Change call to CreatePick.CreateWhseDocument
    // 
    // PRW17.10.03
    // P8001336, Columbus IT, Jack Reynolds, 25 JUL 14
    //   Fix problem with bin status lot combination
    // 
    // PRW19.00.01
    // P8007466, To Increase, Jack Reynolds, 20 JUL 16
    //   Fix problem registering lot combinations
    // 
    // PRW110.0.02
    // P80045166, To-Increase, Dayakar Battini, 28 JUL 17
    //   Fix issue with multiple lots by passing the correct CU variable
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 02 APR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80057829, To-Increase, Dayakar Battini, 27 APR 18
    //   Provide Container handling for non blending pre-process activities
    // 
    // P80056710, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - create production container from pick
    // 
    // P80060684, To-Increase, Jack Reynolds, 08 AUG 18
    //   Combined Lot Expiration Date
    // 
    // PRW111.00.03
    // P80079197, To-Increase, Gangabhushan, 18 JUL 19
    //   TI-13290-Request for New Events
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW11300.03
    // P80082969, To Increase, Jack Reynolds, 26 SEP 19
    //   New Events
    //
    //   PRW11400.01
    //   P80092182, To Increase, Jack Reynolds, 22 JAV 20
    //     New Events
    //
    // PRW118.01
    // P80094516, To Increase, Jack Reynolds, 24 SEP 21
    //   Use AutoIncrement property


    trigger OnRun()
    begin
    end;

    var
        Location: Record Location;
        FromBin: Record Bin;
        ToBin: Record Bin;
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        LotNoInfo: Record "Lot No. Information";
        SerialNoInfo: Record "Serial No. Information";
        RegisterMode: Option Movement,Adjustment,"UOM Conversion","Inventory Adjustment";
        SourceCode: Code[10];
        AssignedUserID: Code[20];
        RegisterDate: Date;
        WhseReg: Record "Warehouse Register";
        WhseJnlRegisterLine: Codeunit "Whse. Jnl.-Register Line";
        TempSpecification: Record "Warehouse Journal Line" temporary;
        TempSpecEntryNo: Integer;
        HiddenPutAway: Record "Whse. Internal Put-away Header";
        HiddenPick: Record "Whse. Internal Pick Header";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        CreatePickParameters: Record "Create Pick Parameters";
        CreatePick: Codeunit "Create Pick";
        MarkedWhseShptLine: Record "Warehouse Shipment Line";
        TempStagedPickSourceLine: Record "Whse. Staged Pick Source Line" temporary;
        WhseStagedPickMgmt: Codeunit "Whse. Staged Pick Mgmt.";
        SalesSampleStaging: Boolean;
        Text000: Label 'Nothing to Move.';
        Text001: Label 'Nothing to Put-Away.';
        Text002: Label 'All Put-Away source bins must be at the same location.';
        Text003: Label 'Unable to create Put-Away.';
        Text004: Label 'Nothing to Pick.';
        Text005: Label 'All Pick destination bins must be at the same location.';
        Text006: Label 'Unable to create Pick.';
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        ItemPosting: Boolean;
        ItemPostingDocNo: Code[20];
        CombineLotsDisabled: Boolean;
        AdjmtAltQty: Decimal;
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        RoundingAdjmtMgmt: Codeunit "Rounding Adjustment Mgmt.";
        AdditionalInfo: Record "Warehouse Journal Line";
        WhseMgmt: Codeunit "Whse. Management";
        AdditionalOrderInfo: Record "Item Journal Line";
        Text007: Label 'Unable to register the container.';
        MoveContainer: Boolean;

    procedure RegisterMove(LocationCode: Code[10]; FromBinCode: Code[20]; ToBinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; LotNo: Code[50]; SerialNo: Code[50]; Qty: Decimal)
    begin
        CheckParameters(
          LocationCode, FromBinCode, ToBinCode, true,
          ItemNo, VariantCode, UnitOfMeasureCode, LotNo, SerialNo);
        RegisterWhseJnlLine(RegisterMode::Movement, Qty, CalcBaseQty(Qty));
    end;

    procedure RegisterMoveBase(LocationCode: Code[10]; FromBinCode: Code[20]; ToBinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; LotNo: Code[50]; SerialNo: Code[50]; Qty: Decimal; QtyBase: Decimal)
    begin
        CheckParameters(
          LocationCode, FromBinCode, ToBinCode, true,
          ItemNo, VariantCode, UnitOfMeasureCode, LotNo, SerialNo);
        RegisterWhseJnlLine(RegisterMode::Movement, Qty, QtyBase);
    end;

    procedure RegisterAdjmt(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; LotNo: Code[50]; SerialNo: Code[50]; Qty: Decimal)
    begin
        CheckParameters(
          LocationCode, BinCode, '', false,
          ItemNo, VariantCode, UnitOfMeasureCode, LotNo, SerialNo);
        SwapBinsOnPosAdjmt(Qty); // P8001056
        PostItemAdjustment(Qty, CalcBaseQty(Qty));
        // P8000740
        if Location."Directed Put-away and Pick" then
            RegisterWhseJnlLine(RegisterMode::Adjustment, Qty, CalcBaseQty(Qty))
        else
            if not ItemPosting then
                RegisterWhseJnlLine(RegisterMode::"Inventory Adjustment", Qty, CalcBaseQty(Qty));
        // P8000740
    end;

    procedure RegisterAdjmtBase(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; LotNo: Code[50]; SerialNo: Code[50]; Qty: Decimal; QtyBase: Decimal)
    begin
        CheckParameters(
          LocationCode, BinCode, '', false,
          ItemNo, VariantCode, UnitOfMeasureCode, LotNo, SerialNo);
        SwapBinsOnPosAdjmt(QtyBase); // P8001056
        PostItemAdjustment(Qty, QtyBase);
        // P8000740
        if Location."Directed Put-away and Pick" then begin // P8001336
            if (AdditionalOrderInfo."Order Type" = AdditionalOrderInfo."Order Type"::FOODLotCombination) and (QtyBase > 0) then // P8001336
                ToBin.Get(LocationCode, BinCode);                                                                                 // P8001336
            RegisterWhseJnlLine(RegisterMode::Adjustment, Qty, QtyBase)
        end else
            if not ItemPosting then // P8001336
                RegisterWhseJnlLine(RegisterMode::"Inventory Adjustment", Qty, QtyBase);
        // P8000740
    end;

    procedure PostAdjmtBase(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50]; SerialNo: Code[50]; QtyBase: Decimal)
    var
        OldItemPosting: Boolean;
    begin
        OldItemPosting := ItemPosting;
        ItemPosting := true;
        CheckParameters(
          LocationCode, '', '', false,
          ItemNo, VariantCode, '', LotNo, SerialNo);
        PostItemAdjustment(QtyBase, QtyBase);
        ItemPosting := OldItemPosting;
    end;

    procedure RegisterUOMConversion(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; FromUnitOfMeasureCode: Code[10]; ToUnitOfMeasureCode: Code[10]; LotNo: Code[50]; SerialNo: Code[50]; FromQty: Decimal)
    var
        FromQtyBase: Decimal;
        ToQty: Decimal;
        ToQtyBase: Decimal;
    begin
        CalcConversionQtys(
          ItemNo, FromQty, FromUnitOfMeasureCode, ToUnitOfMeasureCode,
          true, FromQtyBase, ToQty, ToQtyBase);
        if (ToQty = 0) then
            RegisterAdjmtBase(
              LocationCode, BinCode, ItemNo, VariantCode,
              FromUnitOfMeasureCode, LotNo, SerialNo,
              -FromQty, -FromQtyBase)
        else begin
            CheckParameters(
              LocationCode, BinCode, '', false,
              ItemNo, VariantCode, FromUnitOfMeasureCode, LotNo, SerialNo);
            RegisterWhseJnlLine(RegisterMode::"UOM Conversion", FromQty, FromQtyBase);
            CheckParameters(
              LocationCode, '', BinCode, false,
              ItemNo, VariantCode, ToUnitOfMeasureCode, LotNo, SerialNo);
            RegisterWhseJnlLine(RegisterMode::"UOM Conversion", ToQty, ToQtyBase);
        end;
    end;

    local procedure CalcConversionQtys(ItemNo: Code[20]; FromQty: Decimal; FromUnitOfMeasureCode: Code[10]; ToUnitOfMeasureCode: Code[10]; CalculateToQty: Boolean; var FromQtyBase: Decimal; var ToQty: Decimal; var ToQtyBase: Decimal)
    var
        FromUOM: Record "Item Unit of Measure";
        ToUOM: Record "Item Unit of Measure";
    begin
        FromUOM.Get(ItemNo, FromUnitOfMeasureCode);
        FromQtyBase :=
          Round(FromQty * FromUOM."Qty. per Unit of Measure", 0.00001);
        ToUOM.Get(ItemNo, ToUnitOfMeasureCode);
        if CalculateToQty then
            ToQty :=
              Round(FromQty * FromUOM."Qty. per Unit of Measure" / ToUOM."Qty. per Unit of Measure", 0.00001);
        ToQtyBase := Round(ToQty * ToUOM."Qty. per Unit of Measure", 0.00001);
    end;

    procedure RegisterUOMConversion2(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; FromUnitOfMeasureCode: Code[10]; ToUnitOfMeasureCode: Code[10]; LotNo: Code[50]; SerialNo: Code[50]; FromQty: Decimal; ToQty: Decimal)
    var
        FromQtyBase: Decimal;
        ToQtyBase: Decimal;
    begin
        CalcConversionQtys(
          ItemNo, FromQty, FromUnitOfMeasureCode, ToUnitOfMeasureCode,
          false, FromQtyBase, ToQty, ToQtyBase);
        if (ToQty = 0) then
            RegisterAdjmtBase(
              LocationCode, BinCode, ItemNo, VariantCode,
              FromUnitOfMeasureCode, LotNo, SerialNo,
              -FromQty, -FromQtyBase)
        else begin
            CheckParameters(
              LocationCode, BinCode, '', false,
              ItemNo, VariantCode, FromUnitOfMeasureCode, LotNo, SerialNo);
            RegisterWhseJnlLine(RegisterMode::"UOM Conversion", FromQty, FromQtyBase);
            CheckParameters(
              LocationCode, '', BinCode, false,
              ItemNo, VariantCode, ToUnitOfMeasureCode, LotNo, SerialNo);
            RegisterWhseJnlLine(RegisterMode::"UOM Conversion", ToQty, ToQtyBase);
        end;
    end;

    local procedure CheckParameters(LocationCode: Code[10]; FromBinCode: Code[20]; ToBinCode: Code[20]; RequireFromAndToBins: Boolean; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; LotNo: Code[50]; SerialNo: Code[50])
    begin
        Location.Get(LocationCode);
        if RequireFromAndToBins then begin
            FromBin.Get(LocationCode, FromBinCode);
            ToBin.Get(LocationCode, ToBinCode);
        end else begin
            Clear(FromBin);
            if (FromBinCode <> '') or ((ToBinCode = '') and (not ItemPosting)) then
                FromBin.Get(LocationCode, FromBinCode);
            Clear(ToBin);
            if (ToBinCode <> '') then
                ToBin.Get(LocationCode, ToBinCode);
        end;
        Item.Get(ItemNo);
        Clear(ItemVariant);
        if (VariantCode <> '') then
            ItemVariant.Get(ItemNo, VariantCode);
        if (UnitOfMeasureCode <> '') then
            ItemUnitOfMeasure.Get(ItemNo, UnitOfMeasureCode)
        else
            ItemUnitOfMeasure.Get(ItemNo, Item."Base Unit of Measure");
        Clear(LotNoInfo);
        if (LotNo <> '') then
            if not LotNoInfo.Get(ItemNo, VariantCode, LotNo) then begin
                LotNoInfo."Item No." := ItemNo;
                LotNoInfo."Variant Code" := VariantCode;
                LotNoInfo."Lot No." := LotNo;
            end;
        Clear(SerialNoInfo);
        if (SerialNo <> '') then begin
            if not SerialNoInfo.Get(ItemNo, VariantCode, SerialNo) then begin
                SerialNoInfo."Item No." := ItemNo;
                SerialNoInfo."Variant Code" := VariantCode;
                SerialNoInfo."Serial No." := SerialNo;
            end;
            ItemUnitOfMeasure.TestField("Qty. per Unit of Measure", 1);
        end;
    end;

    local procedure CalcBaseQty(Qty: Decimal): Decimal
    begin
        ItemUnitOfMeasure.TestField("Qty. per Unit of Measure");
        exit(Round(Qty * ItemUnitOfMeasure."Qty. per Unit of Measure", 0.00001));
    end;

    local procedure RegisterWhseJnlLine(Mode: Integer; Qty: Decimal; QtyBase: Decimal)
    var
        WhseJnlLine: Record "Warehouse Journal Line";
        WMSMgmt: Codeunit "WMS Management";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        WhseSNRequired: Boolean;
        WhseLNRequired: Boolean;
        SkipWhseJnlLineCheck: Boolean;
        ContainerHeader: Record "Container Header";
    begin
        WhseJnlLine.Init;
        WhseJnlLine."Location Code" := Location.Code;
        if (RegisterDate <> 0D) then
            WhseJnlLine."Registering Date" := RegisterDate
        else
            WhseJnlLine."Registering Date" := WorkDate;
        WhseJnlLine."User ID" := UserId;
        case Mode of
            RegisterMode::Movement:
                WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::Movement;
            RegisterMode::Adjustment:
                begin
                    Location.TestField("Adjustment Bin Code");
                    if (Qty < 0) or (QtyBase < 0) then begin
                        ToBin.Get(Location.Code, Location."Adjustment Bin Code");
                        WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::"Negative Adjmt.";
                    end else begin
                        // ToBin := FromBin; // P8001056
                        FromBin.Get(Location.Code, Location."Adjustment Bin Code");
                        WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::"Positive Adjmt.";
                    end;
                    SkipWhseJnlLineCheck := AdditionalOrderInfo."Order Type" = AdditionalOrderInfo."Order Type"::FOODLotCombination; // P8007466
                end;
            RegisterMode::"UOM Conversion":
                begin                           // P8000974
                    WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::Movement;
                    SkipWhseJnlLineCheck := true; // P8000974
                end;                            // P8000974
            RegisterMode::"Inventory Adjustment":
                begin
                    if (Qty < 0) or (QtyBase < 0) then
                        WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::"Negative Adjmt."
                    else begin
                        // ToBin := FromBin; // P8001056
                        Clear(FromBin);
                        WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::"Positive Adjmt.";
                    end;
                    SkipWhseJnlLineCheck := AdditionalOrderInfo."Order Type" = AdditionalOrderInfo."Order Type"::FOODLotCombination; // P8007466
                end;
        end;
        WhseJnlLine."Item No." := Item."No.";
        WhseJnlLine.Description := Item.Description;
        WhseJnlLine."Variant Code" := ItemVariant.Code;
        WhseJnlLine."From Zone Code" := FromBin."Zone Code";
        WhseJnlLine."From Bin Code" := FromBin.Code;
        WhseJnlLine."To Zone Code" := ToBin."Zone Code";
        WhseJnlLine."To Bin Code" := ToBin.Code;
        WhseJnlLine."Unit of Measure Code" := ItemUnitOfMeasure.Code;
        WhseJnlLine."Qty. per Unit of Measure" := ItemUnitOfMeasure."Qty. per Unit of Measure";
        WhseJnlLine."Serial No." := SerialNoInfo."Serial No.";
        WhseJnlLine."Lot No." := LotNoInfo."Lot No.";
        WhseJnlLine."Warranty Date" := GetLotWarrantyDate();
        WhseJnlLine."Expiration Date" := LotNoInfo."Expiration Date";
        // P80053245
        if WhseJnlLine."Entry Type" = WhseJnlLine."Entry Type"::Movement then begin
            WhseJnlLine."New Lot No." := WhseJnlLine."Lot No.";
            WhseJnlLine."New Expiration Date" := WhseJnlLine."Expiration Date";
        end;
        // P80053245
        WhseJnlLine."Source Code" := GetSourceCode();
        if (ItemPostingDocNo <> '') then begin
            WhseJnlLine."Reference Document" := WhseJnlLine."Reference Document"::"Item Journal";
            WhseJnlLine."Reference No." := ItemPostingDocNo;
        end;
        WhseJnlLine."User ID" := UserId;
        WhseJnlLine.Quantity := Qty;
        WhseJnlLine."Qty. (Base)" := QtyBase;
        WhseJnlLine."Qty. (Absolute)" := Abs(WhseJnlLine.Quantity);
        WhseJnlLine."Qty. (Absolute, Base)" := Abs(WhseJnlLine."Qty. (Base)");
        WhseJnlLine.Weight := WhseJnlLine."Qty. (Absolute)" * ItemUnitOfMeasure.Weight;
        WhseJnlLine.Cubage := WhseJnlLine."Qty. (Absolute)" * ItemUnitOfMeasure.Cubage;
        // P8001082
        WhseJnlLine."Source Type" := AdditionalInfo."Source Type";
        WhseJnlLine."Source Subtype" := AdditionalInfo."Source Subtype";
        WhseJnlLine."Source No." := AdditionalInfo."Source No.";
        WhseJnlLine."Source Line No." := AdditionalInfo."Source Line No.";
        if (WhseJnlLine."Source Type" <> 0) then
            WhseJnlLine."Source Document" :=                                                      // P8001132
              WhseMgmt.GetSourceDocumentType(WhseJnlLine."Source Type", WhseJnlLine."Source Subtype"); // P8001132
        // P8001082

        // P8000591A
        if Item.TrackAlternateUnits() and
           ((WhseJnlLine."From Bin Code" = Location."Adjustment Bin Code") or
            (WhseJnlLine."To Bin Code" = Location."Adjustment Bin Code"))
        then begin
            if not Item."Catch Alternate Qtys." then                              // P8000740
                AdjmtAltQty := Round(QtyBase * Item.AlternateQtyPerBase(), 0.00001); // P8000740
            WhseJnlLine."Quantity (Alt.)" := AdjmtAltQty;
            WhseJnlLine."Quantity (Absolute, Alt.)" := Abs(AdjmtAltQty);
        end;
        // P8000591A

        if not (SkipWhseJnlLineCheck or MoveContainer) then begin // P8000974, P80056710
                                                                  // P8000895
            WMSMgmt.CheckWhseJnlLine(WhseJnlLine, 4, 0, false);
            ItemTrackingMgt.CheckWhseItemTrkgSetup(WhseJnlLine."Item No.", WhseSNRequired, WhseLNRequired, false);
            if WhseSNRequired or WhseLNRequired then begin
                if WhseLNRequired then
                    WhseJnlLine.TestField("Lot No.");
            end;
            // P8000895
        end;                                   // P8000974

        // P80057829
        if AdditionalInfo."From Container ID" <> '' then begin
            ContainerHeader.Get(AdditionalInfo."From Container ID");
            WhseJnlLine."From Container ID" := ContainerHeader.ID;
            WhseJnlLine."From Container License Plate" := ContainerHeader."License Plate";
        end;

        if AdditionalInfo."To Container ID" <> '' then begin
            ContainerHeader.Get(AdditionalInfo."To Container ID");
            WhseJnlLine."To Container ID" := ContainerHeader.ID;
            WhseJnlLine."To Container License Plate" := ContainerHeader."License Plate";
        end;
        // P80057829
        WhseJnlRegisterLine.DisableCombineLots(CombineLotsDisabled); // P8000495A
        XferRegsToWhse;   // P8000888
        WhseJnlRegisterLine.SetWhseRegister(WhseReg);
        XferWhseRoundingAdjmts; // P8001039
        OnWhseJnlRegisterLineOnBeforeWhseJnlRegisterLine(WhseJnlLine); // P80082969
        WhseJnlRegisterLine.Run(WhseJnlLine);
        PostWhseRoundingAdjmts; // P8001039
        WhseJnlRegisterLine.GetWhseRegister(WhseReg);
        XferRegsFromWhse; // P8000888
    end;

    local procedure GetLotWarrantyDate(): Date
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        with ItemLedgEntry do begin
            SetCurrentKey("Item No.", "Variant Code", "Lot No.");
            SetRange("Item No.", LotNoInfo."Item No.");
            SetRange("Variant Code", LotNoInfo."Variant Code");
            SetRange("Lot No.", LotNoInfo."Lot No.");
            SetRange(Positive, true);
            SetFilter("Warranty Date", '<>%1', 0D);
            if not Find('-') then
                exit(0D);
            exit("Warranty Date");
        end;
    end;

    procedure ClearSpecification()
    begin
        with TempSpecification do begin
            Reset;
            DeleteAll;
        end;
        Clear(TempSpecEntryNo);
        OnAfterClearSpecification; // P80082969
    end;

    procedure AddToSpecification(LocationCode: Code[10]; FromBinCode: Code[20]; ToBinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; LotNo: Code[50]; SerialNo: Code[50]; Qty: Decimal)
    begin
        CheckParameters(
          LocationCode, FromBinCode, ToBinCode, false, ItemNo,
          VariantCode, UnitOfMeasureCode, LotNo, SerialNo);
        AddToTempSpecification(Qty, CalcBaseQty(Qty));
    end;

    procedure AddToSpecificationBase(LocationCode: Code[10]; FromBinCode: Code[20]; ToBinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; LotNo: Code[50]; SerialNo: Code[50]; Qty: Decimal; QtyBase: Decimal)
    begin
        CheckParameters(
          LocationCode, FromBinCode, ToBinCode, false, ItemNo,
          VariantCode, UnitOfMeasureCode, LotNo, SerialNo);
        AddToTempSpecification(Qty, QtyBase);
    end;

    local procedure AddToTempSpecification(Qty: Decimal; QtyBase: Decimal)
    begin
        with TempSpecification do begin
            Reset;
            SetCurrentKey(
              "Item No.", "From Bin Code", "Location Code", "Entry Type",
              "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.");
            SetRange("Item No.", Item."No.");
            SetRange("From Bin Code", FromBin.Code);
            SetRange("To Bin Code", ToBin.Code);
            SetRange("Location Code", Location.Code);
            SetRange("Variant Code", ItemVariant.Code);
            SetRange("Unit of Measure Code", ItemUnitOfMeasure.Code);
            SetRange("Lot No.", LotNoInfo."Lot No.");
            SetRange("Serial No.", SerialNoInfo."Serial No.");
            if Find('-') then begin
                Quantity := Quantity + Qty;
                "Qty. (Base)" := "Qty. (Base)" + QtyBase;
                if (Quantity <> 0) or ("Qty. (Base)" <> 0) then
                    Modify
                else
                    Delete;
            end else begin
                TempSpecEntryNo := TempSpecEntryNo + 1;
                "Line No." := TempSpecEntryNo;
                "Item No." := Item."No.";
                "From Bin Code" := FromBin.Code;
                "To Bin Code" := ToBin.Code;
                "Location Code" := Location.Code;
                "Variant Code" := ItemVariant.Code;
                "Unit of Measure Code" := ItemUnitOfMeasure.Code;
                "Lot No." := LotNoInfo."Lot No.";
                "Serial No." := SerialNoInfo."Serial No.";
                Quantity := Qty;
                "Qty. (Base)" := QtyBase;
                if (Quantity <> 0) or ("Qty. (Base)" <> 0) then
                    Insert;
            end;
        end;

        OnAfterAddToTempSpecification(TempSpecification, Qty, QtyBase); // P80092182
    end;

    procedure GetSpecification(var TempSpecification2: Record "Warehouse Journal Line" temporary)
    begin
        with TempSpecification do begin
            Reset;
            if Find('-') then
                repeat
                    TempSpecification2 := TempSpecification;
                    TempSpecification2.Insert;
                until (Next = 0);
        end;
    end;

    procedure BuildBinContentsSpecification(var BinContent: Record "Bin Content")
    var
        WhseEntry: Record "Warehouse Entry";
        WhseActLine: Record "Warehouse Activity Line";
        WhseShptLine: Record "Warehouse Shipment Line";
        WhseRcptLine: Record "Warehouse Receipt Line";
        WhseTrackingLine: Record "Whse. Item Tracking Line";
        LNRequired: Boolean;
        SNRequired: Boolean;
        ContainerHeader: Record "Container Header";
        ContainerLine: Record "Container Line";
    begin
        ClearSpecification;
        WhseEntry.SetCurrentKey(
          "Location Code", "Bin Code", "Item No.", "Variant Code",
          "Unit of Measure Code", Open, "Lot No.", "Serial No.");
        // P8000631A
        ContainerHeader.SetCurrentKey("Container Item No.", "Container Serial No.", "Location Code", "Bin Code");
        ContainerLine.SetCurrentKey(
          "Item No.", "Variant Code", "Location Code", "Bin Code",
          "Unit of Measure Code", "Lot No.", "Serial No.");
        // P8000631A
        WhseActLine.SetCurrentKey(
          "Item No.", "Bin Code", "Location Code", "Action Type", "Variant Code",
          "Unit of Measure Code", "Breakbulk No.", "Activity Type", "Lot No.", "Serial No.");
        WhseShptLine.SetCurrentKey("Bin Code", "Location Code");
        WhseTrackingLine.SetCurrentKey(
          "Source ID", "Source Type", "Source Subtype", "Source Batch Name",
          "Source Prod. Order Line", "Source Ref. No.", "Location Code");
        with BinContent do begin
            SetRange("Receive Bin", false);
            if Find('-') then
                repeat
                    WhseEntry.SetRange("Location Code", "Location Code");
                    WhseEntry.SetRange("Bin Code", "Bin Code");
                    WhseEntry.SetRange("Item No.", "Item No.");
                    WhseEntry.SetRange("Variant Code", "Variant Code");
                    WhseEntry.SetRange("Unit of Measure Code", "Unit of Measure Code");
                    WhseEntry.SetRange(Open, true);
                    CopyFilter("Lot No. Filter", WhseEntry."Lot No.");
                    CopyFilter("Serial No. Filter", WhseEntry."Serial No.");
                    if WhseEntry.Find('-') then
                        repeat
                            AddToSpecificationBase(
                              "Location Code", "Bin Code", '', "Item No.", "Variant Code",
                              "Unit of Measure Code", WhseEntry."Lot No.", WhseEntry."Serial No.",
                              WhseEntry."Remaining Quantity", WhseEntry."Remaining Qty. (Base)");
                        until (WhseEntry.Next = 0);

                    // P8000631A
                    ContainerHeader.SetRange("Container Item No.", "Item No.");
                    CopyFilter("Serial No. Filter", ContainerHeader."Container Serial No.");
                    ContainerHeader.SetRange("Location Code", "Location Code");
                    ContainerHeader.SetRange("Bin Code", "Bin Code");
                    if ContainerHeader.Find('-') then
                        repeat
                            AddToSpecificationBase(
                              "Location Code", "Bin Code", '', "Item No.", "Variant Code",
                              "Unit of Measure Code", '', ContainerHeader."Container Serial No.", -1, -1);
                        until (ContainerHeader.Next = 0);

                    ContainerLine.SetRange("Item No.", "Item No.");
                    ContainerLine.SetRange("Variant Code", "Variant Code");
                    ContainerLine.SetRange("Location Code", "Location Code");
                    ContainerLine.SetRange("Bin Code", "Bin Code");
                    ContainerLine.SetRange("Unit of Measure Code", "Unit of Measure Code");
                    CopyFilter("Lot No. Filter", ContainerLine."Lot No.");
                    CopyFilter("Serial No. Filter", ContainerLine."Serial No.");
                    if ContainerLine.Find('-') then
                        repeat
                            AddToSpecificationBase(
                              "Location Code", "Bin Code", '', "Item No.", "Variant Code",
                              "Unit of Measure Code", ContainerLine."Lot No.", ContainerLine."Serial No.",
                              -ContainerLine.Quantity, -ContainerLine."Quantity (Base)");
                        until (ContainerLine.Next = 0);
                    // P8000631A

                    WhseActLine.SetRange("Item No.", "Item No.");
                    WhseActLine.SetRange("Bin Code", "Bin Code");
                    WhseActLine.SetRange("Location Code", "Location Code");
                    WhseActLine.SetRange("Action Type", WhseActLine."Action Type"::Take);
                    WhseActLine.SetRange("Variant Code", "Variant Code");
                    WhseActLine.SetRange("Unit of Measure Code", "Unit of Measure Code");
                    CopyFilter("Lot No. Filter", WhseActLine."Lot No.");
                    CopyFilter("Serial No. Filter", WhseActLine."Serial No.");
                    if WhseActLine.Find('-') then
                        repeat
                            AddToSpecificationBase(
                              "Location Code", "Bin Code", '', "Item No.", "Variant Code",
                              "Unit of Measure Code", WhseActLine."Lot No.", WhseActLine."Serial No.",
                              -WhseActLine."Qty. Outstanding", -WhseActLine."Qty. Outstanding (Base)");
                        until (WhseActLine.Next = 0);

                    ItemTrackingMgt.CheckWhseItemTrkgSetup("Item No.", SNRequired, LNRequired, false);
                    WhseShptLine.SetRange("Bin Code", "Bin Code");
                    WhseShptLine.SetRange("Location Code", "Location Code");
                    WhseShptLine.SetRange("Item No.", "Item No.");
                    WhseShptLine.SetRange("Variant Code", "Variant Code");
                    WhseShptLine.SetRange("Unit of Measure Code", "Unit of Measure Code");
                    if WhseShptLine.Find('-') then
                        repeat
                            if not (LNRequired or SNRequired) then
                                AddToSpecificationBase(
                                  "Location Code", "Bin Code", '', "Item No.", "Variant Code", "Unit of Measure Code",
                                  '', '', -WhseShptLine."Qty. Picked", -WhseShptLine."Qty. Picked (Base)")
                            else begin
                                WhseTrackingLine.SetRange("Source ID", WhseShptLine."No.");
                                WhseTrackingLine.SetRange("Source Type", DATABASE::"Warehouse Shipment Line");
                                WhseTrackingLine.SetRange("Source Ref. No.", WhseShptLine."Line No.");
                                CopyFilter("Lot No. Filter", WhseTrackingLine."Lot No.");
                                CopyFilter("Serial No. Filter", WhseTrackingLine."Serial No.");
                                if WhseTrackingLine.Find('-') then
                                    repeat
                                        if (WhseTrackingLine."Qty. per Unit of Measure" = 0) then
                                            WhseTrackingLine."Qty. per Unit of Measure" := 1;
                                        AddToSpecificationBase(
                                          "Location Code", "Bin Code", '', "Item No.", "Variant Code", "Unit of Measure Code",
                                          WhseTrackingLine."Lot No.", WhseTrackingLine."Serial No.",
                                          -Round(WhseTrackingLine."Qty. Registered (Base)" /
                                                 WhseTrackingLine."Qty. per Unit of Measure", 0.00001),
                                          -WhseTrackingLine."Qty. Registered (Base)");
                                    until (WhseTrackingLine.Next = 0);
                            end;
                        until (WhseShptLine.Next = 0);
                until (Next = 0);
        end;
        OnAfterBuildBinContentsSpecification(BinContent, TempSpecification); // P80092182
    end;

    procedure RegisterMoveFromSpecification()
    var
        Handled: Boolean;
    begin
        // P80079197
        OnBeforeRegisterMoveFromSpecification(TempSpecification, Handled);
        if Handled then
            exit;
        // P80079197
        with TempSpecification do begin
            Reset;
            if not Find('-') then
                Error(Text000);
            repeat
                OnBeforeRegisterMoveFromSpecificationRegisterMoveBase(TempSpecification); // P80092182
                RegisterMoveBase(
                  "Location Code", "From Bin Code", "To Bin Code", "Item No.", "Variant Code",
                  "Unit of Measure Code", "Lot No.", "Serial No.", Quantity, "Qty. (Base)");
            until (Next = 0);
        end;
        ClearSpecification;
        OnAfterRegisterMoveFromSpecification(); // P80079197
    end;

    procedure CreateWhsePutAway(var WhseActHeader: Record "Warehouse Activity Header")
    var
        WhseIntPutAwayHdr: Record "Whse. Internal Put-away Header";
        WhseIntPutAwayLine: Record "Whse. Internal Put-away Line";
        CreatePutAwayFromWhseSource: Report "Whse.-Source - Create Document";
        WhseActLine: Record "Warehouse Activity Line";
        WarehouseEntry: Record "Warehouse Entry";
    begin
        with TempSpecification do begin
            Reset;
            if not Find('-') then
                Error(Text001);
            Location.Get("Location Code");
            FromBin.Get("Location Code", "From Bin Code");
            while (Next <> 0) do begin
                if ("Location Code" <> Location.Code) then
                    Error(Text002);
                if (FromBin.Code <> '') and ("From Bin Code" <> FromBin.Code) then
                    Clear(FromBin);
            end;
        end;

        with WhseIntPutAwayHdr do begin
            "Location Code" := Location.Code;
            "Hidden Put-Away" := true;
            if (AssignedUserID <> '') then
                Validate("Assigned User ID", AssignedUserID);
            Insert(true);
            if (FromBin.Code <> '') then begin
                Validate("From Zone Code", FromBin."Zone Code");
                Validate("From Bin Code", FromBin.Code);
                Modify(true);
            end;
            WhseIntPutAwayLine."No." := "No.";
        end;

        with TempSpecification do begin
            Reset;
            Find('-');
            repeat
                WhseIntPutAwayLine.Init;
                WhseIntPutAwayLine."Line No." := WhseIntPutAwayLine."Line No." + 10000;
                WhseIntPutAwayLine.Validate("Location Code", "Location Code");
                WhseIntPutAwayLine.Validate("From Bin Code", "From Bin Code");
                FromBin.Get("Location Code", "From Bin Code");
                WhseIntPutAwayLine."From Zone Code" := FromBin."Zone Code";
                WhseIntPutAwayLine.Validate("Item No.", "Item No.");
                WhseIntPutAwayLine.Validate("Variant Code", "Variant Code");
                WhseIntPutAwayLine.Validate("Unit of Measure Code", "Unit of Measure Code");
                WhseIntPutAwayLine.Validate(Quantity, Quantity);
                WhseIntPutAwayLine.Insert;
                if ("Serial No." <> '') or ("Lot No." <> '') then begin
                    // P800-MegaApp
                    WarehouseEntry."Lot No." := "Lot No.";
                    WarehouseEntry."Serial No." := "Serial No.";
                    WhseIntPutAwayLine.SetItemTrackingLines(WarehouseEntry, Quantity * WhseIntPutAwayLine."Qty. per Unit of Measure");
                end;
            // P800-MegaApp
            until (Next = 0);
        end;

        with WhseIntPutAwayHdr do begin
            Find;
            Status := Status::Released;
            Modify;
        end;

        CreatePutAwayFromWhseSource.SetWhseInternalPutAway(WhseIntPutAwayHdr);
        CreatePutAwayFromWhseSource.SetHideValidationDialog(true);
        CreatePutAwayFromWhseSource.UseRequestPage(false);
        CreatePutAwayFromWhseSource.RunModal;

        with WhseActLine do begin
            SetCurrentKey("Whse. Document No.", "Whse. Document Type", "Activity Type");
            SetRange("Whse. Document No.", WhseIntPutAwayHdr."No.");
            SetRange("Whse. Document Type", "Whse. Document Type"::"Internal Put-away");
            SetRange("Activity Type", "Activity Type"::"Put-away");
            if not Find('-') then
                Error(Text003);
            WhseActHeader.Get("Activity Type", "No.");
        end;
        ClearSpecification;
    end;

    procedure CreateWhsePick(var WhseActHeader: Record "Warehouse Activity Header")
    var
        WhseIntPickHdr: Record "Whse. Internal Pick Header";
        WhseIntPickLine: Record "Whse. Internal Pick Line";
        CreatePickFromWhseSource: Report "Whse.-Source - Create Document";
        WhseActLine: Record "Warehouse Activity Line";
    begin
        with TempSpecification do begin
            Reset;
            if not Find('-') then
                Error(Text004);
            Location.Get("Location Code");
            ToBin.Get("Location Code", "To Bin Code");
            while (Next <> 0) do begin
                if ("Location Code" <> Location.Code) then
                    Error(Text005);
                if (ToBin.Code <> '') and ("To Bin Code" <> ToBin.Code) then
                    Clear(ToBin);
            end;
        end;

        with WhseIntPickHdr do begin
            "Location Code" := Location.Code;
            "Hidden Pick" := true;
            if (AssignedUserID <> '') then
                Validate("Assigned User ID", AssignedUserID);
            Insert(true);
            if (ToBin.Code <> '') then begin
                Validate("To Zone Code", ToBin."Zone Code");
                Validate("To Bin Code", ToBin.Code);
                Modify(true);
            end;
            WhseIntPickLine."No." := "No.";
        end;

        with TempSpecification do begin
            Reset;
            Find('-');
            repeat
                WhseIntPickLine.Init;
                WhseIntPickLine."Line No." := WhseIntPickLine."Line No." + 10000;
                WhseIntPickLine.Validate("Location Code", "Location Code");
                WhseIntPickLine.Validate("To Bin Code", "To Bin Code");
                ToBin.Get("Location Code", "To Bin Code");
                WhseIntPickLine."To Zone Code" := ToBin."Zone Code";
                WhseIntPickLine.Validate("Item No.", "Item No.");
                WhseIntPickLine.Validate("Variant Code", "Variant Code");
                WhseIntPickLine.Validate("Unit of Measure Code", "Unit of Measure Code");
                WhseIntPickLine.Validate(Quantity, Quantity);
                WhseIntPickLine.Insert;
                if ("Serial No." <> '') or ("Lot No." <> '') then
                    WhseIntPickLine.SetItemTrackingLines(
                      "Serial No.", "Lot No.", 0D, Quantity * WhseIntPickLine."Qty. per Unit of Measure");
            until (Next = 0);
        end;

        with WhseIntPickHdr do begin
            Find;
            Status := Status::Released;
            Modify;
        end;

        WhseIntPickLine.SetRange("No.", WhseIntPickHdr."No.");
        CreatePickFromWhseSource.SetWhseInternalPickLine(WhseIntPickLine, AssignedUserID);
        CreatePickFromWhseSource.SetHideValidationDialog(true);
        CreatePickFromWhseSource.UseRequestPage(false);
        CreatePickFromWhseSource.RunModal;

        with WhseActLine do begin
            SetCurrentKey("Whse. Document No.", "Whse. Document Type", "Activity Type");
            SetRange("Whse. Document No.", WhseIntPickHdr."No.");
            SetRange("Whse. Document Type", "Whse. Document Type"::"Internal Pick");
            SetRange("Activity Type", "Activity Type"::Pick);
            if not Find('-') then
                Error(Text006);
            WhseActHeader.Get("Activity Type", "No.");
        end;
        ClearSpecification;
    end;

    local procedure CreateWhsePickWithSource(PickCreated: Boolean; var WhseActHeader: Record "Warehouse Activity Header"): Boolean
    var
        TempWhseItemTrkgLine: Record "Whse. Item Tracking Line" temporary;
        FirstDocNo: Code[20];
        LastDocNo: Code[20];
    begin
        if not PickCreated then
            exit(false);
        CreatePick.CreateWhseDocument(FirstDocNo, LastDocNo, false); // P8001301
        CreatePick.ReturnTempItemTrkgLines(TempWhseItemTrkgLine);
        ItemTrackingMgt.UpdateWhseItemTrkgLines(TempWhseItemTrkgLine);
        exit(WhseActHeader.Get(WhseActHeader.Type::Pick, FirstDocNo));
    end;

    procedure CreateWhsePickForShpt(WhseShptNo: Code[20]; var WhseActHeader: Record "Warehouse Activity Header"): Boolean
    var
        WhseShptHeader: Record "Warehouse Shipment Header";
    begin
        WhseShptHeader.SetRange("No.", WhseShptNo);
        exit(CreateShptWhsePick(WhseShptHeader, 0, WhseActHeader));
    end;

    procedure CreateWhsePickForShptLine(WhseShptNo: Code[20]; WhseShptLineNo: Integer; var WhseActHeader: Record "Warehouse Activity Header"): Boolean
    var
        WhseShptHeader: Record "Warehouse Shipment Header";
    begin
        WhseShptHeader.SetRange("No.", WhseShptNo);
        exit(CreateShptWhsePick(WhseShptHeader, WhseShptLineNo, WhseActHeader));
    end;

    procedure CreateWhsePickForShpts(var WhseShptHeader: Record "Warehouse Shipment Header"; var WhseActHeader: Record "Warehouse Activity Header"): Boolean
    begin
        exit(CreateShptWhsePick(WhseShptHeader, 0, WhseActHeader));
    end;

    local procedure CreateShptWhsePick(var WhseShptHeader: Record "Warehouse Shipment Header"; WhseShptLineNo: Integer; var WhseActHeader: Record "Warehouse Activity Header"): Boolean
    var
        WhseShptLine: Record "Warehouse Shipment Line";
        PickCreated: Boolean;
    begin
        Clear(CreatePick);
        // P800131478
        Clear(CreatePickParameters);
        CreatePickParameters."Assigned ID" := AssignedUserID;
        CreatePickParameters."Sorting Method" := CreatePickParameters."Sorting Method"::None;
        CreatePickParameters."Max No. of Lines" := 0;
        CreatePickParameters."Max No. of Source Doc." := 0;
        CreatePickParameters."Do Not Fill Qty. to Handle" := false;
        CreatePickParameters."Breakbulk Filter" := false;
        CreatePickParameters."Per Bin" := false;
        CreatePickParameters."Per Zone" := false;
        CreatePickParameters."Whse. Document" := CreatePickParameters."Whse. Document"::Shipment;
        CreatePickParameters."Whse. Document Type" := CreatePickParameters."Whse. Document Type"::Pick;
        CreatePick.SetParameters(CreatePickParameters);
        // P800131478
        if WhseShptHeader.Find('-') then
            with WhseShptLine do
                repeat
                    SetRange("No.", WhseShptHeader."No.");
                    if (WhseShptLineNo <> 0) then
                        SetRange("Line No.", WhseShptLineNo);
                    SetFilter(Quantity, '>0');
                    if Find('-') then
                        repeat
                            CreateShptWhsePickLine(WhseShptHeader, WhseShptLine, PickCreated);
                        until (Next = 0);
                until (WhseShptHeader.Next = 0);
        exit(CreateWhsePickWithSource(PickCreated, WhseActHeader));
    end;

    local procedure CreateShptWhsePickLine(var WhseShptHeader: Record "Warehouse Shipment Header"; var WhseShptLine: Record "Warehouse Shipment Line"; var PickCreated: Boolean)
    var
        QtyToPickBase: Decimal;
        QtyToPick: Decimal;
        OldQtyToPickBase: Decimal;
        OldQtyToPick: Decimal;
    begin
        with WhseShptLine do begin
            TestField("Qty. per Unit of Measure");
            CalcFields("Pick Qty.", "Pick Qty. (Base)");
            QtyToPick := Quantity - ("Qty. Picked" + "Pick Qty.");
            QtyToPickBase := "Qty. (Base)" - ("Qty. Picked (Base)" + "Pick Qty. (Base)");
            if (QtyToPick > 0) then begin
                CreatePick.SetWhseShipment(
                  WhseShptLine, 1, WhseShptHeader."Shipping Agent Code",
                  WhseShptHeader."Shipping Agent Service Code", WhseShptHeader."Shipment Method Code");
                CreatePick.SetTempWhseItemTrkgLine(
                  "No.", DATABASE::"Warehouse Shipment Line", '', 0, "Line No.", "Location Code");
                OldQtyToPickBase := QtyToPickBase;
                OldQtyToPick := QtyToPick;
                CreatePick.CreateTempLine(
                  "Location Code", "Item No.", "Variant Code", "Unit of Measure Code",
                  '', "Bin Code", "Qty. per Unit of Measure", QtyToPick, QtyToPickBase);
                CreatePick.SaveTempItemTrkgLines;
                if (not PickCreated) and
                   ((QtyToPick <> OldQtyToPick) or (QtyToPickBase <> OldQtyToPickBase))
                then
                    PickCreated := true;
            end;
        end;
    end;

    procedure AddWhsePickWhseReq(WhseReq: Record "Warehouse Request")
    var
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        with WhseShptLine do begin
            SetCurrentKey("Source Type", "Source Subtype", "Source No.");
            SetRange("Source Type", WhseReq."Source Type");
            SetRange("Source Subtype", WhseReq."Source Subtype");
            SetRange("Source No.", WhseReq."Source No.");
            SetRange("Location Code", WhseReq."Location Code");
            SetFilter(Quantity, '>0');
            if Find('-') then
                repeat
                    MarkedWhseShptLine := WhseShptLine;
                    MarkedWhseShptLine.Mark(true);
                until (Next = 0);
        end;
    end;

    procedure CreateWhseReqWhsePick(var WhseActHeader: Record "Warehouse Activity Header"): Boolean
    var
        WhseShptHeader: Record "Warehouse Shipment Header";
        PickCreated: Boolean;
    begin
        Clear(CreatePick);
        // P800131478
        // P800131478
        Clear(CreatePickParameters);
        CreatePickParameters."Assigned ID" := AssignedUserID;
        CreatePickParameters."Sorting Method" := CreatePickParameters."Sorting Method"::None;
        CreatePickParameters."Max No. of Lines" := 0;
        CreatePickParameters."Max No. of Source Doc." := 0;
        CreatePickParameters."Do Not Fill Qty. to Handle" := false;
        CreatePickParameters."Breakbulk Filter" := false;
        CreatePickParameters."Per Bin" := false;
        CreatePickParameters."Per Zone" := false;
        CreatePickParameters."Whse. Document" := CreatePickParameters."Whse. Document"::Shipment;
        CreatePickParameters."Whse. Document Type" := CreatePickParameters."Whse. Document Type"::Pick;
        CreatePick.SetParameters(CreatePickParameters);
        // P800131478
        with MarkedWhseShptLine do begin
            MarkedOnly(true);
            if Find('-') then
                repeat
                    WhseShptHeader.Get("No.");
                    CreateShptWhsePickLine(WhseShptHeader, MarkedWhseShptLine, PickCreated);
                until (Next = 0);
        end;
        exit(CreateWhsePickWithSource(PickCreated, WhseActHeader));
    end;

    procedure CreateWhsePickForProdOrder(ProdOrderNo: Code[20]; var WhseActHeader: Record "Warehouse Activity Header"): Boolean
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Released);
        ProdOrderLine.SetRange("Prod. Order No.", ProdOrderNo);
        exit(CreateProdWhsePick(ProdOrderLine, 0, WhseActHeader));
    end;

    procedure CreateWhsePickForProdOrderLine(ProdOrderNo: Code[20]; ProdOrderLineNo: Integer; var WhseActHeader: Record "Warehouse Activity Header"): Boolean
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Released);
        ProdOrderLine.SetRange("Prod. Order No.", ProdOrderNo);
        ProdOrderLine.SetRange("Line No.", ProdOrderLineNo);
        exit(CreateProdWhsePick(ProdOrderLine, 0, WhseActHeader));
    end;

    procedure CreateWhsePickForProdComp(ProdOrderNo: Code[20]; ProdOrderLineNo: Integer; ProdOrderCompLineNo: Integer; var WhseActHeader: Record "Warehouse Activity Header"): Boolean
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Released);
        ProdOrderLine.SetRange("Prod. Order No.", ProdOrderNo);
        ProdOrderLine.SetRange("Line No.", ProdOrderLineNo);
        exit(CreateProdWhsePick(ProdOrderLine, ProdOrderCompLineNo, WhseActHeader));
    end;

    procedure CreateWhsePickForProdOrders(var ProdOrderLine: Record "Prod. Order Line"; var WhseActHeader: Record "Warehouse Activity Header"): Boolean
    begin
        exit(CreateProdWhsePick(ProdOrderLine, 0, WhseActHeader));
    end;

    local procedure CreateProdWhsePick(var ProdOrderLine: Record "Prod. Order Line"; ProdOrderCompLineNo: Integer; var WhseActHeader: Record "Warehouse Activity Header"): Boolean
    var
        ProdOrderComp: Record "Prod. Order Component";
        PickCreated: Boolean;
    begin
        Clear(CreatePick);
        // P800131478
        Clear(CreatePickParameters);
        CreatePickParameters."Assigned ID" := AssignedUserID;
        CreatePickParameters."Sorting Method" := CreatePickParameters."Sorting Method"::None;
        CreatePickParameters."Max No. of Lines" := 0;
        CreatePickParameters."Max No. of Source Doc." := 0;
        CreatePickParameters."Do Not Fill Qty. to Handle" := false;
        CreatePickParameters."Breakbulk Filter" := false;
        CreatePickParameters."Per Bin" := false;
        CreatePickParameters."Per Zone" := false;
        CreatePickParameters."Whse. Document" := CreatePickParameters."Whse. Document"::Production;
        CreatePickParameters."Whse. Document Type" := CreatePickParameters."Whse. Document Type"::Pick;
        CreatePick.SetParameters(CreatePickParameters);
        // P800131478
        if ProdOrderLine.Find('-') then
            with ProdOrderComp do
                repeat
                    SetRange(Status, ProdOrderLine.Status);
                    SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
                    SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
                    if (ProdOrderCompLineNo <> 0) then
                        SetRange("Line No.", ProdOrderCompLineNo);
                    SetFilter("Item No.", '<>%1', '');
                    SetFilter(
                      "Flushing Method", '%1|%2|%3', "Flushing Method"::Manual,
                      "Flushing Method"::"Pick + Forward", "Flushing Method"::"Pick + Backward");
                    SetRange("Planning Level Code", 0);
                    SetFilter("Expected Quantity", '>0');
                    if Find('-') then
                        repeat
                            if ("Flushing Method" <> "Flushing Method"::"Pick + Forward") or
                               ("Routing Link Code" <> '')
                            then
                                CreateProdWhsePickLine(ProdOrderLine, ProdOrderComp, PickCreated);
                        until (Next = 0);
                until (ProdOrderLine.Next = 0);
        exit(CreateWhsePickWithSource(PickCreated, WhseActHeader));
    end;

    local procedure CreateProdWhsePickLine(var ProdOrderLine: Record "Prod. Order Line"; var ProdOrderComp: Record "Prod. Order Component"; var PickCreated: Boolean)
    var
        QtyToPickBase: Decimal;
        QtyToPick: Decimal;
        OldQtyToPickBase: Decimal;
        OldQtyToPick: Decimal;
    begin
        with ProdOrderComp do begin
            TestField("Qty. per Unit of Measure");
            // CALCFIELDS("Pick Qty.", "Pick Qty. (Base)"); // P8000322A
            CalcPickQtys;                                   // P8000322A
            QtyToPick := "Expected Quantity" - ("Qty. Picked" + "Pick Qty.");
            QtyToPickBase := "Expected Qty. (Base)" - ("Qty. Picked (Base)" + "Pick Qty. (Base)");
            if (QtyToPick > 0) then begin
                Location.Get("Location Code");
                Location.SetToProductionBin("Prod. Order No.", "Prod. Order Line No.", "Line No."); // P8001142
                CreatePick.SetProdOrderCompLine(ProdOrderComp, 1);
                CreatePick.SetTempWhseItemTrkgLine(
                  "Prod. Order No.", DATABASE::"Prod. Order Component", '',
                  "Prod. Order Line No.", "Line No.", "Location Code");
                OldQtyToPickBase := QtyToPickBase;
                OldQtyToPick := QtyToPick;
                CreatePick.CreateTempLine(
                  "Location Code", "Item No.", "Variant Code", "Unit of Measure Code",
                  '', Location."To-Production Bin Code",
                  "Qty. per Unit of Measure", QtyToPick, QtyToPickBase);
                CreatePick.SaveTempItemTrkgLines;
                if (not PickCreated) and
                   ((QtyToPick <> OldQtyToPick) or (QtyToPickBase <> OldQtyToPickBase))
                then
                    PickCreated := true;
            end;
        end;
    end;

    procedure AddStagedPickWhseReq(WhseReq: Record "Warehouse Request")
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
    begin
        with WhseReq do
            InitTempStagedPickSourceLine(
              "Location Code", "Source Type", "Source Subtype", "Source No.", 0);

        with TempStagedPickSourceLine do begin
            case "Source Type" of
                DATABASE::"Sales Line":
                    begin
                        SalesLine.SetRange("Document Type", "Source Subtype");
                        SalesLine.SetRange("Document No.", "Source No.");
                        SalesLine.SetRange("Location Code", "Location Code");
                        SalesLine.SetRange(Type, SalesLine.Type::Item);
                        SalesLine.SetFilter("No.", '<>%1', '');
                        if SalesSampleStaging then
                            SalesLine.SetRange("Sales Sample", true);
                        if SalesLine.Find('-') then
                            repeat
                                AddTempStagedPickSourceLine(
                                  SalesLine."Line No.", 0,
                                  GetSalesLineAvailPickQty(SalesLine) -
                                  GetWhseShptPickQty(
                                    DATABASE::"Sales Line", "Source Subtype", "Source No.", SalesLine."Line No."));
                            until (SalesLine.Next = 0);
                    end;
                DATABASE::"Purchase Line":
                    begin
                        PurchLine.SetRange("Document Type", "Source Subtype");
                        PurchLine.SetRange("Document No.", "Source No.");
                        PurchLine.SetRange("Location Code", "Location Code");
                        PurchLine.SetRange(Type, PurchLine.Type::Item);
                        PurchLine.SetFilter("No.", '<>%1', '');
                        if PurchLine.Find('-') and (not SalesSampleStaging) then
                            repeat
                                AddTempStagedPickSourceLine(
                                  PurchLine."Line No.", 0,
                                  GetPurchLineAvailPickQty(PurchLine) -
                                  GetWhseShptPickQty(
                                    DATABASE::"Purchase Line", "Source Subtype", "Source No.", PurchLine."Line No."));
                            until (PurchLine.Next = 0);
                    end;
                DATABASE::"Transfer Line":
                    begin
                        TransLine.SetRange("Document No.", "Source No.");
                        TransLine.SetRange("Transfer-from Code", "Location Code");
                        TransLine.SetRange("Derived From Line No.", 0);
                        TransLine.SetFilter("Item No.", '<>%1', '');
                        if TransLine.Find('-') and (not SalesSampleStaging) then
                            repeat
                                AddTempStagedPickSourceLine(
                                  TransLine."Line No.", 0,
                                  GetTransLineAvailPickQty(TransLine) -
                                  GetWhseShptPickQty(
                                    DATABASE::"Transfer Line", 0, "Source No.", TransLine."Line No."));
                            until (TransLine.Next = 0);
                    end;
            end;
        end;
    end;

    procedure AddStagedPickProdOrderLine(ProdOrderLine: Record "Prod. Order Line")
    var
        ProdOrderComp: Record "Prod. Order Component";
    begin
        with ProdOrderLine do
            InitTempStagedPickSourceLine(
              "Location Code", DATABASE::"Prod. Order Component",
              Status, "Prod. Order No.", "Line No.");

        with TempStagedPickSourceLine do begin
            ProdOrderComp.SetRange(Status, "Source Subtype");
            ProdOrderComp.SetRange("Prod. Order No.", "Source No.");
            ProdOrderComp.SetRange("Prod. Order Line No.", "Source Line No.");
            ProdOrderComp.SetRange("Location Code", "Location Code");
            ProdOrderComp.SetFilter("Item No.", '<>%1', '');
            if ProdOrderComp.Find('-') then
                repeat
                    if not ProdOrderComp.ReplenishmentNotRequired() then begin
                        ProdOrderComp.CalcFields("Pick Qty.");
                        AddTempStagedPickSourceLine(
                          ProdOrderLine."Line No.", ProdOrderComp."Line No.",
                          GetProdCompLineAvailPickQty(ProdOrderComp) - ProdOrderComp."Pick Qty.");
                    end;
                until (ProdOrderComp.Next = 0);
        end;
    end;

    local procedure InitTempStagedPickSourceLine(LocationCode: Code[10]; SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20]; SourceLineNo: Integer)
    begin
        with TempStagedPickSourceLine do begin
            if not Find('+') then
                "Line No." := 0;
            Init;
            "Location Code" := LocationCode;
            "Source Type" := SourceType;
            "Source Subtype" := SourceSubtype;
            "Source No." := SourceNo;
            "Source Line No." := SourceLineNo;
        end;
    end;

    local procedure AddTempStagedPickSourceLine(SourceLineNo: Integer; SourceSublineNo: Integer; PickQty: Decimal)
    begin
        with TempStagedPickSourceLine do
            if (PickQty > 0) then begin
                "Source Line No." := SourceLineNo;
                "Source Subline No." := SourceSublineNo;
                "Line No." := "Line No." + 1;
                Insert;
            end;
    end;

    procedure CreateStagedPick(var WhseStagedPickHeader: Record "Whse. Staged Pick Header"): Boolean
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        ProdOrderComp: Record "Prod. Order Component";
    begin
        with TempStagedPickSourceLine do begin
            if not Find('-') then
                exit(false);
            CreateStagedPickHeader(WhseStagedPickHeader);
            repeat
                case "Source Type" of
                    DATABASE::"Sales Line":
                        begin
                            SalesLine.Get("Source Subtype", "Source No.", "Source Line No.");
                            WhseStagedPickMgmt.AddSourceSalesLine(WhseStagedPickHeader, SalesLine);
                        end;
                    DATABASE::"Purchase Line":
                        begin
                            PurchLine.Get("Source Subtype", "Source No.", "Source Line No.");
                            WhseStagedPickMgmt.AddSourcePurchLine(WhseStagedPickHeader, PurchLine);
                        end;
                    DATABASE::"Transfer Line":
                        begin
                            TransLine.Get("Source No.", "Source Line No.");
                            WhseStagedPickMgmt.AddSourceTransLine(WhseStagedPickHeader, TransLine);
                        end;
                    DATABASE::"Prod. Order Component":
                        begin
                            ProdOrderComp.Get("Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
                            WhseStagedPickMgmt.AddSourceProdCompLine(WhseStagedPickHeader, ProdOrderComp);
                        end;
                end;
            until (Next = 0);
        end;
        exit(true);
    end;

    local procedure CreateStagedPickHeader(var WhseStagedPickHeader: Record "Whse. Staged Pick Header")
    begin
        with WhseStagedPickHeader do begin
            Validate("Location Code", TempStagedPickSourceLine."Location Code");
            if SalesSampleStaging then begin
                Location.Get("Location Code");
                Location.TestField("Sample Staging Bin Code");
                "Zone Code" := '';
                Validate("Bin Code", Location."Sample Staging Bin Code");
            end;
            if (AssignedUserID <> '') then
                Validate("Assigned User ID", AssignedUserID);
            case TempStagedPickSourceLine."Source Type" of
                DATABASE::"Prod. Order Component":
                    Validate("Staging Type", "Staging Type"::Production);
                else
                    Validate("Staging Type", "Staging Type"::Shipment);
            end;
            Insert(true);
        end;
    end;

    procedure SetSalesSampleStaging(NewSalesSampleStaging: Boolean)
    begin
        SalesSampleStaging := NewSalesSampleStaging;
    end;

    procedure CreateWhsePickToStage(var WhseStgdPick: Record "Whse. Staged Pick Header"; var WhseActHeader: Record "Warehouse Activity Header"): Boolean
    var
        WhseStgdPickLine: Record "Whse. Staged Pick Line";
        PickCreated: Boolean;
    begin
        Clear(CreatePick);
        // P800131478
        Clear(CreatePickParameters);
        CreatePickParameters."Assigned ID" := AssignedUserID;
        CreatePickParameters."Sorting Method" := CreatePickParameters."Sorting Method"::None;
        CreatePickParameters."Max No. of Lines" := 0;
        CreatePickParameters."Max No. of Source Doc." := 0;
        CreatePickParameters."Do Not Fill Qty. to Handle" := false;
        CreatePickParameters."Breakbulk Filter" := false;
        CreatePickParameters."Per Bin" := false;
        CreatePickParameters."Per Zone" := false;
        CreatePickParameters."Whse. Document" := CreatePickParameters."Whse. Document"::FOODStagedPick;
        CreatePickParameters."Whse. Document Type" := CreatePickParameters."Whse. Document Type"::Pick;
        CreatePick.SetParameters(CreatePickParameters);
        with WhseStgdPickLine do begin
            SetRange("No.", WhseStgdPick."No.");
            SetFilter("Qty. Outstanding", '>0');
            if Find('-') then
                repeat
                    CreateWhsePickToStageLine(WhseStgdPick, WhseStgdPickLine, PickCreated);
                until (Next = 0);
        end;
        exit(CreateWhsePickWithSource(PickCreated, WhseActHeader));
    end;

    local procedure CreateWhsePickToStageLine(var WhseStgdPick: Record "Whse. Staged Pick Header"; var WhseStgdPickLine: Record "Whse. Staged Pick Line"; var PickCreated: Boolean)
    var
        QtyToPickBase: Decimal;
        QtyToPick: Decimal;
        OldQtyToPickBase: Decimal;
        OldQtyToPick: Decimal;
    begin
        with WhseStgdPickLine do begin
            TestField("Qty. per Unit of Measure");
            CalcFields("Pick to Stage Qty.", "Pick to Stage Qty. (Base)");
            QtyToPick := "Qty. to Stage" - ("Qty. Staged" + "Pick to Stage Qty.");
            QtyToPickBase := "Qty. to Stage (Base)" - ("Qty. Staged (Base)" + "Pick to Stage Qty. (Base)");
            if (QtyToPick > 0) then begin
                CreatePick.SetWhseStagedPickLine(WhseStgdPickLine, 1);
                CreatePick.SetTempWhseItemTrkgLine(
                  "No.", DATABASE::"Whse. Staged Pick Line", '', 0, "Line No.", "Location Code");
                OldQtyToPickBase := QtyToPickBase;
                OldQtyToPick := QtyToPick;
                CreatePick.CreateTempLine(
                  "Location Code", "Item No.", "Variant Code", "Unit of Measure Code",
                  '', "Bin Code", "Qty. per Unit of Measure", QtyToPick, QtyToPickBase);
                CreatePick.SaveTempItemTrkgLines;
                if (not PickCreated) and
                   ((QtyToPick <> OldQtyToPick) or (QtyToPickBase <> OldQtyToPickBase))
                then
                    PickCreated := true;
            end;
        end;
    end;

    procedure CreateWhsePickFromStage(var WhseStgdPick: Record "Whse. Staged Pick Header"; var WhseActHeader: Record "Warehouse Activity Header"): Boolean
    var
        WhseStgdPickSourceLine: Record "Whse. Staged Pick Source Line";
        PickCreated: Boolean;
    begin
        Clear(CreatePick);
        case WhseStgdPick."Staging Type" of
            WhseStgdPick."Staging Type"::Shipment:
                // P800131478
                begin
                    Clear(CreatePickParameters);
                    CreatePickParameters."Assigned ID" := AssignedUserID;
                    CreatePickParameters."Sorting Method" := CreatePickParameters."Sorting Method"::None;
                    CreatePickParameters."Max No. of Lines" := 0;
                    CreatePickParameters."Max No. of Source Doc." := 0;
                    CreatePickParameters."Do Not Fill Qty. to Handle" := false;
                    CreatePickParameters."Breakbulk Filter" := false;
                    CreatePickParameters."Per Bin" := false;
                    CreatePickParameters."Per Zone" := false;
                    CreatePickParameters."Whse. Document" := CreatePickParameters."Whse. Document"::Shipment;
                    CreatePickParameters."Whse. Document Type" := CreatePickParameters."Whse. Document Type"::Pick;
                    CreatePick.SetParameters(CreatePickParameters);
                end;
            // P800131478
            WhseStgdPick."Staging Type"::Production:
                // P800131478
                begin
                    Clear(CreatePickParameters);
                    CreatePickParameters."Assigned ID" := AssignedUserID;
                    CreatePickParameters."Sorting Method" := CreatePickParameters."Sorting Method"::None;
                    CreatePickParameters."Max No. of Lines" := 0;
                    CreatePickParameters."Max No. of Source Doc." := 0;
                    CreatePickParameters."Do Not Fill Qty. to Handle" := false;
                    CreatePickParameters."Breakbulk Filter" := false;
                    CreatePickParameters."Per Bin" := false;
                    CreatePickParameters."Per Zone" := false;
                    CreatePickParameters."Whse. Document" := CreatePickParameters."Whse. Document"::Production;
                    CreatePickParameters."Whse. Document Type" := CreatePickParameters."Whse. Document Type"::Pick;
                    CreatePick.SetParameters(CreatePickParameters);
                end;
        // P800131478
        end;
        WhseStagedPickMgmt.ClearAssignedDocumentNos;
        with WhseStgdPickSourceLine do begin
            SetCurrentKey(
              "No.", "Source Type", "Source Subtype", "Source No.",
              "Source Line No.", "Source Subline No.");
            SetRange("No.", WhseStgdPick."No.");
            SetFilter("Qty. Outstanding", '>0');
            if Find('-') then
                repeat
                    CreatePick.RestrictToStagedFromPick(WhseStgdPickSourceLine);
                    CreateWhsePickFromStageLine(WhseStgdPick, WhseStgdPickSourceLine, PickCreated);
                until (Next = 0);
        end;
        exit(CreateWhsePickWithSource(PickCreated, WhseActHeader));
    end;

    local procedure CreateWhsePickFromStageLine(var WhseStgdPick: Record "Whse. Staged Pick Header"; var WhseStgdPickSourceLine: Record "Whse. Staged Pick Source Line"; var PickCreated: Boolean)
    var
        QtyToPickBase: Decimal;
        QtyToPick: Decimal;
        OldQtyToPickBase: Decimal;
        OldQtyToPick: Decimal;
        WhseShptHeader: Record "Warehouse Shipment Header";
        WhseShptLine: Record "Warehouse Shipment Line";
        ProdOrderComp: Record "Prod. Order Component";
        WhseSourceFound: Boolean;
        ToBinCode: Code[20];
    begin
        with WhseStgdPickSourceLine do begin
            TestField("Qty. per Unit of Measure");
            CalcFields("Pick Qty.", "Pick Qty. (Base)");
            QtyToPick := Quantity - ("Qty. Picked" + "Pick Qty.");
            QtyToPickBase := "Qty. (Base)" - ("Qty. Picked (Base)" + "Pick Qty. (Base)");
            if (QtyToPick > 0) then begin
                case WhseStgdPick."Staging Type" of
                    WhseStgdPick."Staging Type"::Shipment:
                        begin
                            WhseShptLine.SetCurrentKey(
                              "Source Type", "Source Subtype", "Source No.", "Source Line No.");
                            WhseShptLine.SetRange("Source Type", "Source Type");
                            WhseShptLine.SetRange("Source Subtype", "Source Subtype");
                            WhseShptLine.SetRange("Source No.", "Source No.");
                            WhseShptLine.SetRange("Source Line No.", "Source Line No.");
                            WhseSourceFound := WhseShptLine.Find('-');
                            if WhseSourceFound then begin
                                WhseShptHeader.Get(WhseShptLine."No.");
                                CreatePick.SetWhseShipment(
                                  WhseShptLine,
                                  WhseStagedPickMgmt.AssignTempDocNo(
                                    WhseStgdPick."Order Picking Options", "Source No."),
                                  WhseShptHeader."Shipping Agent Code", WhseShptHeader."Shipping Agent Service Code",
                                  WhseShptHeader."Shipment Method Code");
                                CreatePick.SetTempWhseItemTrkgLine(
                                  WhseShptLine."No.", DATABASE::"Warehouse Shipment Line", '', 0,
                                  WhseShptLine."Line No.", WhseShptLine."Location Code");
                                ToBinCode := WhseShptLine."Bin Code";
                            end;
                        end;
                    WhseStgdPick."Staging Type"::Production:
                        begin
                            WhseSourceFound := ProdOrderComp.Get(
                              "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
                            if WhseSourceFound then begin
                                CreatePick.SetProdOrderCompLine(
                                  ProdOrderComp,
                                  WhseStagedPickMgmt.AssignTempDocNo(
                                    WhseStgdPick."Order Picking Options", "Source No."));
                                CreatePick.SetTempWhseItemTrkgLine(
                                  ProdOrderComp."Prod. Order No.", DATABASE::"Prod. Order Component",
                                  '', ProdOrderComp."Prod. Order Line No.",
                                  ProdOrderComp."Line No.", ProdOrderComp."Location Code");
                                Location.Get("Location Code");
                                Location.SetToProductionBin(                                                                      // P8001142
                                  ProdOrderComp."Prod. Order No.", ProdOrderComp."Prod. Order Line No.", ProdOrderComp."Line No."); // P8001142
                                Location.TestField("To-Production Bin Code");
                                ToBinCode := Location."To-Production Bin Code";
                            end;
                        end;
                end;
                if WhseSourceFound then begin
                    OldQtyToPickBase := QtyToPickBase;
                    OldQtyToPick := QtyToPick;
                    CreatePick.CreateTempLine(
                      "Location Code", "Item No.", "Variant Code", "Unit of Measure Code",
                      '', ToBinCode, "Qty. per Unit of Measure", QtyToPick, QtyToPickBase);
                    CreatePick.SaveTempItemTrkgLines;
                    if (not PickCreated) and
                       ((QtyToPick <> OldQtyToPick) or (QtyToPickBase <> OldQtyToPickBase))
                    then
                        PickCreated := true;
                end;
            end;
        end;
    end;

    procedure PrintWhsePicksToStage(var WhseStgdPick: Record "Whse. Staged Pick Header"): Boolean
    var
        WhseActLine: Record "Warehouse Activity Line";
    begin
        with WhseActLine do begin
            SetCurrentKey("Whse. Document No.", "Whse. Document Type", "Activity Type");
            SetRange("Whse. Document No.", WhseStgdPick."No.");
            SetRange("Whse. Document Type", "Whse. Document Type"::FOODStagedPick);
            SetRange("Activity Type", "Activity Type"::Pick);
            exit(PrintStagedPicks(WhseActLine));
        end;
    end;

    procedure PrintWhsePicksFromStage(var WhseStgdPick: Record "Whse. Staged Pick Header"): Boolean
    var
        WhseActLine: Record "Warehouse Activity Line";
    begin
        with WhseActLine do begin
            SetCurrentKey("From Staged Pick No.");
            SetRange("From Staged Pick No.", WhseStgdPick."No.");
            exit(PrintStagedPicks(WhseActLine));
        end;
    end;

    local procedure PrintStagedPicks(var WhseActLine: Record "Warehouse Activity Line"): Boolean
    var
        WhseActHeader: Record "Warehouse Activity Header";
    begin
        with WhseActLine do begin
            if not Find('-') then
                exit(false);
            repeat
                WhseActHeader.Get("Activity Type", "No.");
                WhseActHeader.Mark(true);
            until (Next = 0);
            WhseActHeader.MarkedOnly(true);
            REPORT.Run(REPORT::"Picking List", false, false, WhseActHeader);
            exit(true);
        end;
    end;

    procedure RegisterWhsePicksFromStage(var WhseStgdPick: Record "Whse. Staged Pick Header"): Boolean
    var
        WhseActLine: Record "Warehouse Activity Line";
        WhseActHeader: Record "Warehouse Activity Header";
    begin
        with WhseActLine do begin
            SetCurrentKey("From Staged Pick No.");
            SetRange("From Staged Pick No.", WhseStgdPick."No.");
            if not Find('-') then
                exit(false);
            repeat
                WhseActHeader.Get("Activity Type", "No.");
                WhseActHeader.Mark(true);
            until (Next = 0);
            Reset;
        end;
        with WhseActHeader do begin
            MarkedOnly(true);
            Find('-');
            repeat
                WhseActLine.SetRange("Activity Type", Type);
                WhseActLine.SetRange("No.", "No.");
                if WhseActLine.Find('-') then begin
                    WhseActivityRegister.ShowHideDialog(true);
                    WhseActivityRegister.Run(WhseActLine);
                    Clear(WhseActivityRegister);
                end;
            until (Next = 0);
            exit(true);
        end;
    end;

    procedure ShowWhseActHeader(var WhseActHeader: Record "Warehouse Activity Header")
    var
        WhsePutAway: Page "Warehouse Put-away";
        WhsePick: Page "Warehouse Pick";
        WhseMovement: Page "Warehouse Movement";
    begin
        with WhseActHeader do begin
            Reset;
            SetRange("No.", "No.");
            case Type of
                Type::"Put-away":
                    begin
                        WhsePutAway.SetTableView(WhseActHeader);
                        WhsePutAway.RunModal;
                    end;
                Type::Pick:
                    begin
                        WhsePick.SetTableView(WhseActHeader);
                        WhsePick.RunModal;
                    end;
                Type::Movement:
                    begin
                        WhseMovement.SetTableView(WhseActHeader);
                        WhseMovement.RunModal;
                    end;
            end;
        end;
    end;

    procedure SetWhseRegister(NewWhseReg: Record "Warehouse Register")
    begin
        WhseReg := NewWhseReg;
    end;

    procedure GetWhseRegister(var NewWhseReg: Record "Warehouse Register")
    begin
        NewWhseReg := WhseReg;
    end;

    procedure DisableCombineLots(NewCombineLotsDisabled: Boolean)
    begin
        CombineLotsDisabled := NewCombineLotsDisabled; // P8000495A
    end;

    procedure SetSourceCode(NewSourceCode: Code[10])
    begin
        SourceCode := NewSourceCode;
    end;

    local procedure GetSourceCode(): Code[10]
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if (SourceCode = '') then begin
            SourceCodeSetup.Get;
            SourceCode := SourceCodeSetup."Whse. Item Journal";
        end;
        exit(SourceCode);
    end;

    procedure SetAssignedUserID(NewAssignedUserID: Code[20])
    begin
        AssignedUserID := NewAssignedUserID;
    end;

    procedure SetRegisterDate(NewRegisterDate: Date)
    begin
        RegisterDate := NewRegisterDate;
    end;

    procedure UpdateHiddenDocOnDelete(var WhseActLine: Record "Warehouse Activity Line")
    var
        InternalPutAwayHdr: Record "Whse. Internal Put-away Header";
        InternalPickHdr: Record "Whse. Internal Pick Header";
    begin
        with WhseActLine do
            case "Activity Type" of
                "Activity Type"::"Put-away":
                    if ("Whse. Document Type" = "Whse. Document Type"::"Internal Put-away") then
                        if InternalPutAwayHdr.Get("Whse. Document No.") then
                            UpdateHiddenPutAway(InternalPutAwayHdr);
                "Activity Type"::Pick:
                    if ("Whse. Document Type" = "Whse. Document Type"::"Internal Pick") then
                        if InternalPickHdr.Get("Whse. Document No.") then
                            UpdateHiddenPick(InternalPickHdr);
            end;
    end;

    procedure StoreHiddenDocuments(var WhseActLine: Record "Warehouse Activity Line")
    var
        WhseActLine2: Record "Warehouse Activity Line";
    begin
        HiddenPutAway.Reset;
        HiddenPick.Reset;
        with WhseActLine2 do begin
            Copy(WhseActLine);
            if Find('-') then
                repeat
                    case "Activity Type" of
                        "Activity Type"::"Put-away":
                            if ("Whse. Document Type" = "Whse. Document Type"::"Internal Put-away") then
                                if HiddenPutAway.Get("Whse. Document No.") then
                                    if HiddenPutAway."Hidden Put-Away" then
                                        HiddenPutAway.Mark(true);
                        "Activity Type"::Pick:
                            if ("Whse. Document Type" = "Whse. Document Type"::"Internal Pick") then
                                if HiddenPick.Get("Whse. Document No.") then
                                    if HiddenPick."Hidden Pick" then
                                        HiddenPick.Mark(true);
                    end;
                until (Next = 0);
        end;
    end;

    procedure UpdateHiddenDocuments()
    begin
        with HiddenPutAway do begin
            MarkedOnly(true);
            if Find('-') then
                repeat
                    UpdateHiddenPutAway(HiddenPutAway);
                until (Next = 0);
        end;
        with HiddenPick do begin
            MarkedOnly(true);
            if Find('-') then
                repeat
                    UpdateHiddenPick(HiddenPick);
                until (Next = 0);
        end;
    end;

    local procedure UpdateHiddenPutAway(var WhseIntPutAwayHdr: Record "Whse. Internal Put-away Header")
    var
        WhseIntPutAwayLine: Record "Whse. Internal Put-away Line";
    begin
        if WhseIntPutAwayHdr."Hidden Put-Away" then
            with WhseIntPutAwayLine do begin
                SetRange("No.", WhseIntPutAwayHdr."No.");
                if Find('-') then
                    repeat
                        CalcFields("Put-away Qty.");
                        if ("Put-away Qty." = 0) then begin
                            ItemTrackingMgt.DeleteWhseItemTrkgLines(
                              DATABASE::"Whse. Internal Put-away Line", 0,
                              "No.", '', 0, "Line No.", "Location Code", true);
                            Delete;
                        end;
                    until (Next = 0);
                if not Find('-') then begin
                    WhseIntPutAwayHdr.DeleteRelatedLines;
                    WhseIntPutAwayHdr.Delete;
                end;
            end;
    end;

    local procedure UpdateHiddenPick(var WhseIntPickHdr: Record "Whse. Internal Pick Header")
    var
        WhseIntPickLine: Record "Whse. Internal Pick Line";
    begin
        if WhseIntPickHdr."Hidden Pick" then
            with WhseIntPickLine do begin
                SetRange("No.", WhseIntPickHdr."No.");
                if Find('-') then
                    repeat
                        CalcFields("Pick Qty.");
                        if ("Pick Qty." = 0) then begin
                            ItemTrackingMgt.DeleteWhseItemTrkgLines(
                              DATABASE::"Whse. Internal Pick Line", 0,
                              "No.", '', 0, "Line No.", "Location Code", true);
                            Delete;
                        end;
                    until (Next = 0);
                if not Find('-') then begin
                    WhseIntPickHdr.DeleteRelatedLines;
                    WhseIntPickHdr.Delete;
                end;
            end;
    end;

    procedure SetItemPosting(NewItemPosting: Boolean)
    begin
        ItemPosting := NewItemPosting;
    end;

    procedure SetItemPostingDocNo(NewItemPostingDocNo: Code[20])
    begin
        ItemPostingDocNo := NewItemPostingDocNo;
    end;

    local procedure PostItemAdjustment(Qty: Decimal; QtyBase: Decimal)
    var
        OldFromBin: Record Bin;
    begin
        if ItemPosting and (QtyBase <> 0) then begin
            OldFromBin := FromBin;
            if Location."Directed Put-away and Pick" then begin // P8000740
                Location.TestField("Adjustment Bin Code");
                FromBin.Get(Location.Code, Location."Adjustment Bin Code");
                SwapBinsOnPosAdjmt(QtyBase); // P8001056
            end;                                                // P8000740
                                                                // RegisterWhseJnlLine(RegisterMode::"Inventory Adjustment", Qty, QtyBase); // P8001039
            PostItemJnlLine(Qty, QtyBase);
            RegisterWhseJnlLine(RegisterMode::"Inventory Adjustment", Qty, QtyBase);    // P8001039
            FromBin := OldFromBin;
        end;
    end;

    local procedure PostItemJnlLine(Qty: Decimal; QtyBase: Decimal)
    var
        ItemJnlLine: Record "Item Journal Line";
        ResEntry: Record "Reservation Entry";
        AltQtyLine: Record "Alternate Quantity Line";
    begin
        with ItemJnlLine do begin
            Validate("Document No.", ItemPostingDocNo);
            if (RegisterDate <> 0D) then
                Validate("Posting Date", RegisterDate)
            else
                Validate("Posting Date", WorkDate);
            if (Qty > 0) then
                Validate("Entry Type", "Entry Type"::"Positive Adjmt.")
            else
                Validate("Entry Type", "Entry Type"::"Negative Adjmt.");
            Validate("Item No.", Item."No.");
            Validate("Variant Code", ItemVariant.Code);
            Validate("Location Code", Location.Code);
            Validate("Source Code", SourceCode);
            Validate("Unit of Measure Code", ItemUnitOfMeasure.Code);
            Validate(Quantity, Signed(Qty));
            "Quantity (Base)" := Signed(QtyBase);
            "Invoiced Qty. (Base)" := "Quantity (Base)";
            // P8000740
            if not Location."Directed Put-away and Pick" then
                if ("Entry Type" = "Entry Type"::"Positive Adjmt.") then
                    "Bin Code" := ToBin.Code
                else
                    "Bin Code" := FromBin.Code;
            // P8000740
            // P8001134
            "Order Type" := AdditionalOrderInfo."Order Type";
            "Order No." := AdditionalOrderInfo."Order No.";
            "Order Line No." := AdditionalOrderInfo."Order Line No.";
            // P8001134
            // P8000591A
            if Item.TrackAlternateUnits() then begin
                if not Item."Catch Alternate Qtys." then                              // P8000740
                    AdjmtAltQty := Round(QtyBase * Item.AlternateQtyPerBase(), 0.00001); // P8000740
                "Quantity (Alt.)" := Signed(AdjmtAltQty);
                "Invoiced Qty. (Alt.)" := "Quantity (Alt.)";
                if Item."Catch Alternate Qtys." then begin // P8000740
                    AltQtyMgmt.AssignNewTransactionNo("Alt. Qty. Transaction No.");
                    AltQtyLine."Alt. Qty. Transaction No." := "Alt. Qty. Transaction No.";
                    AltQtyLine."Line No." := 10000;
                    AltQtyLine."Table No." := DATABASE::"Item Journal Line";
                    AltQtyLine."Journal Template Name" := "Journal Template Name";
                    AltQtyLine."Journal Batch Name" := "Journal Batch Name";
                    AltQtyLine."Source Line No." := "Line No.";
                    AltQtyLine."Lot No." := LotNoInfo."Lot No.";
                    AltQtyLine."Serial No." := SerialNoInfo."Serial No.";
                    AltQtyLine.Quantity := Abs(QtyBase);
                    AltQtyLine."Quantity (Base)" := Abs(QtyBase);
                    AltQtyLine."Invoiced Qty. (Base)" := AltQtyLine."Quantity (Base)";
                    AltQtyLine."Quantity (Alt.)" := Abs(AdjmtAltQty);
                    AltQtyLine."Invoiced Qty. (Alt.)" := AltQtyLine."Quantity (Alt.)";
                    AltQtyLine.Insert;
                end;                                       // P8000740
            end;
            // P8000591A
            "Override Loose Lot Control" := true; // P8000494A
        end;
        if (LotNoInfo."Lot No." <> '') then
            with ResEntry do begin
                // P80094516
                // if not Find('+') then
                //     "Entry No." := 0;
                Init;
                // P80094516
                "Entry No." := 0; // P80094516
                Positive := (Qty > 0);
                "Item No." := Item."No.";
                "Variant Code" := ItemVariant.Code;
                "Location Code" := Location.Code;
                "Source Type" := DATABASE::"Item Journal Line";
                "Source Subtype" := ItemJnlLine."Entry Type";
                "Source ID" := ItemJnlLine."Journal Template Name";
                "Source Batch Name" := ItemJnlLine."Journal Batch Name";
                "Source Ref. No." := ItemJnlLine."Line No.";
                "Lot No." := LotNoInfo."Lot No.";
                // P80060684
                if (AdditionalOrderInfo."Order Type" = AdditionalOrderInfo."Order Type"::FOODLotCombination) and (AdditionalOrderInfo."Order No." = "Lot No.") then
                    "Expiration Date" := AdditionalOrderInfo."Expiration Date";
                // P80060684
                "Reservation Status" := "Reservation Status"::Prospect;
                Quantity := Qty;
                "Quantity (Base)" := QtyBase;
                "Qty. to Handle (Base)" := QtyBase;
                "Qty. to Invoice (Base)" := QtyBase;
                // P8000591A
                if Item.TrackAlternateUnits() then begin
                    "Quantity (Alt.)" := AdjmtAltQty;
                    "Qty. to Handle (Alt.)" := AdjmtAltQty;
                    "Qty. to Invoice (Alt.)" := AdjmtAltQty;
                end;
                // P8000591A
                "Qty. per Unit of Measure" := ItemUnitOfMeasure."Qty. per Unit of Measure";
                Insert;
            end;

        ItemJnlPostLine.Run(ItemJnlLine);
    end;

    procedure SetAdjmtAltQty(NewAdjmtAltQty: Decimal)
    begin
        AdjmtAltQty := NewAdjmtAltQty; // P8000591A
    end;

    procedure GetRegisters(var ItemReg2: Record "Item Register"; var ItemApplnEntryNo2: Integer; var WhseReg2: Record "Warehouse Register"; var GLReg2: Record "G/L Register"; var NextVATEntryNo2: Integer; var NextTransactionNo2: Integer)
    begin
        // P8000888
        ItemJnlPostLine.GetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2, WhseJnlRegisterLine);  //P80045166
        GetWhseRegister(WhseReg2);
    end;

    procedure SetRegisters(var ItemReg2: Record "Item Register"; ItemApplnEntryNo2: Integer; var WhseReg2: Record "Warehouse Register"; var GLReg2: Record "G/L Register"; NextVATEntryNo2: Integer; NextTransactionNo2: Integer)
    begin
        // P8000888
        ItemJnlPostLine.SetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
        SetWhseRegister(WhseReg2);
    end;

    local procedure XferRegsToWhse()
    var
        ItemReg2: Record "Item Register";
        ItemApplnEntryNo2: Integer;
        WhseReg2: Record "Warehouse Register";
        GLReg2: Record "G/L Register";
        NextVATEntryNo2: Integer;
        NextTransactionNo2: Integer;
    begin
        // P8000888
        GetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
        WhseJnlRegisterLine.SetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
    end;

    local procedure XferRegsFromWhse()
    var
        ItemReg2: Record "Item Register";
        ItemApplnEntryNo2: Integer;
        WhseReg2: Record "Warehouse Register";
        GLReg2: Record "G/L Register";
        NextVATEntryNo2: Integer;
        NextTransactionNo2: Integer;
    begin
        // P8000888
        WhseJnlRegisterLine.GetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
        SetRegisters(ItemReg2, ItemApplnEntryNo2, WhseReg2, GLReg2, NextVATEntryNo2, NextTransactionNo2);
    end;

    local procedure XferWhseRoundingAdjmts()
    var
        TempWhseAdjmtLine: Record "Warehouse Journal Line" temporary;
    begin
        // P8001039
        if ItemJnlPostLine.GetWhseRoundingAdjmts(TempWhseAdjmtLine) then begin
            ItemJnlPostLine.ClearWhseRoundingAdjmts;
            RoundingAdjmtMgmt.SetWhseAdjmts(TempWhseAdjmtLine);
            WhseJnlRegisterLine.SetWhseRoundingAdjmts(TempWhseAdjmtLine);
        end;
    end;

    local procedure PostWhseRoundingAdjmts()
    var
        WhseJnlLine: Record "Warehouse Journal Line";
    begin
        // P8001039
        if RoundingAdjmtMgmt.WhseAdjmtsToPost() then begin
            WhseJnlRegisterLine.ClearWhseRoundingAdjmts;
            repeat
                RoundingAdjmtMgmt.BuildWhseAdjmtJnlLine(WhseJnlLine);
                WhseJnlRegisterLine.Run(WhseJnlLine);
            until (not RoundingAdjmtMgmt.WhseAdjmtsToPost());
        end;
    end;

    local procedure SwapBinsOnPosAdjmt(Qty: Decimal)
    var
        TempBin: Record Bin;
    begin
        // P8001056
        if (Qty > 0) then begin
            TempBin := ToBin;
            ToBin := FromBin;
            FromBin := TempBin;
        end;
    end;

    procedure SetSourceInfo(NewSourceType: Integer; NewSourceSubtype: Integer; NewSourceNo: Code[20]; NewSourceLineNo: Integer; FromContainerID: Code[20]; ToContainerID: Code[20])
    begin
        // P8001082
        AdditionalInfo."Source Type" := NewSourceType;
        AdditionalInfo."Source Subtype" := NewSourceSubtype;
        AdditionalInfo."Source No." := NewSourceNo;
        AdditionalInfo."Source Line No." := NewSourceLineNo;
        // P80057829
        AdditionalInfo."From Container ID" := FromContainerID;
        AdditionalInfo."To Container ID" := ToContainerID;
        // P80057829
    end;

    procedure SetSourceOrderInfo(NewSourceOrderType: Option; NewSourceOrderNo: Code[20]; NewSourceOrderLineNo: Integer)
    begin
        // P8001134
        AdditionalOrderInfo."Order Type" := NewSourceOrderType;
        AdditionalOrderInfo."Order No." := NewSourceOrderNo;
        AdditionalOrderInfo."Order Line No." := NewSourceOrderLineNo;
    end;

    procedure StartLotCombination(NewLotNo: Code[50]; NewExpDate: Date)
    begin
        // P80060684 - add parameter for NexExpDate
        SetSourceOrderInfo(AdditionalOrderInfo."Order Type"::FOODLotCombination, NewLotNo, 0); // P8001134
        AdditionalOrderInfo."Expiration Date" := NewExpDate; // P80060684
    end;

    procedure EndLotCombination()
    begin
        SetSourceOrderInfo(0, '', 0); // P8001134
        AdditionalOrderInfo."Expiration Date" := 0D; // P80060684
    end;

    procedure RegisterUOMConvFromSpec()
    begin
        // P8001347
        with TempSpecification do begin
            Reset;
            FindSet;
            repeat
                CheckParameters(
                  "Location Code", "From Bin Code", "To Bin Code", false,
                  "Item No.", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.");
                RegisterWhseJnlLine(RegisterMode::"UOM Conversion", Quantity, "Qty. (Base)");
            until (Next = 0);
        end;
        ClearSpecification;
    end;

    procedure RepickWhsePickForShptLine(var CurrRec: Record "Warehouse Activity Line"; var WhseActLine: Record "Warehouse Activity Line"): Boolean
    var
        WhseActHeader: Record "Warehouse Activity Header";
        WhseActLine2: Record "Warehouse Activity Line";
        WhseShptHeader: Record "Warehouse Shipment Header";
        WhseShptLine: Record "Warehouse Shipment Line";
        PickCreated: Boolean;
        TempWhseItemTrkgLine: Record "Whse. Item Tracking Line" temporary;
    begin
        // P8001347
        Clear(CreatePick);
        // P800131478
        Clear(CreatePickParameters);
        CreatePickParameters."Assigned ID" := AssignedUserID;
        CreatePickParameters."Sorting Method" := CreatePickParameters."Sorting Method"::None;
        CreatePickParameters."Max No. of Lines" := 0;
        CreatePickParameters."Max No. of Source Doc." := 0;
        CreatePickParameters."Do Not Fill Qty. to Handle" := false;
        CreatePickParameters."Breakbulk Filter" := false;
        CreatePickParameters."Per Bin" := false;
        CreatePickParameters."Per Zone" := false;
        CreatePickParameters."Whse. Document" := CreatePickParameters."Whse. Document"::Shipment;
        CreatePickParameters."Whse. Document Type" := CreatePickParameters."Whse. Document Type"::Pick;
        CreatePick.SetParameters(CreatePickParameters);
        // P800131478
        CreatePick.SetDisableRemQtyLine(true);
        CreatePick.ClearTempPickExclusions;
        with WhseActLine do begin
            SetRange("Action Type", "Action Type"::Take);
            FindSet;
            repeat
                TestField("Bin Code");
                TestField("Whse. Document Type", "Whse. Document Type"::Shipment);
                TestField("Whse. Document No.");
                TestField("Whse. Document Line No.");
                CreatePick.AddTempExclusion(
                  "Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code", "Lot No.", "Container Qty.");
                WhseActLine2 := WhseActLine;
                WhseActLine2.SetRange("Activity Type", "Activity Type");
                WhseActLine2.SetRange("No.", "No.");
                WhseActLine2.SetFilter("Line No.", '>%1', "Line No.");
                WhseActLine2.SetRange("Action Type", "Action Type"::Place);
                WhseActLine2.SetRange("First Container Line No.", "First Container Line No.");
                WhseActLine2.FindFirst;
                WhseActLine2.TestField("Source Type", "Source Type");
                WhseActLine2.TestField("Source Subtype", "Source Subtype");
                WhseActLine2.TestField("Source No.", "Source No.");
                WhseActLine2.TestField("Source Line No.", "Source Line No.");
                WhseActLine2.TestField("Source Subline No.", "Source Subline No.");
                WhseActLine2.TestField("Whse. Document No.", "Whse. Document No.");
                WhseActLine2.TestField("Whse. Document Line No.", "Whse. Document Line No.");
                WhseActLine2.TestField(Quantity, Quantity);
                WhseActLine2.Delete;
                Delete;
                WhseShptLine.Get("Whse. Document No.", "Whse. Document Line No.");
                WhseShptLine.Mark(true);
            until (Next = 0);
        end;
        with WhseShptLine do begin
            MarkedOnly(true);
            if FindSet then
                repeat
                    WhseShptHeader.Get("No.");
                    CreateShptWhsePickLine(WhseShptHeader, WhseShptLine, PickCreated);
                until (Next = 0);
        end;
        WhseActHeader.Get(CurrRec."Activity Type", CurrRec."No.");
        with WhseActLine2 do begin
            Reset;
            SetRange("Activity Type", CurrRec."Activity Type");
            SetRange("No.", CurrRec."No.");
            if not FindLast then
                "Line No." := 0;
            CreatePick.AddToWhsePick(WhseActHeader, true);
            CreatePick.ReturnTempItemTrkgLines(TempWhseItemTrkgLine);
            ItemTrackingMgt.UpdateWhseItemTrkgLines(TempWhseItemTrkgLine);
            SetFilter("Line No.", '>%1', "Line No.");
            if FindFirst then
                CurrRec := WhseActLine2;
            exit(true);
        end;
    end;

    procedure SetMoveContainer()
    begin
        // P80056710
        OnBeforeSetMoveContainer(); // P80079197
        MoveContainer := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetMoveContainer()
    begin
        // P80079197
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRegisterMoveFromSpecification(var TempSpecification: Record "Warehouse Journal Line" temporary; var Handled: Boolean)
    begin
        // P80079197
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegisterMoveFromSpecification()
    begin
        // P80079197
    end;

    [IntegrationEvent(false, false)]
    local procedure OnWhseJnlRegisterLineOnBeforeWhseJnlRegisterLine(var WarehouseJournalLine: Record "Warehouse Journal Line")
    begin
        // P80082969
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterClearSpecification()
    begin
        // P80082969
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddToTempSpecification(var TempSpecification: Record "Warehouse Journal Line"; Qty: Decimal; QtyBase: Decimal)
    begin
        // P80092182    
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBuildBinContentsSpecification(var BinContent: Record "Bin Content"; var TempSpecification: Record "Warehouse Journal Line")
    begin
        // P80092182    
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRegisterMoveFromSpecificationRegisterMoveBase(var TempSpecification: Record "Warehouse Journal Line")
    begin
        // P80092182    
    end;
}

