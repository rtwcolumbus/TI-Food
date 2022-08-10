permissionset 37002151 "FOOD Maint-Admin"
{
    Access = Public;
    Assignable = true;
    Caption = 'Setup Mainenance';

    Permissions = tabledata Asset = R,
                  tabledata "Asset Category" = RIMD,
                  tabledata "Asset Spare Part" = R,
                  tabledata "Asset Usage" = R,
                  tabledata "Maintenance Cue" = RIMD,
                  tabledata "Maintenance Journal Batch" = RIMD,
                  tabledata "Maintenance Journal Line" = R,
                  tabledata "Maintenance Journal Template" = RIMD,
                  tabledata "Maintenance Ledger" = R,
                  tabledata "Maintenance Register" = R,
                  tabledata "Maintenance Setup" = RIMD,
                  tabledata "Maintenance Trade" = RIMD,
                  tabledata "My Asset" = RIMD,
                  tabledata "PM Activity" = R,
                  tabledata "PM Frequency" = RIMD,
                  tabledata "PM Material" = R,
                  tabledata "PM Worksheet" = R,
                  tabledata "PM Worksheet Name" = R,
                  tabledata "Preventive Maintenance Order" = R,
                  tabledata "Vendor / Maintenance Trade" = RIMD,
                  tabledata "Work Order" = R,
                  tabledata "Work Order Action Code" = RIMD,
                  tabledata "Work Order Activity" = R,
                  tabledata "Work Order Cause Code" = RIMD,
                  tabledata "Work Order Comment Line" = R,
                  tabledata "Work Order Fault Code" = RIMD,
                  tabledata "Work Order Material" = R;
}
