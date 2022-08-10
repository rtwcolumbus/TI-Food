page 37002043 "Recurring Price Template Card"
{
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Add Cost Calculation Method and Rounding Method
    //   Remove Special Price field
    // 
    // PRW15.00.01
    // P8000613A, VerticalSoft, Jack Reynolds, 23 JUL 08
    //   Move generated prices subform off of tab page and onto main form
    // 
    // P8000761, VerticalSoft, Maria Maslennikova, 03 FEB 10
    //   Code changed in the UpdateForm() method to be correctly transformed into 2009
    //   Page: Field Control37002004 (Generated Prices) deleted
    // 
    // PRW16.00.04
    // P8000912, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Fix problem creating new records
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Recurring Price Template Card';
    DataCaptionExpression = GetCaption;
    DelayedInsert = true;
    PageType = Document;
    PopulateAllFields = true;
    SourceTable = "Recurring Price Template";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Sales Type"; "Sales Type")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        //SalesTypeOnAfterValidate; // P8000912
                        InsertRecord; // P8000912
                        UpdateForm;   // P8000912
                    end;
                }
                field("Sales Code"; "Sales Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Sales CodeEditable";

                    trigger OnValidate()
                    begin
                        InsertRecord; // P8000912
                    end;
                }
                field("Item Type"; "Item Type")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        //ItemTypeOnAfterValidate; // P8000912
                        InsertRecord; // P8000912
                        UpdateForm;   // P8000912
                    end;
                }
                field("Item Code"; "Item Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Item Code 1Editable";

                    trigger OnValidate()
                    begin
                        //ItemCode1OnAfterValidate; // P8000912
                        InsertRecord; // P8000912
                        UpdateForm;   // P8000912
                    end;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
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
                field("Next Date"; "Next Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pricing Frequency"; "Pricing Frequency")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Allow Invoice Disc."; "Allow Invoice Disc.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Allow Line Disc."; "Allow Line Disc.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("VAT Bus. Posting Gr. (Price)"; "VAT Bus. Posting Gr. (Price)")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(Prices; "Price Template Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Generated Prices';
                Editable = false;
                SubPageLink = "Template ID" = FIELD("Template ID");
                SubPageView = SORTING("Template ID", "Starting Date", "Ending Date");
            }
            group("Price Calculation")
            {
                Caption = 'Price Calculation';
                field("Price Type"; "Price Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pricing Method"; "Pricing Method")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        //PricingMethodOnAfterValidate; // P8000912
                        UpdateForm; // P8000912
                    end;
                }
                field("Cost Adjustment"; "Cost Adjustment")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Cost AdjustmentEditable";
                }
                field("Cost Reference"; "Cost Reference")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Cost ReferenceEditable";

                    trigger OnValidate()
                    begin
                        //CostReferenceOnAfterValidate; // P8000912
                        UpdateForm; // P8000912
                    end;
                }
                field("Cost Calc. Method Code"; "Cost Calc. Method Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Cost Calc. Method CodeEditable";
                }
                field("Price Rounding Method"; "Price Rounding Method")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Price Rounding MethodEditable";
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Unit PriceEditable";
                }
                field("Minimum Quantity"; "Minimum Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Maximum Quantity"; "Maximum Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Use Break Charge"; "Use Break Charge")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Generate Fixed Item Prices"; "Generate Fixed Item Prices")
                {
                    ApplicationArea = FOODBasic;
                    Editable = GenerateFixedItemPricesEditabl;
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

    trigger OnAfterGetRecord()
    begin
        UpdateForm;
    end;

    trigger OnInit()
    begin
        GenerateFixedItemPricesEditabl := true;
        "Price Rounding MethodEditable" := true;
        "Cost ReferenceEditable" := true;
        "Cost AdjustmentEditable" := true;
        "Item Code 1Editable" := true;
        "Sales CodeEditable" := true;
        "Unit PriceEditable" := true;
        "Cost Calc. Method CodeEditable" := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        UpdateForm;
    end;

    var
        Cust: Record Customer;
        CustPriceGr: Record "Customer Price Group";
        ItemSalesPriceMgmt: Codeunit "Item Sales Price Management";
        [InDataSet]
        "Cost Calc. Method CodeEditable": Boolean;
        [InDataSet]
        "Unit PriceEditable": Boolean;
        [InDataSet]
        "Sales CodeEditable": Boolean;
        [InDataSet]
        "Item Code 1Editable": Boolean;
        [InDataSet]
        "Cost AdjustmentEditable": Boolean;
        [InDataSet]
        "Cost ReferenceEditable": Boolean;
        [InDataSet]
        "Price Rounding MethodEditable": Boolean;
        [InDataSet]
        GenerateFixedItemPricesEditabl: Boolean;
        Text19038097: Label 'Generated Prices';

    local procedure GetCaption() TemplateDescription: Text[250]
    begin
        // P8000912
        //IF ("Template ID" = 0) AND
        //   (("Sales Type" = "Sales Type"::"All Customers") OR ("Sales Code" <> '')) AND
        //   (("Item Type" = "Item Type"::"All Items") OR ("Item Code 1" <> '')) AND
        //   (("Item Type" <> "Item Type"::"Product Group") OR ("Item Code 2" <> ''))
        //THEN
        //  CurrPage.SAVERECORD;
        // P8000912
        exit(GetDescription());
    end;

    procedure InsertRecord()
    begin
        // P8000912
        if ("Template ID" = 0) and
           (("Sales Type" = "Sales Type"::"All Customers") or ("Sales Code" <> '')) and
           (("Item Type" = "Item Type"::"All Items") or ("Item Code" <> ''))
        then
            CurrPage.SaveRecord;
    end;

    local procedure UpdateForm()
    begin
        "Sales CodeEditable" := "Sales Type" <> "Sales Type"::"All Customers";
        "Item Code 1Editable" := "Item Type" <> "Item Type"::"All Items";
        "Cost AdjustmentEditable" := "Pricing Method" <> "Pricing Method"::"Fixed Amount";
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
        "Unit PriceEditable" := "Pricing Method" = "Pricing Method"::"Fixed Amount";
        GenerateFixedItemPricesEditabl := "Pricing Method" <> "Pricing Method"::"Fixed Amount";
    end;
}

