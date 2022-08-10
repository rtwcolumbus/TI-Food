codeunit 37002462 "Process 800 BOM Functions"
{
    // PR3.61.03
    //   When calculating ABC cost for cost rollup; set overhead rate to zero if no ABC costs
    // 
    // PR3.70.03
    //   Add functions
    //     GetStdCostFactors - get adjustment factors for calculating co-product standard cost
    //     UpdateBOMCost - relocated from ItemCostManagement; added code to maintain Family Line
    //     CreateItemFromBOM - creates item record from data in BOM plus user input
    // 
    // PR4.00
    // P8000219A, Myers Nissi, Jack Reynolds, 24 JUN 05
    //   CalcABCOverhead - use costing equipment
    //   GetPreferredEquipment - determin preferred equipment for BOM
    //   GetCostingEquipment - determin costing equipment for BOM
    //   CalcABCRtngCostPerUnit - calculate unit costs for routing line based on linked ABC costs
    // 
    // P8000197A, Myers Nissi, Jack Reynolds, 22 SEP 05
    //   Create function to update production times for BOM equipment
    // 
    // P8000235A, Myers Nissi, Jack Reynolds, 26 OCT 05
    //   BOMVersionQtyFactor - made GLOBAL
    // 
    // PR4.00.04
    // P8000375A, VerticalSoft, Jack Reynolds, 08 SEP 06
    //   InsertValueEntryABCDetail - creates ABC detail record for specified value entry
    // 
    // P8000391A, VerticalSoft, Jack Reynolds, 27 SEP 06
    //   ResourceUpdateABCCost - modified to also update the "Cost per" on the ABC line
    // 
    // PR4.00.05
    // P8000459A, VerticalSoft, Jack Reynolds, 20 MAR 07
    //   Fix error with ABC detail and multiple entries for the same resource
    // 
    // PRW15.00.01
    // P8000551A, VerticalSoft, Jack Reynolds, 04 DEC 07
    //   Round unit cost on BOM lines to 5 decimal places
    //   Recursively update unit cost on BOM lines for phantoms
    // 
    // P8000557A, VerticalSoft, Jack Reynolds, 08 JAN 08
    //   Fix problem calculating routing cost from activity based cost for different equipment
    // 
    // P8000562A, VerticalSoft, Jack Reynolds, 23 JAN 08
    //   Fix divide by zero error in InsertValueEntryABCDetail
    // 
    // PRW16.00.01
    // P8000679, VerticalSoft, Don Bresee, 25 FEB 09
    //   Fix code to handle BOM with no active version
    // 
    // PRW16.00.02
    // P8000741, VerticalSoft, Jack Reynolds, 19 NOV 09
    //   Remove COMMIT in BOMVersionUpdateWhereUsed
    // 
    // PRW16.00.05
    // P8000925, Columbus IT, Jack Reynolds, 29 MAR 11
    //   Use Prod Order Line instead of Header to get equipment code
    // 
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // P8001092, Columbus IT, Don Bresee, 17 AUG 12
    //   Change costing logic to use "Co-Product Cost Share" field
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW17.10.02
    // P8001266, Columbus IT, Jack Reynolds, 21 JAN 14
    //   Fix standard cost calculation for co-products
    // 
    // PRW18.00.03
    // P8006471. To-Increase, Jack Reynolds, 18 FEB 2016
    //   ABC Detail for packaging configurator
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 08 MAR 16
    //   Expand BOM Version code to Code20
    // 
    // PRW19.00.01
    // P8007573, To Increase, Jack Reynolds, 06 SEP 16
    //   another fix to standard cost calculation for co-products
    // 
    // P8007742, To-Increase, Dayakar Battini, 11 OCT 16
    //   ? character removed from "Include In Cost Rollup?" field
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00


    trigger OnRun()
    begin
    end;

    var
        Text37002000: Label 'Total %1 must not be zero.';
        Text37002001: Label 'BOM nesting level exceeds 50.';
        ProcessFns: Codeunit "Process 800 Functions";

    procedure ResourceUpdateABCCost(var Rec: Record Resource)
    var
        ProdBOMABC: Record "Prod. BOM Activity Cost";
        factor: Decimal;
    begin
        // UpdateABCResourceCost
        with Rec do begin
            ProdBOMABC.SetCurrentKey("Resource No.");
            ProdBOMABC.SetRange("Resource No.", "No.");
            ProdBOMABC.SetRange("Include In Cost Rollup", true); // P8000391A  // P8007742
            if ProdBOMABC.Find('-') then
                repeat
                    if (ProdBOMABC."Cost per" <> 0) and (ProdBOMABC."Include In Cost Rollup") then // P8000391A  // P8007742
                        factor := ProdBOMABC."Extended Cost" / ProdBOMABC."Cost per";                 // P8000391A
                    ProdBOMABC.Validate("Unit Cost", "Unit Cost");
                    ProdBOMABC.Validate("Direct Unit Cost", "Direct Unit Cost");
                    if factor <> 0 then                                             // P8000391A
                        ProdBOMABC."Cost per" := ProdBOMABC."Extended Cost" / factor; // P8000391A
                    ProdBOMABC.Modify;
                until ProdBOMABC.Next = 0;
        end;
    end;

    procedure BOMVersionInitRecord(var Rec: Record "Production BOM Version")
    var
        ProdBOMHeader: Record "Production BOM Header";
        InvSetup: Record "Inventory Setup";
        ProcessSetup: Record "Process Setup";
        MeasSys: Record "Measuring System";
    begin
        // BOMVersionInitRecord
        with Rec do begin
            ProdBOMHeader.Get(Rec."Production BOM No.");
            case ProdBOMHeader."Mfg. BOM Type" of
                Type::Formula, Type::Process:
                    begin
                        ProcessSetup.Get;
                        "Primary UOM" := ProcessSetup."Default Primary UOM";
                        InvSetup.Get;
                        MeasSys.SetRange("Measuring System", InvSetup."Measuring System");
                        MeasSys.SetRange(Type, MeasSys.Type::Weight);
                        if MeasSys.Find('-') then
                            "Weight UOM" := MeasSys.UOM;
                        MeasSys.SetRange(Type, MeasSys.Type::Volume);
                        if MeasSys.Find('-') then
                            "Volume UOM" := MeasSys.UOM;
                    end;
            end;
        end;
    end;

    procedure BOMVersionUpdateLineQty(var Rec: Record "Production BOM Version")
    var
        BOMLine: Record "Production BOM Line";
        factor: Decimal;
    begin
        // BOMVersionUpdateLineQty
        with Rec do begin
            if not (Type in [Type::Formula, Type::Process]) then
                exit;

            factor := BOMVersionQtyFactor(Rec); // P8000197A
            if factor = 0 then
                Error(Text37002000, Format("Primary UOM"));

            BOMLine.SetRange("Production BOM No.", "Production BOM No.");
            BOMLine.SetRange("Version Code", "Version Code");
            if BOMLine.Find('-') then
                repeat
                    BOMLine."Quantity per" := BOMLine."Batch Quantity" / factor;
                    BOMLine.Validate(Quantity, BOMLine."Quantity per");
                    BOMLine.Modify;
                until BOMLine.Next = 0;
        end;
    end;

    procedure BOMVersionUpdateABCAmount(var Rec: Record "Production BOM Version")
    var
        ABCLine: Record "Prod. BOM Activity Cost";
        factor: Decimal;
    begin
        // BOMVersionUpdateABCAmount
        with Rec do begin
            factor := BOMVersionQtyFactor(Rec); // P8000197A
            if factor = 0 then
                Error(Text37002000, Format("Primary UOM"));

            ABCLine.SetRange("Production Bom No.", "Production BOM No.");
            ABCLine.SetRange("Version Code", "Version Code");
            ABCLine.SetRange("Include In Cost Rollup", true);  // P8007742
            if ABCLine.Find('-') then
                repeat
                    ABCLine."Cost per" := ABCLine."Extended Cost" / factor;
                    ABCLine.Modify;
                until ABCLine.Next = 0;
        end;
    end;

    procedure BOMVersionUpdateEquipmentUOM(var Rec: Record "Production BOM Version"; wgt: Boolean; vol: Boolean; UOMCode: Code[10])
    var
        BOMEquipment: Record "Prod. BOM Equipment";
    begin
        // BOMVersionUpdateEquipmentUOM
        with Rec do begin
            BOMEquipment.SetRange("Production Bom No.", "Production BOM No.");
            BOMEquipment.SetRange("Version Code", "Version Code");
            if BOMEquipment.Find('-') then
                repeat
                    if BOMEquipment.ConvertUnits(wgt, vol, UOMCode) then
                        BOMEquipment.Modify;
                until BOMEquipment.Next = 0;
        end;
    end;

    procedure BOMVersionUpdateEquipmentTime(Rec: Record "Production BOM Version")
    var
        BOMEquipment: Record "Prod. BOM Equipment";
        factor: Decimal;
    begin
        // P8000197A
        with Rec do begin
            factor := BOMVersionQtyFactor(Rec);
            if factor = 0 then
                Error(Text37002000, Format("Primary UOM"));

            BOMEquipment.SetRange("Production Bom No.", "Production BOM No.");
            BOMEquipment.SetRange("Version Code", "Version Code");
            if BOMEquipment.Find('-') then
                repeat
                    BOMEquipment.CalcTimeFromRouting(factor);
                    BOMEquipment.Modify;
                until BOMEquipment.Next = 0;
        end;
    end;

    procedure BOMVersionUpdateWhereUsed(var Rec: Record "Production BOM Version")
    var
        BOMsToUpdate: array[2] of Record "Production BOM Line" temporary;
        BOMVars: Record "BOM Variables";
        BOMVars2: Record "BOM Variables";
        BOMVersion: Record "Production BOM Version";
        ProdBOMLine: Record "Production BOM Line";
        VersionMgt: Codeunit VersionManagement;
        CurrentLevel: Integer;
        factor: Decimal;
    begin
        // BOMVersionUpdateWhereUsed
        with Rec do begin
            CurrentLevel := 0;
            BOMsToUpdate[1]."Production BOM No." := "Production BOM No.";
            BOMsToUpdate[1]."Version Code" := "Version Code";
            BOMsToUpdate[1]."Line No." := CurrentLevel;
            BOMsToUpdate[1].Insert;

            BOMsToUpdate[1].SetRange("Line No.", CurrentLevel);
            while BOMsToUpdate[1].Find('-') do begin
                CurrentLevel += 1;
                if CurrentLevel > 50 then
                    Error(Text37002001);
                repeat
                    if VersionMgt.GetBOMVersion(BOMsToUpdate[1]."Production BOM No.", Today, true) =
                       BOMsToUpdate[1]."Version Code"
                    then begin
                        BOMVersion.Get(BOMsToUpdate[1]."Production BOM No.", BOMsToUpdate[1]."Version Code");
                        BOMVars.Type := BOMVersion.Type;
                        BOMVars."No." := BOMVersion."Production BOM No.";
                        BOMVars."Version Code" := BOMVersion."Version Code";
                        BOMVars."Include In Rollup" := true;
                        BOMVars.InitRecord;

                        ProdBOMLine.SetCurrentKey(Type, "No.");
                        ProdBOMLine.SetRange(Type, ProdBOMLine.Type::"Production BOM");
                        ProdBOMLine.SetRange("No.", BOMVersion."Production BOM No.");
                        if ProdBOMLine.Find('-') then
                            repeat
                                // Add this BOM to the list that need to be updated
                                if not BOMsToUpdate[2].Get(ProdBOMLine."Production BOM No.",
                                  ProdBOMLine."Version Code", CurrentLevel)
                                then begin
                                    BOMsToUpdate[2]."Production BOM No." := ProdBOMLine."Production BOM No.";
                                    BOMsToUpdate[2]."Version Code" := ProdBOMLine."Version Code";
                                    BOMsToUpdate[2]."Line No." := CurrentLevel;
                                    BOMsToUpdate[2].Insert;
                                end;

                                if BOMVars.Type = BOMVars.Type::BOM then
                                    ProdBOMLine."Unit Cost" := BOMVars."Total Cost"
                                else
                                    if ProdBOMLine."Unit of Measure Code" = BOMVars."Weight UOM" then
                                        ProdBOMLine."Unit Cost" := BOMVars."Total Cost (per Weight UOM)"
                                    else
                                        if "Unit of Measure Code" = BOMVars."Volume UOM" then
                                            ProdBOMLine."Unit Cost" := BOMVars."Total Cost (per volume UOM)"
                                        else
                                            ProdBOMLine."Unit Cost" := 0;
                                ProdBOMLine.Validate("Unit Cost", Round(ProdBOMLine."Unit Cost", 0.00001)); // P8000551A
                                ProdBOMLine.ReCalc(true, true, true);
                                ProdBOMLine.Modify;
                                //COMMIT; // P8000741

                                BOMVersion.Get(ProdBOMLine."Production BOM No.", ProdBOMLine."Version Code");
                                if BOMVersion.Type in [BOMVersion.Type::Formula, BOMVersion.Type::Process] then begin // PR1.20
                                    Clear(BOMVars2);
                                    BOMVars2.Type := BOMVersion.Type;
                                    BOMVars2."No." := BOMVersion."Production BOM No.";
                                    BOMVars2."Version Code" := BOMVersion."Version Code";
                                    BOMVars2.InitRecord;
                                    BOMVars2.SetPercents(ProdBOMLine."Line No.");
                                    case BOMVars2."Primary UOM" of
                                        BOMVars2."Primary UOM"::Weight:
                                            factor := BOMVars2."Output Weight (Base)";
                                        BOMVars2."Primary UOM"::Volume:
                                            factor := BOMVars2."Output Volume (Base)";
                                    end;
                                    if factor <> 0 then
                                        factor := 100 / factor;
                                    case BOMVars2."Primary UOM" of
                                        BOMVars2."Primary UOM"::Weight:
                                            ProdBOMLine."% of Total" := ProdBOMLine."Output Weight (Base)" * factor;
                                        BOMVars2."Primary UOM"::Volume:
                                            ProdBOMLine."% of Total" := ProdBOMLine."Output Volume (Base)" * factor;
                                    end;
                                end;

                                ProdBOMLine.Modify;
                            until ProdBOMLine.Next = 0;
                    end;
                until BOMsToUpdate[1].Next = 0;
                BOMsToUpdate[1].SetRange("Line No.", CurrentLevel);
            end;
        end;
    end;

    local procedure BOMVersionQtyFactor(ProdBOMVersion: Record "Production BOM Version") factor: Decimal
    var
        P800UOMFns: Codeunit "Process 800 UOM Functions";
    begin
        // ***
        with ProdBOMVersion do
            case Type of
                Type::Formula, Type::Process:
                    begin
                        CalcFields("Output Weight (Base)", "Output Volume (Base)");
                        case "Primary UOM" of
                            "Primary UOM"::Weight:
                                begin
                                    factor := "Output Weight (Base)";
                                    factor := factor / P800UOMFns.UOMtoMetricBase("Weight UOM");
                                end;
                            "Primary UOM"::Volume:
                                begin
                                    factor := "Output Volume (Base)";
                                    factor := factor / P800UOMFns.UOMtoMetricBase("Volume UOM");
                                end;
                        end;
                    end;

                Type::BOM:
                    factor := 1;
            end;
    end;

    local procedure BOMVersionUOM(ProdBOMVersion: Record "Production BOM Version"): Code[10]
    begin
        // P8006471
        with ProdBOMVersion do
            case Type of
                Type::Formula, Type::Process:
                    begin
                        case "Primary UOM" of
                            "Primary UOM"::Weight:
                                exit(ProdBOMVersion."Weight UOM");
                            "Primary UOM"::Volume:
                                exit(ProdBOMVersion."Volume UOM");
                        end;
                    end;
                Type::BOM:
                    exit(ProdBOMVersion."Unit of Measure Code");
            end;
    end;

    procedure CalcABCOverhead(MfgItem: Record Item; var SKU: Record "Stockkeeping Unit"; ProdBOMNo: Code[20]; CalculationDate: Date)
    var
        ProdBOMHeader: Record "Production BOM Header";
        ABCLine: Record "Prod. BOM Activity Cost";
        VersionMgt: Codeunit VersionManagement;
        UomMgmt: Codeunit "Unit of Measure Management";
        BOMVersionCode: Code[20];
        QtyBase: Decimal;
    begin
        // CalcABCOverhead
        // P8001030 - add parameter for SKU
        if ProdBOMNo = '' then
            exit;

        ProdBOMHeader.Get(ProdBOMNo);
        BOMVersionCode := VersionMgt.GetBOMVersion(ProdBOMNo, CalculationDate, true);

        if (ProdBOMHeader.Status <> ProdBOMHeader.Status::Certified) and (BOMVersionCode = '') then
            exit;

        QtyBase := UomMgmt.GetQtyPerUnitOfMeasure(MfgItem, VersionMgt.GetBOMUnitOfMeasure(ProdBOMNo, BOMVersionCode));

        ABCLine.SetRange("Production Bom No.", ProdBOMNo);
        ABCLine.SetRange("Version Code", BOMVersionCode);
        ABCLine.SetRange("Equipment No.", GetCostingEquipment(ProdBOMNo, BOMVersionCode, SKU."Location Code")); // P8000219A, P8001030
        ABCLine.SetRange("Include In Cost Rollup", true);   // P8007742
        SKU."Overhead Rate" := 0;   // PR3.61.03, P8001030
        if ABCLine.Find('-') then begin
            SKU."Overhead Rate" := 0; // PR3.61.03, P8001030
            repeat
                SKU."Overhead Rate" += ABCLine."Cost per"; // P8001030
            until ABCLine.Next = 0;
            SKU."Overhead Rate" := SKU."Overhead Rate" / QtyBase; // P8001030
        end;
    end;

    procedure GetStdCostFactors(MfgItem: Record Item; ProdBOMNo: Code[20]; CalculationDate: Date; var ByProductFactor: Decimal; var CoProductFactor: Decimal): Boolean
    var
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMVersion: Record "Production BOM Version";
        FamilyLine: Record "Family Line";
        VersionMgt: Codeunit VersionManagement;
        UOMMgmt: Codeunit "Unit of Measure Management";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        BOMVersionCode: Code[20];
        QtyBase: Decimal;
        CoProductTotal: Decimal;
        CommonUOM: Code[10];
        CurrItemCostFactor: Decimal;
        CurrLineCostFactor: Decimal;
    begin
        // PR3.70.03
        if ProdBOMNo = '' then
            exit(false);

        ProdBOMHeader.Get(ProdBOMNo);

        if (ProdBOMHeader."Mfg. BOM Type" <> ProdBOMHeader."Mfg. BOM Type"::Process) or
          (ProdBOMHeader."Output Type" <> ProdBOMHeader."Output Type"::Family)
        then
            exit(false);

        BOMVersionCode := VersionMgt.GetBOMVersion(ProdBOMNo, CalculationDate, true);

        if (ProdBOMHeader.Status <> ProdBOMHeader.Status::Certified) and (BOMVersionCode = '') then
            exit(false);

        QtyBase := UOMMgmt.GetQtyPerUnitOfMeasure(MfgItem, VersionMgt.GetBOMUnitOfMeasure(ProdBOMNo, BOMVersionCode));

        ProdBOMVersion.Get(ProdBOMNo, BOMVersionCode);
        ProdBOMVersion.CalcFields("Output Weight (Base)", "Output Volume (Base)");
        case ProdBOMVersion."Primary UOM" of
            ProdBOMVersion."Primary UOM"::Weight:
                begin
                    CommonUOM := ProdBOMVersion."Weight UOM";
                    ByProductFactor := ProdBOMVersion."Output Weight (Base)";
                end;
            ProdBOMVersion."Primary UOM"::Volume:
                begin
                    CommonUOM := ProdBOMVersion."Volume UOM";
                    ByProductFactor := ProdBOMVersion."Output Volume (Base)";
                end;
        end;
        ByProductFactor := QtyBase * ByProductFactor / P800UOMFns.UOMtoMetricBase(CommonUOM);

        if ByProductFactor = 0 then
            exit(false);

        FamilyLine.SetRange("Family No.", ProdBOMNo);
        FamilyLine.SetRange("Process Family", true);
        FamilyLine.SetRange("By-Product", false);
        if FamilyLine.Find('-') then
            repeat
                // P8001092
                // CoProductTotal += FamilyLine.Quantity * P800UOMFns.GetConversionFromTo(
                //   FamilyLine."Item No.",FamilyLine."Unit of Measure Code",CommonUOM);
                FamilyLine.Quantity := FamilyLine.Quantity * P800UOMFns.GetConversionFromTo(FamilyLine."Item No.", FamilyLine."Unit of Measure Code", CommonUOM); // P8007573
                CurrLineCostFactor := FamilyLine."Co-Product Cost Share" * FamilyLine.Quantity;                                                                 // P8007573
                CoProductTotal += CurrLineCostFactor; // P8001266
                if (FamilyLine."Item No." = MfgItem."No.") then
                    CurrItemCostFactor := CurrLineCostFactor / FamilyLine.Quantity; // P8001266, P8007573
                                                                                    // P8001092
            until FamilyLine.Next = 0;

        if CoProductTotal <> 0 then
            // CoProductFactor := ByProductFactor / (CoProductTotal * QtyBase) // P8001092
            CoProductFactor := CurrItemCostFactor / (CoProductTotal * QtyBase) // P8001092, P8001266, P8007573
        else
            CoProductFactor := 0;

        exit(true);
    end;

    procedure UpdateBOMCost(Item: Record Item)
    var
        ProdBOMLine: Record "Production BOM Line";
        FamilyLine: Record "Family Line";
        BOMVersion: Record "Production BOM Version";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
    begin
        // PR3.70.03
        with Item do begin
            ProdBOMLine.SetCurrentKey(Type, "No.");
            ProdBOMLine.SetRange(Type, ProdBOMLine.Type::Item);
            ProdBOMLine.SetRange("No.", "No.");
            if ProdBOMLine.Find('-') then
                repeat
                    ProdBOMLine.Validate("Unit Cost", "Unit Cost" /
                      P800UOMFns.GetConversionFromTo("No.", "Base Unit of Measure", ProdBOMLine."Unit of Measure Code"));
                    if CostInAlternateUnits then
                        ProdBOMLine.Validate("Unit Cost (Costing Units)", "Unit Cost");
                    ProdBOMLine.Modify;
                    // P8000551A
                    if BOMVersion.Get(ProdBOMLine."Production BOM No.", ProdBOMLine."Version Code") then // P8000679
                        BOMVersionUpdateWhereUsed(BOMVersion);
                    // P8000551A
                until ProdBOMLine.Next = 0;

            FamilyLine.SetRange("Item No.", "No.");
            FamilyLine.SetRange("Process Family", true);
            if FamilyLine.Find('-') then
                repeat
                    if CostInAlternateUnits then
                        FamilyLine.Validate("Unit Cost", "Unit Cost")
                    else
                        FamilyLine.Validate("Unit Cost", "Unit Cost" /
                          P800UOMFns.GetConversionFromTo("No.", "Base Unit of Measure", FamilyLine."Unit of Measure Code"));
                    FamilyLine.Modify;
                until FamilyLine.Next = 0;
        end;
    end;

    procedure CreateItemFromBOM(BOMHeader: Record "Production BOM Header"; VersionNo: Code[20])
    var
        BOMVersion: Record "Production BOM Version";
        BOMLine: Record "Production BOM Line";
        Item: Record Item;
        InputItem: Record Item;
        Component: Record Item;
        ItemRecRef: RecordRef;
        TempSKU: Record "Stockkeeping Unit" temporary;
        ItemUOM: Record "Item Unit of Measure";
        ConfigTemplateHeader: Record "Config. Template Header";
        CreateItem: Page "Create Item From BOM";
        ItemCard: Page "Item Card";
        CalcStdCost: Codeunit "Calculate Standard Cost";
        ItemCostMgmt: Codeunit ItemCostManagement;
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        TemplateCode: Code[10];
    begin
        // PR3.70.03
        BOMVersion.Get(BOMHeader."No.", VersionNo);
        CreateItem.SetType(Format(BOMVersion.Type));
        InputItem.Description := BOMHeader.Description;
        case BOMHeader."Mfg. BOM Type" of
            BOMHeader."Mfg. BOM Type"::Formula:
                InputItem."Item Type" := InputItem."Item Type"::Intermediate;
            BOMHeader."Mfg. BOM Type"::BOM:
                InputItem."Item Type" := InputItem."Item Type"::"Finished Good";
        end;
        CreateItem.SetItem(InputItem);
        if CreateItem.RunModal <> ACTION::OK then
            exit;

        CreateItem.GetItem(InputItem);

        Item."No." := InputItem."No.";
        Item."No. Series" := InputItem."No. Series";
        Item.Insert(true);

        // P8007749
        TemplateCode := CreateItem.GetTemplateCode;
        if ConfigTemplateHeader.Get(TemplateCode) then begin
            ItemRecRef.GetTable(Item);
            ConfigTemplateManagement.UpdateRecord(ConfigTemplateHeader, ItemRecRef);
            ItemRecRef.SetTable(Item);
        end;
        // P8007749

        case BOMHeader."Mfg. BOM Type" of
            BOMHeader."Mfg. BOM Type"::Formula:
                begin
                    ItemUOM.Init;
                    ItemUOM."Item No." := Item."No.";
                    ItemUOM.Code := BOMVersion."Weight UOM";
                    ItemUOM.Insert;
                    ItemUOM.Code := BOMVersion."Volume UOM";
                    ItemUOM.Insert;
                    if BOMVersion."Primary UOM" = BOMVersion."Primary UOM"::Weight then
                        Item.Validate("Base Unit of Measure", BOMVersion."Weight UOM")
                    else
                        Item.Validate("Base Unit of Measure", BOMVersion."Volume UOM");
                    Item.Modify; // PR4.00
                    BOMVersion.CalcFields("Output Weight (Base)", "Output Volume (Base)");
                    if BOMVersion."Output Volume (Base)" <> 0 then
                        Item.Validate("Specific Gravity", Round(
                          BOMVersion."Output Weight (Base)" / (BOMVersion."Output Volume (Base)" * 1000), 0.00001));
                    Item.Validate("Weight UOM", BOMVersion."Weight UOM");
                    Item.Validate("Volume UOM", BOMVersion."Volume UOM");
                end;
            BOMHeader."Mfg. BOM Type"::BOM:
                begin
                    ItemUOM.Init;
                    ItemUOM."Item No." := Item."No.";
                    ItemUOM.Code := BOMVersion."Unit of Measure Code";
                    ItemUOM.Insert;
                    Item.Validate("Base Unit of Measure", BOMVersion."Unit of Measure Code");
                    Item.Modify; // PR4.00
                end;
        end;

        Item.Validate(Description, InputItem.Description);
        Item.Validate("Item Type", InputItem."Item Type");
        // Item.VALIDATE("Item Category Code",InputItem."Item Category Code"); // P8007749
        Item.Validate("Replenishment System", Item."Replenishment System"::"Prod. Order");
        Item.Validate("Manufacturing Policy", InputItem."Manufacturing Policy");
        Item.Validate("Production BOM No.", BOMHeader."No.");
        Item.Validate("Proper Shipping Name", BOMVersion."Proper Shipping Name");
        Item.Modify;

        case BOMHeader."Mfg. BOM Type" of
            BOMHeader."Mfg. BOM Type"::Formula:
                begin
                    Item.Validate("Production Grouping Item", Item."No.");
                end;
            BOMHeader."Mfg. BOM Type"::BOM:
                begin
                    BOMLine.SetRange("Production BOM No.", BOMHeader."No.");
                    BOMLine.SetRange("Version Code", VersionNo);
                    BOMLine.SetRange(Type, BOMLine.Type::Item);
                    BOMLine.SetFilter("No.", '<>%1', '');
                    if BOMLine.Find('-') then
                        repeat
                            Component.Get(BOMLine."No.");
                            if Component."Item Type" = Component."Item Type"::Intermediate then begin
                                if Item."Production Grouping Item" = '' then
                                    Item."Production Grouping Item" := Component."No."
                                else
                                    if Item."Production Grouping Item" <> Component."No." then begin
                                        Item."Production Grouping Item" := '';
                                        BOMLine.Find('+');
                                    end;
                            end;
                        until BOMLine.Next = 0;
                    Item.Validate("Production Grouping Item");
                end;
        end;

        Item.Modify(true);

        if BOMVersion.Status = BOMVersion.Status::Certified then begin
            Item.SetRecFilter;
            CalcStdCost.SetProperties(WorkDate, true, false, false, '', false);
            CalcStdCost.CalcItems(Item, TempSKU); // P8001030
            if TempSKU.Get('', Item."No.", '') then begin // P8001030
                                                          //Item := TempItem;                                   // P8001030
                ItemCostMgmt.TransferCostsFromSKUToItem(TempSKU, Item); // P8001030
                if Item."Costing Method" = Item."Costing Method"::Standard then
                    Item."Unit Cost" := Item."Standard Cost";
                Item."Last Unit Cost Calc. Date" := WorkDate;
                Item.Modify;
            end;
        end;

        Commit;

        if CreateItem.GetDisplayFlag then begin
            Item.FilterGroup(9);
            Item.SetRecFilter;
            Item.FilterGroup(0);
            ItemCard.SetTableView(Item);
            ItemCard.RunModal;
        end;
    end;

    procedure GetPreferredEquipment(BOMNo: Code[20]; VersionCode: Code[20]; LocationCode: Code[10]; var BOMEquip: Record "Prod. BOM Equipment")
    var
        ProdBOMEquip: Record "Prod. BOM Equipment";
        Resource: Record Resource;
        MinPref: Integer;
        CheckEquip: Boolean;
    begin
        // P8000219A
        // P8001030 - add parameter for LocationCode
        MinPref := 99;
        Clear(BOMEquip);

        ProdBOMEquip.SetRange("Production Bom No.", BOMNo);
        ProdBOMEquip.SetRange("Version Code", VersionCode);
        if ProdBOMEquip.Find('-') then
            repeat
                // P8001030
                if LocationCode = '' then
                    CheckEquip := true
                else begin
                    Resource.Get(ProdBOMEquip."Resource No.");
                    CheckEquip := Resource."Location Code" = LocationCode;
                end;
                if CheckEquip then
                    // P8001030
                    if ProdBOMEquip.Preference < MinPref then begin
                        BOMEquip := ProdBOMEquip;
                        MinPref := ProdBOMEquip.Preference;
                    end;
            until ProdBOMEquip.Next = 0;
    end;

    procedure GetCostingEquipment(BOMNo: Code[20]; VersionCode: Code[20]; LocationCode: Code[10]): Code[20]
    var
        BOMCost: Record "Prod. BOM Activity Cost";
        BOMEquipment: Record "Prod. BOM Equipment";
    begin
        // P8000219A
        // P8001030 - add parameter for LocationCode
        BOMCost.SetRange("Production Bom No.", BOMNo);
        BOMCost.SetRange("Version Code", VersionCode);
        BOMCost.SetFilter("Equipment No.", '<>%1', '');
        if BOMCost.Find('-') then begin
            GetPreferredEquipment(BOMNo, VersionCode, LocationCode, BOMEquipment); // P8001030
                                                                                   // P8001030
            if BOMEquipment."Resource No." = '' then
                exit('**********')
            else
                // P8001030
                exit(BOMEquipment."Resource No.");
        end else
            exit('');
    end;

    procedure CalcABCRtngCostPerUnit(ItemNo: Code[20]; ProdBOMNo: Code[20]; ProdBOMVersion: Code[20]; RoutingNo: Code[20]; RoutingLinkCode: Code[10]; EquipNo: Code[20]; var DirUnitCost: Decimal; var IndirCostPct: Decimal; var OvhdRate: Decimal; var UnitCost: Decimal): Boolean
    var
        BOMVersion: Record "Production BOM Version";
        BOMEquip: Record "Prod. BOM Equipment";
        BOMCost: Record "Prod. BOM Activity Cost";
        ItemUOM: Record "Item Unit of Measure";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        factor: Decimal;
    begin
        // P8000219A
        // P8000557A - add parameter for Equipment No.
        DirUnitCost := 0;
        IndirCostPct := 0;
        OvhdRate := 0;
        UnitCost := 0;

        BOMEquip.SetCurrentKey("Routing No.");
        BOMEquip.SetRange("Production Bom No.", ProdBOMNo);
        BOMEquip.SetRange("Version Code", ProdBOMVersion);
        BOMEquip.SetRange("Routing No.", RoutingNo);
        if EquipNo <> '' then                        // P8000557A
            BOMEquip.SetRange("Resource No.", EquipNo); // P8000557A
        if not BOMEquip.Find('-') then
            exit;

        BOMCost.SetCurrentKey("Production Bom No.", "Version Code", "Equipment No.", "Routing Link Code");
        BOMCost.SetRange("Production Bom No.", ProdBOMNo);
        BOMCost.SetRange("Version Code", ProdBOMVersion);
        BOMCost.SetRange("Equipment No.", BOMEquip."Resource No.");
        BOMCost.SetRange("Routing Link Code", RoutingLinkCode);
        if BOMCost.Find('-') then
            repeat
                if BOMCost."Resource Type" = BOMCost."Resource Type"::Person then begin
                    DirUnitCost += BOMCost."Extended Cost" - BOMCost."Overhead Cost Ext";
                    OvhdRate += BOMCost."Overhead Cost Ext";
                end else
                    OvhdRate += BOMCost."Extended Cost";
            until BOMCost.Next = 0;

        BOMVersion.Get(ProdBOMNo, ProdBOMVersion);
        if BOMVersion.Type = BOMVersion.Type::BOM then
            factor := 1
        else begin
            if BOMVersion."Primary UOM" = BOMVersion."Primary UOM"::Weight then begin
                BOMVersion.CalcFields("Output Weight (Base)");
                factor := BOMVersion."Output Weight (Base)";
            end else begin
                BOMVersion.CalcFields("Output Volume (Base)");
                factor := BOMVersion."Output Volume (Base)";
            end;
            factor /= P800UOMFns.UOMtoMetricBase(BOMVersion."Unit of Measure Code")
        end;

        ItemUOM.Get(ItemNo, BOMVersion."Unit of Measure Code");
        factor *= ItemUOM."Qty. per Unit of Measure";

        DirUnitCost /= factor;
        OvhdRate /= factor;
        UnitCost := DirUnitCost + OvhdRate;
    end;

    procedure InsertValueEntryABCDetail(ValueEntry: Record "Value Entry"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        ProdOrderLine: Record "Prod. Order Line";
        ProdBOMVersion: Record "Production BOM Version";
        BOMCost: array[2] of Record "Prod. BOM Activity Cost";
        ValueEntryABCDetail: Record "Value Entry ABC Detail";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        EqCode: Code[20];
        TotalBOMCost: Decimal;
        TotalCost: Decimal;
        TotalCostACY: Decimal;
        Cost: Decimal;
        CostACY: Decimal;
        Overhead: Decimal;
        OverheadACY: Decimal;
        BOMFactor: array[2] of Decimal;
        NoOfBOMs: Integer;
        BOMIndex: Integer;
        PackageBOM: Code[20];
    begin
        //ProdOrder.GET(ProdOrder.Status::Finished,ItemLedgerEntry."Prod. Order No.");      // P8000925
        // P8000925 - replace ProdOrder in the lines to follow with ProdOrderLine
        // P8006471 - BOMCost changed to 2 dimensions (1-primary; 2-package variant)
        ProdOrderLine.Get(ProdOrderLine.Status::Finished, ItemLedgerEntry."Order No.", ItemLedgerEntry."Order Line No."); // P8001132

        if ProdOrderLine."Equipment Code" = '' then
            EqCode := GetCostingEquipment(ProdOrderLine."Production BOM No.", ProdOrderLine."Production BOM Version Code", // P8001030
              ProdOrderLine."Location Code")                                                                              // P8001030
        else begin
            BOMCost[1].SetCurrentKey("Production Bom No.", "Version Code", "Equipment No.");
            BOMCost[1].SetRange("Production Bom No.", ProdOrderLine."Production BOM No.");
            BOMCost[1].SetRange("Version Code", ProdOrderLine."Production BOM Version Code");
            BOMCost[1].SetRange("Equipment No.", ProdOrderLine."Equipment Code");
            if BOMCost[1].FindFirst then
                EqCode := ProdOrderLine."Equipment Code"
            else
                EqCode := GetCostingEquipment(ProdOrderLine."Production BOM No.", ProdOrderLine."Production BOM Version Code", // P8001030
                  ProdOrderLine."Location Code")                                                                              // P8001030
        end;

        BOMCost[1].SetCurrentKey("Resource Type", "Include In Cost Rollup", "Equipment No.");  // P8007742
        BOMCost[1].SetRange("Production Bom No.", ProdOrderLine."Production BOM No.");
        BOMCost[1].SetRange("Version Code", ProdOrderLine."Production BOM Version Code");
        BOMCost[1].SetRange("Include In Cost Rollup", true);   // P8007742
        BOMCost[1].SetRange("Equipment No.", EqCode);
        BOMCost[1].CalcSums("Extended Cost");
        //IF BOMCost[1]."Extended Cost" = 0 THEN // P8006471
        //  EXIT;                                // P8006471
        TotalBOMCost := BOMCost[1]."Extended Cost";

        // P8006471
        PackageBOM := ProdOrderLine.PkgBOMNo;
        if PackageBOM <> '' then begin
            ProdBOMVersion.Get(ProdOrderLine."Production BOM No.", ProdOrderLine."Production BOM Version Code");
            BOMFactor[1] := P800UOMFns.GetConversionFromTo(ProdOrderLine."Item No.", ProdOrderLine.PkgBOMUOM, BOMVersionUOM(ProdBOMVersion)) / BOMVersionQtyFactor(ProdBOMVersion);
            TotalBOMCost := TotalBOMCost * BOMFactor[1];

            BOMCost[2].SetCurrentKey("Resource Type", "Include In Cost Rollup", "Equipment No.");  // P8007742
            BOMCost[2].SetRange("Production Bom No.", PackageBOM);
            BOMCost[2].SetRange("Version Code", ProdOrderLine.PkgBOMVersion);
            BOMCost[2].SetRange("Include In Cost Rollup", true);  // P8007742
            BOMCost[2].CalcSums("Extended Cost");
            BOMFactor[2] := 1;
            TotalBOMCost += BOMCost[2]."Extended Cost";
            NoOfBOMs := 2;
        end else begin
            BOMFactor[1] := 1;
            NoOfBOMs := 1;
        end;
        if TotalBOMCost = 0 then
            exit;
        // P8006471

        GLSetup.Get;
        if GLSetup."Additional Reporting Currency" <> '' then
            Currency.Get(GLSetup."Additional Reporting Currency");

        TotalCost := ValueEntry."Cost Amount (Actual)";
        TotalCostACY := ValueEntry."Cost Amount (Actual) (ACY)";

        for BOMIndex := 1 to NoOfBOMs do begin // P8006471
            if BOMCost[BOMIndex].FindSet then // P8006471
                repeat
                    // P8000459A
                    ValueEntryABCDetail.SetRange("Entry No.", ValueEntry."Entry No.");
                    ValueEntryABCDetail.SetRange("Resource No.", BOMCost[BOMIndex]."Resource No.");
                    if not ValueEntryABCDetail.Find('-') then begin
                        ValueEntryABCDetail.Init;
                        ValueEntryABCDetail."Entry No." := ValueEntry."Entry No.";
                        ValueEntryABCDetail."Resource No." := BOMCost[BOMIndex]."Resource No.";
                        ValueEntryABCDetail.Type := BOMCost[BOMIndex]."Resource Type";
                        ValueEntryABCDetail."Item Ledger Entry No." := ItemLedgerEntry."Entry No.";
                        ValueEntryABCDetail.Insert;
                    end;
                    Cost := Round(TotalCost * BOMFactor[BOMIndex] * BOMCost[BOMIndex]."Extended Cost" / TotalBOMCost, GLSetup."Amount Rounding Precision"); // P8006471
                    CostACY := Round(TotalCostACY * BOMFactor[BOMIndex] * BOMCost[BOMIndex]."Extended Cost" / TotalBOMCost, Currency."Amount Rounding Precision"); // P8006471
                    ValueEntryABCDetail.Cost += Cost;
                    ValueEntryABCDetail."Cost (ACY)" += CostACY;
                    TotalBOMCost -= BOMFactor[BOMIndex] * BOMCost[BOMIndex]."Extended Cost"; // P8006471
                    TotalCost -= Cost;
                    TotalCostACY -= CostACY;
                    if BOMCost[BOMIndex]."Extended Cost" <> 0 then begin
                        Overhead := Round(Cost * BOMCost[BOMIndex]."Overhead Cost Ext" / BOMCost[BOMIndex]."Extended Cost", GLSetup."Amount Rounding Precision");
                        OverheadACY := Round(CostACY * BOMCost[BOMIndex]."Overhead Cost Ext" / BOMCost[BOMIndex]."Extended Cost", GLSetup."Amount Rounding Precision");
                        ValueEntryABCDetail.Overhead += Overhead;
                        ValueEntryABCDetail.Cost -= Overhead;
                        ValueEntryABCDetail."Overhead (ACY)" += OverheadACY;
                        ValueEntryABCDetail."Cost (ACY)" -= OverheadACY;
                    end;
                    ValueEntryABCDetail.Modify;
                    // P8000459A
                until (BOMCost[BOMIndex].Next = 0) or (TotalBOMCost = 0); // P8000562A
                                                                          // P8006471
            if TotalBOMCost = 0 then
                BOMIndex := NoOfBOMs;
        end
        // P8006471
    end;

    procedure GetProdBOMAtSKU(Item: Record Item; VariantCode: Code[10]; LocationCode: Code[10]): Code[20]
    var
        SKU: Record "Stockkeeping Unit";
    begin
        // P8001030
        if SKU.Get(LocationCode, Item."No.", VariantCode) then
            if SKU."Production BOM No." <> '' then
                exit(SKU."Production BOM No.");
        exit(Item."Production BOM No.");
    end;

    procedure GetRoutingAtSKU(Item: Record Item; VariantCode: Code[10]; LocationCode: Code[10]): Code[20]
    var
        SKU: Record "Stockkeeping Unit";
    begin
        // P8001030
        if SKU.Get(LocationCode, Item."No.", VariantCode) then
            if SKU."Routing No." <> '' then
                exit(SKU."Routing No.");
        exit(Item."Routing No.");
    end;
}

