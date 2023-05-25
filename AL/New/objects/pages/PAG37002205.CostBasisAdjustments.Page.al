page 37002205 "Cost Basis Adjustments"
{
    // PRW116.00.05
    // P800103616, To-Increase, Gangabhushan, 04 FEB 21
    //  Enhance inventory costing with Book Cost  

    PageType = List;
    ApplicationArea = FOODBasic;
    DataCaptionFields = "Cost Basis Code";
    UsageCategory = Lists;
    SourceTable = "Cost Basis Adjustment";
    SourceTableView = sorting("Calculation Step");

    layout
    {
        area(Content)
        {
            repeater(Adjustments)
            {
                field(CostBasisCode; "Cost Basis Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = False;
                }
                Field(Code; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                Field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                Field(Value; Value)
                {
                    ApplicationArea = FOODBasic;
                }
                field(CalculationStep; "Calculation Step")
                {
                    ApplicationArea = FOODBasic;
                }

            }
        }
        area(factboxes)
        {
            systempart(RecordLinks; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }
}