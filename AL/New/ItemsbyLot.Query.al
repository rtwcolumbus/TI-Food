query 37002020 "Items by Lot"
{
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 17 MAR 16
    //   Incorporate modifications for NAV Anywhere processes

    Caption = 'Items by Lot';

    elements
    {
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {
            column(Item_No; "Item No.")
            {
            }
            column(Location_Code; "Location Code")
            {
            }
            column(Variant_Code; "Variant Code")
            {
            }
            column(Lot_No; "Lot No.")
            {
                ColumnFilter = Lot_No = FILTER(<> '');
            }
            column(Sum_Quantity; Quantity)
            {
                ColumnFilter = Sum_Quantity = FILTER(<> 0);
                Method = Sum;
            }
        }
    }
}

