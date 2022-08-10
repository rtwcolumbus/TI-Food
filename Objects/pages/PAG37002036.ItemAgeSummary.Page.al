page 37002036 "Item Age Summary"
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Displays summary of quantity available by aging category for specified item
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 15 APR 09
    //   Transformed
    //   Reworked to use SourceTableTemporary
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Item Age Summary';
    DataCaptionExpression = Item."No." + ' ' + Item.Description;
    PageType = ListPlus;
    SourceTable = "Lot Age Profile Category";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field(LotInfoFilters; LotInfoFilters)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lot Information Filters';
                Editable = false;
            }
            field(LotAgingFilters; LotAgingFilters)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lot Aging Filters';
                Editable = false;
            }
            field(LotSpecFilters; LotSpecFilters)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lot Specification Filters';
                Editable = false;
            }
            repeater(Control37002000)
            {
                Editable = false;
                ShowCaption = false;
                field("Category Code"; "Category Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = StrSubstNo('37002080,0,0,%1', Item."No.");
                }
            }
        }
    }

    actions
    {
    }

    var
        Item: Record Item;
        LotInfoFilters: Text[1024];
        LotAgingFilters: Text[1024];
        LotSpecFilters: Text[1024];

    procedure SetItem(ItemNo: Code[20])
    begin
        Item.Get(ItemNo);
    end;

    procedure SetFilterStrings(LotInfoText: Text[1024]; LotAgingText: Text[1024]; LotSpecText: Text[1024])
    begin
        LotInfoFilters := LotInfoText;
        LotAgingFilters := LotAgingText;
        LotSpecFilters := LotSpecText;
    end;

    procedure SetTempTable(var AgeSum: Record "Lot Age Profile Category" temporary)
    begin
        if AgeSum.Find('-') then
            repeat
                Rec := AgeSum; // P8000664
                Insert;        // P8000664
            until AgeSum.Next = 0;
    end;
}

