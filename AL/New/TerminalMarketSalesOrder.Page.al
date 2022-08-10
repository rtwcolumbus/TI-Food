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

    Caption = 'Terminal Market Sales Order';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Item Availability,Order,Customer';
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

                    trigger OnValidate()
                    begin
                        if "Sell-to Customer No." <> xRec."Sell-to Customer No." then begin
                            CurrPage.SaveRecord;
                            UpdateItemAvailability('ORDER,%1');
                        end;
                    end;
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

                    trigger OnValidate()
                    begin
                        if "Location Code" <> xRec."Location Code" then begin
                            CurrPage.SaveRecord;
                            UpdateItemAvailability('ORDER,%1');
                        end;
                    end;
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

                    trigger OnValidate()
                    begin
                        if "Shipment Date" <> xRec."Shipment Date" then begin
                            CurrPage.SaveRecord;
                            UpdateItemAvailability('ORDER,%1');
                        end;
                    end;
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
            // usercontrol(Signal; "TI.NAVFood.Controls.SignalWeb")
            // {

            //     trigger AddInReady(guid: Text)
            //     begin
            //         // P80059471
            //         SignalFns.SetControl(1, guid, CurrPage.Signal);
            //         CurrPage.Signal.SetInterval(1);
            //     end;

            //     trigger OnSignal()
            //     begin
            //         // P80059471
            //         CurrPage.Update(false);
            //     end;
            // }
        }
        area(factboxes)
        {
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
                    Promoted = true;
                    PromotedCategory = Category5;
                    ShortCutKey = 'F7';

                    trigger OnAction()
                    begin
                        SalesSetup.Get;
                        if SalesSetup."Calc. Inv. Discount" then begin
                            CurrPage.OrderLines.PAGE.CalcInvDisc;
                            Commit
                        end;
                        PAGE.RunModal(PAGE::"Sales Order Statistics", Rec);
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
                    Promoted = true;
                    PromotedCategory = Category6;
                    RunObject = Page "Customer Card";
                    RunPageLink = "No." = FIELD("Sell-to Customer No.");
                    ShortCutKey = 'Shift+F7';
                }
                action("Credit Info.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Credit Info.';
                    Image = Info;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = false;
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
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        CreateCustomer: Page "Create New Customer";
                    begin
                        // P8000952
                        if "Sell-to Customer No." <> '' then
                            exit;

                        CreateCustomer.RunModal;
                        "Sell-to Customer No." := CreateCustomer.GetCustomerNo;
                        if "Sell-to Customer No." <> '' then begin
                            Validate("Sell-to Customer No.");
                            CurrPage.SaveRecord;
                            UpdateItemAvailability('ORDER,%1');
                        end;
                    end;
                }
                action(ItemAvail)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Items';
                    Image = ItemLines;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        ItemAvail: Page "Term. Mkt. Item Availability";
                    begin
                        if ("No." = '') or (SignalFns.GetControlID(2) <> '') then
                            exit;
                        SignalFns.AddEvent(2, StrSubstNo('ORDER,%1', "No."));
                        ItemAvail.SetSignalFns(SignalFns);
                        ItemAvail.SetSharedTable(SharedItemLotAvail);
                        ItemAvail.Run;
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
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Codeunit "Sales-Post (Yes/No)";
                    ShortCutKey = 'F9';
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
                    RunObject = Codeunit "Sales-Post + Print";
                    ShortCutKey = 'Shift+F9';
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
                    Promoted = true;
                    PromotedCategory = Process;

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
                    Promoted = true;
                    PromotedCategory = Process;

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
    }

    trigger OnAfterGetRecord()
    begin
        if "No." <> xRec."No." then
            UpdateItemAvailability('ORDER,%1');
    end;

    trigger OnClosePage()
    begin
        UpdateItemAvailability('CLOSE');
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        UpdateItemAvailability('CLEAR');
    end;

    trigger OnOpenPage()
    begin
        CurrPage.OrderLines.PAGE.SetSignalFns(SignalFns);
        CurrPage.OrderLines.PAGE.SetSharedTable(SharedItemLotAvail);
    end;

    var
        SalesSetup: Record "Sales & Receivables Setup";
        SharedItemLotAvail: Record "Item Lot Availability" temporary;
        SignalFns: Codeunit "Process 800 Signal Functions";
        Text001: Label 'Item Availability page must be closed first.';
        ReportPrint: Codeunit "Test Report-Print";
        DocPrint: Codeunit "Document-Print";
        Text002: Label 'This Order,All %1 orders for %2';

    procedure UpdateItemAvailability(TextStr: Text[30])
    begin
        SignalFns.AddEvent(2, StrSubstNo(TextStr, "No."));
        SignalFns.Signal(2); // P80059471
    end;
}

