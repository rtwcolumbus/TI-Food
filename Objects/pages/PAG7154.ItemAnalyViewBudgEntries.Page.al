page 7154 "Item Analy. View Budg. Entries"
{
    // PR5.00
    // P8000500A, VerticalSoft, Jack Reynolds, 02 AUG 07
    //   Add controls for alternate quantity
    // 
    // PRW16.00.05
    // P8000921, Columbus IT, Don Bresee, 09 APR 11
    //   Added "Sales Amount (FOB)" and "Sales Amount (Freight)" fields

    Caption = 'Analysis View Budget Entries';
    DataCaptionFields = "Analysis View Code";
    Editable = false;
    PageType = List;
    SourceTable = "Item Analysis View Budg. Entry";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Budget Name"; "Budget Name")
                {
                    ApplicationArea = ItemBudget;
                    ToolTip = 'Specifies the name of the budget that the analysis view budget entries are linked to.';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the code of the location to which the analysis view budget entry was posted.';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the item that the analysis view budget entry is linked to.';
                }
                field("Dimension 1 Value Code"; "Dimension 1 Value Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the dimension value you selected for the analysis view dimension that you defined as Dimension 1 on the analysis view card.';
                }
                field("Dimension 2 Value Code"; "Dimension 2 Value Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies which dimension value you have selected for the analysis view dimension that you defined as Dimension 2 on the analysis view card.';
                }
                field("Dimension 3 Value Code"; "Dimension 3 Value Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies which dimension value you have selected for the analysis view dimension that you defined as Dimension 1 on the analysis view card.';
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which the item budget entries in an analysis view budget entry were posted.';
                }
                field("Sales Amount"; "Sales Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item budget entry sales amount included in an analysis view budget entry.';

                    trigger OnDrillDown()
                    begin
                        DrillDown;
                    end;
                }
                field("Sales Amount (FOB)"; "Sales Amount (FOB)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Sales Amount (Freight)"; "Sales Amount (Freight)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Cost Amount"; "Cost Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item budget entry cost amount included in an analysis view budget entry.';

                    trigger OnDrillDown()
                    begin
                        DrillDown;
                    end;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item budget entry quantity included in an analysis view budget entry.';

                    trigger OnDrillDown()
                    begin
                        DrillDown;
                    end;
                }
                field("Quantity (Alt.)"; "Quantity (Alt.)")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        if "Analysis View Code" <> xRec."Analysis View Code" then;
    end;

    local procedure DrillDown()
    var
        ItemBudgetEntry: Record "Item Budget Entry";
    begin
        ItemBudgetEntry.SetRange("Entry No.", "Entry No.");
        PAGE.RunModal(0, ItemBudgetEntry);
    end;
}

