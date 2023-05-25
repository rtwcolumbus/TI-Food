codeunit 37002563 "Container Jnl.-Post Batch"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Posts container journal batch
    // 
    // PRW17.00
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets

    TableNo = "Container Journal Line";

    trigger OnRun()
    begin
        ContJnlLine.Copy(Rec);
        Code;
        Rec := ContJnlLine;
    end;

    var
        ContJnlTemplate: Record "Container Journal Template";
        ContJnlBatch: Record "Container Journal Batch";
        ContJnlLine: Record "Container Journal Line";
        Text000: Label 'cannot exceed %1 characters';
        Text001: Label 'Journal Batch Name    #1##########\\';
        Text002: Label 'Checking lines        #2######\';
        Text003: Label 'Posting lines         #3###### @4@@@@@@@@@@@@@';
        ContJnlLine2: Record "Container Journal Line";
        ContJnlLine3: Record "Container Journal Line";
        ContLedgEntry: Record "Container Ledger Entry";
        ContReg: Record "Container Register";
        ContJnlCheckLine: Codeunit "Container Jnl.-Check Line";
        ContJnlPostLine: Codeunit "Container Jnl.-Post Line";
        DimMgt: Codeunit DimensionManagement;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Window: Dialog;
        StartLineNo: Integer;
        LineCount: Integer;
        NoOfRecords: Integer;
        ContRegNo: Integer;
        LastDocNo: Code[20];
        LastDocNo2: Code[20];

    local procedure "Code"()
    var
        UpdateAnalysisView: Codeunit "Update Analysis View";
    begin
        with ContJnlLine do begin
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            if RecordLevelLocking then
                LockTable;

            ContJnlTemplate.Get("Journal Template Name");
            ContJnlBatch.Get("Journal Template Name", "Journal Batch Name");
            if StrLen(IncStr(ContJnlBatch.Name)) > MaxStrLen(ContJnlBatch.Name) then
                ContJnlBatch.FieldError(
                  Name,
                  StrSubstNo(
                    Text000,
                    MaxStrLen(ContJnlBatch.Name)));

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
                ContJnlCheckLine.RunCheck(ContJnlLine); // P8001133
                if Next = 0 then
                    Find('-');
            until "Line No." = StartLineNo;
            NoOfRecords := LineCount;

            ContLedgEntry.LockTable;
            ContReg.LockTable;
            if ContReg.Find('+') and (ContReg."To Entry No." = 0) then
                ContRegNo := ContReg."No."
            else
                ContRegNo := ContReg."No." + 1;

            // Post lines
            LineCount := 0;
            LastDocNo := '';
            LastDocNo2 := '';
            Find('-');
            repeat
                LineCount := LineCount + 1;
                Window.Update(3, LineCount);
                Window.Update(4, Round(LineCount / NoOfRecords * 10000, 1));
                if not EmptyLine and
                   (ContJnlBatch."No. Series" <> '') and
                   ("Document No." <> LastDocNo2)
                then
                    TestField("Document No.", NoSeriesMgt.GetNextNo(ContJnlBatch."No. Series", "Posting Date", false));
                LastDocNo2 := "Document No.";
                TestField("Document No.");
                ContJnlPostLine.RunWithCheck(ContJnlLine); // P8001133
            until Next = 0;

            // Copy register no. and current journal batch name to the container journal
            if not ContReg.Find('+') or (ContReg."No." <> ContRegNo) then
                ContRegNo := 0;

            Init;
            "Register No." := ContRegNo;

            // Update/delete lines
            ContJnlLine2.CopyFilters(ContJnlLine);
            ContJnlLine2.SetFilter("Container Item No.", '<>%1', '');
            if ContJnlLine2.Find('+') then; // Remember the last line
            ContJnlLine3.Copy(ContJnlLine);
            ContJnlLine3.DeleteAll; // P8001133
            ContJnlLine3.Reset;
            ContJnlLine3.SetRange("Journal Template Name", "Journal Template Name");
            ContJnlLine3.SetRange("Journal Batch Name", "Journal Batch Name");
            if not ContJnlLine3.Find('+') then
                if IncStr("Journal Batch Name") <> '' then begin
                    ContJnlBatch.Delete;
                    ContJnlBatch.Name := IncStr("Journal Batch Name");
                    if ContJnlBatch.Insert then;
                    "Journal Batch Name" := ContJnlBatch.Name;
                end;

            ContJnlLine3.SetRange("Journal Batch Name", "Journal Batch Name");
            if (ContJnlBatch."No. Series" = '') and not ContJnlLine3.Find('+') then begin
                ContJnlLine3.Init;
                ContJnlLine3."Journal Template Name" := "Journal Template Name";
                ContJnlLine3."Journal Batch Name" := "Journal Batch Name";
                ContJnlLine3."Line No." := 10000;
                ContJnlLine3.Insert;
                ContJnlLine3.SetUpNewLine(ContJnlLine2);
                ContJnlLine3.Modify;
            end;

            if ContJnlBatch."No. Series" <> '' then
                NoSeriesMgt.SaveNoSeries;
            Commit;
        end;
        UpdateAnalysisView.UpdateAll(0, true);
        Commit;
    end;
}

