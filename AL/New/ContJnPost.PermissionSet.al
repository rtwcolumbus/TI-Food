permissionset 37002023 "FOOD Cont Jn-Post"
{
    Access = Public;
    Assignable = true;
    Caption = 'Post Cont. Jnl.';

    Permissions = tabledata "Container Header" = R,
                  tabledata "Container Journal Batch" = RIMD,
                  tabledata "Container Journal Line" = RIMD,
                  tabledata "Container Journal Template" = RIMD,
                  tabledata "Container Ledger Entry" = RIMD,
                  tabledata "Container Line" = R,
                  tabledata "Container Register" = RIMD,
                  tabledata "Container Type" = RIMD,
                  tabledata "Container Type Usage" = RIMD,
                  tabledata "Shipped Container Line" = RIMD;
}
