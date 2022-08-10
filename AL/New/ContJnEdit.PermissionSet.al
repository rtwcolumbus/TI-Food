permissionset 37002022 "FOOD Cont Jn-Edit"
{
    Access = Public;
    Assignable = true;
    Caption = 'Create Entries in Cont. Jnl.';

    Permissions = tabledata "Container Header" = R,
                  tabledata "Container Journal Batch" = RIMD,
                  tabledata "Container Journal Line" = RIMD,
                  tabledata "Container Journal Template" = RIMD,
                  tabledata "Container Ledger Entry" = R,
                  tabledata "Container Line" = R,
                  tabledata "Container Register" = R,
                  tabledata "Container Type" = R,
                  tabledata "Container Type Usage" = R,
                  tabledata "Shipped Container Line" = RIMD;
}
