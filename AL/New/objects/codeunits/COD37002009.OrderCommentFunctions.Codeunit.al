codeunit 37002009 "Order Comment Functions" // Version: FOODNA
{
    // PRNA10.0.02
    // P80050509, To-Increase, Jack Reynolds, 20 DEC 17
    //   Subscription to insert comments for sales order
    // 
    // PRNA11.00
    // P80045696, To-Increase, Jack Reynolds, 11 APR 18
    //   Fix problem copying comments to order when order number has not been assigned


    trigger OnRun()
    begin
    end;

    var
        Delimeter: Label ',; ';
        Text001: Label 'Print On ';
        Text002: Label ' abcdefghijklmnopqrstuvwxyz.,';
        CommentLine: Record "Comment Line";
        Text003: Label '%1 is not a valid code.';

    procedure GetCommentCodes(TableNo: Integer; var CommentCode: array[10] of Code[5]; var CommentDesc: array[10] of Text[30]): Boolean
    begin
        case TableNo of
            CommentLine."Table Name"::Customer:
                SalesCommentCodes(CommentCode, CommentDesc);
            else
                exit(false);
        end;
        exit(true);
    end;

    procedure ValidateCommentFlags(TableNo: Integer; var CommentFlags: Code[30]): Boolean
    var
        pos: Integer;
        StartCode: Integer;
        "Code": Code[30];
        CommentCode: array[10] of Code[5];
        CommentDesc: array[10] of Text[30];
        CodeFound: array[10] of Boolean;
    begin
        if not GetCommentCodes(TableNo, CommentCode, CommentDesc) then
            exit(false);

        while pos < StrLen(CommentFlags) do begin
            pos += 1;
            if StrPos(Delimeter, CopyStr(CommentFlags, pos, 1)) = 0 then begin
                if StartCode = 0 then
                    StartCode := pos;
            end else begin
                if StartCode <> 0 then begin
                    Code := CopyStr(CommentFlags, StartCode, pos - StartCode);
                    CodeFound[MatchCode(CommentCode, Code)] := true;
                    StartCode := 0;
                end;
            end;
        end;
        if StartCode <> 0 then begin
            Code := CopyStr(CommentFlags, StartCode, 1 + pos - StartCode);
            CodeFound[MatchCode(CommentCode, Code)] := true;
        end;

        FormatCommentFlags(CodeFound, CommentCode, CommentFlags);
        exit(true);
    end;

    procedure AssistEditCommentFlags(TableNo: Integer; var CommentFlags: Code[30])
    var
        CommentFlagSelection: Record "Code Selection Buffer" temporary;
        CommentCode: array[10] of Code[5];
        CommentDesc: array[10] of Text[30];
        CodeFound: array[10] of Boolean;
        i: Integer;
    begin
        if not GetCommentCodes(TableNo, CommentCode, CommentDesc) then
            exit;

        CodesSelected(CodeFound, CommentCode, CommentFlags);
        for i := 1 to ArrayLen(CommentCode) do
            if CommentCode[i] <> '' then begin
                CommentFlagSelection."Line No." := i;
                CommentFlagSelection.Code := CommentCode[i];
                CommentFlagSelection.Description := CommentDesc[i];
                CommentFlagSelection.Selected := CodeFound[i];
                CommentFlagSelection.Insert;
            end;

        if PAGE.RunModal(PAGE::"Comment Flag Selection", CommentFlagSelection) in [ACTION::OK, ACTION::LookupOK] then begin // P8000842
            Clear(CodeFound);
            CommentFlagSelection.SetRange(Selected, true);
            if CommentFlagSelection.Find('-') then
                repeat
                    CodeFound[CommentFlagSelection."Line No."] := true;
                until CommentFlagSelection.Next = 0;
            FormatCommentFlags(CodeFound, CommentCode, CommentFlags);
        end;
    end;

    procedure InsertOrderComments(TableNo: Integer; No: Code[20]; DocType: Integer; DocNo: Code[20])
    var
        CommentCode: array[10] of Code[5];
        CommentDesc: array[10] of Text[30];
        CodeFound: array[10] of Boolean;
        LineNo: Integer;
    begin
        DeleteOrderComments(TableNo, DocType, DocNo);
        GetCommentCodes(TableNo, CommentCode, CommentDesc);

        CommentLine.SetRange("Table Name", TableNo);
        CommentLine.SetRange("No.", No);
        CommentLine.SetFilter("Order Comment Flags", '<>%1', '');
        if CommentLine.Find('-') then
            repeat
                CodesSelected(CodeFound, CommentCode, CommentLine."Order Comment Flags");
                case TableNo of
                    CommentLine."Table Name"::Customer:
                        SalesCommentInsert(DocType, DocNo, CommentLine, LineNo, CodeFound);
                end;
            until CommentLine.Next = 0;
    end;

    procedure DeleteOrderComments(TableNo: Integer; DocType: Integer; DocNo: Code[20])
    begin
        case TableNo of
            CommentLine."Table Name"::Customer:
                SalesCommentDelete(DocType, DocNo);
        end;
    end;

    local procedure MatchCode(CommentCode: array[10] of Code[5]; "Code": Code[30]): Integer
    var
        pos: Integer;
    begin
        for pos := 1 to ArrayLen(CommentCode) do begin
            if Code = CommentCode[pos] then
                exit(pos);
        end;
        Error(Text003, Code);
    end;

    local procedure SetCommentCodes(var CommentCode: array[10] of Code[5]; CommentDesc: array[10] of Text[30])
    var
        i: Integer;
    begin
        for i := 1 to ArrayLen(CommentDesc) do
            CommentCode[i] := DelChr(CommentDesc[i], '=', Text002);
    end;

    local procedure CodesSelected(var CodeFound: array[10] of Boolean; CommentCode: array[10] of Code[5]; CommentFlags: Code[30])
    var
        i: Integer;
    begin
        for i := 1 to ArrayLen(CommentCode) do
            CodeFound[i] := 0 <> StrPos(CommentFlags, CommentCode[i]);
    end;

    local procedure FormatCommentFlags(CodeFound: array[10] of Boolean; CommentCode: array[10] of Code[5]; var CommentFlags: Code[30])
    var
        i: Integer;
    begin
        CommentFlags := '';
        for i := 1 to ArrayLen(CodeFound) do
            if CodeFound[i] then
                CommentFlags := CommentFlags + CopyStr(Delimeter, 1, 1) + CommentCode[i];
        CommentFlags := CopyStr(CommentFlags, 2);
    end;

    local procedure SalesCommentCodes(var CommentCode: array[10] of Code[5]; var CommentDesc: array[10] of Text[30])
    var
        SalesComment: Record "Sales Comment Line";
    begin
        CommentDesc[1] := CopyStr(SalesComment.FieldCaption("Print On Quote"), 1 + StrLen(Text001));
        CommentDesc[2] := CopyStr(SalesComment.FieldCaption("Print On Pick Ticket"), 1 + StrLen(Text001));
        CommentDesc[3] := CopyStr(SalesComment.FieldCaption("Print On Order Confirmation"), 1 + StrLen(Text001));
        CommentDesc[4] := CopyStr(SalesComment.FieldCaption("Print On Shipment"), 1 + StrLen(Text001));
        CommentDesc[5] := CopyStr(SalesComment.FieldCaption("Print On Invoice"), 1 + StrLen(Text001));
        CommentDesc[6] := CopyStr(SalesComment.FieldCaption("Print On Credit Memo"), 1 + StrLen(Text001));
        CommentDesc[7] := CopyStr(SalesComment.FieldCaption("Print On Return Authorization"), 1 + StrLen(Text001));
        CommentDesc[8] := CopyStr(SalesComment.FieldCaption("Print On Return Receipt"), 1 + StrLen(Text001));

        SetCommentCodes(CommentCode, CommentDesc);
    end;

    local procedure SalesCommentDelete(DocType: Integer; DocNo: Code[20])
    var
        SalesCommentLine: Record "Sales Comment Line";
    begin
        SalesCommentLine.SetRange("Document Type", DocType);
        SalesCommentLine.SetRange("No.", DocNo);
        SalesCommentLine.DeleteAll;
        SalesCommentLine.Reset;
    end;

    local procedure SalesCommentInsert(DocType: Integer; DocNo: Code[20]; CommentLine: Record "Comment Line"; var LineNo: Integer; CodeFound: array[10] of Boolean)
    var
        SalesCommentLine: Record "Sales Comment Line";
    begin
        LineNo += 10000;
        SalesCommentLine."Document Type" := DocType;
        SalesCommentLine."No." := DocNo;
        SalesCommentLine."Line No." += LineNo;
        SalesCommentLine.Code := CommentLine.Code;
        SalesCommentLine.Comment := CommentLine.Comment;
        SalesCommentLine."Print On Quote" := CodeFound[1];
        SalesCommentLine."Print On Pick Ticket" := CodeFound[2];
        SalesCommentLine."Print On Order Confirmation" := CodeFound[3];
        SalesCommentLine."Print On Shipment" := CodeFound[4];
        SalesCommentLine."Print On Invoice" := CodeFound[5];
        SalesCommentLine."Print On Credit Memo" := CodeFound[6];
        SalesCommentLine."Print On Return Authorization" := CodeFound[7];
        SalesCommentLine."Print On Return Receipt" := CodeFound[8];
        SalesCommentLine.Insert;
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterValidateEvent', 'Sell-to Customer No.', false, false)]
    local procedure OnAfterValidateSellTocustomerNo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        // P80050509
        if Rec.IsTemporary then
            exit;

        // P80045696
        if Rec."No." = '' then
            Rec.InitInsert;
        // P80045606

        if Rec."Sell-to Customer No." <> xRec."Sell-to Customer No." then
            InsertOrderComments(1, Rec."Sell-to Customer No.", Rec."Document Type", Rec."No.");
    end;
}

