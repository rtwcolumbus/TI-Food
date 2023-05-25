enum 44 "Sales Comment Document Type"
{
    #region
    // PRW117.3
    // P80096165, To Increase, Jack Reynolds, 16 FEB 21
    //   Upgrade to 17 - options to enums
    #endregion

    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "Quote") { Caption = 'Quote'; }
    value(1; "Order") { Caption = 'Order'; }
    value(2; "Invoice") { Caption = 'Invoice'; }
    value(3; "Credit Memo") { Caption = 'Credit Memo'; }
    value(4; "Blanket Order") { Caption = 'Blanket Order'; }
    value(5; "Return Order") { Caption = 'Return Order'; }
    value(6; FOODStandingOrder) { Caption = 'Standing Order'; } // P80096165
    value(7; "Shipment") { Caption = 'Shipment'; }
    value(8; "Posted Invoice") { Caption = 'Posted Invoice'; }
    value(9; "Posted Credit Memo") { Caption = 'Posted Credit Memo'; }
    value(10; "Posted Return Receipt") { Caption = 'Posted Return Receipt'; }
}