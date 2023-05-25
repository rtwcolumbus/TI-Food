codeunit 37002049 "Del. Pricing - Calc. Header"
{
    // PRW16.00.05
    // P8000921, Columbus IT, Don Bresee, 08 APR 11
    //   Add Delivered Pricing granule
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 04 JAN 17
    //   Fix problem with freight calculation
    // 
    // PRW110.0.02
    // P80039781, To-Increase, Jack Reynolds, 10 DEC 17
    //   Warehouse Shipping process
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    EventSubscriberInstance = Manual;
    TableNo = "Sales Header";

    trigger OnRun()
    var
        TotalWeight: Decimal;
    begin
        TotalWeight := CalculateWeight(Rec);
        if TotalWeight <= 500 then
            SetFreightUnitAmount(Rec, 0.1)
        else
            SetFreightUnitAmount(Rec, 0.05);
        // DistributeFreightByWeight(Rec,TotalWeight,ROUND(TotalWeight * 0.075));
    end;

    var
        DelPricingCalcLine: Codeunit "Del. Pricing - Calc. Line";

    procedure CalculateWeight(var SalesHeader: Record "Sales Header") TotalWeight: Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        with SalesLine do begin
            SetRange("Document Type", SalesHeader."Document Type");
            SetRange("Document No.", SalesHeader."No.");
            SetFilter(Type, '<>%1', Type::" ");
            if FindSet then
                repeat
                    TotalWeight := TotalWeight + DelPricingCalcLine.CalculateWeight(SalesLine);
                until (Next = 0);
        end;
    end;

    procedure DistributeFreightByWeight(var SalesHeader: Record "Sales Header"; TotalWeight: Decimal; TotalFreight: Decimal)
    var
        SalesLine: Record "Sales Line";
        LineWeight: Decimal;
        LineFreight: Decimal;
    begin
        with SalesLine do begin
            SetRange("Document Type", SalesHeader."Document Type");
            SetRange("Document No.", SalesHeader."No.");
            SetFilter(Type, '<>%1', SalesLine.Type::" ");
            if FindSet then
                repeat
                    LineWeight := DelPricingCalcLine.CalculateWeight(SalesLine);
                    if (TotalWeight = 0) then
                        LineFreight := 0
                    else
                        LineFreight := TotalFreight * (LineWeight / TotalWeight);
                    if not "Freight Entered by User" then begin
                        "Unit Price (Freight)" := 0;
                        "Line Amount (Freight)" := LineFreight;
                        ValidateFreightAmounts;
                        Modify(true);
                        LineFreight := "Line Amount (Freight)";
                    end;
                    TotalFreight := TotalFreight - LineFreight;
                    TotalWeight := TotalWeight - LineWeight;
                until (SalesLine.Next = 0);
        end;
    end;

    procedure SetFreightUnitAmount(var SalesHeader: Record "Sales Header"; FreightUnitAmount: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        with SalesLine do begin
            SetRange("Document Type", SalesHeader."Document Type");
            SetRange("Document No.", SalesHeader."No.");
            SetFilter(Type, '<>%1', SalesLine.Type::" ");
            SetRange("Freight Entered by User", false);
            if FindSet then
                repeat
                    if (GetPricingQty() = 0) then
                        "Unit Price (Freight)" := 0
                    else
                        "Unit Price (Freight)" :=
                          (FreightUnitAmount * DelPricingCalcLine.CalculateWeight(SalesLine)) / GetPricingQty();
                    "Line Amount (Freight)" := 0;
                    ValidateFreightAmounts;
                    Modify; // P80039781
                until (SalesLine.Next = 0);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeTestStatusOpen_Food', '', true, false)]
    local procedure SalesLine_OnBeforeTestStatusOpen_Food(SalesHeader: Record "Sales Header"; var StatusCheckSuspended: Boolean)
    begin
        // P8007748
        if SalesHeader.Status = SalesHeader.Status::"Pending Approval" then
            StatusCheckSuspended := true;
    end;
}

