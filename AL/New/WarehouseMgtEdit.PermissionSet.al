permissionset 37002234 "FOOD Warehouse Mgt-Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'Whse. Mgt. periodic activities (FOOD)';

    Permissions = tabledata "Clear Bin History" = RIMD,
                  tabledata "Directed Pick Exclusion" = RIMD,
                  tabledata "Item Fixed Prod. Bin" = RIMD,
                  tabledata "Item Replenishment Area" = RIMD,
                  tabledata "Replenishment Area" = RIMD;
}
