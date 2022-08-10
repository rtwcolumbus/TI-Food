codeunit 37002874 "Event Subscribers (DC)"
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
    // P80082720, To Increase, Gangabhushan, 19 SEP 19
    //   CS00075736 - Unable to change status on production orders with routing


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnAfterDeleteEvent', '', true, false)]
    local procedure Location_OnAfterDelete(var Rec: Record Location; RunTrigger: Boolean)
    var
        DataCollectionManagement: Codeunit "Data Collection Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        DataCollectionManagement.DeleteDataCollectionLines(DATABASE::Location, Rec.Code, '');
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterDeleteEvent', '', true, false)]
    local procedure Customer_OnAfterDelete(var Rec: Record Customer; RunTrigger: Boolean)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        DataCollectionMgmt.DeleteDataCollectionLines(DATABASE::Customer, Rec."No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterDeleteEvent', '', true, false)]
    local procedure Vendor_OnAfterDelete(var Rec: Record Vendor; RunTrigger: Boolean)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        DataCollectionMgmt.DeleteDataCollectionLines(DATABASE::Vendor, Rec."No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterDeleteEvent', '', true, false)]
    local procedure Item_OnAfterDelete(var Rec: Record Item; RunTrigger: Boolean)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        DataCollectionMgmt.DeleteDataCollectionLines(DATABASE::Item, Rec."No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterDeleteEvent', '', true, false)]
    local procedure SalesHeader_OnAfterDelete(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        DataCollectionMgmt.DeleteDataSheet(DATABASE::"Sales Header", Rec."Document Type", Rec."No.");
        ;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeDeleteEvent', '', true, false)]
    local procedure SalesLine_OnBeforerDelete(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        SalesLine: Record "Sales Line";
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        DataCollectionMgmt.CheckSalesLineModify(Rec, SalesLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Type', true, false)]
    local procedure SalesLine_OnBeforeValidate_Type(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if Rec.Type <> xRec.Type then
            DataCollectionMgmt.CheckSalesLineModify(xRec, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnValidateNoOnBeforeInitRec', '', true, false)]
    local procedure SalesLine_OnValidateNoOnBeforeInitRec(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CallingFieldNo: Integer)
    var
        DataCollectionManagement: Codeunit "Data Collection Management";
    begin
        // P80066030
        DataCollectionManagement.CheckSalesLineModify(xSalesLine, SalesLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Location Code', true, false)]
    local procedure SalesLine_OnBeforeValidate_LocationCode(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if xRec."Location Code" <> Rec."Location Code" then
            DataCollectionMgmt.CheckSalesLineModify(xRec, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterDeleteEvent', '', true, false)]
    local procedure PurchaseHeader_OnAfterDelete(var Rec: Record "Purchase Header"; RunTrigger: Boolean)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P8001090
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        DataCollectionMgmt.DeleteDataSheet(DATABASE::"Purchase Header", Rec."Document Type", Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeDeleteEvent', '', true, false)]
    local procedure PurchaseLine_OnBeforeDelete(var Rec: Record "Purchase Line"; RunTrigger: Boolean)
    var
        PurchaseLine: Record "Purchase Line";
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if (Rec.Quantity <> 0) and Rec.ItemExists(Rec."No.") then
            DataCollectionMgmt.CheckPurchLineModify(Rec, PurchaseLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeValidateEvent', 'Type', true, false)]
    local procedure PurchaseLine_OnBeforeValidate_Type(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        DataCollectionMgmt.CheckPurchLineModify(xRec, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnValidateNoOnBeforeInitRec', '', true, false)]
    local procedure PurchaseLine_OnValidateNoOnBeforeInitRec(var PurchaseLine: Record "Purchase Line"; xPurchaseLine: Record "Purchase Line"; CallingFieldNo: Integer)
    var
        DataCollectionManagement: Codeunit "Data Collection Management";
    begin
        // P80066030
        DataCollectionManagement.CheckPurchLineModify(xPurchaseLine, PurchaseLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeValidateEvent', 'Location Code', true, false)]
    local procedure PurchaseLine_OnBeforeValidate_LocationCode(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if xRec."Location Code" <> Rec."Location Code" then
            DataCollectionMgmt.CheckPurchLineModify(xRec, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnAfterDeleteEvent', '', true, false)]
    local procedure Resource_OnAfterDelete(var Rec: Record Resource; RunTrigger: Boolean)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        DataCollectionMgmt.DeleteDataCollectionLines(DATABASE::Resource, Rec."No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Production Order", 'OnAfterDeleteEvent', '', true, false)]
    local procedure ProductionOrder_OnAfterDelete(var Rec: Record "Production Order"; RunTrigger: Boolean)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        if Rec.Status <> Rec.Status::Finished then
            DataCollectionMgmt.DeleteDataSheet(DATABASE::"Production Order", Rec.Status, Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Line", 'OnBeforeDeleteEvent', '', true, false)]
    local procedure ProdOrderLine_OnBeforeDelete(var Rec: Record "Prod. Order Line"; RunTrigger: Boolean)
    var
        ProdOrderLine: Record "Prod. Order Line";
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.Status <> Rec.Status::Released then
            DataCollectionMgmt.CheckProdOrderLineModify(Rec, ProdOrderLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Line", 'OnBeforeValidateEvent', 'Item No.', true, false)]
    local procedure ProdOrderLine_OnBeforeValidate_ItemNo(var Rec: Record "Prod. Order Line"; var xRec: Record "Prod. Order Line"; CurrFieldNo: Integer)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if Rec."Item No." <> xRec."Item No." then
            DataCollectionMgmt.CheckProdOrderLineModify(xRec, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Line", 'OnBeforeValidateEvent', 'Location Code', true, false)]
    local procedure ProdOrderLine_OnBeforeValidate_LocationCode(var Rec: Record "Prod. Order Line"; var xRec: Record "Prod. Order Line"; CurrFieldNo: Integer)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if Rec."Location Code" <> xRec."Location Code" then
            DataCollectionMgmt.CheckProdOrderLineModify(xRec, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Line", 'OnBeforeValidateEvent', 'Routing No.', true, false)]
    local procedure ProdOrderLine_OnBeforeValidate_RoutingNo(var Rec: Record "Prod. Order Line"; var xRec: Record "Prod. Order Line"; CurrFieldNo: Integer)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if Rec."Routing No." <> xRec."Routing No." then
            DataCollectionMgmt.CheckProdOrderLineModify(xRec, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Line", 'OnBeforeValidateEvent', 'Routing Version Code', true, false)]
    local procedure ProdOrderLine_OnBeforeValidate_RoutingVersionCode(var Rec: Record "Prod. Order Line"; var xRec: Record "Prod. Order Line"; CurrFieldNo: Integer)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if Rec."Routing Version Code" <> xRec."Routing Version Code" then
            DataCollectionMgmt.CheckProdOrderLineModify(xRec, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Routing Line", 'OnBeforeDeleteEvent', '', true, false)]
    local procedure ProdOrderRoutingLine_OnBeforeDelete(var Rec: Record "Prod. Order Routing Line"; RunTrigger: Boolean)
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if (Rec.Status = Rec.Status::Released) and RunTrigger then // P80082720
            DataCollectionMgmt.CheckRoutingLineModify(Rec, ProdOrderRoutingLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Routing Line", 'OnBeforeValidateEvent', 'Type', true, false)]
    local procedure ProdOrderRoutingLine_OnBeforeValidate_Type(var Rec: Record "Prod. Order Routing Line"; var xRec: Record "Prod. Order Routing Line"; CurrFieldNo: Integer)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if Rec.Type <> xRec.Type then
            DataCollectionMgmt.CheckRoutingLineModify(xRec, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Routing Line", 'OnBeforeValidateEvent', 'No.', true, false)]
    local procedure ProdOrderRoutingLine_OnBeforeValidate_No(var Rec: Record "Prod. Order Routing Line"; var xRec: Record "Prod. Order Routing Line"; CurrFieldNo: Integer)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if (Rec."No." <> xRec."No.") and (xRec."No." <> '') then
            DataCollectionMgmt.CheckRoutingLineModify(xRec, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Header", 'OnAfterDeleteEvent', '', true, false)]
    local procedure TransferHeader_OnAfterDelete(var Rec: Record "Transfer Header"; RunTrigger: Boolean)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        DataCollectionMgmt.DeleteDataSheet(DATABASE::"Transfer Header", 0, Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnBeforeDeleteEvent', '', true, false)]
    local procedure TransferLine_OnBeforeDelete(var Rec: Record "Transfer Line"; RunTrigger: Boolean)
    var
        TransferLine: Record "Transfer Line";
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        DataCollectionMgmt.CheckTransLineModify(Rec, TransferLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnBeforeValidateEvent', 'Item No.', true, false)]
    local procedure TransferLine_OnBeforeValidate_ItemNo(var Rec: Record "Transfer Line"; var xRec: Record "Transfer Line"; CurrFieldNo: Integer)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        DataCollectionMgmt.CheckTransLineModify(xRec, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Zone, 'OnAfterDeleteEvent', '', true, false)]
    local procedure Zone_OnAfterDelete(var Rec: Record Zone; RunTrigger: Boolean)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        DataCollectionMgmt.DeleteDataCollectionLines(Database::Zone, Rec."Location Code", Rec.Code);
    end;

    [EventSubscriber(ObjectType::Table, Database::Bin, 'OnAfterDeleteEvent', '', true, false)]
    local procedure Bin_OnAfterDelete(var Rec: Record Bin; RunTrigger: Boolean)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        DataCollectionMgmt.DeleteDataCollectionLines(DATABASE::Bin, Rec."Location Code", Rec.Code);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Work Center", 'OnAfterDeleteEvent', '', true, false)]
    local procedure WorkCenter_OnAfterDelete(var Rec: Record "Work Center"; RunTrigger: Boolean)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        DataCollectionMgmt.DeleteDataCollectionLines(DATABASE::"Work Center", Rec."No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Machine Center", 'OnAfterDeleteEvent', '', true, false)]
    local procedure MachineCenter_OnAfterDelete(var Rec: Record "Machine Center"; RunTrigger: Boolean)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        DataCollectionMgmt.DeleteDataCollectionLines(DATABASE::"Machine Center", Rec."No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Record Link", 'OnAfterDeleteEvent', '', true, false)]
    local procedure Recordlink_OnAfterDelete(var Rec: Record "Record Link"; RunTrigger: Boolean)
    var
        RecordLinkAlertType: Record "Record Link Alert Type";
    begin
        // P800-MegaApp
        if Rec.IsTemporary then
            exit;

        if not RunTrigger then
            exit;

        RecordLinkAlertType.SetRange("Link ID", Rec."Link ID");
        RecordLinkAlertType.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Record Link", 'OnAfterInsertEvent', '', true, false)]
    local procedure Recordlink_OnAfterInsert(var Rec: Record "Record Link"; RunTrigger: Boolean)
    var
        RecordLinkAlertType: Record "Record Link Alert Type";
        xDescription: Text;
    begin
        // P800-MegaApp
        if Rec.IsTemporary then
            exit;

        if not RunTrigger then
            exit;

        xDescription := Rec.Description;
        RecordLinkAlertType."Link ID" := Rec."Link ID";
        RecordLinkAlertType."Alert Type" := RecordLinkLookupDescription(Rec);
        if RecordLinkAlertType."Alert Type" <> 0 then
            RecordLinkAlertType.Insert;

        if xDescription <> rec.Description then
            Rec.Modify;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Record Link", 'OnBeforeModifyEvent', '', true, false)]
    local procedure Recordlink_OnBeforeModify(var Rec: Record "Record Link"; var xRec: Record "Record Link"; RunTrigger: Boolean)
    var
        RecordLinkAlertType: Record "Record Link Alert Type";
        AlertType: Integer;
    begin
        // P800-MegaApp
        if Rec.IsTemporary then
            exit;

        if not RunTrigger then
            exit;

        AlertType := RecordLinkLookupDescription(Rec);
        if RecordLinkAlertType.Get(Rec."Link ID") then begin
            if AlertType = 0 then
                RecordLinkAlertType.Delete
            else begin
                RecordLinkAlertType."Alert Type" := AlertType;
                RecordLinkAlertType.Modify;
            end;
        end else
            if AlertType <> 0 then begin
                RecordLinkAlertType."Link ID" := Rec."Link ID";
                RecordLinkAlertType."Alert Type" := AlertType;
                RecordLinkAlertType.Insert;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeFinalizePosting', '', true, false)]
    local procedure SalesPost_OnBeforeFinalizePosting(var SalesHeader: Record "Sales Header"; var TempSalesLineGlobal: Record "Sales Line" temporary; var EverythingInvoiced: Boolean; SuppressCommit: Boolean)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if SalesHeader.Ship or SalesHeader.Receive then
            DataCollectionMgmt.CreateSheetForSalesHeader(SalesHeader, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeFinalizePosting', '', true, false)]
    local procedure PurchPost_OnBeforeFinalizePosting(var PurchaseHeader: Record "Purchase Header"; var TempPurchLineGlobal: Record "Purchase Line" temporary; var EverythingInvoiced: Boolean; CommitIsSupressed: Boolean)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if PurchaseHeader.Ship or PurchaseHeader.Receive then
            DataCollectionMgmt.CreateSheetForPurchHeader(PurchaseHeader, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnAfterGetPageID', '', true, false)]
    local procedure PageManagement_OnAfterGetPageID(RecordRef: RecordRef; var PageID: Integer)
    var
        DataSheetHeader: Record "Data Sheet Header";
    begin
        // P8004516, P80066030
        case RecordRef.Number of
            DATABASE::"Data Sheet Header":
                begin
                    RecordRef.SetTable(DataSheetHeader);
                    if DataSheetHeader.Type <> DataSheetHeader.Type::Production then
                        PageID := PAGE::"Data Sheet"
                    else
                        PageID := PAGE::"Data Sheet-Production";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Order Status Management", 'OnAfterTransProdOrder', '', true, false)]
    local procedure ProdOrderStatusMgmt_OnAfterTransProdOrder(var FromProdOrder: Record "Production Order"; var ToProdOrder: Record "Production Order")
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if ToProdOrder.Status = ToProdOrder.Status::Finished then
            DataCollectionMgmt.CreateSheetForProdOrder(ToProdOrder, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process 800 Core Functions", 'OnInitializeP800', '', true, false)]
    local procedure Process800CoreFunctions_OnInitializeP800(CompName: Text[30]; var SourceCodeSetup: Record "Source Code Setup"; var SourceCode: Record "Source Code"; var ReportSelections: Record "Report Selections")
    var
        DataCollectionSetup: Record "Data Collection Setup";
    begin
        // P80066030
        if CompName <> CompanyName then
            DataCollectionSetup.ChangeCompany(CompName);
        if not DataCollectionSetup.Find('-') then begin
            DataCollectionSetup.Initialize; // P80073095
            DataCollectionSetup.Insert;
        end;
    end;

    local procedure RecordLinkLookupDescription(var RecordLink: Record "Record Link"): Integer
    var
        RecordLinkDescription: Record "Record Link Description";
        RecordID: RecordId;
    begin
        if (StrLen(RecordLink.Description) < 2) or (RecordLink.Type <> RecordLink.Type::Link) then
            exit;
        if CopyStr(RecordLink.Description, 1, 1) <> '%' then
            exit;

        RecordLinkDescription.SetFilter(Code, CopyStr(RecordLink.Description, 2) + '*');
        if RecordLinkDescription.FindFirst() then begin
            RecordLink.Description := RecordLinkDescription.Description;
            RecordID := RecordLink."Record ID";
            if RecordID.TableNo in [Database::"Data Collection Line", Database::"Data Collection Template Line"] then
                exit(RecordLinkDescription."Alert Type");
        end;
    end;
}
