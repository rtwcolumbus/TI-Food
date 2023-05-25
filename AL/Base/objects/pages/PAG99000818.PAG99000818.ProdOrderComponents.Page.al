page 99000818 "Prod. Order Components"
{
    // PR2.00.03
    //   Add controls for Step Code
    // 
    // PR3.60
    //   Add fields/logic for alternate quantities
    // 
    // PR3.70.04
    // P8000043A, Myers Nissi, Jack Reynolds, 01 JUN 04
    //   Support for easy lot tracking
    // 
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Add menu item for lot preferences
    // 
    // PR3.70.09
    // P8000194A, Myers Nissi, Jack Reynolds, 24 FEB 05
    //   Fix easy lot tracking problem to save record before creating tracking lines
    // 
    // PR3.70.10
    // P8000227A, Myers Nissi, Jack Reynolds, 07 JUL 05
    //   Fix problem specifying lot before line has been inserted
    // 
    // PRW16.00.02
    // P8000761, VerticalSoft, MMAS, 04 FEB 10
    //   Code in the SetLotFields() method changed to be correctly transformed into 2009
    // 
    // PRW16.00.03
    // P8000817, VerticalSoft, Jack Reynolds, 26 APR 10
    //   Change visible property of fields
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Add Pre-Process functionality
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    AutoSplitKey = true;
    Caption = 'Prod. Order Components';
    DataCaptionExpression = Caption();
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Prod. Order Component";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the item that is a component in the production order component list.';

                    trigger OnValidate()
                    var
                        Item: Record Item;
                    begin
                        ItemNoOnAfterValidate();
                        if "Variant Code" = '' then
                            VariantCodeMandatory := Item.IsVariantMandatory(true, "Item No.");
                    end;
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
                    ShowMandatory = VariantCodeMandatory;

                    trigger OnValidate()
                    var
                        Item: Record "Item";
                    begin
                        if "Variant Code" = '' then
                            VariantCodeMandatory := Item.IsVariantMandatory(true, "Item No.");
                    end;
                }
                field("Step Code"; Rec."Step Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Due Date-Time"; Rec."Due Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the due date and the due time, which are combined in a format called "due date-time".';
                    Visible = false;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the date when the produced item must be available. The date is copied from the header of the production order.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a description of the item on the line.';
                }
                field("Scrap %"; Rec."Scrap %")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the percentage of the item that you expect to be scrapped in the production process.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ScrapPercentOnAfterValidate();
                    end;
                }
                field("Calculation Formula"; Rec."Calculation Formula")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies how to calculate the Quantity field.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        CalculationFormulaOnAfterValidate();
                    end;
                }
                field(Length; Length)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the length of one item unit when measured in the specified unit of measure.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        LengthOnAfterValidate();
                    end;
                }
                field(Width; Width)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the width of one item unit when measured in the specified unit of measure.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        WidthOnAfterValidate();
                    end;
                }
                field(Weight; Weight)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the weight of one item unit when measured in the specified unit of measure.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        WeightOnAfterValidate();
                    end;
                }
                field(Depth; Depth)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the depth of one item unit when measured in the specified unit of measure.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        DepthOnAfterValidate();
                    end;
                }
                field("Quantity per"; Rec."Quantity per")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies how many units of the component are required to produce the parent item.';

                    trigger OnValidate()
                    begin
                        QuantityperOnAfterValidate();
                    end;
                }
                field("Reserved Quantity"; Rec."Reserved Quantity")
                {
                    ApplicationArea = Reservation;
                    ToolTip = 'Specifies how many units of this item have been reserved.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        ShowReservationEntries(true);
                        CurrPage.Update(false);
                    end;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';

                    trigger OnValidate()
                    begin
                        UnitofMeasureCodeOnAfterValidate();
                    end;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Lot No.Editable";

                    trigger OnAssistEdit()
                    begin
                        // P8000043A
                        CurrPage.SaveRecord; // P8000194A
                        Commit;              // P8000194A
                        EasyLotTracking.SetProdOrderComp(Rec);
                        if EasyLotTracking.AssistEdit("Lot No.") then
                            UpdateLotTracking(true);
                        CurrPage.SaveRecord
                    end;

                    trigger OnValidate()
                    begin
                        LotNoOnAfterValidate;
                    end;
                }
                field("Flushing Method"; Rec."Flushing Method")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies how consumption of the item (component) is calculated and handled in production processes. Manual: Enter and post consumption in the consumption journal manually. Forward: Automatically posts consumption according to the production order component lines when the first operation starts. Backward: Automatically calculates and posts consumption according to the production order component lines when the production order is finished. Pick + Forward / Pick + Backward: Variations with warehousing.';
                }
                field("Quantity (Alt.)"; Rec."Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Expected Quantity"; Rec."Expected Quantity")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the quantity of the component expected to be consumed during the production of the quantity on this line.';
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the difference between the finished and planned quantities, or zero if the finished quantity is greater than the remaining quantity.';
                }
                field("Expected Qty. (Alt.)"; Rec."Expected Qty. (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pre-Process Type Code"; Rec."Pre-Process Type Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pre-Process Lead Time (Days)"; Rec."Pre-Process Lead Time (Days)")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
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
                    ApplicationArea = Dimensions;
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
                    ApplicationArea = Dimensions;
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
                    ApplicationArea = Dimensions;
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
                    ApplicationArea = Dimensions;
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
                    ApplicationArea = Dimensions;
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
                    ApplicationArea = Dimensions;
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
                field("Routing Link Code"; Rec."Routing Link Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the routing link code when you calculate the production order.';
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the location where the component is stored. Copies the location code from the corresponding field on the production order line.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        LocationCodeOnAfterValidate();
                    end;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the bin in which the component is to be placed before it is consumed.';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Unit Cost (Prod. Units)';
                    ToolTip = 'Specifies the cost of one unit of the item or resource on the line.';
                    Visible = false;
                }
                field("Unit Cost (Costing Units)"; Rec."Unit Cost (Costing Units)")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Unit Cost';
                }
                field("Cost Amount"; Rec."Cost Amount")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the total cost on the line by multiplying the unit cost by the quantity.';
                    Visible = false;
                }
                field(Position; Position)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the position of the component on the bill of material.';
                    Visible = false;
                }
                field("Position 2"; Rec."Position 2")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the components position in the BOM. It is copied from the production BOM when you calculate the production order.';
                    Visible = false;
                }
                field("Position 3"; Rec."Position 3")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the third reference number for the component position on a bill of material, such as the alternate position number of a component on a print card.';
                    Visible = false;
                }
                field("Lead-Time Offset"; Rec."Lead-Time Offset")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the lead-time offset for the component line. It is copied from the corresponding field in the production BOM when you calculate the production order.';
                    Visible = false;
                }
                field("Qty. Picked"; Rec."Qty. Picked")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the quantity of the item you have picked for the component line.';
                    Visible = false;
                }
                field("Qty. Picked (Base)"; Rec."Qty. Picked (Base)")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the quantity of the item you have picked for the component line.';
                    Visible = false;
                }
                field("Substitution Available"; Rec."Substitution Available")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies if an item substitute is available for the production order component.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
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
                        ApplicationArea = Manufacturing;
                        Caption = 'Event';
                        Image = "Event";
                        ToolTip = 'View how the actual and the projected available balance of an item will develop over time according to supply and demand events.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromProdOrderComp(Rec, ItemAvailFormsMgt.ByEvent());
                        end;
                    }
                    action(Period)
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Period';
                        Image = Period;
                        ToolTip = 'View the projected quantity of the item over time according to time periods, such as day, week, or month.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromProdOrderComp(Rec, ItemAvailFormsMgt.ByPeriod());
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
                            ItemAvailFormsMgt.ShowItemAvailFromProdOrderComp(Rec, ItemAvailFormsMgt.ByVariant());
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
                            ItemAvailFormsMgt.ShowItemAvailFromProdOrderComp(Rec, ItemAvailFormsMgt.ByLocation());
                        end;
                    }
                    action(Lot)
                    {
                        ApplicationArea = ItemTracking;
                        Caption = 'Lot';
                        Image = LotInfo;
                        // RunObject = Page "Item Availability by Lot No.";
                        // RunPageLink = "No." = field("Item No."),
                        //     "Location Filter" = field("Location Code"),
                        //     "Variant Filter" = field("Variant Code");
                        ToolTip = 'View the current and projected quantity of the item in each lot.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromProdOrderComp(Rec, ItemAvailFormsMgt.ByLot);
                        end;
                    }
                    action("BOM Level")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'BOM Level';
                        Image = BOMLevel;
                        ToolTip = 'View availability figures for items on bills of materials that show how many units of a parent item you can make based on the availability of child items.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromProdOrderComp(Rec, ItemAvailFormsMgt.ByBOM());
                        end;
                    }
                }
                action("Co&mments")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Prod. Order Comp. Cmt. Sheet";
                    RunPageLink = Status = FIELD(Status),
                                  "Prod. Order No." = FIELD("Prod. Order No."),
                                  "Prod. Order Line No." = FIELD("Prod. Order Line No."),
                                  "Prod. Order BOM Line No." = FIELD("Line No.");
                    ToolTip = 'View or add comments for the record.';
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
                        CurrPage.SaveRecord();
                    end;
                }
                action(ItemTrackingLines)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    ShortCutKey = 'Ctrl+Alt+I';
                    ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.';

                    trigger OnAction()
                    begin
                        OpenItemTrackingLines();
                    end;
                }
                action("Bin Contents")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Bin Contents';
                    Image = BinContent;
                    RunObject = Page "Bin Contents List";
                    RunPageLink = "Location Code" = FIELD("Location Code"),
                                  "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code");
                    RunPageView = SORTING("Location Code", "Bin Code", "Item No.", "Variant Code");
                    ToolTip = 'View items in the bin if the selected line contains a bin code.';
                }
                action(SelectItemSubstitution)
                {
                    AccessByPermission = TableData "Item Substitution" = R;
                    ApplicationArea = Manufacturing;
                    Caption = '&Select Item Substitution';
                    Image = SelectItemSubstitution;
                    ToolTip = 'Select another item that has been set up to be traded instead of the original item if it is unavailable.';

                    trigger OnAction()
                    begin
                        CurrPage.SaveRecord();
                        ShowItemSub();
                        CurrPage.Update(true);
                        ReserveComp();
                    end;
                }
                action("Put-away/Pick Lines/Movement Lines")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Put-away/Pick Lines/Movement Lines';
                    Image = PutawayLines;
                    RunObject = Page "Warehouse Activity Lines";
                    RunPageLink = "Source Type" = CONST(5407),
                                  "Source Subtype" = CONST("3"),
                                  "Source No." = FIELD("Prod. Order No."),
                                  "Source Line No." = FIELD("Prod. Order Line No."),
                                  "Source Subline No." = FIELD("Line No.");
                    RunPageView = SORTING("Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.", "Unit of Measure Code", "Action Type", "Breakbulk No.", "Original Breakbulk");
                    ToolTip = 'View the list of ongoing inventory put-aways, picks, or movements for the order.';
                }
                action("Lot Preferences")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Lot Preferences';
                    Image = NewLotProperties;

                    trigger OnAction()
                    var
                        Item: Record Item;
                        ItemTrackingCode: Record "Item Tracking Code";
                        POComp: Record "Prod. Order Component";
                        LotPreferences: Page "PO Component Lot Preferences";
                    begin
                        // P8000153A
                        Item.Get("Item No.");
                        Item.TestField("Item Tracking Code");
                        ItemTrackingCode.Get(Item."Item Tracking Code");
                        ItemTrackingCode.TestField("Lot Specific Tracking", true);

                        POComp := Rec;
                        POComp.SetRecFilter;
                        LotPreferences.SetTableView(POComp);
                        LotPreferences.RunModal;
                    end;
                }
                action("Pre-Process Activities")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pre-Process Activities';
                    Image = Process;
                    RunObject = Page "Pre-Process Activity List";
                    RunPageLink = "Prod. Order Status" = FIELD(Status),
                                  "Prod. Order No." = FIELD("Prod. Order No."),
                                  "Prod. Order Line No." = FIELD("Prod. Order Line No."),
                                  "Prod. Order Comp. Line No." = FIELD("Line No.");
                    RunPageView = SORTING("Prod. Order Status", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Comp. Line No.");
                }
                action("Reg. Pre-Process Activities")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Reg. Pre-Process Activities';
                    Image = RegisteredDocs;
                    RunObject = Page "Reg. Pre-Process Activity List";
                    RunPageLink = "Prod. Order Status" = FIELD(Status),
                                  "Prod. Order No." = FIELD("Prod. Order No."),
                                  "Prod. Order Line No." = FIELD("Prod. Order Line No."),
                                  "Prod. Order Comp. Line No." = FIELD("Line No.");
                    RunPageView = SORTING("Prod. Order Status", "Prod. Order No.", "Prod. Order Line No.", "Prod. Order Comp. Line No.");
                }
                action("Item Ledger E&ntries")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Item Ledger E&ntries';
                    Image = ItemLedger;
                    RunObject = Page "Item Ledger Entries";
                    RunPageLink = "Order Type" = CONST(Production),
                                  "Order No." = FIELD("Prod. Order No."),
                                  "Order Line No." = field("Prod. Order Line No."),
                                  "Prod. Order Comp. Line No." = field("Line No.");
                    RunPageView = SORTING("Order Type", "Order No.");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the item ledger entries of the item on the document or journal line.';
                }
            }
        }
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
                        if Status in [Status::Simulated, Status::Planned] then
                            Error(Text000, Status);

                        CurrPage.SaveRecord();
                        ShowReservation();
                    end;
                }
                action(OrderTracking)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Order &Tracking';
                    Image = OrderTracking;
                    ToolTip = 'Tracks the connection of a supply to its corresponding demand. This can help you find the original demand that created a specific production order or purchase order.';

                    trigger OnAction()
                    var
                        TrackingForm: Page "Order Tracking";
                    begin
                        TrackingForm.SetProdOrderComponent(Rec);
                        TrackingForm.RunModal();
                    end;
                }
            }
            action("&Print")
            {
                ApplicationArea = Manufacturing;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

                trigger OnAction()
                var
                    ProdOrderComp: Record "Prod. Order Component";
                begin
                    ProdOrderComp.Copy(Rec);
                    REPORT.RunModal(REPORT::"Prod. Order - Picking List", true, true, ProdOrderComp);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref(Reserve_Promoted; Reserve)
                {
                }
                actionref(OrderTracking_Promoted; OrderTracking)
                {
                }
                group(Category_Category5)
                {
                    Caption = 'Line', Comment = 'Generated from the PromotedActionCategories property index 4.';

                    actionref(ItemTrackingLines_Promoted; ItemTrackingLines)
                    {
                    }
                    actionref(SelectItemSubstitution_Promoted; SelectItemSubstitution)
                    {
                    }
                    actionref(Dimensions_Promoted; Dimensions)
                    {
                    }
                    actionref("Co&mments_Promoted"; "Co&mments")
                    {
                    }
#if not CLEAN21
                    actionref("Bin Contents_Promoted"; "Bin Contents")
                    {
                        Visible = false;
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Action is being demoted based on overall low usage.';
                        ObsoleteTag = '21.0';
                    }
#endif
                    actionref("Put-away/Pick Lines/Movement Lines_Promoted"; "Put-away/Pick Lines/Movement Lines")
                    {
                    }
                    actionref("Item Ledger E&ntries_Promoted"; "Item Ledger E&ntries")
                    {
                    }
                }
                actionref("&Print_Promoted"; "&Print")
                {
                }
            }
            group(Category_Category4)
            {
                Caption = 'Print/Send', Comment = 'Generated from the PromotedActionCategories property index 3.';

            }
            group(Category_Report)
            {
                Caption = 'Report', Comment = 'Generated from the PromotedActionCategories property index 2.';
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        Item: Record Item;
    begin
        ShowShortcutDimCode(ShortcutDimCode);
        if "Variant Code" = '' then
            VariantCodeMandatory := Item.IsVariantMandatory(true, "Item No.");
    end;

    trigger OnDeleteRecord(): Boolean
    var
        ProdOrderCompReserve: Codeunit "Prod. Order Comp.-Reserve";
    begin
        Commit();
        if not ProdOrderCompReserve.DeleteLineConfirm(Rec) then
            exit(false);
        ProdOrderCompReserve.DeleteLine(Rec);
    end;

    trigger OnInit()
    begin
        "Lot No.Editable" := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(ShortcutDimCode);
    end;

    var
        Text000: Label 'You cannot reserve components with status %1.';
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        VariantCodeMandatory: Boolean;
        EasyLotTracking: Codeunit "Easy Lot Tracking";
        Text37002000: Label 'The update has been interrupted to respect the warning.';
        [InDataSet]
        "Lot No.Editable": Boolean;
        AllergenManagement: Codeunit "Allergen Management";

    protected var
        ShortcutDimCode: array[8] of Code[20];

    procedure ReserveComp()
    var
        Item: Record Item;
        ShouldReserve: Boolean;
    begin
        ShouldReserve :=
            (xRec."Remaining Qty. (Base)" <> "Remaining Qty. (Base)") or
            (xRec."Item No." <> "Item No.") or
            (xRec."Location Code" <> "Location Code");

        OnBeforeReserveComp(Rec, xRec, ShouldReserve);

        if ShouldReserve then
            if Item.Get("Item No.") then
                if Item.Reserve = Item.Reserve::Always then begin
                    CurrPage.SaveRecord();
                    AutoReserve();
                    CurrPage.Update(false);
                end;
    end;

    protected procedure ItemNoOnAfterValidate()
    begin
        ReserveComp();
    end;

    local procedure ScrapPercentOnAfterValidate()
    begin
        ReserveComp();
    end;

    protected procedure CalculationFormulaOnAfterValidate()
    begin
        ReserveComp();
    end;

    protected procedure LengthOnAfterValidate()
    begin
        ReserveComp();
    end;

    protected procedure WidthOnAfterValidate()
    begin
        ReserveComp();
    end;

    protected procedure WeightOnAfterValidate()
    begin
        ReserveComp();
    end;

    protected procedure DepthOnAfterValidate()
    begin
        ReserveComp();
    end;

    protected procedure QuantityperOnAfterValidate()
    begin
        ReserveComp();
    end;

    protected procedure UnitofMeasureCodeOnAfterValidate()
    begin
        ReserveComp();
    end;

    protected procedure LocationCodeOnAfterValidate()
    begin
        ReserveComp();
    end;

    procedure SetLotFields(Property: Code[10])
    var
        ProcessFns: Codeunit "Process 800 Functions";
        P800Globals: Codeunit "Process 800 System Globals";
    begin
        // P8000043A
        case Property of
            'EDITABLE':
                // P8000761
                //CurrForm."Lot No.".EDITABLE(ProcessFns.TrackingInstalled AND ("Lot No." <> P800Globals.MultipleLotCode));
                "Lot No.Editable" := (ProcessFns.TrackingInstalled and ("Lot No." <> P800Globals.MultipleLotCode));
        // P8000761
        end;
    end;

    local procedure LotNoOnAfterValidate()
    begin
        // P8000227A Begin
        if "Line No." = 0 then begin
            CurrPage.SaveRecord;
            UpdateLotTracking(false);
        end;
        // P8000227A End
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeReserveComp(var ProdOrderComp: Record "Prod. Order Component"; xProdOrderComp: Record "Prod. Order Component"; var ShouldReserve: Boolean)
    begin
    end;
}

