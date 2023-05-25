query 37002331 "Delivery Trip Source Doc. Cnt."
{
    // PRW18.00.02
    // P8004374, To-Increase, Jack Reynolds, 08 OCT 15
    //   Fix problem with default values if no Warehouse Request match
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Delivery Trip Source Doc. Cnt.';

    elements
    {
        dataitem(DeliveryTrip; "N138 Delivery Trip")
        {
            column(DeliveryTripNo; "No.")
            {
            }
            dataitem(WarehouseRequest; "Warehouse Request")
            {
                DataItemLink = "Delivery Trip" = DeliveryTrip."No.";
                SqlJoinType = InnerJoin;
                column(SourceType; "Source Type")
                {
                }
                column(SourceSubtype; "Source Subtype")
                {
                }
                column(SourceNo; "Source No.")
                {
                }
                column(Quantity; Quantity)
                {
                }
                dataitem(WarehouseShipmentHeader; "Warehouse Shipment Header")
                {
                    DataItemLink = "Delivery Trip" = WarehouseRequest."Delivery Trip";
                    dataitem(WarehouseShipmentLine; "Warehouse Shipment Line")
                    {
                        DataItemLink = "No." = WarehouseShipmentHeader."No.", "Source Type" = WarehouseRequest."Source Type", "Source Subtype" = WarehouseRequest."Source Subtype", "Source No." = WarehouseRequest."Source No.";
                        column(SumQtyToShip; "Qty. to Ship")
                        {
                            Method = Sum;
                        }
                    }
                }
            }
        }
    }
}

