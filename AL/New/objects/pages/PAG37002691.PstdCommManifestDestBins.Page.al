page 37002691 "Pstd. Comm. Manifest Dest.Bins"
{
    // PRW16.00.04
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic

    Caption = 'Pstd. Comm. Manifest Dest.Bins';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Pstd. Comm. Manifest Dest. Bin";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupBin;
                    end;
                }
                field(Quantity; Quantity)
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

