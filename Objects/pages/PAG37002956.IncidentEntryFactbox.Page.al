page 37002956 "Incident Entry Factbox"
{
    Caption = 'Incident Entry';
    PageType = CardPart;
    SourceTable = "Incident Entry";

    layout
    {
        area(content)
        {
            field("Entry No."; "Entry No.")
            {
                ApplicationArea = FOODBasic;

                trigger OnAssistEdit()
                var
                    IncidentEntry: Record "Incident Entry";
                begin
                    IncidentEntry := Rec;
                    IncidentEntry.SetRecFilter;
                    PAGE.Run(PAGE::"Incident Entry Card", IncidentEntry);
                end;
            }
            field(Source; Format("Source Record ID"))
            {
                ApplicationArea = FOODBasic;
                Caption = 'Source';
            }
            field("Created By"; "Created By")
            {
                ApplicationArea = FOODBasic;
            }
            field("Created On"; "Created On")
            {
                ApplicationArea = FOODBasic;
            }
            field(Status; Status)
            {
                ApplicationArea = FOODBasic;
            }
            field(Archived; Archived)
            {
                ApplicationArea = FOODBasic;
            }
            field("Incident Classification"; "Incident Classification")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Classification';
                Lookup = false;
            }
            field("Incident Reason Code"; "Incident Reason Code")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Reason Code';
                Lookup = false;
            }
        }
    }

    actions
    {
    }
}

