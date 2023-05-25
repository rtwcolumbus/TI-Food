page 37002800 "Maintenance Setup"
{
    // PR4.00.04
    // P8000333A, VerticalSoft, Jack Reynolds, 31 AUG 06
    //   Standard setup card form for maintenace setup
    // 
    // P8000335A, VerticalSoft, Jack Reynolds, 20 SEP 06
    //   Add controls for default material and contract account
    // 
    // PRW15.00.01
    // P8000590A, VerticalSoft, Jack Reynolds, 07 MAR 08
    //   Add controls for Asset Usage Tolerance (%)
    // 
    // PRW16.00.06
    // P8001009, Columbus IT, Jack Reynolds, 03 JAN 12
    //   Update Control IDs
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Maintenance Setup';
    PageType = Card;
    SourceTable = "Maintenance Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Default Work Order Status"; "Default Work Order Status")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Default Work Order Priority"; "Default Work Order Priority")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Default PM Order Status"; "Default PM Order Status")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Default PM Priority"; "Default PM Priority")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Asset Usage Tolerance (%)"; "Asset Usage Tolerance (%)")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Doc. No. is Work Order No."; "Doc. No. is Work Order No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Employee Mandatory"; "Employee Mandatory")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Vendor Mandatory"; "Vendor Mandatory")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Posting Grace Period"; "Posting Grace Period")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Asset Nos."; "Asset Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Work Order Nos."; "Work Order Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
                field("PM Order Nos."; "PM Order Nos.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
            group(Purchasing)
            {
                Caption = 'Purchasing';
                field("Default Material Account"; "Default Material Account")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Default Contract Account"; "Default Contract Account")
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
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
    end;
}

