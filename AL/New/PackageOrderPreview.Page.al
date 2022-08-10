page 37002606 "Package Order Preview"
{
    // PRW15.00.02
    // P8000606A, VerticalSoft, Jack Reynolds, 17 JUN 08
    //   Add caption property
    // 
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

    Caption = 'Package Order Preview';
    Editable = false;
    PageType = List;
    SourceTable = "Process Order Request Line";
    SourceTableView = WHERE("Package BOM No." = FILTER(<> ''));

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
                    Visible = false;
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
                    Visible = false;
                }
                field("Process BOM No."; "Process BOM No.")
                {
                    ApplicationArea = FOODBasic;
                    LookupPageID = "Co-Product Process List";
                    TableRelation = "Production BOM Header" WHERE("Mfg. BOM Type" = CONST(Process),
                                                                   "Output Type" = CONST(Family));
                    Visible = false;
                }
                field("Process BOM Description"; "Process BOM Description")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field("Package BOM No."; "Package BOM No.")
                {
                    ApplicationArea = FOODBasic;
                    LookupPageID = "Package BOM List";
                }
                field("Finished Item No."; "Finished Item No.")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field("Finished Variant Code"; "Finished Variant Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Finished Item Description"; "Finished Item Description")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field("Package Quantity"; GetPackageQuantity())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Package Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field("Package Unit"; GetPackageUnits())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Package Unit';
                    Editable = false;
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

