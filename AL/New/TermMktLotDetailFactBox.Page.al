page 37002721 "Term. Mkt. Lot Detail FactBox"
{
    // PRW16.00.05
    // P8000944, Columbus IT, Jack Reynolds, 31 MAY 11
    //   Support for enahnced terminal market order entry

    Caption = 'Term. Mkt. Lot Detail FactBox';
    PageType = CardPart;
    SourceTable = "Item Lot Availability";

    layout
    {
        area(content)
        {
            field("Unit Cost"; "Unit Cost")
            {
                ApplicationArea = FOODBasic;
                Importance = Promoted;
            }
            field("Costing Unit of Measure"; "Costing Unit of Measure")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Unit of Measure';
                Importance = Promoted;
            }
            field(Source; SourceReference)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Source';

                trigger OnDrillDown()
                var
                    PurchHeader: Record "Purchase Header";
                    SalesHeader: Record "Sales Header";
                    TransHeader: Record "Transfer Header";
                    ProdOrder: Record "Production Order";
                    RepackOrder: Record "Repack Order";
                begin
                    case "Source Type" of
                        "Source Type"::Purchase:
                            begin
                                PurchHeader.FilterGroup(2);
                                PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
                                PurchHeader.SetRange("No.", "Source Document No.");
                                PurchHeader.FilterGroup(0);
                                PAGE.RunModal(PAGE::"Purchase Order", PurchHeader);
                            end;
                        "Source Type"::"Sales Return":
                            begin
                                SalesHeader.FilterGroup(2);
                                SalesHeader.SetRange("Document Type", PurchHeader."Document Type"::"Return Order");
                                SalesHeader.SetRange("No.", "Source Document No.");
                                SalesHeader.FilterGroup(0);
                                PAGE.RunModal(PAGE::"Sales Return Order", SalesHeader);
                            end;
                        "Source Type"::Transfer:
                            begin
                                TransHeader.FilterGroup(2);
                                TransHeader.SetRange("No.", "Source Document No.");
                                TransHeader.FilterGroup(0);
                                PAGE.RunModal(PAGE::"Transfer Order", TransHeader);
                            end;
                        "Source Type"::Production:
                            begin
                                ProdOrder.FilterGroup(2);
                                ProdOrder.SetRange(Status, "Source Status");
                                ProdOrder.SetRange("No.", "Source Document No.");
                                ProdOrder.FilterGroup(0);
                                case "Source Status" of
                                    "Source Status"::Planned:
                                        PAGE.RunModal(PAGE::"Planned Production Order", ProdOrder);
                                    "Source Status"::"Firm Planned":
                                        PAGE.RunModal(PAGE::"Firm Planned Prod. Order", ProdOrder);
                                    "Source Status"::Released:
                                        PAGE.RunModal(PAGE::"Released Production Order", ProdOrder);
                                end;
                            end;
                        "Source Type"::Repack:
                            begin
                                RepackOrder.FilterGroup(2);
                                RepackOrder.SetRange("No.", "Source Document No.");
                                RepackOrder.FilterGroup(0);
                                PAGE.RunModal(PAGE::"Repack Order", RepackOrder);
                            end;
                    end;
                end;
            }
            field("Receiving Reason Code"; "Receiving Reason Code")
            {
                ApplicationArea = FOODBasic;
            }
            field(Farm; Farm)
            {
                ApplicationArea = FOODBasic;
            }
            field(Brand; Brand)
            {
                ApplicationArea = FOODBasic;
            }
            group("Last Sale")
            {
                Caption = 'Last Sale';
                field("Last Sale Date"; "Last Sale Date")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Date';
                }
                field("Last Sale Price"; "Last Sale Price")
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Price';
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

