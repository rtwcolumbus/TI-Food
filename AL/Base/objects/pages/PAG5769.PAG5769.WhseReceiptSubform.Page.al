page 5769 "Whse. Receipt Subform"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 22-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Support for running for order receiving; alernate quantity and easy lot tracking
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW15.00.03
    // P8000629A, VerticalSoft, Jack Reynolds, 21 SEP 08
    //   Don't allow edits to lot number if multiple lots have been specified
    //   Update alternate qty. to receive when entering qty. to receive
    // 
    // PRW16.00.02
    // P8000756, VerticalSoft, Jack Reynolds, 12 JAN 10
    //   Incorporate P800 mods into NAV 2009 SP1
    // 
    // P8000777, VerticalSoft, Don Bresee, 25 FEB 10
    //   Changed EDITABLE so it could be handled by the form transformation tool
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001106, Columbus IT, Don Bresee, 22 OCT 12
    //   Add "Supplier Lot No." field for easy lot tracking
    // 
    // PRW18.00
    // P8001352, Columbus IT, Jack Reynolds, 30 OCT 14
    //   Rename OnAfterGetCurrRecord function to OnAfterGetCurrRecord2
    // 
    // PRW19.00.01
    // P8007108, To-Increase, Jack Reynolds, 31 MAY 16
    //   Allow entry of Creation Date and Coutry of Origin for lots
    // 
    // P8006916, To-Increase, Dayakar Battini, 16 JUN 16
    //   FOOD-TOM Separation delete Transsmart objects
    // 
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW111.00.01
    // P80061239, To Increase, Jack Reynolds, 31 JUL 18
    //   Run Bin Status from warehouse document pages
    // 
    // PRW111.00.02
    // P80070336, To Increase, Jack Reynolds, 12 FEB 19
    //   Fix issue with Alternate Quantity to Handle
    // 
    // PRW111.00.03
    // P80081811, To-Increase, Gangabhushan, 30 OCT 19
    //   Catchweight item while doing transfer system allowing for Qty to ship Qty.
    // 
    // P800108979, To Increase, Gangabhuhan, 19 OCT 20
    //   CS00130169 | Purchase Order Receiving - lot no must be specified
    //
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    InsertAllowed = false;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Warehouse Receipt Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Source Document"; Rec."Source Document")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the type of document that the line relates to.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the source document that the entry originates from.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the item that is expected to be received.';
                }
                field(Allergens; AllergenManagement.AllergenCodeForRecord(0, 0, "Item No."))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                    Style = StrongAccent;
                    StyleExpr = TRUE;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        // P8006959
                        AllergenManagement.AllergenDrilldownForRecord(0, 0, "Item No.");
                    end;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the description of the item in the line.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the code of the location where the items should be received.';
                    Visible = false;
                }
                field("Zone Code"; Rec."Zone Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the zone in which the items are being received.';
                    Visible = false;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the bin where the items are picked or put away.';
                    Visible = true;

                    trigger OnValidate()
                    begin
                        BinCodeOnAfterValidate();
                    end;
                }
                field("Lot No."; LotNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot No.';
                    Editable = "Lot No.Editable";

                    trigger OnAssistEdit()
                    begin
                        if AssistLotNoEdit(LotNo) then // P8000282A
                            CurrPage.Update;             // P8000282A
                    end;

                    trigger OnValidate()
                    begin
                        ValidateLotNo(LotNo); // P8000282A
                    end;
                }
                field("Supplier Lot No."; SupplierLotNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Supplier Lot No.';
                    Editable = LotInfoEditable;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateSupplierLotNo(SupplierLotNo); // P8001106
                    end;
                }
                field("Creation Date"; CreationDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Creation Date';
                    Editable = LotInfoEditable;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateCreationDate(CreationDate); // P8007108
                    end;
                }
                field(CountryOfOrigin; CountryOfOrigin)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Country/Region of Origin Code';
                    Editable = LotInfoEditable;
                    TableRelation = "Country/Region";
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateCountryOfOrigin(CountryOfOrigin); // P8007108
                    end;
                }
                field("Cross-Dock Zone Code"; Rec."Cross-Dock Zone Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the zone code that will be used for the quantity of items to be cross-docked.';
                    Visible = false;
                }
                field("Cross-Dock Bin Code"; Rec."Cross-Dock Bin Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the bin code that will be used for the quantity of items to be cross-docked.';
                    Visible = false;
                }
                field("Shelf No."; Rec."Shelf No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the shelf number of the item for information use.';
                    Visible = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity that should be received.';
                }
                field("Qty. (Base)"; Rec."Qty. (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity to be received, in the base unit of measure.';
                    Visible = false;
                }
                field("Qty. to Receive"; Rec."Qty. to Receive")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity of items that remains to be received.';

                    trigger OnValidate()
                    begin
                        QtytoReceiveOnAfterValidate();
                    end;
                }
                field("Qty. to Receive (Alt.)"; QtyToReceiveAlt)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = StrSubstNo('37002080,0,3,%1', "Item No.");
                    DecimalPlaces = 0 : 5;
                    Editable = "Qty. to Receive (Alt.)Editable";

                    trigger OnDrillDown()
                    var
                        OrderShippingReceiving: Codeunit "Order Shipping-Receiving";
                        FoodManualSubscriptions: Codeunit "Food Manual Subscriptions";
                    begin
                        // P8000282A
                        CurrPage.SaveRecord;
                        BindSubscription(OrderShippingReceiving); // P80070336
                        // P80081811
                        FoodManualSubscriptions.SetReceipt;
                        BindSubscription(FoodManualSubscriptions);
                        // P80081811
                        AltQtyMgmt.WhseRcptLineDrillQty(Rec);
                        UnbindSubscription(FoodManualSubscriptions); // P80081811
                        CurrPage.Update;
                        // P8000282A
                    end;

                    trigger OnValidate()
                    var
                        OrderShippingReceiving: Codeunit "Order Shipping-Receiving";
                    begin
                        BindSubscription(OrderShippingReceiving); // P80070336
                        TestField("Qty. to Receive"); // P80081811
                        AltQtyMgmt.WhseRcptLineValidateQty(Rec, QtyToReceiveAlt); // P8000282A
                    end;
                }
                field("Qty. to Cross-Dock"; Rec."Qty. to Cross-Dock")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the suggested quantity to put into the cross-dock bin on the put-away document when the receipt is posted.';
                    Visible = true;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        ShowCrossDockOpp(WhseCrossDockOpp2);
                        CurrPage.Update();
                    end;
                }
                field("Qty. Received"; Rec."Qty. Received")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity for this line that has been posted as received.';
                    Visible = true;
                }
                field("Qty. to Receive (Base)"; Rec."Qty. to Receive (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the Qty. to Receive in the base unit of measure.';
                    Visible = false;
                }
                field("Qty. to Cross-Dock (Base)"; Rec."Qty. to Cross-Dock (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the suggested base quantity to put into the cross-dock bin on the put-away document hen the receipt is posted.';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        ShowCrossDockOpp(WhseCrossDockOpp2);
                        CurrPage.Update();
                    end;
                }
                field("Qty. Received (Base)"; Rec."Qty. Received (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity received, in the base unit of measure.';
                    Visible = false;
                }
                field("Qty. Outstanding"; Rec."Qty. Outstanding")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity that still needs to be handled.';
                    Visible = true;
                }
                field("Qty. Outstanding (Base)"; Rec."Qty. Outstanding (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity that still needs to be handled, in the base unit of measure.';
                    Visible = false;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the date on which you expect to receive the items on the line.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of base units of measure, that are in the unit of measure specified for the item on the line.';
                }
                field("Over-Receipt Quantity"; Rec."Over-Receipt Quantity")
                {
                    ApplicationArea = Warehouse;
                    Visible = OverReceiptAllowed;
                    ToolTip = 'Specifies over-receipt quantity.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Over-Receipt Code"; Rec."Over-Receipt Code")
                {
                    ApplicationArea = Warehouse;
                    Visible = OverReceiptAllowed;
                    ToolTip = 'Specifies over-receip code.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action("Source &Document Line")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Source &Document Line';
                    Image = SourceDocLine;
                    ToolTip = 'View the line on a released source document that the warehouse activity is for. ';

                    trigger OnAction()
                    begin
                        ShowSourceLine();
                    end;
                }
                action("&Bin Contents List")
                {
                    AccessByPermission = TableData "Bin Content" = R;
                    ApplicationArea = Warehouse;
                    Caption = '&Bin Contents List';
                    Image = BinContent;
                    ToolTip = 'View the contents of each bin and the parameters that define how items are routed through the bin.';

                    trigger OnAction()
                    begin
                        ShowBinContents();
                    end;
                }
                action(BinStatus)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Bin Status';
                    Image = Bins;

                    trigger OnAction()
                    begin
                        ShowBinStatus; // P80061239
                    end;
                }
                group("Item Availability by")
                {
                    Caption = 'Item Availability by';
                    Image = ItemAvailability;
                    action("Event")
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Event';
                        Image = "Event";
                        ToolTip = 'View how the actual and the projected available balance of an item will develop over time according to supply and demand events.';

                        trigger OnAction()
                        begin
                            ItemAvailability(ItemAvailFormsMgt.ByEvent());
                        end;
                    }
                    action(Period)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Period';
                        Image = Period;
                        ToolTip = 'View the projected quantity of the item over time according to time periods, such as day, week, or month.';

                        trigger OnAction()
                        begin
                            ItemAvailability(ItemAvailFormsMgt.ByPeriod());
                        end;
                    }
                    action(Variant)
                    {
                        ApplicationArea = Planning;
                        Caption = 'Variant';
                        Image = ItemVariant;
                        ToolTip = 'View or edit the item''s variants. Instead of setting up each color of an item as a separate item, you can set up the various colors as variants of the item.';

                        trigger OnAction()
                        begin
                            ItemAvailability(ItemAvailFormsMgt.ByVariant());
                        end;
                    }
                    action(Location)
                    {
                        AccessByPermission = TableData Location = R;
                        ApplicationArea = Warehouse;
                        Caption = 'Location';
                        Image = Warehouse;
                        ToolTip = 'View the actual and projected quantity of the item per location.';

                        trigger OnAction()
                        begin
                            ItemAvailability(ItemAvailFormsMgt.ByLocation());
                        end;
                    }
                    action(Lot)
                    {
                        ApplicationArea = ItemTracking;
                        Caption = 'Lot';
                        Image = LotInfo;
                        RunObject = Page "Item Availability by Lot No.";
                        RunPageLink = "No." = field("Item No."),
                            "Location Filter" = field("Location Code"),
                            "Variant Filter" = field("Variant Code");
                        ToolTip = 'View the current and projected quantity of the item in each lot.';
                    }
                }
                action(ItemTrackingLines)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    ShortCutKey = 'Ctrl+Alt+I';
                    ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.';

                    trigger OnAction()
                    var
                        OrderShippingReceiving: Codeunit "Order Shipping-Receiving";
                    begin
                        BindSubscription(OrderShippingReceiving); // P80070336
                        Rec.OpenItemTrackingLines();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        // P8000282A
        if P800Functions.AltQtyInstalled() then
            AltQtyMgmt.WhseRcptLineGetData(Rec, QtyToReceiveAlt);
        // P8000282A

        LotNo := GetLotNo(); // P8000282A
        GetLotInfo(SupplierLotNo, CreationDate, CountryOfOrigin); // P8007108
        OnAfterGetCurrRecord2; // P8001352
    end;

    trigger OnInit()
    begin
        "Lot No.Editable" := true;
        "Qty. to Receive (Alt.)Editable" := true;
        LotInfoEditable := true; // P8001106, P8007108
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        OnAfterGetCurrRecord2; // P8001352
    end;

    var
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        Text001: Label 'Cross-docking has been disabled for item %1 or location %2.';
        Posted: Boolean;
        P800Functions: Codeunit "Process 800 Functions";
        P800Globals: Codeunit "Process 800 System Globals";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        AllergenManagement: Codeunit "Allergen Management";
        QtyToReceiveAlt: Decimal;
        LotNo: Code[50];
        [InDataSet]
        "Qty. to Receive (Alt.)Editable": Boolean;
        [InDataSet]
        "Lot No.Editable": Boolean;
        SupplierLotNo: Code[50];
        CreationDate: Date;
        CountryOfOrigin: Code[10];
        [InDataSet]
        LotInfoEditable: Boolean;

    protected var
        WhseCrossDockOpp2: Record "Whse. Cross-Dock Opportunity";
        OverReceiptAllowed: Boolean;

    trigger OnOpenPage()
    begin
        SetOverReceiptControlsVisibility();
    end;

    local procedure ShowSourceLine()
    var
        WMSMgt: Codeunit "WMS Management";
    begin
        WMSMgt.ShowSourceDocLine(
          Rec."Source Type", Rec."Source Subtype", Rec."Source No.", Rec."Source Line No.", 0);
    end;

    local procedure ShowBinContents()
    var
        BinContent: Record "Bin Content";
    begin
        BinContent.ShowBinContents(Rec."Location Code", Rec."Item No.", Rec."Variant Code", Rec."Bin Code");
    end;

    local procedure ItemAvailability(AvailabilityType: Option Date,Variant,Location,Bin,"Event",BOM)
    begin
        ItemAvailFormsMgt.ShowItemAvailFromWhseRcptLine(Rec, AvailabilityType);
    end;

    procedure WhsePostRcptYesNo()
    var
        WhseRcptLine: Record "Warehouse Receipt Line";
        WhsePostReceiptYesNo: Codeunit "Whse.-Post Receipt (Yes/No)";
    begin
        WhseRcptLine.Copy(Rec);
        WhsePostReceiptYesNo.Run(WhseRcptLine); // P8007748
        Posted := WhsePostReceiptYesNo.ReceiptPosted; // P8000282A
        Rec.Reset();
        Rec.SetCurrentKey("No.", "Sorting Sequence No.");
        CurrPage.Update(false);
    end;

    procedure WhsePostRcptPrint()
    var
        WhseRcptLine: Record "Warehouse Receipt Line";
        WhsePostReceiptPrint: Codeunit "Whse.-Post Receipt + Print";
    begin
        WhseRcptLine.Copy(Rec);
        WhsePostReceiptPrint.Run(WhseRcptLine); // P8007748
        Posted := WhsePostReceiptPrint.ReceiptPosted; // P8000282A
        Rec.Reset();
        Rec.SetCurrentKey("No.", "Sorting Sequence No.");
        CurrPage.Update(false);
    end;

    procedure WhsePostRcptPrintPostedRcpt()
    var
        WhseRcptLine: Record "Warehouse Receipt Line";
        WhsePostReceiptPrintPostedRcpt: Codeunit "Whse.-Post Receipt + Pr. Pos.";
    begin
        WhseRcptLine.Copy(Rec);
        WhsePostReceiptPrintPostedRcpt.Run(WhseRcptLine); // P8007748
        Posted := WhsePostReceiptPrintPostedRcpt.ReceiptPosted; // P8000576
        Rec.Reset();
        CurrPage.Update(false);
    end;

    procedure AutofillQtyToReceive()
    var
        WhseRcptLine: Record "Warehouse Receipt Line";
    begin
        WhseRcptLine.Copy(Rec);
        WhseRcptLine.SetRange("No.", Rec."No.");
        Rec.AutofillQtyToReceive(WhseRcptLine);
    end;

    procedure DeleteQtyToReceive()
    var
        WhseRcptLine: Record "Warehouse Receipt Line";
    begin
        WhseRcptLine.Copy(Rec);
        WhseRcptLine.SetRange("No.", Rec."No.");
        Rec.DeleteQtyToReceive(WhseRcptLine);
    end;

    protected procedure ShowCrossDockOpp(var CrossDockOpp: Record "Whse. Cross-Dock Opportunity" temporary)
    var
        CrossDockMgt: Codeunit "Whse. Cross-Dock Management";
        UseCrossDock: Boolean;
    begin
        CrossDockMgt.GetUseCrossDock(UseCrossDock, Rec."Location Code", Rec."Item No.");
        if not UseCrossDock then
            Error(Text001, Rec."Item No.", Rec."Location Code");
        CrossDockMgt.ShowCrossDock(CrossDockOpp, '', Rec."No.", Rec."Line No.", Rec."Location Code", Rec."Item No.", Rec."Variant Code");
    end;

    protected procedure BinCodeOnAfterValidate()
    begin
        CurrPage.Update();
    end;

    protected procedure QtytoReceiveOnAfterValidate()
    begin
        CurrPage.SaveRecord();
        // P8000629A
        if P800Functions.AltQtyInstalled() then
            AltQtyMgmt.WhseRcptLineGetData(Rec, QtyToReceiveAlt);
        // P8000629A
        ValidateLotNo(LotNo); // P800108979
    end;

    procedure ReceiptPosted(): Boolean
    begin
        // P8000282A
        exit(Posted);
    end;

    local procedure OnAfterGetCurrRecord2()
    begin
        // P8001352 - Renamed
        xRec := Rec;
        // P8000282A
        if P800Functions.AltQtyInstalled() then begin
            // CurrForm."Qty. to Receive (Alt.)".EDITABLE(TrackAlternateUnits()); // P8000777
            "Qty. to Receive (Alt.)Editable" := TrackAlternateUnits();  // P8000777
            AltQtyMgmt.WhseRcptLineGetData(Rec, QtyToReceiveAlt);
        end;
        // P8000282A
        // P8000629A
        if P800Functions.TrackingInstalled then
            // CurrForm."Lot No.".EDITABLE(LotNo <> P800Globals.MultipleLotCode); // P8000777
            "Lot No.Editable" := LotNo <> P800Globals.MultipleLotCode;  // P8000777
        LotInfoEditable := "Lot No.Editable" and ("Source Type" = DATABASE::"Purchase Line"); // P8001106, P8007108
        // P8000629A
    end;

    local procedure SetOverReceiptControlsVisibility()
    var
        OverReceiptMgt: Codeunit "Over-Receipt Mgt.";
    begin
        OverReceiptAllowed := OverReceiptMgt.IsOverReceiptAllowed();
    end;
}

