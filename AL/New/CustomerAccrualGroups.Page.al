page 37002156 "Customer Accrual Groups"
{
    // PR3.61AC
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 08 FEB 09
    //   New List Page for Customer Accrual Groups Card
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Customer Accrual Groups';
    CardPageID = "Customer Accrual Group Card";
    Editable = false;
    PageType = List;
    SourceTable = "Accrual Group";
    SourceTableView = WHERE(Type = CONST(Customer));
    UsageCategory = Lists;

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
        area(processing)
        {
        }
    }
}

