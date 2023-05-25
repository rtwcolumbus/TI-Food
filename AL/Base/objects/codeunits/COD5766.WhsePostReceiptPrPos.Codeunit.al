codeunit 5766 "Whse.-Post Receipt + Pr. Pos."
{
    // PRW16.00.02
    // P8000756, VerticalSoft, Jack Reynolds, 12 JAN 10
    //   Add code to be able to return if document was posted
    // 
    // PRW111.00.01
    // P80059062, To-Increase, Dayakar Battini, 17 MAY 18
    //   Issue fix for whse. receipt delete when posting error occurs

    TableNo = "Warehouse Receipt Line";

    trigger OnRun()
    begin
        WhseReceiptLine.Copy(Rec);
        Code();
    end;

    var
        PostedWhseRcptHeader: Record "Posted Whse. Receipt Header";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        Text001: Label 'Number of posted whse. receipts printed: 1.';
        Posted: Boolean;

    local procedure "Code"()
    var
        WhsePostReceipt: Codeunit "Whse.-Post Receipt";
        WarehouseDocumentPrint: Codeunit "Warehouse Document-Print";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCode(WhseReceiptLine, IsHandled);
        if IsHandled then
            exit;

        with WhseReceiptLine do begin
            ClearLastError;                   // P80059062
            WhsePostReceipt.Run(WhseReceiptLine);
            WhsePostReceipt.GetResultMessage();
            //Posted := TRUE; // P8000576     // P80059062
            Posted := GetLastErrorText = '';  // P80059062

            PostedWhseRcptHeader.SetRange("Whse. Receipt No.", "No.");
            PostedWhseRcptHeader.SetRange("Location Code", "Location Code");
            PostedWhseRcptHeader.FindLast();
            WarehouseDocumentPrint.PrintPostedRcptHeader(PostedWhseRcptHeader);
            Message(Text001);

            Clear(WhsePostReceipt);
        end;

        OnAfterCode(WhseReceiptLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCode(var WarehouseReceiptLine: Record "Warehouse Receipt Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCode(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; var IsHandled: Boolean)
    begin
    end;
    procedure ReceiptPosted(): Boolean
    begin
        // P8000576
        exit(Posted);
    end;
}

