page 37002059 "Usage Formulas"
{
    // PR4.00.02
    // P8000312A, VerticalSoft, Jack Reynolds, 17 MAR 06
    //   Standard lsit form for Usage Formula table
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 03 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Usage Formulas';
    PageType = List;
    SourceTable = "Usage Formula";
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
                field(Period; Period)
                {
                    ApplicationArea = FOODBasic;
                }
                field("No. of Periods"; "No. of Periods")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Comparison Period Formula"; "Comparison Period Formula")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Rounding Method"; "Rounding Method")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Rounding Precision"; "Rounding Precision")
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

