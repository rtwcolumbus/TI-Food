page 37002588 "Pre-Process Repl. Areas"
{
    // PRW16.00.06
    // P8001082, Columbus IT, Don Bresee, 23 JAN 13
    //   Add Pre-Process functionality

    Caption = 'Pre-Process Repl. Areas';
    DataCaptionFields = "Location Code";
    PageType = List;
    SourceTable = "Replenishment Area";
    SourceTableView = WHERE("Pre-Process Repl. Area" = CONST(true));

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
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Pre-Process Repl. Area" := true;
    end;

    trigger OnOpenPage()
    begin
        CurrPage.Editable(not CurrPage.LookupMode);
    end;
}

