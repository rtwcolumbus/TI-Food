page 37002024 "Lot Lookup"
{
    // PR2.00
    //   Item Tracking
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 06 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Lot Lookup';
    DataCaptionFields = "Item No.", "Variant Code";
    PageType = List;
    SourceTable = "Lot No. Information";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                Editable = false;
                ShowCaption = false;
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Inventory; Inventory)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'On Hand';
                    DecimalPlaces = 0 : 5;
                }
                field("Supplier Lot No."; "Supplier Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    var
        ItemLedger: Record "Item Ledger Entry";
        OnHand: Decimal;
}

