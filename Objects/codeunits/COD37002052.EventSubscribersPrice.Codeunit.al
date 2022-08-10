codeunit 37002052 "Event Subscribers (Price)"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'Bill-to Customer No.', true, false)]
    local procedure Customer_OnAfterValidate_BillToCustomerNo(var Rec: Record Customer; var xRec: Record Customer; CurrFieldNo: Integer)
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        // P8001026, P80066030
        if Rec."Bill-to Customer No." <> xRec."Bill-to Customer No." then
            if Rec."Bill-to Customer No." = '' then
                Rec."Use Sell-to Price Group" := false
            else begin
                SalesSetup.Get;
                Rec."Use Sell-to Price Group" := SalesSetup."Default Customer Price Group" = SalesSetup."Default Customer Price Group"::"Sell-to";
            end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnUpdateSalesLineByChangedFieldName', '', true, false)]
    local procedure SalesHeader_OnUpdateSalesLineByChangedFieldName(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ChangedFieldName: Text[100])
    begin
        // P80053245
        case ChangedFieldName of
            SalesHeader.FieldCaption("FOB Pricing"):
                begin
                    SalesLine.SetUnitPrice;
                    if SalesLine.Type = SalesLine.Type::Item then
                        SalesLine.Validate(Quantity);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterUpdateUnitPrice', '', true, false)]
    local procedure SalesLine_OnAfterUpdateUnitPrice(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CurrFieldNo: Integer)
    var
        SalesContractManagement: Codeunit "Sales Contract Management";
    begin
        // P80053245
        // P8000885
        if ((CurrFieldNo = SalesLine.FieldNo(Quantity)) or (CurrFieldNo = SalesLine.FieldNo("Unit of Measure Code"))) and (SalesLine.Type = SalesLine.Type::Item) then
            SalesContractManagement.ShowOverContLimitWarning(SalesLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnValidateNoOnCopyFromTempSalesLine', '', true, false)]
    local procedure SalesLine_OnValidateNoOnCopyFromTempSalesLine(var SalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line" temporary)
    begin
        // P80053245
        // P8000885
        if TempSalesLine."Contract No." <> '' then begin
            SalesLine."Contract No." := TempSalesLine."Contract No.";
            SalesLine."Outstanding Qty. (Contract)" := TempSalesLine."Outstanding Qty. (Contract)";
            SalesLine."Outstanding Qty. (Cont. Line)" := TempSalesLine."Outstanding Qty. (Cont. Line)";
            SalesLine."Price ID" := TempSalesLine."Price ID";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnUpdateSalesLineOnAfterRecalculateSalesLine', '', true, false)]
    local procedure CopyDocumentMgt_OnUpdateSalesLineOnAfterRecalculateSalesLine(var ToSalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line")
    begin
        // P80073095
        ToSalesLine.CorrectUnitPriceFOB;  // P8006632
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnBeforeModifySalesHeader', '', true, false)]
    local procedure CopyDocumentMgt_OnBeforeModifySalesHeader(var ToSalesHeader: Record "Sales Header"; FromDocType: Option; FromDocNo: Code[20]; IncludeHeader: Boolean)
    begin
        // P80053245
        ToSalesHeader.CreateOrderAllowance; // PR3.70
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Price Calc. Mgt.", 'OnGetCustNoForSalesHeader', '', true, false)]
    local procedure SalesPriceCalcMgt_OnGetCustNoForSalesHeader(SalesHeader: Record "Sales Header"; var CustomerNo: Code[20])
    begin
        // P80060646
        if (SalesHeader."Bill-to Customer No." <> SalesHeader."Sell-to Customer No.") and (SalesHeader."Bill-to Customer No." <> '') then
            CustomerNo := SalesHeader."Bill-to Customer No.";
    end;
}

