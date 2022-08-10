page 37002185 "Sales Contract List"
{
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Sales Contracts';
    CardPageID = "Sales Contract Card";
    DataCaptionFields = "No.", Description;
    Editable = false;
    PageType = List;
    SourceTable = "Sales Contract";
    SourceTableView = SORTING("No.");
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sales Type"; "Sales Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sales Code"; "Sales Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Contract Limit"; "Contract Limit")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Contract Limit Unit of Measure"; "Contract Limit Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
                field(CalcLimitUsed; CalcLimitUsed)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Contract Limit Used';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }
}

