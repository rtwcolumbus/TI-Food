page 6501 "Item Tracking Entries"
{
    // PR2.00
    //   Add lot tracing menu item
    //   Controls for physical count
    // 
    // PR3.60
    //   Add fields/logic for alternate unit of measure
    //   Add Release Date
    // 
    // PR3.60.01
    //   Change caption properties for Source Name and Remaining Quantity
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 26 JUN 07
    //   Add Item Tracing to Item Tracking Entry menu, remove Lot Tracing
    // 
    // PRW16.00.03
    // P8000817, VerticalSoft, Jack Reynolds, 26 APR 10
    //   Change visible property of fields
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Item Tracking Entries';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Entry';
    SaveValues = true;
    SourceTable = "Item Ledger Entry";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Positive; Positive)
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies whether the item in the item ledge entry is positive.';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the document number on the entry. The document is the voucher that the entry was based on, for example, a receipt.';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the number of the item in the entry.';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies a description of the entry.';
                    Visible = false;
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies a serial number if the posted item carries such a number.';
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies a lot number if the posted item carries such a number.';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the code for the location that the entry is linked to.';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the number of units of the item in the item entry.';
                }
                field("Remaining Quantity"; "Remaining Quantity")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the quantity in the Quantity field that remains to be processed.';
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Remaining Quantity (Alt.)"; "Remaining Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the source type that applies to the source number, shown in the Source No. field.';
                    Visible = false;
                }
                field("Release Date"; "Release Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Warranty Date"; "Warranty Date")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the last day of warranty for the item on the line.';
                }
                field("Expiration Date"; "Expiration Date")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the last date that the item on the line can be used.';
                }
                field(SourceName; SourceName)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Source Name';
                    Visible = false;
                }
                field(GetCostingRemQty; GetCostingRemQty)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Remaining Quantity (Costing)';
                    Visible = false;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
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
            group("&Item Tracking Entry")
            {
                Caption = '&Item Tracking Entry';
                Image = Entry;
                action("Serial No. Information Card")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Serial No. Information Card';
                    Image = SNInfo;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Serial No. Information Card";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Serial No." = FIELD("Serial No.");
                    ToolTip = 'View or edit detailed information about the serial number.';
                }
                action("Lot No. Information Card")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Lot No. Information Card';
                    Image = LotInfo;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Lot No. Information Card";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Lot No." = FIELD("Lot No.");
                    ToolTip = 'View or edit detailed information about the lot number.';
                }
                action("Package No. Information Card")
                {
                    Caption = 'Package No. Information Card';
                    Image = SNInfo;
                    RunObject = Page "Package No. Information List";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Variant Code" = FIELD("Variant Code"),
                                  "Package No." = FIELD("Package No.");
                    ToolTip = 'View or edit detailed information about the package number.';
                }
                action("&Item Tracing")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Item Tracing';
                    Image = ItemTracing;
                    ShortCutKey = 'Ctrl+T';

                    trigger OnAction()
                    begin
                        OpenItemTracing; // P8000466A
                    end;
                }
            }
        }
        area(processing)
        {
            action("&Navigate")
            {
                ApplicationArea = ItemTracking;
                Caption = 'Find entries...';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Category4;
                ShortCutKey = 'Shift+Ctrl+I';
                ToolTip = 'Find entries and documents that exist for the document number and posting date on the selected document. (Formerly this action was named Navigate.)';

                trigger OnAction()
                begin
                    Navigate.SetDoc("Posting Date", "Document No.");
                    Navigate.Run;
                end;
            }
        }
    }

    var
        Navigate: Page Navigate;
}

