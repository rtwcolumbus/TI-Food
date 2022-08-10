permissionset 37002233 "FOOD Warehouse Mgt-Admin"
{
    Access = Public;
    Assignable = false;
    Caption = 'Whse Mgt. setup (FOOD)';

    Permissions = tabledata "Clear Bin History" = RIMD,
                  tabledata "Directed Pick Exclusion" = RIMD,
                  tabledata "Item Fixed Prod. Bin" = RIMD,
                  tabledata "Item Replenishment Area" = RIMD,
                  tabledata "Replenishment Area" = RIMD;
}
