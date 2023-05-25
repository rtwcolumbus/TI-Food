page 37002048 "Sales Order Guide"
{
    // PR3.70
    //   Enhanced for contract items
    // 
    // PR4.00.02
    // P8000315A, VerticalSoft, Jack Reynolds, 28 MAR 06
    //   Add support for variant and unit price
    // 
    // PR4.00.04
    // P8000348A, VerticalSoft, Jack Reynolds, 28 JUN 06
    //   Fix issue with Last Order Amount and Last Cost (for different UOM's)
    // 
    // P8000384A, VerticalSoft, Jack Reynolds, 22 SEP 06
    //   Don't reset pricing option when checking/unchecking history guide
    // 
    // PR4.00.05
    // P8000449B, VerticalSoft, Jack Reynolds, 19 FEB 07
    //   Don't display blocked items
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.02
    // P8000791, VerticalSoft, MMAS, 16 MAR 10
    //   Page had been changed after transformation
    //   Functionality for "Date Filter" has been changed (DateFilter variable).
    // 
    // PRW16.00.04
    // P8000878, VerticalSoft, Ron Davidson, 11 NOV 10
    //   Changed Date Filter to Period Length which is a Date Formula
    // 
    // PRW16.00.06
    // P8000999, Columbus IT, Jack Reynolds, 09 DEC 11
    //   Modify for non-modal operation with sales order
    // 
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001149, Columbus IT, Don Bresee, 26 APR 13
    //   Eliminate OK/Cancel behaviour, it doesn't work for non-modal windows in NAV 2013
    // 
    // PRW18.00.01
    // P8001386, Columbus IT, Jack Reynolds, 27 MAY 15
    //   Renamed NAV Food client addins
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Upgrade signal control for JavaScript
    //   Cleanup TimerUpdate property
    // 
    // PRW111.00.02
    // P80072453, To-increase, Gangabhushan, 24 APR 19
    //   Dev. Item-Info factbox on Sales Order Guide
    //   Item Invoicing FactBox added
    // 
    //     PRW114.00
    // P80072447, To-increase, Gangabhushan, 24 APR 19
    //   Dev. Pricing information on the Sales Order Guide
    // 
    // P80072449, To-increase, Gangabhushan, 27 MAY 19
    //   Dev. Margin Information per item on the Sales Order Guide
    // 
    // PRW119.0
    // P800133109, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 19.0 - Qty. Rounding Precision
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 28 APR 22
    //   Removing support for Signal Functions codeunit
    // 
    // PRW121.0
    // P800155629, To-Increase, Jack Reynolds, 03 NOV 22
    //   Add support for Mandatory Variant

    Caption = 'Sales Order Guide';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = Item;
    SourceTableView = WHERE(Blocked = CONST(false));

    layout
    {
        area(content)
        {
            group(Control37002000)
            {
                ShowCaption = false;
                field("History Guide"; ShowItemsWithActivity)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'History Guide';
                    ToolTip = 'Use this flag to look at historical data for this customer only.';

                    trigger OnValidate()
                    begin
                        // PricingOptions := 0; // PR3.70;
                        OrderGuideMgmt.SetStartEndDates(HistoryPeriod, ShowItemsWithActivity); // P8000878
                        CurrPage.Update(false);
                    end;
                }
                field("<HistoryPeriod>"; HistoryPeriod)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'History Period';
                    Enabled = ShowItemsWithActivity;
                    ToolTip = 'Length of time to consider for History';

                    trigger OnValidate()
                    begin
                        OrderGuideMgmt.SetStartEndDates(HistoryPeriod, ShowItemsWithActivity); // P8000878
                        CurrPage.Update(false);
                    end;
                }
                field(PricingOptions; PricingOptions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pricing Options';
                    OptionCaption = 'None,Special Items,Contract Items';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field(DefaultSort; DefaultSort)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Default Sort';

                    trigger OnValidate()
                    begin
                        // P8000999
                        SetSort;
                        CurrPage.Update(false);
                    end;
                }
                field(LocationCode; LocationCode)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Location Code';
                    TableRelation = Location;

                    trigger OnValidate()
                    begin
                        SetRange("Location Filter", LocationCode);
                        CurrPage.Update(false);
                    end;
                }
                field(ItemCategoryFilter; ItemCategoryFilter)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Category Filter';
                    TableRelation = "Item Category";

                    trigger OnValidate()
                    begin
                        SetItemCategoryFilter; // P8007749
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(Control37002005)
            {
                ShowCaption = false;
                field("Item Type"; "Item Type")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Item Category Code"; "Item Category Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    ToolTip = 'Specifies the category that the item belongs to. Item categories also contain any assigned item attributes.';
                    Visible = false;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = "No.Emphasize";
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = DescriptionEmphasize;
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    ToolTip = 'Specifies the base unit used to measure the item, such as piece, box, or pallet. The base unit of measure also serves as the conversion basis for alternate units of measure.';
                }
                field(Inventory; Inventory)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. on Sales Order"; "Qty. on Sales Order")
                {
                    ApplicationArea = FOODBasic;
                    ToolTip = 'Specifies how many units of the item are allocated to sales orders, meaning listed on outstanding sales orders lines.';
                    Visible = false;
                }
                field(QtyAvailable; QtyAvailable)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Quantity Available';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'The quantity of the Item/Variant that is currently available for Sales, calculating future receipts and shipments and taking Lot-Status codes into account.';
                }
                field(LastDocNo; LastDocNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Last Document No.';
                    Editable = false;
                    ToolTip = 'Document No. on which this item was last used (could be a shipment or an invoice)';
                    Visible = false;
                }
                field(LastDate; LastDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Last Order Date';
                    Editable = false;
                    ToolTip = 'Date of the Last Document No.';
                }
                field(LastQty; LastQty)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Last Order Qty';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Last know quantity shipped or invoiced.';
                    Visible = false;
                }
                field(LastUOM; LastUOM)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Last Unit of Measure';
                    Editable = false;
                    ToolTip = 'Last used Unit of Measure Code';
                    Visible = false;
                }
                field(LastUnitPrice; LastUnitPrice)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Last Unit Price';
                    DecimalPlaces = 2 : 5;
                    Editable = false;
                    ToolTip = 'Last Unit Price applied for this item for this customer.';
                }
                field(LastAmount; LastAmount)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Last Order Amount';
                    Editable = false;
                    Visible = false;
                }
                field(QtyOrdered; QtyOrdered)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Qty. Shipped to Cust.';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'A history of the quantities shipped to this customer for this item.';

                    trigger OnDrillDown()
                    begin
                        OrderGuideMgmt.ShowQtyOrdered(Rec);
                    end;
                }
                field(OrderUOM; OrderUOM)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Order Unit of Measure';
                    NotBlank = true;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(OrderGuideMgmt.LookupUOM(Rec, Text));
                    end;

                    trigger OnValidate()
                    begin
                        OrderGuideMgmt.ValidateUOM(Rec, OrderUOM, VariantToOrder, QtyToOrder, UnitPrice, ContractNo); // P8000315A // P80072447
                        OrderGuideMgmt.SetQtyToOrder(Rec, QtyToOrder, VariantToOrder, OrderUOM, DefOrderUOM, UnitPrice, ContractNo, false); // P8000315A // P80072447
                        if ShowItemsWithActivity and (QtyToOrder = 0) then
                            CurrPage.Update(false);
                    end;
                }
                field(VariantToOrder; VariantToOrder)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Variant To Order';
                    ShowMandatory = VariantCodeMandatory;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        // P8000315A
                        exit(OrderGuideMgmt.LookupVariant(Rec, Text));
                    end;

                    trigger OnValidate()
                    begin
                        // P8000315A
                        OrderGuideMgmt.ValidateVariant(Rec, OrderUOM, VariantToOrder, QtyToOrder, UnitPrice, ContractNo); //P80072447
                        OrderGuideMgmt.SetQtyToOrder(Rec, QtyToOrder, VariantToOrder, OrderUOM, DefOrderUOM, UnitPrice, ContractNo, false); // P80072447
                    end;
                }
                field(QtyToOrder; QtyToOrder)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Quantity to Order';
                    DecimalPlaces = 0 : 5;

                    trigger OnValidate()
                    var
                        UOMMgt: Codeunit "Unit of Measure Management";
                        FoodManualSubscriptions: Codeunit "Food Manual Subscriptions";
                    begin
                        // P800133109
                        QtyToOrder := UOMMgt.RoundAndValidateQty(Rec."No.", OrderUOM, QtyToOrder, LabelQtyToOrder);
                        UOMMgt.CalcBaseQty(Rec."No.", OrderUOM, QtyToOrder);
                        // P800133109
                        // P80072447
                        Clear(Bounded);
                        if not PriceFromGetPriceFnc then begin
                            if (UnitPrice = 0) and (QtyToOrder <> 0) and (not OrderGuideMgmt.QtyToOrderExists) and (ContractNo = '') then
                                OrderGuideMgmt.ValidateQty(Rec, OrderUOM, VariantToOrder, QtyToOrder, UnitPrice, ContractNo); // P8000315A // P80072447

                            if (QtyToOrder <> 0) and (OrderGuideMgmt.QtyToOrderExists) and (ContractNo = '') then begin
                                FoodManualSubscriptions.SetOrderGuide();
                                Bounded := BindSubscription(FoodManualSubscriptions);
                                OrderGuideMgmt.ValidateQty(Rec, OrderUOM, VariantToOrder, QtyToOrder, UnitPrice, ContractNo); // P8000315A // P80072447
                            end;

                            if (QtyToOrder <> 0) and (ContractNo <> '') then begin
                                FoodManualSubscriptions.SetOrderGuide();
                                if not Bounded then
                                    BindSubscription(FoodManualSubscriptions);
                                OrderGuideMgmt.ValidateQty(Rec, OrderUOM, VariantToOrder, QtyToOrder, UnitPrice, ContractNo); // P8000315A // P80072447
                            end;
                        end;

                        if PriceFromGetPriceFnc and (QtyToOrder <> 0) and (OrderGuideMgmt.QtyToOrderExists) and (ContractNo <> '') then begin
                            FoodManualSubscriptions.SetOrderGuide();
                            if not Bounded then
                                BindSubscription(FoodManualSubscriptions);
                            OrderGuideMgmt.ValidateQty(Rec, OrderUOM, VariantToOrder, QtyToOrder, UnitPrice, ContractNo); // P8000315A // P80072447
                        end;

                        if QtyToOrder = 0 then begin
                            OrderGuideMgmt.ValidateQty(Rec, OrderUOM, VariantToOrder, QtyToOrder, UnitPrice, ContractNo); // P8000315A // P80072447
                            ContractNo := '';
                            PriceFromGetPriceFnc := false;
                        end;

                        if ContractNo <> '' then
                            CurrPage.ContractInfoFactbox.PAGE.ValidateSalesContractNo("No.", SalesPrice."Price Type", ContractNo)
                        else
                            CurrPage.ContractInfoFactbox.PAGE.ClearContractFields("No.");
                        // P80072447

                        // P80072449
                        OrderGuideMgmt.CalcUnitPriceLCY(UnitPrice, UnitPriceLCY);
                        CurrPage.MarginInfofactBox.PAGE.InsertSalesMargin("No.", "Item Category Code", QtyToOrder, UnitPriceLCY, "Unit Cost",
                                                                          CalcExpectedMarginLCY, CalcExpectedMarginPct);
                        // P80072449

                        OrderGuideMgmt.SetQtyToOrder(Rec, QtyToOrder, VariantToOrder, OrderUOM, DefOrderUOM, UnitPrice, ContractNo, false); // P8000315A // P80072447
                        if ShowItemsWithActivity and (QtyToOrder = 0) then
                            CurrPage.Update(false);
                    end;
                }
                field(UnitPrice; UnitPrice)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Unit Price';
                    DecimalPlaces = 2 : 5;
                    ToolTip = 'The price that will be applied to the Sales Line based on available Sales Price configuration or, if applicable, the selected price.';

                    trigger OnValidate()
                    var
                        Txt0001: Label 'Contract No. musst be equal to '''' in Sales Order Gude line. Current value is %1';
                    begin
                        // P80072447
                        if ContractNo <> '' then
                            Error(Txt0001, ContractNo);
                        // P80072447

                        // P880315A
                        OrderGuideMgmt.SetQtyToOrder(Rec, QtyToOrder, VariantToOrder, OrderUOM, DefOrderUOM, UnitPrice, ContractNo, false); // P80072447

                        // P80072449
                        OrderGuideMgmt.CalcUnitPriceLCY(UnitPrice, UnitPriceLCY);
                        CurrPage.MarginInfofactBox.PAGE.InsertSalesMargin("No.", "Item Category Code", QtyToOrder, UnitPriceLCY, "Unit Cost",
                                                                        CalcExpectedMarginLCY, CalcExpectedMarginPct);
                        // P80072449
                    end;
                }
                field("Sales Contract No."; ContractNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Sales Contract No.';
                    ToolTip = 'The Sales Contract No. if applicable.';

                    trigger OnValidate()
                    var
                        Txt0001: Label 'You can not change the Contract No.';
                    begin
                        // P80072447
                        if ContractNo = '' then begin
                            gItemNo := '';
                            UnitPrice := 0;
                            QtyToOrder := 0;
                            CurrPage.ContractInfoFactbox.PAGE.ClearContractFields("No.");
                            CurrPage.MarginInfofactBox.PAGE.ClearMarginRecords("No."); // P80072449
                            OrderGuideMgmt.SetQtyToOrder(Rec, QtyToOrder, VariantToOrder, OrderUOM, DefOrderUOM, UnitPrice, ContractNo, false); // P80072447
                            PriceFromGetPriceFnc := false;
                        end else
                            Error(Txt0001);
                        // P80072447
                    end;
                }
                field("PriceFrom Get Price Fnc"; PriceFromGetPriceFnc)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Unit Cost"; CalcUnitCostForMargin)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Unit Cost';
                }
                field("Unit Price LCY"; UnitPriceLCY)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Unit Price LCY';
                }
                field("Expected Margin (LCY)"; CalcExpectedMarginLCY)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Expected Margin (LCY)';
                    ToolTip = 'The calculated margin using the Quantity to Order, the Unit Cost and the Unit Price (LCY)';
                }
                field("Expected Margin %"; CalcExpectedMarginPct)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Expected Margin %';
                    ToolTip = 'The expected margin calculated as ((unit Price(LCY) - unit Cost) / Unit Price(LCY))';
                }
            }
        }
        area(factboxes)
        {
            part(Control1100472009; "Item Invoicing FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("No.");
            }
            part(ContractInfoFactbox; "Order Guiide Contract FactBox")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Contract Information';
                SubPageLink = "Item No." = FIELD("No.");
            }
            part(MarginInfofactBox; "Order Guide Margin FactBox")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Margin Information';
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Customer")
            {
                Caption = '&Customer';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;

                    trigger OnAction()
                    begin
                        OrderGuideMgmt.ShowCustomerCard(Rec);
                    end;
                }
                action("Ledger E&ntries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ledger E&ntries';
                    Image = LedgerEntries;

                    trigger OnAction()
                    begin
                        OrderGuideMgmt.ShowCustomerLedgEntries;
                    end;
                }
                separator(Separator1102603050)
                {
                }
                action("Outstanding Orders")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Outstanding Orders';
                    Image = "Order";

                    trigger OnAction()
                    begin
                        OrderGuideMgmt.ShowCustomerOrders;
                    end;
                }
                action("Item Ledger Entries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;

                    trigger OnAction()
                    begin
                        OrderGuideMgmt.ShowCustItemLedgEntries;
                    end;
                }
            }
            group("&Item")
            {
                Caption = '&Item';
                action(Action1102603041)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    RunObject = Page "Item Card";
                    RunPageLink = "No." = FIELD("No."),
                                  "Date Filter" = FIELD("Date Filter"),
                                  "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                  "Location Filter" = FIELD("Location Filter"),
                                  "Drop Shipment Filter" = FIELD("Drop Shipment Filter");
                    ShortCutKey = 'Shift+F7';
                }
                action(Action1102603042)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ledger E&ntries';
                    Image = LedgerEntries;
                    RunObject = Page "Item Ledger Entries";
                    RunPageLink = "Item No." = FIELD("No.");
                    RunPageView = SORTING("Item No.");
                    ShortCutKey = 'Ctrl+F7';
                }
                group("&Item Availability by")
                {
                    Caption = '&Item Availability by';
                    action(Period)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Period';
                        Image = Period;
                        RunObject = Page "Item Availability by Periods";
                        RunPageLink = "No." = FIELD("No."),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                      "Variant Filter" = FIELD("Variant Filter"),
                                      "Bin Filter" = FIELD("Bin Filter");
                    }
                    action(Variant)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Variant';
                        Image = ItemVariant;
                        RunObject = Page "Item Availability by Variant";
                        RunPageLink = "No." = FIELD("No."),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                      "Variant Filter" = FIELD("Variant Filter"),
                                      "Bin Filter" = FIELD("Bin Filter");
                    }
                    action(Location)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Location';
                        Image = Warehouse;
                        RunObject = Page "Item Availability by Location";
                        RunPageLink = "No." = FIELD("No."),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                      "Variant Filter" = FIELD("Variant Filter"),
                                      "Bin Filter" = FIELD("Bin Filter");
                    }
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Clear Sales &Contract")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Clear Sales &Contract';
                    Image = Delete;

                    trigger OnAction()
                    begin
                        // P8000885
                        OrderGuideMgmt.ClearContracts("No.");
                        OrderGuideMgmt.ValidateQty(Rec, OrderUOM, VariantToOrder, QtyToOrder, UnitPrice, ContractNo);
                        OrderGuideMgmt.SetQtyToOrder(Rec, QtyToOrder, VariantToOrder, OrderUOM, DefOrderUOM, UnitPrice, ContractNo, PriceFromGetPriceFnc); // P80072447
                    end;
                }
            }
        }
        area(processing)
        {
            action(AddLines)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Add Lines';
                Image = AddAction;

                trigger OnAction()
                begin
                    // P8000999
                    OrderGuideMgmt.AddOrderLines(GetRangeMin("Location Filter"), TempItemQty); // P80072449
                    // P80072449
                    if TempItemQty.FindSet then
                        repeat
                            CurrPage.MarginInfofactBox.PAGE.ClearMarginRecords(TempItemQty."Item No.");
                        until TempItemQty.Next = 0;
                    // P80072449
                end;
            }
            action(GetPrice)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Get Price';
                Image = Price;

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                    SalesLine: Record "Sales Line";
                    lPriceID: Integer;
                    lPriceFromGetPriceFnc: Boolean;
                begin
                    // P80072447
                    Clear(PriceFromGetPriceFnc);
                    OrderGuideMgmt.ValidateUnitPrice(Rec, SalesLine, QtyToOrder, VariantToOrder, OrderUOM, DefOrderUOM, UnitPrice, ContractNo, SalesPrice);
                    if SalesPrice."Price ID" = 0 then
                        lPriceFromGetPriceFnc := false
                    else
                        lPriceFromGetPriceFnc := true;
                    // P80072447
                    // P80072449
                    OrderGuideMgmt.CalcUnitPriceLCY(UnitPrice, UnitPriceLCY);
                    CurrPage.MarginInfofactBox.PAGE.InsertSalesMargin("No.", "Item Category Code", QtyToOrder, UnitPriceLCY, "Unit Cost",
                                                                      CalcExpectedMarginLCY, CalcExpectedMarginPct);
                    // P80072449
                    // P80072447
                    OrderGuideMgmt.SetQtyToOrder(Rec, QtyToOrder, VariantToOrder, OrderUOM, DefOrderUOM, UnitPrice, ContractNo, lPriceFromGetPriceFnc);
                    gItemNo := "No.";
                    // P80072447
                end;
            }
        }
        area(Promoted)
        {
            actionref(AddLines_Promoted; AddLines)
            {
            }
            group(Category_Customer)
            {
                Caption = 'Customer';

                actionref(CustomerCard_Promoted; Card)
                {
                }
                actionref(CustomerLedgerEtries_Promoted; "Ledger E&ntries")
                {
                }
            }
            group(Category_Item)
            {
                Caption = 'Item';

                actionref(ItemCard_Promoted; Action1102603041)
                {
                }
                actionref(ItemLedgerEtries_Promoted; Action1102603042)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        lSalesContract: Record "Sales Contract";
    begin
        Clear(ContractNo);  // P80072447
        OrderGuideMgmt.GetQtyToOrder(Rec, QtyToOrder, VariantToOrder, OrderUOM, DefOrderUOM, UnitPrice, ContractNo, PriceFromGetPriceFnc); // P8000315A // P80072447
        QtyOrdered := OrderGuideMgmt.GetQtyOrdered(Rec);
        QtyAvailable := OrderGuideMgmt.GetQtyAvailable(Rec);
        OrderGuideMgmt.GetLastTransactionInfo(Rec, LastDocNo, LastDate, LastQty, LastUOM, LastUnitPrice, LastAmount); // P8000348A
        "No.Emphasize" := DisplayBold; // PR3.70
        DescriptionEmphasize := DisplayBold; // PR3.70
        OrderGuideMgmt.CalcUnitPriceLCY(UnitPrice, UnitPriceLCY); // P80072449
        // P80072447
        if (gItemNo = "No.") and (ContractNo <> '') and (gItemNo <> '') then begin
            CurrPage.ContractInfoFactbox.PAGE.ValidateSalesContractNo("No.", SalesPrice."Price Type", ContractNo)
        end else begin
            if (ContractNo = '') and (QtyToOrder = 0) then begin
                CurrPage.ContractInfoFactbox.PAGE.ClearContractFields("No.");
            end;
        end;
        // P80072447
        // P800155629
        if VariantToOrder = '' then
            VariantCodeMandatory := Rec.IsVariantMandatory();
        // P800155629
    end;

    trigger OnClosePage()
    begin
        // P8000999
        if OKPushed then
            OrderGuideMgmt.AddOrderLines(GetRangeMin("Location Filter"), TempItemQty); // P80072449
        // P8000999
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(OrderGuideMgmt.ItemFind(Rec, Which, ShowItemsWithActivity, PricingOptions)); // PR3.70
    end;

    trigger OnInit()
    begin
        ShowItemsWithActivity := true;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(OrderGuideMgmt.ItemNext(Rec, Steps, ShowItemsWithActivity, PricingOptions)); // PR3.70
    end;

    trigger OnOpenPage()
    begin
        OrderGuideMgmt.ItemListInit(Rec);

        SetItemCategoryFilter;

        LocationCode := OrderGuideMgmt.GetFormLocationCode(Rec);

        OrderGuideMgmt.SetStartEndDates(HistoryPeriod, ShowItemsWithActivity); // P8000878

        // P8000999
        if DefaultSort = 0 then
            DefaultSort := DefaultSort::Type;
        SetSort;
        // P8000999

        CurrPage.Caption := OrderGuideMgmt.GetFormCaption; // P80059471
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        // P8000791
        // P8001149
        // CASE CloseAction OF
        //   ACTION::OK : BEGIN
        //     OKPushed := TRUE;
        //     EXIT(TRUE);
        //   END;
        //   ACTION::Cancel, ACTION::Close : BEGIN
        // P8001149
        if AlwaysClose then // P800099
            exit(true);       // P800099
        if not OrderGuideMgmt.QtyToOrderExists() then
            exit(true);
        exit(Confirm(Text000));
        // P8001149
        //   END;
        // END;
        // P8001149
    end;

    var
        ItemCategoryFilter: Code[250];
        LocationCode: Code[10];
        [InDataSet]
        ShowItemsWithActivity: Boolean;
        PricingOptions: Option "None","Special Items","Contract Items";
        OrderGuideMgmt: Codeunit "Sales Order-Order Guide";
        QtyToOrder: Decimal;
        VariantToOrder: Code[10];
        OrderUOM: Code[10];
        DefOrderUOM: Code[10];
        UnitPrice: Decimal;
        QtyOrdered: Decimal;
        QtyAvailable: Decimal;
        OKPushed: Boolean;
        Text000: Label 'You have entered order quantities. Do you want to close the form and discard the order quantities?';
        LabelQtyToOrder: Label 'Quantity to Order';
        LastDocNo: Code[20];
        LastDate: Date;
        LastQty: Decimal;
        LastUOM: Code[10];
        LastUnitPrice: Decimal;
        LastAmount: Decimal;
        [InDataSet]
        "No.Emphasize": Boolean;
        [InDataSet]
        DescriptionEmphasize: Boolean;
        HistoryPeriod: DateFormula;
        AlwaysClose: Boolean;
        DefaultSort: Option ,"No.",Description,Type,Category;
        ContractNo: Code[20];
        SalesPrice: Record "Sales Price";
        gItemNo: Code[20];
        UnitCost: Decimal;
        ExpectedMarginLCY: Decimal;
        ExpectedMarginPct: Decimal;
        SalesContractManagement: Codeunit "Sales Contract Management";
        ContractfactBoxData: Record "Order Guide FactBox Data";
        PriceFromGetPriceFnc: Boolean;
        UnitPriceLCY: Decimal;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        Bounded: Boolean;
        TempItemQty: Record "Item Ledger Entry" temporary;
        VariantCodeMandatory: Boolean;

    local procedure SetItemCategoryFilter()
    begin
        SetFilter("Item Category Code", ItemCategoryFilter);
        ConvertItemCatFilterToItemCatOrderFilter; // P8007749
    end;

    procedure SetDocument(var SalesHeader: Record "Sales Header")
    begin
        OrderGuideMgmt.SetDocument(SalesHeader);
    end;

    procedure CopyItemsToOrder(): Boolean
    begin
        exit(OKPushed);
    end;

    procedure GetCopyInformation(var TempItemQty2: Record "Item Ledger Entry" temporary; var LocationCode: Code[10])
    begin
        OrderGuideMgmt.GetItemsToCopy(TempItemQty2);
        LocationCode := OrderGuideMgmt.GetFormLocationCode(Rec);
    end;

    procedure DisplayBold(): Boolean
    var
        i: Integer;
    begin
        // PR3.70
        if PricingOptions = 0 then
            for i := 1 to 2 do
                if OrderGuideMgmt.IsSpecialItem(Rec, i) then
                    exit(true);
        // PR3.70
    end;

    procedure SetSort()
    begin
        // P8000999
        case DefaultSort of
            DefaultSort::"No.":
                SetCurrentKey("No.");
            DefaultSort::Description:
                SetCurrentKey("Search Description");
            DefaultSort::Type:
                SetCurrentKey("Item Type");
            DefaultSort::Category:
                SetCurrentKey("Item Category Code");
        end;
    end;

    local procedure CalcUnitCostForMargin(): Decimal
    var
        StockkeepingUnit: Record "Stockkeeping Unit";
        Item: Record Item;
    begin
        // P80072449
        if StockkeepingUnit.Get(LocationCode, Rec."No.", VariantToOrder) then
            exit(StockkeepingUnit."Unit Cost")
        else
            if Item.Get(Rec."No.") then
                exit(Item."Unit Cost");
        exit(0);
    end;

    local procedure CalcExpectedMarginLCY(): Decimal
    begin
        // P80072449
        if (QtyToOrder <> 0) and (UnitPriceLCY <> 0) then
            exit((UnitPriceLCY - "Unit Cost") * QtyToOrder);
        exit(0);
    end;

    local procedure CalcExpectedMarginPct(): Decimal
    begin
        // P80072449
        if (QtyToOrder <> 0) and (UnitPriceLCY <> 0) then
            exit(((UnitPriceLCY - "Unit Cost") / UnitPriceLCY) * 100);
        exit(0);
    end;
}

