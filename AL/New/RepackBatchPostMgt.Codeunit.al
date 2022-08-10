codeunit 37002213 "Repack Batch Post Mgt."
{
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    EventSubscriberInstance = Manual;
    Permissions = TableData "Batch Processing Parameter" = rimd,
                  TableData "Batch Processing Parameter Map" = rimd;
    TableNo = "Repack Order";

    trigger OnRun()
    var
        RepackOrder: Record "Repack Order";
        RepackBatchPostMgt: Codeunit "Repack Batch Post Mgt.";
    begin
        RepackOrder.Copy(Rec);

        BindSubscription(RepackBatchPostMgt);
        RepackBatchPostMgt.SetPostingCodeunitId(PostingCodeunitID);
        RepackBatchPostMgt.SetBatchProcessor(BatchProcessingMgt);
        RepackBatchPostMgt.Code(RepackOrder);

        Rec := RepackOrder;
    end;

    var
        PostingDateIsNotSetErr: Label 'Enter the posting date.';
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        PostingCodeunitID: Integer;

    procedure RunBatch(var RepackOrder: Record "Repack Order"; ReplacePostingDate: Boolean; PostingDate: Date; Transfer: Boolean; Produce: Boolean)
    var
        BatchPostParameterTypes: Codeunit "Batch Post Parameter Types";
        RepackBatchPostMgt: Codeunit "Repack Batch Post Mgt.";
    begin
        if ReplacePostingDate and (PostingDate = 0D) then
            Error(PostingDateIsNotSetErr);

        BatchProcessingMgt.AddParameter(37002000, Transfer);
        BatchProcessingMgt.AddParameter(37002001, Produce);
        BatchProcessingMgt.AddParameter(BatchPostParameterTypes.PostingDate, PostingDate);
        BatchProcessingMgt.AddParameter(BatchPostParameterTypes.ReplacePostingDate, ReplacePostingDate);

        RepackBatchPostMgt.SetBatchProcessor(BatchProcessingMgt);
        RepackBatchPostMgt.Run(RepackOrder);
    end;

    procedure RunWithUI(var RepackOrder: Record "Repack Order"; TotalCount: Integer; Question: Text)
    var
        TempErrorMessage: Record "Error Message" temporary;
        RepackBatchPostMgt: Codeunit "Repack Batch Post Mgt.";
        ErrorMessages: Page "Error Messages";
    begin
        if not Confirm(StrSubstNo(Question, RepackOrder.Count, TotalCount), true) then
            exit;

        RepackBatchPostMgt.SetBatchProcessor(BatchProcessingMgt);
        RepackBatchPostMgt.Run(RepackOrder);
        BatchProcessingMgt.GetErrorMessages(TempErrorMessage);

        if TempErrorMessage.FindFirst then begin
            ErrorMessages.SetRecords(TempErrorMessage);
            ErrorMessages.Run;
        end;
    end;

    procedure GetBatchProcessor(var ResultBatchProcessingMgt: Codeunit "Batch Processing Mgt.")
    begin
        ResultBatchProcessingMgt := BatchProcessingMgt;
    end;

    procedure SetBatchProcessor(NewBatchProcessingMgt: Codeunit "Batch Processing Mgt.")
    begin
        BatchProcessingMgt := NewBatchProcessingMgt;
    end;

    procedure "Code"(var RepackOrder: Record "Repack Order")
    var
        RecRef: RecordRef;
    begin
        if PostingCodeunitID = 0 then
            PostingCodeunitID := CODEUNIT::"Repack-Post";

        RecRef.GetTable(RepackOrder);

        BatchProcessingMgt.SetProcessingCodeunit(PostingCodeunitID);
        BatchProcessingMgt.BatchProcess(RecRef);

        RecRef.SetTable(RepackOrder);
    end;

    local procedure PrepareRepackOrder(var RepackOrder: Record "Repack Order"; var BatchConfirm: Option)
    var
        BatchPostParameterTypes: Codeunit "Batch Post Parameter Types";
        ReplacePostingDate: Boolean;
        PostingDate: Date;
    begin
        BatchProcessingMgt.GetParameterBoolean(RepackOrder.RecordId, BatchPostParameterTypes.ReplacePostingDate, ReplacePostingDate);
        BatchProcessingMgt.GetParameterDate(RepackOrder.RecordId, BatchPostParameterTypes.PostingDate, PostingDate);

        if ReplacePostingDate and (RepackOrder."Posting Date" <> PostingDate) then
            RepackOrder."Posting Date" := PostingDate;

        BatchProcessingMgt.GetParameterBoolean(RepackOrder.RecordId, 37002000, RepackOrder.Transfer);
        BatchProcessingMgt.GetParameterBoolean(RepackOrder.RecordId, 37002001, RepackOrder.Produce);
    end;

    procedure SetPostingCodeunitId(NewPostingCodeunitId: Integer)
    begin
        PostingCodeunitID := NewPostingCodeunitId;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Batch Processing Mgt.", 'OnBeforeBatchProcessing', '', true, false)]
    local procedure BatchProcessingMgt_OnBeforeBatchProcessing(var RecRef: RecordRef; var BatchConfirm: Option)
    var
        RepackOrder: Record "Repack Order";
    begin
        RecRef.SetTable(RepackOrder);
        PrepareRepackOrder(RepackOrder, BatchConfirm);
        RecRef.GetTable(RepackOrder);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Batch Processing Mgt.", 'OnAfterBatchProcessing', '', true, false)]
    local procedure BatchProcessingMgt_OnAfterBatchProcessing(var RecRef: RecordRef; PostingResult: Boolean)
    begin
        if PostingResult then
            Commit;
    end;
}

