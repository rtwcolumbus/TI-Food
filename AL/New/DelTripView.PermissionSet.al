permissionset 37002111 "FOOD Del Trip-View"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read Delivery Trips';

    Permissions = tabledata Allergen = R,
                  tabledata "Allergen Set Entry" = R,
                  tabledata "Allergen Set History" = R,
                  tabledata "Allergen Set Tree Node" = R,
                  tabledata "Container Header" = R,
                  tabledata "Delivery Driver" = RIMD,
                  tabledata "Delivery Route" = RIMD,
                  tabledata "Delivery Route Schedule" = RIMD,
                  tabledata "Delivery Routing Matrix Line" = RIMD,
                  tabledata "Delivery Trip" = RIMD,
                  tabledata "Delivery Trip Order" = RIMD,
                  tabledata "Delivery Trip Pick" = RIMD,
                  tabledata "Delivery Trip Pick Line" = RIMD,
                  tabledata "Delivery Truck" = RIMD,
                  tabledata "Dist. Planning Cue" = RIMD,
                  tabledata "Document Extra Charge" = RIMD,
                  tabledata "Extra Charge" = RIMD,
                  tabledata "Extra Charge Posting Setup" = RIMD,
                  tabledata "Pick Class" = RIMD,
                  tabledata "Pick Container Header" = RIMD,
                  tabledata "Pick Container Line" = RIMD,
                  tabledata "Pickup Load Header" = RIMD,
                  tabledata "Pickup Load Line" = RIMD,
                  tabledata "Pickup Location" = RIMD,
                  tabledata "Posted Document Extra Charge" = RIMD,
                  tabledata "Value Entry Extra Charge" = RIMD;
}
