page 37002177 "Item Cost Conversion Factors"
{
    // PR5.00
    // P8000539A, VerticalSoft, Don Bresee, 17 NOV 07
    //   Added for cost conversions between items (used in cost based sales price calculation)
    // 
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 12 AUG 09
    //   Transformed from Form
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property.
    // 
    // PRW110.0
    // P8007749, To-Increase, Jack Reynolds, 07 DEC 16
    //   Item Category/Product Group

    Caption = 'Item Cost Conversion Factors';
    DataCaptionExpression = GetCaption();
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            field("Cost Calc. Item No."; CostCalcItemNo)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Cost Calc. Item No.';
                TableRelation = Item;

                trigger OnLookup(var Text: Text): Boolean
                var
                    CostCalcItem: Record Item;
                    ItemList: Page "Item List";
                begin
                    CostCalcItem.Reset;
                    ItemList.SetTableView(CostCalcItem);
                    if (Text <> '') then begin
                        CostCalcItem."No." := Text;
                        if CostCalcItem.Find('=><') then
                            ItemList.SetRecord(CostCalcItem);
                    end;
                    ItemList.LookupMode(true);
                    if (ItemList.RunModal <> ACTION::LookupOK) then
                        exit(false);
                    ItemList.GetRecord(CostCalcItem);
                    Text := CostCalcItem."No.";
                    exit(true);
                end;

                trigger OnValidate()
                begin
                    SetItemFilter;
                    CurrPage.Update(false);
                end;
            }
            field("Costing Qty. UOM"; CostCalcUOMCode)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Costing Qty. UOM';
                Editable = false;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    LookupItemUOM(CostCalcItemNo, CostCalcUOMCode);
                end;

                trigger OnValidate()
                begin
                    SetItemFilter;
                    CurrPage.Update(false);
                end;
            }
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Pricing Qty. UOM"; PriceUOMCode)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pricing Qty. UOM';
                    Editable = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupItemUOM("No.", PriceUOMCode);
                    end;
                }
                field("Item Category Code"; "Item Category Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Visible = false;
                }
                field("Costing Qty."; CostingQty)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Costing Qty.';
                    DecimalPlaces = 0 : 5;
                    MinValue = 0;

                    trigger OnValidate()
                    begin
                        if (CostCalcItemNo = '') then
                            Error(Text000);
                        if (CostingQty = 0) then
                            CostingQty := 1;
                        SaveQuantities;
                    end;
                }
                field("Equivalent Pricing Qty."; EquivPricingQty)
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Equivalent Pricing Qty.';
                    DecimalPlaces = 0 : 5;
                    MinValue = 0;

                    trigger OnValidate()
                    begin
                        if (CostCalcItemNo = '') then
                            Error(Text000);
                        if (EquivPricingQty = 0) then
                            EquivPricingQty := 1;
                        SaveQuantities;
                    end;
                }
                field("Conversion Description"; ConversionDescription)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Conversion Description';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        LoadQuantities;
    end;

    trigger OnAfterGetRecord()
    begin
        LoadQuantities;
    end;

    trigger OnOpenPage()
    begin
        if (ExtCostCalcItemNo <> '') then
            CostCalcItemNo := ExtCostCalcItemNo;
        SetItemFilter;
    end;

    var
        CostingQty: Decimal;
        EquivPricingQty: Decimal;
        CostCalcItemNo: Code[20];
        ExtCostCalcItemNo: Code[20];
        CostCalcUOMCode: Code[10];
        ConversionDescription: Text[250];
        PriceUOMCode: Code[10];
        Text000: Label 'You must specify a Cost Calc. Item No.';
        Text001: Label '%1 %2 of %3 = %4 %5 of %6';

    local procedure GetCaption(): Text[250]
    var
        CostCalcItem: Record Item;
    begin
        if (CostCalcItemNo <> '') then
            if CostCalcItem.Get(CostCalcItemNo) then begin
                if (CostCalcItem.Description = '') then
                    exit(CostCalcItem."No.");
                exit(StrSubstNo('%1 %2', CostCalcItem."No.", CostCalcItem.Description));
            end;
    end;

    local procedure SetItemFilter()
    var
        CostCalcItem: Record Item;
        CostCalcUOM: Record "Item Unit of Measure";
    begin
        FilterGroup(2);
        Clear(CostCalcUOMCode);
        if (CostCalcItemNo = '') then
            SetRange("No.")
        else begin
            SetFilter("No.", '<>%1', CostCalcItemNo);
            if CostCalcItem.Get(CostCalcItemNo) then
                if CostCalcItem.CostInAlternateUnits() then
                    CostCalcUOMCode := CostCalcItem."Alternate Unit of Measure"
                else
                    CostCalcUOMCode := CostCalcItem."Base Unit of Measure";
        end;
        FilterGroup(0);
    end;

    local procedure LookupItemUOM(ItemNo: Code[20]; UOMCode: Code[10])
    var
        ItemUOM: Record "Item Unit of Measure";
        ItemUOMList: Page "Item Units of Measure";
    begin
        ItemUOM.Reset;
        ItemUOM.SetRange("Item No.", ItemNo);
        ItemUOMList.SetTableView(ItemUOM);
        if (CostCalcUOMCode <> '') then begin
            ItemUOM."Item No." := ItemNo;
            ItemUOM.Code := UOMCode;
            if ItemUOM.Find('=><') then
                ItemUOMList.SetRecord(ItemUOM);
        end;
        ItemUOMList.LookupMode(true);
        ItemUOMList.Editable(false);
        ItemUOMList.RunModal;
    end;

    local procedure LoadQuantities()
    var
        ItemCostCalcFactor: Record "Item Cost Conversion Factor";
    begin
        if CostInAlternateUnits() then
            PriceUOMCode := "Alternate Unit of Measure"
        else
            PriceUOMCode := "Base Unit of Measure";

        if (CostCalcItemNo = '') then begin
            CostingQty := 0;
            EquivPricingQty := 0;
        end else
            if ItemCostCalcFactor.Get(CostCalcItemNo, "No.") then begin
                CostingQty := ItemCostCalcFactor."Costing Qty.";
                EquivPricingQty := ItemCostCalcFactor."Equivalent Pricing Qty.";
            end else begin
                CostingQty := 1;
                EquivPricingQty := 1;
            end;

        UpdateConvDesc;
    end;

    local procedure SaveQuantities()
    var
        ItemCostCalcFactor: Record "Item Cost Conversion Factor";
    begin
        if (CostCalcItemNo <> '') then
            if ItemCostCalcFactor.Get(CostCalcItemNo, "No.") then
                if (CostingQty = 1) and (EquivPricingQty = 1) then
                    ItemCostCalcFactor.Delete(true)
                else begin
                    ItemCostCalcFactor."Costing Qty." := CostingQty;
                    ItemCostCalcFactor."Equivalent Pricing Qty." := EquivPricingQty;
                    ItemCostCalcFactor.Modify(true);
                end
            else
                if (CostingQty <> 1) or (EquivPricingQty <> 1) then begin
                    ItemCostCalcFactor.Init;
                    ItemCostCalcFactor."Cost Calc. Item No." := CostCalcItemNo;
                    ItemCostCalcFactor."Pricing Item No." := "No.";
                    ItemCostCalcFactor."Costing Qty." := CostingQty;
                    ItemCostCalcFactor."Equivalent Pricing Qty." := EquivPricingQty;
                    ItemCostCalcFactor.Insert(true);
                end;

        UpdateConvDesc;
    end;

    local procedure UpdateConvDesc()
    var
        ItemCostCalcFactor: Record "Item Cost Conversion Factor";
    begin
        if not ItemCostCalcFactor.Get(CostCalcItemNo, "No.") then
            ConversionDescription := ''
        else begin
            ConversionDescription :=
              StrSubstNo(Text001,
                ItemCostCalcFactor."Costing Qty.", CostCalcUOMCode, CostCalcItemNo,
                ItemCostCalcFactor."Equivalent Pricing Qty.", PriceUOMCode, "No.");
        end;
    end;

    procedure SetCostCalcItemNo(NewCostCalcItemNo: Code[20])
    begin
        ExtCostCalcItemNo := NewCostCalcItemNo;
    end;
}

