codeunit 37002126 "Accrual Jnl.-B.Post"
{
    // PR3.61AC

    TableNo = "Accrual Journal Batch";

    trigger OnRun()
    begin
        AccrualJnlBatch.Copy(Rec);
        Code;
        Rec := AccrualJnlBatch;
    end;

    var
        Text000: Label 'Do you want to post the journals?';
        Text001: Label 'The journals were successfully posted.';
        Text002: Label 'It was not possible to post all of the journals. ';
        Text003: Label 'The journals that were not successfully posted are now marked.';
        AccrualJnlTemplate: Record "Accrual Journal Template";
        AccrualJnlBatch: Record "Accrual Journal Batch";
        AccrualJnlLine: Record "Accrual Journal Line";
        AccrualJnlPostBatch: Codeunit "Accrual Jnl.-Post Batch";
        JnlWithErrors: Boolean;

    local procedure "Code"()
    begin
        with AccrualJnlBatch do begin
            AccrualJnlTemplate.Get("Journal Template Name");
            AccrualJnlTemplate.TestField("Force Posting Report", false);

            if not Confirm(Text000) then
                exit;

            Find('-');
            repeat
                AccrualJnlLine."Journal Template Name" := "Journal Template Name";
                AccrualJnlLine."Journal Batch Name" := Name;
                AccrualJnlLine."Line No." := 1;
                Clear(AccrualJnlPostBatch);
                if AccrualJnlPostBatch.Run(AccrualJnlLine) then
                    Mark(false)
                else begin
                    Mark(true);
                    JnlWithErrors := true;
                end;
            until Next = 0;

            if not JnlWithErrors then
                Message(Text001)
            else
                Message(
                  Text002 +
                  Text003);

            if not Find('=><') then begin
                Reset;
                FilterGroup(2);
                SetRange("Journal Template Name", "Journal Template Name");
                FilterGroup(0);
                Name := '';
            end;
        end;
    end;
}

