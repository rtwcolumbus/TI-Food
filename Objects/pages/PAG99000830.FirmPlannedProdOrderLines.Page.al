page 99000830 "Firm Planned Prod. Order Lines"
{
    // PR1.00
    //   Add Qty.in  Batch (Base)
    // 
    // PR3.70.04
    // P8000043A, Myers Nissi, Jack Reynolds, 01 JUN 04
    //   Support for easy lot tracking
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
    //   Code changed in the SetLotFields() method to be correctly transformed into 2009
    // 
    // PRW16.00.03
    // P8000817, VerticalSoft, Jack Reynolds, 26 APR 10
    //   Change visible property of fields
    // 
    // PRW16.00.04
    // P8000875, VerticalSoft, Jack Reynolds, 14 OCT 10
    //   Remove Qty. in Batch
    // 
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Add Equipment code
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
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens

    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Prod. Order Line";
    SourceTableView = WHERE(Status = CONST("Firm Planned"));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                IndentationColumn = DescriptionIndent;
                IndentationControls = Description;
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the item that is to be produced.';
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
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the date when the produced item must be available. The date is copied from the header of the production order.';
                }
                field("Planning Flexibility"; "Planning Flexibility")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies whether the supply represented by this line is considered by the planning system when calculating action messages.';
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the value of the Description field on the item card. If you enter a variant code, the variant description is copied to this field instead.';
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies an additional description.';
                    Visible = false;
                }
                field("Production BOM No."; "Production BOM No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the production BOM that is the basis for creating the Prod. Order Component list for this line.';
                    Visible = false;
                }
                field("Routing No."; "Routing No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the routing used as the basis for creating the production order routing for this line.';
                    Visible = false;
                }
                field("Production BOM Version Code"; "Production BOM Version Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the version code of the production BOM.';
                    Visible = false;
                }
                field("Routing Version Code"; "Routing Version Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the version number of the routing.';
                    Visible = false;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the location code, if the produced items should be stored in a specific location.';
                    Visible = false;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the bin that the produced item is posted to as output, and from where it can be taken to storage or cross-docked.';
                    Visible = false;
                }
                field("Equipment Code"; "Equipment Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Starting Date-Time"; "Starting Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the starting date and the starting time, which are combined in a format called "starting date-time".';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Starting Time"; StartingTime)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Starting Time';
                    ToolTip = 'Specifies the entry''s starting time, which is retrieved from the production order routing.';
                    Visible = DateAndTimeFieldVisible;

                    trigger OnValidate()
                    begin
                        Validate("Starting Time", StartingTime);
                        CurrPage.Update(true);
                    end;
                }
                field("Starting Date"; StartingDate)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Starting Date';
                    ToolTip = 'Specifies the entry''s starting date, which is retrieved from the production order routing.';
                    Visible = DateAndTimeFieldVisible;

                    trigger OnValidate()
                    begin
                        Validate("Starting Date", StartingDate);
                        CurrPage.Update(true);
                    end;
                }
                field("Ending Date-Time"; "Ending Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the ending date and the ending time, which are combined in a format called "ending date-time".';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Ending Time"; EndingTime)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Ending Time';
                    ToolTip = 'Specifies the entry''s ending time, which is retrieved from the production order routing.';
                    Visible = DateAndTimeFieldVisible;

                    trigger OnValidate()
                    begin
                        Validate("Ending Time", EndingTime);
                        CurrPage.Update(true);
                    end;
                }
                field("Ending Date"; EndingDate)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Ending Date';
                    ToolTip = 'Specifies the entry''s ending date, which is retrieved from the production order routing.';
                    Visible = DateAndTimeFieldVisible;

                    trigger OnValidate()
                    begin
                        Validate("Ending Date", EndingDate);
                        CurrPage.Update(true);
                    end;
                }
                field("Scrap %"; "Scrap %")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the percentage of the item that you expect to be scrapped in the production process.';
                    Visible = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the quantity to be produced if you manually fill in this line.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Lot No.Editable";

                    trigger OnAssistEdit()
                    begin
                        // P8000043A
                        CurrPage.SaveRecord; // P8000194A
                        Commit;              // P8000194A
                        EasyLotTracking.SetProdOrderLine(Rec);
                        if EasyLotTracking.AssistEdit("Lot No.") then
                            UpdateLotTracking(true);
                        CurrPage.SaveRecord
                    end;

                    trigger OnValidate()
                    begin
                        LotNoOnAfterValidate;
                    end;
                }
                field("Reserved Quantity"; "Reserved Quantity")
                {
                    ApplicationArea = Reservation;
                    ToolTip = 'Specifies how many units of this item have been reserved.';
                    Visible = false;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the cost of one unit of the item or resource on the line.';
                }
                field("Cost Amount"; "Cost Amount")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the total cost on the line by multiplying the unit cost by the quantity.';
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
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
                action("&Reserve")
                {
                    ApplicationArea = Reservation;
                    Caption = '&Reserve';
                    Image = Reserve;
                    ToolTip = 'Reserve the quantity that is required on the document line that you opened this window for.';

                    trigger OnAction()
                    begin
                        PageShowReservation();
                    end;
                }
                action("Order &Tracking")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Order &Tracking';
                    Image = OrderTracking;
                    ToolTip = 'Tracks the connection of a supply to its corresponding demand. This can help you find the original demand that created a specific production order or purchase order.';

                    trigger OnAction()
                    begin
                        ShowTracking();
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
                        ApplicationArea = Manufacturing;
                        Caption = 'Event';
                        Image = "Event";
                        ToolTip = 'View how the actual and the projected available balance of an item will develop over time according to supply and demand events.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromProdOrderLine(Rec, ItemAvailFormsMgt.ByEvent);
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
                            ItemAvailFormsMgt.ShowItemAvailFromProdOrderLine(Rec, ItemAvailFormsMgt.ByPeriod);
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
                            ItemAvailFormsMgt.ShowItemAvailFromProdOrderLine(Rec, ItemAvailFormsMgt.ByVariant);
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
                            ItemAvailFormsMgt.ShowItemAvailFromProdOrderLine(Rec, ItemAvailFormsMgt.ByLocation);
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
                    action("BOM Level")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'BOM Level';
                        Image = BOMLevel;
                        ToolTip = 'View availability figures for items on bills of materials that show how many units of a parent item you can make based on the availability of child items.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromProdOrderLine(Rec, ItemAvailFormsMgt.ByBOM);
                        end;
                    }
                }
                action("Reservation Entries")
                {
                    AccessByPermission = TableData Item = R;
                    ApplicationArea = Reservation;
                    Caption = 'Reservation Entries';
                    Image = ReservationLedger;
                    ToolTip = 'View the entries for every reservation that is made, either manually or automatically.';

                    trigger OnAction()
                    begin
                        ShowReservationEntries(true);
                    end;
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
                action("Ro&uting")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Ro&uting';
                    Image = Route;
                    ToolTip = 'View or edit the operations list of the parent item on the line.';

                    trigger OnAction()
                    begin
                        ShowRouting;
                    end;
                }
                action(Components)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Components';
                    Image = Components;
                    ToolTip = 'View or edit the production order components of the parent item on the line.';

                    trigger OnAction()
                    begin
                        ShowComponents;
                    end;
                }
                action("Item &Tracking Lines")
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
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DescriptionIndent := 0;
        ShowShortcutDimCode(ShortcutDimCode);
        OnAfterGetCurrRecord2; // P8001352
        DescriptionOnFormat;
        GetStartingEndingDateAndTime(StartingTime, StartingDate, EndingTime, EndingDate);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        ReserveProdOrderLine: Codeunit "Prod. Order Line-Reserve";
    begin
        Commit();
        if not ReserveProdOrderLine.DeleteLineConfirm(Rec) then
            exit(false);
    end;

    trigger OnInit()
    begin
        "Lot No.Editable" := true;
        DateAndTimeFieldVisible := false;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(ShortcutDimCode);
        OnAfterGetCurrRecord2; // P8001352
    end;

    trigger OnOpenPage()
    begin
        DateAndTimeFieldVisible := false;
    end;

    var
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        EasyLotTracking: Codeunit "Easy Lot Tracking";
        [InDataSet]
        DescriptionIndent: Integer;
        StartingTime: Time;
        EndingTime: Time;
        StartingDate: Date;
        EndingDate: Date;
        DateAndTimeFieldVisible: Boolean;
        [InDataSet]
        "Lot No.Editable": Boolean;
        AllergenManagement: Codeunit "Allergen Management";

    protected var
        ShortcutDimCode: array[8] of Code[20];

    local procedure ShowComponents()
    var
        ProdOrderComp: Record "Prod. Order Component";
    begin
        ProdOrderComp.SetRange(Status, Status);
        ProdOrderComp.SetRange("Prod. Order No.", "Prod. Order No.");
        ProdOrderComp.SetRange("Prod. Order Line No.", "Line No.");

        PAGE.Run(PAGE::"Prod. Order Components", ProdOrderComp);
    end;

    local procedure ShowTracking()
    var
        TrackingForm: Page "Order Tracking";
    begin
        TrackingForm.SetProdOrderLine(Rec);
        TrackingForm.RunModal();
    end;

    local procedure PageShowReservation()
    begin
        CurrPage.SaveRecord;
        ShowReservation();
    end;

    procedure UpdateForm(SetSaveRecord: Boolean)
    begin
        CurrPage.Update(SetSaveRecord);
    end;

    local procedure DescriptionOnFormat()
    begin
        DescriptionIndent := "Planning Level Code";
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

    local procedure OnAfterGetCurrRecord2()
    begin
        // P8001352 - Renamed
        xRec := Rec;
        SetLotFields('EDITABLE'); // P8000043A
    end;
}

