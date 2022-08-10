page 37002682 "Comm. Class Cost Components"
{
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 03 NOV 10
    //   Add Commodity Class Costing granule

    Caption = 'Commodity Class Cost Components';
    PageType = List;
    SourceTable = "Comm. Cost Setup Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Commodity Class Code"; "Commodity Class Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Comm. Cost Component Code"; "Comm. Cost Component Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Comm. Cost Comp. Description"; "Comm. Cost Comp. Description")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
            }
        }
    }

    actions
    {
    }
}

