page 37002660 "Terminal Market Sales Order"
{
    // PR3.70.04
    // P8000043A, Myers Nissi, Jack Reynolds, 02 JUN 04
    //    Support for easy lot tracking
    // 
    // PR3.70.07
    // P8000148A, Myers Nissi, Jack Reynolds, 22 NOV 04
    //   Change shortcut key for changing a sales line
    // 
    // PR3.70.10
    // P8000237A, Myers Nissi, Jack Reynolds, 04 AUG 05
    //   Allow partial entry of product code
    // 
    // PR4.00
    // P8000248B, Myers Nissi, Jack Reynolds, 08 OCT 05
    //   Add Line menu item to show sales history
    // 
    // P8000255A, Myers Nissi, Jack Reynolds, 21 OCT 05
    //   Fix problem with RUNMODAL during credit check when inserting sales line
    // 
    // P8000254A, Myers Nissi, Jack Reynolds, 21 OCT 05
    //   Add sales lines with base unit of measure
    // 
    // P8000253A, Myers Nissi, Jack Reynolds, 21 OCT 05
    //   Add ability to enter quantity to order and price directly on form and the add all lines at once
    // 
    // PR4.00.01
    // P8000283A, VerticalSoft, Jack Reynolds, 27 JAN 06
    //   Fix problem inserting lines with accruals
    // 
    // PR4.00.02
    // P8000290A, VerticalSoft, Jack Reynolds, 10 FEB 06
    //   Replace flowfield with function for outstanding amount
    // 
    // P8000291A, VerticalSoft, Jack Reynolds, 10 FEB 06
    //   Remove Ship-to UPS Zone
    // 
    // PR4.00.03
    // P8000325A, VerticalSoft, Jack Reynolds, 01 MAY 06
    //   InsertSalesLine - modify call to CreateReservEntry for new parameter for expiration date
    // 
    // PR5.00
    // P8000466A, VerticalSoft, Don Bresee, 12 JUN 07
    //   Eliminate parameter for Expiration Date
    //   Delete sales lines without prompting to delete tracking lines
    // 
    // PRW15.00.03
    // P8000649, VerticalSoft, Jack Reynolds, 03 DEC 08
    //   Fix Credit Info. button to run a worldwide form
    // 
    // P8000650, VerticalSoft, Jack Reynolds, 03 DEC 08
    //   Update total after adding multiple lines
    // 
    // PRW16.00.01
    // P8000734, VerticalSoft, Jack Reynolds, 19 OCT 09
    //   Fix problem when closing the Add Sales Line form
    // 
    // PRW16.00.02
    // P8000784, VerticalSoft, Jack Reynolds, 03 MAR 10
    //   Fix problem with quantity available when changing line
    // 
    // PRW16.00.02
    // P8000797, VerticalSoft, MMAS, 25 MAR 10
    //   Page creation
    // 
    // PRW16.00.03
    // P8000828, VerticalSoft, Don Bresee, 03 JUN 10
    //   Consolidate timer logic
    // 
    // PRW16.00.05
    // P8000944, Columbus IT, Jack Reynolds, 31 MAY 11
    //   Support for enahnced terminal market order entry
    // 
    // P8000952, Columbus IT, Jack Reynolds, 31 MAY 11
    //   Action to create new customers
    // 
    // PRW16.00.06
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
    // PRW18.00
    // P8001359, Columbus IT, Jack Reynolds, 05 NOV 14
    //   Add support for ShowMandatory
    // 
    // P8001360, Columbus IT, Jack Reynolds, 06 NOV 14
    //   Update .NET variable references
    // 
    // PRW18.00.01
    // P8001386, Columbus IT, Jack Reynolds, 27 MAY 15
    //    Renamed NAV Food client addins
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    //   Update add-in assembly version references
    // 
    // PRW10.0
    // P8007755, To-Increase, Jack Reynolds, 22 NOV 16
    //   Update add-in assembly version references
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW111.00
    // P80059471, To Increase, Jack Reynolds, 25 JUN 18
    //   Upgrade signal control for JavaScript
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 28 APR 22
    //   Removing support for Signal Functions codeunit
    //   Support for background validation of documents and journals
    //
    // PRW121.2
    // P800162917, To Increase, Jack Reynolds, 23 Jan 23
    //   Obsolete Post and Print and add Post and Send

    Caption = 'Terminal Market Sales Order';
    PageType = Card;
    SourceTable = "Sales Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    ApplicationArea = FOODBasic;
                    ShowMandatory = true;
                }
                field("Sell-to Customer Name"; "Sell-to Customer Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sell-to Contact"; "Sell-to Contact")
                {
                    ApplicationArea = FOODBasic;
                }
                group(Address)
                {
                    Caption = 'Address';
                    field("Sell-to Address"; "Sell-to Address")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Sell-to Address 2"; "Sell-to Address 2")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Sell-to City"; "Sell-to City")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Sell-to Post Code"; "Sell-to Post Code")
                    {
                        ApplicationArea = FOODBasic;
                    }
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
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(OutstandingAmountLCY; OutstandingAmountLCY)
                {
                    ApplicationArea = FOODBasic;
                    AutoFormatType = 1;
                    Caption = 'Order Total';
                }
            }
            part(OrderLines; "Term. Mkt. Order Lines Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("No.");
            }
            group(Shipping)
            {
                Visible = false;
                field("Ship-to Code"; "Ship-to Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Ship-to Name"; "Ship-to Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Ship-to Contact"; "Ship-to Contact")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Delivery Route No."; "Delivery Route No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Delivery Stop No."; "Delivery Stop No.")
                {
                    ApplicationArea = FOODBasic;
                }
                group(Control37002061)
                {
                    Caption = 'Address';
                    field("Ship-to Address"; "Ship-to Address")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Ship-to Address 2"; "Ship-to Address 2")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Ship-to Post Code"; "Ship-to Post Code")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Ship-to City"; "Ship-to City")
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Shipment Method Code"; "Shipment Method Code")
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
                field("Package Tracking No."; "Package Tracking No.")
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
            group(Invoicing)
            {
                Visible = false;
                field("Bill-to Customer No."; "Bill-to Customer No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Bill-to Name"; "Bill-to Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Bill-to Contact"; "Bill-to Contact")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Price at Shipment"; "Price at Shipment")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Contract Items Only"; "Contract Items Only")
                {
                    ApplicationArea = FOODBasic;
                }
                group(Control37002062)
                {
                    Caption = 'Address';
                    field("Bill-to Address"; "Bill-to Address")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Bill-to Address 2"; "Bill-to Address 2")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Bill-to Post Code"; "Bill-to Post Code")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Bill-to City"; "Bill-to City")
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
                field("Off-Invoice Allowance Exists"; "Off-Invoice Allowance Exists")
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
                field("Tax Area Code"; "Tax Area Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Tax Liable"; "Tax Liable")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            // P800144605
            part(SalesDocCheckFactbox; "Sales Doc. Check Factbox")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Check Document';
                Visible = SalesDocCheckFactboxVisible;
                SubPageLink = "No." = FIELD("No."),
                              "Document Type" = FIELD("Document Type");
            }
            part(Control37002055; "Customer Statistics FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Bill-to Customer No.");
            }
            part(CustomerDetailsFactBox; "Customer Details FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Sell-to Customer No.");
                Visible = false;
            }
            systempart(Control37002057; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002058; Notes)
            {
                ApplicationArea = FOODBasic;
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
                        Rec.OpenSalesOrderStatistics();
                    end;
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

                    trigger OnAction()
                    begin
                        ShowDocDim;          // P8001133
                        CurrPage.SaveRecord; // P8001133
                    end;
                }
                separator("<Action1102603135>")
                {
                    Caption = '<Action1102603135>';
                }
                action("Off-Invoice Allowances")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Off-Invoice Allowances';
                    Image = View;
                    RunObject = Page "Order Off-Invoice Allowances";
                    RunPageLink = "Document Type" = FIELD("Document Type"),
                                  "Document No." = FIELD("No.");
                }
            }
            group(Customer)
            {
                Caption = 'Customer';
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    RunObject = Page "Customer Card";
                    RunPageLink = "No." = FIELD("Sell-to Customer No.");
                    ShortCutKey = 'Shift+F7';
                }
                action("Credit Info.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Credit Info.';
                    Image = Info;
                    RunObject = Page "Available Credit";
                    RunPageLink = "No." = FIELD("Sell-to Customer No.");
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action(NewCustomer)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'New Customer';
                    Image = NewCustomer;

                    trigger OnAction()
                    var
                        CreateCustomer: Page "Create New Customer";
                    begin
                        // P8000952
                        if "Sell-to Customer No." <> '' then
                            exit;

                        CreateCustomer.RunModal;
                        "Sell-to Customer No." := CreateCustomer.GetCustomerNo;
                        if "Sell-to Customer No." <> '' then
                            Validate("Sell-to Customer No.");
                    end;
                }
                action(ItemAvail)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Items';
                    Image = ItemLines;

                    trigger OnAction()
                    var
                        ItemAvail: Page "Term. Mkt. Item Availability";
                    begin
                        if "No." = '' then // P800144605
                            exit;
                        ItemAvail.SetOrder("No."); // P800144605
                        ItemAvail.SetSharedTable(SharedItemLotAvail);
                        ItemAvail.RunModal(); // P800144605
                    end;
                }
                separator(Separator37002087)
                {
                }
                action("Re&lease")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    RunObject = Codeunit "Release Sales Document";
                    ShortCutKey = 'Ctrl+F9';
                }
                action("Re&open")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Re&open';
                    Image = ReOpen;

                    trigger OnAction()
                    var
                        ReleaseSalesDoc: Codeunit "Release Sales Document";
                    begin
                        ReleaseSalesDoc.PerformManualReopen(Rec); // P8000944
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                action("Test Report")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;

                    trigger OnAction()
                    begin
                        ReportPrint.PrintSalesHeader(Rec);
                    end;
                }
                action("P&ost")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = Post;
                    ShortCutKey = 'F9';

                    // P800162917
                    trigger OnAction()
                    begin
                        PostDocument(CODEUNIT::"Sales-Post (Yes/No)");
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
                        PostDocument(CODEUNIT::"Sales-Post and Send");
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

                    // P800162917
                    trigger OnAction()
                    begin
                        PostDocument(CODEUNIT::"Sales-Post + Print");
                    end;
                }
            }
            group("&Print")
            {
                Caption = '&Print';
                action("Order")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Order';
                    Image = "Order";

                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                    begin
                        // P8000970
                        //DocPrint.PrintSalesHeader(Rec);
                        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                        SalesHeader.SetRange("Sell-to Customer No.", "Sell-to Customer No.");
                        SalesHeader.SetRange("Order Date", "Order Date");
                        SalesHeader.FindSet;
                        if SalesHeader.Next <> 0 then
                            case StrMenu(StrSubstNo(Text002, "Sell-to Customer Name", "Order Date"), 2) of
                                0:
                                    exit;
                                1:
                                    SalesHeader.SetRange("No.", "No.");
                            end;
                        REPORT.Run(REPORT::"Terminal Market Order Conf.", false, false, SalesHeader);
                        // P8000970
                    end;
                }
                action("Pick Ticket")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Pick Ticket';
                    Image = InventoryPick;

                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                    begin
                        // P8000970
                        //CurrPage.SETSELECTIONFILTER(SalesHeader);
                        //SalesHeader.PrintPickTicket(TRUE);
                        SalesHeader.Copy(Rec);
                        SalesHeader.SetRecFilter;
                        SalesHeader.PrintTermMktPickTicket(true);
                        // P8000970
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(NewCustomer_Promoted; NewCustomer)
                {
                }
                group(Post)
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
                group(Release)
                {
                    Caption = 'Release';
                    ShowAs = SplitButton;

                    actionref(Release_Promoted; "Re&lease")
                    {
                    }
                    actionref(Reopen_Promoted; "Re&open")
                    {
                    }
                }
                actionref(Order_Promoted; Order)
                {
                }
                actionref(PickTicket_Promoted; "Pick Ticket")
                {
                }
            }
            actionref(ItemAvail_Promoted; ItemAvail)
            {
            }
            group(Category_Customer)
            {
                Caption = 'Customer';

                actionref(Card_Promoted; Card)
                {
                }
                actionref(CreditInfo_Promoted; "Credit Info.")
                {
                }
            }
        }
    }

    // P800144605
    trigger OnAfterGetRecord()
    begin
        OnAfterOnAfterGetRecord(Rec);
    end;

    trigger OnOpenPage()
    var
        DocumentErrorsMgt: Codeunit "Document Errors Mgt.";
    begin
        BindSubscription(FoodDocumentErrorsMgt); // P800144605
        CurrPage.OrderLines.PAGE.SetSharedTable(SharedItemLotAvail);
        // P800144605
        SalesDocCheckFactboxVisible := DocumentErrorsMgt.BackgroundValidationEnabled();
        CheckShowBackgrValidationNotification();
        // P800144605
    end;

    var
        SalesSetup: Record "Sales & Receivables Setup";
        SharedItemLotAvail: Record "Item Lot Availability" temporary;
        Text001: Label 'Item Availability page must be closed first.';
        ReportPrint: Codeunit "Test Report-Print";
        DocPrint: Codeunit "Document-Print";
        FoodDocumentErrorsMgt: Codeunit "Food Document Errors Mgt.";
        SalesDocCheckFactboxVisible: Boolean;
        Text002: Label 'This Order,All %1 orders for %2';

    // P800144605
    procedure RunBackgroundCheck()
    begin
        CurrPage.SalesDocCheckFactbox.Page.CheckErrorsInBackground(Rec);
    end;

    // P800144605
    local procedure CheckShowBackgrValidationNotification()
    var
        DocumentErrorsMgt: Codeunit "Document Errors Mgt.";
    begin
        if DocumentErrorsMgt.CheckShowEnableBackgrValidationNotification() then
            SalesDocCheckFactboxVisible := DocumentErrorsMgt.BackgroundValidationEnabled();
    end;

    // P800162917
    local procedure PostDocument(PostingCodeunitID: Integer)
    var
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
    begin
        LinesInstructionMgt.SalesCheckAllLinesHaveQuantityAssigned(Rec);

        Rec.SendToPosting(PostingCodeunitID);

        CurrPage.Update(false);
    end;

    // P800144605
    [IntegrationEvent(true, false)]
    local procedure OnAfterOnAfterGetRecord(var SalesHeader: Record "Sales Header")
    begin
    end;
}

