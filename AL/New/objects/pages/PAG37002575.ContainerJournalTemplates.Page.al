page 37002575 "Container Journal Templates"
{
    // PR3.70.07
    // P8000140A, Myers Nissi, Jack Reynolds, 19 NOV 04
    //   Standard list form for container journal templates
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 02 FEB 09
    //   Transformed - additions in TIF Editor
    // P8000782, VerticalSoft, Rick Tweedle, 02 MAR 10
    //   Transformed to Page using transfor tool
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 17 NOV 15
    //   Image property for Batches actions
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Container Journal Templates';
    PageType = List;
    SourceTable = "Container Journal Template";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field(Name; Name)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Source Code"; "Source Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Page ID"; "Page ID")
                {
                    ApplicationArea = FOODBasic;
                    LookupPageID = Objects;
                    Visible = false;
                }
                field("Page Caption"; "Page Caption")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                    Visible = false;
                }
                field("Test Report ID"; "Test Report ID")
                {
                    ApplicationArea = FOODBasic;
                    LookupPageID = Objects;
                    Visible = false;
                }
                field("Test Report Caption"; "Test Report Caption")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                    Visible = false;
                }
                field("Posting Report ID"; "Posting Report ID")
                {
                    ApplicationArea = FOODBasic;
                    LookupPageID = Objects;
                    Visible = false;
                }
                field("Posting Report Caption"; "Posting Report Caption")
                {
                    ApplicationArea = FOODBasic;
                    DrillDown = false;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Te&mplate")
            {
                Caption = 'Te&mplate';
                action(Batches)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Batches';
                    Image = Description;
                    RunObject = Page "Container Journal Batches";
                    RunPageLink = "Journal Template Name" = FIELD(Name);
                }
            }
        }
    }
}

