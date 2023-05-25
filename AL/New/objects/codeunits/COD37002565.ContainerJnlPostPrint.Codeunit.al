codeunit 37002565 "Container Jnl.-Post+Print"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Confirms posting and printing of posting report of batch

    TableNo = "Container Journal Line";

    trigger OnRun()
    begin
        ContJnlLine.Copy(Rec);
        Code;
        Rec.Copy(ContJnlLine);
    end;

    var
        ContJnlTemplate: Record "Container Journal Template";
        ContJnlLine: Record "Container Journal Line";
        ContReg: Record "Container Register";
        ContJnlPostBatch: Codeunit "Container Jnl.-Post Batch";
        TempJnlBatchName: Code[10];
        Text001: Label 'Do you want to post the journal lines and print the posting report?';
        Text002: Label 'There is nothing to post.';
        Text003: Label 'The journal lines were successfully posted.';
        Text004: Label 'The journal lines were successfully posted. ';
        Text005: Label 'You are now in the %1 journal.';

    local procedure "Code"()
    begin
        with ContJnlLine do begin
            ContJnlTemplate.Get("Journal Template Name");
            ContJnlTemplate.TestField("Posting Report ID");

            if not Confirm(Text001) then
                exit;

            TempJnlBatchName := "Journal Batch Name";

            ContJnlPostBatch.Run(ContJnlLine);

            if ContReg.Get("Register No.") then begin
                ContReg.SetRecFilter;
                REPORT.Run(ContJnlTemplate."Posting Report ID", false, false, ContReg);
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

