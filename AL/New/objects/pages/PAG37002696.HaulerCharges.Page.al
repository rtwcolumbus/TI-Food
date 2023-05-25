page 37002696 "Hauler Charges"
{
    // PRW16.00.04
    // P8000902, Columbus IT, Don Bresee, 14 MAR 11
    //   Add Commodity Payment logic

    Caption = 'Hauler Charges';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Hauler Charge";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Hauler No."; "Hauler No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Receiving Location Code"; "Receiving Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Producer Zone Code"; "Producer Zone Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Charge Unit Amount"; "Charge Unit Amount")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002008; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002007; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Receiving Location Code" := xRec."Receiving Location Code";
        "Unit of Measure Code" := xRec."Unit of Measure Code";
    end;
}

