codeunit 99000793 "Calculate Low-Level Code"
{
    // PRW16.00.06
    // P8001030, Columbus IT, Jack Reynolds, 30 MAY 12
    //   Support for BOM/Routing on SKU
    // 
    // P8001092, Columbus IT, Don Bresee, 30 AUG 12
    //   Add logic for Item & Co-Product Process BOMs
    // 
    // PRW17.00
    // P8001145, Columbus IT, Don Bresee, 26 MAR 13
    //   Rework Low-Level Code Calculation

    Permissions = TableData Item = rm,
                  TableData "Manufacturing Setup" = r;
    TableNo = Item;

    trigger OnRun()
    var
        ProdBOM: Record "Production BOM Header";
        Item2: Record Item;
        SKU: Record "Stockkeeping Unit";
        ItemProcessBOM: Record "Production BOM Header";
        FamilyLine: Record "Family Line";
    begin
        Item2.Copy(Rec);
        Item := Item2; // to store the last item- used in RecalcLowerLevels
        Item2."Low-Level Code" := CalcLevels(1, Item2."No.", 0, 0);
        if ProdBOM.Get(Item."Production BOM No.") then
            SetRecursiveLevelsOnBOM(ProdBOM, Item2."Low-Level Code" + 1, false);
        SetLevelsOnOtherItemBOMs(Item2, false, true); // P8001145
        OnBeforeItemModify(Item2);
        Item2.Modify();
        Copy(Item2);
    end;

    var
        Item: Record Item;
        ActualProdBOM: Record "Production BOM Header";
        TempBOMItem: Record Item temporary;

        ProdBomErr: Label 'The maximum number of BOM levels, %1, was exceeded. The process stopped at item number %2, BOM header number %3, BOM level %4.';

    procedure CalcLevels(Type: Option " ",Item,"Production BOM",Assembly; No: Code[20]; Level: Integer; LevelDepth: Integer): Integer
    var
        Item2: Record Item;
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMLine: Record "Production BOM Line";
        AsmBOMComp: Record "BOM Component";
        ProductionBOMVersion: Record "Production BOM Version";
        ActLevel: Integer;
        TotalLevels: Integer;
        CalculateDeeperLevel: Boolean;
    begin
        if LevelDepth > 50 then
            Error(ProdBomErr, 50, Item."No.", No, Level);

        TotalLevels := Level;

        case Type of
            Type::"Production BOM":
                begin
                    Item2.SetCurrentKey("Production BOM No.");
                    Item2.SetRange("Production BOM No.", No);
                    // IF Item2.FindSet() then         // P8001145
                    if GetFirstBOMItem(No, Item2) then // P8001145
                        repeat
                            ActLevel := CalcLevels(Type::Item, Item2."No.", Level + 1, LevelDepth + 1);
                            if ActLevel > TotalLevels then
                                TotalLevels := ActLevel;
                            // until Item2.Next() = 0;         // P8001145
                        until not GetNextBOMItem(Item2); // P8001145
                    OnCalcLevelsForProdBOM(Item2, No, Level, LevelDepth, TotalLevels);
                end;
            Type::Assembly:
                begin
                    Item2.Get(No);
                    ActLevel := CalcLevels(Type::Item, Item2."No.", Level + 1, LevelDepth + 1);
                    if ActLevel > TotalLevels then
                        TotalLevels := ActLevel;
                end;
            else
                Item2.Get(No);
        end;

        AsmBOMComp.SetCurrentKey(Type, "No.");
        AsmBOMComp.SetRange(Type, Type);
        AsmBOMComp.SetRange("No.", No);
        if AsmBOMComp.FindSet() then
            repeat
                ActLevel := CalcLevels(Type::Assembly, AsmBOMComp."Parent Item No.", Level, LevelDepth + 1);
                if ActLevel > TotalLevels then
                    TotalLevels := ActLevel;
            until AsmBOMComp.Next() = 0;

        ProdBOMLine.SetCurrentKey(Type, "No.");
        ProdBOMLine.SetRange(Type, Type);
        ProdBOMLine.SetRange("No.", No);
        if ProdBOMLine.FindSet() then
            repeat
                if ProdBOMHeader.Get(ProdBOMLine."Production BOM No.") then begin
                    if ProdBOMHeader."No." = ActualProdBOM."No." then
                        Error(ProdBomErr, 50, Item."No.", No, Level);

                    if ProdBOMLine."Version Code" <> '' then begin
                        ProductionBOMVersion.Get(ProdBOMLine."Production BOM No.", ProdBOMLine."Version Code");
                        CalculateDeeperLevel := ProductionBOMVersion.Status = ProductionBOMVersion.Status::Certified;
                    end else
                        CalculateDeeperLevel := ProdBOMHeader.Status = ProdBOMHeader.Status::Certified;

                    if CalculateDeeperLevel then begin
                        ActLevel := CalcLevels(Type::"Production BOM", ProdBOMLine."Production BOM No.", Level, LevelDepth + 1);
                        if ActLevel > TotalLevels then
                            TotalLevels := ActLevel;
                    end;
                end;
            until ProdBOMLine.Next() = 0;

        OnAfterCalcLevels(Type, No, TotalLevels, Level);
        exit(TotalLevels);
    end;

    procedure RecalcLowerLevels(ProdBOMNo: Code[20]; LowLevelCode: Integer; IgnoreMissingItemsOrBOMs: Boolean)
    var
        CompItem: Record Item;
        CompBOM: Record "Production BOM Header";
        ProdBOMLine: Record "Production BOM Line";
        ProductionBOMVersion: Record "Production BOM Version";
        EntityPresent: Boolean;
        CalculateDeeperLevel: Boolean;
    begin
        if LowLevelCode > 50 then
            Error(ProdBomErr, 50, Item."No.", ProdBOMNo, LowLevelCode);

        ProdBOMLine.SetRange("Production BOM No.", ProdBOMNo);
        ProdBOMLine.SetFilter("No.", '<>%1', '');

        if ProdBOMLine.FindSet() then
            repeat
                if ProdBOMLine."Version Code" <> '' then begin
                    ProductionBOMVersion.Get(ProdBOMLine."Production BOM No.", ProdBOMLine."Version Code");
                    CalculateDeeperLevel := ProductionBOMVersion.Status <> ProductionBOMVersion.Status::Closed;
                end else begin
                    CompBOM.Get(ProdBOMLine."Production BOM No.");
                    CalculateDeeperLevel := CompBOM.Status <> CompBOM.Status::Closed;
                end;

                // closed BOMs are skipped
                if CalculateDeeperLevel then
                    case ProdBOMLine.Type of
                        ProdBOMLine.Type::Item:
                            begin
                                EntityPresent := CompItem.Get(ProdBOMLine."No.");
                                if EntityPresent or (not IgnoreMissingItemsOrBOMs) then
                                    SetRecursiveLevelsOnItem(CompItem, LowLevelCode, IgnoreMissingItemsOrBOMs);
                            end;
                        ProdBOMLine.Type::"Production BOM":
                            begin
                                EntityPresent := CompBOM.Get(ProdBOMLine."No.");
                                if EntityPresent or (not IgnoreMissingItemsOrBOMs) then
                                    SetRecursiveLevelsOnBOM(CompBOM, LowLevelCode, IgnoreMissingItemsOrBOMs);
                            end
                    end;
            until ProdBOMLine.Next() = 0;
    end;

    procedure RecalcAsmLowerLevels(ParentItemNo: Code[20]; LowLevelCode: Integer; IgnoreMissingItemsOrBOMs: Boolean)
    var
        CompItem: Record Item;
        BOMComp: Record "BOM Component";
        EntityPresent: Boolean;
    begin
        if LowLevelCode > 50 then
            Error(ProdBomErr, 50, Item."No.", Item."No.", LowLevelCode);

        BOMComp.SetRange("Parent Item No.", ParentItemNo);
        BOMComp.SetRange(Type, BOMComp.Type::Item);
        BOMComp.SetFilter("No.", '<>%1', '');
        if BOMComp.FindSet() then
            repeat
                EntityPresent := CompItem.Get(BOMComp."No.");
                if EntityPresent or not IgnoreMissingItemsOrBOMs then
                    SetRecursiveLevelsOnItem(CompItem, LowLevelCode, IgnoreMissingItemsOrBOMs);
            until BOMComp.Next() = 0;
    end;

    procedure SetRecursiveLevelsOnItem(var CompItem: Record Item; LowLevelCode: Integer; IgnoreMissingItemsOrBOMs: Boolean)
    var
        CompBOM: Record "Production BOM Header";
        xLowLevelCode: Integer;
        EntityPresent: Boolean;
        SKU: Record "Stockkeeping Unit";
        ItemProcessBOM: Record "Production BOM Header";
        FamilyLine: Record "Family Line";
    begin
        Item := CompItem; // to store the last item- used in RecalcLowerLevels
        xLowLevelCode := CompItem."Low-Level Code";
        CompItem."Low-Level Code" := GetMax(Item."Low-Level Code", LowLevelCode);
        if xLowLevelCode <> CompItem."Low-Level Code" then begin
            CompItem.CalcFields("Assembly BOM");
            if CompItem."Assembly BOM" then
                RecalcAsmLowerLevels(CompItem."No.", CompItem."Low-Level Code" + 1, IgnoreMissingItemsOrBOMs);
            if CompItem."Production BOM No." <> '' then begin
                // calc low level code for BOM set in the item
                EntityPresent := CompBOM.Get(CompItem."Production BOM No.");
                if EntityPresent or (not IgnoreMissingItemsOrBOMs) then
                    SetRecursiveLevelsOnBOM(CompBOM, CompItem."Low-Level Code" + 1, IgnoreMissingItemsOrBOMs);
            end;
            OnSetRecursiveLevelsOnItemOnBeforeCompItemModify(CompItem, IgnoreMissingItemsOrBOMs);
            CompItem.Modify();
        end;
    end;

    procedure SetRecursiveLevelsOnBOM(var CompBOM: Record "Production BOM Header"; LowLevelCode: Integer; IgnoreMissingItemsOrBOMs: Boolean)
    var
        xLowLevelCode: Integer;
    begin
        xLowLevelCode := CompBOM."Low-Level Code";
        if CompBOM.Status = CompBOM.Status::Certified then begin
            // set low level on this BOM
            CompBOM."Low-Level Code" := GetMax(CompBOM."Low-Level Code", LowLevelCode);
            if xLowLevelCode <> CompBOM."Low-Level Code" then begin
                RecalcLowerLevels(CompBOM."No.", LowLevelCode, IgnoreMissingItemsOrBOMs);
                CompBOM.Modify();
            end;
        end;
    end;

    procedure GetMax(Level1: Integer; Level2: Integer) Result: Integer
    begin
        if Level1 > Level2 then
            Result := Level1
        else
            Result := Level2;
    end;

    procedure SetActualProdBOM(ActualProdBOM2: Record "Production BOM Header")
    begin
        ActualProdBOM := ActualProdBOM2;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcLevels(Type: Option " ",Item,"Production BOM",Assembly; No: Code[20]; var TotalLevels: Integer; Level: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeItemModify(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcLevelsForProdBOM(var Item: Record Item; No: Code[20]; Level: Integer; LevelDepth: Integer; var TotalLevels: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetRecursiveLevelsOnItemOnBeforeCompItemModify(var CompItem: Record Item; IgnoreMissingItemsOrBOMs: Boolean)
    begin
    end;

    local procedure SetLevelsOnOtherItemBOMs(var Item2: Record Item; IgnoreMissingItemsOrBOMs: Boolean; UpdateFamilyLines: Boolean)
    var
        SKU: Record "Stockkeeping Unit";
        ItemProcessBOM: Record "Production BOM Header";
        FamilyLine: Record "Family Line";
    begin
        // P8001145
        with SKU do begin
            SetCurrentKey("Item No.");
            SetRange("Item No.", Item2."No.");
            SetFilter("Production BOM No.", '<>%1', '');
            if FindSet then
                repeat
                    SetLevelsOnOtherBOM("Production BOM No.", Item2, IgnoreMissingItemsOrBOMs);
                until Next = 0;
        end;
        with ItemProcessBOM do begin
            SetCurrentKey("Output Item No.");
            SetRange("Output Item No.", Item2."No.");
            if FindSet then
                repeat
                    SetLevelsOnOtherBOM("No.", Item2, IgnoreMissingItemsOrBOMs);
                until Next = 0;
        end;
        with FamilyLine do begin
            SetCurrentKey("Item No.");
            SetRange("Item No.", Item2."No.");
            SetRange("Process Family", true);
            if FindSet then
                repeat
                    SetLevelsOnOtherBOM("Family No.", Item2, IgnoreMissingItemsOrBOMs);
                until Next = 0;
            if UpdateFamilyLines then begin
                SetRange("Process Family");
                ModifyAll("Low-Level Code", Item2."Low-Level Code");
            end;
        end;
    end;

    local procedure SetLevelsOnOtherBOM(ProdBOMNo: Code[20]; var Item2: Record Item; IgnoreMissingItemsOrBOMs: Boolean)
    var
        ProdBOM: Record "Production BOM Header";
        NoBOMFound: Boolean;
    begin
        // P8001145
        if IgnoreMissingItemsOrBOMs then
            NoBOMFound := not ProdBOM.Get(ProdBOMNo)
        else
            ProdBOM.Get(ProdBOMNo);
        if not NoBOMFound then
            SetRecursiveLevelsOnBOM(ProdBOM, Item2."Low-Level Code" + 1, IgnoreMissingItemsOrBOMs);
    end;

    procedure GetFirstBOMItem(ProdBOMNo: Code[20]; var Item2: Record Item): Boolean
    var
        Item3: Record Item;
        SKU: Record "Stockkeeping Unit";
        ItemProcessBOM: Record "Production BOM Header";
        FamilyLine: Record "Family Line";
    begin
        // P8001145
        TempBOMItem.DeleteAll;
        with Item3 do begin
            SetCurrentKey("Production BOM No.");
            SetRange("Production BOM No.", ProdBOMNo);
            if FindSet then
                repeat
                    AddTempBOMItem("No.");
                until Next = 0;
        end;
        with SKU do begin
            SetCurrentKey("Production BOM No.");
            SetRange("Production BOM No.", ProdBOMNo);
            if FindSet then
                repeat
                    AddTempBOMItem("Item No.");
                until Next = 0;
        end;
        with ItemProcessBOM do
            if Get(ProdBOMNo) then
                if ("Output Type" = "Output Type"::Item) and ("Output Item No." <> '') then
                    AddTempBOMItem("Output Item No.");
        with FamilyLine do begin
            SetRange("Family No.", ProdBOMNo);
            SetRange("Process Family", true);
            if FindSet then
                repeat
                    AddTempBOMItem("Item No.");
                until Next = 0;
        end;
        with TempBOMItem do
            if FindSet then
                exit(Item2.Get("No."));
    end;

    local procedure AddTempBOMItem(ItemNo: Code[20])
    var
        Item2: Record Item;
    begin
        // P8001145
        if Item2.Get(ItemNo) then
            with TempBOMItem do
                if not Get(ItemNo) then begin
                    "No." := ItemNo;
                    Insert;
                end;
    end;

    procedure GetNextBOMItem(var Item2: Record Item): Boolean
    begin
        // P8001145
        with TempBOMItem do
            if (Next <> 0) then
                exit(Item2.Get("No."));
    end;

    procedure GetBOMItemCount(): Integer
    begin
        exit(TempBOMItem.Count); // P8001145
    end;
}
