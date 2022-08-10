page 37002480 "Production Forecast List"
{
    // PR1.00  Myers Nissi, Roelof de Jong, 11 NOV 00, PR014
    //   Create new form to list Itemforecast as drilldown on Page 37002472 (Item Forecast).
    // 
    // PR1.20
    //   Rename from Item Forecast List
    // 
    // PR2.00.05
    //   Add variant code
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 02 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Item Forecast Entries';
    Editable = false;
    PageType = List;
    SourceTable = "Production Forecast";
    SourceTableView = SORTING("Item No.", "Variant Code", Date, "Location Code");

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                Editable = false;
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Date; Date)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
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
}

