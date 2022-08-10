permissionset 37002100 "FOOD Data Col-Edit"
{
    Access = Public;
    Assignable = true;
    Caption = 'Edit Data Collection';

    Permissions = tabledata "Automatic Lot No." = RIMD,
                  tabledata "Data Coll. Alert Group Member" = RIMD,
                  tabledata "Data Collection Alert" = RIMD,
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
                  tabledata "Data Sheet Header" = RIMD,
                  tabledata "Data Sheet Line" = RIMD,
                  tabledata "Data Sheet Line Detail" = RIMD,
                  tabledata "Incident Classification" = RIMD,
                  tabledata "Incident Comment Line" = RIMD,
                  tabledata "Incident Entry" = RIMD,
                  tabledata "Incident Reason Code" = RIMD,
                  tabledata "Incident Resolution Entry" = RIMD,
                  tabledata "Incident Search Setup" = RIMD,
                  tabledata "Item Quality Skip Logic Line" = RIMD,
                  tabledata "Item Quality Skip Logic Trans." = RIMD,
                  tabledata "Item Quality Test Result" = RIMD,
                  tabledata "Lot Specification" = RIMD,
                  tabledata "My Alert" = RIMD,
                  tabledata "Quality Control Cue" = RIMD,
                  tabledata "Quality Control Header" = RIMD,
                  tabledata "Quality Control Line" = RIMD,
                  tabledata "Quality Control Technician" = RIMD,
                  tabledata "Record Link Description" = RIMD,
                  tabledata "Skip Logic Setup" = RIMD;
}
