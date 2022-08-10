codeunit 37002550 "Event Subscribers (Q/C)"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //
    // PRW119.03
    // P800122712, To Increase, Gangabhushan, 25 MAY 22
    //   Quality Control Samples

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterDeleteEvent', '', true, false)]
    local procedure Item_OnAfterDelete(var Rec: Record Item; RunTrigger: Boolean)
    var
        DataCollectionMgmt: Codeunit "Data Collection Management";
    begin
        // P80066030
        if Rec.IsTemporary then
            exit;

        DataCollectionMgmt.DeleteDataCollectionLines(DATABASE::Item, Rec."No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Quality Control Header", 'OnAfterInsertEvent', '', true, false)]
    local procedure QualityControlHeader_OnAfterInsert(var Rec: Record "Quality Control Header"; RunTrigger: Boolean)
    var
        TempTransaction: Record "Item Quality Skip Logic Trans." temporary;
        ItemQCSkipLogicManagement: Codeunit "Item Q/C Skip Logic Management";
    begin
        if Rec.IsTemporary then
            exit;

        if Rec."Test No." > 1 then
            exit;

        ItemQCSkipLogicManagement.ApplySkipLogic(Rec, TempTransaction);
        Rec.Validate(Status, TempTransaction."Test Status");
        Rec.Modify;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Quality Control Header", 'OnAfterValidateEvent', 'Status', true, false)]
    local procedure QualityControlHeader_OnAfterValidate_Status(var Rec: Record "Quality Control Header"; var xRec: Record "Quality Control Header"; CurrFieldNo: Integer)
    var
        TempTransaction: Record "Item Quality Skip Logic Trans." temporary;
        LastSkipLogicTrans: Record "Item Quality Skip Logic Trans.";
        SkipLogicTrans: Record "Item Quality Skip Logic Trans.";
        ItemQCSkipLogicManagement: Codeunit "Item Q/C Skip Logic Management";
        Skip: Boolean;
    begin
        if Rec.IsTemporary then
            exit;

        if not ItemQCSkipLogicManagement.UseQCActivity(Rec) then
            exit;

        ItemQCSkipLogicManagement.ApplySkipLogic(Rec, TempTransaction);

        if TempTransaction.IsEmpty then
            exit;

        //Insert new transaction
        SkipLogicTrans.Init;
        SkipLogicTrans := TempTransaction;
        SkipLogicTrans."Line No." += 10000;
        SkipLogicTrans."Test Status" := Rec.Status;
        case SkipLogicTrans."Test Status" of
            SkipLogicTrans."Test Status"::Pass:
                SkipLogicTrans."Current Accepted Events" += 1;
            SkipLogicTrans."Test Status"::Skip:
                SkipLogicTrans."Current Skipped Events" += 1;
        end;
        SkipLogicTrans."Transaction Date" := WorkDate;
        SkipLogicTrans.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process 800 Core Functions", 'OnInitializeP800', '', true, false)]
    local procedure Process800CoreFunctions_OnInitializeP800(CompName: Text[30]; var SourceCodeSetup: Record "Source Code Setup"; var SourceCode: Record "Source Code"; var ReportSelections: Record "Report Selections")
    var
        QCSAMPLE: Label 'QC SAMPLE';
        Process800CoreFunctions: Codeunit "Process 800 Core Functions";
    begin
        // P800122712
        Process800CoreFunctions.InsertSourceCode(SourceCode, SourceCodeSetup."Quality Control Sample", QCSAMPLE, Process800CoreFunctions.PageName(PAGE::"Quality Control SampleHdr.Page"));
    end;
}

