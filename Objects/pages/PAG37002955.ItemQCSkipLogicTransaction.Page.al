page 37002955 "Item Q/C SkipLogic Transaction"
{
    // PRW111.00.01
    // P80037569, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Develop QC skip logic
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Item Q/C SkipLogic Transaction';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Item Quality Skip Logic Trans.";

    layout
    {
        area(content)
        {
            repeater(Control37002003)
            {
                Editable = false;
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Value Class"; "Value Class")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Activity Class"; "Activity Class")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Transaction Date"; "Transaction Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Test Status"; "Test Status")
                {
                    ApplicationArea = FOODBasic;
                }
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
                field("Rejected Level"; "Rejected Level")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        LookupMode := CurrPage.LookupMode; // P8001323
    end;

    var
        Text001: Label 'Nothing has been selected.';
        Text002: Label '%1 must be %2 for all containers.';
        ItemNo: Code[20];
        ItemDesc: Text[100];
        [InDataSet]
        LookupMode: Boolean;
        [InDataSet]
        InTransit: Boolean;
}

