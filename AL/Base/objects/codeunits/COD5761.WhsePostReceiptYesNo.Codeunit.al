codeunit 5761 "Whse.-Post Receipt (Yes/No)"
{
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Support for running from order receiving
    // 
    // PRW111.00.01
    // P80059062, To-Increase, Dayakar Battini, 17 MAY 18
    //   Issue fix for whse. receipt delete when posting error occurs

    TableNo = "Warehouse Receipt Line";

    trigger OnRun()
    begin
        WhseReceiptLine.Copy(Rec);
        Code();
        Rec := WhseReceiptLine;
    end;

    var
        WhseReceiptLine: Record "Warehouse Receipt Line";
        WhsePostReceipt: Codeunit "Whse.-Post Receipt";
        Posted: Boolean;
	
        Text000: Label 'Do you want to post the receipt?';

    local procedure "Code"()
    var
        HideDialog: Boolean;
        IsPosted: Boolean;
        IsHandled: Boolean;
    begin
        HideDialog := false;
        IsPosted := false;
        OnBeforeConfirmWhseReceiptPost(WhseReceiptLine, HideDialog, IsPosted);
        if IsPosted then
            exit;

        with WhseReceiptLine do begin
            if Find() then
                if not HideDialog then
                    if not Confirm(Text000, false) then
                        exit;
            ClearLastError;                   // P80059062

            IsHandled := false;
            OnAfterConfirmPost(WhseReceiptLine, IsHandled);
            if not IsHandled then begin
                WhsePostReceipt.Run(WhseReceiptLine);
                OnAfterWhsePostReceiptRun(WhseReceiptLine, WhsePostReceipt);
                WhsePostReceipt.GetResultMessage();
                //Posted := TRUE; // P8000282A    // P80059062
                Posted := GetLastErrorText = '';  // P80059062
                Clear(WhsePostReceipt);
            end;
        end;
    end;
    
    procedure ReceiptPosted(): Boolean
    begin
        // P8000282A
        exit(Posted);
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnAfterConfirmPost(WhseReceiptLine: Record "Warehouse Receipt Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterWhsePostReceiptRun(var WhseReceiptLine: Record "Warehouse Receipt Line"; WhsePostReceipt: Codeunit "Whse.-Post Receipt")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmWhseReceiptPost(var WhseReceiptLine: Record "Warehouse Receipt Line"; var HideDialog: Boolean; var IsPosted: Boolean)
    begin
    end;
}

