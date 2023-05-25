page 37002597 "Shipped Container Subpage"
{
    // PRW18.00.02
    // P8004554, To-Increase, Jack Reynolds, 27 OCT 15
    //   Support for Delivery Trip History

    Caption = 'Shipped Container Subpage';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Shipped Container Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
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

