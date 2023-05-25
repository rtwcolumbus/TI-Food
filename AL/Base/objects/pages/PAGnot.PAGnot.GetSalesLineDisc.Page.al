#if not CLEAN21
page 7009 "Get Sales Line Disc."
{
    // PR3.60
    //   Sales Line Discount Changes
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    Caption = 'Get Sales Line Disc.';
    Editable = false;
    PageType = List;
    SourceTable = "Sales Line Discount";
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
                    ToolTip = 'Specifies the sales type of the sales line discount. The sales type defines whether the sales price is for an individual customer, customer discount group, all customers, or for a campaign.';
                }
                field("Sales Code"; Rec."Sales Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies one of the following values, depending on the value in the Sales Type field.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the currency code of the sales line discount price.';
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
                field("Variant Code"; Rec."Variant Code")
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
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the minimum quantity that the customer must purchase in order to gain the agreed discount.';
                }
                field("Line Discount Type"; Rec."Line Discount Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the discount percentage to use to calculate the sales line discount.';
                }
                field("Line Discount Amount"; Rec."Line Discount Amount")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sales Line Discount %"; Rec."Sales Line Discount %")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date from which the sales line discount is valid.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date to which the sales line discount is valid.';
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
