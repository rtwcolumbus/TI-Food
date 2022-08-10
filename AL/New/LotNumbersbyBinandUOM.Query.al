query 37002101 "Lot Numbers by Bin and UOM"
{
    Caption = 'Lot Numbers by Bin and UOM';
    OrderBy = Ascending(Lot_No);

    elements
    {
        dataitem(Warehouse_Entry; "Warehouse Entry")
        {
            column(Location_Code; "Location Code")
            {
            }
            column(Item_No; "Item No.")
            {
            }
            column(Variant_Code; "Variant Code")
            {
            }
            column(Zone_Code; "Zone Code")
            {
            }
            column(Bin_Code; "Bin Code")
            {
            }
            column(Lot_No; "Lot No.")
            {
                ColumnFilter = Lot_No = FILTER(<> '');
            }
            column(UOM; "Unit of Measure Code")
            {
            }
            column(Quantity; Quantity)
            {
                ColumnFilter = Quantity = FILTER(<> 0);
                Method = Sum;
            }
        }
    }
}

