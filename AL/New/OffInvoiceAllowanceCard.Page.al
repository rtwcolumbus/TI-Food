page 37002050 "Off-Invoice Allowance Card"
{
    // P8000008A 08-28-03 Mark Amison, MNC
    //   Off-Invoice Allowance
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs

    Caption = 'Off-Invoice Allowance Card';
    PageType = ListPlus;
    SourceTable = "Off-Invoice Allowance Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = FOODBasic;
                }
                field(Description; Description)
                {
                    ApplicationArea = FOODBasic;
                }
                field("G/L Account"; "G/L Account")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            part(Lines; "Off-Invoice Allowance Subform")
            {
                ApplicationArea = FOODBasic;
                Caption = 'Lines';
                SubPageLink = "Allowance Code" = FIELD(Code);
            }
        }
    }

    actions
    {
    }
}

