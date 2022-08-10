page 37002125 "Accrual Payment Groups"
{
    // PR3.61AC
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Accrual Payment Groups';
    CardPageID = "Accrual Payment Group Card";
    Editable = false;
    PageType = List;
    SourceTable = "Accrual Payment Group";
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
            action(Setup)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Setup';
                Ellipsis = true;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Accrual Payment Group Card";
                RunPageLink = Code = FIELD(Code);
            }
        }
    }
}

