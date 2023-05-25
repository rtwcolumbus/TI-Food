page 124 "Comment Sheet" // Version: FOODNA
{
    AutoSplitKey = true;
    Caption = 'Comment Sheet';
    DataCaptionFields = "No.";
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Comment Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Date; Date)
                {
                    ApplicationArea = Comments;
                    ToolTip = 'Specifies the date the comment was created.';
                }
                field(Comment; Comment)
                {
                    ApplicationArea = Comments;
                    ToolTip = 'Specifies the comment itself.';
                }
                field("Code"; Code)
                {
                    ApplicationArea = Comments;
                    ToolTip = 'Specifies a code for the comment.';
                    Visible = false;
                }
                field("Order Comment Flags"; "Order Comment Flags")
                {
                    ApplicationArea = FOODBasic;
                    Visible = ShowFlags;

                    trigger OnAssistEdit()
                    begin
                        // P8000842
                        OrderCommentFns.AssistEditCommentFlags("Table Name", "Order Comment Flags");
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
        SetUpNewLine();
    end;

    trigger OnOpenPage()
    var
        i: Integer;
    begin
        // P8000842
        OrderCommentFns.GetCommentCodes("Table Name", CommentCode, CommentDesc);

        for i := 1 to ArrayLen(CommentCode) do
            ShowFlags := ShowFlags or (CommentCode[i] <> '');
    end;

    var
        OrderCommentFns: Codeunit "Order Comment Functions";
        CommentCode: array[10] of Code[5];
        CommentDesc: array[10] of Text[30];
        CommentText: Text[1024];
        [InDataSet]
        ShowFlags: Boolean;
}

