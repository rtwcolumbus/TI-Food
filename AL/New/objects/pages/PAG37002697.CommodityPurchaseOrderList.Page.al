page 37002697 "Commodity Purchase Order List"
{
    // PRW16.00.04
    // P8000902, Columbus IT, Don Bresee, 14 MAR 11
    //   Add Commodity Payment logic
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 9 NOV 15
    //   NAV 2016 refactoring; Cleanup action names
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Commodity Purchase Order List';
    CardPageID = "Commodity Purchase Order";
    Editable = false;
    PageType = List;
    SourceTable = "Purchase Header";
    SourceTableView = WHERE("Commodity Manifest Order" = CONST(true));
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control37002020)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Buy-from Vendor No."; "Buy-from Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Order Address Code"; "Order Address Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Buy-from Vendor Name"; "Buy-from Vendor Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Vendor Authorization No."; "Vendor Authorization No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Buy-from Post Code"; "Buy-from Post Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Buy-from Country/Region Code"; "Buy-from Country/Region Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Buy-from Contact"; "Buy-from Contact")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Pay-to Vendor No."; "Pay-to Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Pay-to Name"; "Pay-to Name")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Pay-to Post Code"; "Pay-to Post Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Pay-to Country/Region Code"; "Pay-to Country/Region Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Pay-to Contact"; "Pay-to Contact")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Ship-to Code"; "Ship-to Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Ship-to Name"; "Ship-to Name")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Ship-to Post Code"; "Ship-to Post Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Ship-to Country/Region Code"; "Ship-to Country/Region Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Ship-to Contact"; "Ship-to Contact")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DimMgt.LookupDimValueCodeNoUpdate(1);
                    end;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DimMgt.LookupDimValueCodeNoUpdate(2);
                    end;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = true;
                }
                field("Purchaser Code"; "Purchaser Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Assigned User ID"; "Assigned User ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Payment Terms Code"; "Payment Terms Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Payment Discount %"; "Payment Discount %")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Payment Method Code"; "Payment Method Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Shipment Method Code"; "Shipment Method Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Requested Receipt Date"; "Requested Receipt Date")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            part(Control1901138007; "Vendor Details FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Buy-from Vendor No.");
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
                        Rec.OpenDocumentStatistics();
                    end;
                }
                action(Card)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Card';
                    Image = Card;
                    RunObject = Page "Vendor Card";
                    RunPageLink = "No." = FIELD("Buy-from Vendor No.");
                    ShortCutKey = 'Shift+F7';
                }
                action("Co&mments")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page "Purch. Comment Sheet";
                    RunPageLink = "Document Type" = FIELD("Document Type"),
                                  "No." = FIELD("No.");
                }
                action(Receipts)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Receipts';
                    Image = Receipt;
                    RunObject = Page "Posted Purchase Receipts";
                    RunPageLink = "Order No." = FIELD("No.");
                    RunPageView = SORTING("Order No.");
                }
                action(Invoices)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Invoices';
                    Image = Invoice;
                    RunObject = Page "Posted Purchase Invoices";
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
                        Rec.ShowDocDim;
                    end;
                }
            }
        }
        area(processing)
        {
            action("&Show Order")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Show Order';
                Ellipsis = true;
                Image = "Order";

                trigger OnAction()
                begin
                    PAGE.Run(PAGE::"Purchase Order", Rec);
                end;
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("&Calculate")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Calculate';
                    Image = Calculate;

                    trigger OnAction()
                    var
                        CommCostMgmt: Codeunit "Commodity Cost Management";
                    begin
                        CommCostMgmt.CalcCommOrderCosts(Rec, false);
                        Commit;
                        CalcFields("Commodity Cost Calculated");
                        if not "Commodity Cost Calculated" then
                            CommCostMgmt.CalcCommOrderCosts(Rec, true);
                        CurrPage.Update(false);
                    end;
                }
                separator(Separator37002019)
                {
                }
                action("Re&lease")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    ShortCutKey = 'Ctrl+F9';

                    trigger OnAction()
                    var
                        ReleasePurchDoc: Codeunit "Release Purchase Document";
                    begin
                        ReleasePurchDoc.PerformManualRelease(Rec);
                    end;
                }
                action("Re&open")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Re&open';
                    Image = ReOpen;

                    trigger OnAction()
                    var
                        ReleasePurchDoc: Codeunit "Release Purchase Document";
                    begin
                        ReleasePurchDoc.PerformManualReopen(Rec);
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
                        ReportPrint.PrintPurchHeader(Rec);
                    end;
                }
                action("P&ost")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = Post;
                    ShortCutKey = 'F9';

                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                        ApprovalMgt: Codeunit "Approvals Mgmt.";
                        PrePaymentMgt: Codeunit "Prepayment Mgt.";
                    begin
                        Rec.Find; // P8000688
                        if ApprovalMgt.PrePostApprovalCheckPurch(Rec) then begin // P8004516
                            if PrePaymentMgt.TestPurchasePrepayment(Rec) then // P8004516
                                Error(StrSubstNo(Text001, "Document Type", "No."))
                            else begin
                                if PrePaymentMgt.TestPurchasePayment(Rec) then begin // P8004516
                                    if not Confirm(StrSubstNo(Text002, "Document Type", "No."), true) then
                                        exit
                                    else
                                        CODEUNIT.Run(CODEUNIT::"Purch.-Post (Yes/No)", Rec);
                                end else
                                    CODEUNIT.Run(CODEUNIT::"Purch.-Post (Yes/No)", Rec);
                            end;
                        end;
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
                    var
                        SalesHeader: Record "Sales Header";
                        ApprovalMgt: Codeunit "Approvals Mgmt.";
                        PrePaymentMgt: Codeunit "Prepayment Mgt.";
                    begin
                        Rec.Find; // P8000688
                        if ApprovalMgt.PrePostApprovalCheckPurch(Rec) then begin // P8004516
                            if PrePaymentMgt.TestPurchasePrepayment(Rec) then // P8004516
                                Error(StrSubstNo(Text001, "Document Type", "No."))
                            else begin
                                if PrePaymentMgt.TestPurchasePayment(Rec) then begin // P8004516
                                    if not Confirm(StrSubstNo(Text002, "Document Type", "No."), true) then
                                        exit
                                    else
                                        CODEUNIT.Run(CODEUNIT::"Purch.-Post + Print", Rec);
                                end else
                                    CODEUNIT.Run(CODEUNIT::"Purch.-Post + Print", Rec);
                            end;
                        end;
                    end;
                }
            }
            action("&Print")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;

                trigger OnAction()
                begin
                    DocPrint.PrintPurchHeader(Rec);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(ShowOrder_Promoted; "&Show Order")
                {
                }
                actionref(Calculate_Promoted; "&Calculate")
                {
                }
                actionref(Print_Promoted; "&Print")
                {
                }
                actionref(Statistics_Promoted; Statistics)
                {
                }
            }
            group(Category_Release)
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
        }
    }

    var
        DimMgt: Codeunit DimensionManagement;
        ReportPrint: Codeunit "Test Report-Print";
        DocPrint: Codeunit "Document-Print";
        Text001: Label 'There are non posted Prepayment Amounts on %1 %2.';
        Text002: Label 'There are unpaid Prepayment Invoices related to %1 %2. Do you wish to continue?';
}

