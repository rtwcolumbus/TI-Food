page 37002908 "Vendor Certifications"
{
    // PRW17.10
    // P8001229, Columbus IT, Jack Reynolds, 04 OCT 13
    //   Vendor certifications
    // 
    // PRW113.00
    // P80066030, To Increase, Jack Reynolds, 13 DEC 18
    //   Upgrade to 13.00

    ApplicationArea = FOODBasic;
    Caption = 'Vendor Certifications';
    Editable = false;
    PageType = List;
    SourceTable = "Vendor Certification";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = FOODBasic;
                }
                field(GetVendorName; GetVendorName)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Vendor Name';
                }
                field("Order Address Code"; "Order Address Code")
                {
                    ApplicationArea = FOODBasic;
                }
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field(GetTypeDescription; GetTypeDescription)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                }
                field("Effective Date"; "Effective Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Expiration Date"; "Expiration Date")
                {
                    ApplicationArea = FOODBasic;
                }
                field("Certificate No."; "Certificate No.")
                {
                    ApplicationArea = FOODBasic;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control37002010; Links)
            {
                ApplicationArea = FOODBasic;
            }
            systempart(Control37002011; Notes)
            {
                ApplicationArea = FOODBasic;
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

