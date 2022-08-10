page 37002038 "Lot Preference Age Subform"
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Lot age subform for lot preference forms
    // 
    // PRW15.00.02
    // P8000613A, VerticalSoft, Jack Reynolds, 18 JUL 08
    //   Resize to fit subform control on parent form
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 15 APR 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00
    // P8001132, Columbus IT, Jack Reynolds, 23 APR 13
    //   Upgrade for NAV 2013

    Caption = 'Lot Preference Age Subform';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Lot Age Filter";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("ID 2"; "ID 2")
                {
                    ApplicationArea = FOODBasic;
                    Visible = "ID2Visible";
                }
                field("Age Filter"; "Age Filter")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Category Filter"; "Category Filter")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }

    var
        [InDataSet]
        ID2Visible: Boolean;

    procedure SetID2Visible(flag: Boolean)
    begin
        ID2Visible := flag;
    end;

    procedure SetLink(TableID: Integer; Type: Integer; ID: Code[20]; ProdOrderLineNo: Integer; LineNo: Integer)
    begin
        // P8001132
        FilterGroup(4);
        SetRange("Table ID", TableID);
        SetRange(Type, Type);
        SetRange(ID, ID);
        SetRange("Prod. Order Line No.", ProdOrderLineNo);
        SetRange("Line No.", LineNo);
        FilterGroup(4);
    end;
}

