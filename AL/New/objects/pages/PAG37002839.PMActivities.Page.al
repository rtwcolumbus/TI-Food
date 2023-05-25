page 37002839 "PM Activities"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard list style form for PM order activities
    // 
    // PRW15.00.02
    // P8000618A, VerticalSoft, Jack Reynolds, 04 AUG 08
    //   RENAMEED - was "PM Activites"
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 05 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'PM Activities';
    Editable = false;
    PageType = List;
    SourceTable = "PM Activity";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field(AssetNo; AssetNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Asset No.';
                }
                field(FrequencyCode; FrequencyCode)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Frequency Code';
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

