page 37002174 "Cost Basis List"
{
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Added for extended cost based sales pricing mechanism
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW116.00.05
    // P800103616, To-Increase, Gangabhushan, 04 FEB 21
    //  Enhance inventory costing with Book Cost          

    ApplicationArea = FOODBasic;
    Caption = 'Cost Bases';
    PageType = List;
    SourceTable = "Cost Basis";
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
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Calc. Codeunit ID"; "Calc. Codeunit ID")
                {
                    ApplicationArea = FOODBasic;
                    LookupPageID = Objects;
                }
                field(CodeunitName; Process800Utility.GetObjectCaption(5, "Calc. Codeunit ID"))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Codeunit Name';
                }
                field("Reference Cost Basis Code"; "Reference Cost Basis Code")
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
            group("Cost Basis")
            {
                Caption = '&Cost Basis';
                action("Item Cost &Values")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Cost &Values';
                    Image = ItemCosts;

                    trigger OnAction()
                    var
                        CostBasisList: Page "Item Cost Basis List";
                    begin
                        TestField(Code);
                        CostBasisList.SetCostDate(Code, WorkDate);
                        CostBasisList.Run;
                    end;
                }
                action("Calc. Cost Values")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Calc. Cost Values';
                    Ellipsis = true;
                    Image = CalculateCost;

                    trigger OnAction()
                    var
                        CalcCostReport: Report "Calc. Cost Basis Values";
                    begin
                        TestField(Code);
                        TestField("Calc. Codeunit ID");
                        CalcCostReport.SetCostBasisCode(Code);
                        CalcCostReport.RunModal;
                    end;
                }
                action("Cost Basis Adjustments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Cost Basis Adjustments';
                    Image = CostBudget;
                    Runobject = Page "Cost Basis Adjustments";
                    RunPageLink = "Cost Basis Code" = field(Code);
                    Enabled = ("Reference Cost Basis Code" <> '');
                }
            }
        }
    }

    var
        Process800Utility: Codeunit "Process 800 Utility Functions";

    trigger OnOpenPage()
    begin
        CurrPage.Editable(not CurrPage.LookupMode);
    end;
}

