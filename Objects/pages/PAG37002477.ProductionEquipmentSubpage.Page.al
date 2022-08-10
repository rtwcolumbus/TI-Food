page 37002477 "Production Equipment Subpage"
{
    // PRW16.00.03
    // P8000790, VerticalSoft, Don Bresee, 17 MAR 10
    //   Redesign interface for NAV 2009
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001107, Columbus IT, Don Bresee, 19 OCT 12
    //   Add Minimum Equipment Qty. field

    Caption = 'Production Equipment Subpage';
    PageType = ListPart;
    SourceTable = "Prod. BOM Equipment";

    layout
    {
        area(content)
        {
            repeater(Control37002003)
            {
                Editable = VersionEditable;
                FreezeColumn = Description;
                ShowCaption = false;
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
                field(Preference; Preference)
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Routing No."; "Routing No.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                    Visible = false;
                }
                field("Equipment Capacity"; "Equipment Capacity")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Capacity Level %"; "Capacity Level %")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Net Capacity"; "Net Capacity")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Minimum Equipment Qty."; "Minimum Equipment Qty.")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Fixed Prod. Time (Hours)"; "Fixed Prod. Time (Hours)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
                field("Variable Prod. Time (Hours)"; "Variable Prod. Time (Hours)")
                {
                    ApplicationArea = FOODBasic;
                    Editable = VersionEditable;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Routing)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Routing';
                Image = Route;

                trigger OnAction()
                begin
                    DisplayRouting;
                end;
            }
        }
    }

    var
        [InDataSet]
        VersionEditable: Boolean;

    procedure SetEditable(Flag: Boolean)
    begin
        VersionEditable := Flag;
    end;

    procedure DisplayRouting()
    var
        RoutingHeader: Record "Routing Header";
        RoutingForm: Page Routing;
    begin
        if ("Routing No." = '') then
            exit;

        RoutingHeader.FilterGroup(9);
        RoutingHeader.SetRange("No.", "Routing No.");
        RoutingHeader.FilterGroup(0);

        RoutingForm.SetTableView(RoutingHeader);
        RoutingForm.RunModal;
    end;
}

