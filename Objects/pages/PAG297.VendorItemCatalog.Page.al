page 297 "Vendor Item Catalog"
{
    // PRW17.10
    // P8001230, Columbus IT, Jack Reynolds, 18 OCT 13
    //   Support for approved vendors

    Caption = 'Vendor Item Catalog';
    DataCaptionFields = "Vendor No.";
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Prices & Discounts';
    SourceTable = "Item Vendor";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the number of the vendor who offers the alternate direct unit cost.';
                    Visible = false;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the number of the item that the alternate direct unit cost is valid for.';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field("Vendor Item No."; "Vendor Item No.")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the number that the vendor uses for this item.';
                }
                field("Lead Time Calculation"; "Lead Time Calculation")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies a date formula for the amount of time it takes to replenish the item.';
                }
                field(Approved; Approved)
                {
                    ApplicationArea = FOODBasic;
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
            group("Ve&ndor Item")
            {
                Caption = 'Ve&ndor Item';
                Image = Item;
#if not CLEAN19
                action("Purch. Prices")
                {
                    ApplicationArea = Planning;
                    Caption = 'Purch. Prices';
                    Image = Price;
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = not ExtendedPriceEnabled;
                    RunObject = Page "Purchase Prices";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Vendor No." = FIELD("Vendor No.");
                    RunPageView = SORTING("Item No.", "Vendor No.");
                    ToolTip = 'Define purchase price agreements with vendors for specific items.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                    ObsoleteTag = '18.0';
                }
                action("P&urch. Line Discounts")
                {
                    ApplicationArea = Planning;
                    Caption = 'P&urch. Line Discounts';
                    Image = LineDiscount;
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = not ExtendedPriceEnabled;
                    RunObject = Page "Purchase Line Discounts";
                    RunPageLink = "Item No." = FIELD("Item No."),
                                  "Vendor No." = FIELD("Vendor No.");
                    ToolTip = 'Define purchase line discounts with vendors. For example, you may get for a line discount if you buy items from a vendor in large quantities.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                    ObsoleteTag = '18.0';
                }
#endif
                action(Prices)
                {
                    AccessByPermission = TableData "Purchase Price Access" = R;
                    ApplicationArea = Planning;
                    Caption = 'Purchase Prices';
                    Image = Price;
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = ExtendedPriceEnabled;
                    ToolTip = 'Define purchase price agreements with vendors for specific items.';

                    trigger OnAction()
                    begin
                        Rec.ShowPriceListLines("Price Amount Type"::Price);
                    end;
                }
                action(Discounts)
                {
                    AccessByPermission = TableData "Purchase Discount Access" = R;
                    ApplicationArea = Planning;
                    Caption = 'Purchase Discounts';
                    Image = LineDiscount;
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = ExtendedPriceEnabled;
                    ToolTip = 'Define purchase line discounts with vendors. For example, you may get for a line discount if you buy items from a vendor in large quantities.';

                    trigger OnAction()
                    begin
                        Rec.ShowPriceListLines("Price Amount Type"::Discount);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
    begin
        ExtendedPriceEnabled := PriceCalculationMgt.IsExtendedPriceCalculationEnabled();
    end;

    var
        ExtendedPriceEnabled: Boolean;
}

