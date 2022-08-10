codeunit 37002028 "Event Subscribers (Lot)"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    //    
    // PRW113.00.03
    // P80084737, To Increase, Jack Reynolds, 10 OCT 19
    //   Modify subscriptions for RunTrigger
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnAfterDeleteEvent', '', true, false)]
    local procedure Location_OnAfterDelete(var Rec: Record Location; RunTrigger: Boolean)
    var
        LotSegmentValue: Record "Lot No. Segment Value";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        if LotSegmentValue.Get(LotSegmentValue.Type::Location, Rec.Code) then
            LotSegmentValue.Delete(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterDeleteEvent', '', true, false)]
    local procedure Customer_OnAfterDelete(var Rec: Record Customer; RunTrigger: Boolean)
    var
        LotSpecFns: Codeunit "Lot Specification Functions";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        LotSpecFns.DeleteCustomerLotPrefs(Rec); // P8000153A
    end;

    [EventSubscriber(ObjectType::Table, Database::"Work Shift", 'OnAfterDeleteEvent', '', true, false)]
    local procedure WorkShift_OnAfterDelete(var Rec: Record "Work Shift"; RunTrigger: Boolean)
    var
        LotSegmentValue: Record "Lot No. Segment Value";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        // P8001234
        if LotSegmentValue.Get(LotSegmentValue.Type::Shift, Rec.Code) then
            LotSegmentValue.Delete(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Production BOM Line", 'OnAfterDeleteEvent', '', true, false)]
    local procedure ProductionBOMLine_OnAfterDelete(var Rec: Record "Production BOM Line"; RunTrigger: Boolean)
    var
        LotSpecFns: Codeunit "Lot Specification Functions";
    begin
        // P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        LotSpecFns.DeleteBOMLineLotPrefs(Rec);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Delete Invoiced Sales Orders", 'OnAfterDeleteSalesLine', '', true, false)]
    local procedure DeleteInvoicedSalesOrders_OnAfterDeleteSalesLine(var SalesLine: Record "Sales Line")
    var
        LotSpecFns: Codeunit "Lot Specification Functions";
    begin
        // P80066030
        LotSpecFns.DeleteSalesLineLotPrefs(SalesLine); // P8000153A
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnAfterClearTrackingSpec', '', true, false)]
    local procedure ItemTrackingLines_OnAfterClearTrackingSpec(var OldTrkgSpec: Record "Tracking Specification")
    begin
        // P80053245
        OldTrkgSpec."Supplier Lot No." := ''; // P8001106
        OldTrkgSpec."Lot Creation Date" := 0D;             // P8008351
        OldTrkgSpec."Country/Region of Origin Code" := ''; // P8008351
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnAfterCopyTrackingSpec', '', true, false)]
    local procedure ItemTrackingLines_OnAfterCopyTrackingSpec(var SourceTrackingSpec: Record "Tracking Specification"; var DestTrkgSpec: Record "Tracking Specification")
    begin
        // P80053245
        DestTrkgSpec."Supplier Lot No." := SourceTrackingSpec."Supplier Lot No."; // P8001106
        DestTrkgSpec."Lot Creation Date" := SourceTrackingSpec."Lot Creation Date";                         // P8008351
        DestTrkgSpec."Country/Region of Origin Code" := SourceTrackingSpec."Country/Region of Origin Code"; // P8008351
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInsertItemLedgEntry', '', true, false)]
    local procedure ItemJnlPostLine_OnAfterInsertItemLedgEntry(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    var
        LotStatusManagement: Codeunit "Lot Status Management";
    begin
        // P80053245
        LotStatusManagement.InsertItemLedger(ItemLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInsertCorrItemLedgEntry', '', true, false)]
    local procedure ItemJnlPostLine_OnAfterInsertCorrItemLedgEntry(var NewItemLedgerEntry: Record "Item Ledger Entry"; var ItemJournalLine: Record "Item Journal Line"; var OldItemLedgerEntry: Record "Item Ledger Entry")
    var
        LotStatusManagement: Codeunit "Lot Status Management";
    begin
        // P80066030
        LotStatusManagement.InsertItemLedger(NewItemLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterInitToSalesLine', '', true, false)]
    local procedure CopyDocumentMgt_OnAfterInitToSalesLine(var ToSalesLine: Record "Sales Line")
    var
        LotSpecificationFunctions: Codeunit "Lot Specification Functions";
    begin
        // P80053245
        LotSpecificationFunctions.CopyLotPrefCustomerToSalesLine(ToSalesLine); // P8000153A, P8000210A
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process 800 Core Functions", 'OnInitializeP800', '', true, false)]
    local procedure Process800CoreFunctions_OnInitializeP800(CompName: Text[30]; var SourceCodeSetup: Record "Source Code Setup"; var SourceCode: Record "Source Code"; var ReportSelections: Record "Report Selections")
    var
        Available: Label 'Available';
        QUARANTINE: Label 'QUARANTINE';
        QualityControlQuarantine: Label 'Quality Control Quarantine';
        LotStatus: Record "Lot Status Code";
        InvSetup: Record "Inventory Setup";
        Process800Fns: Codeunit "Process 800 Functions";
    begin
        // P80066030
        if CompName <> CompanyName then begin
            LotStatus.ChangeCompany(CompName);
            InvSetup.ChangeCompany(CompName);
        end;

        if LotStatus.Get then
            exit;

        LotStatus.Init;
        LotStatus.Description := Available;
        LotStatus.Insert;

        if Process800Fns.QCInstalled then begin
            LotStatus.Code := QUARANTINE;
            LotStatus.Description := QualityControlQuarantine;
            LotStatus."Available for Sale" := false;
            LotStatus."Available for Consumption" := false;
            LotStatus.Insert;

            InvSetup.Get;
            InvSetup."Quarantine Lot Status" := QUARANTINE;
            InvSetup.Modify;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnBeforeCreateRemainingReservEntry', '', true, false)]
    local procedure CreateReservEntry_OnBeforeCreateRemainingReservEntry(var ReservationEntry: Record "Reservation Entry"; FromReservationEntry: Record "Reservation Entry")
    begin
        // P80073095
        ReservationEntry."Supplier Lot No." := FromReservationEntry."Supplier Lot No."; // P8001106
        ReservationEntry."Country/Region of Origin Code" := FromReservationEntry."Country/Region of Origin Code"; // P8008351
        ReservationEntry."Lot Creation Date" := FromReservationEntry."Lot Creation Date";                         // P8008351
    end;
}

