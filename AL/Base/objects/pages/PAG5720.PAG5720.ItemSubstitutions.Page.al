page 5720 "Item Substitutions"
{
    // PRW19.00.01
    // P8006959, To-Increase, Jack Reynolds, 02 NOV 16
    //   Allergens

    AutoSplitKey = false;
    Caption = 'Item Substitutions';
    DataCaptionFields = Interchangeable;
    Editable = false;
    PageType = List;
    SourceTable = "Item Substitution";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Substitute No."; Rec."Substitute No.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the number of the item that can be used as a substitute in case the original item is unavailable.';
                }
                field(Allergens; AllergenManagement.AllergenCodeForRecord(DATABASE::"Item Substitution", "Substitute Type", "Substitute No."))
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Allergens';
                    Style = StrongAccent;
                    StyleExpr = TRUE;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        // P8006959
                        AllergenManagement.AllergenDrilldownForRecord(DATABASE::"Item Substitution", "Substitute Type", "Substitute No.");
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the description of the substitute item.';
                }
                field(Interchangeable; Interchangeable)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies that the item and the substitute item are interchangeable.';
                }
                field(Condition; Condition)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that a condition exists for this substitution.';
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
        area(processing)
        {
            action("&Condition")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Condition';
                Image = ViewComments;
                RunObject = Page "Sub. Conditions";
                RunPageLink = Type = FIELD(Type),
                              "No." = FIELD("No."),
                              "Substitute Type" = FIELD("Substitute Type"),
                              "Substitute No." = FIELD("Substitute No.");
                ToolTip = 'Specify a condition for the item substitution, which is for information only and does not affect the item substitution.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("&Condition_Promoted"; "&Condition")
                {
                }
            }
        }
    }

    var
        AllergenManagement: Codeunit "Allergen Management";
}

