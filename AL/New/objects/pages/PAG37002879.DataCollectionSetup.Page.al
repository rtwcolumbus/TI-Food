page 37002879 "Data Collection Setup"
{
    // PRW16.00.06
    // P8001090, Columbus IT, Jack Reynolds, 07 DEC 12
    //   Process Data Collection
    // 
    // PRW17.00.01
    // P8001162, Columbus IT, Jack Reynolds, 24 MAY 13
    //   Remove "Alert Gen. Interval (Minutes)"
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    ApplicationArea = FOODBasic;
    Caption = 'Data Collection Setup';
    PageType = Card;
    SourceTable = "Data Collection Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Data Sheet Nos."; "Data Sheet Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                group(Control37002008)
                {
                    ShowCaption = false;
                    field("Critical Alert Response Time"; "Critical Alert Response Time")
                    {
                        ApplicationArea = FOODBasic;
                    }
                    field("Critical Alert Group"; "Critical Alert Group")
                    {
                        ApplicationArea = FOODBasic;
                    }
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002004; Links)
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
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Initialize; // P80073095
            Insert;
        end;
    end;
}

