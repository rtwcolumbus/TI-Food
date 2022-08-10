page 7336 "Whse. Shipment Subform"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // TOM4225     01-10-2015, Rename "Resolve shorts" to "Resolve Shorts"
    // --------------------------------------------------------------------------------
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Support for running for order shipping; alernate quantity and easy lot tracking
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW15.00.03
    // P8000629A, VerticalSoft, Jack Reynolds, 21 SEP 08
    //   Update alternate qty. to ship when entering qty. to ship
    // 
    // PRW16.00.02
    // P8000778, VerticalSoft, Rick Tweedle, 25 FEB 10
    //   Code changed to allow automatic transformation for 2009
    // P8000778, VerticalSoft, Rick Tweedle, 04 MAR 10
    //   Upgraded using transformation tool
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW18.00
    // P8001352, Columbus IT, Jack Reynolds, 30 OCT 14
    //   Rename OnAfterGetCurrRecord function to OnAfterGetCurrRecord2
    // 
    // PRW19.00.01
    // P8006787, To-Increase, Jack Reynolds, 21 APR 16
    //   Fix issues with settlement and catch weight items
    // 
    // P8007536, To-Increase, Dayakar Battini, 12 AUG 16
    //   Item Tracking quantity update when Over shipment.
    // 
    // P8006916, To-Increase, Jack Reynolds, 31 AUG 16
    //   FOOD-TOM Separation
    // 
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW111.00.01
    // P80061239, To Increase, Jack Reynolds, 31 JUL 18
    //   Run Bin Status from warehouse document pages
    // 
    // PRW111.00.02
    // P80070336, To Increase, Jack Reynolds, 12 FEB 19
    //   Fix issue with Alternate Quantity to Handle
    // 
    // P80073378, To Increase, Jack Reynolds, 24 MAR 19
    //   Support for easy lot tracking on warehouse shipments
    // 
    // PRW111.00.03
    // P80081811, To-Increase, Gangabhushan, 30 OCT 19
    //   Catchweight item while doing transfer system allowing for Qty to ship Qty.
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
    SourceTable = "Warehouse Shipment Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Source Document"; "Source Document")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the type of document that the line relates to.';
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the source document that the entry originates from.';
                }
                field("Source Line No."; "Source Line No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the line number of the source document that the entry originates from.';
                    Visible = false;
                }
                field("Destination Type"; "Destination Type")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the type of destination associated with the warehouse shipment line.';
                    Visible = false;
                }
                field("Destination No."; "Destination No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the customer, vendor, or location to which the items should be shipped.';
                    Visible = false;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the item that should be shipped.';
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
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the description of the item in the line.';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = Location;
                    Editable = false;
                    ToolTip = 'Specifies the code of the location from which the items on the line are being shipped.';
                    Visible = false;
                }
                field("Zone Code"; "Zone Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code of the zone where the bin on this shipment line is located.';
                    Visible = false;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the bin where the items are picked or put away.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        BinCodeOnAfterValidate;
                    end;
                }
                field("Lot No."; LotNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot No.';
                    Editable = LotNoEditable;

                    trigger OnAssistEdit()
                    begin
                        if AssistEditLotNo(LotNo) then // P8000282A  // P8007536
                            CurrPage.Update;              // P8007536
                    end;

                    trigger OnValidate()
                    begin
                        ValidateLotNo(LotNo); // P80073378
                    end;
                }
                field("Shelf No."; "Shelf No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the shelf number of the item for informational use.';
                    Visible = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity that should be shipped.';

                    trigger OnValidate()
                    begin
                        QuantityOnAfterValidate();
                    end;
                }
                field("Qty. (Base)"; "Qty. (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity that should be shipped, in the base unit of measure.';
                    Visible = false;
                }
                field("Qty. to Ship"; "Qty. to Ship")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity of items that remain to be shipped.';

                    trigger OnValidate()
                    begin
                        // P8000629A
                        if P800Functions.AltQtyInstalled() then
                            AltQtyMgmt.WhseShptLineGetData(Rec, QtyToShipAlt);
                        // P8000629A
                        SetLotQuantity(LotNo); // P80073378
                    end;
                }
                field("Qty. To Ship (Alt.)"; QtyToShipAlt)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    CaptionClass = StrSubstNo('37002080,0,1,%1', "Item No.");
                    DecimalPlaces = 0 : 5;
                    Editable = QtyToShipAltEditable;

                    trigger OnDrillDown()
                    var
                        OrderShippingReceiving: Codeunit "Order Shipping-Receiving";
                        FoodManualSubscriptions: Codeunit "Food Manual Subscriptions";
                    begin
                        // P8000282A
                        CurrPage.SaveRecord;
                        BindSubscription(OrderShippingReceiving); // P80070336
                        // P80081811
                        FoodManualSubscriptions.SetShpt;
                        BindSubscription(FoodManualSubscriptions);
                        // P80081811
                        AltQtyMgmt.WhseShptLineDrillQty(Rec);
                        UnbindSubscription(FoodManualSubscriptions); // P80081811
                        CurrPage.Update;
                        // P8000282A
                    end;

                    trigger OnValidate()
                    var
                        OrderShippingReceiving: Codeunit "Order Shipping-Receiving";
                    begin
                        BindSubscription(OrderShippingReceiving); // P80070336
                        TestField("Qty. to Ship"); // P80081811
                        AltQtyMgmt.WhseShptLineValidateQty(Rec, QtyToShipAlt, true); // P8000282A, P8006787
                    end;
                }
                field("Qty. Shipped"; "Qty. Shipped")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity of the item on the line that is posted as shipped.';
                }
                field("Qty. to Ship (Base)"; "Qty. to Ship (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity, in base units of measure, that will be shipped when the warehouse shipment is posted.';
                    Visible = false;
                }
                field("Qty. Shipped (Base)"; "Qty. Shipped (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity that is posted as shipped expressed in the base unit of measure.';
                    Visible = false;
                }
                field("Qty. Outstanding"; "Qty. Outstanding")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity that still needs to be handled.';
                    Visible = true;
                }
                field("Qty. Outstanding (Base)"; "Qty. Outstanding (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity that still needs to be handled, expressed in the base unit of measure.';
                    Visible = false;
                }
                field("Pick Qty."; "Pick Qty.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity in pick instructions assigned to be picked for the warehouse shipment line.';
                    Visible = false;
                }
                field("Pick Qty. (Base)"; "Pick Qty. (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity, in the base unit of measure, in pick instructions, that is assigned to be picked for the warehouse shipment line.';
                    Visible = false;
                }
                field("Qty. Picked"; "Qty. Picked")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies how many of the total shipment quantity have been registered as picked.';
                    Visible = false;
                }
                field("Qty. Picked (Base)"; "Qty. Picked (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies how many of the total shipment quantity in the base unit of measure have been registered as picked.';
                    Visible = false;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the date when the related warehouse activity, such as a pick, must be completed to ensure items can be shipped by the shipment date.';
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Qty. per Unit of Measure"; "Qty. per Unit of Measure")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of base units of measure that are in the unit of measure specified for the item on the line.';
                }
                field(QtyCrossDockedUOM; QtyCrossDockedUOM)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Qty. on Cross-Dock Bin';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the sum of all the outbound lines requesting the item within the look-ahead period, minus the quantity of the items that have already been placed in the cross-dock area.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        CrossDockMgt.ShowBinContentsCrossDocked("Item No.", "Variant Code", "Unit of Measure Code", "Location Code", true);
                    end;
                }
                field(QtyCrossDockedUOMBase; QtyCrossDockedUOMBase)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Qty. on Cross-Dock Bin (Base)';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the sum of all the outbound lines requesting the item within the look-ahead period, minus the quantity of the items that have already been placed in the cross-dock area.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        CrossDockMgt.ShowBinContentsCrossDocked("Item No.", "Variant Code", "Unit of Measure Code", "Location Code", true);
                    end;
                }
                field(QtyCrossDockedAllUOMBase; QtyCrossDockedAllUOMBase)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Qty. on Cross-Dock Bin (Base all UOM)';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies the sum of all the outbound lines requesting the item within the look-ahead period, minus the quantity of the items that have already been placed in the cross-dock area.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        CrossDockMgt.ShowBinContentsCrossDocked("Item No.", "Variant Code", "Unit of Measure Code", "Location Code", false);
                    end;
                }
                field(Control3; "Assemble to Order")
                {
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies if the warehouse shipment line is for items that are assembled to a sales order before it is shipped.';
                    Visible = false;
                }
                field(Short; Short)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Short Action"; "Short Action")
                {
                    ApplicationArea = FOODBasic;
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
                        ShowSourceLine;
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
                        ShowBinContents;
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
                action(ItemTrackingLines)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    ShortCutKey = 'Shift+Ctrl+I'; // bug 427462
                    ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.';

                    trigger OnAction()
                    var
                        OrderShippingReceiving: Codeunit "Order Shipping-Receiving";
                    begin
                        OpenItemTrackingLines();
                    end;
                }
                action("Assemble to Order")
                {
                    AccessByPermission = TableData "BOM Component" = R;
                    ApplicationArea = Assembly;
                    Caption = 'Assemble to Order';
                    Image = AssemblyBOM;
                    ToolTip = 'View the linked assembly order if the shipment was for an assemble-to-order sale.';

                    trigger OnAction()
                    var
                        ATOLink: Record "Assemble-to-Order Link";
                        ATOSalesLine: Record "Sales Line";
                    begin
                        TestField("Assemble to Order", true);
                        TestField("Source Type", DATABASE::"Sales Line");
                        ATOSalesLine.Get("Source Subtype", "Source No.", "Source Line No.");
                        ATOLink.ShowAsm(ATOSalesLine);
                    end;
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(ResolveShorts)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Resolve Shorts';
                    Ellipsis = true;
                    Image = OpenJournal;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        ShortsMgt: Codeunit "N138 Shorts Mgt.";
                    begin
                        ShortsMgt.ShowSourceDocWizard(Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CrossDockMgt.CalcCrossDockedItems("Item No.", "Variant Code", "Unit of Measure Code", "Location Code",
          QtyCrossDockedUOMBase,
          QtyCrossDockedAllUOMBase);
        QtyCrossDockedUOM := 0;
        if "Qty. per Unit of Measure" <> 0 then
            QtyCrossDockedUOM := Round(QtyCrossDockedUOMBase / "Qty. per Unit of Measure", UOMMgt.QtyRndPrecision);

        // P8000282A
        if P800Functions.AltQtyInstalled() then
            AltQtyMgmt.WhseShptLineGetData(Rec, QtyToShipAlt);
        // P8000282A

        LotNo := GetLotNo(); // P8000282A
        OnAfterGetCurrRecord2; // P8001352
    end;

    trigger OnInit()
    begin
        QtyToShipAltEditable := true;
        LotNoEditable := true; // P80073378
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        OnAfterGetCurrRecord2; // P8001352
    end;

    var
        WMSMgt: Codeunit "WMS Management";
        CrossDockMgt: Codeunit "Whse. Cross-Dock Management";
        UOMMgt: Codeunit "Unit of Measure Management";
        QtyCrossDockedUOM: Decimal;
        QtyCrossDockedAllUOMBase: Decimal;
        QtyCrossDockedUOMBase: Decimal;
        Posted: Boolean;
        RunFromOrderShip: Boolean;
        P800Functions: Codeunit "Process 800 Functions";
        P800Globals: Codeunit "Process 800 System Globals";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        AllergenManagement: Codeunit "Allergen Management";
        QtyToShipAlt: Decimal;
        LotNo: Code[50];
        [InDataSet]
        LotNoEditable: Boolean;
        [InDataSet]
        QtyToShipAltEditable: Boolean;

    local procedure ShowSourceLine()
    begin
        WMSMgt.ShowSourceDocLine("Source Type", "Source Subtype", "Source No.", "Source Line No.", 0);
    end;

    procedure PostShipmentYesNo()
    var
        WhseShptLine: Record "Warehouse Shipment Line";
        WhsePostShptYesNo: Codeunit "Whse.-Post Shipment (Yes/No)";
    begin
        WhseShptLine.Copy(Rec);
        WhsePostShptYesNo.RunFromOrderShipping(RunFromOrderShip); // P8000282A
        WhsePostShptYesNo.Run(WhseShptLine); // P887748
        Posted := WhsePostShptYesNo.ShipmentPosted; // P8000282A
        Reset;
        SetCurrentKey("No.", "Sorting Sequence No.");
        CurrPage.Update(false);
    end;

    procedure PostShipmentPrintYesNo()
    var
        WhseShptLine: Record "Warehouse Shipment Line";
        WhsePostShptPrintShipInvoice: Codeunit "Whse.-Post Shipment + Print";
    begin
        WhseShptLine.Copy(Rec);
        WhsePostShptPrintShipInvoice.RunFromOrderShipping(RunFromOrderShip); // P8000282A
        WhsePostShptPrintShipInvoice.Run(WhseShptLine); // P887748
        Posted := WhsePostShptPrintShipInvoice.ShipmentPosted; // P8000282A
        Reset;
        SetCurrentKey("No.", "Sorting Sequence No.");
        CurrPage.Update(false);
    end;

    procedure AutofillQtyToHandle()
    var
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        WhseShptLine.Copy(Rec);
        WhseShptLine.SetRange("No.", "No.");
        AutofillQtyToHandle(WhseShptLine);
    end;

    procedure DeleteQtyToHandle()
    var
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        WhseShptLine.Copy(Rec);
        WhseShptLine.SetRange("No.", "No.");
        DeleteQtyToHandle(WhseShptLine);
    end;

    local procedure ShowBinContents()
    var
        BinContent: Record "Bin Content";
    begin
        BinContent.ShowBinContents("Location Code", "Item No.", "Variant Code", "Bin Code");
    end;

    procedure PickCreate()
    var
        WhseShptHeader: Record "Warehouse Shipment Header";
        WhseShptLine: Record "Warehouse Shipment Line";
        ReleaseWhseShipment: Codeunit "Whse.-Shipment Release";
    begin
        OnBeforePickCreate(Rec);

        WhseShptLine.Copy(Rec);
        WhseShptHeader.Get(WhseShptLine."No.");
        if WhseShptHeader.Status = WhseShptHeader.Status::Open then
            ReleaseWhseShipment.Release(WhseShptHeader);
        CreatePickDoc(WhseShptLine, WhseShptHeader);

        OnAfterPickCreate(WhseShptLine);
    end;

    protected procedure BinCodeOnAfterValidate()
    begin
        CurrPage.Update();
    end;

    protected procedure QuantityOnAfterValidate()
    begin
        CurrPage.Update();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPickCreate(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePickCreate(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    begin
    end;

    procedure ShipmentPosted(): Boolean
    begin
        // P8000282A
        exit(Posted);
    end;

    procedure RunFromOrderShipping(OrderShip: Boolean)
    begin
        // P8000282A
        RunFromOrderShip := OrderShip;
    end;

    local procedure OnAfterGetCurrRecord2()
    begin
        // P8001352 - Renamed
        xRec := Rec;
        LotNoEditable := (LotNo <> P800Globals.MultipleLotCode) and P800Functions.TrackingInstalled; // P80073378
        // P8000282A
        if P800Functions.AltQtyInstalled() then begin
            //CurrForm."Qty. To Ship (Alt.)".EDITABLE(TrackAlternateUnits());  // P8000778
            QtyToShipAltEditable := CatchAlternateUnits();  // P8000778
            AltQtyMgmt.WhseShptLineGetData(Rec, QtyToShipAlt);
        end;
        // P8000282A
    end;
}

