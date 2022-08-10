page 37002044 "Recurring Price Template List"
{
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Add Cost Calculation Method and Rounding Method
    //   Remove Special Price field
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Recurring Price Templates';
    CardPageID = "Recurring Price Template Card";
    DataCaptionExpression = GetCaption;
    Editable = false;
    PageType = List;
    SourceTable = "Recurring Price Template";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Next Date"; "Next Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pricing Frequency"; "Pricing Frequency")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sales Type"; "Sales Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sales Code"; "Sales Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Item Type"; "Item Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item Code"; "Item Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Price Type"; "Price Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Minimum Quantity"; "Minimum Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Maximum Quantity"; "Maximum Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pricing Method"; "Pricing Method")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Cost Adjustment"; "Cost Adjustment")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Cost Calc. Method Code"; "Cost Calc. Method Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Price Rounding Method"; "Price Rounding Method")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Cost Reference"; "Cost Reference")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Use Break Charge"; "Use Break Charge")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Allow Invoice Disc."; "Allow Invoice Disc.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("VAT Bus. Posting Gr. (Price)"; "VAT Bus. Posting Gr. (Price)")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Allow Line Disc."; "Allow Line Disc.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    local procedure GetCaption() TemplateDescription: Text[250]
    begin
        if (GetFilter("Sales Type") <> '') then
            TemplateDescription :=
              DelChr(
                StrSubstNo('%1 %2', GetFilter("Sales Type"), GetFilter("Sales Code")),
                '>');

        if (GetFilter("Item Type") <> '') then begin
            if (TemplateDescription <> '') then
                TemplateDescription := TemplateDescription + ' / ';
            TemplateDescription := TemplateDescription +
              DelChr(
                StrSubstNo(
                  '%1 %2', GetFilter("Item Type"), GetFilter("Item Code")), // P8007749
                '>');
        end;
    end;
}

