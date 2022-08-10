permissionset 37002162 "FOOD Maint Jn-Edit"
{
    Access = Public;
    Assignable = true;
    Caption = 'Create Entries in Maint. Jnl.';

    Permissions = tabledata Asset = R,
                  tabledata "Asset Category" = R,
                  tabledata "Asset Spare Part" = R,
                  tabledata "Asset Usage" = R,
                  tabledata "Maintenance Cue" = RIMD,
                  tabledata "Maintenance Journal Batch" = RIMD,
                  tabledata "Maintenance Journal Line" = R,
                  tabledata "Maintenance Journal Template" = RIMD,
                  tabledata "Maintenance Ledger" = R,
                  tabledata "Maintenance Register" = R,
                  tabledata "Maintenance Setup" = R,
                  tabledata "Maintenance Trade" = R,
                  tabledata "My Asset" = RIMD,
                  tabledata "PM Activity" = R,
                  tabledata "PM Frequency" = R,
                  tabledata "PM Material" = R,
                  tabledata "PM Worksheet" = R,
                  tabledata "PM Worksheet Name" = R,
                  tabledata "Preventive Maintenance Order" = R,
                  tabledata "Vendor / Maintenance Trade" = R,
                  tabledata "Work Order" = R,
                  tabledata "Work Order Action Code" = R,
                  tabledata "Work Order Activity" = R,
                  tabledata "Work Order Cause Code" = R,
                  tabledata "Work Order Comment Line" = R,
                  tabledata "Work Order Fault Code" = R,
                  tabledata "Work Order Material" = R;
}
