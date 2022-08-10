page 37002090 "Sales Line Lot Preferences"
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Lot age and specifications preferences for sales lines
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001070, Columbus IT, Jack Reynolds, 16 MAY 12
    //   Bring Lot Freshness and Lot Preferences together
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 23 APR 13
    //   Upgrade for NAV 2013

    Caption = 'Sales Line Lot Preferences';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Document;
    SourceTable = "Sales Line";

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
            group("Lot Freshness Preference")
            {
                Caption = 'Lot Freshness Preference';
                field(FreshnessDateText; FreshnessDateText)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Freshness Date';
                    Editable = OldestAcceptableEditable;
                }
                field("Oldest Accept. Freshness Date"; "Oldest Accept. Freshness Date")
                {
                    ApplicationArea = FOODBasic;
                    Editable = OldestAcceptableEditable;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.LotAgePref.PAGE.SetLink(DATABASE::"Sales Line", "Document Type", "Document No.", 0, "Line No.");  // P8001132
        CurrPage.LotSpecPref.PAGE.SetLink(DATABASE::"Sales Line", "Document Type", "Document No.", 0, "Line No."); // P8001132
    end;

    trigger OnAfterGetRecord()
    begin
        OldestAcceptableEditable := "Freshness Calc. Method" <> 0; // P8001070
    end;

    trigger OnOpenPage()
    begin
        CurrPage.LotAgePref.PAGE.SetID2Visible(false);
        CurrPage.LotSpecPref.PAGE.SetID2Visible(false);
    end;

    var
        [InDataSet]
        OldestAcceptableEditable: Boolean;
}

