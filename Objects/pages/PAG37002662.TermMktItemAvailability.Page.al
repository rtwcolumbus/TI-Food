page 37002662 "Term. Mkt. Item Availability"
{
    // PR4.00
    // P8000253A, Myers Nissi, Jack Reynolds, 21 OCT 05
    //   Modifications to support entry of quantity to order and unit price dirtectly  on form
    // 
    // PRW15.00.02
    // P8000613A, VerticalSoft, Jack Reynolds, 18 JUL 08
    //   Resize to fit subform control on parent form
    // 
    // PRW15.00.03
    // P8000624A, VerticalSoft, Jack Reynolds, 19 AUG 08
    //   Add controls for country of origin
    // 
    // P8000637, VerticalSoft, Jack Reynolds, 06 NOV 08
    //   Fix record position when changing filters
    // 
    // PRW16.00.02
    // P8000797, VerticalSoft, MMAS, 25 MAR 10
    //   Page creation
    //   Item-related Actions (from Terminal Market Order) added
    // 
    // PRW16.00.03
    // P8000828, VerticalSoft, Don Bresee, 03 JUN 10
    //   Consolidate timer logic
    // 
    // PRW16.00.05
    // P8000944, Columbus IT, Jack Reynolds, 31 MAY 11
    //   Support for enahnced terminal market order entry
    // 
    // P8000946, Columbus IT, Jack Reynolds, 31 MAY 11
    //   Terminal Market availability by country of origin
    // 
    // PRW16.00.06
    // P8001042, Columbus IT, Jack Reynolds, 09 MAR 12
    //   Fix problem calculating prices by variant
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // PRW18.00
    // P8001360, Columbus IT, Jack Reynolds, 06 NOV 14
    //   Update .NET variable references
    // 
    // PRW18.00.01
    // P8001386, Columbus IT, Jack Reynolds, 27 MAY 15
    //    Renamed NAV Food client addins
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 31 MAR 16
    //   Update add-in assembly version references
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // P8007755, To-Increase, Jack Reynolds, 22 NOV 16
    //   Update add-in assembly version references
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.01
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Upgrade signal control for JavaScript
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 28 APR 22
    //   Removing support for Signal Functions codeunit

    Caption = 'Terminal Market Item Availability';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    SourceTable = "Item Lot Availability";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Filters)
            {
                Caption = 'Filters';
                field(ItemCategory; ItemCategory[1])
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Category';
                    TableRelation = "Item Category";

                    trigger OnValidate()
                    begin
                        if ItemCategory[1] <> ItemCategory[2] then begin
                            Clear(ItemNo);
                            SetRange("Item No.");
                            ItemCategory[2] := ItemCategory[1];
                            SetFilter("Item Category Code", ItemCategory[1]);
                            ConvertItemCatFilterToItemCatOrderFilter; // P8007749
                            CurrPage.Update(false);
                        end;
                    end;
                }
                field(ItemNo; ItemNo[1])
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Number';

                    trigger OnValidate()
                    begin
                        if ItemNo[1] <> ItemNo[2] then begin
                            if ItemNo[1] <> '' then
                                if '*' <> CopyStr(ItemNo[1], StrLen(ItemNo[1])) then
                                    ItemNo[1] := ItemNo[1] + '*';
                            ItemNo[2] := ItemNo[1];
                            SetFilter("Item No.", ItemNo[1]);
                            CurrPage.Update(false);
                        end;
                    end;
                }
                field(Variant; VariantCode[1])
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Variant';
                    TableRelation = Variant;

                    trigger OnValidate()
                    begin
                        if VariantCode[1] <> VariantCode[2] then begin
                            VariantCode[2] := VariantCode[1];
                            SetFilter("Variant Code", VariantCode[1]);
                            CurrPage.Update(false);
                        end;
                    end;
                }
                field(RecentSales; RecentSales)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Recent Sales';

                    trigger OnValidate()
                    var
                        ItemLotAvail: Record "Item Lot Availability";
                    begin
                        if RecentSales and (not RecentSalesMarked) then begin
                            if CustomerNo <> RecentSalesCustomer then
                                MarkItemsForCustomer(CustomerNo);
                            ItemLotAvail.CopyFilters(Rec);
                            Reset;
                            if Find('-') then
                                repeat
                                    Mark(RecentSalesItem.Get("Item No."));
                                until Next = 0;
                            Rec.CopyFilters(ItemLotAvail);
                        end;

                        if RecentSales then
                            SetRange("Recent Sales Filter", true)
                        else
                            SetRange("Recent Sales Filter");
                        CurrPage.Update(false);
                    end;
                }
                field(SupplyChainGroups; SupplyChainGroups)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Supply Chain Groups';
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        PAGE.RunModal(PAGE::"Supply Chain Groups");
                        SetDefaultItems;
                        UpdateItemLotAvail;
                    end;
                }
            }
            repeater(Control37002001)
            {
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("CountryOfOrigin()"; CountryOfOrigin())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Country/Region of Origin';
                }
                field("Quantity Available"; "Quantity Available")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Unit of Measure';
                }
                field("Quantity to Sell"; "Quantity to Sell")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                }
                field("Unit Price to Sell"; "Unit Price to Sell")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Unit Price';
                }
            }
        }
        area(factboxes)
        {
            part(Detail; "Term. Mkt. Lot Detail FactBox")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Detail';
                SubPageLink = "Item No." = FIELD("Item No."),
                              "Variant Code" = FIELD("Variant Code"),
                              "Lot No." = FIELD("Lot No."),
                              "Country/Region of Origin Code" = FIELD("Country/Region of Origin Code");
            }
            part(QtyBreakdown; "Term. Mkt. Avail. FactBox")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Quantity Available';
                SubPageLink = "Item No." = FIELD("Item No."),
                              "Variant Code" = FIELD("Variant Code"),
                              "Lot No." = FIELD("Lot No."),
                              "Country/Region of Origin Code" = FIELD("Country/Region of Origin Code");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(AddItem)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Add Item';
                Image = Add;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    AddLine(false);
                end;
            }
            action(AddAllItems)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Add A&ll Items';
                Image = AddAction;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    AddLines;
                end;
            }
            action(RepackItem)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Repack Item';
                Image = Edit;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    AddLine(true);
                end;
            }
            action(AvailByLocation)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lot Availability by Location';
                Image = Lot;

                trigger OnAction()
                var
                    LotByLocation: Page "Item Lot by Location";
                begin
                    LotByLocation.LoadData("Item No.", ShipDate);
                    LotByLocation.RunModal;
                end;
            }
            action(SalesHistory)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Sales &History';
                Image = History;

                trigger OnAction()
                var
                    SalesHistory: Page "Customer/Item Sales";
                begin
                    if SalesHeader."Sell-to Customer No." = '' then
                        exit;

                    SalesHistory.SetVariables(SalesHeader."Sell-to Customer No.", "Item No.");
                    SalesHistory.RunModal;
                end;
            }
        }
    }

    trigger OnClosePage()
    begin
        SharedItemLotAvail.Reset;
        SharedItemLotAvail.DeleteAll;
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        RecentSales := GetFilter("Recent Sales Filter") <> '';
        MarkedOnly(RecentSales);
        exit(Find(Which));
    end;

    trigger OnOpenPage()
    begin
        CurrPage.Detail.PAGE.SetSharedTable(SharedItemLotAvail);
        CurrPage.QtyBreakdown.PAGE.SetSharedTable(SharedItemLotAvail);

        SalesSetup.Get;
        SetDefaultItems;
        ProcessOrder();
    end;

    var
        SalesSetup: Record "Sales & Receivables Setup";
        SalesHeader: Record "Sales Header";
        DefaultItem: Record Item temporary;
        RecentSalesItem: Record Item temporary;
        SharedItemLotAvail: Record "Item Lot Availability" temporary;
        SupplyChainGroups: Text[1024];
        AttributeFilter: Text[1024];
        CustomerNo: Code[20];
        ShipDate: Date;
        RecentSalesCustomer: Code[20];
        RecentSalesMarked: Boolean;
        LocationCode: Code[10];
        ItemCategory: array[2] of Code[20];
        ItemNo: array[2] of Code[20];
        VariantCode: array[2] of Code[10];
        Text001: Label '%1 %2 exists for more than one %3.';
        RecentSales: Boolean;
        Text002: Label 'No quantities have been entered.';

    [Obsolete('Removing support for Signal Functions codeunit', 'FOOD-21')]
    procedure SetSignalFns(var SignalCU: Codeunit "Process 800 Signal Functions")
    begin
    end;

    procedure SetSharedTable(var ItemLotAvail: Record "Item Lot Availability" temporary)
    begin
        SharedItemLotAvail.Copy(ItemLotAvail, true);
    end;

    procedure SetDefaultItems()
    var
        Item: Record Item;
        SupplyChainGroup: Record "Supply Chain Group";
        SupplyChainGroupUser: Record "Supply Chain Group User";
    begin
        DefaultItem.Reset;
        DefaultItem.DeleteAll;
        SupplyChainGroups := '';
        SupplyChainGroupUser.SetRange("User ID", UserId);
        if SupplyChainGroupUser.FindSet then begin
            repeat
                SupplyChainGroups := SupplyChainGroups + '|' + SupplyChainGroupUser."Supply Chain Group Code";
                SupplyChainGroup.Get(SupplyChainGroupUser."Supply Chain Group Code");
                SupplyChainGroup.MarkItems(Item);
            until SupplyChainGroupUser.Next = 0;
            SupplyChainGroups := CopyStr(SupplyChainGroups, 2);
        end;
        Item.MarkedOnly(true);
        if Item.Find('-') then
            repeat
                DefaultItem := Item;
                DefaultItem.Insert;
            until Item.Next = 0;
    end;

    procedure MarkItemsForCustomer(CustNo: Code[20])
    var
        ItemLedger: Record "Item Ledger Entry";
    begin
        RecentSalesItem.Reset;
        RecentSalesItem.DeleteAll;
        if Format(SalesSetup."Recent Sales Calculation") = '' then
            Evaluate(SalesSetup."Recent Sales Calculation", '-4W');
        with ItemLedger do begin
            SetCurrentKey("Entry Type", "Item No.", "Variant Code", "Source Type", "Source No.", "Posting Date");
            SetRange("Source Type", "Source Type"::Customer);
            SetRange("Source No.", CustNo);
            SetRange("Entry Type", "Entry Type"::Sale);
            SetRange("Posting Date", CalcDate(SalesSetup."Recent Sales Calculation", Today), Today);
            if Find('-') then
                repeat
                    RecentSalesItem."No." := "Item No.";
                    RecentSalesItem.Insert;
                    SetRange("Item No.", "Item No.");
                    Find('+');
                    SetRange("Item No.");
                until Next = 0;
        end;
        RecentSalesCustomer := CustNo;
    end;

    procedure ClearFilters()
    begin
        FilterGroup(2);
        SetFilter("Quantity Available", '>0');
        FilterGroup(0);
    end;

    procedure UpdateItemLotAvail()
    var
        ItemLotAvail: Record "Item Lot Availability" temporary;
        ItemLotAvail2: Record "Item Lot Availability";
        TerminalMarketFns: Codeunit "Terminal Market Selling";
        UnitPrice: Decimal;
        xVariantCode: Code[10];
    begin
        Reset;
        DeleteAll;
        SharedItemLotAvail.Reset;
        SharedItemLotAvail.DeleteAll;

        if CustomerNo = '' then
            exit;

        RecentSalesMarked := CustomerNo = RecentSalesCustomer;
        if DefaultItem.FindSet then
            repeat
                TerminalMarketFns.CalculateAvailability(DefaultItem, LocationCode, ShipDate, SalesSetup."Terminal Market Item Level",
                  ItemLotAvail);
                if ItemLotAvail.Find('-') then begin
                    ItemLotAvail.GetUnitPrice(SalesHeader."Bill-to Customer No.", SalesHeader."Order Date");
                    UnitPrice := ItemLotAvail."Unit Price";
                    xVariantCode := ItemLotAvail."Variant Code"; // P8001042
                    repeat
                        // P8001042
                        if ItemLotAvail."Variant Code" <> xVariantCode then begin
                            ItemLotAvail.GetUnitPrice(SalesHeader."Bill-to Customer No.", SalesHeader."Order Date");
                            UnitPrice := ItemLotAvail."Unit Price";
                            xVariantCode := ItemLotAvail."Variant Code";
                        end;
                        // P8001042
                        Rec := ItemLotAvail;
                        Description := DefaultItem.Description;
                        "Item Category Code" := DefaultItem."Item Category Code";
                        "Base Unit of Measure" := DefaultItem."Base Unit of Measure";
                        "Unit Price" := UnitPrice;
                        "Unit Price to Sell" := UnitPrice;
                        if DefaultItem.CostInAlternateUnits then
                            "Costing Unit of Measure" := DefaultItem."Alternate Unit of Measure"
                        else
                            "Costing Unit of Measure" := DefaultItem."Base Unit of Measure";
                        if ("Item No." <> ItemLotAvail2."Item No.") or ("Variant Code" <> ItemLotAvail2."Variant Code") then begin
                            GetLastTransaction(CustomerNo);
                            ItemLotAvail2 := Rec;
                        end else begin
                            "Last Sale Date" := ItemLotAvail2."Last Sale Date";
                            "Last Sale Price" := ItemLotAvail2."Last Sale Price";
                        end;
                        Insert;
                        SharedItemLotAvail := Rec;
                        SharedItemLotAvail.Insert;
                        if RecentSalesMarked then
                            Mark(RecentSalesItem.Get("Item No."));
                    until ItemLotAvail.Next = 0;
                end;
            until DefaultItem.Next = 0;
        FilterGroup(2);
        SetFilter("Quantity Available", '>0');
        FilterGroup(0);
    end;

    procedure UpdateLastTransaction()
    var
        ItemLotAvail: Record "Item Lot Availability";
    begin
        ItemLotAvail.CopyFilters(Rec);
        ItemLotAvail."Item No." := '';
        ItemLotAvail."Variant Code" := '';
        Reset;
        if Find('-') then
            repeat
                if ("Item No." <> ItemLotAvail."Item No.") or ("Variant Code" <> ItemLotAvail."Variant Code") then begin
                    GetLastTransaction(CustomerNo);
                    ItemLotAvail := Rec;
                end else begin
                    "Last Sale Date" := ItemLotAvail."Last Sale Date";
                    "Last Sale Price" := ItemLotAvail."Last Sale Price";
                end;
                Modify;
                SharedItemLotAvail := Rec;
                SharedItemLotAvail.Modify;
            until Next = 0;
        Rec.CopyFilters(ItemLotAvail);
    end;

    procedure SetOrder(OrderNo: Code[20])
    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);
        CustomerNo := SalesHeader."Sell-to Customer No.";
        LocationCode := SalesHeader."Location Code";
        ShipDate := SalesHeader."Shipment Date";
    end;

    local procedure ProcessOrder()
    begin
        ClearFilters;

        UpdateItemLotAvail;
        UpdateLastTransaction;

        if FindFirst then;
        CurrPage.Update(false);
    end;

    [Obsolete('Removing support for Signal Functions codeunit', 'FOOD-21')]
    procedure ProcessEvents()
    begin
    end;

    [Obsolete('Removing support for Signal Functions codeunit', 'FOOD-21')]
    procedure UpdateTermMktPage()
    begin
    end;

    procedure AddLine(Repack: Boolean): Boolean
    var
        SalesLine: Record "Sales Line";
        TerminalMarketFns: Codeunit "Terminal Market Selling";
        TermMktLineInput: Page "Term. Mkt. Line Input";
        Qty: Decimal;
        QtyAlt: Decimal;
        UnitPrice: Decimal;
        RepackItemNo: Code[20];
        RepackQty: Decimal;
        Comment: Text[30];
    begin
        TermMktLineInput.SetVariables('ADD', Repack, Rec, SalesHeader, 0, 0, 0, '', '');
        if TermMktLineInput.RunModal <> ACTION::Yes then  // ACTION::Cancel
            exit;

        if not TermMktLineInput.GetVariables(Qty, UnitPrice, RepackItemNo, RepackQty, QtyAlt, Comment) then
            exit;
        if Qty = 0 then
            exit;

        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        TerminalMarketFns.InsertSalesLine(SalesHeader, SalesLine, "Item No.", "Variant Code", "Lot No.",
          "Country/Region of Origin Code", // P8000946
          LocationCode, Qty, QtyAlt, UnitPrice, RepackItemNo, RepackQty, Comment, false);

        if not Repack then
            "Qty. on Sales Order" += Qty
        else begin
            "Qty. on Line Repack (Out)" += Qty;
            if SharedItemLotAvail.Get(RepackItemNo, "Variant Code", "Lot No.", "Country/Region of Origin Code") then begin
                SharedItemLotAvail."Qty. on Line Repack (In)" += RepackQty;
                SharedItemLotAvail."Qty. on Sales Order" += RepackQty;
                SharedItemLotAvail.CalculateAvailable;
                SharedItemLotAvail.Modify
            end;
        end;
        "Quantity to Sell" := 0;              // P8000944
        "Unit Price to Sell" := "Unit Price"; // P8000944
        CalculateAvailable;
        SharedItemLotAvail := Rec;
        SharedItemLotAvail.Modify;
        CurrPage.SaveRecord;
        exit(true);
    end;

    procedure AddLines(): Boolean
    var
        SalesLine: Record "Sales Line";
        ItemAvail: Record "Item Lot Availability" temporary;
        TerminalMarketFns: Codeunit "Terminal Market Selling";
        QtyAlt: Decimal;
    begin
        CurrPage.SaveRecord;
        ItemAvail.Copy(Rec);
        SetFilter("Quantity to Sell", '>0');
        if not Find('-') then begin
            Rec.Copy(ItemAvail);
            Message(Text002);
            exit;
        end;

        repeat
            Clear(SalesLine);
            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";
            QtyAlt := Round(ItemAvail."Quantity to Sell" * ItemAvail."Alternate Qty. per Base", 0.00001);
            TerminalMarketFns.InsertSalesLine(SalesHeader, SalesLine, "Item No.", "Variant Code", "Lot No.",
              "Country/Region of Origin Code", // P8000946
              LocationCode, "Quantity to Sell", QtyAlt, "Unit Price to Sell", '', 0, '', true);
            "Qty. on Sales Order" += "Quantity to Sell";
            CalculateAvailable;
            "Quantity to Sell" := 0;
            "Unit Price to Sell" := "Unit Price";
            Modify;
            SharedItemLotAvail := Rec;
            SharedItemLotAvail.Modify;
        until Next = 0;
        Rec.Copy(ItemAvail);
        SharedItemLotAvail.Get("Item No.", "Variant Code", "Lot No.", "Country/Region of Origin Code");
        Rec := SharedItemLotAvail;
        CurrPage.SaveRecord;
        exit(true);
    end;
}

