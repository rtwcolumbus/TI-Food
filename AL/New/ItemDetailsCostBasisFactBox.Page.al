page 37002206 "ItemDetailsCostBasis Factbox"
{
    // PRW116.00.05
    // P800103616, To-Increase, Gangabhushan, 04 FEB 21
    //  Enhance inventory costing with Book Cost  

    Caption = 'Item Details CostBasis';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Item Cost Basis";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(CostBasisFactbox)
            {
                ShowCaption = false;
                field(CostBasisCode; "Cost Basis Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Cost Basis Code';
                }
                field(LastCostValue; "Cost Value")
                {
                    ApplicationArea = FOODBasic;
                }
                field(LastCostvalueDate; "Cost Date")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Last Cost Value Date';
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        ItemNo: Code[20];
        VariantCode: Code[10];
    begin
        FilterGroup(4);
        ItemNo := GetRangeMax("Item No.");
        VariantCode := GetRangeMax("Variant Code");
        FilterGroup(0);
        InsertRecords(ItemNo, VariantCode);
        exit(Find(Which));
    end;

    local procedure InsertRecords(ItemNo: Code[20]; VariantCode: Code[10])
    var
        ItemCostBasis: Record "Item Cost Basis";
    begin
        if ItemVariant.Get(ItemNo, VariantCode) then
            exit;
        ItemVariant."Item No." := ItemNo;
        ItemVariant.Code := VariantCode;
        ItemVariant.Insert();

        ItemCostBasis.SetRange("Item No.", ItemNo);
        ItemCostBasis.SetRange("Variant Code", VariantCode);
        ItemCostBasis.SetCurrentKey("Cost Basis Code", "Cost Date");
        if ItemCostBasis.FindSet() then
            repeat
                ItemCostBasis.SetRange("Cost Basis Code", ItemCostBasis."Cost Basis Code");
                ItemCostBasis.SetRange("Cost Date", 0D, WorkDate());
                if ItemCostBasis.FindLast() then
                    if not Rec.Get(ItemCostBasis."Cost Basis Code", ItemCostBasis."Item No.", ItemCostBasis."Variant Code", ItemCostBasis."Cost Date") then begin
                        Rec := ItemCostBasis;
                        Rec.Insert();
                    end;
                ItemCostBasis.SetRange("Cost Basis Code");
            until ItemCostBasis.Next() = 0;
    end;

    var
        ItemVariant: Record "Item Variant" temporary;
}