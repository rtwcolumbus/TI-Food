page 37002928 "Allergens For Item"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens

    Caption = 'Allergens For Item';
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "Allergen Set Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Allergen Code"; "Allergen Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Allergen Description"; "Allergen Description")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Presence; Presence)
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

