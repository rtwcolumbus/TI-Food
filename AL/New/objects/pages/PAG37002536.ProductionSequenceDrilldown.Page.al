page 37002536 "Production Sequence Drilldown"
{
    // PRW16.00.04
    // P8000889, Columbus IT, Jack Reynolds, 02 MAR 11
    //   Drilldown for earliest/latest start time form Production Sequence

    Caption = 'Production Sequence Drilldown';
    Editable = false;
    PageType = List;
    SourceTable = "Production Sequencing";
    SourceTableView = SORTING("Equipment Code", Level, "Starting Date-Time", "Ending Date-Time");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Equipment Code"; "Equipment Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Order Status"; "Order Status")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Order No."; "Order No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = FOODBasic;
                }
                field("First Line Duration"; "First Line Duration")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Batch Duration';
                }
                field("Starting Date-Time"; "Starting Date-Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Ending Date-Time"; "Ending Date-Time")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(ShowOrder)
            {
                ApplicationArea = FOODBasic;
                Caption = 'Show Order';
                Image = "Order";

                trigger OnAction()
                begin
                    ShowOrder;
                end;
            }
        }
    }
}

