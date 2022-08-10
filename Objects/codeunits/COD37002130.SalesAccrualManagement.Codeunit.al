codeunit 37002130 "Sales Accrual Management"
{
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00
    // P8000249A, Myers Nissi, Jack Reynolds, 13 OCT 05
    //   Create function SalesPriceListPrice to calculate adjusted unit price with accrual plans taken int account
    // 
    // PR4.00.01
    // P8000274A, VerticalSoft, Jack Reynolds, 22 DEC 05
    //   Fix problems with resolving start and end dates for plan
    // 
    // PR4.00.03
    // P8000324A, VerticalSoft, Jack Reynolds, 06 APR 06
    //   Modify calculate for sales line to calculate all promo/rebates and then the commissions
    // 
    // PR4.00.04
    // P8000355A, VerticalSoft, Jack Reynolds, 19 JUL 06
    //   Add support for accrual groups
    // 
    // P8000399A, VerticalSoft, Jack Reynolds, 04 OCT 06
    //   Fix error with credit check and marketing plans with price impact
    // 
    // PR4.00.05
    // P8000428A, VerticalSoft, Jack Reynolds, 10 JAN 07
    //   Fix problem with calls SuspendCreditCheck on sales line table
    // 
    // PR4.00.06
    // P8000464A, VerticalSoft, Don Bresee, 9 APR 07
    //   Fixes relating to Combine Shipment & Combine Return Receipts functions
    //   Return Orders were being ignored
    // 
    // PR5.00
    // 
    // PRW15.00.01
    // P8000545A, VerticalSoft, Don Bresee, 13 NOV 07
    //   Add logic to use proper price/disc. group
    // 
    // P8000601A, VerticalSoft, Don Bresee, 30 OCT 07
    //   Change search field sequence for SQL
    // 
    // PRW16.00.01
    // P8000690, VerticalSoft, Jack Reynolds, 23 APR 09
    //   Fix rounding problem with unit price
    // 
    // P8000693, VerticalSoft, Jack Reynolds, 01 MAY 09
    //   Fix problem with currency rounding precision
    // 
    // P8000694, VerticalSoft, Jack Reynolds, 04 MAY 09
    //   Fix problems with currency issues
    // 
    // P8000767, VerticalSoft, Don Bresee, 04 FEB 10
    //   Move handling of "Plan Type" when building accrual lines
    //   Change calculation of price impact when building accrual lines
    // 
    // PRW16.00.04
    // P8000850, VerticalSoft, Jack Reynolds, 23 JUL 10
    //   Fix commission calculation with Include Promo/Rebate and Price Impact
    // 
    // PRW16.00.05
    // P8000981, Columbus IT, Don Bresee, 20 SEP 11
    //   Separate Costing and Pricing units
    // 
    // PRW17.00
    // P8001147, Columbus IT, Jack Reynolds, 04 APR 13
    //   Fix problem when updating unit prices on sales lines
    // 
    // PRW17.10.02
    // P8001295, Columbus IT, Jack Reynolds, 21 FEB 14
    //   Fix problem with credit warning when updating unit prices
    // 
    // PRW19.00
    // P8005495, To-Increase, Jack Reynolds, 20 NOV 15
    //   Fix problem with wrong dates (posting date vs. order date)
    // 
    // PRW19.00.01
    // P8007530, To-Increase, Dayakar Battini, 10 AUG 16
    //   Ignore Non Item type lines
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00
    //
    // PRW118.00.05
    // P800138545, To-Increase, Gangabhushan 19 JAN 22
    //   CS00201718 | Customer Rebate not calculated on credit memo when date type = Order date    

    Permissions = TableData "Posted Document Accrual Line" = r,
                  TableData "Accrual Plan Search Line" = r;

    trigger OnRun()
    begin
    end;

    var
        DeletingLine: Boolean;
        SearchCompLevel: Option Line,Header;
        NonPricePromoAmount: Decimal;
        Item: Record Item;
        Currency: Record Currency;
        AccrualMgmt: Codeunit "Accrual Calculation Management";
        SalesHeaderForPriceList: Record "Sales Header";
        ItemSalesPriceMgmt: Codeunit "Item Sales Price Management";

    local procedure IgnoreSalesHeader(var SalesHeader: Record "Sales Header"): Boolean
    begin
        with SalesHeader do
            exit(("Document Type" <> "Document Type"::Order) and
                 ("Document Type" <> "Document Type"::Invoice) and
                 ("Document Type" <> "Document Type"::"Return Order") and // P8000464
                 ("Document Type" <> "Document Type"::"Credit Memo"));
    end;

    local procedure IgnoreSalesLine(var SalesLine: Record "Sales Line"): Boolean
    begin
        with SalesLine do
            exit((("Document Type" <> "Document Type"::Order) and                                 //P8007530
                 ("Document Type" <> "Document Type"::Invoice) and
                 ("Document Type" <> "Document Type"::"Return Order") and // P8000464
                 ("Document Type" <> "Document Type"::"Credit Memo")) or (Type <> Type::Item));   //P8007530
    end;

    procedure SalesDeleteDocument(var SalesHeader: Record "Sales Header")
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        with SalesHeader do begin
            if IgnoreSalesHeader(SalesHeader) then
                exit;
            AccrualMgmt.DeleteAllDocLines(
              DocAccrualLine."Accrual Plan Type"::Sales, "Document Type", "No.");
        end;
    end;

    procedure SalesDeleteLines(var SalesLine: Record "Sales Line")
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        if AccrualMgmt.IsEnabled() then begin
            if IgnoreSalesLine(SalesLine) then
                exit;
            SalesDeleteLineLevelLines(SalesLine);
            SalesUpdateDocLevelLines(SalesLine, true);
        end;
    end;

    local procedure SalesDeleteLineLevelLines(var SalesLine: Record "Sales Line")
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        with SalesLine do begin
            if ("Line No." = 0) then
                AccrualMgmt.DeleteTempDocLines
            else
                AccrualMgmt.DeleteDocLines(
                  DocAccrualLine."Accrual Plan Type"::Sales,
                  DocAccrualLine."Computation Level"::"Document Line",
                  "Document Type", "Document No.", "Line No.");
            CalcFields("Promo/Rebate Amount (LCY)", "Commission Amount (LCY)");
        end;
    end;

    procedure SalesInsertLines(var SalesLine: Record "Sales Line")
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        if AccrualMgmt.IsEnabled() then begin
            if IgnoreSalesLine(SalesLine) then
                exit;
            AccrualMgmt.InsertTempDocLines(SalesLine."Line No.");
            SalesUpdateDocLevelLines(SalesLine, false);
        end;
    end;

    procedure SalesBeginRecalcLines(var SalesLine: Record "Sales Line")
    begin
        if AccrualMgmt.IsEnabled() then
            with SalesLine do begin
                "Unit Price" := "Unit Price" - "Accrual Amount (Price)";
                "Accrual Amount (Price)" := 0;
            end;
        AccrualMgmt.Disable;
    end;

    procedure SalesEndRecalcLines(var SalesLine: Record "Sales Line")
    begin
        AccrualMgmt.Enable;
        SalesUpdateLines(SalesLine, false);
    end;

    procedure SalesRecalcLines(var SalesLine: Record "Sales Line")
    begin
        SalesBeginRecalcLines(SalesLine);
        SalesEndRecalcLines(SalesLine);
    end;

    procedure SalesBeginNewPriceLines(var SalesLine: Record "Sales Line")
    begin
        if AccrualMgmt.IsEnabled() then
            with SalesLine do
                "Accrual Amount (Price)" := 0;
        AccrualMgmt.Disable;
    end;

    procedure SalesEndNewPriceLines(var SalesLine: Record "Sales Line"; SettingUnitPrice: Boolean)
    begin
        AccrualMgmt.Enable;
        SalesUpdateLines(SalesLine, SettingUnitPrice);
    end;

    procedure SetSalesUnitPrice(var SalesLine: Record "Sales Line"; NewUnitPrice: Decimal)
    begin
        with SalesLine do
            "Unit Price" := NewUnitPrice;
        SalesBeginNewPriceLines(SalesLine);
        SalesEndNewPriceLines(SalesLine, true);
    end;

    procedure SalesUpdateLines(var SalesLine: Record "Sales Line"; SettingUnitPrice: Boolean)
    var
        SalesHeader: Record "Sales Header";
        AccrualPlan: Record "Accrual Plan";
    begin
        if AccrualMgmt.IsEnabled() then begin
            if IgnoreSalesLine(SalesLine) then
                exit;
            SalesDeleteLineLevelLines(SalesLine);
            // SalesInsertPlanLines(SalesLine, SearchCompLevel::Line, FALSE); // P8000601A
            SalesInsertItemLinesSQL(SalesLine, SearchCompLevel::Line, false); // P8000601A
            with SalesLine do begin
                if ("Line No." <> 0) then
                    AccrualMgmt.InsertTempDocLines("Line No.");
                SalesUpdateUnitPrice(SalesLine, SettingUnitPrice, false);
                if ("Line No." = 0) then
                    AccrualMgmt.CalcTempDocTotals("Promo/Rebate Amount (LCY)", "Commission Amount (LCY)")
                else
                    CalcFields("Promo/Rebate Amount (LCY)", "Commission Amount (LCY)");
            end;
        end;
    end;

    local procedure SalesUpdateDocLevelLines(var SalesLine: Record "Sales Line"; Deleting: Boolean)
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        with SalesLine do
            if ("Line No." <> 0) then begin
                AccrualMgmt.DeleteDocLines(
                  DocAccrualLine."Accrual Plan Type"::Sales,
                  DocAccrualLine."Computation Level"::Document,
                  "Document Type", "Document No.", 0);
                // SalesInsertPlanLines(SalesLine, SearchCompLevel::Header, Deleting); // P8000601A
                SalesInsertItemLinesSQL(SalesLine, SearchCompLevel::Header, Deleting); // P8000601A
                AccrualMgmt.InsertTempDocLines(0);
            end;
    end;

    local procedure SalesInsertPlanLines(var SalesLine: Record "Sales Line"; ComputationLevel: Integer; Deleting: Boolean)
    var
        SalesHeader: Record "Sales Header";
        AccrualSearchLine: Record "Accrual Plan Search Line";
        LineDiscountFactor: Decimal;
        PlanType: Integer;
    begin
        DeletingLine := Deleting;
        SearchCompLevel := ComputationLevel;
        NonPricePromoAmount := 0;

        with SalesLine do begin
            if (Type <> Type::Item) or ("No." = '') or
               ((Quantity = 0) and ("Unit Price" = 0))
            then
                exit;
            // P8000249A
            if SalesLine."Document No." = '' then
                SalesHeader := SalesHeaderForPriceList
            else
                SalesHeader.Get("Document Type", "Document No.");
            // P8000249A
        end;

        with AccrualSearchLine do begin
            SetCurrentKey(
              "Accrual Plan Type", "Computation Level", "Date Type", "Start Date", "End Date",
              "Source Selection Type", "Source Selection", "Source Code", "Source Ship-to Code",
              "Item Selection", "Item Code", "Plan Type"); // P8000324A

            SetRange("Accrual Plan Type", "Accrual Plan Type"::Sales);
            SetRange("Computation Level", SearchCompLevel);

            // P8000324A
            for PlanType := AccrualSearchLine."Plan Type"::"Promo/Rebate" to AccrualSearchLine."Plan Type"::Commission do begin
                SetRange("Plan Type", PlanType);
                // P8000324A

                if (SalesHeader."Posting Date" <> 0D) then begin
                    SetRange("Date Type", "Date Type"::"Posting Date");
                    SetFilter("Start Date", '..%1', SalesHeader."Posting Date");
                    SetFilter("End Date", '%1|%2..', 0D, SalesHeader."Posting Date");
                    SalesInsertSourceTypeLines(AccrualSearchLine, SalesHeader, SalesLine);
                end;

                if (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order"]) and // P8005495
                 (SalesHeader."Order Date" <> 0D)                                                                                        // P8005495
                then begin                                                                                                               // P8005495
                    SetRange("Date Type", "Date Type"::"Order Date");
                    SetFilter("Start Date", '..%1', SalesHeader."Order Date");
                    SetFilter("End Date", '%1|%2..', 0D, SalesHeader."Order Date");
                    SalesInsertSourceTypeLines(AccrualSearchLine, SalesHeader, SalesLine);
                end;
            end; // P8000324A
        end;
    end;

    local procedure SalesInsertSourceTypeLines(var AccrualSearchLine: Record "Accrual Plan Search Line"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        with AccrualSearchLine do begin
            if not Find('-') then
                exit;

            if (SalesHeader."Bill-to Customer No." <> '') then begin
                SetRange("Source Selection Type", "Source Selection Type"::"Bill-to/Pay-to");
                SalesInsertSourceLines(
                  AccrualSearchLine, SalesHeader, SalesLine, SalesHeader."Bill-to Customer No.", '');
            end;

            // IF (SalesHeader."Sell-to Customer No." <> '') THEN BEGIN // P8000464
            if (SalesLine."Sell-to Customer No." <> '') then begin      // P8000464
                SetRange("Source Selection Type", "Source Selection Type"::"Sell-to/Buy-from");
                SalesInsertSourceLines(
                  // AccrualSearchLine, SalesHeader, SalesLine, SalesHeader."Sell-to Customer No.", ''); // P8000464
                  AccrualSearchLine, SalesHeader, SalesLine, SalesLine."Sell-to Customer No.", '');      // P8000464

                // IF (SalesHeader."Ship-to Code" <> '') THEN BEGIN              // P8000464
                if (GetSalesShipToCode(SalesHeader, SalesLine) <> '') then begin // P8000464
                    SetRange("Source Selection Type", "Source Selection Type"::"Sell-to/Ship-to");
                    SalesInsertSourceLines(
                      AccrualSearchLine, SalesHeader, SalesLine,
                      // SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code");            // P8000464
                      SalesLine."Sell-to Customer No.", GetSalesShipToCode(SalesHeader, SalesLine)); // P8000464
                end;
            end;

            // P8000249A
            if (SalesHeader."Sell-to Customer No." = '') and (SalesHeader."Bill-to Customer No." = '') and
              (SalesHeader."Customer Price Group" <> '')
            then begin
                SetRange("Source Selection Type");
                SalesInsertSourceLines(AccrualSearchLine, SalesHeader, SalesLine, '', '');
            end;
            // P8000249A

            SetRange("Source Selection Type");
        end;
    end;

    procedure GetSalesShipToCode(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"): Code[10]
    var
        SalesShptHeader: Record "Sales Shipment Header";
        SalesRcptHeader: Record "Return Receipt Header";
    begin
        // P8000464
        with SalesLine do
            if ("Document Type" in ["Document Type"::Order, "Document Type"::Invoice]) then begin
                if ("Shipment No." = '') then
                    exit(SalesHeader."Ship-to Code");
                SalesShptHeader.Get("Shipment No.");
                exit(SalesShptHeader."Ship-to Code");
            end else begin
                if ("Return Receipt No." = '') then
                    exit(SalesHeader."Ship-to Code");
                SalesRcptHeader.Get("Return Receipt No.");
                exit(SalesRcptHeader."Ship-to Code");
            end;
    end;

    local procedure SalesInsertSourceLines(var AccrualSearchLine: Record "Accrual Plan Search Line"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; SourceNo: Code[20]; ShipToCode: Code[20])
    var
        Customer: Record Customer;
        AccrualGroupLine: Record "Accrual Group Line";
    begin
        // P8000249A
        if SourceNo = '' then
            Customer."Customer Price Group" := SalesHeader."Customer Price Group"
        else
            // P8000249A
            Customer.Get(SourceNo);

        with AccrualSearchLine do begin
            if not Find('-') then
                exit;

            SetRange("Source Selection", "Source Selection"::All);
            SalesInsertItemLines(AccrualSearchLine, SalesHeader, SalesLine);

            if (Customer."Customer Price Group" <> '') then begin
                SetRange("Source Selection", "Source Selection"::"Price Group");
                SetRange("Source Code", Customer."Customer Price Group");
                SalesInsertItemLines(AccrualSearchLine, SalesHeader, SalesLine);
            end;

            /*P8000355A
            AccrualGroupLine.RESET;
            AccrualGroupLine.SETCURRENTKEY("Accrual Group Type", "No.", "Accrual Group Code");
            AccrualGroupLine.SETRANGE("Accrual Group Type", AccrualGroupLine."Accrual Group Type"::Customer);
            AccrualGroupLine.SETRANGE("No.", SourceNo);
            IF AccrualGroupLine.FIND('-') THEN BEGIN
              SETRANGE("Source Selection", "Source Selection"::"Accrual Group");
              REPEAT
                SETRANGE("Source Code", AccrualGroupLine."Accrual Group Code");
                SalesInsertItemLines(AccrualSearchLine, SalesHeader, SalesLine);
              UNTIL (AccrualGroupLine.NEXT = 0);
            END;
            P8000355A*/

            SetRange("Source Selection", "Source Selection"::Specific);
            SetRange("Source Code", SourceNo);
            if (ShipToCode <> '') then
                SetRange("Source Ship-to Code", ShipToCode);
            SalesInsertItemLines(AccrualSearchLine, SalesHeader, SalesLine);

            SetRange("Source Selection");
            SetRange("Source Code");
            SetRange("Source Ship-to Code");
        end;

    end;

    local procedure SalesInsertItemLines(var AccrualSearchLine: Record "Accrual Plan Search Line"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        AccrualGroupLine: Record "Accrual Group Line";
    begin
        if (Item."No." <> SalesLine."No.") then
            Item.Get(SalesLine."No.");

        with AccrualSearchLine do begin
            if not Find('-') then
                exit;

            SetRange("Item Selection", "Item Selection"::"All Items");
            SalesInsertCalcLines(AccrualSearchLine, SalesHeader, SalesLine);

            SetRange("Item Selection", "Item Selection"::"Specific Item");
            SetRange("Item Code", Item."No.");
            SalesInsertCalcLines(AccrualSearchLine, SalesHeader, SalesLine);

            if (Item."Item Category Code" <> '') then begin
                SetRange("Item Selection", "Item Selection"::"Item Category");
                SetRange("Item Code", Item."Item Category Code");
                SalesInsertCalcLines(AccrualSearchLine, SalesHeader, SalesLine);
            end;

            if (Item."Manufacturer Code" <> '') then begin
                SetRange("Item Selection", "Item Selection"::Manufacturer);
                SetRange("Item Code", Item."Manufacturer Code");
                SalesInsertCalcLines(AccrualSearchLine, SalesHeader, SalesLine);
            end;

            if (Item."Vendor No." <> '') then begin
                SetRange("Item Selection", "Item Selection"::"Vendor No.");
                SetRange("Item Code", Item."Vendor No.");
                SalesInsertCalcLines(AccrualSearchLine, SalesHeader, SalesLine);
            end;

            /*P8000355A
            AccrualGroupLine.RESET;
            AccrualGroupLine.SETCURRENTKEY("Accrual Group Type", "No.", "Accrual Group Code");
            AccrualGroupLine.SETRANGE("Accrual Group Type", AccrualGroupLine."Accrual Group Type"::Item);
            AccrualGroupLine.SETRANGE("No.", Item."No.");
            IF AccrualGroupLine.FIND('-') THEN BEGIN
              SETRANGE("Item Selection", "Item Selection"::"Accrual Group");
              REPEAT
                SETRANGE("Item Code", AccrualGroupLine."Accrual Group Code");
                SalesInsertCalcLines(AccrualSearchLine, SalesHeader, SalesLine);
              UNTIL (AccrualGroupLine.NEXT = 0);
            END;
            P8000355A*/

            SetRange("Item Selection");
            SetRange("Item Code");
        end;

    end;

    local procedure SalesInsertCalcLines(var AccrualSearchLine: Record "Accrual Plan Search Line"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        AccrualPlan: Record "Accrual Plan";
        AccrualAmount: Decimal;
        TempJnlLine: Record "Accrual Journal Line" temporary;
        TempDocAccrualLine: Record "Document Accrual Line";
    begin
        if not AccrualSearchLine.Find('-') then
            exit;

        with AccrualPlan do
            repeat
                Get(AccrualSearchLine."Accrual Plan Type", AccrualSearchLine."Accrual Plan No.");
                GetSalesAccrualAmount(AccrualPlan, SalesHeader, SalesLine, AccrualAmount); // P8000274A
                if (AccrualAmount <> 0) then begin
                    AccrualMgmt.GetPaymentDistribution(
                      Type, "No.", SalesHeader."Bill-to Customer No.", AccrualAmount, TempJnlLine);
                    if TempJnlLine.Find('-') then
                        repeat
                            TempDocAccrualLine.Init;
                            TempDocAccrualLine."Accrual Plan Type" := Type;
                            TempDocAccrualLine."Document Type" := SalesLine."Document Type";
                            TempDocAccrualLine."Document No." := SalesLine."Document No.";
                            if ("Computation Level" = "Computation Level"::"Document Line") then
                                TempDocAccrualLine."Document Line No." := SalesLine."Line No."
                            else
                                TempDocAccrualLine."Document Line No." := 0;
                            TempDocAccrualLine."Plan Type" := "Plan Type";
                            TempDocAccrualLine."Computation Level" := "Computation Level";
                            TempDocAccrualLine.Validate("Accrual Plan No.", "No.");
                            TempDocAccrualLine.Type := TempJnlLine.Type;
                            TempDocAccrualLine.Validate("No.", TempJnlLine."No.");
                            TempDocAccrualLine.Description := SalesHeader."Posting Description";
                            TempDocAccrualLine."Accrual Amount (LCY)" := AccrualAmount;
                            TempDocAccrualLine.Validate("Payment Amount (LCY)", TempJnlLine.Amount);
                            TempDocAccrualLine."Orig. Payment Amount (LCY)" := TempDocAccrualLine."Payment Amount (LCY)";
                            AccrualMgmt.Insert1TempDocLine(TempDocAccrualLine);

                            if ("Plan Type" = "Plan Type"::"Promo/Rebate") and
                               ("Computation Level" = "Computation Level"::"Document Line") and
                               //             ("Price Impact" = "Price Impact"::None)                // P8000850
                               ("Price Impact" <> "Price Impact"::"Exclude from Price") // P8000850
                            then
                                NonPricePromoAmount := NonPricePromoAmount + TempDocAccrualLine."Payment Amount (LCY)";
                        until (TempJnlLine.Next = 0);
                end;
            until (AccrualSearchLine.Next = 0);
    end;

    local procedure GetSalesAccrualAmount(var AccrualPlan: Record "Accrual Plan"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var AccrualAmount: Decimal)
    var
        AccrualQty: Decimal;
        PriceAmount: Decimal;
        CostAmount: Decimal;
        SalesLine2: Record "Sales Line";
        GLSetup: Record "General Ledger Setup";
    begin
        // P8000274A - add parameter SalesHeader
        AccrualQty := 0;
        PriceAmount := 0;
        CostAmount := 0;
        with AccrualPlan do begin
            if not DeletingLine then
                AccumSalesLineAmounts(                                                       // P8000274A
                  AccrualPlan, SalesHeader, SalesLine, AccrualQty, PriceAmount, CostAmount); // P8000274A
            if ("Computation Level" = "Computation Level"::Document) then begin
                SalesLine2.SetRange("Document Type", SalesLine."Document Type");
                SalesLine2.SetRange("Document No.", SalesLine."Document No.");
                SalesLine2.SetFilter("Line No.", '<>%1', SalesLine."Line No.");
                SalesLine2.SetRange(Type, SalesLine2.Type::Item);
                SalesLine2.SetFilter("No.", '<>%1', '');
                if SalesLine2.Find('-') then
                    repeat
                        AccumSalesLineAmounts(                                                        // P8000274A
                          AccrualPlan, SalesHeader, SalesLine2, AccrualQty, PriceAmount, CostAmount); // P8000274A
                    until (SalesLine2.Next = 0);
            end;
            // P8000694
            if SalesHeader."Currency Factor" <> 0 then begin
                PriceAmount := PriceAmount / SalesHeader."Currency Factor";
                CostAmount := CostAmount / SalesHeader."Currency Factor";
            end;
            if ("Plan Type" <> "Plan Type"::"Promo/Rebate") and "Include Promo/Rebate" then // P8000767
                PriceAmount := PriceAmount - NonPricePromoAmount;

            GLSetup.Get;
            PriceAmount := Round(PriceAmount, GLSetup."Amount Rounding Precision");
            CostAmount := Round(CostAmount, GLSetup."Amount Rounding Precision");
            // P8000694
            AccrualAmount := CalcAccrualAmount(                                                  // P8000274A
              SalesLine."No.", GetDocumentTransactionDate(SalesHeader), PriceAmount, CostAmount, AccrualQty); // P8000274A, P8005495
        end;
    end;

    local procedure AccumSalesLineAmounts(var AccrualPlan: Record "Accrual Plan"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var AccrualQty: Decimal; var PriceAmount: Decimal; var CostAmount: Decimal)
    var
        CostingQty: Decimal;
        QtyBase: Decimal;
        QtyAlt: Decimal;
    begin
        // P8000274A - add parameter SalesHeader
        with AccrualPlan do begin
            GetSalesQtys(AccrualPlan, SalesLine, CostingQty, QtyBase, QtyAlt);
            AccrualQty := AccrualQty +                                                           // P8000274A
              CalcAccrualQuantity(SalesLine."No.", GetDocumentTransactionDate(SalesHeader), QtyBase, QtyAlt); // P8000274A, P8005495
            PriceAmount := PriceAmount +
              (SalesLine."Unit Price" * CostingQty) -
              (SalesLine."Line Discount Amount" + SalesLine."Inv. Discount Amount");
            // IF ("Computation Level" = "Computation Level"::"Document Line") THEN // P8000767
            PriceAmount := PriceAmount - SalesLine."Accrual Amount (Price)" * CostingQty;
            // P8000767
            if ("Plan Type" <> "Plan Type"::"Promo/Rebate") and "Include Promo/Rebate" then
                PriceAmount := PriceAmount +
                  AccrualMgmt.CalcTempDocPriceImpact(
                    SalesLine."Acc. Incl. in Price (LCY)", SalesLine."Acc. Excl. from Price (LCY)");
            // P8000767
            //IF "Exclude Promo/Rebate" THEN                      // P8000694
            //  PriceAmount := PriceAmount - NonPricePromoAmount; // P8000694
            //CostAmount := SalesLine."Unit Cost" * CostingQty;              // P8000981
            CostAmount := SalesLine."Unit Cost" * SalesLine.GetCostingQty(); // P8000981
        end;
    end;

    local procedure SalesUpdateUnitPrice(var SalesLine: Record "Sales Line"; SettingUnitPrice: Boolean; ModifyRecord: Boolean)
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        TargetUnitPrice: Decimal;
        LastLineAmount: Decimal;
        LastUnitPrice: Decimal;
        LineAmountChanges: Integer;
    begin
        if AccrualMgmt.IsEnabled() then
            with SalesLine do begin
                if IgnoreSalesLine(SalesLine) then
                    exit;

                if ("Currency Code" = '') then
                    Currency.InitRoundingPrecision // P8000693
                else
                    Currency.Get("Currency Code");
                SalesHeader.Get("Document Type", "Document No."); // P8000694

                TargetUnitPrice := "Unit Price";
                repeat
                    LastLineAmount := "Line Amount";
                    LastUnitPrice := "Unit Price";
                    "Unit Price" := TargetUnitPrice - "Accrual Amount (Price)";
                    if (GetPricingQty() = 0) then
                        "Accrual Amount (Price)" := 0
                    else begin                                                                                // P8000694
                        "Accrual Amount (Price)" := SalesPriceImpact(SalesLine) / GetPricingQty();
                        if SalesHeader."Currency Factor" <> 0 then                                              // P8000694
                            "Accrual Amount (Price)" := "Accrual Amount (Price)" * SalesHeader."Currency Factor"; // P8000694
                        "Accrual Amount (Price)" := Round("Accrual Amount (Price)", Currency."Unit-Amount Rounding Precision"); // P8000690
                    end;                                                                                      // P8000694
                    "Unit Price" := "Unit Price" + "Accrual Amount (Price)";
                    SalesLine.SuspendCreditCheck(true);  // P8001295
                    CalcLineDiscount(true); // P8001147, P80073095
                    SalesLine.SuspendCreditCheck(false); // P8001295
                    "Line Amount" :=
                      Round(GetPricingQty() * "Unit Price", Currency."Amount Rounding Precision") -
                      "Line Discount Amount";
                    if ("Line Amount" <> LastLineAmount) then begin
                        SuspendCreditCheck(true);  // P8000399A, P8000428A
                        UpdateAmounts;
                        SuspendCreditCheck(false); // P8000399A, P8000428A
                        if SettingUnitPrice then begin
                            SalesDeleteLineLevelLines(SalesLine);
                            // SalesInsertPlanLines(SalesLine, SearchCompLevel::Line, FALSE); // P8000601A
                            SalesInsertItemLinesSQL(SalesLine, SearchCompLevel::Line, false); // P8000601A
                            if ("Line No." <> 0) then
                                AccrualMgmt.InsertTempDocLines("Line No.");
                        end;
                        LineAmountChanges := LineAmountChanges + 1;
                    end;
                until (not SettingUnitPrice) or (LineAmountChanges > 9) or
                      ((Abs("Line Amount" - LastLineAmount) < Currency."Amount Rounding Precision") and
                       (Abs("Unit Price" - LastUnitPrice) < Currency."Unit-Amount Rounding Precision"));

                if ModifyRecord and (LineAmountChanges > 0) then
                    Modify(true);
                SalesUpdateDocLevelLines(SalesLine, false);
            end;
    end;

    procedure GetSalesQtys(var AccrualPlan: Record "Accrual Plan"; var SalesLine: Record "Sales Line"; var CostingQty: Decimal; var QtyBase: Decimal; var QtyAlt: Decimal)
    begin
        with SalesLine do begin
            CostingQty := GetPricingQty();
            QtyBase := "Quantity (Base)";
            QtyAlt := "Quantity (Alt.)";
        end;
    end;

    procedure SalesPromoRebateDrillDown(var SalesLine: Record "Sales Line")
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        SalesBeforeDrillDown(SalesLine);
        with DocAccrualLine do
            AccrualMgmt.DocPlanTypeDrillDown(
              "Accrual Plan Type"::Sales, "Plan Type"::"Promo/Rebate", "Computation Level"::"Document Line",
              SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");

        SalesUpdateUnitPrice(SalesLine, false, true);
    end;

    procedure SalesCommissionDrillDown(var SalesLine: Record "Sales Line")
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        SalesBeforeDrillDown(SalesLine);
        with DocAccrualLine do
            AccrualMgmt.DocPlanTypeDrillDown(
              "Accrual Plan Type"::Sales, "Plan Type"::Commission, "Computation Level"::"Document Line",
              SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");

        SalesUpdateUnitPrice(SalesLine, false, true);
    end;

    procedure SalesPriceImpact(var SalesLine: Record "Sales Line"): Decimal
    begin
        with SalesLine do begin
            if ("Line No." = 0) then
                exit(AccrualMgmt.CalcTempDocPriceImpact(
                  "Acc. Incl. in Price (LCY)", "Acc. Excl. from Price (LCY)"));
            CalcFields("Acc. Incl. in Price (LCY)", "Acc. Excl. from Price (LCY)");
            exit("Acc. Incl. in Price (LCY)" - "Acc. Excl. from Price (LCY)");
        end;
    end;

    procedure SalesPriceImpactDrillDown(var SalesLine: Record "Sales Line")
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        SalesBeforeDrillDown(SalesLine);
        with DocAccrualLine do
            AccrualMgmt.DocPriceImpactDrillDown(
              "Accrual Plan Type"::Sales, SalesLine."Document Type",
              SalesLine."Document No.", SalesLine."Line No.");
    end;

    local procedure SalesBeforeDrillDown(var SalesLine: Record "Sales Line")
    begin
        with SalesLine do begin
            TestField(Type, Type::Item);
            TestField("No.");
        end;
    end;

    procedure SalesDocPromoRebateDrillDown(var SalesHeader: Record "Sales Header")
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        with DocAccrualLine do
            AccrualMgmt.DocPlanTypeDrillDown(
              "Accrual Plan Type"::Sales, "Plan Type"::"Promo/Rebate", "Computation Level"::Document,
              SalesHeader."Document Type", SalesHeader."No.", 0);
    end;

    procedure SalesDocCommissionDrillDown(var SalesHeader: Record "Sales Header")
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        with DocAccrualLine do
            AccrualMgmt.DocPlanTypeDrillDown(
              "Accrual Plan Type"::Sales, "Plan Type"::Commission, "Computation Level"::Document,
              SalesHeader."Document Type", SalesHeader."No.", 0);
    end;

    procedure SalesInvPriceImpact(var SalesInvLine: Record "Sales Invoice Line"): Decimal
    begin
        with SalesInvLine do begin
            CalcFields("Acc. Incl. in Price (LCY)", "Acc. Excl. from Price (LCY)");
            exit("Acc. Incl. in Price (LCY)" - "Acc. Excl. from Price (LCY)");
        end;
    end;

    procedure SalesInvPriceImpactDrillDown(var SalesInvLine: Record "Sales Invoice Line")
    var
        AccrualLedgEntry: Record "Accrual Ledger Entry";
    begin
        with SalesInvLine do begin
            TestField(Type, Type::Item);
            TestField("No.");
        end;

        with AccrualLedgEntry do
            AccrualMgmt.LedgPriceImpactDrillDown(
              "Accrual Plan Type"::Sales, "Source Document Type"::Invoice,
              SalesInvLine."Document No.", SalesInvLine."Line No.");
    end;

    procedure SalesPriceListPrice(CustomerNo: Code[20]; CustPriceGroup: Code[10]; ItemNo: Code[20]; UOM: Code[10]; PriceDate: Date; UnitPrice: Decimal): Decimal
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        GLSetup: Record "General Ledger Setup";
    begin
        // P8000249A
        GLSetup.Get;
        Item.Get(ItemNo);
        ItemUOM.Get(ItemNo, UOM);

        SalesLine.Type := SalesLine.Type::Item;
        SalesLine."No." := ItemNo;
        SalesLine.Quantity := 1;
        SalesLine."Unit of Measure" := UOM;
        SalesLine."Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
        SalesLine."Quantity (Base)" := Round(ItemUOM."Qty. per Unit of Measure", 0.00001);
        SalesLine."Quantity (Alt.)" := Round(SalesLine."Quantity (Base)" * Item.AlternateQtyPerBase, 0.00001);
        SalesLine."Unit Cost" := Item."Unit Cost";
        SalesLine."Unit Price" := UnitPrice;
        // P8000545A
        if (CustomerNo <> '') then
            ItemSalesPriceMgmt.SetCustItemPriceGroup(
              CustPriceGroup, CustomerNo, Item."Item Category Code"); // P8007749
        SalesLine."Customer Price Group" := CustPriceGroup;
        // P8000545A

        SalesHeaderForPriceList."Document Type" := SalesHeaderForPriceList."Document Type"::Order; // P8005495
        SalesHeaderForPriceList."Sell-to Customer No." := CustomerNo;
        SalesHeaderForPriceList."Bill-to Customer No." := CustomerNo;
        SalesHeaderForPriceList."Order Date" := PriceDate;
        SalesHeaderForPriceList."Posting Date" := PriceDate;
        SalesHeaderForPriceList."Customer Price Group" := CustPriceGroup;

        // SalesInsertPlanLines(SalesLine, SearchCompLevel::Line, FALSE); // P8000601A
        SalesInsertItemLinesSQL(SalesLine, SearchCompLevel::Line, false); // P8000601A

        if SalesLine.GetPricingQty <> 0 then
            UnitPrice += SalesPriceImpact(SalesLine) / SalesLine.GetPricingQty;

        exit(Round(UnitPrice, GLSetup."Unit-Amount Rounding Precision"));
    end;

    local procedure SalesInsertItemLinesSQL(var SalesLine: Record "Sales Line"; ComputationLevel: Integer; Deleting: Boolean)
    var
        SalesHeader: Record "Sales Header";
        AccrualSearchLine: Record "Accrual Plan Search Line";
        ItemCategory: Record "Item Category";
        PlanType: Integer;
    begin
        // P8000601A
        DeletingLine := Deleting;
        SearchCompLevel := ComputationLevel;
        NonPricePromoAmount := 0;

        with SalesLine do begin
            if (Type <> Type::Item) or ("No." = '') or
               ((Quantity = 0) and ("Unit Price" = 0))
            then
                exit;
            if SalesLine."Document No." = '' then
                SalesHeader := SalesHeaderForPriceList
            else
                SalesHeader.Get("Document Type", "Document No.");

            if (Item."No." <> "No.") then
                Item.Get("No.");
        end;

        with AccrualSearchLine do begin
            SetCurrentKey( // P8000767 - "Plan Type" moved in the key
              "Accrual Plan Type", "Computation Level", "Plan Type", "Item Selection", "Item Code",
              "Source Selection Type", "Source Selection", "Source Code", "Source Ship-to Code",
              "Date Type", "Start Date", "End Date");

            SetRange("Accrual Plan Type", "Accrual Plan Type"::Sales);
            SetRange("Computation Level", SearchCompLevel);

            // P8000767
            for PlanType := "Plan Type"::"Promo/Rebate" to "Plan Type"::Commission do begin
                SetRange("Plan Type", PlanType);
                // P8000767

                SetRange("Item Selection", "Item Selection"::"All Items");
                SetRange("Item Code", '');
                SalesInsertSourceTypeLinesSQL(AccrualSearchLine, SalesHeader, SalesLine);

                SetRange("Item Selection", "Item Selection"::"Specific Item");
                SetRange("Item Code", Item."No.");
                SalesInsertSourceTypeLinesSQL(AccrualSearchLine, SalesHeader, SalesLine);

                if (Item."Item Category Code" <> '') then begin
                    SetRange("Item Selection", "Item Selection"::"Item Category");
                    // P8007749
                    //SETRANGE("Item Code", Item."Item Category Code");
                    ItemCategory.Get(Item."Item Category Code");
                    SetFilter("Item Code", ItemCategory.GetAncestorFilterString(true));
                    // P8007749
                    SalesInsertSourceTypeLinesSQL(AccrualSearchLine, SalesHeader, SalesLine);
                end;

                if (Item."Manufacturer Code" <> '') then begin
                    SetRange("Item Selection", "Item Selection"::Manufacturer);
                    SetRange("Item Code", Item."Manufacturer Code");
                    SalesInsertSourceTypeLinesSQL(AccrualSearchLine, SalesHeader, SalesLine);
                end;

                if (Item."Vendor No." <> '') then begin
                    SetRange("Item Selection", "Item Selection"::"Vendor No.");
                    SetRange("Item Code", Item."Vendor No.");
                    SalesInsertSourceTypeLinesSQL(AccrualSearchLine, SalesHeader, SalesLine);
                end;
            end; // P8000767
        end;
    end;

    local procedure SalesInsertSourceTypeLinesSQL(var AccrualSearchLine: Record "Accrual Plan Search Line"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        // P8000601A
        with AccrualSearchLine do begin
            if not Find('-') then
                exit;

            if (SalesHeader."Bill-to Customer No." <> '') then begin
                SetRange("Source Selection Type", "Source Selection Type"::"Bill-to/Pay-to");
                SalesInsertSourceLinesSQL(
                  AccrualSearchLine, SalesHeader, SalesLine, SalesHeader."Bill-to Customer No.", '');
            end;

            if (SalesLine."Sell-to Customer No." <> '') then begin
                SetRange("Source Selection Type", "Source Selection Type"::"Sell-to/Buy-from");
                SalesInsertSourceLinesSQL(
                  AccrualSearchLine, SalesHeader, SalesLine, SalesLine."Sell-to Customer No.", '');

                if (GetSalesShipToCode(SalesHeader, SalesLine) <> '') then begin
                    SetRange("Source Selection Type", "Source Selection Type"::"Sell-to/Ship-to");
                    SalesInsertSourceLinesSQL(
                      AccrualSearchLine, SalesHeader, SalesLine,
                      SalesLine."Sell-to Customer No.", GetSalesShipToCode(SalesHeader, SalesLine));
                end;
            end;

            if (SalesHeader."Sell-to Customer No." = '') and (SalesHeader."Bill-to Customer No." = '') and
              (SalesHeader."Customer Price Group" <> '')
            then begin
                SetRange("Source Selection Type");
                SalesInsertSourceLinesSQL(AccrualSearchLine, SalesHeader, SalesLine, '', '');
            end;

            SetRange("Source Selection Type");
        end;
    end;

    local procedure SalesInsertSourceLinesSQL(var AccrualSearchLine: Record "Accrual Plan Search Line"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; SourceNo: Code[20]; ShipToCode: Code[20])
    var
        Customer: Record Customer;
    begin
        // P8000601A
        if SourceNo = '' then
            Customer."Customer Price Group" := SalesHeader."Customer Price Group"
        else
            Customer.Get(SourceNo);

        with AccrualSearchLine do begin
            if not Find('-') then
                exit;

            SetRange("Source Selection", "Source Selection"::All);
            SetRange("Source Code", '');
            SalesInsertPlanLinesSQL(AccrualSearchLine, SalesHeader, SalesLine);

            Customer."Customer Price Group" := SalesLine."Customer Price Group"; // P8000545A
            if (Customer."Customer Price Group" <> '') then begin
                SetRange("Source Selection", "Source Selection"::"Price Group");
                SetRange("Source Code", Customer."Customer Price Group");
                SalesInsertPlanLinesSQL(AccrualSearchLine, SalesHeader, SalesLine);
            end;

            SetRange("Source Selection", "Source Selection"::Specific);
            SetRange("Source Code", SourceNo);
            if (ShipToCode <> '') then
                SetRange("Source Ship-to Code", ShipToCode);
            SalesInsertPlanLinesSQL(AccrualSearchLine, SalesHeader, SalesLine);

            SetRange("Source Selection");
            SetRange("Source Code");
            SetRange("Source Ship-to Code");
        end;
    end;

    local procedure SalesInsertPlanLinesSQL(var AccrualSearchLine: Record "Accrual Plan Search Line"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        PlanType: Integer;
        OrderDate: Date;
    begin
        // P8000601A
        with AccrualSearchLine do begin
            if not Find('-') then
                exit;

            // FOR PlanType := "Plan Type"::"Promo/Rebate" TO "Plan Type"::Commission DO BEGIN // P8000767
            //   SETRANGE("Plan Type",PlanType);                                               // P8000767

            if (SalesHeader."Posting Date" <> 0D) then begin
                SetRange("Date Type", "Date Type"::"Posting Date");
                SetFilter("Start Date", '..%1', SalesHeader."Posting Date");
                SetFilter("End Date", '%1|%2..', 0D, SalesHeader."Posting Date");
                SalesInsertCalcLines(AccrualSearchLine, SalesHeader, SalesLine);
            end;

            if (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order"]) and // P8005495
             (SalesHeader."Order Date" <> 0D)                                                                                        // P8005495
            then begin                                                                                                               // P8005495
                SetRange("Date Type", "Date Type"::"Order Date");
                SetFilter("Start Date", '..%1', SalesHeader."Order Date");
                SetFilter("End Date", '%1|%2..', 0D, SalesHeader."Order Date");
                SalesInsertCalcLines(AccrualSearchLine, SalesHeader, SalesLine);
            end;
            // P800138545
            IF (SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::"Credit Memo"]) and // P8005495
             (SalesHeader."Posting Date" <> 0D)                                                                                        // P8005495
            then begin
                OrderDate := SalesHeader."Order Date";
                SalesHeader."Order Date" := SalesHeader."Posting Date";
                SetRange("Date Type", "Date Type"::"Order Date");
                SetFilter("Start Date", '..%1', SalesHeader."Order Date");
                SetFilter("End Date", '%1|%2..', 0D, SalesHeader."Order Date");
                SalesInsertCalcLines(AccrualSearchLine, SalesHeader, SalesLine);
                SalesHeader."Order Date" := OrderDate;
            end;
            // P800138545            
            // END;                   // P8000767

            // SETRANGE("Plan Type"); // P8000767
            SetRange("Date Type");
            SetRange("Start Date");
            SetRange("End Date");
        end;
    end;
}

