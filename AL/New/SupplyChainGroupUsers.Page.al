page 37002161 "Supply Chain Group Users"
{
    // PRW16.00.05
    // P8000931, Columbus IT, Jack Reynolds, 20 APR 11
    //   Support for Supply Chain Groups

    Caption = 'Supply Chain Group Users';
    PageType = List;
    SourceTable = "Supply Chain Group User";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User ID"; "User ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Supply Chain Group Code"; "Supply Chain Group Code")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }
}

