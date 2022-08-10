permissionset 37002075 "FOOD D365 WHSE, VIEW"
{
    Access = Public;
    Assignable = false;
    Caption = 'Dynamics 365 View warehouse (FOOD)';

    Permissions = tabledata Allergen = R,
                  tabledata "Allergen Set Entry" = R,
                  tabledata "Allergen Set History" = R,
                  tabledata "Allergen Set Tree Node" = R,
                  tabledata "Clear Bin History" = R,
                  tabledata "Container Charge" = RIMD,
                  tabledata "Container Comment Line" = RIMD,
                  tabledata "Container Header" = RIMD,
                  tabledata "Container Line" = RIMD,
                  tabledata "Container Line Application" = RIMD,
                  tabledata "Container Type" = R,
                  tabledata "Container Type Charge" = RIMD,
                  tabledata "Container Type Usage" = R,
                  tabledata "Directed Pick Exclusion" = R,
                  tabledata "Item Fixed Prod. Bin" = R,
                  tabledata "Item Replenishment Area" = R,
                  tabledata "Replenishment Area" = R,
                  tabledata "Shipped Container Header" = RIMD,
                  tabledata "Shipped Container Line" = RIMD,
                  tabledata "Whse. Staged Pick Header" = RIMD,
                  tabledata "Whse. Staged Pick Line" = RIMD,
                  tabledata "Whse. Staged Pick Source Line" = RIMD;
}
