codeunit 37002065 "N138 Shorts Mgt."
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // TOM4219     05-10-2105  Cleanup change line wizard
    // --------------------------------------------------------------------------------
    // 
    // PRW19.00.01
    // P8007412, To-Increase, Dayakar Battini, 29 JUN 16
    //   Zero Qty Shipment line handling.
    // 
    // P8006916, To-Increase, Jack Reynolds, 31 AUG 16
    //   FOOD-TOM Separation
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects


    trigger OnRun()
    begin
    end;

    procedure ShowSourceDocWizard(WhseShptLine: Record "Warehouse Shipment Line")
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
        ServiceLine: Record "Service Line";
        ChangeSourceLineWizard: Page "N138 ChangeSource Line Wizard";
    begin
        with WhseShptLine do begin
            TestField(Short);
            case "Source Type" of
                DATABASE::"Sales Line":
                    begin
                        SalesLine.SetRange("Document Type", "Source Subtype");
                        SalesLine.SetRange("Document No.", "Source No.");
                        SalesLine.SetRange("Line No.", "Source Line No.");
                        SalesLine.FindFirst;
                        ChangeSourceLineWizard.Init(SalesLine."No.", SalesLine.Quantity, "Qty. to Ship", SalesLine, "Short Action"); // TOM4219
                        ChangeSourceLineWizard.RunModal;
                    end;
                DATABASE::"Purchase Line":
                    begin
                        PurchLine.SetRange("Document Type", "Source Subtype");
                        PurchLine.SetRange("Document No.", "Source No.");
                        PurchLine.SetRange("Line No.", "Source Line No.");
                        PurchLine.FindFirst;
                        ChangeSourceLineWizard.Init(PurchLine."No.", PurchLine.Quantity, "Qty. to Ship", PurchLine, "Short Action"); // TOM4219
                        ChangeSourceLineWizard.RunModal; // TOM4219
                    end;
                DATABASE::"Transfer Line":
                    begin
                        TransferLine.SetRange("Document No.", "Source No.");
                        TransferLine.SetRange("Line No.", "Source Line No.");
                        TransferLine.FindFirst;
                        ChangeSourceLineWizard.Init(TransferLine."Item No.", TransferLine.Quantity, "Qty. to Ship", TransferLine, "Short Action"); // TOM4219
                        ChangeSourceLineWizard.RunModal;
                    end;
                DATABASE::"Service Line":
                    begin
                        ServiceLine.SetRange("Document Type", "Source Subtype");
                        ServiceLine.SetRange("Document No.", "Source No.");
                        ServiceLine.SetRange("Line No.", "Source Line No.");
                        ServiceLine.FindFirst;
                        ChangeSourceLineWizard.Init(ServiceLine."No.", ServiceLine.Quantity, "Qty. to Ship", ServiceLine, "Short Action"); // TOM4219
                        ChangeSourceLineWizard.RunModal;
                    end;
            end;
            if ChangeSourceLineWizard.Finished then begin
                // P8007412
                if not WhseShptLine.Find then
                    exit;
                // P8007412
                Validate(Short, false);
                Modify(true);
            end;
        end;
    end;
}

