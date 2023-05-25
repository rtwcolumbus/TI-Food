page 37002605 "Process Order Preview"
{
    // PRW16.00.03
    // P8000793, VerticalSoft, Don Bresee, 17 MAR 10
    //   Add LookupFormID for BOM fields
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001092, Columbus IT, Don Bresee, 17 OCT 12
    //   Add Variant Code

    Caption = 'Process Order Preview';
    Editable = false;
    PageType = List;
    SourceTable = "Process Order Request Line";
    SourceTableView = WHERE("Package BOM No." = FILTER(''));

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
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
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Process BOM No."; "Process BOM No.")
                {
                    ApplicationArea = FOODBasic;
                    LookupPageID = "Co-Product Process List";
                    TableRelation = "Production BOM Header" WHERE("No." = FIELD("Process BOM No."),
                                                                   "Mfg. BOM Type" = CONST(Process),
                                                                   "Output Type" = CONST(Family));
                }
                field("Process BOM Description"; "Process BOM Description")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
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

