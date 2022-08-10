page 37002093 "PO Component Lot Preferences"
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Lot age and specifications preferences for production order components
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 23 APR 13
    //   Upgrade for NAV 2013

    Caption = 'Prod. Order Component Lot Preferences';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Prod. Order Component";

    layout
    {
        area(content)
        {
            part(LotAgePref; "Lot Preference Age Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lot Age Preferences';
            }
            part(LotSpecPref; "Lot Preference Spec. Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lot Specification Preferences';
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.LotAgePref.PAGE.SetLink(DATABASE::"Prod. Order Component", Status, "Prod. Order No.", "Prod. Order Line No.", "Line No.");  // P8001132
        CurrPage.LotSpecPref.PAGE.SetLink(DATABASE::"Prod. Order Component", Status, "Prod. Order No.", "Prod. Order Line No.", "Line No."); // P8001132
    end;

    trigger OnOpenPage()
    begin
        CurrPage.LotAgePref.PAGE.SetID2Visible(false);
        CurrPage.LotSpecPref.PAGE.SetID2Visible(false);
    end;
}

