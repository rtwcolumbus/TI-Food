codeunit 37002546 "Incident Comments Mgt."
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration


    trigger OnRun()
    begin
    end;

    var
        IncidentEntryNo: Integer;

    procedure ReCreateIncidentComments(ContactCommentView: Text; NewExtendedComment: Text)
    var
        CommentLine: Record "Incident Comment Line";
        TempCommentLine: Record "Incident Comment Line" temporary;
        LineNoNewCommentLine: Integer;
    begin
        CommentLine.SetView(ContactCommentView);
        //copy info to temporary table
        CopyOldIncidentCommentDetails(TempCommentLine, CommentLine);
        //delete existing lines
        CommentLine.DeleteAll;

        //reinsert lines
        InsertIncidentCommentLines(NewExtendedComment, TempCommentLine, false);
    end;

    local procedure CopyOldIncidentCommentDetails(var TempCommentLine: Record "Incident Comment Line" temporary; var CommentLine: Record "Incident Comment Line"): Boolean
    begin
        if CommentLine.FindFirst then begin
            TempCommentLine := CommentLine;
            TempCommentLine.Insert;
            exit(true);
        end;
        exit(false);
    end;

    procedure InsertIncidentCommentLines(NewExtendedComment: Text; var TempCommentLine: Record "Incident Comment Line" temporary; FromEmptyLine: Boolean)
    var
        NewCommentLength: Integer;
        i: Integer;
        CommentLine: Record "Incident Comment Line";
        IncidentEntry: Record "Incident Entry";
    begin
        NewCommentLength := StrLen(NewExtendedComment);
        i := 1;
        while i <= NewCommentLength do begin
            CommentLine.TransferFields(TempCommentLine);
            if FromEmptyLine then
                CommentLine."Entry No." := FindLastEntryNo(TempCommentLine)
            else
                CommentLine."Entry No." := FindFirstEntryNo(TempCommentLine);
            CommentLine.Comment := CopyStr(NewExtendedComment, i, MaxStrLen(CommentLine.Comment));
            if IncidentEntry.Get(IncidentEntryNo) then
                CommentLine.Validate("Incident Entry No.", IncidentEntry."Entry No.");
            CommentLine.Insert(true);
            i += MaxStrLen(CommentLine.Comment);
        end;
    end;

    procedure InsertIncidentResCommentLines(NewExtendedComment: Text; var TempCommentLine: Record "Incident Comment Line" temporary; FromEmptyLine: Boolean)
    var
        NewCommentLength: Integer;
        i: Integer;
        CommentLine: Record "Incident Comment Line";
        IncidentEntry: Record "Incident Resolution Entry";
    begin
        NewCommentLength := StrLen(NewExtendedComment);
        i := 1;
        while i <= NewCommentLength do begin
            CommentLine.TransferFields(TempCommentLine);
            if FromEmptyLine then
                CommentLine."Entry No." := FindLastEntryNo(TempCommentLine)
            else
                CommentLine."Entry No." := FindFirstEntryNo(TempCommentLine);
            CommentLine.Comment := CopyStr(NewExtendedComment, i, MaxStrLen(CommentLine.Comment));
            if IncidentEntry.Get(IncidentEntryNo) then begin
                CommentLine."Table ID" := DATABASE::"Incident Resolution Entry";
                CommentLine.Validate("Incident Entry No.", IncidentEntry."Entry No.");
            end;
            CommentLine.Insert(true);
            i += MaxStrLen(CommentLine.Comment);
        end;
    end;

    local procedure FindFirstEntryNo(TempCommentLine: Record "Incident Comment Line" temporary): Integer
    var
        EntryNo: Integer;
        CommentLine: Record "Incident Comment Line";
    begin
        EntryNo := 1;
        while CommentLine.Get(EntryNo) do
            EntryNo += 1;
        exit(EntryNo);
    end;

    local procedure FindLastEntryNo(TempCommentLine: Record "Incident Comment Line" temporary): Integer
    var
        CommentLine: Record "Incident Comment Line";
    begin
        if CommentLine.FindLast then
            exit(CommentLine."Entry No." + 1)
        else
            exit(1);
    end;

    local procedure FindFirstUnusedLineNoCommentLine(TempCommentLine: Record "Comment Line" temporary): Integer
    var
        LineNo: Integer;
        CommentLine: Record "Comment Line";
    begin
        LineNo := 10000;
        while CommentLine.Get(TempCommentLine."Table Name", TempCommentLine."No.", LineNo) do
            LineNo += 10000;
        exit(LineNo);
    end;

    local procedure FindLastUnusedLineNoCommentLine(TempCommentLine: Record "Comment Line" temporary): Integer
    var
        CommentLine: Record "Comment Line";
    begin
        CommentLine.SetRange("Table Name", TempCommentLine."Table Name");
        CommentLine.SetRange("No.", TempCommentLine."No.");
        if CommentLine.FindLast then
            exit(CommentLine."Line No." + 10000)
        else
            exit(10000);
    end;

    procedure SetSource(IncidentEntry: Integer)
    begin
        IncidentEntryNo := IncidentEntry;
    end;

    procedure ReCreateIncidentResComments(ContactCommentView: Text; NewExtendedComment: Text)
    var
        CommentLine: Record "Incident Comment Line";
        TempCommentLine: Record "Incident Comment Line" temporary;
        LineNoNewCommentLine: Integer;
    begin
        CommentLine.SetView(ContactCommentView);
        //copy info to temporary table
        CopyOldIncidentResCommentDetails(TempCommentLine, CommentLine);
        //delete existing lines
        CommentLine.DeleteAll;

        //reinsert lines
        InsertIncidentResCommentLines(NewExtendedComment, TempCommentLine, false);
    end;

    local procedure CopyOldIncidentResCommentDetails(var TempCommentLine: Record "Incident Comment Line" temporary; var CommentLine: Record "Incident Comment Line"): Boolean
    begin
        if CommentLine.FindFirst then begin
            TempCommentLine := CommentLine;
            TempCommentLine.Insert;
            exit(true);
        end;
        exit(false);
    end;
}

