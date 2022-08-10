codeunit 7306 "Whse.-Act.-Register (Yes/No)"
{
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 18 AUG 06
    //   Add code to indicate the process that is running this and to return of the registration happened
    // 
    // P8000372A, VerticalSoft, Phyllis McGovern, 06 SEP 06
    //   WH Overship and OverReceive
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 12 JUN 07
    //   Overship - Fix UOM bug
    // 
    // PRW110.0.02
    // P80050544, To-Increase, Dayakar Battini, 12 FEB 18
    //   Upgrade to 2017 CU13
    // 
    // P80039781, To-Increase, Jack Reynolds, 10 DEC 17
    //   Warehouse Shipping process

    TableNo = "Warehouse Activity Line";

    trigger OnRun()
    begin
        WhseActivLine.Copy(Rec);
        Code;
        Copy(WhseActivLine);
    end;

    var
        Text001: Label 'Do you want to register the %1 Document?';
        WhseActivLine: Record "Warehouse Activity Line";
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
        WMSMgt: Codeunit "WMS Management";
        Text002: Label 'The document %1 is not supported.';
        RunFromOrderShip: Boolean;
        Posted: Boolean;
        Text37000000: Label 'Confirm the over-shipment of %1 %2s of Item %3 for %4 %5?';
        Text37000001: Label 'One or more components for kit %1 have not been picked to ship the kit complete.';
        Text37000002: Label 'Components for kit %1 have not been picked to ship a whole number for the kit.';

    local procedure "Code"()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCode(WhseActivLine, IsHandled);
        if IsHandled then
            exit;

        with WhseActivLine do begin
            CheckSourceDocument();

            WMSMgt.CheckBalanceQtyToHandle(WhseActivLine);

            if not ConfirmRegister(WhseActivLine) then
                exit;

            // P8000372A
            if not ProcessOverShip(WhseActivLine) then
                exit;
            // P8000372A

            IsHandled := false;
            OnBeforeRegisterRun(WhseActivLine, IsHandled);
            if not IsHandled then
                WhseActivityRegister.Run(WhseActivLine);
            Clear(WhseActivityRegister);

            Posted := true; // P8000322A
        end;

        OnAfterCode(WhseActivLine);
    end;

    local procedure ConfirmRegister(WarehouseActivityLine: Record "Warehouse Activity Line") Result: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeConfirmRegister(WarehouseActivityLine, Result, IsHandled);
        if IsHandled then
            exit(Result);

        Result := Confirm(Text001, false, WarehouseActivityLine."Activity Type");
    end;

    procedure RunFromOrderShipping(OrderShip: Boolean)
    begin
        RunFromOrderShip := OrderShip; // P8000322A
    end;

    procedure DocumentPosted(): Boolean
    begin
        exit(Posted); // P8000322A
    end;

    procedure ProcessOverShip(var WhseActivLine: Record "Warehouse Activity Line"): Boolean
    var
        WhseActivLine2: Record "Warehouse Activity Line";
        WhseShptLine: Record "Warehouse Shipment Line";
        TempWhseShptLine: Record "Warehouse Shipment Line" temporary;
        UnitOfMeasure: Record "Unit of Measure";
        WHActHeader: Record "Warehouse Activity Header";
    begin
        // P8000372A
        // P8000466A - Change parameter to VAR, Reworked to handle different units, kits
        if (WhseActivLine."Activity Type" = WhseActivLine."Activity Type"::Pick) then begin
            WHActHeader.Get(WhseActivLine."Activity Type"::Pick, WhseActivLine."No.");
            with WhseActivLine2 do begin
                Copy(WhseActivLine);
                SetRange("Action Type", "Action Type"::Take);
                SetRange("Whse. Document Type", "Whse. Document Type"::Shipment);
                SetRange("Breakbulk No.", 0);
                if Find('-') then
                    repeat
                        if TempWhseShptLine.Get("Whse. Document No.", "Whse. Document Line No.") then begin
                            if ("Unit of Measure Code" = TempWhseShptLine."Unit of Measure Code") then
                                TempWhseShptLine."Qty. to Ship" :=
                                  TempWhseShptLine."Qty. to Ship" + "Qty. to Handle"
                            else
                                TempWhseShptLine."Qty. to Ship" := TempWhseShptLine."Qty. to Ship" +
                                  ("Qty. to Handle" * "Qty. per Unit of Measure" / TempWhseShptLine."Qty. per Unit of Measure");
                            TempWhseShptLine.Modify;
                        end else
                            if WhseShptLine.Get("Whse. Document No.", "Whse. Document Line No.") then begin
                                TempWhseShptLine := WhseShptLine;
                                if ("Unit of Measure Code" = TempWhseShptLine."Unit of Measure Code") then
                                    TempWhseShptLine."Qty. to Ship" := "Qty. to Handle"
                                else
                                    TempWhseShptLine."Qty. to Ship" :=
                                      ("Qty. to Handle" * "Qty. per Unit of Measure" / TempWhseShptLine."Qty. per Unit of Measure");
                                TempWhseShptLine.Insert;
                            end;
                    until (Next = 0);
            end;
            with TempWhseShptLine do begin
                if Find('-') then begin
                    repeat
                        "Qty. to Ship" := Round("Qty. to Ship", 0.00001);
                        if ("Qty. to Ship" > "Qty. Outstanding") then begin
                            UnitOfMeasure.Get("Unit of Measure Code");
                            if WHActHeader."ADC Started" = false then
                                if not Confirm(Text37000000, false, "Qty. to Ship" - "Qty. Outstanding",
                                               UnitOfMeasure.Description, "Item No.", "Source Document", "Source No.")
                                then
                                    exit(false);
                            Modify;
                        end;
                    until (Next = 0);
                    Find('-');
                    repeat
                        if ("Qty. to Ship" > "Qty. Outstanding") then begin
                            WhseShptLine := TempWhseShptLine;
                            WhseShptLine.Find;
                            WhseShptLine."Qty. to Ship" := "Qty. to Ship";
                            WhseShptLine.ProcessOverShip(''); // P80039781
                        end;
                    until (Next = 0);
                end;
            end;
        end;
        exit(true);
        // P8000372A
    end;
    
    local procedure CheckSourceDocument()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckSourceDocument(WhseActivLine, IsHandled);
        if IsHandled then
            exit;

        with WhseActivLine do
            if ("Activity Type" = "Activity Type"::"Invt. Movement") and
               not ("Source Document" in ["Source Document"::" ",
                                          "Source Document"::"Prod. Consumption",
                                          "Source Document"::"Assembly Consumption"])
            then
                Error(Text002, "Source Document");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCode(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCode(var WarehouseActivityLine: Record "Warehouse Activity Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckSourceDocument(WarehouseActivityLine: Record "Warehouse Activity Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmRegister(var WarehouseActivityLine: Record "Warehouse Activity Line"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRegisterRun(var WarehouseActivityLine: Record "Warehouse Activity Line"; var IsHandled: Boolean)
    begin
    end;
}

