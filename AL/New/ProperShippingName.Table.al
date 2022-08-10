table 37002006 "Proper Shipping Name"
{
    // PRW16.00
    // P8000639, VerticalSoft, Jack Reynolds, 18 NOV 08
    //   Add DropDown field group
    // 
    // PRW17.10.03
    // P8001350, Columbus IT, Jack Reynolds, 26 SEP 14
    //   Don't allow blank Code

    Caption = 'Proper Shipping Name';
    LookupPageID = "Proper Shipping Names";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; "Proper Shipping Name"; Text[80])
        {
            Caption = 'Proper Shipping Name';
        }
        field(3; "Hazard Class"; Code[10])
        {
            Caption = 'Hazard Class';
        }
        field(4; Hazardous; Boolean)
        {
            Caption = 'Hazardous';
        }
        field(5; "DOT ID"; Code[10])
        {
            Caption = 'DOT ID';
        }
        field(6; "Packaging Group"; Code[5])
        {
            Caption = 'Packaging Group';
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
        fieldgroup(DropDown; "Code", "Proper Shipping Name")
        {
        }
    }
}

