page 37002840 "PM Materials"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 01 SEP 06
    //   Standard list style form for PM order materials
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 05 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'PM Materials';
    Editable = false;
    PageType = List;
    SourceTable = "PM Material";

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
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Part No."; "Part No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Planned Quantity"; "Planned Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit Cost"; "Unit Cost")
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

