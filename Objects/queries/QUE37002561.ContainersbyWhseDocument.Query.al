query 37002561 "Containers by Whse. Document"
{
    // PRW110.0.02
    // P80046533, To-Increase, Jack Reynolds, 10 OCT 17
    //   Inbound containers and shipping containers

    Caption = 'Containers by Whse. Document';

    elements
    {
        dataitem(ContainerHeader; "Container Header")
        {
            filter(WhseDocumentType; "Whse. Document Type")
            {
            }
            filter(WhseDocumentNo; "Whse. Document No.")
            {
            }
            filter(ShipReceive; "Ship/Receive")
            {
            }
            column(DocumentType; "Document Type")
            {
            }
            column(DocumentSubtype; "Document Subtype")
            {
            }
            column(DocumentNo; "Document No.")
            {
            }
            column(DocumentRefNo; "Document Ref. No.")
            {
            }
            column(LineCount)
            {
                Method = Count;
            }
        }
    }
}

