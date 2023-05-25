query 37002333 "Delivery Trip History"
{
    // PRW19.00.01
    // P8006916, To-Increase, Dayakar Battini, 16 JUN 16
    //   FOOD-TOM Separation delete Transsmart objects
    // 
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Delivery Trip History';

    elements
    {
        dataitem(DeliveryTripHistory; "N138 Delivery Trip History")
        {
            filter(DeliveryTripNo; "No.")
            {
            }
            dataitem(PostedWhseShipment; "Posted Whse. Shipment Header")
            {
                DataItemLink = "Delivery Trip" = DeliveryTripHistory."No.";
                dataitem(PostedWhseShipmentLine; "Posted Whse. Shipment Line")
                {
                    DataItemLink = "No." = PostedWhseShipment."No.";
                    column(PostedSourceDocument; "Posted Source Document")
                    {
                    }
                    column(PostedSourceNo; "Posted Source No.")
                    {
                    }
                    column("Count")
                    {
                        Method = Count;
                    }
                }
            }
        }
    }
}

