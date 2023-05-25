page 37002184 "Sales Contract Price Subform"
{
    // PRW17.10.03
    // P8001321, Columbus IT, Jack Reynolds, 12 MAY 14
    //   Fix problem with contract prices for item categoreis and product groups
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 03 NOV 16
    //   Item Category/Product Group
    //
    // PRW115.00.03
    // P800121970, To-Increase, Gangabhushan, 20 APR 21
    //   CS00155486 | FW: Sales Contract - Filter warnings


    Caption = 'Sales Contract Price Subform';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Sales Price";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Special Price"; "Special Price")
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
                        xRec := Rec;
                        UpdateItemFields;
                    end;
                }
                field("Cost Reference"; "Cost Reference")
                {
                    ApplicationArea = FOODBasic;
                    Editable = CostRefEditable;

                    trigger OnValidate()
                    begin
                        xRec := Rec;
                        UpdateItemFields;
                    end;
                }
                field("Cost Calc. Method Code"; "Cost Calc. Method Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = CostCalcMethodCodeEditable;
                }
                field("Price Rounding Method"; "Price Rounding Method")
                {
                    ApplicationArea = FOODBasic;
                    Editable = PriceRoundingMethodEditable;
                    Visible = false;
                }
                field("Cost Adjustment"; "Cost Adjustment")
                {
                    ApplicationArea = FOODBasic;
                    Editable = CostAdjEditable;
                    // P800121970
                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                    end;
                    // P800121970
                }                
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = FOODBasic;
                    Editable = UnitPriceEditable;
                    // P800121970
                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                    end;
                    // P800121970                    
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
                field("Allow Line Disc."; "Allow Line Disc.")
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
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateItemFields; // P8001321
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        // P8001321
        FilterGroup(4);
        ItemCode := GetRangeMin("Item Code");
        FilterGroup(0);

        exit(Find(Which));
        // P8001321
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Contract No." := ConNo;
        "Item Code" := ItemCode; // P8001321
        "Sales Type" := SalesType;
        "Sales Code" := SalesCode;
        "Starting Date" := StartDate;
        "Ending Date" := EndDate;
    end;

    trigger OnOpenPage()
    begin
        UpdateItemFields;
    end;

    var
        ConNo: Code[20];
        ItemCode: Code[20];
        SalesType: Integer;
        SalesCode: Code[20];
        StartDate: Date;
        EndDate: Date;
        [InDataSet]
        CostCalcMethodCodeEditable: Boolean;
        [InDataSet]
        UnitPriceEditable: Boolean;
        [InDataSet]
        CostAdjEditable: Boolean;
        [InDataSet]
        CostRefEditable: Boolean;
        [InDataSet]
        PriceRoundingMethodEditable: Boolean;

    procedure SetContract(SalesContract: Record "Sales Contract")
    begin
        ConNo := SalesContract."No.";
        SalesType := SalesContract."Sales Type";
        SalesCode := SalesContract."Sales Code";
        StartDate := SalesContract."Starting Date";
        EndDate := SalesContract."Ending Date";
    end;

    local procedure UpdateItemFields()
    begin
        CostAdjEditable := "Pricing Method" <> "Pricing Method"::"Fixed Amount";
        CostRefEditable := "Pricing Method" <> "Pricing Method"::"Fixed Amount";
        CostCalcMethodCodeEditable := (
          ("Pricing Method" <> "Pricing Method"::"Fixed Amount") and
          ("Cost Reference" = "Cost Reference"::"Cost Calc. Method"));
        PriceRoundingMethodEditable := "Pricing Method" <> "Pricing Method"::"Fixed Amount";
        UnitPriceEditable := "Pricing Method" = "Pricing Method"::"Fixed Amount";
    end;
}

