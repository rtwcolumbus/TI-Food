query 37002922 "Allergen Presence-Unapproved"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens

    Caption = 'Allergen Presence-Unapproved';

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
                dataitem(UnapprovedItem; "Unapproved Item")
                {
                    DataItemLink = "Allergen Set ID" = AllergenSetEntry."Allergen Set ID";
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

