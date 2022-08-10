codeunit 37002770 "Order Shipping-Receiving"
{
    // PRW111.00.02
    // P80070336, To Increase, Jack Reynolds, 12 FEB 19
    //   Fix issue with Alternate Quantity to Handle
    // 
    // P80071657, To Increase, Jack Reynolds, 15 MAR 19
    //   Fix posting date issue; refactoring

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        BatchID: Guid;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Qty. to Ship', true, false)]
    local procedure SalesLine_OnBeforeValidate_QtyToShip(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary then
            exit;

        Rec.SuspendStatusCheck(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Qty. to Ship (Alt.)', true, false)]
    local procedure SalesLine_OnBeforeValidate_QtyToShipAlt(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary then
            exit;

        Rec.SuspendStatusCheck(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Return Qty. to Receive', true, false)]
    local procedure SalesLine_OnBeforeValidate_ReturnQtyToReceive(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary then
            exit;

        Rec.SuspendStatusCheck(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Return Qty. to Receive (Alt.)', true, false)]
    local procedure SalesLine_OnBeforeValidate_ReturnQtyToReceiveAlt(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary then
            exit;

        Rec.SuspendStatusCheck(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeValidateEvent', 'Qty. to Receive', true, false)]
    local procedure PurchaseLine_OnBeforeValidate_QtyToReceive(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary then
            exit;

        Rec.SuspendStatusCheck(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeValidateEvent', 'Qty. to Receive (Alt.)', true, false)]
    local procedure PurchaseLine_OnBeforeValidate_QtyToReceiveAlt(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary then
            exit;

        Rec.SuspendStatusCheck(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeValidateEvent', 'Return Qty. to Ship', true, false)]
    local procedure PurchaseLine_OnBeforeValidate_ReturnQtyToShip(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary then
            exit;

        Rec.SuspendStatusCheck(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeValidateEvent', 'Return Qty. to Ship (Alt.)', true, false)]
    local procedure PurchaseLine_OnBeforeValidate_ReturnQtyToShipAlt(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary then
            exit;

        Rec.SuspendStatusCheck(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tracking Specification", 'OnBeforeValidateEvent', 'Quantity (Base)', true, false)]
    local procedure TrackingSpecification_OnBeforeValidate_QuantityBase(var Rec: Record "Tracking Specification"; var xRec: Record "Tracking Specification"; CurrFieldNo: Integer)
    begin
        Rec.SuspendStatusCheck(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tracking Specification", 'OnBeforeValidateEvent', 'Qty. to Handle (Base)', true, false)]
    local procedure TrackingSpecification_OnBeforeValidate_QtyToHandleBase(var Rec: Record "Tracking Specification"; var xRec: Record "Tracking Specification"; CurrFieldNo: Integer)
    begin
        Rec.SuspendStatusCheck(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tracking Specification", 'OnBeforeValidateEvent', 'Qty. to Handle (Alt.)', true, false)]
    local procedure TrackingSpecification_OnBeforeValidate_QtyToHandleAlt(var Rec: Record "Tracking Specification"; var xRec: Record "Tracking Specification"; CurrFieldNo: Integer)
    begin
        Rec.SuspendStatusCheck(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Alternate Quantity Line", 'OnBeforeDeleteEvent', '', true, false)]
    local procedure AlternateQuantityLine_OnBeforeDelete(var Rec: Record "Alternate Quantity Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        Rec.SuspendStatusCheck(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Alternate Quantity Line", 'OnBeforeValidateEvent', 'Quantity', true, false)]
    local procedure AlternateQuantityLine_OnBeforeValidate_Quantity(var Rec: Record "Alternate Quantity Line"; var xRec: Record "Alternate Quantity Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary then
            exit;

        Rec.SuspendStatusCheck(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Alternate Quantity Line", 'OnBeforeValidateEvent', 'Quantity (Alt.)', true, false)]
    local procedure AlternateQuantityLine_OnBeforeValidate_QuantityAlt(var Rec: Record "Alternate Quantity Line"; var xRec: Record "Alternate Quantity Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary then
            exit;

        Rec.SuspendStatusCheck(true);
    end;

    [EventSubscriber(ObjectType::Table, database::"Batch Processing Parameter", 'OnAfterInsertEvent', '', true, false)]
    local procedure BatchProcessingParameter_OnAfterInsert(var Rec: Record "Batch Processing Parameter"; RunTrigger: Boolean)
    begin
        // P80071657
        BatchID := Rec."Batch ID";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process 800 Warehouse Mgmt.", 'OnGetBatchID', '', false, false)]
    local procedure Process800WarehouseMgmt_OnGetBatchID(var ID: Guid)
    begin
        // P80071657
        ID := BatchID;
    end;
}

