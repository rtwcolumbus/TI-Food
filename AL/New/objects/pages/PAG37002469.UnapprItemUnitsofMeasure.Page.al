page 37002469 "Unappr Item Units of Measure"
{
    // PR1.00, Myers Nissi, Jack Reynolds, 30 JUL 00, PR007
    //   Standard tabular lookup form for Unapproved Units of Measure
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 02 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Unappr Item Units of Measure';
    DataCaptionFields = "Unapproved Item No.";
    PageType = List;
    SourceTable = "Unappr. Item Unit of Measure";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Unapproved Item No."; "Unapproved Item No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. per Unit of Measure"; "Qty. per Unit of Measure")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnValidate()
                    begin
                        QtyperUnitofMeasureOnAfterVali;
                    end;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    local procedure QtyperUnitofMeasureOnAfterVali()
    begin
        CurrPage.Update;
    end;
}

