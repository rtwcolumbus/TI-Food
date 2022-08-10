page 37002092 "BOM Line Lot Preferences"
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Lot age and specifications preferences for BOM lines
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00.01
    // P8001163, Columbus IT, Jack Reynolds, 30 MAY 13
    //   Fix problem with editing sub-pages

    Caption = 'BOM Line Lot Preferences';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Production BOM Line";

    layout
    {
        area(content)
        {
            part(LotAgePref; "Lot Preference Age Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lot Age Preferences';
                SubPageLink = "Table ID" = CONST(99000772),
                              ID = FIELD("Production BOM No."),
                              "ID 2" = FIELD("Version Code"),
                              "Line No." = FIELD("Line No.");
            }
            part(LotSpecPref; "Lot Preference Spec. Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lot Specification Preferences';
                SubPageLink = "Table ID" = CONST(99000772),
                              ID = FIELD("Production BOM No."),
                              "ID 2" = FIELD("Version Code"),
                              "Line No." = FIELD("Line No.");
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        CurrPage.LotAgePref.PAGE.SetID2Visible(false);
        CurrPage.LotSpecPref.PAGE.SetID2Visible(false);
    end;
}

