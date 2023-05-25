page 37002124 "Accrual Posting Groups"
{
    // PR3.61AC
    // 
    // PR4.00
    // P8000246A, Myers Nissi, Jack Reynolds, 05 OCT 05
    //   Add controls for Sales Account (Accrual) and Purch. Account (Accrual)
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 30 JAN 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.10.03
    // P8001308, Columbus IT, Jack Reynolds, 01 APR 14
    //   Fix problem posting purcahse lines with type of Accrual Plan
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    ApplicationArea = FOODBasic;
    Caption = 'Accrual Posting Groups';
    PageType = List;
    SourceTable = "Accrual Posting Group";
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
                field("Sales Plan Account"; "Sales Plan Account")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sales Account (Accrual)"; "Sales Account (Accrual)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Purchase Plan Account"; "Purchase Plan Account")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Purch. Account (Accrual)"; "Purch. Account (Accrual)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Accrual Account"; "Accrual Account")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
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

