page 37002538 "Pre-Process Activity List"
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
    Caption = 'Pre-Process Activity List';
    CardPageID = "Pre-Process Activity";
    Editable = false;
    PageType = List;
    SourceTable = "Pre-Process Activity";
    UsageCategory = Lists;

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
                }
                field("Quantity (Base)"; "Quantity (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Remaining Quantity"; "Remaining Quantity")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Remaining Qty. (Base)"; "Remaining Qty. (Base)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("To Bin Code"; "To Bin Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("From Bin Code"; "From Bin Code")
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
                Enabled = ProdOrderExists;
                Image = Production;
                Promoted = true;
                PromotedCategory = Process;
                ShortCutKey = 'Shift+F7';

                trigger OnAction()
                begin
                    ShowProdOrder("Prod. Order Status", "Prod. Order No.");
                end;
            }
            action("Blending Order")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Blending Order';
                Enabled = BlendingOrderExists;
                Image = GetLines;
                Promoted = true;
                PromotedCategory = Process;
                ShortCutKey = 'Ctrl+B';

                trigger OnAction()
                begin
                    ShowProdOrder("Blending Order Status", "Blending Order No.");
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
            separator(Separator37002013)
            {
            }
            action("Warehouse Entries")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Warehouse Entries';
                Image = BinLedger;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Warehouse Entries";
                RunPageLink = "Source No." = FIELD("No.");
                RunPageView = SORTING("Source Type", "Source Subtype", "Source No.")
                              WHERE("Source Type" = CONST(37002494),
                                    "Source Subtype" = CONST("0"));
                ShortCutKey = 'Ctrl+F7';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        BlendingOrderExists := ("Blending Order No." <> '');
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        ProdOrderExists := Find(Which);
        BlendingOrderExists := false;
        exit(ProdOrderExists);
    end;

    var
        [InDataSet]
        ProdOrderExists: Boolean;
        [InDataSet]
        BlendingOrderExists: Boolean;
}

