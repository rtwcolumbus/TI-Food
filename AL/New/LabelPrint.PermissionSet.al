permissionset 37002150 "FOOD Label-Print"
{
    Access = Public;
    Assignable = true;
    Caption = 'Print Labels';

    Permissions = tabledata Allergen = R,
                  tabledata "Allergen Set Entry" = R,
                  tabledata "Allergen Set History" = R,
                  tabledata "Allergen Set Tree Node" = R,
                  tabledata "Container Label" = RIMD,
                  tabledata "Item Case Label" = RIMD,
                  tabledata "Label" = R,
                  tabledata "Label Printer Selection" = R,
                  tabledata "Label Selection" = R,
                  tabledata "Label Worksheet Line" = RIMD,
                  tabledata "Ship/Prod. Container Label" = RIMD;
}
