page 37002556 "Incident Comment View"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Extended Comment Display';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field(CommentDate; CommentDate)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Date';
                Editable = false;
                Enabled = false;
            }
            field(ExtendedCommentText; ExtendedCommentText)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Comment';
                MultiLine = true;
            }
        }
    }

    actions
    {
    }

    var
        ExtendedCommentText: Text;
        CommentView: Text;
        InitialExtendedCommentText: Text;
        CommentDate: Date;

    procedure SetDisplayTextIncident(CommentLine: Record "Incident Comment Line")
    begin
        case true of
            StrLen(CommentLine.Comment) > 0:
                begin
                    Clear(ExtendedCommentText);
                    CommentLine.SetRange("Table ID", CommentLine."Table ID");
                    CommentLine.SetRange("Incident Entry No.", CommentLine."Incident Entry No.");
                    CommentLine.SetFilter(Date, '%1|%2', CommentLine.Date, 0D);
                    if CommentLine.FindSet then
                        repeat
                            ExtendedCommentText += CommentLine.Comment;
                        until CommentLine.Next = 0;
                end;
        end;

        CommentView := CommentLine.GetView;
        InitialExtendedCommentText := ExtendedCommentText;
    end;

    procedure GetDisplayText(): Text
    begin
        exit(ExtendedCommentText);
    end;

    procedure CheckExtendedCommentIsModified(): Boolean
    begin
        exit(ExtendedCommentText <> InitialExtendedCommentText);
    end;

    procedure GetCommentView(): Text
    begin
        exit(CommentView);
    end;

    procedure SetCommentDate(pCommentDate: Date)
    begin
        CommentDate := pCommentDate;
    end;
}

