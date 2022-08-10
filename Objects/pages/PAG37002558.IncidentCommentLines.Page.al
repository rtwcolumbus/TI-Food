page 37002558 "Incident Comment Lines"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration

    AutoSplitKey = true;
    Caption = 'Incident Comment Lines';
    DataCaptionExpression = GetCaption;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Incident Comment Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Date; Date)
                {
                    ApplicationArea = FOODBasic;
                    ToolTip = 'Specifies a date for the comment. When you run the XBRL Export Instance - Spec. 2 report, it includes comments that dates within the period of the report, as well as comments that do not have a date.';
                }
                field(Comment; Comment)
                {
                    ApplicationArea = FOODBasic;
                    ToolTip = 'Specifies the comment. If the comment type is Info, this comment was imported with the taxonomy and cannot be edited. If the comment type is Note, you can enter a maximum of 80 characters for each, both numbers and letters, and it will be exported with the rest of the financial information.';

                    trigger OnAssistEdit()
                    var
                        CommentDisplay: Page "Incident Comment View";
                        NewComment: Text;
                        CommentsMgmt: Codeunit "Incident Comments Mgt.";
                        TempIncidentCommentLine: Record "Incident Comment Line" temporary;
                    begin
                        if GetFilter("Incident Entry No.") <> '' then
                            Evaluate("Incident Entry No.", GetFilter("Incident Entry No."));
                        CommentDisplay.SetDisplayTextIncident(Rec);
                        CommentDisplay.SetCommentDate(GetDisplayDate);
                        CommentDisplay.LookupMode(true);
                        if CommentDisplay.RunModal = ACTION::LookupOK then
                            if CommentDisplay.CheckExtendedCommentIsModified then begin
                                NewComment := CommentDisplay.GetDisplayText;
                                if StrLen(Comment) > 0 then
                                    CommentsMgmt.ReCreateIncidentComments(CommentDisplay.GetCommentView, NewComment)
                                else begin
                                    CreateTempCommentLine(TempIncidentCommentLine, Rec);
                                    CommentsMgmt.InsertIncidentCommentLines(NewComment, TempIncidentCommentLine, true);
                                end;
                            end;

                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if GetFilter("Incident Entry No.") <> '' then
            Evaluate("Incident Entry No.", GetFilter("Incident Entry No."));
        SetUpNewLine;
    end;

    local procedure GetCaption(): Text[250]
    var
        XBRLLine: Record "XBRL Taxonomy Line";
    begin
    end;

    local procedure CreateTempCommentLine(var TempCommentLine: Record "Incident Comment Line" temporary; CommentLine: Record "Incident Comment Line")
    begin
        TempCommentLine.Init;
        TempCommentLine.TransferFields(CommentLine);
        if TempCommentLine.Date = 0D then
            TempCommentLine.Date := WorkDate;
        TempCommentLine.Insert;
    end;

    local procedure GetDisplayDate(): Date
    begin
        if Date = 0D then
            exit(WorkDate);
        exit(Date);
    end;
}

