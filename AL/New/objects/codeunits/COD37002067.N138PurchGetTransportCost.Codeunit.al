codeunit 37002067 "N138 Purch.-Get Transport Cost"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    TableNo = "Purchase Line";

    trigger OnRun()
    var
        PurchHdr: Record "Purchase Header";
    begin
        PurchHdr.Get("Document Type", "Document No.");
        GetTransportCost(PurchHdr);
    end;

    var
        Text000: Label 'Posted Transport Order No. %1:';
        Text001: Label 'Delivery Trip History No. %1:';

    procedure GetTransportCost(PurchHeader: Record "Purchase Header")
    var
        TempPostedTransCost: Record "N138 Posted Transport Cost" temporary;
        PostedTransCost: Record "N138 Posted Transport Cost";
        GetPostedTransCost: Page "N138 Get Posted Transport Cost";
    begin
        PurchHeader.TestField("Document Type", PurchHeader."Document Type"::Invoice);
        PurchHeader.TestField(Status, PurchHeader.Status::Open);
        PurchHeader.TestField("Buy-from Vendor No.");

        PostedTransCost.SetRange(Invoiced, false);
        if PostedTransCost.FindSet then
            repeat
                PostedTransCost.CalcFields("Purch. Invoice No.", "Posted Invoice No.");
                if ((PostedTransCost."Purch. Invoice No." = '') and
                    (PostedTransCost."Posted Invoice No." = '')) then begin
                    if CheckShippingAgentService(PurchHeader, PostedTransCost) then begin
                        TempPostedTransCost := PostedTransCost;
                        if not TempPostedTransCost.Find then
                            TempPostedTransCost.Insert;
                    end;
                end;
            until PostedTransCost.Next = 0;

        GetPostedTransCost.LookupMode := true;
        GetPostedTransCost.SetTransportCost(TempPostedTransCost);
        if GetPostedTransCost.RunModal = ACTION::LookupOK then begin
            GetPostedTransCost.GetTransportCost(TempPostedTransCost);
            CreateLines(PurchHeader, TempPostedTransCost);
        end;
    end;

    local procedure CheckShippingAgentService(PurchHeader: Record "Purchase Header"; PostedTransCost: Record "N138 Posted Transport Cost"): Boolean
    var
        ShippingAgentService: Record "Shipping Agent Services";
        DeliveryTripHistory: Record "N138 Delivery Trip History";
    begin
        ShippingAgentService.SetRange("Vendor No.", PurchHeader."Buy-from Vendor No.");

        case PostedTransCost."Source Type" of
            DATABASE::"N138 Delivery Trip History":
                begin
                    DeliveryTripHistory.Get(PostedTransCost."Posted No.");
                    ShippingAgentService.SetRange(Code, DeliveryTripHistory."Shipping Agent Service Code");
                    exit(not ShippingAgentService.IsEmpty);
                end;
        end;
    end;

    local procedure CreateLines(PurchHeader: Record "Purchase Header"; var TempPostedTransCost: Record "N138 Posted Transport Cost" temporary)
    var
        lCtxText001: Label 'Posted Transport Order No. %1:';
        PurchLine: Record "Purchase Line";
        LineNo: Integer;
        PurchCommLine: Record "Purch. Comment Line";
        PrevPostedNo: Code[20];
    begin
        PurchLine.Reset;
        PurchLine.SetRange(PurchLine."Document Type", PurchHeader."Document Type");
        PurchLine.SetRange(PurchLine."Document No.", PurchHeader."No.");
        if PurchLine.FindLast then
            LineNo := PurchLine."Line No." + 10000
        else
            LineNo := 10000;

        with TempPostedTransCost do begin
            repeat
                if FindFirst then begin
                    if "Posted No." <> PrevPostedNo then begin

                        PrevPostedNo := "Posted No.";
                        PurchLine.Init;
                        PurchLine."Line No." := LineNo;
                        LineNo += 10000;
                        PurchLine."Document Type" := PurchHeader."Document Type";
                        PurchLine."Document No." := PurchHeader."No.";
                        PurchLine.Description := GetDescription(TempPostedTransCost);
                        PurchLine.Insert;
                    end;
                    PurchLine.Init;
                    PurchLine."Line No." := LineNo;
                    LineNo += 10000;
                    PurchLine."Document Type" := PurchHeader."Document Type";
                    PurchLine."Document No." := PurchHeader."No.";
                    PurchLine.Validate(Type, PurchLine.Type::"G/L Account");
                    PurchLine.Validate("No.", "G/L Account No.");
                    PurchLine.Validate(Quantity, 1);
                    PurchLine.Description := Description;
                    PurchLine.Validate("Direct Unit Cost", Amount);
                    PurchLine."Currency Code" := Currency;
                    PurchLine."Transport Cost Entry No" := "Entry No.";
                    PurchLine.Insert;
                end;
                Delete;
            until IsEmpty;
        end;
    end;

    local procedure GetDescription(PostedTransportCost: Record "N138 Posted Transport Cost") Return: Text[100]
    var
        DeliveryTripHistory: Record "N138 Delivery Trip History";
    begin
        case PostedTransportCost."Source Type" of
            DATABASE::"N138 Delivery Trip History":
                begin
                    DeliveryTripHistory.Get(PostedTransportCost."Posted No.");
                    Return := StrSubstNo(Text001, DeliveryTripHistory."No.");
                end;
        end;
    end;
}

