codeunit 37002542 "Incident Search Management"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration

    Permissions = TableData "Change Log Setup" = r,
                  TableData "Change Log Setup (Table)" = r,
                  TableData "Change Log Setup (Field)" = r,
                  TableData "Change Log Entry" = ri;
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        IncidentSearchSetup: Record "Incident Search Setup";
        TempIncidentSearchSetup: Record "Incident Search Setup" temporary;
        EntryNo: Integer;
        SetupRead: Boolean;
        IncidentCommentLine: Record "Incident Comment Line" temporary;
        SearchAny: Boolean;
        TempRecRef: Variant;
        LastEntryNo: Integer;
        Window: Dialog;
        SearchMsg: Label 'Searching for         #1######\';
        TotalRecMsg: Label 'Total                      #2######\', Comment = 'Counter';
        SearchingRecMsg: Label 'Searching              #3######\', Comment = 'Counter';
        PendingRecMsg: Label 'Pending                 #4######\', Comment = 'Counter';
        CompletedRecMsg: Label 'Completed            #5######\';
        FoundRecMsg: Label 'Found                   #6######';
        HitCount: Integer;

    procedure PerformSearch(FindWhat: Text; FindWhatResult: Text)
    begin
        if (FindWhat = '') and (FindWhatResult = '') then
            exit;

        if (not SetupRead) and (FindWhatResult = '') then
            Initialize(SearchAny);

        PerformRecordSearch(FindWhat, FindWhatResult);
    end;

    local procedure PerformRecordSearch(FindWhat: Text; FindWhatResult: Text)
    var
        SourceRecRef: RecordRef;
        xSourceRecRef: RecordRef;
        SourceFieldRef: FieldRef;
        TempFindWhat: Record "Incident Comment Line" temporary;
        SpaceCharPosition: Integer;
    begin
        if FindWhatResult <> '' then begin
            PrepareSearchContent(TempFindWhat, FindWhatResult);
            PerformRecordSearchInResultSet2(TempFindWhat);
        end else begin
            PrepareSearchContent(TempFindWhat, FindWhat);
            PerformRecordSearchInAll(TempFindWhat);
        end;
    end;

    local procedure PrepareSearchContent(var TempFindWhat: Record "Incident Comment Line" temporary; FindWhat: Text)
    var
        SourceRecRef: RecordRef;
        xSourceRecRef: RecordRef;
        SourceFieldRef: FieldRef;
        SpaceCharPosition: Integer;
    begin
        TempFindWhat.Reset;
        TempFindWhat.DeleteAll;
        TempFindWhat.Init;

        TempFindWhat."Entry No." += 1;
        TempFindWhat.Comment := FindWhat;  // Exact matching
        if TempFindWhat.Comment <> ' ' then
            TempFindWhat.Insert;

        if SearchAny then
            SpaceCharPosition := StrPos(FindWhat, ' ') - 1;

        if SpaceCharPosition = 0 then
            exit;

        while (FindWhat <> '') do begin
            if SpaceCharPosition <= 0 then
                SpaceCharPosition := StrLen(FindWhat);
            TempFindWhat."Entry No." += 1;
            TempFindWhat.Comment := DelChr(CopyStr(FindWhat, 1, SpaceCharPosition), '=', '');  // Individual words
            if TempFindWhat.Comment <> ' ' then
                TempFindWhat.Insert;
            FindWhat := CopyStr(FindWhat, SpaceCharPosition + 1, StrLen(FindWhat));
            SpaceCharPosition := StrPos(FindWhat, ' ');
        end;
    end;

    local procedure PerformRecordSearchInResultSet(var TempFindWhat: Record "Incident Comment Line" temporary)
    var
        SourceRecRef: RecordRef;
        SourceFieldRef: FieldRef;
        SpaceCharPosition: Integer;
        ResultLine: Record "Incident Comment Line" temporary;
        TotaRecCount: Integer;
        PendingRecCount: Integer;
        KeyRef1: KeyRef;
        KeyFieldRef: FieldRef;
        i: Integer;
    begin
        TotaRecCount := 0;
        PendingRecCount := 0;
        HitCount := 0;
        IncidentCommentLine.Reset;
        if IncidentCommentLine.FindFirst then
            repeat
                ResultLine := IncidentCommentLine;
                ResultLine.Insert;
                TotaRecCount += 1;
            until IncidentCommentLine.Next = 0;
        ResultLine.Reset;
        ResultLine.SetFilter("Table ID", '<>%1', 1);
        if ResultLine.FindFirst then begin
            Window.Open(
            SearchMsg +
            TotalRecMsg +
            SearchingRecMsg +
            PendingRecMsg +
            CompletedRecMsg +
            FoundRecMsg);
            repeat
                SourceRecRef.Get(ResultLine."Incident Entry Record ID");
                TempFindWhat.Reset;
                if TempFindWhat.FindFirst then
                    repeat
                        Window.Update(1, TempFindWhat.Comment);
                        Window.Update(2, TotaRecCount);
                        Window.Update(4, PendingRecCount);
                        Window.Update(5, TotaRecCount - PendingRecCount);
                        Window.Update(6, HitCount);

                        TempIncidentSearchSetup.Reset;
                        TempIncidentSearchSetup.SetRange("Table No.", SourceRecRef.Number);
                        if TempIncidentSearchSetup.FindFirst then begin
                            if StrPos(UpperCase(Format(SourceRecRef)), UpperCase(TempFindWhat.Comment)) <> 0 then
                                repeat
                                    if SourceRecRef.FieldExist(TempIncidentSearchSetup."Field No.") then begin
                                        SourceFieldRef := SourceRecRef.Field(TempIncidentSearchSetup."Field No.");
                                        if StrPos(UpperCase(Format(SourceFieldRef.Value)), UpperCase(TempFindWhat.Comment)) <> 0 then
                                            InsertFromSource(SourceRecRef, SourceFieldRef, true, false);
                                    end else begin
                                        KeyRef1 := SourceRecRef.KeyIndex(1);
                                        for i := 1 to KeyRef1.FieldCount do begin
                                            KeyFieldRef := KeyRef1.FieldIndex(i);
                                            if StrPos(UpperCase(Format(KeyFieldRef.Value)), UpperCase(TempFindWhat.Comment)) <> 0 then
                                                InsertFromSource(SourceRecRef, KeyFieldRef, true, false);
                                        end;
                                    end;
                                until TempIncidentSearchSetup.Next = 0;
                        end;
                    until TempFindWhat.Next = 0;
                if IncidentCommentLine.Get(ResultLine."Entry No.") then
                    if IncidentCommentLine."Source Field No." = ResultLine."Source Field No." then
                        IncidentCommentLine.Delete;
            until ResultLine.Next = 0;
            Window.Close;
        end;
    end;

    local procedure PerformRecordSearchInResultSet2(var TempFindWhat: Record "Incident Comment Line" temporary)
    var
        SourceRecRef: RecordRef;
        SourceFieldRef: FieldRef;
        SpaceCharPosition: Integer;
        ResultLine: Record "Incident Comment Line" temporary;
        TotaRecCount: Integer;
        PendingRecCount: Integer;
        i: Integer;
        KeyRef1: KeyRef;
        KeyFieldRef: FieldRef;
        j: Integer;
    begin
        TotaRecCount := 0;
        PendingRecCount := 0;
        HitCount := 0;
        IncidentCommentLine.Reset;
        if IncidentCommentLine.FindFirst then
            repeat
                ResultLine := IncidentCommentLine;
                ResultLine.Insert;
                TotaRecCount += 1;
            until IncidentCommentLine.Next = 0;
        ResultLine.Reset;
        ResultLine.SetFilter("Table ID", '<>%1', 1);
        if ResultLine.FindFirst then begin
            Window.Open(
            SearchMsg +
            TotalRecMsg +
            SearchingRecMsg +
            PendingRecMsg +
            CompletedRecMsg +
            FoundRecMsg);
            repeat
                SourceRecRef.Get(ResultLine."Incident Entry Record ID");
                TempFindWhat.Reset;
                if TempFindWhat.FindFirst then
                    repeat
                        Window.Update(1, TempFindWhat.Comment);
                        Window.Update(2, TotaRecCount);
                        Window.Update(4, PendingRecCount);
                        Window.Update(5, TotaRecCount - PendingRecCount);
                        Window.Update(6, HitCount);
                        if StrPos(UpperCase(Format(SourceRecRef)), UpperCase(TempFindWhat.Comment)) <> 0 then begin
                            for i := 1 to SourceRecRef.FieldCount do begin
                                if SourceRecRef.FieldExist(i) then begin
                                    SourceFieldRef := SourceRecRef.FieldIndex(i);
                                    if StrPos(UpperCase(Format(SourceFieldRef.Value)), UpperCase(TempFindWhat.Comment)) <> 0 then begin
                                        SourceFieldRef := SourceRecRef.FieldIndex(i);
                                        InsertFromSource(SourceRecRef, SourceFieldRef, true, false);
                                    end;
                                end else begin
                                    KeyRef1 := SourceRecRef.KeyIndex(1);
                                    for j := 1 to KeyRef1.FieldCount do begin
                                        KeyFieldRef := KeyRef1.FieldIndex(j);
                                        if StrPos(UpperCase(Format(KeyFieldRef.Value)), UpperCase(TempFindWhat.Comment)) <> 0 then
                                            InsertFromSource(SourceRecRef, KeyFieldRef, true, false);
                                    end;
                                end;
                            end;
                        end;
                    until TempFindWhat.Next = 0;
                if IncidentCommentLine.Get(ResultLine."Entry No.") then
                    if IncidentCommentLine."Source Field No." = ResultLine."Source Field No." then
                        IncidentCommentLine.Delete;
            until ResultLine.Next = 0;
            Window.Close;
        end;
    end;

    local procedure PerformRecordSearchInAll(var TempFindWhat: Record "Incident Comment Line" temporary)
    var
        SourceRecRef: RecordRef;
        xSourceRecRef: RecordRef;
        SourceFieldRef: FieldRef;
        SpaceCharPosition: Integer;
        FirstFieldRef: FieldRef;
        HandledObject: Record "Table Metadata" temporary;
        TotaRecCount: Integer;
        PendingRecCount: Integer;
    begin
        TempFindWhat.Reset;
        if TempFindWhat.FindFirst then begin
            Window.Open(
            SearchMsg +
            TotalRecMsg +
            SearchingRecMsg +
            PendingRecMsg +
            CompletedRecMsg +
            FoundRecMsg);
            repeat
                TempIncidentSearchSetup.Reset;
                if TempIncidentSearchSetup.FindFirst then
                    repeat
                        xSourceRecRef.Open(TempIncidentSearchSetup."Table No.");
                        TotaRecCount := xSourceRecRef.Count;
                        PendingRecCount := TotaRecCount;
                        if xSourceRecRef.FindFirst then
                            repeat
                                SourceRecRef.Get(xSourceRecRef.RecordId);
                                if not HandledObject.Get(TempIncidentSearchSetup."Table No.") and
                                  (TempIncidentSearchSetup."Field No." = 0)
                                then begin
                                    PendingRecCount -= 1;
                                    Window.Update(1, TempFindWhat.Comment);
                                    Window.Update(2, TotaRecCount);
                                    Window.Update(4, PendingRecCount);
                                    Window.Update(5, TotaRecCount - PendingRecCount);
                                    Window.Update(6, HitCount);

                                    HandledObject.ID := TempIncidentSearchSetup."Table No.";
                                    HandledObject.Insert;
                                    SourceFieldRef := SourceRecRef.FieldIndex(1);
                                    if StrPos(UpperCase(Format(SourceRecRef.Name)), UpperCase(TempFindWhat.Comment)) <> 0 then
                                        InsertFromSource(SourceRecRef, SourceFieldRef, false, true);
                                end else begin
                                    SourceFieldRef := SourceRecRef.Field(TempIncidentSearchSetup."Field No.");
                                    if StrPos(UpperCase(Format(SourceFieldRef.Value)), UpperCase(TempFindWhat.Comment)) <> 0 then
                                        InsertFromSource(SourceRecRef, SourceFieldRef, false, false);
                                end;
                            until xSourceRecRef.Next = 0;
                        xSourceRecRef.Close;
                    until TempIncidentSearchSetup.Next = 0;
            until TempFindWhat.Next = 0;
            Window.Close;
        end;
    end;

    procedure Initialize(FindAny: Boolean)
    var
        TableNumber: Integer;
        FieldNumber: Integer;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldIndex: Integer;
        ObjectRecRef: RecordRef;
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        SearchAny := FindAny;
        Clear(EntryNo);
        Clear(LastEntryNo);
        IncidentCommentLine.Reset;
        IncidentCommentLine.DeleteAll;
        TempIncidentSearchSetup.Reset;
        TempIncidentSearchSetup.DeleteAll;
        SetupRead := true;

        GetSearchSetup(DATABASE::"Incident Comment Line", 7);

        IncidentSearchSetup.Reset;
        if IncidentSearchSetup.FindFirst then
            repeat
                TempIncidentSearchSetup."Table No." := IncidentSearchSetup."Table No.";
                TempIncidentSearchSetup."Field No." := 0;
                if TempIncidentSearchSetup.Insert then;

                TempIncidentSearchSetup := IncidentSearchSetup;
                if TempIncidentSearchSetup.Insert then;
            until IncidentSearchSetup.Next = 0;
    end;

    procedure InitializeFindResultSet(FindAny: Boolean; var ResultSet: Record "Incident Comment Line" temporary)
    var
        TableNumber: Integer;
        FieldNumber: Integer;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldIndex: Integer;
        RecordField: Record "Field";
        TempRecord: Record "Field" temporary;
    begin
        SearchAny := FindAny;

        TempIncidentSearchSetup.Reset;
        TempIncidentSearchSetup.DeleteAll;
        SetupRead := true;

        LastEntryNo := EntryNo;
        if ResultSet.FindFirst then
            repeat
                RecordField.SetRange(TableNo, ResultSet."Table ID");
                if RecordField.FindFirst then
                    repeat
                        if not TempRecord.Get(RecordField.TableNo, RecordField."No.") then begin
                            RecRef.Get(RecordField.RecordId);
                            if RecRef.FieldExist(RecordField."No.") then
                                FieldRef := RecRef.Field(RecordField."No.");
                            if IsNormalField(FieldRef) then
                                GetSearchSetup(RecordField.TableNo, RecordField."No.");
                            TempRecord := RecordField;
                            TempRecord.Insert;
                        end;
                    until RecordField.Next = 0;
            until ResultSet.Next = 0;
    end;

    procedure GetSearchSetup(TableNumber: Integer; FieldNumber: Integer)
    begin
        if not TempIncidentSearchSetup.Get(TableNumber, FieldNumber) then begin
            TempIncidentSearchSetup.Init;
            TempIncidentSearchSetup."Table No." := TableNumber;
            TempIncidentSearchSetup."Field No." := FieldNumber;
            TempIncidentSearchSetup.Insert;
        end;
    end;

    local procedure InsertCommentLine(var FldRef: FieldRef; var RecRef: RecordRef; ObjectOnly: Boolean)
    var
        TableMetadata: Record "Table Metadata";
    begin
        EntryNo += 1;
        HitCount += 1;
        IncidentCommentLine.Init;
        IncidentCommentLine."Entry No." := EntryNo;
        IncidentCommentLine."Table ID" := RecRef.Number;
        IncidentCommentLine."Incident Entry Record ID" := RecRef.RecordId;
        IncidentCommentLine."Source Field No." := FldRef.Number;
        IncidentCommentLine."Source Field Name" := FldRef.Name;
        IncidentCommentLine.IncidentRecID := CopyStr(Format(IncidentCommentLine."Incident Entry Record ID"), 1, 249);
        IncidentCommentLine.IncidentRecID2 := CopyStr(Format(IncidentCommentLine."Incident Entry Record ID"), 250, 499);
        IncidentCommentLine.Comment := Format(FldRef.Value);
        if ObjectOnly then begin
            RecRef.SetTable(TableMetadata);
            IncidentCommentLine."Source Field No." := 0;
            IncidentCommentLine.Comment := TableMetadata.Name;
        end;
        IncidentCommentLine.Insert;
    end;

    procedure InsertFromSource(RecRef: RecordRef; FldRef: FieldRef; ResultSet: Boolean; ObjectOnly: Boolean)
    var
        xRecRef: RecordRef;
        TableMetadata: Record "Table Metadata";
        InsertRequired: Boolean;
        UpdateRequired: Boolean;
        NewFieldName: Text;
        NewFieldValue: Text;
    begin
        InsertRequired := false;
        UpdateRequired := false;
        if ObjectOnly then begin
            if TableMetadata.Get(RecRef.Number) then begin
                RecRef.Close;
                RecRef.Get(TableMetadata.RecordId);
            end;
        end;
        xRecRef.Open(RecRef.Number);
        if not xRecRef.ReadPermission then
            exit;

        if not xRecRef.Get(RecRef.RecordId) then
            exit;

        IncidentCommentLine.SetRange("Incident Entry Record ID", RecRef.RecordId);
        if ResultSet then
            IncidentCommentLine.SetFilter("Entry No.", '>%1', LastEntryNo);
        InsertRequired := IncidentCommentLine.IsEmpty;
        UpdateRequired := not InsertRequired;

        if UpdateRequired then begin
            IncidentCommentLine.FindFirst;
            if (IncidentCommentLine."Source Field Name" <> '') and (StrPos(IncidentCommentLine."Source Field Name", FldRef.Name) = 0) then begin
                NewFieldName := IncidentCommentLine."Source Field Name" + ';' + FldRef.Name;
                NewFieldValue := IncidentCommentLine.Comment + ';' + Format(FldRef.Value);
                if StrLen(NewFieldName) <= 250 then
                    IncidentCommentLine."Source Field Name" := NewFieldName;
                if StrLen(NewFieldName) <= 250 then
                    IncidentCommentLine.Comment := NewFieldValue;
                IncidentCommentLine.Hits += 1;
                HitCount += 1;
                IncidentCommentLine.Modify;
            end;
        end else begin
            InsertRequired := ObjectOnly and InsertRequired;
            InsertRequired := InsertRequired or ((not ObjectOnly) and (IsNormalField(FldRef)));
            if InsertRequired then
                InsertCommentLine(FldRef, RecRef, ObjectOnly);
        end;
    end;

    local procedure IsNormalField(FieldRef: FieldRef): Boolean
    begin
        exit(Format(FieldRef.Class) = 'Normal')
    end;

    procedure GetResultSet(var ResultLine: Record "Incident Comment Line" temporary)
    begin
        IncidentCommentLine.Reset;
        ResultLine.Copy(IncidentCommentLine, true);
    end;
}

