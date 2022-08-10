page 37002066 "Delivery Truck List"
{
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 03 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW111.00.02
    // P80072282, To-Increase, Gangabhushan, 02 APR 19
    //   TI-13063 - Delivery Trip Truck does not allow for setup of the truck ids
    //   Changed page property Editable to <Yes>

    ApplicationArea = FOODBasic;
    Caption = 'Delivery Trucks';
    PageType = List;
    SourceTable = "Delivery Truck";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Internal No."; "Internal No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("License Plate"; "License Plate")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Link to Asset"; "Link to Asset")
                {
                    ApplicationArea = FOODBasic;
                    Visible = MaintenanceInstalled;
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

    trigger OnOpenPage()
    begin
        MaintenanceInstalled := Process800Functions.MaintenanceInstalled;
    end;

    var
        Process800Functions: Codeunit "Process 800 Functions";
        MaintenanceInstalled: Boolean;
}

