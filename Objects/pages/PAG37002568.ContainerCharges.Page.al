page 37002568 "Container Charges"
{
    // PRW16.00.02
    // P8000782, VerticalSoft, Rick Tweedle, 02 MAR 10
    //   Transformed to Page using transfor tool
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Container Charges';
    PageType = List;
    SourceTable = "Container Charge";
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
                field("Account No."; "Account No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = FOODBasic;
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
            group(Charge)
            {
                Caption = 'Charge';
                action("Container Types")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Container Types';
                    Image = Inventory;
                    RunObject = Page "Container Type Charges";
                    RunPageLink = "Container Charge Code" = FIELD(Code);
                    RunPageView = SORTING("Container Charge Code", "Container Type Code");
                }
            }
        }
    }
}

