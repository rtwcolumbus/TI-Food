permissionset 37002074 "FOOD D365 WHSE, SETUP"
{
    Access = Public;
    Assignable = false;
    Caption = 'Dynamics 365 Setup warehouse (FOOD)';

    Permissions = tabledata "Clear Bin History" = RIMD,
                  tabledata "Directed Pick Exclusion" = RIMD,
                  tabledata "Item Fixed Prod. Bin" = RIMD,
                  tabledata "Item Replenishment Area" = RIMD,
                  tabledata "Replenishment Area" = RIMD,
                  tabledata "Whse. Staged Pick Header" = R,
                  tabledata "Whse. Staged Pick Line" = R,
                  tabledata "Whse. Staged Pick Source Line" = R;
}
