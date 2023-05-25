page 37002680 "Commodity Classes"
{
    // PRW16.00.04
    // P8000856, VerticalSoft, Don Bresee, 03 NOV 10
    //   Add Commodity Class Costing granule
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Commodity Classes';
    PageType = List;
    SourceTable = "Commodity Class";
    UsageCategory = Lists;

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
                field("No. of Cost Components"; "No. of Cost Components")
                {
                    ApplicationArea = FOODBasic;

                    trigger OnDrillDown()
                    var
                        CommCostSetup: Record "Comm. Cost Setup Line";
                    begin
                        CurrPage.SaveRecord;
                        Commit;
                        CommCostSetup.FilterGroup(2);
                        CommCostSetup.SetRange("Commodity Class Code", Code);
                        CommCostSetup.FilterGroup(0);
                        PAGE.RunModal(0, CommCostSetup);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002006; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002005; Notes)
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
            action("&Components")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Components';
                Ellipsis = true;
                Image = Components;
                RunObject = Page "Comm. Class Cost Components";
                RunPageLink = "Commodity Class Code" = FIELD(Code);
                RunPageView = SORTING("Commodity Class Code", "Comm. Cost Component Code");
            }
        }
    }
}

