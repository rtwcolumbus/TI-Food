codeunit 37002131 "Purchase Accrual Management"
{
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00.01
    // P8000274A, VerticalSoft, Jack Reynolds, 22 DEC 05
    //   Fix problems with resolving start and end dates for plan
    // 
    // PR4.00.04
    // P8000355A, VerticalSoft, Jack Reynolds, 19 JUL 06
    //   Add support for accrual groups
    // 
    // PR4.00.06
    // P8000464A, VerticalSoft, Don Bresee, 9 APR 07
    //   Return Orders were being ignored
    // 
    // PRW15.00.01
    // P8000601A, VerticalSoft, Don Bresee, 30 OCT 07
    //   Change search field sequence for SQL
    // 
    // PRW16.00.01
    // P8000690, VerticalSoft, Jack Reynolds, 23 APR 09
    //   Fix rounding problem with unit cost
    // 
    // P8000693, VerticalSoft, Jack Reynolds, 01 MAY 09
    //   Fix problem with currency rounding precision
    // 
    // P8000694, VerticalSoft, Jack Reynolds, 04 MAY 09
    //   Fix problems with currency issues
    // 
    // PRW16.00.02
    // P8000767, VerticalSoft, Jack Reynolds, 18 FEB 10
    //   Change order of fields on Accrual Search Line key
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

    local procedure IgnorePurchHeader(var PurchHeader: Record "Purchase Header"): Boolean
    begin
        with PurchHeader do
            exit(("Document Type" <> "Document Type"::Order) and
                 ("Document Type" <> "Document Type"::Invoice) and
                 ("Document Type" <> "Document Type"::"Return Order") and // P8000464A
                 ("Document Type" <> "Document Type"::"Credit Memo"));
    end;

    local procedure IgnorePurchLine(var PurchLine: Record "Purchase Line"): Boolean
    begin
        with PurchLine do
            exit((("Document Type" <> "Document Type"::Order) and                                 //P8007530;
                 ("Document Type" <> "Document Type"::Invoice) and
                 ("Document Type" <> "Document Type"::"Return Order") and // P8000464A
                 ("Document Type" <> "Document Type"::"Credit Memo")) or (Type <> Type::Item));   //P8007530;
    end;

    procedure PurchDeleteDocument(var PurchHeader: Record "Purchase Header")
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        with PurchHeader do begin
            if IgnorePurchHeader(PurchHeader) then
                exit;
            AccrualMgmt.DeleteAllDocLines(
              DocAccrualLine."Accrual Plan Type"::Purchase, "Document Type", "No.");
        end;
    end;

    procedure PurchDeleteLines(var PurchLine: Record "Purchase Line")
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        if AccrualMgmt.IsEnabled() then begin
            if IgnorePurchLine(PurchLine) then
                exit;
            PurchDeleteLineLevelLines(PurchLine);
            PurchUpdateDocLevelLines(PurchLine, true);
        end;
    end;

    local procedure PurchDeleteLineLevelLines(var PurchLine: Record "Purchase Line")
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        with PurchLine do begin
            if ("Line No." = 0) then
                AccrualMgmt.DeleteTempDocLines
            else
                AccrualMgmt.DeleteDocLines(
                  DocAccrualLine."Accrual Plan Type"::Purchase,
                  DocAccrualLine."Computation Level"::"Document Line",
                  "Document Type", "Document No.", "Line No.");
            CalcFields("Promo/Rebate Amount (LCY)", "Commission Amount (LCY)");
        end;
    end;

    procedure PurchInsertLines(var PurchLine: Record "Purchase Line")
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        if AccrualMgmt.IsEnabled() then begin
            if IgnorePurchLine(PurchLine) then
                exit;
            AccrualMgmt.InsertTempDocLines(PurchLine."Line No.");
            PurchUpdateDocLevelLines(PurchLine, false);
        end;
    end;

    procedure PurchBeginRecalcLines(var PurchLine: Record "Purchase Line")
    begin
        if AccrualMgmt.IsEnabled() then
            with PurchLine do begin
                "Direct Unit Cost" := "Direct Unit Cost" - "Accrual Amount (Cost)";
                "Accrual Amount (Cost)" := 0;
            end;
        AccrualMgmt.Disable;
    end;

    procedure PurchEndRecalcLines(var PurchLine: Record "Purchase Line")
    begin
        AccrualMgmt.Enable;
        PurchUpdateLines(PurchLine, false);
    end;

    procedure PurchRecalcLines(var PurchLine: Record "Purchase Line")
    begin
        PurchBeginRecalcLines(PurchLine);
        PurchEndRecalcLines(PurchLine);
    end;

    procedure PurchBeginNewCostLines(var PurchLine: Record "Purchase Line")
    begin
        if AccrualMgmt.IsEnabled() then
            with PurchLine do
                "Accrual Amount (Cost)" := 0;
        AccrualMgmt.Disable;
    end;

    procedure PurchEndNewCostLines(var PurchLine: Record "Purchase Line"; SettingUnitCost: Boolean)
    begin
        AccrualMgmt.Enable;
        PurchUpdateLines(PurchLine, SettingUnitCost);
    end;

    procedure SetPurchUnitCost(var PurchLine: Record "Purchase Line"; NewUnitCost: Decimal)
    begin
        with PurchLine do
            "Direct Unit Cost" := NewUnitCost;
        PurchBeginNewCostLines(PurchLine);
        PurchEndNewCostLines(PurchLine, true);
    end;

    procedure PurchUpdateLines(var PurchLine: Record "Purchase Line"; SettingUnitPrice: Boolean)
    var
        PurchHeader: Record "Purchase Header";
        AccrualPlan: Record "Accrual Plan";
    begin
        if AccrualMgmt.IsEnabled() then begin
            if IgnorePurchLine(PurchLine) then
                exit;
            PurchDeleteLineLevelLines(PurchLine);
            // PurchInsertPlanLines(PurchLine, SearchCompLevel::Line, FALSE); // P8000601A
            PurchInsertItemLinesSQL(PurchLine, SearchCompLevel::Line, false); // P8000601A
            with PurchLine do begin
                if ("Line No." <> 0) then
                    AccrualMgmt.InsertTempDocLines("Line No.");
                PurchUpdateUnitCost(PurchLine, SettingUnitPrice, false);
                if ("Line No." = 0) then
                    AccrualMgmt.CalcTempDocTotals("Promo/Rebate Amount (LCY)", "Commission Amount (LCY)")
                else
                    CalcFields("Promo/Rebate Amount (LCY)", "Commission Amount (LCY)");
            end;
        end;
    end;

    local procedure PurchUpdateDocLevelLines(var PurchLine: Record "Purchase Line"; Deleting: Boolean)
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        with PurchLine do
            if ("Line No." <> 0) then begin
                AccrualMgmt.DeleteDocLines(
                  DocAccrualLine."Accrual Plan Type"::Purchase,
                  DocAccrualLine."Computation Level"::Document,
                  "Document Type", "Document No.", 0);
                // PurchInsertPlanLines(PurchLine, SearchCompLevel::Header, Deleting); // P8000601A
                PurchInsertItemLinesSQL(PurchLine, SearchCompLevel::Header, Deleting); // P8000601A
                AccrualMgmt.InsertTempDocLines(0);
            end;
    end;

    local procedure PurchInsertPlanLines(var PurchLine: Record "Purchase Line"; ComputationLevel: Integer; Deleting: Boolean)
    var
        PurchHeader: Record "Purchase Header";
        AccrualSearchLine: Record "Accrual Plan Search Line";
        LineDiscountFactor: Decimal;
    begin
        DeletingLine := Deleting;
        SearchCompLevel := ComputationLevel;
        NonPricePromoAmount := 0;

        with PurchLine do begin
            if (Type <> Type::Item) or ("No." = '') or
               ((Quantity = 0) and ("Direct Unit Cost" = 0))
            then
                exit;
            PurchHeader.Get("Document Type", "Document No.");
        end;

        with AccrualSearchLine do begin
            SetCurrentKey(
              "Accrual Plan Type", "Computation Level", "Date Type", "Start Date", "End Date",
              "Source Selection Type", "Source Selection", "Source Code", "Source Ship-to Code",
              "Item Selection", "Item Code");

            SetRange("Accrual Plan Type", "Accrual Plan Type"::Purchase);
            SetRange("Computation Level", SearchCompLevel);

            if (PurchHeader."Posting Date" <> 0D) then begin
                SetRange("Date Type", "Date Type"::"Posting Date");
                SetFilter("Start Date", '..%1', PurchHeader."Posting Date");
                SetFilter("End Date", '%1|%2..', 0D, PurchHeader."Posting Date");
                PurchInsertSourceTypeLines(AccrualSearchLine, PurchHeader, PurchLine);
            end;

            if (PurchHeader."Document Type" in [PurchHeader."Document Type"::Order, PurchHeader."Document Type"::"Return Order"]) and // P8005495
             (PurchHeader."Order Date" <> 0D)                                                                                        // P8005495
            then begin                                                                                                               // P8005495
                SetRange("Date Type", "Date Type"::"Order Date");
                SetFilter("Start Date", '..%1', PurchHeader."Order Date");
                SetFilter("End Date", '%1|%2..', 0D, PurchHeader."Order Date");
                PurchInsertSourceTypeLines(AccrualSearchLine, PurchHeader, PurchLine);
            end;
        end;
    end;

    local procedure PurchInsertSourceTypeLines(var AccrualSearchLine: Record "Accrual Plan Search Line"; var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    begin
        with AccrualSearchLine do begin
            if not Find('-') then
                exit;

            if (PurchHeader."Pay-to Vendor No." <> '') then begin
                SetRange("Source Selection Type", "Source Selection Type"::"Bill-to/Pay-to");
                PurchInsertSourceLines(
                  AccrualSearchLine, PurchHeader, PurchLine, PurchHeader."Pay-to Vendor No.");
            end;

            if (PurchHeader."Buy-from Vendor No." <> '') then begin
                SetRange("Source Selection Type", "Source Selection Type"::"Sell-to/Buy-from");
                PurchInsertSourceLines(
                  AccrualSearchLine, PurchHeader, PurchLine, PurchHeader."Pay-to Vendor No.");
            end;

            SetRange("Source Selection Type");
        end;
    end;

    local procedure PurchInsertSourceLines(var AccrualSearchLine: Record "Accrual Plan Search Line"; var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; SourceNo: Code[20])
    var
        Vendor: Record Vendor;
        AccrualGroupLine: Record "Accrual Group Line";
    begin
        Vendor.Get(SourceNo);

        with AccrualSearchLine do begin
            if not Find('-') then
                exit;

            SetRange("Source Selection", "Source Selection"::All);
            PurchInsertItemLines(AccrualSearchLine, PurchHeader, PurchLine);

            /*P8000355A
            AccrualGroupLine.RESET;
            AccrualGroupLine.SETCURRENTKEY("Accrual Group Type", "No.", "Accrual Group Code");
            AccrualGroupLine.SETRANGE("Accrual Group Type", AccrualGroupLine."Accrual Group Type"::Vendor);
            AccrualGroupLine.SETRANGE("No.", SourceNo);
            IF AccrualGroupLine.FIND('-') THEN BEGIN
              SETRANGE("Source Selection", "Source Selection"::"Accrual Group");
              REPEAT
                SETRANGE("Source Code", AccrualGroupLine."Accrual Group Code");
                PurchInsertItemLines(AccrualSearchLine, PurchHeader, PurchLine);
              UNTIL (AccrualGroupLine.NEXT = 0);
            END;
            P8000355A*/

            SetRange("Source Selection", "Source Selection"::Specific);
            SetRange("Source Code", SourceNo);
            PurchInsertItemLines(AccrualSearchLine, PurchHeader, PurchLine);

            SetRange("Source Selection");
            SetRange("Source Code");
        end;

    end;

    local procedure PurchInsertItemLines(var AccrualSearchLine: Record "Accrual Plan Search Line"; var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    var
        AccrualGroupLine: Record "Accrual Group Line";
    begin
        if (Item."No." <> PurchLine."No.") then
            Item.Get(PurchLine."No.");

        with AccrualSearchLine do begin
            if not Find('-') then
                exit;

            SetRange("Item Selection", "Item Selection"::"All Items");
            PurchInsertCalcLines(AccrualSearchLine, PurchHeader, PurchLine);

            SetRange("Item Selection", "Item Selection"::"Specific Item");
            SetRange("Item Code", Item."No.");
            PurchInsertCalcLines(AccrualSearchLine, PurchHeader, PurchLine);

            if (Item."Item Category Code" <> '') then begin
                SetRange("Item Selection", "Item Selection"::"Item Category");
                SetRange("Item Code", Item."Item Category Code");
                PurchInsertCalcLines(AccrualSearchLine, PurchHeader, PurchLine);
            end;

            if (Item."Manufacturer Code" <> '') then begin
                SetRange("Item Selection", "Item Selection"::Manufacturer);
                SetRange("Item Code", Item."Manufacturer Code");
                PurchInsertCalcLines(AccrualSearchLine, PurchHeader, PurchLine);
            end;

            if (Item."Vendor No." <> '') then begin
                SetRange("Item Selection", "Item Selection"::"Vendor No.");
                SetRange("Item Code", Item."Vendor No.");
                PurchInsertCalcLines(AccrualSearchLine, PurchHeader, PurchLine);
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
                PurchInsertCalcLines(AccrualSearchLine, PurchHeader, PurchLine);
              UNTIL (AccrualGroupLine.NEXT = 0);
            END;
            P8000355A*/

            SetRange("Item Selection");
            SetRange("Item Code");
        end;

    end;

    local procedure PurchInsertCalcLines(var AccrualSearchLine: Record "Accrual Plan Search Line"; var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
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
                GetPurchAccrualAmount(AccrualPlan, PurchHeader, PurchLine, AccrualAmount); // P8000274A
                if (AccrualAmount <> 0) then begin
                    AccrualMgmt.GetPaymentDistribution(
                      Type, "No.", PurchHeader."Pay-to Vendor No.", AccrualAmount, TempJnlLine);
                    if TempJnlLine.Find('-') then
                        repeat
                            TempDocAccrualLine.Init;
                            TempDocAccrualLine."Accrual Plan Type" := Type;
                            TempDocAccrualLine."Document Type" := PurchLine."Document Type";
                            TempDocAccrualLine."Document No." := PurchLine."Document No.";
                            if ("Computation Level" = "Computation Level"::"Document Line") then
                                TempDocAccrualLine."Document Line No." := PurchLine."Line No."
                            else
                                TempDocAccrualLine."Document Line No." := 0;
                            TempDocAccrualLine."Plan Type" := "Plan Type";
                            TempDocAccrualLine."Computation Level" := "Computation Level";
                            TempDocAccrualLine.Validate("Accrual Plan No.", "No.");
                            TempDocAccrualLine.Type := TempJnlLine.Type;
                            TempDocAccrualLine.Validate("No.", TempJnlLine."No.");
                            TempDocAccrualLine.Description := PurchHeader."Posting Description";
                            TempDocAccrualLine."Accrual Amount (LCY)" := AccrualAmount;
                            TempDocAccrualLine.Validate("Payment Amount (LCY)", TempJnlLine.Amount);
                            TempDocAccrualLine."Orig. Payment Amount (LCY)" := TempDocAccrualLine."Payment Amount (LCY)";
                            AccrualMgmt.Insert1TempDocLine(TempDocAccrualLine);

                            if ("Plan Type" = "Plan Type"::"Promo/Rebate") and
                               ("Computation Level" = "Computation Level"::"Document Line") and
                               ("Price Impact" = "Price Impact"::None)
                            then
                                NonPricePromoAmount := NonPricePromoAmount + TempDocAccrualLine."Payment Amount (LCY)";
                        until (TempJnlLine.Next = 0);
                end;
            until (AccrualSearchLine.Next = 0);
    end;

    local procedure GetPurchAccrualAmount(var AccrualPlan: Record "Accrual Plan"; var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; var AccrualAmount: Decimal)
    var
        AccrualQty: Decimal;
        CostAmount: Decimal;
        PurchLine2: Record "Purchase Line";
        GLSetup: Record "General Ledger Setup";
    begin
        // P8000274A - add parameter PurchHeader
        AccrualQty := 0;
        CostAmount := 0;
        with AccrualPlan do begin
            if not DeletingLine then
                AccumPurchLineAmounts(                                          // P8000274A
                  AccrualPlan, PurchHeader, PurchLine, AccrualQty, CostAmount); // P8000274A
            if ("Computation Level" = "Computation Level"::Document) then begin
                PurchLine2.SetRange("Document Type", PurchLine."Document Type");
                PurchLine2.SetRange("Document No.", PurchLine."Document No.");
                PurchLine2.SetFilter("Line No.", '<>%1', PurchLine."Line No.");
                PurchLine2.SetRange(Type, PurchLine2.Type::Item);
                PurchLine2.SetFilter("No.", '<>%1', '');
                if PurchLine2.Find('-') then
                    repeat
                        AccumPurchLineAmounts(                                           // P8000274A
                          AccrualPlan, PurchHeader, PurchLine2, AccrualQty, CostAmount); // P8000274A
                    until (PurchLine2.Next = 0);
            end;
            // P8000694
            if PurchHeader."Currency Factor" <> 0 then
                CostAmount := CostAmount / PurchHeader."Currency Factor";
            if "Include Promo/Rebate" then
                CostAmount := CostAmount - NonPricePromoAmount;

            GLSetup.Get;
            CostAmount := Round(CostAmount, GLSetup."Amount Rounding Precision");
            // P8000694
            AccrualAmount :=                                                                             // P8000274A
              CalcAccrualAmount(PurchLine."No.", GetDocumentTransactionDate(PurchHeader), 0, CostAmount, AccrualQty); // P8000274A, P8005495
        end;
    end;

    local procedure AccumPurchLineAmounts(var AccrualPlan: Record "Accrual Plan"; var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; var AccrualQty: Decimal; var CostAmount: Decimal)
    var
        CostingQty: Decimal;
        QtyBase: Decimal;
        QtyAlt: Decimal;
    begin
        // P8000274A - add parameter PurchHeader
        with AccrualPlan do begin
            GetPurchQtys(AccrualPlan, PurchLine, CostingQty, QtyBase, QtyAlt);
            AccrualQty := AccrualQty +                                                           // P8000274A
              CalcAccrualQuantity(PurchLine."No.", GetDocumentTransactionDate(PurchHeader), QtyBase, QtyAlt); // P8000274A, P8005495
            CostAmount := CostAmount +
              (PurchLine."Direct Unit Cost" * CostingQty) -
              (PurchLine."Line Discount Amount" + PurchLine."Inv. Discount Amount");
            if ("Computation Level" = "Computation Level"::"Document Line") then
                CostAmount := CostAmount - PurchLine."Accrual Amount (Cost)" * CostingQty;
            //IF "Exclude Promo/Rebate" THEN                    // P8000694
            //  CostAmount := CostAmount - NonPricePromoAmount; // P8000694
        end;
    end;

    local procedure PurchUpdateUnitCost(var PurchLine: Record "Purchase Line"; SettingUnitCost: Boolean; ModifyRecord: Boolean)
    var
        PurchHeader: Record "Purchase Header";
        Currency: Record Currency;
        TargetUnitCost: Decimal;
        LastLineAmount: Decimal;
        LastUnitCost: Decimal;
        LineAmountChanges: Integer;
    begin
        if AccrualMgmt.IsEnabled() then
            with PurchLine do begin
                if IgnorePurchLine(PurchLine) then
                    exit;

                if ("Currency Code" = '') then
                    Currency.InitRoundingPrecision // P8000693
                else
                    Currency.Get("Currency Code");
                PurchHeader.Get("Document Type", "Document No."); // P8000694

                TargetUnitCost := "Direct Unit Cost";
                repeat
                    LastLineAmount := "Line Amount";
                    LastUnitCost := "Direct Unit Cost";
                    "Direct Unit Cost" := TargetUnitCost - "Accrual Amount (Cost)";
                    if (GetCostingQty() = 0) then
                        "Accrual Amount (Cost)" := 0
                    else begin                                                                              // P8000694
                        "Accrual Amount (Cost)" := PurchPriceImpact(PurchLine) / GetCostingQty();
                        if PurchHeader."Currency Factor" <> 0 then                                            // P8000694
                            "Accrual Amount (Cost)" := "Accrual Amount (Cost)" * PurchHeader."Currency Factor"; // P8000694
                        "Accrual Amount (Cost)" := Round("Accrual Amount (Cost)", Currency."Unit-Amount Rounding Precision"); // P8000690
                    end;                                                                                    // P8000694
                    "Direct Unit Cost" := "Direct Unit Cost" + "Accrual Amount (Cost)";
                    "Line Amount" :=
                      Round(GetCostingQty() * "Direct Unit Cost", Currency."Amount Rounding Precision") -
                      "Line Discount Amount";
                    if ("Line Amount" <> LastLineAmount) then begin
                        UpdateAmounts;
                        if SettingUnitCost then begin
                            PurchDeleteLineLevelLines(PurchLine);
                            // PurchInsertPlanLines(PurchLine, SearchCompLevel::Line, FALSE); // P8000601A
                            PurchInsertItemLinesSQL(PurchLine, SearchCompLevel::Line, false); // P8000601A
                            if ("Line No." <> 0) then
                                AccrualMgmt.InsertTempDocLines("Line No.");
                        end;
                        LineAmountChanges := LineAmountChanges + 1;
                    end;
                until (not SettingUnitCost) or (LineAmountChanges > 9) or
                      ((Abs("Line Amount" - LastLineAmount) < Currency."Amount Rounding Precision") and
                       (Abs("Direct Unit Cost" - LastUnitCost) < Currency."Unit-Amount Rounding Precision"));

                if ModifyRecord and (LineAmountChanges > 0) then
                    Modify(true);
                PurchUpdateDocLevelLines(PurchLine, false);
            end;
    end;

    procedure GetPurchQtys(var AccrualPlan: Record "Accrual Plan"; var PurchLine: Record "Purchase Line"; var CostingQty: Decimal; var QtyBase: Decimal; var QtyAlt: Decimal)
    begin
        with PurchLine do begin
            CostingQty := GetCostingQty();
            QtyBase := "Quantity (Base)";
            QtyAlt := "Quantity (Alt.)";
        end;
    end;

    procedure PurchPromoRebateDrillDown(var PurchLine: Record "Purchase Line")
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        PurchBeforeDrillDown(PurchLine);
        with DocAccrualLine do
            AccrualMgmt.DocPlanTypeDrillDown(
              "Accrual Plan Type"::Purchase, "Plan Type"::"Promo/Rebate", "Computation Level"::"Document Line",
              PurchLine."Document Type", PurchLine."Document No.", PurchLine."Line No.");

        PurchUpdateUnitCost(PurchLine, false, true);
    end;

    procedure PurchCommissionDrillDown(var PurchLine: Record "Purchase Line")
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        PurchBeforeDrillDown(PurchLine);
        with DocAccrualLine do
            AccrualMgmt.DocPlanTypeDrillDown(
              "Accrual Plan Type"::Purchase, "Plan Type"::Commission, "Computation Level"::"Document Line",
              PurchLine."Document Type", PurchLine."Document No.", PurchLine."Line No.");

        PurchUpdateUnitCost(PurchLine, false, true);
    end;

    procedure PurchPriceImpact(var PurchLine: Record "Purchase Line"): Decimal
    begin
        with PurchLine do begin
            if ("Line No." = 0) then
                exit(AccrualMgmt.CalcTempDocPriceImpact(
                  "Acc. Incl. in Cost (LCY)", "Acc. Excl. from Cost (LCY)"));
            CalcFields("Acc. Incl. in Cost (LCY)", "Acc. Excl. from Cost (LCY)");
            exit("Acc. Incl. in Cost (LCY)" - "Acc. Excl. from Cost (LCY)");
        end;
    end;

    procedure PurchPriceImpactDrillDown(var PurchLine: Record "Purchase Line")
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        PurchBeforeDrillDown(PurchLine);
        with DocAccrualLine do
            AccrualMgmt.DocPriceImpactDrillDown(
              "Accrual Plan Type"::Purchase, PurchLine."Document Type",
              PurchLine."Document No.", PurchLine."Line No.");
    end;

    local procedure PurchBeforeDrillDown(var PurchLine: Record "Purchase Line")
    begin
        with PurchLine do begin
            TestField(Type, Type::Item);
            TestField("No.");
        end;
    end;

    procedure PurchDocPromoRebateDrillDown(var PurchHeader: Record "Purchase Header")
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        with DocAccrualLine do
            AccrualMgmt.DocPlanTypeDrillDown(
              "Accrual Plan Type"::Purchase, "Plan Type"::"Promo/Rebate", "Computation Level"::Document,
              PurchHeader."Document Type", PurchHeader."No.", 0);
    end;

    procedure PurchDocCommissionDrillDown(var PurchHeader: Record "Purchase Header")
    var
        DocAccrualLine: Record "Document Accrual Line";
    begin
        with DocAccrualLine do
            AccrualMgmt.DocPlanTypeDrillDown(
              "Accrual Plan Type"::Purchase, "Plan Type"::Commission, "Computation Level"::Document,
              PurchHeader."Document Type", PurchHeader."No.", 0);
    end;

    procedure PurchInvPriceImpact(var PurchInvLine: Record "Sales Invoice Line"): Decimal
    begin
        with PurchInvLine do begin
            CalcFields("Acc. Incl. in Price (LCY)", "Acc. Excl. from Price (LCY)");
            exit("Acc. Incl. in Price (LCY)" - "Acc. Excl. from Price (LCY)");
        end;
    end;

    procedure PurchInvPriceImpactDrillDown(var PurchInvLine: Record "Sales Invoice Line")
    var
        AccrualLedgEntry: Record "Accrual Ledger Entry";
    begin
        with PurchInvLine do begin
            TestField(Type, Type::Item);
            TestField("No.");
        end;

        with AccrualLedgEntry do
            AccrualMgmt.LedgPriceImpactDrillDown(
              "Accrual Plan Type"::Purchase, "Source Document Type"::Invoice,
              PurchInvLine."Document No.", PurchInvLine."Line No.");
    end;

    local procedure PurchInsertItemLinesSQL(var PurchLine: Record "Purchase Line"; ComputationLevel: Integer; Deleting: Boolean)
    var
        PurchHeader: Record "Purchase Header";
        AccrualSearchLine: Record "Accrual Plan Search Line";
        ItemCategory: Record "Item Category";
    begin
        // P8000601A
        DeletingLine := Deleting;
        SearchCompLevel := ComputationLevel;
        NonPricePromoAmount := 0;

        with PurchLine do begin
            if (Type <> Type::Item) or ("No." = '') or
               ((Quantity = 0) and ("Direct Unit Cost" = 0))
            then
                exit;
            PurchHeader.Get("Document Type", "Document No.");

            if (Item."No." <> "No.") then
                Item.Get("No.");
        end;

        with AccrualSearchLine do begin
            SetCurrentKey( // P8000767 - "Plan Type" moved in the key
              "Accrual Plan Type", "Computation Level", "Plan Type", "Item Selection", "Item Code",
              "Source Selection Type", "Source Selection", "Source Code", "Source Ship-to Code",
              "Date Type", "Start Date", "End Date");

            SetRange("Accrual Plan Type", "Accrual Plan Type"::Purchase);
            SetRange("Computation Level", SearchCompLevel);

            SetRange("Item Selection", "Item Selection"::"All Items");
            SetRange("Item Code", '');
            PurchInsertSourceTypeLinesSQL(AccrualSearchLine, PurchHeader, PurchLine);

            SetRange("Item Selection", "Item Selection"::"Specific Item");
            SetRange("Item Code", Item."No.");
            PurchInsertSourceTypeLinesSQL(AccrualSearchLine, PurchHeader, PurchLine);

            if (Item."Item Category Code" <> '') then begin
                SetRange("Item Selection", "Item Selection"::"Item Category");
                // P8007749
                //SETRANGE("Item Code", Item."Item Category Code");
                ItemCategory.Get(Item."Item Category Code");
                SetFilter("Item Code", ItemCategory.GetAncestorFilterString(true));
                // P8007749
                PurchInsertSourceTypeLinesSQL(AccrualSearchLine, PurchHeader, PurchLine);
            end;

            if (Item."Manufacturer Code" <> '') then begin
                SetRange("Item Selection", "Item Selection"::Manufacturer);
                SetRange("Item Code", Item."Manufacturer Code");
                PurchInsertSourceTypeLinesSQL(AccrualSearchLine, PurchHeader, PurchLine);
            end;

            if (Item."Vendor No." <> '') then begin
                SetRange("Item Selection", "Item Selection"::"Vendor No.");
                SetRange("Item Code", Item."Vendor No.");
                PurchInsertSourceTypeLinesSQL(AccrualSearchLine, PurchHeader, PurchLine);
            end;
        end;
    end;

    local procedure PurchInsertSourceTypeLinesSQL(var AccrualSearchLine: Record "Accrual Plan Search Line"; var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    begin
        // P8000601A
        with AccrualSearchLine do begin
            if not Find('-') then
                exit;

            if (PurchHeader."Pay-to Vendor No." <> '') then begin
                SetRange("Source Selection Type", "Source Selection Type"::"Bill-to/Pay-to");
                PurchInsertSourceLinesSQL(
                  AccrualSearchLine, PurchHeader, PurchLine, PurchHeader."Pay-to Vendor No.");
            end;

            if (PurchHeader."Buy-from Vendor No." <> '') then begin
                SetRange("Source Selection Type", "Source Selection Type"::"Sell-to/Buy-from");
                PurchInsertSourceLinesSQL(
                  AccrualSearchLine, PurchHeader, PurchLine, PurchHeader."Pay-to Vendor No.");
            end;

            SetRange("Source Selection Type");
        end;
    end;

    local procedure PurchInsertSourceLinesSQL(var AccrualSearchLine: Record "Accrual Plan Search Line"; var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; SourceNo: Code[20])
    var
        Vendor: Record Vendor;
    begin
        // P8000601A
        Vendor.Get(SourceNo);

        with AccrualSearchLine do begin
            if not Find('-') then
                exit;

            SetRange("Source Selection", "Source Selection"::All);
            SetRange("Source Code", '');
            PurchInsertPlanLinesSQL(AccrualSearchLine, PurchHeader, PurchLine);

            SetRange("Source Selection", "Source Selection"::Specific);
            SetRange("Source Code", SourceNo);
            PurchInsertPlanLinesSQL(AccrualSearchLine, PurchHeader, PurchLine);

            SetRange("Source Selection");
            SetRange("Source Code");
        end;
    end;

    local procedure PurchInsertPlanLinesSQL(var AccrualSearchLine: Record "Accrual Plan Search Line"; var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    var
        OrderDate: Date;
    begin
        // P8000601A
        with AccrualSearchLine do begin
            if not Find('-') then
                exit;

            if (PurchHeader."Posting Date" <> 0D) then begin
                SetRange("Date Type", "Date Type"::"Posting Date");
                SetFilter("Start Date", '..%1', PurchHeader."Posting Date");
                SetFilter("End Date", '%1|%2..', 0D, PurchHeader."Posting Date");
                PurchInsertCalcLines(AccrualSearchLine, PurchHeader, PurchLine);
            end;

            if (PurchHeader."Document Type" in [PurchHeader."Document Type"::Order, PurchHeader."Document Type"::"Return Order"]) and // P8005495
             (PurchHeader."Order Date" <> 0D)                                                                                        // P8005495
            then begin                                                                                                               // P8005495
                SetRange("Date Type", "Date Type"::"Order Date");
                SetFilter("Start Date", '..%1', PurchHeader."Order Date");
                SetFilter("End Date", '%1|%2..', 0D, PurchHeader."Order Date");
                PurchInsertCalcLines(AccrualSearchLine, PurchHeader, PurchLine);
            end;
            // P800138545
            if (PurchHeader."Document Type" in [PurchHeader."Document Type"::Invoice, PurchHeader."Document Type"::"Credit Memo"]) and // P8005495
             (PurchHeader."Posting Date" <> 0D)                                                                                        // P8005495
            then begin                                                                                                              // P8005495
                OrderDate := PurchHeader."Order Date";
                PurchHeader."Order Date" := PurchHeader."Posting Date"; // P8005495    
                SetRange("Date Type", "Date Type"::"Order Date");
                SetFilter("Start Date", '..%1', PurchHeader."Order Date");
                SetFilter("End Date", '%1|%2..', 0D, PurchHeader."Order Date");
                PurchInsertCalcLines(AccrualSearchLine, PurchHeader, PurchLine);
                PurchHeader."Order Date" := OrderDate;
            end;
            // P800138545
            SetRange("Date Type");
            SetRange("Start Date");
            SetRange("End Date");
        end;
    end;
}

