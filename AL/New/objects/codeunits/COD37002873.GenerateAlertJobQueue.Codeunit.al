codeunit 37002873 "Generate Alert-Job Queue"
{
    // PRW17.10
    // P8001226, Columbus IT, Jack Reynolds, 01 OCT 13
    //   Generate alerts with background processing from job queue

    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        CODEUNIT.Run(CODEUNIT::"Data Collection Generate Alert");
    end;
}

