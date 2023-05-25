page 37002920 Allergens
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Allergens';
    PageType = List;
    SourceTable = Allergen;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002006; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002007; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(WherePresent)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Where Present';
                Image = Track;

                trigger OnAction()
                begin
                    ShowWherePresent;
                end;
            }
        }
        area(processing)
        {
            group(Approval)
            {
                Caption = 'Approval';
                action(Approve)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Approve';
                    Enabled = OpenApprovalEntriesExistCurrUser;
                    Image = Approve;
                    Visible = ActiveWorkflowExists;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(RecordId);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Reject';
                    Enabled = OpenApprovalEntriesExistCurrUser;
                    Image = Reject;
                    Visible = ActiveWorkflowExists;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.RejectRecordApprovalRequest(RecordId);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Delegate';
                    Enabled = OpenApprovalEntriesExistCurrUser;
                    Image = Delegate;
                    Visible = ActiveWorkflowExists;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.DelegateRecordApprovalRequest(RecordId);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Approve)
            {
                Caption = 'Approve';
                ShowAs = SplitButton;

                actionref(Approve_Promoted; Approve)
                {
                }
                actionref(Reject_Promoted; Reject)
                {
                }
                actionref(Delegate_Promoted; Delegate)
                {
                }
            }
            actionref(WherePresent_Promoted; WherePresent)
            {
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId);
    end;

    trigger OnOpenPage()
    begin
        ActiveWorkflowExists := ApprovalsMgmt.IsAddAllergenWorkflowEnabled(Rec);
    end;

    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        [InDataSet]
        ActiveWorkflowExists: Boolean;
        [InDataSet]
        OpenApprovalEntriesExistCurrUser: Boolean;
}

