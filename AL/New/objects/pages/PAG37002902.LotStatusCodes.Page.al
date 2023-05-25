page 37002902 "Lot Status Codes"
{
    // PRW16.00.06
    // P8001083, Columbus IT, Jack Reynolds, 07 AUG 12
    //   Support for Lot Status
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Lot Status Codes';
    PageType = List;
    SourceTable = "Lot Status Code";
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
                field("Available for Sale"; "Available for Sale")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Available for Purchase"; "Available for Purchase")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Available for Transfer"; "Available for Transfer")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Available for Consumption"; "Available for Consumption")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Available for Adjustment"; "Available for Adjustment")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Available for Planning"; "Available for Planning")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002011; Links)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
            systempart(Control37002012; Notes)
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
    var
        InvSetup: Record "Inventory Setup";
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;

            if Process800Fns.QCInstalled then begin
                Code := Text001;
                Description := Text002;
                "Available for Sale" := false;
                "Available for Consumption" := false;
                Insert;

                InvSetup.Get;
                InvSetup."Quarantine Lot Status" := Text001;
                InvSetup.Modify;
            end;

            Get;
        end;
    end;

    var
        Process800Fns: Codeunit "Process 800 Functions";
        Text001: Label 'QUARANTINE';
        Text002: Label 'Quality Control Quarantine';
}

