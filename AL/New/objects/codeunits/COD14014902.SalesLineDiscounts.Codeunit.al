codeunit 14014902 "Sales Line Discounts"
{
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   Running enhanced pages


    trigger OnRun()
    begin
        ProcessFns.RunSalesLineDiscounts('', false);
    end;

    var
        ProcessFns: Codeunit "Process 800 Functions";
}

