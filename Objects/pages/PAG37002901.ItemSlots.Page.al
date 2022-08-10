page 37002901 "Item Slots"
{
    // PRW16.00.05
    // P8000968, Columbus IT, Jack Reynolds, 16 AUG 11
    //   List page for Item Slots

    Caption = 'Item Slots';
    DataCaptionFields = "Item No.";
    PageType = List;
    SourceTable = "Item Slot";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Slot No."; "Slot No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002006; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002007; Notes)
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

