page 37002126 "Accrual Payment Group Card"
{
    // PR3.61AC
    // 
    // PRW15.00.02
    // P8000613A, VerticalSoft, Jack Reynolds, 18 JUL 08
    //   Fix button placement
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 03 NOV 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Accrual Payment Group Card';
    PageType = ListPlus;
    SourceTable = "Accrual Payment Group";

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
            }
            part(Control37002003; "Accrual Payment Group Subform")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Accrual Payment Group" = FIELD(Code);
                SubPageView = SORTING("Accrual Payment Group", "Line No.");
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

