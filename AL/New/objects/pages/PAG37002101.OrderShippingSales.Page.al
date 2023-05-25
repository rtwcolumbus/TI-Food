page 37002101 "Order Shipping-Sales" // Version: FOODNA
{
    // P8000282A, VerticalSoft, Jack Reynolds, 23 MAR 06
    //   Sales order form for posting shipments from order shipping
    // 
    // PR4.00.04
    // P8000371A, VerticalSoft, Jack Reynolds, 06 SEP 06
    //   Modify to be called from Route Planning
    // 
    // PRW15.00.01
    // P8000576A, VerticalSoft, Jack Reynolds, 14 FEB 08
    //   Order menu button is always visible
    // 
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Support for delivery trip management
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
    // PRW16.00.06,PRNA6.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
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
    // P8004518, To-Increase, Jack Reynolds, 01 DEC 15
    //   Cleanup old delivery trips
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
    //
    // PRW121.2
    // P800162917, To Increase, Jack Reynolds, 23 Jan 23
    //   Obsolete Post and Print and add Post and Send

    Caption = 'Sales Order';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Document;
    SaveValues = true;
    SourceTable = "Sales Header";

    layout
    {
        area(content)
        {
            part(Lines; "Order Shipping-Sales Subform")
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
                    group(Control37002058)
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
                field(DateShipped; ShipDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Date Shipped';
                    Editable = DateShippedEditable;
                    NotBlank = true;
                }
                field("Requested Delivery Date"; "Requested Delivery Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Promised Delivery Date"; "Promised Delivery Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
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
                    group(Control37002061)
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
                field("Payment Method Code"; "Payment Method Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                    Lookup = false;
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
                    field("Ship-to Code"; "Ship-to Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Code';
                        Editable = false;
                        Lookup = false;
                    }
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
                field("Outbound Whse. Handling Time"; "Outbound Whse. Handling Time")
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
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Shipping Agent CodeEditable";
                }
                field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = ShippingAgentServiceCodeEditab;
                }
                field("Shipping Time"; "Shipping Time")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Shipping TimeEditable";
                }
                field("Late Order Shipping"; "Late Order Shipping")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Expected Shipment Date';
                    Editable = false;
                    NotBlank = true;
                }
                field(DateShipped2; ShipDate)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Date Shipped';
                    Editable = DateShipped2Editable;
                    NotBlank = true;
                }
                field("Shipping Advice"; "Shipping Advice")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Shipping AdviceEditable";
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
            part(Control1906127307; "Sales Line FactBox")
            {
                ApplicationArea = FOODBasic;
                Provider = Lines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Line No." = FIELD("Line No.");
                Visible = true;
            }
            part(Control1901796907; "Item Warehouse FactBox")
            {
                ApplicationArea = FOODBasic;
                Provider = Lines;
                SubPageLink = "No." = FIELD("No.");
                Visible = true;
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
                Visible = bnOrderVisible;
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
                separator(Separator1102603129)
                {
                }
                action("Contai&ners")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Contai&ners';
                    Image = Inventory;
                    ShortCutKey = 'Ctrl+N';

                    trigger OnAction()
                    begin
                        ContainerSpecification;
                    end;
                }
            }
        }
        area(processing)
        {
            group(bnPost)
            {
                Caption = 'P&osting';
                Visible = bnPostVisible;
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
                // P800162917
                action(PostAndSend)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Post and Send';
                    Ellipsis = true;
                    Image = PostMail;
                    ToolTip = 'Finalize and prepare to send the document according to the customer''s sending profile, such as attached to an email. The Send document to window opens where you can confirm or select a sending profile.';

                    trigger OnAction()
                    begin
                        Post(true);
                        CurrPage.Close;
                    end;
                }
                action("Post and &Print")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Post and &Print';
                    Ellipsis = true;
                    Image = PostPrint;
                    // P800162917
                    ObsoleteReason = 'Removed - Replaced by Post and Send';
                    ObsoleteState = Pending;
                    ObsoleteTag = 'FOOD-22';
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
                // P800162917
                actionref(PostAndSend_Promoted; PostAndSend)
                {
                }
                actionref(PostAndPrint_Promoted; "Post and &Print")
                {
                    // P800162917
                    ObsoleteReason = 'Removed - Replaced by Post and Send';
                    ObsoleteState = Pending;
                    ObsoleteTag = 'FOOD-22';
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
        "Shipping AdviceEditable" := true;
        DateShipped2Editable := true;
        DateShippedEditable := true;
        "Shipping TimeEditable" := true;
        ShippingAgentServiceCodeEditab := true;
        "Shipping Agent CodeEditable" := true;
        bnOrderVisible := true;
        bnLineVisible := true;
        bnPostVisible := true;
    end;

    trigger OnOpenPage()
    var
        Editable: Boolean;
    begin
        BottomMargin := FrmHeight - (LinesYPos + LinesHeight);
        HdrPos := HeaderYPos;
        HdrHeight := HeaderHeight;

        ShipDate := WorkDate;

        SetHeaderDisplay(ShowHeader);

        // P8000549A
        if PostingDisabled then begin
            Location.Get(PostingLocation);
            Editable := DelTripNo <> ''; // P8004518
            bnOrderXPos := bnLineXPos;
            bnLineXPos := bnPostXPos;
            bnPostVisible := false;
            bnLineVisible := Editable;
            bnOrderVisible := Editable;
            "Shipping Agent CodeEditable" := false;
            ShippingAgentServiceCodeEditab := false;
            "Shipping TimeEditable" := false;
            DateShippedEditable := false;
            DateShipped2Editable := false;
            "Shipping AdviceEditable" := false;
            CurrPage.Lines.PAGE.SetFormEditable(Editable);
        end;
        // P8000549A

        BindSubscription(OrderShippingReceiving); // P80070336
    end;

    var
        Location: Record Location;
        OrderShippingReceiving: Codeunit "Order Shipping-Receiving";
        FormatAddress: Codeunit "Format Address";
        PostingLocation: Code[10];
        ShipDate: Date;
        Text000: Label 'Do you want to post the shipment?';
        ShowHeader: Boolean;
        BottomMargin: Integer;
        HdrPos: Integer;
        HdrHeight: Integer;
        DelTripNo: Code[20];
        PostingDisabled: Boolean;
        [InDataSet]
        bnPostVisible: Boolean;
        [InDataSet]
        bnLineVisible: Boolean;
        [InDataSet]
        bnOrderVisible: Boolean;
        [InDataSet]
        "Shipping Agent CodeEditable": Boolean;
        [InDataSet]
        ShippingAgentServiceCodeEditab: Boolean;
        [InDataSet]
        "Shipping TimeEditable": Boolean;
        [InDataSet]
        DateShippedEditable: Boolean;
        [InDataSet]
        DateShipped2Editable: Boolean;
        [InDataSet]
        "Shipping AdviceEditable": Boolean;
        bnOrderXPos: Integer;
        bnLineXPos: Integer;
        bnPostXPos: Integer;
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

    procedure SetHeader(SalesHeader: Record "Sales Header")
    begin
        // P8000371A
        PostingLocation := SalesHeader."Location Code";
        Get(SalesHeader."Document Type", SalesHeader."No.");
        FilterGroup(2);
        SetRecFilter;
        FilterGroup(0);
    end;

    procedure SetDelTripOrder(DeliveryTripOrder: Record "Delivery Trip Order")
    begin
        // P8000549A
        PostingLocation := DeliveryTripOrder."Location Code";
        Get(DeliveryTripOrder."Source Subtype", DeliveryTripOrder."Source No.");
        FilterGroup(2);
        SetRecFilter;
        FilterGroup(0);

        DelTripNo := DeliveryTripOrder."Delivery Trip No.";
        PostingDisabled := true;
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

    local procedure Post(PrintSend: Boolean)
    var
        Process800WarehouseMgmt: Codeunit "Process 800 Warehouse Mgmt.";
    begin
        // P80071657
        Rec.Find;
        if not Confirm(Text000, false) then
            exit;

        Process800WarehouseMgmt.PostSale(Rec, ShipDate, PostingLocation, PrintSend);
    end;
}
