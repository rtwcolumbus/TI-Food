page 37002723 "Term. Mkt. Lot Lookup"
{
    // PRW16.00.05
    // P8000944, Columbus IT, Jack Reynolds, 31 MAY 11
    //   Support for enahnced terminal market order entry

    Caption = 'Terminal Market Lot Lookup';
    Editable = false;
    PageType = List;
    SourceTable = "Item Lot Availability";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Item No.", "Variant Code", "Country Code");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                    Visible = false;
                }
                field("Country Code"; "Country Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity Available"; "Quantity Available")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Costing Unit of Measure"; "Costing Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
                field(SourceReference; SourceReference)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Source';
                }
                field(Farm; Farm)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Brand; Brand)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Receiving Reason Code"; "Receiving Reason Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    procedure LoadData(var ItemLotAvail: Record "Item Lot Availability" temporary)
    begin
        if ItemLotAvail.FindSet then
            repeat
                Rec := ItemLotAvail;
                Rec.Insert;
            until ItemLotAvail.Next = 0;
        if FindFirst then;
    end;
}

