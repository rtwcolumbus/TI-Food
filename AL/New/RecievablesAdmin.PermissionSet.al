permissionset 37002210 "FOOD Recievables-Admin"
{
    Access = Public;
    Assignable = false;
    Caption = 'S&R  setup (FOOD)';

    Permissions = tabledata "Delivery Driver" = RIMD,
                  tabledata "Delivery Route" = RIMD,
                  tabledata "Delivery Route Schedule" = RIMD,
                  tabledata "Delivery Routing Matrix Line" = RIMD,
                  tabledata "Delivery Trip" = RIMD,
                  tabledata "Delivery Trip Order" = RIMD,
                  tabledata "Delivery Trip Pick" = RIMD,
                  tabledata "Delivery Trip Pick Line" = RIMD,
                  tabledata "Delivery Truck" = RIMD,
                  tabledata "N138 Delivery Trip" = RIMD,
                  tabledata "N138 Delivery Trip History" = RIMD,
                  tabledata "N138 Loading Dock" = RIMD,
                  tabledata "N138 Posted Transport Cost" = RIMD,
                  tabledata "N138 Trans. CC Template Line" = RIMD,
                  tabledata "N138 Trans. Cost Comp Template" = RIMD,
                  tabledata "N138 Transport Cost" = RIMD,
                  tabledata "N138 Transport Cost Component" = RIMD,
                  tabledata "N138 Transport Mgt. Setup" = RIMD,
                  tabledata "Off-Invoice Allowance Header" = RIMD,
                  tabledata "Off-Invoice Allowance Line" = RIMD,
                  tabledata "Order Off-Invoice Allowance" = RIMD,
                  tabledata "Pick Class" = RIMD,
                  tabledata "Pick Container Header" = RIMD,
                  tabledata "Pick Container Line" = RIMD;
}
