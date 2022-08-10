page 37002900 "Item Alt. Quantity FactBox"
{
    // PRW16.00.20
    // P8000663, VerticalSoft, Jack Reynolds, 26 JAN 09
    //   Factbox to expose alternate quantity information about an item
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Item Details - Alternate Quantity';
    PageType = CardPart;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            field("No."; "No.")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Item No.';

                trigger OnDrillDown()
                begin
                    ShowDetails;
                end;
            }
            field("Alternate Unit of Measure"; "Alternate Unit of Measure")
            {
                ApplicationArea = FOODBasic;
            }
            field("Costing Unit"; "Costing Unit")
            {
                ApplicationArea = FOODBasic;
            }
            field("Catch Alternate Qtys."; "Catch Alternate Qtys.")
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
    }

    procedure ShowDetails()
    begin
        PAGE.Run(PAGE::"Item Card", Rec);
    end;
}

