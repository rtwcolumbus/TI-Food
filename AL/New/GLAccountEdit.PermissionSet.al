permissionset 37002132 "FOOD G/L Account-Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'Edit G/L accounts (FOOD)';

    Permissions = tabledata "Ledger Entry Comment Line" = RM;
}
