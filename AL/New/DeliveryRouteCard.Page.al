page 37002060 "Delivery Route Card"
{
    // PR3.60
    //   Delivery Routing
    // 
    // PR3.70.06
    // P8000079A, Myers Nissi, Jack Reynolds, 16 SEP 04
    //   Add tab for Weekly Schedule with check boxes for days of week
    // 
    // PRW15.00.01
    // P8000547A, VerticalSoft, Jack Reynolds, 02 MAY 08
    //   Additional defaults and subform for day of week data
    // 
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Support for picker assignments
    // 
    // PRW15.00.02
    // P8000603A, VerticalSoft, Jack Reynolds, 05 JUN 08
    //   Remove Delivery Route REeview from the Route menu button
    // 
    // P8000613A, VerticalSoft, Jack Reynolds, 23 JUL 08
    //   Move weekly schedule subform off of tab page and onto main form
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 20 JUL 09
    //   Transformed from Form
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW17.00.01
    // P8001194, Columbus IT, Jack Reynolds, 27 AUG 13
    //    Fix promoted action categories
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018

    Caption = 'Delivery Route Card';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Route';
    SourceTable = "Delivery Route";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Location Code"; "Location Code")
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
            part(Schedule; "Delivery Route Sched. Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Schedule';
                SubPageLink = "Delivery Route No." = FIELD("No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Route")
            {
                Caption = '&Route';
                action("Posted Route Review")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Posted Route Review';
                    Image = Route;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "Posted Delivery Route Review";
                    RunPageLink = "Delivery Route No." = FIELD("No.");
                }
            }
        }
    }
}

