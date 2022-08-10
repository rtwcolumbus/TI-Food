permissionset 37002020 "FOOD Consumption Journals-Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'Create entries in Cons. Jnl. (FOOD)';

    Permissions = tabledata Allergen = R,
                  tabledata "Allergen Set Entry" = R,
                  tabledata "Allergen Set History" = R,
                  tabledata "Allergen Set Tree Node" = R,
                  tabledata "Alternate Quantity Line" = RIMD,
                  tabledata "Container Comment Line" = RIMD,
                  tabledata "Container Header" = RIMD,
                  tabledata "Container Line" = RIMD,
                  tabledata "Item Slot" = R,
                  tabledata "Item Status Entry" = R,
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
                  tabledata "Value Entry ABC Detail" = R,
                  tabledata Variant = R,
                  tabledata "Vendor Certification" = R,
                  tabledata "Vendor Certification Type" = R;
}
