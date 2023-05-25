page 37002188 "Order Guide Margin FactBox"
{
    // PRW114.00
    // P80072449, To-increase, Gangabhushan, 23 MAY 19
    //   Dev. Margin Information per item on the Sales Order Guide in factbox

    Caption = 'Margin Details';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Order Guide FactBox Data";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Presentation Order")
                      ORDER(Ascending)
                      WHERE(Type = CONST(Margin),
                            "Item Category" = FILTER(<> ''));

    layout
    {
        area(content)
        {
            group(Control1100472001)
            {
                ShowCaption = false;
                field("Total Margin"; TotMargin)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Total Margin';
                }
            }
            repeater(Control1100472005)
            {
                IndentationColumn = Indentation;
                IndentationControls = "Item Category";
                ShowCaption = false;
                field("Item Category"; "Item Category")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Expected Margin (LCY)"; "Expected Margin (LCY)")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    var
        TotMargin: Decimal;

    procedure InsertSalesMargin(pItemNo: Code[20]; pItemCatCode: Code[20]; pQty: Decimal; pUnitPriceLCY: Decimal; pUnitCostLCY: Decimal; pExpMarginLCY: Decimal; pExpMarginPct: Decimal)
    var
        EntryNo: Integer;
        OrderGuidefactBoxData: Record "Order Guide FactBox Data" temporary;
        PrevQty: Decimal;
        PrevExpMarginLCY: Decimal;
        ItemCategory: Record "Item Category";
    begin
        // P80072449
        if pItemCatCode = '' then
            exit;
        OrderGuidefactBoxData.Copy(Rec, true);
        OrderGuidefactBoxData.Reset;
        OrderGuidefactBoxData.SetRange("Item No.", pItemNo);
        OrderGuidefactBoxData.SetRange(Type, Type::Margin);
        if not OrderGuidefactBoxData.FindFirst then begin
            if pUnitPriceLCY <> 0 then begin
                OrderGuidefactBoxData.Reset;
                if OrderGuidefactBoxData.FindLast then
                    EntryNo := OrderGuidefactBoxData."Enry No." + 1
                else
                    EntryNo := 1;
                OrderGuidefactBoxData.Init;
                OrderGuidefactBoxData."Enry No." := EntryNo;
                OrderGuidefactBoxData.Type := OrderGuidefactBoxData.Type::Margin;
                OrderGuidefactBoxData."Item No." := pItemNo;
                OrderGuidefactBoxData.Quantity := pQty;
                OrderGuidefactBoxData."Expected Margin Pct." := pExpMarginPct;
                OrderGuidefactBoxData."Expected Margin (LCY)" := pExpMarginLCY;
                OrderGuidefactBoxData."Unit Cost" := pUnitCostLCY;
                OrderGuidefactBoxData."Unit Price (LCY)" := pUnitPriceLCY;
                OrderGuidefactBoxData.Insert;
            end;
        end else begin
            PrevQty := OrderGuidefactBoxData.Quantity;
            PrevExpMarginLCY := OrderGuidefactBoxData."Expected Margin (LCY)";
            if (pQty = 0) or (pUnitPriceLCY = 0) then
                OrderGuidefactBoxData.Delete
            else begin
                OrderGuidefactBoxData.Quantity := pQty;
                OrderGuidefactBoxData."Unit Price (LCY)" := pUnitPriceLCY;
                OrderGuidefactBoxData."Expected Margin (LCY)" := pExpMarginLCY;
                OrderGuidefactBoxData.Modify;
            end;
        end;

        ItemCategory.Get(pItemCatCode);
        UpdateItemCategory(ItemCategory, PrevQty, pQty, PrevExpMarginLCY, pExpMarginLCY);
        while ItemCategory."Parent Category" <> '' do begin
            ItemCategory.Get(ItemCategory."Parent Category");
            UpdateItemCategory(ItemCategory, PrevQty, pQty, PrevExpMarginLCY, pExpMarginLCY);
        end;

        Clear(TotMargin);
        OrderGuidefactBoxData.Reset;
        OrderGuidefactBoxData.SetFilter("Item No.", '<>%1', '');
        OrderGuidefactBoxData.SetRange(Type, Type::Margin);
        if OrderGuidefactBoxData.FindSet then
            repeat
                TotMargin += OrderGuidefactBoxData."Expected Margin (LCY)";
            until OrderGuidefactBoxData.Next = 0;

        CurrPage.Update(false);
    end;

    local procedure UpdateItemCategory(pItemCategory: Record "Item Category"; pPrevQty: Decimal; pQty: Decimal; pPrevExpMarginLCY: Decimal; pExpMarginLCY: Decimal)
    var
        EntryNo: Integer;
        OrderGuidefactBoxData: Record "Order Guide FactBox Data" temporary;
    begin
        // P80072449
        OrderGuidefactBoxData.Copy(Rec, true);
        OrderGuidefactBoxData.Reset;
        OrderGuidefactBoxData.SetRange(Type, OrderGuidefactBoxData.Type::Margin);
        OrderGuidefactBoxData.SetRange("Item Category", pItemCategory.Code);
        if OrderGuidefactBoxData.FindFirst then begin
            OrderGuidefactBoxData.Quantity += pQty - pPrevQty;
            OrderGuidefactBoxData."Expected Margin (LCY)" += pExpMarginLCY - pPrevExpMarginLCY;
            if OrderGuidefactBoxData.Quantity = 0 then
                OrderGuidefactBoxData.Delete
            else
                OrderGuidefactBoxData.Modify;
        end else begin
            if pExpMarginLCY <> 0 then begin
                OrderGuidefactBoxData.Reset;
                if OrderGuidefactBoxData.FindLast then
                    EntryNo := OrderGuidefactBoxData."Enry No." + 1
                else
                    EntryNo := 1;
                OrderGuidefactBoxData.Init;
                OrderGuidefactBoxData."Enry No." := EntryNo;
                OrderGuidefactBoxData.Type := OrderGuidefactBoxData.Type::Margin;
                OrderGuidefactBoxData."Item Category" := pItemCategory.Code;
                OrderGuidefactBoxData.Quantity := pQty;
                OrderGuidefactBoxData."Expected Margin (LCY)" := pExpMarginLCY;
                OrderGuidefactBoxData."Presentation Order" := pItemCategory."Presentation Order";
                OrderGuidefactBoxData.Indentation := pItemCategory.Indentation;
                OrderGuidefactBoxData.Insert;
            end;
        end;
    end;

    procedure ClearMarginRecords(pItemNo: Code[20])
    var
        lRecItem: Record Item;
        ItemCategory: Record "Item Category";
        OrderGuidefactBoxData: Record "Order Guide FactBox Data" temporary;
    begin
        // P80072449
        if lRecItem.Get(pItemNo) then
            ItemCategory.Get(lRecItem."Item Category Code");
        if ItemCategory.Code = '' then
            exit;

        Reset;
        SetRange(Type, Type::Margin);
        SetFilter("Item No.", '<>%1', '');
        if FindFirst then
            Delete;

        Reset;
        SetRange(Type, Type::Margin);
        SetRange("Item Category", ItemCategory.Code);
        if FindFirst then
            Delete;
        while ItemCategory."Parent Category" <> '' do begin
            ItemCategory.Get(ItemCategory."Parent Category");
            Reset;
            SetRange(Type, Type::Margin);
            SetRange("Item Category", ItemCategory.Code);
            if FindFirst then
                Delete;
        end;

        Clear(TotMargin);
        OrderGuidefactBoxData.Reset;
        OrderGuidefactBoxData.SetFilter("Item No.", '<>%1', '');
        OrderGuidefactBoxData.SetRange(Type, Type::Margin);
        if OrderGuidefactBoxData.FindSet then
            repeat
                TotMargin += OrderGuidefactBoxData."Expected Margin (LCY)";
            until OrderGuidefactBoxData.Next = 0;
    end;
}

