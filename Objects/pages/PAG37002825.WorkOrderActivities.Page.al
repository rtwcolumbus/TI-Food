page 37002825 "Work Order Activities"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard list style form for work order activities
    // 
    // PRW15.00.02
    // P8000618A, VerticalSoft, Jack Reynolds, 04 AUG 08
    //   RENAMED - was "Work Order Activites"
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 04 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Work Order Activities';
    DataCaptionFields = "Work Order No.";
    Editable = false;
    PageType = List;
    SourceTable = "Work Order Activity";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Work Order No."; "Work Order No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Trade Code"; "Trade Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Planned Hours"; "Planned Hours")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Rate (Hourly)"; "Rate (Hourly)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Planned Cost"; "Planned Cost")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Actual Hours"; "Actual Hours")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Actual Cost"; "Actual Cost")
                {
                    ApplicationArea = FOODBasic;
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

