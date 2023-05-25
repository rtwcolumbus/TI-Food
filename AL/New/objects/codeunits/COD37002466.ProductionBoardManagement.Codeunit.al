codeunit 37002466 "Production Board Management"
{
    // PR4.00
    // P8000197A, Myers Nissi, Jack Reynolds, 22 SEP 05
    //   Utility functions for produciton board not included in sales board or equipment board management codeunits
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 08 MAR 16
    //   Expand BOM Version code to Code20


    trigger OnRun()
    begin
    end;

    var
        VersionMgt: Codeunit VersionManagement;

    procedure GetRequiredItems(ItemNo: Code[20]; QtyRequired: Decimal; DateRequired: Date; var RequiredItem: Record "Where-Used Line" temporary)
    var
        Item: Record Item;
        LastEntry: Integer;
        EntryNo: Integer;
    begin
        RequiredItem.Reset;
        RequiredItem.DeleteAll;

        // Seed the required item table with the original item
        RequiredItem."Item No." := ItemNo;
        RequiredItem."Quantity Needed" := QtyRequired;
        RequiredItem.Insert;

        // For each entry in the required item table we examine it's requirements and add additional
        // required items as necessary.  LastEntry keeps track of which entries in the required item
        // table have been examined
        while RequiredItem.Get(LastEntry) do begin
            Item.Get(RequiredItem."Item No.");
            if Item."Production BOM No." <> '' then begin
                RequiredItem."Production BOM No." := Item."Production BOM No.";
                RequiredItem."Version Code" := VersionMgt.GetBOMVersion(RequiredItem."Production BOM No.", Today, true);
                RequiredItem.Modify;
                AddBOMToRequiredItems(RequiredItem."Item No.",
                  RequiredItem."Production BOM No.", RequiredItem."Version Code",
                  RequiredItem."Level Code" + 1, RequiredItem."Quantity Needed", DateRequired,
                  RequiredItem, EntryNo);
            end;
            LastEntry += 1;
        end;
    end;

    procedure AddBOMToRequiredItems(ItemNo: Code[20]; BOMNo: Code[20]; VersionCode: Code[20]; Level: Integer; QtyRequired: Decimal; DateRequired: Date; var RequiredItem: Record "Where-Used Line" temporary; var EntryNo: Integer)
    var
        ProdBOMHeader: Record "Production BOM Header";
        ProdBOMLine: Record "Production BOM Line";
        ItemUOM: Record "Item Unit of Measure";
        BOMVars: Record "BOM Variables";
        UOM: Code[10];
        BOMQty: Decimal;
        LineQty: Decimal;
    begin
        ProdBOMLine.SetRange("Production BOM No.", BOMNo);
        ProdBOMLine.SetRange("Version Code", VersionCode);
        ProdBOMLine.SetFilter("Starting Date", '%1|..%2', 0D, DateRequired);
        ProdBOMLine.SetFilter("Ending Date", '%1|%2..', 0D, DateRequired);
        ProdBOMLine.SetFilter("No.", '<>%1', '');
        if QtyRequired <> 0 then
            if ItemNo <> '' then begin // Produced Item
                UOM := VersionMgt.GetBOMUnitOfMeasure(BOMNo, VersionCode);
                ItemUOM.Get(ItemNo, UOM);
                BOMQty := QtyRequired / ItemUOM."Qty. per Unit of Measure";
            end else                   // Phantom
                BOMQty := QtyRequired;
        if ProdBOMLine.Find('-') then begin
            repeat
                LineQty := BOMQty * ProdBOMLine.Quantity * (1 + ProdBOMLine."Scrap %" / 100);
                case ProdBOMLine.Type of
                    ProdBOMLine.Type::Item:
                        begin
                            RequiredItem.SetRange("Item No.", ProdBOMLine."No.");
                            RequiredItem.SetRange("Level Code", Level);
                            if not RequiredItem.Find('-') then begin
                                EntryNo += 1;
                                RequiredItem.Init;
                                RequiredItem."Entry No." := EntryNo;
                                RequiredItem."Item No." := ProdBOMLine."No.";
                                RequiredItem."Level Code" := Level;
                                RequiredItem.Insert;
                            end;
                            if LineQty <> 0 then begin
                                ItemUOM.Get(ProdBOMLine."No.", ProdBOMLine."Unit of Measure Code");
                                LineQty := LineQty * ItemUOM."Qty. per Unit of Measure";
                                RequiredItem."Quantity Needed" += LineQty;
                                RequiredItem.Modify;
                            end;
                        end;
                    ProdBOMLine.Type::"Production BOM":
                        begin
                            if LineQty <> 0 then begin
                                ProdBOMHeader.Get(ProdBOMLine."No.");
                                if ProdBOMHeader."Mfg. BOM Type" <> ProdBOMHeader."Mfg. BOM Type"::BOM then begin
                                    BOMVars.Type := ProdBOMHeader."Mfg. BOM Type";
                                    BOMVars."No." := ProdBOMLine."No.";
                                    BOMVars."Version Code" := VersionMgt.GetBOMVersion(ProdBOMLine."No.", DateRequired, true);
                                    BOMVars.InitRecord;
                                    if ProdBOMLine."Unit of Measure Code" <> BOMVars."Unit of Measure Code" then
                                        if ProdBOMLine."Unit of Measure Code" = BOMVars."Weight UOM" then
                                            LineQty := LineQty / BOMVars.Density
                                        else
                                            LineQty := LineQty * BOMVars.Density;
                                end;
                            end;
                            AddBOMToRequiredItems('',
                              ProdBOMLine."No.", VersionMgt.GetBOMVersion(ProdBOMLine."No.", Today, true),
                              Level, LineQty, DateRequired, RequiredItem, EntryNo);
                        end;
                end;
            until ProdBOMLine.Next = 0;
        end;
    end;
}

