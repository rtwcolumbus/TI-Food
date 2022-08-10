permissionset 37002021 "FOOD Consumption Journals-Post"
{
    Access = Public;
    Assignable = false;
    Caption = 'Post Cons. Jnl. (FOOD)';

    Permissions = tabledata "Alternate Quantity Line" = RIMD,
                  tabledata "Container Comment Line" = RIMD,
                  tabledata "Container Header" = RIMD,
                  tabledata "Container Ledger Entry" = RIMD,
                  tabledata "Container Line" = RIMD,
                  tabledata "Container Register" = RIMD,
                  tabledata "Container Type" = R,
                  tabledata "Container Type Usage" = R,
                  tabledata "Item Slot" = R,
                  tabledata "Item Status Entry" = RIMD,
                  tabledata "Lot Age Category" = R,
                  tabledata "Lot Age Filter" = R,
                  tabledata "Lot Age Profile" = R,
                  tabledata "Lot Age Profile Category" = R,
                  tabledata "Lot Freshness" = R,
                  tabledata "Lot Specification Filter" = R,
                  tabledata "Lot Status Code" = R,
                  tabledata "Process Setup" = R,
                  tabledata "Prod. BOM Activity Cost" = R,
                  tabledata "Prod. BOM Equipment" = R,
                  tabledata "Purchasing Group" = R,
                  tabledata "Supply Chain Group" = R,
                  tabledata "Supply Chain Group User" = R,
                  tabledata "Usage Formula" = R,
                  tabledata "Value Entry ABC Detail" = RIMD,
                  tabledata Variant = R,
                  tabledata "Vendor Certification" = R,
                  tabledata "Vendor Certification Type" = R;
}
