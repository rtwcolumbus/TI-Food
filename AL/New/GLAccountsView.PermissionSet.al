permissionset 37002133 "FOOD G/L Accounts-View"
{
    Access = Public;
    Assignable = false;
    Caption = 'Read G/L accounts and entries (FOOD)';

    Permissions = tabledata "Ledger Entry Comment Line" = R;
}
