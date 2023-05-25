page 37002587 "Reg. Pre-Process Activity List"
{
    // PRW16.00.06
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Add Pre-Process functionality
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Reg. Pre-Process Activity List';
    CardPageID = "Reg. Pre-Process Activity";
    Editable = false;
    PageType = List;
    SourceTable = "Reg. Pre-Process Activity";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Prod. Order Status"; "Prod. Order Status")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Prod. Order No."; "Prod. Order No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Prod. Order BOM No."; "Prod. Order BOM No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Replenishment Area Code"; "Replenishment Area Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Quantity (Base)"; "Quantity (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Quantity Processed"; "Quantity Processed")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. Processed (Base)"; "Qty. Processed (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("To-Bin Code"; "To-Bin Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("From-Bin Code"; "From-Bin Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Pre-Process Type Code"; "Pre-Process Type Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Blending; Blending)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Order Specific"; "Order Specific")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Auto Complete"; "Auto Complete")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Blending Order Status"; "Blending Order Status")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Blending Order No."; "Blending Order No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002019; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002016; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Prod. Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Prod. Order';
                Image = Production;
                ShortCutKey = 'Shift+F7';

                trigger OnAction()
                begin
                    Activity.ShowProdOrder("Prod. Order Status", "Prod. Order No.");
                end;
            }
            action("Blending Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Blending Order';
                Enabled = BlendingOrderExists;
                Image = GetLines;
                ShortCutKey = 'Ctrl+B';

                trigger OnAction()
                begin
                    Activity.ShowProdOrder("Blending Order Status", "Blending Order No.");
                end;
            }
            action(Item)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item';
                Image = Item;
                RunObject = Page "Item Card";
                RunPageLink = "No." = FIELD("Item No.");
                RunPageMode = View;
            }
            separator(Separator37002006)
            {
            }
            action("Warehouse Entries")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Warehouse Entries';
                Image = BinLedger;
                RunObject = Page "Warehouse Entries";
                RunPageLink = "Source No." = FIELD("No.");
                RunPageView = SORTING("Source Type", "Source Subtype", "Source No.")
                              WHERE("Source Type" = CONST(37002494),
                                    "Source Subtype" = CONST("0"));
                ShortCutKey = 'Ctrl+F7';
            }
        }
        area(Promoted)
        {
            actionref(ProdOrder_Promoted; "Prod. Order")
            {
            }
            actionref(BlendingOrder_Promoted; "Blending Order")
            {
            }
            actionref(WarehouseEntries_Promoted; "Warehouse Entries")
            {
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        BlendingOrderExists := ("Blending Order No." <> '');
    end;

    var
        Activity: Record "Pre-Process Activity";
        [InDataSet]
        BlendingOrderExists: Boolean;
}

