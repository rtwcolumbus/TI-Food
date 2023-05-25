page 37002690 "Posted Comm. Manifest Lines"
{
    // PRW16.00.04
    // P8000891, VerticalSoft, Don Bresee, 04 JAN 11
    //   Add Commodity Receiving logic

    Caption = 'Posted Comm. Manifest Lines';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Posted Comm. Manifest Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Vendor Name"; "Vendor Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Purch. Rcpt. No."; "Purch. Rcpt. No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PurchRcptHeader: Record "Purch. Rcpt. Header";
                    begin
                        PurchRcptHeader."No." := "Purch. Rcpt. No.";
                        PAGE.RunModal(PAGE::"Posted Purchase Receipt", PurchRcptHeader);
                    end;
                }
                field("Manifest Quantity"; "Manifest Quantity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("GetReceivedPercentage()"; GetReceivedPercentage())
                {
                    ApplicationArea = FOODBasic;
                    BlankZero = true;
                    Caption = 'Received Percentage';
                    DecimalPlaces = 1 : 1;
                    Editable = false;
                }
                field("Received Date"; "Received Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Received Lot No."; "Received Lot No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    begin
                        ShowReceviedLotEntries;
                    end;
                }
                field("Rejection Action"; "Rejection Action")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }
}

