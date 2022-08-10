page 37002780 "Clear Bin History Entries"
{
    Caption = 'Clear Bin History Entries';
    DataCaptionFields = "Bin Code";
    Editable = false;
    PageType = List;
    SourceTable = "Clear Bin History";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Date/Time"; "Date/Time")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Item Entry No."; "Item Entry No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Whse. Entry No."; "Whse. Entry No.")
                {
                    ApplicationArea = FOODBasic;
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

