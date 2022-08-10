report 37002049 "Sales Price Worksheet"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW113.00.02
    // P80079516, To Increase, Jack Reynolds, 25 JUL 19
    //   Suppress "Schedule Report" dialog

    ApplicationArea = FOODBasic;
    Caption = 'Sales Price Worksheet';
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
        CODEUNIT.Run(CODEUNIT::"Sales Price Worksheet");
    end;
}

