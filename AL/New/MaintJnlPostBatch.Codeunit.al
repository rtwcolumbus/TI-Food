codeunit 37002803 "Maint. Jnl.-Post Batch"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   Standard code for posting journal batch adapted for maintenance journal
    // 
    // PRW16.00.01
    // P8000719, VerticalSoft, Jack Reynolds, 18 SEP 09
    //   Don't create new batch for combined journal called from work order
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets

    TableNo = "Maintenance Journal Line";

    trigger OnRun()
    begin
        MaintJnlLine.Copy(Rec);
        Code;
        Rec := MaintJnlLine;
    end;

    var
        MaintJnlTemplate: Record "Maintenance Journal Template";
        MaintJnlBatch: Record "Maintenance Journal Batch";
        MaintJnlLine: Record "Maintenance Journal Line";
        Text000: Label 'cannot exceed %1 characters';
        Text001: Label 'Journal Batch Name    #1##########\\';
        Text002: Label 'Checking lines        #2######\';
        Text003: Label 'Posting lines         #3###### @4@@@@@@@@@@@@@';
        MaintJnlLine2: Record "Maintenance Journal Line";
        MaintJnlLine3: Record "Maintenance Journal Line";
        MaintEntry: Record "Maintenance Ledger";
        MaintReg: Record "Maintenance Register";
        MaintJnlCheckLine: Codeunit "Maint. Jnl.-Check Line";
        MaintJnlPostLine: Codeunit "Maint. Jnl.-Post Line";
        DimMgt: Codeunit DimensionManagement;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Window: Dialog;
        LineCount: Integer;
        StartLineNo: Integer;
        NoOfRecords: Integer;
        MaintRegNo: Integer;
        LastDocNo: Code[20];
        LastDocNo2: Code[20];

    local procedure "Code"()
    var
        TempMaintJnlLine: Record "Maintenance Journal Line" temporary;
        UpdateAnalysisView: Codeunit "Update Analysis View";
    begin
        with MaintJnlLine do begin
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");

            MaintJnlTemplate.Get("Journal Template Name");
            MaintJnlBatch.Get("Journal Template Name", "Journal Batch Name");
            if StrLen(IncStr(MaintJnlBatch.Name)) > MaxStrLen(MaintJnlBatch.Name) then
                MaintJnlBatch.FieldError(
                  Name,
                  StrSubstNo(
                    Text000,
                    MaxStrLen(MaintJnlBatch.Name)));

            if not Find('=><') then begin
                "Line No." := 0;
                Commit;
                exit;
            end;

            Window.Open(
              Text001 +
              Text002 +
              Text003);
            Window.Update(1, "Journal Batch Name");

            // Check lines
            LineCount := 0;
            StartLineNo := "Line No.";
            repeat
                LineCount := LineCount + 1;
                Window.Update(2, LineCount);
                MaintJnlCheckLine.RunCheck(MaintJnlLine); // P8001133
                TempMaintJnlLine := MaintJnlLine;
                TempMaintJnlLine.Insert;
                if Next = 0 then
                    FindFirst;
            until "Line No." = StartLineNo;
            NoOfRecords := LineCount;


            // Find next register no.
            MaintEntry.LockTable;

            if RecordLevelLocking then
                if MaintEntry.FindLast then;
            MaintReg.LockTable;
            if MaintReg.FindLast then
                MaintRegNo := MaintReg."No." + 1
            else
                MaintRegNo := 1;

            // Post lines
            LineCount := 0;
            LastDocNo := '';
            LastDocNo2 := '';
            FindSet(true, false);
            repeat
                LineCount := LineCount + 1;
                Window.Update(3, LineCount);
                Window.Update(4, Round(LineCount / NoOfRecords * 10000, 1));
                if not EmptyLine and
                   (MaintJnlBatch."No. Series" <> '') and
                   ("Document No." <> LastDocNo2)
                then
                    TestField("Document No.", NoSeriesMgt.GetNextNo(MaintJnlBatch."No. Series", "Posting Date", false));
                LastDocNo2 := "Document No.";
                TestField("Document No.");
                MaintJnlPostLine.RunWithCheck(MaintJnlLine); // P8001133
            until Next = 0;

            // Copy register no. and current journal batch name to the maintenance journal
            if not MaintReg.FindLast or (MaintReg."No." <> MaintRegNo) then
                MaintRegNo := 0;

            Init;
            "Line No." := MaintRegNo;

            // Update/delete lines
            MaintJnlLine2.CopyFilters(MaintJnlLine);
            if MaintJnlLine2.FindLast then; // Remember the last line
            MaintJnlLine3.Copy(MaintJnlLine);
            if MaintJnlLine3.FindSet(true, false) then
                MaintJnlLine3.DeleteAll; // P8001133
            MaintJnlLine3.Reset;
            MaintJnlLine3.SetRange("Journal Template Name", "Journal Template Name");
            MaintJnlLine3.SetRange("Journal Batch Name", "Journal Batch Name");
            if not MaintJnlLine3.FindLast then
                // P8000719
                FilterGroup(2);
            if GetFilter("Work Order No.") = '' then
                // P8000719
                if IncStr("Journal Batch Name") <> '' then begin
                    MaintJnlBatch.Delete;
                    MaintJnlBatch.Name := IncStr("Journal Batch Name");
                    if MaintJnlBatch.Insert then;
                    "Journal Batch Name" := MaintJnlBatch.Name;
                end;
            FilterGroup(0); // P8000719

            MaintJnlLine3.SetRange("Journal Batch Name", "Journal Batch Name");
            if (MaintJnlBatch."No. Series" = '') and not MaintJnlLine3.FindLast then begin
                MaintJnlLine3.Init;
                MaintJnlLine3."Journal Template Name" := "Journal Template Name";
                MaintJnlLine3."Journal Batch Name" := "Journal Batch Name";
                MaintJnlLine3."Line No." := 10000;
                MaintJnlLine3.Insert;
                MaintJnlLine3.SetUpNewLine(MaintJnlLine2);
                MaintJnlLine3.Modify;
            end;

            if MaintJnlBatch."No. Series" <> '' then
                NoSeriesMgt.SaveNoSeries;
            Commit;
        end;
        UpdateAnalysisView.UpdateAll(0, true);
        Commit;
    end;
}

