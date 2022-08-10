query 37002563 "Container Qty. by Doc. Line"
{
    // PRW110.0.02
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers
    // 
    // PRW111.00.01
    // P80060004, To Increase, Jack Reynolds, 14 JUN 18
    //   Add filter column for Applicatoin Batch Name
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Container Qty. by Doc. Line';

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
                    filter(LotNo; "Lot No.")
                    {
                    }
                    filter(SerialNo; "Serial No.")
                    {
                    }
                }
            }
        }
    }
}

