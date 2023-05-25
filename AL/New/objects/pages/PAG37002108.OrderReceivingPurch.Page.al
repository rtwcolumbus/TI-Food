page 37002108 "Order Receiving-Purch." // Version: FOODNA
{
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Purchase order form for posting receipts from order receiving
    // 
    // PRW15.00.01
    // P8000576A, VerticalSoft, Jack Reynolds, 14 FEB 08
    //   Order menu button is always visible
    // 
    // PRW16.00.01
    // P8000688, VerticalSoft, Jack Reynolds, 19 MAY 09
    //   Fix problem with "Another user has modified ..."
    // 
    // PRW16.00.02
    // P8000777, VerticalSoft, Don Bresee, 03 MAR 10
    //   Remove HeaderVisible use in properties
    //   Moves Lines part to first in content area
    // 
    // PRW16.00.05
    // P8000928, Columbus IT, Jack Reynolds, 06 APR 11
    //   Support for extra charges on transfer orders
    // 
    // PRW16.00.06,PRNA6.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001047, Columbus IT, Jack Reynolds, 30 MAR 12
    //   Receiving Labels
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001135, Columbus IT, Nagam Srinivas, 19 FEB 13
    //   Restoring the SaveValues Property.
    // 
    // PRNA7.10
    // P8001252, Columbus IT, Jack Reynolds, 05 JAN 14
    //   Fix State field
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00.02
    // P80070336, To Increase, Jack Reynolds, 12 FEB 19
    //   Fix issue with Alternate Quantity to Handle
    // 
    // P80071657, To Increase, Jack Reynolds, 15 MAR 19
    //   Fix posting date issue; refactoring
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Purchase Order';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Document;
    SaveValues = true;
    SourceTable = "Purchase Header";

    layout
    {
        area(content)
        {
            part(Lines; "Order Receiving-Purch. Subform")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("No.");
            }
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                group("Buy-from")
                {
                    Caption = 'Buy-from';
                    field("Buy-from Vendor No."; "Buy-from Vendor No.")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Vendor No.';
                        Editable = false;
                        Lookup = false;
                    }
                    field("Buy-from Vendor Name"; "Buy-from Vendor Name")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Vendor Name';
                        Editable = false;
                        Lookup = false;
                    }
                    field("Buy-from Address"; "Buy-from Address")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address';
                        Editable = false;
                    }
                    field("Buy-from Address 2"; "Buy-from Address 2")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address 2';
                        Editable = false;
                    }
                    field("Buy-from City"; "Buy-from City")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'City';
                        Editable = false;
                        Lookup = false;
                    }
                    group(Control37002056)
                    {
                        ShowCaption = false;
                        Visible = IsBuyFromCountyVisible;
                        field("Buy-from County"; "Buy-from County")
                        {
                            ApplicationArea = FOODBasic;
                            Editable = false;
                        }
                    }
                    field("Buy-from Post Code"; "Buy-from Post Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Post Code';
                        Editable = false;
                        Lookup = false;
                    }
                    field("Buy-from Country/Region Code"; "Buy-from Country/Region Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Country/Region Code';
                        Editable = false;
                        Importance = Additional;
                        Lookup = false;
                    }
                    field("Buy-from Contact"; "Buy-from Contact")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Contact';
                        Editable = false;
                        Lookup = false;
                    }
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Order Date"; "Order Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(ReceiptDate; ReceiptDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Date Received';
                    NotBlank = true;
                }
                field("Vendor Order No."; "Vendor Order No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Vendor Shipment No."; "Vendor Shipment No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Vendor Invoice No."; "Vendor Invoice No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Order Address Code"; "Order Address Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field("Purchaser Code"; "Purchaser Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field("Responsibility Center"; "Responsibility Center")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
            }
            group(Invoicing)
            {
                Caption = 'Invoicing';
                group("Pay-to")
                {
                    Caption = 'Pay-to';
                    field("Pay-to Vendor No."; "Pay-to Vendor No.")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Vendor No.';
                        Editable = false;
                        Lookup = false;
                    }
                    field("Pay-to Name"; "Pay-to Name")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Name';
                        Editable = false;
                        Lookup = false;
                    }
                    field("Pay-to Address"; "Pay-to Address")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address';
                        Editable = false;
                    }
                    field("Pay-to Address 2"; "Pay-to Address 2")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address 2';
                        Editable = false;
                    }
                    field("Pay-to City"; "Pay-to City")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'City';
                        Editable = false;
                        Lookup = false;
                    }
                    group(Control37002060)
                    {
                        ShowCaption = false;
                        Visible = IsPayToCountyVisible;
                        field("Pay-to County"; "Pay-to County")
                        {
                            ApplicationArea = FOODBasic;
                            Editable = false;
                        }
                    }
                    field("Pay-to Post Code"; "Pay-to Post Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Post Code';
                        Editable = false;
                        Lookup = false;
                    }
                    field("Pay-to Country/Region Code"; "Pay-to Country/Region Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Country/Region Code';
                        Editable = false;
                        Importance = Additional;
                        Lookup = false;
                    }
                    field("Pay-to Contact"; "Pay-to Contact")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Contact';
                        Editable = false;
                        Lookup = false;
                    }
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field("Payment Terms Code"; "Payment Terms Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Payment Discount %"; "Payment Discount %")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Pmt. Discount Date"; "Pmt. Discount Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("On Hold"; "On Hold")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Tax Liable"; "Tax Liable")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Tax Area Code"; "Tax Area Code")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Shipping)
            {
                Caption = 'Shipping';
                group("Ship-to")
                {
                    Caption = 'Ship-to';
                    field("Ship-to Name"; "Ship-to Name")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Name';
                        Editable = false;
                    }
                    field("Ship-to Address"; "Ship-to Address")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address';
                        Editable = false;
                    }
                    field("Ship-to Address 2"; "Ship-to Address 2")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address 2';
                        Editable = false;
                    }
                    field("Ship-to City"; "Ship-to City")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'City';
                        Editable = false;
                        Lookup = false;
                    }
                    group(Control37002064)
                    {
                        ShowCaption = false;
                        Visible = IsShipToCountyVisible;
                        field("Ship-to County"; "Ship-to County")
                        {
                            ApplicationArea = FOODBasic;
                            Editable = false;
                        }
                    }
                    field("Ship-to Post Code"; "Ship-to Post Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Post Code';
                        Editable = false;
                        Lookup = false;
                    }
                    field("Ship-to Country/Region Code"; "Ship-to Country/Region Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Country/Region Code';
                        Editable = false;
                        Importance = Additional;
                        Lookup = false;
                    }
                    field("Ship-to Contact"; "Ship-to Contact")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Contact';
                        Editable = false;
                    }
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field("Inbound Whse. Handling Time"; "Inbound Whse. Handling Time")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Shipment Method Code"; "Shipment Method Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field("Lead Time Calculation"; "Lead Time Calculation")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Requested Receipt Date"; "Requested Receipt Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Promised Receipt Date"; "Promised Receipt Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Expected Receipt Date"; "Expected Receipt Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field(ReceiptDate2; ReceiptDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Date Received';
                    NotBlank = true;
                }
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
            }
            group(ForeignTrade)
            {
                Caption = 'Foreign Trade';
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
            }
        }
        area(factboxes)
        {
            part(Control1903326807; "Item Replenishment FactBox")
            {
                ApplicationArea = FOODBasic;
                Provider = Lines;
                SubPageLink = "No." = FIELD("No.");
                Visible = true;
            }
            part(ApprovalFactBox; "Approval FactBox")
            {
                ApplicationArea = FOODBasic;
                Provider = Lines;
                SubPageLink = "Table ID" = CONST(38),
                              "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("No."),
                              Status = CONST(Open);
                Visible = false;
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(bnOrder)
            {
                Caption = 'O&rder';
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Purch. Comment Sheet";
                    RunPageLink = "Document Type" = FIELD("Document Type"),
                                  "No." = FIELD("No.");
                }
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim;
                    end;
                }
                action("E&xtra Charges")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'E&xtra Charges';
                    Image = Costs;

                    trigger OnAction()
                    begin
                        ShowExtraCharges;
                    end;
                }
            }
        }
        area(processing)
        {
            action("Print Labels")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Print Labels';
                Ellipsis = true;
                Image = Print;

                trigger OnAction()
                var
                    PurchHeader: Record "Purchase Header";
                begin
                    // P8001047
                    PurchHeader.Copy(Rec);
                    PurchHeader.SetRange("Location Filter", PostingLocation);
                    PurchHeader.PrintLabels;
                end;
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                action("P&ost")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = Post;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    begin
                        Post(false); // P80071657
                        CurrPage.Close;
                    end;
                }
                action("Post and &Print")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Post and &Print';
                    Ellipsis = true;
                    Image = PostPrint;
                    ShortCutKey = 'Shift+F9';

                    trigger OnAction()
                    begin
                        Post(true); // P80071657
                        CurrPage.Close;
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Post)
            {
                Caption = 'Post';
                ShowAs = SplitButton;

                actionref(Post_Promoted; "P&ost")
                {
                }
                actionref(PostAndPrint_Promoted; "Post and &Print")
                {
                }
            }
            actionref("E&xtra Charges_Promoted"; "E&xtra Charges")
            {
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        CurrPage.Lines.PAGE.SetLocation(PostingLocation);
        IsBuyFromCountyVisible := FormatAddress.UseCounty("Buy-from Country/Region Code"); // P80066030
        IsShipToCountyVisible := FormatAddress.UseCounty("Ship-to Country/Region Code"); // P80066030
        IsPayToCountyVisible := FormatAddress.UseCounty("Pay-to Country/Region Code"); // P80066030
    end;

    trigger OnInit()
    begin
        HeaderVisible := true;
    end;

    trigger OnOpenPage()
    begin
        BottomMargin := FrmHeight - (LinesYPos + LinesHeight);
        HdrPos := HeaderYPos;
        HdrHeight := HeaderHeight;

        ReceiptDate := WorkDate;

        SetHeaderDisplay(ShowHeader);

        BindSubscription(OrderShippingReceiving); // P80070336
    end;

    var
        OrderShippingReceiving: Codeunit "Order Shipping-Receiving";
        FormatAddress: Codeunit "Format Address";
        PostingLocation: Code[10];
        ReceiptDate: Date;
        ShowHeader: Boolean;
        BottomMargin: Integer;
        HdrPos: Integer;
        HdrHeight: Integer;
        Text000: Label 'Do you want to post the receipt?';
        LinesYPos: Integer;
        HeaderYPos: Integer;
        LinesHeight: Integer;
        HeaderHeight: Integer;
        FrmHeight: Integer;
        [InDataSet]
        HeaderVisible: Boolean;
        IsBuyFromCountyVisible: Boolean;
        IsShipToCountyVisible: Boolean;
        IsPayToCountyVisible: Boolean;

    procedure SetPurchHeader(WhseReq: Record "Warehouse Request")
    begin
        PostingLocation := WhseReq."Location Code";
        Get(WhseReq."Source Subtype", WhseReq."Source No.");
        FilterGroup(2);
        SetRecFilter;
        FilterGroup(0);
    end;

    procedure SetHeaderDisplay(Display: Boolean)
    var
        LineBottom: Integer;
    begin
        //CurrForm.bnOrder.VISIBLE(Display); // P8000576A

        LineBottom := FrmHeight - BottomMargin;
        HeaderVisible := Display;
        if Display then
            LinesYPos := HdrPos + HdrHeight + 220
        else
            ;
        LinesHeight := LineBottom - LinesYPos;
    end;

    local procedure Post(Print: Boolean)
    var
        Process800WarehouseMgmt: Codeunit "Process 800 Warehouse Mgmt.";
    begin
        // P80071657
        Rec.Find;
        if not Confirm(Text000, false) then
            exit;

        Process800WarehouseMgmt.PostPurchase(Rec, ReceiptDate, PostingLocation, Print);
    end;
}

