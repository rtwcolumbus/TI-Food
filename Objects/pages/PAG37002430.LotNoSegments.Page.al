page 37002430 "Lot No. Segments"
{
    // PRW17.10
    // P8001234, Columbus IT, Jack Reynolds, 01 NOV 13
    //    Support for custom lot number formats

    Caption = 'Lot No. Segments';
    Editable = false;
    PageType = List;
    SourceTable = "Lot No. Segment";
    SourceTableView = SORTING("Sequence No.");

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
    }

    actions
    {
    }
}

