page 37002077 "Pickup Load List"
{
    // PR3.70.06
    //   P8000080A, Myers Nissi, Steve Post, 30 AUG 04
    //     For Pickup Load Planning
    // 
    // PRW15.00.01
    // P8000549A, VerticalSoft, Jack Reynolds, 04 MAY 08
    //   Add controls for Location Code and Delivery Trip No.
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Pickup Loads';
    CardPageID = "Pickup Load";
    Editable = false;
    PageType = List;
    SourceTable = "Pickup Load Header";
    UsageCategory = Lists;

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
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Status; Status)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Carrier; Carrier)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Delivery Trip No."; "Delivery Trip No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pickup Date"; "Pickup Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Temperature; Temperature)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Freight Charge"; "Freight Charge")
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

