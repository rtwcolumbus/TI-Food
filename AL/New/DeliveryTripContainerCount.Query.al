query 37002332 "Delivery Trip Container Count"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Delivery Trip Container Count';

    elements
    {
        dataitem(DeliveryTrip; "N138 Delivery Trip")
        {
            filter(DeliveryTripNo; "No.")
            {
            }
            dataitem(WarehouseShipment; "Warehouse Shipment Header")
            {
                DataItemLink = "Delivery Trip" = DeliveryTrip."No.";
                dataitem(ContainerHeader; "Container Header")
                {
                    DataItemLink = "Whse. Document No." = WarehouseShipment."No.";
                    DataItemTableFilter = "Whse. Document Type" = CONST(Shipment);
                    filter(DocumentType; "Document Type")
                    {
                    }
                    filter(DocumentSubtype; "Document Subtype")
                    {
                    }
                    filter(DocumentNo; "Document No.")
                    {
                    }
                    column(Loaded; Loaded)
                    {
                    }
                    column(LineCount)
                    {
                        Method = Count;
                    }
                }
            }
        }
    }
}

