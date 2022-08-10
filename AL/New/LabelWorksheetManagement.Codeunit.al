codeunit 37002701 "Label Worksheet Management"
{
    // PRW16.00.06
    // P8001047, Columbus IT, Jack Reynolds, 30 MAR 12
    //   Receiving Labels
    // 
    // PRW17.00
    // P8001233, Columbus IT, Jack Reynolds, 24 OCT 13
    //   Support for label worksheet


    trigger OnRun()
    begin
    end;

    procedure RunWorksheet(var LabelWorksheetLine: Record "Label Worksheet Line" temporary)
    var
        LabelWorksheet: Page "Label Worksheet";
    begin
        LabelWorksheet.LoadData(LabelWorksheetLine);
        LabelWorksheet.Run;
    end;

    procedure WorksheetLinesForWhseReq(var WarehouseRequest: Record "Warehouse Request"; var LabelWorksheetLine: Record "Label Worksheet Line" temporary)
    var
        WarehouseRequest2: Record "Warehouse Request";
        LabelWorksheetLine2: Record "Label Worksheet Line" temporary;
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        LineOffset: Integer;
    begin
        LabelWorksheetLine.Reset;
        LabelWorksheetLine.DeleteAll;
        LabelWorksheetLine."Line No." := 0;

        WarehouseRequest2.Copy(WarehouseRequest);

        if WarehouseRequest2.FindSet then
            repeat
                if WarehouseRequest2.Type = WarehouseRequest2.Type::Inbound then
                    case WarehouseRequest2."Source Type" of
                        DATABASE::"Sales Line":
                            if WarehouseRequest2."Source Subtype" = SalesLine."Document Type"::"Return Order" then begin
                                SalesLine.SetRange("Document Type", WarehouseRequest2."Source Subtype");
                                SalesLine.SetRange("Document No.", WarehouseRequest2."Source No.");
                                SalesLine.SetRange("Location Code", WarehouseRequest2."Location Code");
                                WorksheetLinesForSalesLine(SalesLine, LabelWorksheetLine2);
                            end;

                        DATABASE::"Purchase Line":
                            if WarehouseRequest2."Source Subtype" = PurchLine."Document Type"::Order then begin
                                PurchLine.SetRange("Document Type", WarehouseRequest2."Source Subtype");
                                PurchLine.SetRange("Document No.", WarehouseRequest2."Source No.");
                                PurchLine.SetRange("Location Code", WarehouseRequest2."Location Code");
                                WorksheetLinesForPurchLine(PurchLine, LabelWorksheetLine2);
                            end;

                        DATABASE::"Transfer Line":
                            begin
                                TransLine.SetRange("Document No.", WarehouseRequest2."Source No.");
                                WorksheetLinesForTransLine(TransLine, LabelWorksheetLine2);
                            end;
                    end;

                LineOffset := LabelWorksheetLine."Line No.";
                if LabelWorksheetLine2.FindSet then
                    repeat
                        LabelWorksheetLine := LabelWorksheetLine2;
                        LabelWorksheetLine."Line No." += LineOffset;
                        LabelWorksheetLine.Insert;
                    until LabelWorksheetLine2.Next = 0;
            until WarehouseRequest2.Next = 0;
    end;

    procedure WorksheetLinesForPurchHdr(var PurchHeader: Record "Purchase Header"; var LabelWorksheetLine: Record "Label Worksheet Line" temporary)
    var
        PurchHeader2: Record "Purchase Header";
        LabelWorksheetLine2: Record "Label Worksheet Line" temporary;
        PurchLine: Record "Purchase Line";
        LineOffset: Integer;
    begin
        LabelWorksheetLine.Reset;
        LabelWorksheetLine.DeleteAll;
        LabelWorksheetLine."Line No." := 0;

        PurchHeader2.Copy(PurchHeader);
        PurchHeader2.SetRange("Document Type", PurchHeader2."Document Type"::Order);

        if PurchHeader2.FindSet then
            repeat
                PurchLine.SetRange("Document Type", PurchHeader2."Document Type");
                PurchLine.SetRange("Document No.", PurchHeader2."No.");
                PurchHeader2.CopyFilter("Location Filter", PurchLine."Location Code");
                WorksheetLinesForPurchLine(PurchLine, LabelWorksheetLine2);

                LineOffset := LabelWorksheetLine."Line No.";
                if LabelWorksheetLine2.FindSet then
                    repeat
                        LabelWorksheetLine := LabelWorksheetLine2;
                        LabelWorksheetLine."Line No." += LineOffset;
                        LabelWorksheetLine.Insert;
                    until LabelWorksheetLine2.Next = 0;
            until PurchHeader2.Next = 0;
    end;

    local procedure WorksheetLinesForPurchLine(var PurchLine: Record "Purchase Line"; var LabelWorksheetLine: Record "Label Worksheet Line" temporary)
    var
        PurchLine2: Record "Purchase Line";
        ReservEntry: Record "Reservation Entry";
        TempReservEntry: Record "Reservation Entry" temporary;
        PurchReserv: Codeunit "Purch. Line-Reserve";
        Quantity: Decimal;
    begin
        LabelWorksheetLine.Reset;
        LabelWorksheetLine.DeleteAll;
        LabelWorksheetLine."Line No." := 0;

        PurchLine2.Copy(PurchLine);
        PurchLine2.SetRange(Type, PurchLine2.Type::Item);
        PurchLine2.SetFilter("No.", '<>%1', '');
        PurchLine2.SetFilter("Outstanding Quantity", '>0');
        if PurchLine2.FindSet then
            repeat
                LabelWorksheetLine.Init;
                LabelWorksheetLine.Validate("Item No.", PurchLine2."No.");
                LabelWorksheetLine."Variant Code" := PurchLine2."Variant Code";
                LabelWorksheetLine."Source Table" := DATABASE::"Purchase Line";
                LabelWorksheetLine."Source Type" := PurchLine2."Document Type";
                LabelWorksheetLine."Source Document No." := PurchLine2."Document No.";
                LabelWorksheetLine."Source Line No." := PurchLine2."Line No.";
                LabelWorksheetLine."Unit of Measure Code" := PurchLine2."Unit of Measure Code";
                LabelWorksheetLine."Qty. per Unit of Measure" := PurchLine2."Qty. per Unit of Measure";
                LabelWorksheetLine.Validate("Label Unit of Measure Code", PurchLine2."Label Unit of Measure Code");

                if LabelWorksheetLine."Lot Tracked" then begin
                    PurchLine2.SetReservationFilters(ReservEntry); // P800131478
                    SumReservEntryByLot(ReservEntry, TempReservEntry);
                    if TempReservEntry.FindSet then
                        repeat
                            LabelWorksheetLine."Line No." += 1;
                            LabelWorksheetLine.Validate("Lot No.", TempReservEntry."Lot No.");
                            Quantity := TempReservEntry.Quantity;
                            if PurchLine2."Outstanding Quantity" < Quantity then
                                Quantity := PurchLine2."Outstanding Quantity";
                            PurchLine2."Outstanding Quantity" -= Quantity;
                            LabelWorksheetLine.Validate(Quantity, Quantity);
                            LabelWorksheetLine.Insert;
                        until TempReservEntry.Next = 0;
                end;
                if PurchLine2."Outstanding Quantity" > 0 then begin
                    LabelWorksheetLine."Line No." += 1;
                    LabelWorksheetLine.Validate("Lot No.", '');
                    LabelWorksheetLine.Validate(Quantity, PurchLine2."Outstanding Quantity");
                    LabelWorksheetLine.Insert;
                end;
            until PurchLine2.Next = 0;
    end;

    procedure WorksheetLinesForSalesHdr(var SalesHeader: Record "Sales Header"; var LabelWorksheetLine: Record "Label Worksheet Line" temporary)
    var
        SalesHeader2: Record "Sales Header";
        LabelWorksheetLine2: Record "Label Worksheet Line" temporary;
        SalesLine: Record "Sales Line";
        LineOffset: Integer;
    begin
        LabelWorksheetLine.Reset;
        LabelWorksheetLine.DeleteAll;
        LabelWorksheetLine."Line No." := 0;

        SalesHeader2.Copy(SalesHeader);
        SalesHeader2.SetRange("Document Type", SalesHeader2."Document Type"::"Return Order");

        if SalesHeader2.FindSet then
            repeat
                SalesLine.SetRange("Document Type", SalesHeader2."Document Type");
                SalesLine.SetRange("Document No.", SalesHeader2."No.");
                SalesHeader2.CopyFilter("Location Filter", SalesLine."Location Code");
                WorksheetLinesForSalesLine(SalesLine, LabelWorksheetLine2);

                LineOffset := LabelWorksheetLine."Line No.";
                if LabelWorksheetLine2.FindSet then
                    repeat
                        LabelWorksheetLine := LabelWorksheetLine2;
                        LabelWorksheetLine."Line No." += LineOffset;
                        LabelWorksheetLine.Insert;
                    until LabelWorksheetLine2.Next = 0;
            until SalesHeader2.Next = 0;
    end;

    local procedure WorksheetLinesForSalesLine(var SalesLine: Record "Sales Line"; var LabelWorksheetLine: Record "Label Worksheet Line" temporary)
    var
        SalesLine2: Record "Sales Line";
        ReservEntry: Record "Reservation Entry";
        TempReservEntry: Record "Reservation Entry" temporary;
        SalesReserv: Codeunit "Sales Line-Reserve";
        Quantity: Decimal;
    begin
        LabelWorksheetLine.Reset;
        LabelWorksheetLine.DeleteAll;
        LabelWorksheetLine."Line No." := 0;

        SalesLine2.Copy(SalesLine);
        SalesLine2.SetRange(Type, SalesLine2.Type::Item);
        SalesLine2.SetFilter("No.", '<>%1', '');
        SalesLine2.SetFilter("Outstanding Quantity", '>0');
        if SalesLine2.FindSet then
            repeat
                LabelWorksheetLine.Init;
                LabelWorksheetLine.Validate("Item No.", SalesLine2."No.");
                LabelWorksheetLine."Variant Code" := SalesLine2."Variant Code";
                LabelWorksheetLine."Source Table" := DATABASE::"Sales Line";
                LabelWorksheetLine."Source Type" := SalesLine2."Document Type";
                LabelWorksheetLine."Source Document No." := SalesLine2."Document No.";
                LabelWorksheetLine."Source Line No." := SalesLine2."Line No.";
                LabelWorksheetLine."Unit of Measure Code" := SalesLine2."Unit of Measure Code";
                LabelWorksheetLine."Qty. per Unit of Measure" := SalesLine2."Qty. per Unit of Measure";
                LabelWorksheetLine.Validate("Label Unit of Measure Code", SalesLine2."Label Unit of Measure Code");

                if LabelWorksheetLine."Lot Tracked" then begin
                    SalesLine2.SetReservationFilters(ReservEntry); // P800131478
                    SumReservEntryByLot(ReservEntry, TempReservEntry);
                    if TempReservEntry.FindSet then
                        repeat
                            LabelWorksheetLine."Line No." += 1;
                            LabelWorksheetLine.Validate("Lot No.", TempReservEntry."Lot No.");
                            Quantity := TempReservEntry.Quantity;
                            if SalesLine2."Outstanding Quantity" < Quantity then
                                Quantity := SalesLine2."Outstanding Quantity";
                            SalesLine2."Outstanding Quantity" -= Quantity;
                            LabelWorksheetLine.Validate(Quantity, Quantity);
                            LabelWorksheetLine.Insert;
                        until TempReservEntry.Next = 0;
                end;
                if SalesLine2."Outstanding Quantity" > 0 then begin
                    LabelWorksheetLine."Line No." += 1;
                    LabelWorksheetLine.Validate("Lot No.", '');
                    LabelWorksheetLine.Validate(Quantity, SalesLine2."Outstanding Quantity");
                    LabelWorksheetLine.Insert;
                end;
            until SalesLine2.Next = 0;
    end;

    procedure WorksheetLinesForTransHdr(var TransHeader: Record "Transfer Header"; var LabelWorksheetLine: Record "Label Worksheet Line" temporary)
    var
        TransHeader2: Record "Transfer Header";
        LabelWorksheetLine2: Record "Label Worksheet Line" temporary;
        TransLine: Record "Transfer Line";
        LineOffset: Integer;
    begin
        LabelWorksheetLine.Reset;
        LabelWorksheetLine.DeleteAll;
        LabelWorksheetLine."Line No." := 0;

        TransHeader2.Copy(TransHeader);

        if TransHeader2.FindSet then
            repeat
                TransLine.SetRange("Document No.", TransHeader2."No.");
                WorksheetLinesForTransLine(TransLine, LabelWorksheetLine2);

                LineOffset := LabelWorksheetLine."Line No.";
                if LabelWorksheetLine2.FindSet then
                    repeat
                        LabelWorksheetLine := LabelWorksheetLine2;
                        LabelWorksheetLine."Line No." += LineOffset;
                        LabelWorksheetLine.Insert;
                    until LabelWorksheetLine2.Next = 0;
            until TransHeader2.Next = 0;
    end;

    local procedure WorksheetLinesForTransLine(var TransLine: Record "Transfer Line"; var LabelWorksheetLine: Record "Label Worksheet Line" temporary)
    var
        TransLine2: Record "Transfer Line";
        ReservEntry: Record "Reservation Entry";
        TempReservEntry: Record "Reservation Entry" temporary;
        TransReserv: Codeunit "Transfer Line-Reserve";
        Quantity: Decimal;
    begin
        LabelWorksheetLine.Reset;
        LabelWorksheetLine.DeleteAll;
        LabelWorksheetLine."Line No." := 0;

        TransLine2.Copy(TransLine);
        TransLine2.SetRange(Type, TransLine2.Type::Item);
        TransLine2.SetFilter("Item No.", '<>%1', '');
        TransLine2.SetFilter("Qty. in Transit", '>0');
        if TransLine2.FindSet then
            repeat
                LabelWorksheetLine.Init;
                LabelWorksheetLine.Validate("Item No.", TransLine2."Item No.");
                LabelWorksheetLine."Variant Code" := TransLine2."Variant Code";
                LabelWorksheetLine."Source Table" := DATABASE::"Transfer Line";
                LabelWorksheetLine."Source Type" := 1;
                LabelWorksheetLine."Source Document No." := TransLine2."Document No.";
                LabelWorksheetLine."Source Line No." := TransLine2."Line No.";
                LabelWorksheetLine."Unit of Measure Code" := TransLine2."Unit of Measure Code";
                LabelWorksheetLine."Qty. per Unit of Measure" := TransLine2."Qty. per Unit of Measure";
                LabelWorksheetLine.Validate("Label Unit of Measure Code", TransLine2."Label Unit of Measure Code");

                if LabelWorksheetLine."Lot Tracked" then begin
                    TransLine2.SetReservationFilters(ReservEntry, "Transfer Direction"::Inbound); // P800131478
                    SumReservEntryByLot(ReservEntry, TempReservEntry);
                    if TempReservEntry.FindSet then
                        repeat
                            LabelWorksheetLine."Line No." += 1;
                            LabelWorksheetLine.Validate("Lot No.", TempReservEntry."Lot No.");
                            Quantity := TempReservEntry.Quantity;
                            if TransLine2."Qty. in Transit" < Quantity then
                                Quantity := TransLine2."Qty. in Transit";
                            TransLine2."Qty. in Transit" -= Quantity;
                            LabelWorksheetLine.Validate(Quantity, Quantity);
                            LabelWorksheetLine.Insert;
                        until TempReservEntry.Next = 0;
                end;
                if TransLine2."Qty. in Transit" > 0 then begin
                    LabelWorksheetLine."Line No." += 1;
                    LabelWorksheetLine.Validate("Lot No.", '');
                    LabelWorksheetLine.Validate(Quantity, TransLine2."Qty. in Transit");
                    LabelWorksheetLine.Insert;
                end;
            until TransLine2.Next = 0;
    end;

    procedure WorksheetLinesForPurchRcpt(var PurchRcptHeader: Record "Purch. Rcpt. Header"; var LabelWorksheetLine: Record "Label Worksheet Line" temporary)
    var
        PurchRcptHeader2: Record "Purch. Rcpt. Header";
        LabelWorksheetLine2: Record "Label Worksheet Line" temporary;
        PurchRcptLine: Record "Purch. Rcpt. Line";
        LineOffset: Integer;
    begin
        LabelWorksheetLine.Reset;
        LabelWorksheetLine.DeleteAll;
        LabelWorksheetLine."Line No." := 0;

        PurchRcptHeader2.Copy(PurchRcptHeader);

        if PurchRcptHeader2.FindSet then
            repeat
                PurchRcptLine.SetRange("Document No.", PurchRcptHeader2."No.");
                WorksheetLinesForPurchRcptLine(PurchRcptLine, PurchRcptHeader2."Posting Date", LabelWorksheetLine2);

                LineOffset := LabelWorksheetLine."Line No.";
                if LabelWorksheetLine2.FindSet then
                    repeat
                        LabelWorksheetLine := LabelWorksheetLine2;
                        LabelWorksheetLine."Line No." += LineOffset;
                        LabelWorksheetLine.Insert;
                    until LabelWorksheetLine2.Next = 0;
            until PurchRcptHeader2.Next = 0;
    end;

    local procedure WorksheetLinesForPurchRcptLine(var PurchRcptLine: Record "Purch. Rcpt. Line"; PostingDate: Date; var LabelWorksheetLine: Record "Label Worksheet Line" temporary)
    var
        PurchRcptLine2: Record "Purch. Rcpt. Line";
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
    begin
        LabelWorksheetLine.Reset;
        LabelWorksheetLine.DeleteAll;
        LabelWorksheetLine."Line No." := 0;

        PurchRcptLine2.Copy(PurchRcptLine);
        PurchRcptLine2.SetRange(Type, PurchRcptLine2.Type::Item);
        PurchRcptLine2.SetFilter("No.", '<>%1', '');
        PurchRcptLine2.SetFilter(Quantity, '>0');
        if PurchRcptLine2.FindSet then
            repeat
                LabelWorksheetLine.Init;
                LabelWorksheetLine.Validate("Item No.", PurchRcptLine2."No.");
                LabelWorksheetLine."Variant Code" := PurchRcptLine2."Variant Code";
                LabelWorksheetLine."Source Table" := DATABASE::"Purch. Rcpt. Line";
                LabelWorksheetLine."Source Document No." := PurchRcptLine2."Document No.";
                LabelWorksheetLine."Source Line No." := PurchRcptLine2."Line No.";
                LabelWorksheetLine."Unit of Measure Code" := PurchRcptLine2."Unit of Measure Code";
                LabelWorksheetLine."Qty. per Unit of Measure" := PurchRcptLine2."Qty. per Unit of Measure";
                LabelWorksheetLine.Validate("Label Unit of Measure Code", PurchRcptLine2."Label Unit of Measure Code");

                SumPostedTrackingByLot(PurchRcptLine2."Item Rcpt. Entry No.", PurchRcptLine2."Quantity (Base)",
                  DATABASE::"Purch. Rcpt. Line", PurchRcptLine2."Document No.", PurchRcptLine2."Line No.", TempItemLedgEntry);
                if TempItemLedgEntry.FindSet then
                    repeat
                        LabelWorksheetLine."Line No." += 1;
                        LabelWorksheetLine.Validate("Lot No.", TempItemLedgEntry."Lot No.");
                        LabelWorksheetLine.Validate(Quantity,
                          Round(TempItemLedgEntry.Quantity / LabelWorksheetLine."Qty. per Unit of Measure", 0.00001));
                        if LabelWorksheetLine."Document Date" = 0D then
                            LabelWorksheetLine."Document Date" := PostingDate;
                        LabelWorksheetLine."Document Date Editable" := false;
                        LabelWorksheetLine.Insert;
                    until TempItemLedgEntry.Next = 0;
            until PurchRcptLine2.Next = 0;
    end;

    procedure WorksheetLinesForSalesRcpt(var SalesRcptHeader: Record "Return Receipt Header"; var LabelWorksheetLine: Record "Label Worksheet Line" temporary)
    var
        SalesRcptHeader2: Record "Return Receipt Header";
        LabelWorksheetLine2: Record "Label Worksheet Line" temporary;
        SalesRcptLine: Record "Return Receipt Line";
        LineOffset: Integer;
    begin
        LabelWorksheetLine.Reset;
        LabelWorksheetLine.DeleteAll;
        LabelWorksheetLine."Line No." := 0;

        SalesRcptHeader2.Copy(SalesRcptHeader);

        if SalesRcptHeader2.FindSet then
            repeat
                SalesRcptLine.SetRange("Document No.", SalesRcptHeader2."No.");
                WorksheetLinesForSalesRcptLine(SalesRcptLine, SalesRcptHeader2."Posting Date", LabelWorksheetLine2);

                LineOffset := LabelWorksheetLine."Line No.";
                if LabelWorksheetLine2.FindSet then
                    repeat
                        LabelWorksheetLine := LabelWorksheetLine2;
                        LabelWorksheetLine."Line No." += LineOffset;
                        LabelWorksheetLine.Insert;
                    until LabelWorksheetLine2.Next = 0;
            until SalesRcptHeader2.Next = 0;
    end;

    local procedure WorksheetLinesForSalesRcptLine(var SalesRcptLine: Record "Return Receipt Line"; PostingDate: Date; var LabelWorksheetLine: Record "Label Worksheet Line" temporary)
    var
        SalesRcptLine2: Record "Return Receipt Line";
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
    begin
        LabelWorksheetLine.Reset;
        LabelWorksheetLine.DeleteAll;
        LabelWorksheetLine."Line No." := 0;

        SalesRcptLine2.Copy(SalesRcptLine);
        SalesRcptLine2.SetRange(Type, SalesRcptLine2.Type::Item);
        SalesRcptLine2.SetFilter("No.", '<>%1', '');
        SalesRcptLine2.SetFilter(Quantity, '>0');
        if SalesRcptLine2.FindSet then
            repeat
                LabelWorksheetLine.Init;
                LabelWorksheetLine.Validate("Item No.", SalesRcptLine2."No.");
                LabelWorksheetLine."Variant Code" := SalesRcptLine2."Variant Code";
                LabelWorksheetLine."Source Table" := DATABASE::"Return Receipt Line";
                LabelWorksheetLine."Source Document No." := SalesRcptLine2."Document No.";
                LabelWorksheetLine."Source Line No." := SalesRcptLine2."Line No.";
                LabelWorksheetLine."Unit of Measure Code" := SalesRcptLine2."Unit of Measure Code";
                LabelWorksheetLine."Qty. per Unit of Measure" := SalesRcptLine2."Qty. per Unit of Measure";
                LabelWorksheetLine.Validate("Label Unit of Measure Code", SalesRcptLine2."Label Unit of Measure Code");

                SumPostedTrackingByLot(SalesRcptLine2."Item Rcpt. Entry No.", SalesRcptLine2."Quantity (Base)",
                  DATABASE::"Return Receipt Line", SalesRcptLine2."Document No.", SalesRcptLine2."Line No.", TempItemLedgEntry);
                if TempItemLedgEntry.FindSet then
                    repeat
                        LabelWorksheetLine."Line No." += 1;
                        LabelWorksheetLine.Validate("Lot No.", TempItemLedgEntry."Lot No.");
                        LabelWorksheetLine.Validate(Quantity,
                          Round(TempItemLedgEntry.Quantity / LabelWorksheetLine."Qty. per Unit of Measure", 0.00001));
                        if LabelWorksheetLine."Document Date" = 0D then
                            LabelWorksheetLine."Document Date" := PostingDate;
                        LabelWorksheetLine."Document Date Editable" := false;
                        LabelWorksheetLine.Insert;
                    until TempItemLedgEntry.Next = 0;
            until SalesRcptLine2.Next = 0;
    end;

    procedure WorksheetLinesForTransRcpt(var TransRcptHeader: Record "Transfer Receipt Header"; var LabelWorksheetLine: Record "Label Worksheet Line" temporary)
    var
        TransRcptHeader2: Record "Transfer Receipt Header";
        LabelWorksheetLine2: Record "Label Worksheet Line" temporary;
        TransRcptLine: Record "Transfer Receipt Line";
        LineOffset: Integer;
    begin
        LabelWorksheetLine.Reset;
        LabelWorksheetLine.DeleteAll;
        LabelWorksheetLine."Line No." := 0;

        TransRcptHeader2.Copy(TransRcptHeader);

        if TransRcptHeader2.FindSet then
            repeat
                TransRcptLine.SetRange("Document No.", TransRcptHeader2."No.");
                WorksheetLinesForTransRcptLine(TransRcptLine, TransRcptHeader2."Posting Date", LabelWorksheetLine2);

                LineOffset := LabelWorksheetLine."Line No.";
                if LabelWorksheetLine2.FindSet then
                    repeat
                        LabelWorksheetLine := LabelWorksheetLine2;
                        LabelWorksheetLine."Line No." += LineOffset;
                        LabelWorksheetLine.Insert;
                    until LabelWorksheetLine2.Next = 0;
            until TransRcptHeader2.Next = 0;
    end;

    local procedure WorksheetLinesForTransRcptLine(var TransRcptLine: Record "Transfer Receipt Line"; PostingDate: Date; var LabelWorksheetLine: Record "Label Worksheet Line" temporary)
    var
        TransRcptLine2: Record "Transfer Receipt Line";
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
    begin
        LabelWorksheetLine.Reset;
        LabelWorksheetLine.DeleteAll;
        LabelWorksheetLine."Line No." := 0;

        TransRcptLine2.Copy(TransRcptLine);
        TransRcptLine2.SetRange(Type, TransRcptLine2.Type::Item);
        TransRcptLine2.SetFilter("Item No.", '<>%1', '');
        TransRcptLine2.SetFilter(Quantity, '>0');
        if TransRcptLine2.FindSet then
            repeat
                LabelWorksheetLine.Init;
                LabelWorksheetLine.Validate("Item No.", TransRcptLine2."Item No.");
                LabelWorksheetLine."Variant Code" := TransRcptLine2."Variant Code";
                LabelWorksheetLine."Source Table" := DATABASE::"Transfer Receipt Line";
                LabelWorksheetLine."Source Document No." := TransRcptLine2."Document No.";
                LabelWorksheetLine."Source Line No." := TransRcptLine2."Line No.";
                LabelWorksheetLine."Unit of Measure Code" := TransRcptLine2."Unit of Measure Code";
                LabelWorksheetLine."Qty. per Unit of Measure" := TransRcptLine2."Qty. per Unit of Measure";
                LabelWorksheetLine.Validate("Label Unit of Measure Code", TransRcptLine2."Label Unit of Measure Code");

                SumPostedTrackingByLot(TransRcptLine2."Item Rcpt. Entry No.", TransRcptLine2."Quantity (Base)",
                  DATABASE::"Transfer Receipt Line", TransRcptLine2."Document No.", TransRcptLine2."Line No.", TempItemLedgEntry);
                if TempItemLedgEntry.FindSet then
                    repeat
                        LabelWorksheetLine."Line No." += 1;
                        LabelWorksheetLine.Validate("Lot No.", TempItemLedgEntry."Lot No.");
                        LabelWorksheetLine.Validate(Quantity,
                          Round(TempItemLedgEntry.Quantity / LabelWorksheetLine."Qty. per Unit of Measure", 0.00001));
                        if LabelWorksheetLine."Document Date" = 0D then
                            LabelWorksheetLine."Document Date" := PostingDate;
                        LabelWorksheetLine."Document Date Editable" := false;
                        LabelWorksheetLine.Insert;
                    until TempItemLedgEntry.Next = 0;
            until TransRcptLine2.Next = 0;
    end;

    procedure WorksheetLinesForProdOrder(var ProdOrder: Record "Production Order"; var LabelWorksheetLine: Record "Label Worksheet Line" temporary)
    var
        ProdOrder2: Record "Production Order";
        LabelWorksheetLine2: Record "Label Worksheet Line" temporary;
        ProdOrderLine: Record "Prod. Order Line";
        LineOffset: Integer;
    begin
        LabelWorksheetLine.Reset;
        LabelWorksheetLine.DeleteAll;
        LabelWorksheetLine."Line No." := 0;

        ProdOrder2.Copy(ProdOrder);

        if ProdOrder2.FindSet then
            repeat
                ProdOrderLine.SetRange(Status, ProdOrder2.Status);
                ProdOrderLine.SetRange("Prod. Order No.", ProdOrder2."No.");
                WorksheetLinesForProdOrderLine(ProdOrderLine, LabelWorksheetLine2);

                LineOffset := LabelWorksheetLine."Line No.";
                if LabelWorksheetLine2.FindSet then
                    repeat
                        LabelWorksheetLine := LabelWorksheetLine2;
                        LabelWorksheetLine."Line No." += LineOffset;
                        LabelWorksheetLine.Insert;
                    until LabelWorksheetLine2.Next = 0;
            until ProdOrder2.Next = 0;
    end;

    local procedure WorksheetLinesForProdOrderLine(var ProdOrderLine: Record "Prod. Order Line"; var LabelWorksheetLine: Record "Label Worksheet Line" temporary)
    var
        ProdOrderLine2: Record "Prod. Order Line";
        ReservEntry: Record "Reservation Entry";
        TempReservEntry: Record "Reservation Entry" temporary;
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        ProdOrderLineReserv: Codeunit "Prod. Order Line-Reserve";
        Quantity: Decimal;
    begin
        LabelWorksheetLine.Reset;
        LabelWorksheetLine.DeleteAll;
        LabelWorksheetLine."Line No." := 0;

        ProdOrderLine2.Copy(ProdOrderLine);
        case ProdOrderLine2.GetRangeMax(Status) of
            ProdOrderLine2.Status::Released:
                ProdOrderLine2.SetFilter("Remaining Quantity", '>0');
            ProdOrderLine2.Status::Finished:
                ProdOrderLine2.SetFilter("Finished Quantity", '>0');
        end;

        if ProdOrderLine2.FindSet then
            repeat
                LabelWorksheetLine.Init;
                LabelWorksheetLine.Validate("Item No.", ProdOrderLine2."Item No.");
                LabelWorksheetLine."Variant Code" := ProdOrderLine2."Variant Code";
                LabelWorksheetLine."Source Table" := DATABASE::"Prod. Order Line";
                LabelWorksheetLine."Source Type" := ProdOrderLine2.Status;
                LabelWorksheetLine."Source Document No." := ProdOrderLine2."Prod. Order No.";
                LabelWorksheetLine."Source Line No." := ProdOrderLine2."Line No.";
                LabelWorksheetLine."Unit of Measure Code" := ProdOrderLine2."Unit of Measure Code";
                LabelWorksheetLine."Qty. per Unit of Measure" := ProdOrderLine2."Qty. per Unit of Measure";
                LabelWorksheetLine.Validate("Label Unit of Measure Code", ProdOrderLine2."Label Unit of Measure Code");

                case ProdOrderLine2.Status of
                    ProdOrderLine2.Status::Released:
                        begin
                            if LabelWorksheetLine."Lot Tracked" then begin
                                ProdOrderLine2.SetReservationFilters(ReservEntry); // P800131478
                                SumReservEntryByLot(ReservEntry, TempReservEntry);
                                if TempReservEntry.FindSet then
                                    repeat
                                        LabelWorksheetLine."Line No." += 1;
                                        LabelWorksheetLine.Validate("Lot No.", TempReservEntry."Lot No.");
                                        Quantity := TempReservEntry.Quantity;
                                        if ProdOrderLine2."Remaining Quantity" < Quantity then
                                            Quantity := ProdOrderLine2."Remaining Quantity";
                                        ProdOrderLine2."Remaining Quantity" -= Quantity;
                                        LabelWorksheetLine.Validate(Quantity, Quantity);
                                        LabelWorksheetLine.Insert;
                                    until TempReservEntry.Next = 0;
                            end;
                            if ProdOrderLine2."Remaining Quantity" > 0 then begin
                                LabelWorksheetLine."Line No." += 1;
                                LabelWorksheetLine.Validate("Lot No.", '');
                                LabelWorksheetLine.Validate(Quantity, ProdOrderLine2."Remaining Quantity");
                                LabelWorksheetLine.Insert;
                            end;
                        end;

                    ProdOrderLine2.Status::Finished:
                        begin
                            if LabelWorksheetLine."Lot Tracked" then begin
                                SumPostedTrackingForProdOrderByLot(ProdOrderLine2."Prod. Order No.", ProdOrderLine2."Line No.", TempItemLedgEntry);
                                if TempItemLedgEntry.FindSet then
                                    repeat
                                        LabelWorksheetLine."Line No." += 1;
                                        LabelWorksheetLine.Validate("Lot No.", TempItemLedgEntry."Lot No.");
                                        LabelWorksheetLine.Validate(Quantity,
                                          Round(TempItemLedgEntry.Quantity / LabelWorksheetLine."Qty. per Unit of Measure", 0.00001));
                                        LabelWorksheetLine.Insert;
                                    until TempItemLedgEntry.Next = 0;
                            end else begin
                                LabelWorksheetLine."Line No." += 1;
                                LabelWorksheetLine.Validate("Lot No.", '');
                                LabelWorksheetLine.Validate(Quantity, ProdOrderLine2."Finished Quantity");
                                LabelWorksheetLine.Insert;
                            end;
                        end;
                end;
            until ProdOrderLine2.Next = 0;
    end;

    local procedure SumReservEntryByLot(var ReservEntry: Record "Reservation Entry"; var TempReservEntry: Record "Reservation Entry" temporary)
    begin
        TempReservEntry.Reset;
        TempReservEntry.DeleteAll;
        TempReservEntry."Entry No." := 0;

        ReservEntry.SetCurrentKey("Source Type", "Source ID", "Source Batch Name", "Source Ref. No.", "Lot No.", "Serial No.");
        ReservEntry.SetRange(Positive, true);
        ReservEntry.SetFilter("Lot No.", '<>%1', '');
        if ReservEntry.FindSet then
            repeat
                ReservEntry.SetRange("Lot No.", ReservEntry."Lot No.");
                TempReservEntry.Init;
                TempReservEntry."Entry No." += 1;
                TempReservEntry."Lot No." := ReservEntry."Lot No.";
                repeat
                    TempReservEntry.Quantity += ReservEntry.Quantity;
                until ReservEntry.Next = 0;
                TempReservEntry.Insert;
                ReservEntry.SetRange("Lot No.");
            until ReservEntry.Next = 0;
    end;

    local procedure SumPostedTrackingByLot(EntryNo: Integer; QuantityBase: Decimal; TableNo: Integer; DocNo: Code[20]; LineNo: Integer; var TempItemLedgEntry: Record "Item Ledger Entry" temporary)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemEntryRelation: Record "Item Entry Relation";
    begin
        TempItemLedgEntry.Reset;
        TempItemLedgEntry.DeleteAll;
        TempItemLedgEntry.SetCurrentKey("Item No.", "Lot No.", "Posting Date");

        if EntryNo <> 0 then begin
            TempItemLedgEntry.Quantity := QuantityBase;
            TempItemLedgEntry.Insert;
        end else begin
            ItemEntryRelation.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Ref. No.");
            ItemEntryRelation.SetRange("Source Type", TableNo);
            ItemEntryRelation.SetRange("Source ID", DocNo);
            ItemEntryRelation.SetRange("Source Ref. No.", LineNo);
            if ItemEntryRelation.FindSet then
                repeat
                    ItemLedgEntry.Get(ItemEntryRelation."Item Entry No.");
                    TempItemLedgEntry.SetRange("Lot No.", ItemLedgEntry."Lot No.");
                    if TempItemLedgEntry.Find('-') then begin
                        TempItemLedgEntry.Quantity += ItemLedgEntry.Quantity;
                        TempItemLedgEntry.Modify;
                    end else begin
                        EntryNo += 1;
                        TempItemLedgEntry."Entry No." := EntryNo;
                        TempItemLedgEntry."Lot No." := ItemLedgEntry."Lot No.";
                        TempItemLedgEntry.Quantity := ItemLedgEntry.Quantity;
                        TempItemLedgEntry.Insert;
                    end;
                until ItemEntryRelation.Next = 0;
        end;
        TempItemLedgEntry.SetRange("Lot No.");
    end;

    local procedure SumPostedTrackingForProdOrderByLot(ProdOrderNo: Code[20]; LineNo: Integer; var TempItemLedgEntry: Record "Item Ledger Entry" temporary)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        EntryNo: Integer;
    begin
        TempItemLedgEntry.Reset;
        TempItemLedgEntry.DeleteAll;
        TempItemLedgEntry.SetCurrentKey("Item No.", "Lot No.", "Posting Date");

        ItemLedgEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.",
          "Entry Type", "Prod. Order Comp. Line No.");

        ItemLedgEntry.SetRange("Order Type", ItemLedgEntry."Order Type"::Production);
        ItemLedgEntry.SetRange("Order No.", ProdOrderNo);
        ItemLedgEntry.SetRange("Order Line No.", LineNo);
        ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Output);
        ItemLedgEntry.SetRange("Prod. Order Comp. Line No.", 0);

        if ItemLedgEntry.FindSet then
            repeat
                TempItemLedgEntry.SetRange("Lot No.", ItemLedgEntry."Lot No.");
                if TempItemLedgEntry.Find('-') then begin
                    TempItemLedgEntry.Quantity += ItemLedgEntry.Quantity;
                    TempItemLedgEntry.Modify;
                end else begin
                    EntryNo += 1;
                    TempItemLedgEntry."Entry No." := EntryNo;
                    TempItemLedgEntry."Lot No." := ItemLedgEntry."Lot No.";
                    TempItemLedgEntry.Quantity := ItemLedgEntry.Quantity;
                    TempItemLedgEntry.Insert;
                end;
            until ItemLedgEntry.Next = 0;
    end;
}

