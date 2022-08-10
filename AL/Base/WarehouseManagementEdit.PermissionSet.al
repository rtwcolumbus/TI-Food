permissionset 4472 "Warehouse Management - Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'Whse. Mgt. periodic activities';

    IncludedPermissionSets = "FOOD Warehouse Mgt-Edit";

    Permissions = tabledata Bin = RIMD,
                  tabledata "Bin Content" = RIMD,
                  tabledata "Bin Content Buffer" = RIMD,
                  tabledata "Bin Creation Wksh. Name" = R,
                  tabledata "Bin Creation Wksh. Template" = R,
                  tabledata "Bin Creation Worksheet Line" = RIMD,
                  tabledata "Phys. Invt. Counting Period" = RIMD,
                  tabledata "Phys. Invt. Item Selection" = R,
                  tabledata "Registered Whse. Activity Hdr." = RD,
                  tabledata "Registered Whse. Activity Line" = RD,
                  tabledata "Warehouse Employee" = R,
                  tabledata "Warehouse Journal Batch" = R,
                  tabledata "Warehouse Journal Line" = RIMD,
                  tabledata "Warehouse Journal Template" = R,
                  tabledata "Warehouse Register" = Rimd;
}
