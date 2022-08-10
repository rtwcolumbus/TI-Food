codeunit 37002545 "Incident Management"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration
    // 
    // PRW111.00.02
    // P80064337, To-Increase, Jack Reynolds, 06 SEP 18
    //   Missing or misspelled caption


    trigger OnRun()
    begin
    end;

    var
        ConfirmCreateIncidentTxt: Label 'Do you want to create a new incident entry for %1?';
        ConfirmCreateIncidentResTxt: Label 'Do you want to create a new resolution entry for %1?';
        ConfirmAcceptIncidentResTxt: Label 'Do you want to accept the resolution entry %1?';
        TempIncidentSearchSetup: Record "Incident Search Setup" temporary;
        SourceFieldCaption: array[10] of Text;
        SourceFieldData: array[10] of Variant;
        ErrorAlreadyAcceptTxt: Label 'Incident resolution entry %1 already accepted. ';

    procedure CreateEntryFromSource(RecRef: RecordRef)
    var
        IncidentEntry: Record "Incident Entry";
        TempIncidentEntry: Record "Incident Entry" temporary;
        PrimaryKey: Text;
        KeyFldRef: FieldRef;
        KeyRef1: KeyRef;
        i: Integer;
        IncidentConfirm: Page "Incident Entries-Confirm";
        NewComment: Text;
        IncidentCommentMgt: Codeunit "Incident Comments Mgt.";
        TempCommentLine: Record "Incident Comment Line" temporary;
    begin
        if not Confirm(StrSubstNo(ConfirmCreateIncidentTxt, Format(RecRef.RecordId), true)) then
            exit;
        TempIncidentEntry.Init;

        TempIncidentEntry."Table No." := RecRef.Number;
        TempIncidentEntry."Source Record ID" := RecRef.RecordId;
        TempIncidentEntry.SourceRecordID := CopyStr(Format(TempIncidentEntry."Source Record ID"), 1, 249);
        TempIncidentEntry.SourceRecordID2 := CopyStr(Format(TempIncidentEntry."Source Record ID"), 250, 499);

        KeyRef1 := RecRef.KeyIndex(1);
        for i := 1 to KeyRef1.FieldCount do begin
            KeyFldRef := KeyRef1.FieldIndex(i);
            case i of
                1:
                    begin
                        TempIncidentEntry."Primary Key Field 1 No." := KeyFldRef.Number;
                        TempIncidentEntry."Primary Key Field 1 Value" := Format(KeyFldRef.Value, 0, 9);
                    end;
                2:
                    begin
                        TempIncidentEntry."Primary Key Field 2 No." := KeyFldRef.Number;
                        TempIncidentEntry."Primary Key Field 2 Value" := Format(KeyFldRef.Value, 0, 9);
                    end;
                3:
                    begin
                        TempIncidentEntry."Primary Key Field 3 No." := KeyFldRef.Number;
                        TempIncidentEntry."Primary Key Field 3 Value" := Format(KeyFldRef.Value, 0, 9);
                    end;
            end;
        end;
        TempIncidentEntry.Insert;
        GetFieldMappingSetup(TempIncidentEntry);
        GetSourceFieldDetails(TempIncidentEntry);
        IncidentConfirm.SetCurrentRecord(TempIncidentEntry, SourceFieldCaption, SourceFieldData);
        IncidentConfirm.LookupMode := true;
        if (IncidentConfirm.RunModal <> ACTION::LookupOK) then
            exit;
        IncidentConfirm.GetCurrentRecord(TempIncidentEntry, NewComment);

        IncidentEntry := TempIncidentEntry;
        IncidentEntry."Entry No." := GetLastEntryNo + 1;
        IncidentEntry."Created By" := UserId;
        IncidentEntry."Created On" := CurrentDateTime;
        IncidentEntry.Insert;

        UpdateSourceFieldDetails(TempIncidentSearchSetup, IncidentEntry);
        TempCommentLine.Init;
        TempCommentLine."Incident Entry No." := IncidentEntry."Entry No.";
        TempCommentLine."Table ID" := IncidentEntry."Table No.";
        TempCommentLine."User ID" := UserId;
        TempCommentLine.Date := WorkDate;
        TempCommentLine."Date and Time" := CurrentDateTime;
        TempCommentLine."Incident Entry Record ID" := IncidentEntry."Source Record ID";
        TempCommentLine.Insert;
        if NewComment <> '' then
            IncidentCommentMgt.InsertIncidentCommentLines(NewComment, TempCommentLine, true);
    end;

    local procedure GetLastEntryNo(): Integer
    var
        LastIncidentEntry: Record "Incident Entry";
    begin
        if LastIncidentEntry.FindLast then
            exit(LastIncidentEntry."Entry No.");
    end;

    procedure CreateToDo(IncidentEntry: Record "Incident Entry")
    var
        ToDo: Record "To-do";
        TempToDo: Record "To-do" temporary;
        IncidentCreateTodoMgmt: Codeunit "Incident Create To-do Mgmt.";
    begin
        IncidentEntry.TestField("Salesperson Code");
        ToDo.SetRange("Salesperson Code", IncidentEntry."Salesperson Code");
        ToDo.Init;
        BindSubscription(IncidentCreateTodoMgmt);
        TempToDo.CreateTaskFromTask(ToDo);
        UnbindSubscription(IncidentCreateTodoMgmt);
        IncidentEntry."To-do No." := IncidentCreateTodoMgmt.GetToDo;
        IncidentEntry.Modify;
    end;

    procedure CreateResolutionEntry(var IncidentEntry: Record "Incident Entry")
    var
        TempIncidentResEntry: Record "Incident Resolution Entry" temporary;
        IncidentResEntry: Record "Incident Resolution Entry";
        PrimaryKey: Text;
        KeyFldRef: FieldRef;
        KeyRef1: KeyRef;
        i: Integer;
        IncidentConfirm: Page "Incident Res. Entries-Confirm";
        NewComment: Text;
        IncidentCommentMgt: Codeunit "Incident Comments Mgt.";
        TempCommentLine: Record "Incident Comment Line" temporary;
    begin
        IncidentEntry.TestField(Archived, false);

        if not Confirm(StrSubstNo(ConfirmCreateIncidentResTxt, Format(IncidentEntry."Entry No."), true)) then
            exit;
        TempIncidentResEntry.Init;
        TempIncidentResEntry."Incident Entry No." := IncidentEntry."Entry No.";
        TempIncidentResEntry."Incident Entry Record ID" := IncidentEntry."Source Record ID";
        TempIncidentResEntry.Insert;
        IncidentConfirm.SetCurrentRecord(TempIncidentResEntry);
        IncidentConfirm.LookupMode := true;
        if (IncidentConfirm.RunModal <> ACTION::LookupOK) then
            exit;
        IncidentConfirm.GetCurrentRecord(TempIncidentResEntry, NewComment);

        IncidentResEntry.Init;
        IncidentResEntry := TempIncidentResEntry;
        IncidentResEntry."Entry No." := GetLastResEntryNo + 1;
        IncidentResEntry."User ID" := UserId;
        IncidentResEntry."Date and Time" := CurrentDateTime;
        IncidentResEntry.Insert;

        TempCommentLine.Init;
        TempCommentLine."Incident Entry No." := IncidentResEntry."Entry No.";
        TempCommentLine."Table ID" := DATABASE::"Incident Resolution Entry";
        TempCommentLine."User ID" := UserId;
        TempCommentLine.Date := WorkDate;
        TempCommentLine."Date and Time" := CurrentDateTime;
        TempCommentLine."Incident Entry Record ID" := IncidentResEntry."Incident Entry Record ID";
        TempCommentLine.Insert;
        if NewComment <> '' then
            IncidentCommentMgt.InsertIncidentResCommentLines(NewComment, TempCommentLine, true);
    end;

    local procedure GetLastResEntryNo(): Integer
    var
        LastIncidentResEntry: Record "Incident Resolution Entry";
    begin
        if LastIncidentResEntry.FindLast then
            exit(LastIncidentResEntry."Entry No.");
    end;

    procedure AcceptResolution(var IncidentEntry: Record "Incident Entry")
    var
        IncidentResEntry: Record "Incident Resolution Entry";
    begin
        IncidentEntry.TestField(Archived, false);

        IncidentResEntry.SetRange("Incident Entry No.", IncidentEntry."Entry No.");
        IncidentResEntry.SetRange(Active, true);
        IncidentResEntry.FindFirst;
        if IncidentResEntry.Accept then
            Error(ErrorAlreadyAcceptTxt, Format(IncidentResEntry."Entry No."));
        if not Confirm(StrSubstNo(ConfirmAcceptIncidentResTxt, Format(IncidentResEntry."Entry No."), true)) then
            exit;

        IncidentResEntry.Validate(Accept, true);
        IncidentResEntry.Modify;
    end;

    procedure GetFieldMappingSetup(var TempIncidentEntry: Record "Incident Entry" temporary)
    var
        IncidentSearchSetup: Record "Incident Search Setup";
    begin
        IncidentSearchSetup.SetRange("Table No.", TempIncidentEntry."Table No.");
        IncidentSearchSetup.SetFilter("Incident Entry Field No.", '<>%1', 0);
        if IncidentSearchSetup.FindFirst then
            repeat
                TempIncidentSearchSetup := IncidentSearchSetup;
                if TempIncidentSearchSetup.Insert then;
            until IncidentSearchSetup.Next = 0;
    end;

    procedure UpdateSourceFieldDetails(var TempIncidentSearchSetup: Record "Incident Search Setup" temporary; var IncidentEntry: Record "Incident Entry")
    var
        SourceRecRef: RecordRef;
        SourceFieldRef: FieldRef;
        IncidentRecRef: RecordRef;
        IncidentFieldRef: FieldRef;
    begin
        SourceRecRef.Get(IncidentEntry."Source Record ID");
        IncidentRecRef.Get(IncidentEntry.RecordId);

        if TempIncidentSearchSetup.FindFirst then
            repeat
                Clear(SourceFieldRef);
                Clear(IncidentFieldRef);
                if SourceRecRef.FieldExist(TempIncidentSearchSetup."Field No.") then begin
                    SourceFieldRef := SourceRecRef.Field(TempIncidentSearchSetup."Field No.");
                    if IncidentRecRef.FieldExist(TempIncidentSearchSetup."Incident Entry Field No.") then begin
                        IncidentFieldRef := IncidentRecRef.Field(TempIncidentSearchSetup."Incident Entry Field No.");
                        IncidentFieldRef.Value := SourceFieldRef.Value;
                        IncidentRecRef.Modify;
                    end;
                end;
            until TempIncidentSearchSetup.Next = 0;
    end;

    procedure GetSourceFieldDetails(var IncidentEntry: Record "Incident Entry")
    var
        SourceRecRef: RecordRef;
        SourceFieldRef: FieldRef;
        i: Integer;
    begin
        SourceRecRef.Get(IncidentEntry."Source Record ID");

        if TempIncidentSearchSetup.FindFirst then
            repeat
                i += 1;
                Clear(SourceFieldRef);
                if SourceRecRef.FieldExist(TempIncidentSearchSetup."Field No.") then begin
                    SourceFieldRef := SourceRecRef.Field(TempIncidentSearchSetup."Field No.");
                    SourceFieldCaption[i] := SourceFieldRef.Caption;
                    SourceFieldData[i] := SourceFieldRef.Value;
                end;
            until (TempIncidentSearchSetup.Next = 0) or (i >= 10);
    end;
}

