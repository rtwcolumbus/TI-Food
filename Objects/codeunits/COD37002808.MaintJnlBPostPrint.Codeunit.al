codeunit 37002808 "Maint. Jnl.-B.Post+Print"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   Standard cost for Jnl.-B.Post+Print codeunit adapted for maintenance journal

    TableNo = "Maintenance Journal Batch";

    trigger OnRun()
    begin
        MaintJnlBatch.Copy(Rec);
        Code;
        Rec := MaintJnlBatch;
    end;

    var
        MaintJnlTemplate: Record "Maintenance Journal Template";
        MaintJnlBatch: Record "Maintenance Journal Batch";
        MaintJnlLine: Record "Maintenance Journal Line";
        MaintReg: Record "Maintenance Register";
        MaintJnlPostBatch: Codeunit "Maint. Jnl.-Post Batch";
        JnlWithErrors: Boolean;
        Text000: Label 'Do you want to post the journals and print the posting report?';
        Text001: Label 'The journals were successfully posted.';
        Text002: Label 'It was not possible to post all of the journals. ';
        Text003: Label 'The journals that were not successfully posted are now marked.';

    local procedure "Code"()
    begin
        with MaintJnlBatch do begin
            MaintJnlTemplate.Get("Journal Template Name");
            MaintJnlTemplate.TestField("Posting Report ID");

            if not Confirm(Text000) then
                exit;

            FindSet;
            repeat
                MaintJnlLine."Journal Template Name" := "Journal Template Name";
                MaintJnlLine."Journal Batch Name" := Name;
                MaintJnlLine."Line No." := 1;
                Clear(MaintJnlPostBatch);
                if MaintJnlPostBatch.Run(MaintJnlLine) then begin
                    Mark(false);
                    if MaintReg.Get(MaintJnlLine."Line No.") then begin
                        MaintReg.SetRecFilter;
                        REPORT.Run(MaintJnlTemplate."Posting Report ID", false, false, MaintReg);
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

