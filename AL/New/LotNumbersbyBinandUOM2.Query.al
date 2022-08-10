query 37002102 "Lot Numbers by Bin and UOM 2"
{
    // P800-MegaApp

    Caption = 'Lot Numbers by Bin and UOM';
    OrderBy = Ascending(Lot_No);

    elements
    {
        dataitem(Warehouse_Entry; "Warehouse Entry")
        {
            filter(OpenEntry; Open)
            {
                ColumnFilter = OpenEntry = const(true);
            }
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
            }
            column(Serial_No; "Serial No.")
            {
            }
            column(Package_No; "Package No.")
            {
            }
            column(Unit_of_Measure_Code; "Unit of Measure Code")
            {
            }
            column(Sum_Qty_Base; "Remaining Qty. (Base)")
            {
                Method = Sum;
            }
            column(Sum_Qty_Alt; "Remaining Qty. (Alt.)")
            {
                Method = Sum;
            }
        }
    }
}

