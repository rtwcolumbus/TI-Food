page 37002061 "Delivery Route List"
{
    // PR3.60
    //   Delivery Routing
    // 
    // PR3.70.06
    // P8000079A, Myers Nissi, Jack Reynolds, 16 SEP 04
    //   Add check boxes for days of week
    // 
    // PRW15.00.01
    // P8000547A, VerticalSoft, Jack Reynolds, 02 MAY 08
    //   Add Locationcode, rearrange day of week columns
    // 
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Support for picker assignments
    // 
    // PRW15.00.02
    // P8000603A, VerticalSoft, Jack Reynolds, 05 JUN 08
    //   Remove Delivery Route REeview from the Route menu button
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 20 JUL 09
    //   Transformed from Form
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW111.00
    // P80053245, To Increase, Jack Reynolds, 23 MAR 18
    //   Upgrade for NAV 2018
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Delivery Routes';
    CardPageID = "Delivery Route Card";
    Editable = false;
    PageType = List;
    SourceTable = "Delivery Route";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control37002001)
            {
                ShowCaption = false;
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
                    Visible = false;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Monday; Monday)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'M';
                }
                field(Tuesday; Tuesday)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'T';
                }
                field(Wednesday; Wednesday)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'W';
                }
                field(Thursday; Thursday)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'T';
                }
                field(Friday; Friday)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'F';
                }
                field(Saturday; Saturday)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'S';
                }
                field(Sunday; Sunday)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'S';
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
                    RunObject = Page "Posted Delivery Route Review";
                    RunPageLink = "Delivery Route No." = FIELD("No.");
                }
            }
        }
    }
}

