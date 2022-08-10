query 37002760 "Whse.Act.Line - Item-Lot"
{
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 17 MAR 16
    //   Incorporate modifications for NAV Anywhere processes
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Whse.Act.Line - Item-Lot';

    elements
    {
        dataitem(Warehouse_Activity_Line; "Warehouse Activity Line")
        {
            filter(ActivityType; "Activity Type")
            {
            }
            filter(No; "No.")
            {
            }
            filter(ActionType; "Action Type")
            {
            }
            column(BinCode; "Bin Code")
            {
            }
            column(ItemNo; "Item No.")
            {
            }
            column(VariantCode; "Variant Code")
            {
            }
            column(UOM; "Unit of Measure Code")
            {
            }
            column(LotNo; "Lot No.")
            {
            }
            column(QtyOutstanding; "Qty. Outstanding")
            {
                ColumnFilter = QtyOutstanding = FILTER(> 0);
                Method = Sum;
            }
        }
    }
}

