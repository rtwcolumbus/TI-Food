page 37002035 "Lot Specification Filters"
{
    // PR3.70.07
    // P8000153A, Myers Nissi, Jack Reynolds, 16 DEC 04
    //   To specify filters for lot specifications
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 30 JAN 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Lot Specification Filters';
    PageType = Worksheet;
    SourceTable = "Lot Specification Filter";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Data Element Code"; "Data Element Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Filter"; Filter)
                {
                    ApplicationArea = FOODBasic;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        LotSpecFns: Codeunit "Lot Specification Functions";
                    begin
                        if "Data Element Type" <> "Data Element Type"::"Lookup" then
                            exit(false);
                        exit(LotSpecFns.LotSpecLookup("Data Element Code", Text));
                    end;
                }
            }
        }
    }

    actions
    {
    }
}

