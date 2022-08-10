permissionset 37002042 "FOOD D365 ACC. PAYABLE"
{
    Access = Public;
    Assignable = false;
    Caption = 'Dynamics 365 Accounts payable (FOOD)';

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
                  tabledata "Alternate Quantity Entry" = RIMD,
                  tabledata "Alternate Quantity Line" = RIMD,
                  tabledata "Automatic Lot No." = RIMD,
                  tabledata "Data Collection Alert" = RIMD,
                  tabledata "Data Sheet Header" = RIMD,
                  tabledata "Data Sheet Line" = RIMD,
                  tabledata "Data Sheet Line Detail" = RIMD,
                  tabledata "Deduction Comment Line" = RIMD,
                  tabledata "Deduction Line" = RIMD,
                  tabledata "Deduction Resolution" = RIMD,
                  tabledata "Document Accrual Line" = RIMD,
                  tabledata "Incident Comment Line" = RIMD,
                  tabledata "Incident Entry" = RIMD,
                  tabledata "Incident Resolution Entry" = RIMD,
                  tabledata "Item Quality Skip Logic Trans." = RIMD,
                  tabledata "Item Quality Test Result" = RIMD,
                  tabledata "Item Status Entry" = RIMD,
                  tabledata "Lot No. Custom Format" = R,
                  tabledata "Lot No. Custom Format Line" = R,
                  tabledata "Lot No. Segment" = R,
                  tabledata "Lot No. Segment Value" = R,
                  tabledata "Lot Specification" = RIMD,
                  tabledata "N138 Loading Dock" = RIMD,
                  tabledata "N138 Trans. CC Template Line" = RIMD,
                  tabledata "N138 Trans. Cost Comp Template" = RIMD,
                  tabledata "N138 Transport Mgt. Setup" = RIMD,
                  tabledata "Posted Document Accrual Line" = RIMD,
                  tabledata "Quality Control Header" = RIMD,
                  tabledata "Quality Control Line" = RIMD;
}
