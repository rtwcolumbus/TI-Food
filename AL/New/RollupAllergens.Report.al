report 37002921 "Rollup Allergens"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW113.00.02
    // P80079516, To Increase, Jack Reynolds, 25 JUL 19
    //   Suppress "Schedule Report" dialog

    ApplicationArea = FOODBasic;
    Caption = 'Rollup Allergens';
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
        CODEUNIT.Run(CODEUNIT::"Allergen Rollup");
    end;
}

