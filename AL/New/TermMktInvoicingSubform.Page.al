page 37002665 "Term. Mkt. Invoicing Subform"
{
    // PR3.70.10
    // P8000237A, Myers Nissi, Jack Reynolds, 04 AUG 05
    //   Add controls to display Variant Code
    // 
    // PRW16.00.03
    // P8000817, VerticalSoft, Jack Reynolds, 26 APR 10
    //   Change visible property of fields
    // 
    // P8000828, VerticalSoft, Don Bresee, 03 JUN 10
    //   Consolidate timer logic
    // 
    // PRW16.00.05
    // P8000944, Columbus IT, Jack Reynolds, 31 MAY 11
    //   Support for enahnced terminal market order entry
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names

    Caption = 'Term. Mkt. Invoicing Subform';
    PageType = ListPart;
    SourceTable = "Sales Line";

    layout
    {
        area(content)
        {
            repeater(Control37002003)
            {
                Editable = false;
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Country/Region of Origin Code"; "Country/Region of Origin Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Quantity Invoiced"; "Quantity Invoiced")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. Invoiced (Alt.)"; "Qty. Invoiced (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. to Invoice"; "Qty. to Invoice")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Qty. to Invoice (Alt.)"; "Qty. to Invoice (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Line Dimensions")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Line Dimensions';
                Image = Dimensions;
                ShortCutKey = 'Shift+Ctrl+D';

                trigger OnAction()
                begin
                    Rec.ShowDimensions;
                end;
            }
        }
    }
}

