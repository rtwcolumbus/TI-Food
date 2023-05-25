page 37002596 "Shipped Container"
{
    // PRW18.00.02
    // P8004554, To-Increase, Jack Reynolds, 27 OCT 15
    //   Support for Delivery Trip History

    Caption = 'Shipped Container';
    Editable = false;
    PageType = Document;
    SourceTable = "Shipped Container Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(ID; ID)
                {
                    ApplicationArea = FOODBasic;
                }
                field("License Plate"; "License Plate")
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
                field("Container Serial No."; "Container Serial No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Shipping)
            {
                field(DocumentType; DocumentType)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Document Type';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(Lines; "Shipped Container Subpage")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
                SubPageLink = "Container ID" = FIELD(ID);
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

