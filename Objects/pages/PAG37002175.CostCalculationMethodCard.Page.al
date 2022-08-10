page 37002175 "Cost Calculation Method Card"
{
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Added for extended cost based sales pricing mechanism

    Caption = 'Cost Calculation Method Card';
    PageType = Card;
    SourceTable = "Cost Calculation Method";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Cost Basis Code"; "Cost Basis Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Cost Date Formula"; "Cost Date Formula")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Day of Week Restriction"; "Day of Week Restriction")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Calculate; Calculate)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Calculation Period"; "Calculation Period")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Cost Calc. Item No."; "Cost Calc. Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Cost Calc.")
            {
                Caption = '&Cost Calc.';
                separator(Separator37002020)
                {
                }
                action("Cost Conversion &Factors")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Cost Conversion &Factors';
                    Image = UnitConversions;

                    trigger OnAction()
                    var
                        ItemCostFactorForm: Page "Item Cost Conversion Factors";
                    begin
                        TestField("Cost Calc. Item No.");
                        ItemCostFactorForm.SetCostCalcItemNo("Cost Calc. Item No.");
                        ItemCostFactorForm.Run;
                    end;
                }
            }
        }
    }
}

