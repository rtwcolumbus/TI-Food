page 37002042 "Enhanced Sales Price Worksheet"
{
    // PR3.60
    // 
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Add Cost Calculation Method and Rounding Method
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // P8000761, VerticalSoft, Maria Maslennikova, 02 FEB 10
    //   Code changed in the UpdateItemFields() method to be correctly transformed into 2009.
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property.
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group

    Caption = 'Sales Price Worksheet';
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Sales Price Worksheet";

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

                    trigger OnValidate()
                    begin
                        UpdateCalculatedPrice; // PR3.60
                    end;
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

                    trigger OnValidate()
                    begin
                        UpdateCalculatedPrice; // PR3.60
                    end;
                }
                field("Item Code"; "Item Code")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        UpdateCalculatedPrice; // PR3.60
                    end;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        UpdateCalculatedPrice; // PR3.60
                    end;
                }
                field("Special Price"; "Special Price")
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

                    trigger OnValidate()
                    begin
                        UpdateItemFields; // PR3.60
                        UpdateCalculatedPrice; // PR3.60
                    end;
                }
                field("Current Cost Adjustment"; "Current Cost Adjustment")
                {
                    ApplicationArea = FOODBasic;
                }
                field("New Cost Adjustment"; "New Cost Adjustment")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "New Cost AdjustmentEditable";

                    trigger OnValidate()
                    begin
                        UpdateCalculatedPrice; // PR3.60
                    end;
                }
                field("Cost Reference"; "Cost Reference")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Cost ReferenceEditable";

                    trigger OnValidate()
                    begin
                        UpdateItemFields; // P8000539A
                        UpdateCalculatedPrice; // PR3.60
                    end;
                }
                field("Cost Calc. Method Code"; "Cost Calc. Method Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Cost Calc. Method CodeEditable";

                    trigger OnValidate()
                    begin
                        UpdateCalculatedPrice; // P8000539A
                    end;
                }
                field("Price Rounding Method"; "Price Rounding Method")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Price Rounding MethodEditable";
                    Visible = false;
                }
                field("Current Unit Price"; "Current Unit Price")
                {
                    ApplicationArea = FOODBasic;
                }
                field("New Unit Price"; "New Unit Price")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "New Unit PriceEditable";

                    trigger OnValidate()
                    begin
                        UpdateCalculatedPrice; // P8000539A
                    end;
                }
                field("Calculated Unit Price"; CalculatedUnitPrice)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Calculated Unit Price';
                    DecimalPlaces = 2 : 5;
                    Editable = false;
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
                field("Price Includes VAT"; "Price Includes VAT")
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
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Suggest &Item Price on Wksh.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Suggest &Item Price on Wksh.';
                    Ellipsis = true;
                    Image = SuggestItemPrice;

                    trigger OnAction()
                    begin
                        REPORT.RunModal(REPORT::"Suggest Item Price on Wksh.", true, true);
                    end;
                }
                action("Suggest &Sales Price on Wksh.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Suggest &Sales Price on Wksh.';
                    Ellipsis = true;
                    Image = SuggestSalesPrice;

                    trigger OnAction()
                    begin
                        REPORT.RunModal(REPORT::"Suggest Sales Price on Wksh.", true, true);
                    end;
                }
                action("Suggest &Recurring Prices on Wksh.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Suggest &Recurring Prices on Wksh.';
                    Ellipsis = true;
                    Image = SuggestSalesPrice;

                    trigger OnAction()
                    begin
                        REPORT.RunModal(REPORT::"Suggest Recurring Prices", true, true);
                    end;
                }
                action("I&mplement Price Change")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'I&mplement Price Change';
                    Ellipsis = true;
                    Image = ImplementPriceChange;

                    trigger OnAction()
                    begin
                        REPORT.RunModal(REPORT::"Implement Price Change", true, true, Rec);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(SuggestItemPriceOnWksh_Promoted; "Suggest &Item Price on Wksh.")
                {
                }
                actionref(SuggestSalesPriceOnWksh_Promoted; "Suggest &Sales Price on Wksh.")
                {
                }
                actionref(SuggestRecurringPricesOnWksh_Promoted; "Suggest &Recurring Prices on Wksh.")
                {
                }
                actionref(ImplementPriceChange_Promoted; "I&mplement Price Change")
                {
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        UpdateItemFields;
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateCalculatedPrice;
    end;

    trigger OnInit()
    begin
        "Price Rounding MethodEditable" := true;
        "Cost ReferenceEditable" := true;
        "New Cost AdjustmentEditable" := true;
        "New Unit PriceEditable" := true;
        "Cost Calc. Method CodeEditable" := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        UpdateCalculatedPrice;
    end;

    var
        ItemSalesPriceMgmt: Codeunit "Item Sales Price Management";
        CalculatedUnitPrice: Decimal;
        [InDataSet]
        "Cost Calc. Method CodeEditable": Boolean;
        [InDataSet]
        "New Unit PriceEditable": Boolean;
        [InDataSet]
        "New Cost AdjustmentEditable": Boolean;
        [InDataSet]
        "Cost ReferenceEditable": Boolean;
        [InDataSet]
        "Price Rounding MethodEditable": Boolean;

    local procedure UpdateItemFields()
    begin
        "New Unit PriceEditable" := "Pricing Method" = "Pricing Method"::"Fixed Amount";
        "New Cost AdjustmentEditable" := "Pricing Method" <> "Pricing Method"::"Fixed Amount";
        "Cost ReferenceEditable" := "Pricing Method" <> "Pricing Method"::"Fixed Amount";
        // P8000539A
        //P8000761 MMAS >>
        //CurrForm."Cost Calc. Method Code".EDITABLE(
        "Cost Calc. Method CodeEditable" := (
        //P8000761 MMAS <<
          ("Pricing Method" <> "Pricing Method"::"Fixed Amount") and
          ("Cost Reference" = "Cost Reference"::"Cost Calc. Method"));
        "Price Rounding MethodEditable" := "Pricing Method" <> "Pricing Method"::"Fixed Amount";
        // P8000539A
    end;

    local procedure UpdateCalculatedPrice()
    var
        SalesPrice: Record "Sales Price";
    begin
        if ("Item Type" <> "Item Type"::Item) or ("Item Code" = '') then
            CalculatedUnitPrice := 0
        else
            if "Pricing Method" = "Pricing Method"::"Fixed Amount" then
                CalculatedUnitPrice := "New Unit Price"
            else begin
                SalesPrice."Starting Date" := "Starting Date";
                SalesPrice."Item No." := "Item Code";
                SalesPrice."Unit of Measure Code" := "Unit of Measure Code";
                SalesPrice."Pricing Method" := "Pricing Method";
                SalesPrice."Cost Reference" := "Cost Reference";
                SalesPrice."Cost Adjustment" := "New Cost Adjustment";
                ItemSalesPriceMgmt.SetPriceSource(SalesPrice, '', 0, 0D);
                ItemSalesPriceMgmt.CalculateCostBasedPrice(SalesPrice);
                CalculatedUnitPrice := SalesPrice."Unit Price";
            end;
    end;
}

