page 37002907 "Vendor Certs. by Vendor"
{
    // PRW17.10
    // P8001229, Columbus IT, Jack Reynolds, 04 OCT 13
    //   Vendor certifications

    Caption = 'Vendor Certifications';
    DataCaptionExpression = Caption;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Vendor Certification";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = FOODBasic;
                }
                field(GetTypeDescription; GetTypeDescription)
                {
                    ApplicationArea = FOODBasic;
                    Caption = 'Description';
                    QuickEntry = false;
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
            systempart(Control37002007; Links)
            {
                ApplicationArea = FOODBasic;
            }
            systempart(Control37002008; Notes)
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
        SourceType: Option;
    begin
        FilterGroup(3);
        SourceType := GetRangeMax("Source Type");
        FilterGroup(0);

        Caption := StrSubstNo(Text000, GetVendorNo, GetVendorName);
        if SourceType = "Source Type"::"Order Address" then
            Caption := Caption + ', ' + GetRangeMax("Order Address Code");
    end;

    var
        Text000: Label '%1 • %2';
        Caption: Text[100];
}

