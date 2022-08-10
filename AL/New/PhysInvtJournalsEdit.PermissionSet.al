permissionset 37002200 "FOOD Phys Invt Journals-Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'Taking a physical inventory (FOOD)';

    Permissions = tabledata Allergen = R,
                  tabledata "Allergen Set Entry" = R,
                  tabledata "Allergen Set History" = R,
                  tabledata "Allergen Set Tree Node" = R,
                  tabledata "Alternate Quantity Entry" = R,
                  tabledata "Alternate Quantity Line" = RIMD,
                  tabledata "Container Charge" = RIMD,
                  tabledata "Container Comment Line" = RIMD,
                  tabledata "Container Header" = RIMD,
                  tabledata "Container Line" = RIMD,
                  tabledata "Container Line Application" = RIMD,
                  tabledata "Container Type" = R,
                  tabledata "Container Type Charge" = RIMD,
                  tabledata "Container Type Usage" = R,
                  tabledata "Item Status Entry" = R,
                  tabledata "Shipped Container Header" = RIMD,
                  tabledata "Shipped Container Line" = RIMD;
}
