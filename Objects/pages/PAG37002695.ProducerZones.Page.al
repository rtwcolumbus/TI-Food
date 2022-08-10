page 37002695 "Producer Zones"
{
    // PRW16.00.04
    // P8000902, Columbus IT, Don Bresee, 14 MAR 11
    //   Add Commodity Payment logic
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Producer Zones';
    PageType = List;
    SourceTable = "Producer Zone";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002007; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002006; Notes)
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
            action("Hauler Charges")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Hauler Charges';
                Image = ProjectExpense;
                RunObject = Page "Hauler Charges";
                RunPageLink = "Producer Zone Code" = FIELD(Code);
                RunPageView = SORTING("Hauler No.", "Producer Zone Code", "Receiving Location Code");
            }
        }
    }

    trigger OnOpenPage()
    begin
        CurrPage.Editable(not CurrPage.LookupMode);
    end;
}

