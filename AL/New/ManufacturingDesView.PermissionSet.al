permissionset 37002172 "FOOD Manufacturing Des-View"
{
    Access = Public;
    Assignable = false;
    Caption = 'Read Production BOM & Routing (FOOD)';

    Permissions = tabledata Allergen = R,
                  tabledata "Allergen Set Entry" = R,
                  tabledata "Allergen Set History" = R,
                  tabledata "Allergen Set Tree Node" = R,
                  tabledata "Batch Planning Worksheet Line" = R,
                  tabledata "Batch Planning Worksheet Name" = R,
                  tabledata "Clear Bin History" = RIMD,
                  tabledata "Daily Production Event" = R,
                  tabledata "Item Fixed Prod. Bin" = RIMD,
                  tabledata "Item Replenishment Area" = RIMD,
                  tabledata "Item Variant Variable" = R,
                  tabledata "Package Variable" = R,
                  tabledata "Pre-Process Activity" = R,
                  tabledata "Pre-Process Activity Line" = R,
                  tabledata "Pre-Process Type" = R,
                  tabledata "Process Order Request Line" = R,
                  tabledata "Process Setup" = R,
                  tabledata "Prod. BOM Activity Cost" = RIMD,
                  tabledata "Prod. BOM Equipment" = RIMD,
                  tabledata "Production Planning Event" = R,
                  tabledata "Production Sequence" = R,
                  tabledata "Reg. Pre-Process Activity" = R,
                  tabledata "Reg. Pre-Process Activity Line" = R,
                  tabledata "Replenishment Area" = RIMD,
                  tabledata "Unappr. Item Unit of Measure" = RIMD,
                  tabledata "Unapproved Item" = RIMD;
}
