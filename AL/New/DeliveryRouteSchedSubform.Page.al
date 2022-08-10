page 37002321 "Delivery Route Sched. Subform"
{
    // PRW15.00.01
    // P8000547A, VerticalSoft, Jack Reynolds, 02 MAY 08
    //   Schedule subform for delivery route card
    // 
    // PRW15.00.02
    // P8000613A, VerticalSoft, Jack Reynolds, 23 JUL 08
    //   Resize to fit subform control on parent form

    Caption = 'Delivery Route Sched. Subform';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Delivery Route Schedule";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Day of Week"; "Day of Week")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Default Driver No."; "Default Driver No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Default Driver Name"; "Default Driver Name")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                }
                field("Default Truck ID"; "Default Truck ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Default Departure Time"; "Default Departure Time")
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

