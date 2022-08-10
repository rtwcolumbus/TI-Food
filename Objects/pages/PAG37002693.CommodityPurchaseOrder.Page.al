page 37002693 "Commodity Purchase Order"
{
    // PRW16.00.04
    // P8000902, Columbus IT, Don Bresee, 14 MAR 11
    //   Add Commodity Payment logic
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 9 NOV 15
    //   NAV 2016 refactoring; Cleanup action names
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW120.0
    // P800144605, To Increase, Jack Reynolds, 23 MAY 22
    //   Support for background validation of documents and journals

    Caption = 'Commodity Purchase Order';
    InsertAllowed = false;
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Purchase Header";
    SourceTableView = WHERE("Commodity Manifest Order" = CONST(true));

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Buy-from Vendor No."; "Buy-from Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Buy-from Vendor Name"; "Buy-from Vendor Name")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Pay-to Vendor No."; "Pay-to Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Pay-to Name"; "Pay-to Name")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Commodity Item No."; "Commodity Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Comm. Receiving Complete"; "Comm. Receiving Complete")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Comm. Order Description"; CommOrderDescription())
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Commodity P.O. Type"; "Commodity P.O. Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Commodity Cost Calculated"; "Commodity Cost Calculated")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Commodity Amount"; "Commodity Amount")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field("Blended Comm. Unit Cost"; "Blended Comm. Unit Cost")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Vendor Invoice No."; "Vendor Invoice No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(Lines; "Commodity Purch. Order Subpage")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("No.");
                SubPageView = SORTING("Document Type", "Document No.", "Line No.");
            }
        }
        area(factboxes)
        {
            // P800144605
            part(PurchDocCheckFactbox; "Purch. Doc. Check Factbox")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Check Document';
                Visible = PurchDocCheckFactboxVisible;
                SubPageLink = "No." = FIELD("No."),
                              "Document Type" = FIELD("Document Type");
            }
            part(ItemReplenishmentFactBox; "Item Replenishment FactBox")
            {
                ApplicationArea = FOODBasic;
                Provider = Lines;
                SubPageLink = "No." = FIELD("No.");
                Visible = false;
            }
            part(ApprovalFactBox; "Approval FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Table ID" = CONST(38),
                              "Document Type" = FIELD("Document Type"),
                              "Document No." = FIELD("No."),
                              Status = CONST(Open);
                Visible = false;
            }
            part(VendorDetailsFactBox; "Vendor Details FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Buy-from Vendor No.");
                Visible = false;
            }
            part(Control37002040; "Vendor Statistics FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Buy-from Vendor No.");
                Visible = true;
            }
            part(Control37002039; "Vendor Hist. Buy-from FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Buy-from Vendor No.");
                Visible = true;
            }
            part(VendorHistPaytoFactBox; "Vendor Hist. Pay-to FactBox")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "No." = FIELD("Pay-to Vendor No.");
                Visible = false;
            }
            systempart(Control37002037; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002036; Notes)
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
                        CheckOrderMinimum('MESSAGE');
                        CalcInvDiscForHeader;
                        Commit;
                        PAGE.RunModal(PAGE::"Purchase Order Statistics", Rec);
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
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

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
                    Promoted = true;
                    PromotedCategory = Process;

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
                separator(Separator37002028)
                {
                }
                action("Re&lease")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    Promoted = true;
                    PromotedCategory = Process;
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
                    Promoted = true;
                    PromotedCategory = Process;

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
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
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
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
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
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    DocPrint.PrintPurchHeader(Rec);
                end;
            }
        }
    }

    // P800144605
    trigger OnAfterGetRecord()
    begin
        OnAfterOnAfterGetRecord(Rec);
    end;

    // P800144605
    trigger OnOpenPage()
    var
        DocumentErrorsMgt: Codeunit "Document Errors Mgt.";
    begin
        BindSubscription(FoodDocumentErrorsMgt);        
        PurchDocCheckFactboxVisible := DocumentErrorsMgt.BackgroundValidationEnabled(); 
        CheckShowBackgrValidationNotification();
    end;

    var
        FoodDocumentErrorsMgt: Codeunit "Food Document Errors Mgt.";
        PurchDocCheckFactboxVisible: Boolean;
        ReportPrint: Codeunit "Test Report-Print";
        DocPrint: Codeunit "Document-Print";
        Text001: Label 'There are non-posted Prepayment Amounts on %1 %2.';
        Text002: Label 'There are unpaid Prepayment Invoices related to %1 %2. Do you wish to continue?';
        Text003: Label 'Do you want to post the Order?';
        Text004: Label 'Do you want to post and print the Order?';

    local procedure PostOrder(PrintOrder: Boolean)
    var
        SalesHeader: Record "Sales Header";
        ApprovalMgt: Codeunit "Approvals Mgmt.";
        PrePaymentMgt: Codeunit "Prepayment Mgt.";
        PurchPost: Codeunit "Purch.-Post";
        PurchInvHeader: Record "Purch. Inv. Header";
        ReportSelection: Record "Report Selections";
    begin
        Rec.Find;
        if ApprovalMgt.PrePostApprovalCheckPurch(Rec) then begin // P8004516
            if PrePaymentMgt.TestPurchasePrepayment(Rec) then // P8004516
                Error(StrSubstNo(Text001, "Document Type", "No."));
            if PrePaymentMgt.TestPurchasePayment(Rec) then // P8004516
                if not Confirm(StrSubstNo(Text002, "Document Type", "No."), true) then
                    exit;
            if not PrintOrder then begin
                if not Confirm(Text003) then
                    exit;
            end else begin
                if not Confirm(Text004) then
                    exit;
            end;
            Receive := true;
            Invoice := true;
            PurchPost.Run(Rec);
            if PrintOrder then begin
                PurchInvHeader."No." := "Last Posting No.";
                PurchInvHeader.SetRecFilter;
                ReportSelection.Reset;
                ReportSelection.SetRange(Usage, ReportSelection.Usage::"P.Invoice");
                ReportSelection.FindSet;
                repeat
                    ReportSelection.TestField("Report ID");
                    REPORT.Run(ReportSelection."Report ID", false, false, PurchInvHeader);
                until (ReportSelection.Next = 0);
            end;
        end;
    end;

    // P800144605
    procedure RunBackgroundCheck()
    begin
        CurrPage.PurchDocCheckFactbox.Page.CheckErrorsInBackground(Rec);
    end;

    // P800144605
    local procedure CheckShowBackgrValidationNotification()
    var
        DocumentErrorsMgt: Codeunit "Document Errors Mgt.";
    begin
        if DocumentErrorsMgt.CheckShowEnableBackgrValidationNotification() then
            PurchDocCheckFactboxVisible := DocumentErrorsMgt.BackgroundValidationEnabled();
    end;

    // P800144605
    [IntegrationEvent(true, false)]
    local procedure OnAfterOnAfterGetRecord(var PurchaseHeader: Record "Purchase Header")
    begin
    end;
}

