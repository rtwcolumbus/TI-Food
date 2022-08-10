permissionset 37002164 "FOOD Maint WO-Edit"
{
    Access = Public;
    Assignable = true;
    Caption = 'Edit Maint. W.O.';

    Permissions = tabledata Asset = R,
                  tabledata "Asset Category" = R,
                  tabledata "Asset Spare Part" = R,
                  tabledata "Asset Usage" = RIMD,
                  tabledata "Maintenance Cue" = RIMD,
                  tabledata "Maintenance Journal Batch" = R,
                  tabledata "Maintenance Journal Line" = R,
                  tabledata "Maintenance Journal Template" = R,
                  tabledata "Maintenance Ledger" = R,
                  tabledata "Maintenance Register" = R,
                  tabledata "Maintenance Setup" = R,
                  tabledata "Maintenance Trade" = R,
                  tabledata "My Asset" = RIMD,
                  tabledata "PM Activity" = RIMD,
                  tabledata "PM Frequency" = RIMD,
                  tabledata "PM Material" = RIMD,
                  tabledata "PM Worksheet" = RIMD,
                  tabledata "PM Worksheet Name" = RIMD,
                  tabledata "Preventive Maintenance Order" = RIMD,
                  tabledata "Vendor / Maintenance Trade" = R,
                  tabledata "Work Order" = RIMD,
                  tabledata "Work Order Action Code" = RIMD,
                  tabledata "Work Order Activity" = RIMD,
                  tabledata "Work Order Cause Code" = RIMD,
                  tabledata "Work Order Comment Line" = RIMD,
                  tabledata "Work Order Fault Code" = RIMD,
                  tabledata "Work Order Material" = RIMD;
}
