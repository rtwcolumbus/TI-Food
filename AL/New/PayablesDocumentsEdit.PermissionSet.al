permissionset 37002191 "FOOD Payables Documents-Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'Create purchase orders, etc. (FOOD)';

    Permissions = tabledata "Accrual Charge" = RIMD,
                  tabledata "Accrual Charge Line" = RIMD,
                  tabledata "Accrual Computation Group" = RIMD,
                  tabledata "Accrual Group" = RIMD,
                  tabledata "Accrual Group Line" = RIMD,
                  tabledata "Accrual Journal Batch" = RIMD,
                  tabledata "Accrual Journal Line" = RIMD,
                  tabledata "Accrual Journal Template" = RIMD,
                  tabledata "Accrual Ledger Entry" = RIMD,
                  tabledata "Accrual Payment Group" = RIMD,
                  tabledata "Accrual Payment Group Line" = RIMD,
                  tabledata "Accrual Plan" = RIMD,
                  tabledata "Accrual Plan Line" = RIMD,
                  tabledata "Accrual Plan Schedule Line" = RIMD,
                  tabledata "Accrual Plan Search Line" = RIMD,
                  tabledata "Accrual Plan Source Line" = RIMD,
                  tabledata "Accrual Posting Group" = RIMD,
                  tabledata "Accrual Register" = RIMD,
                  tabledata "Accrual Setup" = RIMD,
                  tabledata Allergen = R,
                  tabledata "Allergen Set Entry" = R,
                  tabledata "Allergen Set History" = R,
                  tabledata "Allergen Set Tree Node" = R,
                  tabledata "Alternate Quantity Entry" = R,
                  tabledata "Alternate Quantity Line" = RIMD,
                  tabledata "Automatic Lot No." = RIMD,
                  tabledata "Comm. Cost Component" = RIMD,
                  tabledata "Comm. Cost Setup Line" = RIMD,
                  tabledata "Commodity Class" = RIMD,
                  tabledata "Commodity Cost Entry" = RIMD,
                  tabledata "Commodity Cost Period" = RIMD,
                  tabledata "Commodity Manifest Dest. Bin" = RIMD,
                  tabledata "Commodity Manifest Header" = RIMD,
                  tabledata "Commodity Manifest Line" = RIMD,
                  tabledata "Container Charge" = RIMD,
                  tabledata "Container Comment Line" = RIMD,
                  tabledata "Container Header" = RIMD,
                  tabledata "Container Line" = RIMD,
                  tabledata "Container Line Application" = RIMD,
                  tabledata "Container Type" = R,
                  tabledata "Container Type Charge" = RIMD,
                  tabledata "Container Type Usage" = R,
                  tabledata "Document Accrual Line" = RIMD,
                  tabledata "Document Extra Charge" = RIMD,
                  tabledata "Extra Charge" = R,
                  tabledata "Extra Charge Posting Setup" = RIMD,
                  tabledata "Hauler Charge" = RIMD,
                  tabledata "Item Slot" = R,
                  tabledata "Item Status Entry" = R,
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
                  tabledata "Pickup Load Header" = RIMD,
                  tabledata "Pickup Load Line" = RIMD,
                  tabledata "Pickup Location" = RIMD,
                  tabledata "Posted Comm. Manifest Header" = RIMD,
                  tabledata "Posted Comm. Manifest Line" = RIMD,
                  tabledata "Posted Document Accrual Line" = RIMD,
                  tabledata "Posted Document Extra Charge" = RIMD,
                  tabledata "Producer Zone" = RIMD,
                  tabledata "Pstd. Comm. Manifest Dest. Bin" = RIMD,
                  tabledata "Purchasing Group" = R,
                  tabledata "Shipped Container Header" = RIMD,
                  tabledata "Shipped Container Line" = RIMD,
                  tabledata "Supply Chain Group" = R,
                  tabledata "Supply Chain Group User" = R,
                  tabledata "Usage Formula" = R,
                  tabledata "Value Entry Extra Charge" = R,
                  tabledata Variant = R,
                  tabledata "Vendor Certification" = R,
                  tabledata "Vendor Certification Type" = R;
}
