permissionset 4936 "Inventory - Periodic"
{
    Access = Public;
    Assignable = false;
    Caption = 'Inventory periodic activities';

    IncludedPermissionSets = "FOOD Inventory-Periodic";

    Permissions = tabledata "Analysis View" = rimd,
                  tabledata "Analysis View Entry" = rim,
                  tabledata "Analysis View Filter" = r,
                  tabledata "Avg. Cost Adjmt. Entry Point" = Rimd,
                  tabledata "Batch Processing Parameter" = Rimd,
                  tabledata "Batch Processing Session Map" = Rimd,
                  tabledata Currency = R,
                  tabledata "Currency Exchange Rate" = R,
                  tabledata "Customer Posting Group" = R,
                  tabledata "Customer Price Group" = R,
                  tabledata "Date Compr. Register" = RimD,
                  tabledata "Dtld. Price Calculation Setup" = RIMD,
                  tabledata "Duplicate Price Line" = RIMD,
                  tabledata "Employee Posting Group" = R,
                  tabledata "G/L Account" = R,
                  tabledata "G/L Entry" = Ri,
                  tabledata "G/L Register" = Rim,
                  tabledata "Gen. Business Posting Group" = R,
                  tabledata "Gen. Product Posting Group" = R,
                  tabledata "General Ledger Setup" = R,
                  tabledata "General Posting Setup" = R,
                  tabledata "Inventory Posting Group" = R,
                  tabledata "Inventory Posting Setup" = R,
                  tabledata Item = RM,
                  tabledata "Item Application Entry" = Rimd,
                  tabledata "Item Ledger Entry" = Rimd,
                  tabledata "Item Register" = Rimd,
                  tabledata "Item Variant" = R,
                  tabledata "Price Asset" = RIMD,
                  tabledata "Price Calculation Buffer" = RIMD,
                  tabledata "Price Calculation Setup" = RIMD,
                  tabledata "Price Line Filters" = RIMD,
                  tabledata "Price List Header" = RIMD,
                  tabledata "Price List Line" = RIMD,
                  tabledata "Price Source" = RIMD,
                  tabledata "Price Worksheet Line" = RIMD,
                  tabledata "Reservation Entry" = Rimd,
                  tabledata "Responsibility Center" = R,
                  tabledata "Rounding Method" = R,
#if not CLEAN21
                  tabledata "Sales Price" = RIMD,
#endif
                  tabledata "Sales Price Access" = RIMD,
#if not CLEAN21
                  tabledata "Sales Price Worksheet" = RIMD,
#endif
                  tabledata "Source Code Setup" = R,
                  tabledata "Stockkeeping Unit" = RM,
                  tabledata "Tracking Specification" = Rimd,
                  tabledata "Value Entry" = Rimd,
                  tabledata "VAT Assisted Setup Bus. Grp." = R,
                  tabledata "VAT Assisted Setup Templates" = R,
                  tabledata "VAT Business Posting Group" = R,
                  tabledata "VAT Posting Setup" = R,
                  tabledata "VAT Product Posting Group" = R,
                  tabledata "VAT Rate Change Conversion" = R,
                  tabledata "VAT Rate Change Log Entry" = Ri,
                  tabledata "VAT Rate Change Setup" = R,
                  tabledata "VAT Setup Posting Groups" = R,
                  tabledata Vendor = R,
                  tabledata "Vendor Bank Account" = R,
                  tabledata "Vendor Posting Group" = R;
}
