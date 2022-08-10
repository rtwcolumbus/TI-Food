page 37002595 "Shipped Containers"
{
    // PRW18.00.02
    // P8004554, To-Increase, Jack Reynolds, 27 OCT 15
    //   Support for Delivery Trip History

    ApplicationArea = FOODBasic;
    Caption = 'Shipped Containers';
    CardPageID = "Shipped Container";
    Editable = false;
    PageType = List;
    SourceTable = "Shipped Container Header";
    UsageCategory = History; // P800-MegaApp

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ID; ID)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Container Type Code"; "Container Type Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("License Plate"; "License Plate")
                {
                    ApplicationArea = FOODBasic;
                }
                field(DocumentType; DocumentType)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Document Type';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Total Quantity (Base)"; "Total Quantity (Base)")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Container")
            {
                Caption = '&Container';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    RunObject = Page "Shipped Container";
                    RunPageLink = ID = FIELD(ID);
                    ShortCutKey = 'Shift+F7';
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Container Comment List";
                    RunPageLink = Status = CONST(Closed),
                                  "Container ID" = FIELD(ID);
                }
            }
        }
    }
}

