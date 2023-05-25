codeunit 37002061 "Standing Sales Order to Order"
{
    // PR3.70
    //   Off-Invoice Allowances
    // 
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Copy lot preferences to sales line
    // 
    // PR3.70.10
    // P8000210A, Myers Nissi, Jack Reynolds, 11 MAY 05
    //   Copy lot preferences from standing order instead of customer
    // 
    // P8000223A, Myers Nissi, Jack Reynolds, 16 JUN 05
    //   Assign new Alt. Qty. Transaction No. on new sales order lines
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 22 JUN 07
    //   Add COPYLINKS call
    //   Add Prepayment related code, explicit location and ship-to address assignments
    // 
    // PRW16.00.06
    // P8001025, Columbus IT, Jack Reynolds, 25 JAN 12
    //   Refresh header/line fields based on current customer/item/resource ...
    // 
    // P8001096, Columbus IT, Jack Reynolds, 26 SEP 12
    //   Fix problem populating Qty. to Ship
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW18.00.01
    // P8001386, Columbus IT, Jack Reynolds, 26 MAY 15
    //   Refactoring changess for cumulative updates
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 07 DEC 16
    //   Item Category/Product Group
    // 
    // PRW111.00.03
    // P80078010, To-Increase, Gangabhushan, 03 JUL 19
    //   CS00069686 - Standing Order Commnets to No Copy to Orders Created
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    TableNo = "Sales Header";

    trigger OnRun()
    var
        BlankFrequency: DateFormula;
        NewOrderDate: Date;
    begin
        TestField("Document Type", "Document Type"::FOODStandingOrder);

        CalcFields("Delivery Route Order");
        TestField("Delivery Route Order", false);

        // P8000466A
        Cust.Get("Sell-to Customer No.");
        Cust.CheckBlockedCustOnDocs(Cust, "Document Type"::Order, true, false);
        // P8000466A

        SalesSetup.Get;

        if ("Next Order Date" = 0D) or ("Next Order Date" < "Order Date") then
            NewOrderDate := "Order Date"
        else
            NewOrderDate := "Next Order Date";

        if ("Posting Date" <> 0D) and (NewOrderDate > "Posting Date") then
            Error(Text003, FieldCaption("Next Order Date"));

        if not HideValidationDialog then begin
            StandingOrderSalesLine.Reset;
            StandingOrderSalesLine.SetRange("Document Type", "Document Type");
            StandingOrderSalesLine.SetRange("Document No.", "No.");
            StandingOrderSalesLine.SetFilter("Qty. to Ship", '<>0');
            if not StandingOrderSalesLine.Find('-') then
                Error(Text000);
        end;

        if not Confirm(Text001, true, "Document Type", "No.", NewOrderDate) then
            exit;

        "Next Order Date" := NewOrderDate;

        MakeOrder(Rec);

        if ("Order Frequency" <> BlankFrequency) then
            "Next Order Date" := CalcDate("Order Frequency", "Next Order Date");

        Modify(true);

        Message(Text002, SalesOrderHeader."No.", "Document Type", "No.");
        Commit;
    end;

    var
        StandingOrderSalesLine: Record "Sales Line";
        SalesLine: Record "Sales Line";
        SalesOrderHeader: Record "Sales Header";
        SalesOrderLine: Record "Sales Line";
        SalesCommentLine: Record "Sales Comment Line";
        SalesCommentLine2: Record "Sales Comment Line";
        SalesSetup: Record "Sales & Receivables Setup";
        CustCheckCreditLimit: Codeunit "Cust-Check Cr. Limit";
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        LinesCreated: Boolean;
        HideValidationDialog: Boolean;
        Text000: Label 'There are no lines to create.';
        Text001: Label 'Create an Order from %1 %2 for %3?';
        Text002: Label 'Order %1 has been created from %2 %3.';
        Text003: Label '%1 is after the Ending Date.';
        ProcessFns: Codeunit "Process 800 Functions";
        LotSpecFns: Codeunit "Lot Specification Functions";
        xSalesOrderLine: Record "Sales Line";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        Cust: Record Customer;
        PrepmtMgt: Codeunit "Prepayment Mgt.";

    procedure MakeDeliveryOrder(var StandingOrderHeader: Record "Sales Header"; NewOrderDate: Date): Boolean
    begin
        with StandingOrderHeader do begin
            if ("Next Order Date" > NewOrderDate) or
               (("Posting Date" <> 0D) and (NewOrderDate > "Posting Date"))
            then
                exit(false);

            "Next Order Date" := NewOrderDate;

            HideValidationDialog := true;
            MakeOrder(StandingOrderHeader);

            "Next Order Date" := "Next Order Date" + 1;
            Modify(true);

            exit(LinesCreated);
        end;
    end;

    procedure MakeOrder(var StandingOrderHeader: Record "Sales Header")
    begin
        with StandingOrderHeader do begin
            StandingOrderSalesLine.SetRange("Document Type", "Document Type");
            StandingOrderSalesLine.SetRange("Document No.", "No.");
            StandingOrderSalesLine.SetRange(Type, StandingOrderSalesLine.Type::Item);
            StandingOrderSalesLine.SetFilter("No.", '<>%1', '');
            if StandingOrderSalesLine.Find('-') then
                repeat
                    if (StandingOrderSalesLine."Qty. to Ship" > 0) then begin
                        SalesLine := StandingOrderSalesLine;
                        ResetQuantityFields(SalesLine);
                        SalesLine.SuspendStatusCheck(true);
                        SalesLine.Quantity := StandingOrderSalesLine."Qty. to Ship";
                        SalesLine.InitOutstanding;
                        SalesLine."Line No." := 0;
                        if not HideValidationDialog then
                            ItemCheckAvail.SalesLineCheck(SalesLine); // P8001386, P8004516
                        "Amount Including VAT" := "Amount Including VAT" + SalesLine."Amount Including VAT";
                    end;
                until StandingOrderSalesLine.Next = 0;

            SalesOrderHeader := StandingOrderHeader;
            SalesOrderHeader."Document Type" := SalesOrderHeader."Document Type"::Order;
            if not HideValidationDialog then
                CustCheckCreditLimit.SalesHeaderCheck(SalesOrderHeader);

            SalesOrderHeader."No. Printed" := 0;
            SalesOrderHeader.Status := SalesOrderHeader.Status::Open;
            SalesOrderHeader."No." := '';

            SalesOrderLine.LockTable;
            SalesOrderHeader.Insert(true);

            SalesOrderHeader."Standing Order No." := StandingOrderHeader."No.";

            SalesOrderHeader."Order Date" := "Next Order Date";
            SalesOrderHeader."Posting Date" := "Next Order Date";
            SalesOrderHeader."Document Date" := "Next Order Date";
            SalesOrderHeader."Shipment Date" := "Next Order Date";
            SalesOrderHeader."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            SalesOrderHeader."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            SalesOrderHeader."Dimension Set ID" := "Dimension Set ID"; // P8001133

            // P8000466A
            SalesOrderHeader."Location Code" := "Location Code";
            SalesOrderHeader."Outbound Whse. Handling Time" := "Outbound Whse. Handling Time";
            SalesOrderHeader."Ship-to Name" := "Ship-to Name";
            SalesOrderHeader."Ship-to Name 2" := "Ship-to Name 2";
            SalesOrderHeader."Ship-to Address" := "Ship-to Address";
            SalesOrderHeader."Ship-to Address 2" := "Ship-to Address 2";
            SalesOrderHeader."Ship-to City" := "Ship-to City";
            SalesOrderHeader."Ship-to Post Code" := "Ship-to Post Code";
            SalesOrderHeader."Ship-to County" := "Ship-to County";
            SalesOrderHeader."Ship-to Country/Region Code" := "Ship-to Country/Region Code";
            SalesOrderHeader."Ship-to Contact" := "Ship-to Contact";
            // P8000466A
            SalesOrderHeader.CreateOrderAllowance; // PR3.70

            SalesOrderHeader."Prepayment %" := Cust."Prepayment %"; // P8000466A

            RefreshHeaderFields(SalesOrderHeader); // P8001025

            SalesOrderHeader.Modify;

            StandingOrderSalesLine.Reset;
            StandingOrderSalesLine.SetRange("Document Type", "Document Type");
            StandingOrderSalesLine.SetRange("Document No.", "No.");

            LinesCreated := false;
            if StandingOrderSalesLine.Find('-') then
                repeat
                    SalesOrderLine := StandingOrderSalesLine;
                    if SalesOrderLine."Alt. Qty. Transaction No." <> 0 then                             // P8000223A
                        AltQtyMgmt.GetNewAltQtyTransactionNo(SalesOrderLine."Alt. Qty. Transaction No."); // P8000223A
                    ResetQuantityFields(SalesOrderLine);
                    SalesOrderLine."Document Type" := SalesOrderHeader."Document Type";
                    SalesOrderLine."Document No." := SalesOrderHeader."No.";
                    if (SalesOrderLine."No." <> '') and (SalesOrderLine.Type <> 0) then begin
                        RefreshLineFields(SalesOrderHeader, SalesOrderLine); // P8001025
                        SalesOrderLine.Validate(Quantity, StandingOrderSalesLine."Qty. to Ship");
                        SalesOrderLine.Validate("Line Discount %", StandingOrderSalesLine."Line Discount %");
                        SalesOrderLine.UpdateWithWarehouseShip; // P8000466A
                        SalesOrderLine.SetDefaultQuantity; // P8001096
                    end;
                    SalesOrderLine."Shortcut Dimension 1 Code" := StandingOrderSalesLine."Shortcut Dimension 1 Code";
                    SalesOrderLine."Shortcut Dimension 2 Code" := StandingOrderSalesLine."Shortcut Dimension 2 Code";
                    SalesOrderLine."Dimension Set ID" := StandingOrderSalesLine."Dimension Set ID"; // P8001133

                    // P8000466A
                    if Cust."Prepayment %" <> 0 then
                        SalesOrderLine."Prepayment %" := Cust."Prepayment %";
                    PrepmtMgt.SetSalesPrepaymentPct(SalesOrderLine, SalesOrderHeader."Posting Date");
                    SalesOrderLine.Validate("Prepayment %");
                    // P8000466A

                    SalesOrderLine.Insert;

                    if ProcessFns.TrackingInstalled then                                               // P8000153A
                        LotSpecFns.CopyLotPrefSlsLineToSalesLine(StandingOrderSalesLine, SalesOrderLine); // P8000210A

                    if StandingOrderSalesLine."Qty. to Ship" <> 0 then
                        LinesCreated := true;
                    StandingOrderSalesLine.Validate("Qty. to Ship", StandingOrderSalesLine.Quantity);
                    StandingOrderSalesLine.Modify;
                until StandingOrderSalesLine.Next = 0;

            if not LinesCreated then
                if not HideValidationDialog then
                    Error(Text000)
                else
                    SalesOrderHeader.Delete(true)
            else begin
                SalesOrderHeader.Validate("Posting Date");
                SalesOrderHeader.Validate("Payment Terms Code");
                SalesOrderHeader.Validate("Shipment Date");
                SalesOrderHeader.Modify;

                if SalesSetup."Copy Cmts Standing to Order" then begin
                    SalesCommentLine.SetRange("Document Type", SalesCommentLine."Document Type"::FOODStandingOrder); // P80078010
                    SalesCommentLine.SetRange("No.", "No.");
                    if SalesCommentLine.Find('-') then
                        repeat
                            SalesCommentLine2 := SalesCommentLine;
                            SalesCommentLine2."Document Type" := SalesOrderHeader."Document Type";
                            SalesCommentLine2."No." := SalesOrderHeader."No.";
                            SalesCommentLine2.Insert;
                        until SalesCommentLine.Next = 0;
                    SalesOrderHeader.CopyLinks(StandingOrderHeader); // P8000466A
                end;
            end;

            Clear(CustCheckCreditLimit);
            Clear(ItemCheckAvail);
        end;
    end;

    local procedure ResetQuantityFields(var TempSalesLine: Record "Sales Line")
    begin
        TempSalesLine."Qty. Shipped Not Invoiced" := 0;
        TempSalesLine."Quantity Shipped" := 0;
        TempSalesLine."Quantity Invoiced" := 0;
        TempSalesLine."Qty. Shipped Not Invd. (Base)" := 0;
        TempSalesLine."Qty. Shipped (Base)" := 0;
        TempSalesLine."Qty. Invoiced (Base)" := 0;
    end;

    procedure GetSalesOrderHeader(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader := SalesOrderHeader;
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    procedure SetQtyToOrder(var StandingOrderHeader: Record "Sales Header"; ClearQuantities: Boolean)
    begin
        with StandingOrderSalesLine do begin
            Reset;
            SetRange("Document Type", StandingOrderHeader."Document Type");
            SetRange("Document No.", StandingOrderHeader."No.");
            if Find('-') then
                repeat
                    if ClearQuantities then
                        Validate("Qty. to Ship", 0)
                    else
                        Validate("Qty. to Ship", Quantity);
                    Modify(true);
                until (Next = 0);
        end;
    end;

    procedure RefreshHeaderFields(var SalesHeader: Record "Sales Header")
    var
        Cust: Record Customer;
        GLSetup: Record "General Ledger Setup";
    begin
        // P8001025
        GLSetup.Get;
        Cust.Get(SalesHeader."Bill-to Customer No.");
        SalesHeader."Customer Posting Group" := Cust."Customer Posting Group";
        SalesHeader."Gen. Bus. Posting Group" := Cust."Gen. Bus. Posting Group";
        if GLSetup."Bill-to/Sell-to VAT Calc." = GLSetup."Bill-to/Sell-to VAT Calc."::"Bill-to/Pay-to No." then
            SalesHeader."VAT Bus. Posting Group" := Cust."VAT Bus. Posting Group"
        else begin
            Cust.Get(SalesHeader."Sell-to Customer No.");
            SalesHeader."VAT Bus. Posting Group" := Cust."VAT Bus. Posting Group"
        end;
    end;

    procedure RefreshLineFields(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        GLAccount: Record "G/L Account";
        Item: Record Item;
        Resource: Record Resource;
        ItemCharge: Record "Item Charge";
    begin
        // P8001025
        SalesLine."Gen. Bus. Posting Group" := SalesHeader."Gen. Bus. Posting Group";
        SalesLine."VAT Bus. Posting Group" := SalesHeader."VAT Bus. Posting Group";
        case SalesLine.Type of
            SalesLine.Type::"G/L Account":
                begin
                    GLAccount.Get(SalesLine."No.");
                    SalesLine."Gen. Prod. Posting Group" := GLAccount."Gen. Prod. Posting Group";
                    SalesLine."VAT Bus. Posting Group" := GLAccount."VAT Prod. Posting Group";
                    SalesLine."Tax Group Code" := GLAccount."Tax Group Code";
                end;
            SalesLine.Type::Item:
                begin
                    Item.Get(SalesLine."No.");
                    SalesLine."Posting Group" := Item."Inventory Posting Group";
                    SalesLine."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
                    SalesLine."VAT Bus. Posting Group" := Item."VAT Prod. Posting Group";
                    SalesLine."Tax Group Code" := Item."Tax Group Code";
                    SalesLine."Item Category Code" := Item."Item Category Code";
                    SalesLine."Supply Chain Group Code" := Item.GetSupplyChainGroupCode;
                end;
            SalesLine.Type::Resource:
                begin
                    Resource.Get(SalesLine."No.");
                    SalesLine."Gen. Prod. Posting Group" := Resource."Gen. Prod. Posting Group";
                    SalesLine."VAT Bus. Posting Group" := Resource."VAT Prod. Posting Group";
                    SalesLine."Tax Group Code" := Resource."Tax Group Code";
                end;
            SalesLine.Type::"Fixed Asset":
                SalesLine.Validate("Depreciation Book Code"); // This calls GetFAPostingGroup which is a local fuction
                                                              // on SalesLine and therefore not directly callable
            SalesLine.Type::"Charge (Item)":
                begin
                    ItemCharge.Get(SalesLine."No.");
                    SalesLine."Gen. Prod. Posting Group" := ItemCharge."Gen. Prod. Posting Group";
                    SalesLine."VAT Bus. Posting Group" := ItemCharge."VAT Prod. Posting Group";
                    SalesLine."Tax Group Code" := ItemCharge."Tax Group Code";
                end;
        end;
    end;
}

