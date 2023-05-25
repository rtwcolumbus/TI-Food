codeunit 5762 "Whse.-Post Receipt + Print"
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
        WhseActivHeader: Record "Warehouse Activity Header";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        PrintedDocuments: Integer;
        Posted: Boolean;
	
        Text001: Label 'Number of put-away activities printed: %1.';

    local procedure "Code"()
    var
        ReportSelectionWarehouse: Record "Report Selection Warehouse";
        WhsePostReceipt: Codeunit "Whse.-Post Receipt";
        ShouldRunPrint: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCode(WhseReceiptLine, IsHandled);
        if IsHandled then
            exit;

        ClearLastError;                   // P80059062
        WhsePostReceipt.Run(WhseReceiptLine);
        WhsePostReceipt.GetResultMessage();
        //Posted := TRUE; // P8000282A    // P80059062
        Posted := GetLastErrorText = '';  // P80059062

        PrintedDocuments := 0;
        ShouldRunPrint := WhsePostReceipt.GetFirstPutAwayDocument(WhseActivHeader);
        OnCodeOnAfterCalcShouldRunPrint(WhseReceiptLine, WhsePostReceipt, ShouldRunPrint);
        if ShouldRunPrint then begin
            repeat
                WhseActivHeader.SetRecFilter();
                OnBeforePrintReport(WhseActivHeader);
                ReportSelectionWarehouse.PrintWhseActivityHeader(WhseActivHeader, "Report Selection Warehouse Usage"::"Put-away", true);
                OnAfterPrintReport(WhseActivHeader);
                PrintedDocuments := PrintedDocuments + 1;
            until not WhsePostReceipt.GetNextPutAwayDocument(WhseActivHeader);
            Message(Text001, PrintedDocuments);
        end;
        Clear(WhsePostReceipt);

        OnAfterCode(WhseReceiptLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPrintReport(var WhseActivityHeader: Record "Warehouse Activity Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCode(var WhseReceiptLine: Record "Warehouse Receipt Line")
    begin
    end;

    procedure ReceiptPosted(): Boolean
    begin
        // P8000282A
        exit(Posted);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCode(var WhseReceiptLine: Record "Warehouse Receipt Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintReport(var WhseActivityHeader: Record "Warehouse Activity Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnAfterCalcShouldRunPrint(var WarehouseReceiptLine: Record "Warehouse Receipt Line"; var WhsePostReceipt: Codeunit "Whse.-Post Receipt"; var ShouldRunPrint: Boolean)
    begin
    end;
}