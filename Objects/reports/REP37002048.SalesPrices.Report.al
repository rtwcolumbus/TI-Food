report 37002048 "Sales Prices"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW113.00.02
    // P80079516, To Increase, Jack Reynolds, 25 JUL 19
    //   Suppress "Schedule Report" dialog

    ApplicationArea = FOODBasic;
    Caption = 'Sales Prices';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    UseRequestPage = false;

    dataset
    {
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
    }

    trigger OnInitReport()
    begin
        CODEUNIT.Run(CODEUNIT::"Sales Prices");
    end;
}

