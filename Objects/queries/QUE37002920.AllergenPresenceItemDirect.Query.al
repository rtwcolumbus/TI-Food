query 37002920 "Allergen Presence-Item-Direct"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens

    Caption = 'Allergen Presence-Item-Direct';

    elements
    {
        dataitem(Allergen; Allergen)
        {
            column("Code"; "Code")
            {
            }
            dataitem(AllergenSetEntry; "Allergen Set Entry")
            {
                DataItemLink = "Allergen ID" = Allergen."Allergen ID";
                SqlJoinType = InnerJoin;
                column(Presence; Presence)
                {
                }
                dataitem(Item; Item)
                {
                    DataItemLink = "Direct Allergen Set ID" = AllergenSetEntry."Allergen Set ID";
                    SqlJoinType = InnerJoin;
                    column(No; "No.")
                    {
                    }
                    column(Description; Description)
                    {
                    }
                }
            }
        }
    }
}

