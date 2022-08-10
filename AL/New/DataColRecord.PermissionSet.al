permissionset 37002102 "FOOD Data Col-Record"
{
    Access = Public;
    Assignable = true;
    Caption = 'Record Data Collection';

    Permissions = tabledata "Automatic Lot No." = RIMD,
                  tabledata "Data Coll. Alert Group Member" = R,
                  tabledata "Data Collection Alert" = RIMD,
                  tabledata "Data Collection Alert Group" = R,
                  tabledata "Data Collection Comment" = R,
                  tabledata "Data Collection Data Element" = R,
                  tabledata "Data Collection Line" = R,
                  tabledata "Data Collection Log Group" = R,
                  tabledata "Data Collection Lookup" = R,
                  tabledata "Data Collection Setup" = R,
                  tabledata "Data Collection Temp/Item Cat." = R,
                  tabledata "Data Collection Template" = R,
                  tabledata "Data Collection Template Line" = R,
                  tabledata "Data Sheet Header" = RIMD,
                  tabledata "Data Sheet Line" = RIMD,
                  tabledata "Data Sheet Line Detail" = RIMD,
                  tabledata "Incident Classification" = R,
                  tabledata "Incident Comment Line" = RIMD,
                  tabledata "Incident Entry" = RIMD,
                  tabledata "Incident Reason Code" = R,
                  tabledata "Incident Resolution Entry" = RIMD,
                  tabledata "Incident Search Setup" = R,
                  tabledata "Item Quality Skip Logic Line" = R,
                  tabledata "Item Quality Skip Logic Trans." = RIMD,
                  tabledata "Item Quality Test Result" = RIMD,
                  tabledata "Lot Specification" = RIMD,
                  tabledata "My Alert" = RIMD,
                  tabledata "Quality Control Cue" = RIMD,
                  tabledata "Quality Control Header" = RIMD,
                  tabledata "Quality Control Line" = RIMD,
                  tabledata "Quality Control Technician" = R,
                  tabledata "Record Link Description" = R,
                  tabledata "Skip Logic Setup" = R;
}
