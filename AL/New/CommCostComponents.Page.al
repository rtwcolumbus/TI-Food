page 37002681 "Comm. Cost Components"
{
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 03 NOV 10
    //   Add Commodity Class Costing granule
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Comm. Cost Components';
    PageType = List;
    SourceTable = "Comm. Cost Component";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupUOM(Text));
                    end;
                }
                field("Q/C Test Type"; "Q/C Test Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Q/C Test Result Handling"; "Q/C Test Result Handling")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002008; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002007; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

