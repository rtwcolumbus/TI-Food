report 37002672 "Sales Payment - Daily Detail"
{
    // PRW16.00.05
    // P8000941, Columbus IT, Jack Reynolds, 25 OCT 11
    //   Daily Detail of Sales Payment Tenders
    // 
    // PRW110.0
    // P8007748, To-Increase, Jack Reynolds, 03 NOV 16
    //   General changes and refactoring for NAV 2017
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    DefaultLayout = RDLC;
    RDLCLayout = './layout/SalesPaymentDailyDetail.rdlc';

    ApplicationArea = FOODBasic;
    Caption = 'Sales Payment - Daily Detail';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Sales Payment Header"; "Sales Payment Header")
        {
            DataItemTableView = SORTING("No.");

            trigger OnAfterGetRecord()
            begin
                SalesPayment.TransferFields("Sales Payment Header");
                SalesPayment.Insert;
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Posting Date", PostingDate);
            end;
        }
        dataitem("Posted Sales Payment Header"; "Posted Sales Payment Header")
        {
            DataItemTableView = SORTING("No.");

            trigger OnAfterGetRecord()
            begin
                SalesPayment.TransferFields("Posted Sales Payment Header");
                SalesPayment.Insert;
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Posting Date", PostingDate);
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number);
            dataitem("Sales Payment Tender Entry"; "Sales Payment Tender Entry")
            {
                DataItemTableView = SORTING("Document No.") WHERE(Type = FILTER(<> Void), Result = FILTER(" " | Posted));
                column(SalesPaymentTenderEntryCustNo; "Customer No.")
                {
                    IncludeCaption = true;
                }
                column(CompanyName; CompanyInfo.Name)
                {
                }
                column(PostingDate; StrSubstNo(Text002, PostingDate))
                {
                }
                column(SalesPaymentTenderEntryPaymentMethodCode; "Payment Method Code")
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
                column(SalesPaymentTenderEntryType; Type)
                {
                    IncludeCaption = true;
                }
                column(SalesPaymentCustName; SalesPayment."Customer Name")
                {
                }

                trigger OnPreDataItem()
                begin
                    SetRange("Document No.", SalesPayment."No.");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then
                    SalesPayment.Find('-')
                else
                    SalesPayment.Next;
            end;

            trigger OnPreDataItem()
            begin
                SetRange(Number, 1, SalesPayment.Count);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = FOODBasic;
                        Caption = 'Posting Date';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        CustNameCaption = 'Customer Name';
        ReportTitleCaption = 'Sales Payment Daily Detail';
        PageCaption = 'Page';
    }

    trigger OnInitReport()
    begin
        PostingDate := WorkDate;
    end;

    trigger OnPreReport()
    begin
        if PostingDate = 0D then
            Error(Text001);
        CompanyInfo.Get;
    end;

    var
        CompanyInfo: Record "Company Information";
        SalesPayment: Record "Posted Sales Payment Header" temporary;
        Text001: Label 'Posting Date must be entered.';
        PaymentMethod: Record "Payment Method";
        PostingDate: Date;
        Text002: Label 'Transactions Posted %1';
}

