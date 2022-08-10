permissionset 37002140 "FOOD Inventory-Admin"
{
    Access = Public;
    Assignable = false;
    Caption = 'Inventory setup (FOOD)';

    Permissions = tabledata Allergen = RIMD,
                  tabledata "Comm. Cost Component" = RIMD,
                  tabledata "Comm. Cost Setup Line" = RIMD,
                  tabledata "Commodity Class" = RIMD,
                  tabledata "Commodity Cost Entry" = RIMD,
                  tabledata "Commodity Cost Period" = RIMD,
                  tabledata "Extra Charge" = RIMD,
                  tabledata "Hauler Charge" = RIMD,
                  tabledata "Item Slot" = RIMD,
                  tabledata "Lot Age Category" = RIMD,
                  tabledata "Lot Age Filter" = RIMD,
                  tabledata "Lot Age Profile" = RIMD,
                  tabledata "Lot Age Profile Category" = RIMD,
                  tabledata "Lot Control Item" = RIMD,
                  tabledata "Lot Freshness" = RIMD,
                  tabledata "Lot No. Custom Format" = RIMD,
                  tabledata "Lot No. Custom Format Line" = RIMD,
                  tabledata "Lot No. Segment" = RIMD,
                  tabledata "Lot No. Segment Value" = RIMD,
                  tabledata "Lot Specification Filter" = RIMD,
                  tabledata "Lot Status Code" = RIMD,
                  tabledata "Producer Zone" = RIMD,
                  tabledata "Purchasing Group" = RIMD,
                  tabledata "Supply Chain Group" = RIMD,
                  tabledata "Supply Chain Group User" = RIMD,
                  tabledata "Usage Formula" = RIMD,
                  tabledata Variant = RIMD,
                  tabledata "Vendor Certification" = RIMD,
                  tabledata "Vendor Certification Type" = RIMD;
}
