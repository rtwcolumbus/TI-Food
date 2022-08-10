table 37002205 "Vendor Certification Type"
{
    // PRW17.10
    // P8001229, Columbus IT, Jack Reynolds, 04 OCT 13
    //   Vendor certifications
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Vendor Certification Type';
    LookupPageID = "Vendor Certification Types";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        VendorCertification.SetRange(Type, Code);
        if not VendorCertification.IsEmpty then
            Error(Text000, TableCaption, Code)
    end;

    var
        VendorCertification: Record "Vendor Certification";
        Text000: Label 'You cannot delete %1 %2 because there is at least one vendor certification for this type.';
}

