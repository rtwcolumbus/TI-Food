page 37002943 "Incident Resolution Card"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration

    Caption = 'Incident Resolution Card';
    DataCaptionExpression = GetCaption;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Item';
    RefreshOnActivate = true;
    SourceTable = "Incident Resolution Entry";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("User ID"; "User ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Date and Time"; "Date and Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Active; Active)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Accept; Accept)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Archived; Archived)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Resolution Reason Code"; "Resolution Reason Code")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Incident)
            {
                Caption = 'Incident';
                field("Primary Key Field 1 Value"; IncidentEntry."Primary Key Field 1 Value")
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = IncidentEntry.GetFieldCaption(IncidentEntry."Primary Key Field 1 No.");
                    Caption = 'Primary Key Field 1 Value';
                    Editable = false;
                }
                field("Primary Key Field 2 Value"; IncidentEntry."Primary Key Field 2 Value")
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = IncidentEntry.GetFieldCaption(IncidentEntry."Primary Key Field 2 No.");
                    Caption = 'Primary Key Field 2 Value';
                    Editable = false;
                    Visible = Field2Visible;
                }
                field("Primary Key Field 3 Value"; IncidentEntry."Primary Key Field 3 Value")
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = IncidentEntry.GetFieldCaption(IncidentEntry."Primary Key Field 3 No.");
                    Caption = 'Primary Key Field 3 Value';
                    Editable = false;
                    Visible = Field3Visible;
                }
                field("Incident Classification"; IncidentEntry."Incident Classification")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Incident Classification';
                    Editable = false;
                    TableRelation = "Incident Classification".Code;
                }
                field(Status; Format(IncidentEntry.Status))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Status';
                    Editable = false;
                    TableRelation = "Incident Entry".Status;
                }
                field("Incident Reason Code"; IncidentEntry."Incident Reason Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Incident Reason Code';
                    Editable = false;
                    TableRelation = "Incident Reason Code".Type;
                }
                field("Salesperson Code"; IncidentEntry."Salesperson Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Salesperson Code';
                    Editable = false;
                    TableRelation = "Salesperson/Purchaser".Code;
                }
                group(Control37002013)
                {
                    ShowCaption = false;
                    field("Incident Comments"; IncidentCommentText)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Incident Comments';
                        Editable = false;
                        MultiLine = true;
                    }
                    field("Resolution Comments"; CommentText)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Resolution Comments';
                        MultiLine = true;

                        trigger OnValidate()
                        var
                            IncidentEntry: Record "Incident Entry";
                            CommentsMgmt: Codeunit "Incident Comments Mgt.";
                            CommentLine: Record "Incident Comment Line";
                        begin
                            if OldCommentText <> CommentText then begin
                                CommentsMgmt.SetSource("Entry No.");
                                CommentsMgmt.ReCreateIncidentResComments(CommentView, CommentText);
                                CurrPage.Update(false);
                            end;
                        end;
                    }
                }
            }
        }
        area(factboxes)
        {
            part(WorkflowStatus; "Workflow Status FactBox")
            {
                ApplicationArea = FOODBasic;
                Editable = false;
                Enabled = false;
                ShowFilter = false;
                Visible = ShowWorkflowStatus;
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = true;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(OpenDocument)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Open Record';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Open the document, journal line, or entry that the incoming document is linked to.';

                trigger OnAction()
                var
                    SourceRecRef: RecordRef;
                    IncidentEntry: Record "Incident Entry";
                begin
                    SourceRecRef.Get("Incident Entry Record ID");
                    IncidentEntry.ShowNAVRecord(SourceRecRef);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IncidentEntry.Get("Incident Entry No.");
        Field2Visible := IncidentEntry."Primary Key Field 2 Value" <> '';
        Field3Visible := IncidentEntry."Primary Key Field 3 Value" <> '';
        Clear(IncidentCommentText);
        GetCommentLinetoText(IncidentCommentText, CommentText);
        OldCommentText := CommentText;

        OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(RecordId);

        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(RecordId);
    end;

    trigger OnOpenPage()
    begin
        OpenApprovalEntriesExistCurrUser := true;
    end;

    var
        IncidentCommentText: Text;
        OldCommentText: Text;
        CommentText: Text;
        Field2Visible: Boolean;
        Field3Visible: Boolean;
        CommentView: Text;
        CreateToDoVisible: Boolean;
        OpenApprovalEntriesExistCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        ShowWorkflowStatus: Boolean;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        CanCancelApprovalForRecord: Boolean;
        EventFilter: Text;
        EnabledApprovalWorkflowsExist: Boolean;
        LinesVisible: Boolean;
        IncidentEntry: Record "Incident Entry";

    local procedure GetCaption(): Text
    begin
        exit(Format(Format("Incident Entry Record ID")));
    end;

    local procedure GetCommentLinetoText(var IncidentCommentText: Text; var RescommentText: Text)
    var
        IncidentCommentLine: Record "Incident Comment Line";
    begin
        Clear(CommentText);
        IncidentCommentLine.SetRange("Incident Entry No.", "Entry No.");
        IncidentCommentLine.SetRange("Table ID", DATABASE::"Incident Resolution Entry");
        if IncidentCommentLine.FindFirst then
            repeat
                RescommentText += IncidentCommentLine.Comment;
            until IncidentCommentLine.Next = 0;
        CommentView := IncidentCommentLine.GetView;

        IncidentCommentLine.SetRange("Incident Entry No.", "Incident Entry No.");
        IncidentCommentLine.SetFilter("Table ID", '<>%1', DATABASE::"Incident Resolution Entry");
        if IncidentCommentLine.FindFirst then
            repeat
                IncidentCommentText += IncidentCommentLine.Comment;
            until IncidentCommentLine.Next = 0;
    end;
}

