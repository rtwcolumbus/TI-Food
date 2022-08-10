permissionset 37002024 "FOOD Cont-Admin"
{
    Access = Public;
    Assignable = true;
    Caption = 'Setup Containers';

    Permissions = tabledata "Container Charge" = RIMD,
                  tabledata "Container Comment Line" = RIMD,
                  tabledata "Container Header" = RIMD,
                  tabledata "Container Journal Batch" = RIMD,
                  tabledata "Container Journal Template" = RIMD,
                  tabledata "Container Ledger Entry" = R,
                  tabledata "Container Line" = RIMD,
                  tabledata "Container Line Application" = R,
                  tabledata "Container Register" = R,
                  tabledata "Container Type" = RIMD,
                  tabledata "Container Type Usage" = RIMD,
                  tabledata "Shipped Container Header" = R,
                  tabledata "Shipped Container Line" = RIMD;
}
