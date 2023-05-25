page 37002476 "Production Costs Subpage"
{
    // PRW16.00.03
    // P8000790, VerticalSoft, Don Bresee, 17 MAR 10
    //   Redesign interface for NAV 2009
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW19.00.01
    // P8007742, To-Increase, Dayakar Battini, 11 OCT 16
    //   ? character removed from "Include In Cost Rollup?" field

    Caption = 'Production Costs Subpage';
    PageType = ListPart;
    SourceTable = "Prod. BOM Activity Cost";

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                FreezeColumn = Description;
                ShowCaption = false;
                field("Resource Type"; "Resource Type")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Resource No."; "Resource No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Resource Multiplier"; "Resource Multiplier")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                    Visible = false;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Extended Cost"; "Extended Cost")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Overhead Cost Ext"; "Overhead Cost Ext")
                {
                    ApplicationArea = FOODBasic;
                    Editable = false;
                }
                field("Include In Cost Rollup"; "Include In Cost Rollup")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Equipment No."; "Equipment No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                    Visible = false;
                }
                field("Routing Link Code"; "Routing Link Code")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    var
        [InDataSet]
        VersionEditable: Boolean;

    procedure SetEditable(Flag: Boolean)
    begin
        VersionEditable := Flag;
    end;
}

