page 37002924 "Allergen Set History Subpage"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens

    Caption = 'Allergen Set History Subpage';
    Editable = false;
    PageType = ListPart;
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
                    DrillDown = false;
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

