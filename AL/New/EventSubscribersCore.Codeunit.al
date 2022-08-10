codeunit 37002166 "Event Subscribers (Core)"
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
    //
    // PRW118.01
    // P800128960, To Increase, Jack Reynolds, 24 AUG 21
    //   Decimal precision on alternate quantity data entry

    trigger OnRun()
    begin
    end;

    var
        Text001: Label '%1 must begin with the %2.';

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterDeleteEvent', '', true, false)]
    local procedure Vendor_OnAfterDelete(var Rec: Record Vendor; RunTrigger: Boolean)
    var
        VendorCertification: Record "Vendor Certification";
    begin
        // P8001229, P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        VendorCertification.SetFilter("Source Type", '%1|%2', VendorCertification."Source Type"::Vendor, VendorCertification."Source Type"::"Order Address");
        VendorCertification.SetRange("Vendor No.", Rec."No.");
        VendorCertification.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnBeforeValidateEvent', 'GLN', true, false)]
    local procedure CompanyInformation_OnBeforeValidate_GLN(var Rec: Record "Company Information"; var xRec: Record "Company Information"; CurrFieldNo: Integer)
    begin
        // P80055555
        if (Rec.GLN <> '') and (Rec."GS1 Company Prefix" <> '') then
            if Rec."GS1 Company Prefix" <> CopyStr(Rec.GLN, 1, StrLen(Rec."GS1 Company Prefix")) then
                Error(Text001, Rec.FieldCaption(GLN), Rec.FieldCaption("GS1 Company Prefix"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromSalesLine', '', true, false)]
    local procedure ItemJournalLine_OnAfterCopyItemJnlLineFromSalesLine(var ItemJnlLine: Record "Item Journal Line"; SalesLine: Record "Sales Line")
    begin
        // P80053245
        ItemJnlLine."Don't Apply" := SalesLine."Writeoff Responsibility" <> 0; // P8007748
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterSetupNewLine', '', true, false)]
    local procedure ItemJournalLine_OnAfterSetupNewLine(var ItemJournalLine: Record "Item Journal Line"; var LastItemJournalLine: Record "Item Journal Line"; ItemJournalTemplate: Record "Item Journal Template")
    begin
        // P80073095
        ItemJournalLine."Phys. Inventory" := ItemJournalTemplate.Type = ItemJournalTemplate.Type::"Phys. Inventory"; // PR3.61.01
    end;

    [EventSubscriber(ObjectType::Table, Database::"Order Address", 'OnAfterDeleteEvent', '', true, false)]
    local procedure OrderAddress_OnAfterDelete(var Rec: Record "Order Address"; RunTrigger: Boolean)
    var
        VendorCertification: Record "Vendor Certification";
    begin
        // P8001229, P80066030
        if not RunTrigger then exit; // P80084737

        if Rec.IsTemporary then
            exit;

        VendorCertification.SetRange("Source Type", VendorCertification."Source Type"::"Order Address");
        VendorCertification.SetRange("Vendor No.", Rec."Vendor No.");
        VendorCertification.SetRange("Order Address Code", Rec.Code);
        VendorCertification.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Shipment Line", 'OnAfterCopyFromTransferLine', '', true, false)]
    local procedure TransferShipmentLine_OnAfterCopyFromTransferLine(var TransferShipmentLine: Record "Transfer Shipment Line"; TransferLine: Record "Transfer Line")
    begin
        // P80053245
        TransferShipmentLine."Supply Chain Group Code" := TransferLine."Supply Chain Group Code"; // P8007748
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Receipt Line", 'OnAfterCopyFromTransferLine', '', true, false)]
    local procedure TransferReceiptLine_OnAfterCopyFromTransferLine(var TransferReceiptLine: Record "Transfer Receipt Line"; TransferLine: Record "Transfer Line")
    begin
        // P80053245
        TransferReceiptLine."Supply Chain Group Code" := TransferLine."Supply Chain Group Code"; // P8007748
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', true, false)]
    local procedure ItemJnlPostLine_OnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    begin
        // P8004516
        NewItemLedgEntry."Writeoff Responsibility" := ItemJournalLine."Writeoff Responsibility";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertItemLedgEntry', '', true, false)]
    local procedure ItemJnlPostLine_OnBeforeInsertItemLedgEntry(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    begin
        // P80053245
        ItemLedgerEntry."Posting Date/Time" := CurrentDateTime; // P8001017
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnAfterLogInStart', '', true, false)]
    local procedure LogInManagement_OnAfterLogInStart()
    var
        Process800Fns: Codeunit "Process 800 Functions";
    begin
        // P80066030
        Process800Fns.SetDemoWorkDate; // P8001132, P8001352
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Auto Format", 'OnResolveAutoFormat', '', false, false)]
    local procedure AutoFormat_OnResolveAutoFormat(AutoFormatType: Enum "Auto Format"; AutoFormatExpr: Text[80]; var Result: Text[80]; var Resolved: Boolean)
    var
        Item: Record Item;
        AltQtyMgt: Codeunit "Alt. Qty. Management";
        ProcessFns: Codeunit "Process 800 Functions";
        NumDecimalPlaces: Integer;
        FormatTxt: Label '<Precision,%1><Standard Format,0>';
    begin
        // P800-MegaApp
        // P800128960
        if Resolved then
            exit;
        case AutoFormatType of
            AutoFormatType::FoodFormat:
                begin
                    Result := StrSubstNo(FormatTxt, AutoFormatExpr);
                    Resolved := true;
                end;
            AutoFormatType::FoodAltQty:
                begin
                    Result := StrSubstNo(FormatTxt, '0:5');
                    if AutoFormatExpr <> '' then
                        if ProcessFns.AltQtyInstalled() then
                            if Item.Get(AutoFormatExpr) then
                                if AltQtyMgt.GetMaxDecimalPlaces(Item."Alternate Unit of Measure", NumDecimalPlaces) then
                                    Result := StrSubstNo(FormatTxt, '0:' + Format(NumDecimalPlaces));
                    Resolved := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Blanket Purch. Order to Order", 'OnBeforeInsertPurchOrderHeader', '', true, false)]
    local procedure BlanketPurchOrderToOrder_OnBeforeInsertPurchOrderHeader(var PurchOrderHeader: Record "Purchase Header"; BlanketOrderPurchHeader: Record "Purchase Header")
    begin
        // P80053245
        PurchOrderHeader."Allow Unapproved Items" := BlanketOrderPurchHeader."Allow Unapproved Items"; // P8001230
    end;

    // P800122976
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process 800 Core Functions", 'OnInitializeP800', '', true, false)]
    local procedure Process800CoreFunctions_OnInitializeP800(CompName: Text[30]; var SourceCodeSetup: Record "Source Code Setup"; var SourceCode: Record "Source Code"; var ReportSelections: Record "Report Selections")
    var
        P800Utility: Codeunit "Process 800 Utility Functions";
    begin
        P800Utility.InitializeFOODTransactionNumber();
    end;
}

