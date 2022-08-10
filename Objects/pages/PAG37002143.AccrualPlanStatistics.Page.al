page 37002143 "Accrual Plan Statistics"
{
    // PR3.70.10
    // P8000241A, Myers Nissi, Jack Reynolds, 29 AUG 05
    //   Accrual enhancements
    // 
    // PR4.00.02
    // P8000292A, VerticalSoft, Jack Reynolds, 10 FEB 06
    //   Remove unnecessary local variables
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 02 NOV 09
    //   Transformed from Form
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Accrual Plan Statistics';
    DataCaptionExpression = StrSubstNo(Text000, Type, "No.", Name);
    Editable = false;
    PageType = Card;
    SourceTable = "Accrual Plan";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Name; Name)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Plan Type"; "Plan Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Accrual Amount"; "Accrual Amount")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Payment Amount"; "Payment Amount")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Balance; Balance)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Computation Level"; "Computation Level")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Accrue; Accrue)
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(SubForm; "Accrual Plan Stats. Subform")
            {
                ApplicationArea = FOODBasic;
                SubPageLink = "Accrual Plan Type" = FIELD(Type),
                              "Accrual Plan No." = FIELD("No."),
                              "Source No." = FIELD("Source Filter"),
                              "Item No." = FIELD("Item Filter"),
                              "Posting Date" = FIELD("Date Filter");
                SubPageView = SORTING("Accrual Plan Type", "Accrual Plan No.", "Source No.", "Entry Type", Type, "No.", "Item No.", "Posting Date");
            }
        }
    }

    actions
    {
    }

    var
        Text000: Label '%1 Plan %2 %3';
}

