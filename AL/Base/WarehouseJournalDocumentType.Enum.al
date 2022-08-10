enum 5773 "Warehouse Journal Document Type"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "Whse. Journal") { Caption = 'Whse. Journal'; }
    value(1; "Receipt") { Caption = 'Receipt'; }
    value(2; "Shipment") { Caption = 'Shipment'; }
    value(3; "Internal Put-away") { Caption = 'Internal Put-away'; }
    value(4; "Internal Pick") { Caption = 'Internal Pick'; }
    value(5; "Production") { Caption = 'Production'; }
    value(6; "Whse. Phys. Inventory") { Caption = 'Whse. Phys. Inventory'; }
    value(7; " ") { Caption = ' '; }
    value(8; "Assembly") { Caption = 'Assembly'; }
    value(9; FOODStagedPick)
     { Caption = 'Staged Pick';
        ObsoleteState = Pending;
        ObsoleteReason = 'Moving to value 37002000';
        ObsoleteTag = 'FOOD-20';
      }
    value(10; FOODDeliveryTripPick)
     { Caption = 'Delivery Trip Pick';
        ObsoleteState = Pending;
        ObsoleteReason = 'Moving to value 37002001';
        ObsoleteTag = 'FOOD-20';
      }
    value(11; FOODDeliveryTrip)
     { Caption = 'Delivery Trip';
        ObsoleteState = Pending;
        ObsoleteReason = 'Moving to value 37002002';
        ObsoleteTag = 'FOOD-20';
      }
}