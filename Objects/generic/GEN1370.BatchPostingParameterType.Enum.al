enum 1370 "Batch Posting Parameter Type"
{
    // PRW120.00
    // P800144605, To Increase, Jack Reynolds, 20 APR 22
    //   Upgrade to 20.0
    
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "Invoice") { Caption = 'Invoice'; }
    value(1; "Ship") { Caption = 'Ship'; }
    value(2; "Receive") { Caption = 'Receive'; }
    value(3; "Posting Date") { Caption = 'Posting Date'; }
    value(4; "Replace Posting Date") { Caption = 'Replace Posting Date'; }
    value(5; "Replace Document Date") { Caption = 'Replace Document Date'; }
    value(6; "Calculate Invoice Discount") { Caption = 'Calculate Invoice Discount'; }
    value(7; "Print") { Caption = 'Print'; }
    value(3700200; FOODRepackTransfer) { Caption = 'Repack-Transfer'; }
    value(3700201; FOODRepackProduce) { Caption = 'Repack-Produce'; }
}