codeunit 37002811 "Event Subscribers (Maint)"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW113.00.03
    // P80084737, To Increase, Jack Reynolds, 10 OCT 19
    //   Modify subscriptions for RunTrigger
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 26 APR 22
    //   Upgrade to 20.0 - Update PM Order degfault dimensions from Asset
    //   Fix Source Code initialization for Maintenance Material Journal

    trigger OnRun()
    begin
    end;

    var
        CannotDelete_Asset: Label 'You cannot delete %1 %2 because there are one or more assets for this %1.';
        CannotDelete_AssetSpare: Label 'You cannot delete %1 %2 because there are one or more asset spare parts for this %1.';

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnBeforeDeleteEvent', '', true, false)]
    local procedure Location_OnBeforeDelete(var Rec: Record Location; RunTrigger: Boolean)
    var
        Asset: Record Asset;
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        Asset.SetRange("Location Code", Rec.Code);
        if not Asset.IsEmpty then
            Error(CannotDelete_Asset, Rec.TableCaption, Rec.Code);
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterDeleteEvent', '', true, false)]
    local procedure Vendor_OnAfterDelete(var Rec: Record Vendor; RunTrigger: Boolean)
    var
        VendorTrade: Record "Vendor / Maintenance Trade";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        VendorTrade.Reset;
        VendorTrade.SetRange("Vendor No.", Rec."No.");
        VendorTrade.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeDeleteEvent', '', true, false)]
    local procedure Item_OnBeforeDelete(var Rec: Record Item; RunTrigger: Boolean)
    var
        AssetSparePart: Record "Asset Spare Part";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        AssetSparePart.SetRange(Type, AssetSparePart.Type::Stock);
        AssetSparePart.SetRange("Item No.", Rec."No.");
        if not AssetSparePart.IsEmpty then
            Error(CannotDelete_AssetSpare, Rec.TableCaption, Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeModifyEvent', '', true, false)]
    local procedure Item_OnBeforeModify(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        Item: Record Item;
    begin
        // P80066030
        if Rec.IsTemporary then
            exit;

        Item.Get(Rec."No.");
        Rec."Old Unit Cost" := Item."Unit Cost";
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterModifyEvent', '', true, false)]
    local procedure Item_OnAfterModify(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        MaintenanceManagement: Codeunit "Maintenance Management";
    begin
        // P80066030
        if Rec.IsTemporary then
            exit;

        if Rec."Old Unit Cost" <> Rec."Unit Cost" then
            MaintenanceManagement.UpdatePMMtlUnitCost(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'No.', true, false)]
    local procedure PurchaseLine_OnAfterValidate_No(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        MaintenancePurchaseMgmt: Codeunit "Maintenance Purchase Mgmt.";
    begin
        // P80066030
        MaintenancePurchaseMgmt.PurchLineValidate(Rec.FieldNo("No."), xRec, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Quantity', true, false)]
    local procedure PurchaseLine_OnAfterValidate_Quantity(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        MaintenancePurchaseMgmt: Codeunit "Maintenance Purchase Mgmt.";
    begin
        // P80066030
        MaintenancePurchaseMgmt.PurchLineValidate(Rec.FieldNo(Quantity), xRec, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Unit of Measure Code', true, false)]
    local procedure PurchaseLine_OnAfterValidate_UnitOfMeasureCode(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        MaintenancePurchaseMgmt: Codeunit "Maintenance Purchase Mgmt.";
    begin
        // P80066030
        MaintenancePurchaseMgmt.PurchLineValidate(Rec.FieldNo("Unit of Measure Code"), xRec, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnValidateNoOnCopyFromTempPurchLine', '', true, false)]
    local procedure PurchaseLine_OnValidateNoOnCopyFromTempPurchLine(var PurchLine: Record "Purchase Line"; TempPurchaseLine: Record "Purchase Line" temporary)
    begin
        // P80053245
        // P8000335A
        PurchLine."Work Order No." := TempPurchaseLine."Work Order No.";
        PurchLine."Maintenance Entry Type" := TempPurchaseLine."Maintenance Entry Type";
    end;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeDeleteEvent', '', true, false)]
    local procedure Resource_OnBeforeDelete(var Rec: Record Resource; RunTrigger: Boolean)
    var
        Asset: Record Asset;
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        Asset.SetRange("Resource No.", Rec."No.");
        if not Asset.IsEmpty then
            Error(CannotDelete_Asset, Rec.TableCaption, Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterUpdateGlobalDimCode', '', true, false)]
    local procedure DefaultDimension_OnAfterUpdateGlobalDimCode(GlobalDimCodeNo: Integer; TableID: Integer; AccNo: Code[20]; NewDimValue: Code[20])
    var
        MaintenanceManagement: Codeunit "Maintenance Management";
    begin
        // P80053245
        case TableID of
            // P8001133
            DATABASE::Asset:
                MaintenanceManagement.UpdateAssetGLobalDimCode(GlobalDimCodeNo, AccNo, NewDimValue);
            DATABASE::"Preventive Maintenance Order":
                MaintenanceManagement.UpdatePMGLobalDimCode(GlobalDimCodeNo, AccNo, NewDimValue);
        // P8001133
        end;
    end;

    // P800144605
    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnBeforeInsertEvent', '', true, false)]
    local procedure DefaultDimension_OnBeforeInsert(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        xRec: Record "Default Dimension";
    begin
        if Rec.IsTemporary() or (Rec."Table ID" <> Database::Asset) then
            exit;
        xRec := Rec;
        xRec."Dimension Value Code" := '';
        UpdatePMDefaultDimFromAsset(Rec, xRec);
    end;

    // P800144605
    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnBeforeModifyEvent', '', true, false)]
    local procedure DefaultDimension_OnBeforeModify(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or (Rec."Table ID" <> Database::Asset) then
            exit;
        xRec.Find();
        UpdatePMDefaultDimFromAsset(Rec, xRec);
    end;

    // P800144605
    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnBeforeDeleteEvent', '', true, false)]
    local procedure DefaultDimension_OnBeforeDelete(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    var
        xRec: Record "Default Dimension";
    begin
        if Rec.IsTemporary() or (Rec."Table ID" <> Database::Asset) then
            exit;
        xRec := Rec;
        Rec."Dimension Value Code" := '';
        UpdatePMDefaultDimFromAsset(Rec, xRec);
    end;

    // P800144605
    local procedure UpdatePMDefaultDimFromAsset(Rec: Record "Default Dimension"; xRec: Record "Default Dimension")
    var
        PMOrder: Record "Preventive Maintenance Order";
        DefaultDimension: Record "Default Dimension";
    begin
        PMOrder.SetRange("Asset No.", Rec."No.");
        if PMOrder.FindSet() then
            repeat
                if DefaultDimension.Get(Database::"Preventive Maintenance Order", PMOrder."Entry No.", Rec."Dimension Code") then begin
                    if DefaultDimension."Dimension Value Code" = xRec."Dimension Value Code" then begin
                        if Rec."Dimension Value Code" = '' then
                            DefaultDimension.Delete()
                        else begin
                            DefaultDimension := Rec;
                            DefaultDimension."Table ID" := Database::"Preventive Maintenance Order";
                            DefaultDimension."No." := PMOrder."Entry No.";
                            DefaultDimension.Modify();
                        end; 
                    end;
                end else begin
                    if Rec."Dimension Value Code" <> '' then begin
                        DefaultDimension := Rec; 
                        DefaultDimension."Table ID" := Database::"Preventive Maintenance Order";
                        DefaultDimension."No." := PMOrder."Entry No.";
                        DefaultDimension.Insert();
                    end; 
                end;
            until PMOrder.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::Manufacturer, 'OnBeforeDeleteEvent', '', true, false)]
    local procedure Manufacturer_OnBeforeDelete(var Rec: Record Manufacturer; RunTrigger: Boolean)
    var
        AssetSparePart: Record "Asset Spare Part";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        AssetSparePart.SetRange("Manufacturer Code", Rec.Code);
        if not AssetSparePart.IsEmpty then
            Error(CannotDelete_AssetSpare, Rec.TableCaption, Rec.Code);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', true, false)]
    local procedure ItemJnlPostLine_OnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    begin
        // P8004516
        NewItemLedgEntry."Maint. Ledger Entry No." := ItemJournalLine."Maint. Ledger Entry No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterItemValuePosting', '', true, false)]
    local procedure ItemJnlPostLine_OnAfterItemValuePosting(var ValueEntry: Record "Value Entry"; var ItemJournalLine: Record "Item Journal Line"; var Item: Record Item)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        MaintenanceManagement: Codeunit "Maintenance Management";
    begin
        // P80066030
        ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.");
        if ItemLedgerEntry."Maint. Ledger Entry No." <> 0 then
            MaintenanceManagement.UpdateItemCost(ItemLedgerEntry."Maint. Ledger Entry No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeTestPurchLine', '', true, false)]
    local procedure PurchPost_OnBeforeTestPurchLine(var PurchaseLine: Record "Purchase Line"; var PurchaseHeader: Record "Purchase Header")
    var
        MaintenancePurchaseMgmt: Codeunit "Maintenance Purchase Mgmt.";
    begin
        // P80066030
        if PurchaseLine."Document Type" in [PurchaseLine."Document Type"::Order, PurchaseLine."Document Type"::Invoice] then
            if PurchaseLine."Work Order No." <> '' then
                MaintenancePurchaseMgmt.PurchPostCheckLine(PurchaseLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnAfterFillTableBuffer', '', true, false)]
    local procedure CalcGLAccWhereUsed_OnAfterFillTableBuffer(var TableBuffer: Record "Integer")
    begin
        // P80073095
        TableBuffer.Number := DATABASE::"Maintenance Setup";
        TableBuffer.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnShowExtensionPage', '', true, false)]
    local procedure CalcGLAccWhereUsed_OnShowExtensionPage(GLAccountWhereUsed: Record "G/L Account Where-Used")
    var
        MaintenanceSetup: Record "Maintenance Setup";
    begin
        // P80066030
        case GLAccountWhereUsed."Table ID" of
            DATABASE::"Maintenance Setup":
                begin
                    MaintenanceSetup.Get;
                    PAGE.Run(PAGE::"Maintenance Setup", MaintenanceSetup);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"User Management", 'OnAfterRenameRecord', '', true, false)]
    local procedure UserManagement_OnAfterRename(var RecRef: RecordRef; TableNo: Integer; NumberOfPrimaryKeyFields: Integer; UserName: Code[50]; Company: Text[30])
    var
        MyAsset: Record "My Asset";
    begin
        // P8007748
        if TableNo = DATABASE::"My Asset" then begin
            MyAsset.ChangeCompany(Company);
            RecRef.SetTable(MyAsset);
            MyAsset.Rename(UserName, MyAsset."Asset No.");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnAfterGetPageID', '', true, false)]
    local procedure PageManagement_OnAfterGetPageID(RecordRef: RecordRef; var PageID: Integer)
    var
        WorkOrder: Record "Work Order";
    begin
        // P8004516, P80066030
        case RecordRef.Number of
            DATABASE::"Work Order":
                begin
                    RecordRef.SetTable(WorkOrder);
                    if WorkOrder.Completed then
                        PageID := PAGE::"Completed Work Order"
                    else
                        PageID := PAGE::"Work Order";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process 800 Core Functions", 'OnInitializeP800', '', true, false)]
    local procedure Process800CoreFunctions_OnInitializeP800(CompName: Text[30]; var SourceCodeSetup: Record "Source Code Setup"; var SourceCode: Record "Source Code"; var ReportSelections: Record "Report Selections")
    var
        MaintSetup: Record "Maintenance Setup";
        WORKORDER: Label 'WORKORDER';
        MAINTLAB: Label 'MAINTLAB';
        MAINTMTL: Label 'MAINTMTL';
        MAINTCON: Label 'MAINTCON';
        MAINTJNL: Label 'MAINTJNL';
        Process800CoreFunctions: Codeunit "Process 800 Core Functions";
    begin
        // P80066030
        if CompName <> CompanyName then
            MaintSetup.ChangeCompany(CompName);
        if not MaintSetup.Find('-') then begin
            MaintSetup.Init;
            MaintSetup.Insert;
        end;

        Process800CoreFunctions.InsertSourceCode(SourceCode, SourceCodeSetup."Work Order", WORKORDER, Process800CoreFunctions.PageName(PAGE::"Work Order"));
        Process800CoreFunctions.InsertSourceCode(SourceCode, SourceCodeSetup."Maintenance Labor Journal", MAINTLAB, Process800CoreFunctions.PageName(PAGE::"Maintenance Labor Journal"));
        Process800CoreFunctions.InsertSourceCode(SourceCode, SourceCodeSetup."Maintenance Material Journal", MAINTMTL, Process800CoreFunctions.PageName(PAGE::"Maintenance Material Journal"));
        Process800CoreFunctions.InsertSourceCode(SourceCode, SourceCodeSetup."Maintenance Contract Journal", MAINTCON, Process800CoreFunctions.PageName(PAGE::"Maintenance Contract Journal"));
        Process800CoreFunctions.InsertSourceCode(SourceCode, SourceCodeSetup."Maintenance Journal", MAINTJNL, Process800CoreFunctions.PageName(PAGE::"Maintenance Journal"));

        Process800CoreFunctions.InsertRepSelection(ReportSelections, ReportSelections.Usage::FOODMWorkOrder, '1', REPORT::"Maintenance Work Order");
    end;
}

