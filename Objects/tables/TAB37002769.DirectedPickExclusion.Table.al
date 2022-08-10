table 37002769 "Directed Pick Exclusion"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Directed Pick Exclusion';

    fields
    {
        field(1; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(2; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = Bin.Code WHERE("Location Code" = FIELD("Location Code"));
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(4; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(5; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(6; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
            TableRelation = "Lot No. Information"."Lot No." WHERE("Item No." = FIELD("Item No."),
                                                                   "Variant Code" = FIELD("Variant Code"));
        }
        field(7; "Container Qty."; Decimal)
        {
            BlankZero = true;
            Caption = 'Container Qty.';
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(Key1; "Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code", "Lot No.", "Container Qty.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        ContainerFns: Codeunit "Container Functions";

    procedure AddBinExclusion(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; LotNo: Code[50])
    begin
        Reset;
        DeleteOverriddenExclusions(LocationCode, BinCode, ItemNo, VariantCode, UnitOfMeasureCode, LotNo, 0);
        if BinExclusionExists(LocationCode, BinCode, ItemNo, VariantCode, '', '') then
            exit;
        if (LotNo <> '') then
            if BinExclusionExists(LocationCode, BinCode, ItemNo, VariantCode, '', LotNo) then
                exit;
        if (UnitOfMeasureCode <> '') then begin
            if BinExclusionExists(LocationCode, BinCode, ItemNo, VariantCode, UnitOfMeasureCode, '') then
                exit;
            if (LotNo <> '') then
                if BinExclusionExists(LocationCode, BinCode, ItemNo, VariantCode, UnitOfMeasureCode, LotNo) then
                    exit;
        end;
        Insert;
    end;

    procedure AddContQtyExclusion(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; LotNo: Code[50]; ContainerQty: Decimal)
    begin
        Reset;
        DeleteOverriddenExclusions(LocationCode, BinCode, ItemNo, VariantCode, UnitOfMeasureCode, LotNo, ContainerQty);
        if BinExclusionExists(LocationCode, BinCode, ItemNo, VariantCode, UnitOfMeasureCode, '') then
            exit;
        if ContQtyExclusionExists(LocationCode, BinCode, ItemNo, VariantCode, UnitOfMeasureCode, '', ContainerQty) then
            exit;
        if (LotNo <> '') then begin
            if BinExclusionExists(LocationCode, BinCode, ItemNo, VariantCode, UnitOfMeasureCode, LotNo) then
                exit;
            if ContQtyExclusionExists(LocationCode, BinCode, ItemNo, VariantCode, UnitOfMeasureCode, LotNo, ContainerQty) then
                exit;
        end;
        Insert;
    end;

    procedure AddExclusion(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; LotNo: Code[50]; ContainerQty: Decimal)
    begin
        if (ContainerQty = 0) then
            AddBinExclusion(LocationCode, BinCode, ItemNo, VariantCode, UnitOfMeasureCode, LotNo)
        else
            AddContQtyExclusion(LocationCode, BinCode, ItemNo, VariantCode, UnitOfMeasureCode, LotNo, ContainerQty);
    end;

    local procedure DeleteOverriddenExclusions(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; LotNo: Code[50]; ContainerQty: Decimal)
    begin
        if (UnitOfMeasureCode = '') or (LotNo = '') or (ContainerQty = 0) then begin
            SetFilters(LocationCode, BinCode, ItemNo, VariantCode, UnitOfMeasureCode);
            if (LotNo <> '') then
                SetRange("Lot No.", LotNo);
            if (ContainerQty <> 0) then
                SetRange("Container Qty.", ContainerQty);
            DeleteAll;
            Reset;
        end;
    end;

    procedure SetFilters(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10])
    begin
        Reset;
        SetRange("Location Code", LocationCode);
        SetRange("Bin Code", BinCode);
        SetRange("Item No.", ItemNo);
        SetRange("Variant Code", VariantCode);
        if (UnitOfMeasureCode <> '') then
            SetRange("Unit of Measure Code", UnitOfMeasureCode);
    end;

    procedure SetBinContentFilters(var BinContent: Record "Bin Content")
    begin
        SetFilters(
          BinContent."Location Code", BinContent."Bin Code", BinContent."Item No.",
          BinContent."Variant Code", BinContent."Unit of Measure Code");
    end;

    local procedure InitPickExclusion(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; LotNo: Code[50]; ContainerQty: Decimal)
    begin
        "Location Code" := LocationCode;
        "Bin Code" := BinCode;
        "Item No." := ItemNo;
        "Variant Code" := VariantCode;
        "Unit of Measure Code" := UnitOfMeasureCode;
        "Lot No." := LotNo;
        "Container Qty." := ContainerQty;
    end;

    local procedure PickExclusionExists(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; LotNo: Code[50]; ContainerQty: Decimal): Boolean
    begin
        InitPickExclusion(LocationCode, BinCode, ItemNo, VariantCode, UnitOfMeasureCode, LotNo, ContainerQty);
        exit(Find);
    end;

    local procedure BinExclusionExists(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; LotNo: Code[50]): Boolean
    begin
        exit(PickExclusionExists(LocationCode, BinCode, ItemNo, VariantCode, UnitOfMeasureCode, LotNo, 0));
    end;

    local procedure ContQtyExclusionExists(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; LotNo: Code[50]; ContainerQty: Decimal): Boolean
    begin
        exit(PickExclusionExists(LocationCode, BinCode, ItemNo, VariantCode, UnitOfMeasureCode, LotNo, ContainerQty));
    end;

    procedure BinNotExcluded(var BinContent: Record "Bin Content"; AllUOMs: Boolean; LotNo: Code[50]): Boolean
    begin
        SetBinContentFilters(BinContent);
        if AllUOMs then
            SetFilter("Unit of Measure Code", '%1', '')
        else
            SetFilter("Unit of Measure Code", '%1|%2', '', BinContent."Unit of Measure Code");
        SetFilter("Lot No.", '%1|%2', '', LotNo);
        SetRange("Container Qty.", 0);
        exit(IsEmpty);
    end;

    procedure FindBinLotExclusions(var BinContent: Record "Bin Content"): Boolean
    begin
        SetBinContentFilters(BinContent);
        SetFilter("Lot No.", '<>%1', '');
        SetRange("Container Qty.", 0);
        exit(FindSet);
    end;

    procedure AddContQtyExclusions(var QtyBase: Decimal; var BinContent: Record "Bin Content"; LotNo: Code[50]; var TempWhseActivLine: Record "Warehouse Activity Line" temporary)
    begin
        SetBinContentFilters(BinContent);
        if (LotNo <> '') then
            SetFilter("Lot No.", '%1|%2', '', LotNo);
        SetFilter("Container Qty.", '<>0');
        if FindSet then begin
            repeat
                QtyBase := QtyBase - CalcContQtyExclusion(LotNo, TempWhseActivLine);
            until (QtyBase <= 0) or (Next = 0);
            if (QtyBase < 0) then
                QtyBase := 0;
        end;
    end;

    local procedure CalcContQtyExclusion(LotNo: Code[50]; var TempWhseActivLine: Record "Warehouse Activity Line" temporary): Decimal
    var
        TempContainerTotal: Record "Warehouse Activity Line" temporary;
        NumContainers: Integer;
    begin
        ContainerFns.BuildContainerTotals(
          "Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code",
          LotNo, "Container Qty.", true, TempWhseActivLine, TempContainerTotal);
        if TempContainerTotal.FindSet then begin
            repeat
                NumContainers := NumContainers + TempContainerTotal.Quantity;
            until (TempContainerTotal.Next = 0);
            exit(NumContainers * "Container Qty.");
        end;
    end;

    procedure ContQtyNotExcluded(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; LotNo: Code[50]; ContainerQty: Decimal): Boolean
    begin
        SetFilters(LocationCode, BinCode, ItemNo, VariantCode, UnitOfMeasureCode);
        if (LotNo <> '') then
            SetFilter("Lot No.", '%1|%2', '', LotNo);
        SetRange("Container Qty.", ContainerQty);
        exit(IsEmpty);
    end;

    procedure BuildTotalExclusions(LocationCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; LotNo: Code[50]; BinExclusions: Boolean; var TempPickExclusion: Record "Directed Pick Exclusion" temporary)
    var
        PickExclusion: Record "Directed Pick Exclusion";
    begin
        Reset;
        DeleteAll;
        PickExclusion.SetFilters(LocationCode, BinCode, ItemNo, VariantCode, UnitOfMeasureCode);
        if (LotNo <> '') then
            PickExclusion.SetFilter("Lot No.", '%1|%2', '', LotNo);
        if BinExclusions then
            PickExclusion.SetRange("Container Qty.", 0)
        else
            PickExclusion.SetFilter("Container Qty.", '<>0');
        if PickExclusion.FindSet then
            repeat
                Rec := PickExclusion;
                Insert;
            until (PickExclusion.Next = 0);
        TempPickExclusion.Copy(PickExclusion);
        if TempPickExclusion.FindSet then
            repeat
                AddExclusion(
                  LocationCode, BinCode, ItemNo, VariantCode, TempPickExclusion."Unit of Measure Code",
                  TempPickExclusion."Lot No.", TempPickExclusion."Container Qty.");
            until (TempPickExclusion.Next = 0);
    end;
}

