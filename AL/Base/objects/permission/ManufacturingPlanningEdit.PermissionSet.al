permissionset 2694 "Manufacturing Planning - Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'Create Planning';

    IncludedPermissionSets = "FOOD Manufacturing Plan-Edit";

    Permissions = tabledata Bin = R,
                  tabledata "Calendar Entry" = R,
                  tabledata "Capacity Constrained Resource" = R,
                  tabledata "Capacity Ledger Entry" = R,
                  tabledata "Capacity Unit of Measure" = R,
                  tabledata "Entry Summary" = RIMD,
                  tabledata "Gen. Business Posting Group" = R,
                  tabledata "Gen. Product Posting Group" = R,
                  tabledata "General Posting Setup" = R,
                  tabledata "Inventory Posting Group" = R,
                  tabledata "Inventory Posting Setup" = R,
                  tabledata "Inventory Profile" = Rimd,
                  tabledata Item = R,
                  tabledata "Item Journal Line" = Rm,
                  tabledata "Item Ledger Entry" = Rm,
                  tabledata "Item Unit of Measure" = R,
                  tabledata "Item Variant" = R,
                  tabledata Location = R,
                  tabledata "Machine Center" = R,
                  tabledata "Planning Component" = RIMD,
                  tabledata "Planning Routing Line" = RIMD,
                  tabledata "Prod. Order Capacity Need" = Rmd,
                  tabledata "Prod. Order Comment Line" = Rmd,
                  tabledata "Prod. Order Comp. Cmt Line" = Rmd,
                  tabledata "Prod. Order Component" = Rm,
                  tabledata "Prod. Order Line" = Rm,
                  tabledata "Prod. Order Routing Line" = Rmd,
                  tabledata "Prod. Order Routing Personnel" = Rmd,
                  tabledata "Prod. Order Routing Tool" = Rmd,
                  tabledata "Prod. Order Rtng Comment Line" = Rmd,
                  tabledata "Prod. Order Rtng Qlty Meas." = Rmd,
                  tabledata "Production BOM Header" = R,
                  tabledata "Production BOM Line" = R,
                  tabledata "Production BOM Version" = R,
                  tabledata "Production Forecast Entry" = RIMD,
                  tabledata "Production Forecast Name" = RIMD,
                  tabledata "Production Order" = Rmd,
                  tabledata "Purchase Line" = Rm,
                  tabledata "Reason Code" = R,
                  tabledata "Req. Wksh. Template" = Rim,
                  tabledata "Requisition Line" = Rim,
                  tabledata "Requisition Wksh. Name" = Rim,
                  tabledata "Reservation Entry" = Rimd,
                  tabledata "Routing Header" = R,
                  tabledata "Routing Line" = R,
                  tabledata "Routing Version" = R,
                  tabledata "Sales Header" = R,
                  tabledata "Sales Line" = Rm,
                  tabledata "Source Code" = R,
                  tabledata "Source Code Setup" = R,
                  tabledata "Standard Task" = R,
                  tabledata "Standard Task Description" = R,
                  tabledata "Standard Task Personnel" = R,
                  tabledata "Standard Task Quality Measure" = R,
                  tabledata "Standard Task Tool" = R,
                  tabledata "Tracking Specification" = Rimd,
                  tabledata "Unit of Measure" = R,
                  tabledata "Value Entry" = Rm,
                  tabledata "VAT Assisted Setup Bus. Grp." = R,
                  tabledata "VAT Assisted Setup Templates" = R,
                  tabledata "VAT Business Posting Group" = R,
                  tabledata "VAT Posting Setup" = R,
                  tabledata "VAT Product Posting Group" = R,
                  tabledata "VAT Rate Change Conversion" = R,
                  tabledata "VAT Rate Change Log Entry" = Ri,
                  tabledata "VAT Rate Change Setup" = R,
                  tabledata "VAT Setup Posting Groups" = R,
                  tabledata "Work Center" = R;
}
