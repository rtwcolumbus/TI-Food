permissionset 37002031 "FOOD Cont-View"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read Containers and Entries';

    Permissions = tabledata Allergen = R,
                  tabledata "Allergen Set Entry" = R,
                  tabledata "Allergen Set History" = R,
                  tabledata "Allergen Set Tree Node" = R,
                  tabledata "Container Header" = R,
                  tabledata "Container Ledger Entry" = R,
                  tabledata "Container Line" = R,
                  tabledata "Container Line Application" = R,
                  tabledata "Container Register" = R,
                  tabledata "Container Type" = R,
                  tabledata "Container Type Charge" = R,
                  tabledata "Container Type Usage" = R,
                  tabledata "Shipped Container Header" = R;
}
