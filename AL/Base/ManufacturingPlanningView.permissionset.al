permissionset 413 "Manufacturing Planning - View"
{
    Access = Public;
    Assignable = false;
    Caption = 'Make orders from Planning';

    IncludedPermissionSets = "FOOD Manufacturing Plan-View";

    Permissions = tabledata "Calendar Entry" = R,
                  tabledata "Capacity Constrained Resource" = R,
                  tabledata "Capacity Ledger Entry" = R,
                  tabledata "Capacity Unit of Measure" = R,
                  tabledata "Entry Summary" = RIMD,
                  tabledata "Item Journal Line" = Rm,
                  tabledata "Item Ledger Entry" = Rm,
                  tabledata "Machine Center" = R,
                  tabledata "Planning Component" = Rmd,
                  tabledata "Planning Routing Line" = Rmd,
                  tabledata "Prod. Order Capacity Need" = Rimd,
                  tabledata "Prod. Order Comment Line" = Rmd,
                  tabledata "Prod. Order Comp. Cmt Line" = Rmd,
                  tabledata "Prod. Order Component" = Rm,
                  tabledata "Prod. Order Line" = Rm,
                  tabledata "Prod. Order Routing Line" = Rimd,
                  tabledata "Prod. Order Routing Personnel" = Rmd,
                  tabledata "Prod. Order Routing Tool" = Rmd,
                  tabledata "Prod. Order Rtng Comment Line" = Rmd,
                  tabledata "Prod. Order Rtng Qlty Meas." = Rmd,
                  tabledata "Production BOM Comment Line" = R,
                  tabledata "Production Order" = Rimd,
                  tabledata "Purchase Line" = Rm,
                  tabledata "Requisition Line" = Rim,
                  tabledata "Reservation Entry" = Rimd,
                  tabledata "Routing Comment Line" = R,
                  tabledata "Routing Personnel" = R,
                  tabledata "Routing Quality Measure" = R,
                  tabledata "Routing Tool" = R,
                  tabledata "Sales Line" = Rm,
                  tabledata "Tracking Specification" = Rimd,
                  tabledata "Value Entry" = Rm,
                  tabledata "Work Center" = R;
}
