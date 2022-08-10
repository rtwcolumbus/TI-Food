page 37002110 "Order Receiving-Sales" // Version: FOODNA
{
    // PR4.00.02
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Sales return order form for posting receipts from order receiving
    // 
    // PRW15.00.01
    // P8000576A, VerticalSoft, Jack Reynolds, 14 FEB 08
    //   Order menu button is always visible
    // 
    // PRW16.00.02
    // P8000777, VerticalSoft, Don Bresee, 03 MAR 10
    //   Remove HeaderVisible use in properties
    //   Moves Lines part to first in content area
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
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
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

    Caption = 'Sales Return Order';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Document;
    SaveValues = true;
    SourceTable = "Sales Header";

    layout
    {
        area(content)
        {
            part(Lines; "Order Receiving-Sales Subform")
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
                group("Sell-to")
                {
                    Caption = 'Sell-to';
                    field("Sell-to Customer No."; "Sell-to Customer No.")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Customer No.';
                        Editable = false;
                        Lookup = false;
                    }
                    field("Sell-to Customer Name"; "Sell-to Customer Name")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Customer Name';
                        Editable = false;
                        Lookup = false;
                    }
                    field("Sell-to Address"; "Sell-to Address")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address';
                        Editable = false;
                    }
                    field("Sell-to Address 2"; "Sell-to Address 2")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address 2';
                        Editable = false;
                    }
                    field("Sell-to City"; "Sell-to City")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'City';
                        Editable = false;
                        Lookup = false;
                    }
                    group(Control37002045)
                    {
                        ShowCaption = false;
                        Visible = IsSellToCountyVisible;
                        field("Sell-to County"; "Sell-to County")
                        {
                            ApplicationArea = FOODBasic;
                            Editable = false;
                        }
                    }
                    field("Sell-to Post Code"; "Sell-to Post Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Post Code';
                        Editable = false;
                        Lookup = false;
                    }
                    field("Sell-to Country/Region Code"; "Sell-to Country/Region Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Country/Region Code';
                        Editable = false;
                        Importance = Additional;
                        Lookup = false;
                    }
                    field("Sell-to Contact"; "Sell-to Contact")
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
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field("Campaign No."; "Campaign No.")
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
                group("Bill-to")
                {
                    Caption = 'Bill-to';
                    field("Bill-to Customer No."; "Bill-to Customer No.")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Customer No.';
                        Editable = false;
                        Lookup = false;
                    }
                    field("Bill-to Name"; "Bill-to Name")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Name';
                        Editable = false;
                        Lookup = false;
                    }
                    field("Bill-to Address"; "Bill-to Address")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address';
                        Editable = false;
                    }
                    field("Bill-to Address 2"; "Bill-to Address 2")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address 2';
                        Editable = false;
                    }
                    field("Bill-to City"; "Bill-to City")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'City';
                        Editable = false;
                        Lookup = false;
                    }
                    group(Control37002049)
                    {
                        ShowCaption = false;
                        Visible = IsBillToCountyVisible;
                        field("Bill-to County"; "Bill-to County")
                        {
                            ApplicationArea = FOODBasic;
                            Editable = false;
                        }
                    }
                    field("Bill-to Post Code"; "Bill-to Post Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Post Code';
                        Editable = false;
                        Lookup = false;
                    }
                    field("Bill-to Country/Region Code"; "Bill-to Country/Region Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Country/Region Code';
                        Editable = false;
                        Importance = Additional;
                        Lookup = false;
                    }
                    field("Bill-to Contact"; "Bill-to Contact")
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
                field("Applies-to Doc. Type"; "Applies-to Doc. Type")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Applies-to Doc. No."; "Applies-to Doc. No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
                }
                field("Applies-to ID"; "Applies-to ID")
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
                    group(Control37002053)
                    {
                        ShowCaption = false;
                        Visible = IsShipToCountyVisible;
                        field("Ship-to County"; "Ship-to County")
                        {
                            ApplicationArea = FOODBasic;
                            Editable = false;
                        }
                    }
                    field("Ship-to Country/Region Code"; "Ship-to Country/Region Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Country/Region Code';
                        Editable = false;
                        Importance = Additional;
                        Lookup = false;
                    }
                    field("Ship-to Post Code"; "Ship-to Post Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Post Code';
                        Editable = false;
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
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Expected Receipt Date';
                    Editable = false;
                    NotBlank = true;
                }
                field(ReceiptDate2; ReceiptDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Date Received';
                    NotBlank = true;
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
            part(SalesLineFactBox; "Sales Line FactBox")
            {
                ApplicationArea = FOODBasic;
                Provider = Lines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Line No." = FIELD("Line No.");
                Visible = false;
            }
            part(ApprovalFactBox; "Approval FactBox")
            {
                ApplicationArea = FOODBasic;
                Provider = Lines;
                SubPageLink = "Table ID" = CONST(36),
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
                Caption = '&Ret. Order';
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Sales Comment Sheet";
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
                    SalesHeader: Record "Sales Header";
                begin
                    // P8001047
                    SalesHeader.Copy(Rec);
                    SalesHeader.SetRange("Location Filter", PostingLocation);
                    SalesHeader.PrintLabels;
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
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
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
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';

                    trigger OnAction()
                    begin
                        Post(true); // P80071657
                        CurrPage.Close;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        CurrPage.Lines.PAGE.SetLocation(PostingLocation);
        IsSellToCountyVisible := FormatAddress.UseCounty("Sell-to Country/Region Code"); // P80066030
        IsShipToCountyVisible := FormatAddress.UseCounty("Ship-to Country/Region Code"); // P80066030
        IsBillToCountyVisible := FormatAddress.UseCounty("Bill-to Country/Region Code"); // P80066030
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
        IsSellToCountyVisible: Boolean;
        IsShipToCountyVisible: Boolean;
        IsBillToCountyVisible: Boolean;

    procedure SetSalesHeader(WhseReq: Record "Warehouse Request")
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

        Process800WarehouseMgmt.PostSale(Rec, ReceiptDate, PostingLocation, Print);
    end;
}

