permissionset 37002001 "FOOD Account Schedules-View"
{
    Access = Public;
    Assignable = false;
    Caption = 'Read account schedules (FOOD)';

    Permissions = tabledata "Acc. Schedule Unit" = RIMD;
}
