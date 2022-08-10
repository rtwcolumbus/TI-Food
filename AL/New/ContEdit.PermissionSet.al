permissionset 37002030 "FOOD Cont-Edit"
{
    Access = Public;
    Assignable = true;
    Caption = 'Edit Containers';

    Permissions = tabledata Allergen = R,
                  tabledata "Allergen Set Entry" = R,
                  tabledata "Allergen Set History" = R,
                  tabledata "Allergen Set Tree Node" = R,
                  tabledata "Container Comment Line" = R,
                  tabledata "Container Header" = RIMD,
                  tabledata "Container Ledger Entry" = RIMD,
                  tabledata "Container Line" = RIMD,
                  tabledata "Container Line Application" = R,
                  tabledata "Container Register" = RIMD,
                  tabledata "Container Type" = R,
                  tabledata "Container Type Charge" = RIMD,
                  tabledata "Container Type Usage" = R,
                  tabledata "Shipped Container Header" = R;
}
