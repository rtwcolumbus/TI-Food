query 37002560 "Containers by Item/Lot"
{
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 17 MAR 16
    //   Incorporate modifications for NAV Anywhere processes
    // 
    // PRW111.00.01
    // P80056709, To-Increase, Jack Reynolds, 25 JUL 18
    //   Production Containers - assign container to production order
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Containers by Item/Lot';
    OrderBy = Descending(Sum_Quantity);

    elements
    {
        dataitem(Container_Line; "Container Line")
        {
            filter(Location_Code; "Location Code")
            {
            }
            filter(Bin_Code; "Bin Code")
            {
            }
            filter(Item_No; "Item No.")
            {
            }
            filter(Variant_Code; "Variant Code")
            {
            }
            filter(Unit_of_Measure_Code; "Unit of Measure Code")
            {
            }
            filter(Inbound; Inbound)
            {
            }
            column(Container_ID; "Container ID")
            {
            }
            column(Lot_No; "Lot No.")
            {
            }
            column(Sum_Quantity; Quantity)
            {
                Method = Sum;
            }
            column(Sum_Quantity_Base; "Quantity (Base)")
            {
                Method = Sum;
            }
            column(Sum_Quantity_Alt; "Quantity (Alt.)")
            {
                Method = Sum;
            }
            dataitem(Container_Header; "Container Header")
            {
                DataItemLink = ID = Container_Line."Container ID";
                SqlJoinType = InnerJoin;
                filter(Document_Type; "Document Type")
                {
                }
                column(Container_Type_Code; "Container Type Code")
                {
                }
                column(Container_Item_No; "Container Item No.")
                {
                }
                column(Total_Quantity_Base; "Total Quantity (Base)")
                {
                }
            }
        }
    }

    trigger OnBeforeOpen()
    begin
        SetRange(Inbound, false);
    end;
}

