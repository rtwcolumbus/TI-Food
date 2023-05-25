report 37002026 "Phys. Inventory Journal"
{
    // P800-MegsaApp

    ApplicationArea = FOODBasic;
    Caption = 'Physical Inventory Journals';
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
        CODEUNIT.Run(CODEUNIT::"Phys. Inventory Journal");
    end;
}

