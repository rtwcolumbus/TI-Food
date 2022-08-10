#if not CLEAN19
codeunit 7000 "Sales Price Calc. Mgt."
{
    // PR3.10.P
    //   Fix to Get Price, wrong UOM passed to ConvertPriceToUoM
    //   Sales Pricing
    //     Add Break Charge
    // 
    // PR3.60.02
    //   Fix running of improper form in GetSalesLinePrice and GetSalesLineLineDisc
    // 
    // PR3.70
    //   Integration of P800 into 3.70  Support for contract items only
    // 
    // PR3.70.07
    // P8000145A, Myers Nissi, Jack Reynolds, 18 NOV 04
    //   FindSalesLinePrice - add Container to case statement with Item
    // 
    // PR4.00
    // P8000247A, Myers Nissi, Jack Reynolds, 05 OCT 05
    //   Renamed price list functions to include 'Customer"; copied and modified them for price groups
    // 
    // P8000249A, Myers Nissi, Jack Reynolds, 13 OCT 05
    //   Modify FindCustomerPriceListPrice and FindPriceGroupPriceListPrice to adjust unit price for
    //    accruals with price impact
    // 
    // P8000253A, Myers Nissi, Jack Reynolds, 26 OCT 05
    //   Add support for variant code on price list pricing functions
    // 
    // PR4.00.05
    // P8000440A, VerticalSoft, Jack Reynolds, 24 JAN 07
    //   Proper handling of Line Discount Type
    // 
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Add price rounding method
    //   InitCurrencyAndTaxVars - SalesLine.GetDate was returning a blank date (from the SalesHeader)
    // 
    // P8000545A, VerticalSoft, Don Bresee, 13 NOV 07
    //   Use proper price group for price list
    // 
    // PRW16.00.01
    // P8000700, VerticalSoft, Jack Reynolds, 21 MAY 09
    //   Make ActivatedCampaignExists a global function
    // 
    // PRW16.00.04
    // P8000885, VerticalSoft, Ron Davidson, 27 DEC 10
    //   Added logic to open a page and let the user select a Sales Contract for pricing if one exists.
    //   Filter on Contract No. when GetSalesLinePrice is run.
    // 
    // PRW16.00.05
    // P8000921, Columbus IT, Don Bresee, 08 APR 11
    //   Modify "Get Sales Price" logic for FOB/Freight
    // 
    // P8000982, Columbus IT, Jack Reynolds, 22 SEP 11
    //   Fix problem displaying prices
    // 
    // P8000981, Columbus IT, Don Bresee, 20 SEP 11
    //   Use Pricing Qty for Minimum Qty calculation
    // 
    // PRW16.00.06
    // P8000999, Columbus IT, Jack Reynolds, 09 DEC 11
    //   Fix problem calculating sales price when called from order guide
    // 
    // P8001026, Columbus IT, Jack Reynolds, 26 JAN 12
    //   Option to use Sell-to Customer Price Group
    // 
    // PRW17.00.01
    // P8001178, Columbus IT, Jack Reynolds, 05 JUL 13
    //   Fix problem with Allow Line Disc.
    // 
    // P8007152, To-Increase, Dayakar Battini, 06 JUN 16
    //   Fix issue Resolve Shorts for Containers.
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80072447, To-increase, Gangabhushan, 10 APR 19
    //   Dev. Pricing information on the Sales Order Guide

    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
    ObsoleteTag = '16.0';

    trigger OnRun()
    begin
    end;

    var
        GLSetup: Record "General Ledger Setup";
        Item: Record Item;
        ResPrice: Record "Resource Price";
        Res: Record Resource;
        Currency: Record Currency;
        Text000: Label '%1 is less than %2 in the %3.';
        Text010: Label 'Prices including VAT cannot be calculated when %1 is %2.';
        TempSalesPrice: Record "Sales Price" temporary;
        TempSalesLineDisc: Record "Sales Line Discount" temporary;
        LineDiscPerCent: Decimal;
        Qty: Decimal;
        AllowLineDisc: Boolean;
        AllowInvDisc: Boolean;
        VATPerCent: Decimal;
        PricesInclVAT: Boolean;
        VATCalcType: Option "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax";
        VATBusPostingGr: Code[20];
        QtyPerUOM: Decimal;
        PricesInCurrency: Boolean;
        CurrencyFactor: Decimal;
        ExchRateDate: Date;
        Text018: Label '%1 %2 is greater than %3 and was adjusted to %4.';
        FoundSalesPrice: Boolean;
        Text001: Label 'The %1 in the %2 must be same as in the %3.';
        TempTableErr: Label 'The table passed as a parameter must be temporary.';
        HideResUnitPriceMessage: Boolean;
        DateCaption: Text[30];
        SourceSalesPrice: Record "Sales Price";
        SourceSalesLineDisc: Record "Sales Line Discount";
        ItemSalesPriceMgmt: Codeunit "Item Sales Price Management";
        PostingShipment: Boolean;
        ContractItem: Boolean;
        Text37002000: Label 'The total ordered quantity at this price is greater than %1 in the %2.';
        ProcessFns: Codeunit "Process 800 Functions";
        SalesContMgmt: Codeunit "Sales Contract Management";
        IsShortSubstituteItem: Boolean;

    procedure FindSalesLinePrice(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CalledByFieldNo: Integer)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeFindSalesLinePrice(SalesLine, SalesHeader, CalledByFieldNo, IsHandled);
        if IsHandled then
            exit;

        ContractItem := false; // P800
        with SalesLine do begin
            SetCurrency(
              SalesHeader."Currency Code", SalesHeader."Currency Factor", SalesHeaderExchDate(SalesHeader));
            SetVAT(SalesHeader."Prices Including VAT", "VAT %", "VAT Calculation Type".AsInteger(), "VAT Bus. Posting Group");
            SetUoM(Abs(Quantity), "Qty. per Unit of Measure");
            SetLineDisc("Line Discount %", "Allow Line Disc.", "Allow Invoice Disc.");

            TestField("Qty. per Unit of Measure");
            if PricesInCurrency then
                SalesHeader.TestField("Currency Factor");

            case Type of
                Type::Item, Type::FOODContainer: // P8000145A
                    begin
                        Item.Get("No.");
                        SalesLinePriceExists(SalesHeader, SalesLine, false);
                        if ProcessFns.PricingInstalled and IsShortSubstituteItem then   // P8007152
                            SalesContMgmt.SetShortSubstituteItem();                        // P8007152
                                                                                           // P8000885
                        if ProcessFns.PricingInstalled and
                           (CalledByFieldNo in                                                                                     // P8000999
                             [-1, SalesLine.FieldNo("No."), SalesLine.FieldNo(Quantity), SalesLine.FieldNo("Unit of Measure Code")]) // P8000999
                        then
                            SalesContMgmt.SetContractFilters(SalesLine, TempSalesPrice);
                        // P8000885
                        AllowLineDisc := SalesHeader."Allow Line Disc."; // P8001178
                        CalcBestUnitPrice(TempSalesPrice);
                        OnAfterFindSalesLineItemPrice(SalesLine, TempSalesPrice, FoundSalesPrice, CalledByFieldNo);
                        if FoundSalesPrice or
                           not ((CalledByFieldNo = FieldNo(Quantity)) or
                                (CalledByFieldNo = FieldNo("Variant Code")))
                        then begin
                            "Allow Line Disc." := TempSalesPrice."Allow Line Disc.";
                            "Allow Invoice Disc." := TempSalesPrice."Allow Invoice Disc.";
                            "Unit Price" := TempSalesPrice."Unit Price";

                            "Price ID" := TempSalesPrice."Price ID"; // PR3.60
                            "Contract No." := TempSalesPrice."Contract No."; // P8000885
                            OnFindSalesLinePriceOnItemTypeOnAfterSetUnitPrice(SalesHeader, SalesLine, TempSalesPrice, CalledByFieldNo, FoundSalesPrice);
                            InitOutstandingQtyCont; // P8000885
                                                    // P8001178
                        end else begin
                            "Allow Line Disc." := SalesHeader."Allow Line Disc.";
                            // P8001178
                        end;
                        if not "Allow Line Disc." then
                            "Line Discount %" := 0;
                    end;
                Type::Resource:
                    begin
                        SetResPrice("No.", "Work Type Code", "Currency Code");
                        OnFindSalesLinePriceOnAfterSetResPrice(SalesLine, ResPrice);
                        CODEUNIT.Run(CODEUNIT::"Resource-Find Price", ResPrice);
                        OnAfterFindSalesLineResPrice(SalesLine, ResPrice);
                        ConvertPriceToVAT(false, '', '', ResPrice."Unit Price");
                        ConvertPriceLCYToFCY(ResPrice."Currency Code", ResPrice."Unit Price");
                        "Unit Price" := ResPrice."Unit Price" * "Qty. per Unit of Measure";
                    end;
            end;
            OnAfterFindSalesLinePrice(SalesLine, SalesHeader, TempSalesPrice, ResPrice, CalledByFieldNo, FoundSalesPrice);
        end;
    end;

    procedure FindItemJnlLinePrice(var ItemJnlLine: Record "Item Journal Line"; CalledByFieldNo: Integer)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeFindItemJnlLinePrice(ItemJnlLine, CalledByFieldNo, IsHandled);
        if IsHandled then
            exit;

        with ItemJnlLine do begin
            SetCurrency('', 0, 0D);
            SetVAT(false, 0, 0, '');
            SetUoM(Abs(Quantity), "Qty. per Unit of Measure");
            TestField("Qty. per Unit of Measure");
            Item.Get("Item No.");

            FindSalesPrice(
              TempSalesPrice, '', '', '', '', "Item No.", "Variant Code",
              "Unit of Measure Code", '', "Posting Date", false);
            CalcBestUnitPrice(TempSalesPrice);
            if FoundSalesPrice or
               not ((CalledByFieldNo = FieldNo(Quantity)) or
                    (CalledByFieldNo = FieldNo("Variant Code")))
            then
                Validate("Unit Amount", TempSalesPrice."Unit Price");
            OnAfterFindItemJnlLinePrice(ItemJnlLine, TempSalesPrice, CalledByFieldNo, FoundSalesPrice);
        end;
    end;

    procedure FindServLinePrice(ServHeader: Record "Service Header"; var ServLine: Record "Service Line"; CalledByFieldNo: Integer)
    var
        ServCost: Record "Service Cost";
        Res: Record Resource;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeFindServLinePrice(ServLine, ServHeader, CalledByFieldNo, IsHandled);
        if IsHandled then
            exit;

        with ServLine do begin
            ServHeader.Get("Document Type", "Document No.");
            if Type <> Type::" " then begin
                SetCurrency(
                  ServHeader."Currency Code", ServHeader."Currency Factor", ServHeaderExchDate(ServHeader));
                SetVAT(ServHeader."Prices Including VAT", "VAT %", "VAT Calculation Type".AsInteger(), "VAT Bus. Posting Group");
                SetUoM(Abs(Quantity), "Qty. per Unit of Measure");
                SetLineDisc("Line Discount %", "Allow Line Disc.", false);

                TestField("Qty. per Unit of Measure");
                if PricesInCurrency then
                    ServHeader.TestField("Currency Factor");
            end;

            case Type of
                Type::Item:
                    begin
                        ServLinePriceExists(ServHeader, ServLine, false);
                        CalcBestUnitPrice(TempSalesPrice);
                        if FoundSalesPrice or
                           not ((CalledByFieldNo = FieldNo(Quantity)) or
                                (CalledByFieldNo = FieldNo("Variant Code")))
                        then begin
                            if "Line Discount Type" = "Line Discount Type"::"Line Disc." then
                                "Allow Line Disc." := TempSalesPrice."Allow Line Disc.";
                            "Unit Price" := TempSalesPrice."Unit Price";
                        end;
                        if not "Allow Line Disc." and ("Line Discount Type" = "Line Discount Type"::"Line Disc.") then
                            "Line Discount %" := 0;
                    end;
                Type::Resource:
                    begin
                        SetResPrice("No.", "Work Type Code", "Currency Code");
                        CODEUNIT.Run(CODEUNIT::"Resource-Find Price", ResPrice);
                        OnAfterFindServLineResPrice(ServLine, ResPrice);
                        ConvertPriceToVAT(false, '', '', ResPrice."Unit Price");
                        ResPrice."Unit Price" := ResPrice."Unit Price" * "Qty. per Unit of Measure";
                        ConvertPriceLCYToFCY(ResPrice."Currency Code", ResPrice."Unit Price");
                        if (ResPrice."Unit Price" > ServHeader."Max. Labor Unit Price") and
                           (ServHeader."Max. Labor Unit Price" <> 0)
                        then begin
                            Res.Get("No.");
                            "Unit Price" := ServHeader."Max. Labor Unit Price";
                            if (HideResUnitPriceMessage = false) and
                               (CalledByFieldNo <> FieldNo(Quantity))
                            then
                                Message(
                                  StrSubstNo(
                                    Text018,
                                    Res.TableCaption, FieldCaption("Unit Price"),
                                    ServHeader.FieldCaption("Max. Labor Unit Price"),
                                    ServHeader."Max. Labor Unit Price"));
                            HideResUnitPriceMessage := true;
                        end else
                            "Unit Price" := ResPrice."Unit Price";
                    end;
                Type::Cost:
                    begin
                        ServCost.Get("No.");

                        ConvertPriceToVAT(false, '', '', ServCost."Default Unit Price");
                        ConvertPriceLCYToFCY('', ServCost."Default Unit Price");
                        "Unit Price" := ServCost."Default Unit Price";
                    end;
            end;
            OnAfterFindServLinePrice(ServLine, ServHeader, TempSalesPrice, ResPrice, ServCost, CalledByFieldNo);
        end;
    end;

    procedure FindSalesLineLineDisc(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeFindSalesLineLineDisc(SalesLine, SalesHeader, IsHandled);
        if IsHandled then
            exit;

        with SalesLine do begin
            SetCurrency(SalesHeader."Currency Code", 0, 0D);
            SetUoM(Abs(Quantity), "Qty. per Unit of Measure");

            TestField("Qty. per Unit of Measure");

            IsHandled := false;
            OnFindSalesLineLineDiscOnBeforeCalcLineDisc(SalesHeader, SalesLine, TempSalesLineDisc, Qty, QtyPerUOM, IsHandled);
            if not IsHandled then
                if Type = Type::Item then begin
                    Item.Get("No."); // P8007749
                    SalesLineLineDiscExists(SalesHeader, SalesLine, false);
                    CalcBestLineDisc(TempSalesLineDisc);

                    //"Line Discount %" := TempSalesLineDisc."Line Discount %"; // P8000440A
                    // P8000440A
                    "Line Discount Type" := TempSalesLineDisc."Line Discount Type";
                    case "Line Discount Type" of
                        "Line Discount Type"::Percent:
                            "Line Discount %" := TempSalesLineDisc."Line Discount %";
                        "Line Discount Type"::Amount:
                            "Line Discount Amount" := TempSalesLineDisc."Line Discount Amount";
                        "Line Discount Type"::"Unit Amount":
                            "Line Discount Unit Amount" := TempSalesLineDisc."Line Discount Amount";
                    end;
                    // P8000440A
                end;

            OnAfterFindSalesLineLineDisc(SalesLine, SalesHeader, TempSalesLineDisc);
        end;
    end;

    procedure FindServLineDisc(ServHeader: Record "Service Header"; var ServLine: Record "Service Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeFindServLineDisc(ServHeader, ServLine, IsHandled);
        if IsHandled then
            exit;

        with ServLine do begin
            SetCurrency(ServHeader."Currency Code", 0, 0D);
            SetUoM(Abs(Quantity), "Qty. per Unit of Measure");

            TestField("Qty. per Unit of Measure");

            if Type = Type::Item then begin
                Item.Get("No.");
                FindSalesLineDisc(
                  TempSalesLineDisc, "Bill-to Customer No.", ServHeader."Contact No.",
                  "Customer Disc. Group", '', "No.", Item."Item Disc. Group", "Variant Code",
                  "Unit of Measure Code", ServHeader."Currency Code", ServHeader."Order Date", false);
                CalcBestLineDisc(TempSalesLineDisc);
                "Line Discount %" := TempSalesLineDisc."Line Discount %";
            end;
            if Type in [Type::Resource, Type::Cost, Type::"G/L Account"] then begin
                "Line Discount %" := 0;
                "Line Discount Amount" :=
                  Round(
                    Round(CalcChargeableQty * "Unit Price", Currency."Amount Rounding Precision") *
                    "Line Discount %" / 100, Currency."Amount Rounding Precision");
                "Inv. Discount Amount" := 0;
                "Inv. Disc. Amount to Invoice" := 0;
            end;
            OnAfterFindServLineDisc(ServLine, ServHeader, TempSalesLineDisc);
        end;
    end;

    procedure FindStdItemJnlLinePrice(var StdItemJnlLine: Record "Standard Item Journal Line"; CalledByFieldNo: Integer)
    var
        IsHandled: Boolean;
    begin
        IsHandled := true;
        OnBeforeFindStdItemJnlLinePrice(StdItemJnlLine, CalledByFieldNo, IsHandled);
        if IsHandled then
            exit;

        with StdItemJnlLine do begin
            SetCurrency('', 0, 0D);
            SetVAT(false, 0, 0, '');
            SetUoM(Abs(Quantity), "Qty. per Unit of Measure");
            TestField("Qty. per Unit of Measure");
            Item.Get("Item No.");

            FindSalesPrice(
              TempSalesPrice, '', '', '', '', "Item No.", "Variant Code",
              "Unit of Measure Code", '', WorkDate, false);
            CalcBestUnitPrice(TempSalesPrice);
            if FoundSalesPrice or
               not ((CalledByFieldNo = FieldNo(Quantity)) or
                    (CalledByFieldNo = FieldNo("Variant Code")))
            then
                Validate("Unit Amount", TempSalesPrice."Unit Price");
            OnAfterFindStdItemJnlLinePrice(StdItemJnlLine, TempSalesPrice, CalledByFieldNo);
        end;
    end;

    procedure FindAnalysisReportPrice(ItemNo: Code[20]; Date: Date): Decimal
    var
        UnitPrice: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeFindAnalysisReportPrice(ItemNo, Date, UnitPrice, IsHandled);
        if IsHandled then
            exit(UnitPrice);

        SetCurrency('', 0, 0D);
        SetVAT(false, 0, 0, '');
        SetUoM(0, 1);
        Item.Get(ItemNo);

        FindSalesPrice(TempSalesPrice, '', '', '', '', ItemNo, '', '', '', Date, false);
        CalcBestUnitPrice(TempSalesPrice);
        if FoundSalesPrice then
            exit(TempSalesPrice."Unit Price");
        exit(Item."Unit Price");
    end;

    procedure CalcBestUnitPrice(var SalesPrice: Record "Sales Price")
    var
        BestSalesPrice: Record "Sales Price";
        BestSalesPriceFound: Boolean;
        IsHandled: Boolean;
    begin
        OnBeforeCalcBestUnitPrice(SalesPrice, IsHandled);
        if IsHandled then
            exit;

        
        // PR3.60
        ItemSalesPriceMgmt.SetBestPriceFilters(SalesPrice);
        repeat
            // PR3.60

            with SalesPrice do begin
            FoundSalesPrice := FindSet();
                if FoundSalesPrice then
                    repeat
                        IsHandled := false;
                        OnCalcBestUnitPriceOnBeforeCalcBestUnitPriceConvertPrice(SalesPrice, Qty, IsHandled);
                        if not IsHandled then
                            if ItemSalesPriceMgmt.IsInMaxQty(SalesPrice, QtyPerUOM, Qty) then // PR3.60

                                if IsInMinQty("Unit of Measure Code", "Minimum Quantity") then begin
                                    // PR3.60
                                    /*
                                    CalcBestUnitPriceConvertPrice(SalesPrice);
                                    */
                                    // PR3.60

                                    case true of
                                        ((BestSalesPrice."Currency Code" = '') and ("Currency Code" <> '')) or
                                        ((BestSalesPrice."Variant Code" = '') and ("Variant Code" <> '')):
                                            begin
                                                "Unit Price" := "Sales Unit Price"; // PR3.60
                                                BestSalesPrice := SalesPrice;
                                                BestSalesPriceFound := true;
                                            end;
                                        ((BestSalesPrice."Currency Code" = '') or ("Currency Code" <> '')) and
                                        ((BestSalesPrice."Variant Code" = '') or ("Variant Code" <> '')):
                                            begin
                                                "Unit Price" := "Sales Unit Price"; // PR3.60
                                                if (BestSalesPrice."Unit Price" = 0) or
                                                   (CalcLineAmount(BestSalesPrice) > CalcLineAmount(SalesPrice))
                                                then // PR3.60
                                                    BestSalesPrice := SalesPrice;
                                                BestSalesPriceFound := true;
                                            end;
                                    end;
                                end;
                    until Next() = 0;
            end;

        until BestSalesPriceFound or (not ItemSalesPriceMgmt.RemoveBestPriceFilter(SalesPrice)); // PR3.60, P80066030

        OnAfterCalcBestUnitPrice(SalesPrice, BestSalesPrice);

        // No price found in agreement
        if not BestSalesPriceFound then begin
            // PR3.60
            /*
            ConvertPriceToVAT(
              Item."Price Includes VAT",Item."VAT Prod. Posting Group",
              Item."VAT Bus. Posting Gr. (Price)",Item."Unit Price");
            ConvertPriceToUoM('',Item."Unit Price");
            ConvertPriceLCYToFCY('',Item."Unit Price");
            */
            // PR3.60

            Clear(BestSalesPrice);
            BestSalesPrice."Unit Price" := Item."Unit Price";
            BestSalesPrice."Allow Line Disc." := AllowLineDisc;
            BestSalesPrice."Allow Invoice Disc." := AllowInvDisc;

            // PR3.60
            BestSalesPrice."Price Includes VAT" := Item."Price Includes VAT";
            BestSalesPrice."VAT Bus. Posting Gr. (Price)" := Item."VAT Bus. Posting Gr. (Price)";

            BestSalesPrice."Sales Unit Price" :=
              ItemSalesPriceMgmt.ConvertSalesUnitPrice(BestSalesPrice, Item."Unit Price");
            PrepareSalesPrices(BestSalesPrice);

            BestSalesPrice."Unit Price" := BestSalesPrice."Sales Unit Price";
            // PR3.60

            OnAfterCalcBestUnitPriceAsItemUnitPrice(BestSalesPrice, Item);
        end;

        SalesPrice := BestSalesPrice;
    end;

    local procedure CalcBestUnitPriceConvertPrice(var SalesPrice: Record "Sales Price")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcBestUnitPriceConvertPrice(SalesPrice, IsHandled, Item);
        if IsHandled then
            exit;

        with SalesPrice do begin
            ConvertPriceToVAT(
                "Price Includes VAT", Item."VAT Prod. Posting Group",
                "VAT Bus. Posting Gr. (Price)", "Unit Price");
            ConvertPriceToUoM("Unit of Measure Code", "Unit Price");
            ConvertPriceLCYToFCY("Currency Code", "Unit Price");
        end;
    end;

    procedure CalcBestLineDisc(var SalesLineDisc: Record "Sales Line Discount")
    var
        BestSalesLineDisc: Record "Sales Line Discount";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcBestLineDisc(SalesLineDisc, Item, IsHandled, QtyPerUOM, Qty);
        if IsHandled then
            exit;

        // PR3.60
        ItemSalesPriceMgmt.SetBestLineDiscFilters(SalesLineDisc);
        repeat
            // PR3.60

            with SalesLineDisc do begin
                if FindSet then
                    repeat
                        if IsInMinQty("Unit of Measure Code", "Minimum Quantity") then
                            case true of
                                // ((BestSalesLineDisc."Currency Code" = '') AND ("Currency Code" <> '')) OR // PR3.70
                                // ((BestSalesLineDisc."Variant Code" = '') AND ("Variant Code" <> '')):     // PR3.70
                                //   BestSalesLineDisc := SalesLineDisc;                                     // PR3.70
                                ((BestSalesLineDisc."Currency Code" = '') or ("Currency Code" <> '')) and
                                ((BestSalesLineDisc."Variant Code" = '') or ("Variant Code" <> '')):
                                    begin // PR3.70
                                        "Line Discount %" := "Sales Line Discount %"; // PR3.60
                                        if BestSalesLineDisc."Line Discount %" < "Line Discount %" then
                                            BestSalesLineDisc := SalesLineDisc;
                                    end; // PR3.70
                            end;
                until Next() = 0;
            end;

            // PR3.60
        until (BestSalesLineDisc."Line Discount %" <> 0) or
              (not ItemSalesPriceMgmt.RemoveBestLineDiscFilter(SalesLineDisc));
        // PR3.60

        SalesLineDisc := BestSalesLineDisc;
    end;

    procedure FindSalesPrice(var ToSalesPrice: Record "Sales Price"; CustNo: Code[20]; ContNo: Code[20]; CustPriceGrCode: Code[10]; CampaignNo: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UOM: Code[10]; CurrencyCode: Code[10]; StartingDate: Date; ShowAll: Boolean)
    var
        FromSalesPrice: Record "Sales Price";
        TempTargetCampaignGr: Record "Campaign Target Group" temporary;
    begin
        if not ToSalesPrice.IsTemporary then
            Error(TempTableErr);

        ToSalesPrice.Reset();
        ToSalesPrice.DeleteAll();

        OnBeforeFindSalesPrice(
          ToSalesPrice, FromSalesPrice, QtyPerUOM, Qty, CustNo, ContNo, CustPriceGrCode, CampaignNo,
          ItemNo, VariantCode, UOM, CurrencyCode, StartingDate, ShowAll);

        with FromSalesPrice do begin
            SetRange("Item No.", ItemNo);
            SetFilter("Variant Code", '%1|%2', VariantCode, '');
            SetFilter("Ending Date", '%1|>=%2', 0D, StartingDate);
            if not ShowAll then begin
                SetFilter("Currency Code", '%1|%2', CurrencyCode, '');
                if UOM <> '' then
                    SetFilter("Unit of Measure Code", '%1|%2', UOM, '');
                SetRange("Starting Date", 0D, StartingDate);
            end;

            // PR3.60
            SetRange("Item No.");
            SourceSalesPrice.Init;                            // PR3.70
            SourceSalesPrice."Currency Code" := CurrencyCode; // PR3.70
            SourceSalesPrice."Item No." := ItemNo;            // PR3.70
            SourceSalesPrice."Variant Code" := VariantCode;   // PR3.70
            SourceSalesPrice."Unit of Measure Code" := UOM;   // PR3.70
            SourceSalesPrice."Starting Date" := StartingDate; // PR3.70
            ItemSalesPriceMgmt.SetPriceSource(SourceSalesPrice, CustNo, CurrencyFactor, ExchRateDate);
            // PR3.60

            SetRange("Sales Type", "Sales Type"::"All Customers");
            SetRange("Sales Code");
            // CopySalesPriceToSalesPrice(FromSalesPrice,ToSalesPrice);   // PR3.60
            CopyItemSalesPriceToSalesPrice(FromSalesPrice, ToSalesPrice); // PR3.60

            if CustNo <> '' then begin
                SetRange("Sales Type", "Sales Type"::Customer);
                SetRange("Sales Code", CustNo);
                // CopySalesPriceToSalesPrice(FromSalesPrice,ToSalesPrice);   // PR3.60
                CopyItemSalesPriceToSalesPrice(FromSalesPrice, ToSalesPrice); // PR3.60
            end;

            if CustPriceGrCode <> '' then begin
                SetRange("Sales Type", "Sales Type"::"Customer Price Group");
                SetRange("Sales Code", CustPriceGrCode);
                // CopySalesPriceToSalesPrice(FromSalesPrice,ToSalesPrice);   // PR3.60
                CopyItemSalesPriceToSalesPrice(FromSalesPrice, ToSalesPrice); // PR3.60
            end;

            if not ((CustNo = '') and (ContNo = '') and (CampaignNo = '')) then begin
                SetRange("Sales Type", "Sales Type"::Campaign);
                if ActivatedCampaignExists(TempTargetCampaignGr, CustNo, ContNo, CampaignNo) then
                    repeat
                        SetRange("Sales Code", TempTargetCampaignGr."Campaign No.");
                        // CopySalesPriceToSalesPrice(FromSalesPrice,ToSalesPrice);   // PR3.70
                        CopyItemSalesPriceToSalesPrice(FromSalesPrice, ToSalesPrice); // PR3.70
                    until TempTargetCampaignGr.Next() = 0;
            end;
        end;

        OnAfterFindSalesPrice(
          ToSalesPrice, FromSalesPrice, QtyPerUOM, Qty, CustNo, ContNo, CustPriceGrCode, CampaignNo,
          ItemNo, VariantCode, UOM, CurrencyCode, StartingDate, ShowAll);
    end;

    procedure FindSalesLineDisc(var ToSalesLineDisc: Record "Sales Line Discount"; CustNo: Code[20]; ContNo: Code[20]; CustDiscGrCode: Code[20]; CampaignNo: Code[20]; ItemNo: Code[20]; ItemDiscGrCode: Code[20]; VariantCode: Code[10]; UOM: Code[10]; CurrencyCode: Code[10]; StartingDate: Date; ShowAll: Boolean)
    var
        FromSalesLineDisc: Record "Sales Line Discount";
        TempCampaignTargetGr: Record "Campaign Target Group" temporary;
        InclCampaigns: Boolean;
    begin
        OnBeforeFindSalesLineDisc(
          ToSalesLineDisc, CustNo, ContNo, CustDiscGrCode, CampaignNo, ItemNo, ItemDiscGrCode, VariantCode, UOM,
          CurrencyCode, StartingDate, ShowAll);

        with FromSalesLineDisc do begin
            SetFilter("Ending Date", '%1|>=%2', 0D, StartingDate);
            SetFilter("Variant Code", '%1|%2', VariantCode, '');
            OnFindSalesLineDiscOnAfterSetFilters(FromSalesLineDisc);
            if not ShowAll then begin
                SetRange("Starting Date", 0D, StartingDate);
                SetFilter("Currency Code", '%1|%2', CurrencyCode, '');
                if UOM <> '' then
                    SetFilter("Unit of Measure Code", '%1|%2', UOM, '');
            end;

            // PR3.60
            SourceSalesLineDisc := ToSalesLineDisc;

            SourceSalesLineDisc.Init;
            SourceSalesLineDisc."Currency Code" := CurrencyCode;
            SourceSalesLineDisc."Variant Code" := VariantCode;
            SourceSalesLineDisc."Unit of Measure Code" := UOM;
            SourceSalesLineDisc."Starting Date" := StartingDate;
            ItemSalesPriceMgmt.SetLineDiscSource(SourceSalesLineDisc, ItemNo, CustNo, CurrencyFactor, ExchRateDate);
            // PR3.60

            ToSalesLineDisc.Reset();
            ToSalesLineDisc.DeleteAll();
            for "Sales Type" := "Sales Type"::Customer to "Sales Type"::Campaign do
                if ("Sales Type" = "Sales Type"::"All Customers") or
                   (("Sales Type" = "Sales Type"::Customer) and (CustNo <> '')) or
                   (("Sales Type" = "Sales Type"::"Customer Disc. Group") and (CustDiscGrCode <> '')) or
                   (("Sales Type" = "Sales Type"::Campaign) and
                    not ((CustNo = '') and (ContNo = '') and (CampaignNo = '')))
                then begin
                    InclCampaigns := false;

                    SetRange("Sales Type", "Sales Type");
                    case "Sales Type" of
                        "Sales Type"::"All Customers":
                            SetRange("Sales Code");
                        "Sales Type"::Customer:
                            SetRange("Sales Code", CustNo);
                        "Sales Type"::"Customer Disc. Group":
                            SetRange("Sales Code", CustDiscGrCode);
                        "Sales Type"::Campaign:
                            begin
                                InclCampaigns := ActivatedCampaignExists(TempCampaignTargetGr, CustNo, ContNo, CampaignNo);
                                SetRange("Sales Code", TempCampaignTargetGr."Campaign No.");
                            end;
                    end;

                    repeat
                        // PR3.60
                        /*
                        SETRANGE(Type,Type::Item);
                        SETRANGE(Code,ItemNo);
                        CopySalesDiscToSalesDisc(FromSalesLineDisc,ToSalesLineDisc);

                        IF ItemDiscGrCode <> '' THEN BEGIN
                          SETRANGE(Type,Type::"Item Disc. Group");
                          SETRANGE(Code,ItemDiscGrCode);
                          CopySalesDiscToSalesDisc(FromSalesLineDisc,ToSalesLineDisc);
                        END;
                        */
                        // PR3.60

                        CopyItemSalesDiscToSalesDisc(FromSalesLineDisc, ToSalesLineDisc, ItemDiscGrCode); // PR3.60

                        if InclCampaigns then begin
                            InclCampaigns := TempCampaignTargetGr.Next <> 0;
                            SetRange("Sales Code", TempCampaignTargetGr."Campaign No.");
                        end;
                    until not InclCampaigns;
                end;
        end;

        OnAfterFindSalesLineDisc(
          ToSalesLineDisc, CustNo, ContNo, CustDiscGrCode, CampaignNo, ItemNo, ItemDiscGrCode, VariantCode, UOM,
          CurrencyCode, StartingDate, ShowAll);

    end;

    procedure CopySalesPrice(var SalesPrice: Record "Sales Price")
    begin
        SalesPrice.DeleteAll();
        CopySalesPriceToSalesPrice(TempSalesPrice, SalesPrice);
    end;

    local procedure CopySalesPriceToSalesPrice(var FromSalesPrice: Record "Sales Price"; var ToSalesPrice: Record "Sales Price")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopySalesPriceToSalesPrice(FromSalesPrice, ToSalesPrice, IsHandled);
        if IsHandled then
            exit;

        with ToSalesPrice do
            if FromSalesPrice.FindSet then
                repeat
                    // PR3.60
                    ItemSalesPriceMgmt.CalculateSalesPrices(FromSalesPrice);
                    PrepareSalesPrices(FromSalesPrice);
                    // PR3.60

                    ToSalesPrice := FromSalesPrice;
                    Insert;
                    ContractItem := ContractItem or                                                // PR3.70
                      (("Item Type" = "Item Type"::Item) and                                       // PR3.70
                        ("Price Type" in ["Price Type"::Contract, "Price Type"::"Soft Contract"])); // PR3.70
                until FromSalesPrice.Next() = 0;
    end;

    local procedure CopySalesDiscToSalesDisc(var FromSalesLineDisc: Record "Sales Line Discount"; var ToSalesLineDisc: Record "Sales Line Discount")
    begin
        with ToSalesLineDisc do
            if FromSalesLineDisc.FindSet then
                repeat
                    ItemSalesPriceMgmt.CalculateSalesLineDiscs(FromSalesLineDisc); // PR3.60

                    ToSalesLineDisc := FromSalesLineDisc;
                    Insert;
                until FromSalesLineDisc.Next() = 0;
    end;

    procedure SetItem(ItemNo: Code[20])
    begin
        Item.Get(ItemNo);
    end;

    procedure SetResPrice(Code2: Code[20]; WorkTypeCode: Code[10]; CurrencyCode: Code[10])
    begin
        with ResPrice do begin
            Init;
            Code := Code2;
            "Work Type Code" := WorkTypeCode;
            "Currency Code" := CurrencyCode;
        end;
    end;

    procedure SetCurrency(CurrencyCode2: Code[10]; CurrencyFactor2: Decimal; ExchRateDate2: Date)
    begin
        PricesInCurrency := CurrencyCode2 <> '';
        if PricesInCurrency then begin
            Currency.Get(CurrencyCode2);
            Currency.TestField("Unit-Amount Rounding Precision");
            CurrencyFactor := CurrencyFactor2;
            ExchRateDate := ExchRateDate2;
        end else
            GLSetup.Get();
    end;

    procedure SetVAT(PriceInclVAT2: Boolean; VATPerCent2: Decimal; VATCalcType2: Option; VATBusPostingGr2: Code[20])
    begin
        PricesInclVAT := PriceInclVAT2;
        VATPerCent := VATPerCent2;
        VATCalcType := VATCalcType2;
        VATBusPostingGr := VATBusPostingGr2;
    end;

    procedure SetUoM(Qty2: Decimal; QtyPerUoM2: Decimal)
    begin
        Qty := Qty2;
        QtyPerUOM := QtyPerUoM2;
    end;

    procedure SetLineDisc(LineDiscPerCent2: Decimal; AllowLineDisc2: Boolean; AllowInvDisc2: Boolean)
    begin
        LineDiscPerCent := LineDiscPerCent2;
        AllowLineDisc := AllowLineDisc2;
        AllowInvDisc := AllowInvDisc2;
    end;

    local procedure IsInMinQty(UnitofMeasureCode: Code[10]; MinQty: Decimal): Boolean
    begin
        // PR3.60
        if (UnitofMeasureCode = '') then
            //MinQty := MinQty / Item.CostingQtyPerBase(); // P8000981
            MinQty := MinQty / Item.PricingQtyPerBase();   // P8000981
        // PR3.60

        if UnitofMeasureCode = '' then
            exit(MinQty <= QtyPerUOM * Qty);
        exit(MinQty <= Qty);
    end;

    procedure ConvertPriceToVAT(FromPricesInclVAT: Boolean; FromVATProdPostingGr: Code[20]; FromVATBusPostingGr: Code[20]; var UnitPrice: Decimal)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        IsHandled: Boolean;
    begin
        if FromPricesInclVAT then begin
            VATPostingSetup.Get(FromVATBusPostingGr, FromVATProdPostingGr);
            IsHandled := false;
            OnBeforeConvertPriceToVAT(VATPostingSetup, UnitPrice, IsHandled);
            if IsHandled then
                exit;

            case VATPostingSetup."VAT Calculation Type" of
                VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT":
                    VATPostingSetup."VAT %" := 0;
                VATPostingSetup."VAT Calculation Type"::"Sales Tax":
                    Error(
                      Text010,
                      VATPostingSetup.FieldCaption("VAT Calculation Type"),
                      VATPostingSetup."VAT Calculation Type");
            end;

            case VATCalcType of
                VATCalcType::"Normal VAT",
                VATCalcType::"Full VAT",
                VATCalcType::"Sales Tax":
                    begin
                        if PricesInclVAT then begin
                            if VATBusPostingGr <> FromVATBusPostingGr then
                                UnitPrice := UnitPrice * (100 + VATPerCent) / (100 + VATPostingSetup."VAT %");
                        end else
                            UnitPrice := UnitPrice / (1 + VATPostingSetup."VAT %" / 100);
                    end;
                VATCalcType::"Reverse Charge VAT":
                    UnitPrice := UnitPrice / (1 + VATPostingSetup."VAT %" / 100);
            end;
        end else
            if PricesInclVAT then
                UnitPrice := UnitPrice * (1 + VATPerCent / 100);
    end;

    local procedure ConvertPriceToUoM(UnitOfMeasureCode: Code[10]; var UnitPrice: Decimal)
    begin
        if UnitOfMeasureCode = '' then
            UnitPrice := UnitPrice * QtyPerUOM;
    end;

    procedure ConvertPriceLCYToFCY(CurrencyCode: Code[10]; var UnitPrice: Decimal)
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if PricesInCurrency then begin
            if CurrencyCode = '' then
                UnitPrice :=
                  CurrExchRate.ExchangeAmtLCYToFCY(ExchRateDate, Currency.Code, UnitPrice, CurrencyFactor);
            UnitPrice := Round(UnitPrice, Currency."Unit-Amount Rounding Precision");
        end else
            UnitPrice := Round(UnitPrice, GLSetup."Unit-Amount Rounding Precision");
    end;

    local procedure CalcLineAmount(SalesPrice: Record "Sales Price") LineAmount: Decimal
    begin
        with SalesPrice do
            if "Allow Line Disc." then
                LineAmount := "Unit Price" * (1 - LineDiscPerCent / 100)
            else
                LineAmount := "Unit Price";
        OnAfterCalcLineAmount(SalesPrice, LineAmount, LineDiscPerCent);
    end;

    procedure GetSalesLinePrice(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetSalesLinePrice(SalesHeader, SalesLine, IsHandled);
        if IsHandled then
            exit;
            
        InitCurrencyAndTaxVars(SalesHeader, SalesLine); // PR3.60

        SalesLinePriceExists(SalesHeader, SalesLine, true);

        SalesLinePriceExists(SalesHeader, SalesLine, true);


        with SalesLine do begin // P8000885 - Added BEGIN and END to DO
                                // P8000885
            if ProcessFns.PricingInstalled then
                SalesContMgmt.SetContractFilters(SalesLine, TempSalesPrice);
            //  IF TempSalesPrice.GETFILTER("Contract No.") = '' THEN                             // P8000982
            if (PAGE.RunModal(PAGE::"Get Sales Price", TempSalesPrice) <> ACTION::LookupOK) or // P8000982
               (TempSalesPrice.GetFilter("Contract No.") <> '')                               // P8000982
            then                                                                              // P8000982
                exit;
            // P8000885
            // IF PAGE.RUNMODAL(FORM::"Get Sales Price",TempSalesPrice) = ACTION::LookupOK THEN BEGIN // P8000885 - Removed
            // PR3.60
            if not (TempSalesPrice."Currency Code" in ["Currency Code", '']) then
                Error(Text001, FieldCaption("Currency Code"), TableCaption, TempSalesPrice.TableCaption);

            if not (TempSalesPrice."Unit of Measure Code" in ["Unit of Measure Code", '']) then
                Error(Text001, FieldCaption("Unit of Measure Code"), TableCaption, TempSalesPrice.TableCaption);
            // PR3.60

            SetVAT(
              SalesHeader."Prices Including VAT", "VAT %", "VAT Calculation Type".AsInteger(), "VAT Bus. Posting Group");
            SetUoM(Abs(Quantity), "Qty. per Unit of Measure");
            SetCurrency(
              SalesHeader."Currency Code", SalesHeader."Currency Factor", SalesHeaderExchDate(SalesHeader));

            if not IsInMinQty(TempSalesPrice."Unit of Measure Code", TempSalesPrice."Minimum Quantity") then
                Error(
                  Text000,
                  FieldCaption(Quantity),
                  TempSalesPrice.FieldCaption("Minimum Quantity"),
                  TempSalesPrice.TableCaption);

            // PR3.60
            /*
            IF NOT (TempSalesPrice."Currency Code" IN ["Currency Code",'']) THEN
              ERROR(
                Text001,
                FIELDCAPTION("Currency Code"),
                TABLECAPTION,
                TempSalesPrice.TABLECAPTION);
            IF NOT (TempSalesPrice."Unit of Measure Code" IN ["Unit of Measure Code",'']) THEN
              ERROR(
                Text001,
                FIELDCAPTION("Unit of Measure Code"),
                TABLECAPTION,
                TempSalesPrice.TABLECAPTION);
            */
            // PR3.60

            // PR3.60
            if not ItemSalesPriceMgmt.IsInMaxQty(TempSalesPrice, QtyPerUOM, Qty) then
                Error(Text37002000, TempSalesPrice.FieldCaption("Maximum Quantity"), TempSalesPrice.TableCaption);
            // PR3.60

            if TempSalesPrice."Starting Date" > SalesHeaderStartDate(SalesHeader, DateCaption) then
                Error(
                  Text000,
                  DateCaption,
                  TempSalesPrice.FieldCaption("Starting Date"),
                  TempSalesPrice.TableCaption);

            // PR3.60
            /*
            ConvertPriceToVAT(
              TempSalesPrice."Price Includes VAT",Item."VAT Prod. Posting Group",
              TempSalesPrice."VAT Bus. Posting Gr. (Price)",TempSalesPrice."Unit Price");
            ConvertPriceToUoM(TempSalesPrice."Unit of Measure Code",TempSalesPrice."Unit Price");
            ConvertPriceLCYToFCY(TempSalesPrice."Currency Code",TempSalesPrice."Unit Price");
            */
            // PR3.60

            // PR3.60
            TempSalesPrice."Unit Price" := TempSalesPrice."Sales Unit Price";
            "Price ID" := TempSalesPrice."Price ID";
            "Contract No." := TempSalesPrice."Contract No."; // P8000885
            InitOutstandingQtyCont; // P8000885
                                    // PR3.60

            "Allow Invoice Disc." := TempSalesPrice."Allow Invoice Disc.";
            "Allow Line Disc." := TempSalesPrice."Allow Line Disc.";
            if not "Allow Line Disc." then
                "Line Discount %" := 0;

            // VALIDATE("Unit Price",TempSalesPrice."Unit Price");    // P8000921
            Validate("Unit Price (FOB)", TempSalesPrice."Unit Price"); // P8000921
        end;

        OnAfterGetSalesLinePrice(SalesHeader, SalesLine, TempSalesPrice);

    end;

    procedure GetSalesLineLineDisc(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetSalesLineLineDisc(SalesHeader, SalesLine, IsHandled);
        if IsHandled then
            exit;

        SalesLineLineDiscExists(SalesHeader, SalesLine, true);

        with SalesLine do
            if PAGE.RunModal(PAGE::"Get Sales Line Disc.", TempSalesLineDisc) = ACTION::LookupOK then begin
                // PR3.60
                if not (TempSalesLineDisc."Currency Code" in ["Currency Code", '']) then
                    Error(Text001, FieldCaption("Currency Code"), TableCaption, TempSalesLineDisc.TableCaption);

                if not (TempSalesLineDisc."Unit of Measure Code" in ["Unit of Measure Code", '']) then
                    Error(Text001, FieldCaption("Unit of Measure Code"), TableCaption, TempSalesLineDisc.TableCaption);
                // PR3.60

                SetCurrency(SalesHeader."Currency Code", 0, 0D);
                SetUoM(Abs(Quantity), "Qty. per Unit of Measure");

                if not IsInMinQty(TempSalesLineDisc."Unit of Measure Code", TempSalesLineDisc."Minimum Quantity")
                then
                    Error(
                      Text000, FieldCaption(Quantity),
                      TempSalesLineDisc.FieldCaption("Minimum Quantity"),
                      TempSalesLineDisc.TableCaption);

                // PR3.60
                /*
                IF NOT (TempSalesLineDisc."Currency Code" IN ["Currency Code",'']) THEN
                  ERROR(
                    Text001,
                    FIELDCAPTION("Currency Code"),
                    TABLECAPTION,
                    TempSalesLineDisc.TABLECAPTION);
                IF NOT (TempSalesLineDisc."Unit of Measure Code" IN ["Unit of Measure Code",'']) THEN
                  ERROR(
                    Text001,
                    FIELDCAPTION("Unit of Measure Code"),
                    TABLECAPTION,
                    TempSalesLineDisc.TABLECAPTION);
                */
                // PR3.60

                if TempSalesLineDisc."Starting Date" > SalesHeaderStartDate(SalesHeader, DateCaption) then
                    Error(
                      Text000,
                      DateCaption,
                      TempSalesLineDisc.FieldCaption("Starting Date"),
                      TempSalesLineDisc.TableCaption);

                TestField("Allow Line Disc.");
                //VALIDATE("Line Discount %",TempSalesLineDisc."Line Discount %"); // P8000440A
                // P8000440A
                "Line Discount Type" := TempSalesLineDisc."Line Discount Type";
                case "Line Discount Type" of
                    "Line Discount Type"::Percent:
                        "Line Discount %" := TempSalesLineDisc."Line Discount %";
                    "Line Discount Type"::Amount:
                        "Line Discount Amount" := TempSalesLineDisc."Line Discount Amount";
                    "Line Discount Type"::"Unit Amount":
                        "Line Discount Unit Amount" := TempSalesLineDisc."Line Discount Amount";
                end;
                Validate("Line Discount %");
                // P8000440A
            end;

        OnAfterGetSalesLineLineDisc(SalesLine, TempSalesLineDisc);

    end;

    procedure SalesLinePriceExists(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ShowAll: Boolean) Result: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSalesLinePriceExistsProcedure(SalesHeader, SalesLine, ShowAll, TempSalesPrice, Result, IsHandled);
        if IsHandled then
            exit(Result);

        with SalesLine do
            if (Type = Type::Item) and Item.Get("No.") then begin
                IsHandled := false;
                OnBeforeSalesLinePriceExists(
                  SalesLine, SalesHeader, TempSalesPrice, Currency, CurrencyFactor,
                  SalesHeaderStartDate(SalesHeader, DateCaption), Qty, QtyPerUOM, ShowAll, IsHandled);
                if not IsHandled then begin
                    ItemSalesPriceMgmt.SetSalesLine(SalesLine); // PR3.60
                    FindSalesPrice(
                      TempSalesPrice, GetCustNoForSalesHeader(SalesHeader), SalesHeader."Bill-to Contact No.",
                      SalesLine."Customer Price Group", '', "No.", "Variant Code", "Unit of Measure Code",
                      SalesHeader."Currency Code", SalesHeaderStartDate(SalesHeader, DateCaption), ShowAll);

                    // PR3.60
                    FindSellToSalesPrice(
                      TempSalesPrice, "Sell-to Customer No.", "Bill-to Customer No.",
                      "Variant Code", "Unit of Measure Code", SalesHeader."Currency Code", // PR3.70
                      SalesHeaderStartDate(SalesHeader, DateCaption), ShowAll);            // PR3.70
                                                                                           // PR3.60

                    OnAfterSalesLinePriceExists(SalesLine, SalesHeader, TempSalesPrice, ShowAll);
                end;
                exit(TempSalesPrice.FindFirst);
            end;
        exit(false);
    end;

    procedure SalesLineLineDiscExists(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ShowAll: Boolean): Boolean
    var
        IsHandled: Boolean;
    begin
        with SalesLine do
            if (Type = Type::Item) and Item.Get("No.") then begin
                IsHandled := false;
                OnBeforeSalesLineLineDiscExists(
                  SalesLine, SalesHeader, TempSalesLineDisc, SalesHeaderStartDate(SalesHeader, DateCaption),
                  Qty, QtyPerUOM, ShowAll, IsHandled);
                if not IsHandled then begin
                    // PR3.60
                    InitCurrencyAndTaxVars(SalesHeader, SalesLine);
                    ItemSalesPriceMgmt.SetSalesLine(SalesLine);
                    // PR3.60
                    FindSalesLineDisc(
                      TempSalesLineDisc, GetCustNoForSalesHeader(SalesHeader), SalesHeader."Bill-to Contact No.",
                      "Customer Disc. Group", '', "No.", Item."Item Disc. Group", "Variant Code", "Unit of Measure Code",
                      SalesHeader."Currency Code", SalesHeaderStartDate(SalesHeader, DateCaption), ShowAll);

                    // PR3.60
                    FindSellToSalesLineDisc(
                      TempSalesLineDisc, "No.", Item."Item Disc. Group",
                      "Sell-to Customer No.", "Bill-to Customer No.",
                      "Variant Code", "Unit of Measure Code", SalesHeader."Currency Code", // PR3.70
                      SalesHeaderStartDate(SalesHeader, DateCaption), ShowAll);            // PR3.70
                                                                                           // PR3.60

                    OnAfterSalesLineLineDiscExists(SalesLine, SalesHeader, TempSalesLineDisc, ShowAll);
                end;
                exit(TempSalesLineDisc.FindFirst);
            end;
        exit(false);
    end;

    procedure GetServLinePrice(ServHeader: Record "Service Header"; var ServLine: Record "Service Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetServLinePrice(ServHeader, ServLine, IsHandled);
        if IsHandled then
            exit;

        ServLinePriceExists(ServHeader, ServLine, true);

        with ServLine do
            if PAGE.RunModal(PAGE::"Get Sales Price", TempSalesPrice) = ACTION::LookupOK then begin
                SetVAT(
                  ServHeader."Prices Including VAT", "VAT %", "VAT Calculation Type".AsInteger(), "VAT Bus. Posting Group");
                SetUoM(Abs(Quantity), "Qty. per Unit of Measure");
                SetCurrency(
                  ServHeader."Currency Code", ServHeader."Currency Factor", ServHeaderExchDate(ServHeader));

                if not IsInMinQty(TempSalesPrice."Unit of Measure Code", TempSalesPrice."Minimum Quantity") then
                    Error(
                      Text000,
                      FieldCaption(Quantity),
                      TempSalesPrice.FieldCaption("Minimum Quantity"),
                      TempSalesPrice.TableCaption);
                if not (TempSalesPrice."Currency Code" in ["Currency Code", '']) then
                    Error(
                      Text001,
                      FieldCaption("Currency Code"),
                      TableCaption,
                      TempSalesPrice.TableCaption);
                if not (TempSalesPrice."Unit of Measure Code" in ["Unit of Measure Code", '']) then
                    Error(
                      Text001,
                      FieldCaption("Unit of Measure Code"),
                      TableCaption,
                      TempSalesPrice.TableCaption);
                if TempSalesPrice."Starting Date" > ServHeaderStartDate(ServHeader, DateCaption) then
                    Error(
                      Text000,
                      DateCaption,
                      TempSalesPrice.FieldCaption("Starting Date"),
                      TempSalesPrice.TableCaption);

                ConvertPriceToVAT(
                  TempSalesPrice."Price Includes VAT", Item."VAT Prod. Posting Group",
                  TempSalesPrice."VAT Bus. Posting Gr. (Price)", TempSalesPrice."Unit Price");
                ConvertPriceToUoM(TempSalesPrice."Unit of Measure Code", TempSalesPrice."Unit Price");
                ConvertPriceLCYToFCY(TempSalesPrice."Currency Code", TempSalesPrice."Unit Price");

                "Allow Invoice Disc." := TempSalesPrice."Allow Invoice Disc.";
                "Allow Line Disc." := TempSalesPrice."Allow Line Disc.";
                if not "Allow Line Disc." then
                    "Line Discount %" := 0;

                Validate("Unit Price", TempSalesPrice."Unit Price");
                ConfirmAdjPriceLineChange;
            end;
    end;

    procedure GetServLineLineDisc(ServHeader: Record "Service Header"; var ServLine: Record "Service Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetServLineDisc(ServHeader, ServLine, IsHandled);
        if IsHandled then
            exit;

        ServLineLineDiscExists(ServHeader, ServLine, true);

        with ServLine do
            if PAGE.RunModal(PAGE::"Get Sales Line Disc.", TempSalesLineDisc) = ACTION::LookupOK then begin
                SetCurrency(ServHeader."Currency Code", 0, 0D);
                SetUoM(Abs(Quantity), "Qty. per Unit of Measure");

                if not IsInMinQty(TempSalesLineDisc."Unit of Measure Code", TempSalesLineDisc."Minimum Quantity")
                then
                    Error(
                      Text000, FieldCaption(Quantity),
                      TempSalesLineDisc.FieldCaption("Minimum Quantity"),
                      TempSalesLineDisc.TableCaption);
                if not (TempSalesLineDisc."Currency Code" in ["Currency Code", '']) then
                    Error(
                      Text001,
                      FieldCaption("Currency Code"),
                      TableCaption,
                      TempSalesLineDisc.TableCaption);
                if not (TempSalesLineDisc."Unit of Measure Code" in ["Unit of Measure Code", '']) then
                    Error(
                      Text001,
                      FieldCaption("Unit of Measure Code"),
                      TableCaption,
                      TempSalesLineDisc.TableCaption);
                if TempSalesLineDisc."Starting Date" > ServHeaderStartDate(ServHeader, DateCaption) then
                    Error(
                      Text000,
                      DateCaption,
                      TempSalesLineDisc.FieldCaption("Starting Date"),
                      TempSalesLineDisc.TableCaption);

                TestField("Allow Line Disc.");
                CheckLineDiscount(TempSalesLineDisc."Line Discount %");
                Validate("Line Discount %", TempSalesLineDisc."Line Discount %");
                ConfirmAdjPriceLineChange;
            end;
    end;

    local procedure GetCustNoForSalesHeader(SalesHeader: Record "Sales Header"): Code[20]
    var
        CustNo: Code[20];
    begin
        CustNo := SalesHeader."Bill-to Customer No.";
        OnGetCustNoForSalesHeader(SalesHeader, CustNo);
        exit(CustNo);
    end;

    [Scope('OnPrem')]
    procedure ServLinePriceExists(ServHeader: Record "Service Header"; var ServLine: Record "Service Line"; ShowAll: Boolean): Boolean
    var
        IsHandled: Boolean;
    begin
        with ServLine do
            if (Type = Type::Item) and Item.Get("No.") then begin
                IsHandled := false;
                OnBeforeServLinePriceExists(ServLine, ServHeader, TempSalesPrice, ShowAll, IsHandled);
                if not IsHandled then
                    FindSalesPrice(
                      TempSalesPrice, "Bill-to Customer No.", ServHeader."Bill-to Contact No.",
                      "Customer Price Group", '', "No.", "Variant Code", "Unit of Measure Code",
                      ServHeader."Currency Code", ServHeaderStartDate(ServHeader, DateCaption), ShowAll);
                OnAfterServLinePriceExists(ServLine);
                exit(TempSalesPrice.Find('-'));
            end;
        exit(false);
    end;

    [Scope('OnPrem')]
    procedure ServLineLineDiscExists(ServHeader: Record "Service Header"; var ServLine: Record "Service Line"; ShowAll: Boolean): Boolean
    var
        IsHandled: Boolean;
    begin
        with ServLine do
            if (Type = Type::Item) and Item.Get("No.") then begin
                IsHandled := false;
                OnBeforeServLineLineDiscExists(ServLine, ServHeader, TempSalesLineDisc, ShowAll, IsHandled);
                if not IsHandled then
                    FindSalesLineDisc(
                      TempSalesLineDisc, "Bill-to Customer No.", ServHeader."Bill-to Contact No.",
                      "Customer Disc. Group", '', "No.", Item."Item Disc. Group", "Variant Code", "Unit of Measure Code",
                      ServHeader."Currency Code", ServHeaderStartDate(ServHeader, DateCaption), ShowAll);
                OnAfterServLineLineDiscExists(ServLine);
                exit(TempSalesLineDisc.Find('-'));
            end;
        exit(false);
    end;

    procedure ActivatedCampaignExists(var ToCampaignTargetGr: Record "Campaign Target Group"; CustNo: Code[20]; ContNo: Code[20]; CampaignNo: Code[20]): Boolean
    var
        FromCampaignTargetGr: Record "Campaign Target Group";
        Cont: Record Contact;
        IsHandled: Boolean;
    begin
        if not ToCampaignTargetGr.IsTemporary then
            Error(TempTableErr);

        IsHandled := false;
        OnBeforeActivatedCampaignExists(ToCampaignTargetGr, CustNo, ContNo, CampaignNo, IsHandled);
        IF IsHandled then
            exit;

        with FromCampaignTargetGr do begin
            ToCampaignTargetGr.Reset();
            ToCampaignTargetGr.DeleteAll();

            if CampaignNo <> '' then begin
                ToCampaignTargetGr."Campaign No." := CampaignNo;
                ToCampaignTargetGr.Insert();
            end else begin
                SetRange(Type, Type::Customer);
                SetRange("No.", CustNo);
                if FindSet then
                    repeat
                        ToCampaignTargetGr := FromCampaignTargetGr;
                        ToCampaignTargetGr.Insert();
                    until Next() = 0
                else
                    if Cont.Get(ContNo) then begin
                        SetRange(Type, Type::Contact);
                        SetRange("No.", Cont."Company No.");
                        if FindSet then
                            repeat
                                ToCampaignTargetGr := FromCampaignTargetGr;
                                ToCampaignTargetGr.Insert();
                            until Next() = 0;
                    end;
            end;
            exit(ToCampaignTargetGr.FindFirst);
        end;
    end;

    procedure SalesHeaderExchDate(SalesHeader: Record "Sales Header"): Date
    begin
        with SalesHeader do begin
            if "Posting Date" <> 0D then
                exit("Posting Date");
            exit(WorkDate);
        end;
    end;

    procedure SalesHeaderStartDate(var SalesHeader: Record "Sales Header"; var DateCaption: Text[30]): Date
    var
        StartDate: Date;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSalesHeaderStartDate(SalesHeader, DateCaption, StartDate, IsHandled);
        if IsHandled then
            exit(StartDate);

        with SalesHeader do
            if "Document Type" in ["Document Type"::Invoice, "Document Type"::"Credit Memo"] then begin
                DateCaption := FieldCaption("Posting Date");
                exit("Posting Date")
            end else begin
                // PR3.70 Begin
                if ("Document Type" = "Document Type"::Order) and SalesHeader."Price at Shipment" then begin
                    DateCaption := FieldCaption("Posting Date");
                    exit("Posting Date");
                end else begin
                    // PR3.70 End
                    DateCaption := FieldCaption("Order Date");
                    exit("Order Date");
                end; // PR3.70
            end;
    end;

    procedure ServHeaderExchDate(ServHeader: Record "Service Header"): Date
    begin
        with ServHeader do begin
            if ("Document Type" = "Document Type"::Quote) and
               ("Posting Date" = 0D)
            then
                exit(WorkDate);
            exit("Posting Date");
        end;
    end;

    procedure ServHeaderStartDate(ServHeader: Record "Service Header"; var DateCaption: Text[30]): Date
    begin
        with ServHeader do
            if "Document Type" in ["Document Type"::Invoice, "Document Type"::"Credit Memo"] then begin
                DateCaption := FieldCaption("Posting Date");
                exit("Posting Date")
            end else begin
                DateCaption := FieldCaption("Order Date");
                exit("Order Date");
            end;
    end;

    procedure NoOfSalesLinePrice(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ShowAll: Boolean) Result: Integer
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeNoOfSalesLinePrice(SalesHeader, SalesLine, ShowAll, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if SalesLinePriceExists(SalesHeader, SalesLine, ShowAll) then
            exit(TempSalesPrice.Count);
    end;

    procedure NoOfSalesLineLineDisc(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ShowAll: Boolean) Result: Integer
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeNoOfSalesLineLineDisc(SalesHeader, SalesLine, ShowAll, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if SalesLineLineDiscExists(SalesHeader, SalesLine, ShowAll) then
            exit(TempSalesLineDisc.Count);
    end;

    procedure NoOfServLinePrice(ServHeader: Record "Service Header"; var ServLine: Record "Service Line"; ShowAll: Boolean) Result: Integer
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeNoOfServLinePrice(ServHeader, ServLine, ShowAll, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if ServLinePriceExists(ServHeader, ServLine, ShowAll) then
            exit(TempSalesPrice.Count);
    end;

    procedure NoOfServLineLineDisc(ServHeader: Record "Service Header"; var ServLine: Record "Service Line"; ShowAll: Boolean) Result: Integer
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeNoOfServLineLineDisc(ServHeader, ServLine, ShowAll, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if ServLineLineDiscExists(ServHeader, ServLine, ShowAll) then
            exit(TempSalesLineDisc.Count);
    end;

    procedure FindJobPlanningLinePrice(var JobPlanningLine: Record "Job Planning Line"; CalledByFieldNo: Integer)
    var
        Job: Record Job;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeFindJobPlanningLinePrice(JobPlanningLine, CalledByFieldNo, IsHandled);
        if IsHandled then
            exit;

        with JobPlanningLine do begin
            SetCurrency("Currency Code", "Currency Factor", "Planning Date");
            SetVAT(false, 0, 0, '');
            SetUoM(Abs(Quantity), "Qty. per Unit of Measure");
            SetLineDisc(0, true, true);

            case Type of
                Type::Item:
                    begin
                        Job.Get("Job No.");
                        Item.Get("No.");
                        TestField("Qty. per Unit of Measure");
                        FindSalesPrice(
                          TempSalesPrice, Job."Bill-to Customer No.", Job."Bill-to Contact No.",
                          Job."Customer Price Group", '', "No.", "Variant Code", "Unit of Measure Code",
                          Job."Currency Code", "Planning Date", false);
                        CalcBestUnitPrice(TempSalesPrice);
                        if FoundSalesPrice or
                           not ((CalledByFieldNo = FieldNo(Quantity)) or
                                (CalledByFieldNo = FieldNo("Location Code")) or
                                (CalledByFieldNo = FieldNo("Variant Code")))
                        then begin
                            "Unit Price" := TempSalesPrice."Unit Price";
                            AllowLineDisc := TempSalesPrice."Allow Line Disc.";
                        end;
                    end;
                Type::Resource:
                    begin
                        Job.Get("Job No.");
                        SetResPrice("No.", "Work Type Code", "Currency Code");
                        CODEUNIT.Run(CODEUNIT::"Resource-Find Price", ResPrice);
                        OnAfterFindJobPlanningLineResPrice(JobPlanningLine, ResPrice);
                        ConvertPriceLCYToFCY(ResPrice."Currency Code", ResPrice."Unit Price");
                        "Unit Price" := ResPrice."Unit Price" * "Qty. per Unit of Measure";
                    end;
            end;
        end;
        OnFindJobPlanningLinePriceOnBeforeJobPlanningLineFindJTPrice(JobPlanningLine, ResPrice);
        JobPlanningLineFindJTPrice(JobPlanningLine);
    end;

    procedure JobPlanningLineFindJTPrice(var JobPlanningLine: Record "Job Planning Line")
    var
        JobItemPrice: Record "Job Item Price";
        JobResPrice: Record "Job Resource Price";
        JobGLAccPrice: Record "Job G/L Account Price";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeJobPlanningLineFindJTPrice(JobPlanningLine, IsHandled);
        if IsHandled then
            exit;

        with JobPlanningLine do
            case Type of
                Type::Item:
                    begin
                        JobItemPrice.SetRange("Job No.", "Job No.");
                        JobItemPrice.SetRange("Item No.", "No.");
                        JobItemPrice.SetRange("Variant Code", "Variant Code");
                        JobItemPrice.SetRange("Unit of Measure Code", "Unit of Measure Code");
                        JobItemPrice.SetRange("Currency Code", "Currency Code");
                        JobItemPrice.SetRange("Job Task No.", "Job Task No.");
                        OnJobPlanningLineFindJTPriceOnAfterSetJobItemPriceFilters(JobItemPrice, JobPlanningLine);
                        if JobItemPrice.FindFirst then
                            CopyJobItemPriceToJobPlanLine(JobPlanningLine, JobItemPrice)
                        else begin
                            JobItemPrice.SetRange("Job Task No.", ' ');
                            if JobItemPrice.FindFirst then
                                CopyJobItemPriceToJobPlanLine(JobPlanningLine, JobItemPrice);
                        end;

                        if JobItemPrice.IsEmpty or (not JobItemPrice."Apply Job Discount") then
                            FindJobPlanningLineLineDisc(JobPlanningLine);
                    end;
                Type::Resource:
                    begin
                        Res.Get("No.");
                        JobResPrice.SetRange("Job No.", "Job No.");
                        JobResPrice.SetRange("Currency Code", "Currency Code");
                        JobResPrice.SetRange("Job Task No.", "Job Task No.");
                        OnJobPlanningLineFindJTPriceOnAfterSetJobResPriceFilters(JobResPrice, JobPlanningLine);
                        case true of
                            JobPlanningLineFindJobResPrice(JobPlanningLine, JobResPrice, JobResPrice.Type::Resource):
                                CopyJobResPriceToJobPlanLine(JobPlanningLine, JobResPrice);
                            JobPlanningLineFindJobResPrice(JobPlanningLine, JobResPrice, JobResPrice.Type::"Group(Resource)"):
                                CopyJobResPriceToJobPlanLine(JobPlanningLine, JobResPrice);
                            JobPlanningLineFindJobResPrice(JobPlanningLine, JobResPrice, JobResPrice.Type::All):
                                CopyJobResPriceToJobPlanLine(JobPlanningLine, JobResPrice);
                            else begin
                                    JobResPrice.SetRange("Job Task No.", '');
                                    case true of
                                        JobPlanningLineFindJobResPrice(JobPlanningLine, JobResPrice, JobResPrice.Type::Resource):
                                            CopyJobResPriceToJobPlanLine(JobPlanningLine, JobResPrice);
                                        JobPlanningLineFindJobResPrice(JobPlanningLine, JobResPrice, JobResPrice.Type::"Group(Resource)"):
                                            CopyJobResPriceToJobPlanLine(JobPlanningLine, JobResPrice);
                                        JobPlanningLineFindJobResPrice(JobPlanningLine, JobResPrice, JobResPrice.Type::All):
                                            CopyJobResPriceToJobPlanLine(JobPlanningLine, JobResPrice);
                                    end;
                                end;
                        end;
                    end;
                Type::"G/L Account":
                    begin
                        JobGLAccPrice.SetRange("Job No.", "Job No.");
                        JobGLAccPrice.SetRange("G/L Account No.", "No.");
                        JobGLAccPrice.SetRange("Currency Code", "Currency Code");
                        JobGLAccPrice.SetRange("Job Task No.", "Job Task No.");
                        OnJobPlanningLineFindJTPriceOnAfterSetJobGLAccPriceFilters(JobGLAccPrice, JobPlanningLine);
                        if JobGLAccPrice.FindFirst then
                            CopyJobGLAccPriceToJobPlanLine(JobPlanningLine, JobGLAccPrice)
                        else begin
                            JobGLAccPrice.SetRange("Job Task No.", '');
                            if JobGLAccPrice.FindFirst then
                                CopyJobGLAccPriceToJobPlanLine(JobPlanningLine, JobGLAccPrice);
                        end;
                    end;
            end;
    end;

    local procedure CopyJobItemPriceToJobPlanLine(var JobPlanningLine: Record "Job Planning Line"; JobItemPrice: Record "Job Item Price")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyJobItemPriceToJobPlanLine(JobPlanningLine, JobItemPrice, IsHandled);
        if IsHandled then
            exit;

        with JobPlanningLine do begin
            if JobItemPrice."Apply Job Price" then begin
                "Unit Price" := JobItemPrice."Unit Price";
                "Cost Factor" := JobItemPrice."Unit Cost Factor";
            end;
            if JobItemPrice."Apply Job Discount" then
                "Line Discount %" := JobItemPrice."Line Discount %";
        end;
    end;

    local procedure CopyJobResPriceToJobPlanLine(var JobPlanningLine: Record "Job Planning Line"; JobResPrice: Record "Job Resource Price")
    begin
        with JobPlanningLine do begin
            if JobResPrice."Apply Job Price" then begin
                "Unit Price" := JobResPrice."Unit Price" * "Qty. per Unit of Measure";
                "Cost Factor" := JobResPrice."Unit Cost Factor";
            end;
            if JobResPrice."Apply Job Discount" then
                "Line Discount %" := JobResPrice."Line Discount %";
        end;
    end;

    local procedure JobPlanningLineFindJobResPrice(var JobPlanningLine: Record "Job Planning Line"; var JobResPrice: Record "Job Resource Price"; PriceType: Option Resource,"Group(Resource)",All): Boolean
    begin
        case PriceType of
            PriceType::Resource:
                begin
                    JobResPrice.SetRange(Type, JobResPrice.Type::Resource);
                    JobResPrice.SetRange("Work Type Code", JobPlanningLine."Work Type Code");
                    JobResPrice.SetRange(Code, JobPlanningLine."No.");
                    exit(JobResPrice.Find('-'));
                end;
            PriceType::"Group(Resource)":
                begin
                    JobResPrice.SetRange(Type, JobResPrice.Type::"Group(Resource)");
                    JobResPrice.SetRange(Code, Res."Resource Group No.");
                    exit(FindJobResPrice(JobResPrice, JobPlanningLine."Work Type Code"));
                end;
            PriceType::All:
                begin
                    JobResPrice.SetRange(Type, JobResPrice.Type::All);
                    JobResPrice.SetRange(Code);
                    exit(FindJobResPrice(JobResPrice, JobPlanningLine."Work Type Code"));
                end;
        end;
    end;

    local procedure CopyJobGLAccPriceToJobPlanLine(var JobPlanningLine: Record "Job Planning Line"; JobGLAccPrice: Record "Job G/L Account Price")
    begin
        with JobPlanningLine do begin
            "Unit Cost" := JobGLAccPrice."Unit Cost";
            "Unit Price" := JobGLAccPrice."Unit Price" * "Qty. per Unit of Measure";
            "Cost Factor" := JobGLAccPrice."Unit Cost Factor";
            "Line Discount %" := JobGLAccPrice."Line Discount %";
        end;
    end;

    procedure FindJobJnlLinePrice(var JobJnlLine: Record "Job Journal Line"; CalledByFieldNo: Integer)
    var
        Job: Record Job;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeFindJobJnlLinePrice(JobJnlLine, CalledByFieldNo, IsHandled);
        if IsHandled then
            exit;

        with JobJnlLine do begin
            SetCurrency("Currency Code", "Currency Factor", "Posting Date");
            SetVAT(false, 0, 0, '');
            SetUoM(Abs(Quantity), "Qty. per Unit of Measure");

            case Type of
                Type::Item:
                    begin
                        Item.Get("No.");
                        TestField("Qty. per Unit of Measure");
                        Job.Get("Job No.");

                        FindSalesPrice(
                          TempSalesPrice, Job."Bill-to Customer No.", Job."Bill-to Contact No.",
                          "Customer Price Group", '', "No.", "Variant Code", "Unit of Measure Code",
                          "Currency Code", "Posting Date", false);
                        CalcBestUnitPrice(TempSalesPrice);
                        if FoundSalesPrice or
                           not ((CalledByFieldNo = FieldNo(Quantity)) or
                                (CalledByFieldNo = FieldNo("Variant Code")))
                        then
                            "Unit Price" := TempSalesPrice."Unit Price";
                    end;
                Type::Resource:
                    begin
                        IsHandled := false;
                        OnFindJobJnlLinePriceOnBeforeResourceGetJob(JobJnlLine, IsHandled);
                        if not IsHandled then
                            Job.Get("Job No.");
                        SetResPrice("No.", "Work Type Code", "Currency Code");
                        OnBeforeFindJobJnlLineResPrice(JobJnlLine, ResPrice);
                        CODEUNIT.Run(CODEUNIT::"Resource-Find Price", ResPrice);
                        OnAfterFindJobJnlLineResPrice(JobJnlLine, ResPrice);
                        ConvertPriceLCYToFCY(ResPrice."Currency Code", ResPrice."Unit Price");
                        "Unit Price" := ResPrice."Unit Price" * "Qty. per Unit of Measure";
                    end;
            end;
        end;
        OnFindJobJnlLinePriceOnBeforeJobJnlLineFindJTPrice(JobJnlLine);
        JobJnlLineFindJTPrice(JobJnlLine);
    end;

    local procedure JobJnlLineFindJobResPrice(var JobJnlLine: Record "Job Journal Line"; var JobResPrice: Record "Job Resource Price"; PriceType: Option Resource,"Group(Resource)",All): Boolean
    begin
        case PriceType of
            PriceType::Resource:
                begin
                    JobResPrice.SetRange(Type, JobResPrice.Type::Resource);
                    JobResPrice.SetRange("Work Type Code", JobJnlLine."Work Type Code");
                    JobResPrice.SetRange(Code, JobJnlLine."No.");
                    exit(JobResPrice.Find('-'));
                end;
            PriceType::"Group(Resource)":
                begin
                    JobResPrice.SetRange(Type, JobResPrice.Type::"Group(Resource)");
                    JobResPrice.SetRange(Code, Res."Resource Group No.");
                    exit(FindJobResPrice(JobResPrice, JobJnlLine."Work Type Code"));
                end;
            PriceType::All:
                begin
                    JobResPrice.SetRange(Type, JobResPrice.Type::All);
                    JobResPrice.SetRange(Code);
                    exit(FindJobResPrice(JobResPrice, JobJnlLine."Work Type Code"));
                end;
        end;
    end;

    local procedure CopyJobResPriceToJobJnlLine(var JobJnlLine: Record "Job Journal Line"; JobResPrice: Record "Job Resource Price")
    begin
        with JobJnlLine do begin
            if JobResPrice."Apply Job Price" then begin
                "Unit Price" := JobResPrice."Unit Price" * "Qty. per Unit of Measure";
                "Cost Factor" := JobResPrice."Unit Cost Factor";
            end;
            if JobResPrice."Apply Job Discount" then
                "Line Discount %" := JobResPrice."Line Discount %";
        end;

        OnAfterCopyJobResPriceToJobJnlLine(JobJnlLine);
    end;

    local procedure CopyJobGLAccPriceToJobJnlLine(var JobJnlLine: Record "Job Journal Line"; JobGLAccPrice: Record "Job G/L Account Price")
    begin
        with JobJnlLine do begin
            "Unit Cost" := JobGLAccPrice."Unit Cost";
            "Unit Price" := JobGLAccPrice."Unit Price" * "Qty. per Unit of Measure";
            "Cost Factor" := JobGLAccPrice."Unit Cost Factor";
            "Line Discount %" := JobGLAccPrice."Line Discount %";
        end;
    end;

    procedure JobJnlLineFindJTPrice(var JobJnlLine: Record "Job Journal Line")
    var
        JobItemPrice: Record "Job Item Price";
        JobResPrice: Record "Job Resource Price";
        JobGLAccPrice: Record "Job G/L Account Price";
    begin
        with JobJnlLine do
            case Type of
                Type::Item:
                    begin
                        JobItemPrice.SetRange("Job No.", "Job No.");
                        JobItemPrice.SetRange("Item No.", "No.");
                        JobItemPrice.SetRange("Variant Code", "Variant Code");
                        JobItemPrice.SetRange("Unit of Measure Code", "Unit of Measure Code");
                        JobItemPrice.SetRange("Currency Code", "Currency Code");
                        JobItemPrice.SetRange("Job Task No.", "Job Task No.");
                        OnJobJnlLineFindJTPriceOnAfterSetJobItemPriceFilters(JobItemPrice, JobJnlLine);
                        if JobItemPrice.FindFirst then
                            CopyJobItemPriceToJobJnlLine(JobJnlLine, JobItemPrice)
                        else begin
                            JobItemPrice.SetRange("Job Task No.", ' ');
                            if JobItemPrice.FindFirst then
                                CopyJobItemPriceToJobJnlLine(JobJnlLine, JobItemPrice);
                        end;
                        if JobItemPrice.IsEmpty or (not JobItemPrice."Apply Job Discount") then
                            FindJobJnlLineLineDisc(JobJnlLine);
                        OnAfterJobJnlLineFindJTPriceItem(JobJnlLine);
                    end;
                Type::Resource:
                    begin
                        Res.Get("No.");
                        JobResPrice.SetRange("Job No.", "Job No.");
                        JobResPrice.SetRange("Currency Code", "Currency Code");
                        JobResPrice.SetRange("Job Task No.", "Job Task No.");
                        case true of
                            JobJnlLineFindJobResPrice(JobJnlLine, JobResPrice, JobResPrice.Type::Resource):
                                CopyJobResPriceToJobJnlLine(JobJnlLine, JobResPrice);
                            JobJnlLineFindJobResPrice(JobJnlLine, JobResPrice, JobResPrice.Type::"Group(Resource)"):
                                CopyJobResPriceToJobJnlLine(JobJnlLine, JobResPrice);
                            JobJnlLineFindJobResPrice(JobJnlLine, JobResPrice, JobResPrice.Type::All):
                                CopyJobResPriceToJobJnlLine(JobJnlLine, JobResPrice);
                            else begin
                                    JobResPrice.SetRange("Job Task No.", '');
                                    case true of
                                        JobJnlLineFindJobResPrice(JobJnlLine, JobResPrice, JobResPrice.Type::Resource):
                                            CopyJobResPriceToJobJnlLine(JobJnlLine, JobResPrice);
                                        JobJnlLineFindJobResPrice(JobJnlLine, JobResPrice, JobResPrice.Type::"Group(Resource)"):
                                            CopyJobResPriceToJobJnlLine(JobJnlLine, JobResPrice);
                                        JobJnlLineFindJobResPrice(JobJnlLine, JobResPrice, JobResPrice.Type::All):
                                            CopyJobResPriceToJobJnlLine(JobJnlLine, JobResPrice);
                                    end;
                                end;
                        end;
                        OnAfterJobJnlLineFindJTPriceResource(JobJnlLine);
                    end;
                Type::"G/L Account":
                    begin
                        JobGLAccPrice.SetRange("Job No.", "Job No.");
                        JobGLAccPrice.SetRange("G/L Account No.", "No.");
                        JobGLAccPrice.SetRange("Currency Code", "Currency Code");
                        JobGLAccPrice.SetRange("Job Task No.", "Job Task No.");
                        if JobGLAccPrice.FindFirst then
                            CopyJobGLAccPriceToJobJnlLine(JobJnlLine, JobGLAccPrice)
                        else begin
                            JobGLAccPrice.SetRange("Job Task No.", '');
                            if JobGLAccPrice.FindFirst then;
                            CopyJobGLAccPriceToJobJnlLine(JobJnlLine, JobGLAccPrice);
                        end;
                        OnAfterJobJnlLineFindJTPriceGLAccount(JobJnlLine);
                    end;
            end;
    end;

    local procedure CopyJobItemPriceToJobJnlLine(var JobJnlLine: Record "Job Journal Line"; JobItemPrice: Record "Job Item Price")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCopyJobItemPriceToJobJnlLine(JobJnlLine, JobItemPrice, IsHandled);
        if IsHandled then
            exit;

        with JobJnlLine do begin
            if JobItemPrice."Apply Job Price" then begin
                "Unit Price" := JobItemPrice."Unit Price";
                "Cost Factor" := JobItemPrice."Unit Cost Factor";
            end;
            if JobItemPrice."Apply Job Discount" then
                "Line Discount %" := JobItemPrice."Line Discount %";
        end;
    end;

    local procedure FindJobPlanningLineLineDisc(var JobPlanningLine: Record "Job Planning Line")
    begin
        with JobPlanningLine do begin
            SetCurrency("Currency Code", "Currency Factor", "Planning Date");
            SetUoM(Abs(Quantity), "Qty. per Unit of Measure");
            TestField("Qty. per Unit of Measure");
            if Type = Type::Item then begin
                JobPlanningLineLineDiscExists(JobPlanningLine, false);
                CalcBestLineDisc(TempSalesLineDisc);
                if AllowLineDisc then
                    "Line Discount %" := TempSalesLineDisc."Line Discount %"
                else
                    "Line Discount %" := 0;
            end;
        end;

        OnAfterFindJobPlanningLineLineDisc(JobPlanningLine, TempSalesLineDisc);
    end;

    local procedure JobPlanningLineLineDiscExists(var JobPlanningLine: Record "Job Planning Line"; ShowAll: Boolean): Boolean
    var
        Job: Record Job;
    begin
        with JobPlanningLine do
            if (Type = Type::Item) and Item.Get("No.") then begin
                Job.Get("Job No.");
                OnBeforeJobPlanningLineLineDiscExists(JobPlanningLine);
                FindSalesLineDisc(
                  TempSalesLineDisc, Job."Bill-to Customer No.", Job."Bill-to Contact No.",
                  Job."Customer Disc. Group", '', "No.", Item."Item Disc. Group", "Variant Code", "Unit of Measure Code",
                  "Currency Code", JobPlanningLineStartDate(JobPlanningLine, DateCaption), ShowAll);
                OnAfterJobPlanningLineLineDiscExists(JobPlanningLine);
                exit(TempSalesLineDisc.Find('-'));
            end;
        exit(false);
    end;

    local procedure JobPlanningLineStartDate(JobPlanningLine: Record "Job Planning Line"; var DateCaption: Text[30]): Date
    begin
        DateCaption := JobPlanningLine.FieldCaption("Planning Date");
        exit(JobPlanningLine."Planning Date");
    end;

    local procedure FindJobJnlLineLineDisc(var JobJnlLine: Record "Job Journal Line")
    begin
        with JobJnlLine do begin
            SetCurrency("Currency Code", "Currency Factor", "Posting Date");
            SetUoM(Abs(Quantity), "Qty. per Unit of Measure");
            TestField("Qty. per Unit of Measure");
            if Type = Type::Item then begin
                JobJnlLineLineDiscExists(JobJnlLine, false);
                CalcBestLineDisc(TempSalesLineDisc);
                "Line Discount %" := TempSalesLineDisc."Line Discount %";
            end;
        end;

        OnAfterFindJobJnlLineLineDisc(JobJnlLine, TempSalesLineDisc);
    end;

    local procedure JobJnlLineLineDiscExists(var JobJnlLine: Record "Job Journal Line"; ShowAll: Boolean): Boolean
    var
        Job: Record Job;
    begin
        with JobJnlLine do
            if (Type = Type::Item) and Item.Get("No.") then begin
                Job.Get("Job No.");
                OnBeforeJobJnlLineLineDiscExists(JobJnlLine);
                FindSalesLineDisc(
                  TempSalesLineDisc, Job."Bill-to Customer No.", Job."Bill-to Contact No.",
                  Job."Customer Disc. Group", '', "No.", Item."Item Disc. Group", "Variant Code", "Unit of Measure Code",
                  "Currency Code", JobJnlLineStartDate(JobJnlLine, DateCaption), ShowAll);
                OnAfterJobJnlLineLineDiscExists(JobJnlLine);
                exit(TempSalesLineDisc.Find('-'));
            end;
        exit(false);
    end;

    local procedure JobJnlLineStartDate(JobJnlLine: Record "Job Journal Line"; var DateCaption: Text[30]): Date
    begin
        DateCaption := JobJnlLine.FieldCaption("Posting Date");
        exit(JobJnlLine."Posting Date");
    end;

    local procedure FindJobResPrice(var JobResPrice: Record "Job Resource Price"; WorkTypeCode: Code[10]): Boolean
    begin
        JobResPrice.SetRange("Work Type Code", WorkTypeCode);
        if JobResPrice.FindFirst then
            exit(true);
        JobResPrice.SetRange("Work Type Code", '');
        exit(JobResPrice.FindFirst);
    end;

    procedure FindResPrice(var ResJournalLine: Record "Res. Journal Line")
    begin
        GLSetup.Get();
        ResPrice.Init();
        ResPrice.Code := ResJournalLine."Resource No.";
        ResPrice."Work Type Code" := ResJournalLine."Work Type Code";
        ResJournalLine.BeforeFindResPrice(ResPrice);
        CODEUNIT.Run(CODEUNIT::"Resource-Find Price", ResPrice);
        ResJournalLine.AfterFindResPrice(ResPrice);
        ResJournalLine."Unit Price" :=
            Round(ResPrice."Unit Price" * ResJournalLine."Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision");
        ResJournalLine.Validate("Unit Price");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcBestUnitPrice(var SalesPrice: Record "Sales Price"; var BestSalesPrice: Record "Sales Price")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcBestUnitPriceAsItemUnitPrice(var SalesPrice: Record "Sales Price"; var Item: Record Item)
    begin
    end;

    procedure SetPostingShipment(NewPostingShipment: Boolean)
    begin
        PostingShipment := NewPostingShipment; // PR3.60
    end;

    local procedure PrepareSalesPrices(var SalesPrice: Record "Sales Price")
    begin
        // PR3.60
        with SalesPrice do begin
            ItemSalesPriceMgmt.RoundCurrencyUnitPrice("Currency Code", "Unit Price");
            ItemSalesPriceMgmt.RoundCurrencyUnitPrice("Currency Code", "Break Charge");

            ConvertPriceToVAT(
              "Price Includes VAT", Item."VAT Prod. Posting Group", "VAT Bus. Posting Gr. (Price)", "Sales Unit Price"); // PR3.70
            if ("Price Rounding Method" <> '') then                                               // P8000539A
                ItemSalesPriceMgmt.RoundWithMethodCode("Price Rounding Method", "Sales Unit Price") // P8000539A
            else                                                                                  // P8000539A
                ItemSalesPriceMgmt.RoundItemUnitPrice(Item, "Sales Unit Price");
            ItemSalesPriceMgmt.RoundCurrencyUnitPrice(SourceSalesPrice."Currency Code", "Sales Unit Price");
        end;
        // PR3.60
    end;

    local procedure CopyItemSalesPriceToSalesPrice(var FromSalesPrice: Record "Sales Price"; var ToSalesPrice: Record "Sales Price")
    var
        ItemCategory: Record "Item Category";
    begin
        // PR3.60
        with FromSalesPrice do begin
            SetRange("Item Type", "Item Type"::"All Items");
            SetRange("Item Code");
            //SETRANGE("Item Code 2"); // P8007749
            CopySalesPriceToSalesPrice(FromSalesPrice, ToSalesPrice);

            SetRange("Item Type", "Item Type"::Item);
            SetRange("Item Code", Item."No.");
            CopySalesPriceToSalesPrice(FromSalesPrice, ToSalesPrice);

            if (Item."Item Category Code" <> '') then begin
                SetRange("Item Type", "Item Type"::"Item Category");
                // P8007749
                ItemCategory.Get(Item."Item Category Code");
                SetFilter("Item Code", ItemCategory.GetAncestorFilterString(true));
                CopySalesPriceToSalesPrice(FromSalesPrice, ToSalesPrice);
                // P8007749
            end;
        end;
        // PR3.60
    end;

    local procedure CopyItemSalesDiscToSalesDisc(var FromSalesLineDisc: Record "Sales Line Discount"; var ToSalesLineDisc: Record "Sales Line Discount"; ItemDiscGrCode: Code[10])
    var
        ItemCategory: Record "Item Category";
    begin
        // PR3.60
        with FromSalesLineDisc do begin
            SetRange("Item Type", "Item Type"::"All Items");
            SetRange("Item Code");
            //SETRANGE("Item Code 2"); // P8007749
            CopySalesDiscToSalesDisc(FromSalesLineDisc, ToSalesLineDisc);

            SetRange("Item Type", "Item Type"::Item);
            SetRange("Item Code", Item."No.");
            CopySalesDiscToSalesDisc(FromSalesLineDisc, ToSalesLineDisc);

            if (ItemDiscGrCode <> '') then begin
                SetRange("Item Type", "Item Type"::"Item Disc. Group");
                SetRange("Item Code", ItemDiscGrCode);
                CopySalesDiscToSalesDisc(FromSalesLineDisc, ToSalesLineDisc);
            end;

            if Item."Item Category Code" <> '' then begin
                SetRange("Item Type", "Item Type"::"Item Category");
                // P8007749
                ItemCategory.Get(Item."Item Category Code");
                SetFilter("Item Code", ItemCategory.GetAncestorFilterString(true));
                CopySalesDiscToSalesDisc(FromSalesLineDisc, ToSalesLineDisc);
            end;
            // P8007749
        end;
        // PR3.60
    end;

    local procedure FindSellToSalesPrice(var ToSalesPrice: Record "Sales Price"; SellToCustNo: Code[20]; BillToCustNo: Code[20]; VariantCode: Code[10]; UOM: Code[10]; CurrencyCode: Code[10]; StartingDate: Date; ShowAll: Boolean)
    var
        FromSalesPrice: Record "Sales Price";
    begin
        // PR3.60
        // PR3.70 - parameters added for variant code, uom code, currency code, starting date
        if (SellToCustNo = BillToCustNo) or (SellToCustNo = '') then
            exit;

        with FromSalesPrice do begin
            SetFilter("Variant Code", '%1|%2', VariantCode, '');      // PR3.70
            SetFilter("Ending Date", '%1|>=%2', 0D, StartingDate);   // PR3.70
            if not ShowAll then begin
                SetFilter("Currency Code", '%1|%2', CurrencyCode, ''); // PR3.70
                SetFilter("Unit of Measure Code", '%1|%2', UOM, '');   // PR3.70
                SetRange("Starting Date", 0D, StartingDate);           // PR3.70
            end;

            SetRange("Sales Type", "Sales Type"::Customer);
            SetRange("Sales Code", SellToCustNo);
            CopyItemSalesPriceToSalesPrice(FromSalesPrice, ToSalesPrice);
        end;
        // PR3.60
    end;

    local procedure FindSellToSalesLineDisc(var ToSalesLineDisc: Record "Sales Line Discount"; ItemNo: Code[20]; ItemDiscGrCode: Code[10]; SellToCustNo: Code[20]; BillToCustNo: Code[20]; VariantCode: Code[10]; UOM: Code[10]; CurrencyCode: Code[10]; StartingDate: Date; ShowAll: Boolean)
    var
        FromSalesLineDisc: Record "Sales Line Discount";
    begin
        // PR3.60
        // PR3.70 - parameters added for variant code, uom code, currency code, starting date
        if (SellToCustNo = BillToCustNo) or (SellToCustNo = '') then
            exit;

        with FromSalesLineDisc do begin
            SetFilter("Variant Code", '%1|%2', VariantCode, '');     // PR3.70
            SetFilter("Ending Date", '%1|>=%2', 0D, StartingDate);   // PR3.70
            if not ShowAll then begin
                SetFilter("Currency Code", '%1|%2', CurrencyCode, ''); // PR3.70
                SetFilter("Unit of Measure Code", '%1|%2', UOM, '');   // PR3.70
                SetRange("Starting Date", 0D, StartingDate);           // PR3.70
            end;

            SetRange("Sales Type", "Sales Type"::Customer);
            SetRange("Sales Code", SellToCustNo);
            CopyItemSalesDiscToSalesDisc(FromSalesLineDisc, ToSalesLineDisc, ItemDiscGrCode);
        end;
        // PR3.60
    end;

    local procedure InitCurrencyAndTaxVars(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        // PR3.60
        with SalesLine do begin
            SetSalesHeader(SalesHeader); // P8000539A
            TestField("Qty. per Unit of Measure");
            PricesInclVAT := SalesHeader."Prices Including VAT";
            PricesInCurrency := SalesHeader."Currency Code" <> '';
            if PricesInCurrency then begin
                Currency.Get(SalesHeader."Currency Code");
                SalesHeader.TestField("Currency Factor");
                Currency.TestField("Unit-Amount Rounding Precision");
                CurrencyFactor := SalesHeader."Currency Factor";
                ExchRateDate := GetDate;
            end else
                GLSetup.Get;

            Item.Get("No.");
            Qty := Abs(Quantity);
            QtyPerUOM := "Qty. per Unit of Measure";
            VATPerCent := "VAT %";
            VATCalcType := "VAT Calculation Type";
            VATBusPostingGr := "VAT Bus. Posting Group";
            LineDiscPerCent := "Line Discount %";
            AllowLineDisc := "Allow Line Disc.";
            AllowInvDisc := "Allow Invoice Disc.";
        end;
        // PR3.60
    end;

    procedure FindCustomerPriceListPrice(var Item2: Record Item; var Customer2: Record Customer; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; PriceDate: Date; IncludeAccruals: Boolean)
    var
        SalesAccrualMgt: Codeunit "Sales Accrual Management";
    begin
        // PR3.60
        // P8000249A - add parameter IncludeAccruals
        // P8000253A - add paraeter VariantCode
        with Customer2 do begin
            InitCurrencyFromCustomer(Customer2, PriceDate);

            Item := Item2;
            Item."Unit Price" := 0;

            GetCustomerPriceListPrices(TempSalesPrice, Customer2,
              VariantCode, UnitOfMeasureCode, "Currency Code", PriceDate); // PR3.70, P8000253A

            CalcBestUnitPrice(TempSalesPrice);

            Item2."Unit Price" := TempSalesPrice."Sales Unit Price";

            // P8000249A
            if IncludeAccruals and ProcessFns.AccrualsInstalled then
                Item2."Unit Price" :=
                  SalesAccrualMgt.SalesPriceListPrice("No.", '', Item2."No.", UnitOfMeasureCode, PriceDate, Item2."Unit Price");
            // P8000249A
        end;
        // PR3.60
    end;

    procedure FindCustomerPriceListUnits(var Item2: Record Item; Customer2: Record Customer; PriceDate: Date; BrokenCasePrices: Boolean; var TempUOM: Record "Unit of Measure" temporary)
    var
        TempSalesPrice2: Record "Sales Price" temporary;
        ItemUOM: Record "Item Unit of Measure";
    begin
        // PR3.60
        with Customer2 do begin
            InitCurrencyFromCustomer(Customer2, PriceDate);

            Item := Item2;

            TempUOM.Reset;
            TempUOM.DeleteAll;

            GetCustomerPriceListPrices(TempSalesPrice2, Customer2,
              '', '', '', PriceDate); // PR3.70

            TempSalesPrice2.Reset;
            TempSalesPrice2.SetFilter("Currency Code", '%1|%2', "Currency Code", '');
            TempSalesPrice2.SetFilter("Unit of Measure Code", '<>%1', '');
            TempSalesPrice2.SetRange("Starting Date", 0D, PriceDate);
            if TempSalesPrice2.Find('-') then
                repeat
                    if not TempUOM.Get(TempSalesPrice2."Unit of Measure Code") then begin
                        TempUOM.Code := TempSalesPrice2."Unit of Measure Code";
                        TempUOM.Insert;
                    end;
                until (TempSalesPrice2.Next = 0);

            if BrokenCasePrices then begin
                ItemUOM.SetRange("Item No.", Item2."No.");
                ItemUOM.SetFilter("Break Charge Adjustment", '<>0');
                if ItemUOM.Find('-') then
                    repeat
                        if not TempUOM.Get(ItemUOM.Code) then begin
                            TempUOM.Code := ItemUOM.Code;
                            TempUOM.Insert;
                        end;
                    until (ItemUOM.Next = 0);
            end;
        end;
        // PR3.60
    end;

    local procedure InitCurrencyFromCustomer(var Customer2: Record Customer; PriceDate: Date)
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        // PR3.60
        with Customer2 do begin
            PricesInclVAT := "Prices Including VAT";
            PricesInCurrency := "Currency Code" <> '';
            if PricesInCurrency then begin
                Currency.Get("Currency Code");
                Currency.TestField("Unit-Amount Rounding Precision");
                CurrencyFactor := CurrExchRate.ExchangeRate(PriceDate, "Currency Code");
                ExchRateDate := PriceDate;
            end else
                GLSetup.Get;

            Qty := 0;
            QtyPerUOM := 1;
            VATPerCent := 0;
            VATCalcType := 0;
            VATBusPostingGr := '';
            LineDiscPerCent := 0;
            AllowLineDisc := false;
            AllowInvDisc := false;
        end;
        // PR3.60
    end;

    local procedure GetCustomerPriceListPrices(var TempSalesPrice2: Record "Sales Price"; Customer2: Record Customer; VariantCode: Code[10]; UOM: Code[10]; CurrencyCode: Code[10]; StartingDate: Date)
    var
        BillToCustomer: Record Customer;
        PriceGroupCustomer: Code[20];
    begin
        // PR3.60
        // PR3.70 - add parameters for variant code, uom code, currency code, starting date
        with Customer2 do begin
            if ("Bill-to Customer No." in ['', "No."]) then
                BillToCustomer := Customer2
            else
                BillToCustomer.Get("Bill-to Customer No.");

            // P8001026
            if "Use Sell-to Price Group" then begin
                BillToCustomer."Customer Price Group" := Customer2."Customer Price Group";
                PriceGroupCustomer := Customer2."No.";
            end else
                PriceGroupCustomer := BillToCustomer."No.";
            // P8001026

            // P8000545A
            ItemSalesPriceMgmt.SetCustItemPriceGroup(
              BillToCustomer."Customer Price Group", PriceGroupCustomer, // P8001026
              Item."Item Category Code"); // P8007749
                                          // P8000545A

            FindSalesPrice(
              TempSalesPrice2, BillToCustomer."No.", '', BillToCustomer."Customer Price Group", '', // PR3.70
              Item."No.", VariantCode, UOM, CurrencyCode, StartingDate, false);                         // PR3.70

            FindSellToSalesPrice(TempSalesPrice2, "No.", BillToCustomer."No.",
              VariantCode, UOM, CurrencyCode, StartingDate, false);                             // PR3.70
        end;
        // PR3.60
    end;

    procedure IsContractItem(): Boolean
    begin
        exit(ContractItem); // PR3.70
    end;

    procedure FindPriceGroupPriceListPrice(var Item2: Record Item; var PriceGroup2: Record "Customer Price Group"; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; PriceDate: Date; IncludeAccruals: Boolean)
    var
        SalesAccrualMgt: Codeunit "Sales Accrual Management";
    begin
        // P8000247A
        // P8000249A - add parameter IncludeAccruals
        // P8000253A - add paraeter VariantCode
        Item := Item2;
        Item."Unit Price" := 0;

        GetPriceGroupPriceListPrices(TempSalesPrice, PriceGroup2, VariantCode, UnitOfMeasureCode, '', PriceDate); // P8000253A

        CalcBestUnitPrice(TempSalesPrice);

        Item2."Unit Price" := TempSalesPrice."Sales Unit Price";

        // P8000249A
        if IncludeAccruals and ProcessFns.AccrualsInstalled then
            Item2."Unit Price" :=
              SalesAccrualMgt.SalesPriceListPrice('', PriceGroup2.Code, Item2."No.", UnitOfMeasureCode, PriceDate, Item2."Unit Price");
        // P8000249A
    end;

    procedure FindPriceGroupPriceListUnits(var Item2: Record Item; PriceGroup2: Record "Customer Price Group"; PriceDate: Date; BrokenCasePrices: Boolean; var TempUOM: Record "Unit of Measure" temporary)
    var
        TempSalesPrice2: Record "Sales Price" temporary;
        ItemUOM: Record "Item Unit of Measure";
    begin
        // P8000247A
        Item := Item2;

        TempUOM.Reset;
        TempUOM.DeleteAll;

        GetPriceGroupPriceListPrices(TempSalesPrice2, PriceGroup2, '', '', '', PriceDate);

        TempSalesPrice2.Reset;
        TempSalesPrice2.SetFilter("Currency Code", '%1', '');
        TempSalesPrice2.SetFilter("Unit of Measure Code", '<>%1', '');
        TempSalesPrice2.SetRange("Starting Date", 0D, PriceDate);
        if TempSalesPrice2.Find('-') then
            repeat
                if not TempUOM.Get(TempSalesPrice2."Unit of Measure Code") then begin
                    TempUOM.Code := TempSalesPrice2."Unit of Measure Code";
                    TempUOM.Insert;
                end;
            until (TempSalesPrice2.Next = 0);

        if BrokenCasePrices then begin
            ItemUOM.SetRange("Item No.", Item2."No.");
            ItemUOM.SetFilter("Break Charge Adjustment", '<>0');
            if ItemUOM.Find('-') then
                repeat
                    if not TempUOM.Get(ItemUOM.Code) then begin
                        TempUOM.Code := ItemUOM.Code;
                        TempUOM.Insert;
                    end;
                until (ItemUOM.Next = 0);
        end;
    end;

    local procedure GetPriceGroupPriceListPrices(var TempSalesPrice2: Record "Sales Price"; PriceGroup2: Record "Customer Price Group"; VariantCode: Code[10]; UOM: Code[10]; CurrencyCode: Code[10]; StartingDate: Date)
    var
        BillToCustomer: Record Customer;
    begin
        // P8000247A
        FindSalesPrice(
          TempSalesPrice2, '', '', PriceGroup2.Code, '',
          Item."No.", VariantCode, UOM, CurrencyCode, StartingDate, false);
    end;

    procedure SetShortSubstituteItem()
    begin
        // P8007152
        IsShortSubstituteItem := true;
    end;

    [Scope('Personalization')]
    procedure GetSalesLinePriceForOrderGuide(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var pSalesPrice: Record "Sales Price")
    begin
        // P80072447
        //Copy of function GetSalesLinePrice
        InitCurrencyAndTaxVars(SalesHeader, SalesLine);
        SalesLinePriceExists(SalesHeader, SalesLine, true);
        Commit;

        with SalesLine do begin
            if ProcessFns.PricingInstalled then
                if (PAGE.RunModal(PAGE::"Get Sales Price", TempSalesPrice) <> ACTION::LookupOK)
                then begin
                    Clear(pSalesPrice);
                    exit;
                end;
            if not (TempSalesPrice."Currency Code" in ["Currency Code", '']) then
                Error(Text001, FieldCaption("Currency Code"), TableCaption, TempSalesPrice.TableCaption);

            if not (TempSalesPrice."Unit of Measure Code" in ["Unit of Measure Code", '']) then
                Error(Text001, FieldCaption("Unit of Measure Code"), TableCaption, TempSalesPrice.TableCaption);

            SetVAT(
              SalesHeader."Prices Including VAT", "VAT %", "VAT Calculation Type", "VAT Bus. Posting Group");
            SetUoM(Abs(Quantity), "Qty. per Unit of Measure");
            SetCurrency(
              SalesHeader."Currency Code", SalesHeader."Currency Factor", SalesHeaderExchDate(SalesHeader));

            if not IsInMinQty(TempSalesPrice."Unit of Measure Code", TempSalesPrice."Minimum Quantity") then
                Error(
                  Text000,
                  FieldCaption(Quantity),
                  TempSalesPrice.FieldCaption("Minimum Quantity"),
                  TempSalesPrice.TableCaption);

            if not ItemSalesPriceMgmt.IsInMaxQty(TempSalesPrice, QtyPerUOM, Qty) then
                Error(Text37002000, TempSalesPrice.FieldCaption("Maximum Quantity"), TempSalesPrice.TableCaption);

            if TempSalesPrice."Starting Date" > SalesHeaderStartDate(SalesHeader, DateCaption) then
                Error(
                  Text000,
                  DateCaption,
                  TempSalesPrice.FieldCaption("Starting Date"),
                  TempSalesPrice.TableCaption);

            TempSalesPrice."Unit Price" := TempSalesPrice."Sales Unit Price";
            pSalesPrice := TempSalesPrice;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcLineAmount(SalesPrice: Record "Sales Price"; var LineAmount: Decimal; var LineDiscPerCent: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyJobResPriceToJobJnlLine(var JobJnlLine: Record "Job Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindItemJnlLinePrice(var ItemJournalLine: Record "Item Journal Line"; var SalesPrice: Record "Sales Price"; CalledByFieldNo: Integer; FoundSalesPrice: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindJobJnlLineResPrice(var JobJournalLine: Record "Job Journal Line"; var ResourcePrice: Record "Resource Price")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindJobJnlLineLineDisc(var JobJournalLine: Record "Job Journal Line"; var TempSalesLineDisc: Record "Sales Line Discount" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindJobPlanningLineLineDisc(var JobPlanningLine: Record "Job Planning Line"; var TempSalesLineDisc: Record "Sales Line Discount" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindJobPlanningLineResPrice(var JobPlanningLine: Record "Job Planning Line"; var ResourcePrice: Record "Resource Price")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindStdItemJnlLinePrice(var StdItemJnlLine: Record "Standard Item Journal Line"; var SalesPrice: Record "Sales Price"; CalledByFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindSalesLinePrice(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var SalesPrice: Record "Sales Price"; var ResourcePrice: Record "Resource Price"; CalledByFieldNo: Integer; FoundSalesPrice: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindSalesLineLineDisc(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var SalesLineDiscount: Record "Sales Line Discount")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindSalesPrice(var ToSalesPrice: Record "Sales Price"; var FromSalesPrice: Record "Sales Price"; QtyPerUOM: Decimal; Qty: Decimal; CustNo: Code[20]; ContNo: Code[20]; CustPriceGrCode: Code[10]; CampaignNo: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UOM: Code[10]; CurrencyCode: Code[10]; StartingDate: Date; ShowAll: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindSalesLineItemPrice(var SalesLine: Record "Sales Line"; var TempSalesPrice: Record "Sales Price" temporary; var FoundSalesPrice: Boolean; CalledByFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindSalesLineResPrice(var SalesLine: Record "Sales Line"; var ResPrice: Record "Resource Price")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindSalesLineDisc(var ToSalesLineDisc: Record "Sales Line Discount"; CustNo: Code[20]; ContNo: Code[20]; CustDiscGrCode: Code[20]; CampaignNo: Code[20]; ItemNo: Code[20]; ItemDiscGrCode: Code[20]; VariantCode: Code[10]; UOM: Code[10]; CurrencyCode: Code[10]; StartingDate: Date; ShowAll: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindServLinePrice(var ServiceLine: Record "Service Line"; var ServiceHeader: Record "Service Header"; var SalesPrice: Record "Sales Price"; var ResourcePrice: Record "Resource Price"; var ServiceCost: Record "Service Cost"; CalledByFieldNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindServLineResPrice(var ServiceLine: Record "Service Line"; var ResPrice: Record "Resource Price")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindServLineDisc(var ServiceLine: Record "Service Line"; var ServiceHeader: Record "Service Header"; var SalesLineDiscount: Record "Sales Line Discount")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetSalesLinePrice(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var TempSalesPrice: Record "Sales Price" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetSalesLineLineDisc(var SalesLine: Record "Sales Line"; var SalesLineDiscount: Record "Sales Line Discount")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterJobJnlLineFindJTPriceGLAccount(var JobJournalLine: Record "Job Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterJobJnlLineFindJTPriceItem(var JobJournalLine: Record "Job Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterJobJnlLineFindJTPriceResource(var JobJournalLine: Record "Job Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterJobJnlLineLineDiscExists(var JobJournalLine: Record "Job Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterJobPlanningLineLineDiscExists(var JobPlanningLine: Record "Job Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSalesLineLineDiscExists(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var TempSalesLineDisc: Record "Sales Line Discount" temporary; ShowAll: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSalesLinePriceExists(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var TempSalesPrice: Record "Sales Price" temporary; ShowAll: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterServLinePriceExists(var ServiceLine: Record "Service Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterServLineLineDiscExists(var ServiceLine: Record "Service Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeActivatedCampaignExists(var ToCampaignTargetGr: Record "Campaign Target Group"; CustNo: Code[20]; ContNo: Code[20]; CampaignNo: Code[20]; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcBestLineDisc(var SalesLineDisc: Record "Sales Line Discount"; Item: Record Item; var IsHandled: Boolean; QtyPerUOM: Decimal; Qty: Decimal);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcBestUnitPrice(var SalesPrice: Record "Sales Price"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConvertPriceToVAT(var VATPostingSetup: Record "VAT Posting Setup"; var UnitPrice: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyJobItemPriceToJobJnlLine(var JobJnlLine: Record "Job Journal Line"; JobItemPrice: Record "Job Item Price"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyJobItemPriceToJobPlanLine(var JobPlanningLine: Record "Job Planning Line"; JobItemPrice: Record "Job Item Price"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopySalesPriceToSalesPrice(var FromSalesPrice: Record "Sales Price"; var ToSalesPrice: Record "Sales Price"; var IsHandled: Boolean)
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindAnalysisReportPrice(ItemNo: Code[20]; Date: Date; var UnitPrice: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindItemJnlLinePrice(var ItemJournalLine: Record "Item Journal Line"; CalledByFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindJobJnlLinePrice(var JobJournalLine: Record "Job Journal Line"; CalledByFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindJobPlanningLinePrice(var JobPlanningLine: Record "Job Planning Line"; CalledByFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindJobJnlLineResPrice(var JobJournalLine: Record "Job Journal Line"; var ResourcePrice: Record "Resource Price")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindSalesPrice(var ToSalesPrice: Record "Sales Price"; var FromSalesPrice: Record "Sales Price"; var QtyPerUOM: Decimal; var Qty: Decimal; var CustNo: Code[20]; var ContNo: Code[20]; var CustPriceGrCode: Code[10]; var CampaignNo: Code[20]; var ItemNo: Code[20]; var VariantCode: Code[10]; var UOM: Code[10]; var CurrencyCode: Code[10]; var StartingDate: Date; var ShowAll: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindSalesLinePrice(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; CalledByFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindSalesLineDisc(var ToSalesLineDisc: Record "Sales Line Discount"; var CustNo: Code[20]; ContNo: Code[20]; var CustDiscGrCode: Code[20]; var CampaignNo: Code[20]; var ItemNo: Code[20]; var ItemDiscGrCode: Code[20]; var VariantCode: Code[10]; var UOM: Code[10]; var CurrencyCode: Code[10]; var StartingDate: Date; var ShowAll: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindSalesLineLineDisc(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindServLinePrice(var ServiceLine: Record "Service Line"; ServiceHeader: Record "Service Header"; CalledByFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindServLineDisc(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFindStdItemJnlLinePrice(var StandardItemJournalLine: Record "Standard Item Journal Line"; CalledByFieldNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetSalesLinePrice(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetSalesLineLineDisc(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetServLinePrice(ServHeader: Record "Service Header"; var ServLine: Record "Service Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetServLineDisc(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeJobJnlLineLineDiscExists(var JobJournalLine: Record "Job Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeJobPlanningLineLineDiscExists(var JobPlanningLine: Record "Job Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeJobPlanningLineFindJTPrice(var JobPlanningLine: Record "Job Planning Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSalesHeaderStartDate(var SalesHeader: Record "Sales Header"; var DateCaption: Text[30]; var StartDate: Date; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeNoOfSalesLineLineDisc(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ShowAll: Boolean; var Result: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeNoOfSalesLinePrice(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ShowAll: Boolean; var Result: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeNoOfServLineLineDisc(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line"; ShowAll: Boolean; var Result: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeNoOfServLinePrice(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line"; ShowAll: Boolean; var Result: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSalesLineLineDiscExists(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var TempSalesLineDisc: Record "Sales Line Discount" temporary; StartingDate: Date; Qty: Decimal; QtyPerUOM: Decimal; ShowAll: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSalesLinePriceExists(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header"; var TempSalesPrice: Record "Sales Price" temporary; Currency: Record Currency; CurrencyFactor: Decimal; StartingDate: Date; Qty: Decimal; QtyPerUOM: Decimal; ShowAll: Boolean; var InHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSalesLinePriceExistsProcedure(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ShowAll: Boolean; TempSalesPrice: Record "Sales Price" temporary; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeServLinePriceExists(var ServiceLine: Record "Service Line"; var ServiceHeader: Record "Service Header"; var TempSalesPrice: Record "Sales Price" temporary; ShowAll: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeServLineLineDiscExists(var ServiceLine: Record "Service Line"; var ServiceHeader: Record "Service Header"; var TempSalesLineDisc: Record "Sales Line Discount" temporary; ShowAll: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetCustNoForSalesHeader(var SalesHeader: Record "Sales Header"; var CustomerNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindJobJnlLinePriceOnBeforeJobJnlLineFindJTPrice(var JobJnlLine: Record "Job Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindJobJnlLinePriceOnBeforeResourceGetJob(var JobJnlLine: Record "Job Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindSalesLineDiscOnAfterSetFilters(var SalesLineDiscount: Record "Sales Line Discount")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindSalesLineLineDiscOnBeforeCalcLineDisc(var SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var TempSalesLineDiscount: Record "Sales Line Discount" temporary; Qty: Decimal; QtyPerUOM: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnJobJnlLineFindJTPriceOnAfterSetJobItemPriceFilters(var JobItemPrice: Record "Job Item Price"; JobJnlLine: Record "Job Journal Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnJobPlanningLineFindJTPriceOnAfterSetJobGLAccPriceFilters(var JobItemPrice: Record "Job G/L Account Price"; JobPlanningLine: Record "Job Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnJobPlanningLineFindJTPriceOnAfterSetJobItemPriceFilters(var JobItemPrice: Record "Job Item Price"; JobPlanningLine: Record "Job Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnJobPlanningLineFindJTPriceOnAfterSetJobResPriceFilters(var JobResPrice: Record "Job Resource Price"; JobPlanningLine: Record "Job Planning Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindJobPlanningLinePriceOnBeforeJobPlanningLineFindJTPrice(var JobPlanningLine: Record "Job Planning Line"; var ResPrice: Record "Resource Price")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindSalesLinePriceOnAfterSetResPrice(var SalesLine: Record "Sales Line"; var ResPrice: Record "Resource Price")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindSalesLinePriceOnItemTypeOnAfterSetUnitPrice(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var TempSalesPrice: Record "Sales Price" temporary; CalledByFieldNo: Integer; FoundSalesPrice: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCalcBestUnitPriceConvertPrice(var SalesPrice: Record "Sales Price"; var IsHandled: Boolean; Item: Record "Item")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcBestUnitPriceOnBeforeCalcBestUnitPriceConvertPrice(var SalesPrice: Record "Sales Price"; Qty: Decimal; var IsHandled: Boolean)
    begin
    end;
}
#endif
