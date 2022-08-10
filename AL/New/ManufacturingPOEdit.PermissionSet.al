permissionset 37002175 "FOOD Manufacturing PO-Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'Edit production order (FOOD)';

    Permissions = tabledata Allergen = R,
                  tabledata "Allergen Set Entry" = R,
                  tabledata "Allergen Set History" = R,
                  tabledata "Allergen Set Tree Node" = R,
                  tabledata "Alternate Quantity Entry" = R,
                  tabledata "Alternate Quantity Line" = RIMD,
                  tabledata "Clear Bin History" = RIMD,
                  tabledata "Extra Charge" = R,
                  tabledata "Item Fixed Prod. Bin" = RIMD,
                  tabledata "Item Replenishment Area" = RIMD,
                  tabledata "Item Slot" = R,
                  tabledata "Item Status Entry" = R,
                  tabledata "Item Variant Variable" = RIMD,
                  tabledata "Lot Age Category" = R,
                  tabledata "Lot Age Filter" = R,
                  tabledata "Lot Age Profile" = R,
                  tabledata "Lot Age Profile Category" = R,
                  tabledata "Lot Freshness" = R,
                  tabledata "Lot No. Custom Format" = R,
                  tabledata "Lot No. Custom Format Line" = R,
                  tabledata "Lot No. Segment" = R,
                  tabledata "Lot No. Segment Value" = R,
                  tabledata "Lot Specification Filter" = R,
                  tabledata "Lot Status Code" = R,
                  tabledata "Package Variable" = RIMD,
                  tabledata "Pre-Process Activity" = RIMD,
                  tabledata "Pre-Process Activity Line" = RIMD,
                  tabledata "Pre-Process Type" = R,
                  tabledata "Process Setup" = R,
                  tabledata "Prod. BOM Activity Cost" = R,
                  tabledata "Prod. BOM Equipment" = R,
                  tabledata "Production Order XRef" = RIMD,
                  tabledata "Production Sequence" = RIMD,
                  tabledata "Purchasing Group" = R,
                  tabledata "Reg. Pre-Process Activity" = RIMD,
                  tabledata "Reg. Pre-Process Activity Line" = RIMD,
                  tabledata "Repack Order" = RIMD,
                  tabledata "Repack Order Comment Line" = RIMD,
                  tabledata "Repack Order Line" = RIMD,
                  tabledata "Replenishment Area" = RIMD,
                  tabledata "Supply Chain Group" = R,
                  tabledata "Supply Chain Group User" = R,
                  tabledata "Usage Formula" = R,
                  tabledata Variant = R,
                  tabledata "Vendor Certification" = R,
                  tabledata "Vendor Certification Type" = R;
}
