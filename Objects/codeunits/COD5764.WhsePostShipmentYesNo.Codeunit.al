codeunit 5764 "Whse.-Post Shipment (Yes/No)"
{
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Support for running from order Shipping

    TableNo = "Warehouse Shipment Line";

    trigger OnRun()
    begin
        WhseShptLine.Copy(Rec);
        Code;
        Rec := WhseShptLine;
    end;

    var
        WhseShptLine: Record "Warehouse Shipment Line";
        WhsePostShipment: Codeunit "Whse.-Post Shipment";
        Selection: Integer;
        ShipInvoiceQst: Label '&Ship,Ship &and Invoice';
        RunFromOrderShip: Boolean;
        Posted: Boolean;
        Text37002000: Label 'Do you want to post the shipment?';

    local procedure "Code"()
    var
        Invoice: Boolean;
        HideDialog: Boolean;
        IsPosted: Boolean;
    begin
        HideDialog := false;
        IsPosted := false;
        OnBeforeConfirmWhseShipmentPost(WhseShptLine, HideDialog, Invoice, IsPosted, Selection);
        if IsPosted then
            exit;

        with WhseShptLine do begin
            if Find then
                if not HideDialog then begin
                    // P8000282A
                    if RunFromOrderShip then begin
                        if not Confirm(Text37002000, false) then
                            exit;
                    end else begin
                        Selection := StrMenu(ShipInvoiceQst, 1);
                        if Selection = 0 then
                            exit;
                        Invoice := (Selection = 2);
                    end; // P8000282A
                end;

            OnAfterConfirmPost(WhseShptLine, Invoice);

            WhsePostShipment.SetPostingSettings(Invoice);
            WhsePostShipment.SetPrint(false);
            WhsePostShipment.Run(WhseShptLine);
            WhsePostShipment.GetResultMessage;
            Posted := true; // P8000282A
            Clear(WhsePostShipment);
        end;

        OnAfterCode(WhseShptLine);
    end;

    procedure RunFromOrderShipping(OrderShip: Boolean)
    begin
        // P8000282A
        RunFromOrderShip := OrderShip;
    end;

    procedure ShipmentPosted(): Boolean
    begin
        // P8000282A
        exit(Posted);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterConfirmPost(WhseShipmentLine: Record "Warehouse Shipment Line"; Invoice: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCode(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmWhseShipmentPost(var WhseShptLine: Record "Warehouse Shipment Line"; var HideDialog: Boolean; var Invoice: Boolean; var IsPosted: Boolean; var Selection: Integer)
    begin
    end;
}

