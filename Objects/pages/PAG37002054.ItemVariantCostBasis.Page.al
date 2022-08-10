page 37002054 "Item Variant Cost Basis"
{
    // PR4.00
    // P8000245B, Myers Nissi, Jack Reynolds, 04 OCT 05
    //   Subform for display and editing of market prices for item variants
    // 
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Add Cost Basis Code
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 30 JAN 09
    //   Transformed from Form
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Item Variant Cost Basis';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Item Variant";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(LastMarketPrice; LastMarketPrice)
                {
                    ApplicationArea = FOODBasic;
                    AutoFormatExpression = CostBasis."Currency Code";
                    AutoFormatType = 2;
                    BlankZero = true;
                    Caption = 'Last Cost Value';
                    DecimalPlaces = 2 : 5;
                    Editable = false;
                }
                field(LastMarketPriceDate; LastMarketPriceDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Last Cost Value Date';
                    Editable = false;
                }
                field("Cost Value"; MarketPrice)
                {
                    ApplicationArea = FOODBasic;
                    AutoFormatExpression = CostBasis."Currency Code";
                    AutoFormatType = 2;
                    BlankZero = true;
                    Caption = 'Cost Value';
                    DecimalPlaces = 2 : 5;

                    trigger OnDrillDown()
                    begin
                        ItemMarketPrice.GetCostValueAsOf(CostBasisCode, "Item No.", Code, CostDate); // P8000539A
                        ItemMarketPrice.Reset;
                        ItemMarketPrice.SetRange("Cost Basis Code", CostBasisCode); // P8000539A
                        ItemMarketPrice.SetRange("Item No.", "Item No.");
                        ItemMarketPrice.SetRange("Variant Code", Code);
                        PAGE.RunModal(0, ItemMarketPrice);
                    end;

                    trigger OnValidate()
                    begin
                        ItemMarketPrice.SetCostValue(CostBasisCode, "Item No.", Code, CostDate, MarketPrice); // P8000539A
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        MarketPrice := ItemMarketPrice.GetCostValue(CostBasisCode, "Item No.", Code, CostDate); // P8000539A

        LastMarketPrice := ItemMarketPrice.GetCostValueBefore(CostBasisCode, "Item No.", Code, CostDate); // P8000539A
        LastMarketPriceDate := ItemMarketPrice."Cost Date";
    end;

    trigger OnInit()
    begin
        CostDate := WorkDate;
    end;

    var
        ItemMarketPrice: Record "Item Cost Basis";
        CostDate: Date;
        LastMarketPrice: Decimal;
        LastMarketPriceDate: Date;
        MarketPrice: Decimal;
        CostBasisCode: Code[20];
        CostBasis: Record "Cost Basis";

    procedure SetCostDate(CostBasisCode2: Code[20]; Date: Date)
    begin
        // P8000539A
        CostBasisCode := CostBasisCode2;
        if not CostBasis.Get(CostBasisCode) then
            Clear(CostBasis);
        // P8000539A
        CostDate := Date;
    end;
}

