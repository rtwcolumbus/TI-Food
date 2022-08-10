permissionset 37002149 "FOOD Label-Admin"
{
    Access = Public;
    Assignable = true;
    Caption = 'Setup Labels';

    Permissions = tabledata "Label" = RIMD,
                  tabledata "Label Printer Selection" = RIMD,
                  tabledata "Label Selection" = RIMD;
}
