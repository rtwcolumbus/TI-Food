query 37002022 "Lots by Location-Bin-Status"
{
    // PRW110.0.02
    // P80039781, To-Increase, Jack Reynolds, 10 DEC 17
    //   Warehouse Shipping process

    Caption = 'Lots by Location-Bin-Status';

    elements
    {
        dataitem(LotNoInformation; "Lot No. Information")
        {
            filter(ItemNo; "Item No.")
            {
            }
            filter(VariantCode; "Variant Code")
            {
            }
            filter(UOMFilter; "Unit of Measure Filter")
            {
            }
            column(LotNo; "Lot No.")
            {
            }
            filter(LocationFilter; "Location Filter")
            {
            }
            filter(BinFilter; "Bin Filter")
            {
            }
            filter(Inventory; "Inventory (Warehouse)")
            {
                ColumnFilter = Inventory = FILTER(<> 0);
            }
            dataitem(LotStatusCode; "Lot Status Code")
            {
                DataItemLink = Code = LotNoInformation."Lot Status Code";
                filter(AvailableForSale; "Available for Sale")
                {
                }
                filter(AvailableForPurchase; "Available for Purchase")
                {
                }
                filter(AvailableForTransfer; "Available for Transfer")
                {
                }
                filter(AvailableForConsumption; "Available for Consumption")
                {
                }
                filter(AvailableForAdjustment; "Available for Adjustment")
                {
                }
                filter(AvailableForPlanning; "Available for Planning")
                {
                }
            }
        }
    }
}

