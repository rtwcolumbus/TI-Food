permissionset 5401 "Consumption Journals - Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'Create entries in Cons. Jnl.';

    IncludedPermissionSets = "FOOD Consumption Journals-Edit";

    Permissions = tabledata Bin = R,
                  tabledata "Comment Line" = R,
                  tabledata "Default Dimension" = R,
                  tabledata "Default Dimension Priority" = R,
                  tabledata "Gen. Business Posting Group" = R,
                  tabledata "Gen. Product Posting Group" = R,
                  tabledata "General Ledger Setup" = R,
                  tabledata "General Posting Setup" = R,
                  tabledata "Inventory Posting Group" = R,
                  tabledata "Inventory Posting Setup" = R,
                  tabledata Item = R,
                  tabledata "Item Journal Batch" = RI,
                  tabledata "Item Journal Line" = RIMD,
                  tabledata "Item Journal Template" = RI,
                  tabledata "Item Ledger Entry" = R,
                  tabledata "Item Tracking Code" = R,
                  tabledata "Item Tracking Comment" = RIMD,
                  tabledata "Item Unit of Measure" = R,
                  tabledata "Item Variant" = R,
                  tabledata Location = R,
                  tabledata "Lot No. Information" = RIMD,
                  tabledata "Package No. Information" = RIMD,
                  tabledata "Prod. Order Component" = R,
                  tabledata "Prod. Order Line" = R,
                  tabledata "Production Order" = R,
                  tabledata "Reason Code" = R,
                  tabledata "Serial No. Information" = RIMD,
                  tabledata "Source Code Setup" = R,
                  tabledata "Stockkeeping Unit" = R,
                  tabledata "Unit of Measure" = R,
                  tabledata "Value Entry" = R,
                  tabledata "VAT Assisted Setup Bus. Grp." = R,
                  tabledata "VAT Assisted Setup Templates" = R,
                  tabledata "VAT Business Posting Group" = R,
                  tabledata "VAT Posting Setup" = R,
                  tabledata "VAT Product Posting Group" = R,
                  tabledata "VAT Rate Change Conversion" = R,
                  tabledata "VAT Rate Change Log Entry" = Ri,
                  tabledata "VAT Rate Change Setup" = R,
                  tabledata "VAT Setup Posting Groups" = R;
}
