permissionset 37002142 "FOOD Inventory-Periodic"
{
    Access = Public;
    Assignable = false;
    Caption = 'Inventory periodic activities (FOOD)';

    Permissions = tabledata Allergen = RIMD,
                  tabledata "Allergen Set Entry" = RIMD,
                  tabledata "Allergen Set History" = RIMD,
                  tabledata "Allergen Set Tree Node" = RIMD,
                  tabledata "Alternate Quantity Entry" = RIMD,
                  tabledata "Comm. Cost Component" = RIMD,
                  tabledata "Comm. Cost Setup Line" = RIMD,
                  tabledata "Commodity Class" = RIMD,
                  tabledata "Commodity Cost Entry" = RIMD,
                  tabledata "Commodity Cost Period" = RIMD,
                  tabledata "Cost Basis" = RIMD,
                  tabledata "Cost Basis Adjustment" = RIMD,
                  tabledata "Cost Calculation Method" = RIMD,
                  tabledata "Cust./Item Price/Disc. Group" = RIMD,
                  tabledata "Hauler Charge" = RIMD,
                  tabledata "Item Cost Basis" = RIMD,
                  tabledata "Item Cost Conversion Factor" = RIMD,
                  tabledata "Item Status Entry" = RIMD,
                  tabledata "Producer Zone" = RIMD,
                  tabledata "Recurring Price Template" = RIMD,
                  tabledata "Sales Contract" = RIMD,
                  tabledata "Sales Contract History" = RIMD,
                  tabledata "Sales Contract Line" = RIMD,
                  tabledata "Value Entry ABC Detail" = RIMD;
}
