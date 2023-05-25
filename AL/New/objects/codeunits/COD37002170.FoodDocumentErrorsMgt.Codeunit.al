codeunit 37002170 "Food Document Errors Mgt."
{
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 23 MAY 22
    //   Support for background validation of documents and journals
    
    EventSubscriberInstance = Manual;

    var
        GlobalTerminalMarketSalesOrderPage: Page "Terminal Market Sales Order";
        GlobalCommodityPurchaseOrderPage: Page "Commodity Purchase Order";
        DocumentErrorsMgt: Codeunit "Document Errors Mgt.";

    // Terminal Market Sales Order
    [EventSubscriber(ObjectType::Page, Page::"Terminal Market Sales Order", 'OnAfterOnAfterGetRecord', '', false, false)]
    local procedure OnAfterOnAfterGetRecordTerminalMarketSalesOrder(var Sender: Page "Terminal Market Sales Order"; var SalesHeader: Record "Sales Header")
    begin
        if DocumentErrorsMgt.BackgroundValidationEnabled() then
            GlobalTerminalMarketSalesOrderPage := Sender;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Terminal Market Sales Order", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifyRecordEventTerminalMarketSalesOrder(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; var AllowModify: Boolean)
    begin
        if DocumentErrorsMgt.BackgroundValidationEnabled() then begin
            DocumentErrorsMgt.SetFullDocumentCheck(true);
            GlobalTerminalMarketSalesOrderPage.RunBackgroundCheck();
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Term. Mkt. Order Lines Subform", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifyRecordEventTermMarketSubform(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; var AllowModify: Boolean)
    begin
        if DocumentErrorsMgt.BackgroundValidationEnabled() then begin
            DocumentErrorsMgt.SetFullDocumentCheck(true);
            GlobalTerminalMarketSalesOrderPage.RunBackgroundCheck();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Errors Mgt.", 'OnBeforeOnAfterGetCurrRecordSalesDocCheckFactbox', '', false, false)]
    local procedure OnBeforeOnAfterGetCurrRecordSalesDocCheckFactbox(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
        if DocumentErrorsMgt.BackgroundValidationEnabled() then begin
            DocumentErrorsMgt.SetFullDocumentCheck(true);
            GlobalTerminalMarketSalesOrderPage.RunBackgroundCheck();
            IsHandled := true;
        end;
    end;

    // Commodity Purchase Order
    [EventSubscriber(ObjectType::Page, Page::"Commodity Purchase Order", 'OnAfterOnAfterGetRecord', '', false, false)]
    local procedure OnAfterOnAfterGetRecordCommodityPurchaseOrder(var Sender: Page "Commodity Purchase Order"; var PurchaseHeader: Record "Purchase Header")
    begin
        if DocumentErrorsMgt.BackgroundValidationEnabled() then
            GlobalCommodityPurchaseOrderPage := Sender;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Commodity Purchase Order", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifyRecordEventCommodityPurchaseOrder(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; var AllowModify: Boolean)
    begin
        if DocumentErrorsMgt.BackgroundValidationEnabled() then begin
            DocumentErrorsMgt.SetFullDocumentCheck(true);
            GlobalCommodityPurchaseOrderPage.RunBackgroundCheck();
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Commodity Purch. Order Subpage", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifyRecordEventCommodityPurchOrderSubpage(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; var AllowModify: Boolean)
    begin
        if DocumentErrorsMgt.BackgroundValidationEnabled() then begin
            DocumentErrorsMgt.SetFullDocumentCheck(true);
            GlobalCommodityPurchaseOrderPage.RunBackgroundCheck();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Errors Mgt.", 'OnBeforeOnAfterGetCurrRecordPurchDocCheckFactbox', '', false, false)]
    local procedure OnBeforeOnAfterGetCurrRecordPurchDocCheckFactbox(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
        if DocumentErrorsMgt.BackgroundValidationEnabled() then begin
            DocumentErrorsMgt.SetFullDocumentCheck(true);
            GlobalCommodityPurchaseOrderPage.RunBackgroundCheck();
            IsHandled := true;
        end;
    end;
}