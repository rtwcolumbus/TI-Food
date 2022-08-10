page 37002679 "Item Lot by Location"
{
    // PRW16.00.05
    // P8000944, Columbus IT, Jack Reynolds, 31 MAY 11
    //   Support for enahnced terminal market order entry

    Caption = 'Item Lot by Location';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPlus;
    SourceTable = "Lot No. Information";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = "Country/Region of Origin Code";
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Country/Region of Origin Code"; "Country/Region of Origin Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("GetData(1)"; GetData(1))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = GetColHeading(1);
                    DecimalPlaces = 0 : 5;
                    HideValue = NoOfCols < 1;
                    ShowCaption = false;
                }
                field("GetData(2)"; GetData(2))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = GetColHeading(2);
                    DecimalPlaces = 0 : 5;
                    HideValue = NoOfCols < 2;
                    ShowCaption = false;
                }
                field("GetData(3)"; GetData(3))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = GetColHeading(3);
                    DecimalPlaces = 0 : 5;
                    HideValue = NoOfCols < 3;
                    ShowCaption = false;
                }
                field("GetData(4)"; GetData(4))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = GetColHeading(4);
                    DecimalPlaces = 0 : 5;
                    HideValue = NoOfCols < 4;
                    ShowCaption = false;
                }
                field("GetData(5)"; GetData(5))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = GetColHeading(5);
                    DecimalPlaces = 0 : 5;
                    HideValue = NoOfCols < 5;
                    ShowCaption = false;
                }
                field("<Control37002012>"; GetData(6))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = GetColHeading(6);
                    Caption = '<Control37002012>';
                    DecimalPlaces = 0 : 5;
                    HideValue = NoOfCols < 6;
                }
                field("GetData(7)"; GetData(7))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = GetColHeading(7);
                    DecimalPlaces = 0 : 5;
                    HideValue = NoOfCols < 7;
                    ShowCaption = false;
                }
                field("GetData(8)"; GetData(8))
                {
                    ApplicationArea = FOODBasic;
                    CaptionClass = GetColHeading(8);
                    DecimalPlaces = 0 : 5;
                    HideValue = NoOfCols < 8;
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Previous)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Previous Location';
                Enabled = 0 < ColOffset;
                Image = PreviousRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ColOffset -= 1;
                end;
            }
            action(Next)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Next Location';
                Enabled = ColOffset < MaxOffset;
                Image = NextRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ColOffset += 1;
                end;
            }
        }
    }

    trigger OnInit()
    begin
        NoOfCols := 8;
    end;

    var
        TempLocation: Record "Item Ledger Entry" temporary;
        ItemLotAvail: Record "Item Lot Availability" temporary;
        [InDataSet]
        ColOffset: Integer;
        [InDataSet]
        MaxOffset: Integer;
        [InDataSet]
        NoOfCols: Integer;

    procedure LoadData(ItemNo: Code[20]; EndDate: Date)
    var
        Location: Record Location;
        InvSetup: Record "Inventory Setup";
        Item: Record Item;
        ItemLotAvail2: Record "Item Lot Availability" temporary;
        TermMarketFns: Codeunit "Terminal Market Selling";
    begin
        InvSetup.Get;
        Location.SetRange("Use As In-Transit", false);
        Location.SetFilter(Code, '<>%1', InvSetup."Offsite Cont. Location Code");
        if Location.FindSet then
            repeat
                TempLocation."Entry No." += 1;
                TempLocation."Location Code" := Location.Code;
                TempLocation.Insert;
            until Location.Next = 0;

        ColOffset := 0;
        MaxOffset := TempLocation.Count - NoOfCols;
        if MaxOffset < 0 then
            MaxOffset := 0;

        Item.Get(ItemNo);
        TempLocation.Find('-');
        repeat
            TermMarketFns.CalculateAvailability(Item, TempLocation."Location Code", EndDate, 0, ItemLotAvail2);
            ItemLotAvail2.SetFilter("Quantity Available", '>0');
            if ItemLotAvail2.Find('-') then
                repeat
                    ItemLotAvail := ItemLotAvail2;
                    ItemLotAvail."Country/Region of Origin Code" := TempLocation."Location Code";
                    ItemLotAvail.Insert;
                    if not Get(ItemLotAvail2."Item No.", ItemLotAvail2."Variant Code", ItemLotAvail2."Lot No.") then begin
                        "Item No." := ItemLotAvail2."Item No.";
                        "Variant Code" := ItemLotAvail2."Variant Code";
                        "Lot No." := ItemLotAvail2."Lot No.";
                        Description := Item.Description;
                        "Country/Region of Origin Code" := ItemLotAvail2."Country/Region of Origin Code";
                        Insert;
                    end;
                until ItemLotAvail2.Next = 0;
        until TempLocation.Next = 0;

        if Find('-') then;
    end;

    procedure GetColHeading(Index: Integer): Code[10]
    begin
        if TempLocation.Get(ColOffset + Index) then
            exit(TempLocation."Location Code")
        else
            exit('');
    end;

    procedure GetData(Index: Integer): Decimal
    begin
        TempLocation.Get(ColOffset + Index);
        if ItemLotAvail.Get("Item No.", "Variant Code", "Lot No.", TempLocation."Location Code") then
            exit(ItemLotAvail."Quantity Available");
    end;
}

