codeunit 37002468 "Batch Planning Functions"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Support functions for the Batch Planning tables, reports, and pages
    // 
    // P8000889, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Support for production sequencing
    // 
    // PRW16.00.05
    // P8000933, Columbus IT, Jack Reynolds, 20 APR 11
    //   Fix problem with Quantity Required when planning an item
    // 
    // P8000972, Columbus IT, Jack Reynolds, 26 AUG 11
    //   Fix problem with Additional Quantity (to package)
    // 
    // P8000973, Columbus IT, Jack Reynolds, 26 AUG 11
    //   Fix screen refresh issues
    // 
    // P8000991, Columbus IT, Jack Reynolds, 26 OCT 11
    //   Fix problem with Maximum Order Quantity of zero
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // P8001107, Columbus IT, Don Bresee, 19 OCT 12
    //   Add Minimum Equipment Qty. field
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.00.01
    // P8001182, Columbus IT, Jack Reynolds, 18 JUL 13
    //   Modify to use signalling instead of SENDKEYS to trigger an action
    // 
    // P8001184, Columbus IT, Jack Reynolds, 18 JUL 13
    //   Fix problem initializing worksheet equipment summary records
    // 
    // PRW17.10.02
    // P8001301, Columbus IT, Jack Reynolds, 03 MAR 14
    //   Update Rollup 4
    // 
    // PRW18.00
    // P8001360, Columbus IT, Jack Reynolds, 06 NOV 14
    //   Update .NET variable references
    // 
    // PRW18.00.01
    // P8001386, Columbus IT, Jack Reynolds, 27 MAY 15
    //    Renamed NAV Food client addins
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 31 MAR 16
    //   Update add-in assembly version references
    // 
    // PRW19.00.01
    // P8007285, To-Increase, Dayakar Battini, 20 JUN 16
    //   Replenishment Areas not set on Batch Production Order
    // 
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW110.0
    // P8007750, To-Increase, Jack Reynolds, 07 NOV 16
    //   Convert Food Item Attributes to NAV Item Attributes
    // 
    // P8007755, To-Increase, Jack Reynolds, 22 NOV 16
    //   Update add-in assembly version references
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Upgrade signal control for JavaScript
    // 
    // P80062449, To-Increase, Jack Reynolds, 23 JUL 18
    //   Fix incorrect batch production time
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 28 APR 22
    //   Removing support for Signal Functions codeunit


    trigger OnRun()
    begin
    end;

    var
        BPWorksheetName: Record "Batch Planning Worksheet Name";
        EquipmentParameter: Record "Batch Planning Equip. Summary" temporary;
        Equipment: Record Resource temporary;
        DailySummary: Record "Batch Planning Equip. Summary" temporary;
        DailyDetail: Record "Batch Planning Order Detail" temporary;
        BatchItem: Record Item;
        FinishedItem: Record "Batch Planning Worksheet Line" temporary;
        BatchSummary: Record "Batch Planning - Batch" temporary;
        BatchDetail: Record "Batch Planning - Batch" temporary;
        PackageSummary: Record "Batch Planning - Package" temporary;
        PackageDetail: array[2] of Record "Batch Planning - Package" temporary;
        GlobalUpdateAction: array[2] of Code[20];
        LocationCode: Code[10];
        BatchVariant: Code[10];
        BeginDate: Date;
        EndDate: Date;
        SummaryRecordDisplayed: Boolean;
        BatchItemHighlight: Text[250];
        PackageItemHighlight: Text[250];
        ProductionDate: Date;
        TotalBatchQty: Decimal;
        Text001: Label 'Nothing to create.';
        FinishedQtyRequired: Decimal;
        ManualQtyRequired: Decimal;
        RemainingBatchQtyToPack: Decimal;
        UpdateAction: array[10] of Code[20];
        Text002: Label 'There are one or more finished items remaining to be packed.';
        ExistingOrders: Boolean;
        Text003: Label 'Delete existing orders?';
        Text004: Label 'Batch quantity is less than total requirements.';
        Text005: Label 'There are not enough batches to satisfy the requirements.';

    procedure GetParameter(Item: Record Item; IntermediateItem: Record Item; Type: Option " ",Intermediate,Finished; "Field": Option " ","Item No.","Item Category",Allergen,,,,Attribute; Attribute: Integer) Value: Text[250]
    begin
        // P8006959 - Add Allergen to field OptionString
        // P8007750 - Attribute changed to Integer, Return changed to Text250
        if Type = Type::Intermediate then
            Value := GetParameter2(IntermediateItem, Field, Attribute)
        else
            Value := GetParameter2(Item, Field, Attribute);
    end;

    procedure GetParameter2(Item: Record Item; "Field": Option " ","Item No.","Item Category",Allergen,,,,Attribute; Attribute: Integer) Value: Text[250]
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        ItemAttributeValue: Record "Item Attribute Value";
        AllergenManagement: Codeunit "Allergen Management";
    begin
        // P8006959 - Add Allergen to field OptionString
        // P8007750 - Attribute changed to Integer, Return changed to Text250
        case Field of
            Field::"Item No.":
                Value := Item."No.";
            Field::"Item Category":
                Value := Item."Item Category Code";
            Field::Allergen:
                Value := AllergenManagement.AllergenCodeForRecord(0, 0, Item."No."); // P8006959
            Field::Attribute:
                // P8007750
                if Attribute <> 0 then
                    if ItemAttributeValueMapping.Get(DATABASE::Item, Item."No.", Attribute) then begin
                        ItemAttributeValue.Get(ItemAttributeValueMapping."Item Attribute ID", ItemAttributeValueMapping."Item Attribute Value ID");
                        Value := ItemAttributeValue.Value;
                    end;
        // P8007750
        end;
    end;

    procedure GetParameter3(Item: Record Item; "Field": Option " ","Item No.","Item Category",Allergen,,,,Attribute; Attribute: Integer) Value: Text[250]
    begin
        // P8006959
        // P8007750 - Attribute changed to Integer, Return changed to Text250
        if Field <> Field::Allergen then
            exit(GetParameter2(Item, Field, Attribute))
        else
            exit(Format(Item."Direct Allergen Set ID" + Item."Indirect Allergen Set ID"));
    end;

    procedure TriggerUpdate(Position: Integer; UpdAction: Code[20])
    begin
        // P800144605
        GlobalUpdateAction[Position] := UpdAction;
    end;

    procedure GetUpdateAction(Position: Integer) UpdAction: Code[20]
    begin
        // P800144605
        UpdAction := GlobalUpdateAction[Position];
        GlobalUpdateAction[Position] := '';
    end;

    procedure InitializeWorksheet(WkshName: Code[10]; LocCode: Code[10]; Date1: Date; Date2: Date)
    var
        Resource: Record Resource;
        DailyEvent: Record "Daily Production Event";
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
    begin
        if (WkshName = BPWorksheetName.Name) and (LocationCode = LocCode) and (BeginDate = Date1) and (EndDate = Date2) then
            exit;

        BPWorksheetName.Get(WkshName);
        LocationCode := LocCode;
        BeginDate := Date1;
        EndDate := Date2;

        Equipment.Reset;
        Equipment.DeleteAll;
        Clear(Equipment);
        DailySummary.Reset;
        DailySummary.DeleteAll;
        Clear(DailySummary);
        DailyDetail.Reset;
        DailyDetail.DeleteAll;
        Clear(DailyDetail);
        EquipmentParameter.Reset;
        EquipmentParameter.DeleteAll;
        Clear(EquipmentParameter);

        if BeginDate = 0D then
            exit;

        Resource.SetRange(Type, Resource.Type::Machine);
        Resource.SetFilter("Machine Type", '>0');
        Resource.SetFilter("Location Code", LocationCode);
        Equipment.Insert;
        if Resource.FindSet then
            repeat
                Equipment := Resource;
                Equipment.Insert;
            until Resource.Next = 0;

        for DailySummary."Production Date" := BeginDate to EndDate do begin
            if Equipment.FindSet then
                repeat
                    DailySummary."Equipment Code" := Equipment."No.";
                    DailySummary."Equipment Type" := Equipment."Machine Type";
                    DailySummary."Hide Equipment" := DailySummary."Production Date" <> BeginDate;
                    DailySummary.Insert;
                until Equipment.Next = 0;
        end;

        DailyEvent.SetRange("Production Date", BeginDate, EndDate);
        if Resource.FindSet then
            repeat
                DailyEvent.SetRange("Equipment Code", Resource."No.");
                if DailyEvent.FindSet then
                    repeat
                        if Equipment.Get(DailyEvent."Equipment Code") then begin // P8001184
                            DailyDetail."Production Date" := DailyEvent."Production Date";
                            DailyDetail."Equipment Code" := DailyEvent."Equipment Code";
                            DailyDetail.Type := DailyDetail.Type::"Event";
                            DailyDetail.Validate("Event Code", DailyEvent."Event Code");
                            DailyDetail."Line No." := DailyEvent."Line No.";
                            DailyDetail."Duration (Hours)" := DailyEvent."Duration (Hours)";
                            DailyDetail.Insert;
                        end; // P8001184
                    until DailyEvent.Next = 0;
            until Resource.Next = 0;

        ProdOrderLine.SetRange(Status, ProdOrder.Status::"Firm Planned", ProdOrder.Status::Released);
        ProdOrderLine.SetRange("Location Code", LocationCode);
        ProdOrderLine.SetRange("Starting Date", BeginDate, EndDate);
        if ProdOrderLine.FindSet then begin
            repeat
                if Equipment.Get(ProdOrderLine."Equipment Code") then begin // P8001184
                    UpdateDailyDetail(ProdOrderLine);
                    UpdateEquipmentParameter(ProdOrderLine);
                end; // P8001184
            until ProdOrderLine.Next = 0;
        end;

        UpdateDailySummary;
    end;

    procedure UpdateEquipmentParameter(ProdOrderLine: Record "Prod. Order Line")
    var
        Resource: Record Resource;
        Item: Record Item;
        ParameterValue: Text[250];
    begin
        if Resource.Get(ProdOrderLine."Equipment Code") then
            if Resource."Machine Type" > 0 then begin
                Item.Get(ProdOrderLine."Item No.");
                case Resource."Machine Type" of
                    Resource."Machine Type"::Batch:
                        ParameterValue := GetParameter3(Item, BPWorksheetName."Batch Highlight Field", // P8006959
                          BPWorksheetName."Batch Highlight Attribute");
                    Resource."Machine Type"::Package:
                        ParameterValue := GetParameter3(Item, BPWorksheetName."Package Highlight Field", // P8006959
                          BPWorksheetName."Package Highlight Attribute");
                end;
                if ParameterValue <> '' then begin
                    EquipmentParameter."Production Date" := ProdOrderLine."Starting Date";
                    EquipmentParameter."Equipment Code" := ProdOrderLine."Equipment Code";
                    EquipmentParameter."Highlight Value" := ParameterValue;
                    EquipmentParameter."Prod. Order Status" := ProdOrderLine.Status;
                    EquipmentParameter."Prod. Order No." := ProdOrderLine."Prod. Order No.";
                    if EquipmentParameter.Insert then;
                end;
            end;
    end;

    procedure GetWorksheetParameters(var LocCode: Code[10]; var Date1: Date; var Date2: Date)
    begin
        LocCode := LocationCode;
        Date1 := BeginDate;
        Date2 := EndDate;
    end;

    procedure UpdateDailyDetail(ProdOrderLine: Record "Prod. Order Line")
    begin
        DailyDetail.Init;
        DailyDetail."Production Date" := ProdOrderLine."Starting Date";
        DailyDetail."Equipment Code" := ProdOrderLine."Equipment Code";
        DailyDetail.Type := DailyDetail.Type::Order;
        DailyDetail."Event Code" := '';
        DailyDetail.Validate("Order Status", ProdOrderLine.Status);
        DailyDetail."Order No." := ProdOrderLine."Prod. Order No.";
        DailyDetail."Line No." := 0;
        DailyDetail.Validate("Item No.", ProdOrderLine."Item No.");
        DailyDetail."Variant Code" := ProdOrderLine."Variant Code"; // P8001030
        if DailyDetail.Find('=') then begin
            DailyDetail.Quantity += ProdOrderLine."Quantity (Base)";
            DailyDetail."Duration (Hours)" +=
              Round((ProdOrderLine."Ending Date-Time" - ProdOrderLine."Starting Date-Time") / 3600000, 0.001);
            DailyDetail.Modify;
        end else begin
            DailyDetail.Quantity := ProdOrderLine."Quantity (Base)";
            DailyDetail."Duration (Hours)" :=
              Round((ProdOrderLine."Ending Date-Time" - ProdOrderLine."Starting Date-Time") / 3600000, 0.001);
            DailyDetail.Insert;
        end;
    end;

    procedure UpdateDailySummary()
    var
        ProdDate: Date;
    begin
        DailySummary.Reset;
        DailySummary.ModifyAll(Items, 0);
        DailySummary.ModifyAll("Total Time (Hours)", 0);

        DailyDetail.Reset;
        DailyDetail.SetCurrentKey("Production Date", "Equipment Code", "Item No.");
        for ProdDate := BeginDate to EndDate do begin
            DailyDetail.SetRange("Production Date", ProdDate);
            if DailyDetail.Find('-') then
                repeat
                    DailyDetail.SetRange("Equipment Code", DailyDetail."Equipment Code");
                    DailyDetail.CalcSums("Duration (Hours)");
                    DailySummary.Get(DailyDetail."Production Date", DailyDetail."Equipment Code");
                    DailySummary."Total Time (Hours)" := DailyDetail."Duration (Hours)";
                    DailySummary.Items := 0;
                    repeat
                        DailyDetail.SetRange("Item No.", DailyDetail."Item No.");
                        if DailyDetail."Item No." <> '' then
                            DailySummary.Items += 1;
                        DailyDetail.Find('+');
                        DailyDetail.SetRange("Item No.");
                    until DailyDetail.Next = 0;
                    DailyDetail.SetRange("Equipment Code");
                    DailySummary.Modify
                until DailyDetail.Next = 0;
        end;
        DailyDetail.Reset;
    end;

    procedure GetWorksheet(var Worksheet: Record "Batch Planning Worksheet Name")
    begin
        Worksheet := BPWorksheetName;
    end;

    procedure GetDailySummary(var Summary: Record "Batch Planning Equip. Summary")
    var
        EntryNo: Integer;
    begin
        Summary.Reset;
        Summary.DeleteAll;

        DailySummary.Reset;
        if DailySummary.FindSet then
            repeat
                Summary := DailySummary;
                Summary.Insert;
            until DailySummary.Next = 0;
    end;

    procedure GetCurrentDailySummary(var Summary: Record "Batch Planning Equip. Summary")
    var
        EntryNo: Integer;
    begin
        Summary := DailySummary;
    end;

    procedure MarkEquipment(CurrentItem: Record Item; VariantCode: Code[10])
    var
        Item: Record Item;
        BOMEquipment: Record "Prod. BOM Equipment";
        VersionMgt: Codeunit VersionManagement;
        ProductionBOMNo: Code[20];
    begin
        // P8001030 - add parameter for VariantCode
        Equipment.ClearMarks;

        if CurrentItem."Production Grouping Item" <> '' then begin
            Item.Get(CurrentItem."Production Grouping Item");
            ProductionBOMNo := Item.ProductionBOMNo(Item."Production Grouping Variant", LocationCode);        // P8001030
            if ProductionBOMNo <> '' then begin                                                              // P8001030
                BOMEquipment.SetRange("Production Bom No.", ProductionBOMNo);                                   // P8001030
                BOMEquipment.SetRange("Version Code", VersionMgt.GetBOMVersion(ProductionBOMNo, WorkDate, true)); // P8001030
                if BOMEquipment.FindSet then
                    repeat
                        if Equipment.Get(BOMEquipment."Resource No.") then
                            Equipment.Mark(true);
                    until BOMEquipment.Next = 0;
            end;
        end;
        ProductionBOMNo := CurrentItem.ProductionBOMNo(VariantCode, LocationCode);                        // P8001030
        if ProductionBOMNo <> '' then begin                                                              // P8001030
            BOMEquipment.SetRange("Production Bom No.", ProductionBOMNo);                                   // P8001030
            BOMEquipment.SetRange("Version Code", VersionMgt.GetBOMVersion(ProductionBOMNo, WorkDate, true)); // P8001030
            if BOMEquipment.FindSet then
                repeat
                    if Equipment.Get(BOMEquipment."Resource No.") then
                        Equipment.Mark(true);
                until BOMEquipment.Next = 0;
        end;
    end;

    procedure ShowEquipment(EqSummary: Record "Batch Planning Equip. Summary"): Boolean
    begin
        if EqSummary."Equipment Code" = '' then
            exit(false)
        else begin
            if Equipment.Get(EqSummary."Equipment Code") then
                exit(Equipment.Mark);
        end;
    end;

    procedure HighlightEquipment(EquipmentSummary: Record "Batch Planning Equip. Summary"; BatchHighlight: Text[250]; PackageHighlight: Text[250]): Boolean
    begin
        // P8007750 - change BatchHighlight and PackageHighlight to Text250
        EquipmentParameter.Reset;
        EquipmentParameter.SetRange("Production Date", EquipmentSummary."Production Date");
        EquipmentParameter.SetRange("Equipment Code", EquipmentSummary."Equipment Code");
        case EquipmentSummary."Equipment Type" of
            EquipmentSummary."Equipment Type"::Batch:
                EquipmentParameter.SetRange("Highlight Value", BatchHighlight);
            EquipmentSummary."Equipment Type"::Package:
                EquipmentParameter.SetRange("Highlight Value", PackageHighlight);
        end;
        exit(not EquipmentParameter.IsEmpty);
    end;

    procedure HighlightEquipment2(var BatchSummary: Record "Batch Planning - Batch"; BatchHighlight: Text[250])
    begin
        // P8007750 - change BatchHighlight to Text250
        BatchSummary.Highlight := false;
        EquipmentParameter.SetRange("Production Date", ProductionDate);
        EquipmentParameter.SetRange("Equipment Code", BatchSummary."Equipment Code");
        EquipmentParameter.SetRange("Highlight Value", BatchHighlight);
        EquipmentParameter.SetRange("Prod. Order Status");
        EquipmentParameter.SetRange("Prod. Order No.");
        if EquipmentParameter.FindSet then
            repeat
                if not EquipmentParameter.Mark then begin
                    BatchSummary.Highlight := true;
                    exit;
                end;
            until EquipmentParameter.Next = 0;
    end;

    procedure HighlightEquipment3(var PackageSummary: Record "Batch Planning - Package"; PackageHighlight: Text[250])
    begin
        // P8007750 - change PackageHighlight to Text250
        PackageSummary.Highlight := false;
        EquipmentParameter.SetRange("Production Date", ProductionDate);
        EquipmentParameter.SetRange("Equipment Code", PackageSummary."Equipment Code");
        EquipmentParameter.SetRange("Highlight Value", PackageHighlight);
        EquipmentParameter.SetRange("Prod. Order Status");
        EquipmentParameter.SetRange("Prod. Order No.");
        if EquipmentParameter.FindSet then
            repeat
                if not EquipmentParameter.Mark then begin
                    PackageSummary.Highlight := true;
                    exit;
                end;
            until EquipmentParameter.Next = 0;
    end;

    procedure SetPackageHighlight(ItemNo: Code[20]; VariantCode: Code[10])
    begin
        FinishedItem.Get(BPWorksheetName.Name, ItemNo, VariantCode, FinishedItem.Type::Summary, 0);
        if PackageItemHighlight <> FinishedItem."Package Highlight Parameter" then begin
            PackageItemHighlight := FinishedItem."Package Highlight Parameter";
            PackageSummary.Reset;
            if PackageSummary.FindSet(true, false) then
                repeat
                    HighlightEquipment3(PackageSummary, PackageItemHighlight);
                    PackageSummary.Modify;
                until PackageSummary.Next = 0;
        end;
    end;

    procedure GetDailyDetail(var Detail: Record "Batch Planning Order Detail" temporary)
    var
        EntryNo: Integer;
    begin
        Detail.Reset;
        Detail.DeleteAll;

        DailyDetail.Reset;
        if DailyDetail.FindSet then
            repeat
                Detail := DailyDetail;
                Detail.Insert;
            until DailyDetail.Next = 0;
    end;

    procedure InsertDailyDetail(var Detail: Record "Batch Planning Order Detail"): Boolean
    var
        DailyProductionEvent: Record "Daily Production Event";
    begin
        if Detail.Type = Detail.Type::"Event" then
            DailyProductionEvent."Production Date" := Detail."Production Date";
        DailyProductionEvent."Equipment Code" := Detail."Equipment Code";
        DailyProductionEvent."Event Code" := Detail."Event Code";
        DailyProductionEvent."Duration (Hours)" := Detail."Duration (Hours)";
        if DailyProductionEvent.Insert then begin
            Detail."Line No." := DailyProductionEvent."Line No.";
            DailyDetail := Detail; // P8000973
            DailyDetail.Insert;    // P8000973

            DailySummary.Get(Detail."Production Date", Detail."Equipment Code");
            DailySummary."Total Time (Hours)" += Detail."Duration (Hours)";
            DailySummary.Modify;
            TriggerUpdate(1, 'UPDATE SUMMARY');
            exit(true);
        end;
    end;

    procedure ModifyDailyDetail(Detail: Record "Batch Planning Order Detail"): Boolean
    var
        DailyProductionEvent: Record "Daily Production Event";
        xDuration: Decimal;
    begin
        if Detail.Type = Detail.Type::"Event" then
            if DailyProductionEvent.Get(Detail."Production Date", Detail."Equipment Code", Detail."Event Code", Detail."Line No.") then begin
                xDuration := DailyProductionEvent."Duration (Hours)";
                DailyProductionEvent."Duration (Hours)" := Detail."Duration (Hours)";
                if DailyProductionEvent.Modify(true) then begin
                    DailyDetail := Detail; // P8000973
                    DailyDetail.Modify;    // P8000973
                    DailySummary.Get(Detail."Production Date", Detail."Equipment Code");
                    DailySummary."Total Time (Hours)" -= xDuration;
                    DailySummary."Total Time (Hours)" += Detail."Duration (Hours)";
                    DailySummary.Modify;
                    TriggerUpdate(1, 'UPDATE SUMMARY');
                    exit(true);
                end;
            end;
    end;

    procedure DeleteDailyDetail(Detail: Record "Batch Planning Order Detail"): Boolean
    var
        DailyProductionEvent: Record "Daily Production Event";
    begin
        if Detail.Type = Detail.Type::"Event" then
            if DailyProductionEvent.Get(Detail."Production Date", Detail."Equipment Code", Detail."Event Code", Detail."Line No.") then
                if DailyProductionEvent.Delete(true) then begin
                    DailyDetail := Detail; // P8000973
                    DailyDetail.Delete;    // P8000973

                    DailySummary.Get(Detail."Production Date", Detail."Equipment Code");
                    DailySummary."Total Time (Hours)" -= Detail."Duration (Hours)";
                    DailySummary.Modify;
                    TriggerUpdate(1, 'UPDATE SUMMARY');
                    exit(true);
                end;
    end;

    procedure SetSummaryRecordDisplayed(Flag: Boolean)
    begin
        SummaryRecordDisplayed := Flag;
    end;

    procedure GetSummaryRecordDisplayed(): Boolean
    begin
        exit(SummaryRecordDisplayed);
    end;

    procedure InitializePlanningItem(IntermediateItem: Record Item; IntermediateVariant: Code[10]; ProdDate: Date)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SKU: Record "Stockkeeping Unit";
        FinishedItem2: Record "Batch Planning Worksheet Line" temporary;
        FinishedItemTemp: Record "Batch Planning Worksheet Line" temporary;
        BOMEquipment: Record "Prod. BOM Equipment";
        Resource: Record Resource;
        BatchOrderLine: Record "Prod. Order Line";
        PkgOrder: Record "Production Order";
        PkgOrderLine: Record "Prod. Order Line";
        BatchSummarySeq: Record "Batch Planning - Batch" temporary;
        GetPlanningParameters: Codeunit "Planning-Get Parameters";
        VersionMgmt: Codeunit VersionManagement;
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        BatchOrderNo: Code[20];
        SequenceNo: Integer;
        MultiLineOrder: Boolean;
        BatchNo: Integer;
        ProductionBOMNo: Code[20];
        VersionCode: Code[20];
        BOMUOM: Code[10];
        RecalcPackages: Boolean;
    begin
        // P8001030 - Parameter added for IntermediateVariant
        BatchItem := IntermediateItem;
        BatchVariant := IntermediateVariant; // P8001030
        BatchItemHighlight := GetParameter3(BatchItem, // P8006959
          BPWorksheetName."Batch Highlight Field", BPWorksheetName."Batch Highlight Attribute");
        PackageItemHighlight := '';
        ProductionDate := ProdDate;

        // Establish list of finished items
        FinishedItem.Reset;
        FinishedItem.DeleteAll;

        Item.SetRange("Item Type", Item."Item Type"::"Finished Good");
        Item.SetRange("Production Grouping Item", BatchItem."No.");
        Item.SetRange("Production Grouping Variant", BatchVariant); // P8001030
        Item.SetFilter("Production BOM No.", '<>%1', '');
        if Item.FindSet then
            repeat
                FinishedItem.Init;
                FinishedItem."Worksheet Name" := BPWorksheetName.Name;
                FinishedItem."Item No." := Item."No.";
                FinishedItem."Variant Code" := '';
                FinishedItem.Type := FinishedItem.Type::Summary;
                FinishedItem."Line No." := 0;
                FinishedItem."Location Code" := LocationCode;
                FinishedItem."Begin Date" := BeginDate;
                FinishedItem."End Date" := EndDate;
                FinishedItem.Description := Item.Description;
                FinishedItem."Unit of Measure" := Item."Base Unit of Measure";
                Item.GetItemUOMRndgPrecision(Item."Base Unit of Measure", true);
                FinishedItem."Rounding Precision" := Item."Rounding Precision";
                FinishedItem."Intermediate Item No." := BatchItem."No.";
                FinishedItem."Intermediate Variant Code" := BatchVariant; // P8001030
                FinishedItem."Intermediate Description" := BatchItem.Description;
                FinishedItem."Intermediate Unit of Measure" := BatchItem."Base Unit of Measure";
                FinishedItem."Parameter 1" := GetParameter(Item, BatchItem,
                  BPWorksheetName."Parameter 1 Type", BPWorksheetName."Parameter 1 Field", BPWorksheetName."Parameter 1 Attribute");
                FinishedItem."Parameter 2" := GetParameter(Item, BatchItem,
                  BPWorksheetName."Parameter 2 Type", BPWorksheetName."Parameter 2 Field", BPWorksheetName."Parameter 2 Attribute");
                FinishedItem."Parameter 3" := GetParameter(Item, BatchItem,
                  BPWorksheetName."Parameter 3 Type", BPWorksheetName."Parameter 3 Field", BPWorksheetName."Parameter 3 Attribute");
                FinishedItem."Package Highlight Parameter" := GetParameter3(Item, BPWorksheetName."Package Highlight Field", // P8006959
                      BPWorksheetName."Package Highlight Attribute");
                ProductionBOMNo := Item.ProductionBOMNo('', LocationCode);      // P8001030
                if ProductionBOMNo <> '' then begin                            // P8001030
                    FinishedItem.Validate("Production BOM No.", ProductionBOMNo); // P8001030
                    GetPlanningParameters.AtSKU(SKU, FinishedItem."Item No.", '', LocationCode);
                    if SKU."Replenishment System" = SKU."Replenishment System"::"Prod. Order" then begin
                        FinishedItem.GetDemand(Item, SKU."Safety Lead Time", SKU."Manufacturing Policy", FinishedItemTemp); // P8001030
                        FinishedItem."Quantity Required" := FinishedItem."Quantity Remaining"; // P8000933
                        FinishedItem.Insert;
                        if FinishedItemTemp.FindSet then begin
                            FinishedItem2 := FinishedItem;
                            repeat
                                FinishedItem := FinishedItemTemp;
                                FinishedItem.Insert;
                            until FinishedItemTemp.Next = 0;
                            FinishedItem := FinishedItem2;
                        end;
                    end;
                end;  // P8001030
                ItemVariant.SetRange("Item No.", FinishedItem."Item No.");
                if ItemVariant.FindSet then
                    repeat
                        FinishedItem."Variant Code" := ItemVariant.Code;
                        ProductionBOMNo := Item.ProductionBOMNo(ItemVariant.Code, LocationCode); // P8001030
                        if ProductionBOMNo <> '' then begin                                     // P8001030
                            FinishedItem.Validate("Production BOM No.", ProductionBOMNo);          // P8001030
                            GetPlanningParameters.AtSKU(SKU, FinishedItem."Item No.", FinishedItem."Variant Code", LocationCode);
                            if SKU."Replenishment System" = SKU."Replenishment System"::"Prod. Order" then begin
                                FinishedItemTemp.DeleteAll;
                                FinishedItem.GetDemand(Item, SKU."Safety Lead Time", SKU."Manufacturing Policy", FinishedItemTemp); // P8001030
                                FinishedItem."Quantity Required" := FinishedItem."Quantity Remaining"; // P800933
                                FinishedItem.Insert;
                                if FinishedItemTemp.FindSet then begin
                                    FinishedItem2 := FinishedItem;
                                    repeat
                                        FinishedItem := FinishedItemTemp;
                                        FinishedItem.Insert;
                                    until FinishedItemTemp.Next = 0;
                                    FinishedItem := FinishedItem2;
                                end;
                            end;
                        end; // P8001030
                    until ItemVariant.Next = 0;
            until Item.Next = 0;

        // Establish list of batch equipment
        BatchSummary.Reset;
        BatchSummary.DeleteAll;
        BatchDetail.Reset;
        BatchDetail.DeleteAll;

        GetPlanningParameters.AtSKU(SKU, IntermediateItem."No.", BatchVariant, LocationCode); // P8001030
        if SKU."Order Multiple" = 0 then begin
            IntermediateItem.GetItemUOMRndgPrecision(IntermediateItem."Base Unit of Measure", true);
            SKU."Order Multiple" := IntermediateItem."Rounding Precision";
        end;
        if SKU."Maximum Order Quantity" = 0 then
            SKU."Maximum Order Quantity" := 999999999999.0;
        BatchSummary."Entry No." := 0;
        ProductionBOMNo := BatchItem.ProductionBOMNo(BatchVariant, LocationCode); // P8001030
        VersionCode := VersionMgmt.GetBOMVersion(ProductionBOMNo, WorkDate, true); // P8001030
        BOMUOM := VersionMgmt.GetBOMUnitOfMeasure(ProductionBOMNo, VersionCode);  // P8001030
        BOMEquipment.SetCurrentKey(Preference);                                  // P8001030
        BOMEquipment.SetRange("Production Bom No.", ProductionBOMNo);
        BOMEquipment.SetRange("Version Code", VersionCode);
        if BOMEquipment.FindSet then
            repeat
                Resource.Get(BOMEquipment."Resource No.");
                if Resource."Location Code" = LocationCode then begin
                    BatchSummary.Init;
                    BatchSummary."Entry No." += 1;
                    BatchSummary.Summary := true;
                    BatchSummary."Equipment Code" := Resource."No.";
                    BatchSummary."Equipment Description" := Resource.Name;
                    BatchSummary.Capacity := BOMEquipment."Net Capacity";
                    BatchSummary."Capacity UOM" := BOMEquipment."Unit of Measure";
                    BatchSummary."Minimum Equipment Qty." := BOMEquipment."Minimum Equipment Qty."; // P8001107
                    BatchSummary."Order Multiple" := SKU."Order Multiple";
                    BatchSummary."Minimum Order Quantity" := SKU."Minimum Order Quantity";
                    BatchSummary."Maximum Order Quantity" := SKU."Maximum Order Quantity";
                    BatchSummary.ConvertCapacityUOM(IntermediateItem);
                    BatchSummary."Fixed Time" := BOMEquipment."Fixed Prod. Time (Hours)";
                    BatchSummary."Variable Time" := BOMEquipment."Variable Prod. Time (Hours)" *
                      P800UOMFns.GetConversionFromTo(BatchItem."No.", BatchItem."Base Unit of Measure", BOMUOM);
                    DailySummary.Get(ProductionDate, BatchSummary."Equipment Code");
                    BatchSummary."Other Time (Hours)" := DailySummary."Total Time (Hours)";
                    BatchSummary.Insert;
                end;
            until BOMEquipment.Next = 0;

        // Establish lists of package equipment (summary and by item)
        PackageSummary.Reset;
        PackageSummary.DeleteAll;
        PackageDetail[1].Reset;
        PackageDetail[1].DeleteAll;
        FinishedItem.SetRange(Type, FinishedItem.Type::Summary);
        if FinishedItem.FindSet then
            repeat
                BOMUOM := VersionMgmt.GetBOMUnitOfMeasure(FinishedItem."Production BOM No.", FinishedItem."Version Code");
                BOMEquipment.SetRange("Production Bom No.", FinishedItem."Production BOM No.");
                BOMEquipment.SetRange("Version Code", FinishedItem."Version Code");
                if BOMEquipment.FindSet then
                    repeat
                        Resource.Get(BOMEquipment."Resource No.");
                        if Resource."Location Code" = LocationCode then begin
                            PackageDetail[1].Init;
                            PackageDetail[1]."Batch No." := 0;
                            PackageDetail[1]."Equipment Code" := Resource."No.";
                            PackageDetail[1]."Equipment Description" := Resource.Name;
                            PackageDetail[1]."Item No." := FinishedItem."Item No.";
                            PackageDetail[1]."Item Description" := FinishedItem.Description;
                            PackageDetail[1]."Variant Code" := FinishedItem."Variant Code";
                            PackageDetail[1]."Unit of Measure" := FinishedItem."Unit of Measure";
                            PackageDetail[1]."Fixed Time" := BOMEquipment."Fixed Prod. Time (Hours)";
                            PackageDetail[1]."Variable Time" := BOMEquipment."Variable Prod. Time (Hours)" *
                              P800UOMFns.GetConversionFromTo(FinishedItem."Item No.", FinishedItem."Unit of Measure", BOMUOM);
                            PackageDetail[1]."Intermediate Quantity per" := FinishedItem."Intermediate Quantity per";
                            PackageDetail[1]."Rounding Precision" := FinishedItem."Rounding Precision";
                            PackageDetail[1].Insert;

                            PackageSummary := PackageDetail[1];
                            PackageSummary."Item No." := '';
                            PackageSummary."Item Description" := '';
                            PackageSummary."Variant Code" := '';
                            PackageSummary."Fixed Time" := 0;
                            PackageSummary."Variable Time" := 0;
                            PackageSummary."Intermediate Quantity per" := 0;
                            PackageSummary."Rounding Precision" := 0;
                            if not PackageSummary.Find then begin
                                DailySummary.Get(ProductionDate, PackageSummary."Equipment Code");
                                PackageSummary."Other Time (Hours)" := DailySummary."Total Time (Hours)";
                                PackageSummary.Insert;
                            end;
                        end;
                    until BOMEquipment.Next = 0;
            until FinishedItem.Next = 0;

        // Populate BatchDetail and PackageDetail with existing orders
        ExistingOrders := false;
        TotalBatchQty := 0;
        ManualQtyRequired := 0;
        FinishedQtyRequired := 0;

        BatchSummary.Reset;
        PackageDetail[1].Reset;
        PackageDetail[1].SetRange("Batch No.", 0);

        DailyDetail.Reset;
        DailyDetail.ModifyAll("Pending Deletion", false);

        EquipmentParameter.Reset;

        BatchOrderLine.SetCurrentKey(Status, "Item No.", "Variant Code", "Location Code", "Starting Date");
        BatchOrderLine.SetRange(Status, BatchOrderLine.Status::"Firm Planned", BatchOrderLine.Status::Released);
        BatchOrderLine.SetRange("Item No.", BatchItem."No.");
        BatchOrderLine.SetRange("Variant Code", BatchVariant); // P8001030
        BatchOrderLine.SetRange("Location Code", LocationCode);
        BatchOrderLine.SetRange("Starting Date", ProductionDate);
        if BatchOrderLine.FindSet then begin
            ExistingOrders := true;
            MultiLineOrder := true;
            BatchOrderNo := BatchOrderLine."Prod. Order No.";
            repeat
                if BatchOrderNo <> BatchOrderLine."Prod. Order No." then
                    MultiLineOrder := false;

                if DailyDetail.Get(ProductionDate, BatchOrderLine."Equipment Code", DailyDetail.Type::Order,
                  '', BatchOrderLine.Status, BatchOrderLine."Prod. Order No.", 0)
                then begin
                    DailyDetail."Pending Deletion" := true;
                    DailyDetail.Modify;
                end;

                BatchSummary.SetRange("Equipment Code", BatchOrderLine."Equipment Code");
                BatchSummary.FindFirst;
                if not BatchSummary.Include then begin
                    SequenceNo += 1;
                    BatchSummary.Sequence := SequenceNo;
                    BatchSummary.Include := true;
                end;
                BatchSummary."Other Time (Hours)" -=
                  Round((BatchOrderLine."Ending Date-Time" - BatchOrderLine."Starting Date-Time") / 3600000, 0.001);
                BatchSummary.Modify;

                EquipmentParameter.SetRange("Production Date", BatchOrderLine."Starting Date");
                EquipmentParameter.SetRange("Equipment Code", BatchOrderLine."Equipment Code");
                EquipmentParameter.SetRange("Highlight Value");
                EquipmentParameter.SetRange("Prod. Order Status", BatchOrderLine.Status);
                EquipmentParameter.SetRange("Prod. Order No.", BatchOrderLine."Prod. Order No.");
                if EquipmentParameter.FindSet then
                    repeat
                        EquipmentParameter.Mark(true);
                    until EquipmentParameter.Next = 0;

                BatchDetail.Init;
                BatchDetail."Entry No." += 1;
                BatchDetail."Equipment Code" := BatchOrderLine."Equipment Code";
                BatchDetail.Sequence := BatchSummary.Sequence;
                BatchDetail."Equipment Entry No." := BatchSummary."Entry No.";
                BatchDetail."Batch Size" := BatchOrderLine.Quantity;
                BatchDetail."Remaining Batch Quantity" := BatchDetail."Batch Size";
                BatchDetail."Order Status" := BatchOrderLine.Status;
                BatchDetail."Order No." := BatchOrderLine."Prod. Order No.";
                BatchDetail.Insert;
                TotalBatchQty += BatchDetail."Batch Size";
            until BatchOrderLine.Next = 0;
        end;

        BatchSummary.Reset;
        BatchSummary.SetRange(Include, false);
        if BatchSummary.FindSet(true, false) then
            repeat
                SequenceNo += 1;
                BatchSummary.Sequence := SequenceNo;
                HighlightEquipment2(BatchSummary, BatchItemHighlight);
                BatchSummary.Modify;
            until BatchSummary.Next = 0;
        BatchSummary.Reset;

        AssignBatchNo;

        // If existing order is a multi-line order and the setting is now to not create multi-line orders then
        // there is nothing we can do to retain the existing package orders
        RecalcPackages := MultiLineOrder and (not BPWorksheetName."Create Multi-line Orders");

        if not RecalcPackages then begin
            // Create Package Detail for the batch
            BatchDetail.Reset;
            if BatchDetail.FindSet then
                repeat
                    if PackageDetail[1].FindSet then
                        repeat
                            PackageDetail[2] := PackageDetail[1];
                            PackageDetail[2]."Batch No." := BatchDetail."Batch No.";
                            // P8000972
                            //PackageDetail[2]."Maximum Quantity Possible" :=
                            //  ROUND(BatchDetail."Batch Size" / PackageDetail[2]."Intermediate Quantity per",
                            //  PackageDetail[2]."Rounding Precision");
                            //IF PackageDetail[1]."Maximum Quantity Possible" < PackageDetail[2]."Maximum Quantity Possible" THEN
                            //  PackageDetail[2]."Maximum Quantity Possible" := PackageDetail[1]."Maximum Quantity Possible";
                            //PackageDetail[2]."Additional Quantity Possible" := PackageDetail[2]."Maximum Quantity Possible";
                            // P8000972
                            PackageDetail[2].Insert;
                        until PackageDetail[1].Next = 0;
                until BatchDetail.Next = 0;
        end;

        PkgOrder.SetCurrentKey(Status, "Batch Prod. Order No.", "No.");
        if BatchDetail.FindSet then
            repeat
                if BPWorksheetName."Create Multi-line Orders" then
                    BatchNo := 0
                else
                    BatchNo := BatchDetail."Batch No.";
                PkgOrder.SetRange(Status, BatchDetail."Order Status");
                PkgOrder.SetRange("Batch Prod. Order No.", BatchDetail."Order No.");
                PkgOrder.SetFilter("No.", '<>%1', BatchDetail."Order No.");
                if PkgOrder.FindSet then
                    repeat
                        PkgOrderLine.SetRange(Status, PkgOrder.Status);
                        PkgOrderLine.SetRange("Prod. Order No.", PkgOrder."No.");
                        if PkgOrderLine.FindSet then
                            repeat
                                if not PkgOrderLine.Mark then begin
                                    if DailyDetail.Get(ProductionDate, PkgOrderLine."Equipment Code", DailyDetail.Type::Order,
                                      '', PkgOrderLine.Status, PkgOrderLine."Prod. Order No.", 0)
                                    then begin
                                        DailyDetail."Pending Deletion" := true;
                                        DailyDetail.Modify;
                                    end;

                                    FinishedItem.Get(BPWorksheetName.Name, PkgOrderLine."Item No.", PkgOrderLine."Variant Code",
                                      FinishedItem.Type::Summary, 0);
                                    FinishedItem.Include := true;
                                    FinishedItem."Quantity to Produce" += PkgOrderLine.Quantity;
                                    FinishedItem."Quantity Required" += PkgOrderLine.Quantity; // P800933
                                    FinishedItem.CalcRemainingQtyToProduce;

                                    if not RecalcPackages then begin
                                        if PackageDetail[1].Get(BatchNo, PkgOrderLine."Equipment Code",
                                          PkgOrderLine."Item No.", PkgOrderLine."Variant Code")
                                        then begin
                                            PackageSummary.Get(0, PackageDetail[1]."Equipment Code", '');
                                            PackageDetail[1].Quantity += PkgOrderLine.Quantity;
                                            PackageDetail[1].CalculateTime;
                                            PackageDetail[1].Modify;
                                            PackageSummary."Package Time (Hours)" += PackageDetail[1]."Production Time (Hours)";
                                            PackageSummary."Other Time (Hours)" -=
                                              Round((PkgOrderLine."Ending Date-Time" - PkgOrderLine."Starting Date-Time") / 3600000,
                                              0.001);
                                            PackageSummary.Modify;

                                            BatchDetail."Remaining Batch Quantity" -= PackageDetail[1].Quantity * FinishedItem."Intermediate Quantity per";
                                            BatchDetail.Modify;
                                        end;
                                    end else begin
                                        FinishedItem."Remaining Quantity to Pack" += PkgOrderLine.Quantity;
                                    end;
                                    FinishedItem.Modify;
                                    FinishedQtyRequired += PkgOrderLine.Quantity * FinishedItem."Intermediate Quantity per";
                                    PkgOrderLine.Mark(true);

                                    EquipmentParameter.SetRange("Production Date", PkgOrderLine."Starting Date");
                                    EquipmentParameter.SetRange("Equipment Code", PkgOrderLine."Equipment Code");
                                    EquipmentParameter.SetRange("Highlight Value");
                                    EquipmentParameter.SetRange("Prod. Order Status", PkgOrderLine.Status);
                                    EquipmentParameter.SetRange("Prod. Order No.", PkgOrderLine."Prod. Order No.");
                                    if EquipmentParameter.FindSet then
                                        repeat
                                            EquipmentParameter.Mark(true);
                                        until EquipmentParameter.Next = 0;
                                end;
                            until PkgOrderLine.Next = 0;
                    until PkgOrder.Next = 0;
            until BatchDetail.Next = 0;

        DailyDetail.Reset;

        FinishedItem.Reset;
        FinishedItem.SetRange(Type, FinishedItem.Type::Summary);
        //PackageDetail[1].RESET; // P8000972
        if FinishedItem.FindSet then
            repeat
                if FinishedItem.Include then
                    FinishedItem."Additional Quantity Possible" :=
                      Round((TotalBatchQty - FinishedQtyRequired) / FinishedItem."Intermediate Quantity per",
                      FinishedItem."Rounding Precision", '<')
                else
                    FinishedItem."Additional Quantity Possible" := 0;
                FinishedItem.Modify;

                PackageDetail[1].Reset; // P8000972
                PackageDetail[1].SetRange("Item No.", FinishedItem."Item No.");
                PackageDetail[1].SetRange("Variant Code", FinishedItem."Variant Code");
                PackageDetail[1].ModifyAll(Include, FinishedItem.Include);

                // P8000972
                if not RecalcPackages then begin
                    PackageDetail[1].SetRange("Batch No.", 0);
                    PackageDetail[1].ModifyAll("Maximum Quantity Possible", FinishedItem."Quantity to Produce");
                end;
            // P8000972
            until FinishedItem.Next = 0;
        PackageDetail[1].Reset;

        if RecalcPackages then
            CalculatePackageOrders
        // P8000972
        else begin
            PackageDetail[1].SetRange("Batch No.", 0);
            BatchDetail.Reset;
            if BatchDetail.FindSet then
                repeat
                    if PackageDetail[1].FindSet then
                        repeat
                            PackageDetail[2].Get(BatchDetail."Batch No.", PackageDetail[1]."Equipment Code",
                              PackageDetail[1]."Item No.", PackageDetail[1]."Variant Code");
                            PackageDetail[2]."Maximum Quantity Possible" :=
                              Round(BatchDetail."Batch Size" / PackageDetail[2]."Intermediate Quantity per",
                              PackageDetail[2]."Rounding Precision");
                            if PackageDetail[1]."Maximum Quantity Possible" < PackageDetail[2]."Maximum Quantity Possible" then
                                PackageDetail[2]."Maximum Quantity Possible" := PackageDetail[1]."Maximum Quantity Possible";
                            PackageDetail[2].Modify;
                        until PackageDetail[1].Next = 0;
                until BatchDetail.Next = 0;
            PackageDetail[1].Reset;
        end;
        // P8000972
    end;

    procedure ClearBatches()
    begin
        BatchDetail.Reset;
        BatchDetail.DeleteAll;
        TotalBatchQty := 0;
        FinishedQtyRequired := 0;
    end;

    procedure CalculateBatches(UpdateRequired: Boolean)
    var
        EntryNo: Integer;
        QtyRequired: Decimal;
    begin
        BatchDetail.Reset;
        BatchDetail.DeleteAll;
        TotalBatchQty := 0;
        FinishedQtyRequired := 0;

        BatchSummary.Reset;
        BatchSummary.SetCurrentKey(Sequence);
        BatchSummary.SetRange(Include, true);
        if BatchSummary.FindSet(true, false) then begin
            repeat
                if BatchSummary.Batches <> 0 then
                    BatchSummary."Batches Remaining" := BatchSummary.Batches
                else
                    BatchSummary."Batches Remaining" := 2147483647;
                BatchSummary.Modify;
            until BatchSummary.Next = 0;
        end else begin
            CalculateAdditional(0);
            if UpdateRequired then
                TriggerUpdate(2, 'CALCULATE BATCH');
            exit;
        end;

        FinishedItem.Reset;
        FinishedItem.SetRange(Type, FinishedItem.Type::Summary);
        FinishedItem.SetRange(Include, true);
        FinishedItem.SetFilter("Quantity to Produce", '>0');
        if FinishedItem.FindSet then begin
            repeat
                FinishedQtyRequired += FinishedItem."Quantity to Produce" * FinishedItem."Intermediate Quantity per";
            until FinishedItem.Next = 0;
            FinishedQtyRequired := Round(FinishedQtyRequired, 0.00001);
        end;

        if ManualQtyRequired > FinishedQtyRequired then
            QtyRequired := ManualQtyRequired
        else
            QtyRequired := FinishedQtyRequired;

        BatchSummary.SetFilter("Batches Remaining", '>0');
        BatchSummary.SetFilter("Maximum Order Quantity", '>0'); // P8000991
        BatchSummary.Find('+');
        while (TotalBatchQty < QtyRequired) and (not BatchSummary.IsEmpty) do begin
            EntryNo += 1;
            if BatchSummary.Next = 0 then
                BatchSummary.FindSet(true, false);
            BatchDetail.Init;
            BatchDetail."Entry No." := EntryNo;
            BatchDetail."Equipment Code" := BatchSummary."Equipment Code";
            BatchDetail.Sequence := BatchSummary.Sequence;
            BatchDetail."Equipment Entry No." := BatchSummary."Entry No.";
            BatchDetail."Batch Size" := BatchSummary.SetBatchSize(QtyRequired - TotalBatchQty);
            BatchDetail."Remaining Batch Quantity" := BatchDetail."Batch Size";
            BatchDetail.Insert;
            BatchSummary."Batches Remaining" -= 1;
            BatchSummary.Modify;
            TotalBatchQty += BatchDetail."Batch Size";
        end;
        if TotalBatchQty < QtyRequired then
            Error(Text005);

        AssignBatchNo;
        CalculateAdditional(TotalBatchQty - FinishedQtyRequired);
        CalculatePackageOrders;
        if UpdateRequired then
            TriggerUpdate(2, 'CALCULATE BATCH');
    end;

    procedure AssignBatchNo()
    var
        BatchNo: Integer;
    begin
        BatchSummary.Reset;
        BatchSummary.ModifyAll("Batch Time (Hours)", 0);
        BatchSummary.SetCurrentKey(Sequence);
        BatchDetail.Reset;
        if BatchSummary.FindSet(true, false) then
            repeat
                BatchDetail.SetRange("Equipment Code", BatchSummary."Equipment Code");
                if BatchDetail.FindSet(true, false) then begin
                    repeat
                        BatchNo += 1;
                        BatchDetail."Batch No." := BatchNo;
                        BatchDetail."Production Time (Hours)" :=
                          BatchSummary."Fixed Time" + (BatchSummary."Variable Time" * BatchDetail."Batch Size");
                        BatchDetail.Modify;
                        BatchSummary."Batch Time (Hours)" += BatchDetail."Production Time (Hours)";
                    until BatchDetail.Next = 0;
                    BatchSummary.Modify;
                end;
            until BatchSummary.Next = 0;
        BatchDetail.Reset;
    end;

    procedure CalculateAdditional(AdditionalQty: Decimal)
    begin
        FinishedItem.Reset;
        FinishedItem.SetRange(Type, FinishedItem.Type::Summary);
        FinishedItem.FindSet(true, false);
        repeat
            if FinishedItem.Include then
                FinishedItem."Additional Quantity Possible" :=
                  Round(AdditionalQty / FinishedItem."Intermediate Quantity per", FinishedItem."Rounding Precision", '<')
            else
                FinishedItem."Additional Quantity Possible" := 0;
            FinishedItem.Modify;
        until FinishedItem.Next = 0;
    end;

    procedure CalculatePackageOrders()
    var
        IntermediateRequired: Decimal;
        MinimumQty: Decimal;
        PackageQty: Decimal;
        Stop: Boolean;
    begin
        PackageSummary.Reset;
        PackageSummary.ModifyAll("Package Time (Hours)", 0);
        PackageDetail[1].Reset;
        PackageDetail[1].SetFilter("Batch No.", '<>0');
        PackageDetail[1].DeleteAll;
        PackageDetail[1].Reset;
        PackageDetail[2].Reset;
        BatchDetail.Reset;


        PackageDetail[1].SetRange("Batch No.", 0);
        if PackageDetail[1].FindSet(true, false) then
            repeat
                // Initialize detail records for batch 0 (used as a prototype for other batches and for multi-line batches)
                FinishedItem.Get(BPWorksheetName.Name, PackageDetail[1]."Item No.", PackageDetail[1]."Variant Code",
                  FinishedItem.Type::Summary, 0);
                PackageDetail[1]."Maximum Quantity Possible" := FinishedItem."Quantity to Produce";
                PackageDetail[1]."Additional Quantity Possible" := FinishedItem."Quantity to Produce";
                PackageDetail[1].Quantity := 0;
                PackageDetail[1]."Package Time (Hours)" := 0;
                PackageDetail[1].Modify;
                if not BPWorksheetName."Create Multi-line Orders" then begin
                    if BatchDetail.FindSet then
                        repeat
                            // Initialize detail records for each batch (used for single line batch orders)
                            PackageDetail[2] := PackageDetail[1];
                            PackageDetail[2]."Batch No." := BatchDetail."Batch No.";
                            PackageDetail[2]."Maximum Quantity Possible" :=
                              Round(BatchDetail."Batch Size" / PackageDetail[2]."Intermediate Quantity per",
                              PackageDetail[2]."Rounding Precision");
                            if PackageDetail[1]."Maximum Quantity Possible" < PackageDetail[2]."Maximum Quantity Possible" then
                                PackageDetail[2]."Maximum Quantity Possible" := PackageDetail[1]."Maximum Quantity Possible";
                            PackageDetail[2]."Additional Quantity Possible" := PackageDetail[2]."Maximum Quantity Possible";
                            PackageDetail[2].Insert;
                        until BatchDetail.Next = 0;
                end;
            until PackageDetail[1].Next = 0;
        PackageDetail[1].Reset;

        if not BatchDetail.FindSet(true, false) then
            exit;

        // Start consuming the batches and assign them to package orders
        // For multi-line batch orders there will only be a single package order for each finished items and
        //    it will be tracked against batch 0
        // For single line batch orders ech finished item can have multiple package orders tracked against
        //    the specific batches
        RemainingBatchQtyToPack := TotalBatchQty;
        FinishedItem.Reset;
        FinishedItem.SetRange(Type, FinishedItem.Type::Summary);
        FinishedItem.SetRange(Include, true);
        if FinishedItem.FindSet(true, false) then begin
            PackageDetail[1].SetRange("Batch No.", 0);
            repeat
                FinishedItem."Remaining Quantity to Pack" := FinishedItem."Quantity to Produce";
                PackageDetail[1].SetRange("Item No.", FinishedItem."Item No.");
                PackageDetail[1].SetRange("Variant Code", FinishedItem."Variant Code");
                if PackageDetail[1].FindSet(true, false) then begin
                    // Can only create package orders if there is only a single equipment for the item
                    // Otherwise the user must assign the equipment and create the package orders manually
                    if PackageDetail[1].Next = 0 then begin
                        PackageSummary.Get(0, PackageDetail[1]."Equipment Code");
                        IntermediateRequired := FinishedItem."Remaining Quantity to Pack" * FinishedItem."Intermediate Quantity per";
                        MinimumQty := FinishedItem."Rounding Precision" * FinishedItem."Intermediate Quantity per";
                        if BPWorksheetName."Create Multi-line Orders" then begin
                            PackageDetail[1].Quantity := FinishedItem."Quantity to Produce";
                            PackageDetail[1].CalculateTime;
                            PackageDetail[1]."Additional Quantity Possible" := 0;
                            PackageDetail[1].Modify;
                            RemainingBatchQtyToPack -= FinishedItem."Quantity to Produce" * FinishedItem."Intermediate Quantity per";
                            FinishedItem."Remaining Quantity to Pack" := 0;
                            PackageSummary."Package Time (Hours)" += PackageDetail[1]."Production Time (Hours)";
                        end else begin
                            while (MinimumQty < IntermediateRequired) and (not Stop) do begin
                                if IntermediateRequired < BatchDetail."Remaining Batch Quantity" then
                                    PackageQty := IntermediateRequired
                                else
                                    PackageQty := BatchDetail."Remaining Batch Quantity";
                                PackageQty := Round(PackageQty / FinishedItem."Intermediate Quantity per", FinishedItem."Rounding Precision");
                                BatchDetail."Remaining Batch Quantity" -= PackageQty * FinishedItem."Intermediate Quantity per";
                                FinishedItem."Remaining Quantity to Pack" -= PackageQty;
                                IntermediateRequired := FinishedItem."Remaining Quantity to Pack" * FinishedItem."Intermediate Quantity per";
                                PackageDetail[2].Get(BatchDetail."Batch No.", PackageDetail[1]."Equipment Code",
                                  FinishedItem."Item No.", FinishedItem."Variant Code");
                                PackageDetail[2].Quantity := PackageQty;
                                PackageDetail[2].CalculateTime;
                                PackageDetail[2]."Additional Quantity Possible" := 0;
                                PackageDetail[2].Mark(true);
                                PackageDetail[2].Modify;
                                PackageSummary."Package Time (Hours)" += PackageDetail[2]."Production Time (Hours)";
                                PackageDetail[2].SetRange("Batch No.", BatchDetail."Batch No.");
                                if PackageDetail[2].FindSet(true, false) then
                                    repeat
                                        if PackageDetail[2].Mark then
                                            PackageDetail[2].Mark(false)
                                        else begin
                                            PackageDetail[2].Validate("Additional Quantity Possible",
                                              Round(BatchDetail."Remaining Batch Quantity" / PackageDetail[2]."Intermediate Quantity per",
                                              PackageDetail[2]."Rounding Precision"));
                                            PackageDetail[2].Modify;
                                        end;
                                    until PackageDetail[2].Next = 0;
                                PackageDetail[2].SetRange("Batch No.");
                                BatchDetail.Modify;
                                if BatchDetail."Remaining Batch Quantity" < MinimumQty then
                                    Stop := BatchDetail.Next = 0;
                            end;
                        end;
                        PackageSummary.Modify;
                    end;
                    FinishedItem.Modify;
                end;
            until (FinishedItem.Next = 0) or Stop;
        end;
    end;

    procedure GetFinishedItems(var BPFinishedItem: Record "Batch Planning Worksheet Line")
    begin
        BPFinishedItem.Reset;
        BPFinishedItem.DeleteAll;

        FinishedItem.Reset;
        FinishedItem.SetRange(Type, FinishedItem.Type::Summary);
        if FinishedItem.FindSet then
            repeat
                BPFinishedItem := FinishedItem;
                BPFinishedItem.Insert;
            until FinishedItem.Next = 0;
    end;

    procedure ModifyFinishedItem(BPItem: Record "Batch Planning Worksheet Line"; Recalc: Boolean)
    begin
        FinishedItem := BPItem;
        FinishedItem.Modify;

        PackageDetail[1].Reset;
        PackageDetail[1].SetRange("Item No.", FinishedItem."Item No.");
        PackageDetail[1].SetRange("Variant Code", FinishedItem."Variant Code");
        PackageDetail[1].ModifyAll(Include, FinishedItem.Include);
        PackageDetail[1].Reset;

        if Recalc then
            CalculateBatches(false);
    end;

    procedure ShowFinishedItemDetail(CurrentRec: Record "Batch Planning Worksheet Line")
    var
        BPWorksheetLine: Record "Batch Planning Worksheet Line";
    begin
        FinishedItem.Reset;
        FinishedItem.FilterGroup(9);
        FinishedItem.SetRange("Item No.", CurrentRec."Item No.");
        FinishedItem.SetRange("Variant Code", CurrentRec."Variant Code");
        FinishedItem.SetRange(Type, FinishedItem.Type::Detail);
        FinishedItem.FilterGroup(9);
        PAGE.Run(PAGE::"Batch Planning Wrksheet Detail", FinishedItem);
        FinishedItem.Reset;
    end;

    procedure GetBatchItem(var Item: Record Item)
    begin
        Item := BatchItem;
    end;

    procedure GetBatches(var BPBatch: Record "Batch Planning - Batch")
    var
        EntryNo: Integer;
    begin
        BPBatch.Reset;
        BPBatch.DeleteAll;

        BatchSummary.Reset;
        BatchSummary.SetCurrentKey(Sequence);
        BatchDetail.Reset;
        if BatchSummary.FindSet then
            repeat
                EntryNo += 1;
                BPBatch := BatchSummary;
                BPBatch."Entry No." := EntryNo;
                BPBatch."Equipment Entry No." := BatchSummary."Entry No.";
                if not BPWorksheetName."Create Multi-line Orders" then
                    BPBatch."Batch No. Link" := -1;
                BPBatch.Insert;
                BatchDetail.SetRange("Equipment Code", BatchSummary."Equipment Code");
                if BatchDetail.FindSet then begin
                    BPBatch."Batch No." := BatchDetail."Batch No.";
                    if not BPWorksheetName."Create Multi-line Orders" then
                        BPBatch."Batch No. Link" := BPBatch."Batch No.";
                    BPBatch."Batch Size" := BatchDetail."Batch Size";
                    BPBatch."Production Time (Hours)" := BatchDetail."Production Time (Hours)";
                    BPBatch.Modify;
                    BPBatch.Summary := false;
                    BPBatch.Highlight := false;
                    BPBatch.Include := false;
                    while BatchDetail.Next <> 0 do begin
                        EntryNo += 1;
                        BPBatch."Entry No." := EntryNo;
                        BPBatch."Batch No." := BatchDetail."Batch No.";
                        if not BPWorksheetName."Create Multi-line Orders" then
                            BPBatch."Batch No. Link" := BPBatch."Batch No.";
                        BPBatch."Batch Size" := BatchDetail."Batch Size";
                        BPBatch."Production Time (Hours)" := BatchDetail."Production Time (Hours)"; // P80062449
                        BPBatch.Insert;
                    end;
                end;
            until BatchSummary.Next = 0;
    end;

    procedure ModifyQtyRequired(QtyReqd: Decimal)
    begin
        if QtyReqd < FinishedQtyRequired then
            Error(Text004)
        else begin
            ManualQtyRequired := QtyReqd;
            BatchDetail.Reset;
            BatchDetail.DeleteAll;
            CalculateBatches(true);
        end;
    end;

    procedure ModifyBatches(Batch: Record "Batch Planning - Batch"; Recalc: Boolean)
    begin
        BatchSummary.Get(Batch."Equipment Entry No.");

        Recalc := Recalc and
          ((BatchSummary.Include <> Batch.Include) or
           (Batch.Include and
            ((BatchSummary.Sequence = Batch.Sequence) or (BatchSummary.Batches = Batch.Batches))));
        BatchSummary.Include := Batch.Include;
        BatchSummary.Sequence := Batch.Sequence;
        BatchSummary.Batches := Batch.Batches;
        BatchSummary."Batch Time (Hours)" := 0; // P8000973
        BatchSummary.Modify;

        if Recalc then begin
            BatchDetail.Reset;
            if BatchSummary.Include then
                BatchDetail.DeleteAll
            else begin
                BatchDetail.SetRange("Equipment Code", BatchSummary."Equipment Code");
                BatchDetail.DeleteAll;
            end;
            BatchDetail.Reset;

            CalculateBatches(true);
        end;
    end;

    procedure GetBatchSummary(var BatchTotal: Decimal; var Required: Decimal)
    begin
        if TotalBatchQty < ManualQtyRequired then
            BatchTotal := ManualQtyRequired
        else
            BatchTotal := TotalBatchQty;
        Required := FinishedQtyRequired;
    end;

    procedure GetPackages(var BPPackage: Record "Batch Planning - Package"; Mode: Code[10])
    var
        BatchNo: Integer;
        EquipmentCode: Code[20];
    begin
        BatchNo := -1;

        BPPackage.Reset;
        BPPackage.DeleteAll;

        PackageSummary.Reset;
        PackageDetail[1].Reset;
        case Mode of
            'BATCH':
                PackageDetail[1].SetCurrentKey("Batch No.", "Equipment Code");
            'ITEM':
                PackageDetail[1].SetCurrentKey("Item No.", "Equipment Code");
        end;
        PackageDetail[1].SetRange(Include, true);
        if PackageDetail[1].FindSet then
            repeat
                BPPackage := PackageDetail[1];
                if ((Mode = 'BATCH') and ((BPPackage."Equipment Code" <> EquipmentCode) or (BPPackage."Batch No." <> BatchNo))) or
                   ((Mode = 'ITEM') and (BPPackage."Batch No." in [0, 1]))
                then begin
                    PackageSummary.Get(0, BPPackage."Equipment Code");
                    BPPackage."Package Time (Hours)" := PackageSummary."Package Time (Hours)";
                    BPPackage."Other Time (Hours)" := PackageSummary."Other Time (Hours)";
                    BPPackage.Highlight := PackageSummary.Highlight;
                    BPPackage.Summary := true;
                    BatchNo := BPPackage."Batch No.";
                    EquipmentCode := BPPackage."Equipment Code";
                end;
                BPPackage.Insert;
            until PackageDetail[1].Next = 0;
    end;

    procedure ModifyPackages(BPPackage: Record "Batch Planning - Package"; Update: Boolean): Boolean
    var
        QuantityChange: Decimal;
        BatchQuantityChange: Decimal;
        RemainingBatchQuantity: Decimal;
    begin
        PackageDetail[1].Reset;
        PackageDetail[1].Get(BPPackage."Batch No.", BPPackage."Equipment Code", BPPackage."Item No.", BPPackage."Variant Code");
        QuantityChange := BPPackage.Quantity - PackageDetail[1].Quantity;
        if QuantityChange = 0 then
            exit;

        BatchQuantityChange := QuantityChange * PackageDetail[1]."Intermediate Quantity per";
        if BPWorksheetName."Create Multi-line Orders" then
            RemainingBatchQtyToPack -= BatchQuantityChange
        else begin
            BatchDetail.Reset;
            BatchDetail.SetRange("Batch No.", BPPackage."Batch No.");
            BatchDetail.FindFirst;
            BatchDetail."Remaining Batch Quantity" -= BatchQuantityChange;
            BatchDetail.Modify;
        end;

        PackageSummary.Get(0, BPPackage."Equipment Code");
        PackageSummary."Package Time (Hours)" -= PackageDetail[1]."Production Time (Hours)";
        PackageDetail[1].Quantity := BPPackage.Quantity;
        PackageDetail[1].CalculateTime;
        PackageDetail[1].Modify;
        PackageSummary."Package Time (Hours)" += PackageDetail[1]."Production Time (Hours)";
        PackageSummary.Modify;

        FinishedItem.Get(BPWorksheetName.Name, PackageDetail[1]."Item No.", PackageDetail[1]."Variant Code",
          FinishedItem.Type::Summary, 0);
        FinishedItem."Remaining Quantity to Pack" -= QuantityChange;
        FinishedItem.Modify;

        // Adjust additional quantity possible for records in the batch
        PackageDetail[1].Reset;
        PackageDetail[1].SetRange("Batch No.", BPPackage."Batch No.");
        if BPWorksheetName."Create Multi-line Orders" then
            RemainingBatchQuantity := RemainingBatchQtyToPack
        else
            RemainingBatchQuantity := BatchDetail."Remaining Batch Quantity";
        if PackageDetail[1].FindSet(true, false) then
            repeat
                FinishedItem.Get(BPWorksheetName.Name, PackageDetail[1]."Item No.", PackageDetail[1]."Variant Code",
                  FinishedItem.Type::Summary, 0);
                PackageDetail[1]."Additional Quantity Possible" :=
                  Round(RemainingBatchQuantity / PackageDetail[1]."Intermediate Quantity per",
                  PackageDetail[1]."Rounding Precision");
                if PackageDetail[1]."Additional Quantity Possible" > FinishedItem."Remaining Quantity to Pack" then
                    PackageDetail[1]."Additional Quantity Possible" := FinishedItem."Remaining Quantity to Pack";
                PackageDetail[1].Validate("Additional Quantity Possible");
                PackageDetail[1].Modify;
            until PackageDetail[1].Next = 0;

        // Addjust additional quantity possible for other records for same item in other batches
        PackageDetail[1].Reset;
        PackageDetail[1].SetFilter("Batch No.", '<>0&<>%1', BPPackage."Batch No.");
        PackageDetail[1].SetRange("Item No.", BPPackage."Item No.");
        PackageDetail[1].SetRange("Variant Code", BPPackage."Variant Code");
        FinishedItem.Get(BPWorksheetName.Name, BPPackage."Item No.", BPPackage."Variant Code", FinishedItem.Type::Summary, 0);
        if PackageDetail[1].FindSet(true, false) then
            repeat
                if BPWorksheetName."Create Multi-line Orders" then
                    RemainingBatchQuantity := RemainingBatchQtyToPack
                else begin
                    BatchDetail.SetRange("Batch No.", PackageDetail[1]."Batch No.");
                    BatchDetail.FindFirst;
                    RemainingBatchQuantity := BatchDetail."Remaining Batch Quantity";
                end;
                PackageDetail[1]."Additional Quantity Possible" :=
                  Round(RemainingBatchQuantity / PackageDetail[1]."Intermediate Quantity per",
                  PackageDetail[1]."Rounding Precision");
                if PackageDetail[1]."Additional Quantity Possible" > FinishedItem."Remaining Quantity to Pack" then
                    PackageDetail[1]."Additional Quantity Possible" := FinishedItem."Remaining Quantity to Pack";
                PackageDetail[1].Validate("Additional Quantity Possible");
                PackageDetail[1].Modify;
            until PackageDetail[1].Next = 0;
        PackageDetail[1].Reset;

        if Update then begin
            TriggerUpdate(2, 'PACKAGE QUANTITY');
            exit(true);
        end;
    end;

    procedure CreateBatchOrders(): Boolean
    var
        WorksheetLine: Record "Batch Planning Worksheet Line";
        MfgSetup: Record "Manufacturing Setup";
        ProcessSetup: Record "Process Setup";
        BatchOrder: Record "Production Order";
        BatchOrderLine: Record "Prod. Order Line";
        PkgOrder: Record "Production Order";
        PkgOrderLine: Record "Prod. Order Line";
        CreateOrder: Page "Create Production Orders";
        P800ProdOrderMgmt: Codeunit "Process 800 Prod. Order Mgt.";
        ProdOrderCalculate: Codeunit "Calculate Prod. Order";
        ProdOrderStatusMgt: Codeunit "Prod. Order Status Management";
        OrderCount: Integer;
        Status: Integer;
        Direction: Integer;
        DimensionSetID: Integer;
        Filler: Code[10];
        SubOrder: Code[10];
        BatchLotNo: Code[50];
        PkgLotNo: Code[50];
        BatchEqCode: Code[20];
        StartDateTime: DateTime;
        EndDateTime: DateTime;
        MultipleBatchEquipment: Boolean;
    begin
        BatchDetail.Reset;
        OrderCount := BatchDetail.Count;
        if OrderCount = 0 then
            if ExistingOrders then begin
                if not Confirm(Text003, false) then
                    Error('');
            end else
                Error(Text001);

        FinishedItem.Reset;
        FinishedItem.SetRange(Type, FinishedItem.Type::Summary);
        FinishedItem.SetRange(Include, true);
        FinishedItem.SetFilter("Remaining Quantity to Pack", '<>0');
        if FinishedItem.FindFirst then
            Error(Text002);

        MfgSetup.Get;
        ProcessSetup.Get;

        if OrderCount <> 0 then begin
            CreateOrder.SetVariables(LocationCode, ProcessSetup."Default Batch Status", 0);
            CreateOrder.SetMinimumOrderStatus(BatchOrder.Status::"Firm Planned");
            CreateOrder.SetDefaultDimensions(DATABASE::"Process Setup", 'BATCH');
            CreateOrder.ProhibitDirectionChange;
            CreateOrder.ProhibitLocationChange;
            if CreateOrder.RunModal <> ACTION::Yes then
                exit;
            CreateOrder.ReturnVariables(LocationCode, Direction, Status, DimensionSetID); // P8001133
        end;

        DeleteBatchOrders(BatchItem."No.", BatchVariant, LocationCode, ProductionDate); // P8001030

        DailyDetail.Reset;
        DailyDetail.SetRange("Pending Deletion", true);
        DailyDetail.DeleteAll;
        DailyDetail.Reset;

        EquipmentParameter.SetRange("Production Date");
        EquipmentParameter.SetRange("Equipment Code");
        EquipmentParameter.SetRange("Highlight Value");
        EquipmentParameter.SetRange("Prod. Order Status");
        EquipmentParameter.SetRange("Prod. Order No.");
        EquipmentParameter.MarkedOnly(true);
        EquipmentParameter.DeleteAll;

        FinishedItem.Reset;
        if FinishedItem.FindSet then
            repeat
                if WorksheetLine.Get(BPWorksheetName.Name, FinishedItem."Item No.", FinishedItem."Variant Code",
                  WorksheetLine.Type::Summary, 0)
                then begin
                    ;
                    WorksheetLine.UpdateQuantity;
                    WorksheetLine.Modify;
                end;
            until FinishedItem.Next = 0;

        if OrderCount = 0 then begin
            UpdateDailySummary;
            exit(true);
        end;

        PackageDetail[1].Reset;

        if BPWorksheetName."Create Multi-line Orders" then begin
            P800ProdOrderMgmt.CreateOrderHeader(
              BatchOrder,
              Status,
              ProcessSetup."Batch Order Nos.",
              Filler,
              BatchOrder."Source Type"::Item,
              BatchItem."No.",
              BatchVariant, // P8001030
              TotalBatchQty,
              ProductionDate,
              LocationCode,
              DimensionSetID, // P8001133
              '',
              BatchOrder."Order Type"::Batch,
              0,
              '',
              '');

            BatchDetail.FindSet;
            repeat
                P800ProdOrderMgmt.CreateOrderLine(
                  BatchOrder,
                  BatchOrderLine,
                  BatchItem."No.",
                  BatchVariant, // P8001030
                  BatchDetail."Batch Size",
                  BatchItem."Base Unit of Measure",
                  '',
                  BatchDetail."Equipment Code");
                ProdOrderCalculate.Calculate(BatchOrderLine, Direction, true, true, true, true); // P8001301
                BatchOrderLine.Find;
                BatchLotNo := '';
                P800ProdOrderMgmt.CreateOutputItemTracking(BatchOrderLine, BatchLotNo);
                P800ProdOrderMgmt.CreateAutoPlanOrder(BatchOrderLine.Status, BatchOrderLine."Prod. Order No.",
                  BatchOrderLine."Line No.", BatchOrderLine."Starting Date", BatchOrderLine."Location Code", Direction);
                UpdateDailyDetail(BatchOrderLine);
                UpdateEquipmentParameter(BatchOrderLine);
                if BatchEqCode = '' then
                    BatchEqCode := BatchDetail."Equipment Code"
                else
                    if BatchEqCode <> BatchDetail."Equipment Code" then
                        MultipleBatchEquipment := true;
            until BatchDetail.Next = 0;

            BatchOrder.Find;
            BatchSummary.Reset;
            BatchSummary.SetRange(Include, true);
            if BatchSummary.FindSet then begin
                StartDateTime := CreateDateTime(BatchOrder."Starting Date", BatchOrder."Starting Time");
                EndDateTime := CreateDateTime(BatchOrder."Ending Date", BatchOrder."Ending Time");
                repeat
                    P800ProdOrderMgmt.AdjustProdOrderLineDates(BatchOrder, BatchSummary."Equipment Code",
                      StartDateTime, EndDateTime, Direction)
                until BatchSummary.Next = 0;
            end;
            if not MultipleBatchEquipment then
                BatchOrder.Validate("Equipment Code", BatchEqCode);     //P8007285
            BatchOrder.Modify;

            if BatchOrder.Status = BatchOrder.Status::Released then
                ProdOrderStatusMgt.FlushProdOrder(BatchOrder, BatchOrder.Status, WorkDate);

            SubOrder := '000';
            PackageDetail[1].SetRange("Batch No.", 0);
            PackageDetail[1].SetFilter(Quantity, '<>0');
            if PackageDetail[1].FindSet then
                repeat
                    P800ProdOrderMgmt.CreateOrderHeader(
                      PkgOrder,
                      Status,
                      ProcessSetup."Packaging Order Nos.",
                      SubOrder,
                      PkgOrder."Source Type"::Item,
                      PackageDetail[1]."Item No.",
                      PackageDetail[1]."Variant Code",
                      PackageDetail[1].Quantity,
                      ProductionDate,
                      LocationCode,
                      DimensionSetID, // P8001133
                      PackageDetail[1]."Equipment Code",
                      PkgOrder."Order Type"::Package,
                      0,
                      BatchOrder."No.",
                      '');

                    P800ProdOrderMgmt.CreateOrderLine(
                      PkgOrder,
                      PkgOrderLine,
                      PackageDetail[1]."Item No.",
                      PackageDetail[1]."Variant Code",
                      PackageDetail[1].Quantity,
                      PackageDetail[1]."Unit of Measure",
                      '',
                      PackageDetail[1]."Equipment Code");
                    ProdOrderCalculate.Calculate(PkgOrderLine, Direction, true, true, true, true); // P8001301
                    PkgOrderLine.Find;
                    PkgLotNo := '';
                    P800ProdOrderMgmt.CreateOutputItemTracking(PkgOrderLine, PkgLotNo);
                    UpdateDailyDetail(PkgOrderLine);
                    UpdateWorksheetLine(PkgOrderLine);
                    UpdateEquipmentParameter(PkgOrderLine);

                    if PkgOrder.Status = PkgOrder.Status::Released then
                        ProdOrderStatusMgt.FlushProdOrder(PkgOrder, PkgOrder.Status, WorkDate);
                until PackageDetail[1].Next = 0;
        end else begin
            BatchDetail.FindSet(true);
            repeat
                P800ProdOrderMgmt.CreateOrderHeader(
                  BatchOrder,
                  Status,
                  ProcessSetup."Batch Order Nos.",
                  Filler,
                  BatchOrder."Source Type"::Item,
                  BatchItem."No.",
                  BatchVariant, // P8001030
                  BatchDetail."Batch Size",
                  ProductionDate,
                  LocationCode,
                  DimensionSetID, // P8001133
                  BatchDetail."Equipment Code",
                  BatchOrder."Order Type"::Batch,
                  0,
                  '',
                  '');

                P800ProdOrderMgmt.CreateOrderLine(
                  BatchOrder,
                  BatchOrderLine,
                  BatchItem."No.",
                  BatchVariant, // P8001030
                  BatchDetail."Batch Size",
                  BatchItem."Base Unit of Measure",
                  '',
                  BatchDetail."Equipment Code");
                ProdOrderCalculate.Calculate(BatchOrderLine, Direction, true, true, true, true); // P8001301
                BatchOrderLine.Find;
                BatchLotNo := '';
                P800ProdOrderMgmt.CreateOutputItemTracking(BatchOrderLine, BatchLotNo);
                P800ProdOrderMgmt.CreateAutoPlanOrder(BatchOrderLine.Status, BatchOrderLine."Prod. Order No.",
                  BatchOrderLine."Line No.", BatchOrderLine."Starting Date", BatchOrderLine."Location Code", Direction);
                UpdateDailyDetail(BatchOrderLine);
                UpdateEquipmentParameter(BatchOrderLine);

                if BatchOrder.Status = BatchOrder.Status::Released then
                    ProdOrderStatusMgt.FlushProdOrder(BatchOrder, BatchOrder.Status, WorkDate);

                SubOrder := '000';
                PackageDetail[1].SetRange("Batch No.", BatchDetail."Batch No.");
                PackageDetail[1].SetFilter(Quantity, '<>0');
                if PackageDetail[1].FindSet then
                    repeat
                        P800ProdOrderMgmt.CreateOrderHeader(
                          PkgOrder,
                          Status,
                          ProcessSetup."Packaging Order Nos.",
                          SubOrder,
                          PkgOrder."Source Type"::Item,
                          PackageDetail[1]."Item No.",
                          PackageDetail[1]."Variant Code",
                          PackageDetail[1].Quantity,
                          ProductionDate,
                          LocationCode,
                          DimensionSetID, // P8001133
                          PackageDetail[1]."Equipment Code",
                          PkgOrder."Order Type"::Package,
                          0,
                          BatchOrder."No.",
                          '');

                        P800ProdOrderMgmt.CreateOrderLine(
                          PkgOrder,
                          PkgOrderLine,
                          PackageDetail[1]."Item No.",
                          PackageDetail[1]."Variant Code",
                          PackageDetail[1].Quantity,
                          PackageDetail[1]."Unit of Measure",
                          '',
                          PackageDetail[1]."Equipment Code");
                        ProdOrderCalculate.Calculate(PkgOrderLine, Direction, true, true, true, true); // P8001301
                        PkgOrderLine.Find;
                        PkgLotNo := '';
                        P800ProdOrderMgmt.CreateOutputItemTracking(PkgOrderLine, PkgLotNo);
                        P800ProdOrderMgmt.CreateComponentItemTracking(PkgOrderLine, BatchItem."No.", BatchVariant, BatchLotNo); // P8001030
                        UpdateDailyDetail(PkgOrderLine);
                        UpdateWorksheetLine(PkgOrderLine);
                        UpdateEquipmentParameter(PkgOrderLine);
                        if PkgOrder.Status = PkgOrder.Status::Released then
                            ProdOrderStatusMgt.FlushProdOrder(PkgOrder, PkgOrder.Status, WorkDate);
                    until PackageDetail[1].Next = 0;
            until BatchDetail.Next = 0;
        end;

        UpdateDailySummary;

        exit(true);
    end;

    procedure DeleteBatchOrders(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; ProdDate: Date)
    var
        ProdOrder: Record "Production Order";
        ProdOrder2: Record "Production Order";
    begin
        // P8001030 - add parameter for VariantCode
        ProdOrder.SetCurrentKey("Batch Order", "Source Type", "Source No.");
        ProdOrder.SetRange("Batch Order", true);
        ProdOrder.SetRange(Status, ProdOrder.Status::"Firm Planned", ProdOrder.Status::Released);
        ProdOrder.SetRange("Source Type", ProdOrder."Source Type"::Item);
        ProdOrder.SetRange("Source No.", ItemNo);
        ProdOrder.SetRange("Starting Date", ProdDate);
        ProdOrder.SetRange("Variant Code", VariantCode); // P8001030
        ProdOrder.SetRange("Location Code", LocationCode);
        ProdOrder2.SetCurrentKey(Status, "Batch Prod. Order No.", "No.");
        if ProdOrder.FindSet then
            repeat
                ProdOrder2 := ProdOrder;
                ProdOrder2.SetHideValidationDialog(true);
                ProdOrder2.Delete(true);
            until ProdOrder.Next = 0;
    end;

    procedure UpdateWorksheetLine(ProdOrderLine: Record "Prod. Order Line")
    var
        WorksheetLine: Record "Batch Planning Worksheet Line";
        WorkSheetLineDetail: Record "Batch Planning Worksheet Line";
        ProdOrderXref: Record "Production Order XRef";
        Quantity: Decimal;
    begin
        if not WorksheetLine.Get(BPWorksheetName.Name, ProdOrderLine."Item No.", ProdOrderLine."Variant Code",
          WorksheetLine.Type::Summary, 0)
        then
            exit;

        WorkSheetLineDetail.SetCurrentKey("Worksheet Name", "Item No.", "Variant Code", Type, "Date Required");
        WorkSheetLineDetail.SetRange("Worksheet Name", WorksheetLine."Worksheet Name");
        WorkSheetLineDetail.SetRange("Item No.", WorksheetLine."Item No.");
        WorkSheetLineDetail.SetRange("Variant Code", WorksheetLine."Variant Code");
        WorkSheetLineDetail.SetRange(Type, WorkSheetLineDetail.Type::Detail);

        if WorkSheetLineDetail.FindSet(true, false) then
            repeat
                if ProdOrderLine."Quantity (Base)" < WorkSheetLineDetail."Quantity Remaining" then
                    Quantity := ProdOrderLine."Quantity (Base)"
                else
                    Quantity := WorkSheetLineDetail."Quantity Remaining";

                WorkSheetLineDetail."Quantity Planned" += Quantity;
                WorkSheetLineDetail.CalcRemainingQty;
                WorkSheetLineDetail.Modify;

                WorksheetLine."Quantity Planned" += Quantity;

                ProdOrderXref."Source Table ID" := WorkSheetLineDetail."Order Source";
                ProdOrderXref."Source Type" := WorkSheetLineDetail."Order Source Subtype";
                ProdOrderXref."Source No." := WorkSheetLineDetail."Order No.";
                ProdOrderXref."Source Line No." := WorkSheetLineDetail."Order Line No.";
                ProdOrderXref."Prod. Order Status" := ProdOrderLine.Status;
                ProdOrderXref."Prod. Order No." := ProdOrderLine."Prod. Order No.";
                ProdOrderXref."Prod. Order Line No." := ProdOrderLine."Line No.";
                ProdOrderXref."Quantity (Base)" := Quantity;
                ProdOrderXref.Insert(true);

                ProdOrderLine."Quantity (Base)" -= Quantity;
            until (WorkSheetLineDetail.Next = 0) or (ProdOrderLine."Quantity (Base)" = 0);
        WorksheetLine.CalcRemainingQty;
        WorksheetLine.CalcIntermediateQty;
        WorksheetLine.Modify;
    end;

    procedure LoadProductionSequence(LocationCode: Code[10]; ProdDate: Date; var ProdSequence: Record "Production Sequencing" temporary)
    var
        MfgSetup: Record "Manufacturing Setup";
        Location: Record Location;
        Resource: Record Resource;
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        TempProdOrderLine: Record "Prod. Order Line" temporary;
        ProdEvent: Record "Daily Production Event";
        ProdSequence2: Record "Production Sequencing";
        EntryNo: Integer;
        SequenceNo: Integer;
    begin
        MfgSetup.Get;
        if Location.Get(LocationCode) then
            if Location."Normal Starting Time" = 0T then
                Location."Normal Starting Time" := MfgSetup."Normal Starting Time";

        ProdOrder.SetRange(Status, ProdOrder.Status::"Firm Planned", ProdOrder.Status::Released);
        ProdOrder.SetRange("Location Code", LocationCode);
        ProdOrder.SetRange("Starting Date", ProdDate);
        if ProdOrder.FindSet then
            repeat
                ProdOrderLine.SetRange(Status, ProdOrder.Status);
                ProdOrderLine.SetRange("Prod. Order No.", ProdOrder."No.");
                if ProdOrderLine.FindSet then
                    repeat
                        TempProdOrderLine := ProdOrderLine;
                        TempProdOrderLine.Insert;
                    until ProdOrderLine.Next = 0;
            until ProdOrder.Next = 0;

        TempProdOrderLine.SetCurrentKey("Equipment Code", "Starting Date");

        ProdEvent.SetRange("Production Date", ProdDate);

        Resource.SetRange(Type, Resource.Type::Machine);
        Resource.SetRange("Location Code", LocationCode);
        if Resource.FindSet then
            repeat
                EntryNo += 1;
                ProdSequence2."Entry No." := EntryNo;
                ProdSequence2."Equipment Entry No." := EntryNo;
                ProdSequence2."Equipment Code" := Resource."No.";
                ProdSequence2.Type := ProdSequence2.Type::" ";
                ProdSequence2."Resource Group" := Resource."Resource Group No.";
                ProdSequence2.Level := 0;
                ProdSequence2."Starting Date-Time" := 0DT;
                ProdSequence2."Ending Date-Time" := 0DT;
                ProdSequence2."Starting Time" := 0T;
                ProdSequence2."Ending Time" := 0T;
                ProdSequence2."Total Time (Hours)" := 0;
                ProdSequence2."No. Of Entries" := 0;
                // P8000898
                ProdSequence.Quantity := 0;
                ProdSequence."Unit of Measure Code" := '';
                // P8000898
                ProdSequence2."No. of Batches" := 0;
                ProdSequence2.SetDescription;

                TempProdOrderLine.SetRange("Equipment Code", Resource."No.");
                if TempProdOrderLine.FindSet then
                    repeat
                        ProdOrder.Get(TempProdOrderLine.Status, TempProdOrderLine."Prod. Order No.");
                        EntryNo += 1;
                        ProdSequence."Entry No." := EntryNo;
                        ProdSequence."Equipment Entry No." := ProdSequence2."Entry No.";
                        ProdSequence."Equipment Code" := Resource."No.";
                        ;
                        ProdSequence.Level := 1;
                        ProdSequence.Type := ProdSequence.Type::Order;
                        ProdSequence."Event Code" := '';
                        ProdSequence."Order Status" := TempProdOrderLine.Status;
                        ProdSequence."Order No." := TempProdOrderLine."Prod. Order No.";
                        ProdSequence."Line No." := 0;
                        ProdSequence."Resource Group" := Resource."Resource Group No.";
                        ProdSequence."Item No." := TempProdOrderLine."Item No.";
                        ProdSequence."Item Description" := TempProdOrderLine.Description;
                        ProdSequence.Validate("Starting Date-Time", TempProdOrderLine."Starting Date-Time");
                        ProdSequence."First Line Duration" := TempProdOrderLine."Ending Date-Time" - TempProdOrderLine."Starting Date-Time";
                        TempProdOrderLine.SetRange(Status, TempProdOrderLine.Status);
                        TempProdOrderLine.SetRange("Prod. Order No.", TempProdOrderLine."Prod. Order No.");
                        // P8000898
                        TempProdOrderLine.CalcSums(Quantity);
                        ProdSequence.Quantity := TempProdOrderLine.Quantity;
                        ProdSequence."Unit of Measure Code" := TempProdOrderLine."Unit of Measure Code";
                        // P8000898
                        if ProdOrder."Batch Order" then
                            ProdSequence."No. of Batches" := TempProdOrderLine.Count;
                        TempProdOrderLine.Find('+');
                        TempProdOrderLine.SetRange(Status);
                        TempProdOrderLine.SetRange("Prod. Order No.");
                        ProdSequence.Validate("Ending Date-Time", TempProdOrderLine."Ending Date-Time");
                        ProdSequence2."Total Time (Hours)" += ProdSequence."Duration (Hours)";
                        ProdSequence."No. Of Entries" := 0;
                        ProdSequence."Total Time (Hours)" := 0;
                        ProdSequence.SetDescription;
                        ProdSequence.Insert;

                        ProdSequence2."No. Of Entries" += 1;
                    until TempProdOrderLine.Next = 0;

                ProdEvent.SetRange("Equipment Code", Resource."No.");
                if ProdEvent.FindSet then
                    repeat
                        if ProdEvent."Start Time" = 0T then begin
                            ProdEvent."Start Time" := Location."Normal Starting Time";
                            ProdEvent.Modify;
                        end;
                        EntryNo += 1;
                        ProdSequence."Entry No." := EntryNo;
                        ProdSequence."Equipment Entry No." := ProdSequence2."Entry No.";
                        ProdSequence."Equipment Code" := Resource."No.";
                        ProdSequence.Level := 1;
                        ProdSequence.Type := ProdSequence.Type::"Event";
                        ProdSequence."Event Code" := ProdEvent."Event Code";
                        ProdSequence."Order Status" := 0;
                        ProdSequence."Order No." := '';
                        ProdSequence."Line No." := ProdEvent."Line No.";
                        ProdSequence."Resource Group" := Resource."Resource Group No.";
                        ;
                        ProdSequence."Item No." := '';
                        ProdSequence."Item Description" := '';
                        ProdSequence.Validate("Starting Date-Time", CreateDateTime(ProdDate, ProdEvent."Start Time"));
                        ProdSequence.Validate("Ending Date-Time",
                          CreateDateTime(ProdDate, ProdEvent."Start Time" + 3600000 * ProdEvent."Duration (Hours)"));
                        ProdSequence2."Total Time (Hours)" += ProdSequence."Duration (Hours)";
                        ProdSequence."No. Of Entries" := 0;
                        ProdSequence."Total Time (Hours)" := 0;
                        // P8000898
                        ProdSequence.Quantity := 0;
                        ProdSequence."Unit of Measure Code" := '';
                        // P8000898
                        ProdSequence."No. of Batches" := 0;
                        ProdSequence.SetDescription;
                        ProdSequence.Insert;

                        ProdSequence2."No. Of Entries" += 1;
                    until ProdEvent.Next = 0;

                SequenceNo := 0;
                ProdSequence.SetCurrentKey("Equipment Code", Level, "Starting Date-Time", "Ending Date-Time");
                ProdSequence.SetRange("Equipment Code", ProdSequence2."Equipment Code");
                ProdSequence.SetRange(Level, 1);
                if ProdSequence.FindSet(true) then
                    repeat
                        SequenceNo += 1;
                        ProdSequence."Sequence No." := SequenceNo;
                        ProdSequence."No. Of Entries" := ProdSequence2."No. Of Entries";
                        ProdSequence.Modify;
                    until ProdSequence.Next = 0;

                ProdSequence := ProdSequence2;
                ProdSequence.Insert;
            until Resource.Next = 0;

        ProdSequence.Reset;
    end;
}

