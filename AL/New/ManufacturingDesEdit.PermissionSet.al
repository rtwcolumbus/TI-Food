permissionset 37002171 "FOOD Manufacturing Des-Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'Edit Production BOM & Routing (FOOD)';

    Permissions = tabledata Allergen = R,
                  tabledata "Allergen Set Entry" = RIMD,
                  tabledata "Allergen Set History" = RIMD,
                  tabledata "Allergen Set Tree Node" = RIMD,
                  tabledata "Batch Planning Worksheet Line" = RIMD,
                  tabledata "Batch Planning Worksheet Name" = RIMD,
                  tabledata "Clear Bin History" = RIMD,
                  tabledata "Daily Production Event" = RIMD,
                  tabledata "Item Fixed Prod. Bin" = RIMD,
                  tabledata "Item Replenishment Area" = RIMD,
                  tabledata "Item Variant Variable" = R,
                  tabledata "Package Variable" = R,
                  tabledata "Pre-Process Activity" = R,
                  tabledata "Pre-Process Activity Line" = R,
                  tabledata "Pre-Process Type" = RIMD,
                  tabledata "Process Order Request Line" = RIMD,
                  tabledata "Process Setup" = R,
                  tabledata "Prod. BOM Activity Cost" = RIMD,
                  tabledata "Prod. BOM Equipment" = RIMD,
                  tabledata "Production Planning Event" = RIMD,
                  tabledata "Production Sequence" = R,
                  tabledata "Reg. Pre-Process Activity" = R,
                  tabledata "Reg. Pre-Process Activity Line" = R,
                  tabledata "Replenishment Area" = RIMD,
                  tabledata "Unappr. Item Unit of Measure" = RIMD,
                  tabledata "Unapproved Item" = RIMD;
}
