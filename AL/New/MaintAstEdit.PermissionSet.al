permissionset 37002160 "FOOD Maint Ast-Edit"
{
    Access = Public;
    Assignable = true;
    Caption = 'Edit Maint. Assets';

    Permissions = tabledata Asset = RIMD,
                  tabledata "Asset Category" = RIMD,
                  tabledata "Asset Spare Part" = RIMD,
                  tabledata "Asset Usage" = RIMD,
                  tabledata "Maintenance Cue" = RIMD,
                  tabledata "Maintenance Journal Batch" = R,
                  tabledata "Maintenance Journal Line" = R,
                  tabledata "Maintenance Journal Template" = R,
                  tabledata "Maintenance Ledger" = R,
                  tabledata "Maintenance Register" = R,
                  tabledata "Maintenance Setup" = R,
                  tabledata "Maintenance Trade" = RIMD,
                  tabledata "My Asset" = RIMD,
                  tabledata "PM Activity" = R,
                  tabledata "PM Frequency" = R,
                  tabledata "PM Material" = R,
                  tabledata "PM Worksheet" = R,
                  tabledata "PM Worksheet Name" = R,
                  tabledata "Preventive Maintenance Order" = R,
                  tabledata "Vendor / Maintenance Trade" = RIMD,
                  tabledata "Work Order" = R,
                  tabledata "Work Order Action Code" = R,
                  tabledata "Work Order Activity" = R,
                  tabledata "Work Order Cause Code" = R,
                  tabledata "Work Order Comment Line" = R,
                  tabledata "Work Order Fault Code" = R,
                  tabledata "Work Order Material" = R;
}
