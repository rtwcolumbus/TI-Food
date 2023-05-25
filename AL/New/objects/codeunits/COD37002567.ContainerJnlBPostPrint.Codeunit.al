codeunit 37002567 "Container Jnl.-B.Post+Print"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Confirms posting and printing of posting report of multiple batches

    TableNo = "Container Journal Batch";

    trigger OnRun()
    begin
        ContJnlBatch.Copy(Rec);
        Code;
        Rec := ContJnlBatch;
    end;

    var
        ContJnlTemplate: Record "Container Journal Template";
        ContJnlBatch: Record "Container Journal Batch";
        ContJnlLine: Record "Container Journal Line";
        ContReg: Record "Container Register";
        ContJnlPostBatch: Codeunit "Container Jnl.-Post Batch";
        JnlWithErrors: Boolean;
        Text000: Label 'Do you want to post the journals and print the posting report?';
        Text001: Label 'The journals were successfully posted.';
        Text002: Label 'It was not possible to post all of the journals. ';
        Text003: Label 'The journals that were not successfully posted are now marked.';

    local procedure "Code"()
    begin
        with ContJnlBatch do begin
            ContJnlTemplate.Get("Journal Template Name");
            ContJnlTemplate.TestField("Posting Report ID");

            if not Confirm(Text000) then
                exit;

            Find('-');
            repeat
                ContJnlLine."Journal Template Name" := "Journal Template Name";
                ContJnlLine."Journal Batch Name" := Name;
                ContJnlLine."Line No." := 1;
                Clear(ContJnlPostBatch);
                if ContJnlPostBatch.Run(ContJnlLine) then begin
                    Mark(false);
                    if ContReg.Get(ContJnlLine."Register No.") then begin
                        ContReg.SetRecFilter;
                        REPORT.Run(ContJnlTemplate."Posting Report ID", false, false, ContReg);
                    end;
                end else begin
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
                Name := '';
            end;
        end;
    end;
}

