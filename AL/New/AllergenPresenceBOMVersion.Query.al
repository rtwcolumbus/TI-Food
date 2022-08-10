query 37002923 "Allergen Presence-BOM Version"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens

    Caption = 'Allergen Presence-BOM Version';

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
                dataitem(ProductionBOMVersion; "Production BOM Version")
                {
                    DataItemLink = "Direct Allergen Set ID" = AllergenSetEntry."Allergen Set ID";
                    SqlJoinType = InnerJoin;
                    column(ProductionBOMNo; "Production BOM No.")
                    {
                    }
                    column(VersionCode; "Version Code")
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

