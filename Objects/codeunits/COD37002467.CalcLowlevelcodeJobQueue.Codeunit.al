codeunit 37002467 "Calc. Low-level code-Job Queue"
{
    // PRW17.10
    // P8001226, Columbus IT, Jack Reynolds, 01 OCT 13
    //   Calculate low-level code with background processing from job queue

    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        CODEUNIT.Run(CODEUNIT::"Calc. Low-level code");
    end;
}

