codeunit 37002921 "Allergen Rollup"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens


    trigger OnRun()
    begin
        RollupAllergens;
    end;

    var
        AllergenRollup: Record "Allergen Rollup" temporary;
        Text001: Label 'Cyclical reference found for %1 %2.';
        AllergenDetail: Record "Allergen Detail" temporary;
        AllergenManagement: Codeunit "Allergen Management";
        Text002: Label 'Cyclical reference found for %1 %2, %3.';
        TotalRecords: Integer;
        RecordCount: Integer;
        GatherDetail: Boolean;
        Window: Dialog;
        Text003: Label 'Processing @1@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\Updating Item #2############\Updating BOM #3############';

    local procedure RollupAllergens()
    var
        ProductionBOMHeader: Record "Production BOM Header";
        Item: Record Item;
    begin
        Item.SetRange("Direct Allergen Set ID", 0);

        OpenWindow(Item, ProductionBOMHeader);

        if ProductionBOMHeader.FindSet then
            repeat
                RollupBOM(ProductionBOMHeader."No.");
            until ProductionBOMHeader.Next = 0;

        if Item.FindSet then
            repeat
                RollupItem(Item);
            until Item.Next = 0;

        UpdateMasterTables;

        CloseWindow;
    end;

    local procedure RollupBOM(ProductionBOMNo: Code[20]): Integer
    var
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMVersion: Record "Production BOM Version";
        AllergenRollup2: Record "Allergen Rollup";
        AllergenSetsToMerge: Record "Integer" temporary;
        AllergenSetID: Integer;
    begin
        if AllergenRollup.Get(AllergenRollup.Type::BOM, ProductionBOMNo, '') then begin
            case AllergenRollup.Status of
                AllergenRollup.Status::Processing:
                    Error(Text001, ProductionBOMHeader.TableCaption, ProductionBOMNo);
                AllergenRollup.Status::Indirect:
                    exit(AllergenRollup."Allergen Set ID");
            end;
        end else begin
            RecordCount += 1;
            UpdateWindow(1, RecordCount);

            AllergenRollup2.Type := AllergenRollup2.Type::BOM;
            AllergenRollup2."No." := ProductionBOMNo;
            AllergenRollup2.Status := AllergenRollup2.Status::Processing;
            AllergenRollup := AllergenRollup2;
            AllergenRollup.Insert;
        end;

        ProductionBOMVersion.SetRange("Production BOM No.", ProductionBOMNo);
        ProductionBOMVersion.SetRange(Status, ProductionBOMVersion.Status::Certified);
        if ProductionBOMVersion.FindSet then
            repeat
                AllergenSetID := RollupBOMVersion(ProductionBOMVersion."Production BOM No.", ProductionBOMVersion."Version Code");
                AddAllergentSetToMergeList(AllergenSetID, AllergenSetsToMerge);
            until ProductionBOMVersion.Next = 0;

        AllergenRollup2."Allergen Set ID" := AllergenManagement.MergeAllergenSets(AllergenSetsToMerge);
        AllergenRollup2.Status := AllergenRollup2.Status::Indirect;
        AllergenRollup := AllergenRollup2;
        AllergenRollup.Modify;

        exit(AllergenRollup."Allergen Set ID");
    end;

    local procedure RollupBOMVersion(ProductionBOMNo: Code[20]; VersionCode: Code[20]): Integer
    var
        ProductionBOMVersion: Record "Production BOM Version";
        ProductionBOMLine: Record "Production BOM Line";
        AllergenRollup2: Record "Allergen Rollup";
        AllergenSetsToMerge: Record "Integer" temporary;
        AllergenSetID: Integer;
    begin
        if AllergenRollup.Get(AllergenRollup.Type::BOM, ProductionBOMNo, VersionCode) then begin
            case AllergenRollup.Status of
                AllergenRollup.Status::Processing:
                    Error(Text002, ProductionBOMVersion.TableCaption, ProductionBOMNo, VersionCode);
                AllergenRollup.Status::Indirect:
                    exit(AllergenRollup."Allergen Set ID");
            end;
        end else begin
            ProductionBOMVersion.Get(ProductionBOMNo, VersionCode);
            if ProductionBOMVersion."Direct Allergen Set ID" <> 0 then begin
                AddAllergentSetToMergeList(ProductionBOMVersion."Direct Allergen Set ID", AllergenSetsToMerge);
                if GatherDetail then
                    AddAllergenSetToDetail(ProductionBOMVersion."Direct Allergen Set ID", AllergenDetail."Source Type"::BOM, ProductionBOMNo, VersionCode);
            end;

            AllergenRollup2.Type := AllergenRollup2.Type::BOM;
            AllergenRollup2."No." := ProductionBOMNo;
            AllergenRollup2."Version Code" := VersionCode;
            AllergenRollup2.Status := AllergenRollup2.Status::Processing;
            AllergenRollup := AllergenRollup2;
            AllergenRollup.Insert;
        end;

        ProductionBOMLine.SetRange("Production BOM No.", ProductionBOMNo);
        ProductionBOMLine.SetRange("Version Code", VersionCode);
        ProductionBOMLine.SetFilter(Type, '>0');
        if ProductionBOMLine.FindSet then
            repeat
                case ProductionBOMLine.Type of
                    ProductionBOMLine.Type::Item:
                        AllergenSetID := RollupItem(ProductionBOMLine."No.");
                    ProductionBOMLine.Type::"Production BOM":
                        AllergenSetID := RollupBOM(ProductionBOMLine."No.");
                    ProductionBOMLine.Type::FOODUnapprovedItem:
                        AllergenSetID := RollupUnapprovedItem(ProductionBOMLine."No.");
                    ProductionBOMLine.Type::FOODVariable:
                        AllergenSetID := RollupVariable(ProductionBOMLine."No.");
                end;
                AddAllergentSetToMergeList(AllergenSetID, AllergenSetsToMerge);
            until ProductionBOMLine.Next = 0;

        AllergenRollup2."Allergen Set ID" := AllergenManagement.MergeAllergenSets(AllergenSetsToMerge);
        AllergenRollup2.Status := AllergenRollup2.Status::Indirect;
        AllergenRollup := AllergenRollup2;
        AllergenRollup.Modify;

        exit(AllergenRollup."Allergen Set ID");
    end;

    local procedure RollupItem(ItemSpecification: Variant): Integer
    var
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
        BOMComponent: Record "BOM Component";
        ProductionBOMHeader: Record "Production BOM Header";
        FamilyLine: Record "Family Line";
        ItemVariant: Record "Item Variant";
        AllergenRollup2: Record "Allergen Rollup";
        AllergenSetsToMerge: Record "Integer" temporary;
        AllergenSetID: Integer;
    begin
        if ItemSpecification.IsRecord then
            Item := ItemSpecification
        else
            Item.Get(ItemSpecification);

        if AllergenRollup.Get(AllergenRollup.Type::Item, Item."No.", '') then begin
            case AllergenRollup.Status of
                AllergenRollup.Status::Processing:
                    Error(Text001, Item.TableCaption, Item."No.");
                AllergenRollup.Status::Direct, AllergenRollup.Status::Indirect:
                    exit(AllergenRollup."Allergen Set ID");
            end;
        end else begin
            if Item."Direct Allergen Set ID" <> 0 then begin
                AllergenRollup.Type := AllergenRollup.Type::Item;
                AllergenRollup."No." := Item."No.";
                AllergenRollup."Version Code" := '';
                AllergenRollup.Status := AllergenRollup.Status::Direct;
                AllergenRollup."Allergen Set ID" := Item."Direct Allergen Set ID";
                AllergenRollup.Insert;

                if GatherDetail then
                    AddAllergenSetToDetail(Item."Direct Allergen Set ID", AllergenDetail."Source Type"::Item, Item."No.", '');

                exit(AllergenRollup."Allergen Set ID");
            end else begin
                RecordCount += 1;
                UpdateWindow(1, RecordCount);

                AllergenRollup2.Type := AllergenRollup2.Type::Item;
                AllergenRollup2."No." := Item."No.";
                AllergenRollup2.Status := AllergenRollup2.Status::Processing;
                AllergenRollup := AllergenRollup2;
                AllergenRollup.Insert;
            end;
        end;

        if Item."Production BOM No." <> '' then begin
            AllergenSetID := RollupBOM(Item."Production BOM No.");
            AddAllergentSetToMergeList(AllergenSetID, AllergenSetsToMerge);

            SKU.SetRange("Item No.", Item."No.");
            SKU.SetFilter("Production BOM No.", '<>%1&<>%1', '', Item."Production BOM No.");
            if SKU.FindSet then
                repeat
                    AllergenSetID := RollupBOM(SKU."Production BOM No.");
                    AddAllergentSetToMergeList(AllergenSetID, AllergenSetsToMerge);
                until SKU.Next = 0;
        end;

        BOMComponent.SetRange("Parent Item No.", Item."No.");
        BOMComponent.SetRange(Type, BOMComponent.Type::Item);
        if BOMComponent.FindSet then
            repeat
                AllergenSetID := RollupItem(BOMComponent."No.");
                AddAllergentSetToMergeList(AllergenSetID, AllergenSetsToMerge);
            until BOMComponent.Next = 0;

        ProductionBOMHeader.SetRange("Output Item No.", Item."No.");
        if ProductionBOMHeader.FindSet then
            repeat
                AllergenSetID := RollupBOM(ProductionBOMHeader."No.");
                AddAllergentSetToMergeList(AllergenSetID, AllergenSetsToMerge);
            until ProductionBOMHeader.Next = 0;

        FamilyLine.SetRange("Process Family", true);
        FamilyLine.SetRange("Item No.", Item."No.");
        if FamilyLine.FindSet then
            repeat
                AllergenSetID := RollupBOM(FamilyLine."Family No.");
                AddAllergentSetToMergeList(AllergenSetID, AllergenSetsToMerge);
            until FamilyLine.Next = 0;

        ItemVariant.SetRange("Item No.", Item."No.");
        ItemVariant.SetFilter("Production BOM No.", '<>%1', '');
        if ItemVariant.FindSet then
            repeat
                AllergenSetID := RollupBOM(ItemVariant."Production BOM No.");
                AddAllergentSetToMergeList(AllergenSetID, AllergenSetsToMerge);
            until ItemVariant.Next = 0;

        AllergenRollup2."Allergen Set ID" := AllergenManagement.MergeAllergenSets(AllergenSetsToMerge);
        AllergenRollup2.Status := AllergenRollup2.Status::Indirect;
        AllergenRollup := AllergenRollup2;
        AllergenRollup.Modify;

        exit(AllergenRollup."Allergen Set ID");
    end;

    local procedure RollupUnapprovedItem(UnapprovedItemNo: Code[20]): Integer
    var
        UnapprovedItem: Record "Unapproved Item";
    begin
        if AllergenRollup.Get(AllergenRollup.Type::Unapproved, UnapprovedItemNo, '') then begin
            case AllergenRollup.Status of
                AllergenRollup.Status::Processing:
                    Error(Text001, UnapprovedItem.TableCaption, UnapprovedItemNo);
                AllergenRollup.Status::Direct, AllergenRollup.Status::Indirect:
                    exit(AllergenRollup."Allergen Set ID");
            end;
        end else begin
            UnapprovedItem.Get(UnapprovedItemNo);
            AllergenRollup.Type := AllergenRollup.Type::Unapproved;
            AllergenRollup."No." := UnapprovedItem."No.";
            AllergenRollup."Version Code" := '';
            AllergenRollup.Status := AllergenRollup.Status::Direct;
            AllergenRollup."Allergen Set ID" := UnapprovedItem."Allergen Set ID";
            AllergenRollup.Insert;

            if GatherDetail and (UnapprovedItem."Allergen Set ID" <> 0) then
                AddAllergenSetToDetail(UnapprovedItem."Allergen Set ID", AllergenDetail."Source Type"::"Unapproved Item", UnapprovedItem."No.", '');

            exit(AllergenRollup."Allergen Set ID");
        end;
    end;

    local procedure RollupVariable(VariableCode: Code[10]): Integer
    var
        PackageVariable: Record "Package Variable";
        ItemVariantVariable: Record "Item Variant Variable";
        AllergenRollup2: Record "Allergen Rollup";
        AllergenSetsToMerge: Record "Integer" temporary;
        AllergenSetID: Integer;
    begin
        if AllergenRollup.Get(AllergenRollup.Type::Variable, VariableCode, '') then begin
            case AllergenRollup.Status of
                AllergenRollup.Status::Processing:
                    Error(Text001, PackageVariable.TableCaption, VariableCode);
                AllergenRollup.Status::Indirect:
                    exit(AllergenRollup."Allergen Set ID");
            end;
        end else begin
            AllergenRollup2.Type := AllergenRollup2.Type::Variable;
            AllergenRollup2."No." := VariableCode;
            AllergenRollup2.Status := AllergenRollup2.Status::Processing;
            AllergenRollup := AllergenRollup2;
            AllergenRollup.Insert;
        end;

        ItemVariantVariable.SetRange("Package Variable Code", VariableCode);
        if ItemVariantVariable.FindSet then
            repeat
                AllergenSetID := RollupItem(ItemVariantVariable."Variable Item No.");
                AddAllergentSetToMergeList(AllergenSetID, AllergenSetsToMerge);
            until ItemVariantVariable.Next = 0;

        AllergenRollup2."Allergen Set ID" := AllergenManagement.MergeAllergenSets(AllergenSetsToMerge);
        AllergenRollup2.Status := AllergenRollup2.Status::Indirect;
        AllergenRollup := AllergenRollup2;
        AllergenRollup.Modify;

        exit(AllergenRollup."Allergen Set ID");
    end;

    local procedure AddAllergentSetToMergeList(AllergenSetID: Integer; var AllergenSetsToMerge: Record "Integer" temporary)
    begin
        if AllergenSetID <> 0 then
            if not AllergenSetsToMerge.Get(AllergenSetID) then begin
                AllergenSetsToMerge.Number := AllergenSetID;
                AllergenSetsToMerge.Insert;
            end;
    end;

    local procedure UpdateMasterTables()
    var
        Item: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMVersion: Record "Production BOM Version";
    begin
        Item.SetFilter("Indirect Allergen Set ID", '<>0');
        Item.ModifyAll("Indirect Allergen Set ID", 0, false);
        ProductionBOMHeader.SetFilter("Allergen Set ID", '<>0');
        ProductionBOMHeader.ModifyAll("Allergen Set ID", 0, false);
        ProductionBOMVersion.SetFilter("Indirect Allergen Set ID", '<>0');
        ProductionBOMVersion.ModifyAll("Indirect Allergen Set ID", 0, false);

        AllergenRollup.SetFilter(Type, '%1|%2', AllergenRollup.Type::Item, AllergenRollup.Type::BOM);
        AllergenRollup.SetRange(Status, AllergenRollup.Status::Indirect);
        AllergenRollup.SetFilter("Allergen Set ID", '>0');
        if AllergenRollup.FindSet then
            repeat
                case AllergenRollup.Type of
                    AllergenRollup.Type::Item:
                        begin
                            UpdateWindow(2, AllergenRollup."No.");
                            Item.Get(AllergenRollup."No.");
                            Item."Indirect Allergen Set ID" := AllergenRollup."Allergen Set ID";
                            Item.Modify;
                        end;
                    AllergenRollup.Type::BOM:
                        if AllergenRollup."Version Code" = '' then begin
                            UpdateWindow(3, AllergenRollup."No.");
                            ProductionBOMHeader.Get(AllergenRollup."No.");
                            ProductionBOMHeader."Allergen Set ID" := AllergenRollup."Allergen Set ID";
                            ProductionBOMHeader.Modify;
                        end else begin
                            ProductionBOMVersion.Get(AllergenRollup."No.", AllergenRollup."Version Code");
                            ProductionBOMVersion."Indirect Allergen Set ID" := AllergenRollup."Allergen Set ID";
                            ProductionBOMVersion.Modify;
                        end;
                end;
            until AllergenRollup.Next = 0;
    end;

    procedure GetAllergenDetail(MasterRec: Variant; var Detail: Record "Allergen Detail" temporary)
    var
        MasterRecRef: RecordRef;
        Item: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMVersion: Record "Production BOM Version";
        Allergen: Record Allergen;
    begin
        AllergenDetail.Reset;
        AllergenDetail.DeleteAll;
        GatherDetail := true;

        MasterRecRef.GetTable(MasterRec);
        case MasterRecRef.Number of
            DATABASE::Item:
                begin
                    Item := MasterRec;
                    RollupItem(Item);
                end;
            DATABASE::"Production BOM Header":
                begin
                    ProductionBOMHeader := MasterRec;
                    RollupBOM(ProductionBOMHeader."No.");
                end;
            DATABASE::"Production BOM Version":
                begin
                    ProductionBOMVersion := MasterRec;
                    RollupBOMVersion(ProductionBOMVersion."Production BOM No.", ProductionBOMVersion."Version Code");
                end;
        end;

        Detail.Reset;
        Detail.DeleteAll;
        if AllergenDetail.FindSet then
            repeat
                Detail := AllergenDetail;
                if Detail."Allergen Code" <> Allergen.Code then begin
                    Allergen.Get(Detail."Allergen Code");
                    Detail."Allergen Description" := Allergen.Description;
                    Detail.First := true;
                end;
                Detail.Insert;
            until AllergenDetail.Next = 0;
        if Detail.FindFirst then;
    end;

    local procedure AddAllergenSetToDetail(AllergenSetID: Integer; SourceType: Integer; SourceNo: Code[20]; VersionCode: Code[20])
    var
        AllergenSetEntry: Record "Allergen Set Entry";
    begin
        AllergenSetEntry.SetRange("Allergen Set ID", AllergenSetID);
        if AllergenSetEntry.FindSet then
            repeat
                AllergenDetail."Allergen Code" := AllergenSetEntry."Allergen Code";
                AllergenDetail."Source Type" := SourceType;
                AllergenDetail."Source No." := SourceNo;
                AllergenDetail."Version Code" := VersionCode;
                AllergenDetail.Presence := AllergenSetEntry.Presence;
                AllergenDetail.Insert;
            until AllergenSetEntry.Next = 0;
    end;

    local procedure OpenWindow(var Item: Record Item; var ProductionBOMHeader: Record "Production BOM Header")
    begin
        if GuiAllowed then begin
            TotalRecords := Item.Count + ProductionBOMHeader.Count;
            if TotalRecords <> 0 then
                Window.Open(Text003);
        end;
    end;

    local procedure UpdateWindow(Segment: Integer; Value: Variant)
    var
        Cnt: Integer;
    begin
        if GuiAllowed and (TotalRecords <> 0) then
            case Segment of
                1:
                    begin
                        Cnt := Value;
                        Window.Update(1, Round(9999 * Cnt / TotalRecords, 1));
                    end;
                2:
                    Window.Update(2, Value);
                3:
                    Window.Update(3, Value);
            end;
    end;

    local procedure CloseWindow()
    begin
        if GuiAllowed and (TotalRecords <> 0) then
            Window.Close;
    end;
}

