page 37002076 "Pickup Load Subform"
{
    // PR3.70.06
    // P8000080A, Myers Nissi, Steve Post, 30 AUG 04
    //   For Pickup Load Planning
    // 
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Order lookup filtered by location
    // 
    // PRW16.00.03
    // P8000828, VerticalSoft, Don Bresee, 08 JUN 10
    //   Add UPDATE when the Sequence No. is changed
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Pickup Load Subform';
    PageType = ListPart;
    SourceTable = "Pickup Load Line";
    SourceTableView = SORTING("Sequence No.");

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Purchase Order No."; "Purchase Order No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupOrder(Text)); // P8000549A
                    end;
                }
                field(VendorName; VendorName)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Vendor Name';
                }
                field("Pickup Location Code"; "Pickup Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(PickupLocationName; PickupLocationName)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pickup Location Name';
                }
                field("Sequence No."; "Sequence No.")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.Update; // P8000828
                    end;
                }
                field("Purchase Receipt No."; "Purchase Receipt No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                action("&Order")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Order';

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #37002075. Unsupported part was commented. Please check it.
                        /*CurrPage.LoadSub.PAGE.*/
                        ViewOrder;

                    end;
                }
                action("&Receipt")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Receipt';

                    trigger OnAction()
                    begin
                        //This functionality was copied from page #37002075. Unsupported part was commented. Please check it.
                        /*CurrPage.LoadSub.PAGE.*/
                        ViewReceipt;

                    end;
                }
            }
        }
    }

    procedure ViewOrder()
    var
        POHdr: Record "Purchase Header";
        POForm: Page "Purchase Order";
    begin
        POHdr.FilterGroup(9);
        POHdr.SetRange("Document Type", POHdr."Document Type"::Order);
        POHdr.SetRange("No.", "Purchase Order No.");
        POHdr.FilterGroup(0);
        if POHdr.Find('-') then begin
            POForm.SetTableView(POHdr);
            POForm.Run;
        end;
    end;

    procedure ViewReceipt()
    var
        PurchReceipt: Record "Purch. Rcpt. Header";
        ReceiptForm: Page "Posted Purchase Receipt";
    begin
        PurchReceipt.FilterGroup(9);
        PurchReceipt.SetRange("No.", "Purchase Receipt No.");
        PurchReceipt.FilterGroup(0);
        if PurchReceipt.Find('-') then begin
            ReceiptForm.SetTableView(PurchReceipt);
            ReceiptForm.Run;
        end;
    end;
}

