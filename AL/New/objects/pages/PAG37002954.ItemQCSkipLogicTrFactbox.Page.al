page 37002954 "Item Q/C SkipLogic Tr. Factbox"
{
    // PRW111.00.01
    // P80037569, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop QC skip logic

    Caption = 'Item Q/C Skip Logic Transaction Factbox';
    Editable = false;
    PageType = CardPart;
    SourceTable = "Item Quality Skip Logic Trans.";

    layout
    {
        area(content)
        {
            field("Current Level"; "Current Level")
            {
                ApplicationArea = FOODBasic;
            }
            field("Current Skipped Events"; "Current Skipped Events")
            {
                ApplicationArea = FOODBasic;
            }
            field("Current Accepted Events"; "Current Accepted Events")
            {
                ApplicationArea = FOODBasic;
            }
            field("Current Frequency"; "Current Frequency")
            {
                ApplicationArea = FOODBasic;
            }
            field("No. of Test Activities"; "No. of Test Activities")
            {
                ApplicationArea = FOODBasic;
            }
            field("Test Status"; "Test Status")
            {
                ApplicationArea = FOODBasic;
            }
            field("Transaction Date"; "Transaction Date")
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(FindLast);
    end;
}

