page 37002004 "Proper Shipping Names"
{
    // PRW16.00.20
    // P8000664, VerticalSoft, Jack Reynolds, 02 FEB 09
    //   Transformed - additions in TIF Editor
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Proper Shipping Names';
    PageType = List;
    SourceTable = "Proper Shipping Name";
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
                field("Proper Shipping Name"; "Proper Shipping Name")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Hazard Class"; "Hazard Class")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Hazardous; Hazardous)
                {
                    ApplicationArea = FOODBasic;
                }
                field("DOT ID"; "DOT ID")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Packaging Group"; "Packaging Group")
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
    }

    trigger OnOpenPage()
    begin
        if CurrPage.LookupMode then
            CurrPage.Editable(false);
    end;
}

