page 37002812 "Maintenance Trades"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   Standard list form for maintenance trades
    // 
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 30 JAN 09
    //   Transformed - additions in TIF Editor
    //   Page changes made after transformation
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Maintenance Trades';
    PageType = List;
    SourceTable = "Maintenance Trade";
    UsageCategory = Administration;

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
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("Internal Rate (Hourly)"; "Internal Rate (Hourly)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("External Rate (Hourly)"; "External Rate (Hourly)")
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
        area(navigation)
        {
            group("&Trades")
            {
                Caption = '&Trades';
                action("&Vendors")
                {
                    ApplicationArea = FOODBasic;
                    Caption = '&Vendors';
                    Image = Vendor;
                    RunObject = Page "Vendor / Maintenance Trades";
                    RunPageLink = "Trade Code" = FIELD(Code);
                    RunPageView = SORTING("Trade Code", "Vendor No.");
                }
            }
        }
    }
}

