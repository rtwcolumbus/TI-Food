permissionset 37002134 "FOOD G/L Journals-Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'Create entries in G/L journals (FOOD)';

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
                  tabledata "Document Accrual Line" = RIMD,
                  tabledata "Posted Document Accrual Line" = RIMD;
}
