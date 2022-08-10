codeunit 37002048 "Sales Contract Management"
{
    // PRW16.00.06
    // P8001076, Columbus IT, Jack Reynolds, 13 JUN 12
    //   Remove Item Ledger Entry No. from Sales Contract History
    // 
    // P8001077, Columbus IT, Jack Reynolds, 13 JUN 12
    //   Avoid writing history lines for zer quantity
    // 
    // PRW19.00.01
    // P8007152, To-Increase, Dayakar Battini, 06 JUN 16
    //   Fix issue Resolve Shorts for Containers.
    // 
    // P8006433, To-Increase, Dayakar Battini, 29 JUN 16
    //   Handling page.runmodal error.
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    //   Correct misspellings
    // 
    // PRW110.0.01
    // P80042410, To-Increase, Dayakar Battini, 05 JUL 17
    //   Fix for contract line limit functionality.
    // 
    // PRW110.0.02
    // P80048138, To-Increase, Jack Reynolds, 01 NOV 17
    //   Fix problem when contract is not selected
    // 
    // PRW111.00
    // P80053245, To-Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80060646, To-Increase, Dayakar Battini, 20 JUN 18
    //   Handling of BilltoCustomer for sales prices
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80072447, To-Increase, Gangabhushan, 24 MAY 19
    //   Dev. Pricing information on the Sales Order Guide


    trigger OnRun()
    begin
    end;

    var
        NextContEntryNo: Integer;
        Text000: Label 'You must select a Contract Price!';
        Text001: Label 'There are no Contract Prices to use for Contract No. %1!';
        IsShortSubstituteItem: Boolean;
        Text002: Label 'Contract item %1 must not be selected for substitute.';
        ErrorTxtMultiLineContract: Label 'One or more contract lines exists for the sales lines. You must process by other means.  For example, process line by line.';

    procedure InsertSalesContractHist(DocNo: Code[20]; SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    var
        SalesContHist: Record "Sales Contract History";
        SalesContract: Record "Sales Contract";
        SalesContractLine: Record "Sales Contract Line";
        SalesPrice: Record "Sales Price";
        QtyCont: Decimal;
        QtyContLine: Decimal;
        QtyBase: Decimal;
    begin
        // P8001076 - removed ItemLedgEntryNo as a parameter
        if not (SalesLine."Document Type" in [SalesLine."Document Type"::Order, SalesLine."Document Type"::Invoice,
                                             SalesLine."Document Type"::"Credit Memo", SalesLine."Document Type"::"Return Order"]) or
                                             (SalesLine."Contract No." = '') or
                                             (SalesLine.Type <> SalesLine.Type::Item) or
                                             (SalesLine."No." = '')
        then
            exit;
        // P8001077 - moved up from below
        SalesLine."Qty. to Ship (Base)" := Abs(SalesLine."Qty. to Ship (Base)");
        SalesLine."Qty. to Invoice (Base)" := Abs(SalesLine."Qty. to Invoice (Base)");
        SalesLine."Qty. to Ship" := Abs(SalesLine."Qty. to Ship");
        SalesLine."Qty. to Invoice" := Abs(SalesLine."Qty. to Invoice");
        if SalesLine."Document Type" = SalesLine."Document Type"::Order then
            QtyBase := SalesLine."Qty. to Ship (Base)"
        else
            QtyBase := SalesLine."Qty. to Invoice (Base)";
        // P8001077 - moved up from below
        if QtyBase = 0 then // P8001077
            exit;             // P8001077

        SalesContract.Get(SalesLine."Contract No.");
        if NextContEntryNo = 0 then begin
            SalesContHist.LockTable;
            if SalesContHist.FindLast then
                NextContEntryNo := SalesContHist."Entry No." + 1
            else
                NextContEntryNo := 1;
        end else
            NextContEntryNo += 1;
        SalesPrice.SetCurrentKey("Price ID");
        SalesPrice.SetRange("Price ID", SalesLine."Price ID");
        SalesPrice.FindFirst;
        SalesContractLine.Get(SalesContract."No.", SalesPrice."Item Type", SalesPrice."Item Code"); // P8007749
        if (SalesContract."Contract Limit Unit of Measure" <> '') then
            QtyCont := ConvertLimitUOMFromBase(QtyBase, SalesLine."No.", SalesContract."Contract Limit Unit of Measure")
        else
            QtyCont := 0;
        if SalesContractLine."Line Limit Unit of Measure" <> '' then
            QtyContLine := ConvertLimitUOMFromBase(QtyBase, SalesLine."No.", SalesContractLine."Line Limit Unit of Measure")
        else
            QtyContLine := 0;
        SalesContHist.Init;
        SalesContHist."Entry No." := NextContEntryNo;
        SalesContHist."Contract No." := SalesLine."Contract No.";
        SalesContHist."Sales Price ID" := SalesLine."Price ID";
        SalesContHist."Contract Limit UOM" := SalesContract."Contract Limit Unit of Measure";
        SalesContHist."Contract Line Limit UOM" := SalesContractLine."Line Limit Unit of Measure";
        SalesContHist."Sales UOM" := SalesLine."Unit of Measure Code";
        case SalesLine."Document Type" of
            SalesLine."Document Type"::Order:
                begin
                    SalesContHist."Document Type" := SalesContHist."Document Type"::"Sales Shipment";
                    SalesContHist."Sales Quantity" := SalesLine."Qty. to Ship";
                    SalesContHist."Quantity (Contract)" := QtyCont;
                    SalesContHist."Quantity (Contract Line)" := QtyContLine;
                end;
            SalesLine."Document Type"::Invoice:
                begin
                    SalesContHist."Document Type" := SalesContHist."Document Type"::"Sales Invoice";
                    SalesContHist."Sales Quantity" := SalesLine."Qty. to Invoice";
                    SalesContHist."Quantity (Contract)" := QtyCont;
                    SalesContHist."Quantity (Contract Line)" := QtyContLine;
                end;
            SalesLine."Document Type"::"Credit Memo":
                begin
                    SalesContHist."Document Type" := SalesContHist."Document Type"::"Sales Credit Memo";
                    SalesContHist."Sales Quantity" := SalesLine."Qty. to Invoice";
                    SalesContHist."Quantity (Contract)" := -QtyCont;
                    SalesContHist."Quantity (Contract Line)" := -QtyContLine;
                end;
            SalesLine."Document Type"::"Return Order":
                begin
                    SalesContHist."Document Type" := SalesContHist."Document Type"::"Sales Return Receipt";
                    SalesContHist."Sales Quantity" := SalesLine."Qty. to Invoice";
                    SalesContHist."Quantity (Contract)" := -QtyCont;
                    SalesContHist."Quantity (Contract Line)" := -QtyContLine;
                end;
        end;
        SalesContHist."Document No." := DocNo;
        SalesContHist."Unit Price" := SalesLine."Unit Price";
        SalesContHist."Item No." := SalesLine."No.";
        SalesContHist."Customer No." := SalesLine."Bill-to Customer No.";
        //SalesContHist."Item Ledger Entry No." := ItemLedgEntryNo; // P8001076
        SalesContHist."Item Type" := SalesPrice."Item Type";
        SalesContHist."Item Code" := SalesPrice."Item Code";
        //SalesContHist."Item Code 2" := SalesPrice."Item Code 2"; // P8007749
        SalesContHist."Posting Date" := SalesHeader."Posting Date";
        SalesContHist."Document Line No." := SalesLine."Line No.";
        SalesContHist."Document Date" := SalesHeader."Document Date";
        SalesContHist."Price ID" := SalesLine."Price ID";
        SalesContHist."Limit Type" := SalesContractLine."Limit Type";     // P80042410
        SalesContHist.Insert;
    end;

    procedure SetContractFilters(SalesLine: Record "Sales Line"; var SalesPrice: Record "Sales Price")
    var
        SalesCont: Record "Sales Contract";
        SalesContLine: Record "Sales Contract Line";
        OldSalesLine: Record "Sales Line";
        TempSalesCont: Record "Sales Contract" temporary;
        ContLimitUsed: Decimal;
        ContLineLimitUsed: Decimal;
        ContUseDiff: Decimal;
        ContLineUseDiff: Decimal;
        SalesSetup: Record "Sales & Receivables Setup";
        Result: Action;
        SalesPrice2: Record "Sales Price";
        CallFromOrderGuide: Boolean;
    begin
        with SalesLine do begin
            if not ("Document Type" in ["Document Type"::Order, "Document Type"::Invoice,
                                        "Document Type"::"Credit Memo", "Document Type"::"Return Order"]) or
                                        not IsServiceTier
            then
                exit;
            SalesSetup.Get;
            OldSalesLine := SalesLine;
            if not OldSalesLine.Find then
                Clear(OldSalesLine);
            ContUseDiff := "Outstanding Qty. (Contract)" - OldSalesLine."Outstanding Qty. (Contract)";
            ContLineUseDiff := "Outstanding Qty. (Cont. Line)" - OldSalesLine."Outstanding Qty. (Cont. Line)";
            SalesPrice.SetCurrentKey("Contract No.");
            if "Contract No." <> '' then begin
                SalesPrice.SetRange("Contract No.", "Contract No.");
                SalesPrice.FindSet;
            end else begin
                SalesPrice.SetFilter("Contract No.", '<>%1', '');
                if not SalesPrice.FindSet then begin
                    SalesPrice.SetRange("Contract No.");
                    exit;
                end;
            end;
            repeat
                SalesContLine.Get(SalesPrice."Contract No.", SalesPrice."Item Type", SalesPrice."Item Code"); // P8007749
                SalesContLine.ApplyDocfilters(SalesLine."Document Type", SalesLine."Document No.");    // P80042410
                ContLineLimitUsed := SalesContLine.CalcLimitUsed;
                if ("Outstanding Qty. (Contract)" = 0) and ("Outstanding Qty. (Cont. Line)" = 0) then begin // New Line
                    if ((ContLineLimitUsed + ContLineUseDiff) >= SalesContLine."Line Limit") and
                       (SalesContLine."Line Limit" <> 0)
                    then
                        SalesPrice.Delete;
                end else begin
                    if ((ContLineLimitUsed + ContLineUseDiff) > SalesContLine."Line Limit") and
                       (SalesContLine."Line Limit" <> 0)
                    then
                        SalesPrice.Delete;
                end;
            until SalesPrice.Next = 0;
            if "Contract No." <> '' then
                SalesPrice.FindSet
            else
                if not SalesPrice.FindSet then begin
                    SalesPrice.SetRange("Contract No.");
                    exit;
                end;
            repeat
                SalesCont.Get(SalesPrice."Contract No.");
                ContLimitUsed := SalesCont.CalcLimitUsed;
                if ("Outstanding Qty. (Contract)" = 0) and ("Outstanding Qty. (Cont. Line)" = 0) then begin // New Line
                    if (((ContLimitUsed + ContUseDiff) < SalesCont."Contract Limit") or
                       (SalesCont."Contract Limit" = 0)) and
                       not TempSalesCont.Get(SalesCont."No.")
                    then begin
                        TempSalesCont := SalesCont;
                        TempSalesCont.Insert;
                    end;
                end else begin
                    if (((ContLimitUsed + ContUseDiff) <= SalesCont."Contract Limit") or
                       (SalesCont."Contract Limit" = 0)) and
                       not TempSalesCont.Get(SalesCont."No.")
                    then begin
                        TempSalesCont := SalesCont;
                        TempSalesCont.Insert;
                    end;
                end;
            until SalesPrice.Next = 0;
            if TempSalesCont.IsEmpty then begin
                if "Contract No." <> '' then
                    Error(Text001, "Contract No.");
                SalesPrice.SetRange("Contract No.", '');
                exit;
            end;
            if "Contract No." = '' then begin
                if IsShortSubstituteItem then           // P8007152
                    Error(Text002, SalesLine."No.");       // P8007152
                                                           // P8006433
                                                           // P80072447
                OnGetSetContractFilters(CallFromOrderGuide);
                if not CallFromOrderGuide then
                    // P80072447
                    if not TrySelectContract(TempSalesCont, Result) then
                        HandleErrorMessage();
                if Result = ACTION::LookupOK then begin
                    // P8006433
                    SalesPrice.SetRange("Contract No.", TempSalesCont."No.");
                    // P80042410
                    SalesPrice2.Copy(SalesPrice);
                    if SalesPrice2.FindFirst then;
                    SalesLine."Contract No." := TempSalesCont."No.";
                    SalesLine."Price ID" := SalesPrice2."Price ID";
                    if SalesLine.Quantity <> 0 then
                        ShowOverContLimitWarning(SalesLine);
                    // P80042410
                    exit;
                end else
                    if SalesSetup."Sales Contracts Mandatory" then
                        Error(Text000)
                    else begin
                        //SalesPrice.FILTERGROUP(9); // P80048138
                        SalesPrice.SetRange("Contract No.", '');
                        //SalesPrice.FILTERGROUP(0); // P80048138
                        exit;
                    end;
            end else begin
                SalesPrice.SetRange("Contract No.", "Contract No.");
                exit;
            end;
        end;
    end;

    [TryFunction]
    local procedure TrySelectContract(var TempSalesCont: Record "Sales Contract" temporary; var Result: Action)
    begin
        // P8006433
        ClearLastError;
        Result := PAGE.RunModal(PAGE::"Sales Contract List", TempSalesCont);
        // P8006433
    end;

    local procedure HandleErrorMessage()
    var
        ErrorText: Text;
    begin
        // P8006433
        ErrorText := CopyStr(GetLastErrorText, 1, MaxStrLen(ErrorText));
        if StrPos(ErrorText, 'RunModal') <> 0 then    // Error with form.RUNMODAL handling
            Error(ErrorTxtMultiLineContract)
        else
            Error(GetLastErrorText);
        // P8006433
    end;

    procedure ConvertLimitUOMFromBase(Qty: Decimal; ItemNo: Code[20]; ToUOM: Code[10]) QtyConverted: Decimal
    var
        FromUnitOfMeasure: Record "Unit of Measure";
        ToUnitOfMeasure: Record "Unit of Measure";
        FromItemUOM: Record "Item Unit of Measure";
        ToItemUOM: Record "Item Unit of Measure";
        P800UOMFunctions: Codeunit "Process 800 UOM Functions";
        UOMMgt: Codeunit "Unit of Measure Management";
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        FromUnitOfMeasure.Get(Item."Base Unit of Measure");
        ToUnitOfMeasure.Get(ToUOM);
        if (FromUnitOfMeasure.Type = ToUnitOfMeasure.Type) and (FromUnitOfMeasure.Type <> FromUnitOfMeasure.Type::" ") then
            QtyConverted := P800UOMFunctions.ConvertUOM(Qty, Item."Base Unit of Measure", ToUOM)
        else begin
            if FromItemUOM.Get(Item."No.", Item."Base Unit of Measure") and ToItemUOM.Get(Item."No.", ToUOM) then
                QtyConverted := Round(Qty / UOMMgt.GetQtyPerUnitOfMeasure(Item, ToUOM), 0.00001);
        end;
    end;

    procedure ShowOverContLimitWarning(SalesLine: Record "Sales Line")
    var
        SalesCont: Record "Sales Contract";
        SalesContLine: Record "Sales Contract Line";
        SalesPrice: Record "Sales Price";
        LimitTest000: Label 'If you continue you will exceed the Contract Limit for Contract No. %1. Do you wish to continue?';
        LimitText001: Label 'If you continue you will exceed the Contract Line Limit for Contract No. %1. Do you wish to continue?';
        LimitText002: Label 'Update stopped to heed limit warning!';
        OldSalesLine: Record "Sales Line";
    begin
        with SalesLine do begin
            if "Contract No." = '' then
                exit;
            OldSalesLine := SalesLine;
            //IF OldSalesLine.FIND THEN  // P80042410

            SalesCont.Get("Contract No.");
            SalesPrice.SetCurrentKey("Price ID");
            SalesPrice.SetRange("Price ID", "Price ID");
            SalesPrice.FindFirst;
            SalesContLine.Get("Contract No.", SalesPrice."Item Type", SalesPrice."Item Code"); // P8007749
                                                                                               // P80042410
            SalesContLine.ApplyDocfilters(SalesLine."Document Type", SalesLine."Document No.");
            if not OldSalesLine.Find then begin
                if SalesCont."Contract Limit Unit of Measure" <> '' then
                    "Outstanding Qty. (Contract)" :=
                          ConvertLimitUOMFromBase("Outstanding Qty. (Base)", "No.", SalesCont."Contract Limit Unit of Measure");
                if SalesContLine."Line Limit Unit of Measure" <> '' then
                    "Outstanding Qty. (Cont. Line)" :=
                          ConvertLimitUOMFromBase("Outstanding Qty. (Base)", "No.", SalesContLine."Line Limit Unit of Measure");
            end;
            // P80042410
            if ((SalesCont.CalcLimitUsed + "Outstanding Qty. (Contract)" - OldSalesLine."Outstanding Qty. (Contract)")
                 > SalesCont."Contract Limit") and
               (SalesCont."Contract Limit" <> 0)
            then
                if not Confirm(LimitTest000, true, "Contract No.") then
                    Error(LimitText002);
            if ((SalesContLine.CalcLimitUsed + SalesLine."Outstanding Qty. (Cont. Line)" - OldSalesLine."Outstanding Qty. (Cont. Line)")
                 > SalesContLine."Line Limit") and
               (SalesContLine."Line Limit" <> 0)
            then
                if not Confirm(LimitTest000, true, "Contract No.") then
                    Error(LimitText002);
        end;
    end;

    procedure ResetSalesContract(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        PriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";
    begin
        PriceCalcMgt.FindSalesLinePrice(SalesHeader, SalesLine, 0);
    end;

    procedure VerifyContract(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"): Boolean
    var
        PriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";
        TempSalesPrice: Record "Sales Price" temporary;
        SalesCont: Record "Sales Contract";
        SalesContLine: Record "Sales Contract Line";
    begin
        with SalesLine do begin
            PriceCalcMgt.FindSalesPrice(TempSalesPrice, "Bill-to Customer No.", SalesHeader."Bill-to Contact No.",
                                        "Customer Price Group", '', "No.", "Variant Code", "Unit of Measure Code",
                                        SalesHeader."Currency Code", SalesHeaderStartDate(SalesHeader), false);
            TempSalesPrice.SetCurrentKey("Price ID");
            TempSalesPrice.SetRange("Price ID", "Price ID");
            if not TempSalesPrice.FindFirst then
                exit(false);
            SalesCont.Get("Contract No.");
            SalesContLine.Get("Contract No.", TempSalesPrice."Item Type", TempSalesPrice."Item Code"); // P8007749
            SalesContLine.ApplyDocfilters(SalesLine."Document Type", SalesLine."Document No.");    // P80042410
            if (((SalesCont.CalcLimitUsed + "Outstanding Qty. (Contract)") <= SalesCont."Contract Limit") or
               (SalesCont."Contract Limit" = 0))
               and
               (((SalesContLine.CalcLimitUsed + SalesLine."Outstanding Qty. (Cont. Line)") <= SalesContLine."Line Limit") or
                (SalesContLine."Line Limit" = 0))
            then
                exit(true);
        end;
    end;

    local procedure SalesHeaderStartDate(SalesHeader: Record "Sales Header"): Date
    begin
        with SalesHeader do
            if "Document Type" in ["Document Type"::Invoice, "Document Type"::"Credit Memo"] then
                exit("Posting Date")
            else begin
                // PR3.70 Begin
                if ("Document Type" = "Document Type"::Order) and SalesHeader."Price at Shipment" then
                    exit("Posting Date")
                else
                    // PR3.70 End
                    exit("Order Date");
            end;
    end;

    procedure SetShortSubstituteItem()
    begin
        // P8007152
        IsShortSubstituteItem := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetSetContractFilters(var FromOrderGuide: Boolean)
    begin
        // P80072447
    end;
}

