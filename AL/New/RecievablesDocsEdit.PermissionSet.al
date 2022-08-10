permissionset 37002211 "FOOD Recievables Docs-Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'Create sales orders etc. (FOOD)';

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
                  tabledata "Alternate Quantity Entry" = RIMD,
                  tabledata "Alternate Quantity Line" = RIMD,
                  tabledata "Automatic Lot No." = RIMD,
                  tabledata "Container Charge" = RIMD,
                  tabledata "Container Comment Line" = RIMD,
                  tabledata "Container Header" = RIMD,
                  tabledata "Container Line" = RIMD,
                  tabledata "Container Line Application" = RIMD,
                  tabledata "Container Type" = R,
                  tabledata "Container Type Charge" = RIMD,
                  tabledata "Container Type Usage" = R,
                  tabledata "Cost Basis" = R,
                  tabledata "Cost Basis Adjustment" = R,
                  tabledata "Cost Calculation Method" = R,
                  tabledata "Cust./Item Price/Disc. Group" = R,
                  tabledata "Customer Item Alternate" = RIMD,
                  tabledata "Deduction Comment Line" = RIMD,
                  tabledata "Deduction Line" = RIMD,
                  tabledata "Deduction Resolution" = RIMD,
                  tabledata "Delivery Driver" = R,
                  tabledata "Delivery Route" = R,
                  tabledata "Delivery Route Schedule" = R,
                  tabledata "Delivery Routing Matrix Line" = R,
                  tabledata "Delivery Trip" = RIMD,
                  tabledata "Delivery Trip Order" = RIMD,
                  tabledata "Delivery Trip Pick" = RIMD,
                  tabledata "Delivery Trip Pick Line" = RIMD,
                  tabledata "Delivery Truck" = RIMD,
                  tabledata "Document Accrual Line" = RIMD,
                  tabledata "Extra Charge" = R,
                  tabledata "Item Cost Basis" = R,
                  tabledata "Item Cost Conversion Factor" = R,
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
                  tabledata "N138 Delivery Trip" = RIMD,
                  tabledata "N138 Delivery Trip History" = RIMD,
                  tabledata "N138 Loading Dock" = R,
                  tabledata "N138 Posted Transport Cost" = RIMD,
                  tabledata "N138 Trans. CC Template Line" = R,
                  tabledata "N138 Trans. Cost Comp Template" = R,
                  tabledata "N138 Transport Cost" = RIMD,
                  tabledata "N138 Transport Cost Component" = RIMD,
                  tabledata "N138 Transport Mgt. Setup" = R,
                  tabledata "Off-Invoice Allowance Header" = R,
                  tabledata "Off-Invoice Allowance Line" = R,
                  tabledata "Order Off-Invoice Allowance" = RIMD,
                  tabledata "Pick Class" = RIMD,
                  tabledata "Pick Container Header" = RIMD,
                  tabledata "Pick Container Line" = RIMD,
                  tabledata "Posted Document Accrual Line" = RIMD,
                  tabledata "Posted Sales Payment Header" = RIMD,
                  tabledata "Posted Sales Payment Line" = RIMD,
                  tabledata "Purchasing Group" = R,
                  tabledata "Recurring Price Template" = R,
                  tabledata "Sales Contract" = R,
                  tabledata "Sales Contract History" = R,
                  tabledata "Sales Contract Line" = R,
                  tabledata "Sales Line Repack" = RIMD,
                  tabledata "Sales Payment Header" = RIMD,
                  tabledata "Sales Payment Line" = RIMD,
                  tabledata "Sales Payment Tender Entry" = RIMD,
                  tabledata "Shipped Container Header" = RIMD,
                  tabledata "Shipped Container Line" = RIMD,
                  tabledata "Supply Chain Group" = R,
                  tabledata "Supply Chain Group User" = R,
                  tabledata "Usage Formula" = R,
                  tabledata Variant = R,
                  tabledata "Vendor Certification" = R,
                  tabledata "Vendor Certification Type" = R;
}
