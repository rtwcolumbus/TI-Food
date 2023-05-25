page 37002717 "Posted Sales Payment Subpage"
{
    // PRW16.00.05
    // P8000941, Columbus IT, Don Bresee, 25 JUL 11
    //   Sales Payments granule

    Caption = 'Posted Sales Payment Subpage';
    PageType = ListPart;
    SourceTable = "Posted Sales Payment Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Amount; Amount)
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

