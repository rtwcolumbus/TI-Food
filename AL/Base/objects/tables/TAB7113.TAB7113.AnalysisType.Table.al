table 7113 "Analysis Type"
{
    // PR5.00
    // P8000500A, VerticalSoft, Jack Reynolds, 01 AUG 07
    //   Support for alternate quantity as a value type
    // 
    // PRW16.00.05
    // P8000921, Columbus IT, Don Bresee, 08 APR 11
    //   Add "Sales Amount (FOB)" and "Sales Amount (Freight)" options to the "Value Type" field

    Caption = 'Analysis Type';
    DataCaptionFields = "Code", Name;
    DrillDownPageID = "Analysis Type List";
    LookupPageID = "Analysis Type List";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
        }
        field(3; "Value Type"; Enum "Analysis Value Type")
        {
            Caption = 'Value Type';

            trigger OnValidate()
            begin
                if xRec."Value Type" <> "Value Type" then begin
                    "Item Ledger Entry Type Filter" := '';
                    "Value Entry Type Filter" := '';
                end;
            end;
        }
        field(4; "Item Ledger Entry Type Filter"; Text[250])
        {
            Caption = 'Item Ledger Entry Type Filter';

            trigger OnValidate()
            begin
                if "Item Ledger Entry Type Filter" <> '' then
                    if not CanUseValueTypeForItemLedgerEntryTypeFilter() then
                        Error(Text000, FieldCaption("Item Ledger Entry Type Filter"), "Value Type");
                AnalysisRepMgmt.ValidateFilter(
                  "Item Ledger Entry Type Filter", DATABASE::"Analysis Type",
                  FieldNo("Item Ledger Entry Type Filter"), CurrFieldNo <> FieldNo("Item Ledger Entry Type Filter"));
            end;
        }
        field(5; "Value Entry Type Filter"; Text[250])
        {
            Caption = 'Value Entry Type Filter';

            trigger OnValidate()
            begin
                if "Value Entry Type Filter" <> '' then
                    if not CanUseValueTypeForValueEntryTypeFilter() then
                        Error(Text000, FieldCaption("Value Entry Type Filter"), "Value Type");
                AnalysisRepMgmt.ValidateFilter(
                  "Value Entry Type Filter", DATABASE::"Analysis Type",
                  FieldNo("Value Entry Type Filter"), CurrFieldNo <> FieldNo("Value Entry Type Filter"));
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        AnalysisRepMgmt: Codeunit "Analysis Report Management";

        Text000: Label 'You cannot specify a %1 for %2.';
        Text001: Label 'COGS';
        Text002: Label 'Non-Inventoriable Cost';
        Text003: Label 'Sales Amount';
        Text004: Label 'Sales Quantity';
        Text005: Label 'Unit Price';
        Text006: Label 'COGS';
        Text007: Label 'NON-INVTBL';
        Text008: Label 'SALES-AMT';
        Text009: Label 'SALES-QTY';
        Text010: Label 'UNIT-PRICE';
        Text011: Label 'Direct Cost';
        Text012: Label 'DIRCOST';
        Text013: Label 'Purchases';
        Text014: Label 'PURCHASES';
        Text015: Label 'Purchases Quantity';
        Text016: Label 'PURCH-QTY';
        Text017: Label 'Direct Cost - Capacity';
        Text018: Label 'DIRCOSTCAP';
        Text019: Label 'Indirect Cost';
        Text020: Label 'INDIRCOST';
        Text021: Label 'Revaluation';
        Text022: Label 'REVAL';
        Text023: Label 'Rounding';
        Text024: Label 'ROUNDING';
        Text025: Label 'Variance';
        Text026: Label 'VARIANCE';
        Text027: Label 'Inventory';
        Text028: Label 'INVENTORY';
        Text029: Label 'Consumption';
        Text030: Label 'CONSUMP';
        Text031: Label 'Negative Adjustment';
        Text032: Label 'N-ADJTM';
        Text033: Label 'Output';
        Text034: Label 'OUTPUT';
        Text035: Label 'Postive Adjustment';
        Text036: Label 'P-ADJTM';
        Text037: Label 'Transfer';
        Text038: Label 'TRANSFER';
        Text039: Label 'Consumption Quantity';
        Text040: Label 'CONSUMPQTY';
        Text041: Label 'Inventory Quantity';
        Text042: Label 'INVT-QTY';
        Text043: Label 'Neg. Adjmt. Quantity';
        Text044: Label 'N-ADJTMQTY';
        Text045: Label 'Output Quantity';
        Text046: Label 'OUTPUT-QTY';
        Text047: Label 'Pos. Adjmt. Quantity';
        Text048: Label 'P-ADJTMQTY';
        Text049: Label 'Transfer Quantity';
        Text050: Label 'TRANS-QTY';
        Text051: Label 'Standard Cost';
        Text052: Label 'STDCOST';
        Text053: Label 'Indirect Cost %';
        Text054: Label 'INDCOSTPCT';
        Text055: Label 'The default Analysis Types have been recreated.';
        Text37002001: Label 'Sales Quantity (Alt.)';
        Text37002002: Label 'SALES-QTYA';
        Text37002003: Label 'Purchases Quantity (Alt.)';
        Text37002004: Label 'PURCH-QTYA';
        Text37002005: Label 'Consumption Quantity (Alt.)';
        Text37002006: Label 'CONSUMQTYA';
        Text37002007: Label 'Inventory Quantity (Alt.)';
        Text37002008: Label 'INVT-QTYA';
        Text37002009: Label 'Neg. Adjmt. Quantity (Alt.)';
        Text37002010: Label 'N-ADJQTYA';
        Text37002011: Label 'Output Quantity (Alt.)';
        Text37002012: Label 'OUT-QTYA';
        Text37002013: Label 'Pos. Adjmt. Quantity (Alt.)';
        Text37002014: Label 'P-ADJQTYA';
        Text37002015: Label 'Transfer Quantity (Alt.)';
        Text37002016: Label 'TRANS-QTYA';
        Text37002049: Label 'SALES-FOB';
        Text37002050: Label 'Sales Amount (FOB)';
        Text37002051: Label 'SALES-FRT';
        Text37002052: Label 'Sales Amount (Freight)';

    local procedure CanUseValueTypeForItemLedgerEntryTypeFilter() CanUseValueType: Boolean
    begin
        CanUseValueType := "Value Type" in
          ["Value Type"::Quantity,
            "Value Type"::"Cost Amount",
            "Value Type"::"Non-Invntble Amount",
            "Value Type"::"Sales Amount"];

        // P8000921
        CanUseValueType := CanUseValueType or ("Value Type" in
          ["Value Type"::FOODQuantityAlt, // P800500A
            "Value Type"::FOODSalesAmountFOB,
            "Value Type"::FOODSalesAmounttFreight]);
        // P8000921

        OnAfterCanUseValueTypeForItemLedgerEntryTypeFilter(Rec, CanUseValueType);
    end;

    local procedure CanUseValueTypeForValueEntryTypeFilter() CanUseValueType: Boolean
    begin
        CanUseValueType := "Value Type" in
          ["Value Type"::"Cost Amount",
            "Value Type"::"Non-Invntble Amount",
            "Value Type"::"Sales Amount"];

        // P8000921
        CanUseValueType := CanUseValueType or ("Value Type" in
          ["Value Type"::FOODSalesAmountFOB,
            "Value Type"::FOODSalesAmounttFreight]);
        // P8000921

        OnAfterCanUseValueTypeForValueEntryTypeFilter(Rec, CanUseValueType);
    end;

    procedure ResetDefaultAnalysisTypes(ShowMessage: Boolean)
    var
        ItemStatBuf: Record "Item Statistics Buffer";
    begin
        InsertItemAnalysisType(
          Text001,
          Text006,
          StrSubstNo('=''%1''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::Sale)),
          StrSubstNo('<>''%1''', Format(ItemStatBuf."Entry Type Filter"::Revaluation)),
          "Value Type"::"Cost Amount");
        InsertItemAnalysisType(
          Text007,
          Text002,
          '<>'' ''',
          '',
          "Value Type"::"Non-Invntble Amount");
        InsertItemAnalysisType(
          Text008,
          Text003,
          StrSubstNo('=''%1''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::Sale)),
          StrSubstNo('<>''%1''', Format(ItemStatBuf."Entry Type Filter"::Revaluation)),
          "Value Type"::"Sales Amount");
        // P8000921
        InsertItemAnalysisType(
          Text37002049,
          Text37002050,
          Format(ItemStatBuf."Item Ledger Entry Type Filter"::Sale),
          StrSubstNo('<>%1', Format(ItemStatBuf."Entry Type Filter"::Revaluation)),
          "Value Type"::FOODSalesAmountFOB);
        InsertItemAnalysisType(
          Text37002051,
          Text37002052,
          Format(ItemStatBuf."Item Ledger Entry Type Filter"::Sale),
          StrSubstNo('<>%1', Format(ItemStatBuf."Entry Type Filter"::Revaluation)),
          "Value Type"::FOODSalesAmounttFreight);
        // P8000921
        InsertItemAnalysisType(
          Text009,
          Text004,
          StrSubstNo('=''%1''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::Sale)),
          '',
          "Value Type"::Quantity);
        InsertItemAnalysisType(
          Text010,
          Text005,
          '',
          '',
          "Value Type"::"Unit Price");
        InsertItemAnalysisType(
          Text012,
          Text011,
          StrSubstNo('<>''%1''&<>'' ''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::Sale)),
          StrSubstNo('=''%1''', Format(ItemStatBuf."Entry Type Filter"::"Direct Cost")),
          "Value Type"::"Cost Amount");
        InsertItemAnalysisType(
          Text014,
          Text013,
          StrSubstNo('=''%1''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::Purchase)),
          '',
          "Value Type"::"Cost Amount");
        InsertItemAnalysisType(
          Text016,
          Text015,
          StrSubstNo('=''%1''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::Purchase)),
          '',
          "Value Type"::Quantity);
        InsertItemAnalysisType(
          Text018,
          Text017,
          ''' ''',
          StrSubstNo('=''%1''', Format(ItemStatBuf."Entry Type Filter"::"Direct Cost")),
          "Value Type"::"Cost Amount");
        InsertItemAnalysisType(
          Text020,
          Text019,
          StrSubstNo('<>''%1''&<>'' ''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::Sale)),
          StrSubstNo('=''%1''', Format(ItemStatBuf."Entry Type Filter"::"Indirect Cost")),
          "Value Type"::"Cost Amount");
        InsertItemAnalysisType(
          Text022,
          Text021,
          StrSubstNo('<>''%1''&<>'' ''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::Sale)),
          StrSubstNo('=''%1''', Format(ItemStatBuf."Entry Type Filter"::Revaluation)),
          "Value Type"::"Cost Amount");
        InsertItemAnalysisType(
          Text024,
          Text023,
          StrSubstNo('<>''%1''&<>'' ''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::Sale)),
          StrSubstNo('=''%1''', Format(ItemStatBuf."Entry Type Filter"::Rounding)),
          "Value Type"::"Cost Amount");
        InsertItemAnalysisType(
          Text026,
          Text025,
          StrSubstNo('<>''%1''&<>'' ''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::Sale)),
          StrSubstNo('=''%1''', Format(ItemStatBuf."Entry Type Filter"::Variance)),
          "Value Type"::"Cost Amount");

        InsertItemAnalysisType(
          Text028,
          Text027,
          '<>'' ''',
          '',
          "Value Type"::"Cost Amount");
        InsertItemAnalysisType(
          Text030,
          Text029,
          StrSubstNo('=''%1''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::Consumption)),
          '',
          "Value Type"::"Cost Amount");
        InsertItemAnalysisType(
          Text032,
          Text031,
          StrSubstNo('=''%1''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::"Negative Adjmt.")),
          '',
          "Value Type"::"Cost Amount");
        InsertItemAnalysisType(
          Text034,
          Text033,
          StrSubstNo('=''%1''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::Output)),
          StrSubstNo('<>''%1''', Format(ItemStatBuf."Entry Type Filter"::Variance)),
          "Value Type"::"Cost Amount");
        InsertItemAnalysisType(
          Text036,
          Text035,
          StrSubstNo('=''%1''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::"Positive Adjmt.")),
          '',
          "Value Type"::"Cost Amount");
        InsertItemAnalysisType(
          Text038,
          Text037,
          StrSubstNo('=''%1''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::Transfer)),
          '',
          "Value Type"::"Cost Amount");

        InsertItemAnalysisType(
          Text040,
          Text039,
          StrSubstNo('=''%1''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::Consumption)),
          '',
          "Value Type"::Quantity);
        InsertItemAnalysisType(
          Text042,
          Text041,
          '<>'' ''',
          '',
          "Value Type"::Quantity);
        InsertItemAnalysisType(
          Text044,
          Text043,
          StrSubstNo('=''%1''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::"Negative Adjmt.")),
          '',
          "Value Type"::Quantity);
        InsertItemAnalysisType(
          Text046,
          Text045,
          StrSubstNo('=''%1''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::Output)),
          '',
          "Value Type"::Quantity);
        InsertItemAnalysisType(
          Text048,
          Text047,
          StrSubstNo('=''%1''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::"Positive Adjmt.")),
          '',
          "Value Type"::Quantity);
        InsertItemAnalysisType(
          Text050,
          Text049,
          StrSubstNo('=''%1''', Format(ItemStatBuf."Item Ledger Entry Type Filter"::Transfer)),
          '',
          "Value Type"::Quantity);

        InsertItemAnalysisType(
          Text052,
          Text051,
          '',
          '',
          "Value Type"::"Standard Cost");
        InsertItemAnalysisType(
          Text054,
          Text053,
          '',
          '',
          "Value Type"::"Indirect Cost");

        // P8000500A
        InsertItemAnalysisType(
          Text37002002,
          Text37002001,
          Format(ItemStatBuf."Item Ledger Entry Type Filter"::Sale),
          '',
          "Value Type"::FOODQuantityAlt);
        InsertItemAnalysisType(
          Text37002004,
          Text37002003,
          Format(ItemStatBuf."Item Ledger Entry Type Filter"::Purchase),
          '',
          "Value Type"::FOODQuantityAlt);
        InsertItemAnalysisType(
          Text37002006,
          Text37002005,
          Format(ItemStatBuf."Item Ledger Entry Type Filter"::Consumption),
          '',
          "Value Type"::FOODQuantityAlt);
        InsertItemAnalysisType(
          Text37002008,
          Text37002007,
          '<>'' ''',
          '',
          "Value Type"::FOODQuantityAlt);
        InsertItemAnalysisType(
          Text37002010,
          Text37002009,
          Format(ItemStatBuf."Item Ledger Entry Type Filter"::"Negative Adjmt."),
          '',
          "Value Type"::FOODQuantityAlt);
        InsertItemAnalysisType(
          Text37002012,
          Text37002011,
          Format(ItemStatBuf."Item Ledger Entry Type Filter"::Output),
          '',
          "Value Type"::FOODQuantityAlt);
        InsertItemAnalysisType(
          Text37002014,
          Text37002013,
          Format(ItemStatBuf."Item Ledger Entry Type Filter"::"Positive Adjmt."),
          '',
          "Value Type"::FOODQuantityAlt);
        InsertItemAnalysisType(
          Text37002016,
          Text37002015,
          Format(ItemStatBuf."Item Ledger Entry Type Filter"::Transfer),
          '',
          "Value Type"::FOODQuantityAlt);
        // P8000500A

        if ShowMessage then
            Message(Text055);
    end;

    local procedure InsertItemAnalysisType(Code2: Code[10]; Name2: Text[30]; ItemLedgEntryTypeFilter: Text[250]; ValueEntryTypeFilter: Text[250]; ValueType: Enum "Analysis Value Type")
    var
        AnalysisType: Record "Analysis Type";
    begin
        with AnalysisType do begin
            Init();
            Code := Code2;
            Name := Name2;
            Validate("Value Type", ValueType);
            Validate("Item Ledger Entry Type Filter", ItemLedgEntryTypeFilter);
            Validate("Value Entry Type Filter", ValueEntryTypeFilter);
            if not Insert(true) then
                Modify(true);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCanUseValueTypeForItemLedgerEntryTypeFilter(AnalysisType: Record "Analysis Type"; var CanUseValueType: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCanUseValueTypeForValueEntryTypeFilter(AnalysisType: Record "Analysis Type"; var CanUseValueType: Boolean)
    begin
    end;
}

