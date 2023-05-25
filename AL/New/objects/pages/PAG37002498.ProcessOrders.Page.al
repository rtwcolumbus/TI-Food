page 37002498 "Process Orders"
{
    // PR1.20
    //   Lookup list for process orders
    // 
    // PR3.10
    //   New Production Order table
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 02 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Process Orders';
    Editable = false;
    PageType = List;
    SourceTable = "Production Order";
    SourceTableView = SORTING(Status, "Order Type", "No.")
                      WHERE(Status = CONST(Released),
                            "Order Type" = CONST(Process));

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Input Item No."; "Input Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(InputItemDescription; InputItemDescription)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Input Item Description';
                }
                field(InputQuantity; InputQuantity)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Input Quantity';
                }
                field(InputUOM; InputUOM)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Input Unit of Measure';
                }
                field(InputLotNo; InputLotNo)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Input Lot No.';
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Output Item No.';
                    Visible = false;
                }
                field(OutputItemDescription; OutputItemDescription)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Output Item Description';
                    Visible = false;
                }
                field(OutputQuantity; OutputQuantity)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Output Quantity';
                    Visible = false;
                }
                field(OutputUOM; OutputUOM)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Output Unit of Measure';
                    Visible = false;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
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

