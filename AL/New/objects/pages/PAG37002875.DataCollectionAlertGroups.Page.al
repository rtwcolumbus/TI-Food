page 37002875 "Data Collection Alert Groups"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Data Collection Alert Groups';
    PageType = List;
    SourceTable = "Data Collection Alert Group";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
            systempart(Control37002005; Links)
            {
                ApplicationArea = FOODBasic;
            }
            systempart(Control37002006; Notes)
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Members)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Members';
                Image = Users;
                RunObject = Page "Data Coll. Alert Group Members";
                RunPageLink = "Group Code" = FIELD(Code);
            }
        }
        area(Promoted)
        {
            actionref(Members_Promoted; Members)
            {
            }
        }
    }
}

