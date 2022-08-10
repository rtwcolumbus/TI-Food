enum 6236 "Sales Document Type From"
{
    #region
    // PRW117.3
    // P80096165, To Increase, Jack Reynolds, 16 FEB 21
    //   Upgrade to 17 - options to enums
    #endregion

    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "Quote") { Caption = 'Quote'; }
    value(1; "Blanket Order") { Caption = 'Blanket Order'; }
    // P80096165
    value(2; FOODStandingOrder) { Caption = 'Standing Order'; } 
    value(3; "Order") { Caption = 'Order'; }
    value(4; "Invoice") { Caption = 'Invoice'; }
    value(5; "Return Order") { Caption = 'Return Order'; }
    value(6; "Credit Memo") { Caption = 'Credit Memo'; }
    // P80096165
    value(7; "Posted Shipment") { Caption = 'Posted Shipment'; }
    value(8; "Posted Invoice") { Caption = 'Posted Invoice'; }
    value(9; "Posted Return Receipt") { Caption = 'Posted Return Receipt'; }
    value(10; "Posted Credit Memo") { Caption = 'Posted Credit Memo'; }
    value(11; "Arch. Quote") { Caption = 'Arch. Quote'; }
    value(12; "Arch. Order") { Caption = 'Arch. Order'; }
    value(13; "Arch. Blanket Order") { Caption = 'Arch. Blanket Order'; }
    value(14; "Arch. Return Order") { Caption = 'Arch. Return Order'; }
}