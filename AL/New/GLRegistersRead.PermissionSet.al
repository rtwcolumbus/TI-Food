permissionset 37002130 "FOOD G/L Registers-Read"
{
    Access = Public;
    Assignable = false;
    Caption = 'Read G/L registers (FOOD)';

    Permissions = tabledata "Ledger Entry Comment Line" = R;
}
