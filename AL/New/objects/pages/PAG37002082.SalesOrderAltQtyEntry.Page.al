page 37002082 "Sales Order Alt. Qty. Entry" // Version: FOODNA
{
    // PR3.10.P *TEMP*
    //   Integrate 3.60 Sales Pricing and Line Discounts
    // 
    // PR3.10.P
    //   Sales Pricing - Add Price at Shipment
    // 
    // PR4.00.02
    // P8000291A, VerticalSoft, Jack Reynolds, 10 FEB 06
    //   Remove Ship-to UPS Zone
    // 
    // PRW16.00.02
    // P8000664, VerticalSoft, Jimmy Abidi, 18 NOV 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.03
    // P8000828, VerticalSoft, Don Bresee, 10 JUN 10
    //   Change caption for Lines part
    // 
    // PRW16.00.06,PRNA6.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Upgrade for NAV 2013
    // 
    // P8001133, Columbus IT, Jack Reynolds, 27 MAR 13
    //   Updated for dimension sets
    // 
    // PRW17.00.01
    // P8001163, Columbus IT, Jack Reynolds, 30 MAY 13
    //   Fix problem with editing sub-pages
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Sales Order Alt. Qty. Entry';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Document;
    SourceTable = "Sales Header";
    SourceTableView = WHERE("Document Type" = FILTER(Order));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = false;
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                group("Sell-to")
                {
                    Caption = 'Sell-to';
                    field("Sell-to Customer No."; "Sell-to Customer No.")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Customer No.';

                        trigger OnValidate()
                        begin
                            SelltoCustomerNoOnAfterValidat;
                        end;
                    }
                    field("Sell-to Contact No."; "Sell-to Contact No.")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Contact No.';
                    }
                    field("Sell-to Customer Name"; "Sell-to Customer Name")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Customer Name';
                    }
                    field("Sell-to Address"; "Sell-to Address")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address';
                    }
                    field("Sell-to Address 2"; "Sell-to Address 2")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address 2';
                    }
                    field("Sell-to City"; "Sell-to City")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'City';
                    }
                    group(Control37002061)
                    {
                        ShowCaption = false;
                        Visible = IsSellToCountyVisible;
                        field("Sell-to County"; "Sell-to County")
                        {
                            ApplicationArea = FOODBasic;
                        }
                    }
                    field("Sell-to Post Code"; "Sell-to Post Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Post Code';
                    }
                    field("Sell-to Country/Region Code"; "Sell-to Country/Region Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Country/Region Code';
                        Importance = Additional;
                    }
                    field("Sell-to Contact"; "Sell-to Contact")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Contact';
                    }
                }
                field("No. of Archived Versions"; "No. of Archived Versions")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    var
                        SalesHeaderArchive: Record "Sales Header Archive";
                    begin
                        CurrPage.SaveRecord;
                        Commit;
                        SalesHeaderArchive.SetRange("Document Type", "Document Type"::Order);
                        SalesHeaderArchive.SetRange("No.", "No.");
                        SalesHeaderArchive.SetRange("Doc. No. Occurrence", "Doc. No. Occurrence");
                        if SalesHeaderArchive.Get("Document Type"::Order, "No.", "Doc. No. Occurrence", "No. of Archived Versions") then;
                        PAGE.RunModal(PAGE::"Sales List Archive", SalesHeaderArchive);
                        CurrPage.Update(false);
                    end;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Order Date"; "Order Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Requested Delivery Date"; "Requested Delivery Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Promised Delivery Date"; "Promised Delivery Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Campaign No."; "Campaign No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Responsibility Center"; "Responsibility Center")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(SalesLines; "Sales Order Alt. Qty. Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
                SubPageLink = "Table No." = CONST(37),
                              "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("No.");
                SubPageView = SORTING("Table No.", "Document Type", "Document No.", "Source Line No.", "Line No.");
            }
            group(Invoicing)
            {
                Caption = 'Invoicing';
                Editable = false;
                group("Bill-to")
                {
                    Caption = 'Bill-to';
                    field("Bill-to Customer No."; "Bill-to Customer No.")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Customer No.';

                        trigger OnValidate()
                        begin
                            BilltoCustomerNoOnAfterValidat;
                        end;
                    }
                    field("Bill-to Contact No."; "Bill-to Contact No.")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Contact No.';
                    }
                    field("Bill-to Name"; "Bill-to Name")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Name';
                    }
                    field("Bill-to Address"; "Bill-to Address")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address';
                    }
                    field("Bill-to Address 2"; "Bill-to Address 2")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address 2';
                    }
                    field("Bill-to City"; "Bill-to City")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'City';
                    }
                    group(Control37002065)
                    {
                        ShowCaption = false;
                        Visible = IsBillToCountyVisible;
                        field("Bill-to County"; "Bill-to County")
                        {
                            ApplicationArea = FOODBasic;
                        }
                    }
                    field("Bill-to Post Code"; "Bill-to Post Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Post Code';
                    }
                    field("Bill-to Country/Region Code"; "Bill-to Country/Region Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Country/Region Code';
                        Importance = Additional;
                    }
                    field("Bill-to Contact"; "Bill-to Contact")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Contact';
                    }
                }
                field("Price at Shipment"; "Price at Shipment")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Payment Terms Code"; "Payment Terms Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Payment Discount %"; "Payment Discount %")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pmt. Discount Date"; "Pmt. Discount Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Payment Method Code"; "Payment Method Code")
                {
                    ApplicationArea = FOODBasic;
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
                Editable = false;
                group("Ship-to")
                {
                    Caption = 'Ship-to';
                    field("Ship-to Code"; "Ship-to Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = ' Code';
                    }
                    field("Ship-to Name"; "Ship-to Name")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Name';
                    }
                    field("Ship-to Address"; "Ship-to Address")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address';
                    }
                    field("Ship-to Address 2"; "Ship-to Address 2")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Address 2';
                    }
                    field("Ship-to City"; "Ship-to City")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'City';
                    }
                    group(Control37002068)
                    {
                        ShowCaption = false;
                        Visible = IsShipToCountyVisible;
                        field("Ship-to County"; "Ship-to County")
                        {
                            ApplicationArea = FOODBasic;
                        }
                    }
                    field("Ship-to Post Code"; "Ship-to Post Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Post Code';
                    }
                    field("Ship-to Country/Region Code"; "Ship-to Country/Region Code")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Country/Region Code';
                        Importance = Additional;
                    }
                    field("Ship-to Contact"; "Ship-to Contact")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Contact';
                    }
                }
                field("Delivery Route No."; "Delivery Route No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Delivery Stop No."; "Delivery Stop No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Outbound Whse. Handling Time"; "Outbound Whse. Handling Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shipment Method Code"; "Shipment Method Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Package Tracking No."; "Package Tracking No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shipping Time"; "Shipping Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Late Order Shipping"; "Late Order Shipping")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shipping Advice"; "Shipping Advice")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group("Foreign Trade")
            {
                Caption = 'Foreign Trade';
                Editable = false;
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnAssistEdit()
                    begin
                        ChangeExchangeRate.SetParameter("Currency Code", "Currency Factor", "Posting Date");
                        if ChangeExchangeRate.RunModal = ACTION::OK then begin
                            Validate("Currency Factor", ChangeExchangeRate.GetParameter);
                            CurrPage.Update;
                        end;
                        Clear(ChangeExchangeRate);
                    end;
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
        area(navigation)
        {
            group("O&rder")
            {
                Caption = 'O&rder';
                action(Statistics)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Statistics';
                    Image = Statistics;
                    ShortCutKey = 'F7';

                    trigger OnAction()
                    begin
                        PAGE.RunModal(PAGE::"Sales Order Statistics", Rec);
                    end;
                }
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    RunObject = Page "Customer Card";
                    RunPageLink = "No." = FIELD("Sell-to Customer No.");
                    ShortCutKey = 'Shift+F7';
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Sales Comment Sheet";
                    RunPageLink = "Document Type" = FIELD("Document Type"),
                                  "No." = FIELD("No.");
                }
                action("S&hipments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'S&hipments';
                    Image = Shipment;
                    RunObject = Page "Posted Sales Shipments";
                    RunPageLink = "Order No." = FIELD("No.");
                    RunPageView = SORTING("Order No.");
                }
                action(Invoices)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Invoices';
                    Image = Invoice;
                    RunObject = Page "Posted Sales Invoices";
                    RunPageLink = "Order No." = FIELD("No.");
                    RunPageView = SORTING("Order No.");
                }
                action(Dimensions)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        ShowDocDim;          // P8001133
                        CurrPage.SaveRecord; // P8001133
                    end;
                }
                separator(Separator1102603154)
                {
                }
                action("Pick &Ticket")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pick &Ticket';
                    Ellipsis = true;
                    Image = InventoryPick;

                    trigger OnAction()
                    var
                        SalesOrder: Record "Sales Header";
                    begin
                        SalesOrder.SetRange("No.", "No.");
                        REPORT.RunModal(REPORT::"Pick Ticket - Food Series", true, false, SalesOrder);
                    end;
                }
            }
        }
        area(Promoted)
        {
            actionref(Statistics_Promoted; Statistics)
            {
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        IsSellToCountyVisible := FormatAddress.UseCounty("Sell-to Country/Region Code"); // P80066030
        IsShipToCountyVisible := FormatAddress.UseCounty("Ship-to Country/Region Code"); // P80066030
        IsBillToCountyVisible := FormatAddress.UseCounty("Bill-to Country/Region Code"); // P80066030
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Responsibility Center" := UserMgt.GetSalesFilter();
    end;

    trigger OnOpenPage()
    begin
        if UserMgt.GetSalesFilter() <> '' then begin
            FilterGroup(2);
            SetRange("Responsibility Center", UserMgt.GetSalesFilter());
            FilterGroup(0);
        end;

        SetRange("Date Filter", 0D, WorkDate - 1);
    end;

    var
        Text000: Label 'Unable to execute this function while in view only mode.';
        CopySalesDoc: Report "Copy Sales Document";
        MoveNegSalesLines: Report "Move Negative Sales Lines";
        ReportPrint: Codeunit "Test Report-Print";
        DocPrint: Codeunit "Document-Print";
        ArchiveManagement: Codeunit ArchiveManagement;
        FormatAddress: Codeunit "Format Address";
        SalesSetup: Record "Sales & Receivables Setup";
        ChangeExchangeRate: Page "Change Exchange Rate";
        UserMgt: Codeunit "User Setup Management";
        IsSellToCountyVisible: Boolean;
        IsShipToCountyVisible: Boolean;
        IsBillToCountyVisible: Boolean;

    local procedure SelltoCustomerNoOnAfterValidat()
    begin
        CurrPage.Update;
    end;

    local procedure BilltoCustomerNoOnAfterValidat()
    begin
        CurrPage.Update;
    end;
}

