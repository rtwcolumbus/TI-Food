page 37002173 "Purchase Order Guide"
{
    // PR4.00.02
    // P8000314A, VerticalSoft, Jack Reynolds, 28 MAR 06
    //   Modeled after sales order guide
    // 
    // PR4.00.04
    // P8000348A, VerticalSoft, Jack Reynolds, 28 JUN 06
    //   Fix issue with Last Order Amount and Last Cost (for different UOM's)
    // 
    // PR4.00.05
    // P8000420A, VerticalSoft, Jack Reynolds, 29 NOV 06
    //   Fix problems updating subforms when no records are displayed
    // 
    // P8000449B, VerticalSoft, Jack Reynolds, 19 FEB 07
    //   Don't display blocked items
    // 
    // PR4.00.06
    // P8000475A, VerticalSoft, Jack Reynolds, 29 MAY 07
    //   Modify OK button to not have Default property set
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.02
    // P8000791, VerticalSoft, MMAS, 18 MAR 10
    //   Page had been changed after transformation
    //   Date Filter functionality had been chaneged (DateFilter variable).
    // 
    // PRW16.00.04
    // P8000879, VerticalSoft, Ron Davidson, 18 NOV 10
    //  Replaced Date Filter with History Period a DateFormula Data Type
    // 
    // PRW16.00.06
    // P8000999, Columbus IT, Jack Reynolds, 15 DEC 11
    //   Modify for non-modal operation with purchaseorder
    // 
    // P8001004, Columbus IT, Jack Reynolds, 15 DEC 11
    //   Fixes to FactBoxes
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
    // PRW17.10
    // P8001230, Columbus IT, Jack Reynolds, 18 OCT 13
    //   Support for approved vendors
    // 
    // PRW18.00.01
    // P8001386, Columbus IT, Jack Reynolds, 27 MAY 15
    //   Renamed NAV Food client addins
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Upgrade signal control for JavaScript
    // 
    // PRW111.00.02
    // P80064337, To-Increase, Jack Reynolds, 06 SEP 18
    //   Missing or misspelled caption
    // 
    // PRW119.0
    // P800133109, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 19.0 - Qty. Rounding Precision
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 28 APR 22
    //   Removing support for Signal Functions codeunit

    Caption = 'Purchase Order Guide';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    PromotedActionCategories = 'New,Process,Report,Vendor,Item';
    SaveValues = true;
    SourceTable = Item;
    SourceTableView = WHERE(Blocked = CONST(false));

    layout
    {
        area(content)
        {
            group(Control37002005)
            {
                ShowCaption = false;
                field("History Guide"; ShowItemsWithActivity)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'History Guide';

                    trigger OnValidate()
                    begin
                        OrderGuideMgmt.SetStartEndDates(HistoryPeriod, ShowItemsWithActivity); // P8000879 Added
                        CurrPage.Update(false); // P8001004
                    end;
                }
                field("<HistoryPeriod>"; HistoryPeriod)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'History Period';
                    Enabled = ShowItemsWithActivity;

                    trigger OnValidate()
                    begin
                        // P8000879 Removed
                        // P8000791
                        //IF (DateFilter <> '') THEN
                        //  SETFILTER("Date Filter", DateFilter)
                        //ELSE
                        //  SETRANGE("Date Filter");
                        // P8000879 Removed

                        OrderGuideMgmt.SetStartEndDates(HistoryPeriod, ShowItemsWithActivity); // P8000879 Added
                        CurrPage.Update(false); // P8001004
                    end;
                }
                field(DefaultSort; DefaultSort)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Default Sort';
                    OptionCaption = ',No.,Description,Type,Category';

                    trigger OnValidate()
                    begin
                        // P8000999
                        SetSort;
                        CurrPage.Update(false);
                    end;
                }
                field(DaysView; DaysView)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Days View';
                    MinValue = 0;

                    trigger OnValidate()
                    begin
                        // P8001004
                        EndDate := BegDate + DaysView;
                        if "No." = '' then // P8000420A
                            exit;            // P8000420A
                        CurrPage.AvailSubform.PAGE.SetDates(BegDate, EndDate); // P8001004
                        CurrPage.UsageSubform.PAGE.SetDates(BegDate, EndDate); // P8001004

                        CurrPage.Update(false); // P8000791
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
                        // P8001004
                        CurrPage.AvailSubform.PAGE.SetCurrentLocation(LocationCode);
                        CurrPage.UsageSubform.PAGE.SetCurrentLocation(LocationCode);
                        CurrPage.PlanningSubform.PAGE.SetCurrentLocation(LocationCode);
                        CurrPage.Update(false);
                        // P8001004
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
                        CurrPage.Update(false); // P8001004
                    end;
                }
            }
            repeater(Control37002008)
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
                    Visible = false;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(LastDocNo; LastDocNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Last Document No.';
                    Editable = false;
                    Visible = false;
                }
                field(LastDate; LastDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Last Order Date';
                    Editable = false;
                }
                field(LastQty; LastQty)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Last Order Qty';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    Visible = false;
                }
                field(LastUOM; LastUOM)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Last Unit of Measure';
                    Editable = false;
                    Visible = false;
                }
                field(LastUnitCost; LastUnitCost)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Last Unit Cost';
                    DecimalPlaces = 2 : 5;
                    Editable = false;
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
                    Caption = 'Qty. Received From Vendor';
                    DecimalPlaces = 0 : 5;
                    Editable = false;

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
                        OrderGuideMgmt.ValidateUOM(Rec, OrderUOM, VariantToOrder, QtyToOrder, UnitCost);
                        OrderGuideMgmt.SetQtyToOrder(Rec, QtyToOrder, VariantToOrder, OrderUOM, DefOrderUOM, UnitCost);
                    end;
                }
                field(VariantToOrder; VariantToOrder)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Variant To Order';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(OrderGuideMgmt.LookupVariant(Rec, Text));
                    end;

                    trigger OnValidate()
                    begin
                        OrderGuideMgmt.ValidateVariant(Rec, OrderUOM, VariantToOrder, QtyToOrder, UnitCost);
                        OrderGuideMgmt.SetQtyToOrder(Rec, QtyToOrder, VariantToOrder, OrderUOM, DefOrderUOM, UnitCost);
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
                    begin
                        // P800133109
                        QtyToOrder := UOMMgt.RoundAndValidateQty(Rec."No.", OrderUOM, QtyToOrder, LabelQtyToOrder);
                        UOMMgt.CalcBaseQty(Rec."No.", OrderUOM, QtyToOrder);
                        // P800133109
                        OrderGuideMgmt.ValidateQty(Rec, OrderUOM, VariantToOrder, QtyToOrder, UnitCost);
                        OrderGuideMgmt.SetQtyToOrder(Rec, QtyToOrder, VariantToOrder, OrderUOM, DefOrderUOM, UnitCost);
                        if ShowItemsWithActivity and (QtyToOrder = 0) then // P8001004
                            CurrPage.Update(false);                          // P8001004
                    end;
                }
                field(UnitCost; UnitCost)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Unit Cost';
                    DecimalPlaces = 2 : 5;

                    trigger OnValidate()
                    begin
                        OrderGuideMgmt.SetQtyToOrder(Rec, QtyToOrder, VariantToOrder, OrderUOM, DefOrderUOM, UnitCost);
                    end;
                }
            }
        }
        area(factboxes)
        {
            part(AvailSubform; "Req. Wksh. Avail. Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Availability';
                SubPageLink = "Item No." = FIELD("No.");
            }
            part(UsageSubform; "Req. Wksh. Usage Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Usage';
                SubPageLink = "Item No." = FIELD("No.");
            }
            part(VendorSubform; "Req. Wksh. Vendor Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Vendor';
                SubPageLink = "Item No." = FIELD("No.");
            }
            part(PlanningSubform; "Req. Wksh. Planning Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Planning';
                SubPageLink = "Item No." = FIELD("No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Vendor")
            {
                Caption = '&Vendor';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    begin
                        OrderGuideMgmt.ShowVendorCard(Rec);
                    end;
                }
                action("Ledger E&ntries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ledger E&ntries';
                    Image = LedgerEntries;
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    begin
                        OrderGuideMgmt.ShowVendorLedgEntries;
                    end;
                }
                separator(Separator1102603051)
                {
                }
                action("Outstanding Orders")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Outstanding Orders';
                    Image = "Order";

                    trigger OnAction()
                    begin
                        OrderGuideMgmt.ShowVendorOrders;
                    end;
                }
                action("Item Ledger Entries")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;

                    trigger OnAction()
                    begin
                        OrderGuideMgmt.ShowVendorItemLedgEntries;
                    end;
                }
            }
            group("&Item")
            {
                Caption = '&Item';
                action(Action1102603054)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    Promoted = true;
                    PromotedCategory = Category5;
                    RunObject = Page "Item Card";
                    RunPageLink = "No." = FIELD("No."),
                                  "Date Filter" = FIELD("Date Filter"),
                                  "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                  "Location Filter" = FIELD("Location Filter"),
                                  "Drop Shipment Filter" = FIELD("Drop Shipment Filter");
                    ShortCutKey = 'Shift+F7';
                }
                action(Action1102603055)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ledger E&ntries';
                    Image = LedgerEntries;
                    Promoted = true;
                    PromotedCategory = Category5;
                    RunObject = Page "Item Ledger Entries";
                    RunPageLink = "Item No." = FIELD("No.");
                    RunPageView = SORTING("Item No.");
                    ShortCutKey = 'Ctrl+F7';
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
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    // P8000999
                    OrderGuideMgmt.AddOrderLines(GetRangeMin("Location Filter"));
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        OrderGuideMgmt.GetQtyToOrder(Rec, QtyToOrder, VariantToOrder, OrderUOM, DefOrderUOM, UnitCost);
        QtyOrdered := OrderGuideMgmt.GetQtyOrdered(Rec);
        OrderGuideMgmt.GetLastTransactionInfo(Rec, LastDocNo, LastDate, LastQty, LastUOM, LastUnitCost, LastAmount); // P8000348A
    end;

    trigger OnClosePage()
    begin
        // P8000999
        if OKPushed then
            OrderGuideMgmt.AddOrderLines(GetRangeMin("Location Filter"));
        // P8000999
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        //ItemCategoryFilter := GETFILTER("Item Category Code"); // P8007749

        exit(OrderGuideMgmt.ItemFind(Rec, Which, ShowItemsWithActivity));
    end;

    trigger OnInit()
    begin
        ShowItemsWithActivity := true;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(OrderGuideMgmt.ItemNext(Rec, Steps, ShowItemsWithActivity));
    end;

    trigger OnOpenPage()
    begin
        OrderGuideMgmt.ItemListInit(Rec);

        SetItemCategoryFilter;

        LocationCode := OrderGuideMgmt.GetFormLocationCode(Rec);

        if DaysView = 0 then
            DaysView := 14;
        BegDate := WorkDate;
        EndDate := BegDate + DaysView;
        OrderGuideMgmt.SetStartEndDates(HistoryPeriod, ShowItemsWithActivity); // P8000879 Added

        // P8000999
        if DefaultSort = 0 then
            DefaultSort := DefaultSort::Type;
        SetSort;
        // P8000999

        // P8001004
        CurrPage.AvailSubform.PAGE.SetOrderGuideCodeunit(OrderGuideMgmt);
        CurrPage.PlanningSubform.PAGE.SetOrderGuideCodeunit(OrderGuideMgmt);
        CurrPage.UsageSubform.PAGE.SetOrderGuideCodeunit(OrderGuideMgmt);
        CurrPage.AvailSubform.PAGE.SetDates(BegDate, EndDate);
        CurrPage.UsageSubform.PAGE.SetDates(BegDate, EndDate);
        // P8001004

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
        PurchaseHeader: Record "Purchase Header";
        ItemCategoryFilter: Code[250];
        LocationCode: Code[10];
        [InDataSet]
        ShowItemsWithActivity: Boolean;
        OrderGuideMgmt: Codeunit "Purchase Order-Order Guide";
        QtyToOrder: Decimal;
        VariantToOrder: Code[10];
        OrderUOM: Code[10];
        DefOrderUOM: Code[10];
        UnitCost: Decimal;
        QtyOrdered: Decimal;
        LastDocNo: Code[20];
        LastDate: Date;
        LastQty: Decimal;
        LastUOM: Code[10];
        LastUnitCost: Decimal;
        LastAmount: Decimal;
        OKPushed: Boolean;
        Text000: Label 'You have entered order quantities. Do you want to close the form and discard the order quantities?';
        LabelQtyToOrder: Label 'Quantity to Order';
        BegDate: Date;
        EndDate: Date;
        DaysView: Integer;
        HistoryPeriod: DateFormula;
        AlwaysClose: Boolean;
        DefaultSort: Option ,"No.",Description,Type,Category;

    local procedure SetItemCategoryFilter()
    begin
        SetFilter("Item Category Code", ItemCategoryFilter);
        ConvertItemCatFilterToItemCatOrderFilter; // P8007749
    end;

    local procedure GetCaption(): Text[250]
    begin
        exit(OrderGuideMgmt.GetFormCaption);
    end;

    procedure SetDocument(var PurchHeader: Record "Purchase Header")
    begin
        PurchaseHeader := PurchHeader;
        OrderGuideMgmt.SetDocument(PurchHeader);
        // P8001004
        CurrPage.AvailSubform.PAGE.SetCurrentLocation(PurchaseHeader."Location Code");
        CurrPage.UsageSubform.PAGE.SetCurrentLocation(PurchaseHeader."Location Code");
        CurrPage.VendorSubform.PAGE.SetCurrentVendor(PurchaseHeader."Buy-from Vendor No.");
        CurrPage.PlanningSubform.PAGE.SetCurrentLocation(PurchaseHeader."Location Code");
        // P8001004
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

    [Obsolete('Removing support for Signal Functions codeunit', 'FOOD-21')]
    procedure SetSignalFns(var SignalCU: Codeunit "Process 800 Signal Functions")
    begin
    end;

    [Obsolete('Removing support for Signal Functions codeunit', 'FOOD-21')]
    procedure ProcessEvents()
    begin
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
}

