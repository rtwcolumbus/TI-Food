codeunit 37002134 "Batch Upd Acc Plans-Job Queue"
{
    // PRW16.00.04
    // P8000882, VerticalSoft, Jack Reynolds, 15 DEC 10
    //   Cover for Batch Update Accrual Plans to provide support for Job Queue

    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        CODEUNIT.Run(CODEUNIT::"Batch Update Accrual Plans");
    end;
}

