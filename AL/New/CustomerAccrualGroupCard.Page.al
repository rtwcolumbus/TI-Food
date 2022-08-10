page 37002133 "Customer Accrual Group Card"
{
    // PR3.61AC
    // 
    // PRW16.00.03
    // P8000828, VerticalSoft, Don Bresee, 09 JUN 10
    //   Add caption to Subform part
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Customer Accrual Group Card';
    PageType = Card;
    SourceTable = "Accrual Group";
    SourceTableView = WHERE(Type = CONST(Customer));

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
            part(Customers; "Accrual Group Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Customers';
                SubPageLink = "Accrual Group Type" = FIELD(Type),
                              "Accrual Group Code" = FIELD(Code);
                SubPageView = SORTING("Accrual Group Type", "Accrual Group Code", "No.");
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

