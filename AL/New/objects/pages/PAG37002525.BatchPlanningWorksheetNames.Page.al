page 37002525 "Batch Planning Worksheet Names"
{
    // PRW16.00.04
    // P8000877, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Standard lsit page for Batch Planning Worksheet names
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names

    Caption = 'Batch Planning Worksheet Names';
    CardPageID = "Batch Planning Worksheet Name";
    PageType = List;
    SourceTable = "Batch Planning Worksheet Name";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Days View"; "Days View")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002006; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002005; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Edit Worksheet")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Edit Worksheet';
                Image = Edit;
                ShortCutKey = 'Return';

                trigger OnAction()
                begin
                    BPWorksheet."Worksheet Name" := Name;
                    PAGE.Run(PAGE::"Batch Planning Worksheet", BPWorksheet);
                end;
            }
        }
        area(Promoted)
        {
            actionref(EditWorksheet_Promoted; "Edit Worksheet")
            {
            }
        }
    }

    var
        BPWorksheet: Record "Batch Planning Worksheet Line";
}

