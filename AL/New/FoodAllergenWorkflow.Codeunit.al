codeunit 37002165 "Food Allergen Workflow"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00


    trigger OnRun()
    begin
    end;

    var
        CategoryCodeFood: Label 'FOOD';
        CategoryDescFood: Label 'Food Manufacturing and Distribution';
        AllergenApprovalDesc: Label 'Allergen Approval Workflow';
        ItemAllergenChangeDesc: Label 'Item Allergen Change Approval Workflow';
        AllergenApprWorkFlowCode: Label 'AllergenApproval';
        AllergenApprWorkFlowDesc: Label 'Approve new allergen for use';
        EventDescAllergenAdded: Label 'An allergen is added.';
        EventDescAllergenDeleted: Label 'An allergen is deleted.';
        EventDescCancelAllergenApproval: Label 'An approval request for an allergen is canceled.';
        ResponseDescClearAllergenBlockedFlag: Label 'Clear the allergen Blocked flag.';
        ResponseDescDeleteAllergenRecord: Label 'Delete the allergen  record.';
        UnsupportedRecordTypeErr: Label 'Record type %1 is not supported by this workflow response.', Comment = 'Record type Customer is not supported by this workflow response.';

    procedure AllergenApprovalCode(): code[20]
    var
        WorkflowCode: Label 'FOOD-AAAPW';
    begin
        exit(WorkflowCode)
    end;

    procedure ItemAllergenChangeCode(): code[20]
    var
        WorkflowCode: Label 'FOOD-IACAPW';
    begin
        exit(WorkflowCode)
    end;

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
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnAddAllergenCode, DATABASE::Allergen, EventDescAllergenAdded, 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnDeleteAllergenCode, DATABASE::Allergen, EventDescAllergenDeleted, 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkFlowOnCancelAllergenApprovalRequestCode, DATABASE::Allergen, EventDescCancelAllergenApproval, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsesToLibrary', '', true, false)]
    local procedure WorkflowResponseHandling_OnAddWorkflowResponsesToLibrary()
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        WorkflowResponseHandling.AddResponseToLibrary(ClearAllergenBlockedFlagCode, DATABASE::Allergen, ResponseDescClearAllergenBlockedFlag, 'GROUP 0');
        WorkflowResponseHandling.AddResponseToLibrary(DeleteAllergenRecordCode, DATABASE::Allergen, ResponseDescDeleteAllergenRecord, 'GROUP 0');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', true, false)]
    local procedure WorkflowEventHandling_OnAddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        case EventFunctionName of
            RunWorkflowOnAddAllergenCode:
                begin
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, EventFunctionName);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, EventFunctionName);
                    WorkflowEventHandling.AddEventPredecessor(RunWorkFlowOnCancelAllergenApprovalRequestCode, EventFunctionName);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode, EventFunctionName);
                    WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnDeleteAllergenCode, EventFunctionName);

                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, EventFunctionName);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, EventFunctionName);
                end;
            RunWorkFlowOnCancelAllergenApprovalRequestCode:
                begin
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, EventFunctionName);
                end;
            RunWorkflowOnDeleteAllergenCode:
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
            ClearAllergenBlockedFlagCode:
                begin
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode);
                end;
            DeleteAllergenRecordCode:
                begin
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode);
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkFlowOnCancelAllergenApprovalRequestCode);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowTableRelationsToLibrary', '', true, false)]
    local procedure WorkflowEventHandling_OnAddWorkflowTableRelationsToLibrary()
    var
        ApprovalEntry: Record "Approval Entry";
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        WorkflowSetup.InsertTableRelation(DATABASE::Allergen, 0, DATABASE::"Approval Entry", ApprovalEntry.FieldNo(ApprovalEntry."Record ID to Approve"));
    end;

    procedure RunWorkflowOnAddAllergenCode(): Code[128]
    begin
        exit('RUNWORKFLOWONADDALLERGEN');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnInsertWorkflowTemplates', '', true, false)]
    local procedure WorkflowSetup_OnInsertWorkflowTemplates()
    begin
        // P8006959
        InsertAllergenApprovalWorkflowTemplate;
        InsertItemAllergenChangeWorkflowTemplate;
    end;

    local procedure InsertAllergenApprovalWorkflowTemplate()
    var
        Workflow: Record Workflow;
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        // P8006959
        WorkflowSetup.InsertWorkflowTemplate(Workflow, AllergenApprovalCode, AllergenApprovalDesc, FoodCategoryCode);
        InsertAllergenApprovalWorkflowDetails(Workflow);
        OnAfterInsertWorkflowTemplate(Workflow);
        WorkflowSetup.MarkWorkflowAsTemplate(Workflow);
    end;

    local procedure InsertAllergenApprovalWorkflowDetails(var Workflow: Record Workflow)
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
        WorkflowSetup: Codeunit "Workflow Setup";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        SentForApprovalEventID: Integer;
        RestrictUsageResponseID: Integer;
        CreateApprovalRequestResponseID: Integer;
        SendApprovalRequestResponseID: Integer;
        OnAllRequestsApprovedEventID: Integer;
        AllowRecordUsageResponseID: Integer;
        OnRequestApprovedEventID: Integer;
        SendApprovalRequestResponseID2: Integer;
        OnRequestRejectedEventID: Integer;
        RejectAllApprovalsResponseID: Integer;
        OnRequestCanceledEventID: Integer;
        CancelAllApprovalsResponseID: Integer;
        DeleteAllergeRecordResponseID: Integer;
        ShowMessageResponseID: Integer;
        OnRequestDelegatedEventID: Integer;
        SentApprovalRequestResponseID3: Integer;
        OnAllergeDeletedEventID: Integer;
        CancelAllApprovalsResponseID2: Integer;
        BlankDateFormula: DateFormula;
        ApprovalRequestCanceledMsg: Label 'The approval request for the record has been canceled.';
    begin
        WorkflowSetup.PopulateWorkflowStepArgument(WorkflowStepArgument,
          WorkflowStepArgument."Approver Type"::Approver, WorkflowStepArgument."Approver Limit Type"::"Direct Approver",
          0, '', BlankDateFormula, true);

        SentForApprovalEventID := WorkflowSetup.InsertEntryPointEventStep(Workflow, RunWorkflowOnAddAllergenCode);
        RestrictUsageResponseID := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.RestrictRecordUsageCode, SentForApprovalEventID);
        CreateApprovalRequestResponseID := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.CreateApprovalRequestsCode, RestrictUsageResponseID);
        WorkflowSetup.InsertApprovalArgument(CreateApprovalRequestResponseID, WorkflowStepArgument."Approver Type", WorkflowStepArgument."Approver Limit Type",
          WorkflowStepArgument."Workflow User Group Code", WorkflowStepArgument."Approver User ID", WorkflowStepArgument."Due Date Formula", true); // P8007748
        SendApprovalRequestResponseID := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.SendApprovalRequestForApprovalCode, CreateApprovalRequestResponseID);
        WorkflowSetup.InsertNotificationArgument(SendApprovalRequestResponseID, false, '', 0, '');

        OnAllRequestsApprovedEventID := WorkflowSetup.InsertEventStep(Workflow, WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, SendApprovalRequestResponseID);
        WorkflowSetup.InsertEventArgument(OnAllRequestsApprovedEventID, WorkflowSetup.BuildNoPendingApprovalsConditions);
        AllowRecordUsageResponseID := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.AllowRecordUsageCode, OnAllRequestsApprovedEventID);
        WorkflowSetup.InsertResponseStep(Workflow, ClearAllergenBlockedFlagCode, AllowRecordUsageResponseID);

        OnRequestApprovedEventID := WorkflowSetup.InsertEventStep(Workflow, WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, SendApprovalRequestResponseID);
        WorkflowSetup.InsertEventArgument(OnRequestApprovedEventID, WorkflowSetup.BuildPendingApprovalsConditions);
        SendApprovalRequestResponseID2 := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.SendApprovalRequestForApprovalCode, OnRequestApprovedEventID);
        WorkflowSetup.SetNextStep(Workflow, SendApprovalRequestResponseID2, SendApprovalRequestResponseID);

        OnRequestRejectedEventID := WorkflowSetup.InsertEventStep(Workflow, WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, SendApprovalRequestResponseID);
        RejectAllApprovalsResponseID := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.RejectAllApprovalRequestsCode, OnRequestRejectedEventID);
        WorkflowSetup.InsertNotificationArgument(RejectAllApprovalsResponseID, false, '', WorkflowStepArgument."Link Target Page", '');
        WorkflowSetup.InsertResponseStep(Workflow, DeleteAllergenRecordCode, RejectAllApprovalsResponseID);

        OnRequestCanceledEventID := WorkflowSetup.InsertEventStep(Workflow, RunWorkFlowOnCancelAllergenApprovalRequestCode, SendApprovalRequestResponseID);
        CancelAllApprovalsResponseID := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.CancelAllApprovalRequestsCode, OnRequestCanceledEventID);
        WorkflowSetup.InsertNotificationArgument(CancelAllApprovalsResponseID, false, '', WorkflowStepArgument."Link Target Page", '');
        DeleteAllergeRecordResponseID := WorkflowSetup.InsertResponseStep(Workflow, DeleteAllergenRecordCode, CancelAllApprovalsResponseID);
        ShowMessageResponseID := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.ShowMessageCode, DeleteAllergeRecordResponseID);
        WorkflowSetup.InsertMessageArgument(ShowMessageResponseID, ApprovalRequestCanceledMsg);

        OnRequestDelegatedEventID := WorkflowSetup.InsertEventStep(Workflow, WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode, SendApprovalRequestResponseID);
        SentApprovalRequestResponseID3 := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.SendApprovalRequestForApprovalCode, OnRequestDelegatedEventID);
        WorkflowSetup.SetNextStep(Workflow, SentApprovalRequestResponseID3, SendApprovalRequestResponseID);

        OnAllergeDeletedEventID := WorkflowSetup.InsertEventStep(Workflow, RunWorkflowOnDeleteAllergenCode, SendApprovalRequestResponseID);
        CancelAllApprovalsResponseID2 := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.CancelAllApprovalRequestsCode, OnAllergeDeletedEventID);
        WorkflowSetup.InsertNotificationArgument(CancelAllApprovalsResponseID2, false, '', WorkflowStepArgument."Link Target Page", '');
    end;

    local procedure InsertItemAllergenChangeWorkflowTemplate()
    var
        Workflow: Record Workflow;
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        // P8006959
        WorkflowSetup.InsertWorkflowTemplate(Workflow, ItemAllergenChangeCode, ItemAllergenChangeDesc, FoodCategoryCode);
        InsertItemAllergenChangeWorkflowDetails(Workflow);
        OnAfterInsertWorkflowTemplate(Workflow);
        WorkflowSetup.MarkWorkflowAsTemplate(Workflow);
    end;

    local procedure InsertItemAllergenChangeWorkflowDetails(var Workflow: Record Workflow)
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
        WorkflowRule: Record "Workflow Rule";
        WorkflowSetup: Codeunit "Workflow Setup";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        Item: Record Item;
        RuleOperator: Option;
        RecChangedEventCode: Code[128];
        RecCreateApprovalRequestsCode: Code[128];
        RecSendApprovalRequestForApprovalCode: Code[128];
        TableNo: Integer;
        FieldNo: Integer;
        RecordChangeApprovalMsg: Text;
        RecordChangedEventID: Integer;
        RevertFieldResponseID: Integer;
        CreateApprovalRequestResponseID: Integer;
        SendApprovalRequestResponseID: Integer;
        OnAllRequestsApprovedEventID: Integer;
        OnRequestApprovedEventID: Integer;
        SendApprovalRequestResponseID2: Integer;
        OnRequestRejectedEventID: Integer;
        RejectAllApprovalsResponseID: Integer;
        DiscardNewValuesResponseID: Integer;
        OnRequestDelegatedEventID: Integer;
        SentApprovalRequestResponseID3: Integer;
        ShowMessageResponseID: Integer;
        ApplyNewValuesResponseID: Integer;
        FoodWorkflow: Codeunit "Food Allergen Workflow";
        FoodItemChangeResponseID: Integer;
        OnRequestCanceledEventID: Integer;
        CancelAllApprovalsResponseID: Integer;
        AllowRecordUsageResponseID: Integer;
        BlankDateFormula: DateFormula;
        ItemAllergenChangeSentForAppTxt: Label 'The item allergen set change was sent for approval.';
    begin
        WorkflowSetup.PopulateWorkflowStepArgument(WorkflowStepArgument,
          WorkflowStepArgument."Approver Type"::Approver, WorkflowStepArgument."Approver Limit Type"::"Direct Approver",
          0, '', BlankDateFormula, true);

        RuleOperator := WorkflowRule.Operator::Changed;
        RecChangedEventCode := WorkflowEventHandling.RunWorkflowOnItemChangedCode;
        RecCreateApprovalRequestsCode := WorkflowResponseHandling.CreateApprovalRequestsCode;
        RecSendApprovalRequestForApprovalCode := WorkflowResponseHandling.SendApprovalRequestForApprovalCode;
        TableNo := DATABASE::Item;
        FieldNo := Item.FieldNo("Direct Allergen Set ID");
        RecordChangeApprovalMsg := ItemAllergenChangeSentForAppTxt;

        RecordChangedEventID := WorkflowSetup.InsertEntryPointEventStep(Workflow, RecChangedEventCode);
        WorkflowSetup.InsertEventRule(RecordChangedEventID, FieldNo, RuleOperator);

        RevertFieldResponseID := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.RevertValueForFieldCode,
          RecordChangedEventID);
        WorkflowSetup.InsertChangeRecValueArgument(RevertFieldResponseID, TableNo, FieldNo);
        CreateApprovalRequestResponseID := WorkflowSetup.InsertResponseStep(Workflow, RecCreateApprovalRequestsCode,
          RevertFieldResponseID);
        WorkflowSetup.InsertApprovalArgument(CreateApprovalRequestResponseID, WorkflowStepArgument."Approver Type",
          WorkflowStepArgument."Approver Limit Type", WorkflowStepArgument."Workflow User Group Code",
          WorkflowStepArgument."Approver User ID", WorkflowStepArgument."Due Date Formula", false);

        SendApprovalRequestResponseID := WorkflowSetup.InsertResponseStep(Workflow, RecSendApprovalRequestForApprovalCode,
            CreateApprovalRequestResponseID);
        WorkflowSetup.InsertNotificationArgument(SendApprovalRequestResponseID, false, '', 0, '');
        ShowMessageResponseID := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.ShowMessageCode,
            SendApprovalRequestResponseID);
        WorkflowSetup.InsertMessageArgument(ShowMessageResponseID, CopyStr(RecordChangeApprovalMsg, 1, 250));

        OnAllRequestsApprovedEventID := WorkflowSetup.InsertEventStep(Workflow, WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode,
            ShowMessageResponseID);
        WorkflowSetup.InsertEventArgument(OnAllRequestsApprovedEventID, WorkflowSetup.BuildNoPendingApprovalsConditions);
        ApplyNewValuesResponseID := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.ApplyNewValuesCode,
            OnAllRequestsApprovedEventID);
        WorkflowSetup.InsertChangeRecValueArgument(ApplyNewValuesResponseID, TableNo, FieldNo);

        OnRequestApprovedEventID := WorkflowSetup.InsertEventStep(Workflow, WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode,
            ShowMessageResponseID);
        WorkflowSetup.InsertEventArgument(OnRequestApprovedEventID, WorkflowSetup.BuildPendingApprovalsConditions);
        SendApprovalRequestResponseID2 := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.SendApprovalRequestForApprovalCode,
            OnRequestApprovedEventID);

        WorkflowSetup.SetNextStep(Workflow, SendApprovalRequestResponseID2, ShowMessageResponseID);

        OnRequestRejectedEventID := WorkflowSetup.InsertEventStep(Workflow, WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode,
            ShowMessageResponseID);
        DiscardNewValuesResponseID := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.DiscardNewValuesCode,
            OnRequestRejectedEventID);
        RejectAllApprovalsResponseID := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.RejectAllApprovalRequestsCode,
            DiscardNewValuesResponseID);
        WorkflowSetup.InsertNotificationArgument(RejectAllApprovalsResponseID, false, '', WorkflowStepArgument."Link Target Page", '');

        OnRequestCanceledEventID := WorkflowSetup.InsertEventStep(Workflow, WorkflowEventHandling.RunWorkflowOnCancelItemApprovalRequestCode, ShowMessageResponseID);
        CancelAllApprovalsResponseID := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.CancelAllApprovalRequestsCode,
            OnRequestCanceledEventID);
        WorkflowSetup.InsertNotificationArgument(CancelAllApprovalsResponseID, false, '', WorkflowStepArgument."Link Target Page", '');

        OnRequestDelegatedEventID := WorkflowSetup.InsertEventStep(Workflow, WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode,
            ShowMessageResponseID);
        SentApprovalRequestResponseID3 := WorkflowSetup.InsertResponseStep(Workflow, WorkflowResponseHandling.SendApprovalRequestForApprovalCode,
            OnRequestDelegatedEventID);

        WorkflowSetup.SetNextStep(Workflow, SentApprovalRequestResponseID3, ShowMessageResponseID);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertWorkflowTemplate(Workflow: Record Workflow)
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::Allergen, 'OnAfterInsertEvent', '', true, false)]
    local procedure Allergen_OnAfterInsert(var Rec: Record Allergen; RunTrigger: Boolean)
    var
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        if Rec.IsTemporary then
            exit;

        WorkflowManagement.HandleEvent(RunWorkflowOnAddAllergenCode, Rec);
    end;

    procedure RunWorkflowOnDeleteAllergenCode(): Code[128]
    begin
        exit('RUNWORKFLOWONDELETEALLERGEN');
    end;

    [EventSubscriber(ObjectType::Table, Database::Allergen, 'OnAfterDeleteEvent', '', true, false)]
    local procedure Allergen_OnAfterDelete(var Rec: Record Allergen; RunTrigger: Boolean)
    var
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        if Rec.IsTemporary then
            exit;

        if RunTrigger then
            WorkflowManagement.HandleEvent(RunWorkflowOnDeleteAllergenCode, Rec);
    end;

    procedure RunWorkFlowOnCancelAllergenApprovalRequestCode(): Code[128]
    begin
        exit('RUNWORKFLOWONCANCELALLERGENAPPROVALREQUEST');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnCancelAllergenApprovalRequest', '', true, false)]
    local procedure ApprovalsMgmt_OnCancelAllergenApprovalRequest(var Allergen: Record Allergen)
    var
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        if Allergen.IsTemporary then
            exit;

        WorkflowManagement.HandleEvent(RunWorkFlowOnCancelAllergenApprovalRequestCode, Allergen);
    end;

    procedure ClearAllergenBlockedFlagCode(): Code[128]
    begin
        exit('CLEARALLERGENBLOCKEDFLAG');
    end;

    local procedure ClearAllergenBlockedFlag(Variant: Variant)
    var
        RecRef: RecordRef;
        ApprovalEntry: Record "Approval Entry";
        Allergen: Record Allergen;
    begin
        RecRef.GetTable(Variant);

        case RecRef.Number of
            DATABASE::"Approval Entry":
                begin
                    ApprovalEntry := Variant;
                    if ApprovalEntry."Table ID" <> DATABASE::Allergen then
                        Error(UnsupportedRecordTypeErr, RecRef.Caption);
                    RecRef.Get(ApprovalEntry."Record ID to Approve");
                    RecRef.SetTable(Allergen);
                end;
            DATABASE::Allergen:
                Allergen := Variant;
            else
                Error(UnsupportedRecordTypeErr, RecRef.Caption);
        end;

        Allergen.Validate(Blocked, false);
        Allergen.Modify(false);
    end;

    procedure DeleteAllergenRecordCode(): Code[128]
    begin
        exit('DELETEALLERGENRECORD');
    end;

    local procedure DeleteAllergenRecord(Variant: Variant)
    var
        RecRef: RecordRef;
        ApprovalEntry: Record "Approval Entry";
        Allergen: Record Allergen;
    begin
        RecRef.GetTable(Variant);

        case RecRef.Number of
            DATABASE::"Approval Entry":
                begin
                    ApprovalEntry := Variant;
                    if ApprovalEntry."Table ID" <> DATABASE::Allergen then
                        Error(UnsupportedRecordTypeErr, RecRef.Caption);
                    RecRef.Get(ApprovalEntry."Record ID to Approve");
                    RecRef.SetTable(Allergen);
                end;
            DATABASE::Allergen:
                Allergen := Variant;
            else
                Error(UnsupportedRecordTypeErr, RecRef.Caption);
        end;

        Allergen.Delete;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnExecuteWorkflowResponse', '', true, false)]
    local procedure WorkflowResponseHandling_OnExecuteWorkflowResponse(var ResponseExecuted: Boolean; Variant: Variant; xVariant: Variant; ResponseWorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowResponse: Record "Workflow Response";
    begin
        if WorkflowResponse.Get(ResponseWorkflowStepInstance."Function Name") then
            case WorkflowResponse."Function Name" of
                ClearAllergenBlockedFlagCode:
                    begin
                        ClearAllergenBlockedFlag(Variant);
                        ResponseExecuted := true;
                    end;
                DeleteAllergenRecordCode:
                    begin
                        DeleteAllergenRecord(Variant);
                        ResponseExecuted := true;
                    end;
            end;
    end;
}

