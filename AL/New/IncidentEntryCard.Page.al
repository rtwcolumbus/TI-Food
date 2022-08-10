page 37002942 "Incident Entry Card"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration

    Caption = 'Incident Entry Card';
    DataCaptionExpression = GetCaption;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Item,Approval';
    SourceTable = "Incident Entry";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Primary Key Field 1 Value"; "Primary Key Field 1 Value")
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = GetFieldCaption("Primary Key Field 1 No.");
                    Editable = false;
                }
                field("Primary Key Field 2 Value"; "Primary Key Field 2 Value")
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = GetFieldCaption("Primary Key Field 2 No.");
                    Editable = false;
                    Visible = Field2Visible;
                }
                field("Primary Key Field 3 Value"; "Primary Key Field 3 Value")
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = GetFieldCaption("Primary Key Field 3 No.");
                    Editable = false;
                    Visible = Field3Visible;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Incident Classification"; "Incident Classification")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Incident Reason Code"; "Incident Reason Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group("Source Details")
            {
                Caption = 'Source Details';
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = FOODBasic;
                    Enabled = false;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Source Quantity"; "Source Quantity")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Source Unit of Measure Code"; "Source Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Source Transaction Date"; "Source Transaction Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Incident Quantity"; "Incident Quantity")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Incident Unit of Measure Code"; "Incident Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Item Category"; "Item Category")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Created On"; "Created On")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                group(Control37002002)
                {
                    ShowCaption = false;
                    field("Additional Description"; CommentText)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Additional Description';
                        MultiLine = true;

                        trigger OnValidate()
                        var
                            CommentsMgmt: Codeunit "Incident Comments Mgt.";
                        begin
                            TestField(Archived, false);
                            if OldCommentText <> CommentText then begin
                                CommentsMgmt.SetSource("Entry No.");
                                CommentsMgmt.ReCreateIncidentComments(CommentView, CommentText);
                                CurrPage.Update(false);
                            end;
                        end;
                    }
                }
            }
            group(Task)
            {
                Caption = 'Task';
                field("To-do No."; "To-do No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'No.';
                    Lookup = false;

                    trigger OnAssistEdit()
                    var
                        Todo: Record "To-do";
                    begin
                        if "To-do No." = '' then
                            exit;

                        Todo.Get("To-do No.");
                        Todo.SetRecFilter;
                        PAGE.Run(PAGE::"Task Card", Todo);
                    end;
                }
                field("To-do Description"; "To-do Description")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                    DrillDown = false;
                }
                field("To-do Status"; "To-do Status")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Status';
                    DrillDown = false;
                }
                field("To-do Priority"; "To-do Priority")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Priority';
                    DrillDown = false;
                }
            }
            part(Lines; "Incident Resolution Entries")
            {
                ApplicationArea = FOODBasic;
                Editable = false;
                SubPageLink = "Incident Entry No." = FIELD("Entry No.");
                SubPageView = SORTING("Entry No.");
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
                begin
                    SourceRecRef.Get("Source Record ID");
                    ShowNAVRecord(SourceRecRef);
                end;
            }
            action(CreateToDo)
            {
                ApplicationArea = FOODBasic;
                Caption = '&Create Task';
                Image = NewToDo;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Create a new task.';
                Visible = CreateToDoVisible;

                trigger OnAction()
                var
                    IncidentManagement: Codeunit "Incident Management";
                begin
                    IncidentManagement.CreateToDo(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(CreateResolution)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Create Resolution';
                Image = NewSparkle;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Create a new resolution.';

                trigger OnAction()
                var
                    IncidentManagement: Codeunit "Incident Management";
                begin
                    IncidentManagement.CreateResolutionEntry(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(AcceptResolution)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Accept Resolution';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Accept a resolution.';

                trigger OnAction()
                var
                    IncidentManagement: Codeunit "Incident Management";
                begin
                    IncidentManagement.AcceptResolution(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ReOpen)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Re-Open';
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Re-Open an incident.';

                trigger OnAction()
                var
                    IncidentManagement: Codeunit "Incident Management";
                begin
                    ReOpen;
                    CurrPage.Update(false);
                end;
            }
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Image = SendApprovalRequest;
                action(CancelApprovalRequest)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = CanCancelApprovalForRecord;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Cancel the approval request.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        IncidentWorkflow: Codeunit "Incident Workflow";
                    begin
                        IncidentWorkflow.OnCancelIncidentApprovalRequest(Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        CreateToDoVisible := ("To-do No." = '') and not Archived;

        ShowWorkflowStatus := CurrPage.WorkflowStatus.PAGE.SetFilterOnWorkflowRecord(RecordId);
        OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(RecordId);

        EventFilter := WorkflowEventHandling.RunWorkflowOnSendCustomerForApprovalCode + '|' +
          WorkflowEventHandling.RunWorkflowOnCustomerChangedCode;

        EnabledApprovalWorkflowsExist := WorkflowManagement.EnabledWorkflowExist(DATABASE::Customer, EventFilter);
    end;

    trigger OnAfterGetRecord()
    begin
        Field2Visible := "Primary Key Field 2 Value" <> '';
        Field3Visible := "Primary Key Field 3 Value" <> '';

        GetCommentLinetoText(CommentText, CommentView);
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

    procedure SetCurrentRecord(var IncidentEntry: Record "Incident Entry" temporary)
    begin
        Rec.Copy(IncidentEntry, true);
    end;

    procedure GetCurrentRecord(var IncidentEntry: Record "Incident Entry" temporary; var NewComment: Text)
    begin
        IncidentEntry.Copy(Rec, true);
        NewComment := CommentText;
    end;

    local procedure GetCaption(): Text
    begin
        exit(Format(Format("Source Record ID")));
    end;
}

