permissionset 37002101 "FOOD Data Col-Admin"
{
    Access = Public;
    Assignable = true;
    Caption = 'Setup Data Collection';

    Permissions = tabledata "Automatic Lot No." = RIMD,
                  tabledata "Data Coll. Alert Group Member" = RIMD,
                  tabledata "Data Collection Alert" = R,
                  tabledata "Data Collection Alert Group" = RIMD,
                  tabledata "Data Collection Comment" = RIMD,
                  tabledata "Data Collection Data Element" = RIMD,
                  tabledata "Data Collection Line" = RIMD,
                  tabledata "Data Collection Log Group" = RIMD,
                  tabledata "Data Collection Lookup" = RIMD,
                  tabledata "Data Collection Setup" = RIMD,
                  tabledata "Data Collection Temp/Item Cat." = RIMD,
                  tabledata "Data Collection Template" = RIMD,
                  tabledata "Data Collection Template Line" = RIMD,
                  tabledata "Data Sheet Header" = R,
                  tabledata "Data Sheet Line" = R,
                  tabledata "Data Sheet Line Detail" = R,
                  tabledata "Incident Classification" = RIMD,
                  tabledata "Incident Comment Line" = R,
                  tabledata "Incident Entry" = R,
                  tabledata "Incident Reason Code" = RIMD,
                  tabledata "Incident Resolution Entry" = R,
                  tabledata "Incident Search Setup" = RIMD,
                  tabledata "Item Quality Skip Logic Line" = RIMD,
                  tabledata "Item Quality Skip Logic Trans." = R,
                  tabledata "Item Quality Test Result" = R,
                  tabledata "Lot Specification" = RIMD,
                  tabledata "My Alert" = RIMD,
                  tabledata "Quality Control Cue" = RIMD,
                  tabledata "Quality Control Header" = R,
                  tabledata "Quality Control Line" = R,
                  tabledata "Quality Control Technician" = RIMD,
                  tabledata "Record Link Description" = RIMD,
                  tabledata "Skip Logic Setup" = RIMD;
}
