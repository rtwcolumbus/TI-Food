page 7316 "Warehouse Movement Subform"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW111.00.01
    // P80061239, To Increase, Jack Reynolds, 31 JUL 18
    //   Run Bin Status from warehouse document pages

    Caption = 'Lines';
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Warehouse Activity Line";
    SourceTableView = SORTING("Activity Type", "No.", "Sorting Sequence No.")
                      WHERE("Activity Type" = CONST(Movement));

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
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the lot number to handle in the document.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        LotNoOnAfterValidate();
                    end;
                }
                field("Package No."; Rec."Package No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the package number to handle in the document.';
                    Visible = PackageTrackingVisible;

                    trigger OnValidate()
                    begin
                        PackageNoOnAfterValidate();
                    end;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = ItemTracking;
                    Editable = false;
                    ToolTip = 'Specifies the expiration date of the serial/lot numbers if you are putting items away.';
                    Visible = false;
                }
                field("Zone Code"; Rec."Zone Code")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Zone Code';
                    ToolTip = 'Specifies the zone code where the bin on this line is located.';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Bin Code';
                    ToolTip = 'Specifies the bin where items on the line are handled.';

                    trigger OnValidate()
                    begin
                        BinCodeOnAfterValidate();
                    end;
                }
                field("Special Equipment Code"; Rec."Special Equipment Code")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Special Equipment Code';
                    ToolTip = 'Specifies the code of the equipment required when you perform the action on the line.';
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
                field("Container License Plate"; Rec."Container License Plate")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        // P8001323
                        exit(ContainerFns.LookupContainerOnWhseLine(Rec, FieldNo("Container License Plate"), Text));
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.Update; // P8001347
                    end;
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
                    Editable = false;
                }
                field("Qty. to Handle (Base)"; Rec."Qty. to Handle (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity of items to be handled in this warehouse activity.';
                    Visible = false;
                }
                field("Qty. Outstanding"; Rec."Qty. Outstanding")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of items that have not yet been handled for this warehouse activity line.';
                }
                field("Qty. Outstanding (Base)"; Rec."Qty. Outstanding (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the number of items, expressed in the base unit of measure, that have not yet been handled for this warehouse activity line.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the date when the warehouse activity must be completed.';
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
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the weight of one item unit when measured in the specified unit of measure.';
                    Visible = false;
                }
                field(Cubage; Rec.Cubage)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the total cubage of items on the line, calculated based on the Quantity field.';
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
                        CurrPage.Update;
                    end;
                }
            }
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
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
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update(false);
    end;

    trigger OnOpenPage()
    begin
        SetPackageTrackingVisibility();
    end;

    var
        PackageTrackingVisible: Boolean;
        ContainerFns: Codeunit "Container Functions";
        AllergenManagement: Codeunit "Allergen Management";

    procedure AutofillQtyToHandle()
    var
        WhseActivLine: Record "Warehouse Activity Line";
    begin
        WhseActivLine.Copy(Rec);
        OnAutofillQtyToHandleOnBeforeRecAutofillQtyToHandle(WhseActivLine);
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

    local procedure ChangeUOM()
    var
        WhseActLine: Record "Warehouse Activity Line";
        WhseChangeOUM: Report "Whse. Change Unit of Measure";
    begin
        Rec.TestField("Action Type");
        Rec.TestField("Breakbulk No.", 0);
        Rec.TestField("Qty. to Handle");
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
    begin
        WhseActivLine.Copy(Rec);
        WhseActivLine.FilterGroup(3);
        WhseActivLine.SetRange(Breakbulk);
        WhseActivLine.FilterGroup(0);
        CODEUNIT.Run(CODEUNIT::"Whse.-Act.-Register (Yes/No)", WhseActivLine);
        Rec.Reset();
        Rec.SetCurrentKey("Activity Type", "No.", "Sorting Sequence No.");
        Rec.FilterGroup(4);
        Rec.SetRange("Activity Type", Rec."Activity Type");
        Rec.SetRange("No.", Rec."No.");
        Rec.FilterGroup(3);
        Rec.SetRange(Breakbulk, false);
        Rec.FilterGroup(0);
        CurrPage.Update(false);
    end;

    local procedure ShowBinContents()
    var
        BinContent: Record "Bin Content";
    begin
        BinContent.ShowBinContents(Rec."Location Code", Rec."Item No.", Rec."Variant Code", '');
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
    end;

    protected procedure PackageNoOnAfterValidate()
    begin
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

    [IntegrationEvent(false, false)]
    local procedure OnAutofillQtyToHandleOnBeforeRecAutofillQtyToHandle(var WarehouseActivityLine: Record "Warehouse Activity Line")
    begin
    end;
}

