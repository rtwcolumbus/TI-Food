codeunit 37002600 "Process Order Management"
{
    // PR3.60
    //   Management of process orders
    // 
    // PR3.70.06
    // P8000110A, Myers Nissi, Jack Reynolds, 09 SEP 04
    //   Modify to allow specification of location and dimensions when creating orders
    // 
    // PR3.70.10
    // P8000209A, Myers Nissi, Jack Reynolds, 10 MAY 05
    //   Forward flush components for released orders
    // 
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 22 SEP 05
    //   CreatePackageOrder - re-read produciton order line record after calculating the order
    // 
    // PRW15.00.01
    // P8000518A, VerticalSoft, Jack Reynolds, 14 SEP 07
    //   CreateFamilyOrder - check for non-blank location if Location Mandatory is set
    // 
    // PRW16.00.05
    // P8000961, Columbus IT, Jack Reynolds, 28 JUN 11
    //   Fix problem not creating supply driven planning orders
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // P8001092, Columbus IT, Don Bresee, 11 SEP 12
    //   Add Variant and Location Code to Process Order requests/creation
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.10.02
    // P8001301, Columbus IT, Jack Reynolds, 03 MAR 14
    //   Update Rollup 4
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 08 MAR 16
    //   Expand BOM Version code to Code20
    // 
    // PRW19.00.01
    // P8008053, To-Increase, Dayakar Battini, 23 NOV 16
    //   Adding Equipment Code to orders
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Permissions = TableData "Alternate Quantity Entry" = rim;

    trigger OnRun()
    var
        ProcessReqLine: Record "Process Order Request Line";
        PackageReqLine: Record "Process Order Request Line";
        NumOrders: Integer;
        NumPackageOrders: Integer;
        ConfirmMsg: Text[250];
        BatchOrder: Record "Production Order";
        BatchLotNo: Code[50];
        SubOrder: Code[10];
        CreateOrder: Page "Create Production Orders";
        Location: Code[10];
        Direction: Integer;
        Status: Integer;
        DimensionSetID: Integer;
    begin
        ProcessReqLine.SetRange("Form Type", FormType);
        ProcessReqLine.SetFilter("Package BOM No.", '%1', '');
        ProcessReqLine.SetRange("Location Code", LocationCode); // P8001092
        NumOrders := ProcessReqLine.Count;

        if (NumOrders = 0) then
            Error(Text000);

        PackageReqLine.SetRange("Form Type", FormType);
        PackageReqLine.SetFilter("Package BOM No.", '<>%1', '');
        PackageReqLine.SetRange("Location Code", LocationCode); // P8001092
        NumPackageOrders := PackageReqLine.Count;

        NumOrders := NumOrders + NumPackageOrders;

        /*P8000110A Begin
        IF (NumOrders = 1) THEN
          ConfirmMsg :=
            STRSUBSTNO(Text001)
        ELSE
          ConfirmMsg :=
            STRSUBSTNO(Text002, NumOrders);
        
        IF NOT CONFIRM(ConfirmMsg) THEN
          EXIT;
        P8000110A End*/

        // P8001092
        // CreateOrder.SetVariables('',BatchOrder.Status::Released,NumOrders); // P8000110A
        CreateOrder.SetVariables(LocationCode, BatchOrder.Status::Released, NumOrders);
        CreateOrder.ProhibitLocationChange;
        // P8001092
        CreateOrder.ProhibitStatusChange;                                   // P8000110A
        if CreateOrder.RunModal <> ACTION::Yes then                         // P8000110A, P8000961
            exit;                                                             // P8000110A
        CreateOrder.ReturnVariables(Location, Direction, Status, DimensionSetID); // P8000110A, P8001133

        if (NumPackageOrders = 0) then
            StatusWindow.Open(Text003)
        else
            StatusWindow.Open(Text003 + Text004);

        ProcessSetup.Get;
        with ProcessReqLine do begin
            Find('-');
            repeat
                CreateFamilyOrder(ProcessReqLine, BatchOrder, Location, Direction, Status, DimensionSetID); // P8000110A, P8001133
                PackageReqLine.SetRange("Item No.", "Item No.");
                PackageReqLine.SetRange("Process BOM No.", "Process BOM No.");
                PackageReqLine.SetRange("Process BOM Line No.", "Process BOM Line No.");
                if PackageReqLine.Find('-') then begin
                    SubOrder := '000';
                    repeat
                        CreatePackageOrder(PackageReqLine, BatchOrder, SubOrder, Direction); // P8000110A
                    until (PackageReqLine.Next = 0);
                end;
            until (Next = 0);

            Reset;
            SetRange("Form Type", FormType);
            DeleteAll;
        end;

        if (NumOrders = 1) then
            Message(Text005)
        else
            Message(Text006, NumOrders);

        StatusWindow.Close;

    end;

    var
        FormType: Integer;
        Item: Record Item;
        Family: Record Family;
        ProcessSetup: Record "Process Setup";
        VersionMgmt: Codeunit VersionManagement;
        CreateOrderLines: Codeunit "Create Prod. Order Lines";
        ProdOrderCalculate: Codeunit "Calculate Prod. Order";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        P800Mgmt: Codeunit "Process 800 Prod. Order Mgt.";
        StatusWindow: Dialog;
        Text000: Label 'No orders to create.';
        Text001: Label 'One order will be created.\\Do you want to create the order?';
        Text002: Label '%1 orders will be created.\\Do you want to create the orders?';
        Text003: Label 'Creating Orders...\\Process Order #1##################';
        Text004: Label '\Package Order #2##################';
        Text005: Label 'One order has been created.';
        Text006: Label '%1 orders have been created.';
        Text007: Label 'Other %1s exist for %2 %3. %4 must have a %5 of %6.';
        Text008: Label '%1 %2 must have a %3 with a %4 of %5.';
        Text009: Label 'Location must be specified.';
        LocationCode: Code[10];
        TempPackageEquipment: Record "Prod. BOM Equipment" temporary;

    procedure SetFormType(NewFormType: Integer)
    begin
        // SetFormType
        FormType := NewFormType;
    end;

    local procedure CreateFamilyOrder(var ProcessReqLine: Record "Process Order Request Line"; var ProdOrder: Record "Production Order"; Location: Code[10]; Direction: Integer; Status: Integer; DimensionSetID: Integer)
    var
        ProcessBOMLine: Record "Production BOM Line";
        ProdOrderLine: Record "Prod. Order Line";
        InvSetup: Record "Inventory Setup";
        ProdOrderStatusMgt: Codeunit "Prod. Order Status Management";
        DimMgt: Codeunit DimensionManagement;
        LotNo: Code[50];
        DimensionSetIDArr: array[10] of Integer;
    begin
        // CreateFamilyOrder
        // P8000110A - add parameters for location, direction, status
        // P8001133 - add parameter for DimensionSetID
        ProcessSetup.TestField("Batch Order Nos.");

        // P8000518A
        InvSetup.Get;
        if InvSetup."Location Mandatory" and (Location = '') then
            Error(Text009);
        // P8000518A

        Clear(ProdOrder);
        ProdOrder.Init;
        NoSeriesMgt.InitSeries(ProcessSetup."Batch Order Nos.", '', WorkDate, ProdOrder."No.", ProdOrder."No. Series");
        ProdOrder.Validate(Status, Status); // P8000110A
        ProdOrder.Insert(true);

        StatusWindow.Update(1, ProdOrder."No.");

        ProdOrder."Starting Date" := WorkDate;
        ProdOrder."Creation Date" := WorkDate;
        ProdOrder."Due Date" := WorkDate;
        ProdOrder."Ending Date" := WorkDate;
        ProdOrder."Low-Level Code" := 1;
        ProdOrder."Source Type" := ProdOrder."Source Type"::Family;
        ProdOrder.Validate("Source No.", ProcessReqLine."Process BOM No.");
        ProdOrder.Validate("Location Code", Location); // P8000110A
        ProcessBOMLine.Get(ProcessReqLine."Process BOM No.",
                           VersionMgmt.GetBOMVersion(ProcessReqLine."Process BOM No.", WorkDate, true),
                           ProcessReqLine."Process BOM Line No.");
        ProdOrder.Validate(Quantity,
          ProcessBOMLine.GetProcessOutputQty(ProcessReqLine."Unit of Measure Code", ProcessReqLine.Quantity));
        // P8001133
        DimensionSetIDArr[1] := DimensionSetID;
        DimensionSetIDArr[2] := ProdOrder."Dimension Set ID";
        ProdOrder."Dimension Set ID" :=
          DimMgt.GetCombinedDimensionSetID(DimensionSetIDArr, ProdOrder."Shortcut Dimension 1 Code", ProdOrder."Shortcut Dimension 2 Code");
        // P8001133

        // ProdOrder.VALIDATE("Equipment Code", Equip);

        SetEquipmentCode(ProcessReqLine."Process BOM No.");  // P8008053
        ProdOrder.Validate("Equipment Code", TempPackageEquipment."Resource No."); // P8008053

        ProdOrder.Modify(true);

        CreateOrderLines.Copy(ProdOrder, Direction, '', true); // P8000110A, P8001301

        if (ProdOrder.Status = ProdOrder.Status::Released) then begin // P8001092
            ProdOrderLine.SetRange(Status, ProdOrder.Status);
            ProdOrderLine.SetRange("Prod. Order No.", ProdOrder."No.");
            if ProdOrderLine.Find('-') then
                repeat
                    LotNo := ProdOrderLine."Lot No."; // P8001092
                    P800Mgmt.CreateOutputItemTracking(ProdOrderLine, LotNo);
                until (ProdOrderLine.Next = 0);
        end; // P8001092

        if ProdOrder.Status = ProdOrder.Status::Released then                     // P8000209A
            ProdOrderStatusMgt.FlushProdOrder(ProdOrder, ProdOrder.Status, WorkDate); // P8000209A
    end;

    local procedure CreatePackageOrder(var PackageReqLine: Record "Process Order Request Line"; var BatchOrder: Record "Production Order"; var SubOrder: Code[10]; Direction: Integer)
    var
        BatchOrderLine: Record "Prod. Order Line";
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        LotNo: Code[50];
        P800ItemTracking: Codeunit "Process 800 Item Tracking";
        ProdOrderStatusMgt: Codeunit "Prod. Order Status Management";
    begin
        // CreatePackageOrder
        // P8000110A - add parameters for direction
        BatchOrderLine.Get(BatchOrder.Status, BatchOrder."No.", PackageReqLine."Output Family Line No.");

        // PackageReqLine.CALCFIELDS("Finished Item No."); // P8001092

        SetEquipmentCode(PackageReqLine."Package BOM No.");  // P8008053

        P800Mgmt.CreateOrderHeader(ProdOrder,
          ProdOrder.Status::Released,
          ProcessSetup."Packaging Order Nos.",
          SubOrder,
          ProdOrder."Source Type"::Item,
          PackageReqLine."Finished Item No.",
          // '',                                  // P8001092
          PackageReqLine."Finished Variant Code", // P8001092
          PackageReqLine.GetPackageQuantity(),
          BatchOrderLine."Ending Date",
          BatchOrderLine."Location Code",
          0, // P8001133
          TempPackageEquipment."Resource No.", // P8008053
          ProdOrder."Order Type"::Package,
          BatchOrder.Status,
          BatchOrder."No.",
          '');

        StatusWindow.Update(2, ProdOrder."No.");

        GetItem(PackageReqLine."Finished Item No.");
        ProdOrder.Validate("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
        ProdOrder."Batch Prod. Order Line No." := BatchOrderLine."Line No.";
        ProdOrder.Modify;

        // CreateOrderLines.Copy(ProdOrder, Direction, '');                                // P8000110A, P8001092
        CreateOrderLines.Copy(ProdOrder, Direction, PackageReqLine."Finished Variant Code", true); // P8001092, P8001301

        ProdOrderLine.Get(ProdOrder.Status, ProdOrder."No.", 10000);
        P800Mgmt.CreateOutputItemTracking(ProdOrderLine, LotNo);
        ProdOrderCalculate.Calculate(ProdOrderLine, Direction, true, true, true, true); // P8000110A, P8001301
        ProdOrderLine.Find; // P8000197A

        LotNo := P800ItemTracking.GetLotNoForProdOrderLine(BatchOrderLine);
        // P8001092
        // P800Mgmt.CreateComponentItemTracking(ProdOrderLine, BatchOrderLine."Item No.", '', LotNo); // P8001030
        P800Mgmt.CreateComponentItemTracking(
          ProdOrderLine, BatchOrderLine."Item No.", BatchOrderLine."Variant Code", LotNo);
        // P8001092

        if ProdOrder.Status = ProdOrder.Status::Released then                     // P8000209A
            ProdOrderStatusMgt.FlushProdOrder(ProdOrder, ProdOrder.Status, WorkDate); // P8000209A
    end;

    local procedure GetSummPackageReqLines(FormType2: Integer; var TempPackageReqLine: Record "Process Order Request Line" temporary)
    var
        PackageReqLine: Record "Process Order Request Line";
    begin
        // GetSummPackageReqLines
        with TempPackageReqLine do begin
            Reset;
            DeleteAll;
            SetCurrentKey("Package BOM No.");
            PackageReqLine.SetRange("Form Type", FormType2);
            PackageReqLine.SetFilter("Package BOM No.", '<>%1', '');
            if PackageReqLine.Find('-') then
                repeat
                    SetRange("Package BOM No.", PackageReqLine."Package BOM No.");
                    SetRange("Finished Item No.", PackageReqLine."Finished Item No.");         // P8001092
                    SetRange("Finished Variant Code", PackageReqLine."Finished Variant Code"); // P8001092
                    if Find('-') then begin
                        Quantity := Quantity + PackageReqLine.Quantity;
                        Modify;
                    end else begin
                        TempPackageReqLine := PackageReqLine;
                        Insert;
                    end;
                until (PackageReqLine.Next = 0);
            SetRange("Package BOM No.");
            SetRange("Finished Item No.");     // P8001092
            SetRange("Finished Variant Code"); // P8001092
        end;
    end;

    procedure CheckVersionUOM(var ProdBOMVersion: Record "Production BOM Version"; NewUOMCode: Code[10])
    var
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMVersion2: Record "Production BOM Version";
        FamilyLine: Record "Family Line";
        UnitOfMeasure: Record "Unit of Measure";
        UnitOfMeasure2: Record "Unit of Measure";
    begin
        // CheckVersionUOM
        if (NewUOMCode <> '') then
            if Family.Get(ProdBOMVersion."Production BOM No.") then begin
                ProdBOMHeader.Get(Family."No.");
                if (ProdBOMHeader."Output Type" = ProdBOMHeader."Output Type"::Family) then begin
                    UnitOfMeasure.Get(NewUOMCode);
                    ProdBOMVersion2.SetRange("Production BOM No.", ProdBOMVersion."Production BOM No.");
                    ProdBOMVersion2.SetFilter("Version Code", '<>%1', ProdBOMVersion."Version Code");
                    if ProdBOMVersion2.Find('-') then begin
                        GetProcessVersionUOM(ProdBOMVersion2."Production BOM No.", ProdBOMVersion2."Version Code", UnitOfMeasure2);
                        if (UnitOfMeasure.Type <> UnitOfMeasure2.Type) then
                            Error(Text007, ProdBOMVersion.TableCaption, ProdBOMVersion.Type,
                                  ProdBOMVersion."Production BOM No.", ProdBOMVersion.FieldCaption("Unit of Measure Code"),
                                  UnitOfMeasure.FieldCaption(Type), UnitOfMeasure2.Type);
                    end else
                        with FamilyLine do begin
                            SetRange("Family No.", Family."No.");
                            SetFilter("Item No.", '<>%1', '');
                            if Find('-') then
                                repeat
                                    CheckUnitType(FamilyLine, UnitOfMeasure);
                                until (Next = 0);
                        end;
                end;
            end;
    end;

    procedure CheckFamilyLineUnitType(var FamilyLine: Record "Family Line"; FamilyVersionCode: Code[20])
    var
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        // CheckFamilyLineUnitType
        if GetProcessFamily(FamilyLine) then begin
            GetProcessVersionUOM(FamilyLine."Family No.", FamilyVersionCode, UnitOfMeasure);
            CheckUnitType(FamilyLine, UnitOfMeasure);
        end;
    end;

    local procedure CheckUnitType(var FamilyLine: Record "Family Line"; var UnitOfMeasure: Record "Unit of Measure")
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        // CheckUnitType
        with ItemUnitOfMeasure do
            if (UnitOfMeasure.Type = UnitOfMeasure.Type::" ") then
                Get(FamilyLine."Item No.", UnitOfMeasure.Code)
            else begin
                SetRange("Item No.", FamilyLine."Item No.");
                SetRange(Type, UnitOfMeasure.Type);
                if not Find('-') then
                    Error(Text008, Item.TableCaption, FamilyLine."Item No.",
                          UnitOfMeasure.TableCaption, FieldCaption(Type), UnitOfMeasure.Type);
            end;
    end;

    local procedure MatchUOMType(UOMCode: Code[10]; UOMType: Integer): Boolean
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        // MatchUOMType
        if (UOMCode = '') then
            exit(false);
        UnitOfMeasure.Get(UOMCode);
        exit(UnitOfMeasure.Type = UOMType);
    end;

    local procedure GetProcessFamily(var FamilyLine: Record "Family Line"): Boolean
    var
        ProdBOMHeader: Record "Production BOM Header";
    begin
        // GetProcessFamily
        with FamilyLine do begin
            if ("Item No." = '') then
                exit(false);
            GetFamily("Family No.");
            if not Family."Process Family" then
                exit(false);
            ProdBOMHeader.Get("Family No.");
            exit(ProdBOMHeader."Output Type" = ProdBOMHeader."Output Type"::Family);
        end;
    end;

    local procedure GetProcessVersionUOM(FamilyBOMNo: Code[20]; FamilyVersionCode: Code[20]; var UnitOfMeasure: Record "Unit of Measure")
    var
        ProdBOMVersion: Record "Production BOM Version";
    begin
        // GetProcessVersionUOM
        with ProdBOMVersion do begin
            Get(FamilyBOMNo, FamilyVersionCode);
            case "Primary UOM" of
                "Primary UOM"::Weight:
                    "Unit of Measure Code" := "Weight UOM";
                "Primary UOM"::Volume:
                    "Unit of Measure Code" := "Volume UOM";
            end;
            TestField("Unit of Measure Code");
            UnitOfMeasure.Get("Unit of Measure Code");
        end;
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        // GetItem
        if (Item."No." <> ItemNo) then
            Item.Get(ItemNo);
    end;

    local procedure GetFamily(FamilyNo: Code[20])
    begin
        // GetFamily
        if (FamilyNo <> Family."No.") then
            Family.Get(FamilyNo);
    end;

    procedure LoadProcessRequestQty(FormType: Integer; var ProcessBOMLine: Record "Production BOM Line"; var ReqQty: Decimal)
    var
        RequestLine: Record "Process Order Request Line";
    begin
        // LoadProcessRequestQty
        with ProcessBOMLine do
            // P8001092
            // IF RequestLine.GET(FormType, "No.", "Production BOM No.", "Line No.", 0, '', 0) THEN
            if RequestLine.Get(
                 FormType, "No.", "Variant Code", LocationCode, "Production BOM No.", "Line No.", 0, '', 0, '', '')
            then
                // P8001092
                ReqQty := RequestLine.Quantity
            else
                ReqQty := 0;
    end;

    procedure SaveProcessRequestQty(FormType: Integer; var ProcessBOMLine: Record "Production BOM Line"; ReqUOM: Code[10]; ReqQty: Decimal)
    var
        RequestLine: Record "Process Order Request Line";
    begin
        // SaveProcessRequestQty
        with ProcessBOMLine do
            // P8001092
            // IF RequestLine.GET(FormType, "No.", "Production BOM No.", "Line No.", 0, '', 0) THEN BEGIN
            if RequestLine.Get(
                 FormType, "No.", "Variant Code", LocationCode, "Production BOM No.", "Line No.", 0, '', 0, '', '')
            then begin
                // P8001092
                RequestLine.Quantity := ReqQty;
                RequestLine."Unit of Measure Code" := ReqUOM;
                if (ReqQty = 0) then
                    RequestLine.Delete
                else
                    RequestLine.Modify;
                AdjustPackageRequestQty(ProcessBOMLine, RequestLine);
            end else
                if (ReqQty <> 0) then begin
                    RequestLine."Form Type" := FormType;
                    RequestLine."Item No." := "No.";
                    RequestLine."Variant Code" := "Variant Code"; // P8001092
                    RequestLine."Location Code" := LocationCode;  // P8001092
                    RequestLine."Process BOM No." := "Production BOM No.";
                    RequestLine."Process BOM Line No." := "Line No.";
                    RequestLine."Output Family Line No." := 0;
                    RequestLine."Package BOM No." := '';
                    RequestLine."Package BOM Line No." := 0;
                    RequestLine."Finished Item No." := '';     // P8001092
                    RequestLine."Finished Variant Code" := ''; // P8001092
                    RequestLine.Quantity := ReqQty;
                    RequestLine."Unit of Measure Code" := ReqUOM;
                    RequestLine.Insert;
                end;
    end;

    local procedure AdjustPackageRequestQty(var ProcessBOMLine: Record "Production BOM Line"; var RequestLine: Record "Process Order Request Line")
    var
        OutputFactor: Decimal;
        PackageRequestLine: Record "Process Order Request Line";
        OutputFamilyLine: Record "Family Line";
        OutputQty: Decimal;
    begin
        // AdjustPackageRequestQty
        OutputFactor := ProcessBOMLine.GetProcessOutputQty(RequestLine."Unit of Measure Code", RequestLine.Quantity);
        with PackageRequestLine do begin
            SetRange("Form Type", RequestLine."Form Type");
            SetRange("Item No.", RequestLine."Item No.");
            SetRange("Variant Code", RequestLine."Variant Code");   // P8001092
            SetRange("Location Code", RequestLine."Location Code"); // P8001092
            SetRange("Process BOM No.", RequestLine."Process BOM No.");
            SetRange("Process BOM Line No.", RequestLine."Process BOM Line No.");
            SetFilter("Package BOM No.", '<>%1', '');
            if Find('-') then
                repeat
                    OutputFamilyLine.Get("Process BOM No.", "Output Family Line No.");
                    SetRange("Output Family Line No.", "Output Family Line No.");
                    OutputQty := OutputFamilyLine.Quantity * OutputFactor;
                    repeat
                        if (OutputQty < Quantity) then begin
                            Validate(Quantity, OutputQty);
                            if (Quantity = 0) then
                                Delete
                            else
                                Modify;
                        end;
                        OutputQty := OutputQty - Quantity;
                    until (Next = 0);
                    SetRange("Output Family Line No.");
                until (Next = 0);
        end;
    end;

    procedure GetProcessRequestQty(FormType: Integer; ItemNo: Code[20]; VariantCode: Code[10]): Decimal
    var
        RequestLine: Record "Process Order Request Line";
    begin
        // GetProcessRequestQty
        // P8001092 - Add Variant Code parameter
        RequestLine.SetRange("Form Type", FormType);
        RequestLine.SetRange("Item No.", ItemNo);
        RequestLine.SetRange("Variant Code", VariantCode);  // P8001092
        RequestLine.SetRange("Location Code", LocationCode); // P8001092
        RequestLine.SetRange("Output Family Line No.", 0);
        RequestLine.CalcSums(Quantity);
        exit(RequestLine.Quantity);
    end;

    procedure LoadPackageRequestQty(FormType: Integer; var ProcessBOMLine: Record "Production BOM Line"; OutputFamilyLineNo: Integer; var PackageBOMLine: Record "Production BOM Line"; FinishedItemNo: Code[20]; FinishedVariantCode: Code[10]; var ReqQty: Decimal)
    var
        RequestLine: Record "Process Order Request Line";
    begin
        // LoadPackageRequestQty
        // P8001092 - Add FinishedItemNo and FinishedVariantCode parameters
        with ProcessBOMLine do
            // P8001092
            // IF RequestLine.GET(FormType, "No.", "Production BOM No.", "Line No.", OutputFamilyLineNo,
            //                    PackageBOMLine."Production BOM No.", PackageBOMLine."Line No.")
            if RequestLine.Get(
                 FormType, "No.", "Variant Code", LocationCode, "Production BOM No.", "Line No.", OutputFamilyLineNo,
                 PackageBOMLine."Production BOM No.", PackageBOMLine."Line No.", FinishedItemNo, FinishedVariantCode)
            // P8001092
            then
                ReqQty := RequestLine.Quantity
            else
                ReqQty := 0;
    end;

    procedure SavePackageRequestQty(FormType: Integer; var ProcessBOMLine: Record "Production BOM Line"; OutputFamilyLineNo: Integer; var PackageBOMLine: Record "Production BOM Line"; FinishedItemNo: Code[20]; FinishedVariantCode: Code[10]; ReqUOM: Code[10]; ReqQty: Decimal; FinReqQty: Decimal)
    var
        RequestLine: Record "Process Order Request Line";
    begin
        // SavePackageRequestQty
        // P8001092 - Add FinishedItemNo and FinishedVariantCode parameters
        with ProcessBOMLine do
            // P8001092
            // IF RequestLine.GET(FormType, "No.", "Production BOM No.", "Line No.", OutputFamilyLineNo,
            //                    PackageBOMLine."Production BOM No.", PackageBOMLine."Line No.")
            if RequestLine.Get(
                 FormType, "No.", "Variant Code", LocationCode, "Production BOM No.", "Line No.", OutputFamilyLineNo,
                 PackageBOMLine."Production BOM No.", PackageBOMLine."Line No.", FinishedItemNo, FinishedVariantCode)
            // P8001092
            then
                if (ReqQty = 0) then
                    RequestLine.Delete
                else begin
                    RequestLine."Unit of Measure Code" := ReqUOM;
                    RequestLine.Quantity := ReqQty;
                    RequestLine."Finished Quantity" := FinReqQty; // P8001092
                    RequestLine.Modify;
                end
            else
                if (ReqQty <> 0) then begin
                    RequestLine."Form Type" := FormType;
                    RequestLine."Item No." := "No.";
                    RequestLine."Variant Code" := "Variant Code"; // P8001092
                    RequestLine."Location Code" := LocationCode;  // P8001092
                    RequestLine."Process BOM No." := "Production BOM No.";
                    RequestLine."Process BOM Line No." := "Line No.";
                    RequestLine."Output Family Line No." := OutputFamilyLineNo;
                    RequestLine."Package BOM No." := PackageBOMLine."Production BOM No.";
                    RequestLine."Package BOM Line No." := PackageBOMLine."Line No.";
                    RequestLine."Finished Item No." := FinishedItemNo;          // P8001092
                    RequestLine."Finished Variant Code" := FinishedVariantCode; // P8001092
                    RequestLine."Unit of Measure Code" := ReqUOM;
                    RequestLine.Quantity := ReqQty;
                    RequestLine."Finished Quantity" := FinReqQty; // P8001092
                    RequestLine.Insert;
                end;
    end;

    procedure GetPackageRequestQty(FormType: Integer; var ProcessBOMLine: Record "Production BOM Line"; OutputFamilyLineNo: Integer): Decimal
    var
        RequestLine: Record "Process Order Request Line";
    begin
        // GetPackageRequestQty
        RequestLine.SetRange("Form Type", FormType);
        RequestLine.SetRange("Item No.", ProcessBOMLine."No.");
        RequestLine.SetRange("Variant Code", ProcessBOMLine."Variant Code"); // P8001092
        RequestLine.SetRange("Location Code", LocationCode);                 // P8001092
        RequestLine.SetRange("Process BOM No.", ProcessBOMLine."Production BOM No.");
        RequestLine.SetRange("Process BOM Line No.", ProcessBOMLine."Line No.");
        RequestLine.SetRange("Output Family Line No.", OutputFamilyLineNo);
        RequestLine.CalcSums(Quantity);
        exit(RequestLine.Quantity);
    end;

    procedure ProdBOMLineFind(var ProdBOMLine: Record "Production BOM Line"; Which: Text[30]): Boolean
    var
        ProdBOMLine2: Record "Production BOM Line";
        Direction: Integer;
    begin
        // ProdBOMLineFind
        with ProdBOMLine2 do begin
            Copy(ProdBOMLine);
            if not Find(Which) then
                exit(false);
            Direction := 1;
            while not IsActiveVersion(ProdBOMLine2) do
                case Which of
                    '-':
                        if (Next = 0) then
                            exit(false);
                    '+':
                        if (Next(-1) = 0) then
                            exit(false);
                    else
                        if (Next(Direction) = 0) then begin
                            if (Direction = -1) then
                                exit(false);
                            Copy(ProdBOMLine);
                            Find(Which);
                            Direction := -1;
                            if (Next(Direction) = 0) then
                                exit(false);
                        end;
                end;
        end;
        ProdBOMLine := ProdBOMLine2;
        exit(true);
    end;

    procedure ProdBOMLineNext(var ProdBOMLine: Record "Production BOM Line"; NumSteps: Integer): Integer
    var
        ProdBOMLine2: Record "Production BOM Line";
        StepNo: Integer;
        Direction: Integer;
    begin
        // ProdBOMLineNext
        with ProdBOMLine2 do begin
            Copy(ProdBOMLine);
            Direction := 1;
            if (NumSteps < 0) then begin
                Direction := -Direction;
                NumSteps := -NumSteps;
            end;
            for StepNo := 1 to NumSteps do begin
                if (Next(Direction) = 0) then
                    exit((StepNo - 1) * Direction);
                while not IsActiveVersion(ProdBOMLine2) do
                    if (Next(Direction) = 0) then
                        exit((StepNo - 1) * Direction);
                ProdBOMLine := ProdBOMLine2;
            end;
        end;
        exit(NumSteps * Direction);
    end;

    local procedure IsActiveVersion(var ProdBOMLine: Record "Production BOM Line"): Boolean
    begin
        // IsActiveVersion
        with ProdBOMLine do
            exit("Version Code" = VersionMgmt.GetBOMVersion("Production BOM No.", WorkDate, true));
    end;

    procedure SetLocationCode(NewLocationCode: Code[10])
    begin
        LocationCode := NewLocationCode; // P8001092
    end;

    local procedure SetEquipmentCode(BOMNo: Code[20])
    var
        ProdBOMEquipment: Record "Prod. BOM Equipment";
        Equipment: Record Resource;
    begin
        // P8008053
        TempPackageEquipment.Reset;
        TempPackageEquipment.DeleteAll;

        ProdBOMEquipment.SetRange("Production Bom No.", BOMNo);
        ProdBOMEquipment.SetRange("Version Code", VersionMgmt.GetBOMVersion(BOMNo, WorkDate, true));
        if ProdBOMEquipment.FindSet then
            repeat
                if Equipment.Get(ProdBOMEquipment."Resource No.") then begin
                    TempPackageEquipment := ProdBOMEquipment;
                    TempPackageEquipment.Insert;
                end;
            until ProdBOMEquipment.Next = 0;

        TempPackageEquipment.Reset;
        TempPackageEquipment.SetCurrentKey(Preference);
        if TempPackageEquipment.FindFirst then;
    end;
}

