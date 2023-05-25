page 5799 "Registered Pick Subform"
{
    // --------------------------------------------------------------------------------
    // To-Increase B.V. - www.to-increase.com
    // --------------------------------------------------------------------------------
    // ID          Date        Description
    // --------------------------------------------------------------------------------
    // N138F0000 , 09-10-2014, Initial Version
    // --------------------------------------------------------------------------------
    // 
    // PR4.00.04
    // P8000322A, Don Bresee, 29 JUL 06
    //   Add Undo field/routine.
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW19.00.01
    // P8006916, To-Increase, Dayakar Battini, 16 JUN 16
    //   FOOD-TOM Separation delete Transsmart objects

    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    Editable = false;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Registered Whse. Activity Line";

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
                    ToolTip = 'Specifies the action you must perform for the items on the line.';
                    Visible = false;
                }
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
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the date when the warehouse activity must be completed.';
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the serial number that was handled.';
                    Visible = false;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the lot number that was handled.';
                    Visible = false;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the expiration date of the serial number that was handled.';
                    Visible = false;
                }
                field("Shelf No."; Rec."Shelf No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the shelf number of the item on the line for information use.';
                    Visible = false;
                }
                field("Zone Code"; Rec."Zone Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the code of the zone in which the bin on this line is located.';
                    Visible = false;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the bin where the items are picked or put away.';
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the item number of the item to be handled, such as picked or put away.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies a description of the item on the line.';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies a description of the item on the line.';
                    Visible = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity of the item that was put-away, picked or moved.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Container License Plate"; "Container License Plate")
                {
                    AccessByPermission = TableData "Container Header" = R;
                    ApplicationArea = FOODBasic;
                }
                field("Qty. Undone (Base)"; "Qty. Undone (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
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
                action("Whse. Document Line")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Whse. Document Line';
                    Image = Line;
                    ToolTip = 'View the line on another warehouse document that the warehouse activity is for.';

                    trigger OnAction()
                    begin
                        WMSMgt.ShowWhseActivityDocLine("Whse. Document Type", "Whse. Document No.", "Whse. Document Line No.");
                    end;
                }
                action("Posted Warehouse Shipment Line")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Posted Warehouse Shipment Line';
                    Image = PostedShipment;
                    ToolTip = 'View the related line on the posted warehouse shipment.';

                    trigger OnAction()
                    begin
                        ShowPostedWhseShptLine();
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
                action("Undo Selected Lines")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Undo Selected Lines';
                    Ellipsis = true;

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #5798. Unsupported part was commented. Please check it.
                        /*CurrPage.WhseActivityLines.PAGE.*/
                        UndoWhseActLines; // P8000322A

                    end;
                }
            }
            group("P&ick")
            {
                Caption = 'P&ick';
                Image = CreateInventoryPickup;
                action("&Warehouse Entries")
                {
                    ApplicationArea = Warehouse;
                    Caption = '&Warehouse Entries';
                    Image = BinLedger;
                    ToolTip = 'View the history of quantities that are registered for the item in warehouse activities. ';

                    trigger OnAction()
                    var
                        RegisteredWhseActivityHdr: Record "Registered Whse. Activity Hdr.";
                    begin
                        RegisteredWhseActivityHdr.Get("Activity Type", "No.");
                        ShowWhseEntries(RegisteredWhseActivityHdr."Registering Date");
                    end;
                }
            }
        }
    }

    var
        WMSMgt: Codeunit "WMS Management";
        UndoWhseActivity: Codeunit "Undo Whse. Activity";

    local procedure ShowSourceLine()
    begin
        WMSMgt.ShowSourceDocLine(
          "Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
    end;

    local procedure ShowBinContents()
    var
        BinContent: Record "Bin Content";
    begin
        BinContent.ShowBinContents("Location Code", "Item No.", "Variant Code", "Bin Code");
    end;

    local procedure ShowPostedWhseShptLine()
    begin
        WMSMgt.ShowPostedWhseShptLine("Whse. Document No.", "Whse. Document Line No.");
    end;

    procedure UndoWhseActLines()
    var
        RegWhseActLine: Record "Registered Whse. Activity Line";
    begin
        // P8000322A
        CurrPage.SetSelectionFilter(RegWhseActLine);
        UndoWhseActivity.Run(RegWhseActLine);
        CurrPage.Update(false);
    end;
}

