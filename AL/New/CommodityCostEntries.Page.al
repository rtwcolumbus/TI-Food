page 37002684 "Commodity Cost Entries"
{
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 03 NOV 10
    //   Add Commodity Class Costing granule

    Caption = 'Commodity Cost Entries';
    Editable = false;
    PageType = List;
    SourceTable = "Commodity Cost Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Comm. Class Period Entry No."; "Comm. Class Period Entry No.")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Commodity Class Code"; "Commodity Class Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Comm. Cost Component Code"; "Comm. Cost Component Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("GetDescription()"; GetDescription())
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                }
                field("Component Value"; "Component Value")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Entry Date"; "Entry Date")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
    }

    actions
    {
    }
}

