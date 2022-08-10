page 7378 "Invt. Pick Subform"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // 
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Support for running for order shipping; alternate quantites
    // 
    // PRW16.00.02
    // P8000778, VerticalSoft, Rick Tweedle, 25 FEB 10
    //   Amended code to allow automatic page transformation
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
    // P8006916, To-Increase, Dayakar Battini, 16 JUN 16
    //   FOOD-TOM Separation delete Transsmart objects
    // 
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017

    Caption = 'Lines';
    InsertAllowed = false;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Warehouse Activity Line";
    SourceTableView = WHERE("Activity Type" = CONST("Invt. Pick"));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Action Type"; Rec."Action Type")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the action type for the warehouse activity line.';
                    Visible = false;
                }
                field("Source Document"; Rec."Source Document")
                {
                    ApplicationArea = Warehouse;
                    BlankZero = true;
                    ToolTip = 'Specifies the type of document that the line relates to.';
                    Visible = false;
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the source document that the entry originates from.';
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the item number of the item to be handled, such as picked or put away.';
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
                    ToolTip = 'Specifies a description of the item on the line.';
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the serial number to handle in the document.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        SerialNoOnAfterValidate();
                    end;
                }
                field("Serial No. Blocked"; Rec."Serial No. Blocked")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the serial number is blocked, on its information card.';
                    Visible = false;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the lot number to handle in the document.';

                    trigger OnValidate()
                    begin
                        LotNoOnAfterValidate();
                    end;
                }
                field("Lot No. Blocked"; Rec."Lot No. Blocked")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the lot number is blocked, on its information card.';
                    Visible = false;
                }
                field("Package No."; Rec."Package No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the package number to handle in the document.';
                    Visible = PackageTrackingVisible;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = ItemTracking;
                    Editable = false;
                    ToolTip = 'Specifies the expiration date of the serial/lot numbers if you are putting items away.';
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the code for the location where the activity occurs.';
                    Visible = false;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the bin where the items are picked or put away.';

                    trigger OnValidate()
                    begin
                        BinCodeOnAfterValidate;
                    end;
                }
                field("Shelf No."; Rec."Shelf No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the shelf number of the item for informational use.';
                    Visible = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity of the item to be handled, such as received, put-away, or assigned.';
                }
                field("Qty. (Base)"; Rec."Qty. (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity of the item to be handled, in the base unit of measure.';
                    Visible = false;
                }
                field("Quantity (Alt.)"; Rec."Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. to Handle"; Rec."Qty. to Handle")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies how many units to handle in this warehouse activity.';

                    trigger OnValidate()
                    begin
                        QtytoHandleOnAfterValidate;
                    end;
                }
                field("Qty. to Handle (Alt.)"; Rec."Qty. to Handle (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Qty. to Handle (Alt.)Editable";

                    trigger OnDrillDown()
                    begin
                        // PR8000282A
                        CurrPage.SaveRecord;
                        AltQtyMgmt.ShowWhseActAltQtyLines(Rec);
                        CurrPage.Update;
                    end;

                    trigger OnValidate()
                    begin
                        QtytoHandleAltOnAfterValidate;
                    end;
                }
                field("Qty. Handled"; Rec."Qty. Handled")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of items on the line that have been handled in this warehouse activity.';
                    Visible = true;
                }
                field("Quantity Handled (Alt.)"; Rec."Quantity Handled (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. to Handle (Base)"; Rec."Qty. to Handle (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity of items to be handled in this warehouse activity.';
                    Visible = false;
                }
                field("Qty. Handled (Base)"; Rec."Qty. Handled (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of items on the line that have been handled in this warehouse activity.';
                    Visible = false;
                }
                field("Qty. Outstanding"; Rec."Qty. Outstanding")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of items that have not yet been handled for this warehouse activity line.';
                    Visible = true;
                }
                field("Qty. Outstanding (Base)"; Rec."Qty. Outstanding (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of items, expressed in the base unit of measure, that have not yet been handled for this warehouse activity line.';
                    Visible = false;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the date when the warehouse activity must be completed.';
                    Visible = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity per unit of measure of the item on the line.';
                    Visible = false;
                }
                field("Shipping Advice"; Rec."Shipping Advice")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the shipping advice, informing whether partial deliveries are acceptable, copied from the source document header.';
                    Visible = false;
                }
                field("Destination Type"; Rec."Destination Type")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies information about the type of destination, such as customer or vendor, associated with the warehouse activity line.';
                    Visible = false;
                }
                field("Destination No."; Rec."Destination No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number or code of the customer, vendor or location related to the activity line.';
                    Visible = false;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code for the shipping agent who is transporting the items.';
                    Visible = false;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code for the service, such as a one-day delivery, that is offered by the shipping agent.';
                    Visible = false;
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the delivery conditions of the related shipment, such as free on board (FOB).';
                    Visible = false;
                }
                field("Special Equipment Code"; Rec."Special Equipment Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code of the equipment required when you perform the action on the line.';
                    Visible = false;
                }
                field("Assemble to Order"; Rec."Assemble to Order")
                {
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies that the inventory pick line is for assembly items that are assembled to a sales order before being shipped.';
                    Visible = false;
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
                action(SplitWhseActivityLine)
                {
                    ApplicationArea = Warehouse;
                    Caption = '&Split Line';
                    Image = Split;
                    ShortCutKey = 'Ctrl+F11';
                    ToolTip = 'Enable that the items can be taken or placed in more than one bin, for example, because the quantity in the suggested bin is insufficient to pick or move or there is not enough room to put away the required quantity.';

                    trigger OnAction()
                    begin
                        CallSplitLine();
                    end;
                }
            }
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
                action("Bin Contents List")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Bin Contents List';
                    Image = BinContent;
                    ToolTip = 'View the contents of the selected bin and the parameters that define how items are routed through the bin.';

                    trigger OnAction()
                    begin
                        ShowBinContents();
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
                            Rec.ShowItemAvailabilityByEvent();
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
                            Rec.ShowItemAvailabilityByPeriod();
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
                            Rec.ShowItemAvailabilityByVariant();
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
                            Rec.ShowItemAvailabilityByLocation();
                        end;
                    }
                    action(Lot)
                    {
                        ApplicationArea = ItemTracking;
                        Caption = 'Lot';
                        Image = LotInfo;
                        // RunObject = Page "Item Availability by Lot No.";
                        // RunPageLink = "No." = field("No."),
                        //     "Location Filter" = field("Location Code"),
                        //     "Variant Filter" = field("Variant Code");
                        ToolTip = 'View the current and projected quantity of the item in each lot.';

                        trigger OnAction()
                        begin
                            Rec.ShowItemAvailabilityByLot();
                        end;
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        OnAfterGetCurrRecord2; // P8001352
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update(false);
    end;

    trigger OnInit()
    begin
        "Qty. to Handle (Alt.)Editable" := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Activity Type" := xRec."Activity Type";
        OnAfterGetCurrRecord2; // P8001352
    end;

    trigger OnOpenPage()
    begin
        SetPackageTrackingVisibility();
    end;

    var
        WMSMgt: Codeunit "WMS Management";
        [InDataSet]
        PackageTrackingVisible: Boolean;
        RunFromOrderShip: Boolean;
        Posted: Boolean;
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        AllergenManagement: Codeunit "Allergen Management";
        [InDataSet]
        "Qty. to Handle (Alt.)Editable": Boolean;

    local procedure ShowSourceLine()
    begin
        WMSMgt.ShowSourceDocLine(
            Rec."Source Type", Rec."Source Subtype", Rec."Source No.", Rec."Source Line No.", Rec."Source Subline No.");
    end;

    local procedure ShowBinContents()
    var
        BinContent: Record "Bin Content";
    begin
        BinContent.ShowBinContents(Rec."Location Code", Rec."Item No.", Rec."Variant Code", '')
    end;

    procedure AutofillQtyToHandle()
    var
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        WhseActivLine.Copy(Rec);
        Rec.AutofillQtyToHandle(WhseActivLine);
    end;

    procedure DeleteQtyToHandle()
    var
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        WhseActivLine.Copy(Rec);
        Rec.DeleteQtyToHandle(WhseActivLine);
    end;

    local procedure CallSplitLine()
    var
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        WhseActivLine.Copy(Rec);
        Rec.SplitLine(WhseActivLine);
        Rec.Copy(WhseActivLine);
        CurrPage.Update(false);
    end;

    procedure PostPickYesNo()
    var
        WhseActivLine: Record "Warehouse Activity Line";
        WhseActivPostYesNo: Codeunit "Whse.-Act.-Post (Yes/No)";
    begin
        WhseActivLine.Copy(Rec);
        WhseActivPostYesNo.RunFromOrderShipping(RunFromOrderShip); // P8000282A
        OnPostPickYesNoOnBeforeRunWhseActivPostYesNo(WhseActivLine);
        WhseActivPostYesNo.Run(WhseActivLine); // P8007748
        Posted := WhseActivPostYesNo.DocumentPosted; // P8000282A
        CurrPage.Update(false);
    end;

    procedure PostAndPrint()
    var
        WhseActivLine: Record "Warehouse Activity Line";
        WhseActivPostYesNo: Codeunit "Whse.-Act.-Post (Yes/No)";
    begin
        WhseActivLine.Copy(Rec);
        WhseActivPostYesNo.RunFromOrderShipping(RunFromOrderShip); // P8000282A
        WhseActivPostYesNo.PrintDocument(true);
        OnPostAndPrintOnBeforeRunWhseActivPostYesNo(WhseActivLine);
        WhseActivPostYesNo.Run(WhseActivLine);
        Posted := WhseActivPostYesNo.DocumentPosted; // P8000282A
        CurrPage.Update(false);
    end;

    procedure UpdateForm()
    begin
        CurrPage.Update();
    end;

    protected procedure SerialNoOnAfterValidate()
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ExpDate: Date;
        EntriesExist: Boolean;
    begin
        if Rec."Serial No." <> '' then
            ExpDate := ItemTrackingMgt.ExistingExpirationDate(Rec, false, EntriesExist);

        if ExpDate <> 0D then
            Rec."Expiration Date" := ExpDate;

        CurrPage.SaveRecord; // P8000282A
    end;

    protected procedure LotNoOnAfterValidate()
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ExpDate: Date;
        EntriesExist: Boolean;
    begin
        if Rec."Lot No." <> '' then
            ExpDate := ItemTrackingMgt.ExistingExpirationDate(Rec, false, EntriesExist);

        if ExpDate <> 0D then
            Rec."Expiration Date" := ExpDate;

        CurrPage.SaveRecord; // P8000282A
    end;

    protected procedure BinCodeOnAfterValidate()
    begin
        CurrPage.Update();
    end;

    protected procedure QtytoHandleOnAfterValidate()
    begin
        CurrPage.SaveRecord();
    end;

    local procedure SetPackageTrackingVisibility()
    var
        PackageMgt: Codeunit "Package Management";
    begin
        PackageTrackingVisible := PackageMgt.IsEnabled();
    end;

    procedure RunFromOrderShipping(OrderShip: Boolean)
    begin
        // P8000282A
        RunFromOrderShip := OrderShip;
    end;

    procedure PickPosted(): Boolean
    begin
        // P8000282A
        exit(Posted);
    end;

    local procedure QtytoHandleAltOnAfterValidate()
    begin
        // PR8000282A
        CurrPage.SaveRecord;
        AltQtyMgmt.ValidateWhseActAltQtyLine(Rec);
        CurrPage.Update;
    end;

    local procedure OnAfterGetCurrRecord2()
    begin
        // P8001352 - Renamed
        xRec := Rec;
        //CurrForm."Qty. to Handle (Alt.)".EDITABLE(TrackAlternateUnits());  // P8000778
        "Qty. to Handle (Alt.)Editable" := TrackAlternateUnits();  // P8000778
        // P8000282A
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostPickYesNoOnBeforeRunWhseActivPostYesNo(var WhseActivLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAndPrintOnBeforeRunWhseActivPostYesNo(var WhseActivLine: Record "Warehouse Activity Line")
    begin
    end;
}

