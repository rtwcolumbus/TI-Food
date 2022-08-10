permissionset 37002170 "FOOD Manufacturing-Admin"
{
    Access = Public;
    Assignable = false;
    Caption = 'Setup Manufacturing (FOOD)';

    Permissions = tabledata "Extra Charge" = R,
                  tabledata "Item Slot" = R,
                  tabledata "Lot Age Category" = R,
                  tabledata "Lot Age Filter" = R,
                  tabledata "Lot Age Profile Category" = R,
                  tabledata "Lot Freshness" = R,
                  tabledata "Lot No. Custom Format" = R,
                  tabledata "Lot No. Custom Format Line" = R,
                  tabledata "Lot No. Segment" = R,
                  tabledata "Lot No. Segment Value" = R,
                  tabledata "Lot Specification Filter" = R,
                  tabledata "Lot Status Code" = R,
                  tabledata "Process Setup" = RIMD,
                  tabledata "Purchasing Group" = R,
                  tabledata "Supply Chain Group" = R,
                  tabledata "Supply Chain Group User" = R,
                  tabledata "Usage Formula" = R,
                  tabledata Variant = R,
                  tabledata "Vendor Certification" = R,
                  tabledata "Vendor Certification Type" = R;
}
