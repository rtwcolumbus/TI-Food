page 37002074 "Pickup Locations"
{
    // PR3.70.06
    //   P8000080A, Myers Nissi, Steve Post, 30 AUG 04
    //     For Pickup Load Planning
    // 
    // PRW16.00.03
    // P8000824, VerticalSoft, Jack Reynolds, 10 MAY 10
    //   Remove North American localizations
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jimmy Abidi, 03 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    Caption = 'Pickup Locations';
    DataCaptionFields = "Vendor No.";
    PageType = List;
    SourceTable = "Pickup Location";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Name; Name)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Name 2"; "Name 2")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(Address; Address)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Address 2"; "Address 2")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field(City; City)
                {
                    ApplicationArea = FOODBasic;
                }
                field(County; County)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900000003; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control1900000004; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        CurrPage.Editable := not CurrPage.LookupMode;
    end;
}

