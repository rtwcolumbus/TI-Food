report 37002670 "Sales Payment - Unposted"
{
    // PRW16.00.05
    // P8000941, Columbus IT, Jack Reynolds, 06 OCT 11
    //   Sales Payments granule
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    DefaultRenderingLayout = StandardRDLCLayout;

    ApplicationArea = FOODBasic;
    Caption = 'Sales Payment';
    UsageCategory = Documents;

    dataset
    {
        dataitem("Sales Payment Header"; "Sales Payment Header")
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
            column(SalesPaymentHeaderCustNo; "Customer No.")
            {
            }
            column(SalesPaymentHeaderCustName; "Customer Name")
            {
            }
            column(SalesPaymentHeaderPostingDate; "Posting Date")
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
            column(SalesPaymentHeaderNo; "No.")
            {
            }
            dataitem("Sales Payment Line"; "Sales Payment Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document No.", "Line No.");
                column(SalesPaymentLineType; Type)
                {
                    IncludeCaption = true;
                }
                column(SalesPaymentLineNo; "No.")
                {
                    IncludeCaption = true;
                }
                column(SalesPaymentLineDesc; Description)
                {
                    IncludeCaption = true;
                }
                column(SalesPaymentLineAmount; Amount)
                {
                    IncludeCaption = true;
                }
                column(SalesPaymentLineDocNo; "Document No.")
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
                column(SalesPaymentTenderEntryEntryNo; "Entry No.")
                {
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

    rendering
    {
        layout(StandardRDLCLayout)
        {
            Summary = 'Standard Layout';
            Type = RDLC;
            LayoutFile = './layout/SalesPaymentUnposted.rdlc';
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

