table 37002206 "Vendor Certification"
{
    // PRW17.10
    // P8001229, Columbus IT, Jack Reynolds, 04 OCT 13
    //   Vendor certifications
    // 
    // PRW114.00
    // P80073095, To Increase, Jack Reynolds, 12 JUN 19
    //   Upgrade to 14.00

    Caption = 'Vendor Certification';

    fields
    {
        field(1; "Source Type"; Option)
        {
            Caption = 'Source Type';
            OptionCaption = 'Vendor,Order Address';
            OptionMembers = Vendor,"Order Address";
        }
        field(2; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            NotBlank = true;
            TableRelation = Vendor;
        }
        field(3; "Order Address Code"; Code[10])
        {
            Caption = 'Order Address Code';
            TableRelation = IF ("Source Type" = CONST("Order Address")) "Order Address".Code WHERE("Vendor No." = FIELD("Vendor No."));
        }
        field(4; Type; Code[10])
        {
            Caption = 'Type';
            NotBlank = true;
            TableRelation = "Vendor Certification Type";
        }
        field(5; "Effective Date"; Date)
        {
            Caption = 'Effective Date';
            NotBlank = true;
        }
        field(6; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
        }
        field(7; "Certificate No."; Code[30])
        {
            Caption = 'Certificate No.';
        }
    }

    keys
    {
        key(Key1; "Vendor No.", "Source Type", "Order Address Code", Type, "Effective Date")
        {
        }
        key(Key2; "Expiration Date")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Vendor: Record Vendor;

    procedure GetTypeDescription(): Text[100]
    var
        VendorCertificationType: Record "Vendor Certification Type";
    begin
        if VendorCertificationType.Get(Type) then
            exit(VendorCertificationType.Description)
        else
            exit('');
    end;

    local procedure GetVendor()
    begin
        if "Vendor No." = '' then
            Clear(Vendor)
        else
            if Vendor."No." <> "Vendor No." then
                Vendor.Get("Vendor No.");
    end;

    procedure GetVendorNo(): Code[20]
    begin
        GetVendor;
        exit(Vendor."No.");
    end;

    procedure GetVendorName(): Text[100]
    begin
        GetVendor;
        exit(Vendor.Name);
    end;
}

