permissionset 37002071 "FOOD D365 VENDOR, EDIT"
{
    Access = Public;
    Assignable = false;
    Caption = 'Dynamics 365 Create vendors (FOOD)';

    Permissions = tabledata "Commodity Manifest Dest. Bin" = RIMD,
                  tabledata "Commodity Manifest Header" = RIMD,
                  tabledata "Commodity Manifest Line" = RIMD,
                  tabledata "Pickup Load Header" = RIMD,
                  tabledata "Pickup Load Line" = RIMD,
                  tabledata "Pickup Location" = RIMD,
                  tabledata "Posted Comm. Manifest Header" = RIMD,
                  tabledata "Posted Comm. Manifest Line" = RIMD,
                  tabledata "Pstd. Comm. Manifest Dest. Bin" = RIMD,
                  tabledata "Vendor Certification" = R,
                  tabledata "Vendor Certification Type" = R;
}
