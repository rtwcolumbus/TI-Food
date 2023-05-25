page 37002176 "Cost Calculation Method List"
{
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Added for extended cost based sales pricing mechanism
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Cost Calculation Methods';
    CardPageID = "Cost Calculation Method Card";
    Editable = false;
    PageType = List;
    SourceTable = "Cost Calculation Method";
    UsageCategory = Administration;

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
                    Visible = false;
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
                separator(Separator37002022)
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

