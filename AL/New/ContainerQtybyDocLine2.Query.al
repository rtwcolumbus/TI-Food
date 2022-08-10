query 37002564 "Container Qty. by Doc. Line 2"
{
    // PRW111.00.01
    // P80075420, To-Increase, Jack Reynolds, 08 JUL 19
    //   Problem losing tracking when using containers and specifying alt quantity to handle

    Caption = 'Container Qty. by Doc. Line 2';

    elements
    {
        dataitem(ContainerLineApplication; "Container Line Application")
        {
            filter(ApplicationTableNo; "Application Table No.")
            {
            }
            filter(ApplicationSubtype; "Application Subtype")
            {
            }
            filter(ApplicationNo; "Application No.")
            {
            }
            filter(ApplicationBatchName; "Application Batch Name")
            {
            }
            filter(ApplicationLineNo; "Application Line No.")
            {
            }
            column(SumQuantity; Quantity)
            {
                Method = Sum;
            }
            column(SumQuantityBase; "Quantity (Base)")
            {
                Method = Sum;
            }
            column(SumQuantityAlt; "Quantity (Alt.)")
            {
                Method = Sum;
            }
            dataitem(ContainerHeader; "Container Header")
            {
                DataItemLink = ID = ContainerLineApplication."Container ID";
                column(ShipReceive; "Ship/Receive")
                {
                }
                dataitem(ContainerLine; "Container Line")
                {
                    DataItemLink = "Container ID" = ContainerLineApplication."Container ID", "Line No." = ContainerLineApplication."Container Line No.";
                    column(LotNo; "Lot No.")
                    {
                    }
                    column(SerialNo; "Serial No.")
                    {
                    }
                }
            }
        }
    }
}

