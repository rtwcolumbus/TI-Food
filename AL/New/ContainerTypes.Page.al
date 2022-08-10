page 37002592 "Container Types"
{
    // P8001373, To-Increase, Dayakar Battini, 11 Feb 15
    //   Support containers for purchase returns.
    // 
    // PRW19.00
    // P8004516, To-Increase, Jack Reynolds, 19 NOV 15
    //   Cleanup action names
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Container Types';
    CardPageID = "Container Type Card";
    Editable = false;
    PageType = List;
    SourceTable = "Container Type";
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
                field("Track Inventory"; TrackInventory())
                {
                    ApplicationArea = FOODBasic;
                }
                field("Maintain Inventory Value"; "Maintain Inventory Value")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Serializable; IsSerializable())
                {
                    ApplicationArea = FOODBasic;
                }
                field("Container Item No."; "Container Item No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Setup Level"; "Setup Level")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002009; Links)
            {
                ApplicationArea = FOODBasic;
            }
            systempart(Control37002010; Notes)
            {
                ApplicationArea = FOODBasic;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("&Charges")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Charges';
                Enabled = ChargesEnabled;
                Image = ItemCosts;
                RunObject = Page "Container Type Charges";
                RunPageLink = "Container Type Code" = FIELD(Code);
            }
            action("&Labels")
            {
                ApplicationArea = FOODBasic;
                Caption = '&Labels';
                Image = Text;
                RunObject = Page "Container Labels";
                RunPageLink = "Source Type" = CONST(37002578),
                              "Source No." = FIELD(Code);
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        ChargesEnabled := "Container Item No." <> ''; // P8001305
    end;

    var
        [InDataSet]
        ChargesEnabled: Boolean;
}

