codeunit 37002125 "Accrual Jnl.-Post+Print"
{
    // PR3.61AC

    TableNo = "Accrual Journal Line";

    trigger OnRun()
    begin
        AccrualJnlLine.Copy(Rec);
        Code;
        Rec.Copy(AccrualJnlLine);
    end;

    var
        Text000: Label 'cannot be filtered when posting recurring journals';
        Text001: Label 'Do you want to post the journal lines and print the posting report?';
        Text002: Label 'There is nothing to post.';
        Text003: Label 'The journal lines were successfully posted.';
        Text004: Label 'The journal lines were successfully posted. ';
        Text005: Label 'You are now in the %1 journal.';
        AccrualJnlTemplate: Record "Accrual Journal Template";
        AccrualJnlLine: Record "Accrual Journal Line";
        AccrualReg: Record "Accrual Register";
        AccrualJnlPostBatch: Codeunit "Accrual Jnl.-Post Batch";
        TempJnlBatchName: Code[10];

    local procedure "Code"()
    begin
        with AccrualJnlLine do begin
            AccrualJnlTemplate.Get("Journal Template Name");
            AccrualJnlTemplate.TestField("Posting Report ID");
            if AccrualJnlTemplate.Recurring and (GetFilter("Posting Date") <> '') then
                FieldError("Posting Date", Text000);

            if not Confirm(Text001) then
                exit;

            TempJnlBatchName := "Journal Batch Name";

            AccrualJnlPostBatch.Run(AccrualJnlLine);

            if AccrualReg.Get("Line No.") then begin
                AccrualReg.SetRecFilter;
                REPORT.Run(AccrualJnlTemplate."Posting Report ID", false, false, AccrualReg);
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

