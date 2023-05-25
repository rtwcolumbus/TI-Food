page 37002876 "Data Coll. Alert Group Members"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection

    Caption = 'Data Collection Alert Group Members';
    DataCaptionFields = "Group Code";
    PageType = List;
    SourceTable = "Data Coll. Alert Group Member";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("User ID"; "User ID")
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
    }
}

