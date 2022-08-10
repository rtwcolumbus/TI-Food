page 37002687 "Comm. Manifest Dest. Bins"
{
    // PRW16.00.04
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic

    Caption = 'Comm. Manifest Dest. Bins';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Commodity Manifest Dest. Bin";

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
                        exit(LookupBin(Text));
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

