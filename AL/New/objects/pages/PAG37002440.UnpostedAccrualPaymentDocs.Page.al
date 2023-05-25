page 37002440 "Unposted Accrual Payment Docs."
{
    // PRW18.00.02
    // P8002741, To-Increase, Jack Reynolds, 30 Sep 15
    //   Option to create accrual payment documents
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Unposted Accrual Payment Documents';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = ListPlus;
    PromotedActionCategories = ' ,Line';
    SaveValues = true;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Control37002001)
            {
                ShowCaption = false;
                group(Control37002006)
                {
                    ShowCaption = false;
                    field(DocumentType; DocumentType)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Document Type';

                        trigger OnValidate()
                        begin
                            SetVisible;
                        end;
                    }
                    field(PurchInvoiceCnt; PurchInvoiceCnt)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Purchase Invoices';
                        Editable = false;
                    }
                    field(PurchCMCnt; PurchCMCnt)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Purchase Credit Memos';
                        Editable = false;
                    }
                    field(SalesInvoiceCnt; SalesInvoiceCnt)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Sales Invoices';
                        Editable = false;
                    }
                    field(SalesCMCnt; SalesCMCnt)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Sales Credit Memos';
                        Editable = false;
                    }
                }
                group(Control37002007)
                {
                    ShowCaption = false;
                    part(PurchInvoice; "Unposted Acc. Pymt. Purch Docs")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Purchase Invoices';
                        SubPageView = WHERE("Document Type" = CONST(Invoice));
                        Visible = PIVisible;
                    }
                    part(PurchCM; "Unposted Acc. Pymt. Purch Docs")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Purchase Credit Memos';
                        SubPageView = WHERE("Document Type" = CONST("Credit Memo"));
                        Visible = PCVisible;
                    }
                    part(SalesInvoice; "Unposted Acc. Pymt. Sales Docs")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Sales Invoices';
                        SubPageView = WHERE("Document Type" = CONST(Invoice));
                        Visible = SIVisible;
                    }
                    part(SalesCM; "Unposted Acc. Pymt. Sales Docs")
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Sales Credit Memos';
                        SubPageView = WHERE("Document Type" = CONST("Credit Memo"));
                        Visible = SCVisible;
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        SalesHeader.SetRange("Accrual Payment", true);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesInvoiceCnt := SalesHeader.Count;
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
        SalesCMCnt := SalesHeader.Count;

        PurchHeader.SetRange("Accrual Payment", true);
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Invoice);
        PurchInvoiceCnt := PurchHeader.Count;
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::"Credit Memo");
        PurchCMCnt := PurchHeader.Count;
    end;

    trigger OnOpenPage()
    begin
        SetVisible;
    end;

    var
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        SalesInvoiceCnt: Integer;
        SalesCMCnt: Integer;
        PurchInvoiceCnt: Integer;
        PurchCMCnt: Integer;
        DocumentType: Option "Purchase Invoices","Purchase Credit Memos","Sales Invoices","Sales Credit Memos";
        [InDataSet]
        PIVisible: Boolean;
        [InDataSet]
        PCVisible: Boolean;
        [InDataSet]
        SIVisible: Boolean;
        [InDataSet]
        SCVisible: Boolean;

    local procedure SetVisible()
    begin
        PIVisible := DocumentType = DocumentType::"Purchase Invoices";
        PCVisible := DocumentType = DocumentType::"Purchase Credit Memos";
        SIVisible := DocumentType = DocumentType::"Sales Invoices";
        SCVisible := DocumentType = DocumentType::"Sales Credit Memos";
    end;
}

