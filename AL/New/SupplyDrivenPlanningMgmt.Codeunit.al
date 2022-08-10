codeunit 37002602 "Supply Driven Planning Mgmt."
{
    // PRW16.00.03
    // P8000793, VerticalSoft, Don Bresee, 12 APR 10
    //   Support for new NAV 2009 interface
    // 
    // P8000828, VerticalSoft, Don Bresee, 03 JUN 10
    //   Consolidate timer logic
    // 
    // PRW16.00.05
    // P8000940, Columbus IT, Jack Reynolds, 07 NOV 11
    //   RemoveTimer control and add Signal control
    // 
    // PRW16.00.06
    // P8001092, Columbus IT, Don Bresee, 11 SEP 12
    //   Add/rework logic to handle Location and Variant Code
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW18.00
    // P8001360, Columbus IT, Jack Reynolds, 06 NOV 14
    //   Update .NET variable references
    // 
    // PRW18.00.01
    // P8001367, Columbus IT, Jack Reynolds, 09 JAN 15
    //   Fix problem with package demand in base units
    // 
    // PRW18.00.01
    // P8001386, Columbus IT, Jack Reynolds, 27 MAY 15
    //    Renamed NAV Food client addins
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 31 MAR 16
    //   Update add-in assembly version references
    // 
    // PRW10.0
    // P8007755, To-Increase, Jack Reynolds, 22 NOV 16
    //   Update add-in assembly version references
    // 
    // P8007748, To-Increase, Jack Reynolds, 06 DEC 16
    //   NAV 2017 upgrade
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Upgrade signal control for JavaScript
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00


    trigger OnRun()
    begin
    end;

    var
        ProcessOrderMgmt: Codeunit "Process Order Management";
        VersionMgmt: Codeunit VersionManagement;
        RMItem: Record Item;
        ProcessBOMLine: Record "Production BOM Line";
        ProcessBOMBatchFactor: Decimal;
        FamilyLine: Record "Family Line";
        Location: Record Location;
        RMVariant: Record "Item Variant";
        Text000: Label 'Locating Available Raw Materials...\\Item No. #1##################';
        LotStatus: Record "Lot Status Code";
        LotStatusMgmt: Codeunit "Lot Status Management";
        LotStatusExclusionFilter: Text[1024];
        SupplyDaysView: Integer;
        SupplyEndDate: Date;
        DemandDaysView: Integer;
        DemandEndDate: Date;
        DemandForecastName: Code[10];
        ProcessSetup: Record "Process Setup";
        P800Functions: Codeunit "Process 800 Functions";
        TempPkgBOMLine: Record "Production BOM Line" temporary;
        SignalFns: Codeunit "Process 800 Signal Functions";

    procedure GetMainPageQtys(ItemNo: Code[20]; VariantCode: Code[10]; var CurrReqQty: Decimal; var MaxReqQty: Decimal)
    begin
        // P8001092
        // Remove Item2 record parameter, add Item No. and Variant Code
        /*
        WITH Item2 DO BEGIN
          CurrReqQty := ProcessOrderMgmt.GetProcessRequestQty(0,"No.");
          CALCFIELDS(Inventory,"Qty. on Component Lines");
          MaxReqQty := Inventory - "Qty. on Component Lines";
        END;
        */
        //
        CurrReqQty := ProcessOrderMgmt.GetProcessRequestQty(0, ItemNo, VariantCode);
        MaxReqQty := CalcRawMatSupplyQty(ItemNo, VariantCode);
        // P8001092

    end;

    procedure ProcessPageFind(var ProcessBOMLine2: Record "Production BOM Line"; Which: Text[30]): Boolean
    var
        ItemNo: Code[20];
    begin
        // P8001092
        /*
        ProcessBOMLine2.FILTERGROUP(4);
        ItemNo := ProcessBOMLine2.GETFILTER("No.");
        ProcessBOMLine2.FILTERGROUP(0);
        IF (RMItem."No." <> ItemNo) THEN BEGIN
          IF NOT RMItem.GET(ItemNo) THEN
            CLEAR(RMItem);
          CLEAR(ProcessBOMLine);
          CLEAR(FamilyLine);
        END;
        */
        //
        ProcessBOMLine2.FilterGroup(4);
        ProcessBOMLine2.CopyFilter("No.", RMItem."No.");
        ProcessBOMLine2.CopyFilter("No.", RMVariant."Item No.");
        ProcessBOMLine2.CopyFilter("Variant Code", RMVariant.Code);
        ProcessBOMLine2.FilterGroup(0);
        if not RMItem.FindFirst then
            Clear(RMItem);
        if not RMVariant.FindFirst then
            Clear(RMVariant);
        // P8001092
        exit(ProcessOrderMgmt.ProdBOMLineFind(ProcessBOMLine2, Which));

    end;

    procedure GetProcessPageQtys(var ProcessBOMLine2: Record "Production BOM Line"; var CurrReqQty: Decimal; var MaxReqQty: Decimal)
    var
        RMCurrReqQty: Decimal;
        RMMaxReqQty: Decimal;
    begin
        ProcessOrderMgmt.LoadProcessRequestQty(0, ProcessBOMLine2, CurrReqQty);
        // GetMainPageQtys(RMItem,RMCurrReqQty,RMMaxReqQty);                   // P8001092
        GetMainPageQtys(RMItem."No.", RMVariant.Code, RMCurrReqQty, RMMaxReqQty); // P8001092
        MaxReqQty := Round(RMMaxReqQty - (RMCurrReqQty - CurrReqQty), 0.00001);
    end;

    procedure SaveProcessPageQty(var ProcessBOMLine2: Record "Production BOM Line"; CurrReqQty: Decimal)
    begin
        ProcessOrderMgmt.SaveProcessRequestQty(0, ProcessBOMLine2, RMItem."Base Unit of Measure", CurrReqQty);
        Clear(ProcessBOMLine);
        UpdateMainPage; // P8000940
    end;

    local procedure GetProcessBOMBatchFactor(): Decimal
    begin
        if (ProcessBOMLine."Production BOM No." = '') then
            exit(1);
        exit(ProcessBOMBatchFactor);
    end;

    procedure GetOutputPageQtys(var FamilyLine2: Record "Family Line"; var CurrReqQty: Decimal; var MaxReqQty: Decimal): Decimal
    begin
        CurrReqQty := ProcessOrderMgmt.GetPackageRequestQty(0, ProcessBOMLine, FamilyLine2."Line No.");
        MaxReqQty := FamilyLine2.Quantity * GetProcessBOMBatchFactor();
    end;

    procedure GetPackagePageQtys(var TempRequestLine: Record "Process Order Request Line" temporary; var CurrReqQty: Decimal; var MaxReqQty: Decimal)
    var
        PackageBOMLine: Record "Production BOM Line";
        Item: Record Item;
        OPCurrReqQty: Decimal;
        OPMaxReqQty: Decimal;
    begin
        // P8001092 - Change parameters
        // P8001092
        /*
        Item.SETCURRENTKEY("Production BOM No.");
        Item.SETRANGE("Production BOM No.",PackageBOMLine."Production BOM No.");
        IF Item.FIND('-') AND (FamilyLine."Line No." <> 0) THEN BEGIN
          ItemNo := Item."No.";
          ItemDescription := Item.Description;
          ProcessOrderMgmt.LoadPackageRequestQty(0,ProcessBOMLine,FamilyLine."Line No.",PackageBOMLine,CurrReqQty);
          GetOutputPageQtys(FamilyLine,OPCurrReqQty,OPMaxReqQty);
          MaxReqQty := OPMaxReqQty - (OPCurrReqQty - CurrReqQty);
          CurrReqQty :=
            ROUND(PackageBOMLine.GetPackageOutputQty(FamilyLine."Unit of Measure Code",CurrReqQty),0.00001);
          MaxReqQty :=
            ROUND(PackageBOMLine.GetPackageOutputQty(FamilyLine."Unit of Measure Code",MaxReqQty),0.00001);
        END ELSE BEGIN
          ItemNo := PackageBOMLine."Production BOM No.";
          PackageBOMLine.CALCFIELDS("Prod. BOM Description");
          ItemDescription := PackageBOMLine."Prod. BOM Description";
          CurrReqQty := 0;
          MaxReqQty := 0;
        END;
        */
        //
        with TempRequestLine do begin
            if not PackageBOMLine.Get("Package BOM No.", VersionMgmt.GetBOMVersion("Package BOM No.", WorkDate, true), "Package BOM Line No.") then // P8007748
                exit;                                                                                                                             // P8007748
            ProcessOrderMgmt.LoadPackageRequestQty(
              0, ProcessBOMLine, FamilyLine."Line No.", PackageBOMLine, "Finished Item No.", "Finished Variant Code", CurrReqQty);
        end;
        GetOutputPageQtys(FamilyLine, OPCurrReqQty, OPMaxReqQty);
        MaxReqQty := OPMaxReqQty - (OPCurrReqQty - CurrReqQty);
        with PackageBOMLine do begin
            CurrReqQty := Round(GetPackageOutputQty(FamilyLine."Unit of Measure Code", CurrReqQty), 0.00001);
            MaxReqQty := Round(GetPackageOutputQty(FamilyLine."Unit of Measure Code", MaxReqQty), 0.00001);
        end;
        // P8001092

    end;

    procedure SavePackagePageQty(var TempRequestLine: Record "Process Order Request Line" temporary; CurrReqQty: Decimal)
    var
        PackageBOMLine: Record "Production BOM Line";
        RMToOutputFactor: Decimal;
    begin
        // P8001092 - Change parameters
        // P8001092
        with TempRequestLine do
            PackageBOMLine.Get(
              "Package BOM No.", VersionMgmt.GetBOMVersion("Package BOM No.", WorkDate, true), "Package BOM Line No.");
        // P8001092
        RMToOutputFactor := PackageBOMLine.GetPackageOutputQty(FamilyLine."Unit of Measure Code", 1);
        if (RMToOutputFactor = 0) then
            RMToOutputFactor := 1;
        ProcessOrderMgmt.SavePackageRequestQty(
          0, ProcessBOMLine, FamilyLine."Line No.", PackageBOMLine,
          TempRequestLine."Finished Item No.", TempRequestLine."Finished Variant Code", // P8001092
          FamilyLine."Unit of Measure Code", CurrReqQty / RMToOutputFactor, CurrReqQty);
        UpdateMainPage; // P8000940
    end;

    procedure PageNext(var ProdBOMLine2: Record "Production BOM Line"; NumSteps: Integer): Integer
    begin
        exit(ProcessOrderMgmt.ProdBOMLineNext(ProdBOMLine2, NumSteps));
    end;

    // procedure SetSignalControl(ID: Text[50]; Control: DotNet ISignalWebControlAddIn)
    // begin
    //     // P8000940
    //     SignalFns.SetControl(1, ID, Control); // P80059471
    // end;

    procedure UpdateMainPage()
    begin
        // P8000940
        SignalFns.Signal(1); // P80059471
    end;

    procedure SetLocation(var TempProdComp: Record "Prod. Order Component" temporary; var LocationCode: Code[10])
    begin
        // P8001092
        if not Location.Get(LocationCode) then begin
            Clear(Location);
            Clear(LocationCode);
        end;
        LoadLocation;
        LoadRawMaterials(TempProdComp);
    end;

    procedure ValidateLocation(var TempProdComp: Record "Prod. Order Component" temporary; var LocationCode: Code[10])
    var
        RefreshRawMaterials: Boolean;
    begin
        // P8001092
        if (LocationCode <> Location.Code) then begin
            RefreshRawMaterials := (LocationCode = '') or (Location.Code = '');
            if (LocationCode = '') then
                Clear(Location)
            else
                Location.Get(LocationCode);
            LoadLocation;
            if RefreshRawMaterials then
                LoadRawMaterials(TempProdComp);
        end;
    end;

    local procedure LoadLocation()
    begin
        // P8001092
        ProcessOrderMgmt.SetLocationCode(Location.Code);
        LotStatusExclusionFilter :=
          LotStatusMgmt.SetLotStatusExclusionFilter(LotStatus.FieldNo("Available for Planning"));
    end;

    local procedure LoadRawMaterials(var TempProdComp: Record "Prod. Order Component" temporary)
    var
        ProdBOMLine: Record "Production BOM Line";
        TempProdCompLineNo: Integer;
        Item: Record Item;
        StatusWindow: Dialog;
        StatusWindowOpen: Boolean;
        NextUpdateTime: DateTime;
    begin
        // P8001092
        TempProdComp.Reset;
        TempProdComp.DeleteAll;
        if (Location.Code <> '') then begin
            TempProdComp.SetCurrentKey("Item No.", "Variant Code");
            with ProdBOMLine do begin
                SetCurrentKey(Type, "No.");
                SetRange(Type, Type::Item);
                SetFilter("No.", '<>%1', '');
                SetRange("Prod. BOM Type", "Prod. BOM Type"::Process);
                SetRange("Prod. BOM Output Type", "Prod. BOM Output Type"::Family);
                NextUpdateTime := CurrentDateTime + 1000;
                if FindSet then begin
                    repeat
                        if (CurrentDateTime >= NextUpdateTime) then begin
                            if not StatusWindowOpen then begin
                                StatusWindow.Open(Text000);
                                StatusWindowOpen := true;
                            end;
                            StatusWindow.Update(1, "No.");
                            NextUpdateTime := CurrentDateTime + 100;
                        end;
                        TempProdComp.SetRange("Item No.", "No.");
                        TempProdComp.SetRange("Variant Code", "Variant Code");
                        if not TempProdComp.FindFirst then begin
                            TempProdCompLineNo := TempProdCompLineNo + 1;
                            TempProdComp."Line No." := TempProdCompLineNo;
                            TempProdComp."Item No." := "No.";
                            TempProdComp."Variant Code" := "Variant Code";
                            TempProdComp."Location Code" := Location.Code;
                            Item.Get("No.");
                            TempProdComp.Description := Item.Description;
                            TempProdComp."Unit of Measure Code" := Item."Base Unit of Measure";
                            TempProdComp.Insert;
                        end;
                    until (Next = 0);
                    TempProdComp.SetRange("Item No.");
                    TempProdComp.SetRange("Variant Code");
                    TempProdComp.FindSet;
                    if StatusWindowOpen then
                        StatusWindow.Close;
                end;
            end;
        end;
    end;

    procedure SetSupplyDaysView(NewDaysView: Integer; var NewEndDate: Date)
    begin
        // P8001092
        SupplyDaysView := NewDaysView;
        SupplyEndDate := WorkDate + SupplyDaysView;
        NewEndDate := SupplyEndDate;
    end;

    procedure SetSupplyEndDate(NewEndDate: Date; var NewDaysView: Integer)
    begin
        // P8001092
        SupplyEndDate := NewEndDate;
        SupplyDaysView := SupplyEndDate - WorkDate;
        NewDaysView := SupplyDaysView;
    end;

    procedure SetDemandDaysView(NewDaysView: Integer; var NewEndDate: Date)
    begin
        // P8001092
        DemandDaysView := NewDaysView;
        DemandEndDate := WorkDate + DemandDaysView;
        NewEndDate := DemandEndDate;
    end;

    procedure SetDemandEndDate(NewEndDate: Date; var NewDaysView: Integer)
    begin
        // P8001092
        DemandEndDate := NewEndDate;
        DemandDaysView := DemandEndDate - WorkDate;
        NewDaysView := DemandDaysView;
    end;

    procedure SetDemandForecastName(NewForecastName: Code[10])
    begin
        // P8001092
        DemandForecastName := NewForecastName;
        ProcessSetup.Get;
    end;

    procedure GetDefaultForecastName(var NewForecastName: Code[10])
    var
        MfgSetup: Record "Manufacturing Setup";
    begin
        // P8001092
        MfgSetup.Get;
        NewForecastName := MfgSetup."Current Production Forecast";
    end;

    local procedure CalcRawMatSupplyQty(ItemNo: Code[20]; VariantCode: Code[10]) RawMatQty: Decimal
    var
        Item: Record Item;
        ExcludePurch: Boolean;
        ExcludeSalesRet: Boolean;
        ExcludeOutput: Boolean;
    begin
        // P8001092
        with Item do begin
            if not Get(ItemNo) then // P8007748
                exit;                 // P8007748
            SetRange("Variant Filter", VariantCode);
            SetRange("Location Filter", Location.Code);
            SetRange("Date Filter", 0D, SupplyEndDate);
            CalcFields(
              Inventory, "Qty. on Purch. Order", "Qty. in Transit", "Trans. Ord. Receipt (Qty.)",
              "Qty. on Sales Order", "Qty. on Component Lines", "Trans. Ord. Shipment (Qty.)");
            LotStatusMgmt.SetInboundExclusions(
              Item, LotStatus.FieldNo("Available for Planning"), ExcludePurch, ExcludeSalesRet, ExcludeOutput);
            LotStatusMgmt.AdjustItemFlowFields(
              Item, LotStatusExclusionFilter, true, true, 0, ExcludePurch, ExcludeSalesRet, ExcludeOutput);
            RawMatQty :=
              Inventory + "Qty. on Purch. Order" + "Qty. in Transit" + "Trans. Ord. Receipt (Qty.)" -
              "Qty. on Sales Order" - "Qty. on Component Lines" - "Trans. Ord. Shipment (Qty.)";
            if (RawMatQty < 0) then
                RawMatQty := 0;
        end;
    end;

    procedure CalcPackageDemandQty(ItemNo: Code[20]; VariantCode: Code[10]): Decimal
    var
        Item: Record Item;
        QuickPlannerLine: Record "Quick Planner Worksheet";
        BOMVersion: Record "Production BOM Version";
        ItemUOM: Record "Item Unit of Measure";
        VersionMgmt: Codeunit VersionManagement;
        EarliestForecastDate: Date;
        BOMNo: Code[20];
    begin
        // P8001092
        if ItemNo = '' then // P8007748
            exit;             // P8007748
        Item.Get(ItemNo);
        with QuickPlannerLine do begin
            Reset;
            "User ID" := UserId;
            "Item No." := ItemNo;
            "Variant Code" := VariantCode;
            "Item Description" := Item.Description;
            "Unit of Measure Code" := Item."Base Unit of Measure";
            "Production Forecast Name" := DemandForecastName;
            SetRange("Date Filter", WorkDate, DemandEndDate);
            SetRange("Location Filter", Location.Code);
            SetRange("Production Forecast Name", DemandForecastName);
            if (Format(ProcessSetup."Forecast Time Fence") <> '') then
                EarliestForecastDate := CalcDate(ProcessSetup."Forecast Time Fence", WorkDate)
            else
                EarliestForecastDate := WorkDate;
            Calculate(P800Functions.ForecastInstalled(), EarliestForecastDate, LotStatusExclusionFilter);
            if ("Suggested Quantity" > 0) then begin // P8001367
                                                     // P8001367
                BOMNo := Item.ProductionBOMNo(VariantCode, Location.Code);
                ItemUOM.Get(ItemNo, VersionMgmt.GetBOMUnitOfMeasure(BOMNo, VersionMgmt.GetBOMVersion(BOMNo, WorkDate, true)));
                "Suggested Quantity" := Round("Suggested Quantity" / ItemUOM."Qty. per Unit of Measure", 0.00001);
                // P8001367
                exit("Suggested Quantity");
            end;                                     // P8001367
        end;
    end;

    procedure OutputPageBuild(var TempRequestLine: Record "Process Order Request Line" temporary; Which: Text[1024]): Boolean
    var
        OldRequestLine: Record "Process Order Request Line";
        FamilyLine2: Record "Family Line";
        RMQty: Decimal;
    begin
        // P8001092
        OldRequestLine.Copy(TempRequestLine);
        with TempRequestLine do begin
            Clear(ProcessBOMLine); // P8007748
            FilterGroup(4);
            CopyFilter("Process BOM No.", ProcessBOMLine."Production BOM No.");
            CopyFilter("Process BOM Line No.", ProcessBOMLine."Line No.");
            FilterGroup(0);
            ProcessBOMLine.SetRange("Version Code", VersionMgmt.GetBOMVersion(ProcessBOMLine.GetRangeMax("Production BOM No."), WorkDate, true)); // P8007748
            if not ProcessBOMLine.FindFirst then
                Clear(ProcessBOMLine)
            else begin
                ProcessOrderMgmt.LoadProcessRequestQty(0, ProcessBOMLine, RMQty);
                ProcessBOMBatchFactor := ProcessBOMLine.GetProcessOutputQty(RMItem."Base Unit of Measure", RMQty);
            end;
            Reset;
            DeleteAll;
            FamilyLine2.SetRange("Family No.", ProcessBOMLine."Production BOM No.");
            if FamilyLine2.FindSet then
                repeat
                    "Process BOM No." := ProcessBOMLine."Production BOM No.";
                    "Process BOM Line No." := ProcessBOMLine."Line No.";
                    "Output Family Line No." := FamilyLine2."Line No.";
                    "Item No." := FamilyLine2."Item No.";
                    "Variant Code" := FamilyLine2."Variant Code";
                    "Unit of Measure Code" := FamilyLine2."Unit of Measure Code";
                    Insert;
                until (FamilyLine2.Next = 0);
            Copy(OldRequestLine);
            exit(Find(Which));
        end;
    end;

    procedure PackagePageBuild(var TempRequestLine: Record "Process Order Request Line" temporary; Which: Text[1024]): Boolean
    var
        OldRequestLine: Record "Process Order Request Line";
        PkgBOMLine: Record "Production BOM Line";
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
    begin
        // P8001092
        OldRequestLine.Copy(TempRequestLine);
        with TempRequestLine do begin
            FilterGroup(4);
            CopyFilter("Process BOM No.", FamilyLine."Family No.");
            CopyFilter("Output Family Line No.", FamilyLine."Line No.");
            FilterGroup(0);
            if not FamilyLine.FindFirst then
                Clear(FamilyLine);
            Reset;
            DeleteAll;
            Item.SetCurrentKey("Production BOM No.");
            SKU.SetCurrentKey("Production BOM No.");
            SKU.SetRange("Location Code", Location.Code);
            with PkgBOMLine do begin
                SetCurrentKey(Type, "No.");
                SetRange(Type, Type::Item);
                SetRange("Prod. BOM Type", "Prod. BOM Type"::BOM);
                SetRange("No.", FamilyLine."Item No.");
                SetRange("Variant Code", FamilyLine."Variant Code");
            end;
            if ProcessOrderMgmt.ProdBOMLineFind(PkgBOMLine, '-') then
                repeat
                    "Process BOM No." := ProcessBOMLine."Production BOM No.";
                    "Process BOM Line No." := ProcessBOMLine."Line No.";
                    "Output Family Line No." := FamilyLine."Line No.";
                    "Package BOM No." := PkgBOMLine."Production BOM No.";
                    "Package BOM Line No." := PkgBOMLine."Line No.";
                    Item.SetRange("Production BOM No.", PkgBOMLine."Production BOM No.");
                    if Item.FindSet then
                        repeat
                            "Finished Item No." := Item."No.";
                            "Finished Variant Code" := '';
                            Insert;
                        until (Item.Next = 0);
                    SKU.SetRange("Production BOM No.", PkgBOMLine."Production BOM No.");
                    if SKU.FindSet then
                        repeat
                            "Finished Item No." := SKU."Item No.";
                            "Finished Variant Code" := SKU."Variant Code";
                            Insert;
                        until (SKU.Next = 0);
                until (ProcessOrderMgmt.ProdBOMLineNext(PkgBOMLine, 1) = 0);
            Copy(OldRequestLine);
            exit(Find(Which));
        end;
    end;
}

