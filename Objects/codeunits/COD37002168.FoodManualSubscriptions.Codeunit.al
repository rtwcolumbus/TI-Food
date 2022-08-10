codeunit 37002168 "Food Manual Subscriptions"
{
    // PRW111.00.02
    // P80070693, To-Increase, Gangabhushan, 22 MAR 19
    //   TI-12871 - TO-Warehouse Shipment Error when undo the Registered Picks
    // 
    // PRW111.00.03
    // P80081811, To-Increase, Gangabhushan, 30 OCT 19
    //   Catchweight item while doing transfer system allowing for Qty to ship Qty.
    // 
    // PRW114.00
    // P80072447, To-Increase, Gangabhushan, 24 MAY 19
    //   Dev. Margin Information per item on the Sales Order Guide

    EventSubscriberInstance = Manual;

    var
        FromUndoPick: Boolean;
        FromOrderGuide: Boolean;
        FromShpt: Boolean;
        FromReceipt: Boolean;

    procedure SetUndoPick()
    begin
        FromUndoPick := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Tracking Management", 'OnGetUndoPick', '', true, false)]
    local procedure ItemTrackingManagement_OnGetUndoPick(var pUndoPick: Boolean)
    begin
        pUndoPick := FromUndoPick;
    end;

    procedure SetOrderGuide()
    begin
        FromOrderGuide := true; // P80072447
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Contract Management", 'OnGetSetContractFilters', '', true, false)]
    local procedure SalesContractManagement_OnGetSalesContractFilters(var FromOrderGuide: Boolean)
    begin
        FromOrderGuide := FromUndoPick; // P80072447
    end;

    procedure SetShpt()
    begin
        FromShpt := true; // P80081811
    end;

    procedure SetReceipt()
    begin
        FromReceipt := true; // P80081811
    end;

    [EventSubscriber(ObjectType::Table, Database::"Alternate Quantity Line", 'OnGetFromShpt', '', true, false)]
    local procedure AlternateQuantityLine_OnGetFromShpt(var pFromShpt: Boolean)
    begin
        pFromShpt := FromShpt; // P80081811
    end;

    [EventSubscriber(ObjectType::Table, Database::"Alternate Quantity Line", 'OnGetFromReceipt', '', true, false)]
    local procedure AlternateQuantityLine_OnGetFromReceipt(var pFromReceipt: Boolean)
    begin
        pFromReceipt := FromReceipt; // P80081811
    end;

    // Pricing
    var
        ShortSubstituteItem: Boolean;
        ContractItem: Boolean;

    procedure SetShortSubstituteItem(Short: Boolean)
    begin
        ShortSubstituteItem := Short;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Price Calculation - V15", 'OnGetShortSubstituteItem', '', false, false)]
    local procedure PriceCalculationV15_OnGetShortSubstituteItem(var Short: Boolean);
    begin
        Short := ShortSubstituteItem
    end;  

    procedure GetContractItem(): Boolean
    begin 
        exit(ContractItem);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Price Calculation - V15", 'OnSetContractItem', '', false, false)]
    local procedure PriceCalculationV15_OnSetContractItem(Contract: Boolean);
    begin
        ContractItem := Contract;
    end;
    

}

