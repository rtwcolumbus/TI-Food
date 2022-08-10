permissionset 37002103 "FOOD Data Col-View"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read Data Collection';

    Permissions = tabledata "Automatic Lot No." = R,
                  tabledata "Data Coll. Alert Group Member" = R,
                  tabledata "Data Collection Alert" = R,
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
                  tabledata "Data Sheet Header" = R,
                  tabledata "Data Sheet Line" = R,
                  tabledata "Data Sheet Line Detail" = R,
                  tabledata "Incident Classification" = R,
                  tabledata "Incident Comment Line" = R,
                  tabledata "Incident Entry" = R,
                  tabledata "Incident Reason Code" = R,
                  tabledata "Incident Resolution Entry" = R,
                  tabledata "Incident Search Setup" = R,
                  tabledata "Item Quality Skip Logic Line" = R,
                  tabledata "Item Quality Skip Logic Trans." = R,
                  tabledata "Item Quality Test Result" = R,
                  tabledata "Lot Specification" = R,
                  tabledata "My Alert" = RIMD,
                  tabledata "Quality Control Cue" = RIMD,
                  tabledata "Quality Control Header" = R,
                  tabledata "Quality Control Line" = R,
                  tabledata "Quality Control Technician" = R,
                  tabledata "Record Link Description" = R,
                  tabledata "Skip Logic Setup" = R;
}
