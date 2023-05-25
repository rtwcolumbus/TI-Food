page 37002037 "Lot Preference Spec. Subform"
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   Lot specification subform for lot preference forms
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
    // 
    // PRW111.00.01
    // P80037645, To-Increase, Dayakar Battini, 07 JUN 18
    //   QC-Additions: Add UOM/Measuring Method

    Caption = 'Lot Preference Spec. Subform';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Lot Specification Filter";

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
                field("Data Element Code"; "Data Element Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Data Element Type"; "Data Element Type")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Filter"; Filter)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if "Data Element Type" <> "Data Element Type"::"Lookup" then
                            exit(false);
                        exit(LotSpecFns.LotSpecLookup("Data Element Code", Text));
                    end;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Measuring Method"; "Measuring Method")
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
        LotSpecFns: Codeunit "Lot Specification Functions";
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

