codeunit 37002040 "Off-Invoice Allowance Mgt."
{
    // PR3.70.02
    //   GetOrderAllowances - fix wrong inequality on starting date filter
    // 
    // PR3.70.03
    //   Fix problem calculating remaining allowance on undo
    // 
    // PR3.70.04
    // P8000031A, Myers Nissi, Jack Reynolds, 11 MAY 04
    //   AddAllowanceSalesLines- change SalesHeader parameter so call is by reference
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Support for calculating based on posting location
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80062458, To Increase, Jack Reynolds, 24 JUL 18
    //   Modify GetOrderAllowances to exit if no document number
    //
    // PRW111.00.03
    // P800105603, To-Increase, Jack Reynolds, 03 SEP 20
    //   Fix problem creating and posting off-invoice allowance line
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Permissions = TableData "Sales Shipment Line" = m;

    trigger OnRun()
    begin
    end;

    procedure DeleteOrderAllowances(SalesHeader: Record "Sales Header")
    var
        OrderAllowance: Record "Order Off-Invoice Allowance";
    begin
        OrderAllowance.SetRange("Document Type", SalesHeader."Document Type");
        OrderAllowance.SetRange("Document No.", SalesHeader."No.");
        OrderAllowance.DeleteAll;
    end;

    procedure GetOrderAllowances(SalesHeader: Record "Sales Header")
    var
        AllowanceHeader: Record "Off-Invoice Allowance Header";
        AllowanceLine: Record "Off-Invoice Allowance Line";
        OrderAllowance: Record "Order Off-Invoice Allowance";
    begin
        if SalesHeader."No." = '' then // P80062458
            exit;                        // P80062458
        OrderAllowance.SetRange("Document Type", SalesHeader."Document Type");
        OrderAllowance.SetRange("Document No.", SalesHeader."No.");
        if OrderAllowance.Find('-') then
            repeat
                OrderAllowance.Mark(true);
            until OrderAllowance.Next = 0;

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                AllowanceLine.SetFilter("Document Type", '%1|%2',
                  AllowanceLine."Document Type"::Order, AllowanceLine."Document Type"::Both);
            SalesHeader."Document Type"::Invoice:
                AllowanceLine.SetFilter("Document Type", '%1|%2',
                  AllowanceLine."Document Type"::Invoice, AllowanceLine."Document Type"::Both);
            else
                exit;
        end;
        AllowanceLine.SetFilter("Starting Date", '%1|..%2', 0D, WorkDate); // PR3.70.02

        if AllowanceHeader.Find('-') then begin
            repeat
                OrderAllowance.Init;
                OrderAllowance."Document Type" := SalesHeader."Document Type";
                OrderAllowance."Document No." := SalesHeader."No.";
                OrderAllowance."Allowance Code" := AllowanceHeader.Code;

                AllowanceLine.SetRange("Allowance Code", AllowanceHeader.Code);
                AllowanceLine.SetRange("Sales Type", AllowanceLine."Sales Type"::"All Customers");
                AllowanceLine.SetRange("Sales Code");
                OrderAllowance."Grant Allowance" := AllowanceLine.Find('-');

                if not OrderAllowance."Grant Allowance" then begin
                    AllowanceLine.SetRange("Sales Type", AllowanceLine."Sales Type"::"Customer Price Group");
                    AllowanceLine.SetRange("Sales Code", SalesHeader."Customer Price Group");
                    OrderAllowance."Grant Allowance" := AllowanceLine.Find('-');
                end;

                if not OrderAllowance."Grant Allowance" then begin
                    AllowanceLine.SetRange("Sales Type", AllowanceLine."Sales Type"::Customer);
                    AllowanceLine.SetRange("Sales Code", SalesHeader."Bill-to Customer No.");
                    OrderAllowance."Grant Allowance" := AllowanceLine.Find('-');
                end;

                if OrderAllowance."Grant Allowance" then begin
                    if not OrderAllowance.Insert then begin
                        OrderAllowance.Find('=');
                        OrderAllowance.Mark(false);
                    end;
                end;
            until AllowanceHeader.Next = 0;
        end;

        OrderAllowance.MarkedOnly(true);
        OrderAllowance.DeleteAll;
    end;

    procedure SumSalesLines(SalesHeader: Record "Sales Header"; var Weight: Decimal; var Volume: Decimal; var Quantity: Decimal; var Amount: Decimal; TransType: Code[10])
    var
        SalesLine: Record "Sales Line";
    begin
        // P8000282A - replace DocType and DocNo with SalesHeader
        Weight := 0;
        Volume := 0;
        Quantity := 0;
        Amount := 0;

        SalesLine.SetRange("Document Type", SalesHeader."Document Type"); // P8000282A
        SalesLine.SetRange("Document No.", SalesHeader."No.");            // P8000282A
        SalesLine.SetFilter(Type, '>0');
        SalesLine.SetFilter("Off-Invoice Allowance Code", '=%1', '');
        if SalesHeader."Posting Location Code" <> '' then                          // P8000282A
            SalesLine.SetRange("Location Code", SalesHeader."Posting Location Code"); // P8000282A
        if SalesLine.Find('-') then
            repeat
                IncrementValues(SalesLine, TransType, Weight, Volume, Quantity, Amount);
            until SalesLine.Next = 0;
    end;

    procedure IncrementValues(SalesLine: Record "Sales Line"; TransType: Code[10]; var Weight: Decimal; var Volume: Decimal; var Quantity: Decimal; var Amount: Decimal)
    var
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        LineQtyBase: Decimal;
        LineQtyAlt: Decimal;
    begin
        if SalesLine.Type = SalesLine.Type::Item then begin
            LineQtyBase := SalesLine.GetTransactionQty(SalesLine.FieldNo("Quantity (Base)"), TransType);
            LineQtyAlt := SalesLine.GetTransactionQty(SalesLine.FieldNo("Quantity (Alt.)"), TransType);
            Weight += P800UOMFns.ItemWeight(SalesLine."No.", LineQtyBase, LineQtyAlt);
            Volume += P800UOMFns.ItemVolume(SalesLine."No.", LineQtyBase, LineQtyAlt);
            Quantity += LineQtyBase;
        end;
        if SalesLine.PriceInAlternateUnits then begin
            if SalesLine."Quantity (Alt.)" <> 0 then
                Amount += Round(SalesLine."Line Amount" * LineQtyAlt / SalesLine."Quantity (Alt.)");
        end else begin
            if SalesLine."Quantity (Base)" <> 0 then
                Amount += Round(SalesLine."Line Amount" * LineQtyBase / SalesLine."Quantity (Base)");
        end;
    end;

    procedure CalcAllowance(SalesHeader: Record "Sales Header"; AllowanceCode: Code[10]; Weight: Decimal; Volume: Decimal; Quantity: Decimal; Amount: Decimal; var AllowanceLineToUse: Record "Off-Invoice Allowance Line")
    var
        AllowanceLine: Record "Off-Invoice Allowance Line";
        P800UOMFns: Codeunit "Process 800 UOM Functions";
        Qty: Decimal;
        i: Integer;
    begin
        Clear(AllowanceLineToUse);
        AllowanceLineToUse."Allowance Code" := AllowanceCode;
        AllowanceLine.SetRange("Allowance Code", AllowanceCode);
        if SalesHeader."Price at Shipment" then
            SalesHeader."Order Date" := SalesHeader."Posting Date";
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                AllowanceLine.SetFilter("Document Type", '%1|%2',
                  AllowanceLine."Document Type"::Both, AllowanceLine."Document Type"::Order);
            SalesHeader."Document Type"::Invoice:
                AllowanceLine.SetFilter("Document Type", '%1|%2',
                  AllowanceLine."Document Type"::Both, AllowanceLine."Document Type"::Invoice);
        end;
        AllowanceLine.SetFilter("Starting Date", '%1|..%2', 0D, SalesHeader."Order Date");
        AllowanceLine.SetFilter("Ending Date", '%1|%2..', 0D, SalesHeader."Order Date");

        for i := AllowanceLine."Sales Type"::Customer to AllowanceLine."Sales Type"::"All Customers" do begin
            AllowanceLine.SetRange("Sales Type", i);
            case i of
                AllowanceLine."Sales Type"::Customer:
                    AllowanceLine.SetRange("Sales Code", SalesHeader."Bill-to Customer No.");
                AllowanceLine."Sales Type"::"Customer Price Group":
                    AllowanceLine.SetRange("Sales Code", SalesHeader."Customer Price Group");
                AllowanceLine."Sales Type"::"All Customers":
                    AllowanceLine.SetRange("Sales Code");
            end;
            if AllowanceLine.Find('-') then
                repeat
                    case AllowanceLine.Basis of
                        AllowanceLine.Basis::Weight:
                            Qty := Weight / P800UOMFns.UOMtoMetricBase(AllowanceLine."Unit of Measure Code");
                        AllowanceLine.Basis::Volume:
                            Qty := Volume / P800UOMFns.UOMtoMetricBase(AllowanceLine."Unit of Measure Code");
                        AllowanceLine.Basis::Quantity:
                            Qty := Quantity;
                        AllowanceLine.Basis::Amount:
                            Qty := Amount;
                    end;
                    if Qty > AllowanceLine."Minimum Quantity" then begin
                        case AllowanceLine.Method of
                            AllowanceLine.Method::Amount:
                                if AllowanceLine.Basis = AllowanceLine.Basis::Amount then
                                    AllowanceLine.Allowance := AllowanceLine.Amount
                                else
                                    AllowanceLine.Allowance := Round(Qty * AllowanceLine.Amount);
                            AllowanceLine.Method::Percent:
                                AllowanceLine.Allowance := Round(Qty * AllowanceLine.Amount / 100);
                        end;
                        AllowanceLine.Allowance := Round(AllowanceLine.Allowance);
                        if AllowanceLine.Allowance > AllowanceLineToUse.Allowance then
                            AllowanceLineToUse := AllowanceLine;
                    end;
                until AllowanceLine.Next = 0;
        end;
    end;

    procedure AddAllowanceSalesLines(var SalesHeader: Record "Sales Header"; PostingLocation: Code[10])
    var
        OrderAllowance: Record "Order Off-Invoice Allowance";
        SalesHeader2: Record "Sales Header";
        SalesLine: Record "Sales Line";
        AllowanceLine: Record "Off-Invoice Allowance Line";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        Weight: Decimal;
        Volume: Decimal;
        Quantity: Decimal;
        Amount: Decimal;
    begin
        // PR3.70.04 - change parameter so call is by reference
        // P8000282A - add parameter for posting location
        if not SalesHeader.Ship then
            exit;

        OrderAllowance.SetRange("Document Type", SalesHeader."Document Type");
        OrderAllowance.SetRange("Document No.", SalesHeader."No.");
        OrderAllowance.SetRange("Grant Allowance", true);
        if OrderAllowance.Find('-') then begin
            SalesHeader2 := SalesHeader;
            ReleaseSalesDocument.Reopen(SalesHeader);
            SalesHeader."Posting Location Code" := PostingLocation; // P8000282A

            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if not SalesLine.Find('+') then
                SalesLine."Line No." := 0;
            SumSalesLines(SalesHeader, Weight, Volume, Quantity, Amount, 'SHIP'); // P8000282A
            repeat
                CalcAllowance(SalesHeader, OrderAllowance."Allowance Code", Weight, Volume, Quantity, Amount, AllowanceLine);
                if AllowanceLine.Allowance > 0 then
                    CreateAllowanceLine(SalesHeader, AllowanceLine, SalesLine);
            until OrderAllowance.Next = 0;

            ReleaseSalesDocument.Run(SalesHeader);
            SalesHeader.Invoice := SalesHeader2.Invoice;
            SalesHeader.Ship := SalesHeader2.Ship;
            SalesHeader.Receive := SalesHeader2.Receive;
            SalesHeader."Posting Location Code" := SalesHeader2."Posting Location Code"; // P8000282A
        end;
    end;

    procedure UndoAllowanceSalesLines(ShipmentNo: Code[20])
    var
        ShipmentHeader: Record "Sales Shipment Header";
        ShipmentLine: Record "Sales Shipment Line";
        ShipmentLine2: Record "Sales Shipment Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        AllowanceLine: Record "Off-Invoice Allowance Line";
        Weight: Decimal;
        Volume: Decimal;
        Quantity: Decimal;
        Amount: Decimal;
    begin
        ShipmentLine.SetRange("Document No.", ShipmentNo);
        ShipmentLine.SetFilter(Quantity, '<>0');
        ShipmentLine.SetFilter("Off-Invoice Allowance Code", '<>%1', '');
        if not ShipmentLine.Find('-') then
            exit;

        ShipmentHeader.Get(ShipmentNo);
        SalesHeader.Get(SalesHeader."Document Type"::Order, ShipmentHeader."Order No."); // PR3.70.03
        ShipmentLine2.SetRange("Document No.", ShipmentNo);
        ShipmentLine2.SetFilter(Quantity, '<>0');
        ShipmentLine2.SetFilter("Off-Invoice Allowance Code", '=%1', '');
        if ShipmentLine2.Find('-') then
            repeat
                SalesLine.Get(SalesLine."Document Type"::Order, ShipmentLine2."Order No.", ShipmentLine2."Order Line No.");
                SalesLine."Qty. to Ship (Base)" := ShipmentLine2."Quantity (Base)";
                SalesLine."Qty. to Ship (Alt.)" := ShipmentLine2."Quantity (Alt.)";
                IncrementValues(SalesLine, 'SHIP', Weight, Volume, Quantity, Amount);
            until ShipmentLine2.Next = 0;

        repeat
            SalesLine.Get(SalesLine."Document Type"::Order, ShipmentLine."Order No.", ShipmentLine."Order Line No.");
            CalcAllowance(SalesHeader, ShipmentLine."Off-Invoice Allowance Code", Weight, Volume, Quantity, Amount, AllowanceLine);
            AllowanceLine.Allowance := -AllowanceLine.Allowance;
            if AllowanceLine.Allowance <> SalesLine."Unit Price" then begin
                SalesLine.TestField("Quantity Invoiced", 0);
                SalesLine.Validate("Unit Price", AllowanceLine.Allowance);
                SalesLine.Modify;
                ShipmentLine."Unit Price" := -AllowanceLine.Allowance;
                ShipmentLine.Modify;
            end;
        until ShipmentLine.Next = 0;
    end;

    procedure CreateAllowanceLine(SalesHeader: Record "Sales Header"; AllowanceLine: Record "Off-Invoice Allowance Line"; var SalesLine: Record "Sales Line")
    var
        Allowance: Record "Off-Invoice Allowance Header";
    begin
        Allowance.Get(AllowanceLine."Allowance Code");
        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." += 10000;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", AllowanceLine."G/L Account");
        SalesLine.Description := Allowance.Description;
        if SalesHeader."Posting Location Code" <> '' then                          // P8000282A
            SalesLine.Validate("Location Code", SalesHeader."Posting Location Code"); // P8000282A
        SalesLine.Validate(Quantity, 1);
        // P800105603
        if SalesLine."Qty. to Ship" = 0 then
            SalesLine.Validate("Qty. to Ship", 1);
        // P800105603
        SalesLine.Validate("Unit Price", -AllowanceLine.Allowance);
        SalesLine.Validate("Tax Liable", not AllowanceLine."Tax Excludes Allowance");
        SalesLine.Validate("Allow Invoice Disc.", false);
        SalesLine.Validate("Allow Line Disc.", false);
        SalesLine."Off-Invoice Allowance Code" := Allowance.Code;
        SalesLine.Modify;
    end;

    procedure AllowanceIssued(SalesHeader: Record "Sales Header"; AllowanceCode: Code[10]; ToInvoice: Boolean) Allowance: Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Off-Invoice Allowance Code", AllowanceCode);
        if ToInvoice then
            SalesLine.SetFilter("Qty. to Invoice", '<>0');
        if SalesLine.Find('-') then
            repeat
                Allowance -= SalesLine."Unit Price";
            until SalesLine.Next = 0;
    end;

    procedure TotalAllowance(SalesHeader: Record "Sales Header"; TransType: Code[10]; var Allowance1: Decimal; var Allowance2: Decimal)
    var
        OrderAllowance: Record "Order Off-Invoice Allowance";
        AllowanceLine: Record "Off-Invoice Allowance Line";
        Weight: array[2] of Decimal;
        Volume: array[2] of Decimal;
        Quantity: array[2] of Decimal;
        Amount: array[2] of Decimal;
    begin
        OrderAllowance.SetRange("Document Type", SalesHeader."Document Type");
        OrderAllowance.SetRange("Document No.", SalesHeader."No.");
        if OrderAllowance.Find('-') then
            case TransType of
                'ORDER':
                    begin
                        SumSalesLines(SalesHeader, Weight[1], Volume[1], Quantity[1], Amount[1], 'OUT'); // P8000282A
                        repeat
                            Allowance1 += AllowanceIssued(SalesHeader, OrderAllowance."Allowance Code", false);
                            if OrderAllowance."Grant Allowance" and (Quantity[1] > 0) then begin
                                CalcAllowance(SalesHeader, OrderAllowance."Allowance Code", Weight[1], Volume[1], Quantity[1], Amount[1], AllowanceLine);
                                Allowance2 += AllowanceLine.Allowance;
                            end;
                        until OrderAllowance.Next = 0;
                    end;
                'SHIP':
                    begin
                        SumSalesLines(SalesHeader, Weight[1], Volume[1], Quantity[1], Amount[1], 'SHIP'); // P8000282A
                        repeat
                            if OrderAllowance."Grant Allowance" and (Quantity[1] > 0) then begin
                                CalcAllowance(SalesHeader, OrderAllowance."Allowance Code", Weight[1], Volume[1], Quantity[1], Amount[1], AllowanceLine);
                                Allowance2 += AllowanceLine.Allowance;
                            end;
                        until OrderAllowance.Next = 0;
                    end;
                'INVOICE':
                    begin
                        SumSalesLines(SalesHeader, Weight[1], Volume[1], Quantity[1], Amount[1], 'INVOICE'); // P8000282A
                        SumSalesLines(SalesHeader, Weight[2], Volume[2], Quantity[2], Amount[2], 'SHIPPED'); // P8000282A
                        Weight[1] -= Weight[2];
                        Volume[2] -= Volume[1];
                        Quantity[1] -= Quantity[2];
                        Amount[1] -= Amount[2];
                        repeat
                            Allowance1 += AllowanceIssued(SalesHeader, OrderAllowance."Allowance Code", true);
                            if OrderAllowance."Grant Allowance" and (Quantity[1] > 0) then begin
                                CalcAllowance(SalesHeader, OrderAllowance."Allowance Code", Weight[1], Volume[1], Quantity[1], Amount[1], AllowanceLine);
                                Allowance2 += AllowanceLine.Allowance;
                            end;
                        until OrderAllowance.Next = 0;
                    end;
            end;
    end;
}

