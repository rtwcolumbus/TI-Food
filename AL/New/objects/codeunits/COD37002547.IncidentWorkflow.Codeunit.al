codeunit 37002547 "Incident Workflow"
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration
    // 
    // PRW111.00.02
    // P80072872, To-Increase, Gangabhushan, 04 APR 19
    //   TI-13132 - Unable to create and initialize new company wihtout quality control
    //   Subscriber functions OnMissingLicense property modified
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW120.00
    // P800144605, To Increase, Jack Reynolds, 20 APR 22
    //   Upgrade to 20.0


    trigger OnRun()
    begin
    end;

    var
        CategoryCodeFood: Label 'FOOD';
        CategoryDescFood: Label 'Food Manufacturing and Distribution';
        IncidentApprWorkFlowCode: Label 'IncidentApproval';
        IncidentApprWorkFlowDesc: Label 'Approve new incident for resolution';
        EventDescIncidentChanged: Label 'An Incident entry record  is changed.';
        EventDescIncidentDeleted: Label 'An Incident is deleted.';
        EventDescCancelIncidentApproval: Label 'An approval request for an Incident is canceled.';
        ResponseDescClearIncidentBlockedFlag: Label 'Clear the Incident Blocked flag.';
        ResponseDescDeleteIncidentRecord: Label 'Delete the Incident record.';
        UnsupportedRecordTypeErr: Label 'Record type %1 is not supported by this workflow response.', Comment = 'Record type Customer is not supported by this workflow response.';
        RevertRecordValueTxt: Label 'Revert the value of the %1 field on the record and save the change.', Comment = 'Revert the value of the Credit Limit (LCY) field on the record and save the change.';
        DiscardNewValuesTxt: Label 'Discard the new values.';
        ApplyNewValuesTxt: Label 'Apply the new values.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAddWorkflowCategoriesToLibrary', '', true, false)]
    local procedure WorkflowSetup_OnAddWorkflowCategoriesToLibrary()
    begin
        InsertWorkflowCategory(CategoryCodeFood, CategoryDescFood);
    end;

    local procedure InsertWorkflowCategory("Code": Code[20]; Description: Text[100])
    var
        WorkflowCategory: Record "Workflow Category";
    begin
        WorkflowCategory.Init;
        WorkflowCategory.Code := Code;
        WorkflowCategory.Description := Description;
        if WorkflowCategory.Insert then;
    end;

    procedure FoodCategoryCode(): Code[20]
    begin
        exit(CategoryCodeFood);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', true, false)]
    local procedure WorkflowEventHandling_OnAddWorkflowEventsToLibrary()
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnIncidentStatusChangeCode, DATABASE::"Incident Entry", EventDescIncidentChanged, 0, true);
        WorkflowEventHandling.AddEventToLibrary(RunWorkFlowOnCancelIncidentApprovalRequestCode, DATABASE::"Incident Entry", EventDescCancelIncidentApproval, 0, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsesToLibrary', '', true, false)]
    local procedure WorkflowResponseHandling_OnAddWorkflowResponsesToLibrary()
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        WorkflowResponseHandling.AddResponseToLibrary(RunWorkflowOnIncidentStatusChangeCode, DATABASE::"Incident Entry", EventDescIncidentChanged, 'GROUP 0');
        WorkflowResponseHandling.AddResponseToLibrary(ApplyNewValuesCode, DATABASE::"Incident Entry", ApplyNewValuesTxt, 'GROUP 0');
        WorkflowResponseHandling.AddResponseToLibrary(RevertValueForFieldCode, DATABASE::"Incident Entry", RevertRecordValueTxt, 'GROUP 0');
        WorkflowResponseHandling.AddResponseToLibrary(DiscardNewValuesCode, DATABASE::"Incident Entry", DiscardNewValuesTxt, 'GROUP 0');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', true, false)]
    local procedure WorkflowEventHandling_OnAddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        case EventFunctionName of
            RunWorkflowOnIncidentStatusChangeCode:
                begin
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, EventFunctionName);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, EventFunctionName);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode, EventFunctionName);

                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, EventFunctionName);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, EventFunctionName);
                    //WorkflowResponseHandling.AddResponsePredecessor(RevertValueForFieldCode,EventFunctionName);
                end;
            RunWorkFlowOnCancelIncidentApprovalRequestCode:
                begin
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, EventFunctionName);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', true, false)]
    local procedure WorkflowResponseHandling_OnAddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        case ResponseFunctionName of
            SetStatusToPendingApprovalCode:
                WorkflowResponseHandling.AddResponsePredecessor(SetStatusToPendingApprovalCode, WorkflowEventHandling.RunWorkflowOnCustomerCreditLimitNotExceededCode);
            CreateApprovalRequestsCode:
                WorkflowResponseHandling.AddResponsePredecessor(CreateApprovalRequestsCode, RunWorkflowOnIncidentStatusChangeCode);
            SendApprovalRequestForApprovalCode:
                WorkflowResponseHandling.AddResponsePredecessor(SendApprovalRequestForApprovalCode, RunWorkflowOnIncidentStatusChangeCode);
            RejectAllApprovalRequestsCode:
                WorkflowResponseHandling.AddResponsePredecessor(RejectAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode);
            CancelAllApprovalRequestsCode:
                WorkflowResponseHandling.AddResponsePredecessor(CancelAllApprovalRequestsCode, WorkflowEventHandling.RunWorkflowOnCancelCustomerApprovalRequestCode);
            RevertValueForFieldCode:
                WorkflowResponseHandling.AddResponsePredecessor(RevertValueForFieldCode, RunWorkflowOnIncidentStatusChangeCode);
            ApplyNewValuesCode:
                WorkflowResponseHandling.AddResponsePredecessor(ApplyNewValuesCode, WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode);
            DiscardNewValuesCode:
                WorkflowResponseHandling.AddResponsePredecessor(DiscardNewValuesCode, WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode);
            CreateOverdueNotificationCode:
                WorkflowResponseHandling.AddResponsePredecessor(CreateOverdueNotificationCode, WorkflowEventHandling.RunWorkflowOnSendOverdueNotificationsCode);
            CreateAndApproveApprovalRequestAutomaticallyCode:
                WorkflowResponseHandling.AddResponsePredecessor(CreateAndApproveApprovalRequestAutomaticallyCode, RunWorkflowOnIncidentStatusChangeCode);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowTableRelationsToLibrary', '', true, false)]
    local procedure WorkflowEventHandling_OnAddWorkflowTableRelationsToLibrary()
    var
        ApprovalEntry: Record "Approval Entry";
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        WorkflowSetup.InsertTableRelation(DATABASE::"Incident Entry", 0, DATABASE::"Approval Entry", ApprovalEntry.FieldNo(ApprovalEntry."Record ID to Approve"));
    end;

    procedure RunWorkflowOnIncidentStatusChangeCode(): Code[128]
    begin
        exit('RUNWORKFLOWONINCIDENTSTATUSCHANGE');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incident Entry", 'OnAfterModifyEvent', '', true, false)]
    local procedure IncidentEntry_OnAfterModify(var Rec: Record "Incident Entry"; var xRec: Record "Incident Entry"; RunTrigger: Boolean)
    var
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        if Rec.IsTemporary then
            exit;

        if Format(Rec) = Format(xRec) then
            exit;

        WorkflowManagement.HandleEventWithxRec(RunWorkflowOnIncidentStatusChangeCode, Rec, xRec);
    end;

    procedure RunWorkFlowOnCancelIncidentApprovalRequestCode(): Code[128]
    begin
        exit('RUNWORKFLOWONCANCELINCIDENTAPPROVALREQUEST');
    end;

    procedure OnCancelIncidentApprovalRequest(var Incident: Record "Incident Entry")
    var
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        if Incident.IsTemporary then
            exit;

        WorkflowManagement.HandleEvent(RunWorkFlowOnCancelIncidentApprovalRequestCode, Incident);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnExecuteWorkflowResponse', '', true, false)]
    local procedure WorkflowResponseHandling_OnExecuteWorkflowResponse(var ResponseExecuted: Boolean; Variant: Variant; xVariant: Variant; ResponseWorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowResponse: Record "Workflow Response";
    begin
    end;

    local procedure RunWorkflowOnCustomerChangedCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCustomerChangedCode'));
    end;

    procedure SetStatusToPendingApprovalCode(): Code[128]
    begin
        exit(UpperCase('SetStatusToPendingApproval'));
    end;

    procedure CreateApprovalRequestsCode(): Code[128]
    begin
        exit(UpperCase('CreateApprovalRequests'));
    end;

    procedure SendApprovalRequestForApprovalCode(): Code[128]
    begin
        exit(UpperCase('SendApprovalRequestForApproval'));
    end;

    procedure ApproveAllApprovalRequestsCode(): Code[128]
    begin
        exit(UpperCase('ApproveAllApprovalRequests'));
    end;

    procedure RejectAllApprovalRequestsCode(): Code[128]
    begin
        exit(UpperCase('RejectAllApprovalRequests'));
    end;

    procedure CancelAllApprovalRequestsCode(): Code[128]
    begin
        exit(UpperCase('CancelAllApprovalRequests'));
    end;

    procedure RevertValueForFieldCode(): Code[128]
    begin
        exit(UpperCase('RevertValueForField'));
    end;

    procedure ApplyNewValuesCode(): Code[128]
    begin
        exit(UpperCase('ApplyNewValues'));
    end;

    procedure DiscardNewValuesCode(): Code[128]
    begin
        exit(UpperCase('DiscardNewValues'));
    end;

    local procedure DoNothing()
    begin
    end;

    local procedure CreateNotificationEntry(Variant: Variant; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
        NotificationEntry: Record "Notification Entry";
    begin
        if WorkflowStepArgument.Get(WorkflowStepInstance.Argument) then
            NotificationEntry.CreateNotificationEntry("Notification Entry Type"::"New Record", // P800144605
              WorkflowStepArgument."Notification User ID", Variant, WorkflowStepArgument."Link Target Page",
              WorkflowStepArgument."Custom Link", '');
    end;

    local procedure CreateOverdueNotifications(WorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
        NotificationManagement: Codeunit "Notification Management";
    begin
        if WorkflowStepArgument.Get(WorkflowStepInstance.Argument) then
            NotificationManagement.CreateOverdueNotifications(WorkflowStepArgument);
    end;

    procedure CreateOverdueNotificationCode(): Code[128]
    begin
        exit(UpperCase('CreateOverdueNotifications'));
    end;

    procedure CreateAndApproveApprovalRequestAutomaticallyCode(): Code[128]
    begin
        exit(UpperCase('CreateAndApproveApprovalRequestAutomatically'));
    end;
}

