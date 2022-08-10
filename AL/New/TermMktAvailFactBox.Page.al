page 37002722 "Term. Mkt. Avail. FactBox"
{
    // PRW16.00.05
    // P8000944, Columbus IT, Jack Reynolds, 31 MAY 11
    //   Support for enahnced terminal market order entry

    Caption = 'Term. Mkt. Avail. FactBox';
    PageType = CardPart;
    SourceTable = "Item Lot Availability";

    layout
    {
        area(content)
        {
            field("Qty. on Hand"; "Qty. on Hand")
            {
                ApplicationArea = FOODBasic;
                BlankZero = true;
                Caption = 'On Hand';
            }
            group(Inbound)
            {
                Caption = 'Inbound';
                field("Qty. on Purch. Order"; "Qty. on Purch. Order")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Purchase Orders';
                }
                field("Qty. on Sales Ret. Order"; "Qty. on Sales Ret. Order")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Sales Return Orders';
                }
                field("Qty. on Trans. Order (In)"; "Qty. on Trans. Order (In)")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Transfer Orders';
                }
                field("Qty. on Prod. Order (In)"; "Qty. on Prod. Order (In)")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Production Orders';
                }
                field("Qty. on Repack Order (In)"; "Qty. on Repack Order (In)")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Repack Orders';
                }
                field("Qty. on Line Repack (In)"; "Qty. on Line Repack (In)")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Sales Line Repack';
                }
            }
            group(Outbound)
            {
                Caption = 'Outbound';
                field("Qty. on Sales Order"; "Qty. on Sales Order")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Sales Orders';
                }
                field("Qty. on Purch. Ret. Order"; "Qty. on Purch. Ret. Order")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Purchase Return Orders';
                }
                field("Qty. on Trans. Order (Out)"; "Qty. on Trans. Order (Out)")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Transfer Orders';
                }
                field("Qty. on Prod. Order (Out)"; "Qty. on Prod. Order (Out)")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Production Orders';
                }
                field("Qty. on Repack Order (Out)"; "Qty. on Repack Order (Out)")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Repack Orders';
                }
                field("Qty. on Line Repack (Out)"; "Qty. on Line Repack (Out)")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Sales Line Repack';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        Found: Boolean;
    begin
        FilterGroup(4);
        Found := SharedItemLotAvail.Get(GetRangeMax("Item No."), GetRangeMax("Variant Code"), GetRangeMax("Lot No."),
          GetRangeMax("Country/Region of Origin Code"));
        Rec := SharedItemLotAvail;
        FilterGroup(0);
        exit(Found);
    end;

    var
        SharedItemLotAvail: Record "Item Lot Availability" temporary;

    procedure SetSharedTable(var ItemLotAvail: Record "Item Lot Availability" temporary)
    begin
        SharedItemLotAvail.Copy(ItemLotAvail, true);
    end;
}

