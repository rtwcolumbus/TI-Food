page 37002039 "Customer Lot Preferences"
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Lot age and specifications preferences for customers
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 15 APR 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.04
    // P8000899, Columbus IT, Ron Davidson, 02 MAR 11
    //   Added the Lot Freshness Page as a part.
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00.01
    // P8001163, Columbus IT, Jack Reynolds, 30 MAY 13
    //   Fix problem with editing sub-pages

    Caption = 'Customer Lot Preferences';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = Customer;

    layout
    {
        area(content)
        {
            part(LotAgePref; "Lot Preference Age Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lot Age Preferences';
                SubPageLink = "Table ID" = CONST(18),
                              ID = FIELD("No.");
            }
            part(LotSpecPref; "Lot Preference Spec. Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lot Specification Preferences';
                SubPageLink = "Table ID" = CONST(18),
                              ID = FIELD("No.");
            }
            part(LotFresh; "Lot Freshness")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lot Freshness';
                SubPageLink = "Customer No." = FIELD("No.");
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        CurrPage.LotAgePref.PAGE.SetID2Visible(true);
        CurrPage.LotSpecPref.PAGE.SetID2Visible(true);
    end;
}

