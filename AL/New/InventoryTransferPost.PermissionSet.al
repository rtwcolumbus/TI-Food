permissionset 37002145 "FOOD Inventory Transfer-Post"
{
    Access = Public;
    Assignable = false;
    Caption = 'Post transfer orders (FOOD)';

    Permissions = tabledata "Alternate Quantity Entry" = RIMD,
                  tabledata "Alternate Quantity Line" = RIMD,
                  tabledata "Container Charge" = RIMD,
                  tabledata "Container Comment Line" = RIMD,
                  tabledata "Container Header" = RIMD,
                  tabledata "Container Line" = RIMD,
                  tabledata "Container Line Application" = RIMD,
                  tabledata "Container Type" = R,
                  tabledata "Container Type Charge" = RIMD,
                  tabledata "Container Type Usage" = R,
                  tabledata "Data Collection Alert" = RIMD,
                  tabledata "Data Sheet Header" = RIMD,
                  tabledata "Data Sheet Line" = RIMD,
                  tabledata "Data Sheet Line Detail" = RIMD,
                  tabledata "Document Extra Charge" = RIMD,
                  tabledata "Extra Charge" = R,
                  tabledata "Extra Charge Posting Setup" = RIMD,
                  tabledata "Item Slot" = R,
                  tabledata "Item Status Entry" = RIMD,
                  tabledata "Lot Status Code" = R,
                  tabledata "Posted Document Extra Charge" = RIMD,
                  tabledata "Purchasing Group" = R,
                  tabledata "Shipped Container Header" = RIMD,
                  tabledata "Shipped Container Line" = RIMD,
                  tabledata "Supply Chain Group" = R,
                  tabledata "Supply Chain Group User" = R,
                  tabledata "Usage Formula" = R,
                  tabledata "Value Entry ABC Detail" = RIMD,
                  tabledata "Value Entry Extra Charge" = R,
                  tabledata Variant = R;
}
