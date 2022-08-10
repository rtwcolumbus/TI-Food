page 37002017 "Alternate Item List"
{
    // PRW15.00.01
    // P8000589A, VerticalSoft, Don Bresee, 05 MAR 08
    //   Add alternate sales items by Customer
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 30 JAN 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.03
    // P8000788, VerticalSoft, Rick Tweedle, 29 MAR 10
    //   Upgraded using TIF Tool

    Caption = 'Alternate Item List';
    DataCaptionFields = "Sales Item No.";
    Editable = false;
    PageType = List;
    SourceTable = "Customer Item Alternate";
    SourceTableView = WHERE("Alternate Item No." = FILTER(<> ''));

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Alternate Item No."; "Alternate Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Alternate Item Description"; "Alternate Item Description")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
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
}

