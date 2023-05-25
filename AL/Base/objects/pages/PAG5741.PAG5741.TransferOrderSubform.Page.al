page 5741 "Transfer Order Subform"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // TOM4219     05-10-2105  Cleanup change line wizard
    // --------------------------------------------------------------------------------
    // 
    // PR3.61
    //   Add fields
    //     Type
    //     Quantity (Alt.)
    //     Qty. to Ship (Alt.)
    //     Qty. Shipped (Alt.)
    //     Qty. to Receive (Alt.)
    //     Qty. Received (Alt.)
    //   Add logic for alternate quantities
    //   Add logic for container tracking
    // 
    // PR3.70.04
    // P8000043A, Myers Nissi, Jack Reynolds, 02 JUN 04
    //   Support for easy lot tracking
    // 
    // PR3.70.06
    // P8000071A, Myers Nissi, Jack Reynolds, 15 JUL 04
    //   Modify to not allow easy lot tracking unless line is for an item
    // 
    // PR3.70.10
    // P8000227A, Myers Nissi, Jack Reynolds, 07 JUL 05
    //   Fix problem specifying lot before line has been inserted
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Fix problem with easy lot tracking
    // 
    // PRW16.00.01
    // P8000778, VerticalSoft, Rick Tweedle, 24 FEB 10
    //         Fixed issue with Transformation Tool
    // 
    // PRW16.00.03
    // P8000817, VerticalSoft, Jack Reynolds, 26 APR 10
    //   Change visible property of fields
    // 
    // PRW16.00.05
    // P8000928, Columbus IT, Jack Reynolds, 06 APR 11
    //   Support for Extra Charges
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001047, Columbus IT, Jack Reynolds, 30 MAR 12
    //   Receiving Labels
    // 
    // P8001101, Columbus IT, Jack Reynolds, 27 SEP 12
    //   Change keyboard shortcut for containers
    // 
    // PRW18.00
    // P8001352, Columbus IT, Jack Reynolds, 30 OCT 14
    //   Rename OnAfterGetCurrRecord function to OnAfterGetCurrRecord2
    // 
    // P8001353, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add AccessByPermission functionality
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW19.00.01
    // P8006916, To-Increase, Jack Reynolds, 31 AUG 16
    //   FOOD-TOM Separation
    // 
    // P8007827, To-Increase, Dayakar Battini, 11 OCT 16
    //   Change UOM for Substituted Item
    // 
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW110.0
    // P8008464, To-Increase, Dayakar Battini, 28 FEB 17
    //   Product N138 replaced with Distribution Planning
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW120-.2
    // P800150458, To-Increase, Jack Reynolds, 11 AUG 22
    //   Transfer Orders for Batch Plannng demand
    //   Minor cleanup to Batch Planning objcts

    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Transfer Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Type; Rec.Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the number of the item that will be transferred.';

                    trigger OnValidate()
                    begin
                        UpdateForm(true);
                    end;
                }
                field(Allergens; AllergenManagement.AllergenCodeForRecord(DATABASE::"Transfer Line", Type, "Item No."))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                    Style = StrongAccent;
                    StyleExpr = TRUE;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        // P8006959
                        AllergenManagement.AllergenDrilldownForRecord(DATABASE::"Transfer Line", Type, "Item No.");
                    end;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field("Planning Flexibility"; Rec."Planning Flexibility")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies whether the supply represented by this line is considered by the planning system when calculating action messages.';
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies a description of the entry.';
                }
                field("Transfer-from Bin Code"; Rec."Transfer-from Bin Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code for the bin that the items are transferred from.';
                    Visible = false;
                }
                field("Transfer-To Bin Code"; Rec."Transfer-To Bin Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code for the bin that the items are transferred to.';
                    Visible = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = Location;
                    BlankZero = true;
                    ToolTip = 'Specifies the quantity of the item that will be processed as the document stipulates.';
                }
                field("Reserved Quantity Inbnd."; Rec."Reserved Quantity Inbnd.")
                {
                    ApplicationArea = Reservation;
                    BlankZero = true;
                    ToolTip = 'Specifies the quantity of the item reserved at the transfer-to location.';
                }
                field("Reserved Quantity Shipped"; Rec."Reserved Quantity Shipped")
                {
                    ApplicationArea = Reservation;
                    BlankZero = true;
                    ToolTip = 'Specifies how many units on the shipped transfer order are reserved.';
                }
                field("Reserved Quantity Outbnd."; Rec."Reserved Quantity Outbnd.")
                {
                    ApplicationArea = Reservation;
                    BlankZero = true;
                    ToolTip = 'Specifies the quantity of the item reserved at the transfer-from location.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Label Unit of Measure Code"; Rec."Label Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the name of the item or resource''s unit of measure, such as piece or hour.';
                    Visible = false;
                }
                field("Quantity (Alt.)"; Rec."Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("ShortcutECCharge[1]"; ShortcutECCharge[1])
                {
                    AccessByPermission = TableData "Extra Charge" = R;
                    ApplicationArea = FOODBasic;
                    AutoFormatType = 1;
                    CaptionClass = '37002660,1,1';
                    ShowCaption = false;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutECCharge(1, ShortcutECCharge[1]); // PR3.70.01
                    end;
                }
                field("ShortcutECCharge[2]"; ShortcutECCharge[2])
                {
                    AccessByPermission = TableData "Extra Charge" = R;
                    ApplicationArea = FOODBasic;
                    AutoFormatType = 1;
                    CaptionClass = '37002660,1,2';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutECCharge(2, ShortcutECCharge[2]); // PR3.70.01
                    end;
                }
                field("ShortcutECCharge[3]"; ShortcutECCharge[3])
                {
                    AccessByPermission = TableData "Extra Charge" = R;
                    ApplicationArea = FOODBasic;
                    AutoFormatType = 1;
                    CaptionClass = '37002660,1,3';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutECCharge(3, ShortcutECCharge[3]); // PR3.70.01
                    end;
                }
                field("ShortcutECCharge[4]"; ShortcutECCharge[4])
                {
                    AccessByPermission = TableData "Extra Charge" = R;
                    ApplicationArea = FOODBasic;
                    AutoFormatType = 1;
                    CaptionClass = '37002660,1,4';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutECCharge(4, ShortcutECCharge[4]); // PR3.70.01
                    end;
                }
                field("ShortcutECCharge[5]"; ShortcutECCharge[5])
                {
                    AccessByPermission = TableData "Extra Charge" = R;
                    ApplicationArea = FOODBasic;
                    AutoFormatType = 1;
                    CaptionClass = '37002660,1,5';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutECCharge(5, ShortcutECCharge[5]); // PR3.70.01
                    end;
                }
                field("Extra Charge"; "Extra Charge")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        // PR3.70.01
                        CurrPage.SaveRecord;
                        Commit;
                        Rec.ShowExtraCharges;
                        ShowShortcutECCharge(ShortcutECCharge);
                        CurrPage.Update(true);
                        // PR3.70.01
                    end;
                }
                field(ExtraChargeUnitCost; ExtraChargeUnitCost)
                {
                    AccessByPermission = TableData "Extra Charge" = R;
                    ApplicationArea = FOODBasic;
                    AutoFormatType = 2;
                    Caption = 'Extra Charge Unit Cost';
                    Visible = false;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Lot No.Editable";

                    trigger OnAssistEdit()
                    begin
                        // P8000043A
                        if Type <> Type::Item then // P8000071A
                            exit;                    // P8000071A
                        CurrPage.SaveRecord; // P8000282A
                        Commit;              // P8000282A
                        EasyLotTracking.SetTransferLine(Rec, 0);
                        if EasyLotTracking.AssistEdit("Lot No.") then
                            UpdateLotTracking(true, 0);
                        CurrPage.SaveRecord;
                    end;

                    trigger OnValidate()
                    begin
                        LotNoOnAfterValidate;
                    end;
                }
                field("Qty. to Ship"; Rec."Qty. to Ship")
                {
                    ApplicationArea = Location;
                    BlankZero = true;
                    ToolTip = 'Specifies the quantity of items that remain to be shipped.';
                }
                field("Qty. to Ship (Alt.)"; Rec."Qty. to Ship (Alt.)")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        // PR3.61
                        CurrPage.SaveRecord;
                        AltQtyMgmt.ShowTransAltQtyLines(Rec, 0);
                        CurrPage.Update;
                        // PR3.61
                    end;

                    trigger OnValidate()
                    begin
                        QtytoShipAltOnAfterValidate;
                    end;
                }
                field("Quantity Shipped"; Rec."Quantity Shipped")
                {
                    ApplicationArea = Location;
                    BlankZero = true;
                    ToolTip = 'Specifies how many units of the item on the line have been posted as shipped.';

                    trigger OnDrillDown()
                    var
                        TransShptLine: Record "Transfer Shipment Line";
                    begin
                        TestField("Document No.");
                        TestField("Item No.");
                        TransShptLine.SetCurrentKey("Transfer Order No.", "Item No.", "Shipment Date");
                        TransShptLine.SetRange("Transfer Order No.", "Document No.");
                        TransShptLine.SetRange("Line No.", "Line No.");
                        PAGE.RunModal(0, TransShptLine);
                    end;
                }
                field("Qty. Shipped (Alt.)"; Rec."Qty. Shipped (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. to Receive"; Rec."Qty. to Receive")
                {
                    ApplicationArea = Location;
                    BlankZero = true;
                    Editable = NOT "Direct Transfer";
                    ToolTip = 'Specifies the quantity of items that remains to be received.';
                }
                field("Qty. to Receive (Alt.)"; Rec."Qty. to Receive (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = NOT "Direct Transfer";

                    trigger OnDrillDown()
                    begin
                        // PR3.61
                        if "Direct Transfer" then // P80053245
                            exit;                   // P80053245
                        CurrPage.SaveRecord;
                        AltQtyMgmt.ShowTransAltQtyLines(Rec, 1);
                        CurrPage.Update;
                        // PR3.61
                    end;

                    trigger OnValidate()
                    begin
                        QtytoReceiveAltOnAfterValidate;
                    end;
                }
                field("Quantity Received"; Rec."Quantity Received")
                {
                    ApplicationArea = Location;
                    BlankZero = true;
                    ToolTip = 'Specifies how many units of the item on the line have been posted as received.';

                    trigger OnDrillDown()
                    var
                        TransRcptLine: Record "Transfer Receipt Line";
                    begin
                        TestField("Document No.");
                        TestField("Item No.");
                        TransRcptLine.SetCurrentKey("Transfer Order No.", "Item No.", "Receipt Date");
                        TransRcptLine.SetRange("Transfer Order No.", "Document No.");
                        TransRcptLine.SetRange("Line No.", "Line No.");
                        PAGE.RunModal(0, TransRcptLine);
                    end;
                }
                field("Qty. Received (Alt.)"; Rec."Qty. Received (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies when items on the document are shipped or were shipped. A shipment date is usually calculated from a requested delivery date plus lead time.';
                }
                field("Receipt Date"; Rec."Receipt Date")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the date that you expect the transfer-to location to receive the shipment.';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the code for the shipping agent who is transporting the items.';
                    Visible = false;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the code for the service, such as a one-day delivery, that is offered by the shipping agent.';
                    Visible = false;
                }
                field("Shipping Time"; Rec."Shipping Time")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies how long it takes from when the items are shipped from the warehouse to when they are delivered.';
                    Visible = false;
                }
                // P800150458
                field("Qty. on Prod. Order (Base)"; Rec."Qty. on Prod. Order (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Outbound Whse. Handling Time"; Rec."Outbound Whse. Handling Time")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies a date formula for the time it takes to get items ready to ship from this location. The time element is used in the calculation of the delivery date as follows: Shipment Date + Outbound Warehouse Handling Time = Planned Shipment Date + Shipping Time = Planned Delivery Date.';
                    Visible = false;
                }
                field("Inbound Whse. Handling Time"; Rec."Inbound Whse. Handling Time")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the time it takes to make items part of available inventory, after the items have been posted as received.';
                    Visible = false;
                }
                field("Appl.-to Item Entry"; Rec."Appl.-to Item Entry")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the number of the item ledger entry that the document or journal line is applied to.';
                    Visible = false;
                }
                field(GetDelivertyTrip; GetDelivertyTrip)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Delivery Trip';
                    Editable = true;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupDelivertyTrip;
                    end;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    ApplicationArea = Location;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    ApplicationArea = Location;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    ApplicationArea = Location;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    ApplicationArea = Location;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    ApplicationArea = Location;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    ApplicationArea = Location;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("Custom Transit Number"; Rec."Custom Transit Number")
                {
                    ApplicationArea = Location, BasicMX;
                    ToolTip = 'Specifies a unique transit number as five groups of digits separated by two spaces. The number identifies the transport, the year of transport, the customs office, and other required information.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(Reserve)
                {
                    ApplicationArea = Reservation;
                    Caption = '&Reserve';
                    Image = Reserve;
                    ToolTip = 'Reserve the quantity that is required on the document line that you opened this window for.';

                    trigger OnAction()
                    begin
                        Rec.Find();
                        Rec.ShowReservation();
                    end;
                }
                action(ReserveFromInventory)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reserve from &Inventory';
                    Image = LineReserve;
                    ToolTip = 'Reserve items for the selected line from inventory.';

                    trigger OnAction()
                    begin
                        ReserveSelectedLines();
                    end;
                }
                action("Change Transfer Order Line")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Change Transfer Order Line';
                    Description = 'N138F0000';

                    trigger OnAction()
                    var
                        ChangeSalesLineWizard: Page "N138 ChangeSource Line Wizard";
                    begin
                        //ChangeQty;
                        ChangeSalesLineWizard.Init("Item No.", Quantity, 0, Rec, 1); // TOM4219, P8007827
                        ChangeSalesLineWizard.RunModal;
                    end;
                }
            }
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                group("Item Availability by")
                {
                    Caption = 'Item Availability by';
                    Image = ItemAvailability;
                    action("Event")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Event';
                        Image = "Event";
                        ToolTip = 'View how the actual and the projected available balance of an item will develop over time according to supply and demand events.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromTransLine(Rec, ItemAvailFormsMgt.ByEvent());
                        end;
                    }
                    action(Period)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Period';
                        Image = Period;
                        ToolTip = 'Show the projected quantity of the item over time according to time periods, such as day, week, or month.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromTransLine(Rec, ItemAvailFormsMgt.ByPeriod());
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
                            ItemAvailFormsMgt.ShowItemAvailFromTransLine(Rec, ItemAvailFormsMgt.ByVariant());
                        end;
                    }
                    action(Location)
                    {
                        AccessByPermission = TableData Location = R;
                        ApplicationArea = Location;
                        Caption = 'Location';
                        Image = Warehouse;
                        ToolTip = 'View the actual and projected quantity of the item per location.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromTransLine(Rec, ItemAvailFormsMgt.ByLocation());
                        end;
                    }
                    action(Lot)
                    {
                        ApplicationArea = ItemTracking;
                        Caption = 'Lot';
                        Image = LotInfo;
                        // RunObject = Page "Item Availability by Lot No.";
                        // RunPageLink = "No." = field("Item No."),
                        //     "Variant Filter" = field("Variant Code");
                        ToolTip = 'View the current and projected quantity of the item in each lot.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromTransLine(Rec, ItemAvailFormsMgt.ByLot);
                        end;
                    }
                    action("BOM Level")
                    {
                        ApplicationArea = Location;
                        Caption = 'BOM Level';
                        Image = BOMLevel;
                        ToolTip = 'View availability figures for items on bills of materials that show how many units of a parent item you can make based on the availability of child items.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromTransLine(Rec, ItemAvailFormsMgt.ByBOM());
                        end;
                    }
                }
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        ShowDimensions();
                    end;
                }
                action("E&xtra Charges")
                {
                    AccessByPermission = TableData "Extra Charge" = R;
                    ApplicationArea = FOODBasic;
                    Caption = 'E&xtra Charges';
                    Image = Costs;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        // P8000928
                        ShowExtraCharges;
                    end;
                }
                group("Item &Tracking Lines")
                {
                    Caption = 'Item &Tracking Lines';
                    Image = AllLines;
                    action(Shipment)
                    {
                        ApplicationArea = ItemTracking;
                        Caption = 'Shipment';
                        Image = Shipment;
                        ShortCutKey = 'Ctrl+Alt+I';   
                        ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.';

                        trigger OnAction()
                        begin
                            OpenItemTrackingLines("Transfer Direction"::Outbound);
                        end;
                    }
                    action(Receipt)
                    {
                        ApplicationArea = ItemTracking;
                        Caption = 'Receipt';
                        Image = Receipt;
                        ShortCutKey = 'Shift+Ctrl+R';
                        ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.';

                        trigger OnAction()
                        begin
                            OpenItemTrackingLinesWithReclass("Transfer Direction"::Inbound);
                        end;
                    }
                }
                action("Con&tainers")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Con&tainers';
                    ShortCutKey = 'Shift+Ctrl+T';

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #5740. Unsupported part was commented. Please check it.
                        /*CurrPage.TransferLines.PAGE.*/
                        ContainerTracking; // PR3.70.02

                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ShowShortcutDimCode(ShortcutDimCode);
        ShowShortcutECCharge(ShortcutECCharge); // P8000928
        OnAfterGetCurrRecord2; // P8001352
    end;

    trigger OnDeleteRecord(): Boolean
    var
        TransferLineReserve: Codeunit "Transfer Line-Reserve";
    begin
        Commit();
        if not TransferLineReserve.DeleteLineConfirm(Rec) then
            exit(false);
        TransferLineReserve.DeleteLine(Rec);
    end;

    trigger OnInit()
    begin
        "Lot No.Editable" := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(ShortcutDimCode);
        OnAfterGetCurrRecord2; // P8001352
    end;

    trigger OnOpenPage()
    begin
        SetDimensionsVisibility();
    end;

    var
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        EasyLotTracking: Codeunit "Easy Lot Tracking";
        [InDataSet]
        "Lot No.Editable": Boolean;
        ExtraChargeManagement: Codeunit "Extra Charge Management";
        AllergenManagement: Codeunit "Allergen Management";
        ShortcutECCharge: array[5] of Decimal;

    protected var
        ShortcutDimCode: array[8] of Code[20];
        DimVisible1: Boolean;
        DimVisible2: Boolean;
        DimVisible3: Boolean;
        DimVisible4: Boolean;
        DimVisible5: Boolean;
        DimVisible6: Boolean;
        DimVisible7: Boolean;
        DimVisible8: Boolean;

    procedure UpdateForm(SetSaveRecord: Boolean)
    begin
        CurrPage.Update(SetSaveRecord);
    end;

    procedure ContainerTracking()
    begin
        ContainerSpecification; // PR3.61
    end;

    procedure SetLotFields(Property: Code[10])
    var
        ProcessFns: Codeunit "Process 800 Functions";
        P800Globals: Codeunit "Process 800 System Globals";
    begin
        // P8000043A
        case Property of
            'EDITABLE':
                /*  // P8000778
                CurrForm."Lot No.".EDITABLE(                                                                            // P8000071A
                  ProcessFns.TrackingInstalled AND ("Lot No." <> P800Globals.MultipleLotCode) AND (Type = Type::Item)); // P8000071A
                */  // P8000778
                    // P8000778
                "Lot No.Editable" :=
                  ProcessFns.TrackingInstalled and ("Lot No." <> P800Globals.MultipleLotCode) and (Type = Type::Item);
        // P8000778
        end;

    end;

    local procedure LotNoOnAfterValidate()
    begin
        // P8000227A Begin
        if "Line No." = 0 then begin
            CurrPage.SaveRecord;
            UpdateLotTracking(false, 0);
        end;
        // P8000227A End
    end;

    local procedure QtytoShipAltOnAfterValidate()
    begin
        // PR3.61
        CurrPage.SaveRecord;
        AltQtyMgmt.ValidateTransAltQtyLine(Rec, 0);
        CurrPage.Update;
        // PR3.61
    end;

    local procedure QtytoReceiveAltOnAfterValidate()
    begin
        // PR3.61
        CurrPage.SaveRecord;
        AltQtyMgmt.ValidateTransAltQtyLine(Rec, 1);
        CurrPage.Update;
        // PR3.61
    end;

    local procedure OnAfterGetCurrRecord2()
    begin
        // P8001352 - Renamed
        xRec := Rec;
        SetLotFields('EDITABLE'); // PR3.61
    end;

    local procedure GetDelivertyTrip(): Code[20]
    var
        WarehouseRequest: Record "Warehouse Request";
        ProcessFns: Codeunit "Process 800 Functions";
        DeliveryTripMgt: Codeunit "N138 Delivery Trip Mgt.";
    begin
        //N138F0000.sn
        if ProcessFns.DistPlanningInstalled then  // P8008464
            if DeliveryTripMgt.GetWhseReqTransfer(Rec, WarehouseRequest) then
                exit(WarehouseRequest."Delivery Trip");
        //N138F0000.en
    end;

    local procedure LookupDelivertyTrip(): Code[20]
    var
        WarehouseRequest: Record "Warehouse Request";
        ProcessFns: Codeunit "Process 800 Functions";
        DeliveryTripMgt: Codeunit "N138 Delivery Trip Mgt.";
    begin
        //N138F0000.sn
        if ProcessFns.DistPlanningInstalled then  // P8008464
            DeliveryTripMgt.LookupWhseReqTransfer(Rec);
        //N138F0000.en
    end;

    local procedure ReserveSelectedLines()
    var
        TransLine: Record "Transfer Line";
    begin
        CurrPage.SetSelectionFilter(TransLine);
        ReserveFromInventory(TransLine);
    end;

    local procedure SetDimensionsVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimVisible1 := false;
        DimVisible2 := false;
        DimVisible3 := false;
        DimVisible4 := false;
        DimVisible5 := false;
        DimVisible6 := false;
        DimVisible7 := false;
        DimVisible8 := false;

        DimMgt.UseShortcutDims(
          DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);

        Clear(DimMgt);
    end;
}

