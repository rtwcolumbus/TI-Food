query 37002120 "Detailed Cust. Ledger-Sell-to"
{
    // PRW18.00.01
    // P8001374, Columbus IT, Jack Reynolds, 17 FEB 15
    //   Correct problem with sell-to/bill-to customers
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Detailed Cust. Ledger-Sell-to';

    elements
    {
        dataitem(DetailedCustLedgEntry; "Detailed Cust. Ledg. Entry")
        {
            filter(EntryType; "Entry Type")
            {
                ColumnFilter = EntryType = CONST(Application);
            }
            column(PostingDate; "Posting Date")
            {
            }
            column(CustLedgerEntryNo; "Cust. Ledger Entry No.")
            {
            }
            column(AppliedCustLedgerEntryNo; "Applied Cust. Ledger Entry No.")
            {
            }
            column(BillToCustomerNo; "Customer No.")
            {
            }
            dataitem(CustLedgerEntry; "Cust. Ledger Entry")
            {
                DataItemLink = "Entry No." = DetailedCustLedgEntry."Cust. Ledger Entry No.";
                column(CustLedgerEntry_SellToCustNo; "Sell-to Customer No.")
                {
                }
                column(CustLedgerEntry_DocType; "Document Type")
                {
                }
                column(CustLedgerEntry_DocumentNo; "Document No.")
                {
                }
                column(CustLedgerEntry_Open; Open)
                {
                }
                column(CustLedgerEntry_ClosedAtDate; "Closed at Date")
                {
                }
                column(CustLedgerEntry_PostingDate; "Posting Date")
                {
                }
            }
        }
    }
}

