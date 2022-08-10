codeunit 37002806 "Maint. Jnl.-Post+Print"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   Standard cost for Jnl.-Post+Print codeunit adapted for maintenance journal

    TableNo = "Maintenance Journal Line";

    trigger OnRun()
    begin
        MaintJnlLine.Copy(Rec);
        Code;
        Rec.Copy(MaintJnlLine);
    end;

    var
        MaintJnlTemplate: Record "Maintenance Journal Template";
        MaintJnlLine: Record "Maintenance Journal Line";
        MaintReg: Record "Maintenance Register";
        MaintJnlPostBatch: Codeunit "Maint. Jnl.-Post Batch";
        TempJnlBatchName: Code[10];
        Text001: Label 'Do you want to post the journal lines and print the posting report?';
        Text002: Label 'There is nothing to post.';
        Text003: Label 'The journal lines were successfully posted.';
        Text004: Label 'The journal lines were successfully posted. ';
        Text005: Label 'You are now in the %1 journal.';

    local procedure "Code"()
    begin
        with MaintJnlLine do begin
            MaintJnlTemplate.Get("Journal Template Name");
            MaintJnlTemplate.TestField("Posting Report ID");

            if not Confirm(Text001) then
                exit;

            TempJnlBatchName := "Journal Batch Name";

            MaintJnlPostBatch.Run(MaintJnlLine);

            if MaintReg.Get("Line No.") then begin
                MaintReg.SetRecFilter;
                REPORT.Run(MaintJnlTemplate."Posting Report ID", false, false, MaintReg);
            end;

            if "Line No." = 0 then
                Message(Text002)
            else
                if TempJnlBatchName = "Journal Batch Name" then
                    Message(Text003)
                else
                    Message(
                      Text004 +
                      Text005,
                      "Journal Batch Name");

            if not Find('=><') or (TempJnlBatchName <> "Journal Batch Name") then begin
                Reset;
                FilterGroup(2);
                SetRange("Journal Template Name", "Journal Template Name");
                SetRange("Journal Batch Name", "Journal Batch Name");
                FilterGroup(0);
                "Line No." := 1;
            end;
        end;
    end;
}

