codeunit 37002920 "Allergen Management"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 07 FEB 19
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00


    trigger OnRun()
    begin
    end;

    var
        Text001: Label '%1 %2 has allergens directly assigned.';
        Text002: Label '%1 %2 has allergens (%3) not present in the output.';
        Text003: Label 'and';

    procedure GetAllergenSetID(var AllergenSetEntry: Record "Allergen Set Entry" temporary): Integer
    var
        AllergenSetTreeNode: Record "Allergen Set Tree Node";
        AllergenSetEntry2: Record "Allergen Set Entry";
        Found: Boolean;
    begin
        AllergenSetEntry.SetFilter("Allergen Code", '<>%1', '');
        if not AllergenSetEntry.FindSet then
            exit(0);

        Found := true;

        repeat
            if Found then
                if not AllergenSetTreeNode.Get(AllergenSetTreeNode."Allergen Set ID", AllergenSetEntry."Allergen ID", AllergenSetEntry.Presence) then begin
                    Found := false;
                    AllergenSetTreeNode.LockTable;
                end;
            if not Found then begin
                AllergenSetTreeNode."Parent Allergen Set ID" := AllergenSetTreeNode."Allergen Set ID";
                AllergenSetTreeNode."Allergen ID" := AllergenSetEntry."Allergen ID";
                AllergenSetTreeNode.Presence := AllergenSetEntry.Presence;
                AllergenSetTreeNode."Allergen Set ID" := 0;
                AllergenSetTreeNode."In Use" := false;
                if not AllergenSetTreeNode.Insert then
                    AllergenSetTreeNode.Get(AllergenSetTreeNode."Parent Allergen Set ID", AllergenSetTreeNode."Allergen ID", AllergenSetTreeNode.Presence);
            end;
        until AllergenSetEntry.Next = 0;

        if not AllergenSetTreeNode."In Use" then begin
            if Found then begin
                AllergenSetTreeNode.LockTable;
                AllergenSetTreeNode.Get(AllergenSetTreeNode."Parent Allergen Set ID", AllergenSetTreeNode."Allergen ID", AllergenSetTreeNode.Presence);
            end;
            AllergenSetTreeNode."In Use" := true;
            AllergenSetTreeNode.Modify;

            if AllergenSetEntry.FindSet then
                repeat
                    AllergenSetEntry2 := AllergenSetEntry;
                    AllergenSetEntry2."Allergen Set ID" := AllergenSetTreeNode."Allergen Set ID";
                    AllergenSetEntry2.Insert;
                until AllergenSetEntry.Next = 0;
        end;

        exit(AllergenSetTreeNode."Allergen Set ID");
    end;

    procedure MergeAllergenSets(var AllergenSetsToMerge: Record "Integer" temporary) AllergenSetID: Integer
    var
        AllergenSetEntry: Record "Allergen Set Entry";
        MergedAllergenSet: Record "Allergen Set Entry" temporary;
    begin
        if not AllergenSetsToMerge.FindSet then
            exit(0);

        AllergenSetID := AllergenSetsToMerge.Number;
        if AllergenSetsToMerge.Next = 0 then
            exit;

        AllergenSetEntry.SetRange("Allergen Set ID", AllergenSetID);
        repeat
            MergedAllergenSet := AllergenSetEntry;
            MergedAllergenSet."Allergen Set ID" := 0;
            MergedAllergenSet.Insert;
        until AllergenSetEntry.Next = 0;

        repeat
            AllergenSetEntry.SetRange("Allergen Set ID", AllergenSetsToMerge.Number);
            if AllergenSetEntry.FindSet then
                repeat
                    if MergedAllergenSet.Get(0, AllergenSetEntry."Allergen Code") then begin
                        if MergedAllergenSet.Presence < AllergenSetEntry.Presence then begin
                            MergedAllergenSet.Presence := AllergenSetEntry.Presence;
                            MergedAllergenSet.Modify;
                        end;
                    end else begin
                        MergedAllergenSet := AllergenSetEntry;
                        MergedAllergenSet."Allergen Set ID" := 0;
                        MergedAllergenSet.Insert;
                    end;
                until AllergenSetEntry.Next = 0;
        until AllergenSetsToMerge.Next = 0;
        exit(GetAllergenSetID(MergedAllergenSet));
    end;

    procedure AllergenSetIsSubset(AllergenSet1: Integer; AllergenSet2: Integer; var Allergen: Record Allergen) Subset: Boolean
    var
        AllergenSetEntry1: Record "Allergen Set Entry";
        AllergenSetEntry2: Record "Allergen Set Entry";
    begin
        // Returns TRUE if AllergenSet1 is a subset of AllergenSet2
        Subset := true;
        Allergen.Reset;

        if AllergenSet1 = 0 then // Empty set is a subset of all sets
            exit;
        ;

        AllergenSetEntry1.SetRange("Allergen Set ID", AllergenSet1);
        if AllergenSetEntry1.FindSet then
            repeat
                if not AllergenSetEntry2.Get(AllergenSet2, AllergenSetEntry1."Allergen Code") then begin
                    Subset := false;
                    Allergen.Get(AllergenSetEntry1."Allergen Code");
                    Allergen.Mark(true);
                end;
            until AllergenSetEntry1.Next = 0;
        exit;
    end;

    local procedure ListAllergens(var Allergen: Record Allergen) AllergenList: Text
    var
        NextAllergen: Code[10];
    begin
        if Allergen.FindSet then
            repeat
                if NextAllergen <> '' then begin
                    if AllergenList <> '' then
                        AllergenList := AllergenList + ', ';
                    AllergenList := AllergenList + NextAllergen;
                end;
                NextAllergen := Allergen.Code;
            until Allergen.Next = 0;

        case Allergen.Count of
            0:
                exit;
            1:
                exit(NextAllergen);
            2:
                exit(StrSubstNo('%1 %2 %3', AllergenList, Text003, NextAllergen));
            else
                exit(StrSubstNo('%1, %2 %3', AllergenList, Text003, NextAllergen));
        end;
    end;

    procedure ShowAllergenSet(MasterRec: Variant): Integer
    var
        AllergenSetEntries: Page "Allergen Set Entries";
    begin
        AllergenSetEntries.SetSource(MasterRec);
        AllergenSetEntries.RunModal;
        exit(AllergenSetEntries.GetAllergenSet);
    end;

    procedure ShowAllergenDetail(MasterRec: Variant)
    var
        AllergenDetail: Page "Allergen Detail";
    begin
        AllergenDetail.SetSource(MasterRec);
        AllergenDetail.RunModal;
    end;

    procedure GetAllergenPresence(AllergenCode: Code[10]; var AllergenPresence: Record "Allergen Presence" temporary)
    var
        AllergenPresenceItemDirect: Query "Allergen Presence-Item-Direct";
        AllergenPresenceItemIndirect: Query "Allergen Presence-Item-Ind.";
        AllergenPresenceUnapproved: Query "Allergen Presence-Unapproved";
        AllergenPresenceBOM: Query "Allergen Presence-BOM";
    begin
        AllergenPresence.Reset;
        AllergenPresence.DeleteAll;

        AllergenPresenceItemDirect.SetRange(Code, AllergenCode);
        if AllergenPresenceItemDirect.Open then
            while AllergenPresenceItemDirect.Read do begin
                AllergenPresence.Type := AllergenPresence.Type::Items;
                AllergenPresence."No." := AllergenPresenceItemDirect.No;
                AllergenPresence.Description := AllergenPresenceItemDirect.Description;
                AllergenPresence.Presence := AllergenPresenceItemDirect.Presence;
                AllergenPresence.Direct := true;
                AllergenPresence.Insert;
            end;

        AllergenPresenceItemIndirect.SetRange(Code, AllergenCode);
        if AllergenPresenceItemIndirect.Open then
            while AllergenPresenceItemIndirect.Read do begin
                AllergenPresence.Type := AllergenPresence.Type::Items;
                AllergenPresence."No." := AllergenPresenceItemIndirect.No;
                AllergenPresence.Description := AllergenPresenceItemIndirect.Description;
                AllergenPresence.Presence := AllergenPresenceItemIndirect.Presence;
                AllergenPresence.Direct := false;
                AllergenPresence.Insert;
            end;

        AllergenPresenceUnapproved.SetRange(Code, AllergenCode);
        if AllergenPresenceUnapproved.Open then
            while AllergenPresenceUnapproved.Read do begin
                AllergenPresence.Type := AllergenPresence.Type::"Unapproved Items";
                AllergenPresence."No." := AllergenPresenceUnapproved.No;
                AllergenPresence.Description := AllergenPresenceUnapproved.Description;
                AllergenPresence.Presence := AllergenPresenceUnapproved.Presence;
                AllergenPresence.Direct := false;
                AllergenPresence.Insert;
            end;

        AllergenPresenceBOM.SetRange(Code, AllergenCode);
        if AllergenPresenceBOM.Open then
            while AllergenPresenceBOM.Read do begin
                AllergenPresence.Type := AllergenPresence.Type::BOMs;
                AllergenPresence."No." := AllergenPresenceBOM.No;
                AllergenPresence.Description := AllergenPresenceBOM.Description;
                AllergenPresence.Presence := AllergenPresenceBOM.Presence;
                AllergenPresence.Direct := false;
                AllergenPresence.Insert;
            end;

        if AllergenPresence.FindFirst then;
    end;

    procedure CheckAllergenAssigned(ItemNo: Code[20])
    var
        Item: Record Item;
    begin
        if Item.Get(ItemNo) then
            if Item."Direct Allergen Set ID" <> 0 then
                Error(Text001, Item.TableCaption, Item."No.");
    end;

    procedure IsProducedItem(Item: Record Item): Boolean
    var
        ProductionBOMHeader: Record "Production BOM Header";
        BOMComponent: Record "BOM Component";
        FamilyLine: Record "Family Line";
        ItemVariant: Record "Item Variant";
    begin
        if Item."Production BOM No." <> '' then
            exit(true);

        ProductionBOMHeader.SetRange("Output Item No.", Item."No.");
        if not ProductionBOMHeader.IsEmpty then
            exit(true);

        BOMComponent.SetRange("Parent Item No.", Item."No.");
        if not BOMComponent.IsEmpty then
            exit(true);

        FamilyLine.SetRange("Process Family", true);
        FamilyLine.SetRange("Item No.", Item."No.");
        if not FamilyLine.IsEmpty then
            exit(true);

        ItemVariant.SetRange("Item No.", Item."No.");
        ItemVariant.SetFilter("Production BOM No.", '<>%1', '');
        if not ItemVariant.IsEmpty then
            exit(true);
    end;

    procedure AllergenCodeForRecord(TableID: Integer; Type: Integer; No: Code[20]): Code[10]
    var
        AllergenSetEntry: Record "Allergen Set Entry";
        Process800SystemGlobals: Codeunit "Process 800 System Globals";
        AllergenSetID: Integer;
    begin
        AllergenSetID := TableTypeNo2AllergentSetID(TableID, Type, No);
        if AllergenSetID = 0 then
            exit;

        AllergenSetEntry.SetRange("Allergen Set ID", AllergenSetID);
        if AllergenSetEntry.FindSet then begin
            if AllergenSetEntry.Next = 0 then
                exit(AllergenSetEntry."Allergen Code")
            else
                exit(Process800SystemGlobals.MultipleLotCode);
        end;
    end;

    procedure AllergenDrilldownForRecord(TableID: Integer; Type: Integer; No: Code[20])
    var
        AllergenSetEntry: Record "Allergen Set Entry";
        AllergensForItem: Page "Allergens For Item";
        AllergenSetID: Integer;
    begin
        AllergenSetID := TableTypeNo2AllergentSetID(TableID, Type, No);
        if AllergenSetID = 0 then
            exit;

        AllergenSetEntry.FilterGroup(2);
        AllergenSetEntry.SetRange("Allergen Set ID", AllergenSetID);
        AllergenSetEntry.FilterGroup(0);
        AllergensForItem.SetTableView(AllergenSetEntry);
        AllergensForItem.RunModal;
    end;

    procedure TableTypeNo2AllergentSetID(TableID: Integer; Type: Integer; No: Code[20]): Integer
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
        BOMComponent: Record "BOM Component";
        RequisitionLine: Record "Requisition Line";
        AssemblyLine: Record "Assembly Line";
        ItemSubstitution: Record "Item Substitution";
        TransferLine: Record "Transfer Line";
        RepackOrderLine: Record "Repack Order Line";
        ProductionBOMLine: Record "Production BOM Line";
        BatchPlanningOrderDetail: Record "Batch Planning Order Detail";
        TableRelationsMetadata: Record "Table Relations Metadata";
        Item: Record Item;
        ProductionBOMHeader: Record "Production BOM Header";
        UnapprovedItem: Record "Unapproved Item";
        ProdBOMNo: Code[20];
        RecordType: Integer;
    begin
        if No = '' then
            exit;

        if (TableID = 0) or (Type = 0) then
            RecordType := DATABASE::Item
        else
            case TableID of
                DATABASE::"Sales Line",
              DATABASE::"Sales Shipment Line",
              DATABASE::"Sales Invoice Line",
              DATABASE::"Sales Cr.Memo Line",
              DATABASE::"Sales Line Archive",
              DATABASE::"Return Receipt Line":
                    if Type = SalesLine.Type::Item then
                        RecordType := DATABASE::Item;

                DATABASE::"Purchase Line",
              DATABASE::"Purch. Rcpt. Line",
              DATABASE::"Purch. Inv. Line",
              DATABASE::"Purch. Cr. Memo Line",
              DATABASE::"Purchase Line Archive",
              DATABASE::"Return Shipment Line":
                    if Type = PurchaseLine.Type::Item then
                        RecordType := DATABASE::Item;

                DATABASE::"BOM Component":
                    if Type = BOMComponent.Type::Item then
                        RecordType := DATABASE::Item;

                DATABASE::"Requisition Line":
                    if Type = RequisitionLine.Type::Item then
                        RecordType := DATABASE::Item;

                DATABASE::"Assembly Line",
              DATABASE::"Posted Assembly Line":
                    if Type = AssemblyLine.Type::Item then
                        RecordType := DATABASE::Item;

                DATABASE::"Item Substitution":
                    if Type = ItemSubstitution."Substitute Type"::Item then
                        RecordType := DATABASE::Item;

                DATABASE::"Transfer Line":
                    if Type = TransferLine.Type::Item then
                        RecordType := DATABASE::Item;

                DATABASE::"Repack Order Line":
                    if Type = RepackOrderLine.Type::Item then
                        RecordType := DATABASE::Item;

                DATABASE::"Batch Planning Order Detail":
                    if Type = BatchPlanningOrderDetail.Type::Order then
                        RecordType := DATABASE::Item;

                DATABASE::"Production Sequencing":
                    if Type = 1 then // Type is Level field (0 is equipment summary, 1 is order)
                        RecordType := DATABASE::Item;

                DATABASE::"Production BOM Line":
                    case Type of
                        ProductionBOMLine.Type::Item:
                            RecordType := DATABASE::Item;
                        ProductionBOMLine.Type::"Production BOM":
                            RecordType := DATABASE::"Production BOM Header";
                        ProductionBOMLine.Type::FOODUnapprovedItem:
                            RecordType := DATABASE::"Unapproved Item";
                    end;
            end;

        case RecordType of
            DATABASE::Item:
                if Item.Get(No) then
                    if Item."Direct Allergen Set ID" <> 0 then
                        exit(Item."Direct Allergen Set ID")
                    else
                        exit(Item."Indirect Allergen Set ID");
            DATABASE::"Production BOM Header":
                if ProductionBOMHeader.Get(No) then
                    exit(ProductionBOMHeader."Allergen Set ID");
            DATABASE::"Unapproved Item":
                if UnapprovedItem.Get(No) then
                    exit(UnapprovedItem."Allergen Set ID");
        end;
    end;

    procedure CheckConsumption(SourceRecord: Variant) WarningMsg: Text
    var
        InventorySetup: Record "Inventory Setup";
        Item: Record Item;
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComponent: Record "Prod. Order Component";
        ItemJournalLine: Record "Item Journal Line";
        RepackOrder: Record "Repack Order";
        RepackOrderLine: Record "Repack Order Line";
        AllergenNotPresent: Record Allergen;
        SourceRecRef: RecordRef;
        AllergenConsumptionWarning: Page "Allergen Consumption Warning";
        ConsItemNo: Code[20];
        ConsItemDesc: Text[100];
        ConsAllergentSetID: Integer;
        OutAllergenSetID: Integer;
    begin
        SourceRecRef.GetTable(SourceRecord);
        case SourceRecRef.Number of
            DATABASE::"Prod. Order Component":
                begin
                    ProdOrderComponent := SourceRecord;
                    ConsItemNo := ProdOrderComponent."Item No.";
                    if ConsItemNo = '' then
                        exit;
                    Item.Get(ConsItemNo);
                    ConsItemDesc := Item.Description;
                    ConsAllergentSetID := Item."Direct Allergen Set ID" + Item."Indirect Allergen Set ID";
                    if ConsAllergentSetID = 0 then
                        exit;
                    if ProdOrderComponent."Prod. Order Line No." <> 0 then begin
                        ProdOrderLine.Get(ProdOrderComponent.Status, ProdOrderComponent."Prod. Order No.", ProdOrderComponent."Prod. Order Line No.");
                        Item.Get(ProdOrderLine."Item No.");
                        OutAllergenSetID := Item."Direct Allergen Set ID" + Item."Indirect Allergen Set ID";
                    end else
                        OutAllergenSetID := CoByProductAllergeSetID(ProdOrderComponent.Status, ProdOrderComponent."Prod. Order No.");
                end;

            DATABASE::"Item Journal Line":
                begin
                    ItemJournalLine := SourceRecord;
                    ConsItemNo := ItemJournalLine."Item No.";
                    if ConsItemNo = '' then
                        exit;
                    Item.Get(ConsItemNo);
                    ConsItemDesc := Item.Description;
                    ConsAllergentSetID := Item."Direct Allergen Set ID" + Item."Indirect Allergen Set ID";
                    if ConsAllergentSetID = 0 then
                        exit;
                    if (ItemJournalLine."Order Type" = ItemJournalLine."Order Type"::Production) and (ItemJournalLine."Order No." <> '') then begin
                        if ItemJournalLine."Order Line No." <> 0 then begin
                            ProdOrderLine.Get(ProdOrderLine.Status::Released, ItemJournalLine."Order No.", ItemJournalLine."Order Line No.");
                            Item.Get(ProdOrderLine."Item No.");
                            OutAllergenSetID := Item."Direct Allergen Set ID" + Item."Indirect Allergen Set ID";
                        end else
                            OutAllergenSetID := CoByProductAllergeSetID(ProdOrderLine.Status::Released, ItemJournalLine."Order No.");
                    end else
                        exit;
                end;

            DATABASE::"Repack Order Line":
                begin
                    RepackOrderLine := SourceRecord;
                    ConsItemNo := RepackOrderLine."No.";
                    if ConsItemNo = '' then
                        exit;
                    Item.Get(ConsItemNo);
                    ConsItemDesc := Item.Description;
                    ConsAllergentSetID := Item."Direct Allergen Set ID" + Item."Indirect Allergen Set ID";
                    if ConsAllergentSetID = 0 then
                        exit;
                    RepackOrder.Get(RepackOrderLine."Order No.");
                    if RepackOrder."Item No." = '' then
                        exit
                    else begin
                        Item.Get(RepackOrder."Item No.");
                        OutAllergenSetID := Item."Direct Allergen Set ID" + Item."Indirect Allergen Set ID";
                    end;
                end;
        end;

        if AllergenSetIsSubset(ConsAllergentSetID, OutAllergenSetID, AllergenNotPresent) then
            exit;

        AllergenNotPresent.MarkedOnly(true);
        InventorySetup.Get;
        if InventorySetup."Allergen Cons. Enforcement Lvl" = InventorySetup."Allergen Cons. Enforcement Lvl"::Error then
            Error(Text002, Item.TableCaption, ConsItemNo, ListAllergens(AllergenNotPresent))
        else
            if not GuiAllowed then
                exit(StrSubstNo(Text002, Item.TableCaption, ConsItemNo, ListAllergens(AllergenNotPresent)))
            else begin
                AllergenConsumptionWarning.SetItem(ConsItemNo, ConsItemDesc);
                AllergenConsumptionWarning.SetTableView(AllergenNotPresent);
                if AllergenConsumptionWarning.RunModal <> ACTION::Yes then
                    Error('');
            end;
    end;

    local procedure CoByProductAllergeSetID(Status: Integer; ProdOrderNo: Code[20]): Integer
    var
        ProdOrderLine: Record "Prod. Order Line";
        Item: Record Item;
        AllergenSetsToMerge: Record "Integer" temporary;
        AllergenSetID: Integer;
    begin
        ProdOrderLine.SetRange(Status, Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProdOrderNo);
        if ProdOrderLine.FindSet then
            repeat
                Item.Get(ProdOrderLine."Item No.");
                AllergenSetID := Item."Direct Allergen Set ID" + Item."Indirect Allergen Set ID";
                if AllergenSetID <> 0 then
                    AllergenSetsToMerge.Number := AllergenSetID;
                if AllergenSetsToMerge.Insert then;
            until ProdOrderLine.Next = 0;
        exit(MergeAllergenSets(AllergenSetsToMerge));
    end;

    procedure LogHistory(Rec: Variant)
    var
        RecRef: RecordRef;
        Item: Record Item;
        UnapprovedItem: Record "Unapproved Item";
        xUnapprovedItem: Record "Unapproved Item";
        ProductionBOMVersion: Record "Production BOM Version";
        xProductionBOMVersion: Record "Production BOM Version";
    begin
        RecRef.GetTable(Rec);
        case RecRef.Number of
            DATABASE::Item:
                begin
                    Item := Rec;
                    if Item."Old Direct Allergen Set ID" <> Item."Direct Allergen Set ID" then                                     // P80066030
                        InsertHistory(DATABASE::Item, Item."No.", '', Item."Old Direct Allergen Set ID", Item."Direct Allergen Set ID"); // P80066030
                end;

            DATABASE::"Unapproved Item":
                begin
                    UnapprovedItem := Rec;
                    if UnapprovedItem."Old Allergen Set ID" <> UnapprovedItem."Allergen Set ID" then                                                            // P80066030
                        InsertHistory(DATABASE::"Unapproved Item", UnapprovedItem."No.", '', UnapprovedItem."Old Allergen Set ID", UnapprovedItem."Allergen Set ID"); // P80066030
                end;

            DATABASE::"Production BOM Version":
                begin
                    ProductionBOMVersion := Rec;
                    if ProductionBOMVersion."Old Direct Allergen Set ID" <> ProductionBOMVersion."Direct Allergen Set ID" then // P80066030
                        InsertHistory(DATABASE::"Production BOM Version", ProductionBOMVersion."Production BOM No.", ProductionBOMVersion."Version Code",
                          ProductionBOMVersion."Old Direct Allergen Set ID", ProductionBOMVersion."Direct Allergen Set ID");      // P80066030
                end;
        end;
    end;

    local procedure InsertHistory(TableNo: Integer; Code1: Code[20]; Code2: Code[20]; OldSet: Integer; NewSet: Integer)
    var
        AllergenSetHistory: Record "Allergen Set History";
    begin
        AllergenSetHistory."Table No." := TableNo;
        AllergenSetHistory."Code 1" := Code1;
        AllergenSetHistory."Code 2" := Code2;
        AllergenSetHistory."Date and Time" := CurrentDateTime;
        AllergenSetHistory."User ID" := UserId;
        AllergenSetHistory."Old Allergen Set ID" := OldSet;
        AllergenSetHistory."New Allergen Set ID" := NewSet;
        AllergenSetHistory.Insert;
    end;

    procedure RecordHasPendingAllergenSetChange(MasterRec: Variant; var PendingAllergenSetID: Integer): Boolean
    var
        MasterRecRef: RecordRef;
        Item: Record Item;
        UnapprovedItem: Record "Unapproved Item";
        ProductionBOMVersion: Record "Production BOM Version";
        WorkflowRecordChange: Record "Workflow - Record Change";
        FieldNo: Integer;
    begin
        MasterRecRef.GetTable(MasterRec);
        case MasterRecRef.Number of
            DATABASE::Item:
                FieldNo := Item.FieldNo("Direct Allergen Set ID");
            DATABASE::"Unapproved Item":
                FieldNo := UnapprovedItem.FieldNo("Allergen Set ID");
            DATABASE::"Production BOM Version":
                FieldNo := ProductionBOMVersion.FieldNo("Direct Allergen Set ID");
        end;

        WorkflowRecordChange.SetRange("Table No.", MasterRecRef.Number);
        WorkflowRecordChange.SetRange("Field No.", FieldNo);
        WorkflowRecordChange.SetRange("Record ID", MasterRecRef.RecordId);
        WorkflowRecordChange.SetRange(Inactive, false);

        if WorkflowRecordChange.FindFirst then begin
            Evaluate(PendingAllergenSetID, WorkflowRecordChange."New Value");
            exit(true);
        end else
            exit(false);
    end;
}

