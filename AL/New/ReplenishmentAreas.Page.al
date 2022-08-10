page 37002770 "Replenishment Areas"
{
    // PR5.00
    // P8000494A, VerticalSoft, Don Bresee, 18 JUL 07
    //   Add Production Bins/Replenishment
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Add Pre-Process functionality

    Caption = 'Replenishment Areas';
    DataCaptionFields = "Location Code";
    PageType = List;
    SourceTable = "Replenishment Area";

    layout
    {
        area(content)
        {
            repeater(Control37002000)
            {
                ShowCaption = false;
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = FOODBasic;
                    Visible = false;
                }
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("To Bin Code"; "To Bin Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("From Bin Code"; "From Bin Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Pre-Process Repl. Area Code"; "Pre-Process Repl. Area Code")
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
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Repl. Area")
            {
                Caption = '&Repl. Area';
                action("Item Replenishment Areas")
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Item Replenishment Areas';
                    Image = ItemAvailbyLoc;
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    RunObject = Page "Item Replenishment Areas";
                    RunPageLink = "Location Code" = FIELD("Location Code"),
                                  "Replenishment Area Code" = FIELD(Code);
                    RunPageView = SORTING("Location Code", "Replenishment Area Code");
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CurrPage.Editable(not CurrPage.LookupMode);
    end;
}

