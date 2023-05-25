codeunit 37002800 "Maintenance Management"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   Maintenance management utility functions
    // 
    // P8000335A, VerticalSoft, Jack Reynolds, 20 SEP 06
    //    CheckPostingGracePeriond and WorkOrderGracePeriodLookup moved from Maintenance Journal Line table
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW119.0
    // P800133109, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 19.0 - Qty. Rounding Precision

    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'Do you want to create the PM work orders?';

    procedure LookupSpare(MfgCode: Code[10]; ModelNo: Code[30]; Type: Integer; var ItemNo: Text[1024]): Boolean
    var
        AssetSpare: Record "Asset Spare Part";
        AssetSpares: Page "Asset Spare Parts";
    begin
        if (MfgCode = '') or (ModelNo = '') then
            exit;

        AssetSpare.FilterGroup(9);
        AssetSpare.SetRange("Manufacturer Code", MfgCode);
        AssetSpare.SetRange("Model No.", ModelNo);
        AssetSpare.SetRange(Type, Type);
        AssetSpare.FilterGroup(0);

        AssetSpares.SetTableView(AssetSpare);
        AssetSpare."Manufacturer Code" := MfgCode;
        AssetSpare."Model No." := ModelNo;
        AssetSpare.Type := Type;
        AssetSpare."Item No." := ItemNo;
        if AssetSpare.Find('=><') then
            AssetSpares.SetRecord(AssetSpare);
        AssetSpares.LookupMode(true);
        if AssetSpares.RunModal = ACTION::LookupOK then begin
            AssetSpares.GetRecord(AssetSpare);
            ItemNo := AssetSpare."Item No.";
            exit(true);
        end;
    end;

    procedure LookupItem(var ItemNo: Text[1024]): Boolean
    var
        Item: Record Item;
        ItemList: Page "Item List";
    begin
        Item.SetCurrentKey("Item Type");
        Item.SetRange("Item Type", Item."Item Type"::Spare);

        ItemList.SetTableView(Item);
        Item."No." := ItemNo;
        if Item.Find('=><') then
            ItemList.SetRecord(Item);
        ItemList.LookupMode(true);
        if ItemList.RunModal = ACTION::LookupOK then begin
            ItemList.GetRecord(Item);
            ItemNo := Item."No.";
            exit(true);
        end;
    end;

    procedure UpdateItemCost(EntryNo: Integer)
    var
        GLSetup: Record "General Ledger Setup";
        MaintLedgEntry: Record "Maintenance Ledger";
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        MaintLedgEntry.Get(EntryNo);
        if MaintLedgEntry."Item Ledger Entry No." = 0 then
            exit;

        GLSetup.Get;
        ItemLedgEntry.Get(MaintLedgEntry."Item Ledger Entry No.");
        ItemLedgEntry.CalcFields("Cost Amount (Actual)");
        MaintLedgEntry."Cost Amount" := -ItemLedgEntry."Cost Amount (Actual)";
        if MaintLedgEntry.Quantity <> 0 then
            MaintLedgEntry."Unit Cost" := Round(MaintLedgEntry."Cost Amount" / MaintLedgEntry.Quantity,
              GLSetup."Unit-Amount Rounding Precision");
        MaintLedgEntry.Modify;
    end;

    procedure TestUsage(AssetNo: Code[20]; Date: Date; Usage: Decimal; UsageMustExist: Boolean)
    var
        AssetUsage: Record "Asset Usage";
        LowUsage: Decimal;
        HighUsage: Decimal;
        Text001: Label 'No usage has been established for %1.';
        Text002: Label 'Usage on %1 must be between %2 and %3.';
        Text003: Label 'Usage on %1 may not be less than %2.';
        Text004: Label 'Usage on %1 may not be greater than %2.';
    begin
        AssetUsage.SetRange("Asset No.", AssetNo);
        AssetUsage."Asset No." := AssetNo;
        AssetUsage.Date := Date;
        if not AssetUsage.Find('=<>') then
            if UsageMustExist then
                Error(Text001, AssetNo)
            else
                exit;
        if AssetUsage.Date = Date then begin
            HighUsage := AssetUsage.Reading;
            if AssetUsage.Next(-1) <> 0 then
                LowUsage := AssetUsage.Reading;
            if (Usage < LowUsage) or (Usage > HighUsage) then
                Error(Text002, Date, LowUsage, HighUsage);
        end else
            if AssetUsage.Date < Date then begin
                LowUsage := AssetUsage.Reading;
                if AssetUsage.Next <> 0 then begin
                    HighUsage := AssetUsage.Reading;
                    if (Usage < LowUsage) or (Usage > HighUsage) then
                        Error(Text002, Date, LowUsage, HighUsage);
                end else
                    if Usage < AssetUsage.Reading then
                        Error(Text003, Date, AssetUsage.Reading);
            end else begin
                if Usage > AssetUsage.Reading then
                    Error(Text004, Date, AssetUsage.Reading);
            end;
    end;

    procedure CreatePMOrders(var PMWksh: Record "PM Worksheet"; var WOCreated: array[2] of Code[20])
    var
        PMOrder: Record "Preventive Maintenance Order";
        WorkOrder: Record "Work Order";
        PMWksh2: Record "PM Worksheet";
    begin
        if not Confirm(Text001, false) then
            exit;

        PMWksh2.Copy(PMWksh);

        PMWksh.SetCurrentKey("PM Worksheet Name", "Line No.");
        PMWksh.SetRange("Create Order", true);
        if PMWksh.FindSet then
            repeat
                PMOrder.Get(PMWksh."PM Entry No.");
                PMOrder.TestField("Current Work Order", '');
                if PMWksh."Master PM" then
                    PMOrder.CreateWorkOrder(WorkOrder, WorkDate, 0T, PMWksh."Due Date")
                else begin
                    PMOrder."Current Work Order" := WorkOrder."No.";
                    PMOrder."Override Date" := 0D;
                end;
                PMOrder.Modify;
                if WOCreated[1] = '' then
                    WOCreated[1] := WorkOrder."No.";
                WOCreated[2] := WorkOrder."No.";
            until PMWksh.Next = 0;

        PMWksh.DeleteAll;

        PMWksh.Copy(PMWksh2);
    end;

    procedure UpdatePMMtlUnitCost(Item: Record Item)
    var
        PMMaterial: Record "PM Material";
        GLSetup: Record "General Ledger Setup";
    begin
        PMMaterial.SetCurrentKey(Type, "Item No.");
        PMMaterial.SetRange(Type, PMMaterial.Type::Stock);
        PMMaterial.SetRange("Item No.", Item."No.");
        if PMMaterial.FindSet(true, false) then begin
            GLSetup.Get;
            repeat
                PMMaterial.Validate("Unit Cost",
                  Round(Item."Unit Cost" * PMMaterial.QtyPerUnitOfMeasure(), GLSetup."Unit-Amount Rounding Precision")); // P800133109
                PMMaterial.Modify;
            until PMMaterial.Next = 0;
        end;
    end;

    procedure CheckPostingGracePeriod(WorkOrderNo: Code[20])
    var
        MaintSetup: Record "Maintenance Setup";
        WorkOrder: Record "Work Order";
        GraceDate: Date;
        Text001: Label '%1 has expired.';
    begin
        // P8000335A
        if WorkOrderNo = '' then
            exit;

        WorkOrder.Get(WorkOrderNo);
        if WorkOrder."Completion Date" = 0D then
            exit;

        MaintSetup.Get;
        GraceDate := WorkOrder."Completion Date";
        if Format(MaintSetup."Posting Grace Period") <> '' then
            GraceDate := CalcDate(MaintSetup."Posting Grace Period", WorkOrder."Completion Date");

        if WorkDate > GraceDate then
            Error(Text001, MaintSetup.FieldCaption("Posting Grace Period"));
    end;

    procedure WorkOrderGracePeriodLookup(var Text: Text[1024]): Boolean
    var
        MaintSetup: Record "Maintenance Setup";
        WorkOrder: Record "Work Order";
        WorkOrderList: Page "Work Order List";
        CompDate: Date;
    begin
        // P8000335A
        WorkOrder.SetCurrentKey("Asset No.", "Completion Date");
        MaintSetup.Get;
        CompDate := WorkDate;
        if Format(MaintSetup."Posting Grace Period") <> '' then
            CompDate := CalcDate('-' + Format(MaintSetup."Posting Grace Period"), CompDate);
        WorkOrder.SetFilter("Completion Date", '%1|%2..', 0D, CompDate);

        WorkOrderList.SetTableView(WorkOrder);
        WorkOrderList.LookupMode(true);
        if WorkOrderList.RunModal = ACTION::LookupOK then begin
            WorkOrderList.GetRecord(WorkOrder);
            Text := WorkOrder."No.";
            exit(true);
        end;
    end;

    procedure UpdateAssetGLobalDimCode(GlobalDimCodeNo: Integer; AssetNo: Code[20]; NewDimValue: Code[20])
    var
        Asset: Record Asset;
    begin
        // P8001133
        // P8001263 - CustNo renamed to AssetNo
        if Asset.Get(AssetNo) then begin // P8001263
            case GlobalDimCodeNo of
                1:
                    Asset."Global Dimension 1 Code" := NewDimValue;
                2:
                    Asset."Global Dimension 2 Code" := NewDimValue;
            end;
            Asset.Modify(true);
        end;
    end;

    procedure UpdatePMGLobalDimCode(GlobalDimCodeNo: Integer; EntryNo: Code[20]; NewDimValue: Code[20])
    var
        PM: Record "Preventive Maintenance Order";
    begin
        // P8001133
        // P8001263 - CustNo renamed to EntryNo
        if PM.Get(EntryNo) then begin // P8001263
            case GlobalDimCodeNo of
                1:
                    PM."Global Dimension 1 Code" := NewDimValue;
                2:
                    PM."Global Dimension 2 Code" := NewDimValue;
            end;
            PM.Modify(true);
        end;
    end;
}

