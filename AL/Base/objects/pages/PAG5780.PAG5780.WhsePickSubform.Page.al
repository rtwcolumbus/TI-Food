page 5780 "Whse. Pick Subform"
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
    //   Set lot, zone, and bin to visible; alternate quantities
    // 
    // PR4.00.04
    // P8000322A, VerticalSoft, Don Bresee, 18 AUG 06
    //   Support for running from order shipping
    //   Staged Picks
    // 
    // PRW15.00.03
    // P8000630A, VerticalSoft, Don Bresee, 17 SEP 08
    //   Disable changes to delivery trip documents
    // 
    // PRW16.00.02
    // P8000777, VerticalSoft, Don Bresee, 25 FEB 10
    //   Changed EDITABLE so it could be handled by the form transformation tool
    // 
    // PRW16.00.05
    // P8000934, Columbus IT, Jack Reynolds, 22 APR 11
    //   Fix problem with disabling actions for delivery trips
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 23 APR 13
    //   Upgrade for NAV 2013
    // 
    // PRW19.00
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
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
    // 
    // PRW110.0.02
    // P80050544, To-Increase, Dayakar Battini, 12 FEB 18
    //   Upgrade to 2017 CU13
    // 
    // P80039754, To-Increase, Jack Reynolds, 08 FEB 18
    //   Warehouse Pick process
    // 
    // PRW111.00.01
    // P80061239, To Increase, Jack Reynolds, 31 JUL 18
    //   Run Bin Status from warehouse document pages
    // 
    // PRW111.00.03
    // P80086144, To-Increase, Gangabhushan, 04 NOV 19
    //   CS00079900 - New Pick Line Creation error when Pick lines more than 9 lines splits in Pick page

    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    InsertAllowed = false;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Warehouse Activity Line";
    SourceTableView = WHERE("Activity Type" = CONST(Pick));

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
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the source document that the entry originates from.';
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
                field("Zone Code"; Rec."Zone Code")
                {
                    ApplicationArea = Warehouse;
                    Editable = ZoneCodeEditable;
                    ToolTip = 'Specifies the zone code where the bin on this line is located.';
                    Visible = false;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Warehouse;
                    Editable = BinCodeEditable;
                    ToolTip = 'Specifies the bin where the items are picked or put away.';
                    Visible = true;

                    trigger OnValidate()
                    begin
                        BinCodeOnAfterValidate();
                    end;
                }
                field("Shelf No."; Rec."Shelf No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the shelf number of the item for informational use.';
                    Visible = false;
                }
                field(Quantity; Rec.Quantity)
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
                field("Directed Pick Type"; DirectedPickType)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Container License Plate"; Rec."Container License Plate")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ContainerFns: Codeunit "Container Functions";
                    begin
                        // P8001323
                        exit(ContainerFns.LookupContainerOnWhseLine(Rec, FieldNo("Container License Plate"), Text));
                    end;

                    trigger OnValidate()
                    begin
                        QtyToHandleAltEditable := TrackAlternateUnits() and ("Container ID" = '');  // P8001323
                        xRec."Line No." := "Line No."; // P80086144
                        CurrPage.Update; // P8001347
                    end;
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
                        QtytoHandleOnAfterValidate();
                    end;
                }
                field("Qty. to Handle (Alt.)"; Rec."Qty. to Handle (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "QtytoHandleAltEditable";

                    trigger OnDrillDown()
                    begin
                        // PR8000282A
                        if QtyToHandleAltEditable and ("Container ID" = '') then begin // P8001323
                            CurrPage.SaveRecord;
                            AltQtyMgmt.ShowWhseActAltQtyLines(Rec);
                            CurrPage.Update;
                        end;
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
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the quantity per unit of measure of the item on the line.';
                }
                field("Shipping Advice"; Rec."Shipping Advice")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the shipping advice, which informs whether partial deliveries are acceptable.';
                    Visible = false;
                }
                field("Destination Type"; Rec."Destination Type")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies information about the type of destination, such as customer or vendor, associated with the warehouse activity line.';
                }
                field("Destination No."; Rec."Destination No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number or code of the customer, vendor or location related to the activity line.';
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
                field("Whse. Document Type"; Rec."Whse. Document Type")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the type of warehouse document from which the line originated.';
                    Visible = false;
                }
                field("Whse. Document No."; Rec."Whse. Document No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the warehouse document that is the basis for the action on the line.';
                    Visible = false;
                }
                field("Whse. Document Line No."; Rec."Whse. Document Line No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of the line in the warehouse document that is the basis for the action on the line.';
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
            action("Convert Units")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Convert Units';
                Enabled = ConvertAvailable;
                Image = UnitConversions;

                trigger OnAction()
                var
                    ConvertUnitsPage: Page "Convert Whse. Units";
                begin
                    // P8001347
                    TestField("Action Type", "Action Type"::Take);
                    TestField("Bin Code");
                    ConvertUnitsPage.SetSource(
                      "Location Code", "Bin Code", "Item No.", "Variant Code",
                      "Lot No.", "Unit of Measure Code", "Qty. Outstanding");
                    ConvertUnitsPage.Run;
                end;
            }
            action(Repick)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Repick';
                Image = CreateInventoryPickup;

                trigger OnAction()
                var
                    CreateWhsePick: Codeunit "Process 800 Create Whse. Act.";
                    WhseActivLine: Record "Warehouse Activity Line";
                begin
                    // P8001347
                    CurrPage.SetSelectionFilter(WhseActivLine);
                    CreateWhsePick.RepickWhsePickForShptLine(Rec, WhseActivLine);
                    CurrPage.Update(false);
                end;
            }
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
                    var
                        WhseActivLine: Record "Warehouse Activity Line";
                    begin
                        WhseActivLine.Copy(Rec);
                        Rec.SplitLine(WhseActivLine);
                        Rec.Copy(WhseActivLine);
                        CurrPage.Update(false);
                    end;
                }
                action(ChangeUnitOfMeasure)
                {
                    ApplicationArea = Suite;
                    Caption = '&Change Unit Of Measure';
                    Ellipsis = true;
                    Image = UnitConversions;
                    ToolTip = 'Specify which unit of measure you want to change during the warehouse activity, for example, because you want to ship an item in boxes although you store it in pallets.';

                    trigger OnAction()
                    begin
                        ChangeUOM();
                    end;
                }
                action("New Container")
                {
                    AccessByPermission = TableData "Container Header" = R;
                    ApplicationArea = FOODBasic;
                    Caption = 'New Container';
                    Enabled = "Action Type" = "Action Type"::Place;
                    Image = NewItem;

                    trigger OnAction()
                    var
                        ContainerFns: Codeunit "Container Functions";
                    begin
                        // P8001323
                        ContainerFns.NewContainerOnWhseActivityLine(Rec);
                        ContainerFns.ValidateOnWhseActivityLine(Rec);
                        CurrPage.Update;
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
                action("Whse. Document Line")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Whse. Document Line';
                    Image = Line;
                    ToolTip = 'View the line on another warehouse document that the warehouse activity is for.';

                    trigger OnAction()
                    begin
                        WMSMgt.ShowWhseActivityDocLine(
                            Rec."Whse. Document Type", Rec."Whse. Document No.", Rec."Whse. Document Line No.");
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
                        // RunObject = Page "Item Availability by Lot No.";
                        // RunPageLink = "No." = field("Item No."),
                        //     "Location Filter" = field("Location Code"),
                        //     "Variant Filter" = field("Variant Code");
                        ToolTip = 'View the current and projected quantity of the item in each lot.';
                        
                        trigger OnAction()
                        begin
                            ItemAvailability(ItemAvailFormsMgt.ByLot);
                        end;
                    }
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        QtyToHandleAltEditable := TrackAlternateUnits();  // P8000777, P8001323
        EnableZoneBin();
    end;

    trigger OnAfterGetRecord()
    begin
        // P8001347
        ConvertAvailable := ("Action Type" = "Action Type"::Take) and ("Bin Code" <> '') and ("Container Qty." = 0);
        DirectedPickType := PickType; // P80039754
        // P8001347
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update(false);
    end;

    trigger OnInit()
    begin
        BinCodeEditable := true;
        ZoneCodeEditable := true;
        QtyToHandleAltEditable := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Activity Type" := xRec."Activity Type";
        // P8001347
        ConvertAvailable := false;
        DirectedPickType := PickType; // P80039754
        // P8001347
    end;

    trigger OnOpenPage()
    begin
        SetPackageTrackingVisibility();
    end;

    var
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        WMSMgt: Codeunit "WMS Management";
        AltQtyMgmt: Codeunit "Alt. Qty. Management";
        AllergenManagement: Codeunit "Allergen Management";
        RunFromOrderShip: Boolean;
        Posted: Boolean;
        [InDataSet]
        QtyToHandleAltEditable: Boolean;
        ConvertAvailable: Boolean;
        DirectedPickType: Text;
        [InDataSet]
        ZoneCodeEditable: Boolean;
        [InDataSet]
        BinCodeEditable: Boolean;
        [InDataSet]
        PackageTrackingVisible: Boolean;

    local procedure ShowSourceLine()
    begin
        WMSMgt.ShowSourceDocLine(
          Rec."Source Type", Rec."Source Subtype", Rec."Source No.", Rec."Source Line No.", Rec."Source Subline No.");
    end;

    local procedure ItemAvailability(AvailabilityType: Option Date,Variant,Location,Bin,"Event",BOM,Lot)
    begin
        ItemAvailFormsMgt.ShowItemAvailFromWhseActivLine(Rec, AvailabilityType);
    end;

    procedure AutofillQtyToHandle()
    var
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        WhseActivLine.Copy(Rec);
        WhseActivLine.SetRange("Activity Type", Rec."Activity Type");
        WhseActivLine.SetRange("No.", Rec."No.");
        OnAutofillQtyToHandleOnBeforeRecAutofillQtyToHandle(WhseActivLine);
        Rec.AutofillQtyToHandle(WhseActivLine);
    end;

    procedure DeleteQtyToHandle()
    var
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        WhseActivLine.Copy(Rec);
        WhseActivLine.SetRange("Activity Type", Rec."Activity Type");
        WhseActivLine.SetRange("No.", Rec."No.");
        Rec.DeleteQtyToHandle(WhseActivLine);
    end;

    local procedure ChangeUOM()
    var
        WhseActLine: Record "Warehouse Activity Line";
        WhseChangeOUM: Report "Whse. Change Unit of Measure";
    begin
        Rec.TestField("Action Type");
        Rec.TestField("Breakbulk No.", 0);
        Rec.TestField("Action Type", 1);
        WhseChangeOUM.DefWhseActLine(Rec);
        WhseChangeOUM.RunModal();
        if WhseChangeOUM.ChangeUOMCode(WhseActLine) then
            Rec.ChangeUOMCode(Rec, WhseActLine);
        Clear(WhseChangeOUM);
        CurrPage.Update(false);
    end;

    procedure RegisterActivityYesNo()
    var
        WhseActivLine: Record "Warehouse Activity Line";
        WhseRegisterActivityYesNo: Codeunit "Whse.-Act.-Register (Yes/No)";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeRegisterActivityYesNo(Rec, IsHandled);
        if IsHandled then
            exit;

        WhseActivLine.Copy(Rec);
        WhseActivLine.FilterGroup(3);
        WhseActivLine.SetRange(Breakbulk);
        WhseActivLine.FilterGroup(0);
        WhseRegisterActivityYesNo.RunFromOrderShipping(RunFromOrderShip); // P8000322A
        WhseRegisterActivityYesNo.Run(WhseActivLine); // P8007748
        Posted := WhseRegisterActivityYesNo.DocumentPosted; // P8000322A
        Rec.Reset();
        Rec.SetCurrentKey("Activity Type", "No.", "Sorting Sequence No.");
        Rec.FilterGroup(4);
        Rec.SetRange("Activity Type", Rec."Activity Type");
        Rec.SetRange("No.", Rec."No.");
        Rec.FilterGroup(3);
        Rec.SetRange(Breakbulk, false);
        Rec.FilterGroup(0);
        CurrPage.Update(false);

        OnAfterRegisterActivityYesNo(Rec);
    end;

    local procedure ShowBinContents()
    var
        BinContent: Record "Bin Content";
    begin
        BinContent.ShowBinContents(Rec."Location Code", Rec."Item No.", Rec."Variant Code", '')
    end;

    local procedure EnableZoneBin()
    var
        PlaceLineForConsumption: Boolean;
    begin
        PlaceLineForConsumption :=
          (Rec."Action Type" = Rec."Action Type"::Place) and
          (Rec."Source Document" in ["Warehouse Activity Source Document"::"Prod. Consumption",
                                     "Warehouse Activity Source Document"::"Assembly Consumption",
                                     "Warehouse Activity Source Document"::"Job Usage"]) and
          (Rec."Whse. Document Type" in ["Warehouse Activity Document Type"::Production,
                                         "Warehouse Activity Document Type"::Assembly,
                                         "Warehouse Activity Document Type"::Job]);

        ZoneCodeEditable :=
          (Rec."Action Type" = Rec."Action Type"::Take) or (Rec."Breakbulk No." <> 0) or PlaceLineForConsumption;
        BinCodeEditable :=
          (Rec."Action Type" = Rec."Action Type"::Take) or (Rec."Breakbulk No." <> 0) or PlaceLineForConsumption;
    end;

    local procedure SerialNoOnAfterValidate()
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ExpDate: Date;
        EntriesExist: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSerialNoOnAfterValidate(Rec, IsHandled);
        if IsHandled then
            exit;

        if Rec."Serial No." <> '' then
            ExpDate := ItemTrackingMgt.ExistingExpirationDate(Rec, false, EntriesExist);

        if ExpDate <> 0D then
            Rec."Expiration Date" := ExpDate;

        CurrPage.SaveRecord; // P8000282A
    end;

    local procedure LotNoOnAfterValidate()
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ExpDate: Date;
        EntriesExist: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeLotNoOnAfterValidate(Rec, IsHandled);
        if IsHandled then
            exit;

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
        RunFromOrderShip := OrderShip; // P8000322A
    end;

    procedure PickPosted(): Boolean
    begin
        exit(Posted); // P8000322A
    end;

    local procedure QtytoHandleAltOnAfterValidate()
    begin
        // PR8000282A
        CurrPage.SaveRecord;
        AltQtyMgmt.ValidateWhseActAltQtyLine(Rec);
        CurrPage.Update;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAutofillQtyToHandleOnBeforeRecAutofillQtyToHandle(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLotNoOnAfterValidate(var Rec: Record "Warehouse Activity Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSerialNoOnAfterValidate(var Rec: Record "Warehouse Activity Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRegisterActivityYesNo(var WarehouseActivityLine: Record "Warehouse Activity Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegisterActivityYesNo(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;
}

