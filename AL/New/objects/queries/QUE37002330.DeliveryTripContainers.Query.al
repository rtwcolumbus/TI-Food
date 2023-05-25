query 37002330 "Delivery Trip Containers"
{
    // PRW110.0.02
    // P80038966, To-Increase, Dayakar Battini, 20 NOV 17
    //   FOOD-TOM separation move objects
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW115.3
    // P800119529, To Increase, Jack Reynolds, 23 FEB 21
    //   Bring Container Ship/Receive to Delivery trip page

    Caption = 'Delivery Trip Containers';

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
                    column(ID; ID)
                    {
                    }
                    column(LicensePlate; "License Plate")
                    {
                    }
                    column(ContainerTypeCode; "Container Type Code")
                    {
                    }
                    column(ContainerDescription; Description)
                    {
                    }
                    column(Loaded; Loaded)
                    {
                    }
                    column(Ship; "Ship/Receive")
                    {
                    }
                    column(ContainerNetWeightBase; "Total Net Weight (Base)")
                    {
                    }
                    column(ContainerTareWeightBase; "Container Tare Weight (Base)")
                    {
                    }
                    column(ContaineLineTareWeightBase; "Line Tare Weight (Base)")
                    {
                    }
                    dataitem(ContainerLine; "Container Line")
                    {
                        DataItemLink = "Container ID" = ContainerHeader.ID;
                        column(LineNo; "Line No.")
                        {
                        }
                        column(ItemNo; "Item No.")
                        {
                        }
                        column(ItemDescription; Description)
                        {
                        }
                        column(VariantCode; "Variant Code")
                        {
                        }
                        column(LotNo; "Lot No.")
                        {
                        }
                        column(Quantity; Quantity)
                        {
                        }
                        column(UOMCode; "Unit of Measure Code")
                        {
                        }
                    }
                }
            }
        }
    }
}

