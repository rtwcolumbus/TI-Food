page 37002940 "Incident Resolution Factbox"
{
    // PRW111.00.01
    // P80036649, To-Increase, Jack Reynolds, 25 JUL 18
    //   QC-Additions: Incident/Complaint Registration

    Caption = 'Resolutions';
    PageType = ListPart;
    SourceTable = "Incident Resolution Entry";

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Active; Active)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Resolution Reason Code"; "Resolution Reason Code")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Reason Code';
                }
                field(Accept; Accept)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Archived; Archived)
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

