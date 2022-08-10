report 37002671 "Sales Payment - Posted"
{
    // PRW16.00.05
    // P8000941, Columbus IT, Don Bresee, 08 SEP 11
    //   Sales Payments granule
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    DefaultLayout = RDLC;
    RDLCLayout = './layout/SalesPaymentPosted.rdlc';

    Caption = 'Sales Payment';

    dataset
    {
        dataitem("Posted Sales Payment Header"; "Posted Sales Payment Header")
        {
            CalcFields = Amount, "Amount Tendered";
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Customer No.", "Posting Date";
            column(ReportTitle; StrSubstNo(Text000, "No."))
            {
            }
            column(PageStr; Text001)
            {
            }
            column(PostedSalesPaymentHeaderCustNo; "Customer No.")
            {
            }
            column(PostedSalesPaymentHeaderCustName; "Customer Name")
            {
            }
            column(PostedSalesPaymentHeaderPostingDate; "Posting Date")
            {
            }
            column(CompanyName; COMPANYPROPERTY.DisplayName)
            {
            }
            column(OrderHeader; Text002)
            {
            }
            column(OrderFooter; Text003)
            {
            }
            column(PaymentFooter; Text005)
            {
            }
            column(PaymentHeader; Text004)
            {
            }
            column(OnAccountAmount; Amount - "Amount Tendered")
            {
                AutoFormatType = 1;
            }
            column(PostedSalesPaymentHeaderNo; "No.")
            {
            }
            dataitem("Posted Sales Payment Line"; "Posted Sales Payment Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document No.", "Line No.");
                column(PostedSalesPaymentLineType; Type)
                {
                    IncludeCaption = true;
                }
                column(PostedSalesPaymentLineNo; "No.")
                {
                    IncludeCaption = true;
                }
                column(PostedSalesPaymentLineDesc; Description)
                {
                    IncludeCaption = true;
                }
                column(PostedSalesPaymentLineAmount; Amount)
                {
                    IncludeCaption = true;
                }
                column(PostedSalesPaymentLineDocNo; "Document No.")
                {
                }
            }
            dataitem("Sales Payment Tender Entry"; "Sales Payment Tender Entry")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document No.");
                column(SalesPaymentTenderEntryType; Type)
                {
                    IncludeCaption = true;
                }
                column(SalesPaymentTenderEntryPaymentMethodCode; "Payment Method Code")
                {
                }
                column(SalesPaymentTenderEntryDesc; Description)
                {
                    IncludeCaption = true;
                }
                column(SalesPaymentTenderEntryAmount; Amount)
                {
                    IncludeCaption = true;
                }
                column(SalesPaymentTenderEntryCardCheckNo; "Card/Check No.")
                {
                    IncludeCaption = true;
                }
                column(SalesPaymentTenderEntryDocNo; "Document No.")
                {
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
        CustNoCaption = 'Customer No.:';
        CustNameCaption = 'Customer Name:';
        PostingDateCaption = 'Posting Date:';
        OnAccountAmountCaption = 'Amount On Account:';
        PaymentMethodCodeCaption = 'Payment Method';
    }

    var
        Text000: Label 'Sales Payment %1';
        Text001: Label 'Page ';
        Text002: Label 'Orders';
        Text003: Label 'Total Orders:';
        Text004: Label 'Payments';
        Text005: Label 'Total Payments:';
}

