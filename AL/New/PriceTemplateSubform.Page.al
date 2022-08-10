page 37002045 "Price Template Subform"
{
    // PR3.10.P *TEMP*
    //   Integrate 3.60 Sales Pricing and Line Discounts
    // 
    // PR3.10.P
    //   Sales Pricing - Add Sales Unit Price and Break Charge
    // 
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Add Cost Calculation Method and Rounding Method
    // 
    // PRW15.00.02
    // P8000613A, VerticalSoft, Jack Reynolds, 18 JUL 08
    //   Resize to fit subform control on parent form
    // 
    // PRW16.00.04
    // P8000912, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Fix problem with display for new template records
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    Caption = 'Price Template Subform';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Sales Price";

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
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
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Price Type"; "Price Type")
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
                field("Cost Reference"; "Cost Reference")
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
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Use Break Charge"; "Use Break Charge")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Price Includes VAT"; "Price Includes VAT")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
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
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        TemplateID: Integer;
    begin
        // P8000912
        FilterGroup(4);
        TemplateID := GetRangeMax("Template ID");
        FilterGroup(0);
        if TemplateID = 0 then
            exit(false);
        exit(Find(Which));
        // P8000912
    end;
}

