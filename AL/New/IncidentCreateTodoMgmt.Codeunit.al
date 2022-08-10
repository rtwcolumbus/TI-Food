codeunit 37002548 "Incident Create To-do Mgmt."
{
    // PRW111.00.01
    // P80036649, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Incident/Complaint Registration
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        TempInsertToDo: Record "To-do" temporary;

    [EventSubscriber(ObjectType::Table, Database::"To-do", 'OnAfterInsertEvent', '', true, false)]
    local procedure ToDo_OnAfterInsert(var Rec: Record "To-do"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if Rec.IsTemporary then
            exit;

        TempInsertToDo := Rec;
        if TempInsertToDo.Insert then;
    end;

    procedure GetToDo() TodoNo: Code[20]
    begin
        if TempInsertToDo.FindFirst then
            TodoNo := TempInsertToDo."No.";
        TempInsertToDo.Reset;
        TempInsertToDo.DeleteAll;
    end;
}

