page 37002069 "Standing Sales Order" // Version: FOODNA
{
    // PR3.10
    //   Standing Sales Orders
    // 
    // PR3.70
    //   Contract Items Only
    // 
    // PR3.70.10
    // P8000210A, Myers Nissi, Jack Reynolds, 10 MAY 05
    //   Add menu item for lot availability
    // 
    // PR4.00.02
    // P8000291A, VerticalSoft, Jack Reynolds, 10 FEB 06
    //   Remove Ship-to UPS Zone
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
    // PRNA7.10
    // P8001252, Columbus IT, Jack Reynolds, 05 JAN 14
    //   Fix State field
    // 
    // PRW110.0,PRNA10.0
    // P8007748, To-Increase, Jack Reynolds, 22 DEC 16
    //   Page layout
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Standing Sales Order';
    PageType = Document;
    SourceTable = "Sales Header";
    SourceTableView = WHERE("Document Type" = FILTER(FOODStandingOrder));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = DocNoVisible;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("Sell-to Customer Name"; "Sell-to Customer Name")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Customer';

                    trigger OnValidate()
                    begin
                        // P8007748
                        if GetFilter("Sell-to Customer No.") = xRec."Sell-to Customer No." then
                            if "Sell-to Customer No." <> xRec."Sell-to Customer No." then
                                SetRange("Sell-to Customer No.");

                        CurrPage.Update;
                    end;
                }
                group("Sell-to")
                {
                    Caption = 'Sell-to';
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
                    group(Control37002019)
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

                        trigger OnValidate()
                        begin
                            IsSellToCountyVisible := FormatAddress.UseCounty("Sell-to Country/Region Code"); // P80066030
                        end;
                    }
                    field("Sell-to Contact No."; "Sell-to Contact No.")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Contact No.';

                        trigger OnValidate()
                        begin
                            // P8007748
                            if GetFilter("Sell-to Contact No.") = xRec."Sell-to Contact No." then
                                if "Sell-to Contact No." <> xRec."Sell-to Contact No." then
                                    SetRange("Sell-to Contact No.");
                        end;
                    }
                }
                field("Sell-to Contact"; "Sell-to Contact")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Contact';
                }
                field("Order Date"; "Order Date")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Starting Date';
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Ending Date';
                }
                field("Delivery Route Order"; "Delivery Route Order")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Order Frequency"; "Order Frequency")
                {
                    ApplicationArea = FOODBasic;
                    Editable = "Order FrequencyEditable";
                }
                field("Next Order Date"; "Next Order Date")
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
            part(SalesLines; "Standing Sales Order Subform")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Document No." = FIELD("No.");
            }
            group("Invoice Details")
            {
                Caption = 'Invoice Details';
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
                field("Contract Items Only"; "Contract Items Only")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.SalesLines.PAGE.UpdateForm(true);
                    end;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.SalesLines.PAGE.UpdateForm(true);
                    end;
                }
                field("Payment Terms Code"; "Payment Terms Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Payment Discount %"; "Payment Discount %")
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
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group("Shipping and Billing")
            {
                Caption = 'Shipping and Billing';
                Enabled = "Sell-to Customer No." <> '';
                group(Control37002038)
                {
                    ShowCaption = false;
                    group(Control37002045)
                    {
                        ShowCaption = false;
                        field(ShippingOptions; ShipToOptions)
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Ship-to';

                            trigger OnValidate()
                            var
                                ShipToAddress: Record "Ship-to Address";
                                ShipToAddressList: Page "Ship-to Address List";
                            begin
                                // P8007748
                                case ShipToOptions of
                                    ShipToOptions::"Default (Sell-to Address)":
                                        begin
                                            Validate("Ship-to Code", '');
                                            CopySellToAddressToShipToAddress;
                                        end;
                                    ShipToOptions::"Alternate Shipping Address":
                                        begin
                                            ShipToAddress.SetRange("Customer No.", "Sell-to Customer No.");
                                            ShipToAddressList.LookupMode := true;
                                            ShipToAddressList.SetTableView(ShipToAddress);

                                            if ShipToAddressList.RunModal = ACTION::LookupOK then begin
                                                ShipToAddressList.GetRecord(ShipToAddress);
                                                Validate("Ship-to Code", ShipToAddress.Code);
                                            end else
                                                ShipToOptions := ShipToOptions::"Custom Address";
                                        end;
                                    ShipToOptions::"Custom Address":
                                        Validate("Ship-to Code", '');
                                end;
                            end;
                        }
                        group(Control37002047)
                        {
                            ShowCaption = false;
                            Visible = NOT (ShipToOptions = ShipToOptions::"Default (Sell-to Address)");
                            field("Ship-to Code"; "Ship-to Code")
                            {
                                ApplicationArea = FOODBasic;
                                Caption = 'Code';
                                Editable = ShipToOptions = ShipToOptions::"Alternate Shipping Address";

                                trigger OnValidate()
                                begin
                                    // P8007748
                                    if (xRec."Ship-to Code" <> '') and ("Ship-to Code" = '') then
                                        Error(EmptyShipToCodeErr);
                                end;
                            }
                            field("Ship-to Name"; "Ship-to Name")
                            {
                                ApplicationArea = FOODBasic;
                                Caption = 'Name';
                                Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            }
                            field("Ship-to Address"; "Ship-to Address")
                            {
                                ApplicationArea = FOODBasic;
                                Caption = 'Address';
                                Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            }
                            field("Ship-to Address 2"; "Ship-to Address 2")
                            {
                                ApplicationArea = FOODBasic;
                                Caption = 'Address 2';
                                Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            }
                            field("Ship-to City"; "Ship-to City")
                            {
                                ApplicationArea = FOODBasic;
                                Caption = 'City';
                                Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            }
                            group(Control37002057)
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
                                Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            }
                            field("Ship-to Country/Region Code"; "Ship-to Country/Region Code")
                            {
                                ApplicationArea = FOODBasic;
                                Caption = 'Country/Region Code';
                                Importance = Additional;

                                trigger OnValidate()
                                begin
                                    IsShipToCountyVisible := FormatAddress.UseCounty("Ship-to Country/Region Code"); // P80066030
                                end;
                            }
                            field("Ship-to Contact"; "Ship-to Contact")
                            {
                                ApplicationArea = FOODBasic;
                                Caption = 'Contact';
                                Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            }
                        }
                    }
                    field("Shipment Method Code"; "Shipment Method Code")
                    {
                        ApplicationArea = FOODBasic;
                        Importance = Additional;
                    }
                }
                group(Control37002049)
                {
                    ShowCaption = false;
                    group(Control37002050)
                    {
                        ShowCaption = false;
                        field(BillingOptions; BillToOptions)
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Bill-to';

                            trigger OnValidate()
                            begin
                                // P8007748
                                if BillToOptions = BillToOptions::"Default (Customer)" then
                                    Validate("Bill-to Customer No.", "Sell-to Customer No.");
                            end;
                        }
                    }
                    group(Control37002052)
                    {
                        ShowCaption = false;
                        Visible = BillToOptions = BillToOptions::"Another Customer";
                        field("Bill-to Name"; "Bill-to Name")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = ' Name';

                            trigger OnValidate()
                            begin
                                // P8007748
                                if GetFilter("Bill-to Customer No.") = xRec."Bill-to Customer No." then
                                    if "Bill-to Customer No." <> xRec."Bill-to Customer No." then
                                        SetRange("Bill-to Customer No.");
                            end;
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
                        group(Control37002060)
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

                            trigger OnValidate()
                            begin
                                IsBillToCountyVisible := FormatAddress.UseCounty("Bill-to Country/Region Code"); // P80066030
                            end;
                        }
                        field("Bill-to Contact No."; "Bill-to Contact No.")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Contact No.';
                        }
                        field("Bill-to Contact"; "Bill-to Contact")
                        {
                            ApplicationArea = FOODBasic;
                            Caption = 'Contact';
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            part(Control1903720907; "Sales Hist. Sell-to FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Sell-to Customer No.");
                Visible = true;
            }
            part(CustomerStatisticsFactBox; "Customer Statistics FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Bill-to Customer No.");
                Visible = false;
            }
            part(CustomerDetailsFactBox; "Customer Details FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Sell-to Customer No.");
                Visible = false;
            }
            part(Control1906127307; "Sales Line FactBox")
            {
                ApplicationArea = FOODBasic;
                Provider = SalesLines;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("Document No."),
                              "Line No." = FIELD("Line No.");
                Visible = true;
            }
            part(ItemInvoicingFactBox; "Item Invoicing FactBox")
            {
                ApplicationArea = FOODBasic;
                Provider = SalesLines;
                SubPageLink = "No." = FIELD("No.");
                Visible = false;
            }
            part(ResourceDetailsFactBox; "Resource Details FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("No.");
                Visible = false;
            }
            part(ItemWarehouseFactBox; "Item Warehouse FactBox")
            {
                ApplicationArea = FOODBasic;
                Provider = SalesLines;
                SubPageLink = "No." = FIELD("No.");
                Visible = false;
            }
            part(SalesHistBilltoFactBox; "Sales Hist. Bill-to FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Bill-to Customer No.");
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
            group("O&rder")
            {
                Caption = 'O&rder';
                action(Statistics)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'F7';

                    trigger OnAction()
                    begin
                        SalesSetup.Get;
                        if SalesSetup."Calc. Inv. Discount" then begin
                            CurrPage.SalesLines.PAGE.CalcInvDisc;
                            Commit;
                        end;

                        if "Tax Area Code" = '' then
                            PAGE.RunModal(PAGE::"Sales Order Statistics", Rec)
                        else
                            PAGE.RunModal(PAGE::"Sales Order Stats.", Rec)
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
                    RunPageLink = "Document Type" = CONST(FOODStandingOrder),
                                  "No." = FIELD("No.");
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
                separator(Separator1102603100)
                {
                }
                action(Orders)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Orders';
                    Image = "Order";
                    RunObject = Page "Sales List";
                    RunPageLink = "Standing Order No." = FIELD("No.");
                    RunPageView = SORTING("Document Type", "Standing Order No.", "Posting Date")
                                  WHERE("Document Type" = CONST(Order));
                }
                action("Posted Invoices")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Posted Invoices';
                    Image = PostedTaxInvoice;
                    RunObject = Page "Posted Sales Invoices";
                    RunPageLink = "Standing Order No." = FIELD("No.");
                    RunPageView = SORTING("Standing Order No.", "Posting Date");
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                group("Set Qty. to Order")
                {
                    Caption = 'Set Qty. to Order';
                    action(Clear)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Clear';
                        Image = Delete;

                        trigger OnAction()
                        begin
                            StandingOrderMgmt.SetQtyToOrder(Rec, true);
                        end;
                    }
                    action(Reset)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Reset';
                        Image = ResetStatus;

                        trigger OnAction()
                        begin
                            StandingOrderMgmt.SetQtyToOrder(Rec, false);
                        end;
                    }
                }
                separator(Separator1102603107)
                {
                }
                action("Copy Document")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Copy Document';
                    Ellipsis = true;
                    Enabled = "No." <> '';
                    Image = CopyDocument;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        CopySalesDoc.SetSalesHeader(Rec);
                        CopySalesDoc.RunModal;
                        Clear(CopySalesDoc);
                    end;
                }
                action("Re&lease")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Codeunit "Release Sales Document";
                    ShortCutKey = 'Ctrl+F9';
                }
                action("Re&open")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Re&open';
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        ReleaseSalesDoc: Codeunit "Release Sales Document";
                    begin
                        ReleaseSalesDoc.Reopen(Rec);
                    end;
                }
            }
            action(MakeOrder)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Make &Order';
                Enabled = MakeOrderEnable;
                Image = MakeOrder;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Codeunit "Standing Sales Order to Order";
            }
            action("&Print")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    ReportPrint.PrintSalesHeader(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        // P8001132
        "Order FrequencyEditable" := not "Delivery Route Order";
        MakeOrderEnable := not "Delivery Route Order";
        IsSellToCountyVisible := FormatAddress.UseCounty("Sell-to Country/Region Code"); // P80066030
        IsShipToCountyVisible := FormatAddress.UseCounty("Ship-to Country/Region Code"); // P80066030
        IsBillToCountyVisible := FormatAddress.UseCounty("Bill-to Country/Region Code"); // P80066030
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateShipToBillToGroupVisibility; // P8007748
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.SaveRecord;
        exit(ConfirmDeletion);
    end;

    trigger OnInit()
    begin
        MakeOrderEnable := true;
        "Order FrequencyEditable" := true;
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

        SetDocNoVisible; // P8007748
    end;

    var
        CurrentSalesLine: Record "Sales Line";
        SalesLine: Record "Sales Line";
        SaleShptLine: Record "Sales Shipment Line";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesSetup: Record "Sales & Receivables Setup";
        ChangeExchangeRate: Page "Change Exchange Rate";
        CopySalesDoc: Report "Copy Sales Document";
        ReportPrint: Codeunit "Test Report-Print";
        UserMgt: Codeunit "User Setup Management";
        StandingOrderMgmt: Codeunit "Standing Sales Order to Order";
        FormatAddress: Codeunit "Format Address";
        [InDataSet]
        "Order FrequencyEditable": Boolean;
        [InDataSet]
        MakeOrderEnable: Boolean;
        DocNoVisible: Boolean;
        ShipToOptions: Option "Default (Sell-to Address)","Alternate Shipping Address","Custom Address";
        BillToOptions: Option "Default (Customer)","Another Customer";
        EmptyShipToCodeErr: Label 'The Code field can only be empty if you select Custom Address in the Ship-to field.';
        IsSellToCountyVisible: Boolean;
        IsShipToCountyVisible: Boolean;
        IsBillToCountyVisible: Boolean;

    local procedure SetDocNoVisible()
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
        DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",Reminder,FinChMemo;
    begin
        // P8007748
        DocNoVisible := DocumentNoVisibility.SalesDocumentNoIsVisible(DocType::"Blanket Order", "No.");
    end;

    local procedure UpdateShipToBillToGroupVisibility()
    begin
        // P8007748
        case true of
            ("Ship-to Code" = '') and ShipToAddressEqualsSellToAddress:
                ShipToOptions := ShipToOptions::"Default (Sell-to Address)";
            ("Ship-to Code" = '') and (not ShipToAddressEqualsSellToAddress):
                ShipToOptions := ShipToOptions::"Custom Address";
            "Ship-to Code" <> '':
                ShipToOptions := ShipToOptions::"Alternate Shipping Address";
        end;

        if "Bill-to Customer No." = "Sell-to Customer No." then
            BillToOptions := BillToOptions::"Default (Customer)"
        else
            BillToOptions := BillToOptions::"Another Customer";
    end;
}

