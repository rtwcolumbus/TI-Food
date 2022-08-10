permissionset 37002190 "FOOD Payables-Admin"
{
    Access = Public;
    Assignable = false;
    Caption = 'P&P setup (FOOD)';

    Permissions = tabledata "Comm. Cost Component" = RIMD,
                  tabledata "Comm. Cost Setup Line" = RIMD,
                  tabledata "Commodity Class" = RIMD,
                  tabledata "Extra Charge" = RIMD,
                  tabledata "Extra Charge Posting Setup" = RIMD,
                  tabledata "Hauler Charge" = RIMD,
                  tabledata "Producer Zone" = RIMD,
                  tabledata "Purchasing Group" = RIMD,
                  tabledata "Usage Formula" = RIMD,
                  tabledata "Vendor Certification Type" = RIMD;
}
