table 37002041 "Item Cost Basis"
{
    // PR4.00
    // P8000245B, Myers Nissi, Jack Reynolds, 04 OCT 05
    //   Add field for variant code and make part of primary key
    //   Add variant code parameter to market price functions
    // 
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Add Cost Basis Code, add to primary key
    //   Add utility routines for Cost Basis Calculation Codeunits
    //
    // PRW116.00.05
    // P800103616, To-Increase, Gangabhushan, 04 FEB 21
    //  Enhance inventory costing with Book Cost     

    Caption = 'Item Cost Basis';
    DrillDownPageID = "Item Cost Basis";
    LookupPageID = "Item Cost Basis";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item;
        }
        field(2; "Cost Date"; Date)
        {
            Caption = 'Cost Date';
            NotBlank = true;
        }
        field(3; "Cost Value"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 2;
            Caption = 'Cost Value';
            MinValue = 0;
            NotBlank = true;
        }
        field(4; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(5; "Cost Basis Code"; Code[20])
        {
            Caption = 'Cost Basis Code';
            NotBlank = true;
            TableRelation = "Cost Basis";
        }
        field(6; "Reference Date"; Date)
        {
            Caption = 'Reference Date';
        }
        field(7; "Audit Text"; Text[250])
        {
            Caption = 'Audit Text';
        }
        field(8; "Currency Code"; Code[10])
        {
            CalcFormula = Lookup ("Cost Basis"."Currency Code" WHERE(Code = FIELD("Cost Basis Code")));
            Caption = 'Currency Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(9; "Reference Cost Basis Code"; Code[20])
        {
            Caption = 'Reference Cost Basis Code';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Cost Basis Code", "Item No.", "Variant Code", "Cost Date")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'Manually entered %1 by %2';

    procedure GetCostValue(CostBasisCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; MarketDate: Date): Decimal
    begin
        // P8000245B - add parameter for VariantCode
        Reset;
        SetRange("Cost Basis Code", CostBasisCode); // P8000539A
        SetRange("Item No.", ItemNo);
        SetRange("Variant Code", VariantCode); // P8000245B
        SetRange("Cost Date", MarketDate);
        if not Find('-') then
            Clear(Rec);
        exit("Cost Value");
    end;

    procedure SetCostValue(CostBasisCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; MarketDate: Date; MarketPrice: Decimal)
    var
        CostBasis: Record "Cost Basis";
    begin
        // P8000245B - add parameter for VariantCode
        CostBasis.Get(CostBasisCode); // P8000539A
        Reset;
        SetRange("Cost Basis Code", CostBasisCode); // P8000539A
        SetRange("Item No.", ItemNo);
        SetRange("Variant Code", VariantCode); // P8000245B
        SetRange("Cost Date", MarketDate);
        if Find('-') then begin
            "Cost Value" := MarketPrice; // P8000539A
            if CostBasis."Calc. Codeunit ID" <> 0 then                    // P8000539A
                "Audit Text" := StrSubstNo(Text001, CurrentDateTime, UserId); // P8000539A
            if (MarketPrice = 0) then
                Delete
            else
                Modify;
        end else
            if (MarketPrice = 0) then
                Clear(Rec)
            else begin
                Clear(Rec);
                Validate("Cost Basis Code", CostBasisCode); // P8000539A
                Validate("Item No.", ItemNo);
                Validate("Variant Code", VariantCode); // P8000245B
                Validate("Cost Date", MarketDate);
                "Cost Value" := MarketPrice;
                if CostBasis."Calc. Codeunit ID" <> 0 then                    // P8000539A
                    "Audit Text" := StrSubstNo(Text001, CurrentDateTime, UserId); // P8000539A
                Insert;
            end;
    end;

    procedure GetCostValueAsOf(CostBasisCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; MarketDate: Date): Decimal
    begin
        // P8000245B - add parameter for VariantCode
        Reset;
        SetRange("Cost Basis Code", CostBasisCode); // P8000539A
        SetRange("Item No.", ItemNo);
        SetRange("Variant Code", VariantCode); // P8000245B
        SetRange("Cost Date", 0D, MarketDate);
        if not Find('+') then
            Clear(Rec);
        exit("Cost Value");
    end;

    procedure GetCostValueBefore(CostBasisCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; BeforeMarketDate: Date): Decimal
    begin
        // P8000245B - add parameter for VariantCode
        exit(GetCostValueAsOf(CostBasisCode, ItemNo, VariantCode, BeforeMarketDate - 1)); // P8000245B, P8000539A
    end;

    procedure GetFirstPurchItemEntry(var ItemLedgEntry: Record "Item Ledger Entry"; PeriodFormula: Code[20]): Boolean
    begin
        // P8000539A
        ItemLedgEntry.Reset;
        ItemLedgEntry.SetCurrentKey(
          "Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");
        ItemLedgEntry.SetRange("Item No.", "Item No.");
        ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Purchase);
        ItemLedgEntry.SetRange("Variant Code", "Variant Code");
        ItemLedgEntry.SetRange("Drop Shipment", false);
        ItemLedgEntry.SetRange("Posting Date",
          CalcDate('-(' + PeriodFormula + ')', "Reference Date") + 1, "Reference Date");
        exit(ItemLedgEntry.FindSet);
    end;

    procedure GetItemEntryQty(var ItemLedgEntry: Record "Item Ledger Entry"): Decimal
    begin
        exit(ItemLedgEntry.GetCostingQty()); // P8000539A
    end;

    procedure GetItemEntryCost(var ItemLedgEntry: Record "Item Ledger Entry"): Decimal
    begin
        // P8000539A
        ItemLedgEntry.CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
        exit(ItemLedgEntry."Cost Amount (Expected)" + ItemLedgEntry."Cost Amount (Actual)");
    end;

    procedure AssignResults(CostValue: Decimal; AuditText: Text[250])
    begin
        // P8000539A
        "Cost Value" := CostValue;
        "Audit Text" := AuditText;
    end;
}

