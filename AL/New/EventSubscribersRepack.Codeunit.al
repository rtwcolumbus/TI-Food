codeunit 37002214 "Event Subscribers (Repack)"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnAfterGetPageID', '', true, false)]
    local procedure PageManagement_OnAfterGetPageID(RecordRef: RecordRef; var PageID: Integer)
    var
        RepackOrder: Record "Repack Order";
    begin
        // P8004516, P80066030
        case RecordRef.Number of
            DATABASE::"Repack Order":
                begin
                    RecordRef.SetTable(RepackOrder);
                    if RepackOrder.Status = RepackOrder.Status::Finished then
                        PageID := PAGE::"Finished Repack Order"
                    else
                        PageID := PAGE::"Repack Order";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process 800 Core Functions", 'OnInitializeP800', '', true, false)]
    local procedure Process800CoreFunctions_OnInitializeP800(CompName: Text[30]; var SourceCodeSetup: Record "Source Code Setup"; var SourceCode: Record "Source Code"; var ReportSelections: Record "Report Selections")
    var
        REPACK: Label 'REPACK';
        Process800CoreFunctions: Codeunit "Process 800 Core Functions";
    begin
        // P80066030
        Process800CoreFunctions.InsertSourceCode(SourceCode, SourceCodeSetup."Repack Order", REPACK, Process800CoreFunctions.PageName(PAGE::"Repack Order"));

        Process800CoreFunctions.InsertRepSelection(ReportSelections, ReportSelections.Usage::FOODRepackOrder, '1', REPORT::"Repack Order");
    end;
}

