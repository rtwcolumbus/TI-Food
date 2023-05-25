#if not CLEAN21
page 7007 "Get Sales Price"
{
    // PR3.60
    //   Sales Pricing - Add Sales Unit Price and Break Charge
    // 
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Add Cost Calculation Method and Rounding Method
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    Caption = 'Get Sales Price';
    Editable = false;
    PageType = List;
    SourceTable = "Sales Price";
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
    ObsoleteTag = '16.0';

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Sales Type"; Rec."Sales Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sales price type, which defines whether the price is for an individual, group, all customers, or a campaign.';
                }
                field("Sales Code"; Rec."Sales Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code that belongs to the Sales Type.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code for the currency of the sales price.';
                    Visible = false;
                }
                field("Item Type"; Rec."Item Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item Code"; Rec."Item Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Special Price"; Rec."Special Price")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Price Type"; Rec."Price Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the minimum sales quantity required to warrant the sales price.';
                }
                field("Maximum Quantity"; Rec."Maximum Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pricing Method"; Rec."Pricing Method")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Cost Adjustment"; Rec."Cost Adjustment")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Cost Reference"; Rec."Cost Reference")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Cost Calc. Method Code"; Rec."Cost Calc. Method Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the price of one unit of the item or resource. You can enter a price manually or have it entered according to the Price/Profit Calculation field on the related card.';
                }
                field("Break Charge"; Rec."Break Charge")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Price Rounding Method"; Rec."Price Rounding Method")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Sales Unit Price"; Rec."Sales Unit Price")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sales Currency Code"; Rec."Sales Currency Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date from which the sales price is valid.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the calendar date when the sales price agreement ends.';
                }
                field("Use Break Charge"; Rec."Use Break Charge")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Price Includes VAT"; Rec."Price Includes VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the sales price includes VAT.';
                    Visible = false;
                }
                field("Allow Invoice Disc."; Rec."Allow Invoice Disc.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if an invoice discount will be calculated when the sales price is offered.';
                    Visible = false;
                }
                field("VAT Bus. Posting Gr. (Price)"; Rec."VAT Bus. Posting Gr. (Price)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT business posting group for customers for whom you want the sales price (which includes VAT) to apply.';
                    Visible = false;
                }
                field("Allow Line Disc."; Rec."Allow Line Disc.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if a line discount will be calculated when the sales price is offered.';
                    Visible = false;
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
    }
}
#endif
