permissionset 3632 "Account Schedules - Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'Edit account schedules';

    IncludedPermissionSets = "FOOD Account Schedules-Edit";    

    Permissions = tabledata "Acc. Sched. Chart Setup Line" = RIMD,
                  tabledata "Acc. Schedule Line" = RIMD,
                  tabledata "Acc. Schedule Name" = RIMD,
                  tabledata "Account Schedules Chart Setup" = RIMD,
                  tabledata "Analysis View" = R,
                  tabledata "Analysis View Budget Entry" = R,
                  tabledata "Analysis View Entry" = R,
                  tabledata "Business Unit" = R,
                  tabledata "Business Unit Information" = R,
                  tabledata "Business Unit Setup" = R,
                  tabledata "Column Layout" = RIMD,
                  tabledata "Column Layout Name" = RIMD,
                  tabledata "Consolidation Account" = R,
                  tabledata Dimension = R,
                  tabledata "Dimension Value" = R,
                  tabledata "G/L Account Category" = RIMD,
                  tabledata "G/L Budget Name" = RI;
}
