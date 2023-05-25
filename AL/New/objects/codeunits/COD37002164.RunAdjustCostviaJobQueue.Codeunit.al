codeunit 37002164 "Run Adjust Cost via Job Queue"
{
    // PRW17.00.10
    // P8001227, Columbus IT, Don Bresee, 03 OCT 13
    //   New codeunit to run Cost Adjust process as a job using new periodic commit ability

    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        InvtAdjmt: Codeunit "Inventory Adjustment";
        UpdateItemAnalysisView: Codeunit "Update Item Analysis View";
    begin
        InvtSetup.Get;
        InvtAdjmt.SetProperties(false, InvtSetup."Adjust Cost - Post to G/L");
        InvtAdjmt.SetJobUpdateProperties(true);
        InvtAdjmt.SetLockingTimes(
          InvtSetup."Adjust Cost - Lock Time (s)", InvtSetup."Adjust Cost - Unlock Time (ms)");
        if (InvtSetup."Adjust Cost - Lock Time (s)" = 0) then
            LockTables;
        InvtAdjmt.MakeMultiLevelAdjmt;

        UpdateItemAnalysisView.UpdateAll(0, true);
    end;

    var
        InvtSetup: Record "Inventory Setup";

    local procedure LockTables()
    var
        ItemApplnEntry: Record "Item Application Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        AvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point";
        ValueEntry: Record "Value Entry";
    begin
        // Use locking sequence from Adjust Cost report
        ItemApplnEntry.LockTable;
        if not ItemApplnEntry.FindLast then
            exit;
        ItemLedgEntry.LockTable;
        if not ItemLedgEntry.FindLast then
            exit;
        AvgCostAdjmtEntryPoint.LockTable;
        if AvgCostAdjmtEntryPoint.FindLast then;
        ValueEntry.LockTable;
        if not ValueEntry.FindLast then
            exit;
    end;
}

